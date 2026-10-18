import host.load.Summary
import host.load.Parameters
namespace Host.Load.Extract
open Lean Elab Command Meta Host.Mlx

private structure PG where
  pre : Lean.Name
  idx : Nat := 0
  tensors : Std.HashMap (Nat × Nat) Lean.Name := {}
private abbrev PM := StateT PG TermElabM

private def tensorE (v : Lean.Expr) (t : Tensor) : PM Lean.Expr := do
  let n ← match (← get).tensors[(t.handle, t.node)]? with
    | some n => pure n
    | none =>
      let g ← get
      let n := g.pre ++ Name.mkSimple s!"tensor{g.idx}"
      addDecl (.defnDecl { name := n, levelParams := [], type := mkConst ``Tensor, value := toExpr t, hints := .regular 0, safety := .safe })
      modify fun g => { g with idx := g.idx + 1, tensors := g.tensors.insert (t.handle, t.node) n }
      pure n
  pure (mkApp v (mkConst n))

private def kindE (cs : List Char) : PM Lean.Expr := do
  match projector cs with
  | some .plain => pure (mkConst ``GlueLayers.Projector.plain)
  | some .affineRow => pure (mkConst ``GlueLayers.Projector.affineRow)
  | none => throwError "unknown projection operation"

private def linearE (v : Lean.Expr) (l : Linear) : PM Lean.Expr := do
  let some b := l.biases | throwError "missing affine bias"
  pure (mkAppN (mkConst ``GlueLayers.Linear.mk) #[← tensorE v l.words, ← tensorE v l.scales, ← tensorE v b, toExpr l.bits])

private def mlpE (v : Lean.Expr) (m : Mlp) : PM Lean.Expr := do
  pure (mkAppN (mkConst ``GlueLayers.MlpWeights.mk) #[← tensorE v m.norm,
    ← tensorE v m.gate.codes, ← tensorE v m.gate.scales, ← tensorE v m.up.codes, ← tensorE v m.up.scales,
    ← tensorE v m.down.codes, ← tensorE v m.down.scales, toExpr m.gate.bits, toExpr m.up.bits, toExpr m.down.bits])

private def required (s : Stage) (nm : List Char) : PM Tensor := do
  let some t := namedTensor s.tensors nm | throwError "missing stage tensor"
  pure t

private def deltaE (v : Lean.Expr) (s : Stage) : PM Lean.Expr := do
  let [(_, qkv), (_, z), (_, a), (_, b), (_, out)] := s.linears | throwError "delta linears"
  pure (mkAppN (mkConst ``GlueLayers.DeltaWeights.mk) #[← tensorE v s.inputNorm,
    ← linearE v qkv, ← linearE v z, ← linearE v a, ← linearE v b, ← linearE v out,
    ← kindE qkv.operation, ← kindE z.operation, ← kindE out.operation,
    ← tensorE v (← required s chars!"convWeight"), ← tensorE v (← required s chars!"aLog"),
    ← tensorE v (← required s chars!"dtBias"), ← tensorE v (← required s chars!"normWeight"),
    ← tensorE v (← required s chars!"qScale"), ← tensorE v (← required s chars!"kScale"), ← mlpE v s.mlp])

private def attentionE (v : Lean.Expr) (s : Stage) : PM Lean.Expr := do
  let [(_, q), (_, k), (_, val), (_, o)] := s.linears | throwError "attention linears"
  pure (mkAppN (mkConst ``GlueLayers.AttentionWeights.mk) #[← tensorE v s.inputNorm,
    ← linearE v q, ← linearE v k, ← linearE v val, ← linearE v o,
    ← kindE q.operation, ← kindE k.operation, ← kindE val.operation, ← kindE o.operation,
    ← tensorE v (← required s chars!"qNorm"), ← tensorE v (← required s chars!"kNorm"), ← mlpE v s.mlp])

private def listE (ty : Lean.Expr) (es : List Lean.Expr) : Lean.Expr :=
  es.foldr (mkApp2 (mkApp (mkConst ``List.cons [.zero]) ty)) (mkApp (mkConst ``List.nil [.zero]) ty)

private def selectionE (ty : Lean.Expr) (es : List Lean.Expr) : TermElabM Lean.Expr := do
  let n := mkRawNatLit es.length
  let xs := listE ty es
  withLocalDeclD `i (mkApp (mkConst ``Fin) n) fun i => do
    let len := mkApp2 (mkConst ``List.length [.zero]) ty xs
    let val := mkApp2 (mkConst ``Fin.val) n i
    let lt := mkApp2 (mkConst ``Fin.isLt) n i
    mkLambdaFVars #[i] (mkApp3 (mkConst ``List.get [.zero]) ty xs (mkApp3 (mkConst ``Fin.mk) len val lt))

/-- Choose a compact function of the actual tensor Values. Its agreement with
`pipelineWeights` is checked for every interpretation in the kernel. Splitting
stages and tensors by name avoids repeatedly reducing the entire option-valued
extractor when proving individual header and source-selection facts. -/
elab "load_parameters " name:ident " : " summary:term : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ name.getId
  let lE ← instantiateMVars (← Term.elabTermAndSynthesize summary (some (mkConst ``Loaded)))
  let l ← unsafe evalExpr Loaded (mkConst ``Loaded) lE
  let .some _ := pipelineWeights l (fun _ => zeros [] .uint32) | throwError "unsupported source parameter metadata"
  let ty := mkConst ``TensorValues
  let out := mkConst ``GlueStep.PipelineWeights
  let action : PM Lean.Expr := do
    withLocalDeclD `value ty fun v => do
      let mut ds := []
      let mut ats := []
      for i in List.range 64 do
        let some s := l.model.stages[i]? | throwError "missing stage"
        let stTy := if i % 4 == 3 then mkConst ``GlueLayers.AttentionWeights else mkConst ``GlueLayers.DeltaWeights
        let body ← if i % 4 == 3 then attentionE v s else deltaE v s
        let body ← mkLambdaFVars #[v] body
        let g ← get
        let nm := g.pre ++ Name.mkSimple s!"stage{i}"
        addDecl (.defnDecl { name := nm, levelParams := [], type := ← mkArrow ty stTy, value := body, hints := .regular 0, safety := .safe })
        if i % 4 == 3 then ats := ats ++ [mkApp (mkConst nm) v] else ds := ds ++ [mkApp (mkConst nm) v]
      let some w := namedTensor l.model.embedding chars!"w" | throwError "embedding words"
      let some sc := namedTensor l.model.embedding chars!"scales" | throwError "embedding scales"
      let some b := namedTensor l.model.embedding chars!"biases" | throwError "embedding biases"
      let body := mkAppN (mkConst ``GlueStep.PipelineWeights.mk) #[← tensorE v w, ← tensorE v sc, ← tensorE v b,
        ← selectionE (mkConst ``GlueLayers.DeltaWeights) ds, ← selectionE (mkConst ``GlueLayers.AttentionWeights) ats,
        ← tensorE v l.model.finalNorm, ← linearE v l.model.head]
      mkLambdaFVars #[v] body
  let (body, _) ← action.run {pre}
  addDecl (.defnDecl { name := pre, levelParams := [], type := ← mkArrow ty out, value := body, hints := .regular 0, safety := .safe })
  let pf ← withLocalDeclD `value ty fun v => do
    let lhs := mkApp2 (mkConst ``pipelineWeights) lE v
    let rhs := mkApp2 (mkConst ``Option.some [.zero]) out (mkApp (mkConst pre) v)
    let eq := mkApp3 (mkConst ``Eq [.succ .zero]) (mkApp (mkConst ``Option [.zero]) out) lhs rhs
    let proof := mkApp2 (mkConst ``Eq.refl [.succ .zero]) (mkApp (mkConst ``Option [.zero]) out) lhs
    pure (← mkForallFVars #[v] eq, ← mkLambdaFVars #[v] proof)
  addDecl (.thmDecl { name := pre ++ `matches, levelParams := [], type := pf.1, value := pf.2 })

end Host.Load.Extract

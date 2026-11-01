import host.route.cert.Fin.Cls
import host.simgraph.Choose
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.Cert.Fin
open Lean Elab Command Meta Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Extract

/-! # Choosing a class's carriers (search only)

`simgraph_choose_fin X : (sEnd, SEnd), (sStart, SStart), (sEnv, SEnv), B, V, E, d, tok, G`: `simgraph_choose` reading the end state through
`numsV SEnd B V E d`, carriers from `tok` on preferred. It defines `X.cert`, `X.inputs`, `X.outputs`. Nothing here is trusted: the kernel checks
the result. -/

private def addDef (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit := do
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })
  compileDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

private unsafe def chooseFinCmd (pre : Lean.Name) (sEnd SEnd sStart SStart sEnv SEnv : Lean.Name)
    (bE vE eE dE lowE tokE expected : Lean.Expr) : TermElabM Unit := do
  let (e, S, _) ← Host.Ts.Sim.Template.restore (mkConst sEnd) (mkConst SEnd) `simgraphEnd
  let (b, _, _) ← Host.Ts.Sim.Template.restore (mkConst sStart) (mkConst SStart) `simgraphStart
  let (p0, _, _) ← Host.Ts.Sim.Template.restore (mkConst sEnv) (mkConst SEnv) `simgraphEnv
  let natTy := mkConst ``Nat
  let B ← evalExpr Box (mkConst ``Box) bE
  let V ← evalExpr VarV (mkConst ``VarV) vE
  let E ← evalExpr (List (Nat × Nat)) (mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``Prod [.zero, .zero]) natTy natTy)) eE
  let d ← evalExpr Int (mkConst ``Int) dE
  let low ← evalExpr Nat natTy lowE
  let tok ← evalExpr Nat natTy tokE
  let x := e.aux.ffi.mlx
  let some lT := loadedT b (entryEnv p0) | throwError "simgraph_choose_fin: the start state's loaded model does not extract"
  let some tokNode := x.nodes.get tok | throwError "simgraph_choose_fin: no token node {tok}"
  let inputs := inputNode lT ⟨0, tok, tokNode⟩
  let outs : List (Option Nat × Option Nat) := match loadedT e (entryEnv p0) with
    | some lE => lE.cache.map fun c => (c.first.map (·.node), c.second.map (·.node))
    | none => []
  let nodesTy := mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``RNode) (mkConst ``SDim) (mkConst ``InKey))
  let G ← evalExpr (List (RNode SDim InKey)) nodesTy expected
  let actual := domainNodes (numsV S B V E d) 15235 15235 [5554869888] x
  let cert ← match chooseD actual G inputs low with
    | .ok c => pure c
    | .error m => throwError "simgraph_choose_fin: {m}"
  let used : List (InKey × Nat) := (G.zip cert).filterMap fun (n, c) => match n.prim with
    | .input key => some (key, c)
    | _ => none
  addDef (pre ++ `cert) (mkApp (mkConst ``List [.zero]) natTy) (toExpr cert)
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``InKey) natTy
  addDef (pre ++ `inputs) (mkApp (mkConst ``List [.zero]) pairTy) (toExpr used)
  let optNat := mkApp (mkConst ``Option [.zero]) natTy
  addDef (pre ++ `outputs) (mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``Prod [.zero, .zero]) optNat optNat))
    (toExpr outs)
  logInfo m!"simgraph_choose_fin {pre}: {cert.length} carriers, {used.length} inputs, end nnext {x.nnext}, last {cert.getLast? }"

elab "simgraph_choose_fin " name:ident " : " "(" sE:ident ", " SE:ident ")" ", " "(" sS:ident ", " SS:ident ")" ", "
    "(" sV:ident ", " SV:ident ")" ", " B:term ", " V:term ", " E:term ", " d:term ", " low:term ", " tok:term ", " expected:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let el (stx : Syntax) (ty : Option Lean.Expr) := do instantiateMVars (← Term.elabTermAndSynthesize stx ty)
    let resolve (i : Syntax) := do realizeGlobalConstNoOverloadWithInfo i
    let natTy := mkConst ``Nat
    unsafe chooseFinCmd ((← getCurrNamespace) ++ name.getId) (← resolve sE) (← resolve SE) (← resolve sS) (← resolve SS)
      (← resolve sV) (← resolve SV) (← el B (some (mkConst ``Box))) (← el V (some (mkConst ``VarV)))
      (← el E (some (mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``Prod [.zero, .zero]) natTy natTy))))
      (← el d (some (mkConst ``Int))) (← el low (some natTy)) (← el tok (some natTy)) (← el expected none)

end Host.Route.Cert.Fin

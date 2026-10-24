import host.sim.template.Build
import host.simgraph.Domain
import host.simgraph.Command
import host.mlx.KernelSources
import host.simgraph.prompt.NativeD
namespace Host.Mlx.SimGraph
open Lean Elab Command Meta Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Load.Extract

/-! # Choosing a template certificate (search only)

`simgraph_choose X : (sEnd, SEnd), (sStart, SStart), (sEnv, SEnv), p, NL, N0, fixed, tok, E`
restores the template's end and start states from their streams, reads the
end state's graph symbolically on `tplDom NL N0 fixed` (`clsOf SEnd p`), takes
the inputs from the start state's loaded model and caches (`loadedT`, entry
environment of `sEnv`) and the token node `tok`, and searches carriers for the
expected graph `E`. It defines `X.cert : List Nat`, `X.inputs : List (InKey × Nat)` (the input
carriers) and `X.outputs` (the end state's cache tensor nodes). Nothing here is trusted: `simgraph_check_template` checks
the result in the kernel.

With a trailing `classifying cls` (`cls : SSrv → NumV → Option PDim`, e.g. `fun S => clsOfP S B`)
the end state is read through `cls SEnd` into `PDim` dimensions and `E : List (RNode PDim InKey)`
(`p` is unused): a multi-parameter template's certificate, checked by `simgraph_check_template`
with the `ToExpr PDim` instance below. -/

deriving instance Lean.ToExpr for PDim

private def handle : Ffi.Prim → Option Nat
  | .kernel k _ _ => some k
  | .replayed _ p => handle p
  | _ => none

/-- Carriers for `expected` among the resolved nodes `actual` (preferring ids from `lower`), at any
dimension type (`SDim` for a decode template, `PDim` for a multi-parameter one). -/
def chooseD {δ : Type} [DecidableEq δ] (actual : Array (Option (RNode δ InKey))) (expected : List (RNode δ InKey))
    (inputs : InKey → Option Nat) (lower : Nat) : Except String (List Nat) := do
  let graph := fun i => actual[i]?.join
  let mut buckets : Std.HashMap (List Nat) (Array Nat) := {}
  let mut exponentials : Array Nat := #[]
  for i in [:actual.size] do
    if let some n := graph i then
      buckets := buckets.insert n.ins ((buckets[n.ins]?).getD #[] |>.push i)
      if isExpD n.prim then exponentials := exponentials.push i
  let mut cert : Array Nat := #[]
  let mut used : Std.HashSet Nat := {}
  for e in expected do
    let k := cert.size
    let carrier ← match e.prim with
      | .input key => match inputs key with
        | some i => pure i
        | none => throw s!"missing input at expected node {k}"
      | _ => do
        let ins := e.ins.map (cert[·]?.getD 0)
        let candidates := if e.prim = .computeG then exponentials else (buckets[ins]?).getD #[]
        let accepts := fun i => ins.all (· < i) &&
          if e.prim = .computeG then decide (cgLeaves graph i = some ins)
          else !isExpD e.prim && match graph i with
            | none => false
            | some r => decide (strip r.prim = e.prim ∧ (r.prim = e.prim ∨ elementwise e.prim = false) ∧ r.ins = ins)
        let found := (candidates.find? fun i => lower ≤ i && !used.contains i && accepts i).orElse fun _ =>
          (candidates.find? fun i => !used.contains i && accepts i).orElse fun _ => candidates.find? accepts
        match found with
        | some i => pure i
        | none => throw s!"no carrier at expected node {k}; candidates={candidates.size}; ins={ins}"
    cert := cert.push carrier
    used := used.insert carrier
  return cert.toList

/-- The end state's nodes on the template domain `tplDom NL N0 fixed`, read through `N`. -/
def domainNodes {δ : Type} (N : Nums δ) (NL N0 : Nat) (fixed : List Int) (x : Ffi.St) :
    Array (Option (RNode δ InKey)) := Id.run do
  let kn := kernelName? SourceKernels.sources x
  let mut actual : Array (Option (RNode δ InKey)) := Array.replicate x.nnext none
  for i in [:x.nnext] do
    if tplDom NL N0 fixed x i then
      actual := actual.set! i ((x.nodes.get i).bind (resolveNode N kn))
  return actual

private def addDef (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit := do
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })
  compileDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

/-- Search the carriers of `E` among `actual`; define `pre.cert`, `pre.inputs` and `pre.outputs`. -/
private def chooseFinish {δ : Type} [DecidableEq δ] (pre : Lean.Name) (actual : Array (Option (RNode δ InKey)))
    (E : List (RNode δ InKey)) (inputs : InKey → Option Nat) (N0 : Nat) (outs : List (Option Nat × Option Nat)) :
    TermElabM Unit := do
  let natTy := mkConst ``Nat
  let cert ← match chooseD actual E inputs N0 with
    | .ok c => pure c
    | .error m => throwError "simgraph_choose: {m}"
  let used : List (InKey × Nat) := (E.zip cert).filterMap fun (n, c) => match n.prim with
    | .input key => some (key, c)
    | _ => none
  let listNat := mkApp (mkConst ``List [.zero]) natTy
  addDef (pre ++ `cert) listNat (toExpr cert)
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``InKey) natTy
  addDef (pre ++ `inputs) (mkApp (mkConst ``List [.zero]) pairTy) (toExpr used)
  let optNat := mkApp (mkConst ``Option [.zero]) natTy
  addDef (pre ++ `outputs) (mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``Prod [.zero, .zero]) optNat optNat))
    (toExpr outs)
  logInfo m!"simgraph_choose {pre}: {cert.length} carriers, {used.length} inputs; domain nodes {(actual.toList.filter Option.isSome).length}"

private unsafe def chooseCmd (pre : Lean.Name) (sEnd SEnd sStart SStart sEnv SEnv : Lean.Name)
    (p NL N0 fixed tok expected : Lean.Expr) (cls : Option Lean.Expr) : TermElabM Unit := do
  let (e, S, _) ← Host.Ts.Sim.Template.restore (mkConst sEnd) (mkConst SEnd) `simgraphEnd
  let (b, _, _) ← Host.Ts.Sim.Template.restore (mkConst sStart) (mkConst SStart) `simgraphStart
  let (p0, _, _) ← Host.Ts.Sim.Template.restore (mkConst sEnv) (mkConst SEnv) `simgraphEnv
  let natTy := mkConst ``Nat
  let p ← evalExpr Nat natTy p
  let NL ← evalExpr Nat natTy NL
  let N0 ← evalExpr Nat natTy N0
  let fixed ← evalExpr (List Int) (mkApp (mkConst ``List [.zero]) (mkConst ``Int)) fixed
  let tok ← evalExpr Nat natTy tok
  let x := e.aux.ffi.mlx
  let some lT := loadedT b (entryEnv p0) | throwError "simgraph_choose: the start state's loaded model does not extract"
  let some tokNode := x.nodes.get tok | throwError "simgraph_choose: no token node {tok}"
  let inputs := inputNode lT ⟨0, tok, tokNode⟩
  let some lE := loadedT e (entryEnv p0) | throwError "simgraph_choose: the end state's caches do not extract"
  let outs : List (Option Nat × Option Nat) := lE.cache.map fun c => (c.first.map (·.node), c.second.map (·.node))
  match cls with
  | none =>
    let nodesTy := mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``RNode) (mkConst ``SDim) (mkConst ``InKey))
    let E ← evalExpr (List (RNode SDim InKey)) nodesTy expected
    chooseFinish pre (domainNodes (symNums (clsOf S p)) NL N0 fixed x) E inputs N0 outs
  | some c =>
    let optP := mkApp (mkConst ``Option [.zero]) (mkConst ``PDim)
    let clsTy ← mkArrow (mkConst ``SSrv) (← mkArrow (mkConst ``NumV) optP)
    let c ← evalExpr (SSrv → NumV → Option PDim) clsTy c
    let nodesTy := mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``RNode) (mkConst ``PDim) (mkConst ``InKey))
    let E ← evalExpr (List (RNode PDim InKey)) nodesTy expected
    chooseFinish pre (domainNodes (symNumsD (c S) PDim.lit) NL N0 fixed x) E inputs N0 outs

elab "simgraph_choose " name:ident " : " "(" sE:ident ", " SE:ident ")" ", " "(" sS:ident ", " SS:ident ")" ", "
    "(" sV:ident ", " SV:ident ")" ", " p:term ", " NL:term ", " N0:term ", " fixed:term ", " tok:term ", "
    expected:term cls:((" classifying " term)?) : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let el (stx : Syntax) := do instantiateMVars (← Term.elabTermAndSynthesize stx none)
    let resolve (i : Syntax) := do realizeGlobalConstNoOverloadWithInfo i
    let cls ← match cls.raw.getArgs.toList with
      | [_, c] => pure (some (← el c))
      | _ => pure none
    unsafe chooseCmd ((← getCurrNamespace) ++ name.getId) (← resolve sE) (← resolve SE) (← resolve sS) (← resolve SS)
      (← resolve sV) (← resolve SV) (← el p) (← el NL) (← el N0) (← el fixed) (← el tok) (← el expected) cls

/-- The input table as a function. -/
def inputsOf (l : List (InKey × Nat)) (k : InKey) : Option Nat := (l.find? (·.1 == k)).map (·.2)

end Host.Mlx.SimGraph

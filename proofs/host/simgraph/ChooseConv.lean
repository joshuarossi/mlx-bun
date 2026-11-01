import host.simgraph.Choose
import host.simgraph.ClassifyConv
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Mlx.SimGraph
open Lean Elab Command Meta Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Load.Extract

/-! # Choosing an abstract decode template's carriers (search only)

`simgraph_choose_conv X : (sEnd, SEnd), (sStart, SStart), (sEnv, SEnv), p, pin, NL, N0, fixed, tok, E`: `simgraph_choose` reading the end
state through `clsConv SEnd p pin`. It defines `X.cert`, `X.inputs`, `X.outputs`. Nothing here is trusted: the kernel checks the result. -/

private def addDefC (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit := do
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })
  compileDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

private unsafe def chooseConvCmd (pre : Lean.Name) (sEnd SEnd sStart SStart sEnv SEnv : Lean.Name)
    (pE pinE NLE N0E fixedE tokE expected : Lean.Expr) : TermElabM Unit := do
  let (e, S, _) ← Host.Ts.Sim.Template.restore (mkConst sEnd) (mkConst SEnd) `simgraphEnd
  let (b, _, _) ← Host.Ts.Sim.Template.restore (mkConst sStart) (mkConst SStart) `simgraphStart
  let (p0, _, _) ← Host.Ts.Sim.Template.restore (mkConst sEnv) (mkConst SEnv) `simgraphEnv
  let natTy := mkConst ``Nat
  let p ← evalExpr Nat natTy pE
  let pin ← evalExpr (Nat → Option Nat) (← mkArrow natTy (mkApp (mkConst ``Option [.zero]) natTy)) pinE
  let NL ← evalExpr Nat natTy NLE
  let N0 ← evalExpr Nat natTy N0E
  let fixed ← evalExpr (List Int) (mkApp (mkConst ``List [.zero]) (mkConst ``Int)) fixedE
  let tok ← evalExpr Nat natTy tokE
  let x := e.aux.ffi.mlx
  let some lT := loadedT b (entryEnv p0) | throwError "simgraph_choose_conv: the start state's loaded model does not extract"
  let some tokNode := x.nodes.get tok | throwError "simgraph_choose_conv: no token node {tok}"
  let inputs := inputNode lT ⟨0, tok, tokNode⟩
  let some lE := loadedT e (entryEnv p0) | throwError "simgraph_choose_conv: the end state's caches do not extract"
  let outs : List (Option Nat × Option Nat) := lE.cache.map fun c => (c.first.map (·.node), c.second.map (·.node))
  let nodesTy := mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``RNode) (mkConst ``SDim) (mkConst ``InKey))
  let E ← evalExpr (List (RNode SDim InKey)) nodesTy expected
  let actual := domainNodes (symNums (clsConv S p pin)) NL N0 fixed x
  let cert ← match chooseD actual E inputs N0 with
    | .ok c => pure c
    | .error m => throwError "simgraph_choose_conv: {m}"
  let used : List (InKey × Nat) := (E.zip cert).filterMap fun (n, c) => match n.prim with
    | .input key => some (key, c)
    | _ => none
  addDefC (pre ++ `cert) (mkApp (mkConst ``List [.zero]) natTy) (toExpr cert)
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``InKey) natTy
  addDefC (pre ++ `inputs) (mkApp (mkConst ``List [.zero]) pairTy) (toExpr used)
  let optNat := mkApp (mkConst ``Option [.zero]) natTy
  addDefC (pre ++ `outputs) (mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``Prod [.zero, .zero]) optNat optNat))
    (toExpr outs)
  logInfo m!"simgraph_choose_conv {pre}: {cert.length} carriers, {used.length} inputs; domain nodes {(actual.toList.filter Option.isSome).length}"

elab "simgraph_choose_conv " name:ident " : " "(" sE:ident ", " SE:ident ")" ", " "(" sS:ident ", " SS:ident ")" ", "
    "(" sV:ident ", " SV:ident ")" ", " p:term ", " pin:term ", " NL:term ", " N0:term ", " fixed:term ", " tok:term ", "
    expected:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let el (stx : Syntax) := do instantiateMVars (← Term.elabTermAndSynthesize stx none)
    let resolve (i : Syntax) := do realizeGlobalConstNoOverloadWithInfo i
    unsafe chooseConvCmd ((← getCurrNamespace) ++ name.getId) (← resolve sE) (← resolve SE) (← resolve sS) (← resolve SS)
      (← resolve sV) (← resolve SV) (← el p) (← el pin) (← el NL) (← el N0) (← el fixed) (← el tok) (← el expected)

end Host.Mlx.SimGraph

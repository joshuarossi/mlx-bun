import host.route.cert.Row.Cls
import host.simgraph.Choose
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.Cert.Row
open Lean Elab Command Meta Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Extract

/-! # Choosing a row's carriers (search only)

`simgraph_choose_row X : (sEnd, SEnd), (sStart, SStart), (sEnv, SEnv), d, tok, E`: `simgraph_choose` reading the end state through
`rowNums SEnd d`. It defines `X.cert`, `X.inputs`, `X.outputs`. Nothing here is trusted: `simgraph_check_template` checks the
result in the kernel. -/

private def addDef (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit := do
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })
  compileDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

private unsafe def chooseRowCmd (pre : Lean.Name) (sEnd SEnd sStart SStart sEnv SEnv : Lean.Name)
    (dE tokE expected : Lean.Expr) : TermElabM Unit := do
  let (e, S, _) ← Host.Ts.Sim.Template.restore (mkConst sEnd) (mkConst SEnd) `simgraphEnd
  let (b, _, _) ← Host.Ts.Sim.Template.restore (mkConst sStart) (mkConst SStart) `simgraphStart
  let (p0, _, _) ← Host.Ts.Sim.Template.restore (mkConst sEnv) (mkConst SEnv) `simgraphEnv
  let natTy := mkConst ``Nat
  let d ← evalExpr Int (mkConst ``Int) dE
  let tok ← evalExpr Nat natTy tokE
  let x := e.aux.ffi.mlx
  let some lT := loadedT b (entryEnv p0) | throwError "simgraph_choose_row: the start state's loaded model does not extract"
  let some tokNode := x.nodes.get tok | throwError "simgraph_choose_row: no token node {tok}"
  let inputs := inputNode lT ⟨0, tok, tokNode⟩
  let some lE := loadedT e (entryEnv p0) | throwError "simgraph_choose_row: the end state's caches do not extract"
  let outs : List (Option Nat × Option Nat) := lE.cache.map fun c => (c.first.map (·.node), c.second.map (·.node))
  let nodesTy := mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``RNode) (mkConst ``SDim) (mkConst ``InKey))
  let E ← evalExpr (List (RNode SDim InKey)) nodesTy expected
  let actual := domainNodes (rowNums S d) 15235 15235 [5554869888] x
  let cert ← match chooseD actual E inputs 15235 with
    | .ok c => pure c
    | .error m => throwError "simgraph_choose_row: {m}"
  let used : List (InKey × Nat) := (E.zip cert).filterMap fun (n, c) => match n.prim with
    | .input key => some (key, c)
    | _ => none
  addDef (pre ++ `cert) (mkApp (mkConst ``List [.zero]) natTy) (toExpr cert)
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``InKey) natTy
  addDef (pre ++ `inputs) (mkApp (mkConst ``List [.zero]) pairTy) (toExpr used)
  let optNat := mkApp (mkConst ``Option [.zero]) natTy
  addDef (pre ++ `outputs) (mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``Prod [.zero, .zero]) optNat optNat))
    (toExpr outs)
  logInfo m!"simgraph_choose_row {pre}: {cert.length} carriers, {used.length} inputs, end nnext {x.nnext}, token {cert.getD 0 0}"

elab "simgraph_choose_row " name:ident " : " "(" sE:ident ", " SE:ident ")" ", " "(" sS:ident ", " SS:ident ")" ", "
    "(" sV:ident ", " SV:ident ")" ", " d:term ", " tok:term ", " expected:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let el (stx : Syntax) (ty : Option Lean.Expr) := do instantiateMVars (← Term.elabTermAndSynthesize stx ty)
    let resolve (i : Syntax) := do realizeGlobalConstNoOverloadWithInfo i
    unsafe chooseRowCmd ((← getCurrNamespace) ++ name.getId) (← resolve sE) (← resolve SE) (← resolve sS) (← resolve SS)
      (← resolve sV) (← resolve SV) (← el d (some (mkConst ``Int))) (← el tok (some (mkConst ``Nat))) (← el expected none)

end Host.Route.Cert.Row

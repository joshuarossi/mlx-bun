import host.load.RuntimeBlockPlan
import host.ts.RenameCompiledArgumentEntryChainStep
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

/-- The actual `Ctl.ret` / `Frame.e` `ExprF.chain` continuation. Everything else
stays with the existing linear planner. -/
private def chainReturn? (state : String) : CommandElabM Bool := do
  let stx ← liftCoreM <| ofExcept <| Parser.runParserCategory (← getEnv) `term state
  liftTermElabM do
    let s ← Term.elabTerm stx none
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.ret 1 do return false
    let stack ← whnf (← mkAppM ``St.stack #[s])
    unless stack.isAppOfArity ``List.cons 3 do return false
    let frame ← whnf stack.getAppArgs[1]!
    unless frame.isAppOfArity ``Frame.e 1 do return false
    return (← whnf frame.getAppArgs[0]!).isConstOf ``ExprF.chain

private partial def readName (expression : Lean.Expr) : MetaM Lean.Name := do
  let expression ← whnf expression
  if expression.isConstOf ``Lean.Name.anonymous then return Lean.Name.anonymous
  if expression.isAppOfArity ``Lean.Name.str 2 then
    let parent ← readName expression.getAppArgs[0]!
    let some segment := getStringValue? (← whnf expression.getAppArgs[1]!)
      | throwError "compiled argument plan: invalid name segment"
    return Lean.Name.str parent segment
  if expression.isAppOfArity ``Lean.Name.num 2 then
    let parent ← readName expression.getAppArgs[0]!
    let some index ← getNatValue? (← whnf expression.getAppArgs[1]!)
      | throwError "compiled argument plan: invalid name index"
    return Lean.Name.num parent index
  throwError "compiled argument plan: unreadable declaration name"

private partial def readNames (expression : Lean.Expr) : MetaM (List Lean.Name) := do
  let expression ← whnf expression
  if expression.isAppOfArity ``List.nil 1 then return []
  unless expression.isAppOfArity ``List.cons 3 do
    throwError "compiled argument plan: unreadable name list"
  return (← readName expression.getAppArgs[1]!) :: (← readNames expression.getAppArgs[2]!)

private partial def readNats (expression : Lean.Expr) : MetaM (List Nat) := do
  let expression ← whnf expression
  if expression.isAppOfArity ``List.nil 1 then return []
  unless expression.isAppOfArity ``List.cons 3 do
    throwError "compiled argument plan: unreadable span list"
  let some n ← getNatValue? (← whnf expression.getAppArgs[1]!)
    | throwError "compiled argument plan: unreadable span"
  return n :: (← readNats expression.getAppArgs[2]!)

private def definitionValue (name : Lean.Name) : CommandElabM Lean.Expr :=
  liftTermElabM do
    whnf (← getConstInfoDefn name).value

/-- Local block selector for the compiled-argument region. Chain returns use the
local continuation; every other contiguous span reuses the checked linear planner.
Central drivers are not registered. -/
elab "host_compiled_argument_linear_plan " f:term ", " base:ident " from " start:num
    " plan_steps " count:num " as " name:ident : command => do
  let some fText := f.raw.reprint | throwError "compiled argument plan: cannot print Ffi"
  let some baseText := base.raw.reprint | throwError "compiled argument plan: cannot print the source region"
  let count := count.getNat
  let start := start.getNat
  unless 0 < count && start + count ≤ 280 do
    throwError "compiled argument plan: expected a non-empty region inside steps 0..279"
  let root := base.getId.toString
  let oracle := "Host.Ts.Owned.Annotated.LoopVariables.oracleVariables"
  let state (index : Nat) := s!"{root}.s{index}"
  let server (index : Nat) := s!"(({root}.S{index}).substitute ({oracle}))"
  let mut cursor := start
  let finish := start + count
  let mut rules : List Lean.Name := []
  let mut spans : List Nat := []
  let mut starts : List Nat := []
  while cursor < finish do
    if ← chainReturn? (state cursor) then
      let relative := name.getId ++ Lean.Name.mkSimple s!"Chain{cursor}"
      let block := (← getCurrNamespace) ++ relative
      Parametric.Driver.emit s!"host_compiled_argument_chain_step {fText}, {state cursor} using {server cursor} to {state (cursor + 1)} using {server (cursor + 1)} as {relative}"
      unless (← getEnv).contains (block ++ `retained_transport) do
        throwError "compiled argument plan: chain return was not checked at region index {cursor}"
      if (← get).messages.hasErrors then
        throwError "compiled argument plan: chain return failed at region index {cursor}"
      rules := rules ++ [block ++ `retained_transport]
      spans := spans ++ [1]
      starts := starts ++ [cursor]
      cursor := cursor + 1
    else
      let mut span := 1
      while cursor + span < finish do
        if ← chainReturn? (state (cursor + span)) then break
        span := span + 1
      let relative := name.getId ++ Lean.Name.mkSimple s!"Span{cursor}"
      let block := (← getCurrNamespace) ++ relative
      Parametric.Driver.emit s!"host_source_linear_plan_subst {fText}, {baseText} from {cursor} plan_steps {span} substitute {oracle} as {relative}"
      unless (← getEnv).contains (block ++ `rules) do
        throwError "compiled argument plan: no checked span was generated at region index {cursor}"
      if (← get).messages.hasErrors then
        throwError "compiled argument plan: source span failed at region index {cursor}"
      rules := rules ++ (← liftTermElabM <| readNames (← definitionValue (block ++ `rules)))
      spans := spans ++ (← liftTermElabM <| readNats (← definitionValue (block ++ `spans)))
      starts := starts ++ (← liftTermElabM <| readNats (← definitionValue (block ++ `starts)))
      cursor := cursor + span
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    Parametric.Driver.addData (pre ++ `rules) (toExpr rules)
    Parametric.Driver.addData (pre ++ `spans) (toExpr spans)
    Parametric.Driver.addData (pre ++ `starts) (toExpr starts)
    Parametric.Driver.addData (pre ++ `sourceSteps) (mkNatLit count)
    Parametric.Driver.addData (pre ++ `blockCount) (mkNatLit rules.length)
  let printed := "_root_." ++ pre.toString
  Parametric.Driver.emit s!"theorem {printed}.span_total : {printed}.spans.sum = {printed}.sourceSteps := by decide +kernel"

end Host.Ts.Owned.Annotated.Driver

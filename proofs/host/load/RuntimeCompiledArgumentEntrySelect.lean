import host.load.RuntimeBlockPlan
import host.ts.RenameCompiledArgumentEntryChainStep
import host.ts.RenameCompiledArgumentEntryNotStep
import host.ts.RenameRetainedStructuralMemberStep
import host.ts.RenameRetainedTypedCountStep
import host.ts.RenameRetainedVariableIndexAssignmentStep
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

private def specialStep? (state : String) : CommandElabM (Option String) := do
  if ← chainReturn? state then return some "Chain"
  let stx ← liftCoreM <| ofExcept <| Parser.runParserCategory (← getEnv) `term state
  liftTermElabM do
    let s ← Term.elabTerm stx none
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    if ctl.isAppOfArity ``Ctl.construct 3 then
      let callee ← whnf ctl.getAppArgs[0]!
      if callee.isAppOfArity ``Val.obj 1 then
        let object? ← whnf (← mkAppM ``St.obj? #[s,callee.getAppArgs[0]!])
        if object?.isAppOfArity ``Option.some 2 then
          let kind ← whnf (← mkAppM ``Obj.kind #[object?.getAppArgs[1]!])
          if kind.isAppOfArity ``Kind.fn 1 then
            let code ← whnf kind.getAppArgs[0]!
            if code.isAppOfArity ``Code.native 2 then
              let native ← whnf code.getAppArgs[0]!
              if native.isAppOfArity ``Native.buf 1 then
                if (← whnf native.getAppArgs[0]!).isConstOf ``BufN.typedCtor then
                  let args ← whnf ctl.getAppArgs[1]!
                  if args.isAppOfArity ``List.cons 3 then
                    let value ← whnf args.getAppArgs[1]!
                    if value.isAppOfArity ``Val.num 1 then
                      if (← whnf value.getAppArgs[0]!).isAppOfArity ``NumV.lit 1 then
                        return some "TypedCount"
    if ctl.isAppOfArity ``Ctl.ev 2 then
      let expression ← whnf ctl.getAppArgs[0]!
      if expression.isAppOfArity ``Expr.assign 3 then
        if (← whnf expression.getAppArgs[0]!).isConstOf ``AsgOp.assign then
          let pat ← whnf expression.getAppArgs[1]!
          if pat.isAppOfArity ``Pat.expr 1 then
            let target ← whnf pat.getAppArgs[0]!
            if target.isAppOfArity ``Expr.index 3 then
              if (← whnf target.getAppArgs[0]!).isAppOfArity ``Expr.id 1 then
                if (← whnf target.getAppArgs[1]!).isAppOfArity ``Expr.id 1 then
                  return some "VariableIndex"
      if expression.isAppOfArity ``Expr.unary 2 then
        if (← whnf expression.getAppArgs[0]!).isConstOf ``UnOp.not then return some "Not"
      return none
    unless ctl.isAppOfArity ``Ctl.ret 1 do return none
    unless (← whnf ctl.getAppArgs[0]!).isAppOfArity ``Val.obj 1 do return none
    let stack ← whnf (← mkAppM ``St.stack #[s])
    unless stack.isAppOfArity ``List.cons 3 do return none
    let frame ← whnf stack.getAppArgs[1]!
    unless frame.isAppOfArity ``Frame.e 1 do return none
    let expression ← whnf frame.getAppArgs[0]!
    if expression.isAppOfArity ``ExprF.unary 1 then
      if (← whnf expression.getAppArgs[0]!).isConstOf ``UnOp.not then return some "Not"
    if expression.isAppOfArity ``ExprF.member 2 then
      unless (← whnf expression.getAppArgs[1]!).isConstOf ``Bool.false do return none
      let address := (← whnf ctl.getAppArgs[0]!).getAppArgs[0]!
      let object? ← whnf (← mkAppM ``St.obj? #[s,address])
      if object?.isAppOfArity ``Option.some 2 then
        let object := object?.getAppArgs[1]!
        if (← whnf (← mkAppM ``Obj.kind #[object])).isConstOf ``Kind.ordinary then
          let key ← whnf expression.getAppArgs[0]!
          if key.isAppOfArity ``PKey.str 1 then
            let data? ← whnf (← mkAppM ``findProp #[key,← mkAppM ``Obj.props #[object]])
            if data?.isAppOfArity ``Option.some 2 then
              let data ← whnf data?.getAppArgs[1]!
              if data.isAppOfArity ``PropV.data 3 then
                if (← whnf (← mkAppM ``structuralRole #[data.getAppArgs[0]!])).isAppOfArity ``Option.some 2 then
                  return some "Member"
    return none

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

/-- Local block selector for the compiled-argument region. Chain returns and
logical not use checked continuations; other spans reuse the linear planner.
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
    if let some kind ← specialStep? (state cursor) then
      let span := if kind == "VariableIndex" then 5 else 1
      unless cursor + span ≤ finish do
        throwError "compiled argument plan: complete indexed assignment exceeds the requested endpoint"
      let relative := name.getId ++ Lean.Name.mkSimple s!"{kind}{cursor}"
      let block := (← getCurrNamespace) ++ relative
      let command := if kind == "Chain" then "host_compiled_argument_chain_step"
        else if kind == "Member" then "host_retained_structural_member"
        else if kind == "TypedCount" then "host_retained_typed_count"
        else if kind == "VariableIndex" then "host_retained_variable_index_assignment"
        else "host_compiled_argument_not_step"
      Parametric.Driver.emit s!"{command} {fText}, {state cursor} using {server cursor} to {state (cursor + span)} using {server (cursor + span)} as {relative}"
      unless (← getEnv).contains (block ++ `retained_transport) do
        throwError "compiled argument plan: {kind} was not checked at region index {cursor}"
      if (← get).messages.hasErrors then
        throwError "compiled argument plan: {kind} failed at region index {cursor}"
      rules := rules ++ [block ++ `retained_transport]
      spans := spans ++ [span]
      starts := starts ++ [cursor]
      cursor := cursor + span
    else
      let mut span := 1
      while cursor + span < finish do
        if (← specialStep? (state (cursor + span))).isSome then break
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

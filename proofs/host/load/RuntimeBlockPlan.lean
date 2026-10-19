import host.load.RuntimeDriver
import host.ts.RenameRetainedMapperCallFrontend
import host.ts.RenameRetainedGetterCallFrontend
import host.ts.RenameRetainedOutArrayReturnFrontend
import host.ts.RenameRuntimeDriverMlxConstructor
import host.ts.RenameRetainedChain
import host.mlx.NativeNumberReturnFrontend
import host.ts.RenameRetainedLiteralArrowFrontend
import host.ts.RenameRetainedOptIntFrontend
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

private def sourceSummary (f source : Syntax) : CommandElabM (Option (String × Nat)) :=
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let source ← Term.elabTermEnsuringType source (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f))
    let control ← whnf (← mkAppM ``St.ctl #[source])
    if control.isAppOfArity ``Ctl.ret 1 then
      if (← whnf control.getAppArgs[0]!).isAppOfArity ``Val.big 1 then
        let stack ← whnf (← mkAppM ``St.stack #[source])
        if stack.isAppOfArity ``List.cons 3 then
          let frame ← whnf stack.getAppArgs[1]!
          if frame.isAppOfArity ``Frame.c 1 then
            let args ← whnf frame.getAppArgs[0]!
            if args.isAppOfArity ``CallF.args 6 then
              let callee ← whnf args.getAppArgs[1]!
              if callee.isAppOfArity ``Val.obj 1 then
                let object ← whnf (← mkAppM ``St.obj? #[source,callee.getAppArgs[0]!])
                if object.isAppOfArity ``Option.some 2 then
                  let kind ← whnf (← mkAppM ``Obj.kind #[object.getAppArgs[1]!])
                  if kind.isAppOfArity ``Kind.fn 1 then
                    let code ← whnf kind.getAppArgs[0]!
                    if code.isAppOfArity ``Code.native 2 then
                      let native ← whnf code.getAppArgs[0]!
                      if native.isAppOfArity ``Native.num 1 then
                        if (← whnf native.getAppArgs[0]!).isConstOf ``NumN.number then
                          return some ("host_retained_number_return",6)
    if control.isAppOfArity ``Ctl.construct 3 then
      let callee ← whnf control.getAppArgs[0]!
      if callee.isAppOfArity ``Val.obj 1 then
        let object ← whnf (← mkAppM ``St.obj? #[source,callee.getAppArgs[0]!])
        if object.isAppOfArity ``Option.some 2 then
          let kind ← whnf (← mkAppM ``Obj.kind #[object.getAppArgs[1]!])
          if kind.isAppOfArity ``Kind.fn 1 then
            if (← whnf kind.getAppArgs[0]!).isAppOfArity ``Code.klass 4 then
              return some ("host_retained_mlx_constructor",37)
    if control.isAppOfArity ``Ctl.ret 1 && (← whnf control.getAppArgs[0]!).isConstOf ``Val.undef then
      let stack ← whnf (← mkAppM ``St.stack #[source])
      if stack.isAppOfArity ``List.cons 3 then
        let frame ← whnf stack.getAppArgs[1]!
        if frame.isAppOfArity ``Frame.s 1 then
          let block ← whnf frame.getAppArgs[0]!
          if block.isAppOfArity ``StmtF.block 2 then
            let statements ← whnf block.getAppArgs[0]!
            if statements.isAppOfArity ``List.cons 3 then
              let first ← whnf statements.getAppArgs[1]!
              if first.isAppOfArity ``Stmt.if_ 3 then
                let condition ← whnf first.getAppArgs[0]!
                if condition.isAppOfArity ``Expr.bin 3 then
                  if (← whnf condition.getAppArgs[0]!).isConstOf ``BinOp.sne then
                    return some ("host_retained_outArray_return",15)
    unless control.isAppOfArity ``Ctl.call 3 do return none
    let callee ← whnf control.getAppArgs[0]!
    unless callee.isAppOfArity ``Val.obj 1 do return none
    let arguments ← whnf control.getAppArgs[2]!
    let object ← whnf (← mkAppM ``St.obj? #[source,callee.getAppArgs[0]!])
    unless object.isAppOfArity ``Option.some 2 do return none
    let kind ← whnf (← mkAppM ``Obj.kind #[object.getAppArgs[1]!])
    unless kind.isAppOfArity ``Kind.fn 1 do return none
    let code ← whnf kind.getAppArgs[0]!
    unless code.isAppOfArity ``Code.closure 4 do return none
    -- Select only the pinned complete optInt body. The frontend separately
    -- proves both source endpoints and the retained arbitrary-target result.
    if ← isDefEq code.getAppArgs[0]! (mkConst ``optIntFunction) then
      if arguments.isAppOfArity ``List.cons 3 then
        if (← whnf arguments.getAppArgs[2]!).isAppOfArity ``List.nil 1 then
          let argument ← whnf arguments.getAppArgs[1]!
          if argument.isConstOf ``Val.null then return some ("host_retained_optInt",18)
          if argument.isAppOfArity ``Val.num 1 then
            if (← whnf argument.getAppArgs[0]!).isAppOfArity ``NumV.lit 1 then
              return some ("host_retained_optInt",40)
    let arrow ← whnf code.getAppArgs[2]!
    let body ← whnf (← Parametric.Driver.field code.getAppArgs[0]! ``Func.mk 7 3)
    if arrow.isConstOf ``Bool.true then
      if body.isAppOfArity ``Body.expr 1 then
        if (← whnf body.getAppArgs[0]!).isAppOfArity ``Expr.lit 1 then
          let params ← whnf (← Parametric.Driver.field code.getAppArgs[0]! ``Func.mk 7 1)
          let rest ← whnf (← Parametric.Driver.field code.getAppArgs[0]! ``Func.mk 7 2)
          if params.isAppOfArity ``List.nil 1 && rest.isAppOfArity ``Option.none 1 then
            return some ("host_retained_literal_arrow",5)
      unless arguments.isAppOfArity ``List.cons 3 do return none
      unless (← whnf arguments.getAppArgs[1]!).isAppOfArity ``Val.obj 1 do return none
      unless body.isAppOfArity ``Body.expr 1 do return none
      let expression ← whnf body.getAppArgs[0]!
      unless expression.isAppOfArity ``Expr.member 3 do return none
      unless (← whnf expression.getAppArgs[0]!).isAppOfArity ``Expr.id 1 do return none
      return some ("host_retained_mapper_call",26)
    if arrow.isConstOf ``Bool.false then
      unless arguments.isAppOfArity ``List.nil 1 do return none
      unless (← whnf control.getAppArgs[1]!).isAppOfArity ``Val.obj 1 do return none
      unless body.isAppOfArity ``Body.block 1 do return none
      let statements ← whnf body.getAppArgs[0]!
      unless statements.isAppOfArity ``List.cons 3 do return none
      let first ← whnf statements.getAppArgs[1]!
      unless first.isAppOfArity ``Stmt.if_ 3 do return none
      let test ← whnf first.getAppArgs[0]!
      unless test.isAppOfArity ``Expr.priv 3 do return none
      return some ("host_retained_getter_call",17)
    return none

/-- Plan at most a thousand original source transitions from imported
hundred-step microstate groups. Successful summaries keep their checked span;
otherwise the original one-transition selector is used. Planning discharges
source facts, while retained entry roles are discharged by the chain consumer. -/
private def generatePlan (f : TSyntax `term) (base : TSyntax `ident)
    (start count : TSyntax `num) (name : TSyntax `ident) (replacement : Option (TSyntax `term))
    (linear : Bool := false) : CommandElabM Unit := do
  let some fText := f.raw.reprint | throwError "host_source_plan: cannot print Ffi"
  let count := count.getNat
  unless 0 < count && count ≤ 1000 do throwError "host_source_plan: expected between 1 and 1000 source transitions"
  let start := start.getNat
  let finish := start+count
  let pre := (← getCurrNamespace) ++ name.getId
  let root := base.getId.toString
  let env ← getEnv
  let boundary (tag : String) (index : Nat) :=
    if linear then s!"{root}.{tag}{index}"
    else
      let inner := base.getId ++ Name.mkSimple s!"micro{index/100}" ++ Name.mkSimple s!"{tag}{index%100}"
      if index%100 == 0 && !env.contains inner then s!"{root}.{tag}{index/100}"
      else inner.toString
  let state (index : Nat) := boundary "s" index
  let replacementText ← replacement.mapM fun expression => do
    let some text := expression.raw.reprint | throwError "host_source_plan: cannot print symbolic substitution"
    pure text
  let server (index : Nat) :=
    let original := boundary "S" index
    match replacementText with
    | none => original
    | some expression => s!"(({original}).substitute ({expression}))"
  let mut cursor := start
  let mut rules : List Lean.Name := []
  let mut spans : List Nat := []
  let mut starts : List Nat := []
  while cursor < finish do
    let relativeBlock := name.getId ++ Name.mkSimple s!"Block{cursor}"
    let block := (← getCurrNamespace) ++ relativeBlock
    let blockText := relativeBlock.toString
    let source := state cursor
    let sourceSyntax ← liftCoreM <| ofExcept (Parser.runParserCategory (← getEnv) `term source)
    let mut span := 1
    if let some (summary,proposedSpan) ← sourceSummary f.raw sourceSyntax then
      if cursor+proposedSpan ≤ finish then
        let saved : Command.State ← get
        let mut accepted := true
        try
          Parametric.Driver.emit s!"{summary} {fText}, {source} using {server cursor} to {state (cursor+proposedSpan)} using {server (cursor+proposedSpan)} as {blockText}"
        catch _ => accepted := false
        if (← get).messages.hasErrors then accepted := false
        unless (← getEnv).contains (block ++ `retained_transport) do accepted := false
        if accepted then span := proposedSpan else set saved
    if span == 1 then
      Parametric.Driver.emit s!"host_source_step {fText}, {source} using {server cursor} to {state (cursor+1)} using {server (cursor+1)} as {blockText}"
    unless (← getEnv).contains (block ++ `retained_transport) do
      throwError "host_source_plan: no checked retained rule was generated at source index {cursor}"
    if (← get).messages.hasErrors then
      throwError "host_source_plan: source rule failed at index {cursor}"
    rules := rules ++ [block ++ `retained_transport]
    spans := spans ++ [span]
    starts := starts ++ [cursor]
    cursor := cursor+span
  liftTermElabM do
    Parametric.Driver.addData (pre ++ `rules) (toExpr rules)
    Parametric.Driver.addData (pre ++ `spans) (toExpr spans)
    Parametric.Driver.addData (pre ++ `starts) (toExpr starts)
    Parametric.Driver.addData (pre ++ `sourceSteps) (mkNatLit count)
    Parametric.Driver.addData (pre ++ `blockCount) (mkNatLit rules.length)
  let n := "_root_." ++ pre.toString
  Parametric.Driver.emit s!"theorem {n}.span_total : {n}.spans.sum = {n}.sourceSteps := by decide +kernel"

elab "host_source_plan " f:term ", " base:ident " from " start:num " plan_steps " count:num " as " name:ident : command =>
  generatePlan f base start count name none

/-- Reuse the same actual source states with substituted number servers.
Each selected frontend still checks both original source endpoints. -/
elab "host_source_plan_subst " f:term ", " base:ident " from " start:num " plan_steps " count:num
    " substitute " replacement:term " as " name:ident : command =>
  generatePlan f base start count name (some replacement)

/-- Plan a checked, field-shared source region with consecutive local aliases.
The selected rules and span checks are the same as the retained-cut planner. -/
elab "host_source_linear_plan_subst " f:term ", " base:ident " from " start:num " plan_steps " count:num
    " substitute " replacement:term " as " name:ident : command =>
  generatePlan f base start count name (some replacement) true

private partial def plannedName (expression : Lean.Expr) : MetaM Lean.Name := do
  let expression ← whnf expression
  if expression.isConstOf ``Lean.Name.anonymous then return .anonymous
  if expression.isAppOfArity ``Lean.Name.str 2 then
    let parent ← plannedName expression.getAppArgs[0]!
    let some segment := getStringValue? (← whnf expression.getAppArgs[1]!) | throwError "source plan: invalid name segment"
    return .str parent segment
  if expression.isAppOfArity ``Lean.Name.num 2 then
    let parent ← plannedName expression.getAppArgs[0]!
    let some index ← getNatValue? expression.getAppArgs[1]! | throwError "source plan: invalid name index"
    return .num parent index
  throwError "source plan: rules must be a concrete list of declaration names"

private partial def plannedRules (expression : Lean.Expr) : MetaM (Array Syntax) := do
  let expression ← whnf expression
  if expression.isAppOfArity ``List.nil 1 then return #[]
  unless expression.isAppOfArity ``List.cons 3 do throwError "source plan: malformed rule list"
  let name ← plannedName expression.getAppArgs[1]!
  return #[mkIdent name] ++ (← plannedRules expression.getAppArgs[2]!)

/-- Consume checked planned rules through the existing retained chain. The
recorded names select proofs; the chain checks every reached state, number
server, inventory and span before exporting its connected result. -/
elab "host_retained_plan_chain " f:term ", " plan:ident " using " h:term ", " inventory:term ", " inst:term : tactic => do
  let rulesName ← realizeGlobalConstNoOverloadWithInfo (mkIdent (plan.getId ++ `rules))
  let rules ← liftMetaM <| plannedRules (mkConst rulesName)
  let rules := rules.map fun item => (⟨item⟩ : TSyntax `term)
  Elab.Tactic.evalTactic (← `(tactic| host_retained_chain $f, [$[$rules],*] using $h, $inventory, $inst))

elab "host_retained_plan_chain_after " f:term ", " plan:ident " using " h:term ", " inventory:term ", " inst:term
    " continuing_run " run:term " initial_relation " entry:term : tactic => do
  let rulesName ← realizeGlobalConstNoOverloadWithInfo (mkIdent (plan.getId ++ `rules))
  let rules ← liftMetaM <| plannedRules (mkConst rulesName)
  let rules := rules.map fun item => (⟨item⟩ : TSyntax `term)
  Elab.Tactic.evalTactic (← `(tactic| host_retained_chain_after $f, [$[$rules],*] using $h, $inventory, $inst continuing_run $run initial_relation $entry))

end Host.Ts.Owned.Annotated.Driver

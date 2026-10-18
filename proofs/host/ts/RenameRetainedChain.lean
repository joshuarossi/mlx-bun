import host.ts.RenameRetainedChainFacts
import host.ts.RenameRouteComposition
import Lean.Elab.Tactic
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Meta Tactic

private def sameType (left right : Lean.Expr) : MetaM Bool :=
  isDefEq left right

private partial def proveFromContext (type : Lean.Expr) (fuel : Nat := 8) : MetaM (Option Lean.Expr) := do
  if fuel == 0 then return none
  let type ← instantiateMVars type
  if type.isAppOfArity ``Eq 3 then
    let saved ← saveState
    if ← sameType type.getAppArgs[1]! type.getAppArgs[2]! then
      return some (← mkEqRefl (← instantiateMVars type.getAppArgs[1]!))
    saved.restore
  for declaration in (← getLCtx) do
    unless declaration.isImplementationDetail do
      let saved ← saveState
      if ← sameType declaration.type type then return some declaration.toExpr
      saved.restore
  let reduced ← withReducible (whnf type)
  if reduced.isAppOfArity ``Or 2 then
    if let some proof ← proveFromContext reduced.getAppArgs[0]! (fuel-1) then
      return some (← mkAppM ``Or.inl #[proof])
    if let some proof ← proveFromContext reduced.getAppArgs[1]! (fuel-1) then
      return some (← mkAppM ``Or.inr #[proof])
  if reduced.isConstOf ``True then return some (mkConst ``True.intro)
  return none

private def guardFromEntry (initial current type : Lean.Expr) : MetaM (Option Lean.Expr) := do
  let initialArgs := (← inferType initial).getAppArgs
  let currentArgs := (← inferType current).getAppArgs
  let firstSource := initialArgs[initialArgs.size-2]!
  let currentSource := currentArgs[currentArgs.size-2]!
  let firstNext ← mkAppM ``St.next #[firstSource]
  let some firstValue ← getNatValue? (← whnf firstNext) | return none
  if type.isAppOfArity ``Not 1 then
    let predicate := type.getAppArgs[0]!
    if predicate.getAppArgs.size == 1 then
      let address := predicate.getAppArgs[0]!
      if let some a ← getNatValue? (← whnf address) then
        if firstValue ≤ a then
          let proof ← mkAppM ``chain_not_framed_fresh #[initial,address,← mkDecideProof (← mkLe firstNext address)]
          if ← sameType (← inferType proof) type then return some proof
    return none
  let args := type.getAppArgs
  let (lhs,limit,strict) ← if type.isAppOfArity ``LT.lt 4 then pure (args[2]!,args[3]!,true)
    else if type.isAppOfArity ``Nat.lt 2 then pure (args[0]!,args[1]!,true)
    else if type.isAppOfArity ``LE.le 4 then pure (args[2]!,args[3]!,false)
    else if type.isAppOfArity ``Nat.le 2 then pure (args[0]!,args[1]!,false) else return none
  let currentTarget := currentArgs.back!
  let targetNext ← mkAppM ``St.next #[currentTarget]
  let required ← if ← sameType lhs targetNext then pure (mkNatLit 0)
    else if strict then return none
    else
      let required ← mkFreshExprMVar (mkConst ``Nat)
      unless ← sameType lhs (← mkAppM ``Nat.add #[targetNext,required]) do return none
      instantiateMVars required
  let some requiredValue ← getNatValue? (← whnf required) | return none
  let some currentValue ← getNatValue? (← whnf (← mkAppM ``St.next #[currentSource])) | return none
  if currentValue < firstValue then return none
  let offset := mkNatLit (currentValue-firstValue)
  let allowance ← mkFreshExprMVar (mkConst ``Nat)
  let budgetType ← mkLe (← mkAppM ``Nat.add #[← mkAppM ``St.next #[initialArgs.back!],allowance]) limit
  let some budget ← proveFromContext budgetType | return none
  let allowance ← instantiateMVars allowance
  let some allowanceValue ← getNatValue? (← whnf allowance) | return none
  let sourceRhs ← mkAppM ``Nat.add #[firstNext,offset]
  let proof ← if strict then
      if currentValue-firstValue < allowanceValue then
        mkAppM ``chain_next_budget #[initial,current,offset,allowance,limit,← mkEqRefl sourceRhs,
          ← mkDecideProof (← mkLt offset allowance),budget]
      else return none
    else
      if currentValue-firstValue+requiredValue ≤ allowanceValue then
        mkAppM ``chain_next_budget_le #[initial,current,offset,required,allowance,limit,← mkEqRefl sourceRhs,
          ← mkDecideProof (← mkLe (← mkAppM ``Nat.add #[offset,required]) allowance),budget]
      else return none
  if ← sameType (← inferType proof) type then return some proof
  return none

private partial def expose (goal : MVarId) (proof : Lean.Expr) : MetaM (MVarId × Array Lean.Expr) :=
  goal.withContext do
    let original ← inferType proof
    let type ← if original.getAppFn.isConstOf ``Inst then pure original else withReducible (whnf original)
    if type.isAppOfArity ``Exists 2 then
      let (field,goal) ← goal.note (← mkFreshUserName `transition) proof
      goal.withContext do
        expose goal (← mkAppM ``Classical.choose_spec #[mkFVar field])
    else if type.isAppOfArity ``And 2 then
      let left ← expose goal (← mkAppM ``And.left #[proof])
      left.1.withContext do
        let right ← expose left.1 (← mkAppM ``And.right #[proof])
        return (right.1,left.2 ++ right.2)
    else
      let (field,goal) ← goal.note (← mkFreshUserName `fact) proof
      return (goal,#[mkFVar field])

private def factNamed (facts : Array Lean.Expr) (name : Lean.Name) : MetaM Lean.Expr := do
  for proof in facts do
    if (← inferType proof).getAppFn.isConstOf name then return proof
  throwError "host_retained_chain: transition did not retain {name}; derived types: {MessageData.joinSep (← facts.toList.mapM fun fact => return MessageData.ofExpr (← inferType fact)) m!"\n"}"

private def factOfType (facts : Array Lean.Expr) (type : Lean.Expr) : MetaM Lean.Expr := do
  for proof in facts do
    let saved ← saveState
    let candidate ← inferType proof
    if ← withReducible (isDefEq candidate type) then return proof
    saved.restore
    if candidate.getAppFn == type.getAppFn &&
        (type.getAppFn.isConstOf ``RetainedInventory || type.getAppFn.isConstOf ``Parametric.StateR || type.getAppFn.isConstOf ``Inst) then
      if ← sameType candidate type then return proof
      saved.restore
    if candidate.isAppOfArity ``Eq 3 && type.isAppOfArity ``Eq 3 then
      let left := candidate.getAppArgs[1]!
      let right := type.getAppArgs[1]!
      if left.getAppFn == right.getAppFn then
        let comparable ← if left.getAppFn.isConstOf ``interpC then
            withReducible (isDefEq left.getAppArgs.back! right.getAppArgs.back!)
          else if left.getAppFn.isConstOf ``runC then pure true
          else pure false
        if comparable then
          if ← sameType candidate type then return proof
          saved.restore
  throwError "host_retained_chain: missing derived fact {type}"

private partial def normalStack (stack : Lean.Expr) : MetaM Lean.Expr := do
  let stack ← whnf stack
  if stack.isAppOfArity ``List.cons 3 then
    mkAppM ``List.cons #[← whnf stack.getAppArgs[1]!,← normalStack stack.getAppArgs[2]!]
  else pure stack

private def normalNotes (notes : Lean.Expr) : MetaM Lean.Expr := do
  let runtime ← mkAppM ``RetainedNotes.runtime #[notes]
  let runtime ← mkAppM ``RuntimeNotes.mk #[
    ← whnf (← mkAppM ``RuntimeNotes.control #[runtime]),
    ← normalStack (← mkAppM ``RuntimeNotes.stack #[runtime]),
    ← whnf (← mkAppM ``RuntimeNotes.cells #[runtime])]
  mkAppM ``RetainedNotes.mk #[runtime,
    ← whnf (← mkAppM ``RetainedNotes.privates #[notes]),
    ← whnf (← mkAppM ``RetainedNotes.captures #[notes]),
    ← whnf (← mkAppM ``RetainedNotes.arrays #[notes]),
    ← whnf (← mkAppM ``RetainedNotes.publicFields #[notes]),
    ← whnf (← mkAppM ``RetainedNotes.buffers #[notes])]

private def instantiateRule (rule initial state inventory inst : Lean.Expr) : MetaM Lean.Expr := do
  let (arguments,_,_) ← forallMetaTelescope (← inferType rule)
  for argument in arguments do
    let type ← inferType argument
    let value := if type.getAppFn.isConstOf ``Parametric.StateR then some state
      else if type.getAppFn.isConstOf ``RetainedInventory then some inventory
      else if type.getAppFn.isConstOf ``Inst then some inst else none
    if let some value := value then
      unless ← sameType type (← inferType value) do
        throwError "host_retained_chain: current invariant {(← inferType value)} does not match source rule {type}"
      argument.mvarId!.assign value
  -- Data roles are determined by the retained-note equalities. No source or
  -- target numeric bits are inspected to choose a meaning.
  for _ in [:3] do
    for argument in arguments do
      if !(← argument.mvarId!.isAssigned) && (← isProp (← inferType argument)) then
        let type ← inferType argument
        if let some proof ← proveFromContext type then argument.mvarId!.assign proof
        else
          let saved ← saveState
          if let some proof ← guardFromEntry initial state type then argument.mvarId!.assign proof
          else saved.restore
  let result ← instantiateMVars (mkAppN rule arguments)
  if result.hasMVar then
    let mut missing := #[]
    for argument in arguments do
      if !(← argument.mvarId!.isAssigned) then missing := missing.push (← argument.mvarId!.getDecl).userName
    throwError "host_retained_chain: initial annotations or guards do not establish rule premises for {rule}: {missing}"
  return result

private partial def closeFromFacts (goalType : Lean.Expr) (facts : Array Lean.Expr) : MetaM Lean.Expr := do
  let saved ← saveState
  try
    return ← factOfType facts goalType
  catch _ => saved.restore
  let goalType ← whnf goalType
  if goalType.isAppOfArity ``Exists 2 then
    let witness ← mkFreshExprMVar goalType.getAppArgs[0]!
    let body ← closeFromFacts (mkApp goalType.getAppArgs[1]! witness) facts
    mkAppOptM ``Exists.intro #[some goalType.getAppArgs[0]!,some goalType.getAppArgs[1]!,some witness,some body]
  else if goalType.isAppOfArity ``And 2 then
    mkAppM ``And.intro #[← closeFromFacts goalType.getAppArgs[0]! facts,← closeFromFacts goalType.getAppArgs[1]! facts]
  else factOfType facts goalType

/-- Compose checked retained source rules in one proof. Each rule is applied
only to the preceding result and its retained annotations. Unavailable initial
notes or symbolic guards are rejected instead of becoming new assumptions. -/
elab "host_retained_chain " f:term ", " "[" rules:term,* "]" " using " initialState:term ", " initialInventory:term ", " initialInst:term : tactic => do
  let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
  let rules ← rules.getElems.mapM fun rule => Term.elabTerm rule none
  let mut state ← Term.elabTerm initialState none
  let entryState := state
  let mut inventory ← Term.elabTerm initialInventory none
  let mut inst ← Term.elabTerm initialInst none
  let mut goal ← getMainGoal
  let mut accumulated : Option Lean.Expr := none
  let mut finalFacts := #[]
  for rule in rules do
    trace[Elab.debug] "retained chain applying {rule}"
    goal ← goal.withContext do
      let source := (← inferType inventory).getAppArgs[8]!
      let stack ← whnf (← mkAppM ``St.stack #[source])
      if stack.isAppOfArity ``List.cons 3 then
        let runtime ← mkAppM ``RetainedInventory.runtime #[inventory]
        let view ← mkAppM ``RuntimeInventory.stack_cons #[runtime,stack.getAppArgs[1]!,stack.getAppArgs[2]!,← mkEqRefl stack]
        return (← goal.note (← mkFreshUserName `stackNotes) view).2
      else return goal
    let (nextGoal,nextState,nextInventory,nextInst,run,facts) ← goal.withContext do
      let currentArgs := (← inferType inventory).getAppArgs
      let source := currentArgs[8]!
      let target := currentArgs[9]!
      let server := currentArgs[5]!
      let proof ← instantiateRule rule entryState state inventory inst
      let (nextGoal,facts) ← expose goal proof
      nextGoal.withContext do
        let nextState ← factNamed facts ``Parametric.StateR
        let nextInventory ← factNamed facts ``RetainedInventory
        let nextArgs := (← inferType nextInventory).getAppArgs
        let nextServerName := rule.constName!.getPrefix ++ `nextServer
        unless (← getEnv).contains nextServerName do
          throwError "host_retained_chain: source rule has no checked next server {nextServerName}"
        let nextInstType ← mkAppM ``Inst #[nextArgs[2]!,mkConst nextServerName,nextArgs[4]!]
        let nextInstProof ← closeFromFacts nextInstType facts
        let nextTarget := nextArgs[9]!
        let nextServer := nextArgs[5]!
        let stepRun ← mkAppM ``interpC #[← mkAppM ``M.run #[← mkAppM ``step #[f,target]],server]
        let expected ← mkEq stepRun (← mkAppM ``Option.some #[← mkAppM ``Prod.mk #[nextTarget,nextServer]])
        let targetRun ← factOfType facts expected
        let control ← mkAppM ``Parametric.StateR.control #[state]
        let haltEqual ← mkAppM ``Parametric.ControlR.isHalt_eq #[control]
        let closedHalt ← mkEqRefl (mkConst ``Bool.false)
        let sourceHalt ← mkAppM ``isHalt #[← mkAppM ``St.ctl #[source]]
        unless ← sameType sourceHalt (mkConst ``Bool.false) do
          throwError "host_retained_chain: source step is already halted"
        let notHalt ← mkAppM ``Eq.trans #[haltEqual,closedHalt]
        let zero ← mkEqRefl (← mkAppM ``Option.some #[← mkAppM ``Prod.mk #[nextTarget,nextServer]])
        let one ← mkAppM ``Parametric.runC_cons #[f,mkNatLit 0,target,nextTarget,nextTarget,server,nextServer,nextServer,notHalt,targetRun,zero]
        let run ← match accumulated with
          | none => pure one
          | some previous => mkAppM ``Parametric.runC_join #[f,previous,one]
        let (instName,nextGoal) ← nextGoal.note (← mkFreshUserName `inst) nextInstProof (some nextInstType)
        let nextInst := mkFVar instName
        nextGoal.withContext do
          let normalized ← normalNotes nextArgs[1]!
          let definition ← nextGoal.define (← mkFreshUserName `notes) (mkConst ``RetainedNotes) normalized
          let (noteName,nextGoal) ← definition.intro1P
          let inventoryType := mkAppN (← inferType nextInventory).getAppFn (nextArgs.set! 1 (mkFVar noteName))
          let (inventoryName,nextGoal) ← nextGoal.note (← mkFreshUserName `inventory) nextInventory (some inventoryType)
          let nextInventory := mkFVar inventoryName
          return (nextGoal,nextState,nextInventory,nextInst,run,(facts.push nextInst).push nextInventory)
    goal := nextGoal
    state := nextState
    inventory := nextInventory
    inst := nextInst
    accumulated := some run
    finalFacts := facts
  let some run := accumulated | throwError "host_retained_chain: expected at least one source rule"
  goal.withContext do
    let expected ← goal.getType
    if expected.isMVar then
      let target := (← inferType inventory).getAppArgs.back!
      let bodyFacts := #[run,state,inventory,inst]
      let conclusion ← withLocalDeclD `result (← inferType target) fun result => do
        let types ← bodyFacts.mapM fun proof => do
          let type ← inferType proof
          pure (type.replace fun expression => if expression == target then some result else none)
        let mut body := types.back!
        for type in types.toList.dropLast.reverse do body ← mkAppM ``And #[type,body]
        mkAppM ``Exists #[← mkLambdaFVars #[result] body]
      let conclusion ← zetaReduce conclusion
      unless ← isDefEq expected conclusion do
        throwError "host_retained_chain: computed endpoint depends on an unavailable local annotation"
    let proof ← closeFromFacts (← goal.getType) (finalFacts.push run)
    let proof ← instantiateMVars proof
    unless !proof.hasMVar do throwError "host_retained_chain: output witnesses were not determined by reached notes"
    goal.assign proof
  replaceMainGoal []

/-- Infer the explicit reached annotation type from a connected proof, then
submit it as an ordinary theorem. The result must be a closed proposition. -/
elab "host_retained_theorem " name:ident " := " proof:term : command => do
  let name := (← getCurrNamespace) ++ name.getId
  Elab.Command.liftTermElabM do
    let proof ← Term.elabTerm proof none
    Term.synthesizeSyntheticMVarsNoPostponing
    let proof ← instantiateMVars proof
    let type ← instantiateMVars (← inferType proof)
    unless !proof.hasFVar && !proof.hasMVar && !type.hasFVar && !type.hasMVar && (← isProp type) do
      throwError "host_retained_theorem: expected a closed proof with an explicit proposition type"
    addDecl (.thmDecl {name,levelParams := [],type,value := proof})

end Host.Ts.Owned.Annotated.Driver

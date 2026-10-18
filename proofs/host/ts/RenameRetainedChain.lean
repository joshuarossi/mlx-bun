import host.ts.RenameRetainedChainFacts
import host.ts.RenameRouteComposition
import host.ts.RenameParametricMapControl
import Lean.Elab.Tactic
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Meta Tactic

private def proofType (proof : Lean.Expr) : MetaM Lean.Expr := do
  return (← instantiateMVars (← inferType proof)).consumeMData.headBeta.consumeMData

private def sameType (left right : Lean.Expr) : MetaM Bool :=
  isDefEq left right

private partial def proveFromContext (type : Lean.Expr) (fuel : Nat := 64) : MetaM (Option Lean.Expr) := do
  if fuel == 0 then return none
  let type := (← instantiateMVars type).consumeMData.headBeta.consumeMData
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
  let args := type.getAppArgs
  if type.isAppOfArity ``Parametric.LiveAfter 3 then
    let left := mkApp args[0]! args[2]!
    if let some proof ← proveFromContext left (fuel-1) then
      return some (← mkAppOptM ``Or.inl #[some left,some (← mkEq args[2]! args[1]!),some proof])
  else if type.isAppOfArity ``Parametric.CellsLive 4 then
    if let some proof ← proveFromContext (mkApp args[0]! args[3]!) (fuel-1) then
      return some (← mkAppM ``Parametric.CellsLive.grow #[args[0]!,args[1]!,args[2]!,args[3]!,proof])
  else if type.isAppOfArity ``Parametric.ClosureLive 6 then
    if let some proof ← proveFromContext (mkApp args[0]! args[5]!) (fuel-1) then
      return some (← mkAppM ``Parametric.ClosureLive.grow #[args[0]!,args[1]!,args[2]!,args[3]!,args[4]!,args[5]!,proof])
  let reduced ← withReducible (whnf type)
  let reduced ← if reduced == type && type.getAppFn.isConst then do
      let expanded ← whnf type
      if expanded.isAppOfArity ``Or 2 || expanded.isAppOfArity ``Parametric.LiveAfter 3 ||
          expanded.isAppOfArity ``Parametric.CellsLive 4 || expanded.isAppOfArity ``Parametric.ClosureLive 6 then
        pure expanded
      else pure reduced
    else pure reduced
  if reduced != type && (reduced.isAppOfArity ``Parametric.LiveAfter 3 ||
      reduced.isAppOfArity ``Parametric.CellsLive 4 || reduced.isAppOfArity ``Parametric.ClosureLive 6) then
    return ← proveFromContext reduced (fuel-1)
  if reduced.isAppOfArity ``Or 2 then
    if let some proof ← proveFromContext reduced.getAppArgs[0]! (fuel-1) then
      return some (← mkAppOptM ``Or.inl #[some reduced.getAppArgs[0]!,some reduced.getAppArgs[1]!,some proof])
    if let some proof ← proveFromContext reduced.getAppArgs[1]! (fuel-1) then
      return some (← mkAppOptM ``Or.inr #[some reduced.getAppArgs[0]!,some reduced.getAppArgs[1]!,some proof])
  if reduced.isConstOf ``True then return some (mkConst ``True.intro)
  return none

private partial def constantOffset (expression base : Lean.Expr) (fuel : Nat := 16) : MetaM (Option Nat) := do
  if fuel == 0 then return none
  let saved ← saveState
  if ← sameType expression base then return some 0
  saved.restore
  let expression ← instantiateMVars expression
  let args := expression.getAppArgs
  if expression.getAppFn.isConstOf ``Nat.add || expression.getAppFn.isConstOf ``HAdd.hAdd then
    if args.size ≥ 2 then
      if let some right ← getNatValue? (← whnf args.back!) then
        if let some left ← constantOffset args[args.size-2]! base (fuel-1) then
          return some (left+right)
  let expression ← whnf expression
  if expression.isAppOfArity ``Nat.succ 1 then
    if let some rest ← constantOffset expression.getAppArgs[0]! base (fuel-1) then return some (rest+1)
  return none

private def guardFromEntry (initial current type : Lean.Expr) : MetaM (Option Lean.Expr) := do
  let initialArgs := (← proofType initial).getAppArgs
  let currentArgs := (← proofType current).getAppArgs
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
          if ← sameType (← proofType proof) type then return some proof
    return none
  let args := type.getAppArgs
  let (lhs,limit,strict) ← if type.isAppOfArity ``LT.lt 4 then pure (args[2]!,args[3]!,true)
    else if type.isAppOfArity ``Nat.lt 2 then pure (args[0]!,args[1]!,true)
    else if type.isAppOfArity ``LE.le 4 then pure (args[2]!,args[3]!,false)
    else if type.isAppOfArity ``Nat.le 2 then pure (args[0]!,args[1]!,false) else return none
  let currentTarget := currentArgs.back!
  let targetNext ← mkAppM ``St.next #[currentTarget]
  let some requiredValue ← constantOffset lhs targetNext | return none
  if strict && requiredValue != 0 then return none
  let required := mkNatLit requiredValue
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
  if ← sameType (← proofType proof) type then return some proof
  return none

private partial def expose (goal : MVarId) (proof : Lean.Expr) : MetaM (MVarId × Array Lean.Expr) :=
  goal.withContext do
    let original ← proofType proof
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
    if (← proofType proof).getAppFn.isConstOf name then return proof
  throwError "host_retained_chain: transition did not retain {name}; derived types: {MessageData.joinSep (← facts.toList.mapM fun fact => return MessageData.ofExpr (← proofType fact)) m!"\n"}"

private def factOfType (facts : Array Lean.Expr) (type : Lean.Expr) : MetaM Lean.Expr := do
  for proof in facts do
    let saved ← saveState
    let candidate ← proofType proof
    if type.isAppOfArity ``Eq 3 && candidate.isAppOfArity ``Eq 3 then
      let wanted := type.getAppArgs[1]!.consumeMData
      let found := candidate.getAppArgs[1]!.consumeMData
      if wanted.isAppOfArity ``runC 4 && found.isAppOfArity ``runC 4 then
        unless (← sameType found.getAppArgs[2]! wanted.getAppArgs[2]!) &&
            (← sameType found.getAppArgs[3]! wanted.getAppArgs[3]!) do
          saved.restore
          continue
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

private def blockRunOfType (facts : Array Lean.Expr) (type target server : Lean.Expr) : MetaM Lean.Expr := do
  -- Compare state/server arguments before asking conversion to inspect a run.
  -- An unrelated closed source run must not be unfolded against the target.
  for proof in facts do
    let candidate ← proofType proof
    if candidate.isAppOfArity ``Eq 3 then
      let lhs := candidate.getAppArgs[1]!.consumeMData
      if lhs.isAppOfArity ``runC 4 then
        let saved ← saveState
        if (← sameType lhs.getAppArgs[2]! target) && (← sameType lhs.getAppArgs[3]! server) then
          if ← sameType candidate type then return proof
        saved.restore
  throwError "host_retained_chain: missing checked block run {type}"

private partial def normalStack (stack : Lean.Expr) : MetaM Lean.Expr := do
  let stack ← whnf stack
  if stack.isAppOfArity ``List.cons 3 then
    mkAppM ``List.cons #[← whnf stack.getAppArgs[1]!,← normalStack stack.getAppArgs[2]!]
  else pure stack

private def compactNotes (notes : Lean.Expr) : MetaM Lean.Expr := do
  let selectors := #[``RetainedNotes.runtime,``RetainedNotes.privates,``RetainedNotes.captures,
    ``RetainedNotes.arrays,``RetainedNotes.publicFields,``RetainedNotes.buffers,
    ``RuntimeNotes.control,``RuntimeNotes.stack,``RuntimeNotes.cells,``Notes.cells,
    ``PrivateNotes.owners,``NativeCaptureNotes.owners,``ArrayNotes.owners,``PublicNotes.fields,``BufferNotes.owners]
  let structures := #[``RetainedNotes,``RuntimeNotes,``Notes,``PrivateNotes,``NativeCaptureNotes,
    ``ArrayNotes,``PublicNotes,``BufferNotes]
  Meta.transform notes (pre := fun expression => do
    let selected := match expression with
      | .proj name _ _ => structures.contains name
      | _ => match expression.getAppFn with
        | .const name _ => selectors.contains name
        | _ => false
    if selected then
      let reduced ← whnf expression
      if reduced != expression then return .visit reduced
    return .continue) (skipConstInApp := true)

private def normalNotes (notes : Lean.Expr) : MetaM Lean.Expr := do
  let runtime ← mkAppM ``RetainedNotes.runtime #[notes]
  let runtime ← mkAppM ``RuntimeNotes.mk #[
    ← whnf (← mkAppM ``RuntimeNotes.control #[runtime]),
    ← normalStack (← mkAppM ``RuntimeNotes.stack #[runtime]),
    ← whnf (← mkAppM ``RuntimeNotes.cells #[runtime])]
  compactNotes (← mkAppM ``RetainedNotes.mk #[runtime,
    ← whnf (← mkAppM ``RetainedNotes.privates #[notes]),
    ← whnf (← mkAppM ``RetainedNotes.captures #[notes]),
    ← whnf (← mkAppM ``RetainedNotes.arrays #[notes]),
    ← whnf (← mkAppM ``RetainedNotes.publicFields #[notes]),
    ← whnf (← mkAppM ``RetainedNotes.buffers #[notes])])

private def instantiateRule (rule initial state inventory inst : Lean.Expr) : MetaM Lean.Expr := do
  let (arguments,_,_) ← forallMetaTelescope (← proofType rule)
  for argument in arguments do
    let type ← proofType argument
    let value := if type.getAppFn.isConstOf ``Parametric.StateR then some state
      else if type.getAppFn.isConstOf ``RetainedInventory then some inventory
      else if type.getAppFn.isConstOf ``Inst then some inst else none
    if let some value := value then
      unless ← sameType type (← proofType value) do
        throwError "host_retained_chain: current invariant {(← proofType value)} does not match source rule {type}"
      argument.mvarId!.assign value
  -- Data roles are determined by the retained-note equalities. No source or
  -- target numeric bits are inspected to choose a meaning.
  for _ in [:3] do
    for argument in arguments do
      if !(← argument.mvarId!.isAssigned) && (← isProp (← proofType argument)) then
        let type ← proofType argument
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
private def chain (f : TSyntax `term) (rules : Array (TSyntax `term))
    (initialState initialInventory initialInst : TSyntax `term)
    (previousRun entryRelation : Option (TSyntax `term)) : TacticM Unit := do
  let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
  let rules ← rules.mapM fun rule => Term.elabTerm rule none
  let mut state ← Term.elabTerm initialState none
  let entryState ← match entryRelation with
    | some relation => Term.elabTerm relation none
    | none => pure state
  let mut inventory ← Term.elabTerm initialInventory none
  let mut inst ← Term.elabTerm initialInst none
  unless (← proofType state).getAppFn.isConstOf ``Parametric.StateR &&
      (← proofType entryState).getAppFn.isConstOf ``Parametric.StateR &&
      (← proofType inventory).getAppFn.isConstOf ``RetainedInventory do
    throwError "host_retained_chain: expected the current StateR and RetainedInventory proofs; found {(← proofType state).getAppFn}, {(← proofType entryState).getAppFn}, {(← proofType inventory).getAppFn}"
  let entryLive := (← proofType entryState).getAppArgs[4]!
  let mut retainedAddresses : Array Lean.Expr := #[]
  for declaration in (← getLCtx) do
    unless declaration.isImplementationDetail do
      let type := declaration.type.consumeMData.headBeta.consumeMData
      if type.isApp then
        let address := type.getAppArgs.back!
        if (← proofType address).isConstOf ``Nat then
          let saved ← saveState
          if ← sameType type (mkApp entryLive address) then retainedAddresses := retainedAddresses.push address
          saved.restore
  let mut goal ← getMainGoal
  let mut accumulated ← previousRun.mapM fun run => Term.elabTerm run none
  let mut finalFacts := #[]
  for rule in rules do
    unless rule.isConst do throwError "host_retained_chain: expected a named source rule"
    trace[Elab.debug] "retained chain applying {rule}"
    goal ← goal.withContext do
      let mut currentGoal := goal
      let live := (← proofType inventory).getAppArgs[7]!
      for address in retainedAddresses do
        currentGoal ← currentGoal.withContext do
          let type := mkApp live address
          let some proof ← proveFromContext type | throwError "host_retained_chain: allocation failed to retain initial live resource {address} at {rule}; expected {type}"
          return (← currentGoal.note (← mkFreshUserName `resourceLive) proof (some type)).2
      let source := (← proofType inventory).getAppArgs[8]!
      let stack ← whnf (← mkAppM ``St.stack #[source])
      if stack.isAppOfArity ``List.cons 3 then
        let runtime ← mkAppM ``RetainedInventory.runtime #[inventory]
        let view ← mkAppM ``RuntimeInventory.stack_cons #[runtime,stack.getAppArgs[1]!,stack.getAppArgs[2]!,← mkEqRefl stack]
        return (← currentGoal.note (← mkFreshUserName `stackNotes) view).2
      else return currentGoal
    let (nextGoal,nextState,nextInventory,nextInst,run,facts) ← goal.withContext do
      let currentArgs := (← proofType inventory).getAppArgs
      let source := currentArgs[8]!
      let target := currentArgs[9]!
      let server := currentArgs[5]!
      let proof ← instantiateRule rule entryState state inventory inst
      let (nextGoal,facts) ← expose goal proof
      nextGoal.withContext do
        let nextState ← factNamed facts ``Parametric.StateR
        let nextInventory ← factNamed facts ``RetainedInventory
        let nextArgs := (← proofType nextInventory).getAppArgs
        let nextServerName := rule.constName!.getPrefix ++ `nextServer
        unless (← getEnv).contains nextServerName do
          throwError "host_retained_chain: source rule has no checked next server {nextServerName}"
        let nextInstType ← mkAppM ``Inst #[nextArgs[2]!,mkConst nextServerName,nextArgs[4]!]
        let nextInstProof ← closeFromFacts nextInstType facts
        let nextTarget := nextArgs[9]!
        let nextServer := nextArgs[5]!
        let spanName := rule.constName!.getPrefix ++ `span
        let one ← if (← getEnv).contains spanName then do
            let span := mkConst spanName
            unless (← inferType span).isConstOf ``Nat do
              throwError "host_retained_chain: block span must be a natural number"
            let blockRun ← mkAppM ``runC #[f,span,target,server]
            let expected ← mkEq blockRun (← mkAppM ``Option.some #[← mkAppM ``Prod.mk #[nextTarget,nextServer]])
            blockRunOfType facts expected target server
          else do
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
            mkAppM ``Parametric.runC_cons #[f,mkNatLit 0,target,nextTarget,nextTarget,server,nextServer,nextServer,notHalt,targetRun,zero]
        let run ← match accumulated with
          | none => pure one
          | some previous => mkAppM ``Parametric.runC_join #[f,previous,one]
        let (instName,nextGoal) ← nextGoal.note (← mkFreshUserName `inst) nextInstProof (some nextInstType)
        let nextInst := mkFVar instName
        nextGoal.withContext do
          let normalized ← normalNotes nextArgs[1]!
          let definition ← nextGoal.define (← mkFreshUserName `notes) (mkConst ``RetainedNotes) normalized
          let (noteName,nextGoal) ← definition.intro1P
          let inventoryType := mkAppN (← proofType nextInventory).getAppFn (nextArgs.set! 1 (mkFVar noteName))
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
    let expected := (← instantiateMVars (← goal.getType)).consumeMData
    if expected.getAppFn.isMVar then
      let target := (← proofType inventory).getAppArgs.back!
      let bodyFacts := #[run,state,inventory,inst]
      let conclusion ← withLocalDeclD `result (← proofType target) fun result => do
        let types ← bodyFacts.mapM fun proof => do
          let type ← proofType proof
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

elab "host_retained_chain " f:term ", " "[" rules:term,* "]" " using " initialState:term ", " initialInventory:term ", " initialInst:term : tactic =>
  withMainContext do chain f rules.getElems initialState initialInventory initialInst none none

/-- Continue a checked chunk, joining its existing run and retaining the
original entry relation for a single allocation budget. -/
elab "host_retained_chain_after " f:term ", " "[" rules:term,* "]" " using " initialState:term ", " initialInventory:term ", " initialInst:term
    " continuing_run " previousRun:term " initial_relation " entryRelation:term : tactic =>
  withMainContext do chain f rules.getElems initialState initialInventory initialInst (some previousRun) (some entryRelation)

private partial def schemaLeaves (type : Lean.Expr) : MetaM (Array Lean.Expr) := do
  if type.getAppFn.isConstOf ``Inst then return #[type]
  let type ← whnf type
  if type.isAppOfArity ``And 2 then
    return (← schemaLeaves type.getAppArgs[0]!) ++ (← schemaLeaves type.getAppArgs[1]!)
  return #[type]

private def assertSchema (type : Lean.Expr) (steps : Option Nat := none) : MetaM Unit :=
  forallTelescopeReducing type fun _ conclusion => do
    let conclusion ← whnf conclusion
    unless conclusion.isAppOfArity ``Exists 2 do
      throwError "retained batch schema: expected an existential reached state and the full retained bundle"
    let domain ← whnf conclusion.getAppArgs[0]!
    unless domain.getAppFn.isConstOf ``St do
      throwError "retained batch schema: reached witness must be an interpreter state"
    withLocalDeclD `result conclusion.getAppArgs[0]! fun result => do
      let fields ← schemaLeaves (mkApp conclusion.getAppArgs[1]! result)
      let some state := fields.find? (fun field => field.getAppFn.isConstOf ``Parametric.StateR)
        | throwError "retained batch schema: missing StateR"
      let some inventory := fields.find? (fun field => field.getAppFn.isConstOf ``RetainedInventory)
        | throwError "retained batch schema: missing RetainedInventory"
      let some inst := fields.find? (fun field => field.getAppFn.isConstOf ``Inst)
        | throwError "retained batch schema: missing source numeric-server Inst"
      let some run := fields.find? (fun field => field.isAppOfArity ``Eq 3 && field.getAppArgs[1]!.getAppFn.isConstOf ``runC)
        | throwError "retained batch schema: missing target runC"
      let runArgs := run.getAppArgs[1]!.getAppArgs
      if let some steps := steps then
        unless ← isDefEq runArgs[1]! (mkNatLit steps) do
          throwError "retained batch schema: target run has the wrong step count"
      let someValue ← whnf run.getAppArgs[2]!
      unless someValue.isAppOfArity ``Option.some 2 do throwError "retained batch schema: run must return a reached state"
      let pair ← whnf someValue.getAppArgs[1]!
      unless pair.isAppOfArity ``Prod.mk 4 do throwError "retained batch schema: run must return state and numeric server"
      let stateArgs := state.getAppArgs
      let inventoryArgs := inventory.getAppArgs
      for (left,right) in [(stateArgs.back!,result),(inventoryArgs[9]!,result),(pair.getAppArgs[2]!,result),
          (pair.getAppArgs[3]!,inventoryArgs[5]!),(inst.getAppArgs[2]!,inventoryArgs[4]!),
          (stateArgs[3]!,inventoryArgs[6]!),(stateArgs[4]!,inventoryArgs[7]!),
          (stateArgs[stateArgs.size-2]!,inventoryArgs[8]!)] do
        unless ← isDefEq left right do throwError "retained batch schema: reached state, resource map, live set or servers disagree"

/-- Check the public type after a proof-local export as well as after
generation; an equality leaf cannot pass as a complete retained transition. -/
elab "host_assert_retained_schema " theoremName:ident ", " steps:num : command =>
  Elab.Command.liftTermElabM do
    let proof ← Term.elabTerm theoremName none
    assertSchema (← proofType proof) (some steps.getNat)

/-- Infer the explicit reached annotation type from a connected proof, then
submit it as an ordinary theorem. The result must be a closed proposition. -/
elab "host_retained_theorem " name:ident " := " proof:term : command => do
  let name := (← getCurrNamespace) ++ name.getId
  Elab.Command.liftTermElabM do
    let proof ← Term.elabTerm proof none
    Term.synthesizeSyntheticMVarsNoPostponing
    let proof ← instantiateMVars proof
    let type ← instantiateMVars (← proofType proof)
    unless !proof.hasFVar && !proof.hasMVar && !type.hasFVar && !type.hasMVar && (← isProp type) do
      throwError "host_retained_theorem: expected a closed proof with an explicit proposition type"
    assertSchema type
    addDecl (.thmDecl {name,levelParams := [],type,value := proof})

end Host.Ts.Owned.Annotated.Driver

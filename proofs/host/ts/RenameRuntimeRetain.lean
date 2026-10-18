import host.ts.RenameRetainedInventory
import host.ts.RenameRuntimeDriverStep
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

private partial def leaves (type proof : Lean.Expr) : MetaM (Array (Lean.Expr × Lean.Expr)) := do
  if type.isAppOfArity ``And 2 then
    return (← leaves type.getAppArgs[0]! (← mkAppM ``And.left #[proof])) ++
      (← leaves type.getAppArgs[1]! (← mkAppM ``And.right #[proof]))
  return #[(type,proof)]

private def matchingProof (facts : Array (Lean.Expr × Lean.Expr)) (type : Lean.Expr) : MetaM Lean.Expr := do
  for (candidate,proof) in facts do
    if ← withReducible (isDefEq candidate type) then return proof
  throwError "host_retain_runtime: missing derived result fact {type}"

private def retainedType (notes runtimeType : Lean.Expr) : MetaM Lean.Expr := do
  let args := runtimeType.getAppArgs
  let updated ← mkAppM ``RetainedNotes.withRuntime #[notes,args[1]!]
  mkAppM ``RetainedInventory #[updated,args[2]!,args[3]!,args[4]!,args[5]!,args[6]!,args[7]!,args[8]!,args[9]!]

private partial def changedType (notes type : Lean.Expr) : MetaM Lean.Expr := do
  let type ← whnf type
  if type.isAppOfArity ``RuntimeInventory 10 then retainedType notes type
  else if type.isAppOfArity ``And 2 then
    mkAppM ``And #[← changedType notes type.getAppArgs[0]!,← changedType notes type.getAppArgs[1]!]
  else if type.isAppOfArity ``Exists 2 then
    let domain := type.getAppArgs[0]!
    withLocalDeclD `result domain fun result => do
      let body ← changedType notes (mkApp type.getAppArgs[1]! result)
      mkAppM ``Exists #[← mkLambdaFVars #[result] body]
  else pure type

private partial def finish (notes inventory effects type proof : Lean.Expr)
    (facts : Array (Lean.Expr × Lean.Expr)) : MetaM Lean.Expr := do
  let type ← whnf type
  if type.isAppOfArity ``And 2 then
    mkAppM ``And.intro #[
      ← finish notes inventory effects type.getAppArgs[0]! (← mkAppM ``And.left #[proof]) facts,
      ← finish notes inventory effects type.getAppArgs[1]! (← mkAppM ``And.right #[proof]) facts]
  else if type.isAppOfArity ``RuntimeInventory 10 then
    let initial := (← inferType inventory).getAppArgs
    let args := type.getAppArgs
    let effectsType ← inferType effects
    let F := effectsType.getAppArgs[0]!
    let source := initial[8]!
    let target := initial[9]!
    let sourceRunType ← mkEq (← mkAppM ``interpC #[← mkAppM ``M.run #[← mkAppM ``step #[F,source]],initial[4]!])
      (← mkAppM ``Option.some #[← mkAppM ``Prod.mk #[args[8]!,args[4]!]])
    let targetRunType ← mkEq (← mkAppM ``interpC #[← mkAppM ``M.run #[← mkAppM ``step #[F,target]],initial[5]!])
      (← mkAppM ``Option.some #[← mkAppM ``Prod.mk #[args[9]!,args[5]!]])
    let extension (before after : Lean.Expr) : MetaM Lean.Expr := do
      if ← isDefEq before after then mkAppM ``TableExtends.refl #[before]
      else matchingProof facts (← mkAppM ``TableExtends #[before,after])
    mkAppM ``RetainedInventory.pure_step #[inventory,proof,effects,
      ← matchingProof facts sourceRunType,← matchingProof facts targetRunType,
      ← extension initial[4]! args[4]!,← extension initial[5]! args[5]!]
  else pure proof

private partial def liftResult (notes inventory effects type proof : Lean.Expr) : MetaM Lean.Expr := do
  let type ← whnf type
  if type.isAppOfArity ``Exists 2 then
    let domain := type.getAppArgs[0]!
    let predicate := type.getAppArgs[1]!
    let destination ← changedType notes type
    withLocalDeclD `result domain fun result => do
      withLocalDeclD `post (mkApp predicate result) fun post => do
        let body ← liftResult notes inventory effects (mkApp predicate result) post
        let destinationPredicate := destination.getAppArgs[1]!
        let introduced ← mkAppOptM ``Exists.intro #[some domain,some destinationPredicate,some result,some body]
        let branch ← mkLambdaFVars #[result,post] introduced
        mkAppM ``Exists.elim #[proof,branch]
  else
    finish notes inventory effects type proof (← leaves type proof)

/-- Lift a checked runtime theorem to the six-family retained invariant.
The supplied term is a proof of the original paired effect case, derived from
the initial relation and source layout. It is checked inside the new theorem;
it does not become a target-step/effect premise. -/
elab "host_retain_runtime " source:ident " using " effect:term " as " destination:ident : command => do
  let source ← liftTermElabM do Term.elabTerm source none
  let name := (← getCurrNamespace) ++ destination.getId
  let value ← liftTermElabM do
    let sourceType ← inferType source
    forallTelescope sourceType fun oldLocals conclusion => do
      let rec introduce (index : Nat) (replacements newLocals : Array Lean.Expr)
          (notes inventory : Option Lean.Expr) : TermElabM Lean.Expr := do
        if index < oldLocals.size then
          let old := oldLocals[index]!
          let declaration ← old.fvarId!.getDecl
          let type := declaration.type.replaceFVars (oldLocals.extract 0 index) replacements
          if type.isConstOf ``RuntimeNotes then
            withLocalDecl declaration.userName declaration.binderInfo (mkConst ``RetainedNotes) fun localNotes => do
              introduce (index+1) (replacements.push (← mkAppM ``RetainedNotes.runtime #[localNotes]))
                (newLocals.push localNotes) (some localNotes) inventory
          else if type.isAppOfArity ``RuntimeInventory 10 then
            let some notes := notes | throwError "host_retain_runtime: notes must precede inventory"
            let args := type.getAppArgs
            let inventoryType ← mkAppM ``RetainedInventory #[notes,args[2]!,args[3]!,args[4]!,args[5]!,args[6]!,args[7]!,args[8]!,args[9]!]
            withLocalDecl declaration.userName declaration.binderInfo inventoryType fun retained => do
              introduce (index+1) (replacements.push (← mkAppM ``RetainedInventory.runtime #[retained]))
                (newLocals.push retained) (some notes) (some retained)
          else
            withLocalDecl declaration.userName declaration.binderInfo type fun localValue =>
              introduce (index+1) (replacements.push localValue) (newLocals.push localValue) notes inventory
        else
          let some notes := notes | throwError "host_retain_runtime: missing runtime notes"
          let some inventory := inventory | throwError "host_retain_runtime: missing runtime inventory"
          let effects ← Term.elabTerm effect none
          Term.synthesizeSyntheticMVarsNoPostponing
          unless (← whnf (← inferType effects)).isAppOfArity ``PureRuntimeCase 3 do
            throwError "host_retain_runtime: expected a paired PureRuntimeCase proof"
          let conclusion := conclusion.replaceFVars oldLocals replacements
          let proof ← liftResult notes inventory effects conclusion (mkAppN source replacements)
          mkLambdaFVars newLocals proof
      introduce 0 #[] #[] none none
  liftTermElabM do
    let value ← instantiateMVars value
    let type ← inferType value
    unless !value.hasMVar && !value.hasFVar && !type.hasMVar && !type.hasFVar do
      throwError "host_retain_runtime: generated theorem {name} is not closed"
    addDecl (.thmDecl {name,levelParams := [],type,value})

end Host.Ts.Owned.Annotated.Driver

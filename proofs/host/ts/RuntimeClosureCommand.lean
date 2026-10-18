import host.ts.RuntimeClosureCheck
import Lean.Elab.Command
import Lean.Elab.Term

set_option Elab.async false
namespace Host.Ts.Owned.Parametric.ClosureCheck.Command
open Lean Elab Command Meta

private def literalTrue : Lean.Expr := mkConst ``Bool.true
private def reflTrue : MetaM Lean.Expr := mkEqRefl literalTrue

private def parts (t : Lean.Expr) : MetaM (Option (Lean.Expr × Array Lean.Expr)) := do
  let t ← whnf t
  if t.isAppOfArity ``Trie.nil 1 then return none
  unless t.isAppOfArity ``Trie.node 6 do throwError "closure certificate: expected a source trie constructor"
  let args := t.getAppArgs
  return some (args[1]!,args.extract 2 6)

private partial def groups (root : Lean.Expr) : MetaM (Array Lean.Expr) := do
  let some (value,children) ← parts root | return #[]
  let mut result := #[]
  let value ← whnf value
  if value.isAppOfArity ``Option.some 2 then result := result.push value.getAppArgs[1]!
  else unless value.isAppOfArity ``Option.none 1 do throwError "closure certificate: expected an optional source group"
  for child in children do result := result ++ (← groups child)
  return result

private def source (state : Syntax) (addresses numbers : Nat) : TermElabM (Lean.Expr × Lean.Expr) := do
  let state ← instantiateMVars (← Term.elabTermAndSynthesize state none)
  let heap ← mkAppM ``St.heap #[state]
  let root ← mkAppM ``PTrie.root #[heap]
  let check ← mkAppM ``heapObject #[mkNatLit addresses,mkNatLit numbers]
  let pageCheck ← mkAppM ``allTrie #[check]
  let groupCheck ← mkAppM ``allTrie #[pageCheck]
  return (root,groupCheck)

private def groupName (pre : Lean.Name) (i : Nat) : Lean.Name := pre ++ Lean.Name.mkSimple s!"group{i}"

private def theoremDecl (name : Lean.Name) (goal proof : Lean.Expr) : TermElabM Unit := do
  addDecl (.thmDecl { name,levelParams := [],type := ← instantiateMVars (← mkEq goal literalTrue),value := ← instantiateMVars proof })

/-- Check bounded source groups independently. Their indices only select
obligations; each theorem is an ordinary kernel reduction of the exact group. -/
elab "host_closure_groups " state:term ", " addresses:num ", " numbers:num
    ", " first:num ", " count:num " as " aliasPrefix:ident : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let pre := (← getCurrNamespace) ++ aliasPrefix.getId
    let (root,check) ← source state addresses.getNat numbers.getNat
    let values ← groups root
    unless first.getNat+count.getNat ≤ values.size do throwError "closure certificate: group range exceeds the exact source heap"
    for i in [first.getNat:first.getNat+count.getNat] do
      let started ← IO.monoMsNow
      theoremDecl (groupName pre i) (mkApp check values[i]!) (← reflTrue)
      logInfo m!"closure group {i}/{values.size}: {(← IO.monoMsNow)-started} ms"
      Meta.resetCache

private partial def combine (pre : Lean.Name) (check t : Lean.Expr) (index : Nat) :
    TermElabM (Lean.Expr × Nat) := do
  let some (value,children) ← parts t | return (← reflTrue,index)
  let v ← whnf value
  let (valueProof,index) ← if v.isAppOfArity ``Option.some 2 then
      pure (mkConst (groupName pre index),index+1)
    else if v.isAppOfArity ``Option.none 1 then pure (← reflTrue,index)
    else throwError "closure certificate: expected an optional source group"
  let mut index := index
  let mut childProofs := #[]
  for child in children do
    let (proof,next) ← combine pre check child index
    childProofs := childProofs.push proof
    index := next
  let proof ← mkAppM ``allTrie_node (#[check,value] ++ children ++ #[valueProof] ++ childProofs)
  return (proof,index)

/-- The final structural join consumes every source group certificate. The
original complete heap predicate remains the theorem statement. -/
elab "host_closure_heap " state:term ", " addresses:num ", " numbers:num
    " using " aliasPrefix:ident " as " name:ident : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let pre := (← getCurrNamespace) ++ aliasPrefix.getId
    let (root,check) ← source state addresses.getNat numbers.getNat
    let (proof,count) ← combine pre check root 0
    let goal ← mkAppM ``allTrie #[check,root]
    theoremDecl ((← getCurrNamespace) ++ name.getId) goal proof
    logInfo m!"closure heap join: {count} source groups"

end Host.Ts.Owned.Parametric.ClosureCheck.Command

import host.ts.RenameRouteDriver
import host.ts.RenameParametricPrivateAssign
namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Select source private assignment transitions; the emitted source facts and
execution equations remain ordinary kernel-checked declarations. -/
elab "host_transport_private_assign " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let branch ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let add (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    if ctl.isAppOfArity ``Ctl.ev 2 then
      let expr ← whnf (← field ctl ``Ctl.ev 2 0)
      unless expr.isAppOfArity ``Expr.assign 3 do throwError "host_transport_private_assign: expected private assignment expression"
      let op ← field expr ``Expr.assign 3 0
      unless (← whnf op).isConstOf ``AsgOp.assign do throwError "host_transport_private_assign: expected simple assignment"
      let priv ← whnf (← field (← field expr ``Expr.assign 3 1) ``Pat.expr 1 0)
      let env := ctl.getAppArgs[1]!
      let name ← field priv ``Expr.priv 3 1
      for (tag,v) in [("sourceReceiver",← field priv ``Expr.priv 3 0),("sourceName",name),
        ("sourceOptional",← field priv ``Expr.priv 3 2),("sourceRhs",expr.getAppArgs[2]!),
        ("sourceEnv",env),("sourceBrand",← field (← mkAppM ``lookupEnv #[← mkAppM ``privName #[name],env]) ``Option.some 2 1)] do add tag v
      pure "descent"
    else
      add "sourceValue" (← field ctl ``Ctl.ret 1 0)
      let stack ← mkAppM ``St.stack #[s]
      add "sourceTail" (← field stack ``List.cons 3 2)
      let frame ← whnf (← field stack ``List.cons 3 1)
      unless frame.isAppOfArity ``Frame.a 1 do throwError "host_transport_private_assign: expected assignment continuation"
      let af ← whnf frame.getAppArgs[0]!
      if af.isAppOfArity ``AsgF.privObj 5 then
        unless (← whnf af.getAppArgs[0]!).isConstOf ``AsgOp.assign do throwError "host_transport_private_assign: expected simple receiver"
        for (tag,i) in [("sourceBrand",1),("sourceName",2),("sourceRhs",3),("sourceEnv",4)] do add tag af.getAppArgs[i]!
        pure "receiver"
      else
        unless af.isAppOfArity ``AsgF.put 3 && (← whnf af.getAppArgs[0]!).isAppOfArity ``Option.none 1 do
          throwError "host_transport_private_assign: expected plain private store"
        let target ← whnf af.getAppArgs[1]!
        let a ← field (← field target ``Target.priv 3 0) ``Val.obj 1 0
        let b ← field target ``Target.priv 3 1
        let n ← field target ``Target.priv 3 2
        let obj ← field (← mkAppM ``St.obj? #[s,a]) ``Option.some 2 1
        let prop ← field (← mkAppM ``findPriv #[b,n,← mkAppM ``Obj.priv #[obj]]) ``Option.some 2 1
        for (tag,v) in [("sourceAddress",a),("sourceBrand",b),("sourceName",n),("sourceObject",obj),
          ("sourcePrior",af.getAppArgs[2]!),("sourceOld",← field prop ``PropV.data 3 0),
          ("sourceEnumerable",← field prop ``PropV.data 3 2)] do add tag v
        pure "store"
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag p : String) := emit (header ++ s!"theorem {n}.{tag} : {p} := by host_kernel_rfl")
  let common := s!"{n}.F NR FR R C₀ C live framed before after old old' {n}.input s h"
  let rule ← if branch == "descent" then do
      fact "source_control" s!"{n}.input.ctl = .ev (.assign .assign (.expr (.priv {n}.sourceReceiver {n}.sourceName {n}.sourceOptional)) {n}.sourceRhs) {n}.sourceEnv"
      fact "source_lookup" s!"lookupEnv (privName {n}.sourceName) {n}.sourceEnv = some {n}.sourceBrand"
      pure s!"obtain ⟨sourceRun,run,related⟩ := step_private_assignment_from_source {common} {n}.sourceReceiver {n}.sourceName {n}.sourceOptional {n}.sourceRhs {n}.sourceEnv {n}.sourceBrand {n}.source_control {n}.source_lookup"
    else if branch == "receiver" then do
      fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
      fact "source_frame" s!"{n}.input.stack = .a (.privObj .assign {n}.sourceBrand {n}.sourceName {n}.sourceRhs {n}.sourceEnv)::{n}.sourceTail"
      pure s!"obtain ⟨v,fs,_,sourceRun,run,related⟩ := step_private_receiver_from_source {common} {n}.sourceValue {n}.sourceBrand {n}.sourceName {n}.sourceRhs {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame"
    else do
      fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
      fact "source_frame" s!"{n}.input.stack = .a (.put none (.priv (.obj {n}.sourceAddress) {n}.sourceBrand {n}.sourceName) {n}.sourcePrior)::{n}.sourceTail"
      fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
      fact "source_kind" s!"{n}.sourceObject.kind = .ordinary"
      fact "source_property" s!"findPriv {n}.sourceBrand {n}.sourceName {n}.sourceObject.priv = some (.data {n}.sourceOld true {n}.sourceEnumerable)"
      emit (header ++ s!"theorem {n}.source_bound : {n}.input.next ≤ 2^64 := by decide +kernel")
      pure s!"obtain ⟨v,o,fs,_,sourceRun,run,related⟩ := step_private_store_from_source {common} {n}.sourceAddress {n}.sourceBrand {n}.sourceName {n}.sourceValue {n}.sourcePrior {n}.sourceOld {n}.sourceEnumerable {n}.sourceObject {n}.sourceTail {n}.source_control {n}.source_frame {n}.source_heap {n}.source_kind {n}.source_property {n}.source_bound bound"
  emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  let extra := if branch == "store" then "(bound : s.next ≤ 2^64)" else ""
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s) {extra} :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result := by
    {rule}
    have source := {n}.source_run C₀
    have he := congrArg Prod.fst (Option.some.inj (sourceRun.symm.trans source))
    dsimp only at he
    exact ⟨_,run,he ▸ related⟩")

end Host.Ts.Owned.Parametric.Driver

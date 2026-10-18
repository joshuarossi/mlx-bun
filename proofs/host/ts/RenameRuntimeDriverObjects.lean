import host.ts.RenameRuntimeDriverValues
import host.ts.RenameRetainedObjectNext
import host.ts.RenameRetainedObjectValue

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

private def objectActionOf (properties : Lean.Expr) : TermElabM Lean.Expr := do
  let properties ← whnf properties
  if properties.isAppOfArity ``List.nil 1 then pure (mkConst ``Parametric.ObjectAction.done)
  else
    let property ← whnf (← field properties ``List.cons 3 1)
    let rest ← field properties ``List.cons 3 2
    if property.isAppOfArity ``Property.init 2 then
      let key := property.getAppArgs[0]!
      let name ← field (← field (← mkAppM ``keyOf #[key]) ``Option.some 2 1) ``PKey.str 1 0
      pure (mkAppN (mkConst ``Parametric.ObjectAction.initial) #[key,name,property.getAppArgs[1]!,rest])
    else if property.isAppOfArity ``Property.spread 1 then
      pure (mkAppN (mkConst ``Parametric.ObjectAction.spread) #[property.getAppArgs[0]!,rest])
    else throwError "host_retained_object: unsupported object property scheduler"

/-- Select the original object allocation or current initializer-value store.
The next action comes from source syntax, and a field's meaning comes from
its retained current return note. No future target value is inspected. -/
elab "host_retained_object " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let entry ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))))
    let add (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    let control ← whnf (← mkAppM ``St.ctl #[s])
    if control.isAppOfArity ``Ctl.ev 2 then
      let properties ← field control.getAppArgs[0]! ``Expr.object 1 0
      add "sourceAction" (← objectActionOf properties)
      add "sourceEnv" control.getAppArgs[1]!
      pure true
    else
      let value ← field control ``Ctl.ret 1 0
      let stack ← mkAppM ``St.stack #[s]
      let frame ← whnf (← field (← field stack ``List.cons 3 1) ``Frame.l 1 0)
      unless frame.isAppOfArity ``LitF.objVal 4 do throwError "host_retained_object: expected object value continuation"
      let args := frame.getAppArgs
      let object ← field (← mkAppM ``St.obj? #[s,args[0]!]) ``Option.some 2 1
      unless (← whnf (← mkAppM ``Obj.kind #[object])).isConstOf ``Kind.ordinary do
        throwError "host_retained_object: expected source ordinary object"
      for (tag,value) in [("sourceValue",value),("sourceAddress",args[0]!),("sourceName",← field args[1]! ``PKey.str 1 0),
        ("sourceAction",← objectActionOf args[2]!),("sourceEnv",args[3]!),("sourceObject",object),
        ("sourceTail",← field stack ``List.cons 3 2)] do add tag value
      pure false
  liftTermElabM do
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_valid : {n}.sourceAction.valid := by\n    dsimp only [{n}.sourceAction, ObjectAction.valid] <;> host_kernel_rfl")
  let (extra,postNotes,call,results) ← if entry then do
      fact "source_control" s!"{n}.input.ctl = .ev (.object {n}.sourceAction.properties) {n}.sourceEnv"
      Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next < 2^64 := by decide +kernel")
      pure ("(prototypeLive : live aObjectProto) (prototypeFixed : R.a aObjectProto = aObjectProto) (targetBound : s.next < 2^64)",
        s!"notes.withRuntime (notes.runtime.objectAction {n}.sourceAction {n}.input.next {n}.sourceEnv)",
        s!"inventory.object_action_step h {n}.sourceEnv {n}.sourceAction {n}.source_valid {n}.source_control
          prototypeLive prototypeFixed {n}.source_bound targetBound",
        "left,right,post,retained")
    else do
      fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
      fact "source_frame" s!"{n}.input.stack = .l (.objVal {n}.sourceAddress (.str {n}.sourceName) {n}.sourceAction.properties {n}.sourceEnv)::{n}.sourceTail"
      fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
      fact "source_kind" s!"{n}.sourceObject.kind = .ordinary"
      Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next ≤ 2^64 := by decide +kernel")
      pure (s!"(role : Annotated.Value) (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
        (controlNote : notes.runtime.control = returnNote role) (stackNotes : notes.runtime.stack = headNote::tailNotes)
        (targetBound : s.next ≤ 2^64)",
        s!"notes.objectStored {n}.sourceAddress {n}.sourceName role tailNotes {n}.sourceEnv {n}.sourceAction",
        s!"inventory.object_value_step h {n}.sourceAddress {n}.sourceName {n}.sourceValue {n}.sourceObject {n}.sourceTail {n}.sourceEnv
          {n}.sourceAction {n}.source_valid role headNote tailNotes {n}.source_control {n}.source_frame {n}.source_heap {n}.source_kind
          controlNote stackNotes {n}.source_bound targetBound",
        "value,object,frames,left,right,post,retained")
  let liveResult := if entry then s!"(LiveAfter live {n}.input.next)" else "live"
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s) {extra} :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R {liveResult} framed before after old old' {n}.output result ∧
        RetainedInventory ({postNotes}) ν₀ ν C₀ C R {liveResult} {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨{results}⟩ := {call}
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver

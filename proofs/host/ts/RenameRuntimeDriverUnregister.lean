import host.ts.RenameParametricUnregister
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Retain the original unregister builtin's pure false result. Its
semantics change no host/native inventory and do not execute the callback. -/
theorem RetainedInventory.finalization_unregister_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (a : Nat) (object : Obj) (data : List Val) (receiver : Val) (args : List Val)
    (control : s₀.ctl = .call (.obj a) receiver args)
    (read : s₀.heap.get a = some (.obj object)) (kind : object.kind = .fn (.native (.fn .finUnregister) data)) :
    interpC (step F s₀).run C₀ = some (s₀.ret (.bool false),C₀) ∧
    interpC (step F s).run C = some (s.ret (.bool false),C) ∧
    Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' (s₀.ret (.bool false)) (s.ret (.bool false)) ∧
    RetainedInventory (notes.withRuntime (notes.runtime.returning (.bool false))) ν₀ ν C₀ C R live (s₀.ret (.bool false)) (s.ret (.bool false)) := by
  obtain ⟨left,right,post⟩ := step_finalization_unregister_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h a object data receiver args control read kind
  exact ⟨left,right,post,inventory.heap_step (inventory.runtime.returning (.bool false) (.bool false)) rfl rfl (.refl C₀) (.refl C)⟩

namespace Driver
open Lean Elab Command Meta

elab "host_retained_unregister " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      Parametric.Driver.addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else some stateTy)
    let control ← mkAppM ``St.ctl #[s]
    let a ← Parametric.Driver.field (← Parametric.Driver.field control ``Ctl.call 3 0) ``Val.obj 1 0
    let object ← Parametric.Driver.field (← mkAppM ``St.obj? #[s,a]) ``Option.some 2 1
    let code ← Parametric.Driver.field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0
    for (tag,value) in [("sourceAddress",a),("sourceObject",object),
      ("sourceData",← Parametric.Driver.field code ``Code.native 2 1),
      ("sourceThis",← Parametric.Driver.field control ``Ctl.call 3 1),
      ("sourceArgs",← Parametric.Driver.field control ``Ctl.call 3 2)] do
      Parametric.Driver.addData (pre ++ Name.mkSimple tag) value
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .call (.obj {n}.sourceAddress) {n}.sourceThis {n}.sourceArgs"
  fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
  fact "source_kind" s!"{n}.sourceObject.kind = .fn (.native (.fn .finUnregister) {n}.sourceData)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime (notes.runtime.returning (.bool false))) ν₀ ν C₀ C R live {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨left,right,post,retained⟩ := inventory.finalization_unregister_step h {n}.sourceAddress
        {n}.sourceObject {n}.sourceData {n}.sourceThis {n}.sourceArgs {n}.source_control {n}.source_heap {n}.source_kind
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")
end Driver
end Host.Ts.Owned.Annotated

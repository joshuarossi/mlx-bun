import host.load.RuntimeVectorOracleSlot
import host.ts.renameOrdinary.RankOriginInitializedHandleBuffer

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedVectorOracleBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles

theorem typed_address : Plan.Block298.address = 95 := by host_kernel_rfl
theorem typed_proto : Plan.Block298.protoIndex = 26 := by host_kernel_rfl

theorem array_live_grow (live : Nat → Prop) (a : Nat) (alive : live a) : arrayLive live a := by
  unfold arrayLive
  repeat first | exact alive | apply Or.inl

/-- The null-returning source native constructor and array literal have
already established the zero element meaning. Current strong native ownership
supplies handle-zero stability; the builtin's code/prototype notes are retained
from initialization. No output buffer interpretation is an entry premise. -/
theorem null_slot_current (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (roles : Nat → GraphNode) (boundary : Nat → Prop)
    (objects : Nat → Object) (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer ((P.RestStream.micro0.micro2.S98).substitute LoopVariables.oracleVariables)) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host) R live framed before after old old'
      P.RestStream.micro0.micro2.s98 s)
    (inventory : RetainedInventory (arrayNotes notes caller) ν₀ ν C₀ C R live P.RestStream.micro0.micro2.s98 s)
    (constructorSelected : notes.captures.owners 95 = some RankOrigin.InitializedHandleBuffer.constructorMetadata)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (protoLive : live 26) (protoFixed : R.a 26 = 26) (budget : s.next+1 < 2^64) :
    ∃ result,
      interpC (step P.F P.RestStream.micro0.micro2.s98).run C₀ = some (P.RestStream.micro0.micro2.s99,C₀) ∧
      interpC (step P.F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host) R
        (LiveAfter (LiveAfter live P.RestStream.micro0.micro2.s98.next) (P.RestStream.micro0.micro2.s98.next+1))
        framed before after old old' P.RestStream.micro0.micro2.s99 result ∧
      RetainedInventory ((arrayNotes notes caller).nullTyped P.RestStream.micro0.micro2.s98.next)
        ν₀ ν C₀ C R (LiveAfter (LiveAfter live P.RestStream.micro0.micro2.s98.next) (P.RestStream.micro0.micro2.s98.next+1))
        P.RestStream.micro0.micro2.s99 result ∧ Inst ν₀ (numberServer ((P.RestStream.micro0.micro2.S99).substitute LoopVariables.oracleVariables)) C₀ := by
  have selected : (arrayNotes notes caller).captures.owners Plan.Block298.address =
      some RankOrigin.InitializedHandleBuffer.constructorMetadata := by
    change notes.captures.owners Plan.Block298.address = _
    rw [typed_address]
    exact constructorSelected
  exact Plan.Block298.retained_transport _ ν₀ ν C₀ C R _ live framed before after old old' s inst h inventory
    _ _ H N tail h.native.2 RankOrigin.InitializedHandleBuffer.constructorMetadata selected
    (by host_kernel_rfl) (by host_kernel_rfl) (by rfl) bufferLive bufferFixed
    (typed_proto ▸ protoLive) (by simpa only [typed_proto] using protoFixed) budget

def slotLive (live : Nat → Prop) : Nat → Prop :=
  LiveAfter (LiveAfter (arrayLive live) P.RestStream.micro0.micro2.s98.next) (P.RestStream.micro0.micro2.s98.next+1)
noncomputable def slotNotes (notes : RetainedNotes) (caller : List Annotated.Tree) : RetainedNotes :=
  (arrayNotes notes caller).nullTyped P.RestStream.micro0.micro2.s98.next

/-- A connected forty-nine-step prefix consumes one reached vector state.
The typed output slot is established from the original null-return and current
native relation, not supplied as an intermediate buffer/handle premise. -/
theorem vector_to_slot (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (roles : Nat → GraphNode) (boundary : Nat → Prop)
    (objects : Nat → Object) (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer ((P.RestStream.micro0.micro2.S50).substitute LoopVariables.oracleVariables)) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host) R live framed before after old old'
      P.RestStream.micro0.micro2.s50 s)
    (inventory : RetainedInventory (entryNotes notes caller) ν₀ ν C₀ C R live P.RestStream.micro0.micro2.s50 s)
    (budget : s.next+32 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (arrayBufferLive : live aArrayBufferProto) (arrayBufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (signatureFrame : ¬ framed Plan.Block295.types)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (constructorSelected : notes.captures.owners 95 = some RankOrigin.InitializedHandleBuffer.constructorMetadata)
    (typedLive : live 26) (typedFixed : R.a 26 = 26) :
    ∃ result, runC P.F 49 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host) R (slotLive live)
        framed before after old old' P.RestStream.micro0.micro2.s99 result ∧
      RetainedInventory (slotNotes notes caller) ν₀ ν C₀ C R (slotLive live) P.RestStream.micro0.micro2.s99 result ∧
      Inst ν₀ (numberServer ((P.RestStream.micro0.micro2.S99).substitute LoopVariables.oracleVariables)) C₀ := by
  have earlier := vector_to_array notes caller ν₀ ν C₀ C R _ live framed before after old old' s inst h inventory
    budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed arrayBufferLive arrayBufferFixed signatureFrame globalLive globalFixed
  obtain ⟨s298,run48,h298,inventory298,inst298⟩ := earlier
  have room := chain_next_budget_le h h298
    (P.RestStream.micro0.micro2.s98.next - P.RestStream.micro0.micro2.s50.next) 2 32 (2^64)
    (by decide +kernel) (by decide +kernel) budget
  obtain ⟨result,left,right,post,retained,inst299⟩ := null_slot_current notes caller ν₀ ν C₀ C R roles boundary objects
    H N tail host _ framed before after old old' s298 inst298 h298 inventory298 constructorSelected
    (array_live_grow live _ arrayBufferLive) arrayBufferFixed (array_live_grow live _ typedLive) typedFixed (by omega)
  have one := runC_cons P.F 0 s298 result result C C C (h298.control.isHalt_eq.trans rfl) right rfl
  exact ⟨result,runC_join P.F (m:=48) (n:=1) run48 one,post,retained,inst299⟩
host_assert_retained_schema vector_to_slot, 49

end Host.Load.Run.Full.Ordinary.RetainedVectorOracleBatch

import host.ts.RenameTypedArrayEffects
import host.mlx.OrdinaryVectorStates
import host.mlx.NativeSymbol
import host.ts.RenameRouteDriver
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro2 98 95 as Ordinary.VectorToConcat.Typed298.constructorObject
host_transport_object P.RestStream.micro0.micro2 98 3126699 as Ordinary.VectorToConcat.Typed298.arrayObject
end Host.Load.Run.Full
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.Typed298
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
noncomputable def input : St LSt := P.RestStream.micro0.micro2.s98
noncomputable def output : St LSt := P.RestStream.micro0.micro2.s99
noncomputable def newTarget : Val := match input.ctl with | .construct _ _ v => v | _ => .undef

theorem source_control : input.ctl = .construct (.obj 95) [.obj 3126699] newTarget := by host_kernel_rfl
theorem source_constructor : input.heap.get 95 = some (.obj constructorObject) := by host_kernel_rfl
theorem source_kind : constructorObject.kind = .fn (.native (.buf .typedCtor)
    [.num (.lit (F64.ofNat 9)),.num (.lit (F64.ofNat 26))]) := by host_kernel_rfl
theorem source_array : input.heap.get 3126699 = some (.obj arrayObject) := by host_kernel_rfl
theorem source_values : arrayObject.kind = .array [.big 0] := by host_kernel_rfl
theorem source_next : input.next = 3126700 := by host_kernel_rfl
theorem source_bound : input.next+1 < 2^64 := by decide +kernel
theorem source_post : (newTyped P.F input .u64 26 (cellParts .u64 (.big 0) 8 0) 1).2.ret (.obj (input.next+1)) = output := by host_kernel_rfl

/-- The real BigUint64Array constructor turns its already-computed null
integer element into the null output slot and retains the full host relation. -/
theorem transport_heap (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' input s)
    (contents : ArrayData s (R.a 3126699) [.big 0])
    (code : (Annotated.Value.literal (.lit (F64.ofNat 9))).Holds ν C R (nativeDataArgument s (R.a 95) 0))
    (proto : (Annotated.Value.literal (.lit (F64.ofNat 26))).Holds ν C R (nativeDataArgument s (R.a 95) 1))
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (protoLive : live 26) (protoFixed : R.a 26 = 26)
    (handleZero : R.handle 0 = 0) (bound : s.next+1 < 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R (LiveAfter (LiveAfter live input.next) (input.next+1)) framed before after old old' output result ∧
      (slotKindRole 0).Holds ν C R (objectKindAt result (R.a 3126700)) ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  obtain ⟨_,hr,hs⟩ := step_construct_u64_zero_from_source P.F NR FR R C₀ C ν live framed before after old old' input s h
    95 3126699 26 constructorObject arrayObject newTarget (F64.ofNat 9) (F64.ofNat 26)
    source_control source_constructor source_kind source_array source_values (by decide +kernel) (by decide +kernel)
    contents code proto bufferProtoLive bufferProtoFixed protoLive protoFixed source_bound bound
  have hs' : StateR NR FR R (LiveAfter (LiveAfter live input.next) (input.next+1)) framed before after old old' output
      ((newTyped P.F s .u64 26 (cellParts .u64 (.big 0) 8 0) 1).2.ret (.obj (s.next+1))) := source_post ▸ hs
  have hn : R.a 3126700 = s.next := by simpa only [source_next,Nat.add_zero] using h.heap.fresh 0
  have buffer := newTyped_buffer_object P.F s .u64 26 1 (cellParts .u64 (.big 0) 8 0) bound
  have role := slot_role ν C R 0
  rw [handleZero] at role
  have actual : (slotKindRole 0).Holds ν C R
      (objectKindAt ((newTyped P.F s .u64 26 (cellParts .u64 (.big 0) 8 0) 1).2.ret (.obj (s.next+1))) (R.a 3126700)) := by
    simp only [objectKindAt,hn,buffer]
    exact role
  exact ⟨_,hr,hs',actual,fun a ha => newTyped_ret_heap_below P.F s .u64 26 (cellParts .u64 (.big 0) 8 0) 1 a ha bound⟩
theorem transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' input s)
    (contents : ArrayData s (R.a 3126699) [.big 0])
    (code : (Annotated.Value.literal (.lit (F64.ofNat 9))).Holds ν C R (nativeDataArgument s (R.a 95) 0))
    (proto : (Annotated.Value.literal (.lit (F64.ofNat 26))).Holds ν C R (nativeDataArgument s (R.a 95) 1))
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (protoLive : live 26) (protoFixed : R.a 26 = 26)
    (handleZero : R.handle 0 = 0) (bound : s.next+1 < 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R (LiveAfter (LiveAfter live input.next) (input.next+1)) framed before after old old' output result ∧
      (slotKindRole 0).Holds ν C R (objectKindAt result (R.a 3126700)) := by
  obtain ⟨result,run,hr,slot,_⟩ := transport_heap NR FR R ν C₀ C live framed before after old old' s h contents code proto
    bufferProtoLive bufferProtoFixed protoLive protoFixed handleZero bound
  exact ⟨result,run,hr,slot⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat.Typed298

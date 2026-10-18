import host.ts.renameOrdinary.VectorToConcatTyped
import host.ts.RenameRouteArrayFields
import host.ts.RenameRouteDriverPreparation
import host.ts.RenameRouteDriverStructural
import host.ts.RenameRouteFields
import host.ts.RenameRouteComposition
import host.ts.RenameParametricMapControl
import host.mlx.OrdinaryArrayHost
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
host_transport_preparation P.F, P.RestStream.micro0.micro2.s96 to P.RestStream.micro0.micro2.s97 as Array296
host_transport_structural P.F, P.RestStream.micro0.micro2.s97 to P.RestStream.micro0.micro2.s98 as Argument297
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem source_constructor_stack : ArrayCall.input.stack.tail = .c (.args Argument297.sourceKind Argument297.sourceFunction
    Argument297.sourceThis Argument297.sourceAcc Argument297.sourceRest Argument297.sourceEnv)::Argument297.sourceTail := by host_kernel_rfl
theorem source_constructor_function : Argument297.sourceFunction = .obj 95 := by host_kernel_rfl
theorem source_array_next : Array296.input.next = 3126699 := by host_kernel_rfl
theorem source_native_next : ArrayCall.output.next = 3126699 := by host_kernel_rfl

theorem constructor_live (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St LSt) (h : StateR NR FR R live framed before after old old' ArrayCall.input s) : live 95 := by
  have hs := h.stackLive
  have ht : listSupport (fun f => treeSupport live (Encode.frame f)) ArrayCall.input.stack.tail := by
    cases he : ArrayCall.input.stack with
    | nil => exact True.intro
    | cons f fs => rw [he] at hs; exact hs.2
  rw [source_constructor_stack] at ht
  have hf := ht.1.1.2.1
  rw [source_constructor_function] at hf
  exact hf
end Host.Load.Run.Full.Ordinary.VectorToConcat
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi.Annotated

/-- The four original steps from mlx_array_new to the typed output slot derive
its fixed null annotation; no slot contents at a future native cut are assumed. -/
theorem initialize_null_slot_heap (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' ArrayCall.input s)
    (signatureFrame : ¬ framed 4253)
    (code : (Annotated.Value.literal (.lit (F64.ofNat 9))).Holds ν C R (nativeDataArgument s (R.a 95) 0))
    (proto : (Annotated.Value.literal (.lit (F64.ofNat 26))).Holds ν C R (nativeDataArgument s (R.a 95) 1))
    (arrayProtoLive : live aArrayProto) (arrayProtoFixed : R.a aArrayProto = aArrayProto)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live 26) (typedProtoFixed : R.a 26 = 26)
    (bound : s.next+3 ≤ 2^64) :
    ∃ result, runC P.F 4 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
        R (LiveAfter (LiveAfter (LiveAfter live Array296.input.next) Typed298.input.next) (Typed298.input.next+1))
        framed before after old old' Typed298.output result ∧
      (slotKindRole 0).Holds ν C R (objectKindAt result (R.a 3126700)) ∧
      (∀ a, live a → result.heap.get (R.a a) = s.heap.get (R.a a)) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let fr := VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host
  have ctorLive := constructor_live NR fr R live framed before after old old' s h
  obtain ⟨s296,_,hr295,h296,hc296,_,_,heap296,next296⟩ := ArrayHost.transport_heap ν₀ ν C₀ C R nodes boundary objects
    H N tail host live framed before after old old' s h signatureFrame
  have hb296 : s296.next < 2^64 := by rw [next296]; omega
  obtain ⟨s297,hr296,h297⟩ := Array296.transport NR fr R C₀ C live framed before after old old' s296 h296
    arrayProtoLive arrayProtoFixed hb296
  have hf296 : Array296.input.stack = .l (.array [] [] Array296.sourceEnv)::Array296.sourceTail := by host_kernel_rfl
  obtain ⟨_,contents297,frame297⟩ := step_singleton_array_fields P.F NR fr R live framed before after old old'
    Array296.input s296 s297 C C h296 (.big 0) Array296.sourceEnv Array296.sourceTail hf296 hc296 hb296 hr296
  have arrayAddress : R.a 3126699 = s296.next := by simpa only [source_native_next,Nat.add_zero] using h296.heap.fresh 0
  have contents297' : ArrayData s297 (R.a 3126699) [.big 0] := arrayAddress.symm ▸ contents297
  obtain ⟨s298,hr297,h298⟩ := Argument297.transport NR fr R C₀ C (LiveAfter live Array296.input.next) framed before after old old' s297 h297
  have heap298 := step_argument_heap_from_source P.F NR fr R (LiveAfter live Array296.input.next) framed before after old old'
    Argument297.input s297 s298 C C h297 Argument297.sourceValue Argument297.sourceKind Argument297.sourceFunction
    Argument297.sourceThis Argument297.sourceAcc Argument297.sourceRest Argument297.sourceEnv Argument297.sourceTail
    Argument297.source_control Argument297.source_frame (by decide) hr297
  have contents298 := contents297'.heap_eq heap298
  have heapCtor : s298.heap.get (R.a 95) = s.heap.get (R.a 95) := by
    rw [heap298,frame297 _ (h296.heap.targetBound _ ctorLive),heap296]
  have code298 : (Annotated.Value.literal (.lit (F64.ofNat 9))).Holds ν C R (nativeDataArgument s298 (R.a 95) 0) := by
    have he : nativeDataArgument s298 (R.a 95) 0 = nativeDataArgument s (R.a 95) 0 := by simp only [nativeDataArgument,St.obj?,heapCtor]
    rw [he]; exact code
  have proto298 : (Annotated.Value.literal (.lit (F64.ofNat 26))).Holds ν C R (nativeDataArgument s298 (R.a 95) 1) := by
    have he : nativeDataArgument s298 (R.a 95) 1 = nativeDataArgument s (R.a 95) 1 := by simp only [nativeDataArgument,St.obj?,heapCtor]
    rw [he]; exact proto
  have next298 : s298.next = s.next+1 := h.target_next_add h298 1 (by host_kernel_rfl)
  have hb298 : s298.next+1 < 2^64 := by rw [next298]; omega
  obtain ⟨result,hr298,h299,slot,typedFrame⟩ := Typed298.transport_heap NR fr R ν C₀ C (LiveAfter live Array296.input.next) framed before after old old' s298 h298
    contents298 code298 proto298 (Or.inl bufferProtoLive) bufferProtoFixed (Or.inl typedProtoLive) typedProtoFixed
    h298.native.2.handleZero hb298
  have oldFrame : ∀ a, live a → result.heap.get (R.a a) = s.heap.get (R.a a) := by
    intro a ha
    have hb := h296.heap.targetBound a ha
    have next296' : s296.next = s.next := next296
    have targetOld : R.a a < s298.next := by rw [next298]; rw [next296'] at hb; omega
    calc
      result.heap.get (R.a a) = s298.heap.get (R.a a) := typedFrame _ targetOld
      _ = s297.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) heap298
      _ = s296.heap.get (R.a a) := frame297 _ hb
      _ = s.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) heap296
  refine ⟨result,?_,h299,slot,oldFrame⟩
  apply runC_cons P.F 3 s s296 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr295
  apply runC_cons P.F 2 s296 s297 result C C C (h296.control.isHalt_eq.trans (by host_kernel_rfl)) hr296
  apply runC_cons P.F 1 s297 s298 result C C C (h297.control.isHalt_eq.trans (by host_kernel_rfl)) hr297
  apply runC_cons P.F 0 s298 result result C C C (h298.control.isHalt_eq.trans (by host_kernel_rfl)) hr298
  rfl
theorem initialize_null_slot (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' ArrayCall.input s)
    (signatureFrame : ¬ framed 4253)
    (code : (Annotated.Value.literal (.lit (F64.ofNat 9))).Holds ν C R (nativeDataArgument s (R.a 95) 0))
    (proto : (Annotated.Value.literal (.lit (F64.ofNat 26))).Holds ν C R (nativeDataArgument s (R.a 95) 1))
    (arrayProtoLive : live aArrayProto) (arrayProtoFixed : R.a aArrayProto = aArrayProto)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live 26) (typedProtoFixed : R.a 26 = 26)
    (bound : s.next+3 ≤ 2^64) :
    ∃ result, runC P.F 4 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
        R (LiveAfter (LiveAfter (LiveAfter live Array296.input.next) Typed298.input.next) (Typed298.input.next+1))
        framed before after old old' Typed298.output result ∧
      (slotKindRole 0).Holds ν C R (objectKindAt result (R.a 3126700)) := by
  obtain ⟨result,run,hr,slot,_⟩ := initialize_null_slot_heap ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' s h signatureFrame code proto arrayProtoLive arrayProtoFixed
    bufferProtoLive bufferProtoFixed typedProtoLive typedProtoFixed bound
  exact ⟨result,run,hr,slot⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat

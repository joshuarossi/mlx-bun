import host.ts.renameOrdinary.VectorToWeightGuard
import host.ts.renameOrdinary.ConcatToVector
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

def ConcatVectorLive (live : Nat → Prop) : Nat → Prop :=
  mapTypedLive (mapCompleteLive (mapSetupCompleteLive (concatMapLive live)))

theorem ConcatVectorLive.grow (live : Nat → Prop) (a : Nat) (ha : live a) : ConcatVectorLive live a :=
  Or.inl (Or.inl (map_complete_live_grow _ _ (map_setup_live_grow _ _ (concat_map_live_grow _ _ ha))))

theorem concat_weight_found : forestHasAddress ConvWeightVariable443.address (Callback49.input.stack.map Encode.frame) = true := by host_kernel_rfl
theorem concat_weight_cell : Callback49.input.heap.get ConvWeightVariable443.address =
    some (.cell (some (.obj WeightHandleValue478.sourceAddress))) := by host_kernel_rfl
theorem concat_axis_found : forestHasAddress AxisVariable332.address (Callback49.input.stack.map Encode.frame) = true := by host_kernel_rfl
theorem concat_stream_found : forestHasAddress StreamVariable334.address (Callback49.input.stack.map Encode.frame) = true := by host_kernel_rfl
theorem concat_code_function : MapTyped223.sourceFunction = 95 := by host_kernel_rfl
theorem concat_code_value : MapTyped223.sourceCode = F64.ofNat 9 := by host_kernel_rfl
theorem concat_proto_value : MapTyped223.sourceProtoNumber = F64.ofNat 26 := by host_kernel_rfl
theorem concat_typed_proto : MapTyped223.sourceProto = 26 := by host_kernel_rfl
theorem concat_handles : MapTyped223.sourceHandles = [25732,29363] := by host_kernel_rfl
theorem concat_native_counter : Callback49.input.ffi.mlx.next = VectorCall.input.ffi.mlx.next := by host_kernel_rfl
theorem concat_node_counter : Callback49.input.ffi.mlx.nnext = VectorCall.input.ffi.mlx.nnext := by host_kernel_rfl

/-- Continuous original source execution from concat parameter initialization,
through both map callbacks, vector/concat and construction, to the weight rank
check. Fixed later fields are carried from this entry by actual heap frames. -/
theorem concat_to_weight_rank_guard (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' Callback49.input s)
    (inputNotFramed : ¬ framed Callback56.sourceAddress)
    (firstField : PrivateData s (R.a MapBody138.sourceAddress) (R.a MapBody138.sourceBrand)
      MapBody138.sourceName (.big (Int.ofNat (R.handle 25732))))
    (secondField : PrivateData s (R.a MapBody195.sourceAddress) (R.a MapBody195.sourceBrand)
      MapBody195.sourceName (.big (Int.ofNat (R.handle 29363))))
    (axisRole : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s (R.a AxisVariable332.address)))
    (streamRole : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s (R.a StreamVariable334.address)))
    (code : (Annotated.Value.literal (.lit (F64.ofNat 9))).Holds ν C R (nativeDataArgument s (R.a 95) 0))
    (proto : (Annotated.Value.literal (.lit (F64.ofNat 26))).Holds ν C R (nativeDataArgument s (R.a 95) 1))
    (vectorSignatureFrame : ¬ framed 4411) (nullSignatureFrame : ¬ framed 4253) (concatSignatureFrame : ¬ framed 4409) (freeSignatureFrame : ¬ framed 4413)
    (firstLive : H 25732) (secondLive : H 29363)
    (functionProtoLive : live aFunctionProto) (functionProtoFixed : R.a aFunctionProto = aFunctionProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (arrayProtoLive : live aArrayProto) (arrayProtoFixed : R.a aArrayProto = aArrayProto)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live 26) (typedProtoFixed : R.a 26 = 26)
    (objectProtoFixed : R.a aObjectProto = aObjectProto)
    (weightField : PrivateData s (R.a WeightHandleValue478.sourceAddress) (R.a WeightHandleValue478.sourceBrand)
      WeightHandleValue478.sourceName (.big (Int.ofNat (R.handle 1365))))
    (weightSignatureFrame : ¬ framed 4263) (weightHandleLive : H 1365)
    (sequenceLive : live Binding20.sourceAddress)
    (sequence : s.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))))
    (nodeBound : s.ffi.mlx.nnext < 2^64) (nativeBound : s.ffi.mlx.next+1 < 2^64) (heapBound : s.next+64 ≤ 2^64) :
    ∃ result, runC P.F 453 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
          (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (WeightLive468 (HandleLive (ConstructorBodyLive (LiveAfter (BaseClassLive (callbackLive (initializedSlotLive (outBodyLive (ConcatVectorLive live)))) MlxClass372.input.next) TokenObject376.input.next) MlxBody380.input.next Sources.Mlx.Array.ast_n20))) framed before after old old' WeightGuard18.output result ∧
      PrivateData result (R.a 3126703) (R.a HandleStore390.sourceBrand) HandleStore390.sourceName (.big (Int.ofNat (R.handle 29372))) ∧
      result.heap.get (R.a ConvInputBinding429.sourceAddress) = some (.cell (some (.obj (R.a 3126703)))) ∧
      result.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) ∧
      (∀ a, live a → a < 3126665 → a ≠ ConvInputBinding429.sourceAddress → result.heap.get (R.a a) = s.heap.get (R.a a)) ∧
      result.heap.get (R.a WeightInitialize9.sourceAddress) = some (.cell (some (natV 3))) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let FR := VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host
  have firstBound : R.handle 25732 < 2^64 := by
    have hb := h.native.2.handleMap.bound 25732 (h.native.2.liveHandleBound 25732 firstLive)
    omega
  have secondBound : R.handle 29363 < 2^64 := by
    have hb := h.native.2.handleMap.bound 29363 (h.native.2.liveHandleBound 29363 secondLive)
    omega
  have handlesBound : ∀ handle ∈ MapTyped223.sourceHandles.map R.handle, handle < 2^64 := by
    rw [concat_handles]
    intro handle hh
    simp only [List.map_cons,List.map_nil,List.mem_cons,List.not_mem_nil,or_false] at hh
    rcases hh with rfl | rfl
    · exact firstBound
    · exact secondBound
  have mapCode : (Annotated.Value.literal (.lit MapTyped223.sourceCode)).Holds ν C R
      (nativeDataArgument s (R.a MapTyped223.sourceFunction) 0) := by
    simpa only [concat_code_function,concat_code_value] using code
  have mapProto : (Annotated.Value.literal (.lit MapTyped223.sourceProtoNumber)).Holds ν C R
      (nativeDataArgument s (R.a MapTyped223.sourceFunction) 1) := by
    simpa only [concat_code_function,concat_proto_value] using proto
  have mapTypedLive : live MapTyped223.sourceProto := concat_typed_proto.symm ▸ typedProtoLive
  have mapTypedFixed : R.a MapTyped223.sourceProto = MapTyped223.sourceProto := by
    rw [concat_typed_proto]; exact typedProtoFixed
  obtain ⟨s249,run200,h249,count,buffer,frame249⟩ := concat_to_vector FR R ν₀ ν C₀ C live framed before after old old' s h
    inputNotFramed firstField secondField mapCode mapProto handlesBound functionProtoLive functionProtoFixed
    arrayProtoLive arrayProtoFixed bufferProtoLive bufferProtoFixed mapTypedLive mapTypedFixed globalLive globalFixed (by omega)
  have grow := ConcatVectorLive.grow live
  have axisLive := h.stack_address_live _ concat_axis_found
  have streamLive := h.stack_address_live _ concat_stream_found
  have weightCellLive := h.stack_address_live _ concat_weight_found
  obtain ⟨_,_,_,weightLive⟩ := h.heap.readCell _ _ weightCellLive concat_weight_cell
  obtain ⟨_,_,constructorLive⟩ := concat_initial_live NR FR R live framed before after old old' s h inputNotFramed globalLive
  have constructorLive95 : live 95 := by simpa only [concat_code_function] using constructorLive
  have axisHeap := frame249 _ axisLive (by decide +kernel)
  have streamHeap := frame249 _ streamLive (by decide +kernel)
  have constructorHeap := frame249 95 constructorLive95 (by decide +kernel)
  have weightHeap := frame249 _ weightLive (by decide +kernel)
  have axis249 : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s249 (R.a AxisVariable332.address)) := by
    simpa only [cellValueAt,axisHeap] using axisRole
  have stream249 : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s249 (R.a StreamVariable334.address)) := by
    simpa only [cellValueAt,streamHeap] using streamRole
  have code249 : (Annotated.Value.literal (.lit (F64.ofNat 9))).Holds ν C R (nativeDataArgument s249 (R.a 95) 0) := by
    simpa only [nativeDataArgument,St.obj?,constructorHeap] using code
  have proto249 : (Annotated.Value.literal (.lit (F64.ofNat 26))).Holds ν C R (nativeDataArgument s249 (R.a 95) 1) := by
    simpa only [nativeDataArgument,St.obj?,constructorHeap] using proto
  have weight249 := weightField.heap_at weightHeap
  have sequence249 := (frame249 _ sequenceLive (by decide +kernel)).trans sequence
  have sameNative : s249.ffi.mlx.next = s.ffi.mlx.next := by
    have first : R.handle VectorCall.input.ffi.mlx.next = s.ffi.mlx.next :=
      (congrArg R.handle concat_native_counter).symm.trans h.native.2.handleMap.head
    exact h249.native.2.handleMap.head.symm.trans first
  have sameNodes : s249.ffi.mlx.nnext = s.ffi.mlx.nnext := by
    have first : R.node VectorCall.input.ffi.mlx.nnext = s.ffi.mlx.nnext :=
      (congrArg R.node concat_node_counter).symm.trans h.native.2.nodeMap.head
    exact h249.native.2.nodeMap.head.symm.trans first
  have next249 := h.target_next_add h249 (VectorCall.input.next-Callback49.input.next) (by host_kernel_rfl)
  have budget : VectorCall.input.next-Callback49.input.next+40 ≤ 64 := by decide +kernel
  have bound249 : s249.next+40 ≤ 2^64 := by omega
  obtain ⟨result,run253,hpost,privateResult,inputResult,sequenceResult,frameResult,rankResult⟩ := vector_to_weight_rank_guard
    ν₀ ν C₀ C R base boundary objects H N tail host (ConcatVectorLive live) framed before after old old' s249 h249
    count buffer axis249 stream249 code249 proto249 vectorSignatureFrame nullSignatureFrame concatSignatureFrame freeSignatureFrame
    firstLive secondLive (grow _ functionProtoLive) functionProtoFixed (grow _ globalLive) globalFixed
    (grow _ arrayProtoLive) arrayProtoFixed (grow _ bufferProtoLive) bufferProtoFixed
    (grow _ typedProtoLive) typedProtoFixed objectProtoFixed weight249 weightSignatureFrame weightHandleLive
    (grow _ sequenceLive) sequence249 (sameNodes.symm ▸ nodeBound) ((congrArg (fun n => n+1) sameNative).symm ▸ nativeBound) bound249
  refine ⟨result,runC_join P.F (m:=200) (n:=253) run200 run253,hpost,privateResult,inputResult,sequenceResult,?_,rankResult⟩
  intro address alive below other
  have beforeHandles : address ≠ VectorInput225.sourceAddress := by
    have : VectorInput225.sourceAddress = 3126669 := by host_kernel_rfl
    rw [this]; omega
  exact (frameResult address (grow _ alive) below other).trans (frame249 address alive beforeHandles)
end Host.Load.Run.Full.Ordinary.VectorToConcat

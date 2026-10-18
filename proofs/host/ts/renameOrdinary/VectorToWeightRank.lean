import host.ts.renameOrdinary.VectorToShapeGetter
import host.ts.renameOrdinary.ConvWeightRankPath
import host.ts.RenameLiveAddress
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem vector_weight_found : forestHasAddress ConvWeightVariable443.address (VectorCall.input.stack.map Encode.frame) = true := by host_kernel_rfl
theorem vector_weight_cell : VectorCall.input.heap.get ConvWeightVariable443.address =
    some (.cell (some (.obj WeightHandleValue478.sourceAddress))) := by host_kernel_rfl
theorem vector_input_found : forestHasAddress ConvInputBinding429.sourceAddress (VectorCall.input.stack.map Encode.frame) = true := by host_kernel_rfl

/-- Continuous source execution carries the initial loaded-weight ownership
through concat, construction and nested getters, deriving the real rank read. -/
theorem vector_to_weight_rank (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' VectorCall.input s)
    (countRole : (Annotated.Value.ordinaryBig (Int.ofNat 2)).Holds ν C R (callArgument s.ctl 1))
    (bufferRole : (VectorBuffer.role [25732,29363]).Holds ν C R (objectKindAt s (R.a 3126688)))
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
    (nodeBound : s.ffi.mlx.nnext < 2^64) (nativeBound : s.ffi.mlx.next+1 < 2^64) (heapBound : s.next+40 ≤ 2^64) :
    ∃ result, runC P.F 236 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
          (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (WeightLive468 (HandleLive (ConstructorBodyLive (LiveAfter (BaseClassLive (callbackLive (initializedSlotLive (outBodyLive live))) MlxClass372.input.next) TokenObject376.input.next) MlxBody380.input.next Sources.Mlx.Array.ast_n20))) framed before after old old' NdimCall.output result ∧
      PrivateData result (R.a 3126703) (R.a HandleStore390.sourceBrand) HandleStore390.sourceName (.big (Int.ofNat (R.handle 29372))) ∧
      result.heap.get (R.a ConvInputBinding429.sourceAddress) = some (.cell (some (.obj (R.a 3126703)))) ∧
      result.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) ∧
      (∀ a, live a → a < 3126665 → a ≠ ConvInputBinding429.sourceAddress → result.heap.get (R.a a) = s.heap.get (R.a a)) ∧
      result.ctl = .ret (.big 3) := by
  obtain ⟨s445,run196,h445,arrayField,inputCell,sequence445,caller445,_⟩ := vector_to_shape_getter
    ν₀ ν C₀ C R base boundary objects H N tail host live framed before after old old' s h countRole bufferRole axisRole
    streamRole code proto vectorSignatureFrame nullSignatureFrame concatSignatureFrame freeSignatureFrame firstLive secondLive
    functionProtoLive functionProtoFixed globalLive globalFixed arrayProtoLive arrayProtoFixed bufferProtoLive bufferProtoFixed
    typedProtoLive typedProtoFixed objectProtoFixed sequenceLive sequence nodeBound nativeBound heapBound
  have weightCellLive := h.stack_address_live _ vector_weight_found
  obtain ⟨_,_,_,weightLive⟩ := h.heap.readCell _ _ weightCellLive vector_weight_cell
  have inputLive := h.stack_address_live _ vector_input_found
  have fixedWeight := weightField.heap_at (caller445 _ weightLive (by decide +kernel) (by decide +kernel))
  have next445 := h.heap.target_next_add h445.heap (WeightShapeGetter445.input.next-VectorCall.input.next) (by host_kernel_rfl)
  have budget445 : WeightShapeGetter445.input.next-VectorCall.input.next+20 ≤ 40 := by decide +kernel
  have bound445 : s445.next+20 ≤ 2^64 := by omega
  obtain ⟨result,run40,h485,rank,frame485⟩ := conv_weight_rank ν₀ ν C₀ C R (ConcatNative.postRoles base) boundary
    (objectWrite objects 29371 (.vec [20208,22582])) (fun a => a = 29372 ∨ a = 29371 ∨ H a)
    (fun i => i = 22587 ∨ N i) tail host _ framed before after old old' s445 h445 fixedWeight
    (returned_array_live_grow live aGlobal globalLive) globalFixed weightSignatureFrame (Or.inr (Or.inr weightHandleLive)) bound445
  have mappedArray := h.heap.fresh (3126703-VectorCall.input.next)
  have arraySource : VectorCall.input.next+(3126703-VectorCall.input.next) = 3126703 := by decide +kernel
  rw [arraySource] at mappedArray
  have arrayBefore : 3126703-VectorCall.input.next < WeightShapeGetter445.input.next-VectorCall.input.next := by decide +kernel
  have arrayBound : R.a 3126703 < s445.next := by omega
  have arrayField485 := arrayField.heap_at (frame485 _ arrayBound)
  have inputBound : R.a ConvInputBinding429.sourceAddress < s445.next := by
    have initial := h.heap.targetBound _ inputLive
    omega
  have sequenceBound : R.a Binding20.sourceAddress < s445.next := by
    have initial := h.heap.targetBound _ sequenceLive
    omega
  have input485 := (frame485 _ inputBound).trans inputCell
  have sequence485 := (frame485 _ sequenceBound).trans sequence445
  refine ⟨result,runC_join P.F (m:=196) (n:=40) run196 run40,h485,arrayField485,input485,sequence485,?_,rank⟩
  intro a alive below other
  have initial := h.heap.targetBound a alive
  have bound : R.a a < s445.next := by omega
  exact (frame485 _ bound).trans (caller445 a alive below other)
end Host.Load.Run.Full.Ordinary.VectorToConcat

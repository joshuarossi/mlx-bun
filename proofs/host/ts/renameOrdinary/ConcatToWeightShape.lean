import host.ts.renameOrdinary.ConcatToWeightGuard
import host.ts.renameOrdinary.WeightShapePath
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

def ConcatWeightGuardLive (live : Nat → Prop) : Nat → Prop := WeightLive468 (HandleLive (ConstructorBodyLive (LiveAfter (BaseClassLive (callbackLive (initializedSlotLive (outBodyLive (ConcatVectorLive live)))) MlxClass372.input.next) TokenObject376.input.next) MlxBody380.input.next Sources.Mlx.Array.ast_n20))

theorem ConcatWeightGuardLive.grow (live : Nat → Prop) (a : Nat) (ha : live a) : ConcatWeightGuardLive live a :=
  WeightLive468.grow _ a (returned_array_live_grow _ a (ConcatVectorLive.grow live a ha))

theorem weight_shape_address : WeightShape.Handle40.sourceAddress = WeightHandleValue478.sourceAddress := by host_kernel_rfl
theorem weight_shape_brand : WeightShape.Handle40.sourceBrand = WeightHandleValue478.sourceBrand := by host_kernel_rfl
theorem weight_shape_name : WeightShape.Handle40.sourceName = WeightHandleValue478.sourceName := by host_kernel_rfl
theorem shape_rank_found : forestHasAddress WeightInitialize9.sourceAddress (WeightGuard18.output.stack.map Encode.frame) = true := by host_kernel_rfl
theorem concat_input_found : forestHasAddress ConvInputBinding429.sourceAddress (Callback49.input.stack.map Encode.frame) = true := by host_kernel_rfl

/-- The original source concat/map/constructor path and nested getters form
one execution through the native shape pointer and typed-buffer preparation.
All later field roles and the saved argument follow from this entry. -/
theorem concat_to_weight_shape (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
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
    (shapeSignatureFrame : ¬ framed WeightShape.ShapeNative.signature)
    (shapeRegion : R.region (4*1365) = 4*R.handle 1365)
    (sequenceLive : live Binding20.sourceAddress)
    (sequence : s.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))))
    (nodeBound : s.ffi.mlx.nnext < 2^64) (nativeBound : s.ffi.mlx.next+1 < 2^64) (heapBound : s.next+64 ≤ 2^64) :
    ∃ result, runC P.F 493 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
          (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (WeightShape.GetterLive (ConcatWeightGuardLive live)) framed before after old old' WeightShape.BufferCallee58.output result ∧
      PrivateData result (R.a 3126703) (R.a HandleStore390.sourceBrand) HandleStore390.sourceName (.big (Int.ofNat (R.handle 29372))) ∧
      result.heap.get (R.a ConvInputBinding429.sourceAddress) = some (.cell (some (.obj (R.a 3126703)))) ∧
      result.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) ∧
      (∀ a, live a → a < 3126665 → a ≠ ConvInputBinding429.sourceAddress → result.heap.get (R.a a) = s.heap.get (R.a a)) ∧
      result.heap.get (R.a WeightInitialize9.sourceAddress) = some (.cell (some (natV 3))) ∧ SavedConvSequence R (result.stack.drop 7) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let FR := VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
    (objectWrite objects 29371 (.vec [20208,22582])) (fun a => a = 29372 ∨ a = 29371 ∨ H a)
    (fun i => i = 22587 ∨ N i) tail host
  obtain ⟨s502,run453,h502,array502,input502,sequence502,caller502,rank502,saved502⟩ := concat_to_weight_rank_guard_framed
    ν₀ ν C₀ C R base boundary objects H N tail host live framed before after old old' s h inputNotFramed firstField secondField
    axisRole streamRole code proto vectorSignatureFrame nullSignatureFrame concatSignatureFrame freeSignatureFrame firstLive secondLive
    functionProtoLive functionProtoFixed globalLive globalFixed arrayProtoLive arrayProtoFixed bufferProtoLive bufferProtoFixed
    typedProtoLive typedProtoFixed objectProtoFixed weightField weightSignatureFrame weightHandleLive sequenceLive sequence nodeBound nativeBound heapBound
  have grow := ConcatWeightGuardLive.grow live
  have weightCellLive := h.stack_address_live _ concat_weight_found
  obtain ⟨_,_,_,weightLive⟩ := h.heap.readCell _ _ weightCellLive concat_weight_cell
  have weight502 := weightField.heap_at (caller502 _ weightLive (by decide +kernel) (by decide +kernel))
  have shapeField : PrivateData s502 (R.a WeightShape.Handle40.sourceAddress) (R.a WeightShape.Handle40.sourceBrand)
      WeightShape.Handle40.sourceName (.big (Int.ofNat (R.handle 1365))) := by
    change @PrivateData LSt s502 (R.a WeightShape.Handle40.sourceAddress) (R.a WeightShape.Handle40.sourceBrand) WeightShape.Handle40.sourceName (.big (Int.ofNat (R.handle 1365)))
    simpa only [weight_shape_address,weight_shape_brand,weight_shape_name] using weight502
  have rankLive := h502.stack_address_live _ shape_rank_found
  have next502 := h.heap.target_next_add h502.heap (WeightGuard18.output.next-Callback49.input.next) (by host_kernel_rfl)
  have budget : WeightGuard18.output.next-Callback49.input.next+2+(paramNames WeightShape.EnterGetter28.sourceFunction).length ≤ 64 := by decide +kernel
  have bound502 : s502.next+2+(paramNames WeightShape.EnterGetter28.sourceFunction).length ≤ 2^64 := by omega
  have receiverLive : ConcatWeightGuardLive live WeightShape.Handle40.sourceAddress := weight_shape_address.symm ▸ grow _ weightLive
  obtain ⟨result,run40,hresult,rankResult,weightResult,frame542,stack542⟩ := WeightShape.shape_path_transport NR FR R ν C₀ C
    (ConcatWeightGuardLive live) framed before after old old' s502 h502 rank502 rankLive receiverLive shapeField
    (NodeRel (ConcatNative.postRoles base) ν₀ ν C₀ C R boundary)
    (ObjectRel (objectWrite objects 29371 (.vec [20208,22582])) ν₀ ν C₀ C R)
    (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail h502.native.2 shapeSignatureFrame
    (Or.inr (Or.inr weightHandleLive)) shapeRegion bound502 (grow _ globalLive) globalFixed
  have pointerFresh := h.heap.fresh (WeightShape.PointerBinding48.sourceAddress-Callback49.input.next)
  have pointerSource : Callback49.input.next+(WeightShape.PointerBinding48.sourceAddress-Callback49.input.next) = WeightShape.PointerBinding48.sourceAddress := by decide +kernel
  rw [pointerSource] at pointerFresh
  have arrayFresh := h.heap.fresh (3126703-Callback49.input.next)
  have arraySource : Callback49.input.next+(3126703-Callback49.input.next) = 3126703 := by decide +kernel
  rw [arraySource] at arrayFresh
  have arrayBefore : 3126703-Callback49.input.next < WeightGuard18.output.next-Callback49.input.next := by decide +kernel
  have arrayOther : 3126703-Callback49.input.next ≠ WeightShape.PointerBinding48.sourceAddress-Callback49.input.next := by decide +kernel
  have arrayBound : R.a 3126703 < s502.next := by omega
  have arrayNotPointer : R.a 3126703 ≠ R.a WeightShape.PointerBinding48.sourceAddress := by omega
  have arrayResult := array502.heap_at (frame542 _ arrayBound arrayNotPointer)
  have inputLive := h.stack_address_live _ concat_input_found
  have inputBound : R.a ConvInputBinding429.sourceAddress < s502.next := by have hb := h.heap.targetBound _ inputLive; omega
  have sequenceBound : R.a Binding20.sourceAddress < s502.next := by have hb := h.heap.targetBound _ sequenceLive; omega
  have inputOther : R.a ConvInputBinding429.sourceAddress ≠ R.a WeightShape.PointerBinding48.sourceAddress := by have hb := h.heap.targetBound _ inputLive; omega
  have sequenceOther : R.a Binding20.sourceAddress ≠ R.a WeightShape.PointerBinding48.sourceAddress := by have hb := h.heap.targetBound _ sequenceLive; omega
  have inputResult := (frame542 _ inputBound inputOther).trans input502
  have sequenceResult := (frame542 _ sequenceBound sequenceOther).trans sequence502
  have savedResult : SavedConvSequence R (result.stack.drop 7) := stack542.symm ▸ saved502
  refine ⟨result,runC_join P.F (m:=453) (n:=40) run453 run40,hresult,arrayResult,inputResult,sequenceResult,?_,rankResult,savedResult⟩
  intro address alive below other
  have hb := h.heap.targetBound _ alive
  have targetBefore : R.a address < s502.next := by omega
  have targetOther : R.a address ≠ R.a WeightShape.PointerBinding48.sourceAddress := by omega
  exact (frame542 _ targetBefore targetOther).trans (caller502 address alive below other)
end Host.Load.Run.Full.Ordinary.VectorToConcat

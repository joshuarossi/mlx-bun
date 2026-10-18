import host.ts.renameOrdinary.IncomingToWeightGuard
import host.ts.renameOrdinary.ConcatToWeightShape
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated
/-- Actual rank and both shape getter paths compose with concat, preserving
its saved sequence operand and all owned caller parameters. -/
theorem incoming_to_weight_shape (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' RankOrigin.input s)
    (firstField : PrivateData s (R.a MapBody138.sourceAddress) (R.a MapBody138.sourceBrand)
      MapBody138.sourceName (.big (Int.ofNat (R.handle 25732))))
    (secondField : PrivateData s (R.a MapBody195.sourceAddress) (R.a MapBody195.sourceBrand)
      MapBody195.sourceName (.big (Int.ofNat (R.handle 29363))))
    (streamRole : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s (R.a Parameter45.address)))
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
    (weightShapeSignatureFrame : ¬ framed WeightShape.ShapeNative.signature)
    (weightShapeRegion : R.region (4*1365) = 4*R.handle 1365)
    (firstReceiverLive : live MapBody138.sourceAddress) (secondReceiverLive : live MapBody195.sourceAddress)
    (weightReceiverLive : live WeightHandleValue478.sourceAddress) (constructorLive : live 95)
    (gpuLive : live Parameter45.address)
    (shapeCode : (Annotated.Value.literal (.lit (F64.ofNat 4))).Holds ν C R (nativeDataArgument s (R.a 90) 0))
    (shapeProto : (Annotated.Value.literal (.lit (F64.ofNat 21))).Holds ν C R (nativeDataArgument s (R.a 90) 1))
    (shapeTypedLive : live 21) (shapeTypedFixed : R.a 21 = 21)
    (rankSignatureFrame : ¬ framed RankOrigin.signature) (shapeSignatureFrame : ¬ framed RankOrigin.ShapeNative.signature)
    (inputRole : (Annotated.Value.handle 29363).Holds ν C R (callArgument s.ctl 0))
    (shapeRegion : R.region 117452 = 4*R.handle 29363)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (nativeBound : s.ffi.mlx.next+1 < 2^64) (heapBound : s.next+96 ≤ 2^64) :
    ∃ result, runC P.F 600 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
          (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (WeightShape.GetterLive (ConcatWeightGuardLive (Incoming49Live live))) framed before after old old' WeightShape.BufferCallee58.output result ∧
      PrivateData result (R.a 3126703) (R.a HandleStore390.sourceBrand) HandleStore390.sourceName (.big (Int.ofNat (R.handle 29372))) ∧
      result.heap.get (R.a ConvInputBinding429.sourceAddress) = some (.cell (some (.obj (R.a 3126703)))) ∧
      result.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) ∧
      (∀ a, live a → a < 3126641 → a ≠ ConvInputBinding429.sourceAddress → result.heap.get (R.a a) = s.heap.get (R.a a)) ∧
      result.heap.get (R.a WeightInitialize9.sourceAddress) = some (.cell (some (natV 3))) ∧ SavedConvSequence R (result.stack.drop 7) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let FR : Ren → LSt → LSt → Prop := fun _ a b => host a.host b.host
  let roles := ConcatNative.preRoles base
  let objectsR := fun Q => Host.Mlx.Ffi.Annotated.ObjectRel objects ν₀ ν C₀ C Q
  have shapeField : PrivateData s (R.a RankOrigin.Handle40.sourceAddress) (R.a RankOrigin.Handle40.sourceBrand)
      RankOrigin.Handle40.sourceName (.big (Int.ofNat (R.handle 29363))) := by
    simpa only [current_address,current_brand,current_name] using secondField
  have dim : (roles 22582).shape[1]? = some (.literal (.lit (F64.ofNat 1))) := by
    simp only [roles,ConcatNative.preRoles,ite_true]
    rfl
  have namesBound : 11 + (blockNames Parameter48.sourceBody).length ≤ 96 := by decide +kernel
  obtain ⟨s49,run107,h49,axis49,sequence49,sequenceLive49,frame49,stream49⟩ := incoming_prefix49_sequence_frame_transport
    FR R ν₀ ν C₀ C roles objectsR boundary H N tail live framed before after old old' s h
    shapeCode shapeProto shapeField rankSignatureFrame shapeSignatureFrame inputRole globalLive globalFixed
    bufferProtoLive bufferProtoFixed shapeTypedLive shapeTypedFixed arrayProtoLive arrayProtoFixed dim secondLive shapeRegion (by omega)
  have grow := Incoming49Live.grow live
  have first49 := firstField.heap_at (frame49 _ firstReceiverLive (by decide +kernel))
  have second49 := secondField.heap_at (frame49 _ secondReceiverLive (by decide +kernel))
  have weight49 := weightField.heap_at (frame49 _ weightReceiverLive (by decide +kernel))
  have ctor49 := frame49 95 constructorLive (by decide +kernel)
  have code49 : (Annotated.Value.literal (.lit (F64.ofNat 9))).Holds ν C R (nativeDataArgument s49 (R.a 95) 0) := by
    simpa only [nativeDataArgument,St.obj?,ctor49] using code
  have proto49 : (Annotated.Value.literal (.lit (F64.ofNat 26))).Holds ν C R (nativeDataArgument s49 (R.a 95) 1) := by
    simpa only [nativeDataArgument,St.obj?,ctor49] using proto
  have streamRole49 : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s49 (R.a StreamVariable334.address)) := by
    rw [stream_address,stream49 gpuLive]
    exact streamRole
  have axisRole49 : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s49 (R.a AxisVariable332.address)) := by
    rw [axis_address]
    simp only [cellValueAt,axis49]
    exact .literal _ _ rfl
  have inputNotFramed : ¬ framed Callback56.sourceAddress := by
    intro framedInput
    have bound := h.heap.sourceBound _ (h.heap.prefixLive _ framedInput)
    have fresh : RankOrigin.input.next ≤ Callback56.sourceAddress := by decide +kernel
    omega
  have sameNative : s49.ffi.mlx.next = s.ffi.mlx.next := by
    have first : R.handle Callback49.input.ffi.mlx.next = s.ffi.mlx.next :=
      (congrArg R.handle incoming_native_counter).symm.trans h.native.2.handleMap.head
    exact h49.native.2.handleMap.head.symm.trans first
  have sameNodes : s49.ffi.mlx.nnext = s.ffi.mlx.nnext := by
    have first : R.node Callback49.input.ffi.mlx.nnext = s.ffi.mlx.nnext :=
      (congrArg R.node incoming_node_counter).symm.trans h.native.2.nodeMap.head
    exact h49.native.2.nodeMap.head.symm.trans first
  have next49 := h.target_next_add h49 (Callback49.input.next-RankOrigin.input.next) (by host_kernel_rfl)
  have remaining : Callback49.input.next-RankOrigin.input.next+64 ≤ 96 := by decide +kernel
  obtain ⟨result,run493,hpost,privateResult,inputResult,sequenceResult,frameResult,rankResult,savedResult⟩ := concat_to_weight_shape
    ν₀ ν C₀ C R base boundary objects H N tail host (Incoming49Live live) framed before after old old' s49 h49
    inputNotFramed first49 second49 axisRole49 streamRole49 code49 proto49
    vectorSignatureFrame nullSignatureFrame concatSignatureFrame freeSignatureFrame firstLive secondLive
    (grow _ functionProtoLive) functionProtoFixed (grow _ globalLive) globalFixed
    (grow _ arrayProtoLive) arrayProtoFixed (grow _ bufferProtoLive) bufferProtoFixed (grow _ typedProtoLive) typedProtoFixed
    objectProtoFixed weight49 weightSignatureFrame weightHandleLive weightShapeSignatureFrame weightShapeRegion sequenceLive49 sequence49
    (sameNodes.symm ▸ nodeBound) ((congrArg (fun n => n+1) sameNative).symm ▸ nativeBound) (by omega)
  refine ⟨result,runC_join P.F (m:=107) (n:=493) run107 run493,hpost,privateResult,inputResult,sequenceResult,?_,rankResult,savedResult⟩
  intro address alive below other
  exact (frameResult address (grow _ alive) (by omega) other).trans (frame49 address alive below)
end Host.Load.Run.Full.Ordinary.VectorToConcat

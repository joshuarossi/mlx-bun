import host.ts.renameOrdinary.VectorToConvTail
import host.ts.renameOrdinary.ConvShapeEntryPath
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated
/-- Continuous execution reaches the real weight.shape getter while retaining
both the allocated array's ownership and the literal S argument in its caller. -/
theorem vector_to_shape_getter (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
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
    (sequenceLive : live Binding20.sourceAddress)
    (sequence : s.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))))
    (nodeBound : s.ffi.mlx.nnext < 2^64) (nativeBound : s.ffi.mlx.next+1 < 2^64) (heapBound : s.next+40 ≤ 2^64) :
    ∃ result, runC P.F 196 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
          (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (HandleLive (ConstructorBodyLive (LiveAfter (BaseClassLive (callbackLive (initializedSlotLive (outBodyLive live))) MlxClass372.input.next) TokenObject376.input.next) MlxBody380.input.next Sources.Mlx.Array.ast_n20)) framed before after old old' ConvWeightGetter444.output result ∧
      PrivateData result (R.a 3126703) (R.a HandleStore390.sourceBrand) HandleStore390.sourceName (.big (Int.ofNat (R.handle 29372))) ∧
      result.heap.get (R.a ConvInputBinding429.sourceAddress) = some (.cell (some (.obj (R.a 3126703)))) ∧
      result.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) ∧
      (∀ a, live a → a < 3126665 → a ≠ ConvInputBinding429.sourceAddress → result.heap.get (R.a a) = s.heap.get (R.a a)) ∧
      ∃ fn this acc fs, result.stack =
        ConvWeightIndex441.descent.frame (R.env ConvWeightIndex441.sourceEnv)::
        ConvLengthExpression440.descent.frame (R.env ConvLengthExpression440.sourceEnv)::
        .c (.args 0 fn this (natV 1::acc) convThirdRest (R.env ConvTailArguments439.sourceEnv))::fs := by
  obtain ⟨s440,run191,h440,field,inputCell,sequence440,caller440,fn,this,acc,fs,stack440,_⟩ := vector_to_conv_tail_framed
    ν₀ ν C₀ C R base boundary objects H N tail host live framed before after old old' s h countRole bufferRole axisRole
    streamRole code proto vectorSignatureFrame nullSignatureFrame concatSignatureFrame freeSignatureFrame firstLive secondLive
    functionProtoLive functionProtoFixed globalLive globalFixed arrayProtoLive arrayProtoFixed bufferProtoLive bufferProtoFixed
    typedProtoLive typedProtoFixed objectProtoFixed sequenceLive sequence nodeBound nativeBound heapBound
  obtain ⟨result,run5,h445,heap,stack445⟩ := conv_shape_getter_entry (NumberRoles ν₀ ν C₀ C)
    (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
      (objectWrite objects 29371 (.vec [20208,22582]))
      (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
    R C₀ C _ framed before after old old' s440 h440
  have input445 : result.heap.get (R.a ConvInputBinding429.sourceAddress) = some (.cell (some (.obj (R.a 3126703)))) := by
    rw [heap]
    exact inputCell
  have sequence445 : result.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) := by
    rw [heap]
    exact sequence440
  rw [stack440] at stack445
  refine ⟨result,runC_join P.F (m:=191) (n:=5) run191 run5,h445,field.heap_eq heap,input445,sequence445,?_,
    fn,this,acc,fs,stack445⟩
  intro a ha below other
  exact (congrArg (fun hp => hp.get (R.a a)) heap).trans (caller440 a ha below other)
end Host.Load.Run.Full.Ordinary.VectorToConcat

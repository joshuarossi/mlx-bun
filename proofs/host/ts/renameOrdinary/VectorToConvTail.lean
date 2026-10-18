import host.ts.renameOrdinary.VectorToReturnedArray
import host.ts.renameOrdinary.ConvTailSetupPath
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated
/-- The original concat helper and next convolution call setup execute as one
continuous source path. S and the new array's owned handle survive every
intermediate allocation, store, native output write and finalizer step. -/
theorem vector_to_conv_tail (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
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
    ∃ result, runC P.F 191 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
          (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (HandleLive (ConstructorBodyLive (LiveAfter (BaseClassLive (callbackLive (initializedSlotLive (outBodyLive live))) MlxClass372.input.next) TokenObject376.input.next) MlxBody380.input.next Sources.Mlx.Array.ast_n20)) framed before after old old' ConvTailArguments439.output result ∧
      PrivateData result (R.a 3126703) (R.a HandleStore390.sourceBrand) HandleStore390.sourceName (.big (Int.ofNat (R.handle 29372))) ∧
      result.heap.get (R.a ConvInputBinding429.sourceAddress) = some (.cell (some (.obj (R.a 3126703)))) ∧
      result.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) ∧
      ∃ fn this acc fs, result.stack = .c (.args 0 fn this (natV 1::acc) convThirdRest (R.env ConvTailArguments439.sourceEnv))::fs ∧
        result.ctl = .ev convThirdExpression (R.env ConvTailArguments439.sourceEnv) := by
  obtain ⟨s428,run179,h428,field,_,caller428⟩ := vector_to_returned_array_with_caller ν₀ ν C₀ C R base boundary objects H N tail host
    live framed before after old old' s h countRole bufferRole axisRole streamRole code proto vectorSignatureFrame nullSignatureFrame
    concatSignatureFrame freeSignatureFrame firstLive secondLive functionProtoLive functionProtoFixed globalLive globalFixed
    arrayProtoLive arrayProtoFixed bufferProtoLive bufferProtoFixed typedProtoLive typedProtoFixed objectProtoFixed nodeBound nativeBound heapBound
  have sequence428 : s428.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) :=
    (caller428 _ sequenceLive (by decide +kernel)).trans sequence
  have next428 := h.heap.target_next_add h428.heap (ConcatReturn427.output.next-VectorCall.input.next) (by host_kernel_rfl)
  have deltaBound : ConcatReturn427.output.next-VectorCall.input.next ≤ 40 := by decide +kernel
  obtain ⟨result,run12,h440,inputCell,sequence440,frame440,fn,this,acc,fs,stack440,ctl440⟩ := conv_tail_setup_framed
    (NumberRoles ν₀ ν C₀ C)
    (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
      (objectWrite objects 29371 (.vec [20208,22582]))
      (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
    R C₀ C _ framed before after old old' s428 h428 sequence428 (by omega)
  have objectLive := h428.controlLive
  change treeSupport _ (Encode.ctl ConvInputDeclaration428.input.ctl) at objectLive
  rw [ConvInputDeclaration428.source_control] at objectLive
  have field440 := field.heap_at (frame440 3126703 objectLive.1 (by decide +kernel))
  exact ⟨result,runC_join P.F (m:=179) (n:=12) run179 run12,h440,field440,inputCell,sequence440,fn,this,acc,fs,stack440,ctl440⟩

theorem returned_array_live_grow (live : Nat → Prop) (a : Nat) (ha : live a) :
    (HandleLive (ConstructorBodyLive (LiveAfter (BaseClassLive (callbackLive (initializedSlotLive (outBodyLive live))) MlxClass372.input.next)
      TokenObject376.input.next) MlxBody380.input.next Sources.Mlx.Array.ast_n20)) a := by
  apply CellsLive.grow
  apply CellsLive.grow
  apply Or.inl
  apply Or.inl
  apply Or.inl
  apply Or.inl
  rw [callback_live_eq]
  exact Or.inl (Or.inl (Or.inl (Or.inl (out_body_grow live a ha))))
theorem vector_to_conv_tail_framed (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
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
    ∃ result, runC P.F 191 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
          (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (HandleLive (ConstructorBodyLive (LiveAfter (BaseClassLive (callbackLive (initializedSlotLive (outBodyLive live))) MlxClass372.input.next) TokenObject376.input.next) MlxBody380.input.next Sources.Mlx.Array.ast_n20)) framed before after old old' ConvTailArguments439.output result ∧
      PrivateData result (R.a 3126703) (R.a HandleStore390.sourceBrand) HandleStore390.sourceName (.big (Int.ofNat (R.handle 29372))) ∧
      result.heap.get (R.a ConvInputBinding429.sourceAddress) = some (.cell (some (.obj (R.a 3126703)))) ∧
      result.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) ∧
      (∀ a, live a → a < 3126665 → a ≠ ConvInputBinding429.sourceAddress → result.heap.get (R.a a) = s.heap.get (R.a a)) ∧
      ∃ fn this acc fs, result.stack = .c (.args 0 fn this (natV 1::acc) convThirdRest (R.env ConvTailArguments439.sourceEnv))::fs ∧
        result.ctl = .ev convThirdExpression (R.env ConvTailArguments439.sourceEnv) := by
  obtain ⟨s428,run179,h428,field,_,caller428⟩ := vector_to_returned_array_with_caller ν₀ ν C₀ C R base boundary objects H N tail host
    live framed before after old old' s h countRole bufferRole axisRole streamRole code proto vectorSignatureFrame nullSignatureFrame
    concatSignatureFrame freeSignatureFrame firstLive secondLive functionProtoLive functionProtoFixed globalLive globalFixed
    arrayProtoLive arrayProtoFixed bufferProtoLive bufferProtoFixed typedProtoLive typedProtoFixed objectProtoFixed nodeBound nativeBound heapBound
  have sequence428 : s428.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) :=
    (caller428 _ sequenceLive (by decide +kernel)).trans sequence
  have next428 := h.heap.target_next_add h428.heap (ConcatReturn427.output.next-VectorCall.input.next) (by host_kernel_rfl)
  have deltaBound : ConcatReturn427.output.next-VectorCall.input.next ≤ 40 := by decide +kernel
  obtain ⟨result,run12,h440,inputCell,sequence440,frame440,fn,this,acc,fs,stack440,ctl440⟩ := conv_tail_setup_framed
    (NumberRoles ν₀ ν C₀ C)
    (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
      (objectWrite objects 29371 (.vec [20208,22582]))
      (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
    R C₀ C _ framed before after old old' s428 h428 sequence428 (by omega)
  have objectLive := h428.controlLive
  change treeSupport _ (Encode.ctl ConvInputDeclaration428.input.ctl) at objectLive
  rw [ConvInputDeclaration428.source_control] at objectLive
  have field440 := field.heap_at (frame440 3126703 objectLive.1 (by decide +kernel))
  refine ⟨result,runC_join P.F (m:=179) (n:=12) run179 run12,h440,field440,inputCell,sequence440,?_,fn,this,acc,fs,stack440,ctl440⟩
  intro a ha below other
  have alive := returned_array_live_grow live a ha
  exact (frame440 a alive other).trans (caller428 a ha below)

end Host.Load.Run.Full.Ordinary.VectorToConcat

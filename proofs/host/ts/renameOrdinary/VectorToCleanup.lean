import host.ts.renameOrdinary.VectorToCleanupEntry
import host.ts.renameOrdinary.MlxConstructorCleanup
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem cleanup_vector_cell : CleanupVector419.address = VectorVariable330.address := by host_kernel_rfl

/-- The complete original vector/concat/constructor/finalizer sequence derives
both native handle roles from actual native returns and stores, preserves the
new array's owned private field, and frees the saved vector. Every intermediate
annotation and the actual cleanup-call argument are execution conclusions. -/
theorem vector_to_cleanup (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
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
    (nodeBound : s.ffi.mlx.nnext < 2^64) (nativeBound : s.ffi.mlx.next+1 < 2^64) (heapBound : s.next+40 ≤ 2^64) :
    ∃ result, runC P.F 173 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
          (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (HandleLive (ConstructorBodyLive (LiveAfter (BaseClassLive (callbackLive (initializedSlotLive (outBodyLive live))) MlxClass372.input.next) TokenObject376.input.next) MlxBody380.input.next Sources.Mlx.Array.ast_n20)) framed before after old old' FreeCall.output result ∧
      PrivateData result (R.a 3126703) (R.a HandleStore390.sourceBrand) HandleStore390.sourceName (.big (Int.ofNat (R.handle 29372))) ∧
      result.ctl = .ret (.num zeroN) := by
  have objectProtoLive : live aObjectProto := by
    obtain ⟨_,_,_,hol⟩ := h.heap.readOrdinary aGlobal SlotGlobal288.sourceObject globalLive vector_entry_global_object SlotGlobal288.source_kind
    have hp := hol.2.1
    rw [source_global_prototype] at hp
    exact hp
  obtain ⟨s371,r249,h371,handle371,vector371⟩ := vector_to_checked_return_with_vector ν₀ ν C₀ C R base boundary objects H N tail host live framed before after old old' s h countRole bufferRole axisRole streamRole code proto vectorSignatureFrame nullSignatureFrame concatSignatureFrame firstLive secondLive functionProtoLive functionProtoFixed globalLive globalFixed arrayProtoLive arrayProtoFixed bufferProtoLive bufferProtoFixed typedProtoLive typedProtoFixed nodeBound nativeBound heapBound
  have next371 : s371.next = s.next+13 := h.heap.target_next_add h371.heap 13 (by host_kernel_rfl)
  have constructorBound : s371.next+10 ≤ 2^64 := by rw [next371]; omega
  have prototypeLive : (callbackLive (initializedSlotLive (outBodyLive live))) aObjectProto := by
    rw [callback_live_eq]
    exact Or.inl (Or.inl (Or.inl (Or.inl (out_body_grow live _ objectProtoLive))))
  have vectorRole : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt s371 (R.a CleanupVector419.address)) := by
    rw [cleanup_vector_cell]
    exact vector371
  obtain ⟨result,r371,h422,field,_,ctl⟩ := construct_and_free_vector ν₀ ν C₀ C
    (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
      (objectWrite objects 29371 (.vec [20208,22582]))
      (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
    R _ framed before after old old' s371 h371 handle371 vectorRole prototypeLive objectProtoFixed freeSignatureFrame constructorBound
  exact ⟨result,runC_join P.F (m := 122) (n := 51) r249 r371,h422,field,ctl⟩
theorem vector_to_cleanup_with_caller (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
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
    (nodeBound : s.ffi.mlx.nnext < 2^64) (nativeBound : s.ffi.mlx.next+1 < 2^64) (heapBound : s.next+40 ≤ 2^64) :
    ∃ result, runC P.F 173 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
          (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (HandleLive (ConstructorBodyLive (LiveAfter (BaseClassLive (callbackLive (initializedSlotLive (outBodyLive live))) MlxClass372.input.next) TokenObject376.input.next) MlxBody380.input.next Sources.Mlx.Array.ast_n20)) framed before after old old' FreeCall.output result ∧
      PrivateData result (R.a 3126703) (R.a HandleStore390.sourceBrand) HandleStore390.sourceName (.big (Int.ofNat (R.handle 29372))) ∧
      result.ctl = .ret (.num zeroN) ∧
      (∀ a, live a → a < 3126665 → result.heap.get (R.a a) = s.heap.get (R.a a)) := by
  have objectProtoLive : live aObjectProto := by
    obtain ⟨_,_,_,hol⟩ := h.heap.readOrdinary aGlobal SlotGlobal288.sourceObject globalLive vector_entry_global_object SlotGlobal288.source_kind
    have hp := hol.2.1
    rw [source_global_prototype] at hp
    exact hp
  obtain ⟨s371,r249,h371,handle371,vector371,caller371⟩ := vector_to_checked_return_with_caller ν₀ ν C₀ C R base boundary objects H N tail host live framed before after old old' s h countRole bufferRole axisRole streamRole code proto vectorSignatureFrame nullSignatureFrame concatSignatureFrame firstLive secondLive functionProtoLive functionProtoFixed globalLive globalFixed arrayProtoLive arrayProtoFixed bufferProtoLive bufferProtoFixed typedProtoLive typedProtoFixed nodeBound nativeBound heapBound
  have next371 : s371.next = s.next+13 := h.heap.target_next_add h371.heap 13 (by host_kernel_rfl)
  have constructorBound : s371.next+10 ≤ 2^64 := by rw [next371]; omega
  have prototypeLive : (callbackLive (initializedSlotLive (outBodyLive live))) aObjectProto := by
    rw [callback_live_eq]
    exact Or.inl (Or.inl (Or.inl (Or.inl (out_body_grow live _ objectProtoLive))))
  have vectorRole : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt s371 (R.a CleanupVector419.address)) := by
    rw [cleanup_vector_cell]
    exact vector371
  obtain ⟨result,r371,h422,field,frame422,ctl⟩ := construct_and_free_vector ν₀ ν C₀ C
    (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
      (objectWrite objects 29371 (.vec [20208,22582]))
      (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
    R _ framed before after old old' s371 h371 handle371 vectorRole prototypeLive objectProtoFixed freeSignatureFrame constructorBound
  refine ⟨result,runC_join P.F (m := 122) (n := 51) r249 r371,h422,field,ctl,?_⟩
  intro a ha below
  have alive : (callbackLive (initializedSlotLive (outBodyLive live))) a := by
    rw [callback_live_eq]
    exact Or.inl (Or.inl (Or.inl (Or.inl (out_body_grow live _ ha))))
  exact (frame422 _ (h371.heap.targetBound a alive)).trans (caller371 a ha below)
end Host.Load.Run.Full.Ordinary.VectorToConcat

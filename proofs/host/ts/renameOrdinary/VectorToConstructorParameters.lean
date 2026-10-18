import host.ts.renameOrdinary.VectorToConcatFields
import host.ts.renameOrdinary.MlxConstructorPath
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated
theorem source_global_prototype : SlotGlobal288.sourceObject.proto = .obj aObjectProto := by host_kernel_rfl

/-- The original 132-step vector/concat/constructor sequence carries its owned
result into the real constructor parameter scheduler. Source AST and derived
field writes justify every intermediate role and step. -/
theorem vector_to_constructor_parameters (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
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
    (vectorSignatureFrame : ¬ framed 4411) (nullSignatureFrame : ¬ framed 4253) (concatSignatureFrame : ¬ framed 4409)
    (firstLive : H 25732) (secondLive : H 29363)
    (functionProtoLive : live aFunctionProto) (functionProtoFixed : R.a aFunctionProto = aFunctionProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (arrayProtoLive : live aArrayProto) (arrayProtoFixed : R.a aArrayProto = aArrayProto)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live 26) (typedProtoFixed : R.a 26 = 26)
    (objectProtoFixed : R.a aObjectProto = aObjectProto)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (nativeBound : s.ffi.mlx.next+1 < 2^64) (heapBound : s.next+40 ≤ 2^64) :
    ∃ result, runC P.F 132 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
          (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (ConstructorBodyLive (LiveAfter (BaseClassLive (callbackLive (initializedSlotLive (outBodyLive live))) MlxClass372.input.next) TokenObject376.input.next) MlxBody380.input.next Sources.Mlx.Array.ast_n20) framed before after old old' MlxBody380.output result ∧
      constructorParameterArgument result.stack = .big (Int.ofNat (R.handle 29372)) := by
  have objectProtoLive : live aObjectProto := by
    obtain ⟨_,_,_,hol⟩ := h.heap.readOrdinary aGlobal SlotGlobal288.sourceObject globalLive vector_entry_global_object SlotGlobal288.source_kind
    have hp := hol.2.1
    rw [source_global_prototype] at hp
    exact hp
  obtain ⟨s374,hr249,h374,arg374⟩ := vector_to_private_field_entry ν₀ ν C₀ C R base boundary objects H N tail host live framed before after old old' s h countRole bufferRole axisRole streamRole code proto vectorSignatureFrame nullSignatureFrame concatSignatureFrame firstLive secondLive functionProtoLive functionProtoFixed globalLive globalFixed arrayProtoLive arrayProtoFixed bufferProtoLive bufferProtoFixed typedProtoLive typedProtoFixed nodeBound nativeBound heapBound
  have next374 : s374.next = s.next+15 := h.heap.target_next_add h374.heap 15 (by host_kernel_rfl)
  have bodyBound : s374.next+2+(paramNames Sources.Mlx.Array.ast_n20).length ≤ 2^64 := by
    have len : (paramNames Sources.Mlx.Array.ast_n20).length = 1 := by host_kernel_rfl
    rw [next374,len]; omega
  have prototypeLive : (BaseClassLive (callbackLive (initializedSlotLive (outBodyLive live))) MlxClass372.input.next) aObjectProto := by
    unfold BaseClassLive
    apply Or.inl; apply Or.inl
    rw [callback_live_eq]
    exact Or.inl (Or.inl (Or.inl (Or.inl (out_body_grow live _ objectProtoLive))))
  obtain ⟨result,hr374,h381,arg381⟩ := initialize_and_enter_constructor ν₀ ν C₀ C
    (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
      (objectWrite objects 29371 (.vec [20208,22582]))
      (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
    R (BaseClassLive (callbackLive (initializedSlotLive (outBodyLive live))) MlxClass372.input.next) framed before after old old' s374 h374 prototypeLive objectProtoFixed bodyBound
  exact ⟨result,runC_join P.F (m := 125) (n := 7) hr249 hr374,h381,arg381.trans arg374⟩

end Host.Load.Run.Full.Ordinary.VectorToConcat

import host.mlx.OrdinaryVectorGetCut

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.VectorGet
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
noncomputable def sourceArgs : List Arg := [.jsPtr 3126927 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0),
  .big (Int.ofNat 29377),.big (Int.ofNat 0)]
noncomputable def sourceNative : LSt := Host.Load.Owned.vectorElement VectorGetCall.input.ffi 22591
noncomputable def sourcePost : Host.Ts.St LSt := finishBuffer VectorGetCall.input sourceNative 3126927 0
  VectorGetCall.bufferObject (cellParts .u64 (.big (Int.ofNat 0)) 8 0)
  (cellParts .u64 (.big (Int.ofNat 29378)) 8 0) chars!"mlx_vector_array_get" sourceArgs

theorem source_post : sourcePost = VectorGetCall.output := by host_kernel_rfl

theorem source_step : step F VectorGetCall.input = M.pure VectorGetCall.output := by
  have hk := VectorGetCall.source_kind
  rw [VectorGetCall.source_caps] at hk
  have hb : bufBytes F VectorGetCall.input 3126927 = some (cellParts .u64 (.big (Int.ofNat 0)) 8 0) :=
    bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,VectorGetCall.source_buffer]) VectorGetCall.source_buffer_kind
  have hcall : F.call VectorGetCall.input.ffi chars!"mlx_vector_array_get" sourceArgs =
      M.pure (some (sourceNative,status0,[u64Write 3126927 0 29378])) := by
    simpa only [F,sourceNative,sourceArgs,VectorGetCall.source_counter] using
      Host.Load.Owned.load_vector_get VectorGetCall.input.ffi
        (.jsPtr 3126927 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0)) 3126927 0 29377 0 22591
        [22591,22592,22593] (by rfl) VectorGetCall.source_vector rfl
  rw [step_ffi_ptr_u64_u64 F VectorGetCall.input 4684 4361 3126927 0 (Int.ofNat 29377) (Int.ofNat 0)
    chars!"mlx_vector_array_get" VectorGetCall.returns VectorGetCall.calleeObject VectorGetCall.signatureObject
    (cellParts .u64 (.big (Int.ofNat 0)) 8 0) sourceNative status0 [u64Write 3126927 0 29378]
    VectorGetCall.source_control (by simp only [Host.Ts.St.obj?,VectorGetCall.source_callee]) hk
    (by simp only [Host.Ts.St.obj?,VectorGetCall.source_signature]) VectorGetCall.source_signature_kind hb
    (by simpa only [F,sourceArgs,List.drop_zero] using hcall)]
  simp only [List.drop_zero,u64Write,← Int.ofNat_eq_natCast]
  rw [ffiDone_status0_buffer F VectorGetCall.input sourceNative 3126927 0 VectorGetCall.bufferObject
    (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat 29378)) 8 0)
    chars!"mlx_vector_array_get" _ (by simp only [Host.Ts.St.obj?,VectorGetCall.source_buffer]) VectorGetCall.source_buffer_kind]
  change M.pure sourcePost = _
  rw [source_post]

/-- The actual first output extraction retains the replayed producer 22591,
creates owned array handle 29378, and writes that handle into its real buffer. -/
theorem transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' VectorGetCall.input s)
    (handleRole : (Host.Ts.Owned.Annotated.Value.handle 29377).Holds ν C R (callArgument s.ctl 1))
    (indexRole : (Host.Ts.Owned.Annotated.Value.ordinaryBig (Int.ofNat 0)).Holds ν C R (callArgument s.ctl 2))
    (bufferRole : (Host.Ts.Owned.Annotated.fixedBufferRole VectorGetHost.nullRole).Holds ν C R (objectKindAt s (R.a 3126927)))
    (signatureFrame : ¬ framed 4361) (handleLive : H 29377) (nodeLive : N 22591)
    (targetBound : s.ffi.mlx.next < 2^64) (targetHeapBound : s.next < 2^64) :
    ∃ t, interpC (step F VectorGetCall.input).run C₀ = some (VectorGetCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects (fun a => a = 29378 ∨ H a) N tail host)
        R live framed before after old old' VectorGetCall.output t ∧
      (slotKindRole 29378).Holds ν C R (objectKindAt t (R.a 3126927)) := by
  have hk := VectorGetCall.source_kind
  rw [VectorGetCall.source_caps] at hk
  obtain ⟨t,h₀,ht,hr,hslot⟩ := VectorGetHost.from_source ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' VectorGetCall.input s h 4684 4361 3126927 29377 0 22591
    VectorGetCall.calleeObject VectorGetCall.signatureObject VectorGetCall.bufferObject VectorGetCall.returns
    (.obj 4817) [22591,22592,22593] VectorGetCall.source_control VectorGetCall.source_callee hk
    VectorGetCall.source_signature VectorGetCall.source_signature_kind VectorGetCall.source_buffer VectorGetCall.source_buffer_kind
    signatureFrame handleLive nodeLive VectorGetCall.source_vector rfl
    (by rw [VectorGetCall.source_counter]; decide +kernel) targetBound (by decide +kernel) targetHeapBound handleRole indexRole bufferRole
  rw [VectorGetCall.source_counter] at hr hslot
  change StateR _ _ _ _ _ _ _ _ _ sourcePost t at hr
  rw [source_post] at hr
  refine ⟨t,?_,by simpa only [F,Host.Load.ffi] using ht,hr,hslot⟩
  rw [source_step]; rfl

end Host.Load.Run.Full.Ordinary.VectorGet

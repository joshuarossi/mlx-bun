import host.mlx.OrdinaryVectorSizeCut

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.VectorSize
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
noncomputable def sourcePost : Host.Ts.St LSt := finishBig VectorSizeCall.input VectorSizeCall.input.ffi
  chars!"mlx_vector_array_size" [.big (Int.ofNat 29377)] (Int.ofNat 3)

theorem source_post : sourcePost = VectorSizeCall.output := by host_kernel_rfl

theorem source_step : step F VectorSizeCall.input = M.pure VectorSizeCall.output := by
  have hk := VectorSizeCall.source_kind
  rw [VectorSizeCall.source_caps] at hk
  have hcall : F.call VectorSizeCall.input.ffi chars!"mlx_vector_array_size" [.big (Int.ofNat 29377)] =
      M.pure (some (VectorSizeCall.input.ffi,.big (Int.ofNat 3),[])) := by
    simpa only [F,len,lenL] using Host.Load.Owned.load_vector_size VectorSizeCall.input.ffi 29377
      [22591,22592,22593] VectorSizeCall.source_vector
  rw [step_ffi_one_u64 F VectorSizeCall.input 4789 4571 (Int.ofNat 29377) chars!"mlx_vector_array_size"
    VectorSizeCall.returns VectorSizeCall.calleeObject VectorSizeCall.signatureObject (.obj 4817)
    VectorSizeCall.input.ffi (.big (Int.ofNat 3)) VectorSizeCall.source_control
    (by simp only [Host.Ts.St.obj?,VectorSizeCall.source_callee]) hk
    (by simp only [Host.Ts.St.obj?,VectorSizeCall.source_signature]) VectorSizeCall.source_signature_kind hcall,
    ffiDone_big_empty]
  change M.pure sourcePost = _
  rw [source_post]

/-- The real post-replay size read returns the exact ordinary integer three
and frames all fixed native node and object annotations. -/
theorem transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' VectorSizeCall.input s)
    (handleRole : (Host.Ts.Owned.Annotated.Value.handle 29377).Holds ν C R (callArgument s.ctl 0))
    (signatureFrame : ¬ framed 4571) (handleLive : H 29377) :
    ∃ t, interpC (step F VectorSizeCall.input).run C₀ = some (VectorSizeCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
        R live framed before after old old' VectorSizeCall.output t ∧
      t.ctl = .ret (.big (Int.ofNat 3)) := by
  have hk := VectorSizeCall.source_kind
  rw [VectorSizeCall.source_caps] at hk
  obtain ⟨h₀,ht,hr⟩ := VectorSizeHost.from_source ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' VectorSizeCall.input s h 4789 4571 29377 VectorSizeCall.calleeObject
    VectorSizeCall.signatureObject VectorSizeCall.returns (.obj 4817) [22591,22592,22593] VectorSizeCall.source_control
    VectorSizeCall.source_callee hk VectorSizeCall.source_signature VectorSizeCall.source_signature_kind signatureFrame
    handleLive VectorSizeCall.source_vector handleRole
  change StateR _ _ _ _ _ _ _ _ _ sourcePost _ at hr
  rw [source_post] at hr
  exact ⟨_,by simpa only [F,Host.Load.ffi,← source_post,sourcePost,len,lenL] using h₀,
    by simpa only [F,Host.Load.ffi,len,lenL] using ht,hr,rfl⟩

end Host.Load.Run.Full.Ordinary.VectorSize

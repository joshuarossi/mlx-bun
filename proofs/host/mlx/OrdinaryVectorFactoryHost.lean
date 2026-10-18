import host.mlx.OrdinaryVectorFactoryCut

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.VectorFactory
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
noncomputable def sourcePost : Host.Ts.St LSt := finishBig VectorFactoryCall.input
  (Host.Load.Owned.newVector VectorFactoryCall.input.ffi) chars!"mlx_vector_array_new" []
  (Int.ofNat VectorFactoryCall.input.ffi.mlx.next)

theorem source_post : sourcePost = VectorFactoryCall.output := by host_kernel_rfl

theorem source_step : step F VectorFactoryCall.input = M.pure VectorFactoryCall.output := by
  have hk := VectorFactoryCall.source_kind
  rw [VectorFactoryCall.source_caps] at hk
  have hcall : F.call VectorFactoryCall.input.ffi chars!"mlx_vector_array_new" [] =
      M.pure (some (Host.Load.Owned.newVector VectorFactoryCall.input.ffi,.big (Int.ofNat VectorFactoryCall.input.ffi.mlx.next),[])) := by
    simpa only [F] using Host.Load.Owned.load_vector_new VectorFactoryCall.input.ffi
  rw [step_ffi_noargs F VectorFactoryCall.input 4685 4363 chars!"mlx_vector_array_new" VectorFactoryCall.returns
    VectorFactoryCall.calleeObject VectorFactoryCall.signatureObject (Host.Load.Owned.newVector VectorFactoryCall.input.ffi)
    (.big (Int.ofNat VectorFactoryCall.input.ffi.mlx.next)) [] VectorFactoryCall.source_control
    (by simp only [Host.Ts.St.obj?,VectorFactoryCall.source_callee]) hk
    (by simp only [Host.Ts.St.obj?,VectorFactoryCall.source_signature]) VectorFactoryCall.source_signature_kind hcall,
    ffiDone_big_empty]
  change M.pure sourcePost = _
  rw [source_post]

/-- Actual rest2350 creates the empty output vector subsequently consumed by
the checked compiled-closure application. Its fresh payload annotation is kept. -/
theorem transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' VectorFactoryCall.input s)
    (signatureFrame : ¬ framed 4363) (targetBound : s.ffi.mlx.next < 2^64) :
    ∃ t, interpC (step F VectorFactoryCall.input).run C₀ = some (VectorFactoryCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary (objectWrite objects 29377 (.vec []))
          (fun a => a = 29377 ∨ H a) N tail host)
        R live framed before after old old' VectorFactoryCall.output t ∧
      t.ctl = .ret (.big (Int.ofNat (R.handle 29377))) := by
  have hk := VectorFactoryCall.source_kind
  rw [VectorFactoryCall.source_caps] at hk
  obtain ⟨h₀,ht,hr⟩ := VectorFactoryHost.from_source ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' VectorFactoryCall.input s h 4685 4363 VectorFactoryCall.calleeObject
    VectorFactoryCall.signatureObject VectorFactoryCall.returns (.obj 4817) VectorFactoryCall.source_control
    VectorFactoryCall.source_callee hk VectorFactoryCall.source_signature VectorFactoryCall.source_signature_kind
    signatureFrame (by rw [VectorFactoryCall.source_counter]; decide +kernel) targetBound
  change StateR _ _ _ _ _ _ _ _ _ sourcePost _ at hr
  rw [source_post] at hr
  have nextMapped : s.ffi.mlx.next = R.handle 29377 := by
    have hh := h.native.2.handleMap.head
    rw [VectorFactoryCall.source_counter] at hh
    exact hh.symm
  refine ⟨_,by simpa only [F,Host.Load.ffi,← source_post,sourcePost] using h₀,
    by simpa only [F,Host.Load.ffi] using ht,?_,?_⟩
  · simpa only [VectorFactoryCall.source_counter] using hr
  · change Ctl.ret (.big (Int.ofNat s.ffi.mlx.next)) = _
    rw [nextMapped]

end Host.Load.Run.Full.Ordinary.VectorFactory

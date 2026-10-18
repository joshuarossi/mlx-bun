import host.mlx.OrdinaryArrayFreeCut

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.ArrayFree
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
noncomputable def sourcePost : Host.Ts.St LSt := finishStatus ArrayFreeCall.input
  (Host.Load.Owned.freeArray ArrayFreeCall.input.ffi 29372) chars!"mlx_array_free" [.big (Int.ofNat 29372)]

theorem source_post : sourcePost = ArrayFreeCall.output := by host_kernel_rfl

theorem source_step : step F ArrayFreeCall.input = M.pure ArrayFreeCall.output := by
  have hk := ArrayFreeCall.source_kind
  rw [ArrayFreeCall.source_caps] at hk
  have hcall : F.call ArrayFreeCall.input.ffi chars!"mlx_array_free" [.big (Int.ofNat 29372)] =
      M.pure (some (Host.Load.Owned.freeArray ArrayFreeCall.input.ffi 29372,status0,[])) := by
    simpa only [F] using Host.Load.Owned.load_array_free ArrayFreeCall.input.ffi 29372
  rw [step_ffi_one_u64 F ArrayFreeCall.input 4633 4259 (Int.ofNat 29372) chars!"mlx_array_free" ArrayFreeCall.returns
    ArrayFreeCall.calleeObject ArrayFreeCall.signatureObject (.obj 4817) (Host.Load.Owned.freeArray ArrayFreeCall.input.ffi 29372)
    status0 ArrayFreeCall.source_control (by simp only [Host.Ts.St.obj?,ArrayFreeCall.source_callee]) hk
    (by simp only [Host.Ts.St.obj?,ArrayFreeCall.source_signature]) ArrayFreeCall.source_signature_kind hcall,
    ffiDone_status0_empty]
  change M.pure sourcePost = _
  rw [source_post]

/-- Actual rest1978 releases the old convolution carrier. Its graph is framed,
and all other live resources retain their fixed indexed roles. -/
theorem transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' ArrayFreeCall.input s)
    (role : (Host.Ts.Owned.Annotated.Value.handle 29372).Holds ν C R (callArgument s.ctl 0))
    (signatureFrame : ¬ framed 4259) (handleLive : H 29372) (targetBound : s.ffi.mlx.next < 2^64) :
    ∃ t, interpC (step F ArrayFreeCall.input).run C₀ = some (ArrayFreeCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects (fun b => H b ∧ b ≠ 29372) N tail host)
        R live framed before after old old' ArrayFreeCall.output t ∧
      t.ctl = .ret (.num zeroN) := by
  have hk := ArrayFreeCall.source_kind
  rw [ArrayFreeCall.source_caps] at hk
  obtain ⟨h₀,ht,hr⟩ := ArrayFreeHost.from_source ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' ArrayFreeCall.input s h 4633 4259 29372 ArrayFreeCall.calleeObject
    ArrayFreeCall.signatureObject ArrayFreeCall.returns (.obj 4817) ArrayFreeCall.source_control ArrayFreeCall.source_callee
    hk ArrayFreeCall.source_signature ArrayFreeCall.source_signature_kind signatureFrame handleLive
    (by decide +kernel) (by decide +kernel) targetBound role
  change StateR _ _ _ _ _ _ _ _ _ sourcePost _ at hr
  rw [source_post] at hr
  exact ⟨_,by simpa only [F,Host.Load.ffi,← source_post,sourcePost] using h₀,
    by simpa only [F,Host.Load.ffi] using ht,hr,rfl⟩

end Host.Load.Run.Full.Ordinary.ArrayFree

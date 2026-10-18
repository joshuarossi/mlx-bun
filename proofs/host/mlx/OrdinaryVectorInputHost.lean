import host.mlx.OrdinaryVectorInputCut

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.VectorInput
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
noncomputable def sourcePost : Host.Ts.St LSt := finishBig VectorInputCall.input
  (VectorDataHost.resultWorld VectorInputCall.input.ffi VectorInputCall.nodes) chars!"mlx_vector_array_new_data"
  [.jsPtr 3126910 0 (VectorBuffer.bytes VectorInputCall.handles),.big (Int.ofNat VectorInputCall.handles.length)]
  (Int.ofNat VectorInputCall.input.ffi.mlx.next)

theorem source_post : sourcePost = VectorInputCall.output := by host_kernel_rfl

theorem source_step : step F VectorInputCall.input = M.pure VectorInputCall.output := by
  have hk := VectorInputCall.source_kind
  rw [VectorInputCall.source_caps] at hk
  have hbKind := VectorInputCall.source_buffer_kind
  rw [VectorInputCall.source_bytes] at hbKind
  have hb : bufBytes F VectorInputCall.input 3126910 = some (VectorBuffer.bytes VectorInputCall.handles) :=
    bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,VectorInputCall.source_buffer]) hbKind
  have native := call_vector_data VectorInputCall.input.ffi.mlx
    (.jsPtr 3126910 0 (VectorBuffer.bytes VectorInputCall.handles)) (.big (Int.ofNat VectorInputCall.handles.length))
    VectorInputCall.handles VectorInputCall.nodes (VectorBuffer.handles _ _ _) VectorInputCall.source_nodes
  have hcall : F.call VectorInputCall.input.ffi chars!"mlx_vector_array_new_data"
      [.jsPtr 3126910 0 ((VectorBuffer.bytes VectorInputCall.handles).drop 0),.big (Int.ofNat VectorInputCall.handles.length)] =
      M.pure (some (VectorDataHost.resultWorld VectorInputCall.input.ffi VectorInputCall.nodes,
        .big (Int.ofNat VectorInputCall.input.ffi.mlx.next),[])) := by
    simpa only [F,VectorDataHost.resultWorld,List.drop_zero] using VectorHost.load_vector_call VectorInputCall.input.ffi _ _ _ native
  rw [step_ffi_ptr_u64 F VectorInputCall.input 4709 4411 3126910 0 (Int.ofNat VectorInputCall.handles.length)
    chars!"mlx_vector_array_new_data" VectorInputCall.returns VectorInputCall.calleeObject VectorInputCall.signatureObject _
    (VectorDataHost.resultWorld VectorInputCall.input.ffi VectorInputCall.nodes) (.big (Int.ofNat VectorInputCall.input.ffi.mlx.next)) []
    VectorInputCall.source_control (by simp only [Host.Ts.St.obj?,VectorInputCall.source_callee]) hk
    (by simp only [Host.Ts.St.obj?,VectorInputCall.source_signature]) VectorInputCall.source_signature_kind hb hcall,
    ffiDone_big_empty]
  change M.pure sourcePost = _
  rw [source_post]

/-- Actual rest2336 makes the compiled call's ordered input vector from the
fresh convolution result and the two loaded parameter arrays. -/
theorem transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' VectorInputCall.input s)
    (countRole : (Host.Ts.Owned.Annotated.Value.ordinaryBig (Int.ofNat 3)).Holds ν C R (callArgument s.ctl 1))
    (bufferRole : (VectorBuffer.role VectorInputCall.handles).Holds ν C R (objectKindAt s (R.a 3126910)))
    (signatureFrame : ¬ framed 4411) (convolutionLive : H 29375) (firstParameterLive : H 40) (secondParameterLive : H 41)
    (targetBound : s.ffi.mlx.next < 2^64) :
    ∃ t, interpC (step F VectorInputCall.input).run C₀ = some (VectorInputCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary (objectWrite objects 29376 (.vec [22590,10,11]))
          (fun a => a = 29376 ∨ H a) N tail host)
        R live framed before after old old' VectorInputCall.output t ∧
      t.ctl = .ret (.big (Int.ofNat (R.handle 29376))) := by
  have hk := VectorInputCall.source_kind
  rw [VectorInputCall.source_caps] at hk
  have hbKind := VectorInputCall.source_buffer_kind
  rw [VectorInputCall.source_bytes] at hbKind
  obtain ⟨h₀,ht,hr⟩ := VectorDataHost.from_source ν₀ ν C₀ C R roles boundary objects H N tail host
    live framed before after old old' VectorInputCall.input s h 4709 4411 3126910 VectorInputCall.calleeObject
    VectorInputCall.signatureObject VectorInputCall.bufferObject VectorInputCall.returns (.obj 4817)
    VectorInputCall.handles VectorInputCall.nodes VectorInputCall.source_control VectorInputCall.source_callee hk
    VectorInputCall.source_signature VectorInputCall.source_signature_kind VectorInputCall.source_buffer hbKind signatureFrame
    ⟨convolutionLive,firstParameterLive,secondParameterLive,True.intro⟩ VectorInputCall.source_nodes
    (by rw [VectorInputCall.source_counter]; decide +kernel) targetBound countRole bufferRole
  change StateR _ _ _ _ _ _ _ _ _ sourcePost _ at hr
  rw [source_post] at hr
  have nextMapped : s.ffi.mlx.next = R.handle 29376 := by
    have hh := h.native.2.handleMap.head
    rw [VectorInputCall.source_counter] at hh
    exact hh.symm
  refine ⟨_,by simpa only [F,Host.Load.ffi,← source_post,sourcePost] using h₀,
    by simpa only [F,Host.Load.ffi] using ht,?_,?_⟩
  · simpa only [VectorInputCall.source_counter,VectorInputCall.nodes] using hr
  · change Ctl.ret (.big (Int.ofNat s.ffi.mlx.next)) = _
    rw [nextMapped]

end Host.Load.Run.Full.Ordinary.VectorInput

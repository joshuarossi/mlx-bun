import host.mlx.OrdinarySigmoidCut

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.Sigmoid
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
noncomputable def sourceArgs : List Arg := [.jsPtr 3127013 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0),
  .big (Int.ofNat 29369),.big (Int.ofNat 2)]
noncomputable def sourceNative : LSt := Host.Load.Owned.unaryWorld SigmoidCall.input.ffi chars!"mlx_sigmoid" 22585 SigmoidCall.inputNode
noncomputable def sourcePost : Host.Ts.St LSt := finishBuffer SigmoidCall.input sourceNative 3127013 0
  SigmoidCall.bufferObject (cellParts .u64 (.big (Int.ofNat 0)) 8 0)
  (cellParts .u64 (.big (Int.ofNat 29381)) 8 0) chars!"mlx_sigmoid" sourceArgs

theorem source_post : sourcePost = SigmoidCall.output := by host_kernel_rfl

theorem source_step : step F SigmoidCall.input = M.pure SigmoidCall.output := by
  have hk := SigmoidCall.source_kind
  rw [SigmoidCall.source_caps] at hk
  have hb : bufBytes F SigmoidCall.input 3127013 = some (cellParts .u64 (.big (Int.ofNat 0)) 8 0) :=
    bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,SigmoidCall.source_buffer]) SigmoidCall.source_buffer_kind
  have hs : symOf chars!"mlx_sigmoid" = some .unary := by decide +kernel
  have hm : isMlx chars!"mlx_sigmoid" = true := by decide +kernel
  have native := call_unary_null SigmoidCall.input.ffi.mlx chars!"mlx_sigmoid"
    (.jsPtr 3127013 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0)) (.big (Int.ofNat 2))
    3127013 0 29369 22585 SigmoidCall.inputNode hs SigmoidCall.source_input SigmoidCall.source_node (by rfl)
  have hcall : F.call SigmoidCall.input.ffi chars!"mlx_sigmoid" sourceArgs =
      M.pure (some (sourceNative,status0,[u64Write 3127013 0 29381])) := by
    simpa only [F,sourceNative,Host.Load.Owned.unaryWorld,sourceArgs,SigmoidCall.source_counter] using
      Host.Load.Owned.load_unary_call SigmoidCall.input.ffi chars!"mlx_sigmoid" _ _ _ hm native
  rw [step_ffi_ptr_u64_u64 F SigmoidCall.input 4700 4393 3127013 0 (Int.ofNat 29369) (Int.ofNat 2)
    chars!"mlx_sigmoid" SigmoidCall.returns SigmoidCall.calleeObject SigmoidCall.signatureObject
    (cellParts .u64 (.big (Int.ofNat 0)) 8 0) sourceNative status0 [u64Write 3127013 0 29381]
    SigmoidCall.source_control (by simp only [Host.Ts.St.obj?,SigmoidCall.source_callee]) hk
    (by simp only [Host.Ts.St.obj?,SigmoidCall.source_signature]) SigmoidCall.source_signature_kind hb
    (by simpa only [F,sourceArgs,List.drop_zero] using hcall)]
  simp only [List.drop_zero,u64Write,← Int.ofNat_eq_natCast]
  rw [ffiDone_status0_buffer F SigmoidCall.input sourceNative 3127013 0 SigmoidCall.bufferObject
    (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat 29381)) 8 0)
    chars!"mlx_sigmoid" _ (by simp only [Host.Ts.St.obj?,SigmoidCall.source_buffer]) SigmoidCall.source_buffer_kind]
  change M.pure sourcePost = _
  rw [source_post]

/-- The actual ordinary sigmoid call keeps the selected input dimension
meanings and extends the annotated graph by its original unary node. -/
theorem transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' SigmoidCall.input s)
    (handleRole : (Host.Ts.Owned.Annotated.Value.handle 29369).Holds ν C R (callArgument s.ctl 1))
    (streamRole : (Host.Ts.Owned.Annotated.Value.handle 2).Holds ν C R (callArgument s.ctl 2))
    (bufferRole : (Host.Ts.Owned.Annotated.fixedBufferRole VectorGetHost.nullRole).Holds ν C R (objectKindAt s (R.a 3127013)))
    (signatureFrame : ¬ framed 4393) (handleLive : H 29369)
    (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) (targetHeapBound : s.next < 2^64) :
    ∃ t, interpC (step F SigmoidCall.input).run C₀ = some (SigmoidCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (nodeWrite nodes 22594 (unaryRole nodes chars!"mlx_sigmoid" 22585)) boundary objects
          (fun a => a = 29381 ∨ H a) (fun i => i = 22594 ∨ N i) tail host)
        R live framed before after old old' SigmoidCall.output t ∧
      (slotKindRole 29381).Holds ν C R (objectKindAt t (R.a 3127013)) := by
  have hk := SigmoidCall.source_kind
  rw [SigmoidCall.source_caps] at hk
  obtain ⟨t,h₀,ht,hr,hslot,_,_,_,_⟩ := UnaryHost.from_source ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' SigmoidCall.input s h chars!"mlx_sigmoid" 4700 4393 3127013 29369 2 22585
    SigmoidCall.inputNode SigmoidCall.calleeObject SigmoidCall.signatureObject SigmoidCall.bufferObject SigmoidCall.returns
    (.obj 4817) (by decide +kernel) (by decide +kernel) SigmoidCall.source_control SigmoidCall.source_callee hk
    SigmoidCall.source_signature SigmoidCall.source_signature_kind SigmoidCall.source_buffer SigmoidCall.source_buffer_kind
    signatureFrame handleLive SigmoidCall.source_input SigmoidCall.source_node
    (by rw [SigmoidCall.source_node_counter]; decide +kernel) targetNodes
    (by rw [SigmoidCall.source_counter]; decide +kernel) targetHandles
    (by decide +kernel) targetHeapBound handleRole streamRole bufferRole
  rw [SigmoidCall.source_counter,SigmoidCall.source_node_counter] at hr
  rw [SigmoidCall.source_counter] at hslot
  change StateR _ _ _ _ _ _ _ _ _ sourcePost t at hr
  rw [source_post] at hr
  refine ⟨t,?_,by simpa only [F,Host.Load.ffi] using ht,hr,hslot⟩
  rw [source_step]; rfl

end Host.Load.Run.Full.Ordinary.Sigmoid

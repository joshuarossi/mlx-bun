import host.mlx.OrdinaryMetalNative
import host.mlx.FixedNativeRoles
import host.mlx.OrdinaryVectorHost
import host.ts.RenameParametricRankNative

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.MetalHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
def signature : List Val := [.str chars!"ptr",.str chars!"u64",.str chars!"u64",.str chars!"u64",.str chars!"u64"]
def argumentRoles : List Host.Ts.Owned.Annotated.FixedArgument := [.pointer 3127256 0,.handle 18215,.handle 29387,.handle 29386,.handle 2]
noncomputable def sourceNative : LSt := {MetalCall.input.ffi with mlx := MetalNative.final}
noncomputable def sourcePost : Host.Ts.St LSt := finishBuffer MetalCall.input sourceNative 3127256 0 MetalCall.bufferObject
  (cellParts .u64 (.big (Int.ofNat 29388)) 8 0) (cellParts .u64 (.big (Int.ofNat 29388)) 8 0)
  chars!"mlx_fast_metal_kernel_apply" MetalNative.sourceArgs

theorem source_post : sourcePost = MetalCall.output := by host_kernel_rfl

theorem load_metal_call (s : LSt) (args : List Arg) (native : Host.Mlx.Ffi.St) (ws : List (Nat × Nat × List Byte))
    (hc : Host.Mlx.Ffi.call s.mlx chars!"mlx_fast_metal_kernel_apply" args = okW native status0 ws) :
    Host.Load.call s chars!"mlx_fast_metal_kernel_apply" args = M.pure (some ({s with mlx := native},status0,ws)) := by
  have hm : isMlx chars!"mlx_fast_metal_kernel_apply" = true := by decide +kernel
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,hc,okW,M.bind,M.pure]

theorem decode_metal (F : Ffi) (s : Host.Ts.St F.S) (b : Nat) (kh inv cfg stream : Int) (bytes : List Byte)
    (hb : bufBytes F s b = some bytes) :
    decodeArgs F s signature [.ptr (.js b) 0,.big kh,.big inv,.big cfg,.big stream] =
      M.pure (some [.jsPtr b 0 bytes,.big kh,.big inv,.big cfg,.big stream]) := by
  simpa only [signature,List.drop_zero] using decodeArgs_ptr_u64_tail F s b 0 kh bytes _ _ _ hb
    (decodeArgs_u64_tail F s inv _ _ _ (decodeArgs_u64_tail F s cfg _ _ _ (decodeArgs_one_u64 F s stream)))

theorem source_step : step F MetalCall.input = M.pure MetalCall.output := by
  have hk := MetalCall.source_kind
  rw [MetalCall.source_caps] at hk
  have hb : bufBytes F MetalCall.input 3127256 = some (cellParts .u64 (.big (Int.ofNat 29388)) 8 0) :=
    bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,MetalCall.source_buffer]) MetalCall.source_buffer_kind
  have hcall : F.call MetalCall.input.ffi chars!"mlx_fast_metal_kernel_apply" MetalNative.sourceArgs =
      M.pure (some (sourceNative,status0,[u64Write 3127256 0 29388])) := by
    simpa only [F,sourceNative,MetalCall.native] using load_metal_call MetalCall.input.ffi _ _ _ MetalNative.source_native_call
  rw [step_ffi_decoded F MetalCall.input 4798 4589 chars!"mlx_fast_metal_kernel_apply" MetalCall.returns
    MetalCall.calleeObject MetalCall.signatureObject (.obj 4817) signature _ MetalNative.sourceArgs sourceNative status0
    [u64Write 3127256 0 29388] MetalCall.source_control (by simp only [Host.Ts.St.obj?,MetalCall.source_callee]) hk
    (by simp only [Host.Ts.St.obj?,MetalCall.source_signature]) MetalCall.source_signature_kind
    (decode_metal F MetalCall.input 3127256 (Int.ofNat 18215) (Int.ofNat 29387) (Int.ofNat 29386) (Int.ofNat 2) _ hb) hcall]
  simp only [u64Write,← Int.ofNat_eq_natCast]
  rw [ffiDone_status0_buffer F MetalCall.input sourceNative 3127256 0 MetalCall.bufferObject
    (cellParts .u64 (.big (Int.ofNat 29388)) 8 0) (cellParts .u64 (.big (Int.ofNat 29388)) 8 0)
    chars!"mlx_fast_metal_kernel_apply" _ (by simp only [Host.Ts.St.obj?,MetalCall.source_buffer]) MetalCall.source_buffer_kind]
  change M.pure sourcePost = _
  rw [source_post]

/-- The real ordinary Metal host call, with target reads, output graph and
buffer write derived from its source facts and fixed configuration role. -/
theorem transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object) (configRole : Config)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' MetalCall.input s)
    (arguments : ListR (fun r v => r.role.Holds ν C R v) argumentRoles (callArguments s.ctl))
    (slotRole : (slotKindRole 29388).Holds ν C R (objectKindAt s (R.a 3127256)))
    (signatureFrame : ¬ framed 4589) (kernelLive : H 18215) (inputsLive : H 29387) (configLive : H 29386) (outputLive : H 29388)
    (fixedConfig : objects 29386 = .config configRole)
    (targetNodes : s.ffi.mlx.nnext + configRole.outs.length < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (targetHeap : s.next < 2^64) :
    ∃ K t, interpC (step F MetalCall.input).run C₀ = some (MetalCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C
          (kernelOutputRoles roles 18215 MetalCall.inputs configRole 22603 0 configRole.outs) boundary
          (objectWrite objects 29388 (.vec [22603,22604])) H K tail host)
        R live framed before after old old' MetalCall.output t ∧
      (slotKindRole 29388).Holds ν C R (objectKindAt t (R.a 3127256)) := by
  have hk := MetalCall.source_kind
  rw [MetalCall.source_caps] at hk
  have calleeLive : live 4798 := by have hl := h.controlLive; rw [MetalCall.source_control] at hl; exact hl.1
  have bufferLive : live 3127256 := by have hl := h.controlLive; rw [MetalCall.source_control] at hl; exact hl.2.2.1.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject 4798 MetalCall.calleeObject calleeLive
    (h.heap.function_notFramed 4798 MetalCall.calleeObject _ calleeLive MetalCall.source_callee hk) MetalCall.source_callee
  have signatureLive : live 4589 := by have hl := hol.1; rw [hk] at hl; exact hl.1.2.1.2.1
  obtain ⟨fo,data,this,args,hc,hfo,hfk,hd,_,_⟩ := h.native_call_view 4798 MetalCall.calleeObject (.ffi .symbol) _
    (.obj 4817) _ MetalCall.source_control MetalCall.source_callee hk
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr
        have exactArgs := Host.Ts.Owned.Annotated.FixedArgument.list_exact argumentRoles arguments
        simp only [hc,callArguments] at exactArgs
        rw [exactArgs] at hc
        dsimp only [argumentRoles,Host.Ts.Owned.Annotated.FixedArgument.value,List.map_cons,List.map_nil] at hc
        obtain ⟨signatureObj,hsig,hsigr,_⟩ := h.heap.readObject 4589 MetalCall.signatureObject signatureLive signatureFrame MetalCall.source_signature
        have hsKind := hsigr.kind
        rw [MetalCall.source_signature_kind] at hsKind
        obtain ⟨tys,hsKind,htys⟩ := kind_array hsKind
        have exactTypes := string_values_exact [chars!"ptr",chars!"u64",chars!"u64",chars!"u64",chars!"u64"] htys
        rw [exactTypes] at hsKind
        obtain ⟨out,ho,hro,hlo⟩ := h.heap.readObject 3127256 MetalCall.bufferObject bufferLive
          (h.heap.buffer_notFramed 3127256 MetalCall.bufferObject _ bufferLive MetalCall.source_buffer MetalCall.source_buffer_kind)
          MetalCall.source_buffer
        have hbKind := hro.kind
        rw [MetalCall.source_buffer_kind] at hbKind
        obtain ⟨bytes,hbKind,hbytes⟩ := kind_buffer hbKind
        have hslot : (slotKindRole 29388).Holds ν C R (Encode.kind out.kind) := by
          simpa only [objectKindAt,Host.Ts.St.obj?,ho] using slotRole
        have exactBytes := Kind.buf.inj (hbKind.symm.trans (slot_kind_exact hslot))
        subst bytes
        have native := h.native.2
        change Live _ R _ _ H N tail MetalCall.native s.ffi.mlx at native
        obtain ⟨c',K,hnative,hl,_,_,_⟩ := MetalNative.transport roles boundary objects configRole native
          kernelLive inputsLive configLive outputLive fixedConfig targetNodes targetHandles
        let result' := kernelApply.outs (R.handle 18215) (MetalCall.inputs.map R.node) c' s.ffi.mlx 0 c'.outs
        let native' : LSt := {s.ffi with mlx := result'.1.setObj (R.handle 29388) (.vec result'.2)}
        have nativeRelated : VectorHost.NativeRelation ν₀ ν C₀ C
            (kernelOutputRoles roles 18215 MetalCall.inputs configRole 22603 0 configRole.outs) boundary
            (objectWrite objects 29388 (.vec [22603,22604])) H K tail host R sourceNative native' :=
          ⟨h.native.1,hl⟩
        let bs' := cellParts .u64 (.big (Int.ofNat (R.handle 29388))) 8 0
        let t := finishBuffer s native' (R.a 3127256) 0 out bs' bs' chars!"mlx_fast_metal_kernel_apply" (MetalNative.targetArgs R)
        have hz : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
        have argsRelated : ForestR (NumberRoles ν₀ ν C₀ C) R
            (MetalNative.sourceArgs.map Parametric.arg) ((MetalNative.targetArgs R).map Parametric.arg) :=
          .cons (.node _ (.cons (.address 3127256) (.cons (.atom _ _) (.cons (bytes_roles hbytes) .nil))))
            (.cons (.node _ (.cons (.value (.handle 18215)) .nil))
            (.cons (.node _ (.cons (.value (.handle 29387)) .nil))
            (.cons (.node _ (.cons (.value (.handle 29386)) .nil))
            (.cons (.node _ (.cons (.value (.handle 2)) .nil)) .nil))))
        have hevent : TreeR (NumberRoles ν₀ ν C₀ C) R
            (event ⟨chars!"mlx_fast_metal_kernel_apply",MetalNative.sourceArgs,status0⟩)
            (event ⟨chars!"mlx_fast_metal_kernel_apply",MetalNative.targetArgs R,status0⟩) :=
          .node _ (.cons (.atom _ _) (.cons (.node _ argsRelated) (.cons (.node _ (.cons (.number hz) .nil)) .nil)))
        have heapBound := Nat.lt_trans (h.heap.targetBound _ bufferLive) targetHeap
        have hpost := h.finishBuffer_event sourceNative native' nativeRelated 3127256 0 MetalCall.bufferObject out
          (cellParts .u64 (.big (Int.ofNat 29388)) 8 0) bs' (cellParts .u64 (.big (Int.ofNat 29388)) 8 0) bs'
          chars!"mlx_fast_metal_kernel_apply" MetalNative.sourceArgs (MetalNative.targetArgs R) bufferLive
          MetalCall.source_buffer MetalCall.source_buffer_kind hro hlo hbytes hbytes (by decide +kernel) heapBound hz hevent
        have hb : bufBytes F s (R.a 3127256) = some bs' :=
          bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,ho]) hbKind
        have hcall : F.call s.ffi chars!"mlx_fast_metal_kernel_apply" (MetalNative.targetArgs R) =
            M.pure (some (native',status0,[u64Write (R.a 3127256) 0 (R.handle 29388)])) := by
          simpa only [F,native',result'] using load_metal_call s.ffi _ _ _ hnative
        refine ⟨K,t,?_,?_,?_,?_⟩
        · rw [source_step]; rfl
        · rw [step_ffi_decoded F s (R.a 4798) (R.a 4589) chars!"mlx_fast_metal_kernel_apply" MetalCall.returns fo signatureObj this
            signature _ (MetalNative.targetArgs R) native' status0 [u64Write (R.a 3127256) 0 (R.handle 29388)] hc
            (by simp only [Host.Ts.St.obj?,hfo]) hfk (by simp only [Host.Ts.St.obj?,hsig]) hsKind
            (decode_metal F s (R.a 3127256) (Int.ofNat (R.handle 18215)) (Int.ofNat (R.handle 29387))
              (Int.ofNat (R.handle 29386)) (Int.ofNat (R.handle 2)) _ hb) hcall]
          simp only [u64Write,← Int.ofNat_eq_natCast]
          rw [ffiDone_status0_buffer F s native' (R.a 3127256) 0 out bs' bs' chars!"mlx_fast_metal_kernel_apply" _
            (by simp only [Host.Ts.St.obj?,ho]) hbKind]
          rfl
        · change StateR _ _ _ _ _ _ _ _ _ sourcePost t at hpost
          rw [source_post] at hpost
          exact hpost
        · exact finishBuffer_slot_role ν C R s native' 3127256 29388 out chars!"mlx_fast_metal_kernel_apply" _ heapBound

end Host.Load.Run.Full.Ordinary.MetalHost

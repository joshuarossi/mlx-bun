import host.mlx.NativeSymbol
import host.mlx.OrdinaryCachedWitness

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro23 82 4557 as Ordinary.CachedHost.signatureObject
host_transport_object P.RestStream.micro0.micro23 82 3126924 as Ordinary.CachedHost.bufferObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.CachedHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩

noncomputable def input : Host.Ts.St LSt := NativeCall.input
noncomputable def output : Host.Ts.St LSt := NativeCall.output

theorem source_control : input.ctl = .call (.obj 4782) (.obj 4817)
    [.ptr (.js 3126924) 0,.big (Int.ofNat 1354),.big (Int.ofNat 29376)] := NativeCall.actual_control

private theorem int1354 : Int.ofNat 1354 = (1354 : Int) := rfl
private theorem int29376 : Int.ofNat 29376 = (29376 : Int) := rfl

theorem source_callee : input.heap.get 4782 = some (.obj NativeCall.calleeObject) := by host_kernel_rfl
theorem source_callee_kind : NativeCall.calleeObject.kind =
    .fn (.native (.ffi .symbol) [.str chars!"mlx_closure_apply",.obj 4557,.str chars!"i32"]) := by host_kernel_rfl
theorem source_signature : input.heap.get 4557 = some (.obj signatureObject) := by host_kernel_rfl
theorem source_signature_kind : signatureObject.kind =
    .array [.str chars!"ptr",.str chars!"u64",.str chars!"u64"] := by host_kernel_rfl
theorem source_buffer : input.heap.get 3126924 = some (.obj bufferObject) := by host_kernel_rfl
theorem source_buffer_kind : bufferObject.kind = .buf CachedCall.actualBytes := by host_kernel_rfl

theorem load_call_cached (s : LSt) (args : List Arg) (native : Host.Mlx.Ffi.St)
    (ws : List (Nat × Nat × List Byte))
    (hc : Host.Mlx.Ffi.call s.mlx chars!"mlx_closure_apply" args = okW native status0 ws) :
    Host.Load.call s chars!"mlx_closure_apply" args =
      M.pure (some ({s with mlx := native},status0,ws)) := by
  have hm : isMlx chars!"mlx_closure_apply" = true := by decide +kernel
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,hc,okW,M.bind,M.pure]

/-- The host-world invariant keeps its other native components unchanged while
the indexed MLX graph support grows through the cached replay. -/
def NativeRelation (ν₀ ν : Nat → F64) (C₀ C : CSrv) (base : Nat → GraphNode)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (R : Ren) (s₀ s : LSt) : Prop :=
  host s₀.host s.host ∧
    Live (NumberRoles ν₀ ν C₀ C) R
      (NodeRel (CachedCall.roles (CachedCall.coupledRoles base)) ν₀ ν C₀ C R CachedCall.boundary)
      (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) H N tail s₀.mlx s.mlx

theorem source_slot_role (ν : Nat → F64) (C : CSrv) :
    (slotKindRole 29377).Holds ν C Host.Ts.Owned.Annotated.identity
      (objectKindAt input 3126924) := by
  have ho : input.obj? 3126924 = some bufferObject := by simp only [Host.Ts.St.obj?,source_buffer]
  simp only [objectKindAt,ho,source_buffer_kind,CachedCall.actual_bytes]
  exact slot_role_source ν C 29377

noncomputable def sourceNative : LSt := {input.ffi with
  mlx := CachedCall.s3.setObj 29377 (.vec [22591,22592,22593])}

noncomputable def sourcePost : Host.Ts.St LSt :=
  finishBuffer input sourceNative 3126924 0 bufferObject CachedCall.actualBytes
    (cellParts .u64 (.big (Int.ofNat 29377)) 8 0) chars!"mlx_closure_apply"
    [CachedCall.outArg,.big 1354,.big 29376]

theorem source_post : sourcePost = output := by host_kernel_rfl

theorem source_closure_role (ν : Nat → F64) (C : CSrv) :
    (Host.Ts.Owned.Annotated.Value.handle 1354).Holds ν C Host.Ts.Owned.Annotated.identity
      (callArgument input.ctl 1) := by
  simp only [source_control,callArgument,Host.Ts.arg,nthD]
  exact .handle 1354

theorem source_vector_role (ν : Nat → F64) (C : CSrv) :
    (Host.Ts.Owned.Annotated.Value.handle 29376).Holds ν C Host.Ts.Owned.Annotated.identity
      (callArgument input.ctl 2) := by
  simp only [source_control,callArgument,Host.Ts.arg,nthD]
  exact .handle 29376

theorem source_call : F.call input.ffi chars!"mlx_closure_apply"
    [.jsPtr 3126924 0 (CachedCall.actualBytes.drop 0),.big (Int.ofNat 1354),.big (Int.ofNat 29376)] =
    M.pure (some (sourceNative,status0,[u64Write 3126924 0 29377])) := by
  simpa only [List.drop_zero,CachedCall.outArg,F,sourceNative,int1354,int29376] using
    load_call_cached input.ffi _ _ _ CachedCall.source_cached_call

/-- The exact original host step at the authoritative ordinary-call cut. -/
theorem source_step : step F input = M.pure output := by
  have hb : bufBytes F input 3126924 = some CachedCall.actualBytes :=
    bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,source_buffer]) source_buffer_kind
  rw [step_ffi_ptr_u64_u64 F input 4782 4557 3126924 0 (Int.ofNat 1354) (Int.ofNat 29376)
    chars!"mlx_closure_apply" chars!"i32" NativeCall.calleeObject signatureObject CachedCall.actualBytes
    sourceNative status0 [u64Write 3126924 0 29377] source_control
    (by simp only [Host.Ts.St.obj?,source_callee]) source_callee_kind
    (by simp only [Host.Ts.St.obj?,source_signature]) source_signature_kind hb source_call]
  simp only [u64Write,← Int.ofNat_eq_natCast]
  rw [ffiDone_status0_buffer F input sourceNative 3126924 0 bufferObject CachedCall.actualBytes
    (cellParts .u64 (.big (Int.ofNat 29377)) 8 0) chars!"mlx_closure_apply" _
    (by simp only [Host.Ts.St.obj?,source_buffer]) source_buffer_kind]
  change M.pure sourcePost = M.pure output
  rw [source_post]

theorem signature_live {NR : NumV → NumV → Prop} {FR : Ren → LSt → LSt → Prop}
    {R : Ren} {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {s : Host.Ts.St LSt} (h : StateR NR FR R live framed before after old old' input s) : live 4557 := by
  have hc : live 4782 := by
    have hl := h.controlLive
    rw [source_control] at hl
    exact hl.1
  obtain ⟨_,_,_,hl⟩ := h.heap.readObject 4782 NativeCall.calleeObject hc
    (h.heap.function_notFramed 4782 NativeCall.calleeObject _ hc source_callee source_callee_kind) source_callee
  have hk := hl.1
  rw [source_callee_kind] at hk
  exact hk.1.2.1.2.1

/-- Apply the actual ordinary cached call through the original symbol wrapper.
Only fixed argument/slot annotations and allocation bounds supplement the
source-derived live state; neither a target heap read nor a target run is assumed. -/
theorem transport_annotated (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (H frame : Nat → Prop) (tail : List NumV)
    (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (NativeRelation ν₀ ν C₀ C base H (fun i => CachedCall.N0 i ∨ frame i) tail host)
      R live framed before after old old' input s)
    (closureRole : (Host.Ts.Owned.Annotated.Value.handle 1354).Holds ν C R (callArgument s.ctl 1))
    (vectorRole : (Host.Ts.Owned.Annotated.Value.handle 29376).Holds ν C R (callArgument s.ctl 2))
    (slotRole : (slotKindRole 29377).Holds ν C R (objectKindAt s (R.a 3126924)))
    (signatureFrame : ¬ framed 4557)
    (closureLive : H 1354) (vectorLive : H 29376) (outputLive : H 29377)
    (nodesBound : s.ffi.mlx.nnext + CachedCall.trace.order.length < 2^64)
    (handlesBound : s.ffi.mlx.next < 2^64) (heapBound : s.next < 2^64) :
    ∃ t, interpC (step F input).run C₀ = some (output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (NativeRelation ν₀ ν C₀ C base H (fun i => CachedCall.N3 i ∨ frame i) tail host)
        R live framed before after old old' output t ∧
      (slotKindRole 29377).Holds ν C R (objectKindAt t (R.a 3126924)) := by
  obtain ⟨fo,data,this,args,hc,hfo,hfk,hd,_,ha⟩ := h.native_call_view 4782 NativeCall.calleeObject
    (.ffi .symbol) _ (.obj 4817) _ source_control source_callee source_callee_kind
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr
        cases ha with | cons hp ha =>
          cases ha with | cons hcl ha =>
            cases ha with | cons hvec ha =>
              cases ha
              cases hp
              have hecl := fixed_handle_value closureRole
              have hevec := fixed_handle_value vectorRole
              simp only [hc,callArgument,Host.Ts.arg,nthD] at hecl hevec
              rw [hecl,hevec] at hc
              obtain ⟨targetSignature,hto,htrel,_⟩ := h.heap.readObject 4557 signatureObject (signature_live h) signatureFrame source_signature
              have htKind := htrel.kind
              rw [source_signature_kind] at htKind
              obtain ⟨tys,htKind,htys⟩ := kind_array htKind
              cases htys with | cons hp htys =>
                cases htys with | cons hu htys =>
                  cases htys with | cons hu' htys =>
                    cases htys
                    cases hp; cases hu; cases hu'
                    have bufferLive : live 3126924 := by
                      have hh := h.controlLive
                      rw [source_control] at hh
                      exact hh.2.2.1.1
                    obtain ⟨bo,hbo,hbrel,hblive⟩ := h.heap.readObject 3126924 bufferObject bufferLive
                      (h.heap.buffer_notFramed 3126924 bufferObject _ bufferLive source_buffer source_buffer_kind)
                      source_buffer
                    have hbKind := hbrel.kind
                    rw [source_buffer_kind] at hbKind
                    obtain ⟨bytes,hbKind,hbytes⟩ := kind_buffer hbKind
                    have hslot : (slotKindRole 29377).Holds ν C R (Encode.kind bo.kind) := by
                      simpa only [objectKindAt,Host.Ts.St.obj?,hbo] using slotRole
                    have hebytes := Kind.buf.inj (hbKind.symm.trans (slot_kind_exact hslot))
                    subst bytes
                    have hn := h.native.2
                    change Live _ R _ _ H (fun i => CachedCall.N0 i ∨ frame i) tail CachedCall.source s.ffi.mlx at hn
                    obtain ⟨nt,_,htCall,hnAfter,hw⟩ := CachedCall.cached_call_paired frame base hn
                      closureLive vectorLive outputLive nodesBound handlesBound
                    let native' : LSt := {s.ffi with mlx := nt.setObj (R.handle 29377) (.vec ([22591,22592,22593].map R.node))}
                    have nativeRelated : NativeRelation ν₀ ν C₀ C base H
                        (fun i => CachedCall.N3 i ∨ frame i) tail host R sourceNative native' :=
                      ⟨h.native.1,hnAfter⟩
                    let bs' := cellParts .u64 (.big (Int.ofNat (R.handle 29377))) 8 0
                    let t := finishBuffer s native' (R.a 3126924) 0 bo bs' bs' chars!"mlx_closure_apply"
                      [CachedCall.targetOutArg R,.big (Int.ofNat (R.handle 1354)),.big (Int.ofNat (R.handle 29376))]
                    have hz : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
                    have hpost := h.finishBuffer sourceNative native' nativeRelated 3126924 0 1354 29376
                      bufferObject bo CachedCall.actualBytes bs'
                      (cellParts .u64 (.big (Int.ofNat 29377)) 8 0) bs' chars!"mlx_closure_apply"
                      bufferLive source_buffer source_buffer_kind hbrel hblive hbytes
                      (by rw [← CachedCall.actual_bytes]; exact hw) (by decide +kernel)
                      (Nat.lt_trans (h.heap.targetBound _ bufferLive) heapBound) hz
                    have htBuf : bufBytes F s (R.a 3126924) = some bs' :=
                      bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,hbo]) hbKind
                    have htLoad : F.call s.ffi chars!"mlx_closure_apply"
                        [.jsPtr (R.a 3126924) 0 (bs'.drop 0),.big (Int.ofNat (R.handle 1354)),.big (Int.ofNat (R.handle 29376))] =
                        M.pure (some (native',status0,[u64Write (R.a 3126924) 0 (R.handle 29377)])) := by
                      simpa only [List.drop_zero,CachedCall.targetOutArg,F,native',bs'] using
                        load_call_cached s.ffi _ _ _ htCall
                    have targetStep := step_ffi_ptr_u64_u64 F s (R.a 4782) (R.a 4557) (R.a 3126924) 0
                      (Int.ofNat (R.handle 1354)) (Int.ofNat (R.handle 29376)) chars!"mlx_closure_apply" chars!"i32"
                      fo targetSignature bs' native' status0 [u64Write (R.a 3126924) 0 (R.handle 29377)] hc
                      (by simp only [Host.Ts.St.obj?,hfo]) hfk (by simp only [Host.Ts.St.obj?,hto])
                      htKind htBuf htLoad
                    refine ⟨t,?_,?_,?_,?_⟩
                    · rw [source_step]; rfl
                    · rw [targetStep]
                      simp only [u64Write]
                      rw [ffiDone_status0_buffer F s native' (R.a 3126924) 0 bo bs'
                        (cellParts .u64 (.big (R.handle 29377)) 8 0) chars!"mlx_closure_apply" _
                        (by simp only [Host.Ts.St.obj?,hbo]) hbKind]
                      rfl
                    · change StateR _ _ _ _ _ _ _ _ _ sourcePost t at hpost
                      rw [source_post] at hpost
                      exact hpost
                    · exact finishBuffer_slot_role ν C R s native' 3126924 29377 bo chars!"mlx_closure_apply"
                        [CachedCall.targetOutArg R,.big (Int.ofNat (R.handle 1354)),.big (Int.ofNat (R.handle 29376))]
                        (Nat.lt_trans (h.heap.targetBound _ bufferLive) heapBound)

theorem transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (H frame : Nat → Prop) (tail : List NumV)
    (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (NativeRelation ν₀ ν C₀ C base H (fun i => CachedCall.N0 i ∨ frame i) tail host)
      R live framed before after old old' input s)
    (closureRole : (Host.Ts.Owned.Annotated.Value.handle 1354).Holds ν C R (callArgument s.ctl 1))
    (vectorRole : (Host.Ts.Owned.Annotated.Value.handle 29376).Holds ν C R (callArgument s.ctl 2))
    (slotRole : (slotKindRole 29377).Holds ν C R (objectKindAt s (R.a 3126924)))
    (signatureFrame : ¬ framed 4557)
    (closureLive : H 1354) (vectorLive : H 29376) (outputLive : H 29377)
    (nodesBound : s.ffi.mlx.nnext + CachedCall.trace.order.length < 2^64)
    (handlesBound : s.ffi.mlx.next < 2^64) (heapBound : s.next < 2^64) :
    ∃ t, interpC (step F input).run C₀ = some (output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (NativeRelation ν₀ ν C₀ C base H (fun i => CachedCall.N3 i ∨ frame i) tail host)
        R live framed before after old old' output t := by
  obtain ⟨t,hs,ht,hr,_⟩ := transport_annotated ν₀ ν C₀ C R base H frame tail host live framed
    before after old old' s h closureRole vectorRole slotRole signatureFrame closureLive vectorLive outputLive
    nodesBound handlesBound heapBound
  exact ⟨t,hs,ht,hr⟩

end Host.Load.Run.Full.Ordinary.CachedHost

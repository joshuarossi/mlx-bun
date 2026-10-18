import host.mlx.OrdinaryConcatNative
import host.mlx.OrdinaryVectorHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.ConcatHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
noncomputable def sourceNative : LSt := {ConcatCall.input.ffi with mlx := ConcatNative.final}
noncomputable def sourceArgs : List Arg := [.jsPtr 3126700 0 ConcatCall.actualBytes,
  .big (Int.ofNat 29371),.num one,.big (Int.ofNat 2)]
noncomputable def sourcePost : Host.Ts.St LSt :=
  finishBuffer ConcatCall.input sourceNative 3126700 0 ConcatCall.bufferObject ConcatCall.actualBytes
    (cellParts .u64 (.big (Int.ofNat 29372)) 8 0) chars!"mlx_concatenate_axis" sourceArgs

theorem source_post : sourcePost = ConcatCall.output := by host_kernel_rfl

theorem load_call_concat (s : LSt) (args : List Arg) (native : Host.Mlx.Ffi.St)
    (ws : List (Nat × Nat × List Byte))
    (hc : Host.Mlx.Ffi.call s.mlx chars!"mlx_concatenate_axis" args = okW native status0 ws) :
    Host.Load.call s chars!"mlx_concatenate_axis" args = M.pure (some ({s with mlx := native},status0,ws)) := by
  have hm : isMlx chars!"mlx_concatenate_axis" = true := by decide +kernel
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,hc,okW,M.bind,M.pure]

theorem source_step : step F ConcatCall.input = M.pure ConcatCall.output := by
  have hk := ConcatCall.source_callee_kind
  rw [ConcatCall.source_caps] at hk
  have hb : bufBytes F ConcatCall.input 3126700 = some ConcatCall.actualBytes :=
    bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,ConcatCall.source_buffer]) ConcatCall.source_buffer_kind
  have hcall : F.call ConcatCall.input.ffi chars!"mlx_concatenate_axis"
      [.jsPtr 3126700 0 (ConcatCall.actualBytes.drop 0),.big (Int.ofNat 29371),.num one,.big (Int.ofNat 2)] =
      M.pure (some (sourceNative,status0,[u64Write 3126700 0 29372])) := by
    simpa only [F,sourceNative,List.drop_zero] using load_call_concat ConcatCall.input.ffi _ _ _ ConcatNative.source_native_call
  rw [step_ffi_ptr_u64_one_u64 F ConcatCall.input 4708 4409 3126700 0 (Int.ofNat 29371) (Int.ofNat 2)
    chars!"mlx_concatenate_axis" chars!"i32" ConcatCall.calleeObject ConcatCall.signatureObject _
    sourceNative status0 [u64Write 3126700 0 29372] ConcatCall.source_control
    (by simp only [Host.Ts.St.obj?,ConcatCall.source_callee]) hk
    (by simp only [Host.Ts.St.obj?,ConcatCall.source_signature]) ConcatCall.source_signature_kind hb hcall]
  simp only [u64Write,← Int.ofNat_eq_natCast]
  rw [ffiDone_status0_buffer F ConcatCall.input sourceNative 3126700 0 ConcatCall.bufferObject
    ConcatCall.actualBytes (cellParts .u64 (.big (Int.ofNat 29372)) 8 0) chars!"mlx_concatenate_axis" _
    (by simp only [Host.Ts.St.obj?,ConcatCall.source_buffer]) ConcatCall.source_buffer_kind]
  change M.pure sourcePost = _
  rw [source_post]


/-- The actual convolution-cache concatenation, through native graph creation
and the host output-slot write. Every target lookup and inference is derived. -/
theorem transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' ConcatCall.input s)
    (vectorRole : (Host.Ts.Owned.Annotated.Value.handle 29371).Holds ν C R (callArgument s.ctl 1))
    (axisRole : (Host.Ts.Owned.Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (callArgument s.ctl 2))
    (streamRole : (Host.Ts.Owned.Annotated.Value.handle 2).Holds ν C R (callArgument s.ctl 3))
    (slotRole : (slotKindRole 0).Holds ν C R (objectKindAt s (R.a 3126700)))
    (signatureFrame : ¬ framed 4409) (vectorLive : H 29371) (firstLive : N 20208) (secondLive : N 22582)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (handleBound : s.ffi.mlx.next < 2^64) (heapBound : s.next < 2^64) :
    ∃ t, interpC (step F ConcatCall.input).run C₀ = some (ConcatCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary objects
          (fun a => a = 29372 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R live framed before after old old' ConcatCall.output t ∧
      (slotKindRole 29372).Holds ν C R (objectKindAt t (R.a 3126700)) := by
  have hk := ConcatCall.source_callee_kind
  rw [ConcatCall.source_caps] at hk
  have calleeLive : live 4708 := by
    have hl := h.controlLive
    rw [ConcatCall.source_control] at hl
    exact hl.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject 4708 ConcatCall.calleeObject calleeLive
    (h.heap.function_notFramed 4708 ConcatCall.calleeObject _ calleeLive ConcatCall.source_callee hk)
    ConcatCall.source_callee
  have signatureLive : live 4409 := by
    have hl := hol.1
    rw [hk] at hl
    exact hl.1.2.1.2.1
  obtain ⟨fo,data,this,args,hc,hfo,hfk,hd,_,ha⟩ := h.native_call_view 4708 ConcatCall.calleeObject
    (.ffi .symbol) _ (.obj 4817) _ ConcatCall.source_control ConcatCall.source_callee hk
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr
        cases ha with | cons hp ha =>
          cases ha with | cons hv ha =>
            cases ha with | cons ha1 ha =>
              cases ha with | cons hs ha =>
                cases ha
                cases hp
                have hevec := fixed_handle_value vectorRole
                have heaxis := fixed_literal_value axisRole
                have hestream := fixed_handle_value streamRole
                simp only [hc,callArgument,Host.Ts.arg,nthD] at hevec heaxis hestream
                rw [hevec,heaxis,hestream] at hc
                obtain ⟨signature,hsig,hsigr,_⟩ := h.heap.readObject 4409 ConcatCall.signatureObject signatureLive
                  signatureFrame ConcatCall.source_signature
                have hsKind := hsigr.kind
                rw [ConcatCall.source_signature_kind] at hsKind
                obtain ⟨tys,hsKind,htys⟩ := kind_array hsKind
                cases htys with | cons hp htys =>
                  cases htys with | cons hu htys =>
                    cases htys with | cons hi htys =>
                      cases htys with | cons hu2 htys =>
                        cases htys
                        cases hp; cases hu; cases hi; cases hu2
                        have bufferLive : live 3126700 := by
                          have hl := h.controlLive
                          rw [ConcatCall.source_control] at hl
                          exact hl.2.2.1.1
                        obtain ⟨bo,hbo,hbr,hbl⟩ := h.heap.readObject 3126700 ConcatCall.bufferObject bufferLive
                          (h.heap.buffer_notFramed 3126700 ConcatCall.bufferObject _ bufferLive
                            ConcatCall.source_buffer ConcatCall.source_buffer_kind) ConcatCall.source_buffer
                        have hbKind := hbr.kind
                        rw [ConcatCall.source_buffer_kind] at hbKind
                        obtain ⟨bytes,hbKind,hbytes⟩ := kind_buffer hbKind
                        have hbRole : (slotKindRole 0).Holds ν C R (Encode.kind bo.kind) := by
                          simpa only [objectKindAt,Host.Ts.St.obj?,hbo] using slotRole
                        have hebytes := Kind.buf.inj (hbKind.symm.trans (slot_kind_exact hbRole))
                        have hn := h.native.2
                        change Live _ R _ _ H N tail ConcatCall.native s.ffi.mlx at hn
                        rw [hn.handleZero] at hebytes
                        subst bytes
                        let bs' := cellParts .u64 (.big (Int.ofNat 0)) 8 0
                        let ws' := cellParts .u64 (.big (Int.ofNat (R.handle 29372))) 8 0
                        let args' : List Arg := [.jsPtr (R.a 3126700) 0 bs',.big (Int.ofNat (R.handle 29371)),
                          .num one,.big (Int.ofNat (R.handle 2))]
                        obtain ⟨nativeCall,hnAfter⟩ := ConcatNative.transport base objects boundary hn vectorLive firstLive secondLive
                          nodeBound handleBound (.big (Int.ofNat (R.handle 2)))
                        let native' : LSt := {s.ffi with mlx := createZero s.ffi.mlx (ConcatNative.targetNode R)}
                        have nativeRelated : VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
                            objects (fun a => a = 29372 ∨ H a) (fun i => i = 22587 ∨ N i) tail host
                            R sourceNative native' := ⟨h.native.1,hnAfter⟩
                        have hz : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
                        have hone : NumberRoles ν₀ ν C₀ C one one := ⟨.lit (F64.fin false 1 0),⟨rfl,rfl⟩⟩
                        have hevent : TreeR (NumberRoles ν₀ ν C₀ C) R
                            (event ⟨chars!"mlx_concatenate_axis",sourceArgs,status0⟩)
                            (event ⟨chars!"mlx_concatenate_axis",args',status0⟩) :=
                          .node _ (.cons (.atom _ _) (.cons (.node _ (.cons
                            (.node _ (.cons (.address _) (.cons (.atom _ _) (.cons (bytes_roles hbytes) .nil))))
                            (.cons (.node _ (.cons (.value (.handle 29371)) .nil))
                              (.cons (.node _ (.cons (.number hone) .nil))
                                (.cons (.node _ (.cons (.value (.handle 2)) .nil)) .nil)))))
                            (.cons (.node _ (.cons (.number hz) .nil)) .nil)))
                        let t := finishBuffer s native' (R.a 3126700) 0 bo bs' ws' chars!"mlx_concatenate_axis" args'
                        have bufferBound := Nat.lt_trans (h.heap.targetBound _ bufferLive) heapBound
                        have hpost := h.finishBuffer_event sourceNative native' nativeRelated 3126700 0
                          ConcatCall.bufferObject bo ConcatCall.actualBytes bs'
                          (cellParts .u64 (.big (Int.ofNat 29372)) 8 0) ws' chars!"mlx_concatenate_axis" sourceArgs args'
                          bufferLive ConcatCall.source_buffer ConcatCall.source_buffer_kind hbr hbl hbytes
                          (Host.Mlx.Ffi.Parametric.cellParts_roles (.handle 29372) .u64 8 0)
                          (by decide +kernel) bufferBound hz hevent
                        have htBuf : bufBytes F s (R.a 3126700) = some bs' :=
                          bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,hbo]) hbKind
                        have hcall : F.call s.ffi chars!"mlx_concatenate_axis"
                            [.jsPtr (R.a 3126700) 0 (bs'.drop 0),.big (Int.ofNat (R.handle 29371)),.num one,.big (Int.ofNat (R.handle 2))] =
                            M.pure (some (native',status0,[u64Write (R.a 3126700) 0 (R.handle 29372)])) := by
                          simpa only [F,native',bs',List.drop_zero] using load_call_concat s.ffi _ _ _ nativeCall
                        refine ⟨t,?_,?_,?_,?_⟩
                        · rw [source_step]; rfl
                        · rw [step_ffi_ptr_u64_one_u64 F s (R.a 4708) (R.a 4409) (R.a 3126700) 0
                            (Int.ofNat (R.handle 29371)) (Int.ofNat (R.handle 2)) chars!"mlx_concatenate_axis" chars!"i32"
                            fo signature bs' native' status0 [u64Write (R.a 3126700) 0 (R.handle 29372)] hc
                            (by simp only [Host.Ts.St.obj?,hfo]) hfk (by simp only [Host.Ts.St.obj?,hsig]) hsKind htBuf hcall]
                          simp only [u64Write,← Int.ofNat_eq_natCast]
                          rw [ffiDone_status0_buffer F s native' (R.a 3126700) 0 bo bs' ws' chars!"mlx_concatenate_axis" _
                            (by simp only [Host.Ts.St.obj?,hbo]) hbKind]
                          rfl
                        · change StateR _ _ _ _ _ _ _ _ _ sourcePost t at hpost
                          rw [source_post] at hpost
                          exact hpost
                        · have patch : bs'.take 0 ++ ws' ++ bs'.drop (0 + len ws') = ws' := rfl
                          simp only [objectKindAt,t,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,
                            Host.Ts.St.setObj,Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ bufferBound,patch]
                          exact slot_role ν C R 29372

end Host.Load.Run.Full.Ordinary.ConcatHost

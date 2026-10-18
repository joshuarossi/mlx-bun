import host.mlx.OrdinarySliceNative
import host.mlx.OrdinaryMetadataHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.SliceHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
def signature : List Val := [.str chars!"ptr",.str chars!"u64",.str chars!"ptr",.str chars!"u64",.str chars!"ptr",.str chars!"u64",
  .str chars!"ptr",.str chars!"u64",.str chars!"u64"]

def argumentRoles : List Host.Ts.Owned.Annotated.FixedArgument := [.pointer 3126780 0,.handle 29372,
  .pointer 3126752 0,.integer (Int.ofNat 3),.pointer 3126754 0,.integer (Int.ofNat 3),
  .pointer 3126768 0,.integer (Int.ofNat 3),.handle 2]

def nullRole : List Host.Ts.Owned.Annotated.FixedByte :=
  (List.range 8).map fun i => .part .u64 (.integer (Int.ofNat 0)) i

theorem null_bytes : nullRole.map Host.Ts.Owned.Annotated.FixedByte.value = cellParts .u64 (.big (Int.ofNat 0)) 8 0 := rfl

noncomputable def sourceNative : LSt := {SliceCall.input.ffi with mlx := SliceNative.final}
noncomputable def sourceArgs : List Arg := [.jsPtr 3126780 0 SliceCall.outputBytes,.big (Int.ofNat 29372),
  .jsPtr 3126752 0 SliceCall.startBytes,.big (Int.ofNat 3),.jsPtr 3126754 0 SliceCall.stopBytes,.big (Int.ofNat 3),
  .jsPtr 3126768 0 SliceCall.strideBytes,.big (Int.ofNat 3),.big (Int.ofNat 2)]
noncomputable def targetArgs (R : Ren) : List Arg :=
  [.jsPtr (R.a 3126780) 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0),.big (Int.ofNat (R.handle 29372)),
    .jsPtr (R.a 3126752) 0 SliceCall.startBytes,.big (Int.ofNat 3),
    .jsPtr (R.a 3126754) 0 SliceCall.stopBytes,.big (Int.ofNat 3),
    .jsPtr (R.a 3126768) 0 SliceCall.strideBytes,.big (Int.ofNat 3),.big (Int.ofNat (R.handle 2))]
noncomputable def sourcePost : Host.Ts.St LSt :=
  finishBuffer SliceCall.input sourceNative 3126780 0 SliceCall.outputBuffer SliceCall.outputBytes
    (cellParts .u64 (.big (Int.ofNat 29373)) 8 0) chars!"mlx_slice" sourceArgs

theorem source_post : sourcePost = SliceCall.output := by host_kernel_rfl

theorem load_call_slice (s : LSt) (args : List Arg) (native : Host.Mlx.Ffi.St)
    (ws : List (Nat × Nat × List Byte))
    (hc : Host.Mlx.Ffi.call s.mlx chars!"mlx_slice" args = okW native status0 ws) :
    Host.Load.call s chars!"mlx_slice" args = M.pure (some ({s with mlx := native},status0,ws)) := by
  have hm : isMlx chars!"mlx_slice" = true := by decide +kernel
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,hc,okW,M.bind,M.pure]

theorem decode_slice (F : Ffi) (s : Host.Ts.St F.S) (b st sp sr : Nat) (a stream : Int)
    (bo bst bsp bsr : List Byte)
    (ho : bufBytes F s b = some bo) (hst : bufBytes F s st = some bst)
    (hsp : bufBytes F s sp = some bsp) (hsr : bufBytes F s sr = some bsr) :
    decodeArgs F s signature [.ptr (.js b) 0,.big a,.ptr (.js st) 0,.big (Int.ofNat 3),
      .ptr (.js sp) 0,.big (Int.ofNat 3),.ptr (.js sr) 0,.big (Int.ofNat 3),.big stream] =
      M.pure (some [.jsPtr b 0 bo,.big a,.jsPtr st 0 bst,.big (Int.ofNat 3),
        .jsPtr sp 0 bsp,.big (Int.ofNat 3),.jsPtr sr 0 bsr,.big (Int.ofNat 3),.big stream]) := by
  simpa only [signature,List.drop_zero] using decodeArgs_ptr_u64_tail F s b 0 a bo _ _ _ ho
    (decodeArgs_ptr_u64_tail F s st 0 (Int.ofNat 3) bst _ _ _ hst
      (decodeArgs_ptr_u64_tail F s sp 0 (Int.ofNat 3) bsp _ _ _ hsp
        (decodeArgs_ptr_u64_tail F s sr 0 (Int.ofNat 3) bsr _ _ _ hsr (decodeArgs_one_u64 F s stream))))

theorem source_step : step F SliceCall.input = M.pure SliceCall.output := by
  have hk := SliceCall.source_kind
  rw [SliceCall.source_caps] at hk
  have ho : bufBytes F SliceCall.input 3126780 = some SliceCall.outputBytes :=
    bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,SliceCall.source_output_buffer]) SliceCall.source_output_kind
  have hst : bufBytes F SliceCall.input 3126752 = some SliceCall.startBytes :=
    bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,SliceCall.source_start_buffer]) SliceCall.source_start_kind
  have hsp : bufBytes F SliceCall.input 3126754 = some SliceCall.stopBytes :=
    bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,SliceCall.source_stop_buffer]) SliceCall.source_stop_kind
  have hsr : bufBytes F SliceCall.input 3126768 = some SliceCall.strideBytes :=
    bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,SliceCall.source_stride_buffer]) SliceCall.source_stride_kind
  have hcall : F.call SliceCall.input.ffi chars!"mlx_slice" sourceArgs =
      M.pure (some (sourceNative,status0,[u64Write 3126780 0 29373])) := by
    simpa only [F,sourceArgs,sourceNative] using load_call_slice SliceCall.input.ffi _ _ _ SliceNative.source_native_call
  rw [step_ffi_decoded F SliceCall.input 4713 4419 chars!"mlx_slice" SliceCall.returns SliceCall.calleeObject
    SliceCall.signatureObject (.obj 4817) signature _ sourceArgs sourceNative status0 [u64Write 3126780 0 29373]
    SliceCall.source_control (by simp only [Host.Ts.St.obj?,SliceCall.source_callee]) hk
    (by simp only [Host.Ts.St.obj?,SliceCall.source_signature]) SliceCall.source_signature_kind
    (decode_slice F SliceCall.input 3126780 3126752 3126754 3126768 (Int.ofNat 29372) (Int.ofNat 2)
      _ _ _ _ ho hst hsp hsr) hcall]
  simp only [u64Write,← Int.ofNat_eq_natCast]
  rw [ffiDone_status0_buffer F SliceCall.input sourceNative 3126780 0 SliceCall.outputBuffer SliceCall.outputBytes
    (cellParts .u64 (.big (Int.ofNat 29373)) 8 0) chars!"mlx_slice" _
    (by simp only [Host.Ts.St.obj?,SliceCall.source_output_buffer]) SliceCall.source_output_kind]
  change M.pure sourcePost = _
  rw [source_post]


private theorem pointer_arg {NR : NumV → NumV → Prop} (R : Ren) (b : Nat) (xs ys : List Byte)
    (h : ListR (ByteR NR R) xs ys) :
    TreeR NR R (Parametric.arg (.jsPtr b 0 xs)) (Parametric.arg (.jsPtr (R.a b) 0 ys)) :=
  .node _ (.cons (.address b) (.cons (.atom _ _) (.cons (bytes_roles h) .nil)))

private theorem status_event {NR : NumV → NumV → Prop} {R : Ren} (name : Name) (xs ys : List Arg)
    (h : ForestR NR R (xs.map Parametric.arg) (ys.map Parametric.arg)) (hz : NR zeroN zeroN) :
    TreeR NR R (event ⟨name,xs,status0⟩) (event ⟨name,ys,status0⟩) :=
  .node _ (.cons (.atom _ _) (.cons (.node _ h) (.cons (.node _ (.cons (.number hz) .nil)) .nil)))

/-- The actual nine-argument slice wrapper. Fixed occurrences determine
integer counts and index bytes; source heap/native facts determine all target
reads, decoding, inference, graph allocation and the output-slot write. -/
theorem transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (SliceNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' SliceCall.input s)
    (arguments : ListR (fun r v => r.role.Holds ν C R v) argumentRoles (callArguments s.ctl))
    (outputRole : (Host.Ts.Owned.Annotated.fixedBufferRole nullRole).Holds ν C R (objectKindAt s (R.a 3126780)))
    (startRole : (Host.Ts.Owned.Annotated.fixedBufferRole (Host.Ts.Owned.Annotated.fixedI32 [0,1,0])).Holds ν C R (objectKindAt s (R.a 3126752)))
    (stopRole : (Host.Ts.Owned.Annotated.fixedBufferRole (Host.Ts.Owned.Annotated.fixedI32 [1,4,10240])).Holds ν C R (objectKindAt s (R.a 3126754)))
    (strideRole : (Host.Ts.Owned.Annotated.fixedBufferRole (Host.Ts.Owned.Annotated.fixedI32 [1,1,1])).Holds ν C R (objectKindAt s (R.a 3126768)))
    (signatureFrame : ¬ framed 4419) (handleLive : H 29372)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (handleBound : s.ffi.mlx.next < 2^64) (heapBound : s.next < 2^64) :
    ∃ t, interpC (step F SliceCall.input).run C₀ = some (SliceCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (SliceNative.postRoles base) boundary objects
          (fun a => a = 29373 ∨ H a) (fun i => i = 22588 ∨ N i) tail host)
        R live framed before after old old' SliceCall.output t ∧
      (slotKindRole 29373).Holds ν C R (objectKindAt t (R.a 3126780)) := by
  have hk := SliceCall.source_kind
  rw [SliceCall.source_caps] at hk
  have controlLive := h.controlLive
  rw [SliceCall.source_control] at controlLive
  have calleeLive : live 4713 := controlLive.1
  have outputLive : live 3126780 := controlLive.2.2.1.1
  have startLive : live 3126752 := controlLive.2.2.1.2.2.1
  have stopLive : live 3126754 := controlLive.2.2.1.2.2.2.2.1
  have strideLive : live 3126768 := controlLive.2.2.1.2.2.2.2.2.2.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject 4713 SliceCall.calleeObject calleeLive
    (h.heap.function_notFramed 4713 SliceCall.calleeObject _ calleeLive SliceCall.source_callee hk)
    SliceCall.source_callee
  have signatureLive : live 4419 := by
    have hl := hol.1
    rw [hk] at hl
    exact hl.1.2.1.2.1
  obtain ⟨fo,data,this,args,hc,hfo,hfk,hd,_,_⟩ := h.native_call_view 4713 SliceCall.calleeObject
    (.ffi .symbol) _ (.obj 4817) _ SliceCall.source_control SliceCall.source_callee hk
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr
        have rawRoles : ListR (fun r v => r.role.Holds ν C R v) argumentRoles args := by
          simpa only [callArguments,hc] using arguments
        have argsExact := Host.Ts.Owned.Annotated.FixedArgument.list_exact argumentRoles rawRoles
        rw [argsExact] at hc
        dsimp only [argumentRoles,Host.Ts.Owned.Annotated.FixedArgument.value,List.map_cons,List.map_nil] at hc
        obtain ⟨signatureObj,hsig,hsigr,_⟩ := h.heap.readObject 4419 SliceCall.signatureObject signatureLive
          signatureFrame SliceCall.source_signature
        have hsKind := hsigr.kind
        rw [SliceCall.source_signature_kind] at hsKind
        obtain ⟨types,hsKind,htypes⟩ := kind_array hsKind
        have typeExact := string_values_exact
          [chars!"ptr",chars!"u64",chars!"ptr",chars!"u64",chars!"ptr",chars!"u64",chars!"ptr",chars!"u64",chars!"u64"] htypes
        rw [typeExact] at hsKind
        obtain ⟨out,ho,hko,hro,hlo,hbo⟩ := h.read_fixed_buffer 3126780 SliceCall.outputBuffer SliceCall.outputBytes
          nullRole outputLive SliceCall.source_output_buffer SliceCall.source_output_kind outputRole
        rw [null_bytes] at hko hbo
        obtain ⟨st,hst,hkst,hrst,_,hbst⟩ := h.read_fixed_buffer 3126752 SliceCall.startBuffer SliceCall.startBytes
          (Host.Ts.Owned.Annotated.fixedI32 [0,1,0]) startLive SliceCall.source_start_buffer SliceCall.source_start_kind startRole
        rw [← SliceCall.source_start_bytes] at hkst hbst
        obtain ⟨sp,hsp,hksp,hrsp,_,hbsp⟩ := h.read_fixed_buffer 3126754 SliceCall.stopBuffer SliceCall.stopBytes
          (Host.Ts.Owned.Annotated.fixedI32 [1,4,10240]) stopLive SliceCall.source_stop_buffer SliceCall.source_stop_kind stopRole
        rw [← SliceCall.source_stop_bytes] at hksp hbsp
        obtain ⟨sr,hsr,hksr,hrsr,_,hbsr⟩ := h.read_fixed_buffer 3126768 SliceCall.strideBuffer SliceCall.strideBytes
          (Host.Ts.Owned.Annotated.fixedI32 [1,1,1]) strideLive SliceCall.source_stride_buffer SliceCall.source_stride_kind strideRole
        rw [← SliceCall.source_stride_bytes] at hksr hbsr
        have hn := h.native.2
        change Live _ R _ _ H N tail SliceCall.native s.ffi.mlx at hn
        obtain ⟨nativeCall,hnAfter⟩ := SliceNative.transport base objects boundary hn handleLive nodeBound handleBound
          (.big (Int.ofNat (R.handle 2)))
        let native' : LSt := {s.ffi with mlx := createZero s.ffi.mlx (SliceNative.targetNode R)}
        have nativeRelated : VectorHost.NativeRelation ν₀ ν C₀ C (SliceNative.postRoles base) boundary objects
            (fun a => a = 29373 ∨ H a) (fun i => i = 22588 ∨ N i) tail host R sourceNative native' :=
          ⟨h.native.1,hnAfter⟩
        have hz : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
        have argRoles : ForestR (NumberRoles ν₀ ν C₀ C) R (sourceArgs.map Parametric.arg) ((targetArgs R).map Parametric.arg) :=
          .cons (pointer_arg R 3126780 _ _ hbo)
            (.cons (.node _ (.cons (.value (.handle 29372)) .nil))
            (.cons (pointer_arg R 3126752 _ _ hbst)
            (.cons (.node _ (.cons (.value (.ordinaryBig _)) .nil))
            (.cons (pointer_arg R 3126754 _ _ hbsp)
            (.cons (.node _ (.cons (.value (.ordinaryBig _)) .nil))
            (.cons (pointer_arg R 3126768 _ _ hbsr)
            (.cons (.node _ (.cons (.value (.ordinaryBig _)) .nil))
            (.cons (.node _ (.cons (.value (.handle 2)) .nil)) .nil))))))))
        let bs' := cellParts .u64 (.big (Int.ofNat 0)) 8 0
        let ws' := cellParts .u64 (.big (Int.ofNat (R.handle 29373))) 8 0
        let t := finishBuffer s native' (R.a 3126780) 0 out bs' ws' chars!"mlx_slice" (targetArgs R)
        have outputBound := Nat.lt_trans (h.heap.targetBound _ outputLive) heapBound
        have hpost := h.finishBuffer_event sourceNative native' nativeRelated 3126780 0 SliceCall.outputBuffer out
          SliceCall.outputBytes bs' (cellParts .u64 (.big (Int.ofNat 29373)) 8 0) ws' chars!"mlx_slice" sourceArgs (targetArgs R)
          outputLive SliceCall.source_output_buffer SliceCall.source_output_kind hro hlo hbo
          (Host.Mlx.Ffi.Parametric.cellParts_roles (.handle 29373) .u64 8 0) (by decide +kernel) outputBound hz
          (status_event chars!"mlx_slice" sourceArgs (targetArgs R) argRoles hz)
        have hbuf : bufBytes F s (R.a 3126780) = some bs' :=
          bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,ho]) hko
        have hbufst : bufBytes F s (R.a 3126752) = some SliceCall.startBytes :=
          bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,hst]) hkst
        have hbufsp : bufBytes F s (R.a 3126754) = some SliceCall.stopBytes :=
          bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,hsp]) hksp
        have hbufsr : bufBytes F s (R.a 3126768) = some SliceCall.strideBytes :=
          bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,hsr]) hksr
        have hcall : F.call s.ffi chars!"mlx_slice" (targetArgs R) =
            M.pure (some (native',status0,[u64Write (R.a 3126780) 0 (R.handle 29373)])) := by
          simpa only [F,native',targetArgs] using load_call_slice s.ffi _ _ _ nativeCall
        refine ⟨t,?_,?_,?_,?_⟩
        · rw [source_step]; rfl
        · rw [step_ffi_decoded F s (R.a 4713) (R.a 4419) chars!"mlx_slice" SliceCall.returns fo signatureObj this
            signature _ (targetArgs R) native' status0 [u64Write (R.a 3126780) 0 (R.handle 29373)] hc
            (by simp only [Host.Ts.St.obj?,hfo]) hfk (by simp only [Host.Ts.St.obj?,hsig]) hsKind
            (decode_slice F s (R.a 3126780) (R.a 3126752) (R.a 3126754) (R.a 3126768)
              (Int.ofNat (R.handle 29372)) (Int.ofNat (R.handle 2)) _ _ _ _ hbuf hbufst hbufsp hbufsr) hcall]
          simp only [u64Write,← Int.ofNat_eq_natCast]
          rw [ffiDone_status0_buffer F s native' (R.a 3126780) 0 out bs' ws' chars!"mlx_slice" _
            (by simp only [Host.Ts.St.obj?,ho]) hko]
          rfl
        · change StateR _ _ _ _ _ _ _ _ _ sourcePost t at hpost
          rw [source_post] at hpost
          exact hpost
        · have patch : bs'.take 0 ++ ws' ++ bs'.drop (0 + len ws') = ws' := rfl
          simp only [objectKindAt,t,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,
            Host.Ts.St.setObj,Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ outputBound,patch]
          exact slot_role ν C R 29373

end Host.Load.Run.Full.Ordinary.SliceHost

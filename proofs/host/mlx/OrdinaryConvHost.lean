import host.mlx.OrdinaryConvNative
import host.mlx.OrdinarySliceHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.ConvHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
def signature : List Val := [.str chars!"ptr",.str chars!"u64",.str chars!"u64",.str chars!"i32",
  .str chars!"i32",.str chars!"i32",.str chars!"i32",.str chars!"u64"]
def argumentRoles : List Host.Ts.Owned.Annotated.FixedArgument := [.pointer 3126867 0,.handle 29372,.handle 1365,
  .literal (F64.fin false 1 0),.literal (F64.zero false),.literal (F64.fin false 1 0),
  .literal (F64.ofInt 10240),.handle 2]
noncomputable def sourceNative : LSt := {ConvCall.input.ffi with mlx := ConvNative.final}
noncomputable def sourceArgs : List Arg := [.jsPtr 3126867 0 ConvCall.outputBytes,.big (Int.ofNat 29372),.big (Int.ofNat 1365),
  .num one,.num zeroN,.num one,.num (.lit (F64.ofInt 10240)),.big (Int.ofNat 2)]
noncomputable def targetArgs (R : Ren) : List Arg :=
  [.jsPtr (R.a 3126867) 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0),
    .big (Int.ofNat (R.handle 29372)),.big (Int.ofNat (R.handle 1365)),
    .num one,.num zeroN,.num one,.num (.lit (F64.ofInt 10240)),.big (Int.ofNat (R.handle 2))]
noncomputable def sourcePost : Host.Ts.St LSt :=
  finishBuffer ConvCall.input sourceNative 3126867 0 ConvCall.outputBuffer ConvCall.outputBytes
    (cellParts .u64 (.big (Int.ofNat 29375)) 8 0) chars!"mlx_conv1d" sourceArgs

theorem source_post : sourcePost = ConvCall.output := by host_kernel_rfl

theorem load_call_conv (s : LSt) (args : List Arg) (native : Host.Mlx.Ffi.St)
    (ws : List (Nat × Nat × List Byte))
    (hc : Host.Mlx.Ffi.call s.mlx chars!"mlx_conv1d" args = okW native status0 ws) :
    Host.Load.call s chars!"mlx_conv1d" args = M.pure (some ({s with mlx := native},status0,ws)) := by
  have hm : isMlx chars!"mlx_conv1d" = true := by decide +kernel
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,hc,okW,M.bind,M.pure]

theorem decode_conv (F : Ffi) (s : Host.Ts.St F.S) (b : Nat) (x w stream : Int) (bytes : List Byte)
    (hb : bufBytes F s b = some bytes) :
    decodeArgs F s signature [.ptr (.js b) 0,.big x,.big w,.num one,.num zeroN,.num one,
      .num (.lit (F64.ofInt 10240)),.big stream] =
    M.pure (some [.jsPtr b 0 bytes,.big x,.big w,.num one,.num zeroN,.num one,
      .num (.lit (F64.ofInt 10240)),.big stream]) := by
  have h1 : F64.un .int32 (F64.fin false 1 0) = F64.fin false 1 0 := by decide +kernel
  have h0 : F64.un .int32 (F64.zero false) = F64.zero false := by decide +kernel
  have hg : F64.un .int32 (F64.ofInt 10240) = F64.ofInt 10240 := by decide +kernel
  simpa only [signature,Host.Ts.one,zeroN,List.drop_zero] using decodeArgs_ptr_u64_tail F s b 0 x bytes _ _ _ hb
    (decodeArgs_u64_tail F s w _ _ _
      (decodeArgs_i32_literal_tail F s (F64.fin false 1 0) h1 _ _ _
        (decodeArgs_i32_literal_tail F s (F64.zero false) h0 _ _ _
          (decodeArgs_i32_literal_tail F s (F64.fin false 1 0) h1 _ _ _
            (decodeArgs_i32_literal_tail F s (F64.ofInt 10240) hg _ _ _ (decodeArgs_one_u64 F s stream))))))

theorem source_step : step F ConvCall.input = M.pure ConvCall.output := by
  have hk := ConvCall.source_kind
  rw [ConvCall.source_caps] at hk
  have hb : bufBytes F ConvCall.input 3126867 = some ConvCall.outputBytes :=
    bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,ConvCall.source_buffer]) ConvCall.source_buffer_kind
  have hcall : F.call ConvCall.input.ffi chars!"mlx_conv1d" sourceArgs =
      M.pure (some (sourceNative,status0,[u64Write 3126867 0 29375])) := by
    simpa only [F,sourceArgs,sourceNative] using load_call_conv ConvCall.input.ffi _ _ _ ConvNative.source_native_call
  rw [step_ffi_decoded F ConvCall.input 4742 4477 chars!"mlx_conv1d" ConvCall.returns ConvCall.calleeObject
    ConvCall.signatureObject (.obj 4817) signature _ sourceArgs sourceNative status0 [u64Write 3126867 0 29375]
    ConvCall.source_control (by simp only [Host.Ts.St.obj?,ConvCall.source_callee]) hk
    (by simp only [Host.Ts.St.obj?,ConvCall.source_signature]) ConvCall.source_signature_kind
    (decode_conv F ConvCall.input 3126867 (Int.ofNat 29372) (Int.ofNat 1365) (Int.ofNat 2) _ hb) hcall]
  simp only [u64Write,← Int.ofNat_eq_natCast]
  rw [ffiDone_status0_buffer F ConvCall.input sourceNative 3126867 0 ConvCall.outputBuffer ConvCall.outputBytes
    (cellParts .u64 (.big (Int.ofNat 29375)) 8 0) chars!"mlx_conv1d" _
    (by simp only [Host.Ts.St.obj?,ConvCall.source_buffer]) ConvCall.source_buffer_kind]
  change M.pure sourcePost = _
  rw [source_post]

/-- The exact depthwise convolution call, including literal int32 decoding,
original graph creation and host result write. Native inputs and target reads
are consequences of the strong entry relation and fixed occurrences. -/
theorem transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConvNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' ConvCall.input s)
    (arguments : ListR (fun r v => r.role.Holds ν C R v) argumentRoles (callArguments s.ctl))
    (outputRole : (Host.Ts.Owned.Annotated.fixedBufferRole SliceHost.nullRole).Holds ν C R (objectKindAt s (R.a 3126867)))
    (signatureFrame : ¬ framed 4477) (inputLive : H 29372) (weightLive : H 1365)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (handleBound : s.ffi.mlx.next < 2^64) (heapBound : s.next < 2^64) :
    ∃ t, interpC (step F ConvCall.input).run C₀ = some (ConvCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConvNative.postRoles base) boundary objects
          (fun a => a = 29375 ∨ H a) (fun i => i = 22590 ∨ N i) tail host)
        R live framed before after old old' ConvCall.output t ∧
      (slotKindRole 29375).Holds ν C R (objectKindAt t (R.a 3126867)) := by
  have hk := ConvCall.source_kind
  rw [ConvCall.source_caps] at hk
  have controlLive := h.controlLive
  rw [ConvCall.source_control] at controlLive
  have calleeLive : live 4742 := controlLive.1
  have outputLive : live 3126867 := controlLive.2.2.1.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject 4742 ConvCall.calleeObject calleeLive
    (h.heap.function_notFramed 4742 ConvCall.calleeObject _ calleeLive ConvCall.source_callee hk)
    ConvCall.source_callee
  have signatureLive : live 4477 := by
    have hl := hol.1
    rw [hk] at hl
    exact hl.1.2.1.2.1
  obtain ⟨fo,data,this,args,hc,hfo,hfk,hd,_,_⟩ := h.native_call_view 4742 ConvCall.calleeObject
    (.ffi .symbol) _ (.obj 4817) _ ConvCall.source_control ConvCall.source_callee hk
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
        obtain ⟨signatureObj,hsig,hsigr,_⟩ := h.heap.readObject 4477 ConvCall.signatureObject signatureLive
          signatureFrame ConvCall.source_signature
        have hsKind := hsigr.kind
        rw [ConvCall.source_signature_kind] at hsKind
        obtain ⟨types,hsKind,htypes⟩ := kind_array hsKind
        have typeExact := string_values_exact
          [chars!"ptr",chars!"u64",chars!"u64",chars!"i32",chars!"i32",chars!"i32",chars!"i32",chars!"u64"] htypes
        rw [typeExact] at hsKind
        obtain ⟨out,ho,hko,hro,hlo,hbo⟩ := h.read_fixed_buffer 3126867 ConvCall.outputBuffer ConvCall.outputBytes
          SliceHost.nullRole outputLive ConvCall.source_buffer ConvCall.source_buffer_kind outputRole
        rw [SliceHost.null_bytes] at hko hbo
        have hn := h.native.2
        change Live _ R _ _ H N tail ConvCall.native s.ffi.mlx at hn
        obtain ⟨nativeCall,hnAfter⟩ := ConvNative.transport base objects boundary hn inputLive weightLive nodeBound handleBound
          (.big (Int.ofNat (R.handle 2)))
        let native' : LSt := {s.ffi with mlx := createZero s.ffi.mlx (ConvNative.targetNode R)}
        have nativeRelated : VectorHost.NativeRelation ν₀ ν C₀ C (ConvNative.postRoles base) boundary objects
            (fun a => a = 29375 ∨ H a) (fun i => i = 22590 ∨ N i) tail host R sourceNative native' :=
          ⟨h.native.1,hnAfter⟩
        have hz : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
        have h1 : NumberRoles ν₀ ν C₀ C one one := ⟨.lit (F64.fin false 1 0),⟨rfl,rfl⟩⟩
        have hg : NumberRoles ν₀ ν C₀ C (.lit (F64.ofInt 10240)) (.lit (F64.ofInt 10240)) := ⟨.lit (F64.ofInt 10240),⟨rfl,rfl⟩⟩
        have argRelated : ForestR (NumberRoles ν₀ ν C₀ C) R (sourceArgs.map Parametric.arg) ((targetArgs R).map Parametric.arg) :=
          .cons (.node _ (.cons (.address _) (.cons (.atom _ _) (.cons (bytes_roles hbo) .nil))))
          (.cons (.node _ (.cons (.value (.handle 29372)) .nil))
          (.cons (.node _ (.cons (.value (.handle 1365)) .nil))
          (.cons (.node _ (.cons (.number h1) .nil))
          (.cons (.node _ (.cons (.number hz) .nil))
          (.cons (.node _ (.cons (.number h1) .nil))
          (.cons (.node _ (.cons (.number hg) .nil))
          (.cons (.node _ (.cons (.value (.handle 2)) .nil)) .nil)))))))
        have hevent : TreeR (NumberRoles ν₀ ν C₀ C) R
            (event ⟨chars!"mlx_conv1d",sourceArgs,status0⟩) (event ⟨chars!"mlx_conv1d",targetArgs R,status0⟩) :=
          .node _ (.cons (.atom _ _) (.cons (.node _ argRelated) (.cons (.node _ (.cons (.number hz) .nil)) .nil)))
        let bs' := cellParts .u64 (.big (Int.ofNat 0)) 8 0
        let ws' := cellParts .u64 (.big (Int.ofNat (R.handle 29375))) 8 0
        let t := finishBuffer s native' (R.a 3126867) 0 out bs' ws' chars!"mlx_conv1d" (targetArgs R)
        have outputBound := Nat.lt_trans (h.heap.targetBound _ outputLive) heapBound
        have hpost := h.finishBuffer_event sourceNative native' nativeRelated 3126867 0 ConvCall.outputBuffer out
          ConvCall.outputBytes bs' (cellParts .u64 (.big (Int.ofNat 29375)) 8 0) ws' chars!"mlx_conv1d" sourceArgs (targetArgs R)
          outputLive ConvCall.source_buffer ConvCall.source_buffer_kind hro hlo hbo
          (Host.Mlx.Ffi.Parametric.cellParts_roles (.handle 29375) .u64 8 0) (by decide +kernel) outputBound hz hevent
        have hbuf : bufBytes F s (R.a 3126867) = some bs' :=
          bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,ho]) hko
        have hcall : F.call s.ffi chars!"mlx_conv1d" (targetArgs R) =
            M.pure (some (native',status0,[u64Write (R.a 3126867) 0 (R.handle 29375)])) := by
          simpa only [F,native',targetArgs] using load_call_conv s.ffi _ _ _ nativeCall
        refine ⟨t,?_,?_,?_,?_⟩
        · rw [source_step]; rfl
        · rw [step_ffi_decoded F s (R.a 4742) (R.a 4477) chars!"mlx_conv1d" ConvCall.returns fo signatureObj this
            signature _ (targetArgs R) native' status0 [u64Write (R.a 3126867) 0 (R.handle 29375)] hc
            (by simp only [Host.Ts.St.obj?,hfo]) hfk (by simp only [Host.Ts.St.obj?,hsig]) hsKind
            (decode_conv F s (R.a 3126867) (Int.ofNat (R.handle 29372)) (Int.ofNat (R.handle 1365))
              (Int.ofNat (R.handle 2)) _ hbuf) hcall]
          simp only [u64Write,← Int.ofNat_eq_natCast]
          rw [ffiDone_status0_buffer F s native' (R.a 3126867) 0 out bs' ws' chars!"mlx_conv1d" _
            (by simp only [Host.Ts.St.obj?,ho]) hko]
          rfl
        · change StateR _ _ _ _ _ _ _ _ _ sourcePost t at hpost
          rw [source_post] at hpost
          exact hpost
        · have patch : bs'.take 0 ++ ws' ++ bs'.drop (0 + len ws') = ws' := rfl
          simp only [objectKindAt,t,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,
            Host.Ts.St.setObj,Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ outputBound,patch]
          exact slot_role ν C R 29375

end Host.Load.Run.Full.Ordinary.ConvHost

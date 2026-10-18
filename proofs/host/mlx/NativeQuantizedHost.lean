import host.mlx.NativeQuantizedRoles
import host.mlx.NativeReshapeHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.QuantizedHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.NativeRoles.Arguments Host.Mlx.Ffi.Annotated

abbrev F : Host.Ts.Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
def symbol : Name := chars!"mlx_quantized_matmul"
def signature : List Val := [.str chars!"ptr",.str chars!"u64",.str chars!"u64",.str chars!"u64",.str chars!"u64",
  .str chars!"bool",.str chars!"u64",.str chars!"u64",.str chars!"cstring",.str chars!"u64"]

def arguments (out hx hw hsc hbi : Nat) (tr : Bool) (group bits modeBuffer stream : Nat) : List Host.Ts.Owned.Annotated.FixedArgument :=
  [.pointer out 0,.handle hx,.handle hw,.handle hsc,.handle hbi,.boolean tr,
    .integer (Int.ofNat (packedOptInt group)),.integer (Int.ofNat (packedOptInt bits)),.pointer modeBuffer 0,.handle stream]

def callArgs (out hx hw hsc hbi : Nat) (tr : Bool) (group bits modeBuffer stream : Nat)
    (outBytes modeBytes : List Byte) : List Arg :=
  [.jsPtr out 0 outBytes,.big (Int.ofNat hx),.big (Int.ofNat hw),.big (Int.ofNat hsc),.big (Int.ofNat hbi),.bool tr,
    .big (Int.ofNat (packedOptInt group)),.big (Int.ofNat (packedOptInt bits)),.jsPtr modeBuffer 0 modeBytes,.big (Int.ofNat stream)]

def resultWorld (s : LSt) (x w sc bi : Nat) (tr : Bool) (group bits : Nat) (rows cols : Int)
    (xn sn bn : Node) : LSt :=
  {s with mlx := NativeRoles.createZero s.mlx (qmmNode x w sc bi tr group bits
    (setAt xn.shape (len xn.shape-1) (.lit (qmmOuter tr bits rows cols)))
    (promote xn.dtype (promote sn.dtype bn.dtype)))}

theorem decode_boolean (F : Host.Ts.Ffi) (s : Host.Ts.St F.S) (v : Bool) :
    decodeArg F s chars!"bool" (.bool v) = M.pure (some (.bool v)) := by
  have ptr : (nameEq chars!"bool" chars!"ptr" || nameEq chars!"bool" chars!"pointer" ||
    nameEq chars!"bool" chars!"buffer" || nameEq chars!"bool" chars!"cstring") = false := by decide +kernel
  have big : (nameEq chars!"bool" chars!"u64" || nameEq chars!"bool" chars!"i64" || nameEq chars!"bool" chars!"usize") = false := by decide +kernel
  have f32 : (nameEq chars!"bool" chars!"f32" || nameEq chars!"bool" chars!"float") = false := by decide +kernel
  have f64 : (nameEq chars!"bool" chars!"f64" || nameEq chars!"bool" chars!"double") = false := by decide +kernel
  have same : nameEq chars!"bool" chars!"bool" = true := Nat.beq_refl _
  simp only [decodeArg,ptr,big,f32,f64,same,Bool.cond_false,Bool.cond_true,truthy]
  rfl

theorem decode_quantized (s : Host.Ts.St LSt) (out hx hw hsc hbi : Nat) (tr : Bool)
    (group bits modeBuffer stream : Nat) (outBytes modeBytes : List Byte)
    (ho : bufBytes F s out = some outBytes) (hm : bufBytes F s modeBuffer = some modeBytes) :
    decodeArgs F s signature [.ptr (.js out) 0,.big (Int.ofNat hx),.big (Int.ofNat hw),.big (Int.ofNat hsc),.big (Int.ofNat hbi),
      .bool tr,.big (Int.ofNat (packedOptInt group)),.big (Int.ofNat (packedOptInt bits)),.ptr (.js modeBuffer) 0,.big (Int.ofNat stream)] =
      M.pure (some (callArgs out hx hw hsc hbi tr group bits modeBuffer stream outBytes modeBytes)) := by
  funext β k
  simp only [signature,callArgs,decodeArgs,decodeArg_js_pointer F s out 0 outBytes ho,decode_u64_big,decode_boolean,
    decode_cstring_pointer F s modeBuffer 0 modeBytes hm,List.drop_zero,M.bind,M.pure,Option.map_some]

theorem step_quantized_eq (s : Host.Ts.St LSt) (fn types out hx hw hsc hbi : Nat) (tr : Bool)
    (group bits modeBuffer stream : Nat) (fo signature₀ buffer : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (outBytes modeBytes : List Byte) (native : LSt) (writes : List Byte)
    (hc : s.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat hx),.big (Int.ofNat hw),.big (Int.ofNat hsc),
      .big (Int.ofNat hbi),.bool tr,.big (Int.ofNat (packedOptInt group)),.big (Int.ofNat (packedOptInt bits)),
      .ptr (.js modeBuffer) 0,.big (Int.ofNat stream)])
    (hf : s.heap.get fn = some (.obj fo))
    (hk : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht : s.heap.get types = some (.obj signature₀)) (htk : signature₀.kind = .array signature)
    (hb : s.heap.get out = some (.obj buffer)) (hbk : buffer.kind = .buf outBytes)
    (hm : bufBytes F s modeBuffer = some modeBytes)
    (nativeCall : F.call s.ffi symbol (callArgs out hx hw hsc hbi tr group bits modeBuffer stream outBytes modeBytes) =
      M.pure (some (native,status0,[(out,0,writes)]))) :
    step F s = M.pure (finishBuffer s native out 0 buffer outBytes writes symbol
      (callArgs out hx hw hsc hbi tr group bits modeBuffer stream outBytes modeBytes)) := by
  have outRead := bufBytes_of_obj F s out buffer outBytes (by simp only [Host.Ts.St.obj?,hb]) hbk
  rw [step_ffi_decoded F s fn types symbol returns fo signature₀ receiver signature _ _ native status0 [(out,0,writes)]
    hc (by simp only [Host.Ts.St.obj?,hf]) hk (by simp only [Host.Ts.St.obj?,ht]) htk
    (decode_quantized s out hx hw hsc hbi tr group bits modeBuffer stream outBytes modeBytes outRead hm) nativeCall]
  exact ffiDone_status0_buffer F s native out 0 buffer outBytes writes symbol _
    (by simp only [Host.Ts.St.obj?,hb]) hbk

/-- The real ten-argument ABI and all its writes, numeric status and event
frame, with target native calls derived from fixed source dimension roles. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types out hx hw hsc hbi x w sc bi modeBuffer stream group bits : Nat) (tr : Bool) (rows cols : Int)
    (fo signature₀ outObject modeObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (modeBytes₀ : List Byte) (xn wn sn bn : Node)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat hx),.big (Int.ofNat hw),.big (Int.ofNat hsc),
      .big (Int.ofNat hbi),.bool tr,.big (Int.ofNat (packedOptInt group)),.big (Int.ofNat (packedOptInt bits)),
      .ptr (.js modeBuffer) 0,.big (Int.ofNat stream)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (ho₀ : s₀.heap.get out = some (.obj outObject)) (hok₀ : outObject.kind = .buf (cellParts .u64 (.big (Int.ofNat 0)) 8 0))
    (hm₀ : s₀.heap.get modeBuffer = some (.obj modeObject)) (hmk₀ : modeObject.kind = .buf modeBytes₀)
    (signatureFrame : ¬ framed types) (handlesLive : listSupport H [hx,hw,hsc,hbi])
    (producers : Host.Mlx.Ffi.nodesOf s₀.ffi.mlx [hx,hw,hsc,hbi] = some [x,w,sc,bi])
    (sourceX : s₀.ffi.mlx.nodes.get x = some xn) (sourceW : s₀.ffi.mlx.nodes.get w = some wn)
    (sourceSc : s₀.ffi.mlx.nodes.get sc = some sn) (sourceBi : s₀.ffi.mlx.nodes.get bi = some bn)
    (mode : cstrArg (.jsPtr modeBuffer 0 modeBytes₀) = some chars!"affine")
    (sourceGeometry : QmmGeometry ν₀ tr bits rows cols (roles x).shape (roles w).shape (roles sc).shape (roles bi).shape)
    (targetGeometry : QmmGeometry ν tr bits rows cols (roles x).shape (roles w).shape (roles sc).shape (roles bi).shape)
    (weightDtype : (roles w).dtype = dtUint32) (nonzero : Nat.beq bits 0 = false)
    (float : isFloat (promote (roles x).dtype (promote (roles sc).dtype (roles bi).dtype)) = true)
    (outerExact : F64.toInt? (F64.ofInt (qmmOuter tr bits rows cols)) = some (qmmOuter tr bits rows cols))
    (groupBound : group < 2^32) (bitsBound : bits < 2^32)
    (argumentRoles : ListR (fun r v => r.role.Holds ν C R v)
      (arguments out hx hw hsc hbi tr group bits modeBuffer stream) (callArguments s.ctl))
    (outputRole : (Host.Ts.Owned.Annotated.fixedBufferRole VectorGetHost.nullRole).Holds ν C R (objectKindAt s (R.a out)))
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64) :
    ∃ t,
      interpC (step Host.Load.ffi s₀).run C₀ = some
        (finishBuffer s₀ (resultWorld s₀.ffi x w sc bi tr group bits rows cols xn sn bn) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
          symbol (callArgs out hx hw hsc hbi tr group bits modeBuffer stream (cellParts .u64 (.big (Int.ofNat 0)) 8 0) modeBytes₀),C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C
          (nodeWrite roles s₀.ffi.mlx.nnext (qmmRole roles x w sc bi tr group bits rows cols)) boundary objects
          (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host)
        R live framed before after old old'
        (finishBuffer s₀ (resultWorld s₀.ffi x w sc bi tr group bits rows cols xn sn bn) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
          symbol (callArgs out hx hw hsc hbi tr group bits modeBuffer stream (cellParts .u64 (.big (Int.ofNat 0)) 8 0) modeBytes₀)) t ∧
      (slotKindRole s₀.ffi.mlx.next).Holds ν C R (objectKindAt t (R.a out)) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  have outLive : live out := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.1
  have modeLive : live modeBuffer := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.2.2.2.2.2.2.2.2.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject fn fo calleeLive
    (h.heap.function_notFramed fn fo _ calleeLive hf₀ hk₀) hf₀
  have signatureLive : live types := by have hl := hol.1; rw [hk₀] at hl; exact hl.1.2.1.2.1
  obtain ⟨fo',data,this,args,hc,hfo,hfk,hd,_,_⟩ := h.native_call_view fn fo (.ffi .symbol) _ receiver _ hc₀ hf₀ hk₀
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr
        have argsExact := Host.Ts.Owned.Annotated.FixedArgument.list_exact _ argumentRoles
        simp only [hc,callArguments] at argsExact
        rw [argsExact] at hc
        simp only [arguments,Host.Ts.Owned.Annotated.FixedArgument.value,List.map_cons,List.map_nil] at hc
        obtain ⟨signature',hto,htr,_⟩ := h.heap.readObject types signature₀ signatureLive signatureFrame ht₀
        have htKind := htr.kind
        rw [htk₀] at htKind
        obtain ⟨tys,htKind,htys⟩ := kind_array htKind
        have exactTypes := string_values_exact [chars!"ptr",chars!"u64",chars!"u64",chars!"u64",chars!"u64",chars!"bool",
          chars!"u64",chars!"u64",chars!"cstring",chars!"u64"] htys
        rw [exactTypes] at htKind
        obtain ⟨out',ho,hok,hro,hlo,hbo⟩ := h.read_fixed_buffer out outObject _ VectorGetHost.nullRole outLive ho₀ hok₀ outputRole
        rw [VectorGetHost.null_bytes] at hok hbo
        obtain ⟨mode',hm,hrm,_⟩ := h.heap.readObject modeBuffer modeObject modeLive
          (h.heap.buffer_notFramed modeBuffer modeObject modeBytes₀ modeLive hm₀ hmk₀) hm₀
        have modeKind := hrm.kind
        rw [hmk₀] at modeKind
        obtain ⟨modeBytes,modeKind,hbm⟩ := kind_buffer modeKind
        let oldBytes := cellParts .u64 (.big (Int.ofNat 0)) 8 0
        let args₀ := callArgs out hx hw hsc hbi tr group bits modeBuffer stream oldBytes modeBytes₀
        let args' := callArgs (R.a out) (R.handle hx) (R.handle hw) (R.handle hsc) (R.handle hbi) tr group bits
          (R.a modeBuffer) (R.handle stream) oldBytes modeBytes
        have native := h.native.2
        obtain ⟨xn',sn',bn',sourceCall,targetCall,nativeAfter⟩ := native.qmm_null
          (.jsPtr out 0 oldBytes) (.jsPtr (R.a out) 0 oldBytes) (.big (Int.ofNat stream)) (.big (Int.ofNat (R.handle stream)))
          out 0 hx hw hsc hbi x w sc bi group bits modeBuffer modeBytes₀ modeBytes tr rows cols xn wn sn bn
          handlesLive producers sourceX sourceW sourceSc sourceBi rfl rfl mode hbm sourceGeometry targetGeometry
          weightDtype nonzero float outerExact groupBound bitsBound sourceNodes targetNodes sourceHandles targetHandles
        let native₀ := resultWorld s₀.ffi x w sc bi tr group bits rows cols xn sn bn
        let native' := resultWorld s.ffi (R.node x) (R.node w) (R.node sc) (R.node bi) tr group bits rows cols xn' sn' bn'
        have nativeRelated : VectorHost.NativeRelation ν₀ ν C₀ C
            (nodeWrite roles s₀.ffi.mlx.nnext (qmmRole roles x w sc bi tr group bits rows cols)) boundary objects
            (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R native₀ native' :=
          ⟨h.native.1,nativeAfter⟩
        let writes₀ := cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0
        let writes' := cellParts .u64 (.big (Int.ofNat s.ffi.mlx.next)) 8 0
        let t := finishBuffer s native' (R.a out) 0 out' oldBytes writes' symbol args'
        have zeroRole : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
        have argsRelated : ForestR (NumberRoles ν₀ ν C₀ C) R (args₀.map Parametric.arg) (args'.map Parametric.arg) := by
          refine .cons (.node _ (.cons (.address out) (.cons (.atom _ _) (.cons (bytes_roles hbo) .nil)))) ?_
          refine .cons (.node _ (.cons (.value (.handle hx)) .nil)) ?_
          refine .cons (.node _ (.cons (.value (.handle hw)) .nil)) ?_
          refine .cons (.node _ (.cons (.value (.handle hsc)) .nil)) ?_
          refine .cons (.node _ (.cons (.value (.handle hbi)) .nil)) ?_
          refine .cons (.node _ (.cons (.atom _ _) .nil)) ?_
          refine .cons (.node _ (.cons (.value (.ordinaryBig (Int.ofNat (packedOptInt group)))) .nil)) ?_
          refine .cons (.node _ (.cons (.value (.ordinaryBig (Int.ofNat (packedOptInt bits)))) .nil)) ?_
          refine .cons (.node _ (.cons (.address modeBuffer) (.cons (.atom _ _) (.cons (bytes_roles hbm) .nil)))) ?_
          exact .cons (.node _ (.cons (.value (.handle stream)) .nil)) .nil
        have eventRoles : TreeR (NumberRoles ν₀ ν C₀ C) R (event ⟨symbol,args₀,status0⟩) (event ⟨symbol,args',status0⟩) :=
          .node _ (.cons (.atom _ _) (.cons (.node _ argsRelated) (.cons (.node _ (.cons (.number zeroRole) .nil)) .nil)))
        have writesRelated : ListR (ByteR (NumberRoles ν₀ ν C₀ C) R) writes₀ writes' := by
          dsimp only [writes₀,writes']
          rw [← native.handleMap.head]
          exact Host.Mlx.Ffi.Parametric.cellParts_roles (.handle _) .u64 8 0
        have targetOutBound := Nat.lt_trans (h.heap.targetBound out outLive) targetHeap
        have post := h.finishBuffer_event native₀ native' nativeRelated out 0 outObject out' oldBytes oldBytes writes₀ writes'
          symbol args₀ args' outLive ho₀ hok₀ hro hlo hbo writesRelated sourceHeap targetOutBound zeroRole eventRoles
        refine ⟨t,?_,?_,post,?_⟩
        · change interpC (step F s₀).run C₀ = _
          have call : F.call s₀.ffi symbol args₀ = M.pure (some (native₀,status0,[(out,0,writes₀)])) := by
            simpa only [F,symbol,args₀,callArgs,native₀,resultWorld,writes₀,u64Write,Int.ofNat_eq_natCast] using
              Host.Load.Owned.load_unary_call s₀.ffi symbol _ _ _ (by decide +kernel) sourceCall
          rw [step_quantized_eq s₀ fn types out hx hw hsc hbi tr group bits modeBuffer stream fo signature₀ outObject returns receiver
            oldBytes modeBytes₀ native₀ writes₀ hc₀ hf₀ hk₀ ht₀ htk₀ ho₀ hok₀
            (bufBytes_of_obj F s₀ modeBuffer modeObject modeBytes₀ (by simp only [Host.Ts.St.obj?,hm₀]) hmk₀) call]
          rfl
        · change interpC (step F s).run C = _
          have call : F.call s.ffi symbol args' = M.pure (some (native',status0,[(R.a out,0,writes')])) := by
            simpa only [F,symbol,args',callArgs,native',resultWorld,writes',u64Write,Int.ofNat_eq_natCast] using
              Host.Load.Owned.load_unary_call s.ffi symbol _ _ _ (by decide +kernel) targetCall
          rw [step_quantized_eq s (R.a fn) (R.a types) (R.a out) (R.handle hx) (R.handle hw) (R.handle hsc) (R.handle hbi)
            tr group bits (R.a modeBuffer) (R.handle stream) fo' signature' out' returns this oldBytes modeBytes native' writes'
            hc hfo hfk hto htKind ho hok
            (bufBytes_of_obj F s (R.a modeBuffer) mode' modeBytes (by simp only [Host.Ts.St.obj?,hm]) modeKind) call]
          rfl
        · have patch : oldBytes.take 0 ++ writes' ++ oldBytes.drop (0 + len writes') = writes' := rfl
          simp only [objectKindAt,t,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,Host.Ts.St.setObj,
            Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ targetOutBound,patch]
          dsimp only [writes']
          rw [← native.handleMap.head]
          exact slot_role ν C R s₀.ffi.mlx.next

end Host.Load.Run.Full.Ordinary.QuantizedHost

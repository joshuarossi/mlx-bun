import host.mlx.NativeAttentionRoles
import host.mlx.NativeQuantizedHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.AttentionHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.NativeRoles.Arguments Host.Mlx.Ffi.Annotated

abbrev F : Host.Ts.Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
def symbol : Name := chars!"mlx_fast_scaled_dot_product_attention"
def signature : List Val := [.str chars!"ptr",.str chars!"u64",.str chars!"u64",.str chars!"u64",.str chars!"f32",
  .str chars!"cstring",.str chars!"u64",.str chars!"u64",.str chars!"bool",.str chars!"u64"]
def arguments (out hq hk hv maskBuffer stream : Nat) (scale : F64) (force : Bool) : List Host.Ts.Owned.Annotated.FixedArgument :=
  [.pointer out 0,.handle hq,.handle hk,.handle hv,.literal scale,.pointer maskBuffer 0,.integer 0,.integer 0,.boolean force,.handle stream]
def scaleValue (raw : F64) : NumV := .lit (F64.un .f32 raw)
def scaleRole (raw : F64) : Number := .literal (.lit (F64.un .f32 raw))
def callArgs (out hq hk hv maskBuffer stream : Nat) (scale : F64) (force : Bool) (outBytes maskBytes : List Byte) : List Arg :=
  [.jsPtr out 0 outBytes,.big (Int.ofNat hq),.big (Int.ofNat hk),.big (Int.ofNat hv),.num (scaleValue scale),
    .jsPtr maskBuffer 0 maskBytes,.big 0,.big 0,.bool force,.big (Int.ofNat stream)]
def resultWorld (s : LSt) (q k v : Nat) (scale : F64) (mask : Name) (qn kn vn : Node) : LSt :=
  {s with mlx := NativeRoles.createZero s.mlx (attentionNode q k v (scaleValue scale) mask qn kn vn)}
theorem scale_holds (ν : Nat → F64) (C : CSrv) (scale : F64) :
    (scaleRole scale).Holds ν C (scaleValue scale) := .literal _ _ rfl

theorem step_attention_eq (s : Host.Ts.St LSt) (fn types out hq hk hv maskBuffer stream : Nat)
    (scale : F64) (force : Bool) (fo signature₀ buffer : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (outBytes maskBytes : List Byte) (native : LSt) (writes : List Byte)
    (hc : s.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat hq),.big (Int.ofNat hk),.big (Int.ofNat hv),
      .num (.lit scale),.ptr (.js maskBuffer) 0,.big 0,.big 0,.bool force,.big (Int.ofNat stream)])
    (hf : s.heap.get fn = some (.obj fo))
    (hkind : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht : s.heap.get types = some (.obj signature₀)) (htk : signature₀.kind = .array signature)
    (hb : s.heap.get out = some (.obj buffer)) (hbk : buffer.kind = .buf outBytes)
    (hm : bufBytes F s maskBuffer = some maskBytes)
    (nativeCall : F.call s.ffi symbol (callArgs out hq hk hv maskBuffer stream scale force outBytes maskBytes) =
      M.pure (some (native,status0,[(out,0,writes)]))) :
    step F s = M.pure (finishBuffer s native out 0 buffer outBytes writes symbol
      (callArgs out hq hk hv maskBuffer stream scale force outBytes maskBytes)) := by
  have outRead := bufBytes_of_obj F s out buffer outBytes (by simp only [Host.Ts.St.obj?,hb]) hbk
  have decode : decodeArgs F s signature [.ptr (.js out) 0,.big (Int.ofNat hq),.big (Int.ofNat hk),.big (Int.ofNat hv),
      .num (.lit scale),.ptr (.js maskBuffer) 0,.big 0,.big 0,.bool force,.big (Int.ofNat stream)] =
      M.pure (some (callArgs out hq hk hv maskBuffer stream scale force outBytes maskBytes)) := by
    funext β k
    simp only [signature,callArgs,scaleValue,decodeArgs,decodeArg_js_pointer F s out 0 outBytes outRead,decode_u64_big,
      decode_f32_literal,decode_cstring_pointer F s maskBuffer 0 maskBytes hm,QuantizedHost.decode_boolean,
      List.drop_zero,M.bind,M.pure,Option.map_some]
  rw [step_ffi_decoded F s fn types symbol returns fo signature₀ receiver signature _ _ native status0 [(out,0,writes)]
    hc (by simp only [Host.Ts.St.obj?,hf]) hkind (by simp only [Host.Ts.St.obj?,ht]) htk decode nativeCall]
  exact ffiDone_status0_buffer F s native out 0 buffer outBytes writes symbol _ (by simp only [Host.Ts.St.obj?,hb]) hbk

/-- Original attention host dispatch with real f32 scale conversion and
source-derived C-string parsing, rank guards, graph allocation and writes. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types out hq hk hv q k v maskBuffer stream : Nat) (scale : F64) (force : Bool)
    (fo signature₀ outObject maskObject : Host.Ts.Obj) (returns : Name) (receiver : Val) (maskBytes₀ : List Byte)
    (mask : Name) (qn kn vn : Node)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat hq),.big (Int.ofNat hk),.big (Int.ofNat hv),
      .num (.lit scale),.ptr (.js maskBuffer) 0,.big 0,.big 0,.bool force,.big (Int.ofNat stream)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (ho₀ : s₀.heap.get out = some (.obj outObject)) (hok₀ : outObject.kind = .buf (cellParts .u64 (.big (Int.ofNat 0)) 8 0))
    (hm₀ : s₀.heap.get maskBuffer = some (.obj maskObject)) (hmk₀ : maskObject.kind = .buf maskBytes₀)
    (signatureFrame : ¬ framed types) (handlesLive : listSupport H [hq,hk,hv])
    (producers : Host.Mlx.Ffi.nodesOf s₀.ffi.mlx [hq,hk,hv] = some [q,k,v])
    (sourceQ : s₀.ffi.mlx.nodes.get q = some qn) (sourceK : s₀.ffi.mlx.nodes.get k = some kn) (sourceV : s₀.ffi.mlx.nodes.get v = some vn)
    (decode : cstrArg (.jsPtr maskBuffer 0 maskBytes₀) = some mask)
    (qrank : len (roles q).shape = 4) (krank : len (roles k).shape = 4) (vrank : len (roles v).shape = 4)
    (argumentRoles : ListR (fun r v => r.role.Holds ν C R v)
      (arguments out hq hk hv maskBuffer stream scale force) (callArguments s.ctl))
    (outputRole : (Host.Ts.Owned.Annotated.fixedBufferRole VectorGetHost.nullRole).Holds ν C R (objectKindAt s (R.a out)))
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64) :
    ∃ t,
      interpC (step Host.Load.ffi s₀).run C₀ = some
        (finishBuffer s₀ (resultWorld s₀.ffi q k v scale mask qn kn vn) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
          symbol (callArgs out hq hk hv maskBuffer stream scale force (cellParts .u64 (.big (Int.ofNat 0)) 8 0) maskBytes₀),C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (nodeWrite roles s₀.ffi.mlx.nnext (attentionRole roles q k v (scaleRole scale) mask)) boundary objects
          (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host)
        R live framed before after old old'
        (finishBuffer s₀ (resultWorld s₀.ffi q k v scale mask qn kn vn) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
          symbol (callArgs out hq hk hv maskBuffer stream scale force (cellParts .u64 (.big (Int.ofNat 0)) 8 0) maskBytes₀)) t ∧
      (slotKindRole s₀.ffi.mlx.next).Holds ν C R (objectKindAt t (R.a out)) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  have outLive : live out := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.1
  have maskLive : live maskBuffer := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.2.2.2.2.2.1
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
        have exactTypes := string_values_exact [chars!"ptr",chars!"u64",chars!"u64",chars!"u64",chars!"f32",chars!"cstring",
          chars!"u64",chars!"u64",chars!"bool",chars!"u64"] htys
        rw [exactTypes] at htKind
        obtain ⟨out',ho,hok,hro,hlo,hbo⟩ := h.read_fixed_buffer out outObject _ VectorGetHost.nullRole outLive ho₀ hok₀ outputRole
        rw [VectorGetHost.null_bytes] at hok hbo
        obtain ⟨mask',hm,hrm,_⟩ := h.heap.readObject maskBuffer maskObject maskLive
          (h.heap.buffer_notFramed maskBuffer maskObject maskBytes₀ maskLive hm₀ hmk₀) hm₀
        have maskKind := hrm.kind
        rw [hmk₀] at maskKind
        obtain ⟨maskBytes,maskKind,hbm⟩ := kind_buffer maskKind
        let oldBytes := cellParts .u64 (.big (Int.ofNat 0)) 8 0
        let args₀ := callArgs out hq hk hv maskBuffer stream scale force oldBytes maskBytes₀
        let args' := callArgs (R.a out) (R.handle hq) (R.handle hk) (R.handle hv) (R.a maskBuffer) (R.handle stream) scale force oldBytes maskBytes
        have native := h.native.2
        obtain ⟨qn',kn',vn',sourceCall,targetCall,nativeAfter⟩ := native.attention_null
          (.jsPtr out 0 oldBytes) (.jsPtr (R.a out) 0 oldBytes) (.big (Int.ofNat stream)) (.big (Int.ofNat (R.handle stream)))
          out 0 hq hk hv q k v maskBuffer maskBytes₀ maskBytes mask force qn kn vn (scaleRole scale) (scaleValue scale) (scaleValue scale)
          (scale_holds ν₀ C₀ scale) (scale_holds ν C scale) handlesLive producers sourceQ sourceK sourceV rfl rfl decode hbm qrank krank vrank
          sourceNodes targetNodes sourceHandles targetHandles
        let native₀ := resultWorld s₀.ffi q k v scale mask qn kn vn
        let native' := resultWorld s.ffi (R.node q) (R.node k) (R.node v) scale mask qn' kn' vn'
        have nativeRelated : VectorHost.NativeRelation ν₀ ν C₀ C
            (nodeWrite roles s₀.ffi.mlx.nnext (attentionRole roles q k v (scaleRole scale) mask)) boundary objects
            (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R native₀ native' :=
          ⟨h.native.1,nativeAfter⟩
        let writes₀ := cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0
        let writes' := cellParts .u64 (.big (Int.ofNat s.ffi.mlx.next)) 8 0
        let t := finishBuffer s native' (R.a out) 0 out' oldBytes writes' symbol args'
        have zeroRole : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
        have scalePair := Number.paired (scale_holds ν₀ C₀ scale) (scale_holds ν C scale)
        have argsRelated : ForestR (NumberRoles ν₀ ν C₀ C) R (args₀.map Parametric.arg) (args'.map Parametric.arg) := by
          refine .cons (.node _ (.cons (.address out) (.cons (.atom _ _) (.cons (bytes_roles hbo) .nil)))) ?_
          refine .cons (.node _ (.cons (.value (.handle hq)) .nil)) ?_
          refine .cons (.node _ (.cons (.value (.handle hk)) .nil)) ?_
          refine .cons (.node _ (.cons (.value (.handle hv)) .nil)) ?_
          refine .cons (.node _ (.cons (.number scalePair) .nil)) ?_
          refine .cons (.node _ (.cons (.address maskBuffer) (.cons (.atom _ _) (.cons (bytes_roles hbm) .nil)))) ?_
          refine .cons (.node _ (.cons (.value (.ordinaryBig 0)) .nil)) ?_
          refine .cons (.node _ (.cons (.value (.ordinaryBig 0)) .nil)) ?_
          refine .cons (.node _ (.cons (.atom _ _) .nil)) ?_
          exact .cons (.node _ (.cons (.value (.handle stream)) .nil)) .nil
        have eventRoles : TreeR (NumberRoles ν₀ ν C₀ C) R (event ⟨symbol,args₀,status0⟩) (event ⟨symbol,args',status0⟩) :=
          .node _ (.cons (.atom _ _) (.cons (.node _ argsRelated) (.cons (.node _ (.cons (.number zeroRole) .nil)) .nil)))
        have writesRelated : ListR (ByteR (NumberRoles ν₀ ν C₀ C) R) writes₀ writes' := by
          dsimp only [writes₀,writes']; rw [← native.handleMap.head]
          exact Host.Mlx.Ffi.Parametric.cellParts_roles (.handle _) .u64 8 0
        have targetOutBound := Nat.lt_trans (h.heap.targetBound out outLive) targetHeap
        have post := h.finishBuffer_event native₀ native' nativeRelated out 0 outObject out' oldBytes oldBytes writes₀ writes'
          symbol args₀ args' outLive ho₀ hok₀ hro hlo hbo writesRelated sourceHeap targetOutBound zeroRole eventRoles
        refine ⟨t,?_,?_,post,?_⟩
        · change interpC (step F s₀).run C₀ = _
          have call : F.call s₀.ffi symbol args₀ = M.pure (some (native₀,status0,[(out,0,writes₀)])) := by
            simpa only [F,symbol,args₀,callArgs,native₀,resultWorld,writes₀,u64Write,Int.ofNat_eq_natCast] using
              Host.Load.Owned.load_unary_call s₀.ffi symbol _ _ _ (by decide +kernel) sourceCall
          rw [step_attention_eq s₀ fn types out hq hk hv maskBuffer stream scale force fo signature₀ outObject returns receiver
            oldBytes maskBytes₀ native₀ writes₀ hc₀ hf₀ hk₀ ht₀ htk₀ ho₀ hok₀
            (bufBytes_of_obj F s₀ maskBuffer maskObject maskBytes₀ (by simp only [Host.Ts.St.obj?,hm₀]) hmk₀) call]
          rfl
        · change interpC (step F s).run C = _
          have call : F.call s.ffi symbol args' = M.pure (some (native',status0,[(R.a out,0,writes')])) := by
            simpa only [F,symbol,args',callArgs,native',resultWorld,writes',u64Write,Int.ofNat_eq_natCast] using
              Host.Load.Owned.load_unary_call s.ffi symbol _ _ _ (by decide +kernel) targetCall
          rw [step_attention_eq s (R.a fn) (R.a types) (R.a out) (R.handle hq) (R.handle hk) (R.handle hv)
            (R.a maskBuffer) (R.handle stream) scale force fo' signature' out' returns this oldBytes maskBytes native' writes'
            hc hfo hfk hto htKind ho hok
            (bufBytes_of_obj F s (R.a maskBuffer) mask' maskBytes (by simp only [Host.Ts.St.obj?,hm]) maskKind) call]
          rfl
        · have patch : oldBytes.take 0 ++ writes' ++ oldBytes.drop (0 + len writes') = writes' := rfl
          simp only [objectKindAt,t,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,Host.Ts.St.setObj,
            Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ targetOutBound,patch]
          dsimp only [writes']; rw [← native.handleMap.head]
          exact slot_role ν C R s₀.ffi.mlx.next

end Host.Load.Run.Full.Ordinary.AttentionHost

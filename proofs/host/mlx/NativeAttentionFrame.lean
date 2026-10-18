import host.mlx.NativeAttentionHost
import host.mlx.NativeWritesFrame

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.AttentionHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.NativeRoles.Arguments Host.Mlx.Ffi.Annotated

/-- Original attention host dispatch with real f32 scale conversion and
source-derived C-string parsing, rank guards, graph allocation and writes. -/
theorem from_source_framed (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
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
      (slotKindRole s₀.ffi.mlx.next).Holds ν C R (objectKindAt t (R.a out)) ∧
      Host.Ts.Owned.Annotated.NativeHeapFrame s₀ (finishBuffer s₀ (resultWorld s₀.ffi q k v scale mask qn kn vn) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
          symbol (callArgs out hq hk hv maskBuffer stream scale force (cellParts .u64 (.big (Int.ofNat 0)) 8 0) maskBytes₀)) ∧
      Host.Ts.Owned.Annotated.NativeHeapFrame s t ∧
      (∀ a, a ≠ R.a out → t.heap.get a = s.heap.get a) ∧ t.ctl = .ret (.num zeroN) := by
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
        refine ⟨t,?_,?_,post,?_,?_,?_,?_,rfl⟩
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

        · exact Host.Ts.Owned.Annotated.NativeHeapFrame.finishBuffer s₀ native₀ out 0 outObject oldBytes writes₀
            symbol args₀ ho₀ hok₀ sourceHeap
        · exact Host.Ts.Owned.Annotated.NativeHeapFrame.finishBuffer s native' (R.a out) 0 out' oldBytes writes'
            symbol args' ho hok targetOutBound
        · intro a different
          change (s.heap.set (R.a out) _).get a = s.heap.get a
          rw [PTrie.get_set_u64 _ _ _ targetOutBound,ite_eq_right different]

end Host.Load.Run.Full.Ordinary.AttentionHost

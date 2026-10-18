import host.mlx.NativeRmsRoles
import host.mlx.NativeReshapeHost
import host.mlx.NativeWritesFrame

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.RmsHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.NativeRoles.Arguments Host.Mlx.Ffi.Annotated

abbrev F : Host.Ts.Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
def symbol : Name := chars!"mlx_fast_rms_norm"
def signature : List Val := [.str chars!"ptr",.str chars!"u64",.str chars!"u64",.str chars!"f32",.str chars!"u64"]
def arguments (out hx hw stream : Nat) (epsilon : F64) : List Host.Ts.Owned.Annotated.FixedArgument :=
  [.pointer out 0,.handle hx,.handle hw,.literal epsilon,.handle stream]
def epsilonValue (raw : F64) : NumV := .lit (F64.un .f32 raw)
def epsilonRole (raw : F64) : Number := .literal (.lit (F64.un .f32 raw))
def callArgs (out hx hw stream : Nat) (epsilon : F64) (bytes : List Byte) : List Arg :=
  [.jsPtr out 0 bytes,.big (Int.ofNat hx),.big (Int.ofNat hw),.num (epsilonValue epsilon),.big (Int.ofNat stream)]
def resultWorld (s : LSt) (x w : Nat) (epsilon : F64) (xn wn : Node) : LSt :=
  {s with mlx := NativeRoles.createZero s.mlx (rmsNode x w (epsilonValue epsilon) xn.shape (promote xn.dtype wn.dtype))}

theorem epsilon_holds (ν : Nat → F64) (C : CSrv) (epsilon : F64) :
    (epsilonRole epsilon).Holds ν C (epsilonValue epsilon) := .literal _ _ rfl

theorem step_rms_eq (s : Host.Ts.St LSt) (fn types out hx hw stream : Nat) (epsilon : F64)
    (returns : Name) (fo signature₀ buffer : Host.Ts.Obj) (receiver : Val) (bytes : List Byte) (native : LSt) (writes : List Byte)
    (hc : s.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat hx),.big (Int.ofNat hw),.num (.lit epsilon),.big (Int.ofNat stream)])
    (hf : s.heap.get fn = some (.obj fo))
    (hk : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht : s.heap.get types = some (.obj signature₀)) (htk : signature₀.kind = .array signature)
    (hb : s.heap.get out = some (.obj buffer)) (hbk : buffer.kind = .buf bytes)
    (nativeCall : F.call s.ffi symbol (callArgs out hx hw stream epsilon bytes) = M.pure (some (native,status0,[(out,0,writes)]))) :
    step F s = M.pure (finishBuffer s native out 0 buffer bytes writes symbol (callArgs out hx hw stream epsilon bytes)) := by
  have outRead := bufBytes_of_obj F s out buffer bytes (by simp only [Host.Ts.St.obj?,hb]) hbk
  have decode : decodeArgs F s signature
      [.ptr (.js out) 0,.big (Int.ofNat hx),.big (Int.ofNat hw),.num (.lit epsilon),.big (Int.ofNat stream)] =
      M.pure (some (callArgs out hx hw stream epsilon bytes)) := by
    funext β k
    simp only [signature,callArgs,epsilonValue,decodeArgs,decodeArg_js_pointer F s out 0 bytes outRead,
      decode_u64_big,decode_f32_literal,M.bind,M.pure,List.drop_zero,Option.map_some]
  rw [step_ffi_decoded F s fn types symbol returns fo signature₀ receiver signature _ _ native status0 [(out,0,writes)]
    hc (by simp only [Host.Ts.St.obj?,hf]) hk (by simp only [Host.Ts.St.obj?,ht]) htk decode nativeCall]
  exact ffiDone_status0_buffer F s native out 0 buffer bytes writes symbol _ (by simp only [Host.Ts.St.obj?,hb]) hbk

/-- Weighted RMS norm with the actual f32 epsilon conversion, fixed feature
geometry, original native allocation and the complete host state relation. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types out hx hw x w stream : Nat) (epsilon : F64) (returns : Name) (fo signature₀ outObject : Host.Ts.Obj)
    (receiver : Val) (xn wn : Node)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat hx),.big (Int.ofNat hw),.num (.lit epsilon),.big (Int.ofNat stream)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (ho₀ : s₀.heap.get out = some (.obj outObject)) (hok₀ : outObject.kind = .buf (cellParts .u64 (.big (Int.ofNat 0)) 8 0))
    (signatureFrame : ¬ framed types) (handlesLive : listSupport H [hx,hw]) (weightNonzero : hw ≠ 0)
    (producers : Host.Mlx.Ffi.nodesOf s₀.ffi.mlx [hx,hw] = some [x,w])
    (sourceX : s₀.ffi.mlx.nodes.get x = some xn) (sourceW : s₀.ffi.mlx.nodes.get w = some wn)
    (geometry : RmsGeometry (roles x).shape (roles w).shape)
    (float : isFloat (promote (roles x).dtype (roles w).dtype) = true)
    (argumentRoles : ListR (fun r v => r.role.Holds ν C R v) (arguments out hx hw stream epsilon) (callArguments s.ctl))
    (outputRole : (Host.Ts.Owned.Annotated.fixedBufferRole VectorGetHost.nullRole).Holds ν C R (objectKindAt s (R.a out)))
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64) :
    ∃ t,
      interpC (step Host.Load.ffi s₀).run C₀ = some
        (finishBuffer s₀ (resultWorld s₀.ffi x w epsilon xn wn) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
          symbol (callArgs out hx hw stream epsilon (cellParts .u64 (.big (Int.ofNat 0)) 8 0)),C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (nodeWrite roles s₀.ffi.mlx.nnext (rmsRole roles x w (epsilonRole epsilon))) boundary objects
          (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host)
        R live framed before after old old'
        (finishBuffer s₀ (resultWorld s₀.ffi x w epsilon xn wn) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
          symbol (callArgs out hx hw stream epsilon (cellParts .u64 (.big (Int.ofNat 0)) 8 0))) t ∧
      (slotKindRole s₀.ffi.mlx.next).Holds ν C R (objectKindAt t (R.a out)) ∧
      Host.Ts.Owned.Annotated.NativeHeapFrame s₀
        (finishBuffer s₀ (resultWorld s₀.ffi x w epsilon xn wn) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
          symbol (callArgs out hx hw stream epsilon (cellParts .u64 (.big (Int.ofNat 0)) 8 0))) ∧
      Host.Ts.Owned.Annotated.NativeHeapFrame s t ∧
      (∀ a, a ≠ R.a out → t.heap.get a = s.heap.get a) ∧ t.ctl = .ret (.num zeroN) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  have outLive : live out := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.1
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
        have exactTypes := string_values_exact [chars!"ptr",chars!"u64",chars!"u64",chars!"f32",chars!"u64"] htys
        rw [exactTypes] at htKind
        obtain ⟨out',ho,hok,hro,hlo,hbo⟩ := h.read_fixed_buffer out outObject _ VectorGetHost.nullRole outLive ho₀ hok₀ outputRole
        rw [VectorGetHost.null_bytes] at hok hbo
        let oldBytes := cellParts .u64 (.big (Int.ofNat 0)) 8 0
        let args₀ := callArgs out hx hw stream epsilon oldBytes
        let args' := callArgs (R.a out) (R.handle hx) (R.handle hw) (R.handle stream) epsilon oldBytes
        have native := h.native.2
        obtain ⟨xn',wn',sourceCall,targetCall,nativeAfter⟩ := native.rms_null
          (.jsPtr out 0 oldBytes) (.jsPtr (R.a out) 0 oldBytes) (.big (Int.ofNat stream)) (.big (Int.ofNat (R.handle stream)))
          out 0 hx hw x w xn wn (epsilonRole epsilon) (epsilonValue epsilon) (epsilonValue epsilon)
          (epsilon_holds ν₀ C₀ epsilon) (epsilon_holds ν C epsilon) handlesLive weightNonzero producers sourceX sourceW rfl rfl geometry float
          sourceNodes targetNodes sourceHandles targetHandles
        let native₀ := resultWorld s₀.ffi x w epsilon xn wn
        let native' := resultWorld s.ffi (R.node x) (R.node w) epsilon xn' wn'
        have nativeRelated : VectorHost.NativeRelation ν₀ ν C₀ C
            (nodeWrite roles s₀.ffi.mlx.nnext (rmsRole roles x w (epsilonRole epsilon))) boundary objects
            (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R native₀ native' :=
          ⟨h.native.1,nativeAfter⟩
        let writes₀ := cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0
        let writes' := cellParts .u64 (.big (Int.ofNat s.ffi.mlx.next)) 8 0
        let t := finishBuffer s native' (R.a out) 0 out' oldBytes writes' symbol args'
        have zeroRole : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
        have epsPair := Number.paired (epsilon_holds ν₀ C₀ epsilon) (epsilon_holds ν C epsilon)
        have argsRelated : ForestR (NumberRoles ν₀ ν C₀ C) R (args₀.map Parametric.arg) (args'.map Parametric.arg) :=
          .cons (.node _ (.cons (.address out) (.cons (.atom _ _) (.cons (bytes_roles hbo) .nil))))
            (.cons (.node _ (.cons (.value (.handle hx)) .nil))
              (.cons (.node _ (.cons (.value (.handle hw)) .nil))
                (.cons (.node _ (.cons (.number epsPair) .nil)) (.cons (.node _ (.cons (.value (.handle stream)) .nil)) .nil))))
        have eventRoles : TreeR (NumberRoles ν₀ ν C₀ C) R (event ⟨symbol,args₀,status0⟩) (event ⟨symbol,args',status0⟩) :=
          .node _ (.cons (.atom _ _) (.cons (.node _ argsRelated) (.cons (.node _ (.cons (.number zeroRole) .nil)) .nil)))
        have writesRelated : ListR (ByteR (NumberRoles ν₀ ν C₀ C) R) writes₀ writes' := by
          dsimp only [writes₀,writes']
          rw [← native.handleMap.head]
          exact Host.Mlx.Ffi.Parametric.cellParts_roles (.handle _) .u64 8 0
        have targetOutBound := Nat.lt_trans (h.heap.targetBound out outLive) targetHeap
        have post := h.finishBuffer_event native₀ native' nativeRelated out 0 outObject out' oldBytes oldBytes writes₀ writes'
          symbol args₀ args' outLive ho₀ hok₀ hro hlo hbo writesRelated sourceHeap targetOutBound zeroRole eventRoles
        refine ⟨t,?_,?_,post,?_,?_,?_,?_,rfl⟩
        · change interpC (step F s₀).run C₀ = _
          have call : F.call s₀.ffi symbol args₀ = M.pure (some (native₀,status0,[(out,0,writes₀)])) := by
            simpa only [F,symbol,args₀,callArgs,native₀,resultWorld,writes₀,u64Write,Int.ofNat_eq_natCast] using
              Host.Load.Owned.load_unary_call s₀.ffi symbol _ _ _ (by decide +kernel) sourceCall
          rw [step_rms_eq s₀ fn types out hx hw stream epsilon returns fo signature₀ outObject receiver oldBytes native₀ writes₀
            hc₀ hf₀ hk₀ ht₀ htk₀ ho₀ hok₀ call]
          rfl
        · change interpC (step F s).run C = _
          have call : F.call s.ffi symbol args' = M.pure (some (native',status0,[(R.a out,0,writes')])) := by
            simpa only [F,symbol,args',callArgs,native',resultWorld,writes',u64Write,Int.ofNat_eq_natCast] using
              Host.Load.Owned.load_unary_call s.ffi symbol _ _ _ (by decide +kernel) targetCall
          rw [step_rms_eq s (R.a fn) (R.a types) (R.a out) (R.handle hx) (R.handle hw) (R.handle stream) epsilon returns
            fo' signature' out' this oldBytes native' writes' hc hfo hfk hto htKind ho hok call]
          rfl
        · have patch : oldBytes.take 0 ++ writes' ++ oldBytes.drop (0 + len writes') = writes' := rfl
          simp only [objectKindAt,t,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,Host.Ts.St.setObj,
            Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ targetOutBound,patch]
          dsimp only [writes']
          rw [← native.handleMap.head]
          exact slot_role ν C R s₀.ffi.mlx.next
        · exact Host.Ts.Owned.Annotated.NativeHeapFrame.finishBuffer s₀ native₀ out 0 outObject oldBytes writes₀ symbol args₀
            ho₀ hok₀ sourceHeap
        · exact Host.Ts.Owned.Annotated.NativeHeapFrame.finishBuffer s native' (R.a out) 0 out' oldBytes writes' symbol args'
            ho hok targetOutBound
        · intro a different
          change (s.heap.set (R.a out) _).get a = s.heap.get a
          rw [PTrie.get_set_u64 _ _ _ targetOutBound,ite_eq_right different]

end Host.Load.Run.Full.Ordinary.RmsHost

import host.mlx.NativeConvHost
import host.mlx.NativeWritesFrame

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.ConvFamilyHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.NativeRoles.Arguments Host.Mlx.Ffi.Annotated

/-- Original convolution dispatch with the accepted output-buffer frame. -/
theorem from_source_framed (p : ConvParameters) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types out hx hy x y stream : Nat) (returns : Name) (fo signature₀ outObject : Host.Ts.Obj)
    (receiver : Val) (xn yn : Node) (output : Shape)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat hx),.big (Int.ofNat hy),.num (.lit p.strideValue),.num (.lit p.paddingValue),.num (.lit p.dilationValue),.num (.lit p.groupsValue),.big (Int.ofNat stream)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (ho₀ : s₀.heap.get out = some (.obj outObject)) (hok₀ : outObject.kind = .buf (cellParts .u64 (.big (Int.ofNat 0)) 8 0))
    (signatureFrame : ¬ framed types) (handlesLive : listSupport H [hx,hy])
    (producers : Host.Mlx.Ffi.nodesOf s₀.ffi.mlx [hx,hy] = some [x,y])
    (sourceX : s₀.ffi.mlx.nodes.get x = some xn) (sourceY : s₀.ffi.mlx.nodes.get y = some yn)
    (strideFixed : F64.un .int32 p.strideValue = p.strideValue) (paddingFixed : F64.un .int32 p.paddingValue = p.paddingValue)
    (dilationFixed : F64.un .int32 p.dilationValue = p.dilationValue) (groupsFixed : F64.un .int32 p.groupsValue = p.groupsValue)
    (sourceGeometry : ConvGeometry ν₀ (roles x).shape (roles y).shape output p.stride p.padding p.dilation p.groups)
    (targetGeometry : ConvGeometry ν (roles x).shape (roles y).shape output p.stride p.padding p.dilation p.groups)
    (argumentRoles : ListR (fun r v => r.role.Holds ν C R v) (arguments p out hx hy stream) (callArguments s.ctl))
    (outputRole : (Host.Ts.Owned.Annotated.fixedBufferRole VectorGetHost.nullRole).Holds ν C R (objectKindAt s (R.a out)))
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64) :
    ∃ shape t,
      interpC (step Host.Load.ffi s₀).run C₀ = some
        (finishBuffer s₀ (resultWorld p s₀.ffi x y shape xn.dtype yn.dtype) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
          symbol (callArgs p out hx hy stream (cellParts .u64 (.big (Int.ofNat 0)) 8 0)),C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (nodeWrite roles s₀.ffi.mlx.nnext (convRole roles p x y output)) boundary objects
          (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host)
        R live framed before after old old'
        (finishBuffer s₀ (resultWorld p s₀.ffi x y shape xn.dtype yn.dtype) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
          symbol (callArgs p out hx hy stream (cellParts .u64 (.big (Int.ofNat 0)) 8 0))) t ∧
      (slotKindRole s₀.ffi.mlx.next).Holds ν C R (objectKindAt t (R.a out)) ∧
      t.next = s.next ∧ t.stack = s.stack ∧ (∀ a, a ≠ R.a out → t.heap.get a = s.heap.get a) ∧
      listSupport (fun i => i = s₀.ffi.mlx.nnext ∨ N i) [x,y] ∧
      Host.Ts.Owned.Annotated.NativeHeapFrame s₀ (finishBuffer s₀ (resultWorld p s₀.ffi x y shape xn.dtype yn.dtype) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
          symbol (callArgs p out hx hy stream (cellParts .u64 (.big (Int.ofNat 0)) 8 0))) ∧
      Host.Ts.Owned.Annotated.NativeHeapFrame s t ∧ t.ctl = .ret (.num zeroN) := by
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
        have exactTypes := string_values_exact [chars!"ptr",chars!"u64",chars!"u64",chars!"i32",chars!"i32",chars!"i32",chars!"i32",chars!"u64"] htys
        rw [exactTypes] at htKind
        obtain ⟨out',ho,hok,hro,hlo,hbo⟩ := h.read_fixed_buffer out outObject _ VectorGetHost.nullRole outLive ho₀ hok₀ outputRole
        rw [VectorGetHost.null_bytes] at hok hbo
        let oldBytes := cellParts .u64 (.big (Int.ofNat 0)) 8 0
        let args₀ := callArgs p out hx hy stream oldBytes
        let args' := callArgs p (R.a out) (R.handle hx) (R.handle hy) (R.handle stream) oldBytes
        have native := h.native.2
        have inputsLive := native.nodesOf_support [hx,hy] [x,y] handlesLive producers
        obtain ⟨shape,shape',xn',yn',sourceCall,targetCall,nativeAfter⟩ := native.conv_null p
          (.jsPtr out 0 oldBytes) (.jsPtr (R.a out) 0 oldBytes) (.big (Int.ofNat stream)) (.big (Int.ofNat (R.handle stream)))
          out 0 hx hy x y xn yn output handlesLive producers sourceX sourceY rfl rfl sourceGeometry targetGeometry
          sourceNodes targetNodes sourceHandles targetHandles
        let native₀ := resultWorld p s₀.ffi x y shape xn.dtype yn.dtype
        let native' := resultWorld p s.ffi (R.node x) (R.node y) shape' xn'.dtype yn'.dtype
        have nativeRelated : VectorHost.NativeRelation ν₀ ν C₀ C
            (nodeWrite roles s₀.ffi.mlx.nnext (convRole roles p x y output)) boundary objects
            (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R native₀ native' :=
          ⟨h.native.1,nativeAfter⟩
        let writes₀ := cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0
        let writes' := cellParts .u64 (.big (Int.ofNat s.ffi.mlx.next)) 8 0
        let t := finishBuffer s native' (R.a out) 0 out' oldBytes writes' symbol args'
        have zeroRole : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
        have literalRole (v : F64) : NumberRoles ν₀ ν C₀ C (.lit v) (.lit v) := ⟨.lit v,⟨rfl,rfl⟩⟩
        have argsRelated : ForestR (NumberRoles ν₀ ν C₀ C) R (args₀.map Parametric.arg) (args'.map Parametric.arg) :=
          .cons (.node _ (.cons (.address out) (.cons (.atom _ _) (.cons (bytes_roles hbo) .nil))))
            (.cons (.node _ (.cons (.value (.handle hx)) .nil))
              (.cons (.node _ (.cons (.value (.handle hy)) .nil))
                (.cons (.node _ (.cons (.number (literalRole p.strideValue)) .nil))
                  (.cons (.node _ (.cons (.number (literalRole p.paddingValue)) .nil))
                    (.cons (.node _ (.cons (.number (literalRole p.dilationValue)) .nil))
                      (.cons (.node _ (.cons (.number (literalRole p.groupsValue)) .nil))
                        (.cons (.node _ (.cons (.value (.handle stream)) .nil)) .nil)))))))
        have eventRoles : TreeR (NumberRoles ν₀ ν C₀ C) R (event ⟨symbol,args₀,status0⟩) (event ⟨symbol,args',status0⟩) :=
          .node _ (.cons (.atom _ _) (.cons (.node _ argsRelated) (.cons (.node _ (.cons (.number zeroRole) .nil)) .nil)))
        have writesRelated : ListR (ByteR (NumberRoles ν₀ ν C₀ C) R) writes₀ writes' := by
          dsimp only [writes₀,writes']
          rw [← native.handleMap.head]
          exact Host.Mlx.Ffi.Parametric.cellParts_roles (.handle _) .u64 8 0
        have targetOutBound := Nat.lt_trans (h.heap.targetBound out outLive) targetHeap
        have post := h.finishBuffer_event native₀ native' nativeRelated out 0 outObject out' oldBytes oldBytes writes₀ writes'
          symbol args₀ args' outLive ho₀ hok₀ hro hlo hbo writesRelated sourceHeap targetOutBound zeroRole eventRoles
        refine ⟨shape,t,?_,?_,post,?_,rfl,rfl,?_,⟨Or.inr inputsLive.1,Or.inr inputsLive.2.1,True.intro⟩,?_,?_,rfl⟩
        · change interpC (step F s₀).run C₀ = _
          have call : F.call s₀.ffi symbol args₀ = M.pure (some (native₀,status0,[(out,0,writes₀)])) := by
            simpa only [F,symbol,args₀,callArgs,native₀,resultWorld,writes₀,u64Write,Int.ofNat_eq_natCast] using
              Host.Load.Owned.load_unary_call s₀.ffi symbol _ _ _ (by decide +kernel) sourceCall
          rw [step_conv_eq p s₀ fn types out hx hy stream returns fo signature₀ outObject receiver oldBytes native₀ writes₀
            hc₀ hf₀ hk₀ ht₀ htk₀ ho₀ hok₀ strideFixed paddingFixed dilationFixed groupsFixed call]
          rfl
        · change interpC (step F s).run C = _
          have call : F.call s.ffi symbol args' = M.pure (some (native',status0,[(R.a out,0,writes')])) := by
            simpa only [F,symbol,args',callArgs,native',resultWorld,writes',u64Write,Int.ofNat_eq_natCast] using
              Host.Load.Owned.load_unary_call s.ffi symbol _ _ _ (by decide +kernel) targetCall
          rw [step_conv_eq p s (R.a fn) (R.a types) (R.a out) (R.handle hx) (R.handle hy) (R.handle stream) returns
            fo' signature' out' this oldBytes native' writes' hc hfo hfk hto htKind ho hok strideFixed paddingFixed dilationFixed groupsFixed call]
          rfl
        · have patch : oldBytes.take 0 ++ writes' ++ oldBytes.drop (0 + len writes') = writes' := rfl
          simp only [objectKindAt,t,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,Host.Ts.St.setObj,
            Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ targetOutBound,patch]
          dsimp only [writes']
          rw [← native.handleMap.head]
          exact slot_role ν C R s₀.ffi.mlx.next
        · intro a ne
          change (s.heap.set (R.a out) _).get a = s.heap.get a
          rw [PTrie.get_set_u64 _ _ _ targetOutBound,ite_eq_right ne]

        · exact Host.Ts.Owned.Annotated.NativeHeapFrame.finishBuffer s₀ native₀ out 0 outObject oldBytes writes₀
            symbol args₀ ho₀ hok₀ sourceHeap
        · exact Host.Ts.Owned.Annotated.NativeHeapFrame.finishBuffer s native' (R.a out) 0 out' oldBytes writes'
            symbol args' ho hok targetOutBound

end Host.Load.Run.Full.Ordinary.ConvFamilyHost

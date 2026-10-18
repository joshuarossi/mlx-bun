import host.mlx.NativeUnaryRoles
import host.mlx.NativeVectorGetHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Owned
open Host.Ts Host.Mlx.Ffi

def unaryWorld (s : LSt) (name : Name) (input : Nat) (node : Node) : LSt :=
  {s with mlx := NativeRoles.createZero s.mlx (NativeRoles.unaryNode name input node)}

theorem load_unary_call (s : LSt) (name : Name) (args : List Arg) (native : Host.Mlx.Ffi.St)
    (ws : List (Nat × Nat × List Byte)) (hm : isMlx name = true)
    (hc : Host.Mlx.Ffi.call s.mlx name args = okW native status0 ws) :
    Host.Load.call s name args = M.pure (some ({s with mlx := native},status0,ws)) := by
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,hc,okW,M.bind,M.pure]

end Host.Load.Owned

namespace Host.Load.Run.Full.Ordinary.UnaryHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- Original unary FFI dispatch and null-slot write, from the source callee,
signature and input binding. Fixed input annotations determine the output's
symbolic dimensions; no target native call or target inference is a premise. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (name : Name) (fn types b handle stream input : Nat) (node : Node)
    (fo signature₀ buffer₀ : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (hm : isMlx name = true) (hs : symOf name = some .unary)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.ptr (.js b) 0,.big (Int.ofNat handle),.big (Int.ofNat stream)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str name,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀))
    (htk₀ : signature₀.kind = .array [.str chars!"ptr",.str chars!"u64",.str chars!"u64"])
    (hb₀ : s₀.heap.get b = some (.obj buffer₀)) (hbk₀ : buffer₀.kind = .buf (cellParts .u64 (.big (Int.ofNat 0)) 8 0))
    (signatureFrame : ¬ framed types) (handleLive : H handle)
    (sourceInput : s₀.ffi.mlx.nodeId? handle = some input) (sourceNode : s₀.ffi.mlx.nodes.get input = some node)
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeapBound : b < 2^64) (targetHeapBound : s.next < 2^64)
    (handleRole : (Host.Ts.Owned.Annotated.Value.handle handle).Holds ν C R (callArgument s.ctl 1))
    (streamRole : (Host.Ts.Owned.Annotated.Value.handle stream).Holds ν C R (callArgument s.ctl 2))
    (bufferRole : (Host.Ts.Owned.Annotated.fixedBufferRole VectorGetHost.nullRole).Holds ν C R (objectKindAt s (R.a b))) :
    ∃ t, interpC (step Host.Load.ffi s₀).run C₀ = some
        (finishBuffer s₀ (Host.Load.Owned.unaryWorld s₀.ffi name input node) b 0 buffer₀
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0) name
          [.jsPtr b 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0),.big (Int.ofNat handle),.big (Int.ofNat stream)],C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (nodeWrite nodes s₀.ffi.mlx.nnext (unaryRole nodes name input)) boundary objects
          (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host)
        R live framed before after old old'
        (finishBuffer s₀ (Host.Load.Owned.unaryWorld s₀.ffi name input node) b 0 buffer₀
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0) name
          [.jsPtr b 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0),.big (Int.ofNat handle),.big (Int.ofNat stream)]) t ∧
      (slotKindRole s₀.ffi.mlx.next).Holds ν C R (objectKindAt t (R.a b)) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  have outputLive : live b := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject fn fo calleeLive
    (h.heap.function_notFramed fn fo _ calleeLive hf₀ hk₀) hf₀
  have signatureLive : live types := by
    have hl := hol.1
    rw [hk₀] at hl
    exact hl.1.2.1.2.1
  obtain ⟨fo',data,this,args,hc,hfo,hfk,hd,_,ha⟩ := h.native_call_view fn fo (.ffi .symbol)
    _ receiver _ hc₀ hf₀ hk₀
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr
        cases ha with | cons hp ha =>
          cases ha with | cons hv ha =>
            cases ha with | cons hi ha =>
              cases ha
              cases hp
              have he := fixed_handle_value handleRole
              simp only [hc,callArgument,Host.Ts.arg,nthD] at he
              rw [he] at hc
              have he := fixed_handle_value streamRole
              simp only [hc,callArgument,Host.Ts.arg,nthD] at he
              rw [he] at hc
              obtain ⟨signature',hto,htr,_⟩ := h.heap.readObject types signature₀ signatureLive signatureFrame ht₀
              have htKind := htr.kind
              rw [htk₀] at htKind
              obtain ⟨tys,htKind,htys⟩ := kind_array htKind
              have exactTypes := string_values_exact [chars!"ptr",chars!"u64",chars!"u64"] htys
              rw [exactTypes] at htKind
              obtain ⟨out,ho,hko,hro,hlo,hbo⟩ := h.read_fixed_buffer b buffer₀ _ VectorGetHost.nullRole
                outputLive hb₀ hbk₀ bufferRole
              rw [VectorGetHost.null_bytes] at hko hbo
              have native := h.native.2
              obtain ⟨node',targetNode,sourceCall,targetCall,nativeAfter⟩ := native.unary_null name
                (.jsPtr b 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0))
                (.jsPtr (R.a b) 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0))
                (.big (Int.ofNat stream)) (.big (Int.ofNat (R.handle stream))) b 0 handle input node hs handleLive
                sourceInput sourceNode (by rfl) (by rfl) sourceNodes targetNodes sourceHandles targetHandles
              let native₀ := Host.Load.Owned.unaryWorld s₀.ffi name input node
              let native' := Host.Load.Owned.unaryWorld s.ffi name (R.node input) node'
              have nativeRelated : VectorHost.NativeRelation ν₀ ν C₀ C
                  (nodeWrite nodes s₀.ffi.mlx.nnext (unaryRole nodes name input)) boundary objects
                  (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R native₀ native' :=
                ⟨h.native.1,nativeAfter⟩
              let bs := cellParts .u64 (.big (Int.ofNat 0)) 8 0
              let ws₀ := cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0
              let ws' := cellParts .u64 (.big (Int.ofNat s.ffi.mlx.next)) 8 0
              let args₀ : List Arg := [.jsPtr b 0 bs,.big (Int.ofNat handle),.big (Int.ofNat stream)]
              let args' : List Arg := [.jsPtr (R.a b) 0 bs,.big (Int.ofNat (R.handle handle)),.big (Int.ofNat (R.handle stream))]
              let t := finishBuffer s native' (R.a b) 0 out bs ws' name args'
              have hz : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
              have argumentRoles : ForestR (NumberRoles ν₀ ν C₀ C) R
                  (args₀.map Parametric.arg) (args'.map Parametric.arg) :=
                .cons (.node _ (.cons (.address b) (.cons (.atom _ _) (.cons (bytes_roles hbo) .nil))))
                  (.cons (.node _ (.cons (.value (.handle handle)) .nil))
                    (.cons (.node _ (.cons (.value (.handle stream)) .nil)) .nil))
              have hevent : TreeR (NumberRoles ν₀ ν C₀ C) R
                  (event ⟨name,args₀,status0⟩) (event ⟨name,args',status0⟩) :=
                .node _ (.cons (.atom _ _) (.cons (.node _ argumentRoles)
                  (.cons (.node _ (.cons (.number hz) .nil)) .nil)))
              have writesRelated : ListR (ByteR (NumberRoles ν₀ ν C₀ C) R) ws₀ ws' := by
                dsimp only [ws₀,ws']
                rw [← native.handleMap.head]
                exact Host.Mlx.Ffi.Parametric.cellParts_roles (.handle _) .u64 8 0
              have targetOutputBound := Nat.lt_trans (h.heap.targetBound b outputLive) targetHeapBound
              have hpost := h.finishBuffer_event native₀ native' nativeRelated b 0 buffer₀ out bs bs ws₀ ws'
                name args₀ args' outputLive hb₀ hbk₀ hro hlo hbo writesRelated sourceHeapBound targetOutputBound hz hevent
              refine ⟨t,?_,?_,hpost,?_⟩
              · have hb : bufBytes Host.Load.ffi s₀ b = some bs :=
                    bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,hb₀]) hbk₀
                have hcall : Host.Load.ffi.call s₀.ffi name args₀ =
                    M.pure (some (native₀,status0,[u64Write b 0 s₀.ffi.mlx.next])) := by
                  simpa only [Host.Load.ffi,native₀,Host.Load.Owned.unaryWorld,args₀] using
                    Host.Load.Owned.load_unary_call s₀.ffi name _ _ _ hm sourceCall
                rw [step_ffi_ptr_u64_u64 Host.Load.ffi s₀ fn types b 0 (Int.ofNat handle) (Int.ofNat stream)
                  name returns fo signature₀ bs native₀ status0 [u64Write b 0 s₀.ffi.mlx.next]
                  hc₀ (by simp only [Host.Ts.St.obj?,hf₀]) hk₀ (by simp only [Host.Ts.St.obj?,ht₀]) htk₀ hb
                  (by simpa only [Host.Load.ffi,args₀,List.drop_zero] using hcall)]
                simp only [List.drop_zero,u64Write,← Int.ofNat_eq_natCast]
                rw [ffiDone_status0_buffer Host.Load.ffi s₀ native₀ b 0 buffer₀ bs ws₀ name args₀
                  (by simp only [Host.Ts.St.obj?,hb₀]) hbk₀]
                rfl
              · have hb : bufBytes Host.Load.ffi s (R.a b) = some bs :=
                    bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,ho]) hko
                have hcall : Host.Load.ffi.call s.ffi name args' =
                    M.pure (some (native',status0,[u64Write (R.a b) 0 s.ffi.mlx.next])) := by
                  simpa only [Host.Load.ffi,native',Host.Load.Owned.unaryWorld,args'] using
                    Host.Load.Owned.load_unary_call s.ffi name _ _ _ hm targetCall
                rw [step_ffi_ptr_u64_u64 Host.Load.ffi s (R.a fn) (R.a types) (R.a b) 0 (Int.ofNat (R.handle handle)) (Int.ofNat (R.handle stream))
                  name returns fo' signature' bs native' status0 [u64Write (R.a b) 0 s.ffi.mlx.next]
                  hc (by simp only [Host.Ts.St.obj?,hfo]) hfk (by simp only [Host.Ts.St.obj?,hto]) htKind hb
                  (by simpa only [Host.Load.ffi,args',List.drop_zero] using hcall)]
                simp only [List.drop_zero,u64Write,← Int.ofNat_eq_natCast]
                rw [ffiDone_status0_buffer Host.Load.ffi s native' (R.a b) 0 out bs ws' name args'
                  (by simp only [Host.Ts.St.obj?,ho]) hko]
                rfl
              · have patch : bs.take 0 ++ ws' ++ bs.drop (0 + len ws') = ws' := rfl
                simp only [objectKindAt,t,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,
                  Host.Ts.St.setObj,Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ targetOutputBound,patch]
                dsimp only [ws']
                rw [← native.handleMap.head]
                exact slot_role ν C R s₀.ffi.mlx.next

end Host.Load.Run.Full.Ordinary.UnaryHost

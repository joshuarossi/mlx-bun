import host.mlx.OrdinaryVectorHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.VectorDataHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

def resultWorld (s : LSt) (nodes : List Nat) : LSt := {s with mlx := (s.mlx.newObj (.vec nodes)).2}

/-- The source-only host constructor works for any ordered list of live array
handles. Fixed count and buffer occurrences determine target decoding; source
array bindings determine the new vector's fixed producer list. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types b : Nat) (fo signature₀ buffer₀ : Host.Ts.Obj) (returns : Name) (receiver : Val) (handles nodes : List Nat)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.ptr (.js b) 0,.big (Int.ofNat handles.length)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_vector_array_new_data",.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array [.str chars!"ptr",.str chars!"u64"])
    (hb₀ : s₀.heap.get b = some (.obj buffer₀)) (hbk₀ : buffer₀.kind = .buf (VectorBuffer.bytes handles))
    (signatureFrame : ¬ framed types) (handlesLive : listSupport H handles)
    (sourceNodes : nodesOf s₀.ffi.mlx handles = some nodes)
    (sourceBound : s₀.ffi.mlx.next < 2^64) (targetBound : s.ffi.mlx.next < 2^64)
    (countRole : (Host.Ts.Owned.Annotated.Value.ordinaryBig (Int.ofNat handles.length)).Holds ν C R (callArgument s.ctl 1))
    (bufferRole : (VectorBuffer.role handles).Holds ν C R (objectKindAt s (R.a b))) :
    interpC (step Host.Load.ffi s₀).run C₀ = some
      (finishBig s₀ (resultWorld s₀.ffi nodes) chars!"mlx_vector_array_new_data"
        [.jsPtr b 0 (VectorBuffer.bytes handles),.big (Int.ofNat handles.length)] (Int.ofNat s₀.ffi.mlx.next),C₀) ∧
    interpC (step Host.Load.ffi s).run C = some
      (finishBig s (resultWorld s.ffi (nodes.map R.node)) chars!"mlx_vector_array_new_data"
        [.jsPtr (R.a b) 0 (VectorBuffer.bytes (handles.map R.handle)),.big (Int.ofNat handles.length)]
        (Int.ofNat s.ffi.mlx.next),C) ∧
    StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary (objectWrite objects s₀.ffi.mlx.next (.vec nodes))
        (fun a => a = s₀.ffi.mlx.next ∨ H a) N tail host)
      R live framed before after old old'
      (finishBig s₀ (resultWorld s₀.ffi nodes) chars!"mlx_vector_array_new_data"
        [.jsPtr b 0 (VectorBuffer.bytes handles),.big (Int.ofNat handles.length)] (Int.ofNat s₀.ffi.mlx.next))
      (finishBig s (resultWorld s.ffi (nodes.map R.node)) chars!"mlx_vector_array_new_data"
        [.jsPtr (R.a b) 0 (VectorBuffer.bytes (handles.map R.handle)),.big (Int.ofNat handles.length)] (Int.ofNat s.ffi.mlx.next)) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  have bufferLive : live b := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.1
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
            cases ha
            cases hp
            have he := fixed_ordinary_big_value countRole
            simp only [hc,callArgument,Host.Ts.arg,nthD] at he
            rw [he] at hc
            obtain ⟨signature',hto,htr,_⟩ := h.heap.readObject types signature₀ signatureLive signatureFrame ht₀
            have htKind := htr.kind
            rw [htk₀] at htKind
            obtain ⟨tys,htKind,htys⟩ := kind_array htKind
            cases htys with | cons hp htys =>
              cases htys with | cons hu htys =>
                cases htys
                cases hp; cases hu
                obtain ⟨buffer,hb,hbr,_⟩ := h.heap.readObject b buffer₀ bufferLive
                  (h.heap.buffer_notFramed b buffer₀ _ bufferLive hb₀ hbk₀) hb₀
                have hbKind := hbr.kind
                rw [hbk₀] at hbKind
                obtain ⟨bytes,hbKind,hbytes⟩ := kind_buffer hbKind
                have hbRole : (VectorBuffer.role handles).Holds ν C R (Encode.kind (.buf bytes)) := by
                  simpa only [objectKindAt,Host.Ts.St.obj?,hb,hbKind] using bufferRole
                have hebytes := VectorBuffer.exact_bytes hbRole
                subst bytes
                obtain ⟨sourceCall,targetCall,nativeAfter,_⟩ := h.native.2.vector_data b 0 handles nodes handlesLive sourceNodes sourceBound targetBound
                have nativeRelated : VectorHost.NativeRelation ν₀ ν C₀ C roles boundary
                    (objectWrite objects s₀.ffi.mlx.next (.vec nodes)) (fun a => a = s₀.ffi.mlx.next ∨ H a) N tail host
                    R (resultWorld s₀.ffi nodes) (resultWorld s.ffi (nodes.map R.node)) := ⟨h.native.1,nativeAfter⟩
                have hv : ValueR (NumberRoles ν₀ ν C₀ C) R (.big (Int.ofNat s₀.ffi.mlx.next)) (.big (Int.ofNat s.ffi.mlx.next)) := by
                  rw [← h.native.2.handleMap.head]
                  exact .handle _
                have hevent : TreeR (NumberRoles ν₀ ν C₀ C) R
                    (event ⟨chars!"mlx_vector_array_new_data",[.jsPtr b 0 (VectorBuffer.bytes handles),.big (Int.ofNat handles.length)],.big (Int.ofNat s₀.ffi.mlx.next)⟩)
                    (event ⟨chars!"mlx_vector_array_new_data",[.jsPtr (R.a b) 0 (VectorBuffer.bytes (handles.map R.handle)),.big (Int.ofNat handles.length)],.big (Int.ofNat s.ffi.mlx.next)⟩) :=
                  .node _ (.cons (.atom _ _) (.cons (.node _ (.cons
                    (.node _ (.cons (.address _) (.cons (.atom _ _) (.cons (bytes_roles hbytes) .nil))))
                    (.cons (.node _ (.cons (.value (.ordinaryBig _)) .nil)) .nil)))
                    (.cons (.node _ (.cons (.value hv) .nil)) .nil)))
                refine ⟨?_,?_,h.finishBig _ _ nativeRelated _ _ _ _ _ hevent hv⟩
                · have hbuf : bufBytes Host.Load.ffi s₀ b = some (VectorBuffer.bytes handles) :=
                    bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,hb₀]) hbk₀
                  have hcall : Host.Load.ffi.call s₀.ffi chars!"mlx_vector_array_new_data"
                      [.jsPtr b 0 ((VectorBuffer.bytes handles).drop 0),.big (Int.ofNat handles.length)] =
                      M.pure (some (resultWorld s₀.ffi nodes,.big (Int.ofNat s₀.ffi.mlx.next),[])) := by
                    simpa only [Host.Load.ffi,resultWorld,List.drop_zero] using VectorHost.load_vector_call s₀.ffi _ _ _ sourceCall
                  rw [step_ffi_ptr_u64 Host.Load.ffi s₀ fn types b 0 (Int.ofNat handles.length) chars!"mlx_vector_array_new_data"
                    returns fo signature₀ _ (resultWorld s₀.ffi nodes) (.big (Int.ofNat s₀.ffi.mlx.next)) [] hc₀
                    (by simp only [Host.Ts.St.obj?,hf₀]) hk₀ (by simp only [Host.Ts.St.obj?,ht₀]) htk₀ hbuf hcall]
                  rfl
                · have hbuf : bufBytes Host.Load.ffi s (R.a b) = some (VectorBuffer.bytes (handles.map R.handle)) :=
                    bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,hb]) hbKind
                  have hcall : Host.Load.ffi.call s.ffi chars!"mlx_vector_array_new_data"
                      [.jsPtr (R.a b) 0 ((VectorBuffer.bytes (handles.map R.handle)).drop 0),.big (Int.ofNat handles.length)] =
                      M.pure (some (resultWorld s.ffi (nodes.map R.node),.big (Int.ofNat s.ffi.mlx.next),[])) := by
                    simpa only [Host.Load.ffi,resultWorld,List.drop_zero] using VectorHost.load_vector_call s.ffi _ _ _ targetCall
                  rw [step_ffi_ptr_u64 Host.Load.ffi s (R.a fn) (R.a types) (R.a b) 0 (Int.ofNat handles.length)
                    chars!"mlx_vector_array_new_data" returns fo' signature' _ (resultWorld s.ffi (nodes.map R.node))
                    (.big (Int.ofNat s.ffi.mlx.next)) [] hc (by simp only [Host.Ts.St.obj?,hfo]) hfk
                    (by simp only [Host.Ts.St.obj?,hto]) htKind hbuf hcall]
                  rfl

end Host.Load.Run.Full.Ordinary.VectorDataHost

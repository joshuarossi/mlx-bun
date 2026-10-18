import host.mlx.OrdinaryVectorHost
import host.ts.RenameParametricRankNative

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Owned
open Host.Ts

def freeArray (s : LSt) (handle : Nat) : LSt := {s with mlx := s.mlx.freeArr handle}

theorem call_array_free (s : Host.Mlx.Ffi.St) (handle : Nat) :
    Host.Mlx.Ffi.call s chars!"mlx_array_free" [.big (Int.ofNat handle)] =
      Host.Mlx.Ffi.ok (s.freeArr handle) Host.Mlx.Ffi.status0 := by
  have sy : Host.Mlx.Ffi.symOf chars!"mlx_array_free" = some .arrayFree := by decide +kernel
  unfold Host.Mlx.Ffi.call
  rw [sy]
  simp only [Host.Mlx.Ffi.argNat_big_nat]

theorem load_array_free (s : LSt) (handle : Nat) :
    Host.Load.call s chars!"mlx_array_free" [.big (Int.ofNat handle)] =
      M.pure (some (freeArray s handle,Host.Mlx.Ffi.status0,[])) := by
  have hm : Host.Load.isMlx chars!"mlx_array_free" = true := by decide +kernel
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,call_array_free,Host.Mlx.Ffi.ok,M.bind,M.pure,freeArray]

end Host.Load.Owned

namespace Host.Load.Run.Full.Ordinary.ArrayFreeHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- Array disposal removes its owned handle from live support. Every selected
graph node and every other native object keeps its fixed indexed annotation. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types handle : Nat) (fo signature₀ : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_array_free",.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array [.str chars!"u64"])
    (signatureFrame : ¬ framed types) (handleLive : H handle) (nonzero : handle ≠ 0)
    (sourceBound : handle < 2^64) (targetBound : s.ffi.mlx.next < 2^64)
    (role : (Host.Ts.Owned.Annotated.Value.handle handle).Holds ν C R (callArgument s.ctl 0)) :
    interpC (step Host.Load.ffi s₀).run C₀ =
      some (finishStatus s₀ (Host.Load.Owned.freeArray s₀.ffi handle) chars!"mlx_array_free" [.big (Int.ofNat handle)],C₀) ∧
    interpC (step Host.Load.ffi s).run C =
      some (finishStatus s (Host.Load.Owned.freeArray s.ffi (R.handle handle)) chars!"mlx_array_free"
        [.big (Int.ofNat (R.handle handle))],C) ∧
    StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects (fun b => H b ∧ b ≠ handle) N tail host)
      R live framed before after old old'
      (finishStatus s₀ (Host.Load.Owned.freeArray s₀.ffi handle) chars!"mlx_array_free" [.big (Int.ofNat handle)])
      (finishStatus s (Host.Load.Owned.freeArray s.ffi (R.handle handle)) chars!"mlx_array_free"
        [.big (Int.ofNat (R.handle handle))]) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
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
        cases ha with | cons hv ha =>
          cases ha
          have he := fixed_handle_value role
          simp only [hc,callArgument,Host.Ts.arg,nthD] at he
          rw [he] at hc
          obtain ⟨signature₀',hto,htr,_⟩ := h.heap.readObject types signature₀ signatureLive signatureFrame ht₀
          have htKind := htr.kind
          rw [htk₀] at htKind
          obtain ⟨tys,htKind,htys⟩ := kind_array htKind
          cases htys with | cons hu htys =>
            cases htys
            cases hu
            have native := h.native.2
            have targetHandleBound : R.handle handle < 2^64 :=
              Nat.lt_trans (native.handleMap.bound handle (native.liveHandleBound handle handleLive)) targetBound
            have nativeAfter : VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects
                (fun b => H b ∧ b ≠ handle) N tail host R
                (Host.Load.Owned.freeArray s₀.ffi handle) (Host.Load.Owned.freeArray s.ffi (R.handle handle)) :=
              ⟨h.native.1,native.freeArr_nonzero handle handleLive nonzero sourceBound targetHandleBound⟩
            have hz : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
            have hevent : TreeR (NumberRoles ν₀ ν C₀ C) R
                (event ⟨chars!"mlx_array_free",[.big (Int.ofNat handle)],status0⟩)
                (event ⟨chars!"mlx_array_free",[.big (Int.ofNat (R.handle handle))],status0⟩) :=
              .node _ (.cons (.atom _ _) (.cons
                (.node _ (.cons (.node _ (.cons (.value (.handle handle)) .nil)) .nil))
                (.cons (.node _ (.cons (.number hz) .nil)) .nil)))
            refine ⟨?_,?_,h.finishStatus _ _ nativeAfter _ _ _ hevent hz⟩
            · have hcall : Host.Load.ffi.call s₀.ffi chars!"mlx_array_free" [.big (Int.ofNat handle)] =
                  M.pure (some (Host.Load.Owned.freeArray s₀.ffi handle,status0,[])) := by
                simpa only [Host.Load.ffi] using Host.Load.Owned.load_array_free s₀.ffi handle
              rw [step_ffi_one_u64 Host.Load.ffi s₀ fn types (Int.ofNat handle) chars!"mlx_array_free" returns
                fo signature₀ receiver (Host.Load.Owned.freeArray s₀.ffi handle) status0 hc₀ (by simp only [Host.Ts.St.obj?,hf₀]) hk₀
                (by simp only [Host.Ts.St.obj?,ht₀]) htk₀ hcall]
              rfl
            · have hcall : Host.Load.ffi.call s.ffi chars!"mlx_array_free" [.big (Int.ofNat (R.handle handle))] =
                  M.pure (some (Host.Load.Owned.freeArray s.ffi (R.handle handle),status0,[])) := by
                simpa only [Host.Load.ffi] using Host.Load.Owned.load_array_free s.ffi (R.handle handle)
              rw [step_ffi_one_u64 Host.Load.ffi s (R.a fn) (R.a types) (Int.ofNat (R.handle handle))
                chars!"mlx_array_free" returns fo' signature₀' this (Host.Load.Owned.freeArray s.ffi (R.handle handle)) status0 hc
                (by simp only [Host.Ts.St.obj?,hfo]) hfk (by simp only [Host.Ts.St.obj?,hto]) htKind hcall]
              rfl

end Host.Load.Run.Full.Ordinary.ArrayFreeHost

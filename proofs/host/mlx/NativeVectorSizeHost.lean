import host.mlx.NativeVectorFactoryHost
import host.ts.RenameParametricRankNative

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Owned
open Host.Ts

theorem vector_length_map {α β : Type} (f : α → β) (xs : List α) : len (xs.map f) = len xs := by
  suffices ∀ acc, lenL (xs.map f) acc = lenL xs acc from this 0
  intro acc
  induction xs generalizing acc with
  | nil => rfl
  | cons x xs ih => exact ih (acc + 1)

theorem call_vector_size (s : Host.Mlx.Ffi.St) (handle : Nat) (nodes : List Nat)
    (hv : s.obj? handle = some (.vec nodes)) :
    Host.Mlx.Ffi.call s chars!"mlx_vector_array_size" [.big (Int.ofNat handle)] =
      Host.Mlx.Ffi.ok s (.big (Int.ofNat (len nodes))) := by
  have sy : Host.Mlx.Ffi.symOf chars!"mlx_vector_array_size" = some .vecSize := by decide +kernel
  unfold Host.Mlx.Ffi.call
  rw [sy]
  simp only [Host.Mlx.Ffi.argNat_big_nat,Option.bind_some,hv]
  rw [Int.ofNat_eq_natCast]

theorem load_vector_size (s : LSt) (handle : Nat) (nodes : List Nat)
    (hv : s.mlx.obj? handle = some (.vec nodes)) :
    Host.Load.call s chars!"mlx_vector_array_size" [.big (Int.ofNat handle)] =
      M.pure (some (s,.big (Int.ofNat (len nodes)),[])) := by
  have hm : Host.Load.isMlx chars!"mlx_vector_array_size" = true := by decide +kernel
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,call_vector_size s.mlx handle nodes hv,
    Host.Mlx.Ffi.ok,M.bind,M.pure]

end Host.Load.Owned

namespace Host.Load.Run.Full.Ordinary.VectorSizeHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- Vector metadata reads derive the target payload from live owned objects.
The full indexed native relation is retained after the original host step. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types handle : Nat) (fo signature₀ : Host.Ts.Obj) (returns : Name) (receiver : Val) (entries : List Nat)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_vector_array_size",.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array [.str chars!"u64"])
    (signatureFrame : ¬ framed types) (handleLive : H handle)
    (sourceVector : s₀.ffi.mlx.obj? handle = some (.vec entries))
    (role : (Host.Ts.Owned.Annotated.Value.handle handle).Holds ν C R (callArgument s.ctl 0)) :
    interpC (step Host.Load.ffi s₀).run C₀ =
      some (finishBig s₀ s₀.ffi chars!"mlx_vector_array_size" [.big (Int.ofNat handle)] (Int.ofNat (len entries)),C₀) ∧
    interpC (step Host.Load.ffi s).run C =
      some (finishBig s s.ffi chars!"mlx_vector_array_size" [.big (Int.ofNat (R.handle handle))] (Int.ofNat (len entries)),C) ∧
    StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old'
      (finishBig s₀ s₀.ffi chars!"mlx_vector_array_size" [.big (Int.ofNat handle)] (Int.ofNat (len entries)))
      (finishBig s s.ffi chars!"mlx_vector_array_size" [.big (Int.ofNat (R.handle handle))] (Int.ofNat (len entries))) := by
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
          obtain ⟨signature',hto,htr,_⟩ := h.heap.readObject types signature₀ signatureLive signatureFrame ht₀
          have htKind := htr.kind
          rw [htk₀] at htKind
          obtain ⟨tys,htKind,htys⟩ := kind_array htKind
          cases htys with | cons hu htys =>
            cases htys
            cases hu
            have weak := h.native.2.mono (fun _ _ p => p) (fun _ _ _ p => p) (fun _ _ _ p => p.base)
            have targetVector := weak.vec_view handle handleLive entries sourceVector
            have value : ValueR (NumberRoles ν₀ ν C₀ C) R
                (.big (Int.ofNat (len entries))) (.big (Int.ofNat (len entries))) := .ordinaryBig _
            have hevent : TreeR (NumberRoles ν₀ ν C₀ C) R
                (event ⟨chars!"mlx_vector_array_size",[.big (Int.ofNat handle)],.big (Int.ofNat (len entries))⟩)
                (event ⟨chars!"mlx_vector_array_size",[.big (Int.ofNat (R.handle handle))],.big (Int.ofNat (len entries))⟩) :=
              .node _ (.cons (.atom _ _) (.cons
                (.node _ (.cons (.node _ (.cons (.value (.handle handle)) .nil)) .nil))
                (.cons (.node _ (.cons (.value value) .nil)) .nil)))
            refine ⟨?_,?_,h.finishBig _ _ h.native _ _ _ _ _ hevent value⟩
            · have hcall : Host.Load.ffi.call s₀.ffi chars!"mlx_vector_array_size" [.big (Int.ofNat handle)] =
                  M.pure (some (s₀.ffi,.big (Int.ofNat (len entries)),[])) := by
                simpa only [Host.Load.ffi] using Host.Load.Owned.load_vector_size s₀.ffi handle entries sourceVector
              rw [step_ffi_one_u64 Host.Load.ffi s₀ fn types (Int.ofNat handle) chars!"mlx_vector_array_size" returns
                fo signature₀ receiver s₀.ffi (.big (Int.ofNat (len entries))) hc₀ (by simp only [Host.Ts.St.obj?,hf₀]) hk₀
                (by simp only [Host.Ts.St.obj?,ht₀]) htk₀ hcall]
              rfl
            · have hcall : Host.Load.ffi.call s.ffi chars!"mlx_vector_array_size" [.big (Int.ofNat (R.handle handle))] =
                  M.pure (some (s.ffi,.big (Int.ofNat (len entries)),[])) := by
                simpa only [Host.Load.ffi,Host.Load.Owned.vector_length_map] using
                  Host.Load.Owned.load_vector_size s.ffi (R.handle handle) (entries.map R.node) targetVector
              rw [step_ffi_one_u64 Host.Load.ffi s (R.a fn) (R.a types) (Int.ofNat (R.handle handle))
                chars!"mlx_vector_array_size" returns fo' signature' this s.ffi (.big (Int.ofNat (len entries))) hc
                (by simp only [Host.Ts.St.obj?,hfo]) hfk (by simp only [Host.Ts.St.obj?,hto]) htKind hcall]
              rfl

end Host.Load.Run.Full.Ordinary.VectorSizeHost

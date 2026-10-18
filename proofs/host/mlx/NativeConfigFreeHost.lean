import host.ts.RenameParametricRankNative

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0


namespace Host.Ts
def finishVoid {S : Type} (s : St S) (native : S) (name : Name) (args : List Arg) : St S :=
  ((s.setFfi native).setTrace (⟨name,args,.void⟩ :: s.trace)).ret .undef
end Host.Ts

namespace Host.Ts.Owned.Parametric
theorem StateR.finishVoid {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old oldp : List Event} {s sp : St S}
    (h : StateR NR FR R live framed before after old oldp s sp)
    (name : Name) (args argsp : List Arg)
    (he : TreeR NR R (event ⟨name,args,.void⟩) (event ⟨name,argsp,.void⟩)) :
    StateR NR FR R live framed before after old oldp
      (finishVoid s s.ffi name args) (finishVoid sp sp.ffi name argsp) :=
  (h.traceCons _ _ he).go (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩
end Host.Ts.Owned.Parametric

namespace Host.Load.Owned
open Host.Ts

theorem call_config_free (s : Host.Mlx.Ffi.St) (arg : Arg) :
    Host.Mlx.Ffi.call s chars!"mlx_fast_metal_kernel_config_free" [arg] = Host.Mlx.Ffi.ok s Host.Ts.Ret.void := by
  have sy : Host.Mlx.Ffi.symOf chars!"mlx_fast_metal_kernel_config_free" = some .cfgFree := by decide +kernel
  unfold Host.Mlx.Ffi.call
  rw [sy]

theorem load_config_free (s : LSt) (arg : Arg) :
    Host.Load.call s chars!"mlx_fast_metal_kernel_config_free" [arg] = M.pure (some (s,Host.Ts.Ret.void,[])) := by
  have hm : Host.Load.isMlx chars!"mlx_fast_metal_kernel_config_free" = true := by decide +kernel
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,call_config_free,Host.Mlx.Ffi.ok,M.bind,M.pure]

end Host.Load.Owned

namespace Host.Ts.Owned.Parametric

/-- Source-only symbol dispatch for Metal configuration disposal. The original native model
retains its stores, so the caller's complete indexed native relation is framed. -/
theorem step_config_free_from_source
    (NR : NumV → NumV → Prop) (FR : Ren → Host.Load.LSt → Host.Load.LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (ν : Nat → F64) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St Host.Load.LSt)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (fn types handle : Nat) (fo to : Obj) (returns : Name) (receiver : Val)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_fast_metal_kernel_config_free",.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj to)) (htk₀ : to.kind = .array [.str chars!"u64"])
    (typeFrame : ¬ framed types)
    (handleRole : (Annotated.Value.handle handle).Holds ν C R (callArgument s.ctl 0)) :
    interpC (step Host.Load.ffi s₀).run C₀ =
      some (finishVoid s₀ s₀.ffi chars!"mlx_fast_metal_kernel_config_free" [.big (Int.ofNat handle)],C₀) ∧
    interpC (step Host.Load.ffi s).run C =
      some (finishVoid s s.ffi chars!"mlx_fast_metal_kernel_config_free" [.big (Int.ofNat (R.handle handle))],C) ∧
    StateR NR FR R live framed before after old old'
      (finishVoid s₀ s₀.ffi chars!"mlx_fast_metal_kernel_config_free" [.big (Int.ofNat handle)])
      (finishVoid s s.ffi chars!"mlx_fast_metal_kernel_config_free" [.big (Int.ofNat (R.handle handle))]) := by
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
          have he := fixed_handle_value handleRole
          simp only [hc,callArgument,Host.Ts.arg,nthD] at he
          rw [he] at hc
          obtain ⟨to',hto,htr,_⟩ := h.heap.readObject types to signatureLive typeFrame ht₀
          have htKind := htr.kind
          rw [htk₀] at htKind
          obtain ⟨tys,htKind,htys⟩ := kind_array htKind
          cases htys with | cons hu htys =>
            cases htys
            cases hu
            have hevent : TreeR NR R
                (event ⟨chars!"mlx_fast_metal_kernel_config_free",[.big (Int.ofNat handle)],Host.Ts.Ret.void⟩)
                (event ⟨chars!"mlx_fast_metal_kernel_config_free",[.big (Int.ofNat (R.handle handle))],Host.Ts.Ret.void⟩) :=
              .node _ (.cons (.atom _ _) (.cons
                (.node _ (.cons (.node _ (.cons (.value (.handle handle)) .nil)) .nil))
                (.cons (.node _ .nil) .nil)))
            refine ⟨?_,?_,h.finishVoid _ _ _ hevent⟩
            · have hcall : Host.Load.ffi.call s₀.ffi chars!"mlx_fast_metal_kernel_config_free" [.big (Int.ofNat handle)] =
                  M.pure (some (s₀.ffi,Host.Ts.Ret.void,[])) := by
                simpa only [Host.Load.ffi] using Host.Load.Owned.load_config_free s₀.ffi (.big (Int.ofNat handle))
              rw [step_ffi_one_u64 Host.Load.ffi s₀ fn types (Int.ofNat handle) chars!"mlx_fast_metal_kernel_config_free" returns
                fo to receiver s₀.ffi Host.Ts.Ret.void hc₀ (by simp only [St.obj?,hf₀]) hk₀
                (by simp only [St.obj?,ht₀]) htk₀ hcall]
              rfl
            · have hcall : Host.Load.ffi.call s.ffi chars!"mlx_fast_metal_kernel_config_free" [.big (Int.ofNat (R.handle handle))] =
                  M.pure (some (s.ffi,Host.Ts.Ret.void,[])) := by
                simpa only [Host.Load.ffi] using Host.Load.Owned.load_config_free s.ffi (.big (Int.ofNat (R.handle handle)))
              rw [step_ffi_one_u64 Host.Load.ffi s (R.a fn) (R.a types) (Int.ofNat (R.handle handle))
                chars!"mlx_fast_metal_kernel_config_free" returns fo' to' this s.ffi Host.Ts.Ret.void hc
                (by simp only [St.obj?,hfo]) hfk (by simp only [St.obj?,hto]) htKind hcall]
              rfl

end Host.Ts.Owned.Parametric

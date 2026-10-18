import host.ts.RenameParametricConversions
import host.ts.RenameParametricNativeCall
import host.ts.RenameParametricArrayBuffer
import host.mlx.NativeHostState

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- A fixed integral number occurrence is converted by the actual BigInt
builtin, yielding ordinary integer data and preserving the heap. -/
theorem step_bigint_fixed_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (ν : Nat → F64)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR NR FR R live framed before after old old' s₀ s)
    (fn : Nat) (o₀ : Obj) (data₀ : List Val) (this₀ : Val) (x : F64) (i : Int)
    (hc₀ : s₀.ctl = .call (.obj fn) this₀ [.num (.lit x)])
    (ho₀ : s₀.heap.get fn = some (.obj o₀))
    (hk₀ : o₀.kind = .fn (.native (.num .bigint) data₀))
    (hi : F64.toInt? x = some i)
    (argument : (Annotated.Value.literal (.lit x)).Holds ν C R (callArgument s.ctl 0)) :
    interpC (step F s₀).run C₀ = some (s₀.ret (.big i),C₀) ∧
    interpC (step F s).run C = some (s.ret (.big i),C) ∧
    StateR NR FR R live framed before after old old' (s₀.ret (.big i)) (s.ret (.big i)) := by
  obtain ⟨o,data,this,args,hc,ho,hk,_,_,hargs⟩ := h.native_call_view fn o₀ (.num .bigint) data₀ this₀ _ hc₀ ho₀ hk₀
  cases hargs with | cons hv hargs =>
    cases hargs
    have fixed := fixed_literal_value argument
    simp only [callArgument,hc,Host.Ts.arg,nthD] at fixed
    rw [fixed] at hc
    refine ⟨?_,?_,h.go (.node _ (.cons (.value (.ordinaryBig i)) .nil)) ⟨True.intro,True.intro⟩⟩
    · rw [step_bigint_number_eq F s₀ fn this₀ x i o₀ data₀ hc₀ (by simp only [St.obj?,ho₀]) hk₀ hi]; rfl
    · rw [step_bigint_number_eq F s (R.a fn) this x i o data hc (by simp only [St.obj?,ho]) hk hi]; rfl

end Host.Ts.Owned.Parametric

import host.ts.RenameParametricNativeCall
import host.ts.RenameParametricShapeSpread
import host.mlx.NativeHostState

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem step_ptr_typed_buffer_eq (F : Ffi) (s : St F.S)
    (a view buffer off count : Nat) (fn vo bo : Obj) (k : EltK)
    (data : List Val) (this : Val) (bytes : List Byte)
    (hc : s.ctl = .call (.obj a) this [.obj view])
    (hf : s.heap.get a = some (.obj fn)) (hk : fn.kind = .fn (.native (.ffi .ptr) data))
    (hv : s.heap.get view = some (.obj vo)) (hvk : vo.kind = .typed k buffer off count)
    (hb : s.heap.get buffer = some (.obj bo)) (hbk : bo.kind = .buf bytes)
    (nonempty : count ≠ 0) :
    step F s = M.pure (s.ret (.ptr (.js buffer) off)) := by
  rw [step_native_eq F s a fn (.ffi .ptr) data this _ hc hf hk]
  have hn : Nat.beq count 0 = false := by
    cases he : Nat.beq count 0
    · rfl
    · exact False.elim (nonempty (Nat.eq_of_beq_eq_true he))
  cases vo with | mk vk vp vps vpr ve =>
    cases bo with | mk bk bp bps bpr be =>
      simp only at hvk hbk
      subst vk; subst bk
      simp only [callNative,ffiN,Host.Ts.arg,nthD,offsetArg,St.obj?,hv,hb,
        hn,Bool.cond_false,retS]
      rfl

/-- The actual ptr builtin follows a related typed view to its ordinary
backing buffer. Its pointer role and both machine steps follow from the
source heap, without a target pointer or buffer-kind premise. -/
theorem step_ptr_typed_buffer_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR NR FR R live framed before after old old' s₀ s)
    (a view buffer off count : Nat) (fn vo bo : Obj) (k : EltK)
    (data₀ : List Val) (this₀ : Val) (bytes₀ : List Byte)
    (hc₀ : s₀.ctl = .call (.obj a) this₀ [.obj view])
    (hf₀ : s₀.heap.get a = some (.obj fn)) (hk₀ : fn.kind = .fn (.native (.ffi .ptr) data₀))
    (hv₀ : s₀.heap.get view = some (.obj vo)) (hvk₀ : vo.kind = .typed k buffer off count)
    (hb₀ : s₀.heap.get buffer = some (.obj bo)) (hbk₀ : bo.kind = .buf bytes₀)
    (nonempty : count ≠ 0) :
    interpC (step F s₀).run C₀ = some (s₀.ret (.ptr (.js buffer) off),C₀) ∧
    interpC (step F s).run C = some (s.ret (.ptr (.js (R.a buffer)) off),C) ∧
    StateR NR FR R live framed before after old old'
      (s₀.ret (.ptr (.js buffer) off)) (s.ret (.ptr (.js (R.a buffer)) off)) := by
  obtain ⟨fn',data,this,args,hc,hf,hk,_,_,hargs⟩ := h.native_call_view a fn (.ffi .ptr) data₀ this₀ _ hc₀ hf₀ hk₀
  cases hargs with | cons harg hargs =>
    cases hargs
    cases harg
    have hl := h.controlLive
    rw [hc₀] at hl
    have hview : live view := hl.2.2.1.1
    obtain ⟨vo',hv,hvk,hbuffer⟩ := h.heap.read_typedBuffer view buffer off count vo k hview hv₀ hvk₀
    obtain ⟨bo',hb,hr,_⟩ := h.heap.readObject buffer bo hbuffer
      (h.heap.buffer_notFramed buffer bo bytes₀ hbuffer hb₀ hbk₀) hb₀
    have hbkind := hr.kind
    rw [hbk₀] at hbkind
    obtain ⟨bytes,hbk,_⟩ := kind_buffer hbkind
    refine ⟨?_,?_,h.go (.node _ (.cons (.value (.ptr (.js buffer) off)) .nil)) ⟨hbuffer,True.intro⟩⟩
    · rw [step_ptr_typed_buffer_eq F s₀ a view buffer off count fn vo bo k data₀ this₀ bytes₀ hc₀ hf₀ hk₀ hv₀ hvk₀ hb₀ hbk₀ nonempty]; rfl
    · rw [step_ptr_typed_buffer_eq F s (R.a a) (R.a view) (R.a buffer) off count fn' vo' bo' k data this bytes hc hf hk hv hvk hb hbk nonempty]; rfl

end Host.Ts.Owned.Parametric

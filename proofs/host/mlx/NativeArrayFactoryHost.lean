import host.mlx.OrdinaryArrayHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.ArrayFactoryHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi

abbrev F : Host.Ts.Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
def symbol : Name := chars!"mlx_array_new"

/-- Every occurrence of the null-array factory follows from the source callee
and empty signature. It has no operand or future-annotation premise and leaves
the entire native invariant, host heap and continuation intact. -/
theorem from_source (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (C₀ C : CSrv) (R : Ren) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : Host.Ts.St LSt) (h : StateR NR FR R live framed before after old old' s₀ s)
    (fn types : Nat) (fo signature₀ : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver []) (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array [])
    (signatureFrame : ¬ framed types) :
    ∃ t, interpC (step Host.Load.ffi s₀).run C₀ = some (finishBig s₀ s₀.ffi symbol [] 0,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR NR FR R live framed before after old old' (finishBig s₀ s₀.ffi symbol [] 0) t ∧
      t.ffi = s.ffi ∧ t.heap = s.heap ∧ t.next = s.next ∧ t.stack = s.stack ∧ t.ctl = .ret (.big 0) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject fn fo calleeLive
    (h.heap.function_notFramed fn fo _ calleeLive hf₀ hk₀) hf₀
  have signatureLive : live types := by have hl := hol.1; rw [hk₀] at hl; exact hl.1.2.1.2.1
  obtain ⟨fo',data,this,args,hc,hfo,hfk,hd,_,ha⟩ := h.native_call_view fn fo (.ffi .symbol) _ receiver _ hc₀ hf₀ hk₀
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr; cases ha
        obtain ⟨signature',hto,htr,_⟩ := h.heap.readObject types signature₀ signatureLive signatureFrame ht₀
        have htKind := htr.kind
        rw [htk₀] at htKind
        obtain ⟨tys,htKind,htys⟩ := kind_array htKind
        cases htys
        have events : TreeR NR R (event ⟨symbol,[],.big 0⟩) (event ⟨symbol,[],.big 0⟩) :=
          .node _ (.cons (.atom _ _) (.cons (.node _ .nil) (.cons (.node _ (.cons (.value (.ordinaryBig 0)) .nil)) .nil)))
        refine ⟨finishBig s s.ffi symbol [] 0,?_,?_,h.finishBig s₀.ffi s.ffi h.native _ _ _ _ _ events (.ordinaryBig 0),
          rfl,rfl,rfl,rfl,rfl⟩
        · change interpC (step F s₀).run C₀ = _
          have call : F.call s₀.ffi symbol [] = M.pure (some (s₀.ffi,.big 0,[])) := by
            simpa only [F,symbol] using ArrayHost.load_array_new s₀.ffi
          rw [step_ffi_decoded F s₀ fn types symbol returns fo signature₀ receiver [] [] [] s₀.ffi (.big 0) []
            hc₀ (by simp only [Host.Ts.St.obj?,hf₀]) hk₀ (by simp only [Host.Ts.St.obj?,ht₀]) htk₀ rfl call]
          rfl
        · change interpC (step F s).run C = _
          have call : F.call s.ffi symbol [] = M.pure (some (s.ffi,.big 0,[])) := by
            simpa only [F,symbol] using ArrayHost.load_array_new s.ffi
          rw [step_ffi_decoded F s (R.a fn) (R.a types) symbol returns fo' signature' this [] [] [] s.ffi (.big 0) []
            hc (by simp only [Host.Ts.St.obj?,hfo]) hfk (by simp only [Host.Ts.St.obj?,hto]) htKind rfl call]
          rfl

end Host.Load.Run.Full.Ordinary.ArrayFactoryHost

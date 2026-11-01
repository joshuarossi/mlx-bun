import host.sim.template.EndGen
import host.sim.Support
import host.sim.extract.Grow
import host.sim.full.BridgeClassify
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! # POST's end under the decode template's frames

POST frames only the prompt, over an empty template array; the decode template frames `forwarded`, `emitted` and the prompt, the
last over the one element it was made with. A framed array's template prefix stands for the frame's target prefix, so
neither difference says anything about the target. `withArr`: the template's array replaced. `RelB.reframe`: the relation at
it under new frames. `slotW_frame`: an unframed array can be framed at any prefix of it. -/

/-- `s` with the object at `a` holding the array `x`. -/
def withArr {S : Type} (s : St S) (a : Nat) (o : Obj) (x : List Val) : St S :=
  { s with heap := s.heap.set a (.obj { o with kind := .array x }) }

variable {M : Map}

/-- An unframed array under a frame at a prefix of it. -/
theorem slotW_frame {fr fr' : Nat → Option (List Val × List Val)} {W : Nat → Option WFrame} {b : Nat} {h : HObj}
    {h' : Option HObj} {pre : List Val} (hW : W b = none) (hb : fr b = none) (hb' : fr' b = some (pre, M.vals pre))
    (hk : ∃ o xs, h = .obj o ∧ o.kind = .array (pre ++ xs)) (hs : SlotW M fr W b h h') : SlotW M fr' W b h h' := by
  obtain ⟨o, xs, rfl, hkd⟩ := hk
  simp only [SlotW, hW, SlotOK, hb] at hs
  simp only [SlotW, hW, SlotOK, hb']
  refine ⟨o, M.obj o, rfl, hs, xs, hkd, ?_⟩
  simp only [Map.obj, hkd, Map.kind, Map.vals, List.map_append]

/-- A frame kept. -/
theorem slotW_same {fr fr' : Nat → Option (List Val × List Val)} {W : Nat → Option WFrame} {b : Nat} {h : HObj}
    {h' : Option HObj} (hb : (W b).isSome = true ∧ (fr b).isSome = true ∧ (fr' b).isSome = true ∨ fr' b = fr b)
    (hs : SlotW M fr W b h h') : SlotW M fr' W b h h' := by
  rcases hb with ⟨hw, hf, hf'⟩ | e
  · cases hwb : W b with
    | none => rw [hwb] at hw; cases hw
    | some w =>
      cases hfb : fr b with
      | none => rw [hfb] at hf; cases hf
      | some p =>
        cases hfb' : fr' b with
        | none => rw [hfb'] at hf'; cases hf'
        | some p' =>
          simpa only [SlotW, hwb, hfb, hfb'] using hs
  · unfold SlotW SlotOK at hs ⊢
    rw [e]
    exact hs

/-- **The relation at a replaced framed array and new frames.** -/
theorem RelB.reframe {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {ν : Nat → F64}
    {K : Ctx} {s : St F.S} {S : SSrv} {t : St F.S} {C : CSrv} (h : RelB F FR W stk M ν K s S t C) {a : Nat} {o : Obj}
    (ha : s.heap.get a = some (.obj o)) (hah : a < 2 ^ 62) (x q : List Val) (hWa : W a = none)
    (hsupp : Supp.kind (Present s) S.tab.length (.array x)) {fr' : Nat → Option (List Val × List Val)}
    (hk0 : o.kind = .array []) (hf0 : K.fr a = some ([], q)) (hfa : fr' a = some (x, q))
    (hfr : ∀ b h', b ≠ a → s.heap.get b = some h' → SlotW M K.fr W b h' (t.heap.get (M.a b)) →
      SlotW M fr' W b h' (t.heap.get (M.a b)))
    (hpres : ∀ b p, fr' b = some p → Present s b) :
    RelB F FR W stk M ν { K with fr := fr' } (withArr s a o x) S t C := by
  have hget : ∀ b, b ≠ a → (withArr s a o x).heap.get b = s.heap.get b := fun b hb =>
    PTrie.get_set_ne' _ _ _ _ hb
  have hgeta : (withArr s a o x).heap.get a = some (.obj { o with kind := .array x }) :=
    Host.Ts.Sim.Full.get_set_eq_of_lt _ _ hah
  have hP : Present (withArr s a o x) = Present s := by
    funext b
    by_cases hb : b = a
    · subst hb
      simp only [Present, hgeta, ha, Option.isSome_some]
    · simp only [Present, hget b hb]
  refine
    { srv := h.srv
      heap := ?_
      next := h.next
      offset := h.offset
      room := h.room
      bigFixed := h.bigFixed
      bigExt := h.bigExt
      band := h.band
      intr := h.intr
      bound := fun b hb => h.bound b (hP ▸ hb)
      inj := fun b c hb hc => h.inj b c (hP ▸ hb) (hP ▸ hc)
      presentBound := fun b hb => h.presentBound b (hP ▸ hb)
      framedPresent := fun b p hb => hP ▸ hpres b p hb
      ctl := h.ctl
      stack := h.stack
      jobs := h.jobs
      stores := h.stores
      ffi := h.ffi
      trace := h.trace
      heapSupp := ?_
      ctlSupp := hP ▸ h.ctlSupp
      stackSupp := hP ▸ h.stackSupp
      jobsSupp := hP ▸ h.jobsSupp
      storesSupp := hP ▸ h.storesSupp
      traceSupp := hP ▸ h.traceSupp }
  · intro b h' hb
    by_cases hba : b = a
    · subst hba
      rw [hgeta] at hb
      obtain rfl := Option.some.inj hb
      have hs := h.heap b _ ha
      simp only [SlotW, hWa, SlotOK, hf0] at hs
      obtain ⟨o1, o', e1, ht, xs, hk1, ho'⟩ := hs
      obtain rfl := HObj.obj.inj e1
      rw [hk0] at hk1
      have hxs : xs = [] := by
        have := Kind.array.inj hk1
        simpa using this.symm
      subst hxs
      simp only [SlotW, hWa, SlotOK, hfa]
      refine ⟨_, o', rfl, ht, [], by simp, ?_⟩
      rw [ho']
      simp [Map.obj]
    · rw [hget b hba] at hb
      exact hfr b h' hba hb (h.heap b h' hb)
  · rw [hP]
    intro b h' hb
    by_cases hba : b = a
    · subst hba
      rw [hgeta] at hb
      obtain rfl := Option.some.inj hb
      have hs := h.heapSupp b _ ha
      exact ⟨hsupp, hs.2.1, hs.2.2.1, hs.2.2.2⟩
    · rw [hget b hba] at hb
      exact h.heapSupp b h' hb

end Host.Route

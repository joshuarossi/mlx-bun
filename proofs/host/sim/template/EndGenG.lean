import host.sim.template.EndGen
import host.sim.template.CallGen
import host.sim.template.Ghosts
import host.sim.template.HandGen
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim Host.Load.Run.Tpl

/-! # A decode chain's end over a template with ghosts

`framesP` with the frames from POST's shared cut: the prompt array, and every cell `wideG` frames (the memo and the ghosts, no prefix).
`frG_none`, `frG_some`: the context's frames under `wideG`. A chain from such a template keeps the wide cells exactly (`Ctx.unW` drops them, so
the end's heap clause covers them), they are fixed and present (`wideG_fix`), and none of them holds an array at the end (`keepsG`). -/

theorem lookupW_isSome (a : Nat) : ∀ l : List (Nat × WFrame), (Disp.lookupW a l).isSome = (l.map Prod.fst).contains a
  | [] => rfl
  | (b, _) :: l => by
    unfold Disp.lookupW
    cases h : Nat.beq a b with
    | true =>
      have e := Nat.eq_of_beq_eq_true h
      subst e
      simp
    | false =>
      have e : a ≠ b := fun e => by rw [e] at h; simp at h
      simp only [Bool.cond_false, List.map_cons, List.contains_cons]
      rw [lookupW_isSome a l]
      simp [e]

theorem wideG_isSome (a : Nat) : (wideG a).isSome = (4910 :: ghostAddrs).contains a := lookupW_isSome a _

theorem wideG_mem_iff (a : Nat) : (wideG a).isSome = true ↔ a ∈ 4910 :: ghostAddrs := by
  rw [wideG_isSome]
  exact List.contains_iff_mem

/-- The further frames at a template with ghosts. -/
def framesG {S : Type} (s0 : St S) (q : List Val) : LoopFramesA Host.Load.Run.Prompt.addrPrompt where
  X a := bif Nat.beq a 2665 then some (arrOf s0 2665, q) else bif (wideG a).isSome then some ([], []) else none
  xs := 2665 :: 4910 :: ghostAddrs
  dom a := by
    cases h1 : Nat.beq a 2665
    · have e1 : a ≠ 2665 := fun e => by rw [e] at h1; cases h1
      cases h2 : (wideG a).isSome
      · have hn : a ∉ 4910 :: ghostAddrs := fun hm => by
          have := (wideG_mem_iff a).mpr hm
          rw [h2] at this
          cases this
        simp [e1, hn]
      · have hm := (wideG_mem_iff a).mp h2
        simp only [Bool.cond_false, Bool.cond_true]
        simp only [ne_eq, reduceCtorEq, not_false_eq_true, true_iff]
        exact List.mem_cons_of_mem _ hm
    · have e1 : a = 2665 := Nat.eq_of_beq_eq_true h1
      subst e1
      simp
  fwd := by decide
  emit := by decide

section
variable {S : Type} {s0 : St S} {q p1 p2 : List Val} {K : Ctx}

theorem frG_unW {a : Nat} (hw : wideG a = none) : (K.unW wideG).fr a = K.fr a := by
  show (bif (wideG a).isSome then none else K.fr a) = _
  rw [hw]
  rfl

theorem frG_wide {a : Nat} {w : WFrame} (hw : wideG a = some w) : (K.unW wideG).fr a = none := by
  show (bif (wideG a).isSome then none else K.fr a) = _
  rw [hw]
  rfl

theorem frG_fwd (hfr : K.fr = frA Host.Load.Run.Prompt.addrPrompt s0 (framesG s0 q).X p1 p2) :
    (K.unW wideG).fr 2673448 = some (arrOf s0 2673448, p1) := by
  rw [frG_unW (a := 2673448) rfl, hfr]
  exact frA_fwd Host.Load.Run.Prompt.addrPrompt s0 (framesG s0 q).X p1 p2

theorem frG_emit (hfr : K.fr = frA Host.Load.Run.Prompt.addrPrompt s0 (framesG s0 q).X p1 p2) :
    (K.unW wideG).fr 12504 = some (arrOf s0 12504, p2) := by
  rw [frG_unW (a := 12504) rfl, hfr]
  exact frA_emit Host.Load.Run.Prompt.addrPrompt s0 (framesG s0 q).X p1 p2

theorem frG_prompt (hfr : K.fr = frA Host.Load.Run.Prompt.addrPrompt s0 (framesG s0 q).X p1 p2) :
    (K.unW wideG).fr 2665 = some (arrOf s0 2665, q) := by
  rw [frG_unW (a := 2665) rfl, hfr]
  exact (frA_other Host.Load.Run.Prompt.addrPrompt s0 (framesG s0 q).X p1 p2 (by decide) (by decide)).trans rfl

theorem frG_none (hfr : K.fr = frA Host.Load.Run.Prompt.addrPrompt s0 (framesG s0 q).X p1 p2) {a : Nat}
    (h : (K.unW wideG).fr a = none) : a ∉ [2673448, 12504, 2665] := by
  intro hm
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hm
  rcases hm with rfl | rfl | rfl
  · rw [frG_fwd hfr] at h; cases h
  · rw [frG_emit hfr] at h; cases h
  · rw [frG_prompt hfr] at h; cases h

theorem frG_some (hfr : K.fr = frA Host.Load.Run.Prompt.addrPrompt s0 (framesG s0 q).X p1 p2) {a : Nat}
    {pre pre' : List Val} (h : (K.unW wideG).fr a = some (pre, pre')) :
    (a = 2673448 ∧ pre = arrOf s0 2673448) ∨ (a = 12504 ∧ pre = arrOf s0 12504) ∨ (a = 2665 ∧ pre = arrOf s0 2665) := by
  by_cases h1 : a = 2673448
  · subst h1; rw [frG_fwd hfr] at h; cases h; exact .inl ⟨rfl, rfl⟩
  · by_cases h2 : a = 12504
    · subst h2; rw [frG_emit hfr] at h; cases h; exact .inr (.inl ⟨rfl, rfl⟩)
    · by_cases h3 : a = 2665
      · subst h3; rw [frG_prompt hfr] at h; cases h; exact .inr (.inr ⟨rfl, rfl⟩)
      · exfalso
        cases hw : wideG a with
        | some w => rw [frG_wide hw] at h; cases h
        | none =>
          rw [frG_unW hw, hfr, frA_other Host.Load.Run.Prompt.addrPrompt s0 (framesG s0 q).X p1 p2 h1 h2] at h
          have e3 : Nat.beq a 2665 = false := beq_false h3
          have : (framesG s0 q).X a = none := by
            show (bif Nat.beq a 2665 then _ else bif (wideG a).isSome then _ else none) = none
            rw [e3, hw]; rfl
          rw [this] at h; cases h

/-- The wide frames' half of `IterEndW.ShiftFW`. -/
theorem wideG_fix {σ : Map}
    (h : wideList.all (fun p => Nat.beq (σ.a p.1) p.1 && presentB s0 p.1 && wfixB σ (presentB s0) p.2) = true) :
    ∀ a w, wideG a = some w → a ∈ (framesG s0 q).xs ∧ σ.a a = a ∧ Present s0 a ∧ WFix σ (Present s0) w := by
  intro a w hw
  have hm : (a, w) ∈ wideList := lookupW_mem hw
  have hc := List.all_eq_true.mp h (a, w) hm
  simp only [Bool.and_eq_true] at hc
  have hs : (wideG a).isSome = true := by rw [hw]; rfl
  exact ⟨List.mem_cons_of_mem _ ((wideG_mem_iff a).mp hs), Nat.eq_of_beq_eq_true hc.1.1, hc.1.2, wfix_of hc.2⟩

/-- The frames' arrays are kept: the prompt array has no elements past the template's, the wide cells hold no array. -/
theorem keepsG {s1 : St S} (hp : ∃ o, s1.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf s0 2665 ++ []))
    (hw : (4910 :: ghostAddrs).all (fun a => !isArrB s1 a) = true) : Host.Ts.Sim.Prefill.KeepsAtW (framesG s0 q) s1 := by
  intro a pre pre' hx o es ho hk
  change (bif Nat.beq a 2665 then some (arrOf s0 2665, q) else bif (wideG a).isSome then some ([], []) else none) = _ at hx
  cases h1 : Nat.beq a 2665 with
  | true =>
    have e := Nat.eq_of_beq_eq_true h1
    subst e
    rw [h1] at hx
    simp only [Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at hx
    obtain ⟨rfl, rfl⟩ := hx
    obtain ⟨o', ho', hk'⟩ := hp
    rw [ho] at ho'
    cases ho'
    rw [hk'] at hk
    cases hk
    simp
  | false =>
    rw [h1] at hx
    cases h2 : (wideG a).isSome with
    | false => rw [h2] at hx; cases hx
    | true =>
      have hm := (wideG_mem_iff a).mp h2
      have hc := List.all_eq_true.mp hw a hm
      have hn : isArrB s1 a = false := by simpa using hc
      exact (notArr_of hn ho hk).elim

end

end Host.Ts.Sim.Template

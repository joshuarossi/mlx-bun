import host.sim.world.IterCut
import host.load.run.prompt.Addr
import host.sim.RestartDrop
import host.sim.template.FullShiftGen
namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim

/-! # A decode chain's end on the prompt route, as the end generator states it

The decode loop of the prompt route frames `forwarded`, `emitted` (`addrPrompt`), the prompt array
(2665: the template's elements, the target's prefix `q`) and the constraint cache (4910, a wide memo
frame that `Ctx.unW` drops from the context). `framesP`, `wideP` and `fixP` are those frames and the
fixed addresses; `frP_none`, `frP_some` the context's frames under `wideP` (`genEnd.ts`'s EShift). -/

/-- The prompt route's further frames. -/
def framesP {S : Type} (s0 : St S) (q : List Val) : LoopFramesA Host.Load.Run.Prompt.addrPrompt where
  X a := bif Nat.beq a 2665 then some (arrOf s0 2665, q) else bif Nat.beq a 4910 then some ([], []) else none
  xs := [2665, 4910]
  dom a := by
    cases h1 : Nat.beq a 2665
    · cases h2 : Nat.beq a 4910
      · have e1 : a ≠ 2665 := fun e => by rw [e] at h1; cases h1
        have e2 : a ≠ 4910 := fun e => by rw [e] at h2; cases h2
        simp [e1, e2]
      · have e2 : a = 4910 := Nat.eq_of_beq_eq_true h2
        subst e2; simp
    · have e1 : a = 2665 := Nat.eq_of_beq_eq_true h1
      subst e1; simp
  fwd := by decide
  emit := by decide

/-- The prompt route's wide frames: the constraint cache's memo. -/
def wideP : Nat → Option WFrame := fun a => bif Nat.beq a 4910 then some (.memo []) else none

/-- The addresses a prompt-route decode iteration fixes: `forwarded`, `emitted`, the driver's `emitted` cell. -/
def fixP : List Nat := [2673448, 12504, 2590]

theorem beq_false {a b : Nat} (h : a ≠ b) : Nat.beq a b = false := by
  cases e : Nat.beq a b
  · rfl
  · exact absurd (Nat.eq_of_beq_eq_true e) h

section
variable {S : Type} {s0 : St S} {q p1 p2 : List Val} {K : Ctx}

theorem frP_unW (a : Nat) (ha : a ≠ 4910) : (K.unW wideP).fr a = K.fr a := by
  have hw : wideP a = none := by
    unfold wideP
    rw [beq_false ha]
    rfl
  show (bif (wideP a).isSome then none else K.fr a) = _
  rw [hw]
  rfl

theorem frP_fwd (hfr : K.fr = frA Host.Load.Run.Prompt.addrPrompt s0 (framesP s0 q).X p1 p2) :
    (K.unW wideP).fr 2673448 = some (arrOf s0 2673448, p1) := by
  rw [frP_unW 2673448 (by decide), hfr]
  exact frA_fwd Host.Load.Run.Prompt.addrPrompt s0 (framesP s0 q).X p1 p2

theorem frP_emit (hfr : K.fr = frA Host.Load.Run.Prompt.addrPrompt s0 (framesP s0 q).X p1 p2) :
    (K.unW wideP).fr 12504 = some (arrOf s0 12504, p2) := by
  rw [frP_unW 12504 (by decide), hfr]
  exact frA_emit Host.Load.Run.Prompt.addrPrompt s0 (framesP s0 q).X p1 p2

theorem frP_prompt (hfr : K.fr = frA Host.Load.Run.Prompt.addrPrompt s0 (framesP s0 q).X p1 p2) :
    (K.unW wideP).fr 2665 = some (arrOf s0 2665, q) := by
  rw [frP_unW 2665 (by decide), hfr]
  exact (frA_other Host.Load.Run.Prompt.addrPrompt s0 (framesP s0 q).X p1 p2 (by decide) (by decide)).trans rfl

theorem frP_none (hfr : K.fr = frA Host.Load.Run.Prompt.addrPrompt s0 (framesP s0 q).X p1 p2) {a : Nat}
    (h : (K.unW wideP).fr a = none) : a ∉ [2673448, 12504, 2665] := by
  intro hm
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hm
  rcases hm with rfl | rfl | rfl
  · rw [frP_fwd hfr] at h; cases h
  · rw [frP_emit hfr] at h; cases h
  · rw [frP_prompt hfr] at h; cases h

theorem frP_some (hfr : K.fr = frA Host.Load.Run.Prompt.addrPrompt s0 (framesP s0 q).X p1 p2) {a : Nat}
    {pre pre' : List Val} (h : (K.unW wideP).fr a = some (pre, pre')) :
    (a = 2673448 ∧ pre = arrOf s0 2673448) ∨ (a = 12504 ∧ pre = arrOf s0 12504) ∨ (a = 2665 ∧ pre = arrOf s0 2665) := by
  by_cases h1 : a = 2673448
  · subst h1; rw [frP_fwd hfr] at h; cases h; exact .inl ⟨rfl, rfl⟩
  · by_cases h2 : a = 12504
    · subst h2; rw [frP_emit hfr] at h; cases h; exact .inr (.inl ⟨rfl, rfl⟩)
    · by_cases h3 : a = 2665
      · subst h3; rw [frP_prompt hfr] at h; cases h; exact .inr (.inr ⟨rfl, rfl⟩)
      · exfalso
        by_cases h4 : a = 4910
        · subst h4
          have : (K.unW wideP).fr 4910 = none := rfl
          rw [this] at h; cases h
        · rw [frP_unW a h4, hfr, frA_other Host.Load.Run.Prompt.addrPrompt s0 (framesP s0 q).X p1 p2 h1 h2] at h
          have e3 : Nat.beq a 2665 = false := beq_false h3
          have e4 : Nat.beq a 4910 = false := beq_false h4
          have : (framesP s0 q).X a = none := by
            show (bif Nat.beq a 2665 then _ else bif Nat.beq a 4910 then _ else none) = none
            rw [e3, e4]; rfl
          rw [this] at h; cases h

end

end Host.Ts.Sim.Template

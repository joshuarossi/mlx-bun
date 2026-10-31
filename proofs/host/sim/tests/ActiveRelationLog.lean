import host.sim.full.LogRel
import host.sim.tests.ActiveRelation
set_option Elab.async false
set_option maxRecDepth 1000000

/-! # One template, targets with different logs and lock flags

The relation with a log base holds of one fixed template with the bridge active against two targets that differ in
their logs and in their programs' lock flags: the first wrap's result at `loadDone` (`active_inhabited_programs`),
against its target and against that target with an older effect in its log and every `outLocked` flipped. It stops
compiling if the frame becomes unsatisfiable or stops separating them. -/

namespace Host.Ts.Sim.Full.ActiveRelation
open Host.Ts Host.Ts.Sim
open Host.Mlx.FfiAne (Effect Program)

kernel_rfl lit_programs : bridgeLit.programs.isEmpty = false

/-- Every program's `outLocked` flipped. -/
def flipOut (p : Program) : Program := { p with outLocked := !p.outLocked }

theorem same_flip (ps : List Program) : (ps.map flipOut).map stripP = ps.map stripP := by
  rw [List.map_map]
  rfl

theorem flip_ne {ps : List Program} (h : ps.isEmpty = false) : ps ≠ ps.map flipOut := by
  cases ps with
  | nil => cases h
  | cons p ps =>
    intro e
    have e1 : p.outLocked = (flipOut p).outLocked := congrArg Program.outLocked (List.cons.inj e).1
    cases hp : p.outLocked <;> simp [flipOut, hp] at e1

theorem two_targets :
    ∃ (M : Map) (n : Nat) (x y1 y2 : FF.S) (L : List Effect), (bridgeOf x).active = true ∧
      FRL [] (FullRX P0 15235) M n x y1 ∧ FRL L (FullRX P0 15235) M n x y2 ∧
      (bridgeOf y1).log ≠ (bridgeOf y2).log ∧ (bridgeOf y1).programs ≠ (bridgeOf y2).programs := by
  obtain ⟨M, n, x, y, ha, hr, hp⟩ := active_inhabited_programs
  have hy : (bridgeOf y).programs.isEmpty = false := by
    rw [show (bridgeOf y).programs = (bridgeOf x).programs from (hr.bridge.active ha).rel.programs, hp]
    exact lit_programs
  refine ⟨M, n, x, y, fF [.start 0] ((bridgeOf y).programs.map flipOut) y, [.start 0], ha, .nil hr,
    ⟨y, _, rfl, same_flip _, hr⟩, fun e => ?_, flip_ne hy⟩
  have e' : (bridgeOf y).log = (bridgeOf y).log ++ [.start 0] := e
  have := congrArg List.length e'
  simp at this

/-- The same at the prefill's relation. -/
theorem two_targets_XD :
    ∃ (M : Map) (n : Nat) (x y1 y2 : FF.S) (L : List Effect), (bridgeOf x).active = true ∧
      FRL [] (FullRXD P0 15235) M n x y1 ∧ FRL L (FullRXD P0 15235) M n x y2 ∧
      (bridgeOf y1).log ≠ (bridgeOf y2).log ∧ (bridgeOf y1).programs ≠ (bridgeOf y2).programs := by
  obtain ⟨M, n, x, y1, y2, L, ha, ⟨z1, p1, e1, s1, h1⟩, ⟨z2, p2, e2, s2, h2⟩, hl, hp⟩ := two_targets
  exact ⟨M, n, x, y1, y2, L, ha, ⟨z1, p1, e1, s1, h1.toXD⟩, ⟨z2, p2, e2, s2, h2.toXD⟩, hl, hp⟩

end Host.Ts.Sim.Full.ActiveRelation

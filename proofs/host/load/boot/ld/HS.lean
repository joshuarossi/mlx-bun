import host.load.boot.ld.S
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The support check of every unframed present address of `Ld.s0`, block by block over `Ld.gks`. -/

/-- The cut's number references. -/
noncomputable abbrev Ld.n : Nat := Ld.S0.tab.length

/-- The support check of the entry at `a`. -/
noncomputable def Ld.suppAt (a : Nat) : Bool :=
  match Ld.s0.heap.get a with
  | some h => bHobj (presentB Ld.s0) Ld.n h
  | none => true

tpl_all_blocks Ld.HS from Ld : Ld.suppAt

end Host.Load.Run.Prompt

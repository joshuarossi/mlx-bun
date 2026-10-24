import host.load.boot.ld.S
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Every unframed present address of `Ld.s0` is below its counter, block by block over `Ld.gks`. -/

/-- Present addresses are below the counter. -/
noncomputable def Ld.boundAt (a : Nat) : Bool := Nat.blt a Ld.s0.next

tpl_all_blocks Ld.BD from Ld : Ld.boundAt

end Host.Load.Run.Prompt

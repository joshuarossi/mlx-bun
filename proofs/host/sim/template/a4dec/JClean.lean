import host.sim.template.a4dec.Closed
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The JS bookkeeping at the template start (`Conv.JClean` at its counters): every present address checked, block by block. -/

noncomputable def DT.jcAt (a : Nat) : Bool := Conv.jcleanAtB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DT.s0 a
tpl_all_blocks DT.JC from DT : DT.jcAt
kernel_rfl DT.jcFramed : DT.frames.all DT.jcAt = true
theorem DT.jclean : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DT.s0 :=
  jclean_of_present fun a ha => DT.allPresent DT.JC.all DT.jcFramed a ha

end Host.Load.Run.Tpl

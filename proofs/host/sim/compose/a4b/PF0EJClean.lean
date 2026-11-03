import host.sim.compose.a4b.PF0EClosed
import host.sim.template.CallGen
import host.sim.template.a4pre_fd_x0_r0.S0Eq
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The JS bookkeeping at the x0 pre-final template and at its dcold chain's start (`Conv.JClean` at the template's counters): every present address checked, block by block. -/

noncomputable def PRE_pf_x0.jcAt (a : Nat) : Bool := Conv.jcleanAtB (⟨21986, 17764, 2826767, 112⟩ : Conv.Cnt) PRE_pf_x0.s0 a
tpl_all_blocks PRE_pf_x0.JC from PF0EV : PRE_pf_x0.jcAt
kernel_rfl PRE_pf_x0.jcFramed : PF0EV.frames.all PRE_pf_x0.jcAt = true
theorem PRE_pf_x0.jclean : Conv.JClean (⟨21986, 17764, 2826767, 112⟩ : Conv.Cnt) PRE_pf_x0.s0 :=
  jclean_of_present fun a ha => PRE_pf_x0.allPresent PRE_pf_x0.JC.all PRE_pf_x0.jcFramed a ha
theorem PRE_fd_x0_r0.jcl0 : Conv.JClean (⟨21986, 17764, 2826767, 112⟩ : Conv.Cnt) PRE_fd_x0_r0.s0 := by
  rw [PRE_fd_x0_r0.s0_tok]; exact PRE_pf_x0.jclean

end Host.Load.Run.Tpl

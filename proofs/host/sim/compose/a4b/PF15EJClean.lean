import host.sim.compose.a4b.PF15EClosed
import host.sim.template.CallGen
import host.sim.template.a4pre_fd_vw_r0.S0Eq
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The JS bookkeeping at the VW pre-final template and at its dcold chain's start (`Conv.JClean` at the template's counters): every present address checked, block by block. -/

noncomputable def PRE_pf_vw.jcAt (a : Nat) : Bool := Conv.jcleanAtB (⟨21966, 19057, 2823891, 8323⟩ : Conv.Cnt) PRE_pf_vw.s0 a
tpl_all_blocks PRE_pf_vw.JC from PF15EV : PRE_pf_vw.jcAt
kernel_rfl PRE_pf_vw.jcFramed : PF15EV.frames.all PRE_pf_vw.jcAt = true
theorem PRE_pf_vw.jclean : Conv.JClean (⟨21966, 19057, 2823891, 8323⟩ : Conv.Cnt) PRE_pf_vw.s0 :=
  jclean_of_present fun a ha => PRE_pf_vw.allPresent PRE_pf_vw.JC.all PRE_pf_vw.jcFramed a ha
theorem PRE_fd_vw_r0.jcl0 : Conv.JClean (⟨21966, 19057, 2823891, 8323⟩ : Conv.Cnt) PRE_fd_vw_r0.s0 := by
  rw [PRE_fd_vw_r0.s0_tok]; exact PRE_pf_vw.jclean

end Host.Load.Run.Tpl

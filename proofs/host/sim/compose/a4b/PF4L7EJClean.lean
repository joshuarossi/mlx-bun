import host.sim.compose.a4b.PF4L7EClosed
import host.sim.template.CallGen
import host.sim.template.a4pre_fd_x4_L7_r0.S0Eq
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The JS bookkeeping at the x4 L7 pre-final template and at its dcold chain's start (`Conv.JClean` at the template's counters): every present address checked, block by block. -/

noncomputable def PRE_pf_x4_L7.jcAt (a : Nat) : Bool := Conv.jcleanAtB (⟨22174, 19265, 2834113, 112⟩ : Conv.Cnt) PRE_pf_x4_L7.s0 a
tpl_all_blocks PRE_pf_x4_L7.JC from PF4L7EV : PRE_pf_x4_L7.jcAt
kernel_rfl PRE_pf_x4_L7.jcFramed : PF4L7EV.frames.all PRE_pf_x4_L7.jcAt = true
theorem PRE_pf_x4_L7.jclean : Conv.JClean (⟨22174, 19265, 2834113, 112⟩ : Conv.Cnt) PRE_pf_x4_L7.s0 :=
  jclean_of_present fun a ha => PRE_pf_x4_L7.allPresent PRE_pf_x4_L7.JC.all PRE_pf_x4_L7.jcFramed a ha
theorem PRE_fd_x4_L7_r0.jcl0 : Conv.JClean (⟨22174, 19265, 2834113, 112⟩ : Conv.Cnt) PRE_fd_x4_L7_r0.s0 := by
  rw [PRE_fd_x4_L7_r0.s0_tok]; exact PRE_pf_x4_L7.jclean

end Host.Load.Run.Tpl

import host.sim.template.a4pre_setup_early_r0.H0
import host.sim.template.ShiftJS
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PRE_setup_early_r0.start_eq :
  PRE_setup_early_r0.s0 = Host.Load.Run.Prompt.ldStT [] []
kernel_rfl PRE_setup_early_r0.start_tab :
  PRE_setup_early_r0.S0.tab = Host.Load.Decode.tab
kernel_rfl PRE_setup_early_r0.memo_get :
  PRE_setup_early_r0.s0.heap.get 4910 = some (.obj (objOf PRE_setup_early_r0.s0 4910))
kernel_rfl PRE_setup_early_r0.memo_empty :
  (objOf PRE_setup_early_r0.s0 4910).kind = .map []

end Host.Load.Run.Tpl

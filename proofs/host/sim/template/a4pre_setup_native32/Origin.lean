import host.sim.template.a4pre_setup_native32.BridgeOrigin
import host.sim.template.a4pre_setup_early_r0.Start
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Mlx Host.Load Host.Ts.Sim.Template

def PRENative32.withBridge (s : St Layers.full.S) (b : FfiAne.St) : St Layers.full.S :=
  s.setFfi ((⟨s.ffi.1.1.base, b⟩, s.ffi.1.2), s.ffi.2)

theorem PRENative32.withBridge_self (s : St Layers.full.S) :
    PRENative32.withBridge s s.ffi.1.1.bridge = s := by
  cases s
  rfl

kernel_rfl PRENative32.fields_exact :
  PRENative32.withBridge PRENative32.s0 (Boot.replay Host.Load.Run.Prompt.P.oblog2818) =
    PRE_setup_early_r0.s0

theorem PRENative32.start_exact : PRENative32.s0 = PRE_setup_early_r0.s0 :=
  (PRENative32.withBridge_self PRENative32.s0).symm.trans
    ((congrArg (PRENative32.withBridge PRENative32.s0) PRENative32.bridge_exact.symm).trans
      PRENative32.fields_exact)

kernel_rfl PRENative32.tab_exact : PRENative32.S0.tab = PRE_setup_early_r0.S0.tab

end Host.Load.Run.Tpl

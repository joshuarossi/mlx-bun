import host.sim.template.a4pre_setup_native32.Origin
import host.sim.template.a4pre_setup_early_r0.OkB
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

noncomputable def PRENative32.originalS1 : SSrv :=
  ⟨PRENative32.S1.tab, PRE_setup_early_r0.S0.oracle.drop PRENative32.O.length⟩

kernel_rfl PRENative32.fuel_exact : nth? PRE_setup_early_r0.ks 0 = some 897
kernel_rfl PRENative32.oracle_prefix :
  PRE_setup_early_r0.S0.oracle.take PRENative32.O.length = PRENative32.O

kernel_rfl PRENative32.checked_native :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative32.s0 PRE_setup_early_r0.S0 =
    some (PRENative32.s1, PRENative32.originalS1)

theorem PRENative32.checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32
      PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative32.s1, PRENative32.originalS1) := by
  rw [← PRENative32.start_exact]
  exact PRENative32.checked_native

end Host.Load.Run.Tpl

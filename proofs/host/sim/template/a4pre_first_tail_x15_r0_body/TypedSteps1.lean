import host.sim.template.a4pre_first_tail_x15_r0_body.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.H1
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA5 from PRE_first_tail_x15_r0_body.s14 to PRE_first_tail_x15_r0_body.s15 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s14).run PRE_first_tail_x15_r0_body.S14 = some (PRE_first_tail_x15_r0_body.s15, PRE_first_tail_x15_r0_body.S15)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA6 from PRE_first_tail_x15_r0_body.s19 to PRE_first_tail_x15_r0_body.s20 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s19).run PRE_first_tail_x15_r0_body.S19 = some (PRE_first_tail_x15_r0_body.s20, PRE_first_tail_x15_r0_body.S20)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB6 from PRE_first_tail_x15_r0_body.s20 to PRE_first_tail_x15_r0_body.s21 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s20).run PRE_first_tail_x15_r0_body.S20 = some (PRE_first_tail_x15_r0_body.s21, PRE_first_tail_x15_r0_body.S21)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA7 from PRE_first_tail_x15_r0_body.s23 to PRE_first_tail_x15_r0_body.s24 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s23).run PRE_first_tail_x15_r0_body.S23 = some (PRE_first_tail_x15_r0_body.s24, PRE_first_tail_x15_r0_body.S24)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA8 from PRE_first_tail_x15_r0_body.s27 to PRE_first_tail_x15_r0_body.s28 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s27).run PRE_first_tail_x15_r0_body.S27 = some (PRE_first_tail_x15_r0_body.s28, PRE_first_tail_x15_r0_body.S28)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA9 from PRE_first_tail_x15_r0_body.s32 to PRE_first_tail_x15_r0_body.s33 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s32).run PRE_first_tail_x15_r0_body.S32 = some (PRE_first_tail_x15_r0_body.s33, PRE_first_tail_x15_r0_body.S33)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB9 from PRE_first_tail_x15_r0_body.s33 to PRE_first_tail_x15_r0_body.s34 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s33).run PRE_first_tail_x15_r0_body.S33 = some (PRE_first_tail_x15_r0_body.s34, PRE_first_tail_x15_r0_body.S34)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA10 from PRE_first_tail_x15_r0_body.s35 to PRE_first_tail_x15_r0_body.s36 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s35).run PRE_first_tail_x15_r0_body.S35 = some (PRE_first_tail_x15_r0_body.s36, PRE_first_tail_x15_r0_body.S36)
end Host.Load.Run.Tpl

import host.sim.template.a4pre_first_tail_x15_r0_body.H0
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA1 from PRE_first_tail_x15_r0_body.s1 to PRE_first_tail_x15_r0_body.s2 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1).run PRE_first_tail_x15_r0_body.S1 = some (PRE_first_tail_x15_r0_body.s2, PRE_first_tail_x15_r0_body.S2)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB1 from PRE_first_tail_x15_r0_body.s2 to PRE_first_tail_x15_r0_body.s3 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s2).run PRE_first_tail_x15_r0_body.S2 = some (PRE_first_tail_x15_r0_body.s3, PRE_first_tail_x15_r0_body.S3)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA2 from PRE_first_tail_x15_r0_body.s4 to PRE_first_tail_x15_r0_body.s5 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s4).run PRE_first_tail_x15_r0_body.S4 = some (PRE_first_tail_x15_r0_body.s5, PRE_first_tail_x15_r0_body.S5)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB2 from PRE_first_tail_x15_r0_body.s5 to PRE_first_tail_x15_r0_body.s6 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s5).run PRE_first_tail_x15_r0_body.S5 = some (PRE_first_tail_x15_r0_body.s6, PRE_first_tail_x15_r0_body.S6)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA3 from PRE_first_tail_x15_r0_body.s7 to PRE_first_tail_x15_r0_body.s8 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s7).run PRE_first_tail_x15_r0_body.S7 = some (PRE_first_tail_x15_r0_body.s8, PRE_first_tail_x15_r0_body.S8)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB3 from PRE_first_tail_x15_r0_body.s8 to PRE_first_tail_x15_r0_body.s9 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s8).run PRE_first_tail_x15_r0_body.S8 = some (PRE_first_tail_x15_r0_body.s9, PRE_first_tail_x15_r0_body.S9)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA4 from PRE_first_tail_x15_r0_body.s10 to PRE_first_tail_x15_r0_body.s11 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s10).run PRE_first_tail_x15_r0_body.S10 = some (PRE_first_tail_x15_r0_body.s11, PRE_first_tail_x15_r0_body.S11)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB4 from PRE_first_tail_x15_r0_body.s11 to PRE_first_tail_x15_r0_body.s12 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s11).run PRE_first_tail_x15_r0_body.S11 = some (PRE_first_tail_x15_r0_body.s12, PRE_first_tail_x15_r0_body.S12)
end Host.Load.Run.Tpl

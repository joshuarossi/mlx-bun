import host.sim.template.a4pre_first_tail_x15_r0_body.H2
import host.sim.template.a4pre_first_tail_x15_r0_body.H3
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB25 from PRE_first_tail_x15_r0_body.s83 to PRE_first_tail_x15_r0_body.s84 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s83).run PRE_first_tail_x15_r0_body.S83 = some (PRE_first_tail_x15_r0_body.s84, PRE_first_tail_x15_r0_body.S84)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA26 from PRE_first_tail_x15_r0_body.s85 to PRE_first_tail_x15_r0_body.s86 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s85).run PRE_first_tail_x15_r0_body.S85 = some (PRE_first_tail_x15_r0_body.s86, PRE_first_tail_x15_r0_body.S86)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB26 from PRE_first_tail_x15_r0_body.s86 to PRE_first_tail_x15_r0_body.s87 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s86).run PRE_first_tail_x15_r0_body.S86 = some (PRE_first_tail_x15_r0_body.s87, PRE_first_tail_x15_r0_body.S87)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA27 from PRE_first_tail_x15_r0_body.s88 to PRE_first_tail_x15_r0_body.s89 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s88).run PRE_first_tail_x15_r0_body.S88 = some (PRE_first_tail_x15_r0_body.s89, PRE_first_tail_x15_r0_body.S89)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB27 from PRE_first_tail_x15_r0_body.s89 to PRE_first_tail_x15_r0_body.s90 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s89).run PRE_first_tail_x15_r0_body.S89 = some (PRE_first_tail_x15_r0_body.s90, PRE_first_tail_x15_r0_body.S90)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA28 from PRE_first_tail_x15_r0_body.s91 to PRE_first_tail_x15_r0_body.s92 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s91).run PRE_first_tail_x15_r0_body.S91 = some (PRE_first_tail_x15_r0_body.s92, PRE_first_tail_x15_r0_body.S92)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA29 from PRE_first_tail_x15_r0_body.s95 to PRE_first_tail_x15_r0_body.s96 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s95).run PRE_first_tail_x15_r0_body.S95 = some (PRE_first_tail_x15_r0_body.s96, PRE_first_tail_x15_r0_body.S96)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB29 from PRE_first_tail_x15_r0_body.s96 to PRE_first_tail_x15_r0_body.s97 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s96).run PRE_first_tail_x15_r0_body.S96 = some (PRE_first_tail_x15_r0_body.s97, PRE_first_tail_x15_r0_body.S97)
end Host.Load.Run.Tpl

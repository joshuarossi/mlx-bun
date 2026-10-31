import host.sim.template.a4pre_first_tail_x15_r0_body.H28
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA268 from PRE_first_tail_x15_r0_body.s904 to PRE_first_tail_x15_r0_body.s905 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s904).run PRE_first_tail_x15_r0_body.S904 = some (PRE_first_tail_x15_r0_body.s905, PRE_first_tail_x15_r0_body.S905)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB268 from PRE_first_tail_x15_r0_body.s905 to PRE_first_tail_x15_r0_body.s906 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s905).run PRE_first_tail_x15_r0_body.S905 = some (PRE_first_tail_x15_r0_body.s906, PRE_first_tail_x15_r0_body.S906)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA269 from PRE_first_tail_x15_r0_body.s907 to PRE_first_tail_x15_r0_body.s908 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s907).run PRE_first_tail_x15_r0_body.S907 = some (PRE_first_tail_x15_r0_body.s908, PRE_first_tail_x15_r0_body.S908)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA270 from PRE_first_tail_x15_r0_body.s911 to PRE_first_tail_x15_r0_body.s912 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s911).run PRE_first_tail_x15_r0_body.S911 = some (PRE_first_tail_x15_r0_body.s912, PRE_first_tail_x15_r0_body.S912)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB270 from PRE_first_tail_x15_r0_body.s912 to PRE_first_tail_x15_r0_body.s913 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s912).run PRE_first_tail_x15_r0_body.S912 = some (PRE_first_tail_x15_r0_body.s913, PRE_first_tail_x15_r0_body.S913)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA271 from PRE_first_tail_x15_r0_body.s914 to PRE_first_tail_x15_r0_body.s915 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s914).run PRE_first_tail_x15_r0_body.S914 = some (PRE_first_tail_x15_r0_body.s915, PRE_first_tail_x15_r0_body.S915)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA272 from PRE_first_tail_x15_r0_body.s918 to PRE_first_tail_x15_r0_body.s919 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s918).run PRE_first_tail_x15_r0_body.S918 = some (PRE_first_tail_x15_r0_body.s919, PRE_first_tail_x15_r0_body.S919)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA273 from PRE_first_tail_x15_r0_body.s922 to PRE_first_tail_x15_r0_body.s923 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s922).run PRE_first_tail_x15_r0_body.S922 = some (PRE_first_tail_x15_r0_body.s923, PRE_first_tail_x15_r0_body.S923)
end Host.Load.Run.Tpl

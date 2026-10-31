import host.sim.template.a4pre_first_tail_x15_r0_body.H26
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA249 from PRE_first_tail_x15_r0_body.s841 to PRE_first_tail_x15_r0_body.s842 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s841).run PRE_first_tail_x15_r0_body.S841 = some (PRE_first_tail_x15_r0_body.s842, PRE_first_tail_x15_r0_body.S842)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB249 from PRE_first_tail_x15_r0_body.s842 to PRE_first_tail_x15_r0_body.s843 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s842).run PRE_first_tail_x15_r0_body.S842 = some (PRE_first_tail_x15_r0_body.s843, PRE_first_tail_x15_r0_body.S843)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA250 from PRE_first_tail_x15_r0_body.s844 to PRE_first_tail_x15_r0_body.s845 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s844).run PRE_first_tail_x15_r0_body.S844 = some (PRE_first_tail_x15_r0_body.s845, PRE_first_tail_x15_r0_body.S845)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB250 from PRE_first_tail_x15_r0_body.s845 to PRE_first_tail_x15_r0_body.s846 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s845).run PRE_first_tail_x15_r0_body.S845 = some (PRE_first_tail_x15_r0_body.s846, PRE_first_tail_x15_r0_body.S846)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA251 from PRE_first_tail_x15_r0_body.s847 to PRE_first_tail_x15_r0_body.s848 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s847).run PRE_first_tail_x15_r0_body.S847 = some (PRE_first_tail_x15_r0_body.s848, PRE_first_tail_x15_r0_body.S848)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB251 from PRE_first_tail_x15_r0_body.s848 to PRE_first_tail_x15_r0_body.s849 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s848).run PRE_first_tail_x15_r0_body.S848 = some (PRE_first_tail_x15_r0_body.s849, PRE_first_tail_x15_r0_body.S849)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA252 from PRE_first_tail_x15_r0_body.s850 to PRE_first_tail_x15_r0_body.s851 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s850).run PRE_first_tail_x15_r0_body.S850 = some (PRE_first_tail_x15_r0_body.s851, PRE_first_tail_x15_r0_body.S851)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB252 from PRE_first_tail_x15_r0_body.s851 to PRE_first_tail_x15_r0_body.s852 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s851).run PRE_first_tail_x15_r0_body.S851 = some (PRE_first_tail_x15_r0_body.s852, PRE_first_tail_x15_r0_body.S852)
end Host.Load.Run.Tpl

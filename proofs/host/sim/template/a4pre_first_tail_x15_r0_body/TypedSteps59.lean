import host.sim.template.a4pre_first_tail_x15_r0_body.H30
import host.sim.template.a4pre_first_tail_x15_r0_body.H31
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA293 from PRE_first_tail_x15_r0_body.s989 to PRE_first_tail_x15_r0_body.s990 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s989).run PRE_first_tail_x15_r0_body.S989 = some (PRE_first_tail_x15_r0_body.s990, PRE_first_tail_x15_r0_body.S990)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB293 from PRE_first_tail_x15_r0_body.s990 to PRE_first_tail_x15_r0_body.s991 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s990).run PRE_first_tail_x15_r0_body.S990 = some (PRE_first_tail_x15_r0_body.s991, PRE_first_tail_x15_r0_body.S991)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA294 from PRE_first_tail_x15_r0_body.s992 to PRE_first_tail_x15_r0_body.s993 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s992).run PRE_first_tail_x15_r0_body.S992 = some (PRE_first_tail_x15_r0_body.s993, PRE_first_tail_x15_r0_body.S993)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA295 from PRE_first_tail_x15_r0_body.s996 to PRE_first_tail_x15_r0_body.s997 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s996).run PRE_first_tail_x15_r0_body.S996 = some (PRE_first_tail_x15_r0_body.s997, PRE_first_tail_x15_r0_body.S997)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA296 from PRE_first_tail_x15_r0_body.s1000 to PRE_first_tail_x15_r0_body.s1001 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1000).run PRE_first_tail_x15_r0_body.S1000 = some (PRE_first_tail_x15_r0_body.s1001, PRE_first_tail_x15_r0_body.S1001)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB296 from PRE_first_tail_x15_r0_body.s1001 to PRE_first_tail_x15_r0_body.s1002 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1001).run PRE_first_tail_x15_r0_body.S1001 = some (PRE_first_tail_x15_r0_body.s1002, PRE_first_tail_x15_r0_body.S1002)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA297 from PRE_first_tail_x15_r0_body.s1003 to PRE_first_tail_x15_r0_body.s1004 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1003).run PRE_first_tail_x15_r0_body.S1003 = some (PRE_first_tail_x15_r0_body.s1004, PRE_first_tail_x15_r0_body.S1004)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB297 from PRE_first_tail_x15_r0_body.s1004 to PRE_first_tail_x15_r0_body.s1005 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1004).run PRE_first_tail_x15_r0_body.S1004 = some (PRE_first_tail_x15_r0_body.s1005, PRE_first_tail_x15_r0_body.S1005)
end Host.Load.Run.Tpl

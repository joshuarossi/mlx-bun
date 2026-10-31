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
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA268 from PRE_first_tail_x15_r0_body.s990 to PRE_first_tail_x15_r0_body.s991 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s990).run PRE_first_tail_x15_r0_body.S990 = some (PRE_first_tail_x15_r0_body.s991, PRE_first_tail_x15_r0_body.S991)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB268 from PRE_first_tail_x15_r0_body.s991 to PRE_first_tail_x15_r0_body.s992 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s991).run PRE_first_tail_x15_r0_body.S991 = some (PRE_first_tail_x15_r0_body.s992, PRE_first_tail_x15_r0_body.S992)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA269 from PRE_first_tail_x15_r0_body.s993 to PRE_first_tail_x15_r0_body.s994 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s993).run PRE_first_tail_x15_r0_body.S993 = some (PRE_first_tail_x15_r0_body.s994, PRE_first_tail_x15_r0_body.S994)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA270 from PRE_first_tail_x15_r0_body.s997 to PRE_first_tail_x15_r0_body.s998 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s997).run PRE_first_tail_x15_r0_body.S997 = some (PRE_first_tail_x15_r0_body.s998, PRE_first_tail_x15_r0_body.S998)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB270 from PRE_first_tail_x15_r0_body.s998 to PRE_first_tail_x15_r0_body.s999 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s998).run PRE_first_tail_x15_r0_body.S998 = some (PRE_first_tail_x15_r0_body.s999, PRE_first_tail_x15_r0_body.S999)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA271 from PRE_first_tail_x15_r0_body.s1001 to PRE_first_tail_x15_r0_body.s1002 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1001).run PRE_first_tail_x15_r0_body.S1001 = some (PRE_first_tail_x15_r0_body.s1002, PRE_first_tail_x15_r0_body.S1002)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA272 from PRE_first_tail_x15_r0_body.s1005 to PRE_first_tail_x15_r0_body.s1006 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1005).run PRE_first_tail_x15_r0_body.S1005 = some (PRE_first_tail_x15_r0_body.s1006, PRE_first_tail_x15_r0_body.S1006)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA273 from PRE_first_tail_x15_r0_body.s1010 to PRE_first_tail_x15_r0_body.s1011 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1010).run PRE_first_tail_x15_r0_body.S1010 = some (PRE_first_tail_x15_r0_body.s1011, PRE_first_tail_x15_r0_body.S1011)
end Host.Load.Run.Tpl

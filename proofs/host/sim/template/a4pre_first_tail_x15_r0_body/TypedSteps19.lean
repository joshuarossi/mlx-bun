import host.sim.template.a4pre_first_tail_x15_r0_body.H9
import host.sim.template.a4pre_first_tail_x15_r0_body.H10
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA95 from PRE_first_tail_x15_r0_body.s319 to PRE_first_tail_x15_r0_body.s320 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s319).run PRE_first_tail_x15_r0_body.S319 = some (PRE_first_tail_x15_r0_body.s320, PRE_first_tail_x15_r0_body.S320)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB95 from PRE_first_tail_x15_r0_body.s320 to PRE_first_tail_x15_r0_body.s321 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s320).run PRE_first_tail_x15_r0_body.S320 = some (PRE_first_tail_x15_r0_body.s321, PRE_first_tail_x15_r0_body.S321)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA96 from PRE_first_tail_x15_r0_body.s322 to PRE_first_tail_x15_r0_body.s323 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s322).run PRE_first_tail_x15_r0_body.S322 = some (PRE_first_tail_x15_r0_body.s323, PRE_first_tail_x15_r0_body.S323)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB96 from PRE_first_tail_x15_r0_body.s323 to PRE_first_tail_x15_r0_body.s324 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s323).run PRE_first_tail_x15_r0_body.S323 = some (PRE_first_tail_x15_r0_body.s324, PRE_first_tail_x15_r0_body.S324)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA97 from PRE_first_tail_x15_r0_body.s325 to PRE_first_tail_x15_r0_body.s326 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s325).run PRE_first_tail_x15_r0_body.S325 = some (PRE_first_tail_x15_r0_body.s326, PRE_first_tail_x15_r0_body.S326)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB97 from PRE_first_tail_x15_r0_body.s326 to PRE_first_tail_x15_r0_body.s327 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s326).run PRE_first_tail_x15_r0_body.S326 = some (PRE_first_tail_x15_r0_body.s327, PRE_first_tail_x15_r0_body.S327)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA98 from PRE_first_tail_x15_r0_body.s328 to PRE_first_tail_x15_r0_body.s329 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s328).run PRE_first_tail_x15_r0_body.S328 = some (PRE_first_tail_x15_r0_body.s329, PRE_first_tail_x15_r0_body.S329)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA99 from PRE_first_tail_x15_r0_body.s332 to PRE_first_tail_x15_r0_body.s333 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s332).run PRE_first_tail_x15_r0_body.S332 = some (PRE_first_tail_x15_r0_body.s333, PRE_first_tail_x15_r0_body.S333)
end Host.Load.Run.Tpl

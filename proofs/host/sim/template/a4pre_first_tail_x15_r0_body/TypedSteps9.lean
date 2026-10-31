import host.sim.template.a4pre_first_tail_x15_r0_body.H5
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA45 from PRE_first_tail_x15_r0_body.s163 to PRE_first_tail_x15_r0_body.s164 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s163).run PRE_first_tail_x15_r0_body.S163 = some (PRE_first_tail_x15_r0_body.s164, PRE_first_tail_x15_r0_body.S164)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB45 from PRE_first_tail_x15_r0_body.s164 to PRE_first_tail_x15_r0_body.s165 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s164).run PRE_first_tail_x15_r0_body.S164 = some (PRE_first_tail_x15_r0_body.s165, PRE_first_tail_x15_r0_body.S165)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA46 from PRE_first_tail_x15_r0_body.s167 to PRE_first_tail_x15_r0_body.s168 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s167).run PRE_first_tail_x15_r0_body.S167 = some (PRE_first_tail_x15_r0_body.s168, PRE_first_tail_x15_r0_body.S168)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA47 from PRE_first_tail_x15_r0_body.s171 to PRE_first_tail_x15_r0_body.s172 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s171).run PRE_first_tail_x15_r0_body.S171 = some (PRE_first_tail_x15_r0_body.s172, PRE_first_tail_x15_r0_body.S172)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA48 from PRE_first_tail_x15_r0_body.s176 to PRE_first_tail_x15_r0_body.s177 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s176).run PRE_first_tail_x15_r0_body.S176 = some (PRE_first_tail_x15_r0_body.s177, PRE_first_tail_x15_r0_body.S177)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB48 from PRE_first_tail_x15_r0_body.s177 to PRE_first_tail_x15_r0_body.s178 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s177).run PRE_first_tail_x15_r0_body.S177 = some (PRE_first_tail_x15_r0_body.s178, PRE_first_tail_x15_r0_body.S178)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA49 from PRE_first_tail_x15_r0_body.s179 to PRE_first_tail_x15_r0_body.s180 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s179).run PRE_first_tail_x15_r0_body.S179 = some (PRE_first_tail_x15_r0_body.s180, PRE_first_tail_x15_r0_body.S180)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB49 from PRE_first_tail_x15_r0_body.s180 to PRE_first_tail_x15_r0_body.s181 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s180).run PRE_first_tail_x15_r0_body.S180 = some (PRE_first_tail_x15_r0_body.s181, PRE_first_tail_x15_r0_body.S181)
end Host.Load.Run.Tpl

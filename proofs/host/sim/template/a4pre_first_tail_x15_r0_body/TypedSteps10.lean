import host.sim.template.a4pre_first_tail_x15_r0_body.H5
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA50 from PRE_first_tail_x15_r0_body.s166 to PRE_first_tail_x15_r0_body.s167 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s166).run PRE_first_tail_x15_r0_body.S166 = some (PRE_first_tail_x15_r0_body.s167, PRE_first_tail_x15_r0_body.S167)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB50 from PRE_first_tail_x15_r0_body.s167 to PRE_first_tail_x15_r0_body.s168 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s167).run PRE_first_tail_x15_r0_body.S167 = some (PRE_first_tail_x15_r0_body.s168, PRE_first_tail_x15_r0_body.S168)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA51 from PRE_first_tail_x15_r0_body.s169 to PRE_first_tail_x15_r0_body.s170 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s169).run PRE_first_tail_x15_r0_body.S169 = some (PRE_first_tail_x15_r0_body.s170, PRE_first_tail_x15_r0_body.S170)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB51 from PRE_first_tail_x15_r0_body.s170 to PRE_first_tail_x15_r0_body.s171 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s170).run PRE_first_tail_x15_r0_body.S170 = some (PRE_first_tail_x15_r0_body.s171, PRE_first_tail_x15_r0_body.S171)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA52 from PRE_first_tail_x15_r0_body.s172 to PRE_first_tail_x15_r0_body.s173 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s172).run PRE_first_tail_x15_r0_body.S172 = some (PRE_first_tail_x15_r0_body.s173, PRE_first_tail_x15_r0_body.S173)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA53 from PRE_first_tail_x15_r0_body.s176 to PRE_first_tail_x15_r0_body.s177 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s176).run PRE_first_tail_x15_r0_body.S176 = some (PRE_first_tail_x15_r0_body.s177, PRE_first_tail_x15_r0_body.S177)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB53 from PRE_first_tail_x15_r0_body.s177 to PRE_first_tail_x15_r0_body.s178 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s177).run PRE_first_tail_x15_r0_body.S177 = some (PRE_first_tail_x15_r0_body.s178, PRE_first_tail_x15_r0_body.S178)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA54 from PRE_first_tail_x15_r0_body.s179 to PRE_first_tail_x15_r0_body.s180 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s179).run PRE_first_tail_x15_r0_body.S179 = some (PRE_first_tail_x15_r0_body.s180, PRE_first_tail_x15_r0_body.S180)
end Host.Load.Run.Tpl

import host.sim.template.a4pre_first_tail_x15_r0_body.H31
import host.sim.template.a4pre_first_tail_x15_r0_body.H32
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB273 from PRE_first_tail_x15_r0_body.s1011 to PRE_first_tail_x15_r0_body.s1012 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1011).run PRE_first_tail_x15_r0_body.S1011 = some (PRE_first_tail_x15_r0_body.s1012, PRE_first_tail_x15_r0_body.S1012)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA274 from PRE_first_tail_x15_r0_body.s1014 to PRE_first_tail_x15_r0_body.s1015 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1014).run PRE_first_tail_x15_r0_body.S1014 = some (PRE_first_tail_x15_r0_body.s1015, PRE_first_tail_x15_r0_body.S1015)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB274 from PRE_first_tail_x15_r0_body.s1015 to PRE_first_tail_x15_r0_body.s1016 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1015).run PRE_first_tail_x15_r0_body.S1015 = some (PRE_first_tail_x15_r0_body.s1016, PRE_first_tail_x15_r0_body.S1016)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA275 from PRE_first_tail_x15_r0_body.s1017 to PRE_first_tail_x15_r0_body.s1018 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1017).run PRE_first_tail_x15_r0_body.S1017 = some (PRE_first_tail_x15_r0_body.s1018, PRE_first_tail_x15_r0_body.S1018)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB275 from PRE_first_tail_x15_r0_body.s1018 to PRE_first_tail_x15_r0_body.s1019 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1018).run PRE_first_tail_x15_r0_body.S1018 = some (PRE_first_tail_x15_r0_body.s1019, PRE_first_tail_x15_r0_body.S1019)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA276 from PRE_first_tail_x15_r0_body.s1021 to PRE_first_tail_x15_r0_body.s1022 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1021).run PRE_first_tail_x15_r0_body.S1021 = some (PRE_first_tail_x15_r0_body.s1022, PRE_first_tail_x15_r0_body.S1022)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA277 from PRE_first_tail_x15_r0_body.s1025 to PRE_first_tail_x15_r0_body.s1026 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1025).run PRE_first_tail_x15_r0_body.S1025 = some (PRE_first_tail_x15_r0_body.s1026, PRE_first_tail_x15_r0_body.S1026)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB277 from PRE_first_tail_x15_r0_body.s1026 to PRE_first_tail_x15_r0_body.s1027 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1026).run PRE_first_tail_x15_r0_body.S1026 = some (PRE_first_tail_x15_r0_body.s1027, PRE_first_tail_x15_r0_body.S1027)
end Host.Load.Run.Tpl

import host.sim.template.a4pre_first_tail_x15_r0_body.H21
import host.sim.template.a4pre_first_tail_x15_r0_body.H22
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA189 from PRE_first_tail_x15_r0_body.s699 to PRE_first_tail_x15_r0_body.s700 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s699).run PRE_first_tail_x15_r0_body.S699 = some (PRE_first_tail_x15_r0_body.s700, PRE_first_tail_x15_r0_body.S700)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB189 from PRE_first_tail_x15_r0_body.s700 to PRE_first_tail_x15_r0_body.s701 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s700).run PRE_first_tail_x15_r0_body.S700 = some (PRE_first_tail_x15_r0_body.s701, PRE_first_tail_x15_r0_body.S701)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA190 from PRE_first_tail_x15_r0_body.s702 to PRE_first_tail_x15_r0_body.s703 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s702).run PRE_first_tail_x15_r0_body.S702 = some (PRE_first_tail_x15_r0_body.s703, PRE_first_tail_x15_r0_body.S703)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB190 from PRE_first_tail_x15_r0_body.s703 to PRE_first_tail_x15_r0_body.s704 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s703).run PRE_first_tail_x15_r0_body.S703 = some (PRE_first_tail_x15_r0_body.s704, PRE_first_tail_x15_r0_body.S704)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA191 from PRE_first_tail_x15_r0_body.s705 to PRE_first_tail_x15_r0_body.s706 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s705).run PRE_first_tail_x15_r0_body.S705 = some (PRE_first_tail_x15_r0_body.s706, PRE_first_tail_x15_r0_body.S706)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA192 from PRE_first_tail_x15_r0_body.s709 to PRE_first_tail_x15_r0_body.s710 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s709).run PRE_first_tail_x15_r0_body.S709 = some (PRE_first_tail_x15_r0_body.s710, PRE_first_tail_x15_r0_body.S710)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB192 from PRE_first_tail_x15_r0_body.s710 to PRE_first_tail_x15_r0_body.s711 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s710).run PRE_first_tail_x15_r0_body.S710 = some (PRE_first_tail_x15_r0_body.s711, PRE_first_tail_x15_r0_body.S711)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA193 from PRE_first_tail_x15_r0_body.s713 to PRE_first_tail_x15_r0_body.s714 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s713).run PRE_first_tail_x15_r0_body.S713 = some (PRE_first_tail_x15_r0_body.s714, PRE_first_tail_x15_r0_body.S714)
end Host.Load.Run.Tpl

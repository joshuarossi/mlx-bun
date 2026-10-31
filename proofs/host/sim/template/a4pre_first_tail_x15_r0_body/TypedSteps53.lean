import host.sim.template.a4pre_first_tail_x15_r0_body.H30
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA263 from PRE_first_tail_x15_r0_body.s972 to PRE_first_tail_x15_r0_body.s973 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s972).run PRE_first_tail_x15_r0_body.S972 = some (PRE_first_tail_x15_r0_body.s973, PRE_first_tail_x15_r0_body.S973)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA264 from PRE_first_tail_x15_r0_body.s976 to PRE_first_tail_x15_r0_body.s977 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s976).run PRE_first_tail_x15_r0_body.S976 = some (PRE_first_tail_x15_r0_body.s977, PRE_first_tail_x15_r0_body.S977)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA265 from PRE_first_tail_x15_r0_body.s981 to PRE_first_tail_x15_r0_body.s982 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s981).run PRE_first_tail_x15_r0_body.S981 = some (PRE_first_tail_x15_r0_body.s982, PRE_first_tail_x15_r0_body.S982)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB265 from PRE_first_tail_x15_r0_body.s982 to PRE_first_tail_x15_r0_body.s983 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s982).run PRE_first_tail_x15_r0_body.S982 = some (PRE_first_tail_x15_r0_body.s983, PRE_first_tail_x15_r0_body.S983)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA266 from PRE_first_tail_x15_r0_body.s984 to PRE_first_tail_x15_r0_body.s985 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s984).run PRE_first_tail_x15_r0_body.S984 = some (PRE_first_tail_x15_r0_body.s985, PRE_first_tail_x15_r0_body.S985)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB266 from PRE_first_tail_x15_r0_body.s985 to PRE_first_tail_x15_r0_body.s986 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s985).run PRE_first_tail_x15_r0_body.S985 = some (PRE_first_tail_x15_r0_body.s986, PRE_first_tail_x15_r0_body.S986)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA267 from PRE_first_tail_x15_r0_body.s987 to PRE_first_tail_x15_r0_body.s988 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s987).run PRE_first_tail_x15_r0_body.S987 = some (PRE_first_tail_x15_r0_body.s988, PRE_first_tail_x15_r0_body.S988)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB267 from PRE_first_tail_x15_r0_body.s988 to PRE_first_tail_x15_r0_body.s989 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s988).run PRE_first_tail_x15_r0_body.S988 = some (PRE_first_tail_x15_r0_body.s989, PRE_first_tail_x15_r0_body.S989)
end Host.Load.Run.Tpl

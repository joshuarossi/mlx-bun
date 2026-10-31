import host.sim.template.a4eos_cut.Facts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Compose

/-- The actual full-FFI state at the first acceptance failure. -/
noncomputable def EOSCut.lenPair : St EOSCut.F.S × SSrv :=
  (runS EOSCut.F 394 DEC.s0 EOSCut.S0).getD (DEC.s0, EOSCut.S0)
noncomputable def EOSCut.lenRest : List Frame := EOSCut.lenPair.1.stack.drop 1

kernel_rfl EOSCut.len_reached : runS EOSCut.F 394 DEC.s0 EOSCut.S0 = some EOSCut.lenPair
kernel_rfl EOSCut.len_ctl : EOSCut.lenPair.1.ctl = .ret (.obj 2665)
kernel_rfl EOSCut.len_stack :
  EOSCut.lenPair.1.stack = .e (.member (.str chars!"length") false) :: EOSCut.lenRest
kernel_rfl EOSCut.len_unaccepted : EOSCut.okB0 EOSCut.lenPair.1 EOSCut.lenPair.2 = false

end Host.Load.Run.Tpl

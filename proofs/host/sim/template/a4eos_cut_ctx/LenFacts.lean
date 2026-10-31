import host.sim.template.a4eos_cut_ctx.Patch
import host.sim.template.a4eos_cut.OkB
import host.sim.template.a4eos_cut.Barrier
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Compose Host.Ts.Sim.Template

noncomputable def EOSCutCtxLen.prePair : St EOSCutCtxLen.F.S × SSrv :=
  (runS EOSCutCtxLen.F 393 DEC.s0 EOSCutCtxLen.S0).getD (DEC.s0, EOSCutCtxLen.S0)
noncomputable def EOSCutCtxLen.pre : St EOSCutCtxLen.F.S := EOSCutCtxLen.prePair.1
noncomputable def EOSCutCtxLen.preSrv : SSrv := EOSCutCtxLen.prePair.2
noncomputable def EOSCutCtxLen.fs : List Frame := EOSCutCtxLen.s1.stack.drop 1

kernel_rfl EOSCutCtxLen.start_exact : EOSCutCtxLen.s0 = DEC.s0
kernel_rfl EOSCutCtxLen.tab_exact : EOSCutCtxLen.S0.tab = DEC.tab0
kernel_rfl EOSCutCtxLen.oracle_exact : EOSCutCtxLen.S0.oracle = EOSCutCtxLen.O
kernel_rfl EOSCutCtxLen.oracle1 : EOSCutCtxLen.S1.oracle = []
kernel_rfl EOSCutCtxLen.patch_oracle : EOSCutCtx.inputSrv.oracle = []
kernel_rfl EOSCutCtxLen.prefix : runOk EOSCutCtxLen.F EOSCut.okB0 393 DEC.s0 EOSCutCtxLen.S0 =
  some (EOSCutCtxLen.pre, EOSCutCtxLen.preSrv)
kernel_rfl EOSCutCtxLen.ok0 : EOSCut.okB0 DEC.s0 EOSCutCtxLen.S0 = true
kernel_rfl EOSCutCtxLen.okPre : EOSCut.okB0 EOSCutCtxLen.pre EOSCutCtxLen.preSrv = true
kernel_rfl EOSCutCtxLen.haltPre : isHalt EOSCutCtxLen.pre.ctl = false
kernel_rfl EOSCutCtxLen.step : interpS (step EOSCutCtxLen.F EOSCutCtxLen.pre).run EOSCutCtxLen.preSrv =
  some (EOSCutCtxLen.s1, EOSCutCtxLen.S1)
kernel_rfl EOSCutCtxLen.actual394 : runS EOSCutCtxLen.F 394 DEC.s0 EOSCutCtxLen.S0 =
  some (EOSCutCtxLen.s1, EOSCutCtxLen.S1)
kernel_rfl EOSCutCtxLen.frozen394 : EOSCutCtxLen.s1 = EOSCut.lenPair.1
kernel_rfl EOSCutCtxLen.ctl : EOSCutCtxLen.s1.ctl = .ret (.obj 2665)
kernel_rfl EOSCutCtxLen.stack : EOSCutCtxLen.s1.stack = .e (.member kLength false) :: EOSCutCtxLen.fs
kernel_rfl EOSCutCtxLen.unaccepted : EOSCut.okB0 EOSCutCtxLen.s1 EOSCutCtxLen.S1 = false
kernel_rfl EOSCutCtxLen.obj : EOSCutCtxLen.s1.obj? 2665 = some (objOf EOSCutCtxLen.s1 2665)
kernel_rfl EOSCutCtxLen.kind : (objOf EOSCutCtxLen.s1 2665).kind = .array (arrOf DEC.s0 2665 ++ [])
kernel_rfl EOSCutCtxLen.tabGrow : Nat.ble EOSCutCtxLen.S0.tab.length EOSCutCtx.inputSrv.tab.length = true
kernel_rfl EOSCutCtxLen.prefixGrow : Nat.ble EOSCutCtxLen.S0.tab.length EOSCutCtxLen.preSrv.tab.length = true
kernel_rfl EOSCutCtxLen.stepGrow : Nat.ble EOSCutCtxLen.preSrv.tab.length EOSCutCtxLen.S1.tab.length = true
end Host.Load.Run.Tpl

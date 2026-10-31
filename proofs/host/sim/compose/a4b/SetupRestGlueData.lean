import host.sim.compose.a4b.SetupChunkStage
import host.sim.template.a4pre_setup_early_r0.Run
import host.sim.template.a4pre_setup_early_r0.Bridge

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupRest
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Run.Tpl

def restFuel : Nat := (PRE_setup_early_r0.ks.drop 6).sum
kernel_rfl fuels : PRE_setup_early_r0.ks = [897, 1, 1, 1, 0, 0, 1018, 1, 1, 24, 1, 1, 351, 1, 1, 8]
kernel_rfl restFuel_exact : restFuel = 1407
kernel_rfl sourceNext : PRE_setup_early_r0.s16.next = 2673457
kernel_rfl sourceCounters : ((mlxOf PRE_setup_early_r0.s16.ffi).next,
  (mlxOf PRE_setup_early_r0.s16.ffi).nnext) = (18155, 15235)
kernel_rfl table12 : PRE_setup_early_r0.S12.tab =
  [.var 0, .var 1, .var 2, .var 3, .var 4, .var 5, .var 6, .var 7, .var 8, .var 9, .var 9, .var 9]
kernel_rfl table16 : PRE_setup_early_r0.S16.tab =
  [.var 0, .var 1, .var 2, .var 3, .var 4, .var 5, .var 6, .var 7, .var 8, .var 9,
    .var 9, .var 9, .bin .add (.var 9) (.var 0), .var 9]
kernel_rfl nextCall : isCallOf PRE_setup_early_r0.s16 "nextPrefillStep" none = true

theorem inactive6 : (bridgeOf PRE_setup_early_r0.s6.ffi).active = false := by
  rw [Host.Ts.Sim.Compose.SetupChunk.bridge6, Host.Ts.Sim.Compose.SetupEarly.bridge4,
    PRE_setup_early_r0.start_eq]
  exact Host.Load.Run.Prompt.ldStT_bridge [] []

kernel_rfl oracle6 : Host.Ts.Sim.Lin.goodLin Host.Ts.Sim.Lin.Cls.setup_early.r0.ps
  (Host.Ts.Sim.Lin.Cls.varsOf Host.Ts.Sim.Lin.Cls.setup_early.r0.V [(9, .L)])
  PRE_setup_early_r0.S6.oracle = true

kernel_rfl oracle8 : Host.Ts.Sim.Lin.goodLin Host.Ts.Sim.Lin.Cls.setup_early.r0.ps
  (Host.Ts.Sim.Lin.Cls.varsOf Host.Ts.Sim.Lin.Cls.setup_early.r0.V [(9, .L)])
  PRE_setup_early_r0.S8.oracle = true

kernel_rfl oracle9 : Host.Ts.Sim.Lin.goodLin Host.Ts.Sim.Lin.Cls.setup_early.r0.ps
  (Host.Ts.Sim.Lin.Cls.varsOf Host.Ts.Sim.Lin.Cls.setup_early.r0.V [(9, .L)])
  PRE_setup_early_r0.S9.oracle = true

kernel_rfl oracle11 : Host.Ts.Sim.Lin.goodLin Host.Ts.Sim.Lin.Cls.setup_early.r0.ps
  (Host.Ts.Sim.Lin.Cls.varsOf Host.Ts.Sim.Lin.Cls.setup_early.r0.V [(9, .L)])
  PRE_setup_early_r0.S11.oracle = true

kernel_rfl oracle12 : Host.Ts.Sim.Lin.goodLin Host.Ts.Sim.Lin.Cls.setup_early.r0.ps
  (Host.Ts.Sim.Lin.Cls.varsOf Host.Ts.Sim.Lin.Cls.setup_early.r0.V [(9, .L)])
  PRE_setup_early_r0.S12.oracle = true

kernel_rfl oracle14 : Host.Ts.Sim.Lin.goodLin Host.Ts.Sim.Lin.Cls.setup_early.r0.ps
  (Host.Ts.Sim.Lin.Cls.varsOf Host.Ts.Sim.Lin.Cls.setup_early.r0.V [(9, .L)])
  PRE_setup_early_r0.S14.oracle = true

kernel_rfl oracle15 : Host.Ts.Sim.Lin.goodLin Host.Ts.Sim.Lin.Cls.setup_early.r0.ps
  (Host.Ts.Sim.Lin.Cls.varsOf Host.Ts.Sim.Lin.Cls.setup_early.r0.V [(9, .L)])
  PRE_setup_early_r0.S15.oracle = true

kernel_rfl bridge8 : bridgeOf PRE_setup_early_r0.s8.ffi = bridgeOf PRE_setup_early_r0.s6.ffi

kernel_rfl bridge9 : bridgeOf PRE_setup_early_r0.s9.ffi = bridgeOf PRE_setup_early_r0.s6.ffi

kernel_rfl bridge11 : bridgeOf PRE_setup_early_r0.s11.ffi = bridgeOf PRE_setup_early_r0.s6.ffi

kernel_rfl bridge12 : bridgeOf PRE_setup_early_r0.s12.ffi = bridgeOf PRE_setup_early_r0.s6.ffi

kernel_rfl bridge14 : bridgeOf PRE_setup_early_r0.s14.ffi = bridgeOf PRE_setup_early_r0.s6.ffi

kernel_rfl bridge15 : bridgeOf PRE_setup_early_r0.s15.ffi = bridgeOf PRE_setup_early_r0.s6.ffi

kernel_rfl bridge16 : bridgeOf PRE_setup_early_r0.s16.ffi = bridgeOf PRE_setup_early_r0.s6.ffi

kernel_rfl unhalted7 : isHalt PRE_setup_early_r0.s7.ctl = false

kernel_rfl unhalted10 : isHalt PRE_setup_early_r0.s10.ctl = false

kernel_rfl unhalted13 : isHalt PRE_setup_early_r0.s13.ctl = false

kernel_rfl top8 : noRetBlock PRE_setup_early_r0.s8 = true

kernel_rfl top11 : noRetBlock PRE_setup_early_r0.s11 = true

kernel_rfl top14 : noRetBlock PRE_setup_early_r0.s14 = true

kernel_rfl top16 : noRetBlock PRE_setup_early_r0.s16 = true

kernel_rfl stack8 : PRE_setup_early_r0.s8.stack =
  .e (.member kLength false) :: PRE_setup_early_r0.s8.stack.tail
kernel_rfl prompt8 : arrOf PRE_setup_early_r0.s8 2665 = []

kernel_rfl stack11 : PRE_setup_early_r0.s11.stack =
  .e (.member kLength false) :: PRE_setup_early_r0.s11.stack.tail
kernel_rfl prompt11 : arrOf PRE_setup_early_r0.s11 2665 = []

kernel_rfl stack14 : PRE_setup_early_r0.s14.stack =
  .e (.member kLength false) :: PRE_setup_early_r0.s14.stack.tail
kernel_rfl prompt14 : arrOf PRE_setup_early_r0.s14 2665 = []

kernel_rfl accepted6 : PRE_setup_early_r0.okB2 PRE_setup_early_r0.s6 PRE_setup_early_r0.S6 = true

kernel_rfl accepted9 : PRE_setup_early_r0.okB2 PRE_setup_early_r0.s9 PRE_setup_early_r0.S9 = true

kernel_rfl accepted12 : PRE_setup_early_r0.okB2 PRE_setup_early_r0.s12 PRE_setup_early_r0.S12 = true

kernel_rfl accepted15 : PRE_setup_early_r0.okB2 PRE_setup_early_r0.s15 PRE_setup_early_r0.S15 = true

end Host.Ts.Sim.Compose.SetupRest

import host.sim.template.a4pre_d1_dispatch.Check1
import host.sim.compose.a4b.SetupRestGlue
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupD1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Run.Tpl

theorem sourceCall : isCallOf PRE_setup_early_r0.s16 "nextPrefillStep" none = true := SetupRest.nextCall

theorem sourceInactive : (bridgeOf PRE_setup_early_r0.s16.ffi).active = false := by
  rw [SetupRest.bridge16]
  exact SetupRest.inactive6

theorem start32Inactive : (bridgeOf D1Dispatch32.s0.ffi).active = false := by
  rw [D1Dispatch32.start_exact]
  exact sourceInactive

theorem startSliceInactive : (bridgeOf D1BeforeSlice.s0.ffi).active = false := by
  have h1 := congrArg (fun s : St FF.S => bridgeOf s.ffi) D1BeforeSlice.start_exact
  have h2 : bridgeOf D1Dispatch32.s1.ffi = bridgeOf D1Dispatch32.s0.ffi := D1Dispatch32.bridge
  exact (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) (h1.trans h2)).trans start32Inactive

theorem beforeSliceInactive : (bridgeOf D1BeforeSlice.s1.ffi).active = false := by
  exact (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) D1BeforeSlice.bridge).trans startSliceInactive

end Host.Ts.Sim.Compose.SetupD1

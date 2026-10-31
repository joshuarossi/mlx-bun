import host.sim.compose.a4b.SetupCommonBase
import host.sim.template.a4pre_g0b.S0Eq
import host.sim.template.a4pre_first_tail_x15_r0.SharedStart
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupCommon
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route

theorem inactive0 : (bridgeOf PRE_g0b.s0.ffi).active = false := by
  have h0 := congrArg (fun s : St FF.S => (bridgeOf s.ffi).active) PRE_g0b.s0_tok
  have h1 := congrArg (fun s : St FF.S => (bridgeOf s.ffi).active) PRE_g0b.inputRet
  have h2 := congrArg (fun s : St FF.S => (bridgeOf s.ffi).active) PRE_first_tail_x15_r0.chunk0_eq
  have h3 : (bridgeOf PRE_setup_early_r0.s6.ffi).active = false := by
    rw [SetupChunk.bridge6, SetupEarly.bridge4, PRE_setup_early_r0.start_eq]
    exact Host.Load.Run.Prompt.ldStT_bridge [] []
  exact h0.trans (h1.trans (h2.trans h3))

kernel_rfl live1 : isHalt PRE_g0b.s1.ctl = false
kernel_rfl live4 : isHalt PRE_g0b.s4.ctl = false
kernel_rfl live7 : isHalt PRE_g0b.s7.ctl = false
kernel_rfl top2 : noRetBlock PRE_g0b.s2 = true
kernel_rfl top5 : noRetBlock PRE_g0b.s5 = true
kernel_rfl top8 : noRetBlock PRE_g0b.s8 = true
kernel_rfl top10 : noRetBlock PRE_g0b.s10 = true
kernel_rfl stack2 : PRE_g0b.s2.stack = .e (.member kLength false) :: PRE_g0b.s2.stack.tail
kernel_rfl empty2 : arrOf PRE_g0b.s2 2665 = []
kernel_rfl stack5 : PRE_g0b.s5.stack = .e (.member kLength false) :: PRE_g0b.s5.stack.tail
kernel_rfl empty5 : arrOf PRE_g0b.s5 2665 = []
kernel_rfl stack8 : PRE_g0b.s8.stack = .e (.member kLength false) :: PRE_g0b.s8.stack.tail
kernel_rfl empty8 : arrOf PRE_g0b.s8 2665 = []
kernel_rfl bridge2 : bridgeOf PRE_g0b.s2.ffi = bridgeOf PRE_g0b.s0.ffi
kernel_rfl bridge3 : bridgeOf PRE_g0b.s3.ffi = bridgeOf PRE_g0b.s0.ffi
kernel_rfl bridge5 : bridgeOf PRE_g0b.s5.ffi = bridgeOf PRE_g0b.s0.ffi
kernel_rfl bridge6 : bridgeOf PRE_g0b.s6.ffi = bridgeOf PRE_g0b.s0.ffi
kernel_rfl bridge8 : bridgeOf PRE_g0b.s8.ffi = bridgeOf PRE_g0b.s0.ffi
kernel_rfl bridge9 : bridgeOf PRE_g0b.s9.ffi = bridgeOf PRE_g0b.s0.ffi
kernel_rfl bridge10 : bridgeOf PRE_g0b.s10.ffi = bridgeOf PRE_g0b.s0.ffi
kernel_rfl tableLen0 : Nat.blt 10 PRE_g0b.S0.tab.length = true
kernel_rfl tableLen2 : Nat.blt 10 PRE_g0b.S2.tab.length = true
kernel_rfl tableLen3 : Nat.blt 10 PRE_g0b.S3.tab.length = true
kernel_rfl tableLen5 : Nat.blt 10 PRE_g0b.S5.tab.length = true
kernel_rfl tableLen6 : Nat.blt 10 PRE_g0b.S6.tab.length = true
kernel_rfl tableLen8 : Nat.blt 10 PRE_g0b.S8.tab.length = true
kernel_rfl tableLen9 : Nat.blt 10 PRE_g0b.S9.tab.length = true
end Host.Ts.Sim.Compose.SetupCommon

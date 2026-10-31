import host.sim.template.a4pre_post_head.S0State
import host.sim.template.a4pre_post_head.S0Table
import host.sim.template.a4pre_post_head.S0Tokens
import host.sim.full.StateFields
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Load
state_fields PRE_post_head.newFields from PRE_post_head.s0
state_fields PRE_post_head.oldFields from D1Body.s155
kernel_rfl PRE_post_head.new_bridge : PRE_post_head.newFields.bridge = Boot.replay Host.Load.Run.Prompt.P.oblog2818
kernel_rfl PRE_post_head.old_bridge : PRE_post_head.oldFields.bridge = PRENative32.s0.ffi.1.1.bridge
kernel_rfl PRE_post_head.s0_load : PRE_post_head.newFields.load =
  { PRE_post_head.oldFields.load with mlx := { PRE_post_head.oldFields.load.mlx with tokens := [.ref 1, .ref 2] } }
kernel_rfl PRE_post_head.s0_live : PRE_post_head.newFields.live = PRE_post_head.oldFields.live
kernel_rfl PRE_post_head.s0_krec : PRE_post_head.newFields.krec = PRE_post_head.oldFields.krec
theorem PRE_post_head.s0_tok : PRE_post_head.s0 = D1Body.s155.setFfi
    (Full.fullSetTokens D1Body.s155.ffi [.ref 1, .ref 2]) :=
  Full.start_of_fields PRE_post_head.newFields.ffi_eq PRE_post_head.oldFields.ffi_eq PRE_post_head.s0_noFfi
    PRE_post_head.s0_load
    (PRE_post_head.new_bridge.trans (PRENative32.bridge_exact.trans PRE_post_head.old_bridge.symm))
    PRE_post_head.s0_live PRE_post_head.s0_krec
end Host.Load.Run.Tpl

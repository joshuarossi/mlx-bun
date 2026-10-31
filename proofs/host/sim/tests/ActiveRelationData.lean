import host.sim.full.StateFields
import host.sim.full.BridgeStep
import host.sim.template.a4pre_setup_early_r0.Start
import host.sim.template.a4pre_setup_native32.BridgeOrigin
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # The data of the active relation's check

The boot's state at `loadDone` as a field view of its stored literal (`PRE_setup_early_r0.start_eq`), the
program's first wrap (surface 0, one dimension, dtype 9) and the checks of that wrap. -/

namespace Host.Ts.Sim.Full.ActiveRelation
open Host.Ts Host.Ts.Sim

def P0 : LoadP := ⟨18151, 131072, 2 ^ 40, 15235, 15235, []⟩

state_fields V from _root_.Host.Load.Run.Tpl.PRE_setup_early_r0.s0

noncomputable def bridgeLit : Host.Mlx.FfiAne.St := _root_.Host.Load.Run.Tpl.PRENative32.s0.ffi.1.1.bridge

def args : List Arg :=
  [.num (.lit (F64.ofNat 35184372088832)), .jsPtr 0 0 [.lit 0, .lit 0, .lit 8, .lit 2],
    .num (.lit (F64.ofNat 1)), .num (.lit (F64.ofNat 9)), .num (.lit (F64.ofNat 0)), .num (.lit (F64.ofNat 4096))]

kernel_rfl bridge_view : V.bridge = _root_.Host.Load.Boot.replay _root_.Host.Load.Run.Prompt.P.oblog2818
theorem bridge_lit : V.bridge = bridgeLit := bridge_view.trans _root_.Host.Load.Run.Tpl.PRENative32.bridge_exact

kernel_rfl clean_lit : bridgeClean bridgeLit = true
kernel_rfl wrap_ok : wrapOk P0 V.load.mlx args = true
kernel_rfl wrap_some : (Host.Mlx.FfiAne.wrap bridgeLit V.load.mlx args).isSome = true
kernel_rfl is_mlx : _root_.Host.Load.isMlx Host.Mlx.FfiAne.payloadName = true
kernel_rfl is_wrap : nameEq Host.Mlx.FfiAne.payloadName Host.Mlx.FfiAne.payloadName = true
kernel_rfl no_sym : Host.Mlx.Ffi.symOf Host.Mlx.FfiAne.payloadName = none

end Host.Ts.Sim.Full.ActiveRelation

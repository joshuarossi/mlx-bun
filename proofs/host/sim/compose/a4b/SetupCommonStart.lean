import host.sim.compose.a4b.SetupCommonBase
import host.sim.template.a4pre_g0b.S0Eq
import host.sim.template.a4pre_first_tail_x15_r0.SharedStart
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupCommon
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route

theorem fullSetTokens_self (x : FF.S) : fullSetTokens x (mlxOf x).tokens = x := rfl
kernel_rfl tokens6 : (mlxOf PRE_setup_early_r0.s6.ffi).tokens = [.ref 1, .ref 2]

theorem startState
    (hq : PRE_g0b.s0 = PRE_g0b.rawInput.setFfi (fullSetTokens PRE_g0b.rawInput.ffi [.ref 1, .ref 2])) :
    PRE_g0b.s0 = PRE_setup_early_r0.s6.ret (.num (.ref PRE_setup_early_r0.S6.tab.length)) := by
  let u : St FF.S := PRE_setup_early_r0.s6.ret (.num (.ref 10))
  have hn : PRE_setup_early_r0.S6.tab.length = 10 := by rw [SetupChunk.canonicalTable]; rfl
  rw [hn]
  change PRE_g0b.s0 = u
  have hu : (mlxOf u.ffi).tokens = [.ref 1, .ref 2] := tokens6
  have hf : fullSetTokens u.ffi [.ref 1, .ref 2] = u.ffi :=
    (congrArg (fullSetTokens u.ffi) hu.symm).trans (fullSetTokens_self u.ffi)
  have hi : (PRE_g0b.rawInput : St FF.S) = u :=
    (show (PRE_g0b.rawInput : St FF.S) = PRE_first_tail_x15_r0.s6.ret (.num (.ref 10)) from
      PRE_g0b.inputRet).trans (congrArg (fun z : St FF.S => z.ret (.num (.ref 10)))
        PRE_first_tail_x15_r0.chunk0_eq)
  have hq' : (PRE_g0b.s0 : St FF.S) =
      PRE_g0b.rawInput.setFfi (fullSetTokens PRE_g0b.rawInput.ffi [.ref 1, .ref 2]) := hq
  have hs : (PRE_g0b.s0 : St FF.S) = u.setFfi (fullSetTokens u.ffi [.ref 1, .ref 2]) :=
    hq'.trans (congrArg (fun z : St FF.S => z.setFfi (fullSetTokens z.ffi [.ref 1, .ref 2])) hi)
  exact hs.trans ((congrArg (fun z : FF.S => u.setFfi z) hf).trans (by cases u; rfl))

theorem start_eq :
    PRE_g0b.s0 = PRE_setup_early_r0.s6.ret (.num (.ref PRE_setup_early_r0.S6.tab.length)) :=
  startState PRE_g0b.s0_tok

kernel_rfl startTable : PRE_g0b.S0.tab = PRE_setup_early_r0.S6.tab ++ [.var 10]
end Host.Ts.Sim.Compose.SetupCommon

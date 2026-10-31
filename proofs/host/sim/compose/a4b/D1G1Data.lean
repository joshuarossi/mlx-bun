import host.sim.compose.a4b.D1PreSliceFacts
import host.sim.compose.a4b.D1PtrData
import host.sim.compose.a4b.D1LengthData
import host.sim.compose.a4b.D1TypedGlueB
import host.sim.compose.a4b.D1NewDataStep

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

kernel_rfl accepted4 : D1StageSplit.okB2 D1StageSplit.s4 D1StageSplit.S4 = true
kernel_rfl accepted5 : D1StageSplit.okB2 D1StageSplit.s5 D1StageSplit.S5 = true
kernel_rfl live5 : isHalt D1StageSplit.s5.ctl = false
kernel_rfl top6 : noRetBlock D1StageSplit.s6 = true
kernel_rfl accepted7 : D1StageSplit.okB3 D1StageSplit.s7 D1StageSplit.S7 = true
kernel_rfl accepted8 : D1StageSplit.okB3 D1StageSplit.s8 D1StageSplit.S8 = true
kernel_rfl live8 : isHalt D1StageSplit.s8.ctl = false
kernel_rfl top9 : noRetBlock D1StageSplit.s9 = true
kernel_rfl live11 : isHalt D1StageSplit.s11.ctl = false
kernel_rfl live14 : isHalt D1StageSplit.s14.ctl = false
kernel_rfl live17 : isHalt D1StageSplit.s17.ctl = false
kernel_rfl top12 : noRetBlock D1StageSplit.s12 = true
kernel_rfl top15 : noRetBlock D1StageSplit.s15 = true
kernel_rfl top18 : noRetBlock D1StageSplit.s18 = true

noncomputable def g1Oracle : List Ans :=
  D1StageSplit.S1.oracle ++ D1StageSplit.S4.oracle ++ D1StageSplit.S7.oracle ++
  D1StageSplit.S10.oracle ++ D1StageSplit.S13.oracle ++ D1StageSplit.S15.oracle ++
  D1StageSplit.S16.oracle ++ D1StageSplit.S19.oracle

kernel_rfl g1Check : goodLin final_cold.r0.ps (varsOf final_cold.r0.V D1StageSplit.map_g1_FIN_first)
  g1Oracle = true

structure G1Good (ν : Nat → F64) : Prop where
  s1 : Good ν D1StageSplit.S1.oracle
  s4 : Good ν D1StageSplit.S4.oracle
  s7 : Good ν D1StageSplit.S7.oracle
  s10 : Good ν D1StageSplit.S10.oracle
  s13 : Good ν D1StageSplit.S13.oracle
  s15 : Good ν D1StageSplit.S15.oracle
  s16 : Good ν D1StageSplit.S16.oracle
  s19 : Good ν D1StageSplit.S19.oracle

theorem G1Good.ofGood {ν : Nat → F64} (h : Good ν g1Oracle) : G1Good ν := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    intro q hq <;> exact h q (by simp [g1Oracle, hq])

end Host.Ts.Sim.Compose.D1Split

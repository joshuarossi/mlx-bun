import host.sim.compose.a4b.x4_L7.PtrData
import host.sim.compose.a4b.x4_L7.LengthData
import host.sim.compose.a4b.x4_L7.TypedGlue
import host.sim.compose.a4b.x4_L7.NewDataStep
import host.sim.template.a4pre_first_tail_x4_L7_r0.K4
import host.sim.template.a4pre_d1_dispatch.Advance
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

def npsMap : List (Nat × Q) := [(9, .L), (1087, .n), (1008, .n)]

kernel_rfl accepted19 : PRE_first_tail_x4_L7_r0.okB6 PRE_first_tail_x4_L7_r0.s19 PRE_first_tail_x4_L7_r0.S19 = true
kernel_rfl accepted20 : PRE_first_tail_x4_L7_r0.okB6 PRE_first_tail_x4_L7_r0.s20 PRE_first_tail_x4_L7_r0.S20 = true
kernel_rfl accepted22 : PRE_first_tail_x4_L7_r0.okB7 PRE_first_tail_x4_L7_r0.s22 PRE_first_tail_x4_L7_r0.S22 = true
kernel_rfl accepted23 : PRE_first_tail_x4_L7_r0.okB7 PRE_first_tail_x4_L7_r0.s23 PRE_first_tail_x4_L7_r0.S23 = true
kernel_rfl accepted25 : PRE_first_tail_x4_L7_r0.okB8 PRE_first_tail_x4_L7_r0.s25 PRE_first_tail_x4_L7_r0.S25 = true
kernel_rfl accepted26 : PRE_first_tail_x4_L7_r0.okB8 PRE_first_tail_x4_L7_r0.s26 PRE_first_tail_x4_L7_r0.S26 = true
kernel_rfl live20 : isHalt PRE_first_tail_x4_L7_r0.s20.ctl = false
kernel_rfl live23 : isHalt PRE_first_tail_x4_L7_r0.s23.ctl = false
kernel_rfl live26 : isHalt PRE_first_tail_x4_L7_r0.s26.ctl = false
kernel_rfl live29 : isHalt PRE_first_tail_x4_L7_r0.s29.ctl = false
kernel_rfl live32 : isHalt PRE_first_tail_x4_L7_r0.s32.ctl = false
kernel_rfl live35 : isHalt PRE_first_tail_x4_L7_r0.s35.ctl = false
kernel_rfl top21 : noRetBlock PRE_first_tail_x4_L7_r0.s21 = true
kernel_rfl top24 : noRetBlock PRE_first_tail_x4_L7_r0.s24 = true
kernel_rfl top27 : noRetBlock PRE_first_tail_x4_L7_r0.s27 = true
kernel_rfl top30 : noRetBlock PRE_first_tail_x4_L7_r0.s30 = true
kernel_rfl top33 : noRetBlock PRE_first_tail_x4_L7_r0.s33 = true
kernel_rfl top36 : noRetBlock PRE_first_tail_x4_L7_r0.s36 = true

noncomputable def g1Oracle : List Ans :=
  PRE_first_tail_x4_L7_r0.S19.oracle ++ PRE_first_tail_x4_L7_r0.S22.oracle ++ PRE_first_tail_x4_L7_r0.S25.oracle ++ PRE_first_tail_x4_L7_r0.S28.oracle ++ PRE_first_tail_x4_L7_r0.S31.oracle ++ PRE_first_tail_x4_L7_r0.S33.oracle ++ PRE_first_tail_x4_L7_r0.S34.oracle ++ PRE_first_tail_x4_L7_r0.S37.oracle

kernel_rfl g1Check : ([first_tail_x4.r0].all fun r => goodLin r.ps
  (varsOf r.V npsMap) g1Oracle) = true

structure G1Good (ν : Nat → F64) : Prop where
  s19 : Good ν PRE_first_tail_x4_L7_r0.S19.oracle
  s22 : Good ν PRE_first_tail_x4_L7_r0.S22.oracle
  s25 : Good ν PRE_first_tail_x4_L7_r0.S25.oracle
  s28 : Good ν PRE_first_tail_x4_L7_r0.S28.oracle
  s31 : Good ν PRE_first_tail_x4_L7_r0.S31.oracle
  s33 : Good ν PRE_first_tail_x4_L7_r0.S33.oracle
  s34 : Good ν PRE_first_tail_x4_L7_r0.S34.oracle
  s37 : Good ν PRE_first_tail_x4_L7_r0.S37.oracle

theorem G1Good.ofGood {ν : Nat → F64} (h : Good ν g1Oracle) : G1Good ν := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    intro q hq <;> exact h q (by simp [g1Oracle, hq])

end Host.Ts.Sim.Compose.VWFirst.X4_L7

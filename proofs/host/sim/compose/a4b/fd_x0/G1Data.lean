import host.sim.compose.a4b.fd_x0.PtrData
import host.sim.compose.a4b.fd_x0.LengthData
import host.sim.compose.a4b.fd_x0.TypedGlue
import host.sim.compose.a4b.fd_x0.NewDataStep
import host.sim.template.a4pre_fd_x0_r0.K0
import host.sim.template.a4pre_fd_x0_r0.K1
import host.sim.template.a4pre_fd_x0_r0.K2
import host.sim.template.a4pre_fd_x0_r0.K3
import host.sim.template.a4pre_fd_x0_r0.K4
import host.sim.template.a4pre_fd_x0_r0.K5
import host.sim.template.a4pre_d1_dispatch.Advance
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDX0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

def fdMap : List (Nat × Q) := [(9, .L), (10, .o), (11, .o), (16, .cap)]

/-- What the final step's row says of a prompt's length. -/
theorem rowFacts {i : Cls.Inst} (hi : InRow final_ord.r0 i) :
    2 ≤ i.L ∧ i.L ≤ 2 ^ 19 ∧ i.o = i.L - 1 ∧ i.cap = capL (i.L - 1) := by
  obtain ⟨_, x, hx, hq⟩ := hi
  simp only [final_ord.r0, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
  unfold capL
  omega

kernel_rfl accepted2 : PRE_fd_x0_r0.okB1 PRE_fd_x0_r0.s2 PRE_fd_x0_r0.S2 = true
kernel_rfl accepted3 : PRE_fd_x0_r0.okB1 PRE_fd_x0_r0.s3 PRE_fd_x0_r0.S3 = true
kernel_rfl accepted5 : PRE_fd_x0_r0.okB2 PRE_fd_x0_r0.s5 PRE_fd_x0_r0.S5 = true
kernel_rfl accepted6 : PRE_fd_x0_r0.okB2 PRE_fd_x0_r0.s6 PRE_fd_x0_r0.S6 = true
kernel_rfl accepted8 : PRE_fd_x0_r0.okB3 PRE_fd_x0_r0.s8 PRE_fd_x0_r0.S8 = true
kernel_rfl accepted9 : PRE_fd_x0_r0.okB3 PRE_fd_x0_r0.s9 PRE_fd_x0_r0.S9 = true
kernel_rfl live3 : isHalt PRE_fd_x0_r0.s3.ctl = false
kernel_rfl live6 : isHalt PRE_fd_x0_r0.s6.ctl = false
kernel_rfl live9 : isHalt PRE_fd_x0_r0.s9.ctl = false
kernel_rfl live12 : isHalt PRE_fd_x0_r0.s12.ctl = false
kernel_rfl live15 : isHalt PRE_fd_x0_r0.s15.ctl = false
kernel_rfl live18 : isHalt PRE_fd_x0_r0.s18.ctl = false
kernel_rfl top4 : noRetBlock PRE_fd_x0_r0.s4 = true
kernel_rfl top7 : noRetBlock PRE_fd_x0_r0.s7 = true
kernel_rfl top10 : noRetBlock PRE_fd_x0_r0.s10 = true
kernel_rfl top13 : noRetBlock PRE_fd_x0_r0.s13 = true
kernel_rfl top16 : noRetBlock PRE_fd_x0_r0.s16 = true
kernel_rfl top19 : noRetBlock PRE_fd_x0_r0.s19 = true

noncomputable def g1Oracle : List Ans :=
  PRE_fd_x0_r0.S2.oracle ++ PRE_fd_x0_r0.S5.oracle ++ PRE_fd_x0_r0.S8.oracle ++ PRE_fd_x0_r0.S11.oracle ++ PRE_fd_x0_r0.S14.oracle ++ PRE_fd_x0_r0.S16.oracle ++ PRE_fd_x0_r0.S17.oracle ++ PRE_fd_x0_r0.S20.oracle

kernel_rfl g1Check : ([final_ord.r0].all fun r => goodLin r.ps
  (varsOf r.V fdMap) g1Oracle) = true

structure G1Good (ν : Nat → F64) : Prop where
  s19 : Good ν PRE_fd_x0_r0.S2.oracle
  s22 : Good ν PRE_fd_x0_r0.S5.oracle
  s25 : Good ν PRE_fd_x0_r0.S8.oracle
  s28 : Good ν PRE_fd_x0_r0.S11.oracle
  s31 : Good ν PRE_fd_x0_r0.S14.oracle
  s33 : Good ν PRE_fd_x0_r0.S16.oracle
  s34 : Good ν PRE_fd_x0_r0.S17.oracle
  s37 : Good ν PRE_fd_x0_r0.S20.oracle

theorem G1Good.ofGood {ν : Nat → F64} (h : Good ν g1Oracle) : G1Good ν := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    intro q hq <;> exact h q (by simp [g1Oracle, hq])

end Host.Ts.Sim.Compose.FDX0

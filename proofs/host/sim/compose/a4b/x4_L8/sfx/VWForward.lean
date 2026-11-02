import host.sim.compose.a4b.x4_L8.VWBodyFold
import host.sim.compose.a4b.x4_L8.sfx.VWBodyChain
import host.sim.template.a4pre_first_tail_x4_L8_r0_suffix.m.B3
import host.sim.compose.a4b.VWFirstRows
import host.sim.compose.a4b.VWBodyEntry
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8.Sfx
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- This chain's start: the forward's return. -/
noncomputable def startCore (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (i : Cls.Inst) : ICut FF :=
  bodyCore NB T tk π i bodyΘ ⟨64866, 1253, 0, 0⟩ Host.Ts.Sim.Compose.VWFirst.X4_L8.bodyM PRE_first_tail_x4_L8_r0_suffix.s0 PRE_first_tail_x4_L8_r0_suffix.S0

kernel_rfl bodyEndJv : Host.Ts.Sim.Compose.VWFirst.X4_L8.bodyΘ.1.take Host.Ts.Sim.Compose.VWFirst.X4_L8.bodyJEnd = Host.Ts.Sim.Compose.VWFirst.X4_L8.bodyΘ.1
kernel_rfl bodyEndJe : Host.Ts.Sim.Compose.VWFirst.X4_L8.bodyΘ.2.take Host.Ts.Sim.Compose.VWFirst.X4_L8.bodyJEnd = Host.Ts.Sim.Compose.VWFirst.X4_L8.bodyΘ.2

theorem endTabEq : PRE_first_tail_x4_L8_r0_body.S1427.tab.map (·.subst (Conv.compactθ Host.Ts.Sim.Compose.VWFirst.X4_L8.bodyΘ.1 Host.Ts.Sim.Compose.VWFirst.X4_L8.bodyΘ.2)) = PRE_first_tail_x4_L8_r0_suffix.S0.tab :=
  PRE_first_tail_x4_L8_r0_body.endTab.trans PRE_first_tail_x4_L8_r0_suffix.s0_tab.symm

/-- **The forward from every start**, with what its end knows about it. -/
theorem forwardAll (NB T : Nat) (tk : Nat → Nat) (π : List Nat) {r : Row} {i : Cls.Inst}
    (hr : r ∈ Host.Ts.Sim.Compose.VWFirst.X4_L8.fwdRows) (hi : InRow r i) (hn : i.n ≤ 2 ^ 20) (x0 : SegInst FF) :
    CutStep (withMem (BodyTrail x0) (forwardCut NB T tk π i)) (withMem (BodyTrail x0) (startCore NB T tk π i))
      (0 + Host.Ts.Sim.Compose.VWFirst.X4_L8.bodyN) :=
  (FwdCall.warm ((toBody Host.Ts.Sim.Compose.VWFirst.X4_L8.bodyStartEq PRE_first_tail_x4_L8_r0_body.s0_tab hr hi hn).trans (Host.Ts.Sim.Compose.VWFirst.X4_L8.bodyEnter hn))
    (Host.Ts.Sim.Compose.VWFirst.X4_L8.bodyAll NB T tk π x0 hr hi)
    (endConv (vs := Host.Ts.Sim.Compose.VWFirst.X4_L8.bodyΘ.1) (es := Host.Ts.Sim.Compose.VWFirst.X4_L8.bodyΘ.2) bodyEndJv bodyEndJe bodyStartEq endTabEq (fun _ h => h))).step

end Host.Ts.Sim.Compose.VWFirst.X4_L8.Sfx

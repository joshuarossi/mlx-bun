import host.sim.compose.a4b.x0.B0
import host.sim.compose.a4b.VWBodyEntry
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

abbrev bodyN : Nat := 1541184
abbrev bodyJEnd : Nat := 0

/-- **The forward's flat body**, in 1541184 steps. -/
theorem bodyAll (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨3571, 0, 0, 0⟩ bodyM PRE_first_tail_x0_r0_body.s0 PRE_first_tail_x0_r0_body.S0)
      (bodyCut NB T tk π i x0 bodyΘ ⟨3571, 0, 0, 0⟩ bodyM PRE_first_tail_x0_r0_body.s906 PRE_first_tail_x0_r0_body.S906) bodyN :=
  ((bodyGlue0 NB T tk π x0 hr hi)).cast rfl rfl rfl

/-- The forward's start: the chain reads only the prompt's length. -/
theorem bodyEnter {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {x0 : SegInst FF} (hn : i.n ≤ 2 ^ 20) :
    CutConv (withMem (BodyTrail x0) (bodyStartCut NB T tk π i PRE_first_tail_x0_r0_body.s0 PRE_first_tail_x0_r0_body.S0))
      (bodyCut NB T tk π i x0 bodyΘ ⟨3571, 0, 0, 0⟩ bodyM PRE_first_tail_x0_r0_body.s0 PRE_first_tail_x0_r0_body.S0) :=
  fromStart.trans (by
    rintro x ⟨K0, hr, hb, hnat, hip, hins, hmap, hdf⟩ hB
    exact ⟨x, rfl, rfl, ⟨K0, hr, hb, hnat, hip, hins, MapOk.sub hmap (fun p hp => by
      have e : p = (9, Q.L) := List.mem_singleton.mp hp
      subst e
      simp [bodyMap]), hdf⟩, hB⟩)

end Host.Ts.Sim.Compose.VWFirst.X0

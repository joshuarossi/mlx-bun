import host.sim.compose.a4b.x4_L8.B0
import host.sim.compose.a4b.x4_L8.B1
import host.sim.compose.a4b.x4_L8.B2
import host.sim.compose.a4b.x4_L8.B3
import host.sim.compose.a4b.x4_L8.B4
import host.sim.compose.a4b.x4_L8.B5
import host.sim.compose.a4b.x4_L8.B6
import host.sim.compose.a4b.x4_L8.B7
import host.sim.compose.a4b.x4_L8.B8
import host.sim.compose.a4b.VWBodyEntry
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

abbrev bodyN : Nat := 2208591
abbrev bodyJEnd : Nat := 0

/-- **The forward's flat body**, in 2208591 steps. -/
theorem bodyAll (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨3571, 0, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S0)
      (bodyCut NB T tk π i x0 bodyΘ ⟨64866, 1253, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1427 PRE_first_tail_x4_L8_r0_body.S1427) bodyN :=
  ((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((bodyGlue0 NB T tk π x0 hr hi)).trans (bodyStep0 NB T tk π x0 hr hi)).trans (bodyGlue1 NB T tk π x0 hr hi)).trans (bodyStep1 NB T tk π x0 hr hi)).trans (bodyGlue2 NB T tk π x0 hr hi)).trans (bodyStep2 NB T tk π x0 hr hi)).trans (bodyGlue3 NB T tk π x0 hr hi)).trans (bodyStep3 NB T tk π x0 hr hi)).trans (bodyGlue4 NB T tk π x0 hr hi)).trans (bodyStep4 NB T tk π x0 hr hi)).trans (bodyGlue5 NB T tk π x0 hr hi)).trans (bodyStep5 NB T tk π x0 hr hi)).trans (bodyGlue6 NB T tk π x0 hr hi)).trans (bodyStep6 NB T tk π x0 hr hi)).trans (bodyGlue7 NB T tk π x0 hr hi)).trans (bodyStep7 NB T tk π x0 hr hi)).trans (bodyGlue8 NB T tk π x0 hr hi)).trans (bodyStep8 NB T tk π x0 hr hi)).trans (bodyGlue9 NB T tk π x0 hr hi)).trans (bodyStep9 NB T tk π x0 hr hi)).trans (bodyGlue10 NB T tk π x0 hr hi)).trans (bodyStep10 NB T tk π x0 hr hi)).trans (bodyGlue11 NB T tk π x0 hr hi)).trans (bodyStep11 NB T tk π x0 hr hi)).trans (bodyGlue12 NB T tk π x0 hr hi)).trans (bodyStep12 NB T tk π x0 hr hi)).trans (bodyGlue13 NB T tk π x0 hr hi)).trans (bodyStep13 NB T tk π x0 hr hi)).trans (bodyGlue14 NB T tk π x0 hr hi)).trans (bodyStep14 NB T tk π x0 hr hi)).trans (bodyGlue15 NB T tk π x0 hr hi)).trans (bodyStep15 NB T tk π x0 hr hi)).trans (bodyGlue16 NB T tk π x0 hr hi)).trans (bodyStep16 NB T tk π x0 hr hi)).trans (bodyGlue17 NB T tk π x0 hr hi)).trans (bodyStep17 NB T tk π x0 hr hi)).trans (bodyGlue18 NB T tk π x0 hr hi)).trans (bodyStep18 NB T tk π x0 hr hi)).trans (bodyGlue19 NB T tk π x0 hr hi)).trans (bodyStep19 NB T tk π x0 hr hi)).trans (bodyGlue20 NB T tk π x0 hr hi)).trans (bodyStep20 NB T tk π x0 hr hi)).trans (bodyGlue21 NB T tk π x0 hr hi)).trans (bodyStep21 NB T tk π x0 hr hi)).trans (bodyGlue22 NB T tk π x0 hr hi)).trans (bodyStep22 NB T tk π x0 hr hi)).trans (bodyGlue23 NB T tk π x0 hr hi)).trans (bodyStep23 NB T tk π x0 hr hi)).trans (bodyGlue24 NB T tk π x0 hr hi)).trans (bodyStep24 NB T tk π x0 hr hi)).trans (bodyGlue25 NB T tk π x0 hr hi)).trans (bodyStep25 NB T tk π x0 hr hi)).trans (bodyGlue26 NB T tk π x0 hr hi)).trans (bodyStep26 NB T tk π x0 hr hi)).trans (bodyGlue27 NB T tk π x0 hr hi)).trans (bodyStep27 NB T tk π x0 hr hi)).trans (bodyGlue28 NB T tk π x0 hr hi)).trans (bodyStep28 NB T tk π x0 hr hi)).trans (bodyGlue29 NB T tk π x0 hr hi)).trans (bodyStep29 NB T tk π x0 hr hi)).trans (bodyGlue30 NB T tk π x0 hr hi)).trans (bodyStep30 NB T tk π x0 hr hi)).trans (bodyGlue31 NB T tk π x0 hr hi)).trans (bodyStep31 NB T tk π x0 hr hi)).trans (bodyGlue32 NB T tk π x0 hr hi)).trans (bodyStep32 NB T tk π x0 hr hi)).trans (bodyGlue33 NB T tk π x0 hr hi)).trans (bodyStep33 NB T tk π x0 hr hi)).trans (bodyGlue34 NB T tk π x0 hr hi)).trans (bodyStep34 NB T tk π x0 hr hi)).trans (bodyGlue35 NB T tk π x0 hr hi)).trans (bodyStep35 NB T tk π x0 hr hi)).trans (bodyGlue36 NB T tk π x0 hr hi)).trans (bodyStep36 NB T tk π x0 hr hi)).trans (bodyGlue37 NB T tk π x0 hr hi)).trans (bodyStep37 NB T tk π x0 hr hi)).trans (bodyGlue38 NB T tk π x0 hr hi)).trans (bodyStep38 NB T tk π x0 hr hi)).trans (bodyGlue39 NB T tk π x0 hr hi)).trans (bodyStep39 NB T tk π x0 hr hi)).trans (bodyGlue40 NB T tk π x0 hr hi)).trans (bodyStep40 NB T tk π x0 hr hi)).trans (bodyGlue41 NB T tk π x0 hr hi)).trans (bodyStep41 NB T tk π x0 hr hi)).trans (bodyGlue42 NB T tk π x0 hr hi)).trans (bodyStep42 NB T tk π x0 hr hi)).trans (bodyGlue43 NB T tk π x0 hr hi)).trans (bodyStep43 NB T tk π x0 hr hi)).trans (bodyGlue44 NB T tk π x0 hr hi)).trans (bodyStep44 NB T tk π x0 hr hi)).trans (bodyGlue45 NB T tk π x0 hr hi)).trans (bodyStep45 NB T tk π x0 hr hi)).trans (bodyGlue46 NB T tk π x0 hr hi)).trans (bodyStep46 NB T tk π x0 hr hi)).trans (bodyGlue47 NB T tk π x0 hr hi)).trans (bodyStep47 NB T tk π x0 hr hi)).trans (bodyGlue48 NB T tk π x0 hr hi)).trans (bodyStep48 NB T tk π x0 hr hi)).trans (bodyGlue49 NB T tk π x0 hr hi)).trans (bodyStep49 NB T tk π x0 hr hi)).trans (bodyGlue50 NB T tk π x0 hr hi)).trans (bodyStep50 NB T tk π x0 hr hi)).trans (bodyGlue51 NB T tk π x0 hr hi)).trans (bodyStep51 NB T tk π x0 hr hi)).trans (bodyGlue52 NB T tk π x0 hr hi)).trans (bodyStep52 NB T tk π x0 hr hi)).trans (bodyGlue53 NB T tk π x0 hr hi)).trans (bodyStep53 NB T tk π x0 hr hi)).trans (bodyGlue54 NB T tk π x0 hr hi)).trans (bodyStep54 NB T tk π x0 hr hi)).trans (bodyGlue55 NB T tk π x0 hr hi)).trans (bodyStep55 NB T tk π x0 hr hi)).trans (bodyGlue56 NB T tk π x0 hr hi)).trans (bodyStep56 NB T tk π x0 hr hi)).trans (bodyGlue57 NB T tk π x0 hr hi)).trans (bodyStep57 NB T tk π x0 hr hi)).trans (bodyGlue58 NB T tk π x0 hr hi)).trans (bodyStep58 NB T tk π x0 hr hi)).trans (bodyGlue59 NB T tk π x0 hr hi)).trans (bodyStep59 NB T tk π x0 hr hi)).trans (bodyGlue60 NB T tk π x0 hr hi)).trans (bodyStep60 NB T tk π x0 hr hi)).trans (bodyGlue61 NB T tk π x0 hr hi)).trans (bodyStep61 NB T tk π x0 hr hi)).trans (bodyGlue62 NB T tk π x0 hr hi)).trans (bodyStep62 NB T tk π x0 hr hi)).trans (bodyGlue63 NB T tk π x0 hr hi)).trans (bodyStep63 NB T tk π x0 hr hi)).trans (bodyGlue64 NB T tk π x0 hr hi)).cast rfl rfl rfl

/-- The forward's start: the chain reads only the prompt's length. -/
theorem bodyEnter {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {x0 : SegInst FF} (hn : i.n ≤ 2 ^ 20) :
    CutConv (withMem (BodyTrail x0) (bodyStartCut NB T tk π i PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S0))
      (bodyCut NB T tk π i x0 bodyΘ ⟨3571, 0, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S0) :=
  fromStart.trans (by
    rintro x ⟨K0, hr, hb, hnat, hip, hins, hmap, hdf⟩ hB
    exact ⟨x, rfl, rfl, ⟨K0, hr, hb, hnat, hip, hins, MapOk.sub hmap (fun p hp => by
      have e : p = (9, Q.L) := List.mem_singleton.mp hp
      subst e
      simp [bodyMap]), hdf⟩, hB⟩)

end Host.Ts.Sim.Compose.VWFirst.X4_L8

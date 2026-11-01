import host.sim.compose.a4b.vw8.VWBodyFold
import host.sim.compose.a4b.vw8.sfx.VWBodyChain
import host.sim.template.a4pre_first_tail_x8_r0_suffix.m.B3
import host.sim.compose.a4b.VWFirstRows
import host.sim.compose.a4b.VWBodyEntry
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8.Sfx
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- This chain's start: the forward's return. -/
noncomputable def startCore (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (i : Cls.Inst) : ICut FF :=
  bodyCore NB T tk π i bodyΘ ⟨65874, 1253, 0, 0⟩ bodyMap PRE_first_tail_x8_r0_suffix.s0 PRE_first_tail_x8_r0_suffix.S0

kernel_rfl bodyEndJv : Host.Ts.Sim.Compose.VWFirst.VW8.bodyΘ.1.take Host.Ts.Sim.Compose.VWFirst.VW8.bodyJEnd = Host.Ts.Sim.Compose.VWFirst.VW8.bodyΘ.1
kernel_rfl bodyEndJe : Host.Ts.Sim.Compose.VWFirst.VW8.bodyΘ.2.take Host.Ts.Sim.Compose.VWFirst.VW8.bodyJEnd = Host.Ts.Sim.Compose.VWFirst.VW8.bodyΘ.2

theorem endTabEq : PRE_first_tail_x8_r0_body.S1843.tab.map (·.subst (Conv.compactθ Host.Ts.Sim.Compose.VWFirst.VW8.bodyΘ.1 Host.Ts.Sim.Compose.VWFirst.VW8.bodyΘ.2)) = PRE_first_tail_x8_r0_suffix.S0.tab :=
  PRE_first_tail_x8_r0_body.endTab.trans PRE_first_tail_x8_r0_suffix.s0_tab.symm

/-- **The forward from every start**, with what its end knows about it. -/
theorem forwardAll (NB T : Nat) (tk : Nat → Nat) (π : List Nat) {r : Row} {i : Cls.Inst}
    (hr : r ∈ Host.Ts.Sim.Compose.VWFirst.VW8.fwdRows) (hi : InRow r i) (hn : i.n ≤ 2 ^ 20) (x0 : SegInst FF) :
    CutStep (withMem (BodyTrail x0) (forwardCut NB T tk π i)) (withMem (BodyTrail x0) (startCore NB T tk π i))
      (0 + Host.Ts.Sim.Compose.VWFirst.VW8.bodyN) :=
  (FwdCall.warm ((toBody Host.Ts.Sim.Compose.VWFirst.VW8.bodyStartEq PRE_first_tail_x8_r0_body.s0_tab hn).trans (Host.Ts.Sim.Compose.VWFirst.VW8.bodyEnter hn))
    (Host.Ts.Sim.Compose.VWFirst.VW8.bodyAll NB T tk π x0 hr hi)
    (endConv (vs := Host.Ts.Sim.Compose.VWFirst.VW8.bodyΘ.1) (es := Host.Ts.Sim.Compose.VWFirst.VW8.bodyΘ.2) bodyEndJv bodyEndJe bodyStartEq endTabEq (fun p hp => by
      simp only [bodyMap, List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl <;> simp [Host.Ts.Sim.Compose.VWFirst.VW8.bodyM]))).step

/-- **The first tail's forward** over rows of this body. `hfwd`: the graph, from what the forward's end knows. -/
noncomputable def fwdPiece (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (uses : List Row)
    (hu : ∀ r ∈ uses, r ∈ Host.Ts.Sim.Compose.VWFirst.VW8.fwdRows) (htail : ∀ r ∈ Host.Ts.Sim.Compose.VWFirst.VW8.fwdRows, r ∈ firstTailRows) (obls : List Obl)
    (Mem Mem' : Nat → SegInst FF → Prop)
    (hfwd : ∀ r ∈ uses, ∀ i, InRow r i → ∀ x y, (forwardCut NB T tk π i).R x (forwardCut NB T tk π i).s0
        ⟨(forwardCut NB T tk π i).tab0, []⟩ → (forwardCut NB T tk π i).B x →
      (startCore NB T tk π i).R y (startCore NB T tk π i).s0 ⟨(startCore NB T tk π i).tab0, []⟩ →
      (∀ k, k < bodyN0 → y.M.node k = x.M.node k) → runC FF (0 + Host.Ts.Sim.Compose.VWFirst.VW8.bodyN) x.t x.C = some (y.t, y.C) →
      Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens →
      Mem i.L x → Mem' i.L y) :
    FwdPiece FF uses obls (fun i => withMem (Mem i.L) (forwardCut NB T tk π i))
      (fun i => withMem (Mem' i.L) (startCore NB T tk π i)) where
  m := [(9, .L)]
  np := 0
  nb := 0 + Host.Ts.Sim.Compose.VWFirst.VW8.bodyN
  O := []
  chk _ _ := rfl
  ok r hr i hi _ := by
    obtain ⟨hL, hLmax, hn, _⟩ := firstTailFacts (htail r (hu r hr)) hi
    exact FwdCall.warm (CutConv.refl _)
      (forwardMem (forwardAll NB T tk π (hu r hr) hi (by omega)) (hfwd r hr i hi)) (CutConv.refl _)

end Host.Ts.Sim.Compose.VWFirst.VW8.Sfx

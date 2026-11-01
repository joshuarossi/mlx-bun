import host.sim.compose.a4b.x2.sfx.VWForward
import host.sim.compose.a4b.x2.sfx.VWPfEnd
import host.sim.compose.a4b.x2.sfx.B0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2.Sfx
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- **The first tail from the forward to the pre-final cut.** `hfwd`: the graph, from what the forward's end knows. -/
noncomputable def fwdPf (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap : Nat) (hcap : 67849 ≤ cap) (hbound : cap < Sim.bound)
    (uses : List Row) (hu : ∀ r ∈ uses, r ∈ Host.Ts.Sim.Compose.VWFirst.X2.fwdRows) (htail : ∀ r ∈ Host.Ts.Sim.Compose.VWFirst.X2.fwdRows, r ∈ firstTailRows) (obls : List Obl)
    (Mem Mem' : Nat → SegInst FF → Prop) (hT : ∀ L x y, NTrack x y → Mem' L x → Mem' L y)
    (hfwd : ∀ r ∈ uses, ∀ i, InRow r i → ∀ x y : SegInst FF,
      (startCore NB T tk π i).R y (startCore NB T tk π i).s0 ⟨(startCore NB T tk π i).tab0, []⟩ →
      CSrv.Le x.C y.C → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) →
      (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens → y.M.a 12504 = x.M.a 12504 → Mem i.L x → Mem' i.L y) :
    FwdPiece FF uses obls (fun i => withMem (Mem i.L) (forwardCut NB T tk π i))
      (fun i => withMem (Mem' i.L) (Pf.cut NB T tk π cap 1254 0 PRE_pf_vw.s0 PRE_pf_vw.S0)) where
  m := [(9, .L)]
  np := 0
  nb := 0 + Host.Ts.Sim.Compose.VWFirst.X2.bodyN + 31460
  O := []
  chk _ _ := rfl
  ok r hr i hi _ := by
    obtain ⟨hL, hLmax, hn, _⟩ := firstTailFacts (htail r (hu r hr)) hi
    have hf := forwardMem (Mem := Mem i.L) (Mem' := Mem' i.L) (forwardAll NB T tk π (hu r hr) hi (by omega))
      (fun x y _ _ hy _ hrun hg ht he hm => hfwd r hr i hi x y hy (runC_le _ _ _ _ _ hrun) hg ht he hm)
    exact FwdCall.warm (CutConv.refl _)
      (((((hf).trans (bodyGlue0 NB T tk π (Mem' i.L) (hT i.L) (hu r hr) hi)).trans (bodyStep0 NB T tk π (Mem' i.L) (hT i.L) (hu r hr) hi)).trans (bodyGlue1 NB T tk π (Mem' i.L) (hT i.L) (hu r hr) hi)).convR (toPfEnd NB T tk π cap hcap hbound (Mem' i.L) (hT i.L) (hu r hr) hi (htail r (hu r hr))))
      (CutConv.refl _)

end Host.Ts.Sim.Compose.VWFirst.X2.Sfx

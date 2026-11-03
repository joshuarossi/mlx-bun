import host.sim.compose.a4b.x0.Dispatch
import host.sim.compose.a4b.x0.Site1
import host.sim.compose.a4b.x0.sfx.VWFwdPf
import host.sim.stage.NextStep
import host.sim.stage.CacheHolds
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly

/-! # x0's first forward, as the bundle's pieces

The prefill's step (its own stage, `DTdec`), the glue to the dispatch, the dispatch, the glue to the forward, and the
forward through the first tail to the pre-final cut at `PRE_pf_x0`. -/

/-- **x0's prefill step**: from the shared setup's end into the class's chain. -/
noncomputable def nps_DTdec_first__start__g1_DTdec_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    StagePiece FF [first_tail_x0.r0] [⟨[(0, .L), (1, .o), (2, .C)], Stage.NextStep.DTdec.O⟩]
      (fun i => withMem (Mem i.L) (SetupCommon.nextCut NB T tk π i.L))
      (fun i => withMem (Mem i.L) (afterCut NB T tk π i)) where
  m := [(9, .L)]
  n := PRE_first_tail_x0_r0.st1.tpl.n + 1
  O := PRE_first_tail_x0_r0.st1.S0.oracle
  chk r hr := List.all_eq_true.mp PRE_first_tail_x0_r0.chk_site1 r hr
  ok r hr i hi ho := by
    obtain ⟨hL, hLmax, hn, hC⟩ := x0TailFacts hr hi
    have hc : chunkC i.L = 2048 := by
      rw [chunkC_eq i.L (by omega)]
      (repeat' split) <;> omega
    have horacle : ∀ ν, MapOk ν (setupI i.L) [(9, .L)] → Good ν PRE_first_tail_x0_r0.st1.S0.oracle := by
      intro ν hm
      exact ho.1 ν ⟨hm.1, trivial⟩
    exact StageCall.intro (toNps (hMem i.L) hc) (nps_merged (hMem i.L) horacle)
      ((nps_compact (hMem i.L) (by omega) (by omega) hn).trans
        (toAfter (hMem i.L) (by change i.n ≤ 2 ^ 20; omega)))

/-- The glue from the prefill's step to the dispatch. -/
noncomputable def g1_DTdec_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (hπ : ∀ k ∈ π, k < 248320)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    GluePiece FF [first_tail_x0.r0] (fun i => withMem (Mem i.L) (afterCut NB T tk π i))
      (fun i => withMem (Mem i.L) (dispatchCut NB T tk π i)) where
  m := npsMap
  n := 260
  O := g1Oracle
  chk r hr := List.all_eq_true.mp g1Check r hr
  ok r hr i hi ho := by
    obtain ⟨hL, hLmax, hn, _⟩ := x0TailFacts hr hi
    obtain rfl : r = first_tail_x0.r0 := List.mem_singleton.mp hr
    exact g1 (hMem i.L) hπ hL hLmax hn (x0Facts hi).1 ho.1

/-- The glue from the dispatch to the forward. -/
noncomputable def g2_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    GluePiece FF fwdClassRows (fun i => withMem (Mem i.L) (g2Cut NB T tk π i))
      (fun i => withMem (Mem i.L) (forwardCut NB T tk π i)) where
  m := npsMap
  n := 7
  O := PRE_first_tail_x0_r0.S40.oracle
  chk r hr := List.all_eq_true.mp g2Check r hr
  ok _ _ i _ ho := g2 NB T tk π i (hMem i.L) ho.1

/-- **x0's forward**, from the dispatch's glue to the pre-final cut, at the bundle's cache obligation. `hfwd`: the
graph, from what the forward's end knows. -/
noncomputable def fwd_D1_cold_DFirst__g2_first__g3d_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap : Nat)
    (hcap : 6554 ≤ cap) (hbound : cap < Sim.bound)
    (Mem Mem' : Nat → SegInst FF → Prop) (hT : ∀ L x y, NTrack x y → Mem' L x → Mem' L y)
    (hfwd : ∀ r ∈ [first_tail_x0.r0], ∀ i, InRow r i → ∀ x y : SegInst FF,
      (Sfx.startCore NB T tk π i).R y (Sfx.startCore NB T tk π i).s0 ⟨(Sfx.startCore NB T tk π i).tab0, []⟩ →
      CSrv.Le x.C y.C → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) →
      (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens → y.M.a 12504 = x.M.a 12504 → Mem i.L x → Mem' i.L y) :=
  Sfx.fwdPf NB T tk π cap hcap hbound [first_tail_x0.r0] (fun _ h => h) (fun _ h => h)
    [⟨[(0, .o), (1, .cap), (2, .n)], Stage.Cache.KvDFirst.O⟩] Mem Mem' hT hfwd

end Host.Ts.Sim.Compose.VWFirst.X0

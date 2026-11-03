import host.sim.compose.a4b.x4_L7.Dispatch
import host.sim.compose.a4b.x4_L8.Dispatch
import host.sim.compose.a4b.x4_L9.Dispatch
import host.sim.compose.a4b.x4_L7.sfx.VWFwdPf
import host.sim.compose.a4b.x4_L8.sfx.VWFwdPf
import host.sim.compose.a4b.x4_L9.sfx.VWFwdPf
import host.sim.compose.a4b.PiecesOff
import host.sim.stage.CacheHolds
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.Gpu (Pinned stepOff)

/-! # x4's first forward, as the bundle's pieces

One row, `first_tail_x4.r0`, serves the prompt lengths 7, 8 and 9, and each length has its own chain and its own pre-final
template. One prompt runs one length, and its bookkeeping pins that length (`Pinned`), so the pieces are written at each
length: the length's chain there, nothing at the other two (`stepOff`). The prefill's step and its cut are the wide rows'
(`nps_DTtail_first__start__g1_DTtail_first`, `afterNpsCut`); the glue after it converts to the length's numbering. -/

/-- A glue at one prompt length `k`: the step at `k`, and no state at another. -/
def gluePin {A B : Cls.Inst → ICut FF} {uses : List Row} (k : Nat) (hA : Pinned k A) (m : List (Nat × Q)) (n : Nat)
    (O : List Ans) (chk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true)
    (ok : ∀ r ∈ uses, ∀ i, InRow r i → i.L = k → OblOk i [⟨m, O⟩] → CutStep (A i) (B i) n) : GluePiece FF uses A B where
  m := m
  n := n
  O := O
  chk := chk
  ok r hr i hi ho := if h : i.L = k then ok r hr i hi h ho else stepOff hA h n

theorem x4Tail : ∀ r ∈ [first_tail_x4.r0], r ∈ firstTailRows := by
  intro r hr
  obtain rfl : r = first_tail_x4.r0 := List.mem_singleton.mp hr
  simp [firstTailRows]

/-! ## L = 7 -/

/-- The glue from the prefill's step to the dispatch, at a prompt of length 7. -/
noncomputable def g1_L7 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (hπ : ∀ k ∈ π, k < 248320)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) (hpin : ∀ L x, Mem L x → L = 7) :
    GluePiece FF [first_tail_x4.r0] (fun i => withMem (Mem i.L) (afterNpsCut NB T tk π i))
      (fun i => withMem (Mem i.L) (Host.Ts.Sim.Compose.VWFirst.X4_L7.dispatchCut NB T tk π i)) :=
  gluePin 7 (fun i x hb => hpin i.L x hb.2) Host.Ts.Sim.Compose.VWFirst.X4_L7.npsMap 260 Host.Ts.Sim.Compose.VWFirst.X4_L7.g1Oracle
    (fun r hr => List.all_eq_true.mp Host.Ts.Sim.Compose.VWFirst.X4_L7.g1Check r hr)
    (fun r hr i hi hk ho => by
      obtain ⟨hL, hLmax, hn, _⟩ := firstTailFacts (x4Tail r hr) hi
      exact CutStep.convL (Host.Ts.Sim.Compose.VWFirst.X4_L7.toAfter (hMem i.L) (by change i.n ≤ 2 ^ 20; omega))
        (Host.Ts.Sim.Compose.VWFirst.X4_L7.g1 (hMem i.L) hπ hL hLmax hn hk ho.1))

/-- The dispatch, at a prompt of length 7. -/
noncomputable def disp_L7 (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    StagePiece FF [first_tail_x4.r0] [] (fun i => withMem (Mem i.L) (Host.Ts.Sim.Compose.VWFirst.X4_L7.dispatchCut NB T tk π i))
      (fun i => withMem (Mem i.L) (Host.Ts.Sim.Compose.VWFirst.X4_L7.g2Cut NB T tk π i)) :=
  Host.Ts.Sim.Compose.VWFirst.X4_L7.disp NB T tk π Mem hMem

/-- The glue from the dispatch to the forward, at a prompt of length 7. -/
noncomputable def g2_L7 (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    GluePiece FF [first_tail_x4.r0] (fun i => withMem (Mem i.L) (Host.Ts.Sim.Compose.VWFirst.X4_L7.g2Cut NB T tk π i))
      (fun i => withMem (Mem i.L) (Host.Ts.Sim.Compose.VWFirst.X4_L7.forwardCut NB T tk π i)) where
  m := Host.Ts.Sim.Compose.VWFirst.X4_L7.npsMap
  n := 7
  O := PRE_first_tail_x4_L7_r0.S40.oracle
  chk r hr := List.all_eq_true.mp Host.Ts.Sim.Compose.VWFirst.X4_L7.g2Check r hr
  ok _ _ i _ ho := Host.Ts.Sim.Compose.VWFirst.X4_L7.g2 NB T tk π i (hMem i.L) ho.1

/-- **x4's forward at a prompt of length 7**, from the dispatch's glue to the pre-final cut at `PRE_pf_x4_L7`, at the
bundle's cache obligation. `hfwd`: the graph, from what the forward's end knows. -/
noncomputable def fwd_L7 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap : Nat)
    (hcap : 67849 ≤ cap) (hbound : cap < Sim.bound)
    (Mem Mem' : Nat → SegInst FF → Prop) (hT : ∀ L x y, NTrack x y → Mem' L x → Mem' L y) (hpin : ∀ L x, Mem L x → L = 7)
    (hfwd : ∀ r ∈ [first_tail_x4.r0], ∀ i, InRow r i → ∀ x y : SegInst FF,
      (Host.Ts.Sim.Compose.VWFirst.X4_L7.Sfx.startCore NB T tk π i).R y (Host.Ts.Sim.Compose.VWFirst.X4_L7.Sfx.startCore NB T tk π i).s0 ⟨(Host.Ts.Sim.Compose.VWFirst.X4_L7.Sfx.startCore NB T tk π i).tab0, []⟩ →
      CSrv.Le x.C y.C → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) →
      (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens → y.M.a 12504 = x.M.a 12504 → Mem i.L x → Mem' i.L y) :=
  Host.Ts.Sim.Compose.VWFirst.X4_L7.Sfx.fwdPf NB T tk π cap hcap hbound [first_tail_x4.r0] (fun _ h => h) (fun r hr => x4Tail r hr)
    [⟨[(0, .o), (1, .cap), (2, .n)], Stage.Cache.KvWFirst.O⟩] Mem Mem' hT hpin hfwd

/-! ## L = 8 -/

/-- The glue from the prefill's step to the dispatch, at a prompt of length 8. -/
noncomputable def g1_L8 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (hπ : ∀ k ∈ π, k < 248320)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) (hpin : ∀ L x, Mem L x → L = 8) :
    GluePiece FF [first_tail_x4.r0] (fun i => withMem (Mem i.L) (afterNpsCut NB T tk π i))
      (fun i => withMem (Mem i.L) (Host.Ts.Sim.Compose.VWFirst.X4_L8.dispatchCut NB T tk π i)) :=
  gluePin 8 (fun i x hb => hpin i.L x hb.2) Host.Ts.Sim.Compose.VWFirst.X4_L8.npsMap 260 Host.Ts.Sim.Compose.VWFirst.X4_L8.g1Oracle
    (fun r hr => List.all_eq_true.mp Host.Ts.Sim.Compose.VWFirst.X4_L8.g1Check r hr)
    (fun r hr i hi hk ho => by
      obtain ⟨hL, hLmax, hn, _⟩ := firstTailFacts (x4Tail r hr) hi
      exact CutStep.convL (Host.Ts.Sim.Compose.VWFirst.X4_L8.toAfter (hMem i.L) (by change i.n ≤ 2 ^ 20; omega))
        (Host.Ts.Sim.Compose.VWFirst.X4_L8.g1 (hMem i.L) hπ hL hLmax hn hk ho.1))

/-- The dispatch, at a prompt of length 8. -/
noncomputable def disp_L8 (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    StagePiece FF [first_tail_x4.r0] [] (fun i => withMem (Mem i.L) (Host.Ts.Sim.Compose.VWFirst.X4_L8.dispatchCut NB T tk π i))
      (fun i => withMem (Mem i.L) (Host.Ts.Sim.Compose.VWFirst.X4_L8.g2Cut NB T tk π i)) :=
  Host.Ts.Sim.Compose.VWFirst.X4_L8.disp NB T tk π Mem hMem

/-- The glue from the dispatch to the forward, at a prompt of length 8. -/
noncomputable def g2_L8 (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    GluePiece FF [first_tail_x4.r0] (fun i => withMem (Mem i.L) (Host.Ts.Sim.Compose.VWFirst.X4_L8.g2Cut NB T tk π i))
      (fun i => withMem (Mem i.L) (Host.Ts.Sim.Compose.VWFirst.X4_L8.forwardCut NB T tk π i)) where
  m := Host.Ts.Sim.Compose.VWFirst.X4_L8.npsMap
  n := 7
  O := PRE_first_tail_x4_L8_r0.S40.oracle
  chk r hr := List.all_eq_true.mp Host.Ts.Sim.Compose.VWFirst.X4_L8.g2Check r hr
  ok _ _ i _ ho := Host.Ts.Sim.Compose.VWFirst.X4_L8.g2 NB T tk π i (hMem i.L) ho.1

/-- **x4's forward at a prompt of length 8**, from the dispatch's glue to the pre-final cut at `PRE_pf_x4_L8`, at the
bundle's cache obligation. `hfwd`: the graph, from what the forward's end knows. -/
noncomputable def fwd_L8 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap : Nat)
    (hcap : 67849 ≤ cap) (hbound : cap < Sim.bound)
    (Mem Mem' : Nat → SegInst FF → Prop) (hT : ∀ L x y, NTrack x y → Mem' L x → Mem' L y) (hpin : ∀ L x, Mem L x → L = 8)
    (hfwd : ∀ r ∈ [first_tail_x4.r0], ∀ i, InRow r i → ∀ x y : SegInst FF,
      (Host.Ts.Sim.Compose.VWFirst.X4_L8.Sfx.startCore NB T tk π i).R y (Host.Ts.Sim.Compose.VWFirst.X4_L8.Sfx.startCore NB T tk π i).s0 ⟨(Host.Ts.Sim.Compose.VWFirst.X4_L8.Sfx.startCore NB T tk π i).tab0, []⟩ →
      CSrv.Le x.C y.C → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) →
      (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens → y.M.a 12504 = x.M.a 12504 → Mem i.L x → Mem' i.L y) :=
  Host.Ts.Sim.Compose.VWFirst.X4_L8.Sfx.fwdPf NB T tk π cap hcap hbound [first_tail_x4.r0] (fun _ h => h) (fun r hr => x4Tail r hr)
    [⟨[(0, .o), (1, .cap), (2, .n)], Stage.Cache.KvWFirst.O⟩] Mem Mem' hT hpin hfwd

/-! ## L = 9 -/

/-- The glue from the prefill's step to the dispatch, at a prompt of length 9. -/
noncomputable def g1_L9 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (hπ : ∀ k ∈ π, k < 248320)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) (hpin : ∀ L x, Mem L x → L = 9) :
    GluePiece FF [first_tail_x4.r0] (fun i => withMem (Mem i.L) (afterNpsCut NB T tk π i))
      (fun i => withMem (Mem i.L) (Host.Ts.Sim.Compose.VWFirst.X4_L9.dispatchCut NB T tk π i)) :=
  gluePin 9 (fun i x hb => hpin i.L x hb.2) Host.Ts.Sim.Compose.VWFirst.X4_L9.npsMap 260 Host.Ts.Sim.Compose.VWFirst.X4_L9.g1Oracle
    (fun r hr => List.all_eq_true.mp Host.Ts.Sim.Compose.VWFirst.X4_L9.g1Check r hr)
    (fun r hr i hi hk ho => by
      obtain ⟨hL, hLmax, hn, _⟩ := firstTailFacts (x4Tail r hr) hi
      exact CutStep.convL (Host.Ts.Sim.Compose.VWFirst.X4_L9.toAfter (hMem i.L) (by change i.n ≤ 2 ^ 20; omega))
        (Host.Ts.Sim.Compose.VWFirst.X4_L9.g1 (hMem i.L) hπ hL hLmax hn hk ho.1))

/-- The dispatch, at a prompt of length 9. -/
noncomputable def disp_L9 (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    StagePiece FF [first_tail_x4.r0] [] (fun i => withMem (Mem i.L) (Host.Ts.Sim.Compose.VWFirst.X4_L9.dispatchCut NB T tk π i))
      (fun i => withMem (Mem i.L) (Host.Ts.Sim.Compose.VWFirst.X4_L9.g2Cut NB T tk π i)) :=
  Host.Ts.Sim.Compose.VWFirst.X4_L9.disp NB T tk π Mem hMem

/-- The glue from the dispatch to the forward, at a prompt of length 9. -/
noncomputable def g2_L9 (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    GluePiece FF [first_tail_x4.r0] (fun i => withMem (Mem i.L) (Host.Ts.Sim.Compose.VWFirst.X4_L9.g2Cut NB T tk π i))
      (fun i => withMem (Mem i.L) (Host.Ts.Sim.Compose.VWFirst.X4_L9.forwardCut NB T tk π i)) where
  m := Host.Ts.Sim.Compose.VWFirst.X4_L9.npsMap
  n := 7
  O := PRE_first_tail_x4_L9_r0.S40.oracle
  chk r hr := List.all_eq_true.mp Host.Ts.Sim.Compose.VWFirst.X4_L9.g2Check r hr
  ok _ _ i _ ho := Host.Ts.Sim.Compose.VWFirst.X4_L9.g2 NB T tk π i (hMem i.L) ho.1

/-- **x4's forward at a prompt of length 9**, from the dispatch's glue to the pre-final cut at `PRE_pf_x4_L9`, at the
bundle's cache obligation. `hfwd`: the graph, from what the forward's end knows. -/
noncomputable def fwd_L9 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap : Nat)
    (hcap : 67849 ≤ cap) (hbound : cap < Sim.bound)
    (Mem Mem' : Nat → SegInst FF → Prop) (hT : ∀ L x y, NTrack x y → Mem' L x → Mem' L y) (hpin : ∀ L x, Mem L x → L = 9)
    (hfwd : ∀ r ∈ [first_tail_x4.r0], ∀ i, InRow r i → ∀ x y : SegInst FF,
      (Host.Ts.Sim.Compose.VWFirst.X4_L9.Sfx.startCore NB T tk π i).R y (Host.Ts.Sim.Compose.VWFirst.X4_L9.Sfx.startCore NB T tk π i).s0 ⟨(Host.Ts.Sim.Compose.VWFirst.X4_L9.Sfx.startCore NB T tk π i).tab0, []⟩ →
      CSrv.Le x.C y.C → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) →
      (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens → y.M.a 12504 = x.M.a 12504 → Mem i.L x → Mem' i.L y) :=
  Host.Ts.Sim.Compose.VWFirst.X4_L9.Sfx.fwdPf NB T tk π cap hcap hbound [first_tail_x4.r0] (fun _ h => h) (fun r hr => x4Tail r hr)
    [⟨[(0, .o), (1, .cap), (2, .n)], Stage.Cache.KvWFirst.O⟩] Mem Mem' hT hpin hfwd

end Host.Ts.Sim.Compose.VWFirst

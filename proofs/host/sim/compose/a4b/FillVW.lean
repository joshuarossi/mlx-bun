import host.sim.compose.a4b.vw15.sfx.VWFwdPf
import host.sim.compose.a4b.vw8.sfx.VWFwdPf
import host.sim.compose.a4b.vw6.sfx.VWFwdPf
import host.sim.compose.PiecesSub
namespace Host.Ts.Sim.Compose.FillVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

/-! # The first tail of the wide rows, from the forward to the pre-final cut

The three bodies run different step counts, and a piece has one count over its rows. Each row's own forward piece
therefore runs its whole stretch, and the shared pieces after it are empty. -/

/-- A glue no row runs. -/
def gEmpty (uses : List Row) (A : Cls.Inst → ICut FF) : GluePiece FF uses A A where
  m := []
  n := 0
  O := []
  chk _ _ := rfl
  ok _ _ _ _ _ := CutStep.refl _

/-- A stage no row runs. -/
def sEmpty (uses : List Row) (obls : List Obl) (A : Cls.Inst → ICut FF) : StagePiece FF uses obls A A where
  m := []
  n := 0
  O := []
  chk _ _ := rfl
  ok _ _ _ _ _ := StageCall.intro (CutConv.refl _) (CutStep.refl _) (CutConv.refl _)

/-- The graph's step over a group: from a forward's end to the bookkeeping after it. -/
def HFwd (start : Cls.Inst → ICut FF) (rows : List Row) (Mem Mem' : Nat → SegInst FF → Prop) : Prop :=
  ∀ r ∈ rows, ∀ i, InRow r i → ∀ x y : SegInst FF,
    (start i).R y (start i).s0 ⟨(start i).tab0, []⟩ → CSrv.Le x.C y.C →
    Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens → y.M.a 12504 = x.M.a 12504 →
    Mem i.L x → Mem' i.L y

theorem tail15 : ∀ r ∈ VWFirst.VW15.fwdRows, r ∈ VWFirst.firstTailRows := by
  intro r hr
  simp only [VWFirst.VW15.fwdRows, List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> simp [VWFirst.firstTailRows]

theorem tail8 : ∀ r ∈ VWFirst.VW8.fwdRows, r ∈ VWFirst.firstTailRows := by
  intro r hr
  simp only [VWFirst.VW8.fwdRows, List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> simp [VWFirst.firstTailRows]

theorem tail6 : ∀ r ∈ VWFirst.VW6.fwdRows, r ∈ VWFirst.firstTailRows := by
  intro r hr
  simp only [VWFirst.VW6.fwdRows, List.mem_cons, List.not_mem_nil, or_false] at hr
  subst hr
  simp [VWFirst.firstTailRows]

section
variable (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap : Nat) (hcap : 70009 ≤ cap) (hbound : cap < Sim.bound)
  (Mem Mem' : Nat → SegInst FF → Prop) (hT : ∀ L x y, NTrack x y → Mem' L x → Mem' L y)

/-- The pre-final cut. -/
noncomputable def pfCut (L : Nat) : ICut FF :=
  withMem (Mem' L) (Pf.cut NB T tk π cap 1254 0 PRE_pf_vw.s0 PRE_pf_vw.S0)

/-- A row of the x15 body. -/
noncomputable def fwd15 (hf : HFwd (VWFirst.VW15.Sfx.startCore NB T tk π) VWFirst.VW15.fwdRows Mem Mem') {r : Row}
    (hr : r ∈ VWFirst.VW15.fwdRows) (obls : List Obl) :
    FwdPiece FF [r] obls (fun i => withMem (Mem i.L) (VWFirst.forwardCut NB T tk π i)) (fun i => pfCut NB T tk π cap Mem' i.L) :=
  VWFirst.VW15.Sfx.fwdPf NB T tk π cap (by omega) hbound [r] (fun _ h => (List.mem_singleton.mp h).symm ▸ hr) tail15 obls Mem Mem' hT
    (fun _ h => hf _ ((List.mem_singleton.mp h).symm ▸ hr))

/-- A row of the x8 body. -/
noncomputable def fwd8 (hf : HFwd (VWFirst.VW8.Sfx.startCore NB T tk π) VWFirst.VW8.fwdRows Mem Mem') {r : Row}
    (hr : r ∈ VWFirst.VW8.fwdRows) (obls : List Obl) :
    FwdPiece FF [r] obls (fun i => withMem (Mem i.L) (VWFirst.forwardCut NB T tk π i)) (fun i => pfCut NB T tk π cap Mem' i.L) :=
  VWFirst.VW8.Sfx.fwdPf NB T tk π cap hcap hbound [r] (fun _ h => (List.mem_singleton.mp h).symm ▸ hr) tail8 obls Mem Mem' hT
    (fun _ h => hf _ ((List.mem_singleton.mp h).symm ▸ hr))

/-- A row of the x6 body. -/
noncomputable def fwd6 (hf : HFwd (VWFirst.VW6.Sfx.startCore NB T tk π) VWFirst.VW6.fwdRows Mem Mem') {r : Row}
    (hr : r ∈ VWFirst.VW6.fwdRows) (obls : List Obl) :
    FwdPiece FF [r] obls (fun i => withMem (Mem i.L) (VWFirst.forwardCut NB T tk π i)) (fun i => pfCut NB T tk π cap Mem' i.L) :=
  VWFirst.VW6.Sfx.fwdPf NB T tk π cap (by omega) hbound [r] (fun _ h => (List.mem_singleton.mp h).symm ▸ hr) tail6 obls Mem Mem' hT
    (fun _ h => hf _ ((List.mem_singleton.mp h).symm ▸ hr))
end
end Host.Ts.Sim.Compose.FillVW

import host.sim.compose.a4b.pl.Common.All
import host.sim.compose.a4b.pl.R1.All
import host.sim.compose.a4b.pl.R2.All
import host.sim.compose.RoutePieces
import host.sim.compose.RouteBundleR
import host.sim.template.a4pre_pl_call.Facts
import host.sim.template.a4pre_pl_selector.Good
import host.sim.template.a4pre_pl_t2p.K0
import host.sim.template.a4pre_pl_t2p.Accept
import host.sim.template.a4pre_pl_t2p.Good
import host.sim.template.a4pre_pl_t2p.Origin
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.FillPost
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Ts.Sim.Compose.Post
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route

/-! # POST of the prompts with no Neural Engine forward

The chains are flat and a piece has one step count over its rows, so each stretch lives in one piece and the shape's
others are empty: the selector in `g5`; `PRE_pl_common` in the cold sampler; the restart into the shared tail in `g7`;
the first readback in `rb`; each warm forward, with its sampler and the next readback's start, in its forward piece.

The bookkeeping changes by the route's hooks: `hsmp` at the sampled cut, `hpop` at the readback, `hfw0` and `hfw1` at the
forwards' ends. -/

/-- A stretch's change of bookkeeping, from what its end knows. -/
def Hook (c : ICut FF) (M M' : SegInst FF → Prop) : Prop :=
  ∀ x y : SegInst FF, c.R y c.s0 ⟨c.tab0, []⟩ → CSrv.Le x.C y.C →
    Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens → y.M.a 12504 = x.M.a 12504 → M x → M' y

/-- A template's start equal to another's end. -/
theorem idxConv {NB T cap nI : Nat} {tk : Nat → Nat} {π : List Nat} {M : SegInst FF → Prop} {s s' : St FF.S} {S S' : SSrv}
    (hs : s' = s) (ht : S'.tab = S.tab) :
    CutConv (withMem M (indexedCut NB T tk cap nI π s S)) (withMem M (indexedCut NB T tk cap nI π s' S')) := by
  subst hs
  rintro x ⟨γ, hrel, hb⟩ hB
  refine ⟨x, rfl, rfl, ⟨γ, ?_, hb⟩, hB⟩
  change RelB FF _ _ [] x.M x.ν x.K s' ⟨S'.tab, []⟩ x.t x.C
  rw [ht]
  exact hrel

section Empty
variable {Adm : Cls.Inst → Prop} (uses : List Row) (obls : List Obl) (A : Cls.Inst → ICut FF)

/-- A glue no row runs. -/
def rgEmpty : RGluePiece FF Adm uses A A where
  m := []
  n := 0
  O := []
  chk _ _ := rfl
  ok _ _ _ _ _ _ := CutStep.refl _

/-- A stage no row runs. -/
def rsEmpty : RStagePiece FF Adm uses obls A A where
  m := []
  n := 0
  O := []
  chk _ _ := rfl
  ok _ _ _ _ _ _ := StageCall.intro (CutConv.refl _) (CutStep.refl _) (CutConv.refl _)

end Empty

kernel_rfl selTop : noRetBlock PRE_pl_call.s1 = true
kernel_rfl selCnt : countersOkB PRE_pl_selector.s0 PRE_pl_call.s1 = true
kernel_rfl t2pTop : noRetBlock PRE_pl_t2p.s1 = true
kernel_rfl t2pBr : bridgeOf PRE_pl_t2p.s1.ffi = bridgeOf PRE_pl_t2p.s0.ffi

/-- The rows of POST's main path. -/
def postRows : List Row := [route_post_other.r0, route_post_other.r1]

theorem postFacts {r : Row} {i : Cls.Inst} (hr : r ∈ postRows) (hi : InRow r i) :
    3 ≤ i.T ∧ i.T ≤ 262143 ∧ i.t1 ≤ 248319 ∧ i.t1 ≠ 248044 := by
  simp only [postRows, List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl
  all_goals
    obtain ⟨_, x, hx, hq⟩ := hi
    simp only [route_post_other.r0, route_post_other.r1, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
    omega

section
variable (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap nI : Nat) (hcap : cap ≤ 4096 + 1593835520)
  (hL1 : 1 ≤ π.length) (hL2 : π.length ≤ 224)

/-- The bookkeeping's stretches and changes. -/
structure Hooks where
  Mem0 : Nat → SegInst FF → Prop
  MemP : Nat → Nat → SegInst FF → Prop
  hM0 : ∀ L x y, NTrack x y → Mem0 L x → Mem0 L y
  hMP : ∀ j L x y, NTrack x y → MemP j L x → MemP j L y
  hsmp : ∀ L, Hook (indexedCut NB T tk cap nI π PRE_pl_common.s4 PRE_pl_common.S4) (Mem0 L) (MemP 0 L)
  hlink : ∀ L, CutConv (withMem (MemP 0 L) (indexedCut NB T tk cap nI π PRE_pl_common.s4 PRE_pl_common.S4))
    (withMem (MemP 0 L) (indexedCut NB T tk cap nI π PRE_pl_tail.s0 PRE_pl_tail.S0))
  hpop : ∀ L (x y : SegInst FF),
    (indexedCut NB T tk cap nI π PRE_pl_t2p.s0 PRE_pl_t2p.S0).R x PRE_pl_t2p.s0 ⟨PRE_pl_t2p.S0.tab, []⟩ →
    (indexedCut NB T tk cap nI π PRE_pl_t2p.s1 PRE_pl_t2p.S1).R y PRE_pl_t2p.s1 ⟨PRE_pl_t2p.S1.tab, []⟩ →
    CSrv.Le x.C y.C → y.M.node = x.M.node → y.M.a 12504 = x.M.a 12504 →
    Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → MemP 0 L x → MemP 0 L y
  hfw0 : ∀ L, Hook (indexedCut NB T tk cap nI π PRE_pl_r1.s890 PRE_pl_r1.S890) (MemP 0 L) (MemP 1 L)
  hfw1 : ∀ L, Hook (indexedCut NB T tk cap nI π PRE_pl_r2.s890 PRE_pl_r2.S890) (MemP 1 L) (MemP 2 L)

variable {NB T tk π cap nI}
variable (H : Hooks NB T tk π cap nI)

/-- A cut of POST under the first bookkeeping. -/
noncomputable def c0 (s : St FF.S) (S : SSrv) (i : Cls.Inst) : ICut FF :=
  withMem (H.Mem0 i.L) (indexedCut NB T tk cap nI π s S)

/-- A cut of POST with the reference held through `j` times. -/
noncomputable def cP (j : Nat) (s : St FF.S) (S : SSrv) (i : Cls.Inst) : ICut FF :=
  withMem (H.MemP j i.L) (indexedCut NB T tk cap nI π s S)

/-- The selector, to the head's call. -/
noncomputable def g5 (Adm : Cls.Inst → Prop) (uses : List Row) :
    RGluePiece FF Adm uses (c0 H PRE_pl_head.s1 PRE_pl_head.S1) (c0 H PRE_pl_call.s1 PRE_pl_call.S1) where
  m := []
  n := 131
  O := []
  chk _ _ := rfl
  ok _ _ i _ _ _ :=
    (glueM (nI := nI) (π := π) (modeOk NB T tk cap hcap) PRE_pl_call.accepted_selector PRE_pl_call.selectorRun selTop
      (fun _ h => PRE_pl_selector.good h.rowValue) PRE_pl_call.selector_inactive PRE_pl_call.head_bridge selCnt
      (H.hM0 i.L) rfl).convL (idxConv PRE_pl_selector.s0_eq PRE_pl_selector.s0_tab)

/-- The head, the cold sampler and the first async evaluation, to the sampled cut. -/
noncomputable def smpCold (Adm : Cls.Inst → Prop) (uses : List Row) (obls : List Obl) :
    RStagePiece FF Adm uses obls (c0 H PRE_pl_call.s1 PRE_pl_call.S1) (cP H 0 PRE_pl_common.s4 PRE_pl_common.S4) where
  m := []
  n := PL.Common.N
  O := []
  chk _ _ := rfl
  ok _ _ i _ _ _ := StageCall.intro (idxConv PRE_pl_common.s0_eq PRE_pl_common.s0_tab)
    (hookMem (fun x0 => PL.Common.all NB T tk cap nI π hcap (fun _ h => PRE_pl_common.good h.rowValue) (NTrack x0)
        (fun _ _ h h0 => h0.trans h))
      (fun x y _ hy _ htr hm => H.hsmp i.L x y hy htr.server htr.nodes htr.tokens htr.emit hm))
    (CutConv.refl _)

/-- The restart into the shared tail. -/
noncomputable def g7 (Adm : Cls.Inst → Prop) (uses : List Row) :
    RGluePiece FF Adm uses (cP H 0 PRE_pl_common.s4 PRE_pl_common.S4) (cP H 0 PRE_pl_tail.s0 PRE_pl_tail.S0) where
  m := []
  n := 0
  O := []
  chk _ _ := rfl
  ok _ _ i _ _ _ := (CutStep.refl _).convR (H.hlink i.L)

/-- The first readback: the tail's first stretch, to the first warm forward's call. -/
noncomputable def rb0 (Adm : Cls.Inst → Prop) (hAdm : ∀ i, Adm i → i.T = T ∧ i.t1 = tk 1) (obls : List Obl) :
    RStagePiece FF Adm postRows obls (cP H 0 PRE_pl_tail.s0 PRE_pl_tail.S0) (cP H 0 PRE_pl_t2p.s1 PRE_pl_t2p.S1) where
  m := []
  n := (nth? PRE_pl_t2p.ks 0).getD 0
  O := []
  chk _ _ := rfl
  ok r hr i hi _ hadm := by
    obtain ⟨hT3, hTle, ht1, hne⟩ := postFacts hr hi
    obtain ⟨hiT, hit⟩ := hAdm i hadm
    rw [hiT] at hT3 hTle
    rw [hit] at ht1 hne
    exact StageCall.intro (idxConv PRE_pl_t2p.s0_eq PRE_pl_t2p.s0_tab)
      (popM (nI := nI) (π := π) (modeOk NB T tk cap hcap) PRE_pl_t2p.accepted0 PRE_pl_t2p.run0 t2pTop
        (fun _ h => PRE_pl_t2p.good (T := T) (t := tk 1) (by omega) (by omega) (by omega) hne
          ((h.reserved 0 (by omega)).trans rfl) ((h.reserved 1 (by omega)).trans (by simp [machVal])))
        (Host.Load.Boot.replay_active _) t2pBr
        (fun x y hx hy hle hn ha hg hm => H.hpop i.L x y hx hy hle hn ha hg hm) rfl)
      (CutConv.refl _)

include hL1 hL2 in
theorem capShort : capL π.length = 256 + 256 * 0 := by
  unfold capL
  omega

/-- The first warm forward. -/
noncomputable def fw0 (Adm : Cls.Inst → Prop) (obls : List Obl) :
    RFwdPiece FF Adm postRows obls (cP H 0 PRE_pl_t2p.s1 PRE_pl_t2p.S1) (cP H 1 PRE_pl_r1.s890 PRE_pl_r1.S890) where
  m := []
  np := 0
  nb := PL.R1.N
  O := []
  chk _ _ := rfl
  ok _ _ i _ _ _ := FwdCall.warm (idxConv PRE_pl_r1.s0_eq PRE_pl_r1.s0_tab)
    (hookMem (fun x0 => PL.R1.all NB T tk cap nI π hcap
        (fun _ h => PRE_pl_r1.good (b := 0) (r := π.length) (by omega) hL1 (by omega) h.rowValue
          (by simpa using h.offsetValue) (by rw [h.capValue, capShort hL1 hL2]))
        (NTrack x0) (fun _ _ h h0 => h0.trans h))
      (fun x y _ hy _ htr hm => H.hfw0 i.L x y hy htr.server htr.nodes htr.tokens htr.emit hm))
    (CutConv.refl _)

/-- The second warm forward, to the decode cut. -/
noncomputable def fw1 (Adm : Cls.Inst → Prop) (hAdm : ∀ i, Adm i → i.T = T ∧ i.t1 = tk 1) (obls : List Obl) :
    RFwdPiece FF Adm postRows obls (cP H 1 PRE_pl_r1.s890 PRE_pl_r1.S890) (cP H 2 PRE_pl_r2.s890 PRE_pl_r2.S890) where
  m := []
  np := 0
  nb := PL.R2.N
  O := []
  chk _ _ := rfl
  ok r hr i hi _ hadm := by
    obtain ⟨hT3, hTle, ht1, hne⟩ := postFacts hr hi
    obtain ⟨hiT, hit⟩ := hAdm i hadm
    rw [hiT] at hT3 hTle
    rw [hit] at ht1 hne
    exact FwdCall.warm (idxConv PRE_pl_r2.s0_eq PRE_pl_r2.s0_tab)
      (hookMem (fun x0 => PL.R2.all NB T tk cap nI π hcap
          (fun _ h => PRE_pl_r2.good (b := 0) (r := π.length) (T := T) (t := tk 1) (by omega) hL1 (by omega) hT3 hTle ht1 hne
            ((h.reserved 0 (by omega)).trans rfl) ((h.reserved 1 (by omega)).trans (by simp [machVal])) h.rowValue
            (by simpa using h.offsetValue) (by rw [h.capValue, capShort hL1 hL2]))
          (NTrack x0) (fun _ _ h h0 => h0.trans h))
        (fun x y _ hy _ htr hm => H.hfw1 i.L x y hy htr.server htr.nodes htr.tokens htr.emit hm))
      (CutConv.refl _)

/-- The prefill's invariants, POST's ends at the hooks' bookkeeping. -/
noncomputable def invs (ld pc0 pf : Nat \u2192 ICut FF) (pc : Nat \u2192 Nat \u2192 ICut FF) : PrefInvsW FF where
  ld := ld
  pc0 := pc0
  pc := pc
  pf := pf
  ps L := withMem (H.Mem0 L) (indexedCut NB T tk cap nI \u03C0 PRE_pl_head.s1 PRE_pl_head.S1)
  dec L := withMem (H.MemP 2 L) (indexedCut NB T tk cap nI \u03C0 PRE_pl_r2.s890 PRE_pl_r2.S890)

/-- The cuts between POST's pieces. -/
noncomputable def cuts : Gpu.RoutePiecesRCuts FF where
  b_post_g5_o := c0 H PRE_pl_call.s1 PRE_pl_call.S1
  b_post_g6_i := c0 H PRE_pl_call.s1 PRE_pl_call.S1
  b_post_g6_o := c0 H PRE_pl_call.s1 PRE_pl_call.S1
  b_post_g7_i := cP H 0 PRE_pl_common.s4 PRE_pl_common.S4
  b_post_g7_o := cP H 0 PRE_pl_tail.s0 PRE_pl_tail.S0
  b_post_g8_i := cP H 0 PRE_pl_tail.s0 PRE_pl_tail.S0
  b_post_g8_o := cP H 0 PRE_pl_tail.s0 PRE_pl_tail.S0
  b_post_g9_0_i := cP H 0 PRE_pl_t2p.s1 PRE_pl_t2p.S1
  b_post_g9_0_o := cP H 0 PRE_pl_t2p.s1 PRE_pl_t2p.S1
  b_post_g10_0_i := cP H 1 PRE_pl_r1.s890 PRE_pl_r1.S890
  b_post_g10_0_o := cP H 1 PRE_pl_r1.s890 PRE_pl_r1.S890
  b_post_g11_0_i := cP H 1 PRE_pl_r1.s890 PRE_pl_r1.S890
  b_post_g11_0_o := cP H 1 PRE_pl_r1.s890 PRE_pl_r1.S890
  b_post_g12_0_i := cP H 1 PRE_pl_r1.s890 PRE_pl_r1.S890
  b_post_g12_0_o := cP H 1 PRE_pl_r1.s890 PRE_pl_r1.S890
  b_post_g9_1_i := cP H 1 PRE_pl_r1.s890 PRE_pl_r1.S890
  b_post_g9_1_o := cP H 1 PRE_pl_r1.s890 PRE_pl_r1.S890
  b_post_g10_1_i := cP H 2 PRE_pl_r2.s890 PRE_pl_r2.S890
  b_post_g10_1_o := cP H 2 PRE_pl_r2.s890 PRE_pl_r2.S890
  b_post_g11_1_i := cP H 2 PRE_pl_r2.s890 PRE_pl_r2.S890
  b_post_g11_1_o := cP H 2 PRE_pl_r2.s890 PRE_pl_r2.S890
  b_post_g12_1_i := cP H 2 PRE_pl_r2.s890 PRE_pl_r2.S890

/-- **POST's pieces.** -/
noncomputable def pieces (ld pc0 pf : Nat \u2192 ICut FF) (pc : Nat \u2192 Nat \u2192 ICut FF) :
    Gpu.RoutePiecesR FF (invs H ld pc0 pf pc) T tk where
  cuts := cuts H
  q1 :=
    { post_g5 := g5 hcap H _ _
      head__post_g5__post_g6 := rsEmpty _ _ _
      post_g6 := rgEmpty _ _
      smp_cold__post_g6__post_g7 := smpCold hcap H _ _ _
      post_g7 := g7 H _ _
      async__post_g7__post_g8 := rsEmpty _ _ _
      post_g8 := rgEmpty _ _
      rb__post_g8__post_g9_0 := rb0 hcap H _ (fun _ h => \u27E8h.1, h.2.1\u27E9) _
      post_g9_0 := rgEmpty _ _
      fwd_D1_warm_DFit__post_g9_0__post_g10_0 := fw0 hcap hL1 hL2 H _ _
      post_g10_0 := rgEmpty _ _
      smp_warm__post_g10_0__post_g11_0 := rsEmpty _ _ _
      post_g11_0 := rgEmpty _ _
      async__post_g11_0__post_g12_0 := rsEmpty _ _ _
      post_g12_0 := rgEmpty _ _
      rb__post_g12_0__post_g9_1 := rsEmpty _ _ _
      post_g9_1 := rgEmpty _ _
      fwd_D1_warm_DFit__post_g9_1__post_g10_1 := fw1 hcap hL1 hL2 H _ (fun _ h => \u27E8h.1, h.2.1\u27E9) _
      post_g10_1 := rgEmpty _ _
      smp_warm__post_g10_1__post_g11_1 := rsEmpty _ _ _
      post_g11_1 := rgEmpty _ _
      async__post_g11_1__post_g12_1 := rsEmpty _ _ _
      post_g12_1 := rgEmpty _ _ }
  eqs := \u27E8trivial\u27E9

end

end Host.Ts.Sim.Compose.FillPost

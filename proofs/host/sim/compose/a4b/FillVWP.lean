import host.sim.compose.a4b.FillVWHooks
import host.sim.compose.a4b.FillVW
import host.sim.compose.a4b.FillVWFirst
import host.sim.compose.a4b.FillSetupH0
import host.sim.compose.a4b.FillSetupEarly
import host.sim.compose.a4b.PiecesOff
import host.sim.compose.a4b.fd.Pieces
import host.sim.compose.a4b.fd.Entry
import host.sim.compose.a4b.pl.VHead.All
import host.sim.template.a4pre_plvw_head.Origin
import host.sim.template.a4pre_plvw_head.Good
import host.route.cert.VW15.Fwd
import host.route.cert.VW8.Fwd
import host.route.cert.VW6.Fwd
import host.route.cert.Fin.VW.Hfin
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.FillPost
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Ts.Sim.Compose.Post Host.Ts.Sim.Compose.Gpu
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route Host.Route.PrefGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Load.Run.Prompt Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval
open Host.Mlx.SimGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # A VW prompt's prefill

`I` and `PiecesR` at a prompt of 10 to 224 tokens: setup at the long chunk, the first tail through its group's forward to the
pre-final cut, the final forward, and VW's POST entry. Every other row is of another length: the bookkeeping names it. The first
tail's carriers are the final forward's (`c15`, `c8`, `c6`), the pre-final and final steps' node maps being the identity. -/

kernel_rfl c15 : Host.Route.Cert.VW15.cert.carriers = Host.Route.Cert.Fin.VW.finCert.ps
kernel_rfl c8 : Host.Route.Cert.VW8.cert.carriers = Host.Route.Cert.Fin.VW.finCert.ps
kernel_rfl c6 : Host.Route.Cert.VW6.cert.carriers = Host.Route.Cert.Fin.VW.finCert.ps
kernel_rfl g2X0 : goodLin first_tail_x0.r0.ps (varsOf first_tail_x0.r0.V VWFirst.npsMap) PRE_first_tail_x15_r0.S40.oracle = true

/-- A glue over one more row, of another length. -/
def glueCons {F : Ffi} {r0 : Row} {us : List Row} {A B : Cls.Inst → ICut F} {L : Nat} (p : GluePiece F us A B)
    (hc : goodLin r0.ps (varsOf r0.V p.m) p.O = true) (hA : Pinned L A) (hr : RowsOff L [r0]) : GluePiece F (r0 :: us) A B where
  m := p.m
  n := p.n
  O := p.O
  chk r h := by
    rcases List.mem_cons.mp h with rfl | h
    · exact hc
    · exact p.chk r h
  ok r h i hi ho := by
    rcases List.mem_cons.mp h with rfl | h
    · exact stepOff hA (hr _ (List.mem_singleton_self _) i hi) _
    · exact p.ok r h i hi ho

theorem rowsSetupVW : ∀ r ∈ [setup_early.r0, setup_h0.r0], r ∈ FillSetupEarly.setupRows := by
  intro r hr
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl <;> simp [FillSetupEarly.setupRows]

/-- A stage over fewer rows. -/
def stageRestrict {F : Ffi} {us uses : List Row} {obls : List Obl} {A B : Cls.Inst → ICut F} (hs : ∀ r ∈ us, r ∈ uses)
    (p : StagePiece F uses obls A B) : StagePiece F us obls A B where
  m := p.m
  n := p.n
  O := p.O
  chk r h := p.chk r (hs r h)
  ok r h := p.ok r (hs r h)

/-- The first tail's rows up to 224 tokens. -/
theorem sub21 : ∀ r ∈ [first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0], r ∈ VWFirst.firstTailRows := by
  intro r hr
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> simp [VWFirst.firstTailRows]

/-- The rows below ten tokens. -/
theorem lowOff {L : Nat} (hL : 10 ≤ L) {uses : List Row}
    (hu : ∀ r ∈ uses, r ∈ [setup_early.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0,
      first_tail_x4.r0, final_cold.r0]) : RowsOff L uses := by
  intro r hr i hi
  have hm := hu r hr
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hm
  rcases hm with rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals
    obtain ⟨_, x, hx, hq⟩ := hi
    simp only [setup_early.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0,
      final_cold.r0, Lin.InBox, QOk, Inst.get, eval_mk, dot] at hx hq
    omega

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat) (T : Nat) (tk : Nat → Nat)

/-- Up to the first tail's forward: the length, the cold reference, the emitted array, the load's end. -/
def memC (L : Nat) (x : SegInst FF) : Prop :=
  L = π.length ∧ memCold P KR net env π L x ∧ x.M.a 12504 = 12504 ∧ FromLoad T tk x

/-- From the first tail's forward to the final forward's: the reference after the first tail, at the final forward's carriers. -/
def memVWPre (L : Nat) (x : SegInst FF) : Prop :=
  L = π.length ∧ memPre P KR NE net env π (fun _ => Host.Route.Cert.Fin.VW.finCert.ps) L x ∧ x.M.a 12504 = 12504 ∧
    FromLoad T tk x

variable {P KR NE net env π T tk}

theorem memC_keep {L : Nat} {x y : SegInst FF} (h : NTrack x y) (hm : memC P KR net env π T tk L x) :
    memC P KR net env π T tk L y :=
  ⟨hm.1, memCold_keep L x y h hm.2.1, h.emit.trans hm.2.2.1, hm.2.2.2.grow h.nodes⟩

theorem memVWPre_keep {L : Nat} {x y : SegInst FF} (h : NTrack x y) (hm : memVWPre P KR NE net env π T tk L x) :
    memVWPre P KR NE net env π T tk L y :=
  ⟨hm.1, memPre_keep L x y h hm.2.1, h.emit.trans hm.2.2.1, hm.2.2.2.grow h.nodes⟩

/-- The boot's end, at the prompt. -/
theorem loadVW (leaves : Leaves code env.weights) :
    CutConv (ldPromptCutAt 15235 setupP wideP (ldStT [] []) T tk π (ldStT (π.map natV) (machReads T tk)))
      (withMem (memC P KR net env π T tk π.length) (FillSetupEarly.ldPinCut 15235 T tk π π.length)) := fun x hr hb =>
  have hm := ld_mem P KR net env π leaves (π.map natV) (machReads T tk) hb π.length
  ⟨x, rfl, rfl, hr, ⟨hb.1.1, hb.1.2⟩, rfl, hm.1, hm.2, ld_from π hb⟩

/-- The prefill's invariants of a VW prompt, POST's from its hooks. -/
noncomputable def invsVW {cap nI capC : Nat} {hcapC : capC ≤ 4096 + 1593835520}
    (H : Hooks 15235 T tk π cap nI (classVW 15235 T tk π capC 19057 hcapC)) : PrefInvsW FF :=
  invs H (fun L => withMem (memC P KR net env π T tk L) (FillSetupEarly.ldPinCut 15235 T tk π L))
    (fun L => withMem (memC P KR net env π T tk L) (SetupCommon.nextCut 15235 T tk π L))
    (fun L => FillVW.pfCut 15235 T tk π 70009 (memVWPre P KR NE net env π T tk) L)
    (fun _ _ => noneCut PRE_pl_head.s0)

/-- The final forward's return to VW's sampled cut's start: the entry link, then the head. -/
noncomputable def g3fVW {capC : Nat} (Hn : Nat) (hHn : Hn ≤ 4096) (hcapC : capC ≤ 4096 + 1593835520) (hcapE : 70039 ≤ capC)
    (hbound : capC < Sim.bound) (hL : π.length ≤ 224) (Mf Mem0 : Nat → SegInst FF → Prop)
    (hEnter : ∀ L x y, NTrack x y → VWVals π.length y.ν → Mf L x → Mem0 L y)
    (hKeep : ∀ L x y, NTrackV x y → Mem0 L x → Mem0 L y) :
    GluePiece FF [final_ord.r0] (fun i => withMem (Mf i.L) (FDVW.returnCut 15235 T tk π 70039 Hn 0))
      (fun i => withMem (Mem0 i.L) (indexedCut0 [2823901] 15235 T tk capC 19057 π PRE_plvw_head.s1 PRE_plvw_head.S1)) where
  m := []
  n := PL.VHead.N
  O := []
  chk _ _ := rfl
  ok _ _ i _ _ :=
    (PL.VHead.all 15235 T tk capC 19057 π hcapC (fun _ h => PRE_plvw_head.good h.rowValue) (Mem0 i.L) (hKeep i.L)).convL
      ((FDVW.toEntry hcapE hbound hHn (by decide) hL (hEnter i.L)).trans
        (idxConv PRE_plvw_head.s0_eq PRE_plvw_head.s0_tab))

local notation "M" => memC P KR net env π T tk
local notation "Mp" => memVWPre P KR NE net env π T tk
local notation "Mf" => memFinE P KR NE net env π T tk vwKept (fun _ => 4010)

/-- **The pieces of a VW prompt.** `hEnter`, `hKeep`: `H`'s first bookkeeping, which `hooksVW` has as `memVW0`. -/
noncomputable def piecesVW {cap nI capC : Nat} (hcapC : capC ≤ 4096 + 1593835520) (hcapE : 70039 ≤ capC)
    (hboundC : capC < Sim.bound) (hL10 : 10 ≤ π.length) (hL : π.length ≤ 224)
    (hπ : ∀ k ∈ π, k < 248320) (hlt : ∀ t ∈ π, t < 2 ^ 31)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hpre : ∀ tab, ∃ s, Host.Mlx.SimGraph.Ref.prefillAt P KR NE KR.inPlace net env π tab = some s ∧
      List.Forall₂ (Host.Mlx.SimGraph.Mach.StagePre (π.length - 1))
        (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs)
    (H : Hooks 15235 T tk π cap nI (classVW 15235 T tk π capC 19057 hcapC))
    (hEnter : ∀ L x y, NTrack x y → VWVals π.length y.ν → Mf L x → H.Mem0 L y)
    (hKeep : ∀ L x y, NTrackV x y → H.Mem0 L x → H.Mem0 L y) :
    PiecesR FF (invsVW (P := P) (KR := KR) (NE := NE) (net := net) (env := env) H) := by
  have hM : ∀ L x y, NTrack x y → M L x → M L y := fun _ _ _ h m => memC_keep h m
  have hMp : ∀ L x y, NTrack x y → Mp L x → Mp L y := fun _ _ _ h m => memVWPre_keep h m
  have hPin : ∀ L x, Mp L x → π.length = L := fun _ _ m => m.1.symm
  have pinC : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (SetupCommon.nextCut 15235 T tk π i.L)) :=
    fun _ _ hb => hb.2.1
  have pin0 : Pinned π.length
      (fun i : Cls.Inst => withMem (M i.L) (withSetupPin T tk π (SetupChunk.chunkCallFixedCut 15235 T tk i.L))) :=
    fun _ _ hb => hb.2.1
  have pinD : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (VWFirst.dispatchCut 15235 T tk π i)) :=
    fun _ _ hb => hb.2.1
  have pinG : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (VWFirst.g2Cut 15235 T tk π i)) :=
    fun _ _ hb => hb.2.1
  have pinF : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (VWFirst.forwardCut 15235 T tk π i)) :=
    fun _ _ hb => hb.2.1
  have none0 := noState_none (F := FF) PRE_pl_head.s0
  have hbF : 70009 < Sim.bound := by decide
  have hf15 : FillVW.HFwd (VWFirst.VW15.Sfx.startCore 15235 T tk π) VWFirst.VW15.fwdRows M Mp :=
    fun r hr i hi x y hy hle hg ht he hm =>
      ⟨hm.1, Host.Route.Cert.VW15.hfwd P KR NE net env π leaves typed (fun _ => Host.Route.Cert.Fin.VW.finCert.ps) hlt
        (fun _ _ _ _ => c15.symm) T tk FillVW.tail15 r hr i hi x y hy hle hg ht hm.2.1, he.trans hm.2.2.1, hm.2.2.2.grow hg⟩
  have hf8 : FillVW.HFwd (VWFirst.VW8.Sfx.startCore 15235 T tk π) VWFirst.VW8.fwdRows M Mp :=
    fun r hr i hi x y hy hle hg ht he hm =>
      ⟨hm.1, Host.Route.Cert.VW8.hfwd P KR NE net env π leaves typed (fun _ => Host.Route.Cert.Fin.VW.finCert.ps) hlt
        (fun _ _ _ _ => c8.symm) T tk FillVW.tail8 r hr i hi x y hy hle hg ht hm.2.1, he.trans hm.2.2.1, hm.2.2.2.grow hg⟩
  have hf6 : FillVW.HFwd (VWFirst.VW6.Sfx.startCore 15235 T tk π) VWFirst.VW6.fwdRows M Mp :=
    fun r hr i hi x y hy hle hg ht he hm =>
      ⟨hm.1, Host.Route.Cert.VW6.hfwd P KR NE net env π leaves typed (fun _ => Host.Route.Cert.Fin.VW.finCert.ps) hlt
        (fun _ _ _ _ => c6.symm) T tk FillVW.tail6 r hr i hi x y hy hle hg ht hm.2.1, he.trans hm.2.2.1, hm.2.2.2.grow hg⟩
  have hfin : ∀ i, InRow final_ord.r0 i → ∀ x y : SegInst FF,
      (FDVW.forwardCut 15235 T tk π 70039 1254 0 i).R x (FDVW.forwardCut 15235 T tk π 70039 1254 0 i).s0
        ⟨(FDVW.forwardCut 15235 T tk π 70039 1254 0 i).tab0, []⟩ →
      (FDVW.returnCut 15235 T tk π 70039 1254 0).R y (FDVW.returnCut 15235 T tk π 70039 1254 0).s0
        ⟨(FDVW.returnCut 15235 T tk π 70039 1254 0).tab0, []⟩ →
      (FDVW.returnCut 15235 T tk π 70039 1254 0).B y → NTrack x y → Mp i.L x → Mf i.L y :=
    fun i _ x y _ hy _ htr hm =>
      ⟨Host.Route.Cert.Fin.VW.hfin P KR NE net env leaves typed hpre (by omega) hL (fun _ => Host.Route.Cert.Fin.VW.finCert.ps) rfl
          vwKept Host.Route.Cert.Head.VW.kept_at (fun _ => 4010) rfl (Nat.le_refl _) hy htr i.L
          (memExit_of_pre (by rw [hm.1]; omega) hm.2.1),
        htr.emit.trans hm.2.2.1, hm.2.2.2.grow htr.nodes⟩
  exact
    { cuts :=
        { b_g0a_o := fun i => withMem (M i.L) (withSetupPin T tk π (SetupChunk.chunkCallFixedCut 15235 T tk i.L))
          b_g0b_i := fun i => withMem (M i.L) (SetupCommon.cut 15235 T tk π PRE_g0b.s0 PRE_g0b.S0 i)
          b_g1_DTdec_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g1_DTdec_first_o := fun _ => noneCut PRE_pl_head.s0
          b_g1_DTtail_first_i := fun i => withMem (M i.L) (VWFirst.afterNpsCut 15235 T tk π i)
          b_g1_DTtail_first_o := fun i => withMem (M i.L) (VWFirst.dispatchCut 15235 T tk π i)
          b_g1_FIN_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g1_FIN_first_o := fun _ => noneCut PRE_pl_head.s0
          b_g1_FIN_tailed_i := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70021 1254 0 PRE_fd_vw_r0.s2 PRE_fd_vw_r0.S2)
          b_g1_FIN_tailed_o := fun i => withMem (Mp i.L) (FDVW.dispatchCut 15235 T tk π 70021 1254 0 i)
          b_g2_fin_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g2_fin_first_o := fun _ => noneCut PRE_pl_head.s0
          b_g2_fin_tailed_i := fun i => withMem (Mp i.L) (FDVW.g2Cut 15235 T tk π 70039 1254 0 i)
          b_g2_fin_tailed_o := fun i => withMem (Mp i.L) (FDVW.forwardCut 15235 T tk π 70039 1254 0 i)
          b_g2_first_i := fun i => withMem (M i.L) (VWFirst.g2Cut 15235 T tk π i)
          b_g2_first_o := fun i => withMem (M i.L) (VWFirst.forwardCut 15235 T tk π i)
          b_g3d_first_i := fun i => FillVW.pfCut 15235 T tk π 70009 Mp i.L
          b_g3d_first_o := fun i => FillVW.pfCut 15235 T tk π 70009 Mp i.L
          b_g3f_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g3f_tailed_i := fun i => withMem (Mf i.L) (FDVW.returnCut 15235 T tk π 70039 1254 0)
          b_g4_pf_first_i := fun i => FillVW.pfCut 15235 T tk π 70009 Mp i.L }
      q1 :=
        { g0a := glueRestrict rowsSetupVW (FillSetupEarly.g0a 15235 T tk π M hM)
          chunk_K8__g0a__g0b := stageOff pin0 (lowOff hL10 (by simp))
          g0b := glueRestrict rowsSetupVW (FillSetupEarly.g0b 15235 T tk π M hM)
          chunk_K2048__g0a__g0b := SetupH0.chunk_K2048__g0a__g0b 15235 T tk π M hM
          nps_DTdec_first__start__g1_DTdec_first := stageOff pinC (lowOff hL10 (by simp))
          g1_DTdec_first := glueNone none0
          disp_D1__g1_DTdec_first__g2_first := stageNone none0
          g2_first := glueCons (glueRestrict sub21 (VWFirst.g2_first 15235 T tk π M hM)) g2X0 pinG (lowOff hL10 (by simp))
          fwd_D1_cold_DFirst__g2_first__g3d_first := fwdOff pinF (lowOff hL10 (by simp))
          g3d_first := FillVW.gEmpty _ _
          eval__g3d_first__g4_pf_first := FillVW.sEmpty _ _ _
          g4_pf_first := FillVW.gEmpty _ _
          nps_DTtail_first__start__g1_DTtail_first :=
            stageRestrict sub21 (VWFirst.nps_DTtail_first__start__g1_DTtail_first 15235 T tk π M hM)
          g1_DTtail_first := glueRestrict sub21 (VWFirst.g1_DTtail_first 15235 T tk π hπ M hM)
          disp_V23__g1_DTtail_first__g2_first := stageOff pinD (lowOff hL10 (by simp))
          fwd_V23_cold_WFirst__g2_first__g3d_first := fwdOff pinF (lowOff hL10 (by simp))
          disp_V4__g1_DTtail_first__g2_first := stageOff pinD (lowOff hL10 (by simp))
          fwd_V4_cold_WFirst__g2_first__g3d_first := fwdOff pinF (lowOff hL10 (by simp))
          disp_V58__g1_DTtail_first__g2_first := stageOff pinD (lowOff hL10 (by simp))
          fwd_V58f_cold_WFirst__g2_first__g3d_first := fwdOff pinF (lowOff hL10 (by simp))
          fwd_V58d_cold_WFirst__g2_first__g3d_first := fwdOff pinF (lowOff hL10 (by simp))
          disp_VW__g1_DTtail_first__g2_first := VWFirst.disp_VW__g1_DTtail_first__g2_first 15235 T tk π M hM
          fwd_VW_cold_WFirst_p5__g2_first__g3d_first :=
            FillVW.fwd15 15235 T tk π 70009 (Nat.le_refl _) hbF M Mp hMp hf15 (by simp [VWFirst.VW15.fwdRows]) _
          fwd_VW_cold_WFirst_p6__g2_first__g3d_first :=
            FillVW.fwd6 15235 T tk π 70009 (Nat.le_refl _) hbF M Mp hMp hf6 (by simp [VWFirst.VW6.fwdRows]) _
          fwd_VW_cold_WFirst_p7__g2_first__g3d_first :=
            FillVW.fwd15 15235 T tk π 70009 (Nat.le_refl _) hbF M Mp hMp hf15 (by simp [VWFirst.VW15.fwdRows]) _
          fwd_VW_cold_WFirst_p8__g2_first__g3d_first :=
            FillVW.fwd8 15235 T tk π 70009 (Nat.le_refl _) hbF M Mp hMp hf8 (by simp [VWFirst.VW8.fwdRows]) _
          fwd_VW_cold_WFirst_p9__g2_first__g3d_first :=
            FillVW.fwd15 15235 T tk π 70009 (Nat.le_refl _) hbF M Mp hMp hf15 (by simp [VWFirst.VW15.fwdRows]) _
          fwd_VW_cold_WFirst_p10__g2_first__g3d_first :=
            FillVW.fwd8 15235 T tk π 70009 (Nat.le_refl _) hbF M Mp hMp hf8 (by simp [VWFirst.VW8.fwdRows]) _
          fwd_VW_cold_WFirst_p11__g2_first__g3d_first :=
            FillVW.fwd15 15235 T tk π 70009 (Nat.le_refl _) hbF M Mp hMp hf15 (by simp [VWFirst.VW15.fwdRows]) _
          fwd_VW_cold_WFirst_p12__g2_first__g3d_first :=
            FillVW.fwd8 15235 T tk π 70009 (Nat.le_refl _) hbF M Mp hMp hf8 (by simp [VWFirst.VW8.fwdRows]) _
          fwd_VW_cold_WFirst_p13__g2_first__g3d_first :=
            FillVW.fwd15 15235 T tk π 70009 (Nat.le_refl _) hbF M Mp hMp hf15 (by simp [VWFirst.VW15.fwdRows]) _
          fwd_VW_cold_WFirst_p14__g2_first__g3d_first :=
            FillVW.fwd8 15235 T tk π 70009 (Nat.le_refl _) hbF M Mp hMp hf8 (by simp [VWFirst.VW8.fwdRows]) _
          fwd_VW_cold_WFirst_p15__g2_first__g3d_first :=
            FillVW.fwd15 15235 T tk π 70009 (Nat.le_refl _) hbF M Mp hMp hf15 (by simp [VWFirst.VW15.fwdRows]) _
          fwd_VW_cold_WFirst_p16__g2_first__g3d_first :=
            FillVW.fwd8 15235 T tk π 70009 (Nat.le_refl _) hbF M Mp hMp hf8 (by simp [VWFirst.VW8.fwdRows]) _
          fwd_VW_cold_WFirst_p17__g2_first__g3d_first :=
            FillVW.fwd15 15235 T tk π 70009 (Nat.le_refl _) hbF M Mp hMp hf15 (by simp [VWFirst.VW15.fwdRows]) _
          fwd_VW_cold_WFirst_p18__g2_first__g3d_first :=
            FillVW.fwd8 15235 T tk π 70009 (Nat.le_refl _) hbF M Mp hMp hf8 (by simp [VWFirst.VW8.fwdRows]) _
          fwd_VW_cold_WFirst_p19__g2_first__g3d_first :=
            FillVW.fwd15 15235 T tk π 70009 (Nat.le_refl _) hbF M Mp hMp hf15 (by simp [VWFirst.VW15.fwdRows]) _
          fwd_VW_cold_WFirst_p20__g2_first__g3d_first :=
            FillVW.fwd8 15235 T tk π 70009 (Nat.le_refl _) hbF M Mp hMp hf8 (by simp [VWFirst.VW8.fwdRows]) _
          fwd_VW_cold_WFirst_p21__g2_first__g3d_first :=
            FillVW.fwd15 15235 T tk π 70009 (Nat.le_refl _) hbF M Mp hMp hf15 (by simp [VWFirst.VW15.fwdRows]) _
          nps_FIN_first__start__g1_FIN_first := stageOff pinC (lowOff hL10 (by simp))
          g1_FIN_first := glueNone none0
          disp_D1__g1_FIN_first__g2_fin_first := stageNone none0
          g2_fin_first := glueNone none0
          fwd_D1_cold_DFirst__g2_fin_first__g3f_first := fwdNone none0
          g3f_first := glueNone none0
          nps_FIN_tailed__start__g1_FIN_tailed :=
            FDVW.pf_start (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70009) (H := 1254) (N := 0) (Mem := Mp)
              (hMem := hMp) (hPin := hPin) (by decide) (by decide)
          g1_FIN_tailed :=
            FDVW.g1_piece (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70021) (H := 1254) (N := 0) (Mem := Mp)
              (hMem := hMp) (hPin := hPin) (by decide)
          disp_D1__g1_FIN_tailed__g2_fin_tailed :=
            FDVW.disp_piece (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70021) (H := 1254) (N := 0) (Mem := Mp)
              (hMem := hMp) (by decide)
          g2_fin_tailed :=
            FDVW.g2_piece (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70039) (H := 1254) (N := 0) (Mem := Mp)
              (hMem := hMp)
          fwd_D1_dcold_DFit__g2_fin_tailed__g3f_tailed :=
            FDVW.fwd_piece (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70039) (H := 1254) (N := 0) (Mem := Mp)
              Mf _ (by decide) hfin
          g3f_tailed := g3fVW 1254 (by decide) hcapC hcapE hboundC hL Mf H.Mem0 hEnter hKeep }
      eqs := ⟨trivial⟩ }

end

end Host.Ts.Sim.Compose.FillPost

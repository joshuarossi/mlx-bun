import host.sim.compose.a4b.FillOne
import host.sim.compose.a4b.FillD1First
import host.sim.compose.a4b.PiecesOff
import host.sim.compose.a4b.FillSetupH0
import host.sim.compose.a4b.VWFirstRows
import host.route.cert.One.CertF
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.FillPost
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Ts.Sim.Compose.Post Host.Ts.Sim.Compose.Gpu
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route Host.Route.PrefGraph Host.Route.Cert
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # A one-token prompt's prefill

`I` and `PiecesR` at the prompt `[a]`. It runs setup and the first forward; every other row is of another length, or starts from a cut
no state is at. The bookkeeping names the length, so the shared pieces' other rows have nothing to step from. -/

theorem rowsSetup : ∀ r ∈ [setup_early.r0, setup_h0.r0], r ∈ FillSetupEarly.setupRows := by
  intro r hr
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl <;> simp [FillSetupEarly.setupRows]

theorem offH0 : RowsOff 1 [setup_h0.r0] := by
  intro r hr i hi
  obtain rfl := List.mem_singleton.mp hr
  have := (SetupH0.rowFacts hi).1
  omega

theorem offX0 : RowsOff 1 [first_tail_x0.r0] := by
  intro r hr i hi
  obtain rfl := List.mem_singleton.mp hr
  obtain ⟨_, x, hx, hq⟩ := hi
  simp only [first_tail_x0.r0, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
  omega

theorem offXs {uses : List Row} (hu : ∀ r ∈ uses, r ∈ VWFirst.firstTailRows) : RowsOff 1 uses := fun r hr i hi => by
  have := (VWFirst.firstTailFacts (hu r hr) hi).1
  omega

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (a : Nat) (T : Nat) (tk : Nat → Nat)

/-- Up to the first forward's return: the length, the cold reference, the emitted array, the load's end. -/
def memOneC (L : Nat) (x : SegInst FF) : Prop :=
  L = 1 ∧ memCold P KR net env [a] L x ∧ x.M.a 12504 = 12504 ∧ FromLoad T tk x

variable {P KR NE net env a T tk}

theorem memOneC_keep {L : Nat} {x y : SegInst FF} (h : NTrack x y) (hm : memOneC P KR net env a T tk L x) :
    memOneC P KR net env a T tk L y :=
  ⟨hm.1, memCold_keep L x y h hm.2.1, h.emit.trans hm.2.2.1, hm.2.2.2.grow h.nodes⟩

theorem memOneC_wit {L : Nat} {x y : SegInst FF} (ht : y.t = x.t) (hC : y.C = x.C) (he : y.M.a 12504 = x.M.a 12504)
    (hm : memOneC P KR net env a T tk L x) : memOneC P KR net env a T tk L y := by
  refine ⟨hm.1, memCold_wit L x y ht hC hm.2.1, he.trans hm.2.2.1, ?_⟩
  have h := hm.2.2.2
  unfold FromLoad at h ⊢
  rw [ht]
  exact h

variable {NB cap : Nat} {Kept : Nat → List (Nat × Nat)} {Kn : Nat → Nat}

local notation "M" => memOneC P KR net env a T tk
local notation "Mf" => memFinE P KR NE net env [a] T tk Kept Kn

/-- The prefill's invariants of the prompt `[a]`, POST's from its hooks. -/
noncomputable def invsOne {hcap : cap ≤ 4096 + 1593835520} (H : Hooks NB T tk [a] cap 15235 (classOne NB T tk [a] cap 15235 hcap)) : PrefInvsW FF :=
  invs H (fun L => withMem (M L) (FillSetupEarly.ldPinCut NB T tk [a] L))
    (fun L => withMem (M L) (SetupCommon.nextCut NB T tk [a] L))
    (fun _ => noneCut PRE_pl_head.s0) (fun _ _ => noneCut PRE_pl_head.s0)

end

section
variable {C : M1Max.Contract} {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
  {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {a T : Nat} {tk : Nat → Nat}
  {NB cap : Nat} {Kept : Nat → List (Nat × Nat)} {Kn : Nat → Nat}

local notation "M" => memOneC P KR net env a T tk
local notation "Mf" => memFinE P KR NE net env [a] T tk Kept Kn

/-- **The pieces of the prompt `[a]`.** `hEnter`, `hKeep`: `H`'s first bookkeeping, which `hooksOne` has as `memOne0`. -/
noncomputable def piecesOne (hcap : 4096 ≤ cap) (hcap2 : cap ≤ 4096 + 1593835520) (ha : a < 248320)
    (H : Hooks NB T tk [a] cap 15235 (classOne NB T tk [a] cap 15235 hcap2))
    (hEnter : ∀ L x y, NTrack x y → ShortVals y.ν → Mf L x → H.Mem0 L y)
    (hKeep : ∀ L x y, NTrackV x y → H.Mem0 L x → H.Mem0 L y)
    (hfin : ∀ x y : SegInst FF, (D1First.returnedPromptCut NB T tk [a]).R y D1Body.s155 ⟨D1Body.S155.tab, []⟩ →
      (D1First.returnedPromptCut NB T tk [a]).B y → CSrv.Le x.C y.C →
      Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens →
      memCold P KR net env [a] 1 x → memFin P KR NE net env [a] Kept Kn 1 y) :
    PiecesR FF (invsOne (hcap := hcap2) H) := by
  have hM : ∀ L x y, NTrack x y → M L x → M L y := fun _ _ _ h m => memOneC_keep h m
  have hWit : ∀ L x y, y.t = x.t → y.C = x.C → y.M.a 12504 = x.M.a 12504 → M L x → M L y :=
    fun _ _ _ ht hC he m => memOneC_wit ht hC he m
  have hfinal : ∀ x y : SegInst FF, (D1First.returnedPromptCut NB T tk [a]).R y (D1First.returnedPromptCut NB T tk [a]).s0
      ⟨(D1First.returnedPromptCut NB T tk [a]).tab0, []⟩ → (D1First.returnedPromptCut NB T tk [a]).B y → CSrv.Le x.C y.C →
      Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens →
      y.M.a 12504 = x.M.a 12504 → M 1 x → Mf 1 y :=
    fun x y hy hb hle hg ht he m => ⟨hfin x y hy hb hle hg ht m.2.1, he.trans m.2.2.1, m.2.2.2.grow hg⟩
  have hπ : ∀ k ∈ [a], k < 248320 := by
    intro k hk
    obtain rfl := List.mem_singleton.mp hk
    exact ha
  have pinC : Pinned 1 (fun i : Cls.Inst => withMem (M i.L) (SetupCommon.nextCut NB T tk [a] i.L)) := fun _ _ hb => hb.2.1
  have pin0 : Pinned 1 (fun i : Cls.Inst => withMem (M i.L) (withSetupPin T tk [a] (SetupChunk.chunkCallFixedCut NB T tk i.L))) :=
    fun _ _ hb => hb.2.1
  have none0 := noState_none (F := FF) PRE_pl_head.s0
  exact
    { cuts :=
        { b_g0a_o := fun i => withMem (M i.L) (withSetupPin T tk [a] (SetupChunk.chunkCallFixedCut NB T tk i.L))
          b_g0b_i := fun i => withMem (M i.L) (SetupCommon.cut NB T tk [a] PRE_g0b.s0 PRE_g0b.S0 i)
          b_g1_DTdec_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g1_DTdec_first_o := fun _ => noneCut PRE_pl_head.s0
          b_g1_DTtail_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g1_DTtail_first_o := fun _ => noneCut PRE_pl_head.s0
          b_g1_FIN_first_i := fun _ => D1First.g1Cut NB T tk [a] M
          b_g1_FIN_first_o := fun _ => D1First.dispatchCut NB T tk [a] M
          b_g1_FIN_tailed_i := fun _ => noneCut PRE_pl_head.s0
          b_g1_FIN_tailed_o := fun _ => noneCut PRE_pl_head.s0
          b_g2_fin_first_i := fun _ => D1First.g2Cut NB T tk [a] M
          b_g2_fin_first_o := fun _ => D1First.forwardCut NB T tk [a] M
          b_g2_fin_tailed_i := fun _ => noneCut PRE_pl_head.s0
          b_g2_fin_tailed_o := fun _ => noneCut PRE_pl_head.s0
          b_g2_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g2_first_o := fun _ => noneCut PRE_pl_head.s0
          b_g3d_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g3d_first_o := fun _ => noneCut PRE_pl_head.s0
          b_g3f_first_i := fun _ => withMem (Mf 1) (D1First.returnedPromptCut NB T tk [a])
          b_g3f_tailed_i := fun _ => noneCut PRE_pl_head.s0
          b_g4_pf_first_i := fun _ => noneCut PRE_pl_head.s0 }
      q1 :=
        { g0a := (FillSetupEarly.g0a NB T tk [a] M hM).restrict rowsSetup
          chunk_K8__g0a__g0b := FillSetupEarly.chunk_K8__g0a__g0b NB T tk [a] M hM
          g0b := (FillSetupEarly.g0b NB T tk [a] M hM).restrict rowsSetup
          chunk_K2048__g0a__g0b := stageOff pin0 offH0
          nps_DTdec_first__start__g1_DTdec_first := stageOff pinC offX0
          g1_DTdec_first := glueNone none0
          disp_D1__g1_DTdec_first__g2_first := stageNone none0
          g2_first := glueNone none0
          fwd_D1_cold_DFirst__g2_first__g3d_first := fwdNone none0
          g3d_first := glueNone none0
          eval__g3d_first__g4_pf_first := stageNone none0
          g4_pf_first := glueNone none0
          nps_DTtail_first__start__g1_DTtail_first := stageOff pinC (offXs fun _ h => h)
          g1_DTtail_first := glueNone none0
          disp_V23__g1_DTtail_first__g2_first := stageNone none0
          fwd_V23_cold_WFirst__g2_first__g3d_first := fwdNone none0
          disp_V4__g1_DTtail_first__g2_first := stageNone none0
          fwd_V4_cold_WFirst__g2_first__g3d_first := fwdNone none0
          disp_V58__g1_DTtail_first__g2_first := stageNone none0
          fwd_V58f_cold_WFirst__g2_first__g3d_first := fwdNone none0
          fwd_V58d_cold_WFirst__g2_first__g3d_first := fwdNone none0
          disp_VW__g1_DTtail_first__g2_first := stageNone none0
          fwd_VW_cold_WFirst_p5__g2_first__g3d_first := fwdNone none0
          fwd_VW_cold_WFirst_p6__g2_first__g3d_first := fwdNone none0
          fwd_VW_cold_WFirst_p7__g2_first__g3d_first := fwdNone none0
          fwd_VW_cold_WFirst_p8__g2_first__g3d_first := fwdNone none0
          fwd_VW_cold_WFirst_p9__g2_first__g3d_first := fwdNone none0
          fwd_VW_cold_WFirst_p10__g2_first__g3d_first := fwdNone none0
          fwd_VW_cold_WFirst_p11__g2_first__g3d_first := fwdNone none0
          fwd_VW_cold_WFirst_p12__g2_first__g3d_first := fwdNone none0
          fwd_VW_cold_WFirst_p13__g2_first__g3d_first := fwdNone none0
          fwd_VW_cold_WFirst_p14__g2_first__g3d_first := fwdNone none0
          fwd_VW_cold_WFirst_p15__g2_first__g3d_first := fwdNone none0
          fwd_VW_cold_WFirst_p16__g2_first__g3d_first := fwdNone none0
          fwd_VW_cold_WFirst_p17__g2_first__g3d_first := fwdNone none0
          fwd_VW_cold_WFirst_p18__g2_first__g3d_first := fwdNone none0
          fwd_VW_cold_WFirst_p19__g2_first__g3d_first := fwdNone none0
          fwd_VW_cold_WFirst_p20__g2_first__g3d_first := fwdNone none0
          fwd_VW_cold_WFirst_p21__g2_first__g3d_first := fwdNone none0
          nps_FIN_first__start__g1_FIN_first := D1First.nps_FIN_first__start__g1_FIN_first NB T tk [a] M hM
          g1_FIN_first := D1First.g1_FIN_first NB T tk [a] M hM
          disp_D1__g1_FIN_first__g2_fin_first := D1First.disp_D1__g1_FIN_first__g2_fin_first NB T tk [a] M hM
          g2_fin_first := D1First.g2_fin_first NB T tk [a] M hM
          fwd_D1_cold_DFirst__g2_fin_first__g3f_first := D1First.fwd_D1_cold_DFirst__g2_fin_first__g3f_first NB T tk [a] M Mf hWit hfinal
          g3f_first := D1First.g3f_first NB T tk [a] hπ cap hcap hcap2 Mf H.Mem0 hEnter hKeep
          nps_FIN_tailed__start__g1_FIN_tailed := stageNone none0
          g1_FIN_tailed := glueNone none0
          disp_D1__g1_FIN_tailed__g2_fin_tailed := stageNone none0
          g2_fin_tailed := glueNone none0
          fwd_D1_dcold_DFit__g2_fin_tailed__g3f_tailed := fwdNone none0
          g3f_tailed := glueNone none0 }
      eqs := ⟨trivial⟩ }

/-- The forward's graph, for `piecesOne`. -/
theorem hfinCold (Cr : Nat → List (Option Nat × Option Nat)) (hKept : Kept 1 = oneKept) (hKn : Kn 1 = 4010) (ha : a < 248320) (hNB : 15235 ≤ NB)
    (x y : SegInst FF) (hy : (D1First.returnedPromptCut NB T tk [a]).R y D1Body.s155 ⟨D1Body.S155.tab, []⟩)
    (hb : (D1First.returnedPromptCut NB T tk [a]).B y) (hle : CSrv.Le x.C y.C)
    (hg : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi)) (ht : (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens)
    (m : memCold P KR net env [a] 1 x) : memFin P KR NE net env [a] Kept Kn 1 y :=
  One.hfin P KR NE net env a Cr Kept hKept Kn hKn ha hNB hy hb hle hg ht 1 (memExit_of_cold rfl m)

end

end Host.Ts.Sim.Compose.FillPost

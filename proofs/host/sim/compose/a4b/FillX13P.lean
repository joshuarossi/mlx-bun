import host.sim.compose.a4b.FillVWP
import host.sim.compose.a4b.x1.Dispatch
import host.sim.compose.a4b.x1.sfx.VWFwdPf
import host.route.cert.X1.Fwd
import host.sim.compose.a4b.x2.Dispatch
import host.sim.compose.a4b.x2.sfx.VWFwdPf
import host.route.cert.X2.Fwd
import host.sim.compose.a4b.x3.Dispatch
import host.sim.compose.a4b.x3.sfx.VWFwdPf
import host.route.cert.X3.Fwd
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

/-! # The prompts of 3 to 6 tokens

The x1, x2 and x3 classes: setup at the short chunk, their own first tail to VW's pre-final cut, then VW's final forward and POST
(`piecesVW`'s). The shared first-tail glue runs one class's template, the other rows being of other lengths. -/

/-- A glue over more rows, the added ones of another length. -/
def glueWith {F : Ffi} {us us' : List Row} {A B : Cls.Inst → ICut F} {L : Nat} (p : GluePiece F us A B)
    (hchk : ∀ r ∈ us', goodLin r.ps (varsOf r.V p.m) p.O = true) (hA : Pinned L A)
    (h : ∀ r ∈ us', r ∈ us ∨ ∀ i, InRow r i → i.L ≠ L) : GluePiece F us' A B where
  m := p.m
  n := p.n
  O := p.O
  chk := hchk
  ok r hr i hi ho := (h r hr).elim (fun h' => p.ok r h' i hi ho) (fun h' => stepOff hA (h' i hi) _)

/-- A stage over more rows, the added ones of another length. -/
def stageWith {F : Ffi} {us us' : List Row} {obls : List Obl} {A B : Cls.Inst → ICut F} {L : Nat}
    (p : StagePiece F us obls A B) (hchk : ∀ r ∈ us', goodLin r.ps (varsOf r.V p.m) p.O = true) (hA : Pinned L A)
    (h : ∀ r ∈ us', r ∈ us ∨ ∀ i, InRow r i → i.L ≠ L) : StagePiece F us' obls A B where
  m := p.m
  n := p.n
  O := p.O
  chk := hchk
  ok r hr i hi ho := (h r hr).elim (fun h' => p.ok r h' i hi ho)
    (fun h' => StageCall.intro (CutConv.refl _) (stepOff hA (h' i hi) _) (CutConv.refl _))

/-- A glue over one row's template. -/
def glueOne {F : Ffi} {r0 : Row} {A B : Cls.Inst → ICut F} (m : List (Nat × Q)) (O : List Ans) (n : Nat)
    (hchk : goodLin r0.ps (varsOf r0.V m) O = true)
    (hstep : ∀ i, InRow r0 i → OblOk i [⟨m, O⟩] → CutStep (A i) (B i) n) : GluePiece F [r0] A B where
  m := m
  n := n
  O := O
  chk r hr := by obtain rfl := List.mem_singleton.mp hr; exact hchk
  ok r hr i hi ho := by obtain rfl := List.mem_singleton.mp hr; exact hstep i hi ho

section X1

kernel_rfl c1Cr : Host.Route.Cert.X1.cert.carriers = Host.Route.Cert.Fin.VW.finCert.ps
kernel_rfl g2Chk1 : ([first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0].all fun r => goodLin r.ps (varsOf r.V VWFirst.X1.npsMap)
  PRE_first_tail_x1_r0.S40.oracle) = true

/-- The first tail's rows, but x1's, are of another length. -/
theorem g2Own1 {L : Nat} (h1 : 3 ≤ L) (h2 : L ≤ 4) :
    ∀ r ∈ [first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0], r ∈ [first_tail_x1.r0] ∨ ∀ i, InRow r i → i.L ≠ L := by
  intro r hr
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals first
    | exact .inl (List.mem_singleton_self _)
    | (refine .inr fun i hi => ?_
       obtain ⟨_, x, hx, hq⟩ := hi
       simp only [setup_early.r0, setup_h0.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, final_cold.r0, Lin.InBox, QOk, Inst.get, eval_mk, dot] at hx hq
       omega)

/-- The rows x1's prompts don't reach. -/
theorem off1 {L : Nat} (h1 : 3 ≤ L) (h2 : L ≤ 4) {uses : List Row}
    (hu : ∀ r ∈ uses, r ∈ [setup_h0.r0, first_tail_x0.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, final_cold.r0]) :
    RowsOff L uses := by
  intro r hr i hi
  have hm := hu r hr
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hm
  rcases hm with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals
    obtain ⟨_, x, hx, hq⟩ := hi
    simp only [setup_early.r0, setup_h0.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, final_cold.r0, Lin.InBox, QOk, Inst.get, eval_mk, dot] at hx hq
    omega

section
variable {C : M1Max.Contract} {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
  {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat} {T : Nat} {tk : Nat → Nat}

local notation "M" => memC P KR net env π T tk
local notation "Mp" => memVWPre P KR NE net env π T tk
local notation "Mf" => memFinE P KR NE net env π T tk vwKept (fun _ => 4010)

/-- The prefill's invariants of an x1 prompt, POST's from its hooks. -/
noncomputable def invsX1 {cap nI capC : Nat} {hcapC : capC ≤ 4096 + 1593835520}
    (H : Hooks 15235 T tk π cap nI (classVW 15235 T tk π capC 19057 hcapC)) : PrefInvsW FF :=
  invs H (fun L => withMem (M L) (FillSetupEarly.ldPinCut 15235 T tk π L))
    (fun L => withMem (M L) (SetupCommon.nextCut 15235 T tk π L))
    (fun L => withMem (Mp L) (Pf.cut 15235 T tk π 70009 1257 0 PRE_pf_vw.s0 PRE_pf_vw.S0))
    (fun _ _ => noneCut PRE_pl_head.s0)

/-- **The pieces of an x1 prompt.** `hEnter`, `hKeep`: `H`'s first bookkeeping, which `hooksVW` has as `memVW0`. -/
noncomputable def piecesX1 {cap nI capC : Nat} (hcapC : capC ≤ 4096 + 1593835520) (hcapE : 70039 ≤ capC)
    (hboundC : capC < Sim.bound) (hL1 : 3 ≤ π.length) (hL2 : π.length ≤ 4)
    (hπ : ∀ k ∈ π, k < 248320) (hlt : ∀ t ∈ π, t < 2 ^ 31)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hpre : ∀ tab, ∃ s, Host.Mlx.SimGraph.Ref.prefillAt P KR NE KR.inPlace net env π tab = some s ∧
      List.Forall₂ (Host.Mlx.SimGraph.Mach.StagePre (π.length - 1))
        (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs)
    (H : Hooks 15235 T tk π cap nI (classVW 15235 T tk π capC 19057 hcapC))
    (hEnter : ∀ L x y, NTrack x y → VWVals π.length y.ν → Mf L x → H.Mem0 L y)
    (hKeep : ∀ L x y, NTrackV x y → H.Mem0 L x → H.Mem0 L y) :
    PiecesR FF (invsX1 (P := P) (KR := KR) (NE := NE) (net := net) (env := env) H) := by
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
  have pinG : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (VWFirst.X1.g2Cut 15235 T tk π i)) :=
    fun _ _ hb => hb.2.1
  have pinF : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (VWFirst.X1.forwardCut 15235 T tk π i)) :=
    fun _ _ hb => hb.2.1
  have none0 := noState_none (F := FF) PRE_pl_head.s0
  have hbF : 70009 < Sim.bound := by decide
  have hn : ∀ r ∈ VWFirst.X1.fwdClassRows, ∀ i, InRow r i → i.n ≤ 2 ^ 20 := fun r hr i hi => by
    obtain rfl := List.mem_singleton.mp hr
    have h := VWFirst.firstTailFacts (r := first_tail_x1.r0) (by simp [VWFirst.firstTailRows]) hi
    have h' : i.n ≤ 2048 := by omega
    exact Nat.le_trans h' (by decide)
  have hf : ∀ r ∈ [first_tail_x1.r0], ∀ i, InRow r i → ∀ x y : SegInst FF,
      (VWFirst.X1.Sfx.startCore 15235 T tk π i).R y (VWFirst.X1.Sfx.startCore 15235 T tk π i).s0
        ⟨(VWFirst.X1.Sfx.startCore 15235 T tk π i).tab0, []⟩ →
      CSrv.Le x.C y.C → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) →
      (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens → y.M.a 12504 = x.M.a 12504 → M i.L x → Mp i.L y :=
    fun r hr i hi x y hy hle hg ht he hm =>
      ⟨hm.1, Host.Route.Cert.X1.hfwd P KR NE net env π leaves typed (fun _ => Host.Route.Cert.Fin.VW.finCert.ps) hlt
        (fun _ _ _ _ => c1Cr.symm) T tk (fun r h => by obtain rfl := List.mem_singleton.mp h; simp [VWFirst.firstTailRows])
        r (by obtain rfl := List.mem_singleton.mp hr; simp [VWFirst.X1.fwdClassRows]) i hi x y hy hle hg ht hm.2.1,
        he.trans hm.2.2.1, hm.2.2.2.grow hg⟩
  have hfin : ∀ i, InRow final_ord.r0 i → ∀ x y : SegInst FF,
      (FDVW.forwardCut 15235 T tk π 70039 1257 0 i).R x (FDVW.forwardCut 15235 T tk π 70039 1257 0 i).s0
        ⟨(FDVW.forwardCut 15235 T tk π 70039 1257 0 i).tab0, []⟩ →
      (FDVW.returnCut 15235 T tk π 70039 1257 0).R y (FDVW.returnCut 15235 T tk π 70039 1257 0).s0
        ⟨(FDVW.returnCut 15235 T tk π 70039 1257 0).tab0, []⟩ →
      (FDVW.returnCut 15235 T tk π 70039 1257 0).B y → NTrack x y → Mp i.L x → Mf i.L y :=
    fun i _ x y _ hy _ htr hm =>
      ⟨Host.Route.Cert.Fin.VW.hfin P KR NE net env leaves typed hpre (by omega) (by omega)
          (fun _ => Host.Route.Cert.Fin.VW.finCert.ps) rfl vwKept Host.Route.Cert.Head.VW.kept_at (fun _ => 4010) rfl (Nat.le_refl _) hy htr i.L
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
          b_g1_FIN_tailed_i := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70021 1257 0 PRE_fd_vw_r0.s2 PRE_fd_vw_r0.S2)
          b_g1_FIN_tailed_o := fun i => withMem (Mp i.L) (FDVW.dispatchCut 15235 T tk π 70021 1257 0 i)
          b_g2_fin_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g2_fin_first_o := fun _ => noneCut PRE_pl_head.s0
          b_g2_fin_tailed_i := fun i => withMem (Mp i.L) (FDVW.g2Cut 15235 T tk π 70039 1257 0 i)
          b_g2_fin_tailed_o := fun i => withMem (Mp i.L) (FDVW.forwardCut 15235 T tk π 70039 1257 0 i)
          b_g2_first_i := fun i => withMem (M i.L) (VWFirst.X1.g2Cut 15235 T tk π i)
          b_g2_first_o := fun i => withMem (M i.L) (VWFirst.X1.forwardCut 15235 T tk π i)
          b_g3d_first_i := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70009 1257 0 PRE_pf_vw.s0 PRE_pf_vw.S0)
          b_g3d_first_o := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70009 1257 0 PRE_pf_vw.s0 PRE_pf_vw.S0)
          b_g3f_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g3f_tailed_i := fun i => withMem (Mf i.L) (FDVW.returnCut 15235 T tk π 70039 1257 0)
          b_g4_pf_first_i := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70009 1257 0 PRE_pf_vw.s0 PRE_pf_vw.S0) }
      q1 :=
        { g0a := glueRestrict rowsSetupVW (FillSetupEarly.g0a 15235 T tk π M hM)
          chunk_K8__g0a__g0b := FillSetupEarly.chunk_K8__g0a__g0b 15235 T tk π M hM
          g0b := glueRestrict rowsSetupVW (FillSetupEarly.g0b 15235 T tk π M hM)
          chunk_K2048__g0a__g0b := stageOff pin0 (off1 hL1 hL2 (by simp))
          nps_DTdec_first__start__g1_DTdec_first := stageOff pinC (off1 hL1 hL2 (by simp))
          g1_DTdec_first := glueNone none0
          disp_D1__g1_DTdec_first__g2_first := stageNone none0
          g2_first := glueWith (glueOne (r0 := first_tail_x1.r0) VWFirst.X1.npsMap PRE_first_tail_x1_r0.S40.oracle 7
              (List.all_eq_true.mp g2Chk1 _ (by simp)) (fun i _ ho => VWFirst.X1.g2 15235 T tk π i (hM i.L) ho.1))
            (fun r hr => List.all_eq_true.mp g2Chk1 r hr) pinG (g2Own1 hL1 hL2)
          fwd_D1_cold_DFirst__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          g3d_first := FillVW.gEmpty _ _
          eval__g3d_first__g4_pf_first := FillVW.sEmpty _ _ _
          g4_pf_first := FillVW.gEmpty _ _
          nps_DTtail_first__start__g1_DTtail_first :=
            stageRestrict sub21 (VWFirst.nps_DTtail_first__start__g1_DTtail_first 15235 T tk π M hM)
          g1_DTtail_first := glueRestrict sub21 (VWFirst.g1_DTtail_first 15235 T tk π hπ M hM)
          disp_V23__g1_DTtail_first__g2_first := VWFirst.X1.disp_V23__g1_DTtail_first__g2_first 15235 T tk π M hM hn
          disp_V4__g1_DTtail_first__g2_first := stageOff pinD (off1 hL1 hL2 (by simp))
          disp_V58__g1_DTtail_first__g2_first := stageOff pinD (off1 hL1 hL2 (by simp))
          fwd_V23_cold_WFirst__g2_first__g3d_first := VWFirst.X1.Sfx.fwdPf 15235 T tk π 70009 (by decide) hbF [first_tail_x1.r0]
            (fun r h => by obtain rfl := List.mem_singleton.mp h; simp [VWFirst.X1.fwdRows])
            (fun r h => by obtain rfl := List.mem_singleton.mp h; simp [VWFirst.firstTailRows]) _ M Mp hMp hf
          fwd_V4_cold_WFirst__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_V58f_cold_WFirst__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_V58d_cold_WFirst__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          disp_VW__g1_DTtail_first__g2_first := stageOff pinD (off1 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p5__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p6__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p7__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p8__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p9__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p10__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p11__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p12__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p13__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p14__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p15__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p16__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p17__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p18__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p19__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p20__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p21__g2_first__g3d_first := fwdOff pinF (off1 hL1 hL2 (by simp))
          nps_FIN_first__start__g1_FIN_first := stageOff pinC (off1 hL1 hL2 (by simp))
          g1_FIN_first := glueNone none0
          disp_D1__g1_FIN_first__g2_fin_first := stageNone none0
          g2_fin_first := glueNone none0
          fwd_D1_cold_DFirst__g2_fin_first__g3f_first := fwdNone none0
          g3f_first := glueNone none0
          nps_FIN_tailed__start__g1_FIN_tailed :=
            FDVW.pf_start (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70009) (H := 1257) (N := 0) (Mem := Mp)
              (hMem := hMp) (hPin := hPin) (by decide) (by decide)
          g1_FIN_tailed :=
            FDVW.g1_piece (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70021) (H := 1257) (N := 0) (Mem := Mp)
              (hMem := hMp) (hPin := hPin) (by decide)
          disp_D1__g1_FIN_tailed__g2_fin_tailed :=
            FDVW.disp_piece (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70021) (H := 1257) (N := 0) (Mem := Mp)
              (hMem := hMp) (by decide)
          g2_fin_tailed :=
            FDVW.g2_piece (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70039) (H := 1257) (N := 0) (Mem := Mp)
              (hMem := hMp)
          fwd_D1_dcold_DFit__g2_fin_tailed__g3f_tailed :=
            FDVW.fwd_piece (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70039) (H := 1257) (N := 0) (Mem := Mp)
              Mf _ (by decide) hfin
          g3f_tailed := g3fVW 1257 (by decide) hcapC hcapE hboundC (by omega) Mf H.Mem0 hEnter hKeep }
      eqs := ⟨trivial⟩ }

end

end X1

section X2

kernel_rfl c2Cr : Host.Route.Cert.X2.cert.carriers = Host.Route.Cert.Fin.VW.finCert.ps
kernel_rfl g2Chk2 : ([first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0].all fun r => goodLin r.ps (varsOf r.V VWFirst.X2.npsMap)
  PRE_first_tail_x2_r0.S40.oracle) = true

/-- The first tail's rows, but x2's, are of another length. -/
theorem g2Own2 {L : Nat} (h1 : 5 ≤ L) (h2 : L ≤ 5) :
    ∀ r ∈ [first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0], r ∈ [first_tail_x2.r0] ∨ ∀ i, InRow r i → i.L ≠ L := by
  intro r hr
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals first
    | exact .inl (List.mem_singleton_self _)
    | (refine .inr fun i hi => ?_
       obtain ⟨_, x, hx, hq⟩ := hi
       simp only [setup_early.r0, setup_h0.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, final_cold.r0, Lin.InBox, QOk, Inst.get, eval_mk, dot] at hx hq
       omega)

/-- The rows x2's prompts don't reach. -/
theorem off2 {L : Nat} (h1 : 5 ≤ L) (h2 : L ≤ 5) {uses : List Row}
    (hu : ∀ r ∈ uses, r ∈ [setup_h0.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, final_cold.r0]) :
    RowsOff L uses := by
  intro r hr i hi
  have hm := hu r hr
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hm
  rcases hm with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals
    obtain ⟨_, x, hx, hq⟩ := hi
    simp only [setup_early.r0, setup_h0.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, final_cold.r0, Lin.InBox, QOk, Inst.get, eval_mk, dot] at hx hq
    omega

section
variable {C : M1Max.Contract} {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
  {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat} {T : Nat} {tk : Nat → Nat}

local notation "M" => memC P KR net env π T tk
local notation "Mp" => memVWPre P KR NE net env π T tk
local notation "Mf" => memFinE P KR NE net env π T tk vwKept (fun _ => 4010)

/-- The prefill's invariants of an x2 prompt, POST's from its hooks. -/
noncomputable def invsX2 {cap nI capC : Nat} {hcapC : capC ≤ 4096 + 1593835520}
    (H : Hooks 15235 T tk π cap nI (classVW 15235 T tk π capC 19057 hcapC)) : PrefInvsW FF :=
  invs H (fun L => withMem (M L) (FillSetupEarly.ldPinCut 15235 T tk π L))
    (fun L => withMem (M L) (SetupCommon.nextCut 15235 T tk π L))
    (fun L => withMem (Mp L) (Pf.cut 15235 T tk π 70009 1254 0 PRE_pf_vw.s0 PRE_pf_vw.S0))
    (fun _ _ => noneCut PRE_pl_head.s0)

/-- **The pieces of an x2 prompt.** `hEnter`, `hKeep`: `H`'s first bookkeeping, which `hooksVW` has as `memVW0`. -/
noncomputable def piecesX2 {cap nI capC : Nat} (hcapC : capC ≤ 4096 + 1593835520) (hcapE : 70039 ≤ capC)
    (hboundC : capC < Sim.bound) (hL1 : 5 ≤ π.length) (hL2 : π.length ≤ 5)
    (hπ : ∀ k ∈ π, k < 248320) (hlt : ∀ t ∈ π, t < 2 ^ 31)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hpre : ∀ tab, ∃ s, Host.Mlx.SimGraph.Ref.prefillAt P KR NE KR.inPlace net env π tab = some s ∧
      List.Forall₂ (Host.Mlx.SimGraph.Mach.StagePre (π.length - 1))
        (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs)
    (H : Hooks 15235 T tk π cap nI (classVW 15235 T tk π capC 19057 hcapC))
    (hEnter : ∀ L x y, NTrack x y → VWVals π.length y.ν → Mf L x → H.Mem0 L y)
    (hKeep : ∀ L x y, NTrackV x y → H.Mem0 L x → H.Mem0 L y) :
    PiecesR FF (invsX2 (P := P) (KR := KR) (NE := NE) (net := net) (env := env) H) := by
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
  have pinG : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (VWFirst.X2.g2Cut 15235 T tk π i)) :=
    fun _ _ hb => hb.2.1
  have pinF : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (VWFirst.X2.forwardCut 15235 T tk π i)) :=
    fun _ _ hb => hb.2.1
  have none0 := noState_none (F := FF) PRE_pl_head.s0
  have hbF : 70009 < Sim.bound := by decide
  have hn : ∀ r ∈ VWFirst.X2.fwdClassRows, ∀ i, InRow r i → i.n ≤ 2 ^ 20 := fun r hr i hi => by
    obtain rfl := List.mem_singleton.mp hr
    have h := VWFirst.firstTailFacts (r := first_tail_x2.r0) (by simp [VWFirst.firstTailRows]) hi
    have h' : i.n ≤ 2048 := by omega
    exact Nat.le_trans h' (by decide)
  have hf : ∀ r ∈ [first_tail_x2.r0], ∀ i, InRow r i → ∀ x y : SegInst FF,
      (VWFirst.X2.Sfx.startCore 15235 T tk π i).R y (VWFirst.X2.Sfx.startCore 15235 T tk π i).s0
        ⟨(VWFirst.X2.Sfx.startCore 15235 T tk π i).tab0, []⟩ →
      CSrv.Le x.C y.C → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) →
      (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens → y.M.a 12504 = x.M.a 12504 → M i.L x → Mp i.L y :=
    fun r hr i hi x y hy hle hg ht he hm =>
      ⟨hm.1, Host.Route.Cert.X2.hfwd P KR NE net env π leaves typed (fun _ => Host.Route.Cert.Fin.VW.finCert.ps) hlt
        (fun _ _ _ _ => c2Cr.symm) T tk (fun r h => by obtain rfl := List.mem_singleton.mp h; simp [VWFirst.firstTailRows])
        r (by obtain rfl := List.mem_singleton.mp hr; simp [VWFirst.X2.fwdClassRows]) i hi x y hy hle hg ht hm.2.1,
        he.trans hm.2.2.1, hm.2.2.2.grow hg⟩
  have hfin : ∀ i, InRow final_ord.r0 i → ∀ x y : SegInst FF,
      (FDVW.forwardCut 15235 T tk π 70039 1254 0 i).R x (FDVW.forwardCut 15235 T tk π 70039 1254 0 i).s0
        ⟨(FDVW.forwardCut 15235 T tk π 70039 1254 0 i).tab0, []⟩ →
      (FDVW.returnCut 15235 T tk π 70039 1254 0).R y (FDVW.returnCut 15235 T tk π 70039 1254 0).s0
        ⟨(FDVW.returnCut 15235 T tk π 70039 1254 0).tab0, []⟩ →
      (FDVW.returnCut 15235 T tk π 70039 1254 0).B y → NTrack x y → Mp i.L x → Mf i.L y :=
    fun i _ x y _ hy _ htr hm =>
      ⟨Host.Route.Cert.Fin.VW.hfin P KR NE net env leaves typed hpre (by omega) (by omega)
          (fun _ => Host.Route.Cert.Fin.VW.finCert.ps) rfl vwKept Host.Route.Cert.Head.VW.kept_at (fun _ => 4010) rfl (Nat.le_refl _) hy htr i.L
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
          b_g2_first_i := fun i => withMem (M i.L) (VWFirst.X2.g2Cut 15235 T tk π i)
          b_g2_first_o := fun i => withMem (M i.L) (VWFirst.X2.forwardCut 15235 T tk π i)
          b_g3d_first_i := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70009 1254 0 PRE_pf_vw.s0 PRE_pf_vw.S0)
          b_g3d_first_o := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70009 1254 0 PRE_pf_vw.s0 PRE_pf_vw.S0)
          b_g3f_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g3f_tailed_i := fun i => withMem (Mf i.L) (FDVW.returnCut 15235 T tk π 70039 1254 0)
          b_g4_pf_first_i := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70009 1254 0 PRE_pf_vw.s0 PRE_pf_vw.S0) }
      q1 :=
        { g0a := glueRestrict rowsSetupVW (FillSetupEarly.g0a 15235 T tk π M hM)
          chunk_K8__g0a__g0b := FillSetupEarly.chunk_K8__g0a__g0b 15235 T tk π M hM
          g0b := glueRestrict rowsSetupVW (FillSetupEarly.g0b 15235 T tk π M hM)
          chunk_K2048__g0a__g0b := stageOff pin0 (off2 hL1 hL2 (by simp))
          nps_DTdec_first__start__g1_DTdec_first := stageOff pinC (off2 hL1 hL2 (by simp))
          g1_DTdec_first := glueNone none0
          disp_D1__g1_DTdec_first__g2_first := stageNone none0
          g2_first := glueWith (glueOne (r0 := first_tail_x2.r0) VWFirst.X2.npsMap PRE_first_tail_x2_r0.S40.oracle 7
              (List.all_eq_true.mp g2Chk2 _ (by simp)) (fun i _ ho => VWFirst.X2.g2 15235 T tk π i (hM i.L) ho.1))
            (fun r hr => List.all_eq_true.mp g2Chk2 r hr) pinG (g2Own2 hL1 hL2)
          fwd_D1_cold_DFirst__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          g3d_first := FillVW.gEmpty _ _
          eval__g3d_first__g4_pf_first := FillVW.sEmpty _ _ _
          g4_pf_first := FillVW.gEmpty _ _
          nps_DTtail_first__start__g1_DTtail_first :=
            stageRestrict sub21 (VWFirst.nps_DTtail_first__start__g1_DTtail_first 15235 T tk π M hM)
          g1_DTtail_first := glueRestrict sub21 (VWFirst.g1_DTtail_first 15235 T tk π hπ M hM)
          disp_V23__g1_DTtail_first__g2_first := stageOff pinD (off2 hL1 hL2 (by simp))
          disp_V4__g1_DTtail_first__g2_first := VWFirst.X2.disp_V4__g1_DTtail_first__g2_first 15235 T tk π M hM hn
          disp_V58__g1_DTtail_first__g2_first := stageOff pinD (off2 hL1 hL2 (by simp))
          fwd_V23_cold_WFirst__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_V4_cold_WFirst__g2_first__g3d_first := VWFirst.X2.Sfx.fwdPf 15235 T tk π 70009 (by decide) hbF [first_tail_x2.r0]
            (fun r h => by obtain rfl := List.mem_singleton.mp h; simp [VWFirst.X2.fwdRows])
            (fun r h => by obtain rfl := List.mem_singleton.mp h; simp [VWFirst.firstTailRows]) _ M Mp hMp hf
          fwd_V58f_cold_WFirst__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_V58d_cold_WFirst__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          disp_VW__g1_DTtail_first__g2_first := stageOff pinD (off2 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p5__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p6__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p7__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p8__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p9__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p10__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p11__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p12__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p13__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p14__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p15__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p16__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p17__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p18__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p19__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p20__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p21__g2_first__g3d_first := fwdOff pinF (off2 hL1 hL2 (by simp))
          nps_FIN_first__start__g1_FIN_first := stageOff pinC (off2 hL1 hL2 (by simp))
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
          g3f_tailed := g3fVW 1254 (by decide) hcapC hcapE hboundC (by omega) Mf H.Mem0 hEnter hKeep }
      eqs := ⟨trivial⟩ }

end

end X2

section X3

kernel_rfl c3Cr : Host.Route.Cert.X3.cert.carriers = Host.Route.Cert.Fin.VW.finCert.ps
kernel_rfl g2Chk3 : ([first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0].all fun r => goodLin r.ps (varsOf r.V VWFirst.X3.npsMap)
  PRE_first_tail_x3_r0.S40.oracle) = true
kernel_rfl dispChk3 : ([first_tail_x3.r0, first_tail_x4.r0].all fun r => goodLin r.ps (varsOf r.V VWFirst.X3.npsMap)
  PRE_first_tail_x3_r0.st2.S0.oracle) = true

/-- The first tail's rows, but x3's, are of another length. -/
theorem g2Own3 {L : Nat} (h1 : 6 ≤ L) (h2 : L ≤ 6) :
    ∀ r ∈ [first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0], r ∈ [first_tail_x3.r0] ∨ ∀ i, InRow r i → i.L ≠ L := by
  intro r hr
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals first
    | exact .inl (List.mem_singleton_self _)
    | (refine .inr fun i hi => ?_
       obtain ⟨_, x, hx, hq⟩ := hi
       simp only [setup_early.r0, setup_h0.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, final_cold.r0, Lin.InBox, QOk, Inst.get, eval_mk, dot] at hx hq
       omega)

theorem dispOwn3 {L : Nat} (h1 : 6 ≤ L) (h2 : L ≤ 6) :
    ∀ r ∈ [first_tail_x3.r0, first_tail_x4.r0], r ∈ [first_tail_x3.r0] ∨ ∀ i, InRow r i → i.L ≠ L := by
  intro r hr
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl
  all_goals first
    | exact .inl (List.mem_singleton_self _)
    | (refine .inr fun i hi => ?_
       obtain ⟨_, x, hx, hq⟩ := hi
       simp only [setup_early.r0, setup_h0.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, final_cold.r0, Lin.InBox, QOk, Inst.get, eval_mk, dot] at hx hq
       omega)

/-- The rows x3's prompts don't reach. -/
theorem off3 {L : Nat} (h1 : 6 ≤ L) (h2 : L ≤ 6) {uses : List Row}
    (hu : ∀ r ∈ uses, r ∈ [setup_h0.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, final_cold.r0]) :
    RowsOff L uses := by
  intro r hr i hi
  have hm := hu r hr
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hm
  rcases hm with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals
    obtain ⟨_, x, hx, hq⟩ := hi
    simp only [setup_early.r0, setup_h0.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, final_cold.r0, Lin.InBox, QOk, Inst.get, eval_mk, dot] at hx hq
    omega

section
variable {C : M1Max.Contract} {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
  {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat} {T : Nat} {tk : Nat → Nat}

local notation "M" => memC P KR net env π T tk
local notation "Mp" => memVWPre P KR NE net env π T tk
local notation "Mf" => memFinE P KR NE net env π T tk vwKept (fun _ => 4010)

/-- The prefill's invariants of an x3 prompt, POST's from its hooks. -/
noncomputable def invsX3 {cap nI capC : Nat} {hcapC : capC ≤ 4096 + 1593835520}
    (H : Hooks 15235 T tk π cap nI (classVW 15235 T tk π capC 19057 hcapC)) : PrefInvsW FF :=
  invs H (fun L => withMem (M L) (FillSetupEarly.ldPinCut 15235 T tk π L))
    (fun L => withMem (M L) (SetupCommon.nextCut 15235 T tk π L))
    (fun L => withMem (Mp L) (Pf.cut 15235 T tk π 70009 1254 0 PRE_pf_vw.s0 PRE_pf_vw.S0))
    (fun _ _ => noneCut PRE_pl_head.s0)

/-- **The pieces of an x3 prompt.** `hEnter`, `hKeep`: `H`'s first bookkeeping, which `hooksVW` has as `memVW0`. -/
noncomputable def piecesX3 {cap nI capC : Nat} (hcapC : capC ≤ 4096 + 1593835520) (hcapE : 70039 ≤ capC)
    (hboundC : capC < Sim.bound) (hL1 : 6 ≤ π.length) (hL2 : π.length ≤ 6)
    (hπ : ∀ k ∈ π, k < 248320) (hlt : ∀ t ∈ π, t < 2 ^ 31)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hpre : ∀ tab, ∃ s, Host.Mlx.SimGraph.Ref.prefillAt P KR NE KR.inPlace net env π tab = some s ∧
      List.Forall₂ (Host.Mlx.SimGraph.Mach.StagePre (π.length - 1))
        (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs)
    (H : Hooks 15235 T tk π cap nI (classVW 15235 T tk π capC 19057 hcapC))
    (hEnter : ∀ L x y, NTrack x y → VWVals π.length y.ν → Mf L x → H.Mem0 L y)
    (hKeep : ∀ L x y, NTrackV x y → H.Mem0 L x → H.Mem0 L y) :
    PiecesR FF (invsX3 (P := P) (KR := KR) (NE := NE) (net := net) (env := env) H) := by
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
  have pinG : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (VWFirst.X3.g2Cut 15235 T tk π i)) :=
    fun _ _ hb => hb.2.1
  have pinF : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (VWFirst.X3.forwardCut 15235 T tk π i)) :=
    fun _ _ hb => hb.2.1
  have none0 := noState_none (F := FF) PRE_pl_head.s0
  have hbF : 70009 < Sim.bound := by decide
  have hn : ∀ r ∈ VWFirst.X3.fwdClassRows, ∀ i, InRow r i → i.n ≤ 2 ^ 20 := fun r hr i hi => by
    obtain rfl := List.mem_singleton.mp hr
    have h := VWFirst.firstTailFacts (r := first_tail_x3.r0) (by simp [VWFirst.firstTailRows]) hi
    have h' : i.n ≤ 2048 := by omega
    exact Nat.le_trans h' (by decide)
  have hf : ∀ r ∈ [first_tail_x3.r0], ∀ i, InRow r i → ∀ x y : SegInst FF,
      (VWFirst.X3.Sfx.startCore 15235 T tk π i).R y (VWFirst.X3.Sfx.startCore 15235 T tk π i).s0
        ⟨(VWFirst.X3.Sfx.startCore 15235 T tk π i).tab0, []⟩ →
      CSrv.Le x.C y.C → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) →
      (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens → y.M.a 12504 = x.M.a 12504 → M i.L x → Mp i.L y :=
    fun r hr i hi x y hy hle hg ht he hm =>
      ⟨hm.1, Host.Route.Cert.X3.hfwd P KR NE net env π leaves typed (fun _ => Host.Route.Cert.Fin.VW.finCert.ps) hlt
        (fun _ _ _ _ => c3Cr.symm) T tk (fun r h => by obtain rfl := List.mem_singleton.mp h; simp [VWFirst.firstTailRows])
        r (by obtain rfl := List.mem_singleton.mp hr; simp [VWFirst.X3.fwdClassRows]) i hi x y hy hle hg ht hm.2.1,
        he.trans hm.2.2.1, hm.2.2.2.grow hg⟩
  have hfin : ∀ i, InRow final_ord.r0 i → ∀ x y : SegInst FF,
      (FDVW.forwardCut 15235 T tk π 70039 1254 0 i).R x (FDVW.forwardCut 15235 T tk π 70039 1254 0 i).s0
        ⟨(FDVW.forwardCut 15235 T tk π 70039 1254 0 i).tab0, []⟩ →
      (FDVW.returnCut 15235 T tk π 70039 1254 0).R y (FDVW.returnCut 15235 T tk π 70039 1254 0).s0
        ⟨(FDVW.returnCut 15235 T tk π 70039 1254 0).tab0, []⟩ →
      (FDVW.returnCut 15235 T tk π 70039 1254 0).B y → NTrack x y → Mp i.L x → Mf i.L y :=
    fun i _ x y _ hy _ htr hm =>
      ⟨Host.Route.Cert.Fin.VW.hfin P KR NE net env leaves typed hpre (by omega) (by omega)
          (fun _ => Host.Route.Cert.Fin.VW.finCert.ps) rfl vwKept Host.Route.Cert.Head.VW.kept_at (fun _ => 4010) rfl (Nat.le_refl _) hy htr i.L
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
          b_g2_first_i := fun i => withMem (M i.L) (VWFirst.X3.g2Cut 15235 T tk π i)
          b_g2_first_o := fun i => withMem (M i.L) (VWFirst.X3.forwardCut 15235 T tk π i)
          b_g3d_first_i := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70009 1254 0 PRE_pf_vw.s0 PRE_pf_vw.S0)
          b_g3d_first_o := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70009 1254 0 PRE_pf_vw.s0 PRE_pf_vw.S0)
          b_g3f_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g3f_tailed_i := fun i => withMem (Mf i.L) (FDVW.returnCut 15235 T tk π 70039 1254 0)
          b_g4_pf_first_i := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70009 1254 0 PRE_pf_vw.s0 PRE_pf_vw.S0) }
      q1 :=
        { g0a := glueRestrict rowsSetupVW (FillSetupEarly.g0a 15235 T tk π M hM)
          chunk_K8__g0a__g0b := FillSetupEarly.chunk_K8__g0a__g0b 15235 T tk π M hM
          g0b := glueRestrict rowsSetupVW (FillSetupEarly.g0b 15235 T tk π M hM)
          chunk_K2048__g0a__g0b := stageOff pin0 (off3 hL1 hL2 (by simp))
          nps_DTdec_first__start__g1_DTdec_first := stageOff pinC (off3 hL1 hL2 (by simp))
          g1_DTdec_first := glueNone none0
          disp_D1__g1_DTdec_first__g2_first := stageNone none0
          g2_first := glueWith (glueOne (r0 := first_tail_x3.r0) VWFirst.X3.npsMap PRE_first_tail_x3_r0.S40.oracle 7
              (List.all_eq_true.mp g2Chk3 _ (by simp)) (fun i _ ho => VWFirst.X3.g2 15235 T tk π i (hM i.L) ho.1))
            (fun r hr => List.all_eq_true.mp g2Chk3 r hr) pinG (g2Own3 hL1 hL2)
          fwd_D1_cold_DFirst__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          g3d_first := FillVW.gEmpty _ _
          eval__g3d_first__g4_pf_first := FillVW.sEmpty _ _ _
          g4_pf_first := FillVW.gEmpty _ _
          nps_DTtail_first__start__g1_DTtail_first :=
            stageRestrict sub21 (VWFirst.nps_DTtail_first__start__g1_DTtail_first 15235 T tk π M hM)
          g1_DTtail_first := glueRestrict sub21 (VWFirst.g1_DTtail_first 15235 T tk π hπ M hM)
          disp_V23__g1_DTtail_first__g2_first := stageOff pinD (off3 hL1 hL2 (by simp))
          disp_V4__g1_DTtail_first__g2_first := stageOff pinD (off3 hL1 hL2 (by simp))
          disp_V58__g1_DTtail_first__g2_first := stageWith (VWFirst.X3.disp_V58__g1_DTtail_first__g2_first 15235 T tk π M hM hn)
            (fun r hr => List.all_eq_true.mp dispChk3 r hr) pinD (dispOwn3 hL1 hL2)
          fwd_V23_cold_WFirst__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_V4_cold_WFirst__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_V58f_cold_WFirst__g2_first__g3d_first := VWFirst.X3.Sfx.fwdPf 15235 T tk π 70009 (by decide) hbF [first_tail_x3.r0]
            (fun r h => by obtain rfl := List.mem_singleton.mp h; simp [VWFirst.X3.fwdRows])
            (fun r h => by obtain rfl := List.mem_singleton.mp h; simp [VWFirst.firstTailRows]) _ M Mp hMp hf
          fwd_V58d_cold_WFirst__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          disp_VW__g1_DTtail_first__g2_first := stageOff pinD (off3 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p5__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p6__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p7__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p8__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p9__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p10__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p11__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p12__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p13__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p14__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p15__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p16__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p17__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p18__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p19__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p20__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          fwd_VW_cold_WFirst_p21__g2_first__g3d_first := fwdOff pinF (off3 hL1 hL2 (by simp))
          nps_FIN_first__start__g1_FIN_first := stageOff pinC (off3 hL1 hL2 (by simp))
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
          g3f_tailed := g3fVW 1254 (by decide) hcapC hcapE hboundC (by omega) Mf H.Mem0 hEnter hKeep }
      eqs := ⟨trivial⟩ }

end

end X3

end Host.Ts.Sim.Compose.FillPost

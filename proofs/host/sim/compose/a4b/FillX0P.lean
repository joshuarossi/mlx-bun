import host.sim.compose.a4b.FillX13P
import host.sim.compose.a4b.FillX0Hooks
import host.sim.compose.a4b.x0.Pieces
import host.route.cert.Fin.D1X0.Fwd
import host.sim.compose.a4b.fd_x0.Pieces
import host.sim.compose.a4b.fd_x0.Entry
import host.sim.compose.a4b.pl.X0Head.All
import host.sim.template.a4pre_plx0_head.Origin
import host.sim.template.a4pre_plx0_head.Good
import host.route.cert.Fin.X0.Cert
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

/-! # A prompt of 2 tokens

The x0 class: setup at the short chunk, its own first tail to its own pre-final cut, its own final forward
and POST. Every other row is of another length: the bookkeeping names it. The first tail's carriers are the final forward's, the
pre-final and final steps' node maps being the identity. -/

section X0

section
open Host.Route.Cert.Fin in
kernel_rfl c0Cr : (Expected.cacheOutputs.map fun q => (some (certAt D1X0.d1Cert.cert q.1), some (certAt D1X0.d1Cert.cert q.2))) =
  Host.Route.Cert.Fin.X0.finCert.ps
end
kernel_rfl g2Chk0 : ([first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0].all fun r => goodLin r.ps (varsOf r.V VWFirst.X0.npsMap) PRE_first_tail_x0_r0.S40.oracle) = true

/-- The first tail's rows, but x0's, are of another length. -/
theorem g2Own0 {L : Nat} (hL : L = 2) : ∀ r ∈ [first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0], r ∈ [first_tail_x0.r0] ∨ ∀ i, InRow r i → i.L ≠ L := by
  intro r hr
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals first
    | exact .inl (List.mem_singleton_self _)
    | (refine .inr fun i hi => ?_
       obtain ⟨_, x, hx, hq⟩ := hi
       simp only [setup_early.r0, setup_h0.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, final_cold.r0, Lin.InBox, QOk, Inst.get, eval_mk, dot] at hx hq
       omega)

/-- The rows a prompt of 2 tokens doesn't reach. -/
theorem off0 {L : Nat} (hL : L = 2) {uses : List Row} (hu : ∀ r ∈ uses, r ∈ [setup_h0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, final_cold.r0]) : RowsOff L uses := by
  intro r hr i hi
  have hm := hu r hr
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hm
  rcases hm with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals
    obtain ⟨_, x, hx, hq⟩ := hi
    simp only [setup_early.r0, setup_h0.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, final_cold.r0, Lin.InBox, QOk, Inst.get, eval_mk, dot] at hx hq
    omega

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat) (T : Nat) (tk : Nat → Nat)

/-- From the first tail's forward to the final forward's: the reference after the first tail, at the final forward's carriers. -/
def memX0Pre (L : Nat) (x : SegInst FF) : Prop :=
  L = π.length ∧ memPre P KR NE net env π (fun _ => Host.Route.Cert.Fin.X0.finCert.ps) L x ∧ x.M.a 12504 = 12504 ∧ FromLoad T tk x

variable {P KR NE net env π T tk}

theorem memX0Pre_keep {L : Nat} {x y : SegInst FF} (h : NTrack x y) (hm : memX0Pre P KR NE net env π T tk L x) :
    memX0Pre P KR NE net env π T tk L y :=
  ⟨hm.1, memPre_keep L x y h hm.2.1, h.emit.trans hm.2.2.1, hm.2.2.2.grow h.nodes⟩

/-- The prefill's invariants of a prompt of 2 tokens, POST's from its hooks. -/
noncomputable def invsX0 {cap nI capC : Nat} {hcapC : capC ≤ 4096 + 1593835520}
    (H : Hooks 15235 T tk π cap nI (classX0 15235 T tk π capC 17764 hcapC)) : PrefInvsW FF :=
  invs H (fun L => withMem (memC P KR net env π T tk L) (FillSetupEarly.ldPinCut 15235 T tk π L))
    (fun L => withMem (memC P KR net env π T tk L) (SetupCommon.nextCut 15235 T tk π L))
    (fun L => withMem (memX0Pre P KR NE net env π T tk L) (Pf.cut 15235 T tk π 70009 1 0 PRE_pf_x0.s0 PRE_pf_x0.S0))
    (fun _ _ => noneCut PRE_pl_head.s0)

/-- The final forward's return to the class's sampled cut's start: the entry link, then the head. -/
noncomputable def g3fX0 {capC : Nat} (hcapC : capC ≤ 4096 + 1593835520) (hcapE : 70039 ≤ capC)
    (hbound : capC < Sim.bound) (hL : π.length = 2) (Mf Mem0 : Nat → SegInst FF → Prop)
    (hEnter : ∀ L x y, NTrack x y → PinVals 4 4 4 (π.length - 1) y.ν → Mf L x → Mem0 L y)
    (hKeep : ∀ L x y, NTrackV x y → Mem0 L x → Mem0 L y) :
    GluePiece FF [final_ord.r0] (fun i => withMem (Mf i.L) (FDX0.returnCut 15235 T tk π 70039 1 0))
      (fun i => withMem (Mem0 i.L) (indexedCut0 [2826777] 15235 T tk capC 17764 π PRE_plx0_head.s1 PRE_plx0_head.S1)) where
  m := []
  n := PL.X0Head.N
  O := []
  chk _ _ := rfl
  ok _ _ i _ _ :=
    (PL.X0Head.all 15235 T tk capC 17764 π hcapC (fun _ h => PRE_plx0_head.good h.rowValue) (Mem0 i.L) (hKeep i.L)).convL
      ((FDX0.toEntry hcapE hbound (by decide) (by decide) (by omega) (hEnter i.L)).trans
        (idxConv PRE_plx0_head.s0_eq PRE_plx0_head.s0_tab))

local notation "M" => memC P KR net env π T tk
local notation "Mp" => memX0Pre P KR NE net env π T tk
local notation "Mf" => memFinE P KR NE net env π T tk x0Kept (fun _ => 4010)

/-- **The pieces of a prompt of 2 tokens.** `hfin`: the final forward, from what its return knows (route's
`Host.Route.Cert.Fin.X0.hfin` through `memExit_of_pre`). `hEnter`, `hKeep`: `H`'s first bookkeeping, which `hooksX0` has as `memX00`. -/
noncomputable def piecesX0 {cap nI capC : Nat} (hcapC : capC ≤ 4096 + 1593835520) (hcapE : 70039 ≤ capC)
    (hboundC : capC < Sim.bound) (hL : π.length = 2)
    (hπ : ∀ k ∈ π, k < 248320) (hlt : ∀ t ∈ π, t < 2 ^ 31)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hstep : ∀ tab, ∃ t hs', stepTrace P.toMlxContract KR.toKernelContract (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) 0
      (π.getD 0 0) initialHandles = some (t, hs'))
    (hfin : ∀ i, InRow final_ord.r0 i → ∀ x y : SegInst FF,
      (FDX0.forwardCut 15235 T tk π 70039 1 0 i).R x (FDX0.forwardCut 15235 T tk π 70039 1 0 i).s0
        ⟨(FDX0.forwardCut 15235 T tk π 70039 1 0 i).tab0, []⟩ →
      (FDX0.returnCut 15235 T tk π 70039 1 0).R y (FDX0.returnCut 15235 T tk π 70039 1 0).s0
        ⟨(FDX0.returnCut 15235 T tk π 70039 1 0).tab0, []⟩ →
      (FDX0.returnCut 15235 T tk π 70039 1 0).B y → NTrack x y → Mp i.L x → Mf i.L y)
    (H : Hooks 15235 T tk π cap nI (classX0 15235 T tk π capC 17764 hcapC))
    (hEnter : ∀ L x y, NTrack x y → PinVals 4 4 4 (π.length - 1) y.ν → Mf L x → H.Mem0 L y)
    (hKeep : ∀ L x y, NTrackV x y → H.Mem0 L x → H.Mem0 L y) :
    PiecesR FF (invsX0 (P := P) (KR := KR) (NE := NE) (net := net) (env := env) H) := by
  have hM : ∀ L x y, NTrack x y → M L x → M L y := fun _ _ _ h m => memC_keep h m
  have hMp : ∀ L x y, NTrack x y → Mp L x → Mp L y := fun _ _ _ h m => memX0Pre_keep h m
  have hPin : ∀ L x, Mp L x → π.length = L := fun _ _ m => m.1.symm
  have hpinMp : ∀ L x, Mp L x → L = 2 := fun _ _ m => m.1.trans hL
  have pinC : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (SetupCommon.nextCut 15235 T tk π i.L)) :=
    fun _ _ hb => hb.2.1
  have pin0 : Pinned π.length
      (fun i : Cls.Inst => withMem (M i.L) (withSetupPin T tk π (SetupChunk.chunkCallFixedCut 15235 T tk i.L))) :=
    fun _ _ hb => hb.2.1
  have pinG : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (VWFirst.X0.g2Cut 15235 T tk π i)) :=
    fun _ _ hb => hb.2.1
  have pinF : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (VWFirst.X0.forwardCut 15235 T tk π i)) :=
    fun _ _ hb => hb.2.1
  have none0 := noState_none (F := FF) PRE_pl_head.s0
  have hbF : 70009 < Sim.bound := by decide
  have hf : ∀ r ∈ [first_tail_x0.r0], ∀ i, InRow r i → ∀ x y : SegInst FF,
      (VWFirst.X0.Sfx.startCore 15235 T tk π i).R y (VWFirst.X0.Sfx.startCore 15235 T tk π i).s0
        ⟨(VWFirst.X0.Sfx.startCore 15235 T tk π i).tab0, []⟩ →
      CSrv.Le x.C y.C → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) →
      (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens → y.M.a 12504 = x.M.a 12504 → M i.L x → Mp i.L y :=
    fun r hr i hi x y hy hle hg ht he hm =>
      ⟨hm.1, Host.Route.Cert.Fin.D1X0.hfwd P KR NE net env π leaves typed hstep (fun _ => Host.Route.Cert.Fin.X0.finCert.ps) hlt c0Cr.symm hL T tk
        r (by obtain rfl := List.mem_singleton.mp hr; simp [VWFirst.X0.fwdRows]) i hi x y hy hle hg ht hm.2.1,
        he.trans hm.2.2.1, hm.2.2.2.grow hg⟩
  exact
    { cuts :=
        { b_g0a_o := fun i => withMem (M i.L) (withSetupPin T tk π (SetupChunk.chunkCallFixedCut 15235 T tk i.L))
          b_g0b_i := fun i => withMem (M i.L) (SetupCommon.cut 15235 T tk π PRE_g0b.s0 PRE_g0b.S0 i)
          b_g1_DTdec_first_i := fun i => withMem (M i.L) (VWFirst.X0.afterCut 15235 T tk π i)
          b_g1_DTdec_first_o := fun i => withMem (M i.L) (VWFirst.X0.dispatchCut 15235 T tk π i)
          b_g1_DTtail_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g1_DTtail_first_o := fun _ => noneCut PRE_pl_head.s0
          b_g1_FIN_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g1_FIN_first_o := fun _ => noneCut PRE_pl_head.s0
          b_g1_FIN_tailed_i := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70021 1 0 PRE_fd_x0_r0.s2 PRE_fd_x0_r0.S2)
          b_g1_FIN_tailed_o := fun i => withMem (Mp i.L) (FDX0.dispatchCut 15235 T tk π 70021 1 0 i)
          b_g2_fin_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g2_fin_first_o := fun _ => noneCut PRE_pl_head.s0
          b_g2_fin_tailed_i := fun i => withMem (Mp i.L) (FDX0.g2Cut 15235 T tk π 70039 1 0 i)
          b_g2_fin_tailed_o := fun i => withMem (Mp i.L) (FDX0.forwardCut 15235 T tk π 70039 1 0 i)
          b_g2_first_i := fun i => withMem (M i.L) (VWFirst.X0.g2Cut 15235 T tk π i)
          b_g2_first_o := fun i => withMem (M i.L) (VWFirst.X0.forwardCut 15235 T tk π i)
          b_g3d_first_i := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70009 1 0 PRE_pf_x0.s0 PRE_pf_x0.S0)
          b_g3d_first_o := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70009 1 0 PRE_pf_x0.s0 PRE_pf_x0.S0)
          b_g3f_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g3f_tailed_i := fun i => withMem (Mf i.L) (FDX0.returnCut 15235 T tk π 70039 1 0)
          b_g4_pf_first_i := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70009 1 0 PRE_pf_x0.s0 PRE_pf_x0.S0) }
      q1 :=
        { g0a := glueRestrict rowsSetupVW (FillSetupEarly.g0a 15235 T tk π M hM)
          chunk_K8__g0a__g0b := FillSetupEarly.chunk_K8__g0a__g0b 15235 T tk π M hM
          g0b := glueRestrict rowsSetupVW (FillSetupEarly.g0b 15235 T tk π M hM)
          chunk_K2048__g0a__g0b := stageOff pin0 (off0 hL (by simp))
          nps_DTdec_first__start__g1_DTdec_first := VWFirst.X0.nps_DTdec_first__start__g1_DTdec_first 15235 T tk π M hM
          g1_DTdec_first := VWFirst.X0.g1_DTdec_first 15235 T tk π hπ M hM
          disp_D1__g1_DTdec_first__g2_first := VWFirst.X0.disp 15235 T tk π M hM
          g2_first := glueWith (VWFirst.X0.g2_first 15235 T tk π M hM) (fun r hr => List.all_eq_true.mp g2Chk0 r hr) pinG (g2Own0 hL)
          fwd_D1_cold_DFirst__g2_first__g3d_first := VWFirst.X0.fwd_D1_cold_DFirst__g2_first__g3d_first 15235 T tk π 70009 (by decide) hbF M Mp hMp hf
          g3d_first := FillVW.gEmpty _ _
          eval__g3d_first__g4_pf_first := FillVW.sEmpty _ _ _
          g4_pf_first := FillVW.gEmpty _ _
          nps_DTtail_first__start__g1_DTtail_first := stageOff pinC (off0 hL (by simp))
          g1_DTtail_first := glueNone none0
          disp_V23__g1_DTtail_first__g2_first := stageNone none0
          disp_V4__g1_DTtail_first__g2_first := stageNone none0
          disp_V58__g1_DTtail_first__g2_first := stageNone none0
          disp_VW__g1_DTtail_first__g2_first := stageNone none0
          fwd_V23_cold_WFirst__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_V4_cold_WFirst__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_V58f_cold_WFirst__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_V58d_cold_WFirst__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_VW_cold_WFirst_p5__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_VW_cold_WFirst_p6__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_VW_cold_WFirst_p7__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_VW_cold_WFirst_p8__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_VW_cold_WFirst_p9__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_VW_cold_WFirst_p10__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_VW_cold_WFirst_p11__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_VW_cold_WFirst_p12__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_VW_cold_WFirst_p13__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_VW_cold_WFirst_p14__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_VW_cold_WFirst_p15__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_VW_cold_WFirst_p16__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_VW_cold_WFirst_p17__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_VW_cold_WFirst_p18__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_VW_cold_WFirst_p19__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_VW_cold_WFirst_p20__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          fwd_VW_cold_WFirst_p21__g2_first__g3d_first := fwdOff pinF (off0 hL (by simp))
          nps_FIN_first__start__g1_FIN_first := stageOff pinC (off0 hL (by simp))
          g1_FIN_first := glueNone none0
          disp_D1__g1_FIN_first__g2_fin_first := stageNone none0
          g2_fin_first := glueNone none0
          fwd_D1_cold_DFirst__g2_fin_first__g3f_first := fwdNone none0
          g3f_first := glueNone none0
          nps_FIN_tailed__start__g1_FIN_tailed :=
            FDX0.pf_start (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70009) (H := 1) (N := 0) (Mem := Mp)
              (hMem := hMp) (hPin := hPin) (by decide) (by decide)
          g1_FIN_tailed :=
            FDX0.g1_piece (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70021) (H := 1) (N := 0) (Mem := Mp)
              (hMem := hMp) (hPin := hPin) (by decide)
          disp_D1__g1_FIN_tailed__g2_fin_tailed :=
            FDX0.disp_piece (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70021) (H := 1) (N := 0) (Mem := Mp)
              (hMem := hMp) (by decide)
          g2_fin_tailed :=
            FDX0.g2_piece (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70039) (H := 1) (N := 0) (Mem := Mp)
              (hMem := hMp)
          fwd_D1_dcold_DFit__g2_fin_tailed__g3f_tailed :=
            FDX0.fwd_piece (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70039) (H := 1) (N := 0) (Mem := Mp)
              Mf _ (by decide) hpinMp hfin
          g3f_tailed := g3fX0 hcapC hcapE hboundC hL Mf H.Mem0 hEnter hKeep }
      eqs := ⟨trivial⟩ }

end

end X0

end Host.Ts.Sim.Compose.FillPost

import host.sim.compose.a4b.FillX13P
import host.sim.compose.a4b.FillX4L9Hooks
import host.sim.compose.a4b.X4Pieces
import host.route.cert.X4L9.Fwd
import host.sim.compose.a4b.fd_x4_L9.Pieces
import host.sim.compose.a4b.fd_x4_L9.Entry
import host.sim.compose.a4b.pl.X4L9Head.All
import host.sim.template.a4pre_plx4_L9_head.Origin
import host.sim.template.a4pre_plx4_L9_head.Good
import host.route.cert.Fin.X4L9.Hfin
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

/-! # A prompt of 9 tokens

The x4 L9 class: setup at the long chunk, its own first tail to its own pre-final cut, its own final forward
and POST. Every other row is of another length: the bookkeeping names it. The first tail's carriers are the final forward's, the
pre-final and final steps' node maps being the identity. -/

section X4L9

kernel_rfl c4L9Cr : Host.Route.Cert.X4L9.cert.carriers = Host.Route.Cert.Fin.X4L9.finCert.ps
kernel_rfl g1Chk4L9 : ([first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0].all fun r => goodLin r.ps (varsOf r.V VWFirst.X4_L9.npsMap) VWFirst.X4_L9.g1Oracle) = true
kernel_rfl dispChk4L9 : ([first_tail_x3.r0, first_tail_x4.r0].all fun r => goodLin r.ps (varsOf r.V VWFirst.X4_L9.npsMap)
  PRE_first_tail_x4_L9_r0.st2.S0.oracle) = true
kernel_rfl g2Chk4L9 : ([first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0].all fun r => goodLin r.ps (varsOf r.V VWFirst.X4_L9.npsMap) PRE_first_tail_x4_L9_r0.S40.oracle) = true

/-- The first tail's rows past x0, but x4's, are of another length. -/
theorem g1Own4L9 {L : Nat} (hL : L = 9) : ∀ r ∈ [first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0], r ∈ [first_tail_x4.r0] ∨ ∀ i, InRow r i → i.L ≠ L := by
  intro r hr
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals first
    | exact .inl (List.mem_singleton_self _)
    | (refine .inr fun i hi => ?_
       obtain ⟨_, x, hx, hq⟩ := hi
       simp only [setup_early.r0, setup_h0.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, final_cold.r0, Lin.InBox, QOk, Inst.get, eval_mk, dot] at hx hq
       omega)

theorem dispOwn4L9 {L : Nat} (hL : L = 9) :
    ∀ r ∈ [first_tail_x3.r0, first_tail_x4.r0], r ∈ [first_tail_x4.r0] ∨ ∀ i, InRow r i → i.L ≠ L := by
  intro r hr
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl
  all_goals first
    | exact .inl (List.mem_singleton_self _)
    | (refine .inr fun i hi => ?_
       obtain ⟨_, x, hx, hq⟩ := hi
       simp only [setup_early.r0, setup_h0.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, final_cold.r0, Lin.InBox, QOk, Inst.get, eval_mk, dot] at hx hq
       omega)

/-- The first tail's rows, but x4's, are of another length. -/
theorem g2Own4L9 {L : Nat} (hL : L = 9) : ∀ r ∈ [first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0], r ∈ [first_tail_x4.r0] ∨ ∀ i, InRow r i → i.L ≠ L := by
  intro r hr
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals first
    | exact .inl (List.mem_singleton_self _)
    | (refine .inr fun i hi => ?_
       obtain ⟨_, x, hx, hq⟩ := hi
       simp only [setup_early.r0, setup_h0.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, final_cold.r0, Lin.InBox, QOk, Inst.get, eval_mk, dot] at hx hq
       omega)

/-- The rows a prompt of 9 tokens doesn't reach. -/
theorem off4L9 {L : Nat} (hL : L = 9) {uses : List Row} (hu : ∀ r ∈ uses, r ∈ [setup_early.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, final_cold.r0]) : RowsOff L uses := by
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
def memX4L9Pre (L : Nat) (x : SegInst FF) : Prop :=
  L = π.length ∧ memPre P KR NE net env π (fun _ => Host.Route.Cert.Fin.X4L9.finCert.ps) L x ∧ x.M.a 12504 = 12504 ∧ FromLoad T tk x

variable {P KR NE net env π T tk}

theorem memX4L9Pre_keep {L : Nat} {x y : SegInst FF} (h : NTrack x y) (hm : memX4L9Pre P KR NE net env π T tk L x) :
    memX4L9Pre P KR NE net env π T tk L y :=
  ⟨hm.1, memPre_keep L x y h hm.2.1, h.emit.trans hm.2.2.1, hm.2.2.2.grow h.nodes⟩

/-- The prefill's invariants of a prompt of 9 tokens, POST's from its hooks. -/
noncomputable def invsX4L9 {cap nI capC : Nat} {hcapC : capC ≤ 4096 + 1593835520}
    (H : Hooks 15235 T tk π cap nI (classX4L9 15235 T tk π capC 19265 hcapC)) : PrefInvsW FF :=
  invs H (fun L => withMem (memC P KR net env π T tk L) (FillSetupEarly.ldPinCut 15235 T tk π L))
    (fun L => withMem (memC P KR net env π T tk L) (SetupCommon.nextCut 15235 T tk π L))
    (fun L => withMem (memX4L9Pre P KR NE net env π T tk L) (Pf.cut 15235 T tk π 70009 1254 0 PRE_pf_x4_L9.s0 PRE_pf_x4_L9.S0))
    (fun _ _ => noneCut PRE_pl_head.s0)

/-- The final forward's return to the class's sampled cut's start: the entry link, then the head. -/
noncomputable def g3fX4L9 {capC : Nat} (hcapC : capC ≤ 4096 + 1593835520) (hcapE : 70039 ≤ capC)
    (hbound : capC < Sim.bound) (hL : π.length = 9) (Mf Mem0 : Nat → SegInst FF → Prop)
    (hEnter : ∀ L x y, NTrack x y → PinVals 6 5 5 (π.length - 1) y.ν → Mf L x → Mem0 L y)
    (hKeep : ∀ L x y, NTrackV x y → Mem0 L x → Mem0 L y) :
    GluePiece FF [final_ord.r0] (fun i => withMem (Mf i.L) (FDX4L9.returnCut 15235 T tk π 70039 1254 0))
      (fun i => withMem (Mem0 i.L) (indexedCut0 [2834731] 15235 T tk capC 19265 π PRE_plx4_L9_head.s1 PRE_plx4_L9_head.S1)) where
  m := []
  n := PL.X4L9Head.N
  O := []
  chk _ _ := rfl
  ok _ _ i _ _ :=
    (PL.X4L9Head.all 15235 T tk capC 19265 π hcapC (fun _ h => PRE_plx4_L9_head.good h.rowValue) (Mem0 i.L) (hKeep i.L)).convL
      ((FDX4L9.toEntry hcapE hbound (by decide) (by decide) (by omega) (hEnter i.L)).trans
        (idxConv PRE_plx4_L9_head.s0_eq PRE_plx4_L9_head.s0_tab))

local notation "M" => memC P KR net env π T tk
local notation "Mp" => memX4L9Pre P KR NE net env π T tk
local notation "Mf" => memFinE P KR NE net env π T tk x4L9Kept (fun _ => 4010)

/-- **The pieces of a prompt of 9 tokens.** `hEnter`, `hKeep`: `H`'s first bookkeeping, which `hooksX4L9` has as `memX4L90`. -/
noncomputable def piecesX4L9 {cap nI capC : Nat} (hcapC : capC ≤ 4096 + 1593835520) (hcapE : 70039 ≤ capC)
    (hboundC : capC < Sim.bound) (hL : π.length = 9)
    (hπ : ∀ k ∈ π, k < 248320) (hlt : ∀ t ∈ π, t < 2 ^ 31)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hpre : ∀ tab, ∃ s, Host.Mlx.SimGraph.Ref.prefillAt P KR NE KR.inPlace net env π tab = some s ∧
      List.Forall₂ (Host.Mlx.SimGraph.Mach.StagePre (π.length - 1))
        (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs)
    (H : Hooks 15235 T tk π cap nI (classX4L9 15235 T tk π capC 19265 hcapC))
    (hEnter : ∀ L x y, NTrack x y → PinVals 6 5 5 (π.length - 1) y.ν → Mf L x → H.Mem0 L y)
    (hKeep : ∀ L x y, NTrackV x y → H.Mem0 L x → H.Mem0 L y) :
    PiecesR FF (invsX4L9 (P := P) (KR := KR) (NE := NE) (net := net) (env := env) H) := by
  have hM : ∀ L x y, NTrack x y → M L x → M L y := fun _ _ _ h m => memC_keep h m
  have hMp : ∀ L x y, NTrack x y → Mp L x → Mp L y := fun _ _ _ h m => memX4L9Pre_keep h m
  have hPin : ∀ L x, Mp L x → π.length = L := fun _ _ m => m.1.symm
  have hpinMp : ∀ L x, Mp L x → L = 9 := fun _ _ m => m.1.trans hL
  have pinC : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (SetupCommon.nextCut 15235 T tk π i.L)) :=
    fun _ _ hb => hb.2.1
  have pin0 : Pinned π.length
      (fun i : Cls.Inst => withMem (M i.L) (withSetupPin T tk π (SetupChunk.chunkCallFixedCut 15235 T tk i.L))) :=
    fun _ _ hb => hb.2.1
  have pinG : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (VWFirst.X4_L9.g2Cut 15235 T tk π i)) :=
    fun _ _ hb => hb.2.1
  have pinF : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (VWFirst.X4_L9.forwardCut 15235 T tk π i)) :=
    fun _ _ hb => hb.2.1
  have hpinM : ∀ L x, M L x → L = 9 := fun _ _ m => m.1.trans hL
  have pinA : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (VWFirst.afterNpsCut 15235 T tk π i)) :=
    fun _ _ hb => hb.2.1
  have pinD : Pinned π.length (fun i : Cls.Inst => withMem (M i.L) (VWFirst.X4_L9.dispatchCut 15235 T tk π i)) :=
    fun _ _ hb => hb.2.1
  have hfin : ∀ i, InRow final_ord.r0 i → ∀ x y : SegInst FF,
      (FDX4L9.forwardCut 15235 T tk π 70039 1254 0 i).R x (FDX4L9.forwardCut 15235 T tk π 70039 1254 0 i).s0
        ⟨(FDX4L9.forwardCut 15235 T tk π 70039 1254 0 i).tab0, []⟩ →
      (FDX4L9.returnCut 15235 T tk π 70039 1254 0).R y (FDX4L9.returnCut 15235 T tk π 70039 1254 0).s0
        ⟨(FDX4L9.returnCut 15235 T tk π 70039 1254 0).tab0, []⟩ →
      (FDX4L9.returnCut 15235 T tk π 70039 1254 0).B y → NTrack x y → Mp i.L x → Mf i.L y :=
    fun i _ x y _ hy _ htr hm =>
      ⟨Host.Route.Cert.Fin.X4L9.hfin P KR NE net env leaves typed hpre hL (fun _ => Host.Route.Cert.Fin.X4L9.finCert.ps) rfl x4L9Kept Host.Route.Cert.Head.X4L9.kept_at (fun _ => 4010) rfl
          (Nat.le_refl _) hy htr i.L (memExit_of_pre (by rw [hm.1]; omega) hm.2.1),
        htr.emit.trans hm.2.2.1, hm.2.2.2.grow htr.nodes⟩
  have none0 := noState_none (F := FF) PRE_pl_head.s0
  have hbF : 70009 < Sim.bound := by decide
  have hf : ∀ r ∈ [first_tail_x4.r0], ∀ i, InRow r i → ∀ x y : SegInst FF,
      (VWFirst.X4_L9.Sfx.startCore 15235 T tk π i).R y (VWFirst.X4_L9.Sfx.startCore 15235 T tk π i).s0
        ⟨(VWFirst.X4_L9.Sfx.startCore 15235 T tk π i).tab0, []⟩ →
      CSrv.Le x.C y.C → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) →
      (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens → y.M.a 12504 = x.M.a 12504 → M i.L x → Mp i.L y :=
    fun r hr i hi x y hy hle hg ht he hm =>
      ⟨hm.1, Host.Route.Cert.X4L9.hfwd P KR NE net env π leaves typed (fun _ => Host.Route.Cert.Fin.X4L9.finCert.ps) hlt c4L9Cr.symm hL T tk
        (fun r h => by obtain rfl := List.mem_singleton.mp h; simp [VWFirst.firstTailRows])
        r (by obtain rfl := List.mem_singleton.mp hr; simp [VWFirst.X4_L9.fwdRows]) i hi x y hy hle hg ht hm.2.1,
        he.trans hm.2.2.1, hm.2.2.2.grow hg⟩
  exact
    { cuts :=
        { b_g0a_o := fun i => withMem (M i.L) (withSetupPin T tk π (SetupChunk.chunkCallFixedCut 15235 T tk i.L))
          b_g0b_i := fun i => withMem (M i.L) (SetupCommon.cut 15235 T tk π PRE_g0b.s0 PRE_g0b.S0 i)
          b_g1_DTdec_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g1_DTdec_first_o := fun _ => noneCut PRE_pl_head.s0
          b_g1_DTtail_first_i := fun i => withMem (M i.L) (VWFirst.afterNpsCut 15235 T tk π i)
          b_g1_DTtail_first_o := fun i => withMem (M i.L) (VWFirst.X4_L9.dispatchCut 15235 T tk π i)
          b_g1_FIN_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g1_FIN_first_o := fun _ => noneCut PRE_pl_head.s0
          b_g1_FIN_tailed_i := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70021 1254 0 PRE_fd_x4_L9_r0.s2 PRE_fd_x4_L9_r0.S2)
          b_g1_FIN_tailed_o := fun i => withMem (Mp i.L) (FDX4L9.dispatchCut 15235 T tk π 70021 1254 0 i)
          b_g2_fin_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g2_fin_first_o := fun _ => noneCut PRE_pl_head.s0
          b_g2_fin_tailed_i := fun i => withMem (Mp i.L) (FDX4L9.g2Cut 15235 T tk π 70039 1254 0 i)
          b_g2_fin_tailed_o := fun i => withMem (Mp i.L) (FDX4L9.forwardCut 15235 T tk π 70039 1254 0 i)
          b_g2_first_i := fun i => withMem (M i.L) (VWFirst.X4_L9.g2Cut 15235 T tk π i)
          b_g2_first_o := fun i => withMem (M i.L) (VWFirst.X4_L9.forwardCut 15235 T tk π i)
          b_g3d_first_i := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70009 1254 0 PRE_pf_x4_L9.s0 PRE_pf_x4_L9.S0)
          b_g3d_first_o := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70009 1254 0 PRE_pf_x4_L9.s0 PRE_pf_x4_L9.S0)
          b_g3f_first_i := fun _ => noneCut PRE_pl_head.s0
          b_g3f_tailed_i := fun i => withMem (Mf i.L) (FDX4L9.returnCut 15235 T tk π 70039 1254 0)
          b_g4_pf_first_i := fun i => withMem (Mp i.L) (Pf.cut 15235 T tk π 70009 1254 0 PRE_pf_x4_L9.s0 PRE_pf_x4_L9.S0) }
      q1 :=
        { g0a := glueRestrict rowsSetupVW (FillSetupEarly.g0a 15235 T tk π M hM)
          chunk_K8__g0a__g0b := stageOff pin0 (off4L9 hL (by simp))
          g0b := glueRestrict rowsSetupVW (FillSetupEarly.g0b 15235 T tk π M hM)
          chunk_K2048__g0a__g0b := SetupH0.chunk_K2048__g0a__g0b 15235 T tk π M hM
          nps_DTdec_first__start__g1_DTdec_first := stageOff pinC (off4L9 hL (by simp))
          g1_DTdec_first := glueNone none0
          disp_D1__g1_DTdec_first__g2_first := stageNone none0
          g2_first := glueWith (glueOne (r0 := first_tail_x4.r0) VWFirst.X4_L9.npsMap PRE_first_tail_x4_L9_r0.S40.oracle 7
              (List.all_eq_true.mp g2Chk4L9 _ (by simp)) (fun i _ ho => VWFirst.X4_L9.g2 15235 T tk π i (hM i.L) ho.1))
            (fun r hr => List.all_eq_true.mp g2Chk4L9 r hr) pinG (g2Own4L9 hL)
          fwd_D1_cold_DFirst__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          g3d_first := FillVW.gEmpty _ _
          eval__g3d_first__g4_pf_first := FillVW.sEmpty _ _ _
          g4_pf_first := FillVW.gEmpty _ _
          nps_DTtail_first__start__g1_DTtail_first :=
            stageRestrict sub21 (VWFirst.nps_DTtail_first__start__g1_DTtail_first 15235 T tk π M hM)
          g1_DTtail_first := glueWith (VWFirst.g1_L9 15235 T tk π hπ M hM hpinM)
            (fun r hr => List.all_eq_true.mp g1Chk4L9 r hr) pinA (g1Own4L9 hL)
          disp_V23__g1_DTtail_first__g2_first := stageOff pinD (off4L9 hL (by simp))
          disp_V4__g1_DTtail_first__g2_first := stageOff pinD (off4L9 hL (by simp))
          disp_V58__g1_DTtail_first__g2_first := stageWith (VWFirst.disp_L9 15235 T tk π M hM)
            (fun r hr => List.all_eq_true.mp dispChk4L9 r hr) pinD (dispOwn4L9 hL)
          disp_VW__g1_DTtail_first__g2_first := stageOff pinD (off4L9 hL (by simp))
          fwd_V23_cold_WFirst__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_V4_cold_WFirst__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_V58f_cold_WFirst__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_V58d_cold_WFirst__g2_first__g3d_first := VWFirst.fwd_L9 15235 T tk π 70009 (by decide) hbF M Mp hMp hpinM hf
          fwd_VW_cold_WFirst_p5__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_VW_cold_WFirst_p6__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_VW_cold_WFirst_p7__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_VW_cold_WFirst_p8__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_VW_cold_WFirst_p9__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_VW_cold_WFirst_p10__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_VW_cold_WFirst_p11__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_VW_cold_WFirst_p12__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_VW_cold_WFirst_p13__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_VW_cold_WFirst_p14__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_VW_cold_WFirst_p15__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_VW_cold_WFirst_p16__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_VW_cold_WFirst_p17__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_VW_cold_WFirst_p18__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_VW_cold_WFirst_p19__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_VW_cold_WFirst_p20__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          fwd_VW_cold_WFirst_p21__g2_first__g3d_first := fwdOff pinF (off4L9 hL (by simp))
          nps_FIN_first__start__g1_FIN_first := stageOff pinC (off4L9 hL (by simp))
          g1_FIN_first := glueNone none0
          disp_D1__g1_FIN_first__g2_fin_first := stageNone none0
          g2_fin_first := glueNone none0
          fwd_D1_cold_DFirst__g2_fin_first__g3f_first := fwdNone none0
          g3f_first := glueNone none0
          nps_FIN_tailed__start__g1_FIN_tailed :=
            FDX4L9.pf_start (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70009) (H := 1254) (N := 0) (Mem := Mp)
              (hMem := hMp) (hPin := hPin) (by decide) (by decide)
          g1_FIN_tailed :=
            FDX4L9.g1_piece (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70021) (H := 1254) (N := 0) (Mem := Mp)
              (hMem := hMp) (hPin := hPin) (by decide)
          disp_D1__g1_FIN_tailed__g2_fin_tailed :=
            FDX4L9.disp_piece (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70021) (H := 1254) (N := 0) (Mem := Mp)
              (hMem := hMp) (by decide)
          g2_fin_tailed :=
            FDX4L9.g2_piece (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70039) (H := 1254) (N := 0) (Mem := Mp)
              (hMem := hMp)
          fwd_D1_dcold_DFit__g2_fin_tailed__g3f_tailed :=
            FDX4L9.fwd_piece (NB := 15235) (T := T) (tk := tk) (π := π) (cap := 70039) (H := 1254) (N := 0) (Mem := Mp)
              Mf _ (by decide) hpinMp hfin
          g3f_tailed := g3fX4L9 hcapC hcapE hboundC hL Mf H.Mem0 hEnter hKeep }
      eqs := ⟨trivial⟩ }

end

end X4L9

end Host.Ts.Sim.Compose.FillPost

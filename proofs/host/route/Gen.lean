import host.sim.compose.MainFramed
import host.route.PromptCut
import host.route.Handoff
set_option maxRecDepth 1000000
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (TplInputs)
open Host.Mlx.SimGraph.Mach (refPrompt AneNetOk)
open Host.Ts.Sim (Addr WFrame LoopFramesA LoopBase LoopStartW valL)
open Host.Ts.Sim.Prefill (PrefInvsW loopCutW)
open Host.Ts.Sim.Full (FF FLR fullWorldXD fullWorldFb mlxOf bridgeOf)
open Host.Ts.Sim.Lin.Cls (routeI)
open Host.Ts.Sim.Compose (Pieces RoutePieces PathPiecesW DecodePiecesFramedW DecodeGraphMFramedAt route_of_piecesFramedAt)

/-! # The route's artifacts from its generated pieces

`RouteGen`: the route's generated pieces (the arguments of A4b's `route_of_piecesFramedAt`, `host.sim.compose.Main`);
`RouteGen.artifacts`: the route's artifacts from them; `route_gen`: `route_final_framed` (`host.route.Final`) at
those artifacts, the route's tokens the machine reference's (`machTok_def`) and vocabulary indices
(`machTok_le`), both from the reference's token sequence along the route (`route_refTokens`). `route_main`
(`host.route.Main`) instantiates it at the boot's Neural Engine side and run.

The prefill enters from the prompt-indexed loadDone cut (`ldPromptCut`, `RouteGen.hI`): the boot's
relation retains the actual prompt while the execution pieces remain generic. -/

variable {C : M1Max.Contract}

/-- **The route's generated pieces** (pending: generation, Phase C/D): the arguments of `route_of_piecesFramedAt`
but the trust boundary, the prompt's and the budget's premises and the tokens' facts. -/
structure RouteGen (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
    (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat) (T : Nat) (tk : Nat → Nat)
    (je : Host.Ts.Env) (nm : Host.Ts.Name) (s0ld : St FF.S) where
  -- the closures' names at the route's values
  kind : Nat → Option Compiled
  -- the full world, the prefill's and the decode's load parameters, the driver's cells, the prefill invariants
  NB : Nat
  Pw : Sim.LoadP
  Pd : Sim.LoadP
  A : Addr
  W : Nat → Option WFrame
  fixA : List Nat
  I : PrefInvsW (fullWorldXD NB).F
  -- the actual prompt's loadDone cut enters the prefill's initial invariant
  hPw : LdParams Pw NB
  hW : W 2665 = none
  hI : Host.Ts.Sim.Prefill.CutConv (ldPromptCut NB Pw W s0ld T tk π) (I.ld π.length)
  -- the decode template's constants
  Fr : LoopFramesA A
  s0 : St FF.S
  tab0 : List SymE
  Itpl : TplInputs
  B : LoopBase
  ΔJ : Nat
  ΔH : Nat
  ΔN : Nat
  -- the pieces: the prefill's, POST's and the short paths' over the full world, the decode's at every pinned
  -- bridge
  Pp : Pieces (fullWorldXD NB).F I
  H : RoutePieces (fullWorldXD NB).F I T tk
  Hp : PathPiecesW (fullWorldXD NB) A Pw W fixA tk (H.cuts.b_pA_cut (routeI π.length T (tk 1) (tk 2)))
    (H.cuts.b_pB_cut (routeI π.length T (tk 1) (tk 2))) (H.cuts.b_pC_cut (routeI π.length T (tk 1) (tk 2)))
  D : ∀ (_ : 3 ≤ T) (b0 : Host.Mlx.FfiAne.St), DecodePiecesFramedW (fullWorldFb b0 NB) A Pd W s0 tab0 fixA Fr (machVal T tk) T tk π.length
    (.ref 2 :: machReads T tk) [.num (.ref 1)] B ΔJ ΔH ΔN
  Dg : ∀ h3 b0, DecodeGraphMFramedAt P KR env π b0 je Itpl (D h3 b0)
  -- the driver's cells and the decode template's start facts
  hcE : A.cE ∈ fixA
  hb : A.emit ∈ fixA
  hgen : A.gen ∈ fixA
  hwc : W A.cE = none
  hwe : W A.emit = none
  henv : lookupEnv nm je = some A.cE
  hgenv : lookupEnv chars!"generation" je = some A.gen
  hA : A.nxt = 17
  hAt : A.tvar = 9
  hAk : A.kvar = 14
  hst0 : LoopStartW (fullWorldXD NB) A Pd s0 tab0
  hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true
  -- the decode cut over the pinned worlds, its prefix token 1 read through table symbol 1
  hdec : Host.Ts.Sim.Prefill.CutConv (I.dec π.length) (decCutFirstFb NB A (machGxV P KR NE net env π kind NB Itpl) W Pd Fr s0 tab0 fixA
    (valL (machVal T tk) T tk π.length) tk (.ref 2 :: machReads T tk) [.num (.ref 1)] B)
  -- the counters' bounds
  hJ : T * ΔJ + B.D < Sim.bound
  hH : (mlxOf s0.ffi).next + T * ΔH + B.H + (Pd.E - (mlxOf s0.ffi).next) < 2 ^ 46
  hN : (mlxOf s0.ffi).nnext + T * ΔN + B.N + (Pd.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62
  -- the short paths' graph certificates
  gA : Hp.pA.Goal (goalMV P KR NE net env π kind NB 1)
  gB2 : Hp.pB2.Goal (goalMV P KR NE net env π kind NB 2)
  gB0 : Hp.pB0.Goal (goalCV P KR NE net env π kind NB T je)
  gC1 : Hp.pC1.Goal (goalMV P KR NE net env π kind NB 1)
  gC0 : Hp.pC0.Goal (goalCV P KR NE net env π kind NB T je)

/-- Enter the generated invariant from the boot relation for the actual prompt. -/
theorem RouteGen.loadEntry_inv {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
    {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat} {T : Nat} {tk : Nat → Nat}
    {je : Host.Ts.Env} {nm : Host.Ts.Name} {s0ld t : St FF.S} {Cs : CSrv}
    (Gn : RouteGen P KR NE net env π T tk je nm s0ld)
    (h : (ldPromptCut Gn.NB Gn.Pw Gn.W s0ld T tk π).Inv t Cs) :
    (Gn.I.ld π.length).Inv t Cs := cutConv_inv Gn.hI h

/-- **The route's artifacts from its pieces** (`route_of_piecesFramedAt`), the route's tokens the reference's and
vocabulary indices. -/
noncomputable def RouteGen.artifacts {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
    {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat} {T : Nat} {tk : Nat → Nat}
    {je : Host.Ts.Env} {nm : Host.Ts.Name} {s0ld : St FF.S} (Gn : RouteGen P KR NE net env π T tk je nm s0ld)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) (hπ : 1 ≤ π.length) (hT : 1 ≤ T)
    (hctx : π.length + T ≤ 262144)
    (htkR : ∀ tab j, j < T →
      ∃ hs, refPrompt P KR NE KR.inPlace net env π tab (π.length + j) = some (tk (j + 1), hs))
    (htk : ∀ j, j ≤ T → tk j ≤ 248319) : RouteArtifactsFramed P KR NE net env π Gn.kind T tk je nm :=
  route_of_piecesFramedAt P KR NE net env leaves typed π Gn.kind je nm hπ hT hctx Gn.NB Gn.Pw Gn.Pd Gn.A Gn.W Gn.fixA Gn.I Gn.Fr
    Gn.s0 Gn.tab0 Gn.Itpl Gn.B Gn.ΔJ Gn.ΔH Gn.ΔN Gn.Pp Gn.H Gn.Hp Gn.D Gn.Dg Gn.hcE Gn.hb Gn.hgen Gn.hwc Gn.hwe Gn.henv Gn.hgenv
    Gn.hA Gn.hAt Gn.hAk Gn.hst0 Gn.hfrN (Gn.hdec.trans decCutFirstFb_forget)
    (fun _ _ h => decCutFirstFb_token (cutConv_inv Gn.hdec h)) htkR htk Gn.hJ Gn.hH Gn.hN Gn.gA Gn.gB2 Gn.gB0 Gn.gC1 Gn.gC0

/-- **The route of a prompt from its generated pieces** (`route_final_framed` at `RouteGen.artifacts`). -/
theorem route_gen (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
    (B : KernelGpu.SetBytes) (lseSum : Bool) (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
    (NE : NeuralEngine) (env : FfiEval.Env InKey) (leaves : Leaves code env.weights)
    (typed : TypedCheckpoint env.weights)
    (π : List Nat) (T : Nat) (hπ : 1 ≤ π.length) (hlt : ∀ t ∈ π, t < 248320) (hT : 1 ≤ T)
    (hctx : π.length + T ≤ 262144) (net : Host.Mlx.SimGraph.Ref.AneNet) (hNE : NE.Succeeds net)
    (hnet : ∀ tab, AneNetOk net (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G B Pg lseSum lseNumerator).toKernelContract env tab))))
    {s0ld : St FF.S} (s : St LSt)
    (hs : bootL (RoutePrompt.cx π) (routeWorld T (machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π))
      2000 = some s)
    (Gn : RouteGen P (routeKernel G B Pg lseSum lseNumerator) NE net env π T
      (machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π) (entryEnv s) chars!"emitted" s0ld)
    (hboot : ∃ N0 tL CL, runC (fullWorldXD Gn.NB).F N0 (bootStart s)
      (routeServer T (machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π)) = some (tL, CL) ∧
      (Gn.I.ld π.length).Inv tL CL) :
    RouteOutcomeV P (routeKernel G B Pg lseSum lseNumerator) NE net env leaves typed π Gn.kind T s Gn.NB := by
  have hRT := route_refTokens P G Pg B lseSum lseNumerator NE net env leaves typed hπ (by omega) hlt hNE hnet
  exact route_final_framed P G Pg B lseSum lseNumerator NE env leaves typed π Gn.kind T hπ hlt hT hctx net hNE hnet s hs
    (Gn.artifacts leaves typed hπ hT hctx (fun tab j _ => machTok_def P _ NE net env π (hRT []) hπ tab j)
      (fun j _ => machTok_le P _ NE net env π (hRT []) hπ hlt j)) hboot

end Host.Route

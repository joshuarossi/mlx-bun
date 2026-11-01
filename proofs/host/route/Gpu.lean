import host.route.Gen
import host.sim.compose.MainGpu
set_option maxRecDepth 1000000
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (TplInputs)
open Host.Mlx.SimGraph.Mach (refPrompt AneNetOk)
open Host.Ts.Sim (Addr WFrame LoopFramesA LoopBase LoopStartW HaltStopSrc valL)
open Host.Ts.Sim.Prefill (PrefInvsW PathW tokVals)
open Host.Ts.Sim.Full (FF FLR fullWorldXD fullWorldFb mlxOf bridgeOf)
open Host.Ts.Sim.Compose (DecodePiecesFramedW DecodeGraphMFramedAt TailFix)
open Host.Ts.Sim.Compose.Gpu (PiecesR RoutePiecesR route_of_stepsFramedAt clip_ld)

/-! # The route of a prompt with no Neural Engine forward

`RouteGenGpu`: `RouteGen` with the restricted bundles, the pieces the prompts of at most 224 tokens run (no Neural
Engine forward, chunk 2048, no drains). `route_gen_gpu`: `route_final_framed` at its artifacts. The conclusion, the
tokens and the trust boundary are `route_gen`'s; `RouteGen`, `route_gen` and `route_main` stay beside it for the
Neural Engine route. -/

variable {C : M1Max.Contract}

/-- The load cut at the boot's end state `tL`: the graph bookkeeping entering the prefill reads the target. -/
def ldPromptCutAt (NB : Nat) (Pw : Sim.LoadP) (W : Nat → Option WFrame) (s0 : St FF.S) (T : Nat) (tk : Nat → Nat)
    (π : List Nat) (tL : St FF.S) : Host.Ts.Sim.Prefill.ICut FF :=
  { ldPromptCut NB Pw W s0 T tk π with
    B := fun x => (ldPromptCut NB Pw W s0 T tk π).B x ∧ x.t = tL }

theorem ldPromptCutAt_of_inv {NB : Nat} {Pw : Sim.LoadP} {W : Nat → Option WFrame} {s0 : St FF.S} {T : Nat}
    {tk : Nat → Nat} {π : List Nat} {t : St FF.S} {Cs : CSrv} (h : (ldPromptCut NB Pw W s0 T tk π).Inv t Cs) :
    (ldPromptCutAt NB Pw W s0 T tk π t).Inv t Cs := by
  obtain ⟨x, ht, hC, hr, hb⟩ := h
  exact ⟨x, ht, hC, hr, hb, ht⟩

/-- **The generated pieces of a prompt with no Neural Engine forward.** `tL` is the boot's end state. -/
structure RouteGenGpu (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
    (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat) (T : Nat) (tk : Nat → Nat)
    (je : Host.Ts.Env) (nm : Host.Ts.Name) (s0ld tL : St FF.S) where
  ρ : Nat → F64
  NB : Nat
  Pw : Sim.LoadP
  Pd : Sim.LoadP
  A : Addr
  W : Nat → Option WFrame
  fixA : List Nat
  fixB : List Nat
  hsub : ∀ a ∈ fixA, a ∈ fixB
  I : PrefInvsW (fullWorldXD NB).F
  hPw : LdParams Pw NB
  hW : W 2665 = none
  hI : Host.Ts.Sim.Prefill.CutConv (ldPromptCutAt NB Pw W s0ld T tk π tL) (I.ld π.length)
  Fr : LoopFramesA A
  s0 : St FF.S
  tab0 : List SymE
  Itpl : TplInputs
  B : LoopBase
  ΔJ : Nat
  ΔH : Nat
  ΔN : Nat
  Pp : PiecesR (fullWorldXD NB).F I
  H : RoutePiecesR (fullWorldXD NB).F I T tk
  pA : 2 ≤ T → tk 1 = 248044 → PathW (fullWorldXD NB) A W Pw fixA (I.ps π.length) []
  pB2 : T = 2 → tk 1 ≠ 248044 → tk 2 = 248044 → PathW (fullWorldXD NB) A W Pw fixA (I.ps π.length) (tokVals tk 1)
  pB0 : T = 2 → tk 1 ≠ 248044 → tk 2 ≠ 248044 → PathW (fullWorldXD NB) A W Pw fixA (I.ps π.length) (tokVals tk 2)
  pC1 : T = 1 → tk 1 = 248044 → PathW (fullWorldXD NB) A W Pw fixA (I.ps π.length) []
  pC0 : T = 1 → tk 1 ≠ 248044 → PathW (fullWorldXD NB) A W Pw fixA (I.ps π.length) (tokVals tk 1)
  sA : ∀ h h', HaltStopSrc (pA h h').hs
  sB2 : ∀ h h' h'', HaltStopSrc (pB2 h h' h'').hs
  sC1 : ∀ h h', HaltStopSrc (pC1 h h').hs
  D : ∀ (_ : 3 ≤ T) (b0 : Host.Mlx.FfiAne.St), DecodePiecesFramedW (fullWorldFb b0 NB) A Pd W s0 tab0 fixB Fr ρ T tk π.length
    (.ref 2 :: machReads T tk) [.num (.ref 1)] B ΔJ ΔH ΔN
  Dg : ∀ h3 b0, Host.Ts.Sim.Compose.Gpu.DecodeGraphR P KR env π b0 je Itpl (D h3 b0)
  tails : ∀ h3 b0 k, TailFix (fullWorldFb b0 NB) A W Pd Fr s0 tab0 fixB fixA (valL ρ T tk π.length) tk
    (.ref 2 :: machReads T tk) [.num (.ref 1)] B ΔJ ΔH ΔN ((D h3 b0).cs k)
  hc0 : ∀ h3 b0, (Dg h3 b0).c0.cc ∈ fixA
  hc1 : ∀ h3 b0, (Dg h3 b0).c1.cc ∈ fixA
  hc2 : ∀ h3 b0, (Dg h3 b0).c2.cc ∈ fixA
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
  hdec : ∀ t Cs, (I.dec π.length).Inv t Cs → ∃ kind, (decCutFirstFb NB A (machGxV P KR NE net env π kind NB Itpl) W Pd Fr s0 tab0 fixA
    (valL ρ T tk π.length) tk (.ref 2 :: machReads T tk) [.num (.ref 1)] B).Inv t Cs
  hJ : T * ΔJ + B.D < Sim.bound
  hH : (mlxOf s0.ffi).next + T * ΔH + B.H + (Pd.E - (mlxOf s0.ffi).next) < 2 ^ 46
  hN : (mlxOf s0.ffi).nnext + T * ΔN + B.N + (Pd.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62
  gA : ∀ h h', (pA h h').Goal (fun tF CF => ∃ kind, goalMV P KR NE net env π kind NB 1 tF CF)
  gB2 : ∀ h h' h'', (pB2 h h' h'').Goal (fun tF CF => ∃ kind, goalMV P KR NE net env π kind NB 2 tF CF)
  gB0 : ∀ h h' h'', (pB0 h h' h'').Goal (fun tF CF => ∃ kind, goalCV P KR NE net env π kind NB T je tF CF)
  gC1 : ∀ h h', (pC1 h h').Goal (fun tF CF => ∃ kind, goalMV P KR NE net env π kind NB 1 tF CF)
  gC0 : ∀ h h', (pC0 h h').Goal (fun tF CF => ∃ kind, goalCV P KR NE net env π kind NB T je tF CF)

/-- **The route's artifacts from the restricted pieces.** -/
noncomputable def RouteGenGpu.artifacts {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
    {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat} {T : Nat} {tk : Nat → Nat}
    {je : Host.Ts.Env} {nm : Host.Ts.Name} {s0ld tL : St FF.S} (Gn : RouteGenGpu P KR NE net env π T tk je nm s0ld tL)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) (hπ : 1 ≤ π.length) (hL : π.length ≤ 224)
    (hT : 1 ≤ T) (hctx : π.length + T ≤ 262144)
    (htkR : ∀ tab j, j < T →
      ∃ hs, refPrompt P KR NE KR.inPlace net env π tab (π.length + j) = some (tk (j + 1), hs))
    (htk : ∀ j, j ≤ T → tk j ≤ 248319) : RouteArtifactsX P KR NE net env π T tk je nm :=
  route_of_stepsFramedAt P KR NE net env leaves typed π je nm hπ hL hT hctx Gn.ρ Gn.NB Gn.Pw Gn.Pd Gn.A Gn.W Gn.fixA Gn.fixB Gn.hsub Gn.I Gn.Fr
    Gn.s0 Gn.tab0 Gn.Itpl Gn.B Gn.ΔJ Gn.ΔH Gn.ΔN Gn.Pp Gn.H Gn.pA Gn.pB2 Gn.pB0 Gn.pC1 Gn.pC0 Gn.sA Gn.sB2 Gn.sC1 Gn.D Gn.Dg Gn.tails Gn.hc0 Gn.hc1 Gn.hc2 Gn.hcE Gn.hb Gn.hgen Gn.hwc Gn.hwe Gn.henv Gn.hgenv
    Gn.hA Gn.hAt Gn.hAk Gn.hst0 Gn.hfrN
    (fun t Cs h => (Gn.hdec t Cs h).imp fun _ h' => cutConv_inv decCutFirstFb_forget h')
    (fun t Cs h => by obtain ⟨_, h'⟩ := Gn.hdec t Cs h; exact decCutFirstFb_token h') htkR htk Gn.hJ Gn.hH Gn.hN Gn.gA Gn.gB2 Gn.gB0 Gn.gC1 Gn.gC0

/-- **The route of a prompt of at most 224 tokens from its generated pieces**, with the boot's facts as premises
(`route_main_gpu`, `host.route.MainGpu`, instantiates them at the boot). -/
theorem route_gen_gpu (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
    (B : KernelGpu.SetBytes) (lseSum : Bool) (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
    (NE : NeuralEngine) (env : FfiEval.Env InKey) (leaves : Leaves code env.weights)
    (typed : TypedCheckpoint env.weights)
    (π : List Nat) (T : Nat) (hπ : 1 ≤ π.length) (hL : π.length ≤ 224) (hlt : ∀ t ∈ π, t < 248320) (hT : 1 ≤ T)
    (hctx : π.length + T ≤ 262144) (net : Host.Mlx.SimGraph.Ref.AneNet) (hNE : NE.Succeeds net)
    (hnet : ∀ tab, AneNetOk net (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G B Pg lseSum lseNumerator).toKernelContract env tab))))
    {s0ld tLd : St FF.S} (s : St LSt)
    (hs : bootL (RoutePrompt.cx π) (routeWorld T (machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π))
      2000 = some s)
    (Gn : RouteGenGpu P (routeKernel G B Pg lseSum lseNumerator) NE net env π T
      (machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π) (entryEnv s) chars!"emitted" s0ld tLd)
    (hboot : ∃ N0 tL CL, runC (fullWorldXD Gn.NB).F N0 (bootStart s)
      (routeServer T (machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π)) = some (tL, CL) ∧
      (Gn.I.ld π.length).Inv tL CL) :
    ∃ kind, RouteOutcomeV P (routeKernel G B Pg lseSum lseNumerator) NE net env leaves typed π kind T s Gn.NB := by
  have hRT := route_refTokens P G Pg B lseSum lseNumerator NE net env leaves typed hπ (by omega) hlt hNE hnet
  obtain ⟨N0, tL, CL, hrun, hld⟩ := hboot
  have hclip : (Gn.I.clip.ld π.length).Inv tL CL := (clip_ld Gn.I hL).symm ▸ hld
  exact route_finalX P G Pg B lseSum lseNumerator NE env leaves typed π T hπ hlt hT hctx net hNE hnet s hs
    (Gn.artifacts leaves typed hπ hL hT hctx (fun tab j _ => machTok_def P _ NE net env π (hRT []) hπ tab j)
      (fun j _ => machTok_le P _ NE net env π (hRT []) hπ hlt j))
    ⟨N0, tL, CL, hrun, hclip⟩

end Host.Route

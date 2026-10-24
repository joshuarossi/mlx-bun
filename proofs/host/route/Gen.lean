import host.sim.compose.Main
import host.load.run.prompt.FrameRel
set_option maxRecDepth 1000000
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (TplInputs)
open Host.Mlx.SimGraph.Mach (refPrompt AneNetOk)
open Host.Ts.Sim (Addr WFrame LoopFramesA LoopBase LoopStartW valL)
open Host.Ts.Sim.Prefill (PrefInvsW loopCutW)
open Host.Ts.Sim.Full (FF FLR fullWorld mlxOf bridgeOf)
open Host.Ts.Sim.Lin.Cls (routeI)
open Host.Ts.Sim.Compose (Pieces RoutePieces DecodePiecesW DecodeGraphM route_of_pieces)

/-! # The route's artifacts from its generated pieces

`RouteGen`: the route's generated pieces (the arguments of A4b's `route_of_pieces`, `host.sim.compose.Main`);
`RouteGen.artifacts`: the route's artifacts from them; `route_gen`: `route_final` (`host.route.Final`) at
those artifacts, the route's tokens the machine reference's (`machTok_def`) and vocabulary indices
(`machTok_le`), both from the reference's token sequence along the route (`route_refTokens`). `route_main`
(`host.route.Main`) instantiates it at the boot's Neural Engine side and run.

The prefill's loadDone cut is fixed (`ldCut`, `RouteGen.hI`): the generated chains start from the boot's end
as the boot's relation states it (`Ld.rel_full`), so its invariant there is proved (`route_main`). -/

variable {C : M1Max.Contract}

/-! ## The prefill's loadDone cut -/

/-- **The Neural Engine memory before any forward**: from any loaded surfaces, the target's bridge log runs to
those surfaces with no fixed value and nothing pending. -/
def AneFresh (t : St FF.S) : Prop :=
  ∀ (C' : M1Max.Contract) (Pc : MlxPrefillContract C') (Kc : RouteKernelContract C')
    (weights : List Char → List Char → Option Value) (kind : Nat → Option Compiled) (NE : NeuralEngine)
    (IP : FfiAneEval.InPlace) (G : FfiAneEval.Graph) (init : Nat → Surface),
    FfiAneEval.final Pc Kc weights kind NE IP G init (bridgeOf t.ffi) = some ⟨init, fun _ => none, fun _ => none⟩

/-- **Wide frames where the context frames nothing** cost nothing: at an unframed address `SlotW` is the image
whatever `W`, so the relation without frames is the one under `W` when `W`'s frames lie outside `K.fr`'s
domain. -/
theorem RelB.widen {F : Host.Ts.Ffi} {FR : Host.Ts.Sim.Map → Nat → F.S → F.S → Prop} {stk : List Host.Ts.Frame}
    {M : Host.Ts.Sim.Map} {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {s t : St F.S} {S : Host.Ts.SSrv} {C : Host.Ts.CSrv}
    {W : Nat → Option WFrame}
    (h : Host.Ts.Sim.RelB F FR Host.Ts.Sim.noFrames stk M ν K s S t C) (hW : ∀ a, W a ≠ none → K.fr a = none) :
    Host.Ts.Sim.RelB F FR W stk M ν K s S t C :=
  { h with
    heap := fun a x hg => by
      have hs := h.heap a x hg
      cases hfr : K.fr a with
      | none => exact (Host.Ts.Sim.SlotW.of_fr_none hfr).2 ((Host.Ts.Sim.SlotW.of_fr_none hfr).1 hs)
      | some p =>
        have hw : W a = none := by
          by_contra hne
          have := hW a hne
          rw [hfr] at this
          cases this
        exact (Host.Ts.Sim.SlotW.of_w_none hw).2
          ((Host.Ts.Sim.SlotW.of_w_none (W := Host.Ts.Sim.noFrames) rfl).1 hs) }

/-- The load parameters at which the boot's relation at loadDone holds (`Ld.rel_full`'s side conditions). -/
def LdParams (Pw : Sim.LoadP) (NB : Nat) : Prop :=
  (0 < Pw.lo ∧ Pw.lo ≤ 18151) ∧ (18151 ≤ Pw.E ∧ Pw.E < 2 ^ 46) ∧ (Pw.NL = 15235 ∧ Pw.N0 = 15235) ∧
    (15235 ≤ Pw.NE ∧ Pw.NE < 2 ^ 61) ∧ NB ≤ Pw.NL

/-- **The prefill's loadDone cut** at prompt length `L`: the boot's template state `s0` at loadDone with the
load's table, related to the target by the full world's relation under the route's frames `W` at the remaining
readbacks `machReads T tk`, under the identity map and the route's valuation `machVal T tk` (every template
variable a natural below `2 ^ 20`), the prompt array (2665) framed with a prompt of length `L` below the
vocabulary (`FrameRel.ctx`, the band `[Pw.lo, Pw.E)`), the Neural Engine memory before any forward. -/
def ldCut (NB : Nat) (Pw : Sim.LoadP) (W : Nat → Option WFrame) (s0 : St FF.S) (T : Nat) (tk : Nat → Nat)
    (L : Nat) : Host.Ts.Sim.Prefill.ICut (fullWorld NB).F where
  s0 := s0
  tab0 := Decode.tab
  R := fun x s S => Sim.RelF FF (FLR Pw NB (machReads T tk)) W x.M x.ν x.K s S x.t x.C
  B := fun x => x.M = Sim.Map.id ∧ x.ν = machVal T tk ∧ Host.Ts.Sim.Full.VBOkF Sim.loopVB x.ν ∧
    (∃ π' : List Nat, π'.length = L ∧ (∀ t ∈ π', t < 248320) ∧
      x.K = Host.Load.Run.Prompt.FrameRel.ctx s0 2665 (π'.map natV) Pw.lo Pw.E) ∧ AneFresh x.t

/-- **The route's generated pieces** (pending: generation, Phase C/D): the arguments of `route_of_pieces`
but the trust boundary, the prompt's and the budget's premises and the tokens' facts. -/
structure RouteGen (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
    (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat) (T : Nat) (tk : Nat → Nat)
    (je : Host.Ts.Env) (nm : Host.Ts.Name) (s0ld : St FF.S) where
  -- the full world, the driver's cells, the prefill invariants
  NB : Nat
  Pw : Sim.LoadP
  A : Addr
  W : Nat → Option WFrame
  fixA : List Nat
  I : PrefInvsW (fullWorld NB).F
  -- the prefill chains start from the fixed loadDone cut at the boot's template state `s0ld`
  hPw : LdParams Pw NB
  hW : W 2665 = none
  hI : ∀ L, I.ld L = ldCut NB Pw W s0ld T tk L
  -- the decode template's constants
  Fr : LoopFramesA A
  s0 : St FF.S
  tab0 : List SymE
  Itpl : TplInputs
  B : LoopBase
  ΔJ : Nat
  ΔH : Nat
  ΔN : Nat
  -- the pieces
  Pp : Pieces (fullWorld NB).F I
  H : RoutePieces (fullWorld NB).F I T tk
  D : DecodePiecesW (fullWorld NB) A Pw W s0 tab0 fixA Fr (machVal T tk) T tk π.length
    (.ref 2 :: machReads T tk) [.num (.ref 1)] B ΔJ ΔH ΔN (H.cuts.b_pA_cut (routeI π.length T (tk 1) (tk 2)))
    (H.cuts.b_pB_cut (routeI π.length T (tk 1) (tk 2))) (H.cuts.b_pC_cut (routeI π.length T (tk 1) (tk 2)))
  Dg : DecodeGraphM P KR env π je Itpl D
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
  hst0 : LoopStartW (fullWorld NB) A Pw s0 tab0
  hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true
  -- the decode cut, its prefix token 1 read through table symbol 1
  hdec : I.dec π.length = loopCutW (fullWorld NB) A (machGx P KR NE net env π NB Itpl) W Pw Fr s0 tab0 fixA
    (valL (machVal T tk) T tk π.length) tk (.ref 2 :: machReads T tk) [.num (.ref 1)] B
  he1 : ∀ t C, (I.dec π.length).Inv t C → C.val (.ref 1) = some (F64.ofNat (tk 1))
  -- the counters' bounds
  hJ : T * ΔJ + B.D < Sim.bound
  hH : (mlxOf s0.ffi).next + T * ΔH + B.H + (Pw.E - (mlxOf s0.ffi).next) < 2 ^ 46
  hN : (mlxOf s0.ffi).nnext + T * ΔN + B.N + (Pw.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62
  -- the short paths' graph certificates
  gA : D.pA.Goal (goalM P KR NE net env π NB 1)
  gB2 : D.pB2.Goal (goalM P KR NE net env π NB 2)
  gB0 : D.pB0.Goal (goalC P KR NE net env π NB T je)
  gC1 : D.pC1.Goal (goalM P KR NE net env π NB 1)
  gC0 : D.pC0.Goal (goalC P KR NE net env π NB T je)

/-- **The route's artifacts from its pieces** (`route_of_pieces`), the route's tokens the reference's and
vocabulary indices. -/
noncomputable def RouteGen.artifacts {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
    {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat} {T : Nat} {tk : Nat → Nat}
    {je : Host.Ts.Env} {nm : Host.Ts.Name} {s0ld : St FF.S} (Gn : RouteGen P KR NE net env π T tk je nm s0ld)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) (hπ : 1 ≤ π.length) (hT : 1 ≤ T)
    (hctx : π.length + T ≤ 262144)
    (htkR : ∀ tab j, j < T →
      ∃ hs, refPrompt P KR NE KR.inPlace net env π tab (π.length + j) = some (tk (j + 1), hs))
    (htk : ∀ j, j ≤ T → tk j ≤ 248319) : RouteArtifacts P KR NE net env π T tk je nm :=
  route_of_pieces P KR NE net env leaves typed π je nm hπ hT hctx Gn.NB Gn.Pw Gn.A Gn.W Gn.fixA Gn.I Gn.Fr Gn.s0
    Gn.tab0 Gn.Itpl Gn.B Gn.ΔJ Gn.ΔH Gn.ΔN Gn.Pp Gn.H Gn.D Gn.Dg Gn.hcE Gn.hb Gn.hgen Gn.hwc Gn.hwe Gn.henv Gn.hgenv
    Gn.hA Gn.hAt Gn.hAk Gn.hst0 Gn.hfrN Gn.hdec Gn.he1 htkR htk Gn.hJ Gn.hH Gn.hN Gn.gA Gn.gB2 Gn.gB0 Gn.gC1 Gn.gC0

/-- **The route of a prompt from its generated pieces** (`route_final` at `RouteGen.artifacts`). -/
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
    (hboot : ∃ N0 tL CL, runC (fullWorld Gn.NB).F N0 (bootStart s)
      (routeServer T (machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π)) = some (tL, CL) ∧
      (Gn.I.ld π.length).Inv tL CL) :
    RouteOutcome P (routeKernel G B Pg lseSum lseNumerator) NE net env leaves typed π T s Gn.NB := by
  have hRT := route_refTokens P G Pg B lseSum lseNumerator NE net env leaves typed hπ (by omega) hlt hNE hnet
  exact route_final P G Pg B lseSum lseNumerator NE env leaves typed π T hπ hlt hT hctx net hNE hnet s hs
    (Gn.artifacts leaves typed hπ hT hctx (fun tab j _ => machTok_def P _ NE net env π (hRT []) hπ tab j)
      (fun j _ => machTok_le P _ NE net env π (hRT []) hπ hlt j)) hboot

end Host.Route

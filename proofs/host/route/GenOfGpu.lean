import host.route.Gpu
import host.route.SetupEntry
import host.route.HandRho
import host.route.cert.Dec.Pieces
import host.route.DecodeBounds
import host.sim.compose.ShortFix
import host.sim.template.SavedBindings
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Compose Host.Ts.Sim.Template
open Host.Ts.Sim.Compose.Gpu (PiecesR RoutePiecesR DecodeGraphR)
open Host.Load.Run.Prompt
open Host.Load.Run.Tpl (wideG decVal)
open Host.Route.PrefGraph (handRho handRho_pin handRho_vp)
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # The route of a prompt of at most 224 tokens, assembled

`routeGenOfGpu`: `RouteGenGpu` over the decode template `DT4`, the frames `framesG` and `wideG`, the valuation `handRho`, the pins
`decVal`. The decode chains and their graph facts are `DEC4.piecesFramedGpu`, `DEC4.graphPieces`. The premises are the prefill's, POST's, the short
paths' and their goals, and the two connections of the prefill's invariants. -/

/-- Counter room reserved for the initial POST-to-decode handoff (`routeLoopBase`). -/
def routeLoopBaseGpu : LoopBase := ⟨2 ^ 60, 2 ^ 45, 2 ^ 61⟩

section
variable {C : M1Max.Contract}
  (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
  (bytes : KernelGpu.SetBytes) (lseSum : Bool)
  (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
  (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)
  (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
  (π : List Nat) (T : Nat) (hπ : 1 ≤ π.length) (hL : π.length ≤ 224)
  (hlt : ∀ t ∈ π, t < 248320) (hctx : π.length + T ≤ 262144)
  (hNE : NE.Succeeds net)
  (hnet : ∀ tab, Host.Mlx.SimGraph.Mach.AneNetOk net
    (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G bytes Pg lseSum lseNumerator).toKernelContract env tab))))

local notation "Kr" => routeKernel G bytes Pg lseSum lseNumerator
local notation "Tk" => machTok P Kr NE net env π
local notation "Je" => entryEnv (Host.Load.Run.Prompt.P.at0 (π.map natV) (machReads T Tk))
local notation "FrP" => framesG Host.Route.Cert.Dec.s0 (π.map natV)
local notation "Rh" => handRho T π.length Tk
local notation "Inp" => Host.Route.Cert.Dec.inputs
local notation "Pd4" => Host.Route.Cert.Dec.Pw
local notation "St4" => Host.Route.Cert.Dec.s0
local notation "Tb4" => Host.Route.Cert.Dec.tab0
local notation "Gx" => fun kind => machGxV P Kr NE net env π kind 15235 Inp

/-- **Assemble the route of a prompt of at most 224 tokens.** -/
noncomputable def routeGenOfGpu
    (I : PrefInvsW (fullWorldXD 15235).F)
    (Pp : PiecesR (fullWorldXD 15235).F I)
    (loadEntry : CutConv (ldPromptCutAt 15235 setupP wideP (ldStT [] []) T Tk π (ldStT (π.map natV) (machReads T Tk))) (I.ld π.length))
    (postPieces : RoutePiecesR (fullWorldXD 15235).F I T Tk)
    (pA : 2 ≤ T → Tk 1 = 248044 → PathW (fullWorldXD 15235) addrPrompt wideG setupP shortFixP (I.ps π.length) [])
    (pB2 : T = 2 → Tk 1 ≠ 248044 → Tk 2 = 248044 → PathW (fullWorldXD 15235) addrPrompt wideG setupP shortFixP (I.ps π.length) (tokVals Tk 1))
    (pB0 : T = 2 → Tk 1 ≠ 248044 → Tk 2 ≠ 248044 → PathW (fullWorldXD 15235) addrPrompt wideG setupP shortFixP (I.ps π.length) (tokVals Tk 2))
    (pC1 : T = 1 → Tk 1 = 248044 → PathW (fullWorldXD 15235) addrPrompt wideG setupP shortFixP (I.ps π.length) [])
    (pC0 : T = 1 → Tk 1 ≠ 248044 → PathW (fullWorldXD 15235) addrPrompt wideG setupP shortFixP (I.ps π.length) (tokVals Tk 1))
    (sA : ∀ h h', HaltStopSrc (pA h h').hs)
    (sB2 : ∀ h h' h'', HaltStopSrc (pB2 h h' h'').hs)
    (sC1 : ∀ h h', HaltStopSrc (pC1 h h').hs)
    (postHandoff : ∀ t Cs, (I.dec π.length).Inv t Cs → ∃ kind,
      (decCutFirstFb 15235 addrPrompt (Gx kind) wideG Pd4 FrP St4 Tb4 shortFixP
        (valL Rh T Tk π.length) Tk (.ref 2 :: machReads T Tk) [.num (.ref 1)] routeLoopBaseGpu).Inv t Cs)
    (graphA : ∀ h h', (pA h h').Goal (fun tF CF => ∃ kind, goalMV P Kr NE net env π kind 15235 1 tF CF))
    (graphB2 : ∀ h h' h'', (pB2 h h' h'').Goal (fun tF CF => ∃ kind, goalMV P Kr NE net env π kind 15235 2 tF CF))
    (graphB0 : ∀ h h' h'', (pB0 h h' h'').Goal (fun tF CF => ∃ kind, goalCV P Kr NE net env π kind 15235 T Je tF CF))
    (graphC1 : ∀ h h', (pC1 h h').Goal (fun tF CF => ∃ kind, goalMV P Kr NE net env π kind 15235 1 tF CF))
    (graphC0 : ∀ h h', (pC0 h h').Goal (fun tF CF => ∃ kind, goalCV P Kr NE net env π kind 15235 T Je tF CF)) :
    RouteGenGpu P Kr NE net env π T Tk Je chars!"emitted" (ldStT [] []) (ldStT (π.map natV) (machReads T Tk)) := by
  have hRT := route_refTokens P G Pg bytes lseSum lseNumerator NE net env leaves typed
    hπ (by omega) hlt hNE hnet
  have hv : ∀ j, Tk j ≤ 248319 := machTok_le P Kr NE net env π (hRT []) hπ hlt
  have hVP : ∀ i nx, i + 2 ≤ T → nx ≤ 2 ^ 20 → Host.Load.Run.Tpl.DecOk.VP (valL Rh T Tk π.length i nx) :=
    fun i nx hi hnx => handRho_vp hL (fun j => Nat.le_trans (hv j) (by decide)) hctx (fun j _ => hv j) i nx hi hnx
  have hc := decode_counter_bounds (B := routeLoopBaseGpu) (T := T) (h := (mlxOf (St4).ffi).next) (n := (mlxOf (St4).ffi).nnext)
    (by omega) (Nat.le_of_ble_eq_true Host.Route.Cert.Dec.startNext) (Nat.le_of_ble_eq_true Host.Route.Cert.Dec.startNnext40) le_rfl le_rfl le_rfl
  refine
    { ρ := Rh
      pin := decVal
      NB := 15235
      Pw := setupP
      Pd := Pd4
      A := addrPrompt
      W := wideG
      Wl := wideP
      fixA := shortFixP
      fixB := Dec4.fix4
      hsub := Dec4.short_sub
      I := I
      hPw := by unfold LdParams; decide
      hW := rfl
      hI := loadEntry
      Fr := FrP
      s0 := St4
      tab0 := Tb4
      Itpl := Inp
      B := routeLoopBaseGpu
      ΔJ := 151312
      ΔH := 3867
      ΔN := 4882
      hpT := Host.Route.Cert.Dec.tab0_pin
      hpρ := fun q k h => ⟨by have := Host.Route.decVal_range h; omega, handRho_pin h⟩
      Pp := Pp
      H := postPieces
      pA := pA
      pB2 := pB2
      pB0 := pB0
      pC1 := pC1
      pC0 := pC0
      sA := sA
      sB2 := sB2
      sC1 := sC1
      D := fun h3 b0 => DEC4.piecesFramedGpu (b0 := b0) (NB := 15235) (B := routeLoopBaseGpu) (ΔJ := 151312) (ΔH := 3867) (ΔN := 4882)
        (ρ := Rh) (toks := .ref 2 :: machReads T Tk) (π.map natV) (by simp) hVP hπ hL h3 hctx (fun j _ => hv j)
        (by decide) (by decide) (by decide) hc.1 hc.2.1 hc.2.2
      Dg := fun h3 b0 => DEC4.graphPieces P Kr env π (b0 := b0) (NB := 15235) (B := routeLoopBaseGpu) (ΔJ := 151312) (ΔH := 3867) (ΔN := 4882)
        (π.map natV) (by simp) hVP hπ hL h3 hctx (fun j _ => hv j) le_rfl
        (by decide) (by decide) (by decide) hc.1 hc.2.1 hc.2.2
      tails := fun h3 b0 => DEC4.tailsGpu (b0 := b0) (NB := 15235) (B := routeLoopBaseGpu) (ΔJ := 151312) (ΔH := 3867) (ΔN := 4882)
        (ρ := Rh) (toks := .ref 2 :: machReads T Tk) (π.map natV) (by simp) hVP hπ hL h3 hctx (fun j _ => hv j)
        (by decide) (by decide) (by decide) hc.1 hc.2.1 hc.2.2
      hc0 := fun _ _ => (by decide : 2586 ∈ shortFixP)
      hc1 := fun _ _ => (by decide : 2586 ∈ shortFixP)
      hc2 := fun _ _ => (by decide : 2586 ∈ shortFixP)
      hcE := by decide
      hb := by decide
      hgen := by decide
      hwc := by decide
      hwe := by decide
      henv := saved_emitted _ _
      hgenv := saved_generation _ _
      hA := rfl
      hAt := rfl
      hAk := rfl
      hst0 := ?_
      hfrN := ?_
      hdec := postHandoff
      hJ := hc.1
      hH := hc.2.1
      hN := hc.2.2
      gA := graphA
      gB2 := graphB2
      gB0 := graphB0
      gC1 := graphC1
      gC0 := graphC0 }
  · have hs := Host.Route.Cert.Dec.start Host.Mlx.FfiAne.St.empty 15235
    exact ⟨hs.htok, hs.start, hs.lo, hs.hi⟩
  · change ∀ e ∈ Host.Load.Run.Tpl.DEC4_ord.S0.tab, e.noVar 17 = true
    rw [Host.Load.Run.Tpl.DEC4_ord.S0_tab]
    exact Host.Load.Run.Tpl.DT4.noVar17

end
end Host.Route

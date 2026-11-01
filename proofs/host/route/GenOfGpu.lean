import host.route.Gpu
import host.route.SetupEntry
import host.route.DecodeBounds
import host.sim.compose.a4b.GraphPiecesGpu
import host.sim.compose.a4b.ShortFixGpu
import host.sim.template.SavedBindings
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Compose Host.Ts.Sim.Template
open Host.Ts.Sim.Compose.Gpu (PiecesR RoutePiecesR)
open Host.Load.Run.Prompt
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

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
  (hlt : ∀ t ∈ π, t < 248320) (hT : 1 ≤ T) (hctx : π.length + T ≤ 262144)
  (hNE : NE.Succeeds net)
  (hnet : ∀ tab, Host.Mlx.SimGraph.Mach.AneNetOk net
    (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G bytes Pg lseSum lseNumerator).toKernelContract env tab))))

local notation "Kr" => routeKernel G bytes Pg lseSum lseNumerator
local notation "Tk" => machTok P Kr NE net env π
local notation "Je" => entryEnv (Host.Load.Run.Prompt.P.at0 (π.map natV) (machReads T Tk))
local notation "FrP" => framesP DEC.s0 (π.map natV)
local notation "Gx" => fun kind => machGxV P Kr NE net env π kind 15235 DEC.inputs

/-- Assemble the route of a prompt of at most 224 tokens from the restricted bundles. The remaining premises name the
POST, short-path executions and graph facts, and the two connections of the prefill invariants. -/
noncomputable def routeGenOfGpu
    (I : PrefInvsW (fullWorldXD 15235).F)
    (Pp : PiecesR (fullWorldXD 15235).F I)
    (loadEntry : CutConv (ldPromptCutAt 15235 setupP wideP (ldStT [] []) T Tk π (ldStT (π.map natV) (machReads T Tk))) (I.ld π.length))
    (postPieces : RoutePiecesR (fullWorldXD 15235).F I T Tk)
    (pA : 2 ≤ T → Tk 1 = 248044 → PathW (fullWorldXD 15235) addrPrompt wideP setupP shortFixP (I.ps π.length) [])
    (pB2 : T = 2 → Tk 1 ≠ 248044 → Tk 2 = 248044 → PathW (fullWorldXD 15235) addrPrompt wideP setupP shortFixP (I.ps π.length) (tokVals Tk 1))
    (pB0 : T = 2 → Tk 1 ≠ 248044 → Tk 2 ≠ 248044 → PathW (fullWorldXD 15235) addrPrompt wideP setupP shortFixP (I.ps π.length) (tokVals Tk 2))
    (pC1 : T = 1 → Tk 1 = 248044 → PathW (fullWorldXD 15235) addrPrompt wideP setupP shortFixP (I.ps π.length) [])
    (pC0 : T = 1 → Tk 1 ≠ 248044 → PathW (fullWorldXD 15235) addrPrompt wideP setupP shortFixP (I.ps π.length) (tokVals Tk 1))
    (sA : ∀ h h', HaltStopSrc (pA h h').hs)
    (sB2 : ∀ h h' h'', HaltStopSrc (pB2 h h' h'').hs)
    (sC1 : ∀ h h', HaltStopSrc (pC1 h h').hs)
    (postHandoff : ∀ t Cs, (I.dec π.length).Inv t Cs → ∃ kind,
      (decCutFirstFb 15235 addrPrompt (Gx kind) wideP DEC.Pw FrP DEC.s0 DEC.tab0 shortFixP
        (valL (machVal T Tk) T Tk π.length) Tk (.ref 2 :: machReads T Tk) [.num (.ref 1)] routeLoopBaseGpu).Inv t Cs)
    (graphA : ∀ h h', (pA h h').Goal (fun tF CF => ∃ kind, goalMV P Kr NE net env π kind 15235 1 tF CF))
    (graphB2 : ∀ h h' h'', (pB2 h h' h'').Goal (fun tF CF => ∃ kind, goalMV P Kr NE net env π kind 15235 2 tF CF))
    (graphB0 : ∀ h h' h'', (pB0 h h' h'').Goal (fun tF CF => ∃ kind, goalCV P Kr NE net env π kind 15235 T Je tF CF))
    (graphC1 : ∀ h h', (pC1 h h').Goal (fun tF CF => ∃ kind, goalMV P Kr NE net env π kind 15235 1 tF CF))
    (graphC0 : ∀ h h', (pC0 h h').Goal (fun tF CF => ∃ kind, goalCV P Kr NE net env π kind 15235 T Je tF CF)) :
    RouteGenGpu P Kr NE net env π T Tk Je chars!"emitted" (ldStT [] []) (ldStT (π.map natV) (machReads T Tk)) := by
  have hRT := route_refTokens P G Pg bytes lseSum lseNumerator NE net env leaves typed
    hπ (by omega) hlt hNE hnet
  have hv : ∀ j, Tk j ≤ 248319 := machTok_le P Kr NE net env π (hRT []) hπ hlt
  have hρ : ∀ j, ∃ n ≤ 2 ^ 20, machVal T Tk j = F64.ofNat n := by
    intro j
    by_cases hj : j = 0
    · subst j
      exact ⟨T, by omega, rfl⟩
    · exact ⟨Tk j, by have := hv j; omega, by simp only [machVal, ite_eq_right hj]⟩
  have hsH : (mlxOf DEC.s0.ffi).next ≤ 131072 := by
    rw [DEC.source]
    change (mlxOf Host.Load.Run.Tpl.DT.s0.ffi).next ≤ 131072
    rw [Host.Load.Run.Tpl.DT.mnext_val]
    decide
  have hsN : (mlxOf DEC.s0.ffi).nnext ≤ 2 ^ 40 := by
    rw [DEC.source]
    change (mlxOf Host.Load.Run.Tpl.DT.s0.ffi).nnext ≤ 2 ^ 40
    rw [Host.Load.Run.Tpl.DT.mnnext_val]
    decide
  have hc := decode_counter_bounds (B := routeLoopBaseGpu) (by omega : T ≤ 262144)
    hsH hsN le_rfl le_rfl le_rfl
  let D := fun (h3 : 3 ≤ T) (b0 : Host.Mlx.FfiAne.St) =>
    DEC.piecesFramedGpu (b0 := b0) (NB := 15235) (B := routeLoopBaseGpu)
      (ΔJ := DECG.ΔJ) (ΔH := DECG.ΔH) (ΔN := DECG.ΔN) (ρ := machVal T Tk)
      (toks := .ref 2 :: machReads T Tk) (π.map natV) (by simp) hρ hπ hL h3 hctx
      (fun j _ => hv j) le_rfl le_rfl le_rfl hc.1 hc.2.1 hc.2.2
  refine
    { ρ := machVal T Tk
      NB := 15235
      Pw := setupP
      Pd := DEC.Pw
      A := addrPrompt
      W := wideP
      fixA := shortFixP
      fixB := terminalFixP
      hsub := by decide
      I := I
      hPw := by unfold LdParams; decide
      hW := rfl
      hI := loadEntry
      Fr := FrP
      s0 := DEC.s0
      tab0 := DEC.tab0
      Itpl := DEC.inputs
      B := routeLoopBaseGpu
      ΔJ := DECG.ΔJ
      ΔH := DECG.ΔH
      ΔN := DECG.ΔN
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
      D := D
      Dg := fun h3 b0 => DEC.graphPiecesFramedGpu P Kr env π
        (b0 := b0) (NB := 15235) (B := routeLoopBaseGpu)
        (ΔJ := DECG.ΔJ) (ΔH := DECG.ΔH) (ΔN := DECG.ΔN)
        (π.map natV) (by simp) hρ hπ hL h3 hctx (fun j _ => hv j)
        le_rfl le_rfl le_rfl le_rfl hc.1 hc.2.1 hc.2.2
      tails := fun h3 b0 => DEC.tailsGpu (b0 := b0) (NB := 15235) (B := routeLoopBaseGpu)
        (ΔJ := DECG.ΔJ) (ΔH := DECG.ΔH) (ΔN := DECG.ΔN) (ρ := machVal T Tk)
        (toks := .ref 2 :: machReads T Tk) (π.map natV) (by simp) hρ hπ hL h3 hctx
        (fun j _ => hv j) le_rfl le_rfl le_rfl hc.1 hc.2.1 hc.2.2
      hc0 := fun _ _ => (by decide : 2586 ∈ shortFixP)
      hc1 := fun _ _ => (by decide : 2586 ∈ shortFixP)
      hc2 := fun _ _ => (by decide : 2586 ∈ shortFixP)
      hcE := by decide
      hb := by decide
      hgen := by decide
      hwc := rfl
      hwe := rfl
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
  · have hs := DEC.start Host.Mlx.FfiAne.St.empty 15235
    exact ⟨hs.htok, hs.start, hs.lo, hs.hi⟩
  · change ∀ e ∈ Host.Load.Run.Tpl.DEC_ord.S0.tab, e.noVar 17 = true
    rw [Host.Load.Run.Tpl.DEC_ord.S0_tab]
    exact Host.Load.Run.Tpl.DT.noVar17

end
end Host.Route

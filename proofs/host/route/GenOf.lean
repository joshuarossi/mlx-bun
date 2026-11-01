import host.route.Gen
import host.route.SetupEntry
import host.route.DecodeBounds
import host.sim.compose.a4b.GraphPiecesFixed
import host.sim.template.SavedBindings
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Compose Host.Ts.Sim.Template
open Host.Load.Run.Prompt
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-- Counter room reserved for the initial POST-to-decode handoff. -/
def routeLoopBase : LoopBase := ⟨2 ^ 60, 2 ^ 45, 2 ^ 61⟩

section
variable {C : M1Max.Contract}
  (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
  (bytes : KernelGpu.SetBytes) (lseSum : Bool)
  (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
  (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)
  (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
  (π : List Nat) (kind : Nat → Option Compiled) (T : Nat) (hπ : 1 ≤ π.length) (hlt : ∀ t ∈ π, t < 248320)
  (hT : 1 ≤ T) (hctx : π.length + T ≤ 262144)
  (hNE : NE.Succeeds net)
  (hnet : ∀ tab, Host.Mlx.SimGraph.Mach.AneNetOk net
    (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G bytes Pg lseSum lseNumerator).toKernelContract env tab))))

local notation "Kr" => routeKernel G bytes Pg lseSum lseNumerator
local notation "Tk" => machTok P Kr NE net env π
local notation "Je" => entryEnv (Host.Load.Run.Prompt.P.at0 (π.map natV) (machReads T Tk))
local notation "FrP" => framesP DEC.s0 (π.map natV)
local notation "Gx" => machGxV P Kr NE net env π kind 15235 DEC.inputs

/-- Assemble the route from the prefill bundle. The remaining premises name the POST,
short-path executions and graph facts, and the two connections of the prefill invariants. -/
noncomputable def routeGenOf
    (I : PrefInvsW (fullWorldXD 15235).F)
    (Pp : Pieces (fullWorldXD 15235).F I)
    (loadEntry : CutConv (ldPromptCut 15235 setupP wideP (ldStT [] []) T Tk π) (I.ld π.length))
    (postPieces : RoutePieces (fullWorldXD 15235).F I T Tk)
    (shortPaths : PathPiecesW (fullWorldXD 15235) addrPrompt setupP wideP terminalFixP Tk
      (postPieces.cuts.b_pA_cut (Lin.Cls.routeI π.length T (Tk 1) (Tk 2)))
      (postPieces.cuts.b_pB_cut (Lin.Cls.routeI π.length T (Tk 1) (Tk 2)))
      (postPieces.cuts.b_pC_cut (Lin.Cls.routeI π.length T (Tk 1) (Tk 2))))
    (postHandoff : CutConv (I.dec π.length)
      (decCutFirstFb 15235 addrPrompt Gx wideP DEC.Pw FrP DEC.s0 DEC.tab0 terminalFixP
        (valL (machVal T Tk) T Tk π.length) Tk (.ref 2 :: machReads T Tk) [.num (.ref 1)] routeLoopBase))
    (graphA : shortPaths.pA.Goal (goalMV P Kr NE net env π kind 15235 1))
    (graphB2 : shortPaths.pB2.Goal (goalMV P Kr NE net env π kind 15235 2))
    (graphB0 : shortPaths.pB0.Goal (goalCV P Kr NE net env π kind 15235 T Je))
    (graphC1 : shortPaths.pC1.Goal (goalMV P Kr NE net env π kind 15235 1))
    (graphC0 : shortPaths.pC0.Goal (goalCV P Kr NE net env π kind 15235 T Je)) :
    RouteGen P Kr NE net env π T Tk Je chars!"emitted" (ldStT [] []) := by
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
  have hc := decode_counter_bounds (B := routeLoopBase) (by omega : T ≤ 262144)
    hsH hsN le_rfl le_rfl le_rfl
  let D := fun (h3 : 3 ≤ T) (b0 : Host.Mlx.FfiAne.St) =>
    DEC.piecesFramedFixed (b0 := b0) (NB := 15235) (B := routeLoopBase)
      (ΔJ := DEC.ΔJ) (ΔH := DEC.ΔH) (ΔN := DEC.ΔN) (ρ := machVal T Tk)
      (toks := .ref 2 :: machReads T Tk) (π.map natV) (by simp) hρ hπ h3 hctx
      (fun j _ => hv j) le_rfl le_rfl le_rfl hc.1 hc.2.1 hc.2.2
  refine
    { kind := kind
      NB := 15235
      Pw := setupP
      Pd := DEC.Pw
      A := addrPrompt
      W := wideP
      fixA := terminalFixP
      I := I
      hPw := by unfold LdParams; decide
      hW := rfl
      hI := loadEntry
      Fr := FrP
      s0 := DEC.s0
      tab0 := DEC.tab0
      Itpl := DEC.inputs
      B := routeLoopBase
      ΔJ := DEC.ΔJ
      ΔH := DEC.ΔH
      ΔN := DEC.ΔN
      Pp := Pp
      H := postPieces
      Hp := shortPaths
      D := D
      Dg := fun h3 b0 => DEC.graphPiecesFramedFixed P Kr env π
        (b0 := b0) (NB := 15235) (B := routeLoopBase)
        (ΔJ := DEC.ΔJ) (ΔH := DEC.ΔH) (ΔN := DEC.ΔN)
        (π.map natV) (by simp) hρ hπ h3 hctx (fun j _ => hv j)
        le_rfl le_rfl le_rfl le_rfl hc.1 hc.2.1 hc.2.2
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

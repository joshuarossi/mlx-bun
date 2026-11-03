import host.route.GenOfHooks
import host.route.PromptLoadedCut
import host.sim.compose.a4b.FillOneP
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Compose Host.Ts.Sim.Template
open Host.Ts.Sim.Compose.FillPost (classOne hooksOne memOneC memOne_enter memOne_keep piecesOne hfinCold)
open Host.Ts.Sim.Compose.Gpu (noneCut)
open Host.Load.Run.Prompt
open Host.Load.Run.Tpl (PRE_pl_head.s0)
open Host.Route.PrefGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # The route of a one-token prompt -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (leaves : Leaves code env.weights)
  (a T : Nat) (tk : Nat → Nat)

include leaves in
/-- The boot's end, at the prompt `[a]`. -/
theorem loadOne :
    CutConv (ldPromptCutAt 15235 setupP wideP (ldStT [] []) T tk [a] (ldStT (List.map natV [a]) (machReads T tk)))
      (withMem (memOneC P KR net env a T tk 1) (FillSetupEarly.ldPinCut 15235 T tk [a] 1)) := fun x hr hb =>
  have hm := ld_mem P KR net env [a] leaves (List.map natV [a]) (machReads T tk) hb 1
  ⟨x, rfl, rfl, hr, ⟨hb.1.1, hb.1.2⟩, rfl, hm.1, hm.2, ld_from [a] hb⟩

end

section
variable {C : M1Max.Contract}
  (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
  (bytes : KernelGpu.SetBytes) (lseSum : Bool)
  (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
  (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)
  (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
  (a T : Nat) (ha : a < 248320) (hT : 1 ≤ T) (hctx : [a].length + T ≤ 262144)
  (hNE : NE.Succeeds net)
  (hnet : ∀ tab, Host.Mlx.SimGraph.Mach.AneNetOk net
    (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G bytes Pg lseSum lseNumerator).toKernelContract env tab))))

local notation "Kr" => routeKernel G bytes Pg lseSum lseNumerator
local notation "Tk" => machTok P Kr NE net env [a]
local notation "Je" => entryEnv (Host.Load.Run.Prompt.P.at0 (List.map natV [a]) (machReads T Tk))

/-- POST's hooks of the prompt `[a]`, at the array capacity 4096. -/
noncomputable def hooksR : FillPost.Hooks 15235 T Tk [a] 4096 15235 (classOne 15235 T Tk [a] 4096 15235 (by decide)) :=
  have hlt : ∀ t ∈ [a], t < 248320 := fun t ht => by
    obtain rfl := List.mem_singleton.mp ht
    exact ha
  have hRT := route_refTokens P G Pg bytes lseSum lseNumerator NE net env leaves typed (π := [a]) (by simp) (by simp) hlt hNE hnet
  have htk : ∀ j, Tk j ≤ 248319 := machTok_le P Kr NE net env [a] (hRT []) (by simp) hlt
  hooksOne ha leaves typed hRT (fun _ => oneKept) rfl (fun _ => 4010) rfl le_rfl (by decide) (by decide) (by decide) hT
    (fun tab j _ => machTok_def P Kr NE net env [a] (hRT []) (by simp) tab j) (by have := htk 1; omega)

/-- **The route of the prompt `[a]`.** -/
noncomputable def routeGenOne :
    RouteGenGpu P Kr NE net env [a] T Tk Je chars!"emitted" (ldStT [] []) (ldStT (List.map natV [a]) (machReads T Tk)) :=
  routeGenOfHooks P G Pg bytes lseSum lseNumerator NE net env leaves typed [a] T (by simp) (by simp)
    (fun t ht => by
      obtain rfl := List.mem_singleton.mp ht
      exact ha)
    hT hctx hNE hnet (hooksR P G Pg bytes lseSum lseNumerator NE net env leaves typed a T ha hT hctx hNE hnet) rfl
    (fun L => withMem (memOneC P Kr net env a T Tk L) (FillSetupEarly.ldPinCut 15235 T Tk [a] L))
    (fun L => withMem (memOneC P Kr net env a T Tk L) (SetupCommon.nextCut 15235 T Tk [a] L))
    (fun _ => noneCut PRE_pl_head.s0) (fun _ _ => noneCut PRE_pl_head.s0)
    (by decide)
    (piecesOne (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (cap := 4096) (Kept := fun _ => oneKept) (Kn := fun _ => 4010) (by decide) (by decide) ha
      (hooksR P G Pg bytes lseSum lseNumerator NE net env leaves typed a T ha hT hctx hNE hnet)
      (fun _ _ _ h v m => memOne_enter h v m) (fun _ _ _ h m => memOne_keep h m)
      (hfinCold (Cert.Row.rowCr 0) rfl rfl ha le_rfl))
    (loadOne P Kr net env leaves a T Tk)

local notation "S0" => Host.Load.Run.Prompt.P.at0 (List.map natV [a]) (machReads T Tk)

include ha hT hctx hNE hnet in
/-- **The route of a one-token prompt**, from the boot's two runs. -/
theorem route_gen_one (hs : bootL (RoutePrompt.cx [a]) (routeWorld T Tk) 2000 = some S0) (N0 : Nat)
    (hrun : runC (fullWorldXD 15235).F N0 (bootStart S0) (routeServer T Tk) =
      some (ldStT (List.map natV [a]) (machReads T Tk), routeServer T Tk)) :
    ∃ kind, RouteOutcomeV P Kr NE net env leaves typed [a] kind T S0 15235 := by
  have hlt : ∀ t ∈ [a], t < 248320 := fun t ht => by
    obtain rfl := List.mem_singleton.mp ht
    exact ha
  have hRT := route_refTokens P G Pg bytes lseSum lseNumerator NE net env leaves typed (π := [a]) (by simp) (by simp) hlt hNE hnet
  have hTb : T ≤ 2 ^ 20 := by
    simp only [List.length_cons, List.length_nil] at hctx
    omega
  let Gn := routeGenOne P G Pg bytes lseSum lseNumerator NE net env leaves typed a T ha hT hctx hNE hnet
  exact route_gen_gpu P G Pg bytes lseSum lseNumerator NE env leaves typed [a] T (by simp) (by simp) hlt hT hctx net hNE hnet S0 hs Gn
    ⟨N0, _, _, hrun, cutConv_inv Gn.hI (ldPromptCutAt_of_inv (LoadedCut.ldPromptCut_inv Gn.NB Gn.Pw Gn.hPw Gn.Wl Gn.hW [a] hlt T _ hTb
      fun j => Nat.le_trans (machTok_le P _ NE net env [a] (hRT []) (by simp) hlt j) (by decide)))⟩

end
end Host.Route

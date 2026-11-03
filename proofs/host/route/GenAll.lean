import host.route.GenOne
import host.route.GenVW
import host.route.GenX13
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Compose
open Host.Load.Run.Prompt
open Host.Route.PrefGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # The route of every prompt of at most 224 tokens

`routeGenAll`: `RouteGenGpu` by the prompt's length: one token (`routeGenOne`), 3 to 6 (`routeGenX1`-`X3`), 10 to 224 (`routeGenVW`).
Two tokens (x0) and 7 to 9 (x4) are premises until their prefill pieces land. `route_gen_all`: the route's outcome from the boot's two
runs. -/

section
variable {C : M1Max.Contract}
  (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
  (bytes : KernelGpu.SetBytes) (lseSum : Bool)
  (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
  (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)
  (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) (T : Nat) (hT : 1 ≤ T)
  (hNE : NE.Succeeds net)
  (hnet : ∀ tab, Host.Mlx.SimGraph.Mach.AneNetOk net
    (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G bytes Pg lseSum lseNumerator).toKernelContract env tab))))

local notation "Kr" => routeKernel G bytes Pg lseSum lseNumerator
local notation "Gen" π => RouteGenGpu P Kr NE net env π T (machTok P Kr NE net env π)
  (entryEnv (Host.Load.Run.Prompt.P.at0 (List.map natV π) (machReads T (machTok P Kr NE net env π)))) chars!"emitted" (ldStT [] [])
  (ldStT (List.map natV π) (machReads T (machTok P Kr NE net env π)))

/-- **The route of a prompt of at most 224 tokens**, by its length. -/
noncomputable def routeGenAll (π : List Nat) (hπ : 1 ≤ π.length) (hL : π.length ≤ 224) (hlt : ∀ t ∈ π, t < 248320)
    (hctx : π.length + T ≤ 262144)
    (gen2 : π.length = 2 → Gen π) (gen79 : 7 ≤ π.length → π.length ≤ 9 → Gen π) : Gen π :=
  match π, hπ, hL, hlt, hctx, gen2, gen79 with
  | [a], _, _, hlt, hctx, _, _ =>
    routeGenOne P G Pg bytes lseSum lseNumerator NE net env leaves typed a T (hlt a (List.mem_singleton_self a)) hT hctx hNE hnet
  | a :: b :: rest, _, hL, hlt, hctx, gen2, gen79 =>
    have hge : 2 ≤ (a :: b :: rest).length := by simp
    if h2 : (a :: b :: rest).length = 2 then gen2 h2
    else if h4 : (a :: b :: rest).length ≤ 4 then
      routeGenX1 P G Pg bytes lseSum lseNumerator NE net env leaves typed (a :: b :: rest) T (by omega) (by omega) hlt hT hctx hNE hnet h4
    else if h5 : (a :: b :: rest).length = 5 then
      routeGenX2 P G Pg bytes lseSum lseNumerator NE net env leaves typed (a :: b :: rest) T (by omega) (by omega) hlt hT hctx hNE hnet h5
    else if h6 : (a :: b :: rest).length = 6 then
      routeGenX3 P G Pg bytes lseSum lseNumerator NE net env leaves typed (a :: b :: rest) T (by omega) (by omega) hlt hT hctx hNE hnet h6
    else if h9 : (a :: b :: rest).length ≤ 9 then gen79 (by omega) h9
    else routeGenVW P G Pg bytes lseSum lseNumerator NE net env leaves typed (a :: b :: rest) T (by omega) hL hlt hT hctx hNE hnet

end

section
variable {C : M1Max.Contract}

/-- **The route of a prompt of at most 224 tokens**, from the boot's two runs. Prompts of 2 and of 7 to 9 tokens take their
`RouteGenGpu` as premises. -/
theorem route_gen_all (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
    (bytes : KernelGpu.SetBytes) (lseSum : Bool) (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
    (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (π : List Nat) (T : Nat) (hπ : 1 ≤ π.length) (hL : π.length ≤ 224) (hlt : ∀ t ∈ π, t < 248320) (hT : 1 ≤ T)
    (hctx : π.length + T ≤ 262144) (hNE : NE.Succeeds net)
    (hnet : ∀ tab, Host.Mlx.SimGraph.Mach.AneNetOk net
      (stageWeights (weights (firstValues P.toMlxContract (routeKernel G bytes Pg lseSum lseNumerator).toKernelContract env tab))))
    (gen2 : π.length = 2 → RouteGenGpu P (routeKernel G bytes Pg lseSum lseNumerator) NE net env π T
      (machTok P (routeKernel G bytes Pg lseSum lseNumerator) NE net env π)
      (entryEnv (Host.Load.Run.Prompt.P.at0 (List.map natV π) (machReads T (machTok P (routeKernel G bytes Pg lseSum lseNumerator) NE net env π))))
      chars!"emitted" (ldStT [] []) (ldStT (List.map natV π) (machReads T (machTok P (routeKernel G bytes Pg lseSum lseNumerator) NE net env π))))
    (gen79 : 7 ≤ π.length → π.length ≤ 9 → RouteGenGpu P (routeKernel G bytes Pg lseSum lseNumerator) NE net env π T
      (machTok P (routeKernel G bytes Pg lseSum lseNumerator) NE net env π)
      (entryEnv (Host.Load.Run.Prompt.P.at0 (List.map natV π) (machReads T (machTok P (routeKernel G bytes Pg lseSum lseNumerator) NE net env π))))
      chars!"emitted" (ldStT [] []) (ldStT (List.map natV π) (machReads T (machTok P (routeKernel G bytes Pg lseSum lseNumerator) NE net env π))))
    (hs : bootL (RoutePrompt.cx π) (routeWorld T (machTok P (routeKernel G bytes Pg lseSum lseNumerator) NE net env π)) 2000 =
      some (Host.Load.Run.Prompt.P.at0 (List.map natV π) (machReads T (machTok P (routeKernel G bytes Pg lseSum lseNumerator) NE net env π))))
    (hrun : ∀ NB, ∃ N0, runC (fullWorldXD NB).F N0
      (bootStart (Host.Load.Run.Prompt.P.at0 (List.map natV π) (machReads T (machTok P (routeKernel G bytes Pg lseSum lseNumerator) NE net env π))))
      (routeServer T (machTok P (routeKernel G bytes Pg lseSum lseNumerator) NE net env π)) =
      some (ldStT (List.map natV π) (machReads T (machTok P (routeKernel G bytes Pg lseSum lseNumerator) NE net env π)),
        routeServer T (machTok P (routeKernel G bytes Pg lseSum lseNumerator) NE net env π))) :
    ∃ kind NB, RouteOutcomeV P (routeKernel G bytes Pg lseSum lseNumerator) NE net env leaves typed π kind T
      (Host.Load.Run.Prompt.P.at0 (List.map natV π) (machReads T (machTok P (routeKernel G bytes Pg lseSum lseNumerator) NE net env π))) NB := by
  have hRT := route_refTokens P G Pg bytes lseSum lseNumerator NE net env leaves typed hπ (by omega) hlt hNE hnet
  let Gn := routeGenAll P G Pg bytes lseSum lseNumerator NE net env leaves typed T hT hNE hnet π hπ hL hlt hctx gen2 gen79
  obtain ⟨N0, hr⟩ := hrun Gn.NB
  obtain ⟨kind, h⟩ := route_gen_gpu P G Pg bytes lseSum lseNumerator NE env leaves typed π T hπ hL hlt hT hctx net hNE hnet _ hs Gn
    ⟨N0, _, _, hr, cutConv_inv Gn.hI (ldPromptCutAt_of_inv (LoadedCut.ldPromptCut_inv Gn.NB Gn.Pw Gn.hPw Gn.Wl Gn.hW π hlt T _ (Nat.le_trans (by omega : T ≤ 262143) (by decide))
      fun j => Nat.le_trans (machTok_le P _ NE _ env π (hRT []) hπ hlt j) (by decide)))⟩
  exact ⟨kind, Gn.NB, h⟩

end
end Host.Route

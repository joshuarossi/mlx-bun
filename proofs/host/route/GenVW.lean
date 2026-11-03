import host.route.GenVWH
import host.route.cert.Fin.Caps
import host.sim.compose.a4b.FillVWP
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Compose Host.Ts.Sim.Template
open Host.Ts.Sim.Compose.FillPost (classVW hooksVW invsVW piecesVW loadVW memVW0_enter memVW0_keep)
open Host.Load.Run.Prompt
open Host.Route.PrefGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # The route of a VW prompt: 10 to 224 tokens -/

section
variable {C : M1Max.Contract}
  (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
  (bytes : KernelGpu.SetBytes) (lseSum : Bool)
  (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
  (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)
  (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
  (π : List Nat) (T : Nat) (hL10 : 10 ≤ π.length) (hL : π.length ≤ 224)
  (hlt : ∀ t ∈ π, t < 248320) (hT : 1 ≤ T) (hctx : π.length + T ≤ 262144)
  (hNE : NE.Succeeds net)
  (hnet : ∀ tab, Host.Mlx.SimGraph.Mach.AneNetOk net
    (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G bytes Pg lseSum lseNumerator).toKernelContract env tab))))

local notation "Kr" => routeKernel G bytes Pg lseSum lseNumerator
local notation "Tk" => machTok P Kr NE net env π
local notation "Je" => entryEnv (Host.Load.Run.Prompt.P.at0 (List.map natV π) (machReads T Tk))

/-- **The route of a VW prompt.** -/
noncomputable def routeGenVW :
    RouteGenGpu P Kr NE net env π T Tk Je chars!"emitted" (ldStT [] []) (ldStT (List.map natV π) (machReads T Tk)) :=
  have hπ : ∀ k ∈ π, k < 248320 := hlt
  have hlt31 : ∀ t ∈ π, t < 2 ^ 31 := fun t ht => by have := hlt t ht; omega
  have hpre := fun tab => Host.Route.Cert.Fin.prefill_pre P Kr NE (Kr).inPlace net env π Pg rfl leaves typed (by omega) (by omega)
    (Host.Mlx.SimGraph.Mach.scheduleTyped P Kr NE net env π leaves typed (by omega) hlt hNE hnet) tab
  routeGenOfHooks P G Pg bytes lseSum lseNumerator NE net env leaves typed π T (by omega) hL hlt hT hctx hNE hnet
    (hooksRVW P G Pg bytes lseSum lseNumerator NE net env leaves typed π T hL10 hL hlt hT hNE hnet) rfl
    (invsVW (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (hooksRVW P G Pg bytes lseSum lseNumerator NE net env leaves typed π T hL10 hL hlt hT hNE hnet)).ld
    (invsVW (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (hooksRVW P G Pg bytes lseSum lseNumerator NE net env leaves typed π T hL10 hL hlt hT hNE hnet)).pc0
    (invsVW (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (hooksRVW P G Pg bytes lseSum lseNumerator NE net env leaves typed π T hL10 hL hlt hT hNE hnet)).pf
    (invsVW (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (hooksRVW P G Pg bytes lseSum lseNumerator NE net env leaves typed π T hL10 hL hlt hT hNE hnet)).pc
    (by decide)
    (piecesVW (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (by decide) (by decide) (by decide) hL10 hL hπ hlt31
      leaves typed hpre (hooksRVW P G Pg bytes lseSum lseNumerator NE net env leaves typed π T hL10 hL hlt hT hNE hnet)
      (fun _ _ _ h v m => memVW0_enter h v m) (fun _ _ _ h m => memVW0_keep h m))
    (loadVW leaves)

end
end Host.Route

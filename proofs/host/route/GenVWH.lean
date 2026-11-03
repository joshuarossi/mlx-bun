import host.route.GenOfHooks
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

/-! # POST's hooks of a VW prompt -/

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

/-- POST's hooks of a VW prompt, at the class's capacity 70039 and the tail's 216028. -/
noncomputable def hooksRVW : FillPost.Hooks 15235 T Tk π 216028 19057 (classVW 15235 T Tk π 70039 19057 (by decide)) :=
  have hRT := route_refTokens P G Pg bytes lseSum lseNumerator NE net env leaves typed (π := π) (by omega) (by omega) hlt hNE hnet
  have htk : ∀ j, Tk j ≤ 248319 := machTok_le P Kr NE net env π (hRT []) (by omega) hlt
  hooksVW (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) leaves typed hRT (by omega) hL (by decide) (by decide)
    (by decide) hT (fun tab j _ => machTok_def P Kr NE net env π (hRT []) (by omega) tab j) (by have := htk 1; omega)

end
end Host.Route

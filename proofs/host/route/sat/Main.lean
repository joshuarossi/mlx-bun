import host.route.sat.Machine
import host.route.sat.Mlx
import host.route.sat.Gpu
import host.route.sat.Checkpoint
import host.mlx.NeuralEngine

namespace Host.Route.Sat
open Inference Inference.Contracts.Mlx Host.Mlx Host.Mlx.FfiEval Host.Load.Program
open Host.Load.Run.Full (code)

/-! # `route_main`'s trust boundary is jointly satisfiable

`RouteTrust` is every premise `route_main` (`host.route.Main`) quantifies over but the pending `Gn : RouteGen` and the
prompt's own bounds: the machine, MLX, the GPU with its pipelines and `setBytes`, the logsumexp choices, the Neural
Engine, the checkpoint over the actual graph `code`, and the surfaces' initial contents. `evaluates` says the Neural
Engine evaluates every program on every input, which gives `NE.Succeeds net` at every `net` (`host.route.sat.Route`).
None of it depends on the prompt `π` or the budget `T`, so one model serves every prompt.

`routeTrust` is a mathematical model of these contracts, not a description of the hardware. -/

/-- The trust boundary of `route_main`. -/
structure RouteTrust where
  C : M1Max.Contract
  P : MlxPrefillContract C
  G : Metal.Gpu C
  Pg : KernelGpu.RoutePipelines G
  B : KernelGpu.SetBytes
  lseSum : Bool
  lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction
  NE : NeuralEngine
  env : FfiEval.Env InKey
  leaves : Leaves code env.weights
  typed : TypedCheckpoint env.weights
  init : Nat → Surface
  evaluates : ∀ prog ins, (NE.eval prog ins).isSome = true

/-- The Neural Engine of the model: every program evaluates, to zeros. -/
def neuralEngineModel : NeuralEngine := ⟨fun _ _ => some fun _ => 0⟩

/-- **A model of the whole trust boundary.** -/
noncomputable def routeTrust : RouteTrust where
  C := machineModel
  P := mlxModel machineModel
  G := gpuModel machineModel
  Pg := gpuModel_pipelines machineModel
  B := setBytesModel
  lseSum := false
  lseNumerator := .separate
  NE := neuralEngineModel
  env := modelEnv
  leaves := modelLeaves
  typed := modelTyped
  init := fun _ _ => 0
  evaluates := fun _ _ => rfl

/-- **`route_main`'s trust boundary is jointly satisfiable**, for the actual graph and any prompt. -/
theorem route_trust_satisfiable : Nonempty RouteTrust := ⟨routeTrust⟩

end Host.Route.Sat

import host.load.run.full.SourceTokens
import host.mlx.KernelGpu

namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (ForwardAt Gr)

/-- **The complete source route on the GPU.** `source_tokens` with the route's custom kernels run by the GPU:
the kernel contract is `KernelGpu.ofGpu G limits lseSum lseNumerator`, every field proved from its kernel's Metal
source. Premises: the operation contract `C`, MLX's native operations `M`, the GPU assumption `G`, the pipelines'
threadgroup limits `limits`, the native logsumexp's choices, the environment and checkpoint (`env`, `leaves`, `typed`),
its parameter ranges, and the branch premise selecting the non-EOS route. -/
theorem source_tokens_gpu {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (G : Metal.Gpu C)
    (limits : KernelGpu.RoutePipelines G) (lseSum : Bool) (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters
      (firstPipeline M (KernelGpu.ofGpu G limits lseSum lseNumerator) env [] leaves typed))
    (T : Nat) (hT : 1 ≤ T) (supported : T ≤ 262144)
    (notEos : ∀ i : Fin T, F64.test .eq (.fin false 248044 0)
      (F64.ofNat ((firstContext M (KernelGpu.ofGpu G limits lseSum lseNumerator) env [] leaves typed parameters).run
        promptToken (i.val + 1) (by omega)).token.val) = false) :
    let K := KernelGpu.ofGpu G limits lseSum lseNumerator
    let ρ := recurrenceValuation M K env leaves typed parameters T
    ∃ N final server, (∀ n, N ≤ n →
        ((bootL Route.cx (Tail.worldTail (Tpl.tailReads ρ T)) 2000).bind fun start =>
          runC Host.Load.ffi n start ⟨P.S0.tab.map (SymE.eval ρ)⟩) = some (final, server)) ∧
      emittedNumbers final (entryEnv P.s0) server = some (List.ofFn fun i : Fin T =>
        F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken (i.val + 1) (by omega)).token.val) ∧
      firstPipeline M K env server.tab leaves typed = initialPipeline M K env [] leaves typed ∧
      (∀ time, 1 ≤ time → ∀ h2 : time ≤ T, ∃ caches output,
        ForwardAt M K env server.tab leaves typed (parameters_for_table M K env leaves typed parameters server.tab)
          time (by omega) caches output (Gr server.tab final.ffi.mlx)) ∧
      ReadbackValues M K env (CSrv.val server) (Gr server.tab final.ffi.mlx) final.ffi.mlx.items ∧
      (∃ caches output, Sim.ExtractSim.cachesT final (entryEnv P.s0) = some caches ∧
        ForwardAt M K env server.tab leaves typed (parameters_for_table M K env leaves typed parameters server.tab)
          T supported caches output (Gr server.tab final.ffi.mlx)) ∧
      ∃ v, final.ctl = .halt (.normal v) :=
  source_tokens M (KernelGpu.ofGpu G limits lseSum lseNumerator) env leaves typed parameters T hT supported notEos

end Host.Load.Run.Full

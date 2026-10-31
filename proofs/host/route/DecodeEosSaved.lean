import host.route.DecodeEos
import host.sim.template.SavedBindings
import host.sim.compose.a4b.EosCutFramed
import host.sim.world.DecodeSourceFramed

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Mlx.SimGraph.Mach (AneNetOk)
open Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Compose Host.Ts.Sim.Prefill
open Host.Load.Run.Prompt
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

variable {C : M1Max.Contract}

/-- The actual six-case decode loop followed by the current middle-EOS exit.
The starting invariant and its already emitted first token are initialization obligations;
all subsequent execution, EOS exclusion, graph preservation and stopping follow from the proofs. -/
theorem decode_middle_eos_saved (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
    (bytes : KernelGpu.SetBytes) (lseSum : Bool)
    (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
    (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (π : List Nat) (T : Nat) (hπ : 1 ≤ π.length) (hlt : ∀ t ∈ π, t < 248320)
    (hT : 1 ≤ T) (hctx : π.length + T ≤ 262144)
    (hNE : NE.Succeeds net)
    (hnet : ∀ tab, AneNetOk net (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G bytes Pg lseSum lseNumerator).toKernelContract env tab))))
    (b0 : Host.Mlx.FfiAne.St) (q : List Val) (hql : q.length = π.length) (base : LoopBase)
    (hJ : T * DEC.ΔJ + base.D < Sim.bound)
    (hH : (mlxOf DEC.s0.ffi).next + T * DEC.ΔH + base.H +
      (DEC.Pw.E - (mlxOf DEC.s0.ffi).next) < 2 ^ 46)
    (hN : (mlxOf DEC.s0.ffi).nnext + T * DEC.ΔN + base.N +
      (DEC.Pw.NE - (mlxOf DEC.s0.ffi).nnext) < 2 ^ 62)
    (k : Nat) (hk2 : 2 ≤ k) (hkT : k < T) :
    let KR := routeKernel G bytes Pg lseSum lseNumerator
    let tk := machTok P KR NE net env π
    let toks := .ref 2 :: machReads T tk
    let je := entryEnv (_root_.Host.Load.Run.Prompt.P.at0 (π.map natV) (machReads T tk))
    let Inv := DecodeInvW (fullWorldFb b0 15235) addrPrompt
      (machGx P KR NE net env π 15235 DEC.inputs) wideP DEC.Pw (framesP DEC.s0 q)
      DEC.s0 DEC.tab0 terminalFixP (valL (machVal T tk) T tk π.length) tk toks [.num (.ref 1)]
      base DEC.ΔJ DEC.ΔH DEC.ΔN
    ∀ t0 C0, Inv 1 t0 C0 → C0.val (.ref 1) = some (F64.ofNat (tk 1)) → FirstEos tk T k →
      ∃ N tF CF, (∀ n, N ≤ n → runC FF n t0 C0 = some (tF, CF)) ∧
        (∃ v, tF.ctl = .halt (.normal v)) ∧ CSrv.Le C0 CF ∧
        emittedValsW tF je chars!"emitted" CF = some (tokVals tk (k - 1)) ∧
        goalM P KR NE net env π 15235 k tF CF ∧ stopFin je tF := by
  intro KR tk toks je Inv
  exact decode_middle_eos P G Pg bytes lseSum lseNumerator NE net env leaves typed π T hπ hlt hT hctx
    hNE hnet b0 q hql base hJ hH hN je chars!"emitted"
    (_root_.Host.Load.Run.Prompt.saved_emitted (π.map natV) (machReads T tk))
    (_root_.Host.Load.Run.Prompt.saved_generation (π.map natV) (machReads T tk)) k hk2 hkT

end Host.Route

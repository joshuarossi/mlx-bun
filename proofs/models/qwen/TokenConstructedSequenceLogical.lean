import models.qwen.TokenConstructedSequenceMemory

namespace Inference.Models.Qwen.TokenConstructedSequenceLogical
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open TokenReadyMemory TokenReadyStepMemory TokenConstructedSequenceMemory
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {p : Pipeline} {time parameterCut steps : Nat} {context : Context p}
    {dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages}
    {initial : Ready p time parameterCut} {final : Ready p (time+steps) parameterCut}
    {token : Fin 248320}

-- Only the initial logical identity is required. In particular this does not
-- require the old physical Trace whose initial attention used concat(empty).
theorem Path.logical (path : Path context dispatch initial steps final)
    (initialSupported : time≤262144)
    (initialEq : initial.state.logical=TokenAutoregressive.run p context.parameters context.primitive
      context.sampling context.samplingPrimitive token context.angles time initialSupported) :
    ∀ supported : time+steps≤262144,
      final.state.logical=TokenAutoregressive.run p context.parameters context.primitive context.sampling
        context.samplingPrimitive token context.angles (time+steps) supported := by
  induction path with
  | zero => intro supported; exact initialEq
  | @next steps ready previous room supported ih =>
    intro finalSupported
    have before := ih (by omega)
    have next := (TokenConstructedStepMemory.witness ready context dispatch room).logical supported
    exact next.trans (congrArg (fun state => TokenAutoregressive.advance p context.parameters context.primitive
      context.sampling context.samplingPrimitive state (context.angles.value (time+steps))
      (context.angles.ranges (time+steps) (by omega)) supported
      (context.angles.target (time+steps)) (context.angles.error (time+steps))
      (context.angles.accuracy (time+steps) (by omega)) (context.angles.base (time+steps) (by omega))) before)

theorem Path.readback (path : Path context dispatch initial steps final)
    (initialSupported : time≤262144)
    (initialEq : initial.state.logical=TokenAutoregressive.run p context.parameters context.primitive
      context.sampling context.samplingPrimitive token context.angles time initialSupported)
    (supported : time+steps≤262144) :
    let reference := TokenAutoregressive.run p context.parameters context.primitive context.sampling
      context.samplingPrimitive token context.angles (time+steps) supported
    (final.state.index.read,final.state.readCaches)=(reference.token.val,reference.cache) := by
  have same := Path.logical path initialSupported initialEq supported
  apply Prod.ext
  · exact final.state.index.read_correct.trans (congrArg (fun state => state.token.val) same)
  · exact final.state.caches_eq.trans (congrArg TokenAutoregressive.State.cache same)

variable (context : Context p) (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages)
    (initial : Ready p time parameterCut) (steps : Nat) (supported : time+steps≤262144)
    (room : initial.frontier.cursor+bytes p time steps≤2^64)
    (initialSupported : time≤262144)
    (initialEq : initial.state.logical=TokenAutoregressive.run p context.parameters context.primitive
      context.sampling context.samplingPrimitive token context.angles time initialSupported)

include initialSupported initialEq

theorem run_logical : (run context dispatch initial steps supported room).ready.state.logical=
    TokenAutoregressive.run p context.parameters context.primitive context.sampling context.samplingPrimitive
      token context.angles (time+steps) supported :=
  Path.logical (run context dispatch initial steps supported room).path initialSupported initialEq supported

theorem run_readback :
    let actual := (run context dispatch initial steps supported room).ready.state
    let reference := TokenAutoregressive.run p context.parameters context.primitive context.sampling
      context.samplingPrimitive token context.angles (time+steps) supported
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) :=
  Path.readback (run context dispatch initial steps supported room).path initialSupported initialEq supported

end Inference.Models.Qwen.TokenConstructedSequenceLogical

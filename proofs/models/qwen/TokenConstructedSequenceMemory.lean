import models.qwen.TokenConstructedStepMemory

-- A finite, explicitly budgeted growth/reuse sequence. Every launch plan is derived
-- from its reached predecessor; no plan or allocation oracle is an input.
namespace Inference.Models.Qwen.TokenConstructedSequenceMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open TokenReadyMemory TokenReadyStepMemory
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages TokenWorkspaceFootprint.bytes

def bytes (p : Pipeline) (time : Nat) : Nat → Nat
  | 0 => 0
  | steps+1 => bytes p time steps+TokenWorkspaceFootprint.bytes p (time+steps)

variable {p : Pipeline} {time parameterCut : Nat}

inductive Path (context : Context p) (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages)
    (initial : Ready p time parameterCut) : (steps : Nat) → Ready p (time+steps) parameterCut → Prop where
  | zero : Path context dispatch initial 0 initial
  | next {steps : Nat} {ready : Ready p (time+steps) parameterCut}
      (previous : Path context dispatch initial steps ready)
      (room : ready.frontier.cursor+TokenWorkspaceFootprint.bytes p (time+steps)≤2^64)
      (supported : time+steps+1≤262144) :
      Path context dispatch initial (steps+1) (TokenConstructedStepMemory.next ready context dispatch room supported)

structure Result (context : Context p) (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages)
    (initial : Ready p time parameterCut) (steps : Nat) where
  ready : Ready p (time+steps) parameterCut
  cursor_eq : ready.frontier.cursor=initial.frontier.cursor+bytes p time steps
  path : Path context dispatch initial steps ready

variable (context : Context p) (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages)
  (initial : Ready p time parameterCut)

noncomputable def run : (steps : Nat) → time+steps≤262144 →
    initial.frontier.cursor+bytes p time steps≤2^64 → Result context dispatch initial steps
  | 0, _, _ => ⟨initial,by simp only [bytes,Nat.add_zero],.zero⟩
  | steps+1, supported, room => by
    have previousRoom : initial.frontier.cursor+bytes p time steps≤2^64 :=
      (Nat.le_add_right _ (TokenWorkspaceFootprint.bytes p (time+steps))).trans
        (by simpa only [bytes,Nat.add_assoc] using room)
    let previous := run steps (by omega) previousRoom
    have stepRoom : previous.ready.frontier.cursor+TokenWorkspaceFootprint.bytes p (time+steps)≤2^64 := by
      rw [previous.cursor_eq]
      simpa only [bytes,Nat.add_assoc] using room
    let next := TokenConstructedStepMemory.next previous.ready context dispatch stepRoom (by omega)
    refine ⟨next,?_,Path.next previous.path stepRoom (by omega)⟩
    change (TokenConstructedStepMemory.next previous.ready context dispatch stepRoom _).frontier.cursor=_
    rw [TokenConstructedStepMemory.next_cursor,previous.cursor_eq]
    simp only [bytes,Nat.add_assoc]

variable {context dispatch initial} {steps : Nat} {final : Ready p (time+steps) parameterCut}

theorem Path.parameters_protected (path : Path context dispatch initial steps final) (property : Nat → Nat → Prop) :
    final.parameters.Protected property ↔ initial.parameters.Protected property := by
  induction path with
  | zero => rfl
  | @next steps ready previous room supported ih =>
    exact ((TokenConstructedStepMemory.witness ready context dispatch room).parameters_protected supported property).trans ih

theorem Path.frame (path : Path context dispatch initial steps final)
    (region : TokenParameterConstruction.Region initial.parameters base size) (offset : Nat) (bound : offset<size) :
    final.state.index.bytes (base+offset)=initial.state.index.bytes (base+offset) := by
  induction path with
  | zero => rfl
  | @next steps ready previous room supported ih =>
    have retained : TokenParameterConstruction.Region ready.parameters base size :=
      fun property safe => region property ((previous.parameters_protected property).mp safe)
    exact ((TokenConstructedStepMemory.witness ready context dispatch room).other_region supported retained offset bound).trans ih

section Trace
variable {token : Fin 248320} {initialPlan : InitialCacheMemory.Plan p.graph.stages} {initialMemory : ByteMemory.Bytes}
  {index : Inference.State.TokenStorage.Buffer token}
  {shared : index.bytes=InitialCacheMemory.execute p.graph.stages initialPlan initialMemory}
  {original : TokenParameterMemory.Storage p index.bytes}

theorem Path.extend (path : Path context dispatch initial steps final)
    (trace : TokenParameterConstruction.Trace p context.parameters context.primitive context.sampling context.samplingPrimitive
      token initialPlan initialMemory index shared original context.angles initial.state initial.parameters) :
    TokenParameterConstruction.Trace p context.parameters context.primitive context.sampling context.samplingPrimitive
      token initialPlan initialMemory index shared original context.angles final.state final.parameters := by
  induction path with
  | zero => exact trace
  | @next steps ready previous room supported ih =>
    exact (TokenConstructedStepMemory.witness ready context dispatch room).extend supported ih

theorem Path.readback (path : Path context dispatch initial steps final)
    (trace : TokenParameterConstruction.Trace p context.parameters context.primitive context.sampling context.samplingPrimitive
      token initialPlan initialMemory index shared original context.angles initial.state initial.parameters)
    (supported : time+steps≤262144) :
    let reference := TokenAutoregressive.run p context.parameters context.primitive context.sampling context.samplingPrimitive
      token context.angles (time+steps) supported
    (final.state.index.read,final.state.readCaches)=(reference.token.val,reference.cache) :=
  (path.extend trace).readback supported
end Trace

theorem bytes_bound (p : Pipeline) (time steps : Nat) (supported : time+steps≤262144) :
    bytes p time steps≤steps*17614065888 := by
  induction steps with
  | zero => rfl
  | succ steps ih =>
    have before := ih (by omega)
    have next := TokenWorkspaceFootprint.supported_bound p (time+steps) (by omega)
    simpa only [bytes,Nat.succ_mul,Nat.one_mul] using Nat.add_le_add before next

noncomputable def toLimit (context : Context p) (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages)
    (initial : Ready p time parameterCut) (limit : Nat) (ordered : time≤limit) (supported : limit≤262144)
    (room : initial.frontier.cursor+bytes p time (limit-time)≤2^64) : Result context dispatch initial (limit-time) :=
  run context dispatch initial (limit-time) (by omega) room

end Inference.Models.Qwen.TokenConstructedSequenceMemory

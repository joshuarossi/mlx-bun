import models.qwen.TokenReuseStepMemory

-- A finite, explicitly budgeted reuse segment. Every launch plan is derived
-- from its reached predecessor; no plan or allocation oracle is an input.
namespace Inference.Models.Qwen.TokenReuseSequenceMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open TokenReadyMemory TokenReadyStepMemory
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages TokenNextPlanConstruction.bytes

def bytes (p : Pipeline) (time : Nat) : Nat → Nat
  | 0 => 0
  | steps+1 => bytes p time steps+TokenNextPlanConstruction.bytes p (time+steps)

variable {p : Pipeline} {time parameterCut : Nat}

inductive Path (context : Context p) (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages)
    (initial : Ready p time parameterCut) : (steps : Nat) → Ready p (time+steps) parameterCut → Prop where
  | zero : Path context dispatch initial 0 initial
  | next {steps : Nat} {ready : Ready p (time+steps) parameterCut}
      (previous : Path context dispatch initial steps ready)
      (room : ready.frontier.cursor+TokenNextPlanConstruction.bytes p (time+steps)≤2^64)
      (reuse : ¬Inference.State.KvAllocation.capacity (time+steps)<time+steps+1)
      (supported : time+steps+1≤262144) :
      Path context dispatch initial (steps+1) (TokenReuseStepMemory.next ready context dispatch room reuse supported)

structure Result (context : Context p) (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages)
    (initial : Ready p time parameterCut) (steps : Nat) where
  ready : Ready p (time+steps) parameterCut
  cursor_eq : ready.frontier.cursor=initial.frontier.cursor+bytes p time steps
  path : Path context dispatch initial steps ready

variable (context : Context p) (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages)
  (initial : Ready p time parameterCut)

noncomputable def run : (steps : Nat) → time+steps≤262144 →
    (∀ offset<steps, ¬Inference.State.KvAllocation.capacity (time+offset)<time+offset+1) →
    initial.frontier.cursor+bytes p time steps≤2^64 → Result context dispatch initial steps
  | 0, _, _, _ => ⟨initial,by simp only [bytes,Nat.add_zero],.zero⟩
  | steps+1, supported, reuse, room => by
    have previousRoom : initial.frontier.cursor+bytes p time steps≤2^64 :=
      (Nat.le_add_right _ (TokenNextPlanConstruction.bytes p (time+steps))).trans
        (by simpa only [bytes,Nat.add_assoc] using room)
    let previous := run steps (by omega) (fun offset inside => reuse offset (by omega)) previousRoom
    have stepRoom : previous.ready.frontier.cursor+TokenNextPlanConstruction.bytes p (time+steps)≤2^64 := by
      rw [previous.cursor_eq]
      simpa only [bytes,Nat.add_assoc] using room
    let next := TokenReuseStepMemory.next previous.ready context dispatch stepRoom (reuse steps (by omega)) (by omega)
    refine ⟨next,?_,Path.next previous.path stepRoom (reuse steps (by omega)) (by omega)⟩
    change (TokenReuseStepMemory.next previous.ready context dispatch stepRoom _ _).frontier.cursor=_
    rw [TokenReuseStepMemory.next_cursor,previous.cursor_eq]
    simp only [bytes,Nat.add_assoc]

variable {context dispatch initial} {steps : Nat} {final : Ready p (time+steps) parameterCut}

theorem Path.parameters_protected (path : Path context dispatch initial steps final) (property : Nat → Nat → Prop) :
    final.parameters.Protected property ↔ initial.parameters.Protected property := by
  induction path with
  | zero => rfl
  | @next steps ready previous room reuse supported ih =>
    exact ((TokenReuseStepMemory.witness ready context dispatch room reuse).parameters_protected supported property).trans ih

theorem Path.frame (path : Path context dispatch initial steps final)
    (region : TokenParameterConstruction.Region initial.parameters base size) (offset : Nat) (bound : offset<size) :
    final.state.index.bytes (base+offset)=initial.state.index.bytes (base+offset) := by
  induction path with
  | zero => rfl
  | @next steps ready previous room reuse supported ih =>
    have retained : TokenParameterConstruction.Region ready.parameters base size :=
      fun property safe => region property ((previous.parameters_protected property).mp safe)
    exact ((TokenReuseStepMemory.witness ready context dispatch room reuse).other_region supported retained offset bound).trans ih

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
  | @next steps ready previous room reuse supported ih =>
    exact (TokenReuseStepMemory.witness ready context dispatch room reuse).extend supported ih

theorem Path.readback (path : Path context dispatch initial steps final)
    (trace : TokenParameterConstruction.Trace p context.parameters context.primitive context.sampling context.samplingPrimitive
      token initialPlan initialMemory index shared original context.angles initial.state initial.parameters)
    (supported : time+steps≤262144) :
    let reference := TokenAutoregressive.run p context.parameters context.primitive context.sampling context.samplingPrimitive
      token context.angles (time+steps) supported
    (final.state.index.read,final.state.readCaches)=(reference.token.val,reference.cache) :=
  (path.extend trace).readback supported
end Trace

theorem reuse_first_block (n : Nat) (positive : 1≤n) (below : n<256) :
    ¬Inference.State.KvAllocation.capacity n<n+1 := by
  rw [Inference.State.KvAllocation.growth_iff,Nat.mod_eq_of_lt below]
  omega

theorem reuse_range (positive : 1≤time) (below : time+steps≤256) :
    ∀ offset<steps, ¬Inference.State.KvAllocation.capacity (time+offset)<time+offset+1 := by
  intro offset inside
  exact reuse_first_block _ (by omega) (by omega)

noncomputable def firstBlock (context : Context p) (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages)
    (initial : Ready p time parameterCut) (positive : 1≤time) (below : time≤256)
    (room : initial.frontier.cursor+bytes p time (256-time)≤2^64) : Result context dispatch initial (256-time) :=
  run context dispatch initial (256-time) (by omega) (reuse_range positive (by omega)) room

end Inference.Models.Qwen.TokenReuseSequenceMemory

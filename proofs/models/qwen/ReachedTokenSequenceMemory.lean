import models.qwen.ReachedTokenConstructedMemory
import models.qwen.TokenConstructedSequenceMemory

-- A finite, explicitly budgeted growth/reuse sequence. Every launch plan is derived
-- from its reached predecessor; no plan or allocation oracle is an input.
namespace Inference.Models.Qwen.ReachedTokenSequenceMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open TokenReadyMemory (Ready)
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages TokenWorkspaceFootprint.bytes

open TokenConstructedSequenceMemory (bytes)

variable {p : Pipeline} {time parameterCut : Nat}

inductive Path (context : ReachedTokenContext.Context p) (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages)
    (initial : Ready p time parameterCut) : (steps : Nat) → Ready p (time+steps) parameterCut → Prop where
  | zero : Path context dispatch initial 0 initial
  | next {steps : Nat} {ready : Ready p (time+steps) parameterCut}
      (previous : Path context dispatch initial steps ready)
      (room : ready.frontier.cursor+TokenWorkspaceFootprint.bytes p (time+steps)≤2^64)
      (supported : time+steps+1≤262144) :
      Path context dispatch initial (steps+1) (ReachedTokenConstructedMemory.next ready context dispatch room supported)

structure Result (context : ReachedTokenContext.Context p) (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages)
    (initial : Ready p time parameterCut) (steps : Nat) where
  ready : Ready p (time+steps) parameterCut
  cursor_eq : ready.frontier.cursor=initial.frontier.cursor+bytes p time steps
  path : Path context dispatch initial steps ready

variable (context : ReachedTokenContext.Context p) (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages)
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
    let next := ReachedTokenConstructedMemory.next previous.ready context dispatch stepRoom (by omega)
    refine ⟨next,?_,Path.next previous.path stepRoom (by omega)⟩
    change (ReachedTokenConstructedMemory.next previous.ready context dispatch stepRoom _).frontier.cursor=_
    rw [ReachedTokenConstructedMemory.next_cursor,previous.cursor_eq]
    simp only [bytes,Nat.add_assoc]

variable {context dispatch initial} {steps : Nat} {final : Ready p (time+steps) parameterCut}

theorem Path.parameters_protected (path : Path context dispatch initial steps final) (property : Nat → Nat → Prop) :
    final.parameters.Protected property ↔ initial.parameters.Protected property := by
  induction path with
  | zero => rfl
  | @next steps ready previous room supported ih =>
    exact ((ReachedTokenConstructedMemory.witness ready context dispatch room).parameters_protected supported property).trans ih

theorem Path.frame (path : Path context dispatch initial steps final)
    (region : TokenParameterConstruction.Region initial.parameters base size) (offset : Nat) (bound : offset<size) :
    final.state.index.bytes (base+offset)=initial.state.index.bytes (base+offset) := by
  induction path with
  | zero => rfl
  | @next steps ready previous room supported ih =>
    have retained : TokenParameterConstruction.Region ready.parameters base size :=
      fun property safe => region property ((previous.parameters_protected property).mp safe)
    exact ((ReachedTokenConstructedMemory.witness ready context dispatch room).other_region supported retained offset bound).trans ih



noncomputable def toLimit (context : ReachedTokenContext.Context p) (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages)
    (initial : Ready p time parameterCut) (limit : Nat) (ordered : time≤limit) (supported : limit≤262144)
    (room : initial.frontier.cursor+bytes p time (limit-time)≤2^64) : Result context dispatch initial (limit-time) :=
  run context dispatch initial (limit-time) (by omega) room


variable {token : Fin 248320}

theorem Path.logical (path : Path context dispatch initial steps final)
    (initialSupported : time≤262144)
    (initialEq : initial.state.logical=context.run token time initialSupported) :
    ∀ supported : time+steps≤262144,
      final.state.logical=context.run token (time+steps) supported := by
  induction path with
  | zero => intro supported; exact initialEq
  | @next steps ready previous room supported ih =>
    intro finalSupported
    have before := ih (by omega)
    rw [ReachedTokenConstructedMemory.next_logical]
    exact congrArg (fun state => ReachedTokenContext.Logical.advance p context.parameters context.primitive
      context.sampling context.samplingPrimitive state (context.angles.value (time+steps))
      (context.angles.ranges (time+steps) (by omega)) supported
      (context.angles.target (time+steps)) (context.angles.error (time+steps))
      (context.angles.accuracy (time+steps) (by omega)) (context.angles.base (time+steps) (by omega))) before

theorem Path.readback (path : Path context dispatch initial steps final)
    (initialSupported : time≤262144)
    (initialEq : initial.state.logical=context.run token time initialSupported)
    (supported : time+steps≤262144) :
    let reference := context.run token (time+steps) supported
    (final.state.index.read,final.state.readCaches)=(reference.token.val,reference.cache) := by
  have same := path.logical initialSupported initialEq supported
  apply Prod.ext
  · exact final.state.index.read_correct.trans (congrArg (fun state => state.token.val) same)
  · exact final.state.caches_eq.trans (congrArg TokenAutoregressive.State.cache same)

end Inference.Models.Qwen.ReachedTokenSequenceMemory

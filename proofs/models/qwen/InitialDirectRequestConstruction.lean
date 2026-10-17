import models.qwen.TokenDirectInitialReady
import models.qwen.InitialCacheParsedSourceConstruction
import models.qwen.TokenInitializationHighWater

namespace Inference.Models.Qwen.InitialDirectRequestConstruction
open Contracts.Mlx TokenInference TokenReadyMemory
open TokenBoundaryHighWater (Before)
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages TokenDirectInitialConstruction.bytes

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  {original : TokenParameterMemory.Storage p initialHeap}

def bytes (p : Pipeline) : Nat := 16+TokenInitializationHighWater.bytes+TokenDirectInitialConstruction.bytes p

structure Request (original : TokenParameterMemory.Storage p initialHeap) where
  token : Fin 248320
  frontier : ResidualDeltaHighWater.Frontier
  room : frontier.cursor+bytes p≤2^64
  parameters : original.Protected (Before frontier.cursor)
  dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages
  keyCopied : Bool
  valueCopied : Bool

variable (request : Request original)

def Request.scalars : InitialScalarConstruction.Workspace where
  base := request.frontier.cursor
  aligned := by have := request.frontier.aligned; omega
  bounded := by
    have := request.room
    change request.frontier.cursor+8≤2^64
    unfold bytes at this
    omega

theorem Request.scalar_safe : original.Protected
    (MemoryRegions.Disjoint request.scalars.base InitialScalarConstruction.bytes) :=
  original.protected_mono (fun _ _ inside => Or.inr inside) request.parameters

def Request.prefixParameters : TokenParameterMemory.Storage p (request.scalars.memory initialHeap) :=
  request.scalars.parameters initialHeap original request.scalar_safe

theorem Request.prefix_regions (property : Nat → Nat → Prop) :
    request.prefixParameters.Protected property ↔ original.Protected property :=
  request.scalars.parameters_regions initialHeap original request.scalar_safe property

def Request.initialFrontier : ResidualDeltaHighWater.Frontier where
  cursor := request.frontier.cursor+16
  aligned := by have := request.frontier.aligned; omega

theorem Request.initial_room : (TokenInitializationHighWater.next request.initialFrontier).cursor≤2^64 := by
  have := request.room
  change request.frontier.cursor+16+TokenInitializationHighWater.bytes≤2^64
  unfold bytes at this
  omega

theorem Request.prefix_bound : request.prefixParameters.Protected (Before request.initialFrontier.cursor) :=
  (request.prefix_regions _).mpr
    (original.protected_mono (fun _ _ before => TokenBoundaryHighWater.before_next before) request.parameters)

def Request.initialized : TokenInitializationMemory.Initialized p :=
  TokenInitializationHighWater.initialized request.prefixParameters request.token request.initialFrontier
    request.initial_room request.prefix_bound

def Request.initialWorkspace : TokenInitializationAllocation.Workspace p.graph.stages :=
  TokenInitializationHighWater.workspace request.initialFrontier request.initial_room

theorem Request.initial_separate : MemoryRegions.Disjoint request.initialWorkspace.base
    (TokenInitializationAllocation.bytes p.graph.stages) request.scalars.base InitialScalarConstruction.bytes := by
  apply Or.inr
  change request.frontier.cursor+8≤request.frontier.cursor+16
  omega

def Request.parsedSources : InitialCacheParsedSourceConstruction.Sources :=
  InitialCacheParsedSourceConstruction.initializedSources request.scalars initialHeap request.initialWorkspace
    request.initial_separate (token:=request.token)

theorem Request.parsed_executions : InitialCacheParsedSourceConstruction.Executes p.graph.stages request.initialWorkspace.caches
    (InitialCacheParsedSourceConstruction.entrySources request.scalars initialHeap request.initialWorkspace
      request.initial_separate (token:=request.token)) request.parsedSources :=
  InitialCacheParsedSourceConstruction.initialize_checked request.scalars initialHeap request.initialWorkspace request.initial_separate

theorem Request.initial_state_heap : request.initialized.state.index.bytes=request.parsedSources.history.bytes :=
  InitialCacheParsedSourceConstruction.initialized_state_heap request.scalars initialHeap request.initialWorkspace request.initial_separate

theorem Request.initial_logical : request.initialized.state.logical=TokenAutoregressive.initial p request.token := rfl

theorem Request.initial_parameter_regions (property : Nat → Nat → Prop) :
    request.initialized.parameters.Protected property ↔ original.Protected property :=
  (TokenInitializationHighWater.parameters_regions request.prefixParameters request.token request.initialFrontier
    request.initial_room request.prefix_bound property).trans (request.prefix_regions property)

def Request.first : TokenDirectInitialConstruction.Request request.initialized.parameters where
  cursor := (TokenInitializationHighWater.next request.initialFrontier).cursor
  aligned := (TokenInitializationHighWater.next request.initialFrontier).aligned
  room := by simpa only [bytes,Request.initialFrontier,TokenInitializationHighWater.next,Nat.add_assoc] using request.room
  token := TokenInitializationHighWater.token_bound request.prefixParameters request.token request.initialFrontier
    request.initial_room request.prefix_bound
  parameters := TokenInitializationHighWater.parameters_bound request.prefixParameters request.token request.initialFrontier
    request.initial_room request.prefix_bound
  caches := TokenInitializationHighWater.cache_bound request.prefixParameters request.token request.initialFrontier
    request.initial_room request.prefix_bound
  dispatch := request.dispatch
  keyCopied := request.keyCopied
  valueCopied := request.valueCopied

theorem Request.first_ordered : request.frontier.cursor≤request.first.cursor :=
  (Nat.le_add_right _ 16).trans (TokenInitializationHighWater.le_next request.initialFrontier)

theorem Request.initial_parameters_cut : request.initialized.parameters.Protected (Before request.frontier.cursor) :=
  (request.initial_parameter_regions _).mpr request.parameters

theorem Request.initial_frame (region : TokenParameterConstruction.Region original base size) (offset : Nat) (bound : offset<size) :
    request.initialized.state.index.bytes (base+offset)=initialHeap (base+offset) := by
  rw [request.initial_state_heap]
  have before := region _ request.parameters
  exact InitialCacheParsedSourceConstruction.initialize_frame request.scalars initialHeap request.initialWorkspace request.initial_separate
    (Or.inr before) (Or.inr (TokenBoundaryHighWater.before_next before)) offset bound

attribute [local irreducible] Request.initialized Request.first

noncomputable def Request.firstReady (context : Context p) : Ready p 1 request.frontier.cursor :=
  TokenDirectInitialReady.ready request.first context request.frontier.cursor request.first_ordered request.initial_parameters_cut

theorem Request.first_cursor (context : Context p) : (request.firstReady context).frontier.cursor=request.frontier.cursor+bytes p := by
  rw [Request.firstReady,TokenDirectInitialReady.ready_cursor]
  unfold Request.first
  simp only [TokenInitializationHighWater.next,Request.initialFrontier,bytes,Nat.add_assoc]

theorem Request.first_parameters (context : Context p) (property : Nat → Nat → Prop) :
    (request.firstReady context).parameters.Protected property ↔ original.Protected property :=
  (TokenDirectInitialReady.ready_parameters request.first context request.frontier.cursor request.first_ordered
    request.initial_parameters_cut property).trans (request.initial_parameter_regions property)

theorem Request.first_frame (context : Context p) (region : TokenParameterConstruction.Region original base size)
    (offset : Nat) (bound : offset<size) :
    (request.firstReady context).state.index.bytes (base+offset)=initialHeap (base+offset) := by
  have retained : TokenParameterConstruction.Region request.initialized.parameters base size :=
    fun property safe => region property ((request.initial_parameter_regions property).mp safe)
  exact (TokenDirectInitialReady.ready_frame request.first context request.frontier.cursor request.first_ordered
    request.initial_parameters_cut retained offset bound).trans (request.initial_frame region offset bound)

theorem Request.first_logical (context : Context p) :
    (request.firstReady context).state.logical=TokenAutoregressive.run p context.parameters context.primitive context.sampling
      context.samplingPrimitive request.token context.angles 1 (by decide) :=
  TokenDirectInitialReady.ready_logical request.first context request.frontier.cursor request.first_ordered
    request.initial_parameters_cut request.token request.initial_logical

end Inference.Models.Qwen.InitialDirectRequestConstruction

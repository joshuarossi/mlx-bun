import models.qwen.InitialCacheParsedSourceConstruction
import models.qwen.CheckpointFirstTokenMemory

-- Create both zero scalars, initialize every cache through the parsed copy
-- bodies, and supply that exact heap to the first-token constructor. Native
-- scalar uploads, allocation and compilation remain explicit boundaries.
namespace Inference.Models.Qwen.InitialParsedRequestConstruction
open Contracts.Mlx TokenInference
open TokenBoundaryHighWater (Before)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages TokenFirstPlanConstruction.bytes

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  {original : TokenParameterMemory.Storage p initialHeap}

structure Request (original : TokenParameterMemory.Storage p initialHeap) where
  token : Fin 248320
  frontier : ResidualDeltaHighWater.Frontier
  room : frontier.cursor+(16+TokenInitializationHighWater.bytes+TokenFirstPlanConstruction.bytes p)≤2^64
  parameters : original.Protected (Before frontier.cursor)
  dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages

variable (request : Request original)

def Request.scalars : InitialScalarConstruction.Workspace where
  base := request.frontier.cursor
  aligned := by have := request.frontier.aligned; omega
  bounded := by
    have := request.room
    change request.frontier.cursor+8≤2^64
    omega

theorem Request.scalar_safe : original.Protected
    (MemoryRegions.Disjoint request.scalars.base InitialScalarConstruction.bytes) :=
  original.protected_mono (fun _ _ before => Or.inr before) request.parameters

def Request.prefixParameters : TokenParameterMemory.Storage p (request.scalars.memory initialHeap) :=
  request.scalars.parameters initialHeap original request.scalar_safe

theorem Request.prefix_regions (property : Nat → Nat → Prop) :
    request.prefixParameters.Protected property ↔ original.Protected property :=
  request.scalars.parameters_regions initialHeap original request.scalar_safe property

def Request.initialFrontier : ResidualDeltaHighWater.Frontier where
  cursor := request.frontier.cursor+16
  aligned := by have := request.frontier.aligned; omega

def Request.first : TokenFirstInitializedConstruction.Request request.prefixParameters where
  token := request.token
  frontier := request.initialFrontier
  room := by simpa only [Request.initialFrontier,Nat.add_assoc] using request.room
  parameters := (request.prefix_regions _).mpr
    (original.protected_mono
      (fun _ _ before => ResidualDeltaHighWater.before_mono (Nat.le_add_right _ 16) before) request.parameters)
  dispatch := request.dispatch

def Request.initialWorkspace : TokenInitializationAllocation.Workspace p.graph.stages :=
  TokenInitializationHighWater.workspace request.first.frontier request.first.initial_room

theorem Request.initial_separate :
    MemoryRegions.Disjoint request.initialWorkspace.base (TokenInitializationAllocation.bytes p.graph.stages)
      request.scalars.base InitialScalarConstruction.bytes := by
  apply Or.inr
  change request.frontier.cursor+8≤request.frontier.cursor+16
  omega

def Request.parsedSources : InitialCacheParsedSourceConstruction.Sources :=
  InitialCacheParsedSourceConstruction.initializedSources request.scalars initialHeap
    request.initialWorkspace request.initial_separate (token:=request.token)

theorem Request.parsed_executions :
    InitialCacheParsedSourceConstruction.Executes p.graph.stages request.initialWorkspace.caches
      (InitialCacheParsedSourceConstruction.entrySources request.scalars initialHeap
        request.initialWorkspace request.initial_separate (token:=request.token)) request.parsedSources :=
  InitialCacheParsedSourceConstruction.initialize_checked request.scalars initialHeap
    request.initialWorkspace request.initial_separate

theorem Request.initial_memory : request.parsedSources.history.bytes=request.first.initialization.memory :=
  InitialCacheParsedSourceConstruction.initialize_eq request.scalars initialHeap
    request.initialWorkspace request.initial_separate

theorem Request.initial_state_heap : request.first.ready.state.index.bytes=request.parsedSources.history.bytes :=
  InitialCacheParsedSourceConstruction.initialized_state_heap request.scalars initialHeap
    request.initialWorkspace request.initial_separate

theorem Request.initial_shared : request.parsedSources.history.bytes=request.parsedSources.recurrent.bytes :=
  request.parsedSources.shared.symm

theorem Request.initial_raw_zero : ByteMemory.load32 request.first.ready.state.index.bytes
    (request.scalars.base+4)=0 := by
  rw [request.initial_state_heap]
  exact InitialCacheParsedSourceConstruction.initialize_raw request.scalars initialHeap
    request.initialWorkspace request.initial_separate

theorem Request.prefix_bytes (region : TokenParameterConstruction.Region original base size)
    (offset : Nat) (bound : offset<size) :
    request.scalars.memory initialHeap (base+offset)=initialHeap (base+offset) :=
  request.scalars.other_region initialHeap (region _ request.scalar_safe) offset bound

theorem Request.prefix_region (region : TokenParameterConstruction.Region original base size) :
    TokenParameterConstruction.Region request.prefixParameters base size :=
  fun property retained => region property ((request.prefix_regions property).mp retained)

theorem Request.launch_counts : TokenInitializationAllocation.deltaCount p.graph.stages=48 :=
  InitialCacheParsedSourceConstruction.launch_counts

end Inference.Models.Qwen.InitialParsedRequestConstruction

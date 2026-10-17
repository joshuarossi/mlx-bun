import models.qwen.InitialCacheParsedSourceConstruction
import models.qwen.CheckpointCopiedInitializedBoundary

namespace Inference.Models.Qwen.CopiedScalarInitialization
open Contracts.Mlx Layers TokenInference Kernels.Attention
open ResidualDeltaHighWater (Frontier Before)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

-- These logical scalar buffers do not establish native constant sharing or
-- per-call array-object identity; native scalar descriptors remain external.
def bytes : Nat := 16+CheckpointCopiedInitializedRun.bytes

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  (original : TokenParameterMemory.Storage p initialHeap) (token : Fin 248320) (frontier : Frontier)
  (room : frontier.cursor+bytes≤2^64) (parameters : original.Protected (Before frontier.cursor))

def scalarWorkspace : InitialScalarConstruction.Workspace where
  base := frontier.cursor
  aligned := by have := frontier.aligned; omega
  bounded := by have total := room; dsimp only [bytes,InitialScalarConstruction.bytes] at *; omega

def nextFrontier : Frontier where
  cursor := frontier.cursor+16
  aligned := by have := frontier.aligned; omega

include room in
theorem remainingRoom : (nextFrontier frontier).cursor+CheckpointCopiedInitializedRun.bytes≤2^64 := by
  simpa only [nextFrontier,bytes,Nat.add_assoc] using room

def memory : ByteMemory.Bytes := (scalarWorkspace frontier room).memory initialHeap

include parameters in
private theorem scalarSafe : original.Protected
    (MemoryRegions.Disjoint (scalarWorkspace frontier room).base InitialScalarConstruction.bytes) :=
  original.protected_mono (fun _ _ before => Or.inr before) parameters

def originalAfter : TokenParameterMemory.Storage p (memory (initialHeap:=initialHeap) frontier room) :=
  (scalarWorkspace frontier room).parameters initialHeap original (scalarSafe original frontier room parameters)

theorem originalAfter_regions (property : Nat → Nat → Prop) :
    (originalAfter original frontier room parameters).Protected property ↔ original.Protected property :=
  (scalarWorkspace frontier room).parameters_regions initialHeap original (scalarSafe original frontier room parameters) property

theorem parametersBefore : (originalAfter original frontier room parameters).Protected (Before (nextFrontier frontier).cursor) :=
  (originalAfter_regions original frontier room parameters _).mpr
    (original.protected_mono (fun _ _ before => before.trans (Nat.le_add_right frontier.cursor 16)) parameters)

def initial := CheckpointCopiedInitializedRun.initial (originalAfter original frontier room parameters) token
  (nextFrontier frontier) (remainingRoom frontier room) (parametersBefore original frontier room parameters)

include room in
private theorem initializationRoom : (TokenInitializationHighWater.next (nextFrontier frontier)).cursor≤2^64 := by
  have total := remainingRoom frontier room
  dsimp only [CheckpointCopiedInitializedRun.bytes,TokenInitializationHighWater.next] at *
  omega

def initializationWorkspace : TokenInitializationAllocation.Workspace p.graph.stages :=
  TokenInitializationHighWater.workspace (p:=p) (nextFrontier frontier) (initializationRoom frontier room)

private theorem separate : MemoryRegions.Disjoint (initializationWorkspace (p:=p) frontier room).base
    (TokenInitializationAllocation.bytes p.graph.stages) (scalarWorkspace frontier room).base InitialScalarConstruction.bytes := by
  apply Or.inr
  change frontier.cursor+InitialScalarConstruction.bytes≤frontier.cursor+16
  dsimp [InitialScalarConstruction.bytes]
  omega

def entrySources := InitialCacheParsedSourceConstruction.entrySources (scalarWorkspace frontier room) initialHeap
  (initializationWorkspace (p:=p) frontier room) (separate (p:=p) frontier room) (token:=token)

def sources := InitialCacheParsedSourceConstruction.initializedSources (scalarWorkspace frontier room) initialHeap
  (initializationWorkspace (p:=p) frontier room) (separate (p:=p) frontier room) (token:=token)

theorem checked : InitialCacheParsedSourceConstruction.Executes p.graph.stages
    (initializationWorkspace (p:=p) frontier room).caches
    (entrySources (p:=p) (initialHeap:=initialHeap) token frontier room)
    (sources (p:=p) (initialHeap:=initialHeap) token frontier room) :=
  InitialCacheParsedSourceConstruction.initialize_checked _ _ _ _

theorem source_heap : (sources (p:=p) (initialHeap:=initialHeap) token frontier room).history.bytes=
    (initial original token frontier room parameters).memory.index.bytes :=
  InitialCacheParsedSourceConstruction.initialize_eq _ _ _ _

theorem source_recurrent_heap : (sources (p:=p) (initialHeap:=initialHeap) token frontier room).recurrent.bytes=
    (initial original token frontier room parameters).memory.index.bytes :=
  (sources (p:=p) (initialHeap:=initialHeap) token frontier room).shared.trans (source_heap original token frontier room parameters)

include parameters in
theorem original_bytes : original.Protected (fun base size => ∀ offset<size,
    (memory (initialHeap:=initialHeap) frontier room) (base+offset)=initialHeap (base+offset)) :=
  (scalarWorkspace frontier room).parameters_bytes initialHeap original (scalarSafe original frontier room parameters)

noncomputable def run (ctx : CheckpointCopiedHighWaterRun.Context p) (n : Nat) (supported : n≤262144) :=
  CheckpointCopiedInitializedRun.run (originalAfter original frontier room parameters) token
    (nextFrontier frontier) (remainingRoom frontier room) (parametersBefore original frontier room parameters) ctx n supported

theorem history_base : (sources (p:=p) (initialHeap:=initialHeap) token frontier room).history.base=frontier.cursor :=
  InitialCacheParsedSourceConstruction.initialize_history_base _ _ _ _

theorem recurrent_base : (sources (p:=p) (initialHeap:=initialHeap) token frontier room).recurrent.base=frontier.cursor+4 :=
  InitialCacheParsedSourceConstruction.initialize_recurrent_base _ _ _ _

theorem recurrent_zero : ByteMemory.load32 (initial original token frontier room parameters).memory.index.bytes (frontier.cursor+4)=0 :=
  (congrArg (fun memory => ByteMemory.load32 memory (frontier.cursor+4))
    (source_heap original token frontier room parameters)).symm.trans
      (InitialCacheParsedSourceConstruction.initialize_raw _ _ _ _)

end Inference.Models.Qwen.CopiedScalarInitialization

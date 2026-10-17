import models.qwen.InitialHistorySource

namespace Inference.Models.Qwen.InitialScalarConstruction
open Contracts.Mlx
set_option maxRecDepth 10000

-- Explicit modeled source creation on the loaded heap: one BF16 half store,
-- two untouched padding bytes, then one raw FP32-zero word store. Allocating
-- this arena and realizing these stores through native host/upload operations
-- are external boundaries. No native upload or allocator correspondence follows.
def bytes : Nat := 8

structure Workspace where
  base : Nat
  aligned : base%4=0
  bounded : base+bytes≤2^64

variable (w : Workspace) (initialHeap : ByteMemory.Bytes)

def Workspace.historyWrite : HalfArrayWrites.Trace w.base (fun _ : Fin 1 => (0 : BitVec 16)) where
  before := initialHeap
  aligned := by have := w.aligned; omega
  bounded := by have := w.bounded; dsimp [bytes] at this; omega
  schedule := (HalfArrayWrites.programs w.base (fun _ : Fin 1 => (0 : BitVec 16))).flatten
  remaining := List.replicate 1 []
  execution := by
    simpa only [HalfArrayWrites.programs,List.length_map,List.length_finRange] using
      ThreadgroupWrites.canonical (HalfArrayWrites.programs w.base (fun _ : Fin 1 => (0 : BitVec 16)))
  completed := by intro thread present; simpa using present

def Workspace.afterHistory : ByteMemory.Bytes := (w.historyWrite initialHeap).memory

def Workspace.recurrentWrite : WordArrayWrites.Trace (w.base+4) (fun _ : Fin 1 => (0 : BitVec 32)) where
  before := w.afterHistory initialHeap
  aligned := by have := w.aligned; omega
  bounded := by have := w.bounded; dsimp [bytes] at this; omega
  schedule := (WordArrayWrites.programs (w.base+4) (fun _ : Fin 1 => (0 : BitVec 32))).flatten
  remaining := List.replicate 1 []
  execution := by
    simpa only [WordArrayWrites.programs,List.length_map,List.length_finRange] using
      ThreadgroupWrites.canonical (WordArrayWrites.programs (w.base+4) (fun _ : Fin 1 => (0 : BitVec 32)))
  completed := by intro thread present; simpa using present

def Workspace.memory : ByteMemory.Bytes := (w.recurrentWrite initialHeap).memory

theorem Workspace.history_separate : MemoryRegions.Disjoint (w.base+4) 4 w.base 2 := Or.inr (by omega)

theorem Workspace.history_raw : HalfMemory.load (w.memory initialHeap) w.base=0 := by
  have same := MemoryRegions.execute32_other _ (w.afterHistory initialHeap)
    (ArrayFrame.word_stores_inside (w.recurrentWrite initialHeap)) w.history_separate
  have preserved := ArrayFrame.half_congr (w.afterHistory initialHeap) (w.memory initialHeap) w.base 2 0 same (by omega)
  have written := (w.historyWrite initialHeap).read_correct (0 : Fin 1)
  simpa only [Fin.val_zero,Nat.mul_zero,Nat.add_zero,Workspace.afterHistory] using preserved.trans written

-- Raw attachment is obtained from the concrete raw-word store, never inferred
-- from a FloatBuffer decode attachment (which would be insufficient for bits).
theorem Workspace.recurrent_raw : ByteMemory.load32 (w.memory initialHeap) (w.base+4)=0 := by
  simpa only [Fin.val_zero,Nat.mul_zero,Nat.add_zero,Workspace.memory] using
    (w.recurrentWrite initialHeap).read_correct (0 : Fin 1)

private theorem history_zero_bits : ArrayStorage.bits (InitialStorage.historyZero 0)=0 := by decide +kernel
private theorem recurrent_zero_decode : FloatMemory.decode 0=(0 : Float32) := by decide +kernel

def Workspace.history : ArrayStorage.BFBuffer InitialStorage.historyZero where
  bytes := w.memory initialHeap
  base := w.base
  aligned := by have := w.aligned; omega
  bounded := by have := w.bounded; dsimp [bytes] at this; omega
  attached := by
    intro i
    have index : i.val=0 := by have := i.isLt; omega
    simpa only [InitialStorage.historyZero,index,Nat.mul_zero,Nat.add_zero] using
      (w.history_raw initialHeap).trans history_zero_bits.symm

def Workspace.recurrent : ArrayStorage.FloatBuffer InitialStorage.recurrentZero where
  bytes := w.memory initialHeap
  base := w.base+4
  aligned := by have := w.aligned; omega
  bounded := by have := w.bounded; dsimp [bytes] at this; omega
  attached := by
    intro i
    have index : i.val=0 := by have := i.isLt; omega
    simpa only [InitialStorage.recurrentZero,index,Nat.mul_zero,Nat.add_zero,FloatMemory.load] using
      (congrArg FloatMemory.decode (w.recurrent_raw initialHeap)).trans recurrent_zero_decode

theorem Workspace.shared : (w.history initialHeap).bytes=(w.recurrent initialHeap).bytes := rfl
theorem Workspace.history_bytes : (w.history initialHeap).bytes=w.memory initialHeap := rfl
theorem Workspace.recurrent_bytes : (w.recurrent initialHeap).bytes=w.memory initialHeap := rfl
theorem Workspace.history_base : (w.history initialHeap).base=w.base := rfl
theorem Workspace.recurrent_base : (w.recurrent initialHeap).base=w.base+4 := rfl

theorem Workspace.other_region (separate : MemoryRegions.Disjoint w.base bytes other size)
    (offset : Nat) (bound : offset<size) :
    w.memory initialHeap (other+offset)=initialHeap (other+offset) := by
  have halfSeparate : MemoryRegions.Disjoint w.base 2 other size := by
    unfold MemoryRegions.Disjoint at *
    dsimp [bytes] at separate
    omega
  have wordSeparate : MemoryRegions.Disjoint (w.base+4) 4 other size := by
    unfold MemoryRegions.Disjoint at *
    dsimp [bytes] at separate
    omega
  exact (MemoryRegions.execute32_other _ _ (ArrayFrame.word_stores_inside (w.recurrentWrite initialHeap))
    wordSeparate offset bound).trans
    (MemoryRegions.execute16_other _ _ (ArrayFrame.half_stores_inside (w.historyWrite initialHeap))
      halfSeparate offset bound)

variable {p : TokenInference.Pipeline}

def Workspace.parameters (original : TokenParameterMemory.Storage p initialHeap)
    (safe : original.Protected (MemoryRegions.Disjoint w.base bytes)) :
    TokenParameterMemory.Storage p (w.memory initialHeap) :=
  original.reframe _ (original.protected_mono (fun _ _ region => w.other_region initialHeap region) safe)

theorem Workspace.parameters_regions (original : TokenParameterMemory.Storage p initialHeap)
    (safe : original.Protected (MemoryRegions.Disjoint w.base bytes)) (property : Nat → Nat → Prop) :
    (w.parameters initialHeap original safe).Protected property ↔ original.Protected property :=
  original.reframe_protected _ _ property

theorem Workspace.parameters_bytes (original : TokenParameterMemory.Storage p initialHeap)
    (safe : original.Protected (MemoryRegions.Disjoint w.base bytes)) :
    original.Protected (fun base size => ∀ offset<size, w.memory initialHeap (base+offset)=initialHeap (base+offset)) :=
  original.protected_mono (fun _ _ region => w.other_region initialHeap region) safe

-- Feed the unchanged token-write/history adapter with the scalar CREATED above.
-- Workspace separation derives the two-byte scalar-source protection contract.
variable {token : Fin 248320}

theorem Workspace.tokenWorkspaceFresh (initialization : TokenInitializationAllocation.Workspace p.graph.stages)
    (separate : MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) w.base bytes) :
    MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) (w.history initialHeap).base 2 := by
  change MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) w.base 2
  unfold MemoryRegions.Disjoint at *
  dsimp [bytes] at separate
  omega

def Workspace.historyAfterToken (initialization : TokenInitializationAllocation.Workspace p.graph.stages)
    (separate : MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) w.base bytes) :
    ArrayStorage.BFBuffer InitialStorage.historyZero :=
  InitialHistorySource.scalarAfterToken (token:=token) (w.history initialHeap) initialization
    (w.tokenWorkspaceFresh initialHeap initialization separate)

theorem Workspace.historyAfterToken_bytes (initialization : TokenInitializationAllocation.Workspace p.graph.stages)
    (separate : MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) w.base bytes) :
    (w.historyAfterToken initialHeap (token:=token) initialization separate).bytes=
      (initialization.plan (token:=token) (initialHeap:=w.memory initialHeap)).tokenWrite.memory :=
  InitialHistorySource.scalarAfterToken_bytes _ _ _

theorem Workspace.historyAfterToken_base (initialization : TokenInitializationAllocation.Workspace p.graph.stages)
    (separate : MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) w.base bytes) :
    (w.historyAfterToken initialHeap (token:=token) initialization separate).base=w.base :=
  InitialHistorySource.scalarAfterToken_base _ _ _

theorem Workspace.token_other_region (initialization : TokenInitializationAllocation.Workspace p.graph.stages)
    (separate : MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) w.base bytes)
    (regionSafe : MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) other size)
    (offset : Nat) (bound : offset<size) :
    (w.historyAfterToken initialHeap (token:=token) initialization separate).bytes (other+offset)=
      w.memory initialHeap (other+offset) := by
  have tokenSeparate : MemoryRegions.Disjoint initialization.base 4 other size := by
    unfold MemoryRegions.Disjoint at *
    dsimp [TokenInitializationAllocation.bytes] at regionSafe
    omega
  exact (congrFun (w.historyAfterToken_bytes initialHeap (token:=token) initialization separate) _).trans
    (MemoryRegions.execute32_other _ _
      (ArrayFrame.word_stores_inside (initialization.plan (token:=token) (initialHeap:=w.memory initialHeap)).tokenWrite)
      tokenSeparate offset bound)

theorem Workspace.recurrentTokenFresh (initialization : TokenInitializationAllocation.Workspace p.graph.stages)
    (separate : MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) w.base bytes) :
    MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) (w.base+4) 4 := by
  unfold MemoryRegions.Disjoint at *
  dsimp [bytes] at separate
  omega

def Workspace.recurrentAfterToken (initialization : TokenInitializationAllocation.Workspace p.graph.stages)
    (separate : MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) w.base bytes) :
    ArrayStorage.FloatBuffer InitialStorage.recurrentZero :=
  ArrayFrame.fp (w.recurrent initialHeap) (w.historyAfterToken initialHeap (token:=token) initialization separate).bytes
    (w.token_other_region initialHeap initialization separate (w.recurrentTokenFresh initialization separate))

theorem Workspace.recurrentAfterToken_raw (initialization : TokenInitializationAllocation.Workspace p.graph.stages)
    (separate : MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) w.base bytes) :
    ByteMemory.load32 (w.historyAfterToken initialHeap (token:=token) initialization separate).bytes (w.base+4)=0 := by
  have preserved := ArrayFrame.word_congr (w.memory initialHeap)
    (w.historyAfterToken initialHeap (token:=token) initialization separate).bytes (w.base+4) 4 0
    (w.token_other_region initialHeap initialization separate (w.recurrentTokenFresh initialization separate)) (by omega)
  have equal : ByteMemory.load32 (w.historyAfterToken initialHeap (token:=token) initialization separate).bytes (w.base+4)=
      ByteMemory.load32 (w.memory initialHeap) (w.base+4) := by
    simpa only [Nat.add_zero] using preserved
  exact equal.trans (w.recurrent_raw initialHeap)

theorem Workspace.prefix_other_region (initialization : TokenInitializationAllocation.Workspace p.graph.stages)
    (separate : MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) w.base bytes)
    (scalarSafe : MemoryRegions.Disjoint w.base bytes other size)
    (tokenSafe : MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) other size)
    (offset : Nat) (bound : offset<size) :
    (w.historyAfterToken initialHeap (token:=token) initialization separate).bytes (other+offset)=initialHeap (other+offset) :=
  (w.token_other_region initialHeap initialization separate tokenSafe offset bound).trans
    (w.other_region initialHeap scalarSafe offset bound)

def Workspace.parametersAfterToken (original : TokenParameterMemory.Storage p initialHeap)
    (initialization : TokenInitializationAllocation.Workspace p.graph.stages)
    (separate : MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) w.base bytes)
    (safe : original.Protected (fun base size => MemoryRegions.Disjoint w.base bytes base size ∧
      MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) base size)) :
    TokenParameterMemory.Storage p (w.historyAfterToken initialHeap (token:=token) initialization separate).bytes :=
  original.reframe _ (original.protected_mono
    (fun _ _ region => w.prefix_other_region initialHeap initialization separate region.1 region.2) safe)

theorem Workspace.parametersAfterToken_regions (original : TokenParameterMemory.Storage p initialHeap)
    (initialization : TokenInitializationAllocation.Workspace p.graph.stages)
    (separate : MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) w.base bytes)
    (safe : original.Protected (fun base size => MemoryRegions.Disjoint w.base bytes base size ∧
      MemoryRegions.Disjoint initialization.base (TokenInitializationAllocation.bytes p.graph.stages) base size))
    (property : Nat → Nat → Prop) :
    (w.parametersAfterToken initialHeap (token:=token) original initialization separate safe).Protected property ↔ original.Protected property :=
  original.reframe_protected _ _ property

end Inference.Models.Qwen.InitialScalarConstruction

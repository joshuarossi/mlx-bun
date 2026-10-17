import contracts.mlx.RmsNorm
import contracts.mlx.FloatArrayWrites

namespace Inference.Contracts.Mlx.RmsScratch

def partialValues (p : RmsNorm.Platform) (input : Fin width → Float32) : Fin p.groups → Float32 :=
  NormalizationReduction.groupSum p.reduce p.contracted input

structure Trace (p : RmsNorm.Platform) (input : Fin width → Float32) where
  initial : FloatArrayWrites.Trace 0 (fun _ : Fin 32 => (0 : Float32))
  partials : FloatArrayWrites.Trace 0 (partialValues p input)
  afterInitialization : partials.before=initial.memory

def Trace.canonical (p : RmsNorm.Platform) (input : Fin width → Float32) : Trace p input :=
  let initial := FloatArrayWrites.Trace.canonical (fun _ : Fin 32 => (0 : Float32)) (by decide)
  let partials : FloatArrayWrites.Trace 0 (partialValues p input) :=
    { FloatArrayWrites.Trace.canonical (partialValues p input) (by have := p.groupsBounded; omega) with before := initial.memory }
  ⟨initial, partials, rfl⟩

variable {width : Nat} {p : RmsNorm.Platform} {input : Fin width → Float32}

theorem Trace.padding (trace : Trace p input) (lane : Fin 32) (outside : p.groups ≤ lane.val) :
    FloatMemory.load trace.partials.memory (4*lane.val)=FloatMemory.load trace.partials.before (4*lane.val) := by
  unfold FloatMemory.load FloatArrayWrites.Trace.memory
  rw [ByteMemory.execute_bytes_load32 _ _ _ (by omega), show 4*lane.val/4=lane.val by omega]
  have order := ThreadgroupWrites.completed_schedule trace.partials.execution trace.partials.completed
  rw [MemoryCells.frame]
  · rfl
  · intro store inside
    obtain ⟨i, rfl⟩ := FloatArrayWrites.member 0 (partialValues p input) store (order.mem_iff.mp inside)
    have := i.isLt
    simp only [FloatArrayWrites.entry, Nat.zero_div, Nat.zero_add]
    omega

theorem Trace.read_correct (trace : Trace p input) (lane : Fin 32) :
    FloatMemory.load trace.partials.memory (4*lane.val)=
      if h : lane.val<p.groups then partialValues p input ⟨lane.val, h⟩ else 0 := by
  split
  next h => simpa only [Nat.zero_add] using trace.partials.read_correct ⟨lane.val, h⟩
  next h =>
    rw [trace.padding lane (by omega), trace.afterInitialization]
    simpa only [Nat.zero_add] using trace.initial.read_correct lane

def Trace.sum (trace : Trace p input) : Float32 :=
  p.reduce (fun lane => FloatMemory.load trace.partials.memory (4*lane.val))

theorem Trace.sum_eq (trace : Trace p input) (before : M1Max.WordMemory) (base : Nat) :
    trace.sum=NormalizationReduction.sourceSum p.reduce p.contracted input before base p.groups := by
  unfold Trace.sum NormalizationReduction.sourceSum
  congr 1
  funext lane
  rw [trace.read_correct, NormalizationReduction.shared_read before base _ _ _ (List.Perm.refl _) (List.Perm.refl _)]
  rfl

def Trace.factor (trace : Trace p input) (width eps : Float32) : Float32 :=
  p.rsqrt (FlushToZero.add (p.divide trace.sum width) eps)

theorem Trace.factor_eq (trace : Trace p input) (width eps : Float32) (before : M1Max.WordMemory) (base : Nat) :
    trace.factor width eps=RmsNorm.inverse p input width eps before base := by
  unfold Trace.factor RmsNorm.inverse
  rw [trace.sum_eq before base]

-- RMS_N_READS=4 and RMS_LOOPED_LIMIT=4096 in the pinned defines.h.
theorem head_dispatch : 256 ≤ 4096 ∧ ((256+4-1)/4+32-1)/32=2 ∧
    32*(((256+4-1)/4+32-1)/32)=64 ∧ 64*4=256 := by decide

theorem head_column (thread : Fin 64) (i : Fin 4) :
    (NormalizationSchedule.address (⟨0, thread, i⟩ : NormalizationSchedule.Visit 64))=thread.val*4+i.val ∧
    thread.val*4+4 ≤ 256 := by
  have := thread.isLt
  dsimp [NormalizationSchedule.address]
  omega

end Inference.Contracts.Mlx.RmsScratch

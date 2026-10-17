import kernels.attention.SdpaTwoPassWrites
import contracts.mlx.ThreadgroupWriteProjection
import contracts.mlx.FloatMemory
import contracts.mlx.HalfMemory

namespace Inference.Kernels.Attention.SdpaTwoPassBytes
open Contracts.Mlx SdpaTwoPassLayout SdpaTwoPassWrites
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

def bfloatBits (value : BF) : BitVec 16 := value.bits

inductive Event where
  | sum : ByteMemory.Store → Event
  | maximum : ByteMemory.Store → Event
  | output : HalfMemory.Store → Event

def sumProject : Event → Option ByteMemory.Store
  | .sum store => some store
  | _ => none
def maxProject : Event → Option ByteMemory.Store
  | .maximum store => some store
  | _ => none
def outputProject : Event → Option HalfMemory.Store
  | .output store => some store
  | _ => none

private theorem sum_outputs (stores : List HalfMemory.Store) : (stores.map Event.output).filterMap sumProject=[] := by
  induction stores with
  | nil => rfl
  | cons store rest ih => simpa only [List.map_cons, List.filterMap_cons, sumProject] using ih

private theorem max_outputs (stores : List HalfMemory.Store) : (stores.map Event.output).filterMap maxProject=[] := by
  induction stores with
  | nil => rfl
  | cons store rest ih => simpa only [List.map_cons, List.filterMap_cons, maxProject] using ih

private theorem output_outputs (stores : List HalfMemory.Store) : (stores.map Event.output).filterMap outputProject=stores := by
  induction stores with
  | nil => rfl
  | cons store rest ih => simpa only [List.map_cons, List.filterMap_cons, outputProject] using congrArg (List.cons store) ih

def thread (sumBase maxBase outputBase : Nat) (sums maxima : Fin 24 → Fin blocks → Float32)
    (values : Fin 24 → Fin blocks → Fin 256 → BF) (label : Label blocks) : List Event :=
  (if label.2.2.val=0 then
    [.sum (summaryEntry (sumBase/4) (fun h b => FloatMemory.bits (sums h b)) label),
     .maximum (summaryEntry (maxBase/4) (fun h b => FloatMemory.bits (maxima h b)) label)] else [])++
    (partialThread (outputBase/2) (fun h b i => bfloatBits (values h b i)) label).map Event.output

def programs (sumBase maxBase outputBase : Nat) (sums maxima : Fin 24 → Fin blocks → Float32)
    (values : Fin 24 → Fin blocks → Fin 256 → BF) : List (List Event) :=
  (labels blocks).map (thread sumBase maxBase outputBase sums maxima values)

theorem sum_thread (sumBase maxBase outputBase : Nat) (sums maxima : Fin 24 → Fin blocks → Float32)
    (values : Fin 24 → Fin blocks → Fin 256 → BF) (label : Label blocks) :
    (thread sumBase maxBase outputBase sums maxima values label).filterMap sumProject=
      summaryThread (sumBase/4) (fun h b => FloatMemory.bits (sums h b)) label := by
  unfold thread summaryThread
  split <;> simp only [List.filterMap_append, sum_outputs, List.filterMap_cons, List.filterMap_nil, sumProject] <;> simp

theorem max_thread (sumBase maxBase outputBase : Nat) (sums maxima : Fin 24 → Fin blocks → Float32)
    (values : Fin 24 → Fin blocks → Fin 256 → BF) (label : Label blocks) :
    (thread sumBase maxBase outputBase sums maxima values label).filterMap maxProject=
      summaryThread (maxBase/4) (fun h b => FloatMemory.bits (maxima h b)) label := by
  unfold thread summaryThread
  split <;> simp only [List.filterMap_append, max_outputs, List.filterMap_cons, List.filterMap_nil, maxProject] <;> simp

theorem output_thread (sumBase maxBase outputBase : Nat) (sums maxima : Fin 24 → Fin blocks → Float32)
    (values : Fin 24 → Fin blocks → Fin 256 → BF) (label : Label blocks) :
    (thread sumBase maxBase outputBase sums maxima values label).filterMap outputProject=
      partialThread (outputBase/2) (fun h b i => bfloatBits (values h b i)) label := by
  unfold thread
  split <;> simp only [List.filterMap_append, output_outputs, List.filterMap_cons, List.filterMap_nil, outputProject] <;> simp

theorem sum_programs (sumBase maxBase outputBase : Nat) (sums maxima : Fin 24 → Fin blocks → Float32)
    (values : Fin 24 → Fin blocks → Fin 256 → BF) :
    ThreadgroupWriteProjection.programs sumProject (programs sumBase maxBase outputBase sums maxima values)=
      summaryPrograms (sumBase/4) (fun h b => FloatMemory.bits (sums h b)) := by
  simp only [ThreadgroupWriteProjection.programs, programs, List.map_map, Function.comp_def, sum_thread, summaryPrograms]

theorem max_programs (sumBase maxBase outputBase : Nat) (sums maxima : Fin 24 → Fin blocks → Float32)
    (values : Fin 24 → Fin blocks → Fin 256 → BF) :
    ThreadgroupWriteProjection.programs maxProject (programs sumBase maxBase outputBase sums maxima values)=
      summaryPrograms (maxBase/4) (fun h b => FloatMemory.bits (maxima h b)) := by
  simp only [ThreadgroupWriteProjection.programs, programs, List.map_map, Function.comp_def, max_thread, summaryPrograms]

theorem output_programs (sumBase maxBase outputBase : Nat) (sums maxima : Fin 24 → Fin blocks → Float32)
    (values : Fin 24 → Fin blocks → Fin 256 → BF) :
    ThreadgroupWriteProjection.programs outputProject (programs sumBase maxBase outputBase sums maxima values)=
      partialPrograms (outputBase/2) (fun h b i => bfloatBits (values h b i)) := by
  unfold ThreadgroupWriteProjection.programs programs partialPrograms
  rw [List.map_map]
  apply congrArg (fun f => (labels blocks).map f)
  funext label
  exact output_thread sumBase maxBase outputBase sums maxima values label

-- One legal dispatch trace preserves each thread's actual order: sums,
-- maxima, then eight BF16 outputs. Buffers are separate allocations. The
-- completion dependency precedes second-pass reads; native visibility and
-- allocation identity remain platform obligations.
structure Trace (sums maxima : Fin 24 → Fin blocks → Float32) (values : Fin 24 → Fin blocks → Fin 256 → BF) where
  sumBefore : ByteMemory.Bytes
  maxBefore : ByteMemory.Bytes
  outputBefore : ByteMemory.Bytes
  sumBase : Nat
  maxBase : Nat
  outputBase : Nat
  sumAligned : sumBase%4=0
  maxAligned : maxBase%4=0
  outputAligned : outputBase%2=0
  sumBounded : sumBase+4*(24*blocks) ≤ 2^64
  maxBounded : maxBase+4*(24*blocks) ≤ 2^64
  outputBounded : outputBase+2*(24*blocks*256) ≤ 2^64
  schedule : List Event
  remaining : List (List Event)
  execution : ThreadgroupWrites.Executes (programs sumBase maxBase outputBase sums maxima values) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (sums maxima : Fin 24 → Fin blocks → Float32) (values : Fin 24 → Fin blocks → Fin 256 → BF)
    (bounded : blocks ≤ 1024) : Trace sums maxima values :=
  let stores := programs 0 0 0 sums maxima values
  ⟨fun _ => 0, fun _ => 0, fun _ => 0, 0, 0, 0, by decide, by decide, by decide,
    by omega, by omega, by omega, stores.flatten, List.replicate stores.length [],
    ThreadgroupWrites.canonical stores, ThreadgroupWrites.canonical_barrier stores⟩

variable {blocks : Nat} {sums maxima : Fin 24 → Fin blocks → Float32} {values : Fin 24 → Fin blocks → Fin 256 → BF}

def Trace.sumMemory (trace : Trace sums maxima values) : ByteMemory.Bytes :=
  ByteMemory.execute (trace.schedule.filterMap sumProject) trace.sumBefore
def Trace.maxMemory (trace : Trace sums maxima values) : ByteMemory.Bytes :=
  ByteMemory.execute (trace.schedule.filterMap maxProject) trace.maxBefore
def Trace.outputMemory (trace : Trace sums maxima values) : ByteMemory.Bytes :=
  HalfMemory.execute (trace.schedule.filterMap outputProject) trace.outputBefore

def Trace.sumRead (trace : Trace sums maxima values) (head : Fin 24) (block : Fin blocks) : Float32 :=
  FloatMemory.decode (ByteMemory.load32 trace.sumMemory (trace.sumBase+4*summaryAddress blocks head block))
def Trace.maxRead (trace : Trace sums maxima values) (head : Fin 24) (block : Fin blocks) : Float32 :=
  FloatMemory.decode (ByteMemory.load32 trace.maxMemory (trace.maxBase+4*summaryAddress blocks head block))
def Trace.outputRead (trace : Trace sums maxima values) (head : Fin 24) (block : Fin blocks) (i : Fin 256) : BF :=
  Model.ofBits (HalfMemory.load trace.outputMemory (trace.outputBase+2*partialAddress blocks head block i))

theorem Trace.sum_correct (trace : Trace sums maxima values) (head : Fin 24) (block : Fin blocks) :
    trace.sumRead head block=sums head block := by
  have run := ThreadgroupWriteProjection.execution sumProject trace.execution
  rw [sum_programs] at run
  unfold Trace.sumRead Trace.sumMemory
  rw [ByteMemory.execute_bytes_load32 _ _ _ (by have := trace.sumAligned; omega),
    show (trace.sumBase+4*summaryAddress blocks head block)/4=trace.sumBase/4+summaryAddress blocks head block by omega,
    summary_read _ _ _ _ _ run (ThreadgroupWriteProjection.completed sumProject _ trace.completed), FloatMemory.decode_bits]

theorem Trace.max_correct (trace : Trace sums maxima values) (head : Fin 24) (block : Fin blocks) :
    trace.maxRead head block=maxima head block := by
  have run := ThreadgroupWriteProjection.execution maxProject trace.execution
  rw [max_programs] at run
  unfold Trace.maxRead Trace.maxMemory
  rw [ByteMemory.execute_bytes_load32 _ _ _ (by have := trace.maxAligned; omega),
    show (trace.maxBase+4*summaryAddress blocks head block)/4=trace.maxBase/4+summaryAddress blocks head block by omega,
    summary_read _ _ _ _ _ run (ThreadgroupWriteProjection.completed maxProject _ trace.completed), FloatMemory.decode_bits]

theorem Trace.output_correct (trace : Trace sums maxima values) (head : Fin 24) (block : Fin blocks) (i : Fin 256) :
    trace.outputRead head block i=values head block i := by
  have run := ThreadgroupWriteProjection.execution outputProject trace.execution
  rw [output_programs] at run
  have raw : HalfMemory.load trace.outputMemory (trace.outputBase+2*partialAddress blocks head block i)=
      bfloatBits (values head block i) := by
    unfold Trace.outputMemory
    rw [HalfMemory.execute_load _ _ _ (by have := trace.outputAligned; omega),
      show (trace.outputBase+2*partialAddress blocks head block i)/2=trace.outputBase/2+partialAddress blocks head block i by omega]
    exact partial_read _ _ _ _ _ run (ThreadgroupWriteProjection.completed outputProject _ trace.completed) head block i
  exact congrArg (fun bits : BitVec 16 => (Model.ofBits bits : BF)) raw

def Trace.readState (trace : Trace sums maxima values) (head : Fin 24) (block : Fin blocks) (i : Fin 256) : SdpaUpdate.State :=
  ⟨trace.maxRead head block, trace.sumRead head block, BFloat16.widen (trace.outputRead head block i)⟩

abbrev FirstTrace (p : SdpaVector.Platform) (blocks : Nat) (query : Fin 24 → Fin 256 → BF)
    (keys values : Fin 4 → Fin steps → Fin 256 → BF) :=
  Trace
    (fun (h : Fin 24) (b : Fin blocks) => (SdpaTwoPassFirstPass.raw p (query h) (keys (SdpaScore.kvHead h)) (values (SdpaScore.kvHead h)) 0 b).denominator)
    (fun (h : Fin 24) (b : Fin blocks) => (SdpaTwoPassFirstPass.raw p (query h) (keys (SdpaScore.kvHead h)) (values (SdpaScore.kvHead h)) 0 b).shift)
    (fun h b i => SdpaTwoPassFirstPass.stored p (query h) (keys (SdpaScore.kvHead h)) (values (SdpaScore.kvHead h)) i b)

theorem first_to_second (p : SdpaVector.Platform) (blocks : Nat) (query : Fin 24 → Fin 256 → BF)
    (keys values : Fin 4 → Fin steps → Fin 256 → BF) (trace : FirstTrace p blocks query keys values)
    (head : Fin 24) (block : Fin blocks) (i : Fin 256) :
    trace.readState head block i=
      SdpaTwoPassVector.partials p (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)) i block := by
  unfold Trace.readState
  rw [trace.max_correct, trace.sum_correct, trace.output_correct]
  have shared := SdpaTwoPassFirstPass.shared p (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)) 0 i block
  change (SdpaTwoPassFirstPass.raw _ _ _ _ 0 block).shift = (SdpaTwoPassFirstPass.raw _ _ _ _ i block).shift ∧
    (SdpaTwoPassFirstPass.raw _ _ _ _ 0 block).denominator = (SdpaTwoPassFirstPass.raw _ _ _ _ i block).denominator at shared
  rw [shared.1, shared.2]
  rfl

def forward (p : SdpaVector.Platform) (contracted : Bool) (blocks : Nat) (query : Fin 24 → Fin 256 → BF)
    (keys values : Fin 4 → Fin steps → Fin 256 → BF) (trace : FirstTrace p blocks query keys values)
    (head : Fin 24) (i : Fin 256) : BF :=
  SdpaNormalize.value p.normalization
    (SdpaTwoPassMerge.forward p.merge contracted (fun block => trace.readState head block i)
      (SdpaTwoPassMaximum.common p (fun block => (trace.readState head block 0).shift)))

theorem forward_eq (p : SdpaVector.Platform) (contracted : Bool) (blocks : Nat) (query : Fin 24 → Fin 256 → BF)
    (keys values : Fin 4 → Fin steps → Fin 256 → BF) (trace : FirstTrace p blocks query keys values)
    (head : Fin 24) (i : Fin 256) :
    forward p contracted blocks query keys values trace head i=
      SdpaTwoPassVector.forward p contracted blocks (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)) i := by
  unfold forward
  simp only [first_to_second]
  rfl

theorem forward_error (p : SdpaVector.Platform) (contracted : Bool) (blocks : Nat) (query : Fin 24 → Fin 256 → BF)
    (keys values : Fin 4 → Fin steps → Fin 256 → BF) (trace : FirstTrace p blocks query keys values) (head : Fin 24)
    (targetQuery errorQuery : Fin 256 → ℝ) (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ)
    (he : SdpaVector.InputError (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head))
      targetQuery errorQuery targetKeys targetValues errorKeys errorValues)
    (hf : SdpaTwoPassVector.Finite p contracted blocks (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)))
    (hn : 0<steps) (hb : 0<blocks) (i : Fin 256) :
    |Model.toReal (forward p contracted blocks query keys values trace head i)-SdpaVector.target targetQuery targetKeys targetValues i| ≤
      SdpaTwoPassVector.budget p contracted blocks (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head))
        targetQuery errorQuery targetKeys targetValues errorKeys errorValues i := by
  rw [forward_eq]
  exact SdpaTwoPassVector.forward_error p contracted blocks _ _ _ _ _ _ _ _ _ he hf hn hb i

theorem forward_finite (p : SdpaVector.Platform) (contracted : Bool) (blocks : Nat) (query : Fin 24 → Fin 256 → BF)
    (keys values : Fin 4 → Fin steps → Fin 256 → BF) (trace : FirstTrace p blocks query keys values) (head : Fin 24)
    (hf : SdpaTwoPassVector.Finite p contracted blocks (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)))
    (i : Fin 256) : Model.isFinite (forward p contracted blocks query keys values trace head i)=true := by
  rw [forward_eq]
  exact SdpaTwoPassVector.forward_finite p contracted blocks _ _ _ hf i

end Inference.Kernels.Attention.SdpaTwoPassBytes

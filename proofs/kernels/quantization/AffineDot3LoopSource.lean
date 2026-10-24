import kernels.quantization.AffineDot3Source
import kernels.quantization.AffineDot4LoopSource
import kernels.trellis.GateInputSyntax

namespace Inference.Kernels.Quantization.AffineDot3LoopSource
open Contracts.Mlx AffineDot3Source
open Copy.ScalarCopySyntax (accept decimal)
open AffineDot4LoopSource (Header parseHeader condition advance)
set_option maxRecDepth 10000

structure Pointers where
  inputFactor : Nat
  packedFactor : Nat
  deriving DecidableEq, Repr

def parsePointers (source : String) : Option Pointers := do
  let ts ←Trellis.GateInputSyntax.tokenize source
  let ts ←accept "x_thread" ts
  let ts ←accept "+=" ts
  let input::ts := ts | none
  let inputFactor ←decimal input
  let ts ←accept "*" ts
  let ts ←accept "i" ts
  let ts ←accept ";" ts
  let ts ←accept "w" ts
  let ts ←accept "+=" ts
  let packed::ts := ts | none
  let packedFactor ←decimal packed
  let ts ←accept "*" ts
  let ts ←accept "i" ts
  let ts ←accept ";" ts
  if ts=[] then some ⟨inputFactor,packedFactor⟩ else none

def sourceHeader : String := "for (int i = 0; i < 2; i++) {"
def sourcePointers : String := "x_thread += 8 * i;\n      w += 3 * i;"
def header : Header := ⟨0,2⟩
theorem parsed_header : parseHeader sourceHeader=some header := by decide +kernel
theorem parsed_pointers : parsePointers sourcePointers=some ⟨8,3⟩ := by decide +kernel

def slice (memory : Memory) (iteration : Fin 2) : Memory :=
  ⟨memory.packed,memory.packedBase+3*iteration.val,memory.scaled,memory.scaledBase+8*iteration.val⟩

-- The actual += operations update the CURRENT pointer pair before the body.
-- Bounds exclude address wrap for each three-byte/eight-word chunk.
def sourcePointer (memory : Memory) (iteration : Fin 2) : Option Memory := do
  let p ←parsePointers sourcePointers
  let packed := memory.packedBase+p.packedFactor*iteration.val
  let scaled := memory.scaledBase+p.inputFactor*iteration.val
  if packed+3≤2^64 ∧ scaled+8≤2^64 then
    some ⟨memory.packed,packed,memory.scaled,scaled⟩ else none

theorem pointer_slice (memory : Memory) (iteration : Fin 2)
    (packedRoom : memory.packedBase+6≤2^64) (scaledRoom : memory.scaledBase+16≤2^64) :
    sourcePointer memory iteration=some (slice memory iteration) := by
  have safe : memory.packedBase+3*iteration.val+3≤2^64 ∧ memory.scaledBase+8*iteration.val+8≤2^64 := by
    have := iteration.isLt; omega
  simp only [sourcePointer,parsed_pointers,bind,Option.bind,ite_eq_left safe,slice]

theorem slice_zero (memory : Memory) : slice memory 0=memory := by cases memory; simp [slice]
theorem signed_increments : ∀ iteration : Fin 2, advance iteration.val=some (iteration.val+1:Int) := by decide +kernel
theorem offset_bounds (iteration : Fin 2) : 3*iteration.val<2^31 ∧ 8*iteration.val<2^31 := by
  have := iteration.isLt; omega

inductive Runs (h : Header) (contracted : Nat → Bool) : Int → Memory → Float32 → List Int → Float32 → Prop where
  | stop (ended : condition h index=false) : Runs h contracted index memory acc [] acc
  | next (iteration : Fin 2) (sameIndex : index=(iteration.val:Int)) (entered : condition h index=true)
      (pointers : sourcePointer memory iteration=some current)
      (step : AffineDot3Source.executeSource contracted current acc=some after)
      (increment : advance index=some next)
      (rest : Runs h contracted next current after visits result) :
      Runs h contracted index memory acc (index::visits) result

def step (contracted : Nat → Bool) (memory : Memory) (iteration : Fin 2) (acc : Float32) : Float32 :=
  AffineDot.source3 contracted (bytes (slice memory iteration)) (input (slice memory iteration)) acc
def result (contracted : Nat → Bool) (memory : Memory) (initial : Float32) : Float32 :=
  (List.finRange 2).foldl (fun acc iteration => step contracted memory iteration acc) initial

theorem step_execution (contracted : Nat → Bool) (memory : Memory) (iteration : Fin 2) (acc : Float32) :
    AffineDot3Source.executeSource contracted (slice memory iteration) acc=some (step contracted memory iteration acc) :=
  AffineDot3Source.execution contracted (slice memory iteration) acc

attribute [local irreducible] AffineDot3Source.executeSource sourcePointer step

theorem execution (contracted : Nat → Bool) (memory : Memory) (initial : Float32)
    (packedRoom : memory.packedBase+6≤2^64) (scaledRoom : memory.scaledBase+16≤2^64) :
    Runs header contracted header.initial memory initial [0,1] (result contracted memory initial) := by
  let a1:=step contracted memory 0 initial
  let a2:=step contracted memory 1 a1
  have done : Runs header contracted 2 (slice memory 1) a2 [] a2 := .stop (by decide)
  have second : Runs header contracted 1 (slice memory 0) a1 [1] a2 :=
    .next 1 rfl (by decide) (by rw [slice_zero]; exact pointer_slice memory 1 packedRoom scaledRoom)
      (step_execution contracted memory 1 a1) (signed_increments 1) done
  exact .next 0 rfl (by decide) (pointer_slice memory 0 packedRoom scaledRoom)
    (step_execution contracted memory 0 initial) (signed_increments 0) second

theorem parsed_execution (contracted : Nat → Bool) (memory : Memory) (initial : Float32)
    (packedRoom : memory.packedBase+6≤2^64) (scaledRoom : memory.scaledBase+16≤2^64) :
    ∃ h, parseHeader sourceHeader=some h ∧ Runs h contracted h.initial memory initial [0,1]
      (result contracted memory initial) :=
  ⟨header,parsed_header,execution contracted memory initial packedRoom scaledRoom⟩

end Inference.Kernels.Quantization.AffineDot3LoopSource

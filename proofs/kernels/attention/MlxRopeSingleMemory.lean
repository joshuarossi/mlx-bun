import kernels.attention.MlxRopeSingleSyntax
import kernels.attention.RopeRowsDynamicMemory

namespace Inference.Kernels.Attention.MlxRopeSingleMemory
open Contracts.Mlx MlxRopeSingleSyntax
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

-- These are evaluated on the CURRENT heap, with the input/output pointers
-- aliased by the host partial-rotation copy branch. No output value is supplied.
def captureCell (_ : Cell) (ast : Indices) (memory : ByteMemory.Bytes) (base : Nat)
    (head : Fin rows) (lane : Fin 32) (theta : Float32) : Rope.Inputs :=
  let pos := positions ast lane.val head.val 256 32
  ⟨Model.ofBits (HalfMemory.load memory (base+2*pos.1)),
   Model.ofBits (HalfMemory.load memory (base+2*pos.2)),theta⟩

def captureSource (memory : ByteMemory.Bytes) (base : Nat) (head : Fin rows)
    (lane : Fin 32) (theta : Float32) : Option Rope.Inputs := do
  let ast ←parseIndices sourceIndices
  let cell ←parseCell sourceCell
  pure (captureCell cell ast memory base head lane theta)

theorem capture_current (memory : ByteMemory.Bytes) (base : Nat)
    (theta : Fin rows → Fin 32 → Float32) (reader : RopeRowsDynamicMemory.Reader rows) :
    captureSource memory base reader.1 reader.2 (theta reader.1 reader.2)=
      some (RopeRowsDynamicMemory.read memory base theta reader) := by
  unfold captureSource
  rw [parsed_indices,parsed_cell]
  change some (captureCell .forwardPair indices memory base reader.1 reader.2 (theta reader.1 reader.2))=_
  unfold captureCell
  rw [selected_positions]
  unfold RopeRowsDynamicMemory.read RopeSharedMemory.capture
  simp only [Prod.fst,Prod.snd]
  rw [show base+2*(256*reader.1.val+reader.2.val)=base+512*reader.1.val+2*reader.2.val by omega,
    show base+2*(256*reader.1.val+reader.2.val+32)=base+512*reader.1.val+2*(reader.2.val+32) by omega]

-- The parsed expressions permit only the existing three compiler contraction
-- choices per result. Fast sin/cos and FTZ are still explicit in Rope.Platform.
def result (_ : Cell) (p : Rope.Platform) (input : Rope.Inputs) (half : Fin 2) : BitVec 16 :=
  let a := BFloat16.widen input.first
  let b := BFloat16.widen input.second
  let c := p.cos input.theta
  let s := p.sin input.theta
  let value := if half.val=1 then Rope.sourceSecond p.second a b c s
    else Rope.sourceFirst p.first a b c s
  ArrayStorage.bits (BFloat16.narrow value)

theorem result_eq (p : Rope.Platform) (input : Rope.Inputs) (half : Fin 2) :
    result .forwardPair p input half=ArrayStorage.bits (Rope.value p input (decide (half.val=1))) := by
  by_cases h : half.val=1 <;> simp [result,Rope.value,Rope.source,h]

def storeCell (cell : Cell) (ast : Indices) (p : Rope.Platform) (base : Nat)
    (head : Fin rows) (lane : Fin 32) (half : Fin 2) (input : Rope.Inputs) : HalfMemory.Store :=
  let pos := positions ast lane.val head.val 256 32
  ⟨base/2+(if half.val=1 then pos.2 else pos.1),result cell p input half⟩

def storeSource (p : Rope.Platform) (base : Nat) (reader : RopeRowsDynamicMemory.Reader rows)
    (half : Fin 2) (input : Rope.Inputs) : Option HalfMemory.Store := do
  let ast ←parseIndices sourceIndices
  let cell ←parseCell sourceCell
  pure (storeCell cell ast p base reader.1 reader.2 half input)

theorem store_current (p : Rope.Platform) (base : Nat) (reader : RopeRowsDynamicMemory.Reader rows)
    (half : Fin 2) (input : Rope.Inputs) :
    storeSource p base reader half input=some (RopeRowsDynamicMemory.dynamic p base reader half input) := by
  unfold storeSource
  rw [parsed_indices,parsed_cell]
  change some (storeCell .forwardPair indices p base reader.1 reader.2 half input)=_
  unfold storeCell
  rw [selected_positions,result_eq]
  unfold RopeRowsDynamicMemory.dynamic RopeDynamicMemory.dynamic RopeDevice.index
  have hb := half.isLt
  by_cases h : half.val=1
  · simp only [h,ite_true]; congr 2 <;> omega
  · have hz : half.val=0 := by omega
    simp only [hz,reduceCtorEq,ite_false,Nat.mul_zero,Nat.add_zero]; congr 2 <;> omega

-- Source steps reuse the same pending-register/order obligations as the
-- verified machine. A captured pair is retained across its two stores.
inductive Step (p : Rope.Platform) (base : Nat) (theta : Fin rows → Fin 32 → Float32) :
    RopeRowsDynamicMemory.State rows → RopeRowsDynamicMemory.Event rows → RopeRowsDynamicMemory.State rows → Prop where
  | capture (state : RopeRowsDynamicMemory.State rows) (reader : RopeRowsDynamicMemory.Reader rows)
      (pending : state.registers reader=none) (input : Rope.Inputs)
      (parsed : captureSource state.memory base reader.1 reader.2 (theta reader.1 reader.2)=some input) :
      Step p base theta state (.capture reader)
        ⟨state.memory,Function.update state.registers reader (some input),state.history⟩
  | write (state : RopeRowsDynamicMemory.State rows) (reader : RopeRowsDynamicMemory.Reader rows)
      (half : Fin 2) (input : Rope.Inputs) (captured : state.registers reader=some input)
      (order : (state.history.filter (fun e => e.1=reader)).length=half.val)
      (store : HalfMemory.Store) (parsed : storeSource p base reader half input=some store) :
      Step p base theta state (.write reader half)
        ⟨HalfMemory.store state.memory (2*store.word) store.value,state.registers,state.history++[(reader,half)]⟩

theorem step_source (step : RopeRowsDynamicMemory.Step p base theta start event finish) :
    Step p base theta start event finish := by
  cases step with
  | capture reader pending =>
    exact .capture _ reader pending _ (capture_current _ _ _ _)
  | write reader half input captured order =>
    exact .write _ reader half input captured order _ (store_current _ _ _ _ _)

inductive Executes (p : Rope.Platform) (base : Nat) (theta : Fin rows → Fin 32 → Float32) :
    RopeRowsDynamicMemory.State rows → List (RopeRowsDynamicMemory.Event rows) → RopeRowsDynamicMemory.State rows → Prop where
  | done (state) : Executes p base theta state [] state
  | next : Step p base theta start event middle → Executes p base theta middle rest finish →
      Executes p base theta start (event::rest) finish

theorem trace_source (run : RopeRowsDynamicMemory.Executes p base theta start events finish) :
    Executes p base theta start events finish := by
  induction run with
  | done state => exact .done state
  | next step run ih => exact .next (step_source step) ih

theorem checked {rows base : Nat} {x : Fin rows → Fin 256 → ArrayStorage.BF}
    {source : RopeRowsMemory.Input x base} {p : Rope.Platform} {theta : Fin rows → Fin 32 → Float32}
    (execution : RopeRowsDynamicMemory.Execution p source theta) :
    Executes p base theta (RopeRowsDynamicMemory.initial source.memory) execution.events execution.finish :=
  trace_source execution.execution

end Inference.Kernels.Attention.MlxRopeSingleMemory

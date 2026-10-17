import kernels.normalization.MlxRmsHeadSyntax
import kernels.normalization.MlxRmsHeadHostSelection

namespace Inference.Kernels.Normalization.MlxRmsHeadRegisters
open Contracts.Mlx MlxRmsHeadSyntax MlxRmsOutputSyntax
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange

abbrev Registers := Fin 4 → Float32
structure State where
  registers : Registers
  acc : Float32

def loaded (source : Nat) (memory : HalfMemory.Bytes) (i : Fin 4) : Float32 :=
  BFloat16.widen (Model.ofBits (HalfMemory.load memory (source+2*i.val)))
def step (contracted : Bool) (value acc : Float32) : Float32 :=
  if contracted then FlushToZero.fma value value acc else FlushToZero.add acc (FlushToZero.mul value value)

def cell (contracted : Bool) (source : Nat) (memory : HalfMemory.Bytes) (i : Fin 4) (before : State) : State :=
  let value := loaded source memory i
  ⟨fun other => if other=i then value else before.registers other,step contracted value before.acc⟩

-- Restricted typed execution validates the local-array destination and both
-- reads of that just-written float register. Global source bytes are read
-- only here; the output machine below consumes cached float registers.
def executeCapture (body : Capture) (contracted : Bool) (source : Nat) (memory : HalfMemory.Bytes)
    (i : Fin 4) (before : State) : Option State :=
  match body.target,body.index,body.input,body.accumulator,body.product with
  | "thread_x",.var "i",.index "x" (.var "i"),"acc",
      .mul (.index "thread_x" (.var "i")) (.index "thread_x" (.var "i")) =>
    some (cell contracted source memory i before)
  | _,_,_,_,_ => none

def captureSource (contracted : Bool) (source : Nat) (memory : HalfMemory.Bytes)
    (i : Fin 4) (before : State) : Option State := do
  executeCapture (←parseCapture sourceCaptureBody) contracted source memory i before

theorem capture_execution (contracted : Bool) (source : Nat) (memory : HalfMemory.Bytes)
    (i : Fin 4) (before : State) :
    captureSource contracted source memory i before=some (cell contracted source memory i before) := by
  unfold captureSource
  rw [parsed_capture]
  rfl

def run (contracted : Bool) (source : Nat) (memory : HalfMemory.Bytes) : List (Fin 4) → State → State
  | [],before => before
  | i::rest,before => run contracted source memory rest (cell contracted source memory i before)

inductive Captures (contracted : Bool) (source : Nat) (memory : HalfMemory.Bytes) : List (Fin 4) → State → State → Prop where
  | nil (before) : Captures contracted source memory [] before before
  | next (body : captureSource contracted source memory i before=some middle)
      (rest : Captures contracted source memory offsets middle after) :
      Captures contracted source memory (i::offsets) before after

theorem canonical (contracted : Bool) (source : Nat) (memory : HalfMemory.Bytes)
    (offsets : List (Fin 4)) (before : State) :
    Captures contracted source memory offsets before (run contracted source memory offsets before) := by
  induction offsets generalizing before with
  | nil => exact .nil _
  | cons i rest ih => exact .next (capture_execution _ _ _ _ _) (ih _)

theorem registers (contracted : Bool) (source : Nat) (memory : HalfMemory.Bytes)
    (offsets : List (Fin 4)) (before : State) (i : Fin 4) :
    (run contracted source memory offsets before).registers i=
      if i∈offsets then loaded source memory i else before.registers i := by
  induction offsets generalizing before with
  | nil => simp [run]
  | cons first rest ih =>
    rw [run,ih]
    by_cases inRest : i∈rest
    · simp only [ite_eq_left inRest,List.mem_cons_of_mem first inRest,ite_true]
    · rw [ite_eq_right inRest]
      by_cases same : i=first
      · subst i; simp [cell]
      · simp only [cell,ite_eq_right same,List.mem_cons,not_or_intro same inRest,ite_false]

theorem accumulator (contracted : Bool) (source : Nat) (memory : HalfMemory.Bytes)
    (offsets : List (Fin 4)) (before : State) :
    (run contracted source memory offsets before).acc=
      offsets.foldl (fun acc i => step contracted (loaded source memory i) acc) before.acc := by
  induction offsets generalizing before with
  | nil => rfl
  | cons first rest ih => rw [run,ih]; rfl

def initial : State := ⟨fun _ => 0,0⟩
def captured (contracted : Bool) (source : Nat) (memory : HalfMemory.Bytes) : State :=
  run contracted source memory (List.finRange 4) initial

theorem captured_register (contracted : Bool) (source : Nat) (memory : HalfMemory.Bytes) (i : Fin 4) :
    (captured contracted source memory).registers i=loaded source memory i := by
  rw [captured,registers,ite_eq_left (List.mem_finRange i)]

-- The output store uses the register cache, and loads the weight from its
-- current heap. BF16 narrowing precedes BF16 weight multiplication.
def outputCell (weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (registers : Registers) (i : Fin 4) (before : HalfMemory.Bytes) : HalfMemory.Bytes :=
  HalfMemory.store before (destination+2*i.val) (ArrayStorage.bits
    (BFloat16Arithmetic.mul (Model.ofBits (HalfMemory.load before (weight+2*i.val)))
      (BFloat16.narrow (FlushToZero.mul (registers i) (inverse inverseBase)))))

def executeOutput (body : Store) (weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (registers : Registers) (i : Fin 4) (before : HalfMemory.Bytes) : Option HalfMemory.Bytes :=
  match body.destination,body.index,body.value with
  | "out",.var "i",.mul (.index "w" (.mul (.var "w_stride") (.var "i")))
      (.cast "T" (.mul (.index "thread_x" (.var "i")) (.index "local_inv_mean" .zero))) =>
    some (outputCell weight destination inverse inverseBase registers i before)
  | _,_,_ => none

def outputSource (weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (registers : Registers) (i : Fin 4) (before : HalfMemory.Bytes) : Option HalfMemory.Bytes := do
  executeOutput (←parseOutput sourceOutputBody) weight destination inverse inverseBase registers i before

theorem output_execution (weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (registers : Registers) (i : Fin 4) (before : HalfMemory.Bytes) :
    outputSource weight destination inverse inverseBase registers i before=
      some (outputCell weight destination inverse inverseBase registers i before) := by
  unfold outputSource
  rw [parsed_output]
  rfl

end Inference.Kernels.Normalization.MlxRmsHeadRegisters

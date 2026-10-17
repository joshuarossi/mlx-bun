import kernels.delta.GatedBytes
import kernels.delta.Recurrence
import kernels.delta.GatedInputs

namespace Inference.Kernels.Delta.GatedDevice
open Contracts.Mlx Contracts.Mlx.Numerics GatedStores
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
abbrev BF := GatedBytes.BF
abbrev State := Fin 48 → Fin 128 → Fin 128 → Float32
abbrev Inputs := Fin 48 → Fin 128 → Recurrence.Inputs Float32

def initialWords (initial : State) (word : Nat) : Float32 :=
  initial ⟨word/16384%48, by omega⟩ ⟨word/128%128, by omega⟩ ⟨word%128, by omega⟩

theorem initial_word (initial : State) (head : Fin 48) (row key : Fin 128) :
    initialWords initial (stateIndex head row key)=initial head row key := by
  have := head.isLt; have := row.isLt; have := key.isLt
  unfold initialWords
  congr 1 <;> apply Fin.ext <;> dsimp [stateIndex] <;> omega

structure Storage (initial : State) where
  bytes : ByteMemory.Bytes
  base : Nat
  aligned : base%4=0
  bounded : base+4*786432 ≤ 2^64
  attached : ∀ head row key, FloatMemory.load bytes (base+4*stateIndex head row key)=initial head row key

def Storage.canonical (initial : State) : Storage initial where
  bytes := FloatMemory.encode (initialWords initial)
  base := 0
  aligned := by decide
  bounded := by decide
  attached := by
    intro head row key
    rw [Nat.zero_add, FloatMemory.load_view _ _ (by omega), FloatMemory.view_encode,
      show 4*stateIndex head row key/4=stateIndex head row key by omega]
    exact initial_word initial head row key

def Storage.read (storage : Storage initial) (head : Fin 48) (row key : Fin 128) : Float32 :=
  FloatMemory.load storage.bytes (storage.base+4*stateIndex head row key)

theorem Storage.read_eq (storage : Storage initial) : storage.read=initial :=
  funext fun h => funext fun v => funext fun k => storage.attached h v k

@[irreducible] def producedState (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction)
    (state : State) (inputs : Inputs) (head : Fin 48) (row : Fin 128) : Fin 128 → Float32 :=
  Recurrence.step reduce flags (state head row) (inputs head row)

@[irreducible] def producedOutput (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction)
    (state : State) (inputs : Inputs) (head : Fin 48) (row : Fin 128) : BF :=
  Gated.value (Recurrence.bind (state head row) (inputs head row)) reduce flags

-- Arithmetic consumes the recurrent state and mixed BF16/FP32 input loads.
-- The final registers and BF16 output feed the ordered store programs.
structure Execution (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction) (initial : State) (inputs : Inputs) where
  values : GatedInputs.Values
  binding : values.inputs=inputs
  inputStorage : GatedInputs.Storage values
  storage : Storage initial
  stores : GatedBytes.Trace (producedState reduce flags storage.read inputStorage.inputs) (producedOutput reduce flags storage.read inputStorage.inputs)

def Execution.canonical (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction) (initial : State) (values : GatedInputs.Values) :
    Execution reduce flags initial values.inputs where
  values := values
  binding := rfl
  inputStorage := GatedInputs.Storage.canonical values
  storage := Storage.canonical initial
  stores := GatedBytes.Trace.canonical _ _

variable {reduce : (Fin 32 → Float32) → Float32} {flags : Gated.Contraction} {initial : State} {inputs : Inputs}

def Execution.state (execution : Execution reduce flags initial inputs) : State := execution.stores.stateRead
def Execution.output (execution : Execution reduce flags initial inputs) : Fin 48 → Fin 128 → BF := execution.stores.outputRead

theorem Execution.state_eq (execution : Execution reduce flags initial inputs) :
    execution.state=producedState reduce flags initial inputs := by
  have stored : execution.state=producedState reduce flags execution.storage.read execution.inputStorage.inputs :=
    funext fun h => funext fun v => funext fun k => execution.stores.state_correct h v k
  rw [execution.storage.read_eq, execution.inputStorage.inputs_eq, execution.binding] at stored
  exact stored

theorem Execution.output_eq (execution : Execution reduce flags initial inputs) :
    execution.output=producedOutput reduce flags initial inputs := by
  have stored : execution.output=producedOutput reduce flags execution.storage.read execution.inputStorage.inputs :=
    funext fun h => funext fun v => execution.stores.output_correct h v
  rw [execution.storage.read_eq, execution.inputStorage.inputs_eq, execution.binding] at stored
  exact stored

def Execution.after (execution : Execution reduce flags initial inputs) : Storage execution.state where
  bytes := execution.stores.stateMemory
  base := execution.stores.stateBase
  aligned := execution.stores.stateAligned
  bounded := execution.stores.stateBounded
  attached := fun _ _ _ => rfl

theorem Execution.next_bytes (execution : Execution reduce flags initial inputs) : execution.after.bytes=execution.stores.stateMemory := rfl

theorem Execution.state_error (execution : Execution reduce flags initial inputs) (platform : FlushedReduction.SimdContract reduce)
    (head : Fin 48) (row key : Fin 128) (targetState stateError : Fin 128 → ℝ) (target error : Recurrence.Inputs ℝ)
    (hs : ∀ k, |real (initial head row k)-targetState k| ≤ stateError k)
    (hi : Recurrence.InputError (inputs head row) target error)
    (hf : Arithmetic.Finite (Recurrence.bind (initial head row) (inputs head row)) (Gated.stateExpr flags platform.tree key)) :
    |real (execution.state head row key)-Recurrence.targetStep targetState target key| ≤
      Recurrence.stepBudget platform.tree flags (initial head row) (inputs head row) targetState stateError target error key := by
  rw [execution.state_eq]
  unfold producedState
  exact Recurrence.step_error reduce platform flags _ _ _ _ _ _ hs hi key hf

end Inference.Kernels.Delta.GatedDevice

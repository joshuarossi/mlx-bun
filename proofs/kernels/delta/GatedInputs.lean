import kernels.delta.Recurrence
import contracts.mlx.ArrayStorage

namespace Inference.Kernels.Delta.GatedInputs
open Contracts.Mlx
abbrev BF := ArrayStorage.BF

structure Values where
  key : Fin 16 → Fin 128 → BF
  query : Fin 16 → Fin 128 → BF
  value : Fin 48 → Fin 128 → BF
  decay : Fin 48 → Float32
  beta : Fin 48 → BF

def Values.inputs (values : Values) (head : Fin 48) (row : Fin 128) : Recurrence.Inputs Float32 where
  key i := BFloat16.widen (values.key (Layout.keyHead head) i)
  query i := BFloat16.widen (values.query (Layout.keyHead head) i)
  value := BFloat16.widen (values.value head row)
  decay := values.decay head
  beta := BFloat16.widen (values.beta head)

def index (head : Fin heads) (i : Fin 128) : Fin (heads*128) :=
  ⟨head.val*128+i.val, by have := head.isLt; have := i.isLt; omega⟩

def flatten (values : Fin heads → Fin 128 → α) (i : Fin (heads*128)) : α :=
  values ⟨i.val/128, by have := i.isLt; omega⟩ ⟨i.val%128, by omega⟩

theorem flatten_index (values : Fin heads → Fin 128 → α) (head : Fin heads) (i : Fin 128) :
    flatten values (index head i)=values head i := by
  have := i.isLt
  unfold flatten
  congr 1 <;> apply Fin.ext <;> dsimp [index] <;> omega

structure Storage (values : Values) where
  key : ArrayStorage.BFBuffer (flatten values.key)
  query : ArrayStorage.BFBuffer (flatten values.query)
  value : ArrayStorage.BFBuffer (flatten values.value)
  decay : ArrayStorage.FloatBuffer values.decay
  beta : ArrayStorage.BFBuffer values.beta

def Storage.canonical (values : Values) : Storage values where
  key := ArrayStorage.BFBuffer.canonical _ (by decide)
  query := ArrayStorage.BFBuffer.canonical _ (by decide)
  value := ArrayStorage.BFBuffer.canonical _ (by decide)
  decay := ArrayStorage.FloatBuffer.canonical _ (by decide)
  beta := ArrayStorage.BFBuffer.canonical _ (by decide)

def Storage.inputs (storage : Storage values) (head : Fin 48) (row : Fin 128) : Recurrence.Inputs Float32 where
  key i := BFloat16.widen (storage.key.read (index (Layout.keyHead head) i))
  query i := BFloat16.widen (storage.query.read (index (Layout.keyHead head) i))
  value := BFloat16.widen (storage.value.read (index head row))
  decay := storage.decay.read head
  beta := BFloat16.widen (storage.beta.read head)

theorem Storage.inputs_eq (storage : Storage values) : storage.inputs=values.inputs := by
  funext head row
  simp only [Storage.inputs, Values.inputs, ArrayStorage.BFBuffer.read_correct,
    ArrayStorage.FloatBuffer.read_correct, flatten_index]

-- The chosen B=T=1 source pointers agree with the loaded array indices.
theorem key_pointer (head : Fin 48) (row key : Fin 128) :
    Layout.qIndex (batchSize := 1) ⟨⟨0, by decide⟩, head, row⟩ 1 0 key=(index (Layout.keyHead head) key).val := by
  simp only [Layout.qIndex, index, Nat.zero_mul, Nat.zero_add]

theorem value_pointer (head : Fin 48) (row : Fin 128) :
    Layout.yIndex (batchSize := 1) ⟨⟨0, by decide⟩, head, row⟩ 1 0=(index head row).val := by
  simp only [Layout.yIndex, index, Nat.zero_mul, Nat.zero_add]

theorem gate_pointer (head : Fin 48) (row : Fin 128) :
    Layout.gateIndex (batchSize := 1) ⟨⟨0, by decide⟩, head, row⟩ 1 0=head.val := by
  simp only [Layout.gateIndex, Nat.zero_mul, Nat.zero_add]

end Inference.Kernels.Delta.GatedInputs

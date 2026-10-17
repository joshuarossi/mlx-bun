import contracts.mlx.ArrayStorage
import Mathlib.Logic.Equiv.Fin.Basic

namespace Inference.Contracts.Mlx.RowStorage
open ArrayStorage

def index (row : Fin rows) (column : Fin columns) : Fin (rows*columns) := finProdFinEquiv (row, column)

theorem index_value (row : Fin rows) (column : Fin columns) :
    (index row column).val=row.val*columns+column.val := by
  change column.val+columns*row.val=_
  ring

def flatten (values : Fin rows → Fin columns → BF) (i : Fin (rows*columns)) : BF :=
  let p := finProdFinEquiv.symm i
  values p.1 p.2

theorem flatten_index (values : Fin rows → Fin columns → BF) (row : Fin rows) (column : Fin columns) :
    flatten values (index row column)=values row column := by
  simp only [flatten, index, Equiv.symm_apply_apply]

-- A byte image assembled from row-local views. This is a representation
-- of the disjoint output regions, not an additional runtime copy or an
-- assertion about the native allocator.
def bytes {values : Fin rows → Fin columns → BF} (buffers : ∀ row, BFBuffer (values row)) : HalfMemory.Bytes :=
  fun address => if h : address/(2*columns)<rows then
    let row : Fin rows := ⟨address/(2*columns), h⟩
    (buffers row).bytes ((buffers row).base+address%(2*columns)) else 0

theorem byte_read {values : Fin rows → Fin columns → BF} (buffers : ∀ row, BFBuffer (values row))
    (row : Fin rows) (offset : Nat) (bound : offset<2*columns) :
    bytes buffers (2*(row.val*columns)+offset)=(buffers row).bytes ((buffers row).base+offset) := by
  have positive : 0<2*columns := by omega
  have address : 2*(row.val*columns)+offset=offset+row.val*(2*columns) := by ring
  have quotient : (2*(row.val*columns)+offset)/(2*columns)=row.val := by
    rw [address, Nat.add_mul_div_right _ _ positive, Nat.div_eq_of_lt bound, Nat.zero_add]
  have remainder : (2*(row.val*columns)+offset)%(2*columns)=offset := by
    rw [address, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt bound]
  simp only [bytes, quotient, row.isLt, ↓reduceDIte, remainder]
  have equal : (⟨(2*(row.val*columns)+offset)/(2*columns), by rw [quotient]; exact row.isLt⟩ : Fin rows)=row := Fin.ext quotient
  exact congrArg (fun r => (buffers r).bytes ((buffers r).base+offset)) equal

theorem raw_read {values : Fin rows → Fin columns → BF} (buffers : ∀ row, BFBuffer (values row))
    (row : Fin rows) (column : Fin columns) :
    HalfMemory.load (bytes buffers) (2*(row.val*columns+column.val))=
      HalfMemory.load (buffers row).bytes ((buffers row).base+2*column.val) := by
  have := column.isLt
  unfold HalfMemory.load
  simp only [Nat.mul_add, Nat.add_zero, Nat.add_assoc]
  rw [byte_read buffers row (2*column.val+1) (by omega), byte_read buffers row (2*column.val) (by omega)]

def buffer {values : Fin rows → Fin columns → BF} (buffers : ∀ row, BFBuffer (values row))
    (bound : 2*(rows*columns) ≤ 2^64) : BFBuffer (flatten values) where
  bytes := bytes buffers
  base := 0
  aligned := by decide
  bounded := by omega
  attached := by
    intro i
    let pair : Fin rows × Fin columns := finProdFinEquiv.symm i
    have equal : index pair.1 pair.2=i := Equiv.apply_symm_apply finProdFinEquiv i
    have loaded := raw_read buffers pair.1 pair.2
    rw [(buffers pair.1).attached] at loaded
    rw [← index_value, equal] at loaded
    simpa only [flatten, pair, Nat.zero_add] using loaded

theorem row_read {values : Fin rows → Fin columns → BF} (buffers : ∀ row, BFBuffer (values row))
    (bound : 2*(rows*columns) ≤ 2^64) (row : Fin rows) (column : Fin columns) :
    (buffer buffers bound).read (index row column)=values row column := by
  rw [BFBuffer.read_correct, flatten_index]

theorem rows_disjoint (a b : Fin rows) (different : a≠b) (i j : Fin columns) :
    (index a i).val≠(index b j).val := by
  intro same
  have equal : index a i=index b j := Fin.ext same
  exact different (congrArg Prod.fst (finProdFinEquiv.injective equal))

end Inference.Contracts.Mlx.RowStorage

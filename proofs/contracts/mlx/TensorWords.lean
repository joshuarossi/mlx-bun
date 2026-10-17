import contracts.mlx.BFloat16Arithmetic
import FloatLib.Floats.Formats.BinaryInterchange.IntervalSemantics.Order
import FloatLib.Floats.Formats.BinaryInterchange.Arithmetic.SignedSemantics.Core

namespace Inference.Contracts.Mlx.TensorWords
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- A proof-checking boundary for stored tensor words, independent of host
-- floating-point arithmetic. Applying it to a file still requires a binding
-- between that file's payload and these bytes, and a checked acceptance proof.
def littleEndian16 (low high : BitVec 8) : BitVec 16 :=
  BitVec.ofNat 16 (low.toNat + 256 * high.toNat)
def lowByte (word : BitVec 16) : BitVec 8 := BitVec.ofNat 8 word.toNat
def highByte (word : BitVec 16) : BitVec 8 := BitVec.ofNat 8 (word.toNat / 256)

theorem littleEndian16_value (low high : BitVec 8) :
    (littleEndian16 low high).toNat = low.toNat + 256 * high.toNat := by
  have hl := low.isLt
  have hh := high.isLt
  simp only [littleEndian16, BitVec.toNat_ofNat]
  apply Nat.mod_eq_of_lt
  norm_num at hl hh ⊢
  omega

theorem littleEndian16_roundtrip (word : BitVec 16) :
    littleEndian16 (lowByte word) (highByte word) = word := by
  apply BitVec.eq_of_toNat_eq
  rw [littleEndian16_value]
  have hw := word.isLt
  simp only [lowByte, highByte, BitVec.toNat_ofNat]
  norm_num at hw ⊢
  omega

def littleEndian32 (low high : BitVec 16) : BitVec 32 :=
  BitVec.ofNat 32 (low.toNat + 65536 * high.toNat)

theorem littleEndian32_value (low high : BitVec 16) :
    (littleEndian32 low high).toNat = low.toNat + 65536 * high.toNat := by
  have hl := low.isLt
  have hh := high.isLt
  simp only [littleEndian32, BitVec.toNat_ofNat]
  apply Nat.mod_eq_of_lt
  norm_num at hl hh ⊢
  omega

def readWord32 (bytes : Fin (4 * n) → BitVec 8) (i : Fin n) : BitVec 32 :=
  littleEndian32
    (littleEndian16 (bytes ⟨4*i.val, by omega⟩) (bytes ⟨4*i.val+1, by omega⟩))
    (littleEndian16 (bytes ⟨4*i.val+2, by omega⟩) (bytes ⟨4*i.val+3, by omega⟩))

theorem readWord32_value (bytes : Fin (4 * n) → BitVec 8) (i : Fin n) :
    (readWord32 bytes i).toNat = (bytes ⟨4*i.val, by omega⟩).toNat +
      256 * (bytes ⟨4*i.val+1, by omega⟩).toNat +
      65536 * (bytes ⟨4*i.val+2, by omega⟩).toNat +
      16777216 * (bytes ⟨4*i.val+3, by omega⟩).toNat := by
  rw [readWord32, littleEndian32_value, littleEndian16_value, littleEndian16_value]
  ring

def readWord (bytes : Fin (2 * n) → BitVec 8) (i : Fin n) : BitVec 16 :=
  littleEndian16 (bytes ⟨2*i.val, by omega⟩) (bytes ⟨2*i.val+1, by omega⟩)
def readBFloat16 (bytes : Fin (2 * n) → BitVec 8) (i : Fin n) : Model FloatFormat.bfloat16 :=
  Model.ofBits (readWord bytes i)
def readFloat16 (bytes : Fin (2 * n) → BitVec 8) (i : Fin n) : Model FloatFormat.binary16 :=
  Model.ofBits (readWord bytes i)

theorem readWord_exact (bytes : Fin (2 * n) → BitVec 8) (words : Fin n → BitVec 16)
    (low : ∀ i, bytes ⟨2*i.val, by omega⟩ = lowByte (words i))
    (high : ∀ i, bytes ⟨2*i.val+1, by omega⟩ = highByte (words i)) (i : Fin n) :
    readWord bytes i = words i := by
  rw [readWord, low i, high i, littleEndian16_roundtrip]

def accepts (x cap : Model fmt) : Bool :=
  Model.isFinite x && Model.isFinite cap &&
    Model.Interval.leB (Model.neg cap) x && Model.Interval.leB x cap

theorem accepts_iff (x cap : Model fmt) : accepts x cap = true ↔
    Model.isFinite x = true ∧ Model.isFinite cap = true ∧ |Model.toReal x| ≤ Model.toReal cap := by
  simp only [accepts, Bool.and_eq_true]
  constructor
  · rintro ⟨⟨⟨hx, hc⟩, lo⟩, hi⟩
    have hn : Model.isFinite (Model.neg cap) = true := by rw [Model.isFinite_neg]; exact hc
    have hl := (Model.Interval.leB_eq_true_iff_toReal_le_of_isFinite (Model.neg cap) x hn hx).mp lo
    rw [Model.toReal_neg cap hc] at hl
    exact ⟨hx, hc, abs_le.mpr ⟨hl, (Model.Interval.leB_eq_true_iff_toReal_le_of_isFinite x cap hx hc).mp hi⟩⟩
  · rintro ⟨hx, hc, hb⟩
    have hn : Model.isFinite (Model.neg cap) = true := by rw [Model.isFinite_neg]; exact hc
    refine ⟨⟨⟨hx, hc⟩, ?_⟩, (Model.Interval.leB_eq_true_iff_toReal_le_of_isFinite x cap hx hc).mpr (abs_le.mp hb).2⟩
    apply (Model.Interval.leB_eq_true_iff_toReal_le_of_isFinite (Model.neg cap) x hn hx).mpr
    rw [Model.toReal_neg cap hc]
    exact (abs_le.mp hb).1

def check (values : List (Model fmt)) (cap : Model fmt) : Bool := values.all (fun x => accepts x cap)

theorem check_sound (values : List (Model fmt)) (cap : Model fmt) (checked : check values cap = true)
    (i : Fin values.length) : Model.isFinite values[i] = true ∧ |Model.toReal values[i]| ≤ Model.toReal cap := by
  have h := List.all_eq_true.mp checked values[i] (List.getElem_mem i.isLt)
  have hs := (accepts_iff _ cap).mp h
  exact ⟨hs.1, hs.2.2⟩

theorem check_getD (values : List (Model fmt)) (cap fallback : Model fmt)
    (checked : check values cap = true)
    (default : Model.isFinite fallback = true ∧ |Model.toReal fallback| ≤ Model.toReal cap) (index : Nat) :
    Model.isFinite (values[index]?.getD fallback) = true ∧
      |Model.toReal (values[index]?.getD fallback)| ≤ Model.toReal cap := by
  by_cases hi : index < values.length
  · rw [List.getElem?_eq_getElem hi, Option.getD_some]
    exact check_sound values cap checked ⟨index, hi⟩
  · have hn : values[index]? = none := List.getElem?_eq_none (by omega)
    simpa only [hn, Option.getD_none] using default

theorem check_complete (values : List (Model fmt)) (cap : Model fmt) (hc : Model.isFinite cap = true)
    (bound : ∀ x ∈ values, Model.isFinite x = true ∧ |Model.toReal x| ≤ Model.toReal cap) :
    check values cap = true := by
  apply List.all_eq_true.mpr
  intro x hx
  exact (accepts_iff x cap).mpr ⟨(bound x hx).1, hc, (bound x hx).2⟩

theorem check_append (left right : List (Model fmt)) (cap : Model fmt) :
    check (left ++ right) cap = (check left cap && check right cap) := by
  simp only [check, List.all_append]

theorem check_replicate (count : Nat) (x cap : Model fmt) (checked : accepts x cap = true) :
    check (List.replicate count x) cap = true := by
  apply List.all_eq_true.mpr
  intro y hy
  have h := List.mem_replicate.mp hy
  simpa only [h.2] using checked

-- Certificates can be split into independent blocks or compressed runs.
-- Their soundness is checked by Lean; computing acceptance with a host
-- executable alone does not supply either theorem's proof premise.
theorem check_flatten (blocks : List (List (Model fmt))) (cap : Model fmt)
    (checked : ∀ block ∈ blocks, check block cap = true) : check blocks.flatten cap = true := by
  induction blocks with
  | nil => rfl
  | cons block rest ih =>
    rw [List.flatten_cons, check_append, checked block (by simp), Bool.true_and]
    exact ih (fun b hb => checked b (by simp [hb]))

def expandRuns (runs : List (Nat × Model fmt)) : List (Model fmt) :=
  runs.flatMap (fun run => List.replicate run.1 run.2)

theorem check_runs (runs : List (Nat × Model fmt)) (cap : Model fmt)
    (checked : ∀ run ∈ runs, accepts run.2 cap = true) : check (expandRuns runs) cap = true := by
  induction runs with
  | nil => rfl
  | cons run rest ih =>
    simp only [expandRuns, List.flatMap_cons]
    rw [check_append, check_replicate _ _ _ (checked run (by simp)), Bool.true_and]
    exact ih (fun r hr => checked r (by simp [hr]))

def expandDictionary (dictionary : List (Model fmt)) (indices : List (Fin dictionary.length)) : List (Model fmt) :=
  indices.map (fun index => dictionary[index])

theorem check_dictionary (dictionary : List (Model fmt)) (indices : List (Fin dictionary.length))
    (cap : Model fmt) (checked : check dictionary cap = true) :
    check (expandDictionary dictionary indices) cap = true := by
  apply List.all_eq_true.mpr
  intro x hx
  obtain ⟨i, _, rfl⟩ := List.mem_map.mp hx
  exact List.all_eq_true.mp checked dictionary[i] (List.getElem_mem i.isLt)

theorem readBFloat16_bound (bytes : Fin (2*n) → BitVec 8) (cap : Model FloatFormat.bfloat16)
    (checked : check (List.ofFn (readBFloat16 bytes)) cap = true) (i : Fin n) :
    Model.isFinite (readBFloat16 bytes i) = true ∧
      |Model.toReal (readBFloat16 bytes i)| ≤ Model.toReal cap := by
  have h := check_sound (List.ofFn (readBFloat16 bytes)) cap checked ⟨i.val, by simp⟩
  simpa using h

theorem readFloat16_bound (bytes : Fin (2*n) → BitVec 8) (cap : Model FloatFormat.binary16)
    (checked : check (List.ofFn (readFloat16 bytes)) cap = true) (i : Fin n) :
    Model.isFinite (readFloat16 bytes i) = true ∧
      |Model.toReal (readFloat16 bytes i)| ≤ Model.toReal cap := by
  have h := check_sound (List.ofFn (readFloat16 bytes)) cap checked ⟨i.val, by simp⟩
  simpa using h

end Inference.Contracts.Mlx.TensorWords

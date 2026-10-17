import kernels.sampling.ArgmaxPairs
import kernels.sampling.LogSumExpExponentRanges
import contracts.mlx.FloatArrayWrites
import contracts.mlx.WordArrayWrites

namespace Inference.Kernels.Sampling.ArgmaxStorage
open Contracts.Mlx Contracts.Mlx.Numerics ArgmaxPairs
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

def Valid (value : Candidate) : Prop := Finite value ∧ value.index<2^32
def score (value : Candidate) : Float32 := value.score.getD LogSumExpExponentRanges.negativeInfinity
def decodedScore (value : Float32) : Option Float32 := if Model.isInf (model value) then none else some value

theorem decoded_score (value : Candidate) (finite : Finite value) : decodedScore (score value)=value.score := by
  cases same : value.score with
  | none =>
    simp only [score, same, Option.getD_none]
    rfl
  | some x =>
    have hf : Model.isFinite (model x)=true := by rw [finite_model]; exact finite x same
    have notInf := Model.isInf_eq_false_of_isFinite_eq_true _ hf
    simp only [score, same, Option.getD_some, decodedScore, notInf, Bool.false_eq_true, ite_false]

theorem sentinel_valid : Valid sentinel := ⟨sentinel_finite, by decide⟩

theorem tree_valid (input : Fin n → Candidate) (t : Reduction.Tree n) (valid : ∀ i, Valid (input i)) : Valid (tree input t) :=
  tree_preserves Valid input t valid

theorem scan_valid (values : List Candidate) (initial : Candidate) (hi : Valid initial)
    (hv : ∀ value ∈ values, Valid value) : Valid (scan values initial) := scan_preserves Valid values initial hi hv

-- Float scores and uint32 IDs are distinct native output arrays. The
-- sentinel retains -infinity and 0xffffffff through either scratch phase.
structure Trace (values : Fin n → Candidate) where
  scores : FloatArrayWrites.Trace 0 (fun i => score (values i))
  ids : WordArrayWrites.Trace 0 (fun i => BitVec.ofNat 32 (values i).index)

def Trace.canonical (values : Fin n → Candidate) (bounded : 4*n ≤ 2^64) : Trace values :=
  ⟨FloatArrayWrites.Trace.canonical _ bounded, WordArrayWrites.Trace.canonical _ bounded⟩

variable {n : Nat} {values : Fin n → Candidate}

def Trace.read (trace : Trace values) (i : Fin n) : Candidate :=
  ⟨decodedScore (FloatMemory.load trace.scores.memory (4*i.val)), (ByteMemory.load32 trace.ids.memory (4*i.val)).toNat⟩

theorem Trace.read_correct (trace : Trace values) (valid : ∀ i, Valid (values i)) (i : Fin n) : trace.read i=values i := by
  have hs := trace.scores.read_correct i
  have hi := trace.ids.read_correct i
  simp only [Nat.zero_add] at hs hi
  unfold Trace.read
  rw [hs, hi, decoded_score _ (valid i).1]
  simp only [BitVec.toNat_ofNat, Nat.mod_eq_of_lt (valid i).2]

theorem Trace.score_bytes (trace : Trace values) (i : Fin n) :
    FloatMemory.load trace.scores.memory (4*i.val)=score (values i) := by
  simpa only [Nat.zero_add] using trace.scores.read_correct i

theorem Trace.id_bytes (trace : Trace values) (i : Fin n) :
    ByteMemory.load32 trace.ids.memory (4*i.val)=BitVec.ofNat 32 (values i).index := by
  simpa only [Nat.zero_add] using trace.ids.read_correct i

end Inference.Kernels.Sampling.ArgmaxStorage

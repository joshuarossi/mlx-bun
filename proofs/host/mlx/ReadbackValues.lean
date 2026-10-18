import host.mlx.FfiBytes
import host.ts.RenameBounded
set_option Elab.async false

namespace Host.Ts.F64

theorem toUint32_ofNat31 (n : Nat) (h : n < 2 ^ 31) : toUint32 (ofNat n) = n := by
  rw [ofNat_exact32 n h]
  have ht : truncInt (natExact n) = some (n : Int) := by
    cases n with
    | zero => rfl
    | succ n => simp [natExact, truncInt]
  simp only [toUint32, ht, modNat]
  exact Nat.mod_eq_of_lt (by omega)

end Host.Ts.F64
namespace Host.Mlx.FfiEval
open Host.Ts Host.Mlx.GlueStep

theorem leWord_u32 (token : Nat) (h : token < 2 ^ 32) :
    leWord (leBytes 4 token) 4 0 = token := by
  have hd : token / 256 / 256 / 256 < 256 := by
    rw [Nat.div_div_eq_div_mul, Nat.div_div_eq_div_mul]
    exact (Nat.div_lt_iff_lt_mul (by decide)).2 h
  unfold leWord
  conv_lhs =>
    arg 1
    ext k acc
    rw [Nat.mul_comm]
  rw [show List.range 4 = [0,1,2,3] by rfl]
  simp only [List.foldr_cons, List.foldr_nil, leBytes, Nat.zero_mul, Nat.zero_add,
    List.getD_cons_zero, List.getD_cons_succ, Nat.reducePow]
  rw [Nat.mod_eq_of_lt hd]
  calc
    _ = token % 256 + 256 * (token / 256 % 256 +
      256 * (token / 256 / 256 % 256 + 256 * (token / 256 / 256 / 256))) := by ring
    _ = token := by rw [Nat.mod_add_div, Nat.mod_add_div, Nat.mod_add_div]

theorem feedback_data (token : Nat) (h : token < 2 ^ 31) :
    dataValue (leBytes 4 token) [1,1] 3 = some (tokenIds token) := by
  change some (⟨.uint32, [1,1], fun i => leWord (leBytes 4 token) 4 (i % 1)⟩ : Value) = _
  simp only [Nat.mod_one, leWord_u32 token (by omega)]
  rfl

/-- The source byte buffer made from a returned numeric reference encodes
exactly the computed token, including the actual uint32 conversion. -/
theorem feedback_bytes (ν : NumV → Option F64) (value : NumV) (token : Nat)
    (hv : ν value = some (F64.ofNat token)) (ht : token < 2 ^ 31) :
    (cellParts .u32 (.num value) 4 0).mapM (concreteByte ν) = some (leBytes 4 token) := by
  rw [concreteByte_u32 ν value _ hv, F64.toUint32_ofNat31 token ht]

theorem feedback_input (ν : NumV → Option F64) (value : NumV) (token : Nat)
    (hv : ν value = some (F64.ofNat token)) (ht : token < 2 ^ 31) :
    ((cellParts .u32 (.num value) 4 0).mapM (concreteByte ν)).bind
      (fun bytes => dataValue bytes [1,1] 3) = some (tokenIds token) := by
  rw [feedback_bytes ν value token hv ht]
  exact feedback_data token ht

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : Env InKey) (ν : NumV → Option F64) (G : Nat → Option (RNode Int InKey))

theorem eval_feedback_data (node token : Nat) (ht : token < 2 ^ 31)
    (hg : G node = some ⟨.data (leBytes 4 token) [1,1] 3, []⟩) :
    evalR M K env G node = some (tokenIds token) := by
  rw [evalR_eq, hg, cgLeaves_none G node _ hg rfl]
  exact feedback_data token ht

/-- Evaluation of the actual constructor node made from the four returned
token bytes. This discharges the next token-tensor evaluation premise. -/
theorem native_feedback_data (native : Host.Mlx.Ffi.St) (sources : KernelSources)
    (node : Nat) (value : NumV) (token : Nat)
    (hv : ν value = some (F64.ofNat token)) (ht : token < 2 ^ 31)
    (hn : native.nodes.get node = some
      ⟨.data (cellParts .u32 (.num value) 4 0), [], Host.Mlx.Ffi.lits [1,1], 3⟩) :
    evalR M K env (ffiGraph (concrete ν) sources native) node = some (tokenIds token) := by
  apply eval_feedback_data M K env _ node token ht
  simp only [ffiGraph, hn, Option.bind_some, resolveNode, resolvePrim, concrete]
  rw [feedback_bytes ν value token hv ht]
  rfl

/-- A read symbol denotes the uint32 value of its producing graph node. This
property is proved from graph evaluation and the chosen recurrence valuation;
it is not an additional axiom about an independent token oracle. -/
def TokenRead (node : Nat) (value : NumV) (token : Nat) : Prop :=
  (∃ r, evalR M K env G node = some r ∧ itemUint32 r = some token) ∧
    ν value = some (F64.ofNat token)

/-- Every already memoized native read has its graph-computed value. -/
def ReadbackValues (items : PTrie NumV) : Prop :=
  ∀ node value, items.get node = some value →
    ∃ token, token < 2 ^ 31 ∧ TokenRead M K env ν G node value token

theorem ReadbackValues.empty : ReadbackValues M K env ν G .nil := by
  intro node value h
  simp [PTrie.get, PTrie.nil, Trie.get] at h

theorem ReadbackValues.set {items : PTrie NumV}
    (h : ReadbackValues M K env ν G items) (node : Nat) (value : NumV) (token : Nat)
    (hn : node < 2 ^ 64) (ht : token < 2 ^ 31) (hr : TokenRead M K env ν G node value token) :
    ReadbackValues M K env ν G (items.set node value) := by
  intro j v hv
  rw [PTrie.get_set_u64 _ _ _ hn] at hv
  split at hv
  · next he => subst j; cases hv; exact ⟨token, ht, hr⟩
  · exact h j v hv

theorem ReadbackValues.congr {items : PTrie NumV}
    (h : ReadbackValues M K env ν G items) (env' : Env InKey)
    (ν' : NumV → Option F64) (G' : Nat → Option (RNode Int InKey))
    (he : ∀ node value, items.get node = some value → evalR M K env G node = evalR M K env' G' node)
    (hv : ∀ node value, items.get node = some value → ν value = ν' value) :
    ReadbackValues M K env' ν' G' items := by
  intro node value hm
  obtain ⟨token, ht, ⟨r, hr, hi⟩, hn⟩ := h node value hm
  exact ⟨token, ht, ⟨r, (he node value hm).symm.trans hr, hi⟩, (hv node value hm).symm.trans hn⟩

theorem TokenRead.feedback {node : Nat} {value : NumV} {token : Nat}
    (h : TokenRead M K env ν G node value token) (ht : token < 2 ^ 31) :
    ((cellParts .u32 (.num value) 4 0).mapM (concreteByte ν)).bind
      (fun bytes => dataValue bytes [1,1] 3) = some (tokenIds token) :=
  feedback_input ν value token h.2 ht

end Host.Mlx.FfiEval

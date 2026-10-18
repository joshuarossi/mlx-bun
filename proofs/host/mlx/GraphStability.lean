import host.mlx.FfiEval

namespace Host.Mlx.FfiEval
open Inference.Contracts.Mlx

/-- A runtime graph has no expected-graph input placeholders. Replay tags
do not turn an input placeholder into an actual primitive. -/
def InputFree {δ κ : Type} : RPrim δ κ → Prop
  | .input _ => False
  | .replayed _ p => InputFree p
  | _ => True

/-- Resolving an actual FFI primitive never introduces an expected input leaf. -/
theorem resolvePrim_inputFree {δ κ : Type} (N : Nums δ)
    (kn : Nat → Option (List Char)) (shape : List Ffi.Dim) (dtype : Nat)
    (p : Ffi.Prim) (r : RPrim δ κ)
    (h : resolvePrim N kn shape dtype p = some r) : InputFree r := by
  induction p generalizing r with
  | replayed c p ih =>
    simp only [resolvePrim, Option.map_eq_some_iff] at h
    obtain ⟨r', hr', hr⟩ := h
    cases hr
    exact ih r' hr'
  | _ =>
    simp only [resolvePrim, bind, pure, Option.bind_eq_some_iff, Option.map_eq_some_iff,
      Option.some.injEq] at h
    repeat first | exact True.intro | obtain ⟨_, h⟩ := h

theorem ffiGraph_inputFree {δ κ : Type} (N : Nums δ) (S : KernelSources)
    (s : Ffi.St) (i : Nat) (r : RNode δ κ) (h : ffiGraph N S s i = some r) :
    InputFree r.prim := by
  obtain ⟨nd, _, hr⟩ := Option.bind_eq_some_iff.mp h
  obtain ⟨p, hp, he⟩ := Option.map_eq_some_iff.mp hr
  cases he
  exact resolvePrim_inputFree N (kernelName? S s) nd.shape nd.dtype nd.prim p hp

/-- State extension need only preserve the old nodes and the source-checked
kernel bindings to preserve the resolved graph prefix. -/
theorem ffiGraph_prefix {δ κ : Type} (N : Nums δ) (S : KernelSources)
    (s s' : Ffi.St) (i : Nat) (hn : s.nodes.get i = s'.nodes.get i)
    (hk : kernelName? S s = kernelName? S s') :
    ffiGraph (κ := κ) N S s i = ffiGraph N S s' i := by
  simp only [ffiGraph, hn, hk]

section
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
  {κ : Type} [DecidableEq κ]

theorem primEval_inputs (env env' : Env κ) (hw : env.weights = env'.weights)
    (p : RPrim Int κ) (hp : InputFree p) : primEval M K env p = primEval M K env' p := by
  induction p with
  | input key => exact hp.elim
  | replayed c p ih =>
    funext xs
    simp only [primEval]
    rw [ih hp]
  | load file key =>
    funext xs
    cases xs <;> simp only [primEval, hw]
  | _ =>
    funext xs
    rcases xs with _ | ⟨a, _ | ⟨b, _ | ⟨c, _ | ⟨d, _ | ⟨e, tail⟩⟩⟩⟩⟩ <;> rfl

/-- Appending graph nodes preserves every older value, including fused
compute_g roots, provided the resolved prefix is unchanged. -/
theorem evalR_prefix (env : Env κ) (G G' : Nat → Option (RNode Int κ)) :
    ∀ i, (∀ j ≤ i, G j = G' j) → evalR M K env G i = evalR M K env G' i := by
  intro i
  induction i using Nat.strong_induction_on with
  | h i ih =>
    intro hp
    have hf : (fun j => if _h : j < i then evalR M K env G j else none) =
        (fun j => if _h : j < i then evalR M K env G' j else none) := by
      funext j
      split
      · rw [ih j (by assumption) (fun k hk => hp k (by omega))]
      · rfl
    rw [evalR_eq, evalR_eq, hp i (Nat.le_refl i), cgLeaves_congr G G' i hp]
    cases G' i with
    | none => rfl
    | some nd =>
      cases cgLeaves G' i <;> simp only [hf]

/-- Runtime graph values are independent of the expected graph's input
environment. This permits cache and token values to feed the next step while
all checkpoint leaves retain the same file/key interpretation. -/
theorem evalR_inputs (env env' : Env κ) (hw : env.weights = env'.weights)
    (G : Nat → Option (RNode Int κ)) :
    ∀ i, (∀ j ≤ i, ∀ r, G j = some r → InputFree r.prim) →
      evalR M K env G i = evalR M K env' G i := by
  intro i
  induction i using Nat.strong_induction_on with
  | h i ih =>
    intro hp
    have hf : (fun j => if _h : j < i then evalR M K env G j else none) =
        (fun j => if _h : j < i then evalR M K env' G j else none) := by
      funext j
      split
      · rw [ih j (by assumption) (fun k hk r hr => hp k (by omega) r hr)]
      · rfl
    rw [evalR_eq, evalR_eq]
    cases hg : G i with
    | none => rfl
    | some nd =>
      cases cgLeaves G i with
      | some leaves => simp only [hf]
      | none =>
        simp only [hf]
        rw [primEval_inputs M K env env' hw nd.prim (hp i (Nat.le_refl i) nd hg)]

theorem evalFfi_inputs (env env' : Env κ) (hw : env.weights = env'.weights)
    (N : Nums Int) (S : KernelSources) (s : Ffi.St) (i : Nat) :
    evalR M K env (ffiGraph N S s) i = evalR M K env' (ffiGraph N S s) i :=
  evalR_inputs M K env env' hw _ i fun j _ r hr => ffiGraph_inputFree N S s j r hr

/-- A cached value can be reused in a later decode environment after graph
extension. No expected-input interpretation is assumed for actual FFI nodes. -/
theorem evalFfi_prefix (env env' : Env κ) (hw : env.weights = env'.weights)
    (N : Nums Int) (S : KernelSources) (s s' : Ffi.St) (i : Nat)
    (hn : ∀ j ≤ i, s.nodes.get j = s'.nodes.get j)
    (hk : kernelName? S s = kernelName? S s') :
    evalR M K env (ffiGraph N S s) i = evalR M K env' (ffiGraph N S s') i := by
  rw [evalFfi_inputs M K env env' hw]
  exact evalR_prefix M K env' _ _ i fun j hj => ffiGraph_prefix N S s s' j (hn j hj) hk

end
end Host.Mlx.FfiEval

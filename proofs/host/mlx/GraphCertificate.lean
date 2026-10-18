import host.mlx.FfiEval

namespace Host.Mlx.FfiEval

/-! Construct a carrier certificate from the FFI graph and the loaded input
handles. Searching chooses a candidate only; `certify` checks the entire
candidate with `Matches`, whose soundness theorem uses kernel proofs.
The search is deliberately incomplete: an unavailable input, a graph mismatch,
or an insufficient search bound returns `none`.

Input carriers must come from the actual load/decode states. This helper does
not establish `InputsHeld` or turn a caller-supplied graph into source execution. -/

def findCarriers (G : Nat → Option (RNode Int InKey))
    (E : List (RNode Int InKey)) (inputs : InKey → Option Nat) (upper : Nat) :
    Option (List Nat) :=
  E.foldlM (fun cert e => do
    let k := cert.length
    let carrier ← match e.prim with
      | .input key => inputs key
      | _ => (List.range upper).find? fun i => nodeOk G (cert ++ [i]) k e
    pure (cert ++ [carrier])) []

def certify (G : Nat → Option (RNode Int InKey))
    (E : List (RNode Int InKey)) (inputs : InKey → Option Nat) (upper : Nat) :
    Option (List Nat) := do
  let cert ← findCarriers G E inputs upper
  if Matches G E cert then some cert else none

/-- Check a bounded segment of the original certificate. Segments keep kernel
reduction memory bounded without changing any node or correspondence check. -/
def matchesRange {κ : Type} [DecidableEq κ] (G : Nat → Option (RNode Int κ)) (E : List (RNode Int κ))
    (cert : List Nat) (start count : Nat) : Bool :=
  (List.range' start count).all fun k => match E[k]? with
    | some e => nodeOk G cert k e
    | none => false

theorem matchesRange_append {κ : Type} [DecidableEq κ] (G : Nat → Option (RNode Int κ)) (E : List (RNode Int κ))
    (cert : List Nat) (start m n : Nat)
    (hm : matchesRange G E cert start m = true)
    (hn : matchesRange G E cert (start + m) n = true) :
    matchesRange G E cert start (m + n) = true := by
  unfold matchesRange at *
  rw [← List.range'_append_1, List.all_append, hm, hn]
  rfl

theorem matchesRange_complete {κ : Type} [DecidableEq κ] (G : Nat → Option (RNode Int κ)) (E : List (RNode Int κ))
    (cert : List Nat) (h : matchesRange G E cert 0 E.length = true) :
    Matches G E cert = true := by
  unfold Matches
  rw [List.range_eq_range']
  exact h

/-- Input leaves must use the actual load/cache/token projection's carriers.
`Matches` intentionally handles operation structure; this separate finite check
ties its free leaves to their source-state provenance. -/
def inputCarriersMatch {κ : Type} (E : List (RNode Int κ)) (cert : List Nat)
    (inputs : κ → Option Nat) : Bool :=
  (List.range E.length).all fun k => match E[k]? with
    | some e => match e.prim with
      | .input key => decide (inputs key = some (certAt cert k))
      | _ => true
    | none => false

theorem inputCarriersMatch_get {κ : Type} (E : List (RNode Int κ)) (cert : List Nat)
    (inputs : κ → Option Nat) (h : inputCarriersMatch E cert inputs = true)
    (k : Nat) (e : RNode Int κ) (key : κ) (he : E[k]? = some e) (hp : e.prim = .input key) :
    inputs key = some (certAt cert k) := by
  obtain ⟨hk, _⟩ := List.getElem?_eq_some_iff.mp he
  have hh := List.all_eq_true.mp h k (List.mem_range.mpr hk)
  simpa only [he, hp, decide_eq_true_eq] using hh

theorem certify_matches (G : Nat → Option (RNode Int InKey))
    (E : List (RNode Int InKey)) (inputs : InKey → Option Nat) (upper : Nat)
    (cert : List Nat) (h : certify G E inputs upper = some cert) :
    Matches G E cert = true := by
  unfold certify at h
  cases hc : findCarriers G E inputs upper with
  | none => simp [hc] at h
  | some found =>
    simp only [hc, bind, Option.bind] at h
    split at h
    · obtain rfl := Option.some.inj h
      assumption
    · contradiction

section
open Inference.Contracts.Mlx
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- Discharge `InputsHeld` from checked carrier provenance and the value of
each actual projected input. The latter is supplied by load preprocessing,
cache evolution and token-buffer decoding, not by graph matching alone. -/
theorem inputsHeld_of_carriers (env : Env InKey) (G : Nat → Option (RNode Int InKey))
    (E : List (RNode Int InKey)) (cert : List Nat) (inputs : InKey → Option Nat)
    (h : inputCarriersMatch E cert inputs = true)
    (values : ∀ key n, inputs key = some n → evalR M K env G n = env.inputs key) :
    InputsHeld M K env G E cert := by
  intro k e key he hp
  exact values key _ (inputCarriersMatch_get E cert inputs h k e key he hp)

/-- A successful certificate and independently established input values suffice
to transfer every expected node's value to its actual FFI carrier. -/
theorem certify_eval (env : Env InKey) (G : Nat → Option (RNode Int InKey))
    (E : List (RNode Int InKey)) (inputs : InKey → Option Nat) (upper : Nat)
    (cert : List Nat) (h : certify G E inputs upper = some cert)
    (hin : InputsHeld M K env G E cert) (i : Nat) (hi : i < E.length) :
    evalR M K env G (certAt cert i) = evalR M K env (listGraph E) i :=
  matches_eval M K env G E cert (certify_matches G E inputs upper cert h) hin i hi

end

namespace CertificateChecks

private def expected : List (RNode Int InKey) :=
  [⟨.input .tokenIds, []⟩, ⟨.reshape [1, 1], [0]⟩]

private def actual (shape : List Int) : Nat → Option (RNode Int InKey)
  | 4 => some ⟨.data [1, 0, 0, 0] [1] 7, []⟩
  | 7 => some ⟨.reshape shape, [4]⟩
  | _ => none

private def input : InKey → Option Nat
  | .tokenIds => some 4
  | _ => none

theorem accepts_carried_graph : certify (actual [1, 1]) expected input 8 = some [4, 7] := by decide +kernel
theorem rejects_changed_shape : certify (actual [1, 2]) expected input 8 = none := by decide +kernel
theorem rejects_missing_input : certify (actual [1, 1]) expected (fun _ => none) 8 = none := by decide +kernel
theorem rejects_short_search : certify (actual [1, 1]) expected input 7 = none := by decide +kernel
theorem input_carriers_bound : inputCarriersMatch expected [4, 7] input = true := by decide +kernel
theorem rejects_wrong_input_carrier : inputCarriersMatch expected [5, 7] input = false := by decide +kernel

end CertificateChecks
end Host.Mlx.FfiEval

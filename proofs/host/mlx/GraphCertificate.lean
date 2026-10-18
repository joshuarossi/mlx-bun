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

end CertificateChecks
end Host.Mlx.FfiEval

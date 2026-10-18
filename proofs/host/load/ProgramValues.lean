import host.load.Program
import host.load.Parameters
namespace Host.Load.Program
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract

/-- Every loaded parameter is a checked carrier in the load program, with
exactly the dtype and dimensions exposed by the source heap projection. -/
def covers (p : Code) (cert : List Nat) (ts : List Tensor) : Bool :=
  ts.all fun t =>
    let i := cert.idxOf t.node
    certAt cert i == t.node && match p[i]? with
      | some n => n.dtype == t.value.dtype &&
          t.value.shape == n.shape.map (fun d => Ffi.Dim.lit (Int.ofNat d))
      | none => false

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : Env InKey) (G : Nat → Option (RNode Int InKey))

def fallback : Value := ⟨.uint8, [], fun _ => 0⟩

noncomputable def contents (i : Nat) : Nat → Nat :=
  ((evalR M K env G i).getD fallback).elems

private theorem value_eq (a b : Value) (hd : a.dtype = b.dtype) (hs : a.shape = b.shape)
    (he : a.elems = b.elems) : a = b := by
  cases a; cases b; cases hd; cases hs; cases he; rfl

/-- The header-based interpretation is derived from actual load evaluation.
This removes intermediate tensor contents from the external assumptions. -/
theorem parameter_value (p : Code) (cert : List Nat) (ts : List Tensor)
    (hp : Valid p) (hl : Leaves p env.weights)
    (hm : Matches G (p.map Node.erase) cert = true) (hc : covers p cert ts = true)
    (ht : t ∈ ts) :
    evalR M K env G t.node = some (headerValues (contents M K env G) t) := by
  have ht' := List.all_eq_true.mp hc t ht
  simp only [Bool.and_eq_true, beq_iff_eq] at ht'
  dsimp at ht'
  generalize hi : cert.idxOf t.node = i at ht'
  rcases ht' with ⟨hcarrier, ht'⟩
  cases hn : p[i]? with
  | none => simp [hn] at ht'
  | some n =>
    simp only [hn, Bool.and_eq_true, beq_iff_eq] at ht'
    obtain ⟨v, hv, hd, hs⟩ := evaluated_actual M K env.weights env.inputs p G cert hp hl hm hn
    have he : evalR M K env G t.node = some v := by simpa [hcarrier] using hv
    have hd' : (Dtype.ofCode t.value.dtype).getD .uint8 = v.dtype := by
      rw [← ht'.1, ← hd, Dtype.ofCode_code]
      rfl
    have hs' : t.value.shape.map (fun d => match d with | .lit n => n.toNat | .sym _ => 0) = v.shape := by
      rw [ht'.2, ← hs]
      simp only [List.map_map, Function.comp_def, Int.toNat_natCast]
      exact List.map_id v.shape
    rw [he]
    congr 1
    apply value_eq
    · exact hd'.symm
    · exact hs'.symm
    · simp [headerValues, contents, he]

end Host.Load.Program

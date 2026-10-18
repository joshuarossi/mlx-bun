import host.load.ProgramValues
set_option Elab.async false

namespace Host.Load.Program
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : Env InKey) (G G' : Nat → Option (RNode Int InKey))

/-- A checked load carrier has the same value in every matching actual graph.
The common computation is the load program over the named checkpoint leaves. -/
theorem carrier_value_eq (p : Code) (cert : List Nat)
    (hm : Matches G (p.map Node.erase) cert = true)
    (hm' : Matches G' (p.map Node.erase) cert = true)
    (i : Nat) (hi : i < p.length) :
    evalR M K env G (certAt cert i) = evalR M K env G' (certAt cert i) := by
  have h := matches_eval M K env G (p.map Node.erase) cert hm
    (no_inputs M K env.weights env.inputs p G cert) i (by simpa using hi)
  have h' := matches_eval M K env G' (p.map Node.erase) cert hm'
    (no_inputs M K env.weights env.inputs p G' cert) i (by simpa using hi)
  exact h.trans h'.symm

theorem covered_value_eq (p : Code) (cert : List Nat) (t : Tensor)
    (hm : Matches G (p.map Node.erase) cert = true)
    (hm' : Matches G' (p.map Node.erase) cert = true)
    (hc : covered p cert t = true) :
    evalR M K env G t.node = evalR M K env G' t.node := by
  simp only [covered, Bool.and_eq_true, beq_iff_eq] at hc
  obtain ⟨hcarrier, hc⟩ := hc
  cases hn : p[cert.idxOf t.node]? with
  | none => simp [hn] at hc
  | some n =>
    have hi : cert.idxOf t.node < p.length := (List.getElem?_eq_some_iff.mp hn).choose
    simpa only [hcarrier] using carrier_value_eq M K env G G' p cert hm hm' _ hi

/-- Numeric-server choices outside the parameter ancestor closure cannot
change the parameter values constructed from that closure. -/
theorem parameter_values_eq (p : Code) (cert : List Nat) (ts : List Tensor)
    (hm : Matches G (p.map Node.erase) cert = true)
    (hm' : Matches G' (p.map Node.erase) cert = true)
    (hc : covers p cert ts = true) (t : Tensor) (ht : t ∈ ts) :
    headerValues (contents M K env G) t = headerValues (contents M K env G') t := by
  have he := covered_value_eq M K env G G' p cert t hm hm' (List.all_eq_true.mp hc t ht)
  simp only [headerValues, contents, he]

end Host.Load.Program

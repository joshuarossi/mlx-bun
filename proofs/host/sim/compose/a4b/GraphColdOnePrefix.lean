import host.sim.compose.a4b.GraphColdOneSource
import host.sim.compose.a4b.GraphColdMachine
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.ColdGraph.One
open _root_.Host.Ts _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter

noncomputable def prefixGs : Nat → Option (RNode PDim InKey) :=
  restrictTo (fun i => decide (i < 17777)) Gs

kernel_rfl cert_bounded_check : choice.cert.all (fun i => decide (i < 17777)) = true

theorem cert_bounded (k : Nat) (hk : k < fullExpected.1.length) :
    certAt choice.cert k < 17777 := by
  have hc : k < choice.cert.length := Nat.lt_of_lt_of_le hk cert_length
  have hm : certAt choice.cert k ∈ choice.cert := by
    unfold certAt
    rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hc, Option.getD_some]
    exact List.getElem_mem hc
  exact of_decide_eq_true (List.all_eq_true.mp cert_bounded_check _ hm)

theorem prefix_at (i : Nat) (hi : i < 17777) : prefixGs i = Gs i := by
  simp only [prefixGs, restrictTo, decide_eq_true hi, ↓reduceIte]

/-- computeG reads only the root and smaller ids, including all internal replay nodes. -/
theorem prefix_nodeOk (k : Nat) (hk : k < fullExpected.1.length) (e : RNode PDim InKey) :
    nodeOkD prefixGs choice.cert k e = nodeOkD Gs choice.cert k e := by
  have h := cert_bounded k hk
  have he : ∀ j ≤ certAt choice.cert k, prefixGs j = Gs j :=
    fun j hj => prefix_at j (Nat.lt_of_le_of_lt hj h)
  simp only [nodeOkD, cgLeaves_congr prefixGs Gs _ he, he _ (Nat.le_refl _)]

theorem prefix_checked : MatchesD prefixGs fullExpected.1 choice.cert = true := by
  unfold MatchesD
  apply List.all_eq_true.mpr
  intro k hk
  have h := List.all_eq_true.mp check.matches k hk
  have hl : k < fullExpected.1.length := List.mem_range.mp hk
  simp only [List.getElem?_eq_getElem hl] at h ⊢
  exact (prefix_nodeOk k hl _).trans h

/-- The expected graph, layout, certificate and complete length are unchanged. -/
noncomputable def T_prefix : PromptTemplate fullFamily where
  o₀ := 0
  n₀ := 1
  ss₀ := stages
  Gs := prefixGs
  cert := choice.cert
  checked := by rw [← full_expected_family]; exact prefix_checked
  length := by rw [← full_expected_family]; exact cert_length

theorem template_cert : T_prefix.cert = T.cert := rfl
theorem template_layout : (T_prefix.o₀, T_prefix.n₀, T_prefix.ss₀) = (T.o₀, T.n₀, T.ss₀) := rfl

end Host.Ts.Sim.Compose.ColdGraph.One

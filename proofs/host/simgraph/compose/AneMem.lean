import host.simgraph.compose.AneCut
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.FfiAneEval Inference.Contracts.Mlx
open Host.Mlx.FfiAne (Effect)
open Host.Mlx.SimGraph.Ref (RSt AneNet AneSt routeStep aneStep aneTplOf)

/-! # The Neural Engine memory of a full-world state, and the reference's data at its cuts

* `aneMem G init b`: the Neural Engine memory as A7's run theorem sees it — the bridge state `b`'s log (a full-world
  state `p`'s at `bridgeOf p`) run over the graph `G` from the loaded surfaces `init` (`FfiAneEval.final`). It reads
  only the log: an unchanged log leaves it (`aneMem_log`), effects appended to the log run on it
  (`aneMem_append`).
* At a cut of the reference (`RSt`): its surfaces (`refSurf`), the readers of the forwards run so far
  (`refReaders rd`: `rd i` the target's readers of forward `i`) and their values (`refVals rk`: reader `b` of forward
  `i` at key `k`, `rk b = some (i, k)`, holds that forward's readback). A D1 or GPU row step leaves all three
  (`refData_keep`); a Neural Engine step moves the surfaces to its forward's, adds its readers and keeps the earlier
  readers' values (`refData_ane`). -/

/-! ## The memory -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C)
  (weights : List Char → List Char → Option Value) (kind : Nat → Option Compiled)
  (NE : NeuralEngine) (IP : InPlace) (G : Graph) (init : Nat → Surface)

/-- **The Neural Engine memory of a full-world state**: its bridge log run over `G` from the loaded surfaces (the
memory before any effect when the log does not run). -/
noncomputable def aneMem (b : FfiAne.St) : Mem :=
  (final P K weights kind NE IP G init b).getD ⟨init, fun _ => none, fun _ => none⟩

theorem aneMem_final {b : FfiAne.St} {m : Mem} (h : final P K weights kind NE IP G init b = some m) :
    aneMem P K weights kind NE IP G init b = m := by
  simp [aneMem, h]

/-- An unchanged bridge log leaves the memory. -/
theorem aneMem_log {b b' : FfiAne.St} (h : b'.log = b.log) :
    aneMem P K weights kind NE IP G init b' = aneMem P K weights kind NE IP G init b := by
  simp only [aneMem, final, h]

/-- **Effects appended to the bridge log run on the memory** (the log is newest first). -/
theorem aneMem_append {b b' : FfiAne.St} {es : List Effect} {m m' : Mem}
    (h : b'.log = es.reverse ++ b.log)
    (h0 : final P K weights kind NE IP G init b = some m) (h1 : run P K weights kind NE IP G m es = some m') :
    final P K weights kind NE IP G init b' = some m' ∧ aneMem P K weights kind NE IP G init b' = m' := by
  have e : final P K weights kind NE IP G init b' = some m' := by
    unfold final at h0 ⊢
    rw [h, List.reverse_append, List.reverse_reverse, run_append, h0, Option.bind_some]
    exact h1
  exact ⟨e, aneMem_final P K weights kind NE IP G init e⟩

end

/-! ## The reference's data at a cut -/

section
/-- The surfaces at a cut of the reference. -/
def refSurf (s : RSt) : Nat → Surface := s.surf

/-- The readers of the forwards run so far: `rd i` the target's readers of forward `i`. -/
def refReaders (rd : Nat → List Reader) (s : RSt) : List Reader := (List.range s.anes.length).flatMap rd

/-- The readers' values at a cut: reader `b` of forward `i` at key `k` (`rk b = some (i, k)`) holds that forward's
readback at `k`. -/
def refVals (rk : Nat → Option (Nat × AKey)) (s : RSt) : Nat → Option Value :=
  fun b => (rk b).bind fun ik => (s.anes[ik.1]?).bind fun a => a.rb ik.2

/-- A step keeping the surfaces and the recorded forwards keeps the data. -/
theorem refData_keep (rd : Nat → List Reader) (rk : Nat → Option (Nat × AKey)) {s s' : RSt}
    (h : s'.surf = s.surf ∧ s'.anes = s.anes) :
    refSurf s' = refSurf s ∧ refReaders rd s' = refReaders rd s ∧ refVals rk s' = refVals rk s := by
  refine ⟨by simp [refSurf, h.1], by simp [refReaders, h.2], ?_⟩
  funext b
  simp only [refVals, h.2]

/-- Recording a forward `r`: the surfaces are its, its readers added, the earlier forwards' readers' values kept,
its own readers' values its readbacks. -/
theorem refData_snoc (rd : Nat → List Reader) (rk : Nat → Option (Nat × AKey)) {s s' : RSt} {r : AneSt}
    (hs : s'.surf = r.surf) (ha : s'.anes = s.anes ++ [r]) :
    refSurf s' = r.surf ∧ refReaders rd s' = refReaders rd s ++ rd s.anes.length ∧
      (∀ b, (∀ ik, rk b = some ik → ik.1 < s.anes.length) → refVals rk s' b = refVals rk s b) ∧
      ∀ b k, rk b = some (s.anes.length, k) → refVals rk s' b = r.rb k := by
  refine ⟨hs, ?_, fun b hb => ?_, fun b k hb => ?_⟩
  · simp [refReaders, ha, List.range_succ]
  · unfold refVals
    cases e : rk b with
    | none => rfl
    | some ik =>
      have hi := hb ik e
      simp only [Option.bind_some, ha]
      rw [List.getElem?_append_left hi]
  · simp [refVals, hb, ha]

end

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) (NE : NeuralEngine)
  (IP : InPlace) (net : AneNet) (weights : List Char → List Char → Option Value) (w : GlueStep.PipelineWeights)
  (π : List Nat)

/-- **A route step's data**: a D1 or GPU row step keeps the reference's data at the cut; a Neural Engine step
records its forward (`refData_snoc`). -/
theorem refData_ane (rd : Nat → List Reader) (rk : Nat → Option (Nat × AKey)) {st : Host.Ts.Sim.Prefill.PStep}
    {s s' : RSt} (h : routeStep P K NE IP net weights w π st s = some s') :
    (refSurf s' = refSurf s ∧ refReaders rd s' = refReaders rd s ∧ refVals rk s' = refVals rk s) ∨
      ∃ T r, aneTplOf (st.stop - st.start) = some T ∧ s'.surf = r.surf ∧ s'.anes = s.anes ++ [r] := by
  rcases routeStep_surf P K NE IP net weights w π h with hk | ⟨T, hT, ha⟩
  · exact .inl (refData_keep rd rk hk)
  · obtain ⟨_, r, _, _, h1, h2, _⟩ := Ref.aneStep_spec P K NE IP net weights w π T _ _ s s' ha
    exact .inr ⟨T, r, hT, h2, h1⟩

end

end Host.Mlx.SimGraph

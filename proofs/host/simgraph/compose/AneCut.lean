import host.simgraph.family.ane.Close
import host.simgraph.ref.Route
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.GlueStep Inference.Contracts.Mlx
open Host.Mlx.FfiAne (Effect)
open Host.Mlx.SimGraph.Ref (RSt AneNet routeStep aneStep aneTplOf gpuFamily)

/-! # The Neural Engine side across forwards

The Neural Engine surfaces are shared machine-wide (every bucket's MLP splits use the first build's buffers, the
affine splits one set per shape), so a forward's calls run on the whole surfaces the previous forwards left, stale
rows included, and its sources depend on the earlier forwards' readers (through the KV caches).

* The reference threads them so (`routeStep_surf`): a D1 or GPU row step leaves the surfaces and the recorded
  forwards; a Neural Engine step is `aneStep` on the state's surfaces (`aneStep_spec`: its calls chain them, each
  fill's launch on its surface's whole previous contents, `fillRun`, the program on its input surfaces as the fills
  left them, its output laid over the output surface's old bytes, `runCall`).
* `AneCut V D σ m`: the component of a cut between forwards — the memory holds the threaded surfaces `σ` and every
  earlier forward's reader (`D`) holds its value (`V`). It is the premise of a forward's run (`forward_run`,
  `aneTpl_forward`: `hD`, `hm`, `hv`), holds at the start (`aneCut_start`), is kept by one forward
  (`aneCut_forward`), by reader-only evaluations off `D` (`aneCut_readers`) and by any effects keeping the surfaces
  and `D`'s values (`aneCut_keep`), and composes along a log (`aneCut_seq`, by `run_append`); forwards chain as one
  layer list (`layersOk_append`, by `segsOk_append`). -/

/-! ## The reference threads the surfaces -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) (NE : NeuralEngine)
  (IP : InPlace) (net : AneNet) (weights : List Char → List Char → Option Value) (w : PipelineWeights)
  (π : List Nat)

/-- **A route step's surfaces**: a D1 or GPU row step keeps the surfaces and the recorded forwards; a Neural Engine
step is its bucket family's `aneStep` from the state (whose calls chain the surfaces, `aneStep_spec`). -/
theorem routeStep_surf {st : Host.Ts.Sim.Prefill.PStep} {s s' : RSt}
    (h : routeStep P K NE IP net weights w π st s = some s') :
    (s'.surf = s.surf ∧ s'.anes = s.anes) ∨ ∃ T, aneTplOf (st.stop - st.start) = some T ∧
      aneStep P K NE IP net weights w π T st.start (st.stop - st.start) s = some s' := by
  unfold routeStep at h
  split at h
  · obtain ⟨hs, _, rfl⟩ := Option.map_eq_some_iff.mp h
    exact .inl ⟨rfl, rfl⟩
  · split at h
    · obtain ⟨hs, _, rfl⟩ := Option.map_eq_some_iff.mp h
      exact .inl ⟨rfl, rfl⟩
    · split at h
      · rename_i T hT
        exact .inr ⟨T, hT, h⟩
      · cases h

end

/-! ## The cut between forwards -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C)
  (weights : List Char → List Char → Option Value) (kind : Nat → Option Compiled)
  (NE : NeuralEngine) (IP : InPlace) (G : Graph)

/-- **The Neural Engine side of a cut between forwards**: the memory holds the threaded surfaces `σ` (the
reference's, stale rows included) and every earlier forward's reader (`D`, with its FFI facts) holds its value. -/
structure AneCut (V : Nat → Option Value) (D : List Reader) (σ : Nat → Surface) (m : Mem) : Prop where
  surf : m.surf = σ
  readers : ∀ r ∈ D, Reader.At P K weights G r
  vals : ∀ r ∈ D.map Reader.b, m.vals r = V r

/-- Before any forward: the loaded surfaces, no reader. -/
theorem aneCut_start (V : Nat → Option Value) (init : Nat → Surface) (vals : Nat → Option Value)
    (pend : Nat → Option Surface) : AneCut P K weights G V [] init ⟨init, vals, pend⟩ :=
  ⟨rfl, fun _ h => (by cases h), fun _ h => (by cases h)⟩

/-- **One forward keeps the cut**: its log runs, the memory after holds the surfaces its last call left and every
reader so far (the earlier ones and its own), every other fixed value kept. -/
theorem aneCut_forward {V : Nat → Option Value} {D : List Reader} {σ σ' : Nat → Surface} {m : Mem}
    (h : AneCut P K weights G V D σ m) (ls : List AneLayer) (hl : LayersOk P K weights kind NE IP G V D σ ls σ') :
    ∃ m', run P K weights kind NE IP G m (ls.flatMap fun l => segsLog l.segs) = some m' ∧
      AneCut P K weights G V (D ++ segsReaders (forwardSegs ls)) σ' m' ∧
      ∀ j, j ∉ segsNodes (forwardSegs ls) → m'.vals j = m.vals j := by
  obtain ⟨m', e, hs, hv, hf⟩ := forward_run P K weights kind NE IP G V ls D σ σ' m h.readers hl h.surf h.vals
  have hr := segsOk_readers P K weights kind NE IP G V (forwardSegs ls) D σ σ'
    (layersOk_segs P K weights kind NE IP G V ls D σ σ' hl)
  refine ⟨m', e, ⟨hs, fun r hm => ?_, hv⟩, hf⟩
  rcases List.mem_append.mp hm with hm | hm
  · exact h.readers r hm
  · exact hr r hm

/-- Effects keeping the surfaces and the earlier readers' values keep the cut. -/
theorem aneCut_keep {V : Nat → Option Value} {D : List Reader} {σ : Nat → Surface} {m m' : Mem}
    (h : AneCut P K weights G V D σ m) (hs : m'.surf = m.surf) (hv : ∀ r ∈ D.map Reader.b, m'.vals r = m.vals r) :
    AneCut P K weights G V D σ m' :=
  ⟨hs.trans h.surf, h.readers, fun r hr => (hv r hr).trans (h.vals r hr)⟩

/-- A reader's evaluation keeps the surfaces and every other fixed value. -/
theorem runNode_reader {m m' : Mem} {n : Nat} {sids : List Nat} (ht : G.touch n = some (.read sids))
    (e : runNode P K weights kind IP G m n = some m') : m'.surf = m.surf ∧ ∀ j, j ≠ n → m'.vals j = m.vals j := by
  unfold runNode at e
  rw [ht] at e
  dsimp only at e
  split at e
  · split at e
    · obtain ⟨v, _, rfl⟩ := Option.map_eq_some_iff.mp e
      exact ⟨rfl, fun j hj => by simp [upd, hj]⟩
    · cases e
  · cases e

theorem readers_keep {m m' : Mem} : ∀ (ns : List Nat), (∀ n ∈ ns, ∃ sids, G.touch n = some (.read sids)) →
    ns.foldlM (runNode P K weights kind IP G) m = some m' → m'.surf = m.surf ∧ ∀ j, j ∉ ns → m'.vals j = m.vals j
  | [], _, e => by cases e; exact ⟨rfl, fun _ _ => rfl⟩
  | n :: ns, hr, e => by
    simp only [List.foldlM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff] at e
    obtain ⟨m1, e1, e2⟩ := e
    obtain ⟨sids, ht⟩ := hr n (List.mem_cons_self ..)
    obtain ⟨s1, v1⟩ := runNode_reader P K weights kind IP G ht e1
    obtain ⟨s2, v2⟩ := readers_keep ns (fun x hx => hr x (List.mem_cons_of_mem _ hx)) e2
    refine ⟨s2.trans s1, fun j hj => ?_⟩
    simp only [List.mem_cons, not_or] at hj
    rw [v2 j hj.2, v1 j hj.1]

/-- **Reader-only evaluations off the earlier readers keep the cut** (a token readback, an MLX evaluation of the
GPU share: no writer runs, no earlier reader is re-run). -/
theorem aneCut_readers {V : Nat → Option Value} {D : List Reader} {σ : Nat → Surface} {m m' : Mem}
    (h : AneCut P K weights G V D σ m) (ns : List Nat) (hr : ∀ n ∈ ns, ∃ sids, G.touch n = some (.read sids))
    (hD : ∀ n ∈ ns, n ∉ D.map Reader.b) (e : run P K weights kind NE IP G m [.gpu ns] = some m') :
    AneCut P K weights G V D σ m' := by
  simp only [FfiAneEval.run, List.foldlM_cons, List.foldlM_nil, runEffect_gpu, Option.bind_eq_bind] at e
  obtain ⟨m1, e1, e2⟩ := Option.bind_eq_some_iff.mp e
  cases e2
  obtain ⟨hs, hv⟩ := readers_keep P K weights kind IP G ns hr e1
  exact aneCut_keep P K weights G h hs fun r hrD => hv r fun hn => hD r hn hrD

/-- **Cuts compose along a log** (`run_append`): effects taking every cut at `(D, σ)` to one at `(D', σ')`, then
effects taking every cut at `(D', σ')` to one at `(D'', σ'')`. -/
theorem aneCut_seq {V : Nat → Option Value} {D D' D'' : List Reader} {σ σ' σ'' : Nat → Surface} {es fs : List Effect}
    (h1 : ∀ m, AneCut P K weights G V D σ m → ∃ m', run P K weights kind NE IP G m es = some m' ∧
      AneCut P K weights G V D' σ' m')
    (h2 : ∀ m, AneCut P K weights G V D' σ' m → ∃ m', run P K weights kind NE IP G m fs = some m' ∧
      AneCut P K weights G V D'' σ'' m') :
    ∀ m, AneCut P K weights G V D σ m → ∃ m', run P K weights kind NE IP G m (es ++ fs) = some m' ∧
      AneCut P K weights G V D'' σ'' m' := by
  intro m hm
  obtain ⟨m1, e1, c1⟩ := h1 m hm
  obtain ⟨m2, e2, c2⟩ := h2 m1 c1
  exact ⟨m2, by rw [run_append, e1, Option.bind_some]; exact e2, c2⟩

/-- **Forwards chain as one layer list** (`segsOk_append`): the layers of consecutive forwards, each from the
surfaces the previous left, every earlier reader done. -/
theorem layersOk_append (V : Nat → Option Value) : ∀ (ls ks : List AneLayer) (D : List Reader) (σ σ'' : Nat → Surface),
    LayersOk P K weights kind NE IP G V D σ (ls ++ ks) σ'' ↔
      ∃ σ', LayersOk P K weights kind NE IP G V D σ ls σ' ∧
        LayersOk P K weights kind NE IP G V (D ++ segsReaders (forwardSegs ls)) σ' ks σ''
  | [], ks, D, σ, σ'' => by simp [LayersOk, forwardSegs, segsReaders]
  | l :: ls, ks, D, σ, σ'' => by
    simp only [List.cons_append, LayersOk]
    constructor
    · rintro ⟨σ', h1, h2⟩
      obtain ⟨σ2, h3, h4⟩ := (layersOk_append V ls ks _ σ' σ'').1 h2
      refine ⟨σ2, ⟨σ', h1, h3⟩, ?_⟩
      simpa [forwardSegs, segsReaders_append, List.append_assoc] using h4
    · rintro ⟨σ2, ⟨σ', h1, h3⟩, h4⟩
      refine ⟨σ', h1, (layersOk_append V ls ks _ σ' σ'').2 ⟨σ2, h3, ?_⟩⟩
      simpa [forwardSegs, segsReaders_append, List.append_assoc] using h4

end

end Host.Mlx.SimGraph

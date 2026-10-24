import host.simgraph.ref.Ane
namespace Host.Mlx.SimGraph.Ref
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.GlueStep Host.Mlx.SimGraph Inference.Contracts.Mlx
open Host.Ts.Sim.Prefill (PStep Phase chunkC chunkC_eq drains tailRows)

/-! # The route's prefill step semantics

The state the prefill carries (`RSt`): the cache handles, the Neural Engine surfaces, and each Neural Engine
forward's evaluation so far (`AneSt`, in order: its values, its readbacks — the route's readers of the `i`-th
such forward hold the `i`-th one's at their keys — and its logged calls). A step (`routeStep`) of `n` rows at
offset `o` (phase-dispatch.ts:76, the model's `prompt`/`promptChunk` ranges,
models/qwen/qwen38-27b-trellis-m1max.ts:1180-1181):

* one row: D1 (`d1Sem`);
* a GPU row class (`gpuFamily`: tails of 2–223 rows, chunks of 64 or 128): its family's value instance
  (`rowSem`);
* a Neural Engine bucket (`aneTplOf`: 224–2048 rows): the family's graph evaluated with the bucket's calls
  (`aneStep`, `aneNodes`), threading the surfaces and recording the evaluation; `aneStep_spec`: its calls ran
  and chain the surfaces, and the readbacks are the fixpoint (`aneNodes_calls`, `aneNodes_evalE`).

`prefill_short`: a prompt of at most 224 tokens has no drain and a GPU tail; its prefill reads neither the
Neural Engine side nor the surfaces. -/

/-- The prefill's state: the cache handles, the Neural Engine surfaces, the Neural Engine forwards' evaluations. -/
structure RSt where
  hs : List Handles
  surf : Nat → Surface
  anes : List AneSt

/-- **The Neural Engine bucket family** of a step of `n` rows (`aneRanges`, from 224 rows): #aneSmall up to 512,
#aneDense up to 704, #aneAffine with a GPU rest of 11264 rows (`.353`) at 705–768 and of 10752 (`.382`) above. -/
def aneTplOf (n : Nat) : Option (RowTplX AKey) :=
  if n < 224 then none else if n ≤ 512 then some (aneSmall refRows) else if n ≤ 704 then some (aneDense refRows)
  else if n ≤ 768 then some (aneAffine refRows 11264) else if n ≤ 2048 then some (aneAffine refRows 10752) else none

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) (NE : NeuralEngine)
  (IP : InPlace) (net : AneNet) (weights : List Char → List Char → Option Value) (w : PipelineWeights)
  (π : List Nat)

/-- A Neural Engine step's environment: `stepEnv`'s inputs at the family's `.p` keys, the construction-time
inputs at the others. -/
def aneEnv (o n : Nat) (ids : Value) (hs : List Handles) : Env AKey :=
  ⟨weights, fun k => match k with
    | .p k' => promptInputs (stepInputs w 0 hs) ids (refNu o n) k'
    | k' => net.inputs n k'⟩

/-- **A Neural Engine step**: the family graph's values with the bucket's calls from the state's surfaces; the
caches as handles, the surfaces after, the readbacks recorded. -/
noncomputable def aneStep (T : RowTplX AKey) (o n : Nat) (s : RSt) : Option RSt := do
  let ids ← rowIds π o n
  let ss := chainLayout (stageWeights w) s.hs
  let g := familyGraph T.toTpl.ops (PDim.eval (refNu o n)) o n ss
  let r ← aneNodes P K NE IP net n (aneEnv net weights w o n ids s.hs) (T.tapsOf (PDim.eval (refNu o n)) o n ss) g.1
    ⟨[], fun _ => none, s.surf, []⟩
  let cs ← g.2.2.mapM fun c => do pure ((← r.vals[c.1]?), (← r.vals[c.2]?))
  let hs' ← handlesOf (stageWeights w) cs
  pure ⟨hs', r.surf, s.anes ++ [r]⟩

/-- **A Neural Engine step's facts**: the step's evaluation of the family graph (from no readback, at the
state's surfaces) is appended and leaves the surfaces; its calls chain the surfaces from the step's start, each
ran on its site's values with its readback the key's (`CallOk`), and at the environment holding the readbacks
the family graph's evaluation is the evaluation's value at every node (the fixpoint). -/
theorem aneStep_spec (T : RowTplX AKey) (o n : Nat) (s s' : RSt)
    (h : aneStep P K NE IP net weights w π T o n s = some s') :
    ∃ ids r, rowIds π o n = some ids ∧
      aneNodes P K NE IP net n (aneEnv net weights w o n ids s.hs)
          (T.tapsOf (PDim.eval (refNu o n)) o n (chainLayout (stageWeights w) s.hs))
          (familyGraph T.toTpl.ops (PDim.eval (refNu o n)) o n (chainLayout (stageWeights w) s.hs)).1
          ⟨[], fun _ => none, s.surf, []⟩ = some r ∧
      s'.anes = s.anes ++ [r] ∧ s'.surf = r.surf ∧ CallsChain s.surf r.log r.surf ∧
      (∀ c ∈ r.log, CallOk NE IP net n (T.tapsOf (PDim.eval (refNu o n)) o n (chainLayout (stageWeights w) s.hs))
        r.vals r.rb c) ∧
      ∀ i, i < (familyGraph T.toTpl.ops (PDim.eval (refNu o n)) o n (chainLayout (stageWeights w) s.hs)).1.length →
        evalE P K.toKernelContract (withRb (aneEnv net weights w o n ids s.hs) r.rb)
          (ksR P K (withRb (aneEnv net weights w o n ids s.hs) r.rb))
          (listGraph (familyGraph T.toTpl.ops (PDim.eval (refNu o n)) o n (chainLayout (stageWeights w) s.hs)).1) i =
        r.vals[i]? := by
  unfold aneStep at h
  simp only [Option.bind_eq_bind, Option.bind_eq_some_iff, Option.pure_def, Option.some.injEq] at h
  obtain ⟨ids, hids, r, hr, cs, _, hs', _, rfl⟩ := h
  obtain ⟨hc, hok⟩ := aneNodes_calls P K NE IP net n _ _ _ _ _ hr
  exact ⟨ids, r, hids, hr, rfl, rfl, hc, hok, (aneNodes_evalE P K NE IP net n _ _ _ _ _ hr).2⟩

/-- **The route's step semantics.** -/
noncomputable def routeStep : StepSem RSt := fun st s =>
  if st.stop - st.start = 1 then (d1Sem P K w π st.start s.hs).map fun hs => { s with hs := hs }
  else match gpuFamily st.phase (st.stop - st.start) with
    | some T => (rowSem P K weights w π T st.start (st.stop - st.start) s.hs).map fun hs => { s with hs := hs }
    | none => match aneTplOf (st.stop - st.start) with
      | some T => aneStep P K NE IP net weights w π T st.start (st.stop - st.start) s
      | none => none

/-- The GPU tail of a prompt of at most 224 tokens (none for one token). -/
noncomputable def gpuTail (L : Nat) (hs : List Handles) : Option (List Handles) :=
  if L - 1 = 0 then some hs
  else if L - 1 = 1 then d1Sem P K w π 0 hs
  else (gpuFamily .tail (L - 1)).bind fun T => rowSem P K weights w π T 0 (L - 1) hs

/-- **A prompt of at most 224 tokens**: no drain, a GPU tail; the Neural Engine side and the surfaces are not
read. -/
theorem prefill_short {L : Nat} (hL1 : 1 ≤ L) (hL : L ≤ 224) (s0 : RSt) :
    prefillState (routeStep P K NE IP net weights w π) L s0 =
      (gpuTail P K weights w π L s0.hs).map fun hs => { s0 with hs := hs } := by
  rw [prefillState_eq _ hL1 (by omega)]
  have hC : chunkC L = 2048 := by rw [chunkC_eq L (by omega), ite_eq_left (by omega)]
  have hd : drains L = 0 := by unfold drains; rw [hC]; omega
  have ht : tailRows L = L - 1 := by unfold tailRows; rw [hC]; omega
  unfold preFinal afterDrains tailThen gpuTail
  rw [hd]
  simp only [drainsFrom, Option.bind_some]
  by_cases h0 : L - 1 = 0
  · simp only [ht, h0, ↓reduceIte, Option.map_some]
  · simp only [ht, h0, ↓reduceIte, routeStep, tailStep, hd, Nat.zero_mul, Nat.sub_zero]
    by_cases h1 : L - 1 = 1
    · simp only [h1, ↓reduceIte]
    · simp only [h1, ↓reduceIte]
      obtain ⟨T, hT⟩ := Option.isSome_iff_exists.mp (gpuFamily_tail (n := L - 1) .tail (by simp) (by omega))
      rw [hT]
      rfl

end

end Host.Mlx.SimGraph.Ref

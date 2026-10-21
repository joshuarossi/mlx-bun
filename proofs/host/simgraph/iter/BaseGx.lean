import host.simgraph.iter.BaseMisc
import host.simgraph.iter.BaseNodes
import host.simgraph.iter.BaseKernels
import host.simgraph.Base
import host.load.run.full.cached.All
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Load.Run.Full.Cached Host.Load.CachedShapes
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference.Models.Qwen

/-! # The invariant at the first ordinary readback cut

The five-token development's forward results of times `1 … 3` (on its terminal graph,
`P.s3573`) hold on the cut's graph (`P.s3272`): both states have the same nodes below the
cut's counter `22539` and the terminal state's kernel objects are the cut's. With the
time-3 caches at capacity `256` and the cut's one memoized readback (time 1 at `17776`),
the cut satisfies `GI` at iteration `1` under the identity node map. -/

kernel_rfl base_params_below : (parameterTensors parameterChoice).all (fun t => decide (t.node < 22539)) = true
kernel_rfl base_tpl_below : tplCaches.all (fun p => p.1.all (fun j => decide (j < 22539)) &&
  p.2.all (fun j => decide (j < 22539))) = true

/-- The cut's native state. -/
noncomputable abbrev X3 : Ffi.St := (P.s3272.ffi : LSt).mlx
/-- The terminal native state. -/
noncomputable abbrev X5 : Ffi.St := (P.s3573.ffi : LSt).mlx

theorem base_nodes (j : Nat) (hj : j < 22539) : X3.nodes.get j = X5.nodes.get j := by
  have h := congrArg (·[j]?) base_nodes_check
  simp only [List.getElem?_map, List.getElem?_range hj, Option.map_some] at h
  exact Option.some.inj h

theorem base_kernels (k : Nat) (name : List Char) (hk : kernelName? SourceKernels.sources X5 k = some name) :
    kernelName? SourceKernels.sources X3 k = some name := by
  unfold kernelName? at hk ⊢
  cases ho : X5.obj? k with
  | none => rw [ho] at hk; cases hk
  | some o =>
    cases o with
    | kernel nm sc hd a b =>
      have hget : X5.objs.get k = some (.kernel nm sc hd a b) := ho
      have hmem := Sim.Template.PTrie.mem_keys _ k _ hget
      have h := (List.map_eq_map_iff.mp base_kernels_check) k hmem
      simp only [hget, atKernel] at h
      have h3 : X3.obj? k = some (.kernel nm sc hd a b) := h.symm
      rw [ho] at hk
      rw [h3]
      exact hk
    | _ => rw [ho] at hk; cases hk

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

theorem base_eval (tab : List F64) (i : Nat) (hi : i < 22539) (v : Value)
    (h : evalR M K env (terminalGraph tab) i = some v) : evalR M K env (Gr tab X3) i = some v :=
  evalR_extend M K env (concrete (CSrv.val ⟨tab⟩)) SourceKernels.sources X5 X3 i
    (fun j hj => base_nodes j (by omega)) base_kernels v h

theorem cachesBelow_of_B (cs : List Cache) (b : Nat) (h : cachesBelowB cs b = true) : CachesBelow cs b := by
  intro c hc t ht
  have hc' := List.all_eq_true.mp h c hc
  simp only [Bool.and_eq_true] at hc'
  rcases ht with ht | ht
  · rw [ht] at hc'; simpa using hc'.1
  · rw [ht] at hc'; simpa using hc'.2

theorem cacheValues_base (tab : List F64) (cs : List Cache) (hs : List Handles) (hb : cachesBelowB cs 22539 = true)
    (h : CacheValues M K env (terminalGraph tab) cs hs) : CacheValues M K env (Gr tab X3) cs hs := by
  have hbl := cachesBelow_of_B cs 22539 hb
  unfold CacheValues at h ⊢
  induction h with
  | nil => exact .nil
  | @cons c h cs hs hx _ ih =>
    obtain ⟨ta, tb, a, b, h1, h2, h3, h4, h5⟩ := hx
    refine .cons ⟨ta, tb, a, b, h1, h2, h3, base_eval M K env tab _ ?_ _ h4, base_eval M K env tab _ ?_ _ h5⟩
      (ih (cachesBelowB_tail hb) (fun c' hc' t ht => hbl c' (List.mem_cons_of_mem _ hc') t ht))
    · exact hbl c List.mem_cons_self ta (.inl h1)
    · exact hbl c List.mem_cons_self tb (.inr h2)
where
  cachesBelowB_tail {c : Cache} {cs : List Cache} (h : cachesBelowB (c :: cs) 22539 = true) :
      cachesBelowB cs 22539 = true := by
    simp only [cachesBelowB, List.all_cons, Bool.and_eq_true] at h ⊢
    exact h.2

/-- Cache values depend only on the caches' tensor nodes. -/
theorem cacheValues_at (G : Nat → Option (RNode Int InKey)) (cs : List Cache) (hs : List Handles)
    (h : CacheValues M K env G cs hs) : CacheValues M K env G (cachesAt (fun j => j) (cs.map cacheNodePair)) hs := by
  unfold CacheValues at h ⊢
  induction h with
  | nil => exact .nil
  | @cons c h cs hs hx _ ih =>
    obtain ⟨ta, tb, a, b, h1, h2, h3, h4, h5⟩ := hx
    refine .cons ⟨tensorAt ta.node, tensorAt tb.node, a, b, ?_, ?_, h3, h4, h5⟩ ih
    · simp [cacheAt, cacheNodePair, h1]
    · simp [cacheAt, cacheNodePair, h2]

theorem base_forward (tab : List F64)
    (hp : TokenSequenceRanges.Parameters (firstPipeline M K env tab leaves typed)) (time : Nat)
    (supported : time ≤ 262144) (cs : List Cache) (out : Nat)
    (h : ForwardResult M K env tab leaves typed hp time supported cs out) (hout : out < 22539)
    (hcs : cachesBelowB cs 22539 = true) :
    ForwardAt M K env tab leaves typed hp time supported cs out (Gr tab X3) := by
  obtain ⟨hs, ⟨r, hr, hi⟩, hh, hc⟩ := h
  exact ⟨hs, ⟨r, base_eval M K env tab out hout r hr, hi⟩, hh, cacheValues_base M K env tab cs hs hcs hc⟩

/-- The time-3 caches are at capacity 256. -/
theorem caps_third (tab : List F64) (hp : TokenSequenceRanges.Parameters (firstPipeline M K env tab leaves typed))
    (hs : List Handles)
    (chain : ChainHolds (firstPipeline M K env tab leaves typed).graph.stages hs
      ((firstContext M K env tab leaves typed hp).run promptToken 3 (by decide)).cache)
    (caches : CacheValues M K env (terminalGraph tab) after3.cache hs) :
    CapsFor 256 (stageWeights (weights (firstValues M K env tab))) hs := by
  have compatible := cacheCompatible_of_holds M K _ _ hs _
    (stages_loaded M K _ _ (firstPipeline_loaded M K env tab leaves typed)) chain
  have shapes := caches_sound M K env (terminalGraph tab) .bfloat16 [1,4,256,256] 6 after3.cache
    (cache_shapes_checked3 tab)
  exact capsFor_of_values M K env (terminalGraph tab) 256 _ _ hs caches compatible
    (cache_classes3 (contents M K env (firstFfiGraph tab)))
    (fun cc hc hop t ht v hv => (shapes cc hc hop t ht v hv).2)

/-- **The invariant at the cut**, at every table extending the cut's server at `ρ`, given
that `ρ` gives the first token its value. -/
theorem gi_base (ρ : Nat → F64) (tk : Nat → Nat)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hρ1 : ρ 1 = F64.ofNat (tk 1)) (tab : List F64)
    (hle : Sim.CSrv.Le ⟨P.S3272.tab.map (SymE.eval ρ)⟩ ⟨tab⟩) :
    GI M K env leaves typed parameters tplInputs tab 1 (fun j => j) X3 := by
  have hn : X3.nnext = 22539 := base_nnext
  obtain ⟨one, two, three, -, -⟩ := terminal_all_five M K env tab leaves typed (hpOf M K env leaves typed parameters tab)
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · intro k h1 h2 hb
    rw [hn]
    rcases (by omega : k = 1 ∨ k = 2 ∨ k = 3) with rfl | rfl | rfl
    · exact ⟨_, _, base_forward M K env leaves typed tab _ _ _ _ _ one (by decide) base_below1, by decide,
        cachesBelow_of_B _ _ base_below1⟩
    · exact ⟨_, _, base_forward M K env leaves typed tab _ _ _ _ _ two (by decide) base_below2, by decide,
        cachesBelow_of_B _ _ base_below2⟩
    · exact ⟨_, _, base_forward M K env leaves typed tab _ _ _ _ _ three (by decide) base_below3, by decide,
        cachesBelow_of_B _ _ base_below3⟩
  · intro hb
    rw [hn]
    exact ⟨_, base_forward M K env leaves typed tab _ _ _ _ _ two (by decide) base_below2, by decide,
      cachesBelow_of_B _ _ base_below2⟩
  · intro hb
    rw [hn]
    obtain ⟨hs, ⟨r, hr, hi⟩, hh, hc⟩ := three
    have hcv := cacheValues_at M K env _ _ hs (cacheValues_base M K env tab _ hs base_below3 hc)
    rw [base_caches] at hcv
    refine ⟨hs, ⟨r, base_eval M K env tab _ (by decide) r hr, hi⟩, hh, hcv,
      caps_third M K env leaves typed tab _ hs hh hc, by decide, ?_⟩
    apply cachesAt_below
    intro p hp j hj
    have := List.all_eq_true.mp base_tpl_below p hp
    simp only [Bool.and_eq_true] at this
    rcases hj with hj | hj
    · rw [hj] at this; simpa using this.1
    · rw [hj] at this; simpa using this.2
  · intro t ht
    have hlt : t.node < 22539 := by simpa using List.all_eq_true.mp base_params_below t ht
    exact ⟨base_eval M K env tab _ hlt _ (terminal_parameter_value M K env tab leaves t ht), by rw [hn]; exact hlt⟩
  · rw [hn, base_items]
    refine ⟨?_, ?_⟩
    · obtain ⟨_, ⟨r, hr, hi⟩, _, _⟩ := one
      refine ReadbackValues.set M K env _ _ (ReadbackValues.empty M K env _ _) 17776 (.ref 1) _ (by decide) ?_
        ⟨⟨r, base_eval M K env tab _ (by decide) r hr, hi⟩, ?_⟩
      · have := ((firstContext M K env tab leaves typed (hpOf M K env leaves typed parameters tab)).run
          promptToken 1 (by decide)).token.isLt
        omega
      · have h0 : CSrv.val ⟨P.S3272.tab.map (SymE.eval ρ)⟩ (.ref 1) = some (ρ 1) := by
          show nth? (P.S3272.tab.map (SymE.eval ρ)) 1 = _
          rw [nth?_map, base_ref1]
          rfl
        rw [hle.val h0, hρ1, htk 1 (by decide), recurrence_token_table_eq M K env [] tab leaves typed parameters
          (hpOf M K env leaves typed parameters tab) 1 (by decide)]
    · intro k hk
      rw [PTrie.get_set_u64 _ _ _ (by decide)]
      have : k ≠ 17776 := by omega
      simp only [this, ↓reduceIte]
      simp [PTrie.get, PTrie.nil, Trie.get]

theorem gr_congr (tab : List F64) {x x' : Ffi.St} (hn : x'.nodes = x.nodes) (ho : x'.objs = x.objs) :
    Gr tab x' = Gr tab x := by
  have hk : kernelName? SourceKernels.sources x' = kernelName? SourceKernels.sources x := by
    funext h
    unfold kernelName? Ffi.St.obj?
    rw [ho]
  funext i
  show (x'.nodes.get i).bind (resolveNode _ (kernelName? SourceKernels.sources x')) =
    (x.nodes.get i).bind (resolveNode _ (kernelName? SourceKernels.sources x))
  rw [hn, hk]

/-- `GI` reads a native state only through its nodes, objects, node counter and items. -/
theorem gi_congr (I : TplInputs) (tab : List F64) (i : Nat) (σ : Nat → Nat) {x x' : Ffi.St}
    (hn : x'.nodes = x.nodes) (ho : x'.objs = x.objs) (hnn : x'.nnext = x.nnext) (hi : x'.items = x.items)
    (h : GI M K env leaves typed parameters I tab i σ x) : GI M K env leaves typed parameters I tab i σ x' := by
  have hg := gr_congr tab hn ho
  obtain ⟨h1, h2, h3, h4, h5⟩ := h
  exact ⟨by rw [hg, hnn]; exact h1, by rw [hg, hnn]; exact h2, by rw [hg, hnn]; exact h3,
    by rw [hg, hnn]; exact h4, by rw [hg, hnn, hi]; exact h5⟩

/-- **The base of the loop's graph invariant**: `Gx` at iteration `1` for any target state
with the cut's nodes, objects, node counter and items, under a node map fixing every node. -/
theorem gx_base (Mp : Sim.Map) (hM : ∀ j, Mp.node j = j) (t : St LSt) (hn : t.ffi.mlx.nodes = X3.nodes)
    (ho : t.ffi.mlx.objs = X3.objs) (hnn : t.ffi.mlx.nnext = X3.nnext) (hi : t.ffi.mlx.items = X3.items)
    (ρ : Nat → F64) (tk : Nat → Nat)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hρ1 : ρ 1 = F64.ofNat (tk 1)) :
    Gx M K env leaves typed parameters tplInputs 1 Mp t ⟨P.S3272.tab.map (SymE.eval ρ)⟩ := by
  intro tab hle
  have hσ : Mp.node = fun j => j := funext hM
  rw [hσ]
  exact gi_congr M K env leaves typed parameters _ _ _ _ hn ho hnn hi
    (gi_base M K env leaves typed parameters ρ tk htk hρ1 tab hle)

end Host.Mlx.SimGraph.Iter

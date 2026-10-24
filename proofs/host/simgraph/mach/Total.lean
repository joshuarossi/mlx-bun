import host.simgraph.mach.TotalStep
import host.simgraph.mach.Ref
set_option maxRecDepth 1000000
namespace Host.Mlx.SimGraph.Mach
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.GlueLayers Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Ref (prefillAt prefill_short gpuTail d1Sem RSt AneNet routeStep drainStep tailStep drainsFrom
  tailThen preFinal afterDrains prefillState_eq)
open Host.Ts.Sim.Prefill (PStep chunkC drains tailRows drains_tail)

/-! # The machine reference is defined along the route

Under the GPU assumption (`K.apply` is MLX's launch run by `G`, as in the route's contract
`KernelGpuPrefill.ofGpuRoute G B P …`) the decode step is defined on typed handles, keeps them typed and emits a
vocabulary index (`stepTrace_ty`), so the machine reference `refPrompt π` is defined at every time from `L - 1` on
as soon as the prefill is defined with typed handles (`PrefillTyped π`). That premise is proved here for `L ≤ 2`
(`prefillTyped_short`: no prefill step, or one D1 drain of the first token), and for every `L` it reduces to the
schedule's multi-row steps keeping the prefill's handles typed (`ScheduleTyped π`, on `StagePre`: KV buffers at
the prefill's capacity `capL`; `prefillTyped_of_schedule`; one-row steps are D1 drains, `routeStep_oneK`). The
multi-row steps (GPU row families of 2–223 rows, Neural Engine buckets of 224–2048) are `scheduleTyped`
(Schedule.lean), under the Neural Engine's success on the loaded programs and the loaded model's Neural Engine side.

* `machFrom_ty`: every step of the decode trace is defined, its handles typed.
* `initial_ty`, `initial_caps`: the empty caches are typed; one decode step from them populates every cache
  at capacity 256.
* `capL`, `KvPre`, `StagePre`, `kvPre_steps`, `initial_pre`: the prefill's caches.
* `PrefillTyped`, `prefillTyped_short`, `routeStep_one`, `ScheduleTyped`, `prefillTyped_of_schedule`.
* `refPrompt_defined`, `refPrompt_caps`: the reference is defined at every `t ≥ L - 1`, with typed handles,
  and from `max (L - 1) 1` on at a uniform capacity.
* `RefTokens`, `refPrompt_tokens_total`, `refPrompt_tokens_short`: `refPrompt_tokens` without its definedness,
  shape and token-bound premises. -/

variable {C : M1Max.Contract}

/-! ## The decode trace from typed handles -/

section
variable (M : MlxContract C) (K : KernelContract C) {G : Metal.Gpu C} (RP : Host.Mlx.KernelGpu.RoutePipelines G)
  (hK : K.apply = Host.Mlx.KernelGpu.apply G)
include RP hK

theorem machFrom_ty {w : PipelineWeights} (hw : PipeTy w) (t0 : Nat) (s0 : Nat × List Handles)
    (h0 : List.Forall₂ (HandleTy t0) (stageWeights w) s0.2) :
    ∀ k, ∃ s, machFrom M K w t0 s0 k = some s ∧ List.Forall₂ (HandleTy (t0 + k)) (stageWeights w) s.2
  | 0 => ⟨s0, rfl, h0⟩
  | k + 1 => by
    obtain ⟨s, e, hs⟩ := machFrom_ty hw t0 s0 h0 k
    obtain ⟨tok, hs', e', hh', -⟩ := stepTrace_ty M K RP hK hw s.1 hs
    exact ⟨(tok, hs'), by rw [machFrom, e]; exact e', hh'⟩

end

/-! ## The empty caches -/

theorem initial_ty (w : PipelineWeights) : List.Forall₂ (HandleTy 0) (stageWeights w) initialHandles := by
  have hd : ∀ x : DeltaWeights, HandleTy 0 (.delta x) (.delta none none) := fun _ =>
    ⟨fun _ h => (nomatch h), fun _ h => (nomatch h)⟩
  have ha : ∀ x : AttentionWeights, HandleTy 0 (.attention x) (.attention none none) := fun _ => ⟨rfl, rfl⟩
  repeat (first | exact List.Forall₂.nil | refine List.Forall₂.cons (hd _) ?_ | refine List.Forall₂.cons (ha _) ?_)

theorem kvStep_cap_none {k b view : Value} {n : Nat} (h : GlueKv.step none n k = some (b, view)) :
    b.shape = [1, 4, 256, 256] := by
  unfold GlueKv.step at h
  simp only [Option.bind_eq_bind, Option.bind_some] at h
  obtain ⟨b2, e2, h⟩ := Option.bind_eq_some_iff.mp h
  obtain ⟨v3, _, h⟩ := Option.bind_eq_some_iff.mp h
  have hr : (b2, v3) = (b, view) := Option.some.inj h
  cases hr
  rw [sliceUpdateRange_shape e2]
  rfl

/-! ## The prefill's caches -/

/-- The prefill's capacity at offset `o`. -/
def capL (o : Nat) : Nat := 256 * ((o + 255) / 256)

/-- A KV buffer during the prefill: none at offset 0, else at capacity `capL o`. -/
def KvPre (o : Nat) : Option Value → Prop
  | none => o = 0
  | some b => 0 < o ∧ Ty b .bfloat16 [1, 4, capL o, 256]

/-- A stage's handles during the prefill. -/
abbrev StagePre (o : Nat) : StageWeights → Handles → Prop := HandleTyK KvPre o

theorem KvPre.at {o : Nat} {b : Option Value} (h : KvPre o b) : KvAt o b := by
  cases b with
  | none => exact h
  | some v => exact ⟨capL o, by unfold capL; omega, h.2, by unfold capL; omega⟩

theorem StagePre.handleTy {o : Nat} {s : StageWeights} {h : Handles} (hp : StagePre o s h) : HandleTy o s h := by
  cases s <;> cases h
  · exact hp
  · exact hp.elim
  · exact hp.elim
  · exact ⟨hp.1.at, hp.2.at⟩

theorem stagePre_handleTy {o : Nat} {ws : List StageWeights} {hs : List Handles}
    (h : List.Forall₂ (StagePre o) ws hs) : List.Forall₂ (HandleTy o) ws hs :=
  h.imp fun _ _ hp => hp.handleTy

theorem kvCap_capL (n : Nat) : kvCap (some (capL n)) n = capL (n + 1) := by
  simp only [kvCap]
  by_cases h : capL n < n + 1
  · rw [ite_eq_left h]
    by_cases h2 : n % 256 = 0
    · rw [ite_eq_left h2]; unfold capL at *; omega
    · rw [ite_eq_right h2]; unfold capL at *; omega
  · rw [ite_eq_right h]; unfold capL at *; omega

/-- **The prefill's KV buffers step with the decode's one-row append.** -/
theorem kvPre_steps : KvSteps KvPre := by
  intro n b k hb hk
  obtain ⟨b', v, e, ⟨cap, _, hty, _⟩, hv⟩ := kvStep_ty hb.at hk
  refine ⟨b', v, e, ⟨by omega, hty.1, ?_⟩, hv⟩
  cases b with
  | none =>
    have h0 : n = 0 := hb
    subst h0
    rw [kvStep_cap_none e]; rfl
  | some b0 =>
    rw [kvStep_cap b0 k b' v (capL n) n hb.2.2 e, kvCap_capL]

theorem initial_pre (w : PipelineWeights) : List.Forall₂ (StagePre 0) (stageWeights w) initialHandles := by
  have hd : ∀ x : DeltaWeights, StagePre 0 (.delta x) (.delta none none) := fun _ =>
    ⟨fun _ h => (nomatch h), fun _ h => (nomatch h)⟩
  have ha : ∀ x : AttentionWeights, StagePre 0 (.attention x) (.attention none none) := fun _ => ⟨rfl, rfl⟩
  repeat (first | exact List.Forall₂.nil | refine List.Forall₂.cons (hd _) ?_ | refine List.Forall₂.cons (ha _) ?_)

/-- The stage caches before any step. -/
def StageInit : StageWeights → Handles → Prop
  | .delta _, .delta none none => True
  | .attention _, .attention none none => True
  | _, _ => False

section
variable (M : MlxContract C) (K : KernelContract C)

theorem stageTrace_cap_init (w : StageWeights) (h : Handles) (hc : StageInit w h) (x y : Value) (h' : Handles)
    (e : stageTrace M K 0 w h x = some (y, h')) : StageCap 256 w h' := by
  cases w with
  | delta w =>
    match h, hc with
    | .delta none none, _ =>
      simp only [stageTrace, Option.map_eq_some_iff] at e
      obtain ⟨_, _, he⟩ := e
      simp only [Prod.mk.injEq] at he
      rw [← he.2]
      trivial
  | attention w =>
    match h, hc with
    | .attention none none, _ =>
      simp only [stageTrace, Option.map_eq_some_iff] at e
      obtain ⟨⟨out, ka, vb'⟩, e, he⟩ := e
      simp only [Prod.mk.injEq] at he
      rw [← he.2]
      obtain ⟨⟨k, _, hk⟩, ⟨v, _, hv⟩⟩ := attentionLayerTrace_steps M K w _ _ 0 x out ka vb' e
      exact ⟨kvStep_cap_none hk, kvStep_cap_none hv⟩

theorem chainTrace_caps_init (ws : List StageWeights) (hs : List Handles) (hc : List.Forall₂ StageInit ws hs) :
    ∀ (x y : Value) (hs' : List Handles), chainTrace M K 0 ws hs x = some (y, hs') → CapsFor 256 ws hs' := by
  induction hc with
  | nil =>
    intro x y hs' e
    simp only [chainTrace, Option.some.injEq, Prod.mk.injEq] at e
    rw [← e.2]
    exact .nil
  | @cons w h ws hs hc rest ih =>
    intro x y hs' e
    simp only [chainTrace] at e
    obtain ⟨r, e1, e⟩ := Option.bind_eq_some_iff.mp e
    obtain ⟨t, e2, e⟩ := Option.bind_eq_some_iff.mp e
    have hr : (t.1, r.2 :: t.2) = (y, hs') := Option.some.inj e
    cases hr
    exact .cons (stageTrace_cap_init M K w h hc x r.1 r.2 e1) (ih r.1 t.1 t.2 e2)

theorem initial_init (w : PipelineWeights) : List.Forall₂ StageInit (stageWeights w) initialHandles := by
  repeat (first | exact List.Forall₂.nil | refine List.Forall₂.cons trivial ?_)

/-- **One decode step from the empty caches populates every cache at capacity 256.** -/
theorem initial_caps (w : PipelineWeights) (token : Nat) (hs' : List Handles) (t : Nat)
    (e : stepTrace M K w 0 token initialHandles = some (t, hs')) : CapsFor 256 (stageWeights w) hs' := by
  unfold stepTrace at e
  obtain ⟨x, _, e⟩ := Option.bind_eq_some_iff.mp e
  obtain ⟨r2, e2, e⟩ := Option.bind_eq_some_iff.mp e
  obtain ⟨y, hs2⟩ := r2
  dsimp only at e
  obtain ⟨_, _, e⟩ := Option.bind_eq_some_iff.mp e
  obtain ⟨_, _, e⟩ := Option.bind_eq_some_iff.mp e
  obtain ⟨_, _, e⟩ := Option.bind_eq_some_iff.mp e
  obtain ⟨_, _, e⟩ := Option.bind_eq_some_iff.mp e
  split at e
  · obtain ⟨t7, _, e⟩ := Option.bind_eq_some_iff.mp e
    have hr : (t7, hs2) = (t, hs') := Option.some.inj e
    rw [← (Prod.mk.inj hr).2]
    exact chainTrace_caps_init M K _ _ (initial_init w) x y hs2 e2
  · cases e

end

/-! ## The prompt's reference -/

section
variable (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine) (IP : InPlace) (net : AneNet)
  (env : FfiEval.Env InKey) (π : List Nat)

/-- **The prefill is defined with typed handles** at every table: the premise of the reference's definedness.
Proved for `L ≤ 2` (`prefillTyped_short`). -/
def PrefillTyped : Prop :=
  ∀ tab, ∃ s, prefillAt P KR NE IP net env π tab = some s ∧
    List.Forall₂ (HandleTy (π.length - 1)) (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)))
      s.hs

variable {G : Metal.Gpu C} (RP : Host.Mlx.KernelGpu.RoutePipelines G) (hK : KR.toKernelContract.apply = Host.Mlx.KernelGpu.apply G)
  (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)

/-- At one token the prefill is empty: the empty caches. -/
theorem prefill_one (hL : π.length = 1) (tab : List F64) :
    ∃ s, prefillAt P KR NE IP net env π tab = some s ∧ s.hs = initialHandles := by
  unfold prefillAt
  rw [prefill_short P KR NE IP net env.weights _ π (by omega) (by omega)]
  unfold gpuTail
  dsimp only
  rw [ite_eq_left (by omega), Option.map_some]
  exact ⟨_, rfl, rfl⟩

include RP hK leaves typed in
/-- **At two tokens the prefill is one D1 drain** of the first token from the empty caches: defined, its handles
typed at offset 1 and every cache populated at capacity 256. -/
theorem prefill_two (hL : π.length = 2) (tab : List F64) :
    ∃ s, prefillAt P KR NE IP net env π tab = some s ∧
      List.Forall₂ (HandleTy 1) (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs ∧
      CapsFor 256 (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs := by
  have hw := pipeTy_of_loaded P.toMlxContract KR.toKernelContract
    (firstPipeline_loaded P.toMlxContract KR.toKernelContract env tab leaves typed)
  obtain ⟨x, e1, t1⟩ := embed_ty P.toMlxContract hw (π.getD 0 0)
  obtain ⟨y, hs', e2, _, hh⟩ := chain_ty P.toMlxContract KR.toKernelContract RP hK KvAt kvAt_steps _ initialHandles hw.stages
    (initial_ty _) x t1
  have hd : d1Sem P KR (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) π 0 initialHandles =
      some hs' := by
    unfold d1Sem
    rw [e1]; dsimp only [bind, Option.bind]
    rw [e2]; rfl
  unfold prefillAt
  rw [prefill_short P KR NE IP net env.weights _ π (by omega) (by omega)]
  unfold gpuTail
  dsimp only
  rw [ite_eq_right (by omega), ite_eq_left (by omega), hd, Option.map_some]
  exact ⟨_, rfl, hh, chainTrace_caps_init P.toMlxContract KR.toKernelContract _ _ (initial_init _) x y hs' e2⟩

include RP hK leaves typed in
/-- **At one or two tokens the prefill is defined with typed handles.** -/
theorem prefillTyped_short (hL1 : 1 ≤ π.length) (hL2 : π.length ≤ 2) : PrefillTyped P KR NE IP net env π := by
  intro tab
  by_cases h1 : π.length = 1
  · obtain ⟨s, e, hs⟩ := prefill_one P KR NE IP net env π h1 tab
    exact ⟨s, e, by rw [hs, h1]; exact initial_ty _⟩
  · obtain ⟨s, e, hh, _⟩ := prefill_two P KR NE IP net env π RP hK leaves typed (by omega) tab
    exact ⟨s, e, by rw [show π.length - 1 = 1 by omega]; exact hh⟩

include RP hK leaves typed in
/-- **A one-row step (a D1 drain) keeps the handles typed**, at any offset, for KV buffers typed by any `KV` the
one-row append steps. -/
theorem routeStep_oneK (KV : Nat → Option Value → Prop) (hkv : KvSteps KV) (tab : List F64) (st : PStep) (s : RSt)
    (h1 : st.stop - st.start = 1)
    (hh : List.Forall₂ (HandleTyK KV st.start)
      (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs) :
    ∃ s', routeStep P KR NE IP net env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) π st s =
        some s' ∧
      List.Forall₂ (HandleTyK KV (st.start + 1))
        (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s'.hs := by
  have hw := pipeTy_of_loaded P.toMlxContract KR.toKernelContract
    (firstPipeline_loaded P.toMlxContract KR.toKernelContract env tab leaves typed)
  obtain ⟨x, e1, t1⟩ := embed_ty P.toMlxContract hw (π.getD st.start 0)
  obtain ⟨y, hs', e2, _, hh'⟩ := chain_ty P.toMlxContract KR.toKernelContract RP hK KV hkv _ s.hs hw.stages hh x t1
  have hd : d1Sem P KR (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) π st.start s.hs =
      some hs' := by
    unfold d1Sem
    rw [e1]; dsimp only [bind, Option.bind]
    rw [e2]; rfl
  unfold routeStep
  rw [ite_eq_left h1, hd, Option.map_some]
  exact ⟨_, rfl, hh'⟩

include RP hK leaves typed in
/-- **A one-row step (a D1 drain) keeps the handles typed**, at any offset. -/
theorem routeStep_one (tab : List F64) (st : PStep) (s : RSt) (h1 : st.stop - st.start = 1)
    (hh : List.Forall₂ (HandleTy st.start)
      (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs) :
    ∃ s', routeStep P KR NE IP net env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) π st s =
        some s' ∧
      List.Forall₂ (HandleTy (st.start + 1))
        (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s'.hs :=
  routeStep_oneK P KR NE IP net env π RP hK leaves typed KvAt kvAt_steps tab st s h1 hh

/-- **The prefill schedule's multi-row steps keep the prefill's handles typed** (`StagePre`: KV buffers at the
prefill's capacity): each whole chunk, and the tail when it has two rows or more. The forward families'
definedness; `PrefillTyped` reduces to it (`prefillTyped_of_schedule`). -/
def ScheduleTyped : Prop :=
  ∀ tab, (∀ j < drains π.length, ∀ s : RSt,
      List.Forall₂ (StagePre (j * chunkC π.length))
        (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs →
      ∃ s', routeStep P KR NE IP net env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) π
          (drainStep (chunkC π.length) j) s = some s' ∧
        List.Forall₂ (StagePre ((j + 1) * chunkC π.length))
          (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s'.hs) ∧
    (2 ≤ tailRows π.length → ∀ s : RSt,
      List.Forall₂ (StagePre (drains π.length * chunkC π.length))
        (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs →
      ∃ s', routeStep P KR NE IP net env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) π
          (tailStep π.length) s = some s' ∧
        List.Forall₂ (StagePre (π.length - 1))
          (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s'.hs)

theorem drains_ty (tab : List F64)
    (hd : ∀ j < drains π.length, ∀ s : RSt,
      List.Forall₂ (StagePre (j * chunkC π.length))
        (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs →
      ∃ s', routeStep P KR NE IP net env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) π
          (drainStep (chunkC π.length) j) s = some s' ∧
        List.Forall₂ (StagePre ((j + 1) * chunkC π.length))
          (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s'.hs) :
    ∀ m j (s : RSt), j + m ≤ drains π.length →
      List.Forall₂ (StagePre (j * chunkC π.length))
        (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs →
      ∃ s', drainsFrom (routeStep P KR NE IP net env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) π)
          (chunkC π.length) j m s = some s' ∧
        List.Forall₂ (StagePre ((j + m) * chunkC π.length))
          (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s'.hs
  | 0, j, s, _, h => ⟨s, rfl, by rw [Nat.add_zero]; exact h⟩
  | m + 1, j, s, hm, h => by
    obtain ⟨s1, e1, h1⟩ := hd j (by omega) s h
    obtain ⟨s2, e2, h2⟩ := drains_ty tab hd m (j + 1) s1 (by omega) h1
    refine ⟨s2, ?_, by rw [show j + (m + 1) = j + 1 + m by omega]; exact h2⟩
    show (routeStep P KR NE IP net env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) π
      (drainStep (chunkC π.length) j) s).bind _ = _
    rw [e1, Option.bind_some]
    exact e2

include RP hK leaves typed in
/-- **The prefill is defined with typed handles once its schedule's multi-row steps are**: the drains from the empty
caches, then the tail (none, a D1 drain, or a multi-row step). -/
theorem prefillTyped_of_schedule (hL1 : 1 ≤ π.length) (hL2 : π.length ≤ 349525) (h : ScheduleTyped P KR NE IP net env π) :
    PrefillTyped P KR NE IP net env π := by
  intro tab
  obtain ⟨hd, ht⟩ := h tab
  obtain ⟨s1, e1, h1⟩ := drains_ty P KR NE IP net env π tab hd (drains π.length) 0 ⟨initialHandles, net.surfaces, []⟩
    (by omega) (by rw [Nat.zero_mul]; exact initial_pre _)
  rw [Nat.zero_add] at h1
  have hdt := drains_tail π.length
  unfold prefillAt
  rw [prefillState_eq _ hL1 hL2]
  unfold preFinal afterDrains
  rw [e1, Option.bind_some]
  unfold tailThen
  by_cases h0 : tailRows π.length = 0
  · rw [ite_eq_left h0]
    exact ⟨s1, rfl, stagePre_handleTy (by rw [show π.length - 1 = drains π.length * chunkC π.length by omega]; exact h1)⟩
  · rw [ite_eq_right h0]
    by_cases hr1 : tailRows π.length = 1
    · obtain ⟨s2, e2, h2⟩ := routeStep_oneK P KR NE IP net env π RP hK leaves typed KvPre kvPre_steps tab
        (tailStep π.length) s1 (by show π.length - 1 - drains π.length * chunkC π.length = 1; omega) h1
      refine ⟨s2, e2, stagePre_handleTy ?_⟩
      rw [show π.length - 1 = (tailStep π.length).start + 1 by
        show _ = drains π.length * chunkC π.length + 1; omega]
      exact h2
    · obtain ⟨s2, e2, h2⟩ := ht (by omega) s1 h1
      exact ⟨s2, e2, stagePre_handleTy h2⟩

include RP hK leaves typed in
/-- **The reference is defined at every time from `L - 1` on**, with typed handles, once the prefill is. -/
theorem refPrompt_defined (hpre : PrefillTyped P KR NE IP net env π) (tab : List F64) (t : Nat)
    (ht : π.length - 1 ≤ t) :
    ∃ tok hs, refPrompt P KR NE IP net env π tab t = some (tok, hs) ∧
      List.Forall₂ (HandleTy t) (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) hs := by
  have hw := pipeTy_of_loaded P.toMlxContract KR.toKernelContract
    (firstPipeline_loaded P.toMlxContract KR.toKernelContract env tab leaves typed)
  obtain ⟨s, hs, hh⟩ := hpre tab
  obtain ⟨s', e, hh'⟩ := machFrom_ty P.toMlxContract KR.toKernelContract RP hK hw (π.length - 1)
    (π.getD (π.length - 1) 0, s.hs) hh (t - (π.length - 1))
  refine ⟨s'.1, s'.2, ?_, by rw [show π.length - 1 + (t - (π.length - 1)) = t by omega] at hh'; exact hh'⟩
  unfold refPrompt
  rw [ite_eq_left ht, hs, Option.bind_some, e]

/-- **The reference's token sequence at table `tab`**: at `L - 1` the prompt's last token and the prefill's
handles; at every `t ≥ L - 1` the reference is defined at `t` and `t + 1`, its handles at `t` have the route's
shapes, the token at `t + 1` is a vocabulary index, and step `t`'s D1 family graph (`stepGraphOf`, the graph the
route builds) evaluated at the step's inputs (the token's ids, the loaded weights, the handles) has at its output
node (the normalized argmax of the lm head's logits) the token at `t + 1` and at its cache nodes the handles
at `t + 1`. -/
def RefTokens (tab : List F64) : Prop :=
  refPrompt P KR NE IP net env π tab (π.length - 1) =
      (prefillAt P KR NE IP net env π tab).map (fun s => (π.getD (π.length - 1) 0, s.hs)) ∧
    ∀ t, π.length - 1 ≤ t → ∃ tok hs tok' hs', refPrompt P KR NE IP net env π tab t = some (tok, hs) ∧
      refPrompt P KR NE IP net env π tab (t + 1) = some (tok', hs') ∧ tok' < 248320 ∧
      ShapesOk (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) hs ∧
      (∃ r, evalR P.toMlxContract KR.toKernelContract
          (stepEnvWithIds env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) (tokenIds tok) hs)
          (listGraph (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs t).1)
          (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs t).2.1 = some r ∧
        itemUint32 r = some tok') ∧
      ∀ q ∈ cacheFacts (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs t).2.2 hs',
        evalR P.toMlxContract KR.toKernelContract
          (stepEnvWithIds env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) (tokenIds tok) hs)
          (listGraph (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs t).1) q.1 =
          some q.2

include RP hK leaves typed in
/-- **The token sequence of the prompt's reference at the machine level, unconditionally along the route**
(`refPrompt_tokens` without its definedness, shape and token-bound premises): under the GPU assumption, on the
loaded checkpoint, once the prefill is defined with typed handles (`PrefillTyped`, proved for `L ≤ 2`). -/
theorem refPrompt_tokens_total (hpre : PrefillTyped P KR NE IP net env π) (tab : List F64) :
    RefTokens P KR NE IP net env π tab := by
  unfold RefTokens
  refine ⟨refPrompt_start P KR NE IP net env π tab, fun t ht => ?_⟩
  have hl := firstPipeline_loaded P.toMlxContract KR.toKernelContract env tab leaves typed
  have hw := pipeTy_of_loaded P.toMlxContract KR.toKernelContract hl
  obtain ⟨tok, hs, h0, hh⟩ := refPrompt_defined P KR NE IP net env π RP hK leaves typed hpre tab t ht
  have hsh := shapesOk_of_ty _ hs hw.stages hh
  obtain ⟨tok', hs', e, _, hlt⟩ := stepTrace_ty P.toMlxContract KR.toKernelContract RP hK hw tok hh
  have h1 : refPrompt P KR NE IP net env π tab (t + 1) = some (tok', hs') := by
    rw [refPrompt_succ P KR NE IP net env π tab t ht, h0]
    exact e
  obtain ⟨⟨r, _, hr, hi⟩, _, _, hc⟩ := stepGraph_eval_ids P.toMlxContract KR.toKernelContract env.weights _ t tok
    (tokenIds tok) rfl hs hs' tok' hl.finalNorm.2.1 hsh e
  exact ⟨tok, hs, tok', hs', h0, h1, hlt, hsh, ⟨r, hr, hi⟩, fun q hq => (hc q hq).2⟩

include RP hK leaves typed in
/-- **Uniform capacities along the reference**: from `max (L - 1) 1` on, once they hold at the start (the prefill's
handles at `L - 1 ≥ 1`, or the first decode step's at `L = 1`). -/
theorem refPrompt_caps (hpre : PrefillTyped P KR NE IP net env π) (tab : List F64) (t0 c : Nat) (hs0 : List Handles)
    (ht0 : π.length - 1 ≤ t0) (h0 : ∃ tok, refPrompt P KR NE IP net env π tab t0 = some (tok, hs0))
    (hc : CapsFor c (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) hs0) :
    ∀ k, ∃ tok hs c', refPrompt P KR NE IP net env π tab (t0 + k) = some (tok, hs) ∧
      CapsFor c' (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) hs
  | 0 => by
    obtain ⟨tok, e⟩ := h0
    exact ⟨tok, hs0, c, e, hc⟩
  | k + 1 => by
    obtain ⟨tok, hs, c', e, hc'⟩ := refPrompt_caps hpre tab t0 c hs0 ht0 h0 hc k
    obtain ⟨tok', hs', e', _⟩ := refPrompt_defined P KR NE IP net env π RP hK leaves typed hpre tab (t0 + k + 1)
      (by omega)
    have hstep := refPrompt_succ P KR NE IP net env π tab (t0 + k) (by omega)
    rw [e', e, Option.bind_some] at hstep
    exact ⟨tok', hs', _, e', capsFor_step P.toMlxContract KR.toKernelContract _ (t0 + k) tok hs hs' tok' c' hc'
      hstep.symm⟩


include RP hK leaves typed in
/-- **At one or two tokens the token sequence holds with no premise beyond the GPU assumption and the
checkpoint.** -/
theorem refPrompt_tokens_short (hL1 : 1 ≤ π.length) (hL2 : π.length ≤ 2) (tab : List F64) :
    RefTokens P KR NE IP net env π tab :=
  refPrompt_tokens_total P KR NE IP net env π RP hK leaves typed
    (prefillTyped_short P KR NE IP net env π RP hK leaves typed hL1 hL2) tab

include RP hK leaves typed in
/-- **At one or two tokens the caches are at a uniform capacity from time 1 on** (the prefill's handles at
`L = 2`; the first decode step's at `L = 1`, whose handles at time 0 are the empty caches). -/
theorem refPrompt_caps_short (hL1 : 1 ≤ π.length) (hL2 : π.length ≤ 2) (tab : List F64) (k : Nat) :
    ∃ tok hs c, refPrompt P KR NE IP net env π tab (1 + k) = some (tok, hs) ∧
      CapsFor c (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) hs := by
  have hpre := prefillTyped_short P KR NE IP net env π RP hK leaves typed hL1 hL2
  by_cases h1 : π.length = 1
  · have hw := pipeTy_of_loaded P.toMlxContract KR.toKernelContract
      (firstPipeline_loaded P.toMlxContract KR.toKernelContract env tab leaves typed)
    obtain ⟨s, e, hs⟩ := prefill_one P KR NE IP net env π h1 tab
    have h0 := refPrompt_start P KR NE IP net env π tab
    rw [show π.length - 1 = 0 by omega, e, Option.map_some, hs] at h0
    obtain ⟨tok', hs', e', -, -⟩ := stepTrace_ty P.toMlxContract KR.toKernelContract RP hK hw (π.getD 0 0) (initial_ty _)
    have h1' := refPrompt_succ P KR NE IP net env π tab 0 (by omega)
    rw [h0, Option.bind_some, e'] at h1'
    exact refPrompt_caps P KR NE IP net env π RP hK leaves typed hpre tab 1 256 hs' (by omega) ⟨tok', h1'⟩
      (initial_caps P.toMlxContract KR.toKernelContract _ _ hs' tok' e') k
  · obtain ⟨s, e, _, hc⟩ := prefill_two P KR NE IP net env π RP hK leaves typed (by omega) tab
    have h0 := refPrompt_start P KR NE IP net env π tab
    rw [show π.length - 1 = 1 by omega, e, Option.map_some] at h0
    exact refPrompt_caps P KR NE IP net env π RP hK leaves typed hpre tab 1 256 s.hs (by omega) ⟨_, h0⟩ hc k

end

end Host.Mlx.SimGraph.Mach

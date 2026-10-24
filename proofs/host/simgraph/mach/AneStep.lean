import host.simgraph.mach.AneSite
namespace Host.Mlx.SimGraph.Mach
open Host.Mlx.GlueStep Host.Mlx.GlueLayers
open Inference Inference.Contracts.Mlx Host.Mlx Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph
open Host.Mlx.SimGraph.Ref (refRows refNu AneNet SplitSpec AneSt RSt splitRun aneNodes aneStep aneEnv withRb
  rowIds handlesOf)

/-! # A Neural Engine step is defined on well-typed handles

`aneStep` of the bucket's family (`aneTpl refRows (aneKindsOf n) (aneRestOf n)`) from the prefill handles at offset
`o` on the loaded weights, under the Neural Engine's success on the loaded programs (`NeuralEngine.Succeeds`) and the
loaded model's Neural Engine side (`AneNetOk`): at every environment holding typed readbacks the family's value
instance is defined (`ane_valueRun`), so every node of its graph has a value (`ane_goodAll`); every readback input's
split completes from the run so far (`ane_splitsRun`: its taps precede it, `aneOrder`, and are the family's typed
taps); the run is defined (`aneNodes_ok`) and its cache nodes hold the family's caches at offset `o + n`
(`aneStep_ok`). -/

section
variable (net : AneNet) (n : Nat) (base : Env AKey)

theorem rbExt_none (hk : ∀ k sp, net.split n k = some sp → rbLayer k ≠ none) {rb : AKey → Option Value}
    (hrb : RbTyped net n rb) (k : AKey) (h : rbLayer k = none) : rbExt net n rb k = none := by
  have hs : net.split n k = none := by
    cases e : net.split n k with
    | none => rfl
    | some sp => exact absurd h (hk k sp e)
  have hr : rb k = none := by
    cases e : rb k with
    | none => rfl
    | some y =>
      obtain ⟨sp, hsp, _⟩ := hrb k y e
      rw [hs] at hsp; cases hsp
  simp [rbExt, hr, hs]

theorem envR_off (hk : ∀ k sp, net.split n k = some sp → rbLayer k ≠ none) {rb : AKey → Option Value}
    (hrb : RbTyped net n rb) (k : AKey) (h : rbLayer k = none) : (envR net n base rb).inputs k = base.inputs k := by
  show (rbExt net n rb k).orElse _ = _
  rw [rbExt_none net n hk hrb k h]; rfl

theorem envR_at {rb : AKey → Option Value} (hrb : RbTyped net n rb) {k : AKey} {sp : SplitSpec}
    (hs : net.split n k = some sp) : ∃ y, (envR net n base rb).inputs k = some y ∧ Ty y .bfloat16 [sp.M, sp.D] := by
  show ∃ y, (rbExt net n rb k).orElse _ = some y ∧ _
  cases e : rb k with
  | some y =>
    obtain ⟨sp', hsp', hy⟩ := hrb k y e
    rw [hs] at hsp'; cases hsp'
    exact ⟨y, by simp [rbExt, e], hy⟩
  | none => exact ⟨zeros [sp.M, sp.D] .bfloat16, by simp [rbExt, e, hs], ⟨rfl, rfl⟩⟩

end

theorem LinW.congr {κ : Type} {env env' : Env κ} {bits rows cols : Nat} {key : LinKey → κ} (h : LinW env bits rows cols key)
    (he : ∀ l, env'.inputs (key l) = env.inputs (key l)) : LinW env' bits rows cols key :=
  ⟨by rw [he]; exact h.w, by rw [he]; exact h.scales, by rw [he]; exact h.biases⟩

theorem MlpRestW.congr {κ : Type} {env env' : Env κ} {mlay : MlpLayout} {rest : Nat} {key : MlpKey → κ}
    (h : MlpRestW env mlay rest key) (he : ∀ m, env'.inputs (key m) = env.inputs (key m)) :
    MlpRestW env' mlay rest key :=
  ⟨h.restRows, h.gateBits, h.upBits, h.downBits, by rw [he]; exact h.gateCodes, by rw [he]; exact h.gateScales,
    by rw [he]; exact h.upCodes, by rw [he]; exact h.upScales, by rw [he]; exact h.downCodes,
    by rw [he]; exact h.downScales⟩

section
variable (net : AneNet) (weights : List Char → List Char → Option Value) (w : PipelineWeights) (o n : Nat)
  (ids : Value) (hs : List Handles)

theorem aneEnv_off (k : AKey) (h : ∀ k', k ≠ .p k') :
    (aneEnv net weights w o n ids hs).inputs k = net.inputs n k := by
  cases k with
  | p k' => exact absurd rfl (h k')
  | _ => rfl

/-- **A layer's Neural Engine inputs at an environment holding typed readbacks** (`AneLayerW`), from the loaded
model's Neural Engine side. -/
theorem aneLayerW_envR (hk : ∀ k sp, net.split n k = some sp → rbLayer k ≠ none) {rb : AKey → Option Value}
    (hrb : RbTyped net n rb) (p : Nat) (kd : AneKinds) (rest : Nat) (sl : StageLayout)
    (hl : AneNetLayer net n p kd rest sl) :
    AneLayerW (envR net n (aneEnv net weights w o n ids hs) rb) n p kd rest sl := by
  have hpart : ∀ j h l, (envR net n (aneEnv net weights w o n ids hs) rb).inputs (.part p j h l) =
      (netEnv net n).inputs (.part p j h l) := fun j h l => by
    rw [envR_off net n _ hk hrb _ rfl,
      aneEnv_off net weights w o n ids hs (.part p j h l) (fun _ e => (nomatch e))]; rfl
  have hrest : ∀ m, (envR net n (aneEnv net weights w o n ids hs) rb).inputs (.mlpRest p m) =
      (netEnv net n).inputs (.mlpRest p m) := fun m => by
    rw [envR_off net n _ hk hrb _ rfl,
      aneEnv_off net weights w o n ids hs (.mlpRest p m) (fun _ e => (nomatch e))]; rfl
  have hout : ∀ k s D sizes, rbLayer k = some p → rbSite kd sl k = some s → rbDim kd n sl k = some (D, sizes) →
      OkV ((envR net n (aneEnv net weights w o n ids hs) rb).inputs k) fun v => Ty v .bfloat16 [n, D] := by
    intro k s D sizes h1 h2 h3
    obtain ⟨sp, hsp, hok⟩ := hl.1 k s D sizes h1 h2 h3
    obtain ⟨y, hy, ht⟩ := envR_at net n _ hrb hsp
    exact ⟨y, hy, by rw [← hok.m_eq, ← hok.d_eq]; exact ht⟩
  cases sl with
  | delta d =>
    obtain ⟨hparts, hmlp⟩ := hl.2
    refine ⟨fun j nA hj he => ⟨(hparts j nA hj he).head.congr (hpart j true), (hparts j nA hj he).rest.congr
      (hpart j false), ?_⟩, hmlp.congr hrest, hout (.mlpOut p) 5 5120 [5120 * n] rfl rfl rfl⟩
    have hs : rbSite kd (.delta d) (.linOut p j) = deltaSite j := by simp [rbSite, he, projSplit]
    obtain ⟨s, hs'⟩ : ∃ s, deltaSite j = some s := by
      rcases (show j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 ∨ j = 4 by omega) with rfl | rfl | rfl | rfl | rfl <;> exact ⟨_, rfl⟩
    exact hout (.linOut p j) s nA [nA * (dLay d j).cols, (dLay d j).cols * n] rfl (by rw [hs, hs'])
      (by simp [rbDim, he])
  | attention a =>
    obtain ⟨hparts, hmlp⟩ := hl.2
    refine ⟨fun j nA hj he => ⟨(hparts j nA hj he).head.congr (hpart j true), (hparts j nA hj he).rest.congr
      (hpart j false), ?_⟩, hmlp.congr hrest, hout (.mlpOut p) 4 5120 [5120 * n] rfl rfl rfl⟩
    exact hout (.linOut p j) j nA [nA * (aLay a j).cols, (aLay a j).cols * n] rfl
      (by simp [rbSite, he, projSplit, attnSite, hj]) (by simp [rbDim, he])

end

/-! ## The step's value instance and graph -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) (net : AneNet)
  (weights : List Char → List Char → Option Value) (w : PipelineWeights) (o n : Nat) (ids : Value) (hs : List Handles)

/-- The premises of a Neural Engine step on the prefill handles. -/
structure AneStepPre : Prop where
  net : AneNetOk net (stageWeights w)
  lo : 224 ≤ n
  hi : n ≤ 2048
  grows : Grows o n
  pipe : PipeTy w
  stages : ∀ s ∈ stageWeights w, StageW s
  handles : List.Forall₂ (StagePre o) (stageWeights w) hs
  idsTy : Ty ids .int32 [1, n]
  idsLt : ∀ j < n, ids.elems j < 2 ^ 31

variable {P K net weights w o n ids hs}

theorem chainLayout_get : ∀ {ws : List StageWeights} {hs : List Handles} {q : Nat} {sl : StageLayout},
    (chainLayout ws hs)[q]? = some sl → ∃ s h, ws[q]? = some s ∧ hs[q]? = some h ∧ sl = stageLayout s h
  | s :: ws, h :: hs, 0, sl, e => by
    simp only [chainLayout, List.getElem?_cons_zero, Option.some.injEq] at e
    exact ⟨s, h, rfl, rfl, e.symm⟩
  | s :: ws, h :: hs, q + 1, sl, e => by
    simp only [chainLayout, List.getElem?_cons_succ] at e
    obtain ⟨s', h', e1, e2, e3⟩ := chainLayout_get e
    exact ⟨s', h', by simpa using e1, by simpa using e2, e3⟩
  | [], _, _, _, e => by simp [chainLayout] at e
  | _ :: _, [], _, _, e => by simp [chainLayout] at e

/-- **The family's value instance at an environment holding typed readbacks.** -/
theorem ane_valueRun (h : AneStepPre net w o n ids hs) {rb : AKey → Option Value} (hrb : RbTyped net n rb) :
    OkV (forwardTX (aneTpl refRows (aneKindsOf n) (aneRestOf n))
        (valueB P K.toKernelContract (envR net n (aneEnv net weights w o n ids hs) rb)
          (ksR P K (envR net n (aneEnv net weights w o n ids hs) rb))) (PDim.eval (refNu o n)) o n
        (chainLayout (stageWeights w) hs))
      fun r => Ty r.1.1 .bfloat16 [1, n, 5120] ∧ List.Forall₂ (CacheOk (o + n)) (stageWeights w) r.1.2 ∧
        List.Forall₂ (TapsTyL (aneKindsOf n) n) (chainLayout (stageWeights w) hs) r.2 :=
  ok_aneForward P K _ o n _ (kindsOk_of n) _ weights w ids hs
    (fun k => envR_off net n _ (h.net.keys n) hrb (.p k) rfl) h.grows (by have := h.lo; omega) h.hi h.pipe h.stages
    h.handles h.idsTy h.idsLt fun p s h' hws _ => aneLayerW_envR net weights w o n ids hs (h.net.keys n) hrb p _ _ _
      (h.net.layers n h.lo h.hi p s h' hws)

end

end Host.Mlx.SimGraph.Mach

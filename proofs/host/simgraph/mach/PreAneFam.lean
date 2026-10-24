import host.simgraph.mach.PreAneLayer
import host.simgraph.mach.PreRow
namespace Host.Mlx.SimGraph.Mach
open Host.Mlx.GlueStep Host.Mlx.GlueLayers
open Inference Inference.Contracts.Mlx Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Mlx.GlueStep
open Host.Mlx.SimGraph.Ref (refRows refNu refRows_o refRows_n)

/-! # A Neural Engine family's value instance is defined on well-typed inputs

`aneTpl refRows kd rest` (#aneSmall, #aneDense, #aneAffine) at the value backend, at an environment whose `.p`
keys are the GPU step's (`Ref.stepEnv`: the weights, the prefill handles, the rows' ids) and whose Neural Engine
keys are typed (`AneLayerW`: each split site's head and rest rows and its readback `[n, nA]`, the MLP split's rest
rows and readback `[n, 5120]`): the output, the stages' caches at offset `o + n` (`CacheOk`) and every layer's taps
typed (`TapsTyL`: a split's flattened head rows `[nA·cols]` and input `[cols·n]`, the MLP's input `[5120·n]`). The
projection kinds are the route's (`KindsOk`). -/

/-- The route's projection kinds: plain only at the delta `a`, `b` and attention `k`, `v` projections; splits of
3840, 2304, 1920 rows at the delta `qkv`, `z`, `out`, of 4608, 1920 at the attention `q`, `o`. -/
structure KindsOk (kd : AneKinds) : Prop where
  dplain : ∀ j, j < 5 → kd.delta j = .plain → j = 2 ∨ j = 3
  aplain : ∀ j, j < 4 → kd.attn j = .plain → j = 1 ∨ j = 2
  dsplit : ∀ j nA, kd.delta j = .split nA → (j = 0 ∧ nA = 3840) ∨ (j = 1 ∧ nA = 2304) ∨ (j = 4 ∧ nA = 1920)
  asplit : ∀ j nA, kd.attn j = .split nA → (j = 0 ∧ nA = 4608) ∨ (j = 3 ∧ nA = 1920)

theorem kindsOk_small : KindsOk aneSmallK where
  dplain j hj h := by
    dsimp only [aneSmallK] at h
    split at h
    · omega
    · cases h
  aplain j hj h := by
    dsimp only [aneSmallK] at h
    split at h
    · omega
    · cases h
  dsplit j nA h := by dsimp only [aneSmallK] at h; split at h <;> cases h
  asplit j nA h := by dsimp only [aneSmallK] at h; split at h <;> cases h

theorem kindsOk_dense : KindsOk aneDenseK where
  dplain := kindsOk_small.dplain
  aplain j hj h := by simp [aneDenseK] at h
  dsplit := kindsOk_small.dsplit
  asplit j nA h := by simp [aneDenseK] at h

theorem kindsOk_affine : KindsOk aneAffineK where
  dplain j hj h := by
    dsimp only [aneAffineK] at h
    split at h
    · cases h
    · split at h
      · cases h
      · split at h
        · cases h
        · omega
  aplain j hj h := by
    dsimp only [aneAffineK] at h
    split at h
    · cases h
    · split at h
      · cases h
      · cases h
  dsplit j nA h := by
    dsimp only [aneAffineK] at h
    split at h
    · cases h; omega
    · split at h
      · cases h; omega
      · split at h
        · cases h; omega
        · cases h
  asplit j nA h := by
    dsimp only [aneAffineK] at h
    split at h
    · cases h; omega
    · split at h
      · cases h; omega
      · cases h

/-- A delta layer's projection layouts by site. -/
def dLay (d : DeltaLayout) : Nat → LinLayout
  | 0 => d.qkv
  | 1 => d.z
  | 2 => d.a
  | 3 => d.b
  | _ => d.out

/-- An attention layer's projection layouts by site. -/
def aLay (a : AttnLayout) : Nat → LinLayout
  | 0 => a.q
  | 1 => a.k
  | 2 => a.v
  | _ => a.o

/-- A projection site's taps: a split's flattened head rows and input. -/
def TapTy (k : AneProj) (lay : LinLayout) (n : Nat) (r : Value × Value × Value) : Prop :=
  match k with
  | .split nA => Ty r.2.1 .bfloat16 [nA * lay.cols] ∧ Ty r.2.2 .bfloat16 [lay.cols * n]
  | _ => True

/-- A layer's taps, typed. -/
def TapsTyL (kd : AneKinds) (n : Nat) : StageLayout → List (List Value) → Prop
  | .delta d, l => ∃ (rq rz rb ra ro : Value × Value × Value) (rm : Value × Value),
      l = [[rq.2.1, rq.2.2], [rz.2.1, rz.2.2], [rb.2.1, rb.2.2], [ra.2.1, ra.2.2],
      [ro.2.1, ro.2.2], [rm.2]] ∧ TapTy (kd.delta 0) d.qkv n rq ∧ TapTy (kd.delta 1) d.z n rz ∧
      TapTy (kd.delta 3) d.b n rb ∧ TapTy (kd.delta 2) d.a n ra ∧ TapTy (kd.delta 4) d.out n ro ∧
      Ty rm.2 .bfloat16 [5120 * n]
  | .attention a, l => ∃ (rq rk rv ro : Value × Value × Value) (rm : Value × Value),
      l = [[rq.2.1, rq.2.2], [rk.2.1, rk.2.2], [rv.2.1, rv.2.2], [ro.2.1, ro.2.2],
      [rm.2]] ∧ TapTy (kd.attn 0) a.q n rq ∧ TapTy (kd.attn 1) a.k n rk ∧ TapTy (kd.attn 2) a.v n rv ∧
      TapTy (kd.attn 3) a.o n ro ∧ Ty rm.2 .bfloat16 [5120 * n]

/-- A split site's inputs at layer `p`, site `j`: the head and rest rows, the readback `[n, nA]`. -/
structure SplitW (env : Env AKey) (n p j : Nat) (lay : LinLayout) (nA : Nat) : Prop where
  head : LinW env lay.bits nA lay.cols (.part p j true)
  rest : LinW env lay.bits (lay.rows - nA) lay.cols (.part p j false)
  out : OkV (env.inputs (.linOut p j)) fun v => Ty v .bfloat16 [n, nA]

/-- A layer's Neural Engine inputs at position `p`: each split site's, the MLP split's rest rows and readback. -/
def AneLayerW (env : Env AKey) (n p : Nat) (kd : AneKinds) (rest : Nat) : StageLayout → Prop
  | .delta d => (∀ j nA, j < 5 → kd.delta j = .split nA → SplitW env n p j (dLay d j) nA) ∧
      MlpRestW env d.mlp rest (.mlpRest p) ∧ OkV (env.inputs (.mlpOut p)) fun v => Ty v .bfloat16 [n, 5120]
  | .attention a => (∀ j nA, j < 4 → kd.attn j = .split nA → SplitW env n p j (aLay a j) nA) ∧
      MlpRestW env a.mlp rest (.mlpRest p) ∧ OkV (env.inputs (.mlpOut p)) fun v => Ty v .bfloat16 [n, 5120]

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) (env : Env AKey) (o n : Nat)

/-- **A projection site** of a Neural Engine forward, of kind `kd j`. -/
theorem ok_aneProjAt (kd : Nat → AneProj) (p j : Nat) (lay : LinLayout)
    (hl : LinOk env lay fun l => .p (stageKey p (.lin j l))) (hc : lay.cols = 5120 ∨ lay.cols = 6144)
    (hplain : kd j = .plain → lay.bits = 4) (hsplit : ∀ nA, kd j = .split nA → nA ≤ lay.rows ∧ SplitW env n p j lay nA)
    (h2 : 2 ≤ n) {x : Value} (hx : Ty x .bfloat16 [1, n, lay.cols]) :
    OkV (aneProjAt (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) refRows kd p j lay x)
      fun r => Ty r.1 .bfloat16 [1, n, lay.rows] ∧ TapTy (kd j) lay n r := by
  unfold aneProjAt
  cases e : kd j with
  | dense =>
    simp only [aneProjT]
    refine OkV.bind (ok_denseProjT P K env n lay _ hl.linW hl.bits hc hx) fun y hy => OkV.pure ⟨hy, ?_⟩
    simp [TapTy]
  | plain =>
    simp only [aneProjT]
    have hb := hplain e
    have hw : LinW env 4 lay.rows lay.cols fun l => .p (stageKey p (.lin j l)) := hb ▸ hl.linW
    refine OkV.bind (ok_plainProjT P K env n lay _ hw hb (by omega) h2 hx) fun y hy => OkV.pure ⟨hy, ?_⟩
    simp [TapTy]
  | split nA =>
    simp only [aneProjT]
    obtain ⟨hle, hs⟩ := hsplit nA e
    refine (ok_aneSplitProjT P K env o n lay nA _ _ _ hl.bits hc hle hs.head hs.rest hs.out hx).mono
      fun r hr => ⟨hr.1, ?_⟩
    simp only [TapTy]
    exact hr.2

theorem split_le_delta {kd : AneKinds} (hk : KindsOk kd) {d : DeltaLayout} (hd : d.qkv.rows = 10240 ∧ d.z.rows = 6144 ∧
    d.out.rows = 5120) (j nA : Nat) (h : kd.delta j = .split nA) : nA ≤ (dLay d j).rows := by
  rcases hk.dsplit j nA h with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> simp [dLay, hd.1, hd.2.1, hd.2.2]

theorem split_le_attn {kd : AneKinds} (hk : KindsOk kd) {a : AttnLayout} (hd : a.q.rows = 12288 ∧ a.o.rows = 5120)
    (j nA : Nat) (h : kd.attn j = .split nA) : nA ≤ (aLay a j).rows := by
  rcases hk.asplit j nA h with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> simp [aLay, hd.1, hd.2]

theorem split_lt_delta {kd : AneKinds} (hk : KindsOk kd) (j nA : Nat) (h : kd.delta j = .split nA) : j < 5 := by
  rcases hk.dsplit j nA h with ⟨rfl, _⟩ | ⟨rfl, _⟩ | ⟨rfl, _⟩ <;> omega

theorem split_lt_attn {kd : AneKinds} (hk : KindsOk kd) (j nA : Nat) (h : kd.attn j = .split nA) : j < 4 := by
  rcases hk.asplit j nA h with ⟨rfl, _⟩ | ⟨rfl, _⟩ <;> omega

/-- **A delta layer of a Neural Engine forward** at its stage's weights and prefill handles. -/
theorem ok_aneDeltaLayer (kd : AneKinds) (hk : KindsOk kd) (rest p : Nat) (dw : DeltaWeights) (conv rec : Option Value)
    (hs : StageW (.delta dw)) (hp : StagePre o (.delta dw) (.delta conv rec))
    (hin : ∀ k, env.inputs (.p (stageKey p k)) = deltaInput dw conv rec k)
    (htin : env.inputs (.p (auxKey refRows .causal p 0)) = some (tinValue n))
    (ha : AneLayerW env n p kd rest (.delta (deltaLayout dw conv rec))) (h2 : 2 ≤ n) (h2048 : n ≤ 2048) {x : Value}
    (hx : Ty x .bfloat16 [1, n, 5120]) :
    OkV ((aneTpl refRows kd rest).layer (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) o n p
        (.delta (deltaLayout dw conv rec)) x)
      fun r => (Ty r.1.1 .bfloat16 [1, n, 5120] ∧ CacheOk (o + n) (.delta dw) (r.1.2.1, r.1.2.2)) ∧
        TapsTyL kd n (.delta (deltaLayout dw conv rec)) r.2 := by
  have he := deltaEnv_of env n (aneSKey p) (aneAux refRows p) hin htin hs hp.1 hp.2
  obtain ⟨d1, d2, d3, d4, d5, d6, d7, d8, d9, d10⟩ := he.dims
  have hl : ∀ j, j < 5 → LinOk env (dLay (deltaLayout dw conv rec) j) (fun l => .p (stageKey p (.lin j l))) ∧
      ((dLay (deltaLayout dw conv rec) j).cols = 5120 ∨ (dLay (deltaLayout dw conv rec) j).cols = 6144) ∧
      (kd.delta j = .plain → (dLay (deltaLayout dw conv rec) j).bits = 4) := by
    intro j hj
    have hr4 : ∀ lay : LinLayout, lay.rows = 48 → lay.cols = 5120 → SplitRoute lay.rows lay.cols lay.bits →
        lay.bits = 4 := by
      intro lay hr hc h; rw [hr, hc] at h; simp [SplitRoute] at h; omega
    rcases (show j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 ∨ j = 4 by omega) with rfl | rfl | rfl | rfl | rfl
    · exact ⟨he.qkv, .inl d2, fun h => absurd (hk.dplain 0 (by omega) h) (by omega)⟩
    · exact ⟨he.z, .inl d4, fun h => absurd (hk.dplain 1 (by omega) h) (by omega)⟩
    · exact ⟨he.a, .inl d6, fun _ => hr4 _ d5 d6 he.a.route⟩
    · exact ⟨he.b, .inl d8, fun _ => hr4 _ d7 d8 he.b.route⟩
    · exact ⟨he.out, .inr d10, fun h => absurd (hk.dplain 4 (by omega) h) (by omega)⟩
  refine (ok_aneDeltaLayerT P K env o n _ _ (fun j r => TapTy (kd.delta j) (dLay (deltaLayout dw conv rec) j) n r)
    (fun rm => Ty rm.2 .bfloat16 [5120 * n]) _ _ _ he ?_ ?_ h2 h2048 hx).mono fun r hr => ?_
  · intro j lay x hx hj
    have hj' : j < 5 ∧ lay = dLay (deltaLayout dw conv rec) j := by
      rcases hj with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> exact ⟨by omega, rfl⟩
    obtain ⟨hj5, rfl⟩ := hj'
    obtain ⟨hlo, hc, hpl⟩ := hl j hj5
    exact ok_aneProjAt P K env o n kd.delta p j _ hlo hc hpl
      (fun nA h => ⟨split_le_delta hk ⟨d1, d3, d9⟩ j nA h, ha.1 j nA hj5 h⟩) h2 hx
  · intro x hx
    exact ok_aneMlpT P K env o n rest _ _ _ ha.2.1 ha.2.2 hx
  · obtain ⟨⟨hy, hc1, hc2⟩, rq, rz, rb, ra, ro, rm, e, t0, t1, t3, t2, t4, tm⟩ := hr
    exact ⟨⟨hy, hc1, hc2⟩, rq, rz, rb, ra, ro, rm, e, t0, t1, t3, t2, t4, tm⟩

/-- **An attention layer of a Neural Engine forward** at its stage's weights and prefill handles. -/
theorem ok_aneAttnLayer (kd : AneKinds) (hk : KindsOk kd) (rest p : Nat) (aw : AttentionWeights) (kb vb : Option Value)
    (hs : StageW (.attention aw)) (hp : StagePre o (.attention aw) (.attention kb vb)) (hg : Grows o n)
    (hin : ∀ k, env.inputs (.p (stageKey p k)) = attnInput aw kb vb k)
    (ha : AneLayerW env n p kd rest (.attention (attnLayout aw kb vb))) (h2 : 2 ≤ n) {x : Value}
    (hx : Ty x .bfloat16 [1, n, 5120]) :
    OkV ((aneTpl refRows kd rest).layer (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) o n p
        (.attention (attnLayout aw kb vb)) x)
      fun r => (Ty r.1.1 .bfloat16 [1, n, 5120] ∧ CacheOk (o + n) (.attention aw) (r.1.2.1, r.1.2.2)) ∧
        TapsTyL kd n (.attention (attnLayout aw kb vb)) r.2 := by
  have he := attnEnv_of env o n (aneSKey p) (aneAux refRows p) .causal hin (fun _ h => (nomatch h)) hs hp.1 hp.2
  obtain ⟨d1, d2, d3, d4, d5, d6, d7, d8⟩ := he.dims
  have hl : ∀ j, j < 4 → LinOk env (aLay (attnLayout aw kb vb) j) (fun l => .p (stageKey p (.lin j l))) ∧
      ((aLay (attnLayout aw kb vb) j).cols = 5120 ∨ (aLay (attnLayout aw kb vb) j).cols = 6144) ∧
      (kd.attn j = .plain → (aLay (attnLayout aw kb vb) j).bits = 4) := by
    intro j hj
    have hr4 : ∀ lay : LinLayout, lay.rows = 1024 → lay.cols = 5120 → SplitRoute lay.rows lay.cols lay.bits →
        lay.bits = 4 := by
      intro lay hr hc h; rw [hr, hc] at h; simp [SplitRoute] at h; omega
    rcases (show j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 by omega) with rfl | rfl | rfl | rfl
    · exact ⟨he.q, .inl d2, fun h => absurd (hk.aplain 0 (by omega) h) (by omega)⟩
    · exact ⟨he.k, .inl d4, fun _ => hr4 _ d3 d4 he.k.route⟩
    · exact ⟨he.v, .inl d6, fun _ => hr4 _ d5 d6 he.v.route⟩
    · exact ⟨he.out, .inr d8, fun h => absurd (hk.aplain 3 (by omega) h) (by omega)⟩
  refine (ok_aneAttentionLayerT P K env o n _ _ (fun j r => TapTy (kd.attn j) (aLay (attnLayout aw kb vb) j) n r)
    (fun rm => Ty rm.2 .bfloat16 [5120 * n]) _ _ _ he ?_ ?_ h2 hx).mono fun r hr => ?_
  · intro j lay x hx hj
    have hj' : j < 4 ∧ lay = aLay (attnLayout aw kb vb) j := by
      rcases hj with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> exact ⟨by omega, rfl⟩
    obtain ⟨hj4, rfl⟩ := hj'
    obtain ⟨hlo, hc, hpl⟩ := hl j hj4
    exact ok_aneProjAt P K env o n kd.attn p j _ hlo hc hpl
      (fun nA h => ⟨split_le_attn hk ⟨d1, d7⟩ j nA h, ha.1 j nA hj4 h⟩) h2 hx
  · intro x hx
    exact ok_aneMlpT P K env o n rest _ _ _ ha.2.1 ha.2.2 hx
  · obtain ⟨⟨hy, hc1, hc2⟩, rq, rk, rv, ro, rm, e, t0, t1, t2, t3, tm⟩ := hr
    refine ⟨⟨hy, ?_, ?_⟩, rq, rk, rv, ro, rm, e, t0, t1, t2, t3, tm⟩
    · exact hc1.cast (by rw [show (attnLayout aw kb vb).kcap = capOf kb from rfl, kvCapP_pre hp.1 hg])
    · exact hc2.cast (by rw [show (attnLayout aw kb vb).vcap = capOf vb from rfl, kvCapP_pre hp.2 hg])

end

/-! ## The chain and the forward -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) (env : Env AKey) (o n : Nat)
  (kd : AneKinds) (hk : KindsOk kd) (rest : Nat)

include hk in
/-- A layer from its stage's weights and handles (`stageInput`). -/
theorem ok_aneLayer (p : Nat) {s : StageWeights} {h : Handles} (hs : StageW s) (hp : StagePre o s h) (hg : Grows o n)
    (hin : ∀ k, env.inputs (.p (stageKey p k)) = stageInput s h k)
    (htin : env.inputs (.p (auxKey refRows .causal p 0)) = some (tinValue n))
    (ha : AneLayerW env n p kd rest (stageLayout s h)) (h2 : 2 ≤ n) (h2048 : n ≤ 2048) {x : Value}
    (hx : Ty x .bfloat16 [1, n, 5120]) :
    OkV ((aneTpl refRows kd rest).layer (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) o n p
        (stageLayout s h) x)
      fun r => (Ty r.1.1 .bfloat16 [1, n, 5120] ∧ CacheOk (o + n) s (r.1.2.1, r.1.2.2)) ∧
        TapsTyL kd n (stageLayout s h) r.2 := by
  cases s with
  | delta dw =>
    cases h with
    | attention _ _ => exact hp.elim
    | delta conv rec => exact ok_aneDeltaLayer P K env o n kd hk rest p dw conv rec hs hp hin htin ha h2 h2048 hx
  | attention aw =>
    cases h with
    | delta _ _ => exact hp.elim
    | attention kb vb => exact ok_aneAttnLayer P K env o n kd hk rest p aw kb vb hs hp hg hin ha h2 hx

include hk in
/-- **The chain of a Neural Engine forward** from position `p`. -/
theorem ok_aneChain (hg : Grows o n) (h2 : 2 ≤ n) (h2048 : n ≤ 2048) (ws : List StageWeights) (hs : List Handles)
    (hin : ∀ p s h, ws[p]? = some s → hs[p]? = some h → ∀ k, env.inputs (.p (stageKey p k)) = stageInput s h k)
    (htin : ∀ p, env.inputs (.p (auxKey refRows .causal p 0)) = some (tinValue n))
    (ha : ∀ p s h, ws[p]? = some s → hs[p]? = some h → AneLayerW env n p kd rest (stageLayout s h)) :
    ∀ (p : Nat) (ws' : List StageWeights) (hs' : List Handles), ws.drop p = ws' → hs.drop p = hs' →
      (∀ s ∈ ws', StageW s) → List.Forall₂ (StagePre o) ws' hs' → ∀ x, Ty x .bfloat16 [1, n, 5120] →
      OkV (chainTX (aneTpl refRows kd rest) (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) o n
        p (chainLayout ws' hs') x) fun r => Ty r.1 .bfloat16 [1, n, 5120] ∧
          List.Forall₂ (CacheOk (o + n)) ws' r.2.1 ∧ List.Forall₂ (TapsTyL kd n) (chainLayout ws' hs') r.2.2
  | _, [], [], _, _, _, _, x, hx => OkV.pure ⟨hx, .nil, .nil⟩
  | p, s :: ws', h :: hs', hw, hh, hsw, .cons hp hrest, x, hx => by
    have hws : ws[p]? = some s := by rw [← List.head?_drop, hw]; rfl
    have hhs : hs[p]? = some h := by rw [← List.head?_drop, hh]; rfl
    have hw' : ws.drop (p + 1) = ws' := by rw [← List.drop_drop, hw]; rfl
    have hh' : hs.drop (p + 1) = hs' := by rw [← List.drop_drop, hh]; rfl
    refine OkV.bind (ok_aneLayer P K env o n kd hk rest p (hsw s (List.mem_cons.2 (.inl rfl))) hp hg
      (hin p s h hws hhs) (htin p) (ha p s h hws hhs) h2 h2048 hx) fun r hr => ?_
    obtain ⟨⟨y, c1, c2⟩, ts⟩ := r
    dsimp only
    refine OkV.bind (ok_aneChain hg h2 h2048 ws hs hin htin ha (p + 1) ws' hs' hw' hh'
      (fun s' m => hsw s' (List.mem_cons.2 (.inr m))) hrest y hr.1.1) fun r2 hr2 => ?_
    obtain ⟨z, cs, tss⟩ := r2
    exact OkV.pure ⟨hr2.1, .cons hr.1.2 hr2.2.1, .cons hr.2 hr2.2.2⟩
  | _, [], _ :: _, _, _, _, h, _, _ => nomatch h
  | _, _ :: _, [], _, _, _, h, _, _ => nomatch h

include hk in
/-- **A Neural Engine family's value instance**, at an environment holding the GPU step's inputs at its `.p` keys
and typed Neural Engine inputs at every layer. -/
theorem ok_aneForward (weights : List Char → List Char → Option Value) (w : PipelineWeights) (ids : Value)
    (hs : List Handles) (hp : ∀ k, env.inputs (.p k) = (Ref.stepEnv weights w o n ids hs).inputs k)
    (hg : Grows o n) (h2 : 2 ≤ n) (h2048 : n ≤ 2048) (hpw : PipeTy w) (hw : ∀ s ∈ stageWeights w, StageW s)
    (hh : List.Forall₂ (StagePre o) (stageWeights w) hs) (hids : Ty ids .int32 [1, n])
    (hb : ∀ j < n, ids.elems j < 2 ^ 31)
    (ha : ∀ p s h, (stageWeights w)[p]? = some s → hs[p]? = some h → AneLayerW env n p kd rest (stageLayout s h)) :
    OkV (forwardTX (aneTpl refRows kd rest) (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) o n
        (chainLayout (stageWeights w) hs))
      fun r => Ty r.1.1 .bfloat16 [1, n, 5120] ∧ List.Forall₂ (CacheOk (o + n)) (stageWeights w) r.1.2 ∧
        List.Forall₂ (TapsTyL kd n) (chainLayout (stageWeights w) hs) r.2 := by
  unfold forwardTX
  refine OkV.bind (ok_embedT P K env n (AKey.p .promptIds) (fun k => AKey.p (.base k)) (by simp only [hp]; rfl) hids hb h2
    ⟨_, by simp only [hp]; rfl, hpw.words⟩ ⟨_, by simp only [hp]; rfl, hpw.scales⟩ ⟨_, by simp only [hp]; rfl, hpw.biases⟩) fun x hx => ?_
  refine OkV.bind (ok_aneChain P K env o n kd hk rest hg h2 h2048 (stageWeights w) hs
    (fun p s h hws hhs k => by rw [hp]; exact stepEnv_stage weights w o n ids hs p hws hhs k)
    (fun p => by rw [hp]; exact stepEnv_tin weights w o n ids hs .causal p (by omega)) ha 0 _ _ rfl rfl hw hh x hx)
    fun r hr => ?_
  obtain ⟨y, cs, tss⟩ := r
  dsimp only
  refine OkV.bind (ok_normT P K env (AKey.p (.base .finalNorm)) hr.1 ⟨_, by simp only [hp]; rfl, hpw.finalNorm⟩ rfl
    (Or.inl rfl)) fun out hout => ?_
  exact OkV.pure ⟨hout, hr.2.1, hr.2.2⟩

end

end Host.Mlx.SimGraph.Mach

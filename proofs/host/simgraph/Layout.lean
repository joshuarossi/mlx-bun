import host.simgraph.Dims
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.GlueStep Host.Mlx.GlueLayers
open Inference.Contracts.Mlx

/-! # The layout at any capacity

`stepGraphOf w hs n` reads the handles `hs` only through cache presence and
attention capacities (`chainLayout`). `CapsFor c ws hs`: every cache is
populated and every attention buffer is `[1, 4, c, 256]`.

* `chainLayout_sig`: layouts of two handle lists at capacities `c`, `c'`
  are related by `SigRel n n'` when `c` at `n` and `c'` at `n'` take the same
  KV branches, so `template_eval` applies.
* `kvSig_interior`/`kvSig_fill`/`kvSig_growth`: at a capacity `c` that is
  a multiple of 256 with `n ≤ c` (`GlueKv.State`), offset `n` takes the
  branches of offset 1, 255 or 256 at capacity 256.
* `capsFor_step`: the step trace keeps `CapsFor`, at capacity
  `kvCap (some c) n` (unchanged unless `n = c`, then `c + 256`). -/

/-- A populated stage cache, attention buffers at capacity `c`. -/
def StageCap (c : Nat) : StageWeights → Handles → Prop
  | .delta _, .delta (some _) (some _) => True
  | .attention _, .attention (some a) (some b) => a.shape = [1, 4, c, 256] ∧ b.shape = [1, 4, c, 256]
  | _, _ => False

def CapsFor (c : Nat) (ws : List StageWeights) (hs : List Handles) : Prop := List.Forall₂ (StageCap c) ws hs

theorem stageLayout_sig (w : StageWeights) (h h' : Handles) (c c' n n' : Nat) (hc : StageCap c w h)
    (hc' : StageCap c' w h') (hsig : kvSig (some c) n = kvSig (some c') n') :
    SigRel n n' (stageLayout w h) (stageLayout w h') := by
  cases w with
  | delta w =>
    cases h with
    | attention _ _ => exact hc.elim
    | delta conv rec =>
      cases h' with
      | attention _ _ => exact hc'.elim
      | delta conv' rec' =>
        cases conv <;> cases rec <;> cases conv' <;> cases rec' <;>
          first | exact hc.elim | exact hc'.elim | exact (rfl : deltaLayout w _ _ = deltaLayout w _ _)
  | attention w =>
    cases h with
    | delta _ _ => exact hc.elim
    | attention kb vb =>
      cases h' with
      | delta _ _ => exact hc'.elim
      | attention kb' vb' =>
        cases kb <;> cases vb <;> cases kb' <;> cases vb' <;> try (first | exact hc.elim | exact hc'.elim)
        rename_i a b a' b'
        obtain ⟨ha, hb⟩ := hc
        obtain ⟨ha', hb'⟩ := hc'
        have e : ∀ (v : Value) (k : Nat), v.shape = [1, 4, k, 256] → capOf (some v) = some k := fun v k hv => by
          simp [capOf, hv]
        refine ⟨rfl, rfl, rfl, rfl, rfl, ?_, ?_⟩ <;>
          simp only [attnLayout, e a c ha, e b c hb, e a' c' ha', e b' c' hb', hsig]

theorem chainLayout_sig (c c' n n' : Nat) (hsig : kvSig (some c) n = kvSig (some c') n') :
    ∀ (ws : List StageWeights) (hs hs' : List Handles), CapsFor c ws hs → CapsFor c' ws hs' →
      List.Forall₂ (SigRel n n') (chainLayout ws hs) (chainLayout ws hs')
  | [], [], [], .nil, .nil => .nil
  | w :: ws, h :: hs, h' :: hs', .cons hc rest, .cons hc' rest' =>
    .cons (stageLayout_sig w h h' c c' n n' hc hc' hsig) (chainLayout_sig c c' n n' hsig ws hs hs' rest rest')

/-! ## The three KV branches -/

theorem kvSig_interior (c n : Nat) (h : n + 1 < c) : kvSig (some c) n = kvSig (some 256) 1 := by
  have h1 : ¬ c < n + 1 := by omega
  have h2 : ¬ c = n + 1 := by omega
  simp [kvSig, kvCap, h1, h2]
  omega

theorem kvSig_fill (c n : Nat) (h : n + 1 = c) : kvSig (some c) n = kvSig (some 256) 255 := by
  simp [kvSig, kvCap, ← h]

theorem kvSig_growth (c n : Nat) (h : n = c) (hm : c % 256 = 0) : kvSig (some c) n = kvSig (some 256) 256 := by
  subst h
  simp [kvSig, kvCap, hm]

/-- A buffer of capacity `c` holding `n` rows (`GlueKv.State`) is in one of the three branches. -/
theorem branches (c n : Nat) (hn : n ≤ c) : n + 1 < c ∨ n + 1 = c ∨ n = c := by omega

theorem kvCap_interior (c n : Nat) (h : n + 1 < c) : kvCap (some c) n = c := by
  simp [kvCap, show ¬ c < n + 1 by omega]

theorem kvCap_fill (c n : Nat) (h : n + 1 = c) : kvCap (some c) n = c := by
  simp [kvCap, show ¬ c < n + 1 by omega]

theorem kvCap_growth (c n : Nat) (h : n = c) (hm : c % 256 = 0) : kvCap (some c) n = c + 256 := by
  subst h
  simp [kvCap, hm]

/-- The chain facts fix the branch preconditions: a uniform capacity `c` of
caches holding `n` rows (`GlueKv.State`) is a multiple of 256 and at least `n`. -/
theorem capacity_of_holds {n : Nat} (c : Nat) :
    ∀ (stages : List Inference.Models.Qwen.DecodeStage.Stage) (ws : List StageWeights) (hs : List Handles)
      (cache : Inference.Models.Qwen.DecodeChain.Caches stages n),
      ChainHolds stages hs cache → CapsFor c ws hs → ∀ kb vb, Handles.attention kb vb ∈ hs → c % 256 = 0 ∧ n ≤ c
  | [], _, [], _, _, _, _, _, hm => by simp at hm
  | [], _, _ :: _, _, hh, _, _, _, _ => hh.elim
  | _ :: _, _, [], _, hh, _, _, _, _ => hh.elim
  | s :: ss, w :: ws, h :: hs, cache, hh, .cons hc rest, kb, vb, hm => by
    rcases List.mem_cons.mp hm with he | hm
    · subst he
      cases s with
      | delta _ => exact hh.1.elim
      | attention _ =>
        cases w with
        | delta _ => exact hc.elim
        | attention _ =>
          cases kb with
          | none => exact hc.elim
          | some a =>
            cases vb with
            | none => exact hc.elim
            | some b =>
              obtain ⟨cap, hcap, hold⟩ := hh.1.1
              have e : [1, 4, cap, 256] = [1, 4, c, 256] := hold.2.1.symm.trans hc.1
              have ec : cap = c := by simpa using e
              subst ec
              exact ⟨hcap, hold.2.2.1⟩
    · exact capacity_of_holds c ss ws hs cache.2 hh.2 rest kb vb hm

/-! ## The step keeps uniform capacities -/

section
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

theorem sliceUpdateRange_shape {v u w : Value} {a b : List Nat} (h : sliceUpdateRange v u a b = some w) :
    w.shape = v.shape := by
  unfold sliceUpdateRange at h
  split at h
  · exact (sliceUpdate_spec _ _ _ _ h).2.1
  · cases h

theorem kvStep_cap (b k b' view : Value) (c n : Nat) (hb : b.shape = [1, 4, c, 256])
    (h : GlueKv.step (some b) n k = some (b', view)) : b'.shape = [1, 4, kvCap (some c) n, 256] := by
  unfold GlueKv.step at h
  dsimp only at h
  have hcd : b.shape.getD 2 0 = c := by rw [hb]; rfl
  rw [hcd] at h
  by_cases hc : c < n + 1
  · rw [ite_eq_left hc] at h
    by_cases hm : n % 256 = 0
    · rw [ite_eq_left hm] at h
      peel h => old eo
      cases eo
      peel h => grown e1
      peel h => b2 e2
      peel h => v3 e3
      have hr : (b2, v3) = (b', view) := Option.some.inj h
      cases hr
      rw [sliceUpdateRange_shape e2, (concatenate_spec _ _ _ _ e1).2.1, hb]
      simp [kvCap, hc, hm, zeros]
    · rw [ite_eq_right hm] at h
      peel h => old eo
      peel h => grown e1
      peel h => b2 e2
      peel h => v3 e3
      have hr : (b2, v3) = (b', view) := Option.some.inj h
      cases hr
      have hos := (slice_spec _ _ _ _ eo).2.1
      rw [sliceUpdateRange_shape e2, (concatenate_spec _ _ _ _ e1).2.1, hos]
      simp [kvCap, hc, hm, zeros]
  · rw [ite_eq_right hc] at h
    peel h => g0 e0
    cases e0
    peel h => b2 e2
    peel h => v3 e3
    have hr : (b2, v3) = (b', view) := Option.some.inj h
    cases hr
    rw [sliceUpdateRange_shape e2, hb]
    simp [kvCap, hc]

theorem attentionLayerTrace_steps (w : AttentionWeights) (kb vb : Option Value) (n : Nat) (x out kb' vb' : Value)
    (h : attentionLayerTrace M K w kb vb n x = some (out, kb', vb')) :
    (∃ k kv, GlueKv.step kb n k = some (kb', kv)) ∧ (∃ v vv, GlueKv.step vb n v = some (vb', vv)) := by
  unfold attentionLayerTrace at h
  peel h => normed e1
  peel h => qp e2
  peel h => kp e3
  peel h => vp e4
  peel h => r e5
  obtain ⟨gated, kb2, vb2⟩ := r
  dsimp only at h
  peel h => mixed e6
  peel h => o e7
  have hr : (o, kb2, vb2) = (out, kb', vb') := Option.some.inj h
  cases hr
  unfold GlueAttention.attentionTrace at e5
  peel e5 => qpr f1
  peel e5 => qh f2
  peel e5 => gh f3
  peel e5 => gate f4
  peel e5 => kr f5
  peel e5 => vr f6
  peel e5 => qn f7
  peel e5 => qt f8
  peel e5 => kn f9
  peel e5 => kt f10
  peel e5 => vt f11
  peel e5 => q f12
  peel e5 => k f13
  peel e5 => r14 f14
  obtain ⟨kb3, keys⟩ := r14
  dsimp only at e5
  peel e5 => r15 f15
  obtain ⟨vb3, values⟩ := r15
  dsimp only at e5
  peel e5 => attn f16
  peel e5 => attnT f17
  peel e5 => merged f18
  peel e5 => sig f19
  peel e5 => g20 f20
  have hr : (g20, kb3, vb3) = (gated, kb', vb') := Option.some.inj e5
  cases hr
  exact ⟨⟨k, keys, f14⟩, ⟨vt, values, f15⟩⟩

theorem stageTrace_cap (c n : Nat) (w : StageWeights) (h : Handles) (hc : StageCap c w h) (x y : Value) (h' : Handles)
    (e : stageTrace M K n w h x = some (y, h')) : StageCap (kvCap (some c) n) w h' := by
  cases w with
  | delta w =>
    match h, hc with
    | .delta (some _) (some _), _ =>
      simp only [stageTrace, Option.map_eq_some_iff] at e
      obtain ⟨_, _, he⟩ := e
      simp only [Prod.mk.injEq] at he
      rw [← he.2]
      trivial
  | attention w =>
    match h, hc with
    | .attention (some a) (some b), ⟨ha, hb⟩ =>
      simp only [stageTrace, Option.map_eq_some_iff] at e
      obtain ⟨⟨out, ka, vb'⟩, e, he⟩ := e
      simp only [Prod.mk.injEq] at he
      rw [← he.2]
      obtain ⟨⟨k, _, hk⟩, ⟨v, _, hv⟩⟩ := attentionLayerTrace_steps M K w _ _ n x out ka vb' e
      exact ⟨kvStep_cap a k ka _ c n ha hk, kvStep_cap b v vb' _ c n hb hv⟩

theorem chainTrace_caps (c n : Nat) (ws : List StageWeights) (hs : List Handles) (hc : CapsFor c ws hs) :
    ∀ (x y : Value) (hs' : List Handles), chainTrace M K n ws hs x = some (y, hs') →
      CapsFor (kvCap (some c) n) ws hs' := by
  induction hc with
  | nil =>
    intro x y hs' e
    simp only [chainTrace, Option.some.injEq, Prod.mk.injEq] at e
    rw [← e.2]
    exact .nil
  | @cons w h ws hs hc rest ih =>
    intro x y hs' e
    simp only [chainTrace] at e
    peel e => r e1
    peel e => t e2
    have hr : (t.1, r.2 :: t.2) = (y, hs') := Option.some.inj e
    cases hr
    exact .cons (stageTrace_cap M K c n w h hc x r.1 r.2 e1) (ih r.1 t.1 t.2 e2)

/-- **The step keeps uniform capacities.** -/
theorem capsFor_step (w : PipelineWeights) (n token : Nat) (hs hs' : List Handles) (t c : Nat)
    (hc : CapsFor c (stageWeights w) hs) (e : stepTrace M K w n token hs = some (t, hs')) :
    CapsFor (kvCap (some c) n) (stageWeights w) hs' := by
  unfold stepTrace at e
  peel e => x e1
  peel e => r2 e2
  obtain ⟨y, hs2⟩ := r2
  dsimp only at e
  peel e => hn e3
  peel e => logits e4
  peel e => l e5
  peel e => l6 e6
  split at e <;> [skip; exact absurd e (by simp)]
  peel e => t7 e7
  have hr : (t7, hs2) = (t, hs') := Option.some.inj e
  cases hr
  exact chainTrace_caps M K c n _ hs hc x y _ e2

end

end Host.Mlx.SimGraph

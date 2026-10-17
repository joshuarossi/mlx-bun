import host.mlx.Ops
import state.Kv

namespace Host.Mlx.GlueKv
open Inference

/-! Gap 2: kv.ts updateAndFetch for one decode token. A capacity buffer
whose first n time rows hold the logical cache realizes State.Kv.append
after slice_update + slice, and growth by concatenating zeros keeps it. -/

-- A bf16 [1,4,cap,256] buffer whose first n time rows hold `rows`.
def Holds (buf : Value) (cap n : Nat) (rows : Fin 4 → Fin n → Fin 256 → BF) : Prop :=
  buf.dtype = .bfloat16 ∧ buf.shape = [1,4,cap,256] ∧ n ≤ cap ∧
    ∀ h t i, bf (buf.get [0, h.val, t.val, i.val]) = rows h t i

-- kv.ts:117-118, first call: zeros([1,4,256,256], bf16) holds the empty cache.
theorem initial (step : Nat) (rows : Fin 4 → Fin 0 → Fin 256 → BF) : Holds (zeros [1,4,step,256] .bfloat16) step 0 rows :=
  ⟨rfl, rfl, Nat.zero_le _, fun _ t => t.elim0⟩

-- kv.ts:129-130: concatenate_axis([old, zeros], 2) keeps the held prefix.
theorem grow (buf : Value) (rows : Fin 4 → Fin n → Fin 256 → BF) (hb : Holds buf cap n rows) (step : Nat) :
    ∃ g, concatenate buf (zeros [1,4,step,256] .bfloat16) 2 = some g ∧ Holds g (cap+step) n rows := by
  obtain ⟨hd, hs, hn, he⟩ := hb
  obtain ⟨g, hg⟩ := concatenate_defined buf (zeros [1,4,step,256] .bfloat16) 2
    (by rw [hs, hd]; refine ⟨rfl, rfl, by simp, ?_⟩; simp [zeros, List.range, List.range.loop])
  obtain ⟨gd, gs, gget⟩ := concatenate_spec _ _ _ _ hg
  rw [hs] at gs
  simp only [zeros, List.getD, List.getElem?_cons_succ, List.getElem?_cons_zero, Option.getD_some, List.set] at gs
  refine ⟨g, hg, gd.trans hd, gs, by omega, fun h t i => ?_⟩
  rw [gget _ (by rw [gs]; exact within4 Nat.zero_lt_one h.isLt (by omega) i.isLt), hs]
  have ht : t.val < cap := by omega
  simp only [List.getD, List.getElem?_cons_succ, List.getElem?_cons_zero, Option.getD_some, ht, ite_true]
  exact he h t i

-- kv.ts:140-148: slice_update(buf, k, [0,0,n,0], [1,4,n+1,256]), then
-- slice(buf', [0,0,0,0], [1,4,n+1,256]). `k` is the roped [1,4,1,256] value.
theorem append (buf k : Value) (rows : Fin 4 → Fin n → Fin 256 → BF) (hb : Holds buf cap n rows)
    (key : Fin 4 → Fin 256 → BF) (hk : Tensor4 k 4 1 256 (fun h _ i => key h i)) (room : n < cap) :
    ∃ b v, sliceUpdateRange buf k [0,0,n,0] [1,4,n+1,256] = some b ∧ slice b [0,0,0,0] [1,4,n+1,256] = some v ∧
      Holds b cap (n+1) (fun h t i => State.Kv.appendRows (fun s => rows h s i) (key h i) t) ∧
      Tensor4 v 4 (n+1) 256 (fun h t i => State.Kv.appendRows (fun s => rows h s i) (key h i) t) := by
  obtain ⟨hd, hs, hn, he⟩ := hb
  obtain ⟨kd, ks, ke⟩ := hk
  have range : sliceUpdateRange buf k [0,0,n,0] [1,4,n+1,256] = sliceUpdate buf k [0,0,n,0] := by
    unfold sliceUpdateRange; rw [ite_eq_left (by rw [ks]; simp)]
  obtain ⟨b, hbu⟩ := sliceUpdate_defined buf k [0,0,n,0]
    (by rw [hs, ks, kd, hd]; refine ⟨rfl, rfl, rfl, ?_⟩; simp; omega)
  obtain ⟨bd, bs, bget⟩ := sliceUpdate_spec _ _ _ _ hbu
  rw [hs] at bs
  have held : ∀ (h : Fin 4) (t : Fin (n+1)) (i : Fin 256), bf (b.get [0, h.val, t.val, i.val]) =
      State.Kv.appendRows (fun s => rows h s i) (key h i) t := by
    intro h t i
    rw [bget _ (by rw [hs]; exact within4 Nat.zero_lt_one h.isLt (by omega) i.isLt), ks]
    unfold State.Kv.appendRows
    by_cases ht : t.val < n
    · simp [ht]
      rw [ite_eq_right (by omega)]
      exact he h ⟨t.val, ht⟩ i
    · have heq : t.val = n := by omega
      simp [heq]
      exact ke h 0 i
  obtain ⟨v, hv⟩ := slice_defined b [0,0,0,0] [1,4,n+1,256] (by rw [bs]; simp; omega)
  obtain ⟨vd, vs, vget⟩ := slice_spec _ _ _ _ hv
  simp only [List.zipWith, Nat.sub_zero] at vs
  refine ⟨b, v, range.trans hbu, hv, ⟨bd.trans hd, bs, by omega, held⟩, vd.trans (bd.trans hd), vs, fun h t i => ?_⟩
  rw [vget _ (by rw [vs]; exact within4 Nat.zero_lt_one h.isLt t.isLt i.isLt)]
  simpa using held h t i

-- kv.ts updateAndFetch, L = 1, one tensor: allocate or grow by STEP = 256
-- when full (trimming first iff prev % 256 ≠ 0), write row prev, view.
def step (buf : Option Value) (prev : Nat) (k : Value) : Option (Value × Value) := do
  let grown ← match buf with
    | none => some (zeros [1,4,256,256] .bfloat16)
    | some b =>
      if b.shape.getD 2 0 < prev + 1 then do
        let old ← if prev % 256 = 0 then some b else slice b [0,0,0,0] [1,4,prev,256]
        concatenate old (zeros [1,4,256,256] .bfloat16) 2
      else some b
  let b ← sliceUpdateRange grown k [0,0,prev,0] [1,4,prev+1,256]
  let view ← slice b [0,0,0,0] [1,4,prev+1,256]
  pure (b, view)

-- Capacities stay multiples of 256, so growth happens at prev = cap and no
-- trim slice is issued on the route.
def State (buf : Option Value) (n : Nat) (rows : Fin 4 → Fin n → Fin 256 → BF) : Prop :=
  match buf with
  | none => n = 0
  | some b => ∃ cap, cap % 256 = 0 ∧ Holds b cap n rows

theorem step_correct (buf : Option Value) (rows : Fin 4 → Fin n → Fin 256 → BF) (hs : State buf n rows)
    (k : Value) (key : Fin 4 → Fin 256 → BF) (hk : Tensor4 k 4 1 256 (fun h _ i => key h i)) :
    ∃ b v, step buf n k = some (b, v) ∧
      State (some b) (n+1) (fun h t i => State.Kv.appendRows (fun s => rows h s i) (key h i) t) ∧
      Tensor4 v 4 (n+1) 256 (fun h t i => State.Kv.appendRows (fun s => rows h s i) (key h i) t) := by
  have finish : ∀ g cap, cap % 256 = 0 → Holds g cap n rows → n < cap →
      (∃ b v, (do let b ← sliceUpdateRange g k [0,0,n,0] [1,4,n+1,256]
                  let view ← slice b [0,0,0,0] [1,4,n+1,256]
                  pure (b, view)) = some (b, v) ∧
        State (some b) (n+1) (fun h t i => State.Kv.appendRows (fun s => rows h s i) (key h i) t) ∧
        Tensor4 v 4 (n+1) 256 (fun h t i => State.Kv.appendRows (fun s => rows h s i) (key h i) t)) := by
    intro g cap hc hg room
    obtain ⟨b, v, hb, hv, held, view⟩ := append g k rows hg key hk room
    exact ⟨b, v, by rw [hb]; simp [hv], ⟨cap, hc, held⟩, view⟩
  cases buf with
  | none =>
    have hn : n = 0 := hs
    subst hn
    obtain ⟨b, v, e, rest⟩ := finish _ 256 rfl (initial 256 rows) (by decide)
    exact ⟨b, v, by simpa [step] using e, rest⟩
  | some b =>
    obtain ⟨cap, hc, hb⟩ := hs
    by_cases full : cap < n + 1
    · have hn : n = cap := by have := hb.2.2.1; omega
      have hm : n % 256 = 0 := by rw [hn]; exact hc
      obtain ⟨g, hg, gh⟩ := grow b rows hb 256
      obtain ⟨b', v, e, rest⟩ := finish g (cap+256) (by omega) gh (by omega)
      refine ⟨b', v, ?_, rest⟩
      simp only [step, hb.2.1, List.getD, List.getElem?_cons_succ, List.getElem?_cons_zero, Option.getD_some,
        full, ite_true, hm, Option.bind_eq_bind, Option.bind_some]
      rw [hg]
      simpa using e
    · obtain ⟨b', v, e, rest⟩ := finish b cap hc hb (by omega)
      refine ⟨b', v, ?_, rest⟩
      simp only [step, hb.2.1, List.getD, List.getElem?_cons_succ, List.getElem?_cons_zero, Option.getD_some,
        full, ite_false, Option.bind_eq_bind, Option.bind_some]
      simpa using e

-- Both tensors of one layer: the views encode State.Kv.append.
theorem update_and_fetch (kb vb : Option Value) (cache : State.Kv.Cache BF n)
    (hk : State kb n cache.keys) (hv : State vb n cache.values)
    (k v : Value) (key value : Fin 4 → Fin 256 → BF)
    (hkey : Tensor4 k 4 1 256 (fun h _ i => key h i)) (hvalue : Tensor4 v 4 1 256 (fun h _ i => value h i)) :
    ∃ kb' kview vb' vview, step kb n k = some (kb', kview) ∧ step vb n v = some (vb', vview) ∧
      State (some kb') (n+1) (State.Kv.append cache key value).keys ∧
      State (some vb') (n+1) (State.Kv.append cache key value).values ∧
      Tensor4 kview 4 (n+1) 256 (State.Kv.append cache key value).keys ∧
      Tensor4 vview 4 (n+1) 256 (State.Kv.append cache key value).values := by
  obtain ⟨kb', kview, ek, sk, tk⟩ := step_correct kb cache.keys hk k key hkey
  obtain ⟨vb', vview, ev, sv, tv⟩ := step_correct vb cache.values hv v value hvalue
  exact ⟨kb', kview, vb', vview, ek, ev, sk, sv, tk, tv⟩

end Host.Mlx.GlueKv

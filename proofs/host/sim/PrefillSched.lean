import host.sim.CasesL
namespace Host.Ts.Sim.Prefill
open Host.Ts.Sim

/-! # The prefill schedule and its template classes

The schedule of a prompt of `L` tokens (design `host-L-design.md` §3.1, prefill map §1):

* the chunk size `chunkC L` (`resolveMlxPrefillPolicy`, generation/bindings/prefill-policy.ts:31-35:
  halve from 2048 while above 8 and `sdpaFallbackBytes` exceeds 1 GiB; state/kv-scheme.ts:118-135
  with 24 heads, 2-byte scores, global keys `L`): 2048 up to 10922, then 1024, 512, 256, 128, 64
  up to 349525 (`chunkC_eq`);
* `nextPrefillStep` (contracts/portable/prefill.ts:41-63, tail split on, no snapshot) on naturals
  (`nextStep`): `drains L = ⌊(L-1)/C⌋` whole chunks `[jC, (j+1)C)` (phase `chunk`), a tail
  `[kC, L-1)` of `tailRows L = (L-1) mod C` rows when it is not empty (phase `tail`, or `decode`
  for one row), and the final `[L-1, L)` (phase `decode`): `nextStep_drain`, `nextStep_tail`,
  `nextStep_final`;
* the KV capacity (`KVCache.updateAndFetch`, state/kv.ts:108-150): `kvCap` keeps `capL o`
  (`256·⌈o/256⌉`) at every step of the schedule (`kvCap_drain`, `kvCap_tail`, `kvCap_one`), with
  growth exactly at offsets that are multiples of 256 (`grows_*`), by `256·⌈C/256⌉` along the
  drains (`capL_drain`).

The template classes of each segment of the chain (design §3.2; FINAL warm classes from the P0a
probe: cold `L = 1` vs warmed), as finite lists, and the chain of classes of `L` (`chainOf`).
`chain_cover`: every `L` in `[1, 262143]` (so every `L ≤ 262144 - T`) falls in exactly one chain
of classes: at each position the chain's class is in its finite list, applies, and is the only
class that applies. -/

/-! ## The chunk size -/

/-- `sdpaFallbackBytes` of the model at chunk `c` and context `L`: `24·q·L·2` for `q = min c L`
queries, zero when `q ≤ 8` (the fused kernel). -/
def sdpaBytes (c L : Nat) : Nat := if min c L ≤ 8 then 0 else 48 * min c L * L

/-- `chunkSize`'s halving loop, with fuel (the workspace is `2 ^ 30` bytes). -/
def chunkLoop : Nat → Nat → Nat → Nat
  | 0, c, _ => c
  | f + 1, c, L => if 8 < c ∧ 1073741824 < sdpaBytes c L then chunkLoop f (c / 2) L else c

/-- **The chunk size** of a prompt of `L` tokens (eight halvings reach 8, where the loop stops). -/
def chunkC (L : Nat) : Nat := chunkLoop 8 2048 L

theorem sdpaBytes_ge {c L : Nat} (h8 : 8 < c) (hc : c ≤ L) : sdpaBytes c L = 48 * c * L := by
  unfold sdpaBytes
  rw [Nat.min_eq_left hc, ite_eq_right (by omega)]

theorem sdpaBytes_small {L : Nat} (hL : L < 2048) : ¬ 1073741824 < sdpaBytes 2048 L := by
  unfold sdpaBytes
  rw [Nat.min_eq_right (by omega)]
  split
  · omega
  · have h : L * L ≤ 2047 * 2047 := Nat.mul_le_mul (by omega) (by omega)
    rw [Nat.mul_assoc]
    generalize L * L = q at h ⊢
    omega

theorem chunkLoop_unfold (L : Nat) : chunkLoop 8 2048 L =
    if 8 < 2048 ∧ 1073741824 < sdpaBytes 2048 L then
      (if 8 < 1024 ∧ 1073741824 < sdpaBytes 1024 L then
        (if 8 < 512 ∧ 1073741824 < sdpaBytes 512 L then
          (if 8 < 256 ∧ 1073741824 < sdpaBytes 256 L then
            (if 8 < 128 ∧ 1073741824 < sdpaBytes 128 L then
              (if 8 < 64 ∧ 1073741824 < sdpaBytes 64 L then chunkLoop 2 32 L else 64)
            else 128) else 256) else 512) else 1024) else 2048 := rfl

/-- **The chunk-size table.** -/
theorem chunkC_eq (L : Nat) (h2 : L ≤ 349525) :
    chunkC L = if L ≤ 10922 then 2048 else if L ≤ 21845 then 1024 else if L ≤ 43690 then 512
      else if L ≤ 87381 then 256 else if L ≤ 174762 then 128 else 64 := by
  unfold chunkC
  rw [chunkLoop_unfold]
  by_cases hs : L < 2048
  · rw [ite_eq_right (fun h => sdpaBytes_small hs h.2), ite_eq_left (by omega)]
  · have g : ∀ c, 8 < c → c ≤ 2048 → sdpaBytes c L = 48 * c * L := fun c h8 hc => sdpaBytes_ge h8 (by omega)
    rw [g 2048 (by omega) (by omega), g 1024 (by omega) (by omega), g 512 (by omega) (by omega),
      g 256 (by omega) (by omega), g 128 (by omega) (by omega), g 64 (by omega) (by omega)]
    by_cases a1 : L ≤ 10922
    · rw [ite_eq_right (by omega), ite_eq_left a1]
    · rw [ite_eq_left (by omega), ite_eq_right a1]
      by_cases a2 : L ≤ 21845
      · rw [ite_eq_right (by omega), ite_eq_left a2]
      · rw [ite_eq_left (by omega), ite_eq_right a2]
        by_cases a3 : L ≤ 43690
        · rw [ite_eq_right (by omega), ite_eq_left a3]
        · rw [ite_eq_left (by omega), ite_eq_right a3]
          by_cases a4 : L ≤ 87381
          · rw [ite_eq_right (by omega), ite_eq_left a4]
          · rw [ite_eq_left (by omega), ite_eq_right a4]
            by_cases a5 : L ≤ 174762
            · rw [ite_eq_right (by omega), ite_eq_left a5]
            · rw [ite_eq_left (by omega), ite_eq_right a5, ite_eq_right (by omega)]

/-- The six chunk sizes of the supported lengths. -/
def chunkSizes : List Nat := [2048, 1024, 512, 256, 128, 64]

theorem chunkC_cases {L : Nat} (h2 : L ≤ 349525) :
    chunkC L = 2048 ∨ chunkC L = 1024 ∨ chunkC L = 512 ∨ chunkC L = 256 ∨ chunkC L = 128 ∨ chunkC L = 64 := by
  rw [chunkC_eq L h2]
  (repeat' split) <;> simp

theorem chunkC_mem {L : Nat} (h2 : L ≤ 349525) : chunkC L ∈ chunkSizes := by
  rcases chunkC_cases h2 with h | h | h | h | h | h <;> rw [h] <;> simp [chunkSizes]

theorem chunkSizes_cases {C : Nat} (hC : C ∈ chunkSizes) :
    C = 2048 ∨ C = 1024 ∨ C = 512 ∨ C = 256 ∨ C = 128 ∨ C = 64 := by
  simpa [chunkSizes] using hC

/-! ## The schedule -/

/-- The whole chunks of the schedule. -/
def drains (L : Nat) : Nat := (L - 1) / chunkC L

/-- The rows of the tail (none when `0`). -/
def tailRows (L : Nat) : Nat := (L - 1) % chunkC L

theorem drains_tail (L : Nat) : drains L * chunkC L + tailRows L = L - 1 := by
  unfold drains tailRows
  rw [Nat.mul_comm]
  exact Nat.div_add_mod (L - 1) (chunkC L)

/-- A prompt step's phase (`prefillPhase`). -/
inductive Phase where
  | chunk
  | tail
  | decode
  deriving DecidableEq

/-- A prompt step: `[start, stop)`, final or drain, its phase. -/
structure PStep where
  start : Nat
  stop : Nat
  final : Bool
  phase : Phase
  deriving DecidableEq

/-- `prefillPhase start stop whole`. -/
def phaseOf (start stop : Nat) (whole : Bool) : Phase :=
  if stop - start = 1 then .decode else if whole = true then .chunk else .tail

/-- **`nextPrefillStep`** at length `L`, position `pos`, chunk `C` (tail split, no snapshot). -/
def nextStep (L pos C : Nat) : PStep :=
  if 1 < L - pos then
    if C ≤ L - pos - 1 then ⟨pos, pos + C, false, phaseOf pos (pos + C) true⟩
    else ⟨pos, pos + (L - pos - 1), false, phaseOf pos (pos + (L - pos - 1)) false⟩
  else ⟨pos, L, true, phaseOf pos L (decide (L - pos = C))⟩

/-- The `j`-th whole chunk. -/
theorem nextStep_drain {L C j : Nat} (hC : 2 ≤ C) (hj : (j + 1) * C ≤ L - 1) :
    nextStep L (j * C) C = ⟨j * C, (j + 1) * C, false, .chunk⟩ := by
  have e : (j + 1) * C = j * C + C := Nat.succ_mul j C
  unfold nextStep phaseOf
  rw [ite_eq_left (by omega), ite_eq_left (by omega), ite_eq_right (by omega), ite_eq_left rfl, e]

/-- The tail after the whole chunks. -/
theorem nextStep_tail {L C k t : Nat} (hk : k * C + t = L - 1) (ht : 1 ≤ t) (htC : t < C) :
    nextStep L (k * C) C = ⟨k * C, L - 1, false, if t = 1 then .decode else .tail⟩ := by
  unfold nextStep phaseOf
  rw [ite_eq_left (by omega), ite_eq_right (by omega), show k * C + (L - k * C - 1) = L - 1 by omega]
  by_cases h1 : t = 1
  · rw [ite_eq_left (by omega), ite_eq_left h1]
  · rw [ite_eq_right (by omega), ite_eq_right h1, ite_eq_right (by simp)]

/-- The final step. -/
theorem nextStep_final {L C : Nat} (hL : 1 ≤ L) :
    nextStep L (L - 1) C = ⟨L - 1, L, true, .decode⟩ := by
  unfold nextStep phaseOf
  rw [ite_eq_right (by omega), ite_eq_left (by omega)]

/-! ## The KV capacity -/

/-- The KV capacity after appending `r` rows at offset `o` to capacity `cap` (null keys: `first`). -/
def kvCap (first : Bool) (cap o r : Nat) : Nat :=
  if first = true then 256 * ((r + 255) / 256)
  else if cap < o + r then (if o % 256 ≠ 0 then o else cap) + 256 * ((r + 255) / 256) else cap

/-- Whether an append grows the cache (null keys, or beyond the capacity). -/
def kvGrows (first : Bool) (cap o r : Nat) : Bool := first || decide (cap < o + r)

/-- The first append. -/
theorem kvCap_first (r : Nat) : kvCap true 0 0 r = capL r := by
  unfold kvCap capL
  rw [ite_eq_left rfl]

/-- An append that starts at a multiple of 256 or fits keeps the capacity `capL`. -/
theorem kvCap_capL {o r : Nat} (h : o % 256 = 0 ∨ o + r ≤ capL o) : kvCap false (capL o) o r = capL (o + r) := by
  unfold kvCap
  rw [ite_eq_right (by simp)]
  unfold capL at *
  split
  · split <;> omega
  · omega

/-- The appends of the schedule (chunk `C` among the six, `r ≤ C` rows at `jC`) start at a multiple
of 256 or fit. -/
theorem sched_ok {C j r : Nat} (hC : C ∈ chunkSizes) (hr : r ≤ C) : (j * C) % 256 = 0 ∨ j * C + r ≤ capL (j * C) := by
  unfold capL
  rcases chunkSizes_cases hC with rfl | rfl | rfl | rfl | rfl | rfl <;> omega

/-- A single row always starts at a multiple of 256 or fits. -/
theorem one_ok (o : Nat) : o % 256 = 0 ∨ o + 1 ≤ capL o := by unfold capL; omega

/-- **The capacity after the `j`-th whole chunk** (`j ≥ 1`). -/
theorem kvCap_drain {C j : Nat} (hC : C ∈ chunkSizes) :
    kvCap false (capL (j * C)) (j * C) C = capL ((j + 1) * C) := by
  rw [kvCap_capL (sched_ok hC (Nat.le_refl C)), Nat.succ_mul]

/-- The capacity after the tail. -/
theorem kvCap_tail {C k t : Nat} (hC : C ∈ chunkSizes) (ht : t ≤ C) :
    kvCap false (capL (k * C)) (k * C) t = capL (k * C + t) := kvCap_capL (sched_ok hC ht)

/-- The capacity after one row (the final step and every decode step). -/
theorem kvCap_one (o : Nat) : kvCap false (capL o) o 1 = capL (o + 1) := kvCap_capL (one_ok o)

/-- The capacity's growth along the whole chunks: by `256·⌈C/256⌉` exactly at multiples of 256. -/
theorem capL_drain {C j : Nat} (hC : C ∈ chunkSizes) :
    capL ((j + 1) * C) = capL (j * C) + (if (j * C) % 256 = 0 then 256 * ((C + 255) / 256) else 0) := by
  rw [Nat.succ_mul]
  unfold capL
  rcases chunkSizes_cases hC with rfl | rfl | rfl | rfl | rfl | rfl <;> split <;> omega

/-- A whole chunk grows the cache exactly at multiples of 256 (`j ≥ 1`). -/
theorem grows_drain {C j : Nat} (hC : C ∈ chunkSizes) :
    kvGrows false (capL (j * C)) (j * C) C = decide ((j * C) % 256 = 0) := by
  unfold kvGrows
  rw [Bool.false_or, decide_eq_decide]
  unfold capL
  rcases chunkSizes_cases hC with rfl | rfl | rfl | rfl | rfl | rfl <;> omega

/-- A non-empty tail grows the cache exactly at multiples of 256. -/
theorem grows_tail {C k t : Nat} (hC : C ∈ chunkSizes) (ht1 : 1 ≤ t) (ht : t < C) :
    kvGrows false (capL (k * C)) (k * C) t = decide ((k * C) % 256 = 0) := by
  unfold kvGrows
  rw [Bool.false_or, decide_eq_decide]
  unfold capL
  rcases chunkSizes_cases hC with rfl | rfl | rfl | rfl | rfl | rfl <;> omega

/-- One row grows the cache exactly at multiples of 256. -/
theorem grows_one (o : Nat) : kvGrows false (capL o) o 1 = decide (o % 256 = 0) := by
  unfold kvGrows
  rw [Bool.false_or, decide_eq_decide]
  unfold capL
  omega

/-- From 256 rows every whole chunk starts at a multiple of 256. -/
theorem drain_mod {C j : Nat} (hC : C ∈ chunkSizes) (h256 : 256 ≤ C) : (j * C) % 256 = 0 := by
  rcases chunkSizes_cases hC with rfl | rfl | rfl | rfl | rfl | rfl <;> omega

/-! ## Contiguous bands -/

/-- Bands `[lo, hi]` covering `[a, …]` without gaps or overlaps. -/
def Contig : Nat → List (Nat × Nat) → Prop
  | _, [] => True
  | a, b :: bs => b.1 = a ∧ b.1 ≤ b.2 ∧ Contig (b.2 + 1) bs

/-- The decidable check of `Contig`. -/
def contigB : Nat → List (Nat × Nat) → Bool
  | _, [] => true
  | a, b :: bs => Nat.beq b.1 a && Nat.ble b.1 b.2 && contigB (b.2 + 1) bs

theorem contigB_sound : ∀ (a : Nat) (bs : List (Nat × Nat)), contigB a bs = true → Contig a bs
  | _, [] => fun _ => trivial
  | a, b :: bs => by
    intro h
    simp only [contigB, Bool.and_eq_true, Nat.beq_eq, Nat.ble_eq] at h
    exact ⟨h.1.1, h.1.2, contigB_sound _ bs h.2⟩

/-- `t` is in band `i`. -/
def BandMem (bs : List (Nat × Nat)) (i t : Nat) : Prop := ∃ b, bs[i]? = some b ∧ b.1 ≤ t ∧ t ≤ b.2

/-- The last band's end. -/
def bandsHi : Nat → List (Nat × Nat) → Nat
  | a, [] => a - 1
  | _, b :: bs => bandsHi (b.2 + 1) bs

/-- The band of `t`: the first ending at or after `t`. -/
def bandIdx : List (Nat × Nat) → Nat → Nat
  | [], _ => 0
  | b :: bs, t => if t ≤ b.2 then 0 else bandIdx bs t + 1

theorem contig_lo : ∀ {a : Nat} {bs : List (Nat × Nat)} {i t : Nat}, Contig a bs → BandMem bs i t → a ≤ t
  | _, [], _, _, _, ⟨_, hb, _⟩ => by simp at hb
  | a, b :: bs, 0, t, ⟨e, _, _⟩, ⟨b', hb, h1, _⟩ => by
    simp only [List.getElem?_cons_zero, Option.some.injEq] at hb
    subst hb; omega
  | a, b :: bs, i + 1, t, ⟨e, hle, hc⟩, ⟨b', hb, h1, h2⟩ => by
    have := contig_lo hc ⟨b', by simpa using hb, h1, h2⟩
    omega

/-- **At most one band** holds `t`. -/
theorem contig_unique : ∀ {a : Nat} {bs : List (Nat × Nat)} {i j t : Nat}, Contig a bs → BandMem bs i t →
    BandMem bs j t → i = j
  | _, [], _, _, _, _, ⟨_, hb, _⟩, _ => by simp at hb
  | a, b :: bs, 0, 0, t, _, _, _ => rfl
  | a, b :: bs, 0, j + 1, t, ⟨e, hle, hc⟩, ⟨b', hb, h1, h2⟩, ⟨b'', hb', h1', h2'⟩ => by
    simp only [List.getElem?_cons_zero, Option.some.injEq] at hb
    subst hb
    have := contig_lo hc ⟨b'', by simpa using hb', h1', h2'⟩
    omega
  | a, b :: bs, i + 1, 0, t, ⟨e, hle, hc⟩, ⟨b', hb, h1, h2⟩, ⟨b'', hb', h1', h2'⟩ => by
    simp only [List.getElem?_cons_zero, Option.some.injEq] at hb'
    subst hb'
    have := contig_lo hc ⟨b', by simpa using hb, h1, h2⟩
    omega
  | a, b :: bs, i + 1, j + 1, t, ⟨_, _, hc⟩, ⟨b', hb, h1, h2⟩, ⟨b'', hb', h1', h2'⟩ => by
    have := contig_unique hc ⟨b', by simpa using hb, h1, h2⟩ ⟨b'', by simpa using hb', h1', h2'⟩
    omega

/-- **The band of every `t`** from the start to the last band's end holds it. -/
theorem bandIdx_mem : ∀ {a : Nat} {bs : List (Nat × Nat)} {t : Nat}, 1 ≤ a → Contig a bs → a ≤ t →
    t ≤ bandsHi a bs → bandIdx bs t < bs.length ∧ BandMem bs (bandIdx bs t) t
  | a, [], t, ha, _, h1, h2 => by simp only [bandsHi] at h2; omega
  | a, b :: bs, t, ha, ⟨e, hle, hc⟩, h1, h2 => by
    unfold bandIdx
    by_cases ht : t ≤ b.2
    · rw [ite_eq_left ht]; exact ⟨by simp, b, rfl, by omega, ht⟩
    · rw [ite_eq_right ht]
      obtain ⟨hi, b', hb, hm1, hm2⟩ := bandIdx_mem (a := b.2 + 1) (bs := bs) (t := t) (Nat.succ_pos _) hc (by omega)
        (by simpa [bandsHi] using h2)
      exact ⟨by rw [List.length_cons]; omega, b', by simpa using hb, hm1, hm2⟩

/-! ## The tail row classes -/

/-- **The row classes of a tail** of `t ∈ [1, 2047]` rows (prefill map §2, §3; the model's
`prompt` ranges, models/qwen/qwen38-27b-trellis-m1max.ts:1180, and the down plan,
kernels/trellis/down-mma-wide.ts:40-53): `D1` (one row, phase `decode`), `V23`, `V4`, `V58` at 5
rows (fused SDPA) and at 6–8 (`foldedSdpa`), the 17 `VW` bands of the down plan in 9–223, and the
15 Neural Engine buckets in 224–2047. -/
def rowBands : List (Nat × Nat) :=
  [(1, 1), (2, 3), (4, 4), (5, 5), (6, 8),
   (9, 16), (17, 24), (25, 32), (33, 48), (49, 64), (65, 72), (73, 80), (81, 96), (97, 112), (113, 120),
   (121, 128), (129, 144), (145, 160), (161, 168), (169, 176), (177, 216), (217, 223),
   (224, 256), (257, 320), (321, 384), (385, 448), (449, 512), (513, 576), (577, 640), (641, 704), (705, 768),
   (769, 896), (897, 1024), (1025, 1280), (1281, 1536), (1537, 1792), (1793, 2047)]

theorem rowBands_length : rowBands.length = 37 := rfl

theorem rowBands_contig : Contig 1 rowBands := contigB_sound 1 rowBands (by decide)

theorem rowBands_hi : bandsHi 1 rowBands = 2047 := by decide

/-- The row class (band index) of `t` rows. -/
def rowClass (t : Nat) : Nat := bandIdx rowBands t

/-- `t` rows are in row class `X`. -/
def RowMem (X t : Nat) : Prop := BandMem rowBands X t

/-- **Every tail has exactly one row class.** -/
theorem rowClass_spec {t : Nat} (h1 : 1 ≤ t) (h2 : t ≤ 2047) :
    rowClass t < 37 ∧ RowMem (rowClass t) t ∧ ∀ X, RowMem X t → X = rowClass t := by
  obtain ⟨hi, hm⟩ := bandIdx_mem (Nat.le_refl 1) rowBands_contig h1 (by rw [rowBands_hi]; exact h2)
  exact ⟨by rw [← rowBands_length]; exact hi, hm, fun X hX => contig_unique rowBands_contig hX hm⟩

/-- The row classes of tails below `C` rows: the bands starting below `C`. -/
def rowClassesBelow (C : Nat) : List Nat :=
  (List.range 37).filter fun X => match rowBands[X]? with
    | some b => Nat.blt b.1 C
    | none => false

/-! ## The classes of each segment -/

/-- **SETUP classes** (`chunkSize` with `L` symbolic): the early return of `sdpaFallbackBytes`
(`L ≤ 8`), and `h0` … `h5` halvings of the loop (chunk `2048 / 2^h`). -/
inductive SetupClass where
  | early
  | h0
  | h1
  | h2
  | h3
  | h4
  | h5
  deriving DecidableEq

def setupClasses : List SetupClass := [.early, .h0, .h1, .h2, .h3, .h4, .h5]

def SetupClass.Applies : SetupClass → Nat → Prop
  | .early, L => 1 ≤ L ∧ L ≤ 8
  | .h0, L => 9 ≤ L ∧ L ≤ 10922
  | .h1, L => 10923 ≤ L ∧ L ≤ 21845
  | .h2, L => 21846 ≤ L ∧ L ≤ 43690
  | .h3, L => 43691 ≤ L ∧ L ≤ 87381
  | .h4, L => 87382 ≤ L ∧ L ≤ 174762
  | .h5, L => 174763 ≤ L ∧ L ≤ 349525

/-- The chunk a SETUP class chooses. -/
def SetupClass.chunk : SetupClass → Nat
  | .early => 2048
  | .h0 => 2048
  | .h1 => 1024
  | .h2 => 512
  | .h3 => 256
  | .h4 => 128
  | .h5 => 64

def setupOf (L : Nat) : SetupClass :=
  if L ≤ 8 then .early else if L ≤ 10922 then .h0 else if L ≤ 21845 then .h1 else if L ≤ 43690 then .h2
  else if L ≤ 87381 then .h3 else if L ≤ 174762 then .h4 else .h5

theorem setup_chunk {L : Nat} (h2 : L ≤ 349525) : (setupOf L).chunk = chunkC L := by
  rw [chunkC_eq L h2]
  unfold setupOf
  (repeat' split) <;> first | rfl | omega

/-- A drain's class: the chunk and the cache growth at its offset. -/
structure DrainClass where
  C : Nat
  grow : Bool
  deriving DecidableEq

/-- **DRAIN-later classes**: from 256 rows every drain grows; 128 grows on even drains, 64 on every
fourth. -/
def drainClasses : List DrainClass :=
  [⟨2048, true⟩, ⟨1024, true⟩, ⟨512, true⟩, ⟨256, true⟩, ⟨128, true⟩, ⟨128, false⟩, ⟨64, true⟩, ⟨64, false⟩]

/-- The class of the `j`-th drain (`1 ≤ j`, `(j + 1)·C ≤ L - 1`). -/
def DrainClass.Applies (c : DrainClass) (L j : Nat) : Prop :=
  c.C = chunkC L ∧ 1 ≤ j ∧ (j + 1) * c.C ≤ L - 1 ∧ c.grow = decide ((j * c.C) % 256 = 0)

def drainOf (L j : Nat) : DrainClass := ⟨chunkC L, decide ((j * chunkC L) % 256 = 0)⟩

/-- A tail's class after at least one drain: the chunk, the row class, the growth at its offset. -/
structure TailClass where
  C : Nat
  X : Nat
  grow : Bool
  deriving DecidableEq

/-- **TAIL-later classes**: for each chunk size the row classes below it, with the growth (always
from 256 rows; both for 128 and 64). -/
def tailClasses : List TailClass :=
  chunkSizes.flatMap fun C => (rowClassesBelow C).flatMap fun X =>
    if 256 ≤ C then [⟨C, X, true⟩] else [⟨C, X, true⟩, ⟨C, X, false⟩]

def TailClass.Applies (c : TailClass) (L : Nat) : Prop :=
  c.C = chunkC L ∧ 1 ≤ drains L ∧ 1 ≤ tailRows L ∧ RowMem c.X (tailRows L) ∧
    c.grow = decide ((drains L * c.C) % 256 = 0)

def tailOf (L : Nat) : TailClass := ⟨chunkC L, rowClass (tailRows L), decide ((drains L * chunkC L) % 256 = 0)⟩

/-- **The first step's classes** (from the first `nextPrefillStep` call, `o = 0`, null caches):
DRAIN-first by chunk, TAIL-first by row class (`L ≤ 2048`, chunk 2048), FINAL-first (`L = 1`). -/
inductive FirstClass where
  | drain (C : Nat)
  | tail (X : Nat)
  | final
  deriving DecidableEq

def firstClasses : List FirstClass :=
  chunkSizes.map .drain ++ (List.range 37).map .tail ++ [.final]

def FirstClass.Applies : FirstClass → Nat → Prop
  | .drain C, L => C = chunkC L ∧ 1 ≤ drains L
  | .tail X, L => drains L = 0 ∧ 2 ≤ L ∧ RowMem X (L - 1)
  | .final, L => L = 1

def firstOf (L : Nat) : FirstClass :=
  if 1 ≤ drains L then .drain (chunkC L) else if 2 ≤ L then .tail (rowClass (L - 1)) else .final

/-- The KV branch of a one-row forward at offset `o ≥ 1`. -/
inductive KvBranch where
  | ord
  | fill
  | grow
  deriving DecidableEq

def kvOf (o : Nat) : KvBranch := if o % 256 = 0 then .grow else if o % 256 = 255 then .fill else .ord

/-- **FINAL classes** (the final D1 step from the pre-final cut `o = L - 1`): cold (`L = 1`, null
caches, untraced closures) or warmed with the KV branch at `L - 1`. -/
inductive FinalClass where
  | cold
  | warm (kv : KvBranch)
  deriving DecidableEq

def finalClasses : List FinalClass := [.cold, .warm .ord, .warm .fill, .warm .grow]

def FinalClass.Applies : FinalClass → Nat → Prop
  | .cold, L => L = 1
  | .warm kv, L => 2 ≤ L ∧ kv = kvOf (L - 1)

def finalOf (L : Nat) : FinalClass := if L = 1 then .cold else .warm (kvOf (L - 1))

/-- **POST classes**: the residue of `L` deciding the KV branches of iterations 0 (offset `L`) and 1
(offset `L + 1`): `0` (grow, ord), `255` (fill, grow), `254` (ord, fill), other (ord, ord). -/
inductive PostClass where
  | r0
  | r255
  | r254
  | other
  deriving DecidableEq

def postClasses : List PostClass := [.r0, .r255, .r254, .other]

def postOf (L : Nat) : PostClass :=
  if L % 256 = 0 then .r0 else if L % 256 = 255 then .r255 else if L % 256 = 254 then .r254 else .other

def PostClass.Applies (c : PostClass) (L : Nat) : Prop := c = postOf L

/-! ## The chain of classes of a length -/

/-- The classes of the chain of segments of a prompt of length `L`: SETUP; the first step; the
later drains `1 … k-1`; the later tail when there is one (`k ≥ 1`, `t ≥ 1`); FINAL; POST. -/
structure Chain where
  setup : SetupClass
  first : FirstClass
  later : Nat → DrainClass
  tail : Option TailClass
  final : FinalClass
  post : PostClass

/-- **The chain of classes** of `L`. -/
def chainOf (L : Nat) : Chain where
  setup := setupOf L
  first := firstOf L
  later j := drainOf L j
  tail := if 1 ≤ drains L ∧ 1 ≤ tailRows L then some (tailOf L) else none
  final := finalOf L
  post := postOf L

section Cover
variable {L : Nat}

theorem tailRows_lt (h2 : L ≤ 349525) : tailRows L < chunkC L := by
  unfold tailRows
  apply Nat.mod_lt
  rcases chunkC_cases h2 with h | h | h | h | h | h <;> rw [h] <;> decide

theorem chunkC_le (h2 : L ≤ 349525) : chunkC L ≤ 2048 := by
  rcases chunkC_cases h2 with h | h | h | h | h | h <;> omega

theorem drains_zero_le (h2 : L ≤ 349525) (h0 : drains L = 0) : L ≤ 2048 := by
  have e := drains_tail L
  rw [h0, Nat.zero_mul, Nat.zero_add] at e
  have := tailRows_lt h2
  have := chunkC_le h2
  omega

theorem setup_cover (h1 : 1 ≤ L) (h2 : L ≤ 349525) :
    setupOf L ∈ setupClasses ∧ (setupOf L).Applies L ∧ ∀ c : SetupClass, c.Applies L → c = setupOf L := by
  refine ⟨?_, ?_, ?_⟩
  · unfold setupOf; (repeat' split) <;> simp [setupClasses]
  · unfold setupOf; (repeat' split) <;> simp only [SetupClass.Applies] <;> omega
  · intro c hc
    unfold setupOf
    cases c <;> simp only [SetupClass.Applies] at hc <;> (repeat' split) <;> first | rfl | omega

theorem first_cover (h1 : 1 ≤ L) (h2 : L ≤ 349525) :
    firstOf L ∈ firstClasses ∧ (firstOf L).Applies L ∧ ∀ c : FirstClass, c.Applies L → c = firstOf L := by
  unfold firstOf
  by_cases hd : 1 ≤ drains L
  · rw [ite_eq_left hd]
    refine ⟨?_, ⟨rfl, hd⟩, ?_⟩
    · simp only [firstClasses, List.mem_append, List.mem_map]
      exact .inl (.inl ⟨_, chunkC_mem h2, rfl⟩)
    · intro c hc
      cases c with
      | drain C => obtain ⟨e, -⟩ := hc; rw [e]
      | tail X => exact absurd hc.1 (by omega)
      | final =>
        simp only [FirstClass.Applies] at hc
        subst hc
        simp [drains] at hd
  · rw [ite_eq_right hd]
    have h0 : drains L = 0 := by omega
    have hL := drains_zero_le h2 h0
    by_cases hL2 : 2 ≤ L
    · rw [ite_eq_left hL2]
      obtain ⟨hlt, hm, hu⟩ := rowClass_spec (t := L - 1) (by omega) (by omega)
      refine ⟨?_, ⟨h0, hL2, hm⟩, ?_⟩
      · simp only [firstClasses, List.mem_append, List.mem_map, List.mem_range]
        exact .inl (.inr ⟨_, hlt, rfl⟩)
      · intro c hc
        cases c with
        | drain C => exact absurd hc.2 (by omega)
        | tail X => rw [hu X hc.2.2]
        | final => simp only [FirstClass.Applies] at hc; omega
    · rw [ite_eq_right hL2]
      refine ⟨by simp [firstClasses], (show L = 1 by omega), ?_⟩
      intro c hc
      cases c with
      | drain C => exact absurd hc.2 (by omega)
      | tail X => exact absurd hc.2.1 hL2
      | final => rfl

theorem drain_cover (h2 : L ≤ 349525) {j : Nat} (hj1 : 1 ≤ j) (hjk : j + 1 ≤ drains L) :
    drainOf L j ∈ drainClasses ∧ (drainOf L j).Applies L j ∧ ∀ c : DrainClass, c.Applies L j → c = drainOf L j := by
  have e := drains_tail L
  have hle : (j + 1) * chunkC L ≤ L - 1 := by
    have := Nat.mul_le_mul_right (chunkC L) hjk
    omega
  refine ⟨?_, ⟨rfl, hj1, hle, rfl⟩, ?_⟩
  · unfold drainOf
    rcases chunkC_cases h2 with h | h | h | h | h | h <;> rw [h] <;> simp only [drainClasses]
    · rw [show decide ((j * 2048) % 256 = 0) = true from decide_eq_true (by omega)]; simp
    · rw [show decide ((j * 1024) % 256 = 0) = true from decide_eq_true (by omega)]; simp
    · rw [show decide ((j * 512) % 256 = 0) = true from decide_eq_true (by omega)]; simp
    · rw [show decide ((j * 256) % 256 = 0) = true from decide_eq_true (by omega)]; simp
    · cases decide ((j * 128) % 256 = 0) <;> simp
    · cases decide ((j * 64) % 256 = 0) <;> simp
  · rintro ⟨C, g⟩ ⟨hC, -, -, hg⟩
    simp only at hC hg
    subst hC
    rw [hg]
    rfl

theorem tail_cover (h2 : L ≤ 349525) (hd : 1 ≤ drains L) (ht : 1 ≤ tailRows L) :
    tailOf L ∈ tailClasses ∧ (tailOf L).Applies L ∧ ∀ c : TailClass, c.Applies L → c = tailOf L := by
  have htC := tailRows_lt h2
  have hC2 := chunkC_le h2
  obtain ⟨hlt, hm, hu⟩ := rowClass_spec (t := tailRows L) ht (by omega)
  refine ⟨?_, ⟨rfl, hd, ht, hm, rfl⟩, ?_⟩
  · have hX : rowClass (tailRows L) ∈ rowClassesBelow (chunkC L) := by
      obtain ⟨b, hb, hb1, -⟩ := hm
      simp only [rowClassesBelow, List.mem_filter, List.mem_range, hb, Nat.blt_eq]
      exact ⟨hlt, by omega⟩
    simp only [tailClasses, List.mem_flatMap]
    refine ⟨chunkC L, chunkC_mem h2, rowClass (tailRows L), hX, ?_⟩
    unfold tailOf
    by_cases h256 : 256 ≤ chunkC L
    · rw [ite_eq_left h256, show decide ((drains L * chunkC L) % 256 = 0) = true from
        decide_eq_true (drain_mod (chunkC_mem h2) h256)]
      simp
    · rw [ite_eq_right h256]
      cases decide ((drains L * chunkC L) % 256 = 0) <;> simp
  · rintro ⟨C, X, g⟩ ⟨hC, -, -, hX, hg⟩
    simp only at hC hX hg
    subst hC
    rw [hu X hX, hg]
    rfl

theorem final_cover (h1 : 1 ≤ L) :
    finalOf L ∈ finalClasses ∧ (finalOf L).Applies L ∧ ∀ c : FinalClass, c.Applies L → c = finalOf L := by
  unfold finalOf
  by_cases hL : L = 1
  · rw [ite_eq_left hL]
    refine ⟨by simp [finalClasses], hL, ?_⟩
    intro c hc
    cases c with
    | cold => rfl
    | warm kv => exact absurd hc.1 (by omega)
  · rw [ite_eq_right hL]
    refine ⟨?_, ⟨by omega, rfl⟩, ?_⟩
    · unfold kvOf; (repeat' split) <;> simp [finalClasses]
    · intro c hc
      cases c with
      | cold => exact absurd hc hL
      | warm kv => rw [hc.2]

theorem post_cover : postOf L ∈ postClasses ∧ (postOf L).Applies L ∧ ∀ c : PostClass, c.Applies L → c = postOf L := by
  refine ⟨?_, rfl, fun c hc => hc⟩
  unfold postOf; (repeat' split) <;> simp [postClasses]

end Cover

/-- **The class coverage.** Every length `L ∈ [1, 262143]` (hence every `L ≤ 262144 - T` with
`T ≥ 1`) falls in exactly one chain of classes: at each position of its chain (SETUP, the first
step, each later drain `1 ≤ j < k`, the later tail iff `k ≥ 1` and `t ≥ 1`, FINAL, POST) the
chain's class is one of the position's finitely many classes, applies there, and is the only class
that applies there. -/
theorem chain_cover (L : Nat) (h1 : 1 ≤ L) (h2 : L ≤ 262143) :
    ((chainOf L).setup ∈ setupClasses ∧ (chainOf L).setup.Applies L ∧
      ∀ x : SetupClass, x.Applies L → x = (chainOf L).setup) ∧
    ((chainOf L).first ∈ firstClasses ∧ (chainOf L).first.Applies L ∧
      ∀ x : FirstClass, x.Applies L → x = (chainOf L).first) ∧
    (∀ j, 1 ≤ j → j + 1 ≤ drains L → (chainOf L).later j ∈ drainClasses ∧ ((chainOf L).later j).Applies L j ∧
      ∀ x : DrainClass, x.Applies L j → x = (chainOf L).later j) ∧
    ((chainOf L).tail = none ↔ (drains L = 0 ∨ tailRows L = 0)) ∧
    (∀ d, (chainOf L).tail = some d → d ∈ tailClasses ∧ d.Applies L ∧ ∀ x : TailClass, x.Applies L → x = d) ∧
    ((chainOf L).final ∈ finalClasses ∧ (chainOf L).final.Applies L ∧
      ∀ x : FinalClass, x.Applies L → x = (chainOf L).final) ∧
    ((chainOf L).post ∈ postClasses ∧ (chainOf L).post.Applies L ∧
      ∀ x : PostClass, x.Applies L → x = (chainOf L).post) := by
  refine ⟨setup_cover h1 (by omega), first_cover h1 (by omega), fun j hj1 hjk => drain_cover (by omega) hj1 hjk,
    ?_, ?_, final_cover h1, post_cover⟩
  · show (if 1 ≤ drains L ∧ 1 ≤ tailRows L then some (tailOf L) else none) = none ↔ _
    by_cases h : 1 ≤ drains L ∧ 1 ≤ tailRows L
    · rw [ite_eq_left h]; simp only [reduceCtorEq, false_iff]; omega
    · rw [ite_eq_right h]; simp only [true_iff]; omega
  · intro d hd
    change (if 1 ≤ drains L ∧ 1 ≤ tailRows L then some (tailOf L) else none) = some d at hd
    by_cases h : 1 ≤ drains L ∧ 1 ≤ tailRows L
    · rw [ite_eq_left h] at hd
      cases hd
      exact tail_cover (by omega) h.1 h.2
    · rw [ite_eq_right h] at hd
      cases hd

/-- The template counts of the class lists: 7 SETUP, 44 first-step, 8 later-drain, 172 later-tail,
4 FINAL and 4 POST classes. -/
theorem class_counts : setupClasses.length = 7 ∧ firstClasses.length = 44 ∧ drainClasses.length = 8 ∧
    tailClasses.length = 172 ∧ finalClasses.length = 4 ∧ postClasses.length = 4 := by decide +kernel

end Host.Ts.Sim.Prefill

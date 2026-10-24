import metal.Steps
import metal.kernels.DownFold

namespace Metal.Tests.Steps
open Metal Metal.Core Inference.Contracts.Mlx

/-! # Steps tests

The library on real kernel shapes, with no step counts: DownFold's lane start and its
loop iteration across `simd_sum` (DownFold.lean's `lane_start` and `lane_next`), and
gatedRmsNorm's first loop as elaborated (nested counted loops, an accumulator at a
contraction site, a guarded load). -/

variable (C : M1Max.Contract)

namespace DownFold
open Metal.Kernels.DownFold

/-- A lane runs to its first `simd_sum`. -/
theorem lane_start (ctx : Ctx) (l s g : Nat) (h : Lane ctx l s g) (sh : Shared)
    (r0 : sh.regions 0 = some partialRegion) :
    ∃ t, (∃ n, ∀ m, n ≤ m → (runThread C m ⟨ctx, fun _ => none, [.block body], .running⟩).run sh =
      some (t, { sh with
        log := ((List.range 16).map fun i => entry ctx sh 0 (offset l s g + i) false).reverse ++ sh.log })) ∧
      AtSum ctx l s g (vals (sh.bytes 0) (offset l s g)) 0 t := by
  have hl := h.hl; have hs := h.hs; have hg := h.hg
  have hload := loadAt_run ctx (.vec .f32 4) ⟨0, ((offset l s g : Nat) : Int), .vec .f32 4⟩ partialRegion sh
    (.vec .f32 (vals (sh.bytes 0) (offset l s g))) r0 (by decide) (Int.natCast_nonneg _) (by decide)
    (by simp [loadOffset, partialRegion, alignment, Ty.bytes, Scalar.bytes, offset, col]; omega)
    (by simp [loadOffset, partialRegion, Ty.bytes, Scalar.bytes, offset, col]; omega)
    (by simp [loadOffset, partialRegion]; rfl)
  have hx : (vals (sh.bytes 0) (offset l s g))[0]? = some ((vals (sh.bytes 0) (offset l s g))[0]'(by simp [vals])) :=
    List.getElem?_eq_getElem _
  have hrun : Exec C ctx body (fun _ => none) sh _ _ _ :=
    .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_coord C _ _ _ _) <|
    .set (eval_col C _ _ l s g h _) <|
    .set ((eval_load C _ _ _ _ _ _ _ (eval_addr C _ _ l s g h sh rfl (by simp [setLocal, h.lane]) rfl)).trans hload) <|
    .set (eval_lit C _ _ _ _) <| .loop_stop (Kernels.DownFold.eval_cond C _ _ 0 (by decide) rfl _) <|
    .collective (Kernels.DownFold.eval_component C _ _ _ 0 _ (by decide) rfl rfl hx _) (eval_lit C _ _ _ _) rfl
  exact ⟨_, (hrun.reaches_stop (K := [])).run rfl,
    ⟨rfl, rfl, ⟨_, hx, rfl⟩, rfl, rfl, by simp [setLocal, h.lane], rfl, rfl, rfl⟩⟩

/-- A lane resumed after its `k`-th `simd_sum` runs to the next one: the rest of the body (lane 0
stores), the step, the test, and the next body's prefix. -/
theorem lane_next (ctx : Ctx) (l s g : Nat) (xs : List Val) (k : Nat) (t : Thread) (h : Lane ctx l s g)
    (ht : AtSum ctx l s g xs k t) (hk : k + 1 < 4) (hx : k + 1 < xs.length) (x : Float32) (sh : Shared)
    (r1 : sh.regions 1 = some outRegion) :
    ∃ t', (∃ n, ∀ m, n ≤ m → (runThread C m ({ t with status := .running }.set 6 (.f32 x))).run sh =
      some (t', afterStore ctx sh l s g k (C.narrow x))) ∧ AtSum ctx l s g xs (k + 1) t' := by
  have hl := h.hl; have hs := h.hs; have hg := h.hg
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨hc, hf, _, h0, h1, h2, h3, h4, h5⟩ := ht
  dsimp only at hc hf h0 h1 h2 h3 h4 h5
  subst hc hf
  have hy : xs[k + 1]? = some (xs[k + 1]'hx) := List.getElem?_eq_getElem _
  have hrest : Exec C tc [.set 7 (.local 6), iteStmt] (setLocal tl 6 (.f32 x)) sh .normal
      (setLocal (setLocal tl 6 (.f32 x)) 7 (.f32 x)) (afterStore tc sh l s g k (C.narrow x)) := by
    refine .set (eval_local C _ _ 6 (.f32 x) (by simp) _)
      (.ite (eval_lane0 C _ _ l hl (by simp [setLocal, h2]) _) ?_ (.nil _ _))
    by_cases hl0 : l = 0
    · subst hl0
      exact .store (eval_target C _ _ s g k hs hg (by omega) (by simp [setLocal, h1]) (by simp [setLocal, h3])
        (by simp [setLocal, h5]) _) (eval_narrow C _ _ x (by simp [setLocal]) _)
        (store_run _ s g k hs hg (by omega) _ _ r1) (.nil _ _)
    · simp only [hl0, decide_false, Bool.false_eq_true, ite_false, afterStore]
      exact .nil _ _
  have hc : ∀ (L : Locals) (sh' : Shared), L 5 = some (u32 (k + 1)) →
      (eval C tc L loopCond).run sh' = some (.bool true, sh') := by
    intro L sh' h5'
    rw [Kernels.DownFold.eval_cond C _ _ (k + 1) (by omega) h5' _]
    simp [hk]
  have hreach := Exec.resume_stop (st := loopStep) (b := loopBody) (ss := []) (K := []) hrest (.inl rfl)
    (.set (eval_incr C _ _ k (by omega) (by simp [setLocal, h5]) _) (.nil _ _)) (hc _ _ (by simp [setLocal]))
    (.collective (Kernels.DownFold.eval_component C _ _ xs (k + 1) _ (by omega) (by simp [setLocal, h4])
      (by simp [setLocal]) hy _) (eval_lit C _ _ _ _) rfl)
  exact ⟨_, hreach.run rfl, ⟨rfl, rfl, ⟨_, hy, rfl⟩, by simp [setLocal, h0], by simp [setLocal, h1],
    by simp [setLocal, h2], by simp [setLocal, h3], by simp [setLocal, h4], by simp [setLocal]⟩⟩

end DownFold

namespace GatedRmsNorm

/-! ## gatedRmsNorm's first loop

```
for (uint r = 0; r < uint(D); r += uint(THREADS) * 4u) {
  for (uint i = 0; i < 4u; ++i) {
    const uint col = r + tid * 4u + i;
    const float value = col < uint(D) ? float(x[row * uint(D) + col]) : 0.0f;
    acc += value * value;
  }
}
```
at D = 128, THREADS = 32: one outer iteration, four inner ones. -/

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)

def colE : CExpr := .bin .add .u32 0 (.bin .add .u32 0 (.local 10) (.bin .mul .u32 0 (.local 7) (u32l 4))) (.local 11)
def indexE : CExpr := .bin .add .u32 0 (.bin .mul .u32 0 (.local 4) (u32l 128)) (.local 12)
def valueE : CExpr :=
  .cond (.bin .lt .u32 0 (.local 12) (u32l 128)) (.conv .f32 (.load (.scalar .bf16) (.offset (.local 0) indexE)))
    (.lit (.f32 (Val.ofF32Bits 0)))
def accE : CExpr := .bin .add .f32 1 (.local 6) (.bin .mul .f32 0 (.local 13) (.local 13))
def innerBody : List CStmt := [.set 12 colE, .set 13 valueE, .set 6 accE]
def innerLoop : CStmt :=
  .loop (.bin .lt .u32 0 (.local 11) (u32l 4)) [.set 11 (.bin .add .u32 0 (.local 11) (u32l 1))] innerBody
def outerLoop : CStmt :=
  .loop (.bin .lt .u32 0 (.local 10) (u32l 128)) [.set 10 (.bin .add .u32 0 (.local 10) (u32l 128))]
    [.set 11 (u32l 0), innerLoop]

/-- Slots: 0 x, 4 row, 6 acc, 7 tid, 10 r, 11 i, 12 col, 13 value. -/
def firstLoop : List CStmt := [.set 10 (u32l 0), outerLoop]

-- In the elaborated kernel, `firstLoop` follows the ten declarations.
kernel_rfl firstLoop_eq :
  ((frontend Metal.Elab.Tests.gatedRmsNormText).bind elaborate).map (fun k => (k.body.drop 10).take 2) = some firstLoop

/-- `x`: `[1, 1, 48, 128]` bf16. -/
def xRegion : Region := ⟨.device, 12288, 16⟩

/-- Byte offset of `x[row * 128 + tid * 4 + k]`. -/
def xoff (row tid k : Nat) : Nat := (row * 128 + (tid * 4 + k)) * 2

/-- `float(x[row * 128 + tid * 4 + k])`. -/
def xval (memory : ByteMemory.Bytes) (row tid k : Nat) : Float32 :=
  C.widen (Val.ofBf16Bits (bytesWord ((List.range 2).map fun i => memory (xoff row tid k + i))))

/-- The lane's sum of squares after `k` columns, as the compiler's choice at site 1 computes it. -/
def acc (fuse : Bool) (memory : ByteMemory.Bytes) (row tid : Nat) : Nat → Float32
  | 0 => Val.ofF32Bits 0
  | k + 1 => if fuse then C.fma (xval C memory row tid k) (xval C memory row tid k) (acc fuse memory row tid k)
      else C.fadd (acc fuse memory row tid k) (C.fmul (xval C memory row tid k) (xval C memory row tid k))

/-- Memory after the lane's first `k` loads. -/
def loads (ctx : Ctx) (sh : Shared) (row tid : Nat) : Nat → Shared
  | 0 => sh
  | k + 1 =>
    let p := loads ctx sh row tid k
    { p with log := ((List.range 2).map fun i => entry ctx p 0 (xoff row tid k + i) false).reverse ++ p.log }

theorem loads_regions (ctx : Ctx) (sh : Shared) (row tid : Nat) : ∀ k, (loads ctx sh row tid k).regions = sh.regions
  | 0 => rfl
  | k + 1 => loads_regions ctx sh row tid k

theorem loads_bytes (ctx : Ctx) (sh : Shared) (row tid : Nat) : ∀ k, (loads ctx sh row tid k).bytes = sh.bytes
  | 0 => rfl
  | k + 1 => loads_bytes ctx sh row tid k

/-- The locals the loop reads and keeps. -/
structure Lane (row tid : Nat) (l : Locals) : Prop where
  x : l 0 = some (.ptr ⟨0, 0, .scalar .bf16⟩)
  row : l 4 = some (u32 row)
  tid : l 7 = some (u32 tid)

theorem Lane.set {row tid : Nat} {l : Locals} (h : Lane row tid l) {slot : Nat} (v : Val)
    (hs : slot ≠ 0 ∧ slot ≠ 4 ∧ slot ≠ 7) : Lane row tid (setLocal l slot v) :=
  ⟨by simp [setLocal, h.x, Ne.symm hs.1], by simp [setLocal, h.row, Ne.symm hs.2.1],
    by simp [setLocal, h.tid, Ne.symm hs.2.2]⟩

/-- At the `k`-th test of the inner loop. -/
def Inner (ctx : Ctx) (sh : Shared) (row tid k : Nat) (l : Locals) (sh' : Shared) : Prop :=
  Lane row tid l ∧ l 10 = some (u32 0) ∧ l 11 = some (u32 k) ∧
    l 6 = some (.f32 (acc C (ctx.fuse 1) (sh.bytes 0) row tid k)) ∧ sh' = loads ctx sh row tid k

/-- At the `j`-th test of the outer loop. -/
def Outer (ctx : Ctx) (sh : Shared) (row tid j : Nat) (l : Locals) (sh' : Shared) : Prop :=
  Lane row tid l ∧ l 10 = some (u32 (128 * j)) ∧
    l 6 = some (.f32 (acc C (ctx.fuse 1) (sh.bytes 0) row tid (4 * j))) ∧ sh' = loads ctx sh row tid (4 * j)

section
variable {ctx : Ctx} {row tid : Nat} {sh : Shared}

/-- One iteration of the inner body: column `k`'s value, loaded and squared into the sum. -/
theorem inner_body (hrow : row < 48) (htid : tid < 32) (r0 : sh.regions 0 = some xRegion) (k : Nat) (hk : k < 4)
    (l : Locals) (sh' : Shared) (hI : Inner C ctx sh row tid k l sh') :
    ∃ l₁, Exec C ctx innerBody l sh' .normal l₁ (loads ctx sh row tid (k + 1)) ∧ Lane row tid l₁ ∧
      l₁ 10 = some (u32 0) ∧ l₁ 11 = some (u32 k) ∧
      l₁ 6 = some (.f32 (acc C (ctx.fuse 1) (sh.bytes 0) row tid (k + 1))) := by
  obtain ⟨hl, h10, h11, h6, rfl⟩ := hI
  have hc : (eval C ctx l colE).run (loads ctx sh row tid k) = some (u32 (tid * 4 + k), loads ctx sh row tid k) := by
    have : (eval C ctx l colE).run (loads ctx sh row tid k) = some (u32 (0 + tid * 4 + k), loads ctx sh row tid k) :=
      eval_int C (by decide) (eval_int C (by decide) (eval_local' C h10 _)
        (eval_int C (by decide) (eval_local' C hl.tid _) (eval_lit C _ _ _ _) (binary_mul_u32 C tid 4))
        (binary_add_u32 C 0 (tid * 4))) (eval_local' C h11 _) (binary_add_u32 C (0 + tid * 4) k)
    rwa [Nat.zero_add] at this
  let l₁ := setLocal l 12 (u32 (tid * 4 + k))
  have hl₁ : Lane row tid l₁ := hl.set _ (by decide)
  have hidx : (eval C ctx l₁ indexE).run (loads ctx sh row tid k) =
      some (u32 (row * 128 + (tid * 4 + k)), loads ctx sh row tid k) :=
    eval_int C (by decide)
      (eval_int C (by decide) (eval_local' C hl₁.row _) (eval_lit C _ _ _ _) (binary_mul_u32 C row 128))
      (eval_local' C (setLocal_same _ _ _) _) (binary_add_u32 C (row * 128) (tid * 4 + k))
  have hptr : (eval C ctx l₁ (.offset (.local 0) indexE)).run (loads ctx sh row tid k) =
      some (.ptr ⟨0, ((xoff row tid k : Nat) : Int), .scalar .bf16⟩, loads ctx sh row tid k) := by
    have := eval_offset_u32 C (o := 0) (eval_local' C hl₁.x _) hidx (by omega)
    rwa [show 0 + (row * 128 + (tid * 4 + k)) * (Ty.scalar .bf16).bytes = xoff row tid k by
      simp [xoff, Ty.bytes, Scalar.bytes]] at this
  have hload := loadAt_run ctx (.scalar .bf16) ⟨0, ((xoff row tid k : Nat) : Int), .scalar .bf16⟩ xRegion
    (loads ctx sh row tid k)
    (.bf16 (Val.ofBf16Bits (bytesWord ((List.range 2).map fun i => sh.bytes 0 (xoff row tid k + i)))))
    (by rw [loads_regions]; exact r0) (by decide) (Int.natCast_nonneg _) (by decide)
    (by simp [loadOffset, xRegion, alignment, Scalar.bytes, xoff]; omega)
    (by simp [loadOffset, xRegion, Ty.bytes, Scalar.bytes, xoff]; omega)
    (by rw [loads_bytes]; simp [loadOffset, xRegion]; rfl)
  have htest : (eval C ctx l₁ (.bin .lt .u32 0 (.local 12) (u32l 128))).run (loads ctx sh row tid k) =
      some (.bool true, loads ctx sh row tid k) := by
    have h : (eval C ctx l₁ (.bin .lt .u32 0 (.local 12) (u32l 128))).run (loads ctx sh row tid k) =
        some (.bool (decide (tid * 4 + k < 128)), loads ctx sh row tid k) :=
      eval_int C (by decide) (eval_local' C (setLocal_same _ _ _) _) (eval_lit C _ _ _ _)
        (binary_lt_u32 C (tid * 4 + k) 128 (by omega) (by omega))
    rw [h, decide_eq_true (show tid * 4 + k < 128 by omega)]
  have hv : (eval C ctx l₁ valueE).run (loads ctx sh row tid k) =
      some (.f32 (xval C (sh.bytes 0) row tid k), loads ctx sh row tid (k + 1)) :=
    eval_cond C htest (eval_conv C ((eval_load C _ _ _ _ _ _ _ hptr).trans hload) rfl)
  let l₂ := setLocal l₁ 13 (.f32 (xval C (sh.bytes 0) row tid k))
  have hacc : (eval C ctx l₂ accE).run (loads ctx sh row tid (k + 1)) =
      some (.f32 (acc C (ctx.fuse 1) (sh.bytes 0) row tid (k + 1)), loads ctx sh row tid (k + 1)) :=
    eval_add_mul C rfl (eval_local' C (setLocal_same _ _ _) _) (eval_local' C (setLocal_same _ _ _) _)
      (eval_local' C (by simp [l₂, l₁, setLocal, h6]) _)
  refine ⟨_, .set hc (.set hv (.set hacc (.nil _ _))), (hl₁.set _ (by decide)).set _ (by decide), ?_, ?_, ?_⟩
  · simp [setLocal, h10]
  · simp [setLocal, h11]
  · simp [setLocal]

/-- The inner loop: four columns. -/
theorem inner_loop (hrow : row < 48) (htid : tid < 32) (r0 : sh.regions 0 = some xRegion) (l : Locals)
    (h0 : Inner C ctx sh row tid 0 l sh) :
    ∃ l' sh', Exec C ctx [innerLoop] l sh .normal l' sh' ∧ Inner C ctx sh row tid 4 l' sh' := by
  refine Exec.loop_count 4 (Inner C ctx sh row tid) (Inner C ctx sh row tid) (fun k hk l sh' hI => ⟨sh', ?_, hI⟩)
    (fun k hk l sh' hI => ?_) h0
  · exact eval_int C (by decide) (eval_local' C hI.2.2.1 _) (eval_lit C _ _ _ _)
      (binary_lt_u32 C k 4 (by omega) (by omega))
  · obtain ⟨l₁, hb, hl, h10, h11, h6⟩ := inner_body C hrow htid r0 k hk l sh' hI
    refine ⟨.normal, l₁, _, _, _, .inl rfl, hb,
      .set (eval_int C (by decide) (eval_local' C h11 _) (eval_lit C _ _ _ _) (binary_add_u32 C k 1)) (.nil _ _),
      hl.set _ (by decide), by simp [setLocal, h10], by simp [setLocal], by simp [setLocal, h6], rfl⟩

/-- **The first loop**: the lane's four columns of its row, squared and summed, with their
loads logged. -/
theorem first_loop (hrow : row < 48) (htid : tid < 32) (r0 : sh.regions 0 = some xRegion) (l : Locals)
    (hl : Lane row tid l) (h6 : l 6 = some (.f32 (Val.ofF32Bits 0))) :
    ∃ l', Exec C ctx firstLoop l sh .normal l' (loads ctx sh row tid 4) ∧ Lane row tid l' ∧
      l' 6 = some (.f32 (acc C (ctx.fuse 1) (sh.bytes 0) row tid 4)) := by
  have htest : ∀ j ≤ 1, ∀ l sh', Outer C ctx sh row tid j l sh' →
      ∃ sh₁, (eval C ctx l (.bin .lt .u32 0 (.local 10) (u32l 128))).run sh' = some (.bool (decide (j < 1)), sh₁) ∧
        Outer C ctx sh row tid j l sh₁ := by
    intro j hj l sh' hO
    have h : (eval C ctx l (.bin .lt .u32 0 (.local 10) (u32l 128))).run sh' =
        some (.bool (decide (128 * j < 128)), sh') :=
      eval_int C (by decide) (eval_local' C hO.2.1 _) (eval_lit C _ _ _ _)
        (binary_lt_u32 C (128 * j) 128 (by omega) (by omega))
    exact ⟨sh', by rw [h, show decide (128 * j < 128) = decide (j < 1) from decide_eq_decide.mpr (by omega)], hO⟩
  have hbody : ∀ j < 1, ∀ l sh', Outer C ctx sh row tid j l sh' → ∃ o l₁ sh₁ l₂ sh₂, (o = .normal ∨ o = .continue_) ∧
      Exec C ctx [.set 11 (u32l 0), innerLoop] l sh' o l₁ sh₁ ∧
      Exec C ctx [.set 10 (.bin .add .u32 0 (.local 10) (u32l 128))] l₁ sh₁ .normal l₂ sh₂ ∧
      Outer C ctx sh row tid (j + 1) l₂ sh₂ := by
    intro j hj l sh' hO
    obtain rfl : j = 0 := by omega
    obtain ⟨hl, h10, h6, rfl⟩ := hO
    obtain ⟨l₁, sh₁, hin, hl₁, h10', _, h6', rfl⟩ := inner_loop C hrow htid r0 (setLocal l 11 (.int .u32 0))
      ⟨hl.set _ (by decide), by simpa [setLocal] using h10, by simp [setLocal, u32], by simpa [setLocal] using h6, rfl⟩
    exact ⟨.normal, l₁, _, _, _, .inl rfl, .set (eval_lit C _ _ _ _) hin,
      .set (eval_int C (by decide) (eval_local' C h10' _) (eval_lit C _ _ _ _) (binary_add_u32 C 0 128)) (.nil _ _),
      hl₁.set _ (by decide), by simp [setLocal], by simpa [setLocal] using h6', rfl⟩
  obtain ⟨l', sh', hex, hl', _, h6', rfl⟩ := Exec.loop_count 1 (Outer C ctx sh row tid) (Outer C ctx sh row tid)
    htest hbody (l := setLocal l 10 (.int .u32 0)) (sh := sh)
    ⟨hl.set _ (by decide), by simp [setLocal, u32], by simpa [setLocal, acc] using h6, rfl⟩
  exact ⟨l', .set (eval_lit C _ _ _ _) hex, hl', h6'⟩

end

end GatedRmsNorm

end Metal.Tests.Steps

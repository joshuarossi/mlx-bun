import metal.Steps
import metal.Group
import metal.tests.Elab
import metal.Gpu
import metal.Memory
import metal.Fuel

namespace Metal.Kernels.ArgmaxFinish
open Metal Metal.Core Inference.Contracts.Mlx

/-! # normalized-argmax.ts finish

The header function is `better(x, xi, y, yi)`: `x > y || (x == y && xi < yi)`.

```
const uint tid = thread_position_in_threadgroup.x;
const uint lane = tid % 32, simd = tid / 32;
const uint row = threadgroup_position_in_grid.y;
float best = -INFINITY;
uint bestId = 0xffffffffu;
for (uint i = tid; i < P; i += 128) {
  float value = values[row * P + i];
  uint id = indices[row * P + i];
  if (better(value, id, best, bestId)) { best = value; bestId = id; }
}

for (uint distance = 16; distance > 0; distance >>= 1) {
  float other = simd_shuffle_down(best, distance);
  uint oi = simd_shuffle_down(bestId, distance);
  if (lane + distance < 32 && better(other, oi, best, bestId)) {
    best = other; bestId = oi;
  }
}
threadgroup float scores[4];
threadgroup uint ids[4];
if (lane == 0) { scores[simd] = best; ids[simd] = bestId; }
threadgroup_barrier(mem_flags::mem_threadgroup);
if (simd == 0) {
  best = lane < 4 ? scores[lane] : -INFINITY;
  bestId = lane < 4 ? ids[lane] : 0xffffffffu;
  for (uint distance = 2; distance > 0; distance >>= 1) {
    float other = simd_shuffle_down(best, distance);
    uint oi = simd_shuffle_down(bestId, distance);
    if (lane + distance < 4 && better(other, oi, best, bestId)) {
      best = other; bestId = oi;
    }
  }

  if (lane == 0) out[row] = bestId;
}
```
at `finishConfig`: grid [128, 1, 1], threadgroup [128, 1, 1], so one threadgroup of 4 SIMD-groups, with P = 243. -/

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)
def f32l (bits : Nat) : CExpr := .lit (.f32 (Val.ofF32Bits bits))

/-- The inlined `better(x, xi, y, yi)`: parameters in slots `x xi y yi`, result in slot `r`. -/
def better (x xi y yi r : Nat) : CStmt :=
  .scope
    [.set r (.or (.bin .gt .f32 0 (.local x) (.local y))
      (.and (.bin .eq .f32 0 (.local x) (.local y)) (.bin .lt .u32 0 (.local xi) (.local yi)))),
     .leave]

/-- `distance > 0` and `distance >>= 1` for the counter in slot `d`. -/
def gt0 (d : Nat) : CExpr := .bin .gt .u32 0 (.local d) (u32l 0)
def halve (d : Nat) : List CStmt := [.set d (.bin .shr .u32 0 (.local d) (u32l 1))]

def scanCond : CExpr := .bin .lt .u32 0 (.local 9) (u32l 243)
def scanStep : List CStmt := [.set 9 (.bin .add .u32 0 (.local 9) (u32l 128))]
def scanIndex : CExpr := .bin .add .u32 0 (.bin .mul .u32 0 (.local 6) (u32l 243)) (.local 9)
def scanTake : CStmt := .ite (.local 16) [.set 7 (.local 10), .set 8 (.local 11)] []
def scanBody : List CStmt :=
  [.set 10 (.load (.scalar .f32) (.offset (.local 0) scanIndex)),
   .set 11 (.load (.scalar .u32) (.offset (.local 1) scanIndex)),
   .set 12 (.local 10),
   .set 13 (.local 11),
   .set 14 (.local 7),
   .set 15 (.local 8),
   better 12 13 14 15 16,
   scanTake]

def shuffleCheck : CStmt :=
  .ite (.local 27)
    [.set 22 (.local 19), .set 23 (.local 21), .set 24 (.local 7), .set 25 (.local 8), better 22 23 24 25 26,
     .set 27 (.local 26)] []
def shuffleTake : CStmt := .ite (.local 27) [.set 7 (.local 19), .set 8 (.local 21)] []
def shuffleBody : List CStmt :=
  [.collective 1 18 .shuffleDown .f32 (.local 7) (.conv .u16 (.local 17)),
   .set 19 (.local 18),
   .collective 2 20 .shuffleDown .u32 (.local 8) (.conv .u16 (.local 17)),
   .set 21 (.local 20),
   .set 27 (.bin .lt .u32 0 (.bin .add .u32 0 (.local 4) (.local 17)) (u32l 32)),
   shuffleCheck,
   shuffleTake]

def publish : List CStmt :=
  [.store (.scalar .f32) (.offset (.local 28) (.local 5)) (.local 7),
   .store (.scalar .u32) (.offset (.local 29) (.local 5)) (.local 8)]

def mergeCheck : CStmt :=
  .ite (.local 40)
    [.set 35 (.local 32), .set 36 (.local 34), .set 37 (.local 7), .set 38 (.local 8), better 35 36 37 38 39,
     .set 40 (.local 39)] []
def mergeTake : CStmt := .ite (.local 40) [.set 7 (.local 32), .set 8 (.local 34)] []
def mergeBody : List CStmt :=
  [.collective 4 31 .shuffleDown .f32 (.local 7) (.conv .u16 (.local 30)),
   .set 32 (.local 31),
   .collective 5 33 .shuffleDown .u32 (.local 8) (.conv .u16 (.local 30)),
   .set 34 (.local 33),
   .set 40 (.bin .lt .u32 0 (.bin .add .u32 0 (.local 4) (.local 30)) (u32l 4)),
   mergeCheck,
   mergeTake]
def mergeLoop : CStmt := .loop (gt0 30) (halve 30) mergeBody
def outStore : CStmt :=
  .ite (.bin .eq .u32 0 (.local 4) (u32l 0)) [.store (.scalar .u32) (.offset (.local 2) (.local 6)) (.local 8)] []
def firstSimd : List CStmt :=
  [.set 7
     (.cond (.bin .lt .u32 0 (.local 4) (u32l 4)) (.load (.scalar .f32) (.offset (.local 28) (.local 4)))
       (f32l 0xFF800000)),
   .set 8
     (.cond (.bin .lt .u32 0 (.local 4) (u32l 4)) (.load (.scalar .u32) (.offset (.local 29) (.local 4)))
       (u32l 4294967295)),
   .set 30 (u32l 2),
   mergeLoop,
   outStore]

/-- Slots: 0 values, 1 indices, 2 out, 3 tid, 4 lane, 5 simd, 6 row, 7 best, 8 bestId, 9 i, 10 value, 11 id,
12 … 15 `better`'s `x xi y yi`, 16 its result, 17 distance, 18 the shuffled `best`, 19 other, 20 the shuffled
`bestId`, 21 oi, 22 … 25 `better`'s `x xi y yi`, 26 its result, 27 `lane + distance < 32 && better(…)`,
28 scores (threadgroup array 0), 29 ids (threadgroup array 1), 30 distance, 31 the shuffled `best`, 32 other,
33 the shuffled `bestId`, 34 oi, 35 … 38 `better`'s `x xi y yi`, 39 its result, 40 `lane + distance < 4 && better(…)`. -/
def body : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .f32⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .u32⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .u32⟩)),
   .set 3 (.component (.coord .threadPositionInThreadgroup) (u32l 0)),
   .set 4 (.bin .rem .u32 0 (.local 3) (u32l 32)),
   .set 5 (.bin .div .u32 0 (.local 3) (u32l 32)),
   .set 6 (.component (.coord .threadgroupPositionInGrid) (u32l 1)),
   .set 7 (f32l 0xFF800000),
   .set 8 (u32l 4294967295),
   .set 9 (.local 3),
   .loop scanCond scanStep scanBody,
   .set 17 (u32l 16),
   .loop (gt0 17) (halve 17) shuffleBody,
   .array 28 true 0 (.scalar .f32),
   .array 29 true 1 (.scalar .u32),
   .ite (.bin .eq .u32 0 (.local 4) (u32l 0)) publish [],
   .barrier 3 false true,
   .ite (.bin .eq .u32 0 (.local 5) (u32l 0)) firstSimd []]

def core : Kernel := ⟨3, [(.scalar .f32, 4), (.scalar .u32, 4)], [], body⟩

-- The elaborated text MLX compiles (tests/Assemble.lean) is `core`.
kernel_rfl compile_eq : (frontend Metal.Elab.Tests.argmaxFinishText).bind elaborate = some core


end Metal.Kernels.ArgmaxFinish

/-! # Argmax: the source-level specification, shared by the partial and finish kernels -/

namespace Metal.Kernels.Argmax
open Metal Metal.Core Inference.Contracts.Mlx

/-- A candidate: a score and its index. -/
abbrev Cand := Float32 × Nat

/-- `-INFINITY`, the binary32 word `0xFF800000`. -/
def negInf : Float32 := Val.ofF32Bits 0xFF800000

/-- `(-INFINITY, 0xffffffffu)`, the candidate every lane starts with. -/
def empty : Cand := (negInf, 0xffffffff)

/-- `x > y` as the hardware compares binary32 values (`f32Compare`: subnormals flushed; false when unordered). -/
def gtF (x y : Float32) : Bool := decide (f32Compare x y = some .gt)

/-- `x == y` as the hardware compares binary32 values. -/
def eqF (x y : Float32) : Bool := decide (f32Compare x y = some .eq)

/-- The header function `better(x, xi, y, yi)`: `x > y || (x == y && xi < yi)`. -/
def better (x : Float32) (xi : Nat) (y : Float32) (yi : Nat) : Bool := gtF x y || (eqF x y && decide (xi < yi))

/-- `if (better(v, best)) { best = v; }` -/
def pick (v c : Cand) : Cand := if better v.1 v.2 c.1 c.2 = true then v else c

/-- A lane's candidate after `k` iterations of `for (i = start; …; i += 128) if (better(v i, best)) best = v i;`. -/
def scan (v : Nat → Cand) (start : Nat) : Nat → Cand
  | 0 => empty
  | k + 1 => pick (v (start + 128 * k)) (scan v start k)

/-- The number of iterations of `for (i = start; i < bound; i += 128)`. -/
def count (start bound : Nat) : Nat := (bound - start + 127) / 128

/-- Lane `ln`'s step of a tree level at distance `d` and width `w`: with `o`, the candidate `simd_shuffle_down`
brings, `if (ln + d < w && better(o, c)) c = o;`. -/
def levelStep (w ln d : Nat) (o c : Cand) : Cand := if ln + d < w ∧ better o.1 o.2 c.1 c.2 = true then o else c

/-- A tree level: every lane steps with the candidate `d` lanes down (`shuffle`). -/
def level (w d : Nat) (c : Fin 32 → Cand) (i : Fin 32) : Cand := levelStep w i d (shuffle c d i) (c i)

/-- `for (distance = d₀; distance > 0; distance >>= 1)` at width `w`: the levels at distances `ds`. -/
def tree (w : Nat) : List Nat → (Fin 32 → Cand) → Fin 32 → Cand
  | [], c => c
  | d :: ds, c => tree w ds (level w d c)

theorem shuffle_bound (c : Fin 32 → Cand) (d : Nat) (i : Fin 32) (h : ∀ j, (c j).2 < 2 ^ 32) :
    (shuffle c d i).2 < 2 ^ 32 := by
  unfold shuffle; split <;> exact h _

theorem levelStep_bound (w ln d : Nat) (o c : Cand) (ho : o.2 < 2 ^ 32) (hc : c.2 < 2 ^ 32) :
    (levelStep w ln d o c).2 < 2 ^ 32 := by
  unfold levelStep; split <;> assumption

theorem pick_bound (v c : Cand) (hv : v.2 < 2 ^ 32) (hc : c.2 < 2 ^ 32) : (pick v c).2 < 2 ^ 32 := by
  unfold pick; split <;> assumption

theorem scan_bound (v : Nat → Cand) (start : Nat) (hv : ∀ i, (v i).2 < 2 ^ 32) : ∀ k, (scan v start k).2 < 2 ^ 32
  | 0 => by simp [scan, empty]
  | k + 1 => pick_bound _ _ (hv _) (scan_bound v start hv k)

/-- The test `start + 128 k < bound` of iteration `k` of the loop `count` counts. -/
theorem count_test (start bound k : Nat) (h : k ≤ count start bound) :
    decide (start + 128 * k < bound) = decide (k < count start bound) := by
  unfold count at *
  apply decide_eq_decide.mpr
  omega

/-! ## The inlined `better` and the shuffle trees in the core -/

variable (C : M1Max.Contract) {ctx : Ctx}

theorem binary_gt_f32 (x y : Float32) : binary C .gt .f32 (.f32 x) (.f32 y) = some (.bool (gtF x y)) := by
  simp only [binary, ordered_gt_some]; rfl

theorem binary_eq_f32 (x y : Float32) : binary C .eq .f32 (.f32 x) (.f32 y) = some (.bool (eqF x y)) := by
  simp only [binary, ordered_eq_some]; rfl

/-- The inlined `better(x, xi, y, yi)` sets slot `r` to `better`'s value. -/
theorem exec_better {x xi y yi r : Nat} {l : Locals} {sh : Shared} (a : Float32) (ai : Nat) (b : Float32) (bi : Nat)
    (hx : l x = some (.f32 a)) (hxi : l xi = some (u32 ai)) (hy : l y = some (.f32 b)) (hyi : l yi = some (u32 bi))
    (hai : ai < 2 ^ 32) (hbi : bi < 2 ^ 32) {ss : List CStmt} {o : Outcome} {l' : Locals} {sh' : Shared}
    (h : Exec C ctx ss (setLocal l r (.bool (better a ai b bi))) sh o l' sh') :
    Exec C ctx (ArgmaxFinish.better x xi y yi r :: ss) l sh o l' sh' := by
  have hgt : (eval C ctx l (.bin .gt .f32 0 (.local x) (.local y))).run sh = some (.bool (gtF a b), sh) :=
    eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_local C _ _ _ _ hx _) (eval_local C _ _ _ _ hy _)
      (binary_gt_f32 C a b)
  have heq : (eval C ctx l (.bin .eq .f32 0 (.local x) (.local y))).run sh = some (.bool (eqF a b), sh) :=
    eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_local C _ _ _ _ hx _) (eval_local C _ _ _ _ hy _)
      (binary_eq_f32 C a b)
  have hlt : (eval C ctx l (.bin .lt .u32 0 (.local xi) (.local yi))).run sh =
      some (.bool (decide (ai < bi)), sh) :=
    eval_int C (by decide) (eval_local C _ _ _ _ hxi _) (eval_local C _ _ _ _ hyi _) (binary_lt_u32 C ai bi hai hbi)
  have hv : (eval C ctx l (.or (.bin .gt .f32 0 (.local x) (.local y))
      (.and (.bin .eq .f32 0 (.local x) (.local y)) (.bin .lt .u32 0 (.local xi) (.local yi))))).run sh =
      some (.bool (better a ai b bi), sh) := by
    unfold better
    cases hg : gtF a b
    · rw [hg] at hgt
      cases he : eqF a b
      · rw [he] at heq; exact eval_or_false C hgt (eval_and_false C heq)
      · rw [he] at heq; exact eval_or_false C hgt (eval_and_true C heq hlt)
    · rw [hg] at hgt; exact eval_or_true C hgt
  exact .scope (.set hv .leave) (.inr rfl) h

/-- The slots of a shuffle tree: the sites of its two shuffles, `best`, `bestId`, `lane`, `distance`, the two
shuffled values and their copies (`other`, `oi`), `better`'s parameters and result, the guard, and the width. -/
structure Slots where
  sa : Nat
  sb : Nat
  best : Nat
  bestId : Nat
  lane : Nat
  dist : Nat
  ra : Nat
  oa : Nat
  rb : Nat
  ob : Nat
  x : Nat
  xi : Nat
  y : Nat
  yi : Nat
  r : Nat
  c : Nat
  width : Nat

def Slots.list (S : Slots) : List Nat :=
  [S.best, S.bestId, S.lane, S.dist, S.ra, S.oa, S.rb, S.ob, S.x, S.xi, S.y, S.yi, S.r, S.c]

/-- Distinct slots and a width within the SIMD-group. -/
def Slots.Ok (S : Slots) : Prop := S.list.Nodup ∧ S.width ≤ 32

instance (S : Slots) : Decidable S.Ok := by unfold Slots.Ok; infer_instance

/-- The slots a tree level writes. -/
def Slots.written (S : Slots) : List Nat :=
  [S.ra, S.oa, S.rb, S.ob, S.x, S.xi, S.y, S.yi, S.r, S.c, S.best, S.bestId, S.dist]

theorem Slots.Ok.ne {S : Slots} (h : S.Ok) : List.Pairwise (fun a b => a ≠ b ∧ b ≠ a) S.list :=
  List.Pairwise.imp (fun hab => ⟨hab, fun h => hab h.symm⟩) h.1

/-- `distance > 0`. -/
def treeTest (S : Slots) : CExpr := .bin .gt .u32 0 (.local S.dist) (.lit (.int .u32 0))
/-- `distance >>= 1`. -/
def treeStep (S : Slots) : List CStmt := [.set S.dist (.bin .shr .u32 0 (.local S.dist) (.lit (.int .u32 1)))]
/-- `better(other, oi, best, bestId)` when the guard's first conjunct holds. -/
def treeCheck (S : Slots) : CStmt :=
  .ite (.local S.c)
    [.set S.x (.local S.oa), .set S.xi (.local S.ob), .set S.y (.local S.best), .set S.yi (.local S.bestId),
     ArgmaxFinish.better S.x S.xi S.y S.yi S.r, .set S.c (.local S.r)] []
/-- `{ best = other; bestId = oi; }` -/
def treeTake (S : Slots) : CStmt := .ite (.local S.c) [.set S.best (.local S.oa), .set S.bestId (.local S.ob)] []
/-- The loop body after the second shuffle. -/
def treeC (S : Slots) : List CStmt :=
  [.set S.ob (.local S.rb),
   .set S.c (.bin .lt .u32 0 (.bin .add .u32 0 (.local S.lane) (.local S.dist)) (.lit (.int .u32 S.width))),
   treeCheck S, treeTake S]
/-- The loop body after the first shuffle. -/
def treeB (S : Slots) : List CStmt :=
  .set S.oa (.local S.ra) :: .collective S.sb S.rb .shuffleDown .u32 (.local S.bestId) (.conv .u16 (.local S.dist)) ::
    treeC S
/-- The loop body. -/
def treeBody (S : Slots) : List CStmt :=
  .collective S.sa S.ra .shuffleDown .f32 (.local S.best) (.conv .u16 (.local S.dist)) :: treeB S

end Metal.Kernels.Argmax

namespace Metal.Kernels.Argmax
open Metal Metal.Core Inference.Contracts.Mlx

section Tree
variable (C : M1Max.Contract) {ctx : Ctx} (S : Slots)

theorem eval_delta {l : Locals} {sh : Shared} {d : Nat} (hd : l S.dist = some (u32 d)) (h16 : d < 2 ^ 16) :
    (eval C ctx l (.conv .u16 (.local S.dist))).run sh = some (.int .u16 d, sh) :=
  eval_conv C (eval_local C _ _ _ _ hd _) (convert_u16_u32 C d h16)

/-- The level's first statement: the f32 shuffle of `best`. -/
theorem exec_collA {l : Locals} {sh : Shared} {b : Float32} {d : Nat} (hb : l S.best = some (.f32 b))
    (hd : l S.dist = some (u32 d)) (h16 : d < 2 ^ 16) :
    Exec C ctx (treeBody S) l sh (.stop (.collective S.sa S.ra .shuffleDown .f32 (.f32 b) d) [.block (treeB S)]) l sh :=
  .collective (eval_local C _ _ _ _ hb _) (eval_delta C S hd h16) (natOf_unsigned d rfl)

/-- `other = …`, then the u32 shuffle of `bestId`. -/
theorem exec_collB (hS : S.Ok) {l : Locals} {sh : Shared} {o : Float32} {bi d : Nat} (ho : l S.ra = some (.f32 o))
    (hbi : l S.bestId = some (u32 bi)) (hd : l S.dist = some (u32 d)) (h16 : d < 2 ^ 16) :
    Exec C ctx (treeB S) l sh (.stop (.collective S.sb S.rb .shuffleDown .u32 (u32 bi) d) [.block (treeC S)])
      (setLocal l S.oa (.f32 o)) sh := by
  have hp := hS.ne
  simp [Slots.list] at hp
  exact .set (eval_local C _ _ _ _ ho _) (.collective (eval_local C _ _ _ (u32 bi) (by simp [setLocal, hp, hbi]) _)
    (eval_delta C S (by simp [setLocal, hp, hd]) h16) (natOf_unsigned d rfl))

/-- `oi = …`, the guard, `better` and the take: the lane's candidate becomes `levelStep`. -/
theorem exec_treeC (hS : S.Ok) {l : Locals} {sh : Shared} (c o : Cand) {ln d : Nat}
    (hrb : l S.rb = some (u32 o.2)) (hoa : l S.oa = some (.f32 o.1)) (hb : l S.best = some (.f32 c.1))
    (hbi : l S.bestId = some (u32 c.2)) (hln : l S.lane = some (u32 ln)) (hd : l S.dist = some (u32 d))
    (hlnd : ln + d < 2 ^ 32) (hc2 : c.2 < 2 ^ 32) (ho2 : o.2 < 2 ^ 32) :
    ∃ l', Exec C ctx (treeC S) l sh .normal l' sh ∧ l' S.best = some (.f32 (levelStep S.width ln d o c).1) ∧
      l' S.bestId = some (u32 (levelStep S.width ln d o c).2) ∧ l' S.lane = some (u32 ln) ∧
      l' S.dist = some (u32 d) ∧
      ∀ P : Locals → Prop, (∀ l j v, P l → j ∈ S.written → P (setLocal l j v)) → P l → P l' := by
  have hp := hS.ne
  simp [Slots.list] at hp
  have hw : S.width < 2 ^ 32 := by have := hS.2; omega
  have hg : (eval C ctx (setLocal l S.ob (u32 o.2)) (.bin .lt .u32 0 (.bin .add .u32 0 (.local S.lane)
      (.local S.dist)) (.lit (.int .u32 S.width)))).run sh = some (.bool (decide (ln + d < S.width)), sh) := by
    have hl : (eval C ctx (setLocal l S.ob (u32 o.2)) (.lit (.int .u32 S.width))).run sh = some (u32 S.width, sh) := by
      rw [← u32_lit hw]; exact eval_lit C _ _ _ _
    exact eval_int C (by decide) (eval_int C (by decide) (eval_local C _ _ _ (u32 ln) (by simp [setLocal, hp, hln]) _)
      (eval_local C _ _ _ (u32 d) (by simp [setLocal, hp, hd]) _) (binary_add_u32 C ln d)) hl
      (binary_lt_u32 C (ln + d) S.width hlnd hw)
  have hW : ∀ j ∈ S.written, ∀ P : Locals → Prop, (∀ l j v, P l → j ∈ S.written → P (setLocal l j v)) →
      ∀ l v, P l → P (setLocal l j v) := fun j hj P hP l v h => hP l j v h hj
  have wob : S.ob ∈ S.written := by simp [Slots.written]
  have wc : S.c ∈ S.written := by simp [Slots.written]
  have wx : S.x ∈ S.written := by simp [Slots.written]
  have wxi : S.xi ∈ S.written := by simp [Slots.written]
  have wy : S.y ∈ S.written := by simp [Slots.written]
  have wyi : S.yi ∈ S.written := by simp [Slots.written]
  have wr : S.r ∈ S.written := by simp [Slots.written]
  have wb : S.best ∈ S.written := by simp [Slots.written]
  have wbi : S.bestId ∈ S.written := by simp [Slots.written]
  by_cases hgd : ln + d < S.width
  · rw [decide_eq_true hgd] at hg
    by_cases hbt : better o.1 o.2 c.1 c.2 = true
    · refine ⟨_, .set (eval_local C _ _ _ _ hrb _) (.set hg (.ite (eval_local C _ _ _ (.bool true) (by simp) _)
        (.set (eval_local C _ _ _ (.f32 o.1) (by simp [setLocal, hp, hoa]) _)
          (.set (eval_local C _ _ _ (u32 o.2) (by simp [setLocal, hp]) _)
            (.set (eval_local C _ _ _ (.f32 c.1) (by simp [setLocal, hp, hb]) _)
              (.set (eval_local C _ _ _ (u32 c.2) (by simp [setLocal, hp, hbi]) _)
                (exec_better C o.1 o.2 c.1 c.2 (by simp [setLocal, hp]) (by simp [setLocal, hp])
                  (by simp [setLocal, hp]) (by simp [setLocal]) ho2 hc2
                  (.set (eval_local C _ _ _ _ (setLocal_same _ _ _) _) (.nil _ _)))))))
        (.ite (eval_local C _ _ _ (.bool true) (by simp [hbt]) _)
          (.set (eval_local C _ _ _ (.f32 o.1) (by simp [setLocal, hp, hoa]) _)
            (.set (eval_local C _ _ _ (u32 o.2) (by simp [setLocal, hp]) _) (.nil _ _))) (.nil _ _)))),
        ?_, ?_, ?_, ?_, ?_⟩
      · simp [levelStep, hgd, hbt, setLocal, hp]
      · simp [levelStep, hgd, hbt, setLocal]
      · simp [setLocal, hp, hln]
      · simp [setLocal, hp, hd]
      · intro P hP h0
        exact hW _ wbi P hP _ _ (hW _ wb P hP _ _ (hW _ wc P hP _ _ (hW _ wr P hP _ _ (hW _ wyi P hP _ _
          (hW _ wy P hP _ _ (hW _ wxi P hP _ _ (hW _ wx P hP _ _ (hW _ wc P hP _ _ (hW _ wob P hP _ _ h0)))))))))
    · have hbf : better o.1 o.2 c.1 c.2 = false := by simpa using hbt
      refine ⟨_, .set (eval_local C _ _ _ _ hrb _) (.set hg (.ite (eval_local C _ _ _ (.bool true) (by simp) _)
        (.set (eval_local C _ _ _ (.f32 o.1) (by simp [setLocal, hp, hoa]) _)
          (.set (eval_local C _ _ _ (u32 o.2) (by simp [setLocal, hp]) _)
            (.set (eval_local C _ _ _ (.f32 c.1) (by simp [setLocal, hp, hb]) _)
              (.set (eval_local C _ _ _ (u32 c.2) (by simp [setLocal, hp, hbi]) _)
                (exec_better C o.1 o.2 c.1 c.2 (by simp [setLocal, hp]) (by simp [setLocal, hp])
                  (by simp [setLocal, hp]) (by simp [setLocal]) ho2 hc2
                  (.set (eval_local C _ _ _ _ (setLocal_same _ _ _) _) (.nil _ _)))))))
        (.ite (eval_local C _ _ _ (.bool false) (by simp [hbf]) _) (.nil _ _) (.nil _ _)))),
        ?_, ?_, ?_, ?_, ?_⟩
      · simp [levelStep, hbf, setLocal, hp, hb]
      · simp [levelStep, hbf, setLocal, hp, hbi]
      · simp [setLocal, hp, hln]
      · simp [setLocal, hp, hd]
      · intro P hP h0
        exact hW _ wc P hP _ _ (hW _ wr P hP _ _ (hW _ wyi P hP _ _
          (hW _ wy P hP _ _ (hW _ wxi P hP _ _ (hW _ wx P hP _ _ (hW _ wc P hP _ _ (hW _ wob P hP _ _ h0)))))))
  · rw [decide_eq_false hgd] at hg
    refine ⟨_, .set (eval_local C _ _ _ _ hrb _) (.set hg (.ite (eval_local C _ _ _ (.bool false) (by simp) _)
      (.nil _ _) (.ite (eval_local C _ _ _ (.bool false) (by simp) _) (.nil _ _) (.nil _ _)))), ?_, ?_, ?_, ?_, ?_⟩
    · simp [levelStep, hgd, setLocal, hp, hb]
    · simp [levelStep, hgd, setLocal, hp, hbi]
    · simp [setLocal, hp, hln]
    · simp [setLocal, hp, hd]
    · intro P hP h0
      exact hW _ wc P hP _ _ (hW _ wob P hP _ _ h0)

/-- `distance >>= 1`. -/
theorem exec_treeStep {l : Locals} {sh : Shared} {d : Nat} (hd : l S.dist = some (u32 d)) (h32 : d < 2 ^ 32) :
    Exec C ctx (treeStep S) l sh .normal (setLocal l S.dist (u32 (d / 2))) sh :=
  .set (eval_int C (by decide) (eval_local C _ _ _ _ hd _) (eval_lit C _ _ _ _)
    (by have h := binary_shr_u32 C d 1 h32 (by decide); rw [pow_one] at h; exact h)) (.nil _ _)

/-- `distance > 0`. -/
theorem eval_treeTest {l : Locals} {sh : Shared} {d : Nat} (hd : l S.dist = some (u32 d)) (h32 : d < 2 ^ 32) :
    (eval C ctx l (treeTest S)).run sh = some (.bool (decide (0 < d)), sh) :=
  eval_int C (by decide) (eval_local C _ _ _ _ hd _) (eval_lit C _ _ _ _) (binary_gt_u32 C d 0 h32 (by decide))

/-- A lane stopped at a tree level's f32 shuffle, with candidate `c` at distance `d`: the loop's frames above
`.block after :: K`, its locals in `F`. -/
structure AtA (after : List CStmt) (K : List Frame) (F : Locals → Prop) (ctx : Ctx) (ln : Nat) (c : Cand) (d : Nat)
    (t : Thread) : Prop where
  ctx : t.ctx = ctx
  frames : t.frames = .block (treeB S) :: .loop (treeTest S) (treeStep S) (treeBody S) :: .block after :: K
  status : t.status = .collective S.sa S.ra .shuffleDown .f32 (.f32 c.1) d
  frame : F t.locals
  best : t.locals S.best = some (.f32 c.1)
  bestId : t.locals S.bestId = some (u32 c.2)
  lane : t.locals S.lane = some (u32 ln)
  dist : t.locals S.dist = some (u32 d)
  bound : c.2 < 2 ^ 32

/-- A lane stopped at a tree level's u32 shuffle, holding `other = o`. -/
structure AtB (after : List CStmt) (K : List Frame) (F : Locals → Prop) (ctx : Ctx) (ln : Nat) (c : Cand) (o : Float32)
    (d : Nat) (t : Thread) : Prop where
  ctx : t.ctx = ctx
  frames : t.frames = .block (treeC S) :: .loop (treeTest S) (treeStep S) (treeBody S) :: .block after :: K
  status : t.status = .collective S.sb S.rb .shuffleDown .u32 (u32 c.2) d
  frame : F t.locals
  best : t.locals S.best = some (.f32 c.1)
  bestId : t.locals S.bestId = some (u32 c.2)
  lane : t.locals S.lane = some (u32 ln)
  dist : t.locals S.dist = some (u32 d)
  other : t.locals S.oa = some (.f32 o)
  bound : c.2 < 2 ^ 32

variable {S}

/-- Resumed from the f32 shuffle with `o`: on to the u32 shuffle. -/
theorem lane_A (hS : S.Ok) {after : List CStmt} {K : List Frame} {F : Locals → Prop}
    (hF : ∀ l j v, F l → j ∈ S.written → F (setLocal l j v)) {ln d : Nat} {c : Cand} {t : Thread} (h16 : d < 2 ^ 16)
    (ht : AtA S after K F ctx ln c d t) (o : Float32) (sh : Shared) :
    ∃ t', Reaches C ({ t with status := .running }.set S.ra (.f32 o)) sh t' sh ∧ AtB S after K F ctx ln c o d t' := by
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨hc, hf, -, hF0, hb, hbi, hln, hd, hc2⟩ := ht
  dsimp only at hc hf hF0 hb hbi hln hd
  subst hc hf
  have hp := hS.ne
  simp [Slots.list] at hp
  have hex := exec_collB C S hS (ctx := tc) (l := setLocal tl S.ra (.f32 o)) (sh := sh) (o := o) (bi := c.2) (d := d) (setLocal_same _ _ _)
    (by simp [setLocal, hp, hbi]) (by simp [setLocal, hp, hd]) h16
  exact ⟨_, hex.reaches_stop, ⟨rfl, rfl, rfl,
    hF _ _ _ (hF _ _ _ hF0 (by simp [Slots.written])) (by simp [Slots.written]),
    by simp [setLocal, hp, hb], by simp [setLocal, hp, hbi], by simp [setLocal, hp, hln], by simp [setLocal, hp, hd],
    by simp [setLocal], hc2⟩⟩

/-- Resumed from the u32 shuffle with `o`'s index, the level done and the distance still positive: on to the next
level's f32 shuffle. -/
theorem lane_B_next (hS : S.Ok) {after : List CStmt} {K : List Frame} {F : Locals → Prop}
    (hF : ∀ l j v, F l → j ∈ S.written → F (setLocal l j v)) {ln d : Nat} {c o : Cand} {t : Thread} (hln : ln < 32)
    (h16 : d < 2 ^ 16) (hd2 : 0 < d / 2) (ho2 : o.2 < 2 ^ 32) (ht : AtB S after K F ctx ln c o.1 d t) (sh : Shared) :
    ∃ t', Reaches C ({ t with status := .running }.set S.rb (u32 o.2)) sh t' sh ∧
      AtA S after K F ctx ln (levelStep S.width ln d o c) (d / 2) t' := by
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨hc, hf, -, hF0, hb, hbi, hln', hd, hoa, hc2⟩ := ht
  dsimp only at hc hf hF0 hb hbi hln' hd hoa
  subst hc hf
  have hp := hS.ne
  simp [Slots.list] at hp
  obtain ⟨l', hex, hb', hbi', hln'', hd', hfr⟩ := exec_treeC C S hS (ctx := tc) (l := setLocal tl S.rb (u32 o.2))
    (sh := sh) (ln := ln) (d := d) c o (setLocal_same _ _ _) (by simp [setLocal, hp, hoa]) (by simp [setLocal, hp, hb])
    (by simp [setLocal, hp, hbi]) (by simp [setLocal, hp, hln']) (by simp [setLocal, hp, hd]) (by omega) hc2 ho2
  have hst := exec_treeStep C S (ctx := tc) (sh := sh) hd' (by omega)
  have htest : (eval C tc (setLocal l' S.dist (u32 (d / 2))) (treeTest S)).run sh = some (.bool true, sh) := by
    rw [eval_treeTest C S (setLocal_same _ _ _) (by omega), decide_eq_true hd2]
  have hbody := exec_collA C S (ctx := tc) (l := setLocal l' S.dist (u32 (d / 2))) (sh := sh)
    (b := (levelStep S.width ln d o c).1) (by simp [setLocal, hp, hb']) (setLocal_same _ _ _) (by omega)
  have hwd : S.dist ∈ S.written := by simp [Slots.written]
  exact ⟨_, Exec.resume_stop hex (.inl rfl) hst htest hbody, ⟨rfl, rfl, rfl,
    hF _ _ _ (hfr F hF (hF _ _ _ hF0 (by simp [Slots.written]))) hwd,
    by simp [setLocal, hp, hb'], by simp [setLocal, hp, hbi'], by simp [setLocal, hp, hln''], by simp,
    levelStep_bound _ _ _ _ _ ho2 hc2⟩⟩

/-- Resumed from the u32 shuffle of the last level: the loop ends, on to `after`. -/
theorem lane_B_exit (hS : S.Ok) {after : List CStmt} {K : List Frame} {F : Locals → Prop}
    (hF : ∀ l j v, F l → j ∈ S.written → F (setLocal l j v)) {ln d : Nat} {c o : Cand} {t : Thread} (hln : ln < 32)
    (h16 : d < 2 ^ 16) (hd2 : d / 2 = 0) (ho2 : o.2 < 2 ^ 32) (ht : AtB S after K F ctx ln c o.1 d t) (sh : Shared) :
    ∃ l', Reaches C ({ t with status := .running }.set S.rb (u32 o.2)) sh ⟨ctx, l', .block after :: K, .running⟩ sh ∧
      F l' ∧ l' S.best = some (.f32 (levelStep S.width ln d o c).1) ∧
      l' S.bestId = some (u32 (levelStep S.width ln d o c).2) := by
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨hc, hf, -, hF0, hb, hbi, hln', hd, hoa, hc2⟩ := ht
  dsimp only at hc hf hF0 hb hbi hln' hd hoa
  subst hc hf
  have hp := hS.ne
  simp [Slots.list] at hp
  obtain ⟨l', hex, hb', hbi', -, hd', hfr⟩ := exec_treeC C S hS (ctx := tc) (l := setLocal tl S.rb (u32 o.2))
    (sh := sh) (ln := ln) (d := d) c o (setLocal_same _ _ _) (by simp [setLocal, hp, hoa]) (by simp [setLocal, hp, hb])
    (by simp [setLocal, hp, hbi]) (by simp [setLocal, hp, hln']) (by simp [setLocal, hp, hd]) (by omega) hc2 ho2
  have hst := exec_treeStep C S (ctx := tc) (sh := sh) hd' (by omega)
  have htest : (eval C tc (setLocal l' S.dist (u32 (d / 2))) (treeTest S)).run sh = some (.bool false, sh) := by
    rw [eval_treeTest C S (setLocal_same _ _ _) (by omega), hd2]; rfl
  have hwd : S.dist ∈ S.written := by simp [Slots.written]
  exact ⟨_, Exec.resume_exit hex (.inl rfl) hst htest, hF _ _ _ (hfr F hF (hF _ _ _ hF0 (by simp [Slots.written]))) hwd,
    by simp [setLocal, hp, hb'], by simp [setLocal, hp, hbi']⟩

variable (S)

/-- Lanes resumed from a level's f32 shuffle at distance `d`: lane `i` gets `(shuffle c d i).1`. -/
def resumeA (c : Fin 32 → Cand) (d : Nat) (U : Fin 32 → Thread) : List Thread :=
  List.ofFn fun i => { U i with status := .running }.set S.ra (.f32 (shuffle c d i).1)

theorem resumeA_eq (c : Fin 32 → Cand) (d : Nat) (U : Fin 32 → Thread) :
    (List.ofFn fun i => { U i with status := .running }.set S.ra (shuffle (fun j => Val.f32 (c j).1) d i)) =
      resumeA S c d U := by
  unfold resumeA; congr 1; funext i; exact congrArg _ (shuffle_map (fun x : Cand => Val.f32 x.1) c d i)

variable {S}

/-- A SIMD-group's round to the first level's f32 shuffle. -/
theorem simd_first {after : List CStmt} {K : List Frame} {F : Fin 32 → Locals → Prop} {ctxs : Fin 32 → Ctx}
    (c : Fin 32 → Cand) (d r : Nat) (T : Fin 32 → Thread) (I : Nat → Shared → Prop) (J : Shared → Prop)
    (R : Fin 32 → Thread → Prop)
    (h : ∀ i : Fin 32, ∀ sh, I i sh → ∃ t sh', (Ev fun m => (runThread C m (T i)).run sh = some (t, sh')) ∧
      I (i + 1) sh' ∧ AtA S after K (F i) (ctxs i) i (c i) d t)
    (hnext : ∀ (U : Fin 32 → Thread) (sh : Shared), (∀ i, AtA S after K (F i) (ctxs i) i (c i) d (U i)) → I 32 sh →
      ∃ (V : Fin 32 → Thread) (sh' : Shared),
        (Ev fun m => (runSimd C m r (resumeA S c d U)).run sh = some (List.ofFn V, sh')) ∧ J sh' ∧ ∀ i, R i (V i))
    (sh : Shared) (h0 : I 0 sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m (r + 1) (List.ofFn T)).run sh = some (List.ofFn V, sh')) ∧ J sh' ∧ ∀ i, R i (V i) := by
  refine runSimd_collective_ev C r T S.sa S.ra .shuffleDown .f32 d (fun i => .f32 (c i).1) _
    (resolve_shuffle C .f32 d _) I (fun i t => AtA S after K (F i) (ctxs i) i (c i) d t) J R
    (fun i sh hI => ?_) (fun U sh hU hI => ?_) sh h0
  · obtain ⟨t, sh', ht, hI', hA⟩ := h i sh hI
    exact ⟨t, sh', ht, hI', hA.status, hA⟩
  · obtain ⟨V, sh', hV, hJ, hR⟩ := hnext U sh hU hI
    refine ⟨V, sh', ?_, hJ, hR⟩
    rw [resumeA_eq]; exact hV

/-- A SIMD-group's two rounds through a level whose distance halves to a positive one. -/
theorem simd_level (hS : S.Ok) {after : List CStmt} {K : List Frame} {F : Fin 32 → Locals → Prop}
    (hF : ∀ i l j v, F i l → j ∈ S.written → F i (setLocal l j v)) {ctxs : Fin 32 → Ctx} (c : Fin 32 → Cand) (d : Nat)
    (h16 : d < 2 ^ 16) (hd2 : 0 < d / 2) (U : Fin 32 → Thread) (hU : ∀ i, AtA S after K (F i) (ctxs i) i (c i) d (U i))
    (r : Nat) (sh : Shared) (J : Shared → Prop) (R : Fin 32 → Thread → Prop)
    (hnext : ∀ W : Fin 32 → Thread, (∀ i, AtA S after K (F i) (ctxs i) i (level S.width d c i) (d / 2) (W i)) →
      ∃ (V : Fin 32 → Thread) (sh' : Shared),
        (Ev fun m => (runSimd C m r (resumeA S (level S.width d c) (d / 2) W)).run sh = some (List.ofFn V, sh')) ∧
        J sh' ∧ ∀ i, R i (V i)) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m (r + 2) (resumeA S c d U)).run sh = some (List.ofFn V, sh')) ∧ J sh' ∧ ∀ i, R i (V i) := by
  have hc2 : ∀ i, (c i).2 < 2 ^ 32 := fun i => (hU i).bound
  unfold resumeA
  refine runSimd_collective_ev C (r + 1) _ S.sb S.rb .shuffleDown .u32 d (fun i => u32 (c i).2) _
    (resolve_shuffle C .u32 d _) (fun _ s => s = sh)
    (fun i t => AtB S after K (F i) (ctxs i) i (c i) (shuffle c d i).1 d t) J R (fun i s hs => ?_)
    (fun U' s hU' hs => ?_) sh rfl
  · subst hs
    obtain ⟨t', hr, ht'⟩ := lane_A C hS (hF i) h16 (hU i) (shuffle c d i).1 s
    exact ⟨t', s, hr.ev_stop (by rw [ht'.status]; rfl), rfl, ht'.status, ht'⟩
  · subst hs
    refine runSimd_collective_ev C r _ S.sa S.ra .shuffleDown .f32 (d / 2) (fun i => .f32 (level S.width d c i).1) _
      (resolve_shuffle C .f32 (d / 2) _) (fun _ s' => s' = s)
      (fun i t => AtA S after K (F i) (ctxs i) i (level S.width d c i) (d / 2) t) J R (fun i s' hs' => ?_)
      (fun W s' hW hs' => ?_) s rfl
    · subst hs'
      obtain ⟨t', hr, ht'⟩ := lane_B_next C hS (hF i) (o := shuffle c d i) i.isLt h16 hd2
        (shuffle_bound c d i hc2) (hU' i) s'
      have e := hr.ev_stop (by rw [ht'.status]; rfl)
      rw [← shuffle_map (fun x : Cand => u32 x.2) c d i] at e
      exact ⟨t', s', e, rfl, ht'.status, ht'⟩
    · subst hs'
      obtain ⟨V, sh', hV, hJ, hR⟩ := hnext W hW
      refine ⟨V, sh', ?_, hJ, hR⟩
      rw [resumeA_eq]; exact hV

/-- A SIMD-group's two rounds through the last level: its f32 shuffle, its u32 shuffle, then `after` to a stop. -/
theorem simd_last (hS : S.Ok) {after : List CStmt} {K : List Frame} {F : Fin 32 → Locals → Prop}
    (hF : ∀ i l j v, F i l → j ∈ S.written → F i (setLocal l j v)) {ctxs : Fin 32 → Ctx} (c : Fin 32 → Cand) (d : Nat)
    (h16 : d < 2 ^ 16) (hd2 : d / 2 = 0) (U : Fin 32 → Thread) (hU : ∀ i, AtA S after K (F i) (ctxs i) i (c i) d (U i))
    (r : Nat) (sh : Shared) (I : Nat → Shared → Prop) (h0 : I 0 sh) (R : Fin 32 → Thread → Prop)
    (hafter : ∀ (i : Fin 32) (l : Locals), F i l → l S.best = some (.f32 (level S.width d c i).1) →
      l S.bestId = some (u32 (level S.width d c i).2) → (level S.width d c i).2 < 2 ^ 32 → ∀ sh', I i sh' → ∃ t sh'',
        (Ev fun m => (runThread C m ⟨ctxs i, l, .block after :: K, .running⟩).run sh' = some (t, sh'')) ∧
        I (i + 1) sh'' ∧ blocked t.status = true ∧ R i t) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m (r + 2) (resumeA S c d U)).run sh = some (List.ofFn V, sh')) ∧ I 32 sh' ∧
        ∀ i, R i (V i) := by
  have hc2 : ∀ i, (c i).2 < 2 ^ 32 := fun i => (hU i).bound
  unfold resumeA
  refine runSimd_collective_ev C (r + 1) _ S.sb S.rb .shuffleDown .u32 d (fun i => u32 (c i).2) _
    (resolve_shuffle C .u32 d _) (fun _ s => s = sh)
    (fun i t => AtB S after K (F i) (ctxs i) i (c i) (shuffle c d i).1 d t) (I 32) R (fun i s hs => ?_)
    (fun U' s hU' hs => ?_) sh rfl
  · subst hs
    obtain ⟨t', hr, ht'⟩ := lane_A C hS (hF i) h16 (hU i) (shuffle c d i).1 s
    exact ⟨t', s, hr.ev_stop (by rw [ht'.status]; rfl), rfl, ht'.status, ht'⟩
  · subst hs
    refine runSimd_blocked_ev C r _ I R (fun i s' hI => ?_) s h0
    obtain ⟨l', hr, hFl, hb, hbi⟩ := lane_B_exit C hS (hF i) (o := shuffle c d i) i.isLt h16 hd2
      (shuffle_bound c d i hc2) (hU' i) s'
    obtain ⟨t, sh'', he, hI', hbl, hR⟩ := hafter i l' hFl hb hbi
      (levelStep_bound _ _ _ _ _ (shuffle_bound c d i hc2) (hc2 i)) s' hI
    have e := hr.ev he
    rw [← shuffle_map (fun x : Cand => u32 x.2) c d i] at e
    exact ⟨t, sh'', e, hI', hbl, hR⟩

end Tree

end Metal.Kernels.Argmax

namespace Metal.Kernels.ArgmaxFinish
open Metal Metal.Core Inference.Contracts.Mlx Argmax

/-! ## The specification -/

/-- Element `i` of `values`: the binary32 value of its little-endian word. -/
def value (V : ByteMemory.Bytes) (i : Nat) : Float32 := Val.ofF32Bits (bytesWord (cells V (4 * i) 4))

/-- Element `i` of `indices`: its little-endian word. -/
def index (X : ByteMemory.Bytes) (i : Nat) : Nat := bytesWord (cells X (4 * i) 4)

/-- `(values[row * P + i], indices[row * P + i])` at `row = 0`. -/
def cand (V X : ByteMemory.Bytes) (i : Nat) : Cand := (value V i, index X i)

/-- Thread `tid`'s candidate after `for (uint i = tid; i < P; i += 128)`. -/
def laneBest (V X : ByteMemory.Bytes) (tid : Nat) : Cand := scan (cand V X) tid (count tid 243)

/-- SIMD-group `s`'s candidate: its lane 0's after the shuffle tree at distances 16, 8, 4, 2, 1. -/
def simdBest (V X : ByteMemory.Bytes) (s : Nat) : Cand := tree 32 [16, 8, 4, 2, 1] (fun i => laneBest V X (32 * s + i)) 0

/-- SIMD-group 0's lanes after the barrier: `lane < 4 ? (scores[lane], ids[lane]) : (-INFINITY, 0xffffffffu)`. -/
def merged (V X : ByteMemory.Bytes) (i : Fin 32) : Cand := if i.val < 4 then simdBest V X i else empty

/-- The threadgroup's candidate: SIMD-group 0's lane 0's after its tree at distances 2, 1. -/
def groupBest (V X : ByteMemory.Bytes) : Cand := tree 4 [2, 1] (merged V X) 0

/-- `out`: the bytes of `groupBest`'s index. -/
def expected (V X : ByteMemory.Bytes) (b : Nat) : BitVec 8 :=
  if b < 4 then (wordBytes 4 (groupBest V X).2).getD b 0 else 0

/-! ## Lanes -/

def shuffleSlots : Slots := ⟨1, 2, 7, 8, 4, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 32⟩
def mergeSlots : Slots := ⟨4, 5, 7, 8, 4, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 4⟩

theorem shuffleSlots_ok : shuffleSlots.Ok := by decide
theorem mergeSlots_ok : mergeSlots.Ok := by decide

/-- The body after the first tree. -/
def lastIte : CStmt := .ite (.bin .eq .u32 0 (.local 5) (u32l 0)) firstSimd []
def afterTree : List CStmt :=
  [.array 28 true 0 (.scalar .f32), .array 29 true 1 (.scalar .u32), .ite (.bin .eq .u32 0 (.local 4) (u32l 0)) publish [],
   .barrier 3 false true, lastIte]

def p0 : Val := .ptr ⟨0, 0, .scalar .f32⟩
def p1 : Val := .ptr ⟨1, 0, .scalar .u32⟩
def p2 : Val := .ptr ⟨2, 0, .scalar .u32⟩
def pScores : Val := .ptr ⟨3, 0, .scalar .f32⟩
def pIds : Val := .ptr ⟨4, 0, .scalar .u32⟩

/-- Lane `i` of SIMD-group `s` of the one threadgroup. -/
structure Lane (ctx : Ctx) (s i : Nat) : Prop where
  pos : ctx.coord .threadPositionInThreadgroup = u32x3 (32 * s + i) 0 0
  grid : ctx.coord .threadgroupPositionInGrid = u32x3 0 0 0
  thread : ctx.thread = 32 * s + i
  group : ctx.group = 0
  arrays : ∀ j, ctx.groupArray j = 3 + j
  hs : s < 4
  hi : i < 32

/-- The locals every phase keeps: the buffers, `lane`, `simd`, `row`. -/
structure Fixed (s i : Nat) (l : Locals) : Prop where
  l0 : l 0 = some p0
  l1 : l 1 = some p1
  l2 : l 2 = some p2
  l4 : l 4 = some (u32 i)
  l5 : l 5 = some (u32 s)
  l6 : l 6 = some (u32 0)

theorem Fixed.set {s i : Nat} {l : Locals} (h : Fixed s i l) {j : Nat} (v : Val) (hj : 6 < j) :
    Fixed s i (setLocal l j v) :=
  ⟨by rw [setLocal_other _ _ (by omega)]; exact h.l0, by rw [setLocal_other _ _ (by omega)]; exact h.l1,
    by rw [setLocal_other _ _ (by omega)]; exact h.l2, by rw [setLocal_other _ _ (by omega)]; exact h.l4,
    by rw [setLocal_other _ _ (by omega)]; exact h.l5, by rw [setLocal_other _ _ (by omega)]; exact h.l6⟩

theorem Fixed.of_eq {s i : Nat} {l l' : Locals} (h : Fixed s i l) (h' : ∀ j, j ≤ 6 → l' j = l j) : Fixed s i l' :=
  ⟨(h' 0 (by omega)).trans h.l0, (h' 1 (by omega)).trans h.l1, (h' 2 (by omega)).trans h.l2,
    (h' 4 (by omega)).trans h.l4, (h' 5 (by omega)).trans h.l5, (h' 6 (by omega)).trans h.l6⟩

/-- After the barrier: also the threadgroup arrays. -/
structure Fixed2 (s i : Nat) (l : Locals) : Prop where
  fixed : Fixed s i l
  l28 : l 28 = some pScores
  l29 : l 29 = some pIds

theorem Fixed2.set {s i : Nat} {l : Locals} (h : Fixed2 s i l) {j : Nat} (v : Val) (hj : 6 < j) (h28 : j ≠ 28)
    (h29 : j ≠ 29) : Fixed2 s i (setLocal l j v) :=
  ⟨h.fixed.set v hj, by rw [setLocal_other _ _ (by omega)]; exact h.l28, by rw [setLocal_other _ _ (by omega)]; exact h.l29⟩

theorem shuffle_frame (s : Nat) (i : Fin 32) :
    ∀ l j v, Fixed s i l → j ∈ shuffleSlots.written → Fixed s i (setLocal l j v) := by
  intro l j v h hj
  exact h.set v (by simp [Slots.written, shuffleSlots] at hj; omega)

theorem merge_frame (s : Nat) (i : Fin 32) :
    ∀ l j v, Fixed2 s i l → j ∈ mergeSlots.written → Fixed2 s i (setLocal l j v) := by
  intro l j v h hj
  simp [Slots.written, mergeSlots] at hj
  exact h.set v (by omega) (by omega) (by omega)

/-- The regions as the kernel uses them. -/
structure Regions (a0 a1 : Nat) (R : Nat → Option Region) : Prop where
  r0 : R 0 = some ⟨.device, 972, a0⟩
  r1 : R 1 = some ⟨.device, 972, a1⟩
  r2 : R 2 = some ⟨.device, 4, 16⟩
  r3 : R 3 = some ⟨.threadgroup, 16, 4⟩
  r4 : R 4 = some ⟨.threadgroup, 16, 4⟩
  a0 : a0 % 4 = 0
  a1 : a1 % 4 = 0

/-- The launch's accesses: reads of the inputs; lane 0 of SIMD-group `s` writing `scores[s]`, `ids[s]` before the
barrier, reads of them after; thread 0 writing `out`. -/
def Good (a : Access) : Prop :=
  ((a.region = 0 ∨ a.region = 1) ∧ a.write = false) ∨
  (a.region = 2 ∧ a.thread = 0 ∧ a.group = 0 ∧ a.deviceEpoch = 0) ∨
  ((a.region = 3 ∨ a.region = 4) ∧
    ((a.groupEpoch = 0 ∧ a.thread = 32 * (a.byte / 4)) ∨ (a.groupEpoch = 1 ∧ a.write = false)))

/-- SIMD-group `s`'s candidate in `scores[s]` and `ids[s]`. -/
def Pub (V X : ByteMemory.Bytes) (sh : Shared) (s : Nat) : Prop :=
  cells (sh.bytes 3) (4 * s) 4 = wordBytes 4 (Val.f32Bits (simdBest V X s).1) ∧
  cells (sh.bytes 4) (4 * s) 4 = wordBytes 4 (simdBest V X s).2

/-- Memory in the threadgroup's run: inputs intact, the epochs (`e` barriers passed), the log, SIMD-groups below
`j` published, and `out` once `done`. -/
structure Mem (R : Nat → Option Region) (V X : ByteMemory.Bytes) (e j : Nat) (done : Bool) (sh : Shared) : Prop where
  regions : sh.regions = R
  values : sh.bytes 0 = V
  indices : sh.bytes 1 = X
  device : sh.deviceEpoch = 0
  group : sh.groupEpoch = e
  log : ∀ a ∈ sh.log, Good a
  pub : ∀ s < j, Pub V X sh s
  out : done = true → cells (sh.bytes 2) 0 4 = wordBytes 4 (groupBest V X).2

section Lanes
variable (C : M1Max.Contract) {ctx : Ctx} {R : Nat → Option Region} {V X : ByteMemory.Bytes} {a0 a1 : Nat}

theorem Mem.read {e j : Nat} {done : Bool} {sh : Shared} (hm : Mem R V X e j done sh) (ctx : Ctx) (reg o n : Nat)
    (hg : ∀ b < n, Good (entry ctx sh reg (o + b) false)) :
    Mem R V X e j done { sh with log := ((List.range n).map fun b => entry ctx sh reg (o + b) false).reverse ++ sh.log } :=
  ⟨hm.regions, hm.values, hm.indices, hm.device, hm.group, forall_log _ n _ hg hm.log, hm.pub, hm.out⟩

/-- `values[i]` (with `row = 0`). -/
theorem eval_value (hR : Regions a0 a1 R) {e j : Nat} {done : Bool} {sh : Shared} (hm : Mem R V X e j done sh)
    {l : Locals} {n : Nat} (h0 : l 0 = some p0) (hi : (eval C ctx l scanIndex).run sh = some (u32 n, sh)) (hn : n < 243) :
    (eval C ctx l (.load (.scalar .f32) (.offset (.local 0) scanIndex))).run sh =
      some (.f32 (value V n), { sh with log := ((List.range 4).map fun b => entry ctx sh 0 (4 * n + b) false).reverse ++
        sh.log }) := by
  have hp := eval_ptr_u32 C (eval_local' C h0 sh) hi (by omega)
  rw [show n * (Ty.scalar .f32).bytes = 4 * n by simp [Ty.bytes, Scalar.bytes]; ring] at hp
  rw [eval_load C _ _ _ _ _ _ _ hp, loadAt_scalar ctx .f32 0 (4 * n) _ sh (by rw [hm.regions]; exact hR.r0) (by simp)
    (by simpa [Scalar.bytes] using hR.a0) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset]),
    hm.values]
  rfl

/-- `indices[i]` (with `row = 0`). -/
theorem eval_index (hR : Regions a0 a1 R) {e j : Nat} {done : Bool} {sh : Shared} (hm : Mem R V X e j done sh)
    {l : Locals} {n : Nat} (h1 : l 1 = some p1) (hi : (eval C ctx l scanIndex).run sh = some (u32 n, sh)) (hn : n < 243) :
    (eval C ctx l (.load (.scalar .u32) (.offset (.local 1) scanIndex))).run sh =
      some (u32 (index X n), { sh with log := ((List.range 4).map fun b => entry ctx sh 1 (4 * n + b) false).reverse ++
        sh.log }) := by
  have hp := eval_ptr_u32 C (eval_local' C h1 sh) hi (by omega)
  rw [show n * (Ty.scalar .u32).bytes = 4 * n by simp [Ty.bytes, Scalar.bytes]; ring] at hp
  rw [eval_load C _ _ _ _ _ _ _ hp, loadAt_scalar ctx .u32 1 (4 * n) _ sh (by rw [hm.regions]; exact hR.r1) (by simp)
    (by simpa [Scalar.bytes] using hR.a1) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset]),
    hm.indices]
  rfl

theorem eval_scanIndex {l : Locals} {sh : Shared} {n : Nat} (h6 : l 6 = some (u32 0)) (h9 : l 9 = some (u32 n)) :
    (eval C ctx l scanIndex).run sh = some (u32 n, sh) :=
  eval_bin_u32 C (eval_bin_u32 C (eval_local' C h6 sh) (eval_u32lit C l sh 243 (by decide)) (binary_mul_u32 C 0 243))
    (eval_local' C h9 sh) (by rw [binary_add_u32, Nat.zero_mul, Nat.zero_add])

/-- At the `k`-th test of the loop over `i`. -/
structure Scan (V X : ByteMemory.Bytes) (s i k : Nat) (l : Locals) : Prop where
  fixed : Fixed s i l
  l7 : l 7 = some (.f32 (scan (cand V X) (32 * s + i) k).1)
  l8 : l 8 = some (u32 (scan (cand V X) (32 * s + i) k).2)
  l9 : l 9 = some (u32 (32 * s + i + 128 * k))

theorem cand_bound (V X : ByteMemory.Bytes) (i : Nat) : (cand V X i).2 < 2 ^ 32 := bytesWord_cells_lt X (4 * i)

theorem good_read (ctx : Ctx) (sh : Shared) (reg o : Nat) (h : reg = 0 ∨ reg = 1) :
    ∀ b < 4, Good (entry ctx sh reg (o + b) false) := fun _ _ => Or.inl ⟨h, rfl⟩

/-- One iteration of the loop over `i`: the loads, `better`, the take, the step. -/
theorem scan_iter (hR : Regions a0 a1 R) {s i j : Nat} (hL : Lane ctx s i) (k : Nat) (hk : 32 * s + i + 128 * k < 243)
    {l : Locals} {sh : Shared} (hl : Scan V X s i k l) (hm : Mem R V X 0 j false sh) :
    ∃ l₁ sh₁ l₂, Exec C ctx scanBody l sh .normal l₁ sh₁ ∧ Exec C ctx scanStep l₁ sh₁ .normal l₂ sh₁ ∧
      Scan V X s i (k + 1) l₂ ∧ Mem R V X 0 j false sh₁ := by
  have hi := hL.hi
  have hs := hL.hs
  have hv := eval_value C (ctx := ctx) hR hm hl.fixed.l0 (eval_scanIndex C hl.fixed.l6 hl.l9) hk
  have hm1 := hm.read ctx 0 (4 * (32 * s + i + 128 * k)) 4 (good_read ctx sh 0 _ (.inl rfl))
  have hx := eval_index C (ctx := ctx) hR hm1 (l := setLocal l 10 (.f32 (value V (32 * s + i + 128 * k)))) (by simp [setLocal, hl.fixed.l1])
    (eval_scanIndex C (by simp [setLocal, hl.fixed.l6]) (by simp [setLocal, hl.l9])) hk
  have hm2 := hm1.read ctx 1 (4 * (32 * s + i + 128 * k)) 4 (good_read ctx _ 1 _ (.inr rfl))
  have hc2 := scan_bound (cand V X) (32 * s + i) (cand_bound V X) k
  have hb : ∀ (l' : Locals) (n : Nat) (sh' : Shared), l' 9 = some (u32 n) → n < 243 →
      Exec C ctx scanStep l' sh' .normal (setLocal l' 9 (u32 (n + 128))) sh' := fun l' n sh' h9 hn =>
    .set (eval_bin_u32 C (eval_local' C h9 _) (eval_u32lit C l' _ 128 (by decide)) (binary_add_u32 C n 128)) (.nil _ _)
  have e9 : 32 * s + i + 128 * (k + 1) = 32 * s + i + 128 * k + 128 := by ring
  by_cases hbt : Argmax.better (value V (32 * s + i + 128 * k)) (index X (32 * s + i + 128 * k))
      (scan (cand V X) (32 * s + i) k).1 (scan (cand V X) (32 * s + i) k).2 = true
  · refine ⟨_, _, _, .set hv (.set hx (.set (eval_local' C (v := .f32 (value V (32 * s + i + 128 * k))) (by simp [setLocal]) _)
      (.set (eval_local' C (v := u32 (index X (32 * s + i + 128 * k))) (by simp [setLocal]) _)
      (.set (eval_local' C (v := .f32 (scan (cand V X) (32 * s + i) k).1) (by simp [setLocal, hl.l7]) _)
      (.set (eval_local' C (v := u32 (scan (cand V X) (32 * s + i) k).2) (by simp [setLocal, hl.l8]) _)
      (exec_better C (value V (32 * s + i + 128 * k)) (index X (32 * s + i + 128 * k))
        (scan (cand V X) (32 * s + i) k).1 (scan (cand V X) (32 * s + i) k).2 (by simp [setLocal]) (by simp [setLocal]) (by simp [setLocal]) (by simp [setLocal])
        (bytesWord_cells_lt _ _) hc2
      (.ite (eval_local' C (v := .bool true) (by simp [setLocal, hbt]) _)
        (.set (eval_local' C (v := .f32 (value V (32 * s + i + 128 * k))) (by simp [setLocal]) _)
          (.set (eval_local' C (v := u32 (index X (32 * s + i + 128 * k))) (by simp [setLocal]) _) (.nil _ _)))
        (.nil _ _)))))))), hb _ (32 * s + i + 128 * k) _ (by simp [setLocal, hl.l9]) hk, ⟨?_, ?_, ?_, ?_⟩, hm2⟩
    · exact hl.fixed.of_eq (fun j hj => by simp (disch := omega) only [setLocal_lt])
    · have hsc : scan (cand V X) (32 * s + i) (k + 1) = cand V X (32 * s + i + 128 * k) := by
        simp only [Argmax.scan, Argmax.pick]; exact ite_eq_left hbt
      rw [hsc]; simp [setLocal, cand]
    · have hsc : scan (cand V X) (32 * s + i) (k + 1) = cand V X (32 * s + i + 128 * k) := by
        simp only [Argmax.scan, Argmax.pick]; exact ite_eq_left hbt
      rw [hsc]; simp [setLocal, cand]
    · rw [e9]; simp [setLocal]
  · have hbf : Argmax.better (value V (32 * s + i + 128 * k)) (index X (32 * s + i + 128 * k))
        (scan (cand V X) (32 * s + i) k).1 (scan (cand V X) (32 * s + i) k).2 = false := by simpa using hbt
    refine ⟨_, _, _, .set hv (.set hx (.set (eval_local' C (v := .f32 (value V (32 * s + i + 128 * k))) (by simp [setLocal]) _)
      (.set (eval_local' C (v := u32 (index X (32 * s + i + 128 * k))) (by simp [setLocal]) _)
      (.set (eval_local' C (v := .f32 (scan (cand V X) (32 * s + i) k).1) (by simp [setLocal, hl.l7]) _)
      (.set (eval_local' C (v := u32 (scan (cand V X) (32 * s + i) k).2) (by simp [setLocal, hl.l8]) _)
      (exec_better C (value V (32 * s + i + 128 * k)) (index X (32 * s + i + 128 * k))
        (scan (cand V X) (32 * s + i) k).1 (scan (cand V X) (32 * s + i) k).2 (by simp [setLocal]) (by simp [setLocal]) (by simp [setLocal]) (by simp [setLocal])
        (bytesWord_cells_lt _ _) hc2
      (.ite (eval_local' C (v := .bool false) (by simp [setLocal, hbf]) _) (.nil _ _) (.nil _ _)))))))),
      hb _ (32 * s + i + 128 * k) _ (by simp [setLocal, hl.l9]) hk, ⟨?_, ?_, ?_, ?_⟩, hm2⟩
    · exact hl.fixed.of_eq (fun j hj => by simp (disch := omega) only [setLocal_lt])
    · have hsc : scan (cand V X) (32 * s + i) (k + 1) = scan (cand V X) (32 * s + i) k := by
        simp only [Argmax.scan, Argmax.pick]; exact ite_eq_right (by simp only [cand]; rw [hbf]; decide)
      rw [hsc]; simp [setLocal, hl.l7]
    · have hsc : scan (cand V X) (32 * s + i) (k + 1) = scan (cand V X) (32 * s + i) k := by
        simp only [Argmax.scan, Argmax.pick]; exact ite_eq_right (by simp only [cand]; rw [hbf]; decide)
      rw [hsc]; simp [setLocal, hl.l8]
    · rw [e9]; simp [setLocal]


/-- The loop over `i`. -/
theorem scan_loop (hR : Regions a0 a1 R) {s i j : Nat} (hL : Lane ctx s i) {l : Locals} {sh : Shared}
    (hl : Scan V X s i 0 l) (hm : Mem R V X 0 j false sh) :
    ∃ l' sh', Exec C ctx [.loop scanCond scanStep scanBody] l sh .normal l' sh' ∧
      Scan V X s i (count (32 * s + i) 243) l' ∧ Mem R V X 0 j false sh' := by
  have hi := hL.hi
  have hs := hL.hs
  refine Exec.loop_count (count (32 * s + i) 243) (fun k l sh => Scan V X s i k l ∧ Mem R V X 0 j false sh)
    (fun k l sh => Scan V X s i k l ∧ Mem R V X 0 j false sh) (fun k hk l sh hI => ⟨sh, ?_, hI⟩)
    (fun k hk l sh hI => ?_) ⟨hl, hm⟩
  · have h := eval_lt_u32 C (ctx := ctx) (sh := sh) (b := 243) hI.1.l9 (by unfold count at hk; omega) (by decide)
    rw [count_test _ _ _ hk] at h
    exact h
  · obtain ⟨l₁, sh₁, l₂, hb, hst, hs', hm'⟩ := scan_iter C hR hL k (by unfold count at hk; omega) hI.1 hI.2
    exact ⟨.normal, l₁, sh₁, l₂, sh₁, .inl rfl, hb, hst, hs', hm'⟩

theorem eval_tid {s i : Nat} (hL : Lane ctx s i) (l : Locals) (sh : Shared) :
    (eval C ctx l (.component (.coord .threadPositionInThreadgroup) (u32l 0))).run sh = some (u32 (32 * s + i), sh) := by
  have hv : (eval C ctx l (.coord .threadPositionInThreadgroup)).run sh =
      some (.vec .u32 [u32 (32 * s + i), u32 0, u32 0], sh) := by
    rw [eval_coord, hL.pos]; rfl
  exact eval_component C hv (eval_lit C _ _ _ _) (natOf_unsigned 0 rfl) rfl

theorem eval_row {s i : Nat} (hL : Lane ctx s i) (l : Locals) (sh : Shared) :
    (eval C ctx l (.component (.coord .threadgroupPositionInGrid) (u32l 1))).run sh = some (u32 0, sh) := by
  have hv : (eval C ctx l (.coord .threadgroupPositionInGrid)).run sh = some (.vec .u32 [u32 0, u32 0, u32 0], sh) := by
    rw [eval_coord, hL.grid]; rfl
  exact eval_component C hv (eval_lit C _ _ _ _) (natOf_unsigned 1 rfl) rfl

/-- The locals after the declarations. -/
def start (s i : Nat) : Locals :=
  setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (fun _ => none)
    0 p0) 1 p1) 2 p2) 3 (u32 (32 * s + i))) 4 (u32 i)) 5 (u32 s)) 6 (u32 0)) 7 (.f32 negInf)) 8 (u32 0xffffffff))
    9 (u32 (32 * s + i))

/-- A lane runs from the start to the first shuffle, having scanned its elements. -/
theorem lane_start (hR : Regions a0 a1 R) {s i : Nat} (hL : Lane ctx s i) {sh : Shared} (hm : Mem R V X 0 s false sh) :
    ∃ t sh', (Ev fun m => (runThread C m ⟨ctx, fun _ => none, [.block body], .running⟩).run sh = some (t, sh')) ∧
      Mem R V X 0 s false sh' ∧ AtA shuffleSlots afterTree [] (Fixed s i) ctx i (laneBest V X (32 * s + i)) 16 t := by
  have hi := hL.hi
  have hs := hL.hs
  obtain ⟨l', sh', hscan, hS, hm'⟩ := scan_loop C hR hL (l := start s i) (sh := sh)
    ⟨⟨rfl, rfl, rfl, rfl, rfl, rfl⟩, rfl, rfl, by simp [start, setLocal]⟩ hm
  have h17 : setLocal l' 17 (.int .u32 16) 17 = some (u32 16) := rfl
  have hex : Exec C ctx body (fun _ => none) sh
      (.stop (.collective 1 18 .shuffleDown .f32 (.f32 (laneBest V X (32 * s + i)).1) 16)
        ([.block (treeB shuffleSlots)] ++ [.loop (gt0 17) (halve 17) shuffleBody, .block afterTree]))
      (setLocal l' 17 (.int .u32 16)) sh' :=
    .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_tid C hL _ _) <|
    .set (eval_bin_u32 C (eval_local' C (by rfl) _) (eval_u32lit C _ _ 32 (by decide))
      (by rw [binary_rem_u32 C _ 32 (by omega) (by decide) (by decide), show (32 * s + i) % 32 = i by omega])) <|
    .set (eval_bin_u32 C (eval_local' C (by rfl) _) (eval_u32lit C _ _ 32 (by decide))
      (by rw [binary_div_u32 C _ 32 (by omega) (by decide) (by decide), show (32 * s + i) / 32 = s by omega])) <|
    .set (eval_row C hL _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <|
    .set (eval_local' C (by rfl) _) <|
    Exec.append hscan <| .set (eval_lit C _ _ _ _) <|
      .loop_stop (eval_treeTest C shuffleSlots h17 (by decide))
        (exec_collA C shuffleSlots (by show setLocal l' 17 (.int .u32 16) 7 = _; rw [setLocal_lt _ (by omega)]; exact hS.l7) h17
          (by decide))
  refine ⟨_, sh', (hex.reaches_stop (K := [])).ev_stop rfl, hm', ⟨rfl, rfl, rfl, hS.fixed.set _ (by omega),
    by show setLocal l' 17 (.int .u32 16) 7 = _; rw [setLocal_lt _ (by omega)]; exact hS.l7,
    by show setLocal l' 17 (.int .u32 16) 8 = _; rw [setLocal_lt _ (by omega)]; exact hS.l8,
    by show setLocal l' 17 (.int .u32 16) 4 = _; rw [setLocal_lt _ (by omega)]; exact hS.fixed.l4, h17, scan_bound _ _ (cand_bound V X) _⟩⟩

theorem Mem.publish {s : Nat} {sh : Shared} (hm : Mem R V X 0 s false sh) (ctx : Ctx) (hth : ctx.thread = 32 * s) :
    Mem R V X 0 (s + 1) false (store4 ctx (store4 ctx sh 3 (4 * s) (wordBytes 4 (Val.f32Bits (simdBest V X s).1))) 4
      (4 * s) (wordBytes 4 (simdBest V X s).2)) := by
  have hl : ∀ w, (wordBytes 4 w).length = 4 := fun w => wordBytes_length 4 w
  refine ⟨hm.regions, by simp [store4, hm.values], by simp [store4, hm.indices], hm.device, hm.group, ?_, ?_,
    fun h => absurd h (by decide)⟩
  · refine forall_log _ 4 _ (fun b hb => Or.inr (Or.inr ⟨.inr rfl, .inl ⟨hm.group, ?_⟩⟩)) (forall_log _ 4 _
      (fun b hb => Or.inr (Or.inr ⟨.inl rfl, .inl ⟨hm.group, ?_⟩⟩)) hm.log)
    · simp only [entry, hth]; omega
    · simp only [entry, hth]; omega
  · intro s' hs'
    by_cases h : s' < s
    · obtain ⟨h3, h4⟩ := hm.pub s' h
      constructor
      · have h := cells_writeBytes_other (sh.bytes 3) (4 * s) (4 * s') 4 (wordBytes 4 (Val.f32Bits (simdBest V X s).1))
          (.inl (by omega))
        simpa [store4, h3] using h
      · have h := cells_writeBytes_other (sh.bytes 4) (4 * s) (4 * s') 4 (wordBytes 4 (simdBest V X s).2) (.inl (by omega))
        simpa [store4, h4] using h
    · obtain rfl : s' = s := by omega
      constructor
      · have h := cells_writeBytes_same (sh.bytes 3) (4 * s') (wordBytes 4 (Val.f32Bits (simdBest V X s').1))
        rw [hl] at h
        simpa [store4] using h
      · have h := cells_writeBytes_same (sh.bytes 4) (4 * s') (wordBytes 4 (simdBest V X s').2)
        rw [hl] at h
        simpa [store4] using h

/-- A lane at the barrier, for the second phase. -/
structure AtBar (ctx : Ctx) (s i : Nat) (t : Thread) : Prop where
  ctx : t.ctx = ctx
  frames : t.frames = [.block [lastIte]]
  fixed : Fixed2 s i t.locals

theorem simdBest_bound (V X : ByteMemory.Bytes) (s : Nat) : (simdBest V X s).2 < 2 ^ 32 := by
  have h : ∀ (w : Nat) (ds : List Nat) (c : Fin 32 → Cand), (∀ j, (c j).2 < 2 ^ 32) → ∀ j, (tree w ds c j).2 < 2 ^ 32 := by
    intro w ds
    induction ds with
    | nil => intro c hc j; exact hc j
    | cons d ds ih => intro c hc j; exact ih _ (fun j => levelStep_bound _ _ _ _ _ (shuffle_bound c d j hc) (hc j)) j
  exact h _ _ _ (fun j => scan_bound _ _ (cand_bound V X) _) 0

/-- After the last level of the first tree: lane 0 publishes, every lane stops at the barrier. -/
theorem lane_publish (hR : Regions a0 a1 R) {s : Nat} {i : Fin 32} (hL : Lane ctx s i) (c : Cand)
    (hc : i.val = 0 → c = simdBest V X s) (hc2 : c.2 < 2 ^ 32) {l : Locals} (hF : Fixed s i l)
    (h7 : l 7 = some (.f32 c.1)) (h8 : l 8 = some (u32 c.2)) {sh : Shared} (hm : Mem R V X 0 (s + min i.val 1) false sh) :
    ∃ t sh', (Ev fun m => (runThread C m ⟨ctx, l, [.block afterTree], .running⟩).run sh = some (t, sh')) ∧
      Mem R V X 0 (s + min (i.val + 1) 1) false sh' ∧ blocked t.status = true ∧
      t.status = .barrier 3 false true ∧ AtBar ctx s i t := by
  have hs := hL.hs
  let l₂ := setLocal (setLocal l 28 (.ptr ⟨if true then ctx.groupArray 0 else ctx.threadArray 0, 0, .scalar .f32⟩)) 29
    (.ptr ⟨if true then ctx.groupArray 1 else ctx.threadArray 1, 0, .scalar .u32⟩)
  have hF2 : Fixed2 s i l₂ := ⟨(hF.set _ (by omega)).set _ (by omega), by simp [l₂, setLocal, hL.arrays, pScores],
    by simp [l₂, hL.arrays, pIds]⟩
  have harr : ∀ (ss : List CStmt) (o : Outcome) (l' : Locals) (sh' : Shared), Exec C ctx ss l₂ sh o l' sh' →
      Exec C ctx (.array 28 true 0 (.scalar .f32) :: .array 29 true 1 (.scalar .u32) :: ss) l sh o l' sh' :=
    fun _ _ _ _ h => .array (.array h)
  by_cases h0 : i.val = 0
  · have hi0 : i = 0 := Fin.ext h0
    subst hi0
    obtain rfl := hc rfl
    have hm0 : Mem R V X 0 s false sh := by simpa using hm
    have hp3 : (eval C ctx l₂ (.offset (.local 28) (.local 5))).run sh =
        some (.ptr ⟨3, ((4 * s : Nat) : Int), .scalar .f32⟩, sh) := by
      have h := eval_ptr_u32 C (ctx := ctx) (eval_local' C hF2.l28 sh) (eval_local' C hF2.fixed.l5 sh) (by omega)
      rwa [show s * (Ty.scalar .f32).bytes = 4 * s by simp [Ty.bytes, Scalar.bytes]; ring] at h
    have hs3 := storeAt_scalar ctx .f32 3 (4 * s) _ sh _ _ (by rw [hm.regions]; exact hR.r3) (by simp) (by simp)
      (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (encode_f32 (simdBest V X s).1)
    let sh₁ := store4 ctx sh 3 (4 * s) (wordBytes 4 (Val.f32Bits (simdBest V X s).1))
    have hp4 : (eval C ctx l₂ (.offset (.local 29) (.local 5))).run sh₁ =
        some (.ptr ⟨4, ((4 * s : Nat) : Int), .scalar .u32⟩, sh₁) := by
      have h := eval_ptr_u32 C (ctx := ctx) (eval_local' C hF2.l29 sh₁) (eval_local' C hF2.fixed.l5 sh₁) (by omega)
      rwa [show s * (Ty.scalar .u32).bytes = 4 * s by simp [Ty.bytes, Scalar.bytes]; ring] at h
    have hs4 := storeAt_scalar ctx .u32 4 (4 * s) _ sh₁ _ _ (by simp only [sh₁, store4]; rw [hm.regions]; exact hR.r4)
      (by simp) (by simp) (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)
      (encode_u32 _ (simdBest_bound V X s))
    have hex : Exec C ctx afterTree l sh (.stop (.barrier 3 false true) [.block [lastIte]]) l₂
        (store4 ctx sh₁ 4 (4 * s) (wordBytes 4 (simdBest V X s).2)) :=
      harr _ _ _ _ (.ite (eval_eq_u32 C (a := 0) (by simpa using hF2.fixed.l4) (by decide) (by decide))
        (.store hp3 (eval_local' C (by simp [l₂, setLocal, h7]) _) hs3
          (.store hp4 (eval_local' C (by simp [l₂, setLocal, h8]) _) hs4 (.nil _ _))) .barrier)
    have hm1 : Mem R V X 0 (s + min ((0 : Fin 32).val + 1) 1) false
        (store4 ctx sh₁ 4 (4 * s) (wordBytes 4 (simdBest V X s).2)) := by
      rw [show s + min ((0 : Fin 32).val + 1) 1 = s + 1 by simp]
      exact hm0.publish ctx (by rw [hL.thread]; simp)
    exact ⟨_, _, (hex.reaches_stop (K := [])).ev_stop rfl, hm1, rfl, rfl, ⟨rfl, rfl, hF2⟩⟩
  · have hm' : Mem R V X 0 (s + min (i.val + 1) 1) false sh := by
      rwa [show min (i.val + 1) 1 = min i.val 1 by omega]
    have hex : Exec C ctx afterTree l sh (.stop (.barrier 3 false true) [.block [lastIte]]) l₂ sh :=
      harr _ _ _ _ (.ite (eval_eq_u32 C hF2.fixed.l4 (by omega) (by decide)) (by rw [decide_eq_false h0]; exact .nil _ _)
        .barrier)
    exact ⟨_, _, (hex.reaches_stop (K := [])).ev_stop rfl, hm', rfl, rfl, ⟨rfl, rfl, hF2⟩⟩

/-- `merged`'s indices fit a `uint`. -/
theorem merged_bound (V X : ByteMemory.Bytes) (i : Fin 32) : (merged V X i).2 < 2 ^ 32 := by
  unfold merged; split
  · exact simdBest_bound V X _
  · simp [empty]

theorem good_group_read (ctx : Ctx) (sh : Shared) (reg o : Nat) (h : reg = 3 ∨ reg = 4) (he : sh.groupEpoch = 1) :
    ∀ b < 4, Good (entry ctx sh reg (o + b) false) := fun _ _ => Or.inr (Or.inr ⟨h, .inr ⟨he, rfl⟩⟩)

/-- SIMD-group 0 after the barrier: on to the second tree's first shuffle, having read `scores` and `ids`. -/
theorem lane_merge_start (hR : Regions a0 a1 R) {i : Fin 32} (hL : Lane ctx 0 i) {t : Thread} (ht : AtBar ctx 0 i t)
    {sh : Shared} (hm : Mem R V X 1 4 false sh) :
    ∃ t' sh', (Ev fun m => (runThread C m { t with status := .running }).run sh = some (t', sh')) ∧
      Mem R V X 1 4 false sh' ∧ AtA mergeSlots [outStore] [.block []] (Fixed2 0 i) ctx i (merged V X i) 2 t' := by
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨hc, hf, hF⟩ := ht
  dsimp only at hc hf hF
  subst hc hf
  have hi := i.isLt
  have hsel : (eval C tc tl (.bin .eq .u32 0 (.local 5) (u32l 0))).run sh = some (.bool true, sh) :=
    eval_eq_u32 C hF.fixed.l5 (by decide) (by decide)
  have tail : ∀ (l : Locals) (sh' : Shared), Fixed2 0 i l → l 7 = some (.f32 (merged V X i).1) →
      l 8 = some (u32 (merged V X i).2) → Mem R V X 1 4 false sh' → Exec C tc firstSimd tl sh
        (.stop (.collective 4 31 .shuffleDown .f32 (.f32 (merged V X i).1) 2)
          ([.block (treeB mergeSlots)] ++ [.loop (gt0 30) (halve 30) mergeBody, .block [outStore]]))
        (setLocal l 30 (.int .u32 2)) sh' →
      ∃ t' sh'', (Ev fun m => (runThread C m ⟨tc, tl, [.block [lastIte]], .running⟩).run sh = some (t', sh'')) ∧
        Mem R V X 1 4 false sh'' ∧ AtA mergeSlots [outStore] [.block []] (Fixed2 0 i) tc i (merged V X i) 2 t' := by
    intro l sh' hl h7 h8 hm' hex
    refine ⟨_, sh', ((Exec.ite_stop hsel hex).reaches_stop (K := [])).ev_stop rfl, hm', ⟨rfl, rfl, rfl,
      hl.set _ (by omega) (by omega) (by omega),
      by show setLocal l 30 (.int .u32 2) 7 = _; rw [setLocal_lt _ (by omega)]; exact h7,
      by show setLocal l 30 (.int .u32 2) 8 = _; rw [setLocal_lt _ (by omega)]; exact h8,
      by show setLocal l 30 (.int .u32 2) 4 = _; rw [setLocal_lt _ (by omega)]; exact hl.fixed.l4, rfl,
      merged_bound V X i⟩⟩
  have h30 : ∀ l : Locals, setLocal l 30 (.int .u32 2) 30 = some (u32 2) := fun _ => rfl
  by_cases h4 : i.val < 4
  · have hc4 : ∀ (l : Locals) (sh' : Shared), l 4 = some (u32 i) →
        (eval C tc l (.bin .lt .u32 0 (.local 4) (u32l 4))).run sh' = some (.bool true, sh') := by
      intro l sh' h
      have e := eval_lt_u32 C (ctx := tc) (sh := sh') (b := 4) h (by omega) (by decide)
      rw [decide_eq_true h4] at e
      exact e
    have hp3 : (eval C tc tl (.offset (.local 28) (.local 4))).run sh =
        some (.ptr ⟨3, ((4 * i : Nat) : Int), .scalar .f32⟩, sh) := by
      have h := eval_ptr_u32 C (ctx := tc) (eval_local' C hF.l28 sh) (eval_local' C hF.fixed.l4 sh) (by omega)
      rwa [show i.val * (Ty.scalar .f32).bytes = 4 * i by simp [Ty.bytes, Scalar.bytes]; ring] at h
    have hl3 := loadAt_scalar tc .f32 3 (4 * i) _ sh (by rw [hm.regions]; exact hR.r3) (by simp) (by decide)
      (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset, Ty.bytes, Scalar.bytes])
    have hm1 := hm.read tc 3 (4 * i) 4 (good_group_read tc sh 3 _ (.inl rfl) hm.group)
    have hv3 : Val.ofWord .f32 (bytesWord (cells (sh.bytes 3) (4 * i) (Scalar.bytes .f32))) = .f32 (merged V X i).1 := by
      have hm4 : merged V X i = simdBest V X i := by simp [merged, h4]
      rw [show Scalar.bytes .f32 = 4 from rfl, (hm.pub i h4).1, ofWord_f32, hm4]
    rw [hv3] at hl3
    let sh₁ := { sh with log := ((List.range 4).map fun b => entry tc sh 3 (4 * i + b) false).reverse ++ sh.log }
    have hp4 : (eval C tc (setLocal tl 7 (.f32 (merged V X i).1)) (.offset (.local 29) (.local 4))).run sh₁ =
        some (.ptr ⟨4, ((4 * i : Nat) : Int), .scalar .u32⟩, sh₁) := by
      have h := eval_ptr_u32 C (ctx := tc) (l := setLocal tl 7 (.f32 (merged V X i).1)) (eval_local' C (i := 29) (v := pIds) (by simp [setLocal, hF.l29]) sh₁)
        (eval_local' C (i := 4) (v := u32 i) (by simp [setLocal, hF.fixed.l4]) sh₁) (by omega)
      rwa [show i.val * (Ty.scalar .u32).bytes = 4 * i by simp [Ty.bytes, Scalar.bytes]; ring] at h
    have hl4 := loadAt_scalar tc .u32 4 (4 * i) _ sh₁ (by simp only [sh₁]; rw [hm.regions]; exact hR.r4) (by simp)
      (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset, Ty.bytes, Scalar.bytes])
    have hm2 := hm1.read tc 4 (4 * i) 4 (good_group_read tc sh₁ 4 _ (.inr rfl) hm.group)
    have hv4 : Val.ofWord .u32 (bytesWord (cells (sh₁.bytes 4) (4 * i) (Scalar.bytes .u32))) = u32 (merged V X i).2 := by
      have hm4 : merged V X i = simdBest V X i := by simp [merged, h4]
      rw [show Scalar.bytes .u32 = 4 from rfl, show sh₁.bytes = sh.bytes from rfl, (hm.pub i h4).2, ofWord_u32, hm4]
    rw [hv4] at hl4
    exact tail _ _ ((hF.set _ (by omega) (by omega) (by omega)).set _ (by omega) (by omega) (by omega))
      (by simp [setLocal]) (by simp [setLocal]) hm2
      (.set (eval_cond C (hc4 _ _ hF.fixed.l4) ((eval_load C _ _ _ _ _ _ _ hp3).trans hl3)) <|
        .set (eval_cond C (hc4 _ _ (by simp [setLocal, hF.fixed.l4]))
          ((eval_load C _ _ _ _ _ _ _ hp4).trans hl4)) <|
        .set (eval_lit C _ _ _ _) <| .loop_stop (eval_treeTest C mergeSlots (h30 _) (by decide))
          (exec_collA C mergeSlots (by simp [setLocal, mergeSlots]) (h30 _) (by decide)))
  · have hc4 : ∀ (l : Locals) (sh' : Shared), l 4 = some (u32 i) →
        (eval C tc l (.bin .lt .u32 0 (.local 4) (u32l 4))).run sh' = some (.bool false, sh') := by
      intro l sh' h
      have e := eval_lt_u32 C (ctx := tc) (sh := sh') (b := 4) h (by omega) (by decide)
      rw [decide_eq_false h4] at e
      exact e
    have hme : merged V X i = empty := by simp [merged, h4]
    rw [hme]
    rw [hme] at tail
    exact tail _ _ ((hF.set _ (by omega) (by omega) (by omega)).set _ (by omega) (by omega) (by omega))
      (by simp [setLocal]; rfl) (by simp [setLocal]; rfl) hm
      (.set (eval_cond C (hc4 _ _ hF.fixed.l4) (eval_lit C _ _ _ _)) <|
        .set (eval_cond C (hc4 _ _ (by simp [setLocal, hF.fixed.l4])) (eval_lit C _ _ _ _)) <|
        .set (eval_lit C _ _ _ _) <| .loop_stop (eval_treeTest C mergeSlots (h30 _) (by decide))
          (exec_collA C mergeSlots (by simp [setLocal, mergeSlots]; rfl) (h30 _) (by decide)))

/-- After the second tree: lane 0 writes `out`, every lane ends. -/
theorem lane_out (hR : Regions a0 a1 R) {i : Fin 32} (hL : Lane ctx 0 i) (c : Cand) (hc : i.val = 0 → c = groupBest V X)
    (hc2 : c.2 < 2 ^ 32) {l : Locals} (hF : Fixed2 0 i l) (h8 : l 8 = some (u32 c.2)) {sh : Shared}
    (hm : Mem R V X 1 4 (decide (0 < i.val)) sh) :
    ∃ t sh', (Ev fun m => (runThread C m ⟨ctx, l, [.block [outStore], .block []], .running⟩).run sh = some (t, sh')) ∧
      Mem R V X 1 4 (decide (0 < i.val + 1)) sh' ∧ blocked t.status = true ∧ t.status = .done := by
  have hdone : ∀ sh', Exec C ctx [outStore] l sh .normal l sh' →
      Ev fun m => (runThread C m ⟨ctx, l, [.block [outStore], .block []], .running⟩).run sh = some (⟨ctx, l, [], .done⟩, sh') :=
    fun sh' h => ((h.reaches_normal (K := [.block []])).trans (Exec.nil l sh').reaches_done).ev_stop rfl
  by_cases h0 : i.val = 0
  · obtain rfl := hc h0
    have hp : (eval C ctx l (.offset (.local 2) (.local 6))).run sh = some (.ptr ⟨2, ((0 : Nat) : Int), .scalar .u32⟩, sh) := by
      have h := eval_ptr_u32 C (ctx := ctx) (eval_local' C hF.fixed.l2 sh) (eval_local' C hF.fixed.l6 sh) (by decide)
      simpa using h
    have hs := storeAt_scalar ctx .u32 2 0 _ sh _ _ (by rw [hm.regions]; exact hR.r2) (by simp) (by simp) (by decide)
      (by decide) (by decide) (encode_u32 _ hc2)
    have hex : Exec C ctx [outStore] l sh .normal l (store4 ctx sh 2 0 (wordBytes 4 (groupBest V X).2)) :=
      .ite (eval_eq_u32 C hF.fixed.l4 (by omega) (by decide)) (by
        rw [decide_eq_true h0]
        exact .store hp (eval_local' C h8 _) hs (.nil _ _)) (.nil _ _)
    refine ⟨_, _, hdone _ hex, ⟨hm.regions, by simp [store4, hm.values], by simp [store4, hm.indices], hm.device,
      hm.group, ?_, fun s hs => ?_, fun _ => ?_⟩, rfl, rfl⟩
    · refine forall_log _ 4 _ (fun b hb => Or.inr (Or.inl ⟨rfl, ?_, hL.group, hm.device⟩)) hm.log
      simp [entry, hL.thread, h0]
    · obtain ⟨h3, h4⟩ := hm.pub s hs
      exact ⟨by simpa [store4] using h3, by simpa [store4] using h4⟩
    · have h := cells_writeBytes_same (sh.bytes 2) 0 (wordBytes 4 (groupBest V X).2)
      rw [wordBytes_length] at h
      simpa [store4] using h
  · have hex : Exec C ctx [outStore] l sh .normal l sh :=
      .ite (eval_eq_u32 C hF.fixed.l4 (by omega) (by decide)) (by rw [decide_eq_false h0]; exact .nil _ _) (.nil _ _)
    exact ⟨_, _, hdone _ hex, ⟨hm.regions, hm.values, hm.indices, hm.device, hm.group, hm.log, hm.pub,
      fun _ => hm.out (by simp; omega)⟩, rfl, rfl⟩

/-- SIMD-groups 1 … 3 after the barrier: they end. -/
theorem lane_skip {s : Nat} {i : Fin 32} (hs : s ≠ 0) (hs4 : s < 4) {t : Thread} (ht : AtBar ctx s i t) (sh : Shared) :
    ∃ t', (Ev fun m => (runThread C m { t with status := .running }).run sh = some (t', sh)) ∧ t'.status = .done := by
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨hc, hf, hF⟩ := ht
  dsimp only at hc hf hF
  subst hc hf
  have hex : Exec C tc [lastIte] tl sh .normal tl sh :=
    .ite (eval_eq_u32 C hF.fixed.l5 (by omega) (by decide)) (by rw [decide_eq_false hs]; exact .nil _ _) (.nil _ _)
  exact ⟨_, hex.reaches_done.ev_stop rfl, rfl⟩

end Lanes

/-! ## SIMD-groups, the threadgroup, the launch -/

section Groups
variable (C : M1Max.Contract) {R : Nat → Option Region} {V X : ByteMemory.Bytes} {a0 a1 : Nat}

/-- SIMD-group `s` up to the barrier: the scan, the shuffle tree, lane 0's `scores[s]` and `ids[s]`. -/
theorem simd_first_phase (hR : Regions a0 a1 R) {s : Nat} (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane (ctxs i) s i)
    {sh : Shared} (hm : Mem R V X 0 s false sh) :
    ∃ (W : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m 11 (List.ofFn fun i => (⟨ctxs i, fun _ => none, [.block body], .running⟩ : Thread))).run
        sh = some (List.ofFn W, sh')) ∧ Mem R V X 0 (s + 1) false sh' ∧
      ∀ i, (W i).status = .barrier 3 false true ∧ AtBar (ctxs i) s i (W i) := by
  refine simd_first C (S := shuffleSlots) (after := afterTree) (K := []) (F := fun i => Fixed s i) (ctxs := ctxs)
    (fun i => laneBest V X (32 * s + i)) 16 10 _ (fun _ sh => Mem R V X 0 s false sh) (Mem R V X 0 (s + 1) false)
    (fun i t => t.status = .barrier 3 false true ∧ AtBar (ctxs i) s i t) (fun i sh hI => lane_start C hR (hL i) hI)
    (fun U sh1 hU hI => ?_) sh hm
  refine simd_level C shuffleSlots_ok (shuffle_frame s) _ 16 (by decide) (by decide) U hU 8 sh1 (Mem R V X 0 (s + 1) false)
    (fun i t => t.status = .barrier 3 false true ∧ AtBar (ctxs i) s i t) (fun W1 hW1 => ?_)
  refine simd_level C shuffleSlots_ok (shuffle_frame s) _ 8 (by decide) (by decide) W1 hW1 6 sh1 (Mem R V X 0 (s + 1) false)
    (fun i t => t.status = .barrier 3 false true ∧ AtBar (ctxs i) s i t) (fun W2 hW2 => ?_)
  refine simd_level C shuffleSlots_ok (shuffle_frame s) _ 4 (by decide) (by decide) W2 hW2 4 sh1 (Mem R V X 0 (s + 1) false)
    (fun i t => t.status = .barrier 3 false true ∧ AtBar (ctxs i) s i t) (fun W3 hW3 => ?_)
  refine simd_level C shuffleSlots_ok (shuffle_frame s) _ 2 (by decide) (by decide) W3 hW3 2 sh1 (Mem R V X 0 (s + 1) false)
    (fun i t => t.status = .barrier 3 false true ∧ AtBar (ctxs i) s i t) (fun W4 hW4 => ?_)
  refine simd_last C shuffleSlots_ok (shuffle_frame s) _ 1 (by decide) (by decide) W4 hW4 0 sh1
    (fun i sh => Mem R V X 0 (s + min i 1) false sh) (by simpa using hI)
    (fun i t => t.status = .barrier 3 false true ∧ AtBar (ctxs i) s i t) (fun i l hF hb hbi hbd sh' hI' => ?_)
  obtain ⟨t, sh'', he, hm', -, hst, hbar⟩ := lane_publish C hR (hL i) _ (fun h0 => by
    obtain rfl : i = 0 := Fin.ext h0
    rfl) hbd hF hb hbi hI'
  exact ⟨t, sh'', he, hm', by rw [hst]; rfl, hst, hbar⟩

/-- SIMD-group 0 after the barrier: the tree over the four SIMD-groups' candidates, lane 0's `out`. -/
theorem simd_second_phase (hR : Regions a0 a1 R) (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane (ctxs i) 0 i)
    (U : Fin 32 → Thread) (hU : ∀ i, AtBar (ctxs i) 0 i (U i)) {sh : Shared} (hm : Mem R V X 1 4 false sh) :
    ∃ (W : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m 11 (List.ofFn fun i => { U i with status := .running })).run sh =
        some (List.ofFn W, sh')) ∧ Mem R V X 1 4 true sh' ∧ ∀ i, (W i).status = .done := by
  refine simd_first C (S := mergeSlots) (after := [outStore]) (K := [.block []]) (F := fun i => Fixed2 0 i)
    (ctxs := ctxs) (merged V X) 2 10 _ (fun _ sh => Mem R V X 1 4 false sh) (Mem R V X 1 4 true)
    (fun _ t => t.status = .done) (fun i sh hI => lane_merge_start C hR (hL i) (hU i) hI) (fun U' sh1 hU' hI => ?_) sh hm
  refine simd_level C mergeSlots_ok (merge_frame 0) _ 2 (by decide) (by decide) U' hU' 8 sh1 (Mem R V X 1 4 true)
    (fun _ t => t.status = .done) (fun W1 hW1 => ?_)
  refine simd_last C mergeSlots_ok (merge_frame 0) _ 1 (by decide) (by decide) W1 hW1 6 sh1
    (fun i sh => Mem R V X 1 4 (decide (0 < i)) sh) hI
    (fun _ t => t.status = .done) (fun i l hF hb hbi hbd sh' hI' => ?_)
  obtain ⟨t, sh'', he, hm', hbl, hd⟩ := lane_out C hR (hL i) _ (fun h0 => by
    obtain rfl : i = 0 := Fin.ext h0
    rfl) hbd hF hbi hI'
  exact ⟨t, sh'', he, hm', hbl, hd⟩

/-- SIMD-groups 1 … 3 after the barrier. -/
theorem simd_second_skip {s : Nat} (hs : s ≠ 0) (hs4 : s < 4) (ctxs : Fin 32 → Ctx) (U : Fin 32 → Thread)
    (hU : ∀ i, AtBar (ctxs i) s i (U i)) {sh : Shared} (hm : Mem R V X 1 4 true sh) :
    ∃ (W : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m 11 (List.ofFn fun i => { U i with status := .running })).run sh =
        some (List.ofFn W, sh')) ∧ Mem R V X 1 4 true sh' ∧ ∀ i, (W i).status = .done := by
  have key := runSimd_blocked_ev C 10 (fun i => { U i with status := .running }) (fun _ sh' => sh' = sh)
    (fun _ t => t.status = .done) (fun i sh' hs' => by
      subst hs'
      obtain ⟨t', he, hd⟩ := lane_skip C hs hs4 (hU i) sh'
      exact ⟨t', sh', he, rfl, by rw [hd]; rfl, hd⟩) sh rfl
  obtain ⟨W, sh', hr, hI, hR'⟩ := key
  exact ⟨W, sh', hr, hI ▸ hm, hR'⟩

/-- The threadgroup: both phases. -/
theorem group_run (hR : Regions a0 a1 R) (ctxOf : Fin 4 → Fin 32 → Ctx) (hL : ∀ (s : Fin 4) (i : Fin 32), Lane (ctxOf s i) s i)
    {sh : Shared} (hm : Mem R V X 0 0 false sh) :
    ∃ sh', (Ev fun m => (runGroup C m 11 2 (List.ofFn fun s : Fin 4 => List.ofFn fun i =>
      (⟨ctxOf s i, fun _ => none, [.block body], .running⟩ : Thread))).run sh = some ((), sh')) ∧
      Mem R V X 1 4 true sh' := by
  refine runGroup_barrier_ev C (by decide) 11 1 _ 3 false true (fun j sh => Mem R V X 0 j false sh)
    (fun j i t => AtBar (ctxOf j i) j i t) (Mem R V X 1 4 true) (fun j sh hj => simd_first_phase C hR (ctxOf j) (hL j) hj)
    (fun U sh hU hI => ?_) sh hm
  have h0 : Mem R V X 1 4 (decide (0 < 0)) (pass false true sh) :=
    ⟨hI.regions, hI.values, hI.indices, hI.device, by simp [pass, hI.group], hI.log, hI.pub, fun h => absurd h (by decide)⟩
  refine runGroup_done_ev C 11 0 _ (fun j sh => Mem R V X 1 4 (decide (0 < j)) sh) (fun j sh hj => ?_) _ h0
  by_cases hj0 : j.val = 0
  · obtain rfl : j = 0 := Fin.ext hj0
    exact simd_second_phase C hR (ctxOf 0) (hL 0) (U 0) (hU 0) hj
  · have hj' : Mem R V X 1 4 true sh := by
      have := hj.out; exact ⟨hj.regions, hj.values, hj.indices, hj.device, hj.group, hj.log, hj.pub,
        fun _ => this (by simp; omega)⟩
    obtain ⟨W, sh', hr, hm', hd⟩ := simd_second_skip C hj0 j.isLt (ctxOf j) (U j) (hU j) hj'
    exact ⟨W, sh', hr, hm', hd⟩

/-- The launch: grid and threadgroup `(128, 1, 1)`, `values` and `indices` `[1, 243]`, `out` `[1]`. -/
def launch (V X : ByteMemory.Bytes) (a0 a1 : Nat) (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨core, (128, 1, 1), (128, 1, 1), buffers [⟨.device, 972, a0, V⟩, ⟨.device, 972, a1, X⟩] [4] 16 initial⟩

variable {initial : Nat → ByteMemory.Bytes}

theorem launch_tiles : (launch V X a0 a1 initial).Tiles 128 1 1 1 1 1 4 := ⟨rfl, rfl, rfl, by decide⟩

theorem launch_buffers : (launch V X a0 a1 initial).buffers =
    buffers [⟨.device, 972, a0, V⟩, ⟨.device, 972, a1, X⟩] [4] 16 initial := rfl

theorem launch_regions (ha0 : a0 % 4 = 0) (ha1 : a1 % 4 = 0) : Regions a0 a1 (launch V X a0 a1 initial).regions :=
  ⟨regions_input launch_buffers 0 (by simp), regions_input launch_buffers 1 (by simp),
    regions_output launch_buffers 0 (by simp), Launch.regions_groupArray _ 0 (.scalar .f32) 4 rfl,
    Launch.regions_groupArray _ 1 (.scalar .u32) 4 rfl, ha0, ha1⟩

theorem launch_lane (fuse : Nat → Bool) (s : Fin 4) (i : Fin 32) :
    Lane ((launch V X a0 a1 initial).ctxAt fuse 0 0 0 (32 * s + i)) s i := by
  have hs := s.isLt
  have hi := i.isLt
  refine ⟨?_, rfl, ?_, ?_, fun j => ?_, hs, hi⟩
  · rw [launch_tiles.threadPositionInThreadgroup]
    congr 1 <;> omega
  · rw [launch_tiles.thread]; simp
  · rw [launch_tiles.group_id]
  · rw [Launch.ctxAt_groupArray]; simp [launch, buffers]

/-- The run of the launch. -/
theorem launch_run (ha0 : a0 % 4 = 0) (ha1 : a1 % 4 = 0) (fuse : Nat → Bool) (garbage : Garbage) :
    ∃ sh, Mem (launch V X a0 a1 initial).regions V X 1 4 true sh ∧
      Ev fun m => runLaunch C fuse (launch V X a0 a1 initial) garbage m 11 2 = some ⟨sh.bytes, sh.log⟩ := by
  have hR := launch_regions (V := V) (X := X) (initial := initial) ha0 ha1
  have hg : ∀ bx byy bz, bx < 1 → byy < 1 → bz < 1 → ∀ sh,
      ((bx + byy * 1 + bz * 1 * 1 = 0 ∧ Mem (launch V X a0 a1 initial).regions V X 0 0 false sh) ∨
        (bx + byy * 1 + bz * 1 * 1 = 1 ∧ Mem (launch V X a0 a1 initial).regions V X 1 4 true sh)) → ∃ sh',
      (Ev fun m => (runGroup C m 11 2 (List.ofFn fun s : Fin 4 =>
        List.ofFn ((launch V X a0 a1 initial).lanes fuse bx byy bz s))).run
        { sh with bytes := (launch V X a0 a1 initial).resetGroup garbage (bx + byy * 1 + bz * 1 * 1) sh.bytes } =
          some ((), sh')) ∧
      ((bx + byy * 1 + bz * 1 * 1 + 1 = 0 ∧ Mem (launch V X a0 a1 initial).regions V X 0 0 false sh') ∨
        (bx + byy * 1 + bz * 1 * 1 + 1 = 1 ∧ Mem (launch V X a0 a1 initial).regions V X 1 4 true sh')) := by
    intro bx byy bz hx hy hz sh hI
    obtain rfl : bx = 0 := by omega
    obtain rfl : byy = 0 := by omega
    obtain rfl : bz = 0 := by omega
    have hm : Mem (launch V X a0 a1 initial).regions V X 0 0 false sh := by
      rcases hI with ⟨_, h⟩ | ⟨h, _⟩
      · exact h
      · exact absurd h (by decide)
    have e : ∀ r, r < 3 → (launch V X a0 a1 initial).resetGroup garbage 0 sh.bytes r = sh.bytes r :=
      fun r h => Launch.resetGroup_buffer _ _ _ _ _ (by simp [launch, buffers]; omega)
    have hm' : Mem (launch V X a0 a1 initial).regions V X 0 0 false
        { sh with bytes := (launch V X a0 a1 initial).resetGroup garbage (0 + 0 * 1 + 0 * 1 * 1) sh.bytes } :=
      ⟨hm.regions, (e 0 (by decide)).trans hm.values, (e 1 (by decide)).trans hm.indices, hm.device, hm.group,
        hm.log, fun s hs => absurd hs (by omega), fun h => absurd h (by decide)⟩
    obtain ⟨sh', hr, hm''⟩ := group_run C hR (fun s i => (launch V X a0 a1 initial).ctxAt fuse 0 0 0 (32 * s + i))
      (launch_lane fuse) hm'
    exact ⟨sh', hr, .inr ⟨rfl, hm''⟩⟩
  obtain ⟨sh, hI, hrun⟩ := launch_tiles.launch_run_ev C fuse garbage 11 2
    (fun g sh => (g = 0 ∧ Mem (launch V X a0 a1 initial).regions V X 0 0 false sh) ∨
      (g = 1 ∧ Mem (launch V X a0 a1 initial).regions V X 1 4 true sh))
    (.inl ⟨rfl, rfl, initial_input launch_buffers garbage 0 (by simp), initial_input launch_buffers garbage 1 (by simp),
      rfl, rfl, by simp [Launch.initial], fun s hs => absurd hs (by omega), fun h => absurd h (by decide)⟩) hg
  refine ⟨sh, ?_, hrun⟩
  rcases hI with ⟨h, _⟩ | ⟨_, h⟩
  · exact absurd h (by decide)
  · exact h

/-- Who may write each device byte, and own each threadgroup byte. -/
def dev (r _b : Nat) : Option Writer := if r = 2 then some ⟨0, 0, 0⟩ else none
def tgo (_g e _r b : Nat) : Option Nat := if e = 0 then some (32 * (b / 4)) else none

theorem owned_of_good (L : Launch) (hR : Regions a0 a1 L.regions) (a : Access) (h : Good a) : Owned L dev tgo a := by
  unfold Owned
  rcases h with ⟨hr | hr, hw⟩ | ⟨hr, ht, hg, he⟩ | ⟨hr | hr, ⟨he, ht⟩ | ⟨he, hw⟩⟩
  · simp [hr, hR.r0, isGroup, dev, hw]
  · simp [hr, hR.r1, isGroup, dev, hw]
  · simp [hr, hR.r2, isGroup, dev, ht, hg, he]
  · simp [hr, hR.r3, isGroup, tgo, he, ht]
  · simp [hr, hR.r3, isGroup, tgo, he, hw]
  · simp [hr, hR.r4, isGroup, tgo, he, ht]
  · simp [hr, hR.r4, isGroup, tgo, he, hw]

end Groups

variable (C : M1Max.Contract)

/-- **The GPU runs the argmax finish kernel as its source says.** Under the GPU assumption, MLX's launch of the
exact assembled text on `values` and `indices` (any contents; 4-byte aligned) writes to `out` the index of
`groupBest`: lane 0 of SIMD-group 0 after the tree over the four SIMD-groups' trees over the lanes' scans. -/
theorem gpu_output (G : Gpu C) (hmax : 128 ≤ G.maxThreads Metal.Elab.Tests.argmaxFinishText) (V X : ByteMemory.Bytes)
    (a0 a1 : Nat) (ha0 : 4 ∣ a0) (ha1 : 4 ∣ a1) :
    G.execute Metal.Elab.Tests.argmaxFinishText (128, 1, 1) (128, 1, 1)
      [⟨.device, 972, a0, V⟩, ⟨.device, 972, a1, X⟩] [4] = some [expected V X] := by
  have h := gpu_owned C G (text := Metal.Elab.Tests.argmaxFinishText) (grid := (128, 1, 1)) (tg := (128, 1, 1))
    (inputs := [⟨.device, 972, a0, V⟩, ⟨.device, 972, a1, X⟩]) (sizes := [4])
    (fun _ => expected V X) compile_eq (by simpa using hmax) (fun initial garbage => by
      obtain ⟨sh, hm, n, hn⟩ := launch_run C (V := V) (X := X) (initial := initial) (Nat.mod_eq_zero_of_dvd ha0)
        (Nat.mod_eq_zero_of_dvd ha1) (G.fusion Metal.Elab.Tests.argmaxFinishText) garbage
      refine ⟨n, 11, 2, sh, dev, tgo, hn n le_rfl,
        fun a ha => owned_of_good _ (launch_regions (Nat.mod_eq_zero_of_dvd ha0) (Nat.mod_eq_zero_of_dvd ha1)) a (hm.log a ha),
        fun i hi b hb => ?_⟩
      obtain rfl : i = 0 := by simp at hi; omega
      have hb' : b < 4 := by simpa using hb
      have ho := hm.out rfl
      show sh.bytes 2 b = expected V X b
      rw [expected, ite_eq_left hb', ← ho, cells_getD _ _ _ _ hb', Nat.zero_add])
  rw [h]
  show some [fun b => if b < 4 then expected V X b else 0] = some [expected V X]
  congr 2
  funext b
  unfold expected
  split <;> simp_all

end Metal.Kernels.ArgmaxFinish

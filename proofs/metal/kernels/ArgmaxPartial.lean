import metal.kernels.ArgmaxFinish

namespace Metal.Kernels.ArgmaxPartial
open Metal Metal.Core Inference.Contracts.Mlx

/-! # normalized-argmax.ts partial

The header function is `better(x, xi, y, yi)`: `x > y || (x == y && xi < yi)`.

```
const uint tid = thread_position_in_threadgroup.x;
const uint lane = tid % 32, simd = tid / 32;
const uint row = threadgroup_position_in_grid.y;
const uint tile = threadgroup_position_in_grid.x;
float best = -INFINITY;
uint bestId = 0xffffffffu;
for (uint i = tile * 1024 + tid; i < min(uint(V), (tile + 1) * 1024); i += 128) {
  float value = float(T(logits[row * V + i] - lse[row]));
  // A nonfinite logsumexp produces only NaN or -inf normalized scores.
  // Native argmax selects token zero for this degenerate row.
  value = isnan(value) ? -INFINITY : value;
  if (better(value, i, best, bestId)) { best = value; bestId = i; }
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

  if (lane == 0) { values[row * P + tile] = best; indices[row * P + tile] = bestId; }
}
```
at `partialConfig`: grid [31104, 1, 1], threadgroup [128, 1, 1], so 243 threadgroups of 4 SIMD-groups (one
1024-logit tile each), with V = 248320, P = 243. -/

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

def scanCond : CExpr :=
  .bin .lt .u32 0 (.local 11)
    (.bin .min .u32 0 (u32l 248320) (.bin .mul .u32 0 (.bin .add .u32 0 (.local 8) (u32l 1)) (u32l 1024)))
def scanStep : List CStmt := [.set 11 (.bin .add .u32 0 (.local 11) (u32l 128))]
def valueExpr : CExpr :=
  .conv .f32
    (.bin .sub .bf16 0
      (.load (.scalar .bf16) (.offset (.local 0) (.bin .add .u32 0 (.bin .mul .u32 0 (.local 7) (u32l 248320)) (.local 11))))
      (.load (.scalar .bf16) (.offset (.local 1) (.local 7))))
def scanTake : CStmt := .ite (.local 17) [.set 9 (.local 12), .set 10 (.local 11)] []
def scanBody : List CStmt :=
  [.set 12 valueExpr,
   .set 12 (.cond (.un .isnan .f32 (.local 12)) (f32l 0xFF800000) (.local 12)),
   .set 13 (.local 12),
   .set 14 (.local 11),
   .set 15 (.local 9),
   .set 16 (.local 10),
   better 13 14 15 16 17,
   scanTake]

def shuffleCheck : CStmt :=
  .ite (.local 28)
    [.set 23 (.local 20), .set 24 (.local 22), .set 25 (.local 9), .set 26 (.local 10), better 23 24 25 26 27,
     .set 28 (.local 27)] []
def shuffleTake : CStmt := .ite (.local 28) [.set 9 (.local 20), .set 10 (.local 22)] []
def shuffleBody : List CStmt :=
  [.collective 1 19 .shuffleDown .f32 (.local 9) (.conv .u16 (.local 18)),
   .set 20 (.local 19),
   .collective 2 21 .shuffleDown .u32 (.local 10) (.conv .u16 (.local 18)),
   .set 22 (.local 21),
   .set 28 (.bin .lt .u32 0 (.bin .add .u32 0 (.local 5) (.local 18)) (u32l 32)),
   shuffleCheck,
   shuffleTake]

def publish : List CStmt :=
  [.store (.scalar .f32) (.offset (.local 29) (.local 6)) (.local 9),
   .store (.scalar .u32) (.offset (.local 30) (.local 6)) (.local 10)]

def mergeCheck : CStmt :=
  .ite (.local 41)
    [.set 36 (.local 33), .set 37 (.local 35), .set 38 (.local 9), .set 39 (.local 10), better 36 37 38 39 40,
     .set 41 (.local 40)] []
def mergeTake : CStmt := .ite (.local 41) [.set 9 (.local 33), .set 10 (.local 35)] []
def mergeBody : List CStmt :=
  [.collective 4 32 .shuffleDown .f32 (.local 9) (.conv .u16 (.local 31)),
   .set 33 (.local 32),
   .collective 5 34 .shuffleDown .u32 (.local 10) (.conv .u16 (.local 31)),
   .set 35 (.local 34),
   .set 41 (.bin .lt .u32 0 (.bin .add .u32 0 (.local 5) (.local 31)) (u32l 4)),
   mergeCheck,
   mergeTake]
def mergeLoop : CStmt := .loop (gt0 31) (halve 31) mergeBody
def tileIndex : CExpr := .bin .add .u32 0 (.bin .mul .u32 0 (.local 7) (u32l 243)) (.local 8)
def outStores : CStmt :=
  .ite (.bin .eq .u32 0 (.local 5) (u32l 0))
    [.store (.scalar .f32) (.offset (.local 2) tileIndex) (.local 9),
     .store (.scalar .u32) (.offset (.local 3) tileIndex) (.local 10)] []
def firstSimd : List CStmt :=
  [.set 9
     (.cond (.bin .lt .u32 0 (.local 5) (u32l 4)) (.load (.scalar .f32) (.offset (.local 29) (.local 5)))
       (f32l 0xFF800000)),
   .set 10
     (.cond (.bin .lt .u32 0 (.local 5) (u32l 4)) (.load (.scalar .u32) (.offset (.local 30) (.local 5)))
       (u32l 4294967295)),
   .set 31 (u32l 2),
   mergeLoop,
   outStores]

/-- Slots: 0 logits, 1 lse, 2 values, 3 indices, 4 tid, 5 lane, 6 simd, 7 row, 8 tile, 9 best, 10 bestId, 11 i,
12 value, 13 … 16 `better`'s `x xi y yi`, 17 its result, 18 distance, 19 the shuffled `best`, 20 other,
21 the shuffled `bestId`, 22 oi, 23 … 26 `better`'s `x xi y yi`, 27 its result,
28 `lane + distance < 32 && better(…)`, 29 scores (threadgroup array 0), 30 ids (threadgroup array 1),
31 distance, 32 the shuffled `best`, 33 other, 34 the shuffled `bestId`, 35 oi, 36 … 39 `better`'s `x xi y yi`,
40 its result, 41 `lane + distance < 4 && better(…)`. -/
def body : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .bf16⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .f32⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .u32⟩)),
   .set 4 (.component (.coord .threadPositionInThreadgroup) (u32l 0)),
   .set 5 (.bin .rem .u32 0 (.local 4) (u32l 32)),
   .set 6 (.bin .div .u32 0 (.local 4) (u32l 32)),
   .set 7 (.component (.coord .threadgroupPositionInGrid) (u32l 1)),
   .set 8 (.component (.coord .threadgroupPositionInGrid) (u32l 0)),
   .set 9 (f32l 0xFF800000),
   .set 10 (u32l 4294967295),
   .set 11 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 8) (u32l 1024)) (.local 4)),
   .loop scanCond scanStep scanBody,
   .set 18 (u32l 16),
   .loop (gt0 18) (halve 18) shuffleBody,
   .array 29 true 0 (.scalar .f32),
   .array 30 true 1 (.scalar .u32),
   .ite (.bin .eq .u32 0 (.local 5) (u32l 0)) publish [],
   .barrier 3 false true,
   .ite (.bin .eq .u32 0 (.local 6) (u32l 0)) firstSimd []]

def core : Kernel := ⟨4, [(.scalar .f32, 4), (.scalar .u32, 4)], [], body⟩

-- The elaborated text MLX compiles (tests/Assemble.lean) is `core`.
kernel_rfl compile_eq : (frontend Metal.Elab.Tests.argmaxPartialText).bind elaborate = some core

end Metal.Kernels.ArgmaxPartial

namespace Metal.Kernels.ArgmaxPartial
open Metal Metal.Core Inference.Contracts.Mlx Argmax

/-! ## The specification -/

section Spec
variable (C : M1Max.Contract)

/-- Element `i` of `logits`: the bfloat value of its little-endian word. -/
def logit (Lg : ByteMemory.Bytes) (i : Nat) : BF := Val.ofBf16Bits (bytesWord (cells Lg (2 * i) 2))

/-- The one element of `lse`. -/
def lseOf (S : ByteMemory.Bytes) : BF := Val.ofBf16Bits (bytesWord (cells S 0 2))

open FloatLib.Floats.Formats.BinaryInterchange in
/-- `isnan(value) ? -INFINITY : value`. -/
def nanToNegInf (w : Float32) : Float32 := if Model.isNaN (Numerics.model w) then negInf else w

/-- `value = float(T(logits[row * V + i] - lse[row])); value = isnan(value) ? -INFINITY : value;` at `row = 0`: the
bfloat subtraction, widened to binary32. -/
def score (Lg S : ByteMemory.Bytes) (i : Nat) : Float32 := nanToNegInf (C.widen (C.bfsub (logit Lg i) (lseOf S)))

/-- The candidate `(value, i)`. -/
def cand (Lg S : ByteMemory.Bytes) (i : Nat) : Cand := (score C Lg S i, i)

/-- `min(uint(V), (tile + 1) * 1024)`. -/
def bound (t : Nat) : Nat := min 248320 ((t + 1) * 1024)

/-- Thread `tid` of tile `t`'s candidate after `for (uint i = tile * 1024 + tid; i < min(…); i += 128)`. -/
def laneBest (Lg S : ByteMemory.Bytes) (t tid : Nat) : Cand :=
  scan (cand C Lg S) (t * 1024 + tid) (count (t * 1024 + tid) (bound t))

/-- SIMD-group `s` of tile `t`'s candidate: its lane 0's after the shuffle tree at distances 16, 8, 4, 2, 1. -/
def simdBest (Lg S : ByteMemory.Bytes) (t s : Nat) : Cand :=
  tree 32 [16, 8, 4, 2, 1] (fun i => laneBest C Lg S t (32 * s + i)) 0

/-- SIMD-group 0's lanes after the barrier: `lane < 4 ? (scores[lane], ids[lane]) : (-INFINITY, 0xffffffffu)`. -/
def merged (Lg S : ByteMemory.Bytes) (t : Nat) (i : Fin 32) : Cand := if i.val < 4 then simdBest C Lg S t i else empty

/-- Tile `t`'s candidate: SIMD-group 0's lane 0's after its tree at distances 2, 1. -/
def tileBest (Lg S : ByteMemory.Bytes) (t : Nat) : Cand := tree 4 [2, 1] (merged C Lg S t) 0

/-- `values`: each tile's score, as the bytes of its binary32 word. -/
def values (Lg S : ByteMemory.Bytes) (b : Nat) : BitVec 8 :=
  if b < 972 then (wordBytes 4 (Val.f32Bits (tileBest C Lg S (b / 4)).1)).getD (b % 4) 0 else 0

/-- `indices`: each tile's index, as its bytes. -/
def indices (Lg S : ByteMemory.Bytes) (b : Nat) : BitVec 8 :=
  if b < 972 then (wordBytes 4 (tileBest C Lg S (b / 4)).2).getD (b % 4) 0 else 0

end Spec

/-! ## Lanes -/

def shuffleSlots : Slots := ⟨1, 2, 9, 10, 5, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 32⟩
def mergeSlots : Slots := ⟨4, 5, 9, 10, 5, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 4⟩

theorem shuffleSlots_ok : shuffleSlots.Ok := by decide
theorem mergeSlots_ok : mergeSlots.Ok := by decide

/-- The body after the first tree. -/
def lastIte : CStmt := .ite (.bin .eq .u32 0 (.local 6) (u32l 0)) firstSimd []
def afterTree : List CStmt :=
  [.array 29 true 0 (.scalar .f32), .array 30 true 1 (.scalar .u32), .ite (.bin .eq .u32 0 (.local 5) (u32l 0)) publish [],
   .barrier 3 false true, lastIte]

def p0 : Val := .ptr ⟨0, 0, .scalar .bf16⟩
def p1 : Val := .ptr ⟨1, 0, .scalar .bf16⟩
def p2 : Val := .ptr ⟨2, 0, .scalar .f32⟩
def p3 : Val := .ptr ⟨3, 0, .scalar .u32⟩
def pScores : Val := .ptr ⟨4, 0, .scalar .f32⟩
def pIds : Val := .ptr ⟨5, 0, .scalar .u32⟩

/-- Lane `i` of SIMD-group `s` of tile (threadgroup) `t`. -/
structure Lane (ctx : Ctx) (t s i : Nat) : Prop where
  pos : ctx.coord .threadPositionInThreadgroup = u32x3 (32 * s + i) 0 0
  grid : ctx.coord .threadgroupPositionInGrid = u32x3 t 0 0
  thread : ctx.thread = t * 128 + (32 * s + i)
  group : ctx.group = t
  arrays : ∀ j, ctx.groupArray j = 4 + j
  ht : t < 243
  hs : s < 4
  hi : i < 32

/-- The locals every phase keeps: the buffers, `lane`, `simd`, `row`, `tile`. -/
structure Fixed (t s i : Nat) (l : Locals) : Prop where
  l0 : l 0 = some p0
  l1 : l 1 = some p1
  l2 : l 2 = some p2
  l3 : l 3 = some p3
  l5 : l 5 = some (u32 i)
  l6 : l 6 = some (u32 s)
  l7 : l 7 = some (u32 0)
  l8 : l 8 = some (u32 t)

theorem Fixed.of_eq {t s i : Nat} {l l' : Locals} (h : Fixed t s i l) (h' : ∀ j, j ≤ 8 → l' j = l j) :
    Fixed t s i l' :=
  ⟨(h' 0 (by omega)).trans h.l0, (h' 1 (by omega)).trans h.l1, (h' 2 (by omega)).trans h.l2,
    (h' 3 (by omega)).trans h.l3, (h' 5 (by omega)).trans h.l5, (h' 6 (by omega)).trans h.l6,
    (h' 7 (by omega)).trans h.l7, (h' 8 (by omega)).trans h.l8⟩

theorem Fixed.set {t s i : Nat} {l : Locals} (h : Fixed t s i l) {j : Nat} (v : Val) (hj : 8 < j) :
    Fixed t s i (setLocal l j v) :=
  h.of_eq fun _ hk => setLocal_lt v (by omega)

/-- After the barrier: also the threadgroup arrays. -/
structure Fixed2 (t s i : Nat) (l : Locals) : Prop where
  fixed : Fixed t s i l
  l29 : l 29 = some pScores
  l30 : l 30 = some pIds

theorem Fixed2.set {t s i : Nat} {l : Locals} (h : Fixed2 t s i l) {j : Nat} (v : Val) (hj : 8 < j) (h29 : j ≠ 29)
    (h30 : j ≠ 30) : Fixed2 t s i (setLocal l j v) :=
  ⟨h.fixed.set v hj, by rw [setLocal_other _ _ (by omega)]; exact h.l29, by rw [setLocal_other _ _ (by omega)]; exact h.l30⟩

theorem shuffle_frame (t s : Nat) (i : Fin 32) :
    ∀ l j v, Fixed t s i l → j ∈ shuffleSlots.written → Fixed t s i (setLocal l j v) := by
  intro l j v h hj
  exact h.set v (by simp [Slots.written, shuffleSlots] at hj; omega)

theorem merge_frame (t s : Nat) (i : Fin 32) :
    ∀ l j v, Fixed2 t s i l → j ∈ mergeSlots.written → Fixed2 t s i (setLocal l j v) := by
  intro l j v h hj
  simp [Slots.written, mergeSlots] at hj
  exact h.set v (by omega) (by omega) (by omega)

/-- The regions as the kernel uses them. -/
structure Regions (a0 a1 : Nat) (R : Nat → Option Region) : Prop where
  r0 : R 0 = some ⟨.device, 496640, a0⟩
  r1 : R 1 = some ⟨.constant, 2, a1⟩
  r2 : R 2 = some ⟨.device, 972, 16⟩
  r3 : R 3 = some ⟨.device, 972, 16⟩
  r4 : R 4 = some ⟨.threadgroup, 16, 4⟩
  r5 : R 5 = some ⟨.threadgroup, 16, 4⟩
  a0 : a0 % 2 = 0
  a1 : a1 % 2 = 0

/-- The launch's accesses: reads of the inputs; thread 0 of tile `t` writing `values[t]` and `indices[t]`; lane 0 of
SIMD-group `s` writing `scores[s]`, `ids[s]` before its threadgroup's barrier, reads of them after. -/
def Good (a : Access) : Prop :=
  ((a.region = 0 ∨ a.region = 1) ∧ a.write = false) ∨
  ((a.region = 2 ∨ a.region = 3) ∧ a.thread = 128 * (a.byte / 4) ∧ a.group = a.byte / 4 ∧ a.deviceEpoch = 0) ∨
  ((a.region = 4 ∨ a.region = 5) ∧
    ((a.groupEpoch = a.group ∧ a.thread = 128 * a.group + 32 * (a.byte / 4)) ∨
      (a.groupEpoch = a.group + 1 ∧ a.write = false)))

section Mem
variable (C : M1Max.Contract)

/-- SIMD-group `s` of tile `t`'s candidate in `scores[s]` and `ids[s]`. -/
def Pub (Lg S : ByteMemory.Bytes) (t : Nat) (sh : Shared) (s : Nat) : Prop :=
  cells (sh.bytes 4) (4 * s) 4 = wordBytes 4 (Val.f32Bits (simdBest C Lg S t s).1) ∧
  cells (sh.bytes 5) (4 * s) 4 = wordBytes 4 (simdBest C Lg S t s).2

/-- Tile `t`'s candidate in `values[t]` and `indices[t]`. -/
def Out (Lg S : ByteMemory.Bytes) (sh : Shared) (t : Nat) : Prop :=
  cells (sh.bytes 2) (4 * t) 4 = wordBytes 4 (Val.f32Bits (tileBest C Lg S t).1) ∧
  cells (sh.bytes 3) (4 * t) 4 = wordBytes 4 (tileBest C Lg S t).2

/-- Memory in tile `t`'s run: inputs intact, the epochs (`e` of its barriers passed), the log, its SIMD-groups below
`j` published, the tiles below `t` written, and tile `t` once `done`. -/
structure Mem (R : Nat → Option Region) (Lg S : ByteMemory.Bytes) (t e j : Nat) (done : Bool) (sh : Shared) : Prop where
  regions : sh.regions = R
  logits : sh.bytes 0 = Lg
  lse : sh.bytes 1 = S
  device : sh.deviceEpoch = 0
  group : sh.groupEpoch = t + e
  log : ∀ a ∈ sh.log, Good a
  pub : ∀ s < j, Pub C Lg S t sh s
  outs : ∀ t' < t, Out C Lg S sh t'
  out : done = true → Out C Lg S sh t

end Mem

section Lanes
variable (C : M1Max.Contract) {ctx : Ctx} {R : Nat → Option Region} {Lg S : ByteMemory.Bytes} {a0 a1 : Nat}

theorem Mem.read {t e j : Nat} {done : Bool} {sh : Shared} (hm : Mem C R Lg S t e j done sh) (ctx : Ctx) (reg o n : Nat)
    (hg : ∀ b < n, Good (entry ctx sh reg (o + b) false)) :
    Mem C R Lg S t e j done
      { sh with log := ((List.range n).map fun b => entry ctx sh reg (o + b) false).reverse ++ sh.log } :=
  ⟨hm.regions, hm.logits, hm.lse, hm.device, hm.group, forall_log _ n _ hg hm.log, hm.pub, hm.outs, hm.out⟩

theorem good_read (ctx : Ctx) (sh : Shared) (reg o : Nat) (h : reg = 0 ∨ reg = 1) :
    ∀ b < 2, Good (entry ctx sh reg (o + b) false) := fun _ _ => Or.inl ⟨h, rfl⟩

/-- `float(T(logits[row * V + i] - lse[row]))` at `row = 0`. -/
theorem eval_value (hR : Regions a0 a1 R) {t e j : Nat} {done : Bool} {sh : Shared} (hm : Mem C R Lg S t e j done sh)
    {l : Locals} {n : Nat} (h0 : l 0 = some p0) (h1 : l 1 = some p1) (h7 : l 7 = some (u32 0))
    (h11 : l 11 = some (u32 n)) (hn : n < 248320) :
    ∃ sh', (eval C ctx l valueExpr).run sh = some (.f32 (C.widen (C.bfsub (logit Lg n) (lseOf S))), sh') ∧
      Mem C R Lg S t e j done sh' := by
  have hidx : (eval C ctx l (.bin .add .u32 0 (.bin .mul .u32 0 (.local 7) (u32l 248320)) (.local 11))).run sh =
      some (u32 n, sh) :=
    eval_bin_u32 C (eval_bin_u32 C (eval_local' C h7 sh) (eval_u32lit C l sh 248320 (by decide))
      (binary_mul_u32 C 0 248320)) (eval_local' C h11 sh) (by rw [binary_add_u32, Nat.zero_mul, Nat.zero_add])
  have hp := eval_ptr_u32 C (eval_local' C h0 sh) hidx (by omega)
  rw [show n * (Ty.scalar .bf16).bytes = 2 * n by simp [Ty.bytes, Scalar.bytes]; ring] at hp
  have hl := loadAt_scalar ctx .bf16 0 (2 * n) _ sh (by rw [hm.regions]; exact hR.r0) (by simp)
    (by simpa [Scalar.bytes] using hR.a0) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset])
  have hm1 := hm.read C ctx 0 (2 * n) 2 (good_read ctx sh 0 _ (.inl rfl))
  let sh₁ := { sh with log := ((List.range 2).map fun b => entry ctx sh 0 (2 * n + b) false).reverse ++ sh.log }
  have hq : (eval C ctx l (.offset (.local 1) (.local 7))).run sh₁ = some (.ptr ⟨1, ((0 : Nat) : Int), .scalar .bf16⟩, sh₁) := by
    have h := eval_ptr_u32 C (ctx := ctx) (eval_local' C h1 sh₁) (eval_local' C h7 sh₁) (by decide)
    simpa using h
  have hl' := loadAt_scalar ctx .bf16 1 0 _ sh₁ (by rw [hm1.regions]; exact hR.r1) (by simp)
    (by simpa [Scalar.bytes] using hR.a1) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]) (by simp [loadOffset])
  have hm2 := hm1.read C ctx 1 0 2 (good_read ctx sh₁ 1 _ (.inr rfl))
  refine ⟨_, ?_, hm2⟩
  refine eval_conv C (eval_bin C (z := .bf16 (C.bfsub (logit Lg n) (lseOf S))) (by simp) ((eval_load C _ _ _ _ _ _ _ hp).trans hl)
    ((eval_load C _ _ _ _ _ _ _ hq).trans hl') ?_) ?_
  · show binary C .sub .bf16 (Val.ofWord .bf16 (bytesWord (cells (sh.bytes 0) (2 * n) (Scalar.bytes .bf16))))
      (Val.ofWord .bf16 (bytesWord (cells (sh₁.bytes 1) 0 (Scalar.bytes .bf16)))) = _
    rw [show sh₁.bytes = sh.bytes from rfl, hm.logits, hm.lse]
    rfl
  · rfl

/-- `value = isnan(value) ? -INFINITY : value;` -/
theorem eval_nan {l : Locals} {w : Float32} (h12 : l 12 = some (.f32 w)) (sh : Shared) :
    (eval C ctx l (.cond (.un .isnan .f32 (.local 12)) (f32l 0xFF800000) (.local 12))).run sh =
      some (.f32 (nanToNegInf w), sh) := by
  have hn := eval_un C (ctx := ctx) (sh := sh) (op := .isnan) (s := .f32) (eval_local' C h12 sh) rfl
  unfold nanToNegInf
  revert hn
  cases hb : FloatLib.Floats.Formats.BinaryInterchange.Model.isNaN (Numerics.model w) <;> intro hn
  · exact eval_cond C hn (eval_local' C h12 sh)
  · exact eval_cond C hn (eval_lit C _ _ _ _)

/-- At the `k`-th test of the loop over `i`. -/
structure Scan (Lg S : ByteMemory.Bytes) (t s i k : Nat) (l : Locals) : Prop where
  fixed : Fixed t s i l
  l9 : l 9 = some (.f32 (scan (cand C Lg S) (t * 1024 + (32 * s + i)) k).1)
  l10 : l 10 = some (u32 (scan (cand C Lg S) (t * 1024 + (32 * s + i)) k).2)
  l11 : l 11 = some (u32 (t * 1024 + (32 * s + i) + 128 * k))

theorem cand_bound (Lg S : ByteMemory.Bytes) (i : Nat) (h : i < 2 ^ 32) : (cand C Lg S i).2 < 2 ^ 32 := h

/-- One iteration of the loop over `i`: the two loads, `isnan`, `better`, the take, the step. -/
theorem scan_iter (hR : Regions a0 a1 R) {t s i j : Nat} (k : Nat) (hk : t * 1024 + (32 * s + i) + 128 * k < 248320)
    {l : Locals} {sh : Shared} (hl : Scan C Lg S t s i k l) (hm : Mem C R Lg S t 0 j false sh)
    (hc2 : (scan (cand C Lg S) (t * 1024 + (32 * s + i)) k).2 < 2 ^ 32) :
    ∃ l₁ sh₁ l₂, Exec C ctx scanBody l sh .normal l₁ sh₁ ∧ Exec C ctx scanStep l₁ sh₁ .normal l₂ sh₁ ∧
      Scan C Lg S t s i (k + 1) l₂ ∧ Mem C R Lg S t 0 j false sh₁ := by
  obtain ⟨sh₁, hv, hm1⟩ := eval_value C (ctx := ctx) hR hm hl.fixed.l0 hl.fixed.l1 hl.fixed.l7 hl.l11 hk
  have hb : ∀ (l' : Locals) (n : Nat) (sh' : Shared), l' 11 = some (u32 n) →
      Exec C ctx scanStep l' sh' .normal (setLocal l' 11 (u32 (n + 128))) sh' := fun l' n sh' h11 =>
    .set (eval_bin_u32 C (eval_local' C h11 _) (eval_u32lit C l' _ 128 (by decide)) (binary_add_u32 C n 128)) (.nil _ _)
  have e11 : t * 1024 + (32 * s + i) + 128 * (k + 1) = t * 1024 + (32 * s + i) + 128 * k + 128 := by ring
  have hnan := eval_nan C (ctx := ctx) (l := setLocal l 12 (.f32 (C.widen (C.bfsub (logit Lg
    (t * 1024 + (32 * s + i) + 128 * k)) (lseOf S))))) (setLocal_same _ _ _) sh₁
  by_cases hbt : Argmax.better (score C Lg S (t * 1024 + (32 * s + i) + 128 * k)) (t * 1024 + (32 * s + i) + 128 * k)
      (scan (cand C Lg S) (t * 1024 + (32 * s + i)) k).1 (scan (cand C Lg S) (t * 1024 + (32 * s + i)) k).2 = true
  · refine ⟨_, _, _, .set hv (.set hnan
      (.set (eval_local' C (v := .f32 (score C Lg S (t * 1024 + (32 * s + i) + 128 * k))) (by simp [setLocal]; rfl) _)
      (.set (eval_local' C (v := u32 (t * 1024 + (32 * s + i) + 128 * k)) (by simp [setLocal, hl.l11]) _)
      (.set (eval_local' C (v := .f32 (scan (cand C Lg S) (t * 1024 + (32 * s + i)) k).1) (by simp [setLocal, hl.l9]) _)
      (.set (eval_local' C (v := u32 (scan (cand C Lg S) (t * 1024 + (32 * s + i)) k).2) (by simp [setLocal, hl.l10]) _)
      (exec_better C (score C Lg S (t * 1024 + (32 * s + i) + 128 * k)) (t * 1024 + (32 * s + i) + 128 * k)
        (scan (cand C Lg S) (t * 1024 + (32 * s + i)) k).1 (scan (cand C Lg S) (t * 1024 + (32 * s + i)) k).2
        (by simp [setLocal]) (by simp [setLocal]) (by simp [setLocal]) (by simp [setLocal]) (by omega) hc2
      (.ite (eval_local' C (v := .bool true) (by simp [setLocal, hbt]) _)
        (.set (eval_local' C (v := .f32 (score C Lg S (t * 1024 + (32 * s + i) + 128 * k))) (by simp [setLocal]; rfl) _)
          (.set (eval_local' C (v := u32 (t * 1024 + (32 * s + i) + 128 * k)) (by simp [setLocal, hl.l11]) _) (.nil _ _)))
        (.nil _ _)))))))), hb _ (t * 1024 + (32 * s + i) + 128 * k) _ (by simp [setLocal, hl.l11]),
        ⟨?_, ?_, ?_, ?_⟩, hm1⟩
    · exact hl.fixed.of_eq (fun j hj => by simp (disch := omega) only [setLocal_lt])
    · have hsc : scan (cand C Lg S) (t * 1024 + (32 * s + i)) (k + 1) = cand C Lg S (t * 1024 + (32 * s + i) + 128 * k) := by
        simp only [Argmax.scan, Argmax.pick]; exact ite_eq_left hbt
      rw [hsc]; simp [setLocal, cand]
    · have hsc : scan (cand C Lg S) (t * 1024 + (32 * s + i)) (k + 1) = cand C Lg S (t * 1024 + (32 * s + i) + 128 * k) := by
        simp only [Argmax.scan, Argmax.pick]; exact ite_eq_left hbt
      rw [hsc]; simp [setLocal, cand]
    · rw [e11]; simp [setLocal]
  · have hbf : Argmax.better (score C Lg S (t * 1024 + (32 * s + i) + 128 * k)) (t * 1024 + (32 * s + i) + 128 * k)
        (scan (cand C Lg S) (t * 1024 + (32 * s + i)) k).1 (scan (cand C Lg S) (t * 1024 + (32 * s + i)) k).2 = false := by
      simpa using hbt
    refine ⟨_, _, _, .set hv (.set hnan
      (.set (eval_local' C (v := .f32 (score C Lg S (t * 1024 + (32 * s + i) + 128 * k))) (by simp [setLocal]; rfl) _)
      (.set (eval_local' C (v := u32 (t * 1024 + (32 * s + i) + 128 * k)) (by simp [setLocal, hl.l11]) _)
      (.set (eval_local' C (v := .f32 (scan (cand C Lg S) (t * 1024 + (32 * s + i)) k).1) (by simp [setLocal, hl.l9]) _)
      (.set (eval_local' C (v := u32 (scan (cand C Lg S) (t * 1024 + (32 * s + i)) k).2) (by simp [setLocal, hl.l10]) _)
      (exec_better C (score C Lg S (t * 1024 + (32 * s + i) + 128 * k)) (t * 1024 + (32 * s + i) + 128 * k)
        (scan (cand C Lg S) (t * 1024 + (32 * s + i)) k).1 (scan (cand C Lg S) (t * 1024 + (32 * s + i)) k).2
        (by simp [setLocal]) (by simp [setLocal]) (by simp [setLocal]) (by simp [setLocal]) (by omega) hc2
      (.ite (eval_local' C (v := .bool false) (by simp [setLocal, hbf]) _) (.nil _ _) (.nil _ _)))))))),
      hb _ (t * 1024 + (32 * s + i) + 128 * k) _ (by simp [setLocal, hl.l11]), ⟨?_, ?_, ?_, ?_⟩, hm1⟩
    · exact hl.fixed.of_eq (fun j hj => by simp (disch := omega) only [setLocal_lt])
    · have hsc : scan (cand C Lg S) (t * 1024 + (32 * s + i)) (k + 1) = scan (cand C Lg S) (t * 1024 + (32 * s + i)) k := by
        simp only [Argmax.scan, Argmax.pick]; exact ite_eq_right (by simp only [cand]; rw [hbf]; decide)
      rw [hsc]; simp [setLocal, hl.l9]
    · have hsc : scan (cand C Lg S) (t * 1024 + (32 * s + i)) (k + 1) = scan (cand C Lg S) (t * 1024 + (32 * s + i)) k := by
        simp only [Argmax.scan, Argmax.pick]; exact ite_eq_right (by simp only [cand]; rw [hbf]; decide)
      rw [hsc]; simp [setLocal, hl.l10]
    · rw [e11]; simp [setLocal]

theorem laneBest_bound (Lg S : ByteMemory.Bytes) (t tid k : Nat) (hk : k ≤ count (t * 1024 + tid) (bound t)) :
    (scan (cand C Lg S) (t * 1024 + tid) k).2 < 2 ^ 32 := by
  have h : ∀ k, k ≤ count (t * 1024 + tid) (bound t) → (scan (cand C Lg S) (t * 1024 + tid) k).2 < 2 ^ 32 ∨
      (scan (cand C Lg S) (t * 1024 + tid) k).2 < 248320 := by
    intro k
    induction k with
    | zero => intro _; left; simp [Argmax.scan, empty]
    | succ k ih =>
      intro hk
      have := ih (by omega)
      simp only [Argmax.scan, Argmax.pick]
      split
      · right; simp only [cand]; unfold count bound at hk; omega
      · exact this
  rcases h k hk with h | h
  · exact h
  · omega

/-- The loop over `i`. -/
theorem scan_loop (hR : Regions a0 a1 R) {t s i j : Nat} (hL : Lane ctx t s i) {l : Locals} {sh : Shared}
    (hl : Scan C Lg S t s i 0 l) (hm : Mem C R Lg S t 0 j false sh) :
    ∃ l' sh', Exec C ctx [.loop scanCond scanStep scanBody] l sh .normal l' sh' ∧
      Scan C Lg S t s i (count (t * 1024 + (32 * s + i)) (bound t)) l' ∧ Mem C R Lg S t 0 j false sh' := by
  have hi := hL.hi
  have hs := hL.hs
  have ht := hL.ht
  refine Exec.loop_count (count (t * 1024 + (32 * s + i)) (bound t))
    (fun k l sh => Scan C Lg S t s i k l ∧ Mem C R Lg S t 0 j false sh)
    (fun k l sh => Scan C Lg S t s i k l ∧ Mem C R Lg S t 0 j false sh) (fun k hk l sh hI => ⟨sh, ?_, hI⟩)
    (fun k hk l sh hI => ?_) ⟨hl, hm⟩
  · have hb : (eval C ctx l (.bin .min .u32 0 (u32l 248320)
        (.bin .mul .u32 0 (.bin .add .u32 0 (.local 8) (u32l 1)) (u32l 1024)))).run sh = some (u32 (bound t), sh) :=
      eval_bin_u32 C (eval_u32lit C l sh 248320 (by decide))
        (eval_bin_u32 C (eval_bin_u32 C (eval_local' C hI.1.fixed.l8 sh) (eval_u32lit C l sh 1 (by decide))
          (binary_add_u32 C t 1)) (eval_u32lit C l sh 1024 (by decide)) (binary_mul_u32 C (t + 1) 1024))
        (binary_min_u32 C 248320 ((t + 1) * 1024) (by decide) (by omega))
    have h := eval_bin_u32 C (ctx := ctx) (site := 0) (op := .lt) (eval_local' C hI.1.l11 sh) hb
      (binary_lt_u32 C _ (bound t) (by unfold count bound at hk; omega) (by unfold bound; omega))
    rw [count_test _ _ _ hk] at h
    exact h
  · obtain ⟨l₁, sh₁, l₂, hb, hst, hs', hm'⟩ := scan_iter C (ctx := ctx) hR k (by unfold count bound at hk; omega) hI.1 hI.2
      (laneBest_bound C Lg S t _ k hk.le)
    exact ⟨.normal, l₁, sh₁, l₂, sh₁, .inl rfl, hb, hst, hs', hm'⟩

theorem eval_tid {t s i : Nat} (hL : Lane ctx t s i) (l : Locals) (sh : Shared) :
    (eval C ctx l (.component (.coord .threadPositionInThreadgroup) (u32l 0))).run sh = some (u32 (32 * s + i), sh) := by
  have hv : (eval C ctx l (.coord .threadPositionInThreadgroup)).run sh =
      some (.vec .u32 [u32 (32 * s + i), u32 0, u32 0], sh) := by
    rw [eval_coord, hL.pos]; rfl
  exact eval_component C hv (eval_lit C _ _ _ _) (natOf_unsigned 0 rfl) rfl

theorem eval_grid {t s i : Nat} (hL : Lane ctx t s i) (l : Locals) (sh : Shared) (c : Nat) (hc : c < 2) :
    (eval C ctx l (.component (.coord .threadgroupPositionInGrid) (u32l c))).run sh =
      some (if c = 0 then u32 t else u32 0, sh) := by
  have hv : (eval C ctx l (.coord .threadgroupPositionInGrid)).run sh = some (.vec .u32 [u32 t, u32 0, u32 0], sh) := by
    rw [eval_coord, hL.grid]; rfl
  refine eval_component C hv (eval_lit C _ _ _ _) (natOf_unsigned c rfl) ?_
  rcases (by omega : c = 0 ∨ c = 1) with rfl | rfl <;> rfl

/-- The locals after the declarations. -/
def start (t s i : Nat) : Locals :=
  setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal
    (setLocal (fun _ => none) 0 p0) 1 p1) 2 p2) 3 p3) 4 (u32 (32 * s + i))) 5 (u32 i)) 6 (u32 s)) 7 (u32 0)) 8 (u32 t))
    9 (.f32 negInf)) 10 (u32 0xffffffff)) 11 (u32 (t * 1024 + (32 * s + i)))

/-- A lane runs from the start to the first shuffle, having scanned its elements. -/
theorem lane_start (hR : Regions a0 a1 R) {t s i : Nat} (hL : Lane ctx t s i) {sh : Shared}
    (hm : Mem C R Lg S t 0 s false sh) :
    ∃ t' sh', (Ev fun m => (runThread C m ⟨ctx, fun _ => none, [.block body], .running⟩).run sh = some (t', sh')) ∧
      Mem C R Lg S t 0 s false sh' ∧
      AtA shuffleSlots afterTree [] (Fixed t s i) ctx i (laneBest C Lg S t (32 * s + i)) 16 t' := by
  have hi := hL.hi
  have hs := hL.hs
  have ht := hL.ht
  obtain ⟨l', sh', hscan, hS, hm'⟩ := scan_loop C hR hL (l := start t s i) (sh := sh)
    ⟨⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩, rfl, rfl, by simp [start, setLocal]⟩ hm
  have h18 : setLocal l' 18 (.int .u32 16) 18 = some (u32 16) := rfl
  have hex : Exec C ctx body (fun _ => none) sh
      (.stop (.collective 1 19 .shuffleDown .f32 (.f32 (laneBest C Lg S t (32 * s + i)).1) 16)
        ([.block (treeB shuffleSlots)] ++ [.loop (gt0 18) (halve 18) shuffleBody, .block afterTree]))
      (setLocal l' 18 (.int .u32 16)) sh' :=
    .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <|
    .set (eval_tid C hL _ _) <|
    .set (eval_bin_u32 C (eval_local' C (by rfl) _) (eval_u32lit C _ _ 32 (by decide))
      (by rw [binary_rem_u32 C (32 * s + i) 32 (by omega) (by decide) (by decide), show (32 * s + i) % 32 = i by omega])) <|
    .set (eval_bin_u32 C (eval_local' C (by rfl) _) (eval_u32lit C _ _ 32 (by decide))
      (by rw [binary_div_u32 C (32 * s + i) 32 (by omega) (by decide) (by decide), show (32 * s + i) / 32 = s by omega])) <|
    .set (eval_grid C hL _ _ 1 (by decide)) <| .set (eval_grid C hL _ _ 0 (by decide)) <|
    .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <|
    .set (eval_bin_u32 C (eval_bin_u32 C (eval_local' C (by rfl) _) (eval_u32lit C _ _ 1024 (by decide))
      (binary_mul_u32 C t 1024)) (eval_local' C (by rfl) _) (binary_add_u32 C (t * 1024) (32 * s + i))) <|
    Exec.append hscan <| .set (eval_lit C _ _ _ _) <|
      .loop_stop (eval_treeTest C shuffleSlots h18 (by decide))
        (exec_collA C shuffleSlots (by show setLocal l' 18 (.int .u32 16) 9 = _; rw [setLocal_lt _ (by omega)]; exact hS.l9)
          h18 (by decide))
  refine ⟨_, sh', (hex.reaches_stop (K := [])).ev_stop rfl, hm', ⟨rfl, rfl, rfl, hS.fixed.set _ (by omega),
    by show setLocal l' 18 (.int .u32 16) 9 = _; rw [setLocal_lt _ (by omega)]; exact hS.l9,
    by show setLocal l' 18 (.int .u32 16) 10 = _; rw [setLocal_lt _ (by omega)]; exact hS.l10,
    by show setLocal l' 18 (.int .u32 16) 5 = _; rw [setLocal_lt _ (by omega)]; exact hS.fixed.l5, h18,
    laneBest_bound C Lg S t _ _ le_rfl⟩⟩

theorem Mem.publish {t s : Nat} {sh : Shared} (hm : Mem C R Lg S t 0 s false sh) (ctx : Ctx)
    (hth : ctx.thread = 128 * t + 32 * s) (hg : ctx.group = t) :
    Mem C R Lg S t 0 (s + 1) false (store4 ctx (store4 ctx sh 4 (4 * s)
      (wordBytes 4 (Val.f32Bits (simdBest C Lg S t s).1))) 5 (4 * s) (wordBytes 4 (simdBest C Lg S t s).2)) := by
  have hl : ∀ w, (wordBytes 4 w).length = 4 := fun w => wordBytes_length 4 w
  refine ⟨hm.regions, by simp [store4, hm.logits], by simp [store4, hm.lse], hm.device, hm.group, ?_, ?_,
    fun t' ht' => ?_, fun h => absurd h (by decide)⟩
  · refine forall_log _ 4 _ (fun b hb => Or.inr (Or.inr ⟨.inr rfl, .inl ⟨?_, ?_⟩⟩)) (forall_log _ 4 _
      (fun b hb => Or.inr (Or.inr ⟨.inl rfl, .inl ⟨?_, ?_⟩⟩)) hm.log)
    all_goals first | (simp [entry, store4, hg, hm.group]; done) | (simp only [entry, hth, hg]; omega)
  · intro s' hs'
    by_cases h : s' < s
    · obtain ⟨h4, h5⟩ := hm.pub s' h
      constructor
      · have h := cells_writeBytes_other (sh.bytes 4) (4 * s) (4 * s') 4
          (wordBytes 4 (Val.f32Bits (simdBest C Lg S t s).1)) (.inl (by omega))
        simpa [store4, h4] using h
      · have h := cells_writeBytes_other (sh.bytes 5) (4 * s) (4 * s') 4 (wordBytes 4 (simdBest C Lg S t s).2)
          (.inl (by omega))
        simpa [store4, h5] using h
    · obtain rfl : s' = s := by omega
      constructor
      · have h := cells_writeBytes_same (sh.bytes 4) (4 * s') (wordBytes 4 (Val.f32Bits (simdBest C Lg S t s').1))
        rw [hl] at h
        simpa [store4] using h
      · have h := cells_writeBytes_same (sh.bytes 5) (4 * s') (wordBytes 4 (simdBest C Lg S t s').2)
        rw [hl] at h
        simpa [store4] using h
  · obtain ⟨h2, h3⟩ := hm.outs t' ht'
    exact ⟨by simpa [store4] using h2, by simpa [store4] using h3⟩

/-- A lane at the barrier, for the second phase. -/
structure AtBar (ctx : Ctx) (t s i : Nat) (th : Thread) : Prop where
  ctx : th.ctx = ctx
  frames : th.frames = [.block [lastIte]]
  fixed : Fixed2 t s i th.locals

theorem tree_bound (w : Nat) (ds : List Nat) (c : Fin 32 → Cand) (hc : ∀ j, (c j).2 < 2 ^ 32) (j : Fin 32) :
    (tree w ds c j).2 < 2 ^ 32 := by
  induction ds generalizing c with
  | nil => exact hc j
  | cons d ds ih => exact ih _ (fun j => levelStep_bound _ _ _ _ _ (shuffle_bound c d j hc) (hc j))

theorem simdBest_bound (Lg S : ByteMemory.Bytes) (t s : Nat) : (simdBest C Lg S t s).2 < 2 ^ 32 :=
  tree_bound _ _ _ (fun _ => laneBest_bound C Lg S t _ _ le_rfl) 0

/-- After the last level of the first tree: lane 0 publishes, every lane stops at the barrier. -/
theorem lane_publish (hR : Regions a0 a1 R) {t s : Nat} {i : Fin 32} (hL : Lane ctx t s i) (c : Cand)
    (hc : i.val = 0 → c = simdBest C Lg S t s) (hc2 : c.2 < 2 ^ 32) {l : Locals} (hF : Fixed t s i l)
    (h9 : l 9 = some (.f32 c.1)) (h10 : l 10 = some (u32 c.2)) {sh : Shared}
    (hm : Mem C R Lg S t 0 (s + min i.val 1) false sh) :
    ∃ th sh', (Ev fun m => (runThread C m ⟨ctx, l, [.block afterTree], .running⟩).run sh = some (th, sh')) ∧
      Mem C R Lg S t 0 (s + min (i.val + 1) 1) false sh' ∧ blocked th.status = true ∧
      th.status = .barrier 3 false true ∧ AtBar ctx t s i th := by
  have hs := hL.hs
  let l₂ := setLocal (setLocal l 29 (.ptr ⟨if true then ctx.groupArray 0 else ctx.threadArray 0, 0, .scalar .f32⟩)) 30
    (.ptr ⟨if true then ctx.groupArray 1 else ctx.threadArray 1, 0, .scalar .u32⟩)
  have hF2 : Fixed2 t s i l₂ := ⟨(hF.set _ (by omega)).set _ (by omega), by simp [l₂, setLocal, hL.arrays, pScores],
    by simp [l₂, hL.arrays, pIds]⟩
  have harr : ∀ (ss : List CStmt) (o : Outcome) (l' : Locals) (sh' : Shared), Exec C ctx ss l₂ sh o l' sh' →
      Exec C ctx (.array 29 true 0 (.scalar .f32) :: .array 30 true 1 (.scalar .u32) :: ss) l sh o l' sh' :=
    fun _ _ _ _ h => .array (.array h)
  by_cases h0 : i.val = 0
  · have hi0 : i = 0 := Fin.ext h0
    subst hi0
    obtain rfl := hc rfl
    have hm0 : Mem C R Lg S t 0 s false sh := by simpa using hm
    have hp4 : (eval C ctx l₂ (.offset (.local 29) (.local 6))).run sh =
        some (.ptr ⟨4, ((4 * s : Nat) : Int), .scalar .f32⟩, sh) := by
      have h := eval_ptr_u32 C (ctx := ctx) (eval_local' C hF2.l29 sh) (eval_local' C hF2.fixed.l6 sh) (by omega)
      rwa [show s * (Ty.scalar .f32).bytes = 4 * s by simp [Ty.bytes, Scalar.bytes]; ring] at h
    have hs4 := storeAt_scalar ctx .f32 4 (4 * s) _ sh _ _ (by rw [hm.regions]; exact hR.r4) (by simp) (by simp)
      (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (encode_f32 (simdBest C Lg S t s).1)
    let sh₁ := store4 ctx sh 4 (4 * s) (wordBytes 4 (Val.f32Bits (simdBest C Lg S t s).1))
    have hp5 : (eval C ctx l₂ (.offset (.local 30) (.local 6))).run sh₁ =
        some (.ptr ⟨5, ((4 * s : Nat) : Int), .scalar .u32⟩, sh₁) := by
      have h := eval_ptr_u32 C (ctx := ctx) (eval_local' C hF2.l30 sh₁) (eval_local' C hF2.fixed.l6 sh₁) (by omega)
      rwa [show s * (Ty.scalar .u32).bytes = 4 * s by simp [Ty.bytes, Scalar.bytes]; ring] at h
    have hs5 := storeAt_scalar ctx .u32 5 (4 * s) _ sh₁ _ _ (by simp only [sh₁, store4]; rw [hm.regions]; exact hR.r5)
      (by simp) (by simp) (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)
      (encode_u32 _ (simdBest_bound C Lg S t s))
    have hex : Exec C ctx afterTree l sh (.stop (.barrier 3 false true) [.block [lastIte]]) l₂
        (store4 ctx sh₁ 5 (4 * s) (wordBytes 4 (simdBest C Lg S t s).2)) :=
      harr _ _ _ _ (.ite (eval_eq_u32 C (a := 0) (by simpa using hF2.fixed.l5) (by decide) (by decide))
        (.store hp4 (eval_local' C (by simp [l₂, setLocal, h9]) _) hs4
          (.store hp5 (eval_local' C (by simp [l₂, setLocal, h10]) _) hs5 (.nil _ _))) .barrier)
    have hm1 : Mem C R Lg S t 0 (s + min ((0 : Fin 32).val + 1) 1) false
        (store4 ctx sh₁ 5 (4 * s) (wordBytes 4 (simdBest C Lg S t s).2)) := by
      rw [show s + min ((0 : Fin 32).val + 1) 1 = s + 1 by simp]
      exact hm0.publish C ctx (by rw [hL.thread]; simp only [Fin.val_zero]; ring) hL.group
    exact ⟨_, _, (hex.reaches_stop (K := [])).ev_stop rfl, hm1, rfl, rfl, ⟨rfl, rfl, hF2⟩⟩
  · have hm' : Mem C R Lg S t 0 (s + min (i.val + 1) 1) false sh := by
      rwa [show min (i.val + 1) 1 = min i.val 1 by omega]
    have hex : Exec C ctx afterTree l sh (.stop (.barrier 3 false true) [.block [lastIte]]) l₂ sh :=
      harr _ _ _ _ (.ite (eval_eq_u32 C hF2.fixed.l5 (by omega) (by decide)) (by rw [decide_eq_false h0]; exact .nil _ _)
        .barrier)
    exact ⟨_, _, (hex.reaches_stop (K := [])).ev_stop rfl, hm', rfl, rfl, ⟨rfl, rfl, hF2⟩⟩

theorem merged_bound (Lg S : ByteMemory.Bytes) (t : Nat) (i : Fin 32) : (merged C Lg S t i).2 < 2 ^ 32 := by
  unfold merged; split
  · exact simdBest_bound C Lg S t _
  · simp [empty]

theorem good_group_read (ctx : Ctx) (sh : Shared) (reg o t : Nat) (h : reg = 4 ∨ reg = 5) (hg : ctx.group = t)
    (he : sh.groupEpoch = t + 1) : ∀ b < 4, Good (entry ctx sh reg (o + b) false) :=
  fun _ _ => Or.inr (Or.inr ⟨h, .inr ⟨by simp only [entry]; rw [he, hg], rfl⟩⟩)

/-- SIMD-group 0 after the barrier: on to the second tree's first shuffle, having read `scores` and `ids`. -/
theorem lane_merge_start (hR : Regions a0 a1 R) {t : Nat} {i : Fin 32} (hL : Lane ctx t 0 i) {th : Thread}
    (hth : AtBar ctx t 0 i th) {sh : Shared} (hm : Mem C R Lg S t 1 4 false sh) :
    ∃ th' sh', (Ev fun m => (runThread C m { th with status := .running }).run sh = some (th', sh')) ∧
      Mem C R Lg S t 1 4 false sh' ∧
      AtA mergeSlots [outStores] [.block []] (Fixed2 t 0 i) ctx i (merged C Lg S t i) 2 th' := by
  obtain ⟨tc, tl, tf, ts⟩ := th
  obtain ⟨hc, hf, hF⟩ := hth
  dsimp only at hc hf hF
  subst hc hf
  have hi := i.isLt
  have hsel : (eval C tc tl (.bin .eq .u32 0 (.local 6) (u32l 0))).run sh = some (.bool true, sh) :=
    eval_eq_u32 C hF.fixed.l6 (by decide) (by decide)
  have tail : ∀ (l : Locals) (sh' : Shared), Fixed2 t 0 i l → l 9 = some (.f32 (merged C Lg S t i).1) →
      l 10 = some (u32 (merged C Lg S t i).2) → Mem C R Lg S t 1 4 false sh' → Exec C tc firstSimd tl sh
        (.stop (.collective 4 32 .shuffleDown .f32 (.f32 (merged C Lg S t i).1) 2)
          ([.block (treeB mergeSlots)] ++ [.loop (gt0 31) (halve 31) mergeBody, .block [outStores]]))
        (setLocal l 31 (.int .u32 2)) sh' →
      ∃ th' sh'', (Ev fun m => (runThread C m ⟨tc, tl, [.block [lastIte]], .running⟩).run sh = some (th', sh'')) ∧
        Mem C R Lg S t 1 4 false sh'' ∧
        AtA mergeSlots [outStores] [.block []] (Fixed2 t 0 i) tc i (merged C Lg S t i) 2 th' := by
    intro l sh' hl h9 h10 hm' hex
    refine ⟨_, sh', ((Exec.ite_stop hsel hex).reaches_stop (K := [])).ev_stop rfl, hm', ⟨rfl, rfl, rfl,
      hl.set _ (by omega) (by omega) (by omega),
      by show setLocal l 31 (.int .u32 2) 9 = _; rw [setLocal_lt _ (by omega)]; exact h9,
      by show setLocal l 31 (.int .u32 2) 10 = _; rw [setLocal_lt _ (by omega)]; exact h10,
      by show setLocal l 31 (.int .u32 2) 5 = _; rw [setLocal_lt _ (by omega)]; exact hl.fixed.l5, rfl,
      merged_bound C Lg S t i⟩⟩
  have h31 : ∀ l : Locals, setLocal l 31 (.int .u32 2) 31 = some (u32 2) := fun _ => rfl
  by_cases h4 : i.val < 4
  · have hc4 : ∀ (l : Locals) (sh' : Shared), l 5 = some (u32 i) →
        (eval C tc l (.bin .lt .u32 0 (.local 5) (u32l 4))).run sh' = some (.bool true, sh') := by
      intro l sh' h
      have e := eval_lt_u32 C (ctx := tc) (sh := sh') (b := 4) h (by omega) (by decide)
      rw [decide_eq_true h4] at e
      exact e
    have hp4 : (eval C tc tl (.offset (.local 29) (.local 5))).run sh =
        some (.ptr ⟨4, ((4 * i : Nat) : Int), .scalar .f32⟩, sh) := by
      have h := eval_ptr_u32 C (ctx := tc) (eval_local' C hF.l29 sh) (eval_local' C hF.fixed.l5 sh) (by omega)
      rwa [show i.val * (Ty.scalar .f32).bytes = 4 * i by simp [Ty.bytes, Scalar.bytes]; ring] at h
    have hl4 := loadAt_scalar tc .f32 4 (4 * i) _ sh (by rw [hm.regions]; exact hR.r4) (by simp) (by decide)
      (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset, Ty.bytes, Scalar.bytes])
    have hm1 := hm.read C tc 4 (4 * i) 4 (good_group_read tc sh 4 _ t (.inl rfl) hL.group hm.group)
    have hv4 : Val.ofWord .f32 (bytesWord (cells (sh.bytes 4) (4 * i) (Scalar.bytes .f32))) =
        .f32 (merged C Lg S t i).1 := by
      have hm4 : merged C Lg S t i = simdBest C Lg S t i := by simp [merged, h4]
      rw [show Scalar.bytes .f32 = 4 from rfl, (hm.pub i h4).1, ofWord_f32, hm4]
    rw [hv4] at hl4
    let sh₁ := { sh with log := ((List.range 4).map fun b => entry tc sh 4 (4 * i + b) false).reverse ++ sh.log }
    have hp5 : (eval C tc (setLocal tl 9 (.f32 (merged C Lg S t i).1)) (.offset (.local 30) (.local 5))).run sh₁ =
        some (.ptr ⟨5, ((4 * i : Nat) : Int), .scalar .u32⟩, sh₁) := by
      have h := eval_ptr_u32 C (ctx := tc) (l := setLocal tl 9 (.f32 (merged C Lg S t i).1))
        (eval_local' C (i := 30) (v := pIds) (by simp [setLocal, hF.l30]) sh₁)
        (eval_local' C (i := 5) (v := u32 i) (by simp [setLocal, hF.fixed.l5]) sh₁) (by omega)
      rwa [show i.val * (Ty.scalar .u32).bytes = 4 * i by simp [Ty.bytes, Scalar.bytes]; ring] at h
    have hl5 := loadAt_scalar tc .u32 5 (4 * i) _ sh₁ (by simp only [sh₁]; rw [hm.regions]; exact hR.r5) (by simp)
      (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset, Ty.bytes, Scalar.bytes])
    have hm2 := hm1.read C tc 5 (4 * i) 4 (good_group_read tc sh₁ 5 _ t (.inr rfl) hL.group hm.group)
    have hv5 : Val.ofWord .u32 (bytesWord (cells (sh₁.bytes 5) (4 * i) (Scalar.bytes .u32))) =
        u32 (merged C Lg S t i).2 := by
      have hm4 : merged C Lg S t i = simdBest C Lg S t i := by simp [merged, h4]
      rw [show Scalar.bytes .u32 = 4 from rfl, show sh₁.bytes = sh.bytes from rfl, (hm.pub i h4).2, ofWord_u32, hm4]
    rw [hv5] at hl5
    exact tail _ _ ((hF.set _ (by omega) (by omega) (by omega)).set _ (by omega) (by omega) (by omega))
      (by simp [setLocal]) (by simp [setLocal]) hm2
      (.set (eval_cond C (hc4 _ _ hF.fixed.l5) ((eval_load C _ _ _ _ _ _ _ hp4).trans hl4)) <|
        .set (eval_cond C (hc4 _ _ (by simp [setLocal, hF.fixed.l5]))
          ((eval_load C _ _ _ _ _ _ _ hp5).trans hl5)) <|
        .set (eval_lit C _ _ _ _) <| .loop_stop (eval_treeTest C mergeSlots (h31 _) (by decide))
          (exec_collA C mergeSlots (by simp [setLocal, mergeSlots]) (h31 _) (by decide)))
  · have hc4 : ∀ (l : Locals) (sh' : Shared), l 5 = some (u32 i) →
        (eval C tc l (.bin .lt .u32 0 (.local 5) (u32l 4))).run sh' = some (.bool false, sh') := by
      intro l sh' h
      have e := eval_lt_u32 C (ctx := tc) (sh := sh') (b := 4) h (by omega) (by decide)
      rw [decide_eq_false h4] at e
      exact e
    have hme : merged C Lg S t i = empty := by simp [merged, h4]
    rw [hme]
    rw [hme] at tail
    exact tail _ _ ((hF.set _ (by omega) (by omega) (by omega)).set _ (by omega) (by omega) (by omega))
      (by simp [setLocal]; rfl) (by simp [setLocal]; rfl) hm
      (.set (eval_cond C (hc4 _ _ hF.fixed.l5) (eval_lit C _ _ _ _)) <|
        .set (eval_cond C (hc4 _ _ (by simp [setLocal, hF.fixed.l5])) (eval_lit C _ _ _ _)) <|
        .set (eval_lit C _ _ _ _) <| .loop_stop (eval_treeTest C mergeSlots (h31 _) (by decide))
          (exec_collA C mergeSlots (by simp [setLocal, mergeSlots]; rfl) (h31 _) (by decide)))

theorem Mem.write {t : Nat} {sh : Shared} (hm : Mem C R Lg S t 1 4 false sh) (ctx : Ctx) (hth : ctx.thread = 128 * t)
    (hg : ctx.group = t) :
    Mem C R Lg S t 1 4 true (store4 ctx (store4 ctx sh 2 (4 * t)
      (wordBytes 4 (Val.f32Bits (tileBest C Lg S t).1))) 3 (4 * t) (wordBytes 4 (tileBest C Lg S t).2)) := by
  have hl : ∀ w, (wordBytes 4 w).length = 4 := fun w => wordBytes_length 4 w
  refine ⟨hm.regions, by simp [store4, hm.logits], by simp [store4, hm.lse], hm.device, hm.group, ?_,
    fun s hs => ?_, fun t' ht' => ?_, fun _ => ?_⟩
  · refine forall_log _ 4 _ (fun b hb => Or.inr (Or.inl ⟨.inr rfl, ?_, ?_, hm.device⟩)) (forall_log _ 4 _
      (fun b hb => Or.inr (Or.inl ⟨.inl rfl, ?_, ?_, hm.device⟩)) hm.log)
    · simp only [entry, hth]; omega
    · simp only [entry, hg]; omega
    · simp only [entry, hth]; omega
    · simp only [entry, hg]; omega
  · obtain ⟨h4, h5⟩ := hm.pub s hs
    exact ⟨by simpa [store4] using h4, by simpa [store4] using h5⟩
  · obtain ⟨h2, h3⟩ := hm.outs t' ht'
    constructor
    · have h := cells_writeBytes_other (sh.bytes 2) (4 * t) (4 * t') 4
        (wordBytes 4 (Val.f32Bits (tileBest C Lg S t).1)) (.inl (by omega))
      simpa [store4, h2] using h
    · have h := cells_writeBytes_other (sh.bytes 3) (4 * t) (4 * t') 4 (wordBytes 4 (tileBest C Lg S t).2)
        (.inl (by omega))
      simpa [store4, h3] using h
  · constructor
    · have h := cells_writeBytes_same (sh.bytes 2) (4 * t) (wordBytes 4 (Val.f32Bits (tileBest C Lg S t).1))
      rw [hl] at h
      simpa [store4] using h
    · have h := cells_writeBytes_same (sh.bytes 3) (4 * t) (wordBytes 4 (tileBest C Lg S t).2)
      rw [hl] at h
      simpa [store4] using h

/-- After the second tree: lane 0 writes `values[tile]` and `indices[tile]`, every lane ends. -/
theorem lane_out (hR : Regions a0 a1 R) {t : Nat} {i : Fin 32} (hL : Lane ctx t 0 i) (c : Cand)
    (hc : i.val = 0 → c = tileBest C Lg S t) (hc2 : c.2 < 2 ^ 32) {l : Locals} (hF : Fixed2 t 0 i l)
    (h9 : l 9 = some (.f32 c.1)) (h10 : l 10 = some (u32 c.2)) {sh : Shared}
    (hm : Mem C R Lg S t 1 4 (decide (0 < i.val)) sh) :
    ∃ th sh', (Ev fun m => (runThread C m ⟨ctx, l, [.block [outStores], .block []], .running⟩).run sh =
      some (th, sh')) ∧ Mem C R Lg S t 1 4 (decide (0 < i.val + 1)) sh' ∧ blocked th.status = true ∧
        th.status = .done := by
  have ht := hL.ht
  have hdone : ∀ sh', Exec C ctx [outStores] l sh .normal l sh' →
      Ev fun m => (runThread C m ⟨ctx, l, [.block [outStores], .block []], .running⟩).run sh =
        some (⟨ctx, l, [], .done⟩, sh') :=
    fun sh' h => ((h.reaches_normal (K := [.block []])).trans (Exec.nil l sh').reaches_done).ev_stop rfl
  by_cases h0 : i.val = 0
  · obtain rfl := hc h0
    have hm0 : Mem C R Lg S t 1 4 false sh := by simpa [h0] using hm
    have hidx : ∀ sh' : Shared, (eval C ctx l tileIndex).run sh' = some (u32 t, sh') := fun sh' =>
      eval_bin_u32 C (eval_bin_u32 C (eval_local' C hF.fixed.l7 sh') (eval_u32lit C l sh' 243 (by decide))
        (binary_mul_u32 C 0 243)) (eval_local' C hF.fixed.l8 sh') (by rw [binary_add_u32, Nat.zero_mul, Nat.zero_add])
    have hp2 : (eval C ctx l (.offset (.local 2) tileIndex)).run sh =
        some (.ptr ⟨2, ((4 * t : Nat) : Int), .scalar .f32⟩, sh) := by
      have h := eval_ptr_u32 C (ctx := ctx) (eval_local' C hF.fixed.l2 sh) (hidx sh) (by omega)
      rwa [show t * (Ty.scalar .f32).bytes = 4 * t by simp [Ty.bytes, Scalar.bytes]; ring] at h
    have hs2 := storeAt_scalar ctx .f32 2 (4 * t) _ sh _ _ (by rw [hm.regions]; exact hR.r2) (by simp) (by simp)
      (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (encode_f32 (tileBest C Lg S t).1)
    let sh₁ := store4 ctx sh 2 (4 * t) (wordBytes 4 (Val.f32Bits (tileBest C Lg S t).1))
    have hp3 : (eval C ctx l (.offset (.local 3) tileIndex)).run sh₁ =
        some (.ptr ⟨3, ((4 * t : Nat) : Int), .scalar .u32⟩, sh₁) := by
      have h := eval_ptr_u32 C (ctx := ctx) (eval_local' C hF.fixed.l3 sh₁) (hidx sh₁) (by omega)
      rwa [show t * (Ty.scalar .u32).bytes = 4 * t by simp [Ty.bytes, Scalar.bytes]; ring] at h
    have hs3 := storeAt_scalar ctx .u32 3 (4 * t) _ sh₁ _ _ (by simp only [sh₁, store4]; rw [hm.regions]; exact hR.r3)
      (by simp) (by simp) (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (encode_u32 _ hc2)
    have hex : Exec C ctx [outStores] l sh .normal l (store4 ctx sh₁ 3 (4 * t) (wordBytes 4 (tileBest C Lg S t).2)) :=
      .ite (eval_eq_u32 C hF.fixed.l5 (by omega) (by decide)) (by
        rw [decide_eq_true h0]
        exact .store hp2 (eval_local' C h9 _) hs2 (.store hp3 (eval_local' C h10 _) hs3 (.nil _ _))) (.nil _ _)
    exact ⟨_, _, hdone _ hex, hm0.write C ctx (by rw [hL.thread, h0]; ring) hL.group, rfl, rfl⟩
  · have hex : Exec C ctx [outStores] l sh .normal l sh :=
      .ite (eval_eq_u32 C hF.fixed.l5 (by omega) (by decide)) (by rw [decide_eq_false h0]; exact .nil _ _) (.nil _ _)
    exact ⟨_, _, hdone _ hex, ⟨hm.regions, hm.logits, hm.lse, hm.device, hm.group, hm.log, hm.pub, hm.outs,
      fun _ => hm.out (by simp; omega)⟩, rfl, rfl⟩

/-- SIMD-groups 1 … 3 after the barrier: they end. -/
theorem lane_skip {t s : Nat} {i : Fin 32} (hs : s ≠ 0) (hs4 : s < 4) {th : Thread} (hth : AtBar ctx t s i th)
    (sh : Shared) :
    ∃ th', (Ev fun m => (runThread C m { th with status := .running }).run sh = some (th', sh)) ∧ th'.status = .done := by
  obtain ⟨tc, tl, tf, ts⟩ := th
  obtain ⟨hc, hf, hF⟩ := hth
  dsimp only at hc hf hF
  subst hc hf
  have hex : Exec C tc [lastIte] tl sh .normal tl sh :=
    .ite (eval_eq_u32 C hF.fixed.l6 (by omega) (by decide)) (by rw [decide_eq_false hs]; exact .nil _ _) (.nil _ _)
  exact ⟨_, hex.reaches_done.ev_stop rfl, rfl⟩

end Lanes

/-! ## SIMD-groups, threadgroups, the launch -/

section Groups
variable (C : M1Max.Contract) {R : Nat → Option Region} {Lg S : ByteMemory.Bytes} {a0 a1 : Nat}

/-- SIMD-group `s` of tile `t` up to the barrier: the scan, the shuffle tree, lane 0's `scores[s]` and `ids[s]`. -/
theorem simd_first_phase (hR : Regions a0 a1 R) {t s : Nat} (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane (ctxs i) t s i)
    {sh : Shared} (hm : Mem C R Lg S t 0 s false sh) :
    ∃ (W : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m 11 (List.ofFn fun i => (⟨ctxs i, fun _ => none, [.block body], .running⟩ : Thread))).run
        sh = some (List.ofFn W, sh')) ∧ Mem C R Lg S t 0 (s + 1) false sh' ∧
      ∀ i, (W i).status = .barrier 3 false true ∧ AtBar (ctxs i) t s i (W i) := by
  refine simd_first C (S := shuffleSlots) (after := afterTree) (K := []) (F := fun i => Fixed t s i) (ctxs := ctxs)
    (fun i => laneBest C Lg S t (32 * s + i)) 16 10 _ (fun _ sh => Mem C R Lg S t 0 s false sh)
    (Mem C R Lg S t 0 (s + 1) false) (fun i th => th.status = .barrier 3 false true ∧ AtBar (ctxs i) t s i th)
    (fun i sh hI => lane_start C hR (hL i) hI) (fun U sh1 hU hI => ?_) sh hm
  refine simd_level C shuffleSlots_ok (shuffle_frame t s) _ 16 (by decide) (by decide) U hU 8 sh1
    (Mem C R Lg S t 0 (s + 1) false) (fun i th => th.status = .barrier 3 false true ∧ AtBar (ctxs i) t s i th)
    (fun W1 hW1 => ?_)
  refine simd_level C shuffleSlots_ok (shuffle_frame t s) _ 8 (by decide) (by decide) W1 hW1 6 sh1
    (Mem C R Lg S t 0 (s + 1) false) (fun i th => th.status = .barrier 3 false true ∧ AtBar (ctxs i) t s i th)
    (fun W2 hW2 => ?_)
  refine simd_level C shuffleSlots_ok (shuffle_frame t s) _ 4 (by decide) (by decide) W2 hW2 4 sh1
    (Mem C R Lg S t 0 (s + 1) false) (fun i th => th.status = .barrier 3 false true ∧ AtBar (ctxs i) t s i th)
    (fun W3 hW3 => ?_)
  refine simd_level C shuffleSlots_ok (shuffle_frame t s) _ 2 (by decide) (by decide) W3 hW3 2 sh1
    (Mem C R Lg S t 0 (s + 1) false) (fun i th => th.status = .barrier 3 false true ∧ AtBar (ctxs i) t s i th)
    (fun W4 hW4 => ?_)
  refine simd_last C shuffleSlots_ok (shuffle_frame t s) _ 1 (by decide) (by decide) W4 hW4 0 sh1
    (fun i sh => Mem C R Lg S t 0 (s + min i 1) false sh) (by simpa using hI)
    (fun i th => th.status = .barrier 3 false true ∧ AtBar (ctxs i) t s i th) (fun i l hF hb hbi hbd sh' hI' => ?_)
  obtain ⟨th, sh'', he, hm', -, hst, hbar⟩ := lane_publish C hR (hL i) _ (fun h0 => by
    obtain rfl : i = 0 := Fin.ext h0
    rfl) hbd hF hb hbi hI'
  exact ⟨th, sh'', he, hm', by rw [hst]; rfl, hst, hbar⟩

/-- SIMD-group 0 of tile `t` after the barrier: the tree over the four SIMD-groups' candidates, lane 0's stores. -/
theorem simd_second_phase (hR : Regions a0 a1 R) {t : Nat} (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane (ctxs i) t 0 i)
    (U : Fin 32 → Thread) (hU : ∀ i, AtBar (ctxs i) t 0 i (U i)) {sh : Shared} (hm : Mem C R Lg S t 1 4 false sh) :
    ∃ (W : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m 11 (List.ofFn fun i => { U i with status := .running })).run sh =
        some (List.ofFn W, sh')) ∧ Mem C R Lg S t 1 4 true sh' ∧ ∀ i, (W i).status = .done := by
  refine simd_first C (S := mergeSlots) (after := [outStores]) (K := [.block []]) (F := fun i => Fixed2 t 0 i)
    (ctxs := ctxs) (merged C Lg S t) 2 10 _ (fun _ sh => Mem C R Lg S t 1 4 false sh) (Mem C R Lg S t 1 4 true)
    (fun _ th => th.status = .done) (fun i sh hI => lane_merge_start C hR (hL i) (hU i) hI) (fun U' sh1 hU' hI => ?_)
    sh hm
  refine simd_level C mergeSlots_ok (merge_frame t 0) _ 2 (by decide) (by decide) U' hU' 8 sh1
    (Mem C R Lg S t 1 4 true) (fun _ th => th.status = .done) (fun W1 hW1 => ?_)
  refine simd_last C mergeSlots_ok (merge_frame t 0) _ 1 (by decide) (by decide) W1 hW1 6 sh1
    (fun i sh => Mem C R Lg S t 1 4 (decide (0 < i)) sh) hI
    (fun _ th => th.status = .done) (fun i l hF hb hbi hbd sh' hI' => ?_)
  obtain ⟨th, sh'', he, hm', hbl, hd⟩ := lane_out C hR (hL i) _ (fun h0 => by
    obtain rfl : i = 0 := Fin.ext h0
    rfl) hbd hF hb hbi hI'
  exact ⟨th, sh'', he, hm', hbl, hd⟩

/-- SIMD-groups 1 … 3 after the barrier. -/
theorem simd_second_skip {t s : Nat} (hs : s ≠ 0) (hs4 : s < 4) (ctxs : Fin 32 → Ctx) (U : Fin 32 → Thread)
    (hU : ∀ i, AtBar (ctxs i) t s i (U i)) {sh : Shared} (hm : Mem C R Lg S t 1 4 true sh) :
    ∃ (W : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m 11 (List.ofFn fun i => { U i with status := .running })).run sh =
        some (List.ofFn W, sh')) ∧ Mem C R Lg S t 1 4 true sh' ∧ ∀ i, (W i).status = .done := by
  have key := runSimd_blocked_ev C 10 (fun i => { U i with status := .running }) (fun _ sh' => sh' = sh)
    (fun _ th => th.status = .done) (fun i sh' hs' => by
      subst hs'
      obtain ⟨th', he, hd⟩ := lane_skip C hs hs4 (hU i) sh'
      exact ⟨th', sh', he, rfl, by rw [hd]; rfl, hd⟩) sh rfl
  obtain ⟨W, sh', hr, hI, hR'⟩ := key
  exact ⟨W, sh', hr, hI ▸ hm, hR'⟩

/-- Tile `t`'s threadgroup: both phases. -/
theorem group_run (hR : Regions a0 a1 R) {t : Nat} (ctxOf : Fin 4 → Fin 32 → Ctx)
    (hL : ∀ (s : Fin 4) (i : Fin 32), Lane (ctxOf s i) t s i) {sh : Shared} (hm : Mem C R Lg S t 0 0 false sh) :
    ∃ sh', (Ev fun m => (runGroup C m 11 2 (List.ofFn fun s : Fin 4 => List.ofFn fun i =>
      (⟨ctxOf s i, fun _ => none, [.block body], .running⟩ : Thread))).run sh = some ((), sh')) ∧
      Mem C R Lg S t 1 4 true sh' := by
  refine runGroup_barrier_ev C (by decide) 11 1 _ 3 false true (fun j sh => Mem C R Lg S t 0 j false sh)
    (fun j i th => AtBar (ctxOf j i) t j i th) (Mem C R Lg S t 1 4 true)
    (fun j sh hj => simd_first_phase C hR (ctxOf j) (hL j) hj) (fun U sh hU hI => ?_) sh hm
  have h0 : Mem C R Lg S t 1 4 (decide (0 < 0)) (pass false true sh) :=
    ⟨hI.regions, hI.logits, hI.lse, hI.device, by simp [pass, hI.group], hI.log, hI.pub, hI.outs,
      fun h => absurd h (by decide)⟩
  refine runGroup_done_ev C 11 0 _ (fun j sh => Mem C R Lg S t 1 4 (decide (0 < j)) sh) (fun j sh hj => ?_) _ h0
  by_cases hj0 : j.val = 0
  · obtain rfl : j = 0 := Fin.ext hj0
    exact simd_second_phase C hR (ctxOf 0) (hL 0) (U 0) (hU 0) hj
  · have hj' : Mem C R Lg S t 1 4 true sh := by
      have := hj.out
      exact ⟨hj.regions, hj.logits, hj.lse, hj.device, hj.group, hj.log, hj.pub, hj.outs, fun _ => this (by simp; omega)⟩
    obtain ⟨W, sh', hr, hm', hd⟩ := simd_second_skip C hj0 j.isLt (ctxOf j) (U j) (hU j) hj'
    exact ⟨W, sh', hr, hm', hd⟩

/-- The launch: grid `(31104, 1, 1)`, threadgroup `(128, 1, 1)`, `logits` `[1, 248320]`, `lse` `[1, 1]`, `values` and
`indices` `[1, 243]`. -/
def launch (Lg S : ByteMemory.Bytes) (a0 a1 : Nat) (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨core, (31104, 1, 1), (128, 1, 1),
    buffers [⟨.device, 496640, a0, Lg⟩, ⟨.constant, 2, a1, S⟩] [972, 972] 16 initial⟩

variable {initial : Nat → ByteMemory.Bytes}

theorem launch_tiles : (launch Lg S a0 a1 initial).Tiles 128 1 1 243 1 1 4 := ⟨rfl, rfl, rfl, by decide⟩

theorem launch_buffers : (launch Lg S a0 a1 initial).buffers =
    buffers [⟨.device, 496640, a0, Lg⟩, ⟨.constant, 2, a1, S⟩] [972, 972] 16 initial := rfl

theorem launch_regions (ha0 : a0 % 2 = 0) (ha1 : a1 % 2 = 0) : Regions a0 a1 (launch Lg S a0 a1 initial).regions :=
  ⟨regions_input launch_buffers 0 (by simp), regions_input launch_buffers 1 (by simp),
    regions_output launch_buffers 0 (by simp), regions_output launch_buffers 1 (by simp),
    Launch.regions_groupArray _ 0 (.scalar .f32) 4 rfl, Launch.regions_groupArray _ 1 (.scalar .u32) 4 rfl, ha0, ha1⟩

theorem launch_lane (fuse : Nat → Bool) {t : Nat} (ht : t < 243) (s : Fin 4) (i : Fin 32) :
    Lane ((launch Lg S a0 a1 initial).ctxAt fuse t 0 0 (32 * s + i)) t s i := by
  have hs := s.isLt
  have hi := i.isLt
  refine ⟨?_, rfl, ?_, ?_, fun j => ?_, ht, hs, hi⟩
  · rw [launch_tiles.threadPositionInThreadgroup]
    congr 1 <;> omega
  · rw [launch_tiles.thread]; ring
  · rw [launch_tiles.group_id]; simp
  · rw [Launch.ctxAt_groupArray]; simp [launch, buffers]

/-- The run of the launch: tile after tile. -/
theorem launch_run (ha0 : a0 % 2 = 0) (ha1 : a1 % 2 = 0) (fuse : Nat → Bool) (garbage : Garbage) :
    ∃ sh, Mem C (launch Lg S a0 a1 initial).regions Lg S 243 0 0 false sh ∧
      Ev fun m => runLaunch C fuse (launch Lg S a0 a1 initial) garbage m 11 2 = some ⟨sh.bytes, sh.log⟩ := by
  have hR := launch_regions (Lg := Lg) (S := S) (initial := initial) ha0 ha1
  have hg : ∀ bx byy bz, bx < 243 → byy < 1 → bz < 1 → ∀ sh,
      Mem C (launch Lg S a0 a1 initial).regions Lg S (bx + byy * 243 + bz * 243 * 1) 0 0 false sh → ∃ sh',
      (Ev fun m => (runGroup C m 11 2 (List.ofFn fun s : Fin 4 =>
        List.ofFn ((launch Lg S a0 a1 initial).lanes fuse bx byy bz s))).run
        { sh with bytes := (launch Lg S a0 a1 initial).resetGroup garbage (bx + byy * 243 + bz * 243 * 1) sh.bytes } =
          some ((), sh')) ∧
      Mem C (launch Lg S a0 a1 initial).regions Lg S (bx + byy * 243 + bz * 243 * 1 + 1) 0 0 false sh' := by
    intro bx byy bz hx hy hz sh hm
    obtain rfl : byy = 0 := by omega
    obtain rfl : bz = 0 := by omega
    have e0 : bx + 0 * 243 + 0 * 243 * 1 = bx := by simp
    rw [e0] at hm ⊢
    have e : ∀ r, r < 4 → (launch Lg S a0 a1 initial).resetGroup garbage bx sh.bytes r = sh.bytes r :=
      fun r h => Launch.resetGroup_buffer _ _ _ _ _ (by simp [launch, buffers]; omega)
    have hm' : Mem C (launch Lg S a0 a1 initial).regions Lg S bx 0 0 false
        { sh with bytes := (launch Lg S a0 a1 initial).resetGroup garbage bx sh.bytes } :=
      ⟨hm.regions, (e 0 (by decide)).trans hm.logits, (e 1 (by decide)).trans hm.lse, hm.device, hm.group,
        hm.log, fun s hs => absurd hs (by omega), fun t' ht' => by
          obtain ⟨h2, h3⟩ := hm.outs t' ht'
          exact ⟨by rw [← h2]; congr 1, by rw [← h3]; congr 1⟩,
        fun h => absurd h (by decide)⟩
    obtain ⟨sh', hr, hm''⟩ := group_run C hR (t := bx)
      (fun s i => (launch Lg S a0 a1 initial).ctxAt fuse bx 0 0 (32 * s + i)) (launch_lane fuse hx) hm'
    refine ⟨sh', hr, ⟨hm''.regions, hm''.logits, hm''.lse, hm''.device, by rw [hm''.group], hm''.log,
      fun s hs => absurd hs (by omega), fun t' ht' => ?_, fun h => absurd h (by decide)⟩⟩
    by_cases h : t' < bx
    · exact hm''.outs t' h
    · obtain rfl : t' = bx := by omega
      exact hm''.out rfl
  obtain ⟨sh, hI, hrun⟩ := launch_tiles.launch_run_ev C fuse garbage 11 2
    (fun g sh => Mem C (launch Lg S a0 a1 initial).regions Lg S g 0 0 false sh)
    ⟨rfl, initial_input launch_buffers garbage 0 (by simp), initial_input launch_buffers garbage 1 (by simp),
      rfl, rfl, by simp [Launch.initial], fun s hs => absurd hs (by omega), fun t' ht' => absurd ht' (by omega),
      fun h => absurd h (by decide)⟩ hg
  exact ⟨sh, hI, hrun⟩

/-- Who may write each device byte, and own each threadgroup byte. -/
def dev (r b : Nat) : Option Writer := if r = 2 ∨ r = 3 then some ⟨128 * (b / 4), b / 4, 0⟩ else none
def tgo (g e _r b : Nat) : Option Nat := if e = g then some (128 * g + 32 * (b / 4)) else none

theorem owned_of_good (L : Launch) (hR : Regions a0 a1 L.regions) (a : Access) (h : Good a) : Owned L dev tgo a := by
  unfold Owned
  rcases h with ⟨hr | hr, hw⟩ | ⟨hr | hr, ht, hg, he⟩ | ⟨hr | hr, ⟨he, ht⟩ | ⟨he, hw⟩⟩
  · simp [hr, hR.r0, isGroup, dev, hw]
  · simp [hr, hR.r1, isGroup, dev, hw]
  · simp [hr, hR.r2, isGroup, dev, ht, hg, he]
  · simp [hr, hR.r3, isGroup, dev, ht, hg, he]
  · simp [hr, hR.r4, isGroup, tgo, he, ht]
  · simp [hr, hR.r4, isGroup, tgo, he, hw]
  · simp [hr, hR.r5, isGroup, tgo, he, ht]
  · simp [hr, hR.r5, isGroup, tgo, he, hw]

end Groups

variable (C : M1Max.Contract)

/-- **The GPU runs the argmax partial kernel as its source says.** Under the GPU assumption, MLX's launch of the
exact assembled text on `logits` and `lse` (any contents; 2-byte aligned) writes to `values[t]` and `indices[t]`, for
each of the 243 tiles, the score and index of `tileBest t`: lane 0 of SIMD-group 0 after the tree over the four
SIMD-groups' trees over the lanes' scans of their `float(bfloat(logit - lse))` scores (NaN as `-INFINITY`). -/
theorem gpu_output (G : Gpu C) (hmax : 128 ≤ G.maxThreads Metal.Elab.Tests.argmaxPartialText)
    (Lg S : ByteMemory.Bytes) (a0 a1 : Nat) (ha0 : 2 ∣ a0) (ha1 : 2 ∣ a1) :
    G.execute Metal.Elab.Tests.argmaxPartialText (31104, 1, 1) (128, 1, 1)
      [⟨.device, 496640, a0, Lg⟩, ⟨.constant, 2, a1, S⟩] [972, 972] = some [values C Lg S, indices C Lg S] := by
  have h := gpu_owned C G (text := Metal.Elab.Tests.argmaxPartialText) (grid := (31104, 1, 1)) (tg := (128, 1, 1))
    (inputs := [⟨.device, 496640, a0, Lg⟩, ⟨.constant, 2, a1, S⟩]) (sizes := [972, 972])
    (fun i => if i = 0 then values C Lg S else indices C Lg S) compile_eq (by simpa using hmax) (fun initial garbage => by
      obtain ⟨sh, hm, n, hn⟩ := launch_run C (Lg := Lg) (S := S) (initial := initial) (Nat.mod_eq_zero_of_dvd ha0)
        (Nat.mod_eq_zero_of_dvd ha1) (G.fusion Metal.Elab.Tests.argmaxPartialText) garbage
      refine ⟨n, 11, 2, sh, dev, tgo, hn n le_rfl,
        fun a ha => owned_of_good _ (launch_regions (Nat.mod_eq_zero_of_dvd ha0) (Nat.mod_eq_zero_of_dvd ha1)) a
          (hm.log a ha), fun i hi b hb => ?_⟩
      have hi2 : i < 2 := by simpa using hi
      have hb' : b < 972 := by rcases (by omega : i = 0 ∨ i = 1) with rfl | rfl <;> simpa using hb
      obtain ⟨h2, h3⟩ := hm.outs (b / 4) (by omega)
      have hbb : 4 * (b / 4) + b % 4 = b := by omega
      rcases (by omega : i = 0 ∨ i = 1) with rfl | rfl
      · show sh.bytes 2 b = values C Lg S b
        rw [values, ite_eq_left hb', ← h2, cells_getD _ _ _ _ (Nat.mod_lt _ (by decide)), hbb]
      · show sh.bytes 3 b = indices C Lg S b
        rw [indices, ite_eq_left hb', ← h3, cells_getD _ _ _ _ (Nat.mod_lt _ (by decide)), hbb])
  rw [h]
  show some [fun b => if b < 972 then values C Lg S b else 0, fun b => if b < 972 then indices C Lg S b else 0] =
    some [values C Lg S, indices C Lg S]
  congr 2
  · funext b; unfold values; split <;> simp_all
  · congr 1; funext b; unfold indices; split <;> simp_all

end Metal.Kernels.ArgmaxPartial

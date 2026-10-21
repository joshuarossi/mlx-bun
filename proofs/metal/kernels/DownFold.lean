import metal.Logic
import metal.Launch
import metal.tests.Elab

namespace Metal.Kernels.DownFold
open Metal Metal.Core Inference.Contracts.Mlx

/-! # down-codebook.ts FOLD

```
const uint lane = thread_index_in_simdgroup;
const uint col = threadgroup_position_in_grid.x * 32u + simdgroup_index_in_threadgroup * 4u;
const float4 t = *(const device float4*)(partial + (ulong)lane * (ulong)C + col);
for (uint i = 0; i < 4u; ++i) {
  const float v = metal::simd_sum(t[i]);
  if (lane == 0u) out[col + i] = T(v);
}
```
at C = 5120: 160 threadgroups of 8 SIMD-groups. -/

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)

def colExpr : CExpr :=
  .bin .add .u32 0 (.bin .mul .u32 0 (.component (.coord .threadgroupPositionInGrid) (u32l 0)) (u32l 32))
    (.bin .mul .u32 0 (.coord .simdgroupIndexInThreadgroup) (u32l 4))
def addrExpr : CExpr :=
  .ptrCast (.vec .f32 4) (.offset (.offset (.local 0) (.bin .mul .u64 0 (.conv .u64 (.local 2))
    (.lit (.int .u64 5120)))) (.local 3))
def loopCond : CExpr := .bin .lt .u32 0 (.local 5) (u32l 4)
def loopStep : List CStmt := [.set 5 (.bin .add .u32 0 (.local 5) (u32l 1))]
def storeStmt : CStmt :=
  .store (.scalar .bf16) (.offset (.local 1) (.bin .add .u32 0 (.local 3) (.local 5))) (.conv .bf16 (.local 7))
def iteStmt : CStmt := .ite (.bin .eq .u32 0 (.local 2) (u32l 0)) [storeStmt] []
def loopBody : List CStmt :=
  [.collective 1 6 .sum .f32 (.component (.local 4) (.local 5)) (.lit (.int .u16 0)), .set 7 (.local 6), iteStmt]

/-- Slots: 0 partial, 1 out, 2 lane, 3 col, 4 t, 5 i, 6 the sum, 7 v. -/
def body : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .f32⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .bf16⟩)),
   .set 2 (.coord .threadIndexInSimdgroup),
   .set 3 colExpr,
   .set 4 (.load (.vec .f32 4) addrExpr),
   .set 5 (u32l 0),
   .loop loopCond loopStep loopBody]

def core : Kernel := ⟨2, [], [], body⟩

-- The elaborated text MLX compiles (tests/Assemble.lean) is `core`.
kernel_rfl compile_eq : (frontend Metal.Elab.Tests.downFoldText).bind elaborate = some core

variable (C : M1Max.Contract)

/-- A lane's coordinates: lane `l` of SIMD-group `s` of threadgroup `g`. -/
structure Lane (ctx : Ctx) (l s g : Nat) : Prop where
  lane : ctx.coord .threadIndexInSimdgroup = u32 l
  simd : ctx.coord .simdgroupIndexInThreadgroup = u32 s
  group : ctx.coord .threadgroupPositionInGrid = u32x3 g 0 0
  hl : l < 32
  hs : s < 8
  hg : g < 160

def col (s g : Nat) : Nat := g * 32 + s * 4

theorem eval_col (ctx : Ctx) (locals : Nat → Option Val) (l s g : Nat) (h : Lane ctx l s g) (sh : Shared) :
    (eval C ctx locals colExpr).run sh = some (u32 (col s g), sh) := by
  have h1 : g % 2 ^ 32 = g := Nat.mod_eq_of_lt (by have := h.hg; omega)
  have h2 : s % 2 ^ 32 = s := Nat.mod_eq_of_lt (by have := h.hs; omega)
  simp [eval, colExpr, h.simd, h.group, u32x3, u32, u32l, h1, h2, natOf, lift, lift2, binary, Val.signed, Val.wrap,
    Scalar.isSigned, Scalar.width, Scalar.bytes, Scalar.isInt, col]
  omega

theorem eval_addr (ctx : Ctx) (locals : Nat → Option Val) (l s g : Nat) (h : Lane ctx l s g) (sh : Shared)
    (h0 : locals 0 = some (.ptr ⟨0, 0, .scalar .f32⟩)) (h2 : locals 2 = some (u32 l))
    (h3 : locals 3 = some (u32 (col s g))) :
    (eval C ctx locals addrExpr).run sh =
      some (.ptr ⟨0, (((l * 5120 + col s g) * 4 : Nat) : Int), .vec .f32 4⟩, sh) := by
  have hl := h.hl; have hs := h.hs; have hg := h.hg
  have e1 : l % 4294967296 = l := Nat.mod_eq_of_lt (by omega)
  have e2 : col s g % 4294967296 = col s g := Nat.mod_eq_of_lt (by unfold col; omega)
  simp [eval, addrExpr, h0, h2, h3, u32, e1, e2, natOf, lift, lift1, lift2, binary, convert, Val.signed, Val.wrap,
    Scalar.isSigned, Scalar.width, Scalar.bytes, Scalar.isInt, Ty.bytes]
  have hA : (l : Int) % 18446744073709551616 = l := Int.emod_eq_of_lt (by omega) (by omega)
  have hC : max (l : Int) 0 = l := max_eq_left (by omega)
  have hB : (l : Int) * 5120 % 18446744073709551616 = l * 5120 := Int.emod_eq_of_lt (by omega) (by omega)
  have hD : max ((l : Int) * 5120) 0 = l * 5120 := max_eq_left (by omega)
  rw [hA, hC, hB, hD]
  ring

def p0 : Val := .ptr ⟨0, 0, .scalar .f32⟩
def p1 : Val := .ptr ⟨1, 0, .scalar .bf16⟩
def afterLoop : List Frame := [.loop loopCond loopStep loopBody, .block []]

/-- Byte offset of lane `l`'s float4 in `partial`. -/
def offset (l s g : Nat) : Nat := (l * 5120 + col s g) * 4

/-- The float4 a lane loads, as `decode` reads it. -/
def vals (memory : ByteMemory.Bytes) (o : Nat) : List Val :=
  (List.range 4).map fun i => Val.ofWord .f32 (bytesWord ((((List.range 16).map fun j => memory (o + j)).drop (4 * i)).take 4))

/-- A lane stopped at its `k`-th `simd_sum`. -/
structure AtSum (ctx : Ctx) (l s g : Nat) (xs : List Val) (k : Nat) (t : Thread) : Prop where
  ctx : t.ctx = ctx
  frames : t.frames = .block [.set 7 (.local 6), iteStmt] :: afterLoop
  status : ∃ v, xs[k]? = some v ∧ t.status = .collective 1 6 .sum .f32 v 0
  l0 : t.locals 0 = some p0
  l1 : t.locals 1 = some p1
  l2 : t.locals 2 = some (u32 l)
  l3 : t.locals 3 = some (u32 (col s g))
  l4 : t.locals 4 = some (.vec .f32 xs)
  l5 : t.locals 5 = some (u32 k)

def partialRegion : Region := ⟨.device, 655360, 16⟩

theorem eval_cond (ctx : Ctx) (locals : Nat → Option Val) (k : Nat) (hk : k < 2 ^ 32)
    (h5 : locals 5 = some (u32 k)) (sh : Shared) :
    (eval C ctx locals loopCond).run sh = some (.bool (decide (k < 4)), sh) := by
  have e : k % 4294967296 = k := Nat.mod_eq_of_lt (by omega)
  simp [eval, loopCond, h5, u32, u32l, e, lift, lift2, binary, intCompare, Val.signed, Scalar.isSigned,
    Scalar.isInt, Scalar.width, Scalar.bytes, ordered_lt_compare]

theorem eval_component (ctx : Ctx) (locals : Nat → Option Val) (xs : List Val) (k : Nat) (v : Val) (hk : k < 2 ^ 32)
    (h4 : locals 4 = some (.vec .f32 xs)) (h5 : locals 5 = some (u32 k)) (hx : xs[k]? = some v) (sh : Shared) :
    (eval C ctx locals (.component (.local 4) (.local 5))).run sh = some (v, sh) := by
  have e : k % 4294967296 = k := Nat.mod_eq_of_lt (by omega)
  simp [eval, h4, h5, u32, e, lift, natOf, Val.signed, Scalar.isSigned, hx]

theorem lane_start (ctx : Ctx) (l s g : Nat) (h : Lane ctx l s g) (sh : Shared)
    (r0 : sh.regions 0 = some partialRegion) (n : Nat) :
    ∃ t, (runThread C (n + 8) ⟨ctx, fun _ => none, [.block body], .running⟩).run sh =
      some (t, { sh with log := ((List.range 16).map fun i => entry ctx sh 0 (offset l s g + i) false).reverse ++ sh.log }) ∧
      AtSum ctx l s g (vals (sh.bytes 0) (offset l s g)) 0 t := by
  have hl := h.hl; have hs := h.hs; have hg := h.hg
  rw [runThread_set C _ rfl rfl (eval_lit C _ _ _ _)]
  rw [runThread_set C _ rfl rfl (eval_lit C _ _ _ _)]
  rw [runThread_set C _ rfl rfl (eval_coord C _ _ _ _)]
  rw [runThread_set C _ rfl rfl (eval_col C _ _ l s g h _)]
  have hload := loadAt_run ctx (.vec .f32 4) ⟨0, ((offset l s g : Nat) : Int), .vec .f32 4⟩ partialRegion sh
    (.vec .f32 (vals (sh.bytes 0) (offset l s g))) r0 (by decide) (Int.natCast_nonneg _) (by decide)
    (by simp [loadOffset, partialRegion, alignment, Ty.bytes, Scalar.bytes, offset, col]; omega)
    (by simp [loadOffset, partialRegion, Ty.bytes, Scalar.bytes, offset, col]; omega)
    (by simp [loadOffset, partialRegion]; rfl)
  rw [runThread_set C _ rfl rfl ((eval_load C _ _ _ _ _ _ _ (eval_addr C _ _ l s g h sh rfl (by simp [Thread.set, h.lane]) rfl)).trans hload)]
  rw [runThread_set C _ rfl rfl (eval_lit C _ _ _ _)]
  rw [runThread_loop_enter C _ rfl rfl (eval_cond C _ _ 0 (by decide) rfl _)]
  have hx : (vals (sh.bytes 0) (offset l s g))[0]? = some ((vals (sh.bytes 0) (offset l s g))[0]'(by simp [vals])) :=
    List.getElem?_eq_getElem _
  rw [runThread_collective C _ rfl rfl (eval_component C _ _ _ 0 _ (by decide) rfl rfl hx _) (eval_lit C _ _ _ _) rfl]
  exact ⟨_, rfl, ⟨rfl, rfl, ⟨_, hx, rfl⟩, rfl, rfl, by simp [Thread.set, h.lane], rfl, rfl, rfl⟩⟩

def outRegion : Region := ⟨.device, 10240, 16⟩

/-- What lane `l`'s `k`-th iteration does to memory: lane 0 stores `y` at `out[col + k]`. -/
def afterStore (ctx : Ctx) (sh : Shared) (l s g k : Nat) (y : BF) : Shared :=
  if l = 0 then { sh with
    log := ((List.range 2).map fun i => entry ctx sh 1 ((col s g + k) * 2 + i) true).reverse ++ sh.log,
    bytes := fun region => if region = 1 then writeBytes (sh.bytes region) ((col s g + k) * 2) (wordBytes 2 (Val.bf16Bits y))
      else sh.bytes region }
  else sh

theorem eval_lane0 (ctx : Ctx) (locals : Nat → Option Val) (l : Nat) (hl : l < 32) (h2 : locals 2 = some (u32 l))
    (sh : Shared) :
    (eval C ctx locals (.bin .eq .u32 0 (.local 2) (u32l 0))).run sh = some (.bool (decide (l = 0)), sh) := by
  have e : l % 4294967296 = l := Nat.mod_eq_of_lt (by omega)
  simp [eval, h2, u32, u32l, e, lift, lift2, binary, intCompare, Val.signed, Scalar.isSigned, Scalar.isInt,
    Scalar.width, Scalar.bytes, ordered_eq_compare]

theorem eval_target (ctx : Ctx) (locals : Nat → Option Val) (s g k : Nat) (hs : s < 8) (hg : g < 160) (hk : k < 4)
    (h1 : locals 1 = some p1) (h3 : locals 3 = some (u32 (col s g))) (h5 : locals 5 = some (u32 k)) (sh : Shared) :
    (eval C ctx locals (.offset (.local 1) (.bin .add .u32 0 (.local 3) (.local 5)))).run sh =
      some (.ptr ⟨1, (((col s g + k) * 2 : Nat) : Int), .scalar .bf16⟩, sh) := by
  have e1 : col s g % 4294967296 = col s g := Nat.mod_eq_of_lt (by unfold col; omega)
  have e2 : k % 4294967296 = k := Nat.mod_eq_of_lt (by omega)
  have e3 : ((col s g : Int) + k) % 4294967296 = col s g + k := Int.emod_eq_of_lt (by omega) (by unfold col; omega)
  simp [eval, h1, h3, h5, p1, u32, e1, e2, lift, lift2, binary, Val.signed, Val.wrap, Scalar.isSigned, Scalar.isInt,
    Scalar.width, Scalar.bytes, Ty.bytes, e3]
  omega
theorem eval_incr (ctx : Ctx) (locals : Nat → Option Val) (k : Nat) (hk : k < 4) (h5 : locals 5 = some (u32 k))
    (sh : Shared) :
    (eval C ctx locals (.bin .add .u32 0 (.local 5) (u32l 1))).run sh = some (u32 (k + 1), sh) := by
  have e : k % 4294967296 = k := Nat.mod_eq_of_lt (by omega)
  have e2 : ((k : Int) + 1) % 4294967296 = k + 1 := Int.emod_eq_of_lt (by omega) (by omega)
  simp [eval, h5, u32, u32l, e, lift, lift2, binary, Val.signed, Val.wrap, Scalar.isSigned, Scalar.isInt,
    Scalar.width, Scalar.bytes, e2]
  omega

theorem eval_narrow (ctx : Ctx) (locals : Nat → Option Val) (x : Float32) (h7 : locals 7 = some (.f32 x))
    (sh : Shared) : (eval C ctx locals (.conv .bf16 (.local 7))).run sh = some (.bf16 (C.narrow x), sh) := by
  simp [eval, h7, lift, lift1, convert]

/-- The store of iteration `k` by lane 0. -/
theorem store_run (ctx : Ctx) (s g k : Nat) (hs : s < 8) (hg : g < 160) (hk : k < 4) (y : BF) (sh : Shared)
    (r1 : sh.regions 1 = some outRegion) :
    (storeAt ctx (.scalar .bf16) ⟨1, (((col s g + k) * 2 : Nat) : Int), .scalar .bf16⟩ (.bf16 y)).run sh =
      some ((), afterStore ctx sh 0 s g k y) := by
  rw [storeAt_run ctx (.scalar .bf16) _ outRegion sh (.bf16 y) (wordBytes 2 (Val.bf16Bits y)) r1 (by decide) (by decide)
    (Int.natCast_nonneg _) (by decide) (by rw [Int.toNat_natCast]; simp [alignment, Scalar.bytes])
    (by rw [Int.toNat_natCast]; simp [outRegion, Ty.bytes, Scalar.bytes, col]; omega)
    (by simp [encode, Val.word, Scalar.bytes])]
  simp only [Int.toNat_natCast, afterStore, ite_true]
  rfl

theorem lane_next (ctx : Ctx) (l s g : Nat) (xs : List Val) (k : Nat) (t : Thread) (h : Lane ctx l s g)
    (ht : AtSum ctx l s g xs k t) (hk : k + 1 < 4) (hx : k + 1 < xs.length) (x : Float32) (sh : Shared)
    (r1 : sh.regions 1 = some outRegion) (n : Nat) :
    ∃ t', (runThread C (n + 10) ({ t with status := .running }.set 6 (.f32 x))).run sh =
      some (t', afterStore ctx sh l s g k (C.narrow x)) ∧ AtSum ctx l s g xs (k + 1) t' := by
  have hl := h.hl; have hs := h.hs; have hg := h.hg
  obtain ⟨hc, hf, _, h0, h1, h2, h3, h4, h5⟩ := ht
  subst hc
  rw [runThread_set C _ (rest := [iteStmt]) (fs := afterLoop) (slot := 7) (e := .local 6) (v := .f32 x) rfl
    (by simp [Thread.set, hf]) (eval_local C _ _ 6 _ (by simp [Thread.set]) _)]
  rw [runThread_ite C _ rfl rfl (eval_lane0 C _ _ l hl (by simp [Thread.set, h2]) _)]
  have hy : xs[k + 1]? = some (xs[k + 1]'hx) := List.getElem?_eq_getElem _
  by_cases hl0 : l = 0
  · subst hl0
    simp only [decide_true, ite_true]
    rw [runThread_store C _ rfl rfl (eval_target C _ _ s g k hs hg (by omega) (by simp [Thread.set, h1])
      (by simp [Thread.set, h3]) (by simp [Thread.set, h5]) _) (eval_narrow C _ _ x (by simp [Thread.set]) _)
      (store_run _ s g k hs hg (by omega) _ _ r1)]
    rw [runThread_pop C _ rfl rfl, runThread_pop C _ rfl rfl]
    rw [runThread_loop_next C _ rfl rfl]
    rw [runThread_set C _ rfl rfl (eval_incr C _ _ k (by omega) (by simp [Thread.set, h5]) _)]
    rw [runThread_pop C _ rfl rfl]
    rw [runThread_loop_test C _ rfl rfl (eval_cond C _ _ (k + 1) (by omega) (by simp [Thread.set]) _)]
    simp only [show decide (k + 1 < 4) = true from by simp [hk], ite_true]
    rw [runThread_collective C _ rfl rfl (eval_component C _ _ xs (k + 1) _ (by omega) (by simp [Thread.set, h4])
      (by simp [Thread.set]) hy _) (eval_lit C _ _ _ _) rfl]
    exact ⟨_, rfl, ⟨rfl, rfl, ⟨_, hy, rfl⟩, by simp [Thread.set, h0], by simp [Thread.set, h1],
      by simp [Thread.set, h2], by simp [Thread.set, h3], by simp [Thread.set, h4], by simp [Thread.set]⟩⟩
  · simp only [hl0, decide_false, Bool.false_eq_true, ite_false, afterStore]
    rw [runThread_pop C _ rfl rfl, runThread_pop C _ rfl rfl]
    rw [runThread_loop_next C _ rfl rfl]
    rw [runThread_set C _ rfl rfl (eval_incr C _ _ k (by omega) (by simp [Thread.set, h5]) _)]
    rw [runThread_pop C _ rfl rfl]
    rw [runThread_loop_test C _ rfl rfl (eval_cond C _ _ (k + 1) (by omega) (by simp [Thread.set]) _)]
    simp only [show decide (k + 1 < 4) = true from by simp [hk], ite_true]
    rw [runThread_collective C _ rfl rfl (eval_component C _ _ xs (k + 1) _ (by omega) (by simp [Thread.set, h4])
      (by simp [Thread.set]) hy _) (eval_lit C _ _ _ _) rfl]
    exact ⟨_, rfl, ⟨rfl, rfl, ⟨_, hy, rfl⟩, by simp [Thread.set, h0], by simp [Thread.set, h1],
      by simp [Thread.set, h2], by simp [Thread.set, h3], by simp [Thread.set, h4], by simp [Thread.set]⟩⟩
theorem lane_last (ctx : Ctx) (l s g : Nat) (xs : List Val) (t : Thread) (h : Lane ctx l s g)
    (ht : AtSum ctx l s g xs 3 t) (x : Float32) (sh : Shared) (r1 : sh.regions 1 = some outRegion) (n : Nat) :
    ∃ t', (runThread C (n + 11) ({ t with status := .running }.set 6 (.f32 x))).run sh =
      some (t', afterStore ctx sh l s g 3 (C.narrow x)) ∧ t'.status = .done := by
  have hl := h.hl; have hs := h.hs; have hg := h.hg
  obtain ⟨hc, hf, _, h0, h1, h2, h3, h4, h5⟩ := ht
  subst hc
  rw [runThread_set C _ (rest := [iteStmt]) (fs := afterLoop) (slot := 7) (e := .local 6) (v := .f32 x) rfl
    (by simp [Thread.set, hf]) (eval_local C _ _ 6 _ (by simp [Thread.set]) _)]
  rw [runThread_ite C _ rfl rfl (eval_lane0 C _ _ l hl (by simp [Thread.set, h2]) _)]
  have tail : ∀ (m : Nat) (sh' : Shared) (c : Ctx) (ls : Nat → Option Val), ls 5 = some (u32 3) →
      ∃ t', (runThread C (m + 8) ⟨c, ls, .block [] :: .block [] :: afterLoop, .running⟩).run sh' = some (t', sh') ∧
        t'.status = .done := by
    intro m sh' c ls h50
    rw [runThread_pop C _ rfl rfl, runThread_pop C _ rfl rfl, runThread_loop_next C _ rfl rfl]
    rw [runThread_set C _ rfl rfl (eval_incr C _ _ 3 (by omega) h50 _)]
    rw [runThread_pop C _ rfl rfl]
    rw [runThread_loop_test C _ rfl rfl (eval_cond C _ _ 4 (by omega) (by simp [Thread.set]) _)]
    simp only [show decide (4 < 4) = false from by decide, Bool.false_eq_true, ite_false]
    rw [runThread_pop C _ rfl rfl, runThread_done C _ rfl rfl, runThread_stop C _ rfl]
    exact ⟨_, rfl, rfl⟩
  by_cases hl0 : l = 0
  · subst hl0
    simp only [decide_true, ite_true]
    rw [runThread_store C _ rfl rfl (eval_target C _ _ s g 3 hs hg (by omega) (by simp [Thread.set, h1])
      (by simp [Thread.set, h3]) (by simp [Thread.set, h5]) _) (eval_narrow C _ _ x (by simp [Thread.set]) _)
      (store_run _ s g 3 hs hg (by omega) _ _ r1)]
    exact tail n _ _ _ (by simp [Thread.set, h5])
  · simp only [hl0, decide_false, Bool.false_eq_true, ite_false, afterStore]
    exact tail (n + 1) _ _ _ (by simp [Thread.set, h5])
end Metal.Kernels.DownFold

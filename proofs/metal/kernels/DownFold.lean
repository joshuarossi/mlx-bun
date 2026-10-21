import metal.Logic
import metal.Launch
import metal.tests.Elab
import metal.Gpu

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
/-! ## A SIMD-group -/

section Simd
variable (s g : Nat) (ctxOf : Fin 32 → Ctx)

def ctxAt (i : Nat) : Ctx := if h : i < 32 then ctxOf ⟨i, h⟩ else ctxOf 0

def start (l : Fin 32) : Thread := ⟨ctxOf l, fun _ => none, [.block body], .running⟩

/-- The shared state after lanes `0 … i-1` have run to the first `simd_sum`. -/
def afterStarts (sh : Shared) : Nat → Shared
  | 0 => sh
  | i + 1 =>
    let p := afterStarts sh i
    { p with log := ((List.range 16).map fun x => entry (ctxAt ctxOf i) p 0 (offset i s g + x) false).reverse ++ p.log }

theorem afterStarts_regions (sh : Shared) : ∀ i, (afterStarts s g ctxOf sh i).regions = sh.regions
  | 0 => rfl
  | i + 1 => afterStarts_regions sh i
theorem afterStarts_bytes (sh : Shared) : ∀ i, (afterStarts s g ctxOf sh i).bytes = sh.bytes
  | 0 => rfl
  | i + 1 => afterStarts_bytes sh i

theorem simd_starts (hlane : ∀ l : Fin 32, Lane (ctxOf l) l s g) (sh : Shared)
    (r0 : sh.regions 0 = some partialRegion) :
    ∃ U : Fin 32 → Thread, ((List.ofFn (start ctxOf)).mapM (runThread C 11)).run sh =
      some (List.ofFn U, afterStarts s g ctxOf sh 32) ∧
      ∀ l : Fin 32, AtSum (ctxOf l) l s g (vals (sh.bytes 0) (offset l s g)) 0 (U l) := by
  have spec := fun l : Fin 32 => lane_start C (ctxOf l) l s g (hlane l) (afterStarts s g ctxOf sh l)
    (by rw [afterStarts_regions]; exact r0) 3
  choose U hU using spec
  refine ⟨U, mapM_ofFn_run (start ctxOf) (runThread C 11) U (afterStarts s g ctxOf sh) (fun l => ?_), fun l => ?_⟩
  · have h := (hU l).1
    simp only [afterStarts, ctxAt, l.isLt, dite_true]
    exact h
  · have h := (hU l).2
    rwa [afterStarts_bytes] at h
/-- The shared state after all lanes ran iteration `k` from `sh`: lane 0's store. -/
def afterIter (sh : Shared) (k : Nat) (y : BF) (i : Nat) : Shared :=
  if i = 0 then sh else afterStore (ctxOf 0) sh 0 s g k y

theorem afterStore_regions (ctx : Ctx) (sh : Shared) (l k : Nat) (y : BF) :
    (afterStore ctx sh l s g k y).regions = sh.regions := by
  unfold afterStore; split <;> rfl

theorem afterIter_regions (sh : Shared) (k : Nat) (y : BF) (i : Nat) :
    (afterIter s g ctxOf sh k y i).regions = sh.regions := by
  unfold afterIter; split
  · rfl
  · exact afterStore_regions s g _ _ _ _ _

theorem afterIter_step (sh : Shared) (k : Nat) (y : BF) (l : Fin 32) :
    afterStore (ctxOf l) (afterIter s g ctxOf sh k y l) l s g k y = afterIter s g ctxOf sh k y (l + 1) := by
  by_cases h : (l : Nat) = 0
  · have hl : l = 0 := Fin.ext h
    subst hl; simp [afterIter]
  · simp [afterIter, h, afterStore]

theorem simd_next (hlane : ∀ l : Fin 32, Lane (ctxOf l) l s g) (k : Nat) (hk : k + 1 < 4)
    (T : Fin 32 → Thread) (xs : Fin 32 → List Val) (hT : ∀ l, AtSum (ctxOf l) l s g (xs l) k (T l))
    (hx : ∀ l, k + 1 < (xs l).length) (y : Float32) (sh : Shared) (r1 : sh.regions 1 = some outRegion) :
    ∃ U : Fin 32 → Thread, ((List.ofFn fun l => { T l with status := .running }.set 6 (.f32 y)).mapM (runThread C 11)).run sh =
      some (List.ofFn U, afterStore (ctxOf 0) sh 0 s g k (C.narrow y)) ∧
      ∀ l, AtSum (ctxOf l) l s g (xs l) (k + 1) (U l) := by
  have spec := fun l : Fin 32 => lane_next C (ctxOf l) l s g (xs l) k (T l) (hlane l) (hT l) hk (hx l) y
    (afterIter s g ctxOf sh k (C.narrow y) l) (by rw [afterIter_regions]; exact r1) 1
  choose U hU using spec
  refine ⟨U, ?_, fun l => (hU l).2⟩
  have := mapM_ofFn_run (fun l => { T l with status := .running }.set 6 (.f32 y)) (runThread C 11) U
    (afterIter s g ctxOf sh k (C.narrow y)) (fun l => by rw [← afterIter_step]; exact (hU l).1)
  rw [show afterIter s g ctxOf sh _ _ 0 = sh from if_pos rfl,
    show afterIter s g ctxOf sh _ _ 32 = afterStore (ctxOf 0) sh 0 s g _ _ from if_neg (by decide)] at this
  exact this

theorem simd_last (hlane : ∀ l : Fin 32, Lane (ctxOf l) l s g)
    (T : Fin 32 → Thread) (xs : Fin 32 → List Val) (hT : ∀ l, AtSum (ctxOf l) l s g (xs l) 3 (T l))
    (y : Float32) (sh : Shared) (r1 : sh.regions 1 = some outRegion) :
    ∃ U : Fin 32 → Thread, ((List.ofFn fun l => { T l with status := .running }.set 6 (.f32 y)).mapM (runThread C 11)).run sh =
      some (List.ofFn U, afterStore (ctxOf 0) sh 0 s g 3 (C.narrow y)) ∧ ∀ l, (U l).status = .done := by
  have spec := fun l : Fin 32 => lane_last C (ctxOf l) l s g (xs l) (T l) (hlane l) (hT l) y
    (afterIter s g ctxOf sh 3 (C.narrow y) l) (by rw [afterIter_regions]; exact r1) 0
  choose U hU using spec
  refine ⟨U, ?_, fun l => (hU l).2⟩
  have := mapM_ofFn_run (fun l => { T l with status := .running }.set 6 (.f32 y)) (runThread C 11) U
    (afterIter s g ctxOf sh 3 (C.narrow y)) (fun l => by rw [← afterIter_step]; exact (hU l).1)
  rw [show afterIter s g ctxOf sh _ _ 0 = sh from if_pos rfl,
    show afterIter s g ctxOf sh _ _ 32 = afterStore (ctxOf 0) sh 0 s g _ _ from if_neg (by decide)] at this
  exact this
/-- Float `k` of the float4 at byte `o`. -/
def cell (memory : ByteMemory.Bytes) (o k : Nat) : Float32 :=
  Val.ofF32Bits (bytesWord ((((List.range 16).map fun j => memory (o + j)).drop (4 * k)).take 4))

theorem vals_get (memory : ByteMemory.Bytes) (o k : Nat) (hk : k < 4) :
    (vals memory o)[k]? = some (.f32 (cell memory o k)) := by
  simp [vals, cell, Val.ofWord, hk]

theorem vals_length (memory : ByteMemory.Bytes) (o : Nat) : (vals memory o).length = 4 := by simp [vals]

/-- The sum of column `col s g + k` over the 32 rows. -/
def colSum (memory : ByteMemory.Bytes) (k : Nat) : Float32 := C.simdSum fun l => cell memory (offset l s g) k

theorem status_of (ctx : Ctx) (l : Nat) (memory : ByteMemory.Bytes) (k : Nat) (hk : k < 4) (t : Thread)
    (h : AtSum ctx l s g (vals memory (offset l s g)) k t) :
    t.status = .collective 1 6 .sum .f32 (.f32 (cell memory (offset l s g) k)) 0 := by
  obtain ⟨v, hv, hs⟩ := h.status
  rw [vals_get memory _ k hk] at hv
  rw [hs, ← Option.some.inj hv]

/-- The whole SIMD-group: four sums, lane 0 storing each. -/
theorem simd_run (hlane : ∀ l : Fin 32, Lane (ctxOf l) l s g) (sh : Shared)
    (r0 : sh.regions 0 = some partialRegion) (r1 : sh.regions 1 = some outRegion) :
    ∃ U : Fin 32 → Thread, (runSimd C 11 5 (List.ofFn (start ctxOf))).run sh = some (List.ofFn U,
      afterStore (ctxOf 0) (afterStore (ctxOf 0) (afterStore (ctxOf 0) (afterStore (ctxOf 0) (afterStarts s g ctxOf sh 32)
        0 s g 0 (C.narrow (colSum C s g (sh.bytes 0) 0))) 0 s g 1 (C.narrow (colSum C s g (sh.bytes 0) 1)))
        0 s g 2 (C.narrow (colSum C s g (sh.bytes 0) 2))) 0 s g 3 (C.narrow (colSum C s g (sh.bytes 0) 3))) ∧
      ∀ l, (U l).status = .done := by
  have rs1 := r1
  obtain ⟨U0, h0, a0⟩ := simd_starts C s g ctxOf hlane sh r0
  rw [runSimd_sum C 11 4 _ U0 _ _ 1 6 0 (fun l => cell (sh.bytes 0) (offset l s g) 0) h0
    (fun l => status_of s g _ l _ 0 (by decide) _ (a0 l)), List.map_ofFn]
  have r1' : (afterStarts s g ctxOf sh 32).regions 1 = some outRegion := by rw [afterStarts_regions]; exact r1
  obtain ⟨U1, h1, a1⟩ := simd_next C s g ctxOf hlane 0 (by decide) U0 _ a0 (fun l => by simp [vals_length])
    (C.simdSum fun l => cell (sh.bytes 0) (offset l s g) 0) _ r1'
  simp only [Function.comp_def]
  rw [runSimd_sum C 11 3 _ U1 _ _ 1 6 0 (fun l => cell (sh.bytes 0) (offset l s g) 1) h1
    (fun l => status_of s g _ l _ 1 (by decide) _ (a1 l)), List.map_ofFn]
  obtain ⟨U2, h2, a2⟩ := simd_next C s g ctxOf hlane 1 (by decide) U1 _ a1 (fun l => by simp [vals_length])
    (C.simdSum fun l => cell (sh.bytes 0) (offset l s g) 1)
    (afterStore (ctxOf 0) (afterStarts s g ctxOf sh 32) 0 s g 0 (C.narrow (C.simdSum fun l => cell (sh.bytes 0) (offset l s g) 0)))
    (by rw [afterStore_regions s g]; exact r1')
  simp only [Function.comp_def]
  rw [runSimd_sum C 11 2 _ U2 _ _ 1 6 0 (fun l => cell (sh.bytes 0) (offset l s g) 2) h2
    (fun l => status_of s g _ l _ 2 (by decide) _ (a2 l)), List.map_ofFn]
  obtain ⟨U3, h3, a3⟩ := simd_next C s g ctxOf hlane 2 (by decide) U2 _ a2 (fun l => by simp [vals_length])
    (C.simdSum fun l => cell (sh.bytes 0) (offset l s g) 2)
    (afterStore (ctxOf 0) (afterStore (ctxOf 0) (afterStarts s g ctxOf sh 32) 0 s g 0
      (C.narrow (C.simdSum fun l => cell (sh.bytes 0) (offset l s g) 0))) 0 s g 1
      (C.narrow (C.simdSum fun l => cell (sh.bytes 0) (offset l s g) 1)))
    (by rw [afterStore_regions s g, afterStore_regions s g]; exact r1')
  simp only [Function.comp_def]
  rw [runSimd_sum C 11 1 _ U3 _ _ 1 6 0 (fun l => cell (sh.bytes 0) (offset l s g) 3) h3
    (fun l => status_of s g _ l _ 3 (by decide) _ (a3 l)), List.map_ofFn]
  obtain ⟨U4, h4, a4⟩ := simd_last C s g ctxOf hlane U3 _ a3
    (C.simdSum fun l => cell (sh.bytes 0) (offset l s g) 3)
    (afterStore (ctxOf 0) (afterStore (ctxOf 0) (afterStore (ctxOf 0) (afterStarts s g ctxOf sh 32) 0 s g 0
      (C.narrow (C.simdSum fun l => cell (sh.bytes 0) (offset l s g) 0))) 0 s g 1
      (C.narrow (C.simdSum fun l => cell (sh.bytes 0) (offset l s g) 1))) 0 s g 2
      (C.narrow (C.simdSum fun l => cell (sh.bytes 0) (offset l s g) 2)))
    (by rw [afterStore_regions s g, afterStore_regions s g, afterStore_regions s g]; exact r1')
  simp only [Function.comp_def]
  rw [runSimd_blocked C 11 0 _ (List.ofFn U4) _ _ h4 (fun t ht => by
    obtain ⟨i, rfl⟩ := List.mem_ofFn.mp ht; simp [a4 i, blocked])]
  exact ⟨U4, rfl, a4⟩
end Simd
/-! ## The grid -/

/-- The bf16 output of column `c` (= `32g + 4s + k`). -/
def outValue (P : ByteMemory.Bytes) (c : Nat) : BF := C.narrow (colSum C (c % 32 / 4) (c / 32) P (c % 4))

/-- The thread that writes column `c`: lane 0 of its SIMD-group. -/
def owner (c : Nat) : Nat := c / 32 * 256 + 32 * (c % 32 / 4)

def Good (e : Access) : Prop :=
  (e.region = 0 ∧ e.write = false) ∨ (e.region = 1 ∧ e.write = true ∧ e.thread = owner (e.byte / 2))

/-- Columns `0 … n-1` are written, the input is intact, and every access so far is a read of
`partial` or a write by its column's owner. -/
structure Inv (regions : Nat → Option Region) (P : ByteMemory.Bytes) (n : Nat) (sh : Shared) : Prop where
  regions : sh.regions = regions
  input : sh.bytes 0 = P
  epochs : sh.deviceEpoch = 0 ∧ sh.groupEpoch = 0
  out : ∀ c < n, ∀ i < 2, sh.bytes 1 (2 * c + i) = (wordBytes 2 (Val.bf16Bits (outValue C P c))).getD i 0
  log : ∀ e ∈ sh.log, Good e
theorem writeBytes_outside (memory : ByteMemory.Bytes) (o : Nat) (bytes : List (BitVec 8)) (b : Nat)
    (h : b < o ∨ o + bytes.length ≤ b) : writeBytes memory o bytes b = memory b := by
  unfold writeBytes; split
  · omega
  · rfl

theorem writeBytes_inside (memory : ByteMemory.Bytes) (o : Nat) (bytes : List (BitVec 8)) (i : Nat)
    (h : i < bytes.length) : writeBytes memory o bytes (o + i) = bytes.getD i 0 := by
  unfold writeBytes; rw [if_pos (by omega)]; congr 1; omega

/-- Lane 0's store of iteration `k` keeps the invariant's facts about everything else. -/
theorem afterStore_zero (ctx : Ctx) (sh : Shared) (s g k : Nat) (y : BF) :
    afterStore ctx sh 0 s g k y = { sh with
      log := ((List.range 2).map fun i => entry ctx sh 1 ((col s g + k) * 2 + i) true).reverse ++ sh.log,
      bytes := fun region => if region = 1 then writeBytes (sh.bytes region) ((col s g + k) * 2)
        (wordBytes 2 (Val.bf16Bits y)) else sh.bytes region } := by
  simp [afterStore]

theorem afterStarts_epochs (s g : Nat) (ctxOf : Fin 32 → Ctx) (sh : Shared) : ∀ i,
    (afterStarts s g ctxOf sh i).deviceEpoch = sh.deviceEpoch ∧ (afterStarts s g ctxOf sh i).groupEpoch = sh.groupEpoch
  | 0 => ⟨rfl, rfl⟩
  | i + 1 => afterStarts_epochs s g ctxOf sh i

theorem afterStarts_log (s g : Nat) (ctxOf : Fin 32 → Ctx) (sh : Shared) (hsh : ∀ e ∈ sh.log, Good e) :
    ∀ i, ∀ e ∈ (afterStarts s g ctxOf sh i).log, Good e
  | 0 => hsh
  | i + 1 => by
    intro e he
    simp only [afterStarts, List.mem_append, List.mem_reverse, List.mem_map, List.mem_range] at he
    rcases he with ⟨x, _, rfl⟩ | he
    · left; exact ⟨rfl, rfl⟩
    · exact afterStarts_log s g ctxOf sh hsh i e he
theorem simd_inv (R : Nat → Option Region) (hR0 : R 0 = some partialRegion) (hR1 : R 1 = some outRegion)
    (P : ByteMemory.Bytes) (s g : Nat) (hs : s < 8) (hg : g < 160) (ctxOf : Fin 32 → Ctx)
    (hlane : ∀ l : Fin 32, Lane (ctxOf l) l s g) (hthread : (ctxOf 0).thread = g * 256 + 32 * s)
    (sh : Shared) (hI : Inv C R P (32 * g + 4 * s) sh) :
    ∃ lanes sh', (runSimd C 11 5 (List.ofFn (start ctxOf))).run sh = some (lanes, sh') ∧
      Inv C R P (32 * g + 4 * s + 4) sh' ∧ ∀ t ∈ lanes, t.status = .done := by
  obtain ⟨U, hrun, hdone⟩ := simd_run C s g ctxOf hlane sh (by rw [hI.regions]; exact hR0) (by rw [hI.regions]; exact hR1)
  refine ⟨_, _, hrun, ?_, fun t ht => by obtain ⟨i, rfl⟩ := List.mem_ofFn.mp ht; exact hdone i⟩
  have hc : col s g = 32 * g + 4 * s := by unfold col; ring
  have e0 := (afterStarts_epochs s g ctxOf sh 32)
  constructor
  · simp only [afterStore_regions s g, afterStarts_regions]; exact hI.regions
  · simp only [afterStore_zero, afterStarts_bytes]; simpa using hI.input
  · simp only [afterStore_zero]; exact ⟨e0.1.trans hI.epochs.1, e0.2.trans hI.epochs.2⟩
  · intro c hcn i hi
    simp only [afterStore_zero, if_true, afterStarts_bytes, hI.input]
    have hlen : ∀ w, (wordBytes 2 w).length = 2 := by simp [wordBytes]
    by_cases h0 : c < 32 * g + 4 * s
    · rw [writeBytes_outside _ ((col s g + 3) * 2) _ _ (by simp [hlen]; omega),
        writeBytes_outside _ ((col s g + 2) * 2) _ _ (by simp [hlen]; omega),
        writeBytes_outside _ ((col s g + 1) * 2) _ _ (by simp [hlen]; omega),
        writeBytes_outside _ ((col s g + 0) * 2) _ _ (by simp [hlen]; omega)]
      exact hI.out c h0 i hi
    · obtain ⟨k, hk, rfl⟩ : ∃ k, k < 4 ∧ c = 32 * g + 4 * s + k := ⟨c - (32 * g + 4 * s), by omega, by omega⟩
      have hv : ∀ k < 4, C.narrow (colSum C s g P k) = outValue C P (32 * g + 4 * s + k) := by
        intro k hk; unfold outValue
        rw [show (32 * g + 4 * s + k) % 32 / 4 = s by omega, show (32 * g + 4 * s + k) / 32 = g by omega,
          show (32 * g + 4 * s + k) % 4 = k by omega]
      rcases (by omega : k = 0 ∨ k = 1 ∨ k = 2 ∨ k = 3) with rfl | rfl | rfl | rfl
      · rw [writeBytes_outside _ ((col s g + 3) * 2) _ _ (by simp [hlen]; omega)]
        rw [writeBytes_outside _ ((col s g + 2) * 2) _ _ (by simp [hlen]; omega)]
        rw [writeBytes_outside _ ((col s g + 1) * 2) _ _ (by simp [hlen]; omega)]
        rw [show 2 * (32 * g + 4 * s + 0) + i = (col s g + 0) * 2 + i by rw [hc]; ring,
          writeBytes_inside _ _ _ i (by simp [hlen]; omega), hv 0 (by decide)]
      · rw [writeBytes_outside _ ((col s g + 3) * 2) _ _ (by simp [hlen]; omega)]
        rw [writeBytes_outside _ ((col s g + 2) * 2) _ _ (by simp [hlen]; omega)]
        rw [show 2 * (32 * g + 4 * s + 1) + i = (col s g + 1) * 2 + i by rw [hc]; ring,
          writeBytes_inside _ _ _ i (by simp [hlen]; omega), hv 1 (by decide)]
      · rw [writeBytes_outside _ ((col s g + 3) * 2) _ _ (by simp [hlen]; omega)]
        rw [show 2 * (32 * g + 4 * s + 2) + i = (col s g + 2) * 2 + i by rw [hc]; ring,
          writeBytes_inside _ _ _ i (by simp [hlen]; omega), hv 2 (by decide)]
      · rw [show 2 * (32 * g + 4 * s + 3) + i = (col s g + 3) * 2 + i by rw [hc]; ring,
          writeBytes_inside _ _ _ i (by simp [hlen]; omega), hv 3 (by decide)]
  · intro e he
    have hown : ∀ k < 4, ∀ x < 2, owner (((col s g + k) * 2 + x) / 2) = g * 256 + 32 * s := by
      intro k hk x hx; unfold owner col; omega
    have store : ∀ k < 4, ∀ x < 2, ∀ (d gr : Nat),
        Good ⟨(ctxOf 0).thread, (ctxOf 0).group, 1, (col s g + k) * 2 + x, true, d, gr⟩ := by
      intro k hk x hx d gr; right; exact ⟨rfl, rfl, by simp only [hthread, hown k hk x hx]⟩
    simp only [afterStore_zero, entry, List.mem_append, List.mem_reverse, List.mem_map, List.mem_range] at he
    rcases he with ⟨x, hx, rfl⟩ | ⟨x, hx, rfl⟩ | ⟨x, hx, rfl⟩ | ⟨x, hx, rfl⟩ | he
    · exact store 3 (by decide) x hx _ _
    · exact store 2 (by decide) x hx _ _
    · exact store 1 (by decide) x hx _ _
    · exact store 0 (by decide) x hx _ _
    · exact afterStarts_log s g ctxOf sh hI.log 32 e he
/-- The launch: grid [8·C = 40960], threadgroup [256], `partial` [1, 32, 5120] f32 and `out` [1, 5120] bf16. -/
def launch (P O : ByteMemory.Bytes) : Launch :=
  ⟨core, (40960, 1, 1), (256, 1, 1), [⟨.device, 655360, 16, P⟩, ⟨.device, 10240, 16, O⟩]⟩

theorem launch_group (P O : ByteMemory.Bytes) : (launch P O).group = (256, 1, 1) := rfl
theorem launch_groups (P O : ByteMemory.Bytes) : (launch P O).groups = (160, 1, 1) := by
  simp only [Launch.groups, Launch.group, launch]; decide

theorem threads_length (P O : ByteMemory.Bytes) (fuse : Nat → Bool) (g : Nat) (hg : g < 160) :
    ((launch P O).threads fuse g 0 0).length = 256 := by
  simp only [Launch.threads, launch_group, launch_groups, List.length_map, List.length_range]
  simp [launch]; omega

/-- Thread `32 s + l` of threadgroup `g`. -/
theorem thread_get (P O : ByteMemory.Bytes) (fuse : Nat → Bool) (g : Nat) (hg : g < 160) (i : Nat) (hi : i < 256)
    (h : i < ((launch P O).threads fuse g 0 0).length) :
    ((launch P O).threads fuse g 0 0)[i] = { ((launch P O).threads fuse g 0 0)[i] with
      locals := fun _ => none, frames := [.block body], status := .running } ∧
    ((launch P O).threads fuse g 0 0)[i].ctx.thread = g * 256 + i ∧
    ((launch P O).threads fuse g 0 0)[i].ctx.coord .threadIndexInSimdgroup = u32 (i % 32) ∧
    ((launch P O).threads fuse g 0 0)[i].ctx.coord .simdgroupIndexInThreadgroup = u32 (i / 32) ∧
    ((launch P O).threads fuse g 0 0)[i].ctx.coord .threadgroupPositionInGrid = u32x3 g 0 0 := by
  simp only [Launch.threads, launch_group, launch_groups, List.getElem_map, List.getElem_range]
  simp [launch, core]
  all_goals omega
/-- The contexts of SIMD-group `s` of threadgroup `g`. -/
def ctxs (P O : ByteMemory.Bytes) (fuse : Nat → Bool) (g : Nat) (hg : g < 160) (s : Fin 8) (l : Fin 32) : Ctx :=
  ((launch P O).threads fuse g 0 0)[32 * s.val + l.val]'(by rw [threads_length P O fuse g hg]; omega) |>.ctx

theorem chunks_eq (P O : ByteMemory.Bytes) (fuse : Nat → Bool) (g : Nat) (hg : g < 160) :
    Launch.chunks 32 ((launch P O).threads fuse g 0 0) = List.ofFn fun s => List.ofFn (start (ctxs P O fuse g hg s)) := by
  have hl := threads_length P O fuse g hg
  apply List.ext_getElem
  · simp [Launch.chunks, hl, ceilDiv]
  · intro s h1 h2
    simp only [List.length_ofFn] at h2
    simp only [List.getElem_ofFn]
    apply List.ext_getElem
    · simp [Launch.chunks, hl]; omega
    · intro l h3 h4
      simp only [List.length_ofFn] at h4
      simp only [Launch.chunks, List.getElem_map, List.getElem_range, List.getElem_take, List.getElem_drop, List.getElem_ofFn]
      have := (thread_get P O fuse g hg (s * 32 + l) (by omega) (by rw [hl]; omega)).1
      rw [this]
      simp only [start, ctxs, Nat.mul_comm s 32]

theorem ctxs_lane (P O : ByteMemory.Bytes) (fuse : Nat → Bool) (g : Nat) (hg : g < 160) (s : Fin 8) (l : Fin 32) :
    Lane (ctxs P O fuse g hg s l) l s g := by
  have h := thread_get P O fuse g hg (32 * s.val + l.val) (by omega) (by rw [threads_length P O fuse g hg]; omega)
  refine ⟨?_, ?_, h.2.2.2.2, l.isLt, s.isLt, hg⟩
  · simp only [ctxs, h.2.2.1]; congr 1; omega
  · simp only [ctxs, h.2.2.2.1]; congr 1; omega

theorem ctxs_thread (P O : ByteMemory.Bytes) (fuse : Nat → Bool) (g : Nat) (hg : g < 160) (s : Fin 8) :
    (ctxs P O fuse g hg s 0).thread = g * 256 + 32 * s := by
  have h := thread_get P O fuse g hg (32 * s.val) (by omega) (by rw [threads_length P O fuse g hg]; omega)
  simp only [ctxs, Fin.val_zero, Nat.add_zero]; exact h.2.1
theorem launch_r0 (P O : ByteMemory.Bytes) : (launch P O).regions 0 = some partialRegion := by
  simp [Launch.regions, launch, partialRegion]
theorem launch_r1 (P O : ByteMemory.Bytes) : (launch P O).regions 1 = some outRegion := by
  simp [Launch.regions, launch, outRegion]

theorem group_inv (P O : ByteMemory.Bytes) (fuse : Nat → Bool) (g : Nat) (hg : g < 160) (sh : Shared)
    (hI : Inv C (launch P O).regions P (32 * g) sh) :
    ∃ sh', (runGroup C 11 5 1 (Launch.chunks 32 ((launch P O).threads fuse g 0 0))).run sh = some ((), sh') ∧
      Inv C (launch P O).regions P (32 * g + 32) sh' := by
  rw [chunks_eq P O fuse g hg]
  obtain ⟨us, sh', hrun, hI', hdone⟩ := mapM_ofFn_inv (fun s => List.ofFn (start (ctxs P O fuse g hg s))) (runSimd C 11 5)
    (fun j sh => Inv C (launch P O).regions P (32 * g + 4 * j) sh) (fun lanes => ∀ t ∈ lanes, t.status = .done)
    (fun j sh hj => by
      have := simd_inv C (launch P O).regions (launch_r0 P O) (launch_r1 P O) P j g j.isLt hg (ctxs P O fuse g hg j)
        (ctxs_lane P O fuse g hg j) (ctxs_thread P O fuse g hg j) sh hj
      rwa [show 32 * g + 4 * (j.val + 1) = 32 * g + 4 * j.val + 4 by ring]) sh (by simpa using hI)
  refine ⟨sh', ?_, by simpa using hI'⟩
  have hall : (us.flatten.all fun t => isDone t.status) = true := by
    simp only [List.all_eq_true, List.mem_flatten]
    rintro t ⟨lanes, hl, ht⟩
    simp [hdone lanes hl t ht, isDone]
  simp only [runGroup, StateT.run_bind, hrun]
  show Option.bind (some (us, sh')) _ = _
  simp only [Option.bind_some]
  rw [if_pos hall]
  rfl
theorem resetGroup_id (P O : ByteMemory.Bytes) (garbage : Garbage) (g : Nat) (bytes : Nat → ByteMemory.Bytes) :
    (launch P O).resetGroup garbage g bytes = bytes := by
  funext region
  simp [Launch.resetGroup, Launch.groupArrays, launch, core]
  omega

theorem launch_run (P O : ByteMemory.Bytes) (fuse : Nat → Bool) (garbage : Garbage) :
    ∃ r, runLaunch C fuse (launch P O) garbage 11 5 1 = some r ∧
      (∀ e ∈ r.log, Good e) ∧ ∀ c < 5120, ∀ i < 2, r.buffers 1 (2 * c + i) = (wordBytes 2 (Val.bf16Bits (outValue C P c))).getD i 0 := by
  simp only [runLaunch, launch_groups]
  obtain ⟨sh', hrun, hI⟩ := forM_inv (fun x : Nat × Nat × Nat => (do
      modify fun (sh : Shared) => { sh with bytes := (launch P O).resetGroup garbage (x.1 + x.2.1 * 160 + x.2.2 * 160 * 1) sh.bytes }
      runGroup C 11 5 1 (Launch.chunks 32 ((launch P O).threads fuse x.1 x.2.1 x.2.2)) : M Unit))
    (fun j sh => Inv C (launch P O).regions P (32 * j) sh)
    ((List.range (160 * 1 * 1)).map fun g => (g % 160, g / 160 % 1, g / (160 * 1))) 0 (fun j hj sh hI => by
      simp only [List.length_map, List.length_range] at hj
      simp only [List.getElem_map, List.getElem_range, Nat.zero_add] at hI ⊢
      rw [show j % 160 = j from Nat.mod_eq_of_lt (by omega), show j / 160 % 1 = 0 by omega, show j / (160 * 1) = 0 by omega]
      obtain ⟨sh2, h2, hI2⟩ := group_inv C P O fuse j (by omega) sh hI
      refine ⟨sh2, ?_, by rwa [show 32 * (j + 1) = 32 * j + 32 by ring]⟩
      simp only [StateT.run_bind, resetGroup_id]
      exact h2) ((launch P O).initial garbage) ⟨rfl, rfl, ⟨rfl, rfl⟩, fun c hc => by omega, fun e he => by simp [Launch.initial] at he⟩
  refine ⟨_, by rw [hrun]; rfl, hI.log, fun c hc i hi => hI.out c (by simpa using hc) i hi⟩
theorem race_free (P O : ByteMemory.Bytes) (r : Result) (h : ∀ e ∈ r.log, Good e) : RaceFree (launch P O) r := by
  intro a ha b hb hc
  obtain ⟨hreg, hbyte, hthr, hw, _⟩ := hc
  rcases h a ha with ⟨ra, wa⟩ | ⟨ra, wa, ta⟩ <;> rcases h b hb with ⟨rb, wb⟩ | ⟨rb, wb, tb⟩
  · simp [wa, wb] at hw
  · omega
  · omega
  · exact hthr (by rw [ta, tb, hbyte])

/-- Output byte `b` of `out`: byte `b % 2` of the bf16 word of column `b / 2`. -/
def expected (P : ByteMemory.Bytes) (b : Nat) : BitVec 8 :=
  if b < 10240 then (wordBytes 2 (Val.bf16Bits (outValue C P (b / 2)))).getD (b % 2) 0 else 0

/-- **The GPU runs the down-fold kernel as specified.** Under the GPU assumption, MLX's launch of the
exact assembled text on any `partial` buffer produces `out` with every column `c` equal to the
bf16 narrowing of the SIMD sum of the 32 floats of column `c`. -/
theorem gpu_output (G : Gpu C) (hmax : 256 ≤ G.maxThreads Metal.Elab.Tests.downFoldText) (P : ByteMemory.Bytes) :
    G.execute Metal.Elab.Tests.downFoldText (40960, 1, 1) (256, 1, 1) [⟨.device, 655360, 16, P⟩] [10240] =
      some [expected C P] := by
  apply G.runs_as_modeled _ core _ _ _ _ 11 5 1 _ compile_eq (by simpa using hmax)
  intro initial garbage
  obtain ⟨r, hr, hlog, hout⟩ := launch_run C P (initial 0) (G.fusion Metal.Elab.Tests.downFoldText) garbage
  have hL : (⟨core, (40960, 1, 1), (256, 1, 1), buffers [⟨.device, 655360, 16, P⟩] [10240] 16 initial⟩ : Launch) =
      launch P (initial 0) := rfl
  refine ⟨r, by rw [hL]; exact hr, by rw [hL]; exact race_free P (initial 0) r hlog, ?_⟩
  simp only [outputs, List.zipIdx, List.map_cons, List.map_nil, List.cons.injEq, and_true]
  funext b
  unfold expected
  split
  · rename_i hb
    have := hout (b / 2) (by omega) (b % 2) (by omega)
    rw [show 2 * (b / 2) + b % 2 = b by omega] at this
    simpa using this
  · rfl
end Metal.Kernels.DownFold

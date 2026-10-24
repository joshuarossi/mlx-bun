import metal.Logic
import metal.Launch
import metal.tests.Elab
import metal.Gpu
import metal.Steps
import metal.Group
import metal.Memory
import metal.Fuel

namespace Metal.Kernels.GatedRmsNorm
open Metal Metal.Core Inference.Contracts.Mlx

/-! # gated-rms-norm.ts

```
const uint row = threadgroup_position_in_grid.x;
const uint lane = thread_index_in_simdgroup;
float acc = 0.0f;
const uint tid = thread_position_in_threadgroup.x;
threadgroup float sums[32];
threadgroup float inverse[1];
for (uint r = 0; r < uint(D); r += uint(THREADS) * 4u) {
  for (uint i = 0; i < 4u; ++i) {
    const uint col = r + tid * 4u + i;
    const float value = col < uint(D) ? float(x[row * uint(D) + col]) : 0.0f;
    acc += value * value;
  }
}
acc = metal::simd_sum(acc);
if (THREADS > 32) {
  const uint sg = simdgroup_index_in_threadgroup;
  if (sg == 0) sums[lane] = 0.0f;
  threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  if (lane == 0) sums[sg] = acc;
  threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  if (sg == 0) {
    acc = metal::simd_sum(sums[lane]);
    if (lane == 0) inverse[0] = metal::precise::rsqrt(acc / float(D) + as_type<float>(uint(EPS)));
  }
  threadgroup_barrier(metal::mem_flags::mem_threadgroup);
}
const float inv = THREADS > 32 ? inverse[0]
  : metal::precise::rsqrt(acc / float(D) + as_type<float>(uint(EPS)));
for (uint r = 0; r < uint(D); r += uint(THREADS) * 4u) {
  for (uint i = 0; i < 4u; ++i) {
    const uint col = r + tid * 4u + i, index = row * uint(D) + col;
    if (col >= uint(D)) continue;
    const T normalized = weight[col] * T(float(x[index]) * inv);
    const float g = float(gate[index]);
    const float y = 1.0f / (1.0f + metal::exp(metal::abs(g)));
    const float sigmoid = g < 0.0f ? y : 1.0f - y;
    out[index] = T((g * sigmoid) * float(normalized));
  }
}
```
at `gatedNormConfig`: grid [1536, 1, 1], threadgroup [32, 1, 1], so 48 threadgroups of one SIMD-group, with
D = 128, THREADS = 32, EPS = 897988541 (the f32 word 0x358637BD of 1e-6). -/

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)
def u16l (n : Nat) : CExpr := .lit (.int .u16 n)
def f32l (bits : Nat) : CExpr := .lit (.f32 (Val.ofF32Bits bits))

def sumRowCond : CExpr := .bin .lt .u32 0 (.local 10) (u32l 128)
def sumRowStep : List CStmt := [.set 10 (.bin .add .u32 0 (.local 10) (u32l 128))]
def sumColCond : CExpr := .bin .lt .u32 0 (.local 11) (u32l 4)
def sumColStep : List CStmt := [.set 11 (.bin .add .u32 0 (.local 11) (u32l 1))]
def sumColBody : List CStmt :=
  [.set 12 (.bin .add .u32 0 (.bin .add .u32 0 (.local 10) (.bin .mul .u32 0 (.local 7) (u32l 4))) (.local 11)),
   .set 13
     (.cond (.bin .lt .u32 0 (.local 12) (u32l 128))
        (.conv .f32
          (.load (.scalar .bf16)
            (.offset (.local 0) (.bin .add .u32 0 (.bin .mul .u32 0 (.local 4) (u32l 128)) (.local 12)))))
        (f32l 0x0)),
   .set 6 (.bin .add .f32 1 (.local 6) (.bin .mul .f32 0 (.local 13) (.local 13)))]
def sumColLoop : CStmt := .loop sumColCond sumColStep sumColBody
def sumRowBody : List CStmt := [.set 11 (u32l 0), sumColLoop]

def outRowCond : CExpr := .bin .lt .u32 0 (.local 18) (u32l 128)
def outRowStep : List CStmt := [.set 18 (.bin .add .u32 0 (.local 18) (u32l 128))]
def outColCond : CExpr := .bin .lt .u32 0 (.local 19) (u32l 4)
def outColStep : List CStmt := [.set 19 (.bin .add .u32 0 (.local 19) (u32l 1))]
def padStmt : CStmt := .ite (.bin .ge .u32 0 (.local 20) (u32l 128)) [.continue_] []
def normalizedExpr : CExpr :=
  .bin .mul .bf16 0 (.load (.scalar .bf16) (.offset (.local 2) (.local 20)))
    (.conv .bf16 (.bin .mul .f32 0 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 0) (.local 21)))) (.local 17)))
def yExpr : CExpr :=
  .bin .div .f32 0 (f32l 0x3F800000)
    (.bin .add .f32 0 (f32l 0x3F800000) (.un .fastExp .f32 (.un .fastFabs .f32 (.local 23))))
def sigmoidExpr : CExpr :=
  .cond (.bin .lt .f32 0 (.local 23) (f32l 0x0)) (.local 24) (.bin .sub .f32 0 (f32l 0x3F800000) (.local 24))
def outStore : CStmt :=
  .store (.scalar .bf16) (.offset (.local 3) (.local 21))
    (.conv .bf16 (.bin .mul .f32 0 (.bin .mul .f32 0 (.local 23) (.local 25)) (.conv .f32 (.local 22))))
def outColBody : List CStmt :=
  [.set 20 (.bin .add .u32 0 (.bin .add .u32 0 (.local 18) (.bin .mul .u32 0 (.local 7) (u32l 4))) (.local 19)),
   .set 21 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 4) (u32l 128)) (.local 20)),
   padStmt,
   .set 22 normalizedExpr,
   .set 23 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 1) (.local 21)))),
   .set 24 yExpr,
   .set 25 sigmoidExpr,
   outStore]
def outColLoop : CStmt := .loop outColCond outColStep outColBody
def outRowBody : List CStmt := [.set 19 (u32l 0), outColLoop]

/-- Slots: 0 x, 1 gate, 2 weight, 3 out, 4 row, 5 lane, 6 acc, 7 tid, 8 sums (threadgroup array 0),
9 inverse (threadgroup array 1), 10 r, 11 i, 12 col, 13 value, 14 the `simd_sum` result,
15 and 16 unused (the discarded `THREADS > 32` branch), 17 inv, 18 r, 19 i, 20 col, 21 index, 22 normalized,
23 g, 24 y, 25 sigmoid. -/
def body : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .bf16⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .bf16⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .bf16⟩)),
   .set 4 (.component (.coord .threadgroupPositionInGrid) (u32l 0)),
   .set 5 (.coord .threadIndexInSimdgroup),
   .set 6 (f32l 0x0),
   .set 7 (.component (.coord .threadPositionInThreadgroup) (u32l 0)),
   .array 8 true 0 (.scalar .f32),
   .array 9 true 1 (.scalar .f32),
   .set 10 (u32l 0),
   .loop sumRowCond sumRowStep sumRowBody,
   .collective 2 14 .sum .f32 (.local 6) (u16l 0),
   .set 6 (.local 14),
   .set 17
     (.un .rsqrt .f32
       (.bin .add .f32 0 (.conv .f32 (.bin .mul .f32 0 (.local 6) (f32l 0x3C000000))) (f32l 0x358637BD))),
   .set 18 (u32l 0),
   .loop outRowCond outRowStep outRowBody]

def core : Kernel := ⟨4, [(.scalar .f32, 32), (.scalar .f32, 1)], [], body⟩

-- The elaborated text MLX compiles (tests/Assemble.lean) is `core`.
kernel_rfl compile_eq : (frontend Metal.Elab.Tests.gatedRmsNormText).bind elaborate = some core

variable (C : M1Max.Contract)

/-! ## Expected outputs

The quantities of the source, on the bf16 elements of the inputs, with the operations the core
applies. `fuse` is the compiler's choice at contraction site 1 (`acc += value * value`), the core's
only contraction site (site 2 is the `simd_sum`). -/

def zero : Float32 := Val.ofF32Bits 0
def one : Float32 := Val.ofF32Bits 0x3F800000

/-- `float(x[e])`. -/
def xf (X : ByteMemory.Bytes) (e : Nat) : Float32 := C.widen (bfAt X e)

/-- `acc` of lane `lane` of row `row` after its first `k` columns `4·lane + k` (`acc += value * value`). -/
def sumSq (fuse : Bool) (X : ByteMemory.Bytes) (row lane : Nat) : Nat → Float32
  | 0 => zero
  | k + 1 =>
    if fuse then C.fma (xf C X (row * 128 + (lane * 4 + k))) (xf C X (row * 128 + (lane * 4 + k))) (sumSq fuse X row lane k)
    else C.fadd (sumSq fuse X row lane k) (C.fmul (xf C X (row * 128 + (lane * 4 + k))) (xf C X (row * 128 + (lane * 4 + k))))

/-- `simd_sum(acc)`: the row's sum of squares. -/
def rowSum (fuse : Bool) (X : ByteMemory.Bytes) (row : Nat) : Float32 := C.simdSum fun lane => sumSq C fuse X row lane 4

/-- `rsqrt(acc / float(D) + eps)`; the core divides by D = 128 as the product with 2^-7 (the word 0x3C000000). -/
def invRms (fuse : Bool) (X : ByteMemory.Bytes) (row : Nat) : Float32 :=
  C.rsqrt (C.fadd (C.fmul (rowSum C fuse X row) (Val.ofF32Bits 0x3C000000)) (Val.ofF32Bits 0x358637BD))

/-- `weight[col] * T(float(x[index]) * inv)` at `index = e` (row `e / 128`, `col = e % 128`). -/
def normalized (fuse : Bool) (X W : ByteMemory.Bytes) (e : Nat) : BF :=
  C.bfmul (bfAt W (e % 128)) (C.narrow (C.fmul (xf C X e) (invRms C fuse X (e / 128))))

/-- `g = float(gate[e])`. -/
def gateF (Gt : ByteMemory.Bytes) (e : Nat) : Float32 := C.widen (bfAt Gt e)

/-- `y = 1 / (1 + exp(abs(g)))` (`exp` and `abs` lower to the fast operations). -/
def yOf (g : Float32) : Float32 := C.fdiv one (C.fadd one (C.fastExp (C.fastFabs g)))

/-- `g < 0 ? y : 1 - y`. -/
def sigmoidOf (g : Float32) : Float32 :=
  if f32Compare g zero = some .lt then yOf C g else C.fadd one (f32Neg (yOf C g))

/-- `out[e] = T((g * sigmoid) * float(normalized))`. -/
def outElem (fuse : Bool) (X Gt W : ByteMemory.Bytes) (e : Nat) : BF :=
  C.narrow (C.fmul (C.fmul (gateF C Gt e) (sigmoidOf C (gateF C Gt e))) (C.widen (normalized C fuse X W e)))

/-- Byte `b` of `out` [1, 1, 48, 128] bf16: byte `b % 2` of element `b / 2`. -/
def expected (fuse : Nat → Bool) (X Gt W : ByteMemory.Bytes) (b : Nat) : BitVec 8 :=
  if b < 12288 then (wordBytes 2 (Val.bf16Bits (outElem C (fuse 1) X Gt W (b / 2)))).getD (b % 2) 0 else 0

/-! ## Memory -/

/-- The writer of each byte of `out` (region 3): element `e`'s bytes belong to thread `e / 4` of threadgroup
`e / 128`, in device epoch 0. Nothing else is written; threadgroup memory is not accessed. -/
def dev (region byte : Nat) : Option Writer := if region = 3 then some ⟨byte / 8, byte / 256, 0⟩ else none
def tgo (_ _ _ _ : Nat) : Option Nat := none

/-- The launch's regions: the three inputs and `out`. -/
structure Shape (L : Launch) (ax ag aw : Nat) : Prop where
  r0 : L.regions 0 = some ⟨.device, 12288, ax⟩
  r1 : L.regions 1 = some ⟨.device, 12288, ag⟩
  r2 : L.regions 2 = some ⟨.device, 256, aw⟩
  r3 : L.regions 3 = some ⟨.device, 12288, 16⟩
  ax : ax % 2 = 0
  ag : ag % 2 = 0
  aw : aw % 2 = 0

/-- Memory once the first `n` elements of `out` are written: inputs intact, those elements as expected, and
every access so far keeping the ownership discipline. -/
structure Inv (L : Launch) (fz : Bool) (X Gt W : ByteMemory.Bytes) (n : Nat) (sh : Shared) : Prop where
  regions : sh.regions = L.regions
  x : sh.bytes 0 = X
  gate : sh.bytes 1 = Gt
  weight : sh.bytes 2 = W
  epoch : sh.deviceEpoch = 0
  out : ∀ e < n, ∀ j < 2, sh.bytes 3 (2 * e + j) = (wordBytes 2 (Val.bf16Bits (outElem C fz X Gt W e))).getD j 0
  log : ∀ a ∈ sh.log, Owned L dev tgo a

section
variable {C} {L : Launch} {fz : Bool} {X Gt W : ByteMemory.Bytes} {n : Nat} {sh : Shared}

theorem Inv.rd (h : Inv C L fz X Gt W n sh) (ctx : Ctx) (region off : Nat) (r : Region)
    (hr : L.regions region = some r) (hs : r.space ≠ .threadgroup) (h3 : region ≠ 3) :
    Inv C L fz X Gt W n (rd ctx sh region off) :=
  ⟨h.regions, h.x, h.gate, h.weight, h.epoch, h.out, forall_log _ 2 _
    (fun j _ => owned_device_read L dev tgo ctx sh region (off + j) r hr hs (by simp [dev, h3])) h.log⟩

theorem Inv.wr (h : Inv C L fz X Gt W n sh) (r3 : L.regions 3 = some ⟨.device, 12288, 16⟩) (ctx : Ctx)
    (ht : ctx.thread = n / 4) (hg : ctx.group = n / 128) :
    Inv C L fz X Gt W (n + 1) (wr ctx sh 3 (2 * n) (outElem C fz X Gt W n)) where
  regions := h.regions
  x := h.x
  gate := h.gate
  weight := h.weight
  epoch := h.epoch
  out := by
    intro e he j hj
    show writeBytes (sh.bytes 3) (2 * n) (wordBytes 2 (Val.bf16Bits (outElem C fz X Gt W n))) (2 * e + j) = _
    by_cases hen : e < n
    · rw [writeBytes_outside _ _ _ _ (by rw [wordBytes_length]; omega)]; exact h.out e hen j hj
    · obtain rfl : e = n := by omega
      rw [writeBytes_inside _ _ _ j (by rw [wordBytes_length]; omega)]
  log := forall_log _ 2 _ (fun j hj => owned_device L dev tgo ctx sh 3 (2 * n + j) _ r3 true (by decide)
    ⟨(2 * n + j) / 8, (2 * n + j) / 256, 0⟩ (by simp [dev]) (by rw [ht]; show n / 4 = (2 * n + j) / 8; omega)
    (by rw [hg]; show n / 128 = (2 * n + j) / 256; omega)
    (by rw [h.epoch])) h.log

theorem Inv.reset (h : Inv C L fz X Gt W n sh) (hb : L.buffers.length = 4) (garbage : Garbage) (g : Nat) :
    Inv C L fz X Gt W n { sh with bytes := L.resetGroup garbage g sh.bytes } where
  regions := h.regions
  x := by show L.resetGroup garbage g sh.bytes 0 = X; rw [Launch.resetGroup_buffer L garbage g _ 0 (by omega)]; exact h.x
  gate := by
    show L.resetGroup garbage g sh.bytes 1 = Gt; rw [Launch.resetGroup_buffer L garbage g _ 1 (by omega)]; exact h.gate
  weight := by
    show L.resetGroup garbage g sh.bytes 2 = W; rw [Launch.resetGroup_buffer L garbage g _ 2 (by omega)]; exact h.weight
  epoch := h.epoch
  out := by
    intro e he j hj
    show L.resetGroup garbage g sh.bytes 3 _ = _
    rw [Launch.resetGroup_buffer L garbage g _ 3 (by omega)]; exact h.out e he j hj
  log := h.log
end

/-! ## A thread -/

/-- Lane `i` of threadgroup (row) `g`. -/
structure Lane (ctx : Ctx) (g i : Nat) : Prop where
  row : ctx.coord .threadgroupPositionInGrid = u32x3 g 0 0
  lane : ctx.coord .threadIndexInSimdgroup = u32 i
  tid : ctx.coord .threadPositionInThreadgroup = u32x3 i 0 0
  thread : ctx.thread = 32 * g + i
  group : ctx.group = g
  hg : g < 48
  hi : i < 32

/-- The locals both loops read and keep: the buffers, the row and the thread's index. -/
structure Locs (g i : Nat) (l : Locals) : Prop where
  x : l 0 = some (ptr 0)
  gate : l 1 = some (ptr 1)
  weight : l 2 = some (ptr 2)
  out : l 3 = some (ptr 3)
  row : l 4 = some (u32 g)
  tid : l 7 = some (u32 i)

theorem Locs.set {g i : Nat} {l : Locals} (h : Locs g i l) {slot : Nat} (v : Val) (hs : 7 < slot ∨ slot = 5 ∨ slot = 6) :
    Locs g i (setLocal l slot v) :=
  ⟨by rw [setLocal_other _ _ (by omega)]; exact h.x, by rw [setLocal_other _ _ (by omega)]; exact h.gate,
   by rw [setLocal_other _ _ (by omega)]; exact h.weight, by rw [setLocal_other _ _ (by omega)]; exact h.out,
   by rw [setLocal_other _ _ (by omega)]; exact h.row, by rw [setLocal_other _ _ (by omega)]; exact h.tid⟩

/-! ### The first loop (as tests/Steps.lean proves it) -/

def colE : CExpr := .bin .add .u32 0 (.bin .add .u32 0 (.local 10) (.bin .mul .u32 0 (.local 7) (u32l 4))) (.local 11)
def indexE : CExpr := .bin .add .u32 0 (.bin .mul .u32 0 (.local 4) (u32l 128)) (.local 12)
def valueE : CExpr :=
  .cond (.bin .lt .u32 0 (.local 12) (u32l 128)) (.conv .f32 (.load (.scalar .bf16) (.offset (.local 0) indexE)))
    (f32l 0x0)
def accE : CExpr := .bin .add .f32 1 (.local 6) (.bin .mul .f32 0 (.local 13) (.local 13))

theorem sumColBody_eq : sumColBody = [.set 12 colE, .set 13 valueE, .set 6 accE] := rfl

/-- Memory after the lane's first `k` loads of `x`. -/
def loads (ctx : Ctx) (sh : Shared) (row tid : Nat) : Nat → Shared
  | 0 => sh
  | k + 1 => rd ctx (loads ctx sh row tid k) 0 (2 * (row * 128 + (tid * 4 + k)))

theorem loads_regions (ctx : Ctx) (sh : Shared) (row tid : Nat) : ∀ k, (loads ctx sh row tid k).regions = sh.regions
  | 0 => rfl
  | k + 1 => loads_regions ctx sh row tid k

theorem loads_bytes (ctx : Ctx) (sh : Shared) (row tid : Nat) : ∀ k, (loads ctx sh row tid k).bytes = sh.bytes
  | 0 => rfl
  | k + 1 => loads_bytes ctx sh row tid k

theorem loads_inv {L : Launch} {fz : Bool} {X Gt W : ByteMemory.Bytes} {n : Nat} {sh : Shared} (ax : Nat)
    (h : Inv C L fz X Gt W n sh) (r0 : L.regions 0 = some ⟨.device, 12288, ax⟩) (ctx : Ctx) (row tid : Nat) :
    ∀ k, Inv C L fz X Gt W n (loads ctx sh row tid k)
  | 0 => h
  | k + 1 => (loads_inv ax h r0 ctx row tid k).rd ctx 0 _ _ r0 (by simp) (by decide)

/-- At the `k`-th test of the inner loop. -/
def Inner (ctx : Ctx) (sh : Shared) (row tid k : Nat) (l : Locals) (sh' : Shared) : Prop :=
  Locs row tid l ∧ l 10 = some (u32 0) ∧ l 11 = some (u32 k) ∧
    l 6 = some (.f32 (sumSq C (ctx.fuse 1) (sh.bytes 0) row tid k)) ∧ sh' = loads ctx sh row tid k

/-- At the `j`-th test of the outer loop. -/
def Outer (ctx : Ctx) (sh : Shared) (row tid j : Nat) (l : Locals) (sh' : Shared) : Prop :=
  Locs row tid l ∧ l 10 = some (u32 (128 * j)) ∧
    l 6 = some (.f32 (sumSq C (ctx.fuse 1) (sh.bytes 0) row tid (4 * j))) ∧ sh' = loads ctx sh row tid (4 * j)

section
variable {ctx : Ctx} {row tid ax : Nat} {sh : Shared}

theorem inner_body (hrow : row < 48) (htid : tid < 32) (r0 : sh.regions 0 = some ⟨.device, 12288, ax⟩)
    (hax : ax % 2 = 0) (k : Nat) (hk : k < 4) (l : Locals) (sh' : Shared) (hI : Inner C ctx sh row tid k l sh') :
    ∃ l₁, Exec C ctx sumColBody l sh' .normal l₁ (loads ctx sh row tid (k + 1)) ∧ Locs row tid l₁ ∧
      l₁ 10 = some (u32 0) ∧ l₁ 11 = some (u32 k) ∧
      l₁ 6 = some (.f32 (sumSq C (ctx.fuse 1) (sh.bytes 0) row tid (k + 1))) := by
  obtain ⟨hl, h10, h11, h6, rfl⟩ := hI
  have hc : (eval C ctx l colE).run (loads ctx sh row tid k) = some (u32 (tid * 4 + k), loads ctx sh row tid k) := by
    have : (eval C ctx l colE).run (loads ctx sh row tid k) = some (u32 (0 + tid * 4 + k), loads ctx sh row tid k) :=
      eval_int C (by decide) (eval_int C (by decide) (eval_local' C h10 _)
        (eval_int C (by decide) (eval_local' C hl.tid _) (eval_lit C _ _ _ _) (binary_mul_u32 C tid 4))
        (binary_add_u32 C 0 (tid * 4))) (eval_local' C h11 _) (binary_add_u32 C (0 + tid * 4) k)
    rwa [Nat.zero_add] at this
  let l₁ := setLocal l 12 (u32 (tid * 4 + k))
  have hl₁ : Locs row tid l₁ := hl.set _ (by omega)
  have hidx : (eval C ctx l₁ indexE).run (loads ctx sh row tid k) =
      some (u32 (row * 128 + (tid * 4 + k)), loads ctx sh row tid k) :=
    eval_int C (by decide)
      (eval_int C (by decide) (eval_local' C hl₁.row _) (eval_lit C _ _ _ _) (binary_mul_u32 C row 128))
      (eval_local' C (setLocal_same _ _ _) _) (binary_add_u32 C (row * 128) (tid * 4 + k))
  have hptr : (eval C ctx l₁ (.offset (.local 0) indexE)).run (loads ctx sh row tid k) =
      some (.ptr ⟨0, ((2 * (row * 128 + (tid * 4 + k)) : Nat) : Int), .scalar .bf16⟩, loads ctx sh row tid k) := by
    have := eval_offset_u32 C (o := 0) (eval_local' C hl₁.x _) hidx (by omega)
    rwa [show 0 + (row * 128 + (tid * 4 + k)) * (Ty.scalar .bf16).bytes = 2 * (row * 128 + (tid * 4 + k)) by
      simp only [Ty.bytes, Scalar.bytes]; omega] at this
  have hload := load_bf16 ctx (loads ctx sh row tid k) 0 12288 ax (row * 128 + (tid * 4 + k))
    (by rw [loads_regions]; exact r0) hax (by omega)
  rw [loads_bytes] at hload
  have htest : (eval C ctx l₁ (.bin .lt .u32 0 (.local 12) (u32l 128))).run (loads ctx sh row tid k) =
      some (.bool true, loads ctx sh row tid k) := by
    have h : (eval C ctx l₁ (.bin .lt .u32 0 (.local 12) (u32l 128))).run (loads ctx sh row tid k) =
        some (.bool (decide (tid * 4 + k < 128)), loads ctx sh row tid k) :=
      eval_int C (by decide) (eval_local' C (setLocal_same _ _ _) _) (eval_lit C _ _ _ _)
        (binary_lt_u32 C (tid * 4 + k) 128 (by omega) (by omega))
    rw [h, decide_eq_true (show tid * 4 + k < 128 by omega)]
  have hv : (eval C ctx l₁ valueE).run (loads ctx sh row tid k) =
      some (.f32 (xf C (sh.bytes 0) (row * 128 + (tid * 4 + k))), loads ctx sh row tid (k + 1)) :=
    eval_cond C htest (eval_conv C ((eval_load C _ _ _ _ _ _ _ hptr).trans hload) rfl)
  let l₂ := setLocal l₁ 13 (.f32 (xf C (sh.bytes 0) (row * 128 + (tid * 4 + k))))
  have hacc : (eval C ctx l₂ accE).run (loads ctx sh row tid (k + 1)) =
      some (.f32 (sumSq C (ctx.fuse 1) (sh.bytes 0) row tid (k + 1)), loads ctx sh row tid (k + 1)) :=
    eval_add_mul C rfl (eval_local' C (setLocal_same _ _ _) _) (eval_local' C (setLocal_same _ _ _) _)
      (eval_local' C (by simp [l₂, l₁, setLocal, h6]) _)
  refine ⟨_, .set hc (.set hv (.set hacc (.nil _ _))), (hl₁.set _ (by omega)).set _ (by omega), ?_, ?_, ?_⟩
  · simp [setLocal, h10]
  · simp [setLocal, h11]
  · simp [setLocal]

theorem inner_loop (hrow : row < 48) (htid : tid < 32) (r0 : sh.regions 0 = some ⟨.device, 12288, ax⟩)
    (hax : ax % 2 = 0) (l : Locals) (h0 : Inner C ctx sh row tid 0 l sh) :
    ∃ l' sh', Exec C ctx [sumColLoop] l sh .normal l' sh' ∧ Inner C ctx sh row tid 4 l' sh' := by
  refine Exec.loop_count 4 (Inner C ctx sh row tid) (Inner C ctx sh row tid) (fun k hk l sh' hI => ⟨sh', ?_, hI⟩)
    (fun k hk l sh' hI => ?_) h0
  · exact eval_int C (by decide) (eval_local' C hI.2.2.1 _) (eval_lit C _ _ _ _)
      (binary_lt_u32 C k 4 (by omega) (by omega))
  · obtain ⟨l₁, hb, hl, h10, h11, h6⟩ := inner_body C hrow htid r0 hax k hk l sh' hI
    refine ⟨.normal, l₁, _, _, _, .inl rfl, hb,
      .set (eval_int C (by decide) (eval_local' C h11 _) (eval_lit C _ _ _ _) (binary_add_u32 C k 1)) (.nil _ _),
      hl.set _ (by omega), by simp [setLocal, h10], by simp [setLocal], by simp [setLocal, h6], rfl⟩

/-- The first loop: the lane's four columns of its row, squared and summed, with their loads logged. -/
theorem first_loop (hrow : row < 48) (htid : tid < 32) (r0 : sh.regions 0 = some ⟨.device, 12288, ax⟩)
    (hax : ax % 2 = 0) (l : Locals) (hl : Locs row tid l) (h6 : l 6 = some (.f32 zero)) :
    ∃ l', Exec C ctx [.set 10 (u32l 0), .loop sumRowCond sumRowStep sumRowBody] l sh .normal l'
      (loads ctx sh row tid 4) ∧ Locs row tid l' ∧
      l' 6 = some (.f32 (sumSq C (ctx.fuse 1) (sh.bytes 0) row tid 4)) := by
  have htest : ∀ j ≤ 1, ∀ l sh', Outer C ctx sh row tid j l sh' →
      ∃ sh₁, (eval C ctx l sumRowCond).run sh' = some (.bool (decide (j < 1)), sh₁) ∧
        Outer C ctx sh row tid j l sh₁ := by
    intro j hj l sh' hO
    have h : (eval C ctx l sumRowCond).run sh' = some (.bool (decide (128 * j < 128)), sh') :=
      eval_int C (by decide) (eval_local' C hO.2.1 _) (eval_lit C _ _ _ _)
        (binary_lt_u32 C (128 * j) 128 (by omega) (by omega))
    exact ⟨sh', by rw [h, show decide (128 * j < 128) = decide (j < 1) from decide_eq_decide.mpr (by omega)], hO⟩
  have hbody : ∀ j < 1, ∀ l sh', Outer C ctx sh row tid j l sh' → ∃ o l₁ sh₁ l₂ sh₂,
      (o = .normal ∨ o = .continue_) ∧ Exec C ctx sumRowBody l sh' o l₁ sh₁ ∧
      Exec C ctx sumRowStep l₁ sh₁ .normal l₂ sh₂ ∧ Outer C ctx sh row tid (j + 1) l₂ sh₂ := by
    intro j hj l sh' hO
    obtain rfl : j = 0 := by omega
    obtain ⟨hl, h10, h6, rfl⟩ := hO
    obtain ⟨l₁, sh₁, hin, hl₁, h10', _, h6', rfl⟩ := inner_loop C hrow htid r0 hax (setLocal l 11 (.int .u32 0))
      ⟨hl.set _ (by omega), by simpa [setLocal] using h10, by simp [setLocal, u32], by simpa [setLocal] using h6, rfl⟩
    exact ⟨.normal, l₁, _, _, _, .inl rfl, .set (eval_lit C _ _ _ _) hin,
      .set (eval_int C (by decide) (eval_local' C h10' _) (eval_lit C _ _ _ _) (binary_add_u32 C 0 128)) (.nil _ _),
      hl₁.set _ (by omega), by simp [setLocal], by simpa [setLocal] using h6', rfl⟩
  obtain ⟨l', sh', hex, hl', _, h6', rfl⟩ := Exec.loop_count 1 (Outer C ctx sh row tid) (Outer C ctx sh row tid)
    htest hbody (l := setLocal l 10 (.int .u32 0)) (sh := sh)
    ⟨hl.set _ (by omega), by simp [setLocal, u32], by simpa [setLocal, sumSq] using h6, rfl⟩
  exact ⟨l', .set (eval_lit C _ _ _ _) hex, hl', h6'⟩

end

/-! ### To the `simd_sum` -/

def invE : CExpr :=
  .un .rsqrt .f32 (.bin .add .f32 0 (.conv .f32 (.bin .mul .f32 0 (.local 6) (f32l 0x3C000000))) (f32l 0x358637BD))

/-- The code after the `simd_sum`. -/
def rest : List CStmt := [.set 6 (.local 14), .set 17 invE, .set 18 (u32l 0), .loop outRowCond outRowStep outRowBody]

theorem body_split : body = (body.take 10 ++ [.set 10 (u32l 0), .loop sumRowCond sumRowStep sumRowBody]) ++
    .collective 2 14 .sum .f32 (.local 6) (u16l 0) :: rest := rfl

/-- A lane runs its declarations and the first loop to the `simd_sum`. -/
theorem lane_start (ctx : Ctx) (g i : Nat) (hl : Lane ctx g i) (ax : Nat) (sh : Shared)
    (r0 : sh.regions 0 = some ⟨.device, 12288, ax⟩) (hax : ax % 2 = 0) :
    ∃ l, (∃ n, ∀ m, n ≤ m → (runThread C m ⟨ctx, fun _ => none, [.block body], .running⟩).run sh =
      some (⟨ctx, l, [.block rest], .collective 2 14 .sum .f32 (.f32 (sumSq C (ctx.fuse 1) (sh.bytes 0) g i 4)) 0⟩,
        loads ctx sh g i 4)) ∧ Locs g i l := by
  have hd : ∃ l0, Exec C ctx (body.take 10) (fun _ => none) sh .normal l0 sh ∧ Locs g i l0 ∧
      l0 6 = some (.f32 zero) :=
    ⟨_, .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <|
      .set (eval_lit C _ _ _ _) <| .set (eval_coord_x C hl.row _) <| .set (eval_coord C _ _ _ _) <|
      .set (eval_lit C _ _ _ _) <| .set (eval_coord_x C hl.tid _) <| .array <| .array <| .nil _ _,
      ⟨by simp [setLocal, ptr], by simp [setLocal, ptr], by simp [setLocal, ptr], by simp [setLocal, ptr],
        by simp [setLocal], by simp [setLocal]⟩, by simp [setLocal, zero]⟩
  obtain ⟨l0, hd, hl0, h60⟩ := hd
  obtain ⟨l1, hex, hloc, h6⟩ := first_loop C (ctx := ctx) hl.hg hl.hi r0 hax l0 hl0 h60
  have hr := Exec.reaches_collective (K := []) (rest := rest) (site := 2) (slot := 14) (op := .sum) (s := .f32)
    (d := u16l 0) (k := 0) (hd.append hex) (eval_local' C h6 _) (eval_lit C _ _ _ _) rfl
  refine ⟨l1, ?_, hloc⟩
  rw [body_split]
  exact hr.run rfl

/-! ### After the `simd_sum` -/

def colO : CExpr := .bin .add .u32 0 (.bin .add .u32 0 (.local 18) (.bin .mul .u32 0 (.local 7) (u32l 4))) (.local 19)
def idxO : CExpr := .bin .add .u32 0 (.bin .mul .u32 0 (.local 4) (u32l 128)) (.local 20)
def gateE : CExpr := .conv .f32 (.load (.scalar .bf16) (.offset (.local 1) (.local 21)))
def outE : CExpr := .conv .bf16 (.bin .mul .f32 0 (.bin .mul .f32 0 (.local 23) (.local 25)) (.conv .f32 (.local 22)))

theorem outColBody_eq : outColBody = [.set 20 colO, .set 21 idxO, padStmt, .set 22 normalizedExpr, .set 23 gateE,
    .set 24 yExpr, .set 25 sigmoidExpr, .store (.scalar .bf16) (.offset (.local 3) (.local 21)) outE] := rfl

section
variable {C} {L : Launch} {ax ag aw : Nat} {ctx : Ctx} {g i : Nat} {fz : Bool} {X Gt W : ByteMemory.Bytes}

/-- One column of the second loop: `out[index]` written, its inputs read. -/
theorem out_body (hS : Shape L ax ag aw) (hl : Lane ctx g i) (k : Nat) (hk : k < 4) (l : Locals) (sh : Shared)
    (hloc : Locs g i l) (h17 : l 17 = some (.f32 (invRms C fz X g))) (h18 : l 18 = some (u32 0))
    (h19 : l 19 = some (u32 k)) (hI : Inv C L fz X Gt W (128 * g + 4 * i + k) sh) :
    ∃ l₁ sh₁, Exec C ctx outColBody l sh .normal l₁ sh₁ ∧ Locs g i l₁ ∧
      l₁ 17 = some (.f32 (invRms C fz X g)) ∧ l₁ 18 = some (u32 0) ∧ l₁ 19 = some (u32 k) ∧
      Inv C L fz X Gt W (128 * g + 4 * i + k + 1) sh₁ := by
  have hg := hl.hg; have hi := hl.hi
  have hreg := hI.regions
  have hc : (eval C ctx l colO).run sh = some (u32 (i * 4 + k), sh) := by
    have : (eval C ctx l colO).run sh = some (u32 (0 + i * 4 + k), sh) :=
      eval_int C (by decide) (eval_int C (by decide) (eval_local' C h18 _)
        (eval_int C (by decide) (eval_local' C hloc.tid _) (eval_lit C _ _ _ _) (binary_mul_u32 C i 4))
        (binary_add_u32 C 0 (i * 4))) (eval_local' C h19 _) (binary_add_u32 C (0 + i * 4) k)
    rwa [Nat.zero_add] at this
  have hl₁ : Locs g i (setLocal l 20 (u32 (i * 4 + k))) := hloc.set _ (by omega)
  have hidx : (eval C ctx (setLocal l 20 (u32 (i * 4 + k))) idxO).run sh = some (u32 (128 * g + 4 * i + k), sh) := by
    have : (eval C ctx (setLocal l 20 (u32 (i * 4 + k))) idxO).run sh = some (u32 (g * 128 + (i * 4 + k)), sh) :=
      eval_int C (by decide)
        (eval_int C (by decide) (eval_local' C hl₁.row _) (eval_lit C _ _ _ _) (binary_mul_u32 C g 128))
        (eval_local' C (setLocal_same _ _ _) _) (binary_add_u32 C (g * 128) (i * 4 + k))
    rwa [show g * 128 + (i * 4 + k) = 128 * g + 4 * i + k by ring] at this
  generalize hl₂def : setLocal (setLocal l 20 (u32 (i * 4 + k))) 21 (u32 (128 * g + 4 * i + k)) = l₂
  have hl₂ : Locs g i l₂ := by rw [← hl₂def]; exact hl₁.set _ (by omega)
  have h20 : l₂ 20 = some (u32 (i * 4 + k)) := by rw [← hl₂def]; simp [setLocal]
  have h21 : l₂ 21 = some (u32 (128 * g + 4 * i + k)) := by rw [← hl₂def]; simp [setLocal]
  have h17' : l₂ 17 = some (.f32 (invRms C fz X g)) := by rw [← hl₂def]; simp [setLocal, h17]
  have hpad : (eval C ctx l₂ (.bin .ge .u32 0 (.local 20) (u32l 128))).run sh = some (.bool false, sh) := by
    have h : (eval C ctx l₂ (.bin .ge .u32 0 (.local 20) (u32l 128))).run sh =
        some (.bool (decide (128 ≤ i * 4 + k)), sh) :=
      eval_int C (by decide) (eval_local' C h20 _) (eval_lit C _ _ _ _)
        (binary_ge_u32 C (i * 4 + k) 128 (by omega) (by omega))
    rw [h, decide_eq_false (by omega)]
  -- `normalized`: `weight[col]` then `x[index]`
  have hw := load_bf16 ctx sh 2 256 aw (i * 4 + k) (by rw [hreg]; exact hS.r2) hS.aw (by omega)
  rw [hI.weight] at hw
  generalize hsh₁ : rd ctx sh 2 (2 * (i * 4 + k)) = sh₁ at hw
  have hI₁ : Inv C L fz X Gt W (128 * g + 4 * i + k) sh₁ := by
    rw [← hsh₁]; exact hI.rd ctx 2 _ _ hS.r2 (by simp) (by decide)
  have hx := load_bf16 ctx sh₁ 0 12288 ax (128 * g + 4 * i + k) (by rw [hI₁.regions]; exact hS.r0) hS.ax (by omega)
  rw [hI₁.x] at hx
  generalize hsh₂ : rd ctx sh₁ 0 (2 * (128 * g + 4 * i + k)) = sh₂ at hx
  have hI₂ : Inv C L fz X Gt W (128 * g + 4 * i + k) sh₂ := by
    rw [← hsh₂]; exact hI₁.rd ctx 0 _ _ hS.r0 (by simp) (by decide)
  have hn : normalized C fz X W (128 * g + 4 * i + k) =
      C.bfmul (bfAt W (i * 4 + k)) (C.narrow (C.fmul (C.widen (bfAt X (128 * g + 4 * i + k))) (invRms C fz X g))) := by
    unfold normalized xf
    rw [show (128 * g + 4 * i + k) % 128 = i * 4 + k by omega, show (128 * g + 4 * i + k) / 128 = g by omega]
  have hN : (eval C ctx l₂ normalizedExpr).run sh =
      some (.bf16 (normalized C fz X W (128 * g + 4 * i + k)), sh₂) := by
    rw [hn]
    exact eval_bin_plain C (.inl ⟨by decide, by decide⟩)
      ((eval_load C _ _ _ _ _ _ _ (eval_index C hl₂.weight h20 (by omega) _)).trans hw)
      (eval_conv C (eval_f32 C (.inl ⟨by decide, by decide⟩)
        (eval_conv C ((eval_load C _ _ _ _ _ _ _ (eval_index C hl₂.x h21 (by omega) _)).trans hx) rfl)
        (eval_local' C h17' _) rfl) rfl) rfl
  -- `g = float(gate[index])`
  generalize hl₃def : setLocal l₂ 22 (.bf16 (normalized C fz X W (128 * g + 4 * i + k))) = l₃
  have hl₃ : Locs g i l₃ := by rw [← hl₃def]; exact hl₂.set _ (by omega)
  have h21₃ : l₃ 21 = some (u32 (128 * g + 4 * i + k)) := by rw [← hl₃def]; simp [setLocal, h21]
  have hgl := load_bf16 ctx sh₂ 1 12288 ag (128 * g + 4 * i + k) (by rw [hI₂.regions]; exact hS.r1) hS.ag (by omega)
  rw [hI₂.gate] at hgl
  generalize hsh₃ : rd ctx sh₂ 1 (2 * (128 * g + 4 * i + k)) = sh₃ at hgl
  have hI₃ : Inv C L fz X Gt W (128 * g + 4 * i + k) sh₃ := by
    rw [← hsh₃]; exact hI₂.rd ctx 1 _ _ hS.r1 (by simp) (by decide)
  have hG : (eval C ctx l₃ gateE).run sh₂ = some (.f32 (gateF C Gt (128 * g + 4 * i + k)), sh₃) :=
    eval_conv C ((eval_load C _ _ _ _ _ _ _ (eval_index C hl₃.gate h21₃ (by omega) _)).trans hgl) rfl
  -- `y` and `sigmoid`
  generalize hl₄def : setLocal l₃ 23 (.f32 (gateF C Gt (128 * g + 4 * i + k))) = l₄
  have h23 : l₄ 23 = some (.f32 (gateF C Gt (128 * g + 4 * i + k))) := by rw [← hl₄def]; simp [setLocal]
  have hY : (eval C ctx l₄ yExpr).run sh₃ = some (.f32 (yOf C (gateF C Gt (128 * g + 4 * i + k))), sh₃) :=
    eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_lit C _ _ _ _)
      (eval_f32 C (.inr ⟨rfl, rfl⟩) (eval_lit C _ _ _ _)
        (eval_un C (eval_un C (eval_local' C h23 _) rfl) rfl) rfl) rfl
  generalize hl₅def : setLocal l₄ 24 (.f32 (yOf C (gateF C Gt (128 * g + 4 * i + k)))) = l₅
  have h23₅ : l₅ 23 = some (.f32 (gateF C Gt (128 * g + 4 * i + k))) := by rw [← hl₅def]; simp [setLocal, h23]
  have h24 : l₅ 24 = some (.f32 (yOf C (gateF C Gt (128 * g + 4 * i + k)))) := by rw [← hl₅def]; simp [setLocal]
  have hSg : (eval C ctx l₅ sigmoidExpr).run sh₃ =
      some (.f32 (sigmoidOf C (gateF C Gt (128 * g + 4 * i + k))), sh₃) := by
    have hc : (eval C ctx l₅ (.bin .lt .f32 0 (.local 23) (f32l 0x0))).run sh₃ =
        some (.bool (decide (f32Compare (gateF C Gt (128 * g + 4 * i + k)) zero = some .lt)), sh₃) :=
      eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_local' C h23₅ _) (eval_lit C _ _ _ _) (binary_lt_f32 C _ _)
    refine eval_cond C hc ?_
    unfold sigmoidOf
    by_cases hneg : f32Compare (gateF C Gt (128 * g + 4 * i + k)) zero = some .lt
    · simp only [hneg, decide_true, ite_true]
      exact eval_local' C h24 _
    · simp only [hneg, decide_false, Bool.false_eq_true, ite_false]
      exact eval_f32 C (.inr ⟨rfl, rfl⟩) (eval_lit C _ _ _ _) (eval_local' C h24 _) rfl
  -- the store
  generalize hl₆def : setLocal l₅ 25 (.f32 (sigmoidOf C (gateF C Gt (128 * g + 4 * i + k)))) = l₆
  have hl₆ : Locs g i l₆ := by
    rw [← hl₆def, ← hl₅def, ← hl₄def]; exact ((hl₃.set _ (by omega)).set _ (by omega)).set _ (by omega)
  have h21₆ : l₆ 21 = some (u32 (128 * g + 4 * i + k)) := by
    rw [← hl₆def, ← hl₅def, ← hl₄def]; simp [setLocal, h21₃]
  have h22₆ : l₆ 22 = some (.bf16 (normalized C fz X W (128 * g + 4 * i + k))) := by
    rw [← hl₆def, ← hl₅def, ← hl₄def, ← hl₃def]; simp [setLocal]
  have h23₆ : l₆ 23 = some (.f32 (gateF C Gt (128 * g + 4 * i + k))) := by rw [← hl₆def]; simp [setLocal, h23₅]
  have h25₆ : l₆ 25 = some (.f32 (sigmoidOf C (gateF C Gt (128 * g + 4 * i + k)))) := by
    rw [← hl₆def]; simp [setLocal]
  have hv : (eval C ctx l₆ outE).run sh₃ = some (.bf16 (outElem C fz X Gt W (128 * g + 4 * i + k)), sh₃) :=
    eval_conv C (eval_f32 C (.inl ⟨by decide, by decide⟩)
      (eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_local' C h23₆ _) (eval_local' C h25₆ _) rfl)
      (eval_conv C (eval_local' C h22₆ _) rfl) rfl) rfl
  have hst := store_bf16 ctx sh₃ 3 12288 16 (128 * g + 4 * i + k) (outElem C fz X Gt W (128 * g + 4 * i + k))
    (by rw [hI₃.regions]; exact hS.r3) (by decide) (by omega)
  refine ⟨l₆, _, ?_, hl₆, ?_, ?_, ?_, hI₃.wr hS.r3 ctx (by rw [hl.thread]; omega) (by rw [hl.group]; omega)⟩
  · have hE : Exec C ctx [.store (.scalar .bf16) (.offset (.local 3) (.local 21)) outE] l₆ sh₃ .normal l₆ _ :=
      .store (eval_index C hl₆.out h21₆ (by omega) _) hv hst (.nil _ _)
    subst hl₆def hl₅def hl₄def hl₃def hl₂def
    rw [outColBody_eq]
    exact .set hc (.set hidx (.ite hpad (.nil _ _) (.set hN (.set hG (.set hY (.set hSg hE))))))
  · rw [← hl₆def, ← hl₅def, ← hl₄def, ← hl₃def, ← hl₂def]; simp [setLocal, h17]
  · rw [← hl₆def, ← hl₅def, ← hl₄def, ← hl₃def, ← hl₂def]; simp [setLocal, h18]
  · rw [← hl₆def, ← hl₅def, ← hl₄def, ← hl₃def, ← hl₂def]; simp [setLocal, h19]

end

/-- At the `k`-th test of the second loop's inner loop. -/
def OutI (L : Launch) (fz : Bool) (X Gt W : ByteMemory.Bytes) (g i k : Nat) (l : Locals) (sh : Shared) : Prop :=
  Locs g i l ∧ l 17 = some (.f32 (invRms C fz X g)) ∧ l 18 = some (u32 0) ∧ l 19 = some (u32 k) ∧
    Inv C L fz X Gt W (128 * g + 4 * i + k) sh

/-- At the `j`-th test of the second loop. -/
def OutO (L : Launch) (fz : Bool) (X Gt W : ByteMemory.Bytes) (g i j : Nat) (l : Locals) (sh : Shared) : Prop :=
  Locs g i l ∧ l 17 = some (.f32 (invRms C fz X g)) ∧ l 18 = some (u32 (128 * j)) ∧
    Inv C L fz X Gt W (128 * g + 4 * i + 4 * j) sh

section
variable {C} {L : Launch} {ax ag aw : Nat} {ctx : Ctx} {g i : Nat} {fz : Bool} {X Gt W : ByteMemory.Bytes}

theorem out_inner (hS : Shape L ax ag aw) (hl : Lane ctx g i) (l : Locals) (sh : Shared)
    (h0 : OutI C L fz X Gt W g i 0 l sh) :
    ∃ l' sh', Exec C ctx [outColLoop] l sh .normal l' sh' ∧ OutI C L fz X Gt W g i 4 l' sh' := by
  refine Exec.loop_count 4 (OutI C L fz X Gt W g i) (OutI C L fz X Gt W g i)
    (fun k hk l sh' hI => ⟨sh', ?_, hI⟩) (fun k hk l sh' hI => ?_) h0
  · exact eval_int C (by decide) (eval_local' C hI.2.2.2.1 _) (eval_lit C _ _ _ _)
      (binary_lt_u32 C k 4 (by omega) (by omega))
  · obtain ⟨hloc, h17, h18, h19, hI⟩ := hI
    obtain ⟨l₁, sh₁, hb, hl₁, h17', h18', h19', hI'⟩ := out_body hS hl k hk l sh' hloc h17 h18 h19 hI
    exact ⟨.normal, l₁, sh₁, _, _, .inl rfl, hb,
      .set (eval_int C (by decide) (eval_local' C h19' _) (eval_lit C _ _ _ _) (binary_add_u32 C k 1)) (.nil _ _),
      hl₁.set _ (by omega), by simp [setLocal, h17'], by simp [setLocal, h18'], by simp [setLocal], hI'⟩

/-- The code after the `simd_sum`: `inv`, then the four columns of the lane's row. -/
theorem lane_finish (hS : Shape L ax ag aw) (hl : Lane ctx g i) (l : Locals) (hloc : Locs g i l) (sh : Shared)
    (hI : Inv C L fz X Gt W (128 * g + 4 * i) sh) :
    ∃ l' sh', Exec C ctx rest (setLocal l 14 (.f32 (rowSum C fz X g))) sh .normal l' sh' ∧
      Inv C L fz X Gt W (128 * g + 4 * i + 4) sh' := by
  have hl₁ : Locs g i (setLocal (setLocal l 14 (.f32 (rowSum C fz X g))) 6 (.f32 (rowSum C fz X g))) :=
    (hloc.set _ (by omega)).set _ (by omega)
  have hinv : (eval C ctx (setLocal (setLocal l 14 (.f32 (rowSum C fz X g))) 6 (.f32 (rowSum C fz X g))) invE).run sh =
      some (.f32 (invRms C fz X g), sh) :=
    eval_un C (eval_f32 C (.inr ⟨rfl, rfl⟩) (eval_conv C (eval_f32 C (.inl ⟨by decide, by decide⟩)
      (eval_local' C (setLocal_same _ _ _) _) (eval_lit C _ _ _ _) rfl) rfl) (eval_lit C _ _ _ _) rfl) rfl
  have htest : ∀ j ≤ 1, ∀ l sh', OutO C L fz X Gt W g i j l sh' →
      ∃ sh₁, (eval C ctx l outRowCond).run sh' = some (.bool (decide (j < 1)), sh₁) ∧
        OutO C L fz X Gt W g i j l sh₁ := by
    intro j hj l sh' hO
    have h : (eval C ctx l outRowCond).run sh' = some (.bool (decide (128 * j < 128)), sh') :=
      eval_int C (by decide) (eval_local' C hO.2.2.1 _) (eval_lit C _ _ _ _)
        (binary_lt_u32 C (128 * j) 128 (by omega) (by omega))
    exact ⟨sh', by rw [h, show decide (128 * j < 128) = decide (j < 1) from decide_eq_decide.mpr (by omega)], hO⟩
  have hbody : ∀ j < 1, ∀ l sh', OutO C L fz X Gt W g i j l sh' → ∃ o l₁ sh₁ l₂ sh₂,
      (o = .normal ∨ o = .continue_) ∧ Exec C ctx outRowBody l sh' o l₁ sh₁ ∧
      Exec C ctx outRowStep l₁ sh₁ .normal l₂ sh₂ ∧ OutO C L fz X Gt W g i (j + 1) l₂ sh₂ := by
    intro j hj l sh' hO
    obtain rfl : j = 0 := by omega
    obtain ⟨hl', h17, h18, hI'⟩ := hO
    obtain ⟨l₁, sh₁, hin, hl₁', h17', h18', _, hI₁⟩ := out_inner hS hl (setLocal l 19 (.int .u32 0)) sh'
      ⟨hl'.set _ (by omega), by simpa [setLocal] using h17, by simpa [setLocal] using h18, by simp [setLocal, u32],
        by simpa using hI'⟩
    exact ⟨.normal, l₁, _, _, _, .inl rfl, .set (eval_lit C _ _ _ _) hin,
      .set (eval_int C (by decide) (eval_local' C h18' _) (eval_lit C _ _ _ _) (binary_add_u32 C 0 128)) (.nil _ _),
      hl₁'.set _ (by omega), by simpa [setLocal] using h17', by simp [setLocal], by simpa using hI₁⟩
  have h0 : OutO C L fz X Gt W g i 0 (setLocal (setLocal (setLocal (setLocal l 14 (.f32 (rowSum C fz X g))) 6 (.f32 (rowSum C fz X g)))
      17 (.f32 (invRms C fz X g))) 18 (.int .u32 0)) sh :=
    ⟨(hl₁.set _ (by omega)).set _ (by omega), by simp [setLocal], by simp [setLocal, u32], by simpa using hI⟩
  obtain ⟨l', sh', hex, -, -, -, hI'⟩ := Exec.loop_count 1 (OutO C L fz X Gt W g i) (OutO C L fz X Gt W g i)
    htest hbody h0
  exact ⟨l', sh', .set (eval_local' C (setLocal_same _ _ _) _) (.set hinv (.set (eval_lit C _ _ _ _) hex)), hI'⟩
end

/-! ## The launch -/

def inputs (X Gt W : ByteMemory.Bytes) (ax ag aw : Nat) : List Buffer :=
  [⟨.device, 12288, ax, X⟩, ⟨.device, 12288, ag, Gt⟩, ⟨.device, 256, aw, W⟩]

/-- MLX's launch at `gatedNormConfig`: grid [1536], threadgroup [32], `x` and `gate` [1, 1, 48, 128] bf16,
`weight` [128] bf16, `out` [1, 1, 48, 128] bf16. -/
def launch (X Gt W : ByteMemory.Bytes) (ax ag aw : Nat) (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨core, (1536, 1, 1), (32, 1, 1), buffers (inputs X Gt W ax ag aw) [12288] 16 initial⟩

section
variable {X Gt W : ByteMemory.Bytes} {ax ag aw : Nat} {initial : Nat → ByteMemory.Bytes}

theorem launch_tiles : (launch X Gt W ax ag aw initial).Tiles 32 1 1 48 1 1 1 := ⟨rfl, rfl, rfl, by decide⟩

theorem launch_shape (hax : ax % 2 = 0) (hag : ag % 2 = 0) (haw : aw % 2 = 0) :
    Shape (launch X Gt W ax ag aw initial) ax ag aw :=
  ⟨regions_input (L := launch X Gt W ax ag aw initial) rfl 0 (by simp [inputs]),
   regions_input (L := launch X Gt W ax ag aw initial) rfl 1 (by simp [inputs]),
   regions_input (L := launch X Gt W ax ag aw initial) rfl 2 (by simp [inputs]),
   regions_output (L := launch X Gt W ax ag aw initial) rfl 0 (by simp), hax, hag, haw⟩

theorem lane_of (fuse : Nat → Bool) (g : Nat) (hg : g < 48) (s : Fin 1) (i : Fin 32) :
    Lane ((launch X Gt W ax ag aw initial).ctxAt fuse g 0 0 (32 * s + i)) g i where
  row := Launch.ctxAt_threadgroupPositionInGrid _ _ _ _ _ _
  lane := Launch.ctxAt_lane _ _ _ _ _ _ _
  tid := by
    rw [launch_tiles.threadPositionInThreadgroup]
    have := s.isLt; have := i.isLt
    congr 1 <;> omega
  thread := by rw [launch_tiles.thread]; have := s.isLt; omega
  group := by rw [launch_tiles.group_id]; omega
  hg := hg
  hi := i.isLt
end

section
variable {X Gt W : ByteMemory.Bytes} {ax ag aw : Nat} {initial : Nat → ByteMemory.Bytes}

/-- A row's SIMD-group: every lane to the `simd_sum`, then every lane to the end, writing its four elements. -/
theorem simd_run (hS : Shape (launch X Gt W ax ag aw initial) ax ag aw) (fuse : Nat → Bool) (g : Nat) (hg : g < 48)
    (s : Fin 1) (sh : Shared) (hI : Inv C (launch X Gt W ax ag aw initial) (fuse 1) X Gt W (128 * g) sh) :
    ∃ (f r : Nat) (V : Fin 32 → Thread) (sh' : Shared),
      (runSimd C f r (List.ofFn ((launch X Gt W ax ag aw initial).lanes fuse g 0 0 s))).run sh = some (List.ofFn V, sh') ∧
      Inv C (launch X Gt W ax ag aw initial) (fuse 1) X Gt W (128 * g + 128) sh' ∧ ∀ i, (V i).status = .done := by
  refine simd_collective_bound C _ 2 14 .sum .f32 0 (fun i => .f32 (sumSq C (fuse 1) X g i 4))
    (fun _ => .f32 (rowSum C (fuse 1) X g)) (resolve_sum C 0 _)
    (fun _ sh => Inv C (launch X Gt W ax ag aw initial) (fuse 1) X Gt W (128 * g) sh)
    (fun i t => t.ctx = (launch X Gt W ax ag aw initial).ctxAt fuse g 0 0 (32 * s + i) ∧ t.frames = [.block rest] ∧
      Locs g i t.locals)
    (fun sh => Inv C (launch X Gt W ax ag aw initial) (fuse 1) X Gt W (128 * g + 128) sh) (fun _ t => t.status = .done)
    (fun i sh hI => ?_) (fun U sh hU hI => ?_) sh hI
  · obtain ⟨l, ⟨n, hn⟩, hloc⟩ := lane_start C _ g i (lane_of fuse g hg s i) ax sh (by rw [hI.regions]; exact hS.r0) hS.ax
    refine ⟨n, _, _, hn n le_rfl, loads_inv C ax hI hS.r0 _ g i 4, ?_, rfl, rfl, hloc⟩
    rw [hI.x]; rfl
  · have hlane : ∀ (i : Fin 32) (sh : Shared), Inv C (launch X Gt W ax ag aw initial) (fuse 1) X Gt W (128 * g + 4 * i) sh →
        ∃ f t sh', (runThread C f ({ U i with status := .running }.set 14 (.f32 (rowSum C (fuse 1) X g)))).run sh =
          some (t, sh') ∧ Inv C (launch X Gt W ax ag aw initial) (fuse 1) X Gt W (128 * g + 4 * (i + 1)) sh' ∧
          blocked t.status = true ∧ t.status = .done := by
      intro i sh hI
      obtain ⟨hc, hf, hloc⟩ := hU i
      rw [resume_eq (U i) _ _ hc hf]
      obtain ⟨l', sh', hex, hI'⟩ := lane_finish hS (lane_of fuse g hg s i) _ hloc sh hI
      obtain ⟨n, hn⟩ := hex.reaches_done.run rfl
      exact ⟨n, _, sh', hn n le_rfl, hI', rfl, rfl⟩
    obtain ⟨f, r, V, sh', hr, hI', hV⟩ := simd_blocked_bound C _
      (fun i sh => Inv C (launch X Gt W ax ag aw initial) (fuse 1) X Gt W (128 * g + 4 * i) sh)
      (fun _ t => t.status = .done) hlane sh (by simpa using hI)
    exact ⟨f, r, V, sh', hr, by simpa using hI', hV⟩

/-- A row's threadgroup: its one SIMD-group, to the end. -/
theorem group_run (hS : Shape (launch X Gt W ax ag aw initial) ax ag aw) (fuse : Nat → Bool) (g : Nat) (hg : g < 48)
    (sh : Shared) (hI : Inv C (launch X Gt W ax ag aw initial) (fuse 1) X Gt W (128 * g) sh) :
    ∃ f r b sh', (runGroup C f r b (List.ofFn fun s : Fin 1 =>
      List.ofFn ((launch X Gt W ax ag aw initial).lanes fuse g 0 0 s))).run sh = some ((), sh') ∧
      Inv C (launch X Gt W ax ag aw initial) (fuse 1) X Gt W (128 * g + 128) sh' := by
  obtain ⟨f, r, b, sh', hr, hI'⟩ := group_done_bound C (fun s : Fin 1 => (launch X Gt W ax ag aw initial).lanes fuse g 0 0 s)
    (fun j sh => Inv C (launch X Gt W ax ag aw initial) (fuse 1) X Gt W (128 * g + 128 * j) sh) (fun j sh hj => by
      obtain ⟨f, r, V, sh', hr, hI', hV⟩ := simd_run C hS fuse g hg j sh (by
        have : j.val = 0 := by have := j.isLt; omega
        simpa [this] using hj)
      refine ⟨f, r, V, sh', hr, ?_, hV⟩
      have : j.val = 0 := by have := j.isLt; omega
      simpa [this] using hI') sh (by simpa using hI)
  exact ⟨f, r, b, sh', hr, by simpa using hI'⟩

/-- The whole launch: the 48 rows in order, each writing its 128 elements. -/
theorem launch_inv (hS : Shape (launch X Gt W ax ag aw initial) ax ag aw) (fuse : Nat → Bool) (garbage : Garbage) :
    ∃ n sh, Inv C (launch X Gt W ax ag aw initial) (fuse 1) X Gt W 6144 sh ∧
      runLaunch C fuse (launch X Gt W ax ag aw initial) garbage n n n = some ⟨sh.bytes, sh.log⟩ := by
  obtain ⟨n, sh, hI, hr⟩ := launch_bound C launch_tiles fuse garbage
    (fun G sh => Inv C (launch X Gt W ax ag aw initial) (fuse 1) X Gt W (128 * G) sh)
    ⟨rfl, initial_input (L := launch X Gt W ax ag aw initial) rfl garbage 0 (by simp [inputs]),
      initial_input (L := launch X Gt W ax ag aw initial) rfl garbage 1 (by simp [inputs]),
      initial_input (L := launch X Gt W ax ag aw initial) rfl garbage 2 (by simp [inputs]), rfl,
      fun e he => absurd he (by omega), fun a ha => by simp [Launch.initial] at ha⟩
    (fun bx byy bz hx hy hz sh hI => by
      obtain rfl : byy = 0 := by omega
      obtain rfl : bz = 0 := by omega
      have hI' : Inv C (launch X Gt W ax ag aw initial) (fuse 1) X Gt W (128 * bx) sh := by simpa using hI
      obtain ⟨f, r, b, sh', hr, hI2⟩ := group_run C hS fuse bx hx _ (hI'.reset rfl garbage (bx + 0 * 48 + 0 * 48 * 1))
      exact ⟨f, r, b, sh', hr, by simpa [Nat.mul_add] using hI2⟩)
  exact ⟨n, sh, by simpa using hI, hr⟩
end

/-- **The GPU runs the gated RMS norm kernel as specified.** Under the GPU assumption, MLX's launch of the
exact assembled text at `gatedNormConfig` on any `x`, `gate` and `weight` buffers whose base addresses are
2-aligned (their bf16 element size) produces `out` with every element as `outElem`: row `e / 128`'s sum of
squares by `simd_sum` (with the compiler's contraction choice at `acc += value * value`), its inverse root
mean, the bf16 normalized product with `weight`, and the gate's sigmoid product. -/
theorem gpu_output (G : Gpu C) (hmax : 32 ≤ G.maxThreads Metal.Elab.Tests.gatedRmsNormText)
    (X Gt W : ByteMemory.Bytes) (ax ag aw : Nat) (hax : 2 ∣ ax) (hag : 2 ∣ ag) (haw : 2 ∣ aw) :
    G.execute Metal.Elab.Tests.gatedRmsNormText (1536, 1, 1) (32, 1, 1)
        [⟨.device, 12288, ax, X⟩, ⟨.device, 12288, ag, Gt⟩, ⟨.device, 256, aw, W⟩] [12288] =
      some [expected C (G.fusion Metal.Elab.Tests.gatedRmsNormText) X Gt W] := by
  have h := gpu_owned C G (grid := (1536, 1, 1)) (tg := (32, 1, 1))
    (inputs := [⟨.device, 12288, ax, X⟩, ⟨.device, 12288, ag, Gt⟩, ⟨.device, 256, aw, W⟩]) (sizes := [12288]) (fun _ => expected C (G.fusion Metal.Elab.Tests.gatedRmsNormText) X Gt W) compile_eq
    (by simpa using hmax) (fun initial garbage => by
      obtain ⟨n, sh, hI, hr⟩ := launch_inv C (initial := initial)
        (launch_shape (X := X) (Gt := Gt) (W := W) (ax := ax) (ag := ag) (aw := aw) (initial := initial) (by omega) (by omega) (by omega))
        (G.fusion Metal.Elab.Tests.gatedRmsNormText) garbage
      refine ⟨n, n, n, sh, dev, tgo, hr, hI.log, ?_⟩
      intro i hi b hb
      obtain rfl : i = 0 := by simp at hi; omega
      have hb' : b < 12288 := by simpa using hb
      show sh.bytes 3 b = expected C _ X Gt W b
      have := hI.out (b / 2) (by omega) (b % 2) (by omega)
      rw [show 2 * (b / 2) + b % 2 = b by omega] at this
      rw [this]
      unfold expected
      rw [ite_eq_left hb'])
  rw [h]
  show some [fun b => if b < 12288 then expected C _ X Gt W b else 0] = _
  congr 2
  funext b
  unfold expected
  split <;> simp_all

end Metal.Kernels.GatedRmsNorm

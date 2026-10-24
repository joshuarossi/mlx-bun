import metal.Elab
import metal.Frontend
import metal.Assemble
import host.mlx.PrefillKernelSources
import metal.kernels.GateUp

namespace Metal.Kernels.VectorExpand
open Metal Metal.Core

/-! # vector-expand.ts: `mlx_bun_trellis_vector_expand`

The header functions the body calls (inlined below; their slots are listed under `body`):

```
static inline int trellis_y(uint s) {
  const uint x = s * 34038481u + 76625530u;
  const uint p = (x & 0x00FF00FFu) + ((x >> 8) & 0x00FF00FFu);
  return (int)((p & 0xFFFFu) + (p >> 16)) - 510;
}
static inline float trellis_refined_y(int y) {
  const float yf = (float)y;
  const float r = 1.0f / 147.800537109375f;
  const float q = yf * r;
  const float e = metal::fma(-q, 147.800537109375f, yf);
  return metal::fma(e, r, q);
}
static inline float trellis_val_rcp(uint s) { return trellis_refined_y(trellis_y(s)); }
```
The body:

```
uint c = thread_position_in_grid.x * 4;
uint r = thread_position_in_grid.y;
if constexpr (ROW_TILE > 0) {
  constexpr uint groups = C / (BT * 2);
  const uint tg = threadgroup_position_in_grid.x;
  const uint tile = tg / (groups * ROW_TILE), within = tg % (groups * ROW_TILE);
  r = tile * ROW_TILE + within % ROW_TILE;
  c = (within / ROW_TILE) * BT * 2 + thread_position_in_threadgroup.x * 4;
}
if (c >= C || r >= R) return;
constexpr uint wpb = BT * BITS / 32;
const uint block = c / BT, t = c % BT;
const device uint* bw = codes + (INTERLEAVE
  ? (ulong)(block / 2) * R * 2 * wpb + (ulong)r * 2 * wpb + (block % 2) * wpb
  : (ulong)r * (C / BT) * wpb + block * wpb);
const float scale = float(scales[r]);
const uint pos = (BT - 1 - (t + 3)) * BITS, wi = pos >> 5, off = pos & 31u;
const ulong window = (ulong(bw[wi]) | (ulong(bw[wi + 1 == wpb ? 0 : wi + 1]) << 32)) >> off;
#pragma clang loop unroll(full)
for (uint i = 0; i < 4; i++) {
  const uint s = uint(window >> ((3 - i) * BITS)) & ((1u << L) - 1);
  const float value = trellis_val_rcp(s);
  out[(ulong)r * C + c + i] = T(value * scale);
}
```
Launch (vector-expand.ts:44-56): inputs `codes` uint32 and `scales` float16, output `out`
bfloat16 `[R, C]`, `T` = bfloat16, template ints R, C, BT, BITS, L, INTERLEAVE, ROW_TILE. The route's
instances are the ANE MLP split's GPU share (ane-prefill-split.ts `AneTrellisExpandReduce`,
`AneTrellisExpandScatter`) at C = 5120, BT = 256, L = 12, R the channels left to the GPU
(11264 at fraction .353, 10752 at .382): gate, up and row-major down (BITS 2, 3, 4; INTERLEAVE 0,
ROW_TILE 0) and the 3-bit block-interleaved down (INTERLEAVE 2, ROW_TILE 128: R is a multiple of
128). The core depends on R, BITS, whether INTERLEAVE is nonzero and on ROW_TILE (with C, BT, L the
route's): `core R bits il tile`, `tile` the row tile when there is one; the tiled body's three
locals shift every later slot by three. -/

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)
def u64l (n : Nat) : CExpr := .lit (.int .u64 n)
def i32l (n : Nat) : CExpr := .lit (.int .i32 n)
def f32l (bits : Nat) : CExpr := .lit (.f32 (Val.ofF32Bits bits))

def u32 (op : Core.BinOp) (a b : CExpr) : CExpr := .bin op .u32 0 a b
def u64 (op : Core.BinOp) (a b : CExpr) : CExpr := .bin op .u64 0 a b
def toU64 (e : CExpr) : CExpr := .conv .u64 e

/-! ## The header functions -/

/-- `trellis_y(s)` with `s` in slot `b`: slots `b` s, `b + 1` the result, `b + 2` x, `b + 3` p. -/
def trellisY (b : Nat) : CStmt :=
  .scope
    [.set (b + 2) (u32 .add (u32 .mul (.local b) (u32l 34038481)) (u32l 76625530)),
     .set (b + 3) (u32 .add (u32 .bitAnd (.local (b + 2)) (u32l 0x00FF00FF))
       (u32 .bitAnd (u32 .shr (.local (b + 2)) (u32l 8)) (u32l 0x00FF00FF))),
     .set (b + 1) (.bin .sub .i32 0
       (.conv .i32 (u32 .add (u32 .bitAnd (.local (b + 3)) (u32l 0xFFFF)) (u32 .shr (.local (b + 3)) (u32l 16))))
       (i32l 510)),
     .leave]

/-- `trellis_refined_y(y)` with `y` in slot `b`: slots `b` y, `b + 1` the result, `b + 2` yf,
`b + 3` r (1/147.800537109375, folded), `b + 4` q, `b + 5` e. -/
def refinedY (b : Nat) : CStmt :=
  .scope
    [.set (b + 2) (.conv .f32 (.local b)),
     .set (b + 3) (f32l 0x3BDDB447),
     .set (b + 4) (.bin .mul .f32 0 (.local (b + 2)) (.local (b + 3))),
     .set (b + 5) (.fma (.un .neg .f32 (.local (b + 4))) (f32l 0x4313CCF0) (.local (b + 2))),
     .set (b + 1) (.fma (.local (b + 5)) (.local (b + 3)) (.local (b + 4))),
     .leave]

/-- `trellis_val_rcp(s)` with `s` in slot `b`: slots `b` s, `b + 1` the result, then `trellis_y`
at `b + 2` and `trellis_refined_y` at `b + 6`. -/
def valRcp (b : Nat) : CStmt :=
  .scope
    [.set (b + 2) (.local b),
     trellisY (b + 2),
     .set (b + 6) (.local (b + 3)),
     refinedY (b + 6),
     .set (b + 1) (.local (b + 7)),
     .leave]

/-! ## The body -/

/-- The `if constexpr` block of a row tile `rt` (slots 5 tg, 6 tile, 7 within). -/
def tileBlock (rt : Nat) : List CStmt :=
  [.set 5 (.component (.coord .threadgroupPositionInGrid) (u32l 0)),
   .set 6 (u32 .div (.local 5) (u32l (10 * rt))),
   .set 7 (u32 .rem (.local 5) (u32l (10 * rt))),
   .set 4 (u32 .add (u32 .mul (.local 6) (u32l rt)) (u32 .rem (.local 7) (u32l rt))),
   .set 3 (u32 .add (u32 .mul (u32 .mul (u32 .div (.local 7) (u32l rt)) (u32l 256)) (u32l 2))
     (u32 .mul (.component (.coord .threadPositionInThreadgroup) (u32l 0)) (u32l 4)))]

/-- `bw`'s word offset, block in slot `k` (wpb = 8·bits words a block). -/
def blockWords (R bits : Nat) (il : Bool) (k : Nat) : CExpr :=
  if il then
    u64 .add
      (u64 .add (u64 .mul (u64 .mul (u64 .mul (toU64 (u32 .div (.local k) (u32l 2))) (u64l R)) (u64l 2)) (u64l (8 * bits)))
        (u64 .mul (u64 .mul (toU64 (.local 4)) (u64l 2)) (u64l (8 * bits))))
      (toU64 (u32 .mul (u32 .rem (.local k) (u32l 2)) (u32l (8 * bits))))
  else
    u64 .add (u64 .mul (u64 .mul (toU64 (.local 4)) (u64l 20)) (u64l (8 * bits)))
      (toU64 (u32 .mul (.local k) (u32l (8 * bits))))

/-- One weight `i` (slot `d + 13`): its state into slot `d + 14`, `trellis_val_rcp` at `d + 15`, value
`d + 27`, stored. -/
def weight (bits d : Nat) : List CStmt :=
  [.set (d + 14) (u32 .bitAnd
     (.conv .u32 (u64 .shr (.local (d + 12)) (toU64 (u32 .mul (u32 .sub (u32l 3) (.local (d + 13))) (u32l bits)))))
     (u32l 4095)),
   .set (d + 15) (.local (d + 14)),
   valRcp (d + 15),
   .set (d + 27) (.local (d + 16)),
   .store (.scalar .bf16)
     (.offset (.local 2) (u64 .add (u64 .add (u64 .mul (toU64 (.local 4)) (u64l 5120)) (toU64 (.local 3)))
       (toU64 (.local (d + 13)))))
     (.conv .bf16 (.bin .mul .f32 0 (.local (d + 27)) (.local (d + 8))))]

/-- `bw[wi]` (`wi` in slot `d + 10`) and the window's second word. -/
def windowExpr (bits d : Nat) : CExpr :=
  u64 .shr
    (u64 .bitOr (toU64 (.load (.scalar .u32) (.offset (.local (d + 7)) (.local (d + 10)))))
      (u64 .shl
        (toU64 (.load (.scalar .u32) (.offset (.local (d + 7))
          (.cond (u32 .eq (u32 .add (.local (d + 10)) (u32l 1)) (u32l (8 * bits))) (u32l 0)
            (u32 .add (.local (d + 10)) (u32l 1))))))
        (u64l 32)))
    (toU64 (.local (d + 11)))

/-- Slots: 0 codes, 1 scales, 2 out, 3 c, 4 r, with a row tile 5 tg, 6 tile, 7 within; then, `d` = 3
with a row tile and 0 without, `d + 5` block, `d + 6` t, `d + 7` bw, `d + 8` scale, `d + 9` pos,
`d + 10` wi, `d + 11` off, `d + 12` window, `d + 13` i, `d + 14` s, `d + 15` … `d + 26`
`trellis_val_rcp`'s (`valRcp`), `d + 27` value. -/
def body (R bits : Nat) (il : Bool) (tile : Option Nat) : List CStmt :=
  let d := if tile.isSome then 3 else 0
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .u32⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .f16⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .bf16⟩)),
   .scope
     ([.set 3 (u32 .mul (.component (.coord .threadPositionInGrid) (u32l 0)) (u32l 4)),
       .set 4 (.component (.coord .threadPositionInGrid) (u32l 1))] ++
      (match tile with
       | some rt => tileBlock rt
       | none => []) ++
      [.ite (.or (u32 .ge (.local 3) (u32l 5120)) (u32 .ge (.local 4) (u32l R))) [.leave] [],
       .set (d + 5) (u32 .div (.local 3) (u32l 256)),
       .set (d + 6) (u32 .rem (.local 3) (u32l 256)),
       .set (d + 7) (.offset (.local 0) (blockWords R bits il (d + 5))),
       .set (d + 8) (.conv .f32 (.load (.scalar .f16) (.offset (.local 1) (.local 4)))),
       .set (d + 9) (u32 .mul (u32 .sub (u32l 255) (u32 .add (.local (d + 6)) (u32l 3))) (u32l bits)),
       .set (d + 10) (u32 .shr (.local (d + 9)) (u32l 5)),
       .set (d + 11) (u32 .bitAnd (.local (d + 9)) (u32l 31)),
       .set (d + 12) (windowExpr bits d),
       .set (d + 13) (u32l 0),
       .loop (u32 .lt (.local (d + 13)) (u32l 4)) [.set (d + 13) (u32 .add (.local (d + 13)) (u32l 1))]
         (weight bits d)])]

def core (R bits : Nat) (il : Bool) (tile : Option Nat) : Kernel := ⟨3, [], [], body R bits il tile⟩

section Texts
open Host.Mlx
/-! ## The texts MLX compiles

`codes` `uint32 [R, 160·BITS]` (row-major words) or `[10, R, 48]` (3-bit block-interleaved, the
rows of the down projection's GPU share), `scales` `float16 [R]`; any shapes of at least 8 elements
give the same text. -/

def inputs (R bits : Nat) (il : Bool) : List Assemble.Input :=
  [⟨chars!"codes", .uint32, if il then [10, R, 48] else [R, 160 * bits]⟩, ⟨chars!"scales", .float16, [R]⟩]

def args (R bits il rt : Nat) : List Assemble.TemplateArg :=
  [.dtype chars!"T" .bfloat16, .int chars!"R" R, .int chars!"C" 5120, .int chars!"BT" 256, .int chars!"BITS" bits,
    .int chars!"L" 12, .int chars!"INTERLEAVE" il, .int chars!"ROW_TILE" rt]

def assembled (R bits il rt : Nat) : Option (List Char) :=
  Assemble.assemble (PrefillSources.name .vectorExpand) (inputs R bits (il != 0)) [chars!"out"] [.bfloat16]
    (PrefillSources.source .vectorExpand) (PrefillSources.header .vectorExpand) (args R bits il rt) false

def text (R bits il rt : Nat) : List Char := (assembled R bits il rt).getD []

/-- Every route instance assembles. -/
theorem assembled_route :
    (assembled 11264 2 0 0).isSome ∧ (assembled 11264 3 0 0).isSome ∧ (assembled 11264 4 0 0).isSome ∧
    (assembled 10752 2 0 0).isSome ∧ (assembled 10752 3 0 0).isSome ∧ (assembled 10752 4 0 0).isSome ∧
    (assembled 11264 3 2 128).isSome ∧ (assembled 10752 3 2 128).isSome := by
  decide +kernel

kernel_rfl compile_11264_2 : (frontend (text 11264 2 0 0)).bind elaborate = some (core 11264 2 false none)
kernel_rfl compile_11264_3 : (frontend (text 11264 3 0 0)).bind elaborate = some (core 11264 3 false none)
kernel_rfl compile_11264_4 : (frontend (text 11264 4 0 0)).bind elaborate = some (core 11264 4 false none)
kernel_rfl compile_10752_2 : (frontend (text 10752 2 0 0)).bind elaborate = some (core 10752 2 false none)
kernel_rfl compile_10752_3 : (frontend (text 10752 3 0 0)).bind elaborate = some (core 10752 3 false none)
kernel_rfl compile_10752_4 : (frontend (text 10752 4 0 0)).bind elaborate = some (core 10752 4 false none)
kernel_rfl compile_11264_k3i : (frontend (text 11264 3 2 128)).bind elaborate = some (core 11264 3 true (some 128))
kernel_rfl compile_10752_k3i : (frontend (text 10752 3 2 128)).bind elaborate = some (core 10752 3 true (some 128))

end Texts
end Metal.Kernels.VectorExpand

/-! ## Expected outputs -/

namespace Metal.Kernels.VectorExpand
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

section Spec
variable (C : M1Max.Contract)

/-- `trellis_refined_y(y)`: `yf = (float)y` (exact), `q = yf · r` with `r` the folded
`1.0f / 147.800537109375f` (word `0x3BDDB447`), `e = fma(-q, 147.800537109375f, yf)` (`0x4313CCF0`),
then `fma(e, r, q)`. -/
def refinedVal (y : Int) : Float32 :=
  let yf := Val.ofF32Bits (exactF32 y)
  let r := Val.ofF32Bits 0x3BDDB447
  let q := C.fmul yf r
  C.fma (C.fma (f32Neg q) (Val.ofF32Bits 0x4313CCF0) yf) r q

/-- `trellis_val_rcp(s) = trellis_refined_y(trellis_y(s))` (`trellisYv`: GateUp.lean). -/
def valRcpVal (s : Nat) : Float32 := refinedVal C (trellisYv s)

/-- `bw - codes`: the first word of block `blk` of row `r`, as the source computes it (`wpb = 8·bits`). -/
def blockBase (R bits : Nat) (il : Bool) (r blk : Nat) : Nat :=
  if il then blk / 2 * R * 2 * (8 * bits) + r * 2 * (8 * bits) + blk % 2 * (8 * bits)
  else r * 20 * (8 * bits) + blk * (8 * bits)

/-- The 12-bit trellis state of weight `(r, col)`: column `col % 256` of block `col / 256` of row `r`
(`trellisCode`: GateUp.lean, the block's tail-biting bits). -/
def state (R bits : Nat) (il : Bool) (Codes : ByteMemory.Bytes) (r col : Nat) : Nat :=
  trellisCode bits Codes (blockBase R bits il r (col / 256)) (col % 256)

/-- `out[r, col] = T(trellis_val_rcp(s) * scale)`, `scale = float(scales[r])`. -/
def outVal (R bits : Nat) (il : Bool) (Codes S : ByteMemory.Bytes) (r col : Nat) : BF :=
  C.narrow (C.fmul (valRcpVal C (state R bits il Codes r col)) (scale S r))

/-- Byte `b` of `out` `[R, 5120]` bf16. -/
def expected (R bits : Nat) (il : Bool) (Codes S : ByteMemory.Bytes) (b : Nat) : BitVec 8 :=
  if b < 10240 * R then
    (wordBytes 2 (Val.bf16Bits (outVal C R bits il Codes S (b / 2 / 5120) (b / 2 % 5120)))).getD (b % 2) 0
  else 0

end Spec

end Metal.Kernels.VectorExpand

namespace Metal.Kernels.VectorExpandProof
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis
open Metal.Kernels.VectorExpand (refinedVal valRcpVal blockBase state outVal expected u32l u64l f32l)

/-! ## Threads and the elements they write -/

/-- The row `r` and column `c` thread `T` computes. -/
def rowOf : Option Nat → Nat → Nat
  | none, T => T / 1280
  | some rt, T => T / 128 / (10 * rt) * rt + T / 128 % (10 * rt) % rt

def colOf : Option Nat → Nat → Nat
  | none, T => T % 1280 * 4
  | some rt, T => T / 128 % (10 * rt) / rt * 256 * 2 + T % 128 * 4

/-- The four elements thread `T` writes: quad `rowOf · 1280 + colOf / 4`. -/
def quadOf (tile : Option Nat) (T : Nat) : Nat := rowOf tile T * 1280 + colOf tile T / 4

/-- The thread writing quad `q`. -/
def threadOf : Option Nat → Nat → Nat
  | none, q => q
  | some rt, q => (q / 1280 / rt * (10 * rt) + q % 1280 / 128 * rt + q / 1280 % rt) * 128 + q % 1280 % 128

/-- The row tiles the code handles: any positive tile dividing `R`. -/
def TileOk (R : Nat) : Option Nat → Prop
  | none => True
  | some rt => 0 < rt ∧ rt ∣ R

theorem tile_split {rt bx : Nat} (hrt : 0 < rt) :
    bx = bx / (10 * rt) * (10 * rt) + bx % (10 * rt) / rt * rt + bx % (10 * rt) % rt ∧
      bx % (10 * rt) / rt < 10 ∧ bx % (10 * rt) % rt < rt := by
  have h1 := Nat.div_add_mod bx (10 * rt)
  have h2 := Nat.div_add_mod (bx % (10 * rt)) rt
  have h3 : bx % (10 * rt) < 10 * rt := Nat.mod_lt _ (by omega)
  refine ⟨?_, (Nat.div_lt_iff_lt_mul hrt).mpr h3, Nat.mod_lt _ hrt⟩
  rw [Nat.mul_comm (bx / (10 * rt)), Nat.mul_comm (bx % (10 * rt) / rt)]
  omega

theorem tile_div {rt a b w : Nat} (hrt : 0 < rt) (hb : b < 10) (hw : w < rt) :
    (a * (10 * rt) + b * rt + w) / (10 * rt) = a ∧ (a * (10 * rt) + b * rt + w) % (10 * rt) = b * rt + w ∧
      (b * rt + w) / rt = b ∧ (b * rt + w) % rt = w := by
  have hlt : b * rt + w < 10 * rt := by nlinarith
  have hm : 0 < 10 * rt := by omega
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [Nat.add_assoc, Nat.mul_comm a, Nat.mul_add_div hm, Nat.div_eq_of_lt hlt, Nat.add_zero]
  · rw [Nat.add_assoc, Nat.mul_comm a, Nat.mul_add_mod, Nat.mod_eq_of_lt hlt]
  · rw [Nat.mul_comm b, Nat.mul_add_div hrt, Nat.div_eq_of_lt hw, Nat.add_zero]
  · rw [Nat.mul_comm b, Nat.mul_add_mod, Nat.mod_eq_of_lt hw]

theorem rowOf_lt {R : Nat} {tile : Option Nat} (ht : TileOk R tile) {T : Nat} (hT : T < 1280 * R) :
    rowOf tile T < R ∧ colOf tile T < 5120 ∧ colOf tile T % 4 = 0 := by
  cases tile with
  | none => simp only [rowOf, colOf]; omega
  | some rt =>
    obtain ⟨hrt, n, rfl⟩ := ht
    obtain ⟨-, hb, hw⟩ := tile_split (bx := T / 128) hrt
    simp only [rowOf, colOf]
    refine ⟨?_, by omega, by omega⟩
    have ha : T / 128 / (10 * rt) < n := (Nat.div_lt_iff_lt_mul (by omega)).mpr (by
      have : T / 128 < 10 * (rt * n) := by omega
      calc T / 128 < 10 * (rt * n) := this
        _ = n * (10 * rt) := by ring)
    have : (T / 128 / (10 * rt) + 1) * rt ≤ n * rt := Nat.mul_le_mul_right _ ha
    calc T / 128 / (10 * rt) * rt + T / 128 % (10 * rt) % rt < (T / 128 / (10 * rt) + 1) * rt := by
          rw [Nat.add_mul, Nat.one_mul]; omega
      _ ≤ n * rt := this
      _ = rt * n := Nat.mul_comm _ _

theorem threadOf_quadOf {R : Nat} {tile : Option Nat} (ht : TileOk R tile) (T : Nat) :
    threadOf tile (quadOf tile T) = T := by
  cases tile with
  | none => simp only [threadOf, quadOf, rowOf, colOf]; omega
  | some rt =>
    obtain ⟨hrt, -⟩ := ht
    obtain ⟨hsplit, hb, hw⟩ := tile_split (bx := T / 128) hrt
    simp only [threadOf, quadOf, rowOf, colOf]
    generalize T / 128 / (10 * rt) = a at hsplit ⊢
    generalize T / 128 % (10 * rt) / rt = b at hsplit hb ⊢
    generalize T / 128 % (10 * rt) % rt = w at hsplit hw ⊢
    have hq1 : ((a * rt + w) * 1280 + (b * 256 * 2 + T % 128 * 4) / 4) / 1280 = a * rt + w := by omega
    have hq2 : ((a * rt + w) * 1280 + (b * 256 * 2 + T % 128 * 4) / 4) % 1280 = b * 128 + T % 128 := by omega
    have hd : (a * rt + w) / rt = a := by
      rw [Nat.mul_comm a, Nat.mul_add_div hrt, Nat.div_eq_of_lt hw, Nat.add_zero]
    have hm : (a * rt + w) % rt = w := by rw [Nat.mul_comm a, Nat.mul_add_mod, Nat.mod_eq_of_lt hw]
    rw [hq1, hq2, hd, hm, show (b * 128 + T % 128) / 128 = b by omega, show (b * 128 + T % 128) % 128 = T % 128 by omega]
    omega

theorem quadOf_threadOf {R : Nat} {tile : Option Nat} (ht : TileOk R tile) {q : Nat} (hq : q < 1280 * R) :
    quadOf tile (threadOf tile q) = q ∧ threadOf tile q < 1280 * R := by
  cases tile with
  | none => simp only [threadOf, quadOf, rowOf, colOf]; omega
  | some rt =>
    obtain ⟨hrt, n, rfl⟩ := ht
    simp only [threadOf, quadOf, rowOf, colOf]
    have hr := Nat.div_add_mod (q / 1280) rt
    have hw : q / 1280 % rt < rt := Nat.mod_lt _ hrt
    have hb : q % 1280 / 128 < 10 := by omega
    have hdiv := tile_div (a := q / 1280 / rt) hrt hb hw
    have ha : q / 1280 / rt < n := (Nat.div_lt_iff_lt_mul hrt).mpr (by rw [Nat.mul_comm]; omega)
    have hbx : q / 1280 / rt * (10 * rt) + q % 1280 / 128 * rt + q / 1280 % rt < n * (10 * rt) := by
      have h1 : (q / 1280 / rt + 1) * (10 * rt) ≤ n * (10 * rt) := Nat.mul_le_mul_right _ ha
      have h2 : q % 1280 / 128 * rt + q / 1280 % rt < 10 * rt := by nlinarith
      rw [Nat.add_mul, Nat.one_mul] at h1
      omega
    generalize q / 1280 / rt * (10 * rt) + q % 1280 / 128 * rt + q / 1280 % rt = bx at hdiv hbx
    have e1 : (bx * 128 + q % 1280 % 128) / 128 = bx := by omega
    have e2 : (bx * 128 + q % 1280 % 128) % 128 = q % 1280 % 128 := by omega
    rw [e1, e2, hdiv.1, hdiv.2.1, hdiv.2.2.1, hdiv.2.2.2]
    refine ⟨?_, ?_⟩
    · rw [Nat.mul_comm (q / 1280 / rt) rt]
      omega
    · have : n * (10 * rt) = 10 * (rt * n) := by ring
      omega


/-! ## The launch -/

/-- The inputs: the codes, the scales, and their base alignments. -/
structure In where
  Codes : ByteMemory.Bytes
  S : ByteMemory.Bytes
  ac : Nat
  as : Nat

/-- `codes` (`640·R·bits` bytes in either layout) and `scales` (`float16 [R]`). -/
def bufs (R bits : Nat) (I : In) : List Buffer :=
  [⟨.device, 640 * R * bits, I.ac, I.Codes⟩, ⟨.device, 2 * R, I.as, I.S⟩]

/-- vector-expand.ts's grid: `[1280, R, 1]`, or `[1280·R, 1, 1]` with a row tile. -/
def grid : Option Nat → Nat → Nat × Nat × Nat
  | none, R => (1280, R, 1)
  | some _, R => (1280 * R, 1, 1)

def launch (R bits : Nat) (il : Bool) (tile : Option Nat) (I : In) (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨VectorExpand.core R bits il tile, grid tile R, (128, 1, 1), buffers (bufs R bits I) [10240 * R] 16 initial⟩

/-- The writer of each output byte: the thread of its quad, in that thread's threadgroup `T / 128`. -/
def dev (tile : Option Nat) (region byte : Nat) : Option Writer :=
  if region = 2 then some ⟨threadOf tile (byte / 8), threadOf tile (byte / 8) / 128, 0⟩ else none

/-- No threadgroup memory. -/
def tgo (_g _e _region _byte : Nat) : Option Nat := none

structure Shape (L : Launch) (R bits : Nat) (I : In) : Prop where
  r0 : L.regions 0 = some ⟨.device, 640 * R * bits, I.ac⟩
  r1 : L.regions 1 = some ⟨.device, 2 * R, I.as⟩
  r2 : L.regions 2 = some ⟨.device, 10240 * R, 16⟩
  ac : I.ac % 4 = 0
  as : I.as % 2 = 0

theorem launch_shape {R bits : Nat} {il : Bool} {tile : Option Nat} {I : In} {initial : Nat → ByteMemory.Bytes}
    (hac : I.ac % 4 = 0) (has : I.as % 2 = 0) : Shape (launch R bits il tile I initial) R bits I := by
  have hb : (launch R bits il tile I initial).buffers = buffers (bufs R bits I) [10240 * R] 16 initial := rfl
  exact ⟨regions_input hb 0 (by simp [bufs]), regions_input hb 1 (by simp [bufs]), regions_output hb 0 (by simp),
    hac, has⟩

/-! ## Memory -/

section Memory
variable (C : M1Max.Contract)

/-- Memory during the launch: the inputs intact, no barrier passed, the output elements with `ok` written, and
every access so far keeping the ownership discipline. -/
structure Mem (L : Launch) (R bits : Nat) (il : Bool) (tile : Option Nat) (I : In) (ok : Nat → Prop) (sh : Shared) :
    Prop where
  regions : sh.regions = L.regions
  codes : sh.bytes 0 = I.Codes
  scales : sh.bytes 1 = I.S
  deve : sh.deviceEpoch = 0
  out : ∀ e < 5120 * R, ok e →
    cells (sh.bytes 2) (2 * e) 2 = wordBytes 2 (Val.bf16Bits (outVal C R bits il I.Codes I.S (e / 5120) (e % 5120)))
  log : ∀ a ∈ sh.log, Owned L (dev tile) tgo a

variable {C} {L : Launch} {R bits : Nat} {il : Bool} {tile : Option Nat} {I : In} {ok : Nat → Prop} {sh : Shared}

theorem Mem.mono (h : Mem C L R bits il tile I ok sh) {ok' : Nat → Prop} (hok : ∀ e < 5120 * R, ok' e → ok e) :
    Mem C L R bits il tile I ok' sh :=
  ⟨h.regions, h.codes, h.scales, h.deve, fun e he h' => h.out e he (hok e he h'), h.log⟩

/-- A read of an input. -/
theorem Mem.rd (h : Mem C L R bits il tile I ok sh) (hS : Shape L R bits I) (ctx : Ctx) (reg o n : Nat)
    (hreg : reg < 2) : Mem C L R bits il tile I ok (rdn ctx sh reg o n) :=
  ⟨h.regions, h.codes, h.scales, h.deve, h.out, forall_log _ n _ (fun j _ => by
    obtain ⟨r, hr, hs⟩ : ∃ r, L.regions reg = some r ∧ r.space ≠ .threadgroup := by
      rcases (show reg = 0 ∨ reg = 1 by omega) with rfl | rfl
      exacts [⟨_, hS.r0, by simp⟩, ⟨_, hS.r1, by simp⟩]
    exact owned_device_read L (dev tile) tgo ctx sh reg (o + j) r hr hs (by simp only [dev]; rw [ite_eq_right (by omega)]))
    h.log⟩

/-- The thread of quad `e / 4` writes element `e`. -/
theorem Mem.wout (h : Mem C L R bits il tile I ok sh) (hS : Shape L R bits I) (ctx : Ctx) (e : Nat)
    (he : e < 5120 * R) (ht : ctx.thread = threadOf tile (e / 4)) (hg : ctx.group = threadOf tile (e / 4) / 128) :
    Mem C L R bits il tile I (fun e' => ok e' ∨ e' = e)
      (wrn ctx sh 2 (2 * e) 2 (wordBytes 2 (Val.bf16Bits (outVal C R bits il I.Codes I.S (e / 5120) (e % 5120))))) := by
  have hl : (wordBytes 2 (Val.bf16Bits (outVal C R bits il I.Codes I.S (e / 5120) (e % 5120)))).length = 2 :=
    wordBytes_length 2 _
  refine ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.codes,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.scales, h.deve, fun e' he' hok => ?_,
    forall_log _ 2 _ (fun j hj => owned_device L (dev tile) tgo ctx sh 2 (2 * e + j) _ hS.r2 true (by simp)
      ⟨threadOf tile ((2 * e + j) / 8), threadOf tile ((2 * e + j) / 8) / 128, 0⟩ (ite_eq_left rfl)
      (by rw [ht, show (2 * e + j) / 8 = e / 4 by omega]) (by rw [hg, show (2 * e + j) / 8 = e / 4 by omega])
      (by rw [h.deve])) h.log⟩
  rw [wrn_same]
  by_cases hee : e' = e
  · subst hee
    have := cells_writeBytes_same (sh.bytes 2) (2 * e')
      (wordBytes 2 (Val.bf16Bits (outVal C R bits il I.Codes I.S (e' / 5120) (e' % 5120))))
    rwa [hl] at this
  · rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl]; omega)]
    exact h.out e' he' (hok.resolve_right hee)

end Memory

/-! ## A thread -/

def gridX : Option Nat → Nat → Nat
  | none, T => T % 1280
  | some _, T => T

def gridY : Option Nat → Nat → Nat
  | none, T => T / 1280
  | some _, _ => 0

/-- Thread `T` of the launch (threadgroup `T / 128`, thread `T % 128` in it). -/
structure Lane (tile : Option Nat) (R : Nat) (ctx : Ctx) (T : Nat) : Prop where
  hT : T < 1280 * R
  thread : ctx.thread = T
  group : ctx.group = T / 128
  tpig : ctx.coord .threadPositionInGrid = u32x3 (gridX tile T) (gridY tile T) 0
  tpitg : ctx.coord .threadPositionInThreadgroup = u32x3 (T % 128) 0 0
  tgpig : tile.isSome → ctx.coord .threadgroupPositionInGrid = u32x3 (T / 128) 0 0

/-! ### The header functions -/

section Decode
variable (C : M1Max.Contract) {ctx : Ctx}

theorem trellisY_eq (b : Nat) : VectorExpand.trellisY b = trellisYAt b := rfl

theorem trellisYv_bounds (s : Nat) : -510 ≤ trellisYv s ∧ trellisYv s < 2 ^ 17 := by
  have h1 := Nat.and_le_right (n := trellisP s) (m := 0xFFFF)
  have h2 := trellisP_lt s
  have h3 : trellisP s / 2 ^ 16 < 2 ^ 9 := by omega
  unfold trellisYv
  omega

/-- The inlined `trellis_refined_y(y)`: its value in slot `b + 1`. -/
theorem exec_refinedY (b : Nat) {l : Locals} {sh : Shared} {y : Int} (h : l b = some (i32 y)) (h1 : -2 ^ 24 ≤ y)
    (h2 : y ≤ 2 ^ 24) :
    ∃ l', Exec C ctx [VectorExpand.refinedY b] l sh .normal l' sh ∧ l' (b + 1) = some (.f32 (refinedVal C y)) ∧
      ∀ j, j ≤ b ∨ b + 5 < j → l' j = l j := by
  have e2 : (eval C ctx l (.conv .f32 (.local b))).run sh = some (.f32 (Val.ofF32Bits (exactF32 y)), sh) :=
    eval_conv C (eval_local' C h sh) (convert_f32_i32v C h1 h2)
  generalize hyf : Val.ofF32Bits (exactF32 y) = yf at e2
  generalize hrc : Val.ofF32Bits 0x3BDDB447 = rc
  generalize hl₁ : setLocal l (b + 2) (.f32 yf) = l₁
  generalize hl₂ : setLocal l₁ (b + 3) (.f32 rc) = l₂
  have h22 : l₂ (b + 2) = some (.f32 yf) := by rw [← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_same]
  have h23 : l₂ (b + 3) = some (.f32 rc) := by rw [← hl₂, setLocal_same]
  have e4 : (eval C ctx l₂ (.bin .mul .f32 0 (.local (b + 2)) (.local (b + 3)))).run sh =
      some (.f32 (C.fmul yf rc), sh) :=
    eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_local' C h22 sh) (eval_local' C h23 sh) rfl
  generalize hq : C.fmul yf rc = q at e4
  generalize hl₃ : setLocal l₂ (b + 4) (.f32 q) = l₃
  have h34 : l₃ (b + 4) = some (.f32 q) := by rw [← hl₃, setLocal_same]
  have h32 : l₃ (b + 2) = some (.f32 yf) := by rw [← hl₃, setLocal_other _ _ (by omega)]; exact h22
  have h33 : l₃ (b + 3) = some (.f32 rc) := by rw [← hl₃, setLocal_other _ _ (by omega)]; exact h23
  have e5 : (eval C ctx l₃ (.fma (.un .neg .f32 (.local (b + 4))) (f32l 0x4313CCF0) (.local (b + 2)))).run sh =
      some (.f32 (C.fma (f32Neg q) (Val.ofF32Bits 0x4313CCF0) yf), sh) :=
    eval_fma C (eval_un C (eval_local' C h34 sh) rfl) (eval_lit C _ _ _ _) (eval_local' C h32 sh)
  generalize hee : C.fma (f32Neg q) (Val.ofF32Bits 0x4313CCF0) yf = ee at e5
  generalize hl₄ : setLocal l₃ (b + 5) (.f32 ee) = l₄
  have h45 : l₄ (b + 5) = some (.f32 ee) := by rw [← hl₄, setLocal_same]
  have h43 : l₄ (b + 3) = some (.f32 rc) := by rw [← hl₄, setLocal_other _ _ (by omega)]; exact h33
  have h44 : l₄ (b + 4) = some (.f32 q) := by rw [← hl₄, setLocal_other _ _ (by omega)]; exact h34
  have e6 : (eval C ctx l₄ (.fma (.local (b + 5)) (.local (b + 3)) (.local (b + 4)))).run sh =
      some (.f32 (C.fma ee rc q), sh) :=
    eval_fma C (eval_local' C h45 sh) (eval_local' C h43 sh) (eval_local' C h44 sh)
  have e3 : (eval C ctx l₁ (f32l 0x3BDDB447)).run sh = some (.f32 rc, sh) := by rw [← hrc]; rfl
  subst hl₄ hl₃ hl₂ hl₁
  refine ⟨_, .scope (.set e2 (.set e3 (.set e4 (.set e5 (.set e6 .leave))))) (.inr rfl) (.nil _ _), ?_, fun j hj => ?_⟩
  · rw [setLocal_same, ← hee, ← hq, ← hyf, ← hrc]; rfl
  · rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_other _ _ (by omega),
      setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]

/-- The inlined `trellis_val_rcp(s)`: its value in slot `b + 1`. -/
theorem exec_valRcp (b : Nat) {l : Locals} {sh : Shared} {s : Nat} (h : l b = some (u32 s)) :
    ∃ l', Exec C ctx [VectorExpand.valRcp b] l sh .normal l' sh ∧ l' (b + 1) = some (.f32 (valRcpVal C s)) ∧
      ∀ j, j ≤ b ∨ b + 11 < j → l' j = l j := by
  obtain ⟨l₁, x1, h13, hf1⟩ := exec_trellisY C (ctx := ctx) (b + 2) (l := setLocal l (b + 2) (u32 s)) (sh := sh)
    (setLocal_same _ _ _)
  have hb := trellisYv_bounds s
  obtain ⟨l₂, x2, h27, hf2⟩ := exec_refinedY C (ctx := ctx) (b + 6) (l := setLocal l₁ (b + 6) (i32 (trellisYv s)))
    (sh := sh) (setLocal_same _ _ _) (by omega) (by omega)
  refine ⟨setLocal l₂ (b + 1) (.f32 (refinedVal C (trellisYv s))),
    .scope (.set (eval_local' C h sh) (x1.append (.set (eval_local' C h13 sh) (x2.append
      (.set (eval_local' C h27 sh) .leave))))) (.inr rfl) (.nil _ _), setLocal_same _ _ _, fun j hj => ?_⟩
  rw [setLocal_other _ _ (by omega), hf2 j (by omega), setLocal_other _ _ (by omega), hf1 j (by omega),
    setLocal_other _ _ (by omega)]

end Decode

/-! ### The loop -/

/-- The locals the loop reads: `out`, `c`, `r`, `scale`, `window`. -/
structure Loc (d c r : Nat) (sc : Float32) (win : Nat) (l : Locals) : Prop where
  l2 : l 2 = some (.ptr ⟨2, 0, .scalar .bf16⟩)
  l3 : l 3 = some (u32 c)
  l4 : l 4 = some (u32 r)
  l8 : l (d + 8) = some (.f32 sc)
  l12 : l (d + 12) = some (u64 win)

theorem Loc.of_eq {d c r : Nat} {sc : Float32} {win : Nat} {l l' : Locals} (h : Loc d c r sc win l)
    (h' : ∀ j, j ≤ d + 12 → l' j = l j) : Loc d c r sc win l' :=
  ⟨(h' 2 (by omega)).trans h.l2, (h' 3 (by omega)).trans h.l3, (h' 4 (by omega)).trans h.l4,
    (h' (d + 8) (by omega)).trans h.l8, (h' (d + 12) (by omega)).trans h.l12⟩

theorem and4095 (x : Nat) : x % 2 ^ 32 &&& 4095 = x % 4096 := by
  have h : x % 2 ^ 32 &&& 2 ^ 12 - 1 = x % 2 ^ 32 % 2 ^ 12 := Nat.and_two_pow_sub_one_eq_mod _ 12
  rw [Nat.mod_mod_of_dvd _ (by norm_num)] at h
  exact h

section Loop
variable (C : M1Max.Contract) {ctx : Ctx}

theorem eval_offset_u32' {l : Locals} {sh sh₁ sh₂ : Shared} {p i : CExpr} {r o n : Nat} {e : Ty}
    (hp : (eval C ctx l p).run sh = some (.ptr ⟨r, (o : Int), e⟩, sh₁))
    (hi : (eval C ctx l i).run sh₁ = some (u32 n, sh₂)) (hn : n < 2 ^ 32) (m : Nat) (hm : o + n * e.bytes = m) :
    (eval C ctx l (.offset p i)).run sh = some (.ptr ⟨r, (m : Int), e⟩, sh₂) := by
  rw [eval_offset_u32 C hp hi hn, hm]

theorem eval_offset_u64' {l : Locals} {sh sh₁ sh₂ : Shared} {p i : CExpr} {r o n : Nat} {e : Ty}
    (hp : (eval C ctx l p).run sh = some (.ptr ⟨r, (o : Int), e⟩, sh₁))
    (hi : (eval C ctx l i).run sh₁ = some (u64 n, sh₂)) (hn : n < 2 ^ 64) (m : Nat) (hm : o + n * e.bytes = m) :
    (eval C ctx l (.offset p i)).run sh = some (.ptr ⟨r, (m : Int), e⟩, sh₂) := by
  rw [eval_offset_u64 C hp hi hn, hm]

/-- One weight of the loop: its state from the window, `trellis_val_rcp`, the product with the scale, the store. -/
theorem exec_weight (d bits : Nat) (hK : bits ≤ 7) {R c r k win : Nat} {sc : Float32} {l : Locals} {sh : Shared}
    (hL : Loc d c r sc win l) (hk : l (d + 13) = some (u32 k)) (hk4 : k < 4) (hwin : win < 2 ^ 64)
    (hr2 : sh.regions 2 = some ⟨.device, 10240 * R, 16⟩) (he : r * 5120 + c + k < 5120 * R) (hR : R < 2 ^ 32)
    (hc : c < 5120) :
    ∃ l', Exec C ctx (VectorExpand.weight bits d) l sh .normal l'
      (wrn ctx sh 2 (2 * (r * 5120 + c + k)) 2
        (wordBytes 2 (Val.bf16Bits (C.narrow (C.fmul (valRcpVal C (win / 2 ^ ((3 - k) * bits) % 4096)) sc))))) ∧
      ∀ j, j ≤ d + 13 → l' j = l j := by
  have hsh : (3 - k) * bits < 64 := by
    have : (3 - k) * bits ≤ 3 * 7 := Nat.mul_le_mul (by omega) hK
    omega
  have hs : (eval C ctx l (.conv .u64 (.bin .mul .u32 0 (.bin .sub .u32 0 (u32l 3) (.local (d + 13)))
      (u32l bits)))).run sh = some (u64 ((3 - k) * bits), sh) :=
    eval_conv C (eval_bin_u32 C (eval_bin_u32 C (eval_u32lit C _ _ 3 (by decide)) (eval_local' C hk sh)
      (binary_sub_u32 C 3 k (by omega))) (eval_u32lit C _ _ bits (by omega)) (binary_mul_u32 C _ _))
      (convert_u64_u32 C _ (by omega))
  have hw : (eval C ctx l (.bin .shr .u64 0 (.local (d + 12)) (.conv .u64 (.bin .mul .u32 0
      (.bin .sub .u32 0 (u32l 3) (.local (d + 13))) (u32l bits))))).run sh =
      some (u64 (win / 2 ^ ((3 - k) * bits)), sh) :=
    eval_int C (by decide) (eval_local' C hL.l12 sh) hs (binary_shr_u64 C win _ hwin hsh)
  have hc : (eval C ctx l (.conv .u32 (.bin .shr .u64 0 (.local (d + 12)) (.conv .u64 (.bin .mul .u32 0
      (.bin .sub .u32 0 (u32l 3) (.local (d + 13))) (u32l bits)))))).run sh =
      some (u32 (win / 2 ^ ((3 - k) * bits) % 2 ^ 32), sh) := by
    rw [u32_mod]; exact eval_conv C hw (convert_u32_u64 C _)
  have e14 : (eval C ctx l (.bin .bitAnd .u32 0 (.conv .u32 (.bin .shr .u64 0 (.local (d + 12))
      (.conv .u64 (.bin .mul .u32 0 (.bin .sub .u32 0 (u32l 3) (.local (d + 13))) (u32l bits)))))
      (u32l 4095))).run sh = some (u32 (win / 2 ^ ((3 - k) * bits) % 4096), sh) := by
    rw [← and4095]
    exact eval_bin_u32 C hc (eval_u32lit C _ _ 4095 (by decide))
      (binary_bitAnd_u32 C _ 4095 (Nat.mod_lt _ (by decide)) (by decide))
  generalize hs' : win / 2 ^ ((3 - k) * bits) % 4096 = s at e14 ⊢
  generalize hl₁ : setLocal l (d + 14) (u32 s) = l₁
  have h14 : l₁ (d + 14) = some (u32 s) := by rw [← hl₁, setLocal_same]
  generalize hl₂ : setLocal l₁ (d + 15) (u32 s) = l₂
  have h15 : l₂ (d + 15) = some (u32 s) := by rw [← hl₂, setLocal_same]
  obtain ⟨l₃, x3, h16, hf3⟩ := exec_valRcp C (ctx := ctx) (d + 15) h15 (sh := sh)
  have hb3 : ∀ j, j ≤ d + 13 → l₃ j = l j := fun j hj => by
    rw [hf3 j (.inl (by omega)), ← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_other _ _ (by omega)]
  generalize hl₄ : setLocal l₃ (d + 27) (.f32 (valRcpVal C s)) = l₄
  have hb4 : ∀ j, j ≤ d + 13 → l₄ j = l j := fun j hj => by rw [← hl₄, setLocal_other _ _ (by omega), hb3 j hj]
  have h27 : l₄ (d + 27) = some (.f32 (valRcpVal C s)) := by rw [← hl₄, setLocal_same]
  have h44 : l₄ 4 = some (u32 r) := by rw [hb4 4 (by omega)]; exact hL.l4
  have h43 : l₄ 3 = some (u32 c) := by rw [hb4 3 (by omega)]; exact hL.l3
  have h413 : l₄ (d + 13) = some (u32 k) := by rw [hb4 (d + 13) le_rfl]; exact hk
  have h42 : l₄ 2 = some (.ptr ⟨2, 0, .scalar .bf16⟩) := by rw [hb4 2 (by omega)]; exact hL.l2
  have h48 : l₄ (d + 8) = some (.f32 sc) := by rw [hb4 (d + 8) (by omega)]; exact hL.l8
  have hi : (eval C ctx l₄ (.bin .add .u64 0 (.bin .add .u64 0 (.bin .mul .u64 0 (.conv .u64 (.local 4)) (u64l 5120))
      (.conv .u64 (.local 3))) (.conv .u64 (.local (d + 13))))).run sh = some (u64 (r * 5120 + c + k), sh) :=
    eval_int C (by decide) (eval_int C (by decide) (eval_int C (by decide)
      (eval_conv C (eval_local' C h44 sh) (convert_u64_u32 C r (by omega)))
      (eval_u64lit C _ _ 5120 (by decide)) (binary_mul_u64 C r 5120))
      (eval_conv C (eval_local' C h43 sh) (convert_u64_u32 C c (by omega)))
      (binary_add_u64 C _ _))
      (eval_conv C (eval_local' C h413 sh) (convert_u64_u32 C k (by omega)))
      (binary_add_u64 C _ _)
  have hp := eval_offset_u64' C (o := 0) (eval_local' C h42 sh) hi (by omega)
    (2 * (r * 5120 + c + k)) (by rw [show (Ty.scalar Scalar.bf16).bytes = 2 from rfl]; omega)
  have hv : (eval C ctx l₄ (.conv .bf16 (.bin .mul .f32 0 (.local (d + 27)) (.local (d + 8))))).run sh =
      some (.bf16 (C.narrow (C.fmul (valRcpVal C s) sc)), sh) :=
    eval_conv C (eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_local' C h27 sh) (eval_local' C h48 sh) rfl) rfl
  have hst := store_shared ctx .bf16 sh 2 (2 * (r * 5120 + c + k)) ⟨.device, 10240 * R, 16⟩
    (.bf16 (C.narrow (C.fmul (valRcpVal C s) sc))) (wordBytes 2 (Val.bf16Bits (C.narrow (C.fmul (valRcpVal C s) sc))))
    hr2 (by simp) (by simp) (by show (16 : Nat) % 2 = 0; rfl) (by show 2 * (r * 5120 + c + k) % 2 = 0; omega)
    (by show 2 * (r * 5120 + c + k) + 2 ≤ 10240 * R; omega) rfl
  subst hl₄ hl₂ hl₁
  exact ⟨_, .set e14 (.set (eval_local' C h14 sh) (x3.append (.set (eval_local' C h16 sh) (.store hp hv hst (.nil _ _))))),
    hb4⟩

end Loop

/-- Element `e` once thread `T` has made its first `k` stores (and every thread before it all of its own). -/
def Done (tile : Option Nat) (T k e : Nat) : Prop := threadOf tile (e / 4) < T ∨ (threadOf tile (e / 4) = T ∧ e % 4 < k)

def loopStmt (bits d : Nat) : CStmt :=
  .loop (.bin .lt .u32 0 (.local (d + 13)) (u32l 4)) [.set (d + 13) (.bin .add .u32 0 (.local (d + 13)) (u32l 1))]
    (VectorExpand.weight bits d)

section Loop2
variable (C : M1Max.Contract) {ctx : Ctx} {L : Launch} {R bits : Nat} {il : Bool} {tile : Option Nat} {I : In}

/-- At the `k`-th test of the loop. -/
def LI (L : Launch) (R bits : Nat) (il : Bool) (tile : Option Nat) (I : In) (T d c r : Nat) (sc : Float32)
    (win k : Nat) (l : Locals) (sh : Shared) : Prop :=
  Loc d c r sc win l ∧ l (d + 13) = some (u32 k) ∧ Mem C L R bits il tile I (Done tile T k) sh

/-- The loop: thread `T`'s four stores. -/
theorem exec_loop (hS : Shape L R bits I) (hK : bits ≤ 7) (hR : R < 2 ^ 32) (ht : TileOk R tile) {T d : Nat} (hT : T < 1280 * R)
    (hth : ctx.thread = T) (hgr : ctx.group = T / 128) {sc : Float32} {win : Nat} (hwin : win < 2 ^ 64)
    (hw : ∀ k < 4, win / 2 ^ ((3 - k) * bits) % 4096 = state R bits il I.Codes (rowOf tile T) (colOf tile T + k))
    (hsc : sc = scale I.S (rowOf tile T)) {l : Locals} {sh : Shared}
    (h0 : LI C L R bits il tile I T d (colOf tile T) (rowOf tile T) sc win 0 l sh) :
    ∃ l' sh', Exec C ctx [loopStmt bits d] l sh .normal l' sh' ∧ Mem C L R bits il tile I (Done tile T 4) sh' := by
  obtain ⟨hr, hc, hc4⟩ := rowOf_lt ht hT
  have hq := threadOf_quadOf ht T
  obtain ⟨l', sh', x, hI⟩ : ∃ l' sh', Exec C ctx [loopStmt bits d] l sh .normal l' sh' ∧
      LI C L R bits il tile I T d (colOf tile T) (rowOf tile T) sc win 4 l' sh' := Exec.loop_count (C := C) (ctx := ctx) 4
    (LI C L R bits il tile I T d (colOf tile T) (rowOf tile T) sc win)
    (LI C L R bits il tile I T d (colOf tile T) (rowOf tile T) sc win)
    (fun k hk l sh hI => ⟨sh, eval_lt_u32 C hI.2.1 (by omega) (by decide), hI⟩)
    (fun k hk l sh hI => by
      obtain ⟨hL, hk', hm⟩ := hI
      have he : rowOf tile T * 5120 + colOf tile T + k < 5120 * R := by omega
      obtain ⟨l₁, x1, hf1⟩ := exec_weight C (ctx := ctx) d bits hK hL hk' hk hwin (by rw [hm.regions]; exact hS.r2) he hR hc
      have e4 : (rowOf tile T * 5120 + colOf tile T + k) / 4 = quadOf tile T := by unfold quadOf; omega
      have e1 : (rowOf tile T * 5120 + colOf tile T + k) / 5120 = rowOf tile T := by omega
      have e2 : (rowOf tile T * 5120 + colOf tile T + k) % 5120 = colOf tile T + k := by omega
      have hval : C.narrow (C.fmul (valRcpVal C (win / 2 ^ ((3 - k) * bits) % 4096)) sc) =
          outVal C R bits il I.Codes I.S ((rowOf tile T * 5120 + colOf tile T + k) / 5120)
            ((rowOf tile T * 5120 + colOf tile T + k) % 5120) := by
        unfold outVal; rw [e1, e2, hw k hk, hsc]
      rw [hval] at x1
      have hm₁ := hm.wout hS ctx _ he (by rw [hth, e4, hq]) (by rw [hgr, e4, hq])
      refine ⟨.normal, l₁, _, setLocal l₁ (d + 13) (u32 (k + 1)), _, .inl rfl, x1,
        .set (eval_bin_u32 C (eval_local' C (by rw [hf1 (d + 13) le_rfl]; exact hk') _) (eval_u32lit C _ _ 1 (by decide))
          (binary_add_u32 C k 1)) (.nil _ _),
        hL.of_eq (fun j hj => by rw [setLocal_other _ _ (by omega), hf1 j (by omega)]), setLocal_same _ _ _,
        hm₁.mono (fun e' he' h' => ?_)⟩
      rcases h' with h' | ⟨h1, h2⟩
      · exact .inl (.inl h')
      · by_cases hk'' : e' % 4 < k
        · exact .inl (.inr ⟨h1, hk''⟩)
        · right
          have hq' := (quadOf_threadOf ht (show e' / 4 < 1280 * R by omega)).1
          rw [h1] at hq'
          unfold quadOf at hq'
          omega) h0
  exact ⟨l', sh', x, hI.2.2⟩

end Loop2

/-! ### Before the loop -/

theorem blockBase_bound (R bits : Nat) (il : Bool) {r blk : Nat} (hr : r < R) (hblk : blk < 20) :
    blockBase R bits il r blk + 8 * bits ≤ 20 * R * (8 * bits) := by
  have key : ∃ X, blockBase R bits il r blk = X * (8 * bits) ∧ X + 1 ≤ 20 * R := by
    cases il
    · exact ⟨r * 20 + blk, by
        rw [show blockBase R bits false r blk = r * 20 * (8 * bits) + blk * (8 * bits) from rfl]; ring, by omega⟩
    · refine ⟨blk / 2 * R * 2 + r * 2 + blk % 2, by
        rw [show blockBase R bits true r blk = blk / 2 * R * 2 * (8 * bits) + r * 2 * (8 * bits) + blk % 2 * (8 * bits)
          from rfl]; ring, ?_⟩
      have : blk / 2 * R ≤ 9 * R := Nat.mul_le_mul_right _ (by omega)
      omega
  obtain ⟨X, hX, hX1⟩ := key
  rw [hX]
  have := Nat.mul_le_mul_right (8 * bits) hX1
  rw [Nat.add_mul, Nat.one_mul] at this
  exact this

theorem or_shift (w1 w2 : Nat) (h1 : w1 < 2 ^ 32) : w1 ||| w2 * 2 ^ 32 = w1 + w2 * 2 ^ 32 := by
  rw [Nat.lor_comm, ← Nat.shiftLeft_eq, ← Nat.shiftLeft_add_eq_or_of_lt h1, Nat.shiftLeft_eq, Nat.add_comm]

/-- The window's states: bits `bits·(255 - col)` … of the block. -/
theorem window_state (bits : Nat) (hK : 0 < bits ∧ bits ≤ 7) (B : ByteMemory.Bytes) (base c k : Nat) (hc : c % 4 = 0)
    (hk : k < 4) :
    (word32 B (base + (255 - (c % 256 + 3)) * bits / 32) +
        word32 B (base + ((255 - (c % 256 + 3)) * bits / 32 + 1) % (8 * bits)) * 2 ^ 32) /
      2 ^ ((255 - (c % 256 + 3)) * bits % 32) / 2 ^ ((3 - k) * bits) % 4096 = trellisCode bits B base ((c + k) % 256) := by
  have hle : (255 - (c % 256 + 3)) * bits ≤ 252 * bits := Nat.mul_le_mul_right _ (by omega)
  have h3k : (3 - k) * bits ≤ 21 := by
    have : (3 - k) * bits ≤ 3 * 7 := Nat.mul_le_mul (by omega) hK.2
    omega
  have hexp : 32 * ((255 - (c % 256 + 3)) * bits / 32) + ((255 - (c % 256 + 3)) * bits % 32 + (3 - k) * bits) =
      bits * (255 - (c + k) % 256) := by
    obtain ⟨h1, h2⟩ := hK
    rcases (show bits = 1 ∨ bits = 2 ∨ bits = 3 ∨ bits = 4 ∨ bits = 5 ∨ bits = 6 ∨ bits = 7 by omega) with
      rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> omega
  generalize hpos : (255 - (c % 256 + 3)) * bits = pos at hle hexp ⊢
  have hlt : pos / 32 < 8 * bits := by omega
  have h2 := window_block (K := bits) B base (pos / 32) 2 (pos % 32 + (3 - k) * bits) (by omega) (by omega)
  have hrb : runBits (fun i => word32 B (base + (pos / 32 + i) % (8 * bits))) 2 =
      word32 B (base + pos / 32) + word32 B (base + (pos / 32 + 1) % (8 * bits)) * 2 ^ 32 := by
    show 0 + word32 B (base + (pos / 32 + 0) % (8 * bits)) * 2 ^ (32 * 0) +
      word32 B (base + (pos / 32 + 1) % (8 * bits)) * 2 ^ (32 * 1) = _
    rw [Nat.add_zero, Nat.mod_eq_of_lt hlt]
    simp
  rw [Nat.div_div_eq_div_mul, ← Nat.pow_add, ← hrb, show (4096 : Nat) = 2 ^ 12 by norm_num, h2, hexp]
  rfl

section Pre
variable (C : M1Max.Contract) {ctx : Ctx} {L : Launch} {R bits : Nat} {il : Bool} {tile : Option Nat} {I : In}

theorem eval_blockWords (R bits : Nat) (il : Bool) (k : Nat) {l : Locals} {sh : Shared} {r c : Nat}
    (hk : l k = some (u32 (c / 256))) (h4 : l 4 = some (u32 r)) (hc : c < 5120) (hR : r < 2 ^ 32) (hR' : R < 2 ^ 32)
    (hK : bits ≤ 7) :
    (eval C ctx l (VectorExpand.blockWords R bits il k)).run sh = some (u64 (blockBase R bits il r (c / 256)), sh) := by
  have hb1 : c / 256 * (8 * bits) < 2 ^ 32 :=
    lt_of_le_of_lt (Nat.mul_le_mul (show c / 256 ≤ 20 by omega) (show 8 * bits ≤ 56 by omega)) (by norm_num)
  have hb2 : c / 256 % 2 * (8 * bits) < 2 ^ 32 :=
    lt_of_le_of_lt (Nat.mul_le_mul (show c / 256 % 2 ≤ 1 by omega) (show 8 * bits ≤ 56 by omega)) (by norm_num)
  cases il with
  | false =>
    exact eval_int C (by decide) (eval_int C (by decide) (eval_int C (by decide)
      (eval_conv C (eval_local' C h4 sh) (convert_u64_u32 C r hR)) (eval_u64lit C _ _ 20 (by decide))
      (binary_mul_u64 C r 20)) (eval_u64lit C _ _ (8 * bits) (by omega)) (binary_mul_u64 C _ _))
      (eval_conv C (eval_bin_u32 C (eval_local' C hk sh) (eval_u32lit C _ _ (8 * bits) (by omega)) (binary_mul_u32 C _ _))
        (convert_u64_u32 C _ hb1)) (binary_add_u64 C _ _)
  | true =>
    exact eval_int C (by decide) (eval_int C (by decide)
      (eval_int C (by decide) (eval_int C (by decide) (eval_int C (by decide)
        (eval_conv C (eval_bin_u32 C (eval_local' C hk sh) (eval_u32lit C _ _ 2 (by decide))
          (binary_div_u32 C _ 2 (by omega) (by decide) (by decide))) (convert_u64_u32 C _ (by omega)))
        (eval_u64lit C _ _ R (by omega)) (binary_mul_u64 C _ _)) (eval_u64lit C _ _ 2 (by decide)) (binary_mul_u64 C _ _))
        (eval_u64lit C _ _ (8 * bits) (by omega)) (binary_mul_u64 C _ _))
      (eval_int C (by decide) (eval_int C (by decide) (eval_conv C (eval_local' C h4 sh) (convert_u64_u32 C r hR))
        (eval_u64lit C _ _ 2 (by decide)) (binary_mul_u64 C _ _)) (eval_u64lit C _ _ (8 * bits) (by omega))
        (binary_mul_u64 C _ _))
      (binary_add_u64 C _ _))
      (eval_conv C (eval_bin_u32 C (eval_bin_u32 C (eval_local' C hk sh) (eval_u32lit C _ _ 2 (by decide))
        (binary_rem_u32 C _ 2 (by omega) (by decide) (by decide))) (eval_u32lit C _ _ (8 * bits) (by omega))
        (binary_mul_u32 C _ _)) (convert_u64_u32 C _ hb2))
      (binary_add_u64 C _ _)

/-- The window's second word: `wi + 1 == wpb ? 0 : wi + 1`. -/
def idx2 (bits d : Nat) : CExpr :=
  .cond (.bin .eq .u32 0 (.bin .add .u32 0 (.local (d + 10)) (u32l 1)) (u32l (8 * bits))) (u32l 0)
    (.bin .add .u32 0 (.local (d + 10)) (u32l 1))

theorem eval_window (bits d : Nat) (hK : 0 < bits ∧ bits ≤ 7) {l : Locals} {sh : Shared} {base wi off size ac : Nat}
    {Codes : ByteMemory.Bytes}
    (h7 : l (d + 7) = some (.ptr ⟨0, ((4 * base : Nat) : Int), .scalar .u32⟩)) (h10 : l (d + 10) = some (u32 wi))
    (h11 : l (d + 11) = some (u32 off)) (hwi : wi < 8 * bits) (hoff : off < 32)
    (hr0 : sh.regions 0 = some ⟨.device, size, ac⟩) (hac : ac % 4 = 0) (hsz : 4 * (base + 8 * bits) ≤ size)
    (hb : sh.bytes 0 = Codes) :
    (eval C ctx l (VectorExpand.windowExpr bits d)).run sh =
      some (u64 ((word32 Codes (base + wi) + word32 Codes (base + (wi + 1) % (8 * bits)) * 2 ^ 32) / 2 ^ off),
        rdn ctx (rdn ctx sh 0 (4 * (base + wi)) 4) 0 (4 * (base + (wi + 1) % (8 * bits))) 4) := by
  have hwi32 : wi < 2 ^ 32 := by omega
  have hj8 : (wi + 1) % (8 * bits) < 8 * bits := Nat.mod_lt _ (by omega)
  have hp1 : (eval C ctx l (.offset (.local (d + 7)) (.local (d + 10)))).run sh =
      some (.ptr ⟨0, ((4 * (base + wi) : Nat) : Int), .scalar .u32⟩, sh) :=
    eval_offset_u32' C (eval_local' C h7 sh) (eval_local' C h10 sh) hwi32 _
      (by rw [show (Ty.scalar Scalar.u32).bytes = 4 from rfl]; ring)
  have hld1 := load_shared ctx .u32 sh 0 (4 * (base + wi)) ⟨.device, size, ac⟩ hr0 (by simp) hac
    (by show 4 * (base + wi) % 4 = 0; omega) (by show 4 * (base + wi) + 4 ≤ size; omega) (by simp [loadOffset])
  have hw1 : (eval C ctx l (.conv .u64 (.load (.scalar .u32) (.offset (.local (d + 7)) (.local (d + 10)))))).run sh =
      some (u64 (word32 Codes (base + wi)), rdn ctx sh 0 (4 * (base + wi)) 4) := by
    refine eval_conv C ((eval_load C ctx l (.scalar .u32) _ _ sh sh hp1).trans hld1) ?_
    rw [hb]
    exact convert_u64_u32 C _ (word32_lt Codes _)
  generalize hsh₁ : rdn ctx sh 0 (4 * (base + wi)) 4 = sh₁ at hw1
  have hr0₁ : sh₁.regions 0 = some ⟨.device, size, ac⟩ := by rw [← hsh₁]; exact hr0
  have hb₁ : sh₁.bytes 0 = Codes := by rw [← hsh₁]; exact hb
  have hj : (eval C ctx l (idx2 bits d)).run sh₁ = some (u32 ((wi + 1) % (8 * bits)), sh₁) := by
    have hc := eval_bin_u32 C (ctx := ctx) (op := .eq) (site := 0)
      (eval_bin_u32 C (op := .add) (site := 0) (eval_local' C h10 sh₁) (eval_u32lit C _ _ 1 (by decide))
        (binary_add_u32 C wi 1)) (eval_u32lit C _ _ (8 * bits) (by omega))
      (binary_eq_u32 C (wi + 1) (8 * bits) (by omega) (by omega))
    refine eval_cond C hc ?_
    by_cases he : wi + 1 = 8 * bits
    · rw [decide_eq_true he, he, Nat.mod_self]; exact eval_u32lit C _ _ 0 (by decide)
    · rw [decide_eq_false he, Nat.mod_eq_of_lt (by omega)]
      exact eval_bin_u32 C (eval_local' C h10 sh₁) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C wi 1)
  have hp2 : (eval C ctx l (.offset (.local (d + 7)) (idx2 bits d))).run sh₁ =
      some (.ptr ⟨0, ((4 * (base + (wi + 1) % (8 * bits)) : Nat) : Int), .scalar .u32⟩, sh₁) :=
    eval_offset_u32' C (eval_local' C h7 sh₁) hj (by omega) _
      (by rw [show (Ty.scalar Scalar.u32).bytes = 4 from rfl]; ring)
  have hld2 := load_shared ctx .u32 sh₁ 0 (4 * (base + (wi + 1) % (8 * bits))) ⟨.device, size, ac⟩ hr0₁ (by simp) hac
    (by show 4 * (base + (wi + 1) % (8 * bits)) % 4 = 0; omega)
    (by show 4 * (base + (wi + 1) % (8 * bits)) + 4 ≤ size; omega) (by simp [loadOffset])
  have hc2 : (eval C ctx l (.conv .u64 (.load (.scalar .u32) (.offset (.local (d + 7)) (idx2 bits d))))).run sh₁ =
      some (u64 (word32 Codes (base + (wi + 1) % (8 * bits))),
        rdn ctx sh₁ 0 (4 * (base + (wi + 1) % (8 * bits))) 4) := by
    refine eval_conv C ((eval_load C ctx l (.scalar .u32) _ _ sh₁ sh₁ hp2).trans hld2) ?_
    rw [hb₁]
    exact convert_u64_u32 C _ (word32_lt Codes _)
  have hw2 : (eval C ctx l (.bin .shl .u64 0 (.conv .u64 (.load (.scalar .u32) (.offset (.local (d + 7)) (idx2 bits d))))
      (u64l 32))).run sh₁ = some (u64 (word32 Codes (base + (wi + 1) % (8 * bits)) * 2 ^ 32),
        rdn ctx sh₁ 0 (4 * (base + (wi + 1) % (8 * bits))) 4) :=
    eval_int C (by decide) hc2 (eval_u64lit C _ _ 32 (by decide)) (binary_shl_u64 C _ 32 (by decide))
  have hl1 := word32_lt Codes (base + wi)
  have hl2 := word32_lt Codes (base + (wi + 1) % (8 * bits))
  have hor := or_shift (word32 Codes (base + wi)) (word32 Codes (base + (wi + 1) % (8 * bits))) hl1
  have hX : word32 Codes (base + wi) + word32 Codes (base + (wi + 1) % (8 * bits)) * 2 ^ 32 < 2 ^ 64 := by omega
  rw [← hor]
  exact eval_int C (by decide) (eval_int C (by decide) hw1 hw2
    (binary_bitOr_u64 C _ _ (by omega) (by omega)))
    (eval_conv C (eval_local' C h11 _) (convert_u64_u32 C off (by omega)))
    (binary_shr_u64 C _ off (by rw [hor]; exact hX) (by omega))

/-- The declarations before the loop. -/
def pre (R bits d : Nat) (il : Bool) : List CStmt :=
  [.ite (.or (.bin .ge .u32 0 (.local 3) (u32l 5120)) (.bin .ge .u32 0 (.local 4) (u32l R))) [.leave] [],
   .set (d + 5) (.bin .div .u32 0 (.local 3) (u32l 256)),
   .set (d + 6) (.bin .rem .u32 0 (.local 3) (u32l 256)),
   .set (d + 7) (.offset (.local 0) (VectorExpand.blockWords R bits il (d + 5))),
   .set (d + 8) (.conv .f32 (.load (.scalar .f16) (.offset (.local 1) (.local 4)))),
   .set (d + 9) (.bin .mul .u32 0 (.bin .sub .u32 0 (u32l 255) (.bin .add .u32 0 (.local (d + 6)) (u32l 3))) (u32l bits)),
   .set (d + 10) (.bin .shr .u32 0 (.local (d + 9)) (u32l 5)),
   .set (d + 11) (.bin .bitAnd .u32 0 (.local (d + 9)) (u32l 31)),
   .set (d + 12) (VectorExpand.windowExpr bits d),
   .set (d + 13) (u32l 0)]

theorem exec_pre (hS : Shape L R bits I) (hK : 0 < bits ∧ bits ≤ 7) (hR : R < 2 ^ 32) (d : Nat) {c r : Nat}
    (hr : r < R) (hc : c < 5120) (hc4 : c % 4 = 0) {l : Locals} {sh : Shared} {ok : Nat → Prop}
    (h0 : l 0 = some (.ptr ⟨0, 0, .scalar .u32⟩)) (h1 : l 1 = some (.ptr ⟨1, 0, .scalar .f16⟩))
    (h2 : l 2 = some (.ptr ⟨2, 0, .scalar .bf16⟩)) (h3 : l 3 = some (u32 c)) (h4 : l 4 = some (u32 r))
    (hm : Mem C L R bits il tile I ok sh) :
    ∃ l' sh' win, Exec C ctx (pre R bits d il) l sh .normal l' sh' ∧ Loc d c r (scale I.S r) win l' ∧
      l' (d + 13) = some (u32 0) ∧ win < 2 ^ 64 ∧
      (∀ k < 4, win / 2 ^ ((3 - k) * bits) % 4096 = state R bits il I.Codes r (c + k)) ∧
      Mem C L R bits il tile I ok sh' := by
  -- the test
  have g1 : (eval C ctx l (.bin .ge .u32 0 (.local 3) (u32l 5120))).run sh = some (.bool false, sh) := by
    have := eval_bin_u32 C (ctx := ctx) (op := .ge) (site := 0) (eval_local' C h3 sh) (eval_u32lit C l sh 5120 (by decide))
      (binary_ge_u32 C c 5120 (by omega) (by decide))
    rwa [decide_eq_false (show ¬ 5120 ≤ c by omega)] at this
  have g2 : (eval C ctx l (.bin .ge .u32 0 (.local 4) (u32l R))).run sh = some (.bool false, sh) := by
    have := eval_bin_u32 C (ctx := ctx) (op := .ge) (site := 0) (eval_local' C h4 sh) (eval_u32lit C l sh R hR)
      (binary_ge_u32 C r R (by omega) hR)
    rwa [decide_eq_false (show ¬ R ≤ r by omega)] at this
  have gt := eval_or_false C g1 g2
  -- block, t, bw
  have e5 : (eval C ctx l (.bin .div .u32 0 (.local 3) (u32l 256))).run sh = some (u32 (c / 256), sh) :=
    eval_bin_u32 C (eval_local' C h3 sh) (eval_u32lit C _ _ 256 (by decide))
      (binary_div_u32 C c 256 (by omega) (by decide) (by decide))
  generalize hl₁ : setLocal l (d + 5) (u32 (c / 256)) = l₁
  have e6 : (eval C ctx l₁ (.bin .rem .u32 0 (.local 3) (u32l 256))).run sh = some (u32 (c % 256), sh) :=
    eval_bin_u32 C (eval_local' C (by rw [← hl₁, setLocal_other _ _ (by omega)]; exact h3) sh)
      (eval_u32lit C _ _ 256 (by decide)) (binary_rem_u32 C c 256 (by omega) (by decide) (by decide))
  generalize hl₂ : setLocal l₁ (d + 6) (u32 (c % 256)) = l₂
  have hbase := blockBase_bound R bits il hr (show c / 256 < 20 by omega)
  have hRb : 20 * R * (8 * bits) < 2 ^ 64 :=
    lt_of_le_of_lt (Nat.mul_le_mul (show 20 * R ≤ 20 * 2 ^ 32 by omega) (show 8 * bits ≤ 56 by omega)) (by norm_num)
  have e7 : (eval C ctx l₂ (.offset (.local 0) (VectorExpand.blockWords R bits il (d + 5)))).run sh =
      some (.ptr ⟨0, ((4 * blockBase R bits il r (c / 256) : Nat) : Int), .scalar .u32⟩, sh) :=
    eval_offset_u64' C (o := 0)
      (eval_local' C (by rw [← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_other _ _ (by omega)]; exact h0) sh)
      (eval_blockWords C R bits il (d + 5)
        (by rw [← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_same])
        (by rw [← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_other _ _ (by omega)]; exact h4)
        hc (by omega) hR hK.2) (by omega) _
      (by rw [show (Ty.scalar Scalar.u32).bytes = 4 from rfl]; omega)
  generalize hl₃ : setLocal l₂ (d + 7) (.ptr ⟨0, ((4 * blockBase R bits il r (c / 256) : Nat) : Int), .scalar .u32⟩) = l₃
  -- scale
  have h13 : l₃ 1 = some (.ptr ⟨1, 0, .scalar .f16⟩) := by
    rw [← hl₃, setLocal_other _ _ (by omega), ← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_other _ _ (by omega)]
    exact h1
  have h34 : l₃ 4 = some (u32 r) := by
    rw [← hl₃, setLocal_other _ _ (by omega), ← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_other _ _ (by omega)]
    exact h4
  have hp1 : (eval C ctx l₃ (.offset (.local 1) (.local 4))).run sh =
      some (.ptr ⟨1, ((2 * r : Nat) : Int), .scalar .f16⟩, sh) :=
    eval_offset_u32' C (o := 0) (eval_local' C h13 sh) (eval_local' C h34 sh) (by omega) _
      (by rw [show (Ty.scalar Scalar.f16).bytes = 2 from rfl]; omega)
  have hld := load_shared ctx .f16 sh 1 (2 * r) ⟨.device, 2 * R, I.as⟩ (by rw [hm.regions]; exact hS.r1) (by simp)
    hS.as (by show 2 * r % 2 = 0; omega) (by show 2 * r + 2 ≤ 2 * R; omega) (by simp [loadOffset])
  have e8 : (eval C ctx l₃ (.conv .f32 (.load (.scalar .f16) (.offset (.local 1) (.local 4))))).run sh =
      some (.f32 (scale I.S r), rdn ctx sh 1 (2 * r) 2) := by
    refine eval_conv C ((eval_load C ctx l₃ (.scalar .f16) _ _ sh sh hp1).trans hld) ?_
    rw [hm.scales]; rfl
  generalize hl₄ : setLocal l₃ (d + 8) (.f32 (scale I.S r)) = l₄
  have hm₁ := hm.rd hS ctx 1 (2 * r) 2 (by decide)
  generalize hsh₁ : rdn ctx sh 1 (2 * r) 2 = sh₁ at e8 hm₁
  -- pos, wi, off
  have h46 : l₄ (d + 6) = some (u32 (c % 256)) := by
    rw [← hl₄, setLocal_other _ _ (by omega), ← hl₃, setLocal_other _ _ (by omega), ← hl₂, setLocal_same]
  have hposl : (255 - (c % 256 + 3)) * bits < 2 ^ 32 := by
    have : (255 - (c % 256 + 3)) * bits ≤ 255 * 7 := Nat.mul_le_mul (by omega) hK.2
    omega
  have e9 : (eval C ctx l₄ (.bin .mul .u32 0 (.bin .sub .u32 0 (u32l 255) (.bin .add .u32 0 (.local (d + 6)) (u32l 3)))
      (u32l bits))).run sh₁ = some (u32 ((255 - (c % 256 + 3)) * bits), sh₁) :=
    eval_bin_u32 C (eval_bin_u32 C (eval_u32lit C _ _ 255 (by decide)) (eval_bin_u32 C (eval_local' C h46 sh₁)
      (eval_u32lit C _ _ 3 (by decide)) (binary_add_u32 C _ 3)) (binary_sub_u32 C 255 _ (by omega)))
      (eval_u32lit C _ _ bits (by omega)) (binary_mul_u32 C _ _)
  generalize hl₅ : setLocal l₄ (d + 9) (u32 ((255 - (c % 256 + 3)) * bits)) = l₅
  have h59 : l₅ (d + 9) = some (u32 ((255 - (c % 256 + 3)) * bits)) := by rw [← hl₅, setLocal_same]
  have e10 : (eval C ctx l₅ (.bin .shr .u32 0 (.local (d + 9)) (u32l 5))).run sh₁ =
      some (u32 ((255 - (c % 256 + 3)) * bits / 32), sh₁) := by
    have := eval_bin_u32 C (ctx := ctx) (op := .shr) (site := 0) (eval_local' C h59 sh₁)
      (eval_u32lit C _ _ 5 (by decide)) (binary_shr_u32 C _ 5 hposl (by decide))
    rwa [show (2 : Nat) ^ 5 = 32 by norm_num] at this
  generalize hl₆ : setLocal l₅ (d + 10) (u32 ((255 - (c % 256 + 3)) * bits / 32)) = l₆
  have e11 : (eval C ctx l₆ (.bin .bitAnd .u32 0 (.local (d + 9)) (u32l 31))).run sh₁ =
      some (u32 ((255 - (c % 256 + 3)) * bits % 32), sh₁) := by
    have h69 : l₆ (d + 9) = some (u32 ((255 - (c % 256 + 3)) * bits)) := by
      rw [← hl₆, setLocal_other _ _ (by omega)]; exact h59
    have := eval_bin_u32 C (ctx := ctx) (op := .bitAnd) (site := 0) (eval_local' C h69 sh₁)
      (eval_u32lit C _ _ 31 (by decide)) (binary_bitAnd_u32 C _ 31 hposl (by decide))
    have hand : (255 - (c % 256 + 3)) * bits &&& 31 = (255 - (c % 256 + 3)) * bits % 32 :=
      Nat.and_two_pow_sub_one_eq_mod _ 5
    rwa [hand] at this
  generalize hl₇ : setLocal l₆ (d + 11) (u32 ((255 - (c % 256 + 3)) * bits % 32)) = l₇
  -- the window
  have hwi : (255 - (c % 256 + 3)) * bits / 32 < 8 * bits := by
    have : (255 - (c % 256 + 3)) * bits ≤ 252 * bits := Nat.mul_le_mul_right _ (by omega)
    omega
  have e12 := eval_window C (ctx := ctx) bits d hK (l := l₇) (sh := sh₁) (base := blockBase R bits il r (c / 256))
    (wi := (255 - (c % 256 + 3)) * bits / 32) (off := (255 - (c % 256 + 3)) * bits % 32) (size := 640 * R * bits)
    (ac := I.ac) (Codes := I.Codes)
    (by rw [← hl₇, setLocal_other _ _ (by omega), ← hl₆, setLocal_other _ _ (by omega), ← hl₅,
          setLocal_other _ _ (by omega), ← hl₄, setLocal_other _ _ (by omega), ← hl₃, setLocal_same])
    (by rw [← hl₇, setLocal_other _ _ (by omega), ← hl₆, setLocal_same])
    (by rw [← hl₇, setLocal_same]) hwi (Nat.mod_lt _ (by decide))
    (by rw [hm₁.regions]; exact hS.r0) hS.ac
    (by have e : 20 * R * (8 * bits) * 4 = 640 * R * bits := by ring
        omega)
    hm₁.codes
  have hm₂ := (hm₁.rd hS ctx 0 (4 * (blockBase R bits il r (c / 256) + (255 - (c % 256 + 3)) * bits / 32)) 4
    (by decide)).rd hS ctx 0
    (4 * (blockBase R bits il r (c / 256) + ((255 - (c % 256 + 3)) * bits / 32 + 1) % (8 * bits))) 4 (by decide)
  generalize hW : (word32 I.Codes (blockBase R bits il r (c / 256) + (255 - (c % 256 + 3)) * bits / 32) +
      word32 I.Codes (blockBase R bits il r (c / 256) + ((255 - (c % 256 + 3)) * bits / 32 + 1) % (8 * bits)) * 2 ^ 32) /
      2 ^ ((255 - (c % 256 + 3)) * bits % 32) = W at e12
  have hWl : W < 2 ^ 64 := by
    rw [← hW]
    have hl1 := word32_lt I.Codes (blockBase R bits il r (c / 256) + (255 - (c % 256 + 3)) * bits / 32)
    have hl2 := word32_lt I.Codes (blockBase R bits il r (c / 256) +
      ((255 - (c % 256 + 3)) * bits / 32 + 1) % (8 * bits))
    exact lt_of_le_of_lt (Nat.div_le_self _ _) (by omega)
  have hwin : ∀ k < 4, W / 2 ^ ((3 - k) * bits) % 4096 = state R bits il I.Codes r (c + k) := by
    intro k hk
    rw [← hW, window_state bits hK I.Codes _ c k hc4 hk]
    unfold state
    rw [show (c + k) / 256 = c / 256 by omega]
  subst hl₇ hl₆ hl₅ hl₄ hl₃ hl₂ hl₁ hsh₁
  refine ⟨_, _, W,
    .ite gt (.nil _ _) (.set e5 (.set e6 (.set e7 (.set e8 (.set e9 (.set e10 (.set e11 (.set e12
      (.set (eval_u32lit C _ _ 0 (by decide)) (.nil _ _)))))))))),
    ⟨?_, ?_, ?_, ?_, ?_⟩, ?_, hWl, hwin, hm₂⟩
  · simp (disch := omega) only [setLocal_other, h2]
  · simp (disch := omega) only [setLocal_other, h3]
  · simp (disch := omega) only [setLocal_other, h4]
  · simp (disch := omega) only [setLocal_other, setLocal_same]
  · simp (disch := omega) only [setLocal_other, setLocal_same]
  · simp (disch := omega) only [setLocal_same]

end Pre

/-! ### The thread's coordinates -/

/-- The statements before `if (c >= C || r >= R) return;`. -/
def head : Option Nat → List CStmt
  | none => [.set 3 (.bin .mul .u32 0 (.component (.coord .threadPositionInGrid) (u32l 0)) (u32l 4)),
      .set 4 (.component (.coord .threadPositionInGrid) (u32l 1))]
  | some rt => [.set 3 (.bin .mul .u32 0 (.component (.coord .threadPositionInGrid) (u32l 0)) (u32l 4)),
      .set 4 (.component (.coord .threadPositionInGrid) (u32l 1))] ++ VectorExpand.tileBlock rt

def dOf (tile : Option Nat) : Nat := if tile.isSome then 3 else 0

theorem body_eq (R bits : Nat) (il : Bool) (tile : Option Nat) :
    VectorExpand.body R bits il tile =
      [.set 0 (.lit (.ptr ⟨0, 0, .scalar .u32⟩)), .set 1 (.lit (.ptr ⟨1, 0, .scalar .f16⟩)),
        .set 2 (.lit (.ptr ⟨2, 0, .scalar .bf16⟩)),
        .scope (head tile ++ (pre R bits (dOf tile) il ++ [loopStmt bits (dOf tile)]))] := by
  cases tile <;> rfl

section Head
variable (C : M1Max.Contract) {ctx : Ctx} {R : Nat}

theorem exec_head_none {T : Nat} (hL : Lane none R ctx T) {l : Locals} {sh : Shared} :
    ∃ l', Exec C ctx (head none) l sh .normal l' sh ∧ l' 3 = some (u32 (colOf none T)) ∧
      l' 4 = some (u32 (rowOf none T)) ∧ ∀ j, j < 3 → l' j = l j :=
  ⟨_, .set (eval_bin_u32 C (eval_coord0 C hL.tpig) (eval_u32lit C _ _ 4 (by decide)) (binary_mul_u32 C _ 4))
      (.set (eval_coord1 C hL.tpig) (.nil _ _)),
    by rw [setLocal_other _ _ (by decide), setLocal_same]; rfl, by rw [setLocal_same]; rfl,
    fun j hj => by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]⟩

theorem exec_head_some {rt T : Nat} (hrt : 0 < rt) (hrt32 : 10 * rt < 2 ^ 32) (hT32 : T < 2 ^ 32)
    (hL : Lane (some rt) R ctx T) {l : Locals} {sh : Shared} :
    ∃ l', Exec C ctx (head (some rt)) l sh .normal l' sh ∧ l' 3 = some (u32 (colOf (some rt) T)) ∧
      l' 4 = some (u32 (rowOf (some rt) T)) ∧ ∀ j, j < 3 → l' j = l j := by
  have hg : ctx.coord .threadgroupPositionInGrid = u32x3 (T / 128) 0 0 := hL.tgpig rfl
  have hm : T / 128 % (10 * rt) < 10 * rt := Nat.mod_lt _ (by omega)
  have hrt' : rt < 2 ^ 32 := by omega
  have e3 := eval_bin_u32 C (ctx := ctx) (l := l) (sh := sh) (op := .mul) (site := 0) (eval_coord0 C hL.tpig)
    (eval_u32lit C l sh 4 (by decide)) (binary_mul_u32 C (gridX (some rt) T) 4)
  generalize hl₁ : setLocal l 3 (u32 (gridX (some rt) T * 4)) = l₁
  have e4 := eval_coord1 C (ctx := ctx) (l := l₁) (sh := sh) hL.tpig
  generalize hl₂ : setLocal l₁ 4 (u32 (gridY (some rt) T)) = l₂
  have e5 := eval_coord0 C (ctx := ctx) (l := l₂) (sh := sh) hg
  generalize hl₃ : setLocal l₂ 5 (u32 (T / 128)) = l₃
  have h35 : l₃ 5 = some (u32 (T / 128)) := by rw [← hl₃, setLocal_same]
  have e6 := eval_bin_u32 C (ctx := ctx) (op := .div) (site := 0) (eval_local' C h35 sh)
    (eval_u32lit C l₃ sh (10 * rt) hrt32) (binary_div_u32 C (T / 128) (10 * rt) (by omega) hrt32 (by omega))
  generalize hl₄ : setLocal l₃ 6 (u32 (T / 128 / (10 * rt))) = l₄
  have h45 : l₄ 5 = some (u32 (T / 128)) := by rw [← hl₄, setLocal_other _ _ (by decide)]; exact h35
  have e7 := eval_bin_u32 C (ctx := ctx) (op := .rem) (site := 0) (eval_local' C h45 sh)
    (eval_u32lit C l₄ sh (10 * rt) hrt32) (binary_rem_u32 C (T / 128) (10 * rt) (by omega) hrt32 (by omega))
  generalize hl₅ : setLocal l₄ 7 (u32 (T / 128 % (10 * rt))) = l₅
  have h56 : l₅ 6 = some (u32 (T / 128 / (10 * rt))) := by
    rw [← hl₅, setLocal_other _ _ (by decide), ← hl₄, setLocal_same]
  have h57 : l₅ 7 = some (u32 (T / 128 % (10 * rt))) := by rw [← hl₅, setLocal_same]
  have e8 := eval_bin_u32 C (ctx := ctx) (op := .add) (site := 0)
    (eval_bin_u32 C (op := .mul) (site := 0) (eval_local' C h56 sh) (eval_u32lit C l₅ sh rt hrt')
      (binary_mul_u32 C (T / 128 / (10 * rt)) rt))
    (eval_bin_u32 C (op := .rem) (site := 0) (eval_local' C h57 sh) (eval_u32lit C l₅ sh rt hrt')
      (binary_rem_u32 C (T / 128 % (10 * rt)) rt (by omega) hrt' hrt))
    (binary_add_u32 C _ _)
  generalize hl₆ : setLocal l₅ 4 (u32 (T / 128 / (10 * rt) * rt + T / 128 % (10 * rt) % rt)) = l₆
  have h67 : l₆ 7 = some (u32 (T / 128 % (10 * rt))) := by rw [← hl₆, setLocal_other _ _ (by decide)]; exact h57
  have e9 := eval_bin_u32 C (ctx := ctx) (op := .add) (site := 0)
    (eval_bin_u32 C (op := .mul) (site := 0) (eval_bin_u32 C (op := .mul) (site := 0)
      (eval_bin_u32 C (op := .div) (site := 0) (eval_local' C h67 sh) (eval_u32lit C l₆ sh rt hrt')
        (binary_div_u32 C (T / 128 % (10 * rt)) rt (by omega) hrt' hrt))
      (eval_u32lit C l₆ sh 256 (by decide)) (binary_mul_u32 C _ 256)) (eval_u32lit C l₆ sh 2 (by decide))
      (binary_mul_u32 C _ 2))
    (eval_bin_u32 C (op := .mul) (site := 0) (eval_coord0 C hL.tpitg) (eval_u32lit C l₆ sh 4 (by decide))
      (binary_mul_u32 C (T % 128) 4))
    (binary_add_u32 C _ _)
  subst hl₆ hl₅ hl₄ hl₃ hl₂ hl₁
  refine ⟨_, .set e3 (.set e4 (.set e5 (.set e6 (.set e7 (.set e8 (.set e9 (.nil _ _))))))), ?_, ?_, ?_⟩
  · rw [setLocal_same]; rfl
  · rw [setLocal_other _ _ (by decide), setLocal_same]; rfl
  · intro j hj
    simp (disch := omega) only [setLocal_other]

end Head

/-! ### A whole thread -/

section Thread
variable (C : M1Max.Contract) {L : Launch} {R bits : Nat} {il : Bool} {tile : Option Nat} {I : In}

theorem thread_run (hS : Shape L R bits I) (hK : 0 < bits ∧ bits ≤ 7) (hR : 1280 * R < 2 ^ 32) (ht : TileOk R tile)
    {ctx : Ctx} {T : Nat} (hL : Lane tile R ctx T) {sh : Shared}
    (hm : Mem C L R bits il tile I (fun e => threadOf tile (e / 4) < T) sh) :
    ∃ t sh', (Ev fun m => (runThread C m ⟨ctx, fun _ => none, [.block (VectorExpand.body R bits il tile)], .running⟩).run
        sh = some (t, sh')) ∧
      Mem C L R bits il tile I (fun e => threadOf tile (e / 4) < T + 1) sh' ∧ t.status = .done := by
  have hT := hL.hT
  obtain ⟨hr, hc, hc4⟩ := rowOf_lt ht hT
  generalize hl₀ : setLocal (setLocal (setLocal (fun _ => none) 0 (.ptr ⟨0, 0, .scalar .u32⟩)) 1
    (.ptr ⟨1, 0, .scalar .f16⟩)) 2 (.ptr ⟨2, 0, .scalar .bf16⟩) = l₀
  have hx : ∃ l₁, Exec C ctx (head tile) l₀ sh .normal l₁ sh ∧ l₁ 3 = some (u32 (colOf tile T)) ∧
      l₁ 4 = some (u32 (rowOf tile T)) ∧ ∀ j, j < 3 → l₁ j = l₀ j := by
    cases tile with
    | none => exact exec_head_none C hL
    | some rt =>
      obtain ⟨hrt, n, hn⟩ := ht
      have hrR : rt ≤ R := Nat.le_of_dvd (by omega) ⟨n, hn⟩
      exact exec_head_some C hrt (by omega) (by omega) hL
  obtain ⟨l₁, x1, h3, h4, hf1⟩ := hx
  have h0 : l₁ 0 = some (.ptr ⟨0, 0, .scalar .u32⟩) := by rw [hf1 0 (by omega), ← hl₀]; rfl
  have h1 : l₁ 1 = some (.ptr ⟨1, 0, .scalar .f16⟩) := by rw [hf1 1 (by omega), ← hl₀]; rfl
  have h2 : l₁ 2 = some (.ptr ⟨2, 0, .scalar .bf16⟩) := by rw [hf1 2 (by omega), ← hl₀]; rfl
  obtain ⟨l₂, sh₂, win, x2, hloc, h13, hwin, hw, hm₂⟩ := exec_pre C (ctx := ctx) (tile := tile) (ok := Done tile T 0) hS hK
    (by omega) (dOf tile) hr hc hc4 h0 h1 h2 h3 h4
    (hm.mono (fun e _ h => by rcases h with h | h; exact h; exact absurd h.2 (Nat.not_lt_zero _)))
  obtain ⟨l₃, sh₃, x3, hm₃⟩ := exec_loop C (ctx := ctx) hS hK.2 (by omega) ht hT hL.thread hL.group hwin hw rfl ⟨hloc, h13, hm₂⟩
  have hx : Exec C ctx (VectorExpand.body R bits il tile) (fun _ => none) sh .normal l₃ sh₃ := by
    rw [body_eq]
    exact .set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _)
      (by rw [hl₀]; exact .scope (x1.append (x2.append x3)) (.inl rfl) (.nil _ _))))
  exact ⟨_, _, hx.reaches_done.ev_stop rfl, hm₃.mono (fun e _ h => by unfold Done; omega), rfl⟩

/-- A SIMD-group of consecutive threads `T0 …`. -/
theorem simd_run (hS : Shape L R bits I) (hK : 0 < bits ∧ bits ≤ 7) (hR : 1280 * R < 2 ^ 32) (ht : TileOk R tile)
    (ctxs : Fin 32 → Ctx) {T0 : Nat} (hL : ∀ i : Fin 32, Lane tile R (ctxs i) (T0 + i)) {sh : Shared}
    (hm : Mem C L R bits il tile I (fun e => threadOf tile (e / 4) < T0) sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m 1 (List.ofFn fun i =>
        (⟨ctxs i, fun _ => none, [.block (VectorExpand.body R bits il tile)], .running⟩ : Thread))).run sh =
          some (List.ofFn V, sh')) ∧
      Mem C L R bits il tile I (fun e => threadOf tile (e / 4) < T0 + 32) sh' ∧ ∀ i, (V i).status = .done := by
  obtain ⟨V, sh', hr, hI, hR'⟩ := runSimd_blocked_ev C 0
    (fun i => (⟨ctxs i, fun _ => none, [.block (VectorExpand.body R bits il tile)], .running⟩ : Thread))
    (fun idx sh => Mem C L R bits il tile I (fun e => threadOf tile (e / 4) < T0 + idx) sh)
    (fun _ t => t.status = .done) (fun i sh hI => by
      obtain ⟨t, sh', he, hm', hst⟩ := thread_run C hS hK hR ht (hL i) hI
      exact ⟨t, sh', he, by rw [← Nat.add_assoc]; exact hm', by rw [hst]; rfl, hst⟩) sh (by simpa using hm)
  exact ⟨V, sh', hr, hI, hR'⟩

/-- A threadgroup `G`: its four SIMD-groups. -/
theorem group_run (hS : Shape L R bits I) (hK : 0 < bits ∧ bits ≤ 7) (hR : 1280 * R < 2 ^ 32) (ht : TileOk R tile)
    (G : Nat) (ctxOf : Fin 4 → Fin 32 → Ctx) (hL : ∀ (s : Fin 4) (i : Fin 32), Lane tile R (ctxOf s i) (128 * G + 32 * s + i))
    {sh : Shared} (hm : Mem C L R bits il tile I (fun e => threadOf tile (e / 4) < 128 * G) sh) :
    ∃ sh', (Ev fun m => (runGroup C m 1 1 (List.ofFn fun s : Fin 4 => List.ofFn fun i =>
        (⟨ctxOf s i, fun _ => none, [.block (VectorExpand.body R bits il tile)], .running⟩ : Thread))).run sh =
          some ((), sh')) ∧
      Mem C L R bits il tile I (fun e => threadOf tile (e / 4) < 128 * G + 128) sh' := by
  obtain ⟨sh', hr, hI⟩ := runGroup_done_ev C 1 0
    (fun s i => (⟨ctxOf s i, fun _ => none, [.block (VectorExpand.body R bits il tile)], .running⟩ : Thread))
    (fun j sh => Mem C L R bits il tile I (fun e => threadOf tile (e / 4) < 128 * G + 32 * j) sh)
    (fun j sh hj => by
      obtain ⟨V, sh', hr, hm', hd⟩ := simd_run C hS hK hR ht (ctxOf j) (T0 := 128 * G + 32 * j) (fun i => hL j i) hj
      exact ⟨V, sh', hr, by rw [show 128 * G + 32 * (↑j + 1) = 128 * G + 32 * ↑j + 32 by ring]; exact hm', hd⟩)
    sh (by simpa using hm)
  exact ⟨sh', hr, by simpa using hI⟩

end Thread

/-! ## The launch's threads -/

theorem u32x3_eq {a b c a' b' c' : Nat} (h1 : a = a') (h2 : b = b') (h3 : c = c') : u32x3 a b c = u32x3 a' b' c' := by
  subst h1 h2 h3; rfl

section Launch
variable (C : M1Max.Contract) {R bits : Nat} {il : Bool} {I : In} {initial : Nat → ByteMemory.Bytes}

theorem tiles_none (hR0 : 0 < R) : (launch R bits il none I initial).Tiles 128 1 1 10 R 1 4 :=
  ⟨rfl, by show (1280, R, 1) = (10 * 128, R * 1, 1 * 1); simp, rfl, by omega⟩

theorem tiles_some {rt : Nat} (hR0 : 0 < R) : (launch R bits il (some rt) I initial).Tiles 128 1 1 (10 * R) 1 1 4 :=
  ⟨rfl, Prod.ext (by show 1280 * R = 10 * R * 128; ring) rfl, rfl, by omega⟩

theorem lane_none (hR0 : 0 < R) (fuse : Nat → Bool) {bx byy : Nat} (hx : bx < 10) (hy : byy < R) (s : Fin 4) (i : Fin 32) :
    Lane none R ((launch R bits il none I initial).ctxAt fuse bx byy 0 (32 * s + i))
      (128 * (bx + byy * 10 + 0 * 10 * R) + 32 * s + i) := by
  have hT := tiles_none (bits := bits) (il := il) (I := I) (initial := initial) hR0
  have hs := s.isLt; have hi := i.isLt
  refine ⟨by omega, by rw [hT.thread]; omega, by rw [hT.group_id]; omega, ?_, ?_, fun h => absurd h (by simp)⟩
  · rw [hT.threadPositionInGrid]
    exact u32x3_eq (by simp only [gridX]; omega) (by simp only [gridY]; omega) (by omega)
  · rw [hT.threadPositionInThreadgroup]
    exact u32x3_eq (by omega) (by omega) (by omega)

theorem lane_some {rt : Nat} (hR0 : 0 < R) (fuse : Nat → Bool) {bx : Nat} (hx : bx < 10 * R) (s : Fin 4) (i : Fin 32) :
    Lane (some rt) R ((launch R bits il (some rt) I initial).ctxAt fuse bx 0 0 (32 * s + i))
      (128 * (bx + 0 * (10 * R) + 0 * (10 * R) * 1) + 32 * s + i) := by
  have hT := tiles_some (bits := bits) (il := il) (I := I) (initial := initial) (rt := rt) hR0
  have hs := s.isLt; have hi := i.isLt
  refine ⟨by omega, by rw [hT.thread]; omega, by rw [hT.group_id]; omega, ?_, ?_, fun _ => ?_⟩
  · rw [hT.threadPositionInGrid]
    exact u32x3_eq (by simp only [gridX]; omega) (by simp only [gridY]; omega) (by omega)
  · rw [hT.threadPositionInThreadgroup]
    exact u32x3_eq (by omega) (by omega) (by omega)
  · rw [Launch.ctxAt_threadgroupPositionInGrid]
    exact u32x3_eq (by omega) rfl rfl

/-- The launch: every threadgroup in order, then every element written by its thread. -/
theorem launch_run {tile : Option Nat} (hS : Shape (launch R bits il tile I initial) R bits I) (hK : 0 < bits ∧ bits ≤ 7)
    (hR : 1280 * R < 2 ^ 32) (hR0 : 0 < R) (ht : TileOk R tile) (fuse : Nat → Bool) (garbage : Garbage) :
    ∃ sh, Mem C (launch R bits il tile I initial) R bits il tile I (fun e => threadOf tile (e / 4) < 1280 * R) sh ∧
      Ev fun m => runLaunch C fuse (launch R bits il tile I initial) garbage m 1 1 = some ⟨sh.bytes, sh.log⟩ := by
  have hb : (launch R bits il tile I initial).buffers = buffers (bufs R bits I) [10240 * R] 16 initial := rfl
  have h0 : Mem C (launch R bits il tile I initial) R bits il tile I (fun e => threadOf tile (e / 4) < 128 * 0)
      ((launch R bits il tile I initial).initial garbage) :=
    ⟨rfl, initial_input hb garbage 0 (by simp [bufs]), initial_input hb garbage 1 (by simp [bufs]), rfl,
      fun e _ h => absurd h (by omega), fun a ha => by simp [Launch.initial] at ha⟩
  have hreset : ∀ (g : Nat) (sh : Shared),
      { sh with bytes := (launch R bits il tile I initial).resetGroup garbage g sh.bytes } = sh :=
    fun g sh => by rw [Launch.resetGroup_none _ _ _ _ rfl]
  cases tile with
  | none =>
    obtain ⟨sh, hI, hr⟩ := (tiles_none hR0).launch_run_ev C fuse garbage 1 1
      (fun G sh => Mem C (launch R bits il none I initial) R bits il none I (fun e => threadOf none (e / 4) < 128 * G) sh) h0
      (fun bx byy bz hx hy hz sh hI => by
        obtain rfl : bz = 0 := by omega
        rw [hreset]
        obtain ⟨sh', hr, hm⟩ := group_run C hS hK hR ht _
          (fun s i => (launch R bits il none I initial).ctxAt fuse bx byy 0 (32 * s + i))
          (fun s i => lane_none hR0 fuse hx hy s i) hI
        exact ⟨sh', hr, by rw [Nat.mul_add, Nat.mul_one]; exact hm⟩)
    exact ⟨sh, by rw [show 1280 * R = 128 * (10 * R * 1) by ring]; exact hI, hr⟩
  | some rt =>
    obtain ⟨sh, hI, hr⟩ := (tiles_some (rt := rt) hR0).launch_run_ev C fuse garbage 1 1
      (fun G sh => Mem C (launch R bits il (some rt) I initial) R bits il (some rt) I
        (fun e => threadOf (some rt) (e / 4) < 128 * G) sh) h0
      (fun bx byy bz hx hy hz sh hI => by
        obtain rfl : bz = 0 := by omega
        obtain rfl : byy = 0 := by omega
        rw [hreset]
        obtain ⟨sh', hr, hm⟩ := group_run C hS hK hR ht _
          (fun s i => (launch R bits il (some rt) I initial).ctxAt fuse bx 0 0 (32 * s + i))
          (fun s i => lane_some hR0 fuse hx s i) hI
        exact ⟨sh', hr, by
          rw [show 128 * (bx + 0 * (10 * R) + 0 * (10 * R) * 1 + 1) = 128 * (bx + 0 * (10 * R) + 0 * (10 * R) * 1) + 128
            by ring]
          exact hm⟩)
    exact ⟨sh, by rw [show 1280 * R = 128 * (10 * R * 1 * 1) by ring]; exact hI, hr⟩

end Launch

end Metal.Kernels.VectorExpandProof

namespace Metal.Kernels.VectorExpand
open Metal Metal.Core Inference.Contracts.Mlx

variable (C : M1Max.Contract)

/-- **The GPU runs the vector-expand kernel as its source says**, for any `R` with `1280·R < 2^32`, code width
`bits` in 1 … 7, either code layout and no row tile or any row tile dividing `R`, given that the text compiles to
`core R bits il tile`. Under the GPU assumption, MLX's launch on any codes (4-aligned: read as `uint`) and scales
(2-aligned: read as `half`) writes to `out` `[R, 5120]` every element's `T(trellis_val_rcp(s) · scale)`. -/
theorem gpu_output_of (R bits : Nat) (il : Bool) (tile : Option Nat) (hK : 0 < bits ∧ bits ≤ 7) (hR0 : 0 < R)
    (hR : 1280 * R < 2 ^ 32) (ht : VectorExpandProof.TileOk R tile) (text : List Char)
    (hc : (frontend text).bind elaborate = some (core R bits il tile)) (G : Gpu C) (hmax : 128 ≤ G.maxThreads text)
    (Codes S : ByteMemory.Bytes) (ac as : Nat) (hac : 4 ∣ ac) (has : 2 ∣ as) :
    G.execute text (VectorExpandProof.grid tile R) (128, 1, 1)
      [⟨.device, 640 * R * bits, ac, Codes⟩, ⟨.device, 2 * R, as, S⟩] [10240 * R] =
      some [expected C R bits il Codes S] := by
  have h := gpu_owned C G (text := text) (grid := VectorExpandProof.grid tile R) (tg := (128, 1, 1))
    (inputs := [⟨.device, 640 * R * bits, ac, Codes⟩, ⟨.device, 2 * R, as, S⟩]) (sizes := [10240 * R])
    (fun _ => expected C R bits il Codes S) hc (by simpa using hmax) (fun initial garbage => by
      have hS := VectorExpandProof.launch_shape (R := R) (bits := bits) (il := il) (tile := tile)
        (I := ⟨Codes, S, ac, as⟩) (initial := initial) (Nat.mod_eq_zero_of_dvd hac) (Nat.mod_eq_zero_of_dvd has)
      obtain ⟨sh, hm, n, hn⟩ := VectorExpandProof.launch_run C hS hK hR hR0 ht (G.fusion text) garbage
      refine ⟨n, 1, 1, sh, VectorExpandProof.dev tile, VectorExpandProof.tgo, hn n le_rfl, hm.log, ?_⟩
      intro i hi b hb
      obtain rfl : i = 0 := by simp at hi; omega
      have hb' : b < 10240 * R := by simpa using hb
      show sh.bytes 2 b = expected C R bits il Codes S b
      have := hm.out (b / 2) (by omega) ((VectorExpandProof.quadOf_threadOf ht (by omega)).2)
      rw [expected, ite_eq_left hb', ← this, Metal.cells_getD _ _ _ _ (by omega), show 2 * (b / 2) + b % 2 = b by omega])
  rw [h]
  show some [fun b => if b < 10240 * R then expected C R bits il Codes S b else 0] = _
  congr 2
  funext b
  unfold expected
  split <;> simp_all


/-! ## The route's instances

The ANE MLP split's GPU share (ane-prefill-split.ts): `R` = 11264 (fraction .353) or 10752 (.382) channels; gate,
up and row-major down at 2, 3 and 4 bits on grid `[1280, R, 1]`, and the 3-bit block-interleaved down (`codes`
`[10, R, 48]`) with `ROW_TILE` 128 on grid `[1280·R, 1, 1]`; threadgroup `[128, 1, 1]`. `codes` is `640·R·bits`
bytes, `scales` `2·R`, `out` `10240·R`. -/

section Route
variable {Codes S : ByteMemory.Bytes} {ac as : Nat}

theorem gpu_output_11264_2 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 11264 2 0 0)) (hac : 4 ∣ ac) (has : 2 ∣ as) :
    G.execute (text 11264 2 0 0) (1280, 11264, 1) (128, 1, 1)
      [⟨.device, 14417920, ac, Codes⟩, ⟨.device, 22528, as, S⟩] [115343360] =
      some [expected C 11264 2 false Codes S] :=
  gpu_output_of C 11264 2 false none (by decide) (by decide) (by norm_num) trivial _ compile_11264_2 G hmax Codes S ac as
    hac has

theorem gpu_output_11264_3 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 11264 3 0 0)) (hac : 4 ∣ ac) (has : 2 ∣ as) :
    G.execute (text 11264 3 0 0) (1280, 11264, 1) (128, 1, 1)
      [⟨.device, 21626880, ac, Codes⟩, ⟨.device, 22528, as, S⟩] [115343360] =
      some [expected C 11264 3 false Codes S] :=
  gpu_output_of C 11264 3 false none (by decide) (by decide) (by norm_num) trivial _ compile_11264_3 G hmax Codes S ac as
    hac has

theorem gpu_output_11264_4 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 11264 4 0 0)) (hac : 4 ∣ ac) (has : 2 ∣ as) :
    G.execute (text 11264 4 0 0) (1280, 11264, 1) (128, 1, 1)
      [⟨.device, 28835840, ac, Codes⟩, ⟨.device, 22528, as, S⟩] [115343360] =
      some [expected C 11264 4 false Codes S] :=
  gpu_output_of C 11264 4 false none (by decide) (by decide) (by norm_num) trivial _ compile_11264_4 G hmax Codes S ac as
    hac has

theorem gpu_output_10752_2 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 10752 2 0 0)) (hac : 4 ∣ ac) (has : 2 ∣ as) :
    G.execute (text 10752 2 0 0) (1280, 10752, 1) (128, 1, 1)
      [⟨.device, 13762560, ac, Codes⟩, ⟨.device, 21504, as, S⟩] [110100480] =
      some [expected C 10752 2 false Codes S] :=
  gpu_output_of C 10752 2 false none (by decide) (by decide) (by norm_num) trivial _ compile_10752_2 G hmax Codes S ac as
    hac has

theorem gpu_output_10752_3 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 10752 3 0 0)) (hac : 4 ∣ ac) (has : 2 ∣ as) :
    G.execute (text 10752 3 0 0) (1280, 10752, 1) (128, 1, 1)
      [⟨.device, 20643840, ac, Codes⟩, ⟨.device, 21504, as, S⟩] [110100480] =
      some [expected C 10752 3 false Codes S] :=
  gpu_output_of C 10752 3 false none (by decide) (by decide) (by norm_num) trivial _ compile_10752_3 G hmax Codes S ac as
    hac has

theorem gpu_output_10752_4 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 10752 4 0 0)) (hac : 4 ∣ ac) (has : 2 ∣ as) :
    G.execute (text 10752 4 0 0) (1280, 10752, 1) (128, 1, 1)
      [⟨.device, 27525120, ac, Codes⟩, ⟨.device, 21504, as, S⟩] [110100480] =
      some [expected C 10752 4 false Codes S] :=
  gpu_output_of C 10752 4 false none (by decide) (by decide) (by norm_num) trivial _ compile_10752_4 G hmax Codes S ac as
    hac has

/-- The 3-bit block-interleaved down at `R` = 11264, row tile 128. -/
theorem gpu_output_11264_k3i (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 11264 3 2 128)) (hac : 4 ∣ ac)
    (has : 2 ∣ as) :
    G.execute (text 11264 3 2 128) (14417920, 1, 1) (128, 1, 1)
      [⟨.device, 21626880, ac, Codes⟩, ⟨.device, 22528, as, S⟩] [115343360] =
      some [expected C 11264 3 true Codes S] :=
  gpu_output_of C 11264 3 true (some 128) (by decide) (by decide) (by norm_num) ⟨by decide, 88, by norm_num⟩ _
    compile_11264_k3i G hmax Codes S ac as hac has

/-- The 3-bit block-interleaved down at `R` = 10752, row tile 128. -/
theorem gpu_output_10752_k3i (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 10752 3 2 128)) (hac : 4 ∣ ac)
    (has : 2 ∣ as) :
    G.execute (text 10752 3 2 128) (13762560, 1, 1) (128, 1, 1)
      [⟨.device, 20643840, ac, Codes⟩, ⟨.device, 21504, as, S⟩] [110100480] =
      some [expected C 10752 3 true Codes S] :=
  gpu_output_of C 10752 3 true (some 128) (by decide) (by decide) (by norm_num) ⟨by decide, 84, by norm_num⟩ _
    compile_10752_k3i G hmax Codes S ac as hac has

end Route


end Metal.Kernels.VectorExpand

import metal.Elab
import metal.Frontend
import metal.Assemble
import host.mlx.PrefillKernelSources
import metal.kernels.AneTrellisFill

namespace Metal.Kernels.AneTrellisFillK3i
open Metal Metal.Core

/-! # ane/fill.ts: `mlx_bun_ane_trellis_fill_k3i`

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
The body (3-bit block-interleaved codes):

```
const uint c = thread_position_in_grid.x * PER;
const uint r = thread_position_in_grid.y;
if (c >= (uint)C || r >= (uint)ROWS) return;
constexpr uint wpb = BT * BITS / 32;
const uint block = c / BT, t = c % BT;
const device uint* bw = codes + (ulong)(block / 2) * (ulong)R * 2 * wpb + (ulong)r * 2 * wpb + (block % 2) * wpb;
const float scale = float(scales[r]);
device half4* out = (device half4*)((device half*)dst + (ulong)OFFSET + (ulong)r * (uint)C + c);
#pragma clang loop unroll(full)
for (uint q = 0; q < PER / 4; q++) {
  const uint pos = (BT - 1 - (t + 4 * q + 3)) * BITS, wi = pos >> 5, off = pos & 31u;
  const ulong window = (ulong(bw[wi]) | (ulong(bw[wi + 1 == wpb ? 0 : wi + 1]) << 32)) >> off;
  half4 v;
  #pragma clang loop unroll(full)
  for (uint i = 0; i < 4u; i++) v[i] = half(trellis_val_rcp(uint(window >> ((3 - i) * BITS)) & ((1u << L) - 1)) * scale);
  out[q] = v;
}
if (c == 0u && r == 0u) done[0] = 1;
```
Launch (fill.ts:57-66, 77-82, `trellisFillHalfK3Interleaved`): inputs `codes` uint32 (3-bit
block-interleaved words `[C/512, R, 48]`), `scales` float16 and `dst` float16 (the ANE program's
zero-copy input wrap, written through the cast), output `done` int32 `[1]`; no template dtypes;
template ints R, ROWS, C, BT, BITS, L, OFFSET, PER. The route's instances are the ANE MLP split's
down-weight fill for the 40 layers with interleaved 3-bit down codes (ane-prefill-split.ts:114,
`fillDown`) at R = 17408, C = 5120, BT = 256, BITS = 3, L = 12, OFFSET = 0, PER = 16, ROWS the ANE's
channels (`aneChannels(17408, f)`: 6144 at f = .353, 6656 at .382). `v` (declared without
initializer) is a one-element thread array. The core depends on ROWS: `core rows`. -/

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

/-- `bw`, block in slot 6, `wpb` = 24 words a block: block pairs of all R rows, then the row. -/
def blockWords : CExpr :=
  .offset
    (.offset (.offset (.local 0) (u64 .mul (u64 .mul (u64 .mul (toU64 (u32 .div (.local 6) (u32l 2))) (u64l 17408)) (u64l 2)) (u64l 24)))
      (u64 .mul (u64 .mul (toU64 (.local 5)) (u64l 2)) (u64l 24)))
    (u32 .mul (u32 .rem (.local 6) (u32l 2)) (u32l 24))

/-- `window` of quad `q` (slot 11): `bw[wi]` and the block's next word (`wi` in slot 13, `off` in 14). -/
def windowExpr (bits : Nat) : CExpr :=
  u64 .shr
    (u64 .bitOr (toU64 (.load (.scalar .u32) (.offset (.local 8) (.local 13))))
      (u64 .shl
        (toU64 (.load (.scalar .u32) (.offset (.local 8)
          (.cond (u32 .eq (u32 .add (.local 13) (u32l 1)) (u32l (8 * bits))) (u32l 0) (u32 .add (.local 13) (u32l 1))))))
        (u64l 32)))
    (toU64 (.local 14))

/-- `v[i] = half(trellis_val_rcp(state) * scale)` for weight `i` (slot 17), `trellis_val_rcp` at 18. -/
def weight (bits : Nat) : List CStmt :=
  [.set 18 (u32 .bitAnd
     (.conv .u32 (u64 .shr (.local 15) (toU64 (u32 .mul (u32 .sub (u32l 3) (.local 17)) (u32l bits)))))
     (u32l 4095)),
   valRcp 18,
   .store (.scalar .f16) (.offset (.ptrCast (.scalar .f16) (.local 16)) (.local 17))
     (.conv .f16 (.bin .mul .f32 0 (.local 19) (.local 9)))]

/-- Quad `q` (slot 11): pos, wi, off, window, the four weights into `v`, `out[q] = v`. -/
def quad (bits : Nat) : List CStmt :=
  [.set 12 (u32 .mul (u32 .sub (u32l 255) (u32 .add (u32 .add (.local 7) (u32 .mul (u32l 4) (.local 11))) (u32l 3)))
     (u32l bits)),
   .set 13 (u32 .shr (.local 12) (u32l 5)),
   .set 14 (u32 .bitAnd (.local 12) (u32l 31)),
   .set 15 (windowExpr bits),
   .array 16 false 0 (.vec .f16 4),
   .set 17 (u32l 0),
   .loop (u32 .lt (.local 17) (u32l 4)) [.set 17 (u32 .add (.local 17) (u32l 1))] (weight bits),
   .store (.vec .f16 4) (.offset (.local 10) (.local 11)) (.load (.vec .f16 4) (.local 16))]

/-- Slots: 0 codes, 1 scales, 2 dst, 3 done, 4 c, 5 r, 6 block, 7 t, 8 bw, 9 scale, 10 out, 11 q,
12 pos, 13 wi, 14 off, 15 window, 16 v (thread array 0), 17 i, 18 … 29 `trellis_val_rcp`'s (`valRcp`:
18 its s, 19 its result). -/
def body (rows : Nat) : List CStmt :=
  let bits := 3
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .u32⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .f16⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .f16⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .i32⟩)),
   .scope
     [.set 4 (u32 .mul (.component (.coord .threadPositionInGrid) (u32l 0)) (u32l 16)),
      .set 5 (.component (.coord .threadPositionInGrid) (u32l 1)),
      .ite (.or (u32 .ge (.local 4) (u32l 5120)) (u32 .ge (.local 5) (u32l rows))) [.leave] [],
      .set 6 (u32 .div (.local 4) (u32l 256)),
      .set 7 (u32 .rem (.local 4) (u32l 256)),
      .set 8 blockWords,
      .set 9 (.conv .f32 (.load (.scalar .f16) (.offset (.local 1) (.local 5)))),
      .set 10 (.ptrCast (.vec .f16 4)
        (.offset (.offset (.offset (.local 2) (u64l 0)) (u64 .mul (toU64 (.local 5)) (u64l 5120))) (.local 4))),
      .set 11 (u32l 0),
      .loop (u32 .lt (.local 11) (u32l 4)) [.set 11 (u32 .add (.local 11) (u32l 1))] (quad bits),
      .ite (.and (u32 .eq (.local 4) (u32l 0)) (u32 .eq (.local 5) (u32l 0)))
        [.store (.scalar .i32) (.offset (.local 3) (i32l 0)) (i32l 1)] []]]

/-- The kernel: thread array `v` (one `half4`). -/
def core (rows : Nat) : Kernel := ⟨4, [], [(.vec .f16 4, 1)], body rows⟩

section Texts
open Host.Mlx
/-! ## The texts MLX compiles

`codes` `uint32 [10, 17408, 48]` (block-interleaved words), `scales` `float16 [17408]`, `dst` `float16
[ROWS, 5120]`; any shapes of at least 8 elements give the same text. -/

def inputs (rows : Nat) : List Assemble.Input :=
  [⟨chars!"codes", .uint32, [10, 17408, 48]⟩, ⟨chars!"scales", .float16, [17408]⟩,
    ⟨chars!"dst", .float16, [rows, 5120]⟩]

def args (rows : Nat) : List Assemble.TemplateArg :=
  [.int chars!"R" 17408, .int chars!"ROWS" rows, .int chars!"C" 5120, .int chars!"BT" 256, .int chars!"BITS" 3,
    .int chars!"L" 12, .int chars!"OFFSET" 0, .int chars!"PER" 16]

def assembled (rows : Nat) : Option (List Char) :=
  Assemble.assemble (PrefillSources.name .aneTrellisFillK3i) (inputs rows) [chars!"done"] [.int32]
    (PrefillSources.source .aneTrellisFillK3i) (PrefillSources.header .aneTrellisFillK3i) (args rows) false

def text (rows : Nat) : List Char := (assembled rows).getD []

/-- Every route instance assembles. -/
theorem assembled_route : (assembled 6144).isSome ∧ (assembled 6656).isSome := by
  decide +kernel

kernel_rfl compile_6144 : (frontend (text 6144)).bind elaborate = some (core 6144)
kernel_rfl compile_6656 : (frontend (text 6656)).bind elaborate = some (core 6656)

end Texts
end Metal.Kernels.AneTrellisFillK3i

set_option linter.constructorNameAsVariable false

/-! ## The proof: the fill kernels' proof (AneTrellisFill.lean) with the interleaved code block address -/

namespace Metal.Kernels.AneFill
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

theorem core_k3i (rows : Nat) : AneTrellisFillK3i.core rows = coreWith rows 3 16 AneTrellisFillK3i.blockWords := rfl

/-- 3-bit block-interleaved codes `[C/512, R, 48]`: row `r`'s block `blk` from word
`(blk/2)·R·2·24 + r·2·24 + (blk%2)·24`. -/
def k3i (r blk : Nat) : Nat := blk / 2 * 17408 * 2 * 24 + r * 2 * 24 + blk % 2 * 24

variable (C : M1Max.Contract)

/-- `bw = codes + (ulong)(block/2)·R·2·wpb + (ulong)r·2·wpb + (block%2)·wpb`. -/
theorem bw_k3i : BwSpec C AneTrellisFillK3i.blockWords k3i := by
  intro ctx l sh y blk h0 h5 h6 hy hblk
  have a1 : (eval C ctx l (.bin .mul .u64 0 (.bin .mul .u64 0 (.bin .mul .u64 0
      (.conv .u64 (.bin .div .u32 0 (.local 6) (.lit (.int .u32 2)))) (.lit (.int .u64 17408))) (.lit (.int .u64 2)))
      (.lit (.int .u64 24)))).run sh = some (u64 (blk / 2 * 17408 * 2 * 24), sh) :=
    eval_int C (by decide) (eval_int C (by decide) (eval_int C (by decide)
      (eval_conv C (t := .u64) (eval_bin_u32 C (eval_local' C h6 sh) (eval_u32lit C _ _ 2 (by decide))
        (binary_div_u32 C blk 2 (by omega) (by decide) (by decide))) (convert_u64_u32 C _ (by omega)))
      (show (eval C ctx l (.lit (.int .u64 17408))).run sh = some (u64 17408, sh) from rfl) (binary_mul_u64 C _ 17408))
      (show (eval C ctx l (.lit (.int .u64 2))).run sh = some (u64 2, sh) from rfl) (binary_mul_u64 C _ 2))
      (show (eval C ctx l (.lit (.int .u64 24))).run sh = some (u64 24, sh) from rfl) (binary_mul_u64 C _ 24)
  have a2 := eval_offset_u64 C (o := 0) (eval_local' C h0 sh) a1 (by omega)
  have a3 : (eval C ctx l (.bin .mul .u64 0 (.bin .mul .u64 0 (.conv .u64 (.local 5)) (.lit (.int .u64 2)))
      (.lit (.int .u64 24)))).run sh = some (u64 (y * 2 * 24), sh) :=
    eval_int C (by decide) (eval_int C (by decide)
      (eval_conv C (t := .u64) (eval_local' C h5 sh) (convert_u64_u32 C y (by omega)))
      (show (eval C ctx l (.lit (.int .u64 2))).run sh = some (u64 2, sh) from rfl) (binary_mul_u64 C y 2))
      (show (eval C ctx l (.lit (.int .u64 24))).run sh = some (u64 24, sh) from rfl) (binary_mul_u64 C _ 24)
  have a4 := eval_offset_u64 C a2 a3 (by omega)
  have a5 : (eval C ctx l (.bin .mul .u32 0 (.bin .rem .u32 0 (.local 6) (.lit (.int .u32 2))) (.lit (.int .u32 24)))).run sh =
      some (u32 (blk % 2 * 24), sh) :=
    eval_bin_u32 C (eval_bin_u32 C (eval_local' C h6 sh) (eval_u32lit C _ _ 2 (by decide))
      (binary_rem_u32 C blk 2 (by omega) (by decide) (by decide))) (eval_u32lit C _ _ 24 (by decide))
      (binary_mul_u32 C _ 24)
  have a6 := eval_offset_u32 C a4 a5 (by omega)
  rw [show 0 + blk / 2 * 17408 * 2 * 24 * (Ty.scalar .u32).bytes + y * 2 * 24 * (Ty.scalar .u32).bytes +
    blk % 2 * 24 * (Ty.scalar .u32).bytes = 4 * k3i y blk by
      show 0 + blk / 2 * 17408 * 2 * 24 * 4 + y * 2 * 24 * 4 + blk % 2 * 24 * 4 = _; unfold k3i; omega] at a6
  exact a6

theorem k3i_bound : ∀ y < 17408, ∀ blk < 20, k3i y blk + 8 * 3 ≤ 17408 * 160 * 3 := by
  intro y hy blk hb; unfold k3i; omega

/-- **The GPU runs `mlx_bun_ane_trellis_fill_k3i` as its source says**, for any `rows ≤ R`, given that the text
compiles to `core rows`: as `mlx_bun_ane_trellis_fill` at 3 bits and 16 weights a thread, the codes 3-bit
block-interleaved (`uint32 [10, 17408, 48]`). -/
theorem gpu_output_k3i (rows : Nat) (hrows : 0 < rows ∧ rows ≤ 17408) (text : List Char)
    (hc : (frontend text).bind elaborate = some (AneTrellisFillK3i.core rows)) (G : Gpu C)
    (hmax : 128 ≤ G.maxThreads text) (Codes S D : ByteMemory.Bytes) (ac as ad nd : Nat) (hac : 4 ∣ ac) (has : 2 ∣ as)
    (had : 8 ∣ ad) (hnd : rows * 5120 ≤ nd) :
    ∃ res B, G.executeAll text (320, rows, 1) (128, 1, 1)
        [⟨.device, 33423360, ac, Codes⟩, ⟨.device, 34816, as, S⟩, ⟨.device, nd * 2, ad, D⟩] [4] = some res ∧
      res.length = 4 ∧ res[2]? = some B ∧ (∀ b, b < nd * 2 → B b = (fillStored C 3 rows k3i Codes S b).getD (D b)) ∧
      res[3]? = some doneOut :=
  gpu_output_gen C rows 3 16 _ k3i (.inr (.inl rfl)) (.inr rfl) hrows (bw_k3i C) k3i_bound text
    (by rw [← core_k3i]; exact hc) G hmax Codes S D ac as ad nd hac has had hnd

end Metal.Kernels.AneFill

namespace Metal.Kernels.AneTrellisFillK3i
open Metal Inference.Contracts.Mlx Metal.Kernels.AneFill

/-! ### The route's instances

The ANE MLP split's down-weight fill for the layers with interleaved 3-bit down codes (ane-prefill-split.ts:114):
`ROWS` 6144 (fraction .353) or 6656 (.382), grid `[320, ROWS, 1]`; `dst` is the program's weight surface (`nd ≥
ROWS·5120` halves). -/

variable (C : M1Max.Contract) {Codes S D : ByteMemory.Bytes} {ac as ad nd : Nat}

theorem gpu_output_6144 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 6144)) (hac : 4 ∣ ac) (has : 2 ∣ as)
    (had : 8 ∣ ad) (hnd : 6144 * 5120 ≤ nd) :
    ∃ res B, G.executeAll (text 6144) (320, 6144, 1) (128, 1, 1)
        [⟨.device, 33423360, ac, Codes⟩, ⟨.device, 34816, as, S⟩, ⟨.device, nd * 2, ad, D⟩] [4] = some res ∧
      res.length = 4 ∧ res[2]? = some B ∧ (∀ b, b < nd * 2 → B b = (fillStored C 3 6144 k3i Codes S b).getD (D b)) ∧
      res[3]? = some doneOut :=
  gpu_output_k3i C 6144 ⟨by decide, by decide⟩ _ compile_6144 G hmax Codes S D ac as ad nd hac has had hnd

theorem gpu_output_6656 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 6656)) (hac : 4 ∣ ac) (has : 2 ∣ as)
    (had : 8 ∣ ad) (hnd : 6656 * 5120 ≤ nd) :
    ∃ res B, G.executeAll (text 6656) (320, 6656, 1) (128, 1, 1)
        [⟨.device, 33423360, ac, Codes⟩, ⟨.device, 34816, as, S⟩, ⟨.device, nd * 2, ad, D⟩] [4] = some res ∧
      res.length = 4 ∧ res[2]? = some B ∧ (∀ b, b < nd * 2 → B b = (fillStored C 3 6656 k3i Codes S b).getD (D b)) ∧
      res[3]? = some doneOut :=
  gpu_output_k3i C 6656 ⟨by decide, by decide⟩ _ compile_6656 G hmax Codes S D ac as ad nd hac has had hnd

end Metal.Kernels.AneTrellisFillK3i


import metal.Elab
import metal.Frontend
import metal.Assemble
import host.mlx.PrefillKernelSources
import metal.kernels.GateUp

namespace Metal.Kernels.AneTrellisFill
open Metal Metal.Core

/-! # ane/fill.ts: `mlx_bun_ane_trellis_fill`

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
The body (row-major codes):

```
const uint c = thread_position_in_grid.x * PER;
const uint r = thread_position_in_grid.y;
if (c >= (uint)C || r >= (uint)ROWS) return;
constexpr uint wpb = BT * BITS / 32;
const uint block = c / BT, t = c % BT;
const device uint* bw = codes + (ulong)r * (C / BT) * wpb + block * wpb;
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
Launch (fill.ts:57-74, `trellisFillHalf`): inputs `codes` uint32 (row-major words), `scales` float16
and `dst` float16 (the ANE program's zero-copy input wrap, written through the cast), output `done`
int32 `[1]`; no template dtypes; template ints R, ROWS, C, BT, BITS, L, OFFSET, PER (8 at BITS = 4,
else 16). The route's instances are the ANE MLP split's weight fills (ane-prefill-split.ts:114-116:
`fillDown` for row-major down codes, and gate and up) at R = 17408, C = 5120, BT = 256, L = 12,
OFFSET = 0, ROWS the ANE's channels (`aneChannels(17408, f)`: 6144 at f = .353, 6656 at .382),
BITS 2, 3, 4. `v` (declared without initializer) is a one-element thread array. The core depends on
ROWS, BITS and PER: `core rows bits per`. -/

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

/-- `bw`, block in slot 6, `wpb` = 8·bits words a block. -/
def blockWords (bits : Nat) : CExpr :=
  .offset (.offset (.local 0) (u64 .mul (u64 .mul (toU64 (.local 5)) (u64l 20)) (u64l (8 * bits))))
    (u32 .mul (.local 6) (u32l (8 * bits)))

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
def body (rows bits per : Nat) : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .u32⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .f16⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .f16⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .i32⟩)),
   .scope
     [.set 4 (u32 .mul (.component (.coord .threadPositionInGrid) (u32l 0)) (u32l per)),
      .set 5 (.component (.coord .threadPositionInGrid) (u32l 1)),
      .ite (.or (u32 .ge (.local 4) (u32l 5120)) (u32 .ge (.local 5) (u32l rows))) [.leave] [],
      .set 6 (u32 .div (.local 4) (u32l 256)),
      .set 7 (u32 .rem (.local 4) (u32l 256)),
      .set 8 (blockWords bits),
      .set 9 (.conv .f32 (.load (.scalar .f16) (.offset (.local 1) (.local 5)))),
      .set 10 (.ptrCast (.vec .f16 4)
        (.offset (.offset (.offset (.local 2) (u64l 0)) (u64 .mul (toU64 (.local 5)) (u64l 5120))) (.local 4))),
      .set 11 (u32l 0),
      .loop (u32 .lt (.local 11) (u32l (per / 4))) [.set 11 (u32 .add (.local 11) (u32l 1))] (quad bits),
      .ite (.and (u32 .eq (.local 4) (u32l 0)) (u32 .eq (.local 5) (u32l 0)))
        [.store (.scalar .i32) (.offset (.local 3) (i32l 0)) (i32l 1)] []]]

/-- The kernel: thread array `v` (one `half4`). -/
def core (rows bits per : Nat) : Kernel := ⟨4, [], [(.vec .f16 4, 1)], body rows bits per⟩

section Texts
open Host.Mlx
/-! ## The texts MLX compiles

`codes` `uint32 [17408, 160·BITS]` (row-major words), `scales` `float16 [17408]`, `dst` `float16
[ROWS, 5120]`; any shapes of at least 8 elements give the same text. -/

def inputs (rows bits : Nat) : List Assemble.Input :=
  [⟨chars!"codes", .uint32, [17408, 160 * bits]⟩, ⟨chars!"scales", .float16, [17408]⟩,
    ⟨chars!"dst", .float16, [rows, 5120]⟩]

def args (rows bits per : Nat) : List Assemble.TemplateArg :=
  [.int chars!"R" 17408, .int chars!"ROWS" rows, .int chars!"C" 5120, .int chars!"BT" 256, .int chars!"BITS" bits,
    .int chars!"L" 12, .int chars!"OFFSET" 0, .int chars!"PER" per]

def assembled (rows bits per : Nat) : Option (List Char) :=
  Assemble.assemble (PrefillSources.name .aneTrellisFill) (inputs rows bits) [chars!"done"] [.int32]
    (PrefillSources.source .aneTrellisFill) (PrefillSources.header .aneTrellisFill) (args rows bits per) false

def text (rows bits per : Nat) : List Char := (assembled rows bits per).getD []

/-- Every route instance assembles. -/
theorem assembled_route :
    (assembled 6144 2 16).isSome ∧ (assembled 6144 3 16).isSome ∧ (assembled 6144 4 8).isSome ∧
    (assembled 6656 2 16).isSome ∧ (assembled 6656 3 16).isSome ∧ (assembled 6656 4 8).isSome := by
  decide +kernel

kernel_rfl compile_6144_2 : (frontend (text 6144 2 16)).bind elaborate = some (core 6144 2 16)
kernel_rfl compile_6144_3 : (frontend (text 6144 3 16)).bind elaborate = some (core 6144 3 16)
kernel_rfl compile_6144_4 : (frontend (text 6144 4 8)).bind elaborate = some (core 6144 4 8)
kernel_rfl compile_6656_2 : (frontend (text 6656 2 16)).bind elaborate = some (core 6656 2 16)
kernel_rfl compile_6656_3 : (frontend (text 6656 3 16)).bind elaborate = some (core 6656 3 16)
kernel_rfl compile_6656_4 : (frontend (text 6656 4 8)).bind elaborate = some (core 6656 4 8)

end Texts
end Metal.Kernels.AneTrellisFill

set_option linter.constructorNameAsVariable false

/-! ## The fill kernels' proof -/

namespace Metal.Kernels.AneFill
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

/-! ### The body, with the code block's address as a parameter

`mlx_bun_ane_trellis_fill` and `_k3i` differ only in `bw` (slot 8). -/

/-- Slots 4 … 7: `c`, `r`, the bounds check, `block`, `t`. -/
def pre (rows per : Nat) : List CStmt :=
  [.set 4 (.bin .mul .u32 0 (.component (.coord .threadPositionInGrid) (.lit (.int .u32 0))) (.lit (.int .u32 per))),
   .set 5 (.component (.coord .threadPositionInGrid) (.lit (.int .u32 1))),
   .ite (.or (.bin .ge .u32 0 (.local 4) (.lit (.int .u32 5120))) (.bin .ge .u32 0 (.local 5) (.lit (.int .u32 rows))))
     [.leave] [],
   .set 6 (.bin .div .u32 0 (.local 4) (.lit (.int .u32 256))),
   .set 7 (.bin .rem .u32 0 (.local 4) (.lit (.int .u32 256)))]

/-- `scale` (slot 9), `out` (10), the quads (`q` in 11), `done`. -/
def post (bits per : Nat) : List CStmt :=
  [.set 9 (.conv .f32 (.load (.scalar .f16) (.offset (.local 1) (.local 5)))),
   .set 10 (.ptrCast (.vec .f16 4) (.offset (.offset (.offset (.local 2) (.lit (.int .u64 0)))
     (.bin .mul .u64 0 (.conv .u64 (.local 5)) (.lit (.int .u64 5120)))) (.local 4))),
   .set 11 (.lit (.int .u32 0)),
   .loop (.bin .lt .u32 0 (.local 11) (.lit (.int .u32 (per / 4))))
     [.set 11 (.bin .add .u32 0 (.local 11) (.lit (.int .u32 1)))] (AneTrellisFill.quad bits),
   .ite (.and (.bin .eq .u32 0 (.local 4) (.lit (.int .u32 0))) (.bin .eq .u32 0 (.local 5) (.lit (.int .u32 0))))
     [.store (.scalar .i32) (.offset (.local 3) (.lit (.int .i32 0))) (.lit (.int .i32 1))] []]

def bodyWith (rows bits per : Nat) (bw : CExpr) : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .u32⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .f16⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .f16⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .i32⟩)),
   .scope (pre rows per ++ .set 8 bw :: post bits per)]

def coreWith (rows bits per : Nat) (bw : CExpr) : Kernel := ⟨4, [], [(.vec .f16 4, 1)], bodyWith rows bits per bw⟩

theorem core_eq (rows bits per : Nat) :
    AneTrellisFill.core rows bits per = coreWith rows bits per (AneTrellisFill.blockWords bits) := rfl


/-! ### Expected outputs -/

section Spec
variable (C : M1Max.Contract)

/-- `trellis_refined_y(y)`: `yf = (float)y`; `q = yf · r` with `r = 1.0f / 147.800537109375f` (folded to the word
`0x3BDDB447`); `e = fma(-q, 147.800537109375f, yf)`; the result `fma(e, r, q)`. -/
def refinedY (y : Int) : Float32 :=
  let yf := Val.ofF32Bits (exactF32 y)
  let r := Val.ofF32Bits 0x3BDDB447
  let q := C.fmul yf r
  let e := C.fma (f32Neg q) (Val.ofF32Bits 0x4313CCF0) yf
  C.fma e r q

/-- `trellis_val_rcp(s) = trellis_refined_y(trellis_y(s))`. -/
def valRcp (s : Nat) : Float32 := refinedY C (trellisYv s)

/-- The weight of row `r`, column `c`: `half(trellis_val_rcp(state) * scale)`, the column's 12-bit state in its
block of `K`-bit codes (`base r (c / 256)` the block's first word), the row's half scale. -/
def weight (K : Nat) (base : Nat → Nat → Nat) (Codes S : ByteMemory.Bytes) (r c : Nat) : Float16.Value :=
  C.narrowHalf (C.fmul (valRcp C (trellisCode K Codes (base r (c / 256)) (c % 256))) (scale S r))

/-- `dst`'s element `e` after the fill: the weight of row `e / 5120`, column `e % 5120`. -/
def elem (K : Nat) (base : Nat → Nat → Nat) (Codes S : ByteMemory.Bytes) (e : Nat) : Float16.Value :=
  weight C K base Codes S (e / 5120) (e % 5120)

end Spec

/-- `done` (int32 [1]): 1. -/
def doneOut (b : Nat) : BitVec 8 := (wordBytes 4 1).getD b 0

/-- Row-major codes: row `r`'s block `blk` from word `(20·r + blk)·8K` (`codes + r·(C/BT)·wpb + block·wpb`). -/
def rowMajor (K r blk : Nat) : Nat := (20 * r + blk) * (8 * K)

/-! ### The launch -/

/-- The inputs: codes, scales, `dst` (`nd` halves), their base alignments. -/
structure In where
  Codes : ByteMemory.Bytes
  S : ByteMemory.Bytes
  D : ByteMemory.Bytes
  ac : Nat
  as : Nat
  ad : Nat
  nd : Nat

def bufs (bits : Nat) (I : In) : List Buffer :=
  [⟨.device, GateUp.codesBytes bits, I.ac, I.Codes⟩, ⟨.device, 34816, I.as, I.S⟩, ⟨.device, I.nd * 2, I.ad, I.D⟩]

/-- MLX's launch (fill.ts `launch`): grid `[5120 / PER, rows, 1]`, threadgroup `[128, 1, 1]`, `done` int32 [1]. -/
def launch (rows bits per : Nat) (bw : CExpr) (I : In) (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨coreWith rows bits per bw, (5120 / per, rows, 1), (128, 1, 1), buffers (bufs bits I) [4] 16 initial⟩

/-- The regions as the kernel uses them. -/
structure Shape (L : Launch) (bits : Nat) (I : In) : Prop where
  r0 : L.regions 0 = some ⟨.device, GateUp.codesBytes bits, I.ac⟩
  r1 : L.regions 1 = some ⟨.device, 34816, I.as⟩
  r2 : L.regions 2 = some ⟨.device, I.nd * 2, I.ad⟩
  r3 : L.regions 3 = some ⟨.device, 4, 16⟩
  rt : ∀ th, L.regions (4 + th) = some ⟨.thread, 8, 8⟩
  ac : I.ac % 4 = 0
  as : I.as % 2 = 0
  ad : I.ad % 8 = 0

theorem launch_shape {rows bits per : Nat} {bw : CExpr} {I : In} {initial : Nat → ByteMemory.Bytes}
    (hac : I.ac % 4 = 0) (has : I.as % 2 = 0) (had : I.ad % 8 = 0) :
    Shape (launch rows bits per bw I initial) bits I := by
  have hb : (launch rows bits per bw I initial).buffers = buffers (bufs bits I) [4] 16 initial := rfl
  refine ⟨regions_input hb 0 (by simp [bufs]), regions_input hb 1 (by simp [bufs]),
    regions_input hb 2 (by simp [bufs]), regions_output hb 0 (by simp), fun th => ?_, hac, has, had⟩
  have := Launch.regions_threadArray (launch rows bits per bw I initial) th 0 (.vec .f16 4) 1 rfl
  simpa [Ty.bytes, Scalar.bytes, alignment, show (launch rows bits per bw I initial).buffers.length = 4 from rfl,
    show (launch rows bits per bw I initial).groupArrays = 0 from rfl,
    show (launch rows bits per bw I initial).threadArrays = 1 from rfl] using this

/-- The thread writing thread-order position `n` (row `n / X`, `x = n % X`, `X = 5120 / per` threads a row):
threadgroup `x / 128 + (n / X)·⌈X / 128⌉`, its thread `x % 128`. -/
def gid (per n : Nat) : Nat := n % (5120 / per) / 128 + n / (5120 / per) * ceilDiv (5120 / per) 128
def tid (per n : Nat) : Nat := gid per n * 128 + n % (5120 / per) % 128

/-- The writer of each device byte: `dst`'s element `e` by the thread at position `e / per`, `done` by thread 0. -/
def dev (per : Nat) (region byte : Nat) : Option Writer :=
  if region = 2 then some ⟨tid per (byte / 2 / per), gid per (byte / 2 / per), 0⟩
  else if region = 3 then some ⟨0, 0, 0⟩ else none

/-- No threadgroup memory. -/
def tgo (_ _ _ _ : Nat) : Option Nat := none

/-! ### Memory -/

/-- Memory during the launch: inputs intact, `dst`'s first `E` halves `W`, `done` written once a thread has
finished (`0 < P`), and every access so far keeping the ownership discipline. -/
structure Mem (L : Launch) (per : Nat) (I : In) (W : Nat → Float16.Value) (E P : Nat) (sh : Shared) : Prop where
  regions : sh.regions = L.regions
  codes : sh.bytes 0 = I.Codes
  scales : sh.bytes 1 = I.S
  dst : sh.bytes 2 = halvesOver W I.D E
  done : 0 < P → cells (sh.bytes 3) 0 4 = wordBytes 4 1
  deve : sh.deviceEpoch = 0
  grpe : sh.groupEpoch = 0
  log : ∀ a ∈ sh.log, Owned L (dev per) tgo a

section Memory
variable {L : Launch} {bits per : Nat} {I : In} {W : Nat → Float16.Value} {E P : Nat} {sh : Shared}

/-- A read of the codes or scales. -/
theorem Mem.rd (h : Mem L per I W E P sh) (hS : Shape L bits I) (ctx : Ctx) (reg o n : Nat) (hreg : reg = 0 ∨ reg = 1) :
    Mem L per I W E P (rdn ctx sh reg o n) :=
  ⟨h.regions, h.codes, h.scales, h.dst, h.done, h.deve, h.grpe, forall_log _ n _ (fun j _ => by
    rcases hreg with rfl | rfl
    · exact owned_device_read L (dev per) tgo ctx sh 0 (o + j) _ hS.r0 (by simp) (by simp [dev])
    · exact owned_device_read L (dev per) tgo ctx sh 1 (o + j) _ hS.r1 (by simp) (by simp [dev])) h.log⟩

/-- A write to thread memory. -/
theorem Mem.tput (h : Mem L per I W E P sh) {reg : Nat} (o : Nat) (bs : List (BitVec 8)) (hreg : 4 ≤ reg) :
    Mem L per I W E P (Metal.tput sh reg o bs) :=
  ⟨h.regions, by rw [tput_other _ _ _ (by omega)]; exact h.codes, by rw [tput_other _ _ _ (by omega)]; exact h.scales,
    by rw [tput_other _ _ _ (by omega)]; exact h.dst, fun hp => by rw [tput_other _ _ _ (by omega)]; exact h.done hp,
    h.deve, h.grpe, h.log⟩

/-- A thread's `half4` store of `dst`'s next four halves, its own. -/
theorem Mem.wq (h : Mem L per I W E P sh) (hS : Shape L bits I) (ctx : Ctx) (bs : List (BitVec 8))
    (hbs : bs.length = 8) (hb : ∀ k < 8, bs.getD k 0 = halfByte (W (E + k / 2)) (k % 2))
    (hown : ∀ j < 8, dev per 2 (2 * E + j) = some ⟨ctx.thread, ctx.group, 0⟩) :
    Mem L per I W (E + 4) P (wrn ctx sh 2 (2 * E) 8 bs) :=
  ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.codes,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.scales,
    by rw [wrn_same, h.dst]; exact halvesOver_store W I.D E 4 bs hbs hb,
    fun hp => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.done hp, h.deve, h.grpe,
    forall_log _ 8 _ (fun j hj => owned_device L (dev per) tgo ctx sh 2 (2 * E + j) _ hS.r2 true (by simp)
      ⟨ctx.thread, ctx.group, 0⟩ (hown j hj) rfl rfl (by rw [h.deve])) h.log⟩

/-- Thread 0's store of `done`. -/
theorem Mem.wdone (h : Mem L per I W E P sh) (hS : Shape L bits I) (ctx : Ctx) (ht : ctx.thread = 0)
    (hg : ctx.group = 0) : Mem L per I W E (P + 1) (wrn ctx sh 3 0 4 (wordBytes 4 1)) :=
  ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.codes,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.scales, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.dst,
    fun _ => by
      rw [wrn_same]
      have := cells_writeBytes_same (sh.bytes 3) 0 (wordBytes 4 1)
      rwa [wordBytes_length] at this,
    h.deve, h.grpe,
    forall_log _ 4 _ (fun j _ => owned_device L (dev per) tgo ctx sh 3 (0 + j) _ hS.r3 true (by simp)
      ⟨0, 0, 0⟩ (by simp [dev]) ht hg (by rw [h.deve])) h.log⟩

/-- A later thread: `done` is already written. -/
theorem Mem.bump (h : Mem L per I W E P sh) (hp : 0 < P) : Mem L per I W E (P + 1) sh :=
  ⟨h.regions, h.codes, h.scales, h.dst, fun _ => h.done hp, h.deve, h.grpe, h.log⟩

/-- A threadgroup starts (no threadgroup arrays). -/
theorem Mem.reset (h : Mem L per I W E P sh) (hg : L.groupArrays = 0) (garbage : Garbage) (g : Nat) :
    Mem L per I W E P { sh with bytes := L.resetGroup garbage g sh.bytes } := by
  rw [Launch.resetGroup_none L garbage g sh.bytes hg]
  exact h

theorem Mem.cast (h : Mem L per I W E P sh) {E' P' : Nat} (h1 : E = E') (h2 : P = P') : Mem L per I W E' P' sh := by
  subst h1 h2; exact h

theorem Mem.castP (h : Mem L per I W (P * per) P sh) {P' : Nat} (hP : P = P') : Mem L per I W (P' * per) P' sh := by
  subst hP; exact h

end Memory

/-! ### The header functions -/

section Header
variable (C : M1Max.Contract) {ctx : Ctx}

/-- `trellis_y(s)` (slots `b` s, `b + 1` result, `b + 2` x, `b + 3` p). -/
theorem exec_trellisY (b : Nat) {l : Locals} {sh : Shared} {s : Nat} (h : l b = some (u32 s)) :
    ∃ l', Exec C ctx [AneTrellisFill.trellisY b] l sh .normal l' sh ∧ l' (b + 1) = some (i32 (trellisYv s)) ∧
      ∀ j, j ≤ b ∨ b + 3 < j → l' j = l j := by
  generalize hx : (s * 34038481 + 76625530) % 2 ^ 32 = x
  have hxl : x < 2 ^ 32 := by rw [← hx]; exact Nat.mod_lt _ (by decide)
  obtain ⟨P, hP, hPl⟩ : ∃ P, trellisP s = P ∧ P < 2 ^ 25 := ⟨_, rfl, trellisP_lt s⟩
  have hp : P = (x &&& 16711935) + (x / 2 ^ 8 &&& 16711935) := by rw [← hP, trellisP, hx]
  obtain ⟨Y, hY, hYl⟩ : ∃ Y, (P &&& 65535) + P / 2 ^ 16 = Y ∧ Y < 2 ^ 31 :=
    ⟨_, rfl, by have := Nat.and_le_right (n := P) (m := 65535); omega⟩
  have hyv : trellisYv s = (Y : Int) - 510 := by
    unfold trellisYv; rw [hP, show (P &&& 0xFFFF) = (P &&& 65535) from rfl, hY]
  rw [hyv]
  have e1 : (eval C ctx l (.bin .add .u32 0 (.bin .mul .u32 0 (.local b) (.lit (.int .u32 34038481)))
      (.lit (.int .u32 76625530)))).run sh = some (u32 x, sh) := by
    rw [← hx, u32_mod]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C h sh) (eval_u32lit C _ _ _ (by decide))
      (binary_mul_u32 C s 34038481)) (eval_u32lit C _ _ _ (by decide)) (binary_add_u32 C _ 76625530)
  generalize hl₁ : setLocal l (b + 2) (u32 x) = l₁
  have h2 : l₁ (b + 2) = some (u32 x) := by rw [← hl₁, setLocal_same]
  have e2 : (eval C ctx l₁ (.bin .add .u32 0 (.bin .bitAnd .u32 0 (.local (b + 2)) (.lit (.int .u32 16711935)))
      (.bin .bitAnd .u32 0 (.bin .shr .u32 0 (.local (b + 2)) (.lit (.int .u32 8))) (.lit (.int .u32 16711935))))).run sh =
      some (u32 P, sh) := by
    rw [hp]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C h2 sh) (eval_u32lit C _ _ _ (by decide))
      (binary_bitAnd_u32 C x 16711935 hxl (by decide)))
      (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h2 sh) (eval_u32lit C _ _ _ (by decide))
        (binary_shr_u32 C x 8 hxl (by decide))) (eval_u32lit C _ _ _ (by decide))
        (binary_bitAnd_u32 C (x / 2 ^ 8) 16711935 (lt_of_le_of_lt (Nat.div_le_self _ _) hxl) (by decide)))
      (binary_add_u32 C _ _)
  generalize hl₂ : setLocal l₁ (b + 3) (u32 P) = l₂
  have h3 : l₂ (b + 3) = some (u32 P) := by rw [← hl₂, setLocal_same]
  have e3 : (eval C ctx l₂ (.bin .sub .i32 0
      (.conv .i32 (.bin .add .u32 0 (.bin .bitAnd .u32 0 (.local (b + 3)) (.lit (.int .u32 65535)))
        (.bin .shr .u32 0 (.local (b + 3)) (.lit (.int .u32 16))))) (.lit (.int .i32 510)))).run sh =
      some (i32 ((Y : Int) - 510), sh) := by
    have hz : binary C .sub .i32 (.int .i32 Y) (.int .i32 510) = some (i32 ((Y : Int) - 510)) :=
      binary_sub_i32_nat C Y 510 hYl (by decide)
    have hadd : (eval C ctx l₂ (.bin .add .u32 0 (.bin .bitAnd .u32 0 (.local (b + 3)) (.lit (.int .u32 65535)))
        (.bin .shr .u32 0 (.local (b + 3)) (.lit (.int .u32 16))))).run sh = some (u32 Y, sh) := by
      rw [← hY]
      exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C h3 sh) (eval_u32lit C _ _ _ (by decide))
        (binary_bitAnd_u32 C _ 65535 (by omega) (by decide)))
        (eval_bin_u32 C (eval_local' C h3 sh) (eval_u32lit C _ _ _ (by decide))
          (binary_shr_u32 C _ 16 (by omega) (by decide))) (binary_add_u32 C _ _)
    exact eval_int C (by decide) (eval_conv C (t := .i32) hadd (convert_i32_u32 C _ hYl)) (eval_lit C _ _ _ _) hz
  refine ⟨setLocal l₂ (b + 1) (i32 ((Y : Int) - 510)), ?_, setLocal_same _ _ _, fun j hj => ?_⟩
  · exact .scope (.set e1 (by rw [hl₁]; exact .set e2 (by rw [hl₂]; exact .set e3 .leave))) (.inr rfl) (.nil _ _)
  · rw [setLocal_other _ _ (by omega), ← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_other _ _ (by omega)]

/-- `trellis_refined_y(y)` (slots `b` y, `b + 1` result, `b + 2` yf, `b + 3` r, `b + 4` q, `b + 5` e). -/
theorem exec_refinedY (b : Nat) {l : Locals} {sh : Shared} {y : Int} (h : l b = some (i32 y)) (h1 : -2 ^ 24 ≤ y)
    (h2 : y ≤ 2 ^ 24) :
    ∃ l', Exec C ctx [AneTrellisFill.refinedY b] l sh .normal l' sh ∧ l' (b + 1) = some (.f32 (refinedY C y)) ∧
      ∀ j, j ≤ b ∨ b + 5 < j → l' j = l j := by
  generalize hyf : Val.ofF32Bits (exactF32 y) = yf
  have e1 : (eval C ctx l (.conv .f32 (.local b))).run sh = some (.f32 yf, sh) := by
    rw [← hyf]; exact eval_conv C (eval_local' C h sh) (convert_f32_i32v C h1 h2)
  generalize hl₁ : setLocal l (b + 2) (.f32 yf) = l₁
  generalize hl₂ : setLocal l₁ (b + 3) (.f32 (Val.ofF32Bits 0x3BDDB447)) = l₂
  have e3 : (eval C ctx l₂ (.bin .mul .f32 0 (.local (b + 2)) (.local (b + 3)))).run sh =
      some (.f32 (C.fmul yf (Val.ofF32Bits 0x3BDDB447)), sh) :=
    eval_f32 C (.inl ⟨by decide, by decide⟩)
      (eval_local' C (by rw [← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_same]) sh)
      (eval_local' C (by rw [← hl₂, setLocal_same]) sh) rfl
  generalize hq : C.fmul yf (Val.ofF32Bits 0x3BDDB447) = q at e3
  generalize hl₃ : setLocal l₂ (b + 4) (.f32 q) = l₃
  have e4 : (eval C ctx l₃ (.fma (.un .neg .f32 (.local (b + 4))) (.lit (.f32 (Val.ofF32Bits 0x4313CCF0)))
      (.local (b + 2)))).run sh = some (.f32 (C.fma (f32Neg q) (Val.ofF32Bits 0x4313CCF0) yf), sh) :=
    eval_fma C (eval_un C (eval_local' C (by rw [← hl₃, setLocal_same]) sh) rfl) (eval_lit C _ _ _ _)
      (eval_local' C (by rw [← hl₃, setLocal_other _ _ (by omega), ← hl₂, setLocal_other _ _ (by omega), ← hl₁,
        setLocal_same]) sh)
  generalize he : C.fma (f32Neg q) (Val.ofF32Bits 0x4313CCF0) yf = e at e4
  generalize hl₄ : setLocal l₃ (b + 5) (.f32 e) = l₄
  have e5 : (eval C ctx l₄ (.fma (.local (b + 5)) (.local (b + 3)) (.local (b + 4)))).run sh =
      some (.f32 (C.fma e (Val.ofF32Bits 0x3BDDB447) q), sh) :=
    eval_fma C (eval_local' C (by rw [← hl₄, setLocal_same]) sh)
      (eval_local' C (by rw [← hl₄, setLocal_other _ _ (by omega), ← hl₃, setLocal_other _ _ (by omega), ← hl₂,
        setLocal_same]) sh)
      (eval_local' C (by rw [← hl₄, setLocal_other _ _ (by omega), ← hl₃, setLocal_same]) sh)
  have hv : refinedY C y = C.fma e (Val.ofF32Bits 0x3BDDB447) q := by
    rw [← he, ← hq, ← hyf]; rfl
  refine ⟨setLocal l₄ (b + 1) (.f32 (C.fma e (Val.ofF32Bits 0x3BDDB447) q)), ?_, by rw [hv, setLocal_same],
    fun j hj => ?_⟩
  · subst hl₁ hl₂ hl₃ hl₄
    exact .scope (.set e1 (.set (eval_lit C _ _ _ _) (.set e3 (.set e4 (.set e5 .leave))))) (.inr rfl) (.nil _ _)
  · rw [setLocal_other _ _ (by omega), ← hl₄, setLocal_other _ _ (by omega), ← hl₃, setLocal_other _ _ (by omega),
      ← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_other _ _ (by omega)]

theorem trellisYv_bound (s : Nat) : -2 ^ 24 ≤ trellisYv s ∧ trellisYv s ≤ 2 ^ 24 := by
  have hP := trellisP_lt s
  have := Nat.and_le_right (n := trellisP s) (m := 0xFFFF)
  unfold trellisYv
  omega

/-- **`trellis_val_rcp(s)`** (slots `b` s, `b + 1` result, `b + 2 …` the inlined calls'). -/
theorem exec_valRcp (b : Nat) {l : Locals} {sh : Shared} {s : Nat} (h : l b = some (u32 s)) :
    ∃ l', Exec C ctx [AneTrellisFill.valRcp b] l sh .normal l' sh ∧ l' (b + 1) = some (.f32 (valRcp C s)) ∧
      ∀ j, j ≤ b ∨ b + 11 < j → l' j = l j := by
  generalize hl₁ : setLocal l (b + 2) (u32 s) = l₁
  obtain ⟨l₂, hy, h3, hl₂⟩ := exec_trellisY C (ctx := ctx) (sh := sh) (b + 2) (l := l₁) (s := s)
    (by rw [← hl₁, setLocal_same])
  generalize hl₃ : setLocal l₂ (b + 6) (i32 (trellisYv s)) = l₃
  obtain ⟨l₄, hr, h7, hl₄⟩ := exec_refinedY C (ctx := ctx) (sh := sh) (b + 6) (l := l₃) (y := trellisYv s)
    (by rw [← hl₃, setLocal_same]) (trellisYv_bound s).1 (trellisYv_bound s).2
  refine ⟨setLocal l₄ (b + 1) (.f32 (valRcp C s)), ?_, setLocal_same _ _ _, fun j hj => ?_⟩
  · exact .scope (.set (eval_local' C h sh) (by rw [hl₁]; exact hy.append (.set (eval_local' C h3 sh)
      (by rw [hl₃]; exact hr.append (.set (eval_local' C h7 sh) .leave))))) (.inr rfl) (.nil _ _)
  · rw [setLocal_other _ _ (by omega), hl₄ j (by omega), ← hl₃, setLocal_other _ _ (by omega), hl₂ j (by omega),
      ← hl₁, setLocal_other _ _ (by omega)]

end Header

/-! ### A thread's pieces -/

/-- Code widths 2, 3 and 4. -/
def Bits (K : Nat) : Prop := K = 2 ∨ K = 3 ∨ K = 4

/-- `pos = (BT - 1 - (t + 4·q + 3))·BITS` (slot 12). -/
def posE (bits : Nat) : CExpr :=
  .bin .mul .u32 0 (.bin .sub .u32 0 (.lit (.int .u32 255)) (.bin .add .u32 0 (.bin .add .u32 0 (.local 7)
    (.bin .mul .u32 0 (.lit (.int .u32 4)) (.local 11))) (.lit (.int .u32 3)))) (.lit (.int .u32 bits))

/-- `wi + 1 == wpb ? 0 : wi + 1`. -/
def idxE (bits : Nat) : CExpr :=
  .cond (.bin .eq .u32 0 (.bin .add .u32 0 (.local 13) (.lit (.int .u32 1))) (.lit (.int .u32 (8 * bits))))
    (.lit (.int .u32 0)) (.bin .add .u32 0 (.local 13) (.lit (.int .u32 1)))

/-- `window` (slot 15). -/
def windowE (bits : Nat) : CExpr :=
  .bin .shr .u64 0 (.bin .bitOr .u64 0 (.conv .u64 (.load (.scalar .u32) (.offset (.local 8) (.local 13))))
    (.bin .shl .u64 0 (.conv .u64 (.load (.scalar .u32) (.offset (.local 8) (idxE bits)))) (.lit (.int .u64 32))))
    (.conv .u64 (.local 14))

/-- Weight `i`'s 12-bit state (slot 18). -/
def stateE (bits : Nat) : CExpr :=
  .bin .bitAnd .u32 0 (.conv .u32 (.bin .shr .u64 0 (.local 15) (.conv .u64 (.bin .mul .u32 0
    (.bin .sub .u32 0 (.lit (.int .u32 3)) (.local 17)) (.lit (.int .u32 bits)))))) (.lit (.int .u32 4095))

def weightLoop (bits : Nat) : CStmt :=
  .loop (.bin .lt .u32 0 (.local 17) (.lit (.int .u32 4))) [.set 17 (.bin .add .u32 0 (.local 17) (.lit (.int .u32 1)))]
    (AneTrellisFill.weight bits)

/-- `out[q] = v`. -/
def storeQ : CStmt := .store (.vec .f16 4) (.offset (.local 10) (.local 11)) (.load (.vec .f16 4) (.local 16))

theorem weight_eq (bits : Nat) : AneTrellisFill.weight bits = [.set 18 (stateE bits), AneTrellisFill.valRcp 18,
    .store (.scalar .f16) (.offset (.ptrCast (.scalar .f16) (.local 16)) (.local 17))
      (.conv .f16 (.bin .mul .f32 0 (.local 19) (.local 9)))] := rfl

theorem quad_eq (bits : Nat) : AneTrellisFill.quad bits =
    [.set 12 (posE bits), .set 13 (.bin .shr .u32 0 (.local 12) (.lit (.int .u32 5))),
     .set 14 (.bin .bitAnd .u32 0 (.local 12) (.lit (.int .u32 31))), .set 15 (windowE bits),
     .array 16 false 0 (.vec .f16 4), .set 17 (.lit (.int .u32 0)), weightLoop bits, storeQ] := rfl

/-- The second word of a window: the block's next word, its first after its last. -/
def wsel (bits wi : Nat) : Nat := if wi + 1 = 8 * bits then 0 else wi + 1

/-- The thread's fixed slots 0 … 10: the pointers, `c`, `r`, `block`, `t`, `bw`, `scale`, `out`. -/
structure Loc (c y base : Nat) (sc : Float32) (l : Locals) : Prop where
  l0 : l 0 = some (.ptr ⟨0, 0, .scalar .u32⟩)
  l1 : l 1 = some (.ptr ⟨1, 0, .scalar .f16⟩)
  l2 : l 2 = some (.ptr ⟨2, 0, .scalar .f16⟩)
  l3 : l 3 = some (.ptr ⟨3, 0, .scalar .i32⟩)
  l4 : l 4 = some (u32 c)
  l5 : l 5 = some (u32 y)
  l6 : l 6 = some (u32 (c / 256))
  l7 : l 7 = some (u32 (c % 256))
  l8 : l 8 = some (.ptr ⟨0, ((4 * base : Nat) : Int), .scalar .u32⟩)
  l9 : l 9 = some (.f32 sc)
  l10 : l 10 = some (.ptr ⟨2, ((2 * (y * 5120 + c) : Nat) : Int), .vec .f16 4⟩)

theorem Loc.of_eq {c y base : Nat} {sc : Float32} {l l' : Locals} (h : Loc c y base sc l)
    (h' : ∀ j, j ≤ 10 → l' j = l j) : Loc c y base sc l' :=
  ⟨(h' 0 (by omega)).trans h.l0, (h' 1 (by omega)).trans h.l1, (h' 2 (by omega)).trans h.l2,
    (h' 3 (by omega)).trans h.l3, (h' 4 (by omega)).trans h.l4, (h' 5 (by omega)).trans h.l5,
    (h' 6 (by omega)).trans h.l6, (h' 7 (by omega)).trans h.l7, (h' 8 (by omega)).trans h.l8,
    (h' 9 (by omega)).trans h.l9, (h' 10 (by omega)).trans h.l10⟩

theorem Loc.set {c y base : Nat} {sc : Float32} {l : Locals} (h : Loc c y base sc l) {j : Nat} (v : Val) (hj : 10 < j) :
    Loc c y base sc (setLocal l j v) :=
  h.of_eq fun k hk => setLocal_other _ _ (by omega)

/-- The state of weight `j` of quad `q`, from the window of the block's words, is the column's trellis state. -/
theorem state_code {K : Nat} (hK : Bits K) (B : ByteMemory.Bytes) (base t q j : Nat) (ht : t + 4 * q + 3 ≤ 255)
    (hj : j < 4) :
    (word32 B (base + (255 - (t + 4 * q + 3)) * K / 32) |||
        word32 B (base + wsel K ((255 - (t + 4 * q + 3)) * K / 32)) * 2 ^ 32) /
      2 ^ ((255 - (t + 4 * q + 3)) * K % 32) / 2 ^ ((3 - j) * K) % 2 ^ 12 = trellisCode K B base (t + 4 * q + j) := by
  generalize hp : (255 - (t + 4 * q + 3)) * K = pos
  have hwi : pos / 32 < 8 * K := by rw [← hp]; rcases hK with rfl | rfl | rfl <;> omega
  have hw0 := word32_lt B (base + pos / 32)
  have hor : word32 B (base + pos / 32) ||| word32 B (base + wsel K (pos / 32)) * 2 ^ 32 =
      word32 B (base + pos / 32) + word32 B (base + wsel K (pos / 32)) * 2 ^ 32 := by
    rw [Nat.lor_comm, ← Nat.shiftLeft_eq, ← Nat.shiftLeft_add_eq_or_of_lt hw0]
    omega
  have hm : (pos / 32 + 1) % (8 * K) = wsel K (pos / 32) := by
    unfold wsel
    split
    · rename_i h; rw [h, Nat.mod_self]
    · rename_i h; exact Nat.mod_eq_of_lt (by omega)
  have hrb : runBits (fun i => word32 B (base + (pos / 32 + i) % (8 * K))) 2 =
      word32 B (base + pos / 32) + word32 B (base + wsel K (pos / 32)) * 2 ^ 32 := by
    simp only [runBits, Nat.mul_zero, Nat.pow_zero, Nat.mul_one, Nat.zero_add, Nat.add_zero]
    rw [Nat.mod_eq_of_lt hwi, hm]
  have hwb := window_block (K := K) B base (pos / 32) 2 (pos % 32 + (3 - j) * K) (by omega)
    (by rcases hK with rfl | rfl | rfl <;> omega)
  rw [hor, Nat.div_div_eq_div_mul, ← Nat.pow_add, ← hrb, hwb]
  unfold trellisCode
  rw [show 32 * (pos / 32) + (pos % 32 + (3 - j) * K) = K * (255 - (t + 4 * q + j)) by
    rw [← hp]; rcases hK with rfl | rfl | rfl <;> omega]

/-- The weight at element `y·5120 + c + 4q + j` (within row `y`'s columns and block). -/
theorem elem_at (C : M1Max.Contract) (K : Nat) (base : Nat → Nat → Nat) (Codes S : ByteMemory.Bytes) {y c q j : Nat}
    (hc : c % 256 + 4 * q + j < 256) (hcj : c + 4 * q + j < 5120) :
    elem C K base Codes S (y * 5120 + c + 4 * q + j) =
      C.narrowHalf (C.fmul (valRcp C (trellisCode K Codes (base y (c / 256)) (c % 256 + 4 * q + j))) (scale S y)) := by
  unfold elem weight
  rw [show (y * 5120 + c + 4 * q + j) / 5120 = y by omega, show (y * 5120 + c + 4 * q + j) % 5120 = c + 4 * q + j by omega,
    show (c + 4 * q + j) / 256 = c / 256 by omega, show (c + 4 * q + j) % 256 = c % 256 + 4 * q + j by omega]

section Thread
variable (C : M1Max.Contract) {ctx : Ctx} {L : Launch} {bits per : Nat} {I : In} {W : Nat → Float16.Value}

/-- Weight `i` of a quad: its state from the window (slot 15), `trellis_val_rcp`, `v[i] = half(value · scale)`. -/
theorem exec_weight (hK : Bits bits) {c y base : Nat} {sc : Float32} {l : Locals} {sh : Shared} {R i Wv : Nat}
    (hL : Loc c y base sc l) (h15 : l 15 = some (u64 Wv)) (hWv : Wv < 2 ^ 64)
    (h16 : l 16 = some (.ptr ⟨R, 0, .vec .f16 4⟩)) (h17 : l 17 = some (u32 i)) (hi : i < 4)
    (hR : sh.regions R = some ⟨.thread, 8, 8⟩) :
    ∃ l', Exec C ctx (AneTrellisFill.weight bits) l sh .normal l' (Metal.tput sh R (2 * i)
        (wordBytes 2 (Val.f16Bits (C.narrowHalf (C.fmul (valRcp C (Wv / 2 ^ ((3 - i) * bits) % 2 ^ 12)) sc))))) ∧
      ∀ j, j ≤ 17 → l' j = l j := by
  have hb5 : bits < 5 := by rcases hK with rfl | rfl | rfl <;> omega
  have hk : (3 - i) * bits ≤ 12 := by rcases hK with rfl | rfl | rfl <;> omega
  have hst : (eval C ctx l (stateE bits)).run sh = some (u32 (Wv / 2 ^ ((3 - i) * bits) % 2 ^ 12), sh) := by
    have e1 := eval_bin_u32 C (ctx := ctx) (op := .mul) (site := 0)
      (eval_bin_u32 C (op := .sub) (site := 0) (eval_u32lit C l sh 3 (by decide)) (eval_local' C h17 sh)
        (binary_sub_u32 C 3 i (by omega))) (eval_u32lit C l sh bits (by omega)) (binary_mul_u32 C (3 - i) bits)
    have e2 := eval_int C (op := .shr) (site := 0) (by decide) (eval_local' C h15 sh)
      (eval_conv C (t := .u64) e1 (convert_u64_u32 C ((3 - i) * bits) (by omega)))
      (binary_shr_u64 C Wv ((3 - i) * bits) hWv (by omega))
    have e3 := eval_conv C (t := .u32) e2 (convert_u32_u64 C _)
    rw [← u32_mod] at e3
    have e4 := eval_bin_u32 C (op := .bitAnd) (site := 0) e3 (eval_u32lit C l sh 4095 (by decide))
      (binary_bitAnd_u32 C _ 4095 (Nat.mod_lt _ (by decide)) (by decide))
    have hv : Wv / 2 ^ ((3 - i) * bits) % 2 ^ 32 &&& 4095 = Wv / 2 ^ ((3 - i) * bits) % 2 ^ 12 := by
      rw [show (4095 : Nat) = 2 ^ 12 - 1 from rfl, Nat.and_two_pow_sub_one_eq_mod, Nat.mod_mod_of_dvd _ (by decide)]
    rw [hv] at e4
    exact e4
  generalize Wv / 2 ^ ((3 - i) * bits) % 2 ^ 12 = st at hst ⊢
  obtain ⟨l₁, hv, h19, hl₁⟩ := exec_valRcp C (ctx := ctx) (sh := sh) 18 (l := setLocal l 18 (u32 st)) (s := st)
    (setLocal_same _ _ _)
  have h16' : l₁ 16 = some (.ptr ⟨R, 0, .vec .f16 4⟩) := by
    rw [hl₁ 16 (by omega), setLocal_other _ _ (by omega)]; exact h16
  have h17' : l₁ 17 = some (u32 i) := by rw [hl₁ 17 (by omega), setLocal_other _ _ (by omega)]; exact h17
  have h9' : l₁ 9 = some (.f32 sc) := by rw [hl₁ 9 (by omega), setLocal_other _ _ (by omega)]; exact hL.l9
  have hp : (eval C ctx l₁ (.offset (.ptrCast (.scalar .f16) (.local 16)) (.local 17))).run sh =
      some (.ptr ⟨R, ((2 * i : Nat) : Int), .scalar .f16⟩, sh) := by
    have := eval_offset_u32 C (ctx := ctx) (o := 0) (eval_ptrCast C (t := .scalar .f16) (eval_local' C h16' sh))
      (eval_local' C h17' sh) (show i < 2 ^ 32 by omega)
    rwa [show 0 + i * (Ty.scalar .f16).bytes = 2 * i by simp only [Ty.bytes, Scalar.bytes]; omega] at this
  have hval : (eval C ctx l₁ (.conv .f16 (.bin .mul .f32 0 (.local 19) (.local 9)))).run sh =
      some (.f16 (C.narrowHalf (C.fmul (valRcp C st) sc)), sh) :=
    eval_conv C (eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_local' C h19 sh) (eval_local' C h9' sh) rfl) rfl
  have hs := store_thread ctx .f16 sh R (2 * i) 8 8 (.f16 (C.narrowHalf (C.fmul (valRcp C st) sc)))
    (wordBytes 2 (Val.f16Bits (C.narrowHalf (C.fmul (valRcp C st) sc)))) hR (by decide)
    (by show 2 * i % 2 = 0; omega) (by show 2 * i + 2 ≤ 8; omega) rfl
  refine ⟨l₁, ?_, fun j hj => by rw [hl₁ j (by omega), setLocal_other _ _ (by omega)]⟩
  rw [weight_eq]
  exact .set hst (hv.append (.store hp hval hs (.nil _ _)))

/-- `window`: the two words of the block from word `wi` (the next one wrapping to the block's first), shifted down
`off`. Its loads read the codes. -/
theorem eval_window (hS : Shape L bits I) (hK : Bits bits) {c y base wi off E P : Nat} {sc : Float32} {l : Locals}
    {sh : Shared} (hL : Loc c y base sc l) (h13 : l 13 = some (u32 wi)) (h14 : l 14 = some (u32 off))
    (hwi : wi < 8 * bits) (hoff : off < 32) (hbase : base + 8 * bits ≤ 17408 * 160 * bits)
    (hm : Mem L per I W E P sh) :
    ∃ sh', (eval C ctx l (windowE bits)).run sh = some (u64 ((word32 I.Codes (base + wi) |||
        word32 I.Codes (base + wsel bits wi) * 2 ^ 32) / 2 ^ off), sh') ∧ Mem L per I W E P sh' := by
  have hb5 : bits < 5 := by rcases hK with rfl | rfl | rfl <;> omega
  have hsz : ∀ w, w < 8 * bits → 4 * (base + w) + 4 ≤ GateUp.codesBytes bits := by
    intro w hw; unfold GateUp.codesBytes; omega
  -- a word of the block
  have hload : ∀ (sh₀ : Shared) (w : Nat) (e : CExpr), w < 8 * bits → Mem L per I W E P sh₀ →
      (eval C ctx l e).run sh₀ = some (u32 w, sh₀) →
      (eval C ctx l (.load (.scalar .u32) (.offset (.local 8) e))).run sh₀ =
        some (u32 (word32 I.Codes (base + w)), rdn ctx sh₀ 0 (4 * (base + w)) 4) := by
    intro sh₀ w e hw hm₀ he
    have hp : (eval C ctx l (.offset (.local 8) e)).run sh₀ =
        some (.ptr ⟨0, ((4 * (base + w) : Nat) : Int), .scalar .u32⟩, sh₀) := by
      have := eval_offset_u32 C (o := 4 * base) (eval_local' C hL.l8 sh₀) he (show w < 2 ^ 32 by omega)
      rwa [show 4 * base + w * (Ty.scalar .u32).bytes = 4 * (base + w) by simp only [Ty.bytes, Scalar.bytes]; omega]
        at this
    rw [eval_load C _ _ _ _ _ _ _ hp, load_shared ctx .u32 sh₀ 0 (4 * (base + w)) ⟨.device, GateUp.codesBytes bits, I.ac⟩
      (by rw [hm₀.regions]; exact hS.r0) (by simp) (by show I.ac % 4 = 0; exact hS.ac) (by show 4 * (base + w) % 4 = 0; omega)
      (by show 4 * (base + w) + 4 ≤ GateUp.codesBytes bits; exact hsz w hw) (by simp [loadOffset]), hm₀.codes]
    rfl
  have hA := hload sh wi (.local 13) hwi hm (eval_local' C h13 sh)
  generalize hs₁ : rdn ctx sh 0 (4 * (base + wi)) 4 = sh₁ at hA
  have hm₁ : Mem L per I W E P sh₁ := by rw [← hs₁]; exact hm.rd hS ctx 0 _ 4 (.inl rfl)
  have hw' : wsel bits wi < 8 * bits := by unfold wsel; split <;> omega
  have hidx : (eval C ctx l (idxE bits)).run sh₁ = some (u32 (wsel bits wi), sh₁) := by
    have hc := eval_bin_u32 C (ctx := ctx) (op := .eq) (site := 0)
      (eval_bin_u32 C (op := .add) (site := 0) (eval_local' C h13 sh₁) (eval_u32lit C l sh₁ 1 (by decide))
        (binary_add_u32 C wi 1)) (eval_u32lit C l sh₁ (8 * bits) (by omega))
      (binary_eq_u32 C (wi + 1) (8 * bits) (by omega) (by omega))
    refine eval_cond C hc ?_
    unfold wsel
    by_cases h : wi + 1 = 8 * bits
    · rw [decide_eq_true h, ite_eq_left h]; exact eval_u32lit C l sh₁ 0 (by decide)
    · rw [decide_eq_false h, ite_eq_right h]
      exact eval_bin_u32 C (eval_local' C h13 sh₁) (eval_u32lit C l sh₁ 1 (by decide)) (binary_add_u32 C wi 1)
  have hB := hload sh₁ (wsel bits wi) (idxE bits) hw' hm₁ hidx
  generalize hs₂ : rdn ctx sh₁ 0 (4 * (base + wsel bits wi)) 4 = sh₂ at hB
  have hm₂ : Mem L per I W E P sh₂ := by rw [← hs₂]; exact hm₁.rd hS ctx 0 _ 4 (.inl rfl)
  have hw0 := word32_lt I.Codes (base + wi)
  have hw1 := word32_lt I.Codes (base + wsel bits wi)
  have hsh : (eval C ctx l (.bin .shl .u64 0 (.conv .u64 (.load (.scalar .u32) (.offset (.local 8) (idxE bits))))
      (.lit (.int .u64 32)))).run sh₁ = some (u64 (word32 I.Codes (base + wsel bits wi) * 2 ^ 32), sh₂) :=
    eval_int C (by decide) (eval_conv C (t := .u64) hB (convert_u64_u32 C _ hw1))
      (show (eval C ctx l (.lit (.int .u64 32))).run sh₂ = some (u64 32, sh₂) from rfl)
      (binary_shl_u64 C _ 32 (by decide))
  have hor := eval_int C (op := .bitOr) (site := 0) (by decide) (eval_conv C (t := .u64) hA (convert_u64_u32 C _ hw0)) hsh
    (binary_bitOr_u64 C _ _ (by omega) (by omega))
  have hlt := Nat.or_lt_two_pow (show word32 I.Codes (base + wi) < 2 ^ 64 by omega)
    (show word32 I.Codes (base + wsel bits wi) * 2 ^ 32 < 2 ^ 64 by omega)
  exact ⟨sh₂, eval_int C (by decide) hor (eval_conv C (t := .u64) (eval_local' C h14 sh₂) (convert_u64_u32 C off (by omega)))
    (binary_shr_u64 C _ off hlt (by omega)), hm₂⟩

/-- **A quad** (`q` in slot 11): `pos`, `wi`, `off`, the window, the four weights into the thread array `v`, and
`out[q] = v`, `dst`'s four halves from element `E = 5120·y + c + 4q`. -/
theorem exec_quad (hS : Shape L bits I) (hK : Bits bits) {c y base q E P : Nat} {sc : Float32} {l : Locals}
    {sh : Shared} (hR4 : 4 ≤ ctx.threadArray 0) (hL : Loc c y base sc l) (h11 : l 11 = some (u32 q))
    (ht : c % 256 + 4 * q + 3 ≤ 255) (hbase : base + 8 * bits ≤ 17408 * 160 * bits) (hE : E = y * 5120 + c + 4 * q)
    (hc4 : c % 4 = 0) (hnd : E + 4 ≤ I.nd)
    (hW : ∀ j < 4, W (E + j) =
      C.narrowHalf (C.fmul (valRcp C (trellisCode bits I.Codes base (c % 256 + 4 * q + j))) sc))
    (hown : ∀ j < 8, dev per 2 (2 * E + j) = some ⟨ctx.thread, ctx.group, 0⟩) (hm : Mem L per I W E P sh) :
    ∃ l' sh', Exec C ctx (AneTrellisFill.quad bits) l sh .normal l' sh' ∧ Loc c y base sc l' ∧
      l' 11 = some (u32 q) ∧ Mem L per I W (E + 4) P sh' := by
  have hb5 : bits < 5 ∧ 2 ≤ bits := by rcases hK with rfl | rfl | rfl <;> omega
  have hRr : sh.regions (ctx.threadArray 0) = some ⟨.thread, 8, 8⟩ := by
    rw [hm.regions, show ctx.threadArray 0 = 4 + (ctx.threadArray 0 - 4) by omega]; exact hS.rt _
  -- pos, wi, off
  have hpos : (eval C ctx l (posE bits)).run sh = some (u32 ((255 - (c % 256 + 4 * q + 3)) * bits), sh) :=
    eval_bin_u32 C (eval_bin_u32 C (eval_u32lit C l sh 255 (by decide))
      (eval_bin_u32 C (eval_bin_u32 C (eval_local' C hL.l7 sh)
        (eval_bin_u32 C (eval_u32lit C l sh 4 (by decide)) (eval_local' C h11 sh) (binary_mul_u32 C 4 q))
        (binary_add_u32 C (c % 256) (4 * q))) (eval_u32lit C l sh 3 (by decide)) (binary_add_u32 C _ 3))
      (binary_sub_u32 C 255 _ ht)) (eval_u32lit C l sh bits (by omega)) (binary_mul_u32 C _ bits)
  have hposl : (255 - (c % 256 + 4 * q + 3)) * bits < 2 ^ 32 := by
    have := Nat.mul_le_mul_right bits (Nat.sub_le 255 (c % 256 + 4 * q + 3)); omega
  generalize hp : (255 - (c % 256 + 4 * q + 3)) * bits = pos at hpos hposl
  generalize hl₁ : setLocal l 12 (u32 pos) = l₁
  have h12 : l₁ 12 = some (u32 pos) := by rw [← hl₁, setLocal_same]
  have hwi : (eval C ctx l₁ (.bin .shr .u32 0 (.local 12) (.lit (.int .u32 5)))).run sh = some (u32 (pos / 32), sh) :=
    eval_bin_u32 C (eval_local' C h12 sh) (eval_u32lit C _ _ 5 (by decide)) (binary_shr_u32 C pos 5 hposl (by decide))
  generalize hl₂ : setLocal l₁ 13 (u32 (pos / 32)) = l₂
  have hoff : (eval C ctx l₂ (.bin .bitAnd .u32 0 (.local 12) (.lit (.int .u32 31)))).run sh =
      some (u32 (pos % 32), sh) := by
    have h12' : l₂ 12 = some (u32 pos) := by rw [← hl₂, setLocal_other _ _ (by omega)]; exact h12
    have := eval_bin_u32 C (ctx := ctx) (op := .bitAnd) (site := 0) (eval_local' C h12' sh) (eval_u32lit C l₂ sh 31 (by decide))
      (binary_bitAnd_u32 C pos 31 hposl (by decide))
    rwa [show pos &&& 31 = pos % 32 from Nat.and_two_pow_sub_one_eq_mod pos 5] at this
  generalize hl₃ : setLocal l₂ 14 (u32 (pos % 32)) = l₃
  have hL₃ : Loc c y base sc l₃ := by
    rw [← hl₃, ← hl₂, ← hl₁]; exact ((hL.set _ (by omega)).set _ (by omega)).set _ (by omega)
  have h13 : l₃ 13 = some (u32 (pos / 32)) := by rw [← hl₃, setLocal_other _ _ (by omega), ← hl₂, setLocal_same]
  have h14 : l₃ 14 = some (u32 (pos % 32)) := by rw [← hl₃, setLocal_same]
  have h11₃ : l₃ 11 = some (u32 q) := by
    rw [← hl₃, setLocal_other _ _ (by omega), ← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_other _ _ (by omega)]
    exact h11
  have hwi8 : pos / 32 < 8 * bits := by rw [← hp]; rcases hK with rfl | rfl | rfl <;> omega
  obtain ⟨sh₁, hwin, hm₁⟩ := eval_window C (ctx := ctx) hS hK hL₃ h13 h14 hwi8 (Nat.mod_lt _ (by decide)) hbase hm
  have hstate : ∀ j < 4, (word32 I.Codes (base + pos / 32) ||| word32 I.Codes (base + wsel bits (pos / 32)) * 2 ^ 32) /
      2 ^ (pos % 32) / 2 ^ ((3 - j) * bits) % 2 ^ 12 = trellisCode bits I.Codes base (c % 256 + 4 * q + j) := by
    intro j hj
    have := state_code hK I.Codes base (c % 256) q j ht hj
    rw [hp] at this
    exact this
  have hWvl : (word32 I.Codes (base + pos / 32) ||| word32 I.Codes (base + wsel bits (pos / 32)) * 2 ^ 32) /
      2 ^ (pos % 32) < 2 ^ 64 :=
    lt_of_le_of_lt (Nat.div_le_self _ _) (Nat.or_lt_two_pow
      (by have := word32_lt I.Codes (base + pos / 32); omega)
      (by have := word32_lt I.Codes (base + wsel bits (pos / 32)); omega))
  generalize hWv : (word32 I.Codes (base + pos / 32) ||| word32 I.Codes (base + wsel bits (pos / 32)) * 2 ^ 32) /
    2 ^ (pos % 32) = Wv at hwin hstate hWvl
  generalize hl₄ : setLocal l₃ 15 (u64 Wv) = l₄
  obtain ⟨hv, hhv⟩ : ∃ hv : Nat → Float16.Value,
      ∀ j, hv j = C.narrowHalf (C.fmul (valRcp C (Wv / 2 ^ ((3 - j) * bits) % 2 ^ 12)) sc) := ⟨_, fun _ => rfl⟩
  generalize hl₅ : setLocal l₄ 16 (.ptr ⟨if false = true then ctx.groupArray 0 else ctx.threadArray 0, 0, .vec .f16 4⟩) = l₅
  generalize hl₆ : setLocal l₅ 17 (u32 0) = l₆
  -- the four weights
  obtain ⟨l₈, sh₈, hex, hL₈, h11₈, -, h16₈, -, hm₈, hc₈⟩ := Exec.loop_count (C := C) (ctx := ctx)
    (c := .bin .lt .u32 0 (.local 17) (.lit (.int .u32 4)))
    (st := [.set 17 (.bin .add .u32 0 (.local 17) (.lit (.int .u32 1)))]) (b := AneTrellisFill.weight bits) 4
    (fun k l' sh' => Loc c y base sc l' ∧ l' 11 = some (u32 q) ∧ l' 15 = some (u64 Wv) ∧
      l' 16 = some (.ptr ⟨ctx.threadArray 0, 0, .vec .f16 4⟩) ∧ l' 17 = some (u32 k) ∧ Mem L per I W E P sh' ∧
      ∀ j < k, cells (sh'.bytes (ctx.threadArray 0)) (2 * j) 2 = wordBytes 2 (Val.f16Bits (hv j)))
    (fun k l' sh' => Loc c y base sc l' ∧ l' 11 = some (u32 q) ∧ l' 15 = some (u64 Wv) ∧
      l' 16 = some (.ptr ⟨ctx.threadArray 0, 0, .vec .f16 4⟩) ∧ l' 17 = some (u32 k) ∧ Mem L per I W E P sh' ∧
      ∀ j < k, cells (sh'.bytes (ctx.threadArray 0)) (2 * j) 2 = wordBytes 2 (Val.f16Bits (hv j)))
    (fun k hk l' sh' hI => ⟨sh', eval_lt_u32 C hI.2.2.2.2.1 (by omega) (by decide), hI⟩)
    (fun k hk l' sh' hJ => by
      obtain ⟨hL', h11', h15', h16', h17', hm', hc'⟩ := hJ
      have hRr' : sh'.regions (ctx.threadArray 0) = some ⟨.thread, 8, 8⟩ := by
        rw [hm'.regions, ← hm.regions]; exact hRr
      obtain ⟨l₇, hw, hl₇⟩ := exec_weight C (ctx := ctx) hK hL' h15' hWvl h16' h17' hk hRr'
      have h17₇ : l₇ 17 = some (u32 k) := by rw [hl₇ 17 (by omega)]; exact h17'
      refine ⟨.normal, l₇, _, setLocal l₇ 17 (u32 (k + 1)), _, .inl rfl, hw,
        .set (eval_bin_u32 C (eval_local' C h17₇ _) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C k 1)) (.nil _ _),
        (hL'.of_eq fun j hj => hl₇ j (by omega)).set _ (by omega), ?_, ?_, ?_, setLocal_same _ _ _,
        hm'.tput _ _ hR4, ?_⟩
      · rw [setLocal_other _ _ (by omega), hl₇ 11 (by omega)]; exact h11'
      · rw [setLocal_other _ _ (by omega), hl₇ 15 (by omega)]; exact h15'
      · rw [setLocal_other _ _ (by omega), hl₇ 16 (by omega)]; exact h16'
      · intro j hj
        rw [tput_same]
        by_cases hjk : j = k
        · subst hjk
          rw [hhv]
          have := cells_writeBytes_same (sh'.bytes (ctx.threadArray 0)) (2 * j)
            (wordBytes 2 (Val.f16Bits (C.narrowHalf (C.fmul (valRcp C (Wv / 2 ^ ((3 - j) * bits) % 2 ^ 12)) sc))))
          rwa [wordBytes_length] at this
        · rw [cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega)]
          exact hc' j (by omega))
    (l := l₆) (sh := sh₁)
    ⟨by rw [← hl₆, ← hl₅, ← hl₄]; exact ((hL₃.set _ (by omega)).set _ (by omega)).set _ (by omega),
      by rw [← hl₆, setLocal_other _ _ (by omega), ← hl₅, setLocal_other _ _ (by omega), ← hl₄,
        setLocal_other _ _ (by omega)]; exact h11₃,
      by rw [← hl₆, setLocal_other _ _ (by omega), ← hl₅, setLocal_other _ _ (by omega), ← hl₄, setLocal_same],
      by rw [← hl₆, setLocal_other _ _ (by omega), ← hl₅, setLocal_same]; rfl,
      by rw [← hl₆, setLocal_same], hm₁, fun j hj => absurd hj (by omega)⟩
  -- `out[q] = v`
  have hRr₈ : sh₈.regions (ctx.threadArray 0) = some ⟨.thread, 8, 8⟩ := by rw [hm₈.regions, ← hm.regions]; exact hRr
  have hp8 : (eval C ctx l₈ (.offset (.local 10) (.local 11))).run sh₈ =
      some (.ptr ⟨2, ((2 * E : Nat) : Int), .vec .f16 4⟩, sh₈) := by
    have := eval_offset_u32 C (ctx := ctx) (o := 2 * (y * 5120 + c)) (eval_local' C hL₈.l10 sh₈) (eval_local' C h11₈ sh₈)
      (show q < 2 ^ 32 by omega)
    rwa [show 2 * (y * 5120 + c) + q * (Ty.vec .f16 4).bytes = 2 * E by show _ + q * 8 = _; omega] at this
  have hval : (eval C ctx l₈ (.load (.vec .f16 4) (.local 16))).run sh₈ =
      some (.vec .f16 [.f16 (hv 0), .f16 (hv 1), .f16 (hv 2), .f16 (hv 3)], sh₈) := by
    rw [eval_load C _ _ _ _ _ _ _ (eval_local' C h16₈ sh₈)]
    exact loadAt_run_thread ctx (.vec .f16 4) ⟨ctx.threadArray 0, 0, .vec .f16 4⟩ ⟨.thread, 8, 8⟩ sh₈ _ hRr₈ rfl
      (le_refl _) (by decide) rfl (by show 0 + 8 ≤ 8; omega) (decode_half4 (sh₈.bytes (ctx.threadArray 0)) hv hc₈)
  have hst := store_half4 ctx sh₈ 2 (2 * E) ⟨.device, I.nd * 2, I.ad⟩ (hv 0) (hv 1) (hv 2) (hv 3)
    (by rw [hm₈.regions]; exact hS.r2) (by simp) (by simp) hS.ad (by show 2 * E % 8 = 0; omega)
    (by show 2 * E + 8 ≤ I.nd * 2; omega)
  have hvW : ∀ j < 4, hv j = W (E + j) := by
    intro j hj; rw [hhv, hW j hj, hstate j hj]
  have hm₉ := hm₈.wq hS ctx (wordBytes 2 (Val.f16Bits (hv 0)) ++ wordBytes 2 (Val.f16Bits (hv 1)) ++
    wordBytes 2 (Val.f16Bits (hv 2)) ++ wordBytes 2 (Val.f16Bits (hv 3))) (by simp [wordBytes_length])
    (fun k hk => by rw [halves4_getD hv k hk, hvW (k / 2) (by omega)]) hown
  refine ⟨l₈, _, ?_, hL₈, h11₈, hm₉⟩
  rw [quad_eq]
  subst hl₁ hl₂ hl₃ hl₄ hl₅ hl₆
  exact .set hpos (.set hwi (.set hoff (.set hwin (.array (.set (eval_u32lit C _ _ 0 (by decide))
    (hex.append (.store hp8 hval hst (.nil _ _))))))))

/-- The arithmetic of quad `q` of thread `x`. -/
theorem quad_facts {per x q y : Nat} (hper : per = 8 ∨ per = 16) (hq : q < per / 4) (hx : x * per < 5120) :
    x * per % 256 + 4 * q + 3 ≤ 255 ∧ x * per % 4 = 0 ∧ x * per / 256 < 20 ∧
      (∀ j < 4, x * per % 256 + 4 * q + j < 256 ∧ x * per + 4 * q + j < 5120) ∧ (∀ j < 8, 8 * q + j < 2 * per) ∧
      y * 5120 + x * per + 4 * q + 4 ≤ (y + 1) * 5120 := by
  rcases hper with rfl | rfl <;>
    exact ⟨by omega, by omega, by omega, fun j hj => ⟨by omega, by omega⟩, fun j hj => by omega, by omega⟩

/-- The code block's address `bw` (slot 8) evaluates, for row `y` and block `blk`, to word `base y blk` of the
codes. -/
def BwSpec (bw : CExpr) (base : Nat → Nat → Nat) : Prop :=
  ∀ (ctx : Ctx) (l : Locals) (sh : Shared) (y blk : Nat), l 0 = some (.ptr ⟨0, 0, .scalar .u32⟩) →
    l 5 = some (u32 y) → l 6 = some (u32 blk) → y < 17408 → blk < 20 →
    (eval C ctx l bw).run sh = some (.ptr ⟨0, ((4 * base y blk : Nat) : Int), .scalar .u32⟩, sh)

/-- The thread `(x, y)` after the pointers: its `PER / 4` quads, then `done` if it is thread `(0, 0)`. -/
theorem exec_inner (hS : Shape L bits I) (hK : Bits bits) (hper : per = 8 ∨ per = 16) {rows : Nat}
    (hrows : rows ≤ 17408) (hnd : rows * 5120 ≤ I.nd) {bw : CExpr} {base : Nat → Nat → Nat} (hbw : BwSpec C bw base)
    (hbase : ∀ y < 17408, ∀ blk < 20, base y blk + 8 * bits ≤ 17408 * 160 * bits)
    {x y : Nat} (hx : x * per < 5120) (hy : y < rows) (hpos : ctx.coord .threadPositionInGrid = u32x3 x y 0)
    (hR4 : 4 ≤ ctx.threadArray 0)
    (hown : ∀ j < 2 * per, dev per 2 (2 * (y * 5120 + x * per) + j) = some ⟨ctx.thread, ctx.group, 0⟩)
    (hdone : x = 0 → y = 0 → ctx.thread = 0 ∧ ctx.group = 0) {P : Nat} (hP : P = 0 → x = 0 ∧ y = 0)
    {l : Locals} {sh : Shared} (h0 : l 0 = some (.ptr ⟨0, 0, .scalar .u32⟩)) (h1 : l 1 = some (.ptr ⟨1, 0, .scalar .f16⟩))
    (h2 : l 2 = some (.ptr ⟨2, 0, .scalar .f16⟩)) (h3 : l 3 = some (.ptr ⟨3, 0, .scalar .i32⟩))
    (hm : Mem L per I (elem C bits base I.Codes I.S) (y * 5120 + x * per) P sh) :
    ∃ l' sh', Exec C ctx (pre rows per ++ .set 8 bw :: post bits per) l sh .normal l' sh' ∧
      Mem L per I (elem C bits base I.Codes I.S) (y * 5120 + x * per + per) (P + 1) sh' := by
  have hp4 : per % 4 = 0 ∧ 4 ≤ per ∧ per ≤ 16 := by rcases hper with rfl | rfl <;> decide
  -- slots 4 … 7
  have e4 : (eval C ctx l (.bin .mul .u32 0 (.component (.coord .threadPositionInGrid) (.lit (.int .u32 0)))
      (.lit (.int .u32 per)))).run sh = some (u32 (x * per), sh) :=
    eval_bin_u32 C (eval_coord0 C hpos) (eval_u32lit C _ _ per (by omega)) (binary_mul_u32 C x per)
  generalize hl₄ : setLocal l 4 (u32 (x * per)) = l₄
  have e5 : (eval C ctx l₄ (.component (.coord .threadPositionInGrid) (.lit (.int .u32 1)))).run sh = some (u32 y, sh) :=
    eval_coord1 C hpos
  generalize hl₅ : setLocal l₄ 5 (u32 y) = l₅
  have h54 : l₅ 4 = some (u32 (x * per)) := by rw [← hl₅, setLocal_other _ _ (by omega), ← hl₄, setLocal_same]
  have h55 : l₅ 5 = some (u32 y) := by rw [← hl₅, setLocal_same]
  have eg : (eval C ctx l₅ (.or (.bin .ge .u32 0 (.local 4) (.lit (.int .u32 5120)))
      (.bin .ge .u32 0 (.local 5) (.lit (.int .u32 rows))))).run sh = some (.bool false, sh) := by
    have g1 := eval_bin_u32 C (ctx := ctx) (op := .ge) (site := 0) (eval_local' C h54 sh) (eval_u32lit C l₅ sh 5120 (by decide))
      (binary_ge_u32 C (x * per) 5120 (by omega) (by decide))
    have g2 := eval_bin_u32 C (ctx := ctx) (op := .ge) (site := 0) (eval_local' C h55 sh) (eval_u32lit C l₅ sh rows (by omega))
      (binary_ge_u32 C y rows (by omega) (by omega))
    rw [decide_eq_false (show ¬ 5120 ≤ x * per by omega)] at g1
    rw [decide_eq_false (show ¬ rows ≤ y by omega)] at g2
    exact eval_or_false C g1 g2
  have e6 : (eval C ctx l₅ (.bin .div .u32 0 (.local 4) (.lit (.int .u32 256)))).run sh =
      some (u32 (x * per / 256), sh) :=
    eval_bin_u32 C (eval_local' C h54 sh) (eval_u32lit C _ _ 256 (by decide))
      (binary_div_u32 C _ 256 (by omega) (by decide) (by decide))
  generalize hl₆ : setLocal l₅ 6 (u32 (x * per / 256)) = l₆
  have e7 : (eval C ctx l₆ (.bin .rem .u32 0 (.local 4) (.lit (.int .u32 256)))).run sh =
      some (u32 (x * per % 256), sh) :=
    eval_bin_u32 C (eval_local' C (by rw [← hl₆, setLocal_other _ _ (by omega)]; exact h54) sh)
      (eval_u32lit C _ _ 256 (by decide)) (binary_rem_u32 C _ 256 (by omega) (by decide) (by decide))
  generalize hl₇ : setLocal l₆ 7 (u32 (x * per % 256)) = l₇
  have hpre : Exec C ctx (pre rows per) l sh .normal l₇ sh := by
    subst hl₄ hl₅ hl₆ hl₇
    exact .set e4 (.set e5 (.ite eg (.nil _ _) (.set e6 (.set e7 (.nil _ _)))))
  have f7 : ∀ j, j < 4 → l₇ j = l j := by
    intro j hj
    rw [← hl₇, setLocal_other _ _ (by omega), ← hl₆, setLocal_other _ _ (by omega), ← hl₅, setLocal_other _ _ (by omega),
      ← hl₄, setLocal_other _ _ (by omega)]
  have h74 : l₇ 4 = some (u32 (x * per)) := by
    rw [← hl₇, setLocal_other _ _ (by omega), ← hl₆, setLocal_other _ _ (by omega)]; exact h54
  have h75 : l₇ 5 = some (u32 y) := by
    rw [← hl₇, setLocal_other _ _ (by omega), ← hl₆, setLocal_other _ _ (by omega)]; exact h55
  have h76 : l₇ 6 = some (u32 (x * per / 256)) := by rw [← hl₇, setLocal_other _ _ (by omega), ← hl₆, setLocal_same]
  have h77 : l₇ 7 = some (u32 (x * per % 256)) := by rw [← hl₇, setLocal_same]
  -- slot 8: the block's words
  have e8 := hbw ctx l₇ sh y (x * per / 256) ((f7 0 (by omega)).trans h0) h75 h76 (by omega) (by omega)
  generalize hl₈ : setLocal l₇ 8 (.ptr ⟨0, ((4 * base y (x * per / 256) : Nat) : Int), .scalar .u32⟩) = l₈
  have g8 : ∀ j, j < 8 → l₈ j = l₇ j := fun j hj => by rw [← hl₈, setLocal_other _ _ (by omega)]
  -- slot 9: the scale
  have hp1 : (eval C ctx l₈ (.offset (.local 1) (.local 5))).run sh =
      some (.ptr ⟨1, ((2 * y : Nat) : Int), .scalar .f16⟩, sh) := by
    have := eval_offset_u32 C (ctx := ctx) (o := 0) (eval_local' C ((g8 1 (by omega)).trans ((f7 1 (by omega)).trans h1)) sh)
      (eval_local' C ((g8 5 (by omega)).trans h75) sh) (show y < 2 ^ 32 by omega)
    rwa [show 0 + y * (Ty.scalar .f16).bytes = 2 * y by show 0 + y * 2 = 2 * y; omega] at this
  have hl9 : (eval C ctx l₈ (.load (.scalar .f16) (.offset (.local 1) (.local 5)))).run sh =
      some (.f16 (Val.ofF16Bits (half I.S y)), rdn ctx sh 1 (2 * y) 2) := by
    rw [eval_load C _ _ _ _ _ _ _ hp1, load_shared ctx .f16 sh 1 (2 * y) ⟨.device, 34816, I.as⟩
      (by rw [hm.regions]; exact hS.r1) (by simp) (by show I.as % 2 = 0; exact hS.as) (by show 2 * y % 2 = 0; omega)
      (by show 2 * y + 2 ≤ 34816; omega) (by simp [loadOffset]), hm.scales]
    rfl
  have e9 := eval_conv C (t := .f32) (w := .f32 (scale I.S y)) hl9 rfl
  have hm₉ := hm.rd hS ctx 1 (2 * y) 2 (.inr rfl)
  generalize hs₉ : rdn ctx sh 1 (2 * y) 2 = sh₉ at e9 hm₉
  generalize hl₉ : setLocal l₈ 9 (.f32 (scale I.S y)) = l₉
  have g9 : ∀ j, j < 9 → l₉ j = l₈ j := fun j hj => by rw [← hl₉, setLocal_other _ _ (by omega)]
  -- slot 10: `out`
  have q2 : l₉ 2 = some (.ptr ⟨2, 0, .scalar .f16⟩) := by
    rw [g9 2 (by omega), g8 2 (by omega), f7 2 (by omega)]; exact h2
  have q5 : l₉ 5 = some (u32 y) := by rw [g9 5 (by omega), g8 5 (by omega)]; exact h75
  have q4 : l₉ 4 = some (u32 (x * per)) := by rw [g9 4 (by omega), g8 4 (by omega)]; exact h74
  have e10 : (eval C ctx l₉ (.ptrCast (.vec .f16 4) (.offset (.offset (.offset (.local 2) (.lit (.int .u64 0)))
      (.bin .mul .u64 0 (.conv .u64 (.local 5)) (.lit (.int .u64 5120)))) (.local 4)))).run sh₉ =
      some (.ptr ⟨2, ((2 * (y * 5120 + x * per) : Nat) : Int), .vec .f16 4⟩, sh₉) := by
    have a1 := eval_offset_u64 C (o := 0) (n := 0) (eval_local' C q2 sh₉)
      (show (eval C ctx l₉ (.lit (.int .u64 0))).run sh₉ = some (u64 0, sh₉) from rfl) (by decide)
    have a2 := eval_int C (op := .mul) (site := 0) (by decide)
      (eval_conv C (t := .u64) (eval_local' C q5 sh₉) (convert_u64_u32 C y (by omega)))
      (show (eval C ctx l₉ (.lit (.int .u64 5120))).run sh₉ = some (u64 5120, sh₉) from rfl) (binary_mul_u64 C y 5120)
    have a3 := eval_offset_u64 C a1 a2 (by omega)
    have a4 := eval_offset_u32 C a3 (eval_local' C q4 sh₉) (show x * per < 2 ^ 32 by omega)
    have a5 := eval_ptrCast C (t := .vec .f16 4) a4
    rw [show 0 + 0 * (Ty.scalar .f16).bytes + y * 5120 * (Ty.scalar .f16).bytes + x * per * (Ty.scalar .f16).bytes =
      2 * (y * 5120 + x * per) by show 0 + 0 * 2 + y * 5120 * 2 + x * per * 2 = _; omega] at a5
    exact a5
  generalize hl₁₀ : setLocal l₉ 10 (.ptr ⟨2, ((2 * (y * 5120 + x * per) : Nat) : Int), .vec .f16 4⟩) = l₁₀
  generalize hl₁₁ : setLocal l₁₀ 11 (u32 0) = l₁₁
  have hL₁₁ : Loc (x * per) y (base y (x * per / 256)) (scale I.S y) l₁₁ := by
    have g : ∀ j, j < 10 → l₁₁ j = l₉ j := fun j hj => by
      rw [← hl₁₁, setLocal_other _ _ (by omega), ← hl₁₀, setLocal_other _ _ (by omega)]
    refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · rw [g 0 (by omega), g9 0 (by omega), g8 0 (by omega), f7 0 (by omega)]; exact h0
    · rw [g 1 (by omega), g9 1 (by omega), g8 1 (by omega), f7 1 (by omega)]; exact h1
    · rw [g 2 (by omega)]; exact q2
    · rw [g 3 (by omega), g9 3 (by omega), g8 3 (by omega), f7 3 (by omega)]; exact h3
    · rw [g 4 (by omega)]; exact q4
    · rw [g 5 (by omega)]; exact q5
    · rw [g 6 (by omega), g9 6 (by omega), g8 6 (by omega)]; exact h76
    · rw [g 7 (by omega), g9 7 (by omega), g8 7 (by omega)]; exact h77
    · rw [g 8 (by omega), g9 8 (by omega), ← hl₈, setLocal_same]
    · rw [g 9 (by omega), ← hl₉, setLocal_same]
    · rw [← hl₁₁, setLocal_other _ _ (by omega), ← hl₁₀, setLocal_same]
  -- the quads
  obtain ⟨lq, shq, hloop, hLq, -, hmq⟩ := Exec.loop_count (C := C) (ctx := ctx)
    (c := .bin .lt .u32 0 (.local 11) (.lit (.int .u32 (per / 4))))
    (st := [.set 11 (.bin .add .u32 0 (.local 11) (.lit (.int .u32 1)))]) (b := AneTrellisFill.quad bits) (per / 4)
    (fun q l' sh' => Loc (x * per) y (base y (x * per / 256)) (scale I.S y) l' ∧ l' 11 = some (u32 q) ∧
      Mem L per I (elem C bits base I.Codes I.S) (y * 5120 + x * per + 4 * q) P sh')
    (fun q l' sh' => Loc (x * per) y (base y (x * per / 256)) (scale I.S y) l' ∧ l' 11 = some (u32 q) ∧
      Mem L per I (elem C bits base I.Codes I.S) (y * 5120 + x * per + 4 * q) P sh')
    (fun q hq l' sh' hI => ⟨sh', eval_lt_u32 C hI.2.1 (by omega) (by omega), hI⟩)
    (fun q hq l' sh' hJ => by
      obtain ⟨hLq, h11q, hmq⟩ := hJ
      obtain ⟨ht, hc4, hblk, hjs, hjo, hyq⟩ := quad_facts (y := y) hper hq hx
      have hq4 : y * 5120 + x * per + 4 * q + 4 ≤ I.nd :=
        Nat.le_trans hyq (Nat.le_trans (Nat.mul_le_mul_right 5120 hy) hnd)
      obtain ⟨l', sh', hex, hL', h11', hm'⟩ := exec_quad C (ctx := ctx) (E := y * 5120 + x * per + 4 * q) hS hK hR4
        hLq h11q ht (hbase y (Nat.lt_of_lt_of_le hy hrows) (x * per / 256) hblk) rfl hc4 hq4
        (fun j hj => elem_at C bits base I.Codes I.S (hjs j hj).1 (hjs j hj).2)
        (fun j hj => by
          have := hown (8 * q + j) (hjo j hj)
          rwa [show 2 * (y * 5120 + x * per) + (8 * q + j) = 2 * (y * 5120 + x * per + 4 * q) + j by ring] at this)
        hmq
      refine ⟨.normal, l', sh', setLocal l' 11 (u32 (q + 1)), sh', .inl rfl, hex,
        .set (eval_bin_u32 C (eval_local' C h11' sh') (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C q 1)) (.nil _ _),
        hL'.set _ (by decide), setLocal_same _ _ _, hm'.cast (by ring) rfl⟩)
    (l := l₁₁) (sh := sh₉) ⟨hL₁₁, by rw [← hl₁₁, setLocal_same], hm₉.cast (by omega) rfl⟩
  have hmq' := hmq.cast (E' := y * 5120 + x * per + per) (by omega) rfl
  -- `done`
  by_cases hz : x = 0 ∧ y = 0
  · have hc : (eval C ctx lq (.and (.bin .eq .u32 0 (.local 4) (.lit (.int .u32 0)))
        (.bin .eq .u32 0 (.local 5) (.lit (.int .u32 0))))).run shq = some (.bool true, shq) := by
      have a := eval_eq_u32 C (ctx := ctx) (sh := shq) (b := 0) hLq.l4 (by omega) (by decide)
      have b := eval_eq_u32 C (ctx := ctx) (sh := shq) (b := 0) hLq.l5 (by omega) (by decide)
      rw [decide_eq_true (show x * per = 0 by rw [hz.1, Nat.zero_mul])] at a
      rw [decide_eq_true hz.2] at b
      exact eval_and_true C a b
    have hp3 : (eval C ctx lq (.offset (.local 3) (.lit (.int .i32 0)))).run shq =
        some (.ptr ⟨3, ((0 : Nat) : Int), .scalar .i32⟩, shq) := by
      have := eval_offset_i32 C (o := 0) (n := 0) (eval_local' C hLq.l3 shq)
        (show (eval C ctx lq (.lit (.int .i32 0))).run shq = some (.int .i32 0, shq) from rfl) (by decide)
      rwa [show 0 + 0 * (Ty.scalar .i32).bytes = 0 from rfl] at this
    have hs3 := store_shared ctx .i32 shq 3 0 ⟨.device, 4, 16⟩ (.int .i32 1) (wordBytes 4 1)
      (by rw [hmq'.regions]; exact hS.r3) (by simp) (by simp) (by decide) (by decide) (by decide) rfl
    obtain ⟨ht0, hg0⟩ := hdone hz.1 hz.2
    refine ⟨lq, _, ?_, hmq'.wdone hS ctx ht0 hg0⟩
    subst hl₈ hl₉ hl₁₀ hl₁₁
    exact hpre.append (.set e8 (.set e9 (.set e10 (.set (eval_u32lit C _ _ 0 (by decide))
      (hloop.append (.ite hc (.store hp3 (eval_lit C _ _ _ _) hs3 (.nil _ _)) (.nil _ _)))))))
  · have hc : (eval C ctx lq (.and (.bin .eq .u32 0 (.local 4) (.lit (.int .u32 0)))
        (.bin .eq .u32 0 (.local 5) (.lit (.int .u32 0))))).run shq = some (.bool false, shq) := by
      have a := eval_eq_u32 C (ctx := ctx) (sh := shq) (b := 0) hLq.l4 (by omega) (by decide)
      by_cases hx0 : x * per = 0
      · have hx0' : x = 0 := by rcases Nat.mul_eq_zero.mp hx0 with h | h <;> omega
        have b := eval_eq_u32 C (ctx := ctx) (sh := shq) (b := 0) hLq.l5 (by omega) (by decide)
        rw [decide_eq_true hx0] at a
        rw [decide_eq_false (show ¬ y = 0 from fun h => hz ⟨hx0', h⟩)] at b
        exact eval_and_true C a b
      · rw [decide_eq_false hx0] at a
        exact eval_and_false C a
    have hP0 : 0 < P := Nat.pos_of_ne_zero fun h => hz (hP h)
    refine ⟨lq, shq, ?_, hmq'.bump hP0⟩
    subst hl₈ hl₉ hl₁₀ hl₁₁
    exact hpre.append (.set e8 (.set e9 (.set e10 (.set (eval_u32lit C _ _ 0 (by decide))
      (hloop.append (.ite hc (.nil _ _) (.nil _ _)))))))

/-- **A thread** `(x, y)`: the pointers, then its `PER` weights of row `y` from column `x·PER`, and `done` if it is
thread `(0, 0)`. -/
theorem lane_run (hS : Shape L bits I) (hK : Bits bits) (hper : per = 8 ∨ per = 16) {rows : Nat}
    (hrows : rows ≤ 17408) (hnd : rows * 5120 ≤ I.nd) {bw : CExpr} {base : Nat → Nat → Nat} (hbw : BwSpec C bw base)
    (hbase : ∀ y < 17408, ∀ blk < 20, base y blk + 8 * bits ≤ 17408 * 160 * bits)
    {x y : Nat} (hx : x * per < 5120) (hy : y < rows) (hpos : ctx.coord .threadPositionInGrid = u32x3 x y 0)
    (hR4 : 4 ≤ ctx.threadArray 0)
    (hown : ∀ j < 2 * per, dev per 2 (2 * (y * 5120 + x * per) + j) = some ⟨ctx.thread, ctx.group, 0⟩)
    (hdone : x = 0 → y = 0 → ctx.thread = 0 ∧ ctx.group = 0) {P : Nat} (hP : P = 0 → x = 0 ∧ y = 0) {sh : Shared}
    (hm : Mem L per I (elem C bits base I.Codes I.S) (y * 5120 + x * per) P sh) :
    ∃ l' sh', Exec C ctx (bodyWith rows bits per bw) (fun _ => none) sh .normal l' sh' ∧
      Mem L per I (elem C bits base I.Codes I.S) (y * 5120 + x * per + per) (P + 1) sh' := by
  obtain ⟨l', sh', hex, hm'⟩ := exec_inner C hS hK hper hrows hnd hbw hbase hx hy hpos hR4 hown hdone hP
    (l := setLocal (setLocal (setLocal (setLocal (fun _ => none) 0 (.ptr ⟨0, 0, .scalar .u32⟩)) 1
      (.ptr ⟨1, 0, .scalar .f16⟩)) 2 (.ptr ⟨2, 0, .scalar .f16⟩)) 3 (.ptr ⟨3, 0, .scalar .i32⟩)) rfl rfl rfl rfl hm
  exact ⟨l', sh', .set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _)
    (.set (eval_lit C _ _ _ _) (.scope hex (.inl rfl) (.nil _ _))))), hm'⟩

end Thread

/-! ### Threadgroups and the launch -/

section Group
variable (C : M1Max.Contract) {rows bits per : Nat} {bw : CExpr} {base : Nat → Nat → Nat} {I : In}
  {initial : Nat → ByteMemory.Bytes}

/-- Threadgroup `(bx, by)`: its `32 k` threads, thread-order positions `by·X + 128·bx + …`. -/
theorem group_run (hS : Shape (launch rows bits per bw I initial) bits I) (hK : Bits bits) (hper : per = 8 ∨ per = 16)
    (hrows : rows ≤ 17408) (hnd : rows * 5120 ≤ I.nd) (hbw : BwSpec C bw base)
    (hbase : ∀ y < 17408, ∀ blk < 20, base y blk + 8 * bits ≤ 17408 * 160 * bits) (fuse : Nat → Bool) {bx byy k : Nat}
    (hx : bx < ceilDiv (5120 / per) 128) (hy : byy < rows) (hk : min 128 (5120 / per - bx * 128) = 32 * k)
    {sh : Shared}
    (hm : Mem (launch rows bits per bw I initial) per I (elem C bits base I.Codes I.S)
      ((byy * (5120 / per) + bx * 128) * per) (byy * (5120 / per) + bx * 128) sh) :
    ∃ sh', (Ev fun m => (runGroup C m 1 1 (List.ofFn fun s : Fin k => List.ofFn fun i : Fin 32 =>
        (launch rows bits per bw I initial).start ((launch rows bits per bw I initial).ctxStrip fuse 128
          (ceilDiv (5120 / per) 128) rows bx byy (32 * k) (32 * s + i)))).run sh = some ((), sh')) ∧
      Mem (launch rows bits per bw I initial) per I (elem C bits base I.Codes I.S)
        ((byy * (5120 / per) + bx * 128 + 32 * k) * per) (byy * (5120 / per) + bx * 128 + 32 * k) sh' := by
  have hX : 32 * k ≤ 5120 / per - bx * 128 ∧ 32 * k ≤ 128 := by omega
  have hlane : ∀ (j : Fin k) (i : Fin 32) (sh : Shared),
      Mem (launch rows bits per bw I initial) per I (elem C bits base I.Codes I.S)
        ((byy * (5120 / per) + bx * 128 + 32 * j + i) * per) (byy * (5120 / per) + bx * 128 + 32 * j + i) sh →
      ∃ t sh', (Ev fun m => (runThread C m ((launch rows bits per bw I initial).start
          ((launch rows bits per bw I initial).ctxStrip fuse 128 (ceilDiv (5120 / per) 128) rows bx byy (32 * k)
            (32 * j + i)))).run sh = some (t, sh')) ∧
        Mem (launch rows bits per bw I initial) per I (elem C bits base I.Codes I.S)
          ((byy * (5120 / per) + bx * 128 + 32 * j + i + 1) * per) (byy * (5120 / per) + bx * 128 + 32 * j + i + 1) sh' ∧
        blocked t.status = true ∧ t.status = .done := by
    intro j i sh hi
    have hjv := j.isLt
    have hiv := i.isLt
    have hl : 32 * j.val + i.val < 32 * k := by omega
    have hsl := Launch.Strip.lane (L := launch rows bits per bw I initial) (tx := 128) fuse (ceilDiv (5120 / per) 128)
      rows bx byy (32 * k) (32 * j + i) hl
    have hxv : bx * 128 + (32 * j.val + i.val) < 5120 / per := by omega
    obtain ⟨l', sh', hex, hm'⟩ := lane_run C (ctx := (launch rows bits per bw I initial).ctxStrip fuse 128
        (ceilDiv (5120 / per) 128) rows bx byy (32 * k) (32 * j + i)) hS hK hper hrows hnd hbw hbase
      (x := bx * 128 + (32 * j + i)) (y := byy) (P := byy * (5120 / per) + bx * 128 + 32 * j + i)
      (by rcases hper with rfl | rfl <;> omega) hy hsl.pos
      (by rw [hsl.threadArray]; show 4 ≤ 4 + 0 + _ * 1 + 0; omega)
      (fun j' hj' => by
        rw [hsl.thread, hsl.group]
        unfold dev
        rw [ite_eq_left rfl]
        unfold tid gid
        rcases hper with rfl | rfl <;> simp only [ceilDiv] at hx ⊢ <;> congr 2 <;> omega)
      (fun hx0 hy0 => by
        rw [hsl.thread, hsl.group, hy0, Nat.zero_mul, Nat.add_zero]
        constructor <;> omega)
      (fun hP0 => by rcases hper with rfl | rfl <;> omega)
      (hi.cast (by rcases hper with rfl | rfl <;> omega) rfl)
    refine ⟨⟨_, l', [], .done⟩, sh', hex.reaches_done.ev_stop rfl, hm'.cast (by rcases hper with rfl | rfl <;> omega)
      (by omega), rfl, rfl⟩
  refine runGroup_done_ev C 1 0 (fun (s : Fin k) (i : Fin 32) => (launch rows bits per bw I initial).start
      ((launch rows bits per bw I initial).ctxStrip fuse 128 (ceilDiv (5120 / per) 128) rows bx byy (32 * k) (32 * s + i)))
    (fun j sh => Mem (launch rows bits per bw I initial) per I (elem C bits base I.Codes I.S)
      ((byy * (5120 / per) + bx * 128 + 32 * j) * per) (byy * (5120 / per) + bx * 128 + 32 * j) sh)
    (fun j sh hj => ?_) sh (hm.castP (by omega))
  obtain ⟨V, sh', hr, hI, hR⟩ := runSimd_blocked_ev C 0 _
    (fun i sh => Mem (launch rows bits per bw I initial) per I (elem C bits base I.Codes I.S)
      ((byy * (5120 / per) + bx * 128 + 32 * j + i) * per) (byy * (5120 / per) + bx * 128 + 32 * j + i) sh)
    (fun _ t => t.status = .done)
    (fun i sh hi => by
      obtain ⟨t, sh', ht, hm', hb, hd⟩ := hlane j i sh hi
      exact ⟨t, sh', ht, hm'.castP (by omega), hb, hd⟩)
    sh (hj.castP (by omega))
  exact ⟨V, sh', hr, hI.castP (by omega), hR⟩

/-- Threads before threadgroup `g` (`gx` threadgroups a row of `X` threads). -/
def cnt (per g : Nat) : Nat := g / ceilDiv (5120 / per) 128 * (5120 / per) + g % ceilDiv (5120 / per) 128 * 128

/-- **The launch**: every row's threads in order; `dst`'s first `rows · 5120` halves are the weights. -/
theorem launch_run (hS : Shape (launch rows bits per bw I initial) bits I) (hK : Bits bits) (hper : per = 8 ∨ per = 16)
    (hrows : 0 < rows ∧ rows ≤ 17408) (hnd : rows * 5120 ≤ I.nd) (hbw : BwSpec C bw base)
    (hbase : ∀ y < 17408, ∀ blk < 20, base y blk + 8 * bits ≤ 17408 * 160 * bits) (fuse : Nat → Bool)
    (garbage : Garbage) :
    ∃ sh, Mem (launch rows bits per bw I initial) per I (elem C bits base I.Codes I.S) (rows * 5120)
        (rows * (5120 / per)) sh ∧
      Ev fun m => runLaunch C fuse (launch rows bits per bw I initial) garbage m 1 1 = some ⟨sh.bytes, sh.log⟩ := by
  have hst : (launch rows bits per bw I initial).Strip 128 (5120 / per) rows :=
    ⟨rfl, rfl, by rcases hper with rfl | rfl <;> decide, ⟨by decide, hrows.1⟩, ⟨by decide, by rcases hper with rfl | rfl <;> decide⟩⟩
  have hb : (launch rows bits per bw I initial).buffers = buffers (bufs bits I) [4] 16 initial := rfl
  have h0 : Mem (launch rows bits per bw I initial) per I (elem C bits base I.Codes I.S) 0 0
      ((launch rows bits per bw I initial).initial garbage) :=
    ⟨rfl, initial_input hb garbage 0 (by simp [bufs]), initial_input hb garbage 1 (by simp [bufs]),
      by rw [initial_input hb garbage 2 (by simp [bufs])]; funext b; simp [halvesOver, bufs],
      fun h => absurd h (by omega), rfl, rfl, fun a ha => by simp [Launch.initial] at ha⟩
  obtain ⟨sh, hI, hr⟩ := Launch.Strip.launch_run_ev C hst fuse garbage 1 1
    (fun g sh => Mem (launch rows bits per bw I initial) per I (elem C bits base I.Codes I.S) (cnt per g * per)
      (cnt per g) sh)
    (h0.cast (by simp [cnt]) (by simp [cnt]))
    (fun bx byy k hx hy hk sh hI => by
      have hm := (hI.reset rfl garbage (bx + byy * ceilDiv (5120 / per) 128)).castP
        (P' := byy * (5120 / per) + bx * 128)
        (by unfold cnt; rcases hper with rfl | rfl <;> simp only [ceilDiv] at hx ⊢ <;> omega)
      obtain ⟨sh', hr, hm'⟩ := group_run C hS hK hper hrows.2 hnd hbw hbase fuse hx hy hk hm
      exact ⟨sh', hr, hm'.castP
        (by unfold cnt; rcases hper with rfl | rfl <;> simp only [ceilDiv] at hx hk ⊢ <;> omega)⟩)
  exact ⟨sh, hI.cast (by unfold cnt; rcases hper with rfl | rfl <;> simp only [ceilDiv] <;> omega)
    (by unfold cnt; rcases hper with rfl | rfl <;> simp only [ceilDiv] <;> omega), hr⟩

end Group

/-! ### The GPU -/

/-- The fill's stores into `dst`: its first `rows · 5120` halves, the weights (`WritesThrough`'s `stored`). -/
def fillStored (C : M1Max.Contract) (K rows : Nat) (base : Nat → Nat → Nat) (Codes S : ByteMemory.Bytes) (b : Nat) :
    Option (BitVec 8) :=
  if b < 2 * (rows * 5120) then some (halfByte (elem C K base Codes S (b / 2)) (b % 2)) else none

variable (C : M1Max.Contract)

/-- **The GPU runs a fill kernel as its source says**, for the core with code block address `bw` (word `base y blk`
of row `y`'s block `blk`). MLX's launch on codes (4-aligned: `uint` loads), scales (2-aligned) and `dst` (`nd ≥
rows·5120` halves, 8-aligned: `half4` stores) completes, `dst` holds the weights in its first `rows·5120` halves
and its previous bytes elsewhere, and `done` is 1. -/
theorem gpu_output_gen (rows bits per : Nat) (bw : CExpr) (base : Nat → Nat → Nat) (hK : Bits bits)
    (hper : per = 8 ∨ per = 16) (hrows : 0 < rows ∧ rows ≤ 17408) (hbw : BwSpec C bw base)
    (hbase : ∀ y < 17408, ∀ blk < 20, base y blk + 8 * bits ≤ 17408 * 160 * bits)
    (text : List Char) (hc : (frontend text).bind elaborate = some (coreWith rows bits per bw)) (G : Gpu C)
    (hmax : 128 ≤ G.maxThreads text) (Codes S D : ByteMemory.Bytes) (ac as ad nd : Nat) (hac : 4 ∣ ac) (has : 2 ∣ as)
    (had : 8 ∣ ad) (hnd : rows * 5120 ≤ nd) :
    ∃ res B, G.executeAll text (5120 / per, rows, 1) (128, 1, 1)
        [⟨.device, GateUp.codesBytes bits, ac, Codes⟩, ⟨.device, 34816, as, S⟩, ⟨.device, nd * 2, ad, D⟩] [4] = some res ∧
      res.length = 4 ∧ res[2]? = some B ∧ (∀ b, b < nd * 2 → B b = (fillStored C bits rows base Codes S b).getD (D b)) ∧
      res[3]? = some doneOut := by
  obtain ⟨res, hres, hlen, hall⟩ := gpu_owned_set C G (text := text) (kernel := coreWith rows bits per bw)
    (grid := (5120 / per, rows, 1)) (tg := (128, 1, 1)) (inputs := bufs bits ⟨Codes, S, D, ac, as, ad, nd⟩)
    (sizes := [4]) (fun i => i = 2 ∨ i = 3)
    (fun i => if i = 2 then halvesOver (elem C bits base Codes S) D (rows * 5120) else fun b => (wordBytes 4 1).getD b 0)
    hc (by simpa using hmax) (fun initial garbage => by
      have hS := launch_shape (rows := rows) (bits := bits) (per := per) (bw := bw) (I := ⟨Codes, S, D, ac, as, ad, nd⟩)
        (initial := initial) (Nat.mod_eq_zero_of_dvd hac) (Nat.mod_eq_zero_of_dvd has) (Nat.mod_eq_zero_of_dvd had)
      obtain ⟨sh, hm, n, hn⟩ := launch_run C hS hK hper hrows hnd hbw hbase (G.fusion text) garbage
      refine ⟨n, 1, 1, sh, dev per, tgo, hn n le_rfl, hm.log, ?_⟩
      rintro i (rfl | rfl) b hb
      · rw [hm.dst, ite_eq_left rfl]
      · rw [ite_eq_right (show ¬ (3 : Nat) = 2 by decide)]
        have hb4 : b < 4 := hb
        have hd := hm.done (by rcases hper with rfl | rfl <;> omega)
        have e := cells_getD (sh.bytes 3) 0 4 b hb4
        rw [hd, Nat.zero_add] at e
        exact e.symm)
  have h2 : 2 < res.length := by rw [hlen]; simp [bufs]
  have h3 : 3 < res.length := by rw [hlen]; simp [bufs]
  refine ⟨res, res[2], hres, by rw [hlen]; simp [bufs], List.getElem?_eq_getElem h2, fun b hb => ?_, ?_⟩
  · rw [hall 2 h2 (.inl rfl)]
    show (if b < nd * 2 then (if (2 : Nat) = 2 then halvesOver (elem C bits base Codes S) D (rows * 5120)
      else fun b => (wordBytes 4 1).getD b 0) b else 0) = _
    rw [ite_eq_left hb, ite_eq_left rfl]
    unfold halvesOver fillStored
    by_cases h : b < 2 * (rows * 5120) <;> simp [h]
  · rw [List.getElem?_eq_getElem h3, hall 3 h3 (.inr rfl)]
    congr 1
    funext b
    show (if b < 4 then (if (3 : Nat) = 2 then halvesOver (elem C bits base Codes S) D (rows * 5120)
      else fun b => (wordBytes 4 1).getD b 0) b else 0) = doneOut b
    rw [ite_eq_right (show ¬ (3 : Nat) = 2 by decide)]
    unfold doneOut
    by_cases hb : b < 4
    · rw [ite_eq_left hb]
    · rw [ite_eq_right hb, List.getD_eq_default _ _ (by rw [wordBytes_length]; omega)]

end Metal.Kernels.AneFill

/-! ## `mlx_bun_ane_trellis_fill`: row-major codes -/

namespace Metal.Kernels.AneFill
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

variable (C : M1Max.Contract)

/-- `bw = codes + (ulong)r·(C/BT)·wpb + block·wpb`: word `(20·r + block)·8K`. -/
theorem bw_rowMajor (bits : Nat) (hK : Bits bits) : BwSpec C (AneTrellisFill.blockWords bits) (rowMajor bits) := by
  intro ctx l sh y blk h0 h5 h6 hy hblk
  have hb5 : bits < 5 := by rcases hK with rfl | rfl | rfl <;> omega
  have hyb : y * 20 * (8 * bits) ≤ 17408 * 20 * (8 * 4) :=
    Nat.mul_le_mul (Nat.mul_le_mul_right 20 (by omega)) (Nat.mul_le_mul_left 8 (by omega))
  have hbb : blk * (8 * bits) ≤ 20 * (8 * 4) := Nat.mul_le_mul (by omega) (Nat.mul_le_mul_left 8 (by omega))
  have a1 : (eval C ctx l (.bin .mul .u64 0 (.bin .mul .u64 0 (.conv .u64 (.local 5)) (.lit (.int .u64 20)))
      (.lit (.int .u64 (8 * bits))))).run sh = some (u64 (y * 20 * (8 * bits)), sh) :=
    eval_int C (by decide) (eval_int C (by decide)
      (eval_conv C (t := .u64) (eval_local' C h5 sh) (convert_u64_u32 C y (by omega)))
      (show (eval C ctx l (.lit (.int .u64 20))).run sh = some (u64 20, sh) from rfl) (binary_mul_u64 C y 20))
      (show (eval C ctx l (.lit (.int .u64 (8 * bits)))).run sh = some (u64 (8 * bits), sh) by
        rw [← u64_lit (show 8 * bits < 2 ^ 64 by omega)]; rfl)
      (binary_mul_u64 C (y * 20) (8 * bits))
  have a2 := eval_offset_u64 C (o := 0) (eval_local' C h0 sh) a1 (show y * 20 * (8 * bits) < 2 ^ 64 by omega)
  have a3 : (eval C ctx l (.bin .mul .u32 0 (.local 6) (.lit (.int .u32 (8 * bits))))).run sh =
      some (u32 (blk * (8 * bits)), sh) :=
    eval_bin_u32 C (eval_local' C h6 sh) (eval_u32lit C _ _ (8 * bits) (by omega)) (binary_mul_u32 C blk (8 * bits))
  have a4 := eval_offset_u32 C a2 a3 (show blk * (8 * bits) < 2 ^ 32 by omega)
  rw [show 0 + y * 20 * (8 * bits) * (Ty.scalar .u32).bytes + blk * (8 * bits) * (Ty.scalar .u32).bytes =
    4 * rowMajor bits y blk by
      show 0 + y * 20 * (8 * bits) * 4 + blk * (8 * bits) * 4 = 4 * ((20 * y + blk) * (8 * bits)); ring] at a4
  exact a4

theorem rowMajor_bound {bits : Nat} (hK : Bits bits) :
    ∀ y < 17408, ∀ blk < 20, rowMajor bits y blk + 8 * bits ≤ 17408 * 160 * bits := by
  intro y hy blk hb
  unfold rowMajor
  rcases hK with rfl | rfl | rfl <;> omega

/-- **The GPU runs `mlx_bun_ane_trellis_fill` as its source says**, for code widths 2, 3, 4, 8 or 16 weights a
thread and any `rows ≤ R`, given that the text compiles to `core rows bits per`. MLX's launch on the row-major codes
(`uint32 [17408, 160·bits]`, 4-aligned: `uint` loads), the scales (`float16 [17408]`, 2-aligned) and `dst` (`nd ≥
rows·5120` halves, 8-aligned: `half4` stores) completes; `dst` holds `half(trellis_val_rcp(state)·scale)` of rows
`[0, rows)` row-major in its first `rows·5120` halves and its previous bytes elsewhere; `done` is 1. -/
theorem gpu_output_of (rows bits per : Nat) (hK : Bits bits) (hper : per = 8 ∨ per = 16)
    (hrows : 0 < rows ∧ rows ≤ 17408) (text : List Char)
    (hc : (frontend text).bind elaborate = some (AneTrellisFill.core rows bits per)) (G : Gpu C)
    (hmax : 128 ≤ G.maxThreads text) (Codes S D : ByteMemory.Bytes) (ac as ad nd : Nat) (hac : 4 ∣ ac) (has : 2 ∣ as)
    (had : 8 ∣ ad) (hnd : rows * 5120 ≤ nd) :
    ∃ res B, G.executeAll text (5120 / per, rows, 1) (128, 1, 1)
        [⟨.device, GateUp.codesBytes bits, ac, Codes⟩, ⟨.device, 34816, as, S⟩, ⟨.device, nd * 2, ad, D⟩] [4] = some res ∧
      res.length = 4 ∧ res[2]? = some B ∧
      (∀ b, b < nd * 2 → B b = (fillStored C bits rows (rowMajor bits) Codes S b).getD (D b)) ∧
      res[3]? = some doneOut :=
  gpu_output_gen C rows bits per _ (rowMajor bits) hK hper hrows (bw_rowMajor C bits hK) (rowMajor_bound hK) text
    (by rw [← core_eq]; exact hc) G hmax Codes S D ac as ad nd hac has had hnd

end Metal.Kernels.AneFill

namespace Metal.Kernels.AneTrellisFill
open Metal Inference.Contracts.Mlx Metal.Kernels.AneFill

/-! ### The route's instances

The ANE MLP split's weight fills (ane-prefill-split.ts:114-116): `ROWS` 6144 (fraction .353) or 6656 (.382), the
gate, up and row-major down codes at 2, 3 and 4 bits (`PER` 16, 16, 8; grid `[320, ROWS, 1]` or `[640, ROWS, 1]`).
Codes of width `K` are `17408·640·K` bytes; `dst` is the program's weight surface (`nd ≥ ROWS·5120` halves). -/

variable (C : M1Max.Contract) {Codes S D : ByteMemory.Bytes} {ac as ad nd : Nat}

theorem gpu_output_6144_2 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 6144 2 16)) (hac : 4 ∣ ac)
    (has : 2 ∣ as) (had : 8 ∣ ad) (hnd : 6144 * 5120 ≤ nd) :
    ∃ res B, G.executeAll (text 6144 2 16) (320, 6144, 1) (128, 1, 1)
        [⟨.device, 22282240, ac, Codes⟩, ⟨.device, 34816, as, S⟩, ⟨.device, nd * 2, ad, D⟩] [4] = some res ∧
      res.length = 4 ∧ res[2]? = some B ∧
      (∀ b, b < nd * 2 → B b = (fillStored C 2 6144 (rowMajor 2) Codes S b).getD (D b)) ∧
      res[3]? = some doneOut :=
  AneFill.gpu_output_of C 6144 2 16 (.inl rfl) (.inr rfl) ⟨by decide, by decide⟩ _ compile_6144_2 G hmax Codes
    S D ac as ad nd hac has had hnd

theorem gpu_output_6144_3 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 6144 3 16)) (hac : 4 ∣ ac)
    (has : 2 ∣ as) (had : 8 ∣ ad) (hnd : 6144 * 5120 ≤ nd) :
    ∃ res B, G.executeAll (text 6144 3 16) (320, 6144, 1) (128, 1, 1)
        [⟨.device, 33423360, ac, Codes⟩, ⟨.device, 34816, as, S⟩, ⟨.device, nd * 2, ad, D⟩] [4] = some res ∧
      res.length = 4 ∧ res[2]? = some B ∧
      (∀ b, b < nd * 2 → B b = (fillStored C 3 6144 (rowMajor 3) Codes S b).getD (D b)) ∧
      res[3]? = some doneOut :=
  AneFill.gpu_output_of C 6144 3 16 (.inr (.inl rfl)) (.inr rfl) ⟨by decide, by decide⟩ _ compile_6144_3 G hmax Codes
    S D ac as ad nd hac has had hnd

theorem gpu_output_6144_4 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 6144 4 8)) (hac : 4 ∣ ac)
    (has : 2 ∣ as) (had : 8 ∣ ad) (hnd : 6144 * 5120 ≤ nd) :
    ∃ res B, G.executeAll (text 6144 4 8) (640, 6144, 1) (128, 1, 1)
        [⟨.device, 44564480, ac, Codes⟩, ⟨.device, 34816, as, S⟩, ⟨.device, nd * 2, ad, D⟩] [4] = some res ∧
      res.length = 4 ∧ res[2]? = some B ∧
      (∀ b, b < nd * 2 → B b = (fillStored C 4 6144 (rowMajor 4) Codes S b).getD (D b)) ∧
      res[3]? = some doneOut :=
  AneFill.gpu_output_of C 6144 4 8 (.inr (.inr rfl)) (.inl rfl) ⟨by decide, by decide⟩ _ compile_6144_4 G hmax Codes
    S D ac as ad nd hac has had hnd

theorem gpu_output_6656_2 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 6656 2 16)) (hac : 4 ∣ ac)
    (has : 2 ∣ as) (had : 8 ∣ ad) (hnd : 6656 * 5120 ≤ nd) :
    ∃ res B, G.executeAll (text 6656 2 16) (320, 6656, 1) (128, 1, 1)
        [⟨.device, 22282240, ac, Codes⟩, ⟨.device, 34816, as, S⟩, ⟨.device, nd * 2, ad, D⟩] [4] = some res ∧
      res.length = 4 ∧ res[2]? = some B ∧
      (∀ b, b < nd * 2 → B b = (fillStored C 2 6656 (rowMajor 2) Codes S b).getD (D b)) ∧
      res[3]? = some doneOut :=
  AneFill.gpu_output_of C 6656 2 16 (.inl rfl) (.inr rfl) ⟨by decide, by decide⟩ _ compile_6656_2 G hmax Codes
    S D ac as ad nd hac has had hnd

theorem gpu_output_6656_3 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 6656 3 16)) (hac : 4 ∣ ac)
    (has : 2 ∣ as) (had : 8 ∣ ad) (hnd : 6656 * 5120 ≤ nd) :
    ∃ res B, G.executeAll (text 6656 3 16) (320, 6656, 1) (128, 1, 1)
        [⟨.device, 33423360, ac, Codes⟩, ⟨.device, 34816, as, S⟩, ⟨.device, nd * 2, ad, D⟩] [4] = some res ∧
      res.length = 4 ∧ res[2]? = some B ∧
      (∀ b, b < nd * 2 → B b = (fillStored C 3 6656 (rowMajor 3) Codes S b).getD (D b)) ∧
      res[3]? = some doneOut :=
  AneFill.gpu_output_of C 6656 3 16 (.inr (.inl rfl)) (.inr rfl) ⟨by decide, by decide⟩ _ compile_6656_3 G hmax Codes
    S D ac as ad nd hac has had hnd

theorem gpu_output_6656_4 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 6656 4 8)) (hac : 4 ∣ ac)
    (has : 2 ∣ as) (had : 8 ∣ ad) (hnd : 6656 * 5120 ≤ nd) :
    ∃ res B, G.executeAll (text 6656 4 8) (640, 6656, 1) (128, 1, 1)
        [⟨.device, 44564480, ac, Codes⟩, ⟨.device, 34816, as, S⟩, ⟨.device, nd * 2, ad, D⟩] [4] = some res ∧
      res.length = 4 ∧ res[2]? = some B ∧
      (∀ b, b < nd * 2 → B b = (fillStored C 4 6656 (rowMajor 4) Codes S b).getD (D b)) ∧
      res[3]? = some doneOut :=
  AneFill.gpu_output_of C 6656 4 8 (.inr (.inr rfl)) (.inl rfl) ⟨by decide, by decide⟩ _ compile_6656_4 G hmax Codes
    S D ac as ad nd hac has had hnd

end Metal.Kernels.AneTrellisFill

import metal.Logic
import metal.Launch
import metal.tests.Elab
import metal.Gpu
import metal.Steps
import metal.Group
import metal.Memory
import metal.Fuel

namespace Metal.Kernels.SiluRmsHeads
open Metal Metal.Core Inference.Contracts.Mlx

/-! # silu-rms-heads.ts

```
const uint lane = thread_index_in_simdgroup;
const uint head = threadgroup_position_in_grid.x;
const uint row = threadgroup_position_in_grid.y;
const bool normalize = head < uint(2 * HK);
const uint width = normalize ? uint(DK) : uint(DV);
const uint channel = normalize ? head * uint(DK)
  : uint(2 * HK * DK) + (head - uint(2 * HK)) * uint(DV);
T values[4];
float sum = 0.0f;
for (uint i = 0; i < 4u; ++i) {
  const uint col = lane * 4u + i;
  const T value = col < width ? x[row * uint(C) + channel + col] : T(0);
  const auto y = 1 / (1 + metal::exp(metal::abs(value)));
  const T sigmoid = T(value < T(0) ? y : 1 - y);
  values[i] = T(value * sigmoid);
  const float activated = float(values[i]);
  sum += activated * activated;
}
if (normalize) {
  sum = metal::simd_sum(sum);
  const float inv = metal::precise::rsqrt(sum / float(DK) + 1e-6f);
  const uint index = (row * uint(HK) + head % uint(HK)) * uint(DK) + lane * 4u;
  for (uint i = 0; i < 4u; ++i) {
    if (lane * 4u + i >= uint(DK)) continue;
    const T normalized = T(float(values[i]) * inv);
    if (head < uint(HK)) q[index + i] = qscale[lane * 4u + i] * normalized;
    else k[index + i] = kscale[lane * 4u + i] * normalized;
  }
} else {
  const uint index = (row * uint(HV) + head - uint(2 * HK)) * uint(DV) + lane * 4u;
  for (uint i = 0; i < 4u; ++i) if (lane * 4u + i < uint(DV)) v[index + i] = values[i];
}
```
at `headsConfig`: grid [2560, 1, 1], threadgroup [32, 1, 1], so 80 threadgroups of one SIMD-group (heads 0 … 31
are the q and k heads, 32 … 79 the v heads), with C = 10240, HK = 16, HV = 48, DK = DV = 128. -/

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)
def u16l (n : Nat) : CExpr := .lit (.int .u16 n)
def f32l (bits : Nat) : CExpr := .lit (.f32 (Val.ofF32Bits bits))
def bf16l (bits : Nat) : CExpr := .lit (.bf16 (Val.ofBf16Bits bits))

/-- `i < 4u` and `++i` for the loop counter in slot `i`. -/
def lt4 (i : Nat) : CExpr := .bin .lt .u32 0 (.local i) (u32l 4)
def inc (i : Nat) : List CStmt := [.set i (.bin .add .u32 0 (.local i) (u32l 1))]
/-- `lane * 4u + i` for the loop counter in slot `i`. -/
def laneCol (i : Nat) : CExpr := .bin .add .u32 0 (.bin .mul .u32 0 (.local 6) (u32l 4)) (.local i)

def channelExpr : CExpr :=
  .cond (.local 9) (.bin .mul .u32 0 (.local 7) (u32l 128))
    (.bin .add .u32 0 (u32l 4096) (.bin .mul .u32 0 (.bin .sub .u32 0 (.local 7) (u32l 32)) (u32l 128)))
def valueExpr : CExpr :=
  .cond (.bin .lt .u32 0 (.local 15) (.local 10))
    (.load (.scalar .bf16)
      (.offset (.local 0)
        (.bin .add .u32 0 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 8) (u32l 10240)) (.local 11)) (.local 15))))
    (bf16l 0x0)
def yExpr : CExpr :=
  .bin .div .bf16 0 (bf16l 0x3F80)
    (.bin .add .bf16 0 (bf16l 0x3F80)
      (.conv .bf16 (.un .fastExp .f32 (.conv .f32 (.conv .bf16 (.un .fastFabs .f32 (.conv .f32 (.local 16))))))))
def sigmoidExpr : CExpr :=
  .cond (.bin .lt .bf16 0 (.local 16) (bf16l 0x0)) (.local 17) (.bin .sub .bf16 0 (bf16l 0x3F80) (.local 17))
def activateBody : List CStmt :=
  [.set 15 (laneCol 14),
   .set 16 valueExpr,
   .set 17 yExpr,
   .set 18 sigmoidExpr,
   .store (.scalar .bf16) (.offset (.local 12) (.local 14)) (.bin .mul .bf16 0 (.local 16) (.local 18)),
   .set 19 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 12) (.local 14)))),
   .set 13 (.bin .add .f32 1 (.local 13) (.bin .mul .f32 0 (.local 19) (.local 19)))]
def activateLoop : CStmt := .loop (lt4 14) (inc 14) activateBody

def rsqrtExpr : CExpr :=
  .un .rsqrt .f32 (.bin .add .f32 0 (.conv .f32 (.bin .mul .f32 0 (.local 13) (f32l 0x3C000000))) (f32l 0x358637BD))
def qkIndex : CExpr :=
  .bin .add .u32 0
    (.bin .mul .u32 0
      (.bin .add .u32 0 (.bin .mul .u32 0 (.local 8) (u32l 16)) (.bin .rem .u32 0 (.local 7) (u32l 16))) (u32l 128))
    (.bin .mul .u32 0 (.local 6) (u32l 4))
def qkTarget : CExpr := .bin .add .u32 0 (.local 22) (.local 23)
def normalizedExpr : CExpr :=
  .conv .bf16 (.bin .mul .f32 0 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 12) (.local 23)))) (.local 21))
def qStore : List CStmt :=
  [.store (.scalar .bf16) (.offset (.local 3) qkTarget)
    (.bin .mul .bf16 0 (.load (.scalar .bf16) (.offset (.local 1) (laneCol 23))) (.local 24))]
def kStore : List CStmt :=
  [.store (.scalar .bf16) (.offset (.local 4) qkTarget)
    (.bin .mul .bf16 0 (.load (.scalar .bf16) (.offset (.local 2) (laneCol 23))) (.local 24))]
def padStmt : CStmt := .ite (.bin .ge .u32 0 (laneCol 23) (u32l 128)) [.continue_] []
def qkBody : List CStmt :=
  [padStmt, .set 24 normalizedExpr, .ite (.bin .lt .u32 0 (.local 7) (u32l 16)) qStore kStore]
def qkLoop : CStmt := .loop (lt4 23) (inc 23) qkBody
def normalizeBranch : List CStmt :=
  [.collective 2 20 .sum .f32 (.local 13) (u16l 0),
   .set 13 (.local 20),
   .set 21 rsqrtExpr,
   .set 22 qkIndex,
   .set 23 (u32l 0),
   qkLoop]

def vIndex : CExpr :=
  .bin .add .u32 0
    (.bin .mul .u32 0
      (.bin .sub .u32 0 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 8) (u32l 48)) (.local 7)) (u32l 32)) (u32l 128))
    (.bin .mul .u32 0 (.local 6) (u32l 4))
def vStore : List CStmt :=
  [.store (.scalar .bf16) (.offset (.local 5) (.bin .add .u32 0 (.local 25) (.local 26)))
    (.load (.scalar .bf16) (.offset (.local 12) (.local 26)))]
def vLoop : CStmt := .loop (lt4 26) (inc 26) [.ite (.bin .lt .u32 0 (laneCol 26) (u32l 128)) vStore []]
def valueBranch : List CStmt := [.set 25 vIndex, .set 26 (u32l 0), vLoop]

/-- Slots: 0 x, 1 qscale, 2 kscale, 3 q, 4 k, 5 v, 6 lane, 7 head, 8 row, 9 normalize, 10 width, 11 channel,
12 values (thread array 0), 13 sum, 14 i, 15 col, 16 value, 17 y, 18 sigmoid, 19 activated,
20 the `simd_sum` result, 21 inv, 22 index (normalize), 23 i, 24 normalized, 25 index (v), 26 i. -/
def body : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .bf16⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .bf16⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .bf16⟩)),
   .set 4 (.lit (.ptr ⟨4, 0, .scalar .bf16⟩)),
   .set 5 (.lit (.ptr ⟨5, 0, .scalar .bf16⟩)),
   .set 6 (.coord .threadIndexInSimdgroup),
   .set 7 (.component (.coord .threadgroupPositionInGrid) (u32l 0)),
   .set 8 (.component (.coord .threadgroupPositionInGrid) (u32l 1)),
   .set 9 (.bin .lt .u32 0 (.local 7) (u32l 32)),
   .set 10 (.cond (.local 9) (u32l 128) (u32l 128)),
   .set 11 channelExpr,
   .array 12 false 0 (.scalar .bf16),
   .set 13 (f32l 0x0),
   .set 14 (u32l 0),
   activateLoop,
   .ite (.local 9) normalizeBranch valueBranch]

def core : Kernel := ⟨6, [], [(.scalar .bf16, 4)], body⟩

-- The elaborated text MLX compiles (tests/Assemble.lean) is `core`.
kernel_rfl compile_eq : (frontend Metal.Elab.Tests.siluRmsHeadsText).bind elaborate = some core

/-! ## What the kernel computes -/

section Spec
variable (C : M1Max.Contract)

def bfOne : BF := Val.ofBf16Bits 0x3F80
def bfZero : BF := Val.ofBf16Bits 0x0

/-- `y = 1 / (1 + metal::exp(metal::abs(value)))`: `abs` and `exp` at binary32 with bf16 results, `+` and `/`
in bf16. -/
def expTerm (v : BF) : BF :=
  C.bfdiv bfOne (C.bfadd bfOne (C.narrow (C.fastExp (C.widen (C.narrow (C.fastFabs (C.widen v)))))))

/-- `value < T(0)`, the bf16 values compared as binary32. -/
def isNeg (v : BF) : Bool := decide (f32Compare (C.widen v) (C.widen bfZero) = some .lt)

/-- `sigmoid = T(value < T(0) ? y : 1 - y)`, `1 - y` in bf16. -/
def sigmoid (v : BF) : BF := if isNeg C v then expTerm C v else C.bfsub bfOne (expTerm C v)

/-- `values[i] = T(value * sigmoid)` (a bf16 product) at column `c` of head `h`, whose `value` is
`x[128 h + c]` (`channel = 128 h` for every head, `row = 0`). -/
def act (X : ByteMemory.Bytes) (h c : Nat) : BF :=
  C.bfmul (bfAt X (128 * h + c)) (sigmoid C (bfAt X (128 * h + c)))

/-- Lane `l`'s `sum` after its first `k` columns: `sum += activated * activated` at contraction site 1. -/
def laneSum (fuse : Nat → Bool) (X : ByteMemory.Bytes) (h l : Nat) : Nat → Float32
  | 0 => Val.ofF32Bits 0
  | k + 1 =>
    let a := C.widen (act C X h (4 * l + k))
    if fuse 1 then C.fma a a (laneSum fuse X h l k) else C.fadd (laneSum fuse X h l k) (C.fmul a a)

/-- `simd_sum(sum)` over the 32 lanes of head `h`. -/
def headSum (fuse : Nat → Bool) (X : ByteMemory.Bytes) (h : Nat) : Float32 :=
  C.simdSum fun l => laneSum C fuse X h l 4

/-- `inv = rsqrt(sum / float(DK) + 1e-6f)`, the division compiled as a product by 2^-7. -/
def invRms (fuse : Nat → Bool) (X : ByteMemory.Bytes) (h : Nat) : Float32 :=
  C.rsqrt (C.fadd (C.fmul (headSum C fuse X h) (Val.ofF32Bits 0x3C000000)) (Val.ofF32Bits 0x358637BD))

/-- `normalized = T(float(values[i]) * inv)` at column `c` of head `h`. -/
def normalized (fuse : Nat → Bool) (X : ByteMemory.Bytes) (h c : Nat) : BF :=
  C.narrow (C.fmul (C.widen (act C X h c)) (invRms C fuse X h))

/-- `q` element `e` (head `e / 128`, column `e % 128`): `qscale[c] * normalized`, a bf16 product. -/
def qOut (fuse : Nat → Bool) (X QS : ByteMemory.Bytes) (e : Nat) : BF :=
  C.bfmul (bfAt QS (e % 128)) (normalized C fuse X (e / 128) (e % 128))

/-- `k` element `e` (head `16 + e / 128`, column `e % 128`): `kscale[c] * normalized`. -/
def kOut (fuse : Nat → Bool) (X KS : ByteMemory.Bytes) (e : Nat) : BF :=
  C.bfmul (bfAt KS (e % 128)) (normalized C fuse X (16 + e / 128) (e % 128))

/-- `v` element `e` (head `32 + e / 128`, column `e % 128`): `values[i]`. -/
def vOut (X : ByteMemory.Bytes) (e : Nat) : BF := act C X (32 + e / 128) (e % 128)

/-- Byte `b` of an `n`-byte bf16 output with elements `f`: the little-endian bytes of `f (b / 2)`. -/
def bytesOf (n : Nat) (f : Nat → BF) (b : Nat) : BitVec 8 :=
  if b < n then (wordBytes 2 (Val.bf16Bits (f (b / 2)))).getD (b % 2) 0 else 0

end Spec

/-! ## A thread -/

section Thread
variable (C : M1Max.Contract) (fuse : Nat → Bool)

/-- Lane `l` of head `h` (its threadgroup). -/
structure Lane (ctx : Ctx) (h l : Nat) : Prop where
  lane : ctx.coord .threadIndexInSimdgroup = u32 l
  group : ctx.coord .threadgroupPositionInGrid = u32x3 h 0 0
  fuse : ctx.fuse = fuse
  hl : l < 32
  hh : h < 80

/-- The locals the code reads after its declarations. -/
structure Pre (ctx : Ctx) (h l : Nat) (L : Locals) : Prop where
  x : L 0 = some (.ptr ⟨0, 0, .scalar .bf16⟩)
  qs : L 1 = some (.ptr ⟨1, 0, .scalar .bf16⟩)
  ks : L 2 = some (.ptr ⟨2, 0, .scalar .bf16⟩)
  q : L 3 = some (.ptr ⟨3, 0, .scalar .bf16⟩)
  k : L 4 = some (.ptr ⟨4, 0, .scalar .bf16⟩)
  v : L 5 = some (.ptr ⟨5, 0, .scalar .bf16⟩)
  lane : L 6 = some (u32 l)
  head : L 7 = some (u32 h)
  row : L 8 = some (u32 0)
  norm : L 9 = some (.bool (decide (h < 32)))
  width : L 10 = some (.int .u32 128)
  chan : L 11 = some (u32 (128 * h))
  arr : L 12 = some (.ptr ⟨ctx.threadArray 0, 0, .scalar .bf16⟩)

theorem Pre.set {ctx : Ctx} {h l : Nat} {L : Locals} (hp : Pre ctx h l L) {slot : Nat} (v : Val) (hs : 13 ≤ slot) :
    Pre ctx h l (setLocal L slot v) :=
  ⟨(setLocal_other L v (by omega)).trans hp.x, (setLocal_other L v (by omega)).trans hp.qs,
    (setLocal_other L v (by omega)).trans hp.ks, (setLocal_other L v (by omega)).trans hp.q,
    (setLocal_other L v (by omega)).trans hp.k, (setLocal_other L v (by omega)).trans hp.v,
    (setLocal_other L v (by omega)).trans hp.lane, (setLocal_other L v (by omega)).trans hp.head,
    (setLocal_other L v (by omega)).trans hp.row, (setLocal_other L v (by omega)).trans hp.norm,
    (setLocal_other L v (by omega)).trans hp.width, (setLocal_other L v (by omega)).trans hp.chan,
    (setLocal_other L v (by omega)).trans hp.arr⟩

/-- The declarations before the activation loop. -/
def decls : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .bf16⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .bf16⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .bf16⟩)),
   .set 4 (.lit (.ptr ⟨4, 0, .scalar .bf16⟩)),
   .set 5 (.lit (.ptr ⟨5, 0, .scalar .bf16⟩)),
   .set 6 (.coord .threadIndexInSimdgroup),
   .set 7 (.component (.coord .threadgroupPositionInGrid) (u32l 0)),
   .set 8 (.component (.coord .threadgroupPositionInGrid) (u32l 1)),
   .set 9 (.bin .lt .u32 0 (.local 7) (u32l 32)),
   .set 10 (.cond (.local 9) (u32l 128) (u32l 128)),
   .set 11 channelExpr,
   .array 12 false 0 (.scalar .bf16),
   .set 13 (f32l 0x0),
   .set 14 (u32l 0)]

theorem body_eq : body = decls ++ [activateLoop, .ite (.local 9) normalizeBranch valueBranch] := rfl

variable {C fuse}

theorem decls_run {ctx : Ctx} {h l : Nat} (hc : Lane fuse ctx h l) (sh : Shared) :
    ∃ L, Exec C ctx decls (fun _ => none) sh .normal L sh ∧ Pre ctx h l L ∧
      L 13 = some (.f32 (Val.ofF32Bits 0)) ∧ L 14 = some (u32 0) := by
  have hh := hc.hh
  have e6 : ∀ L : Locals, (eval C ctx L (.coord .threadIndexInSimdgroup)).run sh = some (u32 l, sh) := fun L => by
    rw [eval_coord, hc.lane]
  have hg : ∀ L : Locals, (eval C ctx L (.coord .threadgroupPositionInGrid)).run sh =
      some (.vec .u32 [u32 h, u32 0, u32 0], sh) := fun L => by rw [eval_coord, hc.group]; rfl
  have e7 : ∀ L : Locals, (eval C ctx L (.component (.coord .threadgroupPositionInGrid) (u32l 0))).run sh =
      some (u32 h, sh) := fun L => eval_component C (hg L) (eval_lit C _ _ _ _) rfl rfl
  have e8 : ∀ L : Locals, (eval C ctx L (.component (.coord .threadgroupPositionInGrid) (u32l 1))).run sh =
      some (u32 0, sh) := fun L => eval_component C (hg L) (eval_lit C _ _ _ _) rfl rfl
  have e9 : ∀ L : Locals, L 7 = some (u32 h) →
      (eval C ctx L (.bin .lt .u32 0 (.local 7) (u32l 32))).run sh = some (.bool (decide (h < 32)), sh) :=
    fun L h7 => eval_int C (by decide) (eval_local C ctx L 7 _ h7 sh) (eval_lit C _ _ _ _)
      (binary_lt_u32 C h 32 (by omega) (by omega))
  have e11 : ∀ L : Locals, L 7 = some (u32 h) → L 9 = some (.bool (decide (h < 32))) →
      (eval C ctx L channelExpr).run sh = some (u32 (128 * h), sh) := by
    intro L h7 h9
    refine eval_cond C (eval_local C ctx L 9 _ h9 sh) ?_
    by_cases h32 : h < 32
    · rw [decide_eq_true h32]
      have : (eval C ctx L (.bin .mul .u32 0 (.local 7) (u32l 128))).run sh = some (u32 (h * 128), sh) :=
        eval_int C (by decide) (eval_local C ctx L 7 _ h7 sh) (eval_lit C _ _ _ _) (binary_mul_u32 C h 128)
      rw [Nat.mul_comm] at this
      exact this
    · rw [decide_eq_false h32]
      have : (eval C ctx L (.bin .add .u32 0 (u32l 4096) (.bin .mul .u32 0 (.bin .sub .u32 0 (.local 7) (u32l 32))
          (u32l 128)))).run sh = some (u32 (4096 + (h - 32) * 128), sh) :=
        eval_int C (by decide) (eval_lit C _ _ _ _) (eval_int C (by decide) (eval_int C (by decide)
        (eval_local C ctx L 7 _ h7 sh) (eval_lit C _ _ _ _) (binary_sub_u32 C h 32 (by omega))) (eval_lit C _ _ _ _)
        (binary_mul_u32 C (h - 32) 128)) (binary_add_u32 C 4096 ((h - 32) * 128))
      rw [show 4096 + (h - 32) * 128 = 128 * h by omega] at this
      exact this
  refine ⟨_, .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <|
    .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (e6 _) <|
    .set (e7 _) <| .set (e8 _) <| .set (e9 _ (by simp [setLocal])) <|
    .set (eval_cond_same C (eval_local C ctx _ 9 (.bool (decide (h < 32))) (by simp [setLocal]) sh) (eval_lit C _ _ _ _)) <|
    .set (e11 _ (by simp [setLocal]) (by simp [setLocal])) <| .array <| .set (eval_lit C _ _ _ _) <|
    .set (eval_lit C _ _ _ _) <| .nil _ _, ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩, ?_, ?_⟩ <;>
    simp [setLocal, u32]

end Thread

/-! ## Expressions -/

section Eval
variable (C : M1Max.Contract) {ctx : Ctx} {L : Locals} {sh : Shared}

theorem eval_laneCol {i ln k : Nat} (h6 : L 6 = some (u32 ln)) (hi : L i = some (u32 k)) :
    (eval C ctx L (laneCol i)).run sh = some (u32 (4 * ln + k), sh) := by
  have : (eval C ctx L (laneCol i)).run sh = some (u32 (ln * 4 + k), sh) :=
    eval_int C (by decide) (eval_int C (by decide) (eval_local C ctx L 6 _ h6 sh) (eval_lit C _ _ _ _)
      (binary_mul_u32 C ln 4)) (eval_local C ctx L i _ hi sh) (binary_add_u32 C (ln * 4) k)
  rwa [Nat.mul_comm ln 4] at this

theorem eval_lt4 {i k : Nat} (hi : L i = some (u32 k)) (hk : k < 2 ^ 32) :
    (eval C ctx L (lt4 i)).run sh = some (.bool (decide (k < 4)), sh) :=
  eval_int C (by decide) (eval_local C ctx L i _ hi sh) (eval_lit C _ _ _ _) (binary_lt_u32 C k 4 hk (by decide))

theorem exec_inc {i k : Nat} (hi : L i = some (u32 k)) :
    Exec C ctx (inc i) L sh .normal (setLocal L i (u32 (k + 1))) sh :=
  .set (eval_int C (by decide) (eval_local C ctx L i _ hi sh) (eval_lit C _ _ _ _) (binary_add_u32 C k 1)) (.nil _ _)

theorem eval_value {h l k ax : Nat} {X : ByteMemory.Bytes} (hp : Pre ctx h l L)
    (h15 : L 15 = some (u32 (4 * l + k))) (hk : 4 * l + k < 128) (hh : h < 80)
    (r0 : sh.regions 0 = some ⟨.device, 20480, ax⟩) (hax : 2 ∣ ax) (hx : sh.bytes 0 = X) :
    (eval C ctx L valueExpr).run sh =
      some (.bf16 (bfAt X (128 * h + (4 * l + k))), logged2 ctx sh 0 (128 * h + (4 * l + k)) false) := by
  have hlt : (eval C ctx L (.bin .lt .u32 0 (.local 15) (.local 10))).run sh = some (.bool true, sh) := by
    have : (eval C ctx L (.bin .lt .u32 0 (.local 15) (.local 10))).run sh =
        some (.bool (decide (4 * l + k < 128)), sh) :=
      eval_int C (by decide) (eval_local C ctx L 15 _ h15 sh) (eval_local C ctx L 10 _ hp.width sh)
        (binary_lt_u32 C (4 * l + k) 128 (by omega) (by omega))
    rwa [decide_eq_true hk] at this
  have hidx : (eval C ctx L (.bin .add .u32 0 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 8) (u32l 10240))
      (.local 11)) (.local 15))).run sh = some (u32 (128 * h + (4 * l + k)), sh) := by
    have : (eval C ctx L (.bin .add .u32 0 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 8) (u32l 10240))
        (.local 11)) (.local 15))).run sh = some (u32 (0 * 10240 + 128 * h + (4 * l + k)), sh) :=
      eval_int C (by decide) (eval_int C (by decide) (eval_int C (by decide) (eval_local C ctx L 8 _ hp.row sh)
        (eval_lit C _ _ _ _) (binary_mul_u32 C 0 10240)) (eval_local C ctx L 11 _ hp.chan sh)
        (binary_add_u32 C (0 * 10240) (128 * h))) (eval_local C ctx L 15 _ h15 sh)
        (binary_add_u32 C (0 * 10240 + 128 * h) (4 * l + k))
    rwa [Nat.zero_mul, Nat.zero_add] at this
  exact eval_cond C hlt ((eval_load C _ _ _ _ _ _ _ (eval_bf16_base C (eval_local C ctx L 0 _ hp.x sh) hidx
    (by omega))).trans (load_bf16_elem ctx sh 0 _ _ X r0 (.inl rfl) hax (show _ ≤ 20480 by omega) hx))

theorem eval_y {v : BF} (h16 : L 16 = some (.bf16 v)) :
    (eval C ctx L yExpr).run sh = some (.bf16 (expTerm C v), sh) :=
  eval_bin C (nf_bf16 _) (eval_lit C _ _ _ _) (eval_bin C (nf_bf16 _) (eval_lit C _ _ _ _)
    (eval_conv C (eval_un C (eval_conv C (eval_conv C (eval_un C (eval_conv C (eval_local C ctx L 16 _ h16 sh) rfl)
      rfl) rfl) rfl) rfl) rfl) rfl) rfl

theorem eval_sigmoid {v : BF} (h16 : L 16 = some (.bf16 v)) (h17 : L 17 = some (.bf16 (expTerm C v))) :
    (eval C ctx L sigmoidExpr).run sh = some (.bf16 (sigmoid C v), sh) := by
  have hc : (eval C ctx L (.bin .lt .bf16 0 (.local 16) (bf16l 0x0))).run sh = some (.bool (isNeg C v), sh) :=
    eval_bin C (nf_bf16 _) (eval_local C ctx L 16 _ h16 sh) (eval_lit C _ _ _ _) (binary_lt_bf16 C v bfZero)
  refine eval_cond C hc ?_
  unfold sigmoid
  cases isNeg C v
  · exact eval_bin C (nf_bf16 _) (eval_lit C _ _ _ _) (eval_local C ctx L 17 _ h17 sh) rfl
  · exact eval_local C ctx L 17 _ h17 sh

end Eval

/-! ## The activation loop -/

section Act
variable (C : M1Max.Contract) (fuse : Nat → Bool)

/-- Memory after `k` iterations of the activation loop: the `x` loads logged2, `values[0 … k-1]` stored. -/
def actMem (ctx : Ctx) (X : ByteMemory.Bytes) (h l : Nat) (sh : Shared) : Nat → Shared
  | 0 => sh
  | k + 1 => written2 (logged2 ctx (actMem ctx X h l sh k) 0 (128 * h + (4 * l + k)) false) (ctx.threadArray 0) k
      (act C X h (4 * l + k))

variable {C} {ctx : Ctx} {X : ByteMemory.Bytes} {h l : Nat} {sh : Shared}

theorem actMem_regions : ∀ k, (actMem C ctx X h l sh k).regions = sh.regions
  | 0 => rfl
  | k + 1 => actMem_regions k

theorem actMem_epochs : ∀ k, (actMem C ctx X h l sh k).deviceEpoch = sh.deviceEpoch ∧
    (actMem C ctx X h l sh k).groupEpoch = sh.groupEpoch
  | 0 => ⟨rfl, rfl⟩
  | k + 1 => actMem_epochs k

theorem actMem_succ_bytes (k r : Nat) : (actMem C ctx X h l sh (k + 1)).bytes r =
    if r = ctx.threadArray 0 then
      writeBytes ((actMem C ctx X h l sh k).bytes r) (2 * k) (wordBytes 2 (Val.bf16Bits (act C X h (4 * l + k))))
    else (actMem C ctx X h l sh k).bytes r := rfl

theorem actMem_bytes {r : Nat} (hr : r ≠ ctx.threadArray 0) : ∀ k, (actMem C ctx X h l sh k).bytes r = sh.bytes r
  | 0 => rfl
  | k + 1 => by rw [actMem_succ_bytes, ite_eq_right hr]; exact actMem_bytes hr k

/-- `values[j]` holds column `4 l + j`'s activation, for each stored `j`. -/
theorem actMem_arr : ∀ k, ∀ j < k, ∀ i < 2, (actMem C ctx X h l sh k).bytes (ctx.threadArray 0) (2 * j + i) =
    (wordBytes 2 (Val.bf16Bits (act C X h (4 * l + j)))).getD i 0
  | 0, j, hj, _, _ => absurd hj (by omega)
  | k + 1, j, hj, i, hi => by
    rw [actMem_succ_bytes, ite_eq_left rfl]
    rcases Nat.lt_succ_iff_lt_or_eq.mp hj with hj | rfl
    · rw [writeBytes_outside _ _ _ _ (.inl (by omega))]; exact actMem_arr k j hj i hi
    · exact writeBytes_inside _ _ _ i (by rw [wordBytes_length]; exact hi)

/-- The loop's log entries are reads of `x`. -/
theorem actMem_log : ∀ k, ∀ e ∈ (actMem C ctx X h l sh k).log, e ∈ sh.log ∨
    (e.region = 0 ∧ e.write = false ∧ e.deviceEpoch = sh.deviceEpoch)
  | 0, e, he => .inl he
  | k + 1, e, he => by
    simp only [actMem, written2, logged2, List.mem_append, List.mem_reverse, List.mem_map, List.mem_range] at he
    rcases he with ⟨i, _, rfl⟩ | he
    · exact .inr ⟨rfl, rfl, (actMem_epochs k).1⟩
    · exact actMem_log k e he

variable {fuse}

/-- One iteration: column `4 l + k` loaded, activated, stored to `values[k]`, read back and squared into `sum`. -/
theorem act_body (hc : Lane fuse ctx h l) {ax : Nat} (r0 : sh.regions 0 = some ⟨.device, 20480, ax⟩) (hax : 2 ∣ ax)
    (ra : sh.regions (ctx.threadArray 0) = some ⟨.thread, 8, 2⟩) (ha0 : ctx.threadArray 0 ≠ 0)
    (hx : sh.bytes 0 = X) (k : Nat) (hk : k < 4) (L : Locals) (hp : Pre ctx h l L) (h14 : L 14 = some (u32 k))
    (h13 : L 13 = some (.f32 (laneSum C fuse X h l k))) :
    ∃ L₁, Exec C ctx activateBody L (actMem C ctx X h l sh k) .normal L₁ (actMem C ctx X h l sh (k + 1)) ∧
      Pre ctx h l L₁ ∧ L₁ 14 = some (u32 k) ∧ L₁ 13 = some (.f32 (laneSum C fuse X h l (k + 1))) := by
  have hl := hc.hl; have hh := hc.hh
  have pr : (actMem C ctx X h l sh k).regions = sh.regions := actMem_regions k
  have px : (actMem C ctx X h l sh k).bytes 0 = X := (actMem_bytes (Ne.symm ha0) k).trans hx
  generalize hS0 : actMem C ctx X h l sh k = S0 at pr px
  generalize hS1 : logged2 ctx S0 0 (128 * h + (4 * l + k)) false = S1
  have e15 : (eval C ctx L (laneCol 14)).run S0 = some (u32 (4 * l + k), S0) := eval_laneCol C hp.lane h14
  generalize hL1 : setLocal L 15 (u32 (4 * l + k)) = L1
  have hp1 : Pre ctx h l L1 := hL1 ▸ hp.set _ (by decide)
  have e16 : (eval C ctx L1 valueExpr).run S0 = some (.bf16 (bfAt X (128 * h + (4 * l + k))), S1) :=
    hS1 ▸ eval_value C hp1 (by rw [← hL1]; exact setLocal_same _ _ _) (by omega) hh (by rw [pr]; exact r0) hax px
  generalize hv : bfAt X (128 * h + (4 * l + k)) = v at e16
  have e17 : (eval C ctx (setLocal L1 16 (.bf16 v)) yExpr).run S1 = some (.bf16 (expTerm C v), S1) :=
    eval_y C (setLocal_same _ _ _)
  have e18 : (eval C ctx (setLocal (setLocal L1 16 (.bf16 v)) 17 (.bf16 (expTerm C v))) sigmoidExpr).run S1 =
      some (.bf16 (sigmoid C v), S1) := eval_sigmoid C (by simp [setLocal]) (setLocal_same _ _ _)
  generalize hL4 : setLocal (setLocal (setLocal L1 16 (.bf16 v)) 17 (.bf16 (expTerm C v))) 18
    (.bf16 (sigmoid C v)) = L4
  have hp4 : Pre ctx h l L4 := hL4 ▸ ((hp1.set _ (by decide)).set _ (by decide)).set _ (by decide)
  have h14' : L4 14 = some (u32 k) := by rw [← hL4, ← hL1]; simp [setLocal, h14]
  have hact : C.bfmul v (sigmoid C v) = act C X h (4 * l + k) := by rw [← hv]; rfl
  have hptr : ∀ S : Shared, (eval C ctx L4 (.offset (.local 12) (.local 14))).run S =
      some (.ptr ⟨ctx.threadArray 0, ((2 * k : Nat) : Int), .scalar .bf16⟩, S) := fun S =>
    eval_bf16_base C (eval_local C ctx _ 12 _ hp4.arr _) (eval_local C ctx _ 14 _ h14' _) (by omega)
  have hval : (eval C ctx L4 (.bin .mul .bf16 0 (.local 16) (.local 18))).run S1 =
      some (.bf16 (act C X h (4 * l + k)), S1) :=
    eval_bin C (nf_bf16 _) (eval_local C ctx _ 16 (.bf16 v) (by rw [← hL4]; simp [setLocal]) _)
      (eval_local C ctx _ 18 _ (by rw [← hL4]; exact setLocal_same _ _ _) _) (by rw [← hact]; rfl)
  have S1r : S1.regions (ctx.threadArray 0) = some ⟨.thread, 8, 2⟩ := by rw [← hS1, ← ra, ← pr]; rfl
  have hst := store_bf16_thread ctx S1 (ctx.threadArray 0) k 8 (act C X h (4 * l + k)) S1r (by omega)
  have hS2 : written2 S1 (ctx.threadArray 0) k (act C X h (4 * l + k)) = actMem C ctx X h l sh (k + 1) := by
    rw [← hS1, ← hS0]; rfl
  rw [hS2] at hst
  have e19 : (eval C ctx L4 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 12) (.local 14))))).run
      (actMem C ctx X h l sh (k + 1)) =
      some (.f32 (C.widen (act C X h (4 * l + k))), actMem C ctx X h l sh (k + 1)) := by
    refine eval_conv C ((eval_load C _ _ _ _ _ _ _ (hptr _)).trans
      (load_bf16_thread ctx _ (ctx.threadArray 0) k 8 (act C X h (4 * l + k))
        (by rw [actMem_regions]; exact ra) (by omega) (fun i hi => ?_))) rfl
    rw [actMem_succ_bytes, ite_eq_left rfl]
    exact writeBytes_inside _ _ _ i (by rw [wordBytes_length]; exact hi)
  have e13 : (eval C ctx (setLocal L4 19 (.f32 (C.widen (act C X h (4 * l + k)))))
      (.bin .add .f32 1 (.local 13) (.bin .mul .f32 0 (.local 19) (.local 19)))).run (actMem C ctx X h l sh (k + 1)) =
      some (.f32 (laneSum C fuse X h l (k + 1)), actMem C ctx X h l sh (k + 1)) := by
    have := eval_add_mul C (ctx := ctx) (sh := actMem C ctx X h l sh (k + 1)) (site := 1) (m := 0) (x := .local 19) (y := .local 19) (z := .local 13) rfl
      (eval_local C ctx (setLocal L4 19 (.f32 (C.widen (act C X h (4 * l + k))))) 19 _ (setLocal_same _ _ _) _)
      (eval_local C ctx (setLocal L4 19 (.f32 (C.widen (act C X h (4 * l + k))))) 19 _ (setLocal_same _ _ _) _)
      (eval_local C ctx (setLocal L4 19 (.f32 (C.widen (act C X h (4 * l + k))))) 13 (.f32 (laneSum C fuse X h l k))
        (by rw [← hL4, ← hL1]; simp [setLocal, h13]) _)
    rw [hc.fuse] at this
    exact this
  subst hL1 hL4 hS0
  refine ⟨_, .set e15 (.set e16 (.set e17 (.set e18 (.store (hptr _) hval hst (.set e19 (.set e13 (.nil _ _))))))),
    hp4.set _ (by decide) |>.set _ (by decide), by simp [setLocal, h14], by simp [setLocal]⟩

end Act

/-! ## Loops and threads -/

section Loops
variable {C : M1Max.Contract} {fuse : Nat → Bool} {ctx : Ctx} {X : ByteMemory.Bytes} {h l : Nat} {sh : Shared}

/-- The activation loop: four columns. -/
theorem act_loop (hc : Lane fuse ctx h l) {ax : Nat} (r0 : sh.regions 0 = some ⟨.device, 20480, ax⟩) (hax : 2 ∣ ax)
    (ra : sh.regions (ctx.threadArray 0) = some ⟨.thread, 8, 2⟩) (ha0 : ctx.threadArray 0 ≠ 0)
    (hx : sh.bytes 0 = X) (L : Locals) (hp : Pre ctx h l L) (h14 : L 14 = some (u32 0))
    (h13 : L 13 = some (.f32 (Val.ofF32Bits 0))) :
    ∃ L', Exec C ctx [activateLoop] L sh .normal L' (actMem C ctx X h l sh 4) ∧ Pre ctx h l L' ∧
      L' 13 = some (.f32 (laneSum C fuse X h l 4)) := by
  obtain ⟨L', sh', hex, hp', -, h13', rfl⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := lt4 14) (st := inc 14)
    (b := activateBody) 4
    (fun k L s => Pre ctx h l L ∧ L 14 = some (u32 k) ∧ L 13 = some (.f32 (laneSum C fuse X h l k)) ∧
      s = actMem C ctx X h l sh k)
    (fun k L s => Pre ctx h l L ∧ L 14 = some (u32 k) ∧ L 13 = some (.f32 (laneSum C fuse X h l k)) ∧
      s = actMem C ctx X h l sh k)
    (fun k hk L s hI => ⟨s, eval_lt4 C hI.2.1 (by omega), hI⟩)
    (fun k hk L s hI => by
      obtain ⟨hp, h14, h13, rfl⟩ := hI
      obtain ⟨L₁, hb, hp₁, h14₁, h13₁⟩ := act_body hc r0 hax ra ha0 hx k hk L hp h14 h13
      exact ⟨.normal, L₁, _, _, _, .inl rfl, hb, exec_inc C h14₁, hp₁.set _ (by decide), by simp [setLocal],
        by simp [setLocal, h13₁], rfl⟩)
    ⟨hp, h14, h13, rfl⟩
  exact ⟨L', hex, hp', h13'⟩

/-- Memory after `k` iterations of the q/k loop of lane `l`: `scale[4 l + j]` read, then `out[base + j]`
written2 with `vals j`, for each `j < k`. -/
def qkMem (ctx : Ctx) (out sc base l : Nat) (vals : Nat → BF) (sh : Shared) : Nat → Shared
  | 0 => sh
  | k + 1 => written2 (logged2 ctx (logged2 ctx (qkMem ctx out sc base l vals sh k) sc (4 * l + k) false) out (base + k)
      true) out (base + k) (vals k)

/-- Memory after `k` iterations of the v loop: `v[base + j]` written2 with `vals j`, for each `j < k`. -/
def vMem (ctx : Ctx) (base : Nat) (vals : Nat → BF) (sh : Shared) : Nat → Shared
  | 0 => sh
  | k + 1 => written2 (logged2 ctx (vMem ctx base vals sh k) 5 (base + k) true) 5 (base + k) (vals k)

theorem qkMem_regions {out sc base : Nat} {vals : Nat → BF} :
    ∀ k, (qkMem ctx out sc base l vals sh k).regions = sh.regions
  | 0 => rfl
  | k + 1 => qkMem_regions k

theorem vMem_regions {base : Nat} {vals : Nat → BF} : ∀ k, (vMem ctx base vals sh k).regions = sh.regions
  | 0 => rfl
  | k + 1 => vMem_regions k

theorem qkMem_bytes {out sc base : Nat} {vals : Nat → BF} {r : Nat} (hr : r ≠ out) :
    ∀ k, (qkMem ctx out sc base l vals sh k).bytes r = sh.bytes r
  | 0 => rfl
  | k + 1 => by
    show (if r = out then _ else _) = _
    rw [ite_eq_right hr]; exact qkMem_bytes hr k

theorem vMem_bytes {base : Nat} {vals : Nat → BF} {r : Nat} (hr : r ≠ 5) :
    ∀ k, (vMem ctx base vals sh k).bytes r = sh.bytes r
  | 0 => rfl
  | k + 1 => by
    show (if r = 5 then _ else _) = _
    rw [ite_eq_right hr]; exact vMem_bytes hr k

/-- `qkIndex`: `(row * HK + head % HK) * DK + lane * 4`. -/
theorem eval_qkIndex {L : Locals} (hp : Pre ctx h l L) (hh : h < 80) :
    (eval C ctx L qkIndex).run sh = some (u32 (128 * (h % 16) + 4 * l), sh) := by
  have : (eval C ctx L qkIndex).run sh = some (u32 ((0 * 16 + h % 16) * 128 + l * 4), sh) :=
    eval_int C (by decide) (eval_int C (by decide) (eval_int C (by decide) (eval_int C (by decide)
      (eval_local C ctx L 8 _ hp.row sh) (eval_lit C _ _ _ _) (binary_mul_u32 C 0 16))
      (eval_int C (by decide) (eval_local C ctx L 7 _ hp.head sh) (eval_lit C _ _ _ _)
        (binary_rem_u32 C h 16 (by omega) (by omega) (by omega))) (binary_add_u32 C (0 * 16) (h % 16)))
      (eval_lit C _ _ _ _) (binary_mul_u32 C (0 * 16 + h % 16) 128))
      (eval_int C (by decide) (eval_local C ctx L 6 _ hp.lane sh) (eval_lit C _ _ _ _) (binary_mul_u32 C l 4))
      (binary_add_u32 C ((0 * 16 + h % 16) * 128) (l * 4))
  rwa [show (0 * 16 + h % 16) * 128 + l * 4 = 128 * (h % 16) + 4 * l by ring] at this

/-- `vIndex`: `(row * HV + head - 2 HK) * DV + lane * 4`. -/
theorem eval_vIndex {L : Locals} (hp : Pre ctx h l L) (h32 : 32 ≤ h) (hh : h < 80) :
    (eval C ctx L vIndex).run sh = some (u32 (128 * (h - 32) + 4 * l), sh) := by
  have : (eval C ctx L vIndex).run sh = some (u32 ((0 * 48 + h - 32) * 128 + l * 4), sh) :=
    eval_int C (by decide) (eval_int C (by decide) (eval_int C (by decide) (eval_int C (by decide)
      (eval_int C (by decide) (eval_local C ctx L 8 _ hp.row sh) (eval_lit C _ _ _ _) (binary_mul_u32 C 0 48))
      (eval_local C ctx L 7 _ hp.head sh) (binary_add_u32 C (0 * 48) h)) (eval_lit C _ _ _ _)
      (binary_sub_u32 C (0 * 48 + h) 32 (by omega))) (eval_lit C _ _ _ _) (binary_mul_u32 C (0 * 48 + h - 32) 128))
      (eval_int C (by decide) (eval_local C ctx L 6 _ hp.lane sh) (eval_lit C _ _ _ _) (binary_mul_u32 C l 4))
      (binary_add_u32 C ((0 * 48 + h - 32) * 128) (l * 4))
  rwa [show (0 * 48 + h - 32) * 128 + l * 4 = 128 * (h - 32) + 4 * l by omega] at this

/-- `values[j]` holds column `4 l + j`'s activation. -/
def Holds (C : M1Max.Contract) (X : ByteMemory.Bytes) (h l : Nat) (M : ByteMemory.Bytes) : Prop :=
  ∀ j < 4, ∀ i < 2, M (2 * j + i) = (wordBytes 2 (Val.bf16Bits (act C X h (4 * l + j)))).getD i 0

theorem actMem_holds : Holds C X h l ((actMem C ctx X h l sh 4).bytes (ctx.threadArray 0)) :=
  fun j hj i hi => actMem_arr 4 j hj i hi

/-- `values[k]` read back. -/
theorem eval_values {L : Locals} {i k : Nat} (hp : Pre ctx h l L) (hi : L i = some (u32 k)) (hk : k < 4)
    (ra : sh.regions (ctx.threadArray 0) = some ⟨.thread, 8, 2⟩) (hm : Holds C X h l (sh.bytes (ctx.threadArray 0))) :
    (eval C ctx L (.load (.scalar .bf16) (.offset (.local 12) (.local i)))).run sh =
      some (.bf16 (act C X h (4 * l + k)), sh) :=
  (eval_load C _ _ _ _ _ _ _ (eval_bf16_base C (eval_local C ctx L 12 _ hp.arr sh) (eval_local C ctx L i _ hi sh)
    (by omega))).trans (load_bf16_thread ctx sh _ k 8 _ ra (by omega) (hm k hk))

/-- The q/k loop's memory facts. -/
structure QKFacts (C : M1Max.Contract) (ctx : Ctx) (X : ByteMemory.Bytes) (h l out sc : Nat) (SC : ByteMemory.Bytes)
    (as : Nat) (sh : Shared) : Prop where
  rs : sh.regions sc = some ⟨.device, 256, as⟩
  has : 2 ∣ as
  ro : sh.regions out = some ⟨.device, 4096, 16⟩
  ra : sh.regions (ctx.threadArray 0) = some ⟨.thread, 8, 2⟩
  scale : sh.bytes sc = SC
  arr : Holds C X h l (sh.bytes (ctx.threadArray 0))
  so : sc ≠ out
  ao : ctx.threadArray 0 ≠ out

/-- `qscale[c] * normalized` for column `4 l + j` (or `kscale`). -/
def qkVal (C : M1Max.Contract) (X SC : ByteMemory.Bytes) (h l : Nat) (inv : Float32) (j : Nat) : BF :=
  C.bfmul (bfAt SC (4 * l + j)) (C.narrow (C.fmul (C.widen (act C X h (4 * l + j))) inv))

def scStore (P S : Nat) : List CStmt :=
  [.store (.scalar .bf16) (.offset (.local P) qkTarget)
    (.bin .mul .bf16 0 (.load (.scalar .bf16) (.offset (.local S) (laneCol 23))) (.local 24))]

theorem qStore_eq : qStore = scStore 3 1 := rfl
theorem kStore_eq : kStore = scStore 4 2 := rfl

/-- The q/k loop's invariant at its `k`-th test. -/
def QKInv (C : M1Max.Contract) (ctx : Ctx) (X SC : ByteMemory.Bytes) (h l out sc : Nat) (inv : Float32) (sh0 : Shared)
    (k : Nat) (L : Locals) (sh : Shared) : Prop :=
  Pre ctx h l L ∧ L 21 = some (.f32 inv) ∧ L 22 = some (u32 (128 * (h % 16) + 4 * l)) ∧ L 23 = some (u32 k) ∧
    sh = qkMem ctx out sc (128 * (h % 16) + 4 * l) l (qkVal C X SC h l inv) sh0 k

/-- One iteration of the q/k loop, with `out`/`scale` the slots `P`/`S` the head selects. -/
theorem qk_body (hc : Lane fuse ctx h l) {out sc as : Nat} {SC : ByteMemory.Bytes} {inv : Float32}
    (hf : QKFacts C ctx X h l out sc SC as sh) (hsel : (if decide (h < 16) then qStore else kStore) = scStore out sc)
    (hPo : ∀ L : Locals, Pre ctx h l L → L out = some (.ptr ⟨out, 0, .scalar .bf16⟩) ∧
      L sc = some (.ptr ⟨sc, 0, .scalar .bf16⟩))
    (k : Nat) (hk : k < 4) (L : Locals) (sh' : Shared) (hI : QKInv C ctx X SC h l out sc inv sh k L sh') :
    ∃ L₁, Exec C ctx qkBody L sh' .normal L₁
      (qkMem ctx out sc (128 * (h % 16) + 4 * l) l (qkVal C X SC h l inv) sh (k + 1)) ∧
      Pre ctx h l L₁ ∧ L₁ 21 = some (.f32 inv) ∧ L₁ 22 = some (u32 (128 * (h % 16) + 4 * l)) ∧ L₁ 23 = some (u32 k) := by
  obtain ⟨hp, h21, h22, h23, rfl⟩ := hI
  have hl := hc.hl; have hh := hc.hh
  generalize hS0 : qkMem ctx out sc (128 * (h % 16) + 4 * l) l (qkVal C X SC h l inv) sh k = S0
  have r0 : S0.regions = sh.regions := hS0 ▸ qkMem_regions k
  have bsc : S0.bytes sc = SC := hS0 ▸ (qkMem_bytes hf.so k).trans hf.scale
  have barr : Holds C X h l (S0.bytes (ctx.threadArray 0)) := by
    rw [← hS0, qkMem_bytes hf.ao k]; exact hf.arr
  have hpad : (eval C ctx L (.bin .ge .u32 0 (laneCol 23) (u32l 128))).run S0 = some (.bool false, S0) := by
    have : (eval C ctx L (.bin .ge .u32 0 (laneCol 23) (u32l 128))).run S0 =
        some (.bool (decide (128 ≤ 4 * l + k)), S0) :=
      eval_int C (by decide) (eval_laneCol C hp.lane h23) (eval_lit C _ _ _ _)
        (binary_ge_u32 C (4 * l + k) 128 (by omega) (by omega))
    rwa [decide_eq_false (by omega)] at this
  have e24 : (eval C ctx L normalizedExpr).run S0 =
      some (.bf16 (C.narrow (C.fmul (C.widen (act C X h (4 * l + k))) inv)), S0) :=
    eval_conv C (eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_conv C (eval_values hp h23 hk
      (by rw [r0]; exact hf.ra) barr) rfl) (eval_local C ctx L 21 _ h21 S0) rfl) rfl
  generalize hL1 : setLocal L 24 (.bf16 (C.narrow (C.fmul (C.widen (act C X h (4 * l + k))) inv))) = L1
  have hp1 : Pre ctx h l L1 := hL1 ▸ hp.set _ (by decide)
  have h22' : L1 22 = some (u32 (128 * (h % 16) + 4 * l)) := by rw [← hL1]; simp [setLocal, h22]
  have h23' : L1 23 = some (u32 k) := by rw [← hL1]; simp [setLocal, h23]
  have hlt : (eval C ctx L1 (.bin .lt .u32 0 (.local 7) (u32l 16))).run S0 = some (.bool (decide (h < 16)), S0) :=
    eval_int C (by decide) (eval_local C ctx L1 7 _ hp1.head S0) (eval_lit C _ _ _ _)
      (binary_lt_u32 C h 16 (by omega) (by omega))
  have hptr : (eval C ctx L1 (.offset (.local out) qkTarget)).run S0 =
      some (.ptr ⟨out, ((2 * (128 * (h % 16) + 4 * l + k) : Nat) : Int), .scalar .bf16⟩, S0) :=
    eval_bf16_base C (eval_local C ctx L1 out _ (hPo L1 hp1).1 S0) (eval_int C (by decide)
      (eval_local C ctx L1 22 _ h22' S0) (eval_local C ctx L1 23 _ h23' S0)
      (binary_add_u32 C (128 * (h % 16) + 4 * l) k)) (by omega)
  have hval : (eval C ctx L1 (.bin .mul .bf16 0 (.load (.scalar .bf16) (.offset (.local sc) (laneCol 23)))
      (.local 24))).run S0 = some (.bf16 (qkVal C X SC h l inv k), logged2 ctx S0 sc (4 * l + k) false) :=
    eval_bin C (nf_bf16 _) ((eval_load C _ _ _ _ _ _ _ (eval_bf16_base C (eval_local C ctx L1 sc _ (hPo L1 hp1).2 S0)
      (eval_laneCol C hp1.lane h23') (by omega))).trans (load_bf16_elem ctx S0 sc (4 * l + k) ⟨.device, 256, as⟩ SC
        (by rw [r0]; exact hf.rs) (.inl rfl) hf.has (show _ ≤ 256 by omega) bsc))
      (eval_local C ctx L1 24 _ (by rw [← hL1]; exact setLocal_same _ _ _) _) rfl
  have hst := store_bf16_elem ctx (logged2 ctx S0 sc (4 * l + k) false) out (128 * (h % 16) + 4 * l + k) ⟨.device, 4096, 16⟩
    (qkVal C X SC h l inv k) (by rw [← hf.ro, ← r0]; rfl) rfl (by decide) (show _ ≤ 4096 by omega)
  have hS : written2 (logged2 ctx (logged2 ctx S0 sc (4 * l + k) false) out (128 * (h % 16) + 4 * l + k) true) out
      (128 * (h % 16) + 4 * l + k) (qkVal C X SC h l inv k) =
      qkMem ctx out sc (128 * (h % 16) + 4 * l) l (qkVal C X SC h l inv) sh (k + 1) := by rw [← hS0]; rfl
  rw [hS] at hst
  have hsc : Exec C ctx (scStore out sc) L1 S0 .normal L1
      (qkMem ctx out sc (128 * (h % 16) + 4 * l) l (qkVal C X SC h l inv) sh (k + 1)) :=
    .store hptr hval hst (.nil _ _)
  subst hL1
  exact ⟨_, .ite hpad (.nil _ _) (.set e24 (.ite hlt (by rw [hsel]; exact hsc) (.nil _ _))),
    hp.set _ (by decide), by simp [setLocal, h21], h22', h23'⟩

/-- The q/k loop: four columns. -/
theorem qk_loop (hc : Lane fuse ctx h l) {out sc as : Nat} {SC : ByteMemory.Bytes} {inv : Float32}
    (hf : QKFacts C ctx X h l out sc SC as sh) (hsel : (if decide (h < 16) then qStore else kStore) = scStore out sc)
    (hPo : ∀ L : Locals, Pre ctx h l L → L out = some (.ptr ⟨out, 0, .scalar .bf16⟩) ∧
      L sc = some (.ptr ⟨sc, 0, .scalar .bf16⟩))
    (L : Locals) (hI : QKInv C ctx X SC h l out sc inv sh 0 L sh) :
    ∃ L', Exec C ctx [qkLoop] L sh .normal L'
      (qkMem ctx out sc (128 * (h % 16) + 4 * l) l (qkVal C X SC h l inv) sh 4) := by
  obtain ⟨L', sh', hex, -, -, -, -, rfl⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := lt4 23) (st := inc 23)
    (b := qkBody) 4 (QKInv C ctx X SC h l out sc inv sh) (QKInv C ctx X SC h l out sc inv sh)
    (fun k hk L s hI => ⟨s, eval_lt4 C hI.2.2.2.1 (by omega), hI⟩)
    (fun k hk L s hI => by
      obtain ⟨L₁, hb, hp₁, h21, h22, h23⟩ := qk_body hc hf hsel hPo k hk L s hI
      exact ⟨.normal, L₁, _, _, _, .inl rfl, hb, exec_inc C h23, hp₁.set _ (by decide), by simp [setLocal, h21],
        by simp [setLocal, h22], by simp [setLocal], rfl⟩) hI
  exact ⟨L', hex⟩

/-- `inv = rsqrt(sum / float(DK) + 1e-6f)` from the summed `sum`. -/
def invOf (C : M1Max.Contract) (total : Float32) : Float32 :=
  C.rsqrt (C.fadd (C.fmul total (Val.ofF32Bits 0x3C000000)) (Val.ofF32Bits 0x358637BD))

/-- The normalizing branch after its `simd_sum`. -/
theorem norm_rest (hc : Lane fuse ctx h l) {out sc as : Nat} {SC : ByteMemory.Bytes}
    (hf : QKFacts C ctx X h l out sc SC as sh) (hsel : (if decide (h < 16) then qStore else kStore) = scStore out sc)
    (hPo : ∀ L : Locals, Pre ctx h l L → L out = some (.ptr ⟨out, 0, .scalar .bf16⟩) ∧
      L sc = some (.ptr ⟨sc, 0, .scalar .bf16⟩))
    (L : Locals) (hp : Pre ctx h l L) (total : Float32) :
    ∃ L', Exec C ctx normalizeBranch.tail (setLocal L 20 (.f32 total)) sh .normal L'
      (qkMem ctx out sc (128 * (h % 16) + 4 * l) l (qkVal C X SC h l (invOf C total)) sh 4) := by
  have hl := hc.hl; have hh := hc.hh
  have hp0 : Pre ctx h l (setLocal L 20 (.f32 total)) := hp.set _ (by decide)
  have e21 : (eval C ctx (setLocal (setLocal L 20 (.f32 total)) 13 (.f32 total)) rsqrtExpr).run sh =
      some (.f32 (invOf C total), sh) :=
    eval_un C (eval_bin_plain C (.inr ⟨rfl, rfl⟩) (eval_conv C (eval_f32 C (.inl ⟨by decide, by decide⟩)
      (eval_local C ctx _ 13 _ (setLocal_same _ _ _) sh) (eval_lit C _ _ _ _) rfl) rfl) (eval_lit C _ _ _ _) rfl) rfl
  have hp2 := (hp0.set (.f32 total) (show 13 ≤ 13 by decide)).set (.f32 (invOf C total)) (show 13 ≤ 21 by decide)
  have e22 := eval_qkIndex (C := C) (sh := sh) hp2 hh
  obtain ⟨L', hex⟩ := qk_loop (inv := invOf C total) hc hf hsel hPo _ ⟨(hp2.set (u32 (128 * (h % 16) + 4 * l)) (show 13 ≤ 22 by decide)).set
    (.int .u32 0) (show 13 ≤ 23 by decide), by simp [setLocal],
    by simp [setLocal], by simp [setLocal, u32], rfl⟩
  exact ⟨L', .set (eval_local C ctx _ 20 _ (setLocal_same _ _ _) sh) (.set e21 (.set e22 (.set (eval_lit C _ _ _ _)
    hex)))⟩

/-- The v loop's invariant at its `k`-th test. -/
def VInv (C : M1Max.Contract) (ctx : Ctx) (X : ByteMemory.Bytes) (h l : Nat) (sh0 : Shared) (k : Nat) (L : Locals)
    (sh : Shared) : Prop :=
  Pre ctx h l L ∧ L 25 = some (u32 (128 * (h - 32) + 4 * l)) ∧ L 26 = some (u32 k) ∧
    sh = vMem ctx (128 * (h - 32) + 4 * l) (fun j => act C X h (4 * l + j)) sh0 k

/-- The value branch: `v[index + i] = values[i]` for the four columns. -/
theorem value_branch (hc : Lane fuse ctx h l) (h32 : 32 ≤ h) (r5 : sh.regions 5 = some ⟨.device, 12288, 16⟩)
    (ra : sh.regions (ctx.threadArray 0) = some ⟨.thread, 8, 2⟩) (a5 : ctx.threadArray 0 ≠ 5)
    (harr : Holds C X h l (sh.bytes (ctx.threadArray 0))) (L : Locals) (hp : Pre ctx h l L) :
    ∃ L', Exec C ctx valueBranch L sh .normal L'
      (vMem ctx (128 * (h - 32) + 4 * l) (fun j => act C X h (4 * l + j)) sh 4) := by
  have hl := hc.hl; have hh := hc.hh
  have e25 := eval_vIndex (C := C) (sh := sh) hp h32 hh
  have hp1 := hp.set (u32 (128 * (h - 32) + 4 * l)) (show 13 ≤ 25 by decide)
  obtain ⟨L', sh', hex, -, -, -, rfl⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := lt4 26) (st := inc 26)
    (b := [.ite (.bin .lt .u32 0 (laneCol 26) (u32l 128)) vStore []]) 4 (VInv C ctx X h l sh) (VInv C ctx X h l sh)
    (fun k hk L s hI => ⟨s, eval_lt4 C hI.2.2.1 (by omega), hI⟩)
    (fun k hk L s hI => by
      obtain ⟨hp, h25, h26, rfl⟩ := hI
      generalize hS0 : vMem ctx (128 * (h - 32) + 4 * l) (fun j => act C X h (4 * l + j)) sh k = S0
      have r0 : S0.regions = sh.regions := hS0 ▸ vMem_regions k
      have barr : Holds C X h l (S0.bytes (ctx.threadArray 0)) := by rw [← hS0, vMem_bytes a5 k]; exact harr
      have hlt : (eval C ctx L (.bin .lt .u32 0 (laneCol 26) (u32l 128))).run S0 = some (.bool true, S0) := by
        have : (eval C ctx L (.bin .lt .u32 0 (laneCol 26) (u32l 128))).run S0 =
            some (.bool (decide (4 * l + k < 128)), S0) :=
          eval_int C (by decide) (eval_laneCol C hp.lane h26) (eval_lit C _ _ _ _)
            (binary_lt_u32 C (4 * l + k) 128 (by omega) (by omega))
        rwa [decide_eq_true (by omega)] at this
      have hptr : (eval C ctx L (.offset (.local 5) (.bin .add .u32 0 (.local 25) (.local 26)))).run S0 =
          some (.ptr ⟨5, ((2 * (128 * (h - 32) + 4 * l + k) : Nat) : Int), .scalar .bf16⟩, S0) :=
        eval_bf16_base C (eval_local C ctx L 5 _ hp.v S0) (eval_int C (by decide) (eval_local C ctx L 25 _ h25 S0)
          (eval_local C ctx L 26 _ h26 S0) (binary_add_u32 C (128 * (h - 32) + 4 * l) k)) (by omega)
      have hst := store_bf16_elem ctx S0 5 (128 * (h - 32) + 4 * l + k) ⟨.device, 12288, 16⟩ (act C X h (4 * l + k))
        (by rw [r0]; exact r5) rfl (by decide) (show _ ≤ 12288 by omega)
      have hS : written2 (logged2 ctx S0 5 (128 * (h - 32) + 4 * l + k) true) 5 (128 * (h - 32) + 4 * l + k)
          (act C X h (4 * l + k)) = vMem ctx (128 * (h - 32) + 4 * l) (fun j => act C X h (4 * l + j)) sh (k + 1) := by
        rw [← hS0]; rfl
      rw [hS] at hst
      exact ⟨.normal, L, _, _, _, .inl rfl, .ite hlt (.store hptr (eval_values hp h26 hk (by rw [r0]; exact ra) barr)
        hst (.nil _ _)) (.nil _ _), exec_inc C h26, hp.set _ (by decide), by simp [setLocal, h25], by simp [setLocal],
        rfl⟩)
    ⟨hp1.set (.int .u32 0) (show 13 ≤ 26 by decide), by simp [setLocal], by simp [setLocal, u32], rfl⟩
  exact ⟨L', .set e25 (.set (eval_lit C _ _ _ _) hex)⟩

end Loops

/-! ## Threads -/

section Threads
variable {C : M1Max.Contract} {fuse : Nat → Bool} {ctx : Ctx} {X : ByteMemory.Bytes} {h l : Nat} {sh : Shared}

/-- What a thread's activation needs of memory. -/
structure Mem (ctx : Ctx) (ax : Nat) (sh : Shared) : Prop where
  r0 : sh.regions 0 = some ⟨.device, 20480, ax⟩
  hax : 2 ∣ ax
  ra : sh.regions (ctx.threadArray 0) = some ⟨.thread, 8, 2⟩
  a6 : 6 ≤ ctx.threadArray 0

/-- A normalizing lane runs to its `simd_sum`. -/
theorem lane_start (hc : Lane fuse ctx h l) (h32 : h < 32) {ax : Nat} (hm : Mem ctx ax sh) (hx : sh.bytes 0 = X) :
    ∃ L', (∃ N, ∀ m ≥ N, (runThread C m ⟨ctx, fun _ => none, [.block body], .running⟩).run sh =
      some (⟨ctx, L', [.block normalizeBranch.tail, .block []],
        .collective 2 20 .sum .f32 (.f32 (laneSum C fuse X h l 4)) 0⟩, actMem C ctx X h l sh 4)) ∧
      Pre ctx h l L' := by
  obtain ⟨L0, hd, hp0, h13, h14⟩ := decls_run (C := C) hc sh
  obtain ⟨L', hl, hp', h13'⟩ := act_loop hc hm.r0 hm.hax hm.ra (by have := hm.a6; omega) hx L0 hp0 h14 h13
  have hite : Exec C ctx [.ite (.local 9) normalizeBranch valueBranch] L' (actMem C ctx X h l sh 4)
      (.stop (.collective 2 20 .sum .f32 (.f32 (laneSum C fuse X h l 4)) 0)
        ([.block normalizeBranch.tail] ++ [.block []])) L' (actMem C ctx X h l sh 4) :=
    .ite_stop (v := true) (eval_local C ctx L' 9 _ (by rw [hp'.norm, decide_eq_true h32]) _)
      (.collective (eval_local C ctx L' 13 _ h13' _) (eval_lit C _ _ _ _) rfl)
  have hall : Exec C ctx body (fun _ => none) sh (.stop (.collective 2 20 .sum .f32 (.f32 (laneSum C fuse X h l 4)) 0)
      ([.block normalizeBranch.tail] ++ [.block []])) L' (actMem C ctx X h l sh 4) := by
    rw [body_eq]; exact hd.append (hl.append hite)
  exact ⟨L', hall.reaches_stop.run rfl, hp'⟩

/-- A normalizing lane resumed with the head's sum runs to the end. -/
theorem lane_norm (hc : Lane fuse ctx h l) {out sc as : Nat} {SC : ByteMemory.Bytes}
    (hf : QKFacts C ctx X h l out sc SC as sh) (hsel : (if decide (h < 16) then qStore else kStore) = scStore out sc)
    (hPo : ∀ L : Locals, Pre ctx h l L → L out = some (.ptr ⟨out, 0, .scalar .bf16⟩) ∧
      L sc = some (.ptr ⟨sc, 0, .scalar .bf16⟩))
    (L : Locals) (hp : Pre ctx h l L) (total : Float32) :
    ∃ L', ∃ N, ∀ m ≥ N, (runThread C m ⟨ctx, setLocal L 20 (.f32 total),
      [.block normalizeBranch.tail, .block []], .running⟩).run sh =
      some (⟨ctx, L', [], .done⟩, qkMem ctx out sc (128 * (h % 16) + 4 * l) l (qkVal C X SC h l (invOf C total)) sh 4) := by
  obtain ⟨L', hex⟩ := norm_rest hc hf hsel hPo L hp total
  exact ⟨L', ((hex.reaches_normal (K := [.block []])).trans (.cons rfl (step_pop C) (.single rfl (step_done C)))).run
    rfl⟩

/-- A v lane runs its whole code. -/
theorem lane_value (hc : Lane fuse ctx h l) (h32 : 32 ≤ h) {ax : Nat} (hm : Mem ctx ax sh)
    (r5 : sh.regions 5 = some ⟨.device, 12288, 16⟩) (hx : sh.bytes 0 = X) :
    ∃ L', ∃ N, ∀ m ≥ N, (runThread C m ⟨ctx, fun _ => none, [.block body], .running⟩).run sh =
      some (⟨ctx, L', [], .done⟩, vMem ctx (128 * (h - 32) + 4 * l) (fun j => act C X h (4 * l + j))
        (actMem C ctx X h l sh 4) 4) := by
  obtain ⟨L0, hd, hp0, h13, h14⟩ := decls_run (C := C) hc sh
  have ha0 : ctx.threadArray 0 ≠ 0 := by have := hm.a6; omega
  obtain ⟨L', hl, hp', -⟩ := act_loop (fuse := fuse) hc hm.r0 hm.hax hm.ra ha0 hx L0 hp0 h14 h13
  obtain ⟨L'', hv⟩ := value_branch (C := C) (X := X) hc h32 (by rw [actMem_regions]; exact r5)
    (by rw [actMem_regions]; exact hm.ra) (by have := hm.a6; omega) actMem_holds L' hp'
  have hite : Exec C ctx [.ite (.local 9) normalizeBranch valueBranch] L' (actMem C ctx X h l sh 4) .normal L''
      (vMem ctx (128 * (h - 32) + 4 * l) (fun j => act C X h (4 * l + j)) (actMem C ctx X h l sh 4) 4) :=
    .ite (v := false) (eval_local C ctx L' 9 _ (by rw [hp'.norm, decide_eq_false (by omega)]) _) hv (.nil _ _)
  have hall : Exec C ctx body (fun _ => none) sh .normal L''
      (vMem ctx (128 * (h - 32) + 4 * l) (fun j => act C X h (4 * l + j)) (actMem C ctx X h l sh 4) 4) := by
    rw [body_eq]; exact hd.append (hl.append hite)
  exact ⟨L'', hall.reaches_done.run rfl⟩

/-! ### What the stores leave in memory -/

theorem qkMem_epochs {out sc base : Nat} {vals : Nat → BF} :
    ∀ k, (qkMem ctx out sc base l vals sh k).deviceEpoch = sh.deviceEpoch
  | 0 => rfl
  | k + 1 => qkMem_epochs (out := out) (sc := sc) (base := base) (vals := vals) k

theorem vMem_epochs {base : Nat} {vals : Nat → BF} : ∀ k, (vMem ctx base vals sh k).deviceEpoch = sh.deviceEpoch
  | 0 => rfl
  | k + 1 => vMem_epochs (base := base) (vals := vals) k

theorem qkMem_out {out sc base : Nat} {vals : Nat → BF} :
    ∀ k, (qkMem ctx out sc base l vals sh k).bytes out = wrote base vals (sh.bytes out) k
  | 0 => by funext b; unfold wrote; rw [ite_eq_right (by omega)]; rfl
  | k + 1 => by
    funext b
    show (written2 _ out (base + k) (vals k)).bytes out b = _
    rw [written2_bytes, ite_eq_left rfl]
    show writeBytes ((qkMem ctx out sc base l vals sh k).bytes out) (2 * (base + k)) _ b = _
    rw [qkMem_out k, wrote_succ]

theorem vMem_out {base : Nat} {vals : Nat → BF} :
    ∀ k, (vMem ctx base vals sh k).bytes 5 = wrote base vals (sh.bytes 5) k
  | 0 => by funext b; unfold wrote; rw [ite_eq_right (by omega)]; rfl
  | k + 1 => by
    funext b
    show (written2 _ 5 (base + k) (vals k)).bytes 5 b = _
    rw [written2_bytes, ite_eq_left rfl]
    show writeBytes ((vMem ctx base vals sh k).bytes 5) (2 * (base + k)) _ b = _
    rw [vMem_out k, wrote_succ]

/-- A thread's entry: by `ctx`, in `sh`'s device epoch. -/
def ByCtx (ctx : Ctx) (sh : Shared) (e : Access) : Prop :=
  e.thread = ctx.thread ∧ e.group = ctx.group ∧ e.deviceEpoch = sh.deviceEpoch

theorem qkMem_log {out sc base : Nat} {vals : Nat → BF} : ∀ k, ∀ e ∈ (qkMem ctx out sc base l vals sh k).log,
    e ∈ sh.log ∨ (e.region = sc ∧ e.write = false) ∨
      (e.region = out ∧ ByCtx ctx sh e ∧ 2 * base ≤ e.byte ∧ e.byte < 2 * (base + k))
  | 0, e, he => .inl he
  | k + 1, e, he => by
    simp only [qkMem, written2, logged2, List.mem_append, List.mem_reverse, List.mem_map, List.mem_range] at he
    rcases he with ⟨i, hi, rfl⟩ | ⟨i, _, rfl⟩ | he
    · exact .inr (.inr ⟨rfl, ⟨rfl, rfl, qkMem_epochs k⟩, by simp [entry]; omega, by simp [entry]; omega⟩)
    · exact .inr (.inl ⟨rfl, rfl⟩)
    · rcases qkMem_log k e he with h | h | ⟨h1, h2, h3, h4⟩
      · exact .inl h
      · exact .inr (.inl h)
      · exact .inr (.inr ⟨h1, h2, h3, by omega⟩)

theorem vMem_log {base : Nat} {vals : Nat → BF} : ∀ k, ∀ e ∈ (vMem ctx base vals sh k).log,
    e ∈ sh.log ∨ (e.region = 5 ∧ ByCtx ctx sh e ∧ 2 * base ≤ e.byte ∧ e.byte < 2 * (base + k))
  | 0, e, he => .inl he
  | k + 1, e, he => by
    simp only [vMem, written2, logged2, List.mem_append, List.mem_reverse, List.mem_map, List.mem_range] at he
    rcases he with ⟨i, hi, rfl⟩ | he
    · exact .inr ⟨rfl, ⟨rfl, rfl, vMem_epochs k⟩, by simp [entry]; omega, by simp [entry]; omega⟩
    · rcases vMem_log k e he with h | ⟨h1, h2, h3, h4⟩
      · exact .inl h
      · exact .inr ⟨h1, h2, h3, by omega⟩

end Threads

/-! ## The launch -/

/-- The inputs: `x` [1, 1, 10240], `qscale` [128] and `kscale` [128], bf16, in device memory. -/
def inputs (X QS KS : ByteMemory.Bytes) (ax aq ak : Nat) : List Buffer :=
  [⟨.device, 20480, ax, X⟩, ⟨.device, 256, aq, QS⟩, ⟨.device, 256, ak, KS⟩]

/-- The outputs' sizes in bytes: `q`, `k` [1, 1, 16, 128] and `v` [1, 1, 48, 128], bf16. -/
def sizes : List Nat := [4096, 4096, 12288]

def launch (X QS KS : ByteMemory.Bytes) (ax aq ak : Nat) (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨core, (2560, 1, 1), (32, 1, 1), buffers (inputs X QS KS ax aq ak) sizes 16 initial⟩

/-- The thread that writes element `e` of `q`, `k`, `v`: lane `c / 4` of the head. -/
def qThread (e : Nat) : Nat := 32 * (e / 128) + e % 128 / 4
def kThread (e : Nat) : Nat := 32 * (16 + e / 128) + e % 128 / 4
def vThread (e : Nat) : Nat := 32 * (32 + e / 128) + e % 128 / 4

/-- Thread `t` writes in its threadgroup `t / 32`, before any barrier. -/
def writer (t : Nat) : Writer := ⟨t, t / 32, 0⟩

/-- The writer of each output byte. -/
def dev (region byte : Nat) : Option Writer :=
  if region = 3 then some (writer (qThread (byte / 2)))
  else if region = 4 then some (writer (kThread (byte / 2)))
  else if region = 5 then some (writer (vThread (byte / 2)))
  else none

def tgo : Nat → Nat → Nat → Nat → Option Nat := fun _ _ _ _ => none

section LaunchFacts
variable (X QS KS : ByteMemory.Bytes) (ax aq ak : Nat) (initial : Nat → ByteMemory.Bytes)

theorem tiles : (launch X QS KS ax aq ak initial).Tiles 32 1 1 80 1 1 1 := ⟨rfl, rfl, rfl, by decide⟩

theorem launch_r0 : (launch X QS KS ax aq ak initial).regions 0 = some ⟨.device, 20480, ax⟩ := rfl
theorem launch_r1 : (launch X QS KS ax aq ak initial).regions 1 = some ⟨.device, 256, aq⟩ := rfl
theorem launch_r2 : (launch X QS KS ax aq ak initial).regions 2 = some ⟨.device, 256, ak⟩ := rfl
theorem launch_r3 : (launch X QS KS ax aq ak initial).regions 3 = some ⟨.device, 4096, 16⟩ := rfl
theorem launch_r4 : (launch X QS KS ax aq ak initial).regions 4 = some ⟨.device, 4096, 16⟩ := rfl
theorem launch_r5 : (launch X QS KS ax aq ak initial).regions 5 = some ⟨.device, 12288, 16⟩ := rfl

theorem launch_rt (t : Nat) : (launch X QS KS ax aq ak initial).regions (6 + t) = some ⟨.thread, 8, 2⟩ := by
  have := Launch.regions_threadArray (launch X QS KS ax aq ak initial) t 0 (.scalar .bf16) 4 rfl
  rwa [show (launch X QS KS ax aq ak initial).buffers.length + (launch X QS KS ax aq ak initial).groupArrays +
    t * (launch X QS KS ax aq ak initial).threadArrays + 0 = 6 + t from show 6 + 0 + t * 1 + 0 = 6 + t by omega]
    at this

variable (fuse : Nat → Bool) (h : Nat)

theorem ctx_lane (hh : h < 80) (i : Fin 32) :
    Lane fuse ((launch X QS KS ax aq ak initial).ctxAt fuse h 0 0 (32 * 0 + i)) h i :=
  ⟨Launch.ctxAt_lane _ fuse h 0 0 0 i, Launch.ctxAt_threadgroupPositionInGrid _ fuse h 0 0 _,
    Launch.ctxAt_fuse _ fuse h 0 0 _, i.isLt, hh⟩

theorem ctx_thread (i : Nat) : ((launch X QS KS ax aq ak initial).ctxAt fuse h 0 0 (32 * 0 + i)).thread = 32 * h + i := by
  rw [(tiles X QS KS ax aq ak initial).thread]; ring

theorem ctx_group (i : Nat) : ((launch X QS KS ax aq ak initial).ctxAt fuse h 0 0 (32 * 0 + i)).group = h := by
  rw [(tiles X QS KS ax aq ak initial).group_id]; ring

theorem ctx_arr (i : Nat) :
    ((launch X QS KS ax aq ak initial).ctxAt fuse h 0 0 (32 * 0 + i)).threadArray 0 = 6 + (32 * h + i) := by
  rw [(tiles X QS KS ax aq ak initial).threadArray]
  show 6 + 0 + ((h + 0 * 80 + 0 * 80 * 1) * (32 * 1) + (32 * 0 + i)) * 1 + 0 = _
  ring

theorem ctx_mem (i : Nat) (sh : Shared) (hr : sh.regions = (launch X QS KS ax aq ak initial).regions) (hax : 2 ∣ ax) :
    Mem ((launch X QS KS ax aq ak initial).ctxAt fuse h 0 0 (32 * 0 + i)) ax sh :=
  ⟨by rw [hr]; rfl, hax, by rw [hr, ctx_arr]; exact launch_rt _ _ _ _ _ _ _ _, by rw [ctx_arr]; omega⟩

theorem isGroup_launch (r : Nat) (hr : r < 6) : isGroup ((launch X QS KS ax aq ak initial).regions r) = false := by
  rcases (by omega : r = 0 ∨ r = 1 ∨ r = 2 ∨ r = 3 ∨ r = 4 ∨ r = 5) with rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

/-- A read of an input. -/
theorem owned_read (a : Access) (hr : a.region < 3) (hw : a.write = false) :
    Owned (launch X QS KS ax aq ak initial) dev tgo a := by
  unfold Owned
  rw [isGroup_launch X QS KS ax aq ak initial a.region (by omega)]
  have hd : dev a.region a.byte = none := by
    unfold dev; rw [ite_eq_right (by omega), ite_eq_right (by omega), ite_eq_right (by omega)]
  simp only [Bool.false_eq_true, ↓reduceIte, hd]
  exact hw

/-- A write by the byte's writer. -/
theorem owned_write (a : Access) (hr : a.region = 3 ∨ a.region = 4 ∨ a.region = 5) (t : Nat)
    (hd : dev a.region a.byte = some (writer t)) (ht : a.thread = t) (hg : a.group = t / 32) (he : a.deviceEpoch = 0) :
    Owned (launch X QS KS ax aq ak initial) dev tgo a := by
  unfold Owned
  rw [isGroup_launch X QS KS ax aq ak initial a.region (by omega), hd]
  simp [writer, ht, hg, he]

end LaunchFacts

/-! ### Owners -/

theorem qThread_lt {b : Nat} (hb : b < 4096) : qThread (b / 2) < 512 := by unfold qThread; omega
theorem kThread_bounds {b : Nat} (hb : b < 4096) : 512 ≤ kThread (b / 2) ∧ kThread (b / 2) < 1024 := by
  unfold kThread; omega
theorem vThread_ge (b : Nat) : 1024 ≤ vThread (b / 2) := by unfold vThread; omega
theorem vThread_lt {b : Nat} (hb : b < 12288) : vThread (b / 2) < 2560 := by unfold vThread; omega

/-- The bytes lane `i` of head `h` writes are those whose owner it is. -/
theorem qThread_eq {b h i : Nat} (hb : b < 4096) (hh : h < 16) (hi : i < 32) :
    qThread (b / 2) = 32 * h + i ↔ 2 * (128 * (h % 16) + 4 * i) ≤ b ∧ b < 2 * (128 * (h % 16) + 4 * i + 4) := by
  unfold qThread; omega

theorem kThread_eq {b h i : Nat} (hb : b < 4096) (hh : 16 ≤ h ∧ h < 32) (hi : i < 32) :
    kThread (b / 2) = 32 * h + i ↔ 2 * (128 * (h % 16) + 4 * i) ≤ b ∧ b < 2 * (128 * (h % 16) + 4 * i + 4) := by
  unfold kThread; omega

theorem vThread_eq {b h i : Nat} (hh : 32 ≤ h ∧ h < 80) :
    vThread (b / 2) = 32 * h + i ↔ 2 * (128 * (h - 32) + 4 * i) ≤ b ∧ b < 2 * (128 * (h - 32) + 4 * i + 4) := by
  unfold vThread; omega

/-! ### The invariant -/

/-- Before thread `T` (in launch order) runs: the inputs intact, every output byte written2 by an earlier thread
holding its expected value, and every access so far keeping the ownership discipline. -/
structure Inv (C : M1Max.Contract) (fuse : Nat → Bool) (X QS KS : ByteMemory.Bytes) (ax aq ak : Nat)
    (initial : Nat → ByteMemory.Bytes) (T : Nat) (sh : Shared) : Prop where
  regions : sh.regions = (launch X QS KS ax aq ak initial).regions
  x : sh.bytes 0 = X
  qs : sh.bytes 1 = QS
  ks : sh.bytes 2 = KS
  epoch : sh.deviceEpoch = 0
  q : ∀ b < 4096, qThread (b / 2) < T → sh.bytes 3 b = bytesOf 4096 (qOut C fuse X QS) b
  k : ∀ b < 4096, kThread (b / 2) < T → sh.bytes 4 b = bytesOf 4096 (kOut C fuse X KS) b
  v : ∀ b < 12288, vThread (b / 2) < T → sh.bytes 5 b = bytesOf 12288 (vOut C X) b
  log : ∀ a ∈ sh.log, Owned (launch X QS KS ax aq ak initial) dev tgo a

/-! ### Each thread keeps the invariant -/

section Preserve
variable {C : M1Max.Contract} {fuse : Nat → Bool} {X QS KS : ByteMemory.Bytes} {ax aq ak : Nat}
  {initial : Nat → ByteMemory.Bytes}

theorem qOut_eq {h i j : Nat} (hh : h < 16) (hi : i < 32) (hj : j < 4) :
    qOut C fuse X QS (128 * (h % 16) + 4 * i + j) = qkVal C X QS h i (invRms C fuse X h) j := by
  unfold qOut qkVal normalized
  rw [show (128 * (h % 16) + 4 * i + j) % 128 = 4 * i + j by omega,
    show (128 * (h % 16) + 4 * i + j) / 128 = h by omega]

theorem kOut_eq {h i j : Nat} (hh : 16 ≤ h ∧ h < 32) (hi : i < 32) (hj : j < 4) :
    kOut C fuse X KS (128 * (h % 16) + 4 * i + j) = qkVal C X KS h i (invRms C fuse X h) j := by
  unfold kOut qkVal normalized
  rw [show (128 * (h % 16) + 4 * i + j) % 128 = 4 * i + j by omega,
    show 16 + (128 * (h % 16) + 4 * i + j) / 128 = h by omega]

theorem vOut_eq {h i j : Nat} (hh : 32 ≤ h ∧ h < 80) (hi : i < 32) (hj : j < 4) :
    vOut C X (128 * (h - 32) + 4 * i + j) = act C X h (4 * i + j) := by
  unfold vOut
  rw [show (128 * (h - 32) + 4 * i + j) % 128 = 4 * i + j by omega,
    show 32 + (128 * (h - 32) + 4 * i + j) / 128 = h by omega]

theorem wrote_bytesOf {n base : Nat} {vals f : Nat → BF} {old : ByteMemory.Bytes} {b : Nat} (hb : b < n)
    (hr : 2 * base ≤ b ∧ b < 2 * (base + 4)) (hf : ∀ j < 4, f (base + j) = vals j) :
    wrote base vals old 4 b = bytesOf n f b := by
  unfold wrote bytesOf
  rw [ite_eq_left hr, ite_eq_left hb, show b / 2 = base + (b - 2 * base) / 2 by omega, hf _ (by omega),
    show b % 2 = (b - 2 * base) % 2 by omega]

/-- The activation loop of lane `i` of head `h` keeps the invariant. -/
theorem inv_act {T h i : Nat} {ctx : Ctx} (harr : ctx.threadArray 0 = 6 + (32 * h + i)) {sh : Shared}
    (hI : Inv C fuse X QS KS ax aq ak initial T sh) :
    Inv C fuse X QS KS ax aq ak initial T (actMem C ctx X h i sh 4) where
  regions := (actMem_regions 4).trans hI.regions
  x := (actMem_bytes (by omega) 4).trans hI.x
  qs := (actMem_bytes (by omega) 4).trans hI.qs
  ks := (actMem_bytes (by omega) 4).trans hI.ks
  epoch := (actMem_epochs 4).1.trans hI.epoch
  q := fun b hb ho => by rw [actMem_bytes (by omega) 4]; exact hI.q b hb ho
  k := fun b hb ho => by rw [actMem_bytes (by omega) 4]; exact hI.k b hb ho
  v := fun b hb ho => by rw [actMem_bytes (by omega) 4]; exact hI.v b hb ho
  log := fun a ha => by
    rcases actMem_log 4 a ha with h | ⟨h0, hw, -⟩
    · exact hI.log a h
    · exact owned_read X QS KS ax aq ak initial a (by omega) hw

/-- The arrays of the lanes before `i`, and now lane `i`'s, hold their activations. -/
theorem arr_act {h i : Nat} {ctx : Ctx} (harr : ctx.threadArray 0 = 6 + (32 * h + i)) {sh : Shared}
    (hA : ∀ j < i, Holds C X h j (sh.bytes (6 + (32 * h + j)))) :
    ∀ j < i + 1, Holds C X h j ((actMem C ctx X h i sh 4).bytes (6 + (32 * h + j))) := by
  intro j hj
  rcases Nat.lt_succ_iff_lt_or_eq.mp hj with hj | rfl
  · rw [actMem_bytes (by omega) 4]; exact hA j hj
  · rw [← harr]; exact actMem_holds

/-- A q lane's stores keep the invariant. -/
theorem inv_q {h i : Nat} (hh : h < 16) (hi : i < 32) {ctx : Ctx} (ht : ctx.thread = 32 * h + i)
    (hg : ctx.group = h) {sh : Shared} (hI : Inv C fuse X QS KS ax aq ak initial (32 * h + i) sh) :
    Inv C fuse X QS KS ax aq ak initial (32 * h + i + 1)
      (qkMem ctx 3 1 (128 * (h % 16) + 4 * i) i (qkVal C X QS h i (invRms C fuse X h)) sh 4) where
  regions := (qkMem_regions 4).trans hI.regions
  x := (qkMem_bytes (by decide) 4).trans hI.x
  qs := (qkMem_bytes (by decide) 4).trans hI.qs
  ks := (qkMem_bytes (by decide) 4).trans hI.ks
  epoch := (qkMem_epochs 4).trans hI.epoch
  q := fun b hb ho => by
    rw [qkMem_out]
    by_cases hr : 2 * (128 * (h % 16) + 4 * i) ≤ b ∧ b < 2 * (128 * (h % 16) + 4 * i + 4)
    · exact wrote_bytesOf hb hr (fun j hj => qOut_eq hh hi hj)
    · unfold wrote; rw [ite_eq_right (by omega)]
      have hq : qThread (b / 2) ≠ 32 * h + i := fun e => hr ((qThread_eq hb hh hi).mp e)
      exact hI.q b hb (by omega)
  k := fun b hb ho => absurd ho (by have := kThread_bounds hb; omega)
  v := fun b hb ho => absurd ho (by have := vThread_ge b; omega)
  log := fun a ha => by
    rcases qkMem_log 4 a ha with h1 | ⟨h1, h2⟩ | ⟨h1, ⟨h2, h3, h4⟩, h5, h6⟩
    · exact hI.log a h1
    · exact owned_read X QS KS ax aq ak initial a (by omega) h2
    · refine owned_write X QS KS ax aq ak initial a (.inl h1) (32 * h + i) ?_ (h2.trans ht)
        (by rw [h3, hg]; omega) (h4.trans hI.epoch)
      rw [h1, ← (qThread_eq (b := a.byte) (by omega) hh hi).mpr ⟨h5, by omega⟩]
      rfl

/-- A k lane's stores keep the invariant. -/
theorem inv_k {h i : Nat} (hh : 16 ≤ h ∧ h < 32) (hi : i < 32) {ctx : Ctx} (ht : ctx.thread = 32 * h + i)
    (hg : ctx.group = h) {sh : Shared} (hI : Inv C fuse X QS KS ax aq ak initial (32 * h + i) sh) :
    Inv C fuse X QS KS ax aq ak initial (32 * h + i + 1)
      (qkMem ctx 4 2 (128 * (h % 16) + 4 * i) i (qkVal C X KS h i (invRms C fuse X h)) sh 4) where
  regions := (qkMem_regions 4).trans hI.regions
  x := (qkMem_bytes (by decide) 4).trans hI.x
  qs := (qkMem_bytes (by decide) 4).trans hI.qs
  ks := (qkMem_bytes (by decide) 4).trans hI.ks
  epoch := (qkMem_epochs 4).trans hI.epoch
  q := fun b hb ho => by
    rw [qkMem_bytes (by decide) 4]; exact hI.q b hb (by have := qThread_lt hb; omega)
  k := fun b hb ho => by
    rw [qkMem_out]
    by_cases hr : 2 * (128 * (h % 16) + 4 * i) ≤ b ∧ b < 2 * (128 * (h % 16) + 4 * i + 4)
    · exact wrote_bytesOf hb hr (fun j hj => kOut_eq hh hi hj)
    · unfold wrote; rw [ite_eq_right (by omega)]
      have hk : kThread (b / 2) ≠ 32 * h + i := fun e => hr ((kThread_eq hb hh hi).mp e)
      exact hI.k b hb (by omega)
  v := fun b hb ho => absurd ho (by have := vThread_ge b; omega)
  log := fun a ha => by
    rcases qkMem_log 4 a ha with h1 | ⟨h1, h2⟩ | ⟨h1, ⟨h2, h3, h4⟩, h5, h6⟩
    · exact hI.log a h1
    · exact owned_read X QS KS ax aq ak initial a (by omega) h2
    · refine owned_write X QS KS ax aq ak initial a (.inr (.inl h1)) (32 * h + i) ?_ (h2.trans ht)
        (by rw [h3, hg]; omega) (h4.trans hI.epoch)
      rw [h1, ← (kThread_eq (b := a.byte) (by omega) hh hi).mpr ⟨h5, by omega⟩]
      rfl

/-- A v lane's stores keep the invariant. -/
theorem inv_v {h i : Nat} (hh : 32 ≤ h ∧ h < 80) (hi : i < 32) {ctx : Ctx} (ht : ctx.thread = 32 * h + i)
    (hg : ctx.group = h) {sh : Shared} (hI : Inv C fuse X QS KS ax aq ak initial (32 * h + i) sh) :
    Inv C fuse X QS KS ax aq ak initial (32 * h + i + 1)
      (vMem ctx (128 * (h - 32) + 4 * i) (fun j => act C X h (4 * i + j)) sh 4) where
  regions := (vMem_regions 4).trans hI.regions
  x := (vMem_bytes (by decide) 4).trans hI.x
  qs := (vMem_bytes (by decide) 4).trans hI.qs
  ks := (vMem_bytes (by decide) 4).trans hI.ks
  epoch := (vMem_epochs 4).trans hI.epoch
  q := fun b hb ho => by
    rw [vMem_bytes (by decide) 4]; exact hI.q b hb (by have := qThread_lt hb; omega)
  k := fun b hb ho => by
    rw [vMem_bytes (by decide) 4]; exact hI.k b hb (by have := kThread_bounds hb; omega)
  v := fun b hb ho => by
    rw [vMem_out]
    by_cases hr : 2 * (128 * (h - 32) + 4 * i) ≤ b ∧ b < 2 * (128 * (h - 32) + 4 * i + 4)
    · exact wrote_bytesOf hb hr (fun j hj => vOut_eq hh hi hj)
    · unfold wrote; rw [ite_eq_right (by omega)]
      have hv : vThread (b / 2) ≠ 32 * h + i := fun e => hr ((vThread_eq (b := b) (i := i) hh).mp e)
      exact hI.v b hb (by omega)
  log := fun a ha => by
    rcases vMem_log 4 a ha with h1 | ⟨h1, ⟨h2, h3, h4⟩, h5, h6⟩
    · exact hI.log a h1
    · refine owned_write X QS KS ax aq ak initial a (.inr (.inr h1)) (32 * h + i) ?_ (h2.trans ht)
        (by rw [h3, hg]; omega) (h4.trans hI.epoch)
      rw [h1, ← (vThread_eq (b := a.byte) (i := i) hh).mpr ⟨h5, by omega⟩]
      rfl

end Preserve

/-! ## SIMD-groups, threadgroups and the launch -/

section Run
variable {C : M1Max.Contract} {fuse : Nat → Bool} {X QS KS : ByteMemory.Bytes} {ax aq ak : Nat}
  {initial : Nat → ByteMemory.Bytes}

/-- A v head's SIMD-group: every lane runs its whole code. -/
theorem simd_value (hax : 2 ∣ ax) {h : Nat} (hh : 32 ≤ h ∧ h < 80) (sh : Shared)
    (hI : Inv C fuse X QS KS ax aq ak initial (32 * h) sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared), (∃ N, ∀ m ≥ N,
      (runSimd C m 2 (List.ofFn ((launch X QS KS ax aq ak initial).lanes fuse h 0 0 0))).run sh =
        some (List.ofFn V, sh')) ∧
      Inv C fuse X QS KS ax aq ak initial (32 * h + 32) sh' ∧ ∀ i, (V i).status = .done := by
  obtain ⟨V, sh', ⟨N, hN⟩, hI', hV⟩ := mapM_ofFn_ev ((launch X QS KS ax aq ak initial).lanes fuse h 0 0 0)
    (runThread C) (fun i sh => Inv C fuse X QS KS ax aq ak initial (32 * h + i) sh) (fun _ t => t.status = .done)
    (fun i sh hI => by
      obtain ⟨L', N, hN⟩ := lane_value (C := C) (X := X) (ctx_lane X QS KS ax aq ak initial fuse h hh.2 i) hh.1
        (ctx_mem X QS KS ax aq ak initial fuse h i sh hI.regions hax) (by rw [hI.regions]; rfl) hI.x
      exact ⟨_, _, ⟨N, hN⟩, inv_v hh i.isLt (ctx_thread X QS KS ax aq ak initial fuse h i)
        (ctx_group X QS KS ax aq ak initial fuse h i) (inv_act (ctx_arr X QS KS ax aq ak initial fuse h i) hI), rfl⟩)
    sh (by simpa using hI)
  exact ⟨V, sh', ⟨N, fun m hm => runSimd_blocked_ofFn C m 1 _ V sh sh' (hN m hm) (fun i => by rw [hV i]; rfl)⟩,
    hI', hV⟩

/-- A q or k head's SIMD-group: every lane runs to the `simd_sum`, then from it to the end. -/
theorem simd_norm (hax : 2 ∣ ax) (haq : 2 ∣ aq) (hak : 2 ∣ ak) {h : Nat} (hh : h < 32) (sh : Shared)
    (hI : Inv C fuse X QS KS ax aq ak initial (32 * h) sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared), (∃ N, ∀ m ≥ N,
      (runSimd C m 2 (List.ofFn ((launch X QS KS ax aq ak initial).lanes fuse h 0 0 0))).run sh =
        some (List.ofFn V, sh')) ∧
      Inv C fuse X QS KS ax aq ak initial (32 * h + 32) sh' ∧ ∀ i, (V i).status = .done := by
  obtain ⟨U, sh1, ⟨N1, hN1⟩, ⟨hI1, hA1⟩, hU⟩ := mapM_ofFn_ev ((launch X QS KS ax aq ak initial).lanes fuse h 0 0 0)
    (runThread C) (fun i sh => Inv C fuse X QS KS ax aq ak initial (32 * h) sh ∧
      ∀ j < i, Holds C X h j (sh.bytes (6 + (32 * h + j))))
    (fun i u => ∃ L', u = ⟨(launch X QS KS ax aq ak initial).ctxAt fuse h 0 0 (32 * 0 + i), L',
        [.block normalizeBranch.tail, .block []], .collective 2 20 .sum .f32 (.f32 (laneSum C fuse X h i 4)) 0⟩ ∧
      Pre ((launch X QS KS ax aq ak initial).ctxAt fuse h 0 0 (32 * 0 + i)) h i L')
    (fun i sh hI => by
      obtain ⟨L', ⟨N, hN⟩, hp⟩ := lane_start (C := C) (X := X) (ctx_lane X QS KS ax aq ak initial fuse h (by omega) i)
        hh (ctx_mem X QS KS ax aq ak initial fuse h i sh hI.1.regions hax) hI.1.x
      exact ⟨_, _, ⟨N, hN⟩, ⟨inv_act (ctx_arr X QS KS ax aq ak initial fuse h i) hI.1,
        arr_act (ctx_arr X QS KS ax aq ak initial fuse h i) hI.2⟩, L', rfl, hp⟩)
    sh ⟨hI, fun j hj => absurd hj (by omega)⟩
  choose LU hLU hpU using hU
  obtain ⟨V, sh2, ⟨N2, hN2⟩, ⟨hI2, -⟩, hV⟩ := mapM_ofFn_ev
    (fun i => { U i with status := .running }.set 20 (.f32 (headSum C fuse X h))) (runThread C)
    (fun i sh => Inv C fuse X QS KS ax aq ak initial (32 * h + i) sh ∧
      ∀ j : Fin 32, Holds C X h j (sh.bytes (6 + (32 * h + j))))
    (fun _ t => t.status = .done)
    (fun i sh hI => by
      have hc := ctx_lane X QS KS ax aq ak initial fuse h (by omega) i
      dsimp only
      rw [hLU i]
      have ra : sh.regions (((launch X QS KS ax aq ak initial).ctxAt fuse h 0 0 (32 * 0 + i)).threadArray 0) =
          some ⟨.thread, 8, 2⟩ := by
        rw [hI.1.regions, ctx_arr]; exact launch_rt X QS KS ax aq ak initial _
      have harr : Holds C X h i (sh.bytes (((launch X QS KS ax aq ak initial).ctxAt fuse h 0 0 (32 * 0 + i)).threadArray 0)) := by
        rw [ctx_arr]; exact hI.2 i
      have a6 := ctx_arr X QS KS ax aq ak initial fuse h i
      by_cases hq : h < 16
      · obtain ⟨L'', N, hN⟩ := lane_norm (C := C) (X := X) hc (out := 3) (sc := 1) (SC := QS) (as := aq)
          ⟨by rw [hI.1.regions]; rfl, haq, by rw [hI.1.regions]; rfl, ra, hI.1.qs, harr, by decide, by omega⟩
          (by rw [decide_eq_true hq]; rfl) (fun L hp => ⟨hp.q, hp.qs⟩) (LU i) (hpU i) (headSum C fuse X h)
        refine ⟨_, _, ⟨N, hN⟩, ⟨inv_q hq i.isLt (ctx_thread X QS KS ax aq ak initial fuse h i)
          (ctx_group X QS KS ax aq ak initial fuse h i) hI.1, fun j => ?_⟩, rfl⟩
        rw [qkMem_bytes (by omega) 4]; exact hI.2 j
      · obtain ⟨L'', N, hN⟩ := lane_norm (C := C) (X := X) hc (out := 4) (sc := 2) (SC := KS) (as := ak)
          ⟨by rw [hI.1.regions]; rfl, hak, by rw [hI.1.regions]; rfl, ra, hI.1.ks, harr, by decide, by omega⟩
          (by rw [decide_eq_false hq]; rfl) (fun L hp => ⟨hp.k, hp.ks⟩) (LU i) (hpU i) (headSum C fuse X h)
        refine ⟨_, _, ⟨N, hN⟩, ⟨inv_k ⟨by omega, hh⟩ i.isLt (ctx_thread X QS KS ax aq ak initial fuse h i)
          (ctx_group X QS KS ax aq ak initial fuse h i) hI.1, fun j => ?_⟩, rfl⟩
        rw [qkMem_bytes (by omega) 4]; exact hI.2 j)
    sh1 ⟨by simpa using hI1, fun j => hA1 j j.isLt⟩
  refine ⟨V, sh2, ⟨max N1 N2, fun m hm => ?_⟩, hI2, hV⟩
  rw [runSimd_collective_ofFn C m 1 _ U sh sh1 2 20 .sum .f32 0 (fun i => .f32 (laneSum C fuse X h i 4))
    (fun _ => .f32 (headSum C fuse X h)) (hN1 m (le_trans (le_max_left _ _) hm)) (fun i => by rw [hLU i])
    (resolve_sum C 0 _)]
  exact runSimd_blocked_ofFn C m 0 _ V sh1 sh2 (hN2 m (le_trans (le_max_right _ _) hm)) (fun i => by rw [hV i]; rfl)

/-- A threadgroup: its one SIMD-group runs to the end. -/
theorem group_run (hax : 2 ∣ ax) (haq : 2 ∣ aq) (hak : 2 ∣ ak) {h : Nat} (hh : h < 80) (sh : Shared)
    (hI : Inv C fuse X QS KS ax aq ak initial (32 * h) sh) :
    ∃ sh', (∃ N, ∀ m ≥ N, (runGroup C m 2 1 (List.ofFn fun s : Fin 1 =>
      List.ofFn ((launch X QS KS ax aq ak initial).lanes fuse h 0 0 s))).run sh = some ((), sh')) ∧
      Inv C fuse X QS KS ax aq ak initial (32 * h + 32) sh' := by
  obtain ⟨V, sh', ⟨N, hN⟩, hI', hV⟩ : ∃ (V : Fin 32 → Thread) (sh' : Shared), (∃ N, ∀ m ≥ N,
      (runSimd C m 2 (List.ofFn ((launch X QS KS ax aq ak initial).lanes fuse h 0 0 0))).run sh =
        some (List.ofFn V, sh')) ∧
      Inv C fuse X QS KS ax aq ak initial (32 * h + 32) sh' ∧ ∀ i, (V i).status = .done := by
    by_cases h32 : h < 32
    · exact simd_norm hax haq hak h32 sh hI
    · exact simd_value hax ⟨by omega, hh⟩ sh hI
  refine ⟨sh', ⟨N, fun m hm => ?_⟩, hI'⟩
  obtain ⟨sh'', hr, hs⟩ := runGroup_done_inv C m 2 0 (fun s : Fin 1 => (launch X QS KS ax aq ak initial).lanes fuse h 0 0 s)
    (fun j s => if j = 0 then s = sh else s = sh')
    (fun j s hs => by
      obtain rfl : j = 0 := Subsingleton.elim _ _
      simp only [Fin.val_zero, ite_true] at hs
      subst hs
      exact ⟨V, sh', hN m hm, by simp, hV⟩) sh (by simp)
  simp only [one_ne_zero, ite_false] at hs
  rw [← hs]
  exact hr

theorem inv_initial (garbage : Garbage) :
    Inv C fuse X QS KS ax aq ak initial 0 ((launch X QS KS ax aq ak initial).initial garbage) where
  regions := rfl
  x := rfl
  qs := rfl
  ks := rfl
  epoch := rfl
  q := fun _ _ ho => absurd ho (Nat.not_lt_zero _)
  k := fun _ _ ho => absurd ho (Nat.not_lt_zero _)
  v := fun _ _ ho => absurd ho (Nat.not_lt_zero _)
  log := fun _ ha => by simp [Launch.initial] at ha

/-- The launch: its 80 threadgroups in order. -/
theorem launch_ok (hax : 2 ∣ ax) (haq : 2 ∣ aq) (hak : 2 ∣ ak) (garbage : Garbage) :
    ∃ sh fuel, Inv C fuse X QS KS ax aq ak initial 2560 sh ∧
      runLaunch C fuse (launch X QS KS ax aq ak initial) garbage fuel 2 1 = some ⟨sh.bytes, sh.log⟩ := by
  obtain ⟨sh, fuel, hI, hr⟩ := launch_run_fuel C (tiles X QS KS ax aq ak initial) fuse garbage 2 1
    (fun g sh => Inv C fuse X QS KS ax aq ak initial (32 * g) sh) (inv_initial garbage)
    (fun bx byy bz hx hy hz sh hI => by
      obtain rfl : byy = 0 := by omega
      obtain rfl : bz = 0 := by omega
      simp only [Nat.zero_mul, Nat.add_zero] at hI ⊢
      rw [Launch.resetGroup_none _ _ _ _ rfl]
      obtain ⟨sh', hrun, hI'⟩ := group_run hax haq hak hx sh hI
      exact ⟨sh', hrun, by rw [show 32 * (bx + 1) = 32 * bx + 32 by ring]; exact hI'⟩)
  exact ⟨sh, fuel, hI, hr⟩

end Run

/-! ## The GPU theorem -/

theorem clip_eq (Q K V : ByteMemory.Bytes) (hQ : ∀ b, 4096 ≤ b → Q b = 0) (hK : ∀ b, 4096 ≤ b → K b = 0)
    (hV : ∀ b, 12288 ≤ b → V b = 0) : clip [4096, 4096, 12288] (fun i => [Q, K, V].getD i (fun _ => 0)) = [Q, K, V] := by
  unfold clip
  rw [show [4096, 4096, 12288].zipIdx = [(4096, 0), (4096, 1), (12288, 2)] from rfl]
  simp only [List.map_cons, List.map_nil, List.cons.injEq, and_true]
  refine ⟨?_, ?_, ?_⟩ <;> funext b <;> split
  · rfl
  · exact (hQ b (by omega)).symm
  · rfl
  · exact (hK b (by omega)).symm
  · rfl
  · exact (hV b (by omega)).symm

theorem bytesOf_zero (n : Nat) (f : Nat → BF) (b : Nat) (hb : n ≤ b) : bytesOf n f b = 0 := by
  unfold bytesOf; rw [ite_eq_right (by omega)]

variable (C : M1Max.Contract)

/-- **The GPU runs silu-rms-heads as specified.** Under the GPU assumption, MLX's launch of the exact
assembled text at `headsConfig` on any `x`, `qscale`, `kscale` (bf16 buffers whose base addresses are 2-aligned)
produces `q`, `k` and `v` whose every element is the source's value: the SiLU-activated column of `x`, for the
32 q and k heads normalized by the head's `simd_sum` of squares and scaled by `qscale` or `kscale`, for the
48 v heads as is — at the compiler's contraction choice at the squaring sum. -/
theorem gpu_output (G : Gpu C) (hmax : 32 ≤ G.maxThreads Metal.Elab.Tests.siluRmsHeadsText)
    (X QS KS : ByteMemory.Bytes) (ax aq ak : Nat) (hax : 2 ∣ ax) (haq : 2 ∣ aq) (hak : 2 ∣ ak) :
    G.execute Metal.Elab.Tests.siluRmsHeadsText (2560, 1, 1) (32, 1, 1)
      [⟨.device, 20480, ax, X⟩, ⟨.device, 256, aq, QS⟩, ⟨.device, 256, ak, KS⟩] [4096, 4096, 12288] =
      some [bytesOf 4096 (qOut C (G.fusion Metal.Elab.Tests.siluRmsHeadsText) X QS),
        bytesOf 4096 (kOut C (G.fusion Metal.Elab.Tests.siluRmsHeadsText) X KS),
        bytesOf 12288 (vOut C X)] := by
  rw [← clip_eq _ _ _ (bytesOf_zero _ _) (bytesOf_zero _ _) (bytesOf_zero _ _)]
  apply gpu_owned C G _ compile_eq (by simpa using hmax)
  intro initial garbage
  obtain ⟨sh, fuel, hI, hr⟩ := launch_ok (C := C) (fuse := G.fusion Metal.Elab.Tests.siluRmsHeadsText) (X := X)
    (QS := QS) (KS := KS) (initial := initial) hax haq hak garbage
  refine ⟨fuel, 2, 1, sh, dev, tgo, hr, hI.log, fun i hi b hb => ?_⟩
  simp only [List.length_cons, List.length_nil] at hi
  rcases (by omega : i = 0 ∨ i = 1 ∨ i = 2) with rfl | rfl | rfl
  · exact hI.q b hb (by have := qThread_lt hb; omega)
  · exact hI.k b hb (by have := kThread_bounds hb; omega)
  · exact hI.v b hb (vThread_lt hb)

end Metal.Kernels.SiluRmsHeads

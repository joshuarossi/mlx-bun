import metal.Logic
import metal.Launch
import metal.tests.Elab
import metal.Gpu
import metal.Steps
import metal.Group
import metal.Memory
import metal.Fuel

namespace Metal.Kernels.GatedDeltaStep
open Metal Metal.Core Inference.Contracts.Mlx

/-! # gated.ts gated_delta_step

```
const int T = Tin[0];
auto n = thread_position_in_grid.z;
auto b_idx = n / Hv;
auto hv_idx = n % Hv;
auto hk_idx = hv_idx / (Hv / Hk);
constexpr int n_per_t = Dk / 32;

// q, k: [B, T, Hk, Dk]
auto q_ = q + b_idx * T * Hk * Dk + hk_idx * Dk;
auto k_ = k + b_idx * T * Hk * Dk + hk_idx * Dk;

// v, y: [B, T, Hv, Dv]
auto v_ = v + b_idx * T * Hv * Dv + hv_idx * Dv;
y += b_idx * T * Hv * Dv + hv_idx * Dv;

auto dk_idx = thread_position_in_threadgroup.x;
auto dv_idx = thread_position_in_grid.y;

// state_in, state_out: [B, Hv, Dv, Dk]
auto i_state = state_in + (n * Dv + dv_idx) * Dk;
auto o_state = state_out + (n * Dv + dv_idx) * Dk;

float state[n_per_t];
for (int i = 0; i < n_per_t; ++i) {
  auto s_idx = n_per_t * dk_idx + i;
  state[i] = static_cast<float>(i_state[s_idx]);
}

// g: [B, T, Hv]
auto g_ = g + b_idx * T * Hv;
auto beta_ = beta + b_idx * T * Hv;

for (int t = 0; t < T; ++t) {
  if (true) {
    float kv_mem = 0.0f;
    for (int i = 0; i < n_per_t; ++i) {
      auto s_idx = n_per_t * dk_idx + i;
      state[i] = state[i] * g_[hv_idx];
      kv_mem += state[i] * k_[s_idx];
    }
    kv_mem = simd_sum(kv_mem);

    auto delta = (v_[dv_idx] - kv_mem) * beta_[hv_idx];

    float out = 0.0f;
    for (int i = 0; i < n_per_t; ++i) {
      auto s_idx = n_per_t * dk_idx + i;
      state[i] = state[i] + k_[s_idx] * delta;
      out += state[i] * q_[s_idx];
    }
    out = simd_sum(out);
    if (thread_index_in_simdgroup == 0) {
      y[dv_idx] = static_cast<InT>(out);
    }
  } else {
    y[dv_idx] = static_cast<InT>(0);
  }
  // Increment data pointers to next time step
  q_ += Hk * Dk;
  k_ += Hk * Dk;
  v_ += Hv * Dv;
  y += Hv * Dv;
  g_ += Hv;
  beta_ += Hv;
}
for (int i = 0; i < n_per_t; ++i) {
  auto s_idx = n_per_t * dk_idx + i;
  o_state[s_idx] = static_cast<StT>(state[i]);
}
```
at `gatedConfig` (B = T = 1): grid [32, 128, 48], threadgroup [32, 4, 1], so 32 × 48 threadgroups of 4 SIMD-groups
(lane `dk_idx` of `n = b·Hv + hv`, row `dv_idx`), with InT = bfloat, StT = float, Dk = Dv = 128, Hk = 16, Hv = 48. -/

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)
def u16l (n : Nat) : CExpr := .lit (.int .u16 n)
def i32l (n : Nat) : CExpr := .lit (.int .i32 n)
def f32l (bits : Nat) : CExpr := .lit (.f32 (Val.ofF32Bits bits))

/-- `i < n_per_t` and `++i` for the loop counter in slot `i`. -/
def lt4 (i : Nat) : CExpr := .bin .lt .i32 0 (.local i) (i32l 4)
def inc (i : Nat) : List CStmt := [.set i (.bin .add .i32 0 (.local i) (i32l 1))]
/-- `s_idx = n_per_t * dk_idx + i`. -/
def sIdx (i : Nat) : CExpr := .bin .add .u32 0 (.bin .mul .u32 0 (u32l 4) (.local 17)) (.conv .u32 (.local i))
/-- `state + i`, `state[i]`, and `float(p[s])`. -/
def stateAt (i : Nat) : CExpr := .offset (.local 21) (.local i)
def stateLoad (i : Nat) : CExpr := .load (.scalar .f32) (stateAt i)
def floatAt (p s : Nat) : CExpr := .conv .f32 (.load (.scalar .bf16) (.offset (.local p) (.local s)))

/-- `b_idx * T * Hk * Dk`, `b_idx * T * Hv`, `b_idx * T * Hv * Dv`, `(n * Dv + dv_idx) * Dk`. -/
def qkBatch : CExpr :=
  .bin .mul .u32 0 (.bin .mul .u32 0 (.bin .mul .u32 0 (.local 11) (.conv .u32 (.local 9))) (u32l 16)) (u32l 128)
def gBatch : CExpr := .bin .mul .u32 0 (.bin .mul .u32 0 (.local 11) (.conv .u32 (.local 9))) (u32l 48)
def vBatch : CExpr := .bin .mul .u32 0 gBatch (u32l 128)
def stateRow : CExpr :=
  .bin .mul .u32 0 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 10) (u32l 128)) (.local 18)) (u32l 128)

def loadBody : List CStmt :=
  [.set 23 (sIdx 22), .store (.scalar .f32) (stateAt 22) (.load (.scalar .f32) (.offset (.local 19) (.local 23)))]
def loadLoop : CStmt := .loop (lt4 22) (inc 22) loadBody

def decayBody : List CStmt :=
  [.set 29 (sIdx 28),
   .store (.scalar .f32) (stateAt 28)
     (.bin .mul .f32 0 (stateLoad 28) (.load (.scalar .f32) (.offset (.local 24) (.local 12)))),
   .set 27 (.bin .add .f32 1 (.local 27) (.bin .mul .f32 0 (stateLoad 28) (floatAt 15 29)))]
def decayLoop : CStmt := .loop (lt4 28) (inc 28) decayBody
def deltaExpr : CExpr :=
  .bin .mul .f32 0 (.bin .sub .f32 0 (floatAt 16 18) (.local 27)) (floatAt 25 12)

def updateBody : List CStmt :=
  [.set 34 (sIdx 33),
   .store (.scalar .f32) (stateAt 33) (.bin .add .f32 3 (stateLoad 33) (.bin .mul .f32 0 (floatAt 15 34) (.local 31))),
   .set 32 (.bin .add .f32 4 (.local 32) (.bin .mul .f32 0 (stateLoad 33) (floatAt 14 34)))]
def updateLoop : CStmt := .loop (lt4 33) (inc 33) updateBody
def yStore : CStmt :=
  .ite (.bin .eq .u32 0 (.coord .threadIndexInSimdgroup) (u32l 0))
    [.store (.scalar .bf16) (.offset (.local 7) (.local 18)) (.conv .bf16 (.local 32))] []

/-- One time step; the trailing statements advance the data pointers. -/
def stepBody : List CStmt :=
  [.set 27 (f32l 0x0),
   .set 28 (i32l 0),
   decayLoop,
   .collective 2 30 .sum .f32 (.local 27) (u16l 0),
   .set 27 (.local 30),
   .set 31 deltaExpr,
   .set 32 (f32l 0x0),
   .set 33 (i32l 0),
   updateLoop,
   .collective 5 35 .sum .f32 (.local 32) (u16l 0),
   .set 32 (.local 35),
   yStore,
   .set 14 (.offset (.local 14) (i32l 2048)),
   .set 15 (.offset (.local 15) (i32l 2048)),
   .set 16 (.offset (.local 16) (i32l 6144)),
   .set 7 (.offset (.local 7) (i32l 6144)),
   .set 24 (.offset (.local 24) (i32l 48)),
   .set 25 (.offset (.local 25) (i32l 48))]

def storeBody : List CStmt :=
  [.set 37 (sIdx 36), .store (.scalar .f32) (.offset (.local 20) (.local 37)) (.load (.scalar .f32) (stateAt 36))]

/-- Slots: 0 q, 1 k, 2 v, 3 g, 4 beta, 5 state_in, 6 Tin, 7 y (advanced in place), 8 state_out, 9 T, 10 n,
11 b_idx, 12 hv_idx, 13 hk_idx, 14 q_, 15 k_, 16 v_, 17 dk_idx, 18 dv_idx, 19 i_state, 20 o_state,
21 state (thread array 0), 22 i, 23 s_idx, 24 g_, 25 beta_, 26 t, 27 kv_mem, 28 i, 29 s_idx,
30 the first `simd_sum` result, 31 delta, 32 out, 33 i, 34 s_idx, 35 the second `simd_sum` result, 36 i, 37 s_idx. -/
def body : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .bf16⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .bf16⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .f32⟩)),
   .set 4 (.lit (.ptr ⟨4, 0, .scalar .bf16⟩)),
   .set 5 (.lit (.ptr ⟨5, 0, .scalar .f32⟩)),
   .set 6 (.lit (.ptr ⟨6, 0, .scalar .i32⟩)),
   .set 7 (.lit (.ptr ⟨7, 0, .scalar .bf16⟩)),
   .set 8 (.lit (.ptr ⟨8, 0, .scalar .f32⟩)),
   .set 9 (.load (.scalar .i32) (.offset (.local 6) (i32l 0))),
   .set 10 (.component (.coord .threadPositionInGrid) (u32l 2)),
   .set 11 (.bin .div .u32 0 (.local 10) (u32l 48)),
   .set 12 (.bin .rem .u32 0 (.local 10) (u32l 48)),
   .set 13 (.bin .div .u32 0 (.local 12) (u32l 3)),
   .set 14 (.offset (.offset (.local 0) qkBatch) (.bin .mul .u32 0 (.local 13) (u32l 128))),
   .set 15 (.offset (.offset (.local 1) qkBatch) (.bin .mul .u32 0 (.local 13) (u32l 128))),
   .set 16 (.offset (.offset (.local 2) vBatch) (.bin .mul .u32 0 (.local 12) (u32l 128))),
   .set 7 (.offset (.local 7) (.bin .add .u32 0 vBatch (.bin .mul .u32 0 (.local 12) (u32l 128)))),
   .set 17 (.component (.coord .threadPositionInThreadgroup) (u32l 0)),
   .set 18 (.component (.coord .threadPositionInGrid) (u32l 1)),
   .set 19 (.offset (.local 5) stateRow),
   .set 20 (.offset (.local 8) stateRow),
   .array 21 false 0 (.scalar .f32),
   .set 22 (i32l 0),
   loadLoop,
   .set 24 (.offset (.local 3) gBatch),
   .set 25 (.offset (.local 4) gBatch),
   .set 26 (i32l 0),
   .loop (.bin .lt .i32 0 (.local 26) (.local 9)) (inc 26) stepBody,
   .set 36 (i32l 0),
   .loop (lt4 36) (inc 36) storeBody]

def core : Kernel := ⟨9, [], [(.scalar .f32, 4)], body⟩

-- The elaborated text MLX compiles (tests/Assemble.lean) is `core`.
kernel_rfl compile_eq : (frontend Metal.Elab.Tests.gatedDeltaStepText).bind elaborate = some core

/-! ## What the kernel computes -/

/-- The input buffers' contents: `q`, `k` [1, 1, 16, 128] bf16, `v` [1, 1, 48, 128] bf16, `g` [1, 1, 48] f32,
`beta` [1, 1, 48] bf16, `state_in` [1, 48, 128, 128] f32 and `T` [1] int32. -/
structure Ins where
  q : ByteMemory.Bytes
  k : ByteMemory.Bytes
  v : ByteMemory.Bytes
  g : ByteMemory.Bytes
  beta : ByteMemory.Bytes
  state : ByteMemory.Bytes
  t : ByteMemory.Bytes

section Spec
variable (C : M1Max.Contract) (fuse : Nat → Bool) (I : Ins)

/-- `i_state[s_idx]` for head `n` (= `hv_idx`), row `r` (= `dv_idx`), column `c` (= `s_idx`). -/
def stateIn (n r c : Nat) : Float32 := f32At I.state ((n * 128 + r) * 128 + c)

/-- `float(k_[s_idx])` and `float(q_[s_idx])`: key head `n / 3` (= `hk_idx`), column `c`. -/
def keyAt (n c : Nat) : Float32 := C.widen (bfAt I.k (n / 3 * 128 + c))
def queryAt (n c : Nat) : Float32 := C.widen (bfAt I.q (n / 3 * 128 + c))

/-- `state[i] = state[i] * g_[hv_idx]` -/
def decayed (n r c : Nat) : Float32 := C.fmul (stateIn I n r c) (f32At I.g n)

/-- Lane `d`'s `kv_mem` after its first `j` columns: `kv_mem += state[i] * k_[s_idx]` at contraction site 1. -/
def kvPart (n r d : Nat) : Nat → Float32
  | 0 => Val.ofF32Bits 0
  | j + 1 => if fuse 1 then C.fma (decayed C I n r (4 * d + j)) (keyAt C I n (4 * d + j)) (kvPart n r d j)
      else C.fadd (kvPart n r d j) (C.fmul (decayed C I n r (4 * d + j)) (keyAt C I n (4 * d + j)))

/-- `kv_mem = simd_sum(kv_mem)` over the 32 lanes of row `r`. -/
def kvMem (n r : Nat) : Float32 := C.simdSum fun d => kvPart C fuse I n r d 4

/-- `delta = (v_[dv_idx] - kv_mem) * beta_[hv_idx]`. -/
def delta (n r : Nat) : Float32 :=
  C.fmul (C.fadd (C.widen (bfAt I.v (n * 128 + r))) (f32Neg (kvMem C fuse I n r))) (C.widen (bfAt I.beta n))

/-- `state[i] = state[i] + k_[s_idx] * delta` at contraction site 3. -/
def updated (n r c : Nat) : Float32 :=
  if fuse 3 then C.fma (keyAt C I n c) (delta C fuse I n r) (decayed C I n r c)
  else C.fadd (decayed C I n r c) (C.fmul (keyAt C I n c) (delta C fuse I n r))

/-- Lane `d`'s `out` after its first `j` columns: `out += state[i] * q_[s_idx]` at contraction site 4. -/
def outPart (n r d : Nat) : Nat → Float32
  | 0 => Val.ofF32Bits 0
  | j + 1 => if fuse 4 then C.fma (updated C fuse I n r (4 * d + j)) (queryAt C I n (4 * d + j)) (outPart n r d j)
      else C.fadd (outPart n r d j) (C.fmul (updated C fuse I n r (4 * d + j)) (queryAt C I n (4 * d + j)))

/-- `out = simd_sum(out)` over the 32 lanes of row `r`. -/
def outSum (n r : Nat) : Float32 := C.simdSum fun d => outPart C fuse I n r d 4

/-- `y` element `e` (head `e / 128`, row `e % 128`): `InT(out)`. -/
def yOut (e : Nat) : BF := C.narrow (outSum C fuse I (e / 128) (e % 128))

/-- `state_out` element `e` (head `e / 128 / 128`, row `e / 128 % 128`, column `e % 128`): `state[i]`. -/
def stateOut (e : Nat) : Float32 := updated C fuse I (e / 128 / 128) (e / 128 % 128) (e % 128)

end Spec

/-- Byte `b` of an `n`-byte bf16 output with elements `f`. -/
def bytes2 (n : Nat) (f : Nat → BF) (b : Nat) : BitVec 8 :=
  if b < n then (wordBytes 2 (Val.bf16Bits (f (b / 2)))).getD (b % 2) 0 else 0

/-- Byte `b` of an `n`-byte binary32 output with elements `f`. -/
def bytes4 (n : Nat) (f : Nat → Float32) (b : Nat) : BitVec 8 :=
  if b < n then (wordBytes 4 (Val.f32Bits (f (b / 4)))).getD (b % 4) 0 else 0

/-! ## A thread -/

/-- The input buffers' alignments. -/
structure Al where
  q : Nat
  k : Nat
  v : Nat
  g : Nat
  beta : Nat
  state : Nat
  t : Nat

/-- The regions a thread accesses. -/
structure Regs (ctx : Ctx) (A : Al) (R : Nat → Option Region) : Prop where
  q : R 0 = some ⟨.device, 4096, A.q⟩
  k : R 1 = some ⟨.device, 4096, A.k⟩
  v : R 2 = some ⟨.device, 12288, A.v⟩
  g : R 3 = some ⟨.device, 192, A.g⟩
  beta : R 4 = some ⟨.device, 96, A.beta⟩
  state : R 5 = some ⟨.device, 3145728, A.state⟩
  t : R 6 = some ⟨.constant, 4, A.t⟩
  y : R 7 = some ⟨.device, 12288, 16⟩
  so : R 8 = some ⟨.device, 3145728, 16⟩
  arr : R (ctx.threadArray 0) = some ⟨.thread, 16, 4⟩
  a9 : 9 ≤ ctx.threadArray 0
  aq : 2 ∣ A.q
  ak : 2 ∣ A.k
  av : 2 ∣ A.v
  ag : 4 ∣ A.g
  ab : 2 ∣ A.beta
  as : 4 ∣ A.state
  aT : 4 ∣ A.t

/-- The input buffers hold `I`. -/
structure Inputs (I : Ins) (M : Nat → ByteMemory.Bytes) : Prop where
  q : M 0 = I.q
  k : M 1 = I.k
  v : M 2 = I.v
  g : M 3 = I.g
  beta : M 4 = I.beta
  state : M 5 = I.state
  t : M 6 = I.t

theorem Inputs.of {I : Ins} {M M' : Nat → ByteMemory.Bytes} (h : Inputs I M) (hM : ∀ r < 7, M' r = M r) :
    Inputs I M' :=
  ⟨(hM 0 (by decide)).trans h.q, (hM 1 (by decide)).trans h.k, (hM 2 (by decide)).trans h.v,
    (hM 3 (by decide)).trans h.g, (hM 4 (by decide)).trans h.beta, (hM 5 (by decide)).trans h.state,
    (hM 6 (by decide)).trans h.t⟩

section Thread
variable (C : M1Max.Contract) (fuse : Nat → Bool)

/-- Lane `d` of row `r` of head `n`. -/
structure Lane (ctx : Ctx) (n r d : Nat) : Prop where
  grid : ctx.coord .threadPositionInGrid = u32x3 d r n
  tg : ctx.coord .threadPositionInThreadgroup = u32x3 d (r % 4) 0
  lane : ctx.coord .threadIndexInSimdgroup = u32 d
  fuse : ctx.fuse = fuse
  hd : d < 32
  hr : r < 128
  hn : n < 48

/-- The locals the code reads after its declarations. -/
structure Pre (ctx : Ctx) (n r d : Nat) (L : Locals) : Prop where
  g : L 3 = some (.ptr ⟨3, 0, .scalar .f32⟩)
  beta : L 4 = some (.ptr ⟨4, 0, .scalar .bf16⟩)
  y : L 7 = some (.ptr ⟨7, ((2 * (n * 128) : Nat) : Int), .scalar .bf16⟩)
  T : L 9 = some (.int .i32 1)
  b : L 11 = some (u32 0)
  hv : L 12 = some (u32 n)
  q : L 14 = some (.ptr ⟨0, ((2 * (n / 3 * 128) : Nat) : Int), .scalar .bf16⟩)
  k : L 15 = some (.ptr ⟨1, ((2 * (n / 3 * 128) : Nat) : Int), .scalar .bf16⟩)
  v : L 16 = some (.ptr ⟨2, ((2 * (n * 128) : Nat) : Int), .scalar .bf16⟩)
  dk : L 17 = some (u32 d)
  dv : L 18 = some (u32 r)
  si : L 19 = some (.ptr ⟨5, ((4 * ((n * 128 + r) * 128) : Nat) : Int), .scalar .f32⟩)
  so : L 20 = some (.ptr ⟨8, ((4 * ((n * 128 + r) * 128) : Nat) : Int), .scalar .f32⟩)
  arr : L 21 = some (.ptr ⟨ctx.threadArray 0, 0, .scalar .f32⟩)

theorem Pre.set {ctx : Ctx} {n r d : Nat} {L : Locals} (hp : Pre ctx n r d L) {slot : Nat} (v : Val) (hs : 22 ≤ slot) :
    Pre ctx n r d (setLocal L slot v) :=
  ⟨(setLocal_other L v (by omega)).trans hp.g, (setLocal_other L v (by omega)).trans hp.beta,
    (setLocal_other L v (by omega)).trans hp.y, (setLocal_other L v (by omega)).trans hp.T,
    (setLocal_other L v (by omega)).trans hp.b, (setLocal_other L v (by omega)).trans hp.hv,
    (setLocal_other L v (by omega)).trans hp.q, (setLocal_other L v (by omega)).trans hp.k,
    (setLocal_other L v (by omega)).trans hp.v, (setLocal_other L v (by omega)).trans hp.dk,
    (setLocal_other L v (by omega)).trans hp.dv, (setLocal_other L v (by omega)).trans hp.si,
    (setLocal_other L v (by omega)).trans hp.so, (setLocal_other L v (by omega)).trans hp.arr⟩

/-- The declarations before the load loop. -/
def decls : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .bf16⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .bf16⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .f32⟩)),
   .set 4 (.lit (.ptr ⟨4, 0, .scalar .bf16⟩)),
   .set 5 (.lit (.ptr ⟨5, 0, .scalar .f32⟩)),
   .set 6 (.lit (.ptr ⟨6, 0, .scalar .i32⟩)),
   .set 7 (.lit (.ptr ⟨7, 0, .scalar .bf16⟩)),
   .set 8 (.lit (.ptr ⟨8, 0, .scalar .f32⟩)),
   .set 9 (.load (.scalar .i32) (.offset (.local 6) (i32l 0))),
   .set 10 (.component (.coord .threadPositionInGrid) (u32l 2)),
   .set 11 (.bin .div .u32 0 (.local 10) (u32l 48)),
   .set 12 (.bin .rem .u32 0 (.local 10) (u32l 48)),
   .set 13 (.bin .div .u32 0 (.local 12) (u32l 3)),
   .set 14 (.offset (.offset (.local 0) qkBatch) (.bin .mul .u32 0 (.local 13) (u32l 128))),
   .set 15 (.offset (.offset (.local 1) qkBatch) (.bin .mul .u32 0 (.local 13) (u32l 128))),
   .set 16 (.offset (.offset (.local 2) vBatch) (.bin .mul .u32 0 (.local 12) (u32l 128))),
   .set 7 (.offset (.local 7) (.bin .add .u32 0 vBatch (.bin .mul .u32 0 (.local 12) (u32l 128)))),
   .set 17 (.component (.coord .threadPositionInThreadgroup) (u32l 0)),
   .set 18 (.component (.coord .threadPositionInGrid) (u32l 1)),
   .set 19 (.offset (.local 5) stateRow),
   .set 20 (.offset (.local 8) stateRow),
   .array 21 false 0 (.scalar .f32),
   .set 22 (i32l 0)]

/-- What follows the load loop before the time loop, and after it. -/
def mid : List CStmt := [.set 24 (.offset (.local 3) gBatch), .set 25 (.offset (.local 4) gBatch), .set 26 (i32l 0)]
def timeLoop : CStmt := .loop (.bin .lt .i32 0 (.local 26) (.local 9)) (inc 26) stepBody
def tail : List CStmt := [.set 36 (i32l 0), .loop (lt4 36) (inc 36) storeBody]

theorem body_eq : body = decls ++ ([loadLoop] ++ (mid ++ (timeLoop :: tail))) := rfl

end Thread

/-! ## Expressions -/

section Eval
variable (C : M1Max.Contract) {ctx : Ctx} {L : Locals} {sh : Shared}

theorem eval_qkBatch (h11 : L 11 = some (u32 0)) (h9 : L 9 = some (.int .i32 1)) :
    (eval C ctx L qkBatch).run sh = some (u32 0, sh) :=
  eval_int C (by decide) (eval_int C (by decide) (eval_int C (by decide) (eval_local C ctx L 11 _ h11 sh)
    (eval_conv C (eval_local C ctx L 9 _ h9 sh) (convert_u32_i32 C 1 (by decide))) (binary_mul_u32 C 0 1))
    (eval_lit C _ _ _ _) (binary_mul_u32 C (0 * 1) 16)) (eval_lit C _ _ _ _) (binary_mul_u32 C (0 * 1 * 16) 128)

theorem eval_gBatch (h11 : L 11 = some (u32 0)) (h9 : L 9 = some (.int .i32 1)) :
    (eval C ctx L gBatch).run sh = some (u32 0, sh) :=
  eval_int C (by decide) (eval_int C (by decide) (eval_local C ctx L 11 _ h11 sh)
    (eval_conv C (eval_local C ctx L 9 _ h9 sh) (convert_u32_i32 C 1 (by decide))) (binary_mul_u32 C 0 1))
    (eval_lit C _ _ _ _) (binary_mul_u32 C (0 * 1) 48)

theorem eval_vBatch (h11 : L 11 = some (u32 0)) (h9 : L 9 = some (.int .i32 1)) :
    (eval C ctx L vBatch).run sh = some (u32 0, sh) :=
  eval_int C (by decide) (eval_gBatch C h11 h9) (eval_lit C _ _ _ _) (binary_mul_u32 C 0 128)

theorem eval_kq {P region hk : Nat} (hP : L P = some (.ptr ⟨region, 0, .scalar .bf16⟩)) (h11 : L 11 = some (u32 0))
    (h9 : L 9 = some (.int .i32 1)) (h13 : L 13 = some (u32 hk)) (hhk : hk < 16) :
    (eval C ctx L (.offset (.offset (.local P) qkBatch) (.bin .mul .u32 0 (.local 13) (u32l 128)))).run sh =
      some (.ptr ⟨region, ((2 * (hk * 128) : Nat) : Int), .scalar .bf16⟩, sh) := by
  have := eval_bf16 C (a := 0 + 0) (eval_bf16 C (a := 0) (eval_local C ctx L P _ hP sh) (eval_qkBatch C h11 h9)
    (by decide)) (eval_int C (by decide) (eval_local C ctx L 13 _ h13 sh) (eval_lit C _ _ _ _)
      (binary_mul_u32 C hk 128) : (eval C ctx L (.bin .mul .u32 0 (.local 13) (u32l 128))).run sh =
        some (u32 (hk * 128), sh)) (by omega)
  rwa [show 0 + 0 + hk * 128 = hk * 128 by omega] at this

theorem eval_vptr {n : Nat} (h2 : L 2 = some (.ptr ⟨2, 0, .scalar .bf16⟩)) (h11 : L 11 = some (u32 0))
    (h9 : L 9 = some (.int .i32 1)) (h12 : L 12 = some (u32 n)) (hn : n < 48) :
    (eval C ctx L (.offset (.offset (.local 2) vBatch) (.bin .mul .u32 0 (.local 12) (u32l 128)))).run sh =
      some (.ptr ⟨2, ((2 * (n * 128) : Nat) : Int), .scalar .bf16⟩, sh) := by
  have := eval_bf16 C (a := 0 + 0) (eval_bf16 C (a := 0) (eval_local C ctx L 2 _ h2 sh) (eval_vBatch C h11 h9)
    (by decide)) (eval_int C (by decide) (eval_local C ctx L 12 _ h12 sh) (eval_lit C _ _ _ _)
      (binary_mul_u32 C n 128) : (eval C ctx L (.bin .mul .u32 0 (.local 12) (u32l 128))).run sh =
        some (u32 (n * 128), sh)) (by omega)
  rwa [show 0 + 0 + n * 128 = n * 128 by omega] at this

theorem eval_yptr {n : Nat} (h7 : L 7 = some (.ptr ⟨7, 0, .scalar .bf16⟩)) (h11 : L 11 = some (u32 0))
    (h9 : L 9 = some (.int .i32 1)) (h12 : L 12 = some (u32 n)) (hn : n < 48) :
    (eval C ctx L (.offset (.local 7) (.bin .add .u32 0 vBatch (.bin .mul .u32 0 (.local 12) (u32l 128))))).run sh =
      some (.ptr ⟨7, ((2 * (n * 128) : Nat) : Int), .scalar .bf16⟩, sh) := by
  have := eval_bf16 C (a := 0) (eval_local C ctx L 7 _ h7 sh) (eval_int C (by decide) (eval_vBatch C h11 h9)
    (eval_int C (by decide) (eval_local C ctx L 12 _ h12 sh) (eval_lit C _ _ _ _) (binary_mul_u32 C n 128))
    (binary_add_u32 C 0 (n * 128)) : (eval C ctx L (.bin .add .u32 0 vBatch
      (.bin .mul .u32 0 (.local 12) (u32l 128)))).run sh = some (u32 (0 + n * 128), sh)) (by omega)
  rwa [show 0 + (0 + n * 128) = n * 128 by omega] at this

theorem eval_srow {P region n r : Nat} (hP : L P = some (.ptr ⟨region, 0, .scalar .f32⟩)) (h10 : L 10 = some (u32 n))
    (h18 : L 18 = some (u32 r)) (hn : n < 48) (hr : r < 128) :
    (eval C ctx L (.offset (.local P) stateRow)).run sh =
      some (.ptr ⟨region, ((4 * ((n * 128 + r) * 128) : Nat) : Int), .scalar .f32⟩, sh) := by
  have := eval_f32p C (a := 0) (eval_local C ctx L P _ hP sh) (eval_int C (by decide) (eval_int C (by decide)
    (eval_int C (by decide) (eval_local C ctx L 10 _ h10 sh) (eval_lit C _ _ _ _) (binary_mul_u32 C n 128))
    (eval_local C ctx L 18 _ h18 sh) (binary_add_u32 C (n * 128) r)) (eval_lit C _ _ _ _)
    (binary_mul_u32 C (n * 128 + r) 128) : (eval C ctx L stateRow).run sh = some (u32 ((n * 128 + r) * 128), sh))
    (by omega)
  rwa [Nat.zero_add] at this

/-- `s_idx = n_per_t * dk_idx + i`. -/
theorem eval_sIdx {i d k : Nat} (h17 : L 17 = some (u32 d)) (hi : L i = some (.int .i32 k)) (hk : k < 2 ^ 31) :
    (eval C ctx L (sIdx i)).run sh = some (u32 (4 * d + k), sh) :=
  eval_int C (by decide) (eval_int C (by decide) (eval_lit C _ _ _ _) (eval_local C ctx L 17 _ h17 sh)
    (binary_mul_u32 C 4 d)) (eval_conv C (eval_local C ctx L i _ hi sh) (convert_u32_i32 C k hk))
    (binary_add_u32 C (4 * d) k)

theorem eval_lt4 {i k : Nat} (hi : L i = some (.int .i32 k)) (hk : k < 2 ^ 31) :
    (eval C ctx L (lt4 i)).run sh = some (.bool (decide (k < 4)), sh) :=
  eval_int C (by decide) (eval_local C ctx L i _ hi sh) (eval_lit C _ _ _ _) (binary_lt_i32 C k 4 hk (by decide))

theorem exec_inc {i k : Nat} (hi : L i = some (.int .i32 k)) (hk : k + 1 < 2 ^ 31) :
    Exec C ctx (inc i) L sh .normal (setLocal L i (.int .i32 (k + 1))) sh :=
  .set (eval_int C (by decide) (eval_local C ctx L i _ hi sh) (eval_lit C _ _ _ _) (binary_add_i32 C k 1 hk)) (.nil _ _)

/-- `state[i]` (the pointer). -/
theorem eval_stateAt {i k : Nat} (h21 : L 21 = some (.ptr ⟨ctx.threadArray 0, 0, .scalar .f32⟩))
    (hi : L i = some (.int .i32 k)) (hk : k < 2 ^ 31) :
    (eval C ctx L (stateAt i)).run sh = some (.ptr ⟨ctx.threadArray 0, ((4 * k : Nat) : Int), .scalar .f32⟩, sh) := by
  have := eval_f32i C (a := 0) (eval_local C ctx L 21 _ h21 sh) (eval_local C ctx L i _ hi sh) hk
  rwa [Nat.zero_add] at this

/-- `state[i]` (the load). -/
theorem eval_stateLoad {i k : Nat} {v : Nat → Float32} (h21 : L 21 = some (.ptr ⟨ctx.threadArray 0, 0, .scalar .f32⟩))
    (hi : L i = some (.int .i32 k)) (hk : k < 4) (ra : sh.regions (ctx.threadArray 0) = some ⟨.thread, 16, 4⟩)
    (hm : Arr (sh.bytes (ctx.threadArray 0)) v 4) :
    (eval C ctx L (stateLoad i)).run sh = some (.f32 (v k), sh) :=
  (eval_load C _ _ _ _ _ _ _ (eval_stateAt C h21 hi (by omega))).trans
    (load_f32_thread_of ctx sh _ k 16 _ ra (by omega) (hm k hk))

/-- `float(p[s])` for a bf16 buffer pointer at element `a`. -/
theorem eval_floatAt {p s region a m : Nat} {r : Region} {M : ByteMemory.Bytes}
    (hp : L p = some (.ptr ⟨region, ((2 * a : Nat) : Int), .scalar .bf16⟩)) (hs : L s = some (u32 m)) (hm : m < 2 ^ 32)
    (hr : sh.regions region = some r) (hsp : r.space = .device) (ha : 2 ∣ r.align) (hb : 2 * (a + m) + 2 ≤ r.size)
    (hM : sh.bytes region = M) :
    (eval C ctx L (floatAt p s)).run sh = some (.f32 (C.widen (bfAt M (a + m))), logged ctx sh region 2 (a + m) false) :=
  eval_conv C ((eval_load C _ _ _ _ _ _ _ (eval_bf16 C (eval_local C ctx L p _ hp sh) (eval_local C ctx L s _ hs sh)
    hm)).trans (load_bf16_logged ctx sh region (a + m) r M hr (.inl hsp) ha hb hM)) rfl

end Eval

/-! ## Phase A: to the first `simd_sum` -/

section PhaseA
variable {C : M1Max.Contract} {fuse : Nat → Bool} {ctx : Ctx} {n r d : Nat} {A : Al} {I : Ins}

theorem decls_run (hc : Lane fuse ctx n r d) {sh : Shared} (hR : Regs ctx A sh.regions) (hI : Inputs I sh.bytes)
    (hT : I.t 0 = 1 ∧ I.t 1 = 0 ∧ I.t 2 = 0 ∧ I.t 3 = 0) :
    ∃ L, Exec C ctx decls (fun _ => none) sh .normal L (logged ctx sh 6 4 0 false) ∧ Pre ctx n r d L ∧
      L 22 = some (.int .i32 0) := by
  have hd := hc.hd; have hr := hc.hr; have hn := hc.hn
  have e9 : ∀ L : Locals, L 6 = some (.ptr ⟨6, 0, .scalar .i32⟩) →
      (eval C ctx L (.load (.scalar .i32) (.offset (.local 6) (i32l 0)))).run sh =
        some (.int .i32 1, logged ctx sh 6 4 0 false) := by
    intro L h6
    have hp : (eval C ctx L (.offset (.local 6) (i32l 0))).run sh =
        some (.ptr ⟨6, ((0 : Nat) : Int), .scalar .i32⟩, sh) :=
      eval_offset_i32 C (o := 0) (eval_local C ctx L 6 _ h6 sh) (eval_lit C _ _ _ _) (by decide)
    have hw : bytesWord ((List.range 4).map fun i => sh.bytes 6 (0 + i)) = 1 := by
      rw [hI.t]
      show bytesWord [I.t (0 + 0), I.t (0 + 1), I.t (0 + 2), I.t (0 + 3)] = 1
      simp [bytesWord, hT.1, hT.2.1, hT.2.2.1, hT.2.2.2]
    have := loadAt_run ctx (.scalar .i32) ⟨6, ((0 : Nat) : Int), .scalar .i32⟩ ⟨.constant, 4, A.t⟩ sh (.int .i32 1)
      hR.t (by simp) (by simp) (by simp only [alignment, Scalar.bytes]; exact Nat.mod_eq_zero_of_dvd hR.aT)
      (by simp [loadOffset]) (by simp [loadOffset, Ty.bytes, Scalar.bytes])
      (by
        simp only [loadOffset, Int.toNat_natCast]
        show some (Val.ofWord .i32 (bytesWord (((List.range 4).map fun i => sh.bytes 6 (0 + i)).take 4))) = _
        rw [List.take_of_length_le (by simp), hw]; rfl)
    rw [eval_load C _ _ _ _ _ _ _ hp, this]
    simp [logged, loadOffset, Ty.bytes, Scalar.bytes]
  generalize hS : logged ctx sh 6 4 0 false = S at e9
  have hg : ∀ L : Locals, (eval C ctx L (.coord .threadPositionInGrid)).run S =
      some (.vec .u32 [u32 d, u32 r, u32 n], S) := fun L => by rw [eval_coord, hc.grid]; rfl
  have htg : ∀ L : Locals, (eval C ctx L (.coord .threadPositionInThreadgroup)).run S =
      some (.vec .u32 [u32 d, u32 (r % 4), u32 0], S) := fun L => by rw [eval_coord, hc.tg]; rfl
  have e10 : ∀ L : Locals, (eval C ctx L (.component (.coord .threadPositionInGrid) (u32l 2))).run S =
      some (u32 n, S) := fun L => eval_component C (hg L) (eval_lit C _ _ _ _) rfl rfl
  have e18 : ∀ L : Locals, (eval C ctx L (.component (.coord .threadPositionInGrid) (u32l 1))).run S =
      some (u32 r, S) := fun L => eval_component C (hg L) (eval_lit C _ _ _ _) rfl rfl
  have e17 : ∀ L : Locals, (eval C ctx L (.component (.coord .threadPositionInThreadgroup) (u32l 0))).run S =
      some (u32 d, S) := fun L => eval_component C (htg L) (eval_lit C _ _ _ _) rfl rfl
  have e11 : ∀ L : Locals, L 10 = some (u32 n) →
      (eval C ctx L (.bin .div .u32 0 (.local 10) (u32l 48))).run S = some (u32 0, S) := fun L h => by
    have : (eval C ctx L (.bin .div .u32 0 (.local 10) (u32l 48))).run S = some (u32 (n / 48), S) :=
      eval_int C (by decide) (eval_local C ctx L 10 _ h S) (eval_lit C _ _ _ _)
        (binary_div_u32 C n 48 (by omega) (by decide) (by decide))
    rwa [Nat.div_eq_of_lt (by omega)] at this
  have e12 : ∀ L : Locals, L 10 = some (u32 n) →
      (eval C ctx L (.bin .rem .u32 0 (.local 10) (u32l 48))).run S = some (u32 n, S) := fun L h => by
    have : (eval C ctx L (.bin .rem .u32 0 (.local 10) (u32l 48))).run S = some (u32 (n % 48), S) :=
      eval_int C (by decide) (eval_local C ctx L 10 _ h S) (eval_lit C _ _ _ _)
        (binary_rem_u32 C n 48 (by omega) (by decide) (by decide))
    rwa [Nat.mod_eq_of_lt (by omega)] at this
  have e13 : ∀ L : Locals, L 12 = some (u32 n) →
      (eval C ctx L (.bin .div .u32 0 (.local 12) (u32l 3))).run S = some (u32 (n / 3), S) := fun L h =>
    eval_int C (by decide) (eval_local C ctx L 12 _ h S) (eval_lit C _ _ _ _)
      (binary_div_u32 C n 3 (by omega) (by decide) (by decide))
  refine ⟨_, .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <|
    .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <|
    .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <|
    .set (e9 _ (by simp [setLocal])) <| .set (e10 _) <| .set (e11 _ (by simp [setLocal])) <|
    .set (e12 _ (by simp [setLocal])) <| .set (e13 _ (by simp [setLocal])) <|
    .set (eval_kq C (P := 0) (region := 0) (hk := n / 3) (by simp [setLocal]) (by simp [setLocal])
      (by simp [setLocal]) (by simp [setLocal]) (by omega)) <|
    .set (eval_kq C (P := 1) (region := 1) (hk := n / 3) (by simp [setLocal]) (by simp [setLocal])
      (by simp [setLocal]) (by simp [setLocal]) (by omega)) <|
    .set (eval_vptr C (n := n) (by simp [setLocal]) (by simp [setLocal]) (by simp [setLocal]) (by simp [setLocal]) hn) <|
    .set (eval_yptr C (n := n) (by simp [setLocal]) (by simp [setLocal]) (by simp [setLocal]) (by simp [setLocal]) hn) <|
    .set (e17 _) <| .set (e18 _) <|
    .set (eval_srow C (P := 5) (region := 5) (n := n) (r := r) (by simp [setLocal]) (by simp [setLocal])
      (by simp [setLocal]) hn hr) <|
    .set (eval_srow C (P := 8) (region := 8) (n := n) (r := r) (by simp [setLocal]) (by simp [setLocal])
      (by simp [setLocal]) hn hr) <|
    .array <| .set (eval_lit C _ _ _ _) <| .nil _ _,
    ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩, ?_⟩ <;> simp [setLocal]

/-- Memory after `k` iterations of the load loop: `i_state[s_idx]` read and stored to `state[i]`. -/
def loadMem (ctx : Ctx) (I : Ins) (n r d : Nat) (sh : Shared) : Nat → Shared
  | 0 => sh
  | k + 1 => tput (logged ctx (loadMem ctx I n r d sh k) 5 4 ((n * 128 + r) * 128 + (4 * d + k)) false)
      (ctx.threadArray 0) (4 * k) (wordBytes 4 (Val.f32Bits (stateIn I n r (4 * d + k))))

theorem loadMem_regions {sh : Shared} : ∀ k, (loadMem ctx I n r d sh k).regions = sh.regions
  | 0 => rfl
  | k + 1 => loadMem_regions k

theorem loadMem_epoch {sh : Shared} : ∀ k, (loadMem ctx I n r d sh k).deviceEpoch = sh.deviceEpoch
  | 0 => rfl
  | k + 1 => loadMem_epoch k

theorem loadMem_bytes {sh : Shared} {x : Nat} (hx : x ≠ ctx.threadArray 0) :
    ∀ k, (loadMem ctx I n r d sh k).bytes x = sh.bytes x
  | 0 => rfl
  | k + 1 => by rw [loadMem, tput_bytes, ite_eq_right hx]; exact loadMem_bytes hx k

theorem loadMem_arr {sh : Shared} : ∀ k, k ≤ 4 →
    Arr ((loadMem ctx I n r d sh k).bytes (ctx.threadArray 0)) (fun j => stateIn I n r (4 * d + j)) k
  | 0, _ => fun j hj => absurd hj (by omega)
  | k + 1, hk => by
    intro j hj b hb
    rw [loadMem, tput_bytes, ite_eq_left rfl]
    rcases Nat.lt_succ_iff_lt_or_eq.mp hj with hj | rfl
    · rw [writeBytes_outside _ _ _ _ (.inl (by omega))]; exact loadMem_arr k (by omega) j hj b hb
    · exact writeBytes_inside _ _ _ b (by rw [wordBytes_length]; exact hb)

theorem loadMem_log {sh : Shared} : ∀ k, ∀ e ∈ (loadMem ctx I n r d sh k).log, e ∈ sh.log ∨
    (e.region = 5 ∧ e.write = false)
  | 0, e, he => .inl he
  | k + 1, e, he => by
    simp only [loadMem, tput, logged, List.mem_append, List.mem_reverse, List.mem_map, List.mem_range] at he
    rcases he with ⟨i, _, rfl⟩ | he
    · exact .inr ⟨rfl, rfl⟩
    · exact loadMem_log k e he

/-- The load loop: `state[i] = i_state[s_idx]` for the lane's four columns. -/
theorem load_loop (hc : Lane fuse ctx n r d) {sh : Shared} (hR : Regs ctx A sh.regions) (hI : Inputs I sh.bytes)
    (L : Locals) (hp : Pre ctx n r d L) (h22 : L 22 = some (.int .i32 0)) :
    ∃ L', Exec C ctx [loadLoop] L sh .normal L' (loadMem ctx I n r d sh 4) ∧ Pre ctx n r d L' := by
  have hd := hc.hd; have hr := hc.hr; have hn := hc.hn
  obtain ⟨L', sh', hex, hp', -, rfl⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := lt4 22) (st := inc 22)
    (b := loadBody) 4
    (fun k L s => Pre ctx n r d L ∧ L 22 = some (.int .i32 k) ∧ s = loadMem ctx I n r d sh k)
    (fun k L s => Pre ctx n r d L ∧ L 22 = some (.int .i32 k) ∧ s = loadMem ctx I n r d sh k)
    (fun k hk L s hI' => ⟨s, eval_lt4 C hI'.2.1 (by omega), hI'⟩)
    (fun k hk L s hI' => by
      obtain ⟨hp, h22, rfl⟩ := hI'
      have e23 := eval_sIdx C (ctx := ctx) (sh := loadMem ctx I n r d sh k) hp.dk h22 (by omega)
      have hp1 := hp.set (u32 (4 * d + k)) (show 22 ≤ 23 by decide)
      have h22' : setLocal L 23 (u32 (4 * d + k)) 22 = some (.int .i32 k) := by simp [setLocal, h22]
      have hval := (eval_load C _ _ _ _ _ _ _ (eval_f32p C (eval_local C ctx _ 19 _ hp1.si (loadMem ctx I n r d sh k))
        (eval_local C ctx _ 23 _ (setLocal_same _ _ _) (loadMem ctx I n r d sh k)) (by omega))).trans
        (load_f32 ctx (loadMem ctx I n r d sh k) 5 ((n * 128 + r) * 128 + (4 * d + k)) ⟨.device, 3145728, A.state⟩
          I.state (by rw [loadMem_regions]; exact hR.state) (.inl rfl) hR.as (show _ ≤ 3145728 by omega)
          (by rw [loadMem_bytes (by have := hR.a9; omega)]; exact hI.state))
      have hst := store_f32_thread_tput ctx (logged ctx (loadMem ctx I n r d sh k) 5 4 ((n * 128 + r) * 128 + (4 * d + k))
        false) (ctx.threadArray 0) k 16 (stateIn I n r (4 * d + k))
        (by show (loadMem ctx I n r d sh k).regions _ = _; rw [loadMem_regions]; exact hR.arr) (by omega)
      exact ⟨.normal, _, _, _, _, .inl rfl, .set e23 (.store (eval_stateAt C hp1.arr h22' (by omega)) hval hst
        (.nil _ _)), exec_inc C h22' (by omega), hp1.set _ (by decide), by simp [setLocal], rfl⟩)
    ⟨hp, h22, rfl⟩
  exact ⟨L', hex, hp'⟩

end PhaseA

section PhaseA2
variable {C : M1Max.Contract} {fuse : Nat → Bool} {ctx : Ctx} {n r d : Nat} {A : Al} {I : Ins}

/-- `g_`, `beta_` and `t = 0` besides the declarations. -/
structure PreB (ctx : Ctx) (n r d : Nat) (L : Locals) : Prop where
  pre : Pre ctx n r d L
  g : L 24 = some (.ptr ⟨3, 0, .scalar .f32⟩)
  beta : L 25 = some (.ptr ⟨4, 0, .scalar .bf16⟩)
  t : L 26 = some (.int .i32 0)

theorem PreB.set {L : Locals} (hp : PreB ctx n r d L) {slot : Nat} (v : Val) (hs : 27 ≤ slot) :
    PreB ctx n r d (setLocal L slot v) :=
  ⟨hp.pre.set v (by omega), (setLocal_other L v (by omega)).trans hp.g, (setLocal_other L v (by omega)).trans hp.beta,
    (setLocal_other L v (by omega)).trans hp.t⟩

theorem mid_run {sh : Shared} (L : Locals) (hp : Pre ctx n r d L) :
    ∃ L', Exec C ctx mid L sh .normal L' sh ∧ PreB ctx n r d L' := by
  have e24 : (eval C ctx L (.offset (.local 3) gBatch)).run sh = some (.ptr ⟨3, 0, .scalar .f32⟩, sh) :=
    eval_f32p C (a := 0) (eval_local C ctx L 3 _ hp.g sh) (eval_gBatch C hp.b hp.T) (by decide)
  have hp1 := hp.set (.ptr ⟨3, 0, .scalar .f32⟩) (show 22 ≤ 24 by decide)
  have e25 : (eval C ctx (setLocal L 24 (.ptr ⟨3, 0, .scalar .f32⟩)) (.offset (.local 4) gBatch)).run sh =
      some (.ptr ⟨4, 0, .scalar .bf16⟩, sh) :=
    eval_bf16 C (a := 0) (eval_local C ctx _ 4 _ hp1.beta sh) (eval_gBatch C hp1.b hp1.T) (by decide)
  exact ⟨_, .set e24 (.set e25 (.set (eval_lit C _ _ _ _) (.nil _ _))),
    ⟨(hp1.set _ (by decide)).set _ (by decide), by simp [setLocal], by simp [setLocal], by simp [setLocal]⟩⟩

/-- Memory after `k` iterations of the decay loop: `g_[hv_idx]` read, `state[i]` decayed, `k_[s_idx]` read. -/
def decayMem (C : M1Max.Contract) (ctx : Ctx) (I : Ins) (n r d : Nat) (sh : Shared) : Nat → Shared
  | 0 => sh
  | k + 1 => logged ctx (tput (logged ctx (decayMem C ctx I n r d sh k) 3 4 n false) (ctx.threadArray 0) (4 * k)
      (wordBytes 4 (Val.f32Bits (decayed C I n r (4 * d + k))))) 1 2 (n / 3 * 128 + (4 * d + k)) false

theorem decayMem_regions {sh : Shared} : ∀ k, (decayMem C ctx I n r d sh k).regions = sh.regions
  | 0 => rfl
  | k + 1 => decayMem_regions k

theorem decayMem_epoch {sh : Shared} : ∀ k, (decayMem C ctx I n r d sh k).deviceEpoch = sh.deviceEpoch
  | 0 => rfl
  | k + 1 => decayMem_epoch k

theorem decayMem_bytes {sh : Shared} {x : Nat} (hx : x ≠ ctx.threadArray 0) :
    ∀ k, (decayMem C ctx I n r d sh k).bytes x = sh.bytes x
  | 0 => rfl
  | k + 1 => by
    show (tput _ _ _ _).bytes x = _
    rw [tput_bytes, ite_eq_right hx]; exact decayMem_bytes hx k

theorem decayMem_arr {sh : Shared} (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => stateIn I n r (4 * d + j)) 4) :
    ∀ k, k ≤ 4 → Arr ((decayMem C ctx I n r d sh k).bytes (ctx.threadArray 0))
      (fun j => if j < k then decayed C I n r (4 * d + j) else stateIn I n r (4 * d + j)) 4
  | 0, _ => h0.congr fun j _ => by simp
  | k + 1, hk => by
    have e : (decayMem C ctx I n r d sh (k + 1)).bytes (ctx.threadArray 0) =
        writeBytes ((decayMem C ctx I n r d sh k).bytes (ctx.threadArray 0)) (4 * k)
          (wordBytes 4 (Val.f32Bits (decayed C I n r (4 * d + k)))) := by
      show (tput _ _ _ _).bytes _ = _
      rw [tput_bytes, ite_eq_left rfl]; rfl
    rw [e]
    exact ((decayMem_arr h0 k (by omega)).write (show k < 4 by omega) _).congr fun j _ =>
      mix_succ (fun j => decayed C I n r (4 * d + j)) (fun j => stateIn I n r (4 * d + j)) k j

theorem decayMem_log {sh : Shared} : ∀ k, ∀ e ∈ (decayMem C ctx I n r d sh k).log, e ∈ sh.log ∨
    ((e.region = 3 ∨ e.region = 1) ∧ e.write = false)
  | 0, e, he => .inl he
  | k + 1, e, he => by
    simp only [decayMem, tput, logged, List.mem_append, List.mem_reverse, List.mem_map, List.mem_range] at he
    rcases he with ⟨i, _, rfl⟩ | ⟨i, _, rfl⟩ | he
    · exact .inr ⟨.inr rfl, rfl⟩
    · exact .inr ⟨.inl rfl, rfl⟩
    · exact decayMem_log k e he

/-- One iteration of the decay loop. -/
theorem decay_body (hc : Lane fuse ctx n r d) {sh : Shared} (hR : Regs ctx A sh.regions) (hI : Inputs I sh.bytes)
    (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => stateIn I n r (4 * d + j)) 4)
    (k : Nat) (hk : k < 4) (L : Locals) (hp : PreB ctx n r d L) (h28 : L 28 = some (.int .i32 k))
    (h27 : L 27 = some (.f32 (kvPart C fuse I n r d k))) :
    ∃ L₁, Exec C ctx decayBody L (decayMem C ctx I n r d sh k) .normal L₁ (decayMem C ctx I n r d sh (k + 1)) ∧
      PreB ctx n r d L₁ ∧ L₁ 28 = some (.int .i32 k) ∧ L₁ 27 = some (.f32 (kvPart C fuse I n r d (k + 1))) := by
  have hd := hc.hd; have hr := hc.hr; have hn := hc.hn; have a9 := hR.a9
  have harr := decayMem_arr (C := C) h0 k (by omega)
  have r0 : (decayMem C ctx I n r d sh k).regions = sh.regions := decayMem_regions k
  have b1 : (decayMem C ctx I n r d sh k).bytes 1 = I.k := (decayMem_bytes (by omega) k).trans hI.k
  have b3 : (decayMem C ctx I n r d sh k).bytes 3 = I.g := (decayMem_bytes (by omega) k).trans hI.g
  generalize hS0 : decayMem C ctx I n r d sh k = S0 at harr r0 b1 b3
  have ra : S0.regions (ctx.threadArray 0) = some ⟨.thread, 16, 4⟩ := by rw [r0]; exact hR.arr
  have e29 : (eval C ctx L (sIdx 28)).run S0 = some (u32 (4 * d + k), S0) := eval_sIdx C hp.pre.dk h28 (by omega)
  generalize hL1 : setLocal L 29 (u32 (4 * d + k)) = L1
  have hp1 : PreB ctx n r d L1 := hL1 ▸ hp.set _ (by decide)
  have h28' : L1 28 = some (.int .i32 k) := by rw [← hL1]; simp [setLocal, h28]
  have h29 : L1 29 = some (u32 (4 * d + k)) := by rw [← hL1]; simp [setLocal]
  have h27' : L1 27 = some (.f32 (kvPart C fuse I n r d k)) := by rw [← hL1]; simp [setLocal, h27]
  have hold : (eval C ctx L1 (stateLoad 28)).run S0 = some (.f32 (stateIn I n r (4 * d + k)), S0) := by
    have := eval_stateLoad C hp1.pre.arr h28' hk ra harr
    rwa [ite_eq_right (lt_irrefl k)] at this
  have hgv : (eval C ctx L1 (.load (.scalar .f32) (.offset (.local 24) (.local 12)))).run S0 =
      some (.f32 (f32At I.g n), logged ctx S0 3 4 n false) := by
    have := (eval_load C _ _ _ _ _ _ _ (eval_f32p C (a := 0) (eval_local C ctx L1 24 _ hp1.g S0)
      (eval_local C ctx L1 12 _ hp1.pre.hv S0) (by omega))).trans (load_f32 ctx S0 3 (0 + n) ⟨.device, 192, A.g⟩ I.g
        (by rw [r0]; exact hR.g) (.inl rfl) hR.ag (show _ ≤ 192 by omega) b3)
    rwa [Nat.zero_add] at this
  have hval : (eval C ctx L1 (.bin .mul .f32 0 (stateLoad 28) (.load (.scalar .f32)
      (.offset (.local 24) (.local 12))))).run S0 = some (.f32 (decayed C I n r (4 * d + k)), logged ctx S0 3 4 n false) :=
    eval_f32 C (.inl ⟨by decide, by decide⟩) hold hgv rfl
  have hst := store_f32_thread_tput ctx (logged ctx S0 3 4 n false) (ctx.threadArray 0) k 16
    (decayed C I n r (4 * d + k)) ra (by omega)
  generalize hS2 : tput (logged ctx S0 3 4 n false) (ctx.threadArray 0) (4 * k)
    (wordBytes 4 (Val.f32Bits (decayed C I n r (4 * d + k)))) = S2 at hst
  have harr2 : Arr (S2.bytes (ctx.threadArray 0)) (fun j => if j = k then decayed C I n r (4 * d + k) else
      (if j < k then decayed C I n r (4 * d + j) else stateIn I n r (4 * d + j))) 4 := by
    rw [← hS2, tput_bytes, ite_eq_left rfl]; exact harr.write hk _
  have r2 : S2.regions = sh.regions := by rw [← hS2]; exact r0
  have hnew : (eval C ctx L1 (stateLoad 28)).run S2 = some (.f32 (decayed C I n r (4 * d + k)), S2) := by
    have := eval_stateLoad C hp1.pre.arr h28' hk (by rw [r2]; exact hR.arr) harr2
    rwa [ite_eq_left rfl] at this
  have hkey : (eval C ctx L1 (floatAt 15 29)).run S2 =
      some (.f32 (keyAt C I n (4 * d + k)), logged ctx S2 1 2 (n / 3 * 128 + (4 * d + k)) false) :=
    eval_floatAt C (r := ⟨.device, 4096, A.k⟩) hp1.pre.k h29 (by omega) (by rw [r2]; exact hR.k) rfl hR.ak (by show _ ≤ 4096; omega)
      (by rw [← hS2, tput_bytes, ite_eq_right (by omega)]; exact b1)
  have e27 : (eval C ctx L1 (.bin .add .f32 1 (.local 27) (.bin .mul .f32 0 (stateLoad 28) (floatAt 15 29)))).run S2 =
      some (.f32 (kvPart C fuse I n r d (k + 1)), logged ctx S2 1 2 (n / 3 * 128 + (4 * d + k)) false) := by
    have := eval_add_mul_mem C (site := 1) (m := 0) rfl hnew hkey (eval_local C ctx L1 27 _ h27' S2)
      (eval_local C ctx L1 27 _ h27' _)
    rw [hc.fuse] at this; exact this
  have hS3 : logged ctx S2 1 2 (n / 3 * 128 + (4 * d + k)) false = decayMem C ctx I n r d sh (k + 1) := by
    rw [← hS2, ← hS0]; rfl
  rw [hS3] at e27
  subst hL1
  exact ⟨_, .set e29 (.store (eval_stateAt C hp1.pre.arr h28' (by omega)) hval hst (.set e27 (.nil _ _))),
    hp1.set _ (by decide), by simp [setLocal, h28], by simp [setLocal]⟩

/-- The decay loop and its declarations. -/
theorem decay_loop (hc : Lane fuse ctx n r d) {sh : Shared} (hR : Regs ctx A sh.regions) (hI : Inputs I sh.bytes)
    (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => stateIn I n r (4 * d + j)) 4) (L : Locals) (hp : PreB ctx n r d L) :
    ∃ L', Exec C ctx [.set 27 (f32l 0x0), .set 28 (i32l 0), decayLoop] L sh .normal L' (decayMem C ctx I n r d sh 4) ∧
      PreB ctx n r d L' ∧ L' 27 = some (.f32 (kvPart C fuse I n r d 4)) := by
  obtain ⟨L', sh', hex, hp', -, h27, rfl⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := lt4 28) (st := inc 28)
    (b := decayBody) 4
    (fun k L s => PreB ctx n r d L ∧ L 28 = some (.int .i32 k) ∧ L 27 = some (.f32 (kvPart C fuse I n r d k)) ∧
      s = decayMem C ctx I n r d sh k)
    (fun k L s => PreB ctx n r d L ∧ L 28 = some (.int .i32 k) ∧ L 27 = some (.f32 (kvPart C fuse I n r d k)) ∧
      s = decayMem C ctx I n r d sh k)
    (fun k hk L s hI' => ⟨s, eval_lt4 C hI'.2.1 (by omega), hI'⟩)
    (fun k hk L s hI' => by
      obtain ⟨hp, h28, h27, rfl⟩ := hI'
      obtain ⟨L₁, hb, hp₁, h28₁, h27₁⟩ := decay_body hc hR hI h0 k hk L hp h28 h27
      exact ⟨.normal, L₁, _, _, _, .inl rfl, hb, exec_inc C h28₁ (by omega), hp₁.set _ (by decide),
        by simp [setLocal], by simp [setLocal, h27₁], rfl⟩)
    (l := setLocal (setLocal L 27 (.f32 (Val.ofF32Bits 0x0))) 28 (.int .i32 0))
    ⟨(hp.set _ (by decide)).set _ (by decide), by simp [setLocal], by simp [setLocal]; rfl, rfl⟩
  exact ⟨L', .set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) hex), hp', h27⟩

/-- The frames after the first `simd_sum`, and the time loop's frame. -/
def restA : List CStmt := stepBody.drop 4
def restB : List CStmt := stepBody.drop 10
def loopFrame : Frame := .loop (.bin .lt .i32 0 (.local 26) (.local 9)) (inc 26) stepBody

theorem stepBody_eqA : stepBody = [.set 27 (f32l 0x0), .set 28 (i32l 0), decayLoop] ++
    (.collective 2 30 .sum .f32 (.local 27) (u16l 0) :: restA) := rfl

/-- Memory after phase A. -/
def memA (C : M1Max.Contract) (ctx : Ctx) (I : Ins) (n r d : Nat) (sh : Shared) : Shared :=
  decayMem C ctx I n r d (loadMem ctx I n r d (logged ctx sh 6 4 0 false) 4) 4

/-- A lane runs to its first `simd_sum`. -/
theorem phaseA (hc : Lane fuse ctx n r d) {sh : Shared} (hR : Regs ctx A sh.regions) (hI : Inputs I sh.bytes)
    (hT : I.t 0 = 1 ∧ I.t 1 = 0 ∧ I.t 2 = 0 ∧ I.t 3 = 0) :
    ∃ L', (∃ N, ∀ m ≥ N, (runThread C m ⟨ctx, fun _ => none, [.block body], .running⟩).run sh =
      some (⟨ctx, L', [.block restA, loopFrame, .block tail],
        .collective 2 30 .sum .f32 (.f32 (kvPart C fuse I n r d 4)) 0⟩, memA C ctx I n r d sh)) ∧
      PreB ctx n r d L' := by
  have a9 := hR.a9
  obtain ⟨L0, hd, hp0, h22⟩ := decls_run (C := C) hc hR hI hT
  obtain ⟨L1, hl, hp1⟩ := load_loop (C := C) (I := I) hc (sh := logged ctx sh 6 4 0 false) hR hI L0 hp0 h22
  obtain ⟨L2, hm, hp2⟩ := mid_run (C := C) (sh := loadMem ctx I n r d (logged ctx sh 6 4 0 false) 4) L1 hp1
  have R2 : Regs ctx A (loadMem ctx I n r d (logged ctx sh 6 4 0 false) 4).regions := by
    rw [loadMem_regions]; exact hR
  have I2 : Inputs I (loadMem ctx I n r d (logged ctx sh 6 4 0 false) 4).bytes :=
    Inputs.of (M := (logged ctx sh 6 4 0 false).bytes) hI (fun x hx => loadMem_bytes (by omega) 4)
  obtain ⟨L3, hdl, hp3, h27⟩ := decay_loop (C := C) (fuse := fuse) hc R2 I2 (loadMem_arr 4 le_rfl) L2 hp2
  have hstep : Exec C ctx stepBody L2 (loadMem ctx I n r d (logged ctx sh 6 4 0 false) 4)
      (.stop (.collective 2 30 .sum .f32 (.f32 (kvPart C fuse I n r d 4)) 0) [.block restA]) L3 (memA C ctx I n r d sh) := by
    rw [stepBody_eqA]
    exact hdl.append (.collective (eval_local C ctx L3 27 _ h27 _) (eval_lit C _ _ _ _) rfl)
  have htime : Exec C ctx (timeLoop :: tail) L2 (loadMem ctx I n r d (logged ctx sh 6 4 0 false) 4)
      (.stop (.collective 2 30 .sum .f32 (.f32 (kvPart C fuse I n r d 4)) 0) ([.block restA] ++ [loopFrame, .block tail]))
      L3 (memA C ctx I n r d sh) :=
    .loop_stop (eval_int C (by decide) (eval_local C ctx L2 26 _ hp2.t _) (eval_local C ctx L2 9 _ hp2.pre.T _)
      (binary_lt_i32 C 0 1 (by decide) (by decide))) hstep
  have hall : Exec C ctx body (fun _ => none) sh
      (.stop (.collective 2 30 .sum .f32 (.f32 (kvPart C fuse I n r d 4)) 0) ([.block restA] ++ [loopFrame, .block tail]))
      L3 (memA C ctx I n r d sh) := by
    rw [body_eq]; exact hd.append (hl.append (hm.append htime))
  exact ⟨L3, hall.reaches_stop.run rfl, hp3⟩

end PhaseA2

/-! ## Phase B: from the first `simd_sum` to the second -/

section PhaseB
variable {C : M1Max.Contract} {fuse : Nat → Bool} {ctx : Ctx} {n r d : Nat} {A : Al} {I : Ins}

/-- Memory after `delta`'s loads of `v_[dv_idx]` and `beta_[hv_idx]`. -/
def deltaMem (ctx : Ctx) (n r : Nat) (sh : Shared) : Shared := logged ctx (logged ctx sh 2 2 (n * 128 + r) false) 4 2 n false

/-- Memory after `k` iterations of the update loop: `k_[s_idx]` read, `state[i]` updated, `q_[s_idx]` read. -/
def updateMem (C : M1Max.Contract) (fuse : Nat → Bool) (ctx : Ctx) (I : Ins) (n r d : Nat) (sh : Shared) :
    Nat → Shared
  | 0 => sh
  | k + 1 => logged ctx (tput (logged ctx (updateMem C fuse ctx I n r d sh k) 1 2 (n / 3 * 128 + (4 * d + k)) false)
      (ctx.threadArray 0) (4 * k) (wordBytes 4 (Val.f32Bits (updated C fuse I n r (4 * d + k))))) 0 2
      (n / 3 * 128 + (4 * d + k)) false

theorem updateMem_regions {sh : Shared} : ∀ k, (updateMem C fuse ctx I n r d sh k).regions = sh.regions
  | 0 => rfl
  | k + 1 => updateMem_regions k

theorem updateMem_epoch {sh : Shared} : ∀ k, (updateMem C fuse ctx I n r d sh k).deviceEpoch = sh.deviceEpoch
  | 0 => rfl
  | k + 1 => updateMem_epoch k

theorem updateMem_bytes {sh : Shared} {x : Nat} (hx : x ≠ ctx.threadArray 0) :
    ∀ k, (updateMem C fuse ctx I n r d sh k).bytes x = sh.bytes x
  | 0 => rfl
  | k + 1 => by
    show (tput _ _ _ _).bytes x = _
    rw [tput_bytes, ite_eq_right hx]; exact updateMem_bytes hx k

theorem updateMem_arr {sh : Shared} (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => decayed C I n r (4 * d + j)) 4) :
    ∀ k, k ≤ 4 → Arr ((updateMem C fuse ctx I n r d sh k).bytes (ctx.threadArray 0))
      (fun j => if j < k then updated C fuse I n r (4 * d + j) else decayed C I n r (4 * d + j)) 4
  | 0, _ => h0.congr fun j _ => by simp
  | k + 1, hk => by
    have e : (updateMem C fuse ctx I n r d sh (k + 1)).bytes (ctx.threadArray 0) =
        writeBytes ((updateMem C fuse ctx I n r d sh k).bytes (ctx.threadArray 0)) (4 * k)
          (wordBytes 4 (Val.f32Bits (updated C fuse I n r (4 * d + k)))) := by
      show (tput _ _ _ _).bytes _ = _
      rw [tput_bytes, ite_eq_left rfl]; rfl
    rw [e]
    exact ((updateMem_arr h0 k (by omega)).write (show k < 4 by omega) _).congr fun j _ =>
      mix_succ (fun j => updated C fuse I n r (4 * d + j)) (fun j => decayed C I n r (4 * d + j)) k j

theorem updateMem_log {sh : Shared} : ∀ k, ∀ e ∈ (updateMem C fuse ctx I n r d sh k).log, e ∈ sh.log ∨
    ((e.region = 0 ∨ e.region = 1) ∧ e.write = false)
  | 0, e, he => .inl he
  | k + 1, e, he => by
    simp only [updateMem, tput, logged, List.mem_append, List.mem_reverse, List.mem_map, List.mem_range] at he
    rcases he with ⟨i, _, rfl⟩ | ⟨i, _, rfl⟩ | he
    · exact .inr ⟨.inl rfl, rfl⟩
    · exact .inr ⟨.inr rfl, rfl⟩
    · exact updateMem_log k e he

/-- One iteration of the update loop. -/
theorem update_body (hc : Lane fuse ctx n r d) {sh : Shared} (hR : Regs ctx A sh.regions) (hI : Inputs I sh.bytes)
    (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => decayed C I n r (4 * d + j)) 4)
    (k : Nat) (hk : k < 4) (L : Locals) (hp : PreB ctx n r d L) (h31 : L 31 = some (.f32 (delta C fuse I n r)))
    (h33 : L 33 = some (.int .i32 k)) (h32 : L 32 = some (.f32 (outPart C fuse I n r d k))) :
    ∃ L₁, Exec C ctx updateBody L (updateMem C fuse ctx I n r d sh k) .normal L₁
      (updateMem C fuse ctx I n r d sh (k + 1)) ∧
      PreB ctx n r d L₁ ∧ L₁ 31 = some (.f32 (delta C fuse I n r)) ∧ L₁ 33 = some (.int .i32 k) ∧
      L₁ 32 = some (.f32 (outPart C fuse I n r d (k + 1))) := by
  have hd := hc.hd; have hr := hc.hr; have hn := hc.hn; have a9 := hR.a9
  have harr := updateMem_arr (fuse := fuse) h0 k (by omega)
  have r0 : (updateMem C fuse ctx I n r d sh k).regions = sh.regions := updateMem_regions k
  have b0 : (updateMem C fuse ctx I n r d sh k).bytes 0 = I.q := (updateMem_bytes (by omega) k).trans hI.q
  have b1 : (updateMem C fuse ctx I n r d sh k).bytes 1 = I.k := (updateMem_bytes (by omega) k).trans hI.k
  generalize hS0 : updateMem C fuse ctx I n r d sh k = S0 at harr r0 b0 b1
  have ra : S0.regions (ctx.threadArray 0) = some ⟨.thread, 16, 4⟩ := by rw [r0]; exact hR.arr
  have e34 : (eval C ctx L (sIdx 33)).run S0 = some (u32 (4 * d + k), S0) := eval_sIdx C hp.pre.dk h33 (by omega)
  generalize hL1 : setLocal L 34 (u32 (4 * d + k)) = L1
  have hp1 : PreB ctx n r d L1 := hL1 ▸ hp.set _ (by decide)
  have h33' : L1 33 = some (.int .i32 k) := by rw [← hL1]; simp [setLocal, h33]
  have h34 : L1 34 = some (u32 (4 * d + k)) := by rw [← hL1]; simp [setLocal]
  have h31' : L1 31 = some (.f32 (delta C fuse I n r)) := by rw [← hL1]; simp [setLocal, h31]
  have h32' : L1 32 = some (.f32 (outPart C fuse I n r d k)) := by rw [← hL1]; simp [setLocal, h32]
  have hold : ∀ S : Shared, S.regions = S0.regions → S.bytes (ctx.threadArray 0) = S0.bytes (ctx.threadArray 0) →
      (eval C ctx L1 (stateLoad 33)).run S = some (.f32 (decayed C I n r (4 * d + k)), S) := by
    intro S hSr hSb
    have := eval_stateLoad C (sh := S) hp1.pre.arr h33' hk (by rw [hSr]; exact ra) (by rw [hSb]; exact harr)
    rwa [ite_eq_right (lt_irrefl k)] at this
  have hkey : (eval C ctx L1 (floatAt 15 34)).run S0 =
      some (.f32 (keyAt C I n (4 * d + k)), logged ctx S0 1 2 (n / 3 * 128 + (4 * d + k)) false) :=
    eval_floatAt C (r := ⟨.device, 4096, A.k⟩) hp1.pre.k h34 (by omega) (by rw [r0]; exact hR.k) rfl hR.ak
      (by show _ ≤ 4096; omega) b1
  have hval : (eval C ctx L1 (.bin .add .f32 3 (stateLoad 33) (.bin .mul .f32 0 (floatAt 15 34) (.local 31)))).run S0 =
      some (.f32 (updated C fuse I n r (4 * d + k)), logged ctx S0 1 2 (n / 3 * 128 + (4 * d + k)) false) := by
    have := eval_add_mul_mem C (site := 3) (m := 0) rfl hkey (eval_local C ctx L1 31 _ h31' _)
      (hold S0 rfl rfl) (hold _ rfl rfl)
    rw [hc.fuse] at this; exact this
  have hst := store_f32_thread_tput ctx (logged ctx S0 1 2 (n / 3 * 128 + (4 * d + k)) false) (ctx.threadArray 0) k 16
    (updated C fuse I n r (4 * d + k)) ra (by omega)
  generalize hS2 : tput (logged ctx S0 1 2 (n / 3 * 128 + (4 * d + k)) false) (ctx.threadArray 0) (4 * k)
    (wordBytes 4 (Val.f32Bits (updated C fuse I n r (4 * d + k)))) = S2 at hst
  have harr2 : Arr (S2.bytes (ctx.threadArray 0)) (fun j => if j = k then updated C fuse I n r (4 * d + k) else
      (if j < k then updated C fuse I n r (4 * d + j) else decayed C I n r (4 * d + j))) 4 := by
    rw [← hS2, tput_bytes, ite_eq_left rfl]; exact harr.write hk _
  have r2 : S2.regions = sh.regions := by rw [← hS2]; exact r0
  have hnew : (eval C ctx L1 (stateLoad 33)).run S2 = some (.f32 (updated C fuse I n r (4 * d + k)), S2) := by
    have := eval_stateLoad C hp1.pre.arr h33' hk (by rw [r2]; exact hR.arr) harr2
    rwa [ite_eq_left rfl] at this
  have hq : (eval C ctx L1 (floatAt 14 34)).run S2 =
      some (.f32 (queryAt C I n (4 * d + k)), logged ctx S2 0 2 (n / 3 * 128 + (4 * d + k)) false) :=
    eval_floatAt C (r := ⟨.device, 4096, A.q⟩) hp1.pre.q h34 (by omega) (by rw [r2]; exact hR.q) rfl hR.aq
      (by show _ ≤ 4096; omega) (by rw [← hS2, tput_bytes, ite_eq_right (by omega)]; exact b0)
  have e32 : (eval C ctx L1 (.bin .add .f32 4 (.local 32) (.bin .mul .f32 0 (stateLoad 33) (floatAt 14 34)))).run S2 =
      some (.f32 (outPart C fuse I n r d (k + 1)), logged ctx S2 0 2 (n / 3 * 128 + (4 * d + k)) false) := by
    have := eval_add_mul_mem C (site := 4) (m := 0) rfl hnew hq (eval_local C ctx L1 32 _ h32' S2)
      (eval_local C ctx L1 32 _ h32' _)
    rw [hc.fuse] at this; exact this
  have hS3 : logged ctx S2 0 2 (n / 3 * 128 + (4 * d + k)) false = updateMem C fuse ctx I n r d sh (k + 1) := by
    rw [← hS2, ← hS0]; rfl
  rw [hS3] at e32
  subst hL1
  exact ⟨_, .set e34 (.store (eval_stateAt C hp1.pre.arr h33' (by omega)) hval hst (.set e32 (.nil _ _))),
    hp1.set _ (by decide), by simp [setLocal, h31], by simp [setLocal, h33], by simp [setLocal]⟩

theorem restA_eq : restA = [.set 27 (.local 30), .set 31 deltaExpr, .set 32 (f32l 0x0), .set 33 (i32l 0), updateLoop] ++
    (.collective 5 35 .sum .f32 (.local 32) (u16l 0) :: restB) := rfl

/-- A lane resumed with the row's `kv_mem` runs to its second `simd_sum`. -/
theorem phaseB (hc : Lane fuse ctx n r d) {sh : Shared} (hR : Regs ctx A sh.regions) (hI : Inputs I sh.bytes)
    (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => decayed C I n r (4 * d + j)) 4) (L : Locals)
    (hp : PreB ctx n r d L) :
    ∃ L', (∃ N, ∀ m ≥ N, (runThread C m ⟨ctx, setLocal L 30 (.f32 (kvMem C fuse I n r)),
      [.block restA, loopFrame, .block tail], .running⟩).run sh =
      some (⟨ctx, L', [.block restB, loopFrame, .block tail],
        .collective 5 35 .sum .f32 (.f32 (outPart C fuse I n r d 4)) 0⟩,
        updateMem C fuse ctx I n r d (deltaMem ctx n r sh) 4)) ∧ PreB ctx n r d L' := by
  have hd := hc.hd; have hr := hc.hr; have hn := hc.hn; have a9 := hR.a9
  generalize hL0 : setLocal L 30 (.f32 (kvMem C fuse I n r)) = L0
  have hp0 : PreB ctx n r d L0 := hL0 ▸ hp.set _ (by decide)
  have e27 : (eval C ctx L0 (.local 30)).run sh = some (.f32 (kvMem C fuse I n r), sh) :=
    eval_local C ctx L0 30 _ (by rw [← hL0]; exact setLocal_same _ _ _) sh
  generalize hL1 : setLocal L0 27 (.f32 (kvMem C fuse I n r)) = L1
  have hp1 : PreB ctx n r d L1 := hL1 ▸ hp0.set _ (by decide)
  have h27 : L1 27 = some (.f32 (kvMem C fuse I n r)) := by rw [← hL1]; exact setLocal_same _ _ _
  have hv : (eval C ctx L1 (floatAt 16 18)).run sh =
      some (.f32 (C.widen (bfAt I.v (n * 128 + r))), logged ctx sh 2 2 (n * 128 + r) false) :=
    eval_floatAt C (r := ⟨.device, 12288, A.v⟩) hp1.pre.v hp1.pre.dv (by omega) hR.v rfl hR.av
      (by show _ ≤ 12288; omega) hI.v
  have hb : (eval C ctx L1 (floatAt 25 12)).run (logged ctx sh 2 2 (n * 128 + r) false) =
      some (.f32 (C.widen (bfAt I.beta n)), deltaMem ctx n r sh) := by
    have := eval_floatAt C (ctx := ctx) (a := 0) (r := ⟨.device, 96, A.beta⟩) (sh := logged ctx sh 2 2 (n * 128 + r) false)
      hp1.beta hp1.pre.hv (by omega) hR.beta rfl hR.ab (by show _ ≤ 96; omega) hI.beta
    rwa [Nat.zero_add] at this
  have e31 : (eval C ctx L1 deltaExpr).run sh = some (.f32 (delta C fuse I n r), deltaMem ctx n r sh) :=
    eval_f32 C (.inl ⟨by decide, by decide⟩)
      (eval_f32 C (.inr ⟨rfl, rfl⟩) hv (eval_local C ctx L1 27 _ h27 _) rfl) hb rfl
  generalize hL4 : setLocal (setLocal (setLocal L1 31 (.f32 (delta C fuse I n r))) 32 (.f32 (Val.ofF32Bits 0x0))) 33
    (.int .i32 0) = L4
  have hp4 : PreB ctx n r d L4 := hL4 ▸ ((hp1.set _ (by decide)).set _ (by decide)).set _ (by decide)
  have R1 : Regs ctx A (deltaMem ctx n r sh).regions := hR
  have I1 : Inputs I (deltaMem ctx n r sh).bytes := hI
  obtain ⟨L', sh', hex, hp', -, -, h32, rfl⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := lt4 33) (st := inc 33)
    (b := updateBody) 4
    (fun k L s => PreB ctx n r d L ∧ L 31 = some (.f32 (delta C fuse I n r)) ∧ L 33 = some (.int .i32 k) ∧
      L 32 = some (.f32 (outPart C fuse I n r d k)) ∧ s = updateMem C fuse ctx I n r d (deltaMem ctx n r sh) k)
    (fun k L s => PreB ctx n r d L ∧ L 31 = some (.f32 (delta C fuse I n r)) ∧ L 33 = some (.int .i32 k) ∧
      L 32 = some (.f32 (outPart C fuse I n r d k)) ∧ s = updateMem C fuse ctx I n r d (deltaMem ctx n r sh) k)
    (fun k hk L s hI' => ⟨s, eval_lt4 C hI'.2.2.1 (by omega), hI'⟩)
    (fun k hk L s hI' => by
      obtain ⟨hp, h31, h33, h32, rfl⟩ := hI'
      obtain ⟨L₁, hb, hp₁, h31₁, h33₁, h32₁⟩ := update_body hc R1 I1 h0 k hk L hp h31 h33 h32
      exact ⟨.normal, L₁, _, _, _, .inl rfl, hb, exec_inc C h33₁ (by omega), hp₁.set _ (by decide),
        by simp [setLocal, h31₁], by simp [setLocal], by simp [setLocal, h32₁], rfl⟩)
    (l := L4) ⟨hp4, by rw [← hL4]; simp [setLocal], by rw [← hL4]; simp [setLocal],
      by rw [← hL4]; simp [setLocal]; rfl, rfl⟩
  have hrest : Exec C ctx restA L0 sh (.stop (.collective 5 35 .sum .f32 (.f32 (outPart C fuse I n r d 4)) 0)
      [.block restB]) L' (updateMem C fuse ctx I n r d (deltaMem ctx n r sh) 4) := by
    rw [restA_eq]
    subst hL4 hL1
    exact .set e27 (.set e31 (.set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _)
      (hex.append (.collective (eval_local C ctx L' 32 _ h32 _) (eval_lit C _ _ _ _) rfl)))))
  subst hL0
  exact ⟨L', (hrest.reaches_stop (K := [loopFrame, .block tail])).run rfl, hp'⟩

end PhaseB

/-! ## Phase C: from the second `simd_sum` to the end -/

section PhaseC
variable {C : M1Max.Contract} {fuse : Nat → Bool} {ctx : Ctx} {n r d : Nat} {A : Al} {I : Ins}

/-- Memory after `y[dv_idx] = InT(out)` by lane 0. -/
def yMem (C : M1Max.Contract) (fuse : Nat → Bool) (ctx : Ctx) (I : Ins) (n r d : Nat) (sh : Shared) : Shared :=
  if d = 0 then tput (logged ctx sh 7 2 (n * 128 + r) true) 7 (2 * (n * 128 + r))
    (wordBytes 2 (Val.bf16Bits (C.narrow (outSum C fuse I n r))))
  else sh

/-- Memory after `k` iterations of the final loop: `o_state[s_idx] = state[i]`. -/
def storeMem (C : M1Max.Contract) (fuse : Nat → Bool) (ctx : Ctx) (I : Ins) (n r d : Nat) (sh : Shared) :
    Nat → Shared
  | 0 => sh
  | k + 1 => tput (logged ctx (storeMem C fuse ctx I n r d sh k) 8 4 ((n * 128 + r) * 128 + (4 * d + k)) true) 8
      (4 * ((n * 128 + r) * 128 + (4 * d + k))) (wordBytes 4 (Val.f32Bits (updated C fuse I n r (4 * d + k))))

theorem storeMem_regions {sh : Shared} : ∀ k, (storeMem C fuse ctx I n r d sh k).regions = sh.regions
  | 0 => rfl
  | k + 1 => storeMem_regions k

theorem storeMem_bytes {sh : Shared} {x : Nat} (hx : x ≠ 8) : ∀ k, (storeMem C fuse ctx I n r d sh k).bytes x = sh.bytes x
  | 0 => rfl
  | k + 1 => by rw [storeMem, tput_bytes, ite_eq_right hx]; exact storeMem_bytes hx k

theorem yMem_regions {sh : Shared} : (yMem C fuse ctx I n r d sh).regions = sh.regions := by
  unfold yMem; split <;> rfl

theorem yMem_bytes {sh : Shared} {x : Nat} (hx : x ≠ 7) : (yMem C fuse ctx I n r d sh).bytes x = sh.bytes x := by
  unfold yMem; split
  · rw [tput_bytes, ite_eq_right hx]; rfl
  · rfl

/-- What phase C needs of the locals. -/
structure PreC (ctx : Ctx) (n r d : Nat) (L : Locals) : Prop where
  T : L 9 = some (.int .i32 1)
  dk : L 17 = some (u32 d)
  so : L 20 = some (.ptr ⟨8, ((4 * ((n * 128 + r) * 128) : Nat) : Int), .scalar .f32⟩)
  arr : L 21 = some (.ptr ⟨ctx.threadArray 0, 0, .scalar .f32⟩)

theorem PreC.set {L : Locals} (hp : PreC ctx n r d L) {slot : Nat} (v : Val)
    (hs : slot ≠ 9 ∧ slot ≠ 17 ∧ slot ≠ 20 ∧ slot ≠ 21) : PreC ctx n r d (setLocal L slot v) :=
  ⟨(setLocal_other L v (Ne.symm hs.1)).trans hp.T, (setLocal_other L v (Ne.symm hs.2.1)).trans hp.dk,
    (setLocal_other L v (Ne.symm hs.2.2.1)).trans hp.so, (setLocal_other L v (Ne.symm hs.2.2.2)).trans hp.arr⟩

/-- The final loop: the lane's four state columns stored. -/
theorem store_loop (hc : Lane fuse ctx n r d) {sh : Shared} (hR : Regs ctx A sh.regions)
    (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => updated C fuse I n r (4 * d + j)) 4) (L : Locals)
    (hp : PreC ctx n r d L) :
    ∃ L', Exec C ctx tail L sh .normal L' (storeMem C fuse ctx I n r d sh 4) := by
  have hd := hc.hd; have hr := hc.hr; have hn := hc.hn; have a9 := hR.a9
  obtain ⟨L', sh', hex, -, -, rfl⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := lt4 36) (st := inc 36)
    (b := storeBody) 4
    (fun k L s => PreC ctx n r d L ∧ L 36 = some (.int .i32 k) ∧ s = storeMem C fuse ctx I n r d sh k)
    (fun k L s => PreC ctx n r d L ∧ L 36 = some (.int .i32 k) ∧ s = storeMem C fuse ctx I n r d sh k)
    (fun k hk L s hI' => ⟨s, eval_lt4 C hI'.2.1 (by omega), hI'⟩)
    (fun k hk L s hI' => by
      obtain ⟨hp, h36, rfl⟩ := hI'
      have r0 : (storeMem C fuse ctx I n r d sh k).regions = sh.regions := storeMem_regions k
      have b0 : (storeMem C fuse ctx I n r d sh k).bytes (ctx.threadArray 0) = sh.bytes (ctx.threadArray 0) :=
        storeMem_bytes (by omega) k
      have e37 := eval_sIdx C (ctx := ctx) (sh := storeMem C fuse ctx I n r d sh k) hp.dk h36 (by omega)
      have hp1 := hp.set (u32 (4 * d + k)) (show 37 ≠ 9 ∧ 37 ≠ 17 ∧ 37 ≠ 20 ∧ 37 ≠ 21 by decide)
      have h36' : setLocal L 37 (u32 (4 * d + k)) 36 = some (.int .i32 k) := by simp [setLocal, h36]
      have hptr := eval_f32p C (eval_local C ctx _ 20 _ hp1.so (storeMem C fuse ctx I n r d sh k))
        (eval_local C ctx _ 37 _ (setLocal_same L 37 (u32 (4 * d + k))) _) (by omega)
      have hval := eval_stateLoad C (sh := storeMem C fuse ctx I n r d sh k) hp1.arr h36' hk
        (by rw [r0]; exact hR.arr) (by rw [b0]; exact h0)
      have hst := store_f32 ctx (storeMem C fuse ctx I n r d sh k) 8 ((n * 128 + r) * 128 + (4 * d + k))
        ⟨.device, 3145728, 16⟩ (updated C fuse I n r (4 * d + k)) (by rw [r0]; exact hR.so) rfl (by decide)
        (by show _ ≤ 3145728; omega)
      exact ⟨.normal, _, _, _, _, .inl rfl, .set e37 (.store hptr hval hst (.nil _ _)), exec_inc C h36' (by omega),
        hp1.set _ (by decide), by simp [setLocal], rfl⟩)
    (l := setLocal L 36 (.int .i32 0)) ⟨hp.set _ (by decide), by simp [setLocal], rfl⟩
  exact ⟨L', .set (eval_lit C _ _ _ _) hex⟩

/-- A lane resumed with the row's `out` stores `y` (lane 0), advances its pointers, leaves the time loop and stores
its state columns. -/
theorem phaseC (hc : Lane fuse ctx n r d) {sh : Shared} (hR : Regs ctx A sh.regions)
    (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => updated C fuse I n r (4 * d + j)) 4) (L : Locals)
    (hp : PreB ctx n r d L) :
    ∃ L', ∃ N, ∀ m ≥ N, (runThread C m ⟨ctx, setLocal L 35 (.f32 (outSum C fuse I n r)),
      [.block restB, loopFrame, .block tail], .running⟩).run sh =
      some (⟨ctx, L', [], .done⟩, storeMem C fuse ctx I n r d (yMem C fuse ctx I n r d sh) 4) := by
  have hd := hc.hd; have hr := hc.hr; have hn := hc.hn; have a9 := hR.a9
  generalize hL1 : setLocal (setLocal L 35 (.f32 (outSum C fuse I n r))) 32 (.f32 (outSum C fuse I n r)) = L1
  have hp1 : PreB ctx n r d L1 := hL1 ▸ (hp.set _ (by decide)).set _ (by decide)
  have h32 : L1 32 = some (.f32 (outSum C fuse I n r)) := by rw [← hL1]; exact setLocal_same _ _ _
  have hlane : (eval C ctx L1 (.coord .threadIndexInSimdgroup)).run sh = some (u32 d, sh) := by
    rw [eval_coord, hc.lane]
  have htest : (eval C ctx L1 (.bin .eq .u32 0 (.coord .threadIndexInSimdgroup) (u32l 0))).run sh =
      some (.bool (decide (d = 0)), sh) :=
    eval_int C (by decide) hlane (eval_lit C _ _ _ _) (binary_eq_u32 C d 0 (by omega) (by decide))
  have hy : Exec C ctx [yStore] L1 sh .normal L1 (yMem C fuse ctx I n r d sh) := by
    by_cases hd0 : d = 0
    · have hst := store_bf16_logged ctx sh 7 (n * 128 + r) ⟨.device, 12288, 16⟩ (C.narrow (outSum C fuse I n r)) hR.y rfl
        (by decide) (by show _ ≤ 12288; omega)
      rw [show yMem C fuse ctx I n r d sh = _ from ite_eq_left hd0]
      rw [decide_eq_true hd0] at htest
      exact .ite htest (.store (eval_bf16 C (eval_local C ctx L1 7 _ hp1.pre.y sh)
        (eval_local C ctx L1 18 _ hp1.pre.dv sh) (by omega)) (eval_conv C (eval_local C ctx L1 32 _ h32 sh) rfl) hst
        (.nil _ _)) (.nil _ _)
    · rw [show yMem C fuse ctx I n r d sh = sh from ite_eq_right hd0]
      rw [decide_eq_false hd0] at htest
      exact .ite htest (.nil _ _) (.nil _ _)
  generalize hS : yMem C fuse ctx I n r d sh = S at hy
  have hRS : S.regions = sh.regions := by rw [← hS]; exact yMem_regions
  have hAS : S.bytes (ctx.threadArray 0) = sh.bytes (ctx.threadArray 0) := by rw [← hS]; exact yMem_bytes (by omega)
  -- the pointer advances
  have p14 : (eval C ctx L1 (.offset (.local 14) (i32l 2048))).run S =
      some (.ptr ⟨0, ((2 * (n / 3 * 128) + 2048 * (Ty.scalar .bf16).bytes : Nat) : Int), .scalar .bf16⟩, S) :=
    eval_offset_i32 C (eval_local C ctx L1 14 _ hp1.pre.q S) (eval_lit C _ _ _ _) (by decide)
  generalize hL2 : setLocal L1 14 (.ptr ⟨0, ((2 * (n / 3 * 128) + 2048 * (Ty.scalar .bf16).bytes : Nat) : Int),
    .scalar .bf16⟩) = L2
  have p15 : (eval C ctx L2 (.offset (.local 15) (i32l 2048))).run S =
      some (.ptr ⟨1, ((2 * (n / 3 * 128) + 2048 * (Ty.scalar .bf16).bytes : Nat) : Int), .scalar .bf16⟩, S) :=
    eval_offset_i32 C (eval_local C ctx L2 15 _ (by rw [← hL2]; simp [setLocal, hp1.pre.k]) S) (eval_lit C _ _ _ _)
      (by decide)
  generalize hL3 : setLocal L2 15 (.ptr ⟨1, ((2 * (n / 3 * 128) + 2048 * (Ty.scalar .bf16).bytes : Nat) : Int),
    .scalar .bf16⟩) = L3
  have p16 : (eval C ctx L3 (.offset (.local 16) (i32l 6144))).run S =
      some (.ptr ⟨2, ((2 * (n * 128) + 6144 * (Ty.scalar .bf16).bytes : Nat) : Int), .scalar .bf16⟩, S) :=
    eval_offset_i32 C (eval_local C ctx L3 16 _ (by rw [← hL3, ← hL2]; simp [setLocal, hp1.pre.v]) S)
      (eval_lit C _ _ _ _) (by decide)
  generalize hL4 : setLocal L3 16 (.ptr ⟨2, ((2 * (n * 128) + 6144 * (Ty.scalar .bf16).bytes : Nat) : Int),
    .scalar .bf16⟩) = L4
  have p7 : (eval C ctx L4 (.offset (.local 7) (i32l 6144))).run S =
      some (.ptr ⟨7, ((2 * (n * 128) + 6144 * (Ty.scalar .bf16).bytes : Nat) : Int), .scalar .bf16⟩, S) :=
    eval_offset_i32 C (eval_local C ctx L4 7 _ (by rw [← hL4, ← hL3, ← hL2]; simp [setLocal, hp1.pre.y]) S)
      (eval_lit C _ _ _ _) (by decide)
  generalize hL5 : setLocal L4 7 (.ptr ⟨7, ((2 * (n * 128) + 6144 * (Ty.scalar .bf16).bytes : Nat) : Int),
    .scalar .bf16⟩) = L5
  have p24 : (eval C ctx L5 (.offset (.local 24) (i32l 48))).run S =
      some (.ptr ⟨3, ((0 + 48 * (Ty.scalar .f32).bytes : Nat) : Int), .scalar .f32⟩, S) :=
    eval_offset_i32 C (o := 0) (eval_local C ctx L5 24 _ (by rw [← hL5, ← hL4, ← hL3, ← hL2]; simp [setLocal, hp1.g]) S)
      (eval_lit C _ _ _ _) (by decide)
  generalize hL6 : setLocal L5 24 (.ptr ⟨3, ((0 + 48 * (Ty.scalar .f32).bytes : Nat) : Int), .scalar .f32⟩) = L6
  have p25 : (eval C ctx L6 (.offset (.local 25) (i32l 48))).run S =
      some (.ptr ⟨4, ((0 + 48 * (Ty.scalar .bf16).bytes : Nat) : Int), .scalar .bf16⟩, S) :=
    eval_offset_i32 C (o := 0) (eval_local C ctx L6 25 _
      (by rw [← hL6, ← hL5, ← hL4, ← hL3, ← hL2]; simp [setLocal, hp1.beta]) S) (eval_lit C _ _ _ _) (by decide)
  generalize hL7 : setLocal L6 25 (.ptr ⟨4, ((0 + 48 * (Ty.scalar .bf16).bytes : Nat) : Int), .scalar .bf16⟩) = L7
  have hrest : Exec C ctx restB (setLocal L 35 (.f32 (outSum C fuse I n r))) sh .normal L7 S := by
    subst hL1 hL2 hL3 hL4 hL5 hL6 hL7
    exact .set (eval_local C ctx _ 35 _ (setLocal_same _ _ _) sh) (hy.append (.set p14 (.set p15 (.set p16
      (.set p7 (.set p24 (.set p25 (.nil _ _))))))))
  have hpC : PreC ctx n r d L7 := by
    subst hL2 hL3 hL4 hL5 hL6 hL7
    exact ⟨by simp [setLocal, hp1.pre.T], by simp [setLocal, hp1.pre.dk], by simp [setLocal, hp1.pre.so],
      by simp [setLocal, hp1.pre.arr]⟩
  have h26 : L7 26 = some (.int .i32 0) := by
    subst hL2 hL3 hL4 hL5 hL6 hL7; simp [setLocal, hp1.t]
  have hinc := exec_inc C (ctx := ctx) (sh := S) h26 (by decide)
  have hexit : (eval C ctx (setLocal L7 26 (.int .i32 (0 + 1))) (.bin .lt .i32 0 (.local 26) (.local 9))).run S =
      some (.bool false, S) :=
    eval_int C (by decide) (eval_local C ctx _ 26 _ (setLocal_same _ _ _) S)
      (eval_local C ctx _ 9 _ (by simp [setLocal, hpC.T]) S) (binary_lt_i32 C (0 + 1) 1 (by decide) (by decide))
  obtain ⟨L', htail⟩ := store_loop (C := C) (fuse := fuse) (I := I) hc (sh := S) (by rw [hRS]; exact hR)
    (by rw [hAS]; exact h0) _
    (hpC.set (.int .i32 (0 + 1)) (show 26 ≠ 9 ∧ 26 ≠ 17 ∧ 26 ≠ 20 ∧ 26 ≠ 21 by decide))
  refine ⟨L', ((Exec.resume_exit (C := C) (K := []) hrest (.inl rfl) hinc hexit).trans htail.reaches_done).run rfl⟩

end PhaseC

/-! ## The launch -/

/-- The input buffers: `T` (one int32) in constant memory, the rest in device memory. -/
def inputs (I : Ins) (A : Al) : List Buffer :=
  [⟨.device, 4096, A.q, I.q⟩, ⟨.device, 4096, A.k, I.k⟩, ⟨.device, 12288, A.v, I.v⟩, ⟨.device, 192, A.g, I.g⟩,
   ⟨.device, 96, A.beta, I.beta⟩, ⟨.device, 3145728, A.state, I.state⟩, ⟨.constant, 4, A.t, I.t⟩]

/-- The outputs' sizes in bytes: `y` [1, 1, 48, 128] bf16 and `state_out` [1, 48, 128, 128] f32. -/
def sizes : List Nat := [12288, 3145728]

def launch (I : Ins) (A : Al) (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨core, (32, 128, 48), (32, 4, 1), buffers (inputs I A) sizes 16 initial⟩

/-- The thread that writes `y` element `e` (row `e % 128` of head `e / 128`): lane 0 of SIMD-group `row % 4` of
threadgroup `(0, row / 4, head)`. -/
def yThread (e : Nat) : Nat := 128 * (e % 128 / 4) + 4096 * (e / 128) + 32 * (e % 128 % 4)

/-- The thread that writes `state_out` element `e` (column `e % 128` of row `e / 128 % 128` of head
`e / 128 / 128`): lane `column / 4` of the row's SIMD-group. -/
def soThread (e : Nat) : Nat :=
  128 * (e / 128 % 128 / 4) + 4096 * (e / 128 / 128) + 32 * (e / 128 % 128 % 4) + e % 128 / 4

/-- Thread `t` writes in its threadgroup `t / 128`, before any barrier. -/
def writer (t : Nat) : Writer := ⟨t, t / 128, 0⟩

def dev (region byte : Nat) : Option Writer :=
  if region = 7 then some (writer (yThread (byte / 2)))
  else if region = 8 then some (writer (soThread (byte / 4)))
  else none

def tgo : Nat → Nat → Nat → Nat → Option Nat := fun _ _ _ _ => none

section LaunchFacts
variable (I : Ins) (A : Al) (initial : Nat → ByteMemory.Bytes)

theorem tiles : (launch I A initial).Tiles 32 4 1 1 32 48 4 := ⟨rfl, rfl, rfl, by decide⟩

theorem launch_rt (t : Nat) : (launch I A initial).regions (9 + t) = some ⟨.thread, 16, 4⟩ := by
  have := Launch.regions_threadArray (launch I A initial) t 0 (.scalar .f32) 4 rfl
  rwa [show (launch I A initial).buffers.length + (launch I A initial).groupArrays +
    t * (launch I A initial).threadArrays + 0 = 9 + t from show 9 + 0 + t * 1 + 0 = 9 + t by omega] at this

theorem isGroup_launch (x : Nat) (hx : x < 9) : isGroup ((launch I A initial).regions x) = false := by
  rcases (by omega : x = 0 ∨ x = 1 ∨ x = 2 ∨ x = 3 ∨ x = 4 ∨ x = 5 ∨ x = 6 ∨ x = 7 ∨ x = 8) with
    rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

/-- A read of an input. -/
theorem owned_read (a : Access) (hr : a.region < 7) (hw : a.write = false) :
    Owned (launch I A initial) dev tgo a := by
  unfold Owned
  rw [isGroup_launch I A initial a.region (by omega)]
  have hd : dev a.region a.byte = none := by unfold dev; rw [ite_eq_right (by omega), ite_eq_right (by omega)]
  simp only [Bool.false_eq_true, ↓reduceIte, hd]
  exact hw

/-- A write by the byte's writer. -/
theorem owned_write (a : Access) (hr : a.region = 7 ∨ a.region = 8) (t : Nat)
    (hd : dev a.region a.byte = some (writer t)) (ht : a.thread = t) (hg : a.group = t / 128) (he : a.deviceEpoch = 0) :
    Owned (launch I A initial) dev tgo a := by
  unfold Owned
  rw [isGroup_launch I A initial a.region (by omega), hd]
  simp [writer, ht, hg, he]

variable (fuse : Nat → Bool) {yy n s : Nat}

theorem ctx_lane (hy : yy < 32) (hn : n < 48) (hs : s < 4) (i : Fin 32) :
    Lane fuse ((launch I A initial).ctxAt fuse 0 yy n (32 * s + i)) n (4 * yy + s) i := by
  have hi := i.isLt
  refine ⟨?_, ?_, Launch.ctxAt_lane _ fuse 0 yy n s i, Launch.ctxAt_fuse _ fuse 0 yy n _, hi, by omega, hn⟩
  · rw [(tiles I A initial).threadPositionInGrid, show 0 * 32 + (32 * s + i) % 32 = i by omega,
      show yy * 4 + (32 * s + i) / 32 % 4 = 4 * yy + s by omega, show n * 1 + (32 * s + i) / (32 * 4) = n by omega]
  · rw [(tiles I A initial).threadPositionInThreadgroup, show (32 * s + i) % 32 = i by omega,
      show (32 * s + i) / 32 % 4 = (4 * yy + s) % 4 by omega, show (32 * s + i) / (32 * 4) = 0 by omega]

theorem ctx_thread (i : Nat) :
    ((launch I A initial).ctxAt fuse 0 yy n (32 * s + i)).thread = 128 * (yy + 32 * n) + 32 * s + i := by
  rw [(tiles I A initial).thread]; ring

theorem ctx_group (i : Nat) : ((launch I A initial).ctxAt fuse 0 yy n (32 * s + i)).group = yy + 32 * n := by
  rw [(tiles I A initial).group_id]; ring

theorem ctx_arr (i : Nat) :
    ((launch I A initial).ctxAt fuse 0 yy n (32 * s + i)).threadArray 0 = 9 + (128 * (yy + 32 * n) + 32 * s + i) := by
  rw [(tiles I A initial).threadArray]
  show 9 + 0 + ((0 + yy * 1 + n * 1 * 32) * (32 * 4) + (32 * s + i)) * 1 + 0 = _
  ring

end LaunchFacts

/-! ### Owners -/

theorem yThread_lt {b : Nat} (hb : b < 12288) : yThread (b / 2) < 196608 := by unfold yThread; omega
theorem soThread_lt {b : Nat} (hb : b < 3145728) : soThread (b / 4) < 196608 := by unfold soThread; omega

/-- The `y` bytes lane `d` of SIMD-group `s` of threadgroup `(0, yy, n)` owns: row `4 yy + s`'s, if `d = 0`. -/
theorem yThread_eq {b yy n s d : Nat} (hd : d < 32) :
    yThread (b / 2) = 128 * (yy + 32 * n) + 32 * s + d ↔
      d = 0 ∧ 2 * (n * 128 + (4 * yy + s)) ≤ b ∧ b < 2 * (n * 128 + (4 * yy + s)) + 2 := by
  unfold yThread; omega

/-- The `state_out` bytes lane `d` of SIMD-group `s` of threadgroup `(0, yy, n)` owns: its four columns of row
`4 yy + s`. -/
theorem soThread_eq {b yy n s d : Nat} :
    soThread (b / 4) = 128 * (yy + 32 * n) + 32 * s + d ↔
      4 * ((n * 128 + (4 * yy + s)) * 128 + 4 * d) ≤ b ∧ b < 4 * ((n * 128 + (4 * yy + s)) * 128 + 4 * d + 4) := by
  unfold soThread; omega

/-! ### The invariant -/

/-- Before thread `T` (in launch order) runs: the inputs intact, every output byte tput by an earlier thread
holding its expected value, and every access so far keeping the ownership discipline. -/
structure Inv (C : M1Max.Contract) (fuse : Nat → Bool) (I : Ins) (A : Al) (initial : Nat → ByteMemory.Bytes)
    (T : Nat) (sh : Shared) : Prop where
  regions : sh.regions = (launch I A initial).regions
  inputs : Inputs I sh.bytes
  epoch : sh.deviceEpoch = 0
  y : ∀ b < 12288, yThread (b / 2) < T → sh.bytes 7 b = bytes2 12288 (yOut C fuse I) b
  so : ∀ b < 3145728, soThread (b / 4) < T → sh.bytes 8 b = bytes4 3145728 (stateOut C fuse I) b
  log : ∀ a ∈ sh.log, Owned (launch I A initial) dev tgo a

/-! ### Each phase keeps the invariant -/

section Preserve
variable {C : M1Max.Contract} {fuse : Nat → Bool} {I : Ins} {A : Al} {initial : Nat → ByteMemory.Bytes}
  {ctx : Ctx} {n r d : Nat}

theorem memA_regions {sh : Shared} : (memA C ctx I n r d sh).regions = sh.regions :=
  (decayMem_regions 4).trans (loadMem_regions 4)

theorem memA_bytes {sh : Shared} {x : Nat} (hx : x ≠ ctx.threadArray 0) : (memA C ctx I n r d sh).bytes x = sh.bytes x :=
  (decayMem_bytes hx 4).trans (loadMem_bytes hx 4)

theorem memA_arr {sh : Shared} :
    Arr ((memA C ctx I n r d sh).bytes (ctx.threadArray 0)) (fun j => decayed C I n r (4 * d + j)) 4 :=
  (decayMem_arr (loadMem_arr 4 le_rfl) 4 le_rfl).congr fun j hj => by simp [hj]

/-- Phase A keeps the invariant: it only reads the inputs. -/
theorem inv_A {T : Nat} (ha : 9 ≤ ctx.threadArray 0) {sh : Shared} (hI : Inv C fuse I A initial T sh) :
    Inv C fuse I A initial T (memA C ctx I n r d sh) where
  regions := memA_regions.trans hI.regions
  inputs := hI.inputs.of fun x hx => memA_bytes (by omega)
  epoch := (decayMem_epoch 4).trans ((loadMem_epoch 4).trans hI.epoch)
  y := fun b hb ho => by rw [memA_bytes (by omega)]; exact hI.y b hb ho
  so := fun b hb ho => by rw [memA_bytes (by omega)]; exact hI.so b hb ho
  log := fun a ha' => by
    rcases decayMem_log 4 a ha' with h1 | ⟨hreg, hw⟩
    · rcases loadMem_log 4 a h1 with h2 | ⟨h2, hw⟩
      · rcases logged_log a h2 with h3 | ⟨h3, hw, -⟩
        · exact hI.log a h3
        · exact owned_read I A initial a (by omega) hw
      · exact owned_read I A initial a (by omega) hw
    · exact owned_read I A initial a (by rcases hreg with h | h <;> omega) hw

theorem memB_regions {sh : Shared} : (updateMem C fuse ctx I n r d (deltaMem ctx n r sh) 4).regions = sh.regions :=
  updateMem_regions 4

theorem memB_bytes {sh : Shared} {x : Nat} (hx : x ≠ ctx.threadArray 0) :
    (updateMem C fuse ctx I n r d (deltaMem ctx n r sh) 4).bytes x = sh.bytes x :=
  updateMem_bytes hx 4

theorem memB_arr {sh : Shared} (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => decayed C I n r (4 * d + j)) 4) :
    Arr ((updateMem C fuse ctx I n r d (deltaMem ctx n r sh) 4).bytes (ctx.threadArray 0))
      (fun j => updated C fuse I n r (4 * d + j)) 4 :=
  (updateMem_arr (sh := deltaMem ctx n r sh) h0 4 le_rfl).congr fun j hj => by simp [hj]

/-- Phase B keeps the invariant: it only reads the inputs. -/
theorem inv_B {T : Nat} (ha : 9 ≤ ctx.threadArray 0) {sh : Shared} (hI : Inv C fuse I A initial T sh) :
    Inv C fuse I A initial T (updateMem C fuse ctx I n r d (deltaMem ctx n r sh) 4) where
  regions := memB_regions.trans hI.regions
  inputs := hI.inputs.of fun x hx => memB_bytes (by omega)
  epoch := (updateMem_epoch 4).trans hI.epoch
  y := fun b hb ho => by rw [memB_bytes (by omega)]; exact hI.y b hb ho
  so := fun b hb ho => by rw [memB_bytes (by omega)]; exact hI.so b hb ho
  log := fun a ha' => by
    rcases updateMem_log 4 a ha' with h1 | ⟨hreg, hw⟩
    · rcases logged_log a h1 with h2 | ⟨h2, hw, -⟩
      · rcases logged_log a h2 with h3 | ⟨h3, hw, -⟩
        · exact hI.log a h3
        · exact owned_read I A initial a (by omega) hw
      · exact owned_read I A initial a (by omega) hw
    · exact owned_read I A initial a (by rcases hreg with h | h <;> omega) hw

theorem storeMem_epoch {sh : Shared} : ∀ k, (storeMem C fuse ctx I n r d sh k).deviceEpoch = sh.deviceEpoch
  | 0 => rfl
  | k + 1 => storeMem_epoch k

theorem yMem_epoch {sh : Shared} : (yMem C fuse ctx I n r d sh).deviceEpoch = sh.deviceEpoch := by
  unfold yMem; split <;> rfl

theorem yMem_out {sh : Shared} : (yMem C fuse ctx I n r d sh).bytes 7 = if d = 0 then
    writeBytes (sh.bytes 7) (2 * (n * 128 + r)) (wordBytes 2 (Val.bf16Bits (C.narrow (outSum C fuse I n r))))
    else sh.bytes 7 := by
  unfold yMem; split
  · rw [tput_bytes, ite_eq_left rfl]; rfl
  · rfl

theorem yMem_log {sh : Shared} : ∀ e ∈ (yMem C fuse ctx I n r d sh).log, e ∈ sh.log ∨
    (d = 0 ∧ e.region = 7 ∧ e.thread = ctx.thread ∧ e.group = ctx.group ∧ e.deviceEpoch = sh.deviceEpoch ∧
      2 * (n * 128 + r) ≤ e.byte ∧ e.byte < 2 * (n * 128 + r) + 2) := by
  intro e he
  unfold yMem at he
  split at he
  · rename_i hd0
    rcases logged_log e he with h | ⟨h1, -, h3, h4, h5, h6, h7⟩
    · exact .inl h
    · exact .inr ⟨hd0, h1, h3, h4, h5, h6, h7⟩
  · exact .inl he

theorem storeMem_out {sh : Shared} : ∀ k, (storeMem C fuse ctx I n r d sh k).bytes 8 =
    wrote4 ((n * 128 + r) * 128 + 4 * d) (fun j => updated C fuse I n r (4 * d + j)) (sh.bytes 8) k
  | 0 => by funext b; unfold wrote4; rw [ite_eq_right (by omega)]; rfl
  | k + 1 => by
    funext b
    rw [storeMem, tput_bytes, ite_eq_left rfl]
    show writeBytes ((storeMem C fuse ctx I n r d sh k).bytes 8) _ _ b = _
    rw [storeMem_out k, show (n * 128 + r) * 128 + (4 * d + k) = (n * 128 + r) * 128 + 4 * d + k by omega, wrote4_succ]

theorem storeMem_log {sh : Shared} : ∀ k, ∀ e ∈ (storeMem C fuse ctx I n r d sh k).log, e ∈ sh.log ∨
    (e.region = 8 ∧ e.thread = ctx.thread ∧ e.group = ctx.group ∧ e.deviceEpoch = sh.deviceEpoch ∧
      4 * ((n * 128 + r) * 128 + 4 * d) ≤ e.byte ∧ e.byte < 4 * ((n * 128 + r) * 128 + 4 * d + k))
  | 0, e, he => .inl he
  | k + 1, e, he => by
    rcases logged_log (ctx := ctx) e (show e ∈ (logged ctx (storeMem C fuse ctx I n r d sh k) 8 4
      ((n * 128 + r) * 128 + (4 * d + k)) true).log from he) with h | ⟨h1, -, h3, h4, h5, h6, h7⟩
    · rcases storeMem_log k e h with h | ⟨h1, h2, h3, h4, h5, h6⟩
      · exact .inl h
      · exact .inr ⟨h1, h2, h3, h4, h5, by omega⟩
    · exact .inr ⟨h1, h3, h4, h5.trans (storeMem_epoch k), by omega, by omega⟩

theorem wrote4_bytes4 {N base : Nat} {vals f : Nat → Float32} {old : ByteMemory.Bytes} {b : Nat} (hb : b < N)
    (hr : 4 * base ≤ b ∧ b < 4 * (base + 4)) (hf : ∀ j < 4, f (base + j) = vals j) :
    wrote4 base vals old 4 b = bytes4 N f b := by
  unfold wrote4 bytes4
  rw [ite_eq_left hr, ite_eq_left hb, show b / 4 = base + (b - 4 * base) / 4 by omega, hf _ (by omega),
    show b % 4 = (b - 4 * base) % 4 by omega]

theorem stateOut_eq {n r d j : Nat} (hr : r < 128) (hd : d < 32) (hj : j < 4) :
    stateOut C fuse I ((n * 128 + r) * 128 + 4 * d + j) = updated C fuse I n r (4 * d + j) := by
  unfold stateOut
  rw [show ((n * 128 + r) * 128 + 4 * d + j) / 128 / 128 = n by omega,
    show ((n * 128 + r) * 128 + 4 * d + j) / 128 % 128 = r by omega,
    show ((n * 128 + r) * 128 + 4 * d + j) % 128 = 4 * d + j by omega]

/-- Phase C of lane `d` of SIMD-group `s` of threadgroup `(0, yy, n)` writes the bytes it owns. -/
theorem inv_C {yy s : Nat} (hy : yy < 32) (hs : s < 4) (hd : d < 32) (hr : r = 4 * yy + s)
    (ht : ctx.thread = 128 * (yy + 32 * n) + 32 * s + d) (hg : ctx.group = yy + 32 * n)
    {sh : Shared} (hI : Inv C fuse I A initial (128 * (yy + 32 * n) + 32 * s + d) sh) :
    Inv C fuse I A initial (128 * (yy + 32 * n) + 32 * s + d + 1)
      (storeMem C fuse ctx I n r d (yMem C fuse ctx I n r d sh) 4) where
  regions := (storeMem_regions 4).trans (yMem_regions.trans hI.regions)
  inputs := hI.inputs.of fun x hx => (storeMem_bytes (by omega) 4).trans (yMem_bytes (by omega))
  epoch := (storeMem_epoch 4).trans (yMem_epoch.trans hI.epoch)
  y := fun b hb ho => by
    rw [storeMem_bytes (by decide) 4, yMem_out]
    by_cases hw : d = 0 ∧ 2 * (n * 128 + r) ≤ b ∧ b < 2 * (n * 128 + r) + 2
    · rw [ite_eq_left hw.1]
      obtain ⟨i, hi, rfl⟩ : ∃ i, i < 2 ∧ b = 2 * (n * 128 + r) + i := ⟨b - 2 * (n * 128 + r), by omega, by omega⟩
      rw [writeBytes_inside _ _ _ i (by rw [wordBytes_length]; exact hi)]
      unfold bytes2 yOut
      rw [ite_eq_left hb, show (2 * (n * 128 + r) + i) / 2 = n * 128 + r by omega,
        show (2 * (n * 128 + r) + i) % 2 = i by omega, show (n * 128 + r) / 128 = n by omega,
        show (n * 128 + r) % 128 = r by omega]
    · have hne : yThread (b / 2) ≠ 128 * (yy + 32 * n) + 32 * s + d := fun e => by
        have := (yThread_eq (b := b) (yy := yy) (n := n) (s := s) hd).mp e; subst hr; exact hw this
      have hold : (if d = 0 then writeBytes (sh.bytes 7) (2 * (n * 128 + r))
          (wordBytes 2 (Val.bf16Bits (C.narrow (outSum C fuse I n r)))) else sh.bytes 7) b = sh.bytes 7 b := by
        split
        · exact writeBytes_outside _ _ _ _ (by rw [wordBytes_length]; omega)
        · rfl
      rw [hold]; exact hI.y b hb (by omega)
  so := fun b hb ho => by
    rw [storeMem_out, yMem_bytes (by decide)]
    by_cases hw : 4 * ((n * 128 + r) * 128 + 4 * d) ≤ b ∧ b < 4 * ((n * 128 + r) * 128 + 4 * d + 4)
    · exact wrote4_bytes4 hb hw (fun j hj => stateOut_eq (by omega) hd hj)
    · have hne : soThread (b / 4) ≠ 128 * (yy + 32 * n) + 32 * s + d := fun e => by
        have := (soThread_eq (b := b) (yy := yy) (n := n) (s := s) (d := d)).mp e; subst hr; exact hw this
      unfold wrote4; rw [ite_eq_right (by omega)]
      exact hI.so b hb (by omega)
  log := fun a ha => by
    rcases storeMem_log 4 a ha with h1 | ⟨h1, h2, h3, h4, h5, h6⟩
    · rcases yMem_log a h1 with h1 | ⟨hd0, h1, h2, h3, h4, h5, h6⟩
      · exact hI.log a h1
      · refine owned_write I A initial a (.inl h1) (128 * (yy + 32 * n) + 32 * s + d) ?_ (h2.trans ht)
          (by rw [h3, hg]; omega) (h4.trans hI.epoch)
        rw [h1, ← (yThread_eq (b := a.byte) (yy := yy) (n := n) (s := s) hd).mpr ⟨hd0, by subst hr; omega, by subst hr; omega⟩]
        rfl
    · refine owned_write I A initial a (.inr h1) (128 * (yy + 32 * n) + 32 * s + d) ?_ (h2.trans ht)
        (by rw [h3, hg]; omega) (h4.trans (yMem_epoch.trans hI.epoch))
      rw [h1, ← (soThread_eq (b := a.byte) (yy := yy) (n := n) (s := s) (d := d)).mpr ⟨by subst hr; omega, by subst hr; omega⟩]
      rfl

end Preserve

/-! ## SIMD-groups, threadgroups and the launch -/

/-- The input buffers' alignments cover their element accesses. -/
structure Al.Ok (A : Al) : Prop where
  q : 2 ∣ A.q
  k : 2 ∣ A.k
  v : 2 ∣ A.v
  g : 4 ∣ A.g
  beta : 2 ∣ A.beta
  state : 4 ∣ A.state
  t : 4 ∣ A.t

section Run
variable {C : M1Max.Contract} {fuse : Nat → Bool} {I : Ins} {A : Al} {initial : Nat → ByteMemory.Bytes}

theorem regs_of (hA : A.Ok) {yy n s : Nat} (i : Nat) {sh : Shared} (hr : sh.regions = (launch I A initial).regions) :
    Regs ((launch I A initial).ctxAt fuse 0 yy n (32 * s + i)) A sh.regions :=
  ⟨by rw [hr]; rfl, by rw [hr]; rfl, by rw [hr]; rfl, by rw [hr]; rfl, by rw [hr]; rfl, by rw [hr]; rfl,
    by rw [hr]; rfl, by rw [hr]; rfl, by rw [hr]; rfl, by rw [hr, ctx_arr]; exact launch_rt I A initial _,
    by rw [ctx_arr]; omega, hA.q, hA.k, hA.v, hA.g, hA.beta, hA.state, hA.t⟩

/-- A SIMD-group: every lane runs to the first `simd_sum`, from it to the second, and from that to the end. -/
theorem simd_run (hA : A.Ok) (hT : I.t 0 = 1 ∧ I.t 1 = 0 ∧ I.t 2 = 0 ∧ I.t 3 = 0) {yy n s : Nat} (hy : yy < 32)
    (hn : n < 48) (hs : s < 4) (sh : Shared) (hI : Inv C fuse I A initial (128 * (yy + 32 * n) + 32 * s) sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared), (∃ N, ∀ m ≥ N,
      (runSimd C m 3 (List.ofFn ((launch I A initial).lanes fuse 0 yy n s))).run sh = some (List.ofFn V, sh')) ∧
      Inv C fuse I A initial (128 * (yy + 32 * n) + 32 * s + 32) sh' ∧ ∀ i, (V i).status = .done := by
  -- phase A
  obtain ⟨U, sh1, ⟨N1, hN1⟩, ⟨hI1, hA1⟩, hU⟩ := mapM_ofFn_ev ((launch I A initial).lanes fuse 0 yy n s) (runThread C)
    (fun i sh => Inv C fuse I A initial (128 * (yy + 32 * n) + 32 * s) sh ∧
      ∀ j < i, Arr (sh.bytes (9 + (128 * (yy + 32 * n) + 32 * s + j))) (fun c => decayed C I n (4 * yy + s) (4 * j + c)) 4)
    (fun i u => ∃ L', u = ⟨(launch I A initial).ctxAt fuse 0 yy n (32 * s + i), L', [.block restA, loopFrame, .block tail],
        .collective 2 30 .sum .f32 (.f32 (kvPart C fuse I n (4 * yy + s) i 4)) 0⟩ ∧
      PreB ((launch I A initial).ctxAt fuse 0 yy n (32 * s + i)) n (4 * yy + s) i L')
    (fun i sh hI => by
      have ha := ctx_arr I A initial fuse (yy := yy) (n := n) (s := s) i
      obtain ⟨L', ⟨N, hN⟩, hp⟩ := phaseA (C := C) (ctx_lane I A initial fuse hy hn hs i)
        (regs_of hA i hI.1.regions) hI.1.inputs hT
      refine ⟨_, _, ⟨N, hN⟩, ⟨inv_A (by omega) hI.1, fun j hj => ?_⟩, L', rfl, hp⟩
      rcases Nat.lt_succ_iff_lt_or_eq.mp hj with hj | rfl
      · rw [memA_bytes (by omega)]; exact hI.2 j hj
      · rw [← ha]; exact memA_arr)
    sh ⟨hI, fun j hj => absurd hj (by omega)⟩
  choose LU hLU hpU using hU
  -- phase B
  obtain ⟨U2, sh2, ⟨N2, hN2⟩, ⟨hI2, hA2⟩, hU2⟩ := mapM_ofFn_ev
    (fun i => { U i with status := .running }.set 30 (.f32 (kvMem C fuse I n (4 * yy + s)))) (runThread C)
    (fun i sh => Inv C fuse I A initial (128 * (yy + 32 * n) + 32 * s) sh ∧
      ∀ j : Fin 32, Arr (sh.bytes (9 + (128 * (yy + 32 * n) + 32 * s + j)))
        (fun c => if j.val < i then updated C fuse I n (4 * yy + s) (4 * j + c) else decayed C I n (4 * yy + s) (4 * j + c)) 4)
    (fun i u => ∃ L', u = ⟨(launch I A initial).ctxAt fuse 0 yy n (32 * s + i), L', [.block restB, loopFrame, .block tail],
        .collective 5 35 .sum .f32 (.f32 (outPart C fuse I n (4 * yy + s) i 4)) 0⟩ ∧
      PreB ((launch I A initial).ctxAt fuse 0 yy n (32 * s + i)) n (4 * yy + s) i L')
    (fun i sh hI => by
      have ha := ctx_arr I A initial fuse (yy := yy) (n := n) (s := s) i
      dsimp only
      rw [hLU i]
      have h0 : Arr (sh.bytes (((launch I A initial).ctxAt fuse 0 yy n (32 * s + i)).threadArray 0))
          (fun c => decayed C I n (4 * yy + s) (4 * i + c)) 4 := by
        rw [ha]; exact (hI.2 i).congr fun c _ => by simp
      obtain ⟨L', ⟨N, hN⟩, hp⟩ := phaseB (C := C) (ctx_lane I A initial fuse hy hn hs i)
        (regs_of hA i hI.1.regions) hI.1.inputs h0 (LU i) (hpU i)
      refine ⟨_, _, ⟨N, hN⟩, ⟨inv_B (by omega) hI.1, fun j => ?_⟩, L', rfl, hp⟩
      by_cases hji : j = i
      · subst hji; rw [← ha]; exact (memB_arr h0).congr fun c _ => by simp
      · have hj : j.val ≠ i.val := fun e => hji (Fin.ext e)
        rw [memB_bytes (by omega)]
        exact (hI.2 j).congr fun c _ => by
          by_cases h1 : j.val < i.val
          · simp [h1, show j.val < i.val + 1 by omega]
          · simp [h1, show ¬ j.val < i.val + 1 by omega])
    sh1 ⟨hI1, fun j => (hA1 j j.isLt).congr fun c _ => by simp⟩
  choose LU2 hLU2 hpU2 using hU2
  -- phase C
  obtain ⟨V, sh3, ⟨N3, hN3⟩, ⟨hI3, -⟩, hV⟩ := mapM_ofFn_ev
    (fun i => { U2 i with status := .running }.set 35 (.f32 (outSum C fuse I n (4 * yy + s)))) (runThread C)
    (fun i sh => Inv C fuse I A initial (128 * (yy + 32 * n) + 32 * s + i) sh ∧
      ∀ j : Fin 32, Arr (sh.bytes (9 + (128 * (yy + 32 * n) + 32 * s + j)))
        (fun c => updated C fuse I n (4 * yy + s) (4 * j + c)) 4)
    (fun _ t => t.status = .done)
    (fun i sh hI => by
      have ha := ctx_arr I A initial fuse (yy := yy) (n := n) (s := s) i
      dsimp only
      rw [hLU2 i]
      have h0 : Arr (sh.bytes (((launch I A initial).ctxAt fuse 0 yy n (32 * s + i)).threadArray 0))
          (fun c => updated C fuse I n (4 * yy + s) (4 * i + c)) 4 := by
        rw [ha]; exact hI.2 i
      obtain ⟨L', N, hN⟩ := phaseC (C := C) (ctx_lane I A initial fuse hy hn hs i) (regs_of hA i hI.1.regions) h0
        (LU2 i) (hpU2 i)
      refine ⟨_, _, ⟨N, hN⟩, ⟨inv_C hy hs i.isLt rfl (ctx_thread I A initial fuse i) (ctx_group I A initial fuse i)
        hI.1, fun j => ?_⟩, rfl⟩
      rw [storeMem_bytes (by omega) 4, yMem_bytes (by omega)]
      exact hI.2 j)
    sh2 ⟨by simpa using hI2, fun j => (hA2 j).congr fun c _ => by simp [j.isLt]⟩
  refine ⟨V, sh3, ⟨max N1 (max N2 N3), fun m hm => ?_⟩, hI3, hV⟩
  rw [runSimd_collective_ofFn C m 2 _ U sh sh1 2 30 .sum .f32 0 (fun i => .f32 (kvPart C fuse I n (4 * yy + s) i 4))
    (fun _ => .f32 (kvMem C fuse I n (4 * yy + s))) (hN1 m (by omega)) (fun i => by rw [hLU i]) (resolve_sum C 0 _)]
  rw [runSimd_collective_ofFn C m 1 _ U2 sh1 sh2 5 35 .sum .f32 0 (fun i => .f32 (outPart C fuse I n (4 * yy + s) i 4))
    (fun _ => .f32 (outSum C fuse I n (4 * yy + s))) (hN2 m (by omega)) (fun i => by rw [hLU2 i]) (resolve_sum C 0 _)]
  exact runSimd_blocked_ofFn C m 0 _ V sh2 sh3 (hN3 m (by omega)) (fun i => by rw [hV i]; rfl)

/-- A threadgroup: its four SIMD-groups, one after another. -/
theorem group_run (hA : A.Ok) (hT : I.t 0 = 1 ∧ I.t 1 = 0 ∧ I.t 2 = 0 ∧ I.t 3 = 0) {yy n : Nat} (hy : yy < 32)
    (hn : n < 48) (sh : Shared) (hI : Inv C fuse I A initial (128 * (yy + 32 * n)) sh) :
    ∃ sh', (∃ N, ∀ m ≥ N, (runGroup C m 3 1 (List.ofFn fun s : Fin 4 =>
      List.ofFn ((launch I A initial).lanes fuse 0 yy n s))).run sh = some ((), sh')) ∧
      Inv C fuse I A initial (128 * (yy + 32 * n + 1)) sh' := by
  obtain ⟨W, sh', ⟨N, hN⟩, hI', hW⟩ := mapM_ofFn_ev (fun s : Fin 4 => List.ofFn ((launch I A initial).lanes fuse 0 yy n s))
    (runSimd C · 3) (fun s sh => Inv C fuse I A initial (128 * (yy + 32 * n) + 32 * s) sh)
    (fun _ u => ∃ V : Fin 32 → Thread, u = List.ofFn V ∧ ∀ i, (V i).status = .done)
    (fun s sh hI => by
      obtain ⟨V, sh', ⟨N, hN⟩, hI', hV⟩ := simd_run hA hT hy hn s.isLt sh hI
      have hI'' : Inv C fuse I A initial (128 * (yy + 32 * n) + 32 * (s.val + 1)) sh' := by
        rw [show 128 * (yy + 32 * n) + 32 * (s.val + 1) = 128 * (yy + 32 * n) + 32 * s + 32 by ring]; exact hI'
      exact ⟨_, sh', ⟨N, hN⟩, hI'', V, rfl, hV⟩)
    sh (by simpa using hI)
  choose V hV using hW
  refine ⟨sh', ⟨N, fun m hm => ?_⟩, by rw [show 128 * (yy + 32 * n + 1) = 128 * (yy + 32 * n) + 32 * 4 by ring]; exact hI'⟩
  refine runGroup_done_ofFn C m 3 0 _ V sh sh' ?_ (fun j i => (hV j).2 i)
  rw [hN m hm, show W = fun j => List.ofFn (V j) from funext fun j => (hV j).1]

theorem inv_initial (garbage : Garbage) :
    Inv C fuse I A initial 0 ((launch I A initial).initial garbage) where
  regions := rfl
  inputs := ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
  epoch := rfl
  y := fun _ _ ho => absurd ho (Nat.not_lt_zero _)
  so := fun _ _ ho => absurd ho (Nat.not_lt_zero _)
  log := fun _ ha => by simp [Launch.initial] at ha

/-- The launch: its 32 × 48 threadgroups in order. -/
theorem launch_ok (hA : A.Ok) (hT : I.t 0 = 1 ∧ I.t 1 = 0 ∧ I.t 2 = 0 ∧ I.t 3 = 0) (garbage : Garbage) :
    ∃ sh fuel, Inv C fuse I A initial (128 * (1 * 32 * 48)) sh ∧
      runLaunch C fuse (launch I A initial) garbage fuel 3 1 = some ⟨sh.bytes, sh.log⟩ :=
  launch_run_fuel C (tiles I A initial) fuse garbage 3 1 (fun g sh => Inv C fuse I A initial (128 * g) sh)
    (inv_initial garbage)
    (fun bx byy bz hx hy hz sh hI => by
      obtain rfl : bx = 0 := by omega
      rw [show 0 + byy * 1 + bz * 1 * 32 = byy + 32 * bz by ring] at hI ⊢
      rw [Launch.resetGroup_none _ _ _ _ rfl]
      exact group_run hA hT hy hz sh hI)

end Run

/-! ## The GPU theorem -/

theorem clip_eq (Y S : ByteMemory.Bytes) (hY : ∀ b, 12288 ≤ b → Y b = 0) (hS : ∀ b, 3145728 ≤ b → S b = 0) :
    clip [12288, 3145728] (fun i => [Y, S].getD i (fun _ => 0)) = [Y, S] := by
  unfold clip
  rw [show [12288, 3145728].zipIdx = [(12288, 0), (3145728, 1)] from rfl]
  simp only [List.map_cons, List.map_nil, List.cons.injEq, and_true]
  refine ⟨?_, ?_⟩ <;> funext b <;> split
  · rfl
  · exact (hY b (by omega)).symm
  · rfl
  · exact (hS b (by omega)).symm

theorem bytes2_zero (N : Nat) (f : Nat → BF) (b : Nat) (hb : N ≤ b) : bytes2 N f b = 0 := by
  unfold bytes2; rw [ite_eq_right (by omega)]

theorem bytes4_zero (N : Nat) (f : Nat → Float32) (b : Nat) (hb : N ≤ b) : bytes4 N f b = 0 := by
  unfold bytes4; rw [ite_eq_right (by omega)]

variable (C : M1Max.Contract)

/-- **The GPU runs gated_delta_step as specified.** Under the GPU assumption, MLX's launch of the exact assembled
text at `gatedConfig` on any `q`, `k`, `v`, `g`, `beta`, `state_in` (base addresses aligned to their element
sizes) and a `T` buffer holding the int32 1 produces `y` and `state_out` whose every element is the source's
value for one time step: each state row decayed by `g`, its `simd_sum`med key product subtracted from `v` and
scaled by `beta` into `delta`, the row updated by `k * delta`, and `y` the bf16 narrowing of the `simd_sum`med
query product — at the compiler's contraction choices at the three accumulations. -/
theorem gpu_output (G : Gpu C) (hmax : 128 ≤ G.maxThreads Metal.Elab.Tests.gatedDeltaStepText)
    (q k v g beta s t : ByteMemory.Bytes) (aq ak av ag ab as aT : Nat)
    (hq : 2 ∣ aq) (hk : 2 ∣ ak) (hv : 2 ∣ av) (hg : 4 ∣ ag) (hb : 2 ∣ ab) (hs : 4 ∣ as) (ht : 4 ∣ aT)
    (hT : t 0 = 1 ∧ t 1 = 0 ∧ t 2 = 0 ∧ t 3 = 0) :
    G.execute Metal.Elab.Tests.gatedDeltaStepText (32, 128, 48) (32, 4, 1)
      [⟨.device, 4096, aq, q⟩, ⟨.device, 4096, ak, k⟩, ⟨.device, 12288, av, v⟩, ⟨.device, 192, ag, g⟩,
        ⟨.device, 96, ab, beta⟩, ⟨.device, 3145728, as, s⟩, ⟨.constant, 4, aT, t⟩] [12288, 3145728] =
      some [bytes2 12288 (yOut C (G.fusion Metal.Elab.Tests.gatedDeltaStepText) ⟨q, k, v, g, beta, s, t⟩),
        bytes4 3145728 (stateOut C (G.fusion Metal.Elab.Tests.gatedDeltaStepText) ⟨q, k, v, g, beta, s, t⟩)] := by
  rw [← clip_eq _ _ (bytes2_zero _ _) (bytes4_zero _ _)]
  apply gpu_owned C G _ compile_eq (by simpa using hmax)
  intro initial garbage
  obtain ⟨sh, fuel, hI, hr⟩ := launch_ok (C := C) (fuse := G.fusion Metal.Elab.Tests.gatedDeltaStepText)
    (I := ⟨q, k, v, g, beta, s, t⟩) (A := ⟨aq, ak, av, ag, ab, as, aT⟩) (initial := initial)
    ⟨hq, hk, hv, hg, hb, hs, ht⟩ hT garbage
  refine ⟨fuel, 3, 1, sh, dev, tgo, hr, hI.log, fun i hi b hb' => ?_⟩
  simp only [List.length_cons, List.length_nil] at hi
  rcases (by omega : i = 0 ∨ i = 1) with rfl | rfl
  · exact hI.y b hb' (by have := yThread_lt hb'; omega)
  · exact hI.so b hb' (by have := soThread_lt hb'; omega)

end Metal.Kernels.GatedDeltaStep

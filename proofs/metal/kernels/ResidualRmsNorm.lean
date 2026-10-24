import metal.Logic
import metal.Launch
import metal.tests.Elab
import metal.Gpu
import metal.Steps
import metal.Group
import metal.kernels.GatedRmsNorm

namespace Metal.Kernels.ResidualRmsNorm
open Metal Metal.Core Inference.Contracts.Mlx

/-! # residual-rms-norm.ts

```
const uint row = threadgroup_position_in_grid.x;
const uint tid = thread_position_in_threadgroup.x;
const uint lane = thread_index_in_simdgroup;
const uint sg = simdgroup_index_in_threadgroup;
threadgroup float sums[32];
threadgroup float inv[1];
float acc = 0.0f;
for (uint r = 0; r < uint(D); r += uint(THREADS) * 4u) {
  for (uint i = 0; i < 4u; ++i) {
    const uint col = r + tid * 4u + i;
    if (col < uint(D)) {
      const uint index = row * uint(D) + col;
      const T value = T(float(x[index]) + float(update[index]));
      residual[index] = value;
      const float v = float(value);
      acc += v * v;
    }
  }
}
acc = metal::simd_sum(acc);
if (sg == 0) sums[lane] = 0.0f;
threadgroup_barrier(metal::mem_flags::mem_threadgroup);
if (lane == 0) sums[sg] = acc;
threadgroup_barrier(metal::mem_flags::mem_threadgroup);
if (sg == 0) {
  acc = metal::simd_sum(sums[lane]);
  if (lane == 0) inv[0] = metal::precise::rsqrt(acc / float(D) + as_type<float>(uint(EPS)));
}
threadgroup_barrier(metal::mem_flags::mem_threadgroup | metal::mem_flags::mem_device);
for (uint r = 0; r < uint(D); r += uint(THREADS) * 4u) {
  for (uint i = 0; i < 4u; ++i) {
    const uint col = r + tid * 4u + i;
    if (col < uint(D)) {
      const uint index = row * uint(D) + col;
      normalized[index] = weight[col] * T(float(residual[index]) * inv[0]);
    }
  }
}
```
at `residualConfig`: grid [1024, 1, 1], threadgroup [1024, 1, 1], so one threadgroup of 32 SIMD-groups, with
D = 5120, THREADS = 1024, EPS = 897988541 (the f32 word 0x358637BD of 1e-6). -/

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)
def u16l (n : Nat) : CExpr := .lit (.int .u16 n)
def i32l (n : Nat) : CExpr := .lit (.int .i32 n)
def f32l (bits : Nat) : CExpr := .lit (.f32 (Val.ofF32Bits bits))

def sgIsZero : CExpr := .bin .eq .u32 0 (.local 8) (u32l 0)
def laneIsZero : CExpr := .bin .eq .u32 0 (.local 7) (u32l 0)

def addRowCond : CExpr := .bin .lt .u32 0 (.local 12) (u32l 5120)
def addRowStep : List CStmt := [.set 12 (.bin .add .u32 0 (.local 12) (u32l 4096))]
def addColCond : CExpr := .bin .lt .u32 0 (.local 13) (u32l 4)
def addColStep : List CStmt := [.set 13 (.bin .add .u32 0 (.local 13) (u32l 1))]
def addInBounds : List CStmt :=
  [.set 15 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 5) (u32l 5120)) (.local 14)),
   .set 16
     (.bin .add .bf16 0 (.load (.scalar .bf16) (.offset (.local 0) (.local 15)))
       (.load (.scalar .bf16) (.offset (.local 1) (.local 15)))),
   .store (.scalar .bf16) (.offset (.local 3) (.local 15)) (.local 16),
   .set 17 (.conv .f32 (.local 16)),
   .set 11 (.bin .add .f32 1 (.local 11) (.bin .mul .f32 0 (.local 17) (.local 17)))]
def addGuard : CStmt := .ite (.bin .lt .u32 0 (.local 14) (u32l 5120)) addInBounds []
def addColBody : List CStmt :=
  [.set 14 (.bin .add .u32 0 (.bin .add .u32 0 (.local 12) (.bin .mul .u32 0 (.local 6) (u32l 4))) (.local 13)),
   addGuard]
def addColLoop : CStmt := .loop addColCond addColStep addColBody
def addRowBody : List CStmt := [.set 13 (u32l 0), addColLoop]

def clearSums : CStmt := .ite sgIsZero [.store (.scalar .f32) (.offset (.local 9) (.local 7)) (f32l 0x0)] []
def publishSum : CStmt := .ite laneIsZero [.store (.scalar .f32) (.offset (.local 9) (.local 8)) (.local 11)] []
def rsqrtMean : CExpr :=
  .un .rsqrt .f32 (.bin .add .f32 0 (.bin .div .f32 0 (.local 11) (f32l 0x45A00000)) (f32l 0x358637BD))
def invStore : CStmt := .ite laneIsZero [.store (.scalar .f32) (.offset (.local 10) (i32l 0)) rsqrtMean] []
def foldSums : CStmt :=
  .ite sgIsZero
    [.collective 5 19 .sum .f32 (.load (.scalar .f32) (.offset (.local 9) (.local 7))) (u16l 0),
     .set 11 (.local 19),
     invStore] []

def normRowCond : CExpr := .bin .lt .u32 0 (.local 20) (u32l 5120)
def normRowStep : List CStmt := [.set 20 (.bin .add .u32 0 (.local 20) (u32l 4096))]
def normColCond : CExpr := .bin .lt .u32 0 (.local 21) (u32l 4)
def normColStep : List CStmt := [.set 21 (.bin .add .u32 0 (.local 21) (u32l 1))]
def normStore : CStmt :=
  .store (.scalar .bf16) (.offset (.local 4) (.local 23))
    (.bin .mul .bf16 0 (.load (.scalar .bf16) (.offset (.local 2) (.local 22)))
      (.conv .bf16
        (.bin .mul .f32 0 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 3) (.local 23))))
          (.load (.scalar .f32) (.offset (.local 10) (i32l 0))))))
def normInBounds : List CStmt :=
  [.set 23 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 5) (u32l 5120)) (.local 22)), normStore]
def normGuard : CStmt := .ite (.bin .lt .u32 0 (.local 22) (u32l 5120)) normInBounds []
def normColBody : List CStmt :=
  [.set 22 (.bin .add .u32 0 (.bin .add .u32 0 (.local 20) (.bin .mul .u32 0 (.local 6) (u32l 4))) (.local 21)),
   normGuard]
def normColLoop : CStmt := .loop normColCond normColStep normColBody
def normRowBody : List CStmt := [.set 21 (u32l 0), normColLoop]

/-- Slots: 0 x, 1 update, 2 weight, 3 residual, 4 normalized, 5 row, 6 tid, 7 lane, 8 sg,
9 sums (threadgroup array 0), 10 inv (threadgroup array 1), 11 acc, 12 r, 13 i, 14 col, 15 index, 16 value, 17 v,
18 the first `simd_sum` result, 19 the second `simd_sum` result, 20 r, 21 i, 22 col, 23 index. -/
def body : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .bf16⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .bf16⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .bf16⟩)),
   .set 4 (.lit (.ptr ⟨4, 0, .scalar .bf16⟩)),
   .set 5 (.component (.coord .threadgroupPositionInGrid) (u32l 0)),
   .set 6 (.component (.coord .threadPositionInThreadgroup) (u32l 0)),
   .set 7 (.coord .threadIndexInSimdgroup),
   .set 8 (.coord .simdgroupIndexInThreadgroup),
   .array 9 true 0 (.scalar .f32),
   .array 10 true 1 (.scalar .f32),
   .set 11 (f32l 0x0),
   .set 12 (u32l 0),
   .loop addRowCond addRowStep addRowBody,
   .collective 2 18 .sum .f32 (.local 11) (u16l 0),
   .set 11 (.local 18),
   clearSums,
   .barrier 3 false true,
   publishSum,
   .barrier 4 false true,
   foldSums,
   .barrier 6 true true,
   .set 20 (u32l 0),
   .loop normRowCond normRowStep normRowBody]

def core : Kernel := ⟨5, [(.scalar .f32, 32), (.scalar .f32, 1)], [], body⟩

-- The elaborated text MLX compiles (tests/Assemble.lean) is `core`.
kernel_rfl compile_eq : (frontend Metal.Elab.Tests.residualRmsNormText).bind elaborate = some core

variable (C : M1Max.Contract)

/-! ## Expected outputs

The quantities of the source, on the bf16 elements of the inputs, with the operations the core
applies. `fuse` is the compiler's choice at contraction site 1 (`acc += v * v`), the core's only
contraction site (sites 2 and 5 are the `simd_sum`s, 3, 4 and 6 the barriers). Thread `t` handles
columns `4t + i` and, for `t < 256`, `4096 + 4t + i`. -/

def zero : Float32 := Val.ofF32Bits 0

/-- `value = T(float(x[e]) + float(update[e]))`, the core's bf16 addition. -/
def resv (X U : ByteMemory.Bytes) (e : Nat) : BF := C.bfadd (bfAt X e) (bfAt U e)

/-- Thread `t`'s column at its step `m` (iteration `m / 4` of the outer loop, `m % 4` of the inner):
`r + tid * 4 + i`. -/
def colOf (t m : Nat) : Nat := 4096 * (m / 4) + t * 4 + m % 4

/-- Thread `t`'s `acc` after its first `m` steps (`acc += v * v` on the columns below D). -/
def accR (fuse : Bool) (X U : ByteMemory.Bytes) (t : Nat) : Nat → Float32
  | 0 => zero
  | m + 1 =>
    if colOf t m < 5120 then
      if fuse then C.fma (C.widen (resv C X U (colOf t m))) (C.widen (resv C X U (colOf t m))) (accR fuse X U t m)
      else C.fadd (accR fuse X U t m) (C.fmul (C.widen (resv C X U (colOf t m))) (C.widen (resv C X U (colOf t m))))
    else accR fuse X U t m

/-- SIMD-group `q`'s `simd_sum(acc)` over its threads `32 q + i`, published in `sums[q]`. -/
def simdS (fuse : Bool) (X U : ByteMemory.Bytes) (q : Nat) : Float32 :=
  C.simdSum fun i => accR C fuse X U (32 * q + i) 8

/-- SIMD-group 0's `simd_sum(sums[lane])`: the row's sum of squares. -/
def total (fuse : Bool) (X U : ByteMemory.Bytes) : Float32 := C.simdSum fun i => simdS C fuse X U i

/-- `inv[0] = rsqrt(acc / float(D) + eps)`. -/
def invR (fuse : Bool) (X U : ByteMemory.Bytes) : Float32 :=
  C.rsqrt (C.fadd (C.fdiv (total C fuse X U) (Val.ofF32Bits 0x45A00000)) (Val.ofF32Bits 0x358637BD))

/-- `normalized[e] = weight[e] * T(float(residual[e]) * inv[0])`. -/
def normR (fuse : Bool) (X U W : ByteMemory.Bytes) (e : Nat) : BF :=
  C.bfmul (bfAt W e) (C.narrow (C.fmul (C.widen (resv C X U e)) (invR C fuse X U)))

/-- Byte `b` of `residual` [1, 1, 5120] bf16. -/
def expectedResidual (X U : ByteMemory.Bytes) (b : Nat) : BitVec 8 :=
  if b < 10240 then (wordBytes 2 (Val.bf16Bits (resv C X U (b / 2)))).getD (b % 2) 0 else 0

/-- Byte `b` of `normalized` [1, 1, 5120] bf16. -/
def expectedNormalized (fuse : Nat → Bool) (X U W : ByteMemory.Bytes) (b : Nat) : BitVec 8 :=
  if b < 10240 then (wordBytes 2 (Val.bf16Bits (normR C (fuse 1) X U W (b / 2)))).getD (b % 2) 0 else 0

/-! ## Ownership

Element `e < 5120` of `residual` and `normalized` belongs to thread `owner e`, which handles it at its step
`4 (e / 4096) + e % 4`; `seqOf e` orders the elements as the threads handle them. -/

def owner (e : Nat) : Nat := e % 4096 / 4
def seqOf (e : Nat) : Nat := 8 * owner e + (4 * (e / 4096) + e % 4)

theorem seqOf_inj {e e' : Nat} (he : e < 5120) (he' : e' < 5120) (h : seqOf e = seqOf e') : e = e' := by
  unfold seqOf owner at h; omega

theorem seqOf_lt {e : Nat} (he : e < 5120) : seqOf e < 8192 := by unfold seqOf owner; omega

theorem colOf_step {t j k : Nat} (ht : t < 1024) (hj : j < 2) (hk : k < 4) :
    colOf t (4 * j + k) = 4096 * j + t * 4 + k ∧
    (4096 * j + t * 4 + k < 5120 → seqOf (4096 * j + t * 4 + k) = 8 * t + (4 * j + k) ∧
      owner (4096 * j + t * 4 + k) = t) ∧
    (5120 ≤ 4096 * j + t * 4 + k → ∀ e < 5120, seqOf e ≠ 8 * t + (4 * j + k)) := by
  unfold colOf seqOf owner
  refine ⟨by omega, fun h => ⟨by omega, by omega⟩, fun h e he => by omega⟩

/-- Writers of device bytes: `residual` (region 3) in device epoch 0 and `normalized` (region 4) in device
epoch 1, each element by its owner. -/
def dev (region byte : Nat) : Option Writer :=
  if region = 3 then some ⟨owner (byte / 2), 0, 0⟩ else if region = 4 then some ⟨owner (byte / 2), 0, 1⟩ else none

/-- Owners of threadgroup bytes by barrier epoch: `sums[lane]` cleared by SIMD-group 0 (epoch 0), `sums[sg]`
written by lane 0 of SIMD-group `sg` (epoch 1), `inv[0]` written by thread 0 (epoch 2); else read-only. -/
def tgo (_g ep region byte : Nat) : Option Nat :=
  if region = 5 ∧ ep = 0 then some (byte / 4)
  else if region = 5 ∧ ep = 1 then some (32 * (byte / 4))
  else if region = 6 ∧ ep = 2 then some 0
  else none

/-- The launch's regions: the three inputs, the two outputs, `sums` and `inv`. -/
structure Shape (L : Launch) (ax au aw : Nat) : Prop where
  r0 : L.regions 0 = some ⟨.device, 10240, ax⟩
  r1 : L.regions 1 = some ⟨.device, 10240, au⟩
  r2 : L.regions 2 = some ⟨.device, 10240, aw⟩
  r3 : L.regions 3 = some ⟨.device, 10240, 16⟩
  r4 : L.regions 4 = some ⟨.device, 10240, 16⟩
  r5 : L.regions 5 = some ⟨.threadgroup, 128, 4⟩
  r6 : L.regions 6 = some ⟨.threadgroup, 4, 4⟩
  ax : ax % 2 = 0
  au : au % 2 = 0
  aw : aw % 2 = 0

/-- Memory in device epoch `de` and barrier epoch `ge`, once the elements of `residual` before `nRes` (in
`seqOf` order), the first `nSums` entries of `sums`, `inv[0]` (if `hasInv`) and the elements of `normalized`
before `nNorm` are written: inputs intact, those values as expected, every access so far owned. -/
structure Inv (L : Launch) (fz : Bool) (X U W : ByteMemory.Bytes) (de ge nRes nSums : Nat) (hasInv : Bool)
    (nNorm : Nat) (sh : Shared) : Prop where
  regions : sh.regions = L.regions
  x : sh.bytes 0 = X
  upd : sh.bytes 1 = U
  weight : sh.bytes 2 = W
  dEpoch : sh.deviceEpoch = de
  gEpoch : sh.groupEpoch = ge
  res : ∀ e < 5120, seqOf e < nRes → ∀ j < 2,
    sh.bytes 3 (2 * e + j) = (wordBytes 2 (Val.bf16Bits (resv C X U e))).getD j 0
  sums : ∀ q < nSums, ∀ b < 4, sh.bytes 5 (4 * q + b) = (wordBytes 4 (Val.f32Bits (simdS C fz X U q))).getD b 0
  inv : hasInv = true → ∀ b < 4, sh.bytes 6 b = (wordBytes 4 (Val.f32Bits (invR C fz X U))).getD b 0
  norm : ∀ e < 5120, seqOf e < nNorm → ∀ j < 2,
    sh.bytes 4 (2 * e + j) = (wordBytes 2 (Val.bf16Bits (normR C fz X U W e))).getD j 0
  log : ∀ a ∈ sh.log, Owned L dev tgo a

section
variable {C} {L : Launch} {fz : Bool} {X U W : ByteMemory.Bytes} {de ge nRes nSums nNorm : Nat} {hv : Bool}
  {sh : Shared}

theorem Inv.read (h : Inv C L fz X U W de ge nRes nSums hv nNorm sh) (ctx : Ctx) (region off : Nat) (r : Region)
    (hr : L.regions region = some r) (hs : r.space ≠ .threadgroup) (h3 : region ≠ 3) (h4 : region ≠ 4) :
    Inv C L fz X U W de ge nRes nSums hv nNorm (rd ctx sh region off) :=
  { h with log := forall_log _ 2 _ (fun j _ => owned_device_read L dev tgo ctx sh region (off + j) r hr hs
      (by simp [dev, h3, h4])) h.log }

/-- A read of a `residual` element by its owner. -/
theorem Inv.readOwn (h : Inv C L fz X U W de ge nRes nSums hv nNorm sh) (ctx : Ctx) (e : Nat)
    (ht : ctx.thread = owner e) (r3 : L.regions 3 = some ⟨.device, 10240, 16⟩) :
    Inv C L fz X U W de ge nRes nSums hv nNorm (rd ctx sh 3 (2 * e)) :=
  { h with log := forall_log _ 2 _ (fun j hj => owned_device_own L dev tgo ctx sh 3 (2 * e + j) _ r3 (by simp)
      ⟨owner ((2 * e + j) / 2), 0, 0⟩ (by simp [dev])
      (by rw [ht]; show owner e = owner ((2 * e + j) / 2); rw [show (2 * e + j) / 2 = e by omega])) h.log }

theorem Inv.read4 (h : Inv C L fz X U W de ge nRes nSums hv nNorm sh) (ctx : Ctx) (region off : Nat) (r : Region)
    (hr : L.regions region = some r) (hs : r.space = .threadgroup)
    (hn : ∀ b < 4, tgo ctx.group ge region (off + b) = none) :
    Inv C L fz X U W de ge nRes nSums hv nNorm (rd4 ctx sh region off) :=
  { h with log := forall_log _ 4 _ (fun j hj => owned_group_read L dev tgo ctx sh region (off + j) r hr hs
      (by rw [h.gEpoch]; exact hn j hj)) h.log }

/-- SIMD-group 0 clears `sums[lane]` in barrier epoch 0. -/
theorem Inv.clear (h : Inv C L fz X U W de 0 nRes 0 hv nNorm sh) (ctx : Ctx) (i : Nat) (ht : ctx.thread = i)
    (r5 : L.regions 5 = some ⟨.threadgroup, 128, 4⟩) (y : Float32) :
    Inv C L fz X U W de 0 nRes 0 hv nNorm (wr4 ctx sh 5 (4 * i) y) where
  regions := h.regions
  x := h.x
  upd := h.upd
  weight := h.weight
  dEpoch := h.dEpoch
  gEpoch := h.gEpoch
  res := h.res
  sums := fun q hq => absurd hq (Nat.not_lt_zero q)
  inv := h.inv
  norm := h.norm
  log := forall_log _ 4 _ (fun b hb => owned_group L dev tgo ctx sh 5 (4 * i + b) _ r5 true rfl
    (by rw [h.gEpoch, ht]; simp [tgo]; omega)) h.log

/-- Lane 0 of SIMD-group `q` publishes its sum in barrier epoch 1. -/
theorem Inv.publish {q : Nat} (h : Inv C L fz X U W de 1 nRes q hv nNorm sh) (ctx : Ctx) (ht : ctx.thread = 32 * q)
    (r5 : L.regions 5 = some ⟨.threadgroup, 128, 4⟩) :
    Inv C L fz X U W de 1 nRes (q + 1) hv nNorm (wr4 ctx sh 5 (4 * q) (simdS C fz X U q)) where
  regions := h.regions
  x := h.x
  upd := h.upd
  weight := h.weight
  dEpoch := h.dEpoch
  gEpoch := h.gEpoch
  res := h.res
  sums := by
    intro q' hq' b hb
    show writeBytes (sh.bytes 5) (4 * q) (wordBytes 4 (Val.f32Bits (simdS C fz X U q))) (4 * q' + b) = _
    by_cases hlt : q' < q
    · rw [writeBytes_outside _ _ _ _ (by rw [wordBytes_length]; omega)]; exact h.sums q' hlt b hb
    · obtain rfl : q' = q := by omega
      rw [writeBytes_inside _ _ _ b (by rw [wordBytes_length]; omega)]
  inv := h.inv
  norm := h.norm
  log := forall_log _ 4 _ (fun b hb => owned_group L dev tgo ctx sh 5 (4 * q + b) _ r5 true rfl
    (by rw [h.gEpoch, ht]; simp [tgo]; omega)) h.log

/-- Thread 0 writes `inv[0]` in barrier epoch 2. -/
theorem Inv.writeInv (h : Inv C L fz X U W de 2 nRes nSums hv nNorm sh) (ctx : Ctx) (ht : ctx.thread = 0)
    (r6 : L.regions 6 = some ⟨.threadgroup, 4, 4⟩) :
    Inv C L fz X U W de 2 nRes nSums true nNorm (wr4 ctx sh 6 (4 * 0) (invR C fz X U)) where
  regions := h.regions
  x := h.x
  upd := h.upd
  weight := h.weight
  dEpoch := h.dEpoch
  gEpoch := h.gEpoch
  res := h.res
  sums := h.sums
  inv := by
    intro _ b hb
    show writeBytes (sh.bytes 6) (4 * 0) (wordBytes 4 (Val.f32Bits (invR C fz X U))) b = _
    have := writeBytes_inside (sh.bytes 6) (4 * 0) (wordBytes 4 (Val.f32Bits (invR C fz X U))) b
      (by rw [wordBytes_length]; omega)
    simpa using this
  norm := h.norm
  log := forall_log _ 4 _ (fun b hb => owned_group L dev tgo ctx sh 6 (4 * 0 + b) _ r6 true rfl
    (by rw [h.gEpoch, ht]; simp [tgo])) h.log

/-- The owner of `residual` element `e` writes it in device epoch 0. -/
theorem Inv.wrRes {n : Nat} (h : Inv C L fz X U W 0 ge n nSums hv nNorm sh) (ctx : Ctx) (e : Nat) (he : e < 5120)
    (hs : seqOf e = n) (ht : ctx.thread = owner e) (hg : ctx.group = 0)
    (r3 : L.regions 3 = some ⟨.device, 10240, 16⟩) :
    Inv C L fz X U W 0 ge (n + 1) nSums hv nNorm (wr ctx sh 3 (2 * e) (resv C X U e)) where
  regions := h.regions
  x := h.x
  upd := h.upd
  weight := h.weight
  dEpoch := h.dEpoch
  gEpoch := h.gEpoch
  res := by
    intro e' he' hs' j hj
    show writeBytes (sh.bytes 3) (2 * e) (wordBytes 2 (Val.bf16Bits (resv C X U e))) (2 * e' + j) = _
    by_cases hee : e' = e
    · subst hee; rw [writeBytes_inside _ _ _ j (by rw [wordBytes_length]; omega)]
    · rw [writeBytes_outside _ _ _ _ (by rw [wordBytes_length]; omega)]
      exact h.res e' he' (by have : seqOf e' ≠ seqOf e := fun h' => hee (seqOf_inj he' he h'); omega) j hj
  sums := h.sums
  inv := h.inv
  norm := h.norm
  log := forall_log _ 2 _ (fun j hj => owned_device L dev tgo ctx sh 3 (2 * e + j) _ r3 true (by simp)
    ⟨owner ((2 * e + j) / 2), 0, 0⟩ (by simp [dev])
    (by rw [ht]; show owner e = owner ((2 * e + j) / 2); rw [show (2 * e + j) / 2 = e by omega])
    (by rw [hg]) (by rw [h.dEpoch])) h.log

/-- A step past the row's end writes no element. -/
theorem Inv.skipRes {n : Nat} (h : Inv C L fz X U W de ge n nSums hv nNorm sh) (hno : ∀ e < 5120, seqOf e ≠ n) :
    Inv C L fz X U W de ge (n + 1) nSums hv nNorm sh :=
  { h with res := fun e he hs j hj => h.res e he (by have := hno e he; omega) j hj }

/-- The owner of `normalized` element `e` writes it in device epoch 1. -/
theorem Inv.wrNorm {n : Nat} (h : Inv C L fz X U W 1 ge nRes nSums hv n sh) (ctx : Ctx) (e : Nat) (he : e < 5120)
    (hs : seqOf e = n) (ht : ctx.thread = owner e) (hg : ctx.group = 0)
    (r4 : L.regions 4 = some ⟨.device, 10240, 16⟩) :
    Inv C L fz X U W 1 ge nRes nSums hv (n + 1) (wr ctx sh 4 (2 * e) (normR C fz X U W e)) where
  regions := h.regions
  x := h.x
  upd := h.upd
  weight := h.weight
  dEpoch := h.dEpoch
  gEpoch := h.gEpoch
  res := h.res
  sums := h.sums
  inv := h.inv
  norm := by
    intro e' he' hs' j hj
    show writeBytes (sh.bytes 4) (2 * e) (wordBytes 2 (Val.bf16Bits (normR C fz X U W e))) (2 * e' + j) = _
    by_cases hee : e' = e
    · subst hee; rw [writeBytes_inside _ _ _ j (by rw [wordBytes_length]; omega)]
    · rw [writeBytes_outside _ _ _ _ (by rw [wordBytes_length]; omega)]
      exact h.norm e' he' (by have : seqOf e' ≠ seqOf e := fun h' => hee (seqOf_inj he' he h'); omega) j hj
  log := forall_log _ 2 _ (fun j hj => owned_device L dev tgo ctx sh 4 (2 * e + j) _ r4 true (by simp)
    ⟨owner ((2 * e + j) / 2), 0, 1⟩ (by simp [dev])
    (by rw [ht]; show owner e = owner ((2 * e + j) / 2); rw [show (2 * e + j) / 2 = e by omega])
    (by rw [hg]) (by rw [h.dEpoch])) h.log

theorem Inv.skipNorm {n : Nat} (h : Inv C L fz X U W de ge nRes nSums hv n sh) (hno : ∀ e < 5120, seqOf e ≠ n) :
    Inv C L fz X U W de ge nRes nSums hv (n + 1) sh :=
  { h with norm := fun e he hs j hj => h.norm e he (by have := hno e he; omega) j hj }

theorem Inv.pass (h : Inv C L fz X U W de ge nRes nSums hv nNorm sh) (d g : Bool) :
    Inv C L fz X U W (if d then de + 1 else de) (if g then ge + 1 else ge) nRes nSums hv nNorm (pass d g sh) :=
  { h with
    dEpoch := by show (if d then sh.deviceEpoch + 1 else sh.deviceEpoch) = _; rw [h.dEpoch]
    gEpoch := by show (if g then sh.groupEpoch + 1 else sh.groupEpoch) = _; rw [h.gEpoch] }

theorem Inv.reset (h : Inv C L fz X U W de ge nRes 0 false nNorm sh) (hb : L.buffers.length = 5) (garbage : Garbage)
    (g : Nat) : Inv C L fz X U W de ge nRes 0 false nNorm { sh with bytes := L.resetGroup garbage g sh.bytes } where
  regions := h.regions
  x := by show L.resetGroup garbage g sh.bytes 0 = X; rw [Launch.resetGroup_buffer L garbage g _ 0 (by omega)]; exact h.x
  upd := by
    show L.resetGroup garbage g sh.bytes 1 = U; rw [Launch.resetGroup_buffer L garbage g _ 1 (by omega)]; exact h.upd
  weight := by
    show L.resetGroup garbage g sh.bytes 2 = W; rw [Launch.resetGroup_buffer L garbage g _ 2 (by omega)]; exact h.weight
  dEpoch := h.dEpoch
  gEpoch := h.gEpoch
  res := by
    intro e he hs j hj
    show L.resetGroup garbage g sh.bytes 3 _ = _
    rw [Launch.resetGroup_buffer L garbage g _ 3 (by omega)]; exact h.res e he hs j hj
  sums := fun q hq => absurd hq (Nat.not_lt_zero q)
  inv := fun hf => absurd hf (by simp)
  norm := by
    intro e he hs j hj
    show L.resetGroup garbage g sh.bytes 4 _ = _
    rw [Launch.resetGroup_buffer L garbage g _ 4 (by omega)]; exact h.norm e he hs j hj
  log := h.log
end


/-! ## A thread -/

/-- Lane `i` of SIMD-group `s`: thread `32 s + i` of the one threadgroup. -/
structure Lane (ctx : Ctx) (s i : Nat) : Prop where
  row : ctx.coord .threadgroupPositionInGrid = u32x3 0 0 0
  tid : ctx.coord .threadPositionInThreadgroup = u32x3 (32 * s + i) 0 0
  lane : ctx.coord .threadIndexInSimdgroup = u32 i
  sg : ctx.coord .simdgroupIndexInThreadgroup = u32 s
  ga0 : ctx.groupArray 0 = 5
  ga1 : ctx.groupArray 1 = 6
  thread : ctx.thread = 32 * s + i
  group : ctx.group = 0
  hs : s < 32
  hi : i < 32

/-- The locals every phase reads and keeps (slots 0–10). -/
structure Locs (s i : Nat) (l : Locals) : Prop where
  x : l 0 = some (ptr 0)
  upd : l 1 = some (ptr 1)
  weight : l 2 = some (ptr 2)
  res : l 3 = some (ptr 3)
  norm : l 4 = some (ptr 4)
  row : l 5 = some (u32 0)
  tid : l 6 = some (u32 (32 * s + i))
  lane : l 7 = some (u32 i)
  sg : l 8 = some (u32 s)
  sums : l 9 = some (fptr 5)
  inv : l 10 = some (fptr 6)

theorem Locs.set {s i : Nat} {l : Locals} (h : Locs s i l) {slot : Nat} (v : Val) (hs : 10 < slot) :
    Locs s i (setLocal l slot v) :=
  ⟨by rw [setLocal_other _ _ (by omega)]; exact h.x, by rw [setLocal_other _ _ (by omega)]; exact h.upd,
   by rw [setLocal_other _ _ (by omega)]; exact h.weight, by rw [setLocal_other _ _ (by omega)]; exact h.res,
   by rw [setLocal_other _ _ (by omega)]; exact h.norm, by rw [setLocal_other _ _ (by omega)]; exact h.row,
   by rw [setLocal_other _ _ (by omega)]; exact h.tid, by rw [setLocal_other _ _ (by omega)]; exact h.lane,
   by rw [setLocal_other _ _ (by omega)]; exact h.sg, by rw [setLocal_other _ _ (by omega)]; exact h.sums,
   by rw [setLocal_other _ _ (by omega)]; exact h.inv⟩

/-! ### The first loop: `residual` and the sum of squares -/

def colR : CExpr := .bin .add .u32 0 (.bin .add .u32 0 (.local 12) (.bin .mul .u32 0 (.local 6) (u32l 4))) (.local 13)
def idxR : CExpr := .bin .add .u32 0 (.bin .mul .u32 0 (.local 5) (u32l 5120)) (.local 14)
def valR : CExpr :=
  .bin .add .bf16 0 (.load (.scalar .bf16) (.offset (.local 0) (.local 15)))
    (.load (.scalar .bf16) (.offset (.local 1) (.local 15)))
def accE : CExpr := .bin .add .f32 1 (.local 11) (.bin .mul .f32 0 (.local 17) (.local 17))

theorem addColBody_eq : addColBody = [.set 14 colR, .ite (.bin .lt .u32 0 (.local 14) (u32l 5120))
    [.set 15 idxR, .set 16 valR, .store (.scalar .bf16) (.offset (.local 3) (.local 15)) (.local 16),
     .set 17 (.conv .f32 (.local 16)), .set 11 accE] []] := rfl

/-- The column of step `4 j + k`: `r + tid * 4 + i`. -/
theorem eval_col {ctx : Ctx} {l : Locals} {s i j k : Nat} {ra ka : Nat} (hloc : Locs s i l)
    (hr : l ra = some (u32 (4096 * j))) (hk : l ka = some (u32 k)) (sh : Shared) :
    (eval C ctx l (.bin .add .u32 0 (.bin .add .u32 0 (.local ra) (.bin .mul .u32 0 (.local 6) (u32l 4)))
      (.local ka))).run sh = some (u32 (4096 * j + (32 * s + i) * 4 + k), sh) :=
  eval_int C (by decide) (eval_int C (by decide) (eval_local' C hr _)
    (eval_int C (by decide) (eval_local' C hloc.tid _) (eval_lit C _ _ _ _) (binary_mul_u32 C _ 4))
    (binary_add_u32 C _ _)) (eval_local' C hk _) (binary_add_u32 C _ k)

/-- The index `row * D + col` (row 0). -/
theorem eval_idx {ctx : Ctx} {l : Locals} {s i c ca : Nat} (hloc : Locs s i l) (hc : l ca = some (u32 c))
    (sh : Shared) :
    (eval C ctx l (.bin .add .u32 0 (.bin .mul .u32 0 (.local 5) (u32l 5120)) (.local ca))).run sh =
      some (u32 c, sh) := by
  have : (eval C ctx l (.bin .add .u32 0 (.bin .mul .u32 0 (.local 5) (u32l 5120)) (.local ca))).run sh =
      some (u32 (0 * 5120 + c), sh) :=
    eval_int C (by decide) (eval_int C (by decide) (eval_local' C hloc.row _) (eval_lit C _ _ _ _)
      (binary_mul_u32 C 0 5120)) (eval_local' C hc _) (binary_add_u32 C (0 * 5120) c)
  rwa [show 0 * 5120 + c = c by omega] at this

section
variable {C} {L : Launch} {ax au aw : Nat} {ctx : Ctx} {s i : Nat} {fz : Bool} {X U W : ByteMemory.Bytes}

/-- Step `4 j + k` of the first loop: the column, if below D, added, stored to `residual` and squared into `acc`. -/
theorem add_body (hS : Shape L ax au aw) (hl : Lane ctx s i) (hfz : ctx.fuse 1 = fz) (j k : Nat) (hj : j < 2)
    (hk : k < 4) (l : Locals) (sh : Shared) (hloc : Locs s i l) (h12 : l 12 = some (u32 (4096 * j)))
    (h13 : l 13 = some (u32 k)) (h11 : l 11 = some (.f32 (accR C fz X U (32 * s + i) (4 * j + k))))
    (hI : Inv C L fz X U W 0 0 (8 * (32 * s + i) + (4 * j + k)) 0 false 0 sh) :
    ∃ l₁ sh₁, Exec C ctx addColBody l sh .normal l₁ sh₁ ∧ Locs s i l₁ ∧ l₁ 12 = some (u32 (4096 * j)) ∧
      l₁ 13 = some (u32 k) ∧ l₁ 11 = some (.f32 (accR C fz X U (32 * s + i) (4 * j + k + 1))) ∧
      Inv C L fz X U W 0 0 (8 * (32 * s + i) + (4 * j + k) + 1) 0 false 0 sh₁ := by
  have hs := hl.hs; have hi := hl.hi
  obtain ⟨hcol, hin, hout⟩ := colOf_step (t := 32 * s + i) (j := j) (k := k) (by omega) hj hk
  have hc := eval_col C (ctx := ctx) hloc h12 h13 sh
  generalize hcdef : 4096 * j + (32 * s + i) * 4 + k = c at hc hcol hin hout
  have hl₁ : Locs s i (setLocal l 14 (u32 c)) := hloc.set _ (by omega)
  have hg : (eval C ctx (setLocal l 14 (u32 c)) (.bin .lt .u32 0 (.local 14) (u32l 5120))).run sh =
      some (.bool (decide (c < 5120)), sh) :=
    eval_int C (by decide) (eval_local' C (setLocal_same _ _ _) _) (eval_lit C _ _ _ _)
      (binary_lt_u32 C c 5120 (by omega) (by omega))
  by_cases hc5 : c < 5120
  · rw [decide_eq_true hc5] at hg
    obtain ⟨hseq, hown⟩ := hin hc5
    have hidx := eval_idx C (ctx := ctx) hl₁ (setLocal_same _ _ _) sh
    have hl₂ : Locs s i (setLocal (setLocal l 14 (u32 c)) 15 (u32 c)) := hl₁.set _ (by omega)
    have h15 : (setLocal (setLocal l 14 (u32 c)) 15 (u32 c)) 15 = some (u32 c) := setLocal_same _ _ _
    have hx := load_bf16 ctx sh 0 10240 ax c (by rw [hI.regions]; exact hS.r0) hS.ax (by omega)
    rw [hI.x] at hx
    have hI₁ := hI.read ctx 0 (2 * c) _ hS.r0 (by simp) (by decide) (by decide)
    have hu := load_bf16 ctx (rd ctx sh 0 (2 * c)) 1 10240 au c (by rw [hI₁.regions]; exact hS.r1) hS.au (by omega)
    rw [hI₁.upd] at hu
    have hI₂ := hI₁.read ctx 1 (2 * c) _ hS.r1 (by simp) (by decide) (by decide)
    have hv : (eval C ctx (setLocal (setLocal l 14 (u32 c)) 15 (u32 c)) valR).run sh =
        some (.bf16 (resv C X U c), rd ctx (rd ctx sh 0 (2 * c)) 1 (2 * c)) :=
      eval_bin_plain C (.inr ⟨rfl, rfl⟩) ((eval_load C _ _ _ _ _ _ _ (eval_index C hl₂.x h15 (by omega) _)).trans hx)
        ((eval_load C _ _ _ _ _ _ _ (eval_index C hl₂.upd h15 (by omega) _)).trans hu) rfl
    have hl₃ := hl₂.set (.bf16 (resv C X U c)) (slot := 16) (by omega)
    have hst := store_bf16 ctx (rd ctx (rd ctx sh 0 (2 * c)) 1 (2 * c)) 3 10240 16 c (resv C X U c)
      (by rw [hI₂.regions]; exact hS.r3) (by decide) (by omega)
    have hI₃ := hI₂.wrRes ctx c hc5 hseq (by rw [hl.thread, hown]) hl.group hS.r3
    have hacc : (eval C ctx (setLocal (setLocal (setLocal (setLocal l 14 (u32 c)) 15 (u32 c)) 16
        (.bf16 (resv C X U c))) 17 (.f32 (C.widen (resv C X U c)))) accE).run
          (wr ctx (rd ctx (rd ctx sh 0 (2 * c)) 1 (2 * c)) 3 (2 * c) (resv C X U c)) =
        some (.f32 (accR C fz X U (32 * s + i) (4 * j + k + 1)),
          wr ctx (rd ctx (rd ctx sh 0 (2 * c)) 1 (2 * c)) 3 (2 * c) (resv C X U c)) := by
      show (eval C ctx _ (.bin .add .f32 1 (.local 11) (.bin .mul .f32 0 (.local 17) (.local 17)))).run _ = _
      rw [eval_add_mul C rfl (eval_local' C (setLocal_same _ _ _) _) (eval_local' C (setLocal_same _ _ _) _)
        (eval_local' C (show _ = some (.f32 (accR C fz X U (32 * s + i) (4 * j + k))) by simp [setLocal, h11]) _)]
      simp only [accR, hcol, hc5, ite_true, hfz]
    refine ⟨setLocal (setLocal (setLocal (setLocal (setLocal l 14 (u32 c)) 15 (u32 c)) 16
        (.bf16 (resv C X U c))) 17 (.f32 (C.widen (resv C X U c)))) 11 (.f32 (accR C fz X U (32 * s + i) (4 * j + k + 1))),
      wr ctx (rd ctx (rd ctx sh 0 (2 * c)) 1 (2 * c)) 3 (2 * c) (resv C X U c), ?_,
      (hl₃.set _ (by omega)).set _ (by omega), by simp [setLocal, h12], by simp [setLocal, h13], by simp [setLocal], hI₃⟩
    rw [addColBody_eq]
    exact .set hc (.ite hg (.set hidx (.set hv (.store (eval_index C hl₃.res (by simp [setLocal]) (by omega) _)
      (eval_local' C (setLocal_same _ _ _) _) hst (.set (eval_conv C (eval_local' C (setLocal_same _ _ _) _) rfl)
        (.set hacc (.nil _ _)))))) (.nil _ _))
  · rw [decide_eq_false hc5] at hg
    refine ⟨_, _, ?_, hl₁, by simp [setLocal, h12], by simp [setLocal, h13], ?_,
      hI.skipRes (hout (by omega))⟩
    · rw [addColBody_eq]
      exact .set hc (.ite hg (.nil _ _) (.nil _ _))
    · rw [setLocal_other _ _ (by omega), h11]
      simp only [accR, hcol, hc5, ite_false]

end

/-- At the `k`-th test of the first loop's inner loop. -/
def AddI (L : Launch) (fz : Bool) (X U W : ByteMemory.Bytes) (s i j k : Nat) (l : Locals) (sh : Shared) : Prop :=
  Locs s i l ∧ l 12 = some (u32 (4096 * j)) ∧ l 13 = some (u32 k) ∧
    l 11 = some (.f32 (accR C fz X U (32 * s + i) (4 * j + k))) ∧
    Inv C L fz X U W 0 0 (8 * (32 * s + i) + (4 * j + k)) 0 false 0 sh

/-- At the `j`-th test of the first loop. -/
def AddO (L : Launch) (fz : Bool) (X U W : ByteMemory.Bytes) (s i j : Nat) (l : Locals) (sh : Shared) : Prop :=
  Locs s i l ∧ l 12 = some (u32 (4096 * j)) ∧ l 11 = some (.f32 (accR C fz X U (32 * s + i) (4 * j))) ∧
    Inv C L fz X U W 0 0 (8 * (32 * s + i) + 4 * j) 0 false 0 sh

section
variable {C} {L : Launch} {ax au aw : Nat} {ctx : Ctx} {s i : Nat} {fz : Bool} {X U W : ByteMemory.Bytes}

theorem add_loop (hS : Shape L ax au aw) (hl : Lane ctx s i) (hfz : ctx.fuse 1 = fz) (l : Locals) (sh : Shared)
    (hloc : Locs s i l) (h11 : l 11 = some (.f32 zero))
    (hI : Inv C L fz X U W 0 0 (8 * (32 * s + i)) 0 false 0 sh) :
    ∃ l' sh', Exec C ctx [.set 12 (u32l 0), .loop addRowCond addRowStep addRowBody] l sh .normal l' sh' ∧
      Locs s i l' ∧ l' 11 = some (.f32 (accR C fz X U (32 * s + i) 8)) ∧
      Inv C L fz X U W 0 0 (8 * (32 * s + i) + 8) 0 false 0 sh' := by
  have hinner : ∀ j < 2, ∀ l sh, AddI C L fz X U W s i j 0 l sh →
      ∃ l' sh', Exec C ctx [addColLoop] l sh .normal l' sh' ∧ AddI C L fz X U W s i j 4 l' sh' := by
    intro j hj l sh h0
    refine Exec.loop_count 4 (AddI C L fz X U W s i j) (AddI C L fz X U W s i j)
      (fun k hk l sh' hA => ⟨sh', ?_, hA⟩) (fun k hk l sh' hA => ?_) h0
    · exact eval_int C (by decide) (eval_local' C hA.2.2.1 _) (eval_lit C _ _ _ _)
        (binary_lt_u32 C k 4 (by omega) (by omega))
    · obtain ⟨hloc, h12, h13, h11, hI⟩ := hA
      obtain ⟨l₁, sh₁, hb, hl₁, h12', h13', h11', hI'⟩ := add_body hS hl hfz j k hj hk l sh' hloc h12 h13 h11 hI
      exact ⟨.normal, l₁, sh₁, _, _, .inl rfl, hb,
        .set (eval_int C (by decide) (eval_local' C h13' _) (eval_lit C _ _ _ _) (binary_add_u32 C k 1)) (.nil _ _),
        hl₁.set _ (by omega), by simp [setLocal, h12'], by simp [setLocal], by simpa [setLocal, Nat.add_assoc] using h11',
        by simpa [Nat.add_assoc] using hI'⟩
  have htest : ∀ j ≤ 2, ∀ l sh', AddO C L fz X U W s i j l sh' →
      ∃ sh₁, (eval C ctx l addRowCond).run sh' = some (.bool (decide (j < 2)), sh₁) ∧
        AddO C L fz X U W s i j l sh₁ := by
    intro j hj l sh' hO
    have h : (eval C ctx l addRowCond).run sh' = some (.bool (decide (4096 * j < 5120)), sh') :=
      eval_int C (by decide) (eval_local' C hO.2.1 _) (eval_lit C _ _ _ _)
        (binary_lt_u32 C (4096 * j) 5120 (by omega) (by omega))
    exact ⟨sh', by rw [h, show decide (4096 * j < 5120) = decide (j < 2) from decide_eq_decide.mpr (by omega)], hO⟩
  have hbody : ∀ j < 2, ∀ l sh', AddO C L fz X U W s i j l sh' → ∃ o l₁ sh₁ l₂ sh₂,
      (o = .normal ∨ o = .continue_) ∧ Exec C ctx addRowBody l sh' o l₁ sh₁ ∧
      Exec C ctx addRowStep l₁ sh₁ .normal l₂ sh₂ ∧ AddO C L fz X U W s i (j + 1) l₂ sh₂ := by
    intro j hj l sh' hO
    obtain ⟨hloc, h12, h11, hI⟩ := hO
    obtain ⟨l₁, sh₁, hin, hl₁, h12', _, h11', hI₁⟩ := hinner j hj (setLocal l 13 (.int .u32 0)) sh'
      ⟨hloc.set _ (by omega), by simpa [setLocal] using h12, by simp [setLocal, u32], by simpa [setLocal] using h11,
        by simpa using hI⟩
    refine ⟨.normal, l₁, _, _, _, .inl rfl, .set (eval_lit C _ _ _ _) hin,
      .set (eval_int C (by decide) (eval_local' C h12' _) (eval_lit C _ _ _ _) (binary_add_u32 C _ 4096)) (.nil _ _),
      hl₁.set _ (by omega), ?_, ?_, ?_⟩
    · rw [setLocal_same, show 4096 * j + 4096 = 4096 * (j + 1) by ring]
    · simpa [setLocal, show 4 * j + 4 = 4 * (j + 1) by ring] using h11'
    · simpa [show 8 * (32 * s + i) + (4 * j + 4) = 8 * (32 * s + i) + 4 * (j + 1) by ring] using hI₁
  obtain ⟨l', sh', hex, hl', -, h11', hI'⟩ := Exec.loop_count 2 (AddO C L fz X U W s i) (AddO C L fz X U W s i)
    htest hbody (l := setLocal l 12 (.int .u32 0)) (sh := sh)
    ⟨hloc.set _ (by omega), by simp [setLocal, u32], by simpa [setLocal, accR] using h11, by simpa using hI⟩
  exact ⟨l', sh', .set (eval_lit C _ _ _ _) hex, hl', h11', hI'⟩

end


/-! ### The second loop: `normalized` -/

def colN : CExpr := .bin .add .u32 0 (.bin .add .u32 0 (.local 20) (.bin .mul .u32 0 (.local 6) (u32l 4))) (.local 21)
def idxN : CExpr := .bin .add .u32 0 (.bin .mul .u32 0 (.local 5) (u32l 5120)) (.local 22)
def normV : CExpr :=
  .bin .mul .bf16 0 (.load (.scalar .bf16) (.offset (.local 2) (.local 22)))
    (.conv .bf16
      (.bin .mul .f32 0 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 3) (.local 23))))
        (.load (.scalar .f32) (.offset (.local 10) (i32l 0)))))

theorem normColBody_eq : normColBody = [.set 22 colN, .ite (.bin .lt .u32 0 (.local 22) (u32l 5120))
    [.set 23 idxN, .store (.scalar .bf16) (.offset (.local 4) (.local 23)) normV] []] := rfl

/-- `&inv[0]`. -/
theorem eval_inv0 {ctx : Ctx} {l : Locals} {s i : Nat} (hloc : Locs s i l) (sh : Shared) :
    (eval C ctx l (.offset (.local 10) (i32l 0))).run sh = some (.ptr ⟨6, ((4 * 0 : Nat) : Int), .scalar .f32⟩, sh) := by
  have := eval_offset_i32 C (o := 0) (n := 0) (eval_local' C (ctx := ctx) hloc.inv sh) (eval_lit C _ _ _ _) (by decide)
  rwa [show 0 + 0 * (Ty.scalar .f32).bytes = 4 * 0 from rfl] at this

section
variable {C} {L : Launch} {ax au aw : Nat} {ctx : Ctx} {s i : Nat} {fz : Bool} {X U W : ByteMemory.Bytes}

/-- Step `4 j + k` of the second loop: the column, if below D, normalized from its `residual` element. -/
theorem norm_body (hS : Shape L ax au aw) (hl : Lane ctx s i) (j k : Nat) (hj : j < 2) (hk : k < 4) (l : Locals)
    (sh : Shared) (hloc : Locs s i l) (h20 : l 20 = some (u32 (4096 * j))) (h21 : l 21 = some (u32 k))
    (hI : Inv C L fz X U W 1 3 8192 32 true (8 * (32 * s + i) + (4 * j + k)) sh) :
    ∃ l₁ sh₁, Exec C ctx normColBody l sh .normal l₁ sh₁ ∧ Locs s i l₁ ∧ l₁ 20 = some (u32 (4096 * j)) ∧
      l₁ 21 = some (u32 k) ∧ Inv C L fz X U W 1 3 8192 32 true (8 * (32 * s + i) + (4 * j + k) + 1) sh₁ := by
  have hs := hl.hs; have hi := hl.hi
  obtain ⟨-, hin, hout⟩ := colOf_step (t := 32 * s + i) (j := j) (k := k) (by omega) hj hk
  have hc := eval_col C (ctx := ctx) hloc h20 h21 sh
  generalize hcdef : 4096 * j + (32 * s + i) * 4 + k = c at hc hin hout
  have hl₁ : Locs s i (setLocal l 22 (u32 c)) := hloc.set _ (by omega)
  have hg : (eval C ctx (setLocal l 22 (u32 c)) (.bin .lt .u32 0 (.local 22) (u32l 5120))).run sh =
      some (.bool (decide (c < 5120)), sh) :=
    eval_int C (by decide) (eval_local' C (setLocal_same _ _ _) _) (eval_lit C _ _ _ _)
      (binary_lt_u32 C c 5120 (by omega) (by omega))
  by_cases hc5 : c < 5120
  · rw [decide_eq_true hc5] at hg
    obtain ⟨hseq, hown⟩ := hin hc5
    have hidx := eval_idx C (ctx := ctx) hl₁ (setLocal_same _ _ _) sh
    have hl₂ : Locs s i (setLocal (setLocal l 22 (u32 c)) 23 (u32 c)) := hl₁.set _ (by omega)
    have h22 : (setLocal (setLocal l 22 (u32 c)) 23 (u32 c)) 22 = some (u32 c) := by simp [setLocal]
    have h23 : (setLocal (setLocal l 22 (u32 c)) 23 (u32 c)) 23 = some (u32 c) := setLocal_same _ _ _
    have hw := load_bf16 ctx sh 2 10240 aw c (by rw [hI.regions]; exact hS.r2) hS.aw (by omega)
    rw [hI.weight] at hw
    have hI₁ := hI.read ctx 2 (2 * c) _ hS.r2 (by simp) (by decide) (by decide)
    have hr := load_bf16 ctx (rd ctx sh 2 (2 * c)) 3 10240 16 c (by rw [hI₁.regions]; exact hS.r3) (by decide) (by omega)
    rw [bfAt_of _ c (resv C X U c) (hI₁.res c hc5 (seqOf_lt hc5))] at hr
    have hI₂ := hI₁.readOwn ctx c (by rw [hl.thread, hown]) hS.r3
    have hv := load_f32_group ctx (rd ctx (rd ctx sh 2 (2 * c)) 3 (2 * c)) 6 4 0 (by rw [hI₂.regions]; exact hS.r6)
      (by omega)
    rw [f32At_of _ 0 (invR C fz X U) (fun b hb => by simpa using hI₂.inv rfl b hb)] at hv
    have hI₃ := hI₂.read4 ctx 6 (4 * 0) _ hS.r6 rfl (fun b _ => by rw [hl.group]; simp [tgo])
    have hN : (eval C ctx (setLocal (setLocal l 22 (u32 c)) 23 (u32 c)) normV).run sh =
        some (.bf16 (normR C fz X U W c), rd4 ctx (rd ctx (rd ctx sh 2 (2 * c)) 3 (2 * c)) 6 (4 * 0)) :=
      eval_bin_plain C (.inl ⟨by decide, by decide⟩)
        ((eval_load C _ _ _ _ _ _ _ (eval_index C hl₂.weight h22 (by omega) _)).trans hw)
        (eval_conv C (eval_f32 C (.inl ⟨by decide, by decide⟩)
          (eval_conv C ((eval_load C _ _ _ _ _ _ _ (eval_index C hl₂.res h23 (by omega) _)).trans hr) rfl)
          ((eval_load C _ _ _ _ _ _ _ (eval_inv0 C hl₂ _)).trans hv) rfl) rfl) rfl
    have hst := store_bf16 ctx (rd4 ctx (rd ctx (rd ctx sh 2 (2 * c)) 3 (2 * c)) 6 (4 * 0)) 4 10240 16 c
      (normR C fz X U W c) (by rw [hI₃.regions]; exact hS.r4) (by decide) (by omega)
    refine ⟨_, _, ?_, hl₂, by simp [setLocal, h20], by simp [setLocal, h21],
      hI₃.wrNorm ctx c hc5 hseq (by rw [hl.thread, hown]) hl.group hS.r4⟩
    rw [normColBody_eq]
    exact .set hc (.ite hg (.set hidx (.store (eval_index C hl₂.norm h23 (by omega) _) hN hst (.nil _ _))) (.nil _ _))
  · rw [decide_eq_false hc5] at hg
    refine ⟨_, _, ?_, hl₁, by simp [setLocal, h20], by simp [setLocal, h21], hI.skipNorm (hout (by omega))⟩
    rw [normColBody_eq]
    exact .set hc (.ite hg (.nil _ _) (.nil _ _))

end

/-- At the `k`-th test of the second loop's inner loop. -/
def NormI (L : Launch) (fz : Bool) (X U W : ByteMemory.Bytes) (s i j k : Nat) (l : Locals) (sh : Shared) : Prop :=
  Locs s i l ∧ l 20 = some (u32 (4096 * j)) ∧ l 21 = some (u32 k) ∧
    Inv C L fz X U W 1 3 8192 32 true (8 * (32 * s + i) + (4 * j + k)) sh

/-- At the `j`-th test of the second loop. -/
def NormO (L : Launch) (fz : Bool) (X U W : ByteMemory.Bytes) (s i j : Nat) (l : Locals) (sh : Shared) : Prop :=
  Locs s i l ∧ l 20 = some (u32 (4096 * j)) ∧ Inv C L fz X U W 1 3 8192 32 true (8 * (32 * s + i) + 4 * j) sh

/-- The code after the last barrier. -/
def rest4 : List CStmt := [.set 20 (u32l 0), .loop normRowCond normRowStep normRowBody]

section
variable {C} {L : Launch} {ax au aw : Nat} {ctx : Ctx} {s i : Nat} {fz : Bool} {X U W : ByteMemory.Bytes}

theorem norm_loop (hS : Shape L ax au aw) (hl : Lane ctx s i) (l : Locals) (sh : Shared) (hloc : Locs s i l)
    (hI : Inv C L fz X U W 1 3 8192 32 true (8 * (32 * s + i)) sh) :
    ∃ l' sh', Exec C ctx rest4 l sh .normal l' sh' ∧
      Inv C L fz X U W 1 3 8192 32 true (8 * (32 * s + i) + 8) sh' := by
  have hinner : ∀ j < 2, ∀ l sh, NormI C L fz X U W s i j 0 l sh →
      ∃ l' sh', Exec C ctx [normColLoop] l sh .normal l' sh' ∧ NormI C L fz X U W s i j 4 l' sh' := by
    intro j hj l sh h0
    refine Exec.loop_count 4 (NormI C L fz X U W s i j) (NormI C L fz X U W s i j)
      (fun k hk l sh' hA => ⟨sh', ?_, hA⟩) (fun k hk l sh' hA => ?_) h0
    · exact eval_int C (by decide) (eval_local' C hA.2.2.1 _) (eval_lit C _ _ _ _)
        (binary_lt_u32 C k 4 (by omega) (by omega))
    · obtain ⟨hloc, h20, h21, hI⟩ := hA
      obtain ⟨l₁, sh₁, hb, hl₁, h20', h21', hI'⟩ := norm_body hS hl j k hj hk l sh' hloc h20 h21 hI
      exact ⟨.normal, l₁, sh₁, _, _, .inl rfl, hb,
        .set (eval_int C (by decide) (eval_local' C h21' _) (eval_lit C _ _ _ _) (binary_add_u32 C k 1)) (.nil _ _),
        hl₁.set _ (by omega), by simp [setLocal, h20'], by simp [setLocal], by simpa [Nat.add_assoc] using hI'⟩
  have htest : ∀ j ≤ 2, ∀ l sh', NormO C L fz X U W s i j l sh' →
      ∃ sh₁, (eval C ctx l normRowCond).run sh' = some (.bool (decide (j < 2)), sh₁) ∧
        NormO C L fz X U W s i j l sh₁ := by
    intro j hj l sh' hO
    have h : (eval C ctx l normRowCond).run sh' = some (.bool (decide (4096 * j < 5120)), sh') :=
      eval_int C (by decide) (eval_local' C hO.2.1 _) (eval_lit C _ _ _ _)
        (binary_lt_u32 C (4096 * j) 5120 (by omega) (by omega))
    exact ⟨sh', by rw [h, show decide (4096 * j < 5120) = decide (j < 2) from decide_eq_decide.mpr (by omega)], hO⟩
  have hbody : ∀ j < 2, ∀ l sh', NormO C L fz X U W s i j l sh' → ∃ o l₁ sh₁ l₂ sh₂,
      (o = .normal ∨ o = .continue_) ∧ Exec C ctx normRowBody l sh' o l₁ sh₁ ∧
      Exec C ctx normRowStep l₁ sh₁ .normal l₂ sh₂ ∧ NormO C L fz X U W s i (j + 1) l₂ sh₂ := by
    intro j hj l sh' hO
    obtain ⟨hloc, h20, hI⟩ := hO
    obtain ⟨l₁, sh₁, hin, hl₁, h20', _, hI₁⟩ := hinner j hj (setLocal l 21 (.int .u32 0)) sh'
      ⟨hloc.set _ (by omega), by simpa [setLocal] using h20, by simp [setLocal, u32], by simpa using hI⟩
    refine ⟨.normal, l₁, _, _, _, .inl rfl, .set (eval_lit C _ _ _ _) hin,
      .set (eval_int C (by decide) (eval_local' C h20' _) (eval_lit C _ _ _ _) (binary_add_u32 C _ 4096)) (.nil _ _),
      hl₁.set _ (by omega), ?_, ?_⟩
    · rw [setLocal_same, show 4096 * j + 4096 = 4096 * (j + 1) by ring]
    · simpa [show 8 * (32 * s + i) + (4 * j + 4) = 8 * (32 * s + i) + 4 * (j + 1) by ring] using hI₁
  obtain ⟨l', sh', hex, -, -, hI'⟩ := Exec.loop_count 2 (NormO C L fz X U W s i) (NormO C L fz X U W s i)
    htest hbody (l := setLocal l 20 (.int .u32 0)) (sh := sh)
    ⟨hloc.set _ (by omega), by simp [setLocal, u32], by simpa using hI⟩
  exact ⟨l', sh', .set (eval_lit C _ _ _ _) hex, hI'⟩

end

/-! ### Between stops -/

def rest3 : List CStmt := [foldSums, .barrier 6 true true] ++ rest4
def rest2 : List CStmt := [publishSum, .barrier 4 false true] ++ rest3
def rest1 : List CStmt := [.set 11 (.local 18), clearSums, .barrier 3 false true] ++ rest2

theorem body_split : body = (body.take 11 ++ [.set 11 (f32l 0x0), .set 12 (u32l 0), .loop addRowCond addRowStep addRowBody]) ++
    .collective 2 18 .sum .f32 (.local 11) (u16l 0) :: rest1 := rfl

/-- The SIMD-group index test `sg == 0`. -/
theorem eval_sgIsZero {ctx : Ctx} {l : Locals} {s i : Nat} (hloc : Locs s i l) (hs : s < 32) (sh : Shared) :
    (eval C ctx l sgIsZero).run sh = some (.bool (decide (s = 0)), sh) :=
  eval_int C (by decide) (eval_local' C hloc.sg _) (eval_lit C _ _ _ _) (binary_eq_u32 C s 0 (by omega) (by omega))

/-- The lane test `lane == 0`. -/
theorem eval_laneIsZero {ctx : Ctx} {l : Locals} {s i : Nat} (hloc : Locs s i l) (hi : i < 32) (sh : Shared) :
    (eval C ctx l laneIsZero).run sh = some (.bool (decide (i = 0)), sh) :=
  eval_int C (by decide) (eval_local' C hloc.lane _) (eval_lit C _ _ _ _) (binary_eq_u32 C i 0 (by omega) (by omega))

section
variable {C} {L : Launch} {ax au aw : Nat} {ctx : Ctx} {s i : Nat} {fz : Bool} {X U W : ByteMemory.Bytes}

/-- A thread runs its declarations and the first loop to the first `simd_sum`. -/
theorem lane_start (hS : Shape L ax au aw) (hl : Lane ctx s i) (hfz : ctx.fuse 1 = fz) (sh : Shared)
    (hI : Inv C L fz X U W 0 0 (8 * (32 * s + i)) 0 false 0 sh) :
    ∃ l sh', (∃ n, ∀ m, n ≤ m → (runThread C m ⟨ctx, fun _ => none, [.block body], .running⟩).run sh =
      some (⟨ctx, l, [.block rest1], .collective 2 18 .sum .f32 (.f32 (accR C fz X U (32 * s + i) 8)) 0⟩, sh')) ∧
      Locs s i l ∧ Inv C L fz X U W 0 0 (8 * (32 * s + i) + 8) 0 false 0 sh' := by
  have hd : ∃ l0, Exec C ctx (body.take 11) (fun _ => none) sh .normal l0 sh ∧ Locs s i l0 :=
    ⟨_, .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <|
      .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_coord_x C hl.row _) <|
      .set (eval_coord_x C hl.tid _) <| .set (eval_coord C _ _ _ _) <| .set (eval_coord C _ _ _ _) <|
      .array <| .array <| .nil _ _,
      ⟨by simp [setLocal, ptr], by simp [setLocal, ptr], by simp [setLocal, ptr], by simp [setLocal, ptr],
        by simp [setLocal, ptr], by simp [setLocal], by simp [setLocal], by simp [setLocal, hl.lane],
        by simp [setLocal, hl.sg], by simp [setLocal, hl.ga0, fptr], by simp [setLocal, hl.ga1, fptr]⟩⟩
  obtain ⟨l0, hd, hl0⟩ := hd
  obtain ⟨l1, sh1, hex, hloc, h11, hI1⟩ := add_loop hS hl hfz (setLocal l0 11 (.f32 zero)) sh (hl0.set _ (by omega))
    (setLocal_same _ _ _) hI
  have hr := Exec.reaches_collective (K := []) (rest := rest1) (site := 2) (slot := 18) (op := .sum) (s := .f32)
    (d := u16l 0) (k := 0) (hd.append (.set (eval_lit C _ _ _ _) hex)) (eval_local' C h11 _) (eval_lit C _ _ _ _) rfl
  refine ⟨l1, sh1, ?_, hloc, hI1⟩
  rw [body_split]
  exact hr.run rfl

/-- After the first `simd_sum`: `acc` takes the sum and SIMD-group 0 clears `sums`, to the first barrier. -/
theorem lane_clear (hS : Shape L ax au aw) (hl : Lane ctx s i) (l : Locals) (hloc : Locs s i l) (v : Float32)
    (n : Nat) (sh : Shared) (hI : Inv C L fz X U W 0 0 n 0 false 0 sh) :
    ∃ l' sh', (∃ m0, ∀ m, m0 ≤ m → (runThread C m ⟨ctx, setLocal l 18 (.f32 v), [.block rest1], .running⟩).run sh =
      some (⟨ctx, l', [.block rest2], .barrier 3 false true⟩, sh')) ∧ Locs s i l' ∧ l' 11 = some (.f32 v) ∧
      Inv C L fz X U W 0 0 n 0 false 0 sh' := by
  have hl₁ : Locs s i (setLocal (setLocal l 18 (.f32 v)) 11 (.f32 v)) := (hloc.set _ (by omega)).set _ (by omega)
  have hpre : ∃ sh', Exec C ctx [.set 11 (.local 18), clearSums] (setLocal l 18 (.f32 v)) sh .normal
      (setLocal (setLocal l 18 (.f32 v)) 11 (.f32 v)) sh' ∧ Inv C L fz X U W 0 0 n 0 false 0 sh' := by
    have hz := eval_sgIsZero C (ctx := ctx) hl₁ hl.hs sh
    by_cases hs0 : s = 0
    · subst hs0
      have hst := store_f32_group ctx sh 5 128 i zero (by rw [hI.regions]; exact hS.r5) (by have := hl.hi; omega)
      refine ⟨_, .set (eval_local' C (setLocal_same _ _ _) _) (.ite hz (.store (eval_index4 C hl₁.sums hl₁.lane
        (by have := hl.hi; omega) _) (eval_lit C _ _ _ _) hst (.nil _ _)) (.nil _ _)),
        hI.clear ctx i (by rw [hl.thread]; omega) hS.r5 zero⟩
    · rw [decide_eq_false hs0] at hz
      exact ⟨sh, .set (eval_local' C (setLocal_same _ _ _) _) (.ite hz (.nil _ _) (.nil _ _)), hI⟩
  obtain ⟨sh', hex, hI'⟩ := hpre
  exact ⟨_, sh', (Exec.reaches_barrier (K := []) (rest := rest2) hex).run rfl, hl₁, by simp [setLocal], hI'⟩

/-- Lane 0 of each SIMD-group publishes its sum, to the second barrier. -/
theorem lane_publish (hS : Shape L ax au aw) (hl : Lane ctx s i) (l : Locals) (hloc : Locs s i l)
    (h11 : l 11 = some (.f32 (simdS C fz X U s))) (sh : Shared)
    (hI : Inv C L fz X U W 0 1 8192 (s + min i 1) false 0 sh) :
    ∃ sh', (∃ m0, ∀ m, m0 ≤ m → (runThread C m ⟨ctx, l, [.block rest2], .running⟩).run sh =
      some (⟨ctx, l, [.block rest3], .barrier 4 false true⟩, sh')) ∧
      Inv C L fz X U W 0 1 8192 (s + min (i + 1) 1) false 0 sh' := by
  have hpre : ∃ sh', Exec C ctx [publishSum] l sh .normal l sh' ∧
      Inv C L fz X U W 0 1 8192 (s + min (i + 1) 1) false 0 sh' := by
    have hz := eval_laneIsZero C (ctx := ctx) hloc hl.hi sh
    by_cases hi0 : i = 0
    · subst hi0
      have hst := store_f32_group ctx sh 5 128 s (simdS C fz X U s) (by rw [hI.regions]; exact hS.r5)
        (by have := hl.hs; omega)
      exact ⟨_, .ite hz (.store (eval_index4 C hloc.sums hloc.sg (by have := hl.hs; omega) _) (eval_local' C h11 _)
        hst (.nil _ _)) (.nil _ _), (show Inv C L fz X U W 0 1 8192 s false 0 sh by simpa using hI).publish ctx
          (by rw [hl.thread]; omega) hS.r5⟩
    · rw [decide_eq_false hi0] at hz
      exact ⟨sh, .ite hz (.nil _ _) (.nil _ _), by
        rw [show min (i + 1) 1 = min i 1 by omega]; exact hI⟩
  obtain ⟨sh', hex, hI'⟩ := hpre
  exact ⟨sh', (Exec.reaches_barrier (K := []) (rest := rest3) hex).run rfl, hI'⟩

/-- SIMD-groups other than 0 skip the fold, to the last barrier. -/
theorem lane_skip (hl : Lane ctx s i) (hs0 : s ≠ 0) (l : Locals) (hloc : Locs s i l) (sh : Shared) :
    ∃ m0, ∀ m, m0 ≤ m → (runThread C m ⟨ctx, l, [.block rest3], .running⟩).run sh =
      some (⟨ctx, l, [.block rest4], .barrier 6 true true⟩, sh) := by
  have hz := eval_sgIsZero C (ctx := ctx) hloc hl.hs sh
  rw [decide_eq_false hs0] at hz
  exact (Exec.reaches_barrier (K := []) (rest := rest4) (pre := [foldSums]) (.ite hz (.nil _ _) (.nil _ _))).run rfl

/-- SIMD-group 0 loads `sums[lane]`, to the second `simd_sum`. -/
theorem lane_fold (hS : Shape L ax au aw) (hl : Lane ctx 0 i) (l : Locals) (hloc : Locs 0 i l) (hv : Bool)
    (sh : Shared) (hI : Inv C L fz X U W 0 2 8192 32 hv 0 sh) :
    ∃ m0, ∀ m, m0 ≤ m → (runThread C m ⟨ctx, l, [.block rest3], .running⟩).run sh =
      some (⟨ctx, l, [.block [.set 11 (.local 19), invStore], .block (.barrier 6 true true :: rest4)],
        .collective 5 19 .sum .f32 (.f32 (simdS C fz X U i)) 0⟩, rd4 ctx sh 5 (4 * i)) := by
  have hi := hl.hi
  have hz := eval_sgIsZero C (ctx := ctx) hloc (by decide) sh
  rw [decide_eq_true rfl] at hz
  have hld := load_f32_group ctx sh 5 128 i (by rw [hI.regions]; exact hS.r5) (by omega)
  rw [f32At_of _ i (simdS C fz X U i) (hI.sums i (by omega))] at hld
  have hex : Exec C ctx rest3 l sh (.stop (.collective 5 19 .sum .f32 (.f32 (simdS C fz X U i)) 0)
      ([.block [.set 11 (.local 19), invStore]] ++ [.block (.barrier 6 true true :: rest4)])) l (rd4 ctx sh 5 (4 * i)) :=
    .ite_stop hz (.collective ((eval_load C _ _ _ _ _ _ _ (eval_index4 C hloc.sums hloc.lane (by omega) _)).trans hld)
      (eval_lit C _ _ _ _) rfl)
  exact (hex.reaches_stop (K := [])).run rfl

/-- SIMD-group 0 after the second `simd_sum`: lane 0 writes `inv[0]`, to the last barrier. -/
theorem lane_inv (hS : Shape L ax au aw) (hl : Lane ctx 0 i) (l : Locals) (hloc : Locs 0 i l) (sh : Shared)
    (hI : Inv C L fz X U W 0 2 8192 32 (decide (0 < i)) 0 sh) :
    ∃ l' sh', (∃ m0, ∀ m, m0 ≤ m → (runThread C m ⟨ctx, setLocal l 19 (.f32 (total C fz X U)),
      [.block [.set 11 (.local 19), invStore], .block (.barrier 6 true true :: rest4)], .running⟩).run sh =
      some (⟨ctx, l', [.block rest4], .barrier 6 true true⟩, sh')) ∧ Locs 0 i l' ∧
      Inv C L fz X U W 0 2 8192 32 (decide (0 < i + 1)) 0 sh' := by
  have hi := hl.hi
  have hl₁ : Locs 0 i (setLocal (setLocal l 19 (.f32 (total C fz X U))) 11 (.f32 (total C fz X U))) :=
    (hloc.set _ (by omega)).set _ (by omega)
  have hpre : ∃ sh', Exec C ctx [.set 11 (.local 19), invStore] (setLocal l 19 (.f32 (total C fz X U))) sh .normal
      (setLocal (setLocal l 19 (.f32 (total C fz X U))) 11 (.f32 (total C fz X U))) sh' ∧
      Inv C L fz X U W 0 2 8192 32 (decide (0 < i + 1)) 0 sh' := by
    have hz := eval_laneIsZero C (ctx := ctx) hl₁ hi sh
    by_cases hi0 : i = 0
    · subst hi0
      have hst := store_f32_group ctx sh 6 4 0 (invR C fz X U) (by rw [hI.regions]; exact hS.r6) (by omega)
      have hm : (eval C ctx (setLocal (setLocal l 19 (.f32 (total C fz X U))) 11 (.f32 (total C fz X U))) rsqrtMean).run
          sh = some (.f32 (invR C fz X U), sh) :=
        eval_un C (eval_f32 C (.inr ⟨rfl, rfl⟩) (eval_f32 C (.inl ⟨by decide, by decide⟩)
          (eval_local' C (setLocal_same _ _ _) _) (eval_lit C _ _ _ _) rfl) (eval_lit C _ _ _ _) rfl) rfl
      exact ⟨_, .set (eval_local' C (setLocal_same _ _ _) _) (.ite hz (.store (eval_inv0 C hl₁ _) hm hst (.nil _ _))
        (.nil _ _)), hI.writeInv ctx (by rw [hl.thread]) hS.r6⟩
    · rw [decide_eq_false hi0] at hz
      refine ⟨sh, .set (eval_local' C (setLocal_same _ _ _) _) (.ite hz (.nil _ _) (.nil _ _)), ?_⟩
      rw [show decide (0 < i + 1) = decide (0 < i) from decide_eq_decide.mpr (by omega)]
      exact hI
  obtain ⟨sh', hex, hI'⟩ := hpre
  exact ⟨_, sh', ((hex.reaches_normal (K := [.block (.barrier 6 true true :: rest4)])).trans
    ((Exec.barrier (C := C) (ctx := ctx) (site := 6) (d := true) (g := true) (ss := rest4)).reaches_stop (K := []))).run
      rfl, hl₁, hI'⟩

/-- After the last barrier: the second loop, to the end. -/
theorem lane_norm (hS : Shape L ax au aw) (hl : Lane ctx s i) (l : Locals) (hloc : Locs s i l) (sh : Shared)
    (hI : Inv C L fz X U W 1 3 8192 32 true (8 * (32 * s + i)) sh) :
    ∃ l' sh', (∃ m0, ∀ m, m0 ≤ m → (runThread C m ⟨ctx, l, [.block rest4], .running⟩).run sh =
      some (⟨ctx, l', [], .done⟩, sh')) ∧ Inv C L fz X U W 1 3 8192 32 true (8 * (32 * s + i) + 8) sh' := by
  obtain ⟨l', sh', hex, hI'⟩ := norm_loop hS hl l sh hloc hI
  exact ⟨l', sh', hex.reaches_done.run rfl, hI'⟩

end


/-! ## The launch -/

def inputs (X U W : ByteMemory.Bytes) (ax au aw : Nat) : List Buffer :=
  [⟨.device, 10240, ax, X⟩, ⟨.device, 10240, au, U⟩, ⟨.device, 10240, aw, W⟩]

/-- MLX's launch at `residualConfig`: grid [1024], threadgroup [1024], `x`, `update` [1, 1, 5120] bf16,
`weight` [5120] bf16, `residual` and `normalized` [1, 1, 5120] bf16. -/
def launch (X U W : ByteMemory.Bytes) (ax au aw : Nat) (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨core, (1024, 1, 1), (1024, 1, 1), buffers (inputs X U W ax au aw) [10240, 10240] 16 initial⟩

section
variable {X U W : ByteMemory.Bytes} {ax au aw : Nat} {initial : Nat → ByteMemory.Bytes}

theorem launch_tiles : (launch X U W ax au aw initial).Tiles 1024 1 1 1 1 1 32 := ⟨rfl, rfl, rfl, by decide⟩

theorem launch_shape (hax : ax % 2 = 0) (hau : au % 2 = 0) (haw : aw % 2 = 0) :
    Shape (launch X U W ax au aw initial) ax au aw :=
  ⟨regions_input (L := launch X U W ax au aw initial) rfl 0 (by simp [inputs]),
   regions_input (L := launch X U W ax au aw initial) rfl 1 (by simp [inputs]),
   regions_input (L := launch X U W ax au aw initial) rfl 2 (by simp [inputs]),
   regions_output (L := launch X U W ax au aw initial) rfl 0 (by simp),
   regions_output (L := launch X U W ax au aw initial) rfl 1 (by simp),
   Launch.regions_groupArray (launch X U W ax au aw initial) 0 (.scalar .f32) 32 rfl,
   Launch.regions_groupArray (launch X U W ax au aw initial) 1 (.scalar .f32) 1 rfl, hax, hau, haw⟩

theorem lane_of (fuse : Nat → Bool) (s i : Fin 32) :
    Lane ((launch X U W ax au aw initial).ctxAt fuse 0 0 0 (32 * s + i)) s i where
  row := Launch.ctxAt_threadgroupPositionInGrid _ _ _ _ _ _
  tid := by
    rw [launch_tiles.threadPositionInThreadgroup]
    have := s.isLt; have := i.isLt
    congr 1 <;> omega
  lane := Launch.ctxAt_lane _ _ _ _ _ _ _
  sg := Launch.ctxAt_simd _ _ _ _ _ _ _
  ga0 := (Launch.ctxAt_groupArray _ _ _ _ _ _ 0).trans rfl
  ga1 := (Launch.ctxAt_groupArray _ _ _ _ _ _ 1).trans rfl
  thread := by rw [launch_tiles.thread]; omega
  group := by rw [launch_tiles.group_id]
  hs := s.isLt
  hi := i.isLt
end

/-- Lane `i` of SIMD-group `s` at the first barrier, with its SIMD-group's sum in `acc`. -/
def AtClear (L : Launch) (fuse : Nat → Bool) (X U : ByteMemory.Bytes) (s : Nat) (i : Fin 32) (t : Thread) : Prop :=
  t.ctx = L.ctxAt fuse 0 0 0 (32 * s + i) ∧ t.frames = [.block rest2] ∧ Locs s i t.locals ∧
    t.locals 11 = some (.f32 (simdS C (fuse 1) X U s))

/-- Lane `i` of SIMD-group `s` at a barrier, before the code `F`. -/
def AtBarrier (L : Launch) (fuse : Nat → Bool) (F : List CStmt) (s : Nat) (i : Fin 32) (t : Thread) : Prop :=
  t.ctx = L.ctxAt fuse 0 0 0 (32 * s + i) ∧ t.frames = [.block F] ∧ Locs s i t.locals

section
variable {X U W : ByteMemory.Bytes} {ax au aw : Nat} {initial : Nat → ByteMemory.Bytes}

/-- To the first barrier: the first loop and `simd_sum`, then SIMD-group 0 clears `sums`. -/
theorem simd_phase1 (hS : Shape (launch X U W ax au aw initial) ax au aw) (fuse : Nat → Bool) (s : Fin 32)
    (sh : Shared) (hI : Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 0 (256 * s) 0 false 0 sh) :
    ∃ (f r : Nat) (V : Fin 32 → Thread) (sh' : Shared),
      (runSimd C f r (List.ofFn ((launch X U W ax au aw initial).lanes fuse 0 0 0 s))).run sh =
        some (List.ofFn V, sh') ∧
      Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 0 (256 * (s + 1)) 0 false 0 sh' ∧
      ∀ i, (V i).status = .barrier 3 false true ∧ AtClear C (launch X U W ax au aw initial) fuse X U s i (V i) := by
  refine simd_collective_bound C _ 2 18 .sum .f32 0 (fun i => .f32 (accR C (fuse 1) X U (32 * s + i) 8))
    (fun _ => .f32 (simdS C (fuse 1) X U s)) (resolve_sum C 0 _)
    (fun k sh => Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 0 (8 * (32 * s + k)) 0 false 0 sh)
    (fun i t => t.ctx = (launch X U W ax au aw initial).ctxAt fuse 0 0 0 (32 * s + i) ∧ t.frames = [.block rest1] ∧
      Locs s i t.locals)
    (fun sh => Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 0 (256 * (s + 1)) 0 false 0 sh)
    (fun i t => t.status = .barrier 3 false true ∧ AtClear C (launch X U W ax au aw initial) fuse X U s i t)
    (fun i sh hI => ?_) (fun V0 sh hV hI => ?_) sh (by rw [show 8 * (32 * (s : Nat) + 0) = 256 * s by ring]; exact hI)
  · obtain ⟨l, sh', ⟨n, hn⟩, hloc, hI'⟩ := lane_start hS (lane_of fuse s i) rfl sh hI
    exact ⟨n, _, sh', hn n le_rfl, by rw [show 8 * (32 * (s : Nat) + (i + 1)) = 8 * (32 * s + i) + 8 by ring]; exact hI',
      rfl, rfl, rfl, hloc⟩
  · have hlane : ∀ (i : Fin 32) (sh : Shared),
        Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 0 (256 * (s + 1)) 0 false 0 sh →
        ∃ f t sh', (runThread C f ({ V0 i with status := .running }.set 18 (.f32 (simdS C (fuse 1) X U s)))).run sh =
          some (t, sh') ∧ Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 0 (256 * (s + 1)) 0 false 0 sh' ∧
          blocked t.status = true ∧
          (t.status = .barrier 3 false true ∧ AtClear C (launch X U W ax au aw initial) fuse X U s i t) := by
      intro i sh hI
      obtain ⟨hc, hf, hloc⟩ := hV i
      rw [resume_eq (V0 i) _ _ hc hf]
      obtain ⟨l', sh', ⟨n, hn⟩, hl', h11, hI'⟩ := lane_clear hS (lane_of fuse s i) _ hloc (simdS C (fuse 1) X U s) _ sh hI
      exact ⟨n, _, sh', hn n le_rfl, hI', rfl, rfl, rfl, rfl, hl', h11⟩
    obtain ⟨f, r, V, sh', hr, hI', hV'⟩ := simd_blocked_bound C _
      (fun _ sh => Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 0 (256 * (s + 1)) 0 false 0 sh) _ hlane sh
      (by rw [show 256 * ((s : Nat) + 1) = 8 * (32 * s + 32) by ring]; exact hI)
    exact ⟨f, r, V, sh', hr, hI', hV'⟩

/-- To the second barrier: lane 0 of SIMD-group `s` publishes `sums[s]`. -/
theorem simd_phase2 (hS : Shape (launch X U W ax au aw initial) ax au aw) (fuse : Nat → Bool) (s : Fin 32)
    (V1 : Fin 32 → Thread) (hV : ∀ i, AtClear C (launch X U W ax au aw initial) fuse X U s i (V1 i)) (sh : Shared)
    (hI : Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 1 8192 s false 0 sh) :
    ∃ (f r : Nat) (V : Fin 32 → Thread) (sh' : Shared),
      (runSimd C f r (List.ofFn fun i => { V1 i with status := .running })).run sh = some (List.ofFn V, sh') ∧
      Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 1 8192 (s + 1) false 0 sh' ∧
      ∀ i, (V i).status = .barrier 4 false true ∧ AtBarrier (launch X U W ax au aw initial) fuse rest3 s i (V i) := by
  have hlane : ∀ (i : Fin 32) (sh : Shared),
      Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 1 8192 (s + min (i : Nat) 1) false 0 sh →
      ∃ f t sh', (runThread C f { V1 i with status := .running }).run sh = some (t, sh') ∧
        Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 1 8192 (s + min ((i : Nat) + 1) 1) false 0 sh' ∧
        blocked t.status = true ∧
        (t.status = .barrier 4 false true ∧ AtBarrier (launch X U W ax au aw initial) fuse rest3 s i t) := by
    intro i sh hI
    obtain ⟨hc, hf, hloc, h11⟩ := hV i
    rw [run_eq (V1 i) _ _ hc hf]
    obtain ⟨sh', ⟨n, hn⟩, hI'⟩ := lane_publish hS (lane_of fuse s i) _ hloc h11 sh hI
    exact ⟨n, _, sh', hn n le_rfl, hI', rfl, rfl, rfl, rfl, hloc⟩
  obtain ⟨f, r, V, sh', hr, hI', hV'⟩ := simd_blocked_bound C _
    (fun k sh => Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 1 8192 (s + min k 1) false 0 sh) _ hlane sh
    (by simpa using hI)
  exact ⟨f, r, V, sh', hr, by simpa using hI', hV'⟩

/-- To the last barrier: SIMD-group 0 folds `sums` and lane 0 writes `inv[0]`; the others pass. -/
theorem simd_phase3 (hS : Shape (launch X U W ax au aw initial) ax au aw) (fuse : Nat → Bool) (s : Fin 32)
    (V2 : Fin 32 → Thread) (hV : ∀ i, AtBarrier (launch X U W ax au aw initial) fuse rest3 s i (V2 i)) (sh : Shared)
    (hI : Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 2 8192 32 (decide (0 < (s : Nat))) 0 sh) :
    ∃ (f r : Nat) (V : Fin 32 → Thread) (sh' : Shared),
      (runSimd C f r (List.ofFn fun i => { V2 i with status := .running })).run sh = some (List.ofFn V, sh') ∧
      Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 2 8192 32 true 0 sh' ∧
      ∀ i, (V i).status = .barrier 6 true true ∧ AtBarrier (launch X U W ax au aw initial) fuse rest4 s i (V i) := by
  by_cases hs0 : (s : Nat) = 0
  · obtain rfl : s = 0 := Fin.ext hs0
    have hI0 : Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 2 8192 32 false 0 sh := by simpa using hI
    refine simd_collective_bound C _ 5 19 .sum .f32 0 (fun i => .f32 (simdS C (fuse 1) X U i))
      (fun _ => .f32 (total C (fuse 1) X U)) (resolve_sum C 0 _)
      (fun _ sh => Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 2 8192 32 false 0 sh)
      (fun i t => t.ctx = (launch X U W ax au aw initial).ctxAt fuse 0 0 0 (32 * 0 + i) ∧
        t.frames = [.block [.set 11 (.local 19), invStore], .block (.barrier 6 true true :: rest4)] ∧ Locs 0 i t.locals)
      (fun sh => Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 2 8192 32 true 0 sh)
      (fun i t => t.status = .barrier 6 true true ∧ AtBarrier (launch X U W ax au aw initial) fuse rest4 0 i t)
      (fun i sh hI => ?_) (fun V0 sh hV0 hI => ?_) sh hI0
    · obtain ⟨hc, hf, hloc⟩ := hV i
      rw [run_eq (V2 i) _ _ hc hf]
      obtain ⟨n, hn⟩ := lane_fold hS (lane_of fuse 0 i) _ hloc _ sh hI
      exact ⟨n, _, _, hn n le_rfl, hI.read4 _ 5 (4 * i) _ hS.r5 rfl (fun b _ => by simp [tgo]), rfl, rfl, rfl, hloc⟩
    · have hlane : ∀ (i : Fin 32) (sh : Shared),
          Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 2 8192 32 (decide (0 < (i : Nat))) 0 sh →
          ∃ f t sh', (runThread C f ({ V0 i with status := .running }.set 19 (.f32 (total C (fuse 1) X U)))).run sh =
            some (t, sh') ∧
            Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 2 8192 32 (decide (0 < (i : Nat) + 1)) 0 sh' ∧
            blocked t.status = true ∧
            (t.status = .barrier 6 true true ∧ AtBarrier (launch X U W ax au aw initial) fuse rest4 0 i t) := by
        intro i sh hI
        obtain ⟨hc, hf, hloc⟩ := hV0 i
        rw [resume_eq (V0 i) _ _ hc hf]
        obtain ⟨l', sh', ⟨n, hn⟩, hl', hI'⟩ := lane_inv hS (lane_of fuse 0 i) _ hloc sh hI
        exact ⟨n, _, sh', hn n le_rfl, hI', rfl, rfl, rfl, rfl, hl'⟩
      obtain ⟨f, r, V, sh', hr, hI', hV'⟩ := simd_blocked_bound C _
        (fun k sh => Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 2 8192 32 (decide (0 < k)) 0 sh) _ hlane sh
        (by simpa using hI)
      exact ⟨f, r, V, sh', hr, by simpa using hI', hV'⟩
  · have hI1 : Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 2 8192 32 true 0 sh := by
      have : decide (0 < (s : Nat)) = true := decide_eq_true (by omega)
      rwa [this] at hI
    have hlane : ∀ (i : Fin 32) (sh : Shared),
        Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 2 8192 32 true 0 sh →
        ∃ f t sh', (runThread C f { V2 i with status := .running }).run sh = some (t, sh') ∧
          Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 2 8192 32 true 0 sh' ∧ blocked t.status = true ∧
          (t.status = .barrier 6 true true ∧ AtBarrier (launch X U W ax au aw initial) fuse rest4 s i t) := by
      intro i sh hI
      obtain ⟨hc, hf, hloc⟩ := hV i
      rw [run_eq (V2 i) _ _ hc hf]
      obtain ⟨n, hn⟩ := lane_skip (C := C) (lane_of fuse s i) hs0 _ hloc sh
      exact ⟨n, _, sh, hn n le_rfl, hI, rfl, rfl, rfl, rfl, hloc⟩
    exact simd_blocked_bound C _ (fun _ sh => Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 2 8192 32 true 0 sh)
      _ hlane sh hI1

/-- To the end: the second loop. -/
theorem simd_phase4 (hS : Shape (launch X U W ax au aw initial) ax au aw) (fuse : Nat → Bool) (s : Fin 32)
    (V3 : Fin 32 → Thread) (hV : ∀ i, AtBarrier (launch X U W ax au aw initial) fuse rest4 s i (V3 i)) (sh : Shared)
    (hI : Inv C (launch X U W ax au aw initial) (fuse 1) X U W 1 3 8192 32 true (256 * s) sh) :
    ∃ (f r : Nat) (V : Fin 32 → Thread) (sh' : Shared),
      (runSimd C f r (List.ofFn fun i => { V3 i with status := .running })).run sh = some (List.ofFn V, sh') ∧
      Inv C (launch X U W ax au aw initial) (fuse 1) X U W 1 3 8192 32 true (256 * (s + 1)) sh' ∧
      ∀ i, (V i).status = .done := by
  have hlane : ∀ (i : Fin 32) (sh : Shared),
      Inv C (launch X U W ax au aw initial) (fuse 1) X U W 1 3 8192 32 true (8 * (32 * s + i)) sh →
      ∃ f t sh', (runThread C f { V3 i with status := .running }).run sh = some (t, sh') ∧
        Inv C (launch X U W ax au aw initial) (fuse 1) X U W 1 3 8192 32 true (8 * (32 * s + (i + 1))) sh' ∧
        blocked t.status = true ∧ t.status = .done := by
    intro i sh hI
    obtain ⟨hc, hf, hloc⟩ := hV i
    rw [run_eq (V3 i) _ _ hc hf]
    obtain ⟨l', sh', ⟨n, hn⟩, hI'⟩ := lane_norm hS (lane_of fuse s i) _ hloc sh hI
    exact ⟨n, _, sh', hn n le_rfl, by rw [show 8 * (32 * (s : Nat) + (i + 1)) = 8 * (32 * s + i) + 8 by ring]; exact hI',
      rfl, rfl⟩
  obtain ⟨f, r, V, sh', hr, hI', hV'⟩ := simd_blocked_bound C _
    (fun k sh => Inv C (launch X U W ax au aw initial) (fuse 1) X U W 1 3 8192 32 true (8 * (32 * s + k)) sh) _ hlane sh
    (by rw [show 8 * (32 * (s : Nat) + 0) = 256 * s by ring]; exact hI)
  exact ⟨f, r, V, sh', hr, by rw [show 256 * ((s : Nat) + 1) = 8 * (32 * s + 32) by ring]; exact hI', hV'⟩

/-- The threadgroup: four phases between its three barriers. -/
theorem group_run (hS : Shape (launch X U W ax au aw initial) ax au aw) (fuse : Nat → Bool) (sh : Shared)
    (hI : Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 0 0 0 false 0 sh) :
    ∃ f r b sh', (runGroup C f r b (List.ofFn fun s : Fin 32 =>
      List.ofFn ((launch X U W ax au aw initial).lanes fuse 0 0 0 s))).run sh = some ((), sh') ∧
      Inv C (launch X U W ax au aw initial) (fuse 1) X U W 1 3 8192 32 true 8192 sh' := by
  refine group_barrier_bound C (by decide) (fun s : Fin 32 => (launch X U W ax au aw initial).lanes fuse 0 0 0 s) 3
    false true (fun j sh => Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 0 (256 * j) 0 false 0 sh)
    (fun j i t => AtClear C (launch X U W ax au aw initial) fuse X U j i t)
    (fun sh => Inv C (launch X U W ax au aw initial) (fuse 1) X U W 1 3 8192 32 true 8192 sh)
    (fun j sh hj => simd_phase1 C hS fuse j sh hj) (fun V1 sh hV1 hI1 => ?_) sh (by simpa using hI)
  have hI2 : Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 1 8192 0 false 0 (pass false true sh) := by
    simpa using hI1.pass false true
  refine group_barrier_bound C (by decide) (fun s i => { V1 s i with status := .running }) 4 false true
    (fun j sh => Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 1 8192 j false 0 sh)
    (fun j i t => AtBarrier (launch X U W ax au aw initial) fuse rest3 j i t)
    (fun sh => Inv C (launch X U W ax au aw initial) (fuse 1) X U W 1 3 8192 32 true 8192 sh)
    (fun j sh hj => simd_phase2 C hS fuse j (V1 j) (fun i => hV1 j i) sh hj) (fun V2 sh hV2 hI2' => ?_) _ hI2
  have hI3 : Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 2 8192 32 false 0 (pass false true sh) := by
    simpa using hI2'.pass false true
  refine group_barrier_bound C (by decide) (fun s i => { V2 s i with status := .running }) 6 true true
    (fun j sh => Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 2 8192 32 (decide (0 < j)) 0 sh)
    (fun j i t => AtBarrier (launch X U W ax au aw initial) fuse rest4 j i t)
    (fun sh => Inv C (launch X U W ax au aw initial) (fuse 1) X U W 1 3 8192 32 true 8192 sh)
    (fun j sh hj => ?_) (fun V3 sh hV3 hI3' => ?_) _ (by simpa using hI3)
  · obtain ⟨f, r, V, sh', hr, hI', hV⟩ := simd_phase3 C hS fuse j (V2 j) (fun i => hV2 j i) sh hj
    exact ⟨f, r, V, sh', hr, by simpa using hI', hV⟩
  · have hI4 : Inv C (launch X U W ax au aw initial) (fuse 1) X U W 1 3 8192 32 true 0 (pass true true sh) := by
      simpa using hI3'.pass true true
    obtain ⟨f, r, b, sh', hr, hI'⟩ := group_done_bound C (fun s i => { V3 s i with status := .running })
      (fun j sh => Inv C (launch X U W ax au aw initial) (fuse 1) X U W 1 3 8192 32 true (256 * j) sh)
      (fun j sh hj => simd_phase4 C hS fuse j (V3 j) (fun i => hV3 j i) sh hj) _ (by simpa using hI4)
    exact ⟨f, r, b, sh', hr, by simpa using hI'⟩

/-- The launch: its one threadgroup. -/
theorem launch_inv (hS : Shape (launch X U W ax au aw initial) ax au aw) (fuse : Nat → Bool) (garbage : Garbage) :
    ∃ n sh, Inv C (launch X U W ax au aw initial) (fuse 1) X U W 1 3 8192 32 true 8192 sh ∧
      runLaunch C fuse (launch X U W ax au aw initial) garbage n n n = some ⟨sh.bytes, sh.log⟩ := by
  obtain ⟨n, sh, hI, hr⟩ := launch_bound C launch_tiles fuse garbage
    (fun G sh => if G = 0 then Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 0 0 0 false 0 sh
      else Inv C (launch X U W ax au aw initial) (fuse 1) X U W 1 3 8192 32 true 8192 sh)
    (by
      rw [ite_eq_left rfl]
      exact ⟨rfl, initial_input (L := launch X U W ax au aw initial) rfl garbage 0 (by simp [inputs]),
        initial_input (L := launch X U W ax au aw initial) rfl garbage 1 (by simp [inputs]),
        initial_input (L := launch X U W ax au aw initial) rfl garbage 2 (by simp [inputs]), rfl, rfl,
        fun _ _ h => absurd h (Nat.not_lt_zero _), fun q hq => absurd hq (Nat.not_lt_zero q),
        fun h => absurd h (by simp), fun _ _ h => absurd h (Nat.not_lt_zero _),
        fun a ha => by simp [Launch.initial] at ha⟩)
    (fun bx byy bz hx hy hz sh hI => by
      obtain rfl : bx = 0 := by omega
      obtain rfl : byy = 0 := by omega
      obtain rfl : bz = 0 := by omega
      have hI' : Inv C (launch X U W ax au aw initial) (fuse 1) X U W 0 0 0 0 false 0 sh := by simpa using hI
      obtain ⟨f, r, b, sh', hr, hI2⟩ := group_run C hS fuse _ (hI'.reset rfl garbage (0 + 0 * 1 + 0 * 1 * 1))
      exact ⟨f, r, b, sh', hr, by simpa using hI2⟩)
  exact ⟨n, sh, by simpa using hI, hr⟩
end

/-- **The GPU runs the residual RMS norm kernel as specified.** Under the GPU assumption, MLX's launch of the
exact assembled text at `residualConfig` on any `x`, `update` and `weight` buffers whose base addresses are
2-aligned (their bf16 element size) produces `residual` with every element `x + update` (bf16) and
`normalized` with every element `weight · T(residual · inv)`, `inv` the inverse root mean of the sums of
squares (with the compiler's contraction choice at `acc += v * v`) folded by `simd_sum` per SIMD-group and then
across the SIMD-groups through threadgroup memory. -/
theorem gpu_output (G : Gpu C) (hmax : 1024 ≤ G.maxThreads Metal.Elab.Tests.residualRmsNormText)
    (X U W : ByteMemory.Bytes) (ax au aw : Nat) (hax : 2 ∣ ax) (hau : 2 ∣ au) (haw : 2 ∣ aw) :
    G.execute Metal.Elab.Tests.residualRmsNormText (1024, 1, 1) (1024, 1, 1)
        [⟨.device, 10240, ax, X⟩, ⟨.device, 10240, au, U⟩, ⟨.device, 10240, aw, W⟩] [10240, 10240] =
      some [expectedResidual C X U, expectedNormalized C (G.fusion Metal.Elab.Tests.residualRmsNormText) X U W] := by
  have h := gpu_owned C G (grid := (1024, 1, 1)) (tg := (1024, 1, 1))
    (inputs := [⟨.device, 10240, ax, X⟩, ⟨.device, 10240, au, U⟩, ⟨.device, 10240, aw, W⟩]) (sizes := [10240, 10240])
    (fun i => if i = 0 then expectedResidual C X U
      else expectedNormalized C (G.fusion Metal.Elab.Tests.residualRmsNormText) X U W) compile_eq
    (by simpa using hmax) (fun initial garbage => by
      obtain ⟨n, sh, hI, hr⟩ := launch_inv C (initial := initial)
        (launch_shape (X := X) (U := U) (W := W) (ax := ax) (au := au) (aw := aw) (initial := initial) (by omega)
          (by omega) (by omega)) (G.fusion Metal.Elab.Tests.residualRmsNormText) garbage
      refine ⟨n, n, n, sh, dev, tgo, hr, hI.log, ?_⟩
      intro i hi b hb
      have hi2 : i = 0 ∨ i = 1 := by simp at hi; omega
      have hb' : b < 10240 := by rcases hi2 with rfl | rfl <;> simpa using hb
      have hres := hI.res (b / 2) (by omega) (seqOf_lt (by omega)) (b % 2) (by omega)
      have hnorm := hI.norm (b / 2) (by omega) (seqOf_lt (by omega)) (b % 2) (by omega)
      rw [show 2 * (b / 2) + b % 2 = b by omega] at hres hnorm
      rcases hi2 with rfl | rfl
      · show sh.bytes 3 b = expectedResidual C X U b
        unfold expectedResidual; rw [ite_eq_left hb', hres]
      · show sh.bytes 4 b = expectedNormalized C _ X U W b
        unfold expectedNormalized; rw [ite_eq_left hb', hnorm])
  rw [h]
  show some [fun b => if b < 10240 then expectedResidual C X U b else 0,
    fun b => if b < 10240 then expectedNormalized C _ X U W b else 0] = _
  congr 2
  · funext b; unfold expectedResidual; split <;> simp_all
  · congr 1; funext b; unfold expectedNormalized; split <;> simp_all

end Metal.Kernels.ResidualRmsNorm

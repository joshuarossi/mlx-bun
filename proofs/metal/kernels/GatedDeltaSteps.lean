import metal.kernels.GatedDeltaStep

namespace Metal.Kernels.GatedDeltaSteps
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.GatedDeltaStep

/-! # gated.ts gated_delta_step over `T` time steps

The prefill launches the same text (`Metal.Elab.Tests.gatedDeltaStepText`, elaborated to
`GatedDeltaStep.core`, `compile_eq`) on chunks of `T` positions: `T` arrives as the int32 in `Tin`, so
the assembled text does not depend on it; only the buffers' sizes do (q, k [1, T, 16, 128] bf16; v, y
[1, T, 48, 128] bf16; g [1, T, 48] f32; beta [1, T, 48] bf16; state_in, state_out [1, 48, 128, 128] f32).
Each thread runs the time loop `for (int t = 0; t < T; ++t)`, carrying `state[]` across steps and
advancing `q_`, `k_` by `Hk * Dk = 2048` elements, `v_`, `y` by `Hv * Dv = 6144`, `g_`, `beta_` by
`Hv = 48`. Step `t` is the one-step kernel (`GatedDeltaStep`'s `yOut`, `stateOut`) on the `t`-th slices of
the inputs and the previous step's state (`stepAt`).

The integer arithmetic bounds `T`: it is an `int` compared with the `int` counter `t` and incremented to
`T`, and converted to `uint` in `b_idx * T * …`, so it must be non-negative and `T ≤ 2^31 - 1` (a `Tin`
word at or above `2^31` is a negative `int`: the loop would not run and `y` would stay unwritten). All
other index expressions (`s_idx`, `n * Dv + dv_idx`, …) do not depend on `T`, and the pointer
arithmetic is unbounded. -/

section Bytes

theorem f32At_bytes4 {N : Nat} (f : Nat → Float32) {j : Nat} (hj : 4 * j + 4 ≤ N) : f32At (bytes4 N f) j = f j :=
  f32At_of _ j _ fun i hi => by
    unfold bytes4
    rw [ite_eq_left (by omega), show (4 * j + i) / 4 = j by omega, show (4 * j + i) % 4 = i by omega]

end Bytes

/-! ## What the kernel computes -/

section Spec
variable (C : M1Max.Contract) (fuse : Nat → Bool) (I : Ins)

/-- Time step `t`'s inputs: the `t`-th slices of `q`, `k` ([T, 16, 128] bf16: 4096 bytes a step), `v`
([T, 48, 128] bf16: 12288), `g` ([T, 48] f32: 192) and `beta` ([T, 48] bf16: 96), and the state `S`. -/
def stepIns (S : ByteMemory.Bytes) (t : Nat) : Ins :=
  ⟨fun b => I.q (4096 * t + b), fun b => I.k (4096 * t + b), fun b => I.v (12288 * t + b),
    fun b => I.g (192 * t + b), fun b => I.beta (96 * t + b), S, I.t⟩

/-- The state before time step `t`: `state_in`'s bytes, then each step's `state_out` encoded. -/
def stateBytes : Nat → ByteMemory.Bytes
  | 0 => I.state
  | t + 1 => bytes4 3145728 (stateOut C fuse (stepIns I (stateBytes t) t))

/-- Time step `t`: its slices of the inputs and the state before it. -/
def stepAt (t : Nat) : Ins := stepIns I (stateBytes C fuse I t) t

/-- `y` element `e` (time step `e / 6144`, head `e % 6144 / 128`, row `e % 128`): that step's `yOut`. The
`state_out` elements are the last step's `stateOut`. -/
def ySteps (e : Nat) : BF := yOut C fuse (stepAt C fuse I (e / 6144)) (e % 6144)

end Spec

section Slices
variable (C : M1Max.Contract) (fuse : Nat → Bool) (I : Ins)

theorem stepAt_zero : stepAt C fuse I 0 = I := by
  cases I; simp [stepAt, stepIns, stateBytes]

/-- What the kernel reads at time step `t` (through the advanced pointers) is `J`'s one-step input. -/
structure Slice (J : Ins) (t : Nat) : Prop where
  key : ∀ n c, C.widen (bfAt I.k (2048 * t + n / 3 * 128 + c)) = keyAt C J n c
  query : ∀ n c, C.widen (bfAt I.q (2048 * t + n / 3 * 128 + c)) = queryAt C J n c
  value : ∀ n r, bfAt I.v (6144 * t + n * 128 + r) = bfAt J.v (n * 128 + r)
  decay : ∀ n, f32At I.g (48 * t + n) = f32At J.g n
  beta : ∀ n, bfAt I.beta (48 * t + n) = bfAt J.beta n

theorem slice_step (S : ByteMemory.Bytes) (t : Nat) : Slice C I (stepIns I S t) t where
  key n c := by
    show _ = C.widen (bfAt (fun b => I.k (4096 * t + b)) (n / 3 * 128 + c))
    rw [bfAt_shift _ _ (show 4096 * t = 2 * (2048 * t) by ring), Nat.add_assoc]
  query n c := by
    show _ = C.widen (bfAt (fun b => I.q (4096 * t + b)) (n / 3 * 128 + c))
    rw [bfAt_shift _ _ (show 4096 * t = 2 * (2048 * t) by ring), Nat.add_assoc]
  value n r := by
    show _ = bfAt (fun b => I.v (12288 * t + b)) (n * 128 + r)
    rw [bfAt_shift _ _ (show 12288 * t = 2 * (6144 * t) by ring), Nat.add_assoc]
  decay n := by
    show _ = f32At (fun b => I.g (192 * t + b)) n
    rw [f32At_shift _ _ (show 192 * t = 4 * (48 * t) by ring)]
  beta n := by
    show _ = bfAt (fun b => I.beta (96 * t + b)) n
    rw [bfAt_shift _ _ (show 96 * t = 2 * (48 * t) by ring)]

theorem slice_at (t : Nat) : Slice C I (stepAt C fuse I t) t := slice_step C I _ t

/-- The state before step `t + 1` is step `t`'s updated state. -/
theorem stateIn_succ {n r c : Nat} (t : Nat) (hn : n < 48) (hr : r < 128) (hc : c < 128) :
    stateIn (stepAt C fuse I (t + 1)) n r c = updated C fuse (stepAt C fuse I t) n r c := by
  show f32At (bytes4 3145728 (stateOut C fuse (stepAt C fuse I t))) ((n * 128 + r) * 128 + c) = _
  rw [f32At_bytes4 _ (by omega)]
  unfold stateOut
  rw [show ((n * 128 + r) * 128 + c) / 128 / 128 = n by omega, show ((n * 128 + r) * 128 + c) / 128 % 128 = r by omega,
    show ((n * 128 + r) * 128 + c) % 128 = c by omega]

/-- The state before step 0 is `state_in`'s. -/
theorem stateIn_zero (n r c : Nat) : stateIn (stepAt C fuse I 0) n r c = stateIn I n r c := rfl

end Slices


/-! ## A thread -/

/-- Four bytes holding the int32 `T`, little-endian. -/
def TWord (t : ByteMemory.Bytes) (T : Nat) : Prop :=
  t 0 = BitVec.ofNat 8 T ∧ t 1 = BitVec.ofNat 8 (T / 2 ^ 8) ∧ t 2 = BitVec.ofNat 8 (T / 2 ^ 16) ∧
    t 3 = BitVec.ofNat 8 (T / 2 ^ 24)

/-- The regions a thread accesses, for `T` time steps. -/
structure RegsT (T : Nat) (ctx : Ctx) (A : Al) (R : Nat → Option Region) : Prop where
  q : R 0 = some ⟨.device, 4096 * T, A.q⟩
  k : R 1 = some ⟨.device, 4096 * T, A.k⟩
  v : R 2 = some ⟨.device, 12288 * T, A.v⟩
  g : R 3 = some ⟨.device, 192 * T, A.g⟩
  beta : R 4 = some ⟨.device, 96 * T, A.beta⟩
  state : R 5 = some ⟨.device, 3145728, A.state⟩
  t : R 6 = some ⟨.constant, 4, A.t⟩
  y : R 7 = some ⟨.device, 12288 * T, 16⟩
  so : R 8 = some ⟨.device, 3145728, 16⟩
  arr : R (ctx.threadArray 0) = some ⟨.thread, 16, 4⟩
  a9 : 9 ≤ ctx.threadArray 0
  al : A.Ok

/-- The locals the code reads after its declarations. -/
structure PreA (ctx : Ctx) (T n r d : Nat) (L : Locals) : Prop where
  g : L 3 = some (.ptr ⟨3, 0, .scalar .f32⟩)
  beta : L 4 = some (.ptr ⟨4, 0, .scalar .bf16⟩)
  y : L 7 = some (.ptr ⟨7, ((2 * (n * 128) : Nat) : Int), .scalar .bf16⟩)
  T : L 9 = some (.int .i32 T)
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

theorem PreA.set {ctx : Ctx} {T n r d : Nat} {L : Locals} (hp : PreA ctx T n r d L) {slot : Nat} (v : Val)
    (hs : 22 ≤ slot) : PreA ctx T n r d (setLocal L slot v) :=
  ⟨(setLocal_other L v (by omega)).trans hp.g, (setLocal_other L v (by omega)).trans hp.beta,
    (setLocal_other L v (by omega)).trans hp.y, (setLocal_other L v (by omega)).trans hp.T,
    (setLocal_other L v (by omega)).trans hp.b, (setLocal_other L v (by omega)).trans hp.hv,
    (setLocal_other L v (by omega)).trans hp.q, (setLocal_other L v (by omega)).trans hp.k,
    (setLocal_other L v (by omega)).trans hp.v, (setLocal_other L v (by omega)).trans hp.dk,
    (setLocal_other L v (by omega)).trans hp.dv, (setLocal_other L v (by omega)).trans hp.si,
    (setLocal_other L v (by omega)).trans hp.so, (setLocal_other L v (by omega)).trans hp.arr⟩

/-- The locals the time loop reads at step `t`: the data pointers advanced `t` times. -/
structure PreT (ctx : Ctx) (T n r d t : Nat) (L : Locals) : Prop where
  y : L 7 = some (.ptr ⟨7, ((2 * (6144 * t + n * 128) : Nat) : Int), .scalar .bf16⟩)
  T : L 9 = some (.int .i32 T)
  hv : L 12 = some (u32 n)
  q : L 14 = some (.ptr ⟨0, ((2 * (2048 * t + n / 3 * 128) : Nat) : Int), .scalar .bf16⟩)
  k : L 15 = some (.ptr ⟨1, ((2 * (2048 * t + n / 3 * 128) : Nat) : Int), .scalar .bf16⟩)
  v : L 16 = some (.ptr ⟨2, ((2 * (6144 * t + n * 128) : Nat) : Int), .scalar .bf16⟩)
  dk : L 17 = some (u32 d)
  dv : L 18 = some (u32 r)
  so : L 20 = some (.ptr ⟨8, ((4 * ((n * 128 + r) * 128) : Nat) : Int), .scalar .f32⟩)
  arr : L 21 = some (.ptr ⟨ctx.threadArray 0, 0, .scalar .f32⟩)
  g : L 24 = some (.ptr ⟨3, ((4 * (48 * t) : Nat) : Int), .scalar .f32⟩)
  beta : L 25 = some (.ptr ⟨4, ((2 * (48 * t) : Nat) : Int), .scalar .bf16⟩)
  t : L 26 = some (.int .i32 t)

theorem PreT.set {ctx : Ctx} {T n r d t : Nat} {L : Locals} (hp : PreT ctx T n r d t L) {slot : Nat} (v : Val)
    (hs : 27 ≤ slot) : PreT ctx T n r d t (setLocal L slot v) :=
  ⟨(setLocal_other L v (by omega)).trans hp.y, (setLocal_other L v (by omega)).trans hp.T,
    (setLocal_other L v (by omega)).trans hp.hv, (setLocal_other L v (by omega)).trans hp.q,
    (setLocal_other L v (by omega)).trans hp.k, (setLocal_other L v (by omega)).trans hp.v,
    (setLocal_other L v (by omega)).trans hp.dk, (setLocal_other L v (by omega)).trans hp.dv,
    (setLocal_other L v (by omega)).trans hp.so, (setLocal_other L v (by omega)).trans hp.arr,
    (setLocal_other L v (by omega)).trans hp.g, (setLocal_other L v (by omega)).trans hp.beta,
    (setLocal_other L v (by omega)).trans hp.t⟩

/-! ### Expressions -/

section Eval
variable (C : M1Max.Contract) {ctx : Ctx} {L : Locals} {sh : Shared} {T : Nat}

/-- `b_idx * T` with `b_idx = 0`. -/
theorem eval_bT (h11 : L 11 = some (u32 0)) (h9 : L 9 = some (.int .i32 T)) (hT : T < 2 ^ 31) :
    (eval C ctx L (.bin .mul .u32 0 (.local 11) (.conv .u32 (.local 9)))).run sh = some (u32 0, sh) := by
  have : (eval C ctx L (.bin .mul .u32 0 (.local 11) (.conv .u32 (.local 9)))).run sh = some (u32 (0 * T), sh) :=
    eval_int C (by decide) (eval_local C ctx L 11 _ h11 sh)
      (eval_conv C (eval_local C ctx L 9 _ h9 sh) (convert_u32_i32 C T hT)) (binary_mul_u32 C 0 T)
  rwa [Nat.zero_mul] at this

theorem eval_qkBatchT (h11 : L 11 = some (u32 0)) (h9 : L 9 = some (.int .i32 T)) (hT : T < 2 ^ 31) :
    (eval C ctx L qkBatch).run sh = some (u32 0, sh) :=
  eval_int C (by decide) (eval_int C (by decide) (eval_bT C h11 h9 hT) (eval_lit C _ _ _ _)
    (binary_mul_u32 C 0 16)) (eval_lit C _ _ _ _) (binary_mul_u32 C (0 * 16) 128)

theorem eval_gBatchT (h11 : L 11 = some (u32 0)) (h9 : L 9 = some (.int .i32 T)) (hT : T < 2 ^ 31) :
    (eval C ctx L gBatch).run sh = some (u32 0, sh) :=
  eval_int C (by decide) (eval_bT C h11 h9 hT) (eval_lit C _ _ _ _) (binary_mul_u32 C 0 48)

theorem eval_vBatchT (h11 : L 11 = some (u32 0)) (h9 : L 9 = some (.int .i32 T)) (hT : T < 2 ^ 31) :
    (eval C ctx L vBatch).run sh = some (u32 0, sh) :=
  eval_int C (by decide) (eval_gBatchT C h11 h9 hT) (eval_lit C _ _ _ _) (binary_mul_u32 C 0 128)

theorem eval_kqT {P region hk : Nat} (hP : L P = some (.ptr ⟨region, 0, .scalar .bf16⟩)) (h11 : L 11 = some (u32 0))
    (h9 : L 9 = some (.int .i32 T)) (hT : T < 2 ^ 31) (h13 : L 13 = some (u32 hk)) (hhk : hk < 16) :
    (eval C ctx L (.offset (.offset (.local P) qkBatch) (.bin .mul .u32 0 (.local 13) (u32l 128)))).run sh =
      some (.ptr ⟨region, ((2 * (hk * 128) : Nat) : Int), .scalar .bf16⟩, sh) := by
  have := eval_bf16 C (a := 0 + 0) (eval_bf16 C (a := 0) (eval_local C ctx L P _ hP sh) (eval_qkBatchT C h11 h9 hT)
    (by decide)) (eval_int C (by decide) (eval_local C ctx L 13 _ h13 sh) (eval_lit C _ _ _ _)
      (binary_mul_u32 C hk 128) : (eval C ctx L (.bin .mul .u32 0 (.local 13) (u32l 128))).run sh =
        some (u32 (hk * 128), sh)) (by omega)
  rwa [show 0 + 0 + hk * 128 = hk * 128 by omega] at this

theorem eval_vptrT {n : Nat} (h2 : L 2 = some (.ptr ⟨2, 0, .scalar .bf16⟩)) (h11 : L 11 = some (u32 0))
    (h9 : L 9 = some (.int .i32 T)) (hT : T < 2 ^ 31) (h12 : L 12 = some (u32 n)) (hn : n < 48) :
    (eval C ctx L (.offset (.offset (.local 2) vBatch) (.bin .mul .u32 0 (.local 12) (u32l 128)))).run sh =
      some (.ptr ⟨2, ((2 * (n * 128) : Nat) : Int), .scalar .bf16⟩, sh) := by
  have := eval_bf16 C (a := 0 + 0) (eval_bf16 C (a := 0) (eval_local C ctx L 2 _ h2 sh) (eval_vBatchT C h11 h9 hT)
    (by decide)) (eval_int C (by decide) (eval_local C ctx L 12 _ h12 sh) (eval_lit C _ _ _ _)
      (binary_mul_u32 C n 128) : (eval C ctx L (.bin .mul .u32 0 (.local 12) (u32l 128))).run sh =
        some (u32 (n * 128), sh)) (by omega)
  rwa [show 0 + 0 + n * 128 = n * 128 by omega] at this

theorem eval_yptrT {n : Nat} (h7 : L 7 = some (.ptr ⟨7, 0, .scalar .bf16⟩)) (h11 : L 11 = some (u32 0))
    (h9 : L 9 = some (.int .i32 T)) (hT : T < 2 ^ 31) (h12 : L 12 = some (u32 n)) (hn : n < 48) :
    (eval C ctx L (.offset (.local 7) (.bin .add .u32 0 vBatch (.bin .mul .u32 0 (.local 12) (u32l 128))))).run sh =
      some (.ptr ⟨7, ((2 * (n * 128) : Nat) : Int), .scalar .bf16⟩, sh) := by
  have := eval_bf16 C (a := 0) (eval_local C ctx L 7 _ h7 sh) (eval_int C (by decide) (eval_vBatchT C h11 h9 hT)
    (eval_int C (by decide) (eval_local C ctx L 12 _ h12 sh) (eval_lit C _ _ _ _) (binary_mul_u32 C n 128))
    (binary_add_u32 C 0 (n * 128)) : (eval C ctx L (.bin .add .u32 0 vBatch
      (.bin .mul .u32 0 (.local 12) (u32l 128)))).run sh = some (u32 (0 + n * 128), sh)) (by omega)
  rwa [show 0 + (0 + n * 128) = n * 128 by omega] at this

/-- A bf16 data pointer advanced by an `int` literal (`q_ += Hk * Dk`, …). -/
theorem eval_adv2 {p region a m : Nat}
    (hp : L p = some (.ptr ⟨region, ((2 * a : Nat) : Int), .scalar .bf16⟩)) (hm : m < 2 ^ 31) :
    (eval C ctx L (.offset (.local p) (i32l m))).run sh =
      some (.ptr ⟨region, ((2 * (a + m) : Nat) : Int), .scalar .bf16⟩, sh) := by
  have := eval_offset_i32 C (eval_local C ctx L p _ hp sh) (eval_lit C _ _ _ _) hm
  rwa [show 2 * a + m * (Ty.scalar .bf16).bytes = 2 * (a + m) by simp [Ty.bytes, Scalar.bytes]; ring] at this

/-- A binary32 data pointer advanced by an `int` literal (`g_ += Hv`). -/
theorem eval_adv4 {p region a m : Nat}
    (hp : L p = some (.ptr ⟨region, ((4 * a : Nat) : Int), .scalar .f32⟩)) (hm : m < 2 ^ 31) :
    (eval C ctx L (.offset (.local p) (i32l m))).run sh =
      some (.ptr ⟨region, ((4 * (a + m) : Nat) : Int), .scalar .f32⟩, sh) := by
  have := eval_offset_i32 C (eval_local C ctx L p _ hp sh) (eval_lit C _ _ _ _) hm
  rwa [show 4 * a + m * (Ty.scalar .f32).bytes = 4 * (a + m) by simp [Ty.bytes, Scalar.bytes]; ring] at this

end Eval

/-! ### Phase A: to the first `simd_sum` of step 0 -/

section PhaseA
variable {C : M1Max.Contract} {fuse : Nat → Bool} {ctx : Ctx} {T n r d : Nat} {A : Al} {I : Ins}

theorem declsT_run (hc : Lane fuse ctx n r d) {sh : Shared} (hR : RegsT T ctx A sh.regions) (hI : Inputs I sh.bytes)
    (hT : TWord I.t T) (hT2 : T < 2 ^ 31) :
    ∃ L, Exec C ctx decls (fun _ => none) sh .normal L (logged ctx sh 6 4 0 false) ∧ PreA ctx T n r d L ∧
      L 22 = some (.int .i32 0) := by
  have hd := hc.hd; have hr := hc.hr; have hn := hc.hn
  have e9 : ∀ L : Locals, L 6 = some (.ptr ⟨6, 0, .scalar .i32⟩) →
      (eval C ctx L (.load (.scalar .i32) (.offset (.local 6) (i32l 0)))).run sh =
        some (.int .i32 T, logged ctx sh 6 4 0 false) := by
    intro L h6
    have hp : (eval C ctx L (.offset (.local 6) (i32l 0))).run sh =
        some (.ptr ⟨6, ((0 : Nat) : Int), .scalar .i32⟩, sh) :=
      eval_offset_i32 C (o := 0) (eval_local C ctx L 6 _ h6 sh) (eval_lit C _ _ _ _) (by decide)
    have hw : bytesWord ((List.range 4).map fun i => sh.bytes 6 (0 + i)) = T := by
      rw [hI.t]
      show bytesWord [I.t (0 + 0), I.t (0 + 1), I.t (0 + 2), I.t (0 + 3)] = T
      simp [bytesWord, hT.1, hT.2.1, hT.2.2.1, hT.2.2.2]
      omega
    have := loadAt_run ctx (.scalar .i32) ⟨6, ((0 : Nat) : Int), .scalar .i32⟩ ⟨.constant, 4, A.t⟩ sh (.int .i32 T)
      hR.t (by simp) (by simp) (by simp only [alignment, Scalar.bytes]; exact Nat.mod_eq_zero_of_dvd hR.al.t)
      (by simp [loadOffset]) (by simp [loadOffset, Ty.bytes, Scalar.bytes])
      (by
        simp only [loadOffset, Int.toNat_natCast]
        show some (Val.ofWord .i32 (bytesWord (((List.range 4).map fun i => sh.bytes 6 (0 + i)).take 4))) = _
        rw [List.take_of_length_le (by simp), hw]
        show some (Val.int .i32 (T % 2 ^ 32)) = _
        rw [Nat.mod_eq_of_lt (by omega)])
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
    .set (eval_kqT C (P := 0) (region := 0) (hk := n / 3) (by simp [setLocal]) (by simp [setLocal])
      (by simp [setLocal]) hT2 (by simp [setLocal]) (by omega)) <|
    .set (eval_kqT C (P := 1) (region := 1) (hk := n / 3) (by simp [setLocal]) (by simp [setLocal])
      (by simp [setLocal]) hT2 (by simp [setLocal]) (by omega)) <|
    .set (eval_vptrT C (n := n) (by simp [setLocal]) (by simp [setLocal]) (by simp [setLocal]) hT2 (by simp [setLocal])
      hn) <|
    .set (eval_yptrT C (n := n) (by simp [setLocal]) (by simp [setLocal]) (by simp [setLocal]) hT2 (by simp [setLocal])
      hn) <|
    .set (e17 _) <| .set (e18 _) <|
    .set (eval_srow C (P := 5) (region := 5) (n := n) (r := r) (by simp [setLocal]) (by simp [setLocal])
      (by simp [setLocal]) hn hr) <|
    .set (eval_srow C (P := 8) (region := 8) (n := n) (r := r) (by simp [setLocal]) (by simp [setLocal])
      (by simp [setLocal]) hn hr) <|
    .array <| .set (eval_lit C _ _ _ _) <| .nil _ _,
    ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩, ?_⟩ <;> simp [setLocal]

/-- The load loop: `state[i] = i_state[s_idx]` for the lane's four columns. -/
theorem loadT_loop (hc : Lane fuse ctx n r d) {sh : Shared} (hR : RegsT T ctx A sh.regions) (hI : Inputs I sh.bytes)
    (L : Locals) (hp : PreA ctx T n r d L) (h22 : L 22 = some (.int .i32 0)) :
    ∃ L', Exec C ctx [loadLoop] L sh .normal L' (loadMem ctx I n r d sh 4) ∧ PreA ctx T n r d L' := by
  have hd := hc.hd; have hr := hc.hr; have hn := hc.hn
  obtain ⟨L', sh', hex, hp', -, rfl⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := lt4 22) (st := inc 22)
    (b := loadBody) 4
    (fun k L s => PreA ctx T n r d L ∧ L 22 = some (.int .i32 k) ∧ s = loadMem ctx I n r d sh k)
    (fun k L s => PreA ctx T n r d L ∧ L 22 = some (.int .i32 k) ∧ s = loadMem ctx I n r d sh k)
    (fun k hk L s hI' => ⟨s, eval_lt4 C hI'.2.1 (by omega), hI'⟩)
    (fun k hk L s hI' => by
      obtain ⟨hp, h22, rfl⟩ := hI'
      have e23 := eval_sIdx C (ctx := ctx) (sh := loadMem ctx I n r d sh k) hp.dk h22 (by omega)
      have hp1 := hp.set (u32 (4 * d + k)) (show 22 ≤ 23 by decide)
      have h22' : setLocal L 23 (u32 (4 * d + k)) 22 = some (.int .i32 k) := by simp [setLocal, h22]
      have hval := (eval_load C _ _ _ _ _ _ _ (eval_f32p C (eval_local C ctx _ 19 _ hp1.si (loadMem ctx I n r d sh k))
        (eval_local C ctx _ 23 _ (setLocal_same _ _ _) (loadMem ctx I n r d sh k)) (by omega))).trans
        (load_f32 ctx (loadMem ctx I n r d sh k) 5 ((n * 128 + r) * 128 + (4 * d + k)) ⟨.device, 3145728, A.state⟩
          I.state (by rw [loadMem_regions]; exact hR.state) (.inl rfl) hR.al.state (show _ ≤ 3145728 by omega)
          (by rw [loadMem_bytes (by have := hR.a9; omega)]; exact hI.state))
      have hst := store_f32_thread_tput ctx (logged ctx (loadMem ctx I n r d sh k) 5 4 ((n * 128 + r) * 128 + (4 * d + k))
        false) (ctx.threadArray 0) k 16 (stateIn I n r (4 * d + k))
        (by show (loadMem ctx I n r d sh k).regions _ = _; rw [loadMem_regions]; exact hR.arr) (by omega)
      exact ⟨.normal, _, _, _, _, .inl rfl, .set e23 (.store (eval_stateAt C hp1.arr h22' (by omega)) hval hst
        (.nil _ _)), exec_inc C h22' (by omega), hp1.set _ (by decide), by simp [setLocal], rfl⟩)
    ⟨hp, h22, rfl⟩
  exact ⟨L', hex, hp'⟩

theorem midT_run {sh : Shared} (hT2 : T < 2 ^ 31) (L : Locals) (hp : PreA ctx T n r d L) :
    ∃ L', Exec C ctx mid L sh .normal L' sh ∧ PreT ctx T n r d 0 L' := by
  have e24 : (eval C ctx L (.offset (.local 3) gBatch)).run sh = some (.ptr ⟨3, 0, .scalar .f32⟩, sh) :=
    eval_f32p C (a := 0) (eval_local C ctx L 3 _ hp.g sh) (eval_gBatchT C hp.b hp.T hT2) (by decide)
  have hp1 := hp.set (.ptr ⟨3, 0, .scalar .f32⟩) (show 22 ≤ 24 by decide)
  have e25 : (eval C ctx (setLocal L 24 (.ptr ⟨3, 0, .scalar .f32⟩)) (.offset (.local 4) gBatch)).run sh =
      some (.ptr ⟨4, 0, .scalar .bf16⟩, sh) :=
    eval_bf16 C (a := 0) (eval_local C ctx _ 4 _ hp1.beta sh) (eval_gBatchT C hp1.b hp1.T hT2) (by decide)
  refine ⟨_, .set e24 (.set e25 (.set (eval_lit C _ _ _ _) (.nil _ _))),
    ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩⟩ <;>
    simp [setLocal, hp.y, hp.T, hp.hv, hp.q, hp.k, hp.v, hp.dk, hp.dv, hp.so, hp.arr]

/-- Memory after `k` iterations of the decay loop at step `t`: `g_[hv_idx]` read, `state[i]` decayed,
`k_[s_idx]` read. -/
def decayMemT (C : M1Max.Contract) (ctx : Ctx) (J : Ins) (n r d t : Nat) (sh : Shared) : Nat → Shared
  | 0 => sh
  | k + 1 => logged ctx (tput (logged ctx (decayMemT C ctx J n r d t sh k) 3 4 (48 * t + n) false)
      (ctx.threadArray 0) (4 * k) (wordBytes 4 (Val.f32Bits (decayed C J n r (4 * d + k))))) 1 2
      (2048 * t + n / 3 * 128 + (4 * d + k)) false

variable {J : Ins} {t : Nat}

theorem decayMemT_regions {sh : Shared} : ∀ k, (decayMemT C ctx J n r d t sh k).regions = sh.regions
  | 0 => rfl
  | k + 1 => decayMemT_regions k

theorem decayMemT_epoch {sh : Shared} : ∀ k, (decayMemT C ctx J n r d t sh k).deviceEpoch = sh.deviceEpoch
  | 0 => rfl
  | k + 1 => decayMemT_epoch k

theorem decayMemT_bytes {sh : Shared} {x : Nat} (hx : x ≠ ctx.threadArray 0) :
    ∀ k, (decayMemT C ctx J n r d t sh k).bytes x = sh.bytes x
  | 0 => rfl
  | k + 1 => by
    show (tput _ _ _ _).bytes x = _
    rw [tput_bytes, ite_eq_right hx]; exact decayMemT_bytes hx k

theorem decayMemT_arr {sh : Shared} (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => stateIn J n r (4 * d + j)) 4) :
    ∀ k, k ≤ 4 → Arr ((decayMemT C ctx J n r d t sh k).bytes (ctx.threadArray 0))
      (fun j => if j < k then decayed C J n r (4 * d + j) else stateIn J n r (4 * d + j)) 4
  | 0, _ => h0.congr fun j _ => by simp
  | k + 1, hk => by
    have e : (decayMemT C ctx J n r d t sh (k + 1)).bytes (ctx.threadArray 0) =
        writeBytes ((decayMemT C ctx J n r d t sh k).bytes (ctx.threadArray 0)) (4 * k)
          (wordBytes 4 (Val.f32Bits (decayed C J n r (4 * d + k)))) := by
      show (tput _ _ _ _).bytes _ = _
      rw [tput_bytes, ite_eq_left rfl]; rfl
    rw [e]
    exact ((decayMemT_arr h0 k (by omega)).write (show k < 4 by omega) _).congr fun j _ =>
      mix_succ (fun j => decayed C J n r (4 * d + j)) (fun j => stateIn J n r (4 * d + j)) k j

theorem decayMemT_log {sh : Shared} : ∀ k, ∀ e ∈ (decayMemT C ctx J n r d t sh k).log, e ∈ sh.log ∨
    (e.region < 7 ∧ e.write = false)
  | 0, e, he => .inl he
  | k + 1, e, he => by
    simp only [decayMemT, tput, logged, List.mem_append, List.mem_reverse, List.mem_map, List.mem_range] at he
    rcases he with ⟨i, _, rfl⟩ | ⟨i, _, rfl⟩ | he
    · exact .inr ⟨by simp [entry], rfl⟩
    · exact .inr ⟨by simp [entry], rfl⟩
    · exact decayMemT_log k e he

/-- One iteration of the decay loop at step `t`. -/
theorem decayT_body (hc : Lane fuse ctx n r d) {sh : Shared} (hR : RegsT T ctx A sh.regions) (hI : Inputs I sh.bytes)
    (hJ : Slice C I J t) (ht : t < T)
    (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => stateIn J n r (4 * d + j)) 4)
    (k : Nat) (hk : k < 4) (L : Locals) (hp : PreT ctx T n r d t L) (h28 : L 28 = some (.int .i32 k))
    (h27 : L 27 = some (.f32 (kvPart C fuse J n r d k))) :
    ∃ L₁, Exec C ctx decayBody L (decayMemT C ctx J n r d t sh k) .normal L₁ (decayMemT C ctx J n r d t sh (k + 1)) ∧
      PreT ctx T n r d t L₁ ∧ L₁ 28 = some (.int .i32 k) ∧ L₁ 27 = some (.f32 (kvPart C fuse J n r d (k + 1))) := by
  have hd := hc.hd; have hr := hc.hr; have hn := hc.hn; have a9 := hR.a9
  have harr := decayMemT_arr (C := C) (t := t) h0 k (by omega)
  have r0 : (decayMemT C ctx J n r d t sh k).regions = sh.regions := decayMemT_regions k
  have b1 : (decayMemT C ctx J n r d t sh k).bytes 1 = I.k := (decayMemT_bytes (by omega) k).trans hI.k
  have b3 : (decayMemT C ctx J n r d t sh k).bytes 3 = I.g := (decayMemT_bytes (by omega) k).trans hI.g
  generalize hS0 : decayMemT C ctx J n r d t sh k = S0 at harr r0 b1 b3
  have ra : S0.regions (ctx.threadArray 0) = some ⟨.thread, 16, 4⟩ := by rw [r0]; exact hR.arr
  have e29 : (eval C ctx L (sIdx 28)).run S0 = some (u32 (4 * d + k), S0) := eval_sIdx C hp.dk h28 (by omega)
  generalize hL1 : setLocal L 29 (u32 (4 * d + k)) = L1
  have hp1 : PreT ctx T n r d t L1 := hL1 ▸ hp.set _ (by decide)
  have h28' : L1 28 = some (.int .i32 k) := by rw [← hL1]; simp [setLocal, h28]
  have h29 : L1 29 = some (u32 (4 * d + k)) := by rw [← hL1]; simp [setLocal]
  have h27' : L1 27 = some (.f32 (kvPart C fuse J n r d k)) := by rw [← hL1]; simp [setLocal, h27]
  have hold : (eval C ctx L1 (stateLoad 28)).run S0 = some (.f32 (stateIn J n r (4 * d + k)), S0) := by
    have := eval_stateLoad C hp1.arr h28' hk ra harr
    rwa [ite_eq_right (lt_irrefl k)] at this
  have hgv : (eval C ctx L1 (.load (.scalar .f32) (.offset (.local 24) (.local 12)))).run S0 =
      some (.f32 (f32At J.g n), logged ctx S0 3 4 (48 * t + n) false) := by
    have := (eval_load C _ _ _ _ _ _ _ (eval_f32p C (a := 48 * t) (eval_local C ctx L1 24 _ hp1.g S0)
      (eval_local C ctx L1 12 _ hp1.hv S0) (by omega))).trans (load_f32 ctx S0 3 (48 * t + n) ⟨.device, 192 * T, A.g⟩
        I.g (by rw [r0]; exact hR.g) (.inl rfl) hR.al.g (show _ ≤ 192 * T by omega) b3)
    rwa [hJ.decay] at this
  have hval : (eval C ctx L1 (.bin .mul .f32 0 (stateLoad 28) (.load (.scalar .f32)
      (.offset (.local 24) (.local 12))))).run S0 =
        some (.f32 (decayed C J n r (4 * d + k)), logged ctx S0 3 4 (48 * t + n) false) :=
    eval_f32 C (.inl ⟨by decide, by decide⟩) hold hgv rfl
  have hst := store_f32_thread_tput ctx (logged ctx S0 3 4 (48 * t + n) false) (ctx.threadArray 0) k 16
    (decayed C J n r (4 * d + k)) ra (by omega)
  generalize hS2 : tput (logged ctx S0 3 4 (48 * t + n) false) (ctx.threadArray 0) (4 * k)
    (wordBytes 4 (Val.f32Bits (decayed C J n r (4 * d + k)))) = S2 at hst
  have harr2 : Arr (S2.bytes (ctx.threadArray 0)) (fun j => if j = k then decayed C J n r (4 * d + k) else
      (if j < k then decayed C J n r (4 * d + j) else stateIn J n r (4 * d + j))) 4 := by
    rw [← hS2, tput_bytes, ite_eq_left rfl]; exact harr.write hk _
  have r2 : S2.regions = sh.regions := by rw [← hS2]; exact r0
  have hnew : (eval C ctx L1 (stateLoad 28)).run S2 = some (.f32 (decayed C J n r (4 * d + k)), S2) := by
    have := eval_stateLoad C hp1.arr h28' hk (by rw [r2]; exact hR.arr) harr2
    rwa [ite_eq_left rfl] at this
  have hkey : (eval C ctx L1 (floatAt 15 29)).run S2 =
      some (.f32 (keyAt C J n (4 * d + k)), logged ctx S2 1 2 (2048 * t + n / 3 * 128 + (4 * d + k)) false) := by
    have := eval_floatAt C (ctx := ctx) (r := ⟨.device, 4096 * T, A.k⟩) (M := I.k) hp1.k h29 (by omega) (by rw [r2]; exact hR.k) rfl hR.al.k
      (by show _ ≤ 4096 * T; omega) (by rw [← hS2, tput_bytes, ite_eq_right (by omega)]; exact b1)
    rwa [hJ.key] at this
  have e27 : (eval C ctx L1 (.bin .add .f32 1 (.local 27) (.bin .mul .f32 0 (stateLoad 28) (floatAt 15 29)))).run S2 =
      some (.f32 (kvPart C fuse J n r d (k + 1)), logged ctx S2 1 2 (2048 * t + n / 3 * 128 + (4 * d + k)) false) := by
    have := eval_add_mul_mem C (site := 1) (m := 0) rfl hnew hkey (eval_local C ctx L1 27 _ h27' S2)
      (eval_local C ctx L1 27 _ h27' _)
    rw [hc.fuse] at this; exact this
  have hS3 : logged ctx S2 1 2 (2048 * t + n / 3 * 128 + (4 * d + k)) false = decayMemT C ctx J n r d t sh (k + 1) := by
    rw [← hS2, ← hS0]; rfl
  rw [hS3] at e27
  subst hL1
  exact ⟨_, .set e29 (.store (eval_stateAt C hp1.arr h28' (by omega)) hval hst (.set e27 (.nil _ _))),
    hp1.set _ (by decide), by simp [setLocal, h28], by simp [setLocal]⟩

/-- The decay loop at step `t` and its declarations. -/
theorem decayT_loop (hc : Lane fuse ctx n r d) {sh : Shared} (hR : RegsT T ctx A sh.regions) (hI : Inputs I sh.bytes)
    (hJ : Slice C I J t) (ht : t < T)
    (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => stateIn J n r (4 * d + j)) 4) (L : Locals)
    (hp : PreT ctx T n r d t L) :
    ∃ L', Exec C ctx [.set 27 (f32l 0x0), .set 28 (i32l 0), decayLoop] L sh .normal L' (decayMemT C ctx J n r d t sh 4) ∧
      PreT ctx T n r d t L' ∧ L' 27 = some (.f32 (kvPart C fuse J n r d 4)) := by
  obtain ⟨L', sh', hex, hp', -, h27, rfl⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := lt4 28) (st := inc 28)
    (b := decayBody) 4
    (fun k L s => PreT ctx T n r d t L ∧ L 28 = some (.int .i32 k) ∧ L 27 = some (.f32 (kvPart C fuse J n r d k)) ∧
      s = decayMemT C ctx J n r d t sh k)
    (fun k L s => PreT ctx T n r d t L ∧ L 28 = some (.int .i32 k) ∧ L 27 = some (.f32 (kvPart C fuse J n r d k)) ∧
      s = decayMemT C ctx J n r d t sh k)
    (fun k hk L s hI' => ⟨s, eval_lt4 C hI'.2.1 (by omega), hI'⟩)
    (fun k hk L s hI' => by
      obtain ⟨hp, h28, h27, rfl⟩ := hI'
      obtain ⟨L₁, hb, hp₁, h28₁, h27₁⟩ := decayT_body hc hR hI hJ ht h0 k hk L hp h28 h27
      exact ⟨.normal, L₁, _, _, _, .inl rfl, hb, exec_inc C h28₁ (by omega), hp₁.set _ (by decide),
        by simp [setLocal], by simp [setLocal, h27₁], rfl⟩)
    (l := setLocal (setLocal L 27 (.f32 (Val.ofF32Bits 0x0))) 28 (.int .i32 0))
    ⟨(hp.set _ (by decide)).set _ (by decide), by simp [setLocal], by simp [setLocal]; rfl, rfl⟩
  exact ⟨L', .set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) hex), hp', h27⟩

/-- Memory after phase A. -/
def memAT (C : M1Max.Contract) (fuse : Nat → Bool) (ctx : Ctx) (I : Ins) (n r d : Nat) (sh : Shared) : Shared :=
  decayMemT C ctx (stepAt C fuse I 0) n r d 0 (loadMem ctx I n r d (logged ctx sh 6 4 0 false) 4) 4

/-- A lane runs to its first `simd_sum` (of step 0). -/
theorem phaseAT (hc : Lane fuse ctx n r d) {sh : Shared} (hR : RegsT T ctx A sh.regions) (hI : Inputs I sh.bytes)
    (hT : TWord I.t T) (hT1 : 1 ≤ T) (hT2 : T < 2 ^ 31) :
    ∃ L', (∃ N, ∀ m ≥ N, (runThread C m ⟨ctx, fun _ => none, [.block body], .running⟩).run sh =
      some (⟨ctx, L', [.block restA, loopFrame, .block tail],
        .collective 2 30 .sum .f32 (.f32 (kvPart C fuse (stepAt C fuse I 0) n r d 4)) 0⟩, memAT C fuse ctx I n r d sh)) ∧
      PreT ctx T n r d 0 L' := by
  have a9 := hR.a9
  obtain ⟨L0, hd, hp0, h22⟩ := declsT_run (C := C) hc hR hI hT hT2
  obtain ⟨L1, hl, hp1⟩ := loadT_loop (C := C) (I := I) hc (sh := logged ctx sh 6 4 0 false) hR hI L0 hp0 h22
  obtain ⟨L2, hm, hp2⟩ := midT_run (C := C) (sh := loadMem ctx I n r d (logged ctx sh 6 4 0 false) 4) hT2 L1 hp1
  have R2 : RegsT T ctx A (loadMem ctx I n r d (logged ctx sh 6 4 0 false) 4).regions := by
    rw [loadMem_regions]; exact hR
  have I2 : Inputs I (loadMem ctx I n r d (logged ctx sh 6 4 0 false) 4).bytes :=
    Inputs.of (M := (logged ctx sh 6 4 0 false).bytes) hI (fun x hx => loadMem_bytes (by omega) 4)
  obtain ⟨L3, hdl, hp3, h27⟩ := decayT_loop (C := C) (fuse := fuse) hc R2 I2 (slice_at C fuse I 0) (by omega)
    ((loadMem_arr 4 le_rfl).congr fun j _ => (stateIn_zero C fuse I n r (4 * d + j)).symm) L2 hp2
  have hstep : Exec C ctx stepBody L2 (loadMem ctx I n r d (logged ctx sh 6 4 0 false) 4)
      (.stop (.collective 2 30 .sum .f32 (.f32 (kvPart C fuse (stepAt C fuse I 0) n r d 4)) 0) [.block restA]) L3
      (memAT C fuse ctx I n r d sh) := by
    rw [stepBody_eqA]
    exact hdl.append (.collective (eval_local C ctx L3 27 _ h27 _) (eval_lit C _ _ _ _) rfl)
  have htime : Exec C ctx (timeLoop :: tail) L2 (loadMem ctx I n r d (logged ctx sh 6 4 0 false) 4)
      (.stop (.collective 2 30 .sum .f32 (.f32 (kvPart C fuse (stepAt C fuse I 0) n r d 4)) 0)
        ([.block restA] ++ [loopFrame, .block tail])) L3 (memAT C fuse ctx I n r d sh) := by
    have hlt := eval_int C (ctx := ctx) (sh := loadMem ctx I n r d (logged ctx sh 6 4 0 false) 4) (site := 0) (by decide)
      (eval_local C ctx L2 26 _ hp2.t _) (eval_local C ctx L2 9 _ hp2.T _) (binary_lt_i32 C 0 T (by decide) hT2)
    rw [show decide (0 < T) = true from decide_eq_true (by omega)] at hlt
    exact .loop_stop hlt hstep
  have hall : Exec C ctx body (fun _ => none) sh
      (.stop (.collective 2 30 .sum .f32 (.f32 (kvPart C fuse (stepAt C fuse I 0) n r d 4)) 0)
        ([.block restA] ++ [loopFrame, .block tail])) L3 (memAT C fuse ctx I n r d sh) := by
    rw [body_eq]; exact hd.append (hl.append (hm.append htime))
  exact ⟨L3, hall.reaches_stop.run rfl, hp3⟩

end PhaseA

/-! ### Phase B: from the first `simd_sum` of step `t` to its second -/

section PhaseB
variable {C : M1Max.Contract} {fuse : Nat → Bool} {ctx : Ctx} {T n r d : Nat} {A : Al} {I J : Ins} {t : Nat}

/-- Memory after `delta`'s loads of `v_[dv_idx]` and `beta_[hv_idx]` at step `t`. -/
def deltaMemT (ctx : Ctx) (n r t : Nat) (sh : Shared) : Shared :=
  logged ctx (logged ctx sh 2 2 (6144 * t + n * 128 + r) false) 4 2 (48 * t + n) false

/-- Memory after `k` iterations of the update loop at step `t`: `k_[s_idx]` read, `state[i]` updated,
`q_[s_idx]` read. -/
def updateMemT (C : M1Max.Contract) (fuse : Nat → Bool) (ctx : Ctx) (J : Ins) (n r d t : Nat) (sh : Shared) :
    Nat → Shared
  | 0 => sh
  | k + 1 => logged ctx (tput (logged ctx (updateMemT C fuse ctx J n r d t sh k) 1 2
      (2048 * t + n / 3 * 128 + (4 * d + k)) false) (ctx.threadArray 0) (4 * k)
      (wordBytes 4 (Val.f32Bits (updated C fuse J n r (4 * d + k))))) 0 2 (2048 * t + n / 3 * 128 + (4 * d + k)) false

theorem updateMemT_regions {sh : Shared} : ∀ k, (updateMemT C fuse ctx J n r d t sh k).regions = sh.regions
  | 0 => rfl
  | k + 1 => updateMemT_regions k

theorem updateMemT_epoch {sh : Shared} : ∀ k, (updateMemT C fuse ctx J n r d t sh k).deviceEpoch = sh.deviceEpoch
  | 0 => rfl
  | k + 1 => updateMemT_epoch k

theorem updateMemT_bytes {sh : Shared} {x : Nat} (hx : x ≠ ctx.threadArray 0) :
    ∀ k, (updateMemT C fuse ctx J n r d t sh k).bytes x = sh.bytes x
  | 0 => rfl
  | k + 1 => by
    show (tput _ _ _ _).bytes x = _
    rw [tput_bytes, ite_eq_right hx]; exact updateMemT_bytes hx k

theorem updateMemT_arr {sh : Shared} (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => decayed C J n r (4 * d + j)) 4) :
    ∀ k, k ≤ 4 → Arr ((updateMemT C fuse ctx J n r d t sh k).bytes (ctx.threadArray 0))
      (fun j => if j < k then updated C fuse J n r (4 * d + j) else decayed C J n r (4 * d + j)) 4
  | 0, _ => h0.congr fun j _ => by simp
  | k + 1, hk => by
    have e : (updateMemT C fuse ctx J n r d t sh (k + 1)).bytes (ctx.threadArray 0) =
        writeBytes ((updateMemT C fuse ctx J n r d t sh k).bytes (ctx.threadArray 0)) (4 * k)
          (wordBytes 4 (Val.f32Bits (updated C fuse J n r (4 * d + k)))) := by
      show (tput _ _ _ _).bytes _ = _
      rw [tput_bytes, ite_eq_left rfl]; rfl
    rw [e]
    exact ((updateMemT_arr h0 k (by omega)).write (show k < 4 by omega) _).congr fun j _ =>
      mix_succ (fun j => updated C fuse J n r (4 * d + j)) (fun j => decayed C J n r (4 * d + j)) k j

theorem updateMemT_log {sh : Shared} : ∀ k, ∀ e ∈ (updateMemT C fuse ctx J n r d t sh k).log, e ∈ sh.log ∨
    (e.region < 7 ∧ e.write = false)
  | 0, e, he => .inl he
  | k + 1, e, he => by
    simp only [updateMemT, tput, logged, List.mem_append, List.mem_reverse, List.mem_map, List.mem_range] at he
    rcases he with ⟨i, _, rfl⟩ | ⟨i, _, rfl⟩ | he
    · exact .inr ⟨by simp [entry], rfl⟩
    · exact .inr ⟨by simp [entry], rfl⟩
    · exact updateMemT_log k e he

/-- One iteration of the update loop at step `t`. -/
theorem updateT_body (hc : Lane fuse ctx n r d) {sh : Shared} (hR : RegsT T ctx A sh.regions) (hI : Inputs I sh.bytes)
    (hJ : Slice C I J t) (ht : t < T)
    (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => decayed C J n r (4 * d + j)) 4)
    (k : Nat) (hk : k < 4) (L : Locals) (hp : PreT ctx T n r d t L) (h31 : L 31 = some (.f32 (delta C fuse J n r)))
    (h33 : L 33 = some (.int .i32 k)) (h32 : L 32 = some (.f32 (outPart C fuse J n r d k))) :
    ∃ L₁, Exec C ctx updateBody L (updateMemT C fuse ctx J n r d t sh k) .normal L₁
      (updateMemT C fuse ctx J n r d t sh (k + 1)) ∧
      PreT ctx T n r d t L₁ ∧ L₁ 31 = some (.f32 (delta C fuse J n r)) ∧ L₁ 33 = some (.int .i32 k) ∧
      L₁ 32 = some (.f32 (outPart C fuse J n r d (k + 1))) := by
  have hd := hc.hd; have hr := hc.hr; have hn := hc.hn; have a9 := hR.a9
  have harr := updateMemT_arr (fuse := fuse) (t := t) h0 k (by omega)
  have r0 : (updateMemT C fuse ctx J n r d t sh k).regions = sh.regions := updateMemT_regions k
  have b0 : (updateMemT C fuse ctx J n r d t sh k).bytes 0 = I.q := (updateMemT_bytes (by omega) k).trans hI.q
  have b1 : (updateMemT C fuse ctx J n r d t sh k).bytes 1 = I.k := (updateMemT_bytes (by omega) k).trans hI.k
  generalize hS0 : updateMemT C fuse ctx J n r d t sh k = S0 at harr r0 b0 b1
  have ra : S0.regions (ctx.threadArray 0) = some ⟨.thread, 16, 4⟩ := by rw [r0]; exact hR.arr
  have e34 : (eval C ctx L (sIdx 33)).run S0 = some (u32 (4 * d + k), S0) := eval_sIdx C hp.dk h33 (by omega)
  generalize hL1 : setLocal L 34 (u32 (4 * d + k)) = L1
  have hp1 : PreT ctx T n r d t L1 := hL1 ▸ hp.set _ (by decide)
  have h33' : L1 33 = some (.int .i32 k) := by rw [← hL1]; simp [setLocal, h33]
  have h34 : L1 34 = some (u32 (4 * d + k)) := by rw [← hL1]; simp [setLocal]
  have h31' : L1 31 = some (.f32 (delta C fuse J n r)) := by rw [← hL1]; simp [setLocal, h31]
  have h32' : L1 32 = some (.f32 (outPart C fuse J n r d k)) := by rw [← hL1]; simp [setLocal, h32]
  have hold : ∀ S : Shared, S.regions = S0.regions → S.bytes (ctx.threadArray 0) = S0.bytes (ctx.threadArray 0) →
      (eval C ctx L1 (stateLoad 33)).run S = some (.f32 (decayed C J n r (4 * d + k)), S) := by
    intro S hSr hSb
    have := eval_stateLoad C (sh := S) hp1.arr h33' hk (by rw [hSr]; exact ra) (by rw [hSb]; exact harr)
    rwa [ite_eq_right (lt_irrefl k)] at this
  have hkey : (eval C ctx L1 (floatAt 15 34)).run S0 =
      some (.f32 (keyAt C J n (4 * d + k)), logged ctx S0 1 2 (2048 * t + n / 3 * 128 + (4 * d + k)) false) := by
    have := eval_floatAt C (ctx := ctx) (r := ⟨.device, 4096 * T, A.k⟩) (M := I.k) hp1.k h34 (by omega)
      (by rw [r0]; exact hR.k) rfl hR.al.k (by show _ ≤ 4096 * T; omega) b1
    rwa [hJ.key] at this
  have hval : (eval C ctx L1 (.bin .add .f32 3 (stateLoad 33) (.bin .mul .f32 0 (floatAt 15 34) (.local 31)))).run S0 =
      some (.f32 (updated C fuse J n r (4 * d + k)), logged ctx S0 1 2 (2048 * t + n / 3 * 128 + (4 * d + k)) false) := by
    have := eval_add_mul_mem C (site := 3) (m := 0) rfl hkey (eval_local C ctx L1 31 _ h31' _)
      (hold S0 rfl rfl) (hold _ rfl rfl)
    rw [hc.fuse] at this; exact this
  have hst := store_f32_thread_tput ctx (logged ctx S0 1 2 (2048 * t + n / 3 * 128 + (4 * d + k)) false) (ctx.threadArray 0) k
    16 (updated C fuse J n r (4 * d + k)) ra (by omega)
  generalize hS2 : tput (logged ctx S0 1 2 (2048 * t + n / 3 * 128 + (4 * d + k)) false) (ctx.threadArray 0) (4 * k)
    (wordBytes 4 (Val.f32Bits (updated C fuse J n r (4 * d + k)))) = S2 at hst
  have harr2 : Arr (S2.bytes (ctx.threadArray 0)) (fun j => if j = k then updated C fuse J n r (4 * d + k) else
      (if j < k then updated C fuse J n r (4 * d + j) else decayed C J n r (4 * d + j))) 4 := by
    rw [← hS2, tput_bytes, ite_eq_left rfl]; exact harr.write hk _
  have r2 : S2.regions = sh.regions := by rw [← hS2]; exact r0
  have hnew : (eval C ctx L1 (stateLoad 33)).run S2 = some (.f32 (updated C fuse J n r (4 * d + k)), S2) := by
    have := eval_stateLoad C hp1.arr h33' hk (by rw [r2]; exact hR.arr) harr2
    rwa [ite_eq_left rfl] at this
  have hq : (eval C ctx L1 (floatAt 14 34)).run S2 =
      some (.f32 (queryAt C J n (4 * d + k)), logged ctx S2 0 2 (2048 * t + n / 3 * 128 + (4 * d + k)) false) := by
    have := eval_floatAt C (ctx := ctx) (r := ⟨.device, 4096 * T, A.q⟩) (M := I.q) hp1.q h34 (by omega)
      (by rw [r2]; exact hR.q) rfl hR.al.q (by show _ ≤ 4096 * T; omega)
      (by rw [← hS2, tput_bytes, ite_eq_right (by omega)]; exact b0)
    rwa [hJ.query] at this
  have e32 : (eval C ctx L1 (.bin .add .f32 4 (.local 32) (.bin .mul .f32 0 (stateLoad 33) (floatAt 14 34)))).run S2 =
      some (.f32 (outPart C fuse J n r d (k + 1)), logged ctx S2 0 2 (2048 * t + n / 3 * 128 + (4 * d + k)) false) := by
    have := eval_add_mul_mem C (site := 4) (m := 0) rfl hnew hq (eval_local C ctx L1 32 _ h32' S2)
      (eval_local C ctx L1 32 _ h32' _)
    rw [hc.fuse] at this; exact this
  have hS3 : logged ctx S2 0 2 (2048 * t + n / 3 * 128 + (4 * d + k)) false =
      updateMemT C fuse ctx J n r d t sh (k + 1) := by
    rw [← hS2, ← hS0]; rfl
  rw [hS3] at e32
  subst hL1
  exact ⟨_, .set e34 (.store (eval_stateAt C hp1.arr h33' (by omega)) hval hst (.set e32 (.nil _ _))),
    hp1.set _ (by decide), by simp [setLocal, h31], by simp [setLocal, h33], by simp [setLocal]⟩

/-- A lane resumed with the row's `kv_mem` at step `t` runs to its second `simd_sum`. -/
theorem phaseBT (hc : Lane fuse ctx n r d) {sh : Shared} (hR : RegsT T ctx A sh.regions) (hI : Inputs I sh.bytes)
    (hJ : Slice C I J t) (ht : t < T)
    (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => decayed C J n r (4 * d + j)) 4) (L : Locals)
    (hp : PreT ctx T n r d t L) :
    ∃ L', (∃ N, ∀ m ≥ N, (runThread C m ⟨ctx, setLocal L 30 (.f32 (kvMem C fuse J n r)),
      [.block restA, loopFrame, .block tail], .running⟩).run sh =
      some (⟨ctx, L', [.block restB, loopFrame, .block tail],
        .collective 5 35 .sum .f32 (.f32 (outPart C fuse J n r d 4)) 0⟩,
        updateMemT C fuse ctx J n r d t (deltaMemT ctx n r t sh) 4)) ∧ PreT ctx T n r d t L' := by
  have hd := hc.hd; have hr := hc.hr; have hn := hc.hn; have a9 := hR.a9
  generalize hL0 : setLocal L 30 (.f32 (kvMem C fuse J n r)) = L0
  have hp0 : PreT ctx T n r d t L0 := hL0 ▸ hp.set _ (by decide)
  have e27 : (eval C ctx L0 (.local 30)).run sh = some (.f32 (kvMem C fuse J n r), sh) :=
    eval_local C ctx L0 30 _ (by rw [← hL0]; exact setLocal_same _ _ _) sh
  generalize hL1 : setLocal L0 27 (.f32 (kvMem C fuse J n r)) = L1
  have hp1 : PreT ctx T n r d t L1 := hL1 ▸ hp0.set _ (by decide)
  have h27 : L1 27 = some (.f32 (kvMem C fuse J n r)) := by rw [← hL1]; exact setLocal_same _ _ _
  have hv : (eval C ctx L1 (floatAt 16 18)).run sh =
      some (.f32 (C.widen (bfAt J.v (n * 128 + r))), logged ctx sh 2 2 (6144 * t + n * 128 + r) false) := by
    have := eval_floatAt C (ctx := ctx) (r := ⟨.device, 12288 * T, A.v⟩) (M := I.v) hp1.v hp1.dv (by omega) hR.v rfl
      hR.al.v (by show _ ≤ 12288 * T; omega) hI.v
    rwa [hJ.value] at this
  have hb : (eval C ctx L1 (floatAt 25 12)).run (logged ctx sh 2 2 (6144 * t + n * 128 + r) false) =
      some (.f32 (C.widen (bfAt J.beta n)), deltaMemT ctx n r t sh) := by
    have := eval_floatAt C (ctx := ctx) (a := 48 * t) (r := ⟨.device, 96 * T, A.beta⟩) (M := I.beta)
      (sh := logged ctx sh 2 2 (6144 * t + n * 128 + r) false) hp1.beta hp1.hv (by omega) hR.beta rfl hR.al.beta
      (by show _ ≤ 96 * T; omega) hI.beta
    rwa [hJ.beta] at this
  have e31 : (eval C ctx L1 deltaExpr).run sh = some (.f32 (delta C fuse J n r), deltaMemT ctx n r t sh) :=
    eval_f32 C (.inl ⟨by decide, by decide⟩)
      (eval_f32 C (.inr ⟨rfl, rfl⟩) hv (eval_local C ctx L1 27 _ h27 _) rfl) hb rfl
  generalize hL4 : setLocal (setLocal (setLocal L1 31 (.f32 (delta C fuse J n r))) 32 (.f32 (Val.ofF32Bits 0x0))) 33
    (.int .i32 0) = L4
  have hp4 : PreT ctx T n r d t L4 := hL4 ▸ ((hp1.set _ (by decide)).set _ (by decide)).set _ (by decide)
  have R1 : RegsT T ctx A (deltaMemT ctx n r t sh).regions := hR
  have I1 : Inputs I (deltaMemT ctx n r t sh).bytes := hI
  obtain ⟨L', sh', hex, hp', -, -, h32, rfl⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := lt4 33) (st := inc 33)
    (b := updateBody) 4
    (fun k L s => PreT ctx T n r d t L ∧ L 31 = some (.f32 (delta C fuse J n r)) ∧ L 33 = some (.int .i32 k) ∧
      L 32 = some (.f32 (outPart C fuse J n r d k)) ∧ s = updateMemT C fuse ctx J n r d t (deltaMemT ctx n r t sh) k)
    (fun k L s => PreT ctx T n r d t L ∧ L 31 = some (.f32 (delta C fuse J n r)) ∧ L 33 = some (.int .i32 k) ∧
      L 32 = some (.f32 (outPart C fuse J n r d k)) ∧ s = updateMemT C fuse ctx J n r d t (deltaMemT ctx n r t sh) k)
    (fun k hk L s hI' => ⟨s, eval_lt4 C hI'.2.2.1 (by omega), hI'⟩)
    (fun k hk L s hI' => by
      obtain ⟨hp, h31, h33, h32, rfl⟩ := hI'
      obtain ⟨L₁, hb, hp₁, h31₁, h33₁, h32₁⟩ := updateT_body hc R1 I1 hJ ht h0 k hk L hp h31 h33 h32
      exact ⟨.normal, L₁, _, _, _, .inl rfl, hb, exec_inc C h33₁ (by omega), hp₁.set _ (by decide),
        by simp [setLocal, h31₁], by simp [setLocal], by simp [setLocal, h32₁], rfl⟩)
    (l := L4) ⟨hp4, by rw [← hL4]; simp [setLocal], by rw [← hL4]; simp [setLocal],
      by rw [← hL4]; simp [setLocal]; rfl, rfl⟩
  have hrest : Exec C ctx restA L0 sh (.stop (.collective 5 35 .sum .f32 (.f32 (outPart C fuse J n r d 4)) 0)
      [.block restB]) L' (updateMemT C fuse ctx J n r d t (deltaMemT ctx n r t sh) 4) := by
    rw [restA_eq]
    subst hL4 hL1
    exact .set e27 (.set e31 (.set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _)
      (hex.append (.collective (eval_local C ctx L' 32 _ h32 _) (eval_lit C _ _ _ _) rfl)))))
  subst hL0
  exact ⟨L', (hrest.reaches_stop (K := [loopFrame, .block tail])).run rfl, hp'⟩

end PhaseB

/-! ### Phase C: from the second `simd_sum` of step `t` to the first of step `t + 1`, or to the end -/

section PhaseC
variable {C : M1Max.Contract} {fuse : Nat → Bool} {ctx : Ctx} {T n r d : Nat} {A : Al} {I J : Ins} {t : Nat}

/-- Memory after `y[dv_idx] = InT(out)` by lane 0 at step `t`. -/
def yMemT (C : M1Max.Contract) (fuse : Nat → Bool) (ctx : Ctx) (J : Ins) (n r d t : Nat) (sh : Shared) : Shared :=
  if d = 0 then tput (logged ctx sh 7 2 (6144 * t + n * 128 + r) true) 7 (2 * (6144 * t + n * 128 + r))
    (wordBytes 2 (Val.bf16Bits (C.narrow (outSum C fuse J n r))))
  else sh

theorem yMemT_regions {sh : Shared} : (yMemT C fuse ctx J n r d t sh).regions = sh.regions := by
  unfold yMemT; split <;> rfl

theorem yMemT_bytes {sh : Shared} {x : Nat} (hx : x ≠ 7) : (yMemT C fuse ctx J n r d t sh).bytes x = sh.bytes x := by
  unfold yMemT; split
  · rw [tput_bytes, ite_eq_right hx]; rfl
  · rfl

theorem yMemT_epoch {sh : Shared} : (yMemT C fuse ctx J n r d t sh).deviceEpoch = sh.deviceEpoch := by
  unfold yMemT; split <;> rfl

theorem yMemT_out {sh : Shared} : (yMemT C fuse ctx J n r d t sh).bytes 7 = if d = 0 then
    writeBytes (sh.bytes 7) (2 * (6144 * t + n * 128 + r)) (wordBytes 2 (Val.bf16Bits (C.narrow (outSum C fuse J n r))))
    else sh.bytes 7 := by
  unfold yMemT; split
  · rw [tput_bytes, ite_eq_left rfl]; rfl
  · rfl

theorem yMemT_log {sh : Shared} : ∀ e ∈ (yMemT C fuse ctx J n r d t sh).log, e ∈ sh.log ∨
    (d = 0 ∧ e.region = 7 ∧ e.write = true ∧ e.thread = ctx.thread ∧ e.group = ctx.group ∧
      e.deviceEpoch = sh.deviceEpoch ∧ 2 * (6144 * t + n * 128 + r) ≤ e.byte ∧ e.byte < 2 * (6144 * t + n * 128 + r) + 2) := by
  intro e he
  unfold yMemT at he
  split at he
  · rename_i hd0
    rcases logged_log e he with h | ⟨h1, h2, h3, h4, h5, h6, h7⟩
    · exact .inl h
    · exact .inr ⟨hd0, h1, h2, h3, h4, h5, h6, h7⟩
  · exact .inl he

theorem restBT_run (hc : Lane fuse ctx n r d) {sh : Shared} (hR : RegsT T ctx A sh.regions) (ht : t < T)
    (L : Locals) (hp : PreT ctx T n r d t L) :
    ∃ L7, Exec C ctx restB (setLocal L 35 (.f32 (outSum C fuse J n r))) sh .normal L7 (yMemT C fuse ctx J n r d t sh) ∧
      L7 26 = some (.int .i32 t) ∧ PreT ctx T n r d (t + 1) (setLocal L7 26 (.int .i32 (t + 1))) := by
  have hd := hc.hd; have hr := hc.hr; have hn := hc.hn
  generalize hL1 : setLocal (setLocal L 35 (.f32 (outSum C fuse J n r))) 32 (.f32 (outSum C fuse J n r)) = L1
  have hp1 : PreT ctx T n r d t L1 := hL1 ▸ (hp.set _ (by decide)).set _ (by decide)
  have h32 : L1 32 = some (.f32 (outSum C fuse J n r)) := by rw [← hL1]; exact setLocal_same _ _ _
  have hlane : (eval C ctx L1 (.coord .threadIndexInSimdgroup)).run sh = some (u32 d, sh) := by
    rw [eval_coord, hc.lane]
  have htest : (eval C ctx L1 (.bin .eq .u32 0 (.coord .threadIndexInSimdgroup) (u32l 0))).run sh =
      some (.bool (decide (d = 0)), sh) :=
    eval_int C (by decide) hlane (eval_lit C _ _ _ _) (binary_eq_u32 C d 0 (by omega) (by decide))
  have hy : Exec C ctx [yStore] L1 sh .normal L1 (yMemT C fuse ctx J n r d t sh) := by
    by_cases hd0 : d = 0
    · have hst := store_bf16_logged ctx sh 7 (6144 * t + n * 128 + r) ⟨.device, 12288 * T, 16⟩ (C.narrow (outSum C fuse J n r))
        hR.y rfl (show 2 ∣ 16 by decide) (by show _ ≤ 12288 * T; omega)
      rw [show yMemT C fuse ctx J n r d t sh = _ from ite_eq_left hd0]
      rw [decide_eq_true hd0] at htest
      exact .ite htest (.store (eval_bf16 C (eval_local C ctx L1 7 _ hp1.y sh)
        (eval_local C ctx L1 18 _ hp1.dv sh) (by omega)) (eval_conv C (eval_local C ctx L1 32 _ h32 sh) rfl) hst
        (.nil _ _)) (.nil _ _)
    · rw [show yMemT C fuse ctx J n r d t sh = sh from ite_eq_right hd0]
      rw [decide_eq_false hd0] at htest
      exact .ite htest (.nil _ _) (.nil _ _)
  generalize hS : yMemT C fuse ctx J n r d t sh = S at hy
  have p14 : (eval C ctx L1 (.offset (.local 14) (i32l 2048))).run S =
      some (.ptr ⟨0, ((2 * (2048 * (t + 1) + n / 3 * 128) : Nat) : Int), .scalar .bf16⟩, S) := by
    have := eval_adv2 C (ctx := ctx) (sh := S) (m := 2048) hp1.q (by decide)
    rwa [show 2048 * t + n / 3 * 128 + 2048 = 2048 * (t + 1) + n / 3 * 128 by omega] at this
  generalize hL2 : setLocal L1 14 (.ptr ⟨0, ((2 * (2048 * (t + 1) + n / 3 * 128) : Nat) : Int), .scalar .bf16⟩) = L2
  have p15 : (eval C ctx L2 (.offset (.local 15) (i32l 2048))).run S =
      some (.ptr ⟨1, ((2 * (2048 * (t + 1) + n / 3 * 128) : Nat) : Int), .scalar .bf16⟩, S) := by
    have := eval_adv2 C (ctx := ctx) (L := L2) (sh := S) (p := 15) (region := 1) (a := 2048 * t + n / 3 * 128) (m := 2048)
      (by rw [← hL2]; simp [setLocal, hp1.k]) (by decide)
    rwa [show 2048 * t + n / 3 * 128 + 2048 = 2048 * (t + 1) + n / 3 * 128 by omega] at this
  generalize hL3 : setLocal L2 15 (.ptr ⟨1, ((2 * (2048 * (t + 1) + n / 3 * 128) : Nat) : Int), .scalar .bf16⟩) = L3
  have p16 : (eval C ctx L3 (.offset (.local 16) (i32l 6144))).run S =
      some (.ptr ⟨2, ((2 * (6144 * (t + 1) + n * 128) : Nat) : Int), .scalar .bf16⟩, S) := by
    have := eval_adv2 C (ctx := ctx) (L := L3) (sh := S) (p := 16) (region := 2) (a := 6144 * t + n * 128) (m := 6144)
      (by rw [← hL3, ← hL2]; simp [setLocal, hp1.v]) (by decide)
    rwa [show 6144 * t + n * 128 + 6144 = 6144 * (t + 1) + n * 128 by omega] at this
  generalize hL4 : setLocal L3 16 (.ptr ⟨2, ((2 * (6144 * (t + 1) + n * 128) : Nat) : Int), .scalar .bf16⟩) = L4
  have p7 : (eval C ctx L4 (.offset (.local 7) (i32l 6144))).run S =
      some (.ptr ⟨7, ((2 * (6144 * (t + 1) + n * 128) : Nat) : Int), .scalar .bf16⟩, S) := by
    have := eval_adv2 C (ctx := ctx) (L := L4) (sh := S) (p := 7) (region := 7) (a := 6144 * t + n * 128) (m := 6144)
      (by rw [← hL4, ← hL3, ← hL2]; simp [setLocal, hp1.y]) (by decide)
    rwa [show 6144 * t + n * 128 + 6144 = 6144 * (t + 1) + n * 128 by omega] at this
  generalize hL5 : setLocal L4 7 (.ptr ⟨7, ((2 * (6144 * (t + 1) + n * 128) : Nat) : Int), .scalar .bf16⟩) = L5
  have p24 : (eval C ctx L5 (.offset (.local 24) (i32l 48))).run S =
      some (.ptr ⟨3, ((4 * (48 * (t + 1)) : Nat) : Int), .scalar .f32⟩, S) := by
    have := eval_adv4 C (ctx := ctx) (L := L5) (sh := S) (p := 24) (region := 3) (a := 48 * t) (m := 48)
      (by rw [← hL5, ← hL4, ← hL3, ← hL2]; simp [setLocal, hp1.g]) (by decide)
    rwa [show 48 * t + 48 = 48 * (t + 1) by omega] at this
  generalize hL6 : setLocal L5 24 (.ptr ⟨3, ((4 * (48 * (t + 1)) : Nat) : Int), .scalar .f32⟩) = L6
  have p25 : (eval C ctx L6 (.offset (.local 25) (i32l 48))).run S =
      some (.ptr ⟨4, ((2 * (48 * (t + 1)) : Nat) : Int), .scalar .bf16⟩, S) := by
    have := eval_adv2 C (ctx := ctx) (L := L6) (sh := S) (p := 25) (region := 4) (a := 48 * t) (m := 48)
      (by rw [← hL6, ← hL5, ← hL4, ← hL3, ← hL2]; simp [setLocal, hp1.beta]) (by decide)
    rwa [show 48 * t + 48 = 48 * (t + 1) by omega] at this
  generalize hL7 : setLocal L6 25 (.ptr ⟨4, ((2 * (48 * (t + 1)) : Nat) : Int), .scalar .bf16⟩) = L7
  have hrest : Exec C ctx restB (setLocal L 35 (.f32 (outSum C fuse J n r))) sh .normal L7 S := by
    subst hL1 hL2 hL3 hL4 hL5 hL6 hL7
    exact .set (eval_local C ctx _ 35 _ (setLocal_same _ _ _) sh) (hy.append (.set p14 (.set p15 (.set p16
      (.set p7 (.set p24 (.set p25 (.nil _ _))))))))
  refine ⟨L7, hrest, ?_, ?_⟩
  · subst hL2 hL3 hL4 hL5 hL6 hL7; simp [setLocal, hp1.t]
  · subst hL2 hL3 hL4 hL5 hL6 hL7
    exact ⟨by simp [setLocal], by simp [setLocal, hp1.T], by simp [setLocal, hp1.hv], by simp [setLocal],
      by simp [setLocal], by simp [setLocal], by simp [setLocal, hp1.dk], by simp [setLocal, hp1.dv],
      by simp [setLocal, hp1.so], by simp [setLocal, hp1.arr], by simp [setLocal], by simp [setLocal],
      by simp [setLocal]⟩

/-- A lane resumed with the row's `out` at step `t`, `t + 1 < T`: it stores `y` (lane 0), advances, and runs
step `t + 1` to its first `simd_sum`. -/
theorem phaseCT_next (hc : Lane fuse ctx n r d) {sh : Shared} (hR : RegsT T ctx A sh.regions) (hI : Inputs I sh.bytes)
    {J' : Ins} (hJ' : Slice C I J' (t + 1)) (ht : t + 1 < T) (hT2 : T < 2 ^ 31)
    (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => stateIn J' n r (4 * d + j)) 4) (L : Locals)
    (hp : PreT ctx T n r d t L) :
    ∃ L', (∃ N, ∀ m ≥ N, (runThread C m ⟨ctx, setLocal L 35 (.f32 (outSum C fuse J n r)),
      [.block restB, loopFrame, .block tail], .running⟩).run sh =
      some (⟨ctx, L', [.block restA, loopFrame, .block tail],
        .collective 2 30 .sum .f32 (.f32 (kvPart C fuse J' n r d 4)) 0⟩,
        decayMemT C ctx J' n r d (t + 1) (yMemT C fuse ctx J n r d t sh) 4)) ∧ PreT ctx T n r d (t + 1) L' := by
  have a9 := hR.a9
  obtain ⟨L7, hrest, h26, hp7⟩ := restBT_run (C := C) (J := J) hc hR (by omega) L hp
  have hinc := exec_inc C (ctx := ctx) (sh := yMemT C fuse ctx J n r d t sh) h26 (by omega)
  have hcond : (eval C ctx (setLocal L7 26 (.int .i32 (t + 1))) (.bin .lt .i32 0 (.local 26) (.local 9))).run
      (yMemT C fuse ctx J n r d t sh) = some (.bool true, yMemT C fuse ctx J n r d t sh) := by
    have := eval_int C (ctx := ctx) (sh := yMemT C fuse ctx J n r d t sh) (site := 0) (by decide)
      (eval_local C ctx _ 26 _ hp7.t _) (eval_local C ctx _ 9 _ hp7.T _) (binary_lt_i32 C (t + 1) T (by omega) hT2)
    rwa [decide_eq_true ht] at this
  have R1 : RegsT T ctx A (yMemT C fuse ctx J n r d t sh).regions := by rw [yMemT_regions]; exact hR
  have I1 : Inputs I (yMemT C fuse ctx J n r d t sh).bytes := hI.of fun x hx => yMemT_bytes (by omega)
  have A1 : Arr ((yMemT C fuse ctx J n r d t sh).bytes (ctx.threadArray 0)) (fun j => stateIn J' n r (4 * d + j)) 4 := by
    rw [yMemT_bytes (by omega)]; exact h0
  obtain ⟨L3, hdl, hp3, h27⟩ := decayT_loop (C := C) (fuse := fuse) hc R1 I1 hJ' ht A1 _ hp7
  have hb : Exec C ctx stepBody (setLocal L7 26 (.int .i32 (t + 1))) (yMemT C fuse ctx J n r d t sh)
      (.stop (.collective 2 30 .sum .f32 (.f32 (kvPart C fuse J' n r d 4)) 0) [.block restA]) L3
      (decayMemT C ctx J' n r d (t + 1) (yMemT C fuse ctx J n r d t sh) 4) := by
    rw [stepBody_eqA]
    exact hdl.append (.collective (eval_local C ctx L3 27 _ h27 _) (eval_lit C _ _ _ _) rfl)
  exact ⟨L3, (Exec.resume_stop (C := C) (K := []) (ss := tail) hrest (.inl rfl) hinc hcond hb).run rfl, hp3⟩

/-- What the final loop reads of the locals. -/
structure PreS (ctx : Ctx) (n r d : Nat) (L : Locals) : Prop where
  dk : L 17 = some (u32 d)
  so : L 20 = some (.ptr ⟨8, ((4 * ((n * 128 + r) * 128) : Nat) : Int), .scalar .f32⟩)
  arr : L 21 = some (.ptr ⟨ctx.threadArray 0, 0, .scalar .f32⟩)

theorem PreS.set {L : Locals} (hp : PreS ctx n r d L) {slot : Nat} (v : Val) (hs : 22 ≤ slot) :
    PreS ctx n r d (setLocal L slot v) :=
  ⟨(setLocal_other L v (by omega)).trans hp.dk, (setLocal_other L v (by omega)).trans hp.so,
    (setLocal_other L v (by omega)).trans hp.arr⟩

/-- The final loop: the lane's four state columns stored. -/
theorem store_loopT (hc : Lane fuse ctx n r d) {sh : Shared} (hR : RegsT T ctx A sh.regions)
    (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => updated C fuse J n r (4 * d + j)) 4) (L : Locals)
    (hp : PreS ctx n r d L) :
    ∃ L', Exec C ctx tail L sh .normal L' (storeMem C fuse ctx J n r d sh 4) := by
  have hd := hc.hd; have hr := hc.hr; have hn := hc.hn; have a9 := hR.a9
  obtain ⟨L', sh', hex, -, -, rfl⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := lt4 36) (st := inc 36)
    (b := storeBody) 4
    (fun k L s => PreS ctx n r d L ∧ L 36 = some (.int .i32 k) ∧ s = storeMem C fuse ctx J n r d sh k)
    (fun k L s => PreS ctx n r d L ∧ L 36 = some (.int .i32 k) ∧ s = storeMem C fuse ctx J n r d sh k)
    (fun k hk L s hI' => ⟨s, eval_lt4 C hI'.2.1 (by omega), hI'⟩)
    (fun k hk L s hI' => by
      obtain ⟨hp, h36, rfl⟩ := hI'
      have r0 : (storeMem C fuse ctx J n r d sh k).regions = sh.regions := storeMem_regions k
      have b0 : (storeMem C fuse ctx J n r d sh k).bytes (ctx.threadArray 0) = sh.bytes (ctx.threadArray 0) :=
        storeMem_bytes (by omega) k
      have e37 := eval_sIdx C (ctx := ctx) (sh := storeMem C fuse ctx J n r d sh k) hp.dk h36 (by omega)
      have hp1 := hp.set (u32 (4 * d + k)) (show 22 ≤ 37 by decide)
      have h36' : setLocal L 37 (u32 (4 * d + k)) 36 = some (.int .i32 k) := by simp [setLocal, h36]
      have hptr := eval_f32p C (eval_local C ctx _ 20 _ hp1.so (storeMem C fuse ctx J n r d sh k))
        (eval_local C ctx _ 37 _ (setLocal_same L 37 (u32 (4 * d + k))) _) (by omega)
      have hval := eval_stateLoad C (sh := storeMem C fuse ctx J n r d sh k) hp1.arr h36' hk
        (by rw [r0]; exact hR.arr) (by rw [b0]; exact h0)
      have hst := store_f32 ctx (storeMem C fuse ctx J n r d sh k) 8 ((n * 128 + r) * 128 + (4 * d + k))
        ⟨.device, 3145728, 16⟩ (updated C fuse J n r (4 * d + k)) (by rw [r0]; exact hR.so) rfl (by decide)
        (by show _ ≤ 3145728; omega)
      exact ⟨.normal, _, _, _, _, .inl rfl, .set e37 (.store hptr hval hst (.nil _ _)), exec_inc C h36' (by omega),
        hp1.set _ (by decide), by simp [setLocal], rfl⟩)
    (l := setLocal L 36 (.int .i32 0)) ⟨hp.set _ (by decide), by simp [setLocal], rfl⟩
  exact ⟨L', .set (eval_lit C _ _ _ _) hex⟩

/-- A lane resumed with the row's `out` at the last step `t` (`t + 1 = T`): it stores `y` (lane 0), advances,
leaves the time loop and stores its state columns. -/
theorem phaseCT_last (hc : Lane fuse ctx n r d) {sh : Shared} (hR : RegsT T ctx A sh.regions) (ht : t + 1 = T)
    (hT2 : T < 2 ^ 31) (h0 : Arr (sh.bytes (ctx.threadArray 0)) (fun j => updated C fuse J n r (4 * d + j)) 4)
    (L : Locals) (hp : PreT ctx T n r d t L) :
    ∃ L', ∃ N, ∀ m ≥ N, (runThread C m ⟨ctx, setLocal L 35 (.f32 (outSum C fuse J n r)),
      [.block restB, loopFrame, .block tail], .running⟩).run sh =
      some (⟨ctx, L', [], .done⟩, storeMem C fuse ctx J n r d (yMemT C fuse ctx J n r d t sh) 4) := by
  have a9 := hR.a9
  obtain ⟨L7, hrest, h26, hp7⟩ := restBT_run (C := C) (J := J) hc hR (by omega) L hp
  have hinc := exec_inc C (ctx := ctx) (sh := yMemT C fuse ctx J n r d t sh) h26 (by omega)
  have hexit : (eval C ctx (setLocal L7 26 (.int .i32 (t + 1))) (.bin .lt .i32 0 (.local 26) (.local 9))).run
      (yMemT C fuse ctx J n r d t sh) = some (.bool false, yMemT C fuse ctx J n r d t sh) := by
    have := eval_int C (ctx := ctx) (sh := yMemT C fuse ctx J n r d t sh) (site := 0) (by decide)
      (eval_local C ctx _ 26 _ hp7.t _) (eval_local C ctx _ 9 _ hp7.T _) (binary_lt_i32 C (t + 1) T (by omega) hT2)
    rwa [decide_eq_false (by omega)] at this
  obtain ⟨L', htail⟩ := store_loopT (C := C) (fuse := fuse) (J := J) hc (sh := yMemT C fuse ctx J n r d t sh)
    (by rw [yMemT_regions]; exact hR) (by rw [yMemT_bytes (by omega)]; exact h0) _ ⟨hp7.dk, hp7.so, hp7.arr⟩
  exact ⟨L', ((Exec.resume_exit (C := C) (K := []) hrest (.inl rfl) hinc hexit).trans htail.reaches_done).run rfl⟩

end PhaseC

/-! ## The launch -/

/-- The input buffers for `T` time steps: `T` (one int32) in constant memory, the rest in device memory. -/
def inputsT (T : Nat) (I : Ins) (A : Al) : List Buffer :=
  [⟨.device, 4096 * T, A.q, I.q⟩, ⟨.device, 4096 * T, A.k, I.k⟩, ⟨.device, 12288 * T, A.v, I.v⟩,
   ⟨.device, 192 * T, A.g, I.g⟩, ⟨.device, 96 * T, A.beta, I.beta⟩, ⟨.device, 3145728, A.state, I.state⟩,
   ⟨.constant, 4, A.t, I.t⟩]

/-- The outputs' sizes in bytes: `y` [1, T, 48, 128] bf16 and `state_out` [1, 48, 128, 128] f32. -/
def sizesT (T : Nat) : List Nat := [12288 * T, 3145728]

def launchT (T : Nat) (I : Ins) (A : Al) (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨core, (32, 128, 48), (32, 4, 1), buffers (inputsT T I A) (sizesT T) 16 initial⟩

/-- `y` element `e` is tput by step `e / 6144`'s writer of its row (`yThread`), `state_out` elements as for
one step. -/
def devT (region byte : Nat) : Option Writer :=
  if region = 7 then some (writer (yThread (byte / 2 % 6144)))
  else if region = 8 then some (writer (soThread (byte / 4)))
  else none

section LaunchFacts
variable (T : Nat) (I : Ins) (A : Al) (initial : Nat → ByteMemory.Bytes)

theorem tilesT : (launchT T I A initial).Tiles 32 4 1 1 32 48 4 := ⟨rfl, rfl, rfl, by decide⟩

theorem launchT_rt (t : Nat) : (launchT T I A initial).regions (9 + t) = some ⟨.thread, 16, 4⟩ := by
  have := Launch.regions_threadArray (launchT T I A initial) t 0 (.scalar .f32) 4 rfl
  rwa [show (launchT T I A initial).buffers.length + (launchT T I A initial).groupArrays +
    t * (launchT T I A initial).threadArrays + 0 = 9 + t from show 9 + 0 + t * 1 + 0 = 9 + t by omega] at this

theorem isGroup_launchT (x : Nat) (hx : x < 9) : isGroup ((launchT T I A initial).regions x) = false := by
  rcases (by omega : x = 0 ∨ x = 1 ∨ x = 2 ∨ x = 3 ∨ x = 4 ∨ x = 5 ∨ x = 6 ∨ x = 7 ∨ x = 8) with
    rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

/-- A read of an input. -/
theorem owned_readT (a : Access) (hr : a.region < 7) (hw : a.write = false) :
    Owned (launchT T I A initial) devT tgo a := by
  unfold Owned
  rw [isGroup_launchT T I A initial a.region (by omega)]
  have hd : devT a.region a.byte = none := by unfold devT; rw [ite_eq_right (by omega), ite_eq_right (by omega)]
  simp only [Bool.false_eq_true, ↓reduceIte, hd]
  exact hw

/-- A write by the byte's writer. -/
theorem owned_writeT (a : Access) (hr : a.region = 7 ∨ a.region = 8) (t : Nat)
    (hd : devT a.region a.byte = some (writer t)) (ht : a.thread = t) (hg : a.group = t / 128) (he : a.deviceEpoch = 0) :
    Owned (launchT T I A initial) devT tgo a := by
  unfold Owned
  rw [isGroup_launchT T I A initial a.region (by omega), hd]
  simp [writer, ht, hg, he]

variable (fuse : Nat → Bool) {yy n s : Nat}

theorem ctx_laneT (hy : yy < 32) (hn : n < 48) (hs : s < 4) (i : Fin 32) :
    Lane fuse ((launchT T I A initial).ctxAt fuse 0 yy n (32 * s + i)) n (4 * yy + s) i := by
  have hi := i.isLt
  refine ⟨?_, ?_, Launch.ctxAt_lane _ fuse 0 yy n s i, Launch.ctxAt_fuse _ fuse 0 yy n _, hi, by omega, hn⟩
  · rw [(tilesT T I A initial).threadPositionInGrid, show 0 * 32 + (32 * s + i) % 32 = i by omega,
      show yy * 4 + (32 * s + i) / 32 % 4 = 4 * yy + s by omega, show n * 1 + (32 * s + i) / (32 * 4) = n by omega]
  · rw [(tilesT T I A initial).threadPositionInThreadgroup, show (32 * s + i) % 32 = i by omega,
      show (32 * s + i) / 32 % 4 = (4 * yy + s) % 4 by omega, show (32 * s + i) / (32 * 4) = 0 by omega]

theorem ctx_threadT (i : Nat) :
    ((launchT T I A initial).ctxAt fuse 0 yy n (32 * s + i)).thread = 128 * (yy + 32 * n) + 32 * s + i := by
  rw [(tilesT T I A initial).thread]; ring

theorem ctx_groupT (i : Nat) : ((launchT T I A initial).ctxAt fuse 0 yy n (32 * s + i)).group = yy + 32 * n := by
  rw [(tilesT T I A initial).group_id]; ring

theorem ctx_arrT (i : Nat) :
    ((launchT T I A initial).ctxAt fuse 0 yy n (32 * s + i)).threadArray 0 = 9 + (128 * (yy + 32 * n) + 32 * s + i) := by
  rw [(tilesT T I A initial).threadArray]
  show 9 + 0 + ((0 + yy * 1 + n * 1 * 32) * (32 * 4) + (32 * s + i)) * 1 + 0 = _
  ring

end LaunchFacts

/-! ### The invariant -/

/-- `y` element `e` has been tput when its writer `yThread (e % 6144)` ran before thread `Th`, or is `Th`
and ran its first `tt` steps. -/
def yDone (Th tt e : Nat) : Prop := yThread (e % 6144) < Th ∨ yThread (e % 6144) = Th ∧ e / 6144 < tt

/-- `state_out` element `e` has been tput when its writer ran before thread `Th`. -/
def soDone (Th e : Nat) : Prop := soThread e < Th

/-- The inputs intact, every output element in `Y` (`y`) and `S` (`state_out`) holding its expected value,
and every access so far keeping the ownership discipline. -/
structure InvT (C : M1Max.Contract) (fuse : Nat → Bool) (T : Nat) (I : Ins) (A : Al)
    (initial : Nat → ByteMemory.Bytes) (Y S : Nat → Prop) (sh : Shared) : Prop where
  regions : sh.regions = (launchT T I A initial).regions
  inputs : Inputs I sh.bytes
  epoch : sh.deviceEpoch = 0
  y : ∀ b < 12288 * T, Y (b / 2) → sh.bytes 7 b = bytes2 (12288 * T) (ySteps C fuse I) b
  so : ∀ b < 3145728, S (b / 4) → sh.bytes 8 b = bytes4 3145728 (stateOut C fuse (stepAt C fuse I (T - 1))) b
  log : ∀ a ∈ sh.log, Owned (launchT T I A initial) devT tgo a

theorem yThread_mod (e : Nat) : yThread e % 32 = 0 := by unfold yThread; omega

theorem yThread_base {yy n s e : Nat}
    (h : yThread e = 128 * (yy + 32 * n) + 32 * s) : e = n * 128 + (4 * yy + s) := by
  unfold yThread at h; omega

/-- After lane 0's `y` store of step `t` (row `4 yy + s` of head `n`), the next step's `yDone`. -/
theorem yDone_next {yy n s t i e : Nat}
    (h : yDone (128 * (yy + 32 * n) + 32 * s) (t + 1) e) :
    yDone (128 * (yy + 32 * n) + 32 * s) (if i = 0 then t else t + 1) e ∨
      i = 0 ∧ e = 6144 * t + (n * 128 + (4 * yy + s)) := by
  by_cases hi : i = 0
  · rw [ite_eq_left hi]
    rcases h with h | ⟨h1, h2⟩
    · exact .inl (.inl h)
    · by_cases h3 : e / 6144 < t
      · exact .inl (.inr ⟨h1, h3⟩)
      · have := yThread_base h1
        exact .inr ⟨hi, by omega⟩
  · rw [ite_eq_right hi]; exact .inl h

/-- After lane `i`'s run of the last step `t` (`T = t + 1`), `yDone` of the next thread. -/
theorem yDone_last {yy n s t i e : Nat} (hi : i < 32) (he : e < 6144 * (t + 1))
    (h : yDone (128 * (yy + 32 * n) + 32 * s + (i + 1)) (if i + 1 = 0 then t else 0) e) :
    yDone (128 * (yy + 32 * n) + 32 * s + i) (if i = 0 then t else 0) e ∨
      i = 0 ∧ e = 6144 * t + (n * 128 + (4 * yy + s)) := by
  rw [ite_eq_right (by omega)] at h
  rcases h with h | ⟨-, h2⟩
  · by_cases h1 : yThread (e % 6144) < 128 * (yy + 32 * n) + 32 * s + i
    · exact .inl (.inl h1)
    · have h4 : yThread (e % 6144) = 128 * (yy + 32 * n) + 32 * s + i := by omega
      have h5 := yThread_mod (e % 6144)
      obtain rfl : i = 0 := by omega
      have := yThread_base h4
      by_cases h3 : e / 6144 < t
      · exact .inl (.inr ⟨h4, by rw [ite_eq_left rfl]; exact h3⟩)
      · exact .inr ⟨rfl, by omega⟩
  · omega

/-- The `state_out` elements lane `d` of SIMD-group `s` of threadgroup `(0, yy, n)` owns. -/
theorem soThread_lane {yy n s d e : Nat} (h : soThread e = 128 * (yy + 32 * n) + 32 * s + d) :
    (n * 128 + (4 * yy + s)) * 128 + 4 * d ≤ e ∧ e < (n * 128 + (4 * yy + s)) * 128 + 4 * d + 4 := by
  unfold soThread at h; omega

section Preserve
variable {C : M1Max.Contract} {fuse : Nat → Bool} {T : Nat} {I : Ins} {A : Al} {initial : Nat → ByteMemory.Bytes}
  {ctx : Ctx} {n r d : Nat} {J : Ins} {t : Nat} {Y S : Nat → Prop}

theorem InvT.mono {Y' S' : Nat → Prop} {sh : Shared} (h : InvT C fuse T I A initial Y S sh)
    (hy : ∀ e < 6144 * T, Y' e → Y e) (hs : ∀ e < 786432, S' e → S e) : InvT C fuse T I A initial Y' S' sh where
  regions := h.regions
  inputs := h.inputs
  epoch := h.epoch
  y := fun b hb hY => h.y b hb (hy _ (by omega) hY)
  so := fun b hb hS => h.so b hb (hs _ (by omega) hS)
  log := h.log

/-- Memory that only reads inputs and changes a thread array keeps the invariant. -/
theorem InvT.reads {sh sh' : Shared} (h : InvT C fuse T I A initial Y S sh) {x : Nat} (hx : 9 ≤ x)
    (hr : sh'.regions = sh.regions) (he : sh'.deviceEpoch = sh.deviceEpoch) (hb : ∀ z, z ≠ x → sh'.bytes z = sh.bytes z)
    (hl : ∀ a ∈ sh'.log, a ∈ sh.log ∨ (a.region < 7 ∧ a.write = false)) : InvT C fuse T I A initial Y S sh' where
  regions := hr.trans h.regions
  inputs := h.inputs.of fun z hz => hb z (by omega)
  epoch := he.trans h.epoch
  y := fun b hb' hY => by rw [hb 7 (by omega)]; exact h.y b hb' hY
  so := fun b hb' hS => by rw [hb 8 (by omega)]; exact h.so b hb' hS
  log := fun a ha => by
    rcases hl a ha with h1 | ⟨h1, h2⟩
    · exact h.log a h1
    · exact owned_readT T I A initial a h1 h2

theorem memAT_bytes {sh : Shared} {x : Nat} (hx : x ≠ ctx.threadArray 0) :
    (memAT C fuse ctx I n r d sh).bytes x = sh.bytes x :=
  (decayMemT_bytes hx 4).trans (loadMem_bytes hx 4)

theorem memAT_arr {sh : Shared} :
    Arr ((memAT C fuse ctx I n r d sh).bytes (ctx.threadArray 0)) (fun j => decayed C (stepAt C fuse I 0) n r (4 * d + j)) 4 :=
  (decayMemT_arr ((loadMem_arr 4 le_rfl).congr fun j _ => (stateIn_zero C fuse I n r (4 * d + j)).symm) 4 le_rfl).congr
    fun j hj => by simp [hj]

/-- Phase A keeps the invariant: it only reads the inputs. -/
theorem InvT.memA (ha : 9 ≤ ctx.threadArray 0) {sh : Shared} (h : InvT C fuse T I A initial Y S sh) :
    InvT C fuse T I A initial Y S (memAT C fuse ctx I n r d sh) :=
  h.reads ha ((decayMemT_regions 4).trans (loadMem_regions 4)) ((decayMemT_epoch 4).trans (loadMem_epoch 4))
    (fun z hz => memAT_bytes hz) fun a ha' => by
      rcases decayMemT_log 4 a ha' with h1 | h1
      · rcases loadMem_log 4 a h1 with h2 | ⟨h2, hw⟩
        · rcases logged_log a h2 with h3 | ⟨h3, hw, -⟩
          · exact .inl h3
          · exact .inr ⟨by omega, hw⟩
        · exact .inr ⟨by omega, hw⟩
      · exact .inr h1

/-- Phase B keeps the invariant: it only reads the inputs. -/
theorem InvT.memB (ha : 9 ≤ ctx.threadArray 0) {sh : Shared} (h : InvT C fuse T I A initial Y S sh) :
    InvT C fuse T I A initial Y S (updateMemT C fuse ctx J n r d t (deltaMemT ctx n r t sh) 4) :=
  h.reads ha (updateMemT_regions 4) (updateMemT_epoch 4) (fun z hz => updateMemT_bytes hz 4) fun a ha' => by
    rcases updateMemT_log 4 a ha' with h1 | h1
    · rcases logged_log a h1 with h2 | ⟨h2, hw, -⟩
      · rcases logged_log a h2 with h3 | ⟨h3, hw, -⟩
        · exact .inl h3
        · exact .inr ⟨by omega, hw⟩
      · exact .inr ⟨by omega, hw⟩
    · exact .inr h1

/-- The decay loop keeps the invariant: it only reads the inputs. -/
theorem InvT.decay (ha : 9 ≤ ctx.threadArray 0) {sh : Shared} (h : InvT C fuse T I A initial Y S sh) :
    InvT C fuse T I A initial Y S (decayMemT C ctx J n r d t sh 4) :=
  h.reads ha (decayMemT_regions 4) (decayMemT_epoch 4) (fun _ hz => decayMemT_bytes hz 4) fun a ha' =>
    decayMemT_log 4 a ha'

/-- Lane `d`'s `y` store at step `t` writes its row's element of step `t` (lane 0). -/
theorem InvT.ystore {yy s : Nat} (hy : yy < 32) (hs : s < 4) (hn : n < 48) (hr : r = 4 * yy + s)
    (hth : ctx.thread = 128 * (yy + 32 * n) + 32 * s + d) (hg : ctx.group = yy + 32 * n) {sh : Shared}
    (h : InvT C fuse T I A initial Y S sh) :
    InvT C fuse T I A initial (fun e => Y e ∨ d = 0 ∧ e = 6144 * t + (n * 128 + r)) S
      (yMemT C fuse ctx (stepAt C fuse I t) n r d t sh) where
  regions := yMemT_regions.trans h.regions
  inputs := h.inputs.of fun x hx => yMemT_bytes (by omega)
  epoch := yMemT_epoch.trans h.epoch
  y := fun b hb hY => by
    rw [yMemT_out]
    by_cases hw : d = 0 ∧ 2 * (6144 * t + n * 128 + r) ≤ b ∧ b < 2 * (6144 * t + n * 128 + r) + 2
    · rw [ite_eq_left hw.1]
      obtain ⟨i, hi, rfl⟩ : ∃ i, i < 2 ∧ b = 2 * (6144 * t + n * 128 + r) + i :=
        ⟨b - 2 * (6144 * t + n * 128 + r), by omega, by omega⟩
      rw [writeBytes_inside _ _ _ i (by rw [wordBytes_length]; exact hi)]
      unfold bytes2 ySteps yOut
      rw [ite_eq_left hb, show (2 * (6144 * t + n * 128 + r) + i) / 2 = 6144 * t + n * 128 + r by omega,
        show (2 * (6144 * t + n * 128 + r) + i) % 2 = i by omega, show (6144 * t + n * 128 + r) / 6144 = t by omega,
        show (6144 * t + n * 128 + r) % 6144 = n * 128 + r by omega, show (n * 128 + r) / 128 = n by omega,
        show (n * 128 + r) % 128 = r by omega]
    · have hold : (if d = 0 then writeBytes (sh.bytes 7) (2 * (6144 * t + n * 128 + r))
          (wordBytes 2 (Val.bf16Bits (C.narrow (outSum C fuse (stepAt C fuse I t) n r)))) else sh.bytes 7) b =
            sh.bytes 7 b := by
        split
        · exact writeBytes_outside _ _ _ _ (by rw [wordBytes_length]; omega)
        · rfl
      rw [hold]
      rcases hY with hY | ⟨hd0, he⟩
      · exact h.y b hb hY
      · exact absurd ⟨hd0, by omega, by omega⟩ hw
  so := fun b hb hS => by rw [yMemT_bytes (by decide)]; exact h.so b hb hS
  log := fun a ha => by
    rcases yMemT_log a ha with h1 | ⟨hd0, h1, -, h3, h4, h5, h6, h7⟩
    · exact h.log a h1
    · refine owned_writeT T I A initial a (.inl h1) (128 * (yy + 32 * n) + 32 * s) ?_
        (by rw [h3, hth, hd0, Nat.add_zero]) (by rw [h4, hg]; omega) (h5.trans h.epoch)
      rw [h1]
      show some (writer (yThread (a.byte / 2 % 6144))) = _
      congr 2
      unfold yThread
      omega

/-- Lane `d`'s state stores after the last step. -/
theorem InvT.sostore {yy s : Nat} (hy : yy < 32) (hs : s < 4) (hd : d < 32) (hr : r = 4 * yy + s)
    (hth : ctx.thread = 128 * (yy + 32 * n) + 32 * s + d) (hg : ctx.group = yy + 32 * n) {sh : Shared}
    (h : InvT C fuse T I A initial Y S sh) :
    InvT C fuse T I A initial Y
      (fun e => S e ∨ (n * 128 + r) * 128 + 4 * d ≤ e ∧ e < (n * 128 + r) * 128 + 4 * d + 4)
      (storeMem C fuse ctx (stepAt C fuse I (T - 1)) n r d sh 4) where
  regions := (storeMem_regions 4).trans h.regions
  inputs := h.inputs.of fun x hx => storeMem_bytes (by omega) 4
  epoch := (storeMem_epoch 4).trans h.epoch
  y := fun b hb hY => by rw [storeMem_bytes (by decide) 4]; exact h.y b hb hY
  so := fun b hb hS => by
    rw [storeMem_out]
    by_cases hw : 4 * ((n * 128 + r) * 128 + 4 * d) ≤ b ∧ b < 4 * ((n * 128 + r) * 128 + 4 * d + 4)
    · exact wrote4_bytes4 hb hw (fun j hj => stateOut_eq (by omega) hd hj)
    · unfold wrote4; rw [ite_eq_right (by omega)]
      rcases hS with hS | hS
      · exact h.so b hb hS
      · exact absurd ⟨by omega, by omega⟩ hw
  log := fun a ha => by
    rcases storeMem_log 4 a ha with h1 | ⟨h1, h2, h3, h4, h5, h6⟩
    · exact h.log a h1
    · refine owned_writeT T I A initial a (.inr h1) (128 * (yy + 32 * n) + 32 * s + d) ?_ (h2.trans hth)
        (by rw [h3, hg]; omega) (h4.trans h.epoch)
      rw [h1, ← (soThread_eq (b := a.byte) (yy := yy) (n := n) (s := s) (d := d)).mpr
        ⟨by subst hr; omega, by subst hr; omega⟩]
      rfl

end Preserve

/-! ## SIMD-groups, threadgroups and the launch -/

section Run
variable {C : M1Max.Contract} {fuse : Nat → Bool} {T : Nat} {I : Ins} {A : Al} {initial : Nat → ByteMemory.Bytes}

theorem regs_ofT (hA : A.Ok) {yy n s : Nat} (i : Nat) {sh : Shared} (hr : sh.regions = (launchT T I A initial).regions) :
    RegsT T ((launchT T I A initial).ctxAt fuse 0 yy n (32 * s + i)) A sh.regions :=
  ⟨by rw [hr]; rfl, by rw [hr]; rfl, by rw [hr]; rfl, by rw [hr]; rfl, by rw [hr]; rfl, by rw [hr]; rfl,
    by rw [hr]; rfl, by rw [hr]; rfl, by rw [hr]; rfl, by rw [hr, ctx_arrT]; exact launchT_rt T I A initial _,
    by rw [ctx_arrT]; omega, hA⟩

variable (C fuse T I A initial) in
/-- Lane `i` of SIMD-group `s` of threadgroup `(0, yy, n)` stopped at the first `simd_sum` of step `t`. -/
def AtKv (yy n s t i : Nat) (u : Thread) : Prop :=
  ∃ L', u = ⟨(launchT T I A initial).ctxAt fuse 0 yy n (32 * s + i), L', [.block restA, loopFrame, .block tail],
    .collective 2 30 .sum .f32 (.f32 (kvPart C fuse (stepAt C fuse I t) n (4 * yy + s) i 4)) 0⟩ ∧
    PreT ((launchT T I A initial).ctxAt fuse 0 yy n (32 * s + i)) T n (4 * yy + s) i t L'

variable (C fuse T I A initial) in
/-- … stopped at the second `simd_sum` of step `t`. -/
def AtOut (yy n s t i : Nat) (u : Thread) : Prop :=
  ∃ L', u = ⟨(launchT T I A initial).ctxAt fuse 0 yy n (32 * s + i), L', [.block restB, loopFrame, .block tail],
    .collective 5 35 .sum .f32 (.f32 (outPart C fuse (stepAt C fuse I t) n (4 * yy + s) i 4)) 0⟩ ∧
    PreT ((launchT T I A initial).ctxAt fuse 0 yy n (32 * s + i)) T n (4 * yy + s) i t L'

/-- The SIMD-group's thread arrays: lane `j`'s holds `v j (4 j + c)` at element `c`. -/
def Arrs (yy n s : Nat) (v : Nat → Nat → Float32) (sh : Shared) : Prop :=
  ∀ j : Fin 32, Arr (sh.bytes (9 + (128 * (yy + 32 * n) + 32 * s + j))) (fun c => v j (4 * j + c)) 4

/-- Phase B of step `t` for a SIMD-group: every lane from the first `simd_sum` to the second. -/
theorem simd_B (hA : A.Ok) {yy n s t : Nat} (hy : yy < 32) (hn : n < 48) (hs : s < 4) (ht : t < T)
    {Y S : Nat → Prop} (U : Fin 32 → Thread) (hU : ∀ i : Fin 32, AtKv C fuse T I A initial yy n s t i (U i)) (sh : Shared)
    (hI : InvT C fuse T I A initial Y S sh)
    (ha : Arrs yy n s (fun _ c => decayed C (stepAt C fuse I t) n (4 * yy + s) c) sh) :
    ∃ (U2 : Fin 32 → Thread) (sh2 : Shared), (∃ N, ∀ m ≥ N,
      ((List.ofFn fun i => { U i with status := .running }.set 30
        (.f32 (kvMem C fuse (stepAt C fuse I t) n (4 * yy + s)))).mapM (runThread C m)).run sh =
          some (List.ofFn U2, sh2)) ∧
      InvT C fuse T I A initial Y S sh2 ∧ Arrs yy n s (fun _ c => updated C fuse (stepAt C fuse I t) n (4 * yy + s) c) sh2 ∧
      ∀ i : Fin 32, AtOut C fuse T I A initial yy n s t i (U2 i) := by
  obtain ⟨U2, sh2, hN, ⟨hI2, hA2⟩, hU2⟩ := mapM_ofFn_ev
    (fun i => { U i with status := .running }.set 30 (.f32 (kvMem C fuse (stepAt C fuse I t) n (4 * yy + s))))
    (runThread C)
    (fun i sh => InvT C fuse T I A initial Y S sh ∧
      Arrs yy n s (fun j c => if j < i then updated C fuse (stepAt C fuse I t) n (4 * yy + s) c
        else decayed C (stepAt C fuse I t) n (4 * yy + s) c) sh)
    (fun i u => AtOut C fuse T I A initial yy n s t i u)
    (fun i sh hI => by
      have ha := ctx_arrT T I A initial fuse (yy := yy) (n := n) (s := s) i
      obtain ⟨L, hLU, hp⟩ := hU i
      dsimp only
      rw [hLU]
      have h0 : Arr (sh.bytes (((launchT T I A initial).ctxAt fuse 0 yy n (32 * s + i)).threadArray 0))
          (fun c => decayed C (stepAt C fuse I t) n (4 * yy + s) (4 * i + c)) 4 := by
        rw [ha]; exact (hI.2 i).congr fun c _ => by simp
      obtain ⟨L', ⟨N, hN⟩, hp'⟩ := phaseBT (C := C) (ctx_laneT T I A initial fuse hy hn hs i)
        (regs_ofT hA i hI.1.regions) hI.1.inputs (slice_at C fuse I t) ht h0 L hp
      refine ⟨_, _, ⟨N, hN⟩, ⟨hI.1.memB (by rw [ha]; omega), fun j => ?_⟩, L', rfl, hp'⟩
      by_cases hji : j = i
      · subst hji; rw [← ha]
        exact (updateMemT_arr (fuse := fuse) (t := t) h0 4 le_rfl).congr fun c hc => by simp [hc]
      · have hj : j.val ≠ i.val := fun e => hji (Fin.ext e)
        rw [updateMemT_bytes (by omega) 4]
        exact (hI.2 j).congr fun c _ => by
          by_cases h1 : j.val < i.val
          · simp [h1, show j.val < i.val + 1 by omega]
          · simp [h1, show ¬ j.val < i.val + 1 by omega])
    sh ⟨hI, fun j => (ha j).congr fun c _ => by simp⟩
  exact ⟨U2, sh2, hN, hI2, fun j => (hA2 j).congr fun c _ => by simp [j.isLt], hU2⟩

/-- Phase C of step `t` for a SIMD-group, `t + 1 < T`: every lane from the second `simd_sum` to the first of
step `t + 1`. -/
theorem simd_Cn (hA : A.Ok) {yy n s t : Nat} (hy : yy < 32) (hn : n < 48) (hs : s < 4) (ht : t + 1 < T)
    (hT2 : T < 2 ^ 31) (U2 : Fin 32 → Thread) (hU : ∀ i : Fin 32, AtOut C fuse T I A initial yy n s t i (U2 i)) (sh : Shared)
    (hI : InvT C fuse T I A initial (yDone (128 * (yy + 32 * n) + 32 * s) t) (soDone (128 * (yy + 32 * n) + 32 * s)) sh)
    (ha : Arrs yy n s (fun _ c => updated C fuse (stepAt C fuse I t) n (4 * yy + s) c) sh) :
    ∃ (U3 : Fin 32 → Thread) (sh3 : Shared), (∃ N, ∀ m ≥ N,
      ((List.ofFn fun i => { U2 i with status := .running }.set 35
        (.f32 (outSum C fuse (stepAt C fuse I t) n (4 * yy + s)))).mapM (runThread C m)).run sh =
          some (List.ofFn U3, sh3)) ∧
      InvT C fuse T I A initial (yDone (128 * (yy + 32 * n) + 32 * s) (t + 1)) (soDone (128 * (yy + 32 * n) + 32 * s))
        sh3 ∧
      Arrs yy n s (fun _ c => decayed C (stepAt C fuse I (t + 1)) n (4 * yy + s) c) sh3 ∧
      ∀ i : Fin 32, AtKv C fuse T I A initial yy n s (t + 1) i (U3 i) := by
  obtain ⟨U3, sh3, hN, ⟨hI3, hA3⟩, hU3⟩ := mapM_ofFn_ev
    (fun i => { U2 i with status := .running }.set 35 (.f32 (outSum C fuse (stepAt C fuse I t) n (4 * yy + s))))
    (runThread C)
    (fun i sh => InvT C fuse T I A initial (yDone (128 * (yy + 32 * n) + 32 * s) (if i = 0 then t else t + 1))
      (soDone (128 * (yy + 32 * n) + 32 * s)) sh ∧
      Arrs yy n s (fun j c => if j < i then decayed C (stepAt C fuse I (t + 1)) n (4 * yy + s) c
        else stateIn (stepAt C fuse I (t + 1)) n (4 * yy + s) c) sh)
    (fun i u => AtKv C fuse T I A initial yy n s (t + 1) i u)
    (fun i sh hI => by
      have ha := ctx_arrT T I A initial fuse (yy := yy) (n := n) (s := s) i
      have hi := i.isLt
      obtain ⟨L, hLU, hp⟩ := hU i
      dsimp only
      rw [hLU]
      have h0 : Arr (sh.bytes (((launchT T I A initial).ctxAt fuse 0 yy n (32 * s + i)).threadArray 0))
          (fun c => stateIn (stepAt C fuse I (t + 1)) n (4 * yy + s) (4 * i + c)) 4 := by
        rw [ha]; exact (hI.2 i).congr fun c _ => by simp
      obtain ⟨L', ⟨N, hN⟩, hp'⟩ := phaseCT_next (C := C) (J := stepAt C fuse I t)
        (ctx_laneT T I A initial fuse hy hn hs i) (regs_ofT hA i hI.1.regions) hI.1.inputs (slice_at C fuse I (t + 1))
        ht hT2 h0 L hp
      have hy' := hI.1.ystore (C := C) (t := t) (ctx := (launchT T I A initial).ctxAt fuse 0 yy n (32 * s + i)) hy hs hn
        rfl (ctx_threadT T I A initial fuse i) (ctx_groupT T I A initial fuse i)
      refine ⟨_, _, ⟨N, hN⟩, ⟨(hy'.decay (by rw [ha]; omega)).mono (fun e _ he => yDone_next he)
        (fun e _ he => he), fun j => ?_⟩, L', rfl, hp'⟩
      by_cases hji : j = i
      · subst hji; rw [← ha]
        refine (decayMemT_arr (C := C) (t := t + 1) ?_ 4 le_rfl).congr fun c hc => by simp [hc]
        rw [yMemT_bytes (by omega)]; exact h0
      · have hj : j.val ≠ i.val := fun e => hji (Fin.ext e)
        rw [decayMemT_bytes (by omega) 4, yMemT_bytes (by omega)]
        exact (hI.2 j).congr fun c _ => by
          by_cases h1 : j.val < i.val
          · simp [h1, show j.val < i.val + 1 by omega]
          · simp [h1, show ¬ j.val < i.val + 1 by omega])
    sh ⟨hI, fun j => (ha j).congr fun c hc => by
      simp only [Nat.not_lt_zero, ite_false]
      exact (stateIn_succ C fuse I t hn (by omega) (by omega)).symm⟩
  rw [ite_eq_right (show ¬ (32 : Nat) = 0 by decide)] at hI3
  exact ⟨U3, sh3, hN, hI3, fun j => (hA3 j).congr fun c _ => by simp [j.isLt], hU3⟩

/-- Phase C of the last step `t` (`t + 1 = T`) for a SIMD-group: every lane from the second `simd_sum` to the
end. -/
theorem simd_Cl (hA : A.Ok) {yy n s t : Nat} (hy : yy < 32) (hn : n < 48) (hs : s < 4) (ht : t + 1 = T)
    (hT2 : T < 2 ^ 31) (U2 : Fin 32 → Thread) (hU : ∀ i : Fin 32, AtOut C fuse T I A initial yy n s t i (U2 i)) (sh : Shared)
    (hI : InvT C fuse T I A initial (yDone (128 * (yy + 32 * n) + 32 * s) t) (soDone (128 * (yy + 32 * n) + 32 * s)) sh)
    (ha : Arrs yy n s (fun _ c => updated C fuse (stepAt C fuse I t) n (4 * yy + s) c) sh) :
    ∃ (V : Fin 32 → Thread) (sh3 : Shared), (∃ N, ∀ m ≥ N,
      ((List.ofFn fun i => { U2 i with status := .running }.set 35
        (.f32 (outSum C fuse (stepAt C fuse I t) n (4 * yy + s)))).mapM (runThread C m)).run sh =
          some (List.ofFn V, sh3)) ∧
      InvT C fuse T I A initial (yDone (128 * (yy + 32 * n) + 32 * s + 32) 0) (soDone (128 * (yy + 32 * n) + 32 * s + 32))
        sh3 ∧ ∀ i, (V i).status = .done := by
  obtain ⟨V, sh3, hN, ⟨hI3, -⟩, hV⟩ := mapM_ofFn_ev
    (fun i => { U2 i with status := .running }.set 35 (.f32 (outSum C fuse (stepAt C fuse I t) n (4 * yy + s))))
    (runThread C)
    (fun i sh => InvT C fuse T I A initial (yDone (128 * (yy + 32 * n) + 32 * s + i) (if i = 0 then t else 0))
      (soDone (128 * (yy + 32 * n) + 32 * s + i)) sh ∧
      Arrs yy n s (fun _ c => updated C fuse (stepAt C fuse I t) n (4 * yy + s) c) sh)
    (fun _ u => u.status = .done)
    (fun i sh hI => by
      have ha := ctx_arrT T I A initial fuse (yy := yy) (n := n) (s := s) i
      have hi := i.isLt
      obtain ⟨L, hLU, hp⟩ := hU i
      dsimp only
      rw [hLU]
      have h0 : Arr (sh.bytes (((launchT T I A initial).ctxAt fuse 0 yy n (32 * s + i)).threadArray 0))
          (fun c => updated C fuse (stepAt C fuse I t) n (4 * yy + s) (4 * i + c)) 4 := by
        rw [ha]; exact hI.2 i
      obtain ⟨L', N, hN⟩ := phaseCT_last (C := C) (J := stepAt C fuse I t)
        (ctx_laneT T I A initial fuse hy hn hs i) (regs_ofT hA i hI.1.regions) ht hT2 h0 L hp
      have hy' := hI.1.ystore (C := C) (t := t) (ctx := (launchT T I A initial).ctxAt fuse 0 yy n (32 * s + i)) hy hs hn
        rfl (ctx_threadT T I A initial fuse i) (ctx_groupT T I A initial fuse i)
      have hs' := hy'.sostore (C := C) (ctx := (launchT T I A initial).ctxAt fuse 0 yy n (32 * s + i)) hy hs i.isLt
        rfl (ctx_threadT T I A initial fuse i) (ctx_groupT T I A initial fuse i)
      rw [show T - 1 = t by omega] at hs'
      refine ⟨_, _, ⟨N, hN⟩, ⟨hs'.mono (fun e he hY => yDone_last hi (by rw [← ht] at he; exact he) hY)
        (fun e _ he => ?_), fun j => ?_⟩, rfl⟩
      · unfold soDone at he ⊢
        by_cases h1 : soThread e < 128 * (yy + 32 * n) + 32 * s + i
        · exact .inl h1
        · exact .inr (soThread_lane (show soThread e = 128 * (yy + 32 * n) + 32 * s + i by omega))
      · rw [storeMem_bytes (by omega) 4, yMemT_bytes (by omega)]
        exact hI.2 j)
    sh ⟨hI, ha⟩
  rw [ite_eq_right (show ¬ (32 : Nat) = 0 by decide)] at hI3
  exact ⟨V, sh3, hN, hI3, hV⟩

/-- A SIMD-group resumed with the row's `kv_mem` at step `t` runs to the end, `2 (T - t)` rounds. -/
theorem simd_steps (hA : A.Ok) (hT2 : T < 2 ^ 31) {yy n s : Nat} (hy : yy < 32) (hn : n < 48) (hs : s < 4) (k : Nat) :
    ∀ t, t + k + 1 = T → ∀ (U : Fin 32 → Thread) (sh : Shared), (∀ i : Fin 32, AtKv C fuse T I A initial yy n s t i (U i)) →
      InvT C fuse T I A initial (yDone (128 * (yy + 32 * n) + 32 * s) t) (soDone (128 * (yy + 32 * n) + 32 * s)) sh →
      Arrs yy n s (fun _ c => decayed C (stepAt C fuse I t) n (4 * yy + s) c) sh →
      ∃ (V : Fin 32 → Thread) (sh' : Shared), (∃ N, ∀ m ≥ N,
        (runSimd C m (2 * k + 2) (List.ofFn fun i => { U i with status := .running }.set 30
          (.f32 (kvMem C fuse (stepAt C fuse I t) n (4 * yy + s))))).run sh = some (List.ofFn V, sh')) ∧
        InvT C fuse T I A initial (yDone (128 * (yy + 32 * n) + 32 * s + 32) 0)
          (soDone (128 * (yy + 32 * n) + 32 * s + 32)) sh' ∧ ∀ i, (V i).status = .done := by
  induction k with
  | zero =>
    intro t ht U sh hU hI ha
    obtain ⟨U2, sh2, ⟨N2, hN2⟩, hI2, ha2, hU2⟩ := simd_B hA hy hn hs (by omega) U hU sh hI ha
    obtain ⟨V, sh3, ⟨N3, hN3⟩, hI3, hV⟩ := simd_Cl hA hy hn hs (by omega) hT2 U2 hU2 sh2 hI2 ha2
    refine ⟨V, sh3, ⟨max N2 N3, fun m hm => ?_⟩, hI3, hV⟩
    rw [show 2 * 0 + 2 = 1 + 1 from rfl, runSimd_collective_ofFn C m 1 _ U2 sh sh2 5 35 .sum .f32 0
      (fun i => .f32 (outPart C fuse (stepAt C fuse I t) n (4 * yy + s) i 4))
      (fun _ => .f32 (outSum C fuse (stepAt C fuse I t) n (4 * yy + s))) (hN2 m (by omega))
      (fun i => by obtain ⟨L, h, -⟩ := hU2 i; rw [h]) (resolve_sum C 0 _)]
    exact runSimd_blocked_ofFn C m 0 _ V sh2 sh3 (hN3 m (by omega)) (fun i => by rw [hV i]; rfl)
  | succ k ih =>
    intro t ht U sh hU hI ha
    obtain ⟨U2, sh2, ⟨N2, hN2⟩, hI2, ha2, hU2⟩ := simd_B hA hy hn hs (by omega) U hU sh hI ha
    obtain ⟨U3, sh3, ⟨N3, hN3⟩, hI3, ha3, hU3⟩ := simd_Cn hA hy hn hs (by omega) hT2 U2 hU2 sh2 hI2 ha2
    obtain ⟨V, sh4, ⟨N4, hN4⟩, hI4, hV⟩ := ih (t + 1) (by omega) U3 sh3 hU3 hI3 ha3
    refine ⟨V, sh4, ⟨max N2 (max N3 N4), fun m hm => ?_⟩, hI4, hV⟩
    rw [show 2 * (k + 1) + 2 = 2 * k + 3 + 1 by ring, runSimd_collective_ofFn C m (2 * k + 3) _ U2 sh sh2 5 35 .sum .f32 0
      (fun i => .f32 (outPart C fuse (stepAt C fuse I t) n (4 * yy + s) i 4))
      (fun _ => .f32 (outSum C fuse (stepAt C fuse I t) n (4 * yy + s))) (hN2 m (by omega))
      (fun i => by obtain ⟨L, h, -⟩ := hU2 i; rw [h]) (resolve_sum C 0 _)]
    rw [show 2 * k + 3 = 2 * k + 2 + 1 by ring, runSimd_collective_ofFn C m (2 * k + 2) _ U3 sh2 sh3 2 30 .sum .f32 0
      (fun i => .f32 (kvPart C fuse (stepAt C fuse I (t + 1)) n (4 * yy + s) i 4))
      (fun _ => .f32 (kvMem C fuse (stepAt C fuse I (t + 1)) n (4 * yy + s))) (hN3 m (by omega))
      (fun i => by obtain ⟨L, h, -⟩ := hU3 i; rw [h]) (resolve_sum C 0 _)]
    exact hN4 m (by omega)

/-- A SIMD-group: every lane runs to the first `simd_sum` of step 0, then through the `T` steps. -/
theorem simd_runT (hA : A.Ok) (hT : TWord I.t T) (hT1 : 1 ≤ T) (hT2 : T < 2 ^ 31) {yy n s : Nat} (hy : yy < 32)
    (hn : n < 48) (hs : s < 4) (sh : Shared)
    (hI : InvT C fuse T I A initial (yDone (128 * (yy + 32 * n) + 32 * s) 0) (soDone (128 * (yy + 32 * n) + 32 * s)) sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared), (∃ N, ∀ m ≥ N,
      (runSimd C m (2 * T + 1) (List.ofFn ((launchT T I A initial).lanes fuse 0 yy n s))).run sh =
        some (List.ofFn V, sh')) ∧
      InvT C fuse T I A initial (yDone (128 * (yy + 32 * n) + 32 * s + 32) 0) (soDone (128 * (yy + 32 * n) + 32 * s + 32))
        sh' ∧ ∀ i, (V i).status = .done := by
  obtain ⟨U, sh1, ⟨N1, hN1⟩, ⟨hI1, hA1⟩, hU⟩ := mapM_ofFn_ev ((launchT T I A initial).lanes fuse 0 yy n s) (runThread C)
    (fun i sh => InvT C fuse T I A initial (yDone (128 * (yy + 32 * n) + 32 * s) 0)
      (soDone (128 * (yy + 32 * n) + 32 * s)) sh ∧
      ∀ j < i, Arr (sh.bytes (9 + (128 * (yy + 32 * n) + 32 * s + j)))
        (fun c => decayed C (stepAt C fuse I 0) n (4 * yy + s) (4 * j + c)) 4)
    (fun i u => AtKv C fuse T I A initial yy n s 0 i u)
    (fun i sh hI => by
      have ha := ctx_arrT T I A initial fuse (yy := yy) (n := n) (s := s) i
      obtain ⟨L', ⟨N, hN⟩, hp⟩ := phaseAT (C := C) (ctx_laneT T I A initial fuse hy hn hs i)
        (regs_ofT hA i hI.1.regions) hI.1.inputs hT hT1 hT2
      refine ⟨_, _, ⟨N, hN⟩, ⟨hI.1.memA (by rw [ha]; omega), fun j hj => ?_⟩, L', rfl, hp⟩
      rcases Nat.lt_succ_iff_lt_or_eq.mp hj with hj | rfl
      · rw [memAT_bytes (by omega)]; exact hI.2 j hj
      · rw [← ha]; exact memAT_arr)
    sh ⟨hI, fun j hj => absurd hj (by omega)⟩
  obtain ⟨V, sh', ⟨N2, hN2⟩, hI', hV⟩ := simd_steps hA hT2 hy hn hs (T - 1) 0 (by omega) U sh1 hU hI1
    (fun j => hA1 j j.isLt)
  refine ⟨V, sh', ⟨max N1 N2, fun m hm => ?_⟩, hI', hV⟩
  rw [show 2 * T + 1 = 2 * (T - 1) + 2 + 1 by omega, runSimd_collective_ofFn C m (2 * (T - 1) + 2) _ U sh sh1 2 30 .sum
    .f32 0 (fun i => .f32 (kvPart C fuse (stepAt C fuse I 0) n (4 * yy + s) i 4))
    (fun _ => .f32 (kvMem C fuse (stepAt C fuse I 0) n (4 * yy + s))) (hN1 m (by omega))
    (fun i => by obtain ⟨L, h, -⟩ := hU i; rw [h]) (resolve_sum C 0 _)]
  exact hN2 m (by omega)

/-- A threadgroup: its four SIMD-groups, one after another. -/
theorem group_runT (hA : A.Ok) (hT : TWord I.t T) (hT1 : 1 ≤ T) (hT2 : T < 2 ^ 31) {yy n : Nat} (hy : yy < 32)
    (hn : n < 48) (sh : Shared)
    (hI : InvT C fuse T I A initial (yDone (128 * (yy + 32 * n)) 0) (soDone (128 * (yy + 32 * n))) sh) :
    ∃ sh', (∃ N, ∀ m ≥ N, (runGroup C m (2 * T + 1) 1 (List.ofFn fun s : Fin 4 =>
      List.ofFn ((launchT T I A initial).lanes fuse 0 yy n s))).run sh = some ((), sh')) ∧
      InvT C fuse T I A initial (yDone (128 * (yy + 32 * n + 1)) 0) (soDone (128 * (yy + 32 * n + 1))) sh' := by
  obtain ⟨W, sh', ⟨N, hN⟩, hI', hW⟩ := mapM_ofFn_ev
    (fun s : Fin 4 => List.ofFn ((launchT T I A initial).lanes fuse 0 yy n s))
    (runSimd C · (2 * T + 1)) (fun s sh => InvT C fuse T I A initial (yDone (128 * (yy + 32 * n) + 32 * s) 0)
      (soDone (128 * (yy + 32 * n) + 32 * s)) sh)
    (fun _ u => ∃ V : Fin 32 → Thread, u = List.ofFn V ∧ ∀ i, (V i).status = .done)
    (fun s sh hI => by
      obtain ⟨V, sh', ⟨N, hN⟩, hI', hV⟩ := simd_runT hA hT hT1 hT2 hy hn s.isLt sh hI
      have hI'' : InvT C fuse T I A initial (yDone (128 * (yy + 32 * n) + 32 * (s.val + 1)) 0)
          (soDone (128 * (yy + 32 * n) + 32 * (s.val + 1))) sh' := by
        rw [show 128 * (yy + 32 * n) + 32 * (s.val + 1) = 128 * (yy + 32 * n) + 32 * s + 32 by ring]; exact hI'
      exact ⟨_, sh', ⟨N, hN⟩, hI'', V, rfl, hV⟩)
    sh hI
  choose V hV using hW
  refine ⟨sh', ⟨N, fun m hm => ?_⟩, by
    rw [show 128 * (yy + 32 * n + 1) = 128 * (yy + 32 * n) + 32 * 4 by ring]; exact hI'⟩
  refine runGroup_done_ofFn C m (2 * T + 1) 0 _ V sh sh' ?_ (fun j i => (hV j).2 i)
  rw [hN m hm, show W = fun j => List.ofFn (V j) from funext fun j => (hV j).1]

theorem inv_initialT (garbage : Garbage) :
    InvT C fuse T I A initial (yDone 0 0) (soDone 0) ((launchT T I A initial).initial garbage) where
  regions := rfl
  inputs := ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
  epoch := rfl
  y := fun _ _ ho => by unfold yDone at ho; omega
  so := fun _ _ ho => absurd ho (Nat.not_lt_zero _)
  log := fun _ ha => by simp [Launch.initial] at ha

/-- The launch: its 32 × 48 threadgroups in order. -/
theorem launch_okT (hA : A.Ok) (hT : TWord I.t T) (hT1 : 1 ≤ T) (hT2 : T < 2 ^ 31) (garbage : Garbage) :
    ∃ sh fuel, InvT C fuse T I A initial (yDone (128 * (1 * 32 * 48)) 0) (soDone (128 * (1 * 32 * 48))) sh ∧
      runLaunch C fuse (launchT T I A initial) garbage fuel (2 * T + 1) 1 = some ⟨sh.bytes, sh.log⟩ :=
  launch_run_fuel C (tilesT T I A initial) fuse garbage (2 * T + 1) 1
    (fun g sh => InvT C fuse T I A initial (yDone (128 * g) 0) (soDone (128 * g)) sh) (inv_initialT garbage)
    (fun bx byy bz hx hy hz sh hI => by
      obtain rfl : bx = 0 := by omega
      rw [show 0 + byy * 1 + bz * 1 * 32 = byy + 32 * bz by ring] at hI ⊢
      rw [Launch.resetGroup_none _ _ _ _ rfl]
      exact group_runT hA hT hT1 hT2 hy hz sh hI)

end Run

/-! ## The GPU theorem -/

theorem clip_eqT (T : Nat) (Y S : ByteMemory.Bytes) (hY : ∀ b, 12288 * T ≤ b → Y b = 0)
    (hS : ∀ b, 3145728 ≤ b → S b = 0) :
    clip [12288 * T, 3145728] (fun i => [Y, S].getD i (fun _ => 0)) = [Y, S] := by
  unfold clip
  rw [show [12288 * T, 3145728].zipIdx = [(12288 * T, 0), (3145728, 1)] from rfl]
  simp only [List.map_cons, List.map_nil, List.cons.injEq, and_true]
  refine ⟨?_, ?_⟩ <;> funext b <;> split
  · rfl
  · exact (hY b (by omega)).symm
  · rfl
  · exact (hS b (by omega)).symm

variable (C : M1Max.Contract)

/-- **The GPU runs gated_delta_step over `T` time steps as specified.** Under the GPU assumption, MLX's launch
of the exact assembled text at the route's prefill configuration (B = 1, `T` positions, grid (32, 128, 48),
threadgroup (32, 4, 1)) on any `q`, `k`, `v`, `g`, `beta`, `state_in` (base addresses aligned to their element
sizes) and a `Tin` buffer holding the int32 `T`, `1 ≤ T < 2^31`, produces `y` whose time-step-`t` slice is the
one-step kernel's `yOut` on step `t`'s slices of the inputs and the state after `t` steps, and `state_out` the
last step's `stateOut` (`stepAt`: each step's state is the previous step's `state_out`) — at the compiler's
contraction choices at the three accumulations. -/
theorem gpu_output_steps (G : Gpu C) (hmax : 128 ≤ G.maxThreads Metal.Elab.Tests.gatedDeltaStepText)
    (T : Nat) (hT1 : 1 ≤ T) (hT2 : T < 2 ^ 31)
    (q k v g beta s t : ByteMemory.Bytes) (aq ak av ag ab as aT : Nat)
    (hq : 2 ∣ aq) (hk : 2 ∣ ak) (hv : 2 ∣ av) (hg : 4 ∣ ag) (hb : 2 ∣ ab) (hs : 4 ∣ as) (ht : 4 ∣ aT)
    (hT : t 0 = BitVec.ofNat 8 T ∧ t 1 = BitVec.ofNat 8 (T / 2 ^ 8) ∧ t 2 = BitVec.ofNat 8 (T / 2 ^ 16) ∧
      t 3 = BitVec.ofNat 8 (T / 2 ^ 24)) :
    G.execute Metal.Elab.Tests.gatedDeltaStepText (32, 128, 48) (32, 4, 1)
      [⟨.device, 4096 * T, aq, q⟩, ⟨.device, 4096 * T, ak, k⟩, ⟨.device, 12288 * T, av, v⟩, ⟨.device, 192 * T, ag, g⟩,
        ⟨.device, 96 * T, ab, beta⟩, ⟨.device, 3145728, as, s⟩, ⟨.constant, 4, aT, t⟩] [12288 * T, 3145728] =
      some [bytes2 (12288 * T) (ySteps C (G.fusion Metal.Elab.Tests.gatedDeltaStepText) ⟨q, k, v, g, beta, s, t⟩),
        bytes4 3145728 (stateOut C (G.fusion Metal.Elab.Tests.gatedDeltaStepText)
          (stepAt C (G.fusion Metal.Elab.Tests.gatedDeltaStepText) ⟨q, k, v, g, beta, s, t⟩ (T - 1)))] := by
  rw [← clip_eqT T _ _ (bytes2_zero _ _) (bytes4_zero _ _)]
  apply gpu_owned C G _ compile_eq (by simpa using hmax)
  intro initial garbage
  obtain ⟨sh, fuel, hI, hr⟩ := launch_okT (C := C) (fuse := G.fusion Metal.Elab.Tests.gatedDeltaStepText)
    (I := ⟨q, k, v, g, beta, s, t⟩) (A := ⟨aq, ak, av, ag, ab, as, aT⟩) (initial := initial)
    ⟨hq, hk, hv, hg, hb, hs, ht⟩ hT hT1 hT2 garbage
  refine ⟨fuel, 2 * T + 1, 1, sh, devT, tgo, hr, hI.log, fun i hi b hb' => ?_⟩
  simp only [List.length_cons, List.length_nil] at hi
  rcases (by omega : i = 0 ∨ i = 1) with rfl | rfl
  · exact hI.y b hb' (.inl (by unfold yThread; omega))
  · exact hI.so b hb' (by have := soThread_lt hb'; unfold soDone; omega)

/-- **Consistency with one step**: at `T = 1` the theorem's outputs are `GatedDeltaStep.gpu_output`'s. -/
theorem steps_one (fuse : Nat → Bool) (I : Ins) :
    bytes2 (12288 * 1) (ySteps C fuse I) = bytes2 12288 (yOut C fuse I) ∧
      bytes4 3145728 (stateOut C fuse (stepAt C fuse I (1 - 1))) = bytes4 3145728 (stateOut C fuse I) := by
  refine ⟨funext fun b => ?_, by rw [Nat.sub_self, stepAt_zero]⟩
  unfold bytes2 ySteps
  split
  · rename_i hb
    rw [show b / 2 / 6144 = 0 by omega, show b / 2 % 6144 = b / 2 by omega, stepAt_zero]
  · rfl

/-- `gpu_output_steps` at `T = 1` is `GatedDeltaStep.gpu_output`'s statement. -/
theorem gpu_output_one (G : Gpu C) (hmax : 128 ≤ G.maxThreads Metal.Elab.Tests.gatedDeltaStepText)
    (q k v g beta s t : ByteMemory.Bytes) (aq ak av ag ab as aT : Nat)
    (hq : 2 ∣ aq) (hk : 2 ∣ ak) (hv : 2 ∣ av) (hg : 4 ∣ ag) (hb : 2 ∣ ab) (hs : 4 ∣ as) (ht : 4 ∣ aT)
    (hT : t 0 = 1 ∧ t 1 = 0 ∧ t 2 = 0 ∧ t 3 = 0) :
    G.execute Metal.Elab.Tests.gatedDeltaStepText (32, 128, 48) (32, 4, 1)
      [⟨.device, 4096, aq, q⟩, ⟨.device, 4096, ak, k⟩, ⟨.device, 12288, av, v⟩, ⟨.device, 192, ag, g⟩,
        ⟨.device, 96, ab, beta⟩, ⟨.device, 3145728, as, s⟩, ⟨.constant, 4, aT, t⟩] [12288, 3145728] =
      some [bytes2 12288 (yOut C (G.fusion Metal.Elab.Tests.gatedDeltaStepText) ⟨q, k, v, g, beta, s, t⟩),
        bytes4 3145728 (stateOut C (G.fusion Metal.Elab.Tests.gatedDeltaStepText) ⟨q, k, v, g, beta, s, t⟩)] := by
  have h := gpu_output_steps C G hmax 1 le_rfl (by decide) q k v g beta s t aq ak av ag ab as aT hq hk hv hg hb hs ht
    ⟨hT.1, hT.2.1, hT.2.2.1, hT.2.2.2⟩
  obtain ⟨h1, h2⟩ := steps_one C (G.fusion Metal.Elab.Tests.gatedDeltaStepText) ⟨q, k, v, g, beta, s, t⟩
  rw [h1, h2] at h
  exact h

end Metal.Kernels.GatedDeltaSteps

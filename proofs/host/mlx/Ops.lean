import host.mlx.Value
import contracts.mlx.M1MaxPlatforms
import contracts.mlx.ElementwiseAdd
import contracts.mlx.FloatMemory
import layers.Normalization
import layers.AffineVerifyLinear
import layers.QuantizedEmbedding
import kernels.attention.SdpaDispatched
import kernels.attention.OutputGate
import kernels.delta.Convolution
import kernels.delta.ComputeGHostSource
import kernels.normalization.MlxRmsHostSelection

namespace Host.Mlx
open Inference Inference.Contracts.Mlx Inference.Kernels
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

/-! Value-level semantics of the MLX v0.32.2 C API operations on the decode
route. Each operation is a partial function on immutable array values,
defined for the dtypes and shapes the route issues. A strided view, a
donated buffer and a fresh copy are the same value: layout, aliasing,
scheduling and synchronization are MLX's responsibility (gap 8). -/

/-! ## Row-major index algebra -/

def extent (shape : List Nat) : Nat := shape.foldr (· * ·) 1

def Within : List Nat → List Nat → Prop
  | [], [] => True
  | x :: xs, n :: ns => x < n ∧ Within xs ns
  | _, _ => False

theorem extent_cons (n : Nat) (s : List Nat) : extent (n :: s) = n * extent s := rfl
theorem flat_nil (idx : List Nat) : flat [] idx = 0 := rfl
theorem flat_cons (n x : Nat) (s idx : List Nat) : flat (n :: s) (x :: idx) = extent s * x + flat s idx := rfl
theorem unflat_cons (n i : Nat) (s : List Nat) : unflat (n :: s) i = i / extent s :: unflat s (i % extent s) := rfl

theorem flat_lt : ∀ (s idx : List Nat), Within idx s → flat s idx < extent s
  | [], [], _ => by decide
  | [], _ :: _, h => h.elim
  | _ :: _, [], h => h.elim
  | n :: s, x :: idx, ⟨hx, h⟩ => by
    have := flat_lt s idx h
    rw [flat_cons, extent_cons]
    have : extent s * x + extent s ≤ n * extent s := by
      rw [Nat.mul_comm n]; exact (Nat.mul_succ (extent s) x).symm ▸ Nat.mul_le_mul_left _ hx
    omega

theorem unflat_flat : ∀ (s idx : List Nat), Within idx s → unflat s (flat s idx) = idx
  | [], [], _ => rfl
  | [], _ :: _, h => h.elim
  | _ :: _, [], h => h.elim
  | n :: s, x :: idx, ⟨_, h⟩ => by
    have lt := flat_lt s idx h
    have pos : 0 < extent s := by omega
    rw [flat_cons, unflat_cons, Nat.mul_add_div pos, Nat.div_eq_of_lt lt, Nat.add_zero,
      Nat.mul_add_mod, Nat.mod_eq_of_lt lt, unflat_flat s idx h]

theorem within_unflat : ∀ (s : List Nat) (i : Nat), i < extent s → Within (unflat s i) s
  | [], _, _ => trivial
  | n :: s, i, h => by
    rw [extent_cons] at h
    have pos : 0 < extent s := Nat.pos_of_ne_zero (fun e => by rw [e, Nat.mul_zero] at h; omega)
    rw [unflat_cons]
    exact ⟨(Nat.div_lt_iff_lt_mul pos).mpr h, within_unflat s _ (Nat.mod_lt _ pos)⟩

theorem flat_unflat : ∀ (s : List Nat) (i : Nat), i < extent s → flat s (unflat s i) = i
  | [], i, h => by change i < 1 at h; change 0 = i; omega
  | n :: s, i, h => by
    rw [extent_cons] at h
    have pos : 0 < extent s := Nat.pos_of_ne_zero (fun e => by rw [e, Nat.mul_zero] at h; omega)
    rw [unflat_cons, flat_cons, flat_unflat s _ (Nat.mod_lt _ pos)]
    exact Nat.div_add_mod i (extent s)

theorem Value.size_eq (v : Value) : v.size = extent v.shape := rfl

theorem flat2 (p a w x : Nat) : flat [p,a] [w,x] = w*a+x := by
  simp only [flat_cons, flat_nil, extent, List.foldr]; ring
theorem flat3 (p a b w x y : Nat) : flat [p,a,b] [w,x,y] = (w*a+x)*b+y := by
  simp only [flat_cons, flat_nil, extent, List.foldr]; ring
theorem flat4 (p a b c w x y z : Nat) : flat [p,a,b,c] [w,x,y,z] = ((w*a+x)*b+y)*c+z := by
  simp only [flat_cons, flat_nil, extent, List.foldr]; ring

theorem within3 {p a b w x y : Nat} (hw : w < p) (hx : x < a) (hy : y < b) : Within [w,x,y] [p,a,b] :=
  ⟨hw, hx, hy, trivial⟩
theorem within4 {p a b c w x y z : Nat} (hw : w < p) (hx : x < a) (hy : y < b) (hz : z < c) :
    Within [w,x,y,z] [p,a,b,c] := ⟨hw, hx, hy, hz, trivial⟩

/-! ## Element access and bit codecs -/

def Value.get (v : Value) (idx : List Nat) : Nat := v.elems (flat v.shape idx)

def bf (n : Nat) : BF := Model.ofBits (BitVec.ofNat 16 n)
def bfWord (x : BF) : Nat := x.bits.toNat
theorem bf_word (x : BF) : bf (bfWord x) = x := by
  cases x with
  | mk b =>
    change (⟨BitVec.ofNat 16 (b : BitVec 16).toNat⟩ : BF) = ⟨b⟩
    congr 1
    rw [BitVec.ofNat_toNat]
    exact BitVec.setWidth_eq (b : BitVec 16)

def f32 (n : Nat) : Float32 := FloatMemory.decode (BitVec.ofNat 32 n)
def f32Word (x : Float32) : Nat := (FloatMemory.bits x).toNat
theorem f32_word (x : Float32) : f32 (f32Word x) = x := by
  unfold f32 f32Word
  rw [BitVec.ofNat_toNat, BitVec.setWidth_eq]
  exact FloatMemory.decode_bits x

-- Little-endian bytes and 16-bit words of a uint32 array's storage.
def Value.byte (v : Value) (b : Nat) : BitVec 8 := BitVec.ofNat 8 (v.elems (b/4) / 256^(b%4))
def Value.word16 (v : Value) (b : Nat) : BitVec 16 := BitVec.ofNat 16 (v.elems (b/4) / 256^(b%4))

-- Typed views of the route's tensors. `Tensor4 v a b c f`: v is bf16 [1,a,b,c].
def Tensor4 (v : Value) (a b c : Nat) (f : Fin a → Fin b → Fin c → BF) : Prop :=
  v.dtype = .bfloat16 ∧ v.shape = [1,a,b,c] ∧ ∀ x y z, bf (v.get [0,x.val,y.val,z.val]) = f x y z
def Tensor3 (v : Value) (a b : Nat) (f : Fin a → Fin b → BF) : Prop :=
  v.dtype = .bfloat16 ∧ v.shape = [1,a,b] ∧ ∀ x y, bf (v.get [0,x.val,y.val]) = f x y
def Row (v : Value) (n : Nat) (f : Fin n → BF) : Prop := Tensor3 v 1 n (fun _ => f)

/-! ## Layout operation access lemmas -/

theorem reshape_some (v : Value) (shape : List Nat) (h : extent shape = extent v.shape) :
    reshape v shape = some { v with shape := shape } := by
  unfold reshape
  rw [ite_eq_left (show List.foldr (· * ·) 1 shape = v.size from h)]

theorem slice_spec (v w : Value) (start stop : List Nat) (h : slice v start stop = some w) :
    w.dtype = v.dtype ∧ w.shape = List.zipWith (· - ·) stop start ∧
      ∀ idx, Within idx w.shape → w.get idx = v.get (List.zipWith (· + ·) start idx) := by
  unfold slice at h
  split at h
  · cases h
    refine ⟨rfl, rfl, fun idx hi => ?_⟩
    unfold Value.get
    dsimp only
    rw [unflat_flat _ _ hi]
  · cases h

theorem sliceUpdate_spec (v u w : Value) (start : List Nat) (h : sliceUpdate v u start = some w) :
    w.dtype = v.dtype ∧ w.shape = v.shape ∧
      ∀ idx, Within idx v.shape → w.get idx =
        if (List.zip idx (List.zip start u.shape)).all (fun (x, a, n) => a ≤ x ∧ x < a + n)
        then u.get (List.zipWith (· - ·) idx start) else v.get idx := by
  unfold sliceUpdate at h
  split at h
  · cases h
    refine ⟨rfl, rfl, fun idx hi => ?_⟩
    unfold Value.get
    dsimp only
    rw [unflat_flat _ _ hi]
  · cases h

theorem concatenate_spec (a b w : Value) (axis : Nat) (h : concatenate a b axis = some w) :
    w.dtype = a.dtype ∧ w.shape = a.shape.set axis (a.shape.getD axis 0 + b.shape.getD axis 0) ∧
      ∀ idx, Within idx w.shape → w.get idx = if idx.getD axis 0 < a.shape.getD axis 0 then a.get idx
        else b.get (idx.set axis (idx.getD axis 0 - a.shape.getD axis 0)) := by
  unfold concatenate at h
  split at h
  · cases h
    refine ⟨rfl, rfl, fun idx hi => ?_⟩
    unfold Value.get
    dsimp only
    rw [unflat_flat _ _ hi]
  · cases h

theorem transpose_spec (v w : Value) (axes : List Nat) (h : transpose v axes = some w) :
    w.dtype = v.dtype ∧ w.shape = axes.map (fun a => v.shape.getD a 0) ∧
      ∀ idx, Within idx w.shape →
        w.get idx = v.get ((List.range v.shape.length).map (fun a => idx.getD (axes.idxOf a) 0)) := by
  unfold transpose at h
  split at h
  · cases h
    refine ⟨rfl, rfl, fun idx hi => ?_⟩
    unfold Value.get
    dsimp only
    rw [unflat_flat _ _ hi]
  · cases h

theorem get3 (v : Value) (hs : v.shape = [p,a,b]) (w x y : Nat) : v.get [w,x,y] = v.elems ((w*a+x)*b+y) := by
  unfold Value.get; rw [hs, flat3]
theorem get4 (v : Value) (hs : v.shape = [p,a,b,c]) (w x y z : Nat) :
    v.get [w,x,y,z] = v.elems (((w*a+x)*b+y)*c+z) := by
  unfold Value.get; rw [hs, flat4]

theorem Tensor4.elems (h : Tensor4 v a b c f) (x : Fin a) (y : Fin b) (z : Fin c) :
    bf (v.elems ((x.val*b+y.val)*c+z.val)) = f x y z := by
  have e := h.2.2 x y z
  rw [get4 v h.2.1] at e
  simpa using e
theorem Tensor4.mk (hd : v.dtype = .bfloat16) (hs : v.shape = [1,a,b,c])
    (he : ∀ x y z, bf (v.elems ((x.val*b+y.val)*c+z.val)) = f x y z) : Tensor4 v a b c f :=
  ⟨hd, hs, fun x y z => by rw [get4 v hs]; simpa using he x y z⟩
theorem Tensor3.elems (h : Tensor3 v a b f) (x : Fin a) (y : Fin b) : bf (v.elems (x.val*b+y.val)) = f x y := by
  have e := h.2.2 x y
  rw [get3 v h.2.1] at e
  simpa using e
theorem Tensor3.mk (hd : v.dtype = .bfloat16) (hs : v.shape = [1,a,b])
    (he : ∀ x y, bf (v.elems (x.val*b+y.val)) = f x y) : Tensor3 v a b f :=
  ⟨hd, hs, fun x y => by rw [get3 v hs]; simpa using he x y⟩
theorem Row.elems (h : Row v n f) (j : Fin n) : bf (v.elems j.val) = f j := by
  simpa using Tensor3.elems h 0 j
theorem Row.mk (hd : v.dtype = .bfloat16) (hs : v.shape = [1,1,n]) (he : ∀ j : Fin n, bf (v.elems j.val) = f j) :
    Row v n f :=
  Tensor3.mk hd hs (fun x y => by have : x.val = 0 := by omega
                                  simpa [this] using he y)

theorem slice_defined (v : Value) (start stop : List Nat)
    (h : start.length = v.shape.length ∧ stop.length = v.shape.length ∧
      (List.zip start (List.zip stop v.shape)).all (fun (a, b, n) => a ≤ b ∧ b ≤ n)) :
    ∃ w, slice v start stop = some w := by
  unfold slice; rw [ite_eq_left h]; exact ⟨_, rfl⟩

theorem sliceUpdate_defined (v u : Value) (start : List Nat)
    (h : u.dtype = v.dtype ∧ start.length = v.shape.length ∧ u.shape.length = v.shape.length ∧
      (List.zip start (List.zip u.shape v.shape)).all (fun (a, n, m) => a + n ≤ m)) :
    ∃ w, sliceUpdate v u start = some w := by
  unfold sliceUpdate; rw [ite_eq_left h]; exact ⟨_, rfl⟩

theorem concatenate_defined (a b : Value) (axis : Nat)
    (h : a.dtype = b.dtype ∧ a.shape.length = b.shape.length ∧ axis < a.shape.length ∧
      (List.range a.shape.length).all (fun k => k = axis ∨ a.shape.getD k 0 = b.shape.getD k 0)) :
    ∃ w, concatenate a b axis = some w := by
  unfold concatenate; rw [ite_eq_left h]; exact ⟨_, rfl⟩

theorem transpose_defined (v : Value) (axes : List Nat)
    (h : axes.length = v.shape.length ∧ (List.range v.shape.length).all (fun a => axes.contains a)) :
    ∃ w, transpose v axes = some w := by
  unfold transpose; rw [ite_eq_left h]; exact ⟨_, rfl⟩

/-! ## Further layout operations issued by the route

ops.ts split issues one mlx_slice per section, so the FFI trace holds slices. -/

-- mlx_slice_update with explicit stop and unit strides (ops.ts sliceUpdate).
def sliceUpdateRange (v u : Value) (start stop : List Nat) : Option Value :=
  if List.zipWith (· - ·) stop start = u.shape then sliceUpdate v u start else none

-- mlx_slice_dynamic(a, start, axes, sizes): `start` is an int32 array with
-- one entry per axis in `axes`; other axes start at 0 (materialize.ts).
def sliceDynamic (v start : Value) (axes sizes : List Nat) : Option Value :=
  if start.dtype = .int32 ∧ start.size = axes.length ∧ sizes.length = v.shape.length then
    let origin := (List.range v.shape.length).map fun k =>
      if axes.contains k then start.elems (axes.idxOf k) else 0
    slice v origin (List.zipWith (· + ·) origin sizes)
  else none

/-! ## Elementwise and row operations -/

def map1 (op : BF → BF) (v : Value) : Option Value :=
  if v.dtype = .bfloat16 then some { v with elems := fun i => bfWord (op (bf (v.elems i))) } else none

-- Same-shape binary operations (no broadcasting occurs on the route).
def map2 (op : BF → BF → BF) (a b : Value) : Option Value :=
  if a.dtype = .bfloat16 ∧ b.dtype = .bfloat16 ∧ a.shape = b.shape then
    some { a with elems := fun i => bfWord (op (bf (a.elems i)) (bf (b.elems i))) }
  else none

-- Apply `f r` to contiguous row r of the last axis (width w) of a bf16 value.
def rowwise (w : Nat) (f : Nat → (Fin w → BF) → Fin w → BF) (v : Value) : Option Value :=
  if h : v.dtype = .bfloat16 ∧ v.shape.getLast? = some w ∧ 0 < w then
    some { v with elems := (fun i =>
      bfWord (f (i / w) (fun j => bf (v.elems (i / w * w + j.val))) ⟨i % w, Nat.mod_lt _ h.2.2⟩)) }
  else none

theorem rowwise_elems (w : Nat) (f : Nat → (Fin w → BF) → Fin w → BF) (v u : Value)
    (h : rowwise w f v = some u) (r : Nat) (j : Fin w) :
    u.dtype = v.dtype ∧ u.shape = v.shape ∧
      bf (u.elems (r * w + j.val)) = f r (fun k => bf (v.elems (r * w + k.val))) j := by
  unfold rowwise at h
  split at h
  · cases h
    refine ⟨rfl, rfl, ?_⟩
    have pos : 0 < w := by omega
    have hd : (r * w + j.val) / w = r := by
      rw [Nat.add_comm, Nat.add_mul_div_right _ _ pos, Nat.div_eq_of_lt j.isLt, Nat.zero_add]
    have hm : (r * w + j.val) % w = j.val := by
      rw [Nat.add_comm, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt j.isLt]
    dsimp only
    rw [bf_word]
    simp only [hd, hm]
  · cases h

theorem map1_elems (op : BF → BF) (v u : Value) (h : map1 op v = some u) (i : Nat) :
    u.dtype = v.dtype ∧ u.shape = v.shape ∧ bf (u.elems i) = op (bf (v.elems i)) := by
  unfold map1 at h
  split at h
  · cases h; exact ⟨rfl, rfl, bf_word _⟩
  · cases h

theorem map2_elems (op : BF → BF → BF) (a b u : Value) (h : map2 op a b = some u) (i : Nat) :
    u.dtype = a.dtype ∧ u.shape = a.shape ∧ bf (u.elems i) = op (bf (a.elems i)) (bf (b.elems i)) := by
  unfold map2 at h
  split at h
  · cases h; exact ⟨rfl, rfl, bf_word _⟩
  · cases h

/-! ## The trusted MLX v0.32.2 statement

Fields are the MLX-internal choices that affect bits and are not fixed by
the pinned source alone, or are fixed there by a value we must name. Every
other operation semantics below is a definition from the proved kernel
models, instantiated with platforms built from the M1 Max contract `C`.
Sources: ml-explore/mlx@1f8e74e3 (v0.32.2), pinned in proofs/check.ts. -/
structure MlxContract (C : M1Max.Contract) where
  -- normalization.cpp:57-80: axis 5120 > RMS_LOOPED_LIMIT 4096 (defines.h:16)
  -- selects rms_norm_looped with maxTotalThreadsPerThreadgroup threads.
  -- On this pipeline that limit is 1024, i.e. 32 SIMD groups.
  hiddenThreads : Normalization.MlxRmsHostSelection.KernelLimit
  hiddenThreads_m1max : hiddenThreads.threads = 1024
  -- llvm.fmuladd contraction chosen by the Metal compiler at each kernel's
  -- multiply-add sites (carry no claim; they select the proved expression).
  rmsContracted : Bool
  ropeFirst : Attention.Rope.Contraction
  ropeSecond : Attention.Rope.Contraction
  sdpaSum : Bool
  sdpaNumerator : Attention.SdpaUpdate.Contraction
  sdpaScore : Bool
  sdpaMerge : Bool
  convContracted : Bool
  qmvContracted : Bool
  qmvTail : Bool
  dequantizeContracted : Bool
  -- unary_ops.h:308-313 Sigmoid on bfloat16: y = 1/(1+exp(|x|)), then
  -- x<0 ? y : 1-y in BF16 (OutputGate.lean); `expAbs` is the bf16 exp(|x|).
  sigmoid : Attention.OutputGate.Platform
  -- rope.cpp:123 `float base = std::log2(base_)` on the host (libm log2f).
  log2 : Float32 → Float32
  -- The observed log2f word for the route's base 1e7 (0x4b189680).
  log2_route : log2 (Float32.ofBits 0x4b189680) = Float32.ofBits 0x41ba0729
  -- compiled.cpp: a compiled closure's elementwise chain becomes one JIT
  -- kernel; its LogAddExp uses the compiled preamble's max/min tie policy
  -- with fast exp/log1p (MlxLogAddExpSource), not the uncompiled kernel.
  logAddExp : Delta.MlxLogAddExpSource.Policy
  decay : Delta.Decay.Platform

namespace MlxContract
variable {C : M1Max.Contract} (M : MlxContract C)

-- normalization.cpp:68-75: axis 256 ≤ 4096 selects rms_norm with
-- ceil(256/RMS_N_READS)=64 threads (MlxRmsHeadHostSelection), 2 SIMD groups.
noncomputable def headNorm : RmsNorm.Platform := C.rmsPlatform 2 (by decide) (by decide) M.rmsContracted
noncomputable def hiddenNorm : RmsNorm.Platform :=
  C.rmsPlatform (Normalization.MlxRmsHostSelection.groups M.hiddenThreads)
    (Normalization.MlxRmsHostSelection.groups_positive _) (Normalization.MlxRmsHostSelection.groups_bounded _)
    M.rmsContracted
noncomputable def angles (_ : MlxContract C) : Attention.RopeAngles.Platform := C.anglePlatform
noncomputable def rotation : Attention.Rope.Platform := C.rotationPlatform M.ropeFirst M.ropeSecond
noncomputable def sdpa : Attention.SdpaVector.Platform := C.sdpaPlatform M.sdpaSum M.sdpaNumerator M.sdpaScore
noncomputable def row : Quantization.AffineRow.Platform := C.rowPlatform M.qmvContracted M.qmvTail

theorem hiddenGroups : Normalization.MlxRmsHostSelection.groups M.hiddenThreads = 32 := by
  unfold Normalization.MlxRmsHostSelection.groups; rw [M.hiddenThreads_m1max]

end MlxContract

-- device.h:158 get_architecture().back(), read by the SDPA dispatch:
-- 's' for the M1 Max (applegpu_g13s, device.cpp:612).
def arch : Char := 's'

/-! ## Numeric operations -/

-- Scratch contents do not affect RmsNorm.value (inverse_correct).
theorem rmsValue_scratch (P : RmsNorm.Platform) (x : Fin n → Float32) (w : Fin n → BF) (width eps : Float32)
    (s s' : M1Max.WordMemory) (b b' : Nat) :
    RmsNorm.value P x w width eps s b = RmsNorm.value P x w width eps s' b' := by
  funext i
  unfold RmsNorm.value
  rw [RmsNorm.inverse_correct, RmsNorm.inverse_correct]

-- mlx_fast_rms_norm(x, w, eps) over the last axis; the kernel converts
-- axis_size to float (rms_norm.metal). `P` is headNorm or hiddenNorm.
def rmsNorm (P : RmsNorm.Platform) (x weight : Value) (eps : Float32) : Option Value :=
  match weight.dtype, weight.shape with
  | .bfloat16, [w] => rowwise w (fun _ row => Layers.Normalization.value P (fun k => BFloat16.widen (row k))
      (fun k => bf (weight.elems k.val)) false (Float32.ofNat w) eps (fun _ => 0) 0) x
  | _, _ => none

-- mlx_fast_rope(x, dims, traditional, base, scale, offset, freqs=null).
-- rope.cpp:94-123 selects rope_single for row-contiguous T=1 input and
-- passes log2(base); rope.metal:21 position = scale*float(offset)
-- (RopeAngles.value). Rows are (B·heads·T) in order; T=1 on the route.
noncomputable def rope (M : MlxContract C) (x : Value) (dims : Nat) (traditional : Bool) (base : Option Float32)
    (scale : Float32) (offset : Int) : Option Value :=
  match base with
  | some b =>
    if dims = 64 ∧ traditional = false ∧ x.shape.length = 4 ∧ x.shape.getD 2 0 = 1 then
      rowwise 256 (fun _ row => Attention.Rope.head M.rotation row
        (Attention.RopeAngles.value M.angles ⟨M.log2 b, Float32.ofInt offset, scale⟩)) x
    else none
  | none => none

-- mlx_fast_scaled_dot_product_attention(q, k, v, scale, mask="") for
-- q [1,24,1,256], k/v [1,4,n,256]. sdpa_vector.h:63 kv head = h / (24/4);
-- scaled_dot_product_attention.cpp dispatch is SdpaDispatched.route.
-- The model's score scale is 1/16; the op requires that f32 word.
noncomputable def sdpaAt (M : MlxContract C) (q k v : Value) (n : Nat) (h : Fin 24) (c : Fin 256) : BF :=
  let kv := Attention.SdpaScore.kvHead h
  Attention.SdpaDispatched.forward M.sdpa M.sdpaMerge arch (fun c => bf (q.get [0, h.val, 0, c.val]))
    (fun (t : Fin n) c => bf (k.get [0, kv.val, t.val, c.val])) (fun (t : Fin n) c => bf (v.get [0, kv.val, t.val, c.val])) c

noncomputable def sdpa (M : MlxContract C) (q k v : Value) (scale : Float32) : Option Value :=
  match k.shape with
  | [1, 4, n, 256] =>
    if q.dtype = .bfloat16 ∧ k.dtype = .bfloat16 ∧ v.dtype = .bfloat16 ∧ q.shape = [1,24,1,256] ∧
        v.shape = [1,4,n,256] ∧ scale = Attention.SdpaScore.scale then
      some { q with elems := (fun i =>
        bfWord (sdpaAt M q k v n ⟨i / 256 % 24, Nat.mod_lt _ (by decide)⟩ ⟨i % 256, Nat.mod_lt _ (by decide)⟩)) }
    else none
  | _ => none

-- unary.cpp / binary.cpp on bf16 operands (unary_ops.h, binary_ops.h).
noncomputable def sigmoid (M : MlxContract C) (v : Value) : Option Value := map1 (Attention.OutputGate.sigmoid M.sigmoid) v
def multiply (a b : Value) : Option Value := map2 BFloat16Arithmetic.mul a b
def add (a b : Value) : Option Value := map2 BFloat16Arithmetic.add a b

-- mlx_conv1d(in [1,4,C], w [C,4,1], stride 1, padding 0, dilation 1,
-- groups C): conv.cpp:1551 selects depthwise_conv_1d (Convolution.selected).
def conv1d (M : MlxContract C) (input weight : Value) (stride padding dilation groups : Nat) : Option Value :=
  match input.shape with
  | [1, 4, c] =>
    if input.dtype = .bfloat16 ∧ weight.dtype = .bfloat16 ∧ weight.shape = [c, 4, 1] ∧
        Delta.Convolution.depthwiseSelected c c groups stride dilation 1 padding false then
      some { dtype := .bfloat16, shape := [1, 1, c], elems := (fun i =>
        bfWord (Delta.Convolution.value M.convContracted
          (fun tap => bf (input.get [0, tap.val, i])) (fun tap => bf (weight.get [i, tap.val, 0])))) }
    else none
  | _ => none

-- mlx_quantized_matmul(x [1,1,steps·512], w u32 [rows, steps·64],
-- scales/biases bf16 [rows, steps·8], transpose, g64, b4, "affine"):
-- quantized.cpp:484-502 selects qmv_fast with 4 rows per SIMD group (the
-- narrow variant needs architecture gen 17; M1 Max is 13): MlxQmv. Weight
-- words are read as AffineLoads reads them.
def weights4 (w scales biases : Value) (steps : Nat) (row : Nat) : Quantization.AffineRow.Weights4 steps where
  words step lane chunk := w.word16 (Quantization.AffineLayout.weightOffset 4 row steps step.val lane.val (chunk.val*2))
  scale g := bf (scales.elems (row*(steps*8)+g.val))
  bias g := bf (biases.elems (row*(steps*8)+g.val))

noncomputable def quantizedMatmul (M : MlxContract C) (x w scales biases : Value) (transpose : Bool) (group bits : Nat) (mode : String) :
    Option Value :=
  match x.shape, w.shape with
  | [1, 1, k], [rows, _] =>
    if x.dtype = .bfloat16 ∧ w.dtype = .uint32 ∧ transpose = true ∧ group = 64 ∧ bits = 4 ∧ mode = "affine" ∧
        k % 512 = 0 ∧ w.shape = [rows, k/8] ∧ scales.shape = [rows, k/64] ∧ biases.shape = [rows, k/64] then
      let steps := k / 512
      some { dtype := .bfloat16, shape := [1, 1, rows], elems := (fun r =>
        if h : r < rows then
          bfWord (({ platform := M.row, weights := fun row => weights4 w scales biases steps row.val } :
            Layers.AffineVerifyLinear.Projection4 steps rows).plainForward
            (fun j => bf (x.elems j.val)) ⟨r, h⟩)
        else 0) }
    else none
  | _, _ => none

-- mlx_dequantize of one gathered embedding row ([1,1,640] u32, [1,1,80]
-- scales/biases, g64, b4): AffineDequantize.row on the row's bytes.
def dequantizeRow (M : MlxContract C) (w scales biases : Value) : Option Value :=
  if w.dtype = .uint32 ∧ w.shape = [1, 1, 640] ∧ scales.shape = [1, 1, 80] ∧ biases.shape = [1, 1, 80] then
    some { dtype := .bfloat16, shape := [1, 1, 5120], elems := (fun i =>
      if h : i < 5120 then
        bfWord (Quantization.AffineDequantize.row M.dequantizeContracted (fun b => w.byte b.val)
          (fun g => bf (scales.elems g.val)) (fun g => bf (biases.elems g.val)) ⟨i, h⟩)
      else 0) }
  else none

-- mlx_take_axis(table [rows, cols], ids [1,1] u32, 0) = takeRows.
def takeAxis0 (table ids : Value) : Option Value :=
  if ids.dtype = .uint32 then takeRows table ids else none

/-! ## Compiled closures (gap 5)

mlx_closure_apply on a closure built by mlx_compile evaluates the traced
graph. compiled.cpp fuses maximal elementwise chains into one JIT kernel;
the values are the fused per-op computation as compiled, which for compute_g
is ComputeGHostSource (fast LogAddExp policy, bf16×f32 → f32 promotion).
Closures that only launch our metal kernels have those kernels' semantics. -/
inductive Closure where
  -- compute_g(A_log [48] bf16, a [1,1,48] bf16, dt_bias [48] bf16) → f32 [1,1,48]
  | computeG
  -- a closure whose body is our metal kernel launches
  | kernels (body : List Value → Option (List Value))

def computeGValue (M : MlxContract C) (aLog a dt : Value) : Value :=
  { dtype := .float32, shape := [1, 1, 48], elems := (fun i =>
    match Delta.ComputeGHostSource.execute M.logAddExp M.decay (bf (aLog.elems i)) (bf (a.elems i)) (bf (dt.elems i)) with
    | some (.fp g) => f32Word g
    | _ => 0) }

def Closure.eval (M : MlxContract C) : Closure → List Value → Option (List Value)
  | .computeG, [aLog, a, dt] =>
    if aLog.dtype = .bfloat16 ∧ a.dtype = .bfloat16 ∧ dt.dtype = .bfloat16 ∧ a.shape = [1, 1, 48] then
      some [computeGValue M aLog a dt]
    else none
  | .computeG, _ => none
  | .kernels body, xs => body xs

-- The closure contract: applying a compiled closure is evaluating it.
def closureApply (M : MlxContract C) (f : Closure) (xs : List Value) : Option (List Value) := f.eval M xs

-- mlx_eval / mlx_async_eval have no value effect; item_uint32 reads element 0.
def itemUint32 (v : Value) : Option Nat := if v.dtype = .uint32 ∧ v.size = 1 then some (v.elems 0) else none

end Host.Mlx

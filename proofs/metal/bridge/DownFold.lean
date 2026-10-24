import metal.kernels.DownFold
import metal.bridge.General

namespace Metal.Bridge.DownFold
open Metal Metal.Core Metal.Kernels.DownFold
open Inference.Contracts.Mlx Inference.Contracts.Mlx.Numerics
open Inference.Kernels.Trellis Inference.Models.Qwen Inference.Models.Qwen.WrittenLayers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Metal.Bridge.General

/-! # down-codebook FOLD: the machine spec is the model's fold step

`Metal.Kernels.DownFold.gpu_output` states `out[c]` as `C.narrow (C.simdSum (partial[·][c]))` on the bytes of
`partial`; the model's fold step is `Trellis.DownOutput.foldValues trace reduce c =
BFloat16.narrow (reduce (trace.read · c))` on the partial buffer of a `Trellis.DownDevice.Trace` (the down-partial
dispatch's result, with `reduce = mlp.downPlatform.reduce`, which `GlueKernels.trellis_mlp` requires to be
`C.simdSum`). The operations are the same; the hardware cast needs a finite sum, which the model's
`TrellisCodebookDown.Finite.narrowing` (finite bf16 output) implies. -/

variable (C : M1Max.Contract)

theorem cell_eq (P : ByteMemory.Bytes) (o k : Nat) (hk : k < 4) :
    cell P o k = FloatMemory.decode (ByteMemory.load32 P (o + 4 * k)) := by
  rw [← ofF32Bits_bytes]
  unfold cell
  rcases (by omega : k = 0 ∨ k = 1 ∨ k = 2 ∨ k = 3) with rfl | rfl | rfl | rfl <;> rfl

/-- Column `c` of `out` from the bytes of `partial`: the cast of the `simd_sum` of the 32 rows' floats. -/
theorem outValue_eq (P : ByteMemory.Bytes) (c : Nat) :
    outValue C P c = C.narrow (C.simdSum fun l => FloatMemory.decode (ByteMemory.load32 P (4 * (l.val * 5120 + c)))) := by
  unfold outValue colSum
  congr 2
  funext l
  rw [cell_eq _ _ _ (Nat.mod_lt _ (by decide))]
  congr 2
  unfold offset col
  omega

/-- **Column `c` of the kernel is the model's fold** `DownOutput.foldValues trace C.simdSum c`, when `partial`'s bytes
are the trace's partial buffer and the column's sum is finite. -/
theorem outValue_fold {load : M1Max.ThreadgroupLoad} {before : Nat → ByteMemory.Bytes} {base : Nat}
    {words : DownExecution.PackedMatrix} {k : Nat} {scale input : Nat → Float32}
    (trace : DownDevice.Trace load before base words k scale input) (P : ByteMemory.Bytes)
    (hP : ∀ b < 655360, P b = trace.memory (trace.partialBase + b)) (c : Fin 5120)
    (hfin : (C.simdSum fun l => trace.read l.val c.val).isFinite = true) :
    outValue C P c.val = DownOutput.foldValues trace C.simdSum c.val := by
  have hr : (fun l : Fin 32 => FloatMemory.decode (ByteMemory.load32 P (4 * (l.val * 5120 + c.val)))) =
      fun l => trace.read l.val c.val := by
    funext l
    have hl := l.isLt
    have hc := c.isLt
    unfold DownDevice.Trace.read FloatMemory.load ByteMemory.load32
    rw [hP _ (by omega), hP _ (by omega), hP _ (by omega), hP _ (by omega)]
    simp only [Nat.add_assoc]
  rw [outValue_eq, hr, C.narrow_model _ hfin]
  rfl

/-- The output bytes of a model fold. -/
def foldBytes (f : Fin 5120 → BF) (b : Nat) : BitVec 8 :=
  if h : b < 10240 then (wordBytes 2 (Val.bf16Bits (f ⟨b / 2, by omega⟩))).getD (b % 2) 0 else 0

/-- **The fold's bytes are the model's MLP output** `mlp.forward` (the value `GlueKernels.trellis_mlp` concludes), for
the route's Trellis execution `e`, when `partial` holds `e.down`'s partial buffer, the down platform reduces with
`C.simdSum`, and the model's bf16 outputs are finite (`TrellisMlp.forward_finite`). -/
theorem expected_mlp (mlp : GateDown) (input : Fin 5120 → BF) (e : TrellisMlpParsedDown.Execution mlp input)
    (hred : mlp.downPlatform.reduce = C.simdSum) (P : ByteMemory.Bytes)
    (hP : ∀ b < 655360, P b = e.down.memory (e.down.partialBase + b))
    (hfin : ∀ c, Model.isFinite (mlp.forward (ArrayStorage.bfWords input) c) = true) :
    expected C P = foldBytes (mlp.forward (ArrayStorage.bfWords input)) := by
  have hcol : ∀ c : Fin 5120, outValue C P c.val = mlp.forward (ArrayStorage.bfWords input) c := by
    intro c
    have hout : DownOutput.foldValues e.down mlp.downPlatform.reduce c.val = mlp.forward (ArrayStorage.bfWords input) c :=
      (e.output.read_correct c.val c.isLt).symm.trans (TrellisMlpParsedDown.output_eq e c)
    rw [hred] at hout
    have hf : (C.simdSum fun l => e.down.read l.val c.val).isFinite = true := by
      apply finite_of_narrow
      have := hfin c
      rw [← hout] at this
      exact this
    rw [outValue_fold C e.down P hP c hf, hout]
  funext b
  unfold expected foldBytes
  by_cases hb : b < 10240
  · rw [ite_eq_left hb, dite_eq_left hb, hcol ⟨b / 2, by omega⟩]
  · rw [ite_eq_right hb, dite_eq_right hb]

/-- **Under the GPU assumption the fold launch's output is the encoding of the model's MLP output.** -/
theorem gpu_model (G : Gpu C) (hmax : 256 ≤ G.maxThreads Metal.Elab.Tests.downFoldText) (mlp : GateDown)
    (input : Fin 5120 → BF) (e : TrellisMlpParsedDown.Execution mlp input) (hred : mlp.downPlatform.reduce = C.simdSum)
    (P : ByteMemory.Bytes) (hP : ∀ b < 655360, P b = e.down.memory (e.down.partialBase + b))
    (hfin : ∀ c, Model.isFinite (mlp.forward (ArrayStorage.bfWords input) c) = true) :
    G.execute Metal.Elab.Tests.downFoldText (40960, 1, 1) (256, 1, 1) [⟨.device, 655360, 16, P⟩] [10240] =
      some [foldBytes (mlp.forward (ArrayStorage.bfWords input))] := by
  rw [gpu_output C G hmax P, expected_mlp C mlp input e hred P hP hfin]

/-- The output bytes read back as the route reads them are `GlueKernels.trellis_mlp`'s conclusion. -/
theorem readback (f : Fin 5120 → BF) : Host.Mlx.Flat (Host.Mlx.halfArray (foldBytes f) 0 [1, 5120]) [1, 5120] f := by
  refine ⟨rfl, rfl, fun j => ?_⟩
  change Host.Mlx.bf (HalfMemory.load (foldBytes f) (0 + 2 * j.val)).toNat = f j
  rw [Host.Mlx.bf_toNat, Nat.zero_add]
  refine half_readback _ _ _ fun k hk => ?_
  unfold foldBytes
  rw [dite_eq_left (by omega)]
  rw [show (2 * j.val + k) % 2 = k by omega]
  congr 4
  exact Fin.ext (by simp only; omega)

end Metal.Bridge.DownFold

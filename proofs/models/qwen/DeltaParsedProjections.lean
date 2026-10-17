import models.qwen.Delta48NativeParsedAffine4
import layers.AffineParsedSource

namespace Inference.Models.Qwen.DeltaParsedProjections
open Contracts.Mlx Layers Kernels.Delta
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 2000

variable {layer : DeltaNet.Layer} {input : Fin 5120 → ArrayStorage.BF}
  (phase : DeltaAffineMemory.Execution layer input)

-- QKV and Z use the custom complete-row wrapper. The 48-element A and B
-- projections use the native four-bit route, whose two-SIMD layout differs.
-- All four certificates refer to the executions in this one ordered phase.
structure Certificate (a b : AffineVerifyLinear.Projection4 10 48)
    (ha : layer.a=.bits4 a) (hb : layer.b=.bits4 b)
    (generation : Nat) (size : Char) (before : Nat → Float32) : Prop where
  qkv : AffineParsedSource.Certificate (steps := 10) (blocks := 160) phase.qkv before
  z : AffineParsedSource.Certificate (steps := 10) (blocks := 96) phase.z before
  a : AffineNativeParsedSource4.Certificate (blocks := 6)
    (Delta48NativeParsedAffine4.aExecution phase a ha) generation size before
  b : AffineNativeParsedSource4.Certificate (blocks := 6)
    (Delta48NativeParsedAffine4.bExecution phase b hb) generation size before

theorem checked (a b : AffineVerifyLinear.Projection4 10 48)
    (ha : layer.a=.bits4 a) (hb : layer.b=.bits4 b)
    (generation : Nat) (size : Char) (before : Nat → Float32)
    (qkvFinite : layer.qkv.Finite input) (zFinite : layer.z.Finite input)
    (aFinite : a.Finite input) (bFinite : b.Finite input) :
    Certificate phase a b ha hb generation size before :=
  ⟨AffineParsedSource.checked (steps := 10) (blocks := 160) (p := layer.qkv)
      phase.qkv before (by decide) (by decide) qkvFinite,
    AffineParsedSource.checked (steps := 10) (blocks := 96) (p := layer.z)
      phase.z before (by decide) (by decide) zFinite,
    Delta48NativeParsedAffine4.a_source phase a ha generation size before aFinite,
    Delta48NativeParsedAffine4.b_source phase b hb generation size before bFinite⟩

theorem ordered_heaps :
    phase.z.source.bytes=phase.qkv.outputBuffer.bytes ∧
    phase.a.source.bytes=phase.z.outputBuffer.bytes ∧
    phase.b.source.bytes=phase.a.outputBuffer.bytes :=
  ⟨phase.z_memory,phase.a_memory,phase.b_memory⟩

variable {a b : AffineVerifyLinear.Projection4 10 48}
  {ha : layer.a=.bits4 a} {hb : layer.b=.bits4 b}
  {generation : Nat} {size : Char} {before : Nat → Float32}
  (source : Certificate phase a b ha hb generation size before)

include source in
theorem qkv_readback (row : Fin 10240) :
    phase.qkvBuffer.read row=AffineParsedSource.value (steps := 10) (blocks := 160) phase.qkv row := by
  rw [ArrayStorage.BFBuffer.read_correct]
  exact (AffineParsedSource.readback (steps := 10) (blocks := 160) (p := layer.qkv)
    phase.qkv before source.qkv row).symm

include source in
theorem z_readback (row : Fin 6144) :
    phase.zBuffer.read row=AffineParsedSource.value (steps := 10) (blocks := 96) phase.z row := by
  rw [ArrayStorage.BFBuffer.read_correct]
  exact (AffineParsedSource.readback (steps := 10) (blocks := 96) (p := layer.z)
    phase.z before source.z row).symm

include source in
theorem a_readback (head : Fin 48) :
    phase.aBuffer.read head=AffineNativeParsedSource4.value (blocks := 6)
      (Delta48NativeParsedAffine4.aExecution phase a ha) head := by
  rw [ArrayStorage.BFBuffer.read_correct]
  calc
    layer.a.forward input head = a.forward input head :=
      congrArg (fun spec : AffineVerifyLinear.Projection 10 48 => spec.forward input head) ha
    _ = _ := (source.a.readback head).symm

include source in
theorem b_readback (head : Fin 48) :
    phase.bBuffer.read head=AffineNativeParsedSource4.value (blocks := 6)
      (Delta48NativeParsedAffine4.bExecution phase b hb) head := by
  rw [ArrayStorage.BFBuffer.read_correct]
  calc
    layer.b.forward input head = b.forward input head :=
      congrArg (fun spec : AffineVerifyLinear.Projection 10 48 => spec.forward input head) hb
    _ = _ := (source.b.readback head).symm

theorem consumer_heap :
    phase.qkvBuffer.bytes=phase.memory ∧ phase.zBuffer.bytes=phase.memory ∧
    phase.aBuffer.bytes=phase.memory ∧ phase.bBuffer.bytes=phase.memory := ⟨rfl,rfl,rfl,rfl⟩

include source in
theorem qkv_error (target error : Fin 5120 → ℝ)
    (inputBound : ∀ i, |Model.toReal (input i)-target i| ≤ error i)
    (finite : layer.qkv.Finite input) (row : Fin 10240) :
    |Model.toReal (phase.qkvBuffer.read row)-layer.qkv.target target row| ≤
      layer.qkv.budget input target error row := by
  rw [qkv_readback phase source row]
  exact AffineParsedSource.readback_error (steps := 10) (blocks := 160) (p := layer.qkv)
    phase.qkv before source.qkv target error inputBound finite row

include source in
theorem z_error (target error : Fin 5120 → ℝ)
    (inputBound : ∀ i, |Model.toReal (input i)-target i| ≤ error i)
    (finite : layer.z.Finite input) (row : Fin 6144) :
    |Model.toReal (phase.zBuffer.read row)-layer.z.target target row| ≤
      layer.z.budget input target error row := by
  rw [z_readback phase source row]
  exact AffineParsedSource.readback_error (steps := 10) (blocks := 96) (p := layer.z)
    phase.z before source.z target error inputBound finite row

end Inference.Models.Qwen.DeltaParsedProjections

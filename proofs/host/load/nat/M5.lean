import host.load.nat.M4
namespace Host.Ts.FfiNat
open Host.Ts
set_option maxHeartbeats 4000000

rel_derive mapN.ctor
rel_derive_ffi mapN.ctor
rel_derive mapOf
rel_derive_ffi mapOf
rel_derive mapN.withMap
rel_derive_ffi mapN.withMap
rel_derive findEntry.sameValueZero
rel_derive_ffi findEntry.sameValueZero
rel_derive findEntry
rel_derive_ffi findEntry
rel_derive mapEntryValueLinear
rel_derive_ffi mapEntryValueLinear
rel_derive mapEntryValue
rel_derive_ffi mapEntryValue
rel_derive mapN.snapshot
rel_derive_ffi mapN.snapshot
rel_derive mapN.mk
rel_derive_ffi mapN.mk
rel_derive mapN
rel_derive_ffi mapN
rel_derive setN.dedup
rel_derive_ffi setN.dedup
rel_derive setOf
rel_derive_ffi setOf
rel_derive setN.withSet
rel_derive_ffi setN.withSet
rel_derive setN
rel_derive_ffi setN
rel_derive_indep offsetArg
rel_derive_indep cellsOf
rel_derive bufN.typedCtor
rel_derive_ffi bufN.typedCtor
rel_derive byteLen
rel_derive_ffi byteLen
rel_derive viewOf
rel_derive_ffi viewOf
rel_derive_indep isLittle
rel_derive bufN.get
rel_derive_ffi bufN.get
rel_derive bufN.set
rel_derive_ffi bufN.set
rel_derive typedOf
rel_derive_ffi typedOf
rel_derive bufN
rel_derive_ffi bufN
rel_derive fnN
rel_derive_ffi fnN
rel_derive_state genResume
rel_derive ctlN.gen
rel_derive_ffi ctlN.gen
rel_derive ctlN.agen
rel_derive_ffi ctlN.agen
rel_derive thenOn
rel_derive_ffi thenOn
rel_derive ctlN
rel_derive_ffi ctlN
rel_derive ffiN.mk
rel_derive_ffi ffiN.mk
rel_derive decodeArgs
rel_derive_ffi decodeArgs
rel_derive readMem
rel_derive_ffi readMem
rel_derive ffiN.rd
rel_derive_ffi ffiN.rd
rel_derive ffiN
rel_derive_ffi ffiN
rel_derive hostCall
rel_derive_ffi hostCall
rel_derive callNative
rel_derive_ffi callNative
rel_derive callStep
rel_derive_ffi callStep
rel_derive resolveFns
rel_derive_ffi resolveFns
rel_derive constructNative
rel_derive_ffi constructNative
rel_derive constructStep
rel_derive_ffi constructStep
rel_derive bindStep
rel_derive_ffi bindStep
rel_derive shortStep
rel_derive_ffi shortStep
section
variable {F1 F2 : Ffi} [FfiRel F1 F2] [FfiSim F1 F2]
rel_derive stepImpl
end

theorem step_impl (F : Ffi) : @step F = @stepImpl F := by
  funext s; unfold step stepImpl; rcases s.ctl <;> rfl

section
variable {F1 F2 : Ffi} [FfiRel F1 F2] [FfiSim F1 F2]
theorem rel_step (a0 : St F1.S) (a0_x : F2.S) (a0_hx : FfiRel.R a0.ffi a0_x) :
    MR CRel.r (step F1 a0) (step F2 (a0.reFfi a0_x)) := by
  rw [step_impl, step_impl]
  exact rel_stepImpl _ _ a0 a0_x a0_hx
end


end Host.Ts.FfiNat

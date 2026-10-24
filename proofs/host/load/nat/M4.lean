import host.load.nat.M3
namespace Host.Ts.FfiNat
open Host.Ts
set_option maxHeartbeats 4000000

rel_derive awaitVal
rel_derive_ffi awaitVal
rel_derive yieldResult
rel_derive_ffi yieldResult
rel_derive yieldVal
rel_derive_ffi yieldVal
rel_derive agenYield
rel_derive_ffi agenYield
rel_derive retK
rel_derive_ffi retK
section
variable {F1 F2 : Ffi} [FfiRel F1 F2] [FfiSim F1 F2]
rel_derive retStepImpl
end

theorem retStep_impl (F : Ffi) : @retStep F = @retStepImpl F := by
  funext s f v; cases f <;> rfl

section
variable {F1 F2 : Ffi} [FfiRel F1 F2] [FfiSim F1 F2]
theorem rel_retStep (a0 : St F1.S) (a0_x : F2.S) (a0_hx : FfiRel.R a0.ffi a0_x) (a1 : Frame) (a2 : Val) :
    MR CRel.r (retStep F1 a0 a1 a2) (retStep F2 (a0.reFfi a0_x) a1 a2) := by
  rw [retStep_impl, retStep_impl]
  exact rel_retStepImpl _ _ a0 a0_x a0_hx a1 a2
end

section
variable {F1 F2 : Ffi} [FfiRel F1 F2] [FfiSim F1 F2]
rel_derive stepRetImpl
end

theorem stepRet_impl (F : Ffi) : @stepRet F = @stepRetImpl F := by
  funext s v; unfold stepRet stepRetImpl; rcases s.stack with _ | ⟨f, fs⟩ <;> rfl

section
variable {F1 F2 : Ffi} [FfiRel F1 F2] [FfiSim F1 F2]
theorem rel_stepRet (a0 : St F1.S) (a0_x : F2.S) (a0_hx : FfiRel.R a0.ffi a0_x) (a1 : Val) :
    MR CRel.r (stepRet F1 a0 a1) (stepRet F2 (a0.reFfi a0_x) a1) := by
  rw [stepRet_impl, stepRet_impl]
  exact rel_stepRetImpl _ _ a0 a0_x a0_hx a1
end

rel_derive mkError
rel_derive_ffi mkError
rel_derive abrSt
rel_derive_ffi abrSt
rel_derive closeIter
rel_derive_ffi closeIter
rel_derive abrLp
rel_derive_ffi abrLp
rel_derive boundaryAbr
rel_derive_ffi boundaryAbr
rel_derive nativeAbr
rel_derive_ffi nativeAbr
rel_derive abrK
rel_derive_ffi abrK
section
variable {F1 F2 : Ffi} [FfiRel F1 F2] [FfiSim F1 F2]
rel_derive abrStepImpl
end

theorem abrStep_impl (F : Ffi) : @abrStep F = @abrStepImpl F := by
  funext s f a; cases f <;> rfl

section
variable {F1 F2 : Ffi} [FfiRel F1 F2] [FfiSim F1 F2]
theorem rel_abrStep (a0 : St F1.S) (a0_x : F2.S) (a0_hx : FfiRel.R a0.ffi a0_x) (a1 : Frame) (a2 : Abrupt) :
    MR CRel.r (abrStep F1 a0 a1 a2) (abrStep F2 (a0.reFfi a0_x) a1 a2) := by
  rw [abrStep_impl, abrStep_impl]
  exact rel_abrStepImpl _ _ a0 a0_x a0_hx a1 a2
end

section
variable {F1 F2 : Ffi} [FfiRel F1 F2] [FfiSim F1 F2]
rel_derive stepAbrImpl
end

theorem stepAbr_impl (F : Ffi) : @stepAbr F = @stepAbrImpl F := by
  funext s a; unfold stepAbr stepAbrImpl; rcases s.stack with _ | ⟨f, fs⟩ <;> rfl

section
variable {F1 F2 : Ffi} [FfiRel F1 F2] [FfiSim F1 F2]
theorem rel_stepAbr (a0 : St F1.S) (a0_x : F2.S) (a0_hx : FfiRel.R a0.ffi a0_x) (a1 : Abrupt) :
    MR CRel.r (stepAbr F1 a0 a1) (stepAbr F2 (a0.reFfi a0_x) a1) := by
  rw [stepAbr_impl, stepAbr_impl]
  exact rel_stepAbrImpl _ _ a0 a0_x a0_hx a1
end

rel_derive objN.mk
rel_derive_ffi objN.mk
rel_derive objN.hasOwn
rel_derive_ffi objN.hasOwn
rel_derive arrayOf
rel_derive_ffi arrayOf
rel_derive objN.go
rel_derive_ffi objN.go
rel_derive objN.goA
rel_derive_ffi objN.goA
rel_derive objN
rel_derive_ffi objN
rel_derive arrN.withArr
rel_derive_ffi arrN.withArr
rel_derive setArray
rel_derive_ffi setArray
rel_derive_indep relIdx
rel_derive indexOfL
rel_derive_ffi indexOfL
rel_derive joinStr
rel_derive_ffi joinStr
rel_derive arrN.go
rel_derive_ffi arrN.go
rel_derive arrN
rel_derive_ffi arrN
rel_derive iterN.mk
rel_derive_ffi iterN.mk
rel_derive iterN
rel_derive_ffi iterN
rel_derive mathN.un
rel_derive_ffi mathN.un
rel_derive mathN.lit
rel_derive_ffi mathN.lit
rel_derive mathN.fold
rel_derive_ffi mathN.fold
rel_derive mathN.«lit?»
rel_derive_ffi mathN.«lit?»
rel_derive mathN
rel_derive_ffi mathN
rel_derive numN.litTest
rel_derive_ffi numN.litTest
rel_derive numN.str
rel_derive_ffi numN.str
rel_derive numN
rel_derive_ffi numN
rel_derive_indep thisStr
rel_derive_indep strArg
rel_derive_indep strN.go
rel_derive strN
rel_derive_ffi strN
rel_derive_indep str2N.go
rel_derive_indep str2N.goC
rel_derive str2N
rel_derive_ffi str2N
rel_derive errN.mk
rel_derive_ffi errN.mk
rel_derive errN
rel_derive_ffi errN
rel_derive pairsOf
rel_derive_ffi pairsOf

end Host.Ts.FfiNat

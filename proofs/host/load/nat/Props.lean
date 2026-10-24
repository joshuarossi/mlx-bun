import host.load.nat.Derive
namespace Host.Ts.FfiNat
open Host.Ts

section
variable {F1 F2 : Ffi} [FfiRel F1 F2] [FfiReadSim F1 F2]

@[rel_simp] theorem rel_bufBytes (s : St F1.S) (x : F2.S) (hx : FfiRel.R s.ffi x) (b : Nat) :
    bufBytes F2 (s.reFfi x) b = bufBytes F1 s b := by
  unfold bufBytes
  simp only [rel_simp, ← FfiReadSim.read _ _ hx]

end

end Host.Ts.FfiNat

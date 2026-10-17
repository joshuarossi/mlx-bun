import Std

namespace Inference.Contracts.Mlx.M1Max

abbrev WordMemory := Nat → Float32
abbrev ThreadgroupLoad := WordMemory → Nat → Float32

/- Platform premise for the M1 Max threadgroup float load used by
   trellis_codebook_window. Addresses are bytes; memory is indexed by words.
   The premise is supplied by the target's hardware contract, not proved from
   software and not declared as a global axiom. It says nothing about the
   correctness of any kernel, table contents, index calculation, or arithmetic.

   Memory denotes the visible contents after the preceding threadgroup barrier.
   Source-to-machine compilation and the memory/barrier execution model are
   separate platform boundaries; this contract only states the load operation. -/
structure LoadContract (load : ThreadgroupLoad) : Prop where
  ignoresLowAddressBits : ∀ (memory : WordMemory) (base words offset : Nat),
    base % 4 = 0 → base + 4 * words ≤ 2^64 → offset < 4 * words →
    load memory (base + offset) = memory (base / 4 + offset / 4)

-- A concrete mathematical implementation satisfies the premise. This is a
-- consistency witness, not a claim to have verified Apple's physical circuit.
def alignedLoad (memory : WordMemory) (address : Nat) : Float32 := memory (address / 4)

theorem alignedLoad_contract : LoadContract alignedLoad := by
  constructor
  intro memory base words offset ha _hn _ho
  unfold alignedLoad
  congr 1
  omega

theorem float_eq_of_bits_eq (a b : Float32) (h : a.toBits = b.toBits) : a = b := by
  cases a with
  | ofModel a =>
    cases b with
    | ofModel b =>
      cases a with
      | mk ab av =>
        cases b with
        | mk bb bv =>
          change ab = bb at h
          cases h
          rfl

end Inference.Contracts.Mlx.M1Max

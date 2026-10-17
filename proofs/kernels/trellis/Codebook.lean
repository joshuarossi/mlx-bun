import Std

/-
Arithmetic and packed-state obligations for the Qwen3.8-27B Trellis M1 Max graph.
Run: bun proofs/check.ts (Lean 4.35.0 must be on PATH).

Paths under proofs/ mirror packages/inference/src/, with PascalCase Lean
module filenames. This module corresponds to kernels/trellis/codebook.ts.

The definitions below are manually reviewed translations of helpers in
packages/inference/src/kernels/trellis/codebook.ts. check.ts pins that source;
the pin prevents silent drift but does not prove the translation correct.

BitVec 32 models Metal uint arithmetic modulo 2^32. The signed cast and
subtraction are modeled by BitVec.toInt; the theorems establish that neither
the cast nor the signed subtraction overflows.

All proofs use ordinary proof terms checked by Lean's logical kernel. The
axiom checks below permit only propext, Classical.choice, and Quot.sound;
native computation assumptions, custom axioms, and proof holes are rejected.

This proves helper arithmetic, floating-point decoder contracts, and packed
window extraction. It does not prove GPU execution, a complete projection
kernel, a layer, or the inference graph. Float32 uses Lean 4.35's reducible
binary32 model (round to nearest, ties to even); Metal compilation and hardware
correspondence remain outside these proofs.
-/
namespace Inference.Kernels.Trellis.Codebook

def mix (s : BitVec 32) : BitVec 32 := s * 34038481 + 76625530

def packedSum (x : BitVec 32) : BitVec 32 :=
  let p := (x &&& 0x00FF00FF) + ((x >>> 8) &&& 0x00FF00FF)
  (p &&& 0xFFFF) + (p >>> 16)

def byteSum (x : BitVec 32) : BitVec 32 :=
  (x &&& 255#32) + ((x >>> 8) &&& 255#32) +
  ((x >>> 16) &&& 255#32) + ((x >>> 24) &&& 255#32)

def implementation (s : BitVec 32) : Int := (packedSum (mix s)).toInt - 510

-- The specification uses mathematical integers, not a wrapping byte sum.
def specification (s : BitVec 32) : Int :=
  let x := mix s
  (x &&& 255#32).toNat + ((x >>> 8) &&& 255#32).toNat +
    ((x >>> 16) &&& 255#32).toNat + ((x >>> 24) &&& 255#32).toNat - (510 : Int)

private theorem mask8 (n : Nat) : n &&& 255 = n % 256 := by
  exact Nat.and_two_pow_sub_one_eq_mod n 8

private theorem mask16 (n : Nat) : n &&& 65535 = n % 65536 := by
  exact Nat.and_two_pow_sub_one_eq_mod n 16

-- The alternating-byte mask is two independent 16-bit lanes.
private theorem maskPairs (n : Nat) :
    n &&& 16711935 = n % 256 + 65536 * (n / 65536 % 256) := by
  have hm := Nat.and_mod_two_pow (a := n) (b := 16711935) (n := 16)
  have hd := Nat.and_div_two_pow (a := n) (b := 16711935) (n := 16)
  simp only [show 2^16 = 65536 from rfl, show 16711935 % 65536 = 255 from rfl,
    show 16711935 / 65536 = 255 from rfl, mask8] at hm hd
  have he := Nat.mod_add_div (n &&& 16711935) 65536
  omega

-- Each lane holds at most 255 + 255, so neither lane carries into the other
-- and their packed sum cannot overflow uint32. Folding the lanes sums bytes.
theorem packedSum_toNat (x : BitVec 32) :
    (packedSum x).toNat = x.toNat % 256 + (x.toNat / 256) % 256 +
      (x.toNat / 65536) % 256 + (x.toNat / 16777216) % 256 := by
  have hp : x.toNat % 256 + 65536 * (x.toNat / 65536 % 256) +
      (x.toNat / 256 % 256 + 65536 * (x.toNat / 16777216 % 256)) < 4294967296 := by
    have h0 := Nat.mod_lt x.toNat (by decide : 0 < 256)
    have h1 := Nat.mod_lt (x.toNat / 256) (by decide : 0 < 256)
    have h2 := Nat.mod_lt (x.toNat / 65536) (by decide : 0 < 256)
    have h3 := Nat.mod_lt (x.toNat / 16777216) (by decide : 0 < 256)
    omega
  simp [packedSum, BitVec.toNat_add, BitVec.toNat_and, BitVec.toNat_ushiftRight,
    Nat.shiftRight_eq_div_pow, mask16, maskPairs, Nat.div_div_eq_div_mul]
  rw [Nat.mod_eq_of_lt hp]
  have hpack : x.toNat % 256 + 65536 * (x.toNat / 65536 % 256) +
      (x.toNat / 256 % 256 + 65536 * (x.toNat / 16777216 % 256)) =
      (x.toNat % 256 + x.toNat / 256 % 256) +
      65536 * (x.toNat / 65536 % 256 + x.toNat / 16777216 % 256) := by omega
  rw [hpack]
  have hlo : x.toNat % 256 + x.toNat / 256 % 256 < 65536 := by omega
  simp only [Nat.add_mul_mod_self_left, Nat.add_mul_div_left _ _ (by decide : 0 < 65536),
    Nat.mod_eq_of_lt hlo, Nat.div_eq_of_lt hlo, Nat.zero_add]
  omega

theorem byteSum_no_wrap (x : BitVec 32) :
    (byteSum x).toNat = (x &&& 255#32).toNat + ((x >>> 8) &&& 255#32).toNat +
      ((x >>> 16) &&& 255#32).toNat + ((x >>> 24) &&& 255#32).toNat := by
  have bound (v : BitVec 32) : (v &&& 255#32).toNat ≤ 255 := by
    simpa using (Nat.and_le_right (n := v.toNat) (m := 255))
  have h0 := bound x
  have h1 := bound (x >>> 8)
  have h2 := bound (x >>> 16)
  have h3 := bound (x >>> 24)
  simp only [byteSum, BitVec.toNat_add]
  omega

theorem packedSum_eq_byteSum (x : BitVec 32) : packedSum x = byteSum x := by
  apply BitVec.eq_of_toNat_eq
  rw [packedSum_toNat, byteSum_no_wrap]
  simp [BitVec.toNat_and, BitVec.toNat_ushiftRight, Nat.shiftRight_eq_div_pow, mask8]

theorem packedSum_bound (x : BitVec 32) : packedSum x ≤ 1020 := by
  simp only [BitVec.le_def, packedSum_toNat]
  change x.toNat % 256 + (x.toNat / 256) % 256 +
    (x.toNat / 65536) % 256 + (x.toNat / 16777216) % 256 ≤ 1020
  omega

theorem correct (s : BitVec 32) : implementation s = specification s := by
  have hb := packedSum_bound (mix s)
  have hn := byteSum_no_wrap (mix s)
  have he := packedSum_eq_byteSum (mix s)
  simp [BitVec.le_def] at hb
  simp only [implementation, specification, BitVec.toInt_eq_toNat_cond]
  rw [ite_eq_left (by omega)]
  rw [he, hn]
  omega

theorem range (s : BitVec 32) : -510 ≤ implementation s ∧ implementation s ≤ 510 := by
  have hb := packedSum_bound (mix s)
  simp [BitVec.le_def] at hb
  simp only [implementation, BitVec.toInt_eq_toNat_cond]
  rw [ite_eq_left (by omega)]
  omega

/-- info: 'Inference.Kernels.Trellis.Codebook.correct' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms correct
/-- info: 'Inference.Kernels.Trellis.Codebook.range' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms range

namespace PackedState
def implementation (lo hi : BitVec 32) (off : Nat) : BitVec 32 :=
  (if off + 12 > 32 then (lo >>> off) ||| (hi <<< (32-off)) else lo >>> off) &&& 4095#32

theorem mask_bit (j : Nat) : (4095#32).getLsbD j = decide (j < 12) := by
  change Nat.testBit (2^12-1) j = decide (j < 12)
  exact Nat.testBit_two_pow_sub_one 12 j

theorem correct (lo hi : BitVec 32) (off j : Nat) (ho : off < 32) (hj : j < 12) :
    (implementation lo hi off).getLsbD j =
    (hi ++ lo).getLsbD (off+j) := by
  unfold implementation
  simp only [BitVec.getLsbD_and, mask_bit, hj, decide_true, Bool.and_true]
  split
  next h =>
    simp only [BitVec.getLsbD_or, BitVec.getLsbD_ushiftRight, BitVec.getLsbD_shiftLeft,
      BitVec.getLsbD_append]
    by_cases hc : off+j < 32
    · simp [hc, show j < 32-off by omega]
    · have he : j-(32-off) = off+j-32 := by omega
      simp [hc, he, show ¬j < 32-off by omega, show j < 32 by omega,
        BitVec.getLsbD_of_ge lo (off+j) (by omega)]
  next h =>
    simp only [BitVec.getLsbD_ushiftRight, BitVec.getLsbD_append]
    simp only [show off+j < 32 by omega, ite_true]

theorem geometry (k t : Nat) (hk : k=2 ∨ k=3 ∨ k=4) (ht : t<256) :
    (255-t)*k < 2^32 ∧ ((255-t)*k)/32 < 8*k ∧ ((255-t)*k)%32 < 32 ∧
    (if ((255-t)*k)/32+1 = 8*k then 0 else ((255-t)*k)/32+1) < 8*k := by
  rcases hk with hk | hk | hk <;> subst k <;> split <;> omega

def read (w : Nat → BitVec 32) (k t : Nat) : BitVec 32 :=
  let p := (255-t)*k
  let wi := p/32
  let next := if wi+1=8*k then 0 else wi+1
  implementation (w wi) (w next) (p%32)

theorem cyclic_correct (w : Nat → BitVec 32) (k t j : Nat)
    (hk : k=2 ∨ k=3 ∨ k=4) (ht : t<256) (hj : j<12) :
    (read w k t).getLsbD j =
      (w ((((255-t)*k+j)%(256*k))/32)).getLsbD (((255-t)*k+j)%32) := by
  unfold read
  rw [correct _ _ _ _ (by omega) hj, BitVec.getLsbD_append]
  split
  next hc =>
    have hn : (255-t)*k+j < 256*k := by
      rcases hk with hk | hk | hk <;> subst k <;> omega
    rw [Nat.mod_eq_of_lt hn]
    have hw : (255-t)*k/32 = (((255-t)*k+j)%(256*k))/32 := by
      rw [Nat.mod_eq_of_lt hn]
      omega
    have hb : (255-t)*k%32+j = ((255-t)*k+j)%32 := by omega
    rw [Nat.mod_eq_of_lt hn] at hw
    rw [hw, hb]
  next hc =>
    have hw : (if (255-t)*k/32+1=8*k then 0 else (255-t)*k/32+1) =
        (((255-t)*k+j)%(256*k))/32 := by
      split
      next hlast =>
        rcases hk with hk | hk | hk <;> subst k <;> omega
      next hlast =>
        have hn : (255-t)*k+j < 256*k := by
          rcases hk with hk | hk | hk <;> subst k <;> omega
        rw [Nat.mod_eq_of_lt hn]
        omega
    have hb : (255-t)*k%32+j-32 = ((255-t)*k+j)%32 := by omega
    rw [hw, hb]

end PackedState


namespace CodebookWindow
def virtualWord (w : Nat → BitVec 32) (i : Nat) : BitVec 32 :=
  if i = 0 then w 0 <<< 16 else (w (i-1) >>> 16) ||| (w i <<< 16)

def byteOffset (w : Nat → BitVec 32) (off : Nat) : BitVec 32 :=
  if 2 ≤ off ∧ (off - 2) % 32 + 14 ≤ 32 then
    (w ((off-2)/32) >>> ((off-2)%32)) &&& 16383#32
  else
    (virtualWord w ((off+14)/32) >>> ((off+14)%32)) &&& 16383#32

theorem mask_bit (j : Nat) : (16383#32).getLsbD j = decide (j < 14) := by
  change Nat.testBit (2^14-1) j = decide (j < 14)
  exact Nat.testBit_two_pow_sub_one 14 j

theorem correct (w : Nat → BitVec 32) (off j : Nat) (ho : off ≤ 124) (hj : j < 12) :
    (byteOffset w off >>> 2).getLsbD j =
      (w ((off+j)/32)).getLsbD ((off+j)%32) := by
  unfold byteOffset
  split
  next h =>
    simp only [BitVec.getLsbD_ushiftRight, BitVec.getLsbD_and, mask_bit]
    have hmask : 2 + j < 14 := by omega
    simp only [hmask, decide_true, Bool.and_true]
    have hw : (off - 2) / 32 = (off+j)/32 := by omega
    have hb : (off - 2) % 32 + (2+j) = (off+j)%32 := by omega
    simp only [hw, hb]
  next h =>
    simp only [BitVec.getLsbD_ushiftRight, BitVec.getLsbD_and, mask_bit]
    have hmask : 2 + j < 14 := by omega
    simp only [hmask, decide_true, Bool.and_true]
    unfold virtualWord
    split
    next hz =>
      simp only [BitVec.getLsbD_shiftLeft]
      have hbit : 16 ≤ (off+14)%32 + (2+j) := by omega
      have he : (off+14)%32+(2+j)-16 = (off+j)%32 := by omega
      have hw : (off+j)/32 = 0 := by omega
      have hu : (off+14)%32+(2+j) < 32 := by omega
      simp [hbit, he, hw, hu]
    next hn =>
      simp only [BitVec.getLsbD_or, BitVec.getLsbD_ushiftRight, BitVec.getLsbD_shiftLeft]
      by_cases hb : (off+14)%32+(2+j) < 16
      · have hw : (off+14)/32-1 = (off+j)/32 := by omega
        have he : 16+((off+14)%32+(2+j)) = (off+j)%32 := by omega
        simp [hw, he, show ¬16 ≤ (off+14)%32+(2+j) by omega]
      · have hw : (off+14)/32 = (off+j)/32 := by omega
        have he : (off+14)%32+(2+j)-16 = (off+j)%32 := by omega
        have hi : 32 ≤ 16+((off+14)%32+(2+j)) := by omega
        have hu : (off+14)%32+(2+j) < 32 := by omega
        simp [hw, he, hu, BitVec.getLsbD_of_ge _ _ hi, show 16 ≤ (off+14)%32+(2+j) by omega]

theorem byteOffset_bound (w : Nat → BitVec 32) (off : Nat) :
    (byteOffset w off).toNat < 16384 := by
  have bound (v : BitVec 32) : (v &&& 16383#32).toNat ≤ 16383 := by
    simpa using (Nat.and_le_right (n := v.toNat) (m := 16383))
  unfold byteOffset
  split <;> exact Nat.lt_of_le_of_lt (bound _) (by decide)

theorem index_bound (w : Nat → BitVec 32) (off : Nat) :
    (byteOffset w off >>> 2).toNat < 4096 := by
  have h := byteOffset_bound w off
  simp only [BitVec.toNat_ushiftRight, Nat.shiftRight_eq_div_pow]
  omega

theorem load_indices (off : Nat) (ho : off ≤ 60) :
    (off-2)/32 < 3 ∧ (off+14)/32 < 3 ∧ (off+14)/32-1 < 3 ∧
    (off-2)%32 < 32 ∧ (off+14)%32 < 32 := by omega

theorem lane_geometry (k i : Nat) (hk : k=2 ∨ k=3 ∨ k=4) (hi : i<16) :
    i*k ≤ 60 ∧ (i*k-2)/32 < (15*k+43)/32 ∧
    (i*k+14)/32 < (15*k+43)/32 ∧
    (i*k+14)/32-1 < (15*k+43)/32 := by
  rcases hk with hk | hk | hk <;> subst k <;> omega

-- This is a valid k=2, i=1 window and demonstrates why the arithmetic proof
-- cannot establish a portable aligned float load. M1 load semantics are needed.
theorem unaligned_witness : (byteOffset (fun _ => 1#32) 2).toNat % 4 = 1 := by decide

end CodebookWindow


namespace FloatingPoint
set_option maxRecDepth 10000
set_option maxHeartbeats 0

def divisor : Float32 := 147.800537109375

def reference (y : Int) : Float32 := Float32.ofInt y / divisor

def reciprocal : Float32 := 1 / divisor

def unrefined (y : Int) : Float32 := Float32.ofInt y * reciprocal

def refined (y : Int) : Float32 :=
  let yf := Float32.ofInt y
  let q := yf * reciprocal
  let e := Float32.fma (-q) divisor yf
  Float32.fma e reciprocal q

def lifted (y : Int) : Float32 :=
  Float32.ofBits (0x4b000000 ||| UInt32.ofInt (y + 510)) - 8389118

theorem lifted_correct : ∀ i : Fin 1021,
    (lifted (i.val - 510)).toBits = (Float32.ofInt (i.val - 510)).toBits := by decide +kernel

theorem refined_correct : ∀ i : Fin 1021,
    (refined (i.val - 510)).toBits = (reference (i.val - 510)).toBits := by decide +kernel

-- Float.toFloat32 is opaque; explicitly round its binary64 logical value.
def narrow (v : Float) : Float32 :=
  let rounded := match v.toModel.unpack with
    | .finite s m e _ => Float.Model.UnpackedFloat.round .binary32 s m e
    | x => x
  Float32.ofModel (Float32.Model.pack rounded)

def host (y : Int) : Float32 := narrow (Float.ofInt y / (147.800537109375 : Float))

theorem host_correct : ∀ i : Fin 1021,
    (host (i.val - 510)).toBits = (reference (i.val - 510)).toBits := by decide +kernel

-- Exact dyadic value in units of 2^-32. For this domain, exponents are >= -32.
def scaled (v : Float32) : Int := match v.toModel.unpack with
  | .finite s m e _ => s.apply (m * 2^(e + 32).toNat)
  | _ => 0

def representable (v : Float32) : Bool := match v.toModel.unpack with
  | .finite _ _ e _ => decide (-32 ≤ e)
  | .zero _ => true
  | _ => false

def errorNumerator (v : Float32) (y : Int) : Nat :=
  (scaled v * 605391 - y * 4096 * 2^32).natAbs

-- Since d = 605391/4096, these integer inequalities state relative error
-- bounds of 2^-24 and 2^-23 against the exact rational y/d. At y=0 they
-- assert zero absolute error. representable ensures scaled is the exact
-- dyadic value multiplied by 2^32, not its fallback for non-finite inputs.
theorem reference_accuracy : ∀ i : Fin 1021,
    representable (reference (i.val - 510)) = true ∧
    errorNumerator (reference (i.val - 510)) (i.val - 510) * 2^24 ≤
      ((i.val - 510 : Int) * 4096 * 2^32).natAbs := by decide +kernel

theorem unrefined_relative_accuracy : ∀ i : Fin 1021,
    representable (unrefined (i.val - 510)) = true ∧
    errorNumerator (unrefined (i.val - 510)) (i.val - 510) * 2^23 ≤
      ((i.val - 510 : Int) * 4096 * 2^32).natAbs := by decide +kernel

theorem unrefined_accuracy : ∀ i : Fin 1021,
    ((unrefined (i.val - 510)).toBits.toNat : Int) - (reference (i.val - 510)).toBits.toNat ≤ 1 ∧
    ((reference (i.val - 510)).toBits.toNat : Int) - (unrefined (i.val - 510)).toBits.toNat ≤ 1 ∧
    (unrefined (i.val - 510)).isFinite = true := by decide +kernel

-- The fast decoder's contract is accuracy, not equality to precise division.
theorem unrefined_not_exact : (unrefined 9).toBits ≠ (reference 9).toBits := by decide +kernel

private theorem eq_of_bits_eq (a b : Float32) (h : a.toBits = b.toBits) : a = b := by
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

-- Compose the integer range theorem with the exhaustive binary32 proof.
-- These statements cover every uint32 state, not just the 4096 LUT entries.
def stateIndex (s : BitVec 32) : Fin 1021 :=
  ⟨(implementation s + 510).toNat, by have h := range s; omega⟩

theorem stateIndex_value (s : BitVec 32) : (stateIndex s).val - (510 : Int) = implementation s := by
  have h := range s
  simp only [stateIndex]
  omega

theorem refined_state_correct (s : BitVec 32) :
    (refined (implementation s)).toBits = (host (specification s)).toBits := by
  have hr := refined_correct (stateIndex s)
  have hh := host_correct (stateIndex s)
  rw [stateIndex_value] at hr hh
  rw [← correct s]
  exact hr.trans hh.symm

theorem lifted_state_correct (s : BitVec 32) :
    lifted (implementation s) = Float32.ofInt (specification s) := by
  apply eq_of_bits_eq
  have h := lifted_correct (stateIndex s)
  rw [stateIndex_value, correct] at h
  simpa only [correct] using h

theorem unrefined_bits_state_correct (s : BitVec 32) :
    (lifted (implementation s) * reciprocal).toBits =
      (unrefined (specification s)).toBits := by
  rw [lifted_state_correct]
  rfl

theorem unrefined_state_accuracy (s : BitVec 32) :
    representable (unrefined (implementation s)) = true ∧
    errorNumerator (unrefined (implementation s)) (specification s) * 2^23 ≤
      (specification s * 4096 * 2^32).natAbs := by
  have h := unrefined_relative_accuracy (stateIndex s)
  rw [stateIndex_value] at h
  simpa only [correct] using h

def bfloat (v : Float32) : Float32 :=
  let u := v.toBits
  Float32.ofBits ((u + (0x7fff : UInt32) + ((u >>> (16 : UInt32)) &&& (1 : UInt32))) &&& (0xffff0000 : UInt32))

def bfloatReference (v : Float32) : Float32 :=
  let fmt : Float.Model.Format := { mantissaBitsWithoutImplicit := 7, exponentBits := 8 }
  let rounded := match v.toModel.unpack with
    | .finite s m e _ => Float.Model.UnpackedFloat.round fmt s m e
    | x => x
  -- Re-normalize the 8-significand-bit result for binary32 packing.
  let widened := match rounded with
    | .finite s m e _ => Float.Model.UnpackedFloat.round .binary32 s m e
    | x => x
  Float32.ofModel (Float32.Model.pack widened)

theorem bfloat_correct : ∀ i : Fin 1021,
    (bfloat (reference (i.val - 510))).toBits = (bfloatReference (reference (i.val - 510))).toBits := by decide +kernel

theorem bfloat_state_correct (s : BitVec 32) :
    (bfloat (refined (implementation s))).toBits =
      (bfloatReference (host (specification s))).toBits := by
  have hr := refined_correct (stateIndex s)
  have hh := host_correct (stateIndex s)
  have hb := bfloat_correct (stateIndex s)
  rw [stateIndex_value] at hr hh hb
  rw [eq_of_bits_eq _ _ hr, ← correct s, eq_of_bits_eq _ _ hh]
  exact hb
end FloatingPoint

end Inference.Kernels.Trellis.Codebook

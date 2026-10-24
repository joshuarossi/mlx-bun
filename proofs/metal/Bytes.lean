import metal.Launch
import contracts.mlx.HalfMemory

namespace Metal
open Core Inference.Contracts.Mlx

/-! # Bytes, words and bit fields

The little-endian bytes of words (`wordBytes`, `bytesWord`), runs of buffer bytes (`cells`), the bits of
the floating-point formats, the elements of buffers (`bfAt`, `f32At`, …), the value of a run of words
(`runBits`) and its bit fields, and element-index arithmetic. -/


/-! ## Writes, words and their bytes -/

theorem writeBytes_outside (memory : ByteMemory.Bytes) (o : Nat) (bytes : List (BitVec 8)) (b : Nat)
    (h : b < o ∨ o + bytes.length ≤ b) : writeBytes memory o bytes b = memory b := by
  unfold writeBytes; split
  · omega
  · rfl

theorem writeBytes_inside (memory : ByteMemory.Bytes) (o : Nat) (bytes : List (BitVec 8)) (i : Nat)
    (h : i < bytes.length) : writeBytes memory o bytes (o + i) = bytes.getD i 0 := by
  unfold writeBytes; rw [ite_eq_left (by omega)]; congr 1; omega

theorem wordBytes_length (n w : Nat) : (wordBytes n w).length = n := by simp [wordBytes]

theorem bytesWord_cons (b : BitVec 8) (bs : List (BitVec 8)) : bytesWord (b :: bs) = b.toNat + 256 * bytesWord bs :=
  rfl

theorem bytesWord_lt : ∀ bs : List (BitVec 8), bytesWord bs < 256 ^ bs.length
  | [] => by simp [bytesWord]
  | b :: bs => by
    have h1 := bytesWord_lt bs
    have h2 : b.toNat < 256 := b.isLt
    rw [bytesWord_cons, List.length_cons, Nat.pow_succ]
    generalize bytesWord bs = w at *
    generalize 256 ^ bs.length = X at *
    omega

theorem bytesWord_wordBytes : ∀ (n w : Nat), bytesWord (wordBytes n w) = w % 256 ^ n
  | 0, w => by simp [bytesWord, wordBytes, Nat.mod_one]
  | n + 1, w => by
    have hs : wordBytes (n + 1) w = BitVec.ofNat 8 w :: wordBytes n (w / 256) := by
      unfold wordBytes
      rw [List.range_succ_eq_map, List.map_cons, List.map_map]
      congr 1
      · simp
      · apply List.map_congr_left
        intro i _
        simp only [Function.comp, Nat.succ_eq_add_one, Nat.pow_succ, Nat.div_div_eq_div_mul, Nat.mul_comm]
    rw [hs, bytesWord_cons, bytesWord_wordBytes n (w / 256), BitVec.toNat_ofNat]
    show w % 256 + 256 * (w / 256 % 256 ^ n) = w % 256 ^ (n + 1)
    rw [Nat.pow_succ, Nat.mul_comm (256 ^ n) 256, Nat.mod_mul]

theorem bytesWord_wordBytes2 (w : Nat) : bytesWord (wordBytes 2 w) = w % 2 ^ 16 := by
  simp [wordBytes, bytesWord, List.range_succ]
  omega

theorem bytesWord_wordBytes4 (w : Nat) : bytesWord (wordBytes 4 w) = w % 2 ^ 32 := by
  simp [wordBytes, bytesWord, List.range_succ]
  omega

theorem bytesWord_wordBytes2_of_lt (w : Nat) (hw : w < 2 ^ 16) : bytesWord (wordBytes 2 w) = w := by
  simp [wordBytes, bytesWord, List.range_succ, BitVec.toNat_ofNat]
  omega

theorem bytesWord_wordBytes4_of_lt (w : Nat) (hw : w < 2 ^ 32) : bytesWord (wordBytes 4 w) = w := by
  simp [wordBytes, bytesWord, List.range_succ, BitVec.toNat_ofNat]
  omega

theorem map_getD_wordBytes (n w : Nat) : (List.range n).map (fun j => (wordBytes n w).getD j 0) = wordBytes n w := by
  conv_rhs => unfold wordBytes
  apply List.map_congr_left
  intro j hj
  rw [List.mem_range] at hj
  simp [wordBytes, List.getD_eq_getElem?_getD, List.getElem?_range hj]

theorem ofNat8_eq (x : BitVec 8) (n : Nat) (h : n % 256 = x.toNat) : BitVec.ofNat 8 n = x :=
  BitVec.eq_of_toNat_eq (by simp [h])

theorem ofNat8_toNat (x : BitVec 8) : BitVec.ofNat 8 x.toNat = x := BitVec.ofNat_toNat 8 x |>.trans (by simp)

theorem wordBytes4_bytesWord (a b c d : BitVec 8) : wordBytes 4 (bytesWord [a, b, c, d]) = [a, b, c, d] := by
  have ha := a.isLt; have hb := b.isLt; have hc := c.isLt; have hd := d.isLt
  show [BitVec.ofNat 8 (bytesWord [a, b, c, d] / 256 ^ 0), BitVec.ofNat 8 (bytesWord [a, b, c, d] / 256 ^ 1),
    BitVec.ofNat 8 (bytesWord [a, b, c, d] / 256 ^ 2), BitVec.ofNat 8 (bytesWord [a, b, c, d] / 256 ^ 3)] = _
  simp only [bytesWord, List.foldr_cons, List.foldr_nil]
  rw [ofNat8_eq a _ (by omega), ofNat8_eq b _ (by omega), ofNat8_eq c _ (by omega), ofNat8_eq d _ (by omega)]

theorem wordBytes2_bytesWord (a b : BitVec 8) : wordBytes 2 (bytesWord [a, b]) = [a, b] := by
  have ha := a.isLt; have hb := b.isLt
  show [BitVec.ofNat 8 (bytesWord [a, b] / 256 ^ 0), BitVec.ofNat 8 (bytesWord [a, b] / 256 ^ 1)] = _
  simp only [bytesWord, List.foldr_cons, List.foldr_nil]
  rw [ofNat8_eq a _ (by omega), ofNat8_eq b _ (by omega)]

/-! ## Runs of bytes -/

/-- The `n` bytes of `memory` from byte `o`. -/
def cells (memory : ByteMemory.Bytes) (o n : Nat) : List (BitVec 8) := (List.range n).map fun i => memory (o + i)

theorem cells_length (memory : ByteMemory.Bytes) (o n : Nat) : (cells memory o n).length = n := by simp [cells]

theorem cells_getD (memory : ByteMemory.Bytes) (o n i : Nat) (h : i < n) : (cells memory o n).getD i 0 = memory (o + i) := by
  simp [cells, List.getD_eq_getElem?_getD, h]

theorem cells_two (B : ByteMemory.Bytes) (o : Nat) : cells B o 2 = [B (o + 0), B (o + 1)] := rfl

theorem cells_succ (B : ByteMemory.Bytes) (o n : Nat) : cells B o (n + 1) = B o :: cells B (o + 1) n := by
  simp only [cells, List.range_succ_eq_map, List.map_cons, List.map_map, Nat.add_zero]
  congr 1
  apply List.map_congr_left
  intro i _
  simp [Function.comp, Nat.add_assoc, Nat.add_comm 1]

theorem cells_append (B : ByteMemory.Bytes) (o m n : Nat) : cells B o (m + n) = cells B o m ++ cells B (o + m) n := by
  apply List.ext_getElem
  · simp [cells]
  · intro j h1 h2
    simp only [cells_length] at h1
    by_cases hj : j < m
    · rw [List.getElem_append_left (by rw [cells_length]; exact hj)]
      simp [cells]
    · rw [List.getElem_append_right (by rw [cells_length]; omega)]
      simp only [cells, List.getElem_map, List.getElem_range, List.length_map, List.length_range]
      congr 1; omega

theorem cells_drop_take (B : ByteMemory.Bytes) (o n a b : Nat) (h : a + b ≤ n) :
    ((cells B o n).drop a).take b = cells B (o + a) b := by
  apply List.ext_getElem
  · simp [cells]; omega
  · intro k h1 h2
    simp [cells, List.getElem_drop, List.getElem_take, Nat.add_assoc]

theorem cells_writeBytes_same (memory : ByteMemory.Bytes) (o : Nat) (bs : List (BitVec 8)) :
    cells (writeBytes memory o bs) o bs.length = bs := by
  apply List.ext_getElem
  · simp [cells]
  · intro i h1 h2
    simp [cells, writeBytes, List.getD_eq_getElem?_getD, h2]

theorem cells_writeBytes_of_length (B : ByteMemory.Bytes) (o n : Nat) (bs : List (BitVec 8)) (h : bs.length = n) :
    cells (writeBytes B o bs) o n = bs := by
  subst h; exact cells_writeBytes_same B o bs

theorem cells_writeBytes_other (memory : ByteMemory.Bytes) (o o' n : Nat) (bs : List (BitVec 8))
    (h : o' + n ≤ o ∨ o + bs.length ≤ o') : cells (writeBytes memory o bs) o' n = cells memory o' n := by
  unfold cells
  apply List.map_congr_left
  intro i hi
  simp only [List.mem_range] at hi
  unfold writeBytes
  rw [ite_eq_right_iff.mpr (fun h => absurd h (by omega))]

/-- Bytes `a … a + n - 1` of a write, read back. -/
theorem cells_writeBytes_sub (B : ByteMemory.Bytes) (o a n : Nat) (bs : List (BitVec 8)) (h : a + n ≤ bs.length) :
    cells (writeBytes B o bs) (o + a) n = (bs.drop a).take n := by
  apply List.ext_getElem
  · simp [cells]; omega
  · intro i h1 h2
    simp only [cells, List.getElem_map, List.getElem_range, List.getElem_take, List.getElem_drop]
    simp only [cells, List.length_map, List.length_range] at h1
    unfold writeBytes
    rw [ite_eq_left (by omega), List.getD_eq_getElem?_getD, List.getElem?_eq_getElem (by omega)]
    simp only [Option.getD_some]
    congr 1; omega

theorem cells_shape (r K : Nat) :
    cells (fun b => (wordBytes 4 r ++ wordBytes 4 K).getD b 0) 0 4 = wordBytes 4 r := by
  apply List.ext_getElem
  · simp [cells, wordBytes_length]
  · intro j h1 h2
    simp only [cells, List.getElem_map, List.getElem_range, Nat.zero_add]
    rw [List.getD_eq_getElem?_getD, List.getElem?_append_left (by rw [wordBytes_length]; simpa [cells] using h1)]
    simp [List.getElem?_eq_getElem h2]

theorem bytesWord_cells_lt (memory : ByteMemory.Bytes) (o : Nat) : bytesWord (cells memory o 4) < 2 ^ 32 := by
  have := bytesWord_lt (cells memory o 4)
  rw [cells_length] at this
  simpa using this

/-! ## The bits of values -/

theorem ofBf16Bits_bf16Bits (x : BF) : Val.ofBf16Bits (Val.bf16Bits x) = x :=
  FloatLib.Floats.Formats.BinaryInterchange.Model.ofNatBits_toNatBits x

theorem ofBf16Bits_bf16Bits_mod (x : BF) : Val.ofBf16Bits (Val.bf16Bits x % 2 ^ 16) = x := by
  have h : x.bits.toNat < 2 ^ 16 := x.bits.isLt
  show Val.ofBf16Bits (x.bits.toNat % 2 ^ 16) = x
  rw [Nat.mod_eq_of_lt h]
  exact FloatLib.Floats.Formats.BinaryInterchange.Model.ofNatBits_toNatBits x

theorem bf16Bits_lt (x : BF) : Val.bf16Bits x < 2 ^ 16 := x.bits.isLt

theorem ofF32Bits_f32Bits (x : Float32) : Val.ofF32Bits (Val.f32Bits x) = x := by
  unfold Val.ofF32Bits Val.f32Bits
  rw [BitVec.ofNat_toNat, BitVec.setWidth_eq]
  exact FloatMemory.decode_bits x

theorem ofF32Bits_f32Bits_mod (x : Float32) : Val.ofF32Bits (Val.f32Bits x % 2 ^ 32) = x := by
  unfold Val.ofF32Bits Val.f32Bits
  rw [Nat.mod_eq_of_lt (FloatMemory.bits x).isLt, BitVec.ofNat_toNat, BitVec.setWidth_eq]
  exact FloatMemory.decode_bits x

theorem f32Bits_lt (x : Float32) : Val.f32Bits x < 2 ^ 32 := (FloatMemory.bits x).isLt

theorem ofF16Bits_f16Bits (x : Float16.Value) : Val.ofF16Bits (Val.f16Bits x) = x :=
  FloatLib.Floats.Formats.BinaryInterchange.Model.ofNatBits_toNatBits x

theorem f16Bits_lt (x : Float16.Value) : Val.f16Bits x < 2 ^ 16 := x.bits.isLt

/-- A stored binary32 value loads back. -/
theorem ofWord_f32 (x : Float32) : Val.ofWord .f32 (bytesWord (wordBytes 4 (Val.f32Bits x))) = .f32 x := by
  rw [bytesWord_wordBytes, Nat.mod_eq_of_lt (by have := f32Bits_lt x; omega)]
  exact congrArg Val.f32 (ofF32Bits_f32Bits x)

/-- A stored binary16 value loads back. -/
theorem ofWord_f16 (x : Float16.Value) : Val.ofWord .f16 (bytesWord (wordBytes 2 (Val.f16Bits x))) = .f16 x := by
  rw [bytesWord_wordBytes, Nat.mod_eq_of_lt (by have := f16Bits_lt x; omega)]
  exact congrArg Val.f16 (ofF16Bits_f16Bits x)

/-- A stored `uint` loads back. -/
theorem ofWord_u32 (n : Nat) : Val.ofWord .u32 (bytesWord (wordBytes 4 n)) = u32 n := by
  rw [bytesWord_wordBytes]
  show Val.int .u32 (n % 256 ^ 4 % 2 ^ 32) = Val.int .u32 (n % 2 ^ 32)
  rw [show (256 : Nat) ^ 4 = 2 ^ 32 by norm_num, Nat.mod_mod]

theorem ofWord_i32 {r : Nat} (h : r < 2 ^ 31) : Val.ofWord .i32 (bytesWord (wordBytes 4 r)) = .int .i32 r := by
  rw [bytesWord_wordBytes]
  show Val.int .i32 (r % 256 ^ 4 % 2 ^ 32) = _
  congr 1; omega

theorem encode_f32 (x : Float32) : encode (.scalar .f32) (.f32 x) = some (wordBytes 4 (Val.f32Bits x)) := rfl

theorem encode_f16 (x : Float16.Value) : encode (.scalar .f16) (.f16 x) = some (wordBytes 2 (Val.f16Bits x)) := rfl

theorem encode_bf16 (x : BF) : encode (.scalar .bf16) (.bf16 x) = some (wordBytes 2 (Val.bf16Bits x)) := rfl

theorem encode_u32 (n : Nat) (h : n < 2 ^ 32) : encode (.scalar .u32) (u32 n) = some (wordBytes 4 n) := by
  have e : n % 2 ^ 32 = n := Nat.mod_eq_of_lt h
  simp only [u32, e]; rfl

theorem decode_cells (s : Scalar) (memory : ByteMemory.Bytes) (o : Nat) :
    decode (.scalar s) (cells memory o s.bytes) = some (Val.ofWord s (bytesWord (cells memory o s.bytes))) := by
  simp only [decode]
  rw [List.take_of_length_le (by rw [cells_length])]

/-- Two bytes holding a bf16 word decode to it. -/
theorem decode_bf16 (M : ByteMemory.Bytes) (o : Nat) (x : BF)
    (h : ∀ i < 2, M (o + i) = (wordBytes 2 (Val.bf16Bits x)).getD i 0) :
    decode (.scalar .bf16) ((List.range 2).map fun i => M (o + i)) = some (.bf16 x) := by
  have e : (List.range 2).map (fun i => M (o + i)) = wordBytes 2 (Val.bf16Bits x) := by
    rw [show (List.range 2).map (fun i => M (o + i)) = [M (o + 0), M (o + 1)] from rfl, h 0 (by decide),
      h 1 (by decide)]
    rfl
  rw [e]
  show some (Val.ofWord .bf16 (bytesWord ((wordBytes 2 (Val.bf16Bits x)).take 2))) = _
  rw [List.take_of_length_le (by simp [wordBytes_length]), bytesWord_wordBytes2_of_lt _ (bf16Bits_lt x)]
  show some (Val.bf16 (Val.ofBf16Bits (Val.bf16Bits x))) = _
  rw [ofBf16Bits_bf16Bits]

/-- Four bytes holding a binary32 word decode to it. -/
theorem decode_f32 (M : ByteMemory.Bytes) (o : Nat) (x : Float32)
    (h : ∀ i < 4, M (o + i) = (wordBytes 4 (Val.f32Bits x)).getD i 0) :
    decode (.scalar .f32) ((List.range 4).map fun i => M (o + i)) = some (.f32 x) := by
  have e : (List.range 4).map (fun i => M (o + i)) = wordBytes 4 (Val.f32Bits x) := by
    rw [show (List.range 4).map (fun i => M (o + i)) = [M (o + 0), M (o + 1), M (o + 2), M (o + 3)] from rfl,
      h 0 (by decide), h 1 (by decide), h 2 (by decide), h 3 (by decide)]
    rfl
  rw [e]
  show some (Val.ofWord .f32 (bytesWord ((wordBytes 4 (Val.f32Bits x)).take 4))) = _
  rw [List.take_of_length_le (by simp [wordBytes_length]), bytesWord_wordBytes4_of_lt _ (f32Bits_lt x)]
  show some (Val.f32 (Val.ofF32Bits (Val.f32Bits x))) = _
  rw [ofF32Bits_f32Bits]

theorem decode_f32_bytes (x : Float32) : decode (.scalar .f32) (wordBytes 4 (Val.f32Bits x)) = some (.f32 x) := by
  simp only [decode]
  rw [List.take_of_length_le (by rw [wordBytes_length]; rfl)]
  exact congrArg some (ofWord_f32 x)

theorem decode_u32_bytes (w : Nat) : decode (.scalar .u32) (wordBytes 4 w) = some (u32 w) := by
  simp only [decode]
  rw [List.take_of_length_le (by rw [wordBytes_length]; rfl)]
  exact congrArg some (ofWord_u32 w)

/-- Two-element vectors as their elements' bytes. -/
theorem decode_vec_f16 (B : ByteMemory.Bytes) :
    decode (.vec .f16 2) (cells B 0 4) =
      some (.vec .f16 [Val.ofWord .f16 (bytesWord (cells B 0 2)), Val.ofWord .f16 (bytesWord (cells B 2 2))]) := rfl

theorem decode_vec_f32 (B : ByteMemory.Bytes) :
    decode (.vec .f32 2) (cells B 0 8) =
      some (.vec .f32 [Val.ofWord .f32 (bytesWord (cells B 0 4)), Val.ofWord .f32 (bytesWord (cells B 4 4))]) := rfl

theorem decode_ptr {r o : Nat} (hr : r < 2 ^ 24) (ho : o < 2 ^ 40) (sp : Space) (e : Ty) :
    decode (.ptr sp e) (wordBytes 8 (r * 2 ^ 40 + o)) = some (.ptr ⟨r, (o : Int), e⟩) := by
  have hw : r * 2 ^ 40 + o < 256 ^ 8 := by
    have h1 : r * 2 ^ 40 + o < (r + 1) * 2 ^ 40 := by rw [Nat.add_mul, Nat.one_mul]; exact Nat.add_lt_add_left ho _
    have h2 : (r + 1) * 2 ^ 40 ≤ 2 ^ 24 * 2 ^ 40 := Nat.mul_le_mul_right _ hr
    calc r * 2 ^ 40 + o < (r + 1) * 2 ^ 40 := h1
      _ ≤ 2 ^ 24 * 2 ^ 40 := h2
      _ = 256 ^ 8 := by norm_num
  simp only [decode]
  rw [List.take_of_length_le (by rw [wordBytes_length]), bytesWord_wordBytes, Nat.mod_eq_of_lt hw,
    show r * 2 ^ 40 + o = o + 2 ^ 40 * r by ring, Nat.add_mul_div_left _ _ (by norm_num), Nat.add_mul_mod_self_left,
    Nat.div_eq_of_lt ho, Nat.mod_eq_of_lt ho, Nat.zero_add]

theorem encode_ptr {r o : Nat} (hr : r < 2 ^ 24) (ho : o < 2 ^ 40) :
    encode (.ptr .device (.scalar .u32)) (.ptr ⟨r, (o : Int), .scalar .u32⟩) = some (wordBytes 8 (r * 2 ^ 40 + o)) := by
  have h : (0 : Int) ≤ (o : Int) ∧ (o : Int) < 2 ^ 40 ∧ r < 2 ^ 24 := ⟨Int.natCast_nonneg _, by exact_mod_cast ho, hr⟩
  simp [encode, ptrWord, h]
  exact ⟨lt_of_lt_of_eq ho (by norm_num), lt_of_lt_of_eq hr (by norm_num)⟩

/-! ## Pairs and quadruples -/

/-- Two binary32 values, as a `float2` or a matrix's two `thread_elements()` are stored. -/
def pairBytes (x y : Float32) : List (BitVec 8) := wordBytes 4 (Val.f32Bits x) ++ wordBytes 4 (Val.f32Bits y)

theorem pairBytes_length (x y : Float32) : (pairBytes x y).length = 8 := by simp [pairBytes, wordBytes_length]

theorem decode_pair (x y : Float32) : decode (.vec .f32 2) (pairBytes x y) = some (.vec .f32 [.f32 x, .f32 y]) := by
  have h : decode (.vec .f32 2) (pairBytes x y) = some (.vec .f32 [Val.ofWord .f32 (bytesWord (wordBytes 4 (Val.f32Bits x))),
      Val.ofWord .f32 (bytesWord (wordBytes 4 (Val.f32Bits y)))]) := rfl
  rw [h, ofWord_f32, ofWord_f32]

theorem encode_pair (x y : Float32) : encode (.vec .f32 2) (.vec .f32 [.f32 x, .f32 y]) = some (pairBytes x y) := rfl

theorem encode_f32x2 (x y : Float32) :
    encode (.vec .f32 2) (.vec .f32 [.f32 x, .f32 y]) =
      some (wordBytes 4 (Val.f32Bits x) ++ wordBytes 4 (Val.f32Bits y)) := by
  simp [encode, Val.word, Ty.bytes, Scalar.bytes]

theorem pairBytes_lo (B : ByteMemory.Bytes) (o : Nat) (x y : Float32) :
    cells (writeBytes B o (pairBytes x y)) o 4 = wordBytes 4 (Val.f32Bits x) := by
  have := cells_writeBytes_sub B o 0 4 (pairBytes x y) (by rw [pairBytes_length]; omega)
  rw [Nat.add_zero] at this
  rw [this]; simp [pairBytes, wordBytes_length]

theorem pairBytes_hi (B : ByteMemory.Bytes) (o : Nat) (x y : Float32) :
    cells (writeBytes B o (pairBytes x y)) (o + 4) 4 = wordBytes 4 (Val.f32Bits y) := by
  rw [cells_writeBytes_sub B o 4 4 (pairBytes x y) (by rw [pairBytes_length])]
  simp [pairBytes, wordBytes_length]

/-- Byte `j` of a half's little-endian encoding. -/
def halfByte (x : Float16.Value) (j : Nat) : BitVec 8 := (wordBytes 2 (Val.f16Bits x)).getD j 0

/-- A `half4` of thread memory whose four halves hold `h 0 … h 3`. -/
theorem decode_half4 (B : ByteMemory.Bytes) (h : Nat → Float16.Value)
    (hB : ∀ j < 4, cells B (2 * j) 2 = wordBytes 2 (Val.f16Bits (h j))) :
    decode (.vec .f16 4) ((List.range (Ty.vec .f16 4).bytes).map fun i => B (0 + i)) =
      some (.vec .f16 [.f16 (h 0), .f16 (h 1), .f16 (h 2), .f16 (h 3)]) := by
  have hc : (List.range (Ty.vec .f16 4).bytes).map (fun i => B (0 + i)) = cells B 0 8 := rfl
  rw [hc]
  have he : ∀ j < 4, Val.ofWord .f16 (bytesWord (((cells B 0 8).drop (Scalar.f16.bytes * j)).take Scalar.f16.bytes)) =
      .f16 (h j) := by
    intro j hj
    rw [show Scalar.f16.bytes = 2 from rfl, cells_drop_take B 0 8 (2 * j) 2 (by omega), Nat.zero_add, hB j hj,
      bytesWord_wordBytes2_of_lt _ (f16Bits_lt _)]
    exact congrArg Val.f16 (ofF16Bits_f16Bits (h j))
  show some (Val.vec .f16 [_, _, _, _]) = _
  beta_reduce
  rw [he 0 (by decide), he 1 (by decide), he 2 (by decide), he 3 (by decide)]

/-- A `half4` of four halves: their eight bytes. -/
theorem encode_half4 (h0 h1 h2 h3 : Float16.Value) :
    Metal.encode (.vec .f16 4) (.vec .f16 [.f16 h0, .f16 h1, .f16 h2, .f16 h3]) =
      some (wordBytes 2 (Val.f16Bits h0) ++ wordBytes 2 (Val.f16Bits h1) ++ wordBytes 2 (Val.f16Bits h2) ++
        wordBytes 2 (Val.f16Bits h3)) := by
  simp [encode, Val.word, Ty.bytes, Scalar.bytes]

theorem halves4_getD (h : Nat → Float16.Value) (k : Nat) (hk : k < 8) :
    (wordBytes 2 (Val.f16Bits (h 0)) ++ wordBytes 2 (Val.f16Bits (h 1)) ++ wordBytes 2 (Val.f16Bits (h 2)) ++
      wordBytes 2 (Val.f16Bits (h 3))).getD k 0 = halfByte (h (k / 2)) (k % 2) := by
  rcases (show k = 0 ∨ k = 1 ∨ k = 2 ∨ k = 3 ∨ k = 4 ∨ k = 5 ∨ k = 6 ∨ k = 7 by omega) with
    rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

/-! ## Elements of buffers -/

/-- Byte `o` of a buffer, as a number. -/
def byteAt (B : ByteMemory.Bytes) (o : Nat) : Nat := (B o).toNat

/-- bf16 element `e` of a buffer: bytes `2e` and `2e + 1`, little-endian. -/
def bfAt (B : ByteMemory.Bytes) (e : Nat) : BF := Val.ofBf16Bits (bytesWord ((List.range 2).map fun j => B (2 * e + j)))

/-- `bfAt` is the contracts' bf16 decoding of the halfword at byte `2e`. -/
theorem bfAt_eq_load (B : ByteMemory.Bytes) (e : Nat) :
    bfAt B e = (FloatLib.Floats.Formats.BinaryInterchange.Model.ofBits (HalfMemory.load B (2 * e)) : BF) := by
  unfold bfAt Val.ofBf16Bits HalfMemory.load
  congr 1
  apply BitVec.eq_of_toNat_eq
  simp only [bytesWord, List.range_succ, List.range_zero, List.nil_append, List.cons_append, List.map_cons,
    List.map_nil, List.foldr_cons, List.foldr_nil, BitVec.toNat_ofNat]
  rw [BitVec.toNat_append, <- Nat.shiftLeft_add_eq_or_of_lt (BitVec.isLt _), Nat.shiftLeft_eq]
  have h0 := (B (2 * e + 0)).isLt
  have h1 := (B (2 * e + 1)).isLt
  simp only [Nat.add_zero] at h0 ⊢
  omega

/-- The bf16 element of bytes a store of `v` wrote. -/
theorem bfAt_of (B : ByteMemory.Bytes) (e : Nat) (v : BF)
    (h : ∀ j < 2, B (2 * e + j) = (wordBytes 2 (Val.bf16Bits v)).getD j 0) : bfAt B e = v := by
  unfold bfAt
  rw [List.map_congr_left (fun j hj => h j (List.mem_range.mp hj)), map_getD_wordBytes, bytesWord_wordBytes2,
    ofBf16Bits_bf16Bits_mod]

/-- The bf16 elements of bytes from offset `2 a`. -/
theorem bfAt_shift (M : ByteMemory.Bytes) {o a : Nat} (j : Nat) (ho : o = 2 * a) :
    bfAt (fun b => M (o + b)) j = bfAt M (a + j) := by
  unfold bfAt
  congr 2
  exact List.map_congr_left fun i _ => by dsimp only; congr 1; omega

/-- The bf16 of two bytes. -/
def bfVal (B : ByteMemory.Bytes) (o : Nat) : Val := Val.ofWord .bf16 (bytesWord (cells B o 2))

/-- A bf16 loaded from two bytes stores back the same bytes. -/
theorem encode_bfVal (B : ByteMemory.Bytes) (o : Nat) : encode (.scalar .bf16) (bfVal B o) = some (cells B o 2) := by
  have hl : bytesWord (cells B o 2) < 2 ^ 16 := by
    have := bytesWord_lt (cells B o 2); rw [cells_length] at this; simpa using this
  show some (wordBytes 2 (Val.bf16Bits (Val.ofBf16Bits (bytesWord (cells B o 2))))) = _
  have e : Val.bf16Bits (Val.ofBf16Bits (bytesWord (cells B o 2))) = bytesWord (cells B o 2) := by
    show (BitVec.ofNat 16 (bytesWord (cells B o 2))).toNat = _
    rw [BitVec.toNat_ofNat]
    exact Nat.mod_eq_of_lt hl
  rw [e, cells_two, wordBytes2_bytesWord]

/-- f32 element `e` of a buffer: bytes `4e … 4e + 3`, little-endian. -/
def f32At (B : ByteMemory.Bytes) (e : Nat) : Float32 := Val.ofF32Bits (bytesWord ((List.range 4).map fun j => B (4 * e + j)))

/-- The f32 element of bytes a store of `y` wrote. -/
theorem f32At_of (B : ByteMemory.Bytes) (e : Nat) (y : Float32)
    (h : ∀ j < 4, B (4 * e + j) = (wordBytes 4 (Val.f32Bits y)).getD j 0) : f32At B e = y := by
  unfold f32At
  rw [List.map_congr_left (fun j hj => h j (List.mem_range.mp hj)), map_getD_wordBytes, bytesWord_wordBytes4,
    ofF32Bits_f32Bits_mod]

theorem f32At_write_same (B : ByteMemory.Bytes) (e : Nat) (y : Float32) :
    f32At (writeBytes B (4 * e) (wordBytes 4 (Val.f32Bits y))) e = y :=
  f32At_of _ e y fun j hj => writeBytes_inside _ _ _ j (by rw [wordBytes_length]; omega)

theorem f32At_write_other (B : ByteMemory.Bytes) {e e' : Nat} (y : Float32) (h : e' ≠ e) :
    f32At (writeBytes B (4 * e) (wordBytes 4 (Val.f32Bits y))) e' = f32At B e' := by
  unfold f32At
  congr 2
  apply List.map_congr_left
  intro j hj
  rw [List.mem_range] at hj
  exact writeBytes_outside _ _ _ _ (by rw [wordBytes_length]; omega)

theorem f32At_write (B : ByteMemory.Bytes) (e e' : Nat) (y : Float32) :
    f32At (writeBytes B (4 * e) (wordBytes 4 (Val.f32Bits y))) e' = if e' = e then y else f32At B e' := by
  split
  · subst_vars; exact f32At_write_same B _ y
  · exact f32At_write_other B y ‹_›

/-- The binary32 elements of bytes from offset `4 a`. -/
theorem f32At_shift (M : ByteMemory.Bytes) {o a : Nat} (j : Nat) (ho : o = 4 * a) :
    f32At (fun b => M (o + b)) j = f32At M (a + j) := by
  unfold f32At
  congr 2
  exact List.map_congr_left fun i _ => by dsimp only; congr 1; omega

/-! ## Elements written so far -/

/-- Bytes of the elements written so far. -/
def wrote (base : Nat) (vals : Nat → BF) (old : ByteMemory.Bytes) (k b : Nat) : BitVec 8 :=
  if 2 * base ≤ b ∧ b < 2 * (base + k) then (wordBytes 2 (Val.bf16Bits (vals ((b - 2 * base) / 2)))).getD
    ((b - 2 * base) % 2) 0 else old b

theorem wrote_succ (base : Nat) (vals : Nat → BF) (old : ByteMemory.Bytes) (k b : Nat) :
    writeBytes (wrote base vals old k) (2 * (base + k)) (wordBytes 2 (Val.bf16Bits (vals k))) b =
      wrote base vals old (k + 1) b := by
  unfold wrote
  by_cases h1 : 2 * (base + k) ≤ b ∧ b < 2 * (base + k) + 2
  · obtain ⟨i, hi, rfl⟩ : ∃ i, i < 2 ∧ b = 2 * (base + k) + i := ⟨b - 2 * (base + k), by omega, by omega⟩
    rw [writeBytes_inside _ _ _ i (by rw [wordBytes_length]; exact hi), ite_eq_left (by omega)]
    rw [show (2 * (base + k) + i - 2 * base) / 2 = k by omega, show (2 * (base + k) + i - 2 * base) % 2 = i by omega]
  · rw [writeBytes_outside _ _ _ _ (by rw [wordBytes_length]; omega)]
    by_cases h2 : 2 * base ≤ b ∧ b < 2 * (base + k)
    · rw [ite_eq_left h2, ite_eq_left (by omega)]
    · rw [ite_eq_right h2, ite_eq_right (by omega)]

/-- Bytes of the binary32 elements written so far. -/
def wrote4 (base : Nat) (vals : Nat → Float32) (old : ByteMemory.Bytes) (k b : Nat) : BitVec 8 :=
  if 4 * base ≤ b ∧ b < 4 * (base + k) then (wordBytes 4 (Val.f32Bits (vals ((b - 4 * base) / 4)))).getD
    ((b - 4 * base) % 4) 0 else old b

theorem wrote4_succ (base : Nat) (vals : Nat → Float32) (old : ByteMemory.Bytes) (k b : Nat) :
    writeBytes (wrote4 base vals old k) (4 * (base + k)) (wordBytes 4 (Val.f32Bits (vals k))) b =
      wrote4 base vals old (k + 1) b := by
  unfold wrote4
  by_cases h1 : 4 * (base + k) ≤ b ∧ b < 4 * (base + k) + 4
  · obtain ⟨i, hi, rfl⟩ : ∃ i, i < 4 ∧ b = 4 * (base + k) + i := ⟨b - 4 * (base + k), by omega, by omega⟩
    rw [writeBytes_inside _ _ _ i (by rw [wordBytes_length]; exact hi), ite_eq_left (by omega)]
    rw [show (4 * (base + k) + i - 4 * base) / 4 = k by omega, show (4 * (base + k) + i - 4 * base) % 4 = i by omega]
  · rw [writeBytes_outside _ _ _ _ (by rw [wordBytes_length]; omega)]
    by_cases h2 : 4 * base ≤ b ∧ b < 4 * (base + k)
    · rw [ite_eq_left h2, ite_eq_left (by omega)]
    · rw [ite_eq_right h2, ite_eq_right (by omega)]

/-- The thread array holds `v j` at element `j`, for `j < k`. -/
def Arr (M : ByteMemory.Bytes) (v : Nat → Float32) (k : Nat) : Prop :=
  ∀ j < k, ∀ b < 4, M (4 * j + b) = (wordBytes 4 (Val.f32Bits (v j))).getD b 0

theorem Arr.congr {M : ByteMemory.Bytes} {v w : Nat → Float32} {k : Nat} (h : Arr M v k) (hv : ∀ j < k, v j = w j) :
    Arr M w k := fun j hj b hb => by rw [← hv j hj]; exact h j hj b hb

theorem Arr.write {M : ByteMemory.Bytes} {v : Nat → Float32} (h : Arr M v 4) {k : Nat} (hk : k < 4) (x : Float32) :
    Arr (writeBytes M (4 * k) (wordBytes 4 (Val.f32Bits x))) (fun j => if j = k then x else v j) 4 := by
  intro j hj b hb
  by_cases hjk : j = k
  · subst hjk; dsimp only; rw [ite_eq_left rfl]; exact writeBytes_inside _ _ _ b (by rw [wordBytes_length]; exact hb)
  · dsimp only; rw [ite_eq_right hjk, writeBytes_outside _ _ _ _ (by rw [wordBytes_length]; omega)]; exact h j hj b hb

/-- `D` with its first `E` halves replaced by `W 0 … W (E - 1)`. -/
def halvesOver (W : Nat → Float16.Value) (D : ByteMemory.Bytes) (E : Nat) : ByteMemory.Bytes :=
  fun b => if b < 2 * E then halfByte (W (b / 2)) (b % 2) else D b

/-- Writing the next `n` halves. -/
theorem halvesOver_store (W : Nat → Float16.Value) (D : ByteMemory.Bytes) (E n : Nat) (bs : List (BitVec 8))
    (hbs : bs.length = 2 * n) (hb : ∀ k < 2 * n, bs.getD k 0 = halfByte (W (E + k / 2)) (k % 2)) :
    writeBytes (halvesOver W D E) (2 * E) bs = halvesOver W D (E + n) := by
  funext b
  unfold writeBytes halvesOver
  rw [hbs]
  by_cases h1 : 2 * E ≤ b ∧ b < 2 * E + 2 * n
  · rw [ite_eq_left h1, ite_eq_left (show b < 2 * (E + n) by omega), hb (b - 2 * E) (by omega), show E + (b - 2 * E) / 2 = b / 2 by omega,
      show (b - 2 * E) % 2 = b % 2 by omega]
  · rw [ite_eq_right h1]
    by_cases h2 : b < 2 * E
    · rw [ite_eq_left h2, ite_eq_left (show b < 2 * (E + n) by omega)]
    · rw [ite_eq_right h2, ite_eq_right (show ¬ b < 2 * (E + n) by omega)]

/-! ## Words as bits -/

/-- The little-endian value of the words `W 0 … W (n - 1)`. -/
def runBits (W : Nat → Nat) : Nat → Nat
  | 0 => 0
  | n + 1 => runBits W n + W n * 2 ^ (32 * n)

theorem pow32_add (a b : Nat) : (2 : Nat) ^ (32 * (a + b)) = 2 ^ (32 * a) * 2 ^ (32 * b) := by
  rw [Nat.mul_add, Nat.pow_add]

theorem runBits_lt {W : Nat → Nat} : ∀ {n : Nat}, (∀ i < n, W i < 2 ^ 32) → runBits W n < 2 ^ (32 * n)
  | 0, _ => by simp [runBits]
  | n + 1, hW => by
    have h1 := runBits_lt (n := n) (fun i hi => hW i (by omega))
    have h2 := hW n (by omega)
    rw [runBits, pow32_add, Nat.mul_one]
    have : W n * 2 ^ (32 * n) ≤ (2 ^ 32 - 1) * 2 ^ (32 * n) := Nat.mul_le_mul_right _ (by omega)
    have h3 : (2 ^ 32 - 1) * 2 ^ (32 * n) + 2 ^ (32 * n) = 2 ^ (32 * n) * 2 ^ 32 := by
      rw [Nat.sub_mul, Nat.one_mul, Nat.mul_comm]; have := Nat.one_le_two_pow (n := 32 * n); have := Nat.le_mul_of_pos_right (2 ^ (32 * n)) (show 0 < 2 ^ 32 by norm_num); omega
    omega

/-- Word `i` of the value of `n` words. -/
theorem runBits_word {W : Nat → Nat} : ∀ {n : Nat}, (∀ i < n, W i < 2 ^ 32) → ∀ i < n,
    runBits W n / 2 ^ (32 * i) % 2 ^ 32 = W i
  | 0, _, i, hi => absurd hi (Nat.not_lt_zero _)
  | n + 1, hW, i, hi => by
    have hA := runBits_lt (n := n) (fun j hj => hW j (by omega))
    rw [runBits]
    by_cases hin : i < n
    · obtain ⟨d, rfl⟩ : ∃ d, n = i + (d + 1) := ⟨n - i - 1, by omega⟩
      rw [pow32_add, show W (i + (d + 1)) * (2 ^ (32 * i) * 2 ^ (32 * (d + 1))) =
        W (i + (d + 1)) * 2 ^ (32 * (d + 1)) * 2 ^ (32 * i) by ring,
        Nat.add_mul_div_right _ _ (Nat.two_pow_pos _), pow32_add, Nat.mul_one,
        show W (i + (d + 1)) * (2 ^ (32 * d) * 2 ^ 32) = 2 ^ 32 * (W (i + (d + 1)) * 2 ^ (32 * d)) by ring,
        Nat.add_mul_mod_self_left]
      exact runBits_word (fun j hj => hW j (by omega)) i (by omega)
    · obtain rfl : i = n := by omega
      rw [Nat.add_mul_div_right _ _ (Nat.two_pow_pos _), Nat.div_eq_of_lt hA, Nat.zero_add,
        Nat.mod_eq_of_lt (hW i (by omega))]

/-- Word `i`, and the words above it. -/
theorem runBits_split {W : Nat → Nat} {n : Nat} (hW : ∀ i < n, W i < 2 ^ 32) {i : Nat} (hi : i < n) :
    runBits W n / 2 ^ (32 * i) = W i + 2 ^ 32 * (runBits W n / 2 ^ (32 * (i + 1))) := by
  have h := Nat.mod_add_div (runBits W n / 2 ^ (32 * i)) (2 ^ 32)
  rw [runBits_word hW i hi, Nat.div_div_eq_div_mul, ← Nat.pow_add, show 32 * i + 32 = 32 * (i + 1) by ring] at h
  exact h.symm

/-- `m` words from word `a` of the value of `n` words. -/
theorem runBits_slice {W : Nat → Nat} {n : Nat} (hW : ∀ i < n, W i < 2 ^ 32) (a : Nat) :
    ∀ m, a + m ≤ n → runBits W n / 2 ^ (32 * a) % 2 ^ (32 * m) = runBits (fun i => W (a + i)) m
  | 0, _ => by simp [runBits, Nat.mod_one]
  | m + 1, h => by
    rw [pow32_add, Nat.mul_one, Nat.mod_mul, runBits_slice hW a m (by omega), runBits, Nat.div_div_eq_div_mul,
      ← Nat.pow_add, show 32 * a + 32 * m = 32 * (a + m) by ring, runBits_word hW (a + m) (by omega)]
    ring

/-- `m` words of the words `x / 2^(32 i) % 2^32` of `x`: `x` below bit `32 m`. -/
theorem runBits_words (x : Nat) : ∀ m, runBits (fun i => x / 2 ^ (32 * i) % 2 ^ 32) m = x % 2 ^ (32 * m)
  | 0 => by simp [runBits, Nat.mod_one]
  | m + 1 => by
    rw [runBits, runBits_words x m, pow32_add, Nat.mul_one, Nat.mod_mul, Nat.mul_comm (x / 2 ^ (32 * m) % 2 ^ 32)]

theorem runBits_congr {W W' : Nat → Nat} : ∀ {n : Nat}, (∀ i < n, W i = W' i) → runBits W n = runBits W' n
  | 0, _ => rfl
  | n + 1, h => by
    rw [runBits, runBits, runBits_congr (fun i hi => h i (by omega)), h n (by omega)]

/-- Bits `o … o + 11` of `x` only depend on `x` below bit `M ≥ o + 12`. -/
theorem window_mod (x o M : Nat) (h : o + 12 ≤ M) : x % 2 ^ M / 2 ^ o % 2 ^ 12 = x / 2 ^ o % 2 ^ 12 := by
  rw [← Nat.mod_mul_right_div_self, ← Nat.mod_mul_right_div_self x, ← Nat.pow_add,
    Nat.mod_mod_of_dvd _ (Nat.pow_dvd_pow 2 h)]

/-- The bits below `32·m` of a word list do not depend on the words past `m`. -/
theorem runBits_window_ext {W : Nat → Nat} {N N' j : Nat} (hW : ∀ i < N', W i < 2 ^ 32) (hN : N ≤ N')
    (hj : j + 12 ≤ 32 * N) : runBits W N / 2 ^ j % 2 ^ 12 = runBits W N' / 2 ^ j % 2 ^ 12 := by
  have h := runBits_slice hW 0 N (by omega)
  simp only [Nat.mul_zero, Nat.pow_zero, Nat.div_one, Nat.zero_add] at h
  rw [← window_mod (runBits W N') j (32 * N) hj, h]

/-- A 14-bit field at bit `r` of a word, without its low two bits: bits `r + 2 …` of the value above the word. -/
theorem field_word (y r : Nat) (hr : r + 14 ≤ 32) : y % 2 ^ 32 / 2 ^ r % 2 ^ 14 / 4 = y / 2 ^ (r + 2) % 2 ^ 12 := by
  have h1 : y % 2 ^ 32 / 2 ^ r % 2 ^ 14 = y / 2 ^ r % 2 ^ 14 := by
    rw [← Nat.mod_mul_right_div_self, ← Nat.mod_mul_right_div_self y, ← Nat.pow_add,
      Nat.mod_mod_of_dvd _ (Nat.pow_dvd_pow 2 hr)]
  rw [h1, show (2 : Nat) ^ 14 = 4 * 2 ^ 12 by norm_num, Nat.mod_mul_right_div_self, Nat.div_div_eq_div_mul,
    show (2 : Nat) ^ r * 4 = 2 ^ (r + 2) by rw [Nat.pow_add]]

/-- The shifted word `(w[i] >> 16) | (w[i + 1] << 16)`: word `i + 1` of the value moved up 16 bits. -/
theorem shifted_word {W : Nat → Nat} {n : Nat} (hW : ∀ i < n, W i < 2 ^ 32) {i : Nat} (hi : i + 1 < n) :
    W i / 2 ^ 16 ||| W (i + 1) * 2 ^ 16 % 2 ^ 32 = runBits W n * 2 ^ 16 / 2 ^ (32 * (i + 1)) % 2 ^ 32 := by
  have ha := hW i (by omega)
  have e1 : W (i + 1) * 2 ^ 16 % 2 ^ 32 = (W (i + 1) % 2 ^ 16) <<< 16 := by
    rw [Nat.shiftLeft_eq, show (2 : Nat) ^ 32 = 2 ^ 16 * 2 ^ 16 by norm_num, Nat.mul_mod_mul_right]
  rw [e1, Nat.lor_comm, ← Nat.shiftLeft_add_eq_or_of_lt (by omega), Nat.shiftLeft_eq]
  have hs := runBits_split hW (show i < n by omega)
  have hb := runBits_word hW (i + 1) hi
  rw [show 32 * (i + 1) = 32 * i + 16 + 16 by ring, Nat.pow_add, Nat.mul_div_mul_right _ _ (Nat.two_pow_pos 16),
    Nat.pow_add, ← Nat.div_div_eq_div_mul, hs]
  generalize runBits W n / 2 ^ (32 * (i + 1)) = Z at hb ⊢
  omega

/-- `w[0] << 16`: word 0 of the value moved up 16 bits. -/
theorem shifted_word0 {W : Nat → Nat} {n : Nat} (hW : ∀ i < n, W i < 2 ^ 32) (hn : 0 < n) :
    W 0 * 2 ^ 16 % 2 ^ 32 = runBits W n * 2 ^ 16 % 2 ^ 32 := by
  have h0 := runBits_word hW 0 hn
  rw [Nat.mul_zero, Nat.pow_zero, Nat.div_one] at h0
  rw [show (2 : Nat) ^ 32 = 2 ^ 16 * 2 ^ 16 by norm_num, Nat.mul_mod_mul_right, Nat.mul_mod_mul_right, ← h0,
    Nat.mod_mod_of_dvd _ (by norm_num)]

/-- `(W i >> o) | (W (i + 1) << (32 - o))` for `0 < o < 32`: word `i` of the words moved down `o` bits. -/
theorem realign_word {W : Nat → Nat} {n : Nat} (hW : ∀ i < n, W i < 2 ^ 32) {o i : Nat} (ho : 0 < o) (ho' : o < 32)
    (hi : i + 1 < n) :
    W i / 2 ^ o ||| W (i + 1) * 2 ^ (32 - o) % 2 ^ 32 = runBits W n / 2 ^ o / 2 ^ (32 * i) % 2 ^ 32 := by
  have ha := hW i (by omega)
  have hb := runBits_word hW (i + 1) hi
  have hs := runBits_split hW (show i < n by omega)
  have hPQ : 2 ^ o * 2 ^ (32 - o) = 2 ^ 32 := by rw [← Nat.pow_add]; congr 1; omega
  have e1 : W (i + 1) * 2 ^ (32 - o) % 2 ^ 32 = (W (i + 1) % 2 ^ o) <<< (32 - o) := by
    rw [Nat.shiftLeft_eq, ← hPQ, Nat.mul_mod_mul_right]
  have hlo : W i / 2 ^ o < 2 ^ (32 - o) := by
    rw [Nat.div_lt_iff_lt_mul (Nat.two_pow_pos o), ← Nat.pow_add, show 32 - o + o = 32 by omega]; exact ha
  rw [e1, Nat.lor_comm, ← Nat.shiftLeft_add_eq_or_of_lt hlo, Nat.shiftLeft_eq]
  rw [Nat.div_div_eq_div_mul, Nat.mul_comm (2 ^ o), ← Nat.div_div_eq_div_mul, hs]
  generalize runBits W n / 2 ^ (32 * (i + 1)) = Z at hb ⊢
  have hP : 0 < 2 ^ o := Nat.two_pow_pos o
  rw [← hPQ] at hb ⊢
  generalize 2 ^ o = P at *
  generalize 2 ^ (32 - o) = Q at *
  have hQ : 0 < Q := by
    rcases Nat.eq_zero_or_pos Q with h | h
    · subst h; omega
    · exact h
  rw [show W i + P * Q * Z = W i + P * (Q * Z) by ring, Nat.add_mul_div_left _ _ hP]
  have hz := Nat.mod_add_div Z P
  have hzP : Z % P < P := Nat.mod_lt _ hP
  have hm : W (i + 1) % P = Z % P := by rw [← hb, Nat.mod_mul_right_mod]
  rw [hm]
  have hA : W i / P + Q * (Z % P) < P * Q := by nlinarith
  rw [show W i / P + Q * Z = (W i / P + Q * (Z % P)) + P * Q * (Z / P) by
    conv_lhs => rw [← hz]
    ring]
  rw [Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt hA]
  ring

/-- Bits `r … r + 11` of a word's low 32 bits. -/
theorem bits_low (y r : Nat) (hr : r + 12 ≤ 32) : y % 2 ^ 32 / 2 ^ r % 2 ^ 12 = y / 2 ^ r % 2 ^ 12 := by
  rw [← Nat.mod_mul_right_div_self, ← Nat.mod_mul_right_div_self y, ← Nat.pow_add,
    Nat.mod_mod_of_dvd _ (Nat.pow_dvd_pow 2 hr)]

/-- `block_state`'s in-word field `(w[b >> 5] >> (b & 31)) & 4095`. -/
theorem field_in_word (x b : Nat) (h : b % 32 + 12 ≤ 32) :
    x / 2 ^ (32 * (b / 32)) % 2 ^ 32 / 2 ^ (b % 32) % 2 ^ 12 = x / 2 ^ b % 2 ^ 12 := by
  rw [bits_low _ _ h, Nat.div_div_eq_div_mul, ← Nat.pow_add, show 32 * (b / 32) + b % 32 = b by omega]

/-- `block_state`'s field across a word edge, from the virtual word `vi = (b + 16) >> 5`. -/
theorem field_virtual_of_bit (x b : Nat) (h : 32 < b % 32 + 12) :
    x * 2 ^ 16 / 2 ^ (32 * ((b + 16) / 32)) % 2 ^ 32 / 2 ^ (b + 16 - 32 * ((b + 16) / 32)) % 2 ^ 12 =
      x / 2 ^ b % 2 ^ 12 := by
  rw [bits_low _ _ (by omega), Nat.div_div_eq_div_mul, ← Nat.pow_add,
    show 32 * ((b + 16) / 32) + (b + 16 - 32 * ((b + 16) / 32)) = b + 16 by omega, Nat.pow_add,
    Nat.mul_div_mul_right _ _ (Nat.two_pow_pos 16)]

/-- The in-word field of a 12-bit window: bits `o …` of word `a`. -/
theorem field_inword (R a o : Nat) (h : o + 12 ≤ 32) :
    R / 2 ^ (32 * a) % 2 ^ 32 / 2 ^ o % 2 ^ 12 = R / 2 ^ (32 * a + o) % 2 ^ 12 := by
  rw [window_mod _ _ _ h, Nat.div_div_eq_div_mul, ← Nat.pow_add]

/-- The virtual-word field of a 12-bit window: bits `sft …` of virtual word `vi` (the value moved up 16 bits). -/
theorem field_virtual (R bb vi sft : Nat) (h : sft + 12 ≤ 32) (he : 32 * vi + sft = bb + 16) :
    R * 2 ^ 16 / 2 ^ (32 * vi) % 2 ^ 32 / 2 ^ sft % 2 ^ 12 = R / 2 ^ bb % 2 ^ 12 := by
  rw [window_mod _ _ _ h, Nat.div_div_eq_div_mul, ← Nat.pow_add, he, Nat.pow_add,
    Nat.mul_div_mul_right _ _ (Nat.two_pow_pos 16)]

theorem and_hi (w : Nat) (h : w < 2 ^ 32) : w &&& 4294901760 = w / 2 ^ 16 * 2 ^ 16 := by
  apply Nat.eq_of_testBit_eq
  intro k
  rw [Nat.testBit_and, Nat.testBit_mul_two_pow, Nat.testBit_div_two_pow]
  by_cases hk : k < 32
  · by_cases hk16 : 16 ≤ k
    · have e : (4294901760 : Nat).testBit k = true := by
        have hM : ∀ k < 32, (4294901760 : Nat).testBit k = decide (16 ≤ k) := by decide
        rw [hM k hk, decide_eq_true hk16]
      rw [e, Bool.and_true, decide_eq_true hk16, Bool.true_and, Nat.sub_add_cancel hk16]
    · have e : (4294901760 : Nat).testBit k = false := by
        have hM : ∀ k < 32, (4294901760 : Nat).testBit k = decide (16 ≤ k) := by decide
        rw [hM k hk, decide_eq_false hk16]
      rw [e, Bool.and_false, decide_eq_false hk16, Bool.false_and]
  · rw [Nat.testBit_lt_two_pow (lt_of_lt_of_le h (Nat.pow_le_pow_right (by decide) (by omega))), Bool.false_and]
    by_cases hk16 : 16 ≤ k
    · rw [decide_eq_true hk16, Bool.true_and, Nat.sub_add_cancel hk16,
        Nat.testBit_lt_two_pow (lt_of_lt_of_le h (Nat.pow_le_pow_right (by decide) (by omega)))]
    · omega

theorem and4095 (x : Nat) : x &&& 4095 = x % 2 ^ 12 := Nat.and_two_pow_sub_one_eq_mod x 12

theorem and31 (x : Nat) : x &&& 31 = x % 32 := Nat.and_two_pow_sub_one_eq_mod x 5

/-! ## Bit fields -/

theorem and_mask_shift (x B top : Nat) : x &&& (2 ^ B - 1) * 2 ^ top = x / 2 ^ top % 2 ^ B * 2 ^ top := by
  apply Nat.eq_of_testBit_eq
  intro k
  rw [Nat.testBit_and, Nat.testBit_mul_two_pow, Nat.testBit_mul_two_pow, Nat.testBit_two_pow_sub_one,
    Nat.testBit_mod_two_pow, Nat.testBit_div_two_pow]
  by_cases h : top ≤ k
  · rw [Nat.sub_add_cancel h]
    cases x.testBit k <;> simp [h]
  · simp [h]

/-- Bits `off …` of `lo` moved up to `top` (`lo << (top - off)`), read back at `top`. -/
theorem field_shl (lo off top B : Nat) (h1 : off ≤ top) (h2 : top + B ≤ 32) :
    lo * 2 ^ (top - off) % 2 ^ 32 / 2 ^ top % 2 ^ B = lo / 2 ^ off % 2 ^ B := by
  apply Nat.eq_of_testBit_eq
  intro k
  rw [Nat.testBit_mod_two_pow, Nat.testBit_div_two_pow, Nat.testBit_mod_two_pow, Nat.testBit_mul_two_pow,
    Nat.testBit_mod_two_pow, Nat.testBit_div_two_pow]
  by_cases hk : k < B
  · have e : k + top - (top - off) = k + off := by omega
    simp [hk, show k + top < 32 by omega, show top - off ≤ k + top by omega, e]
  · simp [hk]

/-- Bits `off …` of `lo` moved down to `top` (`lo >> (off - top)`), read back at `top`. -/
theorem field_shr (lo off top B : Nat) (h1 : top ≤ off) :
    lo / 2 ^ (off - top) / 2 ^ top % 2 ^ B = lo / 2 ^ off % 2 ^ B := by
  rw [Nat.div_div_eq_div_mul, ← Nat.pow_add, Nat.sub_add_cancel h1]

theorem div_lt_of_lt32 {lo off : Nat} (hlo : lo < 2 ^ 32) (h : off ≤ 32) : lo / 2 ^ off < 2 ^ (32 - off) := by
  rw [Nat.div_lt_iff_lt_mul (Nat.two_pow_pos _), ← Nat.pow_add, Nat.sub_add_cancel h]
  exact hlo

/-- A field across two words: the top of `lo` and the bottom of `hi`. -/
theorem field_straddle (lo hi off top B : Nat) (hlo : lo < 2 ^ 32) (h1 : top < off)
    (h3 : off < 32) (h4 : top + B ≤ 32) :
    (lo / 2 ^ (off - top) ||| hi * 2 ^ (top + 32 - off) % 2 ^ 32) / 2 ^ top % 2 ^ B =
      (lo / 2 ^ off + hi * 2 ^ (32 - off)) % 2 ^ B := by
  have hsum : lo / 2 ^ off + hi * 2 ^ (32 - off) = hi <<< (32 - off) ||| lo / 2 ^ off := by
    rw [Nat.add_comm, ← Nat.shiftLeft_eq, Nat.shiftLeft_add_eq_or_of_lt (div_lt_of_lt32 hlo (by omega))]
  rw [hsum]
  apply Nat.eq_of_testBit_eq
  intro k
  rw [Nat.testBit_mod_two_pow, Nat.testBit_div_two_pow, Nat.testBit_or, Nat.testBit_div_two_pow,
    Nat.testBit_mod_two_pow, Nat.testBit_mul_two_pow, Nat.testBit_mod_two_pow, Nat.testBit_or,
    Nat.testBit_shiftLeft, Nat.testBit_div_two_pow]
  by_cases hk : k < B
  · have e1 : k + top + (off - top) = k + off := by omega
    rw [e1]
    by_cases hk2 : 32 - off ≤ k
    · have e2 : k + top - (top + 32 - off) = k - (32 - off) := by omega
      have hl : lo.testBit (k + off) = false := Nat.testBit_lt_two_pow
        (lt_of_lt_of_le hlo (Nat.pow_le_pow_right (by decide) (by omega)))
      simp [hk, show k + top < 32 by omega, show top + 32 - off ≤ k + top by omega, e2, hk2, hl]
    · simp [hk, show k + top < 32 by omega, show ¬ (top + 32 - off ≤ k + top) by omega, hk2]
  · simp [hk]

theorem mod_add_two_pow_mul (a Y B c : Nat) (h : B ≤ c) : (a + 2 ^ c * Y) % 2 ^ B = a % 2 ^ B := by
  rw [show 2 ^ c * Y = 2 ^ B * (2 ^ (c - B) * Y) by rw [← Nat.mul_assoc, ← Nat.pow_add, Nat.add_sub_cancel' h],
    Nat.add_mul_mod_self_left]

theorem div_word (a Y off : Nat) (h : off ≤ 32) : (a + 2 ^ 32 * Y) / 2 ^ off = a / 2 ^ off + 2 ^ (32 - off) * Y := by
  rw [show 2 ^ 32 * Y = 2 ^ off * (2 ^ (32 - off) * Y) by rw [← Nat.mul_assoc, ← Nat.pow_add, Nat.add_sub_cancel' h],
    Nat.add_mul_div_left _ _ (Nat.two_pow_pos _)]

/-- A field inside word `w` of a run of words. -/
theorem runBits_field {Wd : Nat → Nat} {n : Nat} (hW : ∀ i < n, Wd i < 2 ^ 32) {w off B : Nat} (hw : w < n)
    (h : off + B ≤ 32) : runBits Wd n / 2 ^ (32 * w + off) % 2 ^ B = Wd w / 2 ^ off % 2 ^ B := by
  rw [Nat.pow_add, ← Nat.div_div_eq_div_mul, runBits_split hW hw, div_word _ _ _ (by omega),
    mod_add_two_pow_mul _ _ _ _ (by omega)]

/-- A field across words `w` and `w + 1` of a run of words. -/
theorem runBits_field2 {Wd : Nat → Nat} {n : Nat} (hW : ∀ i < n, Wd i < 2 ^ 32) {w off B : Nat} (hw : w + 1 < n)
    (h1 : off < 32) (h2 : B ≤ 32) :
    runBits Wd n / 2 ^ (32 * w + off) % 2 ^ B = (Wd w / 2 ^ off + Wd (w + 1) * 2 ^ (32 - off)) % 2 ^ B := by
  rw [Nat.pow_add, ← Nat.div_div_eq_div_mul, runBits_split hW (show w < n by omega), div_word _ _ _ (by omega),
    runBits_split hW hw, Nat.mul_add, ← Nat.add_assoc, ← Nat.mul_assoc, ← Nat.pow_add, Nat.mul_comm (2 ^ (32 - off)),
    mod_add_two_pow_mul _ _ _ _ (by omega)]

/-- `q << top | 0x3f800000` for a field below bit 23. -/
theorem or_one (q top : Nat) (h : q * 2 ^ top < 2 ^ 23) : q * 2 ^ top ||| 0x3F800000 = 0x3F800000 + q * 2 ^ top := by
  rw [show (0x3F800000 : Nat) = 127 <<< 23 by decide, Nat.shiftLeft_add_eq_or_of_lt h, Nat.lor_comm]

/-! ## Element indices -/

/-- An element index `m · N + n` with `n < N` determines `m` and `n`. -/
theorem idx_inj {N m n m' n' : Nat} (hn : n < N) (hn' : n' < N) (h : m * N + n = m' * N + n') : m = m' ∧ n = n' := by
  have h1 : (m * N + n) / N = m := by rw [Nat.add_comm, Nat.add_mul_div_right _ _ (by omega), Nat.div_eq_of_lt hn]; simp
  have h2 : (m' * N + n') / N = m' := by rw [Nat.add_comm, Nat.add_mul_div_right _ _ (by omega), Nat.div_eq_of_lt hn']; simp
  have hm : m = m' := by rw [← h1, ← h2, h]
  subst hm
  omega

theorem idx_div {N m n : Nat} (hn : n < N) : (m * N + n) / N = m := by
  rw [Nat.add_comm, Nat.add_mul_div_right _ _ (by omega), Nat.div_eq_of_lt hn]; simp

theorem idx_mod {N m n : Nat} (hn : n < N) : (m * N + n) % N = n := by
  rw [Nat.add_comm, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hn]

theorem idx_lt {a M r m : Nat} (hr : r < a) (hm : m < M) : r * M + m < a * M := by
  have : (r + 1) * M ≤ a * M := Nat.mul_le_mul_right _ hr
  rw [Nat.succ_mul] at this; omega

theorem eq_of_div_mod {x y c : Nat} (h1 : x / c = y / c) (h2 : x % c = y % c) : x = y := by
  rw [← Nat.div_add_mod x c, ← Nat.div_add_mod y c, h1, h2]

/-- `for (x = x0; x < n; x += d)` runs `(n - x0 + d - 1) / d` times. -/
theorem count_iff {x0 d n : Nat} (hd : 0 < d) (k : Nat) : x0 + d * k < n ↔ k < (n - x0 + d - 1) / d := by
  by_cases h : x0 < n
  · obtain ⟨m, hm⟩ : ∃ m, n - x0 = m + 1 := ⟨n - x0 - 1, by omega⟩
    rw [hm, show m + 1 + d - 1 = m + d * 1 by omega, Nat.add_mul_div_left _ _ hd]
    constructor
    · intro hk
      have : k * d ≤ m := by rw [Nat.mul_comm]; omega
      have := (Nat.le_div_iff_mul_le hd).mpr this
      omega
    · intro hk
      have : k ≤ m / d := by omega
      have := (Nat.le_div_iff_mul_le hd).mp this
      rw [Nat.mul_comm] at this
      omega
  · rw [show n - x0 = 0 by omega, Nat.zero_add, Nat.div_eq_of_lt (by omega)]
    omega

end Metal

import host.mlx.GlueStep

namespace Host.Mlx.GlueStep
open Inference.Contracts.Mlx

/-- The one logical element of the actual prompt or device-feedback buffer.
No condition is imposed on memory beyond that element. -/
structure TokenBuffer (ids : Value) (token : Nat) : Prop where
  dtype : ids.dtype = .uint32 ∨ ids.dtype = .int32
  shape : ids.shape = [1, 1]
  element : ids.elems 0 = token
  bounded : token < 2 ^ 31

theorem TokenBuffer.take (ids : Value) (token : Nat) (h : TokenBuffer ids token)
    (table : Value) : takeAxis0 table ids = takeRows table ids := by
  unfold takeAxis0
  rcases h.dtype with hd | hd
  · rw [ite_eq_left hd]
  · have hv : (List.range (extent ids.shape)).all (fun i => ids.elems i < 2^31) = true := by
      simpa only [h.shape, extent, List.foldr, Nat.mul_one, List.range_succ, List.range_zero,
        List.nil_append, List.all_cons, List.all_nil, Bool.and_true, h.element, decide_eq_true_eq] using h.bounded
    rw [ite_eq_right (by rw [hd]; decide), ite_eq_left ⟨hd, hv⟩]

def gathered (table ids : Value) (rows cols : Nat) : Value :=
  ⟨table.dtype, [1, 1, cols], fun i =>
    if ids.elems (i / cols) < rows then table.elems (ids.elems (i / cols) * cols + i % cols) else 0⟩

theorem TokenBuffer.gather (ids : Value) (token : Nat) (h : TokenBuffer ids token)
    (table : Value) (rows cols : Nat) (hs : table.shape = [rows, cols]) :
    takeAxis0 table ids = some (gathered table ids rows cols) := by
  rw [h.take ids token table]
  simp only [takeRows, hs, h.shape, gathered]
  rfl

theorem TokenBuffer.gather_elems (ids : Value) (token : Nat) (h : TokenBuffer ids token)
    (table : Value) (rows cols i : Nat) (hi : i < cols) :
    (gathered table ids rows cols).elems i =
      (gathered table (tokenIds token) rows cols).elems i := by
  simp only [gathered, Nat.div_eq_of_lt hi, h.element, tokenIds]
  rfl

theorem TokenBuffer.of_readback (r ids : Value) (token : Nat)
    (hr : itemUint32 r = some token) (hs : reshape r [1, 1] = some ids)
    (ht : token < 2 ^ 31) : TokenBuffer ids token := by
  obtain ⟨he, hd, hshape⟩ := reshape_elems r [1, 1] ids hs
  unfold itemUint32 at hr
  split at hr
  · next hc =>
    have hv : r.elems 0 = token := Option.some.inj hr
    exact ⟨.inl (hd.trans hc.1), hshape, by rw [he, hv], ht⟩
  · cases hr

def bufferEmbed (M : MlxContract C) (words scales biases ids : Value) : Option Value := do
  let rows ← takeAxis0 words ids
  let s ← takeAxis0 scales ids
  let b ← takeAxis0 biases ids
  dequantizeRow M rows s b

/-- The actual singleton buffer gives exactly the canonical embedding value.
Only indices inside the three gathered rows are read by dequantization, so
unrelated bytes beyond a native argmax's one-element result are irrelevant. -/
theorem bufferEmbed_eq (M : MlxContract C) (words scales biases ids : Value) (token : Nat)
    (h : TokenBuffer ids token) (hw : words.dtype = .uint32)
    (hws : words.shape = [248320, 640]) (hss : scales.shape = [248320, 80])
    (hbs : biases.shape = [248320, 80]) :
    bufferEmbed M words scales biases ids = embedTrace M words scales biases token := by
  have hc : TokenBuffer (tokenIds token) token := ⟨.inl rfl, rfl, rfl, h.bounded⟩
  unfold bufferEmbed embedTrace
  rw [h.gather ids token words 248320 640 hws, hc.gather _ _ words 248320 640 hws]
  simp only [bind, Option.bind]
  rw [h.gather ids token scales 248320 80 hss, hc.gather _ _ scales 248320 80 hss]
  simp only [bind, Option.bind]
  rw [h.gather ids token biases 248320 80 hbs, hc.gather _ _ biases 248320 80 hbs]
  simp only [bind, Option.bind]
  have ew : (fun b : Fin 2560 => (gathered words ids 248320 640).byte b.val) =
      (fun b : Fin 2560 => (gathered words (tokenIds token) 248320 640).byte b.val) := by
    funext b
    unfold Value.byte
    rw [h.gather_elems ids token words 248320 640 (b.val / 4) (by omega)]
  have es : (fun g : Fin 80 => bf ((gathered scales ids 248320 80).elems g.val)) =
      (fun g : Fin 80 => bf ((gathered scales (tokenIds token) 248320 80).elems g.val)) := by
    funext g
    rw [h.gather_elems ids token scales 248320 80 g.val g.isLt]
  have eb : (fun g : Fin 80 => bf ((gathered biases ids 248320 80).elems g.val)) =
      (fun g : Fin 80 => bf ((gathered biases (tokenIds token) 248320 80).elems g.val)) := by
    funext g
    rw [h.gather_elems ids token biases 248320 80 g.val g.isLt]
  unfold dequantizeRow
  simp only [gathered, hw, and_self, ↓reduceIte] at *
  rw [ew, es, eb]

end Host.Mlx.GlueStep

import host.simgraph.family.Eval
import host.simgraph.mach.TotalOps
namespace Host.Mlx.SimGraph.Mach
open Inference Inference.Contracts.Mlx Inference.Kernels Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph

/-! # The multi-row MLX operations are defined on well-typed arguments

The prefill forwards' value instances (`valueB`: `primEvalE`, the decode semantics `primEval` else the
multi-row semantics `rowsEval`, over `MlxPrefillContract`) on arguments of the forwards' dtypes and shapes:
each operation the GPU row families and the Neural Engine families issue is defined and its result has the
operation's type. The decode semantics fails on the multi-row shapes (its guards fix one row) and the multi-row
semantics gives the value; every `MlxPrefillContract` field the operations read gives elements in the shape the
wrapper fixes, so no field is needed beyond its type.

* `OkV x Q`: `x` is defined and its value satisfies `Q`; `OkV.bind`, `OkV.pure`, `OkV.map`.
* One lemma per operation (`ok_*`). -/

/-- `x` is defined and its value satisfies `Q`. -/
def OkV {α : Type} (x : Option α) (Q : α → Prop) : Prop := ∃ a, x = some a ∧ Q a

theorem OkV.bind {α β : Type} {x : Option α} {f : α → Option β} {Q : α → Prop} {R : β → Prop}
    (h : OkV x Q) (hf : ∀ a, Q a → OkV (f a) R) : OkV (x >>= f) R := by
  obtain ⟨a, ha, hq⟩ := h
  obtain ⟨b, hb, hr⟩ := hf a hq
  exact ⟨b, by rw [ha]; exact hb, hr⟩

theorem OkV.pure {α : Type} {a : α} {Q : α → Prop} (h : Q a) : OkV (Pure.pure a : Option α) Q := ⟨a, rfl, h⟩

theorem OkV.map {α β : Type} {x : Option α} {f : α → β} {Q : α → Prop} {R : β → Prop} (h : OkV x Q)
    (hf : ∀ a, Q a → R (f a)) : OkV (f <$> x) R := by
  obtain ⟨a, ha, hq⟩ := h
  exact ⟨f a, by rw [ha]; rfl, hf a hq⟩

theorem OkV.mono {α : Type} {x : Option α} {Q R : α → Prop} (h : OkV x Q) (hf : ∀ a, Q a → R a) : OkV x R := by
  obtain ⟨a, ha, hq⟩ := h
  exact ⟨a, ha, hf a hq⟩

theorem OkV.of_eq {α : Type} {x : Option α} {a : α} {Q : α → Prop} (h : x = some a) (hq : Q a) : OkV x Q :=
  ⟨a, h, hq⟩

/-! ## Shapes as the forwards write them -/

theorem natShape_ofNat (l : List Nat) : natShape (l.map Int.ofNat) = some l := by
  induction l with
  | nil => rfl
  | cons d ds ih =>
    rw [List.map_cons]
    unfold natShape
    rw [ite_eq_left (by rw [Int.ofNat_eq_natCast]; omega), ih]
    simp

theorem count_neg_ofNat (l : List Nat) : (l.map Int.ofNat).count (-1) = 0 := by
  induction l with
  | nil => rfl
  | cons d ds ih =>
    rw [List.map_cons, List.count_cons, ih]
    simp only [beq_iff_eq]
    rw [ite_eq_right (by rw [Int.ofNat_eq_natCast]; omega)]

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : KernelContract C) {κ : Type} (env : Env κ)
  (ks : KernelSem)

/-! ## The evaluation's cases -/

theorem primEvalP_some {p : RPrim Int κ} {xs : List Value} {y : Value}
    (h : primEval P.toMlxContract K env p xs = some y) : primEvalP P K env p xs = some y := by
  simp [primEvalP, h, Option.orElse]

theorem primEvalP_rows {p : RPrim Int κ} {xs : List Value}
    (h : primEval P.toMlxContract K env p xs = none) : primEvalP P K env p xs = rowsEval P p xs := by
  simp [primEvalP, h, Option.orElse]

/-- A plain operation (no kernel, no closure): `primEvalP`. -/
theorem primEvalE_plain (p : RPrim Int κ) (xs : List Value) (hk : ∀ nm c o, p ≠ .kernel nm c o)
    (hg : p ≠ .computeG) (hc : closureOf? p = none) : primEvalE P K env ks p xs = primEvalP P K env p xs := by
  unfold primEvalE
  split
  · exact absurd rfl (hk _ _ _)
  · exact absurd rfl hg
  · rw [hc]

/-- A plain operation whose decode semantics has the value. -/
theorem okE_decode {p : RPrim Int κ} {xs : List Value} {Q : Value → Prop} (hk : ∀ nm c o, p ≠ .kernel nm c o)
    (hg : p ≠ .computeG) (hc : closureOf? p = none) (h : OkV (primEval P.toMlxContract K env p xs) Q) :
    OkV (primEvalE P K env ks p xs) Q := by
  obtain ⟨y, hy, hq⟩ := h
  exact ⟨y, by rw [primEvalE_plain P K env ks p xs hk hg hc, primEvalP_some P K env hy], hq⟩

/-- A plain operation the decode semantics leaves undefined, whose multi-row semantics has the value. -/
theorem okE_rows {p : RPrim Int κ} {xs : List Value} {Q : Value → Prop} (hk : ∀ nm c o, p ≠ .kernel nm c o)
    (hg : p ≠ .computeG) (hc : closureOf? p = none) (h0 : primEval P.toMlxContract K env p xs = none)
    (h : OkV (rowsEval P p xs) Q) : OkV (primEvalE P K env ks p xs) Q := by
  rw [primEvalE_plain P K env ks p xs hk hg hc, primEvalP_rows P K env h0]
  exact h

theorem okE_input (k : κ) {Q : Value → Prop} (h : OkV (env.inputs k) Q) :
    OkV (primEvalE P K env ks (.input k) []) Q := by
  have e : primEvalE P K env ks (.input k) [] = env.inputs k := by
    simp only [primEvalE, closureOf?, primEvalP, primEval, Option.orElse]
    cases env.inputs k <;> rfl
  rw [e]; exact h

end

/-! ## Layout and elementwise operations -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : KernelContract C) {κ : Type} (env : Env κ)
  (ks : KernelSem)

theorem ok_rmsNorm (eps : Nat) {x w : Value} {sh : List Nat} {d : Nat} (hx : Ty x .bfloat16 sh)
    (hw : Ty w .bfloat16 [d]) (hl : sh.getLast? = some d) (hd : d = 5120 ∨ d = 256 ∨ d = 128) :
    OkV (primEvalE P K env ks (.rmsNorm eps) [x, w]) (fun u => Ty u .bfloat16 sh) := by
  have hk : ∀ nm c o, (RPrim.rmsNorm eps : RPrim Int κ) ≠ .kernel nm c o := fun _ _ _ h => nomatch h
  rcases hd with rfl | rfl | rfl
  · refine okE_decode P K env ks hk (fun h => nomatch h) rfl ?_
    have hn : normPlatform P.toMlxContract w = some P.hiddenNorm := by
      unfold normPlatform; rw [hw.2]; rfl
    show OkV ((normPlatform P.toMlxContract w).bind fun pl => rmsNorm pl x w (f32 eps)) _
    rw [hn, Option.bind_some]
    exact rmsNorm_ty _ _ hx hw hl (by decide)
  · refine okE_decode P K env ks hk (fun h => nomatch h) rfl ?_
    have hn : normPlatform P.toMlxContract w = some P.headNorm := by
      unfold normPlatform; rw [hw.2]; rfl
    show OkV ((normPlatform P.toMlxContract w).bind fun pl => rmsNorm pl x w (f32 eps)) _
    rw [hn, Option.bind_some]
    exact rmsNorm_ty _ _ hx hw hl (by decide)
  · have hn : normPlatform P.toMlxContract w = none := by
      unfold normPlatform; rw [hw.2]; rfl
    refine okE_rows P K env ks hk (fun h => nomatch h) rfl ?_ ?_
    · show (normPlatform P.toMlxContract w).bind (fun pl => rmsNorm pl x w (f32 eps)) = none
      rw [hn]; rfl
    · show OkV (rmsNormNarrow P x w (f32 eps)) _
      unfold rmsNormNarrow
      rw [hw.2]
      exact rmsNorm_ty _ _ hx hw hl (by decide)

theorem ok_reshape {v : Value} {d : Dtype} {sh : List Nat} (hv : Ty v d sh) (ds : List Int) (sh' : List Nat)
    (hds : ds = sh'.map Int.ofNat) (he : extent sh' = extent sh) :
    OkV (primEvalE P K env ks (.reshape ds) [v]) (fun u => Ty u d sh') := by
  subst hds
  refine okE_decode P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl ?_
  show OkV (reshapeDims v (sh'.map Int.ofNat)) _
  unfold reshapeDims
  rw [ite_eq_right (by rw [count_neg_ofNat]; omega), natShape_ofNat, Option.bind_some]
  exact reshape_ty hv sh' he

theorem ok_transpose {v : Value} {d : Dtype} {sh : List Nat} (hv : Ty v d sh) (axes : List Nat)
    (hc : axes.length = sh.length ∧ (List.range sh.length).all (fun a => axes.contains a)) :
    OkV (primEvalE P K env ks (.transpose axes) [v]) (fun u => Ty u d (axes.map fun a => sh.getD a 0)) :=
  okE_decode P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl (transpose_ty hv axes hc)

theorem ok_slice {v : Value} {d : Dtype} {sh : List Nat} (hv : Ty v d sh) (st sp sr : List Int) (st' sp' : List Nat)
    (hst : st = st'.map Int.ofNat) (hsp : sp = sp'.map Int.ofNat) (hsr : unitStrides sr = true)
    (hc : st'.length = sh.length ∧ sp'.length = sh.length ∧
      (List.zip st' (List.zip sp' sh)).all (fun (a, b, n) => a ≤ b ∧ b ≤ n)) :
    OkV (primEvalE P K env ks (.slice st sp sr) [v]) (fun u => Ty u d (List.zipWith (· - ·) sp' st')) := by
  subst hst hsp
  refine okE_decode P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl ?_
  show OkV (if unitStrides sr then (natShape (st'.map Int.ofNat)).bind fun a =>
    (natShape (sp'.map Int.ofNat)).bind fun b => slice v a b else none) _
  rw [ite_eq_left hsr, natShape_ofNat, natShape_ofNat, Option.bind_some, Option.bind_some]
  exact slice_ty hv st' sp' hc

theorem ok_sliceUpdate {v u : Value} {d : Dtype} {sv su : List Nat} (hv : Ty v d sv) (hu : Ty u d su)
    (st sp sr : List Int) (st' sp' : List Nat) (hst : st = st'.map Int.ofNat) (hsp : sp = sp'.map Int.ofNat)
    (hsr : unitStrides sr = true) (hr : List.zipWith (· - ·) sp' st' = su)
    (hc : st'.length = sv.length ∧ su.length = sv.length ∧
      (List.zip st' (List.zip su sv)).all (fun (a, n, m) => a + n ≤ m)) :
    OkV (primEvalE P K env ks (.sliceUpdate st sp sr) [v, u]) (fun y => Ty y d sv) := by
  subst hst hsp
  refine okE_decode P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl ?_
  show OkV (if unitStrides sr then (natShape (st'.map Int.ofNat)).bind fun a =>
    (natShape (sp'.map Int.ofNat)).bind fun b => sliceUpdateRange v u a b else none) _
  rw [ite_eq_left hsr, natShape_ofNat, natShape_ofNat, Option.bind_some, Option.bind_some]
  exact sliceUpdateRange_ty hv hu st' sp' hr hc

theorem ok_concat {a b : Value} {d : Dtype} {sa sb : List Nat} (ha : Ty a d sa) (hb : Ty b d sb) (axis : Nat)
    (hc : sa.length = sb.length ∧ axis < sa.length ∧
      (List.range sa.length).all (fun k => k = axis ∨ sa.getD k 0 = sb.getD k 0)) :
    OkV (primEvalE P K env ks (.concat axis) [a, b])
      (fun u => Ty u d (sa.set axis (sa.getD axis 0 + sb.getD axis 0))) :=
  okE_decode P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl (concatenate_ty ha hb axis hc)

theorem ok_sigmoid {v : Value} {sh : List Nat} (hv : Ty v .bfloat16 sh) :
    OkV (primEvalE P K env ks (.unary chars!"sigmoid") [v]) (fun u => Ty u .bfloat16 sh) :=
  okE_decode P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl
    (by show OkV (if chars!"sigmoid" = chars!"sigmoid" then sigmoid P.toMlxContract v else none) _
        rw [ite_eq_left rfl]; exact map1_ty _ hv)

theorem ok_add {a b : Value} {sh : List Nat} (ha : Ty a .bfloat16 sh) (hb : Ty b .bfloat16 sh) :
    OkV (primEvalE P K env ks (.binary chars!"add") [a, b]) (fun u => Ty u .bfloat16 sh) :=
  okE_decode P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl
    (by show OkV (if chars!"add" = chars!"multiply" then multiply a b else
          if chars!"add" = chars!"add" then add a b else none) _
        rw [ite_eq_right (by decide), ite_eq_left rfl]; exact add_ty ha hb)

theorem ok_multiply {a b : Value} {sh : List Nat} (ha : Ty a .bfloat16 sh) (hb : Ty b .bfloat16 sh) :
    OkV (primEvalE P K env ks (.binary chars!"multiply") [a, b]) (fun u => Ty u .bfloat16 sh) :=
  okE_decode P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl
    (by show OkV (if chars!"multiply" = chars!"multiply" then multiply a b else
          if chars!"multiply" = chars!"add" then add a b else none) _
        rw [ite_eq_left rfl]; exact map2_ty _ ha hb)

theorem ok_zeros (shape : List Int) (sh : List Nat) (hs : shape = sh.map Int.ofNat) (code : Nat) (d : Dtype)
    (hd : Dtype.ofCode code = some d) :
    OkV (primEvalE P K env ks (.zeros shape code) []) (fun u => Ty u d sh) := by
  subst hs
  refine okE_decode P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl ?_
  show OkV ((natShape (sh.map Int.ofNat)).bind fun s => (Dtype.ofCode code).bind fun t => some (zeros s t)) _
  rw [natShape_ofNat, hd]
  exact ⟨_, rfl, rfl, rfl⟩

end

/-! ## Data, gathers and the multi-row operations -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : KernelContract C) {κ : Type} (env : Env κ)
  (ks : KernelSem)

theorem ok_data (bytes : List Nat) (shape : List Int) (sh : List Nat) (hs : shape = sh.map Int.ofNat) (code : Nat)
    (d : Dtype) (hd : Dtype.ofCode code = some d) :
    OkV (primEvalE P K env ks (.data bytes shape code) [])
      (fun u => Ty u d sh ∧ ∀ i, u.elems i = leWord bytes d.bytes (i % extent sh)) := by
  subst hs
  refine okE_decode P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl ?_
  show OkV (dataValue bytes (sh.map Int.ofNat) code) _
  unfold dataValue
  rw [hd, natShape_ofNat]
  exact ⟨_, rfl, ⟨rfl, rfl⟩, fun _ => rfl⟩

/-- The conv state's new tail: `sliceDynamic` of the `[1, 3, 10240]` view at an int32 scalar zero. -/
theorem ok_sliceDynamic {v z : Value} {d : Dtype} (hv : Ty v d [1, 3, 10240]) (hz : Ty z .int32 [])
    (hz0 : z.elems 0 = 0) (sz : List Int) (hsz : sz = [1, 3, 10240]) :
    OkV (primEvalE P K env ks (.sliceDynamic [0] sz) [v, z]) (fun u => Ty u d [1, 3, 10240]) := by
  subst hsz
  refine okE_decode P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl ?_
  show OkV ((natShape [1, 3, 10240]).bind fun s => sliceDynamic v z [0] s) _
  have e : sliceDynamic v z [0] [1, 3, 10240] = slice v [0, 0, 0] [1, 3, 10240] := by
    unfold sliceDynamic
    rw [ite_eq_left ⟨hz.1, by rw [Value.size, hz.2]; rfl, by rw [hv.2]⟩, hv.2]
    dsimp only
    rw [show List.range [1, 3, 10240].length = [0, 1, 2] from rfl]
    simp [hz0]
  rw [show natShape [1, 3, 10240] = some [1, 3, 10240] from rfl, Option.bind_some, e]
  exact slice_ty hv _ _ (by decide)

/-- The embedding's gather of the prompt rows: an int32 `[1, n]` of indices below `2³¹`. -/
theorem ok_take {a i : Value} {d : Dtype} {rows cols n : Nat} (ha : Ty a d [rows, cols]) (hi : Ty i .int32 [1, n])
    (hb : ∀ j < n, i.elems j < 2 ^ 31) :
    OkV (primEvalE P K env ks (.take 0) [a, i]) (fun u => Ty u d [1, n, cols]) := by
  refine okE_decode P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl ?_
  show OkV (if 0 = 0 then takeAxis0 a i else none) _
  rw [ite_eq_left rfl]
  unfold takeAxis0
  have hall : (List.range (extent i.shape)).all (fun j => i.elems j < 2 ^ 31) = true := by
    rw [hi.2]
    simp only [extent, List.foldr, Nat.one_mul, Nat.mul_one, List.all_eq_true, List.mem_range, decide_eq_true_eq]
    exact hb
  rw [ite_eq_right (by rw [hi.1]; decide), ite_eq_left ⟨hi.1, hall⟩]
  unfold takeRows
  rw [ha.2]
  exact ⟨_, rfl, ha.1, by rw [hi.2]; rfl⟩

theorem dequantize4_ty {w s b : Value} {lead : List Nat} {words : Nat} (hw : Ty w .uint32 (lead ++ [words]))
    (hs : Ty s .bfloat16 (lead ++ [words * 8 / 64])) (hb : Ty b .bfloat16 (lead ++ [words * 8 / 64]))
    (hpos : 0 < words) : OkV (dequantize4 P w s b) (fun u => Ty u .bfloat16 (lead ++ [words * 8])) := by
  unfold dequantize4
  rw [hw.2, List.getLast?_concat]
  dsimp only
  rw [List.dropLast_concat, ite_eq_left ⟨hw.1, hs.1, hb.1, by omega, hs.2, hb.2⟩]
  exact ⟨_, rfl, rfl, rfl⟩

theorem dequantize3_ty {w s b : Value} {lead : List Nat} {words : Nat} (hw : Ty w .uint32 (lead ++ [words]))
    (hs : Ty s .bfloat16 (lead ++ [words * 32 / 3 / 64])) (hb : Ty b .bfloat16 (lead ++ [words * 32 / 3 / 64]))
    (h3 : words % 3 = 0) (h64 : words * 32 / 3 % 64 = 0) :
    OkV (dequantize3V P w s b) (fun u => Ty u .bfloat16 (lead ++ [words * 32 / 3])) := by
  unfold dequantize3V
  rw [hw.2, List.getLast?_concat]
  dsimp only
  rw [List.dropLast_concat, ite_eq_left ⟨hw.1, hs.1, hb.1, h3, h64, hs.2, hb.2⟩]
  exact ⟨_, rfl, rfl, rfl⟩

/-- 4-bit dequantize of the gathered rows: `uint32 [1, n, 640]`, scales and biases `[1, n, 80]`, `n ≥ 2`. -/
theorem ok_dequantizeRows {w s b : Value} {n : Nat} (hw : Ty w .uint32 [1, n, 640]) (hs : Ty s .bfloat16 [1, n, 80])
    (hb : Ty b .bfloat16 [1, n, 80]) (hn : 2 ≤ n) :
    OkV (primEvalE P K env ks (.dequantize 64 4 chars!"affine" none) [w, s, b])
      (fun u => Ty u .bfloat16 [1, n, 5120]) := by
  refine okE_rows P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl ?_ ?_
  · show (if 64 = 64 ∧ 4 = 4 ∧ chars!"affine" = chars!"affine" ∧ (none : Option Nat) = none then
      dequantizeRow P.toMlxContract w s b else none) = none
    rw [ite_eq_left ⟨rfl, rfl, rfl, rfl⟩]
    unfold dequantizeRow
    rw [ite_eq_right (by rw [hw.2]; intro h; have := h.2.1; simp at this; omega)]
  · show OkV (if 64 = 64 ∧ chars!"affine" = chars!"affine" ∧ (none : Option Nat) = none then
      (if 4 = 4 then dequantize4 P w s b else if 4 = 3 then dequantize3V P w s b else none) else none) _
    rw [ite_eq_left ⟨rfl, rfl, rfl⟩, ite_eq_left rfl]
    exact dequantize4_ty P (lead := [1, n]) (words := 640) hw hs hb (by decide)

/-- Dequantize of a 2-D weight (the Neural Engine forwards' dense projections) at 4 or 3 bits. -/
theorem ok_dequantize2 {w s b : Value} {rows words : Nat} (bits : Nat) (hbits : bits = 3 ∨ bits = 4)
    (hw : Ty w .uint32 [rows, words]) (hs : Ty s .bfloat16 [rows, words * 32 / bits / 64])
    (hb : Ty b .bfloat16 [rows, words * 32 / bits / 64]) (hpos : 0 < words) (h3 : bits = 3 → words % 3 = 0)
    (h64 : (words * 32 / bits) % 64 = 0) :
    OkV (primEvalE P K env ks (.dequantize 64 bits chars!"affine" none) [w, s, b])
      (fun u => Ty u .bfloat16 [rows, words * 32 / bits]) := by
  refine okE_rows P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl ?_ ?_
  · show (if 64 = 64 ∧ bits = 4 ∧ chars!"affine" = chars!"affine" ∧ (none : Option Nat) = none then
      dequantizeRow P.toMlxContract w s b else none) = none
    by_cases h4 : bits = 4
    · rw [ite_eq_left ⟨rfl, h4, rfl, rfl⟩]
      unfold dequantizeRow
      rw [ite_eq_right (by rw [hw.2]; intro h; have := h.2.1; simp at this)]
    · rw [ite_eq_right (fun h => h4 h.2.1)]
  · show OkV (if 64 = 64 ∧ chars!"affine" = chars!"affine" ∧ (none : Option Nat) = none then
      (if bits = 4 then dequantize4 P w s b else if bits = 3 then dequantize3V P w s b else none) else none) _
    rw [ite_eq_left ⟨rfl, rfl, rfl⟩]
    rcases hbits with rfl | rfl
    · rw [ite_eq_right (by decide), ite_eq_left rfl]
      exact dequantize3_ty P (lead := [rows]) hw hs hb (h3 rfl) h64
    · rw [ite_eq_left rfl]
      have e1 : words * 32 / 4 = words * 8 := by omega
      have e2 : words * 32 / 4 / 64 = words * 8 / 64 := by omega
      rw [e1]
      rw [e2] at hs hb
      exact dequantize4_ty P (lead := [rows]) hw hs hb hpos

theorem ok_conv1d {x w : Value} {n : Nat} (hx : Ty x .bfloat16 [1, n + 3, 10240]) (hw : Ty w .bfloat16 [10240, 4, 1])
    (hn : 2 ≤ n) :
    OkV (primEvalE P K env ks (.conv1d 1 0 1 10240) [x, w]) (fun u => Ty u .bfloat16 [1, n, 10240]) := by
  refine okE_rows P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl ?_ ?_
  · show conv1d P.toMlxContract x w 1 0 1 10240 = none
    unfold conv1d
    rw [hx.2]
    split
    · rename_i h; simp at h; omega
    · rfl
  · show OkV (conv1dRows P x w 1 0 1 10240) _
    unfold conv1dRows
    rw [hx.2]
    simp only
    rw [ite_eq_left ⟨hx.1, hw.1, hw.2, by omega, by decide⟩]
    exact ⟨_, rfl, rfl, by simp⟩

/-- A compiled closure node is its closure's value. -/
theorem primEvalE_closure (c : Compiled) (xs : List Value) :
    primEvalE P K env ks (closureP c) xs = compiledValue P c xs := by
  unfold primEvalE
  split
  · rename_i h; cases c <;> exact absurd h (fun e => nomatch e)
  · rename_i h; cases c <;> exact absurd h (fun e => nomatch e)
  · rw [closureOf_closureP]

theorem ok_silu {x : Value} {sh : List Nat} (hx : Ty x .bfloat16 sh) :
    OkV (primEvalE P K env ks (closureP .silu) [x]) (fun u => Ty u .bfloat16 sh) := by
  rw [primEvalE_closure]; exact map1_ty _ hx

theorem ok_swiglu {g u : Value} {sh : List Nat} (hg : Ty g .bfloat16 sh) (hu : Ty u .bfloat16 sh) :
    OkV (primEvalE P K env ks (closureP .swiglu) [g, u]) (fun y => Ty y .bfloat16 sh) := by
  rw [primEvalE_closure]; exact map2_ty _ hg hu

theorem ok_preciseSwiglu {g x : Value} {sh : List Nat} (hg : Ty g .bfloat16 sh) (hx : Ty x .bfloat16 sh) :
    OkV (primEvalE P K env ks (closureP .preciseSwiglu) [g, x]) (fun y => Ty y .bfloat16 sh) := by
  rw [primEvalE_closure]; exact map2_ty _ hg hx

theorem ok_computeG {al a dt : Value} {n : Nat} (hal : Ty al .bfloat16 [48]) (ha : Ty a .bfloat16 [1, n, 48])
    (hdt : Ty dt .bfloat16 [48]) (hn : 2 ≤ n) :
    OkV (primEvalE P K env ks .computeG [al, a, dt]) (fun u => Ty u .float32 [1, n, 48]) := by
  show OkV (computeGP P (κ := κ) [al, a, dt]) _
  unfold computeGP
  have h0 : closureApply P.toMlxContract .computeG [al, a, dt] = none := by
    unfold closureApply Closure.eval
    dsimp only
    rw [ite_eq_right (by rw [ha.2]; intro h; have := h.2.2.2; simp at this; omega)]
  rw [h0]
  show OkV (computeGRows P al a dt) _
  unfold computeGRows
  rw [ite_eq_left ⟨hal.1, ha.1, hdt.1, hal.2, hdt.2, by rw [ha.2]; rfl⟩]
  exact ⟨_, rfl, rfl, ha.2⟩

theorem ok_rope {x : Value} {sh : List Nat} (base scale : Nat) (off : Int) (hx : Ty x .bfloat16 sh)
    (h4 : sh.length = 4) (hT : 2 ≤ sh.getD 2 0) (hl : sh.getLast? = some 256) (hoff : 0 ≤ off)
    (hb : (GlueAttention.optionalFloat base).isSome) :
    OkV (primEvalE P K env ks (.rope 64 false base scale off) [x]) (fun u => Ty u .bfloat16 sh) := by
  obtain ⟨b, hb'⟩ := Option.isSome_iff_exists.mp hb
  refine okE_rows P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl ?_ ?_
  · show rope P.toMlxContract x 64 false (GlueAttention.optionalFloat base) (f32 scale) off = none
    rw [hb']
    unfold rope
    dsimp only
    rw [ite_eq_right (by rw [hx.2]; intro h; omega)]
  · show OkV (ropeRows P x 64 false (GlueAttention.optionalFloat base) (f32 scale) off) _
    rw [hb']
    unfold ropeRows
    dsimp only
    rw [ite_eq_left ⟨rfl, rfl, by rw [hx.2]; exact h4, by rw [hx.2]; exact hT, hoff⟩]
    exact rowwise_ty 256 _ hx hl (by decide)

theorem ok_sdpaCausal {q k v : Value} {n m : Nat} (hq : Ty q .bfloat16 [1, 24, n, 256])
    (hk : Ty k .bfloat16 [1, 4, m, 256]) (hv : Ty v .bfloat16 [1, 4, m, 256]) (hn : 2 ≤ n) (hnm : n ≤ m) :
    OkV (primEvalE P K env ks (.sdpa 0x3d800000 chars!"causal") [q, k, v]) (fun u => Ty u .bfloat16 [1, 24, n, 256]) := by
  refine okE_rows P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl ?_ ?_
  · show (if chars!"causal" = [] then sdpa P.toMlxContract q k v (f32 0x3d800000) else none) = none
    rw [ite_eq_right (by decide)]
  · show OkV (if chars!"causal" = chars!"causal" then sdpaCausalV P q k v (f32 0x3d800000) else none) _
    rw [ite_eq_left rfl]
    unfold sdpaCausalV
    rw [hq.2, hk.2]
    simp only
    rw [ite_eq_left ⟨hq.1, hk.1, hv.1, hv.2, hn, hnm, GlueAttention.sdpa_scale_word⟩]
    exact ⟨_, rfl, hq.1, rfl⟩

end

/-! ## The operations the contract names, and conversions -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : KernelContract C) {κ : Type} (env : Env κ)
  (ks : KernelSem)

theorem ok_matmul {a b : Value} {sa sb sh : List Nat} (ha : Ty a .bfloat16 sa) (hb : Ty b .bfloat16 sb)
    (hs : matmulOut sa sb = some sh) :
    OkV (primEvalE P K env ks (.unary chars!"matmul") [a, b]) (fun u => Ty u .bfloat16 sh) := by
  refine okE_rows P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl rfl ?_
  show OkV (if chars!"matmul" = chars!"matmul" then matmulV P a b else
    if chars!"matmul" = chars!"less_equal" then lessEqual a b else none) _
  rw [ite_eq_left rfl]
  unfold matmulV
  rw [ite_eq_left ⟨ha.1, hb.1⟩, ha.2, hb.2, hs]
  exact ⟨_, rfl, rfl, rfl⟩

theorem ok_lessEqual {a b : Value} {sa sb sh : List Nat} (ha : Ty a .int32 sa) (hb : Ty b .int32 sb)
    (hs : bshape sa sb = some sh) :
    OkV (primEvalE P K env ks (.unary chars!"less_equal") [a, b]) (fun u => Ty u .bool sh) := by
  refine okE_rows P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl rfl ?_
  show OkV (if chars!"less_equal" = chars!"matmul" then matmulV P a b else
    if chars!"less_equal" = chars!"less_equal" then lessEqual a b else none) _
  rw [ite_eq_right (by decide), ite_eq_left rfl]
  unfold lessEqual
  rw [ite_eq_left ⟨ha.1, hb.1⟩, ha.2, hb.2, hs]
  exact ⟨_, rfl, rfl, rfl⟩

theorem ok_where {c x y : Value} {d : Dtype} {sc sx sy s1 sh : List Nat} (hc : Ty c .bool sc) (hx : Ty x d sx)
    (hy : Ty y d sy) (h1 : bshape sc sx = some s1) (h2 : bshape s1 sy = some sh) :
    OkV (primEvalE P K env ks (.unary chars!"where") [c, x, y]) (fun u => Ty u d sh) := by
  refine okE_rows P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl rfl ?_
  show OkV (if chars!"where" = chars!"where" then select c x y else none) _
  rw [ite_eq_left rfl]
  unfold select
  rw [ite_eq_left ⟨hc.1, hx.1.trans hy.1.symm⟩, hc.2, hx.2, hy.2, h1, Option.bind_some, h2]
  exact ⟨_, rfl, hx.1, rfl⟩

theorem ok_softmax {a : Value} {sh : List Nat} (ha : Ty a .bfloat16 sh) (hne : sh ≠ []) (op : List Char)
    (hop : op = Ffi.axisName chars!"softmax" (sh.length - 1) true) :
    OkV (primEvalE P K env ks (.binary op) [a]) (fun u => Ty u .bfloat16 sh) := by
  refine okE_rows P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) (by subst hop; rfl) rfl ?_
  show OkV (if op = Ffi.axisName chars!"softmax" (a.shape.length - 1) true then softmaxV P a else _) _
  rw [ite_eq_left (by rw [ha.2]; exact hop)]
  unfold softmaxV
  rw [ite_eq_left ⟨ha.1, by rw [ha.2]; exact hne⟩]
  exact ⟨_, rfl, rfl, ha.2⟩

/-- `sum_axis(·, 1)` of the down pass's float32 partials `[r, 8, 5120]`. -/
theorem ok_sum1 {a : Value} {r : Nat} (ha : Ty a .float32 [r, 8, 5120]) :
    OkV (primEvalE P K env ks (.binary (Ffi.axisName chars!"sum_axis" 1 false)) [a])
      (fun u => Ty u .float32 [r, 5120]) := by
  refine okE_rows P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl rfl ?_
  show OkV (if Ffi.axisName chars!"sum_axis" 1 false = Ffi.axisName chars!"softmax" (a.shape.length - 1) true then
    softmaxV P a else match (List.range a.shape.length).find?
      (fun ax => Ffi.axisName chars!"sum_axis" 1 false = Ffi.axisName chars!"sum_axis" ax false) with
      | some ax => sumV P a ax
      | none => none) _
  rw [ha.2, show [r, 8, 5120].length = 3 from rfl, ite_eq_right (by decide), show (List.range 3).find?
      (fun ax => Ffi.axisName chars!"sum_axis" 1 false = Ffi.axisName chars!"sum_axis" ax false) = some 1 by decide]
  dsimp only
  unfold sumV
  rw [ite_eq_left ⟨ha.1, by rw [ha.2]; simp⟩]
  exact ⟨_, rfl, rfl, by rw [ha.2]; rfl⟩

theorem ok_astype {v : Value} {sh : List Nat} (hv : Ty v .float32 sh) :
    OkV (primEvalE P K env ks (.astype Ffi.dtBf16) [v]) (fun u => Ty u .bfloat16 sh) := by
  refine okE_rows P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl rfl ?_
  show OkV ((Dtype.ofCode Ffi.dtBf16).bind (astypeV v)) _
  rw [show Dtype.ofCode Ffi.dtBf16 = some .bfloat16 from rfl, Option.bind_some]
  unfold astypeV
  rw [ite_eq_right (by rw [hv.1]; decide), hv.1]
  exact ⟨_, rfl, rfl, hv.2⟩

/-- The folded read's scaling by a bf16 scalar. -/
theorem ok_mulScalar {a b : Value} {sh : List Nat} (ha : Ty a .bfloat16 sh) (hb : Ty b .bfloat16 []) (hne : sh ≠ []) :
    OkV (primEvalE P K env ks (.binary chars!"multiply") [a, b]) (fun u => Ty u .bfloat16 sh) := by
  refine okE_rows P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl ?_ ?_
  · show (if chars!"multiply" = chars!"multiply" then multiply a b else
      if chars!"multiply" = chars!"add" then add a b else none) = none
    rw [ite_eq_left rfl]
    unfold multiply map2
    rw [ite_eq_right (by rw [ha.2, hb.2]; intro h; exact hne h.2.2)]
  · show OkV (if chars!"multiply" = chars!"multiply" then multiplyScalar a b else none) _
    rw [ite_eq_left rfl]
    unfold multiplyScalar
    rw [ite_eq_right (by rw [ha.2, hb.2]; exact hne), ite_eq_left ⟨ha.1, hb.1, hb.2⟩]
    exact ⟨_, rfl, ha.1, ha.2⟩

/-- `quantized_matmul` on `m ≥ 2` rows (the Neural Engine forwards' plain projections). -/
theorem ok_qmm {x w s b : Value} {m k rows : Nat} (hx : Ty x .bfloat16 [1, m, k]) (hw : Ty w .uint32 [rows, k / 8])
    (hs : s.shape = [rows, k / 64]) (hb : b.shape = [rows, k / 64]) (hm : 2 ≤ m) (hk : k % 512 = 0) :
    OkV (primEvalE P K env ks (.qmm true 64 4 chars!"affine") [x, w, s, b]) (fun u => Ty u .bfloat16 [1, m, rows]) := by
  obtain ⟨m', rfl⟩ : ∃ m', m = m' + 2 := ⟨m - 2, by omega⟩
  refine okE_rows P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl ?_ ?_
  · show quantizedMatmul P.toMlxContract x w s b true 64 4 (String.ofList chars!"affine") = none
    unfold quantizedMatmul
    rw [hx.2, hw.2]
    rfl
  · have e : qmmRowsV P x w s b true 64 4 (String.ofList chars!"affine") =
        some ⟨.bfloat16, [1, m' + 2, rows], fun i => bfWord (P.qmmRows x w s b i)⟩ := by
      unfold qmmRowsV
      rw [hx.2, hw.2]
      simp [hx.1, hw.1, hk, hs, hb]
    exact ⟨_, e, rfl, rfl⟩

/-- `reshape(·, [1, n, -1])`: the last axis inferred. -/
theorem ok_reshapeInfer {v : Value} {d : Dtype} {sh : List Nat} {n m : Nat} (hv : Ty v d sh) (hn : 0 < n)
    (hsz : extent sh = n * m) (ds : List Int) (hds : ds = [1, (n : Int), -1]) :
    OkV (primEvalE P K env ks (.reshape ds) [v]) (fun u => Ty u d [1, n, m]) := by
  subst hds
  refine okE_decode P K env ks (fun _ _ _ h => nomatch h) (fun h => nomatch h) rfl ?_
  show OkV (reshapeDims v [1, (n : Int), -1]) _
  have hsize : v.size = n * m := by rw [hv.size, hsz]
  unfold reshapeDims GlueLayout.reshapeInfer
  have hc : [1, (n : Int), -1].count (-1) = 1 := by simp
  have hf : ([1, (n : Int), -1].filter (· ≠ -1)) = [1, (n : Int)] := by simp
  rw [ite_eq_left hc]
  dsimp only
  rw [hf, ite_eq_left ⟨hc, by simp; omega, by simp [hsize]⟩]
  have hl : ([1, (n : Int), -1].map fun d => if d = -1 then v.size / (List.foldr (fun d p => d.toNat * p) 1 [1, (n : Int)])
      else d.toNat) = [1, n, m] := by
    simp [hsize, Nat.mul_div_cancel_left m hn]
  rw [hl]
  exact reshape_ty hv [1, n, m] (by rw [hsz]; simp only [extent, List.foldr]; ring)

end

end Host.Mlx.SimGraph.Mach

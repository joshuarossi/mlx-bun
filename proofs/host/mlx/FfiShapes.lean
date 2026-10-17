import host.mlx.Ffi
import host.mlx.Ops
namespace Host.Mlx.Ffi
open Host.Ts
open Inference Inference.Contracts.Mlx Inference.Kernels

/-! # The FFI model's shapes agree with the value model

For every operation both `Host.Mlx.Ops` (values) and the FFI model (shape
inference, `infer`) define, a value result has the shape and dtype the FFI
infers from its arguments' shapes and dtypes. Shapes are literal here: the
statements are about `infer` on integer dimensions, which asks the number
server nothing (`Pure`). -/

/-- `m` returns `a` without a server request. -/
def Pure {α : Type} (m : M α) (a : α) : Prop := ∀ (β : Type) (k : α → Free β), m β k = k a

theorem Pure.ret {α : Type} (a : α) : Pure (M.pure a) a := fun _ _ => rfl

theorem Pure.bind {α β : Type} {m : M α} {f : α → M β} {a : α} {b : β} (hm : Pure m a) (hf : Pure (f a) b) :
    Pure (M.bind m f) b :=
  fun γ k => (hm γ _).trans (hf γ k)

/-- Dimensions of a value-model shape. -/
def natDims (s : List Nat) : List Dim := s.map fun n => .lit (n : Int)

/-- The shape an inferred result has, given the input shapes. -/
def Out.shape (ins : List (List Dim × Nat)) : Out → List Dim
  | .node s _ => s
  | .same i => (nthD ([], 0) ins i).1

def Out.dtype (ins : List (List Dim × Nat)) : Out → Nat
  | .node _ d => d
  | .same i => (nthD ([], 0) ins i).2

/-- `infer p ins` returns a result of shape `s` and dtype `d`, purely. -/
def Infers (p : Prim) (ins : List (List Dim × Nat)) (s : List Dim) (d : Nat) : Prop :=
  ∃ o, Pure (infer p ins) (some o) ∧ o.shape ins = s ∧ o.dtype ins = d

/-! ## Dimension arithmetic on literals -/

theorem dEq_self (x : Dim) : Pure (dEq x x) true := by
  intro β k
  cases x with
  | lit a => simp [dEq, M.pure]
  | sym y => simp [dEq, M.pure]

theorem dEq_lit (a b : Int) : Pure (dEq (.lit a) (.lit b)) (decide (a = b)) := fun _ _ => rfl
theorem dLt_lit (a b : Int) : Pure (dLt (.lit a) (.lit b)) (decide (a < b)) := fun _ _ => rfl
theorem dAdd_lit (a b : Int) : Pure (dAdd (.lit a) (.lit b)) (.lit (a + b)) := fun _ _ => rfl
theorem dSub_lit (a b : Int) : Pure (dSub (.lit a) (.lit b)) (.lit (a - b)) := fun _ _ => rfl
theorem dMul_lit (a b : Int) : Pure (dMul (.lit a) (.lit b)) (.lit (a * b)) := fun _ _ => rfl

theorem allEq_self : ∀ (a : List Dim), Pure (allEq a a) true
  | [] => Pure.ret _
  | x :: xs => Pure.bind (dEq_self x) (by simp only [Bool.cond_true]; exact allEq_self xs)

theorem natDims_length (s : List Nat) : (natDims s).length = s.length := by simp [natDims]

theorem lenL_eq {α : Type} : ∀ (l : List α) (n : Nat), lenL l n = l.length + n
  | [], n => by simp [lenL]
  | _ :: l, n => by simp only [lenL, lenL_eq l, List.length_cons]; omega

theorem len_eq {α : Type} (l : List α) : len l = l.length := by simp [len, lenL_eq]

theorem nthD_eq {α : Type} (d : α) : ∀ (l : List α) (i : Nat), nthD d l i = l.getD i d
  | [], _ => rfl
  | _ :: _, 0 => rfl
  | _ :: l, i + 1 => nthD_eq d l i

theorem nthD_natDims : ∀ (s : List Nat) (i : Nat), nthD (.lit 0) (natDims s) i = .lit (s.getD i 0 : Nat)
  | [], _ => rfl
  | _ :: _, 0 => rfl
  | _ :: s, i + 1 => nthD_natDims s i

/-! ## Broadcasting equal shapes -/

theorem broadcast_go_self : ∀ (a : List Dim), Pure (broadcast.go a a) (some a.reverse)
  | [] => Pure.ret _
  | x :: xs => by
    unfold broadcast.go
    refine Pure.bind (dEq_self x) ?_
    simp only [Bool.cond_true]
    refine Pure.bind (broadcast_go_self xs) ?_
    simp only [Option.map_some, List.reverse_cons]
    exact Pure.ret _

theorem broadcast_self (a : List Dim) : Pure (broadcast a a) (some a) := by
  unfold broadcast
  refine Pure.bind (broadcast_go_self a.reverse) ?_
  simp only [List.reverse_reverse]
  exact Pure.ret _

/-! ## Shape-preserving operations -/

theorem infers_unary (op : List Char) (s : List Dim) (d : Nat) :
    Infers (.unary op) [(s, d)] s (unaryDtype op d) :=
  ⟨.node s (unaryDtype op d), Pure.ret _, rfl, rfl⟩

theorem infers_binary_same (op : List Char) (s : List Dim) (d e : Nat) :
    Infers (.binary op) [(s, d), (s, e)] s (binaryDtype op d e) := by
  refine ⟨.node s (binaryDtype op d e), ?_, rfl, rfl⟩
  intro β k
  simp only [infer]
  exact (broadcast_self s β _)

/-! ## Agreement, operation by operation -/

section
variable {C : M1Max.Contract} (M : MlxContract C)

theorem bf16_code : Dtype.bfloat16.code = dtBf16 := rfl

theorem unaryDtype_sigmoid : unaryDtype chars!"sigmoid" dtBf16 = dtBf16 := by decide +kernel

theorem sigmoid_shape (v w : Value) (h : Host.Mlx.sigmoid M v = some w) :
    Infers (.unary chars!"sigmoid") [(natDims v.shape, v.dtype.code)] (natDims w.shape) w.dtype.code := by
  unfold Host.Mlx.sigmoid map1 at h
  split at h
  · next hd =>
    cases h
    rw [hd, bf16_code]
    have := infers_unary chars!"sigmoid" (natDims v.shape) dtBf16
    rw [unaryDtype_sigmoid] at this
    exact this
  · cases h

theorem map2_shape (op : BF → BF → BF)
    (name : List Char) (hn : binaryDtype name dtBf16 dtBf16 = dtBf16) (a b w : Value) (h : map2 op a b = some w) :
    Infers (.binary name) [(natDims a.shape, a.dtype.code), (natDims b.shape, b.dtype.code)] (natDims w.shape) w.dtype.code := by
  unfold map2 at h
  split at h
  · next hc =>
    cases h
    obtain ⟨ha, hb, hs⟩ := hc
    rw [ha, hb, ← hs]
    simp only [bf16_code]
    have := infers_binary_same name (natDims a.shape) dtBf16 dtBf16
    rw [hn] at this
    exact this
  · cases h

theorem multiply_shape (a b w : Value) (h : Host.Mlx.multiply a b = some w) :
    Infers (.binary chars!"multiply") [(natDims a.shape, a.dtype.code), (natDims b.shape, b.dtype.code)]
      (natDims w.shape) w.dtype.code := map2_shape _ _ (by decide +kernel) a b w h

theorem add_shape (a b w : Value) (h : Host.Mlx.add a b = some w) :
    Infers (.binary chars!"add") [(natDims a.shape, a.dtype.code), (natDims b.shape, b.dtype.code)]
      (natDims w.shape) w.dtype.code := map2_shape _ _ (by decide +kernel) a b w h

theorem rowwise_shape (n : Nat) (f : Nat → (Fin n → BF) → Fin n → BF)
    (v w : Value) (h : rowwise n f v = some w) :
    w.shape = v.shape ∧ w.dtype = v.dtype ∧ v.dtype = .bfloat16 ∧ v.shape.getLast? = some n ∧ 0 < n := by
  unfold rowwise at h
  split at h
  · next hc => cases h; exact ⟨rfl, rfl, hc.1, hc.2.1, hc.2.2⟩
  · cases h

theorem getD_last (s : List Nat) (n : Nat) (h : s.getLast? = some n) : s.getD (len s - 1) 0 = n := by
  rw [len_eq, List.getD_eq_getElem?_getD]
  rw [List.getLast?_eq_getElem?] at h
  simp [h]

theorem rmsNorm_shape (P : RmsNorm.Platform) (x weight w : Value) (eps : Float32) (e : NumV)
    (h : Host.Mlx.rmsNorm P x weight eps = some w) :
    Infers (.rmsNorm e) [(natDims x.shape, x.dtype.code), (natDims weight.shape, weight.dtype.code)]
      (natDims w.shape) w.dtype.code := by
  unfold Host.Mlx.rmsNorm at h
  split at h
  · next n hd hs =>
    obtain ⟨hws, hwd, hxd, hl, _⟩ := rowwise_shape _ _ _ _ h
    refine ⟨.node (natDims x.shape) dtBf16, ?_, by simp only [Out.shape, hws], by simp only [Out.dtype, hwd, hxd]; rfl⟩
    rw [hd, hs, hxd]
    simp only [infer, bf16_code]
    have hlen : len (natDims x.shape) - 1 = len x.shape - 1 := by simp [len_eq, natDims_length]
    rw [hlen, nthD_natDims, getD_last _ _ hl]
    exact Pure.bind (dEq_self _) (Pure.ret _)
  · cases h

theorem rope_shape (x w : Value) (dims : Nat) (tr : Bool) (base : Option Float32) (scale : Float32) (offset : Int)
    (d : Nat) (tr2 : Bool) (b : Arg) (sc off : NumV) (h : Host.Mlx.rope M x dims tr base scale offset = some w) :
    Infers (.rope d tr2 b sc off) [(natDims x.shape, x.dtype.code)] (natDims w.shape) w.dtype.code := by
  unfold Host.Mlx.rope at h
  split at h
  · split at h
    · next hc =>
      obtain ⟨hws, hwd, _, _, _⟩ := rowwise_shape _ _ _ _ h
      refine ⟨.node (natDims x.shape) x.dtype.code, ?_, by simp only [Out.shape, hws], by simp only [Out.dtype, hwd]⟩
      have h3 : Nat.ble 3 (len (natDims x.shape)) = true := by
        simp [len_eq, natDims_length, hc.2.2.1]
      simp only [infer, h3, Bool.cond_true]
      exact Pure.ret _
    · cases h
  · cases h

theorem sdpa_shape (q k v w : Value) (scale : Float32) (sc : NumV) (mask : List Char) (h : Host.Mlx.sdpa M q k v scale = some w) :
    Infers (.sdpa sc mask) [(natDims q.shape, q.dtype.code), (natDims k.shape, k.dtype.code), (natDims v.shape, v.dtype.code)]
      (natDims w.shape) w.dtype.code := by
  unfold Host.Mlx.sdpa at h
  split at h
  · next n hk =>
    split at h
    · next hc =>
      cases h
      obtain ⟨hq, hkd, hv, hqs, hvs, _⟩ := hc
      refine ⟨.node (natDims q.shape) dtBf16, ?_, rfl, by simp only [Out.dtype, hq]; rfl⟩
      rw [hk, hq, hkd, hv, hqs, hvs]
      exact Pure.ret _
    · cases h
  · cases h


theorem promote_self (d : Dtype) : promote d.code d.code = d.code := by cases d <;> decide +kernel

theorem natDims_append (a b : List Nat) : natDims (a ++ b) = natDims a ++ natDims b := by simp [natDims]

theorem conv1d_shape (input weight w : Value) (st pd dl gr : Nat) (hc : 0 < input.shape.getD 2 0)
    (h : Host.Mlx.conv1d M input weight st pd dl gr = some w) :
    Infers (.conv1d st pd dl gr) [(natDims input.shape, input.dtype.code), (natDims weight.shape, weight.dtype.code)]
      (natDims w.shape) w.dtype.code := by
  unfold Host.Mlx.conv1d at h
  split at h
  · next c hs =>
    split at h
    · next hcond =>
      cases h
      obtain ⟨hi, hwd, hws, hsel⟩ := hcond
      simp only [Delta.Convolution.depthwiseSelected, Bool.and_eq_true, beq_iff_eq, Bool.not_false] at hsel
      obtain ⟨⟨⟨⟨⟨⟨_, hg⟩, _⟩, hst⟩, hdl⟩, hpd⟩, _⟩ := hsel
      subst hg hst hdl hpd
      rw [hs] at hc
      simp only [List.getD_cons_succ, List.getD_cons_zero] at hc
      refine ⟨.node (natDims [1, 1, gr]) dtBf16, ?_, rfl, rfl⟩
      rw [hs, hws, hi, hwd]
      have hx : natDims [1, 4, gr] = [.lit 1, .lit 4, .lit (gr : Int)] := rfl
      have hw : natDims [gr, 4, 1] = [.lit (gr : Int), .lit 4, .lit 1] := rfl
      have hcond : decide (0 < 1 ∧ 0 < gr ∧ (gr : Int) = 1 * (gr : Int)) = true := by simp; omega
      have hlo : ((4 : Int) + 2 * ((0 : Nat) : Int) - ((1 : Nat) : Int) * (4 - 1) - 1) / ((1 : Nat) : Int) + 1 = 1 := by decide
      rw [hx, hw]
      intro β k
      simp only [infer, hcond, Bool.cond_true, hlo, bf16_code, promote_self]
      rfl
    · cases h
  · cases h


@[simp] theorem nthD_cons_zero {α : Type} (d a : α) (l : List α) : nthD d (a :: l) 0 = a := rfl
@[simp] theorem nthD_cons_succ {α : Type} (d a : α) (l : List α) (n : Nat) : nthD d (a :: l) (n + 1) = nthD d l n := rfl
@[simp] theorem M_bind_pure {α β : Type} (a : α) (f : α → Host.Ts.M β) : Host.Ts.M.bind (Host.Ts.M.pure a) f = f a := rfl
@[simp] theorem dEq_lit_eq (a b : Int) : dEq (.lit a) (.lit b) = Host.Ts.M.pure (decide (a = b)) := rfl

theorem affine_ne : nameEq chars!"affine" chars!"affine" = true := by decide +kernel

theorem quantizedMatmul_shape (x wq sc bi w : Value) (tr : Bool) (g b : Nat) (mode : String)
    (hs : sc.dtype = .bfloat16 ∧ bi.dtype = .bfloat16)
    (h : Host.Mlx.quantizedMatmul M x wq sc bi tr g b mode = some w) :
    Infers (.qmm tr g b chars!"affine") [(natDims x.shape, x.dtype.code), (natDims wq.shape, wq.dtype.code),
      (natDims sc.shape, sc.dtype.code), (natDims bi.shape, bi.dtype.code)] (natDims w.shape) w.dtype.code := by
  unfold Host.Mlx.quantizedMatmul at h
  split at h
  · next kk rows other hx hw =>
    split at h
    · next hcond =>
      cases h
      obtain ⟨hxd, hwd, htr, hg, hb, _, hk, hw2, hsc, hbi⟩ := hcond
      subst htr hg hb
      refine ⟨.node (natDims [1, 1, rows]) dtBf16, ?_, rfl, rfl⟩
      rw [hx, hw2, hsc, hbi, hxd, hwd, hs.1, hs.2]
      have hX : natDims [1, 1, kk] = [.lit 1, .lit 1, .lit (kk : Int)] := rfl
      have hW : natDims [rows, kk / 8] = [.lit (rows : Int), .lit ((kk / 8 : Nat) : Int)] := rfl
      have hinner : ((kk / 8 : Nat) : Int) * 32 / ((4 : Nat) : Int) = (kk : Int) := by omega
      have hpre : (!nameEq chars!"affine" chars!"affine" || !Nat.beq Dtype.uint32.code dtUint32 || Nat.beq 4 0) = false := by
        decide +kernel
      have hdt : promote Dtype.bfloat16.code (promote Dtype.bfloat16.code Dtype.bfloat16.code) = dtBf16 := by decide +kernel
      have hfl : isFloat dtBf16 = true := by decide +kernel
      rw [hX, hW]
      intro β k
      simp only [infer, hpre, Bool.cond_false, len_eq, List.length_cons, List.length_nil, nthD_cons_zero, nthD_cons_succ,
        Nat.reduceAdd, Nat.reduceSub, dEq_lit_eq, M_bind_pure, hinner, decide_true]
      have he := allEq_self (natDims [rows, kk / 64]) β
      simp only [Host.Ts.M.bind] at he ⊢
      rw [he]
      simp [hdt, hfl, setAt, natDims, Host.Ts.M.pure]
    · cases h
  · cases h


theorem dequantizeRow_shape (wq sc bi w : Value) (g : Nat) (hs : sc.dtype = .bfloat16 ∧ bi.dtype = .bfloat16)
    (h : Host.Mlx.dequantizeRow M wq sc bi = some w) :
    Infers (.dequantize g 4 chars!"affine" none) [(natDims wq.shape, wq.dtype.code), (natDims sc.shape, sc.dtype.code),
      (natDims bi.shape, bi.dtype.code)] (natDims w.shape) w.dtype.code := by
  unfold Host.Mlx.dequantizeRow at h
  split at h
  · next hcond =>
    cases h
    obtain ⟨hwd, hws, hsc, hbi⟩ := hcond
    refine ⟨.node (natDims [1, 1, 5120]) dtBf16, ?_, rfl, rfl⟩
    rw [hws, hsc, hbi, hwd, hs.1, hs.2]
    have hpre : (!nameEq chars!"affine" chars!"affine" || !Nat.beq Dtype.uint32.code dtUint32 || Nat.beq 4 0) = false := by
      decide +kernel
    have hdt : promote Dtype.bfloat16.code Dtype.bfloat16.code = dtBf16 := by decide +kernel
    have hW : natDims [1, 1, 640] = [.lit 1, .lit 1, .lit 640] := rfl
    rw [hW]
    intro β k
    have he := allEq_self (natDims [1, 1, 80]) β
    unfold infer
    simp only [hpre, Bool.cond_false, len_eq, List.length_cons, List.length_nil, Nat.reduceAdd,
      Nat.reduceSub, nthD_cons_zero, nthD_cons_succ]
    simp only [Host.Ts.M.bind, he, hdt]
    rfl
  · cases h

theorem takeAxis0_shape (table ids w : Value) (h : Host.Mlx.takeAxis0 table ids = some w) :
    Infers (.take 0) [(natDims table.shape, table.dtype.code), (natDims ids.shape, ids.dtype.code)]
      (natDims w.shape) w.dtype.code := by
  unfold Host.Mlx.takeAxis0 takeRows at h
  split at h
  · next hid =>
    split at h
    · next rows cols ht =>
      cases h
      refine ⟨.node (natDims (ids.shape ++ [cols])) table.dtype.code, ?_, rfl, rfl⟩
      rw [ht, hid]
      have hint : isInteger Dtype.uint32.code = true := by decide +kernel
      have hb : Nat.blt 0 (len (natDims [rows, cols])) = true := rfl
      intro β k
      simp only [infer, hb, hint, Bool.and_true, Bool.cond_true, natDims_append]
      rfl
    · cases h
  · cases h

theorem natDims_map {α : Type} (f : α → Nat) : ∀ (l : List α), natDims (l.map f) = l.map (fun a => Dim.lit (f a : Int))
  | [] => rfl
  | a :: l => by simp only [List.map_cons]; exact congrArg (Dim.lit (f a : Int) :: ·) (natDims_map f l)

theorem any_beq (axes : List Nat) (a : Nat) : axes.any (Nat.beq a) = axes.contains a := by
  induction axes with
  | nil => rfl
  | cons x xs ih =>
    simp only [List.any_cons, List.contains_cons, ih]
    congr 1

theorem transpose_shape (v w : Value) (axes : List Nat) (h : Host.Mlx.transpose v axes = some w) :
    Infers (.transpose axes) [(natDims v.shape, v.dtype.code)] (natDims w.shape) w.dtype.code := by
  unfold Host.Mlx.transpose at h
  split at h
  · next hc =>
    cases h
    refine ⟨.node (natDims (axes.map fun a => v.shape.getD a 0)) v.dtype.code, ?_, rfl, rfl⟩
    have hl : Nat.beq (len axes) (len (natDims v.shape)) = true := by
      simp [len_eq, natDims_length, hc.1]
    have ha : ((List.range (len (natDims v.shape))).all fun a => axes.any (Nat.beq a)) = true := by
      simp only [len_eq, natDims_length, any_beq]
      exact hc.2
    have hm : axes.map (nthD (.lit 0) (natDims v.shape)) = natDims (axes.map fun a => v.shape.getD a 0) := by
      rw [natDims_map]
      exact List.map_congr_left (fun a _ => nthD_natDims v.shape a)
    intro β k
    simp only [infer, hl, ha, Bool.and_self, Bool.cond_true, hm]
    rfl
  · cases h


theorem Pure.congr {α : Type} {m : Host.Ts.M α} {a b : α} (h : Pure m a) (e : a = b) : Pure m b := e ▸ h

theorem dProd_natDims : ∀ (s : List Nat), Pure (dProd (natDims s)) (.lit ((s.foldr (· * ·) 1 : Nat) : Int))
  | [] => Pure.ret _
  | d :: ds => Pure.bind (dProd_natDims ds) (Pure.congr (dMul_lit _ _) (by simp only [List.foldr, Nat.cast_mul]))

theorem filter_natDims : ∀ (s : List Nat), (natDims s).filter (· = .lit (-1)) = []
  | [] => rfl
  | n :: s => by
    show List.filter _ (Dim.lit (n : Int) :: natDims s) = []
    have : ¬ (Dim.lit (n : Int) = Dim.lit (-1)) := by intro h; cases h
    simp [List.filter_cons, filter_natDims s, this]

theorem reshape_shape (v w : Value) (shape : List Nat) (h : Host.Mlx.reshape v shape = some w) :
    Infers (.reshape (natDims shape)) [(natDims v.shape, v.dtype.code)] (natDims w.shape) w.dtype.code := by
  unfold Host.Mlx.reshape at h
  split at h
  · next hp =>
    cases h
    refine ⟨.node (natDims shape) v.dtype.code, ?_, rfl, rfl⟩
    show Pure (Host.Ts.M.bind (reshapeShape (natDims v.shape) (natDims shape))
      fun r => Host.Ts.M.pure (r.map (Out.node · v.dtype.code))) _
    refine Pure.bind (a := some (natDims shape)) ?_ (Pure.ret _)
    unfold reshapeShape
    rw [filter_natDims]
    refine Pure.bind (dProd_natDims _) ?_
    refine Pure.bind (dProd_natDims _) ?_
    have he : decide (((shape.foldr (· * ·) 1 : Nat) : Int) = ((v.shape.foldr (· * ·) 1 : Nat) : Int)) = true := by
      simp only [decide_eq_true_eq]; exact congrArg _ hp
    exact Pure.bind (Pure.congr (dEq_lit _ _) he) (Pure.ret _)
  · cases h

theorem dMin_lit (a b : Int) : Pure (dMin (.lit a) (.lit b)) (.lit (min a b)) := by
  intro β k
  show k (bif decide (a < b) then Dim.lit a else Dim.lit b) = k (Dim.lit (min a b))
  by_cases h : a < b
  · simp [h, min_eq_left (le_of_lt h)]
  · simp [h, min_eq_right (not_lt.mp h)]

theorem dMax_lit (a b : Int) : Pure (dMax (.lit a) (.lit b)) (.lit (max a b)) := by
  intro β k
  show k (bif decide (a < b) then Dim.lit b else Dim.lit a) = k (Dim.lit (max a b))
  by_cases h : a < b
  · simp [h, max_eq_right (le_of_lt h)]
  · simp [h, max_eq_left (not_lt.mp h)]

/-- One literal slice axis inside the array, stride 1: its length. -/
theorem sliceAxis_lit (n a b : Nat) (h1 : a ≤ b) (h2 : b ≤ n) :
    Pure (sliceAxis (.lit n) (.lit a) (.lit b) (.lit 1)) (some (.lit ((b - a : Nat) : Int))) := by
  unfold sliceAxis
  refine Pure.bind (Pure.congr (dLt_lit _ _) (decide_eq_false (by omega : ¬ ((a : Int) < 0)))) ?_
  simp only [Bool.cond_false]
  refine Pure.bind (Pure.ret _) ?_
  refine Pure.bind (Pure.congr (dLt_lit _ _) (decide_eq_false (by omega : ¬ ((b : Int) < 0)))) ?_
  simp only [Bool.cond_false]
  refine Pure.bind (Pure.ret _) ?_
  refine Pure.bind (Pure.congr (dMin_lit _ _) (congrArg Dim.lit (min_eq_left (by omega : (a : Int) ≤ n)))) ?_
  refine Pure.bind (Pure.congr (dMax_lit _ _) (congrArg Dim.lit (max_eq_right (by omega : (0 : Int) ≤ a)))) ?_
  refine Pure.bind (Pure.congr (dMin_lit _ _) (congrArg Dim.lit (min_eq_left (by omega : (b : Int) ≤ n)))) ?_
  refine Pure.bind (Pure.congr (dMax_lit _ _) (congrArg Dim.lit (max_eq_right (by omega : (0 : Int) ≤ b)))) ?_
  refine Pure.bind (Pure.congr (dLt_lit _ _) (decide_eq_false (by omega : ¬ ((b : Int) < a)))) ?_
  simp only [Bool.cond_false]
  exact Pure.bind (dSub_lit _ _) (Pure.congr (Pure.ret _) (by congr 2; omega))

theorem sliceShape_lit : ∀ (s st sp : List Nat), st.length = s.length → sp.length = s.length →
    ((List.zip st (List.zip sp s)).all fun (a, b, n) => decide (a ≤ b ∧ b ≤ n)) = true →
    Pure (sliceShape (natDims s) (natDims st) (natDims sp) (natDims (List.replicate s.length 1)))
      (some (natDims (List.zipWith (· - ·) sp st)))
  | [], [], [], _, _, _ => Pure.ret _
  | n :: s, a :: st, b :: sp, h1, h2, h3 => by
    simp only [List.zip_cons_cons, List.all_cons, Bool.and_eq_true, decide_eq_true_eq] at h3
    show Pure (Host.Ts.M.bind (sliceAxis (.lit n) (.lit a) (.lit b) (.lit 1)) _) _
    refine Pure.bind (sliceAxis_lit n a b h3.1.1 h3.1.2) ?_
    refine Pure.bind (sliceShape_lit s st sp (by simpa using h1) (by simpa using h2) h3.2) ?_
    exact Pure.ret _
  | [], _ :: _, _, h1, _, _ => by simp at h1
  | [], [], _ :: _, _, h2, _ => by simp at h2
  | _ :: _, [], _, h1, _, _ => by simp at h1
  | _ :: _, _ :: _, [], _, h2, _ => by simp at h2

theorem allEq_natDims : ∀ (a b : List Nat), Pure (allEq (natDims a) (natDims b)) (decide (a = b))
  | [], [] => Pure.ret _
  | x :: a, y :: b => by
    show Pure (Host.Ts.M.bind (dEq (.lit x) (.lit y)) _) _
    refine Pure.bind (dEq_lit _ _) ?_
    by_cases hxy : x = y
    · subst hxy
      simp only [decide_true, Bool.cond_true]
      exact Pure.congr (allEq_natDims a b) (by simp)
    · have : decide ((x : Int) = y) = false := by simp; omega
      simp only [this, Bool.cond_false]
      exact Pure.congr (Pure.ret _) (by simp [hxy])
  | [], _ :: _ => Pure.congr (Pure.ret _) (by simp)
  | _ :: _, [] => Pure.congr (Pure.ret _) (by simp)

theorem slice_shape (v w : Value) (start stop : List Nat) (h : Host.Mlx.slice v start stop = some w) :
    Infers (.slice (natDims start) (natDims stop) (natDims (List.replicate v.shape.length 1)))
      [(natDims v.shape, v.dtype.code)] (natDims w.shape) w.dtype.code := by
  unfold Host.Mlx.slice at h
  split at h
  · next hc =>
    cases h
    obtain ⟨h1, h2, h3⟩ := hc
    have hl : Nat.beq (len (natDims start)) (len (natDims v.shape)) = true := by simp [len_eq, natDims_length, h1]
    by_cases he : List.zipWith (· - ·) stop start = v.shape
    · refine ⟨.same 0, ?_, by simp [Out.shape, nthD, he], rfl⟩
      show Pure (bif Nat.beq (len (natDims start)) (len (natDims v.shape)) then _ else _) _
      rw [hl, Bool.cond_true]
      refine Pure.bind (sliceShape_lit v.shape start stop h1 h2 h3) ?_
      refine Pure.bind (allEq_natDims _ _) ?_
      simp only [he, decide_true, Bool.cond_true]
      exact Pure.ret _
    · refine ⟨.node (natDims (List.zipWith (· - ·) stop start)) v.dtype.code, ?_, rfl, rfl⟩
      show Pure (bif Nat.beq (len (natDims start)) (len (natDims v.shape)) then _ else _) _
      rw [hl, Bool.cond_true]
      refine Pure.bind (sliceShape_lit v.shape start stop h1 h2 h3) ?_
      refine Pure.bind (allEq_natDims _ _) ?_
      simp only [he, decide_false, Bool.cond_false]
      exact Pure.ret _
  · cases h

theorem zipWith_sub_add : ∀ (a b : List Nat), a.length = b.length →
    List.zipWith (· - ·) (List.zipWith (· + ·) a b) a = b
  | [], [], _ => rfl
  | x :: a, y :: b, h => by simp only [List.zipWith_cons_cons, Nat.add_sub_cancel_left, zipWith_sub_add a b (by simpa using h)]
  | [], _ :: _, h => by simp at h
  | _ :: _, [], h => by simp at h

theorem zip_add_le : ∀ (a u s : List Nat),
    ((List.zip a (List.zip u s)).all fun (x, n, m) => decide (x + n ≤ m)) = true →
    ((List.zip a (List.zip (List.zipWith (· + ·) a u) s)).all fun (x, y, m) => decide (x ≤ y ∧ y ≤ m)) = true
  | [], _, _, _ => rfl
  | _ :: _, [], _, _ => rfl
  | _ :: _, _ :: _, [], _ => rfl
  | x :: a, n :: u, m :: s, h => by
    simp only [List.zip_cons_cons, List.all_cons, Bool.and_eq_true, decide_eq_true_eq, List.zipWith_cons_cons] at h ⊢
    exact ⟨⟨Nat.le_add_right _ _, h.1⟩, zip_add_le a u s h.2⟩

theorem sliceUpdateRange_shape (v u w : Value) (start stop : List Nat) (hstop : stop = List.zipWith (· + ·) start u.shape)
    (h : Host.Mlx.sliceUpdateRange v u start stop = some w) :
    Infers (.sliceUpdate (natDims start) (natDims stop) (natDims (List.replicate v.shape.length 1)))
      [(natDims v.shape, v.dtype.code), (natDims u.shape, u.dtype.code)] (natDims w.shape) w.dtype.code := by
  unfold Host.Mlx.sliceUpdateRange Host.Mlx.sliceUpdate at h
  split at h
  · split at h
    · next hc =>
      cases h
      obtain ⟨_, h1, h2, h3⟩ := hc
      subst hstop
      refine ⟨.node (natDims v.shape) v.dtype.code, ?_, rfl, rfl⟩
      have hsl : (List.zipWith (· + ·) start u.shape).length = v.shape.length := by simp [h1, h2]
      show Pure (Host.Ts.M.bind (sliceShape _ _ _ _) _) _
      refine Pure.bind (sliceShape_lit v.shape start _ h1 hsl (zip_add_le start u.shape v.shape h3)) ?_
      rw [zipWith_sub_add start u.shape (by rw [h1, h2])]
      refine Pure.bind (broadcast_self _) ?_
      refine Pure.bind (allEq_self _) ?_
      exact Pure.ret _
    · cases h
  · cases h

theorem sliceDynamic_shape (v st w : Value) (axes sizes : List Nat) (hst : st.shape.length ≤ 1)
    (hax : ∀ a ∈ axes, a < v.shape.length) (h : Host.Mlx.sliceDynamic v st axes sizes = some w) :
    Infers (.sliceDynamic axes (natDims sizes)) [(natDims v.shape, v.dtype.code), (natDims st.shape, st.dtype.code)]
      (natDims w.shape) w.dtype.code := by
  unfold Host.Mlx.sliceDynamic at h
  split at h
  · next hc =>
    obtain ⟨hsd, _, hlen⟩ := hc
    unfold Host.Mlx.slice at h
    dsimp only at h
    split at h
    · next hc2 =>
      cases h
      refine ⟨.node (natDims sizes) v.dtype.code, ?_, ?_, rfl⟩
      · have hi : isInteger st.dtype.code = true := by rw [hsd]; decide +kernel
        have hb : (Nat.beq (len (natDims sizes)) (len (natDims v.shape)) && isInteger st.dtype.code &&
            Nat.ble (len (natDims st.shape)) 1 && axes.all (Nat.blt · (len (natDims v.shape)))) = true := by
          simp only [len_eq, natDims_length, hlen, hi, Bool.and_eq_true, Nat.beq_eq_true_eq, Nat.ble_eq, hst,
            List.all_eq_true, Nat.blt_eq, true_and, and_true]
          exact ⟨by simp [Nat.beq_eq], hax⟩
        show Pure (bif _ then _ else _) _
        rw [hb, Bool.cond_true]
        exact Pure.ret _
      · show natDims sizes = natDims (List.zipWith (· - ·) (List.zipWith (· + ·) _ sizes) _)
        rw [zipWith_sub_add _ _ (by simp [hlen])]
    · cases h
  · cases h


theorem setAt_natDims : ∀ (s : List Nat) (i x : Nat), setAt (natDims s) i (.lit (x : Int)) = natDims (s.set i x)
  | [], _, _ => rfl
  | _ :: _, 0, _ => rfl
  | y :: s, i + 1, x => by
    show Dim.lit (y : Int) :: setAt (natDims s) i (.lit (x : Int)) = natDims (y :: s.set i x)
    rw [setAt_natDims s i x]; rfl

theorem set_zero_eq (a b : List Nat) (axis : Nat) (hl : a.length = b.length)
    (h : ((List.range a.length).all fun k => decide (k = axis ∨ a.getD k 0 = b.getD k 0)) = true) :
    a.set axis 0 = b.set axis 0 := by
  apply List.ext_getElem (by simp [hl])
  intro k h1 h2
  simp only [List.length_set] at h1 h2
  simp only [List.getElem_set]
  by_cases hk : axis = k
  · simp [hk]
  · simp only [hk, ↓reduceIte]
    have := List.all_eq_true.mp h k (List.mem_range.mpr h1)
    simp only [decide_eq_true_eq] at this
    rcases this with e | e
    · exact absurd e.symm hk
    · simpa [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem h1, List.getElem?_eq_getElem h2] using e

theorem concatenate_shape (a b w : Value) (axis : Nat) (h : Host.Mlx.concatenate a b axis = some w) :
    Infers (.concat axis) [(natDims a.shape, a.dtype.code), (natDims b.shape, b.dtype.code)] (natDims w.shape) w.dtype.code := by
  unfold Host.Mlx.concatenate at h
  split at h
  · next hc =>
    cases h
    obtain ⟨hd, hl, _, hk⟩ := hc
    refine ⟨.node (natDims (a.shape.set axis (a.shape.getD axis 0 + b.shape.getD axis 0))) a.dtype.code, ?_, rfl, rfl⟩
    have h2 : Nat.beq (len [(natDims a.shape, a.dtype.code), (natDims b.shape, b.dtype.code)]) 1 = false := rfl
    have hlen : Nat.beq (len (natDims a.shape)) (len (natDims b.shape)) = true := by simp [len_eq, natDims_length, hl]
    have hset := set_zero_eq a.shape b.shape axis hl (by simpa using hk)
    simp only [infer, h2, Bool.cond_false]
    refine Pure.bind (a := some (natDims (a.shape.set axis (a.shape.getD axis 0 + b.shape.getD axis 0)), a.dtype.code)) ?_
      (Pure.ret _)
    unfold concatShape
    refine Pure.bind (a := some (natDims b.shape, b.dtype.code)) (by unfold concatShape; exact Pure.ret _) ?_
    simp only [hlen, Bool.cond_true, nthD_natDims]
    rw [show Dim.lit 0 = Dim.lit ((0 : Nat) : Int) from rfl, setAt_natDims, setAt_natDims, hset]
    refine Pure.bind (allEq_self _) ?_
    simp only [Bool.cond_true]
    refine Pure.bind (dAdd_lit _ _) ?_
    rw [show ((a.shape.getD axis 0 : Nat) : Int) + ((b.shape.getD axis 0 : Nat) : Int)
        = (((a.shape.getD axis 0 + b.shape.getD axis 0 : Nat)) : Int) by push_cast; rfl, setAt_natDims, hd, promote_self]
    exact Pure.ret _
  · cases h

end

end Host.Mlx.Ffi

import host.simgraph.mach.PreDelta
namespace Host.Mlx.SimGraph.Mach
open Inference Inference.Contracts.Mlx Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Mlx.SimGraph.Ref (refRows refNu refRows_o refRows_n)

/-! # An attention layer of a GPU row family is defined on well-typed inputs

`attentionLayerT` at the value backend, at the step's canonical rows: the KV append of `n` rows at offset `o`
(`kvStepT`: the buffers at capacity `kvCapP cap o n`, the views `[1, 4, o + n, 256]`), the attention read
(MLX's causal SDPA, or the folded read at `6 ≤ r ≤ 8` rows), and the layer around them. -/

/-! ## Broadcast and matmul shapes -/

theorem bcastRevN_nil (xs : List Nat) : bcastRevN xs [] = some xs := by cases xs <;> rfl

theorem bshape_nil (l : List Nat) : bshape l [] = some l := by
  unfold bshape
  rw [List.reverse_nil, bcastRevN_nil]
  simp

theorem bshape_row_col {m k : Nat} (hm : m ≠ 1) (hk : k ≠ 1) : bshape [1, m] [k, 1] = some [k, m] := by
  simp [bshape, bcastRevN, hm, Ne.symm hk]

theorem bshape_lead {a b : Nat} : bshape [a, b] [1, 4, a, b] = some [1, 4, a, b] := by
  simp [bshape, bcastRevN]

theorem matmulOut_batched (a k b : Nat) : matmulOut [1, 4, a, k] [1, 4, k, b] = some [1, 4, a, b] := by
  simp [matmulOut, bshape, bcastRevN]

/-- A step's int32 data inputs: `cellsValue` of `vs` at shape `sh` (`vs` the shape's count of cells). -/
theorem cells_ty (vs : List Int) (sh : List Nat) : OkV (cellsValue vs (sh.map Int.ofNat)) fun v => Ty v .int32 sh := by
  unfold cellsValue dataValue
  rw [show Dtype.ofCode Ffi.dtInt32 = some .int32 from rfl, natShape_ofNat]
  exact ⟨_, rfl, rfl, rfl⟩

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} (env : Env κ) (o n : Nat)

/-! ## The KV append -/

theorem kvZeros_shape (o n : Nat) : [li (PDim.eval (refNu o n)) 1, li (PDim.eval (refNu o n)) 4,
    PDim.eval (refNu o n) (PDim.rupF 256 refRows.nP), li (PDim.eval (refNu o n)) 256] =
    [1, 4, 256 * ((n + 255) / 256), 256].map Int.ofNat := by
  rw [refRows_rup]; rfl

theorem ok_kvZeros : OkV (primEvalE P K.toKernelContract env (ksR P K env)
      (.zeros [li (PDim.eval (refNu o n)) 1, li (PDim.eval (refNu o n)) 4,
        PDim.eval (refNu o n) (PDim.rupF 256 refRows.nP), li (PDim.eval (refNu o n)) 256] Ffi.dtBf16) [])
    fun v => Ty v .bfloat16 [1, 4, 256 * ((n + 255) / 256), 256] :=
  ok_zeros P K.toKernelContract env (ksR P K env) _ _ (kvZeros_shape o n) Ffi.dtBf16 .bfloat16 rfl

theorem ok_kvGrowT (cap : Option Nat) (key : κ) (hnone : cap = none → o = 0)
    (hcap : ∀ c, cap = some c → o ≤ c ∧ OkV (env.inputs key) fun v => Ty v .bfloat16 [1, 4, c, 256]) :
    OkV (kvGrowT (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) refRows o n cap key)
      fun v => Ty v .bfloat16 [1, 4, kvCapP cap o n, 256] := by
  cases cap with
  | none =>
    have hk : kvCapP none o n = 256 * ((n + 255) / 256) := rfl
    rw [hk]
    dsimp only [kvGrowT]
    exact ok_kvZeros P K env o n
  | some c =>
    obtain ⟨hoc, hin⟩ := hcap c rfl
    dsimp only [kvGrowT]
    refine OkV.bind hin fun b hb => ?_
    unfold kvGrownT
    by_cases hg : c < o + n
    · rw [ite_eq_left hg]
      have hk : kvCapP (some c) o n = (if o % 256 = 0 then c else o) + 256 * ((n + 255) / 256) := by
        simp [kvCapP, hg]
      refine OkV.bind (Q := fun v => Ty v .bfloat16 [1, 4, if o % 256 = 0 then c else o, 256]) ?_ fun old hold => ?_
      · unfold kvOldT
        by_cases h0 : o % 256 = 0
        · rw [ite_eq_left h0, ite_eq_left h0]; exact OkV.pure hb
        · rw [ite_eq_right h0, ite_eq_right h0]
          exact (ok_slice P K.toKernelContract env (ksR P K env) hb _ _ _ [0, 0, 0, 0] [1, 4, o, 256]
            (by simp [D, PDim.eval]) (by simp [li, PDim.eval, refRows_o]) (by simp [D, unitStrides, PDim.eval])
            (by simp; omega)).mono fun u hu => hu.cast (by simp)
      dsimp only
      refine OkV.bind (ok_kvZeros P K env o n) fun z hz => ?_
      rw [hk]
      exact (ok_concat P K.toKernelContract env (ksR P K env) hold hz 2 (by simp [List.range_succ])).mono
        fun u hu => hu.cast (by simp)
    · rw [ite_eq_right hg]
      have hk : kvCapP (some c) o n = c := by simp [kvCapP, hg]
      rw [hk]
      exact OkV.pure hb

theorem kvCapP_ge (cap : Option Nat) (hnone : cap = none → o = 0) (hcap : ∀ c, cap = some c → o ≤ c) :
    o + n ≤ kvCapP cap o n := by
  cases cap with
  | none => have := hnone rfl; simp [kvCapP]; omega
  | some c =>
    have := hcap c rfl
    simp only [kvCapP]
    split
    · split <;> omega
    · omega

/-- **The KV append** of `n ≥ 1` rows at offset `o`: the buffer at capacity `kvCapP cap o n`, the view
`[1, 4, o + n, 256]`. -/
theorem ok_kvStepT (cap : Option Nat) (key : κ) (hnone : cap = none → o = 0)
    (hcap : ∀ c, cap = some c → o ≤ c ∧ OkV (env.inputs key) fun v => Ty v .bfloat16 [1, 4, c, 256])
    {x : Value} (hx : Ty x .bfloat16 [1, 4, n, 256]) :
    OkV (kvStepT (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) refRows o n cap key x)
      fun r => Ty r.1 .bfloat16 [1, 4, kvCapP cap o n, 256] ∧ Ty r.2 .bfloat16 [1, 4, o + n, 256] := by
  have hge := kvCapP_ge o n cap hnone fun c h => (hcap c h).1
  unfold kvStepT
  refine OkV.bind (ok_kvGrowT P K env o n cap key hnone hcap) fun g hg => ?_
  refine OkV.bind (ok_sliceUpdate P K.toKernelContract env (ksR P K env) hg hx _ _ _ [0, 0, o, 0] [1, 4, o + n, 256]
    (by simp [li, PDim.eval, refRows_o]) (by simp [li, PDim.eval, refRows_on]) (by simp [D, unitStrides, PDim.eval])
    (by simp) (by simp; omega)) fun b hb => ?_
  refine OkV.bind (Q := fun v => Ty v .bfloat16 [1, 4, o + n, 256]) ?_ fun view hview => OkV.pure ⟨hb, hview⟩
  unfold kvViewT
  by_cases he : kvCapP cap o n = o + n
  · rw [ite_eq_left he]; exact OkV.pure (hb.cast (by rw [he]))
  · rw [ite_eq_right he]
    exact (ok_slice P K.toKernelContract env (ksR P K env) hb _ _ _ [0, 0, 0, 0] [1, 4, o + n, 256]
      (by simp [D, PDim.eval]) (by simp [li, PDim.eval, refRows_on]) (by simp [D, unitStrides, PDim.eval])
      (by simp; omega)).mono fun u hu => hu.cast (by simp)

/-! ## The attention read -/

/-- The folded read's host arrays at `r` rows: the key positions `[o + r]` and the key limits `[6r, 1]`. -/
structure FoldedEnv {κ : Type} (env : Env κ) (aux : Nat → κ) (o r : Nat) : Prop where
  cols : OkV (env.inputs (aux 2)) fun v => Ty v .int32 [o + r]
  limits : OkV (env.inputs (aux 1)) fun v => Ty v .int32 [6 * r, 1]

theorem ok_readT (rd : Read) (aux : Nat → κ) (hrd : ∀ r, rd = .folded r → r = n ∧ 6 ≤ n ∧ FoldedEnv env aux o n)
    (h2 : 2 ≤ n) {q keys values : Value} (hq : Ty q .bfloat16 [1, 24, n, 256])
    (hk : Ty keys .bfloat16 [1, 4, o + n, 256]) (hv : Ty values .bfloat16 [1, 4, o + n, 256]) :
    OkV (readT (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) refRows rd aux q keys values)
      fun u => Ty u .bfloat16 [1, 24, n, 256] := by
  cases rd with
  | causal =>
    exact ok_sdpaCausal P K.toKernelContract env (ksR P K env) hq hk hv h2 (by omega)
  | folded r =>
    obtain ⟨rfl, h6, hf⟩ := hrd r rfl
    unfold readT
    refine OkV.bind (ok_data P K.toKernelContract env (ksR P K env) scaleBytes [] [] rfl Ffi.dtBf16 .bfloat16 rfl)
      fun sc hsc => ?_
    refine OkV.bind (ok_mulScalar P K.toKernelContract env (ksR P K env) hq hsc.1 (by simp)) fun qs hqs => ?_
    refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hqs _ [1, 4, 6 * r, 256]
      (by simp [lis, PDim.eval]) (by simp [extent]; ring)) fun rows hrows => ?_
    refine OkV.bind (ok_transpose P K.toKernelContract env (ksR P K env) hk [0, 1, 3, 2] (by simp [List.range_succ])) fun kt hkt => ?_
    have hkt' : Ty kt .bfloat16 [1, 4, 256, o + r] := hkt.cast rfl
    refine OkV.bind (ok_matmul P K.toKernelContract env (ksR P K env) hrows hkt' (matmulOut_batched _ _ _))
      fun scores hscores => ?_
    refine OkV.bind hf.cols fun cols hcols => ?_
    refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hcols _ [1, o + r]
      (by simp [li, PDim.eval, refRows_on]) (by simp [extent])) fun colRow hcolRow => ?_
    refine OkV.bind hf.limits fun lim hlim => ?_
    refine OkV.bind (ok_lessEqual P K.toKernelContract env (ksR P K env) hcolRow hlim
      (bshape_row_col (by omega) (by omega))) fun vis hvis => ?_
    refine OkV.bind (ok_data P K.toKernelContract env (ksR P K env) ninfBytes [] [] rfl Ffi.dtBf16 .bfloat16 rfl)
      fun ninf hninf => ?_
    refine OkV.bind (ok_where P K.toKernelContract env (ksR P K env) hvis hscores hninf.1 bshape_lead (bshape_nil _))
      fun masked hmasked => ?_
    refine OkV.bind (ok_softmax P K.toKernelContract env (ksR P K env) hmasked (by simp) _ rfl) fun probs hprobs => ?_
    refine OkV.bind (ok_matmul P K.toKernelContract env (ksR P K env) hprobs hv (matmulOut_batched _ _ _))
      fun out hout => ?_
    exact ok_reshape P K.toKernelContract env (ksR P K env) hout _ [1, 24, r, 256] (by simp [lis, PDim.eval])
      (by simp [extent]; ring)

end

/-- An attention stage's inputs at the step's environment. -/
structure AttnEnv {κ : Type} (env : Env κ) (key : SKey → κ) (aux : Nat → κ) (a : AttnLayout) (rd : Read) (o n : Nat) :
    Prop where
  inputNorm : OkV (env.inputs (key .inputNorm)) fun v => Ty v .bfloat16 [5120]
  q : LinOk env a.q (key ∘ .lin 0)
  k : LinOk env a.k (key ∘ .lin 1)
  v : LinOk env a.v (key ∘ .lin 2)
  out : LinOk env a.o (key ∘ .lin 3)
  dims : a.q.rows = 12288 ∧ a.q.cols = 5120 ∧ a.k.rows = 1024 ∧ a.k.cols = 5120 ∧ a.v.rows = 1024 ∧
    a.v.cols = 5120 ∧ a.o.rows = 5120 ∧ a.o.cols = 6144
  qNorm : OkV (env.inputs (key .qNorm)) fun v => Ty v .bfloat16 [256]
  kNorm : OkV (env.inputs (key .kNorm)) fun v => Ty v .bfloat16 [256]
  mlp : MlpOk env a.mlp (key ∘ .mlp)
  knone : a.kcap = none → o = 0
  kbuf : ∀ c, a.kcap = some c → o ≤ c ∧ OkV (env.inputs (key (.cache 0))) fun v => Ty v .bfloat16 [1, 4, c, 256]
  vnone : a.vcap = none → o = 0
  vbuf : ∀ c, a.vcap = some c → o ≤ c ∧ OkV (env.inputs (key (.cache 1))) fun v => Ty v .bfloat16 [1, 4, c, 256]
  read : ∀ r, rd = .folded r → r = n ∧ 6 ≤ n ∧ FoldedEnv env aux o n

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} (env : Env κ) (o n : Nat)

theorem rope_base : (GlueAttention.optionalFloat ropeBaseWord).isSome := by
  rw [show ropeBaseWord = 0x4b189680 + 2 ^ 32 from rfl, GlueAttention.base_word]; rfl

/-- **An attention layer** of a GPU row family on `n` rows at offset `o` (`2 ≤ n`). -/
theorem ok_attentionLayerT (proj : LinLayout → (LinKey → κ) → Value → Option Value)
    (mlp : MlpLayout → (MlpKey → κ) → Value → Option Value)
    (hproj : ∀ lay key x, LinOk env lay key → Ty x .bfloat16 [1, n, lay.cols] →
      OkV (proj lay key x) fun u => Ty u .bfloat16 [1, n, lay.rows])
    (hmlp : ∀ mlay key x, MlpOk env mlay key → Ty x .bfloat16 [1, n, 5120] →
      OkV (mlp mlay key x) fun u => Ty u .bfloat16 [1, n, 5120])
    (rd : Read) (a : AttnLayout) (key : SKey → κ) (aux : Nat → κ) (he : AttnEnv env key aux a rd o n)
    (h2 : 2 ≤ n) {x : Value} (hx : Ty x .bfloat16 [1, n, 5120]) :
    OkV (attentionLayerT (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) proj mlp refRows o n
      rd a key aux x)
      fun r => Ty r.1 .bfloat16 [1, n, 5120] ∧ Ty r.2.1 .bfloat16 [1, 4, kvCapP a.kcap o n, 256] ∧
        Ty r.2.2 .bfloat16 [1, 4, kvCapP a.vcap o n, 256] := by
  obtain ⟨d1, d2, d3, d4, d5, d6, d7, d8⟩ := he.dims
  unfold attentionLayerT
  refine OkV.bind (ok_normT P K env (key .inputNorm) hx he.inputNorm rfl (Or.inl rfl)) fun xn hxn => ?_
  refine OkV.bind (hproj _ _ xn he.q (hxn.cast (by rw [d2]))) fun qp hqp => ?_
  rw [d1] at hqp
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hqp _ [1, n, 24, 512]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun qpr hqpr => ?_
  refine OkV.bind (ok_slice P K.toKernelContract env (ksR P K env) hqpr _ _ _ [0, 0, 0, 0] [1, n, 24, 256]
    (by simp [lis, PDim.eval]) (by simp [li, PDim.eval, refRows_n]) (by simp [lis, unitStrides, PDim.eval])
    (by simp)) fun qh hqh => ?_
  have hqh' : Ty qh .bfloat16 [1, n, 24, 256] := hqh.cast (by simp)
  refine OkV.bind (ok_slice P K.toKernelContract env (ksR P K env) hqpr _ _ _ [0, 0, 0, 256] [1, n, 24, 512]
    (by simp [lis, PDim.eval]) (by simp [li, PDim.eval, refRows_n]) (by simp [lis, unitStrides, PDim.eval])
    (by simp)) fun gh hgh => ?_
  have hgh' : Ty gh .bfloat16 [1, n, 24, 256] := hgh.cast (by simp)
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hgh' _ [1, n, 6144]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun gate hgate => ?_
  refine OkV.bind (hproj _ _ xn he.k (hxn.cast (by rw [d4]))) fun kp hkp => ?_
  rw [d3] at hkp
  refine OkV.bind (hproj _ _ xn he.v (hxn.cast (by rw [d6]))) fun vp hvp => ?_
  rw [d5] at hvp
  refine OkV.bind (ok_normT P K env (key .qNorm) hqh' he.qNorm rfl (Or.inr (Or.inl rfl))) fun qn hqn => ?_
  refine OkV.bind (ok_transpose P K.toKernelContract env (ksR P K env) hqn [0, 2, 1, 3] (by simp [List.range_succ]))
    fun qt hqt => ?_
  have hqt' : Ty qt .bfloat16 [1, 24, n, 256] := hqt.cast (by simp)
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hkp _ [1, n, 4, 256]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun kr hkr => ?_
  refine OkV.bind (ok_normT P K env (key .kNorm) hkr he.kNorm rfl (Or.inr (Or.inl rfl))) fun kn hkn => ?_
  refine OkV.bind (ok_transpose P K.toKernelContract env (ksR P K env) hkn [0, 2, 1, 3] (by simp [List.range_succ]))
    fun kt hkt => ?_
  have hkt' : Ty kt .bfloat16 [1, 4, n, 256] := hkt.cast (by simp)
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hvp _ [1, n, 4, 256]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun vr hvr => ?_
  refine OkV.bind (ok_transpose P K.toKernelContract env (ksR P K env) hvr [0, 2, 1, 3] (by simp [List.range_succ]))
    fun vt hvt => ?_
  have hvt' : Ty vt .bfloat16 [1, 4, n, 256] := hvt.cast (by simp)
  have hoff : 0 ≤ PDim.eval (refNu o n) refRows.oP := by rw [refRows_o]; omega
  refine OkV.bind (ok_rope P K.toKernelContract env (ksR P K env) ropeBaseWord ropeScaleWord _ hqt' rfl (by simp; omega)
    rfl hoff rope_base) fun qr hqr => ?_
  refine OkV.bind (ok_rope P K.toKernelContract env (ksR P K env) ropeBaseWord ropeScaleWord _ hkt' rfl (by simp; omega)
    rfl hoff rope_base) fun kq hkq => ?_
  refine OkV.bind (ok_kvStepT P K env o n a.kcap (key (.cache 0)) he.knone he.kbuf hkq) fun r1 hr1 => ?_
  obtain ⟨kb, keys⟩ := r1
  dsimp only
  refine OkV.bind (ok_kvStepT P K env o n a.vcap (key (.cache 1)) he.vnone he.vbuf hvt') fun r2 hr2 => ?_
  obtain ⟨vb, values⟩ := r2
  dsimp only
  refine OkV.bind (ok_readT P K env o n rd aux he.read h2 hqr hr1.2 hr2.2) fun attn hattn => ?_
  refine OkV.bind (ok_transpose P K.toKernelContract env (ksR P K env) hattn [0, 2, 1, 3] (by simp [List.range_succ]))
    fun attnT hattnT => ?_
  refine OkV.bind (ok_reshapeInfer P K.toKernelContract env (ksR P K env) (n := n) (m := 6144) hattnT (by omega)
    (by simp [extent]) _ (by simp [li, PDim.eval, refRows_n])) fun merged hmerged => ?_
  refine OkV.bind (ok_sigmoid P K.toKernelContract env (ksR P K env) hgate) fun sig hsig => ?_
  refine OkV.bind (ok_multiply P K.toKernelContract env (ksR P K env) hmerged hsig) fun gated hgated => ?_
  refine OkV.bind (hproj _ _ gated he.out (hgated.cast (by rw [d8]))) fun mixed hmixed => ?_
  rw [d7] at hmixed
  refine OkV.bind (ok_add P K.toKernelContract env (ksR P K env) hx hmixed) fun h hh => ?_
  refine OkV.bind (ok_normT P K env (key (.mlp .norm)) hh he.mlp.norm rfl (Or.inl rfl)) fun hn hhn => ?_
  refine OkV.bind (hmlp _ _ hn he.mlp hhn) fun mo hmo => ?_
  refine OkV.bind (ok_add P K.toKernelContract env (ksR P K env) hh hmo) fun out hout => ?_
  exact OkV.pure ⟨hout, hr1.1, hr2.1⟩

end

end Host.Mlx.SimGraph.Mach

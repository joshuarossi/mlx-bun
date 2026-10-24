import host.simgraph.mach.PreAne
namespace Host.Mlx.SimGraph.Mach
open Inference Inference.Contracts.Mlx Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Mlx.SimGraph.Ref (refRows refNu refRows_o refRows_n)

/-! # A Neural Engine forward's layers are defined on well-typed inputs

`aneDeltaLayerT`, `aneAttentionLayerT` at the value backend: the layers of `deltaLayerT`, `attentionLayerT` with a
projection per site and the MLP split, for projection and MLP templates defined on typed inputs, their taps
satisfying the sites' predicates (`PT j`, `MT`), collected in call order. -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} (env : Env κ)
  (o n : Nat)

/-- **A gated-delta layer of a Neural Engine forward** (`2 ≤ n ≤ 2048`). -/
theorem ok_aneDeltaLayerT (proj : Nat → LinLayout → Value → Option (Value × Value × Value))
    (mlp : MlpLayout → Value → Option (Value × Value)) (PT : Nat → Value × Value × Value → Prop)
    (MT : Value × Value → Prop) (d : DeltaLayout) (key : SKey → κ) (aux : Nat → κ) (he : DeltaEnv env key aux d n)
    (hproj : ∀ j lay x, Ty x .bfloat16 [1, n, lay.cols] →
      (j = 0 ∧ lay = d.qkv) ∨ (j = 1 ∧ lay = d.z) ∨ (j = 2 ∧ lay = d.a) ∨ (j = 3 ∧ lay = d.b) ∨ (j = 4 ∧ lay = d.out) →
      OkV (proj j lay x) fun r => Ty r.1 .bfloat16 [1, n, lay.rows] ∧ PT j r)
    (hmlp : ∀ x, Ty x .bfloat16 [1, n, 5120] → OkV (mlp d.mlp x) fun r => Ty r.1 .bfloat16 [1, n, 5120] ∧ MT r)
    (h2 : 2 ≤ n) (h2048 : n ≤ 2048) {x : Value} (hx : Ty x .bfloat16 [1, n, 5120]) :
    OkV (aneDeltaLayerT (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) proj mlp refRows d key
        aux x)
      fun r => (Ty r.1.1 .bfloat16 [1, n, 5120] ∧ Ty r.1.2.1 .bfloat16 [1, 3, 10240] ∧
        Ty r.1.2.2 .float32 [1, 48, 128, 128]) ∧
        ∃ rq rz rb ra ro rm, r.2 = [[rq.2.1, rq.2.2], [rz.2.1, rz.2.2], [rb.2.1, rb.2.2], [ra.2.1, ra.2.2],
          [ro.2.1, ro.2.2], [rm.2]] ∧ PT 0 rq ∧ PT 1 rz ∧ PT 3 rb ∧ PT 2 ra ∧ PT 4 ro ∧ MT rm := by
  obtain ⟨d1, d2, d3, d4, d5, d6, d7, d8, d9, d10⟩ := he.dims
  unfold aneDeltaLayerT
  refine OkV.bind (ok_normT P K env (key .inputNorm) hx he.inputNorm rfl (Or.inl rfl)) fun xn hxn => ?_
  refine OkV.bind (hproj 0 d.qkv xn (hxn.cast (by rw [d2])) (.inl ⟨rfl, rfl⟩)) fun rq hrq => ?_
  have hqkv := hrq.1.cast (by rw [d1])
  refine OkV.bind (hproj 1 d.z xn (hxn.cast (by rw [d4])) (.inr (.inl ⟨rfl, rfl⟩))) fun rz hrz => ?_
  have hz0 := hrz.1.cast (by rw [d3])
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hz0 _ [1, n, 48, 128]
    (by simp [li, PDim.eval, refRows_n]) (by simp only [extent, List.foldr])) fun z hz => ?_
  refine OkV.bind (hproj 3 d.b xn (hxn.cast (by rw [d8])) (.inr (.inr (.inr (.inl ⟨rfl, rfl⟩))))) fun rb hrb => ?_
  have hbv := hrb.1.cast (by rw [d7])
  refine OkV.bind (hproj 2 d.a xn (hxn.cast (by rw [d6])) (.inr (.inr (.inl ⟨rfl, rfl⟩)))) fun ra hra => ?_
  have hav := hra.1.cast (by rw [d5])
  refine OkV.bind (ok_optInpT P K env d.hasConv (key (.cache 0)) _ [1, 3, 10240] (by simp [lis, PDim.eval])
    Ffi.dtBf16 .bfloat16 rfl he.cache0) fun conv hconv => ?_
  refine OkV.bind (ok_concat P K.toKernelContract env (ksR P K env) hconv hqkv 1 (by simp [List.range_succ]))
    fun joined hj => ?_
  have hj' : Ty joined .bfloat16 [1, n + 3, 10240] := hj.cast (by simp; omega)
  refine OkV.bind (ok_slice P K.toKernelContract env (ksR P K env) hj' _ _ _ [0, n, 0] [1, n + 3, 10240]
    (by simp [li, PDim.eval, refRows_n]) (by simp [li, PDim.eval, refRows_n3]) (by simp [lis, unitStrides, PDim.eval])
    (by simp)) fun view hview => ?_
  have hview' : Ty view .bfloat16 [1, 3, 10240] := hview.cast (by simp)
  refine OkV.bind (ok_data P K.toKernelContract env (ksR P K env) [0, 0, 0, 0] [] [] rfl Ffi.dtInt32 .int32 rfl)
    fun zi hzi => ?_
  refine OkV.bind (ok_sliceDynamic P K.toKernelContract env (ksR P K env) hview' hzi.1 (by rw [hzi.2]; rfl) _
    (by simp [lis, PDim.eval])) fun tail htail => ?_
  refine OkV.bind he.conv fun cw hcw => ?_
  refine OkV.bind (ok_conv1d P K.toKernelContract env (ksR P K env) hj' hcw h2) fun c hc => ?_
  refine OkV.bind (ok_silu P K.toKernelContract env (ksR P K env) hc) fun cs hcs => ?_
  refine OkV.bind (ok_slice P K.toKernelContract env (ksR P K env) hcs _ _ _ [0, 0, 0] [1, n, 2048]
    (by simp [lis, PDim.eval]) (by simp [li, PDim.eval, refRows_n]) (by simp [lis, unitStrides, PDim.eval])
    (by simp)) fun qf hqf => ?_
  refine OkV.bind (ok_slice P K.toKernelContract env (ksR P K env) hcs _ _ _ [0, 0, 2048] [1, n, 4096]
    (by simp [lis, PDim.eval]) (by simp [li, PDim.eval, refRows_n]) (by simp [lis, unitStrides, PDim.eval])
    (by simp)) fun kf hkf => ?_
  refine OkV.bind (ok_slice P K.toKernelContract env (ksR P K env) hcs _ _ _ [0, 0, 4096] [1, n, 10240]
    (by simp [lis, PDim.eval]) (by simp [li, PDim.eval, refRows_n]) (by simp [lis, unitStrides, PDim.eval])
    (by simp)) fun vf hvf => ?_
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hqf _ [1, n, 16, 128]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun q0 hq0 => ?_
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hkf _ [1, n, 16, 128]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun k0 hk0 => ?_
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hvf _ [1, n, 48, 128]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun v hv => ?_
  refine OkV.bind (ok_normT P K env (key .qScale) hq0 he.qScale rfl (Or.inr (Or.inr rfl))) fun q hq => ?_
  refine OkV.bind (ok_normT P K env (key .kScale) hk0 he.kScale rfl (Or.inr (Or.inr rfl))) fun k hk => ?_
  refine OkV.bind (ok_sigmoid P K.toKernelContract env (ksR P K env) hbv) fun beta hbeta => ?_
  refine OkV.bind he.aLog fun al hal => ?_
  refine OkV.bind he.dtBias fun dt hdt => ?_
  refine OkV.bind (ok_computeG P K.toKernelContract env (ksR P K env) hal hav hdt h2) fun g hg => ?_
  refine OkV.bind (ok_optInpT P K env d.hasRec (key (.cache 1)) _ [1, 48, 128, 128] (by simp [lis, PDim.eval])
    Ffi.dtF32 .float32 rfl he.cache1) fun st0 hst0 => ?_
  refine OkV.bind (⟨_, he.tin, rfl⟩ : OkV (env.inputs (aux 0)) (· = tinValue n)) fun t ht => ?_
  subst ht
  refine OkV.bind ((ok_gatedKernel P K env (refNu o n) refRows n (refRows_n o n) 0 (Or.inl rfl) h2 h2048 hq hk hv hg
    hbeta hst0).mono fun u hu => (by simpa using hu : Ty u .bfloat16 [1, n, 48, 128])) fun y hy => ?_
  refine OkV.bind ((ok_gatedKernel P K env (refNu o n) refRows n (refRows_n o n) 1 (Or.inr rfl) h2 h2048 hq hk hv hg
    hbeta hst0).mono fun u hu => (by simpa using hu : Ty u .float32 [1, 48, 128, 128])) fun s hs => ?_
  refine OkV.bind (ok_normT P K env (key .norm) hy he.norm rfl (Or.inr (Or.inr rfl))) fun yn hyn => ?_
  refine OkV.bind (ok_preciseSwiglu P K.toKernelContract env (ksR P K env) hz hyn) fun gated hgated => ?_
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hgated _ [1, n, 6144]
    (by simp [li, PDim.eval, refRows_n]) (by simp only [extent, List.foldr])) fun merged hmerged => ?_
  refine OkV.bind (hproj 4 d.out merged (hmerged.cast (by rw [d10])) (.inr (.inr (.inr (.inr ⟨rfl, rfl⟩)))))
    fun ro hro => ?_
  have hmixed := hro.1.cast (by rw [d9])
  refine OkV.bind (ok_add P K.toKernelContract env (ksR P K env) hx hmixed) fun h hh => ?_
  refine OkV.bind (ok_normT P K env (key (.mlp .norm)) hh he.mlp.norm rfl (Or.inl rfl)) fun hn hhn => ?_
  refine OkV.bind (hmlp hn hhn) fun rm hrm => ?_
  refine OkV.bind (ok_add P K.toKernelContract env (ksR P K env) hh hrm.1) fun out hout => ?_
  exact OkV.pure ⟨⟨hout, htail, hs⟩, rq, rz, rb, ra, ro, rm, rfl, hrq.2, hrz.2, hrb.2, hra.2, hro.2, hrm.2⟩

/-- **An attention layer of a Neural Engine forward** (the causal read, `2 ≤ n`). -/
theorem ok_aneAttentionLayerT (proj : Nat → LinLayout → Value → Option (Value × Value × Value))
    (mlp : MlpLayout → Value → Option (Value × Value)) (PT : Nat → Value × Value × Value → Prop)
    (MT : Value × Value → Prop) (a : AttnLayout) (key : SKey → κ) (aux : Nat → κ) (he : AttnEnv env key aux a .causal o n)
    (hproj : ∀ j lay x, Ty x .bfloat16 [1, n, lay.cols] →
      (j = 0 ∧ lay = a.q) ∨ (j = 1 ∧ lay = a.k) ∨ (j = 2 ∧ lay = a.v) ∨ (j = 3 ∧ lay = a.o) →
      OkV (proj j lay x) fun r => Ty r.1 .bfloat16 [1, n, lay.rows] ∧ PT j r)
    (hmlp : ∀ x, Ty x .bfloat16 [1, n, 5120] → OkV (mlp a.mlp x) fun r => Ty r.1 .bfloat16 [1, n, 5120] ∧ MT r)
    (h2 : 2 ≤ n) {x : Value} (hx : Ty x .bfloat16 [1, n, 5120]) :
    OkV (aneAttentionLayerT (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) proj mlp refRows o n
        a key aux x)
      fun r => (Ty r.1.1 .bfloat16 [1, n, 5120] ∧ Ty r.1.2.1 .bfloat16 [1, 4, kvCapP a.kcap o n, 256] ∧
        Ty r.1.2.2 .bfloat16 [1, 4, kvCapP a.vcap o n, 256]) ∧
        ∃ rq rk rv ro rm, r.2 = [[rq.2.1, rq.2.2], [rk.2.1, rk.2.2], [rv.2.1, rv.2.2], [ro.2.1, ro.2.2], [rm.2]] ∧
          PT 0 rq ∧ PT 1 rk ∧ PT 2 rv ∧ PT 3 ro ∧ MT rm := by
  obtain ⟨d1, d2, d3, d4, d5, d6, d7, d8⟩ := he.dims
  unfold aneAttentionLayerT
  refine OkV.bind (ok_normT P K env (key .inputNorm) hx he.inputNorm rfl (Or.inl rfl)) fun xn hxn => ?_
  refine OkV.bind (hproj 0 a.q xn (hxn.cast (by rw [d2])) (.inl ⟨rfl, rfl⟩)) fun rq hrq => ?_
  have hqp := hrq.1.cast (by rw [d1])
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
  refine OkV.bind (hproj 1 a.k xn (hxn.cast (by rw [d4])) (.inr (.inl ⟨rfl, rfl⟩))) fun rk hrk => ?_
  have hkp := hrk.1.cast (by rw [d3])
  refine OkV.bind (hproj 2 a.v xn (hxn.cast (by rw [d6])) (.inr (.inr (.inl ⟨rfl, rfl⟩)))) fun rv hrv => ?_
  have hvp := hrv.1.cast (by rw [d5])
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
  refine OkV.bind (ok_readT P K env o n .causal aux he.read h2 hqr hr1.2 hr2.2) fun attn hattn => ?_
  refine OkV.bind (ok_transpose P K.toKernelContract env (ksR P K env) hattn [0, 2, 1, 3] (by simp [List.range_succ]))
    fun attnT hattnT => ?_
  refine OkV.bind (ok_reshapeInfer P K.toKernelContract env (ksR P K env) (n := n) (m := 6144) hattnT (by omega)
    (by simp [extent]) _ (by simp [li, PDim.eval, refRows_n])) fun merged hmerged => ?_
  refine OkV.bind (ok_sigmoid P K.toKernelContract env (ksR P K env) hgate) fun sig hsig => ?_
  refine OkV.bind (ok_multiply P K.toKernelContract env (ksR P K env) hmerged hsig) fun gated hgated => ?_
  refine OkV.bind (hproj 3 a.o gated (hgated.cast (by rw [d8])) (.inr (.inr (.inr ⟨rfl, rfl⟩)))) fun ro hro => ?_
  have hmixed := hro.1.cast (by rw [d7])
  refine OkV.bind (ok_add P K.toKernelContract env (ksR P K env) hx hmixed) fun h hh => ?_
  refine OkV.bind (ok_normT P K env (key (.mlp .norm)) hh he.mlp.norm rfl (Or.inl rfl)) fun hn hhn => ?_
  refine OkV.bind (hmlp hn hhn) fun rm hrm => ?_
  refine OkV.bind (ok_add P K.toKernelContract env (ksR P K env) hh hrm.1) fun out hout => ?_
  exact OkV.pure ⟨⟨hout, hr1.1, hr2.1⟩, rq, rk, rv, ro, rm, rfl, hrq.2, hrk.2, hrv.2, hro.2, hrm.2⟩

end

end Host.Mlx.SimGraph.Mach

import host.simgraph.mach.PreLayer
namespace Host.Mlx.SimGraph.Mach
open Inference Inference.Contracts.Mlx Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Mlx.SimGraph.Ref (refRows refNu refRows_o refRows_n)

/-! # A gated-delta layer of a GPU row family is defined on well-typed inputs

`deltaLayerT` at the value backend, at the step's canonical rows: from a hidden state `[1, n, 5120]` and the
stage's inputs typed (`DeltaEnv`: weights, the caches when the layout has them, `Tin`), the output, the new
conv tail `[1, 3, 10240]` and the recurrent state `[1, 48, 128, 128]`, for any projection and MLP templates
that are themselves defined on typed inputs. -/

theorem Ty.cast {v : Value} {d : Dtype} {sh sh' : List Nat} (h : Ty v d sh) (e : sh = sh') : Ty v d sh' := e ▸ h

/-- A gated-delta stage's inputs at the step's environment. -/
structure DeltaEnv {κ : Type} (env : Env κ) (key : SKey → κ) (aux : Nat → κ) (d : DeltaLayout) (n : Nat) : Prop where
  inputNorm : OkV (env.inputs (key .inputNorm)) fun v => Ty v .bfloat16 [5120]
  qkv : LinOk env d.qkv (key ∘ .lin 0)
  z : LinOk env d.z (key ∘ .lin 1)
  a : LinOk env d.a (key ∘ .lin 2)
  b : LinOk env d.b (key ∘ .lin 3)
  out : LinOk env d.out (key ∘ .lin 4)
  dims : d.qkv.rows = 10240 ∧ d.qkv.cols = 5120 ∧ d.z.rows = 6144 ∧ d.z.cols = 5120 ∧ d.a.rows = 48 ∧
    d.a.cols = 5120 ∧ d.b.rows = 48 ∧ d.b.cols = 5120 ∧ d.out.rows = 5120 ∧ d.out.cols = 6144
  conv : OkV (env.inputs (key .conv)) fun v => Ty v .bfloat16 [10240, 4, 1]
  aLog : OkV (env.inputs (key .aLog)) fun v => Ty v .bfloat16 [48]
  dtBias : OkV (env.inputs (key .dtBias)) fun v => Ty v .bfloat16 [48]
  norm : OkV (env.inputs (key .norm)) fun v => Ty v .bfloat16 [128]
  qScale : OkV (env.inputs (key .qScale)) fun v => Ty v .bfloat16 [128]
  kScale : OkV (env.inputs (key .kScale)) fun v => Ty v .bfloat16 [128]
  mlp : MlpOk env d.mlp (key ∘ .mlp)
  cache0 : d.hasConv = true → OkV (env.inputs (key (.cache 0))) fun v => Ty v .bfloat16 [1, 3, 10240]
  cache1 : d.hasRec = true → OkV (env.inputs (key (.cache 1))) fun v => Ty v .float32 [1, 48, 128, 128]
  tin : env.inputs (aux 0) = some (tinValue n)

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} (env : Env κ) (o n : Nat)

theorem ok_optInpT (b : Bool) (key : κ) (shape : List Int) (sh : List Nat) (hs : shape = sh.map Int.ofNat)
    (code : Nat) (d : Dtype) (hd : Dtype.ofCode code = some d) (hin : b = true → OkV (env.inputs key) fun v => Ty v d sh) :
    OkV (optInpT (valueB P K.toKernelContract env (ksR P K env)) b key (.zeros shape code)) fun v => Ty v d sh := by
  cases b
  · exact ok_zeros P K.toKernelContract env (ksR P K env) shape sh hs code d hd
  · exact hin rfl

/-- **A gated-delta layer** of a GPU row family on `n` rows (`2 ≤ n ≤ 2048`). -/
theorem ok_deltaLayerT (proj : LinLayout → (LinKey → κ) → Value → Option Value)
    (mlp : MlpLayout → (MlpKey → κ) → Value → Option Value)
    (hproj : ∀ lay key x, LinOk env lay key → Ty x .bfloat16 [1, n, lay.cols] →
      OkV (proj lay key x) fun u => Ty u .bfloat16 [1, n, lay.rows])
    (hmlp : ∀ mlay key x, MlpOk env mlay key → Ty x .bfloat16 [1, n, 5120] →
      OkV (mlp mlay key x) fun u => Ty u .bfloat16 [1, n, 5120])
    (d : DeltaLayout) (key : SKey → κ) (aux : Nat → κ) (he : DeltaEnv env key aux d n) (h2 : 2 ≤ n)
    (h2048 : n ≤ 2048) {x : Value} (hx : Ty x .bfloat16 [1, n, 5120]) :
    OkV (deltaLayerT (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) proj mlp refRows d key aux x)
      fun r => Ty r.1 .bfloat16 [1, n, 5120] ∧ Ty r.2.1 .bfloat16 [1, 3, 10240] ∧
        Ty r.2.2 .float32 [1, 48, 128, 128] := by
  obtain ⟨d1, d2, d3, d4, d5, d6, d7, d8, d9, d10⟩ := he.dims
  unfold deltaLayerT
  refine OkV.bind (ok_normT P K env (key .inputNorm) hx he.inputNorm rfl (Or.inl rfl)) fun xn hxn => ?_
  refine OkV.bind (hproj _ _ xn he.qkv (hxn.cast (by rw [d2]))) fun qkv hqkv => ?_
  rw [d1] at hqkv
  refine OkV.bind (hproj _ _ xn he.z (hxn.cast (by rw [d4]))) fun z0 hz0 => ?_
  rw [d3] at hz0
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hz0 _ [1, n, 48, 128]
    (by simp [li, PDim.eval, refRows_n]) (by simp only [extent, List.foldr])) fun z hz => ?_
  refine OkV.bind (hproj _ _ xn he.b (hxn.cast (by rw [d8]))) fun bv hbv => ?_
  rw [d7] at hbv
  refine OkV.bind (hproj _ _ xn he.a (hxn.cast (by rw [d6]))) fun av hav => ?_
  rw [d5] at hav
  refine OkV.bind (ok_optInpT P K env d.hasConv (key (.cache 0)) _ [1, 3, 10240] (by simp [lis, PDim.eval])
    Ffi.dtBf16 .bfloat16 rfl he.cache0) fun conv hconv => ?_
  refine OkV.bind (ok_concat P K.toKernelContract env (ksR P K env) hconv hqkv 1 (by simp [List.range_succ])) fun joined hj => ?_
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
  refine OkV.bind (hproj _ _ merged he.out (hmerged.cast (by rw [d10]))) fun mixed hmixed => ?_
  rw [d9] at hmixed
  refine OkV.bind (ok_add P K.toKernelContract env (ksR P K env) hx hmixed) fun h hh => ?_
  refine OkV.bind (ok_normT P K env (key (.mlp .norm)) hh he.mlp.norm rfl (Or.inl rfl)) fun hn hhn => ?_
  refine OkV.bind (hmlp _ _ hn he.mlp hhn) fun mo hmo => ?_
  refine OkV.bind (ok_add P K.toKernelContract env (ksR P K env) hh hmo) fun out hout => ?_
  exact OkV.pure ⟨hout, htail, hs⟩

end

end Host.Mlx.SimGraph.Mach

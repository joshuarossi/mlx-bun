import host.simgraph.mach.PreRow
import host.simgraph.family.AneFamilies
namespace Host.Mlx.SimGraph.Mach
open Inference Inference.Contracts.Mlx Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Mlx.SimGraph.Ref (refRows refNu refRows_o refRows_n)
open Host.Mlx.PrefillSources (PrefillKernel)

/-! # The Neural Engine forwards' projections and MLP splits are defined on well-typed inputs

The GPU side of a Neural Engine forward at the value backend: the dense projection (dequantize, transpose,
matmul), the plain projection (`quantized_matmul` at 4 bits), the affine split (the head rows' flattened
dequantized weights and the flattened input as taps, the readback concatenated with the rest rows' dense
projection), and the MLP split (the rest rows' vector expansions, matmuls and SwiGLU, the readback added),
from weights typed at their rows (`LinW`, `MlpRestW`) and a readback of its geometry. -/

/-- A projection's weights at `key`: `rows` rows of `cols` inputs at `bits`. -/
structure LinW {κ : Type} (env : Env κ) (bits rows cols : Nat) (key : LinKey → κ) : Prop where
  w : OkV (env.inputs (key .w)) fun v => Ty v .uint32 [rows, cols * bits / 32]
  scales : OkV (env.inputs (key .scales)) fun v => Ty v .bfloat16 [rows, cols / 64]
  biases : OkV (env.inputs (key .biases)) fun v => Ty v .bfloat16 [rows, cols / 64]

theorem LinOk.linW {κ : Type} {env : Env κ} {lay : LinLayout} {key : LinKey → κ} (h : LinOk env lay key) :
    LinW env lay.bits lay.rows lay.cols key := ⟨h.w, h.scales, h.biases⟩

/-- An MLP split's GPU rows at `key`: `rest` rows' codes and scales for the vector expansions. -/
structure MlpRestW {κ : Type} (env : Env κ) (mlay : MlpLayout) (rest : Nat) (key : MlpKey → κ) : Prop where
  restRows : rest = 11264 ∨ rest = 10752
  gateBits : mlay.gateBits = 2 ∨ mlay.gateBits = 3 ∨ mlay.gateBits = 4
  upBits : mlay.upBits = 2 ∨ mlay.upBits = 3 ∨ mlay.upBits = 4
  downBits : mlay.downBits = 2 ∨ mlay.downBits = 3 ∨ mlay.downBits = 4
  gateCodes : OkV (env.inputs (key .gateCodes)) fun v => Ty v .uint32 [rest, 160 * mlay.gateBits]
  gateScales : OkV (env.inputs (key .gateScales)) fun v => Ty v .float16 [rest]
  upCodes : OkV (env.inputs (key .upCodes)) fun v => Ty v .uint32 [rest, 160 * mlay.upBits]
  upScales : OkV (env.inputs (key .upScales)) fun v => Ty v .float16 [rest]
  downCodes : OkV (env.inputs (key .downCodes)) fun v =>
    Ty v .uint32 (expandCodes rest mlay.downBits (if mlay.downBits = 3 then 2 else 0))
  downScales : OkV (env.inputs (key .downScales)) fun v => Ty v .float16 [rest]

theorem matmulOut_proj (n C R : Nat) : matmulOut [1, n, C] [C, R] = some [1, n, R] := by
  simp [matmulOut]

theorem matmulOut_mat (n C R : Nat) : matmulOut [n, C] [C, R] = some [n, R] := by
  simp [matmulOut, bshape, bcastRevN]

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} (env : Env κ)
  (o n : Nat)

theorem dq_cols (bits cols : Nat) (hb : bits = 3 ∨ bits = 4) (hc : cols = 5120 ∨ cols = 6144) :
    cols * bits / 32 * 32 / bits = cols ∧ cols * bits / 32 * 32 / bits / 64 = cols / 64 ∧ 0 < cols * bits / 32 ∧
      (bits = 3 → cols * bits / 32 % 3 = 0) ∧ cols * bits / 32 * 32 / bits % 64 = 0 := by
  rcases hb with rfl | rfl <;> rcases hc with rfl | rfl <;> decide

/-- `DequantizedMatmulLinear` on `x` `[1, n, cols]`. -/
theorem ok_denseProjT (lay : LinLayout) (key : LinKey → κ) {rows cols : Nat} (hw : LinW env lay.bits rows cols key)
    (hbits : lay.bits = 3 ∨ lay.bits = 4) (hc : cols = 5120 ∨ cols = 6144) {x : Value}
    (hx : Ty x .bfloat16 [1, n, cols]) :
    OkV (denseProjT (valueB P K.toKernelContract env (ksR P K env)) lay key x) fun u => Ty u .bfloat16 [1, n, rows] := by
  obtain ⟨e1, e2, e3, e4, e5⟩ := dq_cols lay.bits cols hbits hc
  unfold denseProjT
  refine OkV.bind hw.w fun w hw' => ?_
  refine OkV.bind hw.scales fun s hs => ?_
  refine OkV.bind hw.biases fun b hb => ?_
  refine OkV.bind (ok_dequantize2 P K.toKernelContract env (ksR P K env) lay.bits hbits hw' (hs.cast (by rw [e2]))
    (hb.cast (by rw [e2])) e3 e4 e5) fun dq hdq => ?_
  rw [e1] at hdq
  refine OkV.bind (ok_transpose P K.toKernelContract env (ksR P K env) hdq [1, 0] (by simp [List.range_succ])) fun wt hwt => ?_
  exact ok_matmul P K.toKernelContract env (ksR P K env) hx (hwt.cast rfl) (matmulOut_proj n cols rows)

/-- `QuantizedLinearPlain` on `x` `[1, n, cols]` at 4 bits, `n ≥ 2`. -/
theorem ok_plainProjT (lay : LinLayout) (key : LinKey → κ) {rows cols : Nat} (hw : LinW env 4 rows cols key)
    (hl : lay.bits = 4) (hc : cols % 512 = 0) (hn : 2 ≤ n) {x : Value} (hx : Ty x .bfloat16 [1, n, cols]) :
    OkV (plainProjT (valueB P K.toKernelContract env (ksR P K env)) lay key x) fun u => Ty u .bfloat16 [1, n, rows] := by
  unfold plainProjT
  refine OkV.bind hw.w fun w hw' => ?_
  refine OkV.bind hw.scales fun s hs => ?_
  refine OkV.bind hw.biases fun b hb => ?_
  rw [hl]
  exact ok_qmm P K.toKernelContract env (ksR P K env) hx (hw'.cast (by rw [show cols * 4 / 32 = cols / 8 by omega]))
    hs.2 hb.2 hn hc

/-- `AneAffineSplit.forward` with `nA` Neural Engine rows: the head rows' weights `head`, the rest rows' `rest`, the
readback `out` (`[n, nA]`); the taps the flattened head rows `[nA·cols]` and the flattened input `[cols·n]`. -/
theorem ok_aneSplitProjT (lay : LinLayout) (nA : Nat) (head rest : LinKey → κ) (out : κ)
    (hbits : lay.bits = 3 ∨ lay.bits = 4) (hc : lay.cols = 5120 ∨ lay.cols = 6144) (hnA : nA ≤ lay.rows)
    (hhead : LinW env lay.bits nA lay.cols head) (hrest : LinW env lay.bits (lay.rows - nA) lay.cols rest)
    (hout : OkV (env.inputs out) fun v => Ty v .bfloat16 [n, nA]) {x : Value}
    (hx : Ty x .bfloat16 [1, n, lay.cols]) :
    OkV (aneSplitProjT (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) refRows lay nA head rest
        out x)
      fun r => Ty r.1 .bfloat16 [1, n, lay.rows] ∧ Ty r.2.1 .bfloat16 [nA * lay.cols] ∧
        Ty r.2.2 .bfloat16 [lay.cols * n] := by
  obtain ⟨e1, e2, e3, e4, e5⟩ := dq_cols lay.bits lay.cols hbits hc
  unfold aneSplitProjT
  refine OkV.bind hhead.w fun hw hw' => ?_
  refine OkV.bind hhead.scales fun hs hs' => ?_
  refine OkV.bind hhead.biases fun hb hb' => ?_
  refine OkV.bind (ok_dequantize2 P K.toKernelContract env (ksR P K env) lay.bits hbits hw' (hs'.cast (by rw [e2]))
    (hb'.cast (by rw [e2])) e3 e4 e5) fun dense hdense => ?_
  rw [e1] at hdense
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hdense _ [nA * lay.cols]
    (by simp [li, PDim.eval]) (by simp [extent])) fun flat hflat => ?_
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hx _ [lay.cols * n]
    (by rw [refRows_scaled o n _ (by omega)]; simp) (by simp [extent]; ring)) fun x2 hx2 => ?_
  refine OkV.bind (ok_denseProjT P K env n lay rest hrest hbits hc hx) fun gpu hgpu => ?_
  refine OkV.bind hout fun b hb => ?_
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hgpu _ [n, lay.rows - nA]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun g2 hg2 => ?_
  refine OkV.bind (ok_concat P K.toKernelContract env (ksR P K env) hb hg2 1 (by simp [List.range_succ]))
    fun both hboth => ?_
  have hboth' : Ty both .bfloat16 [n, lay.rows] := hboth.cast (by simp; omega)
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hboth' _ [1, n, lay.rows]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun y hy => ?_
  exact OkV.pure ⟨hy, hflat, hx2⟩

/-- The vector expansion of `rows` stored rows. -/
theorem ok_expandKernel (rows bits il : Nat) (hroute : ExpandRoute rows bits il (if il = 0 then 0 else 128)) {cd sc : Value}
    (hcd : Ty cd .uint32 (expandCodes rows bits il)) (hsc : Ty sc .float16 [rows]) :
    OkV (primEvalE P K.toKernelContract env (ksR P K env)
      (.kernel chars!"mlx_bun_trellis_vector_expand" (expandCfg (PDim.eval (refNu o n)) rows bits il) 0) [cd, sc])
      fun u => Ty u .bfloat16 [rows, 5120] :=
  ok_prefillLaunch P K env (prefillOf_self .vectorExpand) (toConfig_expand (refNu o n) rows bits il) rfl
    (K.vectorExpand cd sc hroute hcd hsc)

/-- The MLP split on `x` `[1, n, 5120]`: the rest rows' expansions, matmuls and SwiGLU, the readback `out`
(`[n, 5120]`) added; the tap the flattened input `[5120·n]`. -/
theorem ok_aneMlpT (rest : Nat) (mlay : MlpLayout) (key : MlpKey → κ) (out : κ) (hm : MlpRestW env mlay rest key)
    (hout : OkV (env.inputs out) fun v => Ty v .bfloat16 [n, 5120]) {x : Value} (hx : Ty x .bfloat16 [1, n, 5120]) :
    OkV (aneMlpT (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) refRows rest mlay key out x)
      fun r => Ty r.1 .bfloat16 [1, n, 5120] ∧ Ty r.2 .bfloat16 [5120 * n] := by
  have hroute : ∀ bits il, (bits = 2 ∨ bits = 3 ∨ bits = 4) → (il = 0 ∨ (bits = 3 ∧ il = 2)) →
      ExpandRoute rest bits il (if il = 0 then 0 else 128) := by
    intro bits il hb hil
    refine ⟨hm.restRows, ?_⟩
    rcases hil with rfl | ⟨rfl, rfl⟩
    · exact .inl ⟨rfl, rfl, hb⟩
    · exact .inr ⟨rfl, rfl, rfl⟩
  unfold aneMlpT
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hx _ [5120 * n]
    (by rw [refRows_scaled o n _ (by omega)]; simp) (by simp [extent]; ring)) fun h2 hh2 => ?_
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hx _ [n, 5120]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun gx hgx => ?_
  refine OkV.bind hm.gateCodes fun gc hgc => ?_
  refine OkV.bind hm.gateScales fun gs hgs => ?_
  refine OkV.bind (ok_expandKernel P K env o n rest mlay.gateBits 0 (hroute _ _ hm.gateBits (.inl rfl))
    (hgc.cast rfl) hgs) fun ge hge => ?_
  refine OkV.bind (ok_transpose P K.toKernelContract env (ksR P K env) hge [1, 0] (by simp [List.range_succ])) fun gt hgt => ?_
  refine OkV.bind (ok_matmul P K.toKernelContract env (ksR P K env) hgx (hgt.cast rfl) (matmulOut_mat n 5120 rest))
    fun gp hgp => ?_
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hgp _ [1, n, rest]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun g hg => ?_
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hx _ [n, 5120]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun ux hux => ?_
  refine OkV.bind hm.upCodes fun uc huc => ?_
  refine OkV.bind hm.upScales fun us hus => ?_
  refine OkV.bind (ok_expandKernel P K env o n rest mlay.upBits 0 (hroute _ _ hm.upBits (.inl rfl))
    (huc.cast rfl) hus) fun ue hue => ?_
  refine OkV.bind (ok_transpose P K.toKernelContract env (ksR P K env) hue [1, 0] (by simp [List.range_succ])) fun ut hut => ?_
  refine OkV.bind (ok_matmul P K.toKernelContract env (ksR P K env) hux (hut.cast rfl) (matmulOut_mat n 5120 rest))
    fun up hup => ?_
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hup _ [1, n, rest]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun u hu => ?_
  refine OkV.bind (ok_swiglu P K.toKernelContract env (ksR P K env) hg hu) fun mid hmid => ?_
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hmid _ [n, rest]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun dx hdx => ?_
  refine OkV.bind hm.downCodes fun dc hdc => ?_
  refine OkV.bind hm.downScales fun ds hds => ?_
  refine OkV.bind (ok_expandKernel P K env o n rest mlay.downBits (if mlay.downBits = 3 then 2 else 0)
    (hroute _ _ hm.downBits (by by_cases h : mlay.downBits = 3 <;> simp [h])) hdc hds) fun de hde => ?_
  refine OkV.bind (ok_matmul P K.toKernelContract env (ksR P K env) hdx hde (matmulOut_mat n rest 5120))
    fun dp hdp => ?_
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hdp _ [1, n, 5120]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun gpuOut hgo => ?_
  refine OkV.bind hout fun b hb => ?_
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hgo _ [n, 5120]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun g2 hg2 => ?_
  refine OkV.bind (ok_add P K.toKernelContract env (ksR P K env) hb hg2) fun s hs => ?_
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hs _ [1, n, 5120]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun y hy => ?_
  exact OkV.pure ⟨hy, hh2⟩

end

end Host.Mlx.SimGraph.Mach

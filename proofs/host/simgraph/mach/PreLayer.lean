import host.simgraph.mach.PreKern
import host.simgraph.ref.Steps
namespace Host.Mlx.SimGraph.Mach
open Inference Inference.Contracts.Mlx Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Mlx.SimGraph.Ref (refRows refNu refRows_o refRows_n)

/-! # The GPU row families' projections and MLPs are defined on well-typed inputs

The value instances of the projection templates (`rowsProjT`, `splitProjT`), the down pass (`downT`), the
MLPs (`codebookMlpT`, `wideMlpT`), the norm and the embedding at the step's canonical rows (`refRows`,
valuation `refNu o n`), on the step environment's weights (`LinOk`, `MlpOk`: the inputs at the keys typed, at
the route's instances) and inputs of the forwards' shapes. -/

/-! ## The step's dimensions -/

theorem refRows_on (o n : Nat) : refRows.onP.eval (refNu o n) = o + n := by
  simp [refRows, Rows.onP, Aff.eval_toP, Aff.add, Aff.var, Aff.eval, termsEval, refNu, insertTerm]

theorem refRows_n3 (o n : Nat) : refRows.n3P.eval (refNu o n) = n + 3 := by
  simp [refRows, Rows.n3P, Aff.eval_toP, Aff.add, Aff.var, Aff.const, Aff.eval, termsEval, refNu, insertTerm]
  omega

theorem refRows_scaled (o n : Nat) (k : Int) (hk : k ≠ 0) : (refRows.scaled k).eval (refNu o n) = k * n := by
  simp [refRows, Rows.scaled, Aff.eval_toP, Aff.scale, Aff.var, Aff.eval, termsEval, refNu, hk]

theorem refRows_rup (o n : Nat) :
    (PDim.rupF 256 refRows.nP).eval (refNu o n) = ((256 * ((n + 255) / 256) : Nat) : Int) := by
  have h : refRows.nP = .lin 0 [(1, 1)] := rfl
  rw [h]
  simp [PDim.rupF, PDim.eval, ceilDiv, termsEval, refNu]
  omega

/-! ## The step environment's weights -/

/-- A projection's inputs at `key`: typed for the layout, at a route instance (`SplitRoute`, which contains the
rows kernels' instances). -/
structure LinOk {κ : Type} (env : Env κ) (lay : LinLayout) (key : LinKey → κ) : Prop where
  bits : lay.bits = 3 ∨ lay.bits = 4
  route : SplitRoute lay.rows lay.cols lay.bits
  w : ∃ v, env.inputs (key .w) = some v ∧ Ty v .uint32 [lay.rows, lay.cols * lay.bits / 32]
  scales : ∃ v, env.inputs (key .scales) = some v ∧ Ty v .bfloat16 [lay.rows, lay.cols / 64]
  biases : ∃ v, env.inputs (key .biases) = some v ∧ Ty v .bfloat16 [lay.rows, lay.cols / 64]

/-- An MLP's inputs at `key`: typed for the layout, its gate and up widths a route pair. -/
structure MlpOk {κ : Type} (env : Env κ) (mlay : MlpLayout) (key : MlpKey → κ) : Prop where
  route : GateUpRoute mlay.gateBits mlay.upBits
  downBits : mlay.downBits = 2 ∨ mlay.downBits = 3 ∨ mlay.downBits = 4
  norm : ∃ v, env.inputs (key .norm) = some v ∧ Ty v .bfloat16 [5120]
  gateCodes : ∃ v, env.inputs (key .gateCodes) = some v ∧ Ty v .uint32 [17408, 160 * mlay.gateBits]
  gateScales : ∃ v, env.inputs (key .gateScales) = some v ∧ Ty v .float16 [17408]
  upCodes : ∃ v, env.inputs (key .upCodes) = some v ∧ Ty v .uint32 [17408, 160 * mlay.upBits]
  upScales : ∃ v, env.inputs (key .upScales) = some v ∧ Ty v .float16 [17408]
  downCodes : ∃ v, env.inputs (key .downCodes) = some v ∧
    Ty v .uint32 (if mlay.downBits = 3 then [10, 17408, 48] else [17408, 160 * mlay.downBits])
  downScales : ∃ v, env.inputs (key .downScales) = some v ∧ Ty v .float16 [17408]

theorem rows_route {r N K bits : Nat} (h : SplitRoute N K bits) (hr : r = 2 ∨ r = 3) :
    if bits = 3 then Rows3Route r N K else Rows4Route r N K := by
  unfold SplitRoute at h
  simp only [List.mem_cons, Prod.mk.injEq, List.not_mem_nil, or_false] at h
  split
  · rename_i h3
    refine ⟨hr, ?_⟩
    simp only [List.mem_cons, Prod.mk.injEq, List.not_mem_nil, or_false]
    omega
  · rename_i h3
    refine ⟨hr, ?_⟩
    simp only [List.mem_cons, Prod.mk.injEq, List.not_mem_nil, or_false]
    omega

/-! ## Templates -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} (env : Env κ) (o n : Nat)

/-- The norm. -/
theorem ok_normT (key : κ) {x : Value} {sh : List Nat} {d : Nat} (hx : Ty x .bfloat16 sh)
    (hin : ∃ v, env.inputs key = some v ∧ Ty v .bfloat16 [d]) (hl : sh.getLast? = some d)
    (hd : d = 5120 ∨ d = 256 ∨ d = 128) :
    OkV (normT (valueB P K.toKernelContract env (ksR P K env)) key x) (fun u => Ty u .bfloat16 sh) := by
  unfold normT
  exact OkV.bind hin fun w hw => ok_rmsNorm P K.toKernelContract env (ksR P K env) eps6 hx hw hl hd

/-- `affine{3,4}_rows` on `x` `[1, n, K]`, `n ∈ {2, 3}`. -/
theorem ok_rowsProjT (lay : LinLayout) (key : LinKey → κ) (hl : LinOk env lay key) (hn : n = 2 ∨ n = 3)
    {x : Value} (hx : Ty x .bfloat16 [1, n, lay.cols]) :
    OkV (rowsProjT (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) refRows lay key x)
      (fun u => Ty u .bfloat16 [1, n, lay.rows]) := by
  unfold rowsProjT
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hx _ [n, lay.cols]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun x2 hx2 => ?_
  refine OkV.bind hl.w fun w hw => ?_
  refine OkV.bind hl.scales fun s hs => ?_
  refine OkV.bind hl.biases fun b hb => ?_
  refine OkV.bind (ok_rowsKernel P K env (refNu o n) refRows n (refRows_n o n) lay hl.bits
    (rows_route hl.route hn) hx2 hw hs hb) fun y hy => ?_
  exact ok_reshape P K.toKernelContract env (ksR P K env) hy _ [1, n, lay.rows] (by simp [li, PDim.eval, refRows_n])
    (by simp [extent])

/-- `affine_split_mma` on `x` `[1, n, K]`, `4 ≤ n ≤ 223`. -/
theorem ok_splitProjT (lay : LinLayout) (key : LinKey → κ) (hl : LinOk env lay key) (h4 : 4 ≤ n) (h223 : n ≤ 223)
    {x : Value} (hx : Ty x .bfloat16 [1, n, lay.cols]) :
    OkV (splitProjT (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) refRows lay key x)
      (fun u => Ty u .bfloat16 [1, n, lay.rows]) := by
  unfold splitProjT
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hx _ [n, lay.cols]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun x2 hx2 => ?_
  refine OkV.bind hl.w fun w hw => ?_
  refine OkV.bind hl.scales fun s hs => ?_
  refine OkV.bind hl.biases fun b hb => ?_
  refine OkV.bind (ok_splitKernel P K env (refNu o n) refRows n (refRows_n o n) lay hl.route h4 h223
    hx2 hw hs hb) fun y hy => ?_
  exact ok_reshape P K.toKernelContract env (ksR P K env) hy _ [1, n, lay.rows] (by simp [li, PDim.eval, refRows_n])
    (by simp [extent])

/-- The down pass, its sum over the partials, the bf16 cast, on `mid` `[1, n, 17408]`. -/
theorem ok_downT (pass : DownPass) (mlay : MlpLayout) (key : MlpKey → κ) (hm : MlpOk env mlay key)
    (h2 : 2 ≤ n) (h223 : n ≤ 223) (hpass : mlay.downBits = 3 → pass = .oneBlock)
    (route : mlay.downBits ≠ 3 → DownRoute mlay.downBits pass.s pass.mt) {x : Value}
    (hx : Ty x .bfloat16 [1, n, 17408]) :
    OkV (downT (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) refRows pass mlay key x)
      (fun u => Ty u .bfloat16 [1, n, 5120]) := by
  unfold downT
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hx _ [n, 17408]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun x2 hx2 => ?_
  refine OkV.bind hm.downCodes fun dc hdc => ?_
  refine OkV.bind hm.downScales fun ds hds => ?_
  refine OkV.bind (ok_downKernel P K env (refNu o n) refRows n (refRows_n o n) pass mlay h2 h223
    hpass route hx2 hdc hds) fun part hpart => ?_
  refine OkV.bind (ok_sum1 P K.toKernelContract env (ksR P K env) hpart) fun sm hsm => ?_
  refine OkV.bind (ok_astype P K.toKernelContract env (ksR P K env) hsm) fun y hy => ?_
  exact ok_reshape P K.toKernelContract env (ksR P K env) hy _ [1, n, 5120] (by simp [li, PDim.eval, refRows_n])
    (by simp [extent])

/-- The codebook MLP on `x` `[1, n, 5120]`, `2 ≤ n ≤ 8`. -/
theorem ok_codebookMlpT (mlay : MlpLayout) (key : MlpKey → κ) (hm : MlpOk env mlay key) (h2 : 2 ≤ n) (h8 : n ≤ 8)
    {x : Value} (hx : Ty x .bfloat16 [1, n, 5120]) :
    OkV (codebookMlpT (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) refRows mlay key x)
      (fun u => Ty u .bfloat16 [1, n, 5120]) := by
  unfold codebookMlpT
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hx _ [n, 5120]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun x2 hx2 => ?_
  refine OkV.bind hm.gateCodes fun gc hgc => ?_
  refine OkV.bind hm.gateScales fun gs hgs => ?_
  refine OkV.bind hm.upCodes fun uc huc => ?_
  refine OkV.bind hm.upScales fun us hus => ?_
  refine OkV.bind (ok_codebookKernel P K env (refNu o n) refRows n (refRows_n o n) mlay hm.route h2 h8 hx2 hgc hgs
    huc hus) fun mid hmid => ?_
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hmid _ [1, n, 17408]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun mid1 hmid1 => ?_
  exact ok_downT P K env o n .oneBlock mlay key hm h2 (by omega) (fun _ => rfl)
    (fun h3 => by
      rcases hm.downBits with h | h | h
      · rw [h]; simp [DownRoute, DownPass.oneBlock]
      · exact absurd h h3
      · rw [h]; simp [DownRoute, DownPass.oneBlock]) hmid1

/-- The wide MLP on `x` `[1, n, 5120]`, `9 ≤ n ≤ 223`, `MT` its row blocks, a route down pass. -/
theorem ok_wideMlpT (mt : Nat) (pass : DownPass) (mlay : MlpLayout) (key : MlpKey → κ) (hm : MlpOk env mlay key)
    (h9 : 9 ≤ n) (h223 : n ≤ 223) (hmt : mt = Metal.Kernels.GateUpMmaWide.rowBlocks n)
    (route : mlay.downBits ≠ 3 → DownRoute mlay.downBits pass.s pass.mt) {x : Value}
    (hx : Ty x .bfloat16 [1, n, 5120]) :
    OkV (wideMlpT (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) refRows mt pass mlay key x)
      (fun u => Ty u .bfloat16 [1, n, 5120]) := by
  unfold wideMlpT
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hx _ [n, 5120]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun x2 hx2 => ?_
  refine OkV.bind hm.gateCodes fun gc hgc => ?_
  refine OkV.bind hm.gateScales fun gs hgs => ?_
  refine OkV.bind hm.upCodes fun uc huc => ?_
  refine OkV.bind hm.upScales fun us hus => ?_
  refine OkV.bind (ok_wideKernel P K env (refNu o n) refRows n (refRows_n o n) mt hmt mlay hm.route h9 h223 hx2 hgc
    hgs huc hus) fun mid hmid => ?_
  refine OkV.bind (ok_reshape P K.toKernelContract env (ksR P K env) hmid _ [1, n, 17408]
    (by simp [li, PDim.eval, refRows_n]) (by simp [extent])) fun mid1 hmid1 => ?_
  by_cases h3 : mlay.downBits = 3
  · rw [ite_eq_left h3]
    exact ok_downT P K env o n .oneBlock mlay key hm (by omega) h223 (fun _ => rfl) (fun h => absurd h3 h) hmid1
  · rw [ite_eq_right h3]
    exact ok_downT P K env o n pass mlay key hm (by omega) h223 (fun h => absurd h h3) route hmid1

end

end Host.Mlx.SimGraph.Mach

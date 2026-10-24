import host.simgraph.family.LayerSim
import host.simgraph.family.TplX
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx

/-! # The Neural Engine forwards' layer templates

The GPU side of the Neural Engine forwards (#aneSmall, #aneDense, #aneAffine;
prefill-map §3–4), as the TypeScript builds it. A split hands its sources to
in-place writers and reads the Neural Engine's rows back through the output
wrap: the writers are not in the expected graph, their pure sources are the
template's taps, and the readback (`astype` of the output view) is an input.

* `denseProjT` (dequantized-linear.ts `DequantizedMatmulLinear`): dequantize
  (g64, affine) → transpose → matmul;
* `plainProjT` (quantized-linear.ts `QuantizedLinearPlain`): quantized_matmul
  (transposed, g64, affine);
* `aneSplitProjT` (ane-prefill-split.ts `AneAffineSplit.forward`, the rest
  rows Dense): taps the flattened dequantized head rows and the flattened
  input (the two `writeHalf` sources); the readback concatenated with the
  rest rows' projection;
* `aneMlpT` (`mlpSplit` with `AneTrellisExpandReduce`/`Scatter`): taps the
  flattened input (`writeHalf`'s source); the GPU share's vector expansions of
  the rest rows (vector-expand.ts), matmuls and SwiGLU; the readback plus the
  GPU partial;
* `aneDeltaLayerT`, `aneAttentionLayerT`: the plain layers (blocks.ts) with a
  projection per site (delta 0 qkv, 1 z, 2 a, 3 b, 4 out; attention 0 q, 1 k,
  2 v, 3 o) and the MLP, collecting the taps in call order (the delta block
  projects qkv, z, b, a).

Each template is natural (`nat_*`), branches only on the KV signature
(`aneAttentionLayerT_sig`), and its builder carries its value computation
(`sim_*`). -/

/-- A projection site's kind in a Neural Engine forward (ANE rows `nA` for a split). -/
inductive AneProj where
  | dense
  | plain
  | split (nA : Nat)
deriving DecidableEq

section
variable {δ : Type} (I : PDim → δ)

/-- vector-expand.ts `vectorTrellisExpand` of `rows` stored rows at width `bits`: row-major (`il = 0`, grid
`[1280, rows, 1]`) or the 3-bit block interleave (`il = 2`, row tile 128, grid `[1280·rows, 1, 1]`). -/
def expandCfg (rows bits il : Nat) : RCfg δ :=
  kcfg I [([.lit rows, .lit 5120], Ffi.dtBf16)]
    (if il = 0 then [.lit 1280, .lit rows, .lit 1] else [.lit (1280 * rows), .lit 1, .lit 1]) [.lit 128, .lit 1, .lit 1]
    [(chars!"T", Ffi.dtBf16)]
    [(chars!"R", .lit rows), (chars!"C", .lit 5120), (chars!"BT", .lit 256), (chars!"BITS", .lit bits),
      (chars!"L", .lit 12), (chars!"INTERLEAVE", .lit il), (chars!"ROW_TILE", .lit (if il = 0 then 0 else 128))]

end

section
variable {δ κ : Type} {m : Type → Type} [Monad m] {α : Type} (B : Backend δ κ m α) (I : PDim → δ)

/-- `DequantizedMatmulLinear` on `x` `[1, r, K]`. -/
def denseProjT (lay : LinLayout) (key : LinKey → κ) (x : α) : m α := do
  let w ← B.inp (key .w)
  let s ← B.inp (key .scales)
  let b ← B.inp (key .biases)
  let dq ← B.op (.dequantize 64 lay.bits chars!"affine" none) [w, s, b]
  let wt ← B.op (.transpose [1, 0]) [dq]
  B.op (.unary chars!"matmul") [x, wt]

/-- `QuantizedLinearPlain` on `x` `[1, r, K]`. -/
def plainProjT (lay : LinLayout) (key : LinKey → κ) (x : α) : m α := do
  let w ← B.inp (key .w)
  let s ← B.inp (key .scales)
  let b ← B.inp (key .biases)
  B.op (.qmm true 64 lay.bits chars!"affine") [x, w, s, b]

/-- `AneAffineSplit.forward` with `nA` ANE rows on `x` `[1, r, K]`: the head and
rest rows' weights `head`, `rest` (slices made at construction), the readback
`out`. Taps: the flattened head rows, the flattened input. -/
def aneSplitProjT (R : Rows) (lay : LinLayout) (nA : Nat) (head rest : LinKey → κ) (out : κ) (x : α) :
    m (α × α × α) := do
  let hw ← B.inp (head .w)
  let hs ← B.inp (head .scales)
  let hb ← B.inp (head .biases)
  let dense ← B.op (.dequantize 64 lay.bits chars!"affine" none) [hw, hs, hb]
  let flat ← B.op (.reshape [li I ((nA * lay.cols : Nat) : Int)]) [dense]
  let x2 ← B.op (.reshape [I (R.scaled lay.cols)]) [x]
  let gpu ← denseProjT B lay rest x
  let b ← B.inp out
  let g2 ← B.op (.reshape [I R.nP, li I ((lay.rows - nA : Nat) : Int)]) [gpu]
  let both ← B.op (.concat 1) [b, g2]
  let y ← B.op (.reshape [li I 1, I R.nP, li I lay.rows]) [both]
  pure (y, flat, x2)

/-- A projection site of a Neural Engine forward with its two taps (a split's
sources; the output twice at a site without a split). -/
def aneProjT (R : Rows) : AneProj → LinLayout → (LinKey → κ) → (LinKey → κ) → (LinKey → κ) → κ → α → m (α × α × α)
  | .dense, lay, key, _, _, _, x => do let y ← denseProjT B lay key x; pure (y, y, y)
  | .plain, lay, key, _, _, _, x => do let y ← plainProjT B lay key x; pure (y, y, y)
  | .split nA, lay, _, head, rest, out, x => aneSplitProjT B I R lay nA head rest out x

/-- `mlpSplit` (expanded GPU rows, `rest` rows on the GPU) on `x` `[1, r, 5120]`:
the rest rows' codes and scales `key` (`trellisRows`/`trellisStoredRows`,
made at construction), the readback `out`. Tap: the flattened input. -/
def aneMlpT (R : Rows) (rest : Nat) (mlay : MlpLayout) (key : MlpKey → κ) (out : κ) (x : α) : m (α × α) := do
  let h2 ← B.op (.reshape [I (R.scaled 5120)]) [x]
  let gx ← B.op (.reshape [I R.nP, li I 5120]) [x]
  let gc ← B.inp (key .gateCodes)
  let gs ← B.inp (key .gateScales)
  let ge ← B.op (.kernel chars!"mlx_bun_trellis_vector_expand" (expandCfg I rest mlay.gateBits 0) 0) [gc, gs]
  let gt ← B.op (.transpose [1, 0]) [ge]
  let gp ← B.op (.unary chars!"matmul") [gx, gt]
  let g ← B.op (.reshape [li I 1, I R.nP, li I rest]) [gp]
  let ux ← B.op (.reshape [I R.nP, li I 5120]) [x]
  let uc ← B.inp (key .upCodes)
  let us ← B.inp (key .upScales)
  let ue ← B.op (.kernel chars!"mlx_bun_trellis_vector_expand" (expandCfg I rest mlay.upBits 0) 0) [uc, us]
  let ut ← B.op (.transpose [1, 0]) [ue]
  let up ← B.op (.unary chars!"matmul") [ux, ut]
  let u ← B.op (.reshape [li I 1, I R.nP, li I rest]) [up]
  let mid ← B.op (closureP .swiglu) [g, u]
  let dx ← B.op (.reshape [I R.nP, li I rest]) [mid]
  let dc ← B.inp (key .downCodes)
  let ds ← B.inp (key .downScales)
  let de ← B.op (.kernel chars!"mlx_bun_trellis_vector_expand"
    (expandCfg I rest mlay.downBits (if mlay.downBits = 3 then 2 else 0)) 0) [dc, ds]
  let dp ← B.op (.unary chars!"matmul") [dx, de]
  let gpuOut ← B.op (.reshape [li I 1, I R.nP, li I 5120]) [dp]
  let b ← B.inp out
  let g2 ← B.op (.reshape [I R.nP, li I 5120]) [gpuOut]
  let s ← B.op (.binary chars!"add") [b, g2]
  let y ← B.op (.reshape [li I 1, I R.nP, li I 5120]) [s]
  pure (y, h2)

variable (proj : Nat → LinLayout → α → m (α × α × α)) (mlp : MlpLayout → α → m (α × α))

/-- One gated-delta layer of a Neural Engine forward (`deltaLayerT` with a
projection per site and the split MLP); taps in call order. -/
def aneDeltaLayerT (R : Rows) (d : DeltaLayout) (key : SKey → κ) (aux : Nat → κ) (x : α) :
    m ((α × α × α) × List (List α)) := do
  let xn ← normT B (key .inputNorm) x
  let rq ← proj 0 d.qkv xn
  let rz ← proj 1 d.z xn
  let z ← B.op (.reshape [li I 1, I R.nP, li I 48, li I 128]) [rz.1]
  let rb ← proj 3 d.b xn
  let ra ← proj 2 d.a xn
  let conv ← optInpT B d.hasConv (key (.cache 0)) (.zeros (lis I [1, 3, 10240]) Ffi.dtBf16)
  let joined ← B.op (.concat 1) [conv, rq.1]
  let view ← B.op (.slice [li I 0, I R.nP, li I 0] [li I 1, I R.n3P, li I 10240] (lis I [1, 1, 1])) [joined]
  let zi ← B.op (.data [0, 0, 0, 0] [] Ffi.dtInt32) []
  let tail ← B.op (.sliceDynamic [0] (lis I [1, 3, 10240])) [view, zi]
  let cw ← B.inp (key .conv)
  let c ← B.op (.conv1d 1 0 1 10240) [joined, cw]
  let cs ← B.op (closureP .silu) [c]
  let qf ← B.op (.slice (lis I [0, 0, 0]) [li I 1, I R.nP, li I 2048] (lis I [1, 1, 1])) [cs]
  let kf ← B.op (.slice (lis I [0, 0, 2048]) [li I 1, I R.nP, li I 4096] (lis I [1, 1, 1])) [cs]
  let vf ← B.op (.slice (lis I [0, 0, 4096]) [li I 1, I R.nP, li I 10240] (lis I [1, 1, 1])) [cs]
  let q0 ← B.op (.reshape [li I 1, I R.nP, li I 16, li I 128]) [qf]
  let k0 ← B.op (.reshape [li I 1, I R.nP, li I 16, li I 128]) [kf]
  let v ← B.op (.reshape [li I 1, I R.nP, li I 48, li I 128]) [vf]
  let q ← normT B (key .qScale) q0
  let k ← normT B (key .kScale) k0
  let beta ← B.op (.unary chars!"sigmoid") [rb.1]
  let al ← B.inp (key .aLog)
  let dt ← B.inp (key .dtBias)
  let g ← B.op .computeG [al, ra.1, dt]
  let st0 ← optInpT B d.hasRec (key (.cache 1)) (.zeros (lis I [1, 48, 128, 128]) Ffi.dtF32)
  let t ← B.inp (aux 0)
  let y ← B.op (.kernel chars!"gated_delta_step" (gatedCfg I R) 0) [q, k, v, g, beta, st0, t]
  let s ← B.op (.kernel chars!"gated_delta_step" (gatedCfg I R) 1) [q, k, v, g, beta, st0, t]
  let yn ← normT B (key .norm) y
  let gated ← B.op (closureP .preciseSwiglu) [z, yn]
  let merged ← B.op (.reshape [li I 1, I R.nP, li I 6144]) [gated]
  let ro ← proj 4 d.out merged
  let h ← B.op (.binary chars!"add") [x, ro.1]
  let hn ← normT B (key (.mlp .norm)) h
  let rm ← mlp d.mlp hn
  let out ← B.op (.binary chars!"add") [h, rm.1]
  pure ((out, tail, s), [[rq.2.1, rq.2.2], [rz.2.1, rz.2.2], [rb.2.1, rb.2.2], [ra.2.1, ra.2.2], [ro.2.1, ro.2.2], [rm.2]])

/-- One attention layer of a Neural Engine forward (`attentionLayerT`, the
causal read, a projection per site and the split MLP); taps in call order. -/
def aneAttentionLayerT (R : Rows) (o n : Nat) (a : AttnLayout) (key : SKey → κ) (aux : Nat → κ) (x : α) :
    m ((α × α × α) × List (List α)) := do
  let xn ← normT B (key .inputNorm) x
  let rq ← proj 0 a.q xn
  let qpr ← B.op (.reshape [li I 1, I R.nP, li I 24, li I 512]) [rq.1]
  let qh ← B.op (.slice (lis I [0, 0, 0, 0]) [li I 1, I R.nP, li I 24, li I 256] (lis I [1, 1, 1, 1])) [qpr]
  let gh ← B.op (.slice (lis I [0, 0, 0, 256]) [li I 1, I R.nP, li I 24, li I 512] (lis I [1, 1, 1, 1])) [qpr]
  let gate ← B.op (.reshape [li I 1, I R.nP, li I 6144]) [gh]
  let rk ← proj 1 a.k xn
  let rv ← proj 2 a.v xn
  let qn ← normT B (key .qNorm) qh
  let qt ← B.op (.transpose [0, 2, 1, 3]) [qn]
  let kr ← B.op (.reshape [li I 1, I R.nP, li I 4, li I 256]) [rk.1]
  let kn ← normT B (key .kNorm) kr
  let kt ← B.op (.transpose [0, 2, 1, 3]) [kn]
  let vr ← B.op (.reshape [li I 1, I R.nP, li I 4, li I 256]) [rv.1]
  let vt ← B.op (.transpose [0, 2, 1, 3]) [vr]
  let qr ← B.op (.rope 64 false ropeBaseWord ropeScaleWord (I R.oP)) [qt]
  let kq ← B.op (.rope 64 false ropeBaseWord ropeScaleWord (I R.oP)) [kt]
  let (kb, keys) ← kvStepT B I R o n a.kcap (key (.cache 0)) kq
  let (vb, values) ← kvStepT B I R o n a.vcap (key (.cache 1)) vt
  let attn ← readT B I R .causal aux qr keys values
  let attnT ← B.op (.transpose [0, 2, 1, 3]) [attn]
  let merged ← B.op (.reshape [li I 1, I R.nP, li I (-1)]) [attnT]
  let sig ← B.op (.unary chars!"sigmoid") [gate]
  let gated ← B.op (.binary chars!"multiply") [merged, sig]
  let ro ← proj 3 a.o gated
  let h ← B.op (.binary chars!"add") [x, ro.1]
  let hn ← normT B (key (.mlp .norm)) h
  let rm ← mlp a.mlp hn
  let out ← B.op (.binary chars!"add") [h, rm.1]
  pure ((out, kb, vb), [[rq.2.1, rq.2.2], [rk.2.1, rk.2.2], [rv.2.1, rv.2.2], [ro.2.1, ro.2.2], [rm.2]])

end

/-! ## Naturality and branches -/

section
variable {δ δ' κ : Type} (f : δ → δ') (I : PDim → δ)

/-- Close the side conditions of the Neural Engine templates' primitives. -/
macro "dimA_map" : tactic =>
  `(tactic| first | rfl | simp [mapP, mapC_kcfg, expandCfg, gatedCfg, li, lis, List.map_map, Function.comp_def])

theorem nat_denseProjT (lay : LinLayout) (key : LinKey → κ) (x : Nat) :
    Natural f (denseProjT (δ := δ) graphB lay key x) (denseProjT (δ := δ') graphB lay key x) := by
  unfold denseProjT; natB_peel

theorem nat_plainProjT (lay : LinLayout) (key : LinKey → κ) (x : Nat) :
    Natural f (plainProjT (δ := δ) graphB lay key x) (plainProjT (δ := δ') graphB lay key x) := by
  unfold plainProjT; natB_peel

theorem nat_aneSplitProjT (R : Rows) (lay : LinLayout) (nA : Nat) (head rest : LinKey → κ) (out : κ) (x : Nat) :
    Natural f (aneSplitProjT graphB I R lay nA head rest out x)
      (aneSplitProjT graphB (fun d => f (I d)) R lay nA head rest out x) := by
  unfold aneSplitProjT
  natB_peel
  refine natural_bind (nat_denseProjT f lay rest _) fun _ => ?_
  natB_peel

theorem nat_aneProjT (R : Rows) (k : AneProj) (lay : LinLayout) (key head rest : LinKey → κ) (out : κ) (x : Nat) :
    Natural f (aneProjT graphB I R k lay key head rest out x)
      (aneProjT graphB (fun d => f (I d)) R k lay key head rest out x) := by
  cases k with
  | dense => exact natural_bind (nat_denseProjT f lay key x) fun _ => natural_pure _
  | plain => exact natural_bind (nat_plainProjT f lay key x) fun _ => natural_pure _
  | split nA => exact nat_aneSplitProjT f I R lay nA head rest out x

theorem nat_aneMlpT (R : Rows) (rest : Nat) (mlay : MlpLayout) (key : MlpKey → κ) (out : κ) (x : Nat) :
    Natural f (aneMlpT graphB I R rest mlay key out x) (aneMlpT graphB (fun d => f (I d)) R rest mlay key out x) := by
  unfold aneMlpT
  natB_peel
  all_goals dimA_map

variable {I}

theorem nat_aneDeltaLayerT (proj : Nat → LinLayout → Nat → Build δ κ (Nat × Nat × Nat))
    (proj' : Nat → LinLayout → Nat → Build δ' κ (Nat × Nat × Nat))
    (mlp : MlpLayout → Nat → Build δ κ (Nat × Nat)) (mlp' : MlpLayout → Nat → Build δ' κ (Nat × Nat))
    (hp : ∀ j lay x, Natural f (proj j lay x) (proj' j lay x)) (hm : ∀ lay x, Natural f (mlp lay x) (mlp' lay x))
    (R : Rows) (d : DeltaLayout) (key : SKey → κ) (aux : Nat → κ) (x : Nat) :
    Natural f (aneDeltaLayerT graphB I proj mlp R d key aux x)
      (aneDeltaLayerT graphB (fun d => f (I d)) proj' mlp' R d key aux x) := by
  unfold aneDeltaLayerT
  refine natural_bind (nat_normT f _ x) fun _ => ?_
  refine natural_bind (hp _ _ _) fun _ => ?_
  refine natural_bind (hp _ _ _) fun _ => ?_
  refine natural_bind (natB_op f _ (by dimB_map)) fun _ => ?_
  refine natural_bind (hp _ _ _) fun _ => ?_
  refine natural_bind (hp _ _ _) fun _ => ?_
  refine natural_bind (nat_optInpT f _ _ _ _ (by dimB_map)) fun _ => ?_
  natB_peel
  refine natural_bind (nat_normT f _ _) fun _ => ?_
  refine natural_bind (nat_normT f _ _) fun _ => ?_
  natB_peel
  refine natural_bind (nat_optInpT f _ _ _ _ (by dimB_map)) fun _ => ?_
  natB_peel
  refine natural_bind (nat_normT f _ _) fun _ => ?_
  natB_peel
  refine natural_bind (hp _ _ _) fun _ => ?_
  natB_peel
  refine natural_bind (nat_normT f _ _) fun _ => ?_
  refine natural_bind (hm _ _) fun _ => ?_
  natB_peel

theorem nat_aneAttentionLayerT (proj : Nat → LinLayout → Nat → Build δ κ (Nat × Nat × Nat))
    (proj' : Nat → LinLayout → Nat → Build δ' κ (Nat × Nat × Nat))
    (mlp : MlpLayout → Nat → Build δ κ (Nat × Nat)) (mlp' : MlpLayout → Nat → Build δ' κ (Nat × Nat))
    (hp : ∀ j lay x, Natural f (proj j lay x) (proj' j lay x)) (hm : ∀ lay x, Natural f (mlp lay x) (mlp' lay x))
    (R : Rows) (o n : Nat) (a : AttnLayout) (key : SKey → κ) (aux : Nat → κ) (x : Nat) :
    Natural f (aneAttentionLayerT graphB I proj mlp R o n a key aux x)
      (aneAttentionLayerT graphB (fun d => f (I d)) proj' mlp' R o n a key aux x) := by
  unfold aneAttentionLayerT
  refine natural_bind (nat_normT f _ x) fun _ => ?_
  refine natural_bind (hp _ _ _) fun _ => ?_
  natB_peel
  refine natural_bind (hp _ _ _) fun _ => ?_
  refine natural_bind (hp _ _ _) fun _ => ?_
  refine natural_bind (nat_normT f _ _) fun _ => ?_
  natB_peel
  refine natural_bind (nat_normT f _ _) fun _ => ?_
  natB_peel
  refine natural_bind (nat_kvStepT f I R o n _ _ _) fun ⟨_, _⟩ => ?_
  dsimp only
  refine natural_bind (nat_kvStepT f I R o n _ _ _) fun ⟨_, _⟩ => ?_
  dsimp only
  refine natural_bind (nat_readT f I R .causal aux _ _ _) fun _ => ?_
  natB_peel
  refine natural_bind (hp _ _ _) fun _ => ?_
  natB_peel
  refine natural_bind (nat_normT f _ _) fun _ => ?_
  refine natural_bind (hm _ _) fun _ => ?_
  natB_peel

end

section
variable {δ κ : Type} (I : PDim → δ)

theorem aneAttentionLayerT_sig (proj : Nat → LinLayout → Nat → Build δ κ (Nat × Nat × Nat))
    (mlp : MlpLayout → Nat → Build δ κ (Nat × Nat)) (R : Rows) (o n o' n' : Nat) (a a' : AttnLayout)
    (h : SigRelR kvSigP o n o' n' (.attention a) (.attention a')) (key : SKey → κ) (aux : Nat → κ) (x : Nat) :
    aneAttentionLayerT graphB I proj mlp R o n a key aux x = aneAttentionLayerT graphB I proj mlp R o' n' a' key aux x := by
  obtain ⟨hq, hk, hv, ho, hm, hkc, hvc⟩ := h
  unfold aneAttentionLayerT
  rw [hq, hk, hv, ho, hm]
  simp only [kvStepT_sig I R o n o' n' a.kcap a'.kcap _ _ hkc, kvStepT_sig I R o n o' n' a.vcap a'.vcap _ _ hvc]

end

/-! ## The builders carry their value computations -/

section
variable {C : M1Max.Contract} {P : MlxPrefillContract C} {K : KernelContract C} {κ : Type} {env : Env κ}
  {ks : KernelSem} (ν : Nat → Int)

theorem sim_denseProjT (lay : LinLayout) (key : LinKey → κ) (fs : List (Nat × Value)) (x : Nat) (v : Value)
    (h : (x, v) ∈ fs) :
    Sim P K env ks fs (denseProjT graphB lay key x) (denseProjT (valueB P K env ks) lay key v) := by
  unfold denseProjT; sim_peel

theorem sim_plainProjT (lay : LinLayout) (key : LinKey → κ) (fs : List (Nat × Value)) (x : Nat) (v : Value)
    (h : (x, v) ∈ fs) :
    Sim P K env ks fs (plainProjT graphB lay key x) (plainProjT (valueB P K env ks) lay key v) := by
  unfold plainProjT; sim_peel

theorem sim_aneSplitProjT (R : Rows) (lay : LinLayout) (nA : Nat) (head rest : LinKey → κ) (out : κ)
    (fs : List (Nat × Value)) (x : Nat) (v : Value) (h : (x, v) ∈ fs) :
    Sim P K env ks fs (aneSplitProjT graphB (PDim.eval ν) R lay nA head rest out x)
      (aneSplitProjT (valueB P K env ks) (PDim.eval ν) R lay nA head rest out v) := by
  unfold aneSplitProjT
  sim_peel
  refine sim_bind (sim_denseProjT _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  sim_peel

theorem sim_aneProjT (R : Rows) (k : AneProj) (lay : LinLayout) (key head rest : LinKey → κ) (out : κ)
    (fs : List (Nat × Value)) (x : Nat) (v : Value) (h : (x, v) ∈ fs) :
    Sim P K env ks fs (aneProjT graphB (PDim.eval ν) R k lay key head rest out x)
      (aneProjT (valueB P K env ks) (PDim.eval ν) R k lay key head rest out v) := by
  cases k with
  | dense =>
    unfold aneProjT
    refine sim_bind (sim_denseProjT _ _ _ _ _ h) fun _ _ => ?_
    sim_peel
  | plain =>
    unfold aneProjT
    refine sim_bind (sim_plainProjT _ _ _ _ _ h) fun _ _ => ?_
    sim_peel
  | split nA => exact sim_aneSplitProjT ν R lay nA head rest out fs x v h

theorem sim_aneMlpT (R : Rows) (rest : Nat) (mlay : MlpLayout) (key : MlpKey → κ) (out : κ)
    (fs : List (Nat × Value)) (x : Nat) (v : Value) (h : (x, v) ∈ fs) :
    Sim P K env ks fs (aneMlpT graphB (PDim.eval ν) R rest mlay key out x)
      (aneMlpT (valueB P K env ks) (PDim.eval ν) R rest mlay key out v) := by
  unfold aneMlpT; sim_peel

variable (proj : Nat → LinLayout → Nat → Build Int κ (Nat × Nat × Nat))
  (projV : Nat → LinLayout → Value → Option (Value × Value × Value))
  (mlp : MlpLayout → Nat → Build Int κ (Nat × Nat)) (mlpV : MlpLayout → Value → Option (Value × Value))
  (hp : ∀ j lay fs x v, (x, v) ∈ fs → Sim P K env ks fs (proj j lay x) (projV j lay v))
  (hm : ∀ lay fs x v, (x, v) ∈ fs → Sim P K env ks fs (mlp lay x) (mlpV lay v))
include hp hm

theorem sim_aneDeltaLayerT (R : Rows) (d : DeltaLayout) (key : SKey → κ) (aux : Nat → κ) (fs : List (Nat × Value))
    (x : Nat) (v : Value) (h : (x, v) ∈ fs) :
    Sim P K env ks fs (aneDeltaLayerT graphB (PDim.eval ν) proj mlp R d key aux x)
      (aneDeltaLayerT (valueB P K env ks) (PDim.eval ν) projV mlpV R d key aux v) := by
  unfold aneDeltaLayerT
  sim_sub sim_normT _ _
  refine sim_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  refine sim_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  sim_peel
  refine sim_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  refine sim_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  refine sim_bind (sim_optInpT _ _ _ _) fun conv vconv => ?_
  sim_peel
  sim_sub sim_normT _ _
  sim_sub sim_normT _ _
  sim_peel
  refine sim_bind (sim_optInpT _ _ _ _) fun st vst => ?_
  sim_peel
  sim_sub sim_normT _ _
  sim_peel
  refine sim_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  sim_peel
  sim_sub sim_normT _ _
  refine sim_bind (hm _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  sim_peel

theorem sim_aneAttentionLayerT (R : Rows) (o n : Nat) (a : AttnLayout) (key : SKey → κ) (aux : Nat → κ)
    (fs : List (Nat × Value)) (x : Nat) (v : Value) (h : (x, v) ∈ fs) :
    Sim P K env ks fs (aneAttentionLayerT graphB (PDim.eval ν) proj mlp R o n a key aux x)
      (aneAttentionLayerT (valueB P K env ks) (PDim.eval ν) projV mlpV R o n a key aux v) := by
  unfold aneAttentionLayerT
  sim_sub sim_normT _ _
  refine sim_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  sim_peel
  refine sim_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  refine sim_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  sim_sub sim_normT _ _
  sim_peel
  sim_sub sim_normT _ _
  sim_peel
  refine sim_bind (sim_kvStepT ν R o n _ _ _ _ _ ?_) fun ⟨kb, keys⟩ ⟨vkb, vkeys⟩ => ?_
  · mem_tac
  dsimp only
  refine sim_bind (sim_kvStepT ν R o n _ _ _ _ _ ?_) fun ⟨vb, values⟩ ⟨vvb, vvalues⟩ => ?_
  · mem_tac
  dsimp only
  refine sim_bind (sim_readT ν R .causal aux _ _ _ _ _ _ _ ?_ ?_ ?_) fun attn vattn => ?_
  · mem_tac
  · mem_tac
  · mem_tac
  sim_peel
  refine sim_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  sim_peel
  sim_sub sim_normT _ _
  refine sim_bind (hm _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  sim_peel

end

end Host.Mlx.SimGraph

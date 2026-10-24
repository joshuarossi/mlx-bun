import host.simgraph.family.Tpl
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx

/-! # Multi-row layer templates

The operation templates of the prefill forwards' layers at `r ≥ 2` rows and
cache offset `o`, as the TypeScript issues them (blocks.ts `QwenDeltaLayer`,
`QwenGatedDeltaNet`, `QwenAttentionLayer`; ssm.ts; kv.ts; folded-attention.ts;
affine-verify-linear.ts; trellis-gate-up.ts; trellis-down.ts; the kernels'
launch files), each written once over a `Backend`:

* projections: `rowsProjT` (`mlx_bun_affine{3,4}_rows`, V23) and
  `splitProjT` (`mlx_bun_affine_split_mma`, V4/V58/VW): reshape to `[r, K]`,
  the launch, reshape to `[1, r, N]`;
* MLPs: `codebookMlpT` (V23/V4/V58: `mlx_bun_trellis_gateup_codebook_mma`,
  the down pass in one block) and `wideMlpT` (VW:
  `mlx_bun_trellis_gateup_mma_wide`, the planned down pass), then
  `mlx_sum_axis(·, 1)`, `astype(bf16)`, reshape;
* `deltaLayerT`: input norm, the four projections, the causal conv over the
  conv state (zeros when null) and its new tail, `nn.silu`, the q/k/v heads
  and their norms, `compute_g`, `gated_delta_step` with `Tin = [r]` (the
  `aux 0` input), the gated norm, `_precise_swiglu`, the out projection, the
  residual, the post norm, the MLP, the residual;
* `attentionLayerT`: input norm, q (and gate), k, v projections, head norms,
  transposes, RoPE at offset `o`, the KV append (`kvStepT`, kv.ts
  `updateAndFetch`), the attention read (`causal`: MLX's causal SDPA;
  `folded r`: folded-attention.ts for `r ∈ {6, 7, 8}`), the gate, the out
  projection, the residual, the post norm, the MLP, the residual.

The projection and the MLP are parameters of the layer templates, so a row
family is a choice of per-layer templates. Dimensions are `PDim` terms of the
step's offset and rows (`Rows`), read through `I`. -/

/-- The step's symbolic offset and rows. -/
structure Rows where
  o : Aff
  n : Aff

namespace Rows
variable (R : Rows)
def nP : PDim := R.n.toP
def oP : PDim := R.o.toP
/-- `o + r`. -/
def onP : PDim := (R.o.add R.n).toP
/-- `r + 3` (the conv tail's end). -/
def n3P : PDim := (R.n.add (.const 3)).toP
/-- `k·r`. -/
def scaled (k : Int) : PDim := (R.n.scale k).toP
end Rows

/-- `⌈d/k⌉`, folded on literals (the run computes literal quotients itself). -/
def PDim.cdivF (d : PDim) (k : Nat) : PDim :=
  match d with
  | .lit i => .lit (ceilDiv i k)
  | d => .cdiv d k

/-- `k·⌈d/k⌉`, folded on literals. -/
def PDim.rupF (k : Nat) (d : PDim) : PDim :=
  match d with
  | .lit i => .lit ((k : Int) * ceilDiv i k)
  | d => .rup k d

theorem PDim.eval_cdivF (ν : Nat → Int) (d : PDim) (k : Nat) : (d.cdivF k).eval ν = (PDim.cdiv d k).eval ν := by
  cases d <;> rfl

theorem PDim.eval_rupF (ν : Nat → Int) (k : Nat) (d : PDim) : (PDim.rupF k d).eval ν = (PDim.rup k d).eval ν := by
  cases d <;> rfl

/-! ## Constants and configurations -/

def eps6 : Nat := 0x358637bd
def sdpaScaleWord : Nat := 0x3d800000
/-- bf16 0.0625 (folded-attention.ts `scalarLike(0.0625, q)`): bytes of 0x3D80. -/
def scaleBytes : List Nat := [0x80, 0x3D]
/-- bf16 -∞ (`scalarLike(-Infinity, scores)`): bytes of 0xFF80. -/
def ninfBytes : List Nat := [0x80, 0xFF]
def ropeBaseWord : Nat := 0x4b189680 + 2 ^ 32
def ropeScaleWord : Nat := 0x3f800000

section
variable {δ : Type} (I : PDim → δ)

/-- A literal dimension. -/
def li (i : Int) : δ := I (.lit i)
def lis (l : List Int) : List δ := l.map fun i => I (.lit i)

/-- A kernel launch's configuration (`MetalKernelCall`): outputs, grid,
threadgroup, template dtypes and ints in the order the TypeScript adds them. -/
def kcfg (outs : List (List PDim × Nat)) (grid group : List PDim) (dtypes : List (List Char × Nat))
    (ints : List (List Char × PDim)) : RCfg δ :=
  ⟨outs.map fun o => (o.1.map I, o.2), grid.map I, group.map I, ints.map fun t => (t.1, I t.2), dtypes, none⟩

end

theorem mapC_kcfg {δ δ' : Type} (f : δ → δ') (I : PDim → δ) (outs : List (List PDim × Nat)) (grid group : List PDim)
    (dtypes : List (List Char × Nat)) (ints : List (List Char × PDim)) :
    mapC f (kcfg I outs grid group dtypes ints) = kcfg (fun d => f (I d)) outs grid group dtypes ints := by
  simp [mapC, kcfg, List.map_map, Function.comp_def]

def litD (i : Int) : PDim := .lit i

/-- The `affine_split_mma` plan (affine-split-mma.ts:116-118): (TILES, SPLITS). -/
def splitPlan (N : Nat) : Nat × Nat := if 2048 ≤ N ∧ N % 16 = 0 then (2, 2) else (1, 8)

/-- `NW = ⌈(2·S·k + L - 1)/32⌉ + 1` (down-mma-wide.ts). -/
def downNW (s k : Nat) : Nat := (2 * s * k + 11 + 31) / 32 + 1

/-- A down pass: S, MT. -/
structure DownPass where
  s : Nat
  mt : Nat
deriving DecidableEq

def DownPass.oneBlock : DownPass := ⟨16, 1⟩

/-- The attention read. -/
inductive Read where
  | causal
  /-- folded-attention.ts at `r` rows (6, 7 or 8). -/
  | folded (r : Nat)
deriving DecidableEq

/-! ## Launch configurations (`MetalKernelCall` as each launch file builds it) -/

section
variable {δ : Type} (I : PDim → δ) (R : Rows)

/-- affine3-rows.ts/affine4-rows.ts: grid `[64, ⌈N/8⌉, 1]`, ints `M, N, K, NR, SGS, VPT`. -/
def rowsCfg (lay : LinLayout) : RCfg δ :=
  kcfg I [([R.nP, litD lay.rows], Ffi.dtBf16)] [litD 64, litD ((lay.rows + 7) / 8), litD 1] [litD 64, litD 1, litD 1]
    [(chars!"T", Ffi.dtBf16)]
    [(chars!"M", R.nP), (chars!"N", litD lay.rows), (chars!"K", litD lay.cols), (chars!"NR", litD 4),
      (chars!"SGS", litD 2), (chars!"VPT", litD 16)]

/-- affine-split-mma.ts: grid `[32·SPLITS, N/(8·TILES), ⌈r/8⌉]`, ints `N, K, BITS, TILES, SPLITS`. -/
def splitCfg (lay : LinLayout) : RCfg δ :=
  kcfg I [([R.nP, litD lay.rows], Ffi.dtBf16)]
    [litD (32 * (splitPlan lay.rows).2), litD (lay.rows / (8 * (splitPlan lay.rows).1)), R.nP.cdivF 8]
    [litD (32 * (splitPlan lay.rows).2), litD 1, litD 1] [(chars!"T", Ffi.dtBf16)]
    [(chars!"N", litD lay.rows), (chars!"K", litD lay.cols), (chars!"BITS", litD lay.bits),
      (chars!"TILES", litD (splitPlan lay.rows).1), (chars!"SPLITS", litD (splitPlan lay.rows).2)]

/-- down-mma-wide.ts `launch` at pass `(S, MT)`: grid `[128, ⌈8·nGroups/4⌉, ⌈r/(8·MT)⌉]`. -/
def downCfg (pass : DownPass) (mlay : MlpLayout) : RCfg δ :=
  kcfg I [([R.nP, litD 8, litD 5120], Ffi.dtF32)]
    [litD 128, litD ((20 * (32 / pass.s) * 8 + 3) / 4), R.nP.cdivF (8 * pass.mt)] [litD 128, litD 1, litD 1]
    [(chars!"T", Ffi.dtBf16)]
    [(chars!"R", litD 17408), (chars!"C", litD 5120), (chars!"K", litD mlay.downBits), (chars!"L", litD 12),
      (chars!"SPLITS", litD 8), (chars!"SG_TG", litD 4), (chars!"INTERLEAVE", litD (if mlay.downBits = 3 then 1 else 0)),
      (chars!"MT", litD pass.mt), (chars!"S", litD pass.s), (chars!"NW", litD (downNW pass.s mlay.downBits))]

/-- gate-up-codebook-mma.ts: grid `[128, 544, 1]`, SG_TG 4. -/
def codebookCfg (mlay : MlpLayout) : RCfg δ :=
  kcfg I [([R.nP, litD 17408], Ffi.dtBf16)] [litD 128, litD 544, litD 1] [litD 128, litD 1, litD 1]
    [(chars!"T", Ffi.dtBf16)]
    [(chars!"R", litD 17408), (chars!"C", litD 5120), (chars!"BT", litD 256), (chars!"KG", litD mlay.gateBits),
      (chars!"KU", litD mlay.upBits), (chars!"L", litD 12), (chars!"SG_TG", litD 4)]

/-- gate-up-mma-wide.ts: grid `[256, 272, ⌈r/(8·MT)⌉]`, SG_TG 8, `MT`. -/
def wideCfg (mt : Nat) (mlay : MlpLayout) : RCfg δ :=
  kcfg I [([R.nP, litD 17408], Ffi.dtBf16)] [litD 256, litD 272, R.nP.cdivF (8 * mt)] [litD 256, litD 1, litD 1]
    [(chars!"T", Ffi.dtBf16)]
    [(chars!"R", litD 17408), (chars!"C", litD 5120), (chars!"BT", litD 256), (chars!"KG", litD mlay.gateBits),
      (chars!"KU", litD mlay.upBits), (chars!"L", litD 12), (chars!"SG_TG", litD 8), (chars!"MT", litD mt)]

/-- gated.ts `launchRecurrence` (no mask) at `r` positions. -/
def gatedCfg : RCfg δ :=
  kcfg I [([litD 1, R.nP, litD 48, litD 128], Ffi.dtBf16), ([litD 1, litD 48, litD 128, litD 128], Ffi.dtF32)]
    [litD 32, litD 128, litD 48] [litD 32, litD 4, litD 1] [(chars!"InT", Ffi.dtBf16), (chars!"StT", Ffi.dtF32)]
    [(chars!"Dk", litD 128), (chars!"Dv", litD 128), (chars!"Hk", litD 16), (chars!"Hv", litD 48)]

end

/-- The projection kernels' route names. -/
def rowsName (bits : Nat) : List Char := if bits = 3 then chars!"mlx_bun_affine3_rows" else chars!"mlx_bun_affine4_rows"
def downName (bits : Nat) : List Char :=
  if bits = 3 then chars!"mlx_bun_trellis_down_k3i_mma_wide" else chars!"mlx_bun_trellis_down_mma_wide"

/-! ## Templates -/

section
variable {δ κ : Type} {m : Type → Type} [Monad m] {α : Type} (B : Backend δ κ m α) (I : PDim → δ)

def optInpT (b : Bool) (key : κ) (zp : RPrim δ κ) : m α := if b then B.inp key else B.op zp []

/-- mlx_fast_rms_norm(x, weight, 1e-6). -/
def normT (key : κ) (x : α) : m α := do
  let w ← B.inp key
  B.op (.rmsNorm eps6) [x, w]

/-- `Affine3RowsLinear`/`Affine4RowsLinear` (V23) on `x` `[1, r, K]`. -/
def rowsProjT (R : Rows) (lay : LinLayout) (key : LinKey → κ) (x : α) : m α := do
  let x2 ← B.op (.reshape [I R.nP, li I lay.cols]) [x]
  let w ← B.inp (key .w)
  let s ← B.inp (key .scales)
  let b ← B.inp (key .biases)
  let y ← B.op (.kernel (rowsName lay.bits) (rowsCfg I R lay) 0) [x2, w, s, b]
  B.op (.reshape [li I 1, I R.nP, li I lay.rows]) [y]

/-- `AffineSplitMmaLinear` (V4, V58, VW) on `x` `[1, r, K]`. -/
def splitProjT (R : Rows) (lay : LinLayout) (key : LinKey → κ) (x : α) : m α := do
  let x2 ← B.op (.reshape [I R.nP, li I lay.cols]) [x]
  let w ← B.inp (key .w)
  let s ← B.inp (key .scales)
  let b ← B.inp (key .biases)
  let y ← B.op (.kernel chars!"mlx_bun_affine_split_mma" (splitCfg I R lay) 0) [x2, w, s, b]
  B.op (.reshape [li I 1, I R.nP, li I lay.rows]) [y]

/-- The down pass, its sum over the eight partials, the bf16 cast and the
reshape (trellis-down.ts `project`), on `mid` `[1, r, 17408]`. -/
def downT (R : Rows) (pass : DownPass) (mlay : MlpLayout) (key : MlpKey → κ) (mid : α) : m α := do
  let mid2 ← B.op (.reshape [I R.nP, li I 17408]) [mid]
  let dc ← B.inp (key .downCodes)
  let ds ← B.inp (key .downScales)
  let part ← B.op (.kernel (downName mlay.downBits) (downCfg I R pass mlay) 0) [mid2, dc, ds]
  let sum ← B.op (.binary (Ffi.axisName chars!"sum_axis" 1 false)) [part]
  let y ← B.op (.astype Ffi.dtBf16) [sum]
  B.op (.reshape [li I 1, I R.nP, li I 5120]) [y]

/-- `CodebookMmaGateUp` and the one-block down pass (V23, V4, V58). -/
def codebookMlpT (R : Rows) (mlay : MlpLayout) (key : MlpKey → κ) (x : α) : m α := do
  let x2 ← B.op (.reshape [I R.nP, li I 5120]) [x]
  let gc ← B.inp (key .gateCodes)
  let gs ← B.inp (key .gateScales)
  let uc ← B.inp (key .upCodes)
  let us ← B.inp (key .upScales)
  let mid ← B.op (.kernel chars!"mlx_bun_trellis_gateup_codebook_mma" (codebookCfg I R mlay) 0) [x2, gc, gs, uc, us]
  let mid1 ← B.op (.reshape [li I 1, I R.nP, li I 17408]) [mid]
  downT B I R .oneBlock mlay key mid1

/-- `MmaGateUpWide` (`MT` its row blocks) and the planned down pass (VW); a
3-bit (K3i) down pass is always one block. -/
def wideMlpT (R : Rows) (mt : Nat) (pass : DownPass) (mlay : MlpLayout) (key : MlpKey → κ) (x : α) : m α := do
  let x2 ← B.op (.reshape [I R.nP, li I 5120]) [x]
  let gc ← B.inp (key .gateCodes)
  let gs ← B.inp (key .gateScales)
  let uc ← B.inp (key .upCodes)
  let us ← B.inp (key .upScales)
  let mid ← B.op (.kernel chars!"mlx_bun_trellis_gateup_mma_wide" (wideCfg I R mt mlay) 0) [x2, gc, gs, uc, us]
  let mid1 ← B.op (.reshape [li I 1, I R.nP, li I 17408]) [mid]
  downT B I R (if mlay.downBits = 3 then .oneBlock else pass) mlay key mid1

/-- The embedding of the prompt rows (quantized-embedding.ts): `take_axis`
of the words, scales and biases at the ids, then 4-bit dequantize. -/
def embedT (ids : κ) (key : InKey → κ) : m α := do
  let i ← B.inp ids
  let w ← B.inp (key .embedWords)
  let s ← B.inp (key .embedScales)
  let b ← B.inp (key .embedBiases)
  let rows ← B.op (.take 0) [w, i]
  let sc ← B.op (.take 0) [s, i]
  let bi ← B.op (.take 0) [b, i]
  B.op (.dequantize 64 4 chars!"affine" none) [rows, sc, bi]

variable (proj : LinLayout → (LinKey → κ) → α → m α) (mlp : MlpLayout → (MlpKey → κ) → α → m α)

/-- One gated-delta layer at `r` rows; `aux 0` is `gated_delta_step`'s `Tin`
(`[r]`). Output, new conv state, new recurrent state. -/
def deltaLayerT (R : Rows) (d : DeltaLayout) (key : SKey → κ) (aux : Nat → κ) (x : α) : m (α × α × α) := do
  let xn ← normT B (key .inputNorm) x
  let qkv ← proj d.qkv (key ∘ .lin 0) xn
  let z0 ← proj d.z (key ∘ .lin 1) xn
  let z ← B.op (.reshape [li I 1, I R.nP, li I 48, li I 128]) [z0]
  let b ← proj d.b (key ∘ .lin 3) xn
  let a ← proj d.a (key ∘ .lin 2) xn
  let conv ← optInpT B d.hasConv (key (.cache 0)) (.zeros (lis I [1, 3, 10240]) Ffi.dtBf16)
  let joined ← B.op (.concat 1) [conv, qkv]
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
  let beta ← B.op (.unary chars!"sigmoid") [b]
  let al ← B.inp (key .aLog)
  let dt ← B.inp (key .dtBias)
  let g ← B.op .computeG [al, a, dt]
  let st0 ← optInpT B d.hasRec (key (.cache 1)) (.zeros (lis I [1, 48, 128, 128]) Ffi.dtF32)
  let t ← B.inp (aux 0)
  let y ← B.op (.kernel chars!"gated_delta_step" (gatedCfg I R) 0) [q, k, v, g, beta, st0, t]
  let s ← B.op (.kernel chars!"gated_delta_step" (gatedCfg I R) 1) [q, k, v, g, beta, st0, t]
  let yn ← normT B (key .norm) y
  let gated ← B.op (closureP .preciseSwiglu) [z, yn]
  let merged ← B.op (.reshape [li I 1, I R.nP, li I 6144]) [gated]
  let mixed ← proj d.out (key ∘ .lin 4) merged
  let h ← B.op (.binary chars!"add") [x, mixed]
  let hn ← normT B (key (.mlp .norm)) h
  let mo ← mlp d.mlp (key ∘ .mlp) hn
  let out ← B.op (.binary chars!"add") [h, mo]
  pure (out, tail, s)

def kvOldT (R : Rows) (o : Nat) (b : α) : m α :=
  if o % 256 = 0 then pure b
  else B.op (.slice (D (fun i => I (.lit i)) [0, 0, 0, 0]) [li I 1, li I 4, I R.oP, li I 256]
    (D (fun i => I (.lit i)) [1, 1, 1, 1])) [b]

def kvGrownT (R : Rows) (o n c : Nat) (b : α) : m α :=
  if c < o + n then do
    let old ← kvOldT B I R o b
    let z ← B.op (.zeros [li I 1, li I 4, I (PDim.rupF 256 R.nP), li I 256] Ffi.dtBf16) []
    B.op (.concat 2) [old, z]
  else pure b

def kvGrowT (R : Rows) (o n : Nat) (cap : Option Nat) (key : κ) : m α :=
  match cap with
  | none => B.op (.zeros [li I 1, li I 4, I (PDim.rupF 256 R.nP), li I 256] Ffi.dtBf16) []
  | some c => do
    let b ← B.inp key
    kvGrownT B I R o n c b

def kvViewT (R : Rows) (o n : Nat) (cap : Option Nat) (b : α) : m α :=
  if kvCapP cap o n = o + n then pure b
  else B.op (.slice (D (fun i => I (.lit i)) [0, 0, 0, 0]) [li I 1, li I 4, I R.onP, li I 256]
    (D (fun i => I (.lit i)) [1, 1, 1, 1])) [b]

/-- kv.ts `updateAndFetch` of the rows `x` at control offset `o`, rows `n`
(`kvStepP` at any backend): grow iff null or `o + n > cap` by
`256·⌈n/256⌉` zero rows (trimming to `o` first iff `o % 256 ≠ 0`), write rows
`[o, o+n)`, view `[0, o+n)`. -/
def kvStepT (R : Rows) (o n : Nat) (cap : Option Nat) (key : κ) (x : α) : m (α × α) := do
  let grown ← kvGrowT B I R o n cap key
  let b ← B.op (.sliceUpdate [li I 0, li I 0, I R.oP, li I 0] [li I 1, li I 4, I R.onP, li I 256]
    (D (fun i => I (.lit i)) [1, 1, 1, 1])) [grown, x]
  let view ← kvViewT B I R o n cap b
  pure (b, view)

/-- The attention read on `q` `[1, 24, r, 256]`, `keys`/`values` `[1, 4, o+r, 256]`;
the folded read's host arrays are `aux 1` (the key limits) and `aux 2` (the
key positions). -/
def readT (R : Rows) (rd : Read) (aux : Nat → κ) (q keys values : α) : m α :=
  match rd with
  | .causal => B.op (.sdpa sdpaScaleWord chars!"causal") [q, keys, values]
  | .folded r => do
    let sc ← B.op (.data scaleBytes [] Ffi.dtBf16) []
    let qs ← B.op (.binary chars!"multiply") [q, sc]
    let rows ← B.op (.reshape (lis I [1, 4, 6 * r, 256])) [qs]
    let kt ← B.op (.transpose [0, 1, 3, 2]) [keys]
    let scores ← B.op (.unary chars!"matmul") [rows, kt]
    let cols ← B.inp (aux 2)
    let colRow ← B.op (.reshape [li I 1, I R.onP]) [cols]
    let limits ← B.inp (aux 1)
    let visible ← B.op (.unary chars!"less_equal") [colRow, limits]
    let ninf ← B.op (.data ninfBytes [] Ffi.dtBf16) []
    let masked ← B.op (.unary chars!"where") [visible, scores, ninf]
    let probs ← B.op (.binary (Ffi.axisName chars!"softmax" 3 true)) [masked]
    let out ← B.op (.unary chars!"matmul") [probs, values]
    B.op (.reshape (lis I [1, 24, r, 256])) [out]

/-- One attention layer at `r` rows, offset `o`: output, key and value buffers. -/
def attentionLayerT (R : Rows) (o n : Nat) (rd : Read) (a : AttnLayout) (key : SKey → κ) (aux : Nat → κ) (x : α) :
    m (α × α × α) := do
  let xn ← normT B (key .inputNorm) x
  let qp ← proj a.q (key ∘ .lin 0) xn
  let qpr ← B.op (.reshape [li I 1, I R.nP, li I 24, li I 512]) [qp]
  let qh ← B.op (.slice (lis I [0, 0, 0, 0]) [li I 1, I R.nP, li I 24, li I 256] (lis I [1, 1, 1, 1])) [qpr]
  let gh ← B.op (.slice (lis I [0, 0, 0, 256]) [li I 1, I R.nP, li I 24, li I 512] (lis I [1, 1, 1, 1])) [qpr]
  let gate ← B.op (.reshape [li I 1, I R.nP, li I 6144]) [gh]
  let kp ← proj a.k (key ∘ .lin 1) xn
  let vp ← proj a.v (key ∘ .lin 2) xn
  let qn ← normT B (key .qNorm) qh
  let qt ← B.op (.transpose [0, 2, 1, 3]) [qn]
  let kr ← B.op (.reshape [li I 1, I R.nP, li I 4, li I 256]) [kp]
  let kn ← normT B (key .kNorm) kr
  let kt ← B.op (.transpose [0, 2, 1, 3]) [kn]
  let vr ← B.op (.reshape [li I 1, I R.nP, li I 4, li I 256]) [vp]
  let vt ← B.op (.transpose [0, 2, 1, 3]) [vr]
  let qr ← B.op (.rope 64 false ropeBaseWord ropeScaleWord (I R.oP)) [qt]
  let kq ← B.op (.rope 64 false ropeBaseWord ropeScaleWord (I R.oP)) [kt]
  let (kb, keys) ← kvStepT B I R o n a.kcap (key (.cache 0)) kq
  let (vb, values) ← kvStepT B I R o n a.vcap (key (.cache 1)) vt
  let attn ← readT B I R rd aux qr keys values
  let attnT ← B.op (.transpose [0, 2, 1, 3]) [attn]
  let merged ← B.op (.reshape [li I 1, I R.nP, li I (-1)]) [attnT]
  let sig ← B.op (.unary chars!"sigmoid") [gate]
  let gated ← B.op (.binary chars!"multiply") [merged, sig]
  let mixed ← proj a.o (key ∘ .lin 3) gated
  let h ← B.op (.binary chars!"add") [x, mixed]
  let hn ← normT B (key (.mlp .norm)) h
  let mo ← mlp a.mlp (key ∘ .mlp) hn
  let out ← B.op (.binary chars!"add") [h, mo]
  pure (out, kb, vb)

end

end Host.Mlx.SimGraph

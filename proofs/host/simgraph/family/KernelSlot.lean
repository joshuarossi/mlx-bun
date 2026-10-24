import host.simgraph.family.FamilyStep
import host.simgraph.prompt.DimData
import host.mlx.ReadbackValues
import host.mlx.FfiEvalRoute
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Host.Ts Inference.Contracts.Mlx
open Host.Mlx.PrefillSources (PrefillKernel)

/-! # Where the route kernel contract slots in

The families evaluate kernel nodes through an abstract `ks : KernelSem`. At a
route kernel contract `K` (`RouteKernelContract`, host/mlx/PrefillKernels.lean)
the FFI graph's evaluation is `evalRR` (FfiEvalRoute), whose kernel nodes are
`primEvalR`; `ksR` is that semantics as a `KernelSem`.

* `rowTpl_graph_stepR`: the forward stage's graph postcondition at `evalRR`,
  the reference computation's kernels being `ksR` (`rowTpl_graph_step` with
  the prefill kernels' values), for an FFI graph none of whose kernel nodes is
  replayed (`KernelsPlain`);
* `ksR_launch`: a prefill kernel node's value is its launch, `K.applyP`;
* `prefillOf_*`, `toConfig_*`: each launch the families issue names the
  contract's kernel and resolves to the configuration the contract's field
  states (`rowsConfig`, `splitConfig`, `codebookConfig`, `wideConfig`,
  `downConfig'`, `gatedConfigT`) at the rows the valuation gives, so the field
  gives its outputs as the kernel's expected-output definition
  (proofs/metal/kernels/<Name>.lean);
* `cells_tin`: the delta layer's `Tin` input (`cells p 0 [n] [1]`) is the
  contract's `tinValue r`. -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} (env : Env κ)

/-- The route's kernel semantics: a kernel node's value in `evalRR`. -/
noncomputable def ksR : KernelSem := fun name c out xs => primEvalR P K env (.kernel name c out) xs

/-- A prefill kernel node is its launch. -/
theorem ksR_launch {name : List Char} {c : RCfg Int} {out : Nat} {xs : List Value} {k : PrefillKernel}
    {cfg : Config} (hk : prefillOf name = some k) (hc : toConfig c = some cfg) (hp : k.inPlace? = none) :
    ksR P K env name c out xs = (K.applyP k xs cfg).bind (·[out]?) := by
  show primEvalR P K env (.kernel name c out) xs = _
  rw [primEvalR_kernel P K env (primEvalP_prefill P K env hk) hk hc]
  unfold prefillLaunch
  rw [hp]
  rfl

/-- The FFI graph's kernel nodes are not replayed (no compiled closure records a kernel launch). -/
def KernelsPlain (G : Nat → Option (RNode Int κ)) : Prop :=
  ∀ j nd name c out, G j = some nd → strip nd.prim = .kernel name c out → nd.prim = .kernel name c out

theorem primsAgree_R [DecidableEq κ] (G : Nat → Option (RNode Int κ)) (hG : KernelsPlain G) :
    PrimsAgree P K.toKernelContract env (ksR P K env) G (primEvalR P K env) := by
  intro j nd q xs v hj hs hor hc hcl hp
  unfold primEvalE at hp
  split at hp
  · rw [hG j nd _ _ _ hj hs]; exact hp
  · contradiction
  · rw [hcl] at hp
    exact primEvalR_of P K env (by rw [primEvalP_strip P K.toKernelContract env nd.prim _ hs hor]; exact hp)

/-- The FFI nodes carrying `E`'s inputs hold the inputs' values (`evalRR`). -/
def InputsHeldR [DecidableEq κ] (kind : Nat → Option Compiled) (G : Nat → Option (RNode Int κ))
    (E : List (RNode Int κ)) (cert : List Nat) : Prop :=
  ∀ k e key v, E[k]? = some e → e.prim = .input key → env.inputs key = some v →
    evalRR P K env kind G (certAt cert k) = some v

end

/-! ## The graph side of a multi-row step at the route contract -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C)

theorem family_template_stepR {κ : Type} [DecidableEq κ] {F : RowFamily κ} (T : FamilyTemplate F) (ν : Nat → Int)
    (o n : Nat) (ss : List StageLayout) (hsig : List.Forall₂ (SigRelR F.ops.sig T.o₀ T.n₀ o n) T.ss₀ ss)
    (env : Env κ) (G : Nat → Option (RNode Int κ)) (σ cl : Nat → Nat) (emb : Embeds σ cl (mapG (PDim.eval ν) T.Gs) G)
    (kind' : Nat → Option Compiled) (hk : ∀ c, kind' (cl c) = T.kind c)
    (hin : InputsHeldR P K env kind' G (familyGraph F.ops (PDim.eval ν) o n ss).1 (T.cert.map σ))
    (hG : KernelsPlain G) (i : Nat) (v : Value)
    (hv : EvE P K.toKernelContract env (ksR P K env) (familyGraph F.ops (PDim.eval ν) o n ss).1 i v) :
    evalRR P K env kind' G (σ (certAt T.cert i)) = some v := by
  have hm := family_template_matches T ν o n ss hsig G σ cl emb kind' hk
  have hl := family_template_length T ν o n ss hsig
  rw [← certAt_map σ T.cert i (by have := hv.1; omega)]
  exact matches_evalG P K.toKernelContract env (ksR P K env) kind' (evalRR P K env kind') (primEvalR P K env)
    (evalRR_eq P K env kind') G _ _ hm hin (primsAgree_R P K env G hG) i hv.1 v hv.2

/-- **The forward stage's graph postcondition** for a GPU row family at the
route kernel contract: the iteration's graph carries the family's graph (from
the checked template), and when the step's reference computation (kernels
`ksR`) returns the final hidden state `out` and the layers' caches `cs`, the
carriers of the output node and of every cache node hold them in `evalRR`. -/
theorem rowTpl_graph_stepR (R : Rows) (pk : ProjKind) (mk : MlpKind) (rd : Read) (env : Env PKey)
    (T : FamilyTemplate (rowFamily R pk mk rd)) (ν : Nat → Int) (o n : Nat) (ss : List StageLayout)
    (hsig : List.Forall₂ (SigRelR kvSigP T.o₀ T.n₀ o n) T.ss₀ ss)
    (G : Nat → Option (RNode Int PKey)) (σ cl : Nat → Nat) (emb : Embeds σ cl (mapG (PDim.eval ν) T.Gs) G)
    (kind' : Nat → Option Compiled) (hk : ∀ c, kind' (cl c) = T.kind c)
    (hin : InputsHeldR P K env kind' G (familyGraph (rowTpl R pk mk rd).ops (PDim.eval ν) o n ss).1 (T.cert.map σ))
    (hG : KernelsPlain G) (out : Value) (cs : List (Value × Value))
    (hv : forwardT (rowTpl R pk mk rd) (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval ν) o n ss =
      some (out, cs)) :
    ∀ q ∈ Handle.facts (familyGraph (rowTpl R pk mk rd).ops (PDim.eval ν) o n ss).2 (out, cs),
      evalRR P K env kind' G (σ (certAt T.cert q.1)) = some q.2 := by
  intro q hq
  have hall := rowTpl_eval (P := P) (K := K.toKernelContract) (env := env) (ks := ksR P K env) R pk mk rd ν o n ss
    out cs hv
  exact family_template_stepR P K T ν o n ss hsig env G σ cl emb kind' hk hin hG q.1 q.2 (hall q hq)

end

/-! ## The families' launches: kernels and configurations -/

theorem prefillOf_rowsName (bits : Nat) :
    prefillOf (rowsName bits) = some (if bits = 3 then .affine3Rows else .affine4Rows) := by
  unfold rowsName
  by_cases h : bits = 3
  · rw [ite_eq_left h, ite_eq_left h]; exact prefillOf_self .affine3Rows
  · rw [ite_eq_right h, ite_eq_right h]; exact prefillOf_self .affine4Rows

theorem prefillOf_split : prefillOf chars!"mlx_bun_affine_split_mma" = some .affineSplitMma :=
  prefillOf_self .affineSplitMma

theorem prefillOf_codebook : prefillOf chars!"mlx_bun_trellis_gateup_codebook_mma" = some .gateUpCodebookMma :=
  prefillOf_self .gateUpCodebookMma

theorem prefillOf_wide : prefillOf chars!"mlx_bun_trellis_gateup_mma_wide" = some .gateUpMmaWide :=
  prefillOf_self .gateUpMmaWide

theorem prefillOf_downName (bits : Nat) :
    prefillOf (downName bits) = some (if bits = 3 then .downK3iMmaWide else .downMmaWide) := by
  unfold downName
  by_cases h : bits = 3
  · rw [ite_eq_left h, ite_eq_left h]; exact prefillOf_self .downK3iMmaWide
  · rw [ite_eq_right h, ite_eq_right h]; exact prefillOf_self .downMmaWide

section
variable (ν : Nat → Int) (R : Rows) (r : Nat) (hr : R.nP.eval ν = r)
include hr

theorem cdivF_eval (k : Nat) (hk : 0 < k) : (R.nP.cdivF k).eval ν = (((r + k - 1) / k : Nat) : Int) := by
  rw [PDim.eval_cdivF]
  simp only [PDim.eval, ceilDiv, hr]
  rw [show (r : Int) + (k : Int) - 1 = ((r + k - 1 : Nat) : Int) by omega, Int.natCast_ediv]

theorem toConfig_rows (lay : LinLayout) :
    toConfig (rowsCfg (PDim.eval ν) R lay) = some (rowsConfig r lay.rows lay.cols) := by
  simp [toConfig, rowsCfg, kcfg, outOf, natShape, triple?, nat?, dtOf, intOf, initOf, PDim.eval, litD, hr,
    Dtype.ofCode, Ffi.dtBf16, rowsConfig]
  rfl

theorem toConfig_split (lay : LinLayout) :
    toConfig (splitCfg (PDim.eval ν) R lay) = some (splitConfig r lay.rows lay.cols lay.bits) := by
  simp [toConfig, splitCfg, kcfg, outOf, natShape, triple?, nat?, dtOf, intOf, initOf, PDim.eval, litD, hr,
    cdivF_eval ν R r hr 8 (by decide), Dtype.ofCode, Ffi.dtBf16, splitConfig, splitPlan, Host.Mlx.splitPlan]
  rfl

theorem toConfig_codebook (mlay : MlpLayout) :
    toConfig (codebookCfg (PDim.eval ν) R mlay) = some (codebookConfig r mlay.gateBits mlay.upBits) := by
  simp [toConfig, codebookCfg, kcfg, outOf, natShape, triple?, nat?, dtOf, intOf, initOf, PDim.eval, litD, hr,
    Dtype.ofCode, Ffi.dtBf16, codebookConfig]

/-- The wide gate-up at `MT` its row blocks (gate-up-mma-wide.ts `rowBlocks`). -/
theorem toConfig_wide (mt : Nat) (hmt : mt = Metal.Kernels.GateUpMmaWide.rowBlocks r) (mlay : MlpLayout) :
    toConfig (wideCfg (PDim.eval ν) R mt mlay) = some (wideConfig r mlay.gateBits mlay.upBits) := by
  have hpos : 0 < mt := by
    rw [hmt]; unfold Metal.Kernels.GateUpMmaWide.rowBlocks; split <;> omega
  rw [wideConfig, ← hmt]
  simp [toConfig, wideCfg, kcfg, outOf, natShape, triple?, nat?, dtOf, intOf, initOf, PDim.eval, litD, hr,
    cdivF_eval ν R r hr (8 * mt) (by omega), Dtype.ofCode, Ffi.dtBf16, Metal.ceilDiv]
  rfl

/-- The down pass at code width `downBits`; the 3-bit pass reads the block interleave. -/
theorem toConfig_down (pass : DownPass) (hmt : 0 < pass.mt) (mlay : MlpLayout) :
    toConfig (downCfg (PDim.eval ν) R pass mlay) =
      some (downConfig' r mlay.downBits pass.s pass.mt (if mlay.downBits = 3 then 1 else 0)) := by
  have e1 : ((20 : Int) * (32 / (pass.s : Int)) * 8 + 3) / 4 = (((20 * (32 / pass.s) * 8 + 3) / 4 : Nat) : Int) := by
    norm_cast
  have hw : ∀ k s, downWords k s = downNW s k := fun _ _ => rfl
  simp only [downCfg, e1]
  by_cases hb : mlay.downBits = 3 <;>
  simp [hb, toConfig, kcfg, outOf, natShape, triple?, nat?, dtOf, intOf, initOf, PDim.eval, litD, hr,
    cdivF_eval ν R r hr (8 * pass.mt) (by omega), Dtype.ofCode, Ffi.dtBf16, Ffi.dtF32, downConfig', Metal.ceilDiv,
    hw, -Int.natCast_ediv]

theorem toConfig_gated : toConfig (gatedCfg (PDim.eval ν) R) = some (gatedConfigT r) := by
  simp [toConfig, gatedCfg, kcfg, outOf, natShape, triple?, nat?, dtOf, intOf, initOf, PDim.eval, litD, hr,
    Dtype.ofCode, Ffi.dtBf16, Ffi.dtF32, gatedConfigT]

end

/-! ## Gated delta's `Tin` -/

theorem cells_tin (T : Nat) (h : T < 2 ^ 32) : cellsValue [(T : Int)] [1] = some (tinValue T) := by
  have hm : F64.modNat (T : Int) (2 ^ 32) = T := by
    simp only [F64.modNat]
    rw [Int.emod_eq_of_lt (by omega) (by omega)]
    rfl
  show dataValue (cellsBytes [(T : Int)]) [1] Ffi.dtInt32 = _
  simp only [cellsBytes, List.flatMap_cons, List.flatMap_nil, List.append_nil, i32Bytes, hm]
  change some (⟨.int32, [1], fun i => leWord (leBytes 4 T) 4 (i % 1)⟩ : Value) = _
  simp only [Nat.mod_one, leWord_u32 T h, tinValue]

end Host.Mlx.SimGraph

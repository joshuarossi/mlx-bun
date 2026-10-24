import host.simgraph.family.KernelSlot
import host.simgraph.mach.PreOps
import host.simgraph.mach.TotalKernels
namespace Host.Mlx.SimGraph.Mach
open Inference Inference.Contracts.Mlx Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Mlx.PrefillSources (PrefillKernel)

/-! # The prefill kernels are defined on well-typed arguments

A GPU row family's kernel node is `ksR P K env` (the route evaluation's kernel semantics): a prefill kernel's
launch `K.applyP` at the configuration the node resolves to (`toConfig_*`), gated_delta_step through
`K.apply`. Every `RouteKernelContract` field the families launch states its outputs (`readOutput` of the
kernel's expected bytes, at the configuration's dtype and shape) for typed arguments at the route's
instances (`Rows3Route`, `Rows4Route`, `SplitRoute`, `GateUpRoute`, `DownRoute`, the row ranges), so each
launch is defined and typed there. -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} (env : Env κ)
  (ν : Nat → Int) (R : Rows) (r : Nat) (hr : R.nP.eval ν = r)

/-- A kernel node of the value instance is the kernel semantics. -/
theorem primEvalE_kernel (ks : KernelSem) (name : List Char) (c : RCfg Int) (out : Nat) (xs : List Value) :
    primEvalE P K.toKernelContract env ks (.kernel name c out) xs = ks name c out xs := rfl

/-- A prefill kernel's launch whose contract field gives its outputs: the output `out` is typed. -/
theorem ok_prefillLaunch {name : List Char} {c : RCfg Int} {k : PrefillKernel} {cfg : Config} {xs : List Value}
    {B : ByteMemory.Bytes} {sh : List Nat} {d : Dtype} (hk : prefillOf name = some k) (hc : toConfig c = some cfg)
    (hp : k.inPlace? = none) (ha : K.applyP k xs cfg = some [KernelGpu.readOutput B (sh, d)]) :
    OkV (primEvalE P K.toKernelContract env (ksR P K env) (.kernel name c 0) xs) (fun u => Ty u d sh) := by
  rw [primEvalE_kernel, ksR_launch P K env hk hc hp, ha]
  exact ⟨_, rfl, readOutput_ty _ _ _⟩

include hr

/-- `affine{3,4}_rows` (V23) on `x` `[r, K]`. -/
theorem ok_rowsKernel (lay : LinLayout) {x w s b : Value} (hbits : lay.bits = 3 ∨ lay.bits = 4)
    (route : if lay.bits = 3 then Rows3Route r lay.rows lay.cols else Rows4Route r lay.rows lay.cols)
    (hx : Ty x .bfloat16 [r, lay.cols]) (hw : Ty w .uint32 [lay.rows, lay.cols * lay.bits / 32])
    (hs : Ty s .bfloat16 [lay.rows, lay.cols / 64]) (hb : Ty b .bfloat16 [lay.rows, lay.cols / 64]) :
    OkV (primEvalE P K.toKernelContract env (ksR P K env) (.kernel (rowsName lay.bits) (rowsCfg (PDim.eval ν) R lay) 0)
      [x, w, s, b]) (fun u => Ty u .bfloat16 [r, lay.rows]) := by
  have hc := toConfig_rows ν R r hr lay
  rcases hbits with h3 | h4
  · rw [ite_eq_left h3] at route
    have hk : prefillOf (rowsName lay.bits) = some .affine3Rows := by rw [prefillOf_rowsName, ite_eq_left h3]
    rw [h3] at hw
    exact ok_prefillLaunch P K env hk hc rfl (K.affine3Rows x w s b route hx hw hs hb)
  · rw [ite_eq_right (by omega)] at route
    have hk : prefillOf (rowsName lay.bits) = some .affine4Rows := by rw [prefillOf_rowsName, ite_eq_right (by omega)]
    rw [h4, show lay.cols * 4 / 32 = lay.cols / 8 by omega] at hw
    exact ok_prefillLaunch P K env hk hc rfl (K.affine4Rows x w s b route hx hw hs hb)

/-- `affine_split_mma` (V4, V58, VW) on `x` `[r, K]`, `4 ≤ r ≤ 223`. -/
theorem ok_splitKernel (lay : LinLayout) {x w s b : Value} (route : SplitRoute lay.rows lay.cols lay.bits)
    (h4 : 4 ≤ r) (h223 : r ≤ 223) (hx : Ty x .bfloat16 [r, lay.cols])
    (hw : Ty w .uint32 [lay.rows, lay.cols * lay.bits / 32]) (hs : Ty s .bfloat16 [lay.rows, lay.cols / 64])
    (hb : Ty b .bfloat16 [lay.rows, lay.cols / 64]) :
    OkV (primEvalE P K.toKernelContract env (ksR P K env)
      (.kernel chars!"mlx_bun_affine_split_mma" (splitCfg (PDim.eval ν) R lay) 0) [x, w, s, b])
      (fun u => Ty u .bfloat16 [r, lay.rows]) :=
  ok_prefillLaunch P K env prefillOf_split (toConfig_split ν R r hr lay) rfl
    (K.affineSplitMma x w s b route h4 h223 hx hw hs hb)

/-- The codebook gate-up (V23, V4, V58) on `x` `[r, 5120]`, `2 ≤ r ≤ 8`. -/
theorem ok_codebookKernel (mlay : MlpLayout) {x gc gs uc us : Value} (route : GateUpRoute mlay.gateBits mlay.upBits)
    (h2 : 2 ≤ r) (h8 : r ≤ 8) (hx : Ty x .bfloat16 [r, 5120]) (hgc : Ty gc .uint32 [17408, 160 * mlay.gateBits])
    (hgs : Ty gs .float16 [17408]) (huc : Ty uc .uint32 [17408, 160 * mlay.upBits]) (hus : Ty us .float16 [17408]) :
    OkV (primEvalE P K.toKernelContract env (ksR P K env)
      (.kernel chars!"mlx_bun_trellis_gateup_codebook_mma" (codebookCfg (PDim.eval ν) R mlay) 0) [x, gc, gs, uc, us])
      (fun u => Ty u .bfloat16 [r, 17408]) :=
  ok_prefillLaunch P K env prefillOf_codebook (toConfig_codebook ν R r hr mlay) rfl
    (K.gateUpCodebookMma x gc gs uc us route h2 h8 hx hgc hgs huc hus)

/-- The wide gate-up (VW) on `x` `[r, 5120]`, `9 ≤ r ≤ 223`, `MT` its row blocks. -/
theorem ok_wideKernel (mt : Nat) (hmt : mt = Metal.Kernels.GateUpMmaWide.rowBlocks r) (mlay : MlpLayout)
    {x gc gs uc us : Value} (route : GateUpRoute mlay.gateBits mlay.upBits) (h9 : 9 ≤ r) (h223 : r ≤ 223)
    (hx : Ty x .bfloat16 [r, 5120]) (hgc : Ty gc .uint32 [17408, 160 * mlay.gateBits]) (hgs : Ty gs .float16 [17408])
    (huc : Ty uc .uint32 [17408, 160 * mlay.upBits]) (hus : Ty us .float16 [17408]) :
    OkV (primEvalE P K.toKernelContract env (ksR P K env)
      (.kernel chars!"mlx_bun_trellis_gateup_mma_wide" (wideCfg (PDim.eval ν) R mt mlay) 0) [x, gc, gs, uc, us])
      (fun u => Ty u .bfloat16 [r, 17408]) :=
  ok_prefillLaunch P K env prefillOf_wide (toConfig_wide ν R r hr mt hmt mlay) rfl
    (K.gateUpMmaWide x gc gs uc us route h9 h223 hx hgc hgs huc hus)

/-- The down pass on `mid` `[r, 17408]`, `2 ≤ r ≤ 223`: row-major at width 2 or 4 (a `DownRoute` pass), or the
3-bit block interleave in one block. -/
theorem ok_downKernel (pass : DownPass) (mlay : MlpLayout) {x dc ds : Value} (h2 : 2 ≤ r) (h223 : r ≤ 223)
    (hpass : mlay.downBits = 3 → pass = .oneBlock) (route : mlay.downBits ≠ 3 → DownRoute mlay.downBits pass.s pass.mt)
    (hx : Ty x .bfloat16 [r, 17408])
    (hdc : Ty dc .uint32 (if mlay.downBits = 3 then [10, 17408, 48] else [17408, 160 * mlay.downBits]))
    (hds : Ty ds .float16 [17408]) :
    OkV (primEvalE P K.toKernelContract env (ksR P K env)
      (.kernel (downName mlay.downBits) (downCfg (PDim.eval ν) R pass mlay) 0) [x, dc, ds])
      (fun u => Ty u .float32 [r, 8, 5120]) := by
  by_cases h3 : mlay.downBits = 3
  · have hp := hpass h3
    subst hp
    have hc := toConfig_down ν R r hr .oneBlock (by decide) mlay
    rw [ite_eq_left h3] at hc hdc
    rw [show DownPass.oneBlock.s = 16 from rfl, show DownPass.oneBlock.mt = 1 from rfl, h3] at hc
    have hk : prefillOf (downName mlay.downBits) = some .downK3iMmaWide := by rw [prefillOf_downName, ite_eq_left h3]
    exact ok_prefillLaunch P K env hk hc rfl (K.downK3iMmaWide x dc ds h2 h223 hx hdc hds)
  · have hrt := route h3
    have hmt : 0 < pass.mt := by
      unfold DownRoute at hrt
      simp only [List.mem_cons, Prod.mk.injEq, List.not_mem_nil, or_false] at hrt
      omega
    have hc := toConfig_down ν R r hr pass hmt mlay
    rw [ite_eq_right h3] at hc hdc
    have hk : prefillOf (downName mlay.downBits) = some .downMmaWide := by rw [prefillOf_downName, ite_eq_right h3]
    exact ok_prefillLaunch P K env hk hc rfl (K.downMmaWide x dc ds hrt h2 h223 hx hdc hds)

/-- gated_delta_step on `r` positions (`2 ≤ r ≤ 2048`): output 0 the `[1, r, 48, 128]` bf16 rows, output 1 the
`[1, 48, 128, 128]` float32 state. -/
theorem ok_gatedKernel (out : Nat) (hout : out = 0 ∨ out = 1) {q k v g beta s : Value} (h2 : 2 ≤ r) (h2048 : r ≤ 2048)
    (hq : Ty q .bfloat16 [1, r, 16, 128]) (hk : Ty k .bfloat16 [1, r, 16, 128]) (hv : Ty v .bfloat16 [1, r, 48, 128])
    (hg : Ty g .float32 [1, r, 48]) (hb : Ty beta .bfloat16 [1, r, 48]) (hs : Ty s .float32 [1, 48, 128, 128]) :
    OkV (primEvalE P K.toKernelContract env (ksR P K env) (.kernel chars!"gated_delta_step" (gatedCfg (PDim.eval ν) R) out)
      [q, k, v, g, beta, s, tinValue r])
      (fun u => if out = 0 then Ty u .bfloat16 [1, r, 48, 128] else Ty u .float32 [1, 48, 128, 128]) := by
  rw [primEvalE_kernel]
  have ha := K.gatedDeltaSteps q k v g beta s h2 h2048 hq hk hv hg hb hs
  have e : ∀ o, primEval P.toMlxContract K.toKernelContract env
      (.kernel chars!"gated_delta_step" (gatedCfg (PDim.eval ν) R) o) [q, k, v, g, beta, s, tinValue r] =
      (K.apply .gatedDeltaStep [q, k, v, g, beta, s, tinValue r] (gatedConfigT r)).bind (·[o]?) := by
    intro o
    show ((kernelOf chars!"gated_delta_step").bind fun kk => (toConfig (gatedCfg (PDim.eval ν) R)).bind fun cfg =>
      (K.apply kk [q, k, v, g, beta, s, tinValue r] cfg).bind fun ys => ys[o]?) = _
    rw [show kernelOf chars!"gated_delta_step" = some .gatedDeltaStep from rfl, Option.bind_some,
      toConfig_gated ν R r hr, Option.bind_some]
  rw [ha] at e
  rcases hout with rfl | rfl
  · have h0 : primEval P.toMlxContract K.toKernelContract env
        (.kernel chars!"gated_delta_step" (gatedCfg (PDim.eval ν) R) 0) [q, k, v, g, beta, s, tinValue r] =
        some (KernelGpu.readOutput (Metal.Kernels.GatedDeltaStep.bytes2 (12288 * r)
          (Metal.Kernels.GatedDeltaSteps.ySteps C K.deltaFusion (deltaIns q k v g beta s r))) ([1, r, 48, 128], .bfloat16)) := by
      rw [e]; rfl
    exact ⟨_, primEvalR_of P K env (primEvalP_some P K.toKernelContract env h0), readOutput_ty _ _ _⟩
  · have h1 : primEval P.toMlxContract K.toKernelContract env
        (.kernel chars!"gated_delta_step" (gatedCfg (PDim.eval ν) R) 1) [q, k, v, g, beta, s, tinValue r] =
        some (KernelGpu.readOutput (Metal.Kernels.GatedDeltaStep.bytes4 3145728
          (Metal.Kernels.GatedDeltaStep.stateOut C K.deltaFusion
            (Metal.Kernels.GatedDeltaSteps.stepAt C K.deltaFusion (deltaIns q k v g beta s r) (r - 1))))
          ([1, 48, 128, 128], .float32)) := by
      rw [e]; rfl
    exact ⟨_, primEvalR_of P K env (primEvalP_some P K.toKernelContract env h1), readOutput_ty _ _ _⟩

end

end Host.Mlx.SimGraph.Mach

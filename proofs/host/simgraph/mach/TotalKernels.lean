import host.mlx.KernelGpu
import host.simgraph.mach.TotalOps
import host.simgraph.mach.TotalArgmax
set_option maxRecDepth 100000
namespace Host.Mlx.SimGraph.Mach
open Metal Inference Inference.Contracts.Mlx Inference.Kernels Host.Mlx Host.Mlx.KernelGpu

/-! # The decode kernels are defined on well-typed arguments, under the GPU assumption

`KernelContract`'s decode fields give a launch's result only under the model's finiteness certificates; at the
machine level nothing bounds the arguments. The GPU assumption does: each kernel's Metal source runs to its
expected output bytes on any input bytes (`Metal.Kernels.*.gpu_output`), so MLX's launch run by `G`
(`KernelGpu.apply G`, the `apply` of `ofGpu G P`) is defined on arguments of the launch's dtypes and shapes and
returns the configuration's outputs (`Ty` of `readOutput`). The threadgroup limits are `RoutePipelines`'. -/

variable {C : M1Max.Contract} (G : Gpu C)

theorem readOutput_ty (B : ByteMemory.Bytes) (sh : List Nat) (d : Dtype) : Ty (readOutput B (sh, d)) d sh := ⟨rfl, rfl⟩

theorem heads_ty (P : RoutePipelines G) {x qs ks : Value} (hx : Ty x .bfloat16 [1, 1, 10240])
    (hq : Ty qs .bfloat16 [128]) (hk : Ty ks .bfloat16 [128]) :
    ∃ q k v, apply G .siluRmsHeads [x, qs, ks] headsConfig = some [q, k, v] ∧ Ty q .bfloat16 [1, 1, 16, 128] ∧
      Ty k .bfloat16 [1, 1, 16, 128] ∧ Ty v .bfloat16 [1, 1, 48, 128] := by
  have he := Metal.Kernels.SiluRmsHeads.gpu_output C G P.siluRmsHeads x.storageByte qs.storageByte ks.storageByte
    16 16 16 (by decide) (by decide) (by decide)
  have ht : launchText .siluRmsHeads [x, qs, ks] headsConfig = some Metal.Elab.Tests.siluRmsHeadsText := by
    show Assemble.Tests.launch .siluRmsHeads chars!"mlx_bun_silu_rms_heads"
      [⟨chars!"x", x.dtype, x.shape⟩, ⟨chars!"qscale", qs.dtype, qs.shape⟩, ⟨chars!"kscale", ks.dtype, ks.shape⟩]
      [chars!"q", chars!"k", chars!"v"] headsConfig = _
    rw [hx.1, hx.2, hq.1, hq.2, hk.1, hk.2]
    exact Assemble.Tests.siluRmsHeads_assemble
  have hb : [x, qs, ks].map buffer =
      [⟨.device, 20480, 16, x.storageByte⟩, ⟨.device, 256, 16, qs.storageByte⟩, ⟨.device, 256, 16, ks.storageByte⟩] := by
    show [buffer x, buffer qs, buffer ks] = _
    rw [buffer_of hx.1 hx.2, buffer_of hq.1 hq.2, buffer_of hk.1 hk.2]
    rfl
  exact ⟨_, _, _, apply_some G rfl rfl ht (by rw [hb]; exact he) rfl, readOutput_ty _ _ _, readOutput_ty _ _ _,
    readOutput_ty _ _ _⟩

theorem gatedNorm_ty (P : RoutePipelines G) {xv gv wv : Value} (hx : Ty xv .bfloat16 [1, 1, 48, 128])
    (hg : Ty gv .bfloat16 [1, 1, 48, 128]) (hw : Ty wv .bfloat16 [128]) :
    ∃ out, apply G .gatedRmsNorm [xv, gv, wv] gatedNormConfig = some [out] ∧ Ty out .bfloat16 [1, 1, 48, 128] := by
  have he := Metal.Kernels.GatedRmsNorm.gpu_output C G P.gatedRmsNorm xv.storageByte gv.storageByte wv.storageByte
    16 16 16 (by decide) (by decide) (by decide)
  have ht : launchText .gatedRmsNorm [xv, gv, wv] gatedNormConfig = some Metal.Elab.Tests.gatedRmsNormText := by
    show Assemble.Tests.launch .gatedRmsNorm chars!"mlx_bun_gated_rms_norm"
      [⟨chars!"x", xv.dtype, xv.shape⟩, ⟨chars!"gate", gv.dtype, gv.shape⟩, ⟨chars!"weight", wv.dtype, wv.shape⟩]
      [chars!"out"] gatedNormConfig = _
    rw [hx.1, hx.2, hg.1, hg.2, hw.1, hw.2]
    exact Assemble.Tests.gatedRmsNorm_assemble
  have hb : [xv, gv, wv].map buffer =
      [⟨.device, 12288, 16, xv.storageByte⟩, ⟨.device, 12288, 16, gv.storageByte⟩, ⟨.device, 256, 16, wv.storageByte⟩] := by
    show [buffer xv, buffer gv, buffer wv] = _
    rw [buffer_of hx.1 hx.2, buffer_of hg.1 hg.2, buffer_of hw.1 hw.2]
    rfl
  exact ⟨_, apply_some G rfl rfl ht (by rw [hb]; exact he) rfl, readOutput_ty _ _ _⟩

theorem residualNorm_ty (P : RoutePipelines G) {xv uv wv : Value} (hx : Ty xv .bfloat16 [1, 1, 5120])
    (hu : Ty uv .bfloat16 [1, 1, 5120]) (hw : Ty wv .bfloat16 [5120]) :
    ∃ h n, apply G .residualRmsNorm [xv, uv, wv] residualConfig = some [h, n] ∧ Ty h .bfloat16 [1, 1, 5120] ∧
      Ty n .bfloat16 [1, 1, 5120] := by
  have he := Metal.Kernels.ResidualRmsNorm.gpu_output C G P.residualRmsNorm xv.storageByte uv.storageByte
    wv.storageByte 16 16 16 (by decide) (by decide) (by decide)
  have ht : launchText .residualRmsNorm [xv, uv, wv] residualConfig = some Metal.Elab.Tests.residualRmsNormText := by
    show Assemble.Tests.launch .residualRmsNorm chars!"mlx_bun_residual_rms_norm"
      [⟨chars!"x", xv.dtype, xv.shape⟩, ⟨chars!"update", uv.dtype, uv.shape⟩, ⟨chars!"weight", wv.dtype, wv.shape⟩]
      [chars!"residual", chars!"normalized"] residualConfig = _
    rw [hx.1, hx.2, hu.1, hu.2, hw.1, hw.2]
    exact Assemble.Tests.residualRmsNorm_assemble
  have hb : [xv, uv, wv].map buffer =
      [⟨.device, 10240, 16, xv.storageByte⟩, ⟨.device, 10240, 16, uv.storageByte⟩, ⟨.device, 10240, 16, wv.storageByte⟩] := by
    show [buffer xv, buffer uv, buffer wv] = _
    rw [buffer_of hx.1 hx.2, buffer_of hu.1 hu.2, buffer_of hw.1 hw.2]
    rfl
  exact ⟨_, _, apply_some G rfl rfl ht (by rw [hb]; exact he) rfl, readOutput_ty _ _ _, readOutput_ty _ _ _⟩

theorem gatedDelta_ty (P : RoutePipelines G) {q k v g beta s : Value} (hq : Ty q .bfloat16 [1, 1, 16, 128])
    (hk : Ty k .bfloat16 [1, 1, 16, 128]) (hv : Ty v .bfloat16 [1, 1, 48, 128]) (hg : Ty g .float32 [1, 1, 48])
    (hb : Ty beta .bfloat16 [1, 1, 48]) (hs : Ty s .float32 [1, 48, 128, 128]) :
    ∃ y s', apply G .gatedDeltaStep [q, k, v, g, beta, s, ⟨.int32, [1], fun _ => 1⟩] gatedConfig = some [y, s'] ∧
      Ty y .bfloat16 [1, 1, 48, 128] ∧ Ty s' .float32 [1, 48, 128, 128] := by
  let T : Value := ⟨.int32, [1], fun _ => 1⟩
  have hT : T.storageByte 0 = 1 ∧ T.storageByte 1 = 0 ∧ T.storageByte 2 = 0 ∧ T.storageByte 3 = 0 := by decide
  have he := Metal.Kernels.GatedDeltaStep.gpu_output C G P.gatedDeltaStep q.storageByte k.storageByte v.storageByte
    g.storageByte beta.storageByte s.storageByte T.storageByte 16 16 16 16 16 16 16 (by decide) (by decide) (by decide)
    (by decide) (by decide) (by decide) (by decide) hT
  have ht : launchText .gatedDeltaStep [q, k, v, g, beta, s, T] gatedConfig = some Metal.Elab.Tests.gatedDeltaStepText := by
    show Assemble.Tests.launch .gatedDeltaStep chars!"gated_delta_step"
      [⟨chars!"q", q.dtype, q.shape⟩, ⟨chars!"k", k.dtype, k.shape⟩, ⟨chars!"v", v.dtype, v.shape⟩,
        ⟨chars!"g", g.dtype, g.shape⟩, ⟨chars!"beta", beta.dtype, beta.shape⟩, ⟨chars!"state_in", s.dtype, s.shape⟩,
        ⟨chars!"Tin", .int32, [1]⟩] [chars!"y", chars!"state_out"] gatedConfig = _
    rw [hq.1, hq.2, hk.1, hk.2, hv.1, hv.2, hg.1, hg.2, hb.1, hb.2, hs.1, hs.2]
    exact Assemble.Tests.gatedDeltaStep_assemble
  have hbuf : [q, k, v, g, beta, s, T].map buffer =
      [⟨.device, 4096, 16, q.storageByte⟩, ⟨.device, 4096, 16, k.storageByte⟩, ⟨.device, 12288, 16, v.storageByte⟩,
        ⟨.device, 192, 16, g.storageByte⟩, ⟨.device, 96, 16, beta.storageByte⟩, ⟨.device, 3145728, 16, s.storageByte⟩,
        ⟨.constant, 4, 16, T.storageByte⟩] := by
    show [buffer q, buffer k, buffer v, buffer g, buffer beta, buffer s, buffer T] = _
    rw [buffer_of hq.1 hq.2, buffer_of hk.1 hk.2, buffer_of hv.1 hv.2, buffer_of hg.1 hg.2,
      buffer_of hb.1 hb.2, buffer_of hs.1 hs.2, buffer_of (v := T) rfl rfl]
    rfl
  exact ⟨_, _, apply_some G rfl rfl ht (by rw [hbuf]; exact he) rfl, readOutput_ty _ _ _, readOutput_ty _ _ _⟩

theorem downFold_ty (P : RoutePipelines G) {part : Value} (hp : Ty part .float32 [1, 32, 5120]) :
    ∃ out, apply G .downFold [part] foldConfig = some [out] ∧ Ty out .bfloat16 [1, 5120] := by
  have he := Metal.Kernels.DownFold.gpu_output C G P.downFold part.storageByte
  have hb : [part].map buffer = [⟨.device, 655360, 16, part.storageByte⟩] := by
    show [buffer part] = _
    rw [buffer_device (n := 655360) hp.1 hp.2 (by decide) (by decide)]
  have ht : launchText .downFold [part] foldConfig = some Metal.Elab.Tests.downFoldText := by
    show Assemble.Tests.launch .downFold chars!"mlx_bun_trellis_down_codebook_fold"
      [⟨chars!"partial", part.dtype, part.shape⟩] [chars!"out"] foldConfig = _
    rw [hp.1, hp.2]
    exact Assemble.Tests.downFold_assemble
  exact ⟨_, apply_some G rfl rfl ht (by rw [hb]; exact he) rfl, readOutput_ty _ _ _⟩

theorem argmax_ty (P : RoutePipelines G) {l s : Value} (hl : Ty l .bfloat16 [1, 248320]) (hs : Ty s .bfloat16 [1, 1]) :
    ∃ values indices token, apply G .argmaxPartial [l, s] partialConfig = some [values, indices] ∧
      apply G .argmaxFinish [values, indices] finishConfig = some [token] ∧ Ty token .uint32 [1] ∧
      token.elems 0 < 248320 := by
  have hP := Metal.Kernels.ArgmaxPartial.gpu_output C G P.argmaxPartial l.storageByte s.storageByte 16 16
    (by decide) (by decide)
  have ht : launchText .argmaxPartial [l, s] partialConfig = some Metal.Elab.Tests.argmaxPartialText := by
    show Assemble.Tests.launch .argmaxPartial chars!"normalized_argmax_partial"
      [⟨chars!"logits", l.dtype, l.shape⟩, ⟨chars!"lse", s.dtype, s.shape⟩] [chars!"values", chars!"indices"]
      partialConfig = _
    rw [hl.1, hl.2, hs.1, hs.2]
    exact Assemble.Tests.argmaxPartial_assemble
  have hb : [l, s].map buffer = [⟨.device, 496640, 16, l.storageByte⟩, ⟨.constant, 2, 16, s.storageByte⟩] := by
    show [buffer l, buffer s] = _
    rw [buffer_of hl.1 hl.2, buffer_of hs.1 hs.2]
    rfl
  let values := readOutput (Metal.Kernels.ArgmaxPartial.values C l.storageByte s.storageByte) ([1, 243], .float32)
  let indices := readOutput (Metal.Kernels.ArgmaxPartial.indices C l.storageByte s.storageByte) ([1, 243], .uint32)
  have hF := Metal.Kernels.ArgmaxFinish.gpu_output C G P.argmaxFinish
    (Metal.Kernels.ArgmaxPartial.values C l.storageByte s.storageByte)
    (Metal.Kernels.ArgmaxPartial.indices C l.storageByte s.storageByte) 16 16 (by decide) (by decide)
  have htF : launchText .argmaxFinish [values, indices] finishConfig = some Metal.Elab.Tests.argmaxFinishText :=
    Assemble.Tests.argmaxFinish_assemble
  have hbF : [values, indices].map buffer =
      [⟨.device, 972, 16, Metal.Kernels.ArgmaxPartial.values C l.storageByte s.storageByte⟩,
        ⟨.device, 972, 16, Metal.Kernels.ArgmaxPartial.indices C l.storageByte s.storageByte⟩] := by
    show [buffer values, buffer indices] = _
    rw [buffer_of (v := values) rfl rfl, buffer_of (v := indices) rfl rfl,
      readOutput_storage_word _ _ .float32 rfl, readOutput_storage_word _ _ .uint32 rfl]
    rfl
  exact ⟨values, indices, _, apply_some G rfl rfl ht (by rw [hb]; exact hP) rfl,
    apply_some G rfl rfl htF (by rw [hbF]; exact hF) rfl, readOutput_ty _ _ _, token_lt C l.storageByte s.storageByte⟩

/-- The gate-up launch at gate and up widths in `2 … 4`. -/
theorem gateUp_ty (P : RoutePipelines G) {kg ku : Nat} (hg : kg = 2 ∨ kg = 3 ∨ kg = 4) (hu : ku = 2 ∨ ku = 3 ∨ ku = 4)
    {x gc gs uc us : Value} (hx : Ty x .bfloat16 [1, 5120]) (hgc : Ty gc .uint32 [17408, 160 * kg])
    (hgs : Ty gs .float16 [17408]) (huc : Ty uc .uint32 [17408, 160 * ku]) (hus : Ty us .float16 [17408]) :
    ∃ mid, apply G .gateUp [x, gc, gs, uc, us] (gateUpConfig kg ku) = some [mid] ∧ Ty mid .bfloat16 [1, 17408] := by
  have e1 := Metal.Kernels.GateUp.gpu_output_of C _ _ _ (Metal.Bridge.Trellis.width_of hg)
    (Metal.Bridge.Trellis.width_of hu) _ (gateUp_compiles hg hu) G (P.gateUp hg hu) x.storageByte gc.storageByte
    gs.storageByte uc.storageByte us.storageByte 16 16 16 16 16 (by decide) (by decide) (by decide) (by decide) (by decide)
  have ht : launchText .gateUp [x, gc, gs, uc, us] (gateUpConfig kg ku) = some (Metal.Kernels.GateUp.text kg ku) := by
    show Assemble.Tests.launch .gateUp (kernelName .gateUp)
      [⟨chars!"x", x.dtype, x.shape⟩, ⟨chars!"gcodes", gc.dtype, gc.shape⟩, ⟨chars!"gscales", gs.dtype, gs.shape⟩,
        ⟨chars!"ucodes", uc.dtype, uc.shape⟩, ⟨chars!"uscales", us.dtype, us.shape⟩] (outputNames .gateUp) _ = _
    rw [hx.1, hx.2, hgc.1, hgc.2, hgs.1, hgs.2, huc.1, huc.2, hus.1, hus.2]
    exact gateUp_launch hg hu
  have hb : [x, gc, gs, uc, us].map buffer =
      [⟨.device, 10240, 16, x.storageByte⟩, ⟨.device, Metal.Kernels.GateUp.codesBytes kg, 16, gc.storageByte⟩,
        ⟨.device, 34816, 16, gs.storageByte⟩, ⟨.device, Metal.Kernels.GateUp.codesBytes ku, 16, uc.storageByte⟩,
        ⟨.device, 34816, 16, us.storageByte⟩] := by
    show [buffer x, buffer gc, buffer gs, buffer uc, buffer us] = _
    rw [buffer_device (n := 10240) hx.1 hx.2 (by decide) (by decide),
      buffer_device (n := Metal.Kernels.GateUp.codesBytes kg) hgc.1 hgc.2
        (by simp only [List.foldr_cons, List.foldr_nil, Dtype.bytes, Metal.Kernels.GateUp.codesBytes]; omega)
        (by simp only [List.foldr_cons, List.foldr_nil, Assemble.maxConstantArraySize]; omega),
      buffer_device (n := 34816) hgs.1 hgs.2 (by decide) (by decide),
      buffer_device (n := Metal.Kernels.GateUp.codesBytes ku) huc.1 huc.2
        (by simp only [List.foldr_cons, List.foldr_nil, Dtype.bytes, Metal.Kernels.GateUp.codesBytes]; omega)
        (by simp only [List.foldr_cons, List.foldr_nil, Assemble.maxConstantArraySize]; omega),
      buffer_device (n := 34816) hus.1 hus.2 (by decide) (by decide)]
  exact ⟨_, apply_some G rfl rfl ht (by rw [hb]; exact e1) rfl, readOutput_ty _ _ _⟩

/-- The down partial launch at width `2 … 4` (the 3-bit codes block-interleaved). -/
theorem downPartial_ty (P : RoutePipelines G) {k : Nat} (hk : k = 2 ∨ k = 3 ∨ k = 4) {x dc ds : Value}
    (hx : Ty x .bfloat16 [1, 17408])
    (hdc : Ty dc .uint32 (if k = 3 then [10, 17408, 48] else [17408, 160 * k])) (hds : Ty ds .float16 [17408]) :
    ∃ part, apply G .downPartial [x, dc, ds] (downConfig k) = some [part] ∧ Ty part .float32 [1, 32, 5120] := by
  obtain ⟨sf, hG, hc⟩ := Metal.Bridge.Trellis.down_compiles hk
  have hmax : 256 ≤ G.maxThreads (Metal.Kernels.DownPartial.text k) := by
    rcases hk with rfl | rfl | rfl
    · exact P.downPartial_2
    · exact P.downPartial_3
    · exact P.downPartial_4
  have e2 := Metal.Kernels.DownPartial.gpu_output_of C _ _ _ hG _ hc G hmax x.storageByte dc.storageByte
    ds.storageByte 16 16 16 (by decide) (by decide) (by decide)
  have ht : launchText .downPartial [x, dc, ds] (downConfig k) = some (Metal.Kernels.DownPartial.text k) := by
    show Assemble.Tests.launch .downPartial (kernelName .downPartial)
      [⟨chars!"x", x.dtype, x.shape⟩, ⟨chars!"codes", dc.dtype, dc.shape⟩, ⟨chars!"scales", ds.dtype, ds.shape⟩]
      (outputNames .downPartial) _ = _
    rw [hx.1, hx.2, hdc.1, hdc.2, hds.1, hds.2, ← downPartial_launch hk]
    unfold Metal.Kernels.DownPartial.inputs
    by_cases h3 : k = 3
    · rw [if_pos h3, if_pos h3]; rfl
    · rw [if_neg h3, if_neg h3]; rfl
  have hdcb : buffer dc = ⟨.device, Metal.Kernels.DownPartial.codesBytes k, 16, dc.storageByte⟩ := by
    by_cases h3 : k = 3
    · subst h3
      exact buffer_device (n := Metal.Kernels.DownPartial.codesBytes 3) hdc.1 (hdc.2.trans (if_pos rfl)) rfl
        (by decide)
    · exact buffer_device (n := Metal.Kernels.DownPartial.codesBytes k) hdc.1 (hdc.2.trans (if_neg h3))
        (by simp only [List.foldr_cons, List.foldr_nil, Dtype.bytes, Metal.Kernels.DownPartial.codesBytes]; omega)
        (by simp only [List.foldr_cons, List.foldr_nil, Assemble.maxConstantArraySize]; omega)
  have hb : [x, dc, ds].map buffer =
      [⟨.device, 34816, 16, x.storageByte⟩, ⟨.device, Metal.Kernels.DownPartial.codesBytes k, 16, dc.storageByte⟩,
        ⟨.device, 34816, 16, ds.storageByte⟩] := by
    show [buffer x, buffer dc, buffer ds] = _
    rw [buffer_device (n := 34816) hx.1 hx.2 (by decide) (by decide), hdcb,
      buffer_device (n := 34816) hds.1 hds.2 (by decide) (by decide)]
  exact ⟨_, apply_some G rfl rfl ht (by rw [hb]; exact e2) rfl, readOutput_ty _ _ _⟩


/-- The 3-bit affine row launch of one assembled text. -/
theorem affineRow3_ty {steps blocks : Nat}
    (hc : (frontend (Metal.Kernels.AffineRow.text 3 steps blocks)).bind elaborate = some (Metal.Kernels.AffineRow.core3 steps))
    (ha : Metal.Kernels.AffineRow.assembled 3 steps blocks = some (Metal.Kernels.AffineRow.text 3 steps blocks))
    (hmax : 512 ≤ G.maxThreads (Metal.Kernels.AffineRow.text 3 steps blocks)) (hst : 0 < steps) (hbk : 0 < blocks)
    (hW : 64 * blocks * (192 * steps) < 2 ^ 31) {x w s b : Value} (hx : Ty x .bfloat16 [1, 1, steps * 512])
    (hw : Ty w .uint32 [4 * (blocks * 16), steps * 48]) (hs : Ty s .bfloat16 [4 * (blocks * 16), steps * 8])
    (hb : Ty b .bfloat16 [4 * (blocks * 16), steps * 8]) :
    ∃ y, apply G .affineRow [x, w, s, b] (affineConfig (steps * 512) (4 * (blocks * 16)) 3) = some [y] ∧
      Ty y .bfloat16 [1, 1, 4 * (blocks * 16)] := by
  have he := Metal.Kernels.AffineRow.gpu_output3 C G _ steps blocks hc hmax hst hbk hW x.storageByte w.storageByte
    s.storageByte b.storageByte 16 16 16 16 (by decide) (by decide) (by decide)
  exact ⟨_, apply_some G rfl rfl (affine_launch (wcols := 48) (by omega) ha hx hw hs hb)
    (by rw [affineConfig_grid, affineConfig_sizes, affine_buffers hst hbk 48 (by decide) hx hw hs hb]; exact he) rfl,
    readOutput_ty _ _ _⟩

/-- The 4-bit affine row launch of one assembled text. -/
theorem affineRow4_ty {steps blocks : Nat}
    (hc : (frontend (Metal.Kernels.AffineRow.text 4 steps blocks)).bind elaborate = some (Metal.Kernels.AffineRow.core4 steps))
    (ha : Metal.Kernels.AffineRow.assembled 4 steps blocks = some (Metal.Kernels.AffineRow.text 4 steps blocks))
    (hmax : 512 ≤ G.maxThreads (Metal.Kernels.AffineRow.text 4 steps blocks)) (hst : 0 < steps) (hbk : 0 < blocks)
    (hW : 64 * blocks * (256 * steps) < 2 ^ 31) {x w s b : Value} (hx : Ty x .bfloat16 [1, 1, steps * 512])
    (hw : Ty w .uint32 [4 * (blocks * 16), steps * 64]) (hs : Ty s .bfloat16 [4 * (blocks * 16), steps * 8])
    (hb : Ty b .bfloat16 [4 * (blocks * 16), steps * 8]) :
    ∃ y, apply G .affineRow [x, w, s, b] (affineConfig (steps * 512) (4 * (blocks * 16)) 4) = some [y] ∧
      Ty y .bfloat16 [1, 1, 4 * (blocks * 16)] := by
  have he := Metal.Kernels.AffineRow.gpu_output4 C G _ steps blocks hc hmax hst hbk hW x.storageByte w.storageByte
    s.storageByte b.storageByte 16 16 16 16 (by decide) (by decide) (by decide) (by decide)
  exact ⟨_, apply_some G rfl rfl (affine_launch (wcols := 64) (by omega) ha hx hw hs hb)
    (by rw [affineConfig_grid, affineConfig_sizes, affine_buffers hst hbk 64 (by decide) hx hw hs hb]; exact he) rfl,
    readOutput_ty _ _ _⟩

/-- **The affine row launch at every `AffineRoute` shape and both widths.** -/
theorem affineRow_ty (P : RoutePipelines G) {steps blocks bits : Nat} (route : AffineRoute steps blocks)
    (hbits : bits = 3 ∨ bits = 4) {x w s b : Value} (hx : Ty x .bfloat16 [1, 1, steps * 512])
    (hw : Ty w .uint32 [4 * (blocks * 16), steps * (16 * bits)]) (hs : Ty s .bfloat16 [4 * (blocks * 16), steps * 8])
    (hb : Ty b .bfloat16 [4 * (blocks * 16), steps * 8]) :
    ∃ y, apply G .affineRow [x, w, s, b] (affineConfig (steps * 512) (4 * (blocks * 16)) bits) = some [y] ∧
      Ty y .bfloat16 [1, 1, 4 * (blocks * 16)] := by
  rcases affine_route route with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> rcases hbits with rfl | rfl
  · exact affineRow3_ty G Metal.Kernels.AffineRow.compile_3_10_160 Metal.Kernels.AffineRow.assembled_route.1
      P.affine_3_10_160 (by decide) (by decide) (by decide) hx hw hs hb
  · exact affineRow4_ty G affine_compile_4_10_160 affine_assembled.1
      P.affine_4_10_160 (by decide) (by decide) (by decide) hx hw hs hb
  · exact affineRow3_ty G Metal.Kernels.AffineRow.compile_3_10_96 Metal.Kernels.AffineRow.assembled_route.2.1
      P.affine_3_10_96 (by decide) (by decide) (by decide) hx hw hs hb
  · exact affineRow4_ty G affine_compile_4_10_96 affine_assembled.2.1
      P.affine_4_10_96 (by decide) (by decide) (by decide) hx hw hs hb
  · exact affineRow3_ty G Metal.Kernels.AffineRow.compile_3_12_80 Metal.Kernels.AffineRow.assembled_route.2.2.1
      P.affine_3_12_80 (by decide) (by decide) (by decide) hx hw hs hb
  · exact affineRow4_ty G affine_compile_4_12_80 affine_assembled.2.2.1
      P.affine_4_12_80 (by decide) (by decide) (by decide) hx hw hs hb
  · exact affineRow3_ty G affine_compile_3_10_3880 affine_assembled.2.2.2
      P.affine_3_10_3880 (by decide) (by decide) (by decide) hx hw hs hb
  · exact affineRow4_ty G Metal.Kernels.AffineRow.compile_4_10_3880 Metal.Kernels.AffineRow.assembled_route.2.2.2
      P.affine_4_10_3880 (by decide) (by decide) (by decide) hx hw hs hb

end Host.Mlx.SimGraph.Mach

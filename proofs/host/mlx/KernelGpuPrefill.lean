import host.mlx.PrefillKernels
import metal.AssembleShape
namespace Host.Mlx.KernelGpu
open Metal Inference.Contracts.Mlx Inference.Kernels Host.Mlx.PrefillSources
open Metal.Kernels

/-! # The prefill kernels from the GPU assumption

`ofGpuRoute G B P lseSum lseNumerator` is the route's kernel contract over the decode and prefill kernels: its
decode part is `ofGpu G P lseSum lseNumerator` (unchanged), `applyP` MLX's custom-kernel launch of a prefill
kernel run by `G`, `inPlace` the same launch with every buffer's final contents (`G.executeAll`), and every
prefill field is proved from its kernel's theorem (proofs/metal/kernels, the generic `gpu_output_of` at the
route's instances).

The launch MLX issues for a prefill kernel (`applyP`): the text `Metal.Assemble.assemble` writes for the
constructor's name, input and output names, body, header and `atomic_outputs` flag (`PrefillSources`), the
inputs' dtypes and shapes and the call's output dtypes and template arguments (`launchTextP`); the buffers
custom_kernel.cpp:57-77 binds (`bindings`): each input's array (`KernelGpu.buffer`) and, for an input of rank
> 0 whose name the body mentions with `_shape`, its shape as `int32` words (`set_vector_bytes`, at the alignment
the trusted clause `SetBytes` states); the outputs read back with the call's dtypes and shapes. Strides and rank
buffers are not modelled (no route kernel reads them): a kernel whose body mentions them has no value. No decode
kernel's body mentions any input's shape, strides or rank (`decode_noShape`), so `KernelGpu.apply`, which binds the
arrays alone, binds as MLX does (`apply_bindings`).

The kernel modules assembled their texts with representative input shapes; the text depends on the shapes
only through MLX's classification of each input (`Assemble.assemble_cls`), so it is the module's text for
every route shape with the same dtypes and at least 8 elements. -/

/-! ## The launch MLX issues -/

/-- The text MLX compiles for a prefill kernel's call (after `metal::utils()`). -/
def launchTextP (k : PrefillKernel) (xs : List Value) (cfg : Config) : Option (List Char) :=
  Assemble.assemble (PrefillSources.name k)
    (List.zipWith (fun n v => (⟨n, v.dtype, v.shape⟩ : Assemble.Input)) (PrefillSources.inputNames k) xs)
    (PrefillSources.outputNames k) (cfg.outputs.map (·.2)) (PrefillSources.source k) (PrefillSources.header k)
    (Assemble.Tests.configArgs cfg) (PrefillSources.atomicOutputs k)

/-- The text of any route kernel's call. -/
def launchTextR : RouteKernel → List Value → Config → Option (List Char)
  | .decode k => launchText k
  | .prefill k => launchTextP k

/-- `set_vector_bytes(in.shape())`: the dimensions as little-endian `int32` words. -/
def shapeBytes (shape : List Nat) : ByteMemory.Bytes := fun b => ((shape.map (wordBytes 4)).flatten).getD b 0

/-- **Trusted boundary clause: MLX's `setBytes` data.** custom_kernel.cpp:66-67 binds an input's shape with
`set_vector_bytes` (device.h:64-67: `MTLComputeCommandEncoder::setBytes`): Metal copies the words into argument
storage the kernel reads through `const constant int*`. `align` is that storage's base alignment, Metal's choice,
which nothing in the model fixes; `aligned` is the one fact the route takes about it (MLX and Metal are trusted):
it is a multiple of 4, an `int`'s alignment. Every prefill theorem holds for every such `align`. -/
structure SetBytes where
  align : Nat
  aligned : 4 ∣ align

/-- A shape buffer, at the `setBytes` alignment. -/
def shapeBuffer (B : SetBytes) (v : Value) : Buffer := ⟨.constant, 4 * v.shape.length, B.align, shapeBytes v.shape⟩

/-- The buffers bound for one input (custom_kernel.cpp:60-76): the array; for rank > 0, the shape when the body
mentions `<name>_shape`. Strides or rank buffers: not modelled. -/
def inputBuffers (B : SetBytes) (source name : List Char) (v : Value) : Option (List Buffer) :=
  if v.shape.isEmpty then some [buffer v] else
    match Assemble.shapeInfo source name with
    | (false, false, false) => some [buffer v]
    | (true, false, false) => some [buffer v, shapeBuffer B v]
    | _ => none

/-- The input buffers in binding order. -/
def bindings (B : SetBytes) (source : List Char) : List (List Char) → List Value → Option (List Buffer)
  | n :: ns, v :: vs => do pure ((← inputBuffers B source n v) ++ (← bindings B source ns vs))
  | _, _ => some []

variable {C : M1Max.Contract} (G : Gpu C) (B : SetBytes)

/-- `mlx_fast_metal_kernel_apply` of a prefill kernel run by the GPU: MLX checks the input count; no route kernel sets
`init_value`. -/
def applyP (k : PrefillKernel) (xs : List Value) (cfg : Config) : Option (List Value) :=
  if xs.length = (PrefillSources.inputNames k).length ∧ cfg.initValue = none then
    (launchTextP k xs cfg).bind fun text =>
      (bindings B (PrefillSources.source k) (PrefillSources.inputNames k) xs).bind
      fun bufs => (G.execute text cfg.grid cfg.threadGroup bufs (cfg.outputs.map outputSize)).map fun outs =>
        List.zipWith readOutput outs cfg.outputs
  else none

/-- The in-place kernels' launch with every buffer's final contents (`InPlace.ofGpu`: `G.executeAll` of the assembled
text on the inputs' buffers; their bodies read no shape). -/
def inPlaceGpu : FfiAneEval.InPlace :=
  FfiAneEval.InPlace.ofGpu G (fun k xs cfg => launchTextP k.prefill xs cfg) buffer

/-! ## Lemmas -/

theorem applyP_some {k : PrefillKernel} {xs : List Value} {cfg : Config} {text : List Char} {bufs : List Buffer}
    {outs : List ByteMemory.Bytes} {ys : List Value} (hlen : xs.length = (PrefillSources.inputNames k).length)
    (hinit : cfg.initValue = none) (ht : launchTextP k xs cfg = some text)
    (hb : bindings B (PrefillSources.source k) (PrefillSources.inputNames k) xs = some bufs)
    (he : G.execute text cfg.grid cfg.threadGroup bufs (cfg.outputs.map outputSize) = some outs)
    (hr : List.zipWith readOutput outs cfg.outputs = ys) : applyP G B k xs cfg = some ys := by
  unfold applyP
  rw [ite_eq_left ⟨hlen, hinit⟩, ht, Option.bind_some, hb, Option.bind_some, he, Option.map_some, hr]

/-- The call's text is a kernel module's assembly when the inputs classify as the module's and the template
arguments are the module's. -/
theorem launchTextP_eq {k : PrefillKernel} {xs : List Value} {cfg : Config} {ins : List Assemble.Input}
    {args : List Assemble.TemplateArg} {text : List Char}
    (hin : (List.zipWith (fun n v => (⟨n, v.dtype, v.shape⟩ : Assemble.Input)) (PrefillSources.inputNames k) xs).map
      Assemble.Input.cls = ins.map Assemble.Input.cls)
    (hargs : Assemble.Tests.configArgs cfg = args)
    (ha : Assemble.assemble (PrefillSources.name k) ins (PrefillSources.outputNames k) (cfg.outputs.map (·.2))
      (PrefillSources.source k) (PrefillSources.header k) args (PrefillSources.atomicOutputs k) = some text) :
    launchTextP k xs cfg = some text := by
  unfold launchTextP
  rw [Assemble.assemble_cls _ hin, hargs]
  exact ha

theorem some_getD {o : Option (List Char)} (h : o.isSome) : o = some (o.getD []) := by
  cases o with
  | none => cases h
  | some _ => rfl

theorem cls_typed {n : List Char} {v : Value} {d : Dtype} {s : List Nat} (h : Typed v d s) :
    Assemble.Input.cls ⟨n, v.dtype, v.shape⟩ = Assemble.Input.cls ⟨n, d, s⟩ := by
  rw [h.1, h.2]

theorem size_eq {v : Value} {s : List Nat} (h : v.shape = s) : v.size = s.foldr (· * ·) 1 := by
  unfold Value.size; rw [h]

/-- An input of at least 8 elements classifies as the module's input of that name and dtype with at least 8. -/
theorem cls_big {n : List Char} {v : Value} {d : Dtype} {s : List Nat} (hd : v.dtype = d) (hv : 8 ≤ v.size)
    (hs : 8 ≤ s.foldr (· * ·) 1) : Assemble.Input.cls ⟨n, v.dtype, v.shape⟩ = Assemble.Input.cls ⟨n, d, s⟩ :=
  Assemble.cls_device rfl hd hv hs

theorem map_cls2 {a b a' b' : Assemble.Input} (h1 : a.cls = a'.cls) (h2 : b.cls = b'.cls) :
    [a, b].map Assemble.Input.cls = [a', b'].map Assemble.Input.cls := by
  simp only [List.map_cons, List.map_nil, h1, h2]

theorem map_cls3 {a b c a' b' c' : Assemble.Input} (h1 : a.cls = a'.cls) (h2 : b.cls = b'.cls) (h3 : c.cls = c'.cls) :
    [a, b, c].map Assemble.Input.cls = [a', b', c'].map Assemble.Input.cls := by
  simp only [List.map_cons, List.map_nil, h1, h2, h3]

theorem map_cls4 {a b c d a' b' c' d' : Assemble.Input} (h1 : a.cls = a'.cls) (h2 : b.cls = b'.cls)
    (h3 : c.cls = c'.cls) (h4 : d.cls = d'.cls) :
    [a, b, c, d].map Assemble.Input.cls = [a', b', c', d'].map Assemble.Input.cls := by
  simp only [List.map_cons, List.map_nil, h1, h2, h3, h4]

theorem map_cls5 {a b c d e a' b' c' d' e' : Assemble.Input} (h1 : a.cls = a'.cls) (h2 : b.cls = b'.cls)
    (h3 : c.cls = c'.cls) (h4 : d.cls = d'.cls) (h5 : e.cls = e'.cls) :
    [a, b, c, d, e].map Assemble.Input.cls = [a', b', c', d', e'].map Assemble.Input.cls := by
  simp only [List.map_cons, List.map_nil, h1, h2, h3, h4, h5]

theorem map_cls7 {a b c d e f g a' b' c' d' e' f' g' : Assemble.Input} (h1 : a.cls = a'.cls) (h2 : b.cls = b'.cls)
    (h3 : c.cls = c'.cls) (h4 : d.cls = d'.cls) (h5 : e.cls = e'.cls) (h6 : f.cls = f'.cls) (h7 : g.cls = g'.cls) :
    [a, b, c, d, e, f, g].map Assemble.Input.cls = [a', b', c', d', e', f', g'].map Assemble.Input.cls := by
  simp only [List.map_cons, List.map_nil, h1, h2, h3, h4, h5, h6, h7]

/-- A body that mentions no input's shape, strides or rank binds each input's array alone. -/
theorem bindings_plain (src : List Char) : ∀ (ns : List (List Char)) (xs : List Value), ns.length = xs.length →
    (ns.all fun n => Assemble.shapeInfo src n == (false, false, false)) = true →
      bindings B src ns xs = some (xs.map buffer)
  | [], [], _, _ => rfl
  | [], _ :: _, hl, _ => by simp at hl
  | _ :: _, [], hl, _ => by simp at hl
  | n :: ns, v :: vs, hl, ha => by
    simp only [List.all_cons, Bool.and_eq_true, beq_iff_eq] at ha
    have hv : inputBuffers B src n v = some [buffer v] := by
      unfold inputBuffers
      split
      · rfl
      · rw [ha.1]
    simp only [bindings, hv, bindings_plain src ns vs (by simpa using hl) ha.2, Option.bind_eq_bind, Option.bind_some,
      Option.pure_def, List.map_cons]
    rfl

/-- A body that mentions the first input's shape (and no other shape, strides or rank): its array, its shape, then
the other inputs' arrays. -/
theorem bindings_shape (src n : List Char) (ns : List (List Char)) (x : Value) (xs : List Value)
    (hx : x.shape.isEmpty = false) (hn : Assemble.shapeInfo src n = (true, false, false)) (hl : ns.length = xs.length)
    (ha : (ns.all fun n => Assemble.shapeInfo src n == (false, false, false)) = true) :
    bindings B src (n :: ns) (x :: xs) = some (buffer x :: shapeBuffer B x :: xs.map buffer) := by
  have hv : inputBuffers B src n x = some [buffer x, shapeBuffer B x] := by
    unfold inputBuffers
    rw [hx, hn]
    rfl
  simp only [bindings, hv, bindings_plain B src ns xs hl ha, Option.bind_eq_bind, Option.bind_some, Option.pure_def]
  rfl

theorem shapeBuffer_two {v : Value} {a b : Nat} (h : v.shape = [a, b]) :
    shapeBuffer B v = ⟨.constant, 8, B.align, fun i => (wordBytes 4 a ++ wordBytes 4 b).getD i 0⟩ := by
  unfold shapeBuffer shapeBytes
  rw [h]
  simp

/-! ## The decode kernels bind as MLX does -/

/-- **No decode kernel's body mentions an input's shape, strides or rank** (`Assemble.shapeInfo` on each of its
inputs' names, `SourceKernels.sources`), by kernel evaluation. -/
theorem decode_noShape : ∀ k : Kernel,
    ((inputNames k).all fun n => Assemble.shapeInfo (SourceKernels.sources.source k) n == (false, false, false)) = true := by
  intro k
  cases k <;> decide +kernel

/-- So MLX binds a decode launch's input arrays alone: `KernelGpu.apply`'s buffers. -/
theorem apply_bindings (k : Kernel) (xs : List Value) (hl : xs.length = (inputNames k).length) :
    bindings B (SourceKernels.sources.source k) (inputNames k) xs = some (xs.map buffer) :=
  bindings_plain B _ _ _ hl.symm (decode_noShape k)

/-- **`KernelGpu.apply` is MLX's launch with MLX's binding** (`bindings`, the same model as the prefill kernels'). -/
theorem apply_bound (k : Kernel) (xs : List Value) (cfg : Config) :
    apply G k xs cfg =
      if xs.length = (inputNames k).length ∧ cfg.initValue = none then
        (launchText k xs cfg).bind fun text => (bindings B (SourceKernels.sources.source k) (inputNames k) xs).bind
          fun bufs => (G.execute text cfg.grid cfg.threadGroup bufs (cfg.outputs.map outputSize)).map fun outs =>
            List.zipWith readOutput outs cfg.outputs
      else none := by
  unfold apply
  by_cases h : xs.length = (inputNames k).length ∧ cfg.initValue = none
  · rw [ite_eq_left h, ite_eq_left h]
    congr 1
    funext text
    rw [apply_bindings B k xs h.1, Option.bind_some]
  · rw [ite_eq_right h, ite_eq_right h]

/-- Nor does an in-place kernel's body (`inPlaceGpu` binds the arrays alone, as MLX does). -/
theorem inPlace_noShape : ∀ k : FfiAneEval.InPlaceKernel,
    ((PrefillSources.inputNames k.prefill).all fun n =>
      Assemble.shapeInfo (PrefillSources.source k.prefill) n == (false, false, false)) = true := by
  intro k
  cases k <;> decide +kernel

theorem inPlace_bindings (k : FfiAneEval.InPlaceKernel) (xs : List Value)
    (hl : xs.length = (PrefillSources.inputNames k.prefill).length) :
    bindings B (PrefillSources.source k.prefill) (PrefillSources.inputNames k.prefill) xs = some (xs.map buffer) :=
  bindings_plain B _ _ _ hl.symm (inPlace_noShape k)

theorem shape_word0 (a b : Nat) (ha : a < 2 ^ 32) :
    Trellis.word32 (fun i => (wordBytes 4 a ++ wordBytes 4 b).getD i 0) 0 = a := by
  have hc : cells (fun i => (wordBytes 4 a ++ wordBytes 4 b).getD i 0) (4 * 0) 4 = wordBytes 4 a := rfl
  unfold Trellis.word32
  rw [hc]
  exact bytesWord_wordBytes4_of_lt a ha

theorem shape_bytes (a b : Nat) :
    (fun i => (wordBytes 4 a ++ wordBytes 4 b).getD i 0) 0 = BitVec.ofNat 8 a ∧
      (fun i => (wordBytes 4 a ++ wordBytes 4 b).getD i 0) 1 = BitVec.ofNat 8 (a / 2 ^ 8) ∧
      (fun i => (wordBytes 4 a ++ wordBytes 4 b).getD i 0) 2 = BitVec.ofNat 8 (a / 2 ^ 16) ∧
      (fun i => (wordBytes 4 a ++ wordBytes 4 b).getD i 0) 3 = BitVec.ofNat 8 (a / 2 ^ 24) := by
  simp [wordBytes, List.range_succ]

theorem foldr_two (a b : Nat) : [a, b].foldr (· * ·) 1 = a * b := by simp

/-- An array of `n` row-major elements of `d` with at least 8 of them: a device buffer of its bytes. -/
theorem buffer_big {v : Value} {d : Dtype} {s : List Nat} (h : Typed v d s) {n : Nat}
    (hn : s.foldr (· * ·) 1 * d.bytes = n) (h8 : 8 ≤ s.foldr (· * ·) 1) : buffer v = ⟨.device, n, 16, v.storageByte⟩ :=
  buffer_device h.1 h.2 hn (by unfold Assemble.maxConstantArraySize; omega)

/-! ## affine3_rows, affine4_rows -/

section Rows
variable {r N K : Nat} {x w s b : Value}

theorem rows_buffers {wcols : Nat} (hx : Typed x .bfloat16 [r, K]) (hw : Typed w .uint32 [N, wcols])
    (hs : Typed s .bfloat16 [N, K / 64]) (hb : Typed b .bfloat16 [N, K / 64]) (h8 : 8 ≤ r * K) (hw8 : 8 ≤ N * wcols)
    (hs8 : 8 ≤ N * (K / 64)) :
    [x, w, s, b].map buffer = [⟨.device, 2 * (r * K), 16, x.storageByte⟩, ⟨.device, 4 * (N * wcols), 16, w.storageByte⟩,
      ⟨.device, 2 * (N * (K / 64)), 16, s.storageByte⟩, ⟨.device, 2 * (N * (K / 64)), 16, b.storageByte⟩] := by
  show [buffer x, buffer w, buffer s, buffer b] = _
  rw [buffer_big hx (n := 2 * (r * K)) (by rw [foldr_two]; simp only [Dtype.bytes]; ring) (by rw [foldr_two]; exact h8),
    buffer_big hw (n := 4 * (N * wcols)) (by rw [foldr_two]; simp only [Dtype.bytes]; ring) (by rw [foldr_two]; exact hw8),
    buffer_big hs (n := 2 * (N * (K / 64))) (by rw [foldr_two]; simp only [Dtype.bytes]; ring)
      (by rw [foldr_two]; exact hs8),
    buffer_big hb (n := 2 * (N * (K / 64))) (by rw [foldr_two]; simp only [Dtype.bytes]; ring)
      (by rw [foldr_two]; exact hs8)]

theorem rows_sizes : (rowsConfig r N K).outputs.map outputSize = [2 * (r * N)] := by
  simp only [rowsConfig, List.map_cons, List.map_nil, outputSize, foldr_two, Dtype.bytes, List.cons.injEq, and_true]
  ring

theorem rows3_of (hD : AffineRows.Dims r N K) (ha : AffineRows3.assembled r N K = some (AffineRows3.text r N K))
    (hc : (frontend (AffineRows3.text r N K)).bind elaborate = some (AffineRows3.core r N K))
    (hmax : 64 ≤ G.maxThreads (AffineRows3.text r N K))
    (hx : Typed x .bfloat16 [r, K]) (hw : Typed w .uint32 [N, K * 3 / 32]) (hs : Typed s .bfloat16 [N, K / 64])
    (hb : Typed b .bfloat16 [N, K / 64]) (h8 : 8 ≤ r * K) (hw8 : 8 ≤ N * (K * 3 / 32)) (hs8 : 8 ≤ N * (K / 64)) :
    applyP G B .affine3Rows [x, w, s, b] (rowsConfig r N K) =
      some [readOutput (AffineRows3.expected C r N K x.storageByte w.storageByte s.storageByte b.storageByte)
        ([r, N], .bfloat16)] := by
  have he := AffineRows3.gpu_output_of C G hD _ hc hmax x.storageByte w.storageByte s.storageByte b.storageByte
    16 16 16 16 (by decide) (by decide) (by decide)
  have hg : (N + 7) / 8 = N / 8 := by have := hD.n8; omega
  refine applyP_some G B (outs := [AffineRows3.expected C r N K x.storageByte w.storageByte s.storageByte b.storageByte])
    rfl rfl (launchTextP_eq (map_cls4 (cls_typed hx) (cls_typed hw) (cls_typed hs) (cls_typed hb)) rfl ha)
    (bindings_plain B _ _ _ rfl (by decide +kernel)) ?_ rfl
  show G.execute _ (64, (N + 7) / 8, 1) (64, 1, 1) _ _ = _
  rw [hg, rows_buffers hx hw hs hb h8 hw8 hs8, rows_sizes]
  exact he

theorem rows4_of (hD : AffineRows.Dims r N K) (ha : AffineRows4.assembled r N K = some (AffineRows4.text r N K))
    (hc : (frontend (AffineRows4.text r N K)).bind elaborate = some (AffineRows4.core r N K))
    (hmax : 64 ≤ G.maxThreads (AffineRows4.text r N K))
    (hx : Typed x .bfloat16 [r, K]) (hw : Typed w .uint32 [N, K / 8]) (hs : Typed s .bfloat16 [N, K / 64])
    (hb : Typed b .bfloat16 [N, K / 64]) (h8 : 8 ≤ r * K) (hw8 : 8 ≤ N * (K / 8)) (hs8 : 8 ≤ N * (K / 64)) :
    applyP G B .affine4Rows [x, w, s, b] (rowsConfig r N K) =
      some [readOutput (AffineRows4.expected C r N K x.storageByte w.storageByte s.storageByte b.storageByte)
        ([r, N], .bfloat16)] := by
  have he := AffineRows4.gpu_output_of C G hD _ hc hmax x.storageByte w.storageByte s.storageByte b.storageByte
    16 16 16 16 (by decide) (by decide) (by decide) (by decide)
  have hg : (N + 7) / 8 = N / 8 := by have := hD.n8; omega
  refine applyP_some G B (outs := [AffineRows4.expected C r N K x.storageByte w.storageByte s.storageByte b.storageByte])
    rfl rfl (launchTextP_eq (map_cls4 (cls_typed hx) (cls_typed hw) (cls_typed hs) (cls_typed hb)) rfl ha)
    (bindings_plain B _ _ _ rfl (by decide +kernel)) ?_ rfl
  show G.execute _ (64, (N + 7) / 8, 1) (64, 1, 1) _ _ = _
  rw [hg, rows_buffers hx hw hs hb h8 hw8 hs8, rows_sizes]
  exact he

end Rows

theorem outputSize_two (a b : Nat) (d : Dtype) : outputSize ([a, b], d) = a * b * d.bytes := by
  simp [outputSize]

/-! ## affine_split_mma -/

section Split
variable {r N K bits tiles splits : Nat} {x w s b : Value}

theorem split_of (hp : splitPlan N = (tiles, splits)) (hbits : bits = 3 ∨ bits = 4) (hK : K % 256 = 0)
    (hKle : K < 2 ^ 16) (hN : N % (8 * tiles) = 0) (hNpos : 0 < N) (hNle : N < 2 ^ 16) (ht : 0 < tiles)
    (hs0 : 0 < splits) (hsK : splits ≤ K / 256)
    (ha : AffineSplitMma.assembled N K bits tiles splits = some (AffineSplitMma.text N K bits tiles splits))
    (hc : (frontend (AffineSplitMma.text N K bits tiles splits)).bind elaborate =
      some (AffineSplitMma.core N K bits tiles splits))
    (hmax : 32 * splits ≤ G.maxThreads (AffineSplitMma.text N K bits tiles splits)) (hr : 4 ≤ r) (hr' : r ≤ 223)
    (hx : Typed x .bfloat16 [r, K]) (hw : Typed w .uint32 [N, K * bits / 32]) (hs : Typed s .bfloat16 [N, K / 64])
    (hb : Typed b .bfloat16 [N, K / 64]) (hw8 : 8 ≤ N * (K * bits / 32)) (hs8 : 8 ≤ N * (K / 64)) :
    applyP G B .affineSplitMma [x, w, s, b] (splitConfig r N K bits) =
      some [readOutput (AffineSplitMma.expected C N K bits (splitPlan N).1 (splitPlan N).2 r x.storageByte
        w.storageByte s.storageByte b.storageByte) ([r, N], .bfloat16)] := by
  have hK0 : 256 ≤ K := by have := hsK; omega
  have hcfg : splitConfig r N K bits = ⟨[([r, N], .bfloat16)], (32 * splits, N / (8 * tiles), (r + 7) / 8),
      (32 * splits, 1, 1), [("T", .bfloat16)],
      [("N", N), ("K", K), ("BITS", bits), ("TILES", tiles), ("SPLITS", splits)], none⟩ := by
    unfold splitConfig; rw [hp]
  rw [hcfg, hp]
  have he := AffineSplitMma.gpu_output_of C N K bits tiles splits hbits hK hKle hN hNpos hNle ht hs0 hsK _ hc G hmax r
    (by omega) (by omega) x.storageByte w.storageByte s.storageByte b.storageByte 16 B.align 16 16 16 (by decide) B.aligned
    (by decide) (by decide) (by decide)
  have hxK : 8 ≤ r * K := by nlinarith
  refine applyP_some G B (outs := [AffineSplitMma.expected C N K bits tiles splits r x.storageByte w.storageByte
      s.storageByte b.storageByte]) rfl rfl
    (launchTextP_eq (map_cls4 (cls_big hx.1 (by rw [size_eq hx.2, foldr_two]; exact hxK) (by rw [foldr_two]; omega))
      (cls_typed hw) (cls_typed hs) (cls_typed hb)) rfl ha)
    (bindings_shape B _ _ _ x [w, s, b] (by rw [hx.2]; rfl) (by decide +kernel) rfl (by decide +kernel)) ?_ rfl
  show G.execute _ _ _ (buffer x :: shapeBuffer B x :: [buffer w, buffer s, buffer b]) [outputSize ([r, N], .bfloat16)] = _
  rw [shapeBuffer_two B hx.2, buffer_big hx (n := 2 * (r * K)) (by rw [foldr_two]; simp only [Dtype.bytes]; ring)
      (by rw [foldr_two]; exact hxK),
    buffer_big hw (n := 4 * (N * (K * bits / 32))) (by rw [foldr_two]; simp only [Dtype.bytes]; ring)
      (by rw [foldr_two]; exact hw8),
    buffer_big hs (n := 2 * (N * (K / 64))) (by rw [foldr_two]; simp only [Dtype.bytes]; ring)
      (by rw [foldr_two]; exact hs8),
    buffer_big hb (n := 2 * (N * (K / 64))) (by rw [foldr_two]; simp only [Dtype.bytes]; ring)
      (by rw [foldr_two]; exact hs8),
    outputSize_two, show r * N * Dtype.bytes .bfloat16 = 2 * (r * N) by simp only [Dtype.bytes]; ring]
  exact he

end Split

/-! ## The Trellis gate-up MMAs -/

section GateUp
variable {r kg ku : Nat} {x gc gs uc us : Value}

theorem gateUp_buffers (hgc : Typed gc .uint32 [17408, 160 * kg]) (hgs : Typed gs .float16 [17408])
    (huc : Typed uc .uint32 [17408, 160 * ku]) (hus : Typed us .float16 [17408]) (hkg : 0 < kg) (hku : 0 < ku) :
    [gc, gs, uc, us].map buffer = [⟨.device, GateUp.codesBytes kg, 16, gc.storageByte⟩, ⟨.device, 34816, 16, gs.storageByte⟩,
      ⟨.device, GateUp.codesBytes ku, 16, uc.storageByte⟩, ⟨.device, 34816, 16, us.storageByte⟩] := by
  show [buffer gc, buffer gs, buffer uc, buffer us] = _
  rw [buffer_big hgc (n := GateUp.codesBytes kg) (by rw [foldr_two]; simp only [Dtype.bytes, GateUp.codesBytes]; ring)
      (by rw [foldr_two]; omega),
    buffer_big hgs (n := 34816) rfl (by decide),
    buffer_big huc (n := GateUp.codesBytes ku) (by rw [foldr_two]; simp only [Dtype.bytes, GateUp.codesBytes]; ring)
      (by rw [foldr_two]; omega),
    buffer_big hus (n := 34816) rfl (by decide)]

theorem codebook_of (hKg : GateUp.Width kg) (hKu : GateUp.Width ku)
    (ha : GateUpCodebookMma.assembled kg ku = some (GateUpCodebookMma.text kg ku))
    (hc : (frontend (GateUpCodebookMma.text kg ku)).bind elaborate = some (GateUpCodebookMma.core kg ku))
    (hmax : 128 ≤ G.maxThreads (GateUpCodebookMma.text kg ku)) (hr : 2 ≤ r) (hr8 : r ≤ 8)
    (hx : Typed x .bfloat16 [r, 5120]) (hgc : Typed gc .uint32 [17408, 160 * kg]) (hgs : Typed gs .float16 [17408])
    (huc : Typed uc .uint32 [17408, 160 * ku]) (hus : Typed us .float16 [17408]) (hkg : 0 < kg) (hku : 0 < ku) :
    applyP G B .gateUpCodebookMma [x, gc, gs, uc, us] (codebookConfig r kg ku) =
      some [readOutput (CodebookMma.expected C kg ku x.storageByte gc.storageByte gs.storageByte uc.storageByte
        us.storageByte r) ([r, 17408], .bfloat16)] := by
  have he := CodebookMma.gpu_output_of C kg ku hKg hKu _ hc G hmax r (by omega) hr8 x.storageByte
    (fun i => (wordBytes 4 r ++ wordBytes 4 5120).getD i 0) gc.storageByte gs.storageByte uc.storageByte us.storageByte
    16 B.align 16 16 16 16 (by decide) B.aligned (by decide) (by decide) (by decide) (by decide) (shape_bytes r 5120)
  refine applyP_some G B (outs := [CodebookMma.expected C kg ku x.storageByte gc.storageByte gs.storageByte
      uc.storageByte us.storageByte r]) rfl rfl
    (launchTextP_eq (map_cls5 (cls_big hx.1 (by rw [size_eq hx.2, foldr_two]; omega) (by decide))
      (cls_typed hgc) (cls_typed hgs) (cls_typed huc) (cls_typed hus)) rfl ha)
    (bindings_shape B _ _ _ x [gc, gs, uc, us] (by rw [hx.2]; rfl) (by decide +kernel) rfl (by decide +kernel)) ?_ rfl
  show G.execute _ _ _ (buffer x :: shapeBuffer B x :: [gc, gs, uc, us].map buffer) [outputSize ([r, 17408], .bfloat16)] = _
  rw [shapeBuffer_two B hx.2, buffer_big hx (n := 10240 * r) (by rw [foldr_two]; simp only [Dtype.bytes]; ring)
      (by rw [foldr_two]; omega), gateUp_buffers hgc hgs huc hus hkg hku,
    outputSize_two, show r * 17408 * Dtype.bytes .bfloat16 = 34816 * r by simp only [Dtype.bytes]; ring]
  exact he

theorem wide_of (hKg : GateUp.Width kg) (hKu : GateUp.Width ku)
    (ha2 : GateUpMmaWide.assembled kg ku 2 = some (GateUpMmaWide.text kg ku 2))
    (ha3 : GateUpMmaWide.assembled kg ku 3 = some (GateUpMmaWide.text kg ku 3))
    (hc2 : (frontend (GateUpMmaWide.text kg ku 2)).bind elaborate = some (GateUpMmaWide.core kg ku 2))
    (hc3 : (frontend (GateUpMmaWide.text kg ku 3)).bind elaborate = some (GateUpMmaWide.core kg ku 3))
    (hm2 : 256 ≤ G.maxThreads (GateUpMmaWide.text kg ku 2)) (hm3 : 256 ≤ G.maxThreads (GateUpMmaWide.text kg ku 3))
    (hr : 9 ≤ r) (hr' : r ≤ 223)
    (hx : Typed x .bfloat16 [r, 5120]) (hgc : Typed gc .uint32 [17408, 160 * kg]) (hgs : Typed gs .float16 [17408])
    (huc : Typed uc .uint32 [17408, 160 * ku]) (hus : Typed us .float16 [17408]) (hkg : 0 < kg) (hku : 0 < ku) :
    applyP G B .gateUpMmaWide [x, gc, gs, uc, us] (wideConfig r kg ku) =
      some [readOutput (GateUpMmaWide.expected C kg ku r x.storageByte gc.storageByte gs.storageByte uc.storageByte
        us.storageByte) ([r, 17408], .bfloat16)] := by
  have hrb : GateUpMmaWide.rowBlocks r = 2 ∨ GateUpMmaWide.rowBlocks r = 3 := by
    unfold GateUpMmaWide.rowBlocks; split <;> simp
  have ha : GateUpMmaWide.assembled kg ku (GateUpMmaWide.rowBlocks r) =
      some (GateUpMmaWide.text kg ku (GateUpMmaWide.rowBlocks r)) := by
    rcases hrb with h | h
    · rw [h]; exact ha2
    · rw [h]; exact ha3
  have hm : 256 ≤ G.maxThreads (GateUpMmaWide.text kg ku (GateUpMmaWide.rowBlocks r)) := by
    rcases hrb with h | h
    · rw [h]; exact hm2
    · rw [h]; exact hm3
  have he := GateUpMmaWide.gpu_output_of C kg ku (GateUpMmaWide.rowBlocks r) hKg hKu (GateUpMmaWide.rowBlocks_range r) _
    (GateUpMmaWide.compile_rowBlocks r hc2 hc3) G hm r ⟨by omega, by omega⟩ x.storageByte gc.storageByte gs.storageByte
    uc.storageByte us.storageByte 16 B.align 16 16 16 16 (by decide) B.aligned (by decide) (by decide) (by decide)
    (by decide)
  refine applyP_some G B (outs := [GateUpMmaWide.expected C kg ku r x.storageByte gc.storageByte gs.storageByte
      uc.storageByte us.storageByte]) rfl rfl
    (launchTextP_eq (map_cls5 (cls_big hx.1 (by rw [size_eq hx.2, foldr_two]; omega) (by decide))
      (cls_typed hgc) (cls_typed hgs) (cls_typed huc) (cls_typed hus)) rfl ha)
    (bindings_shape B _ _ _ x [gc, gs, uc, us] (by rw [hx.2]; rfl) (by decide +kernel) rfl (by decide +kernel)) ?_ rfl
  show G.execute _ _ _ (buffer x :: shapeBuffer B x :: [gc, gs, uc, us].map buffer) [outputSize ([r, 17408], .bfloat16)] = _
  rw [shapeBuffer_two B hx.2, buffer_big hx (n := 10240 * r) (by rw [foldr_two]; simp only [Dtype.bytes]; ring)
      (by rw [foldr_two]; omega), gateUp_buffers hgc hgs huc hus hkg hku,
    outputSize_two, show r * 17408 * Dtype.bytes .bfloat16 = 34816 * r by simp only [Dtype.bytes]; ring]
  exact he

end GateUp

/-! ## The Trellis down MMAs -/

section Down
variable {M k s mt : Nat} {x cd sc : Value}

theorem down_sizes (k s mt il : Nat) : (downConfig' M k s mt il).outputs.map outputSize = [163840 * M] := by
  simp only [downConfig', List.map_cons, List.map_nil, outputSize, List.foldr_cons, List.foldr_nil, Dtype.bytes,
    List.cons.injEq, and_true]
  ring

theorem down_of (hG : DownMmaWide.Geo k s mt (downWords k s) false)
    (ha : DownMmaWide.assembled k s mt (downWords k s) = some (DownMmaWide.text k s mt (downWords k s)))
    (hc : (frontend (DownMmaWide.text k s mt (downWords k s))).bind elaborate =
      some (DownMmaWide.core k s mt (downWords k s) false))
    (hmax : 128 ≤ G.maxThreads (DownMmaWide.text k s mt (downWords k s)))
    (hgy : (5120 / 256 * (32 / s) * 8 + 3) / 4 = DownMmaWide.gyOf s) (hM : 2 ≤ M) (hM' : M ≤ 223)
    (hx : Typed x .bfloat16 [M, 17408]) (hcd : Typed cd .uint32 [17408, 160 * k]) (hsc : Typed sc .float16 [17408])
    (hk : 0 < k) :
    applyP G B .downMmaWide [x, cd, sc] (downConfig' M k s mt 0) =
      some [readOutput (DownMmaWide.expected C k false s mt M x.storageByte cd.storageByte sc.storageByte)
        ([M, 8, 5120], .float32)] := by
  have he := DownMmaWide.gpu_output_of C k s mt (downWords k s) false hG _ hc G hmax M (by omega) (by omega)
    x.storageByte (fun i => (wordBytes 4 M ++ wordBytes 4 17408).getD i 0) cd.storageByte sc.storageByte 16 B.align 16 16
    (by decide) B.aligned (by decide) (by decide) (shape_word0 M 17408 (by omega))
  refine applyP_some G B (outs := [DownMmaWide.expected C k false s mt M x.storageByte cd.storageByte sc.storageByte])
    rfl rfl
    (launchTextP_eq (map_cls3 (cls_big hx.1 (by rw [size_eq hx.2, foldr_two]; omega) (by decide))
      (cls_typed hcd) (cls_typed hsc)) rfl ha)
    (bindings_shape B _ _ _ x [cd, sc] (by rw [hx.2]; rfl) (by decide +kernel) rfl (by decide +kernel)) ?_ rfl
  show G.execute _ (128, (5120 / 256 * (32 / s) * 8 + 3) / 4, Metal.ceilDiv M (8 * mt)) _
    (buffer x :: shapeBuffer B x :: [cd, sc].map buffer) _ = _
  rw [hgy, down_sizes, shapeBuffer_two B hx.2, buffer_big hx (n := 34816 * M)
      (by rw [foldr_two]; simp only [Dtype.bytes]; ring) (by rw [foldr_two]; omega)]
  show G.execute _ _ _ (_ :: _ :: [buffer cd, buffer sc]) _ = _
  rw [buffer_big hcd (n := DownMmaWide.codesBytes k)
      (by rw [foldr_two]; simp only [Dtype.bytes, DownMmaWide.codesBytes]; ring) (by rw [foldr_two]; omega),
    buffer_big hsc (n := 34816) rfl (by decide)]
  exact he

theorem downK3i_of (hmax : 128 ≤ G.maxThreads (DownK3iMmaWide.text 3 16 1 5)) (hM : 2 ≤ M) (hM' : M ≤ 223)
    (hx : Typed x .bfloat16 [M, 17408]) (hcd : Typed cd .uint32 [10, 17408, 48]) (hsc : Typed sc .float16 [17408]) :
    applyP G B .downK3iMmaWide [x, cd, sc] (downConfig' M 3 16 1 1) =
      some [readOutput (DownMmaWide.expected C 3 true 16 1 M x.storageByte cd.storageByte sc.storageByte)
        ([M, 8, 5120], .float32)] := by
  have he := DownK3iMmaWide.gpu_output C G hmax M ⟨hM, hM'⟩ (X := x.storageByte)
    (Xs := fun i => (wordBytes 4 M ++ wordBytes 4 17408).getD i 0) (Cd := cd.storageByte) (S := sc.storageByte)
    (ax := 16) (ash := B.align) (ac := 16) (as := 16) (by decide) B.aligned (by decide) (by decide)
    (shape_word0 M 17408 (by omega))
  refine applyP_some G B (outs := [DownMmaWide.expected C 3 true 16 1 M x.storageByte cd.storageByte sc.storageByte])
    rfl rfl
    (launchTextP_eq (map_cls3 (cls_big hx.1 (by rw [size_eq hx.2, foldr_two]; omega) (by decide))
      (cls_typed hcd) (cls_typed hsc)) rfl (some_getD DownK3iMmaWide.assembled_route))
    (bindings_shape B _ _ _ x [cd, sc] (by rw [hx.2]; rfl) (by decide +kernel) rfl (by decide +kernel)) ?_ rfl
  show G.execute _ (128, 80, Metal.ceilDiv M 8) _ (buffer x :: shapeBuffer B x :: [buffer cd, buffer sc]) _ = _
  rw [down_sizes, shapeBuffer_two B hx.2, buffer_big hx (n := 34816 * M)
      (by rw [foldr_two]; simp only [Dtype.bytes]; ring) (by rw [foldr_two]; omega),
    buffer_big hcd (n := 33423360) rfl (by decide), buffer_big hsc (n := 34816) rfl (by decide)]
  exact he

end Down

/-! ## vector_expand -/

section Expand
variable {R bits il rt : Nat} {cd sc : Value}

theorem expand_of (tile : Option Nat) (hK : 0 < bits ∧ bits ≤ 7) (hR0 : 8 ≤ R) (hR : 1280 * R < 2 ^ 32)
    (ht : VectorExpandProof.TileOk R tile)
    (hgrid : (if rt = 0 then (1280, R, 1) else (1280 * R, 1, 1)) = VectorExpandProof.grid tile R)
    (ha : VectorExpand.assembled R bits il rt = some (VectorExpand.text R bits il rt))
    (hc : (frontend (VectorExpand.text R bits il rt)).bind elaborate = some (VectorExpand.core R bits (il != 0) tile))
    (hmax : 128 ≤ G.maxThreads (VectorExpand.text R bits il rt))
    (hcd : Typed cd .uint32 (if (il != 0) = true then [10, R, 48] else [R, 160 * bits])) (hsc : Typed sc .float16 [R])
    (hsz : (if (il != 0) = true then [10, R, 48] else [R, 160 * bits]).foldr (· * ·) 1 * 4 = 640 * R * bits)
    (h8 : 8 ≤ (if (il != 0) = true then [10, R, 48] else [R, 160 * bits]).foldr (· * ·) 1) :
    applyP G B .vectorExpand [cd, sc] (expandConfig R bits il rt) =
      some [readOutput (VectorExpand.expected C R bits (il != 0) cd.storageByte sc.storageByte) ([R, 5120], .bfloat16)] := by
  have he := VectorExpand.gpu_output_of C R bits (il != 0) tile hK (by omega) hR ht _ hc G hmax cd.storageByte
    sc.storageByte 16 16 (by decide) (by decide)
  refine applyP_some G B (outs := [VectorExpand.expected C R bits (il != 0) cd.storageByte sc.storageByte]) rfl rfl
    (launchTextP_eq (map_cls2 (cls_typed hcd) (cls_typed hsc)) rfl ha)
    (bindings_plain B _ _ _ rfl (by decide +kernel)) ?_ rfl
  show G.execute _ (if rt = 0 then (1280, R, 1) else (1280 * R, 1, 1)) _ [buffer cd, buffer sc]
    [outputSize ([R, 5120], .bfloat16)] = _
  rw [hgrid, buffer_big hcd (n := 640 * R * bits) hsz h8,
    buffer_big hsc (n := 2 * R) (by simp only [List.foldr_cons, List.foldr_nil, Dtype.bytes]; ring)
      (by simp only [List.foldr_cons, List.foldr_nil]; omega),
    outputSize_two, show R * 5120 * Dtype.bytes .bfloat16 = 10240 * R by simp only [Dtype.bytes]; ring]
  exact he

end Expand

/-! ## The in-place kernels -/

section InPlace
variable {rows bits N : Nat} {cd sc dst src : Value}

theorem buffer_dst (hd : dst.dtype = .float16) (h8 : 8 ≤ dst.size) :
    buffer dst = ⟨.device, dst.size * 2, 16, dst.storageByte⟩ := by
  unfold buffer
  rw [ite_eq_right (by unfold Assemble.maxConstantArraySize; omega), hd]
  rfl

/-- `WritesDone` from an all-buffers launch that completes with the written input's final bytes and `done`. -/
theorem writesDone_of {k : FfiAneEval.InPlaceKernel} {xs : List Value} {cfg : Config} {i : Nat}
    {stored : Nat → Option (BitVec 8)} {res : List ByteMemory.Bytes} {B : ByteMemory.Bytes} {d : Value}
    (hl : (inPlaceGpu G).launchAll k xs cfg = some res) (hlen : res.length = xs.length + cfg.outputs.length)
    (hB : res[i]? = some B) (hd : xs[i]? = some d)
    (hbytes : ∀ b, b < d.size * d.dtype.bytes → B b = (stored b).getD (d.storageByte b))
    (hdone : res[xs.length]? = some AneFill.doneOut) :
    WritesDone (inPlaceGpu G) k xs cfg i stored :=
  ⟨⟨res, B, d, hl, hlen, hB, hd, hbytes⟩, fun res' h => by rw [hl] at h; cases h; exact hdone⟩

theorem inPlaceGpu_launch (k : FfiAneEval.InPlaceKernel) (xs : List Value) (cfg : Config) {text : List Char}
    (ht : launchTextP k.prefill xs cfg = some text) (hinit : cfg.initValue = none) :
    (inPlaceGpu G).launchAll k xs cfg =
      G.executeAll text cfg.grid cfg.threadGroup (xs.map buffer) (cfg.outputs.map fun o => o.1.foldr (· * ·) 1 * o.2.bytes) := by
  show (if cfg.initValue = none then (launchTextP k.prefill xs cfg).bind fun t => G.executeAll t cfg.grid cfg.threadGroup
    (xs.map buffer) (cfg.outputs.map fun o => o.1.foldr (· * ·) 1 * o.2.bytes) else none) = _
  rw [ite_eq_left hinit, ht, Option.bind_some]

theorem fill_of (hK : AneFill.Bits bits) (hrows : 0 < rows ∧ rows ≤ 17408)
    (ha : AneTrellisFill.assembled rows bits (fillPer bits) = some (AneTrellisFill.text rows bits (fillPer bits)))
    (hc : (frontend (AneTrellisFill.text rows bits (fillPer bits))).bind elaborate =
      some (AneTrellisFill.core rows bits (fillPer bits)))
    (hmax : 128 ≤ G.maxThreads (AneTrellisFill.text rows bits (fillPer bits)))
    (hcd : Typed cd .uint32 [17408, 160 * bits]) (hsc : Typed sc .float16 [17408]) (hd : dst.dtype = .float16)
    (hn : rows * 5120 ≤ dst.size) :
    WritesDone (inPlaceGpu G) .trellisFill [cd, sc, dst] (fillConfig rows bits) 2
      (AneFill.fillStored C bits rows (AneFill.rowMajor bits) cd.storageByte sc.storageByte) := by
  have hper : fillPer bits = 8 ∨ fillPer bits = 16 := by unfold fillPer; split <;> simp
  have hb0 : 0 < bits := by rcases hK with h | h | h <;> omega
  obtain ⟨res, B, he, hlen, hB, hbytes, hdone⟩ := AneFill.gpu_output_of C rows bits (fillPer bits) hK hper hrows _ hc G
    hmax cd.storageByte sc.storageByte dst.storageByte 16 16 16 dst.size (by decide) (by decide) (by decide) hn
  have h8 : 8 ≤ dst.size := by omega
  have ht : launchTextP .aneTrellisFill [cd, sc, dst] (fillConfig rows bits) =
      some (AneTrellisFill.text rows bits (fillPer bits)) :=
    launchTextP_eq (map_cls3 (cls_typed hcd) (cls_typed hsc) (cls_big hd h8 (by rw [foldr_two]; omega))) rfl ha
  have hl : (inPlaceGpu G).launchAll .trellisFill [cd, sc, dst] (fillConfig rows bits) = some res := by
    rw [inPlaceGpu_launch G .trellisFill _ _ ht rfl]
    show G.executeAll _ _ _ [buffer cd, buffer sc, buffer dst] [4] = _
    rw [buffer_big hcd (n := GateUp.codesBytes bits)
        (by rw [foldr_two]; simp only [Dtype.bytes, GateUp.codesBytes]; ring) (by rw [foldr_two]; omega),
      buffer_big hsc (n := 34816) rfl (by decide), buffer_dst hd h8]
    exact he
  exact writesDone_of G hl (by rw [hlen]; rfl) hB rfl (fun b hb => hbytes b (by rw [hd] at hb; exact hb)) hdone

theorem fillK3i_of (hrows : rows = 6144 ∨ rows = 6656) (ha : AneTrellisFillK3i.assembled rows = some (AneTrellisFillK3i.text rows))
    (hc : (frontend (AneTrellisFillK3i.text rows)).bind elaborate = some (AneTrellisFillK3i.core rows))
    (hmax : 128 ≤ G.maxThreads (AneTrellisFillK3i.text rows))
    (hcd : Typed cd .uint32 [10, 17408, 48]) (hsc : Typed sc .float16 [17408]) (hd : dst.dtype = .float16)
    (hn : rows * 5120 ≤ dst.size) :
    WritesDone (inPlaceGpu G) .trellisFillK3i [cd, sc, dst] (fillConfig rows 3) 2
      (AneFill.fillStored C 3 rows AneFill.k3i cd.storageByte sc.storageByte) := by
  obtain ⟨res, B, he, hlen, hB, hbytes, hdone⟩ := AneFill.gpu_output_k3i C rows (by omega) _ hc G hmax cd.storageByte
    sc.storageByte dst.storageByte 16 16 16 dst.size (by decide) (by decide) (by decide) hn
  have h8 : 8 ≤ dst.size := by omega
  have ht : launchTextP .aneTrellisFillK3i [cd, sc, dst] (fillConfig rows 3) = some (AneTrellisFillK3i.text rows) :=
    launchTextP_eq (map_cls3 (cls_typed hcd) (cls_typed hsc) (cls_big hd h8 (by rw [foldr_two]; omega))) rfl ha
  have hl : (inPlaceGpu G).launchAll .trellisFillK3i [cd, sc, dst] (fillConfig rows 3) = some res := by
    rw [inPlaceGpu_launch G .trellisFillK3i _ _ ht rfl]
    show G.executeAll _ (320, rows, 1) _ [buffer cd, buffer sc, buffer dst] [4] = _
    rw [buffer_big hcd (n := 33423360) rfl (by decide), buffer_big hsc (n := 34816) rfl (by decide), buffer_dst hd h8]
    exact he
  exact writesDone_of G hl (by rw [hlen]; rfl) hB rfl (fun b hb => hbytes b (by rw [hd] at hb; exact hb)) hdone

theorem write_of (h8 : 8 ≤ N) (hN : N < 2 ^ 31) (hmax : 256 ≤ G.maxThreads (AneWriteHalf.text N))
    (hs : src.dtype = .bfloat16) (hsz : src.size = N) (hd : dst.dtype = .float16) (hn : N ≤ dst.size) :
    WritesDone (inPlaceGpu G) .writeHalf [src, dst] (writeConfig N) 1 (AneWrite.writeStored C N src.storageByte) := by
  obtain ⟨res, B, he, hlen, hB, hbytes, hdone⟩ := AneWrite.gpu_output C N h8 hN G hmax src.storageByte dst.storageByte
    16 16 dst.size (by decide) (by decide) hn
  have ha : AneWriteHalf.assembled N = some (AneWriteHalf.text N) := by
    unfold AneWriteHalf.text; rw [AneWriteHalf.assembled_eq N h8 hN]; rfl
  have hd8 : 8 ≤ dst.size := by omega
  have ht : launchTextP .aneWriteHalf [src, dst] (writeConfig N) = some (AneWriteHalf.text N) :=
    launchTextP_eq (map_cls2 (cls_big hs (by omega) (by simp only [List.foldr_cons, List.foldr_nil]; omega))
      (cls_big hd hd8 (by simp only [List.foldr_cons, List.foldr_nil]; omega))) rfl ha
  have hbs : buffer src = ⟨.device, N * 2, 16, src.storageByte⟩ := by
    unfold buffer
    rw [ite_eq_right (by unfold Assemble.maxConstantArraySize; omega), hs, hsz]
    rfl
  have hl : (inPlaceGpu G).launchAll .writeHalf [src, dst] (writeConfig N) = some res := by
    rw [inPlaceGpu_launch G .writeHalf _ _ ht rfl]
    show G.executeAll _ _ _ [buffer src, buffer dst] [4] = _
    rw [hbs, buffer_dst hd hd8]
    exact he
  exact writesDone_of G hl (by rw [hlen]; rfl) hB rfl (fun b hb => hbytes b (by rw [hd] at hb; exact hb)) hdone

end InPlace

/-! ## gated_delta_step over `T` positions -/

section Steps
variable {T : Nat} {q k v g beta s : Value}

theorem tin_bytes (T : Nat) : (tinValue T).storageByte 0 = BitVec.ofNat 8 T ∧
    (tinValue T).storageByte 1 = BitVec.ofNat 8 (T / 2 ^ 8) ∧ (tinValue T).storageByte 2 = BitVec.ofNat 8 (T / 2 ^ 16) ∧
    (tinValue T).storageByte 3 = BitVec.ofNat 8 (T / 2 ^ 24) := by
  simp [Value.storageByte, tinValue, Dtype.bytes]

theorem steps_of (hmax : 128 ≤ G.maxThreads Metal.Elab.Tests.gatedDeltaStepText) (h1 : 1 ≤ T) (h2 : T < 2 ^ 31)
    (hq : Typed q .bfloat16 [1, T, 16, 128]) (hk : Typed k .bfloat16 [1, T, 16, 128])
    (hv : Typed v .bfloat16 [1, T, 48, 128]) (hg : Typed g .float32 [1, T, 48]) (hb : Typed beta .bfloat16 [1, T, 48])
    (hs : Typed s .float32 [1, 48, 128, 128]) :
    apply G .gatedDeltaStep [q, k, v, g, beta, s, tinValue T] (gatedConfigT T) =
      some [readOutput (GatedDeltaStep.bytes2 (12288 * T) (GatedDeltaSteps.ySteps C
          (G.fusion Metal.Elab.Tests.gatedDeltaStepText) (deltaIns q k v g beta s T))) ([1, T, 48, 128], .bfloat16),
        readOutput (GatedDeltaStep.bytes4 3145728 (GatedDeltaStep.stateOut C (G.fusion Metal.Elab.Tests.gatedDeltaStepText)
          (GatedDeltaSteps.stepAt C (G.fusion Metal.Elab.Tests.gatedDeltaStepText) (deltaIns q k v g beta s T) (T - 1))))
          ([1, 48, 128, 128], .float32)] := by
  have he := GatedDeltaSteps.gpu_output_steps C G hmax T h1 h2 q.storageByte k.storageByte v.storageByte g.storageByte
    beta.storageByte s.storageByte (tinValue T).storageByte 16 16 16 16 16 16 16 (by decide) (by decide) (by decide)
    (by decide) (by decide) (by decide) (by decide) (tin_bytes T)
  have hsz4 : ∀ {u : Value} {d : Dtype} {a b c : Nat}, Typed u d [1, a, b, c] → u.size = a * b * c := by
    intro u d a b c h; rw [size_eq h.2]; simp only [List.foldr_cons, List.foldr_nil]; ring
  have hsz3 : ∀ {u : Value} {d : Dtype} {a b : Nat}, Typed u d [1, a, b] → u.size = a * b := by
    intro u d a b h; rw [size_eq h.2]; simp only [List.foldr_cons, List.foldr_nil]; ring
  have hcls : (List.zipWith (fun n v => (⟨n, v.dtype, v.shape⟩ : Assemble.Input)) (inputNames .gatedDeltaStep)
      [q, k, v, g, beta, s, tinValue T]).map Assemble.Input.cls =
      [(⟨chars!"q", .bfloat16, [1, 1, 16, 128]⟩ : Assemble.Input), ⟨chars!"k", .bfloat16, [1, 1, 16, 128]⟩,
        ⟨chars!"v", .bfloat16, [1, 1, 48, 128]⟩, ⟨chars!"g", .float32, [1, 1, 48]⟩,
        ⟨chars!"beta", .bfloat16, [1, 1, 48]⟩, ⟨chars!"state_in", .float32, [1, 48, 128, 128]⟩,
        ⟨chars!"Tin", .int32, [1]⟩].map Assemble.Input.cls :=
    map_cls7 (cls_big hq.1 (by rw [hsz4 hq]; omega) (by decide)) (cls_big hk.1 (by rw [hsz4 hk]; omega) (by decide))
      (cls_big hv.1 (by rw [hsz4 hv]; omega) (by decide)) (cls_big hg.1 (by rw [hsz3 hg]; omega) (by decide))
      (cls_big hb.1 (by rw [hsz3 hb]; omega) (by decide)) (cls_typed hs) rfl
  have ht : launchText .gatedDeltaStep [q, k, v, g, beta, s, tinValue T] (gatedConfigT T) =
      some Metal.Elab.Tests.gatedDeltaStepText :=
    (Assemble.assemble_cls _ hcls _ _ _ _ _ _).trans Assemble.Tests.gatedDeltaStep_assemble
  have hbuf : [q, k, v, g, beta, s, tinValue T].map buffer =
      [⟨.device, 4096 * T, 16, q.storageByte⟩, ⟨.device, 4096 * T, 16, k.storageByte⟩,
        ⟨.device, 12288 * T, 16, v.storageByte⟩, ⟨.device, 192 * T, 16, g.storageByte⟩,
        ⟨.device, 96 * T, 16, beta.storageByte⟩, ⟨.device, 3145728, 16, s.storageByte⟩,
        ⟨.constant, 4, 16, (tinValue T).storageByte⟩] := by
    show [buffer q, buffer k, buffer v, buffer g, buffer beta, buffer s, buffer (tinValue T)] = _
    rw [buffer_big hq (n := 4096 * T) (by simp only [List.foldr_cons, List.foldr_nil, Dtype.bytes]; ring)
        (by simp only [List.foldr_cons, List.foldr_nil]; omega),
      buffer_big hk (n := 4096 * T) (by simp only [List.foldr_cons, List.foldr_nil, Dtype.bytes]; ring)
        (by simp only [List.foldr_cons, List.foldr_nil]; omega),
      buffer_big hv (n := 12288 * T) (by simp only [List.foldr_cons, List.foldr_nil, Dtype.bytes]; ring)
        (by simp only [List.foldr_cons, List.foldr_nil]; omega),
      buffer_big hg (n := 192 * T) (by simp only [List.foldr_cons, List.foldr_nil, Dtype.bytes]; ring)
        (by simp only [List.foldr_cons, List.foldr_nil]; omega),
      buffer_big hb (n := 96 * T) (by simp only [List.foldr_cons, List.foldr_nil, Dtype.bytes]; ring)
        (by simp only [List.foldr_cons, List.foldr_nil]; omega),
      buffer_big hs (n := 3145728) rfl (by decide)]
    rfl
  have hsizes : (gatedConfigT T).outputs.map outputSize = [12288 * T, 3145728] := by
    simp only [gatedConfigT, List.map_cons, List.map_nil, outputSize, List.foldr_cons, List.foldr_nil, Dtype.bytes,
      List.cons.injEq, and_true]
    ring
  refine apply_some G (outs := [GatedDeltaStep.bytes2 (12288 * T) (GatedDeltaSteps.ySteps C
      (G.fusion Metal.Elab.Tests.gatedDeltaStepText) (deltaIns q k v g beta s T)), GatedDeltaStep.bytes4 3145728
      (GatedDeltaStep.stateOut C (G.fusion Metal.Elab.Tests.gatedDeltaStepText) (GatedDeltaSteps.stepAt C
        (G.fusion Metal.Elab.Tests.gatedDeltaStepText) (deltaIns q k v g beta s T) (T - 1)))]) rfl rfl ht ?_ rfl
  show G.execute _ (32, 128, 48) (32, 4, 1) ([q, k, v, g, beta, s, tinValue T].map buffer)
    ((gatedConfigT T).outputs.map outputSize) = _
  rw [hbuf, hsizes]
  exact he

end Steps

/-! ## The route's instances -/

section Route
variable {G}

theorem RoutePipelines.write (P : RoutePipelines G) {N : Nat} (h : WriteRoute N) :
    256 ≤ G.maxThreads (AneWriteHalf.text N) := by
  rcases h with ⟨r, h1, h2, rfl | rfl⟩ | rfl | rfl | rfl
  exacts [P.writeHalf_5120 r h1 h2, P.writeHalf_6144 r h1 h2, P.writeHalf_qkv, P.writeHalf_zo, P.writeHalf_q]

theorem write_bounds {N : Nat} (h : WriteRoute N) : 8 ≤ N ∧ N < 2 ^ 31 := by
  rcases h with ⟨r, h1, h2, rfl | rfl⟩ | rfl | rfl | rfl <;> omega

variable (G)

theorem rows3 (P : RoutePipelines G) {r N K : Nat} (x w s b : Value) (route : Rows3Route r N K)
    (hx : Typed x .bfloat16 [r, K]) (hw : Typed w .uint32 [N, K * 3 / 32]) (hs : Typed s .bfloat16 [N, K / 64])
    (hb : Typed b .bfloat16 [N, K / 64]) :
    applyP G B .affine3Rows [x, w, s, b] (rowsConfig r N K) =
      some [readOutput (AffineRows3.expected C r N K x.storageByte w.storageByte s.storageByte b.storageByte)
        ([r, N], .bfloat16)] := by
  obtain ⟨hr, hNK⟩ := route
  simp only [List.mem_cons, Prod.mk.injEq, List.mem_nil_iff, or_false] at hNK
  have R := AffineRows3.assembled_route
  rcases hr with rfl | rfl <;> rcases hNK with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · exact rows3_of G B (by constructor <;> norm_num) (some_getD R.1) AffineRows3.compile_2_10240_5120
      P.rows3_2_10240_5120 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)
  · exact rows3_of G B (by constructor <;> norm_num) (some_getD R.2.1) AffineRows3.compile_2_6144_5120
      P.rows3_2_6144_5120 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)
  · exact rows3_of G B (by constructor <;> norm_num) (some_getD R.2.2.1) AffineRows3.compile_2_5120_6144
      P.rows3_2_5120_6144 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)
  · exact rows3_of G B (by constructor <;> norm_num) (some_getD R.2.2.2.1) AffineRows3.compile_3_10240_5120
      P.rows3_3_10240_5120 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)
  · exact rows3_of G B (by constructor <;> norm_num) (some_getD R.2.2.2.2.1) AffineRows3.compile_3_6144_5120
      P.rows3_3_6144_5120 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)
  · exact rows3_of G B (by constructor <;> norm_num) (some_getD R.2.2.2.2.2) AffineRows3.compile_3_5120_6144
      P.rows3_3_5120_6144 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)

theorem rows4 (P : RoutePipelines G) {r N K : Nat} (x w s b : Value) (route : Rows4Route r N K)
    (hx : Typed x .bfloat16 [r, K]) (hw : Typed w .uint32 [N, K / 8]) (hs : Typed s .bfloat16 [N, K / 64])
    (hb : Typed b .bfloat16 [N, K / 64]) :
    applyP G B .affine4Rows [x, w, s, b] (rowsConfig r N K) =
      some [readOutput (AffineRows4.expected C r N K x.storageByte w.storageByte s.storageByte b.storageByte)
        ([r, N], .bfloat16)] := by
  obtain ⟨hr, hNK⟩ := route
  simp only [List.mem_cons, Prod.mk.injEq, List.mem_nil_iff, or_false] at hNK
  have R := AffineRows4.assembled_route
  rcases hr with rfl | rfl <;>
    rcases hNK with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · exact rows4_of G B (by constructor <;> norm_num) (some_getD R.1) AffineRows4.compile_2_10240_5120
      P.rows4_2_10240_5120 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)
  · exact rows4_of G B (by constructor <;> norm_num) (some_getD R.2.1) AffineRows4.compile_2_6144_5120
      P.rows4_2_6144_5120 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)
  · exact rows4_of G B (by constructor <;> norm_num) (some_getD R.2.2.1) AffineRows4.compile_2_48_5120
      P.rows4_2_48_5120 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)
  · exact rows4_of G B (by constructor <;> norm_num) (some_getD R.2.2.2.1) AffineRows4.compile_2_5120_6144
      P.rows4_2_5120_6144 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)
  · exact rows4_of G B (by constructor <;> norm_num) (some_getD R.2.2.2.2.1) AffineRows4.compile_2_12288_5120
      P.rows4_2_12288_5120 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)
  · exact rows4_of G B (by constructor <;> norm_num) (some_getD R.2.2.2.2.2.1) AffineRows4.compile_2_1024_5120
      P.rows4_2_1024_5120 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)
  · exact rows4_of G B (by constructor <;> norm_num) (some_getD R.2.2.2.2.2.2.1) AffineRows4.compile_3_10240_5120
      P.rows4_3_10240_5120 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)
  · exact rows4_of G B (by constructor <;> norm_num) (some_getD R.2.2.2.2.2.2.2.1) AffineRows4.compile_3_6144_5120
      P.rows4_3_6144_5120 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)
  · exact rows4_of G B (by constructor <;> norm_num) (some_getD R.2.2.2.2.2.2.2.2.1) AffineRows4.compile_3_48_5120
      P.rows4_3_48_5120 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)
  · exact rows4_of G B (by constructor <;> norm_num) (some_getD R.2.2.2.2.2.2.2.2.2.1) AffineRows4.compile_3_5120_6144
      P.rows4_3_5120_6144 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)
  · exact rows4_of G B (by constructor <;> norm_num) (some_getD R.2.2.2.2.2.2.2.2.2.2.1)
      AffineRows4.compile_3_12288_5120 P.rows4_3_12288_5120 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)
  · exact rows4_of G B (by constructor <;> norm_num) (some_getD R.2.2.2.2.2.2.2.2.2.2.2)
      AffineRows4.compile_3_1024_5120 P.rows4_3_1024_5120 hx hw hs hb (by norm_num) (by norm_num) (by norm_num)

theorem split (P : RoutePipelines G) {r N K bits : Nat} (x w s b : Value) (route : SplitRoute N K bits) (hr : 4 ≤ r)
    (hr' : r ≤ 223) (hx : Typed x .bfloat16 [r, K]) (hw : Typed w .uint32 [N, K * bits / 32])
    (hs : Typed s .bfloat16 [N, K / 64]) (hb : Typed b .bfloat16 [N, K / 64]) :
    applyP G B .affineSplitMma [x, w, s, b] (splitConfig r N K bits) =
      some [readOutput (AffineSplitMma.expected C N K bits (splitPlan N).1 (splitPlan N).2 r x.storageByte
        w.storageByte s.storageByte b.storageByte) ([r, N], .bfloat16)] := by
  simp only [SplitRoute, List.mem_cons, Prod.mk.injEq, List.mem_nil_iff, or_false] at route
  have R := AffineSplitMma.assembled_route
  rcases route with ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ |
    ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩
  · exact split_of G B (tiles := 2) (splits := 2) (by decide) (by decide) (by decide) (by decide) (by decide)
      (by decide) (by decide) (by decide) (by decide) (by decide) (some_getD R.1) AffineSplitMma.compile_10240_5120_3
      P.split_10240_5120_3 hr hr' hx hw hs hb (by norm_num) (by norm_num)
  · exact split_of G B (tiles := 2) (splits := 2) (by decide) (by decide) (by decide) (by decide) (by decide)
      (by decide) (by decide) (by decide) (by decide) (by decide) (some_getD R.2.1) AffineSplitMma.compile_10240_5120_4
      P.split_10240_5120_4 hr hr' hx hw hs hb (by norm_num) (by norm_num)
  · exact split_of G B (tiles := 2) (splits := 2) (by decide) (by decide) (by decide) (by decide) (by decide)
      (by decide) (by decide) (by decide) (by decide) (by decide) (some_getD R.2.2.1) AffineSplitMma.compile_6144_5120_3
      P.split_6144_5120_3 hr hr' hx hw hs hb (by norm_num) (by norm_num)
  · exact split_of G B (tiles := 2) (splits := 2) (by decide) (by decide) (by decide) (by decide) (by decide)
      (by decide) (by decide) (by decide) (by decide) (by decide) (some_getD R.2.2.2.1)
      AffineSplitMma.compile_6144_5120_4 P.split_6144_5120_4 hr hr' hx hw hs hb (by norm_num) (by norm_num)
  · exact split_of G B (tiles := 1) (splits := 8) (by decide) (by decide) (by decide) (by decide) (by decide)
      (by decide) (by decide) (by decide) (by decide) (by decide) (some_getD R.2.2.2.2.1)
      AffineSplitMma.compile_48_5120_4 P.split_48_5120_4 hr hr' hx hw hs hb (by norm_num) (by norm_num)
  · exact split_of G B (tiles := 2) (splits := 2) (by decide) (by decide) (by decide) (by decide) (by decide)
      (by decide) (by decide) (by decide) (by decide) (by decide) (some_getD R.2.2.2.2.2.1)
      AffineSplitMma.compile_5120_6144_3 P.split_5120_6144_3 hr hr' hx hw hs hb (by norm_num) (by norm_num)
  · exact split_of G B (tiles := 2) (splits := 2) (by decide) (by decide) (by decide) (by decide) (by decide)
      (by decide) (by decide) (by decide) (by decide) (by decide) (some_getD R.2.2.2.2.2.2.1)
      AffineSplitMma.compile_5120_6144_4 P.split_5120_6144_4 hr hr' hx hw hs hb (by norm_num) (by norm_num)
  · exact split_of G B (tiles := 2) (splits := 2) (by decide) (by decide) (by decide) (by decide) (by decide)
      (by decide) (by decide) (by decide) (by decide) (by decide) (some_getD R.2.2.2.2.2.2.2.1)
      AffineSplitMma.compile_12288_5120_4 P.split_12288_5120_4 hr hr' hx hw hs hb (by norm_num) (by norm_num)
  · exact split_of G B (tiles := 1) (splits := 8) (by decide) (by decide) (by decide) (by decide) (by decide)
      (by decide) (by decide) (by decide) (by decide) (by decide) (some_getD R.2.2.2.2.2.2.2.2)
      AffineSplitMma.compile_1024_5120_4 P.split_1024_5120_4 hr hr' hx hw hs hb (by norm_num) (by norm_num)

theorem codebook (P : RoutePipelines G) {r kg ku : Nat} (x gc gs uc us : Value) (route : GateUpRoute kg ku)
    (hr : 2 ≤ r) (hr8 : r ≤ 8) (hx : Typed x .bfloat16 [r, 5120]) (hgc : Typed gc .uint32 [17408, 160 * kg])
    (hgs : Typed gs .float16 [17408]) (huc : Typed uc .uint32 [17408, 160 * ku]) (hus : Typed us .float16 [17408]) :
    applyP G B .gateUpCodebookMma [x, gc, gs, uc, us] (codebookConfig r kg ku) =
      some [readOutput (CodebookMma.expected C kg ku x.storageByte gc.storageByte gs.storageByte uc.storageByte
        us.storageByte r) ([r, 17408], .bfloat16)] := by
  simp only [GateUpRoute, List.mem_cons, Prod.mk.injEq, List.mem_nil_iff, or_false] at route
  have R := GateUpCodebookMma.assembled_route
  rcases route with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · exact codebook_of G B GateUp.width_2 GateUp.width_2 (some_getD R.1) GateUpCodebookMma.compile_2_2 P.codebook_2_2
      hr hr8 hx hgc hgs huc hus (by decide) (by decide)
  · exact codebook_of G B GateUp.width_3 GateUp.width_3 (some_getD R.2.1) GateUpCodebookMma.compile_3_3 P.codebook_3_3
      hr hr8 hx hgc hgs huc hus (by decide) (by decide)
  · exact codebook_of G B GateUp.width_3 GateUp.width_2 (some_getD R.2.2.1) GateUpCodebookMma.compile_3_2
      P.codebook_3_2 hr hr8 hx hgc hgs huc hus (by decide) (by decide)
  · exact codebook_of G B GateUp.width_2 GateUp.width_3 (some_getD R.2.2.2.1) GateUpCodebookMma.compile_2_3
      P.codebook_2_3 hr hr8 hx hgc hgs huc hus (by decide) (by decide)
  · exact codebook_of G B GateUp.width_4 GateUp.width_3 (some_getD R.2.2.2.2.1) GateUpCodebookMma.compile_4_3
      P.codebook_4_3 hr hr8 hx hgc hgs huc hus (by decide) (by decide)
  · exact codebook_of G B GateUp.width_4 GateUp.width_4 (some_getD R.2.2.2.2.2.1) GateUpCodebookMma.compile_4_4
      P.codebook_4_4 hr hr8 hx hgc hgs huc hus (by decide) (by decide)
  · exact codebook_of G B GateUp.width_3 GateUp.width_4 (some_getD R.2.2.2.2.2.2) GateUpCodebookMma.compile_3_4
      P.codebook_3_4 hr hr8 hx hgc hgs huc hus (by decide) (by decide)

theorem wide (P : RoutePipelines G) {r kg ku : Nat} (x gc gs uc us : Value) (route : GateUpRoute kg ku)
    (hr : 9 ≤ r) (hr' : r ≤ 223) (hx : Typed x .bfloat16 [r, 5120]) (hgc : Typed gc .uint32 [17408, 160 * kg])
    (hgs : Typed gs .float16 [17408]) (huc : Typed uc .uint32 [17408, 160 * ku]) (hus : Typed us .float16 [17408]) :
    applyP G B .gateUpMmaWide [x, gc, gs, uc, us] (wideConfig r kg ku) =
      some [readOutput (GateUpMmaWide.expected C kg ku r x.storageByte gc.storageByte gs.storageByte uc.storageByte
        us.storageByte) ([r, 17408], .bfloat16)] := by
  simp only [GateUpRoute, List.mem_cons, Prod.mk.injEq, List.mem_nil_iff, or_false] at route
  have R := GateUpMmaWide.assembled_route
  rcases route with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · exact wide_of G B GateUp.width_2 GateUp.width_2 (some_getD R.1) (some_getD R.2.2.2.2.2.2.2.1)
      GateUpMmaWide.compile_2_2_2 GateUpMmaWide.compile_2_2_3 P.wide_2_2_2 P.wide_2_2_3 hr hr' hx hgc hgs huc hus
      (by decide) (by decide)
  · exact wide_of G B GateUp.width_3 GateUp.width_3 (some_getD R.2.1) (some_getD R.2.2.2.2.2.2.2.2.1)
      GateUpMmaWide.compile_3_3_2 GateUpMmaWide.compile_3_3_3 P.wide_3_3_2 P.wide_3_3_3 hr hr' hx hgc hgs huc hus
      (by decide) (by decide)
  · exact wide_of G B GateUp.width_3 GateUp.width_2 (some_getD R.2.2.1) (some_getD R.2.2.2.2.2.2.2.2.2.1)
      GateUpMmaWide.compile_3_2_2 GateUpMmaWide.compile_3_2_3 P.wide_3_2_2 P.wide_3_2_3 hr hr' hx hgc hgs huc hus
      (by decide) (by decide)
  · exact wide_of G B GateUp.width_2 GateUp.width_3 (some_getD R.2.2.2.1) (some_getD R.2.2.2.2.2.2.2.2.2.2.1)
      GateUpMmaWide.compile_2_3_2 GateUpMmaWide.compile_2_3_3 P.wide_2_3_2 P.wide_2_3_3 hr hr' hx hgc hgs huc hus
      (by decide) (by decide)
  · exact wide_of G B GateUp.width_4 GateUp.width_3 (some_getD R.2.2.2.2.1) (some_getD R.2.2.2.2.2.2.2.2.2.2.2.1)
      GateUpMmaWide.compile_4_3_2 GateUpMmaWide.compile_4_3_3 P.wide_4_3_2 P.wide_4_3_3 hr hr' hx hgc hgs huc hus
      (by decide) (by decide)
  · exact wide_of G B GateUp.width_4 GateUp.width_4 (some_getD R.2.2.2.2.2.1) (some_getD R.2.2.2.2.2.2.2.2.2.2.2.2.1)
      GateUpMmaWide.compile_4_4_2 GateUpMmaWide.compile_4_4_3 P.wide_4_4_2 P.wide_4_4_3 hr hr' hx hgc hgs huc hus
      (by decide) (by decide)
  · exact wide_of G B GateUp.width_3 GateUp.width_4 (some_getD R.2.2.2.2.2.2.1) (some_getD R.2.2.2.2.2.2.2.2.2.2.2.2.2)
      GateUpMmaWide.compile_3_4_2 GateUpMmaWide.compile_3_4_3 P.wide_3_4_2 P.wide_3_4_3 hr hr' hx hgc hgs huc hus
      (by decide) (by decide)

theorem down (P : RoutePipelines G) {M k s mt : Nat} (x cd sc : Value) (route : DownRoute k s mt) (hM : 2 ≤ M)
    (hM' : M ≤ 223) (hx : Typed x .bfloat16 [M, 17408]) (hcd : Typed cd .uint32 [17408, 160 * k])
    (hsc : Typed sc .float16 [17408]) :
    applyP G B .downMmaWide [x, cd, sc] (downConfig' M k s mt 0) =
      some [readOutput (DownMmaWide.expected C k false s mt M x.storageByte cd.storageByte sc.storageByte)
        ([M, 8, 5120], .float32)] := by
  simp only [DownRoute, List.mem_cons, Prod.mk.injEq, List.mem_nil_iff, or_false] at route
  have R := DownMmaWide.assembled_route
  rcases route with ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ |
    ⟨rfl, rfl, rfl⟩
  · exact down_of G B (.inl ⟨rfl, rfl, rfl, rfl, rfl⟩) (some_getD R.1) DownMmaWide.compile_2_16_1 P.down_2_16_1
      (by decide) hM hM' hx hcd hsc (by decide)
  · exact down_of G B (.inr (.inl ⟨rfl, rfl, rfl, rfl, rfl⟩)) (some_getD R.2.1) DownMmaWide.compile_4_16_1
      P.down_4_16_1 (by decide) hM hM' hx hcd hsc (by decide)
  · exact down_of G B (.inr (.inr (.inl ⟨rfl, rfl, rfl, rfl, rfl⟩))) (some_getD R.2.2.1) DownMmaWide.compile_2_8_2
      P.down_2_8_2 (by decide) hM hM' hx hcd hsc (by decide)
  · exact down_of G B (.inr (.inr (.inr (.inl ⟨rfl, rfl, rfl, rfl, rfl⟩)))) (some_getD R.2.2.2.1)
      DownMmaWide.compile_4_8_2 P.down_4_8_2 (by decide) hM hM' hx hcd hsc (by decide)
  · exact down_of G B (.inr (.inr (.inr (.inr (.inl ⟨rfl, rfl, rfl, rfl, rfl⟩))))) (some_getD R.2.2.2.2.1)
      DownMmaWide.compile_2_8_3 P.down_2_8_3 (by decide) hM hM' hx hcd hsc (by decide)
  · exact down_of G B (.inr (.inr (.inr (.inr (.inr (.inl ⟨rfl, rfl, rfl, rfl, rfl⟩)))))) (some_getD R.2.2.2.2.2)
      DownMmaWide.compile_4_8_3 P.down_4_8_3 (by decide) hM hM' hx hcd hsc (by decide)

theorem fill (P : RoutePipelines G) {rows bits : Nat} (cd sc dst : Value) (route : FillRoute rows bits)
    (hcd : Typed cd .uint32 [17408, 160 * bits]) (hsc : Typed sc .float16 [17408]) (hd : dst.dtype = .float16)
    (hn : rows * 5120 ≤ dst.size) :
    WritesDone (inPlaceGpu G) .trellisFill [cd, sc, dst] (fillConfig rows bits) 2
      (AneFill.fillStored C bits rows (AneFill.rowMajor bits) cd.storageByte sc.storageByte) := by
  obtain ⟨hr, hb⟩ := route
  have R := AneTrellisFill.assembled_route
  rcases hr with rfl | rfl <;> rcases hb with rfl | rfl | rfl
  · exact fill_of G (.inl rfl) (by decide) (some_getD R.1) AneTrellisFill.compile_6144_2 P.fill_6144_2 hcd hsc hd hn
  · exact fill_of G (.inr (.inl rfl)) (by decide) (some_getD R.2.1) AneTrellisFill.compile_6144_3 P.fill_6144_3 hcd
      hsc hd hn
  · exact fill_of G (.inr (.inr rfl)) (by decide) (some_getD R.2.2.1) AneTrellisFill.compile_6144_4 P.fill_6144_4 hcd
      hsc hd hn
  · exact fill_of G (.inl rfl) (by decide) (some_getD R.2.2.2.1) AneTrellisFill.compile_6656_2 P.fill_6656_2 hcd hsc
      hd hn
  · exact fill_of G (.inr (.inl rfl)) (by decide) (some_getD R.2.2.2.2.1) AneTrellisFill.compile_6656_3 P.fill_6656_3
      hcd hsc hd hn
  · exact fill_of G (.inr (.inr rfl)) (by decide) (some_getD R.2.2.2.2.2) AneTrellisFill.compile_6656_4 P.fill_6656_4
      hcd hsc hd hn

theorem fillK3i (P : RoutePipelines G) {rows : Nat} (cd sc dst : Value) (route : rows = 6144 ∨ rows = 6656)
    (hcd : Typed cd .uint32 [10, 17408, 48]) (hsc : Typed sc .float16 [17408]) (hd : dst.dtype = .float16)
    (hn : rows * 5120 ≤ dst.size) :
    WritesDone (inPlaceGpu G) .trellisFillK3i [cd, sc, dst] (fillConfig rows 3) 2
      (AneFill.fillStored C 3 rows AneFill.k3i cd.storageByte sc.storageByte) := by
  have R := AneTrellisFillK3i.assembled_route
  rcases route with rfl | rfl
  · exact fillK3i_of G (.inl rfl) (some_getD R.1) AneTrellisFillK3i.compile_6144 P.fillK3i_6144 hcd hsc hd hn
  · exact fillK3i_of G (.inr rfl) (some_getD R.2) AneTrellisFillK3i.compile_6656 P.fillK3i_6656 hcd hsc hd hn

theorem write (P : RoutePipelines G) {N : Nat} (src dst : Value) (route : WriteRoute N) (hs : src.dtype = .bfloat16)
    (hsz : src.size = N) (hd : dst.dtype = .float16) (hn : N ≤ dst.size) :
    WritesDone (inPlaceGpu G) .writeHalf [src, dst] (writeConfig N) 1 (AneWrite.writeStored C N src.storageByte) :=
  write_of G (write_bounds route).1 (write_bounds route).2 (P.write route) hs hsz hd hn

theorem expand (P : RoutePipelines G) {R bits il rt : Nat} (cd sc : Value) (route : ExpandRoute R bits il rt)
    (hcd : Typed cd .uint32 (expandCodes R bits il)) (hsc : Typed sc .float16 [R]) :
    applyP G B .vectorExpand [cd, sc] (expandConfig R bits il rt) =
      some [readOutput (VectorExpand.expected C R bits (il != 0) cd.storageByte sc.storageByte)
        ([R, 5120], .bfloat16)] := by
  obtain ⟨hR, hi⟩ := route
  have A := VectorExpand.assembled_route
  rcases hR with rfl | rfl <;> rcases hi with ⟨rfl, rfl, rfl | rfl | rfl⟩ | ⟨rfl, rfl, rfl⟩
  · exact expand_of G B none (by decide) (by norm_num) (by norm_num) trivial rfl (some_getD A.1)
      VectorExpand.compile_11264_2 P.expand_11264_2 hcd hsc (by decide) (by decide)
  · exact expand_of G B none (by decide) (by norm_num) (by norm_num) trivial rfl (some_getD A.2.1)
      VectorExpand.compile_11264_3 P.expand_11264_3 hcd hsc (by decide) (by decide)
  · exact expand_of G B none (by decide) (by norm_num) (by norm_num) trivial rfl (some_getD A.2.2.1)
      VectorExpand.compile_11264_4 P.expand_11264_4 hcd hsc (by decide) (by decide)
  · exact expand_of G B (some 128) (by decide) (by norm_num) (by norm_num) ⟨by decide, 88, by norm_num⟩ rfl
      (some_getD A.2.2.2.2.2.2.1) VectorExpand.compile_11264_k3i P.expand_11264_k3i hcd hsc (by decide) (by decide)
  · exact expand_of G B none (by decide) (by norm_num) (by norm_num) trivial rfl (some_getD A.2.2.2.1)
      VectorExpand.compile_10752_2 P.expand_10752_2 hcd hsc (by decide) (by decide)
  · exact expand_of G B none (by decide) (by norm_num) (by norm_num) trivial rfl (some_getD A.2.2.2.2.1)
      VectorExpand.compile_10752_3 P.expand_10752_3 hcd hsc (by decide) (by decide)
  · exact expand_of G B none (by decide) (by norm_num) (by norm_num) trivial rfl (some_getD A.2.2.2.2.2.1)
      VectorExpand.compile_10752_4 P.expand_10752_4 hcd hsc (by decide) (by decide)
  · exact expand_of G B (some 128) (by decide) (by norm_num) (by norm_num) ⟨by decide, 84, by norm_num⟩ rfl
      (some_getD A.2.2.2.2.2.2.2) VectorExpand.compile_10752_k3i P.expand_10752_k3i hcd hsc (by decide) (by decide)

end Route

/-! ## The contract -/

/-- **The route's kernel contract over the decode and prefill kernels, from the GPU assumption.** Its decode part is
`ofGpu G P lseSum lseNumerator` (`ofGpuRoute_decode`); `applyP` and `inPlace` are MLX's launches run by `G`, shape
buffers at the trusted `setBytes` alignment `B`; the gated delta's contraction choices are `G.fusion` of its text;
every prefill field is proved from its kernel's Metal source. -/
def ofGpuRoute (P : RoutePipelines G) (lseSum : Bool) (lseNumerator : Attention.SdpaUpdate.Contraction) :
    RouteKernelContract C where
  toKernelContract := ofGpu G P lseSum lseNumerator
  applyP := applyP G B
  inPlace := inPlaceGpu G
  deltaFusion := G.fusion Metal.Elab.Tests.gatedDeltaStepText
  deltaFlags_eq := rfl
  affine3Rows := rows3 G B P
  affine4Rows := rows4 G B P
  affineSplitMma := split G B P
  gateUpCodebookMma := codebook G B P
  gateUpMmaWide := wide G B P
  downMmaWide := down G B P
  downK3iMmaWide _ _ _ hM hM' hx hcd hsc := downK3i_of G B P.downK3i hM hM' hx hcd hsc
  aneTrellisFill := fill G P
  aneTrellisFillK3i := fillK3i G P
  aneWriteHalf := write G P
  vectorExpand := expand G B P
  gatedDeltaSteps _ _ _ _ _ _ h2 h3 hq hk hv hg hb hs :=
    steps_of G P.gatedDeltaStep (by omega) (by omega) hq hk hv hg hb hs

/-- The decode part is `ofGpu`, unchanged. -/
theorem ofGpuRoute_decode (P : RoutePipelines G) (lseSum : Bool) (lseNumerator : Attention.SdpaUpdate.Contraction) :
    (ofGpuRoute G B P lseSum lseNumerator).toKernelContract = ofGpu G P lseSum lseNumerator := rfl

end Host.Mlx.KernelGpu

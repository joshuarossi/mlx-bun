import host.mlx.KernelGpu
import host.mlx.RouteKernel
import host.mlx.InPlace
import metal.kernels.AffineRows3
import metal.kernels.AffineRows4
import metal.kernels.AffineSplitMma
import metal.kernels.GateUpCodebookMma
import metal.kernels.GateUpMmaWide
import metal.kernels.DownMmaWide
import metal.kernels.DownK3iMmaWide
import metal.kernels.AneTrellisFill
import metal.kernels.AneTrellisFillK3i
import metal.kernels.AneWriteHalf
import metal.kernels.VectorExpand
import metal.bridge.GatedDeltaSteps
namespace Host.Mlx
open Inference.Contracts.Mlx Inference.Kernels
open Metal.Kernels
open Host.Mlx.PrefillSources (PrefillKernel)

/-! # The route's kernel contract over the prefill kernels

`RouteKernelContract` extends the decode kernel contract (`KernelContract`, unchanged) with the prefill
kernels: `applyP`, MLX's custom-kernel launch of a prefill kernel (its outputs); `inPlace`, the launch of an
in-place kernel with every buffer's final contents (the Neural Engine host model's interface,
`FfiAneEval.InPlace`); `deltaFusion`, the compiler's contraction choices in gated_delta_step's text, whose
three accumulation sites are the decode contract's `flags`. One field per prefill kernel states, for every
launch configuration the route issues (prefill-map §3–4; the row count a parameter with its route range),
its outputs as the kernel's expected-output definition (the machine-level spec of
proofs/metal/kernels/<Name>.lean on the inputs' row-major bytes, with `C`'s operations) read back with the
call's dtype and shape (`KernelGpu.readOutput`); an in-place kernel's field states that the launch writes its
destination input through with the kernel's stores (`FfiAneEval.WritesThrough`) and sets `done`.
`gatedDeltaSteps` is the decode kernel gated_delta_step launched on `T` positions (same text; `T` arrives in
`Tin`). `KernelGpuPrefill.ofGpuRoute` builds the contract from the GPU assumption and proves every field from
its kernel's Metal source. -/

/-- `v` has dtype `d` and shape `s`. -/
def Typed (v : Value) (d : Dtype) (s : List Nat) : Prop := v.dtype = d ∧ v.shape = s

/-! ## The Neural Engine host model's in-place kernels

Three of the prefill kernels write through an input (`FfiAneEval.InPlaceKernel`); their names and bodies are the
prefill table's (`inPlaceOf_prefill`, `inPlaceSources`). -/

/-- The prefill kernel an in-place kernel is. -/
def FfiAneEval.InPlaceKernel.prefill : FfiAneEval.InPlaceKernel → PrefillKernel
  | .trellisFill => .aneTrellisFill
  | .trellisFillK3i => .aneTrellisFillK3i
  | .writeHalf => .aneWriteHalf

/-- The in-place kernel a prefill kernel is, if it writes through an input. -/
def PrefillSources.PrefillKernel.inPlace? : PrefillKernel → Option FfiAneEval.InPlaceKernel
  | .aneTrellisFill => some .trellisFill
  | .aneTrellisFillK3i => some .trellisFillK3i
  | .aneWriteHalf => some .writeHalf
  | _ => none

theorem inPlace?_prefill (k : FfiAneEval.InPlaceKernel) : k.prefill.inPlace? = some k := by cases k <;> rfl

theorem prefill_inPlace? {p : PrefillKernel} {k : FfiAneEval.InPlaceKernel} (h : p.inPlace? = some k) :
    k.prefill = p := by
  cases p <;> simp [PrefillSources.PrefillKernel.inPlace?] at h <;> subst h <;> rfl

/-- The in-place names are the prefill kernels' (`PrefillSources.name`). -/
theorem inPlaceOf_prefill {name : List Char} {k : FfiAneEval.InPlaceKernel} (h : FfiAneEval.inPlaceOf name = some k) :
    PrefillSources.name k.prefill = name ∧ routeKernelOf name = some (.prefill k.prefill) := by
  have hn : PrefillSources.name k.prefill = name := by
    unfold FfiAneEval.inPlaceOf at h
    obtain ⟨p, hp, rfl⟩ := Option.map_eq_some_iff.mp h
    have he := List.find?_some hp
    simp only [decide_eq_true_eq] at he
    have hall : ∀ q ∈ FfiAneEval.inPlaceNames, PrefillSources.name q.2.prefill = q.1 := by decide +kernel
    rw [hall p (List.mem_of_find?_eq_some hp), he]
  exact ⟨hn, hn ▸ routeKernelOf_prefill k.prefill⟩

/-- The in-place kernels' bodies: the prefill table's. -/
def inPlaceSources : FfiAneEval.InPlaceSources :=
  ⟨fun k => PrefillSources.source k.prefill, fun k => PrefillSources.header k.prefill⟩

/-- A writer the Neural Engine graph reads (`FfiAneEval.writerOf` with `inPlaceSources`) is a kernel object the table
resolves, to its in-place kernel's prefill kernel. -/
theorem writer_route (S : FfiEval.KernelSources) {s : Ffi.St} {kh : Nat} {name src hdr : List Char}
    {nIn nOut : Nat}
    {k : FfiAneEval.InPlaceKernel} (ho : s.obj? kh = some (.kernel name src hdr nIn nOut))
    (hk : FfiAneEval.inPlaceOf name = some k) (hs : src = inPlaceSources.source k ∧ hdr = inPlaceSources.header k) :
    routeKernelName? S s kh = some name := by
  obtain ⟨_, hr⟩ := inPlaceOf_prefill hk
  unfold routeKernelName?
  rw [ho]
  show ((routeKernelOf name).bind fun k => if src = k.sourceWith S ∧ hdr = k.headerWith S then some name else none) =
    some name
  rw [hr, Option.bind_some]
  exact ite_eq_left hs

/-! ## The launches the route issues -/

/-- affine3-rows.ts / affine4-rows.ts `affine3Rows`/`affine4Rows` on `x` `[r, K]` (2 ≤ r ≤ 8) with `N` outputs:
NR 4, SGS 2, VPT 16; grid `[32·SGS, ⌈N/(NR·SGS)⌉, 1]`. -/
def rowsConfig (r N K : Nat) : Config :=
  ⟨[([r, N], .bfloat16)], (64, (N + 7) / 8, 1), (64, 1, 1), [("T", .bfloat16)],
    [("M", r), ("N", N), ("K", K), ("NR", 4), ("SGS", 2), ("VPT", 16)], none⟩

/-- affine-split-mma.ts `affineSplitMmaPlan`: two tiles over two splits for `N ≥ 2048` (a multiple of 16), else one
tile over eight. -/
def splitPlan (N : Nat) : Nat × Nat := if 2048 ≤ N ∧ N % 16 = 0 then (2, 2) else (1, 8)

/-- affine-split-mma.ts `affineSplitMma` on `x` `[r, K]` with `N` outputs at `bits` under `splitPlan N`: grid
`[32·SPLITS, N/(8·TILES), ⌈r/8⌉]`. -/
def splitConfig (r N K bits : Nat) : Config :=
  ⟨[([r, N], .bfloat16)], (32 * (splitPlan N).2, N / (8 * (splitPlan N).1), (r + 7) / 8), (32 * (splitPlan N).2, 1, 1),
    [("T", .bfloat16)], [("N", N), ("K", K), ("BITS", bits), ("TILES", (splitPlan N).1), ("SPLITS", (splitPlan N).2)],
    none⟩

/-- gate-up-codebook-mma.ts `gateUpCodebookMma` on `x` `[r, 5120]` (1 ≤ r ≤ 8), gate and up widths `kg`, `ku`
(rows 17408, T 256, L 12, SG_TG 4): grid `[32·SG_TG, ⌈17408/8/SG_TG⌉, 1]`. -/
def codebookConfig (r kg ku : Nat) : Config :=
  ⟨[([r, 17408], .bfloat16)], (128, 544, 1), (128, 1, 1), [("T", .bfloat16)],
    [("R", 17408), ("C", 5120), ("BT", 256), ("KG", kg), ("KU", ku), ("L", 12), ("SG_TG", 4)], none⟩

/-- gate-up-mma-wide.ts `gateUpMmaWide` on `x` `[r, 5120]` (SG_TG 8, `MT = rowBlocks r`): grid `[32·SG_TG,
⌈17408/8/SG_TG⌉, ⌈r/(8·MT)⌉]`. -/
def wideConfig (r kg ku : Nat) : Config :=
  ⟨[([r, 17408], .bfloat16)], (256, 272, Metal.ceilDiv r (8 * GateUpMmaWide.rowBlocks r)), (256, 1, 1),
    [("T", .bfloat16)],
    [("R", 17408), ("C", 5120), ("BT", 256), ("KG", kg), ("KU", ku), ("L", 12), ("SG_TG", 8),
      ("MT", GateUpMmaWide.rowBlocks r)], none⟩

/-- down-mma-wide.ts `launch`: `NW = ⌈(2·S·K + L − 1)/32⌉ + 1` words at L 12. -/
def downWords (k s : Nat) : Nat := (2 * s * k + 11 + 31) / 32 + 1

/-- down-mma-wide.ts `launch` on `x` `[M, 17408]` at code width `k`, pass `(S, MT)` and layout `il` (0 row-major,
1 the 3-bit block interleave): `nGroups = (5120/256)·(32/S)`, grid `[32·SG_TG, ⌈8·nGroups/SG_TG⌉, ⌈M/(8·MT)⌉]`,
`partial` `[M, 8, 5120]` f32. -/
def downConfig' (M k s mt il : Nat) : Config :=
  ⟨[([M, 8, 5120], .float32)], (128, (5120 / 256 * (32 / s) * 8 + 3) / 4, Metal.ceilDiv M (8 * mt)), (128, 1, 1),
    [("T", .bfloat16)],
    [("R", 17408), ("C", 5120), ("K", k), ("L", 12), ("SPLITS", 8), ("SG_TG", 4), ("INTERLEAVE", il), ("MT", mt),
      ("S", s), ("NW", downWords k s)], none⟩

/-- fill.ts `perThread`: 8 weights a thread at 4 bits, else 16. -/
def fillPer (bits : Nat) : Nat := if bits = 4 then 8 else 16

/-- fill.ts `launch` (`OFFSET` 0) of `rows` stored rows at code width `bits` (gate/up/down rows 17408, cols 5120, T 256,
L 12): grid `[5120/PER, rows, 1]`, `done` int32 `[1]`. -/
def fillConfig (rows bits : Nat) : Config :=
  ⟨[([1], .int32)], (5120 / fillPer bits, rows, 1), (128, 1, 1), [],
    [("R", 17408), ("ROWS", rows), ("C", 5120), ("BT", 256), ("BITS", bits), ("L", 12), ("OFFSET", 0),
      ("PER", fillPer bits)], none⟩

/-- fill.ts `writeHalf` (`OFFSET` 0) of a bf16 `src` of `N` elements: grid `[⌈N/256⌉·256, 1, 1]`. -/
def writeConfig (N : Nat) : Config :=
  ⟨[([1], .int32)], ((N + 255) / 256 * 256, 1, 1), (256, 1, 1), [("T", .bfloat16)], [("N", N), ("OFFSET", 0)], none⟩

/-- vector-expand.ts `vectorTrellisExpand` of `R` rows at width `bits`, layout `il` (0 row-major, 2 the 3-bit block
interleave) and row tile `rt` (128 for the interleave, else 0): grid `[5120/4·R, 1, 1]` with a row tile, else
`[5120/4, R, 1]`. -/
def expandConfig (R bits il rt : Nat) : Config :=
  ⟨[([R, 5120], .bfloat16)], if rt = 0 then (1280, R, 1) else (1280 * R, 1, 1), (128, 1, 1), [("T", .bfloat16)],
    [("R", R), ("C", 5120), ("BT", 256), ("BITS", bits), ("L", 12), ("INTERLEAVE", il), ("ROW_TILE", rt)], none⟩

/-- The codes of a vector expansion: row-major `uint32 [R, 160·bits]`, or `[10, R, 48]` interleaved. -/
def expandCodes (R bits il : Nat) : List Nat := if il = 0 then [R, 160 * bits] else [10, R, 48]

/-- gated.ts `launchRecurrence` (no mask) for B = 1 and `T` positions. -/
def gatedConfigT (T : Nat) : Config :=
  ⟨[([1,T,48,128], .bfloat16), ([1,48,128,128], .float32)], (32, 128, 48), (32, 4, 1),
    [("InT", .bfloat16), ("StT", .float32)], [("Dk", 128), ("Dv", 128), ("Hk", 16), ("Hv", 48)], none⟩

/-- `MlxArray.fromInt32([T], [1])`: gated_delta_step's `Tin`. -/
def tinValue (T : Nat) : Value := ⟨.int32, [1], fun _ => T⟩

/-- The `T`-step launch's input bytes. -/
def deltaIns (q k v g beta s : Value) (T : Nat) : GatedDeltaStep.Ins :=
  ⟨q.storageByte, k.storageByte, v.storageByte, g.storageByte, beta.storageByte, s.storageByte,
    (tinValue T).storageByte⟩

/-! ## The route's instances (prefill-map §2–4) -/

/-- V23 forwards' 3-bit affine rows launches (in_proj_qkv, in_proj_z, out_proj of the 3-bit layers): 2 or 3 rows. -/
def Rows3Route (r N K : Nat) : Prop := (r = 2 ∨ r = 3) ∧ (N, K) ∈ [(10240, 5120), (6144, 5120), (5120, 6144)]

/-- V23 forwards' 4-bit affine rows launches (the delta projections of the 4-bit layers, in_proj_a/b, the attention
projections): 2 or 3 rows. -/
def Rows4Route (r N K : Nat) : Prop :=
  (r = 2 ∨ r = 3) ∧ (N, K) ∈ [(10240, 5120), (6144, 5120), (48, 5120), (5120, 6144), (12288, 5120), (1024, 5120)]

/-- The `AffineMma` projections (N, K, bits) of the 4-to-223-row and chunk forwards. -/
def SplitRoute (N K bits : Nat) : Prop :=
  (N, K, bits) ∈ [(10240, 5120, 3), (10240, 5120, 4), (6144, 5120, 3), (6144, 5120, 4), (48, 5120, 4),
    (5120, 6144, 3), (5120, 6144, 4), (12288, 5120, 4), (1024, 5120, 4)]

/-- The layers' gate and up widths (host/load/Data.lean). -/
def GateUpRoute (kg ku : Nat) : Prop := (kg, ku) ∈ [(2, 2), (3, 3), (3, 2), (2, 3), (4, 3), (4, 4), (3, 4)]

/-- The row-major down passes (code width, S, MT): the one-block pass and the plan's (down-mma-wide.ts:40-53). -/
def DownRoute (k s mt : Nat) : Prop :=
  (k, s, mt) ∈ [(2, 16, 1), (4, 16, 1), (2, 8, 2), (4, 8, 2), (2, 8, 3), (4, 8, 3)]

/-- The ANE MLP split's row-major fills: 6144 or 6656 rows (fractions .353, .382), widths 2, 3, 4. -/
def FillRoute (rows bits : Nat) : Prop := (rows = 6144 ∨ rows = 6656) ∧ (bits = 2 ∨ bits = 3 ∨ bits = 4)

/-- The half writer's element counts: the hidden rows `5120·r`, `6144·r` of the ANE forwards (224 ≤ r ≤ 2048) and
the affine split's weight heads (qkv 3840·5120, z and out/o 2304·5120 = 1920·6144, q 4608·5120). -/
def WriteRoute (N : Nat) : Prop :=
  (∃ r, 224 ≤ r ∧ r ≤ 2048 ∧ (N = 5120 * r ∨ N = 6144 * r)) ∨ N = 19660800 ∨ N = 11796480 ∨ N = 23592960

/-- The ANE MLP split's GPU share (`R` 11264 or 10752 rest rows): row-major gate, up and down at widths 2, 3, 4, and
the 3-bit interleaved down with row tile 128. -/
def ExpandRoute (R bits il rt : Nat) : Prop :=
  (R = 11264 ∨ R = 10752) ∧ ((il = 0 ∧ rt = 0 ∧ (bits = 2 ∨ bits = 3 ∨ bits = 4)) ∨ (bits = 3 ∧ il = 2 ∧ rt = 128))

/-! ## The contract -/

open FfiAneEval (InPlace WritesThrough InPlaceKernel)

/-- An in-place launch writes input `i` through with `stored` (`WritesThrough`) and its one output `done` is the int32
1 (fill.ts: `done[0] = 1`). -/
def WritesDone (IP : InPlace) (k : InPlaceKernel) (xs : List Value) (cfg : Config) (i : Nat)
    (stored : Nat → Option (BitVec 8)) : Prop :=
  WritesThrough IP k xs cfg i stored ∧
    ∀ res, IP.launchAll k xs cfg = some res → res[xs.length]? = some AneFill.doneOut

structure RouteKernelContract (C : M1Max.Contract) extends KernelContract C where
  /-- mlx_fast_metal_kernel_apply of a prefill kernel on the default GPU stream: its outputs. -/
  applyP : PrefillKernel → List Value → Config → Option (List Value)
  /-- The same launch of an in-place kernel: every buffer's final contents, inputs then outputs. -/
  inPlace : InPlace
  /-- The compiler's contraction choice at each site of gated_delta_step's text. -/
  deltaFusion : Nat → Bool
  deltaFlags_eq : flags = ⟨deltaFusion 1, deltaFusion 3, deltaFusion 4⟩
  affine3Rows : ∀ {r N K : Nat} (x w s b : Value), Rows3Route r N K →
    Typed x .bfloat16 [r, K] → Typed w .uint32 [N, K * 3 / 32] → Typed s .bfloat16 [N, K / 64] →
    Typed b .bfloat16 [N, K / 64] →
    applyP .affine3Rows [x, w, s, b] (rowsConfig r N K) =
      some [KernelGpu.readOutput (AffineRows3.expected C r N K x.storageByte w.storageByte s.storageByte b.storageByte)
        ([r, N], .bfloat16)]
  affine4Rows : ∀ {r N K : Nat} (x w s b : Value), Rows4Route r N K →
    Typed x .bfloat16 [r, K] → Typed w .uint32 [N, K / 8] → Typed s .bfloat16 [N, K / 64] →
    Typed b .bfloat16 [N, K / 64] →
    applyP .affine4Rows [x, w, s, b] (rowsConfig r N K) =
      some [KernelGpu.readOutput (AffineRows4.expected C r N K x.storageByte w.storageByte s.storageByte b.storageByte)
        ([r, N], .bfloat16)]
  affineSplitMma : ∀ {r N K bits : Nat} (x w s b : Value), SplitRoute N K bits → 4 ≤ r → r ≤ 223 →
    Typed x .bfloat16 [r, K] → Typed w .uint32 [N, K * bits / 32] → Typed s .bfloat16 [N, K / 64] →
    Typed b .bfloat16 [N, K / 64] →
    applyP .affineSplitMma [x, w, s, b] (splitConfig r N K bits) =
      some [KernelGpu.readOutput (AffineSplitMma.expected C N K bits (splitPlan N).1 (splitPlan N).2 r x.storageByte
        w.storageByte s.storageByte b.storageByte) ([r, N], .bfloat16)]
  gateUpCodebookMma : ∀ {r kg ku : Nat} (x gc gs uc us : Value), GateUpRoute kg ku → 2 ≤ r → r ≤ 8 →
    Typed x .bfloat16 [r, 5120] → Typed gc .uint32 [17408, 160 * kg] → Typed gs .float16 [17408] →
    Typed uc .uint32 [17408, 160 * ku] → Typed us .float16 [17408] →
    applyP .gateUpCodebookMma [x, gc, gs, uc, us] (codebookConfig r kg ku) =
      some [KernelGpu.readOutput (CodebookMma.expected C kg ku x.storageByte gc.storageByte gs.storageByte
        uc.storageByte us.storageByte r) ([r, 17408], .bfloat16)]
  gateUpMmaWide : ∀ {r kg ku : Nat} (x gc gs uc us : Value), GateUpRoute kg ku → 9 ≤ r → r ≤ 223 →
    Typed x .bfloat16 [r, 5120] → Typed gc .uint32 [17408, 160 * kg] → Typed gs .float16 [17408] →
    Typed uc .uint32 [17408, 160 * ku] → Typed us .float16 [17408] →
    applyP .gateUpMmaWide [x, gc, gs, uc, us] (wideConfig r kg ku) =
      some [KernelGpu.readOutput (GateUpMmaWide.expected C kg ku r x.storageByte gc.storageByte gs.storageByte
        uc.storageByte us.storageByte) ([r, 17408], .bfloat16)]
  downMmaWide : ∀ {M k s mt : Nat} (x cd sc : Value), DownRoute k s mt → 2 ≤ M → M ≤ 223 →
    Typed x .bfloat16 [M, 17408] → Typed cd .uint32 [17408, 160 * k] → Typed sc .float16 [17408] →
    applyP .downMmaWide [x, cd, sc] (downConfig' M k s mt 0) =
      some [KernelGpu.readOutput (DownMmaWide.expected C k false s mt M x.storageByte cd.storageByte sc.storageByte)
        ([M, 8, 5120], .float32)]
  downK3iMmaWide : ∀ {M : Nat} (x cd sc : Value), 2 ≤ M → M ≤ 223 →
    Typed x .bfloat16 [M, 17408] → Typed cd .uint32 [10, 17408, 48] → Typed sc .float16 [17408] →
    applyP .downK3iMmaWide [x, cd, sc] (downConfig' M 3 16 1 1) =
      some [KernelGpu.readOutput (DownMmaWide.expected C 3 true 16 1 M x.storageByte cd.storageByte sc.storageByte)
        ([M, 8, 5120], .float32)]
  aneTrellisFill : ∀ {rows bits : Nat} (cd sc dst : Value), FillRoute rows bits →
    Typed cd .uint32 [17408, 160 * bits] → Typed sc .float16 [17408] → dst.dtype = .float16 →
    rows * 5120 ≤ dst.size →
    WritesDone inPlace .trellisFill [cd, sc, dst] (fillConfig rows bits) 2
      (AneFill.fillStored C bits rows (AneFill.rowMajor bits) cd.storageByte sc.storageByte)
  aneTrellisFillK3i : ∀ {rows : Nat} (cd sc dst : Value), (rows = 6144 ∨ rows = 6656) →
    Typed cd .uint32 [10, 17408, 48] → Typed sc .float16 [17408] → dst.dtype = .float16 →
    rows * 5120 ≤ dst.size →
    WritesDone inPlace .trellisFillK3i [cd, sc, dst] (fillConfig rows 3) 2
      (AneFill.fillStored C 3 rows AneFill.k3i cd.storageByte sc.storageByte)
  aneWriteHalf : ∀ {N : Nat} (src dst : Value), WriteRoute N →
    src.dtype = .bfloat16 → src.size = N → dst.dtype = .float16 → N ≤ dst.size →
    WritesDone inPlace .writeHalf [src, dst] (writeConfig N) 1 (AneWrite.writeStored C N src.storageByte)
  vectorExpand : ∀ {R bits il rt : Nat} (cd sc : Value), ExpandRoute R bits il rt →
    Typed cd .uint32 (expandCodes R bits il) → Typed sc .float16 [R] →
    applyP .vectorExpand [cd, sc] (expandConfig R bits il rt) =
      some [KernelGpu.readOutput (VectorExpand.expected C R bits (il != 0) cd.storageByte sc.storageByte)
        ([R, 5120], .bfloat16)]
  gatedDeltaSteps : ∀ {T : Nat} (q k v g beta s : Value), 2 ≤ T → T ≤ 2048 →
    Typed q .bfloat16 [1, T, 16, 128] → Typed k .bfloat16 [1, T, 16, 128] → Typed v .bfloat16 [1, T, 48, 128] →
    Typed g .float32 [1, T, 48] → Typed beta .bfloat16 [1, T, 48] → Typed s .float32 [1, 48, 128, 128] →
    apply .gatedDeltaStep [q, k, v, g, beta, s, tinValue T] (gatedConfigT T) =
      some [KernelGpu.readOutput (GatedDeltaStep.bytes2 (12288 * T)
          (GatedDeltaSteps.ySteps C deltaFusion (deltaIns q k v g beta s T))) ([1, T, 48, 128], .bfloat16),
        KernelGpu.readOutput (GatedDeltaStep.bytes4 3145728 (GatedDeltaStep.stateOut C deltaFusion
          (GatedDeltaSteps.stepAt C deltaFusion (deltaIns q k v g beta s T) (T - 1)))) ([1, 48, 128, 128], .float32)]

namespace RouteKernelContract
variable {C : M1Max.Contract} (K : RouteKernelContract C)

/-- The launch of any route kernel. -/
def applyR : RouteKernel → List Value → Config → Option (List Value)
  | .decode k => K.apply k
  | .prefill k => K.applyP k

/-- **The T-step gated delta at model level** (the bridge, `Bridge.GatedDeltaSteps.outputs_eq_steps`): when the
inputs' bytes decode to the T-step model's per-step inputs and every row's output expression is finite at every
step, the launch's outputs encode `Recurrence.outputAt` at every step and `Recurrence.run` after `T` steps, at the
contract's contraction flags. -/
theorem gatedDeltaSteps_model {T : Nat} (q k v g beta s : Value) (h2 : 2 ≤ T) (h3 : T ≤ 2048)
    (hq : Typed q .bfloat16 [1, T, 16, 128]) (hk : Typed k .bfloat16 [1, T, 16, 128])
    (hv : Typed v .bfloat16 [1, T, 48, 128]) (hg : Typed g .float32 [1, T, 48]) (hb : Typed beta .bfloat16 [1, T, 48])
    (hs : Typed s .float32 [1, 48, 128, 128]) {initial : Delta.GatedDevice.State}
    {values : Nat → Delta.GatedInputs.Values}
    (hd : Metal.Bridge.GatedDeltaSteps.DecodesSteps T (deltaIns q k v g beta s T) initial values)
    (hf : ∀ τ < T, ∀ h r, Arithmetic.Finite
      (Metal.Bridge.GatedDeltaStep.row (Metal.Bridge.GatedDeltaSteps.stateRun C K.flags initial values τ) (values τ) h r)
      (Delta.Gated.outputExpr K.flags (Metal.Bridge.GatedDeltaStep.tree C))) :
    K.apply .gatedDeltaStep [q, k, v, g, beta, s, tinValue T] (gatedConfigT T) =
      some [KernelGpu.readOutput (GatedDeltaStep.bytes2 (12288 * T)
          (Metal.Bridge.GatedDeltaSteps.yModelSteps C K.flags initial values)) ([1, T, 48, 128], .bfloat16),
        KernelGpu.readOutput (GatedDeltaStep.bytes4 3145728
          (Metal.Bridge.GatedDeltaSteps.stateModelSteps C T K.flags initial values)) ([1, 48, 128, 128], .float32)] := by
  have hfuse : Metal.Bridge.GatedDeltaStep.Fuses K.deltaFusion K.flags :=
    ⟨by rw [K.deltaFlags_eq], by rw [K.deltaFlags_eq], by rw [K.deltaFlags_eq]⟩
  obtain ⟨h1, h4⟩ := Metal.Bridge.GatedDeltaSteps.outputs_eq_steps (by omega) hd hfuse hf
  rw [K.gatedDeltaSteps q k v g beta s h2 h3 hq hk hv hg hb hs, h1, h4]

end RouteKernelContract

end Host.Mlx

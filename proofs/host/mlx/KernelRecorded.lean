import host.mlx.KernelGpu
import host.load.Layers
import host.mlx.KernelPorts
import host.mlx.KernelGpuPrefill
namespace Host.Mlx.KernelRecorded
open Host.Load.Layers

/-! # The custom-kernel texts over the kernel-recording layer

`KernelGpu.ofGpu`'s `apply` assembles each route kernel's text from its
constructor's names and flags and from the configuration's template arguments
dtypes first (`Metal.Assemble.Tests.configArgs`). Over the kernel-recording layer
(`Layers.kern`) this is MLX's assembly of what the TypeScript passed
(`launchText_recorded`): the name, source and header the model keeps, the input
and output name counts it keeps (the names' bytes lie in JavaScript buffers the
model does not see; they are bound to the TypeScript by KernelSourceBinding.ts
in `KernelPorts`), the `atomic_outputs` flag the layer recorded, and the
template arguments in the order the layer recorded, for every launch the layer
accepts (`Layers.kernCall_launch`). -/

theorem inputNames_ports (k : Kernel) : KernelGpu.inputNames k = KernelPorts.inputNames k := by cases k <;> rfl
theorem outputNames_ports (k : Kernel) : KernelGpu.outputNames k = KernelPorts.outputNames k := by cases k <;> rfl
theorem atomicOutputs_false (k : Kernel) : KernelPorts.atomicOutputs k = false := by cases k <;> rfl

/-- The input and output name counts and the flags of route kernel `k`'s constructor. -/
def kernelPorts (k : Kernel) : (Nat × Nat) × (Bool × Bool) :=
  (((KernelPorts.inputNames k).length, (KernelPorts.outputNames k).length),
    (KernelPorts.rowContiguous k, KernelPorts.atomicOutputs k))

/-- The route name of kernel object `h` over the layer: the model's identification
(`FfiEval.kernelName?`), and the name counts the model kept and the flags the layer
recorded are the constructor's. -/
def kernelName? (S : FfiEval.KernelSources) (m : Ffi.St) (krec : KRec) (h : Nat) : Option (List Char) :=
  match m.obj? h, krec.flags.get h with
  | some (.kernel name src hdr nIn nOut), some fl => (FfiEval.kernelOf name).bind fun k =>
    if src = S.source k ∧ hdr = S.header k ∧ ((nIn, nOut), fl) = kernelPorts k then some name else none
  | _, _ => none

/-- The layer's identification refines the model's. -/
theorem kernelName?_base {S : FfiEval.KernelSources} {m : Ffi.St} {krec : KRec} {h : Nat} {name : List Char}
    (hk : kernelName? S m krec h = some name) : FfiEval.kernelName? S m h = some name := by
  unfold kernelName? at hk
  unfold FfiEval.kernelName?
  split at hk
  · rename_i nm src hdr nIn nOut fl ho _
    rw [ho]
    simp only at hk ⊢
    cases hkk : FfiEval.kernelOf nm with
    | none => rw [hkk] at hk; cases hk
    | some k =>
      rw [hkk] at hk
      simp only [Option.bind_some] at hk ⊢
      split at hk
      · rename_i hc; simp only [hc.1, hc.2.1, and_self, ↓reduceIte]; exact hk
      · cases hk
  · cases hk

/-- A recorded template argument as MLX's `TemplateArg`, its number read through the run's valuation. -/
def recordedArg (ν : Host.Ts.NumV → Option Host.Ts.F64) : List Char × TArg → Option Metal.Assemble.TemplateArg
  | (n, .int v) => ((ν v).bind Host.Ts.F64.toInt?).bind fun i => if 0 ≤ i then some (.int n i) else none
  | (n, .dtype d) => (Dtype.ofCode d).map (.dtype n)

def isIntArg (t : List Char × TArg) : Bool := match t.2 with | .int _ => true | .dtype _ => false

theorem ints_split : ∀ (l : List (List Char × TArg)), l.all isIntArg = true →
    dtypesOf l = [] ∧ l = (intsOf l).map fun p => (p.1, TArg.int p.2)
  | [], _ => ⟨rfl, rfl⟩
  | (n, .int v) :: r, h => by
    simp only [List.all_cons, Bool.and_eq_true, isIntArg] at h
    obtain ⟨h1, h2⟩ := ints_split r h.2
    exact ⟨by simp [dtypesOf, h1], by simp only [intsOf, List.map_cons]; rw [← h2]⟩
  | (n, .dtype d) :: r, h => by simp [isIntArg] at h

/-- An ordered list is its dtype arguments followed by its int arguments. -/
theorem ordered_split : ∀ (l : List (List Char × TArg)), ordered l = true →
    l = (dtypesOf l).map (fun p => (p.1, TArg.dtype p.2)) ++ (intsOf l).map fun p => (p.1, TArg.int p.2)
  | [], _ => rfl
  | (n, .dtype d) :: r, h => by
    simp only [ordered] at h
    simp only [dtypesOf, intsOf, List.map_cons, List.cons_append]
    rw [← ordered_split r h]
  | (n, .int v) :: r, h => by
    have hall : ((n, TArg.int v) :: r).all isIntArg = true := by
      simp only [ordered] at h
      exact h
    obtain ⟨h1, h2⟩ := ints_split _ hall
    rw [h1, List.map_nil, List.nil_append]
    exact h2

theorem recorded_dtypes (ν : Host.Ts.NumV → Option Host.Ts.F64) :
    ∀ (ds : List (List Char × Nat)) (dts : List (String × Dtype)), ds.mapM FfiEval.dtOf = some dts →
      (ds.map fun p => (p.1, TArg.dtype p.2)).mapM (recordedArg ν) =
        some (dts.map fun (n, d) => Metal.Assemble.TemplateArg.dtype n.toList d)
  | [], dts, h => by simp only [List.mapM_nil, Option.pure_def, Option.some.injEq] at h; subst h; rfl
  | (n, d) :: r, dts, h => by
    simp only [List.mapM_cons, Option.pure_def, Option.bind_eq_bind, Option.bind_eq_some_iff,
      Option.some.injEq, FfiEval.dtOf, Option.map_eq_some_iff] at h
    obtain ⟨p, ⟨dt, hdt, rfl⟩, dts', h', rfl⟩ := h
    simp only [List.map_cons, List.mapM_cons, Option.pure_def, Option.bind_eq_bind, recordedArg, hdt,
      Option.map_some, Option.bind_some, recorded_dtypes ν r dts' h']
    simp [String.toList_ofList]

theorem recorded_ints (ν : Host.Ts.NumV → Option Host.Ts.F64) :
    ∀ (is : List (List Char × Host.Ts.NumV)) (ris : List (List Char × Int)) (ints : List (String × Nat)),
      is.mapM (fun (n, v) => ((FfiEval.concrete ν).dim v).map (n, ·)) = some ris → ris.mapM FfiEval.intOf = some ints →
      (is.map fun p => (p.1, TArg.int p.2)).mapM (recordedArg ν) =
        some (ints.map fun (n, v) => Metal.Assemble.TemplateArg.int n.toList v)
  | [], ris, ints, h1, h2 => by
    simp only [List.mapM_nil, Option.pure_def, Option.some.injEq] at h1; subst h1
    simp only [List.mapM_nil, Option.pure_def, Option.some.injEq] at h2; subst h2; rfl
  | (n, v) :: r, ris, ints, h1, h2 => by
    simp only [List.mapM_cons, Option.pure_def, Option.bind_eq_bind, Option.bind_eq_some_iff,
      Option.some.injEq, Option.map_eq_some_iff] at h1
    obtain ⟨p, ⟨i, hi, rfl⟩, ris', h1', rfl⟩ := h1
    simp only [List.mapM_cons, Option.pure_def, Option.bind_eq_bind, Option.bind_eq_some_iff,
      Option.some.injEq, FfiEval.intOf, Option.map_eq_some_iff, FfiEval.nat?] at h2
    obtain ⟨q, ⟨j, hj, rfl⟩, ints', h2', rfl⟩ := h2
    split at hj
    · rename_i h0
      simp only [Option.some.injEq] at hj; subst hj
      have hr := recorded_ints ν r ris' ints' h1' h2'
      simp only [FfiEval.concrete] at hi
      simp only [List.map_cons, List.mapM_cons, Option.pure_def, Option.bind_eq_bind, recordedArg]
      rw [hi, Option.bind_some]
      simp only [h0, ↓reduceIte, Option.bind_some, hr]
      simp [String.toList_ofList, Int.toNat_of_nonneg h0]
    · cases hj

/-- The resolved configuration of a model configuration whose recorded template arguments are ordered
and agree with it assembles them in their recorded order. -/
theorem configArgs_recorded {ν : Host.Ts.NumV → Option Host.Ts.F64} {c : Ffi.Cfg} {rc : FfiEval.RCfg Int}
    {cfg : Config} {l : List (List Char × TArg)}
    (hrc : FfiEval.resolveCfg (FfiEval.concrete ν) c = some rc) (hcfg : FfiEval.toConfig rc = some cfg)
    (hord : ordered l = true) (hd : c.dtypes = dtypesOf l) (hi : c.ints = intsOf l) :
    l.mapM (recordedArg ν) = some (Metal.Assemble.Tests.configArgs cfg) := by
  obtain ⟨outs, grid, group, ints, dtypes, init⟩ := c
  have hints : ∃ ris, ints.mapM (fun (n, v) => ((FfiEval.concrete ν).dim v).map (n, ·)) = some ris ∧
      rc.ints = ris ∧ rc.dtypes = dtypes := by
    cases init with
    | none =>
      simp only [FfiEval.resolveCfg, Option.bind_eq_bind, Option.bind_eq_some_iff, Option.pure_def,
        Option.some.injEq] at hrc
      obtain ⟨_, _, _, _, _, _, ris, hris, _, _, rfl⟩ := hrc
      exact ⟨ris, hris, rfl, rfl⟩
    | some v =>
      simp only [FfiEval.resolveCfg, Option.bind_eq_bind, Option.bind_eq_some_iff, Option.pure_def,
        Option.some.injEq, Option.map_eq_some_iff] at hrc
      obtain ⟨_, _, _, _, _, _, ris, hris, _, _, rfl⟩ := hrc
      exact ⟨ris, hris, rfl, rfl⟩
  obtain ⟨ris, hris, hri, hrd⟩ := hints
  have htc : rc.dtypes.mapM FfiEval.dtOf = some cfg.templateDtypes ∧ rc.ints.mapM FfiEval.intOf = some cfg.templateInts := by
    simp only [FfiEval.toConfig, Option.bind_eq_bind, Option.pure_def, Option.bind_eq_some_iff,
      Option.some.injEq] at hcfg
    obtain ⟨_, _, _, _, _, _, dts, hd', ints', hi', _, _, rfl⟩ := hcfg
    exact ⟨hd', hi'⟩
  obtain ⟨hdt, hit⟩ := htc
  rw [hrd] at hdt; rw [hri] at hit
  simp only at hd hi
  rw [ordered_split l hord, List.mapM_append, ← hd, ← hi, recorded_dtypes ν dtypes _ hdt,
    recorded_ints ν ints ris _ hris hit]
  rfl

/-- The route's kernel names are the constructors' (`FfiEval.kernelOf` inverts `KernelGpu.kernelName`). -/
theorem kernelName_of {name : List Char} {k : Kernel} (h : FfiEval.kernelOf name = some k) :
    KernelGpu.kernelName k = name := by
  unfold FfiEval.kernelOf at h
  obtain ⟨p, hp, rfl⟩ := Option.map_eq_some_iff.mp h
  have he := List.find?_some hp
  simp only [decide_eq_true_eq] at he
  have hall : ∀ q ∈ FfiEval.kernelNames, KernelGpu.kernelName q.2 = q.1 := by decide +kernel
  rw [hall p (List.mem_of_find?_eq_some hp), he]

/-- **A launch's text over the kernel-recording layer is MLX's assembly of what the TypeScript
passed.** For an `mlx_fast_metal_kernel_apply` of kernel object `kh` with configuration `ch` that
the layer accepts (`kernCall` on the model's state `m` before the call), where the layer identifies
`kh` (`kernelName?`) as route kernel `k`: the layer recorded the kernel's flags and the
configuration's template arguments `l`, and `KernelGpu.launchText` is `Metal.Assemble.assemble` on
the name, source and header the model keeps, the constructor's input and output names (as many as
the model kept), the inputs' and outputs' dtypes, `l` in its recorded order and the recorded
`atomic_outputs` flag; the kernel was built with `ensure_row_contiguous` as recorded. -/
theorem launchText_recorded {ν : Host.Ts.NumV → Option Host.Ts.F64} {m : Ffi.St} {krec krec' : KRec}
    {call : Host.Ts.Name} {o kha v cha st : Host.Ts.Arg} {r : Host.Ts.Ret} {kh ch : Nat}
    {name src hdr : List Char} {nIn nOut : Nat} {k : Kernel} {c : Ffi.Cfg} {rc : FfiEval.RCfg Int} {cfg : Config}
    (hs : Ffi.symOf call = some .kernelApply) (hkh : Ffi.argNat kha = some kh) (hch : Ffi.argNat cha = some ch)
    (hacc : kernCall krec m call [o, kha, v, cha, st] r = some krec')
    (ho : m.obj? kh = some (.kernel name src hdr nIn nOut)) (hc : m.obj? ch = some (.cfg c))
    (hk : kernelName? SourceKernels.sources m krec kh = some name) (hkk : FfiEval.kernelOf name = some k)
    (hrc : FfiEval.resolveCfg (FfiEval.concrete ν) c = some rc) (hcfg : FfiEval.toConfig rc = some cfg)
    (xs : List Value) :
    ∃ flags l targs, krec.flags.get kh = some flags ∧ krec.targs.get ch = some l ∧
      l.mapM (recordedArg ν) = some targs ∧
      (KernelPorts.inputNames k).length = nIn ∧ (KernelPorts.outputNames k).length = nOut ∧
      KernelPorts.rowContiguous k = flags.1 ∧
      KernelGpu.launchText k xs cfg = Metal.Assemble.assemble name (List.zipWith (fun n v => ⟨n, v.dtype, v.shape⟩)
        (KernelPorts.inputNames k) xs) (KernelPorts.outputNames k) (cfg.outputs.map (·.2)) src hdr targs flags.2 := by
  obtain ⟨flags, l, c', hfl, hl, hc', hord, hd, hi, _⟩ := kernCall_launch hs hkh hch hacc
  rw [hc] at hc'
  cases hc'
  unfold kernelName? at hk
  rw [ho, hfl] at hk
  simp only [hkk, Option.bind_some] at hk
  split at hk
  · rename_i hsh
    obtain ⟨hsrc, hhdr, hp⟩ := hsh
    simp only [kernelPorts, Prod.mk.injEq] at hp
    obtain ⟨⟨h1, h2⟩, hf⟩ := hp
    subst hf
    refine ⟨_, l, _, hfl, hl, configArgs_recorded hrc hcfg hord hd hi, h1.symm, h2.symm, rfl, ?_⟩
    show Metal.Assemble.assemble (KernelGpu.kernelName k) _ (KernelGpu.outputNames k) _ (SourceKernels.sources.source k)
      (SourceKernels.sources.header k) (Metal.Assemble.Tests.configArgs cfg) false = _
    rw [kernelName_of hkk, inputNames_ports, outputNames_ports, hsrc, hhdr, atomicOutputs_false]
  · cases hk

/-! ## The route's kernel table over the layer

The same check for every kernel of the route's table (`RouteKernel`: the decode kernels and the prefill kernels,
`Host.Mlx.routeKernelOf`): the layer's identification of a kernel object refines the table's resolution
(`routeKernelName?_base`), extends the decode identification (`kernelName?_route`), and a launch of a table
kernel has MLX's assembly of what the TypeScript passed as its text (`launchTextR_recorded`). -/

/-- The input and output name counts and the flags of a table kernel's constructor. -/
def routePorts (k : RouteKernel) : (Nat × Nat) × (Bool × Bool) :=
  ((k.inputNames.length, k.outputNames.length), (k.rowContiguous, k.atomicOutputs))

/-- The table name of kernel object `h` over the layer: the table's resolution, with the name counts the model kept
and the flags the layer recorded the constructor's. -/
def routeKernelName? (m : Ffi.St) (krec : KRec) (h : Nat) : Option (List Char) :=
  match m.obj? h, krec.flags.get h with
  | some (.kernel name src hdr nIn nOut), some fl => (routeKernelOf name).bind fun k =>
    if src = k.source ∧ hdr = k.header ∧ ((nIn, nOut), fl) = routePorts k then some name else none
  | _, _ => none

/-- The layer's identification refines the table's. -/
theorem routeKernelName?_base {m : Ffi.St} {krec : KRec} {h : Nat} {name : List Char}
    (hk : routeKernelName? m krec h = some name) :
    Host.Mlx.routeKernelName? SourceKernels.sources m h = some name := by
  unfold routeKernelName? at hk
  unfold Host.Mlx.routeKernelName?
  split at hk
  · rename_i nm src hdr nIn nOut fl ho _
    rw [ho]
    simp only at hk ⊢
    cases hkk : routeKernelOf nm with
    | none => rw [hkk] at hk; cases hk
    | some k =>
      rw [hkk] at hk
      simp only [Option.bind_some] at hk ⊢
      split at hk
      · rename_i hc; simp only [RouteKernel.sourceWith_sources, RouteKernel.headerWith_sources, hc.1, hc.2.1, and_self,
          ↓reduceIte]; exact hk
      · cases hk
  · cases hk

/-- The layer's identification over the table extends its decode identification. -/
theorem kernelName?_route {m : Ffi.St} {krec : KRec} {h : Nat} {name : List Char}
    (hk : kernelName? SourceKernels.sources m krec h = some name) : routeKernelName? m krec h = some name := by
  unfold kernelName? at hk
  unfold routeKernelName?
  split at hk
  · rename_i nm src hdr nIn nOut fl ho hf
    cases hkk : FfiEval.kernelOf nm with
    | none => rw [hkk] at hk; cases hk
    | some k =>
      rw [hkk] at hk
      simp only [Option.bind_some] at hk
      rw [routeKernelOf_decode hkk, Option.bind_some]
      exact hk
  · cases hk

/-- The constructor name of a table kernel. -/
def _root_.Host.Mlx.RouteKernel.kernelName : RouteKernel → List Char
  | .decode k => KernelGpu.kernelName k
  | .prefill k => PrefillSources.name k

theorem routeKernelName_of {name : List Char} {k : RouteKernel} (h : routeKernelOf name = some k) :
    k.kernelName = name := by
  rcases routeKernelOf_some h with ⟨d, rfl, hd⟩ | ⟨p, rfl, hp⟩
  · exact kernelName_of hd
  · exact hp

/-- A table kernel's text: MLX's assembly from the constructor's name, input and output names, body, header and
`atomic_outputs` flag. -/
theorem launchTextR_eq (k : RouteKernel) (xs : List Value) (cfg : Config) :
    KernelGpu.launchTextR k xs cfg = Metal.Assemble.assemble k.kernelName
      (List.zipWith (fun n v => ⟨n, v.dtype, v.shape⟩) k.inputNames xs) k.outputNames (cfg.outputs.map (·.2))
      k.source k.header (Metal.Assemble.Tests.configArgs cfg) k.atomicOutputs := by
  cases k with
  | decode d =>
    show _ = Metal.Assemble.assemble (KernelGpu.kernelName d) (List.zipWith _ (KernelPorts.inputNames d) xs)
      (KernelPorts.outputNames d) _ (SourceKernels.sources.source d) (SourceKernels.sources.header d) _
      (KernelPorts.atomicOutputs d)
    rw [atomicOutputs_false, ← inputNames_ports, ← outputNames_ports]
    rfl
  | prefill p => rfl

/-- **A launch's text over the kernel-recording layer is MLX's assembly of what the TypeScript passed**, for every
kernel of the route's table: as `launchText_recorded`, with the table's identification (`routeKernelName?`) and
text (`KernelGpu.launchTextR`). -/
theorem launchTextR_recorded {ν : Host.Ts.NumV → Option Host.Ts.F64} {m : Ffi.St} {krec krec' : KRec}
    {call : Host.Ts.Name} {o kha v cha st : Host.Ts.Arg} {r : Host.Ts.Ret} {kh ch : Nat}
    {name src hdr : List Char} {nIn nOut : Nat} {k : RouteKernel} {c : Ffi.Cfg} {rc : FfiEval.RCfg Int} {cfg : Config}
    (hs : Ffi.symOf call = some .kernelApply) (hkh : Ffi.argNat kha = some kh) (hch : Ffi.argNat cha = some ch)
    (hacc : kernCall krec m call [o, kha, v, cha, st] r = some krec')
    (ho : m.obj? kh = some (.kernel name src hdr nIn nOut)) (hc : m.obj? ch = some (.cfg c))
    (hk : routeKernelName? m krec kh = some name) (hkk : routeKernelOf name = some k)
    (hrc : FfiEval.resolveCfg (FfiEval.concrete ν) c = some rc) (hcfg : FfiEval.toConfig rc = some cfg)
    (xs : List Value) :
    ∃ flags l targs, krec.flags.get kh = some flags ∧ krec.targs.get ch = some l ∧
      l.mapM (recordedArg ν) = some targs ∧
      k.inputNames.length = nIn ∧ k.outputNames.length = nOut ∧ k.rowContiguous = flags.1 ∧
      KernelGpu.launchTextR k xs cfg = Metal.Assemble.assemble name (List.zipWith (fun n v => ⟨n, v.dtype, v.shape⟩)
        k.inputNames xs) k.outputNames (cfg.outputs.map (·.2)) src hdr targs flags.2 := by
  obtain ⟨flags, l, c', hfl, hl, hc', hord, hd, hi, _⟩ := kernCall_launch hs hkh hch hacc
  rw [hc] at hc'
  cases hc'
  unfold routeKernelName? at hk
  rw [ho, hfl] at hk
  simp only [hkk, Option.bind_some] at hk
  split at hk
  · rename_i hsh
    obtain ⟨hsrc, hhdr, hp⟩ := hsh
    simp only [routePorts, Prod.mk.injEq] at hp
    obtain ⟨⟨h1, h2⟩, hf⟩ := hp
    subst hf
    refine ⟨_, l, _, hfl, hl, configArgs_recorded hrc hcfg hord hd hi, h1.symm, h2.symm, rfl, ?_⟩
    rw [launchTextR_eq, routeKernelName_of hkk, hsrc, hhdr]
  · cases hk

end Host.Mlx.KernelRecorded

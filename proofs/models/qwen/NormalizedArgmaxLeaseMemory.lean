import contracts.mlx.BufferLeaseMemory
import models.qwen.TokenParameterMemory

-- A release-only lifecycle suffix for the actual sampler scratch spans.
-- Native array/MTL lengths, all outstanding leases, last-read notifications,
-- and command completion callbacks must refine the explicit inputs below.
namespace Inference.Models.Qwen.NormalizedArgmaxLeaseMemory
open Contracts.Mlx Kernels.Sampling BufferLeaseMemory
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

-- Manual translation of normalized-argmax.ts kernelGraph: rows=size/vocab,
-- tiles=ceil(vocab/1024). The selected B1 BF16 domain has size=vocab=248320.
def rows (size vocab : Nat) : Nat := size/vocab
def tiles (vocab : Nat) : Nat := (vocab+1023)/1024

theorem selected_counts : rows 248320 248320=1 ∧ tiles 248320=243 ∧
    rows 248320 248320*tiles 248320*4=972 ∧ (1:Nat)*2=2 := by norm_num [rows,tiles]

inductive Kind where
  | values | indices | scalar
  deriving DecidableEq

def logicalBytes : Kind → Nat | .values => 972 | .indices => 972 | .scalar => 2

def requestedBytes (size vocab : Nat) : Kind → Nat
  | .values => rows size vocab*tiles vocab*4
  | .indices => rows size vocab*tiles vocab*4
  | .scalar => rows size vocab*2

theorem selected_requested (kind : Kind) : requestedBytes 248320 248320 kind=logicalBytes kind := by
  cases kind <;> norm_num [requestedBytes,rows,tiles,logicalBytes]

variable {logits : Fin 248320 → ArrayStorage.BF} {platform : LogSumExpRanges.Platform}
  {source : ArrayStorage.BFBuffer logits} (pipeline : NormalizedArgmaxMemory.Pipeline platform source)

def logicalRegion : Kind → Region
  | .values => ⟨pipeline.selection.layout.scores,972⟩
  | .indices => ⟨pipeline.selection.layout.ids,972⟩
  | .scalar => ⟨pipeline.lse.destination,2⟩

def tokenRegion : Region := ⟨pipeline.selection.destination,4⟩
def logitsRegion (_pipeline : NormalizedArgmaxMemory.Pipeline platform source) : Region := ⟨source.base,496640⟩

def Retained (base size : Nat) : Prop := ∀ kind, MemoryRegions.Disjoint
  (logicalRegion pipeline kind).base (logicalRegion pipeline kind).size base size

theorem safe_retained (safe : pipeline.Safe base size) : Retained pipeline base size := by
  intro kind
  cases kind with
  | values => exact safe.2.1.1
  | indices => exact safe.2.1.2
  | scalar => exact safe.1

theorem token_retained : Retained pipeline (tokenRegion pipeline).base (tokenRegion pipeline).size := by
  intro kind
  cases kind with
  | values => exact MemoryRegions.disjoint_symm pipeline.selection.tokenScoreSafe
  | indices => exact MemoryRegions.disjoint_symm pipeline.selection.tokenIdSafe
  | scalar => exact MemoryRegions.disjoint_symm pipeline.selection.tokenLseSafe

theorem logits_retained : Retained pipeline (logitsRegion pipeline).base (logitsRegion pipeline).size := by
  intro kind
  cases kind with
  | values => exact pipeline.selection.logitsSafe.1
  | indices => exact pipeline.selection.logitsSafe.2
  | scalar => exact pipeline.lse.sourceSafe

-- Physical region size is the extracted native buffer length, not nbytes.
-- Logical disjointness cannot protect a possibly larger physical tail.
structure Classes where
  physical : Kind → Region
  base : ∀ kind, (physical kind).base=(logicalRegion pipeline kind).base
  fits : ∀ kind, logicalBytes kind≤(physical kind).size
  separate : [physical .values,physical .indices,physical .scalar].Pairwise Apart
  token : ∀ kind, Apart (physical kind) (tokenRegion pipeline)
  logits : ∀ kind, Apart (physical kind) (logitsRegion pipeline)

theorem Classes.host_fits (classes : Classes pipeline) (kind : Kind) :
    requestedBytes 248320 248320 kind≤(classes.physical kind).size := by
  rw [selected_requested]
  exact classes.fits kind

variable {pipeline}

def Classes.Safe (classes : Classes pipeline) (base size : Nat) : Prop :=
  ∀ kind, MemoryRegions.Disjoint (classes.physical kind).base (classes.physical kind).size base size

-- Canonical LOGICAL class, useful in the existing heap model. This does not
-- assert that native Metal allocation lengths equal their requested sizes.
def logicalClasses (pipeline : NormalizedArgmaxMemory.Pipeline platform source) : Classes pipeline where
  physical := logicalRegion pipeline
  base := by intro kind; rfl
  fits := by intro kind; cases kind <;> exact Nat.le_refl _
  separate := by
    refine List.Pairwise.cons ?_ (List.Pairwise.cons ?_ (List.Pairwise.cons ?_ .nil))
    · intro region member
      rcases List.mem_cons.mp member with equal | member
      · subst region; exact pipeline.selection.layout.separate
      · have equal := List.mem_singleton.mp member
        subst region; exact pipeline.selection.lseSafe.1
    · intro region member
      have equal := List.mem_singleton.mp member
      subst region; exact pipeline.selection.lseSafe.2
    · simp
  token := token_retained pipeline
  logits := logits_retained pipeline

theorem logical_safe (safe : pipeline.Safe base size) :
    (logicalClasses pipeline).Safe base size := safe_retained pipeline safe

-- The native multimap's list extraction may choose either equal-sized
-- partial first. Neither a deterministic address nor a single arena is used.
structure Pool (classes : Classes pipeline) where
  entries : List Region
  contents : entries.Perm [classes.physical .values,classes.physical .indices,classes.physical .scalar]
  ordered : entries.Pairwise (fun a b => a.size≤b.size)

def logicalPool (pipeline : NormalizedArgmaxMemory.Pipeline platform source) : Pool (logicalClasses pipeline) where
  entries := [logicalRegion pipeline .scalar,logicalRegion pipeline .values,logicalRegion pipeline .indices]
  contents := (List.Perm.swap _ _ _).trans ((List.Perm.swap _ _ _).cons _)
  ordered := by
    simp [List.pairwise_cons,logicalRegion]

variable (classes : Classes pipeline) (pool : Pool classes)

theorem Pool.member_kind (member : region∈pool.entries) : ∃ kind, region=classes.physical kind := by
  have inside := pool.contents.mem_iff.mp member
  simp only [List.mem_cons,List.not_mem_nil,or_false] at inside
  rcases inside with equal | equal | equal
  · exact ⟨.values,equal⟩
  · exact ⟨.indices,equal⟩
  · exact ⟨.scalar,equal⟩

theorem Pool.free : pool.entries.Pairwise Apart :=
  (List.Perm.pairwise_iff (R:=Apart) (fun h => apart_symm h) pool.contents).mpr classes.separate

theorem Pool.selected_safe (found : reuse requested page pool.entries=some (region,rest))
    (safe : classes.Safe base size) : MemoryRegions.Disjoint region.base region.size base size := by
  obtain ⟨kind,rfl⟩ := pool.member_kind classes (reuse_pick found).1.members.1
  exact safe kind

theorem Pool.selected_size (found : reuse requested page pool.entries=some (region,rest)) :
    requested≤region.size := reuse_size found

theorem Pool.selected_minimum (found : reuse requested page pool.entries=some (region,rest))
    (candidate : Region) (member : candidate∈pool.entries) (fits : requested≤candidate.size) :
    region.size≤candidate.size := (reuse_pick found).1.minimum pool.ordered candidate member fits

-- A caller supplies actual native callback/read events when claiming native
-- correspondence. Canonical witnesses below only establish model feasibility.
structure Lifecycle (initial : Kind → Lease) where
  events : Kind → List Event
  after : Kind → Lease
  execution : ∀ kind, Runs (initial kind) (events kind) (after kind)
  released : ∀ kind, (after kind).recyclable

noncomputable def Lifecycle.canonical (initial : Kind → Lease) : Lifecycle initial where
  events kind := Classical.choose (drain (initial kind))
  after _ := ⟨false,0,0⟩
  execution kind := Classical.choose_spec (drain (initial kind))
  released _ := by decide

structure Released (classes : Classes pipeline) (initial : Kind → Lease) where
  lifecycle : Lifecycle initial
  pool : Pool classes

noncomputable def releasedLogical (pipeline : NormalizedArgmaxMemory.Pipeline platform source)
    (initial : Kind → Lease) : Released (logicalClasses pipeline) initial :=
  ⟨Lifecycle.canonical initial,logicalPool pipeline⟩

variable {initial : Kind → Lease} (lifecycle : Lifecycle initial)

theorem Lifecycle.recycles (kind : Kind) : recycle (lifecycle.after kind) (classes.physical kind) []=
    some [classes.physical kind] := by
  simp [recycle,lifecycle.released kind]

-- Host disposal order is values, indices, then the enclosing using-lse.
-- Actual cache multimap iteration may reorder these entries by buffer length.
def recycleAll : Option (List Region) := do
  let first ← recycle (lifecycle.after .values) (classes.physical .values) []
  let second ← recycle (lifecycle.after .indices) (classes.physical .indices) first
  recycle (lifecycle.after .scalar) (classes.physical .scalar) second

theorem Lifecycle.recycles_all : recycleAll classes lifecycle=
    some [classes.physical .scalar,classes.physical .indices,classes.physical .values] := by
  simp [recycleAll,recycle,lifecycle.released .values,lifecycle.released .indices,lifecycle.released .scalar]

theorem Lifecycle.completion_required (kind : Kind) (pending : 0<(initial kind).commands) :
    Event.completed∈lifecycle.events kind :=
  (lifecycle.execution kind).completed_required pending (lifecycle.released kind).2.2

theorem Lifecycle.last_read_required (kind : Kind) (unread : 0<(initial kind).reads) :
    Event.lastRead∈lifecycle.events kind :=
  (lifecycle.execution kind).lastRead_required unread (lifecycle.released kind).2.1

-- These writes may be a later use of a recycled allocation. All frames are
-- against the SAME completed sampler heap; no encoded heap is substituted.
variable (stores : List ByteMemory.Store)
  (found : reuse requested page pool.entries=some (region,rest))
  (inside : MemoryRegions.Inside32 region.base region.size stores)

def after : ByteMemory.Bytes := ByteMemory.execute stores pipeline.memory

include classes pool found inside

theorem frame (safe : classes.Safe base size) (offset : Nat) (bound : offset<size) :
    after (pipeline:=pipeline) stores (base+offset)=pipeline.memory (base+offset) :=
  MemoryRegions.execute32_other stores pipeline.memory inside (pool.selected_safe classes found safe) offset bound

theorem token_frame (offset : Nat) (bound : offset<4) :
    after (pipeline:=pipeline) stores (pipeline.selection.destination+offset)=
      pipeline.memory (pipeline.selection.destination+offset) :=
  frame classes pool stores found inside classes.token offset bound

theorem token_read : (ByteMemory.load32 (after (pipeline:=pipeline) stores) pipeline.selection.destination).toNat=
    pipeline.selection.token := by
  exact congrArg BitVec.toNat (ArrayFrame.word_congr pipeline.memory
    (after (pipeline:=pipeline) stores) pipeline.selection.destination 4 0
    (token_frame classes pool stores found inside) (by decide))

theorem token_eq (primitive : LogSumExpRanges.Primitives platform)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)|≤(2:ℝ)^(23:Nat)) :
    (ByteMemory.load32 (after (pipeline:=pipeline) stores) pipeline.selection.destination).toNat=
      GreedySampling.sample platform logits :=
  (token_read classes pool stores found inside).trans (pipeline.token_eq primitive bound)

def logitsAfter : ArrayStorage.BFBuffer logits :=
  ArrayFrame.bf pipeline.selection.logitsAfter (after (pipeline:=pipeline) stores)
    (fun offset bound => frame classes pool stores found inside classes.logits offset bound)

def after16 (halfStores : List HalfMemory.Store) : ByteMemory.Bytes := HalfMemory.execute halfStores pipeline.memory

omit inside in
theorem frame16 (halfStores : List HalfMemory.Store)
    (halfInside : MemoryRegions.Inside16 region.base region.size halfStores)
    (safe : classes.Safe base size) (offset : Nat) (bound : offset<size) :
    after16 (pipeline:=pipeline) halfStores (base+offset)=pipeline.memory (base+offset) :=
  MemoryRegions.execute16_other halfStores pipeline.memory halfInside
    (pool.selected_safe classes found safe) offset bound

variable {model : TokenInference.Pipeline}

def parametersAfter (parameters : TokenParameterMemory.Storage model pipeline.memory)
    (safe : parameters.Protected classes.Safe) : TokenParameterMemory.Storage model (after (pipeline:=pipeline) stores) :=
  parameters.reframe _ (parameters.protected_mono (fun _ _ region => frame classes pool stores found inside region) safe)

theorem parameters_regions (parameters : TokenParameterMemory.Storage model pipeline.memory)
    (safe : parameters.Protected classes.Safe) (property : Nat → Nat → Prop) :
    (parametersAfter classes pool stores found inside parameters safe).Protected property ↔ parameters.Protected property :=
  parameters.reframe_protected _ _ property

def cachesAfter (stages : List DecodeStage.Stage) (cache : DecodeChain.Caches stages n)
    (storage : DecodeFrame.Storage stages cache pipeline.memory)
    (safe : DecodePreservation.Protected classes.Safe stages cache pipeline.memory storage) :
    DecodeFrame.Storage stages cache (after (pipeline:=pipeline) stores) :=
  DecodePreservation.reframe classes.Safe pipeline.memory _ (fun _ _ region => frame classes pool stores found inside region)
    stages cache storage safe


omit inside in
theorem token_read16 (halfStores : List HalfMemory.Store)
    (halfInside : MemoryRegions.Inside16 region.base region.size halfStores) :
    (ByteMemory.load32 (after16 (pipeline:=pipeline) halfStores) pipeline.selection.destination).toNat=
      pipeline.selection.token :=
  congrArg BitVec.toNat (ArrayFrame.word_congr pipeline.memory (after16 (pipeline:=pipeline) halfStores)
    pipeline.selection.destination 4 0 (frame16 classes pool found halfStores halfInside classes.token) (by decide))

def parametersAfter16 (halfStores : List HalfMemory.Store)
    (halfInside : MemoryRegions.Inside16 region.base region.size halfStores)
    (parameters : TokenParameterMemory.Storage model pipeline.memory)
    (safe : parameters.Protected classes.Safe) : TokenParameterMemory.Storage model (after16 (pipeline:=pipeline) halfStores) :=
  parameters.reframe _ (parameters.protected_mono
    (fun _ _ region => frame16 classes pool found halfStores halfInside region) safe)

def cachesAfter16 (halfStores : List HalfMemory.Store)
    (halfInside : MemoryRegions.Inside16 region.base region.size halfStores)
    (stages : List DecodeStage.Stage) (cache : DecodeChain.Caches stages n)
    (storage : DecodeFrame.Storage stages cache pipeline.memory)
    (safe : DecodePreservation.Protected classes.Safe stages cache pipeline.memory storage) :
    DecodeFrame.Storage stages cache (after16 (pipeline:=pipeline) halfStores) :=
  DecodePreservation.reframe classes.Safe pipeline.memory _
    (fun _ _ region => frame16 classes pool found halfStores halfInside region) stages cache storage safe

def graphSource : String := r#"function kernelGraph(logits: MlxArray): MlxArray {
  const shape = logits.shape;
  const vocab = shape.at(-1)!, rows = logits.size / vocab, tiles = Math.ceil(vocab / 1024);
  partial ??= new MetalKernel({ name: "normalized_argmax_partial", header,
    inputNames: ["logits", "lse"], outputNames: ["values", "indices"], source: partialSource });
  finish ??= new MetalKernel({ name: "normalized_argmax_finish", header,
    inputNames: ["values", "indices"], outputNames: ["out"], source: finishSource });
  using lse = ops.logsumexpAxis(logits, -1, true);
  const [values, indices] = partial.apply([logits, lse], {
    outputs: [{ shape: [rows, tiles], dtype: Dtype.float32 }, { shape: [rows, tiles], dtype: Dtype.uint32 }],
    grid: [tiles * 128, rows, 1], threadGroup: [128, 1, 1],
    templateInts: { V: vocab, P: tiles }, templateDtypes: { T: logits.dtype },
  });
  try {
    using tokens = finish.apply([values!, indices!], {
      outputs: [{ shape: [rows], dtype: Dtype.uint32 }],
      grid: [128, rows, 1], threadGroup: [128, 1, 1], templateInts: { P: tiles },
    })[0]!;
    return ops.reshape(tokens, shape.slice(0, -1));
  } finally { values!.dispose(); indices!.dispose(); }
}"#

def selectionSource : String := r#"export function normalizedArgmax(logits: MlxArray): MlxArray {
  const dtype = logits.dtype;
  if (isShapelessTracing() || logits.size === 0 ||
      (dtype !== Dtype.float32 && dtype !== Dtype.float16 && dtype !== Dtype.bfloat16)) {
    using lse = ops.logsumexpAxis(logits, -1, true);
    using scores = ops.sub(logits, lse);
    return ops.argmaxAxis(scores, -1);
  }
  compiled ??= new CompiledFunction(([input]) => [kernelGraph(input!)], false);
  return compiled.apply([logits])[0]!;
}"#

def scalarSource : String := r#"void LogSumExp::eval_gpu(const std::vector<array>& inputs, array& out) {
  assert(inputs.size() == 1);
  if (!issubdtype(out.dtype(), floating)) {
    throw std::runtime_error(
        "[logsumexp] Does not support non-floating point types.");
  }
  auto& s = stream();
  auto& d = metal::device(s.device);
  auto& compute_encoder = metal::get_command_encoder(s);

  // Make sure that the last dimension is contiguous
  auto ensure_contiguous = [&](const array& x) {
    if (x.flags().contiguous && x.strides()[x.ndim() - 1] == 1) {
      return x;
    } else {
      array x_copy = contiguous_copy_gpu(x, s);
      compute_encoder.add_temporary(x_copy);
      return x_copy;
    }
  };

  auto in = ensure_contiguous(inputs[0]);
  if (in.flags().row_contiguous) {
    out.set_data(allocator::malloc(out.nbytes()));
  } else {
    auto n = in.shape(-1);
    auto flags = in.flags();
    auto strides = in.strides();
    for (auto& s : strides) {
      s /= n;
    }
    bool col_contig = strides[0] == 1;
    for (int i = 1; col_contig && i < strides.size(); ++i) {
      col_contig &=
          (out.shape(i) == 1 || strides[i - 1] == out.shape(i) * strides[i]);
    }
    flags.col_contiguous = col_contig;
    out.set_data(
        allocator::malloc(in.nbytes() / n),
        in.data_size() / n,
        std::move(strides),
        flags);
  }

  int axis_size = in.shape().back();
  int n_rows = in.data_size() / axis_size;

  const int simd_size = 32;
  const int n_reads = 4;
  const int looped_limit = LOGSUMEXP_LOOPED_LIMIT;

  std::string kernel_name = (axis_size > looped_limit) ? "looped_" : "block_";
  kernel_name += "logsumexp_";
  kernel_name += type_to_name(out);

  auto kernel = get_logsumexp_kernel(d, kernel_name, out);
  {
    MTL::Size grid_dims, group_dims;
    if (axis_size <= looped_limit) {
      size_t threadgroup_needed = (axis_size + n_reads - 1) / n_reads;
      size_t simds_needed = (threadgroup_needed + simd_size - 1) / simd_size;
      size_t threadgroup_size = simd_size * simds_needed;
      assert(threadgroup_size <= kernel->maxTotalThreadsPerThreadgroup());
      size_t n_threads = n_rows * threadgroup_size;
      grid_dims = MTL::Size(n_threads, 1, 1);
      group_dims = MTL::Size(threadgroup_size, 1, 1);
    } else {
      size_t threadgroup_size = kernel->maxTotalThreadsPerThreadgroup();
      size_t n_threads = n_rows * threadgroup_size;
      grid_dims = MTL::Size(n_threads, 1, 1);
      group_dims = MTL::Size(threadgroup_size, 1, 1);
    }

    compute_encoder.set_compute_pipeline_state(kernel);
    compute_encoder.set_input_array(in, 0);
    compute_encoder.set_output_array(out, 1);
    compute_encoder.set_bytes(axis_size, 2);
    compute_encoder.dispatch_threads(grid_dims, group_dims);
  }
}"#

end Inference.Models.Qwen.NormalizedArgmaxLeaseMemory

import models.qwen.NormalizedArgmaxLeaseMemory

-- Selected B1 sampler suffix in the existing logical heap model. Native buffer
-- lengths and completion events must refine these explicit logical contracts.
namespace Inference.Models.Qwen.NormalizedArgmaxLeaseReuse
open Contracts.Mlx BufferLeaseMemory NormalizedArgmaxLeaseMemory
open Kernels.Sampling

variable {logits : Fin 248320 → ArrayStorage.BF} {platform : LogSumExpRanges.Platform}
  {source : ArrayStorage.BFBuffer logits}
  (pipeline : NormalizedArgmaxMemory.Pipeline platform source)
  {initial : Kind → Lease} (lifecycle : Lifecycle initial)

-- This is exactly the list returned by recycleAll, rather than an unrelated
-- free-pool witness. Equal-sized partials follow the modeled disposal order.
def completedPool : Pool (logicalClasses pipeline) where
  entries := [logicalRegion pipeline .scalar, logicalRegion pipeline .indices,
    logicalRegion pipeline .values]
  contents := (List.Perm.swap _ _ _).trans ((List.Perm.swap _ _ _).cons _)
    |>.trans (List.Perm.swap _ _ _)
  ordered := by simp [List.pairwise_cons, logicalRegion]

theorem recycled_pool : recycleAll (logicalClasses pipeline) lifecycle =
    some (completedPool pipeline).entries := lifecycle.recycles_all (logicalClasses pipeline)

theorem partial_reused (pagePositive : 0<page) :
    reuse 972 page (completedPool pipeline).entries =
      some (logicalRegion pipeline .indices, [logicalRegion pipeline .scalar,
        logicalRegion pipeline .values]) := by
  simp [reuse,lowerBound,completedPool,logicalRegion]
  omega

-- A successful recycled-pool observation forces completion and last-read
-- events when either lease count was initially positive.
theorem reuse_requires_completion (pending : 0<(initial kind).commands) :
    Event.completed ∈ lifecycle.events kind := lifecycle.completion_required kind pending

theorem reuse_requires_last_read (unread : 0<(initial kind).reads) :
    Event.lastRead ∈ lifecycle.events kind := lifecycle.last_read_required kind unread

-- The sum bounds only these three logical sampler scratch allocations. It is
-- independent of the number of later uses; it is not a physical-RAM theorem.
theorem sampler_scratch_bytes :
    ((completedPool pipeline).entries.map Region.size).sum = 1946 := by
  norm_num [completedPool,logicalRegion]

variable (stores : List ByteMemory.Store)
  (inside : MemoryRegions.Inside32 (logicalRegion pipeline .indices).base
    (logicalRegion pipeline .indices).size stores)

include inside

-- The selected argmax token survives a concrete subsequent write into the
-- completion-recycled index partial on the very same sampler output heap.
theorem token_after_reuse (pagePositive : 0<page) :
    (ByteMemory.load32 (ByteMemory.execute stores pipeline.memory)
      pipeline.selection.destination).toNat = pipeline.selection.token :=
  token_read (logicalClasses pipeline) (completedPool pipeline) stores
    (partial_reused pipeline pagePositive) inside

-- Every existing protected parameter/cache/workspace span is framed by the
-- same selected recycled allocation; no replacement or encoded heap is used.
theorem retained_after_reuse (pagePositive : 0<page)
    (safe : pipeline.Safe base size) (offset : Nat) (bound : offset<size) :
    ByteMemory.execute stores pipeline.memory (base+offset)=pipeline.memory (base+offset) :=
  frame (logicalClasses pipeline) (completedPool pipeline) stores
    (partial_reused pipeline pagePositive) inside (logical_safe safe) offset bound

theorem completed_reuse_preserves_token (pagePositive : 0<page) :
    recycleAll (logicalClasses pipeline) lifecycle=some (completedPool pipeline).entries ∧
    reuse 972 page (completedPool pipeline).entries=
      some (logicalRegion pipeline .indices, [logicalRegion pipeline .scalar,logicalRegion pipeline .values]) ∧
    (∀ kind, 0<(initial kind).commands → Event.completed∈lifecycle.events kind) ∧
    (ByteMemory.load32 (ByteMemory.execute stores pipeline.memory)
      pipeline.selection.destination).toNat=pipeline.selection.token :=
  ⟨recycled_pool pipeline lifecycle, partial_reused pipeline pagePositive,
    fun _kind pending => reuse_requires_completion lifecycle pending,
    token_after_reuse pipeline stores inside pagePositive⟩

end Inference.Models.Qwen.NormalizedArgmaxLeaseReuse

import contracts.mlx.MemoryRegions

-- Manual ownership/selection model of the pinned MLX buffer cache. Native
-- shared_ptr counts, completion callbacks, extracted buffer addresses/lengths,
-- and device allocation remain correspondence obligations.
namespace Inference.Contracts.Mlx.BufferLeaseMemory

structure Region where
  base : Nat
  size : Nat
  deriving DecidableEq

def Apart (a b : Region) : Prop := MemoryRegions.Disjoint a.base a.size b.base b.size

theorem apart_symm (h : Apart a b) : Apart b a := MemoryRegions.disjoint_symm h

-- All future reads and outstanding submitted commands must hold a lease.
-- Completing a read does not complete a GPU command, nor conversely.
structure Lease where
  host : Bool
  reads : Nat
  commands : Nat
  deriving DecidableEq

def Lease.recyclable (lease : Lease) : Prop := lease.host=false ∧ lease.reads=0 ∧ lease.commands=0
instance (lease : Lease) : Decidable lease.recyclable := inferInstanceAs (Decidable (_ ∧ _ ∧ _))

inductive Event where
  | releaseHost | lastRead | completed
  deriving DecidableEq

inductive Step : Lease → Event → Lease → Prop where
  | release : Step ⟨true,r,c⟩ .releaseHost ⟨false,r,c⟩
  | read : Step ⟨h,r+1,c⟩ .lastRead ⟨h,r,c⟩
  | complete : Step ⟨h,r,c+1⟩ .completed ⟨h,r,c⟩

inductive Runs : Lease → List Event → Lease → Prop where
  | nil : Runs lease [] lease
  | cons : Step before event middle → Runs middle events after → Runs before (event::events) after

theorem reads_complete (host : Bool) (reads commands : Nat) :
    Runs ⟨host,reads,commands⟩ (List.replicate reads .lastRead) ⟨host,0,commands⟩ := by
  induction reads with
  | zero => exact .nil
  | succ reads ih => exact .cons .read (by simpa only [List.replicate_succ] using ih)

theorem commands_complete (host : Bool) (reads commands : Nat) :
    Runs ⟨host,reads,commands⟩ (List.replicate commands .completed) ⟨host,reads,0⟩ := by
  induction commands with
  | zero => exact .nil
  | succ commands ih => exact .cons .complete (by simpa only [List.replicate_succ] using ih)

theorem Runs.append (first : Runs a xs b) (second : Runs b ys c) : Runs a (xs++ys) c := by
  induction first with
  | nil => exact second
  | cons step rest ih => exact .cons step (ih second)

-- Positive finite witnesses, not an oracle that declares an incomplete GPU
-- dispatch complete. Native completion must refine the .completed event.
theorem drain (lease : Lease) : ∃ events, Runs lease events ⟨false,0,0⟩ := by
  obtain ⟨host,reads,commands⟩ := lease
  have rest := (reads_complete false reads commands).append (commands_complete false 0 commands)
  cases host with
  | false => exact ⟨_,rest⟩
  | true => exact ⟨_,.cons .release rest⟩

theorem pending_not_recyclable (lease : Lease) (pending : 0<lease.commands) : ¬lease.recyclable := by
  intro h
  have := h.2.2
  omega

theorem unread_not_recyclable (lease : Lease) (unread : 0<lease.reads) : ¬lease.recyclable := by
  intro h
  have := h.2.1
  omega

theorem Runs.completed_required (execution : Runs initial events final)
    (pending : 0<initial.commands) (finished : final.commands=0) : Event.completed∈events := by
  induction execution with
  | nil => omega
  | cons step rest ih =>
    cases step with
    | release => exact List.mem_cons_of_mem _ (ih pending finished)
    | read => exact List.mem_cons_of_mem _ (ih pending finished)
    | complete => simp

theorem Runs.lastRead_required (execution : Runs initial events final)
    (unread : 0<initial.reads) (finished : final.reads=0) : Event.lastRead∈events := by
  induction execution with
  | nil => omega
  | cons step rest ih =>
    cases step with
    | release => exact List.mem_cons_of_mem _ (ih unread finished)
    | read => simp
    | complete => exact List.mem_cons_of_mem _ (ih unread finished)

-- The native multimap is ordered by buffer length. The list view below is
-- supplied by extraction; the executable search models lower_bound(size).
def lowerBound (requested : Nat) : List Region → Option (Region × List Region)
  | [] => none
  | region::pool =>
    if requested≤region.size then some (region,pool)
    else (lowerBound requested pool).map (fun selected => (selected.1,region::selected.2))

inductive Pick (requested : Nat) : List Region → Region → List Region → Prop where
  | here (fits : requested≤region.size) : Pick requested (region::pool) region pool
  | skip (small : region.size<requested) : Pick requested pool selected rest →
      Pick requested (region::pool) selected (region::rest)

theorem lowerBound_pick (found : lowerBound requested pool=some (region,rest)) : Pick requested pool region rest := by
  induction pool generalizing rest with
  | nil => simp [lowerBound] at found
  | cons first pool ih =>
    simp only [lowerBound] at found
    split at found
    · cases found
      exact .here ‹_›
    · rename_i small
      cases next : lowerBound requested pool with
      | none => simp [next] at found
      | some selected =>
        rcases selected with ⟨selected,tail⟩
        simp only [next,Option.map_some,Option.some.injEq,Prod.mk.injEq] at found
        rcases found with ⟨rfl,rfl⟩
        exact .skip (by omega) (ih next)

theorem Pick.fits (pick : Pick requested pool region rest) : requested≤region.size := by
  induction pick with
  | here fits => exact fits
  | skip _ _ ih => exact ih

theorem Pick.perm (pick : Pick requested pool region rest) : pool.Perm (region::rest) := by
  induction pick with
  | here => exact .refl _
  | skip small pick ih => exact (ih.cons _).trans (List.Perm.swap _ _ _)

theorem Pick.minimum (pick : Pick requested pool region rest)
    (ordered : pool.Pairwise (fun a b => a.size≤b.size))
    (candidate : Region) (member : candidate∈pool) (fits : requested≤candidate.size) :
    region.size≤candidate.size := by
  induction pick with
  | here bound =>
    rcases List.mem_cons.mp member with equal | member
    · subst candidate; exact Nat.le_refl _
    · exact (List.pairwise_cons.mp ordered).1 candidate member
  | skip small pick ih =>
    rcases List.mem_cons.mp member with equal | member
    · subst candidate; omega
    · exact ih (List.pairwise_cons.mp ordered).2 member

theorem Pick.members (pick : Pick requested pool region rest) :
    region∈pool ∧ ∀ r∈rest, r∈pool := by
  exact ⟨pick.perm.mem_iff.mpr (by simp),fun r member => pick.perm.mem_iff.mpr (by simp [member])⟩

-- Matches the native strict rejection threshold. Overflow and extracted page
-- size are external machine-integer obligations; arithmetic here is Nat.
def reuse (requested page : Nat) (pool : List Region) : Option (Region × List Region) := do
  let selected ← lowerBound requested pool
  if selected.1.size < min (2*requested) (requested+2*page) then some selected else none

theorem reuse_pick (found : reuse requested page pool=some (region,rest)) :
    Pick requested pool region rest ∧ region.size<min (2*requested) (requested+2*page) := by
  unfold reuse at found
  cases next : lowerBound requested pool with
  | none => simp [next] at found
  | some selected =>
    rcases selected with ⟨selected,tail⟩
    rw [next] at found
    change (if selected.size < min (2*requested) (requested+2*page) then some (selected,tail) else none)=some (region,rest) at found
    split at found
    · cases found
      exact ⟨lowerBound_pick next,‹_›⟩
    · simp at found

theorem reuse_size (found : reuse requested page pool=some (region,rest)) : requested≤region.size :=
  (reuse_pick found).1.fits

structure Ownership (pool live : List Region) : Prop where
  free : pool.Pairwise Apart
  separate : ∀ r∈pool, ∀ s∈live, Apart r s
  live : live.Pairwise Apart

theorem allocate (owned : Ownership pool live) (found : reuse requested page pool=some (region,rest)) :
    Ownership rest (region::live) := by
  have pick := (reuse_pick found).1
  have pair := List.Perm.pairwise_iff (R:=Apart) (fun h => apart_symm h) pick.perm
  have free : (region::rest).Pairwise Apart := pair.mp owned.free
  rw [List.pairwise_cons] at free
  refine ⟨free.2,?_,?_,⟩
  · intro r member s liveMember
    rcases List.mem_cons.mp liveMember with equal | liveMember
    · subst s
      exact apart_symm (free.1 r member)
    · exact owned.separate r (pick.members.2 r member) s liveMember
  · rw [List.pairwise_cons]
    exact ⟨fun s member => owned.separate region pick.members.1 s member,owned.live⟩

-- Recycling is permitted only after host ownership, all remaining reads, and
-- every submitted command lease have ended. It does not write memory.
def recycle (lease : Lease) (region : Region) (pool : List Region) : Option (List Region) :=
  if lease.recyclable then some (region::pool) else none

theorem recycle_ready (found : recycle lease region pool=some next) : lease.recyclable ∧ next=region::pool := by
  unfold recycle at found
  split at found
  · exact ⟨‹_›,Option.some.inj found.symm⟩
  · simp at found

theorem release (owned : Ownership pool (region::live)) (_finished : Runs initial events final)
    (found : recycle final region pool=some next) : Ownership next live := by
  have ready := recycle_ready found
  rw [ready.2]
  have active := List.pairwise_cons.mp owned.live
  refine ⟨?_,?_,active.2⟩
  · rw [List.pairwise_cons]
    exact ⟨fun r member => apart_symm (owned.separate r member region (by simp)),owned.free⟩
  · intro r member s liveMember
    rcases List.mem_cons.mp member with equal | member
    · subst r
      exact active.1 s liveMember
    · exact owned.separate r member s (by simp [liveMember])

-- Every legal 32-bit store in the chosen allocation frames ALL live buffers.
-- Allocation and recycling themselves preserve the complete byte image.
theorem writes_frame (owned : Ownership pool live)
    (found : reuse requested page pool=some (region,rest))
    (stores : List ByteMemory.Store) (inside : MemoryRegions.Inside32 region.base region.size stores)
    (memory : ByteMemory.Bytes) (liveRegion : Region) (member : liveRegion∈live)
    (offset : Nat) (bound : offset<liveRegion.size) :
    ByteMemory.execute stores memory (liveRegion.base+offset)=memory (liveRegion.base+offset) :=
  MemoryRegions.execute32_other stores memory inside
    (owned.separate region (reuse_pick found).1.members.1 liveRegion member) offset bound

-- A concrete sampler partial is 243 float32 scores or 243 uint32 IDs. Its
-- native allocation need not share an arena or address with any other partial.
theorem sampler_partial_size (found : reuse 972 page pool=some (region,rest)) :
    243*4≤region.size := reuse_size found

theorem reuse_singleton (region : Region) (positive : 0<region.size) (pagePositive : 0<page) :
    reuse region.size page [region]=some (region,[]) := by
  have threshold : region.size < min (2*region.size) (region.size+2*page) := by omega
  simp [reuse,lowerBound,threshold]

-- Positive sampler-partial lifecycle in the modeled isolated free pool.
-- Actual cache contents/tie selection and callback occurrence are not inferred.
theorem sampler_partial_roundtrip (region : Region) (size : region.size=972)
    (lease : Lease) (pagePositive : 0<page) :
    ∃ events, Runs lease events ⟨false,0,0⟩ ∧
      recycle ⟨false,0,0⟩ region []=some [region] ∧
      reuse 972 page [region]=some (region,[]) := by
  obtain ⟨events,execution⟩ := drain lease
  refine ⟨events,execution,?_,?_⟩
  · rfl
  · rw [←size]
    exact reuse_singleton region (by omega) pagePositive

structure Snapshot where
  memory : ByteMemory.Bytes
  pool : List Region
  live : List Region

def Snapshot.allocate (before : Snapshot) (requested page : Nat) : Option (Region × Snapshot) := do
  let selected ← reuse requested page before.pool
  return (selected.1,⟨before.memory,selected.2,selected.1::before.live⟩)

theorem Snapshot.allocate_bytes {before after : Snapshot} (found : before.allocate requested page=some (region,after)) :
    after.memory=before.memory := by
  unfold Snapshot.allocate at found
  cases result : reuse requested page before.pool with
  | none => simp [result] at found
  | some selected =>
    simp only [result] at found
    cases found
    rfl

def Snapshot.retire (before : Snapshot) (lease : Lease) : Option Snapshot :=
  match before.live with
  | [] => none
  | region::live => (recycle lease region before.pool).map (fun pool => ⟨before.memory,pool,live⟩)

theorem Snapshot.retire_bytes {before after : Snapshot} (found : before.retire lease=some after) : after.memory=before.memory := by
  unfold Snapshot.retire at found
  cases active : before.live with
  | nil => simp [active] at found
  | cons region live =>
    simp only [active] at found
    cases result : recycle lease region before.pool with
    | none => simp [result] at found
    | some pool =>
      simp only [result,Option.map_some,Option.some.injEq] at found
      cases found
      rfl

-- Recycling a submitted buffer with a positive command count necessarily
-- contains a completion event; a host release cannot substitute for it.
theorem recycle_completed (execution : Runs initial events final) (pending : 0<initial.commands)
    (found : recycle final region pool=some next) : Event.completed∈events :=
  execution.completed_required pending (recycle_ready found).1.2.2

theorem recycle_lastRead (execution : Runs initial events final) (unread : 0<initial.reads)
    (found : recycle final region pool=some next) : Event.lastRead∈events :=
  execution.lastRead_required unread (recycle_ready found).1.2.1


def cacheSource : String := r#"  T* reuse_from_cache(size_t size) {
    // Find the closest buffer in pool.
    auto it = buffer_pool_.lower_bound(size);
    if (it == buffer_pool_.end() ||
        it->first >= std::min(2 * size, size + 2 * page_size_)) {
      return nullptr;
    }

    // Collect from the cache.
    T* buf = it->second->buf;
    pool_size_ -= it->first;

    // Remove from record.
    remove_from_list(it->second);
    buffer_pool_.erase(it);
    return buf;
  }"#

def recycleSource : String := r#"  void recycle_to_cache(T* buf) {
    assert(buf);
    // Add to cache.
    BufferHolder* bh = new BufferHolder(buf);
    add_at_head(bh);
    size_t size = get_size_(buf);
    pool_size_ += size;
    buffer_pool_.emplace(size, bh);
  }"#

def evalSource : String := r#"void eval(array& arr) {
  auto pool = metal::new_scoped_memory_pool();
  auto s = arr.primitive().stream();
  auto& encoder = metal::get_command_encoder(s);
  auto* command_buffer = encoder.get_command_buffer();

  auto outputs = arr.outputs();
  {
    // If the array is a tracer hold a reference
    // to its inputs so they don't get donated
    std::vector<array> inputs;
    if (arr.is_tracer()) {
      inputs = arr.inputs();
    }

    debug_set_primitive_buffer_label(command_buffer, arr.primitive());
    arr.primitive().eval_gpu(arr.inputs(), outputs);
  }
  std::unordered_set<std::shared_ptr<array::Data>> buffers;
  for (auto& in : arr.inputs()) {
    buffers.insert(in.data_shared_ptr());
  }
  for (auto& s : arr.siblings()) {
    buffers.insert(s.data_shared_ptr());
  }
  // Remove the output if it was donated to by an input
  if (auto it = buffers.find(arr.data_shared_ptr()); it != buffers.end()) {
    buffers.erase(it);
  }

  if (encoder.needs_commit()) {
    encoder.end_encoding();
    scheduler::notify_new_task(s);
    encoder.commit([s, buffers = std::move(buffers)]() {
      scheduler::notify_task_completion(s);
    });
  } else {
    command_buffer->addCompletedHandler(
        [buffers = std::move(buffers)](MTL::CommandBuffer* cbuf) {});
  }
}"#

def freeSource : String := r#"void MetalAllocator::free(Buffer buffer) {
  auto buf = static_cast<MTL::Buffer*>(buffer.ptr());
  if (buf == nullptr) {
    return;
  }
  std::unique_lock lk(mutex_);
  active_memory_ -= buf->length();
  if (get_cache_memory() < max_pool_size_) {
    buffer_cache_.recycle_to_cache(buf);
  } else {
    num_resources_--;
    if (!buf->heap()) {
      residency_sets_.erase(buf);
    }
    lk.unlock();
    auto pool = metal::new_scoped_memory_pool();
    buf->release();
  }
}"#

def dataSource : String := r#"    ~Data() {
      d(buffer);
    }"#

end Inference.Contracts.Mlx.BufferLeaseMemory

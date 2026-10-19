import host.ts.RenameRetainedDispose
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Ts.Owned.Annotated.Dispose
open Parametric

theorem success_heap (source : St Host.Load.LSt) (data : SourceData) :
    (successResult source data).heap =
      (entryState source data.env data.home data.owner).heap.set data.owner
        (.obj (flaggedObject data.ownerObject data.brand data.flagEnumerable)) := rfl

theorem success_next (source : St Host.Load.LSt) (data : SourceData) :
    (successResult source data).next = (entryState source data.env data.home data.owner).next := rfl

theorem success_caller (source : St Host.Load.LSt) (data : SourceData) :
    (successResult source data).stack = source.stack := rfl

theorem success_control (source : St Host.Load.LSt) (data : SourceData) :
    (successResult source data).ctl = .ret .undef := rfl

theorem success_disposed (source : St Host.Load.LSt) (data : SourceData) (bound : data.owner < 2^64) :
    (successResult source data).heap.get data.owner =
      some (.obj (flaggedObject data.ownerObject data.brand data.flagEnumerable)) ∧
    findPriv data.brand flag (flaggedObject data.ownerObject data.brand data.flagEnumerable).priv =
      some (.data (.bool true) true data.flagEnumerable) := by
  constructor
  · rw [success_heap]
    exact (PTrie.get_set_u64 _ _ _ bound data.owner).trans (if_pos rfl)
  · exact findPriv_set_same _ _ _ _

/-- The completed body retains every entry heap slot except the receiver's
private-field update, including the actual closure receiver and home cells. -/
theorem success_entry_heap (source : St Host.Load.LSt) (data : SourceData)
    (bound : data.owner < 2^64) (address : Nat) (different : address ≠ data.owner) :
    (successResult source data).heap.get address =
      (entryState source data.env data.home data.owner).heap.get address := by
  rw [success_heap,PTrie.get_set_u64 _ _ _ bound address,if_neg different]

theorem success_receiver {live : Nat → Prop} (source : St Host.Load.LSt) (data : SourceData)
    (entry : SourceEntry data live source) (bound : source.next+2 ≤ 2^64) :
    (successResult source data).heap.get source.next = some (.cell (some (.obj data.owner))) := by
  have below := entry.below data.owner (by simp)
  rw [success_entry_heap source data (by omega) source.next (by omega)]
  exact entry_receiver Host.Load.ffi source data.env data.home data.owner bound

private theorem entry_home (source : St Host.Load.LSt) (env : Env) (home : Val) (owner : Nat)
    (bound : source.next+2 ≤ 2^64) (nonempty : home ≠ .undef) :
    (entryState source env home owner).heap.get (source.next+1) = some (.cell (some home)) := by
  rw [entry_heap]
  unfold closureState
  rw [closureStart_home source env home (.obj owner) nonempty]
  exact (PTrie.get_set_u64 (source.heap.set source.next (.cell (some (.obj owner))))
    (source.next+1) (.cell (some home)) (by omega) (source.next+1)).trans (if_pos rfl)

theorem success_home {live : Nat → Prop} (source : St Host.Load.LSt) (data : SourceData)
    (entry : SourceEntry data live source) (bound : source.next+2 ≤ 2^64) (home : data.home ≠ .undef) :
    (successResult source data).heap.get (source.next+1) = some (.cell (some data.home)) := by
  have below := entry.below data.owner (by simp)
  exact (success_entry_heap source data (by omega) (source.next+1) (by omega)).trans
    (entry_home source data.env data.home data.owner bound home)

end Host.Ts.Owned.Annotated.Dispose

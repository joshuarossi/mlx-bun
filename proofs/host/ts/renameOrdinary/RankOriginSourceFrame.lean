import host.ts.renameOrdinary.RankOriginResult
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The actual source prefix writes two initialized cells and allocates the
getter's two fresh cells. This is an equation about the original interpreter
states, checked by conversion in the kernel. -/
theorem source_heap_updates : Prefix.input.heap =
    (((input.heap.set Variable5.address (.cell (some (natV 3)))).set input.next
      ((Prefix.input.heap.get input.next).getD (.cell none))).set (input.next+1)
      ((Prefix.input.heap.get (input.next+1)).getD (.cell none))).set PointerBinding48.sourceAddress
      (.cell (some (.ptr (.ext 117452) 0))) := by host_kernel_rfl

theorem source_rank_bound : Variable5.address < 2^64 := by decide +kernel
theorem source_pointer_bound : PointerBinding48.sourceAddress < 2^64 := by decide +kernel
theorem source_fresh_bound : input.next+1 < 2^64 := by decide +kernel

theorem source_heap_frame (a : Nat) (bound : a < input.next)
    (notRank : a ≠ Variable5.address) (notPointer : a ≠ PointerBinding48.sourceAddress) :
    Prefix.input.heap.get a = input.heap.get a := by
  rw [source_heap_updates]
  simp only [PTrie.get_set_u64 _ _ _ source_pointer_bound,ite_eq_right notPointer,
    PTrie.get_set_u64 _ _ _ source_fresh_bound,ite_eq_right (show a ≠ input.next+1 by omega),
    PTrie.get_set_u64 _ _ _ (show input.next < 2^64 by have := source_fresh_bound; omega),
    ite_eq_right (Nat.ne_of_lt bound),PTrie.get_set_u64 _ _ _ source_rank_bound,ite_eq_right notRank]
end Host.Load.Run.Full.Ordinary.RankOrigin

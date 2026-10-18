import host.ts.RenameParametricTypedArray
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- Both original typed-array allocations leave all earlier heap addresses
untouched. The two bounded-store hypotheses are discharged by one bound. -/
theorem newTyped_heap_below (F : Ffi) (s : St F.S) (k : EltK) (proto : Nat)
    (bs : List Byte) (count a : Nat) (old : a < s.next) (bound : s.next+1 < 2^64) :
    ((newTyped F s k proto bs count).2.ret (.obj (s.next+1))).heap.get a = s.heap.get a := by
  have hb : s.next < 2^64 := by omega
  have h₀ : a ≠ s.next := Nat.ne_of_lt old
  have h₁ : a ≠ s.next+1 := by omega
  simp only [newTyped,St.allocObj,St.alloc,St.ret,
    PTrie.get_set_u64 _ _ _ bound,PTrie.get_set_u64 _ _ _ hb,ite_eq_right h₀,ite_eq_right h₁]
end Host.Ts.Owned.Parametric

import host.mlx.NativeRoles
import host.ts.RenameAnnotationResources

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles.CounterR
open Host.Ts Host.Ts.Owned

/-- Allocation correspondence composes at the actual middle counter. All
allocated indexes remain bounded and injective, and every future allocation
keeps its offset. The middle counter is not inferred from live notes alone. -/
theorem compose {f g : Nat → Nat} {source middle target : Nat}
    (first : CounterR f source middle) (second : CounterR g middle target) :
    CounterR (fun i => g (f i)) source target := by
  refine ⟨?_,?_,?_⟩
  · intro i hi
    exact second.bound _ (first.bound i hi)
  · intro i j hi hj equal
    exact first.injective i j hi hj
      (second.injective _ _ (first.bound i hi) (first.bound j hj) equal)
  · intro k
    rw [first.fresh k,second.fresh k]

/-- A checked run may allocate any finite number of resources. Repeated
single allocations advance both related counters without changing the map. -/
theorem advance_by {f : Nat → Nat} {source target : Nat}
    (current : CounterR f source target) (count : Nat) :
    CounterR f (source+count) (target+count) := by
  induction count with
  | zero => simpa only [Nat.add_zero] using current
  | succ count ih => simpa only [Nat.add_succ] using ih.advance

/-- Resource composition used by retained restart also preserves both native
allocation counters. The two initial counter correspondences are explicit. -/
theorem compose_resources {R K : Ren} {a b c i j k : Nat}
    (firstHandle : CounterR K.handle a b) (secondHandle : CounterR R.handle b c)
    (firstNode : CounterR K.node i j) (secondNode : CounterR R.node j k) :
    CounterR (Annotated.composeResources R K).handle a c ∧
    CounterR (Annotated.composeResources R K).node i k :=
  ⟨firstHandle.compose secondHandle,firstNode.compose secondNode⟩

end Host.Mlx.Ffi.NativeRoles.CounterR

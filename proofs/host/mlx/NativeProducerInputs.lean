import host.mlx.NativeInputs
import host.mlx.NativeSupport

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

/-- Decoding owned bigint arguments uses the original ordered producer lookup. -/
theorem arrIns_handles (s : St) (handles : List Nat) :
    arrIns s (handles.map fun a => .big (Int.ofNat a)) = nodesOf s handles := by
  induction handles with
  | nil => rfl
  | cons a rest ih =>
    simp only [arrIns] at ih
    simp only [arrIns,List.map_cons,List.mapM_cons,nodesOf,argNat_big_nat,Option.bind_some]
    rw [ih]
    cases s.nodeId? a <;> cases nodesOf s rest <;> rfl

theorem Live.arrIns_handles {NR : NumV → NumV → Prop} {R : Ren}
    {NodeRel : Nat → Node → Node → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R NodeRel ObjRel H N tail s s') (handles inputs : List Nat)
    (live : listSupport H handles) (source : Ffi.nodesOf s handles = some inputs) :
    arrIns s (handles.map fun a => .big (Int.ofNat a)) = some inputs ∧
      arrIns s' (handles.map fun a => .big (Int.ofNat (R.handle a))) = some (inputs.map R.node) ∧
      listSupport N inputs := by
  refine ⟨(NativeRoles.arrIns_handles s handles).trans source,?_,h.nodesOf_support handles inputs live source⟩
  have ht := h.nodesOf handles inputs live source
  rw [← NativeRoles.arrIns_handles s' (handles.map R.handle),List.map_map] at ht
  exact ht

end Host.Mlx.Ffi.NativeRoles

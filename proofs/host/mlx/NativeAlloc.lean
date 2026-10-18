import host.mlx.ObjectRoles

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

inductive Constructor where
  | vector | config | closure

def Constructor.name : Constructor → List Char
  | .vector => chars!"mlx_vector_array_new"
  | .config => chars!"mlx_fast_metal_kernel_config_new"
  | .closure => chars!"mlx_closure_new"

def Constructor.object : Constructor → Obj
  | .vector => .vec []
  | .config => .cfg .empty
  | .closure => .clo .empty

theorem Constructor.roles (op : Constructor) (NR : NumV → NumV → Prop) (R : Ren) :
    ObjectR NR R op.object op.object := by
  cases op with
  | vector => exact .vec []
  | config => exact .cfg (CfgR.empty NR)
  | closure => exact .clo .empty

theorem Constructor.call (op : Constructor) (s : St) :
    Ffi.call s op.name [] = ok (s.newObj op.object).2 (.big (Int.ofNat s.next)) := by
  cases op with
  | vector =>
    have hs : symOf chars!"mlx_vector_array_new" = some .vecNew := by decide +kernel
    unfold Constructor.name Constructor.object Ffi.call
    rw [hs] <;> rfl
  | config =>
    have hs : symOf chars!"mlx_fast_metal_kernel_config_new" = some .cfgNew := by decide +kernel
    unfold Constructor.name Constructor.object Ffi.call
    rw [hs] <;> rfl
  | closure =>
    have hs : symOf chars!"mlx_closure_new" = some .closureNew := by decide +kernel
    unfold Constructor.name Constructor.object Ffi.call
    rw [hs] <;> rfl

/-- Empty native vectors, Metal configurations and closures allocate paired
fresh handles by their actual FFI dispatch. Numeric occurrence meanings are
independent of the new handle values. -/
theorem Live.constructor {NR : NumV → NumV → Prop} {R : Ren}
    {NodeRel : Nat → Node → Node → Prop} {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R NodeRel (fun _ => ObjectR NR R) H N tail s s') (op : Constructor)
    (bs : s.next < 2^64) (bt : s'.next < 2^64) :
    Ffi.call s op.name [] = ok (s.newObj op.object).2 (.big (Int.ofNat s.next)) ∧
      Ffi.call s' op.name [] = ok (s'.newObj op.object).2 (.big (Int.ofNat s'.next)) ∧
      Live NR R NodeRel (fun _ => ObjectR NR R) (fun a => a = s.next ∨ H a) N tail
        (s.newObj op.object).2 (s'.newObj op.object).2 ∧
      Host.Ts.Owned.Parametric.TreeR NR R
        (Host.Ts.Owned.Parametric.ret (.big (Int.ofNat s.next)))
        (Host.Ts.Owned.Parametric.ret (.big (Int.ofNat s'.next))) := by
  refine ⟨op.call s, op.call s', h.newObj _ _ (op.roles NR R) bs bt, ?_⟩
  rw [← h.handleMap.head]
  exact .node _ (.cons (.value (.handle _)) .nil)

theorem call_arrayNew (s : St) : Ffi.call s chars!"mlx_array_new" [] = ok s (.big 0) := by
  have hs : symOf chars!"mlx_array_new" = some .arrayNew := by decide +kernel
  unfold Ffi.call
  rw [hs]

end Host.Mlx.Ffi.NativeRoles

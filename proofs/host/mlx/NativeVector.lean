import host.mlx.NativeConfig

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

theorem setVec_existing (s : St) (a : Nat) (old nodes : List Nat)
    (ha : s.obj? a = some (.vec old)) :
    setVec s a nodes = (a, s.setObj a (.vec nodes)) := by
  unfold setVec
  rw [ha]

namespace Live
variable {NR : NumV → NumV → Prop} {R : Ren}
  {NodeRel : Nat → Node → Node → Prop} {H N : Nat → Prop} {tail : List NumV} {s s' : St}

theorem vec_view (h : Live NR R NodeRel (fun _ => ObjectR NR R) H N tail s s')
    (a : Nat) (ha : H a) (nodes : List Nat) (hv : s.obj? a = some (.vec nodes)) :
    s'.obj? (R.handle a) = some (.vec (nodes.map R.node)) := by
  have hr := h.objs a ha
  change OptionR (ObjectR NR R) (s.obj? a) (s'.obj? (R.handle a)) at hr
  rw [hv] at hr
  cases ht : s'.obj? (R.handle a) with
  | none => rw [ht] at hr; cases hr
  | some o =>
    rw [ht] at hr
    cases hr with
    | some hr => cases hr with
      | vec nodes => rfl

theorem kernel_view (h : Live NR R NodeRel (fun _ => ObjectR NR R) H N tail s s')
    (a : Nat) (ha : H a) (name source header : List Char) (inputs outputs : Nat)
    (hk : s.obj? a = some (.kernel name source header inputs outputs)) :
    s'.obj? (R.handle a) = some (.kernel name source header inputs outputs) := by
  have hr := h.objs a ha
  change OptionR (ObjectR NR R) (s.obj? a) (s'.obj? (R.handle a)) at hr
  rw [hk] at hr
  cases ht : s'.obj? (R.handle a) with
  | none => rw [ht] at hr; cases hr
  | some o =>
    rw [ht] at hr
    cases hr with
    | some hr => cases hr with
      | kernel _ _ _ _ _ => rfl

theorem setVec_existing (h : Live NR R NodeRel (fun _ => ObjectR NR R) H N tail s s')
    (a : Nat) (ha : H a) (old nodes : List Nat) (hv : s.obj? a = some (.vec old))
    (bs : a < 2^64) (bt : R.handle a < 2^64) :
    setVec s a nodes = (a, s.setObj a (.vec nodes)) ∧
      setVec s' (R.handle a) (nodes.map R.node) =
        (R.handle a, s'.setObj (R.handle a) (.vec (nodes.map R.node))) ∧
      Live NR R NodeRel (fun _ => ObjectR NR R) H N tail
        (s.setObj a (.vec nodes)) (s'.setObj (R.handle a) (.vec (nodes.map R.node))) :=
  ⟨NativeRoles.setVec_existing s a old nodes hv,
    NativeRoles.setVec_existing s' (R.handle a) (old.map R.node) (nodes.map R.node) (h.vec_view a ha old hv),
    h.setObj a ha _ _ (.vec nodes) bs bt⟩

end Live
end Host.Mlx.Ffi.NativeRoles

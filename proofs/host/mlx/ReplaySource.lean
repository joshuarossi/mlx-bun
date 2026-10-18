import host.mlx.ReplayPlan

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts

/-- The source equations in a replay plan determine the original recursive
execution independently of the relation used for its paired execution. -/
theorem ReplayPlan.source {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {NodeRel : Nat → Node → Node → Prop} {cls : Nat} {N K : Nat → Prop}
    {s final : St} {m result : List (Nat × Nat)} {order : List Nat}
    (plan : ReplayPlan NR R boundary cls NodeRel N s m order K final result) :
    replayOrder s cls m order = M.pure (some (final,result)) := by
  induction plan with
  | done => rfl
  | leaf nd live full node leaf rest ih =>
    exact (replay_leaf_head _ _ _ _ _ nd node leaf).trans ih
  | unchanged nd live full node kernel same inputs keys rest ih =>
    exact (replay_unchanged_head _ _ _ _ _ nd node kernel same).trans ih
  | kernel nd live full node kernel inputs keys create rest ih =>
    exact (replay_kernel_head _ _ _ _ _ nd node kernel).trans ih
  | node nd live full node leaf kernel changed inputs substituted keys metadata shape dt read infer transport rest ih =>
    exact (replay_node_head _ _ _ _ _ nd metadata shape dt node leaf kernel changed read infer).trans ih
  | same nd live full node leaf kernel changed inputs substituted keys metadata index output read infer outputAt transport rest ih =>
    exact (replay_same_head _ _ _ _ _ nd metadata index output node leaf kernel changed read infer outputAt).trans ih

end Host.Mlx.Ffi.NativeRoles

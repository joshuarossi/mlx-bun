import host.ts.RenameParametricClassEntry
import host.ts.RenameRouteDriver
import host.mlx.OrdinaryConcatStates
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro3 72 4855 as Ordinary.VectorToConcat.MlxClass372.classObject
end Host.Load.Run.Full
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.MlxClass372
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
noncomputable def input : St LSt := P.RestStream.micro0.micro3.s72
noncomputable def output : St LSt := P.RestStream.micro0.micro3.s73
noncomputable def sourceEnv : Env := match classObject.kind with | .fn (.klass _ env _ _) => env | _ => []
noncomputable def sourceMembers : List InstMember := match classObject.kind with | .fn (.klass _ _ _ ms) => ms | _ => []
theorem source_control : input.ctl = .construct (.obj 4855) [.big (Int.ofNat 29372)] (.obj 4855) := by host_kernel_rfl
theorem source_heap : input.heap.get 4855 = some (.obj classObject) := by host_kernel_rfl
theorem source_kind : classObject.kind = .fn (.klass (some Sources.Mlx.Array.ast_n20) sourceEnv .null sourceMembers) := by host_kernel_rfl
theorem source_prototype : findProp kPrototype classObject.props = some (.data (.obj 4854) false false) := by host_kernel_rfl
theorem source_post : baseClassEntry input Sources.Mlx.Array.ast_n20 sourceEnv sourceMembers [.big (Int.ofNat 29372)] 4854 = output := by host_kernel_rfl
theorem source_bound : input.next+2 ≤ 2^64 := by decide +kernel

/-- Actual MlxArray construction derives its mapped class/prototype, allocates
its instance and this-cell, and enters the unchanged source field list. -/
theorem transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' input s)
    (bound : s.next+2 ≤ 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R (BaseClassLive live input.next) framed before after old old' output result := by
  obtain ⟨args,ms,_,_,run,related⟩ := step_base_class_entry_from_source P.F NR FR R C₀ C live framed before after old old' input s h
    4855 4854 classObject Sources.Mlx.Array.ast_n20 sourceEnv sourceMembers [.big (Int.ofNat 29372)] false false
    source_control source_heap source_kind source_prototype source_bound bound
  exact ⟨_,run,source_post ▸ related⟩

/-- The fixed incoming owned handle is retained in the constructor-body frame,
rather than weakened to an existential numeric/bigint meaning. -/
theorem transport_handle (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' input s)
    (control : s.ctl = .construct (.obj (R.a 4855)) [.big (Int.ofNat (R.handle 29372))] (.obj (R.a 4855)))
    (bound : s.next+2 ≤ 2^64) :
    ∃ ms, interpC (step P.F s).run C = some
        (baseClassEntry s Sources.Mlx.Array.ast_n20 (R.env sourceEnv) ms [.big (Int.ofNat (R.handle 29372))] (R.a 4854),C) ∧
      StateR NR FR R (BaseClassLive live input.next) framed before after old old' output
        (baseClassEntry s Sources.Mlx.Array.ast_n20 (R.env sourceEnv) ms [.big (Int.ofNat (R.handle 29372))] (R.a 4854)) := by
  obtain ⟨args,ms,hc,_,run,related⟩ := step_base_class_entry_from_source P.F NR FR R C₀ C live framed before after old old' input s h
    4855 4854 classObject Sources.Mlx.Array.ast_n20 sourceEnv sourceMembers [.big (Int.ofNat 29372)] false false
    source_control source_heap source_kind source_prototype source_bound bound
  have he := congrArg (fun c => match c with | Ctl.construct _ args _ => args | _ => []) (hc.symm.trans control)
  dsimp only at he
  subst args
  exact ⟨ms,run,source_post ▸ related⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat.MlxClass372

import host.ts.renameOrdinary.MlxClassEntry
import host.ts.renameOrdinary.VectorToConcatChecked
import host.ts.RenameRouteDriverStructural
import host.ts.RenameClassHeapEffects
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated
host_transport_structural P.F, P.RestStream.micro0.micro3.s71 to P.RestStream.micro0.micro3.s72 as MlxClassArgument371

def constructorArgument {S : Type} (s : St S) : Val := classBodyArgument s.stack

/-- The returned owned handle flows through the real constructor argument
collector and class entry into the new constructor-body frame. -/
theorem concat_construct_array_framed (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' MlxClassArgument371.input s)
    (handle : s.ctl = .ret (.big (Int.ofNat (R.handle 29372))))
    (bound : s.next+2 ≤ 2^64) :
    ∃ result, runC P.F 2 s C = some (result,C) ∧
      StateR NR FR R (BaseClassLive live MlxClass372.input.next) framed before after old old' MlxClass372.output result ∧
      constructorArgument result = .big (Int.ofNat (R.handle 29372)) ∧
      (∀ m, m < s.next → result.heap.get m = s.heap.get m) := by
  obtain ⟨s372,hr371,h372⟩ := MlxClassArgument371.transport NR FR R C₀ C live framed before after old old' s h
  have hc372 : s372.ctl = .construct (.obj (R.a 4855)) [.big (Int.ofNat (R.handle 29372))] (.obj (R.a 4855)) := by
    obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view MlxClassArgument371.source_frame
    obtain ⟨fn,this,acc,hframe,hfn,_,hacc⟩ := hfr.args_view
    have sourceFn : MlxClassArgument371.sourceFunction = .obj 4855 := by host_kernel_rfl
    have sourceAcc : MlxClassArgument371.sourceAcc = [] := by host_kernel_rfl
    rw [sourceFn] at hfn
    cases hfn
    rw [sourceAcc] at hacc
    cases hacc
    rw [hframe] at hf
    have hr := hr371
    change interpC (step P.F s).run C = some (s372,C) at hr
    rw [step_argument_eq P.F s (.big (Int.ofNat (R.handle 29372))) MlxClassArgument371.sourceKind (.obj (R.a 4855)) this []
      MlxClassArgument371.sourceRest (R.env MlxClassArgument371.sourceEnv) fs handle hf (by decide)] at hr
    have he := congrArg Prod.fst (Option.some.inj hr)
    dsimp only at he
    exact (congrArg St.ctl he).symm
  have bound372 : s372.next+2 ≤ 2^64 := by rw [h.target_next_eq h372 (by host_kernel_rfl)]; exact bound
  obtain ⟨members,hr372,h373⟩ := MlxClass372.transport_handle NR FR R C₀ C live framed before after old old' s372 h372 hc372 bound372
  let result := baseClassEntry s372 Sources.Mlx.Array.ast_n20 (R.env MlxClass372.sourceEnv) members [.big (Int.ofNat (R.handle 29372))] (R.a 4854)
  have run : runC P.F 2 s C = some (result,C) := by
    apply runC_cons P.F 1 s s372 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr371
    apply runC_cons P.F 0 s372 result result C C C (h372.control.isHalt_eq.trans (by host_kernel_rfl)) hr372
    rfl
  have heap372 := step_argument_heap_from_source P.F NR FR R live framed before after old old' _ _ _ C C h
    MlxClassArgument371.sourceValue MlxClassArgument371.sourceKind MlxClassArgument371.sourceFunction
    MlxClassArgument371.sourceThis MlxClassArgument371.sourceAcc MlxClassArgument371.sourceRest MlxClassArgument371.sourceEnv
    MlxClassArgument371.sourceTail MlxClassArgument371.source_control MlxClassArgument371.source_frame (by decide) hr371
  have frame (m : Nat) (below : m < s.next) : result.heap.get m = s.heap.get m := by
    have next372 : s372.next = s.next := h.target_next_eq h372 (by host_kernel_rfl)
    have afterClass := step_base_class_heap_below P.F NR FR R C₀ C C live framed before after old old' _ _ _ h372
      4855 4854 MlxClass372.classObject Sources.Mlx.Array.ast_n20 MlxClass372.sourceEnv MlxClass372.sourceMembers
      [.big (Int.ofNat 29372)] false false MlxClass372.source_control MlxClass372.source_heap MlxClass372.source_kind
      MlxClass372.source_prototype MlxClass372.source_bound bound372 hr372 m (by rw [next372]; exact below)
    exact afterClass.trans (congrArg (fun heap => heap.get m) heap372)
  exact ⟨result,run,h373,rfl,frame⟩

theorem concat_construct_array (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' MlxClassArgument371.input s)
    (handle : s.ctl = .ret (.big (Int.ofNat (R.handle 29372))))
    (bound : s.next+2 ≤ 2^64) :
    ∃ result, runC P.F 2 s C = some (result,C) ∧
      StateR NR FR R (BaseClassLive live MlxClass372.input.next) framed before after old old' MlxClass372.output result ∧
      constructorArgument result = .big (Int.ofNat (R.handle 29372)) := by
  obtain ⟨result,run,related,arg,_⟩ := concat_construct_array_framed NR FR R C₀ C live framed before after old old'
    s h handle bound
  exact ⟨result,run,related,arg⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat

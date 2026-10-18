import host.ts.RenameParametricClassFields
import host.ts.renameOrdinary.MlxClassPath
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro3 73 3126703 as Ordinary.VectorToConcat.MlxFields373.instanceObject
end Host.Load.Run.Full
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.MlxFields373
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
noncomputable def input : St LSt := P.RestStream.micro0.micro3.s73
noncomputable def output : St LSt := P.RestStream.micro0.micro3.s74
noncomputable def sourceEnv : Env := (nThis,3126704)::MlxClass372.sourceEnv
noncomputable def sourceTail : List Frame := input.stack.tail
theorem source_control : input.ctl = .ret .undef := by host_kernel_rfl
theorem source_frame : input.stack = .k (.fields 3126703 MlxClass372.sourceMembers sourceEnv)::sourceTail := by host_kernel_rfl
theorem source_heap : input.heap.get 3126703 = some (.obj instanceObject) := by host_kernel_rfl
theorem source_kind : instanceObject.kind = .ordinary := by host_kernel_rfl
theorem source_private : PrivateFields MlxClass372.sourceMembers := by repeat constructor
theorem source_bound : input.next ≤ 2^64 := by decide +kernel
theorem source_run (C : CSrv) : interpC (step P.F input).run C = some (output,C) := by host_kernel_rfl

/-- The actual initial field step writes the uninitialized private handle and
enters #disposed's source initializer. The constructor argument is retained
under the new field frame, with no target write/initializer/run premise. -/
theorem transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' input s)
    (bound : s.next ≤ 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old' output result ∧
      constructorArgument result = constructorArgument s := by
  obtain ⟨r₀,r,hr₀,hr,hs,_,harg⟩ := step_class_fields_from_source P.F NR FR R C₀ C live framed before after old old' input s h
    .undef 3126703 instanceObject MlxClass372.sourceMembers sourceEnv sourceTail source_control source_frame source_private source_heap source_kind source_bound bound
  rw [source_run] at hr₀
  have he := congrArg Prod.fst (Option.some.inj hr₀)
  dsimp only at he
  subst r₀
  exact ⟨r,hr,hs,harg⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat.MlxFields373

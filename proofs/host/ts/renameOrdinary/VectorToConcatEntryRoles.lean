import host.ts.renameOrdinary.VectorToConcatCallbackPrefix
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
noncomputable def outerFrame (i : Nat) : Frame := nthD (.s .ret) PointerReturn310.input.stack i
noncomputable def outerCollector : CallF := match outerFrame 4 with | .c c => c | _ => .callee [] [] false
noncomputable def outerKind : Nat := match outerCollector with | .args k _ _ _ _ _ => k | _ => 0
noncomputable def outerFunction : Val := match outerCollector with | .args _ f _ _ _ _ => f | _ => .undef
noncomputable def outerThis : Val := match outerCollector with | .args _ _ t _ _ _ => t | _ => .undef
noncomputable def outerAcc : List Val := match outerCollector with | .args _ _ _ a _ _ => a | _ => []
noncomputable def outerRest : List Elem := match outerCollector with | .args _ _ _ _ a _ => a | _ => []
noncomputable def outerEnv : Env := match outerCollector with | .args _ _ _ _ _ e => e | _ => []
noncomputable def outerTail : List Frame := PointerReturn310.input.stack.drop 5
theorem outer_source_stack : PointerReturn310.input.stack = outerFrame 0::outerFrame 1::outerFrame 2::outerFrame 3::
    .c (.args outerKind outerFunction outerThis outerAcc outerRest outerEnv)::outerTail := by host_kernel_rfl
theorem outer_vector_lookup : lookupEnv VectorVariable330.sourceName outerEnv = some VectorVariable330.address := by host_kernel_rfl
theorem outer_axis_lookup : lookupEnv AxisVariable332.sourceName outerEnv = some AxisVariable332.address := by host_kernel_rfl
theorem outer_stream_lookup : lookupEnv StreamVariable334.sourceName outerEnv = some StreamVariable334.address := by host_kernel_rfl
theorem entry_pointer_control : PointerReturn310.input.ctl = .ret (.ptr (.js 3126700) 0) := by host_kernel_rfl
theorem vector_not_pointer_cell : VectorVariable330.address ≠ PointerBinding311.sourceAddress := by decide +kernel
theorem axis_not_pointer_cell : AxisVariable332.address ≠ PointerBinding311.sourceAddress := by decide +kernel
theorem stream_not_pointer_cell : StreamVariable334.address ≠ PointerBinding311.sourceAddress := by decide +kernel
theorem slot_not_pointer_cell : 3126700 ≠ PointerBinding311.sourceAddress := by decide +kernel

/-- The real suspended outer constructor frame keeps vector/axis/stream
cells live while outArray and its callback execute. The pointer control
itself keeps the backing output buffer live. -/
theorem concat_entry_support (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St LSt) (h : StateR NR FR R live framed before after old old' PointerReturn310.input s) :
    live VectorVariable330.address ∧ live AxisVariable332.address ∧ live StreamVariable334.address ∧ live 3126700 := by
  have hl := h.stackLive
  rw [outer_source_stack] at hl
  have he : treeSupport live (Encode.env outerEnv) := hl.2.2.2.2.1.1.2.2.2.2.2.1
  have hc := h.controlLive
  rw [entry_pointer_control] at hc
  exact ⟨env_lookup_live _ _ _ he outer_vector_lookup,env_lookup_live _ _ _ he outer_axis_lookup,
    env_lookup_live _ _ _ he outer_stream_lookup,hc.1⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat

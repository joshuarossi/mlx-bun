import host.ts.renameOrdinary.VectorToConcatVectorOrigin
import host.ts.renameOrdinary.VectorToConcatArguments
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
theorem vector_entry_stack : VectorCall.input.stack = .s (.decl VectorDeclaration250.sourceKind VectorDeclaration250.sourcePattern
    VectorDeclaration250.sourceRest VectorDeclaration250.sourceEnv)::VectorDeclaration250.sourceTail := by host_kernel_rfl
theorem vector_entry_vector_lookup : lookupEnv VectorVariable330.sourceName VectorDeclaration250.sourceEnv = some VectorVariable330.address := by host_kernel_rfl
theorem vector_entry_axis_lookup : lookupEnv AxisVariable332.sourceName VectorDeclaration250.sourceEnv = some AxisVariable332.address := by host_kernel_rfl
theorem vector_entry_stream_lookup : lookupEnv StreamVariable334.sourceName VectorDeclaration250.sourceEnv = some StreamVariable334.address := by host_kernel_rfl
theorem vector_entry_global_object : VectorCall.input.heap.get aGlobal = some (.obj SlotGlobal288.sourceObject) := by host_kernel_rfl
theorem vector_entry_constructor : SlotGlobal288.sourceValue = .obj 95 := by host_kernel_rfl
theorem vector_cell_address : VectorBinding251.sourceAddress = VectorVariable330.address := by host_kernel_rfl
theorem axis_not_vector_cell : AxisVariable332.address ≠ VectorBinding251.sourceAddress := by decide +kernel
theorem stream_not_vector_cell : StreamVariable334.address ≠ VectorBinding251.sourceAddress := by decide +kernel
theorem constructor_not_vector_cell : 95 ≠ VectorBinding251.sourceAddress := by decide +kernel

/-- The actual caller environment owns the surviving scalar/handle cells;
the real global descriptor keeps the typed-array constructor live. -/
theorem vector_prelude_support (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St LSt) (h : StateR NR FR R live framed before after old old' VectorCall.input s)
    (globalLive : live aGlobal) :
    live VectorVariable330.address ∧ live AxisVariable332.address ∧ live StreamVariable334.address ∧ live 95 := by
  have hl := h.stackLive
  rw [vector_entry_stack] at hl
  have envLive : treeSupport live (Encode.env VectorDeclaration250.sourceEnv) := hl.1.1.2.2.2.1
  obtain ⟨_,_,_,support⟩ := h.heap.readOrdinary aGlobal SlotGlobal288.sourceObject globalLive vector_entry_global_object SlotGlobal288.source_kind
  have constructor := (PropsR.support_find support.2.2.1 SlotGlobal288.sourceName SlotGlobal288.source_property).1
  rw [vector_entry_constructor] at constructor
  exact ⟨env_lookup_live _ _ _ envLive vector_entry_vector_lookup,env_lookup_live _ _ _ envLive vector_entry_axis_lookup,
    env_lookup_live _ _ _ envLive vector_entry_stream_lookup,constructor⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat

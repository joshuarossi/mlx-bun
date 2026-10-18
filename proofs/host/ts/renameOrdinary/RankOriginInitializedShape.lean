import host.ts.renameOrdinary.RankOriginInitialRetained
import host.ts.renameOrdinary.RankOriginNativeSeed

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedShape
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

noncomputable def nativeFrame (ρ : Nat → F64) (C : CSrv)
    (R : Ren) (source target : LSt) : Prop :=
  Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ρ ρ C C) R
    (Host.Mlx.Ffi.Annotated.NodeRel NativeSeed.roles ρ ρ C C R NativeSeed.boundary)
    NativeSeed.objectRelation NativeSeed.handles NativeSeed.nodes [] source.mlx target.mlx

theorem initial_state (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.micro3275.S1.tab.map (SymE.eval ρ)) :
    Parametric.StateR (NumberRoles ρ ρ C C) (nativeFrame ρ C) identity
      InitialRetained.live (fun _ => False) [] [] input.trace input.trace input input := by
  have h := InitialClosure.identity_table ρ C table
  exact ⟨h.heap,h.control,h.controlLive,h.stack,h.stackLive,h.jobs,h.jobsLive,
    h.stores,h.storesLive,NativeSeed.initial_live ρ C table,h.trace⟩

theorem source_private_object : input.heap.get Handle40.sourceAddress = some (.obj Handle40.sourceObject) := by
  host_kernel_rfl

theorem source_private_property : Handle40.sourceProperty = .data (.big (Int.ofNat 29363)) true false := by
  host_kernel_rfl

theorem initial_private_handle : PrivateData input Handle40.sourceAddress Handle40.sourceBrand
    Handle40.sourceName (.big (Int.ofNat 29363)) := by
  exact ⟨Handle40.sourceObject,true,false,source_private_object,
    Handle40.source_property.trans (congrArg some source_private_property)⟩

theorem initial_argument (ρ : Nat → F64) (C : CSrv) :
    (Annotated.Value.handle 29363).Holds ρ C identity (callArgument input.ctl 0) := by
  simpa only [source_control,callArgument,Host.Ts.arg,nthD,nth?,
    Host.Mlx.Ffi.Annotated.Initial.identity_handle] using
    (Annotated.Value.Holds.handle (ν:=ρ) (C:=C) (R:=identity) 29363)

theorem allocation_bound : input.next + 5 + (paramNames EnterGetter28.sourceFunction).length ≤ 2^64 := by
  rw [InitialClosure.source_address_limit]
  decide +kernel

theorem initial_global : InitialRetained.live aGlobal := by
  rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel
theorem initial_array_buffer : InitialRetained.live aArrayBufferProto := by
  rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel
theorem initial_typed : InitialRetained.live 21 := by
  rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel
theorem initial_array : InitialRetained.live aArrayProto := by
  rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel

/-- The actual boot-reached rank entry executes the complete 72-step shape
prefix with initialized runtime, capture, array, public and buffer inventories.
The native relation is retained in the resulting state. No initial relation,
inventory, fixed capture or future operand is a caller premise. -/
theorem enter_and_shape (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.micro3275.S1.tab.map (SymE.eval ρ)) :
    ∃ (initialControl : Annotated.Tree) (initialStack : List Annotated.Tree)
        (result : St LSt) (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree),
      runC P.F 72 input C = some (result,C) ∧
      Parametric.StateR (NumberRoles ρ ρ C C) (nativeFrame ρ C) identity
        (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live)) (fun _ => False)
        [] [] input.trace input.trace P.RestStream.micro0.micro0.s14 result ∧
      RetainedInventory (RetainedShapePrefix.EndNotes
        (RankShapeRetained.EntryNotes (InitialRetained.notes initialControl initialStack)
          control fnRole thisRole saved caller) caller (NativeSeed.roles 22582).shape.valueRoles)
        ρ ρ C C identity (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live))
        P.RestStream.micro0.micro0.s14 result ∧
      Inst ρ (numberServer P.RestStream.micro0.micro0.S14) C := by
  obtain ⟨initialControl,initialStack,inventory⟩ := InitialRetained.initial_inventory ρ C table
  have inst : Inst ρ (numberServer P.micro3275.S1) C :=
    ⟨table,fun _ impossible => by cases impossible⟩
  obtain ⟨result,control,fnRole,thisRole,saved,caller,run,related,retained,inst14⟩ :=
    RankShapeRetained.enter_and_shape (nativeFrame ρ C) identity ρ ρ C C
      InitialRetained.live (fun _ => False) [] [] input.trace input.trace input
      (initial_state ρ C table) inst (InitialRetained.notes initialControl initialStack) inventory
      InitialRetained.rank_absent InitialRetained.pointer_absent
      InitialRetained.constructorMetadata InitialRetained.constructor_selected
      InitialRetained.constructor_code InitialRetained.constructor_proto
      NativeSeed.roles NativeSeed.objectRelation NativeSeed.boundary NativeSeed.handles NativeSeed.nodes []
      (NativeSeed.initial_live ρ C table) (fun impossible => impossible) (fun impossible => impossible)
      NativeSeed.handle_live (initial_argument ρ C) initial_private_handle
      (by rw [Host.Mlx.Ffi.Annotated.Initial.identity_handle]; rfl)
      allocation_bound initial_global rfl initial_array_buffer rfl initial_typed rfl initial_array rfl
  exact ⟨initialControl,initialStack,result,control,fnRole,thisRole,saved,caller,run,related,retained,inst14⟩

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedShape

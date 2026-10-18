import host.ts.renameOrdinary.RankOriginInitializedCacheContext
import host.ts.renameOrdinary.RankOriginCacheOffsetRetag

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCache
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open CacheEntry

noncomputable def entryRoles : Nat → GraphNode :=
  cacheRoles LoopVariables.capacity (fun i => (ObjectSeed.roles i).subst LoopVariables.oracleVariables)
noncomputable def entryObjects : Nat → Object :=
  fun i => (ObjectSeed.objects i).subst LoopVariables.oracleVariables
noncomputable def entryNotes (ic : Annotated.Tree) (is : List Annotated.Tree) : RetainedNotes :=
  seededNotes LoopVariables.cacheIndex ((InitialRetained.notes ic is).subst LoopVariables.oracleVariables)

theorem entry_offset_selected (ic : Annotated.Tree) (is : List Annotated.Tree) (owner : Nat)
    (selected : owner ∈ cacheOwners) :
    (entryNotes ic is).publicFields.fields owner chars!"offset" =
      some (.literal (offsetMeaning LoopVariables.cacheIndex owner)) :=
  seed_offset_selected LoopVariables.cacheIndex _ owner selected

theorem entry_role_selected (producer : Nat) (selected : producer ∈ producers) :
    entryRoles producer = capacityRole LoopVariables.capacity := ite_eq_left selected

theorem entry_role_other (producer : Nat) (other : producer ∉ producers) :
    entryRoles producer = (ObjectSeed.roles producer).subst LoopVariables.oracleVariables :=
  cache_roles_other LoopVariables.capacity _ producer other

/-- Offset notes are seeded at the actual reached rank-entry heap, after all
cache objects and literal fields already exist. All 64 phase offsets and the
32 capacity roles come from checked source metadata. Oracle meanings and the
existing six-family inventory are embedded before adding independent loop
meanings; the theorem imposes no future-answer constraint. -/
theorem initialized_entry (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC Host.Load.ffi 32741797 start C) = some (input,C') ∧
      Parametric.StateR
        (NumberRoles (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C')
        (StateNativeRelation LSt.mlx (fun _ _ _ => True)
          (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C'
          entryRoles entryObjects NativeSeed.boundary NativeSeed.handles NativeSeed.nodes [])
        identity InitialRetained.live (fun _ => False) [] [] input.trace input.trace input input ∧
      RetainedInventory (entryNotes ic is)
        (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C'
        identity InitialRetained.live input input ∧
      ProducerAnnotations ObjectSeed.roots NativeSeed.handles NativeSeed.nodes entryRoles entryObjects ∧
      ProducerSupport ObjectSeed.roots NativeSeed.handles NativeSeed.nodes input.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (loop limit))
        ((numberServer P.micro3275.S1).substitute LoopVariables.oracleVariables) C' := by
  obtain ⟨C',run,tab,_,_⟩ := InitialClosure.source_initialization ρ C table answers
  have state := InitializedShape.initial_state ρ C' tab
  have current : Parametric.StateR (NumberRoles ρ ρ C' C')
      (StateNativeRelation LSt.mlx (fun _ _ _ => True) ρ ρ C' C'
        ObjectSeed.roles ObjectSeed.objects NativeSeed.boundary NativeSeed.handles NativeSeed.nodes [])
      identity InitialRetained.live (fun _ => False) [] [] input.trace input.trace input input :=
    {state with native := ⟨ObjectSeed.annotate_live ρ C' input.ffi input.ffi state.native rfl,True.intro⟩}
  obtain ⟨ic,is,inventory⟩ := InitialRetained.initial_inventory ρ C' tab
  have inst : Inst ρ (numberServer P.micro3275.S1) C' := ⟨tab,by intro query impossible; cases impossible⟩
  obtain ⟨embedded,retained,embeddedPolicy,_,_,embeddedInst⟩ :=
    embed_context (loop limit) (loop limit) current inventory ObjectSeed.producer_policy inst
  have selected := selected_roles_substitute LoopVariables.oracleVariables ObjectSeed.roles selected_roles
  obtain ⟨annotated,retained,annotatedPolicy,sourceSupport,_⟩ :=
    annotate_context LoopVariables.capacity selected embedded retained embeddedPolicy
      (capacity_meaning ρ limit) (capacity_meaning ρ limit)
  have seeded := seed_retained LoopVariables.cacheIndex retained (time_meaning ρ limit) (time_meaning ρ limit)
  exact ⟨C',ic,is,run,annotated,seeded,annotatedPolicy,sourceSupport,embeddedInst⟩

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCache

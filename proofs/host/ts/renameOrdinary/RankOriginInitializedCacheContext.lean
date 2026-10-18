import host.ts.renameOrdinary.RankOriginInitializedVector
import host.ts.renameOrdinary.RankOriginCacheContext

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCache
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedVectorEntryBatch CacheEntry

noncomputable def vectorNotes (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
    (saved : Annotated.Tree) (caller : List Annotated.Tree) : RetainedNotes :=
  let prior := endNotes (RankShapeRetained.EntryNotes (InitialRetained.notes ic is)
    control fnRole thisRole saved caller) caller
  prior.withRuntime ⟨returnNote (.handle Vector249.input.ffi.mlx.next),prior.runtime.stack,prior.runtime.cells⟩

def loop (limit : Nat) : Nat → F64 := loopValuation 1 1 limit 256
noncomputable def roles : Nat → GraphNode :=
  cacheRoles LoopVariables.capacity (fun i => (ObjectSeed.roles i).subst LoopVariables.oracleVariables)
noncomputable def objects : Nat → Object :=
  fun i => (InitializedVector.finalObjects i).subst LoopVariables.oracleVariables

theorem selected_roles (producer : Nat) (selected : producer ∈ producers) :
    ObjectSeed.roles producer = literalCapacityRole := by
  rw [ObjectSeed.roles_live producer (producers_bounded producer selected)]
  exact initial_role_selected producer selected

theorem time_meaning (ρ : Nat → F64) (limit : Nat) :
    LoopVariables.cacheIndex.eval (LoopVariables.valuation ρ (loop limit)) = F64.ofNat 3 :=
  LoopVariables.cache_index_eval ρ 1 1 limit 256 (by decide +kernel)

theorem capacity_meaning (ρ : Nat → F64) (limit : Nat) :
    LoopVariables.capacity.eval (LoopVariables.valuation ρ (loop limit)) = F64.ofInt 256 :=
  LoopVariables.capacity_eval ρ 1 1 limit 256

/-- Install the disjoint oracle/loop namespace and symbolic capacity meanings
at the actually reached vector cut. The boot run, every retained note and
all indexed native objects survive; only the checked cache-node roles gain
the independent capacity expression. No future token value is constrained. -/
theorem initialized_context (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742105 start C) = some (result,C') ∧
      Parametric.StateR
        (NumberRoles (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C')
        (StateNativeRelation LSt.mlx (fun _ a b => InitializedVector.hostRelation a.host b.host)
          (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C'
          roles objects NativeSeed.boundary InitializedVector.finalHandles NativeSeed.nodes [])
        identity InitializedVector.finalLive (fun _ => False) [] [] input.trace input.trace
        P.RestStream.micro0.micro2.s50 result ∧
      RetainedInventory ((vectorNotes ic is control fnRole thisRole saved caller).subst LoopVariables.oracleVariables)
        (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C'
        identity InitializedVector.finalLive P.RestStream.micro0.micro2.s50 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedVector.finalHandles NativeSeed.nodes roles objects ∧
      ProducerSupport ObjectSeed.roots InitializedVector.finalHandles NativeSeed.nodes P.RestStream.micro0.micro2.s50.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (loop limit))
        ((numberServer P.RestStream.micro0.micro2.S50).substitute LoopVariables.oracleVariables) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,run,state,inventory,policy,support,inst⟩ :=
    InitializedVector.initialized_vector ρ C table answers
  have current : Parametric.StateR (NumberRoles ρ ρ C' C')
      (StateNativeRelation LSt.mlx (fun _ a b => InitializedVector.hostRelation a.host b.host)
        ρ ρ C' C' ObjectSeed.roles InitializedVector.finalObjects NativeSeed.boundary
        InitializedVector.finalHandles NativeSeed.nodes [])
      identity InitializedVector.finalLive (fun _ => False) [] [] input.trace input.trace
      P.RestStream.micro0.micro2.s50 result := {state with native := ⟨state.native.2,state.native.1⟩}
  change RetainedInventory (vectorNotes ic is control fnRole thisRole saved caller)
    ρ ρ C' C' identity InitializedVector.finalLive P.RestStream.micro0.micro2.s50 result at inventory
  obtain ⟨embedded,retained,embeddedPolicy,_,_,embeddedInst⟩ :=
    embed_context (loop limit) (loop limit) current inventory policy inst
  have selected := selected_roles_substitute LoopVariables.oracleVariables ObjectSeed.roles selected_roles
  obtain ⟨annotated,retained,annotatedPolicy,sourceSupport,_⟩ :=
    annotate_context LoopVariables.capacity selected embedded retained embeddedPolicy
      (capacity_meaning ρ limit) (capacity_meaning ρ limit)
  exact ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,run,annotated,retained,annotatedPolicy,sourceSupport,embeddedInst⟩

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCache

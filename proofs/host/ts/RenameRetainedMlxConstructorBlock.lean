import host.ts.RenameMlxConstructorFrame
import host.ts.RenameRetainedMlxRegisterBlock
import host.ts.RenameRetainedConstructorCompletionBlock

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 10000000
namespace Host.Ts.Owned.Annotated.MlxConstruction
open Parametric

def constructorOutput {S : Type} (source : St S) (env : Env) (proto brand : Nat) (argument : Val) : St S :=
  {handleOutput source env proto brand argument with ctl := .ret (.obj source.next),stack := source.stack}
def constructorNotes {S : Type} (notes : RetainedNotes) (source : St S) (env : Env) (proto brand : Nat)
    (argument : Val) (role : Value) : RetainedNotes :=
  let current := handleNotes notes source env proto brand argument role
  current.withRuntime ⟨returnNote (.obj source.next),notes.runtime.stack,current.runtime.cells⟩

/-- The complete original MLXArray constructor, including private fields,
argument binding, handle assignment, inherited registry call and normal return.
All entry data describes the current source class/captures. Fresh instance,
private handle meaning and the caller's inventories are derived by execution. -/
theorem construct_block {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (address proto brand registryCell registry callee : Nat) (object calleeObject : Obj)
    (env : Env) (argument : Val) (fnRole argRole : Value) (data : List Val) (w e rw re : Bool)
    (control : source.ctl = .construct (.obj address) [argument] (.obj address))
    (read : source.heap.get address = some (.obj object))
    (kind : object.kind = .fn (.klass (some constructorFunction) env .null (members brand)))
    (prototype : findProp kPrototype object.props = some (.data (.obj proto) w e))
    (handleBrand : lookupEnv (privName chars!"handle") env = some brand)
    (tokenBrand : lookupEnv (privName chars!"token") env = some brand)
    (registryLookup : lookupEnv chars!"registry" env = some registryCell)
    (registryRead : source.heap.get registryCell = some (.cell (some (.obj registry))))
    (registryPath : OrdinaryLookup source chars!"register" 16 registry (some (.data (.obj callee) rw re)))
    (calleeRead : source.heap.get callee = some (.obj calleeObject))
    (calleeKind : calleeObject.kind = .fn (.native (.fn .finRegister) data))
    (controlNote : notes.runtime.control = constructNote fnRole [argRole])
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (sourceBound : source.next+6 ≤ 2^64) (targetBound : target.next+6 ≤ 2^64) :
    ∃ result,
      runC F 37 source C₀ = some (constructorOutput source env proto brand argument,C₀) ∧
      runC F 37 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (ParametersLive live source.next) framed before after old old'
        (constructorOutput source env proto brand argument) result ∧
      RetainedInventory (constructorNotes notes source env proto brand argument argRole) ν₀ ν C₀ C R
        (ParametersLive live source.next) (constructorOutput source env proto brand argument) result := by
  have support := h.controlLive
  rw [control] at support
  have addressAlive : live address := support.1
  obtain ⟨_,_,_,objectSupport⟩ := h.heap.readObject address object addressAlive
    (h.heap.function_notFramed address object _ addressAlive read kind) read
  have environmentLive : treeSupport live (Encode.env env) := by
    have support := objectSupport.1
    rw [kind] at support
    exact support.1.2.1
  have registryCellAlive := env_lookup_live chars!"registry" env registryCell environmentLive registryLookup
  have registryAlive := (h.heap.readCell registryCell (.obj registry) registryCellAlive registryRead).choose_spec.2.2
  obtain ⟨_,_,_,_,propertyLive⟩ := registryPath.transport F h.heap chars!"register" registryAlive
  have calleeAlive : live callee := (propertyLive _ rfl).1
  obtain ⟨s19,left19,right19,h19,inv19⟩ := class_handle inventory h address proto brand object env argument fnRole argRole w e
    control read kind prototype handleBrand controlNote objectLive objectFixed sourceBound targetBound
  host_normalize_retained h19, inv19
  have oldHeap : ∀ a, live a → (handleOutput source env proto brand argument).heap.get a = source.heap.get a := by
    intro a alive
    exact handle_old F source env proto brand argument sourceBound a (h.heap.sourceBound a alive)
  obtain ⟨s34,left15,right15,h34,inv34,_,_,_⟩ := register_block inv19 h19
    (parameterEnvironment source env proto brand argument) (.s (.scope [])::.k (.fn (.ctor (.obj source.next)))::source.stack)
    (blockFrameNote [.expr registerExpression] (parameterEnvironment source env proto brand argument))
    (emptyScopeNote::constructorBoundaryNote (.obj source.next)::notes.runtime.stack) argument
    registryCell registry callee (source.next+3) (source.next+4) source.next brand (source.next+2)
    (storedInstance proto brand (source.next+2) argument) calleeObject argument argRole data rw re true false rfl rfl rfl
    (by rw [parameter_lookup_other source env proto brand argument chars!"registry" (by decide +kernel) (by decide +kernel)]; exact registryLookup)
    (parameter_lookup_this source env proto brand argument) (parameter_lookup_handle source env proto brand argument)
    (by rw [parameter_lookup_other source env proto brand argument (privName chars!"token") (by decide +kernel) (by decide +kernel)]; exact tokenBrand)
    ((oldHeap registryCell registryCellAlive).trans registryRead)
    (handle_this F source env proto brand argument sourceBound) (handle_parameter source env proto brand argument sourceBound)
    (handle_instance source env proto brand argument sourceBound) rfl (stored_token proto brand (source.next+2) argument)
    (registryPath.frame_live (reached:=handleOutput source env proto brand argument) h.heap oldHeap registryAlive)
    ((oldHeap callee calleeAlive).trans calleeRead) calleeKind
    (handle_this_note notes source env proto brand argument argRole) (handle_parameter_note notes source env proto brand argument argRole)
  host_normalize_retained h34, inv34
  obtain ⟨result,left3,right3,h37,inv37,_,_,_⟩ := inv34.constructor_completion_block h34
    (parameterEnvironment source env proto brand argument) (.obj source.next) (.obj source.next)
    source.stack notes.runtime.stack rfl rfl rfl rfl
  exact ⟨result,runC_join F (m:=34) (n:=3) (runC_join F (m:=19) (n:=15) left19 left15) left3,
    runC_join F (m:=34) (n:=3) (runC_join F (m:=19) (n:=15) right19 right15) right3,h37,inv37⟩

end Host.Ts.Owned.Annotated.MlxConstruction

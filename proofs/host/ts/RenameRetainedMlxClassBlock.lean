import host.ts.RenameRetainedMlxFieldsBlock
import host.ts.RenameRetainedMlxParameterBlock
import host.ts.RenameRetainedClassEntry
import host.ts.RenameRetainedConstructorBody
import host.ts.RenameResourceFields

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Ts.Owned.Annotated.MlxConstruction
open Parametric

def freshInstance (proto : Nat) : Obj := ⟨.ordinary,.obj proto,[],[],true⟩
def fieldEnvironment {S : Type} (source : St S) (env : Env) : Env := (nThis,source.next+1)::env
def fieldFrames {S : Type} (source : St S) (env : Env) (argument : Val) : List Frame :=
  .k (.ctorBody (.obj source.next) constructorFunction env [argument])::source.stack
def classStart {S : Type} (source : St S) (env : Env) (proto brand : Nat) (argument : Val) : St S :=
  baseClassEntry source constructorFunction env (members brand) [argument] proto
def classFieldsOutput {S : Type} (source : St S) (env : Env) (proto brand : Nat) (argument : Val) : St S :=
  let s0 := classStart source env proto brand argument
  let s1 := fields1 s0 source.next brand (freshInstance proto) (fieldEnvironment source env) (fieldFrames source env argument)
  let s3 := fields3 s1 source.next brand (freshInstance proto) (fieldEnvironment source env) (fieldFrames source env argument)
  let s4 := fields4 s3
  let s5 := fields5 s4 source.next brand (source.next+2) (freshInstance proto) (fieldEnvironment source env) (fieldFrames source env argument)
  fields7 s5 source.next brand (source.next+2) (freshInstance proto) (fieldEnvironment source env) (fieldFrames source env argument)
def classFieldsNotes (notes : RetainedNotes) (env : Env) (base brand : Nat) (role : Value) : RetainedNotes :=
  let n0 := notes.withRuntime (notes.runtime.baseClass constructorFunction env (members brand) [role] base)
  let tail := constructorBodyFrameNote (.obj base) constructorFunction env [role]::notes.runtime.stack
  let fieldEnv := (nThis,base+1)::env
  let n1 := fieldNotes1 n0 base brand fieldEnv tail
  let n3 := fieldNotes3 (n1.withRuntime (n1.runtime.returning (.bool false))) base brand fieldEnv tail
  let n5 := fieldNotes5 (n3.withRuntime {n3.runtime with control := returnNote (.obj (base+2))}) base brand (base+2) fieldEnv tail
  fieldNotes7 (n5.withRuntime (n5.runtime.returning (.literal (.lit (F64.ofNat 0))))) base brand fieldEnv tail
def FieldsLive (live : Nat → Prop) (base : Nat) : Nat → Prop := LiveAfter (BaseClassLive live base) (base+2)

theorem members_private (brand : Nat) : PrivateFields (members brand) :=
  .cons _ _ _ (.cons _ _ _ (.cons _ _ _ (.cons _ _ _ .nil)))

/-- The original base-class entry and all seven private initializers form an
eight-step block over arbitrary fresh counters and caller stacks. The receiver,
its this-cell, and token object are allocated by the actual source operations. -/
theorem class_fields {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (address proto brand : Nat) (object : Obj) (env : Env) (argument : Val)
    (fnRole argRole : Value) (w e : Bool)
    (control : source.ctl = .construct (.obj address) [argument] (.obj address))
    (read : source.heap.get address = some (.obj object))
    (kind : object.kind = .fn (.klass (some constructorFunction) env .null (members brand)))
    (prototype : findProp kPrototype object.props = some (.data (.obj proto) w e))
    (controlNote : notes.runtime.control = constructNote fnRole [argRole])
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (sourceBound : source.next+6 ≤ 2^64) (targetBound : target.next+6 ≤ 2^64) :
    ∃ result,
      runC F 8 source C₀ = some (classFieldsOutput source env proto brand argument,C₀) ∧
      runC F 8 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (FieldsLive live source.next) framed before after old old'
        (classFieldsOutput source env proto brand argument) result ∧
      RetainedInventory (classFieldsNotes notes env source.next brand argRole) ν₀ ν C₀ C R (FieldsLive live source.next)
        (classFieldsOutput source env proto brand argument) result := by
  obtain ⟨_,_,left1,right1,h1,inv1⟩ := inventory.base_class_step F FR notes ν₀ ν C₀ C R live framed before after old old'
    source target h address proto object constructorFunction env (members brand) [argument] w e fnRole [argRole]
    control read kind prototype (members_private brand) controlNote (by omega) (by omega)
  have objectRead : (classStart source env proto brand argument).heap.get source.next = some (.obj (freshInstance proto)) := by
    change ((source.heap.set source.next (.obj (freshInstance proto))).set (source.next+1) (.cell (some (.obj source.next)))).get source.next = _
    rw [PTrie.get_set_u64 _ _ _ (show source.next+1 < 2^64 by omega),ite_eq_right (show source.next ≠ source.next+1 by omega),
      PTrie.get_set_u64 _ _ _ (show source.next < 2^64 by omega),ite_eq_left rfl]
  obtain ⟨result,left7,right7,h7,inv7⟩ := initialize_fields inv1 h1 source.next brand (freshInstance proto)
    (fieldEnvironment source env) (fieldFrames source env argument)
    (classFieldsFrameNote source.next (members brand) (fieldEnvironment source env))
    (constructorBodyFrameNote (.obj source.next) constructorFunction env [argRole]::notes.runtime.stack)
    rfl rfl objectRead rfl rfl (Or.inl (Or.inl objectLive)) objectFixed
    (by change source.next+2+1 ≤ 2^64; omega) (by change target.next+2+1 ≤ 2^64; omega)
  have source1 := runC_cons F 0 source _ _ C₀ C₀ C₀ (by rw [control]; rfl) left1 rfl
  have target1 := runC_cons F 0 target _ _ C C C (h.control.isHalt_eq.trans (by rw [control]; rfl)) right1 rfl
  exact ⟨result,runC_join F (m:=1) (n:=7) source1 left7,runC_join F (m:=1) (n:=7) target1 right7,h7,inv7⟩

def parametersOutput {S : Type} (source : St S) (env : Env) (proto brand : Nat) (argument : Val) : St S :=
  closureState {classFieldsOutput source env proto brand argument with stack := source.stack}
    constructorFunction env false .undef (.obj source.next) [argument] (.ctor (.obj source.next))
def parameterEnvironment {S : Type} (source : St S) (env : Env) (proto brand : Nat) (argument : Val) : Env :=
  closureEnvironment {classFieldsOutput source env proto brand argument with stack := source.stack}
    constructorFunction env false .undef (.obj source.next)
def parametersNotes {S : Type} (notes : RetainedNotes) (source : St S) (env : Env)
    (proto brand : Nat) (argument : Val) (role : Value) : RetainedNotes :=
  let prior := classFieldsNotes notes env source.next brand role
  prior.withRuntime (prior.runtime.constructorBody constructorFunction [role]
    (parameterEnvironment source env proto brand argument) (source.next+3) (.obj source.next) notes.runtime.stack)
def ParametersLive (live : Nat → Prop) (base : Nat) : Nat → Prop :=
  ConstructorBodyLive (FieldsLive live base) (base+3) constructorFunction

/-- The allocated receiver and unchanged incoming argument enter the original
constructor body. Its receiver/parameter cells are allocated here, so later
binding rules need no future-cell interpretation premise. -/
theorem class_parameters {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (address proto brand : Nat) (object : Obj) (env : Env) (argument : Val)
    (fnRole argRole : Value) (w e : Bool)
    (control : source.ctl = .construct (.obj address) [argument] (.obj address))
    (read : source.heap.get address = some (.obj object))
    (kind : object.kind = .fn (.klass (some constructorFunction) env .null (members brand)))
    (prototype : findProp kPrototype object.props = some (.data (.obj proto) w e))
    (controlNote : notes.runtime.control = constructNote fnRole [argRole])
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (sourceBound : source.next+6 ≤ 2^64) (targetBound : target.next+6 ≤ 2^64) :
    ∃ result,
      runC F 9 source C₀ = some (parametersOutput source env proto brand argument,C₀) ∧
      runC F 9 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (ParametersLive live source.next) framed before after old old'
        (parametersOutput source env proto brand argument) result ∧
      RetainedInventory (parametersNotes notes source env proto brand argument argRole) ν₀ ν C₀ C R (ParametersLive live source.next)
        (parametersOutput source env proto brand argument) result := by
  obtain ⟨s8,left8,right8,h8,inv8⟩ := class_fields inventory h address proto brand object env argument fnRole argRole w e
    control read kind prototype controlNote objectLive objectFixed sourceBound targetBound
  have counter : s8.next = target.next+3 := h.heap.target_next_add h8.heap 3 rfl
  obtain ⟨_,_,_,left9,right9,h9,inv9⟩ := inv8.constructor_body_step F FR _ ν₀ ν C₀ C R _ framed
    before after old old' _ _ h8 .undef (.obj source.next) constructorFunction env [argument] source.stack (.obj source.next)
    [argRole] notes.runtime.stack rfl rfl rfl
    (by change source.next+3+3 ≤ 2^64; omega)
    (by change s8.next+3 ≤ 2^64; rw [counter]; omega)
  have l9 := runC_cons F 0 _ _ _ C₀ C₀ C₀ rfl left9 rfl
  have r9 := runC_cons F 0 _ _ _ C C C (h8.control.isHalt_eq.trans rfl) right9 rfl
  exact ⟨_,runC_join F (m:=8) (n:=1) left8 l9,runC_join F (m:=8) (n:=1) right8 r9,h9,inv9⟩

end Host.Ts.Owned.Annotated.MlxConstruction

import host.ts.RenameMapperLookupFrame
import host.ts.RenameRetainedGetterCall
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Owned.Annotated
open Parametric

def mapperGetterInput {S : Type} (s : St S) (env : Env) (name field : Name)
    (receiver : Val) (owner : Nat) (extraArgs : List Val) (getter : Nat) : St S :=
  {mapperEntrySource s env name field receiver owner extraArgs with ctl := .call (.obj getter) (.obj owner) []}

def mapperCallResult {S : Type} (s : St S) (env : Env) (name field : Name)
    (receiver : Val) (owner : Nat) (extraArgs : List Val) (getter : Nat)
    (getterName : Option Name) (getterEnv : Env) (home : Val) (disposedName handleName : Name)
    (yes : Stmt) (value : Val) : St S :=
  {getterCallResult (mapperGetterInput s env name field receiver owner extraArgs getter)
    getterName getterEnv home owner disposedName handleName yes value with ctl := .ret value,stack := s.stack}

def mapperCallNotes (notes : RetainedNotes) (parameter owner : Nat) (role : Value) : RetainedNotes :=
  notes.withRuntime ⟨returnNote role,notes.runtime.stack,
    (notes.runtime.cells.write parameter (.obj owner)).write (parameter+1) (.obj owner)⟩

def MapperCallLive (live : Nat → Prop) (start : Nat) (name field : Name)
    (getterName : Option Name) (home : Val)
    (disposedName handleName : Name) (yes : Stmt) : Nat → Prop :=
  let mapperLive := ClosureLive live start true .undef (mapperFunction name field)
  let fn := getterFunction getterName disposedName handleName yes
  CellsLive (ClosureLive mapperLive (start+1) false home fn)
    (match home with | .undef => start+1+1 | _ => start+1+2) []

private theorem mapper_call_one (F : Ffi) (s t : St F.S) (C : CSrv)
    (active : isHalt s.ctl = false) (execution : interpC (step F s).run C = some (t,C)) :
    runC F 1 s C = some (t,C) := runC_cons F 0 s t t C C C active execution rfl

/-- The complete `x => x.handle` callback is a reusable source-function
contract. Initial closure, prototype path, and private ownership determine all
allocations, receiver bindings, getter calls, branches and return meanings. -/
theorem RetainedInventory.mapper_call_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (callee owner getter brand : Nat) (mapper getterObject object : Obj)
    (env : Env) (name field : Name) (receiver : Val) (extraArgs : List Val)
    (getterName : Option Name) (getterEnv : Env) (home setter : Val)
    (disposedName handleName : Name) (yes : Stmt) (value : Val) (role fnRole thisRole : Value)
    (extraRoles : List Value) (enumerable dw de hw he : Bool)
    (control : s₀.ctl = .call (.obj callee) receiver (.obj owner::extraArgs))
    (mapperRead : s₀.heap.get callee = some (.obj mapper))
    (mapperKind : mapper.kind = .fn (.closure (mapperFunction name field) env true .undef))
    (path : OrdinaryLookup s₀ field 16 owner (some (.acc (.obj getter) setter enumerable)))
    (getterRead : s₀.heap.get getter = some (.obj getterObject))
    (getterKind : getterObject.kind = .fn (.closure (getterFunction getterName disposedName handleName yes) getterEnv false home))
    (objectRead : s₀.heap.get owner = some (.obj object)) (ordinary : object.kind = .ordinary)
    (disposed : findPriv brand disposedName object.priv = some (.data (.bool false) dw de))
    (handle : findPriv brand handleName object.priv = some (.data value hw he))
    (disposedLookup : lookupEnv (privName disposedName) getterEnv = some brand)
    (handleLookup : lookupEnv (privName handleName) getterEnv = some brand)
    (disposedNames : nameEq (privName disposedName) nThis = false ∧ nameEq (privName disposedName) nHome = false)
    (handleNames : nameEq (privName handleName) nThis = false ∧ nameEq (privName handleName) nHome = false)
    (fieldNote : notes.privates.owners owner = some ⟨brand,handleName,role⟩)
    (controlNote : notes.runtime.control = callNote fnRole thisRole (.obj owner::extraRoles))
    (sourceBound : s₀.next+3 ≤ 2^64) (targetBound : s.next+3 ≤ 2^64) :
    ∃ result,
      runC F 26 s₀ C₀ = some (mapperCallResult s₀ env name field receiver owner extraArgs getter
        getterName getterEnv home disposedName handleName yes value,C₀) ∧
      runC F 26 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R
        (MapperCallLive live s₀.next name field getterName home disposedName handleName yes)
        framed before after old old'
        (mapperCallResult s₀ env name field receiver owner extraArgs getter getterName getterEnv home disposedName handleName yes value) result ∧
      RetainedInventory (mapperCallNotes notes s₀.next owner role) ν₀ ν C₀ C R
        (MapperCallLive live s₀.next name field getterName home disposedName handleName yes)
        (mapperCallResult s₀ env name field receiver owner extraArgs getter getterName getterEnv home disposedName handleName yes value) result ∧
      result.ffi = s.ffi ∧ result.next ≤ s.next+3 ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  obtain ⟨s6,left6,right6,h6,inv6,ffi6,next6,heap6⟩ := inventory.mapper_receiver_block h
    callee owner mapper env name field receiver fnRole thisRole extraArgs extraRoles control mapperRead mapperKind controlNote sourceBound targetBound
  have sourceWord : s₀.next < 2^64 := by omega
  have ownerLive := mapper_owner_live h callee owner receiver extraArgs control
  obtain ⟨_,_,_,_,support⟩ := path.transport F h.heap field ownerLive
  have getterLive : live getter := (support _ rfl).1
  have reachedPath := mapper_receiver_lookup h callee owner receiver extraArgs env name field _ control sourceWord path
  obtain ⟨frames,left7,right7,h7,inv7⟩ := inv6.getter_step h6 owner getter field setter enumerable
    (mapperEntrySource s₀ env name field receiver owner extraArgs).stack
    (descentFrameNote (mapperEnvironment s₀ env name) (.member (.id name) field false))
    (expressionReturnNote::callBoundaryNote::notes.runtime.stack) rfl rfl reachedPath rfl
  have reachedGetter : (mapperGetterInput s₀ env name field receiver owner extraArgs getter).heap.get getter = some (.obj getterObject) :=
    (mapper_entry_heap_below s₀ env name field receiver owner extraArgs sourceWord getter (h.heap.sourceBound getter getterLive)).trans getterRead
  have reachedObject : (mapperGetterInput s₀ env name field receiver owner extraArgs getter).heap.get owner = some (.obj object) :=
    (mapper_entry_heap_below s₀ env name field receiver owner extraArgs sourceWord owner (h.heap.sourceBound owner ownerLive)).trans objectRead
  have source7Bound : (mapperGetterInput s₀ env name field receiver owner extraArgs getter).next+2 ≤ 2^64 := by
    change s₀.next+1+2 ≤ 2^64
    omega
  have target7Bound : ({s6 with stack := frames}.go (.call (.obj (R.a getter)) (.obj (R.a owner)) [])).next+2 ≤ 2^64 := by
    change s6.next+2 ≤ 2^64
    omega
  obtain ⟨s24,left24,right24,h24,inv24,ffi24,next24,heap24⟩ := inv7.getter_call_block h7
    getter owner brand getterObject object getterName getterEnv home disposedName handleName yes value role dw de hw he
    rfl reachedGetter getterKind reachedObject ordinary disposed handle disposedLookup handleLookup disposedNames handleNames
    fieldNote rfl source7Bound target7Bound
  obtain ⟨result,left26,right26,h26,inv26,heap26,ffi26,next26⟩ := inv24.mapper_return_block h24
    value role (mapperEnvironment s₀ env name) s₀.stack expressionReturnNote callBoundaryNote notes.runtime.stack rfl rfl rfl rfl
  let reached := CellsLive (ClosureLive (ClosureLive live s₀.next true .undef (mapperFunction name field))
        (mapperGetterInput s₀ env name field receiver owner extraArgs getter).next false home
        (getterFunction getterName disposedName handleName yes))
        (closureState (mapperGetterInput s₀ env name field receiver owner extraArgs getter)
          (getterFunction getterName disposedName handleName yes) getterEnv false home (.obj owner) [] .call).next []
  change Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R reached framed before after old old'
    (mapperCallResult s₀ env name field receiver owner extraArgs getter getterName getterEnv home disposedName handleName yes value) result at h26
  change RetainedInventory (mapperCallNotes notes s₀.next owner role) ν₀ ν C₀ C R reached
    (mapperCallResult s₀ env name field receiver owner extraArgs getter getterName getterEnv home disposedName handleName yes value) result at inv26
  have reachedLive : reached = MapperCallLive live s₀.next name field getterName home disposedName handleName yes := by
    cases home <;> rfl
  rw [reachedLive] at h26 inv26
  have source7 := mapper_call_one F _ _ C₀ rfl left7
  have target7 := mapper_call_one F _ _ C (h6.control.isHalt_eq.trans rfl) right7
  refine ⟨result,runC_join F (runC_join F (runC_join F left6 source7) left24) left26,
    runC_join F (runC_join F (runC_join F right6 target7) right24) right26,h26,?_,ffi26.trans (ffi24.trans ffi6),?_,?_⟩
  · exact inv26
  · rw [next26]
    change s24.next ≤ s.next+3
    have last : s24.next ≤ s6.next+2 := next24
    omega
  · intro a below
    rw [heap26]
    exact (heap24 a (by change a < s6.next; omega)).trans (heap6 a below)

end Host.Ts.Owned.Annotated

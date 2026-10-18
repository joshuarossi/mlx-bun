import host.ts.RenameRuntimeDispatch
import host.ts.RenamePublicInventory
import host.ts.RenameHeapInventory
import host.ts.RenameArrayInventory
import host.ts.RenameBufferInventory
import host.ts.RenameParametricGlobal
import host.ts.RenameParametricLookup

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

private theorem global_lookup_eq (F : Ffi) (s : St F.S) (name : Name) (env : Env) (property : PropV)
    (control : s.ctl = .ev (.id name) env) (lookup : lookupEnv name env = none)
    (chain : getChain F s (.str name) 16 aGlobal = M.pure (some property)) :
    step F s = M.pure (Host.Ts.readProp F s (.obj aGlobal) (some property)) := by
  funext β k
  simp only [step,control,evStep,readVar,lookup]
  rw [chain]
  rfl

/-- Global reads leave every retained heap family unchanged. -/
theorem global_lookup_inventories {S : Type} {heapNotes : HeapNotes} {arrayNotes : ArrayNotes}
    {publicNotes : PublicNotes} {bufferNotes : BufferNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv}
    {R : Ren} {live : Nat → Prop} {s₀ s t₀ t : St S}
    (heap : HeapInventory heapNotes ν₀ ν C₀ C R live s₀ s)
    (arrays : ArrayInventory arrayNotes ν₀ ν C₀ C R live s₀ s)
    (publics : PublicInventory publicNotes ν₀ ν C₀ C R live s₀ s)
    (buffers : BufferInventory bufferNotes ν₀ ν C₀ C R live s₀ s)
    (source : t₀.heap = s₀.heap) (target : t.heap = s.heap) :
    HeapInventory heapNotes ν₀ ν C₀ C R live t₀ t ∧ ArrayInventory arrayNotes ν₀ ν C₀ C R live t₀ t ∧
      PublicInventory publicNotes ν₀ ν C₀ C R live t₀ t ∧ BufferInventory bufferNotes ν₀ ν C₀ C R live t₀ t :=
  ⟨heap.frame (fun _ h => h) (fun _ _ => source ▸ rfl) (fun _ _ => target ▸ rfl),
    arrays.frame (fun _ h => h) (fun _ _ _ => source ▸ rfl) (fun _ _ _ => target ▸ rfl),
    publics.frame (fun _ h => h) (fun _ _ _ _ => source ▸ rfl) (fun _ _ _ _ => target ▸ rfl),
    buffers.frame (fun _ h => h) (fun _ _ _ => source ▸ rfl) (fun _ _ _ => target ▸ rfl)⟩

/-- A global data value keeps its public field's fixed meaning when lexical
lookup misses. No target descriptor, returned role or execution is supplied. -/
theorem RuntimeInventory.global_data_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (heapNotes : HeapNotes) (arrays : ArrayNotes) (publics : PublicNotes) (buffers : BufferNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (heapInventory : HeapInventory heapNotes ν₀ ν C₀ C R live s₀ s)
    (arrayInventory : ArrayInventory arrays ν₀ ν C₀ C R live s₀ s)
    (publicInventory : PublicInventory publics ν₀ ν C₀ C R live s₀ s)
    (bufferInventory : BufferInventory buffers ν₀ ν C₀ C R live s₀ s)
    (name : Name) (env : Env) (o₀ : Obj) (value : Val) (role : Value) (w e : Bool)
    (control : s₀.ctl = .ev (.id name) env) (lookup : lookupEnv name env = none)
    (object : s₀.heap.get aGlobal = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (descriptor : findProp (.str name) o₀.props = some (.data value w e))
    (entry : publics.fields aGlobal name = some role) (globalFixed : R.a aGlobal = aGlobal) :
    ∃ targetValue,
      interpC (step F s₀).run C₀ = some (s₀.ret value,C₀) ∧ interpC (step F s).run C = some (s.ret targetValue,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' (s₀.ret value) (s.ret targetValue) ∧
      RuntimeInventory (notes.returning role) ν₀ ν C₀ C R live (s₀.ret value) (s.ret targetValue) ∧
      HeapInventory heapNotes ν₀ ν C₀ C R live (s₀.ret value) (s.ret targetValue) ∧
      ArrayInventory arrays ν₀ ν C₀ C R live (s₀.ret value) (s.ret targetValue) ∧
      PublicInventory publics ν₀ ν C₀ C R live (s₀.ret value) (s.ret targetValue) ∧
      BufferInventory buffers ν₀ ν C₀ C R live (s₀.ret value) (s.ret targetValue) := by
  have alive := publicInventory.keyLive aGlobal name role entry
  obtain ⟨sourceValue,sourceField,sourceRole⟩ := publicInventory.source aGlobal name role entry
  have same := sourceField.unique (show PublicData s₀ aGlobal name value from ⟨o₀,w,e,object,descriptor⟩)
  subst sourceValue
  obtain ⟨targetValue,targetField,targetRole⟩ := publicInventory.target aGlobal name role entry
  obtain ⟨o,targetRead,objectRelation,_⟩ := h.heap.readOrdinary aGlobal o₀ alive object ordinary
  obtain ⟨targetObject,tw,te,targetObjectRead,targetDescriptor⟩ := targetField
  have same := HObj.obj.inj (Option.some.inj (targetObjectRead.symm.trans targetRead))
  subst targetObject
  have targetLookup : lookupEnv name (R.env env) = none := by rw [lookupEnv_map,lookup]; rfl
  rw [globalFixed] at targetRead
  obtain ⟨result,sourceRun,targetRun,post,_⟩ := step_global_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h name env o₀ value w e control lookup object ordinary descriptor alive globalFixed
  have actual : interpC (step F s).run C = some (s.ret targetValue,C) := by
    rw [step_global_eq F s name (R.env env) o targetValue tw te (h.control_view control).ev_view targetLookup
      targetRead (objectRelation.ordinary ordinary) targetDescriptor]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans actual))
  dsimp only at same
  rw [same] at post
  obtain ⟨heap,arrays,publics,buffers⟩ := global_lookup_inventories heapInventory arrayInventory publicInventory bufferInventory
    (show (s₀.ret value).heap = s₀.heap from rfl) (show (s.ret targetValue).heap = s.heap from rfl)
  exact ⟨targetValue,sourceRun,actual,post,inventory.returning sourceRole targetRole,heap,arrays,publics,buffers⟩

/-- Initialized global constructors and inherited object bindings retain their
source address meanings through the original bounded prototype lookup. -/
theorem RuntimeInventory.global_object_path_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (heapNotes : HeapNotes) (arrays : ArrayNotes) (publics : PublicNotes) (buffers : BufferNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (heapInventory : HeapInventory heapNotes ν₀ ν C₀ C R live s₀ s)
    (arrayInventory : ArrayInventory arrays ν₀ ν C₀ C R live s₀ s)
    (publicInventory : PublicInventory publics ν₀ ν C₀ C R live s₀ s)
    (bufferInventory : BufferInventory buffers ν₀ ν C₀ C R live s₀ s)
    (name : Name) (env : Env) (value : Nat) (w e : Bool)
    (control : s₀.ctl = .ev (.id name) env) (lookup : lookupEnv name env = none)
    (path : OrdinaryLookup s₀ name 16 aGlobal (some (.data (.obj value) w e)))
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) :
    interpC (step F s₀).run C₀ = some (s₀.ret (.obj value),C₀) ∧
      interpC (step F s).run C = some (s.ret (.obj (R.a value)),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' (s₀.ret (.obj value)) (s.ret (.obj (R.a value))) ∧
      RuntimeInventory (notes.returning (.obj value)) ν₀ ν C₀ C R live (s₀.ret (.obj value)) (s.ret (.obj (R.a value))) ∧
      HeapInventory heapNotes ν₀ ν C₀ C R live (s₀.ret (.obj value)) (s.ret (.obj (R.a value))) ∧
      ArrayInventory arrays ν₀ ν C₀ C R live (s₀.ret (.obj value)) (s.ret (.obj (R.a value))) ∧
      PublicInventory publics ν₀ ν C₀ C R live (s₀.ret (.obj value)) (s.ret (.obj (R.a value))) ∧
      BufferInventory buffers ν₀ ν C₀ C R live (s₀.ret (.obj value)) (s.ret (.obj (R.a value))) := by
  obtain ⟨property,sourceGet,targetGet,relation,propertyLive⟩ := path.transport F h.heap name globalLive
  cases relation with | some relation =>
    obtain ⟨targetValue,rfl,valueRelation⟩ := relation.data
    cases valueRelation
    rw [globalFixed] at targetGet
    have targetLookup : lookupEnv name (R.env env) = none := by rw [lookupEnv_map,lookup]; rfl
    have sourceRun : interpC (step F s₀).run C₀ = some (s₀.ret (.obj value),C₀) := by
      rw [global_lookup_eq F s₀ name env _ control lookup sourceGet]; rfl
    have targetRun : interpC (step F s).run C = some (s.ret (.obj (R.a value)),C) := by
      rw [global_lookup_eq F s name (R.env env) _ (h.control_view control).ev_view targetLookup targetGet]; rfl
    have alive : live value := (propertyLive _ rfl).1
    have post := h.go (c:=.ret (.obj value)) (c':=.ret (.obj (R.a value)))
      (.node _ (.cons (.value (.obj value)) .nil)) ⟨alive,True.intro⟩
    obtain ⟨heap,arrays,publics,buffers⟩ := global_lookup_inventories heapInventory arrayInventory publicInventory bufferInventory
      (show (s₀.ret (.obj value)).heap = s₀.heap from rfl) (show (s.ret (.obj (R.a value))).heap = s.heap from rfl)
    exact ⟨sourceRun,targetRun,post,inventory.returning (.obj value) (.obj value),heap,arrays,publics,buffers⟩

end Host.Ts.Owned.Annotated

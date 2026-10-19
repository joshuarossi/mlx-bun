import host.ts.RenameCstrEntryFields
import host.ts.RenameMapIndexEffects

set_option Elab.async false
set_option maxHeartbeats 1000000
set_option maxRecDepth 100000
namespace Host.Ts.Owned.Annotated
open Parametric

/-- The cache resource captured before calling cstr. Parameter and local
cells are deliberately absent: the original function entry creates them. -/
structure CstrCacheBefore {S : Type} (source : St S) (env : Env) (key : Name) (buffer : Nat) where
  cacheCell : Nat
  owner : Nat
  prototype : Nat
  callee : Nat
  object : Obj
  parent : Obj
  function : Obj
  entries : List (Val × Val)
  data : List Val
  writable : Bool
  enumerable : Bool
  cacheLookup : lookupEnv chars!"cstrCache" env = some cacheCell
  cacheRead : source.heap.get cacheCell = some (.cell (some (.obj owner)))
  objectRead : source.heap.get owner = some (.obj object)
  objectKind : object.kind = .map entries
  ownAbsent : findProp (.str chars!"get") object.props = none
  proto : object.proto = .obj prototype
  parentRead : source.heap.get prototype = some (.obj parent)
  parentKind : parent.kind = .ordinary
  getMethod : findProp (.str chars!"get") parent.props = some (.data (.obj callee) writable enumerable)
  functionRead : source.heap.get callee = some (.obj function)
  functionKind : function.kind = .fn (.native (.map .get) data)
  cached : StringIndex.firstValue (pack key) entries = some (.obj buffer)

/-- Current captured ownership places every cache resource below the fresh
receiver/parameter/local cells. The entry itself produces their new values. -/
theorem CstrCacheBefore.entry {S : Type} {NR : NumV → NumV → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {source target : St S}
    {env : Env} {key : Name} {buffer : Nat}
    (current : CstrCacheBefore source env key buffer)
    (heap : Parametric.HeapR NR R live framed before after source target)
    (environmentLive : treeSupport live (Encode.env env)) (receiver : Val)
    (bound : source.next+3 ≤ 2^64) :
    Nonempty (CstrCachedData (cstrEntry source env receiver key) (cstrEntryEnv source env) key (source.next+2) buffer) := by
  have cacheLive := env_lookup_live chars!"cstrCache" env current.cacheCell environmentLive current.cacheLookup
  obtain ⟨_,_,_,ownerLive⟩ := heap.readCell current.cacheCell (.obj current.owner) cacheLive current.cacheRead
  obtain ⟨_,_,_,objectLive⟩ := heap.readObject current.owner current.object ownerLive
    (heap.map_notFramed current.owner current.object current.entries ownerLive current.objectRead current.objectKind) current.objectRead
  have prototypeLive : live current.prototype := by
    have support := objectLive.2.1
    rw [current.proto] at support
    exact support
  obtain ⟨_,_,_,parentLive⟩ := heap.readOrdinary current.prototype current.parent prototypeLive current.parentRead current.parentKind
  have calleeLive : live current.callee := (PropsR.support_find parentLive.2.2.1 chars!"get" current.getMethod).1
  have preserve (address : Nat) (alive : live address) :=
    cstr_entry_heap_below source env receiver key address (heap.sourceBound address alive) bound
  refine ⟨⟨current.cacheCell,source.next+1,current.owner,current.prototype,current.callee,
    current.object,current.parent,current.function,current.entries,current.data,current.writable,current.enumerable,
    ?_,?_,?_,(preserve _ cacheLive).trans current.cacheRead,
    cstr_entry_parameter source env receiver key bound,cstr_entry_local source env receiver key bound,
    (preserve _ ownerLive).trans current.objectRead,current.objectKind,current.ownAbsent,current.proto,
    (preserve _ prototypeLive).trans current.parentRead,current.parentKind,current.getMethod,
    (preserve _ calleeLive).trans current.functionRead,current.functionKind,current.cached⟩⟩
  · unfold cstrEntryEnv
    rw [lookupEnv_skip chars!"cstrCache" chars!"b" _ _ (by decide +kernel),
      lookupEnv_skip chars!"cstrCache" chars!"s" _ _ (by decide +kernel),
      lookupEnv_skip chars!"cstrCache" nThis _ _ (by decide +kernel)]
    exact current.cacheLookup
  · unfold cstrEntryEnv
    rw [lookupEnv_skip chars!"s" chars!"b" _ _ (by decide +kernel)]
    exact lookupEnv_head _ _ _
  · exact lookupEnv_head _ _ _

end Host.Ts.Owned.Annotated

import host.ts.RenameCstrCachedExecution
import host.ts.RenameRetainedStores

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Only current lexical cells, map entries and initialized prototype data. -/
structure CstrCachedData {S : Type} (source : St S) (env : Env) (key : Name) (localCell buffer : Nat) where
  cacheCell : Nat
  parameter : Nat
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
  parameterLookup : lookupEnv chars!"s" env = some parameter
  localLookup : lookupEnv chars!"b" env = some localCell
  cacheRead : source.heap.get cacheCell = some (.cell (some (.obj owner)))
  parameterRead : source.heap.get parameter = some (.cell (some (.str key)))
  localRead : source.heap.get localCell = some (.cell none)
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

theorem CstrCachedData.execution {F : Ffi} {source : St F.S} {env : Env} {key : Name} {localCell buffer : Nat}
    (current : CstrCachedData source env key localCell buffer) (C : CSrv) (caller : List Frame)
    (bound : localCell < 2^64) :
    runC F 25 (cstrBodyState source env caller) C = some (cstrBodyResult source localCell buffer caller,C) :=
  run_cstr_cached_body F source C env caller current.cacheCell current.parameter localCell current.owner
    current.prototype current.callee buffer current.object current.parent current.function current.entries current.data key
    current.writable current.enumerable current.cacheLookup current.parameterLookup current.localLookup
    current.cacheRead current.parameterRead current.objectRead current.objectKind current.ownAbsent current.proto
    current.parentRead current.parentKind current.getMethod current.functionRead current.functionKind current.cached bound

/-- Structural heap ownership transports the entire current cache description.
The source string selects the target entry; no target cache fact is assumed. -/
theorem CstrCachedData.transport {S : Type} {NR : NumV → NumV → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {source target : St S}
    {env : Env} {key : Name} {localCell buffer : Nat}
    (current : CstrCachedData source env key localCell buffer)
    (heap : Parametric.HeapR NR R live framed before after source target)
    (environmentLive : treeSupport live (Encode.env env)) :
    live localCell ∧ live buffer ∧ Nonempty (CstrCachedData target (R.env env) key (R.a localCell) (R.a buffer)) := by
  have cacheLive := env_lookup_live chars!"cstrCache" env current.cacheCell environmentLive current.cacheLookup
  have parameterLive := env_lookup_live chars!"s" env current.parameter environmentLive current.parameterLookup
  have localLive := env_lookup_live chars!"b" env localCell environmentLive current.localLookup
  obtain ⟨_,targetCacheRead,cacheRelation,ownerLive⟩ := heap.readCell current.cacheCell (.obj current.owner) cacheLive current.cacheRead
  cases cacheRelation
  obtain ⟨_,targetParameterRead,parameterRelation,_⟩ := heap.readCell current.parameter (.str key) parameterLive current.parameterRead
  cases parameterRelation
  obtain ⟨object,targetObjectRead,objectRelation,objectLive⟩ := heap.readObject current.owner current.object ownerLive
    (heap.map_notFramed current.owner current.object current.entries ownerLive current.objectRead current.objectKind) current.objectRead
  have kindRelation := objectRelation.kind
  rw [current.objectKind] at kindRelation
  obtain ⟨entries,targetObjectKind,pairsRelation⟩ := kind_string_map kindRelation
  have targetAbsent : findProp (.str chars!"get") object.props = none := by
    have fields := objectRelation.properties.find_string chars!"get"
    rw [current.ownAbsent] at fields
    generalize findProp (.str chars!"get") object.props = found at fields
    cases fields
    rfl
  have targetPrototype : object.proto = .obj (R.a current.prototype) := by
    have protoRelation := objectRelation.prototype
    rw [current.proto] at protoRelation
    generalize object.proto = found at protoRelation
    cases protoRelation
    rfl
  have prototypeLive : live current.prototype := by
    have protoLive := objectLive.2.1
    rw [current.proto] at protoLive
    exact protoLive
  obtain ⟨parent,targetParentRead,parentRelation,parentLive⟩ :=
    heap.readOrdinary current.prototype current.parent prototypeLive current.parentRead current.parentKind
  obtain ⟨_,targetMethod,methodRelation⟩ := parentRelation.properties.find_data chars!"get" (.obj current.callee)
    current.writable current.enumerable current.getMethod
  cases methodRelation
  have calleeLive : live current.callee :=
    (PropsR.support_find parentLive.2.2.1 chars!"get" current.getMethod).1
  obtain ⟨function,targetFunctionRead,functionRelation,_⟩ := heap.readObject current.callee current.function calleeLive
    (heap.function_notFramed current.callee current.function _ calleeLive current.functionRead current.functionKind) current.functionRead
  have functionKind := functionRelation.kind
  rw [current.functionKind] at functionKind
  obtain ⟨data,targetFunctionKind,_⟩ := kind_native functionKind
  have targetCached := string_map_value_related (pack key) pairsRelation
  rw [current.cached,Option.getD_some] at targetCached
  have targetLookup : StringIndex.firstValue (pack key) entries = some (.obj (R.a buffer)) := by
    generalize found : StringIndex.firstValue (pack key) entries = value at targetCached ⊢
    cases value with
    | none => cases targetCached
    | some value =>
      change Parametric.ValueR NR R (.obj buffer) value at targetCached
      cases targetCached
      rfl
  have entriesLive : treeSupport live (Encode.pairs current.entries) := by
    have kindLive := objectLive.1
    rw [current.objectKind] at kindLive
    exact kindLive.1
  have bufferLive : live buffer := by
    have valueLive := string_map_value_support (pack key) current.entries entriesLive
    simpa only [current.cached,Option.getD_some,valueSupport] using valueLive
  have targetLocalRead : target.heap.get (R.a localCell) = some (.cell none) := by
    have slot := heap.lookup localCell localLive
    rw [current.localRead] at slot
    generalize target.heap.get (R.a localCell) = found at slot ⊢
    cases slot with | regular _ relation _ => cases relation; rfl
  refine ⟨localLive,bufferLive,⟨⟨R.a current.cacheCell,R.a current.parameter,R.a current.owner,R.a current.prototype,
    R.a current.callee,object,parent,function,entries,data,current.writable,current.enumerable,
    ?_,?_,?_,targetCacheRead,targetParameterRead,targetLocalRead,targetObjectRead,targetObjectKind,
    targetAbsent,targetPrototype,targetParentRead,parentRelation.ordinary current.parentKind,targetMethod,
    targetFunctionRead,targetFunctionKind,targetLookup⟩⟩⟩
  · rw [lookupEnv_map,current.cacheLookup]; rfl
  · rw [lookupEnv_map,current.parameterLookup]; rfl
  · rw [lookupEnv_map,current.localLookup]; rfl

end Host.Ts.Owned.Annotated

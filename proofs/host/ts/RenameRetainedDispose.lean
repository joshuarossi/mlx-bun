import host.ts.RenameRetainedDisposeMetadata
import host.ts.RenameRetainedDisposeFinish
import host.ts.RenamePrivateListFrame
import host.ts.RenameRuntimeStaticCall
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Ts.Owned.Annotated.Dispose
open Parametric Host.Load.Run.Full.Ordinary Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles

/-- Current source metadata of the pinned disposal closure and its operands. -/
structure SourceData where
  method : Nat
  owner : Nat
  brand : Nat
  registryCell : Nat
  registryAddress : Nat
  unregisterFn : Nat
  moduleCell : Nat
  moduleAddress : Nat
  freeFn : Nat
  types : Nat
  tokenAddress : Nat
  arrayHandle : Nat
  methodObject : Host.Ts.Obj
  ownerObject : Host.Ts.Obj
  unregisterObject : Host.Ts.Obj
  freeObject : Host.Ts.Obj
  signatureObject : Host.Ts.Obj
  env : Env
  home : Val
  unregisterData : List Val
  returns : Name
  flagEnumerable : Bool
  handleWritable : Bool
  handleEnumerable : Bool
  tokenWritable : Bool
  tokenEnumerable : Bool
  registryWritable : Bool
  registryEnumerable : Bool
  moduleWritable : Bool
  moduleEnumerable : Bool

structure SourceEntry (data : SourceData) (live : Nat → Prop) (source : Host.Ts.St Host.Load.LSt) : Prop where
  control : source.ctl = .call (.obj data.method) (.obj data.owner) []
  methodRead : source.heap.get data.method = some (.obj data.methodObject)
  methodKind : data.methodObject.kind = .fn (.closure function data.env false data.home)
  ownerRead : source.heap.get data.owner = some (.obj data.ownerObject)
  ordinary : data.ownerObject.kind = .ordinary
  disposed : findPriv data.brand flag data.ownerObject.priv = some (.data (.bool false) true data.flagEnumerable)
  handleRead : findPriv data.brand handle data.ownerObject.priv =
    some (.data (.big (Int.ofNat data.arrayHandle)) data.handleWritable data.handleEnumerable)
  tokenRead : findPriv data.brand token data.ownerObject.priv =
    some (.data (.obj data.tokenAddress) data.tokenWritable data.tokenEnumerable)
  flagLookup : lookupEnv (privName flag) data.env = some data.brand
  handleLookup : lookupEnv (privName handle) data.env = some data.brand
  tokenLookup : lookupEnv (privName token) data.env = some data.brand
  registryLookup : lookupEnv registry data.env = some data.registryCell
  moduleLookup : lookupEnv nativeModule data.env = some data.moduleCell
  registryCellRead : source.heap.get data.registryCell = some (.cell (some (.obj data.registryAddress)))
  moduleCellRead : source.heap.get data.moduleCell = some (.cell (some (.obj data.moduleAddress)))
  registryPath : OrdinaryLookup source unregister 16 data.registryAddress
    (some (.data (.obj data.unregisterFn) data.registryWritable data.registryEnumerable))
  modulePath : OrdinaryLookup source free 16 data.moduleAddress
    (some (.data (.obj data.freeFn) data.moduleWritable data.moduleEnumerable))
  unregisterRead : source.heap.get data.unregisterFn = some (.obj data.unregisterObject)
  unregisterKind : data.unregisterObject.kind = .fn (.native (.fn .finUnregister) data.unregisterData)
  freeRead : source.heap.get data.freeFn = some (.obj data.freeObject)
  freeKind : data.freeObject.kind = .fn (.native (.ffi .symbol) [.str free,.obj data.types,.str data.returns])
  signatureRead : source.heap.get data.types = some (.obj data.signatureObject)
  signatureKind : data.signatureObject.kind = .array [.str chars!"u64"]
  registryLive : live data.registryAddress
  moduleLive : live data.moduleAddress
  below : ∀ a ∈ [data.owner,data.registryCell,data.moduleCell,data.unregisterFn,data.freeFn,data.types], a < source.next

def environment (source : Host.Ts.St Host.Load.LSt) (data : SourceData) : Env :=
  closureEnvironment source function data.env false data.home (.obj data.owner)
def callers (source : Host.Ts.St Host.Load.LSt) : List Frame := .s (.scope [])::.k (.fn .call)::source.stack

def successResult (source : Host.Ts.St Host.Load.LSt) (data : SourceData) : Host.Ts.St Host.Load.LSt :=
  let e := environment source data
  let fs := callers source
  let entered := entryState source data.env data.home data.owner
  let guarded := guardOutput entered e fs
  let flagged := flagOutput guarded e fs data.owner data.brand data.ownerObject data.flagEnumerable
  let unregistered := unregisterOutput flagged e fs
  finishOutput (freeOutput unregistered e fs data.arrayHandle) source.stack

def successNotes (notes : RetainedNotes) (receiver owner : Nat) : RetainedNotes :=
  notes.withRuntime ⟨returnNote .undef,notes.runtime.stack,notes.runtime.cells.write receiver (.obj owner)⟩

/-- All forty original source transitions of a successful live-array disposal.
Only current source observations and retained operand roles are assumptions;
the target execution, final inventories and producer support are conclusions. -/
theorem successful_call {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {nodes : Nat → GraphNode} {boundary : Nat → Prop} {objects : Nat → Object}
    {roots H N : Nat → Prop} {tailTokens : List NumV} {host : Host.Load.HostSt → Host.Load.HostSt → Prop}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {source target : Host.Ts.St Host.Load.LSt}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tailTokens host)
      R live framed before after old old' source target)
    (policy : ProducerAnnotations roots H N nodes objects)
    (data : SourceData) (entry : SourceEntry data live source)
    (handleNote : notes.privates.owners data.owner = some ⟨data.brand,handle,.handle data.arrayHandle⟩)
    (signatureFrame : ¬ framed data.types) (handleLive : H data.arrayHandle) (nonzero : data.arrayHandle ≠ 0)
    (sourceBound : source.next+2 ≤ 2^64) (targetBound : target.next+2 ≤ 2^64)
    (sourceHandleBound : data.arrayHandle < 2^64) (targetHandleBound : target.ffi.mlx.next < 2^64) :
    ∃ result,
      runC Host.Load.ffi 40 source C₀ = some (successResult source data,C₀) ∧
      runC Host.Load.ffi 40 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects
          (fun i => H i ∧ i ≠ data.arrayHandle) N tailTokens host)
        R (liveAfter live source data.env data.home data.owner) framed before after old old'
          (successResult source data) result ∧
      RetainedInventory (successNotes notes source.next data.owner) ν₀ ν C₀ C R
        (liveAfter live source data.env data.home data.owner) (successResult source data) result ∧
      ProducerAnnotations roots (fun i => H i ∧ i ≠ data.arrayHandle) N nodes objects ∧
      ProducerSupport roots (fun i => H i ∧ i ≠ data.arrayHandle) N (successResult source data).ffi.mlx ∧
      ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i))
        (resourceImage R.handle (fun i => H i ∧ i ≠ data.arrayHandle)) (resourceImage R.node N) result.ffi.mlx := by
  let F := Host.Load.ffi
  let FR := VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tailTokens host
  let e := environment source data
  let fs := callers source
  let entered := entryState source data.env data.home data.owner
  let guarded := guardOutput entered e fs
  let flagged := flagOutput guarded e fs data.owner data.brand data.ownerObject data.flagEnumerable
  have controlNote := inventory.runtime.object_call_note data.method data.owner entry.control
  obtain ⟨s4,left4,right4,h4,inv4,native4,next4,heap4⟩ := entry_block (F:=F) inventory state data.method data.owner
    data.methodObject data.env data.home entry.control entry.methodRead entry.methodKind controlNote sourceBound targetBound
  have oldHeap (a : Nat) (below : a < source.next) : entered.heap.get a = source.heap.get a :=
    entry_heap_below F source data.env data.home data.owner a sourceBound below
  have belowOwner : data.owner < source.next := entry.below _ (by simp)
  have readOwner : entered.heap.get data.owner = some (.obj data.ownerObject) := (oldHeap _ belowOwner).trans entry.ownerRead
  have thisRead : entered.heap.get source.next = some (.cell (some (.obj data.owner))) :=
    entry_receiver F source data.env data.home data.owner sourceBound
  have thisLookup : lookupEnv nThis e = some source.next := environment_this source data.env data.home data.owner
  have inherited (name : Name) (address : Nat) (names : nameEq name nThis = false ∧ nameEq name nHome = false)
      (lookup : lookupEnv name data.env = some address) : lookupEnv name e = some address :=
    environment_lookup source data.env data.home data.owner name address names lookup
  have flagLookup := inherited (privName flag) data.brand (by decide +kernel) entry.flagLookup
  have handleLookup := inherited (privName handle) data.brand (by decide +kernel) entry.handleLookup
  have tokenLookup := inherited (privName token) data.brand (by decide +kernel) entry.tokenLookup
  have registryLookup := inherited registry data.registryCell (by decide +kernel) entry.registryLookup
  have moduleLookup := inherited nativeModule data.moduleCell (by decide +kernel) entry.moduleLookup
  have thisNote : (notes.withRuntime (entryRuntime notes.runtime e source.next data.owner)).runtime.cells.cells source.next = some (.obj data.owner) := by
    simp only [entryRuntime,RetainedNotes.withRuntime,RuntimeNotes.statement,RuntimeNotes.blockNext,RuntimeNotes.bodyEntered,
      RuntimeNotes.closure,Bool.false_eq_true,↓reduceIte,Notes.write,ite_true]
  obtain ⟨s8,left8,right8,h8,inv8,heap8,native8,next8⟩ := guard_block (F:=F) inv4 h4 e fs
    ((statementFrameNotes e (.ifTest (.priv .this flag false) (.ret none) none)).headD (.node "" []))
    (emptyScopeNote::callBoundaryNote::notes.runtime.stack) source.next data.owner data.brand data.ownerObject true
    data.flagEnumerable rfl rfl rfl thisLookup flagLookup thisRead readOwner entry.ordinary entry.disposed thisNote
  have different : ∀ note, notes.privates.owners data.owner = some note → nameEq note.name flag = false := by
    intro note selected
    have same := Option.some.inj (handleNote.symm.trans selected)
    subst note
    change nameEq handle flag = false
    decide +kernel
  obtain ⟨s15,left15,right15,h15,inv15,native15,next15⟩ := flag_block (F:=F) inv8 h8 e fs
    (blockFrameNote [assign,unregisterStmt,freeStmt] e) (emptyScopeNote::callBoundaryNote::notes.runtime.stack)
    .undef source.next data.owner data.brand data.ownerObject data.flagEnumerable rfl rfl rfl thisLookup flagLookup
    thisRead readOwner entry.ordinary entry.disposed thisNote different
    (by exact Nat.le_trans (entry_next_le source data.env data.home data.owner) sourceBound)
    (by rw [next8]; exact Nat.le_trans next4 targetBound)
  have oldFlag (a : Nat) (ne : a ≠ data.owner) : flagged.heap.get a = entered.heap.get a := by
    change (entered.heap.set data.owner (.obj (flaggedObject data.ownerObject data.brand data.flagEnumerable))).get a = _
    rw [PTrie.get_set_u64 _ _ _ (by omega),ite_eq_right ne]
  have flaggedOwner : flagged.heap.get data.owner = some (.obj (flaggedObject data.ownerObject data.brand data.flagEnumerable)) := by
    change (entered.heap.set data.owner (.obj (flaggedObject data.ownerObject data.brand data.flagEnumerable))).get data.owner = _
    exact (PTrie.get_set_u64 _ _ _ (by omega) data.owner).trans (if_pos rfl)
  have flaggedThis : flagged.heap.get source.next = some (.cell (some (.obj data.owner))) :=
    (oldFlag _ (by omega)).trans thisRead
  have cellNe (a object : Nat) (read : source.heap.get a = some (.cell (some (.obj object)))) : a ≠ data.owner := by
    intro equal
    rw [equal,entry.ownerRead] at read
    cases read
  have objectNe (a : Nat) (object : Host.Ts.Obj) (read : source.heap.get a = some (.obj object))
      (differentKind : object.kind ≠ .ordinary) : a ≠ data.owner := by
    intro equal
    rw [equal,entry.ownerRead] at read
    have same := HObj.obj.inj (Option.some.inj read)
    exact differentKind (same ▸ entry.ordinary)
  have unregNe := objectNe data.unregisterFn data.unregisterObject entry.unregisterRead (by rw [entry.unregisterKind]; intro bad; cases bad)
  have freeNe := objectNe data.freeFn data.freeObject entry.freeRead (by rw [entry.freeKind]; intro bad; cases bad)
  have typesNe := objectNe data.types data.signatureObject entry.signatureRead (by rw [entry.signatureKind]; intro bad; cases bad)
  have slotRead (a : Nat) (below : a < source.next) (ne : a ≠ data.owner) : flagged.heap.get a = source.heap.get a :=
    (oldFlag a ne).trans (oldHeap a below)
  have registryRead := (slotRead data.registryCell (entry.below _ (by simp)) (cellNe _ _ entry.registryCellRead)).trans entry.registryCellRead
  have moduleRead := (slotRead data.moduleCell (entry.below _ (by simp)) (cellNe _ _ entry.moduleCellRead)).trans entry.moduleCellRead
  have unregisterRead := (slotRead data.unregisterFn (entry.below _ (by simp)) unregNe).trans entry.unregisterRead
  have freeRead := (slotRead data.freeFn (entry.below _ (by simp)) freeNe).trans entry.freeRead
  have signatureRead := (slotRead data.types (entry.below _ (by simp)) typesNe).trans entry.signatureRead
  have registryPathEntered := entry.registryPath.frame_live (reached:=entered) state.heap (fun a alive => oldHeap a (state.heap.sourceBound a alive)) entry.registryLive
  have modulePathEntered := entry.modulePath.frame_live (reached:=entered) state.heap (fun a alive => oldHeap a (state.heap.sourceBound a alive)) entry.moduleLive
  have registryPathWritten := lookup_private_write registryPathEntered data.owner data.ownerObject
    (flaggedObject data.ownerObject data.brand data.flagEnumerable).priv readOwner (by omega)
  have modulePathWritten := lookup_private_write modulePathEntered data.owner data.ownerObject
    (flaggedObject data.ownerObject data.brand data.flagEnumerable).priv readOwner (by omega)
  have registryPath := lookup_same_heap (target:=flagged) registryPathWritten (by rfl)
  have modulePath := lookup_same_heap (target:=unregisterOutput flagged e fs) modulePathWritten (by rfl)
  have flaggedToken : findPriv data.brand token (flaggedObject data.ownerObject data.brand data.flagEnumerable).priv =
      some (.data (.obj data.tokenAddress) data.tokenWritable data.tokenEnumerable) := by
    rw [flaggedObject,findPriv_set_name_ne _ _ _ _ _ _ (by decide +kernel)]
    exact entry.tokenRead
  have flaggedHandle : findPriv data.brand handle (flaggedObject data.ownerObject data.brand data.flagEnumerable).priv =
      some (.data (.big (Int.ofNat data.arrayHandle)) data.handleWritable data.handleEnumerable) := by
    rw [flaggedObject,findPriv_set_name_ne _ _ _ _ _ _ (by decide +kernel)]
    exact entry.handleRead
  obtain ⟨s26,left26,right26,h26,inv26,heap26,native26,next26⟩ := unregister_block (F:=F) inv15 h15 e fs
    (blockFrameNote [unregisterStmt,freeStmt] e) (emptyScopeNote::callBoundaryNote::notes.runtime.stack) (.bool true)
    data.registryCell data.registryAddress data.unregisterFn source.next data.owner data.brand data.tokenAddress
    (flaggedObject data.ownerObject data.brand data.flagEnumerable) data.unregisterObject data.unregisterData
    data.registryWritable data.registryEnumerable data.tokenWritable data.tokenEnumerable rfl rfl rfl registryLookup thisLookup
    tokenLookup registryRead flaggedThis flaggedOwner entry.ordinary flaggedToken registryPath unregisterRead entry.unregisterKind thisNote
  obtain ⟨s37,left37,right37,h37,inv37,policy37,support37,targetSupport37⟩ := free_block inv26 h26 policy e fs
    (blockFrameNote [freeStmt] e) (emptyScopeNote::callBoundaryNote::notes.runtime.stack) (.bool false)
    data.moduleCell data.moduleAddress data.freeFn data.types source.next data.owner data.brand data.arrayHandle
    (flaggedObject data.ownerObject data.brand data.flagEnumerable) data.freeObject data.signatureObject data.returns
    data.moduleWritable data.moduleEnumerable data.handleWritable data.handleEnumerable rfl rfl rfl moduleLookup thisLookup
    handleLookup moduleRead flaggedThis flaggedOwner entry.ordinary flaggedHandle modulePath freeRead entry.freeKind signatureRead
    entry.signatureKind thisNote handleNote signatureFrame handleLive nonzero sourceHandleBound
    (by
      have same := native26.trans (native15.trans (native8.trans native4))
      exact (congrArg (fun x : Host.Load.LSt => x.mlx.next) same).symm ▸ targetHandleBound)
  obtain ⟨result,left40,right40,h40,inv40,heap40,native40,next40⟩ := finish_block (F:=F) inv37 h37 e source.stack
    (blockFrameNote [] e) emptyScopeNote callBoundaryNote notes.runtime.stack (.num zeroN) nativeStatusRole rfl rfl rfl rfl
  refine ⟨result,runC_join F (runC_join F (runC_join F (runC_join F (runC_join F left4 left8) left15) left26) left37) left40,
    runC_join F (runC_join F (runC_join F (runC_join F (runC_join F right4 right8) right15) right26) right37) right40,
    h40,inv40,policy37,support37,?_⟩
  rw [native40]
  exact targetSupport37

end Host.Ts.Owned.Annotated.Dispose

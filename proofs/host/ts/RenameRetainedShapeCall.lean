import host.mlx.NativeShapeCallBody
import host.ts.RenameRetainedShapeCallFacts
import host.ts.RenameRetainedShapeCallPrelude

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Owned.Annotated
open Parametric Host.Load.Run.Full.Ordinary Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
namespace ShapeCall

/-- Physical facts about the current source call. Every heap/native read is at
the entry state; later lexical cells and operands are produced by execution. -/
structure Source (source : St Host.Load.LSt) where
  shapeGetter : Nat
  ndimGetter : Nat
  owner : Nat
  getter : Nat
  brand : Nat
  numberFn : Nat
  ndimFn : Nat
  shapeFn : Nat
  moduleCell : Nat
  module : Nat
  ndimTypes : Nat
  shapeTypes : Nat
  handle : Nat
  producer : Nat
  typedFn : Nat
  bufferCell : Nat
  bufferFn : Nat
  typedProto : Nat
  shapeObject : Obj
  ndimObject : Obj
  getterObject : Obj
  object : Obj
  global : Obj
  numberObject : Obj
  ndimNative : Obj
  shapeNative : Obj
  ndimSignature : Obj
  shapeSignature : Obj
  typedObject : Obj
  bufferObject : Obj
  shapeEnv : Env
  ndimEnv : Env
  getEnv : Env
  shapeHome : Val
  ndimHome : Val
  getHome : Val
  getName : Option Name
  disposed : Name
  field : Name
  yes : Stmt
  nw : Bool
  ne : Bool
  nmw : Bool
  nme : Bool
  smw : Bool
  sme : Bool
  nge : Bool
  hge : Bool
  dw : Bool
  de : Bool
  hw : Bool
  he : Bool
  tw : Bool
  te : Bool
  ndimSetter : Val
  handleSetter : Val
  ndimReturns : Name
  shapeReturns : Name
  numberData : List Val
  bufferData : List Val
  kindValue : F64
  protoValue : F64
  node : Host.Mlx.Ffi.Node
  control : source.ctl = .call (.obj shapeGetter) (.obj owner) []
  shapeRead : source.heap.get shapeGetter = some (.obj shapeObject)
  shapeKind : shapeObject.kind = .fn (.closure Sources.Mlx.Array.ast_n67 shapeEnv false shapeHome)
  ndimPath : OrdinaryLookup source ndimName 16 owner (some (.acc (.obj ndimGetter) ndimSetter nge))
  ndimRead : source.heap.get ndimGetter = some (.obj ndimObject)
  ndimKind : ndimObject.kind = .fn (.closure Sources.Mlx.Array.ast_n61 ndimEnv false ndimHome)
  numberLookup : lookupEnv NdimCall.numberName ndimEnv = none
  globalRead : source.heap.get aGlobal = some (.obj global)
  globalKind : global.kind = .ordinary
  numberProperty : findProp (.str NdimCall.numberName) global.props = some (.data (.obj numberFn) nw ne)
  ndimModuleLookup : lookupEnv NdimCall.nativeModule ndimEnv = some moduleCell
  shapeModuleLookup : lookupEnv NdimCall.nativeModule shapeEnv = some moduleCell
  moduleRead : source.heap.get moduleCell = some (.cell (some (.obj module)))
  ndimNativePath : OrdinaryLookup source NdimCall.nativeName 16 module (some (.data (.obj ndimFn) nmw nme))
  shapeNativePath : OrdinaryLookup source nativeName 16 module (some (.data (.obj shapeFn) smw sme))
  getterPath : OrdinaryLookup source NdimCall.handleName 16 owner (some (.acc (.obj getter) handleSetter hge))
  getterRead : source.heap.get getter = some (.obj getterObject)
  getterKind : getterObject.kind = .fn (.closure (getterFunction getName disposed field yes) getEnv false getHome)
  objectRead : source.heap.get owner = some (.obj object)
  ordinary : object.kind = .ordinary
  disposedValue : findPriv brand disposed object.priv = some (.data (.bool false) dw de)
  handleValue : findPriv brand field object.priv = some (.data (.big (Int.ofNat handle)) hw he)
  disposedLookup : lookupEnv (privName disposed) getEnv = some brand
  handleLookup : lookupEnv (privName field) getEnv = some brand
  disposedNames : nameEq (privName disposed) nThis = false ∧ nameEq (privName disposed) nHome = false
  handleNames : nameEq (privName field) nThis = false ∧ nameEq (privName field) nHome = false
  numberRead : source.heap.get numberFn = some (.obj numberObject)
  numberKind : numberObject.kind = .fn (.native (.num .number) numberData)
  ndimNativeRead : source.heap.get ndimFn = some (.obj ndimNative)
  ndimNativeKind : ndimNative.kind = .fn (.native (.ffi .symbol) [.str NdimCall.nativeName,.obj ndimTypes,.str ndimReturns])
  shapeNativeRead : source.heap.get shapeFn = some (.obj shapeNative)
  shapeNativeKind : shapeNative.kind = .fn (.native (.ffi .symbol) [.str nativeName,.obj shapeTypes,.str shapeReturns])
  ndimSignatureRead : source.heap.get ndimTypes = some (.obj ndimSignature)
  ndimSignatureKind : ndimSignature.kind = .array [.str chars!"u64"]
  shapeSignatureRead : source.heap.get shapeTypes = some (.obj shapeSignature)
  shapeSignatureKind : shapeSignature.kind = .array [.str chars!"u64"]
  sourceNode : source.ffi.mlx.node? handle = some node
  sourceProducer : source.ffi.mlx.arrs.get handle = some producer
  nonzero : F64.test .eq (F64.ofInt (Int.ofNat (len node.shape))) (F64.ofNat 0) = false
  rankNonzero : len node.shape ≠ 0
  countIndex : F64.toIndex? (byteCount (len node.shape)) = some (len node.shape*4)
  typedLookup : lookupEnv typedName shapeEnv = none
  typedProperty : findProp (.str typedName) global.props = some (.data (.obj typedFn) tw te)
  bufferLookup : lookupEnv bufferName shapeEnv = some bufferCell
  bufferRead : source.heap.get bufferCell = some (.cell (some (.obj bufferFn)))
  bufferFnRead : source.heap.get bufferFn = some (.obj bufferObject)
  bufferKind : bufferObject.kind = .fn (.native (.ffi .toArrayBuffer) bufferData)
  typedRead : source.heap.get typedFn = some (.obj typedObject)
  typedKind : typedObject.kind = .fn (.native (.buf .typedCtor) [.num (.lit kindValue),.num (.lit protoValue)])
  kindIndex : F64.toIndex? kindValue = some 4
  protoIndex : F64.toIndex? protoValue = some typedProto

structure Current {source : St Host.Load.LSt} (data : Source source) (notes : RetainedNotes)
    (live framed : Nat → Prop) (R : Ren) (H : Nat → Prop) where
  globalLive : live aGlobal
  moduleCellLive : live data.moduleCell
  moduleLive : live data.module
  ownerLive : live data.owner
  ndimGetterLive : live data.ndimGetter
  getterLive : live data.getter
  numberLive : live data.numberFn
  ndimLive : live data.ndimFn
  shapeLive : live data.shapeFn
  ndimTypesLive : live data.ndimTypes
  shapeTypesLive : live data.shapeTypes
  bufferCellLive : live data.bufferCell
  bufferFnLive : live data.bufferFn
  typedFnLive : live data.typedFn
  globalFixed : R.a aGlobal = aGlobal
  ndimFrame : ¬ framed data.ndimTypes
  shapeFrame : ¬ framed data.shapeTypes
  owned : H data.handle
  region : R.region (4*data.handle) = 4*R.handle data.handle
  fieldNote : notes.privates.owners data.owner = some ⟨data.brand,data.field,.handle data.handle⟩
  constructor : NativeCaptureNote
  capture : notes.captures.owners data.typedFn = some constructor
  codeNote : constructor.roles 0 = some (.literal (.lit data.kindValue))
  protoNote : constructor.roles 1 = some (.literal (.lit data.protoValue))
  arrayLive : live aArrayProto
  arrayFixed : R.a aArrayProto = aArrayProto
  bufferLive : live aArrayBufferProto
  bufferFixed : R.a aArrayBufferProto = aArrayBufferProto
  typedLive : live data.typedProto
  typedFixed : R.a data.typedProto = data.typedProto
  controlNote : notes.runtime.control = callNote (.obj data.shapeGetter) (.obj data.owner) []

namespace Source
variable {source : St Host.Load.LSt}
def s7 (d : Source source) := entry source d.shapeEnv d.shapeHome d.owner d.ndimGetter
def env (d : Source source) := bodyEnv source d.shapeEnv d.shapeHome d.owner
def rankCell (d : Source source) := (closure source d.shapeEnv d.shapeHome d.owner).next
def pointerCell (d : Source source) := d.rankCell+1
def s46 (d : Source source) := NdimCall.callResult d.s7 d.ndimEnv d.ndimHome d.owner d.getName d.getEnv d.getHome
  d.disposed d.field d.yes d.numberFn d.ndimFn d.module d.getter d.handle (len d.node.shape)
def s57 (d : Source source) := guardResult d.s46 d.rankCell (len d.node.shape) d.env (.s (.scope [])::.k (.fn .call)::source.stack)
def s66 (d : Source source) := nativeInput d.s57 d.env d.shapeFn d.module d.owner d.getter (.s (.scope [])::.k (.fn .call)::source.stack)
def result (d : Source source) := bodyResult d.s66 d.getName d.getEnv d.getHome d.owner d.disposed d.field d.yes
  d.shapeFn d.module d.handle d.pointerCell d.typedFn d.bufferFn d.typedProto d.node d.env source.stack
def live7 (d : Source source) (live : Nat → Prop) := entryLive live source d.shapeEnv d.shapeHome d.owner
def live46 (d : Source source) (live : Nat → Prop) := NdimCall.callLive (d.live7 live) d.s7 d.ndimEnv d.ndimHome d.owner
  d.getName d.getEnv d.getHome d.disposed d.field d.yes d.numberFn d.ndimFn d.module d.getter
def liveResult (d : Source source) (live : Nat → Prop) :=
  let handledLive := NdimCall.bodyLive (d.live46 live) d.s66.next d.getName d.getEnv d.getHome d.owner d.disposed d.field d.yes d.s66
  let pointed := bodyPointer d.s66 d.getName d.getEnv d.getHome d.owner d.disposed d.field d.yes d.shapeFn d.module d.handle
  tailLive handledLive pointed.next
def notes7 (d : Source source) (notes : RetainedNotes) := entryNotes notes source d.shapeEnv d.shapeHome d.owner d.ndimGetter
def notes46 (d : Source source) (notes : RetainedNotes) := NdimCall.callNotes (d.notes7 notes) d.s7 d.ndimEnv d.ndimHome d.owner
  d.numberFn d.ndimFn d.module d.getter (len d.node.shape)
def notes57 (d : Source source) (notes : RetainedNotes) := guardNotes (d.notes46 notes) d.rankCell (len d.node.shape) d.env
  (emptyScopeNote::callBoundaryNote::notes.runtime.stack)
def notes66 (d : Source source) (notes : RetainedNotes) := nativeNotes (d.notes57 notes) d.env d.shapeFn d.module d.owner d.getter
  (emptyScopeNote::callBoundaryNote::notes.runtime.stack)
def notesResult (d : Source source) (notes : RetainedNotes) (nodes : Nat → GraphNode) :=
  let pointed := bodyPointer d.s66 d.getName d.getEnv d.getHome d.owner d.disposed d.field d.yes d.shapeFn d.module d.handle
  bodyNotes (d.notes66 notes) d.s66.next pointed.next d.owner d.handle d.pointerCell (len d.node.shape) d.typedFn d.bufferFn
    (nodes d.producer).shape.valueRoles d.env emptyScopeNote callBoundaryNote notes.runtime.stack
end Source

end ShapeCall

/-- Complete nonzero-rank call of the pinned MlxArray.shape getter. All 115
original transitions and every buffer, view, lexical cell and result element
are derived from current source facts and the strong native graph relation. -/
theorem RetainedInventory.shape_call_block
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {nodes : Nat → GraphNode} {boundary : Nat → Prop} {objects : Nat → Object}
    {roots H N : Nat → Prop} {tokens : List NumV} {host : Host.Load.HostSt → Host.Load.HostSt → Prop}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {source target : St Host.Load.LSt}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tokens host)
      R live framed before after old old' source target)
    (policy : ProducerAnnotations roots H N nodes objects)
    (d : ShapeCall.Source source) (current : ShapeCall.Current d notes live framed R H)
    (sourceBound : source.next+13 ≤ 2^64) (targetBound : target.next+13 ≤ 2^64) :
    ∃ result, runC Host.Load.ffi 115 source C₀ = some (d.result,C₀) ∧ runC Host.Load.ffi 115 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tokens host)
        R (d.liveResult live) framed before after old old' d.result result ∧
      RetainedInventory (d.notesResult notes nodes) ν₀ ν C₀ C R (d.liveResult live) d.result result ∧
      result.ffi = target.ffi ∧ result.next ≤ target.next+13 ∧
      ProducerAnnotations roots H N nodes objects ∧ ProducerSupport roots H N d.result.ffi.mlx ∧
      ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i)) (resourceImage R.handle H) (resourceImage R.node N) result.ffi.mlx := by
  let F := Host.Load.ffi
  let FR := VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tokens host
  have source4 : source.next+4 ≤ 2^64 := by omega
  have target4 : target.next+4 ≤ 2^64 := by omega
  have firstNext : d.s7.next ≤ source.next+4 := ShapeCall.entry_counter_le source d.shapeEnv d.shapeHome d.owner d.ndimGetter
  have firstExact : d.s7.next = d.rankCell+2 := ShapeCall.entry_next source d.shapeEnv d.shapeHome d.owner d.ndimGetter
  have rankAbove : source.next < d.rankCell := ShapeCall.closure_counter_gt source d.shapeEnv d.shapeHome d.owner
  have below7 : source.next < d.s7.next := by omega
  have rankBelow7 : d.rankCell < d.s7.next := by omega
  have pointerBelow7 : d.pointerCell < d.s7.next := by change d.rankCell+1 < d.s7.next; omega
  have grow7 : ∀ a, live a → d.live7 live a := by
    intro a alive
    exact CellsLive.grow _ _ _ a (ClosureLive.grow _ _ _ _ _ a alive)
  have rankLive7 : d.live7 live d.rankCell := Or.inl (Or.inr rfl)
  have pointerLive7 : d.live7 live d.pointerCell := Or.inr rfl
  have frame7 : ∀ a, live a → d.s7.heap.get a = source.heap.get a := fun a alive =>
    ShapeCall.entry_heap_below source d.shapeEnv d.shapeHome d.owner d.ndimGetter source4 a (state.heap.sourceBound a alive)
  obtain ⟨s7,l7,r7,h7,inv7,ffi7,next7,_⟩ := ShapeCall.entry_block (F:=F) inventory state
    d.shapeGetter d.owner d.ndimGetter d.shapeObject d.shapeEnv d.shapeHome d.ndimSetter d.nge
    d.control d.shapeRead d.shapeKind d.ndimPath current.ownerLive current.controlNote source4 target4
  obtain ⟨s46,l46,r46,h46,inv46,ffi46,next46,_,_,_,_⟩ := inv7.ndim_call_block h7 policy
    d.ndimGetter d.owner d.getter d.brand d.numberFn d.ndimFn d.moduleCell d.module d.ndimTypes d.handle
    d.ndimObject d.getterObject d.object d.global d.numberObject d.ndimNative d.ndimSignature
    d.ndimEnv d.getEnv d.ndimHome d.getHome d.getName d.disposed d.field d.yes
    d.nw d.ne d.nmw d.nme d.hge d.dw d.de d.hw d.he d.handleSetter d.ndimReturns d.numberData d.node
    rfl ((frame7 d.ndimGetter current.ndimGetterLive).trans d.ndimRead) d.ndimKind d.numberLookup
    ((frame7 aGlobal current.globalLive).trans d.globalRead) d.globalKind d.numberProperty
    d.ndimModuleLookup ((frame7 d.moduleCell current.moduleCellLive).trans d.moduleRead)
    (by refine OrdinaryLookup.frame_live state.heap ?_ d.ndimNativePath current.moduleLive; intro a alive; exact frame7 a alive)
    (by refine OrdinaryLookup.frame_live state.heap ?_ d.getterPath current.ownerLive; intro a alive; exact frame7 a alive)
    ((frame7 d.getter current.getterLive).trans d.getterRead) d.getterKind
    ((frame7 d.owner current.ownerLive).trans d.objectRead) d.ordinary d.disposedValue d.handleValue d.disposedLookup d.handleLookup d.disposedNames d.handleNames
    ((frame7 d.numberFn current.numberLive).trans d.numberRead) d.numberKind
    ((frame7 d.ndimFn current.ndimLive).trans d.ndimNativeRead) d.ndimNativeKind
    ((frame7 d.ndimTypes current.ndimTypesLive).trans d.ndimSignatureRead) d.ndimSignatureKind
    (grow7 aGlobal current.globalLive) (grow7 d.moduleCell current.moduleCellLive) (grow7 d.module current.moduleLive)
    (grow7 d.owner current.ownerLive) (grow7 d.getter current.getterLive) (grow7 d.numberFn current.numberLive)
    (grow7 d.ndimFn current.ndimLive) (grow7 d.ndimTypes current.ndimTypesLive) current.globalFixed current.ndimFrame current.owned
    (by change d.s7.ffi.mlx.node? d.handle = _; exact (congrArg (fun native : Host.Load.LSt => native.mlx.node? d.handle)
      (ShapeCall.entry_native source d.shapeEnv d.shapeHome d.owner d.ndimGetter)).trans d.sourceNode)
    current.fieldNote rfl (by change d.s7.next+4 ≤ 2^64; omega) (by omega)
  have grow46 : ∀ a, d.live7 live a → d.live46 live a := by
    intro a alive
    exact CellsLive.grow _ _ _ a (ClosureLive.grow _ _ _ _ _ a
      (CellsLive.grow _ _ _ a (ClosureLive.grow _ _ _ _ _ a alive)))
  have grow : ∀ a, live a → d.live46 live a := fun a alive => grow46 a (grow7 a alive)
  have rankLive46 := grow46 d.rankCell rankLive7
  have pointerLive46 := grow46 d.pointerCell pointerLive7
  have secondNext : d.s46.next ≤ d.s7.next+4 := ShapeCall.ndim_counter_le d.s7 d.ndimEnv d.ndimHome d.owner d.getName d.getEnv d.getHome d.disposed d.field d.yes
    d.numberFn d.ndimFn d.module d.getter d.handle (len d.node.shape)
  have sourceBudget46 : d.s46.next+5 ≤ 2^64 := by omega
  have targetBudget46 : s46.next+5 ≤ 2^64 := by omega
  have frame46 : ∀ a, a < d.s7.next → d.s46.heap.get a = d.s7.heap.get a :=
    ShapeCall.ndim_heap_below d.s7 d.ndimEnv d.ndimHome d.owner d.getName d.getEnv d.getHome d.disposed d.field d.yes
      d.numberFn d.ndimFn d.module d.getter d.handle (len d.node.shape) (by omega)
  obtain ⟨s57,l57,r57,h57,inv57,ffi57,next57⟩ := ShapeCall.rank_binding_nonzero_block (F:=F) inv46 h46 d.rankCell (len d.node.shape)
    d.env (.s (.scope [])::.k (.fn .call)::source.stack)
    ((statementFrameNotes d.env (.declarationInit .const (.id ShapeCall.rankName) ShapeCall.ndimExpression [])).headD callBoundaryNote)
    (blockFrameNote [ShapeCall.guard,ShapeCall.pointerDeclaration,ShapeCall.returnStatement] d.env)
    (emptyScopeNote::callBoundaryNote::notes.runtime.stack) rfl rfl
    (ShapeCall.entry_environment_rank source d.shapeEnv d.shapeHome d.owner)
    ((frame46 d.rankCell rankBelow7).trans (ShapeCall.entry_rank_cell source d.shapeEnv d.shapeHome d.owner d.ndimGetter source4))
    rankLive46 rfl rfl d.nonzero (by change d.s46.next ≤ 2^64; omega) (by omega)
  have rankWord : d.rankCell < 2^64 := by omega
  have frame57entry : ∀ a, a < d.s7.next → a ≠ d.rankCell → d.s57.heap.get a = d.s7.heap.get a := by
    intro a below different
    change (d.s46.heap.set d.rankCell (.cell (some (intV (Int.ofNat (len d.node.shape)))))).get a = _
    rw [PTrie.get_set_u64 _ _ _ rankWord]
    simp only [different,ite_false]
    exact frame46 a below
  have frame57 : ∀ a, live a → d.s57.heap.get a = source.heap.get a := by
    intro a alive
    have below := state.heap.sourceBound a alive
    exact (frame57entry a (Nat.lt_trans below below7) (by omega)).trans (frame7 a alive)
  have this46 : (d.notes46 notes).runtime.cells.cells source.next = some (.obj d.owner) := by
    exact (ShapeCall.ndim_notes_below (d.notes7 notes) d.s7 d.ndimEnv d.ndimHome d.owner d.numberFn d.ndimFn d.module d.getter (len d.node.shape) source.next below7).trans
      (by change (notes.runtime.cells.write source.next (.obj d.owner)).cells source.next = _; simp only [Notes.write,ite_true])
  have this57 : (d.notes57 notes).runtime.cells.cells source.next = some (.obj d.owner) := by
    change ((d.notes46 notes).runtime.cells.write d.rankCell (ShapeCall.rankRole (len d.node.shape))).cells source.next = _
    have different : source.next ≠ d.rankCell := Nat.ne_of_lt rankAbove
    simpa only [Notes.write,different,ite_false] using this46
  obtain ⟨s66,l66,r66,h66,inv66,heap66,ffi66,next66⟩ := ShapeCall.native_entry_block (F:=F) inv57 h57 d.env d.moduleCell d.module d.shapeFn source.next d.owner d.getter
    d.smw d.sme d.hge d.handleSetter (.s (.scope [])::.k (.fn .call)::source.stack)
    (blockFrameNote [ShapeCall.pointerDeclaration,ShapeCall.returnStatement] d.env)
    (emptyScopeNote::callBoundaryNote::notes.runtime.stack) rfl rfl
    ((ShapeCall.entry_environment_other source d.shapeEnv d.shapeHome d.owner NdimCall.nativeModule (by decide +kernel) (by decide +kernel) (by decide +kernel) (by decide +kernel)).trans d.shapeModuleLookup)
    ((frame57 d.moduleCell current.moduleCellLive).trans d.moduleRead)
    (by refine OrdinaryLookup.frame_live state.heap ?_ d.shapeNativePath current.moduleLive; intro a alive; exact frame57 a alive)
    (ShapeCall.entry_environment_this source d.shapeEnv d.shapeHome d.owner)
    ((frame57entry source.next below7 (Nat.ne_of_lt rankAbove)).trans (ShapeCall.entry_receiver source d.shapeEnv d.shapeHome d.owner d.ndimGetter source4)) this57
    (by refine OrdinaryLookup.frame_live state.heap ?_ d.getterPath current.ownerLive; intro a alive; exact frame57 a alive) rfl
  have native46 : d.s46.ffi = source.ffi :=
    (NdimCall.call_result_native d.s7 d.ndimEnv d.ndimHome d.owner d.getName d.getEnv d.getHome d.disposed d.field d.yes
      d.numberFn d.ndimFn d.module d.getter d.handle (len d.node.shape)).trans (ShapeCall.entry_native source d.shapeEnv d.shapeHome d.owner d.ndimGetter)
  have rankRead66 : d.s66.heap.get d.rankCell = some (.cell (some (intV (Int.ofNat (len d.node.shape))))) := by
    change (d.s46.heap.set d.rankCell (.cell (some (intV (Int.ofNat (len d.node.shape)))))).get d.rankCell = _
    rw [PTrie.get_set_u64 _ _ _ rankWord]
    simp only [ite_true]
  have pointerRead66 : d.s66.heap.get d.pointerCell = some (.cell none) :=
    (frame57entry d.pointerCell pointerBelow7 (by change d.rankCell+1 ≠ d.rankCell; omega)).trans
      (ShapeCall.entry_pointer_cell source d.shapeEnv d.shapeHome d.owner d.ndimGetter source4)
  obtain ⟨result,l115,r115,h115,inv115,ffi115,next115,_,support115,targetSupport115⟩ := ShapeCall.getter_readback_return inv66 h66 policy
    d.getter d.owner d.brand d.shapeFn d.module d.shapeTypes d.handle d.producer d.pointerCell d.rankCell d.typedFn d.bufferCell d.bufferFn d.typedProto
    d.getterObject d.object d.shapeNative d.shapeSignature d.global d.bufferObject d.typedObject d.getName d.getEnv d.getHome d.disposed d.field d.yes
    d.dw d.de d.hw d.he d.tw d.te d.shapeReturns d.bufferData current.constructor d.kindValue d.protoValue d.node d.env source.stack
    (ShapeCall.pointerDeclNote d.env) (blockFrameNote [ShapeCall.returnStatement] d.env) emptyScopeNote callBoundaryNote notes.runtime.stack rfl rfl
    ((frame57 d.getter current.getterLive).trans d.getterRead) d.getterKind ((frame57 d.owner current.ownerLive).trans d.objectRead)
    d.ordinary d.disposedValue d.handleValue d.disposedLookup d.handleLookup d.disposedNames d.handleNames current.fieldNote
    ((frame57 d.shapeFn current.shapeLive).trans d.shapeNativeRead) d.shapeNativeKind
    ((frame57 d.shapeTypes current.shapeTypesLive).trans d.shapeSignatureRead) d.shapeSignatureKind current.shapeFrame
    ((congrArg (fun native : Host.Load.LSt => native.mlx.node? d.handle) native46).trans d.sourceNode)
    ((congrArg (fun native : Host.Load.LSt => native.mlx.arrs.get d.handle) native46).trans d.sourceProducer) current.owned current.region
    (ShapeCall.entry_environment_pointer source d.shapeEnv d.shapeHome d.owner) pointerRead66
    (ShapeCall.entry_environment_rank source d.shapeEnv d.shapeHome d.owner) rankRead66
    (by change ((d.notes46 notes).runtime.cells.write d.rankCell (ShapeCall.rankRole (len d.node.shape))).cells d.rankCell = _; simp only [Notes.write,ite_true])
    ((ShapeCall.entry_environment_other source d.shapeEnv d.shapeHome d.owner ShapeCall.typedName (by decide +kernel) (by decide +kernel) (by decide +kernel) (by decide +kernel)).trans d.typedLookup)
    ((frame57 aGlobal current.globalLive).trans d.globalRead) d.globalKind d.typedProperty
    ((ShapeCall.entry_environment_other source d.shapeEnv d.shapeHome d.owner ShapeCall.bufferName (by decide +kernel) (by decide +kernel) (by decide +kernel) (by decide +kernel)).trans d.bufferLookup)
    ((frame57 d.bufferCell current.bufferCellLive).trans d.bufferRead) ((frame57 d.bufferFn current.bufferFnLive).trans d.bufferFnRead) d.bufferKind
    ((frame57 d.typedFn current.typedFnLive).trans d.typedRead) d.typedKind d.kindIndex d.protoIndex d.countIndex current.capture current.codeNote current.protoNote
    pointerLive46 rankLive46 (grow d.shapeFn current.shapeLive) (grow d.shapeTypes current.shapeTypesLive) (grow d.bufferFn current.bufferFnLive)
    (grow d.typedFn current.typedFnLive) (grow d.bufferCell current.bufferCellLive) (grow aGlobal current.globalLive) current.globalFixed
    (grow aArrayProto current.arrayLive) current.arrayFixed (grow aArrayBufferProto current.bufferLive) current.bufferFixed (grow d.typedProto current.typedLive) current.typedFixed
    rfl rfl (by exact sourceBudget46) (by rw [next66,next57]; exact targetBudget46)
  refine ⟨result,runC_join F (runC_join F (runC_join F (runC_join F l7 l46) l57) l66) l115,
    runC_join F (runC_join F (runC_join F (runC_join F r7 r46) r57) r66) r115,h115,inv115,
    ffi115.trans (ffi66.trans (ffi57.trans (ffi46.trans ffi7))),?_,policy,support115,targetSupport115⟩
  rw [next66,next57] at next115
  omega

end Host.Ts.Owned.Annotated

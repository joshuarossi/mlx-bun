import host.ts.RenameRetainedShapeCallReadback
import host.mlx.NativeShapeCallTail

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Owned.Annotated
open Parametric Host.Load.Run.Full.Ordinary Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
namespace ShapeCall

def bodyPointer (source : St Host.Load.LSt) (name : Option Name) (getEnv : Env) (getHome : Val)
    (owner : Nat) (disposed field : Name) (yes : Stmt) (nativeFn module handle : Nat) : St Host.Load.LSt :=
  let handled := NdimCall.allocatedGetter source name getEnv getHome owner disposed field yes (.big (Int.ofNat handle))
  let input := {handled with ctl := .call (.obj nativeFn) (.obj module) [.big (Int.ofNat handle)],stack := source.stack.tail}
  finishPointer input source.ffi nativeName [.big (Int.ofNat handle)] (4*handle) 0
def bodyResult (source : St Host.Load.LSt) (name : Option Name) (getEnv : Env) (getHome : Val)
    (owner : Nat) (disposed field : Name) (yes : Stmt) (nativeFn module handle pointerCell typedFn bufferFn typedProto : Nat)
    (node : Host.Mlx.Ffi.Node) (env : Env) (caller : List Frame) : St Host.Load.LSt :=
  let pointer := bodyPointer source name getEnv getHome owner disposed field yes nativeFn module handle
  let ready := readbackResult pointer pointerCell handle (len node.shape) typedFn bufferFn env (.s (.scope [])::.k (.fn .call)::caller)
  tailResult ready handle node typedProto caller
def bodyPointerNotes (notes : RetainedNotes) (start owner handle : Nat) : RetainedNotes :=
  notes.withRuntime ⟨returnNote (.ptr (.ext (4*handle)) 0),notes.runtime.stack.tail,
    notes.runtime.cells.write start (.obj owner)⟩
def bodyNotes (notes : RetainedNotes) (start fresh owner handle pointerCell rank typedFn bufferFn : Nat)
    (elements : List Value) (env : Env) (scopeNote boundaryNote : Tree) (caller : List Tree) : RetainedNotes :=
  let pointed := bodyPointerNotes notes start owner handle
  let ready := readbackNotes pointed pointerCell handle rank typedFn bufferFn env (scopeNote::boundaryNote::caller)
  tailNotes ready fresh elements caller

/-- The nonzero shape suffix performs the real guarded handle getter, native
shape-pointer call, pointer binding, constructor readback and native-node spread
in 49 original transitions. Current rank and native shape agree at entry. -/
theorem getter_readback_return
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
    (getter owner brand nativeFn module types handle producer pointerCell rankCell typedFn bufferCell bufferFn typedProto : Nat)
    (getterObject object nativeObject signatureObject global bufferObject typedObject : Obj)
    (name : Option Name) (getEnv : Env) (getHome : Val) (disposed field : Name) (yes : Stmt)
    (dw de hw he tw te : Bool) (returns : Name) (bufferData : List Val) (constructor : NativeCaptureNote)
    (kindValue protoValue : F64) (node : Host.Mlx.Ffi.Node) (env : Env) (caller : List Frame)
    (declarationNote blockNote scopeNote boundaryNote : Tree) (callerNotes : List Tree)
    (control : source.ctl = .call (.obj getter) (.obj owner) [])
    (stack : source.stack = .c (.args 0 (.obj nativeFn) (.obj module) [] [] env)::
      .s (.decl .const (.id pointerName) [] env)::.s (.block [returnStatement] env)::.s (.scope [])::.k (.fn .call)::caller)
    (getterRead : source.heap.get getter = some (.obj getterObject))
    (getterKind : getterObject.kind = .fn (.closure (getterFunction name disposed field yes) getEnv false getHome))
    (objectRead : source.heap.get owner = some (.obj object)) (ordinary : object.kind = .ordinary)
    (disposedValue : findPriv brand disposed object.priv = some (.data (.bool false) dw de))
    (handleValue : findPriv brand field object.priv = some (.data (.big (Int.ofNat handle)) hw he))
    (disposedLookup : lookupEnv (privName disposed) getEnv = some brand)
    (handleLookup : lookupEnv (privName field) getEnv = some brand)
    (disposedNames : nameEq (privName disposed) nThis = false ∧ nameEq (privName disposed) nHome = false)
    (handleNames : nameEq (privName field) nThis = false ∧ nameEq (privName field) nHome = false)
    (fieldNote : notes.privates.owners owner = some ⟨brand,field,.handle handle⟩)
    (nativeRead : source.heap.get nativeFn = some (.obj nativeObject))
    (nativeKind : nativeObject.kind = .fn (.native (.ffi .symbol) [.str nativeName,.obj types,.str returns]))
    (signatureRead : source.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array [.str chars!"u64"]) (signatureFrame : ¬ framed types)
    (nodeRead : source.ffi.mlx.node? handle = some node) (producerRead : source.ffi.mlx.arrs.get handle = some producer)
    (owned : H handle) (region : R.region (4*handle) = 4*R.handle handle)
    (pointerLookup : lookupEnv pointerName env = some pointerCell) (pointerRead : source.heap.get pointerCell = some (.cell none))
    (rankLookup : lookupEnv rankName env = some rankCell) (rankRead : source.heap.get rankCell = some (.cell (some (intV (Int.ofNat (len node.shape))))))
    (rankNote : notes.runtime.cells.cells rankCell = some (rankRole (len node.shape)))
    (typedLookup : lookupEnv typedName env = none) (globalRead : source.heap.get aGlobal = some (.obj global))
    (globalKind : global.kind = .ordinary) (typedProperty : findProp (.str typedName) global.props = some (.data (.obj typedFn) tw te))
    (bufferLookup : lookupEnv bufferName env = some bufferCell) (bufferRead : source.heap.get bufferCell = some (.cell (some (.obj bufferFn))))
    (bufferFnRead : source.heap.get bufferFn = some (.obj bufferObject))
    (bufferKind : bufferObject.kind = .fn (.native (.ffi .toArrayBuffer) bufferData))
    (typedRead : source.heap.get typedFn = some (.obj typedObject))
    (typedKind : typedObject.kind = .fn (.native (.buf .typedCtor) [.num (.lit kindValue),.num (.lit protoValue)]))
    (kindIndex : F64.toIndex? kindValue = some 4) (protoIndex : F64.toIndex? protoValue = some typedProto)
    (countIndex : F64.toIndex? (byteCount (len node.shape)) = some (len node.shape*4))
    (capture : notes.captures.owners typedFn = some constructor)
    (codeNote : constructor.roles 0 = some (.literal (.lit kindValue)))
    (protoNote : constructor.roles 1 = some (.literal (.lit protoValue)))
    (pointerLive : live pointerCell) (rankLive : live rankCell) (nativeLive : live nativeFn) (typesLive : live types)
    (bufferFnLive : live bufferFn) (typedFnLive : live typedFn) (bufferCellLive : live bufferCell)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live typedProto) (typedFixed : R.a typedProto = typedProto)
    (controlNote : notes.runtime.control = callNote (.obj getter) (.obj owner) [])
    (stackNotes : notes.runtime.stack = argumentFrameNote false 0 (.obj nativeFn) (.obj module) [] [] env::
      declarationNote::blockNote::scopeNote::boundaryNote::callerNotes)
    (sourceBound : source.next+5 ≤ 2^64) (targetBound : target.next+5 ≤ 2^64) :
    let reachedLive := NdimCall.bodyLive live source.next name getEnv getHome owner disposed field yes source
    let pointed := bodyPointer source name getEnv getHome owner disposed field yes nativeFn module handle
    let reached := bodyResult source name getEnv getHome owner disposed field yes nativeFn module handle pointerCell typedFn bufferFn typedProto node env caller
    ∃ result, runC Host.Load.ffi 49 source C₀ = some (reached,C₀) ∧ runC Host.Load.ffi 49 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tokens host)
        R (tailLive reachedLive pointed.next) framed before after old old' reached result ∧
      RetainedInventory (bodyNotes notes source.next pointed.next owner handle pointerCell (len node.shape) typedFn bufferFn
        (nodes producer).shape.valueRoles env scopeNote boundaryNote callerNotes) ν₀ ν C₀ C R
        (tailLive reachedLive pointed.next) reached result ∧ result.ffi = target.ffi ∧ result.next ≤ target.next+5 ∧
      ProducerAnnotations roots H N nodes objects ∧ ProducerSupport roots H N reached.ffi.mlx ∧
      ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i)) (resourceImage R.handle H) (resourceImage R.node N) result.ffi.mlx := by
  let F := Host.Load.ffi
  let FR := VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tokens host
  let handled := NdimCall.allocatedGetter source name getEnv getHome owner disposed field yes (.big (Int.ofNat handle))
  have sourceBound2 : source.next+2 ≤ 2^64 := by omega
  have targetBound2 : target.next+2 ≤ 2^64 := by omega
  have frame := NdimCall.getter_heap_below source name getEnv getHome owner disposed field yes (.big (Int.ofNat handle)) sourceBound2
  have sourceEq := NdimCall.allocatedGetter_eq source name getEnv getHome owner disposed field yes (.big (Int.ofNat handle))
  have readFrame : ∀ a, live a → handled.heap.get a = source.heap.get a := by
    intro a alive
    exact (congrArg (fun s : St Host.Load.LSt => s.heap.get a) sourceEq).symm.trans (frame a (state.heap.sourceBound a alive))
  obtain ⟨s17,l17,r17,h17,inv17,ffi17,next17,heap17⟩ := inventory.getter_call_block (F:=F) state
    getter owner brand getterObject object name getEnv getHome disposed field yes (.big (Int.ofNat handle)) (.handle handle)
    dw de hw he control getterRead getterKind objectRead ordinary disposedValue handleValue disposedLookup handleLookup disposedNames handleNames
    fieldNote controlNote sourceBound2 targetBound2
  have l17 := l17.trans (congrArg (fun s : St Host.Load.LSt => some (s,C₀)) sourceEq)
  let atHandled := fun s : St Host.Load.LSt => Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R
    (NdimCall.bodyLive live source.next name getEnv getHome owner disposed field yes source) framed before after old old' s s17
  have h17 : atHandled handled := Eq.mp (congrArg atHandled sourceEq) h17
  let retainedAt := fun s : St Host.Load.LSt => RetainedInventory (getterCallNotes notes source.next owner (.handle handle)) ν₀ ν C₀ C R
    (NdimCall.bodyLive live source.next name getEnv getHome owner disposed field yes source) s s17
  have inv17 : retainedAt handled := Eq.mp (congrArg retainedAt sourceEq) inv17
  dsimp only [atHandled] at h17
  dsimp only [retainedAt] at inv17
  obtain ⟨_,_,_,_,_,l18,r18,h18,runtime18⟩ := inv17.runtime.argument_step F FR _ ν₀ ν C₀ C R _ framed before after old old'
    _ _ h17 (.big (Int.ofNat handle)) (.handle handle) (.obj nativeFn) (.obj module) [] 0 (.obj nativeFn) (.obj module) [] [] env
    (.s (.decl .const (.id pointerName) [] env)::.s (.block [returnStatement] env)::.s (.scope [])::.k (.fn .call)::caller)
    (declarationNote::blockNote::scopeNote::boundaryNote::callerNotes) rfl (by exact stack) (by decide) rfl stackNotes
  have inv18 := inv17.heap_step runtime18 rfl rfl (.refl C₀) (.refl C)
  have handledNode : handled.ffi.mlx.node? handle = some node := by
    change (NdimCall.allocatedGetter source name getEnv getHome owner disposed field yes (.big (Int.ofNat handle))).ffi.mlx.node? handle = _
    rw [←NdimCall.allocatedGetter_eq,NdimCall.getter_native]; exact nodeRead
  obtain ⟨l19,r19,h19,inv19⟩ := MetadataInventory.retained_shape_from_source ν₀ ν C₀ C R nodes boundary objects H N tokens host
    _ framed before after old old' _ _ h18 inv18 nativeFn types handle nativeObject signatureObject returns (.obj module) node
    rfl ((readFrame nativeFn nativeLive).trans nativeRead) nativeKind ((readFrame types typesLive).trans signatureRead) signatureKind
    signatureFrame owned handledNode region (.obj nativeFn) (.obj module) rfl
  have grow : ∀ a, live a → NdimCall.bodyLive live source.next name getEnv getHome owner disposed field yes source a := by
    intro a alive
    exact CellsLive.grow _ _ _ a (ClosureLive.grow _ _ _ _ _ a alive)
  have readbackBound : handled.next+3 ≤ 2^64 := by
    have room : handled.next ≤ source.next+2 := by
      cases getHome <;> first
        | change source.next+1 ≤ source.next+2; omega
        | change source.next+1+1 ≤ source.next+2; omega
    omega
  have targetReadbackBound : s17.next+3 ≤ 2^64 := by omega
  have readback := ShapeCall.pointer_readback_block (F:=F) inv19 h19 pointerCell rankCell handle (len node.shape)
    typedFn bufferCell bufferFn global tw te env (.s (.scope [])::.k (.fn .call)::caller) declarationNote blockNote (scopeNote::boundaryNote::callerNotes)
    rfl rfl pointerLookup ((readFrame pointerCell pointerLive).trans pointerRead) (grow pointerCell pointerLive)
    rankLookup ((readFrame rankCell rankLive).trans rankRead) (by
      change (notes.runtime.cells.write source.next (.obj owner)).cells rankCell = _
      simpa only [Notes.write,Nat.ne_of_lt (state.heap.sourceBound rankCell rankLive),ite_false] using rankNote)
    typedLookup ((readFrame aGlobal globalLive).trans globalRead)
    globalKind typedProperty bufferLookup ((readFrame bufferCell bufferCellLive).trans bufferRead)
    (grow aGlobal globalLive) globalFixed rfl rfl (by change handled.next ≤ 2^64; omega) (by change s17.next ≤ 2^64; omega)
  obtain ⟨s41,l41,r41,h41,inv41,ffi41,next41⟩ := readback
  have pointerNotBuffer : bufferFn ≠ pointerCell := by intro same; rw [same,pointerRead] at bufferFnRead; cases bufferFnRead
  have pointerNotTyped : typedFn ≠ pointerCell := by intro same; rw [same,pointerRead] at typedRead; cases typedRead
  have pointerWord : pointerCell < 2^64 := Nat.lt_of_lt_of_le (state.heap.sourceBound pointerCell pointerLive) (by omega)
  have readyFrame : ∀ a, a ≠ pointerCell → ((handled.setCell pointerCell (.ptr (.ext (4*handle)) 0)).heap.get a) = handled.heap.get a := by
    intro a different
    rw [St.setCell,PTrie.get_set_u64 _ _ _ pointerWord]
    simp only [different,ite_false]
  have readyNode : (readbackResult (bodyPointer source name getEnv getHome owner disposed field yes nativeFn module handle)
      pointerCell handle (len node.shape) typedFn bufferFn env (.s (.scope [])::.k (.fn .call)::caller)).ffi.mlx.node? handle = some node := by
    exact nodeRead
  have readyProducer : (readbackResult (bodyPointer source name getEnv getHome owner disposed field yes nativeFn module handle)
      pointerCell handle (len node.shape) typedFn bufferFn env (.s (.scope [])::.k (.fn .call)::caller)).ffi.mlx.arrs.get handle = some producer := by
    exact producerRead
  obtain ⟨result,l49,r49,h49,inv49,ffi49,next49,_,policy49,support49,targetSupport49⟩ := inv41.shape_buffer_spread_return h41 policy
    bufferFn typedFn typedProto handle producer bufferObject typedObject bufferData .undef constructor node (byteCount (len node.shape)) kindValue protoValue
    (byteMeaning (len node.shape)) env env caller (.obj bufferFn) .undef (arraySpreadFrameNote [] [] env)
    ((statementFrameNotes env (.returnExpression resultExpression)).headD callBoundaryNote) (blockFrameNote [] env) scopeNote boundaryNote callerNotes
    rfl rfl ((readyFrame bufferFn pointerNotBuffer).trans ((readFrame bufferFn bufferFnLive).trans bufferFnRead)) bufferKind
    ((readyFrame typedFn pointerNotTyped).trans ((readFrame typedFn typedFnLive).trans typedRead)) typedKind kindIndex protoIndex countIndex
    (byteMeaning_closed _) capture codeNote protoNote readyNode readyProducer owned region (grow aArrayProto arrayLive) arrayFixed
    (grow aArrayBufferProto bufferLive) bufferFixed (grow typedProto typedLive) typedFixed rfl rfl readbackBound (by rw [next41]; exact targetReadbackBound)
  have one := fun (s t : St F.S) (C : CSrv) (a : isHalt s.ctl = false)
    (r : interpC (step F s).run C = some (t,C)) => runC_cons F 0 s t t C C C a r rfl
  have sl18 := one _ _ C₀ rfl l18
  have tr18 := one _ _ C (h17.control.isHalt_eq.trans rfl) r18
  have sl19 := one _ _ C₀ rfl l19
  have tr19 := one _ _ C (h18.control.isHalt_eq.trans rfl) r19
  refine ⟨result,runC_join F (runC_join F (runC_join F (runC_join F l17 sl18) sl19) l41) l49,
    runC_join F (runC_join F (runC_join F (runC_join F r17 tr18) tr19) r41) r49,h49,inv49,
    ffi49.trans (ffi41.trans ffi17),?_,policy49,support49,targetSupport49⟩
  rw [next49,next41]
  change s17.next+3 ≤ target.next+5
  omega

end ShapeCall
end Host.Ts.Owned.Annotated

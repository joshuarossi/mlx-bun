import host.mlx.NativeMetadataRetained
import host.mlx.NativeArrayBufferClosedInventory
import host.mlx.NativeTypedBufferInventory
import host.mlx.NativeShapeSpreadInventory
import host.mlx.NativeAnnotationPolicy
import host.ts.RenameRetainedGetterReturn
import host.ts.RenameRetainedNormalize

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Owned.Annotated
open Parametric Host.Load.Run.Full.Ordinary Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
namespace ShapeCall

def tailLive (live : Nat → Prop) (start : Nat) : Nat → Prop :=
  LiveAfter (LiveAfter (LiveAfter live start) (start+1)) (start+1+1)

def tailResult (source : St Host.Load.LSt) (handle : Nat) (node : Host.Mlx.Ffi.Node)
    (typedProto : Nat) (caller : List Frame) : St Host.Load.LSt :=
  let buffer := (source.alloc (externalBuffer (4*handle) 0 (len node.shape*4))).2
  let view := (buffer.alloc (typedBuffer .i32 source.next 0 ((len node.shape*4)/4) typedProto)).2
  let result := (view.alloc (valueArray (node.shape.map (fun d : Host.Mlx.Ffi.Dim => Val.num d.num)))).2
  {result with ctl := .ret (.obj (source.next+1+1)),stack := caller}

def tailNotes (notes : RetainedNotes) (start : Nat) (elements : List Value) (caller : List Tree) : RetainedNotes :=
  { (notes.withRuntime ⟨returnNote (.obj (start+1+1)),caller,notes.runtime.cells⟩) with
    «arrays» := notes.arrays.write (start+1+1) elements }

end ShapeCall

/-- The last eight original nonzero-shape transitions allocate the native
buffer, construct its real i32 view, read all dimensions from the current native
node, allocate the ordinary result array and restore an arbitrary caller. -/
theorem RetainedInventory.shape_buffer_spread_return
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
    (bufferFn typedFn typedProto handle input : Nat) (bufferObject typedObject : Obj)
    (bufferData : List Val) (bufferThis : Val) (constructor : NativeCaptureNote)
    (node : Host.Mlx.Ffi.Node) (count kindValue protoValue : F64) (countMeaning : SymE)
    (env bodyEnv : Env) (caller : List Frame)
    (bufferFnRole bufferThisRole : Value) (spreadNote retNote blockNote scopeNote boundaryNote : Tree)
    (callerNotes : List Tree)
    (control : source.ctl = .call (.obj bufferFn) bufferThis
      [.ptr (.ext (4*handle)) 0,.num (.lit (F64.zero false)),.num (.lit count)])
    (stack : source.stack = .c (.args 1 (.obj typedFn) .undef [] [] env)::
      .l (.spread [] [] env)::.s .ret::.s (.block [] bodyEnv)::.s (.scope [])::.k (.fn .call)::caller)
    (bufferRead : source.heap.get bufferFn = some (.obj bufferObject))
    (bufferKind : bufferObject.kind = .fn (.native (.ffi .toArrayBuffer) bufferData))
    (typedRead : source.heap.get typedFn = some (.obj typedObject))
    (typedKind : typedObject.kind = .fn (.native (.buf .typedCtor) [.num (.lit kindValue),.num (.lit protoValue)]))
    (kindIndex : F64.toIndex? kindValue = some 4) (protoIndex : F64.toIndex? protoValue = some typedProto)
    (countIndex : F64.toIndex? count = some (len node.shape*4))
    (countClosed : ∀ valuation, countMeaning.eval valuation = count)
    (capture : notes.captures.owners typedFn = some constructor)
    (codeNote : constructor.roles 0 = some (.literal (.lit kindValue)))
    (protoNote : constructor.roles 1 = some (.literal (.lit protoValue)))
    (nodeRead : source.ffi.mlx.node? handle = some node) (producer : source.ffi.mlx.arrs.get handle = some input)
    (owned : H handle) (region : R.region (4*handle) = 4*R.handle handle)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live typedProto) (typedFixed : R.a typedProto = typedProto)
    (controlNote : notes.runtime.control = callNote bufferFnRole bufferThisRole
      [.ptr (.ext (4*handle)) 0,.literal (.lit (F64.zero false)),.literal countMeaning])
    (stackNotes : notes.runtime.stack = argumentFrameNote false 1 (.obj typedFn) .undef [] [] env::
      spreadNote::retNote::blockNote::scopeNote::boundaryNote::callerNotes)
    (sourceBound : source.next+3 ≤ 2^64) (targetBound : target.next+3 ≤ 2^64) :
    let reached := ShapeCall.tailResult source handle node typedProto caller
    ∃ result, runC Host.Load.ffi 8 source C₀ = some (reached,C₀) ∧
      runC Host.Load.ffi 8 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tokens host)
        R (ShapeCall.tailLive live source.next) framed before after old old' reached result ∧
      RetainedInventory (ShapeCall.tailNotes notes source.next (nodes input).shape.valueRoles callerNotes)
        ν₀ ν C₀ C R (ShapeCall.tailLive live source.next) reached result ∧
      result.ffi = target.ffi ∧ result.next = target.next+3 ∧
      (∀ a, a < target.next → result.heap.get a = target.heap.get a) ∧
      ProducerAnnotations roots H N nodes objects ∧ ProducerSupport roots H N reached.ffi.mlx ∧
      ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i)) (resourceImage R.handle H) (resourceImage R.node N) result.ffi.mlx := by
  let F := Host.Load.ffi
  let FR := VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tokens host
  let n := len node.shape
  let backing : Obj := ⟨.extBuf (4*handle) 0 (n*4),.obj aArrayBufferProto,[],[],true⟩
  let view : Obj := ⟨.typed .i32 source.next 0 ((n*4)/4),.obj typedProto,[],[],true⟩
  have sourceRoom : source.next < 2^64 := by omega
  have targetRoom : target.next < 2^64 := by omega
  have typedFnLive := inventory.captures.keyLive typedFn constructor capture
  obtain ⟨l1,r1,h1,inv1,frame1,targetFrame1,ffi1,targetFfi1,next1,targetNext1⟩ :=
    inventory.toArrayBuffer_closed_step F FR state bufferFn bufferObject bufferData bufferThis (4*handle) 0 0 (n*4)
      (F64.zero false) count (.lit (F64.zero false)) countMeaning bufferFnRole bufferThisRole (.ptr (.ext (4*handle)) 0)
      control bufferRead bufferKind rfl countIndex controlNote (fun _ => rfl) countClosed bufferLive bufferFixed sourceRoom targetRoom
  have backingRead : ((source.alloc (externalBuffer (4*handle) 0 (n*4))).2.ret (.obj source.next)).heap.get source.next = some (.obj backing) := by
    simp only [St.alloc,St.ret,PTrie.get_set_u64 _ _ _ sourceRoom,ite_true]
    rfl
  have typedRead1 := (frame1 typedFn (state.heap.sourceBound typedFn typedFnLive)).trans typedRead
  obtain ⟨targetValue,targetFn,targetThis,targetAcc,targetArgFrames,l2,r2,h2,runtime2⟩ := inv1.runtime.argument_step F FR _ ν₀ ν C₀ C R _ framed before after old old'
    _ _ h1 (.obj source.next) (.obj source.next) (.obj typedFn) .undef [] 1 (.obj typedFn) .undef [] [] env
    (.l (.spread [] [] env)::.s .ret::.s (.block [] bodyEnv)::.s (.scope [])::.k (.fn .call)::caller)
    (spreadNote::retNote::blockNote::scopeNote::boundaryNote::callerNotes)
    rfl (by exact stack) (by decide) rfl (by exact stackNotes)
  have inv2 := inv1.heap_step runtime2 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨l3,r3,h3,inv3,frame3,targetFrame3,ffi3,targetFfi3,next3,targetNext3⟩ :=
    inv2.typedBuffer_step F FR h2 typedFn source.next typedObject backing (.obj typedFn)
      (4*handle) 0 (n*4) 4 typedProto kindValue protoValue constructor rfl typedRead1 typedKind backingRead rfl kindIndex protoIndex
      capture codeNote protoNote (Or.inl typedLive) typedFixed (by change source.next+1 < 2^64; omega)
      (by change target.next+1 < 2^64; omega)
  have viewRead : ((source.alloc (externalBuffer (4*handle) 0 (n*4))).2.alloc
      (typedBuffer .i32 source.next 0 ((n*4)/4) typedProto)).2.heap.get (source.next+1) = some (.obj view) := by
    change ((source.heap.set source.next (.obj backing)).set (source.next+1) (.obj view)).get (source.next+1) = _
    rw [PTrie.get_set_u64 _ _ _ (by omega)]; simp only [ite_true]
  have backingRead3 := (frame3 source.next (by change source.next < source.next+1; omega)).trans backingRead
  have shapeCount : (n*4)/4 = n := Nat.mul_div_cancel n (by decide)
  obtain ⟨producerIndex,targetNode,targetFrames,producerRead,targetNodeRead,nodeRole,l4,r4,h4,inv4⟩ := inv3.shape_spread_step FR h3
    nodes (ObjectRel objects ν₀ ν C₀ C R) boundary H N tokens h3.native.2
    (source.next+1) source.next handle view backing node env
    (.s .ret::.s (.block [] bodyEnv)::.s (.scope [])::.k (.fn .call)::caller) rfl rfl
    viewRead (by change Kind.typed .i32 source.next 0 ((n*4)/4) = _; rw [shapeCount]) backingRead3 rfl nodeRead owned region
    (Or.inl (Or.inl arrayLive)) arrayFixed (by change source.next+1+1 < 2^64; omega)
    (by change target.next+1+1 < 2^64; omega)
  have sameProducer : producerIndex = input := Option.some.inj (producerRead.symm.trans producer)
  subst producerIndex
  obtain ⟨result,l8,r8,h8,inv8,heap8,ffi8,next8,_⟩ := inv4.getter_return_block (F:=F) h4
    (.obj (source.next+1+1)) (.obj (source.next+1+1)) bodyEnv caller retNote blockNote scopeNote boundaryNote callerNotes
    rfl rfl rfl rfl
  have one := fun (s t : St F.S) (C : CSrv) (a : isHalt s.ctl = false)
    (r : interpC (step F s).run C = some (t,C)) => runC_cons F 0 s t t C C C a r rfl
  have sl1 := one _ _ C₀ (by rw [control]; rfl) l1
  have tr1 := one _ _ C (state.control.isHalt_eq.trans (by rw [control]; rfl)) r1
  have sl2 := one _ _ C₀ rfl l2
  have tr2 := one _ _ C (h1.control.isHalt_eq.trans rfl) r2
  have sl3 := one _ _ C₀ rfl l3
  have tr3 := one _ _ C (h2.control.isHalt_eq.trans rfl) r3
  have sl4 := one _ _ C₀ rfl l4
  have tr4 := one _ _ C (h3.control.isHalt_eq.trans rfl) r4
  have left := runC_join F (runC_join F (runC_join F (runC_join F sl1 sl2) sl3) sl4) l8
  have right := runC_join F (runC_join F (runC_join F (runC_join F tr1 tr2) tr3) tr4) r8
  refine ⟨result,left,right,h8,inv8,?_,?_,?_,policy,policy.source h8.native.2,policy.target h8.native.2⟩
  · exact ffi8.trans (targetFfi3.trans targetFfi1)
  · rw [next8]
    change target.next+1+1+1 = target.next+3
    omega
  · intro a below
    have bound1 : a < target.next+1 := by omega
    have bound3 : a < target.next+1+1 := by omega
    let targetBuffer := (target.alloc (externalBuffer (R.region (4*handle)) 0 (n*4))).2.ret (.obj target.next)
    let targetConstruct := argumentState {targetBuffer with stack := targetArgFrames} 1 targetFn targetThis
      (targetValue::targetAcc) [] (R.env env)
    let targetTyped := (targetConstruct.alloc (typedBuffer .i32 (R.a source.next) 0 ((n*4)/4) typedProto)).2.ret (.obj targetConstruct.next)
    have frame4 := alloc_ret_heap_below {targetTyped with stack := targetFrames}
      (valueArray (targetNode.shape.map (fun d : Host.Mlx.Ffi.Dim => Val.num d.num))) (.obj targetTyped.next)
      (by change target.next+1+1 < 2^64; omega) a bound3
    exact (congrArg (fun heap : PTrie HObj => heap.get a) heap8).trans
      (frame4.trans ((targetFrame3 a bound1).trans (targetFrame1 a below)))

end Host.Ts.Owned.Annotated

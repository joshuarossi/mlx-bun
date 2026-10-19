import host.ts.RenameRetainedNdimCallEntry
import host.ts.RenameRetainedGetterCall
import host.mlx.NativeMetadataRetained
import host.mlx.NativeNumberReturn
import host.mlx.NativeAnnotationPolicy
import host.mlx.NativeSupportRebase

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Owned.Annotated
open Parametric Host.Load.Run.Full.Ordinary Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
namespace NdimCall

def bodyLive (live : Nat → Prop) (start : Nat) (name : Option Name) (env : Env)
    (home : Val) (owner : Nat) (disposed field : Name) (yes : Stmt) (source : Host.Ts.St Host.Load.LSt) : Nat → Prop :=
  CellsLive (ClosureLive live start false home (getterFunction name disposed field yes))
    (closureState source (getterFunction name disposed field yes) env false home (.obj owner) [] .call).next []

def allocatedGetter (source : Host.Ts.St Host.Load.LSt) (name : Option Name) (env : Env)
    (home : Val) (owner : Nat) (disposed field : Name) (yes : Stmt) (value : Val) : Host.Ts.St Host.Load.LSt :=
  let allocated := closureState source (getterFunction name disposed field yes) env false home (.obj owner) [] .call
  {source with heap := allocated.heap,next := allocated.next,ctl := .ret value}

theorem allocatedGetter_eq (source : Host.Ts.St Host.Load.LSt) (name : Option Name) (env : Env)
    (home : Val) (owner : Nat) (disposed field : Name) (yes : Stmt) (value : Val) :
    getterCallResult source name env home owner disposed field yes value =
      allocatedGetter source name env home owner disposed field yes value := by cases home <;> rfl

def bodyResult (source : Host.Ts.St Host.Load.LSt) (name : Option Name) (getEnv : Env) (home : Val)
    (owner : Nat) (disposed field : Name) (yes : Stmt) (handle _numberFn nativeFn module : Nat)
    (rank : Nat) (caller : List Frame) : Host.Ts.St Host.Load.LSt :=
  let handled := getterCallResult source name getEnv home owner disposed field yes (.big (Int.ofNat handle))
  let nativeInput := {handled with ctl := .call (.obj nativeFn) (.obj module) [.big (Int.ofNat handle)],stack := source.stack.tail}
  let nativeOutput := finishBig nativeInput nativeInput.ffi nativeName [.big (Int.ofNat handle)] (Int.ofNat rank)
  {nativeOutput with ctl := .ret (intV (Int.ofNat rank)),stack := caller}

def bodyNotes (notes : RetainedNotes) (start owner rank : Nat) (callerNotes : List Tree) : RetainedNotes :=
  notes.withRuntime ⟨returnNote (.literal (.lit (F64.ofInt (Int.ofNat rank)))),callerNotes,
    notes.runtime.cells.write start (.obj owner)⟩

 theorem getter_heap_below (source : Host.Ts.St Host.Load.LSt) (name : Option Name) (env : Env) (home : Val)
    (owner : Nat) (disposed field : Name) (yes : Stmt) (value : Val)
    (bound : source.next+2 ≤ 2^64) (a : Nat) (below : a < source.next) :
    (getterCallResult source name env home owner disposed field yes value).heap.get a = source.heap.get a := by
  exact closureState_heap_below Host.Load.ffi source (getterFunction name disposed field yes) env false home (.obj owner) [] .call bound a below

 theorem getter_native (source : Host.Ts.St Host.Load.LSt) (name : Option Name) (env : Env) (home : Val)
    (owner : Nat) (disposed field : Name) (yes : Stmt) (value : Val) :
    (getterCallResult source name env home owner disposed field yes value).ffi = source.ffi := by
  cases home <;> rfl

end NdimCall

/-- The whole handle getter, actual native rank ABI call, binary64 Number
conversion and caller return. Rank comes from the current native node shape.
The real getter receiver/home cells and all six annotations are retained. -/
theorem RetainedInventory.ndim_getter_native_return
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {nodes : Nat → GraphNode} {boundary : Nat → Prop} {objects : Nat → Object}
    {roots H N : Nat → Prop} {tailTokens : List NumV} {host : Host.Load.HostSt → Host.Load.HostSt → Prop}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {source target : Host.Ts.St Host.Load.LSt}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tailTokens host)
      R live framed before after old old' source target)
    (policy : ProducerAnnotations roots H N nodes objects)
    (getter owner brand numberFn nativeFn module types handle : Nat)
    (function object numberObject nativeObject signatureObject : Host.Ts.Obj)
    (name : Option Name) (getEnv : Env) (home : Val) (disposed field : Name) (yes : Stmt)
    (dw de hw he : Bool) (returns : Name) (numberData : List Val) (node : Host.Mlx.Ffi.Node)
    (env bodyEnv : Env) (caller : List Frame) (retNote blockNote scopeNote boundaryNote : Tree) (callerNotes : List Tree)
    (control : source.ctl = .call (.obj getter) (.obj owner) [])
    (stack : source.stack = .c (.args 0 (.obj nativeFn) (.obj module) [] [] env)::
      .c (.args 0 (.obj numberFn) .undef [] [] env)::.s .ret::.s (.block [] bodyEnv)::.s (.scope [])::.k (.fn .call)::caller)
    (functionRead : source.heap.get getter = some (.obj function))
    (closure : function.kind = .fn (.closure (getterFunction name disposed field yes) getEnv false home))
    (objectRead : source.heap.get owner = some (.obj object)) (ordinary : object.kind = .ordinary)
    (disposedValue : findPriv brand disposed object.priv = some (.data (.bool false) dw de))
    (handleValue : findPriv brand field object.priv = some (.data (.big (Int.ofNat handle)) hw he))
    (disposedLookup : lookupEnv (privName disposed) getEnv = some brand)
    (handleLookup : lookupEnv (privName field) getEnv = some brand)
    (disposedNames : nameEq (privName disposed) nThis = false ∧ nameEq (privName disposed) nHome = false)
    (handleNames : nameEq (privName field) nThis = false ∧ nameEq (privName field) nHome = false)
    (numberRead : source.heap.get numberFn = some (.obj numberObject))
    (numberKind : numberObject.kind = .fn (.native (.num .number) numberData))
    (nativeRead : source.heap.get nativeFn = some (.obj nativeObject))
    (nativeKind : nativeObject.kind = .fn (.native (.ffi .symbol) [.str NdimCall.nativeName,.obj types,.str returns]))
    (signatureRead : source.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array [.str chars!"u64"])
    (numberLive : live numberFn) (nativeLive : live nativeFn) (typesLive : live types)
    (signatureFrame : ¬ framed types) (handleLive : H handle)
    (sourceNode : source.ffi.mlx.node? handle = some node)
    (fieldNote : notes.privates.owners owner = some ⟨brand,field,.handle handle⟩)
    (controlNote : notes.runtime.control = callNote (.obj getter) (.obj owner) [])
    (stackNotes : notes.runtime.stack = argumentFrameNote false 0 (.obj nativeFn) (.obj module) [] [] env::
      argumentFrameNote false 0 (.obj numberFn) .undef [] [] env::retNote::blockNote::scopeNote::boundaryNote::callerNotes)
    (sourceBound : source.next+2 ≤ 2^64) (targetBound : target.next+2 ≤ 2^64) :
    let reachedLive := NdimCall.bodyLive live source.next name getEnv home owner disposed field yes source
    let reached := NdimCall.bodyResult source name getEnv home owner disposed field yes handle numberFn nativeFn module (len node.shape) caller
    ∃ result, runC Host.Load.ffi 25 source C₀ = some (reached,C₀) ∧
      runC Host.Load.ffi 25 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tailTokens host)
        R reachedLive framed before after old old' reached result ∧
      RetainedInventory (NdimCall.bodyNotes notes source.next owner (len node.shape) callerNotes)
        ν₀ ν C₀ C R reachedLive reached result ∧
      result.ffi = target.ffi ∧ result.next ≤ target.next+2 ∧
      (∀ a, a < target.next → result.heap.get a = target.heap.get a) ∧
      ProducerAnnotations roots H N nodes objects ∧ ProducerSupport roots H N reached.ffi.mlx ∧
      ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i)) (resourceImage R.handle H) (resourceImage R.node N) result.ffi.mlx := by
  let F := Host.Load.ffi
  let FR := VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tailTokens host
  let handled := NdimCall.allocatedGetter source name getEnv home owner disposed field yes (.big (Int.ofNat handle))
  have frame : ∀ a, a < source.next → handled.heap.get a = source.heap.get a :=
    closureState_heap_below Host.Load.ffi source (getterFunction name disposed field yes) getEnv false home (.obj owner) [] .call sourceBound
  have handledNumber : handled.heap.get numberFn = some (.obj numberObject) := (frame numberFn (state.heap.sourceBound numberFn numberLive)).trans numberRead
  have handledNative : handled.heap.get nativeFn = some (.obj nativeObject) := (frame nativeFn (state.heap.sourceBound nativeFn nativeLive)).trans nativeRead
  have handledSignature : handled.heap.get types = some (.obj signatureObject) := (frame types (state.heap.sourceBound types typesLive)).trans signatureRead
  have handledNode : handled.ffi.mlx.node? handle = some node := sourceNode
  obtain ⟨s17,l17,r17,h17,inv17,ffi17,next17,heap17⟩ := inventory.getter_call_block (F:=Host.Load.ffi) state
    getter owner brand function object name getEnv home disposed field yes (.big (Int.ofNat handle)) (.handle handle)
    dw de hw he control functionRead closure objectRead ordinary disposedValue handleValue disposedLookup handleLookup
    disposedNames handleNames fieldNote controlNote sourceBound targetBound
  have allocatedEq := NdimCall.allocatedGetter_eq source name getEnv home owner disposed field yes (.big (Int.ofNat handle))
  have l17 := l17.trans (congrArg (fun st : Host.Ts.St Host.Load.LSt => some (st,C₀)) allocatedEq)
  let reachedLive := NdimCall.bodyLive live source.next name getEnv home owner disposed field yes source
  let stateAt := fun st : Host.Ts.St Host.Load.LSt => Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R reachedLive framed before after old old' st s17
  have h17 : stateAt handled := Eq.mp (congrArg stateAt allocatedEq) h17
  let inventoryAt := fun st : Host.Ts.St Host.Load.LSt => RetainedInventory
    (getterCallNotes notes source.next owner (.handle handle)) ν₀ ν C₀ C R reachedLive st s17
  have inv17 : inventoryAt handled := Eq.mp (congrArg inventoryAt allocatedEq) inv17
  dsimp only [stateAt] at h17
  dsimp only [inventoryAt] at inv17
  obtain ⟨_,_,_,_,_,l18,r18,h18,runtime18⟩ := inv17.runtime.argument_step F FR _ ν₀ ν C₀ C R _ framed before after old old'
    _ _ h17 (.big (Int.ofNat handle)) (.handle handle) (.obj nativeFn) (.obj module) [] 0 (.obj nativeFn) (.obj module) [] [] env
    (.c (.args 0 (.obj numberFn) .undef [] [] env)::.s .ret::.s (.block [] bodyEnv)::.s (.scope [])::.k (.fn .call)::caller)
    (argumentFrameNote false 0 (.obj numberFn) .undef [] [] env::retNote::blockNote::scopeNote::boundaryNote::callerNotes)
    rfl (by exact stack) (by decide) rfl (by exact stackNotes)
  have inv18 := inv17.heap_step runtime18 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨l19,r19,h19,inv19⟩ := MetadataInventory.retained_ndim_from_source ν₀ ν C₀ C R nodes boundary objects H N tailTokens host
    _ framed before after old old' _ _ h18 inv18 nativeFn types handle nativeObject signatureObject returns (.obj module) node
    rfl handledNative nativeKind handledSignature signatureKind signatureFrame handleLive handledNode (.obj nativeFn) (.obj module) rfl
  obtain ⟨result,l25,r25,h25,inv25,heap25,ffi25,next25⟩ := inv19.integer_number_return_block (F:=Host.Load.ffi) h19
    numberFn numberObject numberData .undef (Int.ofNat (len node.shape))
    (.lit (F64.ofInt (Int.ofNat (len node.shape)))) (.ordinaryBig (Int.ofNat (len node.shape))) (.obj numberFn) .undef
    (.ordinary _) env bodyEnv caller retNote blockNote scopeNote boundaryNote callerNotes rfl rfl
    handledNumber numberKind rfl rfl
  have one := fun (s t : St F.S) (C : CSrv) (a : isHalt s.ctl = false)
    (r : interpC (step F s).run C = some (t,C)) => runC_cons F 0 s t t C C C a r rfl
  have left18 := one _ _ C₀ rfl l18
  have right18 := one _ _ C (h17.control.isHalt_eq.trans rfl) r18
  have left19 := one _ _ C₀ rfl l19
  have right19 := one _ _ C (h18.control.isHalt_eq.trans rfl) r19
  let finalSource : Host.Ts.St Host.Load.LSt :=
    let nativeInput := {handled with ctl := .call (.obj nativeFn) (.obj module) [.big (Int.ofNat handle)],stack :=
      (.c (.args 0 (.obj numberFn) .undef [] [] env)::.s .ret::.s (.block [] bodyEnv)::.s (.scope [])::.k (.fn .call)::caller)}
    {finishBig nativeInput source.ffi NdimCall.nativeName [.big (Int.ofNat handle)] (Int.ofNat (len node.shape))
      with ctl := .ret (intV (Int.ofNat (len node.shape))),stack := caller}
  have finalEq : finalSource = NdimCall.bodyResult source name getEnv home owner disposed field yes handle numberFn nativeFn module (len node.shape) caller := by
    unfold NdimCall.bodyResult
    rw [NdimCall.allocatedGetter_eq,stack]
    rfl
  let stateAtFinal := fun st : Host.Ts.St Host.Load.LSt => Parametric.StateR
    (NumberRoles ν₀ ν C₀ C) FR R reachedLive framed before after old old' st result
  have post : stateAtFinal (NdimCall.bodyResult source name getEnv home owner disposed field yes handle numberFn nativeFn module (len node.shape) caller) :=
    Eq.mp (congrArg stateAtFinal finalEq) h25
  let inventoryAtFinal := fun st : Host.Ts.St Host.Load.LSt => RetainedInventory
    (NdimCall.bodyNotes notes source.next owner (len node.shape) callerNotes) ν₀ ν C₀ C R reachedLive st result
  have retained : inventoryAtFinal (NdimCall.bodyResult source name getEnv home owner disposed field yes handle numberFn nativeFn module (len node.shape) caller) :=
    Eq.mp (congrArg inventoryAtFinal finalEq) inv25
  have left := runC_join F (runC_join F (runC_join F l17 left18) left19) l25
  have sourceRun := left.trans (congrArg (fun st : Host.Ts.St Host.Load.LSt => some (st,C₀)) finalEq)
  refine ⟨result,sourceRun,runC_join F (runC_join F (runC_join F r17 right18) right19) r25,post,retained,?_,?_,?_,policy,?_,?_⟩
  · exact ffi25.trans ffi17
  · rw [next25]; exact next17
  · intro a below
    exact (congrArg (fun heap : PTrie HObj => heap.get a) heap25).trans (heap17 a below)
  · exact policy.source post.native.2
  · exact policy.target post.native.2

end Host.Ts.Owned.Annotated

import host.mlx.NativeNdimCallBody

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated
open Parametric Host.Load.Run.Full.Ordinary Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
namespace NdimCall

def function : Func := singleReturnFunction none expression

def entry {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) : St S :=
  let allocated := closureState source function env false home (.obj owner) [] .call
  let e := closureEnvironment source function env false home (.obj owner)
  {source with heap := allocated.heap,next := allocated.next,ctl := .ev expression e,stack :=
    (.s .ret::.s (.block [] e)::.s (.scope [])::.k (.fn .call)::source.stack)}

theorem entry_eq {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) :
    singleReturnEntryState source none env home owner expression = entry source env home owner := by
  cases home <;> rfl

def entryEnv {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) : Env :=
  closureEnvironment source function env false home (.obj owner)

def entryLive {S : Type} (live : Nat → Prop) (source : St S) (env : Env) (home : Val) (owner : Nat) : Nat → Prop :=
  CellsLive (ClosureLive live source.next false home function)
    (closureState source function env false home (.obj owner) [] .call).next []

def entryNotes {S : Type} (notes : RetainedNotes) (source : St S) (env : Env) (home : Val) (owner : Nat) : RetainedNotes :=
  notes.withRuntime (singleReturnEntryRuntime notes.runtime function (entryEnv source env home owner) source.next owner expression)

def callInput (source : Host.Ts.St Host.Load.LSt) (env : Env) (home : Val)
    (numberFn nativeFn module owner getter : Nat) : Host.Ts.St Host.Load.LSt :=
  getterInput (entry source env home owner) (entryEnv source env home owner) numberFn nativeFn module owner getter

def callLive (live : Nat → Prop) (source : Host.Ts.St Host.Load.LSt) (env : Env) (home : Val) (owner : Nat)
    (name : Option Name) (getEnv : Env) (getHome : Val) (disposed field : Name) (yes : Stmt)
    (numberFn nativeFn module getter : Nat) : Nat → Prop :=
  let input := callInput source env home numberFn nativeFn module owner getter
  bodyLive (entryLive live source env home owner) input.next name getEnv getHome owner disposed field yes input

def callResult (source : Host.Ts.St Host.Load.LSt) (env : Env) (home : Val) (owner : Nat)
    (name : Option Name) (getEnv : Env) (getHome : Val) (disposed field : Name) (yes : Stmt)
    (numberFn nativeFn module getter handle rank : Nat) : Host.Ts.St Host.Load.LSt :=
  bodyResult (callInput source env home numberFn nativeFn module owner getter) name getEnv getHome owner disposed field yes
    handle numberFn nativeFn module rank source.stack

def callNotes (notes : RetainedNotes) (source : Host.Ts.St Host.Load.LSt) (env : Env) (home : Val)
    (owner numberFn nativeFn module getter rank : Nat) : RetainedNotes :=
  let first := entryNotes notes source env home owner
  let second := getterNotes first (entryEnv source env home owner) numberFn nativeFn module owner getter
  bodyNotes second (entry source env home owner).next owner rank notes.runtime.stack

theorem entry_environment_other {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) (name : Name)
    (thisName : nameEq name nThis = false) (homeName : nameEq name nHome = false) :
    lookupEnv name (entryEnv source env home owner) = lookupEnv name env := by
  cases home <;> change lookupEnv name (_::_) = _
  all_goals first
    | rw [lookupEnv_skip name nThis _ _ thisName]
    | rw [lookupEnv_skip name nHome _ _ homeName,lookupEnv_skip name nThis _ _ thisName]

theorem entry_environment_this {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) :
    lookupEnv nThis (entryEnv source env home owner) = some source.next := by
  exact getter_environment_this source none env home owner chars!"disposed" chars!"handle" (.block [])

theorem entry_heap_below (source : Host.Ts.St Host.Load.LSt) (env : Env) (home : Val) (owner : Nat)
    (bound : source.next+2 ≤ 2^64) (a : Nat) (below : a < source.next) :
    (entry source env home owner).heap.get a = source.heap.get a :=
  closureState_heap_below Host.Load.ffi source function env false home (.obj owner) [] .call bound a below

theorem entry_native (source : Host.Ts.St Host.Load.LSt) (env : Env) (home : Val) (owner : Nat) :
    (entry source env home owner).ffi = source.ffi := by cases home <;> rfl

theorem entry_next {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) :
    (entry source env home owner).next ≤ source.next+2 := by
  cases home <;> first
    | change source.next+1 ≤ source.next+2; omega
    | change source.next+1+1 ≤ source.next+2; omega

theorem call_result_control (source : Host.Ts.St Host.Load.LSt) (env : Env) (home : Val) (owner : Nat)
    (name : Option Name) (getEnv : Env) (getHome : Val) (disposed field : Name) (yes : Stmt)
    (numberFn nativeFn module getter handle rank : Nat) :
    (callResult source env home owner name getEnv getHome disposed field yes numberFn nativeFn module getter handle rank).ctl =
      .ret (intV (Int.ofNat rank)) := rfl

theorem call_result_stack (source : Host.Ts.St Host.Load.LSt) (env : Env) (home : Val) (owner : Nat)
    (name : Option Name) (getEnv : Env) (getHome : Val) (disposed field : Name) (yes : Stmt)
    (numberFn nativeFn module getter handle rank : Nat) :
    (callResult source env home owner name getEnv getHome disposed field yes numberFn nativeFn module getter handle rank).stack =
      source.stack := rfl

theorem call_result_native (source : Host.Ts.St Host.Load.LSt) (env : Env) (home : Val) (owner : Nat)
    (name : Option Name) (getEnv : Env) (getHome : Val) (disposed field : Name) (yes : Stmt)
    (numberFn nativeFn module getter handle rank : Nat) :
    (callResult source env home owner name getEnv getHome disposed field yes numberFn nativeFn module getter handle rank).ffi =
      source.ffi := by cases getHome <;> rfl

end NdimCall

/-- Complete successful call of the pinned MlxArray.ndim closure. All 39
original transitions, both real closure allocations, the native shape/rank
observation and binary64 Number conversion are derived from current-entry
facts, while arbitrary heaps, renamings, callers and fresh counters survive. -/
theorem RetainedInventory.ndim_call_block
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
    (ndimGetter owner getter brand numberFn nativeFn moduleCell module types handle : Nat)
    (ndimObject getterObject object global numberObject nativeObject signatureObject : Host.Ts.Obj)
    (env getEnv : Env) (home getHome : Val) (name : Option Name) (disposed field : Name) (yes : Stmt)
    (nw ne mw me ge dw de hw he : Bool) (setter : Val) (returns : Name) (numberData : List Val) (node : Host.Mlx.Ffi.Node)
    (control : source.ctl = .call (.obj ndimGetter) (.obj owner) [])
    (ndimRead : source.heap.get ndimGetter = some (.obj ndimObject))
    (ndimKind : ndimObject.kind = .fn (.closure Sources.Mlx.Array.ast_n61 env false home))
    (numberLookup : lookupEnv NdimCall.numberName env = none)
    (globalRead : source.heap.get aGlobal = some (.obj global)) (globalKind : global.kind = .ordinary)
    (numberProperty : findProp (.str NdimCall.numberName) global.props = some (.data (.obj numberFn) nw ne))
    (moduleLookup : lookupEnv NdimCall.nativeModule env = some moduleCell)
    (moduleRead : source.heap.get moduleCell = some (.cell (some (.obj module))))
    (modulePath : OrdinaryLookup source NdimCall.nativeName 16 module (some (.data (.obj nativeFn) mw me)))
    (getterPath : OrdinaryLookup source NdimCall.handleName 16 owner (some (.acc (.obj getter) setter ge)))
    (getterRead : source.heap.get getter = some (.obj getterObject))
    (getterKind : getterObject.kind = .fn (.closure (getterFunction name disposed field yes) getEnv false getHome))
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
    (globalLive : live aGlobal) (moduleCellLive : live moduleCell) (moduleLive : live module)
    (ownerLive : live owner) (getterLive : live getter) (numberLive : live numberFn) (nativeLive : live nativeFn) (typesLive : live types)
    (globalFixed : R.a aGlobal = aGlobal) (signatureFrame : ¬ framed types) (handleLive : H handle)
    (sourceNode : source.ffi.mlx.node? handle = some node)
    (fieldNote : notes.privates.owners owner = some ⟨brand,field,.handle handle⟩)
    (controlNote : notes.runtime.control = callNote (.obj ndimGetter) (.obj owner) [])
    (sourceBound : source.next+4 ≤ 2^64) (targetBound : target.next+4 ≤ 2^64) :
    let reachedLive := NdimCall.callLive live source env home owner name getEnv getHome disposed field yes numberFn nativeFn module getter
    let reached := NdimCall.callResult source env home owner name getEnv getHome disposed field yes numberFn nativeFn module getter handle (len node.shape)
    ∃ result, runC Host.Load.ffi 39 source C₀ = some (reached,C₀) ∧
      runC Host.Load.ffi 39 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tailTokens host)
        R reachedLive framed before after old old' reached result ∧
      RetainedInventory (NdimCall.callNotes notes source env home owner numberFn nativeFn module getter (len node.shape))
        ν₀ ν C₀ C R reachedLive reached result ∧
      result.ffi = target.ffi ∧ result.next ≤ target.next+4 ∧
      (∀ a, a < target.next → result.heap.get a = target.heap.get a) ∧
      ProducerAnnotations roots H N nodes objects ∧ ProducerSupport roots H N reached.ffi.mlx ∧
      ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i)) (resourceImage R.handle H) (resourceImage R.node N) result.ffi.mlx := by
  let F := Host.Load.ffi
  let FR := VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tailTokens host
  let e := NdimCall.entryEnv source env home owner
  let entry := NdimCall.entry source env home owner
  let entryLive := NdimCall.entryLive live source env home owner
  let firstNotes := NdimCall.entryNotes notes source env home owner
  have sourceBound2 : source.next+2 ≤ 2^64 := by omega
  have targetBound2 : target.next+2 ≤ 2^64 := by omega
  have frame := NdimCall.entry_heap_below source env home owner sourceBound2
  have readFrame : ∀ a, live a → entry.heap.get a = source.heap.get a := fun a alive => frame a (state.heap.sourceBound a alive)
  have grow : ∀ a, live a → entryLive a := fun a alive => CellsLive.grow _ _ _ a (ClosureLive.grow _ _ _ _ _ a alive)
  have entryThis : entry.heap.get source.next = some (.cell (some (.obj owner))) :=
    closureState_receiver F source NdimCall.function env home (.obj owner) [] .call sourceBound2
  obtain ⟨s4,l4,r4,h4,inv4,ffi4,next4,heap4⟩ := inventory.single_return_entry_block (F:=Host.Load.ffi) state
    ndimGetter owner ndimObject none env home NdimCall.expression control ndimRead
    (by simpa only [NdimCall.source_function] using ndimKind) controlNote sourceBound2 targetBound2
  have entryEq := NdimCall.entry_eq source env home owner
  have l4 := l4.trans (congrArg (fun st : Host.Ts.St Host.Load.LSt => some (st,C₀)) entryEq)
  let stateAtEntry := fun st : Host.Ts.St Host.Load.LSt => Parametric.StateR
    (NumberRoles ν₀ ν C₀ C) FR R entryLive framed before after old old' st s4
  have h4 : stateAtEntry entry := Eq.mp (congrArg stateAtEntry entryEq) h4
  let inventoryAtEntry := fun st : Host.Ts.St Host.Load.LSt => RetainedInventory firstNotes ν₀ ν C₀ C R entryLive st s4
  have inv4 : inventoryAtEntry entry := Eq.mp (congrArg inventoryAtEntry entryEq) inv4
  dsimp only [stateAtEntry] at h4
  dsimp only [inventoryAtEntry] at inv4
  obtain ⟨s14,l14,r14,h14,inv14,heap14,ffi14,next14⟩ := inv4.ndim_expression_entry (F:=Host.Load.ffi) h4 e numberFn nativeFn moduleCell module source.next owner getter
    global nw ne mw me ge setter rfl
    ((NdimCall.entry_environment_other source env home owner NdimCall.numberName (by decide +kernel) (by decide +kernel)).trans numberLookup)
    ((readFrame aGlobal globalLive).trans globalRead) globalKind numberProperty
    ((NdimCall.entry_environment_other source env home owner NdimCall.nativeModule (by decide +kernel) (by decide +kernel)).trans moduleLookup)
    ((readFrame moduleCell moduleCellLive).trans moduleRead)
    (modulePath.frame_live (reached:=entry) state.heap readFrame moduleLive)
    (NdimCall.entry_environment_this source env home owner) entryThis
    (by change (notes.runtime.cells.write source.next (.obj owner)).cells source.next = _; simp only [Notes.write,ite_true])
    (getterPath.frame_live (reached:=entry) state.heap readFrame ownerLive) (grow aGlobal globalLive) globalFixed
  let input := NdimCall.callInput source env home numberFn nativeFn module owner getter
  have inputFrame : ∀ a, live a → input.heap.get a = source.heap.get a := readFrame
  have inputNode : input.ffi.mlx.node? handle = some node := by
    change entry.ffi.mlx.node? handle = _
    rw [NdimCall.entry_native]; exact sourceNode
  have inputBound : input.next+2 ≤ 2^64 := by
    have le : entry.next ≤ source.next+2 := NdimCall.entry_next source env home owner
    change entry.next+2 ≤ 2^64
    omega
  have resultBound : s14.next+2 ≤ 2^64 := by rw [next14]; omega
  obtain ⟨result,l39,r39,h39,inv39,ffi39,next39,heap39,policy39,support39,targetSupport39⟩ := inv14.ndim_getter_native_return h14 policy
    getter owner brand numberFn nativeFn module types handle getterObject object numberObject nativeObject signatureObject name getEnv getHome disposed field yes
    dw de hw he returns numberData node e e source.stack
    (.node "Frame.s" [.node "StmtF.ret" []]) (blockFrameNote [] e) emptyScopeNote callBoundaryNote notes.runtime.stack rfl rfl
    ((inputFrame getter getterLive).trans getterRead) getterKind ((inputFrame owner ownerLive).trans objectRead) ordinary
    disposedValue handleValue disposedLookup handleLookup disposedNames handleNames
    ((inputFrame numberFn numberLive).trans numberRead) numberKind ((inputFrame nativeFn nativeLive).trans nativeRead) nativeKind
    ((inputFrame types typesLive).trans signatureRead) signatureKind (grow numberFn numberLive) (grow nativeFn nativeLive) (grow types typesLive)
    signatureFrame handleLive inputNode fieldNote rfl rfl inputBound resultBound
  refine ⟨result,runC_join F (runC_join F l4 l14) l39,runC_join F (runC_join F r4 r14) r39,h39,inv39,
    ffi39.trans (ffi14.trans ffi4),?_,?_,policy39,support39,targetSupport39⟩
  · have le : s14.next ≤ target.next+2 := by rw [next14]; exact next4
    omega
  · intro a below
    have receiverLive := CellsLive.grow (ClosureLive live source.next false home NdimCall.function)
      (closureState source NdimCall.function env false home (.obj owner) [] .call).next [] source.next
      (ClosureLive.receiver live source.next home NdimCall.function)
    have grown := h4.heap.targetBound source.next receiverLive
    have fresh := state.heap.fresh 0
    simp only [Nat.add_zero] at fresh
    rw [fresh] at grown
    have entryBelow : a < s4.next := Nat.lt_trans below grown
    exact (heap39 a (by rw [next14]; exact entryBelow)).trans
      ((congrArg (fun heap : PTrie HObj => heap.get a) heap14).trans (heap4 a below))

end Host.Ts.Owned.Annotated

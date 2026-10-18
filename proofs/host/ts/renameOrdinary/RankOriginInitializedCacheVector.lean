import host.load.RuntimeNamespacedVectorEntry
import host.ts.renameOrdinary.RankOriginInitializedCacheBuffer
import host.ts.renameOrdinary.RankOriginObjectSeed

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCache
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open NamespacedVectorEntryBatch

noncomputable def startLive : Nat → Prop :=
  LiveAfter (LiveAfter (arrayLiveSet (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live)))
    Typed223.input.next) (Typed223.input.next+1)
noncomputable def finalLive : Nat → Prop := endLive startLive
noncomputable def finalObjects : Nat → Object :=
  objectWrite entryObjects Vector249.input.ffi.mlx.next (.vec Vector249.nodes)
noncomputable def finalHandles (a : Nat) : Prop := a = Vector249.input.ffi.mlx.next ∨ NativeSeed.handles a
def hostRelation (_ _ : HostSt) : Prop := True

theorem initial_namespace : input.heap.get 455 = some (.cell (some (.obj 4817))) := by host_kernel_rfl
theorem initial_pointer : input.heap.get 2650 = some (.cell (some (.obj 2638))) := by host_kernel_rfl

private theorem vector_entry_cell (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) (a : Nat)
    (notRank : a ≠ RetainedPrefix.Source5.address) (notPointer : a ≠ RetainedPrefix.Source0.address) :
    (RankShapeRetained.EntryNotes (entryNotes ic is) control fnRole thisRole saved caller).runtime.cells.cells a =
      (InitialRetained.cells.cells a).map (Value.subst LoopVariables.oracleVariables) := by
  simp only [RankShapeRetained.EntryNotes,RetainedSeed.seededCells,Notes.write,
    ite_eq_right notRank,ite_eq_right notPointer]
  rfl

theorem namespace_entry (ic : Annotated.Tree) (is : List Annotated.Tree) (control : Annotated.Tree)
    (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree) (caller : List Annotated.Tree) :
    (RankShapeRetained.EntryNotes (entryNotes ic is) control fnRole thisRole saved caller).runtime.cells.cells
      Plan224.Block230.address = some (.obj 4817) := by
  change (RankShapeRetained.EntryNotes (entryNotes ic is) control fnRole thisRole saved caller).runtime.cells.cells
    455 = some (.obj 4817)
  rw [vector_entry_cell ic is control fnRole thisRole saved caller 455 (by decide +kernel) (by decide +kernel)]
  have selected := InitialCells.object_entry 455 4817
    (by rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel) initial_namespace (by decide +kernel)
  rw [selected]; rfl

theorem pointer_entry (ic : Annotated.Tree) (is : List Annotated.Tree) (control : Annotated.Tree)
    (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree) (caller : List Annotated.Tree) :
    (RankShapeRetained.EntryNotes (entryNotes ic is) control fnRole thisRole saved caller).runtime.cells.cells
      Plan224.Block234.address = some (.obj 2638) := by
  change (RankShapeRetained.EntryNotes (entryNotes ic is) control fnRole thisRole saved caller).runtime.cells.cells
    2650 = some (.obj 2638)
  rw [vector_entry_cell ic is control fnRole thisRole saved caller 2650 (by decide +kernel) (by decide +kernel)]
  have selected := InitialCells.object_entry 2650 2638
    (by rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel) initial_pointer (by decide +kernel)
  rw [selected]; rfl

theorem source224_bound : P.RestStream.micro0.micro2.s24.next+16 ≤ 2^64 := by decide +kernel
theorem vector_counter : Vector249.input.ffi.mlx.next = 29371 := by host_kernel_rfl
theorem vector_nodes : Vector249.nodes = [20208,22582] := by host_kernel_rfl

theorem vector_offsets (ic : Annotated.Tree) (is : List Annotated.Tree) (control : Annotated.Tree)
    (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree) (caller : List Annotated.Tree)
    (owner : Nat) (selected : owner ∈ CacheEntry.cacheOwners) :
    (finalNotes (RankShapeRetained.EntryNotes (entryNotes ic is) control fnRole thisRole saved caller) caller).publicFields.fields
      owner chars!"offset" = some (.literal (CacheEntry.offsetMeaning LoopVariables.cacheIndex owner)) :=
  entry_offset_selected ic is owner selected

/-- Real boot initialization reaches the first input-vector allocation. The
pointer/count/BigInt path consumes retained byte and element roles, and the
native allocation preserves indexed roles for all initialized objects plus
the fresh vector and its producer dependencies. Geometry here belongs to the
actual initialized source; no shifted-loop geometry is asserted. -/
theorem initialized_vector (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742105 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C' entryRoles NativeSeed.boundary finalObjects finalHandles NativeSeed.nodes [] hostRelation)
        identity finalLive (fun _ => False) [] [] input.trace input.trace P.RestStream.micro0.micro2.s50 result ∧
      RetainedInventory (finalNotes (RankShapeRetained.EntryNotes (entryNotes ic is)
          control fnRole thisRole saved caller) caller)
        (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C' identity finalLive P.RestStream.micro0.micro2.s50 result ∧
      ProducerAnnotations ObjectSeed.roots finalHandles NativeSeed.nodes entryRoles finalObjects ∧
      ProducerSupport ObjectSeed.roots finalHandles NativeSeed.nodes P.RestStream.micro0.micro2.s50.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (loop limit)) Vector249.nextServer C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s224,run224,h224,inventory224,currentPolicy,_,inst224⟩ :=
    initialized_handle_buffer ρ C limit table answers
  have fresh := h224.heap.fresh 0
  have heapCounter : P.RestStream.micro0.micro2.s24.next = s224.next := by
    simpa only [Nat.add_zero,identity,id_eq] using fresh
  have budget : s224.next+16 ≤ 2^64 := heapCounter ▸ source224_bound
  have globalLive : startLive aGlobal :=
    Or.inl (Or.inl (live_grow _ InitializedShape.initial_global))
  obtain ⟨s249,run25,h249,inventory249,inst249⟩ := typed_to_vector_entry
    (RankShapeRetained.EntryNotes (entryNotes ic is) control fnRole thisRole saved caller) caller
    (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C' identity (nativeFrame ρ limit C') startLive (fun _ => False)
    [] [] input.trace input.trace s224 inst224 h224 inventory224 budget
    (namespace_entry ic is control fnRole thisRole saved caller) (pointer_entry ic is control fnRole thisRole saved caller)
    globalLive rfl
  have strong : Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C')
      (VectorHost.NativeRelation (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C' entryRoles NativeSeed.boundary entryObjects
        NativeSeed.handles NativeSeed.nodes [] hostRelation) identity finalLive (fun _ => False)
      [] [] input.trace input.trace Vector249.input s249 :=
    {h249 with native := ⟨True.intro,h249.native.1⟩}
  have counter := h249.native.1.handleMap.head
  change Vector249.input.ffi.mlx.next = s249.ffi.mlx.next at counter
  have bound : s249.ffi.mlx.next < 2^64 := counter ▸ Vector249.source_native_bound
  have countSchema : FixedIntegerRole (.exactInteger (.lit (F64.ofNat 2))) (Int.ofNat Vector249.handles.length) :=
    .exact (.lit (F64.ofNat 2)) (Int.ofNat 2) (fun _ => rfl) (by decide +kernel)
  obtain ⟨result,left,right,h250,inventory250,policy,support,inst250⟩ := Vector249.retained_transport
    (endNotes (RankShapeRetained.EntryNotes (entryNotes ic is) control fnRole thisRole saved caller) caller)
    (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C' identity entryRoles NativeSeed.boundary entryObjects NativeSeed.handles NativeSeed.nodes []
    hostRelation finalLive (fun _ => False) [] [] input.trace input.trace s249 inst249 strong inventory249
    (fun impossible => impossible) ⟨first_handle_live,second_handle_live,True.intro⟩
    bound ObjectSeed.roots currentPolicy (.obj 4709) (.obj 4817) (.exactInteger (.lit (F64.ofNat 2)))
    countSchema
    (vector_control (RankShapeRetained.EntryNotes (entryNotes ic is) control fnRole thisRole saved caller) caller)
    (vector_buffer (RankShapeRetained.EntryNotes (entryNotes ic is) control fnRole thisRole saved caller) caller)
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,h250,inventory250,policy,support,inst250⟩
  have run1 : runC P.F 1 s249 C' = some (result,C') := by
    have active : isHalt s249.ctl = false := by
      rw [strong.control.isHalt_eq,Vector249.source_control]; rfl
    exact runC_cons P.F 0 s249 result result C' C' C' active right rfl
  have run26 := runC_join P.F (m:=25) (n:=1) run25 run1
  cases boot : bootL Route.cx Decode.world 2000 with
  | none => simp only [boot,Option.bind_none] at run224; cases run224
  | some start =>
    simp only [boot,Option.bind_some] at run224 ⊢
    exact runC_join P.F (m:=32742079) (n:=26) run224 run26

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCache

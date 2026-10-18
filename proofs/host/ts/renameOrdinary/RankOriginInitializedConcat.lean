import host.ts.renameOrdinary.RankOriginInitializedConcatEntry
import host.load.RuntimeConcatEntryFacts

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedVectorPreludeBatch

noncomputable def roles : Nat → GraphNode := nodeWrite ObjectSeed.roles ConcatInventoryCases.Source336.input.ffi.mlx.nnext
  (concatRole ObjectSeed.roles ConcatInventoryCases.Source336.x ConcatInventoryCases.Source336.y
    ConcatInventoryCases.Source336.axis (closedShape [1,4,10240]))
noncomputable def objects : Nat → Object :=
  objectWrite InitializedVector.finalObjects ConcatInventoryCases.Source336.input.ffi.mlx.next .stream
noncomputable def handles (a : Nat) : Prop :=
  a = ConcatInventoryCases.Source336.input.ffi.mlx.next ∨ InitializedVector.finalHandles a
noncomputable def nodes (i : Nat) : Prop :=
  i = ConcatInventoryCases.Source336.input.ffi.mlx.nnext ∨ NativeSeed.nodes i

theorem vector_owned : InitializedVector.finalHandles ConcatInventoryCases.Source336.vec :=
  Or.inl (by host_kernel_rfl)
theorem heap_bound : ConcatInventoryCases.Source336.input.next < 2^64 := by decide +kernel

/-- Real initialized execution performs the first convolution-history concat.
Its current vector, output slot, exact input geometry, source symbol/signature
and indexed producer policy all follow from prior checked initialization. -/
theorem initialized_concat (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742192 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles ρ ρ C' C')
        (VectorHost.NativeRelation ρ ρ C' C' roles NativeSeed.boundary objects handles nodes [] InitializedVector.hostRelation)
        identity (readyLive InitializedVector.finalLive) (fun _ => False) [] [] input.trace input.trace
          P.RestStream.micro0.micro3.s37 result ∧
      RetainedInventory ((readyNotes (RankShapeRetained.EntryNotes (InitialRetained.notes ic is)
        control fnRole thisRole saved caller) caller).nativeHandleResult ConcatInventoryCases.Source336.out
          ConcatInventoryCases.Source336.input.ffi.mlx.next)
        ρ ρ C' C' identity (readyLive InitializedVector.finalLive) P.RestStream.micro0.micro3.s37 result ∧
      ProducerAnnotations ObjectSeed.roots handles nodes roles objects ∧
      ProducerSupport ObjectSeed.roots handles nodes P.RestStream.micro0.micro3.s37.ffi.mlx ∧
      Inst ρ (numberServer P.RestStream.micro0.micro3.S37) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s336,run336,h336,inventory336,policy,support,inst336⟩ :=
    InitializedConcatEntry.initialized_concat_entry ρ C table answers
  have handleCounter := h336.native.2.handleMap.head
  change ConcatInventoryCases.Source336.input.ffi.mlx.next = s336.ffi.mlx.next at handleCounter
  have nodeCounter := h336.native.2.nodeMap.head
  change ConcatInventoryCases.Source336.input.ffi.mlx.nnext = s336.ffi.mlx.nnext at nodeCounter
  have heapCounter := h336.heap.fresh 0
  change ConcatInventoryCases.Source336.input.next = s336.next+0 at heapCounter
  rw [Nat.add_zero] at heapCounter
  obtain ⟨result,left,right,post,retained,newPolicy,newSupport,inst337⟩ := ConcatInventoryCases.Source336.retained_transport
    (readyNotes (RankShapeRetained.EntryNotes (InitialRetained.notes ic is) control fnRole thisRole saved caller) caller)
    ρ ρ C' C' identity ObjectSeed.roles NativeSeed.boundary InitializedVector.finalObjects InitializedVector.finalHandles
    NativeSeed.nodes [] InitializedVector.hostRelation (readyLive InitializedVector.finalLive) (fun _ => False)
    [] [] input.trace input.trace s336 inst336 h336 inventory336 (fun impossible => impossible) vector_owned
    (closedShape [1,4,10240]) (InitialConcat.geometry ρ) (InitialConcat.geometry ρ)
    (nodeCounter ▸ ConcatInventoryCases.Source336.source_node_bound)
    (handleCounter ▸ ConcatInventoryCases.Source336.source_native_bound) (heapCounter ▸ heap_bound)
    ObjectSeed.roots policy (.obj ConcatInventoryCases.Source336.address) (.obj concatReceiver)
    (ready_control _ caller) (ready_buffer _ caller)
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,newPolicy,newSupport,inst337⟩
  have one := runC_cons P.F 0 s336 result result C' C' C' (h336.control.isHalt_eq.trans rfl) right rfl
  cases boot : bootL Route.cx Decode.world 2000 with
  | none => simp only [boot,Option.bind_none] at run336; cases run336
  | some start =>
    simp only [boot,Option.bind_some] at run336 ⊢
    exact runC_join P.F (m:=32742191) (n:=1) run336 one

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedConcat

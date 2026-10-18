import host.ts.renameOrdinary.RankOriginInitializedCacheArray
import host.ts.renameOrdinary.RankOriginInitializedHandleBuffer
import host.mlx.OrdinaryNativeInventoryFrontends
import host.mlx.OrdinaryHandleArrayInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCache
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated


host_retained_handleTyped P.F, P.RestStream.micro0.micro2.s23 using (P.RestStream.micro0.micro2.S23.substitute LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro2.s24 using (P.RestStream.micro0.micro2.S24.substitute LoopVariables.oracleVariables) as Typed223

noncomputable def arrayConstructorMetadata : NativeCaptureNote :=
  InitializedHandleBuffer.constructorMetadata.mapRoles (Value.subst LoopVariables.oracleVariables)

theorem array_constructor_selected (ic : Annotated.Tree) (is : List Annotated.Tree) :
    (entryNotes ic is).captures.owners 95 = some arrayConstructorMetadata := by
  change (InitialRetained.captures.owners 95).map
    (fun note => note.mapRoles (Value.subst LoopVariables.oracleVariables)) = some arrayConstructorMetadata
  rw [InitializedHandleBuffer.constructor_selected]
  rfl

theorem retained_constructor (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree) (caller : List Annotated.Tree) :
    (arrayNotes (RankShapeRetained.EntryNotes (entryNotes ic is) control fnRole thisRole saved caller) caller).captures.owners 95 =
      some arrayConstructorMetadata := array_constructor_selected ic is

theorem retained_elements (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (arrayNotes notes caller).arrays.owners 3126677 = some ([25732,29363].map Annotated.Value.handle) := by
  rfl

theorem live_grow (a : Nat) (alive : InitialRetained.live a) :
    arrayLiveSet (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live)) a := by
  have base := InitializedCallback.source14_grow a alive
  unfold arrayLiveSet
  repeat first | exact base | apply Or.inl

theorem first_handle_live : NativeSeed.handles 25732 := by
  change 25732 < input.ffi.mlx.next
  decide +kernel
theorem second_handle_live : NativeSeed.handles 29363 := NativeSeed.handle_live

/-- Actual initialization constructs the uint64 handle buffer at source223.
Both element meanings and the constructor's code/prototype literals come
from the retained boot invariant. Native ownership and bounds are derived
from the reached native relation and initialized intrinsic resources. -/
theorem initialized_handle_buffer (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (initialControl : Annotated.Tree) (initialStack : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742079 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C') (nativeFrame ρ limit C') identity
        (LiveAfter (LiveAfter (arrayLiveSet (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live)))
          Typed223.input.next) (Typed223.input.next+1)) (fun _ => False)
        [] [] input.trace input.trace P.RestStream.micro0.micro2.s24 result ∧
      RetainedInventory ((arrayNotes (RankShapeRetained.EntryNotes
        (entryNotes initialControl initialStack) control fnRole thisRole saved caller) caller).typedBytes
        Typed223.input.next (handleArrayBytes Typed223.handles))
        (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C' identity
        (LiveAfter (LiveAfter (arrayLiveSet (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live)))
          Typed223.input.next) (Typed223.input.next+1))
        P.RestStream.micro0.micro2.s24 result ∧
      Host.Mlx.Ffi.Annotated.ProducerAnnotations ObjectSeed.roots NativeSeed.handles NativeSeed.nodes entryRoles entryObjects ∧
      Host.Mlx.Ffi.NativeRoles.ProducerSupport ObjectSeed.roots NativeSeed.handles NativeSeed.nodes P.RestStream.micro0.micro2.s24.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (loop limit)) Typed223.nextServer C' := by
  obtain ⟨C',initialControl,initialStack,control,fnRole,thisRole,saved,caller,s223,run223,h223,inventory223,policy,_,inst223⟩ :=
    initialized_array ρ C limit table answers
  have fresh := h223.native.1.handleMap.head
  have nativeCounter : Typed223.input.ffi.mlx.next = s223.ffi.mlx.next := by
    change P.RestStream.micro0.micro2.s23.ffi.mlx.next = s223.ffi.mlx.next
    change P.RestStream.micro0.micro2.s23.ffi.mlx.next = s223.ffi.mlx.next at fresh
    exact fresh
  have nativeBound : s223.ffi.mlx.next < 2^64 :=
    nativeCounter ▸ Typed223.source_native_bound
  have freshHeap := h223.heap.fresh 0
  have heapCounter : Typed223.input.next = s223.next := by
    change P.RestStream.micro0.micro2.s23.next = s223.next at freshHeap
    exact freshHeap
  have bound : s223.next+1 < 2^64 := heapCounter ▸ Typed223.source_typed_bound
  have selected : (arrayNotes (RankShapeRetained.EntryNotes
      (entryNotes initialControl initialStack) control fnRole thisRole saved caller) caller).captures.owners 95 =
      some arrayConstructorMetadata := retained_constructor _ _ _ _ _ _ _
  have elements := retained_elements (RankShapeRetained.EntryNotes
    (entryNotes initialControl initialStack) control fnRole thisRole saved caller) caller
  obtain ⟨result,left,right,h224,inventory224,inst224⟩ := Typed223.retained_transport
    _ (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C' identity (nativeFrame ρ limit C')
    (arrayLiveSet (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live))) (fun _ => False)
    [] [] input.trace input.trace s223 inst223 h223 inventory223
    _ _ NativeSeed.handles NativeSeed.nodes [] h223.native.1 arrayConstructorMetadata selected rfl rfl elements
    ⟨first_handle_live,second_handle_live,True.intro⟩ nativeBound
    (live_grow _ InitializedShape.initial_array_buffer) rfl
    (live_grow _ (by rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel)) rfl bound
  refine ⟨C',initialControl,initialStack,control,fnRole,thisRole,saved,caller,result,?_,h224,inventory224,policy,policy.source h224.native.1,inst224⟩
  cases boot : bootL Route.cx Decode.world 2000 with
  | none =>
    simp only [boot,Option.bind_none] at run223
    cases run223
  | some start =>
    simp only [boot,Option.bind_some] at run223 ⊢
    have run1 : runC P.F 1 s223 C' = some (result,C') := by
      have active : isHalt s223.ctl = false := by
        rw [h223.control.isHalt_eq]
        change isHalt Typed223.input.ctl = false
        rw [Typed223.source_control]; rfl
      exact runC_cons P.F 0 s223 result result C' C' C' active right rfl
    exact runC_join P.F (m:=32742078) (n:=1) run223 run1

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCache

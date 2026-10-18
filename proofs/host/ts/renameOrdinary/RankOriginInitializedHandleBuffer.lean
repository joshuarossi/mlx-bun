import host.ts.renameOrdinary.RankOriginInitializedHandleArray
import host.mlx.OrdinaryNativeInventoryFrontends
import host.mlx.OrdinaryHandleArrayInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedHandleBuffer
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open InitializedHandleArray

def constructorMetadata : NativeCaptureNote := literalNativeNote (.buf .typedCtor) [natV 9,natV 26]

theorem initial_constructor : input.heap.get 95 = some (.obj HandleArray223.constructorObject) := by
  host_kernel_rfl
theorem initial_constructor_live : InitialRetained.live 95 := by
  rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel
theorem constructor_selected : InitialRetained.captures.owners 95 = some constructorMetadata :=
  literalCaptures.entry initial_constructor_live initial_constructor HandleArray223.source_kind

theorem retained_constructor (notes : RetainedNotes) (caller : List Annotated.Tree)
    (entry : notes.captures.owners 95 = some constructorMetadata) :
    (endNotes notes caller).captures.owners 95 = some constructorMetadata := entry

theorem retained_elements (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (endNotes notes caller).arrays.owners 3126677 = some ([25732,29363].map Annotated.Value.handle) := by
  rfl

theorem live_grow (a : Nat) (alive : InitialRetained.live a) :
    endLive (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live)) a := by
  have base := InitializedCallback.source14_grow a alive
  unfold endLive
  repeat first | exact base | apply Or.inl

theorem first_handle_live : NativeSeed.handles 25732 := by
  change 25732 < input.ffi.mlx.next
  decide +kernel
theorem second_handle_live : NativeSeed.handles 29363 := NativeSeed.handle_live

/-- Actual initialization constructs the uint64 handle buffer at source223.
Both element meanings and the constructor's code/prototype literals come
from the retained boot invariant. Native ownership and bounds are derived
from the reached native relation and initialized intrinsic resources. -/
theorem initialized_handle_buffer (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (initialControl : Annotated.Tree) (initialStack : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742079 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles ρ ρ C' C') (InitializedShape.nativeFrame ρ C') identity
        (LiveAfter (LiveAfter (endLive (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live)))
          NativeInventoryCases.Source223.input.next) (NativeInventoryCases.Source223.input.next+1)) (fun _ => False)
        [] [] input.trace input.trace P.RestStream.micro0.micro2.s24 result ∧
      RetainedInventory ((endNotes (RankShapeRetained.EntryNotes
        (InitialRetained.notes initialControl initialStack) control fnRole thisRole saved caller) caller).typedBytes
        NativeInventoryCases.Source223.input.next (handleArrayBytes NativeInventoryCases.Source223.handles))
        ρ ρ C' C' identity
        (LiveAfter (LiveAfter (endLive (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live)))
          NativeInventoryCases.Source223.input.next) (NativeInventoryCases.Source223.input.next+1))
        P.RestStream.micro0.micro2.s24 result ∧
      Inst ρ (numberServer P.RestStream.micro0.micro2.S24) C' := by
  obtain ⟨C',initialControl,initialStack,control,fnRole,thisRole,saved,caller,s223,run223,h223,inventory223,inst223⟩ :=
    InitializedHandleArray.initialized_handle_array ρ C table answers
  have fresh := h223.native.handleMap.head
  have nativeCounter : NativeInventoryCases.Source223.input.ffi.mlx.next = s223.ffi.mlx.next := by
    change P.RestStream.micro0.micro2.s23.ffi.mlx.next = s223.ffi.mlx.next
    change P.RestStream.micro0.micro2.s23.ffi.mlx.next = s223.ffi.mlx.next at fresh
    exact fresh
  have nativeBound : s223.ffi.mlx.next < 2^64 :=
    nativeCounter ▸ NativeInventoryCases.Source223.source_native_bound
  have freshHeap := h223.heap.fresh 0
  have heapCounter : NativeInventoryCases.Source223.input.next = s223.next := by
    simpa only [NativeInventoryCases.Source223.input,Nat.add_zero,identity,id_eq] using freshHeap
  have bound : s223.next+1 < 2^64 := heapCounter ▸ NativeInventoryCases.Source223.source_typed_bound
  have selected : (endNotes (RankShapeRetained.EntryNotes
      (InitialRetained.notes initialControl initialStack) control fnRole thisRole saved caller) caller).captures.owners 95 =
      some constructorMetadata := retained_constructor _ _ constructor_selected
  have elements := retained_elements (RankShapeRetained.EntryNotes
    (InitialRetained.notes initialControl initialStack) control fnRole thisRole saved caller) caller
  obtain ⟨result,left,right,h224,inventory224,inst224⟩ := NativeInventoryCases.Source223.retained_transport
    _ ρ ρ C' C' identity (InitializedShape.nativeFrame ρ C')
    (endLive (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live))) (fun _ => False)
    [] [] input.trace input.trace s223 inst223 h223 inventory223
    _ _ NativeSeed.handles NativeSeed.nodes [] h223.native constructorMetadata selected rfl rfl elements
    ⟨first_handle_live,second_handle_live,True.intro⟩ nativeBound
    (live_grow _ InitializedShape.initial_array_buffer) rfl
    (live_grow _ (by rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel)) rfl bound
  refine ⟨C',initialControl,initialStack,control,fnRole,thisRole,saved,caller,result,?_,h224,inventory224,inst224⟩
  cases boot : bootL Route.cx Decode.world 2000 with
  | none =>
    simp only [boot,Option.bind_none] at run223
    cases run223
  | some start =>
    simp only [boot,Option.bind_some] at run223 ⊢
    have run1 : runC P.F 1 s223 C' = some (result,C') := by
      have active : isHalt s223.ctl = false := by
        rw [h223.control.isHalt_eq]
        change isHalt NativeInventoryCases.Source223.input.ctl = false
        rw [NativeInventoryCases.Source223.source_control]; rfl
      exact runC_cons P.F 0 s223 result result C' C' C' active right rfl
    exact runC_join P.F (m:=32742078) (n:=1) run223 run1

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedHandleBuffer

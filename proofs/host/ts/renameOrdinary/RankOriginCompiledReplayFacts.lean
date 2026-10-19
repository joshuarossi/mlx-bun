import host.ts.renameOrdinary.RankOriginInitializedCompiledClosure
import host.load.RuntimeCachedCallArrayJoined

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.CompiledReplayFacts
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open NamespacedDecode

noncomputable def entryNotes := InitializedCompiledClosure.resultNotes

def fnRole : Annotated.Value := .obj 4782
def thisRole : Annotated.Value := .obj 4817

theorem source_entry : ClosureApplyBridge.After.Block2381.output = Cached2382.input :=
  ClosureApplyBridge.closure_call_output.trans CachedCallArrayJoined.actual_entry.symm

theorem source_server : ClosureApplyBridge.After.Block2381.nextServer = Cached2382.initialServer := by
  host_kernel_rfl

theorem current_control (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (entryNotes notes caller).runtime.control = callNote fnRole thisRole
      ((CachedFamilyHost.arguments 3126924 1354 29376).map FixedArgument.role) := by
  host_kernel_rfl

theorem current_slot (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (entryNotes notes caller).runtime.cells.cells 3126903 = some (.ptr (.js 3126924) 0) := by
  host_kernel_rfl

theorem current_input (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (entryNotes notes caller).runtime.cells.cells 3126901 = some (.handle 29376) := by
  host_kernel_rfl

theorem current_output_buffer (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (entryNotes notes caller).buffers.owners 3126924 = some (handleSlotNotes 29377) := by
  host_kernel_rfl

theorem current_constructor (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (calleeRole receiverRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) :
    (entryNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
      control calleeRole receiverRole saved caller) caller).captures.owners CachedArrayEntry.Allocation.address =
      some InitializedHandleBuffer.constructorMetadata := by
  calc
    _ = (CompiledClosureFacts.initializedNotes ic is control calleeRole receiverRole saved caller).captures.owners
        ClosureApplyBridge.After.Block2353.address := by host_kernel_rfl
    _ = _ := CompiledClosureFacts.current_constructor ic is control calleeRole receiverRole saved caller

theorem constructor_code : InitializedHandleBuffer.constructorMetadata.roles 0 =
    some (.literal (.lit CachedArrayEntry.Allocation.codeLiteral)) := by host_kernel_rfl

theorem constructor_proto : InitializedHandleBuffer.constructorMetadata.roles 1 =
    some (.literal (.lit CachedArrayEntry.Allocation.protoLiteral)) := by host_kernel_rfl

theorem current_intrinsic (a : Nat) (small : a < 100) : InitializedCompiledClosure.live a := by
  unfold InitializedCompiledClosure.live InitializedCompiledClosure.connectedLive
  repeat first | apply CellsLive.grow | apply ClosureLive.grow | apply Or.inl
  rw [InitialRetained.live,InitialClosure.source_address_limit]
  omega

private theorem initial_owned (handle : Nat) (initial : NativeSeed.handles handle)
    (dynamicFree : handle ≠ 29373) (convolutionFree : handle ≠ 29372)
    (concatFree : handle ≠ 25732) : InitializedPostConcatFree.handles handle := by
  refine ⟨⟨Or.inr ⟨Or.inr (Or.inr (Or.inr (Or.inr initial))), ?_⟩, ?_⟩, ?_⟩
  · change handle ≠ 29373
    exact dynamicFree
  · rw [NamespacedDecode.free1978_selected]
    exact convolutionFree
  · rw [NamespacedDecode.free2056_selected]
    exact concatFree

theorem closure_owned : InitializedCompiledClosure.handles 1354 :=
  Or.inr (Or.inr (initial_owned 1354
    (by rw [NativeSeed.handles,NativeSeed.source_next]; decide +kernel)
    (by decide +kernel) (by decide +kernel) (by decide +kernel)))

theorem input_owned : InitializedCompiledClosure.handles 29376 := Or.inr (Or.inl rfl)

theorem output_owned : InitializedCompiledClosure.handles 29377 := Or.inl rfl

end Host.Load.Run.Full.Ordinary.RankOrigin.CompiledReplayFacts

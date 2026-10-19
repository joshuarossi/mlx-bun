import host.ts.renameOrdinary.RankOriginInitializedCompiledArgumentFull
import host.load.RuntimeNamespacedDecodeVectorInputNative

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.CompiledArgumentVectorFacts
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open NamespacedDecode

noncomputable def countMeaning (notes : RetainedNotes) (caller : List Annotated.Tree) : SymE :=
  CompiledArgumentEntry.Through277.meaning (CompiledArgumentFacts.inputNotes notes caller)
    nativeStatusRole CompiledArgumentFacts.cellRole CompiledArgumentFacts.receiverRole

noncomputable def countRole (notes : RetainedNotes) (caller : List Annotated.Tree) : Annotated.Value :=
  .exactInteger (countMeaning notes caller)

theorem count_schema (notes : RetainedNotes) (caller : List Annotated.Tree) :
    FixedIntegerRole (countRole notes caller) (Int.ofNat 3) := by
  change FixedIntegerRole (.exactInteger (countMeaning notes caller)) (Int.ofNat 3)
  refine .exact _ _ ?_ ?_
  · intro valuation
    calc
      _ = CompiledArgumentEntry.From64.Span244.Block277.sourceValue :=
        CompiledArgumentEntry.through277_closed (CompiledArgumentFacts.inputNotes notes caller)
          nativeStatusRole CompiledArgumentFacts.cellRole CompiledArgumentFacts.receiverRole valuation
      _ = F64.ofInt (Int.ofNat 3) := by host_kernel_rfl
  · decide +kernel

theorem current_control (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (InitializedCompiledArgumentFull.resultNotes notes caller).runtime.control =
      callNote (.obj 4709) (.obj 4817) [.ptr (.js 3126910) 0,countRole notes caller] := by
  host_kernel_rfl

theorem current_buffer (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (InitializedCompiledArgumentFull.resultNotes notes caller).buffers.owners 3126910 =
      some (handleArrayBytes [29375,40,41]) := by
  host_kernel_rfl

theorem source_entry : CompiledArgumentEntry.Region.s279 = Vector2336.input := by
  host_kernel_rfl

theorem source_server : numberServer (CompiledArgumentEntry.Region.S279.substitute LoopVariables.oracleVariables) =
    Vector2336.initialServer := by
  host_kernel_rfl

theorem input_owned : InitializedPostConcatFree.handles 29375 := by
  refine ⟨⟨InitializedCacheConvolution.output_owned, ?_⟩, ?_⟩
  · rw [free1978_selected]
    decide +kernel
  · rw [free2056_selected]
    decide +kernel

private theorem initial_owned (handle : Nat) (initial : NativeSeed.handles handle)
    (dynamicFree : handle ≠ 29373) (convolutionFree : handle ≠ 29372)
    (concatFree : handle ≠ 25732) : InitializedPostConcatFree.handles handle := by
  refine ⟨⟨Or.inr ⟨Or.inr (Or.inr (Or.inr (Or.inr initial))), ?_⟩, ?_⟩, ?_⟩
  · change handle ≠ 29373
    exact dynamicFree
  · rw [free1978_selected]
    exact convolutionFree
  · rw [free2056_selected]
    exact concatFree

theorem weight_owned : InitializedPostConcatFree.handles 40 :=
  initial_owned 40 (by rw [NativeSeed.handles,NativeSeed.source_next]; decide +kernel)
    (by decide +kernel) (by decide +kernel) (by decide +kernel)

theorem bias_owned : InitializedPostConcatFree.handles 41 :=
  initial_owned 41 (by rw [NativeSeed.handles,NativeSeed.source_next]; decide +kernel)
    (by decide +kernel) (by decide +kernel) (by decide +kernel)

theorem owned : listSupport InitializedPostConcatFree.handles [29375,40,41] :=
  ⟨input_owned,weight_owned,bias_owned,True.intro⟩

end Host.Load.Run.Full.Ordinary.RankOrigin.CompiledArgumentVectorFacts

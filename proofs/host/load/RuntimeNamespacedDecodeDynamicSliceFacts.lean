import host.load.RuntimeNamespacedDecodeDynamicSliceNative
import host.ts.renameOrdinary.RankOriginInitializedCacheDynamicCall
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode.DynamicCallFacts
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

noncomputable def inputNotes := RankOrigin.InitializedCacheDynamicCall.resultNotes
private def sampleNotes : RetainedNotes :=
  ⟨⟨.atom Nat 0,[],Notes.empty⟩,PrivateNotes.empty,NativeCaptureNotes.empty,
    ArrayNotes.empty,PublicNotes.empty,BufferNotes.empty⟩
def signedMeanings (expressions : List SymE) : List SymE := expressions.map (SymE.un .int32)

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let emptyStack ← mkAppOptM ``List.nil #[some (mkConst ``Annotated.Tree)]
  let ready ← mkAppM ``inputNotes #[mkConst ``sampleNotes,emptyStack]
  let buffers ← mkAppM ``RetainedNotes.buffers #[ready]
  for (name,owner) in [(`axisExpressions,``Slice1549.axisBuffer),(`sizeExpressions,``Slice1549.sizeBuffer)] do
    let selected ← whnf (← mkAppM ``BufferNotes.owners #[buffers,mkConst owner])
    unless selected.isAppOfArity ``Option.some 2 do throwError "dynamic slice byte notes absent for {owner}"
    let bytes := selected.getAppArgs[1]!
    let expressions ← if bytes.isAppOfArity ``literalI32Bytes 1 then
        mkAppM ``signedMeanings #[bytes.getAppArgs[0]!]
      else if bytes.isAppOfArity ``literalShapeByteNotes 1 then pure bytes.getAppArgs[0]!
      else throwError "unexpected current byte-note representation {bytes.getAppFn}"
    Parametric.Driver.addData ((← getCurrNamespace)++name) expressions

def axisCount : Annotated.Value := .exactInteger (.lit (F64.ofNat 1))
def sizeCount : Annotated.Value := .exactInteger (.lit (F64.ofNat 3))
theorem axis_schema : FixedIntegerRole axisCount 1 :=
  .exact (.lit (F64.ofNat 1)) 1 (fun _ => rfl) (by decide +kernel)
theorem size_schema : FixedIntegerRole sizeCount 3 :=
  .exact (.lit (F64.ofNat 3)) 3 (fun _ => rfl) (by decide +kernel)

theorem current_control (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).runtime.control = callNote (.obj Slice1549.address) (.obj 4817)
      (SliceDynamicHost.dynamicArgumentNotes Slice1549.out Slice1549.handle Slice1549.start
        Slice1549.axisBuffer Slice1549.sizeBuffer Slice1549.stream axisCount sizeCount) := by host_kernel_rfl

theorem output_selected (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).buffers.owners Slice1549.out = some (handleSlotNotes 0) := by host_kernel_rfl
theorem axes_selected (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).buffers.owners Slice1549.axisBuffer =
      some (literalShapeByteNotes axisExpressions) := by host_kernel_rfl
theorem sizes_selected (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).buffers.owners Slice1549.sizeBuffer =
      some (literalShapeByteNotes sizeExpressions) := by host_kernel_rfl
theorem axes_closed : axisExpressions.all SymE.closed = true := by decide +kernel
theorem sizes_closed : sizeExpressions.all SymE.closed = true := by decide +kernel
end Host.Load.Run.Full.Ordinary.NamespacedDecode.DynamicCallFacts

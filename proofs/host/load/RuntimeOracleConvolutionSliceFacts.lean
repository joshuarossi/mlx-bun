import host.load.RuntimeOracleSliceCallArguments
import host.load.RuntimeOracleConvolutionSliceNative

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.RetainedOracleConvolutionBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

private def sampleNotes : RetainedNotes :=
  ⟨⟨.atom Nat 0,[],Notes.empty⟩,PrivateNotes.empty,NativeCaptureNotes.empty,
    ArrayNotes.empty,PublicNotes.empty,BufferNotes.empty⟩
def signedMeanings (expressions : List SymE) : List SymE := expressions.map (SymE.un .int32)

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let emptyStack ← mkAppOptM ``List.nil #[some (mkConst ``Annotated.Tree)]
  let ready ← mkAppM ``sliceReadyNotes #[mkConst ``sampleNotes,emptyStack]
  let buffers ←mkAppM ``RetainedNotes.buffers #[ready]
  for (name,owner) in [(`startExpressions,3126752),(`stopExpressions,3126754),(`strideExpressions,3126768)] do
    let selected ←whnf (←mkAppM ``BufferNotes.owners #[buffers,mkNatLit owner])
    unless selected.isAppOfArity ``Option.some 2 do throwError "slice byte notes absent for {owner}"
    let bytes := selected.getAppArgs[1]!
    let expressions ←if bytes.isAppOfArity ``literalI32Bytes 1 then
        mkAppM ``signedMeanings #[bytes.getAppArgs[0]!]
      else if bytes.isAppOfArity ``literalShapeByteNotes 1 then pure bytes.getAppArgs[0]!
      else throwError "unexpected current byte-note representation {bytes.getAppFn}"
    Parametric.Driver.addData ((←getCurrNamespace)++name) expressions

def countRole : Annotated.Value := .exactInteger (.lit (F64.ofNat 3))

theorem count_schema : FixedIntegerRole countRole 3 :=
  .exact (.lit (F64.ofNat 3)) 3 (fun _ => rfl) (by decide +kernel)

theorem current_control (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (sliceReadyNotes notes caller).runtime.control = callNote (.obj Slice1086.Normalized.address) (.obj 4817)
      (SliceFamilyHost.literalSliceArgumentNotes Slice1086.Normalized.out Slice1086.Normalized.handle
        Slice1086.Normalized.start Slice1086.Normalized.stop Slice1086.Normalized.stride
        Slice1086.Normalized.stream countRole countRole countRole) := by host_kernel_rfl

theorem output_selected (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (sliceReadyNotes notes caller).buffers.owners Slice1086.Normalized.out = some (handleSlotNotes 0) := by host_kernel_rfl
theorem start_selected (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (sliceReadyNotes notes caller).buffers.owners Slice1086.Normalized.start =
      some (literalShapeByteNotes startExpressions) := by host_kernel_rfl
theorem stop_selected (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (sliceReadyNotes notes caller).buffers.owners Slice1086.Normalized.stop =
      some (literalShapeByteNotes stopExpressions) := by host_kernel_rfl
theorem stride_selected (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (sliceReadyNotes notes caller).buffers.owners Slice1086.Normalized.stride =
      some (literalShapeByteNotes strideExpressions) := by host_kernel_rfl

theorem start_closed : startExpressions.all SymE.closed = true := by decide +kernel
theorem stop_closed : stopExpressions.all SymE.closed = true := by decide +kernel
theorem stride_closed : strideExpressions.all SymE.closed = true := by decide +kernel

end Host.Load.Run.Full.Ordinary.RetainedOracleConvolutionBatch

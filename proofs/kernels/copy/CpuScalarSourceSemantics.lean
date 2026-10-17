import kernels.copy.CpuScalarSourceSyntax
import contracts.mlx.HalfMemory
namespace Inference.Kernels.Copy.CpuScalarSourceSemantics
open Contracts.Mlx CpuScalarSourceSyntax
set_option maxRecDepth 10000

inductive Backend where | fallback | arm deriving DecidableEq, Repr

def nan (word : BitVec 32) : Bool := ((word >>> 23) &&& 255)==255 && (word &&& 8388607)!=0

def rounded (roundingProgram : Rounding) (word : BitVec 32) : BitVec 16 :=
  ((word+((word >>> roundingProgram.shift) &&& BitVec.ofNat 32 roundingProgram.parityMask)+BitVec.ofNat 32 roundingProgram.bias) >>> roundingProgram.resultShift).setWidth 16

def rne (word : BitVec 32) : BitVec 16 := if nan word then 32704 else rounded rounding word

-- These are explicit native primitive/ABI contracts, not conclusions about
-- the machine running Lean. In particular ARM feature selection is supplied,
-- never inferred from the M1 Max name. The conversion contract is general RNE
-- for non-NaN words, not a premise that the requested BF16 output is zero.
structure Host where
  integerToFloat : Nat → BitVec 32
  integerZero : integerToFloat 0=0
  armBfloat : BitVec 32 → BitVec 16
  armRne : ∀ word, nan word=false → armBfloat word=rne word
  write16 : ByteMemory.Bytes → Nat → BitVec 16 → ByteMemory.Bytes
  write32 : ByteMemory.Bytes → Nat → BitVec 32 → ByteMemory.Bytes
  little16 : ∀ before address value, write16 before address value=HalfMemory.store before address value
  little32 : ∀ before address value, write32 before address value=ByteMemory.store32 before address value

def convert (host : Host) : Backend → Rounding → BitVec 32 → BitVec 16
  | .fallback,roundingProgram,word => if nan word then 32704 else rounded roundingProgram word
  | .arm,_,word => host.armBfloat word

theorem nan_zero : nan 0=false := by decide +kernel
theorem rounded_zero : rounded rounding 0=0 := by decide +kernel
theorem rne_zero : rne 0=0 := by rw [rne,nan_zero]; exact rounded_zero

theorem convert_zero (host : Host) (backend : Backend) : convert host backend rounding 0=0 := by
  cases backend with
  | fallback => simp only [convert,nan_zero,Bool.false_eq_true,ite_false,rounded_zero]
  | arm => exact (host.armRne 0 nan_zero).trans rne_zero

-- The constructor parser accepts only Shape{}, whose empty product is one.
-- Linking that descriptor to the native ArrayDesc and allocation/pointer is
-- an external frontend/allocator boundary, not an assumed scalar byte value.
def descriptorSize : Nat := ([] : List Nat).prod
def allocatedBytes (kind : Kind) : Nat := descriptorSize*itemBytes kind

def coherent (call : ZeroCall) (ctor : Constructor) (init : Init) (branch : Copy) (kind : Kind) : Bool :=
  ctor.argumentType=="T" && ctor.argument==ctor.initArgument && ctor.dtypeArgument==ctor.descriptorDtype &&
  call.dtypeVariable==ctor.dtypeArgument && init.allocationCount=="size" && init.allocationDtype=="dtype" &&
  init.selector==init.allocationDtype && branch.begin==init.source && branch.endBase==init.source &&
  branch.count==init.allocationCount && branch.dtypeName==dtype kind && branch.outputType==ctype kind

def execute (callSource ctorSource selectedSource : String) (kind : Kind) (backend : Backend)
    (host : Host) (before : ByteMemory.Bytes) (base : Nat) : Option ByteMemory.Bytes := do
  let call ←parseZeroCall callSource
  let ctor ←parseConstructor ctorSource
  let init ←parseInit selectedSource
  let branch ←selected kind init
  if coherent call ctor init branch kind && descriptorSize==1 then
    let input := host.integerToFloat call.value
    match kind with
    | .bf16 =>
      let roundingProgram ←parseRounding roundingSource
      pure (host.write16 before base (convert host backend roundingProgram input))
    | .fp32 => pure (host.write32 before base input)
  else none

def selectedExecute (kind : Kind) (backend : Backend) (host : Host) (before : ByteMemory.Bytes) (base : Nat) : Option ByteMemory.Bytes :=
  execute zeroCallSource constructorSource (selectedInitSource kind) kind backend host before base

theorem execute_bf16 (host : Host) (backend : Backend) (before : ByteMemory.Bytes) (base : Nat) :
    selectedExecute .bf16 backend host before base=some (HalfMemory.store before base 0) := by
  simp only [selectedExecute,execute,parsed_zero,parsed_constructor,parsed_selected_init,parsed_rounding]
  change some (host.write16 before base (convert host backend rounding (host.integerToFloat 0)))=some (HalfMemory.store before base 0)
  rw [host.integerZero,convert_zero,host.little16]

theorem execute_fp32 (host : Host) (backend : Backend) (before : ByteMemory.Bytes) (base : Nat) :
    selectedExecute .fp32 backend host before base=some (ByteMemory.store32 before base 0) := by
  simp only [selectedExecute,execute,parsed_zero,parsed_constructor,parsed_selected_init]
  change some (host.write32 before base (host.integerToFloat 0))=some (ByteMemory.store32 before base 0)
  rw [host.integerZero,host.little32]

theorem allocation_bytes : allocatedBytes .bf16=2 ∧ allocatedBytes .fp32=4 := by decide +kernel
end Inference.Kernels.Copy.CpuScalarSourceSemantics

import kernels.delta.GatedOutputSource

namespace Inference.Kernels.Delta.GatedHostSelection

-- Reviewed translation of getKernel/launchRecurrence and the entrypoint's
-- inference branch. This is not a TypeScript frontend, a native descriptor
-- extraction proof, or a proof of custom-kernel compilation/submission.
inductive Dtype where | bfloat16 | float32 | int32 deriving DecidableEq,Repr
structure Metadata where
  batch : Nat
  time : Nat
  keyHeads : Nat
  keyWidth : Nat
  valueHeads : Nat
  valueWidth : Nat
  queryType : Dtype
  deriving DecidableEq,Repr
structure Output where
  shape : List Nat
  dtype : Dtype
  deriving DecidableEq,Repr
structure Launch where
  masked : Bool
  inputs : List String
  outputNames : List String
  timeValues : List Nat
  timeShape : List Nat
  timeType : Dtype
  outputs : List Output
  grid : List Nat
  group : List Nat
  templateInts : List (String × Nat)
  templateDtypes : List (String × Dtype)
  contiguous : Bool
  deriving DecidableEq,Repr

def launch (m : Metadata) (masked : Bool) : Launch :=
  ⟨masked,["q","k","v","g","beta","state_in","Tin"]++(if masked then ["mask"] else []),
    ["y","state_out"],[m.time],[1],.int32,
    [⟨[m.batch,m.time,m.valueHeads,m.valueWidth],m.queryType⟩,
      ⟨[m.batch,m.valueHeads,m.valueWidth,m.keyWidth],.float32⟩],
    [32,m.valueWidth,m.batch*m.valueHeads],[32,4,1],
    [("Dk",m.keyWidth),("Dv",m.valueWidth),("Hk",m.keyHeads),("Hv",m.valueHeads)],
    [("InT",m.queryType),("StT",.float32)],true⟩

inductive Entry where
  | rejected | training | inference : Launch → Bool → Entry
  deriving DecidableEq,Repr

def entry (m : Metadata) (differentiable masked statePresent : Bool) : Entry :=
  if differentiable && masked then .rejected
  else if differentiable then .training
  else .inference (launch m masked) (!statePresent)

def selected : Metadata := ⟨1,1,16,128,48,128,.bfloat16⟩
def expected : Launch :=
  ⟨false,["q","k","v","g","beta","state_in","Tin"],["y","state_out"],[1],[1],.int32,
    [⟨[1,1,48,128],.bfloat16⟩,⟨[1,48,128,128],.float32⟩],[32,128,48],[32,4,1],
    [("Dk",128),("Dv",128),("Hk",16),("Hv",48)],[("InT",.bfloat16),("StT",.float32)],true⟩

theorem selected_launch : launch selected false=expected := by decide +kernel
theorem selected_entry (statePresent : Bool) :
    entry selected false false statePresent=.inference expected (!statePresent) := by
  cases statePresent <;> decide +kernel

-- The launch's local x coordinate is a SIMD lane; four local y rows are
-- independent SIMD groups. Actual Metal builtin interpretation is explicit.
theorem selected_geometry (head : Fin 48) (row : Fin 128) (lane : Fin 32) :
    lane.val<32 ∧ row.val<128 ∧ head.val<48 ∧
    row.val/4<32 ∧ row.val%4<4 ∧ (row.val/4)*4+row.val%4=row.val ∧
    ((row.val%4)*32+lane.val)%32=lane.val := by
  have := head.isLt
  have := row.isLt
  have := lane.isLt
  omega

theorem selected_types :
    expected.timeValues=[1] ∧ expected.timeType=.int32 ∧
    expected.templateDtypes=[("InT",.bfloat16),("StT",.float32)] ∧ expected.contiguous=true :=
  ⟨rfl,rfl,rfl,rfl⟩

end Inference.Kernels.Delta.GatedHostSelection

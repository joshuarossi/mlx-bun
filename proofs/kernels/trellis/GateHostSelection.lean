import kernels.trellis.DownHostSelection
namespace Inference.Kernels.Trellis.GateHostSelection
set_option maxRecDepth 10000

-- Reviewed host translation, not a TypeScript frontend/native descriptor
-- proof. Metadata and contiguous reshape attachments remain native boundaries.
-- The selected integer arithmetic is exactly representable as JS Number;
-- the guarded 0..12 level also makes (4 << L) equal to 4*2^L.
inductive Tail where
  | float | split
  deriving DecidableEq,Repr
structure Geometry where
  axis : Nat
  rows : Nat
  cols : Nat
  block : Nat
  level : Nat
  width : Nat
  inFeatures : Nat
  deriving DecidableEq,Repr
structure Input where
  size : Nat
  lastExtent : Nat
  leading : List Nat
  dtype : DownHostSelection.Dtype
  deriving DecidableEq,Repr
structure Launch where
  reshapeInput : List Nat
  shape : List Nat
  reshapeOutput : List Nat
  dtype : DownHostSelection.Dtype
  grid : List Nat
  threadGroup : List Nat
  templateDtype : DownHostSelection.Dtype
  templates : List (String × Nat)
  deriving DecidableEq,Repr

def groups : Nat := 160
def threads : Nat := 1024
def simds : Nat := 32

def tailCode (gateWidth upWidth : Nat) (preference : Tail) : Nat :=
  if gateWidth≠upWidth ∧ preference=.split then 1 else 0

def select (input : Input) (gate up : Geometry) (preference : Tail) : Option Launch :=
  if gate.axis≠1 ∨ up.axis≠1 ∨ gate.rows≠up.rows ∨ gate.cols≠up.cols ∨ gate.block≠up.block ∨ gate.level≠up.level ∨ gate.level>12 then none
  else if input.size≠input.lastExtent then none
  else if 4*2^gate.level+2*gate.cols>32768 then none
  else some ⟨[1,gate.inFeatures],[1,gate.rows],input.leading++[gate.rows],input.dtype,
    [threads,min groups ((gate.rows+simds-1)/simds),1],[threads,1,1],input.dtype,
    [("R",gate.rows),("C",gate.cols),("BT",gate.block),("KG",gate.width),("KU",up.width),("L",gate.level),
      ("ROWS_TG",simds),("THREADS",threads),("TAIL",tailCode gate.width up.width preference)]⟩

def geometry (width : Nat) : Geometry := ⟨1,17408,5120,256,12,width,5120⟩
def single : Input := ⟨5120,5120,[1],.bfloat16⟩
def expected (gateWidth upWidth : Nat) (preference : Tail) : Launch :=
  ⟨[1,5120],[1,17408],[1,17408],.bfloat16,[1024,160,1],[1024,1,1],.bfloat16,
    [("R",17408),("C",5120),("BT",256),("KG",gateWidth),("KU",upWidth),("L",12),
      ("ROWS_TG",32),("THREADS",1024),("TAIL",tailCode gateWidth upWidth preference)]⟩

theorem selected_launch (gateWidth upWidth : Nat) (preference : Tail) :
    select single (geometry gateWidth) (geometry upWidth) preference=some (expected gateWidth upWidth preference) := by
  simp [select,single,geometry,groups,threads,simds,expected]

theorem same_width_tail (width : Nat) (preference : Tail) : tailCode width width preference=0 := by
  simp [tailCode]

theorem float_tail (gateWidth upWidth : Nat) : tailCode gateWidth upWidth .float=0 := by
  simp [tailCode]

theorem split_tail (gateWidth upWidth : Nat) (different : gateWidth≠upWidth) :
    tailCode gateWidth upWidth .split=1 := by simp [tailCode,different]

theorem workspace : 4*2^12+2*5120=26624 ∧ 26624≤32768 := by decide

end Inference.Kernels.Trellis.GateHostSelection

import kernels.trellis.DownPipelineSource
namespace Inference.Kernels.Trellis.DownHostSelection

-- Reviewed translation of down-codebook.ts's host decisions, not a
-- TypeScript frontend or Metal descriptor/submission proof. Native array
-- metadata and ensureRowContiguous's attachment remain explicit boundaries.
-- Arithmetic here models the selected exactly representable integer values
-- of JavaScript Number, rather than claiming arbitrary Nat/Number equivalence.
inductive Dtype where
  | bfloat16 | float16 | float32
  deriving DecidableEq,Repr
structure Metadata where
  activationRows : Nat
  dtype : Dtype
  codeRank : Nat
  axis : Nat
  block : Nat
  level : Nat
  rows : Nat
  cols : Nat
  width : Nat
  blockInterleave : Nat
  deriving DecidableEq,Repr
structure Dispatch where
  grid : List Nat
  threadGroup : List Nat
  shape : List Nat
  dtype : Dtype
  templateDtype : Dtype
  templates : List (String × Nat)
  deriving DecidableEq,Repr
structure Launch where
  interleave : Bool
  producer : Dispatch
  fold : Dispatch
  deriving DecidableEq,Repr

def splits : Nat := 128
def positions : Nat := 16
def unroll : Nat := 2
def threads : Nat := 256

def ceilDiv (value divisor : Nat) : Nat := (value+divisor-1)/divisor

def launch (metadata : Metadata) (interleave : Bool) : Option Launch :=
  if metadata.activationRows≠1 then none
  else if metadata.axis≠0 ∨ metadata.block≠256 ∨ metadata.level>12 ∨ metadata.cols%256≠0 then none
  else
    let groupsPerSplit := ceilDiv (metadata.cols/256) (positions/8)
    some ⟨interleave,
      ⟨[threads,32*ceilDiv groupsPerSplit 2,1],[threads,1,1],[1,32,metadata.cols],.float32,metadata.dtype,
        [("R",metadata.rows),("C",metadata.cols),("K",metadata.width),("L",metadata.level),
          ("P",positions),("U",unroll),("SPLITS",splits),("THREADS",threads),("INTERLEAVE",if interleave then 1 else 0)]⟩,
      ⟨[8*32*metadata.cols/32,1,1],[8*32,1,1],[1,metadata.cols],metadata.dtype,metadata.dtype,[("C",metadata.cols)]⟩⟩

def rowMajor (metadata : Metadata) : Option Launch :=
  if metadata.blockInterleave≠0 ∨ metadata.codeRank≠2 ∨ (metadata.width≠2 ∧ metadata.width≠4) then none
  else launch metadata false

def interleaved (metadata : Metadata) : Option Launch :=
  if metadata.blockInterleave≠2 ∨ metadata.width≠3 then none else launch metadata true

def selected (width : Nat) : Metadata :=
  ⟨1,.bfloat16,if width=3 then 3 else 2,0,256,12,17408,5120,width,if width=3 then 2 else 0⟩

def select (metadata : Metadata) : Option Launch :=
  if metadata.width=3 then interleaved metadata else rowMajor metadata

def expected (width : Nat) : Launch :=
  ⟨decide (width=3),
    ⟨[256,160,1],[256,1,1],[1,32,5120],.float32,.bfloat16,
      [("R",17408),("C",5120),("K",width),("L",12),("P",16),("U",2),("SPLITS",128),("THREADS",256),
        ("INTERLEAVE",if width=3 then 1 else 0)]⟩,
    ⟨[40960,1,1],[256,1,1],[1,5120],.bfloat16,.bfloat16,[("C",5120)]⟩⟩

theorem selected_launch (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4) :
    select (selected width)=some (expected width) := by
  rcases valid with rfl | rfl | rfl <;> decide

theorem selected_partial_groups (width : Nat) :
    (expected width).producer.grid=[256,160,1] := rfl

theorem selected_fold_groups (width : Nat) :
    (expected width).fold.grid.head!/ (expected width).fold.threadGroup.head! = 160 := by
  change 40960/256=160
  omega

theorem selected_buffers (width : Nat) :
    (expected width).producer.shape=[1,32,5120] ∧
    (expected width).producer.dtype=.float32 ∧
    (expected width).fold.shape=[1,5120] ∧
    (expected width).fold.dtype=.bfloat16 ∧ (expected width).fold.templateDtype=.bfloat16 := by
  exact ⟨rfl,rfl,rfl,rfl,rfl⟩

end Inference.Kernels.Trellis.DownHostSelection

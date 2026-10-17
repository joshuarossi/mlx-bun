import kernels.trellis.PackedArrayGate
namespace Inference.Kernels.Trellis.PackedArrayDown
open PackedArraySyntax PackedArraySemantics PackedArrayPrograms
set_option maxRecDepth 10000

def count (k : Nat) : Nat := (15*k+43)/32
def loadedCount (k : Nat) : Nat := count k+(if (16*k)%32=0 then 0 else 1)
def initial (k lane : Nat) : State := ⟨[
  ("NL",.unsigned (BitVec.ofNat 32 (loadedCount k))),
  ("NA",.unsigned (BitVec.ofNat 32 (count k))),
  ("U",.signed 2),("u",.unsigned 0),
  ("first",.unsigned (BitVec.ofNat 32 (lane*(16*k)/32))),
  ("WPB",.unsigned (BitVec.ofNat 32 (8*k))),
  ("SHIFT",.unsigned (BitVec.ofNat 32 ((16*k)%32))),
  ("shifted",.boolean (decide (k=3 ∧ lane%2=1))),
  ("rowWords",.address "row0" 0)],[],["rowWords"]⟩

def selectRow (state : State) (row : Nat) : State :=
  putVariable (putVariable state "u" (some (.unsigned (BitVec.ofNat 32 row))))
    "rowWords" (some (.address (if row=0 then "row0" else "row1") 0))

def indexResult (k lane : Nat) : Option State := execute 16 downIndexProgram (initial k lane)

def pairLoads (k lane : Nat) : Option State := do
  let state ←indexResult k lane
  let state ←execute 16 downPairLoadProgram state
  execute 16 [downLoadAST true] (selectRow state 1)

def tailLoads (k lane : Nat) : Option State := do
  let state ←indexResult k lane
  execute 16 downTailLoadProgram state

def result (paired : Bool) (k lane row : Nat) : Option State := do
  let state ←if paired then pairLoads k lane else tailLoads k lane
  execute 16 (downAlignProgram paired) (selectRow state row)

def localCell (paired : Bool) (k lane row : Nat) (virtual : Bool) (index : Nat) : Option Value := do
  let state ←result paired k lane row
  cell state (if virtual then "v" else "w") [index]

def sourceWord (row k lane index : Nat) : Word := .global "rowWords"
  (.relative (if row=0 then "row0" else "row1")
    (BitVec.ofNat 32 ((lane*(16*k)/32+index)%(8*k))))

def alignedWord (row k lane index : Nat) : Word :=
  if k=3 ∧ lane%2=1 then .bitOr (.shiftRight (sourceWord row k lane index) 16)
    (.shiftLeft (sourceWord row k lane (index+1)) 16) else sourceWord row k lane index

def virtualWord (row k lane index : Nat) : Word :=
  if index=0 then .shiftLeft (alignedWord row k lane 0) 16 else
    .bitOr (.shiftRight (alignedWord row k lane (index-1)) 16) (.shiftLeft (alignedWord row k lane index) 16)

-- These certify successful source execution and initialized/bounded private
-- reads. In particular, SHIFT=0 never evaluates the untaken shift-by-32 arm.
theorem tail_closed : ∀ k : Fin 3, ∀ lane : Fin 16, ∀ virtual : Bool,
    ∀ index : Fin (count (PackedArrayGate.width k)),
    localCell false (PackedArrayGate.width k) lane.val 0 virtual index.val=
      some (.word (if virtual then virtualWord 0 (PackedArrayGate.width k) lane.val index.val
        else alignedWord 0 (PackedArrayGate.width k) lane.val index.val)) := by decide +kernel

theorem pair_closed : ∀ k : Fin 3, ∀ lane : Fin 16, ∀ row : Fin 2, ∀ virtual : Bool,
    ∀ index : Fin (count (PackedArrayGate.width k)),
    localCell true (PackedArrayGate.width k) lane.val row.val virtual index.val=
      some (.word (if virtual then virtualWord row.val (PackedArrayGate.width k) lane.val index.val
        else alignedWord row.val (PackedArrayGate.width k) lane.val index.val)) := by decide +kernel
end Inference.Kernels.Trellis.PackedArrayDown

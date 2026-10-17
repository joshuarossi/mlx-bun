import kernels.trellis.PackedArrayPrograms
namespace Inference.Kernels.Trellis.PackedArrayGate
open PackedArraySyntax PackedArraySemantics PackedArrayPrograms
set_option maxRecDepth 10000

def width (index : Fin 3) : Nat := index.val+2

def initial (kg ku run : Nat) : State := ⟨[
  ("KG",.signed kg),("KU",.signed ku),("gw",.address "gw" 0),("uw",.address "uw" 0),
  ("gW0",.unsigned (BitVec.ofNat 32 ((7-run)*kg))),
  ("uW0",.unsigned (BitVec.ofNat 32 ((7-run)*ku))),
  ("t0",.unsigned (BitVec.ofNat 32 (run*32)))],[],["gcodes","ucodes"]⟩

def result (kg ku run : Nat) : Option State := execute 16 gateProgram (initial kg ku run)

def localCell (kg ku run : Nat) (isUp virtual : Bool) (index : Nat) : Option Value := do
  let state ←result kg ku run
  cell state (if isUp then if virtual then "uv" else "u" else if virtual then "gv" else "g") [index]

def delta (k run index : Nat) : Nat :=
  if index<k then (7-run)*k+index else if run=0 then 0 else (7-run)*k+k

def sourceWord (isUp : Bool) (k run index : Nat) : Word :=
  .global (if isUp then "ucodes" else "gcodes")
    (.relative (if isUp then "uw" else "gw") (BitVec.ofNat 32 (delta k run index)))

def virtualWord (isUp : Bool) (k run index : Nat) : Word :=
  if index=0 then .shiftLeft (sourceWord isUp k run 0) 16 else
    .bitOr (.shiftRight (sourceWord isUp k run (index-1)) 16) (.shiftLeft (sourceWord isUp k run index) 16)

-- Selected private-array closure: declaration capacities, initialized loads,
-- strided/wrap global indices and both halves of every virtual word.
theorem closed : ∀ kg ku : Fin 3, ∀ run : Fin 8, ∀ isUp virtual : Bool,
    ∀ index : Fin ((if isUp then width ku else width kg)+1),
    localCell (width kg) (width ku) run.val isUp virtual index.val=
      some (.word (if virtual then virtualWord isUp (if isUp then width ku else width kg) run.val index.val
        else sourceWord isUp (if isUp then width ku else width kg) run.val index.val)) := by decide +kernel

attribute [local irreducible] execute loop

theorem result_eq (kg ku run : Nat) : result kg ku run=execute 16 gateProgram (initial kg ku run) := rfl

theorem from_source (kg ku run : Nat) :
    sourceExecute gateSources (initial kg ku run)=result kg ku run := by
  exact (sourceExecute_parsed gateSources gateProgram parsed_gate (initial kg ku run)).trans
    (result_eq kg ku run).symm
end Inference.Kernels.Trellis.PackedArrayGate

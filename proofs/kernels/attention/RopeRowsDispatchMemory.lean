import kernels.attention.RopeRowsCopyMemory

namespace Inference.Kernels.Attention.RopeRowsDispatchMemory
open Contracts.Mlx
open RopeRowsMemory
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000
variable {rows base : Nat} {x : Fin rows → Fin 256 → BF}

-- Pinned backend/common/copy.h reuses storage only for Vector copies
-- accepted by is_donatable. metal/copy.cpp then skips same-dtype copies.
-- BF16 input/output have the same dtype in this partial-RoPE route.
inductive CopyKind where
  | vector | general
  deriving DecidableEq

def reusesStorage (kind : CopyKind) (donatable : Bool) : Bool := kind==.vector && donatable

theorem general_allocates (donatable : Bool) : reusesStorage .general donatable=false := rfl

theorem vector_reuses : reusesStorage .vector true=true := rfl

theorem vector_allocates : reusesStorage .vector false=false := rfl

inductive Preparation (source : Input x base) where
  | donation : Preparation source
  | copy : RopeRowsCopyMemory.Copy source → Preparation source

variable {source : Input x base}

def Preparation.destination : Preparation source → Nat
  | Preparation.donation => base
  | Preparation.copy allocation => allocation.destination

def Preparation.output : (preparation : Preparation source) → Input x preparation.destination
  | Preparation.donation => source
  | Preparation.copy allocation => allocation.output

def Preparation.selected (source : Input x base) (kind : CopyKind) (donatable : Bool)
    (allocation : RopeRowsCopyMemory.Copy source) : Preparation source :=
  if reusesStorage kind donatable then .donation else .copy allocation

theorem Preparation.selected_reuses (source : Input x base) (kind : CopyKind) (donatable : Bool)
    (allocation : RopeRowsCopyMemory.Copy source) (reuse : reusesStorage kind donatable=true) :
    Preparation.selected source kind donatable allocation=.donation := by
  simp only [Preparation.selected,reuse,ite_true]

theorem Preparation.selected_copies (source : Input x base) (kind : CopyKind) (donatable : Bool)
    (allocation : RopeRowsCopyMemory.Copy source) (allocate : reusesStorage kind donatable=false) :
    Preparation.selected source kind donatable allocation=.copy allocation := by
  simp only [Preparation.selected,allocate,Bool.false_eq_true,ite_false]

theorem Preparation.frame (preparation : Preparation source) (address : Nat)
    (outside : address<preparation.destination ∨ preparation.destination+512*rows≤address) :
    preparation.output.memory address=source.memory address := by
  cases preparation with
  | donation => rfl
  | copy copy => exact copy.frame address outside

structure Execution (p : Rope.Platform) (source : Input x base) (theta : Fin rows → Fin 32 → Float32) where
  preparation : Preparation source
  rotation : RopeRowsDynamicMemory.Execution p preparation.output theta

variable {p : Rope.Platform} {theta : Fin rows → Fin 32 → Float32}

def Execution.destination (execution : Execution p source theta) : Nat := execution.preparation.destination

def Execution.output (execution : Execution p source theta) :
    Input (fun head => Rope.head p (x head) (theta head)) execution.destination := execution.rotation.output

theorem Execution.frame (execution : Execution p source theta) (address : Nat)
    (outside : address<execution.destination ∨ execution.destination+512*rows≤address) :
    execution.output.memory address=source.memory address :=
  (execution.rotation.frame address outside).trans (execution.preparation.frame address outside)

def Execution.fromPreparation (p : Rope.Platform) (source : Input x base) (theta : Fin rows → Fin 32 → Float32)
    (preparation : Preparation source) : Execution p source theta :=
  ⟨preparation,RopeRowsDynamicMemory.Execution.canonical p preparation.output theta⟩

def Execution.donation (p : Rope.Platform) (source : Input x base) (theta : Fin rows → Fin 32 → Float32) : Execution p source theta :=
  ⟨.donation,RopeRowsDynamicMemory.Execution.canonical p source theta⟩

def Execution.copy (p : Rope.Platform) (source : Input x base) (theta : Fin rows → Fin 32 → Float32)
    (allocation : RopeRowsCopyMemory.Copy source) : Execution p source theta :=
  ⟨.copy allocation,RopeRowsDynamicMemory.Execution.canonical p allocation.output theta⟩

def Execution.selected (p : Rope.Platform) (source : Input x base) (theta : Fin rows → Fin 32 → Float32)
    (kind : CopyKind) (donatable : Bool) (allocation : RopeRowsCopyMemory.Copy source) : Execution p source theta :=
  let preparation := Preparation.selected source kind donatable allocation
  ⟨preparation,RopeRowsDynamicMemory.Execution.canonical p preparation.output theta⟩

theorem Execution.donation_before (p : Rope.Platform) (source : Input x base) (theta : Fin rows → Fin 32 → Float32) :
    (Execution.donation p source theta).preparation.output.memory=source.memory := rfl

theorem Execution.donation_destination (p : Rope.Platform) (source : Input x base) (theta : Fin rows → Fin 32 → Float32) :
    (Execution.donation p source theta).destination=base := rfl

theorem Execution.read (execution : Execution p source theta) (head : Fin rows) (i : Fin 256) :
    HalfMemory.load execution.output.memory (execution.destination+512*head.val+2*i.val)=
      ArrayStorage.bits (Rope.head p (x head) (theta head) i) := execution.output.attached head i

end Inference.Kernels.Attention.RopeRowsDispatchMemory

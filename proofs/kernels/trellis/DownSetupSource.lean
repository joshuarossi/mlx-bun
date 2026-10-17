import kernels.trellis.GatePointerSyntax
import kernels.trellis.PackedArrayDownMaterialization
namespace Inference.Kernels.Trellis.DownSetupSource
open Copy.ScalarCopySyntax (Parser accept)
open PackedArraySyntax PackedArraySemantics
set_option maxRecDepth 100000

def declaration : Parser GatePointerSyntax.Declaration := fun ts => do
  let ts ←accept "constexpr" ts
  let ts ←match ts with
    | "uint"::rest | "bool"::rest => some rest
    | _ => none
  GatePointerSyntax.bindings 4 ts

def parse (source : String) : Option GatePointerSyntax.Declaration := do
  let (code,rest) ←declaration (←tokenize source)
  if rest=[] then some code else none

def bitsSource : String := "constexpr uint BITS = (uint)(P * K);"
def shiftSource : String := "constexpr uint SHIFT = BITS % 32u;"
def alignedSource : String := "constexpr bool ALIGNED = SHIFT == 0u;"
def countSource : String := "constexpr uint NA = (BITS + (uint)L - (uint)K + 31u) / 32u;"
def loadedSource : String := "constexpr uint NL = ALIGNED ? NA : NA + 1u;"
def lanesSource : String := "constexpr uint LB = 256u / (uint)P;"
def wordsSource : String := "constexpr uint WPB = 8u * (uint)K;"
def blocksSource : String := "constexpr uint NB = (uint)(C / 256);"
def localSource : String := "const uint li = lane % LB;"
def firstSource : String := "const uint first = (li * BITS) >> 5;"
def sources : List String := [bitsSource,shiftSource,alignedSource,countSource,loadedSource,lanesSource,wordsSource,blocksSource]

def executeBinding (state : State) (binding : String × Expr) : Option State :=
  (evaluate 16 state binding.2).map (fun value => putVariable state binding.1 (some value))
def executeDeclaration (state : State) (code : GatePointerSyntax.Declaration) : Option State :=
  code.foldlM executeBinding state

def initial (k lane : Nat) : State := ⟨[
  ("P",.signed 16),("K",.signed k),("L",.signed 12),("C",.signed 5120),
  ("lane",.unsigned (BitVec.ofNat 32 lane))],[],[]⟩

def setup (k lane : Nat) : Option State :=
  (sources.mapM parse).bind (fun code =>
    (code.foldlM executeDeclaration (initial k lane)).bind (fun state =>
      (GatePointerSyntax.parse localSource).bind (fun localCode =>
        (executeDeclaration state localCode).bind (fun localState =>
          (GatePointerSyntax.parse firstSource).bind (executeDeclaration localState)))))

def expected (k lane : Nat) : List (String × Value) := [
  ("first",.unsigned (BitVec.ofNat 32 ((lane%16)*(16*k)/32))),
  ("li",.unsigned (BitVec.ofNat 32 (lane%16))),
  ("NB",.unsigned 20),("WPB",.unsigned (BitVec.ofNat 32 (8*k))),
  ("LB",.unsigned 16),("NL",.unsigned (BitVec.ofNat 32 (PackedArrayDown.loadedCount k))),
  ("NA",.unsigned (BitVec.ofNat 32 (PackedArrayDown.count k))),
  ("ALIGNED",.boolean (decide ((16*k)%32=0))),
  ("SHIFT",.unsigned (BitVec.ofNat 32 ((16*k)%32))),
  ("BITS",.unsigned (BitVec.ofNat 32 (16*k)))]

theorem setup_selected : ∀ k : Fin 3, ∀ lane : Fin 32,
    (setup (PackedArrayGate.width k) lane.val).map State.variables=
      some (expected (PackedArrayGate.width k) lane.val ++ (initial (PackedArrayGate.width k) lane.val).variables) := by decide +kernel

-- Equality is derived from execution, rather than supplied array dimensions
-- or a supplied initial word offset. Other native setup fields remain separate.
attribute [local irreducible] setup expected initial

theorem setup_value (k lane : Nat) (valid : k=2 ∨ k=3 ∨ k=4) (laneBound : lane<32) (name : String) :
    ((setup k lane).bind (fun state => lookupVariable state name))=
      lookup name (expected k lane ++ (initial k lane).variables) := by
  have result := setup_selected (PackedArrayMaterialization.widthIndex k valid) ⟨lane,laneBound⟩
  simp only [PackedArrayMaterialization.width_index] at result
  cases actual : setup k lane with
  | none => simp only [actual,Option.map_none] at result; have impossible := congrArg Option.isSome result; cases impossible
  | some state =>
    simp only [actual,Option.map_some,Option.some.injEq] at result
    simp only [Option.bind_some,lookupVariable,result]
def privateName (i : Fin 5) : String := ["NL","NA","first","WPB","SHIFT"][i.val]!

theorem private_parameters_closed : ∀ k : Fin 3, ∀ lane : Fin 32, ∀ i : Fin 5,
    lookup (privateName i) (expected (PackedArrayGate.width k) lane.val ++ (initial (PackedArrayGate.width k) lane.val).variables)=
      lookupVariable (PackedArrayDown.initial (PackedArrayGate.width k) (lane.val%16)) (privateName i) := by
  unfold expected initial
  decide +kernel

theorem private_parameters (k lane : Nat) (valid : k=2 ∨ k=3 ∨ k=4) (laneBound : lane<32) (i : Fin 5) :
    ((setup k lane).bind (fun state => lookupVariable state (privateName i)))=
      lookupVariable (PackedArrayDown.initial k (lane%16)) (privateName i) := by
  rw [setup_value k lane valid laneBound]
  have selected := private_parameters_closed (PackedArrayMaterialization.widthIndex k valid) ⟨lane,laneBound⟩ i
  simpa only [PackedArrayMaterialization.width_index] using selected
end Inference.Kernels.Trellis.DownSetupSource

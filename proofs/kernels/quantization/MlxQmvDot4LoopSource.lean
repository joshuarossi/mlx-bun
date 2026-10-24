import kernels.quantization.MlxQmvDot4Source
import kernels.trellis.PackedArraySyntax

namespace Inference.Kernels.Quantization.MlxQmvDot4LoopSource
open Contracts.Mlx MlxQmvDot4Source
open Copy.ScalarCopySyntax (Tokens accept decimal)
set_option maxRecDepth 10000

structure Header where
  initial : Nat
  limit : Nat
  deriving DecidableEq, Repr

def parseHeader (source : String) : Option Header := do
  let rest ←Trellis.PackedArraySyntax.tokenize source
  let rest ←accept "for" rest
  let rest ←accept "(" rest
  let rest ←accept "int" rest
  let rest ←accept "i" rest
  let rest ←accept "=" rest
  let initial::rest := rest | none
  let initial ←decimal initial
  let rest ←accept ";" rest
  let rest ←accept "i" rest
  let rest ←accept "<" rest
  let rest ←accept "(" rest
  let rest ←accept "values_per_thread" rest
  let rest ←accept "/" rest
  let divisor::rest := rest | none
  let divisor ←decimal divisor
  let rest ←accept ")" rest
  let limit := 16/divisor
  let rest ←accept ";" rest
  let rest ←accept "i" rest
  let rest ←accept "++" rest
  let rest ←accept ")" rest
  let rest ←accept "{" rest
  if rest=[] then some ⟨initial,limit⟩ else none

def sourceHeader : String := "for (int i = 0; i < (values_per_thread / 4); i++) {"
def header : Header := ⟨0,4⟩
theorem parsed_header : parseHeader sourceHeader=some header := by decide +kernel

def condition (h : Header) (index : Int) : Bool := decide (index<(h.limit:Int))
def advance (index : Int) : Option Int := signed (index+1)

-- Operational signed-int loop execution: a missing step or a truncated trace
-- cannot satisfy stop while the source condition is true.
inductive Runs (h : Header) (contracted : Nat → Bool) (memory : Memory) :
    Int → Float32 → List Int → Float32 → Prop where
  | stop (ended : condition h index=false) : Runs h contracted memory index acc [] acc
  | next (iteration : Fin 4) (sameIndex : index=(iteration.val:Int))
      (entered : condition h index=true)
      (step : MlxQmvDot4Source.executeSource contracted memory iteration acc=some after)
      (increment : advance index=some next)
      (rest : Runs h contracted memory next after visits result) :
      Runs h contracted memory index acc (index::visits) result

def step (contracted : Nat → Bool) (memory : Memory) (iteration : Fin 4) (acc : Float32) : Float32 :=
  MlxQmv.source4 contracted (word memory iteration) (input memory iteration) acc
def result (contracted : Nat → Bool) (memory : Memory) (initial : Float32) : Float32 :=
  (List.finRange 4).foldl (fun acc iteration => step contracted memory iteration acc) initial

theorem signed_increment : ∀ index : Fin 4, advance index.val=some (index.val+1:Int) := by decide +kernel

theorem step_execution (contracted : Nat → Bool) (memory : Memory) (iteration : Fin 4) (acc : Float32) :
    MlxQmvDot4Source.executeSource contracted memory iteration acc=some (step contracted memory iteration acc) :=
  MlxQmvDot4Source.execution contracted memory iteration acc

attribute [local irreducible] MlxQmvDot4Source.executeSource step

theorem execution (contracted : Nat → Bool) (memory : Memory) (initial : Float32) :
    Runs header contracted memory header.initial initial [0,1,2,3] (result contracted memory initial) := by
  let a1:=step contracted memory 0 initial
  let a2:=step contracted memory 1 a1
  let a3:=step contracted memory 2 a2
  let a4:=step contracted memory 3 a3
  have done : Runs header contracted memory 4 a4 [] a4 := .stop (by decide)
  have third : Runs header contracted memory 3 a3 [3] a4 :=
    .next 3 rfl (by decide) (step_execution contracted memory 3 a3)
      (signed_increment 3) done
  have second : Runs header contracted memory 2 a2 [2,3] a4 :=
    .next 2 rfl (by decide) (step_execution contracted memory 2 a2)
      (signed_increment 2) third
  have first : Runs header contracted memory 1 a1 [1,2,3] a4 :=
    .next 1 rfl (by decide) (step_execution contracted memory 1 a1)
      (signed_increment 1) second
  exact .next 0 rfl (by decide) (step_execution contracted memory 0 initial)
    (signed_increment 0) first

theorem parsed_execution (contracted : Nat → Bool) (memory : Memory) (initial : Float32) :
    ∃ h, parseHeader sourceHeader=some h ∧
      Runs h contracted memory h.initial initial [0,1,2,3] (result contracted memory initial) :=
  ⟨header,parsed_header,execution contracted memory initial⟩

end Inference.Kernels.Quantization.MlxQmvDot4LoopSource

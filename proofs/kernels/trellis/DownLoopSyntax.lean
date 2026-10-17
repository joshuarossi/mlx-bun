import kernels.trellis.DownStepSource
import kernels.trellis.GateLoopSource
namespace Inference.Kernels.Trellis.DownLoopSyntax
open Copy.ScalarCopySyntax (Parser accept nameToken)
open PackedArraySyntax
set_option maxRecDepth 10000
structure Loop where
  left : Expr
  strict : Bool
  right : Expr
  counter : String
  increment : Expr
  deriving Repr

def loopTokens : Parser Loop := fun ts => do
  let ts ←accept "(" (←accept "for" ts)
  let ts ←accept ";" ts
  let (left,ts) ←expression 16 0 ts
  let (strict,ts) ←match ts with
    | "<"::rest => some (true,rest)
    | "<="::rest => some (false,rest)
    | _ => none
  let (right,ts) ←expression 16 0 ts
  let ts ←accept ";" ts
  let (counter,increment,ts) ←match ts with
    | "++"::rest => do
      let (counter,rest) ←nameToken rest
      pure (counter,.literal .signed 1,rest)
    | rest => do
      let (counter,rest) ←nameToken rest
      let rest ←accept "+=" rest
      let (increment,rest) ←expression 16 0 rest
      pure (counter,increment,rest)
  let ts ←accept ")" ts
  let ts ←accept "{" ts
  pure (⟨left,strict,right,counter,increment⟩,ts)

def parseLoop (source : String) : Option Loop := do
  let (code,rest) ←loopTokens (←tokenize source)
  if rest=[] then some code else none

def initialTokens : Parser (String × Expr) := fun ts => do
  let ts ←accept "uint" ts
  let (name,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (value,ts) ←expression 8 0 ts
  let ts ←accept ";" ts
  pure ((name,value),ts)
def parseInitial (source : String) : Option (String × Expr) := do
  let (code,rest) ←initialTokens (←tokenize source)
  if rest=[] then some code else none

def initialSource : String := "uint r = 0;"
def pairSource : String := "for (; r + (uint)U <= rows; r += (uint)U) {"
def tailSource : String := "for (; r < rows; ++r) {"
def uSource : String := "for (uint u = 0; u < (uint)U; ++u) {"
def iSource : String := "for (uint i = 0; i < (uint)P; ++i) {"
def initial : String × Expr := ("r",.literal .signed 0)
def pair : Loop := ⟨.add (.variable "r") (.castUInt (.variable "U")),false,.variable "rows","r",.castUInt (.variable "U")⟩
def tail : Loop := ⟨.variable "r",true,.variable "rows","r",.literal .signed 1⟩
def ordinary (isI : Bool) : GateLoopSource.Loop := ⟨if isI then "i" else "u",.literal .signed 0,
  if isI then "i" else "u",.castUInt (.variable (if isI then "P" else "U")),
  if isI then "i" else "u",.literal .unsigned 1⟩
theorem parsed_initial : parseInitial initialSource=some initial := rfl
theorem parsed_pair : parseLoop pairSource=some pair := rfl
theorem parsed_tail : parseLoop tailSource=some tail := rfl
theorem parsed_ordinary : ∀ isI : Bool,
    GateLoopSource.parseLoop (if isI then iSource else uSource)=some (ordinary isI) := by
  intro isI; cases isI <;> rfl
end Inference.Kernels.Trellis.DownLoopSyntax

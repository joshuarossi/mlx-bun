import kernels.copy.ScalarCopySyntax

namespace Inference.Kernels.Normalization.MlxRmsOutputSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept)
set_option maxRecDepth 10000

-- Restricted grammar of rms_looped's output assignment. Both index orders,
-- the weight stride, and the inner cast remain syntax in the parsed tree.
inductive Expr where
  | var : String → Expr
  | zero : Expr
  | index : String → Expr → Expr
  | cast : String → Expr → Expr
  | add : Expr → Expr → Expr
  | mul : Expr → Expr → Expr
  deriving DecidableEq, Repr
structure Store where
  destination : String
  index : Expr
  value : Expr
  deriving DecidableEq, Repr

def letter (c : Char) : Bool :=
  ('a' ≤ c && c ≤ 'z') || ('A' ≤ c && c ≤ 'Z') || c == '_'
def word (c : Char) : Bool := letter c || ('0' ≤ c && c ≤ '9')
def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if [' ','\n','\t','\r'].contains c then lexAux fuel rest
    else if word c then do
      pure (String.ofList (c::rest.takeWhile word)::(←lexAux fuel (rest.dropWhile word)))
    else if ['(',')','[',']',';','+','*','=','<','>'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none
def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList
def nameToken : Parser String
  | token::rest => match token.toList with
    | c::cs => if letter c && cs.all word then some (token,rest) else none
    | [] => none
  | [] => none
def varExpr : Parser Expr := fun tokens => do
  let (name,rest) ←nameToken tokens
  pure (.var name,rest)
def zero : Parser Expr := fun tokens => do pure (.zero,←accept "0" tokens)
def binary (left : Parser Expr) (symbol : String) (right : Parser Expr)
    (constructor : Expr → Expr → Expr) : Parser Expr := fun tokens => do
  let (left,rest) ←left tokens
  let rest ←accept symbol rest
  let (right,rest) ←right rest
  pure (constructor left right,rest)
def sum : Parser Expr := binary varExpr "+" varExpr Expr.add
def product (left right : Parser Expr) : Parser Expr := binary left "*" right Expr.mul
def parenthesized (expression : Parser Expr) : Parser Expr := fun tokens => do
  let rest ←accept "(" tokens
  let (value,rest) ←expression rest
  pure (value,←accept ")" rest)
def indexed (expression : Parser Expr) : Parser Expr := fun tokens => do
  let (name,rest) ←nameToken tokens
  let rest ←accept "[" rest
  let (index,rest) ←expression rest
  pure (.index name index,←accept "]" rest)
def cast (expression : Parser Expr) : Parser Expr := fun tokens => do
  let rest ←accept "static_cast" tokens
  let rest ←accept "<" rest
  let (typeName,rest) ←nameToken rest
  let rest ←accept ">" rest
  let (value,rest) ←parenthesized expression rest
  pure (.cast typeName value,rest)
def parse (source : String) : Option Store := do
  let tokens ←tokenize source
  let (destination,rest) ←nameToken tokens
  let rest ←accept "[" rest
  let (index,rest) ←sum rest
  let rest ←accept "]" rest
  let rest ←accept "=" rest
  let (value,rest) ←product (indexed (product varExpr (parenthesized sum)))
    (cast (product (indexed sum) (indexed zero))) rest
  let rest ←accept ";" rest
  if rest=[] then some ⟨destination,index,value⟩ else none

def sourceBody : String := r#"out[r + i] = w[w_stride * (i + r)] *
            static_cast<T>(x[r + i] * local_inv_mean[0]);"#
def sourceTailBody : String := r#"out[r + i] = w[w_stride * (i + r)] *
              static_cast<T>(x[r + i] * local_inv_mean[0]);"#
def body : Store := ⟨"out",.add (.var "r") (.var "i"),
  .mul (.index "w" (.mul (.var "w_stride") (.add (.var "i") (.var "r"))))
    (.cast "T" (.mul (.index "x" (.add (.var "r") (.var "i")))
      (.index "local_inv_mean" .zero)))⟩

theorem parsed_body : parse sourceBody=some body := by decide +kernel
theorem parsed_tail_body : parse sourceTailBody=some body := by decide +kernel
end Inference.Kernels.Normalization.MlxRmsOutputSyntax

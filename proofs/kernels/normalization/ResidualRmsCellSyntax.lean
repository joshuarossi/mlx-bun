import kernels.copy.ScalarCopySyntax

namespace Inference.Kernels.Normalization.ResidualRmsCellSyntax
open Copy.ScalarCopySyntax (Tokens Parser wordChar accept nameToken)
set_option maxRecDepth 10000

-- Restricted complete grammar of the first-pass guarded cell block. Cast
-- names, identifiers, input subscripts and all arithmetic nodes are retained.
inductive Expr where
  | var : String → Expr
  | cast : String → Expr → Expr
  | index : String → Expr → Expr
  | add : Expr → Expr → Expr
  | mul : Expr → Expr → Expr
  deriving DecidableEq, Repr
inductive Stmt where
  | constant : String → String → Expr → Stmt
  | store : String → Expr → Expr → Stmt
  | addAssign : String → Expr → Stmt
  deriving DecidableEq, Repr

def lexAux : Nat → List Char → Option Tokens
  | 0, _ => none
  | _+1, [] => some []
  | fuel+1, c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c then do
      let tail ←lexAux fuel (rest.dropWhile wordChar)
      pure (String.ofList (c::rest.takeWhile wordChar)::tail)
    else match c,rest with
      | '+','='::rest => do pure ("+="::(←lexAux fuel rest))
      | _,_ => if ['{','}','(',')','[',']',';','+','*','='].contains c then do
          pure (String.singleton c::(←lexAux fuel rest))
        else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

def varExpr : Parser Expr := fun tokens => do
  let (name,rest) ←nameToken tokens
  pure (.var name,rest)

def castVariable : Parser Expr := fun tokens => do
  let (typeName,rest) ←nameToken tokens
  let rest ←accept "(" rest
  let (value,rest) ←varExpr rest
  let rest ←accept ")" rest
  pure (.cast typeName value,rest)

def indexed : Parser (String × Expr) := fun tokens => do
  let (name,rest) ←nameToken tokens
  let rest ←accept "[" rest
  let (index,rest) ←varExpr rest
  let rest ←accept "]" rest
  pure ((name,index),rest)

def castIndexed : Parser Expr := fun tokens => do
  let (typeName,rest) ←nameToken tokens
  let rest ←accept "(" rest
  let ((name,index),rest) ←indexed rest
  let rest ←accept ")" rest
  pure (.cast typeName (.index name index),rest)

def binary (leftParser : Parser Expr) (token : String) (rightParser : Parser Expr) (constructor : Expr → Expr → Expr) : Parser Expr := fun tokens => do
  let (left,rest) ←leftParser tokens
  let rest ←accept token rest
  let (right,rest) ←rightParser rest
  pure (constructor left right,rest)

def sum (leftParser rightParser : Parser Expr) : Parser Expr := binary leftParser "+" rightParser Expr.add
def product (leftParser rightParser : Parser Expr) : Parser Expr := binary leftParser "*" rightParser Expr.mul

def residualExpr : Parser Expr := fun tokens => do
  let (typeName,rest) ←nameToken tokens
  let rest ←accept "(" rest
  let (value,rest) ←sum castIndexed castIndexed rest
  let rest ←accept ")" rest
  pure (.cast typeName value,rest)

def constant (expression : Parser Expr) : Parser Stmt := fun tokens => do
  let rest ←accept "const" tokens
  let (typeName,rest) ←nameToken rest
  let (name,rest) ←nameToken rest
  let rest ←accept "=" rest
  let (value,rest) ←expression rest
  let rest ←accept ";" rest
  pure (.constant typeName name value,rest)

def store : Parser Stmt := fun tokens => do
  let ((name,index),rest) ←indexed tokens
  let rest ←accept "=" rest
  let (value,rest) ←varExpr rest
  let rest ←accept ";" rest
  pure (.store name index value,rest)

def accumulate : Parser Stmt := fun tokens => do
  let (name,rest) ←nameToken tokens
  let rest ←accept "+=" rest
  let (value,rest) ←product varExpr varExpr rest
  let rest ←accept ";" rest
  pure (.addAssign name value,rest)

def block : Parser (List Stmt) := fun tokens => do
  let rest ←accept "{" tokens
  let (index,rest) ←constant (sum (product varExpr castVariable) varExpr) rest
  let (value,rest) ←constant residualExpr rest
  let (written,rest) ←store rest
  let (widened,rest) ←constant castVariable rest
  let (added,rest) ←accumulate rest
  let rest ←accept "}" rest
  pure ([index,value,written,widened,added],rest)

def parseBody (source : String) : Option (List Stmt) := do
  let tokens ←tokenize source
  let (body,remaining) ←block tokens
  if remaining=[] then some body else none

def sourceBody : String := r#"{
        const uint index = row * uint(D) + col;
        const T value = T(float(x[index]) + float(update[index]));
        residual[index] = value;
        const float v = float(value);
        acc += v * v;
      }"#

def body : List Stmt := [
  .constant "uint" "index" (.add (.mul (.var "row") (.cast "uint" (.var "D"))) (.var "col")),
  .constant "T" "value" (.cast "T" (.add (.cast "float" (.index "x" (.var "index"))) (.cast "float" (.index "update" (.var "index"))))),
  .store "residual" (.var "index") (.var "value"),
  .constant "float" "v" (.cast "float" (.var "value")),
  .addAssign "acc" (.mul (.var "v") (.var "v"))]

theorem parsed_body : parseBody sourceBody=some body := by decide +kernel

theorem parseBody_consumes {source : String} {body : List Stmt} (parsed : parseBody source=some body) :
    ∃ tokens, tokenize source=some tokens ∧ block tokens=some (body,[]) := by
  change ((tokenize source).bind (fun tokens => (block tokens).bind (fun result =>
    if result.2=[] then some result.1 else none)))=some body at parsed
  obtain ⟨tokens,lexed,parsed⟩ := Option.bind_eq_some_iff.mp parsed
  obtain ⟨⟨actual,remaining⟩,blocked,parsed⟩ := Option.bind_eq_some_iff.mp parsed
  by_cases empty : remaining=[]
  · subst remaining
    simp only [ite_true] at parsed
    have same : actual=body := Option.some.inj parsed
    subst actual
    exact ⟨tokens,lexed,blocked⟩
  · simp only [empty,ite_false] at parsed
    contradiction

end Inference.Kernels.Normalization.ResidualRmsCellSyntax

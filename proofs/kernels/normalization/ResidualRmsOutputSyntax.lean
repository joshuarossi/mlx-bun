import kernels.normalization.ResidualRmsCellSyntax

namespace Inference.Kernels.Normalization.ResidualRmsOutputSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken)
set_option maxRecDepth 10000

inductive Expr where
  | var : String → Expr
  | zero : Expr
  | cast : String → Expr → Expr
  | index : String → Expr → Expr
  | add : Expr → Expr → Expr
  | mul : Expr → Expr → Expr
  deriving DecidableEq, Repr
inductive Stmt where
  | constant : String → String → Expr → Stmt
  | store : String → Expr → Expr → Stmt
  deriving DecidableEq, Repr

def varExpr : Parser Expr := fun tokens => do
  let (name,rest) ←nameToken tokens
  pure (.var name,rest)
def zero : Parser Expr := fun tokens => do pure (.zero,←accept "0" tokens)
def indexed (index : Parser Expr) : Parser Expr := fun tokens => do
  let (name,rest) ←nameToken tokens
  let rest ←accept "[" rest
  let (index,rest) ←index rest
  let rest ←accept "]" rest
  pure (.index name index,rest)
def cast (expression : Parser Expr) : Parser Expr := fun tokens => do
  let (typeName,rest) ←nameToken tokens
  let rest ←accept "(" rest
  let (value,rest) ←expression rest
  let rest ←accept ")" rest
  pure (.cast typeName value,rest)
def binary (left : Parser Expr) (token : String) (right : Parser Expr) (constructor : Expr → Expr → Expr) : Parser Expr := fun tokens => do
  let (left,rest) ←left tokens
  let rest ←accept token rest
  let (right,rest) ←right rest
  pure (constructor left right,rest)
def product (left right : Parser Expr) : Parser Expr := binary left "*" right Expr.mul
def addition (left right : Parser Expr) : Parser Expr := binary left "+" right Expr.add

def constant : Parser Stmt := fun tokens => do
  let rest ←accept "const" tokens
  let (typeName,rest) ←nameToken rest
  let (name,rest) ←nameToken rest
  let rest ←accept "=" rest
  let (value,rest) ←addition (product varExpr (cast varExpr)) varExpr rest
  let rest ←accept ";" rest
  pure (.constant typeName name value,rest)
def store : Parser Stmt := fun tokens => do
  let (name,rest) ←nameToken tokens
  let rest ←accept "[" rest
  let (atIndex,rest) ←varExpr rest
  let rest ←accept "]" rest
  let rest ←accept "=" rest
  let (value,rest) ←product (indexed varExpr) (cast (product (cast (indexed varExpr)) (indexed zero))) rest
  let rest ←accept ";" rest
  pure (.store name atIndex value,rest)
def parseBody (source : String) : Option (List Stmt) := do
  let tokens ←ResidualRmsCellSyntax.tokenize source
  let rest ←accept "{" tokens
  let (index,rest) ←constant rest
  let (stored,rest) ←store rest
  let rest ←accept "}" rest
  if rest=[] then some [index,stored] else none

def sourceBody : String := r#"{
        const uint index = row * uint(D) + col;
        normalized[index] = weight[col] * T(float(residual[index]) * inv[0]);
      }"#
def body : List Stmt := [
  .constant "uint" "index" (.add (.mul (.var "row") (.cast "uint" (.var "D"))) (.var "col")),
  .store "normalized" (.var "index") (.mul (.index "weight" (.var "col"))
    (.cast "T" (.mul (.cast "float" (.index "residual" (.var "index"))) (.index "inv" .zero))))]

theorem parsed_body : parseBody sourceBody=some body := by decide +kernel
end Inference.Kernels.Normalization.ResidualRmsOutputSyntax

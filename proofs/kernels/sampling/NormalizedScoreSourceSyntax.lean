import kernels.sampling.ArgmaxShuffleSyntax

namespace Inference.Kernels.Sampling.NormalizedScoreSourceSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken)
open ArgmaxShuffleSyntax (wordChar whitespace acceptMany)
set_option maxRecDepth 10000

inductive Expr where
  | variable : String → Expr
  | index : String → Expr → Expr
  | call : String → Expr → Expr
  | add : Expr → Expr → Expr
  | multiply : Expr → Expr → Expr
  | subtract : Expr → Expr → Expr
  | negativeInfinity : Expr
  | conditional : Expr → Expr → Expr → Expr
  deriving DecidableEq, Repr
inductive Stmt where
  | floatDeclaration : String → Expr → Stmt
  | assign : String → Expr → Stmt
  deriving DecidableEq, Repr

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if whitespace c then lexAux fuel (rest.dropWhile whitespace)
    else if wordChar c then do
      pure (String.ofList (c::rest.takeWhile wordChar)::(←lexAux fuel (rest.dropWhile wordChar)))
    else if ['(',')','[',']',';','=','+','*','-','?',':'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest)) else none

def tokenize (source : String) := lexAux (source.length+1) source.toList

def varExpr : Parser Expr := fun tokens => do
  let (name,rest) ←nameToken tokens
  pure (.variable name,rest)
def binary (left : Parser Expr) (symbol : String) (right : Parser Expr)
    (constructor : Expr → Expr → Expr) : Parser Expr := fun tokens => do
  let (left,rest) ←left tokens
  let rest ←accept symbol rest
  let (right,rest) ←right rest
  pure (constructor left right,rest)
def indexed (expression : Parser Expr) : Parser Expr := fun tokens => do
  let (name,rest) ←nameToken tokens
  let rest ←accept "[" rest
  let (value,rest) ←expression rest
  pure (.index name value,←accept "]" rest)
def call (expression : Parser Expr) : Parser Expr := fun tokens => do
  let (name,rest) ←nameToken tokens
  let rest ←accept "(" rest
  let (value,rest) ←expression rest
  pure (.call name value,←accept ")" rest)
def logitIndex : Parser Expr := binary (binary varExpr "*" varExpr Expr.multiply) "+" varExpr Expr.add
def difference : Parser Expr := binary (indexed logitIndex) "-" (indexed varExpr) Expr.subtract

def parseFirstTokens (tokens : Tokens) : Option Stmt := do
  let rest ←accept "float" tokens
  let (name,rest) ←nameToken rest
  let rest ←accept "=" rest
  let (value,rest) ←call (call difference) rest
  let rest ←accept ";" rest
  if rest=[] then some (.floatDeclaration name value) else none

def parseCleanTokens (tokens : Tokens) : Option Stmt := do
  let (name,rest) ←nameToken tokens
  let rest ←accept "=" rest
  let (test,rest) ←call varExpr rest
  let rest ←acceptMany ["?","-","INFINITY",":"] rest
  let (otherwise,rest) ←varExpr rest
  let rest ←accept ";" rest
  if rest=[] then some (.assign name (.conditional test .negativeInfinity otherwise)) else none

def parseFirst (source : String) : Option Stmt := do parseFirstTokens (←tokenize source)
def parseClean (source : String) : Option Stmt := do parseCleanTokens (←tokenize source)
def sourceBody : String := "float value = float(T(logits[row * V + i] - lse[row]));"
def cleanBody : String := "value = isnan(value) ? -INFINITY : value;"
def sourceTokens : Tokens := ["float","value","=","float","(","T","(","logits","[","row","*","V","+","i","]","-","lse","[","row","]",")",")",";"]
def cleanTokens : Tokens := ["value","=","isnan","(","value",")","?","-","INFINITY",":","value",";"]
def sourceExpr : Expr := .call "float" (.call "T" (.subtract
  (.index "logits" (.add (.multiply (.variable "row") (.variable "V")) (.variable "i")))
  (.index "lse" (.variable "row"))))
def cleanExpr : Expr := .conditional (.call "isnan" (.variable "value")) .negativeInfinity (.variable "value")
theorem lexed_source : tokenize sourceBody=some sourceTokens := by decide +kernel
theorem lexed_clean : tokenize cleanBody=some cleanTokens := by decide +kernel
theorem parsed_source : parseFirst sourceBody=some (.floatDeclaration "value" sourceExpr) := by
  simp only [parseFirst,lexed_source]
  decide +kernel
theorem parsed_clean : parseClean cleanBody=some (.assign "value" cleanExpr) := by
  simp only [parseClean,lexed_clean]
  decide +kernel

end Inference.Kernels.Sampling.NormalizedScoreSourceSyntax

import kernels.trellis.GateTailSyntax

namespace Inference.Kernels.Attention.MlxOutputGateSyntax
open Trellis.GateTailSyntax
open Copy.ScalarCopySyntax (accept)
set_option maxRecDepth 10000

structure Sigmoid where
  temporary : Expr
  result : Expr
  deriving DecidableEq, Repr

def parseSigmoid (source : String) : Option Sigmoid := do
  let ts ←tokenize source
  let ts ←accept "auto" ts
  let ts ←accept "y" ts
  let ts ←accept "=" ts
  let (value,ts) ←expression 64 0 ts
  let ts ←accept ";" ts
  let ts ←accept "return" ts
  let (result,ts) ←expression 64 0 ts
  let ts ←accept ";" ts
  if ts=[] then some ⟨value,result⟩ else none

def parseMultiply (source : String) : Option Expr := do
  let ts ←tokenize source
  let ts ←accept "return" ts
  let (value,ts) ←expression 64 0 ts
  let ts ←accept ";" ts
  if ts=[] then some value else none

def sourceSigmoid : String := r#"auto y = 1 / (1 + metal::exp(metal::abs(x)));
return (x < 0) ? y : 1 - y;"#
def sourceMultiply : String := r#"return x * y;"#

def sigmoid : Sigmoid := ⟨.divide (.integer 1) (.add (.integer 1) (.exponential (.absolute (.variable "x")))),
  .choose (.less (.variable "x") (.integer 0)) (.variable "y") (.subtract (.integer 1) (.variable "y"))⟩
def multiply : Expr := .multiply (.variable "x") (.variable "y")

theorem parsed_sigmoid : parseSigmoid sourceSigmoid=some sigmoid := by decide +kernel
theorem parsed_multiply : parseMultiply sourceMultiply=some multiply := by decide +kernel
end Inference.Kernels.Attention.MlxOutputGateSyntax

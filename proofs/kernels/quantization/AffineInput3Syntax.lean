import kernels.quantization.AffineInput4Syntax
namespace Inference.Kernels.Quantization.AffineInput3Syntax
open Copy.ScalarCopySyntax (Tokens Parser accept)
open Sampling.ArgmaxShuffleSyntax (acceptMany)
open AffineInput4Syntax (Expr Assignment Program number load assignment)
open Trellis.GateTailSyntax (tokenize)
set_option maxRecDepth 10000

def additions : Nat → Expr → Parser Expr
  | 0,left => fun ts => some (left,ts)
  | count+1,left => fun ts => do
    let ts ←accept "+" ts
    let (right,ts) ←load ts
    additions count (.add left right) ts

def assignments : Nat → Parser (List Assignment)
  | 0 => fun ts => some ([],ts)
  | count+1 => fun ts => do
    let (first,ts) ←assignment ts
    let (rest,ts) ←assignments count ts
    pure (first::rest,ts)

def parseTokens (tokens : Tokens) : Option Program := do
  let ts ←acceptMany ["for","(","int","i","="] tokens
  let (start,ts) ←number ts
  let ts ←acceptMany [";","i","<"] ts
  let (bound,ts) ←number ts
  let ts ←acceptMany [";","i","+","="] ts
  let (stride,ts) ←number ts
  let ts ←acceptMany [")","{","sum","+","="] ts
  let (first,ts) ←load ts
  let (group,ts) ←additions 7 first ts
  let ts ←accept ";" ts
  let (writes,ts) ←assignments 8 ts
  let ts ←accept "}" ts
  if ts=[] then some ⟨start,bound,stride,group,writes⟩ else none

def parse (source : String) : Option Program := do parseTokens (←tokenize source)
def parseBranch (source : String) : Option Nat := do
  let ts ←tokenize source
  let ts ←acceptMany ["if","(","bits","=="] ts
  let (bits,ts) ←number ts
  let ts ←accept ")" ts
  if ts=[] then some bits else none
def branchSource : String := "if (bits == 3)"
theorem parsed_branch : parseBranch branchSource=some 3 := by decide +kernel

def groupBody : Expr := .add (.add (.add (.add (.add (.add (.add (.load 0) (.load 1)) (.load 2)) (.load 3)) (.load 4)) (.load 5)) (.load 6)) (.load 7)
def body : Program := ⟨0,16,8,groupBody,[⟨0,0,1⟩,⟨1,1,8⟩,⟨2,2,64⟩,⟨3,3,2⟩,⟨4,4,16⟩,⟨5,5,128⟩,⟨6,6,4⟩,⟨7,7,32⟩]⟩
def sourceLoop : String := "for (int i = 0; i < 16; i += 8) {\n      sum += x[i] + x[i + 1] + x[i + 2] + x[i + 3] + x[i + 4] + x[i + 5] +\n          x[i + 6] + x[i + 7];\n      x_thread[i] = x[i];\n      x_thread[i + 1] = x[i + 1] / 8.0f;\n      x_thread[i + 2] = x[i + 2] / 64.0f;\n      x_thread[i + 3] = x[i + 3] / 2.0f;\n      x_thread[i + 4] = x[i + 4] / 16.0f;\n      x_thread[i + 5] = x[i + 5] / 128.0f;\n      x_thread[i + 6] = x[i + 6] / 4.0f;\n      x_thread[i + 7] = x[i + 7] / 32.0f;\n    }"

theorem parsed_loop : parse sourceLoop=some body := by decide +kernel
end Inference.Kernels.Quantization.AffineInput3Syntax

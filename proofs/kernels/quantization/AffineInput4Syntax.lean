import kernels.trellis.GateTailSyntax
import kernels.sampling.ArgmaxShuffleSyntax
namespace Inference.Kernels.Quantization.AffineInput4Syntax
open Copy.ScalarCopySyntax (Tokens Parser accept decimal)
open Trellis.GateTailSyntax (tokenize)
open Sampling.ArgmaxShuffleSyntax (acceptMany)
set_option maxRecDepth 10000
inductive Expr where
  | load : Nat → Expr
  | add : Expr → Expr → Expr
  deriving DecidableEq, Repr
structure Assignment where
  target : Nat
  source : Nat
  divisor : Nat
  deriving DecidableEq, Repr
structure Program where
  start : Nat
  bound : Nat
  stride : Nat
  group : Expr
  writes : List Assignment
  deriving DecidableEq, Repr

def number : Parser Nat := fun tokens => do
  match tokens with
  | value::rest => pure (←decimal value,rest)
  | _ => none

def subscript : Parser Nat := fun tokens => do
  let rest ←acceptMany ["[","i"] tokens
  let (offset,rest) ←match rest with
    | "+"::rest => number rest
    | _ => some (0,rest)
  pure (offset,←accept "]" rest)

def load : Parser Expr := fun tokens => do
  let rest ←accept "x" tokens
  let (offset,rest) ←subscript rest
  pure (.load offset,rest)

def group : Parser Expr := fun tokens => do
  let (a,rest) ←load tokens
  let rest ←accept "+" rest
  let (b,rest) ←load rest
  let rest ←accept "+" rest
  let (c,rest) ←load rest
  let rest ←accept "+" rest
  let (d,rest) ←load rest
  pure (.add (.add (.add a b) c) d,rest)

def assignment : Parser Assignment := fun tokens => do
  let rest ←accept "x_thread" tokens
  let (target,rest) ←subscript rest
  let rest ←acceptMany ["=","x"] rest
  let (source,rest) ←subscript rest
  let (divisor,rest) ←match rest with
    | "/"::value::rest => do
      match value.toList.reverse with
      | 'f'::'0'::'.'::whole => pure (←decimal (String.ofList whole.reverse),rest)
      | _ => none
    | _ => some (1,rest)
  pure (⟨target,source,divisor⟩,←accept ";" rest)

def parseTokens (tokens : Tokens) : Option Program := do
  let rest ←acceptMany ["for","(","int","i","="] tokens
  let (start,rest) ←number rest
  let rest ←acceptMany [";","i","<"] rest
  let (bound,rest) ←number rest
  let rest ←acceptMany [";","i","+","="] rest
  let (stride,rest) ←number rest
  let rest ←acceptMany [")","{","sum","+","="] rest
  let (group,rest) ←group rest
  let rest ←accept ";" rest
  let (a,rest) ←assignment rest
  let (b,rest) ←assignment rest
  let (c,rest) ←assignment rest
  let (d,rest) ←assignment rest
  let rest ←accept "}" rest
  if rest=[] then some ⟨start,bound,stride,group,[a,b,c,d]⟩ else none

def parse (source : String) : Option Program := do parseTokens (←tokenize source)
def parseInitializer (source : String) : Option Nat := do
  let rest ←tokenize source
  let rest ←acceptMany ["float","sum","="] rest
  let (value,rest) ←number rest
  let rest ←accept ";" rest
  if rest=[] then some value else none
def parseReturn (source : String) : Option Unit := do
  let rest ←tokenize source
  let rest ←acceptMany ["return","sum",";"] rest
  if rest=[] then some () else none
def sourceInitializer : String := "float sum = 0;"
def sourceReturn : String := "return sum;"
theorem parsed_initializer : parseInitializer sourceInitializer=some 0 := by decide +kernel
theorem parsed_return : parseReturn sourceReturn=some () := by decide +kernel

def sourceLoop : String := "for (int i = 0; i < 16; i += 4) {\n      sum += x[i] + x[i + 1] + x[i + 2] + x[i + 3];\n      x_thread[i] = x[i];\n      x_thread[i + 1] = x[i + 1] / 16.0f;\n      x_thread[i + 2] = x[i + 2] / 256.0f;\n      x_thread[i + 3] = x[i + 3] / 4096.0f;\n    }"
def body : Program := ⟨0,16,4,.add (.add (.add (.load 0) (.load 1)) (.load 2)) (.load 3),
  [⟨0,0,1⟩,⟨1,1,16⟩,⟨2,2,256⟩,⟨3,3,4096⟩]⟩
theorem parsed_loop : parse sourceLoop=some body := by decide +kernel
end Inference.Kernels.Quantization.AffineInput4Syntax

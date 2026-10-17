import kernels.quantization.AffineScratch4Source
namespace Inference.Kernels.Quantization.AffinePreload4Syntax
open Copy.ScalarCopySyntax (Tokens accept wordChar)
open Sampling.ArgmaxShuffleSyntax (acceptMany)
open AffineInput4Syntax (number)
set_option maxRecDepth 10000
structure Header where
  lanes : Nat
  divisor : Nat
  strideLanes : Nat
  deriving DecidableEq, Repr

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c then do
      pure (String.ofList (c::rest.takeWhile wordChar)::(←lexAux fuel (rest.dropWhile wordChar)))
    else if ['(',')','[',']',';','=','+','*','/','<','{',':',','].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none
def tokenize (source : String) := lexAux (source.length+1) source.toList

def parse (source : String) : Option Header := do
  let rest ←tokenize source
  let rest ←acceptMany ["for","(","int","c","=","(","int",")","(","sg","*"] rest
  let (lanes,rest) ←number rest
  let rest ←acceptMany ["+","lane",")",";","c","<","K","/"] rest
  let (divisor,rest) ←number rest
  let rest ←acceptMany [";","c","+","=","S","*"] rest
  let (strideLanes,rest) ←number rest
  let rest ←acceptMany [")","{"] rest
  if rest=[] then some ⟨lanes,divisor,strideLanes⟩ else none

def parseBarrier (source : String) : Option Unit := do
  let rest ←tokenize source
  let rest ←acceptMany ["threadgroup_barrier","(","mem_flags",":",":","mem_threadgroup",")",";"] rest
  if rest=[] then some () else none

def parseGroups (source : String) : Option Nat := do
  let rest ←tokenize source
  let rest ←acceptMany ["const","R","=","4",",","S","="] rest
  let (groups,rest) ←number rest
  let rest ←accept ";" rest
  if rest=[] then some groups else none
def sourceGroups : String := "const R = 4, S = 16;"
theorem parsed_groups : parseGroups sourceGroups=some 16 := by decide +kernel

def sourceHeader : String := "for (int c = (int)(sg * 32 + lane); c < K / 16; c += S * 32) {"
def sourceBarrier : String := "threadgroup_barrier(mem_flags::mem_threadgroup);"
def header : Header := ⟨32,16,32⟩
theorem parsed_header : parse sourceHeader=some header := by decide +kernel
theorem parsed_barrier : parseBarrier sourceBarrier=some () := by decide +kernel
end Inference.Kernels.Quantization.AffinePreload4Syntax

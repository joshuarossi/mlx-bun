import kernels.quantization.AffineInput4Syntax
import kernels.trellis.PackedArraySyntax
namespace Inference.Kernels.Delta.MlxLogAddExpSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken)
open Sampling.ArgmaxShuffleSyntax (acceptMany)
set_option maxRecDepth 10000

inductive Expr where
  | variable : String→Expr
  | add : Expr→Expr→Expr
  | subtract : Expr→Expr→Expr
  | exponential : Expr→Expr
  | logarithm : Expr→Expr
  deriving DecidableEq,Repr
structure Call where
  target : String
  operation : String
  left : String
  right : String
  deriving DecidableEq,Repr
structure Return where
  minimum : String
  maximum : String
  infinity : String
  direct : String
  fallback : Expr
  deriving DecidableEq,Repr

def parseNan (source : String) : Option Unit := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["if","(","metal",":",":","isnan","(","x",")","|","|","metal",":",":","isnan","(","y",")",")","{",
    "return","metal",":",":","numeric_limits","<","T",">",":",":","quiet_NaN","(",")",";","}"] ts
  if ts=[] then some () else none

def parseInfinity (source : String) : Option Unit := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["constexpr","T","inf","=","metal",":",":","numeric_limits","<","T",">",":",":","infinity","(",")",";"] ts
  if ts=[] then some () else none

def parseCall (source : String) : Option Call := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←accept "T" ts
  let (target,ts) ←nameToken ts
  let ts ←acceptMany ["=","metal",":",":"] ts
  let (operation,ts) ←nameToken ts
  let ts ←accept "(" ts
  let (left,ts) ←nameToken ts
  let ts ←accept "," ts
  let (right,ts) ←nameToken ts
  let ts ←acceptMany [")",";"] ts
  if ts=[] then some ⟨target,operation,left,right⟩ else none

mutual
  def expression : Nat→Parser Expr
    | 0,_ => none
    | fuel+1,ts => do
      let (first,ts) ←primary fuel ts
      tail fuel first ts
  def primary : Nat→Parser Expr
    | 0,_ => none
    | fuel+1,"metal"::":"::":"::"exp"::"("::ts => do
      let (value,ts) ←expression fuel ts
      pure (.exponential value,←accept ")" ts)
    | fuel+1,"log1p"::"("::ts => do
      let (value,ts) ←expression fuel ts
      pure (.logarithm value,←accept ")" ts)
    | fuel+1,"("::ts => do
      let (value,ts) ←expression fuel ts
      pure (value,←accept ")" ts)
    | _+1,ts => do
      let (name,ts) ←nameToken ts
      pure (.variable name,ts)
  def tail : Nat→Expr→Parser Expr
    | 0,_,_ => none
    | fuel+1,left,"+"::ts => do
      let (right,ts) ←primary fuel ts
      tail fuel (.add left right) ts
    | fuel+1,left,"-"::ts => do
      let (right,ts) ←primary fuel ts
      tail fuel (.subtract left right) ts
    | _+1,left,ts => some (left,ts)
end

def parseReturn (source : String) : Option Return := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["return","("] ts
  let (minimum,ts) ←nameToken ts
  let ts ←acceptMany ["==","-"] ts
  let (infinity,ts) ←nameToken ts
  let ts ←acceptMany ["|","|"] ts
  let (maximum,ts) ←nameToken ts
  let ts ←accept "==" ts
  let (sameInfinity,ts) ←nameToken ts
  let ts ←acceptMany [")","?"] ts
  let (direct,ts) ←nameToken ts
  let ts ←accept ":" ts
  let (fallback,ts) ←expression 16 ts
  let ts ←accept ";" ts
  if ts=[] ∧ infinity=sameInfinity then some ⟨minimum,maximum,infinity,direct,fallback⟩ else none

def nanSource : String := "if (metal::isnan(x) || metal::isnan(y)) {\n      return metal::numeric_limits<T>::quiet_NaN();\n    }"
def infinitySource : String := "constexpr T inf = metal::numeric_limits<T>::infinity();"
def maximumSource : String := "T maxval = metal::max(x, y);"
def minimumSource : String := "T minval = metal::min(x, y);"
def returnSource : String := "return (minval == -inf || maxval == inf)\n        ? maxval\n        : (maxval + log1p(metal::exp(minval - maxval)));"
def maximum : Call := ⟨"maxval","max","x","y"⟩
def minimum : Call := ⟨"minval","min","x","y"⟩
def returned : Return := ⟨"minval","maxval","inf","maxval",
  .add (.variable "maxval") (.logarithm (.exponential (.subtract (.variable "minval") (.variable "maxval"))))⟩
theorem parsed_nan : parseNan nanSource=some () := by decide +kernel
theorem parsed_infinity : parseInfinity infinitySource=some () := by decide +kernel
theorem parsed_maximum : parseCall maximumSource=some maximum := by decide +kernel
theorem parsed_minimum : parseCall minimumSource=some minimum := by decide +kernel
theorem parsed_return : parseReturn returnSource=some returned := by decide +kernel
end Inference.Kernels.Delta.MlxLogAddExpSyntax

import kernels.trellis.GateTailSyntax

namespace Inference.Kernels.Quantization.AffineDot4FunctionSyntax
open Copy.ScalarCopySyntax (Tokens accept nameToken)
open Trellis.GateTailSyntax (Expr tokenize expression)
set_option maxRecDepth 10000

structure Initializer where
  name : String
  value : Expr
  deriving DecidableEq, Repr
structure Pointer where
  name : String
  source : String
  deriving DecidableEq, Repr

def parseInitializer (source : String) : Option Initializer := do
  let rest ←tokenize source
  let rest ←accept "float" rest
  let (name,rest) ←nameToken rest
  let rest ←accept "=" rest
  let (value,rest) ←expression 8 0 rest
  let rest ←accept ";" rest
  if rest=[] then some ⟨name,value⟩ else none

def pointerType (rest : Tokens) : Option Tokens := do
  let rest ←accept "const" rest
  let rest ←accept "device" rest
  let rest ←accept "uint16_t" rest
  accept "*" rest

def parsePointer (source : String) : Option Pointer := do
  let rest ←tokenize source
  let rest ←pointerType rest
  let (name,rest) ←nameToken rest
  let rest ←accept "=" rest
  let rest ←accept "(" rest
  let rest ←pointerType rest
  let rest ←accept ")" rest
  let (source,rest) ←nameToken rest
  let rest ←accept ";" rest
  if rest=[] then some ⟨name,source⟩ else none

def parseReturn (source : String) : Option Expr := do
  let rest ←tokenize source
  let rest ←accept "return" rest
  let (value,rest) ←expression 8 0 rest
  let rest ←accept ";" rest
  if rest=[] then some value else none

def sourceInitializer : String := "float accum = 0;"
def sourcePointer : String := "const device uint16_t* ws = (const device uint16_t*)w;"
def sourceReturn : String := "return scale * accum + sum * bias;"
def initializer : Initializer := ⟨"accum",.integer 0⟩
def pointer : Pointer := ⟨"ws","w"⟩
def returnValue : Expr := .add (.multiply (.variable "scale") (.variable "accum"))
  (.multiply (.variable "sum") (.variable "bias"))

theorem parsed_initializer : parseInitializer sourceInitializer=some initializer := by decide +kernel
theorem parsed_pointer : parsePointer sourcePointer=some pointer := by decide +kernel
theorem parsed_return : parseReturn sourceReturn=some returnValue := by decide +kernel

end Inference.Kernels.Quantization.AffineDot4FunctionSyntax

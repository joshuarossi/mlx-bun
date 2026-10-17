import kernels.quantization.AffineInput4Syntax
import kernels.trellis.GateInputSyntax
namespace Inference.Kernels.Delta.MlxDepthwiseConvSyntax
open Copy.ScalarCopySyntax (accept)
open Sampling.ArgmaxShuffleSyntax (acceptMany)
open Quantization.AffineInput4Syntax (number)
set_option maxRecDepth 10000

structure Product where
  inputOffset : Nat
  weightCounter : String
  deriving DecidableEq, Repr

def parseProduct (source : String) : Option Product := do
  let ts ←Trellis.GateInputSyntax.tokenize source
  let ts ←acceptMany ["acc","+=","static_cast","<","float",">","(","in","["] ts
  let (inputOffset,ts) ←number ts
  let ts ←acceptMany ["]",")","*","w","["] ts
  let (counter,ts) ←Copy.ScalarCopySyntax.nameToken ts
  let ts ←acceptMany ["]",";"] ts
  if ts=[] then some ⟨inputOffset,counter⟩ else none

def parseHeader (source : String) : Option Nat := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["for","(","int","i","="] ts
  let (initial,ts) ←number ts
  let ts ←acceptMany [";","i","<","kernel_size",";","++","i",")","{"] ts
  if ts=[] then some initial else none

def parseInitial (source : String) : Option Nat := do
  let ts ←Trellis.GateTailSyntax.tokenize source
  let ts ←acceptMany ["float","acc","=","0.0",";"] ts
  if ts=[] then some 0 else none

def parseAdvance (source : String) : Option Nat := do
  let ts ←Trellis.GateInputSyntax.tokenize source
  let ts ←acceptMany ["in","+=","strides","["] ts
  let (component,ts) ←number ts
  let ts ←acceptMany ["]",";"] ts
  if ts=[] then some component else none

def parseStore (source : String) : Option Unit := do
  let ts ←Trellis.GateInputSyntax.tokenize source
  let ts ←acceptMany ["*","out","=","static_cast","<","T",">","(","acc",")",";"] ts
  if ts=[] then some () else none

def parsePointers (source : String) : Option Unit := do
  let ts ←Trellis.GateInputSyntax.tokenize source
  let ts ←acceptMany ["out","+=","(","tid",".","z","*","static_cast","<","IdxT",">","(","grid_dim",".","y",")","+","tid",".","y",")","*","grid_dim",".","x","+","tid",".","x",";",
    "in","+=","tid",".","z","*","strides","[","0","]","+","tid",".","y","*","strides","[","1","]","+","tid",".","x","*","strides","[","2","]",";",
    "w","+=","tid",".","x","*","kernel_size",";"] ts
  if ts=[] then some () else none

def productSource : String := "acc += static_cast<float>(in[0]) * w[i];"
def headerSource : String := "for (int i = 0; i < kernel_size; ++i) {"
def initialSource : String := "float acc = 0.0;"
def advanceSource : String := "in += strides[1];"
def storeSource : String := "*out = static_cast<T>(acc);"
def pointersSource : String := "out += (tid.z * static_cast<IdxT>(grid_dim.y) + tid.y) * grid_dim.x + tid.x;\n  in += tid.z * strides[0] + tid.y * strides[1] + tid.x * strides[2];\n  w += tid.x * kernel_size;"
def product : Product := ⟨0,"i"⟩
theorem parsed_product : parseProduct productSource=some product := by decide +kernel
theorem parsed_header : parseHeader headerSource=some 0 := by decide +kernel
theorem parsed_initial : parseInitial initialSource=some 0 := by decide +kernel
theorem parsed_advance : parseAdvance advanceSource=some 1 := by decide +kernel
theorem parsed_store : parseStore storeSource=some () := by decide +kernel
theorem parsed_pointers : parsePointers pointersSource=some () := by decide +kernel
end Inference.Kernels.Delta.MlxDepthwiseConvSyntax

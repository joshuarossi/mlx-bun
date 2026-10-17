import kernels.quantization.AffineOutputSyntax
import kernels.quantization.AffineInput4Syntax
import kernels.sampling.ArgmaxShuffleSyntax
namespace Inference.Kernels.Quantization.AffineOuter4Syntax
open Copy.ScalarCopySyntax (Tokens accept)
open Sampling.ArgmaxShuffleSyntax (acceptMany)
open AffineInput4Syntax (number)
set_option maxRecDepth 10000
structure Layout where
  packedFactor : Nat
  rowDivisor : Nat
  groupDivisor : Nat
  deriving DecidableEq, Repr
structure Header where
  start : Nat
  stride : Nat
  deriving DecidableEq, Repr
structure Reads where
  sumLaneWidth : Nat
  sumDivisor : Nat
  inputLaneWidth : Nat
  deriving DecidableEq, Repr
structure Updates where
  packedLanes : Nat
  scaleStep : Nat
  biasStep : Nat
  deriving DecidableEq, Repr

def parseLayout (source : String) : Option Layout := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["constexpr","int","BPL","="] ts
  let (factor,ts) ←number ts
  let ts ←acceptMany ["*","BITS",";","constexpr","int","ROWB","=","K","*","BITS","/"] ts
  let (rowDivisor,ts) ←number ts
  let ts ←acceptMany [";","constexpr","int","GROUPS","=","K","/"] ts
  let (groupDivisor,ts) ←number ts
  let ts ←accept ";" ts
  if ts=[] then some ⟨factor,rowDivisor,groupDivisor⟩ else none

def parseHeader (source : String) : Option Header := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["for","(","int","k","="] ts
  let (start,ts) ←number ts
  let ts ←acceptMany [";","k","<","K",";","k","+="] ts
  let (stride,ts) ←number ts
  let ts ←accept ")" ts
  if ts=[] then some ⟨start,stride⟩ else none

def parsePointers (source : String) : Option Nat := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["const","device","uint8_t","*","ws","=","(","const","device","uint8_t","*",")","w","+","row0","*","ROWB","+","lane","*","BPL",";",
    "const","device","T","*","sc","=","scales","+","row0","*","GROUPS","+","lane","/"] ts
  let (scaleDivisor,ts) ←number ts
  let ts ←acceptMany [";","const","device","T","*","bi","=","biases","+","row0","*","GROUPS","+","lane","/"] ts
  let (biasDivisor,ts) ←number ts
  let ts ←accept ";" ts
  if ts=[] ∧ scaleDivisor=biasDivisor then some scaleDivisor else none

def parseReads (source : String) : Option Reads := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["const","float","sum","=","ss","[","(","k","+","lane","*"] ts
  let (sumLaneWidth,ts) ←number ts
  let ts ←acceptMany [")","/"] ts
  let (sumDivisor,ts) ←number ts
  let ts ←acceptMany ["]",";","const","threadgroup","float","*","x_thread","=","xs","+","k","+","lane","*"] ts
  let (inputLaneWidth,ts) ←number ts
  let ts ←acceptMany [";","const","float","s","=","sc","[","r","*","GROUPS","]",";","const","float","b","=","bi","[","r","*","GROUPS","]",";"] ts
  if ts=[] then some ⟨sumLaneWidth,sumDivisor,inputLaneWidth⟩ else none

def parseUpdates (source : String) : Option Updates := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["ws","+="] ts
  let (packedLanes,ts) ←number ts
  let ts ←acceptMany ["*","BPL",";","sc","+="] ts
  let (scaleStep,ts) ←number ts
  let ts ←acceptMany [";","bi","+="] ts
  let (biasStep,ts) ←number ts
  let ts ←accept ";" ts
  if ts=[] then some ⟨packedLanes,scaleStep,biasStep⟩ else none

def parseInitial (source : String) : Option Nat := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["float","result","[","R","]","=","{"] ts
  let (value,ts) ←number ts
  let ts ←acceptMany ["}",";"] ts
  if ts=[] then some value else none

def parseCall (source : String) : Option Unit := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["result","[","r","]","+=","mlxq_qdot","<","BITS",">","(","ws","+","r","*","ROWB",",","x_thread",",","s",",","b",",","sum",")",";"] ts
  if ts=[] then some () else none

def layoutSource : String := "constexpr int BPL = 2 * BITS;\n  constexpr int ROWB = K * BITS / 8;\n  constexpr int GROUPS = K / 64;"
def headerSource : String := "for (int k = 0; k < K; k += 512)"
def pointersSource : String := "const device uint8_t* ws = (const device uint8_t*)w + row0 * ROWB + lane * BPL;\n  const device T* sc = scales + row0 * GROUPS + lane / 4;\n  const device T* bi = biases + row0 * GROUPS + lane / 4;"
def readsSource : String := "const float sum = ss[(k + lane * 16) / 16];\n    const threadgroup float* x_thread = xs + k + lane * 16;\n      const float s = sc[r * GROUPS];\n      const float b = bi[r * GROUPS];"
def updatesSource : String := "ws += 32 * BPL;\n    sc += 8;\n    bi += 8;"
def innerHeaderSource : String := "for (int r = 0; r < R; r++)"
theorem inner_header_eq : innerHeaderSource=AffineOutputSyntax.loopSource := rfl

def initialSource : String := "float result[R] = {0};"
def callSource : String := "result[r] += mlxq_qdot<BITS>(ws + r * ROWB, x_thread, s, b, sum);"
def layout : Layout := ⟨2,8,64⟩
def header : Header := ⟨0,512⟩
def reads : Reads := ⟨16,16,16⟩
def updates : Updates := ⟨32,8,8⟩
theorem parsed_layout : parseLayout layoutSource=some layout := by decide +kernel
theorem parsed_header : parseHeader headerSource=some header := by decide +kernel
theorem parsed_pointers : parsePointers pointersSource=some 4 := by decide +kernel
theorem parsed_reads : parseReads readsSource=some reads := by decide +kernel
theorem parsed_updates : parseUpdates updatesSource=some updates := by decide +kernel
theorem parsed_initial : parseInitial initialSource=some 0 := by decide +kernel
theorem parsed_call : parseCall callSource=some () := by decide +kernel
end Inference.Kernels.Quantization.AffineOuter4Syntax

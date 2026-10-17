import kernels.attention.MlxSdpaTwoPassStores
import kernels.attention.MlxSdpaMergeSource

namespace Inference.Kernels.Attention.MlxSdpaTwoPassMergeSyntax
open Copy.ScalarCopySyntax (Tokens)
open Normalization.MlxRmsLoopSyntax (word acceptAll)
set_option maxRecDepth 10000

def lex : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if [' ','\n','\t','\r'].contains c then lex fuel rest
    else if word c then do pure (String.ofList (c::rest.takeWhile word)::(←lex fuel (rest.dropWhile word)))
    else if ['(',')','[',']','{','}',';','=','+','*','<','>','-',':',',','?','/','.'].contains c then do
      pure (String.singleton c::(←lex fuel rest)) else none

inductive Maximum where | chunks deriving DecidableEq, Repr
inductive Denominator where | chunks deriving DecidableEq, Repr
inductive Numerator where | chunks deriving DecidableEq, Repr
inductive Transpose where | shared deriving DecidableEq, Repr
inductive Gate where | laneZero deriving DecidableEq, Repr
inductive Initial where | zero deriving DecidableEq, Repr

def parseInitial (source : String) : Option Initial := do
  let ts ←lex (source.length+1) source.toList
  let rest ←acceptAll ["thread","U","o","[","elem_per_thread","]","=","{","0","}",";",
    "U","sum_exp_score","=","0",".","0",";","U","max_score","=","Limits","<","U",">",":",":","finite_min",";"] ts
  if rest=[] then some .zero else none

def parsePointers (source : String) : Option (List MlxSdpaVectorSyntax.Pointer) := do
  let ts ←lex (source.length+1) source.toList
  let (a,rest) ←MlxSdpaTwoPassSyntax.pointer ts
  let (b,rest) ←MlxSdpaTwoPassSyntax.pointer rest
  let (c,rest) ←MlxSdpaTwoPassSyntax.pointer rest
  let (d,rest) ←MlxSdpaTwoPassSyntax.pointer rest
  if rest=[] then some [a,b,c,d] else none

def parseMaximum (source : String) : Option Maximum := do
  let ts ←lex (source.length+1) source.toList
  let rest ←acceptAll ["for","(","int","b","=","0",";","b","<","blocks","/","BN",";","+","+","b",")","{",
    "max_score","=","max","(","max_score",",","maxs","[","simd_lid","+","BN","*","b","]",")",";","}",
    "max_score","=","simd_max","(","max_score",")",";"] ts
  if rest=[] then some .chunks else none

def parseDenominator (source : String) : Option Denominator := do
  let ts ←lex (source.length+1) source.toList
  let rest ←acceptAll ["for","(","int","b","=","0",";","b","<","blocks","/","BN",";","+","+","b",")","{",
    "U","factor","=","fast",":",":","exp","(","maxs","[","simd_lid","+","BN","*","b","]","-","max_score",")",";",
    "sum_exp_score","+","=","factor","*","sums","[","simd_lid","+","BN","*","b","]",";","}",
    "sum_exp_score","=","simd_sum","(","sum_exp_score",")",";"] ts
  if rest=[] then some .chunks else none

def parseNumerator (source : String) : Option Numerator := do
  let ts ←lex (source.length+1) source.toList
  let rest ←acceptAll ["for","(","int","b","=","0",";","b","<","blocks","/","BN",";","+","+","b",")","{",
    "U","factor","=","fast",":",":","exp","(","maxs","[","simd_gid","]","-","max_score",")",";",
    "for","(","int","i","=","0",";","i","<","elem_per_thread",";","i","+","+",")","{",
    "o","[","i","]","+","=","factor","*","static_cast","<","U",">","(","partials","[","i","]",")",";","}",
    "maxs","+","=","BN",";","sums","+","=","BN",";","partials","+","=","BN","*","D",";","}"] ts
  if rest=[] then some .chunks else none

def parseTranspose (source : String) : Option Transpose := do
  let ts ←lex (source.length+1) source.toList
  let rest ←acceptAll ["for","(","int","i","=","0",";","i","<","elem_per_thread",";","i","+","+",")","{",
    "outputs","[","simd_lid","*","BD","+","simd_gid","]","=","o","[","i","]",";",
    "threadgroup_barrier","(","mem_flags",":",":","mem_threadgroup",")",";",
    "o","[","i","]","=","simd_sum","(","outputs","[","simd_gid","*","BD","+","simd_lid","]",")",";",
    "o","[","i","]","=","sum_exp_score","=","=","0","?","o","[","i","]",":","(","o","[","i","]","/","sum_exp_score",")",";",
    "threadgroup_barrier","(","mem_flags",":",":","mem_threadgroup",")",";","}"] ts
  if rest=[] then some .shared else none

def parseGate (source : String) : Option Gate := do
  let ts ←lex (source.length+1) source.toList
  let rest ←acceptAll ["if","(","simd_lid","=","=","0",")","{",
    "for","(","int","i","=","0",";","i","<","elem_per_thread",";","i","+","+",")","{",
    "out","[","i","]","=","static_cast","<","T",">","(","o","[","i","]",")",";","}","}"] ts
  if rest=[] then some .laneZero else none

def sourcePointers : String := r#"partials += q_offset * blocks * D + simd_gid * D + simd_lid * elem_per_thread;
  sums += q_offset * blocks;
  maxs += q_offset * blocks;
  out += q_offset * D + simd_gid * elem_per_thread;"#
def sourceMaximum : String := r#"for (int b = 0; b < blocks / BN; ++b) {
    max_score = max(max_score, maxs[simd_lid + BN * b]);
  }
  max_score = simd_max(max_score);"#
def sourceDenominator : String := r#"for (int b = 0; b < blocks / BN; ++b) {
    U factor = fast::exp(maxs[simd_lid + BN * b] - max_score);
    sum_exp_score += factor * sums[simd_lid + BN * b];
  }
  sum_exp_score = simd_sum(sum_exp_score);"#
def sourceNumerator : String := r#"for (int b = 0; b < blocks / BN; ++b) {
    U factor = fast::exp(maxs[simd_gid] - max_score);

    for (int i = 0; i < elem_per_thread; i++) {
      o[i] += factor * static_cast<U>(partials[i]);
    }
    maxs += BN;
    sums += BN;
    partials += BN * D;
  }"#
def sourceTranspose : String := r#"for (int i = 0; i < elem_per_thread; i++) {
    outputs[simd_lid * BD + simd_gid] = o[i];
    threadgroup_barrier(mem_flags::mem_threadgroup);
    o[i] = simd_sum(outputs[simd_gid * BD + simd_lid]);
    o[i] = sum_exp_score == 0 ? o[i] : (o[i] / sum_exp_score);
    threadgroup_barrier(mem_flags::mem_threadgroup);
  }"#
def sourceGate : String := r#"if (simd_lid == 0) {
    for (int i = 0; i < elem_per_thread; i++) {
      out[i] = static_cast<T>(o[i]);
    }
  }"#
def sourceInitial : String := r#"thread U o[elem_per_thread] = {0};
U sum_exp_score = 0.0;
  U max_score = Limits<U>::finite_min;"#

def partialPointer : MlxSdpaVectorSyntax.Pointer := ⟨"partials",.add (.add (.mul (.mul (.var "q_offset") (.var "blocks")) (.var "D"))
  (.mul (.var "simd_gid") (.var "D"))) (.mul (.var "simd_lid") (.var "elem_per_thread"))⟩
def sumPointer : MlxSdpaVectorSyntax.Pointer := ⟨"sums",.mul (.var "q_offset") (.var "blocks")⟩
def maxPointer : MlxSdpaVectorSyntax.Pointer := ⟨"maxs",sumPointer.offset⟩
def outputPointer : MlxSdpaVectorSyntax.Pointer := ⟨"out",.add (.mul (.var "q_offset") (.var "D")) (.mul (.var "simd_gid") (.var "elem_per_thread"))⟩
def pointers : List MlxSdpaVectorSyntax.Pointer := [partialPointer,sumPointer,maxPointer,outputPointer]

theorem parsed_pointers : parsePointers sourcePointers=some pointers := by decide +kernel
theorem parsed_maximum : parseMaximum sourceMaximum=some .chunks := by decide +kernel
theorem parsed_denominator : parseDenominator sourceDenominator=some .chunks := by decide +kernel
theorem parsed_numerator : parseNumerator sourceNumerator=some .chunks := by decide +kernel
theorem parsed_transpose : parseTranspose sourceTranspose=some .shared := by decide +kernel
theorem parsed_gate : parseGate sourceGate=some .laneZero := by decide +kernel
theorem parsed_initial : parseInitial sourceInitial=some .zero := by decide +kernel

end Inference.Kernels.Attention.MlxSdpaTwoPassMergeSyntax

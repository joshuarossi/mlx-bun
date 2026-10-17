import kernels.attention.MlxSdpaPartialSource

namespace Inference.Kernels.Attention.MlxSdpaMergeSyntax
open Copy.ScalarCopySyntax (Tokens)
open Normalization.MlxRmsLoopSyntax (word acceptAll)
set_option maxRecDepth 10000

def lex : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if [' ','\n','\t','\r'].contains c then lex fuel rest
    else if word c then do pure (String.ofList (c::rest.takeWhile word)::(←lex fuel (rest.dropWhile word)))
    else if ['(',')','[',']','{','}',';','=','+','*','<','>','-',':',',','?','/'].contains c then do
      pure (String.singleton c::(←lex fuel rest)) else none

inductive Summary where | shared deriving DecidableEq, Repr
inductive Transpose where | shared deriving DecidableEq, Repr
inductive Gate where | laneZero deriving DecidableEq, Repr

def parseSummary (source : String) : Option Summary := do
  let ts ←lex (source.length+1) source.toList
  let rest ←acceptAll ["if","(","simd_lid","=","=","0",")","{",
    "max_scores","[","simd_gid","]","=","max_score",";",
    "sum_exp_scores","[","simd_gid","]","=","sum_exp_score",";","}",
    "threadgroup_barrier","(","mem_flags",":",":","mem_threadgroup",")",";",
    "max_score","=","max_scores","[","simd_lid","]",";",
    "U","new_max","=","simd_max","(","max_score",")",";",
    "U","factor","=","fast",":",":","exp","(","max_score","-","new_max",")",";",
    "sum_exp_score","=","simd_sum","(","sum_exp_scores","[","simd_lid","]","*","factor",")",";"] ts
  if rest=[] then some .shared else none

def parseTranspose (source : String) : Option Transpose := do
  let ts ←lex (source.length+1) source.toList
  let rest ←acceptAll ["for","(","int","i","=","0",";","i","<","v_per_thread",";","i","+","+",")","{",
    "outputs","[","simd_lid","*","BD","+","simd_gid","]","=","o","[","i","]",";",
    "threadgroup_barrier","(","mem_flags",":",":","mem_threadgroup",")",";",
    "o","[","i","]","=","simd_sum","(","outputs","[","simd_gid","*","BD","+","simd_lid","]","*","factor",")",";",
    "o","[","i","]","=","sum_exp_score","=","=","0","?","o","[","i","]",":","(","o","[","i","]","/","sum_exp_score",")",";",
    "threadgroup_barrier","(","mem_flags",":",":","mem_threadgroup",")",";","}"] ts
  if rest=[] then some .shared else none

def parseGate (source : String) : Option Gate := do
  let ts ←lex (source.length+1) source.toList
  let rest ←acceptAll ["if","(","simd_lid","=","=","0",")","{",
    "for","(","int","i","=","0",";","i","<","v_per_thread",";","i","+","+",")","{","CELL",";","}","}"] ts
  if rest=[] then some .laneZero else none

def sourceSummary : String := r#"if (simd_lid == 0) {
    max_scores[simd_gid] = max_score;
    sum_exp_scores[simd_gid] = sum_exp_score;
  }
  threadgroup_barrier(mem_flags::mem_threadgroup);
  max_score = max_scores[simd_lid];
  U new_max = simd_max(max_score);
  U factor = fast::exp(max_score - new_max);
  sum_exp_score = simd_sum(sum_exp_scores[simd_lid] * factor);"#
def sourceTranspose : String := r#"for (int i = 0; i < v_per_thread; i++) {
    outputs[simd_lid * BD + simd_gid] = o[i];
    threadgroup_barrier(mem_flags::mem_threadgroup);
    o[i] = simd_sum(outputs[simd_gid * BD + simd_lid] * factor);
    o[i] = sum_exp_score == 0 ? o[i] : (o[i] / sum_exp_score);
    threadgroup_barrier(mem_flags::mem_threadgroup);
  }"#
def sourceGate : String := r#"if (simd_lid == 0) {
    for (int i = 0; i < v_per_thread; i++) { CELL; }
  }"#

theorem parsed_summary : parseSummary sourceSummary=some .shared := by decide +kernel
theorem parsed_transpose : parseTranspose sourceTranspose=some .shared := by decide +kernel
theorem parsed_gate : parseGate sourceGate=some .laneZero := by decide +kernel

end Inference.Kernels.Attention.MlxSdpaMergeSyntax

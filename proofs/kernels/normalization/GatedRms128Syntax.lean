import kernels.delta.GatedPointerSyntax

namespace Inference.Kernels.Normalization.GatedRms128Syntax
open Copy.ScalarCopySyntax (Tokens)
open Normalization.MlxRmsLoopSyntax (acceptAll word)
set_option maxRecDepth 10000

def lex : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lex fuel rest
    else if word c || c=='.' then do
      let inWord := fun c => word c || c=='.'
      pure (String.ofList (c::rest.takeWhile inWord)::(←lex fuel (rest.dropWhile inWord)))
    else if ['(',')','[',']','{','}',';','=','+','*','<','>','-','/',':','?',','].contains c then do
      pure (String.singleton c::(←lex fuel rest)) else none

def parseExact (expected : Tokens) (source : String) : Option Unit := do
  let tokens ←lex (source.length+1) source.toList
  let rest ←acceptAll expected tokens
  if rest=[] then some () else none

def parseInitial : String → Option Unit := parseExact ["const","uint","row","=","threadgroup_position_in_grid.x",";","const","uint","lane","=","thread_index_in_simdgroup",";","float","acc","=","0.0f",";","const","uint","tid","=","thread_position_in_threadgroup.x",";","threadgroup","float","sums","[","32","]",";","threadgroup","float","inverse","[","1","]",";"]

def initialSource : String := r#"const uint row = threadgroup_position_in_grid.x;
  const uint lane = thread_index_in_simdgroup;
  float acc = 0.0f;
  const uint tid = thread_position_in_threadgroup.x;
  threadgroup float sums[32];
  threadgroup float inverse[1];"#

theorem parsed_initial : parseInitial initialSource=some () := by decide +kernel

def parseFirst : String → Option Unit := parseExact ["for","(","uint","r","=","0",";","r","<","uint","(","D",")",";","r","+","=","uint","(","THREADS",")","*","4u",")","{","for","(","uint","i","=","0",";","i","<","4u",";","+","+","i",")","{","const","uint","col","=","r","+","tid","*","4u","+","i",";","const","float","value","=","col","<","uint","(","D",")","?","float","(","x","[","row","*","uint","(","D",")","+","col","]",")",":","0.0f",";","acc","+","=","value","*","value",";","}","}","acc","=","metal",":",":","simd_sum","(","acc",")",";"]

def firstSource : String := r#"for (uint r = 0; r < uint(D); r += uint(THREADS) * 4u) {
    for (uint i = 0; i < 4u; ++i) {
      const uint col = r + tid * 4u + i;
      const float value = col < uint(D) ? float(x[row * uint(D) + col]) : 0.0f;
      acc += value * value;
    }
  }
  acc = metal::simd_sum(acc);"#

theorem parsed_first : parseFirst firstSource=some () := by decide +kernel

def parseMulti : String → Option Unit := parseExact ["if","(","THREADS",">","32",")","{","const","uint","sg","=","simdgroup_index_in_threadgroup",";","if","(","sg","=","=","0",")","sums","[","lane","]","=","0.0f",";","threadgroup_barrier","(","metal",":",":","mem_flags",":",":","mem_threadgroup",")",";","if","(","lane","=","=","0",")","sums","[","sg","]","=","acc",";","threadgroup_barrier","(","metal",":",":","mem_flags",":",":","mem_threadgroup",")",";","if","(","sg","=","=","0",")","{","acc","=","metal",":",":","simd_sum","(","sums","[","lane","]",")",";","if","(","lane","=","=","0",")","inverse","[","0","]","=","metal",":",":","precise",":",":","rsqrt","(","acc","/","float","(","D",")","+","as_type","<","float",">","(","uint","(","EPS",")",")",")",";","}","threadgroup_barrier","(","metal",":",":","mem_flags",":",":","mem_threadgroup",")",";","}"]

def multiSource : String := r#"if (THREADS > 32) {
    const uint sg = simdgroup_index_in_threadgroup;
    if (sg == 0) sums[lane] = 0.0f;
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
    if (lane == 0) sums[sg] = acc;
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
    if (sg == 0) {
      acc = metal::simd_sum(sums[lane]);
      if (lane == 0) inverse[0] = metal::precise::rsqrt(acc / float(D) + as_type<float>(uint(EPS)));
    }
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }"#

theorem parsed_multi : parseMulti multiSource=some () := by decide +kernel

def parseInverse : String → Option Unit := parseExact ["const","float","inv","=","THREADS",">","32","?","inverse","[","0","]",":","metal",":",":","precise",":",":","rsqrt","(","acc","/","float","(","D",")","+","as_type","<","float",">","(","uint","(","EPS",")",")",")",";"]

def inverseSource : String := r#"const float inv = THREADS > 32 ? inverse[0]
    : metal::precise::rsqrt(acc / float(D) + as_type<float>(uint(EPS)));"#

theorem parsed_inverse : parseInverse inverseSource=some () := by decide +kernel

def parseOutput : String → Option Unit := parseExact ["for","(","uint","r","=","0",";","r","<","uint","(","D",")",";","r","+","=","uint","(","THREADS",")","*","4u",")","{","for","(","uint","i","=","0",";","i","<","4u",";","+","+","i",")","{","const","uint","col","=","r","+","tid","*","4u","+","i",",","index","=","row","*","uint","(","D",")","+","col",";","if","(","col",">","=","uint","(","D",")",")","continue",";","const","T","normalized","=","weight","[","col","]","*","T","(","float","(","x","[","index","]",")","*","inv",")",";","const","float","g","=","float","(","gate","[","index","]",")",";","const","float","y","=","1.0f","/","(","1.0f","+","metal",":",":","exp","(","metal",":",":","abs","(","g",")",")",")",";","const","float","sigmoid","=","g","<","0.0f","?","y",":","1.0f","-","y",";","out","[","index","]","=","T","(","(","g","*","sigmoid",")","*","float","(","normalized",")",")",";","}","}"]

def outputSource : String := r#"for (uint r = 0; r < uint(D); r += uint(THREADS) * 4u) {
    for (uint i = 0; i < 4u; ++i) {
      const uint col = r + tid * 4u + i, index = row * uint(D) + col;
      if (col >= uint(D)) continue;
      const T normalized = weight[col] * T(float(x[index]) * inv);
      const float g = float(gate[index]);
      const float y = 1.0f / (1.0f + metal::exp(metal::abs(g)));
      const float sigmoid = g < 0.0f ? y : 1.0f - y;
      out[index] = T((g * sigmoid) * float(normalized));
    }
  }"#

theorem parsed_output : parseOutput outputSource=some () := by decide +kernel

end Inference.Kernels.Normalization.GatedRms128Syntax

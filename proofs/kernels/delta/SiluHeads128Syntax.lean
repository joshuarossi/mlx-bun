import kernels.normalization.GatedRms128Syntax

namespace Inference.Kernels.Delta.SiluHeads128Syntax
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
    else if ['(',')','[',']','{','}',';','=','+','*','<','>','-','/','%',':','?',','].contains c then do
      pure (String.singleton c::(←lex fuel rest)) else none

def parseExact (expected : Tokens) (source : String) : Option Unit := do
  let tokens ←lex (source.length+1) source.toList
  let rest ←acceptAll expected tokens
  if rest=[] then some () else none

def parseHeader : String → Option Unit := parseExact ["const","uint","lane","=","thread_index_in_simdgroup",";","const","uint","head","=","threadgroup_position_in_grid.x",";","const","uint","row","=","threadgroup_position_in_grid.y",";","const","bool","normalize","=","head","<","uint","(","2","*","HK",")",";","const","uint","width","=","normalize","?","uint","(","DK",")",":","uint","(","DV",")",";","const","uint","channel","=","normalize","?","head","*","uint","(","DK",")",":","uint","(","2","*","HK","*","DK",")","+","(","head","-","uint","(","2","*","HK",")",")","*","uint","(","DV",")",";","T","values","[","4","]",";","float","sum","=","0.0f",";"]

def headerSource : String := r#"const uint lane = thread_index_in_simdgroup;
  const uint head = threadgroup_position_in_grid.x;
  const uint row = threadgroup_position_in_grid.y;
  const bool normalize = head < uint(2 * HK);
  const uint width = normalize ? uint(DK) : uint(DV);
  const uint channel = normalize ? head * uint(DK)
    : uint(2 * HK * DK) + (head - uint(2 * HK)) * uint(DV);
  T values[4];
  float sum = 0.0f;"#

theorem parsed_header : parseHeader headerSource=some () := by decide +kernel

def parseActivation : String → Option Unit := parseExact ["for","(","uint","i","=","0",";","i","<","4u",";","+","+","i",")","{","const","uint","col","=","lane","*","4u","+","i",";","const","T","value","=","col","<","width","?","x","[","row","*","uint","(","C",")","+","channel","+","col","]",":","T","(","0",")",";","const","auto","y","=","1","/","(","1","+","metal",":",":","exp","(","metal",":",":","abs","(","value",")",")",")",";","const","T","sigmoid","=","T","(","value","<","T","(","0",")","?","y",":","1","-","y",")",";","values","[","i","]","=","T","(","value","*","sigmoid",")",";","const","float","activated","=","float","(","values","[","i","]",")",";","sum","+","=","activated","*","activated",";","}"]

def activationSource : String := r#"for (uint i = 0; i < 4u; ++i) {
    const uint col = lane * 4u + i;
    const T value = col < width ? x[row * uint(C) + channel + col] : T(0);
    const auto y = 1 / (1 + metal::exp(metal::abs(value)));
    const T sigmoid = T(value < T(0) ? y : 1 - y);
    values[i] = T(value * sigmoid);
    const float activated = float(values[i]);
    sum += activated * activated;
  }"#

theorem parsed_activation : parseActivation activationSource=some () := by decide +kernel

def parseOutput : String → Option Unit := parseExact ["if","(","normalize",")","{","sum","=","metal",":",":","simd_sum","(","sum",")",";","const","float","inv","=","metal",":",":","precise",":",":","rsqrt","(","sum","/","float","(","DK",")","+","1e","-","6f",")",";","const","uint","index","=","(","row","*","uint","(","HK",")","+","head","%","uint","(","HK",")",")","*","uint","(","DK",")","+","lane","*","4u",";","for","(","uint","i","=","0",";","i","<","4u",";","+","+","i",")","{","if","(","lane","*","4u","+","i",">","=","uint","(","DK",")",")","continue",";","const","T","normalized","=","T","(","float","(","values","[","i","]",")","*","inv",")",";","if","(","head","<","uint","(","HK",")",")","q","[","index","+","i","]","=","qscale","[","lane","*","4u","+","i","]","*","normalized",";","else","k","[","index","+","i","]","=","kscale","[","lane","*","4u","+","i","]","*","normalized",";","}","}","else","{","const","uint","index","=","(","row","*","uint","(","HV",")","+","head","-","uint","(","2","*","HK",")",")","*","uint","(","DV",")","+","lane","*","4u",";","for","(","uint","i","=","0",";","i","<","4u",";","+","+","i",")","if","(","lane","*","4u","+","i","<","uint","(","DV",")",")","v","[","index","+","i","]","=","values","[","i","]",";","}"]

def outputSource : String := r#"if (normalize) {
    sum = metal::simd_sum(sum);
    const float inv = metal::precise::rsqrt(sum / float(DK) + 1e-6f);
    const uint index = (row * uint(HK) + head % uint(HK)) * uint(DK) + lane * 4u;
    for (uint i = 0; i < 4u; ++i) {
      if (lane * 4u + i >= uint(DK)) continue;
      const T normalized = T(float(values[i]) * inv);
      if (head < uint(HK)) q[index + i] = qscale[lane * 4u + i] * normalized;
      else k[index + i] = kscale[lane * 4u + i] * normalized;
    }
  } else {
    const uint index = (row * uint(HV) + head - uint(2 * HK)) * uint(DV) + lane * 4u;
    for (uint i = 0; i < 4u; ++i) if (lane * 4u + i < uint(DV)) v[index + i] = values[i];
  }"#

theorem parsed_output : parseOutput outputSource=some () := by decide +kernel

end Inference.Kernels.Delta.SiluHeads128Syntax

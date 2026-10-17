import kernels.normalization.MlxRmsLoopSyntax

namespace Inference.Kernels.Delta.GatedStepSyntax
open Copy.ScalarCopySyntax (Tokens)
open Normalization.MlxRmsLoopSyntax (acceptAll natural word)
set_option maxRecDepth 10000

structure Loop where
  first : Nat
  deriving DecidableEq, Repr
inductive Delta where | differenceTimesBeta deriving DecidableEq, Repr

def lex : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lex fuel rest
    else if word c || c=='.' then do
      let inWord := fun c => word c || c=='.'
      pure (String.ofList (c::rest.takeWhile inWord)::(←lex fuel (rest.dropWhile inWord)))
    else if ['(',')','[',']','{','}',';','=','+','*','<','-'].contains c then do
      pure (String.singleton c::(←lex fuel rest)) else none

def loopStart (ts : Tokens) : Option (Nat × Tokens) := do
  let rest ←acceptAll ["for","(","int","i","="] ts
  let (first,rest) ←natural rest
  let rest ←acceptAll [";","i","<","n_per_t",";","+","+","i",")","{",
    "auto","s_idx","=","n_per_t","*","dk_idx","+","i",";"] rest
  pure (first,rest)

def parsePrediction (source : String) : Option Loop := do
  let ts ←lex (source.length+1) source.toList
  let rest ←acceptAll ["float","kv_mem","=","0.0f",";"] ts
  let (first,rest) ←loopStart rest
  let rest ←acceptAll ["state","[","i","]","=","state","[","i","]","*","g_","[","hv_idx","]",";",
    "kv_mem","+","=","state","[","i","]","*","k_","[","s_idx","]",";","}",
    "kv_mem","=","simd_sum","(","kv_mem",")",";"] rest
  if rest=[] then some ⟨first⟩ else none

def parseDelta (source : String) : Option Delta := do
  let ts ←lex (source.length+1) source.toList
  let rest ←acceptAll ["auto","delta","=","(","v_","[","dv_idx","]","-","kv_mem",")","*","beta_","[","hv_idx","]",";"] ts
  if rest=[] then some .differenceTimesBeta else none

def parseCorrection (source : String) : Option Loop := do
  let ts ←lex (source.length+1) source.toList
  let rest ←acceptAll ["float","out","=","0.0f",";"] ts
  let (first,rest) ←loopStart rest
  let rest ←acceptAll ["state","[","i","]","=","state","[","i","]","+","k_","[","s_idx","]","*","delta",";",
    "out","+","=","state","[","i","]","*","q_","[","s_idx","]",";","}",
    "out","=","simd_sum","(","out",")",";"] rest
  if rest=[] then some ⟨first⟩ else none

def predictionSource : String := r#"float kv_mem = 0.0f;
        for (int i = 0; i < n_per_t; ++i) {
          auto s_idx = n_per_t * dk_idx + i;
          state[i] = state[i] * g_[hv_idx];
          kv_mem += state[i] * k_[s_idx];
        }
        kv_mem = simd_sum(kv_mem);"#

def deltaSource : String := "auto delta = (v_[dv_idx] - kv_mem) * beta_[hv_idx];"

def correctionSource : String := r#"float out = 0.0f;
        for (int i = 0; i < n_per_t; ++i) {
          auto s_idx = n_per_t * dk_idx + i;
          state[i] = state[i] + k_[s_idx] * delta;
          out += state[i] * q_[s_idx];
        }
        out = simd_sum(out);"#

theorem parsed_prediction : parsePrediction predictionSource=some ⟨0⟩ := by decide +kernel
theorem parsed_delta : parseDelta deltaSource=some .differenceTimesBeta := by decide +kernel
theorem parsed_correction : parseCorrection correctionSource=some ⟨0⟩ := by decide +kernel

end Inference.Kernels.Delta.GatedStepSyntax

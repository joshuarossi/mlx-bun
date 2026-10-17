import kernels.delta.GatedStepSyntax

namespace Inference.Kernels.Delta.GatedPointerSyntax
open Copy.ScalarCopySyntax (Tokens)
open Normalization.MlxRmsLoopSyntax (acceptAll natural word)
set_option maxRecDepth 10000

def lex : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lex fuel rest
    else if word c || c=='.' then do
      let inWord := fun c => word c || c=='.'
      pure (String.ofList (c::rest.takeWhile inWord)::(←lex fuel (rest.dropWhile inWord)))
    else if ['(',')','[',']','{','}',';','=','+','*','<','>','-','/','%'].contains c then do
      pure (String.singleton c::(←lex fuel rest)) else none

def parseExact (expected : Tokens) (source : String) : Option Unit := do
  let tokens ←lex (source.length+1) source.toList
  let rest ←acceptAll expected tokens
  if rest=[] then some () else none

def parseHeader : String → Option Unit := parseExact ["const","int","T","=","Tin","[","0","]",";","auto","n","=","thread_position_in_grid.z",";","auto","b_idx","=","n","/","Hv",";","auto","hv_idx","=","n","%","Hv",";","auto","hk_idx","=","hv_idx","/","(","Hv","/","Hk",")",";","constexpr","int","n_per_t","=","Dk","/","32",";"]

def headerSource : String := r#"const int T = Tin[0];
    auto n = thread_position_in_grid.z;
    auto b_idx = n / Hv;
    auto hv_idx = n % Hv;
    auto hk_idx = hv_idx / (Hv / Hk);
    constexpr int n_per_t = Dk / 32;"#

theorem parsed_header : parseHeader headerSource=some () := by decide +kernel

def parseQuery : String → Option Unit := parseExact ["auto","q_","=","q","+","b_idx","*","T","*","Hk","*","Dk","+","hk_idx","*","Dk",";","auto","k_","=","k","+","b_idx","*","T","*","Hk","*","Dk","+","hk_idx","*","Dk",";"]

def querySource : String := r#"auto q_ = q + b_idx * T * Hk * Dk + hk_idx * Dk;
    auto k_ = k + b_idx * T * Hk * Dk + hk_idx * Dk;"#

theorem parsed_query : parseQuery querySource=some () := by decide +kernel

def parseValue : String → Option Unit := parseExact ["auto","v_","=","v","+","b_idx","*","T","*","Hv","*","Dv","+","hv_idx","*","Dv",";","y","+","=","b_idx","*","T","*","Hv","*","Dv","+","hv_idx","*","Dv",";"]

def valueSource : String := r#"auto v_ = v + b_idx * T * Hv * Dv + hv_idx * Dv;
    y += b_idx * T * Hv * Dv + hv_idx * Dv;"#

theorem parsed_value : parseValue valueSource=some () := by decide +kernel

def parseThread : String → Option Unit := parseExact ["auto","dk_idx","=","thread_position_in_threadgroup.x",";","auto","dv_idx","=","thread_position_in_grid.y",";"]

def threadSource : String := r#"auto dk_idx = thread_position_in_threadgroup.x;
    auto dv_idx = thread_position_in_grid.y;"#

theorem parsed_thread : parseThread threadSource=some () := by decide +kernel

def parseState : String → Option Unit := parseExact ["auto","i_state","=","state_in","+","(","n","*","Dv","+","dv_idx",")","*","Dk",";","auto","o_state","=","state_out","+","(","n","*","Dv","+","dv_idx",")","*","Dk",";"]

def stateSource : String := r#"auto i_state = state_in + (n * Dv + dv_idx) * Dk;
    auto o_state = state_out + (n * Dv + dv_idx) * Dk;"#

theorem parsed_state : parseState stateSource=some () := by decide +kernel

def parseInitial : String → Option Unit := parseExact ["float","state","[","n_per_t","]",";","for","(","int","i","=","0",";","i","<","n_per_t",";","+","+","i",")","{","auto","s_idx","=","n_per_t","*","dk_idx","+","i",";","state","[","i","]","=","static_cast","<","float",">","(","i_state","[","s_idx","]",")",";","}"]

def initialSource : String := r#"float state[n_per_t];
    for (int i = 0; i < n_per_t; ++i) {
      auto s_idx = n_per_t * dk_idx + i;
      state[i] = static_cast<float>(i_state[s_idx]);
    }"#

theorem parsed_initial : parseInitial initialSource=some () := by decide +kernel

def parseGate : String → Option Unit := parseExact ["auto","g_","=","g","+","b_idx","*","T","*","Hv",";","auto","beta_","=","beta","+","b_idx","*","T","*","Hv",";"]

def gateSource : String := r#"auto g_ = g + b_idx * T * Hv;
    auto beta_ = beta + b_idx * T * Hv;"#

theorem parsed_gate : parseGate gateSource=some () := by decide +kernel

end Inference.Kernels.Delta.GatedPointerSyntax

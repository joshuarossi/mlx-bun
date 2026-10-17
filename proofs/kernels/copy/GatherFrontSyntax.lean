import kernels.normalization.MlxRmsLoopSyntax
namespace Inference.Kernels.Copy.GatherFrontSyntax
open ScalarCopySyntax (Tokens)
open Kernels.Normalization.MlxRmsLoopSyntax (acceptAll word)
set_option maxRecDepth 10000

-- A restricted recognizer for the complete selected gather body and its
-- index helper. Templates, host argument bindings and Metal remain explicit.
def lex : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lex fuel rest
    else if word c || c=='.' then do
      let inWord := fun c => word c || c=='.'
      pure (String.ofList (c::rest.takeWhile inWord)::(←lex fuel (rest.dropWhile inWord)))
    else if ['(',')','[',']','{','}',';','=','+','*','<','>','-','/',':','?',',','&'].contains c then do
      pure (String.singleton c::(←lex fuel rest)) else none

def parseExact (expected : Tokens) (source : String) : Option Unit := do
  let tokens ←lex (source.length+1) source.toList
  let rest ←acceptAll expected tokens
  if rest=[] then some () else none

def bodySource : String := r#"auto idx = offset_neg_idx(indices[index.y], size);
  LocT src_idx = static_cast<LocT>(stride) * idx;
  LocT out_idx = static_cast<LocT>(stride) * index.y;

  int s_idx = N * index.x;
  for (int i = 0; i < N && s_idx < stride; ++i, ++s_idx) {
    out[out_idx + s_idx] = src[src_idx + s_idx];
  }"#

def parseBody : String → Option Unit := parseExact ["auto","idx","=","offset_neg_idx","(","indices","[","index.y","]",",","size",")",";","LocT","src_idx","=","static_cast","<","LocT",">","(","stride",")","*","idx",";","LocT","out_idx","=","static_cast","<","LocT",">","(","stride",")","*","index.y",";","int","s_idx","=","N","*","index.x",";","for","(","int","i","=","0",";","i","<","N","&","&","s_idx","<","stride",";","+","+","i",",","+","+","s_idx",")","{","out","[","out_idx","+","s_idx","]","=","src","[","src_idx","+","s_idx","]",";","}"]

theorem parsed_body : parseBody bodySource=some () := by decide +kernel

def indexSource : String := r#"if (is_unsigned_v<IdxT>) {
    return idx;
  } else {
    return (idx < 0) ? idx + size : idx;
  }"#

def parseIndex : String → Option Unit := parseExact ["if","(","is_unsigned_v","<","IdxT",">",")","{","return","idx",";","}","else","{","return","(","idx","<","0",")","?","idx","+","size",":","idx",";","}"]

theorem parsed_index : parseIndex indexSource=some () := by decide +kernel

end Inference.Kernels.Copy.GatherFrontSyntax

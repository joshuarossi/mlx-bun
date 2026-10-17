import kernels.copy.ScalarCopySyntax

namespace Inference.Kernels.Sampling.ArgmaxShuffleSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken decimal)
set_option maxRecDepth 20000

inductive Expr where
  | variable : String → Expr
  | gt : Expr → Expr → Expr
  | eq : Expr → Expr → Expr
  | lt : Expr → Expr → Expr
  | land : Expr → Expr → Expr
  | lor : Expr → Expr → Expr
  deriving DecidableEq, Repr

def wordChar (c : Char) : Bool :=
  ('a'≤c && c≤'z') || ('A'≤c && c≤'Z') || ('0'≤c && c≤'9') || c=='_'
def whitespace (c : Char) : Bool := [' ','\n','\r','\t'].contains c

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if whitespace c then lexAux fuel (rest.dropWhile whitespace)
    else if wordChar c then do
      pure (String.ofList (c::rest.takeWhile wordChar)::(←lexAux fuel (rest.dropWhile wordChar)))
    else match c,rest with
    | '&','&'::tail => do pure ("&&"::(←lexAux fuel tail))
    | '|','|'::tail => do pure ("||"::(←lexAux fuel tail))
    | '=','='::tail => do pure ("=="::(←lexAux fuel tail))
    | '>','>'::'='::tail => do pure (">>="::(←lexAux fuel tail))
    | _,_ => if ['{','}','(',')',';',',','+','=','<','>'].contains c then do
        pure (String.singleton c::(←lexAux fuel rest)) else none

def tokenize (source : String) := lexAux (source.length+1) source.toList

def operator : String → Option (Nat × (Expr → Expr → Expr))
  | "||" => some (1,Expr.lor) | "&&" => some (2,Expr.land)
  | "==" => some (3,Expr.eq) | ">" => some (4,Expr.gt) | "<" => some (4,Expr.lt)
  | _ => none
mutual
  def expression : Nat → Nat → Parser Expr
    | 0,_,_ => none
    | fuel+1,minimum,tokens => do
      let (left,rest) ← primary fuel tokens
      climb fuel minimum left rest
  def primary : Nat → Parser Expr
    | 0,_ => none
    | fuel+1,"("::rest => do
      let (value,rest) ← expression fuel 0 rest
      pure (value,←accept ")" rest)
    | _+1,tokens => do
      let (name,rest) ← nameToken tokens
      pure (.variable name,rest)
  def climb : Nat → Nat → Expr → Parser Expr
    | 0,_,_,_ => none
    | fuel+1,minimum,left,tokens =>
      match tokens with
      | token::rest => match operator token with
        | some (precedence,combine) => if minimum≤precedence then do
            let (right,rest) ← expression fuel (precedence+1) rest
            climb fuel minimum (combine left right) rest
          else some (left,tokens)
        | none => some (left,tokens)
      | [] => some (left,[])
end

def acceptMany : Tokens → Tokens → Option Tokens
  | [],rest => some rest
  | expected::tail,tokens => do acceptMany tail (←accept expected tokens)

def natural : Parser Nat
  | token::rest => do pure (←decimal token,rest)
  | [] => none

def parseBetterTokens (tokens : Tokens) : Option Expr := do
  let rest ← acceptMany ["{","return"] tokens
  let (value,rest) ← expression 128 0 rest
  let rest ← acceptMany [";","}"] rest
  if rest=[] then some value else none

def parseBetter (source : String) : Option Expr := do parseBetterTokens (←tokenize source)

-- A restricted complete shuffle loop grammar. Names, types, operations and
-- assignment ordering are checked; the three source constants remain data.
structure Loop where
  start : Nat
  shift : Nat
  bound : Nat
  deriving DecidableEq, Repr

def parseLoopTokens (tokens : Tokens) : Option Loop := do
  let rest ← acceptMany ["for","(","uint","distance","="] tokens
  let (start,rest) ← natural rest
  let rest ← acceptMany [";","distance",">","0",";","distance",">>="] rest
  let (shift,rest) ← natural rest
  let rest ← acceptMany [")","{","float","other","=","simd_shuffle_down","(","best",",","distance",")",";",
    "uint","oi","=","simd_shuffle_down","(","bestId",",","distance",")",";",
    "if","(","lane","+","distance","<"] rest
  let (bound,rest) ← natural rest
  let rest ← acceptMany ["&&","better","(","other",",","oi",",","best",",","bestId",")",")","{",
    "best","=","other",";","bestId","=","oi",";","}","}"] rest
  if rest=[] then some ⟨start,shift,bound⟩ else none

def parseLoop (source : String) : Option Loop := do parseLoopTokens (←tokenize source)

def betterBody : String := r#"{
  return x > y || (x == y && xi < yi);
}"#
def simdLoop : String := r#"for (uint distance = 16; distance > 0; distance >>= 1) {
    float other = simd_shuffle_down(best, distance);
    uint oi = simd_shuffle_down(bestId, distance);
    if (lane + distance < 32 && better(other, oi, best, bestId)) {
      best = other; bestId = oi;
    }
  }"#
def mergeLoop : String := r#"for (uint distance = 2; distance > 0; distance >>= 1) {
      float other = simd_shuffle_down(best, distance);
      uint oi = simd_shuffle_down(bestId, distance);
      if (lane + distance < 4 && better(other, oi, best, bestId)) {
        best = other; bestId = oi;
      }
    }"#
def betterExpr : Expr := .lor (.gt (.variable "x") (.variable "y"))
  (.land (.eq (.variable "x") (.variable "y")) (.lt (.variable "xi") (.variable "yi")))
def betterBodyTokens : Tokens := ["{","return","x",">","y","||","(","x","==","y","&&","xi","<","yi",")",";","}"]
theorem lexed_betterBody : tokenize betterBody=some betterBodyTokens := by decide +kernel
def simdLoopTokens : Tokens := ["for","(","uint","distance","=","16",";","distance",">","0",";","distance",">>=","1",")","{","float","other","=","simd_shuffle_down","(","best",",","distance",")",";","uint","oi","=","simd_shuffle_down","(","bestId",",","distance",")",";","if","(","lane","+","distance","<","32","&&","better","(","other",",","oi",",","best",",","bestId",")",")","{","best","=","other",";","bestId","=","oi",";","}","}"]
theorem lexed_simdLoop : tokenize simdLoop=some simdLoopTokens := by decide +kernel
def mergeLoopTokens : Tokens := ["for","(","uint","distance","=","2",";","distance",">","0",";","distance",">>=","1",")","{","float","other","=","simd_shuffle_down","(","best",",","distance",")",";","uint","oi","=","simd_shuffle_down","(","bestId",",","distance",")",";","if","(","lane","+","distance","<","4","&&","better","(","other",",","oi",",","best",",","bestId",")",")","{","best","=","other",";","bestId","=","oi",";","}","}"]
theorem lexed_mergeLoop : tokenize mergeLoop=some mergeLoopTokens := by decide +kernel

theorem parsed_better : parseBetter betterBody=some betterExpr := by
  simp only [parseBetter,lexed_betterBody]
  decide +kernel
theorem parsed_simd : parseLoop simdLoop=some ⟨16,1,32⟩ := by
  simp only [parseLoop,lexed_simdLoop]
  decide +kernel
theorem parsed_merge : parseLoop mergeLoop=some ⟨2,1,4⟩ := by
  simp only [parseLoop,lexed_mergeLoop]
  decide +kernel


end Inference.Kernels.Sampling.ArgmaxShuffleSyntax

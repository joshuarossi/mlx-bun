import kernels.trellis.CodebookIntegerSyntax
namespace Inference.Kernels.Trellis.CodebookWindowSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken wordChar)
set_option maxRecDepth 10000
inductive Expr where
  | variable : String → Expr
  | literal : CodebookIntegerSyntax.LiteralKind → Nat → Expr
  | index : String → Expr → Expr
  | castInt : Expr → Expr
  | castUInt : Expr → Expr
  | add : Expr → Expr → Expr
  | subtract : Expr → Expr → Expr
  | multiply : Expr → Expr → Expr
  | bitAnd : Expr → Expr → Expr
  | shiftLeft : Expr → Expr → Expr
  | shiftRight : Expr → Expr → Expr
  | ge : Expr → Expr → Expr
  | le : Expr → Expr → Expr
  | logicalAnd : Expr → Expr → Expr
  deriving DecidableEq,Repr
inductive Stmt where
  | constInt : String → Expr → Stmt
  | constUInt : String → Expr → Stmt
  | declareUInt : String → Stmt
  | assignUInt : String → Expr → Stmt
  | ifElse : Expr → List Stmt → List Stmt → Stmt
  | returnTable : String → Expr → Stmt
  deriving Repr

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c then do
      pure (String.ofList (c::rest.takeWhile wordChar)::(←lexAux fuel (rest.dropWhile wordChar)))
    else if ['<','>','&'].contains c then
      match rest with
      | d::tail =>
        if d=c ∨ d='=' then do pure (String.ofList [c,d]::(←lexAux fuel tail))
        else do pure (String.singleton c::(←lexAux fuel rest))
      | [] => some [String.singleton c]
    else if ['{','}','(',')','[',']',';','=','+','-','*'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

def literal (token : String) : Option Expr := do
  match ←CodebookIntegerSyntax.literal token with
  | .literal kind value => some (.literal kind value)
  | _ => none

def operator : String → Option (Nat × (Expr → Expr → Expr))
  | "&&" => some (1,Expr.logicalAnd)
  | ">=" => some (2,Expr.ge)
  | "<=" => some (2,Expr.le)
  | "&" => some (3,Expr.bitAnd)
  | "<<" => some (4,Expr.shiftLeft)
  | ">>" => some (4,Expr.shiftRight)
  | "+" => some (5,Expr.add)
  | "-" => some (5,Expr.subtract)
  | "*" => some (6,Expr.multiply)
  | _ => none
mutual
  def expression : Nat → Nat → Parser Expr
    | 0,_,_ => none
    | fuel+1,minimum,ts => do
      let (left,rest) ← primary fuel ts
      climb fuel minimum left rest
  def primary : Nat → Parser Expr
    | 0,_ => none
    | fuel+1,"int"::"("::rest => do
      let (value,rest) ← expression fuel 0 rest
      let rest ← accept ")" rest
      pure (.castInt value,rest)
    | fuel+1,"uint"::"("::rest => do
      let (value,rest) ← expression fuel 0 rest
      let rest ← accept ")" rest
      pure (.castUInt value,rest)
    | fuel+1,"("::rest => do
      let (value,rest) ← expression fuel 0 rest
      let rest ← accept ")" rest
      pure (value,rest)
    | fuel+1,name::"["::rest => do
      let (name,_) ← nameToken [name]
      let (value,rest) ← expression fuel 0 rest
      let rest ← accept "]" rest
      pure (.index name value,rest)
    | _+1,token::rest =>
      match literal token with
      | some value => some (value,rest)
      | none => do
        let (name,rest) ← nameToken (token::rest)
        pure (.variable name,rest)
    | _+1,[] => none
  def climb : Nat → Nat → Expr → Parser Expr
    | 0,_,_,_ => none
    | fuel+1,minimum,left,ts =>
      match ts with
      | token::rest =>
        match operator token with
        | some (precedence,combine) =>
          if minimum≤precedence then do
            let (right,rest) ← expression fuel (precedence+1) rest
            climb fuel minimum (combine left right) rest
          else some (left,ts)
        | none => some (left,ts)
      | [] => some (left,[])
end
mutual
  def statement : Nat → Parser Stmt
    | 0,_ => none
    | _fuel+1,"const"::kind::rest => do
      let (name,rest) ← nameToken rest
      let rest ← accept "=" rest
      let (value,rest) ← expression 256 0 rest
      let rest ← accept ";" rest
      if kind="int" then some (.constInt name value,rest)
      else if kind="uint" then some (.constUInt name value,rest) else none
    | _+1,"uint"::rest => do
      let (name,rest) ← nameToken rest
      let rest ← accept ";" rest
      pure (.declareUInt name,rest)
    | fuel+1,"if"::"("::rest => do
      let (test,rest) ← expression 256 0 rest
      let rest ← accept ")" rest
      let (yes,rest) ← statement fuel rest
      let rest ← accept "else" rest
      let (no,rest) ← branch fuel rest
      pure (.ifElse test [yes] no,rest)
    | _+1,"return"::rest => do
      let rest ← accept "*" rest
      let rest ← accept "(" rest
      let rest ← accept "const" rest
      let rest ← accept "threadgroup" rest
      let rest ← accept "float" rest
      let rest ← accept "*" rest
      let rest ← accept ")" rest
      let rest ← accept "(" rest
      let (base,rest) ← nameToken rest
      let rest ← accept "+" rest
      let (offset,rest) ← expression 256 0 rest
      let rest ← accept ")" rest
      let rest ← accept ";" rest
      pure (.returnTable base offset,rest)
    | _+1,ts => do
      let (name,rest) ← nameToken ts
      let rest ← accept "=" rest
      let (value,rest) ← expression 256 0 rest
      let rest ← accept ";" rest
      pure (.assignUInt name value,rest)
  def branch : Nat → Parser (List Stmt)
    | 0,_ => none
    | fuel+1,"{"::rest => statements fuel rest
    | fuel+1,rest => do
      let (value,rest) ← statement fuel rest
      pure ([value],rest)
  def statements : Nat → Parser (List Stmt)
    | 0,_ => none
    | _+1,"}"::rest => some ([],rest)
    | fuel+1,ts => do
      let (value,rest) ← statement fuel ts
      let (tail,rest) ← statements fuel rest
      pure (value::tail,rest)
end

def bodyTokens : Parser (List Stmt) := fun ts => do
  let ts ← accept "{" ts
  statements 256 ts

def parse (source : String) : Option (List Stmt) := do
  let ts ← tokenize source
  let (body,rest) ← bodyTokens ts
  if rest=[] then some body else none

def sourceBody : String := r#"{
  const int f = int(off) - 2;
  const uint mask = (1u << (l + 2u)) - 1u;
  uint bits;
  if (f >= 0 && uint(f & 31) + l + 2u <= 32u) bits = (w[f >> 5] >> uint(f & 31)) & mask;
  else { const uint vi = uint(f + 16) >> 5; bits = (v[vi] >> uint(f + 16 - 32 * int(vi))) & mask; }
  return *(const threadgroup float*)(table + bits);
}"#
open Expr in
def body : List Stmt := [
  .constInt "f" (subtract (castInt (Expr.variable "off")) (Expr.literal .signed 2)),
  .constUInt "mask" (subtract (shiftLeft (Expr.literal .unsigned 1) (add (Expr.variable "l") (Expr.literal .unsigned 2))) (Expr.literal .unsigned 1)),
  .declareUInt "bits",
  .ifElse (logicalAnd (ge (Expr.variable "f") (Expr.literal .signed 0))
    (le (add (add (castUInt (bitAnd (Expr.variable "f") (Expr.literal .signed 31))) (Expr.variable "l")) (Expr.literal .unsigned 2)) (Expr.literal .unsigned 32)))
    [.assignUInt "bits" (bitAnd (shiftRight (index "w" (shiftRight (Expr.variable "f") (Expr.literal .signed 5)))
      (castUInt (bitAnd (Expr.variable "f") (Expr.literal .signed 31)))) (Expr.variable "mask"))]
    [.constUInt "vi" (shiftRight (castUInt (add (Expr.variable "f") (Expr.literal .signed 16))) (Expr.literal .signed 5)),
     .assignUInt "bits" (bitAnd (shiftRight (index "v" (Expr.variable "vi"))
       (castUInt (subtract (add (Expr.variable "f") (Expr.literal .signed 16))
         (multiply (Expr.literal .signed 32) (castInt (Expr.variable "vi")))))) (Expr.variable "mask"))],
  .returnTable "table" (Expr.variable "bits")]

def sourceTokens : Tokens := ["{","const","int","f","=","int","(","off",")","-","2",";","const","uint","mask","=","(","1u","<<","(","l","+","2u",")",")","-","1u",";","uint","bits",";","if","(","f",">=","0","&&","uint","(","f","&","31",")","+","l","+","2u","<=","32u",")","bits","=","(","w","[","f",">>","5","]",">>","uint","(","f","&","31",")",")","&","mask",";","else","{","const","uint","vi","=","uint","(","f","+","16",")",">>","5",";","bits","=","(","v","[","vi","]",">>","uint","(","f","+","16","-","32","*","int","(","vi",")",")",")","&","mask",";","}","return","*","(","const","threadgroup","float","*",")","(","table","+","bits",")",";","}"]
theorem tokenized_body : tokenize sourceBody=some sourceTokens := by decide +kernel
theorem parsed_body : parse sourceBody=some body := by
  unfold parse
  rw [tokenized_body]
  rfl
theorem consumes (source : String) (actual : List Stmt) (parsed : parse source=some actual) :
    ∃ ts, tokenize source=some ts ∧ bodyTokens ts=some (actual,[]) := by
  change ((tokenize source).bind (fun ts => (bodyTokens ts).bind (fun result =>
    if result.2=[] then some result.1 else none)))=some actual at parsed
  obtain ⟨ts,lexed,parsed⟩ := Option.bind_eq_some_iff.mp parsed
  obtain ⟨⟨code,rest⟩,parsedTokens,parsed⟩ := Option.bind_eq_some_iff.mp parsed
  by_cases empty : rest=[]
  · subst rest
    simp only [ite_true] at parsed
    have same := Option.some.inj parsed
    subst code
    exact ⟨ts,lexed,parsedTokens⟩
  · simp only [empty,ite_false] at parsed
    contradiction
end Inference.Kernels.Trellis.CodebookWindowSyntax

import kernels.copy.ScalarCopySyntax

namespace Inference.Kernels.Trellis.CodebookIntegerSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken wordChar decimal)
set_option maxRecDepth 10000

-- Restricted actual Metal source subset: identifiers, decimal/hex literals,
-- unsigned suffixes, parentheses, int casts, +,-,*,&,>> and uint declarations.
-- Parsing retains identifiers, literal values/types and actual operator order.
inductive LiteralKind where
  | signed | unsigned
  deriving DecidableEq, Repr

inductive Expr where
  | variable : String → Expr
  | literal : LiteralKind → Nat → Expr
  | add : Expr → Expr → Expr
  | subtract : Expr → Expr → Expr
  | multiply : Expr → Expr → Expr
  | bitAnd : Expr → Expr → Expr
  | shiftRight : Expr → Expr → Expr
  | castInt : Expr → Expr
  deriving DecidableEq, Repr

inductive Stmt where
  | constantUInt : String → Expr → Stmt
  | returnValue : Expr → Stmt
  deriving DecidableEq, Repr

def lexAux : Nat → List Char → Option Tokens
  | 0, _ => none
  | _+1, [] => some []
  | fuel+1, c::rest =>
      if c.isWhitespace then lexAux fuel rest
      else if wordChar c then do
        let token := String.ofList (c::rest.takeWhile wordChar)
        let tail ← lexAux fuel (rest.dropWhile wordChar)
        pure (token::tail)
      else if c='>' then
        match rest with
        | '>'::tail => do pure (">>"::(← lexAux fuel tail))
        | _ => none
      else if ['{','}','(',')',';','=','+','-','*','&'].contains c then do
        pure (String.singleton c::(← lexAux fuel rest))
      else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

def hexDigit (c : Char) : Option Nat :=
  if '0'≤c ∧ c≤ '9' then some (c.toNat-'0'.toNat)
  else if 'a'≤c ∧ c≤ 'f' then some (c.toNat-'a'.toNat+10)
  else if 'A'≤c ∧ c≤ 'F' then some (c.toNat-'A'.toNat+10)
  else none

def hex (digits : List Char) : Option Nat :=
  if digits=[] then none else digits.foldlM (fun value c => do pure (value*16+(←hexDigit c))) 0

def literal (token : String) : Option Expr := do
  let chars := token.toList
  let unsigned := chars.getLast?=some 'u' ∨ chars.getLast?=some 'U'
  let digits := if unsigned then chars.dropLast else chars
  let value ← match digits with
    | '0'::'x'::rest | '0'::'X'::rest => if unsigned then hex rest else none
    | _ => decimal (String.ofList digits)
  pure (.literal (if unsigned then .unsigned else .signed) value)

def operator (token : String) : Option (Nat × (Expr → Expr → Expr)) :=
  match token with
  | "&" => some (1,Expr.bitAnd)
  | ">>" => some (2,Expr.shiftRight)
  | "+" => some (3,Expr.add)
  | "-" => some (3,Expr.subtract)
  | "*" => some (4,Expr.multiply)
  | _ => none

mutual
  def expression : Nat → Nat → Parser Expr
    | 0, _, _ => none
    | fuel+1, minimum, tokens => do
        let (left,rest) ← primary fuel tokens
        climb fuel minimum left rest
  def primary : Nat → Parser Expr
    | 0, _ => none
    | fuel+1, "("::"int"::")"::rest => do
        let (value,rest) ← primary fuel rest
        pure (.castInt value,rest)
    | fuel+1, "("::rest => do
        let (value,rest) ← expression fuel 0 rest
        let rest ← accept ")" rest
        pure (value,rest)
    | _+1, token::rest =>
        match literal token with
        | some value => some (value,rest)
        | none => do
            let (name,rest) ← nameToken (token::rest)
            pure (.variable name,rest)
    | _+1, [] => none
  def climb : Nat → Nat → Expr → Parser Expr
    | 0, _, _, _ => none
    | fuel+1, minimum, left, tokens =>
        match tokens with
        | token::rest =>
            match operator token with
            | some (precedence,combine) =>
                if minimum≤precedence then do
                  let (right,rest) ← expression fuel (precedence+1) rest
                  climb fuel minimum (combine left right) rest
                else some (left,tokens)
            | none => some (left,tokens)
        | [] => some (left,[])
end

def statement : Parser Stmt
  | "const"::"uint"::rest => do
      let (name,rest) ← nameToken rest
      let rest ← accept "=" rest
      let (value,rest) ← expression 256 0 rest
      let rest ← accept ";" rest
      pure (.constantUInt name value,rest)
  | "return"::rest => do
      let (value,rest) ← expression 256 0 rest
      let rest ← accept ";" rest
      pure (.returnValue value,rest)
  | _ => none

def statements : Nat → Parser (List Stmt)
  | 0, _ => none
  | _+1, "}"::rest => some ([],rest)
  | fuel+1, tokens => do
      let (first,rest) ← statement tokens
      let (tail,rest) ← statements fuel rest
      pure (first::tail,rest)

def bodyTokens : Parser (List Stmt) := fun tokens => do
  let rest ← accept "{" tokens
  statements 256 rest

def parseBody (source : String) : Option (List Stmt) := do
  let tokens ← tokenize source
  let (body,rest) ← bodyTokens tokens
  if rest=[] then some body else none

def sourceBody : String := r#"{
  const uint x = s * 34038481u + 76625530u;
  const uint p = (x & 0x00FF00FFu) + ((x >> 8) & 0x00FF00FFu);
  return (int)((p & 0xFFFFu) + (p >> 16)) - 510;
}"#

def body : List Stmt := [
  .constantUInt "x" (.add (.multiply (.variable "s") (.literal .unsigned 34038481)) (.literal .unsigned 76625530)),
  .constantUInt "p" (.add (.bitAnd (.variable "x") (.literal .unsigned 16711935))
    (.bitAnd (.shiftRight (.variable "x") (.literal .signed 8)) (.literal .unsigned 16711935))),
  .returnValue (.subtract (.castInt (.add (.bitAnd (.variable "p") (.literal .unsigned 65535))
    (.shiftRight (.variable "p") (.literal .signed 16)))) (.literal .signed 510))]

theorem parsed_body : parseBody sourceBody=some body := by decide +kernel

theorem consumes (source : String) (actual : List Stmt) (parsed : parseBody source=some actual) :
    ∃ tokens, tokenize source=some tokens ∧ bodyTokens tokens=some (actual,[]) := by
  change ((tokenize source).bind (fun tokens => (bodyTokens tokens).bind (fun result =>
    if result.2=[] then some result.1 else none)))=some actual at parsed
  obtain ⟨tokens,lexed,parsed⟩ := Option.bind_eq_some_iff.mp parsed
  obtain ⟨⟨body,rest⟩,parsedTokens,parsed⟩ := Option.bind_eq_some_iff.mp parsed
  by_cases empty : rest=[]
  · subst rest
    simp only [ite_true] at parsed
    have same := Option.some.inj parsed
    subst body
    exact ⟨tokens,lexed,parsedTokens⟩
  · simp only [empty,ite_false] at parsed
    contradiction

end Inference.Kernels.Trellis.CodebookIntegerSyntax

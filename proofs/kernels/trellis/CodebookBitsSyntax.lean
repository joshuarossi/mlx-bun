import kernels.trellis.CodebookIntegerSyntax

namespace Inference.Kernels.Trellis.CodebookBitsSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken wordChar decimal)
open CodebookIntegerSyntax (hex)
set_option maxRecDepth 10000

-- Restricted expression grammar for the actual helper. Decimal f literals are
-- retained as exact decimal mantissa/scale, not host floating values.
inductive Expr where
  | variable : String → Expr
  | integer : Bool → Nat → Expr
  | floating : Nat → Nat → Expr
  | add : Expr → Expr → Expr
  | subtract : Expr → Expr → Expr
  | multiply : Expr → Expr → Expr
  | divide : Expr → Expr → Expr
  | bitOr : Expr → Expr → Expr
  | toUInt : Expr → Expr
  | reinterpretFloat : Expr → Expr
  deriving DecidableEq, Repr
inductive Stmt where
  | constantFloat : String → Expr → Stmt
  | returnValue : Expr → Stmt
  deriving DecidableEq, Repr

def lexAux : Nat → List Char → Option Tokens
  | 0, _ => none
  | _+1, [] => some []
  | fuel+1, c::rest =>
      if c.isWhitespace then lexAux fuel rest
      else if wordChar c ∨ c='.' then do
        let part := fun c => wordChar c ∨ c='.'
        let tail ← lexAux fuel (rest.dropWhile part)
        pure (String.ofList (c::rest.takeWhile part)::tail)
      else if ['{','}','(',')',';','=','+','-','*','/','|','<','>'].contains c then do
        pure (String.singleton c::(←lexAux fuel rest))
      else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

def literal (token : String) : Option Expr := do
  let chars := token.toList
  if chars.getLast?=some 'f' then
    let digits := chars.dropLast
    let whole := digits.takeWhile (· != '.')
    let rest := digits.dropWhile (· != '.')
    let fraction ← match rest with | '.'::tail => some tail | _ => none
    let a ← decimal (String.ofList whole)
    let b ← decimal (String.ofList fraction)
    pure (.floating (a*10^fraction.length+b) fraction.length)
  else if chars.getLast?=some 'u' then
    let digits := chars.dropLast
    let n ← match digits with
      | '0'::'x'::tail => hex tail
      | _ => decimal (String.ofList digits)
    pure (.integer true n)
  else do pure (.integer false (←decimal token))

def operator : String → Option (Nat × (Expr → Expr → Expr))
  | "|" => some (1,Expr.bitOr)
  | "+" => some (2,Expr.add)
  | "-" => some (2,Expr.subtract)
  | "*" => some (3,Expr.multiply)
  | "/" => some (3,Expr.divide)
  | _ => none
mutual
  def expression : Nat → Nat → Parser Expr
    | 0, _, _ => none
    | fuel+1, minimum, tokens => do
        let (left,rest) ← primary fuel tokens
        climb fuel minimum left rest
  def primary : Nat → Parser Expr
    | 0, _ => none
    | fuel+1, "as_type"::"<"::"float"::">"::"("::rest => do
        let (value,rest) ← expression fuel 0 rest
        let rest ← accept ")" rest
        pure (.reinterpretFloat value,rest)
    | fuel+1, "uint"::"("::rest => do
        let (value,rest) ← expression fuel 0 rest
        let rest ← accept ")" rest
        pure (.toUInt value,rest)
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
  | "const"::"float"::rest => do
      let (name,rest) ← nameToken rest
      let rest ← accept "=" rest
      let (value,rest) ← expression 256 0 rest
      let rest ← accept ";" rest
      pure (.constantFloat name value,rest)
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
  const float lifted = as_type<float>(0x4b000000u | uint(y + 510));
  return (lifted - 8389118.0f) * (1.0f / 147.800537109375f);
}"#
def liftExpression : Expr := .reinterpretFloat (.bitOr (.integer true 1258291200)
  (.toUInt (.add (.variable "y") (.integer false 510))))
def resultExpression : Expr := .multiply (.subtract (.variable "lifted") (.floating 83891180 1))
  (.divide (.floating 10 1) (.floating 147800537109375 12))
def body : List Stmt := [.constantFloat "lifted" liftExpression,.returnValue resultExpression]
def sourceTokens : Tokens := ["{","const","float","lifted","=","as_type","<","float",">","(","0x4b000000u","|","uint","(","y","+","510",")",")",";","return","(","lifted","-","8389118.0f",")","*","(","1.0f","/","147.800537109375f",")",";","}"]
theorem tokenized : tokenize sourceBody=some sourceTokens := by decide +kernel
theorem tokens_parsed : bodyTokens sourceTokens=some (body,[]) := by decide +kernel
theorem parsed_body : parseBody sourceBody=some body := by
  simp only [parseBody,tokenized]
  rfl

theorem consumes (source : String) (actual : List Stmt) (parsed : parseBody source=some actual) :
    ∃ tokens, tokenize source=some tokens ∧ bodyTokens tokens=some (actual,[]) := by
  change ((tokenize source).bind (fun tokens => (bodyTokens tokens).bind (fun result =>
    if result.2=[] then some result.1 else none)))=some actual at parsed
  cases ht : tokenize source with
  | none => simp [ht] at parsed
  | some tokens =>
    cases hb : bodyTokens tokens with
    | none => simp [ht,hb] at parsed
    | some result =>
      rcases result with ⟨value,rest⟩
      by_cases hr : rest=[]
      · subst rest
        simp [ht,hb] at parsed
        subst actual
        exact ⟨tokens,rfl,hb⟩
      · simp [ht,hb,hr] at parsed
end Inference.Kernels.Trellis.CodebookBitsSyntax

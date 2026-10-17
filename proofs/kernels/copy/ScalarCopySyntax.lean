import Std

namespace Inference.Kernels.Copy.ScalarCopySyntax
set_option maxRecDepth 10000

-- This syntax describes only the copy_s body. Template parameters, kernel
-- attributes, argument bindings, and the Metal compiler are outside its scope.
inductive Expr where
  | var : String → Expr
  | nat : Nat → Expr
  | add : Expr → Expr → Expr
  | mul : Expr → Expr → Expr
  | lt : Expr → Expr → Expr
  | gt : Expr → Expr → Expr
  | land : Expr → Expr → Expr
  | index : String → Expr → Expr
  | cast : String → Expr → Expr
  deriving DecidableEq, Repr

inductive Stmt where
  | mulAssign : String → Expr → Stmt
  | assign : Expr → Expr → Stmt
  | ifElse : Expr → List Stmt → List Stmt → Stmt
  -- Signed int induction variable, initializer, condition, prefix increment.
  | forLoop : String → Expr → Expr → List Stmt → Stmt
  deriving Repr

abbrev Tokens := List String

def wordChar (c : Char) : Bool := c.isAlphanum || c == '_'
def identifier (token : String) : Bool :=
  match token.toList with
  | [] => false
  | head::tail => (head.isAlpha || head == '_') && tail.all wordChar

def decimalAux : List Char → Nat → Option Nat
  | [], accumulated => some accumulated
  | digit::rest, accumulated =>
    if '0'.toNat≤digit.toNat ∧ digit.toNat≤'9'.toNat then
      decimalAux rest (10*accumulated+(digit.toNat-'0'.toNat))
    else none

def decimal (token : String) : Option Nat :=
  if token.isEmpty then none else decimalAux token.toList 0

def lexAux : Nat → List Char → Option Tokens
  | 0, _ => none
  | _+1, [] => some []
  | fuel+1, c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c then do
      let word := String.ofList (c::rest.takeWhile wordChar)
      let tail ← lexAux fuel (rest.dropWhile wordChar)
      pure (word::tail)
    else match c,rest with
      | '*','='::rest => do
        let tail ← lexAux fuel rest
        pure ("*="::tail)
      | '+','+'::rest => do
        let tail ← lexAux fuel rest
        pure ("++"::tail)
      | '&','&'::rest => do
        let tail ← lexAux fuel rest
        pure ("&&"::tail)
      | _,_ =>
        if ['{','}','(',')','[',']',';','+','*','=','<','>'].contains c then do
          let tail ← lexAux fuel rest
          pure (String.singleton c::tail)
        else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

def accept (expected : String) : Tokens → Option Tokens
  | found::rest => if found=expected then some rest else none
  | [] => none

def nameToken : Tokens → Option (String × Tokens)
  | token::rest => if identifier token then some (token,rest) else none
  | [] => none

-- A deliberately restricted grammar: multiply assignment followed by an if,
-- with one signed-int for loop and one indexed assignment in each branch.
-- Identifiers, literals, operands, and cast type names are parsed from tokens.
-- This accepts no general C++ declarations or arbitrary nested statements.
abbrev Parser (α : Type) := Tokens → Option (α × Tokens)

def variableExpr : Parser Expr := fun tokens => do
  let (name,rest) ← nameToken tokens
  pure (.var name,rest)

def naturalExpr : Parser Expr
  | token::rest => do
    let value ← decimal token
    pure (.nat value,rest)
  | [] => none

def binary (left : Parser Expr) (symbol : String) (right : Parser Expr)
    (combine : Expr → Expr → Expr) : Parser Expr := fun tokens => do
  let (first,rest) ← left tokens
  let rest ← accept symbol rest
  let (second,rest) ← right rest
  pure (combine first second,rest)

def sumExpr : Parser Expr := binary variableExpr "+" variableExpr Expr.add

def indexed (indexParser : Parser Expr) : Parser Expr := fun tokens => do
  let (name,rest) ← nameToken tokens
  let rest ← accept "[" rest
  let (index,rest) ← indexParser rest
  let rest ← accept "]" rest
  pure (.index name index,rest)

def castExpr : Parser Expr := fun tokens => do
  let rest ← accept "cast_to" tokens
  let rest ← accept "<" rest
  let (typeName,rest) ← nameToken rest
  let rest ← accept ">" rest
  let rest ← accept "(" rest
  let (value,rest) ← indexed naturalExpr rest
  let rest ← accept ")" rest
  pure (.cast typeName value,rest)

def storeStatement : Parser Stmt := fun tokens => do
  let (target,rest) ← indexed sumExpr tokens
  let rest ← accept "=" rest
  let (value,rest) ← castExpr rest
  let rest ← accept ";" rest
  pure (.assign target value,rest)

def loop (conditionParser : Parser Expr) : Parser Stmt := fun tokens => do
  let rest ← accept "for" tokens
  let rest ← accept "(" rest
  let rest ← accept "int" rest
  let (loopName,rest) ← nameToken rest
  let rest ← accept "=" rest
  let (initial,rest) ← naturalExpr rest
  let rest ← accept ";" rest
  let (condition,rest) ← conditionParser rest
  let rest ← accept ";" rest
  let rest ← accept "++" rest
  let (incremented,rest) ← nameToken rest
  if incremented≠loopName then none else do
    let rest ← accept ")" rest
    let rest ← accept "{" rest
    let (store,rest) ← storeStatement rest
    let rest ← accept "}" rest
    pure (.forLoop loopName initial condition [store],rest)

def condition : Parser Expr := fun tokens => do
  let (first,rest) ← binary variableExpr ">" naturalExpr Expr.gt tokens
  let rest ← accept "&&" rest
  let (second,rest) ← binary sumExpr ">" variableExpr Expr.gt rest
  pure (.land first second,rest)

def conditional : Parser Stmt := fun tokens => do
  let rest ← accept "if" tokens
  let rest ← accept "(" rest
  let (test,rest) ← condition rest
  let rest ← accept ")" rest
  let rest ← accept "{" rest
  let (yes,rest) ← loop (binary sumExpr "<" variableExpr Expr.lt) rest
  let rest ← accept "}" rest
  let rest ← accept "else" rest
  let rest ← accept "{" rest
  let (no,rest) ← loop (binary variableExpr "<" variableExpr Expr.lt) rest
  let rest ← accept "}" rest
  pure (.ifElse test [yes] [no],rest)

def block : Parser (List Stmt) := fun tokens => do
  let rest ← accept "{" tokens
  let (name,rest) ← nameToken rest
  let rest ← accept "*=" rest
  let (factor,rest) ← variableExpr rest
  let rest ← accept ";" rest
  let (branch,rest) ← conditional rest
  let rest ← accept "}" rest
  pure ([.mulAssign name factor,branch],rest)

def parseBody (source : String) : Option (List Stmt) := do
  let tokens ← tokenize source
  let (body,remaining) ← block tokens
  if remaining=[] then some body else none

-- Exact raw bytes from the opening brace to the closing brace in pinned
-- mlx/backend/metal/kernels/copy.h:8-19. The separate source-binding check
-- compares this literal with that body; this theorem itself parses the literal.
def sourceBody : String := r#"{
  index *= N;
  if (N > 1 && index + N > size) {
    for (int i = 0; index + i < size; ++i) {
      dst[index + i] = cast_to<U>(src[0]);
    }
  } else {
    for (int i = 0; i < N; ++i) {
      dst[index + i] = cast_to<U>(src[0]);
    }
  }
}"#

def write : Stmt := .assign (.index "dst" (.add (.var "index") (.var "i")))
  (.cast "U" (.index "src" (.nat 0)))

def body : List Stmt := [
  .mulAssign "index" (.var "N"),
  .ifElse (.land (.gt (.var "N") (.nat 1)) (.gt (.add (.var "index") (.var "N")) (.var "size")))
    [.forLoop "i" (.nat 0) (.lt (.add (.var "index") (.var "i")) (.var "size")) [write]]
    [.forLoop "i" (.nat 0) (.lt (.var "i") (.var "N")) [write]]]

def sourceTokens : Tokens := ["{","index","*=","N",";","if","(","N",">","1","&&","index","+","N",">","size",")","{","for","(","int","i","=","0",";","index","+","i","<","size",";","++","i",")","{","dst","[","index","+","i","]","=","cast_to","<","U",">","(","src","[","0","]",")",";","}","}","else","{","for","(","int","i","=","0",";","i","<","N",";","++","i",")","{","dst","[","index","+","i","]","=","cast_to","<","U",">","(","src","[","0","]",")",";","}","}","}"]

theorem tokenized_body : tokenize sourceBody=some sourceTokens := by decide

theorem parsed_body : parseBody sourceBody=some body := by
  unfold parseBody
  rw [tokenized_body]
  have zero : decimal "0"=some 0 := by decide
  have one : decimal "1"=some 1 := by decide
  simp [zero,one,block,conditional,condition,loop,storeStatement,castExpr,indexed,binary,sumExpr,variableExpr,naturalExpr,nameToken,identifier,wordChar,accept,sourceTokens,body,write]

-- Successful parsing requires complete consumption, rather than accepting an
-- arbitrary prefix followed by unparsed source tokens.
theorem parseBody_consumes {source : String} {body : List Stmt} (parsed : parseBody source=some body) :
    ∃ tokens, tokenize source=some tokens ∧ block tokens=some (body,[]) := by
  change ((tokenize source).bind (fun tokens => (block tokens).bind (fun result =>
    if result.2=[] then some result.1 else none)))=some body at parsed
  obtain ⟨tokens,lexed,parsed⟩ := Option.bind_eq_some_iff.mp parsed
  obtain ⟨⟨actual,remaining⟩,blocked,parsed⟩ := Option.bind_eq_some_iff.mp parsed
  by_cases empty : remaining=[]
  · subst remaining
    simp only [ite_true] at parsed
    have same : actual=body := Option.some.inj parsed
    subst actual
    exact ⟨tokens,lexed,blocked⟩
  · simp only [empty,ite_false] at parsed
    contradiction

end Inference.Kernels.Copy.ScalarCopySyntax

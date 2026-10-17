import kernels.copy.ScalarCopySyntax

namespace Inference.Kernels.Binary.BinaryVvSyntax
open Copy.ScalarCopySyntax (Expr Tokens Parser wordChar accept nameToken variableExpr naturalExpr indexed binary sumExpr decimal identifier)
set_option maxRecDepth 10000
-- Complete restricted binary_vv BODY parsing. Signature/template/dispatch/compiler
-- are outside the frontend; the separate host byte check binds the raw literal.

inductive Stmt where
  | mulAssign : String → Expr → Stmt
  | store : Expr → String → Expr → Expr → Stmt
  | ifElse : Expr → List Stmt → List Stmt → Stmt
  | forLoop : String → Expr → Expr → List Stmt → Stmt
  deriving Repr

def storeStatement : Parser Stmt := fun tokens => do
  let (target,rest) ← indexed sumExpr tokens
  let rest ← accept "=" rest
  let (op,rest) ← nameToken rest
  let rest ← accept "(" rest
  let rest ← accept ")" rest
  let rest ← accept "(" rest
  let (left,rest) ← indexed sumExpr rest
  let rest ← accept "," rest
  let (right,rest) ← indexed sumExpr rest
  let rest ← accept ")" rest
  let rest ← accept ";" rest
  pure (.store target op left right,rest)

-- The common lexer already treats *=, ++ and && as indivisible tokens.
-- A comma is added for the actual binary helper call argument separator.
def lexAux : Nat → List Char → Option Tokens
  | 0, _ => none
  | _+1, [] => some []
  | fuel+1, c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c then do
      let tail ← lexAux fuel (rest.dropWhile wordChar)
      pure (String.ofList (c::rest.takeWhile wordChar)::tail)
    else match c,rest with
      | '*','='::rest => do pure ("*="::(←lexAux fuel rest))
      | '+','+'::rest => do pure ("++"::(←lexAux fuel rest))
      | '&','&'::rest => do pure ("&&"::(←lexAux fuel rest))
      | _,_ => if ['{','}','(',')','[',']',';','+','*','=','<','>',','].contains c then do
          pure (String.singleton c::(←lexAux fuel rest))
        else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

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

def sourceBody : String := r#"{
  index *= N;
  if (N > 1 && index + N > size) {
    for (int i = 0; index + i < size; ++i) {
      c[index + i] = Op()(a[index + i], b[index + i]);
    }
  } else {
    for (int i = 0; i < N; ++i) {
      c[index + i] = Op()(a[index + i], b[index + i]);
    }
  }
}"#

def write : Stmt := .store (.index "c" (.add (.var "index") (.var "i"))) "Op"
  (.index "a" (.add (.var "index") (.var "i")))
  (.index "b" (.add (.var "index") (.var "i")))

def body : List Stmt := [
  .mulAssign "index" (.var "N"),
  .ifElse (.land (.gt (.var "N") (.nat 1)) (.gt (.add (.var "index") (.var "N")) (.var "size")))
    [.forLoop "i" (.nat 0) (.lt (.add (.var "index") (.var "i")) (.var "size")) [write]]
    [.forLoop "i" (.nat 0) (.lt (.var "i") (.var "N")) [write]]]

def sourceTokens : Tokens := ["{","index","*=","N",";","if","(","N",">","1","&&","index","+","N",">","size",")","{","for","(","int","i","=","0",";","index","+","i","<","size",";","++","i",")","{","c","[","index","+","i","]","=","Op","(",")","(","a","[","index","+","i","]",",","b","[","index","+","i","]",")",";","}","}","else","{","for","(","int","i","=","0",";","i","<","N",";","++","i",")","{","c","[","index","+","i","]","=","Op","(",")","(","a","[","index","+","i","]",",","b","[","index","+","i","]",")",";","}","}","}"]

theorem tokenized_body : tokenize sourceBody=some sourceTokens := by decide

theorem parsed_body : parseBody sourceBody=some body := by
  unfold parseBody
  rw [tokenized_body]
  have zero : decimal "0"=some 0 := by decide
  have one : decimal "1"=some 1 := by decide
  simp [zero,one,block,conditional,condition,loop,storeStatement,indexed,binary,sumExpr,variableExpr,naturalExpr,nameToken,identifier,wordChar,accept,sourceTokens,body,write]

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

end Inference.Kernels.Binary.BinaryVvSyntax

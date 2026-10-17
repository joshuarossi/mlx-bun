import kernels.copy.ScalarCopySyntax

namespace Inference.Kernels.Copy.GeneralCopy2DSyntax
open ScalarCopySyntax (Tokens Parser accept nameToken decimal identifier wordChar)
set_option maxRecDepth 10000

-- Restricted syntax for copy_gg_nd2 and its elem_to_loc_2 helper. Names,
-- fields, cast types and subscript constants are retained by the parser.
inductive Expr where
  | var : String → Expr
  | nat : Nat → Expr
  | field : String → String → Expr
  | index : String → Expr → Expr
  | cast : String → Expr → Expr
  | add : Expr → Expr → Expr
  | mul : Expr → Expr → Expr
  | call2 : String → String → String → String → Expr
  deriving DecidableEq, Repr

inductive Stmt where
  | declare : String → Expr → Stmt
  | store : Expr → Expr → Stmt
  deriving DecidableEq, Repr

def lexAux : Nat → List Char → Option Tokens
  | 0, _ => none
  | _+1, [] => some []
  | fuel+1, c::rest =>
      if c.isWhitespace then lexAux fuel rest
      else if wordChar c then do
        let word := String.ofList (c::rest.takeWhile wordChar)
        let tail ← lexAux fuel (rest.dropWhile wordChar)
        pure (word::tail)
      else if ['{','}','(',')','[',']',';','+','*','=','<','>',',','.'].contains c then do
        let tail ← lexAux fuel rest
        pure (String.singleton c::tail)
      else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

def variableExpr : Parser Expr := fun tokens => do
  let (name,rest) ← nameToken tokens
  pure (.var name,rest)

def natural : Parser Expr
  | token::rest => do
      let value ← decimal token
      pure (.nat value,rest)
  | [] => none

def indexed (element : Parser Expr) : Parser Expr := fun tokens => do
  let (name,rest) ← nameToken tokens
  let rest ← accept "[" rest
  let (index,rest) ← element rest
  let rest ← accept "]" rest
  pure (.index name index,rest)

def field : Parser Expr := fun tokens => do
  let (name,rest) ← nameToken tokens
  let rest ← accept "." rest
  let (member,rest) ← nameToken rest
  pure (.field name member,rest)

def castIndexed : Parser Expr := fun tokens => do
  let (typeName,rest) ← nameToken tokens
  let rest ← accept "(" rest
  let (element,rest) ← indexed natural rest
  let rest ← accept ")" rest
  pure (.cast typeName element,rest)

def product : Parser Expr := fun tokens => do
  let (left,rest) ← field tokens
  let rest ← accept "*" rest
  let (right,rest) ← castIndexed rest
  pure (.mul left right,rest)

def sum : Parser Expr := fun tokens => do
  let (left,rest) ← product tokens
  let rest ← accept "+" rest
  let (right,rest) ← product rest
  pure (.add left right,rest)

def helperCall : Parser Expr := fun tokens => do
  let (functionName,rest) ← nameToken tokens
  let rest ← accept "<" rest
  let (typeName,rest) ← nameToken rest
  let rest ← accept ">" rest
  let rest ← accept "(" rest
  let (indexName,rest) ← nameToken rest
  let rest ← accept "," rest
  let (stridesName,rest) ← nameToken rest
  let rest ← accept ")" rest
  pure (.call2 functionName typeName indexName stridesName,rest)

def declaration : Parser Stmt := fun tokens => do
  let rest ← accept "auto" tokens
  let (name,rest) ← nameToken rest
  let rest ← accept "=" rest
  let (value,rest) ← helperCall rest
  let rest ← accept ";" rest
  pure (.declare name value,rest)

def castLoad : Parser Expr := fun tokens => do
  let rest ← accept "cast_to" tokens
  let rest ← accept "<" rest
  let (typeName,rest) ← nameToken rest
  let rest ← accept ">" rest
  let rest ← accept "(" rest
  let (value,rest) ← indexed variableExpr rest
  let rest ← accept ")" rest
  pure (.cast typeName value,rest)

def store : Parser Stmt := fun tokens => do
  let (target,rest) ← indexed variableExpr tokens
  let rest ← accept "=" rest
  let (value,rest) ← castLoad rest
  let rest ← accept ";" rest
  pure (.store target value,rest)

def bodyTokens : Parser (List Stmt) := fun tokens => do
  let rest ← accept "{" tokens
  let (source,rest) ← declaration rest
  let (destination,rest) ← declaration rest
  let (write,rest) ← store rest
  let rest ← accept "}" rest
  pure ([source,destination,write],rest)

def helperTokens : Parser Expr := fun tokens => do
  let rest ← accept "{" tokens
  let rest ← accept "return" rest
  let (value,rest) ← sum rest
  let rest ← accept ";" rest
  let rest ← accept "}" rest
  pure (value,rest)

def parseBody (source : String) : Option (List Stmt) := do
  let tokens ← tokenize source
  let (body,rest) ← bodyTokens tokens
  if rest=[] then pure body else none

def parseHelper (source : String) : Option Expr := do
  let tokens ← tokenize source
  let (value,rest) ← helperTokens tokens
  if rest=[] then pure value else none

def sourceBody : String := r#"{
  auto src_idx = elem_to_loc_2<IdxT>(index, src_strides);
  auto dst_idx = elem_to_loc_2<IdxT>(index, dst_strides);
  dst[dst_idx] = cast_to<U>(src[src_idx]);
}"#

def helperBody : String := r#"{
  return elem.x * IdxT(strides[1]) + elem.y * IdxT(strides[0]);
}"#

def body : List Stmt := [
  .declare "src_idx" (.call2 "elem_to_loc_2" "IdxT" "index" "src_strides"),
  .declare "dst_idx" (.call2 "elem_to_loc_2" "IdxT" "index" "dst_strides"),
  .store (.index "dst" (.var "dst_idx")) (.cast "U" (.index "src" (.var "src_idx")))]

def helper : Expr :=
  .add (.mul (.field "elem" "x") (.cast "IdxT" (.index "strides" (.nat 1))))
    (.mul (.field "elem" "y") (.cast "IdxT" (.index "strides" (.nat 0))))

theorem parsed_body : parseBody sourceBody=some body := by decide +kernel
theorem parsed_helper : parseHelper helperBody=some helper := by decide +kernel

theorem body_consumes (source : String) (body : List Stmt) (parsed : parseBody source=some body) :
    ∃ tokens, tokenize source=some tokens ∧ bodyTokens tokens=some (body,[]) := by
  change ((tokenize source).bind (fun tokens => (bodyTokens tokens).bind (fun result =>
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

theorem helper_consumes (source : String) (value : Expr) (parsed : parseHelper source=some value) :
    ∃ tokens, tokenize source=some tokens ∧ helperTokens tokens=some (value,[]) := by
  change ((tokenize source).bind (fun tokens => (helperTokens tokens).bind (fun result =>
    if result.2=[] then some result.1 else none)))=some value at parsed
  obtain ⟨tokens,lexed,parsed⟩ := Option.bind_eq_some_iff.mp parsed
  obtain ⟨⟨actual,remaining⟩,blocked,parsed⟩ := Option.bind_eq_some_iff.mp parsed
  by_cases empty : remaining=[]
  · subst remaining
    simp only [ite_true] at parsed
    have same : actual=value := Option.some.inj parsed
    subst actual
    exact ⟨tokens,lexed,blocked⟩
  · simp only [empty,ite_false] at parsed
    contradiction

end Inference.Kernels.Copy.GeneralCopy2DSyntax

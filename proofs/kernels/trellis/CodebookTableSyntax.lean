import kernels.trellis.CodebookBitsSyntax
namespace Inference.Kernels.Trellis.CodebookTableSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken)
set_option maxRecDepth 10000

structure Loop where
  counterName : String
  initialBuiltin : String
  initialComponent : String
  testVariable : String
  boundBase : Nat
  boundParameter : String
  stepVariable : String
  stepParameter : String
  table : String
  subscript : String
  outerFunction : String
  innerFunction : String
  argument : String
  deriving DecidableEq, Repr

-- A genuine restricted token parser: identifiers, literal values and repeated
-- variable uses survive parsing; their bindings are checked by the semantics.
def unsignedToken : Parser Nat := fun ts => do
  let (token,rest) ← match ts with | token::rest => some (token,rest) | [] => none
  match CodebookBitsSyntax.literal token with
  | some (.integer true value) => some (value,rest)
  | _ => none

def loopTokens : Parser Loop := fun ts => do
  let ts ← accept "for" ts
  let ts ← accept "(" ts
  let ts ← accept "uint" ts
  let (counterName,ts) ← nameToken ts
  let ts ← accept "=" ts
  let (initialBuiltin,ts) ← nameToken ts
  let ts ← accept "." ts
  let (initialComponent,ts) ← nameToken ts
  let ts ← accept ";" ts
  let (testVariable,ts) ← nameToken ts
  let ts ← accept "<" ts
  let ts ← accept "(" ts
  let (boundBase,ts) ← unsignedToken ts
  let ts ← accept "<" ts
  let ts ← accept "<" ts
  let ts ← accept "(" ts
  let ts ← accept "uint" ts
  let ts ← accept ")" ts
  let (boundParameter,ts) ← nameToken ts
  let ts ← accept ")" ts
  let ts ← accept ";" ts
  let (stepVariable,ts) ← nameToken ts
  let ts ← accept "+" ts
  let ts ← accept "=" ts
  let ts ← accept "(" ts
  let ts ← accept "uint" ts
  let ts ← accept ")" ts
  let (stepParameter,ts) ← nameToken ts
  let ts ← accept ")" ts
  let (table,ts) ← nameToken ts
  let ts ← accept "[" ts
  let (subscript,ts) ← nameToken ts
  let ts ← accept "]" ts
  let ts ← accept "=" ts
  let (outerFunction,ts) ← nameToken ts
  let ts ← accept "(" ts
  let (innerFunction,ts) ← nameToken ts
  let ts ← accept "(" ts
  let (argument,ts) ← nameToken ts
  let ts ← accept ")" ts
  let ts ← accept ")" ts
  let ts ← accept ";" ts
  pure (⟨counterName,initialBuiltin,initialComponent,testVariable,boundBase,boundParameter,
    stepVariable,stepParameter,table,subscript,outerFunction,innerFunction,argument⟩,ts)

def sourceLoop : String := r#"for (uint i = thread_position_in_threadgroup.x; i < (1u << (uint)L); i += (uint)THREADS)
    codebook[i] = trellis_unrefined_bits_y(trellis_y(i));"#
def loop : Loop := ⟨"i","thread_position_in_threadgroup","x","i",1,"L","i","THREADS",
  "codebook","i","trellis_unrefined_bits_y","trellis_y","i"⟩
-- This lexical extension adds brackets only; the helper lexer is unchanged.
def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if Copy.ScalarCopySyntax.wordChar c then do
      let word := fun c => Copy.ScalarCopySyntax.wordChar c
      pure (String.ofList (c::rest.takeWhile word)::(←lexAux fuel (rest.dropWhile word)))
    else if ['.','{','}','(',')','[',']',';','=','+','-','*','/','|','<','>'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

def parse (source : String) : Option Loop := do
  let ts ← tokenize source
  let (loop,rest) ← loopTokens ts
  if rest=[] then some loop else none

theorem parsed_loop : parse sourceLoop=some loop := by decide +kernel

inductive Extent where
  | constant : Nat → Extent
  | shifted : Nat → String → Extent
  deriving DecidableEq, Repr
structure Declaration where
  name : String
  extent : Extent
  deriving DecidableEq, Repr

def declarationTokens : Parser Declaration := fun ts => do
  let ts ← accept "threadgroup" ts
  let ts ← accept "float" ts
  let (name,ts) ← nameToken ts
  let ts ← accept "[" ts
  let (first,ts) ← match ts with | first::rest => some (first,rest) | [] => none
  let value ← Copy.ScalarCopySyntax.decimal first
  let (extent,ts) ← match ts with
    | "<"::"<"::rest => do
      let (parameter,rest) ← nameToken rest
      pure (Extent.shifted value parameter,rest)
    | _ => some (Extent.constant value,ts)
  let ts ← accept "]" ts
  let ts ← accept ";" ts
  pure (⟨name,extent⟩,ts)
def parseDeclaration (source : String) : Option Declaration := do
  let ts ← tokenize source
  let (declaration,rest) ← declarationTokens ts
  if rest=[] then some declaration else none

def gateDeclaration : String := "threadgroup float codebook[1 << L];"
def downDeclaration : String := "threadgroup float codebook[4096];"
def sourceBarrier : String := "threadgroup_barrier(metal::mem_flags::mem_threadgroup);"
theorem gate_declaration : parseDeclaration gateDeclaration=some ⟨"codebook",.shifted 1 "L"⟩ := by decide +kernel
theorem down_declaration : parseDeclaration downDeclaration=some ⟨"codebook",.constant 4096⟩ := by decide +kernel
theorem consumes (source : String) (actual : Loop) (parsed : parse source=some actual) :
    ∃ ts, tokenize source=some ts ∧ loopTokens ts=some (actual,[]) := by
  change ((tokenize source).bind (fun ts => (loopTokens ts).bind (fun result =>
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
end Inference.Kernels.Trellis.CodebookTableSyntax

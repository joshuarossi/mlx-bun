import kernels.trellis.CodebookWindowSyntax
namespace Inference.Kernels.Trellis.PackedArraySyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken wordChar)
set_option maxRecDepth 10000
inductive Expr where
  | variable : String → Expr
  | literal : CodebookIntegerSyntax.LiteralKind → Nat → Expr
  | index : String → List Expr → Expr
  | castUInt : Expr → Expr
  | add : Expr → Expr → Expr
  | subtract : Expr → Expr → Expr
  | multiply : Expr → Expr → Expr
  | divide : Expr → Expr → Expr
  | modulo : Expr → Expr → Expr
  | bitOr : Expr → Expr → Expr
  | shiftLeft : Expr → Expr → Expr
  | shiftRight : Expr → Expr → Expr
  | equal : Expr → Expr → Expr
  | conditional : Expr → Expr → Expr → Expr
  deriving Repr
inductive Stmt where
  | declare : List (String × List Expr) → Stmt
  | assign : String → List Expr → Expr → Stmt
  | forLoop : String → Expr → Bool → Expr → List Stmt → Stmt
  deriving Repr

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c then do
      pure (String.ofList (c::rest.takeWhile wordChar)::(←lexAux fuel (rest.dropWhile wordChar)))
    else if ['<','>','=','+'].contains c then
      match rest with
      | d::tail => if d=c ∨ d='=' then do pure (String.ofList [c,d]::(←lexAux fuel tail))
        else do pure (String.singleton c::(←lexAux fuel rest))
      | [] => some [String.singleton c]
    else if ['(',')','[',']',';','-','*','/','%','|','?',':',',','{','}'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

def literal (token : String) : Option Expr := do
  match ←CodebookIntegerSyntax.literal token with
  | .literal kind n => some (.literal kind n)
  | _ => none

def operator : String → Option (Nat × (Expr → Expr → Expr))
  | "==" => some (1,Expr.equal)
  | "|" => some (2,Expr.bitOr)
  | "<<" => some (3,Expr.shiftLeft)
  | ">>" => some (3,Expr.shiftRight)
  | "+" => some (4,Expr.add)
  | "-" => some (4,Expr.subtract)
  | "*" => some (5,Expr.multiply)
  | "/" => some (5,Expr.divide)
  | "%" => some (5,Expr.modulo)
  | _ => none
mutual
  def expression : Nat → Nat → Parser Expr
    | 0,_,_ => none
    | fuel+1,minimum,ts => do
      let (left,rest) ← primary fuel ts
      let (left,rest) ← climb fuel minimum left rest
      if minimum=0 then
        match rest with
        | "?"::rest => do
          let (yes,rest) ← expression fuel 0 rest
          let rest ← accept ":" rest
          let (no,rest) ← expression fuel 0 rest
          pure (.conditional left yes no,rest)
        | _ => some (left,rest)
      else some (left,rest)
  def primary : Nat → Parser Expr
    | 0,_ => none
    | fuel+1,"("::"uint"::")"::rest => do
      let (value,rest) ← primary fuel rest
      pure (.castUInt value,rest)
    | fuel+1,"("::rest => do
      let (value,rest) ← expression fuel 0 rest
      let rest ← accept ")" rest
      pure (value,rest)
    | fuel+1,name::"["::rest => do
      let (name,_) ← nameToken [name]
      let (indices,rest) ← subscripts fuel ("["::rest)
      pure (.index name indices,rest)
    | _+1,token::rest => match literal token with
      | some value => some (value,rest)
      | none => do
        let (name,rest) ← nameToken (token::rest)
        pure (.variable name,rest)
    | _+1,[] => none
  def subscripts : Nat → Parser (List Expr)
    | 0,_ => none
    | fuel+1,"["::rest => do
      let (value,rest) ← expression fuel 0 rest
      let rest ← accept "]" rest
      let (tail,rest) ← subscripts fuel rest
      pure (value::tail,rest)
    | _+1,rest => some ([],rest)
  def climb : Nat → Nat → Expr → Parser Expr
    | 0,_,_,_ => none
    | fuel+1,minimum,left,ts => match ts with
      | token::rest => match operator token with
        | some (precedence,combine) =>
          if minimum≤precedence then do
            let (right,rest) ← expression fuel (precedence+1) rest
            climb fuel minimum (combine left right) rest
          else some (left,ts)
        | none => some (left,ts)
      | [] => some (left,[])
end

def declarator : Parser (String × List Expr) := fun ts => do
  let (name,rest) ← nameToken ts
  let (dimensions,rest) ← subscripts 256 rest
  if dimensions=[] then none else pure ((name,dimensions),rest)
def declarators : Nat → Parser (List (String × List Expr))
  | 0,_ => none
  | fuel+1,ts => do
    let (first,rest) ← declarator ts
    match rest with
    | ","::rest => do
      let (tail,rest) ← declarators fuel rest
      pure (first::tail,rest)
    | _ => pure ([first],rest)

mutual
  def statement : Nat → Parser Stmt
    | 0,_ => none
    | _+1,"uint"::rest => do
      let (arrays,rest) ← declarators 16 rest
      let rest ← accept ";" rest
      pure (.declare arrays,rest)
    | fuel+1,"for"::"("::"uint"::rest => do
      let (counter,rest) ← nameToken rest
      let rest ← accept "=" rest
      let (start,rest) ← expression 256 0 rest
      let rest ← accept ";" rest
      let rest ← accept counter rest
      let (inclusive,rest) ← match rest with
        | "<="::rest => some (true,rest)
        | "<"::rest => some (false,rest)
        | _ => none
      let (bound,rest) ← expression 256 0 rest
      let rest ← accept ";" rest
      let rest ← accept "++" rest
      let rest ← accept counter rest
      let rest ← accept ")" rest
      let (body,rest) ← statement fuel rest
      pure (.forLoop counter start inclusive bound [body],rest)
    | _+1,ts => do
      let (name,rest) ← nameToken ts
      let (indices,rest) ← subscripts 256 rest
      let rest ← accept "=" rest
      let (value,rest) ← expression 256 0 rest
      let rest ← accept ";" rest
      if indices=[] then none else pure (.assign name indices value,rest)
end

def parse (source : String) : Option Stmt := do
  let ts ← tokenize source
  let (value,rest) ← statement 32 ts
  if rest=[] then some value else none

-- Exact separately bound source fragments; comments/pragmas between them are
-- not stripped or normalized into an invented source body.
def gateDeclaration : String := "uint g[KG + 1], gv[KG + 1];"
def upDeclaration : String := "uint u[KU + 1], uv[KU + 1];"
def gateLoad : String := "for (uint i = 0; i < (uint)KG; ++i) g[i] = gcodes[gw + gW0 + i];"
def upLoad : String := "for (uint i = 0; i < (uint)KU; ++i) u[i] = ucodes[uw + uW0 + i];"
def gateWrap : String := "g[KG] = gcodes[gw + (t0 == 0u ? 0u : gW0 + (uint)KG)];"
def upWrap : String := "u[KU] = ucodes[uw + (t0 == 0u ? 0u : uW0 + (uint)KU)];"
def gateVirtualZero : String := "gv[0] = g[0] << 16;"
def upVirtualZero : String := "uv[0] = u[0] << 16;"
def gateVirtual : String := "for (uint i = 1; i <= (uint)KG; ++i) gv[i] = (g[i - 1] >> 16) | (g[i] << 16);"
def upVirtual : String := "for (uint i = 1; i <= (uint)KU; ++i) uv[i] = (u[i - 1] >> 16) | (u[i] << 16);"
def downIndexDeclaration : String := "uint idx[NL];"
def downIndex : String := "for (uint i = 0; i < NL; ++i) idx[i] = (first + i) % WPB;"
def downPairDeclaration : String := "uint ld[U][NL];"
def downPairLoad : String := "for (uint i = 0; i < NL; ++i) ld[u][i] = rowWords[idx[i]];"
def downTailDeclaration : String := "uint ld[NL];"
def downTailLoad : String := "for (uint i = 0; i < NL; ++i) ld[i] = rowWords[idx[i]];"
def downWordsDeclaration : String := "uint w[NA], v[NA];"
def downPairAlign : String := "for (uint i = 0; i < NA; ++i) w[i] = shifted ? (ld[u][i] >> SHIFT) | (ld[u][i + 1] << (32u - SHIFT)) : ld[u][i];"
def downTailAlign : String := "for (uint i = 0; i < NA; ++i) w[i] = shifted ? (ld[i] >> SHIFT) | (ld[i + 1] << (32u - SHIFT)) : ld[i];"
def downVirtualZero : String := "v[0] = w[0] << 16;"
def downVirtual : String := "for (uint i = 1; i < NA; ++i) v[i] = (w[i - 1] >> 16) | (w[i] << 16);"
end Inference.Kernels.Trellis.PackedArraySyntax

import kernels.quantization.AffineDot
import kernels.trellis.CodebookBitsSyntax

namespace Inference.Kernels.Quantization.AffineDot3Syntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken wordChar decimal)
set_option maxRecDepth 10000

-- Each statement retains its destination, byte/mask, source subscript and
-- optional parenthesized floating multiplier. The ten += statements remain
-- separate and ordered, unlike the grouped four-bit expression.
structure Input where
  array : String
  index : Nat
  factor : Option (Nat × Nat)
  deriving DecidableEq, Repr
structure Statement where
  target : String
  packed : String
  index : Nat
  mask : Nat
  input : Input
  deriving DecidableEq, Repr

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c ∨ c='.' then do
      let part := fun c => wordChar c ∨ c='.'
      pure (String.ofList (c::rest.takeWhile part)::(←lexAux fuel (rest.dropWhile part)))
    else if ['(',')','[',']',';','=','+','*','&'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none
def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

def indexed : Parser (String × Nat) := fun ts => do
  let (array,ts) ←nameToken ts
  let ts ←accept "[" ts
  let value::ts := ts | none
  let index ←decimal value
  let ts ←accept "]" ts
  pure ((array,index),ts)

def parseInput : Parser Input := fun ts => match ts with
  | "("::ts => do
    let ((array,index),ts) ←indexed ts
    let ts ←accept "*" ts
    let value::ts := ts | none
    let .floating mantissa scale ←Trellis.CodebookBitsSyntax.literal value | none
    let ts ←accept ")" ts
    pure (⟨array,index,some (mantissa,scale)⟩,ts)
  | _ => do
    let ((array,index),ts) ←indexed ts
    pure (⟨array,index,none⟩,ts)

def parseStatement : Parser Statement := fun ts => do
  let (target,ts) ←nameToken ts
  let ts ←accept "+" ts
  let ts ←accept "=" ts
  let ts ←accept "MLXQ_F" ts
  let ts ←accept "(" ts
  let ((packed,index),ts) ←indexed ts
  let ts ←accept "&" ts
  let value::ts := ts | none
  let mask ←match value.toList with
    | '0'::'x'::digits => Trellis.CodebookIntegerSyntax.hex digits
    | _ => none
  let ts ←accept ")" ts
  let ts ←accept "*" ts
  let (input,ts) ←parseInput ts
  let ts ←accept ";" ts
  pure (⟨target,packed,index,mask,input⟩,ts)

def parseStatements : Nat → Tokens → Option (List Statement)
  | _,[] => some []
  | 0,_::_ => none
  | fuel+1,ts => do
    let (first,rest) ←parseStatement ts
    pure (first::(←parseStatements fuel rest))

def parse (source : String) : Option (List Statement) := do
  let ts ←tokenize source
  parseStatements ts.length ts

def sourceBody : String := r#"accum += MLXQ_F(w[0] & 0x07) * x_thread[0];
      accum += MLXQ_F(w[0] & 0x38) * x_thread[1];
      accum += MLXQ_F(w[0] & 0xc0) * x_thread[2];
      accum += MLXQ_F(w[1] & 0x01) * (x_thread[2] * 256.0f);
      accum += MLXQ_F(w[1] & 0x0e) * x_thread[3];
      accum += MLXQ_F(w[1] & 0x70) * x_thread[4];
      accum += MLXQ_F(w[1] & 0x80) * x_thread[5];
      accum += MLXQ_F(w[2] & 0x03) * (x_thread[5] * 256.0f);
      accum += MLXQ_F(w[2] & 0x1c) * x_thread[6];
      accum += MLXQ_F(w[2] & 0xe0) * x_thread[7];"#

def statement (i : Fin 10) : Statement :=
  ⟨"accum","w",(AffineDot.byte3 i).val,(2^(AffineDot.width3 i)-1)*2^(AffineDot.shift3 i),
    ⟨"x_thread",(AffineDot.coordinate3 i).val,if AffineDot.crossed3 i then some (2560,1) else none⟩⟩
def body : List Statement := (List.finRange 10).map statement

theorem parsed_body : parse sourceBody=some body := by decide +kernel
theorem body_length : body.length=10 := by simp [body]

end Inference.Kernels.Quantization.AffineDot3Syntax

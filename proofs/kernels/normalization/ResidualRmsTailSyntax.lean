import kernels.copy.ScalarCopySyntax

namespace Inference.Kernels.Normalization.ResidualRmsTailSyntax
open Copy.ScalarCopySyntax (Tokens wordChar)
set_option maxRecDepth 10000

-- Deliberately restricted grammar for this source's reduction tail. Each
-- instruction includes the full token spelling, including guards, addresses,
-- namespace qualifiers and barrier flags. Unrecognized or extra tokens fail.
inductive Instruction where
  | groupReduce | initialize | barrier | partialWrite | inverse | deviceBarrier
  deriving DecidableEq, Repr

def spelling : Instruction → String
  | .groupReduce => "acc = metal::simd_sum(acc);"
  | .initialize => "if (sg == 0) sums[lane] = 0.0f;"
  | .barrier => "threadgroup_barrier(metal::mem_flags::mem_threadgroup);"
  | .partialWrite => "if (lane == 0) sums[sg] = acc;"
  | .inverse => "if (sg == 0) { acc = metal::simd_sum(sums[lane]); if (lane == 0) inv[0] = metal::precise::rsqrt(acc / float(D) + as_type<float>(uint(EPS))); }"
  | .deviceBarrier => "threadgroup_barrier(metal::mem_flags::mem_threadgroup | metal::mem_flags::mem_device);"

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c then do
      pure (String.ofList (c::rest.takeWhile wordChar)::(←lexAux fuel (rest.dropWhile wordChar)))
    else if ['(',')','[',']','{','}',';','=',':','/','+','<','>','|','.'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

def program : List Instruction := [.groupReduce,.initialize,.barrier,.partialWrite,.barrier,.inverse,.deviceBarrier]

-- Fixed productions are appropriate here: this parser accepts only the exact
-- reviewed kernel instruction shapes, not a general Metal language subset.
def parseInstructions : List Instruction → Tokens → Option (List Instruction × Tokens)
  | [],tokens => some ([],tokens)
  | instruction::rest,tokens => do
    let expected ←tokenize (spelling instruction)
    if tokens.take expected.length=expected then
      let (parsed,remaining) ←parseInstructions rest (tokens.drop expected.length)
      pure (instruction::parsed,remaining)
    else none

def parseBody (source : String) : Option (List Instruction) := do
  let tokens ←tokenize source
  let (parsed,remaining) ←parseInstructions program tokens
  if remaining=[] then some parsed else none

def sourceBody : String := r#"acc = metal::simd_sum(acc);
  if (sg == 0) sums[lane] = 0.0f;
  threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  if (lane == 0) sums[sg] = acc;
  threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  if (sg == 0) {
    acc = metal::simd_sum(sums[lane]);
    if (lane == 0) inv[0] = metal::precise::rsqrt(acc / float(D) + as_type<float>(uint(EPS)));
  }
  threadgroup_barrier(metal::mem_flags::mem_threadgroup | metal::mem_flags::mem_device);"#

theorem parsed_body : parseBody sourceBody=some program := by decide +kernel

theorem parseInstructions_shape (instructions : List Instruction) (tokens : Tokens)
    (parsed : parseInstructions instructions tokens=some (actual,remaining)) : actual=instructions := by
  induction instructions generalizing tokens actual remaining with
  | nil => simpa [parseInstructions] using congrArg (Option.map Prod.fst) parsed
  | cons instruction rest ih =>
    change ((tokenize (spelling instruction)).bind (fun expected =>
      if tokens.take expected.length=expected then
        (parseInstructions rest (tokens.drop expected.length)).bind (fun result => some (instruction::result.1,result.2))
      else none))=some (actual,remaining) at parsed
    obtain ⟨expected,_,parsed⟩ := Option.bind_eq_some_iff.mp parsed
    split at parsed
    · obtain ⟨⟨tail,leftover⟩,tailParsed,result⟩ := Option.bind_eq_some_iff.mp parsed
      have same : (instruction::tail,leftover)=(actual,remaining) := Option.some.inj result
      exact (congrArg Prod.fst same).symm.trans (congrArg (instruction::·) (ih _ tailParsed))
    · contradiction

end Inference.Kernels.Normalization.ResidualRmsTailSyntax

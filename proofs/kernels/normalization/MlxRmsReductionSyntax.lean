import kernels.normalization.MlxRmsLoopSyntax

namespace Inference.Kernels.Normalization.MlxRmsReductionSyntax
open Copy.ScalarCopySyntax (Tokens)
open MlxRmsLoopSyntax (word)
set_option maxRecDepth 10000

-- Complete fixed productions retain guards, scratch indices, arithmetic and
-- all three barrier flags. Only line comments and whitespace are ignored.
inductive Instruction where
  | groupReduce | initialize | barrier | partialWrite | inverse
  deriving DecidableEq, Repr

def spelling : Instruction → String
  | .groupReduce => "acc = simd_sum(acc);"
  | .initialize => "if (simd_group_id == 0) { local_sums[simd_lane_id] = 0; }"
  | .barrier => "threadgroup_barrier(mem_flags::mem_threadgroup);"
  | .partialWrite => "if (simd_lane_id == 0) { local_sums[simd_group_id] = acc; }"
  | .inverse => "if (simd_group_id == 0) { acc = simd_sum(local_sums[simd_lane_id]); if (simd_lane_id == 0) { local_inv_mean[0] = metal::precise::rsqrt(acc / axis_size + eps); } }"

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if [' ','\n','\t','\r'].contains c then lexAux fuel rest
    else if word c then do
      pure (String.ofList (c::rest.takeWhile word)::(←lexAux fuel (rest.dropWhile word)))
    else match c,rest with
      | '/','/'::rest => lexAux fuel (rest.dropWhile (fun c => c != '\n'))
      | _,_ => if ['(',')','[',']','{','}',';','=',':','/','+','.'].contains c then do
          pure (String.singleton c::(←lexAux fuel rest)) else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

def program : List Instruction := [.groupReduce,.initialize,.barrier,.partialWrite,.barrier,.inverse,.barrier]
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

def sourceBody : String := r#"acc = simd_sum(acc);
  //  Initialize shared memory
  if (simd_group_id == 0) {
    local_sums[simd_lane_id] = 0;
  }
  threadgroup_barrier(mem_flags::mem_threadgroup);

  // Write simd accumulations into shared memory
  if (simd_lane_id == 0) {
    local_sums[simd_group_id] = acc;
  }
  threadgroup_barrier(mem_flags::mem_threadgroup);

  // Accumulate over simd groups
  if (simd_group_id == 0) {
    acc = simd_sum(local_sums[simd_lane_id]);
    if (simd_lane_id == 0) {
      local_inv_mean[0] = metal::precise::rsqrt(acc / axis_size + eps);
    }
  }
  threadgroup_barrier(mem_flags::mem_threadgroup);"#

theorem parsed_body : parseBody sourceBody=some program := by decide +kernel
end Inference.Kernels.Normalization.MlxRmsReductionSyntax

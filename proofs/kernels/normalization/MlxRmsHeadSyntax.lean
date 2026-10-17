import kernels.normalization.MlxRmsOutputSyntax
import kernels.normalization.MlxRmsLoopSyntax

namespace Inference.Kernels.Normalization.MlxRmsHeadSyntax
open MlxRmsOutputSyntax
open Copy.ScalarCopySyntax (accept)
set_option maxRecDepth 10000

structure Capture where
  target : String
  index : Expr
  input : Expr
  accumulator : String
  product : Expr
  deriving DecidableEq, Repr

def parseCapture (source : String) : Option Capture := do
  let tokens ←tokenize source
  let (target,rest) ←nameToken tokens
  let rest ←accept "[" rest
  let (index,rest) ←varExpr rest
  let rest ←accept "]" rest
  let rest ←accept "=" rest
  let (input,rest) ←indexed varExpr rest
  let rest ←accept ";" rest
  let (accumulator,rest) ←nameToken rest
  let rest ←accept "+" rest
  let rest ←accept "=" rest
  let (product,rest) ←MlxRmsOutputSyntax.product (indexed varExpr) (indexed varExpr) rest
  let rest ←accept ";" rest
  if rest=[] then some ⟨target,index,input,accumulator,product⟩ else none

def parseOutput (source : String) : Option Store := do
  let tokens ←tokenize source
  let (destination,rest) ←nameToken tokens
  let rest ←accept "[" rest
  let (index,rest) ←varExpr rest
  let rest ←accept "]" rest
  let rest ←accept "=" rest
  let (value,rest) ←product (indexed (product varExpr varExpr))
    (cast (product (indexed varExpr) (indexed zero))) rest
  let rest ←accept ";" rest
  if rest=[] then some ⟨destination,index,value⟩ else none

-- A complete selected if/full-loop shell. TAIL denotes the whole unreachable
-- else block; its exclusion is proved from the selected 64-thread dispatch.
def parseBranch (source : String) : Option Nat := do
  let tokens ←MlxRmsLoopSyntax.tokenize source
  let rest ←MlxRmsLoopSyntax.acceptAll ["if","(","lid","*","N_READS","+","N_READS","<=","axis_size",
    ")","{","for","(","int","i","="] tokens
  let (initial,rest) ←MlxRmsLoopSyntax.natural rest
  let rest ←MlxRmsLoopSyntax.acceptAll [";","i","<","N_READS",";","i","++",")","{","CELL",";","}","}","else","{","TAIL",";","}"] rest
  if rest=[] then some initial else none

def sourceCaptureBody : String := r#"thread_x[i] = x[i];
      acc += thread_x[i] * thread_x[i];"#
def sourceOutputBody : String := r#"out[i] =
          w[w_stride * i] * static_cast<T>(thread_x[i] * local_inv_mean[0]);"#
def sourceBranchBody : String := r#"if (lid * N_READS + N_READS <= axis_size) {
    for (int i = 0; i < N_READS; i++) { CELL; }
  } else { TAIL; }"#

def capture : Capture := ⟨"thread_x",.var "i",.index "x" (.var "i"),"acc",
  .mul (.index "thread_x" (.var "i")) (.index "thread_x" (.var "i"))⟩
def output : Store := ⟨"out",.var "i",.mul (.index "w" (.mul (.var "w_stride") (.var "i")))
  (.cast "T" (.mul (.index "thread_x" (.var "i")) (.index "local_inv_mean" .zero)))⟩

theorem parsed_capture : parseCapture sourceCaptureBody=some capture := by decide +kernel
theorem parsed_output : parseOutput sourceOutputBody=some output := by decide +kernel
theorem parsed_branch : parseBranch sourceBranchBody=some 0 := by decide +kernel

end Inference.Kernels.Normalization.MlxRmsHeadSyntax

import kernels.sampling.ArgmaxShuffleSyntax
namespace Inference.Kernels.Sampling.LogSumExpSourceSyntax
open Copy.ScalarCopySyntax (Tokens)
set_option maxRecDepth 10000

-- Restricted productions for the complete native looped kernel body.
-- Native lexical extraction is guarded separately; every control, index,
-- operator, scratch store, barrier and output cast is a grammar terminal.
inductive Phase where
  | pointer
  | setup
  | loop
  | group
  | maxScratch
  | normalizerScratch
  | output
  deriving DecidableEq,Repr

def spelling : Phase→Tokens
  | .pointer => ["in","+","=","gid","*","size_t","(","axis_size",")",";"]
  | .setup => ["constexpr","int","SIMD_SIZE","=","32",";","threadgroup","AccT","local_max","[","SIMD_SIZE","]",";","threadgroup","AccT","local_normalizer","[","SIMD_SIZE","]",";","AccT","prevmax",";","AccT","maxval","=","Limits","<","AccT",">",":",":","finite_min",";","AccT","normalizer","=","0",";"]
  | .loop => ["for","(","int","r","=","0",";","r","<","static_cast","<","int",">","(","ceildiv","(","axis_size",",","N_READS","*","lsize",")",")",";","r","+","+",")","{","int","offset","=","r","*","lsize","*","N_READS","+","lid","*","N_READS",";","AccT","vals","[","N_READS","]",";","if","(","offset","+","N_READS","<","=","axis_size",")","{","for","(","int","i","=","0",";","i","<","N_READS",";","i","+","+",")","{","vals","[","i","]","=","AccT","(","in","[","offset","+","i","]",")",";","}","}","else","{","for","(","int","i","=","0",";","i","<","N_READS",";","i","+","+",")","{","vals","[","i","]","=","(","offset","+","i","<","axis_size",")","?","AccT","(","in","[","offset","+","i","]",")",":","Limits","<","AccT",">",":",":","min",";","}","}","prevmax","=","maxval",";","for","(","int","i","=","0",";","i","<","N_READS",";","i","+","+",")","{","maxval","=","(","maxval","<","vals","[","i","]",")","?","vals","[","i","]",":","maxval",";","}","normalizer","*","=","fast",":",":","exp","(","prevmax","-","maxval",")",";","for","(","int","i","=","0",";","i","<","N_READS",";","i","+","+",")","{","normalizer","+","=","fast",":",":","exp","(","vals","[","i","]","-","maxval",")",";","}","}"]
  | .group => ["prevmax","=","maxval",";","maxval","=","simd_max","(","maxval",")",";","normalizer","*","=","fast",":",":","exp","(","prevmax","-","maxval",")",";","normalizer","=","simd_sum","(","normalizer",")",";"]
  | .maxScratch => ["prevmax","=","maxval",";","if","(","simd_lane_id","=","=","0",")","{","local_max","[","simd_group_id","]","=","maxval",";","}","threadgroup_barrier","(","mem_flags",":",":","mem_threadgroup",")",";","maxval","=","simd_max","(","local_max","[","simd_lane_id","]",")",";"]
  | .normalizerScratch => ["normalizer","*","=","fast",":",":","exp","(","prevmax","-","maxval",")",";","if","(","simd_lane_id","=","=","0",")","{","local_normalizer","[","simd_group_id","]","=","normalizer",";","}","threadgroup_barrier","(","mem_flags",":",":","mem_threadgroup",")",";","normalizer","=","simd_sum","(","local_normalizer","[","simd_lane_id","]",")",";"]
  | .output => ["if","(","lid","=","=","0",")","{","out","[","gid","]","=","isinf","(","maxval",")","?","T","(","maxval",")",":","T","(","log","(","normalizer",")","+","maxval",")",";","}"]

def program : List Phase := [.pointer,.setup,.loop,.group,.maxScratch,.normalizerScratch,.output]

def parsePhases : List Phase→Tokens→Option (List Phase×Tokens)
  | [],tokens => some ([],tokens)
  | phase::rest,tokens => do
    let expected := spelling phase
    if tokens.take expected.length=expected then
      let (parsed,remaining) ←parsePhases rest (tokens.drop expected.length)
      pure (phase::parsed,remaining)
    else none

def parse (tokens : Tokens) : Option (List Phase) := do
  let (parsed,remaining) ←parsePhases program tokens
  if remaining=[] then some parsed else none

def bodyTokens : Tokens := ["in","+","=","gid","*","size_t","(","axis_size",")",";","constexpr","int","SIMD_SIZE","=","32",";","threadgroup","AccT","local_max","[","SIMD_SIZE","]",";","threadgroup","AccT","local_normalizer","[","SIMD_SIZE","]",";","AccT","prevmax",";","AccT","maxval","=","Limits","<","AccT",">",":",":","finite_min",";","AccT","normalizer","=","0",";","for","(","int","r","=","0",";","r","<","static_cast","<","int",">","(","ceildiv","(","axis_size",",","N_READS","*","lsize",")",")",";","r","+","+",")","{","int","offset","=","r","*","lsize","*","N_READS","+","lid","*","N_READS",";","AccT","vals","[","N_READS","]",";","if","(","offset","+","N_READS","<","=","axis_size",")","{","for","(","int","i","=","0",";","i","<","N_READS",";","i","+","+",")","{","vals","[","i","]","=","AccT","(","in","[","offset","+","i","]",")",";","}","}","else","{","for","(","int","i","=","0",";","i","<","N_READS",";","i","+","+",")","{","vals","[","i","]","=","(","offset","+","i","<","axis_size",")","?","AccT","(","in","[","offset","+","i","]",")",":","Limits","<","AccT",">",":",":","min",";","}","}","prevmax","=","maxval",";","for","(","int","i","=","0",";","i","<","N_READS",";","i","+","+",")","{","maxval","=","(","maxval","<","vals","[","i","]",")","?","vals","[","i","]",":","maxval",";","}","normalizer","*","=","fast",":",":","exp","(","prevmax","-","maxval",")",";","for","(","int","i","=","0",";","i","<","N_READS",";","i","+","+",")","{","normalizer","+","=","fast",":",":","exp","(","vals","[","i","]","-","maxval",")",";","}","}","prevmax","=","maxval",";","maxval","=","simd_max","(","maxval",")",";","normalizer","*","=","fast",":",":","exp","(","prevmax","-","maxval",")",";","normalizer","=","simd_sum","(","normalizer",")",";","prevmax","=","maxval",";","if","(","simd_lane_id","=","=","0",")","{","local_max","[","simd_group_id","]","=","maxval",";","}","threadgroup_barrier","(","mem_flags",":",":","mem_threadgroup",")",";","maxval","=","simd_max","(","local_max","[","simd_lane_id","]",")",";","normalizer","*","=","fast",":",":","exp","(","prevmax","-","maxval",")",";","if","(","simd_lane_id","=","=","0",")","{","local_normalizer","[","simd_group_id","]","=","normalizer",";","}","threadgroup_barrier","(","mem_flags",":",":","mem_threadgroup",")",";","normalizer","=","simd_sum","(","local_normalizer","[","simd_lane_id","]",")",";","if","(","lid","=","=","0",")","{","out","[","gid","]","=","isinf","(","maxval",")","?","T","(","maxval",")",":","T","(","log","(","normalizer",")","+","maxval",")",";","}"]
theorem parsed : parse bodyTokens=some program := by rfl
end Inference.Kernels.Sampling.LogSumExpSourceSyntax

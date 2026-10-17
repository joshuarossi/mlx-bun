import kernels.attention.MlxSdpaTwoPassLoop
import kernels.attention.MlxSdpaPartialSource

namespace Inference.Kernels.Attention.MlxSdpaTwoPassSyntax
open Contracts.Mlx MlxSdpaVectorSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken)
open Normalization.MlxRmsLoopSyntax (acceptAll natural)
set_option maxRecDepth 10000

def products : Nat → Expr → Tokens → Option (Expr × Tokens)
  | 0,_,_ => none
  | fuel+1,a,"*"::rest => do let (b,rest) ←atom rest; products fuel (.mul a b) rest
  | _+1,a,rest => some (a,rest)
def product : Parser Expr := fun ts => do
  let (a,rest) ←atom ts
  products (ts.length+1) a rest
def additions : Nat → Expr → Tokens → Option (Expr × Tokens)
  | 0,_,_ => none
  | fuel+1,a,"+"::rest => do let (b,rest) ←product rest; additions fuel (.add a b) rest
  | _+1,a,rest => some (a,rest)
def expression : Parser Expr := fun ts => do
  let (a,rest) ←product ts
  additions (ts.length+1) a rest

def pointer : Parser Pointer := fun ts => do
  let (name,rest) ←nameToken ts
  let rest ←acceptAll ["+","="] rest
  let (offset,rest) ←expression rest
  let rest ←accept ";" rest
  pure (⟨name,offset⟩,rest)

def parsePointers (source : String) : Option (List Pointer) := do
  let ts ←MlxRopeSingleSyntax.tokenize source
  let (q,rest) ←pointer ts
  let (k,rest) ←pointer rest
  let (v,rest) ←pointer rest
  let (o,rest) ←pointer rest
  let (s,rest) ←pointer rest
  let (m,rest) ←pointer rest
  if rest=[] then some [q,k,v,o,s,m] else none

def sourcePointers : String := r#"queries += q_offset * D + simd_lid * qk_per_thread;
keys += kv_batch_head_idx * k_head_stride + block_idx * k_seq_stride +
      simd_lid * qk_per_thread;
  values += kv_batch_head_idx * v_head_stride + block_idx * v_seq_stride +
      simd_lid * v_per_thread;
  out += o_offset * blocks * V + block_idx * V + simd_lid * v_per_thread;
sums += o_offset * blocks + block_idx;
  maxs += o_offset * blocks + block_idx;"#

def queryPointer : Pointer := MlxSdpaVectorSyntax.queryPointer
def keyPointer : Pointer := ⟨"keys",.add (.add (.mul (.var "kv_batch_head_idx") (.var "k_head_stride"))
  (.mul (.var "block_idx") (.var "k_seq_stride"))) (.mul (.var "simd_lid") (.var "qk_per_thread"))⟩
def valuePointer : Pointer := ⟨"values",.add (.add (.mul (.var "kv_batch_head_idx") (.var "v_head_stride"))
  (.mul (.var "block_idx") (.var "v_seq_stride"))) (.mul (.var "simd_lid") (.var "v_per_thread"))⟩
def outputPointer : Pointer := ⟨"out",.add (.add (.mul (.mul (.var "o_offset") (.var "blocks")) (.var "V"))
  (.mul (.var "block_idx") (.var "V"))) (.mul (.var "simd_lid") (.var "v_per_thread"))⟩
def sumPointer : Pointer := ⟨"sums",.add (.mul (.var "o_offset") (.var "blocks")) (.var "block_idx")⟩
def maxPointer : Pointer := ⟨"maxs",sumPointer.offset⟩
def pointers : List Pointer := [queryPointer,keyPointer,valuePointer,outputPointer,sumPointer,maxPointer]
theorem parsed_pointers : parsePointers sourcePointers=some pointers := by decide +kernel

def parseDot (source : String) : Option MlxSdpaScoreSource.Dot := do
  let ts ←MlxSdpaScoreSource.lex (source.length+1) source.toList
  let rest ←acceptAll ["U","score","="] ts
  let (initial,rest) ←natural rest
  let rest ←acceptAll [";","for","(","int","i","="] rest
  let (first,rest) ←natural rest
  let rest ←acceptAll [";","i","<","qk_per_thread",";","i","+","+",")","{",
    "score","+","=","q","[","i","]","*","keys","[","i","]",";","}",
    "score","=","simd_sum","(","score",")",";"] rest
  if rest=[] then some ⟨initial,first⟩ else none

def sourceDot : String := r#"U score = 0;
      for (int i = 0; i < qk_per_thread; i++) {
        score += q[i] * keys[i];
      }
      score = simd_sum(score);"#
theorem parsed_dot : parseDot sourceDot=some ⟨0,0⟩ := by decide +kernel

end Inference.Kernels.Attention.MlxSdpaTwoPassSyntax

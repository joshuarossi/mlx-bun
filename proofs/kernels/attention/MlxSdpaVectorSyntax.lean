import kernels.attention.MlxRopeSingleSyntax

namespace Inference.Kernels.Attention.MlxSdpaVectorSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken decimal)
open Normalization.MlxRmsLoopSyntax (acceptAll)
open MlxRopeSingleSyntax (tokenize)
set_option maxRecDepth 10000

inductive Expr where
  | var : String → Expr
  | mul : Expr → Expr → Expr
  | add : Expr → Expr → Expr
  deriving DecidableEq, Repr

def atom : Parser Expr := fun ts => do
  let (name,rest) ←nameToken ts
  pure (.var name,rest)
def product : Parser Expr := fun ts => do
  let (a,rest) ←atom ts
  match rest with
  | "*"::rest => do let (b,rest) ←atom rest; pure (.mul a b,rest)
  | _ => pure (a,rest)
def additions : Nat → Expr → Tokens → Option (Expr × Tokens)
  | 0,_,_ => none
  | _+1,a,[] => some (a,[])
  | fuel+1,a,"+"::rest => do
    let (b,rest) ←product rest
    additions fuel (.add a b) rest
  | _+1,a,rest => some (a,rest)
def expression : Parser Expr := fun ts => do
  let (a,rest) ←product ts
  additions (ts.length+1) a rest

structure Pointer where
  name : String
  offset : Expr
  deriving DecidableEq, Repr

def pointer : Parser Pointer := fun ts => do
  let (name,rest) ←nameToken ts
  let rest ←acceptAll ["+","="] rest
  let (value,rest) ←expression rest
  let rest ←accept ";" rest
  pure (⟨name,value⟩,rest)

def parsePointers (source : String) : Option (List Pointer) := do
  let ts ←tokenize source
  let (q,rest) ←pointer ts
  let (k,rest) ←pointer rest
  let (v,rest) ←pointer rest
  let (o,rest) ←pointer rest
  if rest=[] then some [q,k,v,o] else none

def sourcePointers : String := r#"queries += q_offset * D + simd_lid * qk_per_thread;
  keys += kv_head_idx * k_head_stride + simd_gid * k_seq_stride +
      simd_lid * qk_per_thread;
  values += kv_head_idx * v_head_stride + simd_gid * v_seq_stride +
      simd_lid * v_per_thread;
out += o_offset * V + simd_gid * v_per_thread;"#

def queryPointer : Pointer := ⟨"queries",.add (.mul (.var "q_offset") (.var "D"))
  (.mul (.var "simd_lid") (.var "qk_per_thread"))⟩
def keyPointer : Pointer := ⟨"keys",.add (.add (.mul (.var "kv_head_idx") (.var "k_head_stride"))
  (.mul (.var "simd_gid") (.var "k_seq_stride"))) (.mul (.var "simd_lid") (.var "qk_per_thread"))⟩
def valuePointer : Pointer := ⟨"values",.add (.add (.mul (.var "kv_head_idx") (.var "v_head_stride"))
  (.mul (.var "simd_gid") (.var "v_seq_stride"))) (.mul (.var "simd_lid") (.var "v_per_thread"))⟩
def outputPointer : Pointer := ⟨"out",.add (.mul (.var "o_offset") (.var "V"))
  (.mul (.var "simd_gid") (.var "v_per_thread"))⟩

theorem parsed_pointers : parsePointers sourcePointers=some [queryPointer,keyPointer,valuePointer,outputPointer] := by decide +kernel

-- Retain the source scalar type, coordinate variable and pre-dot scaling.
inductive Cell where
  | query : String → Cell
  | key : String → Cell
  | output : String → Cell
  deriving DecidableEq, Repr

def parseQuery (source : String) : Option Cell := do
  let ts ←tokenize source
  let rest ←acceptAll ["q","["] ts
  let (i,rest) ←nameToken rest
  let rest ←acceptAll ["]","=","static_cast","<","U",">","(","scale",")","*","queries","["] rest
  let (j,rest) ←nameToken rest
  let rest ←acceptAll ["]",";"] rest
  if rest=[] && i==j then some (.query i) else none

def parseKey (source : String) : Option Cell := do
  let ts ←tokenize source
  let rest ←acceptAll ["k","["] ts
  let (i,rest) ←nameToken rest
  let rest ←acceptAll ["]","=","keys","["] rest
  let (j,rest) ←nameToken rest
  let rest ←acceptAll ["]",";"] rest
  if rest=[] && i==j then some (.key i) else none

def parseOutput (source : String) : Option Cell := do
  let ts ←tokenize source
  let rest ←acceptAll ["out","["] ts
  let (i,rest) ←nameToken rest
  let rest ←acceptAll ["]","=","static_cast","<","T",">","(","o","["] rest
  let (j,rest) ←nameToken rest
  let rest ←acceptAll ["]",")",";"] rest
  if rest=[] && i==j then some (.output i) else none

def sourceQuery : String := r#"q[i] = static_cast<U>(scale) * queries[i];"#
def sourceKey : String := r#"k[j] = keys[j];"#
def sourceOutput : String := r#"out[i] = static_cast<T>(o[i]);"#
theorem parsed_query : parseQuery sourceQuery=some (.query "i") := by decide +kernel
theorem parsed_key : parseKey sourceKey=some (.key "j") := by decide +kernel
theorem parsed_output : parseOutput sourceOutput=some (.output "i") := by decide +kernel

def eval (env : String → Nat) : Expr → Nat
  | .var x => env x
  | .mul a b => eval env a * eval env b
  | .add a b => eval env a + eval env b

end Inference.Kernels.Attention.MlxSdpaVectorSyntax

import kernels.quantization.AffineOuter4Syntax
namespace Inference.Kernels.Quantization.MlxQmvFast4Syntax
open Copy.ScalarCopySyntax (accept)
open Sampling.ArgmaxShuffleSyntax (acceptMany)
open AffineInput4Syntax (number)
set_option maxRecDepth 10000
abbrev Header := AffineOuter4Syntax.Header

def parseHeader (source : String) : Option Header := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["for","(","int","k","="] ts
  let (start,ts) ←number ts
  let ts ←acceptMany [";","k","<","in_vec_size",";","k","+=","block_size",")","{"] ts
  if ts=[] then some ⟨start,512⟩ else none

def parseInner (source : String) : Option Nat := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["for","(","int","row","="] ts
  let (initial,ts) ←number ts
  let ts ←acceptMany [";","row","<","results_per_simdgroup",";","row","++",")","{"] ts
  if ts=[] then some initial else none

def parseInitial (source : String) : Option Nat := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["thread","U","result","[","results_per_simdgroup","]","=","{"] ts
  let (initial,ts) ←number ts
  let ts ←acceptMany ["}",";"] ts
  if ts=[] then some initial else none

def parseCall (source : String) : Option Unit := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["result","[","row","]","+=","qdot","<","U",",","values_per_thread",",","bits",">","(","wl",",","x_thread",",","s",",","b",",","sum",")",";"] ts
  if ts=[] then some () else none

def parseLoad (source : String) : Option Unit := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["U","sum","=","load_vector","<","T",",","U",",","values_per_thread",",","bits",">","(","x",",","x_thread",")",";"] ts
  if ts=[] then some () else none

def headerSource : String := "for (int k = 0; k < in_vec_size; k += block_size) {"
def innerSource : String := "for (int row = 0; row < results_per_simdgroup; row++) {"
def initialSource : String := "thread U result[results_per_simdgroup] = {0};"
def callSource : String := "result[row] += qdot<U, values_per_thread, bits>(wl, x_thread, s, b, sum);"
def loadSource : String := "U sum = load_vector<T, U, values_per_thread, bits>(x, x_thread);"
def header : Header := ⟨0,512⟩
theorem parsed_header : parseHeader headerSource=some header := by decide +kernel
theorem parsed_inner : parseInner innerSource=some 0 := by decide +kernel
theorem parsed_initial : parseInitial initialSource=some 0 := by decide +kernel
theorem parsed_call : parseCall callSource=some () := by decide +kernel
theorem parsed_load : parseLoad loadSource=some () := by decide +kernel
structure Config where
  branchBit : Nat
  branchYes : Nat
  branchNo : Nat
  simds : Nat
  rows : Nat
  packWidth : Nat
  byteWidth : Nat
  deriving DecidableEq, Repr

def parseConfig (source : String) : Option Config := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["constexpr","int","packs_per_thread","=","bits","=="] ts
  let (bit,ts) ←number ts
  let ts ←accept "?" ts
  let (yes,ts) ←number ts
  let ts ←accept ":" ts
  let (no,ts) ←number ts
  let ts ←acceptMany [";","constexpr","int","num_simdgroups","="] ts
  let (simds,ts) ←number ts
  let ts ←acceptMany [";","constexpr","int","results_per_simdgroup","="] ts
  let (rows,ts) ←number ts
  let ts ←acceptMany [";","constexpr","int","pack_factor","=","get_pack_factor","<","bits",","] ts
  let (packWidth,ts) ←number ts
  let ts ←acceptMany [">","(",")",";","constexpr","int","bytes_per_pack","=","get_bytes_per_pack","<","bits",","] ts
  let (byteWidth,ts) ←number ts
  let ts ←acceptMany [">","(",")",";","constexpr","int","values_per_thread","=","pack_factor","*","packs_per_thread",";",
    "constexpr","int","block_size","=","values_per_thread","*","SIMD_SIZE",";",
    "constexpr","int","scale_step_per_thread","=","group_size","/","values_per_thread",";"] ts
  if ts=[] then some ⟨bit,yes,no,simds,rows,packWidth,byteWidth⟩ else none

def configSource : String := "constexpr int packs_per_thread = bits == 2 ? 1 : 2;\n  constexpr int num_simdgroups = 2;\n  constexpr int results_per_simdgroup = 4;\n  constexpr int pack_factor = get_pack_factor<bits, 32>();\n  constexpr int bytes_per_pack = get_bytes_per_pack<bits, 32>();\n  constexpr int values_per_thread = pack_factor * packs_per_thread;\n  constexpr int block_size = values_per_thread * SIMD_SIZE;\n  constexpr int scale_step_per_thread = group_size / values_per_thread;"

def configuration : Config := ⟨2,1,2,2,4,32,32⟩
theorem parsed_config : parseConfig configSource=some configuration := by decide +kernel

-- The pinned helper branches for bits4 are wsize/bits and wsize/8. SIMD
-- width32 and group64 remain selected template/device primitive parameters.
def evaluateConfig (c : Config) : List Nat :=
  let packs := if 4=c.branchBit then c.branchYes else c.branchNo
  let factor := c.packWidth/4
  let bytes := c.byteWidth/8
  let values := factor*packs
  [packs,c.simds,c.rows,factor,bytes,values,values*32,64/values]
def sourceConfig : Option (List Nat) := (parseConfig configSource).map evaluateConfig

theorem source_config : sourceConfig=some [2,2,4,8,4,16,512,4] := by
  rw [sourceConfig,parsed_config]
  rfl
end Inference.Kernels.Quantization.MlxQmvFast4Syntax

import kernels.delta.GatedPointerSyntax

namespace Inference.Kernels.Delta.GatedOutputSyntax
open Copy.ScalarCopySyntax (Tokens)
open Normalization.MlxRmsLoopSyntax (acceptAll natural)
open GatedPointerSyntax (lex parseExact)
set_option maxRecDepth 10000

def parseTime (source : String) : Option Nat := do
  let tokens ←lex (source.length+1) source.toList
  let rest ←acceptAll ["for","(","int","t","="] tokens
  let (first,rest) ←natural rest
  let rest ←acceptAll [";","t","<","T",";","+","+","t",")","{","if","(","true",")","{"] rest
  if rest=[] then some first else none

def parseWriter (source : String) : Option Nat := do
  let tokens ←lex (source.length+1) source.toList
  let rest ←acceptAll ["if","(","thread_index_in_simdgroup","=","="] tokens
  let (lane,rest) ←natural rest
  let rest ←acceptAll [")","{","y","[","dv_idx","]","=","static_cast","<","InT",">","(","out",")",";","}"] rest
  if rest=[] then some lane else none

def parseAdvance : String → Option Unit := parseExact ["q_","+","=","Hk","*","Dk",";",
  "k_","+","=","Hk","*","Dk",";","v_","+","=","Hv","*","Dv",";","y","+","=","Hv","*","Dv",";",
  "g_","+","=","Hv",";","beta_","+","=","Hv",";"]

def parseFinal (source : String) : Option Nat := do
  let tokens ←lex (source.length+1) source.toList
  let rest ←acceptAll ["for","(","int","i","="] tokens
  let (first,rest) ←natural rest
  let rest ←acceptAll [";","i","<","n_per_t",";","+","+","i",")","{",
    "auto","s_idx","=","n_per_t","*","dk_idx","+","i",";",
    "o_state","[","s_idx","]","=","static_cast","<","StT",">","(","state","[","i","]",")",";","}"] rest
  if rest=[] then some first else none

def timeSource : String := r#"for (int t = 0; t < T; ++t) {
      if (true) {"#
def writerSource : String := r#"if (thread_index_in_simdgroup == 0) {
          y[dv_idx] = static_cast<InT>(out);
        }"#
def advanceSource : String := r#"q_ += Hk * Dk;
      k_ += Hk * Dk;
      v_ += Hv * Dv;
      y += Hv * Dv;
      g_ += Hv;
      beta_ += Hv;"#
def finalSource : String := r#"for (int i = 0; i < n_per_t; ++i) {
      auto s_idx = n_per_t * dk_idx + i;
      o_state[s_idx] = static_cast<StT>(state[i]);
    }"#

theorem parsed_time : parseTime timeSource=some 0 := by decide +kernel
theorem parsed_writer : parseWriter writerSource=some 0 := by decide +kernel
theorem parsed_advance : parseAdvance advanceSource=some () := by decide +kernel
theorem parsed_final : parseFinal finalSource=some 0 := by decide +kernel

def timeVisits : Option (List Nat) := do
  let start ←parseTime timeSource
  pure ((List.range 1).drop start)
def stateVisits : Option (List (Fin 4)) := do
  let start ←parseFinal finalSource
  pure ((List.finRange 4).drop start)

attribute [local irreducible] parseTime parseWriter parseAdvance parseFinal
theorem time_visits : timeVisits=some [0] := by
  unfold timeVisits
  rw [parsed_time]
  rfl
theorem state_visits : stateVisits=some (List.finRange 4) := by
  unfold stateVisits
  rw [parsed_final]
  rfl

end Inference.Kernels.Delta.GatedOutputSyntax

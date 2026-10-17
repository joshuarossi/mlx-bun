import kernels.sampling.NormalizedScoreSourceMemory

namespace Inference.Kernels.Sampling.ArgmaxTraversalSource
open Contracts.Mlx
open Copy.ScalarCopySyntax (Tokens accept)
open ArgmaxShuffleSyntax (wordChar whitespace acceptMany natural)
set_option maxRecDepth 10000

structure Header where
  tileWidth : Nat
  tileAdvance : Nat
  boundWidth : Nat
  stride : Nat
  deriving DecidableEq, Repr

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if whitespace c then lexAux fuel (rest.dropWhile whitespace)
    else if wordChar c then do
      pure (String.ofList (c::rest.takeWhile wordChar)::(←lexAux fuel (rest.dropWhile wordChar)))
    else if ['(',')','{',';',',','=','+','*','<'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest)) else none

def tokenize (source : String) := lexAux (source.length+1) source.toList

def parseTokens (tokens : Tokens) : Option Header := do
  let rest ←acceptMany ["for","(","uint","i","=","tile","*"] tokens
  let (tileWidth,rest) ←natural rest
  let rest ←acceptMany ["+","tid",";","i","<","min","(","uint","(","V",")",",","(","tile","+"] rest
  let (tileAdvance,rest) ←natural rest
  let rest ←acceptMany [")","*"] rest
  let (boundWidth,rest) ←natural rest
  let rest ←acceptMany [")",";","i","+","="] rest
  let (stride,rest) ←natural rest
  let rest ←acceptMany [")","{"] rest
  if rest=[] then some ⟨tileWidth,tileAdvance,boundWidth,stride⟩ else none

def parse (source : String) : Option Header := do parseTokens (←tokenize source)
def sourceHeader : String := "for (uint i = tile * 1024 + tid; i < min(uint(V), (tile + 1) * 1024); i += 128) {"
def sourceTokens : Tokens := ["for","(","uint","i","=","tile","*","1024","+","tid",";","i","<","min","(","uint","(","V",")",",","(","tile","+","1",")","*","1024",")",";","i","+","=","128",")","{"]
def header : Header := ⟨1024,1,1024,128⟩
theorem lexed : tokenize sourceHeader=some sourceTokens := by decide +kernel
theorem parsed : parse sourceHeader=some header := by
  simp only [parse,lexed]
  decide +kernel

-- Native uint initializers, bounds and increments execute as 32-bit words.
def start (h : Header) (tile : Fin 243) (thread : Fin 128) : Nat :=
  ((BitVec.ofNat 32 tile.val)*(BitVec.ofNat 32 h.tileWidth)+BitVec.ofNat 32 thread.val).toNat
def upper (h : Header) (tile : Fin 243) : Nat :=
  min (BitVec.ofNat 32 248320).toNat
    (((BitVec.ofNat 32 tile.val)+BitVec.ofNat 32 h.tileAdvance)*BitVec.ofNat 32 h.boundWidth).toNat
def condition (h : Header) (tile : Fin 243) (index : Nat) : Bool :=
  decide ((BitVec.ofNat 32 index).toNat<upper h tile)
def advance (h : Header) (index : Nat) : Nat :=
  (BitVec.ofNat 32 index+BitVec.ofNat 32 h.stride).toNat

inductive Runs (h : Header) (tile : Fin 243) : Nat → List Nat → Prop where
  | stop (ended : condition h tile current=false) : Runs h tile current []
  | next (entered : condition h tile current=true) (rest : Runs h tile (advance h current) indices) :
      Runs h tile current (current::indices)

-- This Nat relation is only a proof aid. Its refinement below discharges
-- the word arithmetic and evaluates the actual parsed uint loop controls.
inductive NaturalRuns (upper stride : Nat) : Nat → List Nat → Prop where
  | stop (ended : upper≤current) : NaturalRuns upper stride current []
  | next (entered : current<upper) (rest : NaturalRuns upper stride (current+stride) indices) :
      NaturalRuns upper stride current (current::indices)

def visits (start stride count : Nat) : List Nat := (List.range count).map (fun k => start+k*stride)

theorem visits_succ (start stride count : Nat) : visits start stride (count+1)=start::visits (start+stride) stride count := by
  simp only [visits,List.range_succ_eq_map,List.map_cons,List.map_map,Nat.zero_mul,Nat.add_zero]
  congr 1
  apply List.map_congr_left
  intro k _
  dsimp only [Function.comp_def]
  rw [Nat.succ_mul]
  omega

theorem natural_run (count start upper stride : Nat) (ended : upper≤start+count*stride) :
    NaturalRuns upper stride start ((visits start stride count).filter (fun i => i<upper)) := by
  induction count generalizing start with
  | zero => exact .stop (by simpa [visits] using ended)
  | succ count ih =>
    simp only [Nat.succ_mul] at ended
    rw [visits_succ]
    by_cases entered : start<upper
    · simp only [List.filter_cons,decide_eq_true_eq,entered,ite_true]
      exact .next entered (ih (start+stride) (by omega))
    · have empty : (visits start stride count.succ).filter (fun i => i<upper)=[] := by
        apply List.filter_eq_nil_iff.mpr
        intro i member
        obtain ⟨k,_,rfl⟩ := List.mem_map.mp member
        simp [show ¬start+k*stride<upper by omega]
      rw [visits_succ] at empty
      rw [empty]
      exact .stop (by omega)

theorem start_eq (tile : Fin 243) (thread : Fin 128) : start header tile thread=tile.val*1024+thread.val := by
  have t : tile.val<4294967296 := by have := tile.isLt; omega
  have r : thread.val<4294967296 := by have := thread.isLt; omega
  have p : tile.val*1024<4294967296 := by have := tile.isLt; omega
  have s : tile.val*1024+thread.val<4294967296 := by have := tile.isLt; have := thread.isLt; omega
  simp [start,header,BitVec.toNat_add,BitVec.toNat_mul,BitVec.toNat_ofNat,Nat.mod_eq_of_lt t,
    Nat.mod_eq_of_lt r,Nat.mod_eq_of_lt p,Nat.mod_eq_of_lt s]

theorem upper_eq (tile : Fin 243) : upper header tile=min 248320 ((tile.val+1)*1024) := by
  have t : tile.val<4294967296 := by have := tile.isLt; omega
  have a : tile.val+1<4294967296 := by have := tile.isLt; omega
  have p : (tile.val+1)*1024<4294967296 := by have := tile.isLt; omega
  simp [upper,header,BitVec.toNat_mul,BitVec.toNat_add,BitVec.toNat_ofNat,Nat.mod_eq_of_lt t,
    Nat.mod_eq_of_lt a,Nat.mod_eq_of_lt p]

theorem advance_eq (index : Nat) (small : index+128<2^32) : advance header index=index+128 := by
  have first : index<4294967296 := by change index+128<4294967296 at small; omega
  change index+128<4294967296 at small
  simp [advance,header,BitVec.toNat_add,BitVec.toNat_ofNat,Nat.mod_eq_of_lt first,Nat.mod_eq_of_lt small]

theorem condition_eq (tile : Fin 243) (index : Nat) (small : index<2^32) :
    condition header tile index=decide (index<min 248320 ((tile.val+1)*1024)) := by
  unfold condition
  rw [upper_eq]
  simp only [BitVec.toNat_ofNat,Nat.mod_eq_of_lt small]

theorem refines (tile : Fin 243) (run : NaturalRuns (min 248320 ((tile.val+1)*1024)) 128 initial indices)
    (small : initial<2^32) : Runs header tile initial indices := by
  induction run with
  | stop ended => exact .stop (by rw [condition_eq tile _ small]; simp only [decide_eq_false_iff_not]; omega)
  | @next current indices entered rest ih =>
    have smallNext : current+128<2^32 := by have := min_le_left 248320 ((tile.val+1)*1024); omega
    refine .next (by rw [condition_eq tile _ small]; exact decide_eq_true entered) ?_
    rw [advance_eq current smallNext]
    exact ih smallNext

theorem finRange_values (n : Nat) : (List.finRange n).map Fin.val=List.range n := by
  induction n with
  | zero => rfl
  | succ n ih =>
    rw [List.finRange_succ,List.range_succ_eq_map]
    simpa only [List.map_cons,List.map_map,Fin.val_zero,Fin.val_succ,Function.comp_def] using
      congrArg (List.cons 0) (congrArg (List.map Nat.succ) ih)

theorem offsets_eq (tile : Fin 243) (thread : Fin 128) :
    NormalizedArgmaxLayout.partialOffsets tile thread=
      (visits (tile.val*1024+thread.val) 128 8).filter (fun i => i<min 248320 ((tile.val+1)*1024)) := by
  have mapped : (List.finRange 8).map (NormalizedArgmaxLayout.partialOffset tile thread)=
      visits (tile.val*1024+thread.val) 128 8 := by
    rw [visits,←finRange_values,List.map_map]
    rfl
  unfold NormalizedArgmaxLayout.partialOffsets
  rw [←mapped]
  apply List.filter_congr
  intro index member
  obtain ⟨visit,_,rfl⟩ := List.mem_map.mp member
  exact Bool.eq_iff_iff.mpr (by simp only [decide_eq_true_eq]; exact (NormalizedArgmaxLayout.loop_condition tile thread visit).symm)

theorem selected_run (tile : Fin 243) (thread : Fin 128) :
    Runs header tile (start header tile thread) (NormalizedArgmaxLayout.partialOffsets tile thread) := by
  rw [start_eq,offsets_eq]
  apply refines
  · apply natural_run
    have := min_le_right 248320 ((tile.val+1)*1024)
    omega
  · have := tile.isLt; have := thread.isLt; omega

def ParsedRuns (source : String) (tile : Fin 243) (thread : Fin 128) (indices : List Nat) : Prop :=
  ∃ h, parse source=some h ∧ Runs h tile (start h tile thread) indices

theorem source_visits (tile : Fin 243) (thread : Fin 128) :
    ParsedRuns sourceHeader tile thread (NormalizedArgmaxLayout.partialOffsets tile thread) :=
  ⟨header,parsed,selected_run tile thread⟩

variable {logits : Fin 248320 → ArrayStorage.BF} {platform : LogSumExpRanges.Platform}
  {source : ArrayStorage.BFBuffer logits} (lse : LogSumExpMemory.Execution platform source)

theorem source_lane (primitive : LogSumExpRanges.Primitives platform)
    (bound : ∀ i, FloatLib.Floats.Formats.BinaryInterchange.Model.isFinite (logits i)=true ∧
      |FloatLib.Floats.Formats.BinaryInterchange.Model.toReal (logits i)|≤(2:ℝ)^(23:Nat))
    (tile : Fin 243) (thread : Fin 128) :
    ParsedRuns sourceHeader tile thread (NormalizedArgmaxLayout.partialOffsets tile thread) ∧
    (NormalizedScoreSourceMemory.laneValues lse tile thread).map (fun values => ArgmaxPairs.scan values ArgmaxPairs.sentinel)=
      some (NormalizedArgmaxExecution.partialLane (NormalizedArgmaxMemory.candidates lse) tile thread) :=
  ⟨source_visits tile thread,NormalizedScoreSourceMemory.lane_scan_eq lse primitive bound tile thread⟩

end Inference.Kernels.Sampling.ArgmaxTraversalSource

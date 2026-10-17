import kernels.quantization.MlxQmvFast4Syntax
import kernels.quantization.AffineOuter4Source
namespace Inference.Kernels.Quantization.MlxQmvFast4LoopSource
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open MlxQmvFast4Syntax
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] parseHeader parseInitial parseInner

def offsets : Nat → Nat → List Nat
  | 0,_ => []
  | fuel+1,start => start::offsets fuel (start+512)

theorem visits_offsets (fuel start : Nat) :
    AffineInput4Source.visits fuel start (start+fuel*512) 512=some (offsets fuel start) := by
  induction fuel generalizing start with
  | zero => simp [AffineInput4Source.visits,offsets]
  | succ fuel ih =>
    have entered : start<start+(fuel+1)*512 := by omega
    have bound : start+(fuel+1)*512=(start+512)+fuel*512 := by omega
    simp only [AffineInput4Source.visits,ite_eq_left entered,offsets]
    rw [bound,ih]
    rfl

theorem offsets_append (fuel start : Nat) : offsets (fuel+1) start=offsets fuel start++[start+fuel*512] := by
  induction fuel generalizing start with
  | zero => simp [offsets]
  | succ fuel ih =>
    change start::offsets (fuel+1) (start+512)=(start::offsets fuel (start+512))++[start+(fuel+1)*512]
    rw [ih]
    have same : start+512+fuel*512=start+(fuel+1)*512 := by omega
    simp only [same,List.cons_append]

theorem offsets_range (steps : Nat) : offsets steps 0=(List.finRange steps).map (fun i => i.val*512) := by
  induction steps with
  | zero => rfl
  | succ steps ih => simp [offsets_append,ih,List.finRange_succ_last,List.map_map]

def stepIndex (steps k : Nat) : Option (Fin steps) :=
  if h : k%512=0 ∧ k/512<steps then some ⟨k/512,h.2⟩ else none

theorem step_index (step : Fin steps) : stepIndex steps (step.val*512)=some step := by
  simp [stepIndex,step.isLt]

def sourceIndices (steps : Nat) : Option (List (Fin steps)) := do
  let h ←parseHeader headerSource
  let indices ←AffineInput4Source.visits steps h.start (steps*512) h.stride
  indices.mapM (stepIndex steps)

private theorem mapM_some {α β : Type} (items : List α) (f : α → Option β) (g : α → β)
    (same : ∀ item∈items, f item=some (g item)) : items.mapM f=some (items.map g) := by
  induction items with
  | nil => rfl
  | cons item rest ih =>
    simp only [List.mapM_cons,same item (by simp),List.map_cons]
    rw [ih (fun value member => same value (by simp [member]))]
    rfl

private theorem mapM_map {α β γ : Type} (items : List α) (f : α → β) (g : β → Option γ) :
    (items.map f).mapM g=items.mapM (fun item => g (f item)) := by
  induction items with
  | nil => rfl
  | cons item rest ih => simp only [List.map_cons,List.mapM_cons,ih]

theorem source_indices (steps : Nat) : sourceIndices steps=some (List.finRange steps) := by
  have visits := visits_offsets steps 0
  simp only [Nat.zero_add] at visits
  simp only [sourceIndices,parsed_header]
  change (do let indices ←AffineInput4Source.visits steps 0 (steps*512) 512
             indices.mapM (stepIndex steps))=_
  rw [visits,offsets_range]
  change ((List.finRange steps).map (fun i => i.val*512)).mapM (stepIndex steps)=_
  rw [mapM_map]
  simpa only [List.map_id] using mapM_some (List.finRange steps) (fun i => stepIndex steps (i.val*512)) id
    (fun i _ => step_index i)

abbrev Bank := Fin 4 → Float32

def rowUpdate (call : Fin 4 → Option Float32) (bank : Bank) (offset : Fin 4) : Option Bank := do
  let value ←call offset
  pure (fun target => if target=offset then FlushToZero.add (bank target) value else bank target)
def innerVisits : Option (List (Fin 4)) := do
  let initial ←parseInner innerSource
  AffineOutputSource.visits 4 initial 4
theorem inner_visits : innerVisits=some (List.finRange 4) := by
  rw [innerVisits,parsed_inner]
  decide +kernel

def sourceStep (call : Fin 4 → Option Float32) (bank : Bank) : Option Bank := do
  let rows ←innerVisits
  rows.foldlM (rowUpdate call) bank

def bankStep (tile : Fin 4 → Float32) (bank : Bank) : Bank := fun row => FlushToZero.add (bank row) (tile row)

theorem source_step (call : Fin 4 → Option Float32) (tile : Fin 4 → Float32)
    (same : ∀ row, call row=some (tile row)) (bank : Bank) : sourceStep call bank=some (bankStep tile bank) := by
  unfold sourceStep
  rw [inner_visits]
  change ([0,1,2,3] : List (Fin 4)).foldlM (rowUpdate call) bank=_
  simp only [List.foldlM_cons,List.foldlM_nil,rowUpdate,same,bind,Option.bind]
  apply congrArg some
  funext row
  fin_cases row <;> rfl

attribute [local irreducible] sourceStep

theorem fold_steps (indices : List (Fin steps)) (call : Fin steps → Fin 4 → Option Float32)
    (tile : Fin steps → Fin 4 → Float32) (same : ∀ step row,call step row=some (tile step row)) (bank : Bank) :
    indices.foldlM (fun bank step => sourceStep (call step) bank) bank=
      some (indices.foldl (fun bank step => bankStep (tile step) bank) bank) := by
  induction indices generalizing bank with
  | nil => rfl
  | cons step rest ih =>
    simp only [List.foldlM_cons,List.foldl_cons,source_step (call step) (tile step) (same step)]
    exact ih _

theorem fold_bank (indices : List (Fin steps)) (tile : Fin steps → Fin 4 → Float32) (bank : Bank) (row : Fin 4) :
    (indices.foldl (fun bank step => bankStep (tile step) bank) bank) row=
      indices.foldl (fun acc step => FlushToZero.add acc (tile step row)) (bank row) := by
  induction indices generalizing bank with
  | nil => rfl
  | cons step rest ih => exact ih _

def sourceLoop (call : Fin steps → Fin 4 → Option Float32) : Option Bank := do
  let initial ←parseInitial initialSource
  let indices ←sourceIndices steps
  indices.foldlM (fun bank step => sourceStep (call step) bank) (fun _ => Float32.ofInt initial)

theorem source_loop (call : Fin steps → Fin 4 → Option Float32) (tile : Fin steps → Fin 4 → Float32)
    (same : ∀ step row,call step row=some (tile step row)) :
    sourceLoop call=some (fun row => AffineRow.laneValue (fun step (_ : Fin 32) => tile step row) 0) := by
  simp only [sourceLoop,parsed_initial,source_indices]
  change (List.finRange steps).foldlM _ (fun _ => (0 : Float32))=_
  rw [fold_steps _ call tile same]
  apply congrArg some
  funext row
  exact fold_bank _ tile _ row

end Inference.Kernels.Quantization.MlxQmvFast4LoopSource

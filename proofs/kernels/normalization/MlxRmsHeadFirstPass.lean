import kernels.normalization.MlxRmsHeadMemory

namespace Inference.Kernels.Normalization.MlxRmsHeadFirstPass
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange NormalizationSchedule.threadColumns

def visits (iteration : Nat) (thread : Fin 64) : List (Fin 256) :=
  (List.finRange 4).filterMap (fun i => NormalizationSchedule.columnIndex 256 ⟨iteration,thread,i⟩)

theorem late_empty (iteration : Nat) (late : 1 ≤ iteration) (thread : Fin 64) : visits iteration thread=[] := by
  apply List.filterMap_eq_nil_iff.mpr
  intro i _
  have outside : ¬NormalizationSchedule.address (NormalizationSchedule.Visit.mk iteration thread i)<256 := by
    change ¬(iteration*256+thread.val*4+i.val<256)
    omega
  simp only [NormalizationSchedule.columnIndex,dite_eq_right outside]

theorem threadColumns_full (thread : Fin 64) :
    NormalizationSchedule.threadColumns 256 thread=(List.finRange 4).map (RmsHeadReads.coordinate thread) := by
  have flat : NormalizationSchedule.threadColumns 256 thread=
      (List.finRange 256).flatMap (fun iteration => visits iteration.val thread) := by
    simp only [NormalizationSchedule.threadColumns,List.product,List.map_flatMap,List.map_map,
      List.filterMap_flatMap,Function.comp_def,visits,List.filterMap_map]
  rw [flat,@List.finRange_succ 255,List.flatMap_cons,List.flatMap_map]
  have tail : (List.finRange 255).flatMap (fun iteration => visits iteration.succ.val thread)=[] := by
    apply List.flatMap_eq_nil_iff.mpr
    intro iteration _
    exact late_empty _ (by simp only [Fin.val_succ]; omega) thread
  simp only [Fin.val_zero,tail,List.append_nil]
  unfold visits
  have conversion : (fun i : Fin 4 => NormalizationSchedule.columnIndex 256 (NormalizationSchedule.Visit.mk 0 thread i))=
      (fun i => some (RmsHeadReads.coordinate thread i)) := by
    funext i
    have bound : NormalizationSchedule.address (NormalizationSchedule.Visit.mk 0 thread i)<256 := by
      change 0*256+thread.val*4+i.val<256
      have := thread.isLt; have := i.isLt; omega
    rw [NormalizationSchedule.columnIndex,dite_eq_left bound]
    congr 1
    apply Fin.ext
    simp [NormalizationSchedule.address,RmsHeadReads.coordinate]
  rw [conversion]
  simp

variable {heads base : Nat} {values : Fin heads → Fin 256 → ArrayStorage.BF} {weight : Fin 256 → ArrayStorage.BF}
  (input : RmsHeadsMemory.Input values weight base)

def source (head : Fin heads) (thread : Fin 64) : Nat := base+2*(head.val*256+thread.val*4)

theorem loaded (head : Fin heads) (thread : Fin 64) (i : Fin 4) :
    MlxRmsHeadRegisters.loaded (source (base:=base) head thread) input.source.memory i=
      RmsHeadsMemory.sourceValues input head (RmsHeadReads.coordinate thread i) := by
  have address : source (base:=base) head thread+2*i.val=
      (RmsHeadReads.layout heads base).base head+2*(RmsHeadReads.coordinate thread i).val := by
    dsimp only [source,RmsHeadReads.layout,RmsHeadReads.coordinate]
    omega
  unfold MlxRmsHeadRegisters.loaded
  rw [address,←input.source.addresses head,←input.source.shared head]
  rfl

def localValue (contracted : Bool) (head : Fin heads) (thread : Fin 64) : Float32 :=
  (MlxRmsHeadRegisters.captured contracted (source (base:=base) head thread) input.source.memory).acc

theorem local_eq (contracted : Bool) (head : Fin heads) (thread : Fin 64) :
    localValue input contracted head thread=
      NormalizationReduction.threadSum contracted (RmsHeadsMemory.sourceValues input head) thread := by
  unfold localValue MlxRmsHeadRegisters.captured
  rw [MlxRmsHeadRegisters.accumulator]
  unfold NormalizationReduction.threadSum
  rw [threadColumns_full,List.foldl_map]
  have operation : (fun acc i => MlxRmsHeadRegisters.step contracted
      (MlxRmsHeadRegisters.loaded (source (base:=base) head thread) input.source.memory i) acc)=
      (fun acc i => SquaredSum.arithmeticStep contracted (RmsHeadsMemory.sourceValues input head) acc
        (RmsHeadReads.coordinate thread i)) := by
    funext acc i
    rw [loaded input head thread i]
    rfl
  rw [operation]
  rfl

-- Each source thread's accumulator is constructed from its current captured
-- row. The selected full loop has exactly the source-order four iterations.
theorem source_local (headBound : heads≤2^32) (contracted : Bool) (head : Fin heads) (thread : Fin 64) :
    ∃ after, MlxRmsHeadMemory.captureSource (base:=base) contracted head thread input.source.memory=some after ∧
      MlxRmsHeadRegisters.Captures contracted (source (base:=base) head thread) input.source.memory
        (List.finRange 4) MlxRmsHeadRegisters.initial after ∧
      after.acc=NormalizationReduction.threadSum contracted (RmsHeadsMemory.sourceValues input head) thread := by
  obtain ⟨after,parsed,cells,cache⟩ := MlxRmsHeadMemory.capture_execution input headBound contracted head thread input.source.memory
  have deterministic : after=MlxRmsHeadRegisters.captured contracted (source (base:=base) head thread) input.source.memory := by
    unfold MlxRmsHeadMemory.captureSource at parsed
    rw [MlxRmsHeadSyntax.parsed_branch] at parsed
    have pointer := (MlxRmsHeadPointers.selected_pointers input headBound head thread).1
    have full : (thread.val*4+4)%4294967296≤256 :=
      (Nat.mod_le _ _).trans (MlxRmsHeadHostSelection.full_block thread)
    simp [pointer,full] at parsed
    exact parsed.symm
  exact ⟨after,parsed,cells,deterministic ▸ local_eq input contracted head thread⟩


theorem captures_eq (contracted : Bool) (source : Nat) (memory : HalfMemory.Bytes)
    {offsets : List (Fin 4)} {before after : MlxRmsHeadRegisters.State}
    (actual : MlxRmsHeadRegisters.Captures contracted source memory offsets before after) :
    after=MlxRmsHeadRegisters.run contracted source memory offsets before := by
  induction actual with
  | nil => rfl
  | @next i before middle offsets after body rest ih =>
    have same := Option.some.inj (body.symm.trans (MlxRmsHeadRegisters.capture_execution contracted source memory i before))
    subst middle
    exact ih

-- This is the source accumulator at an actual capture event after arbitrary
-- legal writes by other heads, rather than only the canonical initial heap.
theorem current_local {p : RmsNorm.Platform} {width eps : Float32}
    (execution : RmsHeadsMemory.Execution input p width eps) (state : RmsHeadReads.Machine heads)
    (valid : MlxRmsHeadMemory.Invariant input execution state) (head : Fin heads) (thread : Fin 64)
    (pending : state.registers head thread=none) (after : MlxRmsHeadRegisters.State)
    (cells : MlxRmsHeadRegisters.Captures p.contracted (source (base:=base) head thread) state.memory
      (List.finRange 4) MlxRmsHeadRegisters.initial after) :
    after.acc=NormalizationReduction.threadSum p.contracted (RmsHeadsMemory.sourceValues input head) thread := by
  have notReady : ¬ReadBeforeOverwrite.Ready state head := fun ready => ready thread pending
  have raw := RmsHeadReads.read_local heads base state.memory input.source.memory head
    (valid.captured.pending head notReady) thread
  have sameLoad (i : Fin 4) : MlxRmsHeadRegisters.loaded (source (base:=base) head thread) state.memory i=
      MlxRmsHeadRegisters.loaded (source (base:=base) head thread) input.source.memory i := by
    have bytes := congrFun raw i
    have address : source (base:=base) head thread+2*i.val=
        (RmsHeadReads.layout heads base).base head+2*(RmsHeadReads.coordinate thread i).val := by
      dsimp only [source,RmsHeadReads.layout,RmsHeadReads.coordinate]
      omega
    unfold MlxRmsHeadRegisters.loaded
    rw [address]
    exact congrArg (fun bits : BitVec 16 => BFloat16.widen (Model.ofBits bits)) bytes
  rw [captures_eq _ _ _ cells,MlxRmsHeadRegisters.accumulator]
  have original := local_eq input p.contracted head thread
  unfold localValue MlxRmsHeadRegisters.captured at original
  rw [MlxRmsHeadRegisters.accumulator] at original
  rw [←original]
  congr 1
  funext acc i
  rw [sameLoad i]

end Inference.Kernels.Normalization.MlxRmsHeadFirstPass

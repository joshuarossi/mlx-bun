import host.ts.RenameRetainedRebase
import host.ts.RenameAnnotatedLoop

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

namespace CachePhase

def advanced (time : SymE) : SymE := .bin .add time (.lit (F64.ofNat 1))

/-- A completed layer advances only its own cache occurrence. -/
def meaning (owners : List Nat) (completed : Nat) (time : SymE) (owner : Nat) : SymE :=
  if owner ∈ owners.take completed then advanced time else time

theorem initial (owners : List Nat) (time : SymE) (owner : Nat) :
    meaning owners 0 time owner = time := by simp [meaning]

theorem complete (owners : List Nat) (time : SymE) (owner : Nat) (member : owner ∈ owners) :
    meaning owners owners.length time owner = advanced time := by simp [meaning,member]

theorem next_unadvanced (owners : List Nat) (completed owner : Nat) (time : SymE)
    (distinct : owners.Nodup) (selected : owners[completed]? = some owner) :
    meaning owners completed time owner = time := by
  have suffix : owner ∈ owners.drop completed := List.mem_of_getElem? (i:=0) (by
    simpa only [List.getElem?_drop,Nat.add_zero] using selected)
  have absent : owner ∉ owners.take completed := by
    intro inPrefix
    exact (distinct.rel_of_mem_take_of_mem_drop inPrefix suffix) rfl
  exact ite_eq_right absent

theorem advanced_eval (ν : Nat → F64) (time : SymE) (index : Nat)
    (current : time.eval ν = F64.ofNat index) (bound : index+1 < 2^53) :
    (advanced time).eval ν = F64.ofNat (index+1) := by
  simp only [advanced,SymE.eval,current]
  exact F64.add_ofNat53 index 1 bound

end CachePhase

/-- Canonical offset annotations for a layer prefix. Other public fields,
including every capacity field, retain their existing annotations. -/
def PublicNotes.cachePhase (notes : PublicNotes) (owners : List Nat) (completed : Nat) (time : SymE) : PublicNotes :=
  ⟨fun a name => if a ∈ owners ∧ pack name = pack chars!"offset" then
    some (.literal (CachePhase.meaning owners completed time a)) else notes.fields a name⟩

theorem PublicNotes.cachePhase_selected (notes : PublicNotes) (owners : List Nat) (completed : Nat)
    (time : SymE) (owner : Nat) (member : owner ∈ owners) :
    (notes.cachePhase owners completed time).fields owner chars!"offset" =
      some (.literal (CachePhase.meaning owners completed time owner)) := by
  simp only [cachePhase,member,and_self,ite_true]

theorem PublicNotes.cachePhase_other (notes : PublicNotes) (owners : List Nat) (completed : Nat)
    (time : SymE) (owner : Nat) (name : Name)
    (different : owner ∉ owners ∨ pack name ≠ pack chars!"offset") :
    (notes.cachePhase owners completed time).fields owner name = notes.fields owner name := by
  have absent : ¬ (owner ∈ owners ∧ pack name = pack chars!"offset") := by
    intro both
    rcases different with outside | field
    · exact outside both.1
    · exact field both.2
  exact ite_eq_right absent

/-- This is the exact annotation effect required from one actual layer
summary. It asserts no execution or future read. -/
theorem PublicNotes.cachePhase_write (notes : PublicNotes) (owners : List Nat) (completed owner : Nat)
    (time : SymE) (selected : owners[completed]? = some owner) :
    (notes.cachePhase owners completed time).write owner chars!"offset" (.literal (CachePhase.advanced time)) =
      notes.cachePhase owners (completed+1) time := by
  have member : owner ∈ owners := List.mem_of_getElem? selected
  apply congrArg PublicNotes.mk
  funext a name
  simp only [cachePhase,CachePhase.meaning,List.take_add_one,selected,
    Option.toList_some,List.mem_append,List.mem_singleton]
  by_cases same : a = owner
  · subst a
    by_cases field : pack name = pack chars!"offset"
    · simp only [field,member,and_self,ite_true,or_true]
    · simp only [field,and_false,ite_false]
  · simp only [same,or_false,false_and,ite_false]

def RetainedNotes.cachePhase (notes : RetainedNotes) (owners : List Nat) (completed : Nat) (time : SymE) : RetainedNotes :=
  {notes with publicFields := notes.publicFields.cachePhase owners completed time}

theorem RetainedNotes.cachePhase_write (notes : RetainedNotes) (owners : List Nat) (completed owner : Nat)
    (time : SymE) (selected : owners[completed]? = some owner) :
    {(notes.cachePhase owners completed time) with publicFields :=
      (notes.cachePhase owners completed time).publicFields.write owner chars!"offset" (.literal (CachePhase.advanced time))} =
      notes.cachePhase owners (completed+1) time := by
  simp only [cachePhase,PublicNotes.cachePhase_write notes.publicFields owners completed owner time selected]

private theorem literal_retag {ν : Nat → F64} {C : CSrv} {R : Ren} {oldTime newTime : SymE} {value : Val}
    (same : oldTime.eval ν = newTime.eval ν) (held : (Value.literal oldTime).Holds ν C R value) :
    (Value.literal newTime).Holds ν C R value := by
  cases held with | literal _ value denotation =>
    exact .literal _ value (by simpa only [NumDenote,same] using denotation)

/-- Completion becomes phase zero only after proving the increment equation
for both current valuations. Literal representation and actual public data
come from the retained inventory. -/
theorem PublicInventory.cachePhase_restart {S : Type} {notes : PublicNotes} {owners : List Nat}
    {time nextTime : SymE} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live : Nat → Prop} {s₀ s : St S}
    (held : PublicInventory (notes.cachePhase owners owners.length time) ν₀ ν C₀ C R live s₀ s)
    (sourceStep : (CachePhase.advanced time).eval ν₀ = nextTime.eval ν₀)
    (targetStep : (CachePhase.advanced time).eval ν = nextTime.eval ν) :
    PublicInventory (notes.cachePhase owners 0 nextTime) ν₀ ν C₀ C R live s₀ s := by
  constructor
  · intro a name role entry
    by_cases selected : a ∈ owners ∧ pack name = pack chars!"offset"
    · exact held.keyLive a name (.literal (CachePhase.advanced time)) (by
        simp only [PublicNotes.cachePhase,selected,and_self,ite_true,CachePhase.complete _ _ _ selected.1])
    · exact held.keyLive a name role (by
        simpa only [PublicNotes.cachePhase,selected,ite_false] using entry)
  · intro a name role entry
    by_cases selected : a ∈ owners ∧ pack name = pack chars!"offset"
    · have same : Value.literal nextTime = role := Option.some.inj (by
        simpa only [PublicNotes.cachePhase,selected,and_self,ite_true,CachePhase.initial] using entry)
      subst role
      obtain ⟨value,data,meaning⟩ := held.source a name (.literal (CachePhase.advanced time)) (by
        simp only [PublicNotes.cachePhase,selected,and_self,ite_true,CachePhase.complete _ _ _ selected.1])
      exact ⟨value,data,literal_retag sourceStep meaning⟩
    · exact held.source a name role (by
        simpa only [PublicNotes.cachePhase,selected,ite_false] using entry)
  · intro a name role entry
    by_cases selected : a ∈ owners ∧ pack name = pack chars!"offset"
    · have same : Value.literal nextTime = role := Option.some.inj (by
        simpa only [PublicNotes.cachePhase,selected,and_self,ite_true,CachePhase.initial] using entry)
      subst role
      obtain ⟨value,data,meaning⟩ := held.target a name (.literal (CachePhase.advanced time)) (by
        simp only [PublicNotes.cachePhase,selected,and_self,ite_true,CachePhase.complete _ _ _ selected.1])
      exact ⟨value,data,literal_retag targetStep meaning⟩
    · exact held.target a name role (by
        simpa only [PublicNotes.cachePhase,selected,ite_false] using entry)

theorem RetainedInventory.cachePhase_restart {S : Type} {notes : RetainedNotes} {owners : List Nat}
    {time nextTime : SymE} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live : Nat → Prop} {s₀ s : St S}
    (held : RetainedInventory (notes.cachePhase owners owners.length time) ν₀ ν C₀ C R live s₀ s)
    (sourceStep : (CachePhase.advanced time).eval ν₀ = nextTime.eval ν₀)
    (targetStep : (CachePhase.advanced time).eval ν = nextTime.eval ν) :
    RetainedInventory (notes.cachePhase owners 0 nextTime) ν₀ ν C₀ C R live s₀ s :=
  ⟨held.runtime,held.privates,held.captures,held.arrays,
    held.publicFields.cachePhase_restart sourceStep targetStep,held.buffers⟩

end Host.Ts.Owned.Annotated

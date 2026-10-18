import host.ts.renameOrdinary.RankOriginCacheInventory
import host.ts.RenameLoopVariableNamespace

set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin.CacheEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

private theorem fold_selected (timeMeaning : SymE) (owners : List Nat) (notes : PublicNotes) (owner : Nat) :
    (owners.foldl (fun current selected => current.write selected chars!"offset" (.literal (offsetMeaning timeMeaning selected))) notes).fields
      owner chars!"offset" =
      if owner ∈ owners then some (.literal (offsetMeaning timeMeaning owner)) else notes.fields owner chars!"offset" := by
  induction owners generalizing notes with
  | nil => rfl
  | cons selected owners ih =>
    rw [List.foldl_cons,ih]
    by_cases later : owner ∈ owners
    · simp only [later,ite_true,List.mem_cons,or_true]
    · simp only [later,ite_false,List.mem_cons,or_false]
      by_cases same : owner = selected
      · subst owner
        simp only [PublicNotes.write,and_self,ite_true]
      · simp only [PublicNotes.write,same,false_and,ite_false]

theorem seed_offset_selected (timeMeaning : SymE) (notes : PublicNotes) (owner : Nat)
    (selected : owner ∈ cacheOwners) :
    (seedOffsets timeMeaning notes).fields owner chars!"offset" = some (.literal (offsetMeaning timeMeaning owner)) := by
  rw [seedOffsets,fold_selected,ite_eq_left selected]

private theorem offset_meanings_equal {ν : Nat → F64} {oldTime newTime : SymE}
    (same : oldTime.eval ν = newTime.eval ν) (owner : Nat) :
    (offsetMeaning oldTime owner).eval ν = (offsetMeaning newTime owner).eval ν := by
  by_cases active : owner = 2672298
  · simp only [offsetMeaning,ite_eq_left active,SymE.eval,same]
  · simpa only [offsetMeaning,ite_eq_right active] using same

private theorem literal_retag {ν : Nat → F64} {C : CSrv} {R : Ren} {oldRole newRole : SymE} {value : Val}
    (same : oldRole.eval ν = newRole.eval ν) (held : (Value.literal oldRole).Holds ν C R value) :
    (Value.literal newRole).Holds ν C R value := by
  cases held with
  | literal _ value denotation =>
    exact .literal _ value (by simpa only [NumDenote,same] using denotation)

private theorem field_retag {S : Type} {ν : Nat → F64} {C : CSrv} {R : Ren} {oldTime newTime : SymE}
    {owner : Nat} {s : St S}
    (same : oldTime.eval ν = newTime.eval ν)
    (held : PublicFieldHolds (.literal (offsetMeaning oldTime owner)) ν C R owner chars!"offset" s) :
    PublicFieldHolds (.literal (offsetMeaning newTime owner)) ν C R owner chars!"offset" s := by
  obtain ⟨value,field,role⟩ := held
  exact ⟨value,field,literal_retag (offset_meanings_equal same owner) role⟩

private theorem retag_list {S : Type} {notes : PublicNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live : Nat → Prop} {s₀ s : St S} {oldTime newTime : SymE}
    (original : PublicInventory notes ν₀ ν C₀ C R live s₀ s)
    (selected : ∀ owner ∈ cacheOwners, notes.fields owner chars!"offset" = some (.literal (offsetMeaning oldTime owner)))
    (sameSource : oldTime.eval ν₀ = newTime.eval ν₀) (sameTarget : oldTime.eval ν = newTime.eval ν)
    (owners : List Nat) (members : ∀ owner ∈ owners, owner ∈ cacheOwners)
    (current : PublicNotes) (held : PublicInventory current ν₀ ν C₀ C R live s₀ s) :
    PublicInventory
      (owners.foldl (fun current owner => current.write owner chars!"offset" (.literal (offsetMeaning newTime owner))) current)
      ν₀ ν C₀ C R live s₀ s := by
  induction owners generalizing current with
  | nil => exact held
  | cons owner owners ih =>
    have entry := selected owner (members owner (List.mem_cons_self ..))
    apply ih (fun a member => members a (List.mem_cons_of_mem owner member))
    exact held.annotate owner chars!"offset" (.literal (offsetMeaning newTime owner))
      (original.keyLive owner chars!"offset" _ entry)
      (field_retag sameSource (original.source owner chars!"offset" _ entry))
      (field_retag sameTarget (original.target owner chars!"offset" _ entry))

/-- Reinterpret an already retained literal offset occurrence. Its literal
representation is carried by the old annotation, while equality of current
meanings permits installing the independent loop expression. -/
theorem retag_offsets {S : Type} {notes : PublicNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live : Nat → Prop} {s₀ s : St S} {oldTime newTime : SymE}
    (held : PublicInventory notes ν₀ ν C₀ C R live s₀ s)
    (selected : ∀ owner ∈ cacheOwners, notes.fields owner chars!"offset" = some (.literal (offsetMeaning oldTime owner)))
    (sameSource : oldTime.eval ν₀ = newTime.eval ν₀) (sameTarget : oldTime.eval ν = newTime.eval ν) :
    PublicInventory (seedOffsets newTime notes) ν₀ ν C₀ C R live s₀ s :=
  retag_list held selected sameSource sameTarget cacheOwners (fun _ member => member) notes held

theorem retag_retained_offsets {S : Type} {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live : Nat → Prop} {s₀ s : St S} {oldTime newTime : SymE}
    (held : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (selected : ∀ owner ∈ cacheOwners, notes.publicFields.fields owner chars!"offset" = some (.literal (offsetMeaning oldTime owner)))
    (sameSource : oldTime.eval ν₀ = newTime.eval ν₀) (sameTarget : oldTime.eval ν = newTime.eval ν) :
    RetainedInventory (seededNotes newTime notes) ν₀ ν C₀ C R live s₀ s :=
  ⟨held.runtime,held.privates,held.captures,held.arrays,
    retag_offsets held.publicFields selected sameSource sameTarget,held.buffers⟩

end Host.Load.Run.Full.Ordinary.RankOrigin.CacheEntry

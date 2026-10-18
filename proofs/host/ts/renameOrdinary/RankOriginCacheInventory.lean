import host.ts.renameOrdinary.RankOriginCacheEntry
import host.ts.RenameRetainedInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.RankOrigin.CacheEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
variable (timeMeaning : SymE)

noncomputable def offsetObject (owner : Nat) : Host.Ts.Obj :=
  (input.obj? owner).getD ⟨.ordinary,.null,[],[],false⟩

theorem actual_offset_data (owner : Nat) (selected : owner ∈ cacheOwners) :
    PublicData input owner chars!"offset" (natV (offsetValue owner)) := by
  simp only [cacheOwners,List.mem_cons,List.not_mem_nil,or_false] at selected
  rcases selected with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · exact ⟨offsetObject 2672298,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672303,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672308,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672320,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672329,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672334,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672339,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672351,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672360,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672365,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672370,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672382,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672391,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672396,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672401,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672413,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672422,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672427,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672432,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672444,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672453,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672458,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672463,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672475,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672484,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672489,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672494,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672506,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672515,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672520,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672525,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672537,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672546,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672551,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672556,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672568,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672577,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672582,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672587,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672599,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672608,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672613,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672618,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672630,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672639,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672644,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672649,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672661,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672670,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672675,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672680,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672692,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672701,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672706,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672711,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672723,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672732,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672737,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672742,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672754,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672763,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672768,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672773,true,true,by host_kernel_rfl,by host_kernel_rfl⟩
  · exact ⟨offsetObject 2672785,true,true,by host_kernel_rfl,by host_kernel_rfl⟩

theorem offset_meaning_eval (ν : Nat → F64) (owner : Nat)
    (time : timeMeaning.eval ν = F64.ofNat 3) :
    (offsetMeaning timeMeaning owner).eval ν = F64.ofNat (offsetValue owner) := by
  by_cases active : owner = 2672298
  · simp only [offsetMeaning,offsetValue,ite_eq_left active,SymE.eval,time]
    rfl
  · simpa only [offsetMeaning,offsetValue,ite_eq_right active] using time

theorem offset_field_holds (ν : Nat → F64) (C : CSrv) (owner : Nat)
    (selected : owner ∈ cacheOwners) (time : timeMeaning.eval ν = F64.ofNat 3) :
    PublicFieldHolds (.literal (offsetMeaning timeMeaning owner)) ν C identity owner chars!"offset" input := by
  refine ⟨natV (offsetValue owner),actual_offset_data owner selected,?_⟩
  exact .literal _ _ (by
    change some (F64.ofNat (offsetValue owner)) = some ((offsetMeaning timeMeaning owner).eval ν)
    rw [offset_meaning_eval timeMeaning ν owner time])

def seedOffsets (notes : PublicNotes) : PublicNotes :=
  cacheOwners.foldl (fun current owner => current.write owner chars!"offset" (.literal (offsetMeaning timeMeaning owner))) notes

private theorem seed_list_inventory (owners : List Nat) (members : ∀ owner ∈ owners, owner ∈ cacheOwners)
    (notes : PublicNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (sourceTime : timeMeaning.eval ν₀ = F64.ofNat 3) (targetTime : timeMeaning.eval ν = F64.ofNat 3)
    (held : PublicInventory notes ν₀ ν C₀ C identity (fun a => a < input.next) input input) :
    PublicInventory
      (owners.foldl (fun current owner => current.write owner chars!"offset" (.literal (offsetMeaning timeMeaning owner))) notes)
      ν₀ ν C₀ C identity (fun a => a < input.next) input input := by
  induction owners generalizing notes with
  | nil => exact held
  | cons owner owners ih =>
    have selected := members owner (List.mem_cons_self ..)
    exact ih (fun a member => members a (List.mem_cons_of_mem owner member)) _
      (held.annotate owner chars!"offset" (.literal (offsetMeaning timeMeaning owner)) (offsets_live owner selected)
        (offset_field_holds timeMeaning ν₀ C₀ owner selected sourceTime) (offset_field_holds timeMeaning ν C owner selected targetTime))

theorem seed_offset_inventory (notes : PublicNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (sourceTime : timeMeaning.eval ν₀ = F64.ofNat 3) (targetTime : timeMeaning.eval ν = F64.ofNat 3)
    (held : PublicInventory notes ν₀ ν C₀ C identity (fun a => a < input.next) input input) :
    PublicInventory (seedOffsets timeMeaning notes) ν₀ ν C₀ C identity (fun a => a < input.next) input input :=
  seed_list_inventory timeMeaning cacheOwners (fun _ member => member) notes ν₀ ν C₀ C sourceTime targetTime held

def seededNotes (notes : RetainedNotes) : RetainedNotes :=
  {notes with publicFields := seedOffsets timeMeaning notes.publicFields}

/-- Seed the exact phase vector at the reached convolution entry. Runtime,
private, native-capture, array and byte notes are retained verbatim. -/
theorem seed_retained {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv}
    (held : RetainedInventory notes ν₀ ν C₀ C identity (fun a => a < input.next) input input)
    (sourceTime : timeMeaning.eval ν₀ = F64.ofNat 3) (targetTime : timeMeaning.eval ν = F64.ofNat 3) :
    RetainedInventory (seededNotes timeMeaning notes) ν₀ ν C₀ C identity (fun a => a < input.next) input input :=
  ⟨held.runtime,held.privates,held.captures,held.arrays,
    seed_offset_inventory timeMeaning notes.publicFields ν₀ ν C₀ C sourceTime targetTime held.publicFields,held.buffers⟩

private theorem fold_other (owners : List Nat) (notes : PublicNotes) (owner : Nat) (name : Name)
    (different : ∀ selected ∈ owners, owner ≠ selected ∨ pack name ≠ pack chars!"offset") :
    (owners.foldl (fun current selected => current.write selected chars!"offset" (.literal (offsetMeaning timeMeaning selected))) notes).fields owner name =
      notes.fields owner name := by
  induction owners generalizing notes with
  | nil => rfl
  | cons selected owners ih =>
    rw [List.foldl_cons,ih _ (fun a member => different a (List.mem_cons_of_mem selected member))]
    have notSelected : ¬ (owner = selected ∧ pack name = pack chars!"offset") := by
      rcases different selected (List.mem_cons_self ..) with unequal | unequal <;> exact fun equal => unequal (by first | exact equal.1 | exact equal.2)
    exact ite_eq_right notSelected

theorem seed_other_field (notes : PublicNotes) (owner : Nat) (name : Name)
    (different : owner ∉ cacheOwners ∨ pack name ≠ pack chars!"offset") :
    (seedOffsets timeMeaning notes).fields owner name = notes.fields owner name := by
  apply fold_other timeMeaning
  intro selected member
  rcases different with outside | otherName
  · exact Or.inl (fun equal => outside (equal ▸ member))
  · exact Or.inr otherName

end Host.Load.Run.Full.Ordinary.RankOrigin.CacheEntry

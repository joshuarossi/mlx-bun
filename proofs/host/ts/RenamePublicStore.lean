import host.ts.RenamePublicInventory
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

private theorem code_beq_false {a b : Nat} (different : a ≠ b) : Nat.beq a b = false := by
  cases result : Nat.beq a b with
  | false => rfl
  | true => exact False.elim (different (Nat.eq_of_beq_eq_true result))

/-- Ordered own-data replacement follows the interpreter's actual key codes. -/
theorem findProp_setPropL_code (query key : PKey) (value : PropV) (props : Props) :
    findProp query (setPropL key value props) = if query.code = key.code then some value else findProp query props := by
  simp only [findProp_eq_linear]
  induction props with
  | nil =>
    simp only [setPropL,findPropLinear]
    by_cases same : query.code = key.code
    · simp [same,brec]
    · have ne : Nat.beq query.code key.code = false := by exact code_beq_false same
      simp [same,ne,brec]
  | cons pair props ih =>
    obtain ⟨head,old⟩ := pair
    change findPropLinear query
      (brec (Nat.beq key.code head.code) ((head,value)::props) ((head,old)::setPropL key value props)) = _
    by_cases hit : key.code = head.code
    · have yes : Nat.beq key.code head.code = true := by simp [hit]
      rw [yes]
      simp only [brec,findPropLinear]
      by_cases same : query.code = key.code
      · simp [same,hit]
      · have other : query.code ≠ head.code := by intro eq; exact same (eq.trans hit.symm)
        have no : Nat.beq query.code head.code = false := code_beq_false other
        simp [same,no]
    · have no : Nat.beq key.code head.code = false := code_beq_false hit
      rw [no]
      simp only [brec,findPropLinear]
      by_cases same : query.code = key.code
      · have other : query.code ≠ head.code := by intro eq; exact hit (same.symm.trans eq)
        have noQuery : Nat.beq query.code head.code = false := code_beq_false other
        simp only [noQuery,ite_eq_left same]
        simpa only [findPropLinear] using (ih.trans (ite_eq_left same))
      · by_cases queryHit : query.code = head.code
        · have yes : Nat.beq query.code head.code = true := by simp [queryHit]
          simp [same,yes]
        · have noQuery : Nat.beq query.code head.code = false := code_beq_false queryHit
          simp only [noQuery,ite_eq_right same]
          simpa only [findPropLinear] using (ih.trans (ite_eq_right same))
end Host.Ts.Owned.Parametric

namespace Host.Ts.Owned.Parametric

theorem PublicData.stored {S : Type} (s : St S) (a : Nat) (o : Obj) (name : Name) (v : Val) (w e : Bool)
    (bound : a < 2^64) :
    PublicData (s.setObj a {o with props := setPropL (.str name) (.data v w e) o.props}) a name v := by
  refine ⟨{o with props := setPropL (.str name) (.data v w e) o.props},w,e,?_,?_⟩
  · simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_true]
  · rw [findProp_setPropL_code,ite_eq_left rfl]

theorem PublicData.store_other {S : Type} {s : St S} {owner : Nat} {name : Name} {value : Val}
    (field : PublicData s owner name value) (a : Nat) (o : Obj) (written : Name) (v : Val) (w e : Bool)
    (read : s.heap.get a = some (.obj o)) (bound : a < 2^64)
    (different : owner ≠ a ∨ pack name ≠ pack written) :
    PublicData (s.setObj a {o with props := setPropL (.str written) (.data v w e) o.props}) owner name value := by
  by_cases same : owner = a
  · subst owner
    have codes : pack name ≠ pack written := different.elim (fun impossible => False.elim (impossible rfl)) id
    have keys : (PKey.str name).code ≠ (PKey.str written).code := by
      intro equal
      exact codes (Nat.eq_of_mul_eq_mul_left (by decide : 0 < 2) equal)
    obtain ⟨old,pw,pe,object,descriptor⟩ := field
    have eq := HObj.obj.inj (Option.some.inj (object.symm.trans read))
    subst old
    refine ⟨{o with props := setPropL (.str written) (.data v w e) o.props},pw,pe,?_,?_⟩
    · simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_true]
    · rw [findProp_setPropL_code,ite_eq_right keys]
      exact descriptor
  · exact field.heap_at (by simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_eq_right same])
end Host.Ts.Owned.Parametric

namespace Host.Ts.Owned.Annotated
open Parametric

/-- A real own-data store updates one selected packed-name field. Every other
field on that same object keeps its prior meaning and descriptor. -/
theorem PublicInventory.store {S : Type} {notes : PublicNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {s₀ s : St S} {NR : NumV → NumV → Prop}
    (inventory : PublicInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (a : Nat) (o₀ o : Obj) (name : Name) (role : Value) (v₀ v : Val) (w e : Bool) (alive : live a)
    (source : s₀.heap.get a = some (.obj o₀)) (target : s.heap.get (R.a a) = some (.obj o))
    (sourceRole : role.Holds ν₀ C₀ identity v₀) (targetRole : role.Holds ν C R v)
    (sourceBound : a < 2^64) (targetBound : R.a a < 2^64) :
    PublicInventory (notes.write a name role) ν₀ ν C₀ C R live
      ((s₀.setObj a {o₀ with props := setPropL (.str name) (.data v₀ w e) o₀.props}).ret v₀)
      ((s.setObj (R.a a) {o with props := setPropL (.str name) (.data v w e) o.props}).ret v) := by
  constructor
  · intro b n r entry
    by_cases same : b = a ∧ pack n = pack name
    · exact same.1 ▸ alive
    · exact inventory.keyLive b n r (by simpa only [PublicNotes.write,ite_eq_right same] using entry)
  · intro b n r entry
    by_cases same : b = a ∧ pack n = pack name
    · obtain ⟨rfl,codes⟩ := same
      have eq : role = r := Option.some.inj (by simpa [PublicNotes.write,codes] using entry)
      subst r
      exact ⟨v₀,(PublicData.stored s₀ b o₀ name v₀ w e sourceBound).name_code codes,sourceRole⟩
    · have oldEntry : notes.fields b n = some r := by simpa only [PublicNotes.write,ite_eq_right same] using entry
      obtain ⟨value,field,valueRole⟩ := inventory.source b n r oldEntry
      have different : b ≠ a ∨ pack n ≠ pack name := by
        by_cases eq : b = a
        · exact Or.inr (fun codes => same ⟨eq,codes⟩)
        · exact Or.inl eq
      exact ⟨value,field.store_other a o₀ name v₀ w e source sourceBound different,valueRole⟩
  · intro b n r entry
    by_cases same : b = a ∧ pack n = pack name
    · obtain ⟨rfl,codes⟩ := same
      have eq : role = r := Option.some.inj (by simpa [PublicNotes.write,codes] using entry)
      subst r
      exact ⟨v,(PublicData.stored s (R.a b) o name v w e targetBound).name_code codes,targetRole⟩
    · have oldEntry : notes.fields b n = some r := by simpa only [PublicNotes.write,ite_eq_right same] using entry
      obtain ⟨value,field,valueRole⟩ := inventory.target b n r oldEntry
      have different : R.a b ≠ R.a a ∨ pack n ≠ pack name := by
        by_cases eq : b = a
        · exact Or.inr (fun codes => same ⟨eq,codes⟩)
        · exact Or.inl (fun mapped => eq (heap.inj b a (inventory.keyLive b n r oldEntry) alive mapped))
      exact ⟨value,field.store_other (R.a a) o name v w e target targetBound different,valueRole⟩
end Host.Ts.Owned.Annotated

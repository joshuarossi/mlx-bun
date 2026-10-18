import host.ts.RenameAnnotationResources
import host.ts.RenameIdentifierArguments
import host.ts.RenameParametricArrayBinding
import host.ts.RenameParametricArrayBuffer
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Each selected cell has one fixed occurrence annotation. Equal numeric bits
at different cells may have different meanings. -/
structure Notes where
  cells : Nat → Option Value

def Notes.empty : Notes := ⟨fun _ => none⟩
def Notes.write (notes : Notes) (a : Nat) (role : Value) : Notes :=
  ⟨fun b => if b = a then some role else notes.cells b⟩
def Notes.mapRoles (notes : Notes) (f : Value → Value) : Notes :=
  ⟨fun a => (notes.cells a).map f⟩
def Notes.Live (notes : Notes) (live : Nat → Prop) : Prop :=
  ∀ a role, notes.cells a = some role → live a
def Notes.Holds {S : Type} (notes : Notes) (ν : Nat → F64) (C : CSrv) (R : Ren) (s : St S) : Prop :=
  ∀ a role, notes.cells a = some role → role.Holds ν C R (cellValueAt s (R.a a))

structure CellInventory {S : Type} (notes : Notes) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (R : Ren) (live : Nat → Prop) (s₀ s : St S) : Prop where
  keyLive : notes.Live live
  source : notes.Holds ν₀ C₀ identity s₀
  target : notes.Holds ν C R s

section
variable {S : Type} {notes : Notes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
  {live live' : Nat → Prop} {s₀ s t₀ t : St S}

theorem CellInventory.empty : CellInventory Notes.empty ν₀ ν C₀ C R live s₀ s := by
  constructor <;> intro a role entry <;> cases entry

theorem CellInventory.selected (h : CellInventory notes ν₀ ν C₀ C R live s₀ s)
    (a : Nat) (role : Value) (entry : notes.cells a = some role) :
    live a ∧ role.Holds ν₀ C₀ identity (cellValueAt s₀ a) ∧ role.Holds ν C R (cellValueAt s (R.a a)) :=
  ⟨h.keyLive a role entry,h.source a role entry,h.target a role entry⟩

theorem CellInventory.annotate (h : CellInventory notes ν₀ ν C₀ C R live s₀ s)
    (a : Nat) (role : Value) (alive : live a)
    (sourceRole : role.Holds ν₀ C₀ identity (cellValueAt s₀ a))
    (targetRole : role.Holds ν C R (cellValueAt s (R.a a))) :
    CellInventory (notes.write a role) ν₀ ν C₀ C R live s₀ s := by
  constructor
  · intro b other entry
    by_cases eq : b = a
    · exact eq ▸ alive
    · exact h.keyLive b other (by simpa only [Notes.write,ite_eq_right eq] using entry)
  · intro b other entry
    by_cases eq : b = a
    · subst b
      have same : role = other := Option.some.inj (by simpa [Notes.write] using entry)
      exact same ▸ sourceRole
    · exact h.source b other (by simpa only [Notes.write,ite_eq_right eq] using entry)
  · intro b other entry
    by_cases eq : b = a
    · subst b
      have same : role = other := Option.some.inj (by simpa [Notes.write] using entry)
      exact same ▸ targetRole
    · exact h.target b other (by simpa only [Notes.write,ite_eq_right eq] using entry)

theorem Notes.Live.grow (h : notes.Live live) (grow : ∀ a, live a → live' a) : notes.Live live' :=
  fun a role entry => grow a (h a role entry)

theorem Notes.Holds.map_iff (f : Value → Value) :
    (notes.mapRoles f).Holds ν C R s ↔
      ∀ a role, notes.cells a = some role → (f role).Holds ν C R (cellValueAt s (R.a a)) := by
  constructor
  · intro h a role entry
    exact h a (f role) (by simp only [Notes.mapRoles,entry,Option.map_some])
  · intro h a role entry
    cases original : notes.cells a with
    | none => simp only [Notes.mapRoles,original,Option.map_none] at entry; cases entry
    | some oldRole =>
      have same : f oldRole = role := Option.some.inj (by simpa only [Notes.mapRoles,original,Option.map_some] using entry)
      exact same ▸ h a oldRole original

theorem Notes.Live.mapRoles (f : Value → Value) (h : notes.Live live) : (notes.mapRoles f).Live live := by
  intro a role entry
  cases original : notes.cells a with
  | none => simp only [Notes.mapRoles,original,Option.map_none] at entry; cases entry
  | some oldRole => exact h a oldRole original

theorem Notes.Holds.mono {D : CSrv} (extension : TableExtends C D) (h : notes.Holds ν C R s) :
    notes.Holds ν D R s := fun a role entry => (h a role entry).mono extension

theorem Notes.Holds.frame (h : notes.Holds ν C R s)
    (frame : ∀ a role, notes.cells a = some role → t.heap.get (R.a a) = s.heap.get (R.a a)) :
    notes.Holds ν C R t := by
  intro a role entry
  rw [cellValueAt_heap_at s t _ (frame a role entry)]
  exact h a role entry

theorem CellInventory.frame (h : CellInventory notes ν₀ ν C₀ C R live s₀ s)
    (grow : ∀ a, live a → live' a)
    (sourceFrame : ∀ a role, notes.cells a = some role → t₀.heap.get a = s₀.heap.get a)
    (targetFrame : ∀ a role, notes.cells a = some role → t.heap.get (R.a a) = s.heap.get (R.a a)) :
    CellInventory notes ν₀ ν C₀ C R live' t₀ t :=
  ⟨h.keyLive.grow grow,h.source.frame sourceFrame,h.target.frame targetFrame⟩

theorem CellInventory.mono {D₀ D : CSrv} (h : CellInventory notes ν₀ ν C₀ C R live s₀ s)
    (sourceExtension : TableExtends C₀ D₀) (targetExtension : TableExtends C D) :
    CellInventory notes ν₀ ν D₀ D R live s₀ s :=
  ⟨h.keyLive,h.source.mono sourceExtension,h.target.mono targetExtension⟩

theorem CellInventory.alloc {NR : NumV → NumV → Prop} {framed : Nat → Prop}
    {before after : List Val} (h : CellInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s) (o₀ o : HObj) (v₀ v : Val)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    CellInventory notes ν₀ ν C₀ C R (LiveAfter live s₀.next)
      ((s₀.alloc o₀).2.ret v₀) ((s.alloc o).2.ret v) := by
  apply h.frame (fun _ alive => Or.inl alive)
  · intro a role entry
    exact alloc_ret_heap_below s₀ o₀ v₀ sourceBound a (heap.sourceBound a (h.keyLive a role entry))
  · intro a role entry
    exact alloc_ret_heap_below s o v targetBound (R.a a) (heap.targetBound a (h.keyLive a role entry))

/-- A store changes only its selected annotation. Live heap injectivity keeps
all the other selected target cells distinct from the written location. -/
theorem CellInventory.store {NR : NumV → NumV → Prop} {framed : Nat → Prop}
    {before after : List Val} (h : CellInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s) (a : Nat) (role : Value) (v₀ v : Val)
    (alive : live a) (sourceRole : role.Holds ν₀ C₀ identity v₀) (targetRole : role.Holds ν C R v)
    (sourceBound : a < 2^64) (targetBound : R.a a < 2^64) :
    CellInventory (notes.write a role) ν₀ ν C₀ C R live
      ((s₀.setCell a v₀).ret .undef) ((s.setCell (R.a a) v).ret .undef) := by
  constructor
  · intro b other entry
    by_cases eq : b = a
    · exact eq ▸ alive
    · exact h.keyLive b other (by simpa only [Notes.write,ite_eq_right eq] using entry)
  · intro b other entry
    by_cases eq : b = a
    · subst b
      have same : role = other := Option.some.inj (by simpa [Notes.write] using entry)
      subst other
      simpa only [cellValueAt,identity,St.setCell,St.ret,id_eq,PTrie.get_set_u64 _ _ _ sourceBound,ite_true] using sourceRole
    · have oldEntry : notes.cells b = some other := by simpa only [Notes.write,ite_eq_right eq] using entry
      have frame : ((s₀.setCell a v₀).ret .undef).heap.get b = s₀.heap.get b := by
        simp only [St.setCell,St.ret,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right eq]
      simpa only [cellValueAt,identity,id_eq,frame] using h.source b other oldEntry
  · intro b other entry
    by_cases eq : b = a
    · subst b
      have same : role = other := Option.some.inj (by simpa [Notes.write] using entry)
      subst other
      simpa only [cellValueAt,St.setCell,St.ret,PTrie.get_set_u64 _ _ _ targetBound,ite_true] using targetRole
    · have oldEntry : notes.cells b = some other := by simpa only [Notes.write,ite_eq_right eq] using entry
      have distinct : R.a b ≠ R.a a := fun same => eq (heap.inj b a (h.keyLive b other oldEntry) alive same)
      have frame : ((s.setCell (R.a a) v).ret .undef).heap.get (R.a b) = s.heap.get (R.a b) := by
        simp only [St.setCell,St.ret,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right distinct]
      simpa only [cellValueAt,frame] using h.target b other oldEntry

/-- An object replacement preserves cell annotations, including an undefined
cell selector at the owning object's address. -/
theorem CellInventory.setObject {NR : NumV → NumV → Prop} {framed : Nat → Prop}
    {before after : List Val} (h : CellInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s) (a : Nat) (old₀ old new₀ new : Obj) (v₀ v : Val)
    (alive : live a) (sourceObject : s₀.heap.get a = some (.obj old₀)) (targetObject : s.heap.get (R.a a) = some (.obj old))
    (sourceBound : a < 2^64) (targetBound : R.a a < 2^64) :
    CellInventory notes ν₀ ν C₀ C R live ((s₀.setObj a new₀).ret v₀) ((s.setObj (R.a a) new).ret v) := by
  refine ⟨h.keyLive,?_,?_⟩
  · intro b role entry
    by_cases eq : b = a
    · subst b
      simpa only [cellValueAt,identity,id_eq,sourceObject,St.setObj,St.ret,PTrie.get_set_u64 _ _ _ sourceBound,ite_true]
        using h.source a role entry
    · simpa only [cellValueAt,identity,id_eq,St.setObj,St.ret,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right eq]
        using h.source b role entry
  · intro b role entry
    by_cases eq : b = a
    · subst b
      simpa only [cellValueAt,targetObject,St.setObj,St.ret,PTrie.get_set_u64 _ _ _ targetBound,ite_true]
        using h.target a role entry
    · have other : R.a b ≠ R.a a := fun e => eq (heap.inj b a (h.keyLive b role entry) alive e)
      simpa only [cellValueAt,St.setObj,St.ret,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right other]
        using h.target b role entry

/-- Substitution rebases all numeric occurrence meanings together. -/
theorem Notes.Holds.subst (θ : Nat → SymE) :
    (notes.mapRoles (Value.subst θ)).Holds ν C R s ↔ notes.Holds (nextValuation θ ν) C R s := by
  rw [Notes.Holds.map_iff]
  constructor
  · intro h a role entry
    exact (Value.holds_subst θ role _).mp (h a role entry)
  · intro h a role entry
    exact (Value.holds_subst θ role _).mpr (h a role entry)

theorem CellInventory.subst (θ : Nat → SymE)
    (h : CellInventory notes (nextValuation θ ν₀) (nextValuation θ ν) C₀ C R live s₀ s) :
    CellInventory (notes.mapRoles (Value.subst θ)) ν₀ ν C₀ C R live s₀ s :=
  ⟨h.keyLive.mapRoles _,(Notes.Holds.subst θ).mpr h.source,(Notes.Holds.subst θ).mpr h.target⟩

/-- A renamed inventory may have extra entries. Every selected original entry
must still occur at its actual mapped address with the renamed fixed role. -/
def Notes.RenameCovers (notes renamed : Notes) (K : Ren) : Prop :=
  ∀ a role, notes.cells a = some role → renamed.cells (K.a a) = some (role.rename K)

theorem Notes.Holds.rebase {renamed : Notes} (K : Ren) (θ : Nat → SymE)
    (covers : notes.RenameCovers renamed K)
    (h : (renamed.mapRoles (Value.subst θ)).Holds ν C R s) :
    notes.Holds (nextValuation θ ν) C (composeResources R K) s := by
  have rebased := (Notes.Holds.subst θ).mp h
  intro a role entry
  exact (Value.holds_rename R K role _).mp (rebased (K.a a) (role.rename K) (covers a role entry))
end

/-- The current bound value is an occurrence annotation, independent of equal
numeric literals in other continuation fields. -/
def initializedValue : Ctl → Val
  | .bind _ value _ _ _ => value
  | _ => .undef

/-- The original source identifier read extracts its selected fixed meaning
from the inventory. No target read or future execution is a premise. -/
theorem CellInventory.variable_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : Notes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : CellInventory notes ν₀ ν C₀ C R live s₀ s)
    (name : Name) (env : Env) (a : Nat) (value : Val) (role : Value)
    (control : s₀.ctl = .ev (.id name) env) (lookup : lookupEnv name env = some a)
    (cell : s₀.heap.get a = some (.cell (some value))) (entry : notes.cells a = some role) :
    ∃ targetValue, interpC (step F s₀).run C₀ = some (s₀.ret value,C₀) ∧
      interpC (step F s).run C = some (s.ret targetValue,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' (s₀.ret value) (s.ret targetValue) ∧
      CellInventory notes ν₀ ν C₀ C R live (s₀.ret value) (s.ret targetValue) ∧
      role.Holds ν₀ C₀ identity value ∧ role.Holds ν C R targetValue := by
  have alive := inventory.keyLive a role entry
  obtain ⟨targetValue,targetCell,_,_⟩ := h.heap.readCell a value alive cell
  obtain ⟨v,sourceRun,targetRun,post,_⟩ := step_variable_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h name env a value control (h.control_view control).ev_view lookup alive cell
  have targetLookup : lookupEnv name (R.env env) = some (R.a a) := by rw [lookupEnv_map,lookup]; rfl
  have targetRun' : interpC (step F s).run C = some (s.ret targetValue,C) := by
    rw [step_variable_eq F s name (R.env env) (R.a a) targetValue (h.control_view control).ev_view targetLookup targetCell]
    rfl
  have same : s.ret v = s.ret targetValue := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans targetRun'))
  rw [same] at post
  refine ⟨targetValue,sourceRun,targetRun',post,?_,?_,?_⟩
  · exact inventory.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · simpa only [cellValueAt,identity,id_eq,cell] using inventory.source a role entry
  · simpa only [cellValueAt,targetCell] using inventory.target a role entry

/-- Actual lexical initialization writes the annotated operand and updates the
whole inventory. All other entries survive by the live heap's injectivity. -/
theorem CellInventory.init_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : Notes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : CellInventory notes ν₀ ν C₀ C R live s₀ s)
    (name : Name) (env : Env) (a : Nat) (value : Val) (prior : Option Val) (kind : DeclKind) (role : Value)
    (control : s₀.ctl = .bind (.id name) value env .init kind) (lookup : lookupEnv name env = some a)
    (cell : s₀.heap.get a = some (.cell prior))
    (sourceRole : role.Holds ν₀ C₀ identity value) (targetRole : role.Holds ν C R (initializedValue s.ctl))
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ result, interpC (step F s₀).run C₀ = some ((s₀.setCell a value).ret .undef,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' ((s₀.setCell a value).ret .undef) result ∧
      CellInventory (notes.write a role) ν₀ ν C₀ C R live ((s₀.setCell a value).ret .undef) result := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).bind_view
  have selectedRole : role.Holds ν C R targetValue := by simpa only [initializedValue,targetControl] using targetRole
  have controlLive := h.controlLive
  rw [control] at controlLive
  have alive := env_lookup_live name env a controlLive.2.2.1 lookup
  obtain ⟨sourceRun,targetRun,post⟩ := step_bind_init_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h name value targetValue env kind a prior control targetControl lookup cell sourceBound targetBound
  exact ⟨_,sourceRun,targetRun,post,inventory.store h.heap a role value targetValue alive sourceRole selectedRole
    (Nat.lt_of_lt_of_le (h.heap.sourceBound _ alive) sourceBound)
    (Nat.lt_of_lt_of_le (h.heap.targetBound _ alive) targetBound)⟩
end Host.Ts.Owned.Annotated

import host.ts.RenameParametricIdentity
import host.ts.StoreLaws

set_option Elab.async false
namespace Host.Ts.Owned.Parametric.ClosureCheck

/-- The finite number table is the only numeric-availability bound. -/
def NumberBelow (limit : Nat) : NumV → Prop
  | .lit _ => True
  | .ref i => i < limit

def number (limit : Nat) : NumV → Bool
  | .lit _ => true
  | .ref i => Nat.blt i limit

def value (addresses numbers : Nat) : Val → Bool
  | .num n => number numbers n
  | .obj a => Nat.blt a addresses
  | .sym a => Nat.blt a 16 || Nat.blt (a-16) addresses
  | .ptr (.js a) _ => Nat.blt a addresses
  | _ => true

def cell (numbers : Nat) : Cell → Bool
  | .num n => number numbers n
  | _ => true

def byte (numbers : Nat) : Byte → Bool
  | .lit _ => true
  | .part _ c _ => cell numbers c

mutual
  def tree (addresses numbers : Nat) : Tree → Bool
    | .value v => value addresses numbers v
    | .cell c => cell numbers c
    | .byte b => byte numbers b
    | .address a => Nat.blt a addresses
    | .symbol a => Nat.blt a 16 || Nat.blt (a-16) addresses
    | .number n => number numbers n
    | .node _ fields => forest addresses numbers fields
    | _ => true
  def forest (addresses numbers : Nat) : List Tree → Bool
    | [] => true
    | field::fields => tree addresses numbers field && forest addresses numbers fields
end

def heapObject (addresses numbers : Nat) : HObj → Bool
  | .cell none => true
  | .cell (some v) => value addresses numbers v
  | .obj o => tree addresses numbers (Encode.obj o)

def allTrie {α : Type} (check : α → Bool) : Trie α → Bool
  | .nil => true
  | .node v a b c e => (v.map check).getD true &&
      (allTrie check a && (allTrie check b && (allTrie check c && allTrie check e)))

def heap (addresses numbers : Nat) (h : PTrie HObj) : Bool :=
  allTrie (allTrie (allTrie (heapObject addresses numbers))) h.root

theorem allTrie_node {α : Type} (check : α → Bool) (v : Option α) (a b c e : Trie α)
    (value : (v.map check).getD true = true)
    (ha : allTrie check a = true) (hb : allTrie check b = true)
    (hc : allTrie check c = true) (he : allTrie check e = true) :
    allTrie check (.node v a b c e) = true := by
  simp only [allTrie,value,ha,hb,hc,he,Bool.and_self]

theorem allTrie_node_some {α : Type} (check : α → Bool) (x : α) (a b c e : Trie α)
    (value : check x = true) (ha : allTrie check a = true) (hb : allTrie check b = true)
    (hc : allTrie check c = true) (he : allTrie check e = true) :
    allTrie check (.node (some x) a b c e) = true := by
  exact allTrie_node check (some x) a b c e value ha hb hc he

theorem allTrie_node_none {α : Type} (check : α → Bool) (a b c e : Trie α)
    (ha : allTrie check a = true) (hb : allTrie check b = true)
    (hc : allTrie check c = true) (he : allTrie check e = true) :
    allTrie check (.node none a b c e) = true := by
  exact allTrie_node check none a b c e rfl ha hb hc he

theorem allTrie_nil_at {α : Type} (check : α → Bool) (t : Trie α) (shape : t = .nil) :
    allTrie check t = true := by rw [shape]; rfl

theorem allTrie_some_at {α : Type} (check : α → Bool) (t : Trie α) (x : α) (a b c e : Trie α)
    (shape : t = .node (some x) a b c e) (value : check x = true)
    (ha : allTrie check a = true) (hb : allTrie check b = true)
    (hc : allTrie check c = true) (he : allTrie check e = true) : allTrie check t = true := by
  rw [shape]
  exact allTrie_node_some check x a b c e value ha hb hc he

theorem allTrie_none_at {α : Type} (check : α → Bool) (t : Trie α) (a b c e : Trie α)
    (shape : t = .node none a b c e) (ha : allTrie check a = true) (hb : allTrie check b = true)
    (hc : allTrie check c = true) (he : allTrie check e = true) : allTrie check t = true := by
  rw [shape]
  exact allTrie_node_none check a b c e ha hb hc he

theorem number_sound (limit : Nat) (n : NumV) (h : number limit n = true) : NumberBelow limit n := by
  cases n with
  | lit x => trivial
  | ref i => exact Nat.blt_eq.mp h

theorem value_sound (addresses numbers : Nat) (v : Val) (h : value addresses numbers v = true) :
    valueNumeric (NumberBelow numbers) v ∧ valueSupport (· < addresses) v := by
  cases v <;> simp only [value,valueNumeric,valueSupport] at * <;> try exact ⟨trivial,trivial⟩
  case num n => exact ⟨number_sound numbers n h,trivial⟩
  case obj a => exact ⟨trivial,Nat.blt_eq.mp h⟩
  case sym a => exact ⟨trivial,(Bool.or_eq_true_iff.mp h).imp Nat.blt_eq.mp Nat.blt_eq.mp⟩
  case ptr m off => cases m with
    | js a => exact ⟨trivial,Nat.blt_eq.mp h⟩
    | ext a => exact ⟨trivial,trivial⟩

theorem cell_sound (numbers : Nat) (c : Cell) (h : cell numbers c = true) : cellNumeric (NumberBelow numbers) c := by
  cases c with
  | num n => exact number_sound numbers n h
  | big i => trivial

theorem byte_sound (numbers : Nat) (b : Byte) (h : byte numbers b = true) : byteNumeric (NumberBelow numbers) b := by
  cases b with
  | lit b => trivial
  | part k c i => exact cell_sound numbers c h

mutual
  theorem tree_sound (addresses numbers : Nat) (t : Tree) (h : tree addresses numbers t = true) :
      treeNumeric (NumberBelow numbers) t ∧ treeSupport (· < addresses) t := by
    cases t with
    | atom α x => exact ⟨trivial,trivial⟩
    | value v => exact value_sound addresses numbers v h
    | cell c => exact ⟨cell_sound numbers c h,trivial⟩
    | byte b => exact ⟨byte_sound numbers b h,trivial⟩
    | address a => exact ⟨trivial,Nat.blt_eq.mp h⟩
    | symbol a => exact ⟨trivial,(Bool.or_eq_true_iff.mp h).imp Nat.blt_eq.mp Nat.blt_eq.mp⟩
    | region a => exact ⟨trivial,trivial⟩
    | number n => exact ⟨number_sound numbers n h,trivial⟩
    | node tag fields => exact forest_sound addresses numbers fields h
  theorem forest_sound (addresses numbers : Nat) (fields : List Tree) (h : forest addresses numbers fields = true) :
      forestNumeric (NumberBelow numbers) fields ∧ forestSupport (· < addresses) fields := by
    cases fields with
    | nil => exact ⟨trivial,trivial⟩
    | cons field fields =>
      have split := Bool.and_eq_true_iff.mp h
      have head := tree_sound addresses numbers field split.1
      have tail := forest_sound addresses numbers fields split.2
      exact ⟨⟨head.1,tail.1⟩,⟨head.2,tail.2⟩⟩
end

theorem heapObject_sound (addresses numbers : Nat) (o : HObj) (h : heapObject addresses numbers o = true) :
    heapObjectNumeric (NumberBelow numbers) o ∧ treeSupport (· < addresses) (Encode.hobj o) := by
  cases o with
  | cell v => cases v with
    | none => exact ⟨trivial,trivial⟩
    | some v =>
      have safe := value_sound addresses numbers v h
      exact ⟨safe.1,safe.2,trivial⟩
  | obj o =>
    have safe := tree_sound addresses numbers (Encode.obj o) h
    exact ⟨safe.1,safe.2,trivial⟩

theorem allTrie_get {α : Type} (check : α → Bool) (t : Trie α) (h : allTrie check t = true)
    (n : Nat) (x : α) (read : t.get n = some x) : check x = true := by
  induction t generalizing n with
  | nil => cases read
  | node v a b c e ia ib ic ie =>
    have split := Bool.and_eq_true_iff.mp h
    have ha := (Bool.and_eq_true_iff.mp split.2).1
    have hb := (Bool.and_eq_true_iff.mp (Bool.and_eq_true_iff.mp split.2).2).1
    have hc := (Bool.and_eq_true_iff.mp (Bool.and_eq_true_iff.mp (Bool.and_eq_true_iff.mp split.2).2).2).1
    have he := (Bool.and_eq_true_iff.mp (Bool.and_eq_true_iff.mp (Bool.and_eq_true_iff.mp split.2).2).2).2
    rw [Trie.get_node] at read
    by_cases zero : n = 0
    · subst n
      rw [ite_eq_left rfl] at read
      simpa only [read,Option.map_some,Option.getD_some] using split.1
    · rw [ite_eq_right zero] at read
      unfold Trie.pick brec at read
      cases h₀ : Nat.blt (n % 4) 2 <;> cases h₁ : Nat.beq (n % 4) 0 <;> cases h₂ : Nat.beq (n % 4) 2 <;>
        simp only [h₀,h₁,h₂] at read
      all_goals first | exact ia ha _ read | exact ib hb _ read | exact ic hc _ read | exact ie he _ read

theorem heap_get (addresses numbers : Nat) (h : PTrie HObj) (checked : heap addresses numbers h = true)
    (a : Nat) (o : HObj) (read : h.get a = some o) :
    heapObjectNumeric (NumberBelow numbers) o ∧ treeSupport (· < addresses) (Encode.hobj o) := by
  rw [PTrie.get_eq] at read
  cases groupRead : h.root.get (a/4096) with
  | none => simp only [groupRead,PTrie.orNil_none,Trie.get_nil] at read; cases read
  | some group =>
    have groupSafe := allTrie_get _ h.root checked _ group groupRead
    cases pageRead : group.get ((a/64)%64) with
    | none => simp only [groupRead,pageRead,PTrie.orNil_some,PTrie.orNil_none,Trie.get_nil] at read; cases read
    | some page =>
      have pageSafe := allTrie_get _ group groupSafe _ page pageRead
      have leafRead : page.get (a%64) = some o := by simpa only [groupRead,pageRead,PTrie.orNil_some] using read
      exact heapObject_sound addresses numbers o (allTrie_get _ page pageSafe _ o leafRead)

private theorem nth?_exists {α : Type} (xs : List α) (i : Nat) (h : i < xs.length) : ∃ x, nth? xs i = some x := by
  induction xs generalizing i with
  | nil => cases h
  | cons x xs ih => cases i with
    | zero => exact ⟨x,rfl⟩
    | succ i => exact ih i (by simpa only [List.length_cons,Nat.succ_lt_succ_iff] using h)

theorem number_value (limit : Nat) (C : CSrv) (bound : limit ≤ C.tab.length)
    (n : NumV) (safe : NumberBelow limit n) : ∃ x, C.val n = some x := by
  cases n with
  | lit x => exact ⟨x,rfl⟩
  | ref i => exact nth?_exists C.tab i (Nat.lt_of_lt_of_le safe bound)

theorem number_identity (limit : Nat) (ν : Nat → F64) (C : CSrv) (bound : limit ≤ C.tab.length)
    (n : NumV) (safe : NumberBelow limit n) : NumberRoles ν ν C C n n := by
  obtain ⟨x,read⟩ := number_value limit C bound n safe
  exact numberRoles_reflexive_value ν C n x read

structure Certificate {S : Type} (s : St S) (addresses numbers : Nat) : Prop where
  addressLimit : s.next = addresses
  heap : heap addresses numbers s.heap = true
  control : tree addresses numbers (Encode.ctl s.ctl) = true
  stack : s.stack.all (fun f => tree addresses numbers (Encode.frame f)) = true
  jobs : s.jobs.all (fun j => tree addresses numbers (Encode.job j)) = true
  stores : tree addresses numbers (Encode.stores s.stores) = true

private theorem list_checked {α : Type} (check : α → Bool) (safe : α → Prop)
    (sound : ∀ x, check x = true → safe x) (xs : List α) (h : xs.all check = true) : listSupport safe xs := by
  induction xs with
  | nil => trivial
  | cons x xs ih =>
    have checked := Bool.and_eq_true_iff.mp h
    exact ⟨sound x checked.1,ih checked.2⟩

/-- Source closure certificates supply the complete identity runtime relation.
Only availability of the concrete table is needed; no target state or run is
postulated. The native heap relation is separately initialized. -/
theorem Certificate.identity {S : Type} {s : St S} {addresses numbers : Nat}
    (certificate : Certificate s addresses numbers) (ν : Nat → F64) (C : CSrv)
    (table : numbers ≤ C.tab.length) :
    StateR (NumberRoles ν ν C C) (fun _ _ _ => True) Annotated.identity (· < s.next)
      (fun _ => False) [] [] s.trace s.trace s s := by
  refine StateR.identity (number_identity numbers ν C table) s (· < s.next) (fun _ _ _ => True)
    (fun _ alive => alive) (fun a o _ read => ?_) ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ trivial
  · simpa only [certificate.addressLimit] using heap_get addresses numbers s.heap certificate.heap a o read
  · exact (tree_sound addresses numbers _ certificate.control).1
  · simpa only [certificate.addressLimit] using (tree_sound addresses numbers _ certificate.control).2
  · exact list_checked _ _ (fun f checked => (tree_sound addresses numbers (Encode.frame f) checked).1) _ certificate.stack
  · have safe := list_checked _ _ (fun f checked => (tree_sound addresses numbers (Encode.frame f) checked).2) _ certificate.stack
    simpa only [certificate.addressLimit] using safe
  · exact list_checked _ _ (fun j checked => (tree_sound addresses numbers (Encode.job j) checked).1) _ certificate.jobs
  · have safe := list_checked _ _ (fun j checked => (tree_sound addresses numbers (Encode.job j) checked).2) _ certificate.jobs
    simpa only [certificate.addressLimit] using safe
  · exact (tree_sound addresses numbers _ certificate.stores).1
  · simpa only [certificate.addressLimit] using (tree_sound addresses numbers _ certificate.stores).2

end Host.Ts.Owned.Parametric.ClosureCheck

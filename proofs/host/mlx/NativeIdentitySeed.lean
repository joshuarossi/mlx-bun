import host.mlx.NativeAnnotations
import host.ts.RuntimeClosureCheck

set_option Elab.async false
namespace Host.Mlx.Ffi.Annotated.Initial
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Ts.Owned.Parametric.ClosureCheck

/-- Initial source geometry is retained as exact literal dimensions. A
symbolic constructor fails this certificate rather than acquiring a meaning. -/
def literalDimension (d : Dim) : Dimension :=
  match d with
  | .lit i => .literal (.lit (F64.ofInt i))
  | .sym _ => .symbolic (.any (.lit (F64.ofNat 0)))
def checkDimension : Dim → Bool
  | .lit i => decide (F64.toInt? (F64.ofInt i) = some i)
  | .sym _ => false

def literalNode (n : Node) : GraphNode := ⟨n.shape.map literalDimension,n.dtype,none⟩
def checkNode (n : Node) : Bool := n.shape.all checkDimension

def nodeRoles (s : St) (i : Nat) : GraphNode :=
  match s.nodes.get i with
  | some n => literalNode n
  | none => ⟨[],0,none⟩

def allPaged {α : Type} (check : α → Bool) (t : PTrie α) : Bool :=
  ClosureCheck.allTrie (ClosureCheck.allTrie (ClosureCheck.allTrie check)) t.root

theorem allPaged_get {α : Type} (check : α → Bool) (t : PTrie α) (safe : allPaged check t = true)
    (i : Nat) (value : α) (read : t.get i = some value) : check value = true := by
  rw [PTrie.get_eq] at read
  cases groupRead : t.root.get (i/4096) with
  | none => simp only [groupRead,PTrie.orNil_none,Trie.get_nil] at read; cases read
  | some group =>
    have groupSafe := ClosureCheck.allTrie_get _ t.root safe _ group groupRead
    cases pageRead : group.get ((i/64)%64) with
    | none => simp only [groupRead,pageRead,PTrie.orNil_some,PTrie.orNil_none,Trie.get_nil] at read; cases read
    | some page =>
      have pageSafe := ClosureCheck.allTrie_get _ group groupSafe _ page pageRead
      have leafRead : page.get (i%64) = some value := by simpa only [groupRead,pageRead,PTrie.orNil_some] using read
      exact ClosureCheck.allTrie_get _ page pageSafe _ value leafRead

theorem literalDimension_holds (ν : Nat → F64) (C : CSrv) (d : Dim) (safe : checkDimension d = true) :
    (literalDimension d).Holds ν C d := by
  cases d with
  | lit i => exact .literal (.lit (F64.ofInt i)) i rfl (of_decide_eq_true safe)
  | sym n => cases safe

theorem literalShape_holds (ν : Nat → F64) (C : CSrv) (dims : List Dim)
    (safe : dims.all checkDimension = true) : Shape.Holds ν C (dims.map literalDimension) dims := by
  induction dims with
  | nil => exact .nil
  | cons d dims ih =>
    have split := Bool.and_eq_true_iff.mp safe
    exact .cons (literalDimension_holds ν C d split.1) (ih split.2)

theorem literalNode_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (n : Node) (safe : checkNode n = true) :
    (literalNode n).Holds ν C R n := by
  refine ⟨literalShape_holds ν C n.shape safe,rfl,?_⟩
  intro p ins impossible
  cases impossible

theorem nodeRoles_holds (s : St) (safe : allPaged checkNode s.nodes = true)
    (ν : Nat → F64) (C : CSrv) (R : Ren) (i : Nat) (n : Node) (read : s.nodes.get i = some n) :
    (nodeRoles s i).Holds ν C R n := by
  simp only [nodeRoles,read]
  exact literalNode_holds ν C R n (allPaged_get checkNode s.nodes safe i n read)

theorem identity_handle (h : Nat) : Host.Ts.Owned.Annotated.identity.handle h = h := rfl

theorem numberList_identity (limit : Nat) (ν : Nat → F64) (C : CSrv) (bound : limit ≤ C.tab.length)
    (xs : List NumV) (safe : xs.all (ClosureCheck.number limit) = true) :
    ListR (NumberRoles ν ν C C) xs xs := by
  induction xs with
  | nil => exact .nil
  | cons n ns ih =>
    have checked := Bool.and_eq_true_iff.mp safe
    exact .cons (ClosureCheck.number_identity limit ν C bound n (ClosureCheck.number_sound limit n checked.1)) (ih checked.2)

end Host.Mlx.Ffi.Annotated.Initial

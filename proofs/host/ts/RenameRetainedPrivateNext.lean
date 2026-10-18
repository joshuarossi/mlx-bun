import host.ts.RenameRetainedPrivateInitialization
import host.ts.RenameRetainedClassEntry
import host.ts.RenameRetainedHeapFrame

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def mapPrivateMember (R : Ren) : InstMember → InstMember
  | .privField brand name init => .privField (R.a brand) name init
  | other => other

theorem privateFields_map (NR : NumV → NumV → Prop) (R : Ren) {members : List InstMember}
    (privateFields : PrivateFields members) :
    ClassFieldsR NR R members (members.map (mapPrivateMember R)) := by
  induction privateFields with
  | nil => exact .node _ .nil
  | @cons brand name init rest _ ih =>
    cases ih with | node _ tail =>
      exact .node _ (.cons (.node _ (.cons (.address brand) (.cons (.atom Name name)
        (.cons (.atom (Option Expr) init) .nil)))) tail)

theorem privateFields_target {NR : NumV → NumV → Prop} {R : Ren} {members target : List InstMember}
    (privateFields : PrivateFields members) (related : ClassFieldsR NR R members target) :
    target = members.map (mapPrivateMember R) := by
  induction privateFields generalizing target with
  | nil => exact related.nil_view
  | @cons brand name init rest _ ih =>
    obtain ⟨tail,rfl,tailRelated⟩ := related.private_view
    rw [ih tailRelated]
    rfl

inductive PrivateNext where
  | done
  | initial (brand : Nat) (name : Name) (expression : Expr) (rest : List InstMember)

def PrivateNext.members : PrivateNext → List InstMember
  | .done => []
  | .initial brand name expression rest => .privField brand name (some expression)::rest
def PrivateNext.valid : PrivateNext → Prop
  | .done => True
  | .initial _ _ _ rest => PrivateFields rest
def PrivateNext.map (R : Ren) : PrivateNext → PrivateNext
  | .done => .done
  | .initial brand name expression rest => .initial (R.a brand) name expression (rest.map (mapPrivateMember R))
def PrivateNext.advance {S : Type} (next : PrivateNext) (s : St S) (owner : Nat) (env : Env) : St S :=
  match next with
  | .done => s.ret .undef
  | .initial brand name expression rest =>
      (s.push (.k (.privVal owner brand name rest env))).go (.ev expression env)

def privateInitializerFrameNote (owner brand : Nat) (name : Name) (rest : List InstMember) (env : Env) : Tree :=
  .node "Frame.k" [.node "FnF.privVal" [.address owner,.address brand,.atom Name name,
    privateMembersNote rest,environmentNote env]]
def RuntimeNotes.privateNext (notes : RuntimeNotes) (next : PrivateNext) (owner : Nat) (env : Env) : RuntimeNotes :=
  match next with
  | .done => {notes with control := returnNote .undef}
  | .initial brand name expression rest => {notes with control := expressionNote expression env, stack := privateInitializerFrameNote owner brand name rest env::notes.stack}

theorem PrivateNext.onlyPrivate (next : PrivateNext) (valid : next.valid) : PrivateFields next.members := by
  cases next with
  | done => exact .nil
  | initial brand name expression rest => exact .cons brand name (some expression) valid

theorem PrivateNext.members_map (next : PrivateNext) (R : Ren) :
    (next.map R).members = next.members.map (mapPrivateMember R) := by cases next <;> rfl

theorem PrivateNext.advance_eq (F : Ffi) (next : PrivateNext) (s : St F.S) (owner : Nat) (env : Env) :
    fieldsNext F s owner next.members env = M.pure (next.advance s owner env) := by cases next <;> rfl

theorem privateInitializerFrameNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren}
    (owner brand : Nat) (name : Name) (rest : List InstMember) (env : Env) (valid : PrivateFields rest) :
    (privateInitializerFrameNote owner brand name rest env).Holds ν C R
      (Encode.frame (.k (.privVal (R.a owner) (R.a brand) name (rest.map (mapPrivateMember R)) (R.env env)))) :=
  .node _ (.cons (.node _ (.cons (.address owner) (.cons (.address brand) (.cons (.atom Name name)
    (.cons (privateMembersNote_holds valid (privateFields_map (fun _ _ => True) R valid))
      (.cons (environmentNote_holds ν C R env) .nil)))))) .nil)

/-- Original private-field scheduling adds only fixed source syntax/brand
notes above the existing caller/constructor notes. Every retained data family
is unchanged because scheduling itself leaves the heap untouched. -/
theorem RetainedInventory.private_next {S : Type} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (next : PrivateNext) (valid : next.valid) (owner : Nat) (env : Env) :
    RetainedInventory (notes.withRuntime (notes.runtime.privateNext next owner env)) ν₀ ν C₀ C R live
      (next.advance s₀ owner env) ((next.map R).advance s (R.a owner) (R.env env)) := by
  have sourceHeap : (next.advance s₀ owner env).heap = s₀.heap := by cases next <;> rfl
  have targetHeap : ((next.map R).advance s (R.a owner) (R.env env)).heap = s.heap := by cases next <;> rfl
  have cells := inventory.runtime.cellInventory.frame (fun _ alive => alive)
    (t₀:=next.advance s₀ owner env) (t:=(next.map R).advance s (R.a owner) (R.env env))
    (fun a _ _ => congrArg (fun h => h.get a) sourceHeap)
    (fun a _ _ => congrArg (fun h => h.get (R.a a)) targetHeap)
  have runtime : RuntimeInventory (notes.runtime.privateNext next owner env) ν₀ ν C₀ C R live
      (next.advance s₀ owner env) ((next.map R).advance s (R.a owner) (R.env env)) := by
    cases next with
    | done => exact ⟨cells.keyLive,⟨returnNote_holds .undef,inventory.runtime.source.stack,cells.source⟩,
        ⟨returnNote_holds .undef,inventory.runtime.target.stack,cells.target⟩⟩
    | initial brand name expression rest =>
      have address : identity.a owner = owner := rfl
      have privateBrand : identity.a brand = brand := rfl
      have sameRest : rest.map (mapPrivateMember identity) = rest :=
        (privateFields_target valid (privateFields_identity (fun _ _ => True) valid)).symm
      refine ⟨cells.keyLive,⟨expressionNote_source ν₀ C₀ expression env,?_,cells.source⟩,
        ⟨expressionNote_holds ν C R expression env,?_,cells.target⟩⟩
      · exact .cons (by simpa only [address,privateBrand,sameRest,identity_environment] using
          (privateInitializerFrameNote_holds (ν:=ν₀) (C:=C₀) (R:=identity) owner brand name rest env valid))
          inventory.runtime.source.stack
      · exact .cons (privateInitializerFrameNote_holds owner brand name rest env valid) inventory.runtime.target.stack
  exact inventory.heap_step runtime sourceHeap targetHeap (TableExtends.refl C₀) (TableExtends.refl C)

end Host.Ts.Owned.Annotated

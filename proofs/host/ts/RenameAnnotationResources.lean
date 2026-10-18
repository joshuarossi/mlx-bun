import host.ts.RenameAnnotationRebase
namespace Host.Ts.Owned.Annotated

/-- Composition follows occurrence roles; ordinary bigint values remain ordinary.
Only owned nonnegative handles use the composed handle map. -/
def composeResources (R K : Ren) : Ren :=
  { a := fun a => R.a (K.a a), n := fun n => R.n (K.n n),
    big := fun | .ofNat h => Int.ofNat (R.handle (K.handle h)) | .negSucc n => .negSucc n,
    region := fun r => R.region (K.region r), node := fun n => R.node (K.node n) }

theorem compose_handle (R K : Ren) (h : Nat) :
    (composeResources R K).handle h = R.handle (K.handle h) := rfl

theorem compose_mem (R K : Ren) (m : Mem) :
    (composeResources R K).mem m = R.mem (K.mem m) := by cases m <;> rfl

theorem compose_sym (R K : Ren) (a : Nat) :
    (composeResources R K).sym a = R.sym (K.sym a) := by
  simp only [Ren.sym,NameMap.sym]
  cases hb : Nat.blt a 16
  · simp only [Bool.cond_false]
    have hn : Nat.blt (K.a (a-16)+16) 16 = false := by
      cases ht : Nat.blt (K.a (a-16)+16) 16
      · rfl
      · have := Nat.blt_eq.mp ht
        omega
    simp only [hn,Bool.cond_false,Nat.add_sub_cancel_right]
    rfl
  · simp only [Bool.cond_true,hb]

def Value.rename (K : Ren) : Value → Value
  | .handle h => .handle (K.handle h)
  | .pointerInteger m off => .pointerInteger (K.mem m) off
  | .obj a => .obj (K.a a)
  | .sym a => .sym (K.sym a)
  | .ptr m off => .ptr (K.mem m) off
  | role => role

def Cell.rename (K : Ren) : Cell → Cell
  | .handle h => .handle (K.handle h)
  | .pointerInteger m off => .pointerInteger (K.mem m) off
  | role => role

def Byte.rename (K : Ren) : Byte → Byte
  | .lit b => .lit b
  | .part k role i => .part k (role.rename K) i

mutual
  def Tree.rename (K : Ren) : Tree → Tree
    | .atom α x => .atom α x
    | .value role => .value (role.rename K)
    | .cell role => .cell (role.rename K)
    | .byte role => .byte (role.rename K)
    | .address a => .address (K.a a)
    | .symbol a => .symbol (K.sym a)
    | .region a => .region (K.region a)
    | .number e => .number e
    | .node tag fields => .node tag (renameForest K fields)
  def renameForest (K : Ren) : List Tree → List Tree
    | [] => []
    | role :: rest => role.rename K :: renameForest K rest
end

theorem Value.holds_rename {ν : Nat → F64} {C : CSrv} (R K : Ren) (role : Value) (v : Val) :
    (role.rename K).Holds ν C R v ↔ role.Holds ν C (composeResources R K) v := by
  cases role <;> simp only [Value.rename]
  all_goals constructor <;> intro h <;> cases h
  all_goals try first
    | solve | constructor
    | constructor <;> assumption
  case pointerInteger.mp m off => cases m <;> exact .pointerInteger _ off
  case pointerInteger.mpr m off => cases m <;> exact .pointerInteger _ off
  case sym.mp a => simpa only [compose_sym] using (Value.Holds.sym (ν := ν) (C := C) (R := composeResources R K) a)
  case sym.mpr a => simpa only [compose_sym] using (Value.Holds.sym (ν := ν) (C := C) (R := R) (K.sym a))
  case ptr.mp m off => cases m <;> exact .ptr _ off
  case ptr.mpr m off => cases m <;> exact .ptr _ off

theorem Cell.holds_rename {ν : Nat → F64} {C : CSrv} (R K : Ren) (role : Cell) (v : Host.Ts.Cell) :
    (role.rename K).Holds ν C R v ↔ role.Holds ν C (composeResources R K) v := by
  cases role <;> simp only [Cell.rename]
  all_goals constructor <;> intro h <;> cases h
  all_goals try first
    | solve | constructor
    | constructor <;> assumption
  case pointerInteger.mp m off => cases m <;> exact .pointerInteger _ off
  case pointerInteger.mpr m off => cases m <;> exact .pointerInteger _ off

theorem Byte.holds_rename {ν : Nat → F64} {C : CSrv} (R K : Ren) (role : Byte) (v : Host.Ts.Byte) :
    (role.rename K).Holds ν C R v ↔ role.Holds ν C (composeResources R K) v := by
  cases role <;> simp only [Byte.rename]
  all_goals constructor <;> intro h <;> cases h
  case lit.mp b => exact .lit b
  case lit.mpr b => exact .lit b
  case part.mp k role i c h => exact .part k role i c ((Cell.holds_rename R K role c).mp h)
  case part.mpr k role i c h => exact .part k (role.rename K) i c ((Cell.holds_rename R K role c).mpr h)

mutual
  theorem Tree.rename_holds {ν : Nat → F64} {C : CSrv} (R K : Ren) (role : Tree) (v : Owned.Tree)
      (h : (role.rename K).Holds ν C R v) : role.Holds ν C (composeResources R K) v := by
    cases role <;> simp only [Tree.rename] at h <;> cases h
    case atom α x => exact .atom α x
    case value role v h => exact .value ((Value.holds_rename R K role v).mp h)
    case cell role c h => exact .cell ((Cell.holds_rename R K role c).mp h)
    case byte role b h => exact .byte ((Byte.holds_rename R K role b).mp h)
    case address a => exact .address a
    case symbol a => simpa only [compose_sym] using (Tree.Holds.symbol (ν := ν) (C := C) (R := composeResources R K) a)
    case region a => exact .region a
    case number e n h => exact .number e n h
    case node tag fields values h => exact .node tag (renameForest_holds R K fields values h)
  theorem renameForest_holds {ν : Nat → F64} {C : CSrv} (R K : Ren) (roles : List Tree) (values : List Owned.Tree)
      (h : ForestHolds ν C R (renameForest K roles) values) :
      ForestHolds ν C (composeResources R K) roles values := by
    cases roles <;> simp only [renameForest] at h <;> cases h
    case nil => exact .nil
    case cons role roles value values h hs => exact .cons (Tree.rename_holds R K role value h) (renameForest_holds R K roles values hs)
end

mutual
  theorem Tree.holds_rename_of {ν : Nat → F64} {C : CSrv} (R K : Ren) (role : Tree) (v : Owned.Tree)
      (h : role.Holds ν C (composeResources R K) v) : (role.rename K).Holds ν C R v := by
    cases h
    case atom α x => exact .atom α x
    case value role v h => exact .value ((Value.holds_rename R K role v).mpr h)
    case cell role c h => exact .cell ((Cell.holds_rename R K role c).mpr h)
    case byte role b h => exact .byte ((Byte.holds_rename R K role b).mpr h)
    case address a => exact .address (K.a a)
    case symbol a => simpa only [compose_sym,Tree.rename] using (Tree.Holds.symbol (ν := ν) (C := C) (R := R) (K.sym a))
    case region a => exact .region (K.region a)
    case number e n h => exact .number e n h
    case node tag fields values h => exact .node tag (holds_renameForest_of R K fields values h)
  theorem holds_renameForest_of {ν : Nat → F64} {C : CSrv} (R K : Ren) (roles : List Tree) (values : List Owned.Tree)
      (h : ForestHolds ν C (composeResources R K) roles values) :
      ForestHolds ν C R (renameForest K roles) values := by
    cases h
    case nil => exact .nil
    case cons role value roles values h hs => exact .cons (Tree.holds_rename_of R K role value h) (holds_renameForest_of R K roles values hs)
end

theorem Tree.holds_rename {ν : Nat → F64} {C : CSrv} (R K : Ren) (role : Tree) (v : Owned.Tree) :
    (role.rename K).Holds ν C R v ↔ role.Holds ν C (composeResources R K) v :=
  ⟨Tree.rename_holds R K role v,Tree.holds_rename_of R K role v⟩

/-- Resource/counter rebase preserves the fresh-address law by actual map
composition, rather than choosing an unrelated new renaming. -/
theorem compose_fresh (R K : Ren) (source middle target : Nat)
    (hk : ∀ k, K.a (source+k) = middle+k) (hr : ∀ k, R.a (middle+k) = target+k) :
    ∀ k, (composeResources R K).a (source+k) = target+k := by
  intro k
  change R.a (K.a (source+k)) = target+k
  rw [hk,hr]

theorem Tree.rebase {ν : Nat → F64} {C : CSrv} (R K : Ren) (θ : Nat → SymE) (role : Tree) (v : Owned.Tree) :
    ((role.rename K).subst θ).Holds ν C R v ↔
      role.Holds (nextValuation θ ν) C (composeResources R K) v := by
  rw [Tree.holds_subst,Tree.holds_rename]

end Host.Ts.Owned.Annotated

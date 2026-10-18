import host.ts.Chunk
import Lean.Data.PersistentHashMap
namespace Host.Ts.Memo
open Lean

/-! # Serialization with sharing

A chain's states share almost all of their structure (the heap is a
persistent trie, lists share suffixes, closures share their code); the
derived `ToExpr` instances (`Chunk`) rebuild each state as a tree, which
costs time and memory proportional to the tree, not the state. Here lists,
tries and AST nodes are serialized once per *object*: a table keyed by the
object's address (and the instance's type) returns the expression already
built, and keeps the object alive so its address is not reused. The
instances below take precedence over `Chunk`'s; the types holding lists are
derived again over them. Serialization only chooses the states a chain's
checks compare against: a wrong expression fails a kernel check. -/

-- Persistent structures: a global reference marks what it holds as shared, so an
-- array-based table would be copied on every insertion.
initialize memoRef : IO.Ref (Lean.PersistentHashMap (UInt64 × USize) Lean.Expr) ← IO.mkRef {}
initialize keepRef : IO.Ref (List NonScalar) ← IO.mkRef []
initialize previousRef : IO.Ref (Lean.PersistentHashMap (UInt64 × USize) Lean.Expr) ← IO.mkRef {}
initialize previousKeepRef : IO.Ref (List NonScalar) ← IO.mkRef []

unsafe def memoImpl {α : Type} (tag : UInt64) (x : α) (f : Unit → Lean.Expr) : Lean.Expr :=
  unsafeBaseIO do
    let k := (tag, ptrAddrUnsafe x)
    match (← memoRef.get).find? k with
    | some e => pure e
    | none =>
      let e ← match (← previousRef.get).find? k with
        | some e => pure e
        | none => pure (f ())
      memoRef.modify (·.insert k e)
      keepRef.modify (unsafeCast x :: ·)
      pure e

/-- `f ()`, once per object `x` (per `tag`). -/
@[implemented_by memoImpl] opaque memo {α : Type} (tag : UInt64) (x : α) (f : Unit → Lean.Expr) : Lean.Expr

def resetImpl : IO Unit := do
  memoRef.set {}; keepRef.set []
  previousRef.set {}; previousKeepRef.set []

/-- Start the next serialization epoch. Only the previous boundary may supply
cached expressions; hits promote the native value and expression into this
boundary. Values unused for two boundaries are released. -/
def beginEpoch : IO Unit := do
  previousRef.set (← memoRef.get)
  previousKeepRef.set (← keepRef.get)
  memoRef.set {}
  keepRef.set []

/-- Forget all memoized expressions (each chain command starts afresh). -/
def reset : IO Unit := resetImpl

def tagOf (ty : Lean.Expr) (k : UInt64) : UInt64 := mixHash ty.hash k

/-- A list's expression: cells up to the first memoized suffix, built from that
suffix backwards (no recursion on the list's length). -/
unsafe def listExprImpl {α : Type} (tag : UInt64) (nil cons : Lean.Expr) (elem : α → Lean.Expr) (l : List α) : Lean.Expr :=
  unsafeBaseIO do
    let table ← memoRef.get
    let previous ← previousRef.get
    let mut cells : Array (List α) := #[]
    let mut cur := l
    let mut tail := nil
    repeat
      match cur with
      | [] => break
      | _ :: as =>
        match table.find? (tag, ptrAddrUnsafe cur) with
        | some e => tail := e; break
        | none => match previous.find? (tag, ptrAddrUnsafe cur) with
          | some old =>
            memoRef.modify (·.insert (tag, ptrAddrUnsafe cur) old)
            keepRef.modify (unsafeCast cur :: ·)
            tail := old
            break
          | none => cells := cells.push cur; cur := as
    let mut e := tail
    for i in [0:cells.size] do
      let c := cells[cells.size - 1 - i]!
      match c with
      | x :: _ =>
        e := mkApp2 cons (elem x) e
        memoRef.modify (·.insert (tag, ptrAddrUnsafe c) e)
        keepRef.modify (unsafeCast c :: ·)
      | [] => pure ()
    pure e

@[implemented_by listExprImpl]
opaque listExpr {α : Type} (tag : UInt64) (nil cons : Lean.Expr) (elem : α → Lean.Expr) (l : List α) : Lean.Expr

instance (priority := 20000) instToExprListMemo {α : Type} [ToExpr α] : ToExpr (List α) :=
  let ty := toTypeExpr α
  let nil := mkApp (mkConst ``List.nil [.zero]) ty
  let cons := mkApp (mkConst ``List.cons [.zero]) ty
  ⟨listExpr (tagOf ty 1) nil cons toExpr, mkApp (mkConst ``List [.zero]) ty⟩

instance (priority := 20000) instToExprTrieMemo {α : Type} [ToExpr α] : ToExpr (Trie α) :=
  let ty := toTypeExpr α
  let tag := tagOf ty 2
  let nil := mkApp (mkConst ``Trie.nil) ty
  let node := mkApp (mkConst ``Trie.node) ty
  let rec go : Trie α → Lean.Expr
    | .nil => nil
    | t@(.node v a b c d) => memo tag t fun _ => mkAppN node #[toExpr v, go a, go b, go c, go d]
  ⟨go, mkApp (mkConst ``Trie) ty⟩

-- Capture the cached Trie instances at all three page levels. Chunk's earlier
-- derived instance was elaborated before those instances existed.
deriving instance Lean.ToExpr for Host.Ts.PTrie
attribute [instance 20000] instToExprPTrie

section
variable {α : Type} (inst : ToExpr α) (k : UInt64)
/-- An instance whose results are memoized per object. -/
def memoInst : ToExpr α := ⟨fun x => memo (tagOf inst.toTypeExpr k) x fun _ => inst.toExpr x, inst.toTypeExpr⟩
end

instance (priority := 20000) : ToExpr Expr := memoInst ⟨serNamed serExpr, mkConst ``Expr⟩ 3
instance (priority := 20000) : ToExpr Stmt := memoInst ⟨serNamed serStmt, mkConst ``Stmt⟩ 4
instance (priority := 20000) : ToExpr Func := memoInst ⟨serNamed serFunc, mkConst ``Func⟩ 5
instance (priority := 20000) : ToExpr Class := memoInst ⟨serNamed serClass, mkConst ``Class⟩ 6
instance (priority := 20000) : ToExpr Pat := memoInst ⟨serNamed serPat, mkConst ``Pat⟩ 7
instance (priority := 20000) : ToExpr Elem := memoInst ⟨serNamed serElem, mkConst ``Elem⟩ 8
instance (priority := 20000) : ToExpr Property := memoInst ⟨serNamed serProp, mkConst ``Property⟩ 9
instance (priority := 20000) : ToExpr Member := memoInst ⟨serNamed serMember, mkConst ``Member⟩ 10
instance (priority := 20000) : ToExpr Key := memoInst ⟨serNamed serKey, mkConst ``Key⟩ 11

/-! Types holding lists, derived over the instances above. -/

deriving instance Lean.ToExpr for Host.Ts.PKey
attribute [instance 20000] instToExprPKey
deriving instance Lean.ToExpr for Host.Ts.Val
attribute [instance 20000] instToExprVal
deriving instance Lean.ToExpr for Host.Ts.PropV
attribute [instance 20000] instToExprPropV
deriving instance Lean.ToExpr for Host.Ts.Abrupt
attribute [instance 20000] instToExprAbrupt
deriving instance Lean.ToExpr for Host.Ts.Comp
attribute [instance 20000] instToExprComp
deriving instance Lean.ToExpr for Host.Ts.InstMember
attribute [instance 20000] instToExprInstMember
deriving instance Lean.ToExpr for Host.Ts.IterSrc
attribute [instance 20000] instToExprIterSrc
deriving instance Lean.ToExpr for Host.Ts.CallF
attribute [instance 20000] instToExprCallF
deriving instance Lean.ToExpr for Host.Ts.ExprF
attribute [instance 20000] instToExprExprF
deriving instance Lean.ToExpr for Host.Ts.LitF
attribute [instance 20000] instToExprLitF
deriving instance Lean.ToExpr for Host.Ts.Target
attribute [instance 20000] instToExprTarget
deriving instance Lean.ToExpr for Host.Ts.AsgF
attribute [instance 20000] instToExprAsgF
deriving instance Lean.ToExpr for Host.Ts.StmtF
attribute [instance 20000] instToExprStmtF
deriving instance Lean.ToExpr for Host.Ts.LoopF
attribute [instance 20000] instToExprLoopF
deriving instance Lean.ToExpr for Host.Ts.BindF
attribute [instance 20000] instToExprBindF
deriving instance Lean.ToExpr for Host.Ts.FnF
attribute [instance 20000] instToExprFnF
deriving instance Lean.ToExpr for Host.Ts.Frame
attribute [instance 20000] instToExprFrame
deriving instance Lean.ToExpr for Host.Ts.Ctl
attribute [instance 20000] instToExprCtl
deriving instance Lean.ToExpr for Host.Ts.Susp
attribute [instance 20000] instToExprSusp
deriving instance Lean.ToExpr for Host.Ts.GenState
attribute [instance 20000] instToExprGenState
deriving instance Lean.ToExpr for Host.Ts.Reaction
attribute [instance 20000] instToExprReaction
deriving instance Lean.ToExpr for Host.Ts.PState
attribute [instance 20000] instToExprPState
deriving instance Lean.ToExpr for Host.Ts.Code
attribute [instance 20000] instToExprCode
deriving instance Lean.ToExpr for Host.Ts.Kind
attribute [instance 20000] instToExprKind
deriving instance Lean.ToExpr for Host.Ts.Obj
attribute [instance 20000] instToExprObj
deriving instance Lean.ToExpr for Host.Ts.HObj
attribute [instance 20000] instToExprHObj
deriving instance Lean.ToExpr for Host.Ts.Arg
attribute [instance 20000] instToExprArg
deriving instance Lean.ToExpr for Host.Ts.Ret
attribute [instance 20000] instToExprRet
deriving instance Lean.ToExpr for Host.Ts.Event
attribute [instance 20000] instToExprEvent
deriving instance Lean.ToExpr for Host.Ts.Job
attribute [instance 20000] instToExprJob
deriving instance Lean.ToExpr for Host.Ts.Aux
attribute [instance 20000] instToExprAux
deriving instance Lean.ToExpr for Host.Ts.St
attribute [instance 20000] instToExprSt
deriving instance Lean.ToExpr for Host.Ts.SymE
attribute [instance 20000] instToExprSymE
deriving instance Lean.ToExpr for Host.Ts.Ans
attribute [instance 20000] instToExprAns
deriving instance Lean.ToExpr for Host.Ts.SSrv
attribute [instance 20000] instToExprSSrv

end Host.Ts.Memo

namespace Host.Ts

/-! # Address-keyed stores for kernel reduction

A 4-ary trie on the base-4 digits of an address, least significant first:
the value of `n` sits where the digits of `n` end (`0` is the root).
Lookup and update cost one accelerated `Nat.mod`/`Nat.div` pair and two
comparisons per digit.

The kernel versions use the recursors directly (`Trie.rec` for lookup,
`Nat.rec` on a fuel of 32 digits for update, `Bool.rec` for branches):
`match`, `bif` and structural recursion unfold auxiliary definitions
(matchers, `casesOn`, `brecOn`) at every level. The code generator does not
support these recursors, so native evaluation uses the equivalent `match`
definitions (`implemented_by`); kernel checks never run them. -/

inductive Trie (α : Type) where
  | nil
  | node (v : Option α) (c0 c1 c2 c3 : Trie α)
deriving Inhabited

/-- `if b then x else y` by the recursor (kernel definitions only). -/
noncomputable abbrev brec {β : Type} (b : Bool) (x y : β) : β := Bool.rec (motive := fun _ => β) y x b

namespace Trie

def pickImpl {β : Type} (d : Nat) (a b c e : β) : β :=
  bif Nat.blt d 2 then (bif Nat.beq d 0 then a else b) else (bif Nat.beq d 2 then c else e)

/-- Child `d` (`d < 4`) of four. -/
@[implemented_by pickImpl]
def pick {β : Type} (d : Nat) (a b c e : β) : β :=
  brec (Nat.blt d 2) (brec (Nat.beq d 0) a b) (brec (Nat.beq d 2) c e)

partial def getImpl {α : Type} : Trie α → Nat → Option α
  | nil, _ => none
  | node v a b c e, n => bif Nat.beq n 0 then v else getImpl (pick (Nat.mod n 4) a b c e) (Nat.div n 4)

@[implemented_by getImpl]
def get {α : Type} (t : Trie α) : Nat → Option α :=
  Trie.rec (motive := fun _ => Nat → Option α) (fun _ => none)
    (fun v _ _ _ _ ia ib ic ie n => brec (Nat.beq n 0) v (pick (Nat.mod n 4) ia ib ic ie (Nat.div n 4))) t

def putImpl {α : Type} (d : Nat) (v : Option α) (a b c e x : Trie α) : Trie α :=
  bif Nat.blt d 2 then (bif Nat.beq d 0 then node v x b c e else node v a x c e)
  else (bif Nat.beq d 2 then node v a b x e else node v a b c x)

/-- `node` with child `d` replaced. -/
@[implemented_by putImpl]
def put {α : Type} (d : Nat) (v : Option α) (a b c e x : Trie α) : Trie α :=
  brec (Nat.blt d 2) (brec (Nat.beq d 0) (node v x b c e) (node v a x c e))
    (brec (Nat.beq d 2) (node v a b x e) (node v a b c x))

def setImpl {α : Type} : Nat → Trie α → Nat → α → Trie α
  | 0, t, _, _ => t
  | f + 1, t, n, x =>
    bif Nat.beq n 0 then (match t with
      | nil => node (some x) nil nil nil nil
      | node _ a b c e => node (some x) a b c e)
    else match t with
      | nil => put (Nat.mod n 4) none nil nil nil nil (setImpl f nil (Nat.div n 4) x)
      | node v a b c e => put (Nat.mod n 4) v a b c e (setImpl f (pick (Nat.mod n 4) a b c e) (Nat.div n 4) x)

/-- Update with fuel on the digits (32 base-4 digits cover 64 bits). -/
@[implemented_by setImpl]
def setF {α : Type} (f : Nat) : Trie α → Nat → α → Trie α :=
  Nat.rec (motive := fun _ => Trie α → Nat → α → Trie α) (fun t _ _ => t)
    (fun _ ih t n x => Trie.rec (motive := fun _ => Trie α)
      (brec (Nat.beq n 0) (node (some x) nil nil nil nil) (put (Nat.mod n 4) none nil nil nil nil (ih nil (Nat.div n 4) x)))
      (fun v a b c e _ _ _ _ => brec (Nat.beq n 0) (node (some x) a b c e)
        (put (Nat.mod n 4) v a b c e (ih (pick (Nat.mod n 4) a b c e) (Nat.div n 4) x))) t) f

def set {α : Type} (t : Trie α) (n : Nat) (a : α) : Trie α := setF 32 t n a

end Trie
end Host.Ts

namespace Host.Ts

/-! # Paged stores

A store keyed by addresses that are allocated in order (heap cells and
objects, FFI handles and graph nodes): a trie of groups (`n / 4096`), each a
trie of pages (`(n / 64) % 64`), each a trie of entries (`n % 64`). Lookup
costs the same digits as one trie; what changes is locality: consecutive
addresses share a page, so a run's step rewrites few pages and leaves the
others pointer-identical, which chunked runs name once and share across
states (`Stream`). Small addresses stay shallow: group `0` and page `0` sit at
the roots. -/

structure PTrie (α : Type) where
  root : Trie (Trie (Trie α))

namespace PTrie
variable {α : Type}

def nil : PTrie α := ⟨.nil⟩
instance : Inhabited (PTrie α) := ⟨nil⟩

def getImpl (t : PTrie α) (n : Nat) : Option α :=
  match t.root.get (n / 4096) with
  | some g => match g.get ((n / 64) % 64) with
    | some p => p.get (n % 64)
    | none => none
  | none => none

@[implemented_by getImpl]
def get (t : PTrie α) (n : Nat) : Option α :=
  Option.rec (motive := fun _ => Nat → Option α) (fun _ => none)
    (fun g n => Option.rec (motive := fun _ => Nat → Option α) (fun _ => none) (fun p n => p.get (Nat.mod n 64))
      (g.get (Nat.mod (Nat.div n 64) 64)) n)
    (t.root.get (Nat.div n 4096)) n

def orNilImpl {β : Type} : Option (Trie β) → Trie β
  | some t => t
  | none => .nil

/-- The trie an optional child holds (`nil` when absent). -/
@[implemented_by orNilImpl]
def orNil {β : Type} (o : Option (Trie β)) : Trie β := Option.rec (motive := fun _ => Trie β) .nil (fun t => t) o

def setImpl (t : PTrie α) (n : Nat) (a : α) : PTrie α :=
  let gi := n / 4096
  let pi := (n / 64) % 64
  let g := (t.root.get gi).getD .nil
  let p := (g.get pi).getD .nil
  ⟨t.root.set gi (g.set pi (p.set (n % 64) a))⟩

@[implemented_by setImpl]
def set (t : PTrie α) (n : Nat) (a : α) : PTrie α :=
  ⟨t.root.set (Nat.div n 4096)
    ((orNil (t.root.get (Nat.div n 4096))).set (Nat.mod (Nat.div n 64) 64)
      ((orNil ((orNil (t.root.get (Nat.div n 4096))).get (Nat.mod (Nat.div n 64) 64))).set (Nat.mod n 64) a))⟩

end PTrie
end Host.Ts

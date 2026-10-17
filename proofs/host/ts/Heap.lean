namespace Host.Ts

/-! # Address-keyed stores for kernel reduction

A binary trie on the bits of an address `n ≥ 1`, least significant first,
ending at the most significant bit: `1` is the root, `2k` goes left and
`2k+1` right with key `k`. Lookup and update cost `O(log n)` kernel steps
of accelerated `Nat` bit operations; `Array` would cost `O(n)` (`List.set`),
an association list `O(n)` too. Address `0` is never stored. -/

inductive Trie (α : Type) where
  | nil
  | node (v : Option α) (l r : Trie α)
deriving Inhabited

namespace Trie

def get {α : Type} : Trie α → Nat → Option α
  | nil, _ => none
  | node v l r, n =>
    bif Nat.ble n 1 then (bif Nat.beq n 1 then v else none) else
    bif Nat.beq (Nat.land n 1) 0 then get l (Nat.shiftRight n 1) else get r (Nat.shiftRight n 1)

/-- Update with structural fuel on the address bits (64 bits suffice). -/
def setF {α : Type} : Nat → Trie α → Nat → α → Trie α
  | 0, t, _, _ => t
  | f + 1, nil, n, a =>
    bif Nat.ble n 1 then node (some a) nil nil else
    bif Nat.beq (Nat.land n 1) 0 then node none (setF f nil (Nat.shiftRight n 1) a) nil
    else node none nil (setF f nil (Nat.shiftRight n 1) a)
  | f + 1, node v l r, n, a =>
    bif Nat.ble n 1 then node (some a) l r else
    bif Nat.beq (Nat.land n 1) 0 then node v (setF f l (Nat.shiftRight n 1) a) r
    else node v l (setF f r (Nat.shiftRight n 1) a)

def set {α : Type} (t : Trie α) (n : Nat) (a : α) : Trie α := setF 64 t n a

end Trie
end Host.Ts

import host.ts.Core

namespace Host.Ts

def repeatBlock (block : List α) : Nat → List α
  | 0 => []
  | n + 1 => block ++ repeatBlock block n

theorem repeatBlock_length (block : List α) (n : Nat) :
    (repeatBlock block n).length = n * block.length := by
  induction n with
  | zero => simp [repeatBlock]
  | succ n ih => simp only [repeatBlock, List.length_append, ih, Nat.succ_mul]; omega

theorem repeatBlock_succ_right (block : List α) (n : Nat) :
    repeatBlock block (n+1) = repeatBlock block n ++ block := by
  induction n with
  | zero => simp [repeatBlock]
  | succ n ih =>
    change block ++ repeatBlock block (n+1) = (block ++ repeatBlock block n) ++ block
    rw [ih, List.append_assoc]

def fillBlockFold (block : List α) (bs : List α) (start count : Nat) : List α :=
  (List.range count).foldl (fun bs t =>
    bs.take (start + t * block.length) ++ block ++ bs.drop (start + (t+1) * block.length)) bs

theorem fillBlockFold_eq (block : List α) (bs : List α) (start count : Nat)
    (h : start ≤ bs.length) :
    fillBlockFold block bs start count =
      bs.take start ++ repeatBlock block count ++ bs.drop (start + count * block.length) := by
  induction count with
  | zero => simp [fillBlockFold, repeatBlock]
  | succ n ih =>
    simp only [fillBlockFold, List.range_succ, List.foldl_append, List.foldl_cons,
      List.foldl_nil] at ih ⊢
    rw [ih]
    have hlen : (bs.take start ++ repeatBlock block n).length = start + n * block.length := by
      simp only [List.length_append, List.length_take, Nat.min_eq_left h, repeatBlock_length]
    have htake := List.take_left (l₁ := bs.take start ++ repeatBlock block n)
      (l₂ := bs.drop (start + n * block.length))
    have hdrop := List.drop_left (l₁ := bs.take start ++ repeatBlock block n)
      (l₂ := bs.drop (start + n * block.length))
    rw [hlen] at htake hdrop
    rw [htake]
    have hadd : start + (n + 1) * block.length = start + n * block.length + block.length := by
      rw [Nat.succ_mul]; omega
    rw [hadd, ← List.drop_drop, hdrop, List.drop_drop]
    rw [repeatBlock_succ_right]
    simp only [List.append_assoc]

theorem cellParts_length (k : EltK) (c : Cell) (n i : Nat) :
    (cellParts k c n i).length = n := by
  induction n generalizing i with
  | zero => rfl
  | succ n ih => simp only [cellParts, List.length_cons, ih]

/-- A contiguous fill traverses each byte range once. The fallback retains
the original behavior even for malformed views starting past the buffer. -/
def fillCells (k : EltK) (c : Cell) (bs : List Byte) (start count : Nat) : List Byte :=
  let block := cellParts k c k.size 0
  if start ≤ bs.length then
    bs.take start ++ repeatBlock block count ++ bs.drop (start + count * k.size)
  else fillBlockFold block bs start count

theorem fillCells_eq_fold (k : EltK) (c : Cell) (bs : List Byte) (start count : Nat) :
    fillCells k c bs start count = fillBlockFold (cellParts k c k.size 0) bs start count := by
  unfold fillCells
  split
  · rw [fillBlockFold_eq _ _ _ _ ‹_›, cellParts_length]
  · rfl

/-- Exact equality to the original typed-array fill, for every byte list,
offset, element interval, and stored value. No view invariant is required. -/
theorem fillCells_eq_original (k : EltK) (c : Cell) (bs : List Byte) (off i count : Nat) :
    fillCells k c bs (off + i * k.size) count =
      (List.range count).foldl (fun bs t => writeCell k c bs (off + (i+t) * k.size)) bs := by
  rw [fillCells_eq_fold]
  unfold fillBlockFold
  congr 1
  funext bs t
  simp only [writeCell, cellParts_length, Nat.add_mul, Nat.one_mul, Nat.add_assoc]

end Host.Ts

import host.load.run.full.LoadProgram
import host.load.ProgramValues

namespace Host.Route.Sat
open Host.Mlx Host.Mlx.FfiEval Host.Load.Program
open Host.Load.Run.Full (code)

/-! # A model of the checkpoint

`Leaves code weights` asks one value per `(file, key)` with the header of every load node naming it, so it would be
unsatisfiable if two load nodes named one key at different headers. No two load nodes name one key: their hashes are
distinct (`loadHashes_fresh`, a kernel check on the actual graph), and equal keys have equal hashes. The model is the
zero tensor at each node's header. -/

/-- The key of a load node. -/
def loadKey (n : Node) : List Char :=
  match n.op with
  | .load _ k => k
  | _ => []

def isLoad (n : Node) : Bool :=
  match n.op with
  | .load _ _ => true
  | _ => false

/-- A hash of a key, only used to compare keys cheaply in the kernel. Modulo `2 ^ 19 - 1`, so the bitmask of
`fresh` stays small. -/
def keyHash (k : List Char) : Nat :=
  k.foldl (fun h c => (h * 257 + c.toNat) % 524287) 0

/-- One pass over the hashes with a bitmask of those seen: no hash repeats. Linear, so the kernel's cost on the
graph's 1655 keys stays small. -/
def fresh : Nat → List Nat → Bool
  | _, [] => true
  | mask, x :: xs => !mask.testBit x && fresh (mask ||| 2 ^ x) xs

theorem fresh_unseen : ∀ (l : List Nat) (mask : Nat), fresh mask l = true → ∀ y ∈ l, mask.testBit y = false
  | [], _, _, _, hy => by cases hy
  | x :: xs, mask, hn, y, hy => by
    simp only [fresh, Bool.and_eq_true, Bool.not_eq_true'] at hn
    rcases List.mem_cons.mp hy with rfl | hy'
    · exact hn.1
    · have := fresh_unseen xs _ hn.2 y hy'
      rw [Nat.testBit_or, Bool.or_eq_false_iff] at this
      exact this.1

theorem fresh_ne {x : Nat} {xs : List Nat} {mask : Nat} (h : fresh (mask ||| 2 ^ x) xs = true) {y : Nat}
    (hy : y ∈ xs) : y ≠ x := by
  intro he
  subst he
  have := fresh_unseen xs _ h y hy
  rw [Nat.testBit_or, Nat.testBit_two_pow_self] at this
  simp at this

/-- A function with no repeated values on a list is injective on it. -/
theorem inj_of_fresh {α : Type} (h : α → Nat) :
    ∀ (l : List α) (mask : Nat), fresh mask (l.map h) = true → ∀ a ∈ l, ∀ b ∈ l, h a = h b → a = b
  | [], _, _, a, ha, _, _, _ => by cases ha
  | x :: xs, mask, hn, a, ha, b, hb, hab => by
    simp only [List.map_cons, fresh, Bool.and_eq_true] at hn
    obtain ⟨-, ht⟩ := hn
    have hne : ∀ c ∈ xs, h c ≠ h x := fun c hc => fresh_ne ht (List.mem_map.mpr ⟨c, hc, rfl⟩)
    rcases List.mem_cons.mp ha with rfl | ha' <;> rcases List.mem_cons.mp hb with rfl | hb'
    · rfl
    · exact absurd hab.symm (hne b hb')
    · exact absurd hab (hne a ha')
    · exact inj_of_fresh h xs _ ht a ha' b hb' hab

/-- **The actual graph's load nodes have distinct key hashes.** -/
theorem loadHashes_fresh : fresh 0 ((code.filter isLoad).map (fun n => keyHash (loadKey n))) = true := by
  decide +kernel

/-- **Every load node's dtype is an MLX dtype.** -/
theorem load_dtypes : code.all (fun n => !isLoad n || (Dtype.ofCode n.dtype).isSome) = true := by
  decide +kernel

/-- Two load nodes of the graph naming one key are one node. -/
theorem load_unique {n m : Node} (hn : n ∈ code) (hm : m ∈ code) {file key : List Char}
    (hno : n.op = .load file key) (hmo : m.op = .load file key) : n = m := by
  refine inj_of_fresh (fun n => keyHash (loadKey n)) _ 0 loadHashes_fresh n ?_ m ?_ ?_
  · exact List.mem_filter.mpr ⟨hn, by simp [isLoad, hno]⟩
  · exact List.mem_filter.mpr ⟨hm, by simp [isLoad, hmo]⟩
  · simp [loadKey, hno, hmo]

/-- The model's checkpoint: the zero tensor at the header of the load node naming the tensor. -/
noncomputable def modelWeights (file key : List Char) : Option Value :=
  (code.find? fun n => decide (n.op = .load file key)).bind fun n =>
    (Dtype.ofCode n.dtype).map fun d => ⟨d, n.shape, fun _ => 0⟩

/-- The environment of the model. -/
noncomputable def modelEnv : Env InKey := ⟨modelWeights, fun _ => none⟩

/-- **`Leaves` at the model, for the actual graph.** -/
theorem modelLeaves : Leaves code modelEnv.weights := by
  intro i n file key hi hop
  have hn : n ∈ code := List.mem_of_getElem? hi
  have hfind : (code.find? fun m => decide (m.op = .load file key)).isSome = true := by
    rw [List.find?_isSome]
    exact ⟨n, hn, by simp [hop]⟩
  obtain ⟨m, hm⟩ := Option.isSome_iff_exists.mp hfind
  have hmem : m ∈ code := List.mem_of_find?_eq_some hm
  have hmop : m.op = .load file key := by simpa using List.find?_some hm
  have hmn : m = n := load_unique hmem hn hmop hop
  subst hmn
  have hd : (Dtype.ofCode m.dtype).isSome = true := by
    have := List.all_eq_true.mp load_dtypes m hmem
    simpa [isLoad, hmop] using this
  obtain ⟨d, hd'⟩ := Option.isSome_iff_exists.mp hd
  refine ⟨⟨d, m.shape, fun _ => 0⟩, ?_, ofCode_some_code hd', rfl⟩
  show modelWeights file key = _
  simp [modelWeights, hm, hd']

/-- **`TypedCheckpoint` at the model**: every element is zero. -/
theorem modelTyped : TypedCheckpoint modelEnv.weights := by
  intro file key v hv i _
  have hzero : v.elems i = 0 := by
    change modelWeights file key = some v at hv
    unfold modelWeights at hv
    rcases hf : code.find? (fun n => decide (n.op = .load file key)) with _ | n
    · simp [hf] at hv
    · rcases hd : Dtype.ofCode n.dtype with _ | d
      · simp [hf, hd] at hv
      · simp only [hf, hd, Option.bind_some, Option.map_some, Option.some.injEq] at hv
        rw [← hv]
  rw [hzero]
  exact Nat.two_pow_pos _

end Host.Route.Sat

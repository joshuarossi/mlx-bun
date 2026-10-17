namespace Inference.Models.Qwen.CheckpointFile

-- Safetensors layout as a Lean definition: an 8-byte little-endian header
-- length, a JSON header, then payload bytes addressed by data_offsets.
-- The JSON subset is objects, arrays, escape-free strings and nonnegative
-- integers; anything else is rejected. Imports only Init, so the runner can
-- compile this module natively without changing what it means.
inductive Json where
  | num (n : Nat)
  | str (s : String)
  | arr (xs : List Json)
  | obj (kvs : List (String × Json))

def space (c : UInt8) : Bool := c == 32 || c == 9 || c == 10 || c == 13

def skip (b : ByteArray) : Nat → Nat → Nat
  | 0, p => p
  | f+1, p => if p < b.size && space b[p]! then skip b f (p+1) else p

def digits (b : ByteArray) : Nat → Nat → Nat → Nat × Nat
  | 0, p, a => (a, p)
  | f+1, p, a =>
    if p < b.size && 48 ≤ b[p]! && b[p]! ≤ 57 then digits b f (p+1) (10*a + (b[p]! - 48).toNat) else (a, p)

def stringEnd (b : ByteArray) : Nat → Nat → Option Nat
  | 0, _ => none
  | f+1, p =>
    if p < b.size then
      if b[p]! == 34 then some p else if b[p]! == 92 || b[p]! < 32 then none else stringEnd b f (p+1)
    else none

def string (b : ByteArray) (p : Nat) : Option (String × Nat) :=
  match stringEnd b b.size p with
  | some e => (String.fromUTF8? (b.extract p e)).map fun s => (s, e+1)
  | none => none

mutual
def value (b : ByteArray) : Nat → Nat → Option (Json × Nat)
  | 0, _ => none
  | f+1, p =>
    let p := skip b b.size p
    if b[p]! == 34 then (string b (p+1)).map fun (s, q) => (.str s, q)
    else if b[p]! == 91 then
      if b[skip b b.size (p+1)]! == 93 then some (.arr [], skip b b.size (p+1) + 1) else elements b f (p+1) []
    else if b[p]! == 123 then
      if b[skip b b.size (p+1)]! == 125 then some (.obj [], skip b b.size (p+1) + 1) else members b f (p+1) []
    else if p < b.size && 48 ≤ b[p]! && b[p]! ≤ 57 then
      let (n, q) := digits b b.size p 0
      some (.num n, q)
    else none
def elements (b : ByteArray) : Nat → Nat → List Json → Option (Json × Nat)
  | 0, _, _ => none
  | f+1, p, acc =>
    match value b f p with
    | some (v, q) =>
      let q := skip b b.size q
      if b[q]! == 44 then elements b f (q+1) (v :: acc)
      else if b[q]! == 93 then some (.arr (v :: acc).reverse, q+1) else none
    | none => none
def members (b : ByteArray) : Nat → Nat → List (String × Json) → Option (Json × Nat)
  | 0, _, _ => none
  | f+1, p, acc =>
    let p := skip b b.size p
    if b[p]! == 34 then
      match string b (p+1) with
      | some (k, q) =>
        let q := skip b b.size q
        if b[q]! == 58 then
          match value b f (q+1) with
          | some (v, r) =>
            let r := skip b b.size r
            if b[r]! == 44 then members b f (r+1) ((k, v) :: acc)
            else if b[r]! == 125 then some (.obj ((k, v) :: acc).reverse, r+1) else none
          | none => none
        else none
      | none => none
    else none
end

/-- The whole buffer is one JSON value, optionally surrounded by whitespace. -/
def parse (b : ByteArray) : Option Json :=
  match value b (b.size+1) 0 with
  | some (v, q) => if skip b b.size q = b.size then some v else none
  | none => none

/-- A key's value, only when the key occurs exactly once. -/
def lookup1 (k : String) (kvs : List (String × Json)) : Option Json :=
  match kvs.filter (·.1 == k) with
  | [(_, v)] => some v
  | _ => none

def nats : List Json → Option (List Nat)
  | [] => some []
  | .num n :: rest => (nats rest).map (n :: ·)
  | _ => none

structure Entry where
  dtype : String
  shape : List Nat
  begin : Nat
  stop : Nat
  deriving DecidableEq

def entry : Json → Option Entry
  | .obj kvs =>
    match lookup1 "dtype" kvs, lookup1 "shape" kvs, lookup1 "data_offsets" kvs with
    | some (.str d), some (.arr s), some (.arr o) =>
      match nats s, nats o with
      | some shape, some [begin, stop] => some ⟨d, shape, begin, stop⟩
      | _, _ => none
    | _, _, _ => none
  | _ => none

/-- Little-endian unsigned integer of `k` bytes at offset `o`. -/
def le (b : ByteArray) (o : Nat) : Nat → Nat
  | 0 => 0
  | k+1 => b[o]!.toNat + 256 * le b (o+1) k

/-- Header object of a file, given any prefix that contains the whole header. -/
def header (head : ByteArray) : Option (List (String × Json)) :=
  if 8 + le head 0 8 ≤ head.size then
    match parse (head.extract 8 (8 + le head 0 8)) with
    | some (.obj kvs) => some kvs
    | _ => none
  else none

/-- Entry and payload bytes `[8+n+begin, 8+n+stop)` of a named tensor in a full file. -/
def tensor (file : ByteArray) (name : String) : Option (Entry × ByteArray) :=
  match header file with
  | some kvs =>
    match (lookup1 name kvs).bind entry with
    | some e =>
      if e.begin ≤ e.stop ∧ 8 + le file 0 8 + e.stop ≤ file.size then
        some (e, file.extract (8 + le file 0 8 + e.begin) (8 + le file 0 8 + e.stop))
      else none
    | none => none
  | none => none

def payload (file : ByteArray) (name : String) : Option ByteArray := (tensor file name).map (·.2)

/-- Shard file for a tensor according to model.safetensors.index.json. -/
def weightMap (index : ByteArray) (name : String) : Option String :=
  match parse index with
  | some (.obj kvs) =>
    match lookup1 "weight_map" kvs with
    | some (.obj m) =>
      match lookup1 name m with
      | some (.str s) => some s
      | _ => none
    | _ => none
  | _ => none

/-- Little-endian 16-bit word `i` of a payload. -/
def word (b : ByteArray) (i : Nat) : Nat := b[2*i]!.toNat + 256 * b[2*i+1]!.toNat

/-- Partial file contents from ranged reads: file size, a prefix, and byte ranges. -/
structure View where
  size : Nat
  head : ByteArray
  ranges : List (Nat × ByteArray)

/-- The view's bytes are the file's bytes at the recorded offsets. -/
def View.Faithful (v : View) (file : ByteArray) : Prop :=
  file.size = v.size ∧ file.extract 0 v.head.size = v.head ∧
    ∀ r ∈ v.ranges, r.1 + r.2.size ≤ file.size ∧ file.extract r.1 (r.1 + r.2.size) = r.2

def View.tensorWith (v : View) (kvs : List (String × Json)) (name : String) : Option (Entry × ByteArray) :=
  match (lookup1 name kvs).bind entry with
  | some e =>
    if e.begin ≤ e.stop ∧ 8 + le v.head 0 8 + e.stop ≤ v.size then
      match v.ranges.find? (fun r => r.1 == 8 + le v.head 0 8 + e.begin && r.2.size == e.stop - e.begin) with
      | some r => some (e, r.2)
      | none => none
    else none
  | none => none

theorem getElem!_extract (file : ByteArray) (h i : Nat) (hi : i < h) (hs : h ≤ file.size) :
    (file.extract 0 h)[i]! = file[i]! := by
  have hlt : i < (file.extract 0 h).size := by simp only [ByteArray.size_extract]; omega
  rw [getElem!_pos (file.extract 0 h) i hlt, getElem!_pos file i (Nat.lt_of_lt_of_le hi hs)]
  simp only [ByteArray.getElem_extract, Nat.zero_add]

theorem le_extract (file : ByteArray) (h : Nat) (hs : h ≤ file.size) :
    ∀ k o, o + k ≤ h → le (file.extract 0 h) o k = le file o k
  | 0, _, _ => rfl
  | k+1, o, hk => by
    simp only [le]
    rw [getElem!_extract file h o (by omega) hs, le_extract file h hs k (o+1) (by omega)]

theorem header_view (v : View) (file : ByteArray) (faithful : v.Faithful file) {kvs}
    (hv : header v.head = some kvs) : header file = some kvs ∧ le v.head 0 8 = le file 0 8 := by
  obtain ⟨_, hhead, _⟩ := faithful
  have hsize : v.head.size ≤ file.size := by
    have := congrArg ByteArray.size hhead
    simp only [ByteArray.size_extract] at this
    omega
  unfold header at hv
  split at hv
  · next hlen =>
    have h8 : 8 ≤ v.head.size := by omega
    have hle : le v.head 0 8 = le file 0 8 := by
      rw [← hhead]; exact le_extract file v.head.size hsize 8 0 (by omega)
    have hsub : v.head.extract 8 (8 + le v.head 0 8) = file.extract 8 (8 + le file 0 8) := by
      calc v.head.extract 8 (8 + le v.head 0 8) = (file.extract 0 v.head.size).extract 8 (8 + le file 0 8) := by
            rw [hle, hhead]
        _ = file.extract 8 (8 + le file 0 8) := by
            rw [ByteArray.extract_extract, Nat.min_eq_left (by omega)]
            simp only [Nat.zero_add]
    refine ⟨?_, hle⟩
    unfold header
    have hin : 8 + le file 0 8 ≤ file.size := by omega
    simp only [hin, ↓reduceIte, ← hsub]
    exact hv
  · exact absurd hv (by simp)

theorem tensorWith_sound (v : View) (file : ByteArray) (faithful : v.Faithful file) {kvs name t}
    (hv : header v.head = some kvs) (ht : v.tensorWith kvs name = some t) : tensor file name = some t := by
  obtain ⟨hfile, hle⟩ := header_view v file faithful hv
  obtain ⟨hsize, _, hranges⟩ := faithful
  unfold View.tensorWith at ht
  unfold tensor
  rw [hfile]
  simp only
  split at ht
  · next e he =>
    split at ht
    · next hb =>
      have h1 : e.begin ≤ e.stop := hb.1
      have h2 : 8 + le file 0 8 + e.stop ≤ file.size := by rw [← hle, hsize]; exact hb.2
      simp only [h1, h2, and_self, ↓reduceIte]
      split at ht
      · next r hr =>
        have hp := List.find?_some hr
        have hmem := List.mem_of_find?_eq_some hr
        simp only [Bool.and_eq_true, beq_iff_eq] at hp
        obtain ⟨hstart, hlen⟩ := hp
        have hr2 := (hranges r hmem).2
        rw [hstart, hlen] at hr2
        have hend : 8 + le v.head 0 8 + e.begin + (e.stop - e.begin) = 8 + le v.head 0 8 + e.stop := by omega
        rw [hend, hle] at hr2
        rw [hr2]
        exact ht
      · exact absurd ht (by simp)
    · exact absurd ht (by simp)
  · exact absurd ht (by simp)

/-- Membership table: entry `w` is 1 for every listed word `w`. -/
def table (words : List Nat) : ByteArray :=
  words.foldl (fun t w => t.set! w 1) (ByteArray.mk (Array.replicate 65536 0))

theorem zeros_getElem! (n w : Nat) : (ByteArray.mk (Array.replicate n 0))[w]! = 0 := by
  by_cases hi : w < n
  · have hs : w < (ByteArray.mk (Array.replicate n 0)).size := by
      simp only [ByteArray.size, Array.size_replicate]; exact hi
    rw [getElem!_pos _ w hs, ByteArray.getElem_eq_getElem_data]
    exact Array.getElem_replicate ..
  · have hs : ¬ w < (ByteArray.mk (Array.replicate n 0)).size := by
      simp only [ByteArray.size, Array.size_replicate]; exact hi
    rw [getElem!_neg _ w hs]
    rfl

theorem table_mem (words : List Nat) (w : Nat) (hw : (table words)[w]! = 1) : w ∈ words := by
  suffices ∀ (ws : List Nat) (t : ByteArray), (ws.foldl (fun t w => t.set! w 1) t)[w]! = 1 → t[w]! = 1 ∨ w ∈ ws by
    rcases this words _ hw with h | h
    · rw [zeros_getElem!] at h
      exact absurd h (by decide)
    · exact h
  intro ws
  induction ws with
  | nil => intro t h; exact Or.inl h
  | cons x rest ih =>
    intro t h
    rcases ih _ h with h | h
    · by_cases hx : x = w
      · exact Or.inr (hx ▸ List.mem_cons_self)
      · rw [ByteArray.getElem!_set!_ne _ _ _ _ hx] at h
        exact Or.inl h
    · exact Or.inr (List.mem_cons_of_mem _ h)

/-- Every word below `n` is marked in table `t`. -/
def allWords (t b : ByteArray) : Nat → Bool
  | 0 => true
  | n+1 => t[word b n]! == 1 && allWords t b n

theorem allWords_sound (t b : ByteArray) : ∀ n, allWords t b n = true → ∀ i < n, t[word b i]! = 1
  | 0, _, _, hi => absurd hi (Nat.not_lt_zero _)
  | n+1, h, i, hi => by
    simp only [allWords, Bool.and_eq_true, beq_iff_eq] at h
    rcases Nat.lt_succ_iff_lt_or_eq.mp hi with hi | hi
    · exact allWords_sound t b n h.2 i hi
    · exact hi ▸ h.1

end Inference.Models.Qwen.CheckpointFile

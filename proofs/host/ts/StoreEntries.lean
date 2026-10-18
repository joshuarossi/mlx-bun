import host.ts.StoreLaws

namespace Host.Ts.Trie
variable {α : Type}

/-- Finite enumeration may include unreachable zero-child entries; every
successful lookup is included, which suffices to certify global bounds. -/
def entries : Trie α → List (Nat × α)
  | .nil => []
  | .node v a b c e =>
      (v.toList.map (fun x => (0,x))) ++
      ((entries a).map (fun (n,x) => (4*n,x)) ++
      ((entries b).map (fun (n,x) => (4*n+1,x)) ++
      ((entries c).map (fun (n,x) => (4*n+2,x)) ++
      (entries e).map (fun (n,x) => (4*n+3,x)))))

theorem get_mem_entries (t : Trie α) (n : Nat) (x : α) (h : t.get n = some x) : (n,x) ∈ t.entries := by
  induction t generalizing n with
  | nil => cases h
  | node v a b c e ia ib ic ie =>
    rw [get_node] at h
    by_cases hz : n = 0
    · subst n
      rw [ite_eq_left rfl] at h
      rw [entries,h]
      simp
    · rw [ite_eq_right hz] at h
      have hm : n % 4 < 4 := Nat.mod_lt _ (by decide)
      have hd : n % 4 = 0 ∨ n % 4 = 1 ∨ n % 4 = 2 ∨ n % 4 = 3 := by omega
      rcases hd with hd | hd | hd | hd
      · have hn : a.get (n/4) = some x := by simpa only [hd,pick,brec,Nat.blt,Nat.beq,Nat.ble] using h
        have he : 4*(n/4) = n := by omega
        have member : (n,x) ∈ (entries a).map (fun (k,v) => (4*k,v)) := by
          exact List.mem_map.mpr ⟨(n/4,x),ia (n/4) hn,by simp only [he]⟩
        simp only [entries,List.mem_append]
        exact .inr (.inl member)
      · have hn : b.get (n/4) = some x := by simpa only [hd,pick,brec,Nat.blt,Nat.beq,Nat.ble] using h
        have he : 4*(n/4)+1 = n := by omega
        have member : (n,x) ∈ (entries b).map (fun (k,v) => (4*k+1,v)) := by
          exact List.mem_map.mpr ⟨(n/4,x),ib (n/4) hn,by simp only [he]⟩
        simp only [entries,List.mem_append]
        exact .inr (.inr (.inl member))
      · have hn : c.get (n/4) = some x := by simpa only [hd,pick,brec,Nat.blt,Nat.beq,Nat.ble] using h
        have he : 4*(n/4)+2 = n := by omega
        have member : (n,x) ∈ (entries c).map (fun (k,v) => (4*k+2,v)) := by
          exact List.mem_map.mpr ⟨(n/4,x),ic (n/4) hn,by simp only [he]⟩
        simp only [entries,List.mem_append]
        exact .inr (.inr (.inr (.inl member)))
      · have hn : e.get (n/4) = some x := by simpa only [hd,pick,brec,Nat.blt,Nat.beq,Nat.ble] using h
        have he : 4*(n/4)+3 = n := by omega
        have member : (n,x) ∈ (entries e).map (fun (k,v) => (4*k+3,v)) := by
          exact List.mem_map.mpr ⟨(n/4,x),ie (n/4) hn,by simp only [he]⟩
        simp only [entries,List.mem_append]
        exact .inr (.inr (.inr (.inr member)))

end Host.Ts.Trie

namespace Host.Ts.PTrie
variable {α : Type}

def entries (t : PTrie α) : List (Nat × α) :=
  t.root.entries.flatMap fun (g,group) => group.entries.flatMap fun (p,page) =>
    page.entries.map fun (i,x) => (4096*g+64*p+i,x)

theorem get_mem_entries (t : PTrie α) (n : Nat) (x : α) (h : t.get n = some x) : (n,x) ∈ t.entries := by
  rw [get_eq] at h
  cases hg : t.root.get (n/4096) with
  | none => simp only [hg,orNil_none,Trie.get_nil] at h; cases h
  | some group =>
    cases hp : group.get ((n/64)%64) with
    | none => simp only [hg,hp,orNil_some,orNil_none,Trie.get_nil] at h; cases h
    | some page =>
      have hv : page.get (n%64) = some x := by simpa only [hg,hp,orNil_some] using h
      apply List.mem_flatMap.mpr
      refine ⟨(n/4096,group),Trie.get_mem_entries _ _ _ hg,?_⟩
      apply List.mem_flatMap.mpr
      refine ⟨((n/64)%64,page),Trie.get_mem_entries _ _ _ hp,?_⟩
      apply List.mem_map.mpr
      refine ⟨(n%64,x),Trie.get_mem_entries _ _ _ hv,?_⟩
      have he : 4096*(n/4096)+64*((n/64)%64)+n%64 = n := by omega
      simp only [he]

/-- A finite list certificate covers every successful lookup, including keys
outside the nominal machine-word range. No address-domain truncation occurs. -/
theorem bound_of_entries (t : PTrie α) (bound : Nat)
    (h : ∀ kv ∈ t.entries, kv.1 < bound) : ∀ n x, t.get n = some x → n < bound := by
  intro n x hn
  exact h (n,x) (get_mem_entries t n x hn)

def checkBound (t : PTrie α) (bound : Nat) : Bool :=
  t.entries.all fun kv => Nat.blt kv.1 bound

theorem bound_of_check (t : PTrie α) (bound : Nat) (h : t.checkBound bound = true) :
    ∀ n x, t.get n = some x → n < bound := by
  apply bound_of_entries
  intro kv member
  have hi := List.all_eq_true.mp h kv member
  simpa only [Nat.blt_eq] using hi

end Host.Ts.PTrie

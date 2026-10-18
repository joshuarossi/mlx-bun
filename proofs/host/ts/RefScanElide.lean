import host.ts.RefScan
set_option Elab.async false

namespace Host.Ts.RefScan

/-- This is precisely the existing import filter, separated from its scan. -/
def filterItem (refs : List Nat) : Item → Option Item
  | .import_ [] src => some (.import_ [] src)
  | .import_ specs src => match specs.filter (fun sp => refs.any (Nat.beq (pack (specLocal sp)))) with
    | [] => none
    | sp => some (.import_ sp src)
  | it => some it

def elideItems (refs : List Nat) (m : Module) : Module := m.filterMap (filterItem refs)

theorem filterItem_denote (refs : List Nat) (it : Item) (acc : List Nat) :
    ((filterItem refs it).toList.map Task.item).foldl (fun a t => t.denote a) acc =
      (Task.item it).denote acc := by
  cases it with
  | import_ specs src =>
    cases specs with
    | nil => rfl
    | cons sp specs =>
      simp only [filterItem]
      cases (sp::specs).filter (fun sp => refs.any (Nat.beq (pack (specLocal sp)))) <;> rfl
  | _ => rfl

theorem filterMap_denote (refs : List Nat) (m : Module) (acc : List Nat) :
    ((elideItems refs m).map Task.item).foldl (fun a t => t.denote a) acc =
      (m.map Task.item).foldl (fun a t => t.denote a) acc := by
  induction m generalizing acc with
  | nil => rfl
  | cons it rest ih =>
    have hi := filterItem_denote refs it acc
    cases hf : filterItem refs it with
    | none =>
      simp only [elideItems, List.filterMap_cons, hf, List.map_cons, List.foldl_cons] at *
      simp only [Option.toList_none, List.map_nil, List.foldl_nil] at hi
      rw [ih]
      exact congrArg (fun a => (rest.map Task.item).foldl (fun a t => t.denote a) a) hi
    | some out =>
      simp only [elideItems, List.filterMap_cons, hf, List.map_cons, List.foldl_cons] at *
      simp only [Option.toList_some, List.map_cons, List.map_nil, List.foldl_cons, List.foldl_nil] at hi
      rw [ih, hi]

/-- Dropping or narrowing imports cannot change expression references. The
second scan in `addUser` therefore reuses the first checked result. -/
theorem refsM_elideItems (refs : List Nat) (m : Module) : refsM (elideItems refs m) = refsM m := by
  have h := filterMap_denote refs m []
  change (initial (elideItems refs m)).denote = (initial m).denote at h
  simpa only [initial_denote] using h

theorem elide_eq (m : Module) (refs : List Nat) (h : refsM m = refs) :
    elide m = bif refs.any (Nat.beq 0) then none else some (elideItems refs m) := by
  unfold elide
  rw [h]
  rfl

theorem usesMeta_elideItems (refs : List Nat) (m : Module) (h : refsM m = refs) :
    usesMeta (elideItems refs m) = refs.any (Nat.beq (pack nMeta)) := by
  rw [usesMeta, refsM_elideItems, h]

/-- Exposes the original linker action after a proved scan result, preserving
its allocation order and both import-elision and import.meta decisions. -/
def addUserScanned {S : Type} (root : List Char) (u : UMod) (refs : List Nat) : B S (Option LMod) := do
  bif refs.any (Nat.beq 0) then pure none else do
    let items := elideItems refs u.ast
    let own ← allocOwn (items.flatMap itemNames)
    let own ← bif refs.any (Nat.beq (pack nMeta)) then do
        let m ← metaObj (root ++ '/' :: u.path)
        let c ← modifyGet fun s => s.alloc (.cell (some m))
        pure ((nMeta,c) :: own)
      else pure own
    let (ns,nc) ← allocNs
    pure (some ⟨u.path, items, own, ns, nc⟩)

theorem addUser_eq_scanned {S : Type} (root : List Char) (u : UMod) (refs : List Nat)
    (h : refsM u.ast = refs) : addUser (S := S) root u = addUserScanned root u refs := by
  unfold addUser
  rw [elide_eq u.ast refs h]
  cases hz : refs.any (Nat.beq 0) <;>
    simp only [hz, Bool.cond_false, Bool.cond_true, addUserScanned]
  · rw [usesMeta_elideItems refs u.ast h]

end Host.Ts.RefScan

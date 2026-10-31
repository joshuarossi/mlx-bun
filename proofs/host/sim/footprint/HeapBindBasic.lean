import host.sim.footprint.HeapStmt
import host.sim.dispatch.Bind

namespace Host.Ts.Sim.HeapFoot
open Host.Ts Host.Ts.Sim Conv BufSim StmtSim
open Host.Mlx.Ffi.FullKeep (AllX)

theorem typeErr_fresh {S : Type} (s : St S) (msg : List Char) : AllX (Fresh s) (typeErr s msg) :=
  AllX.pure ((Fresh.alloc _ _).trans (Fresh.of_same ⟨rfl, rfl⟩))

theorem getV_fresh (F : Ffi) (s : St F.S) (v : Val) (k : PKey) :
    AllX (Fresh s) (getV F s v k) := by
  cases v <;> simp only [getV]
  all_goals first
    | exact typeErr_fresh _ _
    | exact AllX.bind' (lookup_lawful _ _ _ _) fun p =>
        AllX.pure (Fresh.of_same (readProp_same _ _ _ _))

theorem startIter_fresh (F : Ffi) (s : St F.S) (v : Val) :
    AllX (Fresh s) (startIter F s v) :=
  (Fresh.of_same (s := s) (u := s.push _) ⟨rfl, rfl⟩).after (getV_fresh _ _ _ _)

theorem arrNext_fresh (F : Ffi) (s : St F.S) (rest : Option Pat) (env : Env)
    (mode : BindMode) (kind : DeclKind) : ∀ (ps : List (Option Pat)) (vs : List Val),
      AllX (Fresh s) (arrNext F s ps rest vs env mode kind)
  | [], _ => by
    cases rest with
    | none => exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
    | some r => exact AllX.pure ((Fresh.alloc _ _).trans (Fresh.of_same ⟨rfl, rfl⟩))
  | none :: ps, vs => arrNext_fresh F s rest env mode kind ps vs.tail
  | some _ :: _, _ => AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)

theorem dataProps_lawful (F : Ffi) (s : St F.S) (o : Obj) : Lawful (dataProps F s o) := by
  unfold dataProps
  generalize ownKeys F s o = ks
  induction ks with
  | nil => exact Lawful.pure _
  | cons k ks ih =>
    change Lawful (Host.Ts.M.bind (ownGet F s o k) _)
    refine Lawful.bind (ownGet_lawful _ _ _ _) fun p => ?_
    cases p with
    | none => exact Lawful.pure _
    | some p =>
      cases p with
      | data v w e => exact Lawful.bind ih fun r => Lawful.pure _
      | acc g st e => exact Lawful.pure _

theorem defineData_fresh (F : Ffi) {s u : St F.S} (h : Fresh s u) {a : Nat}
    (ha : s.next ≤ a) (k : PKey) (v : Val) : Fresh s (defineData F u a k v) := by
  rcases (defineData_heap u a k v).2 with he | ⟨o, he⟩
  · rw [he]; exact h
  · rw [he]; exact h.write ha _

theorem defineData_fold_fresh (F : Ffi) {s u : St F.S} (h : Fresh s u) {a : Nat}
    (ha : s.next ≤ a) (kvs : List (PKey × Val)) :
    Fresh s (kvs.foldl (fun u (k, v) => defineData F u a k v) u) := by
  induction kvs generalizing u with
  | nil => exact h
  | cons kv kvs ih => exact ih (defineData_fresh F h ha kv.1 kv.2)

theorem restObj_lawful (F : Ffi) (s : St F.S) (src : Val) (used : List PKey) :
    Lawful (restObj F s src used) := by
  unfold restObj
  repeat' first
    | exact Lawful.pure _
    | refine Lawful.bind (dataProps_lawful _ _ _) fun r => ?_
    | split

/-- Object-rest properties are written only to the object just allocated by `restObj`. -/
theorem restObj_fresh (F : Ffi) (s : St F.S) (src : Val) (used : List PKey) :
    AllX (fun r => match r with | none => True | some p => Fresh s p.2)
      (restObj F s src used) := by
  unfold restObj
  split
  · split
    · refine AllX.bind' (dataProps_lawful _ _ _) fun r => ?_
      cases r with
      | none => exact AllX.pure trivial
      | some kvs => exact AllX.pure (defineData_fold_fresh F (Fresh.alloc s _) (Nat.le_refl _) _)
    · exact AllX.pure trivial
  · exact AllX.pure trivial

theorem objPatNext_fresh (F : Ffi) (s : St F.S) (src : Val) (ps : List (Key × Pat))
    (rest : Option Pat) (used : List PKey) (env : Env) (mode : BindMode) (kind : DeclKind) :
    AllX (Fresh s) (objPatNext F s src ps rest used env mode kind) := by
  cases ps with
  | nil =>
    cases rest with
    | none => exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
    | some r =>
      simp only [objPatNext]
      refine AllX.bind (restObj_lawful _ _ _ _) (restObj_fresh _ _ _ _) fun p hp => ?_
      cases p with
      | none => exact allX_fail _ _
      | some p => exact AllX.pure (hp.trans (Fresh.of_same ⟨rfl, rfl⟩))
  | cons kp ps =>
    obtain ⟨k, p⟩ := kp
    cases hk : keyOf k with
    | some key =>
      simp only [objPatNext, hk]
      exact (Fresh.of_same (s := s) (u := s.push _) ⟨rfl, rfl⟩).after (getV_fresh _ _ _ _)
    | none =>
      cases k <;> simp only [objPatNext, hk]
      all_goals first
        | exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
        | exact allX_fail _ _

/-- The non-identifier cases only allocate and update fresh objects; nested patterns are
scheduled as later controls, rather than executed by this step. -/
theorem bindStep_nonId_fresh (F : Ffi) (s : St F.S) (p : Pat) (v : Val) (env : Env)
    (mode : BindMode) (kind : DeclKind) (hp : ∀ n, p ≠ .id n) :
    AllX (Fresh s) (bindStep F s p v env mode kind) := by
  cases p with
  | id n => exact (hp n rfl).elim
  | expr e => exact allX_fail _ _
  | dflt q d => cases v <;> exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
  | array ps rest =>
    simp only [bindStep]
    refine AllX.bind' (elemsOf_lawful _ _ _) fun r => ?_
    cases r with
    | some vs => exact arrNext_fresh _ _ _ _ _ _ _ _
    | none =>
      cases v
      case obj a =>
        exact (Fresh.of_same (s := s) (u := (s.push _).push _) ⟨rfl, rfl⟩).after
          (startIter_fresh _ _ _)
      all_goals exact typeErr_fresh _ _
  | object ps rest =>
    exact AllX.cond _ (typeErr_fresh _ _) (objPatNext_fresh _ _ _ _ _ _ _ _ _)

end Host.Ts.Sim.HeapFoot

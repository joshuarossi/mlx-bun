import host.load.Extract
import host.sim.LoadIter
namespace Host.Ts.Sim.ExtractSim
open Host.Ts Host.Ts.Sim Host.Load Host.Load.Extract

/-! # Read-only projections under the map: values

For related states (`Rel Host.Load.ffi FR M ν K s S t C`) and a supported source
value `v`, the projections of `Host.Load.Extract` that read objects, own data
properties, private fields, closure scopes, variable cells and class names give on
the target, at `M.val v`, the images of the source's results. Array elements need
the array unframed (`elements_map`). -/

abbrev LF : Ffi := Host.Load.ffi

/-- A supported source value. -/
abbrev SV (s : St LSt) (n : Nat) (v : Val) : Prop := Supp.val (Present s) n v

section
variable {FR : Map → Nat → LSt → LSt → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St LSt} {S : SSrv} {C : CSrv}

/-! ## The relation's heap facts at `St LSt` -/

theorem t_obj (h : Rel LF FR M ν K s S t C) {a : Nat} {o : Obj} (ho : s.obj? a = some o) (hf : K.fr a = none) :
    t.obj? (M.a a) = some (M.obj o) := h.obj? ho hf

theorem t_obj_some (h : Rel LF FR M ν K s S t C) {a : Nat} {o : Obj} (ho : s.obj? a = some o) :
    ∃ o', t.obj? (M.a a) = some o' ∧ o'.proto = M.val o.proto ∧ o'.props = M.props o.props ∧
      o'.priv = M.privs o.priv ∧ o'.extensible = o.extensible := h.obj?_some ho

theorem t_obj_framed (h : Rel LF FR M ν K s S t C) {a : Nat} {o : Obj} {pre pre' : List Val}
    (ho : s.obj? a = some o) (hf : K.fr a = some (pre, pre')) :
    ∃ o', t.obj? (M.a a) = some o' ∧ FramedObj M pre pre' o o' := h.obj?_framed ho hf

theorem t_cell (h : Rel LF FR M ν K s S t C) {a : Nat} {v : Option Val} (hc : s.cell? a = some v) :
    t.cell? (M.a a) = some (v.map M.val) := h.cell? hc

theorem s_obj_supp (h : Rel LF FR M ν K s S t C) {a : Nat} {o : Obj} (ho : s.obj? a = some o) :
    Supp.obj (Present s) S.tab.length o := h.obj?_supp ho

theorem s_cell_supp (h : Rel LF FR M ν K s S t C) {a : Nat} {v : Val} (hc : s.cell? a = some (some v)) :
    SV s S.tab.length v := h.cell?_supp hc

theorem s_fr_none (h : Rel LF FR M ν K s S t C) {a : Nat} {o : Obj} (ho : s.obj? a = some o)
    (hk : ∀ es, o.kind ≠ .array es) : K.fr a = none := h.fr_none ho hk

/-- A present source address holding no object holds none on the target. -/
theorem obj?_none (h : Rel LF FR M ν K s S t C) {a : Nat} (hp : Present s a) (ho : s.obj? a = none) :
    t.obj? (M.a a) = none := by
  obtain ⟨hh, hg⟩ := Present.get hp
  cases hh with
  | obj o => rw [obj?_iff.2 hg] at ho; cases ho
  | cell w =>
    have ht : t.heap.get (M.a a) = some (M.hobj (.cell w)) := h.get hg (h.fr_cell hg)
    unfold St.obj?
    rw [ht]
    rfl

/-- A present source address holding no cell holds none on the target. -/
theorem cell?_none (h : Rel LF FR M ν K s S t C) {a : Nat} (hp : Present s a) (hc : s.cell? a = none) :
    t.cell? (M.a a) = none := by
  obtain ⟨hh, hg⟩ := Present.get hp
  cases hh with
  | cell w => rw [cell?_iff.2 hg] at hc; cases hc
  | obj o =>
    have hs : SlotOK M K.fr a (.obj o) (t.heap.get (M.a a)) := h.heap a _ hg
    cases hf : K.fr a with
    | none =>
      have ht : t.heap.get (M.a a) = some (M.hobj (.obj o)) := (SlotOK.none_iff hf).1 hs
      unfold St.cell?
      rw [ht]
      rfl
    | some p =>
      obtain ⟨pre, pre'⟩ := p
      obtain ⟨o1, o', _, ht, _⟩ := (SlotOK.some_iff hf).1 hs
      unfold St.cell?
      rw [ht]

/-- The object a supported value names, on both sides: unframed objects are images; framed
ones keep prototype, properties and private members, and both kinds are arrays. -/
theorem object_map (h : Rel LF FR M ν K s S t C) {v : Val} (hv : SV s S.tab.length v) :
    (object s v = none → object t (M.val v) = none) ∧
    ∀ o, object s v = some o → ∃ a o', v = .obj a ∧ object t (M.val v) = some o' ∧
      o'.proto = M.val o.proto ∧ o'.props = M.props o.props ∧ o'.priv = M.privs o.priv ∧
      ((∀ es, o.kind ≠ .array es) → o' = M.obj o) ∧ (K.fr a = none → o' = M.obj o) ∧
      (∀ es, o.kind = .array es → ∃ es', o'.kind = .array es') ∧ Supp.obj (Present s) S.tab.length o := by
  cases v with
  | obj a =>
    have hp : Present s a := hv
    refine ⟨fun ho => obj?_none h hp ho, fun o ho => ?_⟩
    have ho' : s.obj? a = some o := ho
    obtain ⟨o', ht, h1, h2, h3, _⟩ := t_obj_some h ho'
    have ht' : object t (M.val (.obj a)) = some o' := ht
    refine ⟨a, o', rfl, ht', h1, h2, h3, fun hk => ?_, fun hf => ?_, fun es hk => ?_, s_obj_supp h ho'⟩
    · rw [t_obj h ho' (s_fr_none h ho' hk)] at ht
      exact (Option.some.inj ht).symm
    · rw [t_obj h ho' hf] at ht
      exact (Option.some.inj ht).symm
    · cases hf : K.fr a with
      | none =>
        rw [t_obj h ho' hf] at ht
        obtain rfl := Option.some.inj ht
        exact ⟨M.vals es, by show M.kind o.kind = _; rw [hk]; rfl⟩
      | some p =>
        obtain ⟨pre, pre'⟩ := p
        obtain ⟨o2, ht2, xs, _, rfl⟩ := t_obj_framed h ho' hf
        rw [ht2] at ht
        obtain rfl := Option.some.inj ht
        exact ⟨_, rfl⟩
  | _ => exact ⟨fun _ => rfl, fun o ho => nomatch ho⟩

theorem object_supp (h : Rel LF FR M ν K s S t C) {v : Val} {o : Obj} (ho : object s v = some o) :
    Supp.obj (Present s) S.tab.length o := by
  cases v with
  | obj a => exact s_obj_supp h ho
  | _ => cases ho

theorem data_map (p : PropV) : data (M.prop p) = (data p).map M.val := by
  cases p <;> rfl

theorem data_supp {A : Nat → Prop} {n : Nat} {p : PropV} {w : Val} (hp : Supp.prop A n p) (hd : data p = some w) :
    Supp.val A n w := by
  cases p with
  | data x _ _ => cases hd; exact hp
  | acc _ _ _ => cases hd

theorem own_map (h : Rel LF FR M ν K s S t C) {v : Val} (hv : SV s S.tab.length v) (nm : List Char) :
    own t (M.val v) nm = (own s v nm).map M.val := by
  obtain ⟨hnone, hsome⟩ := object_map h hv
  unfold own
  cases ho : object s v with
  | none => rw [hnone ho]; rfl
  | some o =>
    obtain ⟨a, o', _, ht, _, hps, _, _, _, _, hso⟩ := hsome o ho
    rw [ht]
    simp only [Option.bind_eq_bind, Option.bind_some]
    have e : findProp (.str nm) (M.props o.props) = (findProp (.str nm) o.props).map M.prop :=
      findProp_map h.inj (show Supp.key (Present s) S.tab.length (.str nm) from trivial) hso.2.2.1
    rw [hps, e]
    cases findProp (.str nm) o.props with
    | none => rfl
    | some p => exact data_map p

theorem own_supp (h : Rel LF FR M ν K s S t C) {v w : Val} {nm : List Char} (hw : own s v nm = some w) :
    SV s S.tab.length w := by
  unfold own at hw
  cases ho : object s v with
  | none => rw [ho] at hw; cases hw
  | some o =>
    rw [ho] at hw
    simp only [Option.bind_eq_bind, Option.bind_some] at hw
    cases hf : findProp (.str nm) o.props with
    | none => rw [hf] at hw; cases hw
    | some p =>
      rw [hf] at hw
      exact data_supp (findProp_supp (object_supp h ho).2.2.1 hf) hw

/-- The private-field selection of `privateField`. -/
def pick (nm : List Char) (l : List ((Nat × Name) × PropV)) : Option Val :=
  match l.filter (fun ((_, k), _) => nameEq nm k) with
  | [(_, p)] => data p
  | _ => none

theorem privateField_eq (s : St LSt) (v : Val) (nm : List Char) :
    privateField s v nm = (object s v).bind fun o => pick nm o.priv := rfl

theorem filter_privs (nm : List Char) : ∀ l : List ((Nat × Name) × PropV),
    (M.privs l).filter (fun x => nameEq nm x.1.2) = M.privs (l.filter (fun x => nameEq nm x.1.2))
  | [] => rfl
  | ((b, k), p) :: l => by
    show List.filter _ (((M.a b, k), M.prop p) :: M.privs l) = M.privs (List.filter _ (((b, k), p) :: l))
    simp only [List.filter_cons]
    cases nameEq nm k
    · exact filter_privs nm l
    · simp only [ite_true]
      show _ = ((M.a b, k), M.prop p) :: M.privs _
      rw [filter_privs nm l]

theorem pick_map (nm : List Char) (l : List ((Nat × Name) × PropV)) :
    pick nm (M.privs l) = (pick nm l).map M.val := by
  unfold pick
  rw [filter_privs]
  generalize l.filter (fun x => nameEq nm x.1.2) = l'
  rcases l' with _ | ⟨⟨⟨b, k⟩, p⟩, _ | ⟨_, _⟩⟩
  · rfl
  · exact data_map p
  · rfl

theorem privateField_map (h : Rel LF FR M ν K s S t C) {v : Val} (hv : SV s S.tab.length v) (nm : List Char) :
    privateField t (M.val v) nm = (privateField s v nm).map M.val := by
  obtain ⟨hnone, hsome⟩ := object_map h hv
  rw [privateField_eq, privateField_eq]
  cases ho : object s v with
  | none => rw [hnone ho]; rfl
  | some o =>
    obtain ⟨a, o', _, ht, _, _, hpv, _, _, _, _⟩ := hsome o ho
    rw [ht]
    simp only [Option.bind_eq_bind, Option.bind_some]
    rw [hpv]
    exact pick_map nm o.priv

theorem pick_supp {A : Nat → Prop} {n : Nat} {nm : List Char} {l : List ((Nat × Name) × PropV)} {w : Val}
    (hl : ∀ x ∈ l, A x.1.1 ∧ Supp.prop A n x.2) (hw : pick nm l = some w) : Supp.val A n w := by
  unfold pick at hw
  split at hw
  · rename_i x p hx
    have hmem : (x, p) ∈ l := by
      have : (x, p) ∈ l.filter (fun x => nameEq nm x.1.2) := by rw [hx]; exact List.mem_singleton_self _
      exact (List.mem_filter.1 this).1
    exact data_supp (hl _ hmem).2 hw
  · cases hw

theorem privateField_supp (h : Rel LF FR M ν K s S t C) {v w : Val} {nm : List Char}
    (hw : privateField s v nm = some w) : SV s S.tab.length w := by
  rw [privateField_eq] at hw
  cases ho : object s v with
  | none => rw [ho] at hw; cases hw
  | some o =>
    rw [ho] at hw
    exact pick_supp (object_supp h ho).2.2.2 hw

theorem elements_map (h : Rel LF FR M ν K s S t C) {v : Val} (hv : SV s S.tab.length v)
    (hfr : ∀ a, v = .obj a → K.fr a = none) :
    elements t (M.val v) = (elements s v).map M.vals := by
  obtain ⟨hnone, hsome⟩ := object_map h hv
  unfold elements
  cases ho : object s v with
  | none => rw [hnone ho]; rfl
  | some o =>
    obtain ⟨a, o', rfl, ht, _, _, _, _, hun, _, _⟩ := hsome o ho
    rw [ht, hun (hfr a rfl)]
    simp only [Option.bind_eq_bind, Option.bind_some]
    show (match M.kind o.kind with | .array es => some es | _ => none) = _
    cases o.kind <;> rfl

theorem elements_supp (h : Rel LF FR M ν K s S t C) {v : Val} {es : List Val} (he : elements s v = some es) :
    Supp.vals (Present s) S.tab.length es := by
  unfold elements at he
  cases ho : object s v with
  | none => rw [ho] at he; cases he
  | some o =>
    rw [ho] at he
    simp only [Option.bind_eq_bind, Option.bind_some] at he
    have hk := (object_supp h ho).1
    revert he hk
    cases o.kind <;> intro he hk <;> simp at he
    subst he
    exact hk

theorem bindingOf_map (h : Rel LF FR M ν K s S t C) {env : Env} (he : Supp.env (Present s) S.tab.length env)
    (nm : Name) : bindingOf t (M.env env) nm = (bindingOf s env nm).map M.val := by
  unfold bindingOf
  rw [lookupEnv_map]
  cases hl : lookupEnv nm env with
  | none => rfl
  | some c =>
    simp only [Option.map_some, Option.bind_some]
    have hp : Present s c := by
      obtain ⟨m, hm⟩ := StmtSim.env_lookup_mem hl
      exact he _ hm
    cases hc : s.cell? c with
    | none => rw [cell?_none h hp hc]; rfl
    | some w =>
      rw [t_cell h hc]
      cases w <;> rfl

theorem bindingOf_supp (h : Rel LF FR M ν K s S t C) {env : Env} {nm : Name} {w : Val}
    (hw : bindingOf s env nm = some w) : SV s S.tab.length w := by
  unfold bindingOf at hw
  cases hl : lookupEnv nm env with
  | none => rw [hl] at hw; cases hw
  | some c =>
    rw [hl] at hw
    simp only [Option.bind_eq_bind, Option.bind_some] at hw
    cases hc : s.cell? c with
    | none => rw [hc] at hw; cases hw
    | some x =>
      rw [hc] at hw
      cases x with
      | none => cases hw
      | some y => cases hw; exact s_cell_supp h hc

theorem closureBinding_map (h : Rel LF FR M ν K s S t C) {v : Val} (hv : SV s S.tab.length v) (nm : List Char) :
    closureBinding t (M.val v) nm = (closureBinding s v nm).map M.val := by
  obtain ⟨hnone, hsome⟩ := object_map h hv
  unfold closureBinding
  cases ho : object s v with
  | none => rw [hnone ho]; rfl
  | some o =>
    obtain ⟨a, o', _, ht, _, _, _, hnar, _, har, hso⟩ := hsome o ho
    rw [ht]
    simp only [Option.bind_eq_bind, Option.bind_some]
    by_cases hka : ∃ es, o.kind = .array es
    · obtain ⟨es, hk⟩ := hka
      obtain ⟨es', hk'⟩ := har es hk
      rw [hk', hk]; rfl
    · have e := hnar (fun es he => hka ⟨es, he⟩)
      subst e
      show (match M.kind o.kind with | .fn (.closure _ env _ _) => bindingOf t env nm | _ => none) = _
      have hsk := hso.1
      revert hsk
      cases o.kind with
      | fn c =>
        cases c with
        | closure f env ar hm => intro hsk; exact bindingOf_map h hsk.1 nm
        | _ => intro _; rfl
      | _ => intro _; rfl

theorem closureBinding_supp (h : Rel LF FR M ν K s S t C) {v w : Val} {nm : List Char}
    (hw : closureBinding s v nm = some w) : SV s S.tab.length w := by
  unfold closureBinding at hw
  cases ho : object s v with
  | none => rw [ho] at hw; cases hw
  | some o =>
    rw [ho] at hw
    simp only [Option.bind_eq_bind, Option.bind_some] at hw
    revert hw
    cases o.kind with
    | fn c => cases c <;> intro hw <;> first | exact bindingOf_supp h hw | cases hw
    | _ => intro hw; cases hw

theorem beq_map (h : Rel LF FR M ν K s S t C) {a b : Nat} (ha : Present s a) (hb : Present s b) :
    Nat.beq (M.a a) (M.a b) = Nat.beq a b := by
  cases e : Nat.beq a b with
  | true => rw [Nat.eq_of_beq_eq_true e]; exact Nat.beq_refl _
  | false =>
    cases e' : Nat.beq (M.a a) (M.a b) with
    | false => rfl
    | true =>
      have := h.inj a b ha hb (Nat.eq_of_beq_eq_true e')
      subst this
      rw [Nat.beq_refl] at e
      cases e

/-- The class-name tail of `className`, at a constructor address. -/
def ctorName (s : St LSt) (c : Nat) : Option (List Char) := do
  let co ← s.obj? c
  match co.kind with
  | .fn (.klass _ ((n, cell) :: _) _ _) => match s.cell? cell with
    | some (some (.obj d)) => bif Nat.beq c d then some n else none
    | _ => none
  | _ => none

theorem className_eq (s : St LSt) (v : Val) :
    className s v = (object s v).bind fun o => (own s o.proto chars!"constructor").bind fun cv =>
      match cv with
      | .obj c => ctorName s c
      | _ => none := rfl

theorem ctorName_map (h : Rel LF FR M ν K s S t C) {c : Nat} (hc : Present s c) :
    ctorName t (M.a c) = ctorName s c := by
  unfold ctorName
  have hcs : SV s S.tab.length (.obj c) := hc
  obtain ⟨hn2, hs2⟩ := object_map h hcs
  cases hco : s.obj? c with
  | none =>
    rw [show t.obj? (M.a c) = none from hn2 hco]
    rfl
  | some co =>
    obtain ⟨_, co', hca, htc, _, _, _, hnar, _, har, hsco⟩ := hs2 co hco
    cases hca
    rw [show t.obj? (M.a c) = some co' from htc]
    simp only [Option.bind_eq_bind, Option.bind_some]
    by_cases hka : ∃ es, co.kind = .array es
    · obtain ⟨es, hk⟩ := hka
      obtain ⟨es', hk'⟩ := har es hk
      rw [hk', hk]
    · have e := hnar (fun es he => hka ⟨es, he⟩)
      subst e
      show (match M.kind co.kind with
        | .fn (.klass _ ((n, cell) :: _) _ _) => match t.cell? cell with
          | some (some (.obj d)) => bif Nat.beq (M.a c) d then some n else none
          | _ => none
        | _ => none) = _
      have hsk := hsco.1
      revert hsk
      cases co.kind with
      | fn cd =>
        cases cd with
        | klass ctor env par inst =>
          cases env with
          | nil => intro _; rfl
          | cons p rest =>
            obtain ⟨nm, cell⟩ := p
            intro hsk
            have hpc : Present s cell := hsk.1 _ (List.mem_cons_self ..)
            show (match t.cell? (M.a cell) with
              | some (some (.obj d)) => bif Nat.beq (M.a c) d then some nm else none
              | _ => none) = (match s.cell? cell with
              | some (some (.obj d)) => bif Nat.beq c d then some nm else none
              | _ => none)
            cases hcl : s.cell? cell with
            | none => rw [cell?_none h hpc hcl]
            | some w =>
              rw [t_cell h hcl]
              cases w with
              | none => rfl
              | some x =>
                cases x with
                | obj d =>
                  have hpd : Present s d := s_cell_supp h hcl
                  show (bif Nat.beq (M.a c) (M.a d) then some nm else none) = _
                  rw [beq_map h hc hpd]
                | _ => rfl
        | _ => intro _; rfl
      | _ => intro _; rfl

theorem className_map (h : Rel LF FR M ν K s S t C) {v : Val} (hv : SV s S.tab.length v) :
    className t (M.val v) = className s v := by
  obtain ⟨hnone, hsome⟩ := object_map h hv
  rw [className_eq, className_eq]
  cases ho : object s v with
  | none => rw [hnone ho]; rfl
  | some o =>
    obtain ⟨a, o', _, ht, hpr, _, _, _, _, _, hso⟩ := hsome o ho
    rw [ht]
    simp only [Option.bind_eq_bind, Option.bind_some]
    rw [hpr, own_map h hso.2.1]
    cases hc : own s o.proto chars!"constructor" with
    | none => rfl
    | some cv =>
      simp only [Option.map_some, Option.bind_some]
      cases cv with
      | obj c => exact ctorName_map h (own_supp h hc)
      | _ => rfl

end
end Host.Ts.Sim.ExtractSim

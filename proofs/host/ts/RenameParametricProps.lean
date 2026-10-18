import host.ts.RenameParametricVariables
namespace Host.Ts.Owned.Parametric

abbrev KeyR (NR : NumV → NumV → Prop) (R : Ren) (k k' : PKey) := TreeR NR R (Encode.key k) (Encode.key k')
abbrev PropR (NR : NumV → NumV → Prop) (R : Ren) (p p' : PropV) := TreeR NR R (Encode.prop p) (Encode.prop p')
abbrev PropsR (NR : NumV → NumV → Prop) (R : Ren) (ps ps' : Props) := TreeR NR R (Encode.props ps) (Encode.props ps')

private theorem node_tag {NR : NumV → NumV → Prop} {R : Ren} {a b : String} {xs ys : List Tree}
    (h : TreeR NR R (.node a xs) (.node b ys)) : a = b := by cases h; rfl

theorem KeyR.eq_map {NR : NumV → NumV → Prop} {R : Ren} {k k' : PKey} (h : KeyR NR R k k') : k' = R.key k := by
  cases k with
  | str a => cases k' with
    | str b =>
      cases h with | node tag hs => cases hs with | cons hh ht => cases hh; rfl
    | sym b => exact False.elim ((by decide : ("PKey.str" : String) ≠ "PKey.sym") (node_tag h))
  | sym a => cases k' with
    | str b => exact False.elim ((by decide : ("PKey.sym" : String) ≠ "PKey.str") (node_tag h))
    | sym b =>
      cases h with | node tag hs => cases hs with | cons hh ht => cases hh; rfl

/-- String property selection does not depend on symbolic-number values or
native-handle renaming. Symbol keys remain disjoint from string keys. -/
theorem keyEq_string_map (R : Ren) (name : Name) (k : PKey) :
    keyEq (.str name) (R.key k) = keyEq (.str name) k := by
  cases k with
  | str n => rfl
  | sym n =>
    have odd (n : Nat) : Nat.beq (2 * pack name) (Nat.succ (2*n)) = false := by
      cases hb : Nat.beq (2 * pack name) (Nat.succ (2*n))
      · rfl
      · have := Nat.eq_of_beq_eq_true hb
        omega
    change Nat.beq (2 * pack name) (Nat.succ (2 * R.sym n)) = Nat.beq (2 * pack name) (Nat.succ (2*n))
    rw [odd,odd]

theorem PropsR.nil_left {NR : NumV → NumV → Prop} {R : Ren} {ps : Props}
    (h : PropsR NR R [] ps) : ps = [] := by
  cases ps with
  | nil => rfl
  | cons p ps => cases h with | node tag hs => cases hs

theorem PropsR.cons {NR : NumV → NumV → Prop} {R : Ren}
    {k : PKey} {p : PropV} {ps ps' : Props} (h : PropsR NR R ((k,p)::ps) ps') :
    ∃ k' p' rest, ps' = (k',p')::rest ∧ KeyR NR R k k' ∧ PropR NR R p p' ∧ PropsR NR R ps rest := by
  cases ps' with
  | nil => cases h with | node tag hs => cases hs
  | cons q rest =>
    obtain ⟨k',p'⟩ := q
    cases h with | node tag hs =>
      cases hs with | cons hh hs =>
        cases hh with | node tag fields =>
          cases fields with | cons hk fields =>
            cases fields with | cons hp ht =>
              exact ⟨k',p',rest,rfl,hk,hp,.node _ hs⟩

inductive OptionRel {α β : Type} (P : α → β → Prop) : Option α → Option β → Prop where
  | none : OptionRel P none none
  | some {a : α} {b : β} : P a b → OptionRel P (some a) (some b)

/-- Read a string property from related ordered descriptor lists. The proof
uses actual first-match lookup, including duplicate keys and accessors. -/
theorem PropsR.find_string {NR : NumV → NumV → Prop} {R : Ren} {ps ps' : Props}
    (h : PropsR NR R ps ps') (name : Name) :
    OptionRel (PropR NR R) (findProp (.str name) ps) (findProp (.str name) ps') := by
  rw [findProp_eq_linear,findProp_eq_linear]
  induction ps generalizing ps' with
  | nil => have := h.nil_left; subst ps'; exact .none
  | cons q rest ih =>
    obtain ⟨k,p⟩ := q
    obtain ⟨k',p',rest',rfl,hk,hp,hr⟩ := h.cons
    have he : keyEq (.str name) k' = keyEq (.str name) k := by rw [hk.eq_map]; exact keyEq_string_map R name k
    simp only [findPropLinear_cons]
    change OptionRel (PropR NR R) (brec (keyEq (.str name) k) _ _) (brec (keyEq (.str name) k') _ _)
    rw [he]
    cases keyEq (.str name) k
    · exact ih hr
    · exact .some hp

theorem ObjectR.properties {NR : NumV → NumV → Prop} {R : Ren} {o o' : Obj}
    (h : ObjectR NR R o o') : PropsR NR R o.props o'.props := by
  cases h with | node tag hs =>
    cases hs with | cons hk hs =>
      cases hs with | cons hp hs =>
        cases hs with | cons hprops hs => exact hprops

theorem ObjectR.kind {NR : NumV → NumV → Prop} {R : Ren} {o o' : Obj}
    (h : ObjectR NR R o o') : TreeR NR R (Encode.kind o.kind) (Encode.kind o'.kind) := by
  cases h with | node tag hs =>
    cases hs with | cons hk hs => exact hk

private def tagOf : Tree → String
  | .node t _ => t | _ => ""
private theorem TreeR.tag_eq {NR : NumV → NumV → Prop} {R : Ren} {t t' : Tree}
    (h : TreeR NR R t t') : tagOf t = tagOf t' := by cases h <;> rfl

theorem ObjectR.ordinary {NR : NumV → NumV → Prop} {R : Ren} {o o' : Obj}
    (h : ObjectR NR R o o') (hk : o.kind = .ordinary) : o'.kind = .ordinary := by
  have ht := h.kind.tag_eq
  rw [hk] at ht
  cases he : o'.kind <;> simp only [he,Encode.kind,tagOf] at ht
  all_goals try rfl
  all_goals simp at ht

theorem PropR.data {NR : NumV → NumV → Prop} {R : Ren} {v : Val} {w e : Bool} {p : PropV}
    (h : PropR NR R (.data v w e) p) :
    ∃ v', p = .data v' w e ∧ ValueR NR R v v' := by
  cases p with
  | data v' w' e' =>
    cases h with | node tag hs =>
      cases hs with | cons hv hs =>
        cases hs with | cons hw hs =>
          cases hs with | cons he hs =>
            cases hv with | value hv =>
              cases hw; cases he
              exact ⟨v',rfl,hv⟩
  | acc g st e' => exact False.elim ((by decide : ("PropV.data" : String) ≠ "PropV.acc") (node_tag h))

/-- Heap closure supplies the target object; callers do not postulate its read. -/
theorem HeapR.readObject {S : Type} {NR : NumV → NumV → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {s s' : St S}
    (h : HeapR NR R live framed before after s s') (a : Nat) (o : Obj)
    (ha : live a) (hn : ¬ framed a) (ho : s.heap.get a = some (.obj o)) :
    ∃ o', s'.heap.get (R.a a) = some (.obj o') ∧ ObjectR NR R o o' ∧ treeSupport live (Encode.obj o) := by
  have hr := h.lookup a ha
  rw [ho] at hr
  generalize hh : s'.heap.get (R.a a) = target at hr
  cases hr with
  | regular hf hr hl => cases hr with | obj hobj => exact ⟨_,rfl,hobj,hl.1⟩
  | framed hf => exact False.elim (hn hf)

theorem HeapR.readOrdinary {S : Type} {NR : NumV → NumV → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {s s' : St S}
    (h : HeapR NR R live framed before after s s') (a : Nat) (o : Obj)
    (ha : live a) (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .ordinary) :
    ∃ o', s'.heap.get (R.a a) = some (.obj o') ∧ ObjectR NR R o o' ∧ treeSupport live (Encode.obj o) := by
  have hr := h.lookup a ha
  rw [ho] at hr
  generalize hh : s'.heap.get (R.a a) = target at hr
  cases hr with
  | regular hf hr hl => cases hr with | obj hobj => exact ⟨_,rfl,hobj,hl.1⟩
  | framed hf hk₀ => rw [hk] at hk₀; cases hk₀

theorem PropsR.find_data {NR : NumV → NumV → Prop} {R : Ren} {ps ps' : Props}
    (h : PropsR NR R ps ps') (name : Name) (v : Val) (w e : Bool)
    (hp : findProp (.str name) ps = some (.data v w e)) :
    ∃ v', findProp (.str name) ps' = some (.data v' w e) ∧ ValueR NR R v v' := by
  have hr := h.find_string name
  rw [hp] at hr
  generalize hh : findProp (.str name) ps' = result at hr
  cases hr with
  | some hprop =>
    obtain ⟨v',rfl,hv⟩ := hprop.data
    exact ⟨v',rfl,hv⟩

theorem PropsR.support_find {live : Nat → Prop} {ps : Props} {p : PropV}
    (hs : treeSupport live (Encode.props ps)) (name : Name)
    (hp : findProp (.str name) ps = some p) : treeSupport live (Encode.prop p) := by
  rw [findProp_eq_linear] at hp
  induction ps with
  | nil => cases hp
  | cons q rest ih =>
    obtain ⟨k,v⟩ := q
    change (treeSupport live (Encode.key k) ∧ treeSupport live (Encode.prop v) ∧ True) ∧
      forestSupport live (rest.map fun (k,p) => .node "prop" [Encode.key k,Encode.prop p]) at hs
    rw [findPropLinear_cons] at hp
    change brec (keyEq (.str name) k) (some v) (findPropLinear (.str name) rest) = some p at hp
    cases hb : keyEq (.str name) k <;> rw [hb] at hp
    · exact ih hs.2 hp
    · obtain rfl := Option.some.inj hp
      exact hs.1.2.1

/-- The actual ordinary own-data member interpreter step. -/
theorem step_member_data_eq (F : Ffi) (s : St F.S) (a : Nat) (name : Name) (v : Val)
    (w e : Bool) (o : Obj) (fs : List Frame)
    (hc : s.ctl = .ret (.obj a)) (hf : s.stack = .e (.member (.str name) false)::fs)
    (ho : s.obj? a = some o) (hk : o.kind = .ordinary)
    (hp : findProp (.str name) o.props = some (.data v w e)) :
    step F s = M.pure ({s with stack := fs}.ret v) := by
  simp only [St.obj?] at ho
  funext β k
  simp only [step,hc,stepRet,hf,retStep,retE,Bool.false_and,Bool.cond_false,
    getV,lookup,getChain,St.obj?,ho,ownGet,hk,hp,M.bind,M.pure,readProp,retS]

/-- Actual member access derives the target descriptor from the live source
heap and the ordered property relation. No target lookup or step is assumed. -/
theorem step_member_data_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (name : Name) (v₀ : Val) (w e : Bool) (o₀ : Obj) (fs₀ fs : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a)) (hc : s.ctl = .ret (.obj (R.a a)))
    (hf₀ : s₀.stack = .e (.member (.str name) false)::fs₀)
    (hf : s.stack = .e (.member (.str name) false)::fs)
    (ha : live a) (hn : ¬ framed a) (ho : s₀.heap.get a = some (.obj o₀))
    (hk : o₀.kind = .ordinary) (hp : findProp (.str name) o₀.props = some (.data v₀ w e)) :
    ∃ v, interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.ret v₀,C₀) ∧
      interpC (step F s).run C = some ({s with stack := fs}.ret v,C) ∧
      StateR NR FR R live framed before after old old'
        ({s₀ with stack := fs₀}.ret v₀) ({s with stack := fs}.ret v) ∧ ValueR NR R v₀ v := by
  obtain ⟨o,ho',hor,hos⟩ := h.heap.readObject a o₀ ha hn ho
  obtain ⟨v,hp',hvr⟩ := hor.properties.find_data name v₀ w e hp
  have hsprops : treeSupport live (Encode.props o₀.props) := hos.2.2.1
  have hsv : valueSupport live v₀ := (PropsR.support_find hsprops name hp).1
  have hfs : ListR (FrameR NR R) fs₀ fs := by
    have hh := h.stack
    rw [hf₀,hf] at hh
    cases hh with | cons ht hs => exact hs
  have hfl : listSupport (fun f => treeSupport live (Encode.frame f)) fs₀ := by
    have hh := h.stackLive
    rw [hf₀] at hh
    exact hh.2
  have ho₀ : s₀.obj? a = some o₀ := by simp only [St.obj?,ho]
  have hot : s.obj? (R.a a) = some o := by simp only [St.obj?,ho']
  refine ⟨v,?_,?_,(h.restack hfs hfl).go (.node _ (.cons (.value hvr) .nil)) ⟨hsv,True.intro⟩,hvr⟩
  · rw [step_member_data_eq F s₀ a name v₀ w e o₀ fs₀ hc₀ hf₀ ho₀ hk hp]; rfl
  · rw [step_member_data_eq F s (R.a a) name v w e o fs hc hf hot (hor.ordinary hk) hp']; rfl

theorem PropR.accessor {NR : NumV → NumV → Prop} {R : Ren} {g st : Val} {e : Bool} {p : PropV}
    (h : PropR NR R (.acc g st e) p) :
    ∃ g' st', p = .acc g' st' e ∧ ValueR NR R g g' ∧ ValueR NR R st st' := by
  cases p with
  | acc g' st' e' =>
    cases h with | node tag hs =>
      cases hs with | cons hg hs =>
        cases hs with | cons hst hs =>
          cases hs with | cons he hs =>
            cases hg with | value hg =>
              cases hst with | value hst =>
                cases he
                exact ⟨g',st',rfl,hg,hst⟩
  | data v w e' => exact False.elim ((by decide : ("PropV.acc" : String) ≠ "PropV.data") (node_tag h))

theorem ValueR.undef_iff {NR : NumV → NumV → Prop} {R : Ren} {v v' : Val}
    (h : ValueR NR R v v') : v = .undef ↔ v' = .undef := by cases h <;> simp

/-- Both data and accessor descriptors transport their actual read behavior.
A getter call retains the receiver and the fixed descriptor's getter role. -/
theorem StateR.readProp (F : Ffi) {NR : NumV → NumV → Prop} {FR : Ren → F.S → F.S → Prop}
    {R : Ren} {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {s₀ s : St F.S} (h : StateR NR FR R live framed before after old old' s₀ s)
    (receiver₀ receiver : Val) (hr : ValueR NR R receiver₀ receiver) (hrr : valueSupport live receiver₀)
    (p₀ p : PropV) (hp : PropR NR R p₀ p) (hpl : treeSupport live (Encode.prop p₀)) :
    StateR NR FR R live framed before after old old'
      (Host.Ts.readProp F s₀ receiver₀ (some p₀)) (Host.Ts.readProp F s receiver (some p)) := by
  cases p₀ with
  | data v w e =>
    obtain ⟨v',rfl,hv⟩ := hp.data
    exact h.go (.node _ (.cons (.value hv) .nil)) ⟨hpl.1,True.intro⟩
  | acc g st e =>
    obtain ⟨g',st',rfl,hg,hst⟩ := hp.accessor
    by_cases hgu : g = .undef
    · subst g
      have hgu' : g' = .undef := hg.undef_iff.mp rfl
      subst g'
      exact h.go (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩
    · have hgu' : g' ≠ .undef := fun he => hgu (hg.undef_iff.mpr he)
      have hc₀ : Host.Ts.readProp F s₀ receiver₀ (some (.acc g st e)) = s₀.go (.call g receiver₀ []) := by
        cases g <;> simp_all [Host.Ts.readProp]
      have hc : Host.Ts.readProp F s receiver (some (.acc g' st' e)) = s.go (.call g' receiver []) := by
        cases g' <;> simp_all [Host.Ts.readProp]
      rw [hc₀,hc]
      exact h.go (.node _ (.cons (.value hg) (.cons (.value hr) (.cons (.node _ .nil) .nil))))
        ⟨hpl.1,hrr,True.intro,True.intro⟩

end Host.Ts.Owned.Parametric

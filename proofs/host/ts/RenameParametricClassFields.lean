import host.ts.RenameParametricClassEntry
import host.ts.RenameParametricPrivate
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

abbrev ClassFieldsR (NR : NumV → NumV → Prop) (R : Ren) (xs ys : List InstMember) :=
  TreeR NR R (Encode.seq (xs.map Encode.inst)) (Encode.seq (ys.map Encode.inst))

inductive PrivateFields : List InstMember → Prop where
  | nil : PrivateFields []
  | cons (brand : Nat) (name : Name) (init : Option Expr) {rest : List InstMember} :
      PrivateFields rest → PrivateFields (.privField brand name init::rest)

theorem ClassFieldsR.nil_view {NR : NumV → NumV → Prop} {R : Ren} {ys : List InstMember}
    (h : ClassFieldsR NR R [] ys) : ys = [] := by
  cases ys with
  | nil => rfl
  | cons y ys => cases h with | node tag hs => cases hs

theorem ClassFieldsR.private_view {NR : NumV → NumV → Prop} {R : Ren}
    {brand : Nat} {name : Name} {init : Option Expr} {rest ys : List InstMember}
    (h : ClassFieldsR NR R (.privField brand name init::rest) ys) :
    ∃ tail, ys = .privField (R.a brand) name init::tail ∧ ClassFieldsR NR R rest tail := by
  cases ys with
  | nil => cases h with | node tag hs => cases hs
  | cons y ys =>
    cases h with | node tag hs =>
      cases hs with | cons hy hs =>
        have ht := hy.tag_eq
        cases y <;> simp only [Encode.inst,treeTag] at ht
        all_goals try contradiction
        case privField b n i =>
          cases hy with | node tag fields =>
            cases fields with | cons hb fields =>
              cases fields with | cons hn fields =>
                cases fields with | cons hi fields =>
                  cases hb; cases hn; cases hi
                  exact ⟨ys,rfl,.node _ hs⟩

theorem private_support_set_fields {live : Nat → Prop} {ps : Privs}
    (hs : treeSupport live (encodePrivs ps)) (brand : Nat) (name : Name) (hb : live brand)
    (p : PropV) (hp : treeSupport live (Encode.prop p)) :
    treeSupport live (encodePrivs (setPrivL brand name p ps)) := by
  induction ps with
  | nil => exact ⟨⟨hb,True.intro,hp,True.intro⟩,True.intro⟩
  | cons q rest ih =>
    obtain ⟨⟨b,n⟩,old⟩ := q
    change (live b ∧ True ∧ treeSupport live (Encode.prop old) ∧ True) ∧
      forestSupport live (rest.map fun ((b,n),p) => .node "private" [.address b,Encode.atom n,Encode.prop p]) at hs
    change treeSupport live (encodePrivs
      (bif privEq brand name (b,n) then ((b,n),p)::rest else ((b,n),old)::setPrivL brand name p rest))
    cases privEq brand name (b,n)
    · exact ⟨hs.1,ih hs.2⟩
    · exact ⟨⟨hs.1.1,True.intro,hp,True.intro⟩,hs.2⟩

/-- Original private-field initialization processes uninitialized fields and
enters the next source initializer expression. The induction follows the real
fieldsNext recursion and preserves all host/native state components. -/
theorem fieldsNext_private_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (_C₀ _C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o : Obj) (members members' : List InstMember) (env : Env)
    (onlyPrivate : PrivateFields members) (hr : ClassFieldsR NR R members members')
    (ha : live a) (ho : s₀.heap.get a = some (.obj o)) (hk : o.kind = .ordinary)
    (hm : treeSupport live (Encode.seq (members.map Encode.inst)))
    (he : treeSupport live (Encode.env env)) (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ result₀ result, fieldsNext F s₀ a members env = M.pure result₀ ∧
      fieldsNext F s (R.a a) members' (R.env env) = M.pure result ∧
      StateR NR FR R live framed before after old old' result₀ result ∧
      classBodyArgument result₀.stack = classBodyArgument s₀.stack ∧
      classBodyArgument result.stack = classBodyArgument s.stack := by
  induction onlyPrivate generalizing s₀ s o members' with
  | nil =>
    obtain rfl := hr.nil_view
    exact ⟨s₀.ret .undef,s.ret .undef,rfl,rfl,
      h.go (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩,rfl,rfl⟩
  | @cons brand name init rest onlyPrivate ih =>
    obtain ⟨tail,rfl,hrest⟩ := hr.private_view
    have hb : live brand := hm.1.1
    have htail : treeSupport live (Encode.seq (List.map Encode.inst rest)) := hm.2
    cases init with
    | some expr =>
      have hf : FrameR NR R (.k (.privVal a brand name rest env)) (.k (.privVal (R.a a) (R.a brand) name tail (R.env env))) :=
        .node _ (.cons (.node _ (.cons (.address _) (.cons (.address _) (.cons (.atom _ _)
          (.cons hrest (.cons (env_roles NR R env) .nil)))))) .nil)
      have hfl : treeSupport live (Encode.frame (.k (.privVal a brand name rest env))) :=
        ⟨⟨ha,hb,True.intro,htail,he,True.intro⟩,True.intro⟩
      let t₀ := (s₀.push (.k (.privVal a brand name rest env))).go (.ev expr env)
      let t := (s.push (.k (.privVal (R.a a) (R.a brand) name tail (R.env env)))).go (.ev expr (R.env env))
      refine ⟨t₀,t,rfl,rfl,?_,rfl,rfl⟩
      exact (h.restack (.cons hf h.stack) ⟨hfl,h.stackLive⟩).go
        (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,he,True.intro⟩
    | none =>
      obtain ⟨ob,ht,hor,hol⟩ := h.heap.readOrdinary a o ha ho hk
      have propRole : PropR NR R (.data .undef true false) (.data .undef true false) :=
        .node _ (.cons (.value .undef) (.cons (.atom _ _) (.cons (.atom _ _) .nil)))
      have newPriv := hor.privateFields.set hol.2.2.2.1 h.heap.inj brand name hb _ _ propRole
      have privLive := private_support_set_fields hol.2.2.2.1 brand name hb (.data .undef true false)
        ⟨True.intro,True.intro,True.intro,True.intro⟩
      let nextObj₀ := {o with priv := setPrivL brand name (.data .undef true false) o.priv}
      let nextObj := {ob with priv := setPrivL (R.a brand) name (.data .undef true false) ob.priv}
      have hnew := h.setObject a nextObj₀ nextObj ha (h.heap.ordinary_notFramed a o ha ho hk)
        (hor.with_private _ _ newPriv) ⟨hol.1,hol.2.1,hol.2.2.1,privLive,hol.2.2.2.2⟩
        (Nat.lt_of_lt_of_le (h.heap.sourceBound a ha) sourceBound) (Nat.lt_of_lt_of_le (h.heap.targetBound a ha) targetBound)
      have hoNew : (s₀.setObj a nextObj₀).heap.get a = some (.obj nextObj₀) := by
        simp only [St.setObj,PTrie.get_set_u64 _ _ _ (Nat.lt_of_lt_of_le (h.heap.sourceBound a ha) sourceBound),ite_true]
      obtain ⟨result₀,result,hr₀,hrt,hpost,harg₀,harg⟩ := ih (s₀.setObj a nextObj₀) (s.setObj (R.a a) nextObj) hnew nextObj₀
        tail hrest hoNew hk htail sourceBound targetBound
      refine ⟨result₀,result,?_,?_,hpost,harg₀,harg⟩
      · simp only [fieldsNext,St.obj?,ho]
        exact hr₀
      · simp only [fieldsNext,St.obj?,ht]
        exact hrt


theorem FrameR.fields_view {NR : NumV → NumV → Prop} {R : Ren}
    {a : Nat} {members : List InstMember} {env : Env} {f : Frame}
    (h : FrameR NR R (.k (.fields a members env)) f) :
    ∃ members', f = .k (.fields (R.a a) members' (R.env env)) ∧ ClassFieldsR NR R members members' := by
  obtain ⟨fn,rfl,hf⟩ := h.k_view
  have ht := hf.tag_eq
  cases fn <;> simp only [Encode.fnF,treeTag] at ht
  all_goals try contradiction
  case fields a' members' env' =>
    cases hf with | node tag hs =>
      cases hs with | cons ha hs =>
        cases hs with | cons hm hs =>
          cases hs with | cons he hs =>
            cases ha
            obtain rfl := env_eq_map he
            exact ⟨members',rfl,hm⟩

theorem step_class_fields_eq (F : Ffi) (s : St F.S) (v : Val) (a : Nat)
    (members : List InstMember) (env : Env) (fs : List Frame)
    (hc : s.ctl = .ret v) (hf : s.stack = .k (.fields a members env)::fs) :
    step F s = fieldsNext F {s with stack := fs} a members env := by
  simp only [step,hc,stepRet,hf,retStep,retK]

/-- The source field frame selects and derives the target field list and
captured environment, then applies the actual initializer recursion. -/
theorem step_class_fields_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (a : Nat) (o : Obj) (members : List InstMember) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .k (.fields a members env)::fs₀)
    (onlyPrivate : PrivateFields members) (ho : s₀.heap.get a = some (.obj o)) (hk : o.kind = .ordinary)
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ result₀ result, interpC (step F s₀).run C₀ = some (result₀,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old' result₀ result ∧
      classBodyArgument result₀.stack = classBodyArgument s₀.stack ∧
      classBodyArgument result.stack = classBodyArgument s.stack := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,htail⟩ := h.stack_view hf₀
  obtain ⟨members',hframe,hm⟩ := hfr.fields_view
  rw [hframe] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have ha : live a := hl.1.1.1
  have hml : treeSupport live (Encode.seq (members.map Encode.inst)) := hl.1.1.2.1
  have hel : treeSupport live (Encode.env env) := hl.1.1.2.2.1
  have popped := h.restack htail hl.2
  obtain ⟨r₀,r,hr₀,hr,hs,harg₀,harg⟩ := fieldsNext_private_roles F NR FR R C₀ C live framed before after old old'
    {s₀ with stack := fs₀} {s with stack := fs} popped a o members members' env onlyPrivate hm ha ho hk hml hel sourceBound targetBound
  refine ⟨r₀,r,?_,?_,hs,?_,?_⟩
  · rw [step_class_fields_eq F s₀ v₀ a members env fs₀ hc₀ hf₀,hr₀]; rfl
  · rw [step_class_fields_eq F s v (R.a a) members' (R.env env) fs hc hf,hr]; rfl
  · rw [hf₀]; exact harg₀
  · rw [hf]; exact harg

end Host.Ts.Owned.Parametric

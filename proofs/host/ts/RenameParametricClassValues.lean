import host.ts.RenameParametricClassFields
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem FrameR.privateInitializer_view {NR : NumV → NumV → Prop} {R : Ren}
    {a brand : Nat} {name : Name} {members : List InstMember} {env : Env} {f : Frame}
    (h : FrameR NR R (.k (.privVal a brand name members env)) f) :
    ∃ members', f = .k (.privVal (R.a a) (R.a brand) name members' (R.env env)) ∧
      ClassFieldsR NR R members members' := by
  obtain ⟨fn,rfl,hf⟩ := h.k_view
  have ht := hf.tag_eq
  cases fn <;> simp only [Encode.fnF,treeTag] at ht
  all_goals try contradiction
  case privVal a' brand' name' members' env' =>
    cases hf with | node tag hs =>
      cases hs with | cons ha hs =>
        cases hs with | cons hb hs =>
          cases hs with | cons hn hs =>
            cases hs with | cons hm hs =>
              cases hs with | cons he hs =>
                cases ha; cases hb; cases hn
                obtain rfl := env_eq_map he
                exact ⟨members',rfl,hm⟩

theorem step_private_initializer_eq (F : Ffi) (s : St F.S) (a brand : Nat) (name : Name)
    (members : List InstMember) (env : Env) (fs : List Frame) (o : Obj) (v : Val)
    (hc : s.ctl = .ret v) (hf : s.stack = .k (.privVal a brand name members env)::fs)
    (ho : s.heap.get a = some (.obj o)) :
    step F s = fieldsNext F ({s with stack := fs}.setObj a
      {o with priv := setPrivL brand name (.data v true false) o.priv}) a members env := by
  simp only [step,hc,stepRet,hf,retStep,retK,St.obj?,ho]

/-- Private-field initializer return uses the real private write and subsequent
fieldsNext recursion. The target field, brand, initializer list, environment
and returned value are all derived from the source state relation. -/
theorem step_private_initializer_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (a brand : Nat) (name : Name) (o : Obj) (members : List InstMember) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .k (.privVal a brand name members env)::fs₀)
    (onlyPrivate : PrivateFields members) (ho : s₀.heap.get a = some (.obj o)) (hk : o.kind = .ordinary)
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ value result₀ result, s.ctl = .ret value ∧
      interpC (step F s₀).run C₀ = some (result₀,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old' result₀ result ∧
      classBodyArgument result₀.stack = classBodyArgument s₀.stack ∧
      classBodyArgument result.stack = classBodyArgument s.stack := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,htail⟩ := h.stack_view hf₀
  obtain ⟨members',hframe,hm⟩ := hfr.privateInitializer_view
  rw [hframe] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have ha : live a := hl.1.1.1
  have hb : live brand := hl.1.1.2.1
  have hml : treeSupport live (Encode.seq (members.map Encode.inst)) := hl.1.1.2.2.2.1
  have hel : treeSupport live (Encode.env env) := hl.1.1.2.2.2.2.1
  have hvl := (h.return_values v₀ v hc₀ hc).2
  obtain ⟨ob,hot,hor,hol⟩ := h.heap.readOrdinary a o ha ho hk
  have propRole : PropR NR R (.data v₀ true false) (.data v true false) :=
    .node _ (.cons (.value hv) (.cons (.atom _ _) (.cons (.atom _ _) .nil)))
  have newPriv := hor.privateFields.set hol.2.2.2.1 h.heap.inj brand name hb _ _ propRole
  have privLive := private_support_set_fields hol.2.2.2.1 brand name hb (.data v₀ true false)
    ⟨hvl,True.intro,True.intro,True.intro⟩
  let nextObj₀ := {o with priv := setPrivL brand name (.data v₀ true false) o.priv}
  let nextObj := {ob with priv := setPrivL (R.a brand) name (.data v true false) ob.priv}
  have popped := h.restack htail hl.2
  have hnew := popped.setObject a nextObj₀ nextObj ha (h.heap.ordinary_notFramed a o ha ho hk)
    (hor.with_private _ _ newPriv) ⟨hol.1,hol.2.1,hol.2.2.1,privLive,hol.2.2.2.2⟩
    (Nat.lt_of_lt_of_le (h.heap.sourceBound a ha) sourceBound) (Nat.lt_of_lt_of_le (h.heap.targetBound a ha) targetBound)
  have hoNew : ({s₀ with stack := fs₀}.setObj a nextObj₀).heap.get a = some (.obj nextObj₀) := by
    simp only [St.setObj,PTrie.get_set_u64 _ _ _ (Nat.lt_of_lt_of_le (h.heap.sourceBound a ha) sourceBound),ite_true]
  obtain ⟨r₀,r,hr₀,hr,hs,harg₀,harg⟩ := fieldsNext_private_roles F NR FR R C₀ C live framed before after old old'
    ({s₀ with stack := fs₀}.setObj a nextObj₀) ({s with stack := fs}.setObj (R.a a) nextObj) hnew
    a nextObj₀ members members' env onlyPrivate hm ha hoNew hk hml hel sourceBound targetBound
  refine ⟨v,r₀,r,hc,?_,?_,hs,?_,?_⟩
  · rw [step_private_initializer_eq F s₀ a brand name members env fs₀ o v₀ hc₀ hf₀ ho,hr₀]; rfl
  · rw [step_private_initializer_eq F s (R.a a) (R.a brand) name members' (R.env env) fs ob v hc hf hot,hr]; rfl
  · rw [hf₀]; exact harg₀
  · rw [hf]; exact harg

end Host.Ts.Owned.Parametric

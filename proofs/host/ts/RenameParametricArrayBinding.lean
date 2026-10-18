import host.ts.RenameParametricDeclarations
import host.ts.RenameWrites

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem StateR.target_next_eq {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop}
    {R : Ren} {live live' framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {s₀ s t₀ t : St S} (h : StateR NR FR R live framed before after old old' s₀ s)
    (ht : StateR NR FR R live' framed before after old old' t₀ t) (hn : t₀.next = s₀.next) :
    t.next = s.next := by
  have hs := h.heap.fresh 0
  have ht := ht.heap.fresh 0
  simp only [Nat.add_zero,hn] at hs ht
  exact ht.symm.trans hs

theorem step_bind_init_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (v₀ : Val) (env : Env) (kind : DeclKind) (a : Nat) (prior : Option Val)
    (hc₀ : s₀.ctl = .bind (.id name) v₀ env .init kind)
    (he : lookupEnv name env = some a) (ho : s₀.heap.get a = some (.cell prior))
    (hs : s₀.next ≤ 2^64) (ht : s.next ≤ 2^64) :
    ∃ result, interpC (step F s₀).run C₀ = some ((s₀.setCell a v₀).ret .undef,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old' ((s₀.setCell a v₀).ret .undef) result := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).bind_view
  exact ⟨_,step_bind_init_roles F NR FR R C₀ C live framed before after old old' s₀ s h
    name v₀ v env kind a prior hc₀ hc he ho hs ht⟩

theorem kind_array {NR : NumV → NumV → Prop} {R : Ren} {vs : List Val} {k : Kind}
    (h : TreeR NR R (Encode.kind (.array vs)) (Encode.kind k)) :
    ∃ vs', k = .array vs' ∧ ListR (ValueR NR R) vs vs' := by
  have ht := h.tag_eq
  cases k <;> simp only [Encode.kind,treeTag] at ht
  all_goals try contradiction
  case array vs' =>
    cases h with | node tag hs =>
      cases hs with | cons hv hs => exact ⟨vs',rfl,vals_roles_of hv⟩

/-- Destructuring an owned ordinary array derives its target elements from the
heap relation. The framed output accumulator is deliberately distinguished. -/
theorem HeapR.read_array {S : Type} {NR : NumV → NumV → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {s₀ s : St S}
    (h : HeapR NR R live framed before after s₀ s) (a : Nat) (o : Obj) (vs₀ : List Val)
    (ha : live a) (hn : ¬ framed a) (ho : s₀.heap.get a = some (.obj o)) (hk : o.kind = .array vs₀) :
    ∃ o' vs, s.heap.get (R.a a) = some (.obj o') ∧ o'.kind = .array vs ∧
      ListR (ValueR NR R) vs₀ vs ∧ listSupport (valueSupport live) vs₀ := by
  obtain ⟨o',ho',hr,hl⟩ := h.readObject a o ha hn ho
  have hkind := hr.kind
  rw [hk] at hkind
  obtain ⟨vs,hk',hvs⟩ := kind_array hkind
  have hkl : treeSupport live (Encode.kind (.array vs₀)) := by simpa only [hk] using hl.1
  exact ⟨o',vs,ho',hk',hvs,vals_support_of _ hkl.1⟩

/-- The no-rest branch of the original array-pattern scheduler, including
elisions and exhaustion. The equality below connects it to `arrNext`. -/
def arrayBinding {S : Type} (s : St S) : List (Option Pat) → List Val → Env → BindMode → DeclKind → St S
  | [], _, _, _, _ => s.ret .undef
  | none::ps, vs, env, mode, kind => arrayBinding s ps vs.tail env mode kind
  | some p::ps, vs, env, mode, kind =>
      (s.push (.b (.arr ps none vs.tail env mode kind))).go (.bind p (nthD .undef vs 0) env mode kind)

theorem arrNext_noRest_eq (F : Ffi) (s : St F.S) (ps : List (Option Pat)) (vs : List Val)
    (env : Env) (mode : BindMode) (kind : DeclKind) :
    arrNext F s ps none vs env mode kind = M.pure (arrayBinding s ps vs env mode kind) := by
  induction ps generalizing vs with
  | nil => rfl
  | cons p ps ih => cases p with
    | none => exact ih vs.tail
    | some p => rfl

theorem arrayBinding_roles {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop}
    {R : Ren} {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {s₀ s : St S} (h : StateR NR FR R live framed before after old old' s₀ s)
    (ps : List (Option Pat)) (vs₀ vs : List Val) (env : Env) (mode : BindMode) (kind : DeclKind)
    (hv : ListR (ValueR NR R) vs₀ vs) (hl : listSupport (valueSupport live) vs₀)
    (he : treeSupport live (Encode.env env)) :
    StateR NR FR R live framed before after old old'
      (arrayBinding s₀ ps vs₀ env mode kind) (arrayBinding s ps vs (R.env env) mode kind) := by
  induction ps generalizing vs₀ vs with
  | nil => exact h.go (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩
  | cons p ps ih =>
    have hargs := parameter_args_roles hv
    have hargl := parameter_args_live vs₀ hl
    cases p with
    | none => exact ih vs₀.tail vs.tail hargs.2 hargl.2
    | some p =>
      have hf : FrameR NR R (.b (.arr ps none vs₀.tail env mode kind))
          (.b (.arr ps none vs.tail (R.env env) mode kind)) :=
        .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (.atom _ _) (.cons (vals_roles hargs.2)
          (.cons (env_roles NR R env) (.cons (.atom _ _) (.cons (.atom _ _) .nil))))))) .nil)
      have hfl : treeSupport live (Encode.frame (.b (.arr ps none vs₀.tail env mode kind))) :=
        ⟨⟨True.intro,True.intro,vals_support _ hargl.2,he,True.intro,True.intro,True.intro⟩,True.intro⟩
      exact (h.restack (.cons hf h.stack) ⟨hfl,h.stackLive⟩).go
        (.node _ (.cons (.atom _ _) (.cons (.value hargs.1) (.cons (env_roles NR R env)
          (.cons (.atom _ _) (.cons (.atom _ _) .nil))))))
        ⟨True.intro,hargl.1,he,True.intro,True.intro,True.intro⟩

theorem step_bind_array_eq (F : Ffi) (s : St F.S) (ps : List (Option Pat)) (a : Nat)
    (o : Obj) (vs : List Val) (env : Env) (mode : BindMode) (kind : DeclKind)
    (hc : s.ctl = .bind (.array ps none) (.obj a) env mode kind)
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .array vs) :
    step F s = M.pure (arrayBinding s ps vs env mode kind) := by
  have he := Host.Ts.elemsOf_array F s a o vs (by simp only [St.obj?,ho]) hk
  simp only [step,hc,bindStep,he]
  exact arrNext_noRest_eq F s ps vs env mode kind

theorem step_bind_array_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s) (ps : List (Option Pat))
    (a : Nat) (o : Obj) (vs₀ : List Val) (env : Env) (mode : BindMode) (kind : DeclKind)
    (hc₀ : s₀.ctl = .bind (.array ps none) (.obj a) env mode kind)
    (ho₀ : s₀.heap.get a = some (.obj o)) (hk₀ : o.kind = .array vs₀) (hn : ¬ framed a) :
    ∃ result, interpC (step F s₀).run C₀ = some (arrayBinding s₀ ps vs₀ env mode kind,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old' (arrayBinding s₀ ps vs₀ env mode kind) result := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).bind_view
  have hv : v = .obj (R.a a) := by cases hv; rfl
  rw [hv] at hc
  have hl := h.controlLive
  rw [hc₀] at hl
  obtain ⟨o',vs,ho',hk',hvs,hvl⟩ := h.heap.read_array a o vs₀ hl.2.1 hn ho₀ hk₀
  refine ⟨arrayBinding s ps vs (R.env env) mode kind,?_,?_,
    arrayBinding_roles h ps vs₀ vs env mode kind hvs hvl hl.2.2.1⟩
  · rw [step_bind_array_eq F s₀ ps a o vs₀ env mode kind hc₀ ho₀ hk₀]; rfl
  · rw [step_bind_array_eq F s ps (R.a a) o' vs (R.env env) mode kind hc ho' hk']; rfl

theorem FrameR.b_view {NR : NumV → NumV → Prop} {R : Ren}
    {bf : BindF} {f : Frame} (h : FrameR NR R (.b bf) f) :
    ∃ bf', f = .b bf' ∧ TreeR NR R (Encode.bindF bf) (Encode.bindF bf') := by
  have ht := h.tag_eq
  cases f <;> simp only [Encode.frame,treeTag] at ht
  all_goals try contradiction
  case b bf' => cases h with | node tag hs =>
    cases hs with | cons hh hs => exact ⟨bf',rfl,hh⟩

theorem FrameR.arrayBinding_view {NR : NumV → NumV → Prop} {R : Ren}
    {ps : List (Option Pat)} {vs : List Val} {env : Env} {mode : BindMode} {kind : DeclKind} {f : Frame}
    (h : FrameR NR R (.b (.arr ps none vs env mode kind)) f) :
    ∃ vs', f = .b (.arr ps none vs' (R.env env) mode kind) ∧ ListR (ValueR NR R) vs vs' := by
  obtain ⟨bf',rfl,hh⟩ := h.b_view
  have ht := hh.tag_eq
  cases bf' <;> simp only [Encode.bindF,treeTag] at ht
  all_goals try contradiction
  case arr ps' rest vs' env' mode' kind' =>
    cases hh with | node tag hs =>
      cases hs with | cons hp hs =>
        cases hs with | cons hr hs =>
          cases hs with | cons hv hs =>
            cases hs with | cons he hs =>
              cases hs with | cons hm hs =>
                cases hs with | cons hk hs =>
                  cases hp; cases hr; cases hm; cases hk
                  obtain rfl := env_eq_map he
                  exact ⟨vs',rfl,vals_roles_of hv⟩

theorem step_array_binding_next_eq (F : Ffi) (s : St F.S) (v : Val)
    (ps : List (Option Pat)) (vs : List Val) (env : Env) (mode : BindMode) (kind : DeclKind)
    (fs : List Frame) (hc : s.ctl = .ret v)
    (hf : s.stack = .b (.arr ps none vs env mode kind)::fs) :
    step F s = M.pure (arrayBinding {s with stack := fs} ps vs env mode kind) := by
  simp only [step,hc,stepRet,hf,retStep,retB]
  exact arrNext_noRest_eq F _ ps vs env mode kind

theorem step_array_binding_next_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (ps : List (Option Pat)) (vs₀ : List Val) (env : Env)
    (mode : BindMode) (kind : DeclKind) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .b (.arr ps none vs₀ env mode kind)::fs₀) :
    ∃ result, interpC (step F s₀).run C₀ =
        some (arrayBinding {s₀ with stack := fs₀} ps vs₀ env mode kind,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        (arrayBinding {s₀ with stack := fs₀} ps vs₀ env mode kind) result := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  obtain ⟨vs,hfe,hvs⟩ := hfr.arrayBinding_view
  rw [hfe] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  refine ⟨arrayBinding {s with stack := fs} ps vs (R.env env) mode kind,?_,?_,
    arrayBinding_roles (h.restack hfs hl.2) ps vs₀ vs env mode kind hvs
      (vals_support_of _ hl.1.1.2.2.1) hl.1.1.2.2.2.1⟩
  · rw [step_array_binding_next_eq F s₀ v₀ ps vs₀ env mode kind fs₀ hc₀ hf₀]; rfl
  · rw [step_array_binding_next_eq F s v ps vs (R.env env) mode kind fs hc hf]; rfl

end Host.Ts.Owned.Parametric

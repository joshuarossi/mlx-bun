import host.ts.RenameParametricStatements

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem FrameR.c_view {NR : NumV → NumV → Prop} {R : Ren}
    {cf : CallF} {f : Frame} (h : FrameR NR R (.c cf) f) :
    ∃ cf', f = .c cf' ∧ TreeR NR R (Encode.callF cf) (Encode.callF cf') := by
  have ht := h.tag_eq
  cases f <;> simp only [Encode.frame,treeTag] at ht
  all_goals try contradiction
  case c cf' =>
    cases h with | node tag hs =>
      cases hs with | cons hh hs => exact ⟨cf',rfl,hh⟩

theorem FrameR.args_view {NR : NumV → NumV → Prop} {R : Ren}
    {kind : Nat} {fn this : Val} {acc : List Val} {rest : List Elem} {env : Env} {f : Frame}
    (h : FrameR NR R (.c (.args kind fn this acc rest env)) f) :
    ∃ fn' this' acc', f = .c (.args kind fn' this' acc' rest (R.env env)) ∧
      ValueR NR R fn fn' ∧ ValueR NR R this this' ∧ ListR (ValueR NR R) acc acc' := by
  obtain ⟨cf',rfl,hh⟩ := h.c_view
  have ht := hh.tag_eq
  cases cf' <;> simp only [Encode.callF,treeTag] at ht
  all_goals try contradiction
  case args kind' fn' this' acc' rest' env' =>
    cases hh with | node tag hs =>
      cases hs with | cons hk hs =>
        cases hs with | cons hfn hs =>
          cases hs with | cons hthis hs =>
            cases hs with | cons hacc hs =>
              cases hs with | cons hr hs =>
                cases hs with | cons he hs =>
                  cases hk
                  cases hr
                  obtain rfl := env_eq_map he
                  cases hfn with | value hfn =>
                    cases hthis with | value hthis => exact ⟨fn',this',acc',rfl,hfn,hthis,vals_roles_of hacc⟩

theorem values_reverse_roles {NR : NumV → NumV → Prop} {R : Ren} {as bs : List Val}
    (h : ListR (ValueR NR R) as bs) : ListR (ValueR NR R) as.reverse bs.reverse := by
  induction h with
  | nil => exact .nil
  | cons hv hs ih => simpa only [List.reverse_cons] using ih.append (.cons hv .nil)

theorem listSupport_reverse {α : Type} {p : α → Prop} {as : List α}
    (h : listSupport p as) : listSupport p as.reverse := by
  induction as with
  | nil => exact True.intro
  | cons a as ih =>
    rw [List.reverse_cons]
    exact listSupport_append (ih h.2) ⟨h.1,True.intro⟩

def argumentFrame (spread : Bool) (kind : Nat) (fn this : Val)
    (acc : List Val) (rest : List Elem) (env : Env) : Frame :=
  if spread then .c (.spread kind fn this acc rest env) else .c (.args kind fn this acc rest env)

theorem argumentFrame_roles {NR : NumV → NumV → Prop} {R : Ren}
    (spread : Bool) (kind : Nat) (fn₀ fn this₀ this : Val) (acc₀ acc : List Val) (rest : List Elem) (env : Env)
    (hf : ValueR NR R fn₀ fn) (ht : ValueR NR R this₀ this) (ha : ListR (ValueR NR R) acc₀ acc) :
    FrameR NR R (argumentFrame spread kind fn₀ this₀ acc₀ rest env)
      (argumentFrame spread kind fn this acc rest (R.env env)) := by
  cases spread <;> dsimp only [argumentFrame,Encode.frame,Encode.callF,Encode.atom,Encode.val]
  all_goals repeat first | exact hf | exact ht | exact vals_roles ha | exact env_roles NR R env | constructor

theorem argumentFrame_live (live : Nat → Prop) (spread : Bool) (kind : Nat)
    (fn this : Val) (acc : List Val) (rest : List Elem) (env : Env)
    (hf : valueSupport live fn) (ht : valueSupport live this)
    (ha : listSupport (valueSupport live) acc) (he : treeSupport live (Encode.env env)) :
    treeSupport live (Encode.frame (argumentFrame spread kind fn this acc rest env)) := by
  cases spread <;> dsimp only [argumentFrame,Encode.frame,Encode.callF,Encode.atom,Encode.val,treeSupport,forestSupport]
  all_goals repeat first | exact hf | exact ht | exact vals_support _ ha | exact he | constructor

/-- Exact argument continuation for ordinary calls and construction. The
separate derived-constructor path is guarded out by `kind ≤ 1` below. -/
def argumentState {S : Type} (s : St S) (kind : Nat) (fn this : Val) (acc : List Val)
    (rest : List Elem) (env : Env) : St S :=
  match rest with
  | .expr e::r => (s.push (argumentFrame false kind fn this acc r env)).go (.ev e env)
  | .spread e::r => (s.push (argumentFrame true kind fn this acc r env)).go (.ev e env)
  | .hole::r => argumentState s kind fn this (.undef::acc) r env
  | [] => if kind = 0 then s.go (.call fn this acc.reverse)
    else s.go (.construct fn acc.reverse fn)

theorem argsNext_ordinary_eq (F : Ffi) (s : St F.S) (kind : Nat) (fn this : Val)
    (acc : List Val) (rest : List Elem) (env : Env) (hk : kind ≤ 1) :
    argsNext F s kind fn this acc rest env = M.pure (argumentState s kind fn this acc rest env) := by
  induction rest generalizing acc with
  | nil => cases kind with
    | zero => rfl
    | succ k => cases k with
      | zero => rfl
      | succ k => omega
  | cons e rest ih => cases e with
    | expr e => rfl
    | spread e => rfl
    | hole => exact ih (.undef::acc)

theorem argumentState_roles {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (kind : Nat) (fn₀ fn this₀ this : Val) (acc₀ acc : List Val) (rest : List Elem) (env : Env)
    (hf : ValueR NR R fn₀ fn) (ht : ValueR NR R this₀ this) (ha : ListR (ValueR NR R) acc₀ acc)
    (hfl : valueSupport live fn₀) (htl : valueSupport live this₀)
    (hal : listSupport (valueSupport live) acc₀) (hel : treeSupport live (Encode.env env)) :
    StateR NR FR R live framed before after old old'
      (argumentState s₀ kind fn₀ this₀ acc₀ rest env)
      (argumentState s kind fn this acc rest (R.env env)) := by
  induction rest generalizing acc₀ acc with
  | nil =>
    simp only [argumentState]
    split
    · exact h.go (.node _ (.cons (.value hf) (.cons (.value ht)
        (.cons (vals_roles (values_reverse_roles ha)) .nil))))
        ⟨hfl,htl,vals_support _ (listSupport_reverse hal),True.intro⟩
    · exact h.go (.node _ (.cons (.value hf) (.cons (vals_roles (values_reverse_roles ha))
        (.cons (.value hf) .nil))))
        ⟨hfl,vals_support _ (listSupport_reverse hal),hfl,True.intro⟩
  | cons e rest ih => cases e with
    | hole => exact ih (.undef::acc₀) (.undef::acc) (.cons .undef ha) ⟨True.intro,hal⟩
    | expr e =>
      exact (h.restack (.cons (argumentFrame_roles false kind fn₀ fn this₀ this acc₀ acc rest env hf ht ha) h.stack)
        ⟨argumentFrame_live live false kind fn₀ this₀ acc₀ rest env hfl htl hal hel,h.stackLive⟩).go
          (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,hel,True.intro⟩
    | spread e =>
      exact (h.restack (.cons (argumentFrame_roles true kind fn₀ fn this₀ this acc₀ acc rest env hf ht ha) h.stack)
        ⟨argumentFrame_live live true kind fn₀ this₀ acc₀ rest env hfl htl hal hel,h.stackLive⟩).go
          (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,hel,True.intro⟩

theorem step_argument_eq (F : Ffi) (s : St F.S) (v : Val) (kind : Nat) (fn this : Val)
    (acc : List Val) (rest : List Elem) (env : Env) (fs : List Frame)
    (hc : s.ctl = .ret v) (hfs : s.stack = .c (.args kind fn this acc rest env)::fs) (hk : kind ≤ 1) :
    step F s = M.pure (argumentState {s with stack := fs} kind fn this (v::acc) rest env) := by
  simp only [step,hc,stepRet,hfs,retStep,retC]
  exact argsNext_ordinary_eq F _ kind fn this (v::acc) rest env hk

theorem step_argument_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (kind : Nat) (fn₀ this₀ : Val) (acc₀ : List Val) (rest : List Elem) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hfs₀ : s₀.stack = .c (.args kind fn₀ this₀ acc₀ rest env)::fs₀)
    (hk : kind ≤ 1) :
    ∃ result, interpC (step F s₀).run C₀ =
        some (argumentState {s₀ with stack := fs₀} kind fn₀ this₀ (v₀::acc₀) rest env,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        (argumentState {s₀ with stack := fs₀} kind fn₀ this₀ (v₀::acc₀) rest env) result := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  obtain ⟨fr,fs,hfs,hfr,htail⟩ := h.stack_view hfs₀
  obtain ⟨fn,this,acc,hframe,hfn,hthis,hacc⟩ := hfr.args_view
  rw [hframe] at hfs
  have hl := h.stackLive
  rw [hfs₀] at hl
  have hfl : valueSupport live fn₀ := hl.1.1.2.1
  have htl : valueSupport live this₀ := hl.1.1.2.2.1
  have hal := vals_support_of acc₀ hl.1.1.2.2.2.1
  have hel : treeSupport live (Encode.env env) := hl.1.1.2.2.2.2.2.1
  have hvl := (h.return_values v₀ v hc₀ hc).2
  refine ⟨argumentState {s with stack := fs} kind fn this (v::acc) rest (R.env env),?_,?_,
    argumentState_roles (h.restack htail hl.2) kind fn₀ fn this₀ this (v₀::acc₀) (v::acc) rest env
      hfn hthis (.cons hv hacc) hfl htl ⟨hvl,hal⟩ hel⟩
  · rw [step_argument_eq F s₀ v₀ kind fn₀ this₀ acc₀ rest env fs₀ hc₀ hfs₀ hk]; rfl
  · rw [step_argument_eq F s v kind fn this acc rest (R.env env) fs hc hfs hk]; rfl

end Host.Ts.Owned.Parametric

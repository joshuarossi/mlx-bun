import host.ts.RenameUsingScope

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

def completionControl : Comp → Ctl
  | .normal v => .ret v
  | .abrupt a => .abr a

theorem resume_control {S : Type} (s : St S) (c : Comp) : resume s c = s.go (completionControl c) := by
  cases c <;> rfl

theorem completion_roles {NR : NumV → NumV → Prop} {R : Ren} {c c' : Comp}
    (h : TreeR NR R (Encode.comp c) (Encode.comp c')) :
    ControlR NR R (completionControl c) (completionControl c') := by
  have tags := h.tag_eq
  cases c <;> cases c' <;> simp only [Encode.comp,treeTag] at tags <;> try contradiction
  all_goals cases h with | node tag fields =>
    cases fields with | cons value rest => exact .node _ (.cons value .nil)

theorem completion_support {live : Nat → Prop} {c : Comp}
    (h : treeSupport live (Encode.comp c)) : treeSupport live (Encode.ctl (completionControl c)) := by
  cases c <;> exact h

theorem completion_view {NR : NumV → NumV → Prop} {R : Ren} {c : Comp} {ctl : Ctl}
    (h : ControlR NR R (completionControl c) ctl) :
    ∃ c', ctl = completionControl c' ∧ TreeR NR R (Encode.comp c) (Encode.comp c') := by
  cases c with
  | normal value =>
    obtain ⟨value',rfl,role⟩ := h.ret_view
    exact ⟨.normal value',rfl,.node _ (.cons (.value role) .nil)⟩
  | abrupt abrupt =>
    obtain ⟨abrupt',rfl,role⟩ := h.abr_view
    exact ⟨.abrupt abrupt',rfl,.node _ (.cons role .nil)⟩

theorem pairs_nil_view {NR : NumV → NumV → Prop} {R : Ren} {xs : List (Val × Val)}
    (h : TreeR NR R (Encode.pairs []) (Encode.pairs xs)) : xs = [] := by
  cases xs with
  | nil => rfl
  | cons head tail => cases h with | node tag fields => cases fields

theorem pairs_cons_view {NR : NumV → NumV → Prop} {R : Ren} {x m : Val}
    {xs ys : List (Val × Val)} (h : TreeR NR R (Encode.pairs ((x,m)::xs)) (Encode.pairs ys)) :
    ∃ y n rest, ys = (y,n)::rest ∧ ValueR NR R x y ∧ ValueR NR R m n ∧
      TreeR NR R (Encode.pairs xs) (Encode.pairs rest) := by
  cases ys with
  | nil => cases h with | node tag fields => cases fields
  | cons head tail =>
    rcases head with ⟨y,n⟩
    cases h with | node tag fields => cases fields with | cons pair tailRoles =>
      cases pair with | node tag pairFields => cases pairFields with | cons xRole pairFields =>
        cases pairFields with | cons mRole pairFields =>
          cases xRole with | value xRole => cases mRole with | value mRole =>
            exact ⟨y,n,tail,rfl,xRole,mRole,.node _ tailRoles⟩

theorem FrameR.dispose_view {NR : NumV → NumV → Prop} {R : Ren}
    {resources : List (Val × Val)} {c : Comp} {f : Frame}
    (h : FrameR NR R (.s (.dispose resources c)) f) :
    ∃ resources' c', f = .s (.dispose resources' c') ∧
      TreeR NR R (Encode.pairs resources) (Encode.pairs resources') ∧
      TreeR NR R (Encode.comp c) (Encode.comp c') := by
  obtain ⟨statement,rfl,hh⟩ := h.s_view
  have tags := hh.tag_eq
  cases statement <;> simp only [Encode.stmtF,treeTag] at tags
  all_goals try contradiction
  case dispose resources' c' =>
    cases hh with | node tag fields => cases fields with | cons pair fields =>
      cases fields with | cons pending fields => exact ⟨resources',c',rfl,pair,pending⟩

end Host.Ts.Owned.Parametric

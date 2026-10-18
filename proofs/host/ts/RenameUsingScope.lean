import host.ts.RenameParametricDeclarations
import host.ts.RenameRuntimeBinding

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

def innerTag : Owned.Tree → String
  | .node _ [t] => treeTag t
  | _ => ""

theorem TreeR.innerTag_eq {NR : NumV → NumV → Prop} {R : Ren} {a b : Owned.Tree}
    (h : TreeR NR R a b) : innerTag a = innerTag b := by
  cases h <;> try rfl
  case node tag hs =>
    cases hs with
    | nil => rfl
    | cons h hs =>
      cases hs with
      | nil => exact h.tag_eq
      | cons _ _ => rfl

def scopeFrame (f : Frame) : Bool := innerTag (Encode.frame f) == "StmtF.scope"

theorem FrameR.scope_eq {NR : NumV → NumV → Prop} {R : Ren} {f f' : Frame}
    (h : FrameR NR R f f') : scopeFrame f = scopeFrame f' := by
  unfold scopeFrame
  rw [h.innerTag_eq]

theorem addUsing_cons (resource method : Val) (f : Frame) (fs : List Frame)
    (notScope : scopeFrame f = false) :
    addUsing (resource,method) (f::fs) = (addUsing (resource,method) fs).map (f::·) := by
  cases f <;> try rfl
  case s statement =>
    cases statement <;> try rfl
    case scope resources => contradiction

theorem FrameR.scope_view {NR : NumV → NumV → Prop} {R : Ren} {resources : List (Val × Val)} {f : Frame}
    (h : FrameR NR R (.s (.scope resources)) f) :
    ∃ target, f = .s (.scope target) ∧ TreeR NR R (Encode.pairs resources) (Encode.pairs target) := by
  obtain ⟨statement,rfl,hh⟩ := h.s_view
  have tags := hh.tag_eq
  cases statement <;> simp only [Encode.stmtF,treeTag] at tags
  all_goals try contradiction
  case scope target =>
    cases hh with | node tag fields =>
      cases fields with | cons resourceRoles _ => exact ⟨target,rfl,resourceRoles⟩

def ScopeAt (frames : List Frame) : Nat → Prop
  | 0 => match frames with | .s (.scope _)::_ => True | _ => False
  | i+1 => match frames with | f::fs => scopeFrame f = false ∧ ScopeAt fs i | _ => False

instance scopeAtDecidable (frames : List Frame) (index : Nat) : Decidable (ScopeAt frames index) := by
  induction index generalizing frames with
  | zero =>
    cases frames with
    | nil => exact isFalse (fun h => h)
    | cons head tail =>
      cases head <;> try exact isFalse (fun h => h)
      case s statement => cases statement <;> first | exact isFalse (fun h => h) | exact isTrue True.intro
  | succ index ih =>
    cases frames with
    | nil => exact isFalse (fun h => h)
    | cons head tail =>
      change Decidable (scopeFrame head = false ∧ ScopeAt tail index)
      letI := ih tail
      infer_instance

/-- The source's nearest scope determines the target update. Saved frames
outside that scope retain their original relation and live support. -/
theorem addUsing_roles {NR : NumV → NumV → Prop} {R : Ren} {live : Nat → Prop}
    {resource₀ resource method₀ method : Val}
    (resourceRole : ValueR NR R resource₀ resource) (methodRole : ValueR NR R method₀ method)
    (resourceLive : valueSupport live resource₀) (methodLive : valueSupport live method₀) :
    ∀ (source target : List Frame) (index : Nat), ScopeAt source index →
      ListR (FrameR NR R) source target → listSupport (fun f => treeSupport live (Encode.frame f)) source →
      ∃ sourcePost targetPost, addUsing (resource₀,method₀) source = some sourcePost ∧
        addUsing (resource,method) target = some targetPost ∧
        ListR (FrameR NR R) sourcePost targetPost ∧
        listSupport (fun f => treeSupport live (Encode.frame f)) sourcePost := by
  intro source
  induction source with
  | nil => intro target index scope; cases index <;> contradiction
  | cons head rest ih =>
    intro target index scope related supported
    cases related with | cons frameRole restRoles =>
      cases index with
      | zero =>
        cases head <;> try contradiction
        case s statement =>
          cases statement <;> try contradiction
          case scope resources =>
            obtain ⟨targetResources,rfl,pairs⟩ := frameRole.scope_view
            have pairsRole : TreeR NR R (Encode.pairs ((resource₀,method₀)::resources))
                (Encode.pairs ((resource,method)::targetResources)) := by
              cases pairs with | node tag fields =>
                exact .node _ (.cons (.node _ (.cons (.value resourceRole) (.cons (.value methodRole) .nil))) fields)
            have framePost : FrameR NR R (.s (.scope ((resource₀,method₀)::resources)))
                (.s (.scope ((resource,method)::targetResources))) :=
              .node _ (.cons (.node _ (.cons pairsRole .nil)) .nil)
            refine ⟨_,_,rfl,rfl,.cons framePost restRoles,?_,supported.2⟩
            exact ⟨⟨⟨⟨resourceLive,methodLive,True.intro⟩,supported.1.1.1⟩,True.intro⟩,True.intro⟩
      | succ index =>
        obtain ⟨sourcePost,targetPost,left,right,post,postLive⟩ := ih _ index scope.2 restRoles supported.2
        have targetNotScope : scopeFrame _ = false := frameRole.scope_eq ▸ scope.1
        refine ⟨head::sourcePost,_::targetPost,?_,?_,.cons frameRole post,⟨supported.1,postLive⟩⟩
        · rw [addUsing_cons _ _ _ _ scope.1,left]; rfl
        · rw [addUsing_cons _ _ _ _ targetNotScope,right]; rfl

end Host.Ts.Owned.Parametric

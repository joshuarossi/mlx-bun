import host.ts.RenameParametricPrivateAssign
import host.ts.RenameParametricNumbers
import host.ts.RenameParametricExpressionReturns

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem step_variable_fixed_fields (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (env : Env) (a : Nat) (v : Val) (hc₀ : s₀.ctl = .ev (.id name) env)
    (he₀ : lookupEnv name env = some a) (cell : s.heap.get (R.a a) = some (.cell (some v)))
    (run : interpC (step F s).run C = some (result,D)) :
    result.ctl = .ret v ∧ result.heap = s.heap := by
  have hc := (h.control_view hc₀).ev_view
  have he : lookupEnv name (R.env env) = some (R.a a) := by rw [lookupEnv_map,he₀]; rfl
  rw [step_variable_eq F s name (R.env env) (R.a a) v hc he cell] at run
  have stateEq := congrArg Prod.fst (Option.some.inj run)
  exact ⟨(congrArg St.ctl stateEq).symm,(congrArg St.heap stateEq).symm⟩

theorem FrameR.updateOld_view {NR : NumV → NumV → Prop} {R : Ren}
    {name : Name} {env : Env} {f : Frame}
    (h : FrameR NR R (.a (.updOld true false (.var name env))) f) :
    f = .a (.updOld true false (.var name (R.env env))) := by
  obtain ⟨af,rfl,hh⟩ := h.a_view
  have ht := hh.tag_eq
  cases af <;> simp only [Encode.asgF,treeTag] at ht
  all_goals try contradiction
  case updOld inc pre target =>
    cases hh with | node tag hs =>
      cases hs with | cons hi hs =>
        cases hs with | cons hp hs =>
          cases hs with | cons htarget hs =>
            cases hi; cases hp
            have ht := htarget.tag_eq
            cases target <;> simp only [Encode.target,treeTag] at ht
            all_goals try contradiction
            case var name' env' =>
              cases htarget with | node tag hs =>
                cases hs with | cons hn hs =>
                  cases hs with | cons he hs =>
                    cases hn
                    obtain rfl := env_eq_map he
                    rfl

theorem step_update_var_eq (F : Ffi) (s : St F.S) (name : Name) (env : Env)
    (a : Nat) (v : Val) (hc : s.ctl = .ev (.update true false (.id name)) env)
    (he : lookupEnv name env = some a) (hv : s.heap.get a = some (.cell (some v))) :
    step F s = M.pure ((s.push (.a (.updOld true false (.var name env)))).ret v) := by
  simp only [step,hc,evStep,evUpdate,readVar,he,St.cell?,hv,St.push,retS]

theorem FrameR.constant_view {NR : NumV → NumV → Prop} {R : Ren}
    {value : Val} {f : Frame} (h : FrameR NR R (.e (.const value)) f) :
    ∃ v, f = .e (.const v) ∧ ValueR NR R value v := by
  obtain ⟨ef,rfl,hh⟩ := h.e_view
  have ht := hh.tag_eq
  cases ef <;> simp only [Encode.exprF,treeTag] at ht
  all_goals try contradiction
  case const value' =>
    cases hh with | node tag hs =>
      cases hs with | cons hv hs =>
        cases hv with | value hr => exact ⟨value',rfl,hr⟩

theorem step_constant_eq (F : Ffi) (s : St F.S) (value saved : Val) (fs : List Frame)
    (hc : s.ctl = .ret value) (hf : s.stack = .e (.const saved)::fs) :
    step F s = M.pure ({s with stack := fs}.ret saved) := by
  simp only [step,hc,stepRet,hf,retStep,retE,retS]

theorem step_constant_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (value₀ saved₀ : Val) (fs₀ : List Frame) (hc₀ : s₀.ctl = .ret value₀)
    (hf₀ : s₀.stack = .e (.const saved₀)::fs₀) :
    ∃ result, interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.ret saved₀,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old' ({s₀ with stack := fs₀}.ret saved₀) result ∧
      result.heap = s.heap := by
  obtain ⟨value,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  obtain ⟨saved,hframe,hr⟩ := hfr.constant_view
  rw [hframe] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  refine ⟨{s with stack := fs}.ret saved,?_,?_,?_,rfl⟩
  · rw [step_constant_eq F s₀ value₀ saved₀ fs₀ hc₀ hf₀]; rfl
  · rw [step_constant_eq F s value saved fs hc hf]; rfl
  · exact (h.restack hfs hl.2).go (.node _ (.cons (.value hr) .nil)) ⟨hl.1.1.1,True.intro⟩

/-- Reading a variable for a postfix update retains its incoming occurrence
and installs the original assignment continuation. -/
theorem step_update_var_from_source_fixed (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (env : Env) (a : Nat) (v₀ v : Val)
    (hc₀ : s₀.ctl = .ev (.update true false (.id name)) env)
    (he₀ : lookupEnv name env = some a) (hv₀ : s₀.heap.get a = some (.cell (some v₀)))
    (hv : s.heap.get (R.a a) = some (.cell (some v))) :
    interpC (step F s₀).run C₀ = some ((s₀.push (.a (.updOld true false (.var name env)))).ret v₀,C₀) ∧
      interpC (step F s).run C = some ((s.push (.a (.updOld true false (.var name (R.env env))))).ret v,C) ∧
      StateR NR FR R live framed before after old old'
        ((s₀.push (.a (.updOld true false (.var name env)))).ret v₀)
        ((s.push (.a (.updOld true false (.var name (R.env env))))).ret v) := by
  have hc := (h.control_view hc₀).ev_view
  have hl := h.controlLive
  rw [hc₀] at hl
  have ha := env_lookup_live name env a hl.2.1 he₀
  obtain ⟨v',hv',hr,hvl⟩ := h.heap.readCell a v₀ ha hv₀
  have eq : v' = v := Option.some.inj (HObj.cell.inj (Option.some.inj (hv'.symm.trans hv)))
  subst v'
  have he : lookupEnv name (R.env env) = some (R.a a) := by rw [lookupEnv_map,he₀]; rfl
  have hf : FrameR NR R (.a (.updOld true false (.var name env)))
      (.a (.updOld true false (.var name (R.env env)))) := by
    repeat first | exact env_roles NR R env | constructor
  have hfl : treeSupport live (Encode.frame (.a (.updOld true false (.var name env)))) :=
    ⟨⟨True.intro,True.intro,⟨True.intro,hl.2.1,True.intro⟩,True.intro⟩,True.intro⟩
  refine ⟨?_,?_,(h.restack (.cons hf h.stack) ⟨hfl,h.stackLive⟩).go
    (.node _ (.cons (.value hr) .nil)) ⟨hvl,True.intro⟩⟩
  · rw [step_update_var_eq F s₀ name env a v₀ hc₀ he₀ hv₀]; rfl
  · rw [step_update_var_eq F s name (R.env env) (R.a a) v hc he hv]; rfl

def fixedPostincrement {S : Type} (s : St S) (a : Nat) (x y : F64) (fs : List Frame) : St S :=
  {s.setCell a (.num (.lit y)) with ctl := .ret (.num (.lit y)),stack := .e (.const (.num (.lit x)))::fs}

/-- Literal index increments run the original number operation, update the
actual live cell and retain the old literal in the postfix continuation. -/
theorem step_postinc_fixed_from_source (F : Ffi) (FR : Ren → F.S → F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (name : Name) (env : Env) (address : Nat) (x y : F64) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.num (.lit x))) (hc : s.ctl = .ret (.num (.lit x)))
    (hf₀ : s₀.stack = .a (.updOld true false (.var name env))::fs₀)
    (he₀ : lookupEnv name env = some address)
    (cell₀ : s₀.heap.get address = some (.cell (some (.num (.lit x)))))
    (cell : s.heap.get (R.a address) = some (.cell (some (.num (.lit x)))))
    (notFramed : ¬ framed address) (sourceBound : s₀.next ≤ 2^64) (bound : s.next ≤ 2^64)
    (sum : F64.bin .add x (.fin false 1 0) = y) :
    ∃ fs, interpC (step F s₀).run C₀ = some (fixedPostincrement s₀ address x y fs₀,C₀) ∧
      interpC (step F s).run C = some (fixedPostincrement s (R.a address) x y fs,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (fixedPostincrement s₀ address x y fs₀) (fixedPostincrement s (R.a address) x y fs) := by
  let NR := NumberRoles ν₀ ν C₀ C
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  rw [hfr.updateOld_view] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have ha := env_lookup_live name env address hl.1.1.2.2.1.2.1 he₀
  have he : lookupEnv name (R.env env) = some (R.a address) := by rw [lookupEnv_map,he₀]; rfl
  have cell₀' : s₀.cell? address = some (some (.num (.lit x))) := by simp only [St.cell?,cell₀]
  have cell' : s.cell? (R.a address) = some (some (.num (.lit x))) := by simp only [St.cell?,cell]
  have hh := h.setCell address (.num (.lit y)) (.num (.lit y)) ha notFramed
    (.num ⟨.lit y,NumRole.literal ν₀ ν C₀ C y⟩) True.intro
    (Nat.lt_of_lt_of_le (h.heap.sourceBound address ha) sourceBound)
    (Nat.lt_of_lt_of_le (h.heap.targetBound address ha) bound)
  have hold : FrameR NR R (.e (.const (.num (.lit x)))) (.e (.const (.num (.lit x)))) := by
    repeat first | exact NumRole.literal ν₀ ν C₀ C x | exact ValueR.num ⟨.lit x,NumRole.literal ν₀ ν C₀ C x⟩ | constructor
  have holdLive : treeSupport live (Encode.frame (.e (.const (.num (.lit x))))) :=
    ⟨⟨True.intro,True.intro⟩,True.intro⟩
  have result := (hh.restack (.cons hold hfs) ⟨holdLive,hl.2⟩).go
    (c := .ret (.num (.lit y))) (c' := .ret (.num (.lit y)))
    (.node _ (.cons (.value (.num ⟨.lit y,NumRole.literal ν₀ ν C₀ C y⟩)) .nil)) ⟨True.intro,True.intro⟩
  refine ⟨fs,?_,?_,result⟩
  · rw [step_postinc_eq F s₀ (.lit x) fs₀ name env address hc₀ hf₀ he₀ cell₀']
    simp only [numBin,one,sum]
    rfl
  · rw [step_postinc_eq F s (.lit x) fs name (R.env env) (R.a address) hc hf he cell']
    simp only [numBin,one,sum]
    rfl

end Host.Ts.Owned.Parametric

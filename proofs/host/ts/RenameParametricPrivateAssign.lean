import host.ts.RenameParametricPrivate
import host.ts.RenameParametricExpressionEntry
import host.ts.RenameRoutePrivateFields
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem FrameR.a_view {NR : NumV → NumV → Prop} {R : Ren}
    {af : AsgF} {f : Frame} (h : FrameR NR R (.a af) f) :
    ∃ af', f = .a af' ∧ TreeR NR R (Encode.asgF af) (Encode.asgF af') := by
  have ht := h.tag_eq
  cases f <;> simp only [Encode.frame,treeTag] at ht
  all_goals try contradiction
  case a af' =>
    cases h with | node tag hs =>
      cases hs with | cons hh hs => exact ⟨af',rfl,hh⟩

theorem FrameR.privateReceiver_view {NR : NumV → NumV → Prop} {R : Ren}
    {brand : Nat} {name : Name} {rhs : Expr} {env : Env} {f : Frame}
    (h : FrameR NR R (.a (.privObj .assign brand name rhs env)) f) :
    f = .a (.privObj .assign (R.a brand) name rhs (R.env env)) := by
  obtain ⟨af',rfl,hh⟩ := h.a_view
  have ht := hh.tag_eq
  cases af' <;> simp only [Encode.asgF,treeTag] at ht
  all_goals try contradiction
  case privObj op' brand' name' rhs' env' =>
    cases hh with | node tag hs =>
      cases hs with | cons hop hs =>
        cases hs with | cons hb hs =>
          cases hs with | cons hn hs =>
            cases hs with | cons hr hs =>
              cases hs with | cons he hs =>
                cases hop
                cases hb
                cases hn
                cases hr
                obtain rfl := env_eq_map he
                rfl

theorem step_private_assignment_eq (F : Ffi) (s : St F.S) (receiver : Expr) (name : Name)
    (opt : Bool) (rhs : Expr) (env : Env) (brand : Nat)
    (hc : s.ctl = .ev (.assign .assign (.expr (.priv receiver name opt)) rhs) env)
    (hb : lookupEnv (privName name) env = some brand) :
    step F s = M.pure ((s.push (.a (.privObj .assign brand name rhs env))).go (.ev receiver env)) := by
  simp only [step,hc,evStep,evAssign,hb]

theorem step_private_assignment_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (receiver : Expr) (name : Name) (opt : Bool) (rhs : Expr) (env : Env) (brand : Nat)
    (hc₀ : s₀.ctl = .ev (.assign .assign (.expr (.priv receiver name opt)) rhs) env)
    (hb₀ : lookupEnv (privName name) env = some brand) :
    interpC (step F s₀).run C₀ = some ((s₀.push (.a (.privObj .assign brand name rhs env))).go (.ev receiver env),C₀) ∧
      interpC (step F s).run C = some ((s.push (.a (.privObj .assign (R.a brand) name rhs (R.env env)))).go (.ev receiver (R.env env)),C) ∧
      StateR NR FR R live framed before after old old'
        ((s₀.push (.a (.privObj .assign brand name rhs env))).go (.ev receiver env))
        ((s.push (.a (.privObj .assign (R.a brand) name rhs (R.env env)))).go (.ev receiver (R.env env))) := by
  have hc := (h.control_view hc₀).ev_view
  have hl := h.controlLive
  rw [hc₀] at hl
  have he := hl.2.1
  have hb := env_lookup_live (privName name) env brand he hb₀
  have hlookup : lookupEnv (privName name) (R.env env) = some (R.a brand) := by
    rw [lookupEnv_map,hb₀]; rfl
  have hf : FrameR NR R (.a (.privObj .assign brand name rhs env))
      (.a (.privObj .assign (R.a brand) name rhs (R.env env))) := by
    repeat first | exact env_roles NR R env | constructor
  have hfl : treeSupport live (Encode.frame (.a (.privObj .assign brand name rhs env))) :=
    ⟨⟨True.intro,hb,True.intro,True.intro,he,True.intro⟩,True.intro⟩
  refine ⟨?_,?_,(h.restack (.cons hf h.stack) ⟨hfl,h.stackLive⟩).go
    (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,he,True.intro⟩⟩
  · rw [step_private_assignment_eq F s₀ receiver name opt rhs env brand hc₀ hb₀]; rfl
  · rw [step_private_assignment_eq F s receiver name opt rhs (R.env env) (R.a brand) hc hlookup]; rfl

def privateReceiverState {S : Type} (s : St S) (receiver : Val) (brand : Nat)
    (name : Name) (rhs : Expr) (env : Env) : St S :=
  (s.push (.a (.put none (.priv receiver brand name) .undef))).go (.ev rhs env)

theorem step_private_receiver_eq (F : Ffi) (s : St F.S) (receiver : Val) (brand : Nat)
    (name : Name) (rhs : Expr) (env : Env) (fs : List Frame)
    (hc : s.ctl = .ret receiver) (hf : s.stack = .a (.privObj .assign brand name rhs env)::fs) :
    step F s = M.pure (privateReceiverState {s with stack := fs} receiver brand name rhs env) := by
  simp only [step,hc,stepRet,hf,retStep,retA,asgTarget,privateReceiverState]

theorem step_private_receiver_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (receiver₀ : Val) (brand : Nat) (name : Name) (rhs : Expr) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret receiver₀) (hf₀ : s₀.stack = .a (.privObj .assign brand name rhs env)::fs₀) :
    ∃ receiver fs, s.ctl = .ret receiver ∧
      interpC (step F s₀).run C₀ = some (privateReceiverState {s₀ with stack := fs₀} receiver₀ brand name rhs env,C₀) ∧
      interpC (step F s).run C = some (privateReceiverState {s with stack := fs} receiver (R.a brand) name rhs (R.env env),C) ∧
      StateR NR FR R live framed before after old old'
        (privateReceiverState {s₀ with stack := fs₀} receiver₀ brand name rhs env)
        (privateReceiverState {s with stack := fs} receiver (R.a brand) name rhs (R.env env)) := by
  obtain ⟨receiver,hc,hv⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,htail⟩ := h.stack_view hf₀
  rw [hfr.privateReceiver_view] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have hb : live brand := hl.1.1.2.1
  have he : treeSupport live (Encode.env env) := hl.1.1.2.2.2.2.1
  have hvLive := (h.return_values receiver₀ receiver hc₀ hc).2
  have hnew : FrameR NR R (.a (.put none (.priv receiver₀ brand name) .undef))
      (.a (.put none (.priv receiver (R.a brand) name) .undef)) := by
    repeat first | exact hv | constructor
  have hnewLive : treeSupport live (Encode.frame (.a (.put none (.priv receiver₀ brand name) .undef))) :=
    ⟨⟨True.intro,⟨hvLive,hb,True.intro,True.intro⟩,True.intro,True.intro⟩,True.intro⟩
  refine ⟨receiver,fs,hc,?_,?_,(h.restack (.cons hnew htail) ⟨hnewLive,hl.2⟩).go
    (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,he,True.intro⟩⟩
  · rw [step_private_receiver_eq F s₀ receiver₀ brand name rhs env fs₀ hc₀ hf₀]; rfl
  · rw [step_private_receiver_eq F s receiver (R.a brand) name rhs (R.env env) fs hc hf]; rfl
theorem FrameR.privatePut_view {NR : NumV → NumV → Prop} {R : Ren}
    {a brand : Nat} {name : Name} {prior : Val} {f : Frame}
    (h : FrameR NR R (.a (.put none (.priv (.obj a) brand name) prior)) f) :
    ∃ prior', f = .a (.put none (.priv (.obj (R.a a)) (R.a brand) name) prior') := by
  obtain ⟨af',rfl,hh⟩ := h.a_view
  have ht := hh.tag_eq
  cases af' <;> simp only [Encode.asgF,treeTag] at ht
  all_goals try contradiction
  case put op' target' prior' =>
    cases hh with | node tag hs =>
      cases hs with | cons hop hs =>
        cases hs with | cons htarget hs =>
          cases hs with | cons hp hs =>
            cases hop
            have ht := htarget.tag_eq
            cases target' <;> simp only [Encode.target,treeTag] at ht
            all_goals try contradiction
            case priv receiver' brand' name' =>
              cases htarget with | node tag ts =>
                cases ts with | cons hv ts =>
                  cases ts with | cons hb ts =>
                    cases ts with | cons hn ts =>
                      cases hv with | value hv =>
                        cases hv
                        cases hb
                        cases hn
                        exact ⟨prior',rfl⟩

/-- This is the real writable private-field store. Receiver and brand support,
all target frames and the target descriptor are derived from the source state. -/
theorem step_private_store_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (oldTrace oldTrace' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after oldTrace oldTrace' s₀ s)
    (a brand : Nat) (name : Name) (v₀ prior₀ old : Val) (e : Bool) (o₀ : Obj) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀)
    (hf₀ : s₀.stack = .a (.put none (.priv (.obj a) brand name) prior₀)::fs₀)
    (ho : s₀.heap.get a = some (.obj o₀)) (hk : o₀.kind = .ordinary)
    (hp : findPriv brand name o₀.priv = some (.data old true e))
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ (v : Val) (o : Obj) (fs : List Frame), s.ctl = .ret v ∧
      interpC (step F s₀).run C₀ = some (({s₀ with stack := fs₀}.setObj a
        {o₀ with priv := setPrivL brand name (.data v₀ true e) o₀.priv}).ret v₀,C₀) ∧
      interpC (step F s).run C = some (({s with stack := fs}.setObj (R.a a)
        {o with priv := setPrivL (R.a brand) name (.data v true e) o.priv}).ret v,C) ∧
      StateR NR FR R live framed before after oldTrace oldTrace'
        (({s₀ with stack := fs₀}.setObj a {o₀ with priv := setPrivL brand name (.data v₀ true e) o₀.priv}).ret v₀)
        (({s with stack := fs}.setObj (R.a a) {o with priv := setPrivL (R.a brand) name (.data v true e) o.priv}).ret v) := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,htail⟩ := h.stack_view hf₀
  obtain ⟨prior,hfp⟩ := hfr.privatePut_view
  rw [hfp] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have ha : live a := hl.1.1.2.1.1
  have hb : live brand := hl.1.1.2.1.2.1
  obtain ⟨o,r₀,r,hr⟩ := step_private_store_roles F NR FR R C₀ C live framed before after oldTrace oldTrace'
    s₀ s h a brand name v₀ v prior₀ prior old e o₀ fs₀ fs hv hc₀ hc hf₀ hf ha hb ho hk hp
      (Nat.lt_of_lt_of_le (h.heap.sourceBound a ha) sourceBound)
      (Nat.lt_of_lt_of_le (h.heap.targetBound a ha) targetBound)
  exact ⟨v,o,fs,hc,r₀,r,hr⟩

theorem findPriv_set_same (brand : Nat) (name : Name) (p : PropV) (ps : Privs) :
    findPriv brand name (setPrivL brand name p ps) = some p := by
  induction ps with
  | nil => simp only [setPrivL,findPriv,privEq,Nat.beq_refl,nameEq,Bool.and_self,Bool.cond_true]
  | cons entry rest ih =>
    obtain ⟨j,q⟩ := entry
    simp only [setPrivL]
    cases he : privEq brand name j <;> simp only [he,Bool.cond_false,Bool.cond_true,findPriv]
    exact ih

/-- The exact value in the current return control is what the private store
writes. This companion retains an occurrence role independently of ValueR. -/
theorem step_private_store_fields (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (oldTrace oldTrace' : List Event) (s₀ s result : St F.S)
    (h : StateR NR FR R live framed before after oldTrace oldTrace' s₀ s)
    (a brand : Nat) (name : Name) (v₀ v prior₀ old : Val) (e : Bool) (o₀ : Obj) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hc : s.ctl = .ret v)
    (hf₀ : s₀.stack = .a (.put none (.priv (.obj a) brand name) prior₀)::fs₀)
    (ho : s₀.heap.get a = some (.obj o₀)) (hk : o₀.kind = .ordinary)
    (hp : findPriv brand name o₀.priv = some (.data old true e))
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64)
    (run : interpC (step F s).run C = some (result,D)) :
    result.ctl = .ret v ∧ PrivateData result (R.a a) (R.a brand) name v := by
  obtain ⟨v',o,fs,hc',_,hr,_⟩ := step_private_store_from_source F NR FR R C₀ C live framed before after oldTrace oldTrace'
    s₀ s h a brand name v₀ prior₀ old e o₀ fs₀ hc₀ hf₀ ho hk hp sourceBound targetBound
  have hv : v' = v := Ctl.ret.inj (hc'.symm.trans hc)
  subst v'
  have he := congrArg Prod.fst (Option.some.inj (run.symm.trans hr))
  dsimp only at he
  rw [he]
  have hl := h.stackLive
  rw [hf₀] at hl
  have ha : live a := hl.1.1.2.1.1
  have bound : R.a a < 2^64 := Nat.lt_of_lt_of_le (h.heap.targetBound a ha) targetBound
  exact ⟨rfl,{o with priv := setPrivL (R.a brand) name (.data v true e) o.priv},true,e,by simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ bound,ite_true],findPriv_set_same _ _ _ _⟩

theorem step_private_assignment_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (receiver : Expr) (name : Name) (opt : Bool) (rhs : Expr) (env : Env) (brand : Nat)
    (hc₀ : s₀.ctl = .ev (.assign .assign (.expr (.priv receiver name opt)) rhs) env)
    (hb₀ : lookupEnv (privName name) env = some brand)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨_,hr,_⟩ := step_private_assignment_from_source F NR FR R C₀ C live framed before after old old' s₀ s h
    receiver name opt rhs env brand hc₀ hb₀
  have he := congrArg Prod.fst (Option.some.inj (run.symm.trans hr))
  have hh := congrArg (fun t : St F.S => t.heap) he
  exact hh

theorem step_private_receiver_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (receiver : Val) (brand : Nat) (name : Name) (rhs : Expr) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret receiver) (hf₀ : s₀.stack = .a (.privObj .assign brand name rhs env)::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,fs,_,_,hr,_⟩ := step_private_receiver_from_source F NR FR R C₀ C live framed before after old old' s₀ s h
    receiver brand name rhs env fs₀ hc₀ hf₀
  have he := congrArg Prod.fst (Option.some.inj (run.symm.trans hr))
  have hh := congrArg (fun t : St F.S => t.heap) he
  exact hh

end Host.Ts.Owned.Parametric

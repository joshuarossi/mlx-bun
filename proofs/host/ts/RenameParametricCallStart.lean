import host.ts.RenameParametricArguments

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

inductive CallStart where
  | callee (optional : Bool) | method (optional : Bool) | construct

def CallStart.frame (this : Val) (args : List Elem) (env : Env) : CallStart → Frame
  | .callee opt => .c (.callee args env opt)
  | .method opt => .c (.method this args env opt)
  | .construct => .c (.newCallee args env)

def CallStart.kind : CallStart → Nat
  | .construct => 1 | _ => 0

def CallStart.receiver (this : Val) : CallStart → Val
  | .method _ => this | _ => .undef

theorem FrameR.callStart_view {NR : NumV → NumV → Prop} {R : Ren}
    (mode : CallStart) {this : Val} {args : List Elem} {env : Env} {f : Frame}
    (h : FrameR NR R (mode.frame this args env) f) :
    ∃ this', f = mode.frame this' args (R.env env) ∧
      ValueR NR R (mode.receiver this) (mode.receiver this') := by
  cases mode with
  | callee opt =>
    obtain ⟨cf',rfl,hh⟩ := h.c_view
    have ht := hh.tag_eq
    cases cf' <;> simp only [Encode.callF,treeTag] at ht
    all_goals try contradiction
    case callee args' env' opt' =>
      cases hh with | node tag hs =>
        cases hs with | cons ha hs =>
          cases hs with | cons he hs =>
            cases hs with | cons ho hs =>
              cases ha
              cases ho
              obtain rfl := env_eq_map he
              exact ⟨.undef,rfl,.undef⟩
  | method opt =>
    obtain ⟨cf',rfl,hh⟩ := h.c_view
    have ht := hh.tag_eq
    cases cf' <;> simp only [Encode.callF,treeTag] at ht
    all_goals try contradiction
    case method this' args' env' opt' =>
      cases hh with | node tag hs =>
        cases hs with | cons hthis hs =>
          cases hs with | cons ha hs =>
            cases hs with | cons he hs =>
              cases hs with | cons ho hs =>
                cases ha
                cases ho
                obtain rfl := env_eq_map he
                cases hthis with | value hv => exact ⟨this',rfl,hv⟩
  | construct =>
    obtain ⟨cf',rfl,hh⟩ := h.c_view
    have ht := hh.tag_eq
    cases cf' <;> simp only [Encode.callF,treeTag] at ht
    all_goals try contradiction
    case newCallee args' env' =>
      cases hh with | node tag hs =>
        cases hs with | cons ha hs =>
          cases hs with | cons he hs =>
            cases ha
            obtain rfl := env_eq_map he
            exact ⟨.undef,rfl,.undef⟩

theorem CallStart.frame_live (mode : CallStart) {live : Nat → Prop}
    {this : Val} {args : List Elem} {env : Env}
    (h : treeSupport live (Encode.frame (mode.frame this args env))) :
    valueSupport live (mode.receiver this) ∧ treeSupport live (Encode.env env) := by
  cases mode with
  | callee opt => exact ⟨True.intro,h.1.2.1⟩
  | method opt => exact ⟨h.1.1,h.1.2.2.1⟩
  | construct => exact ⟨True.intro,h.1.2.1⟩

theorem step_callStart_eq (F : Ffi) (s : St F.S) (mode : CallStart) (a : Nat)
    (this : Val) (args : List Elem) (env : Env) (fs : List Frame)
    (hc : s.ctl = .ret (.obj a)) (hf : s.stack = mode.frame this args env::fs) :
    step F s = M.pure (argumentState {s with stack := fs} mode.kind (.obj a) (mode.receiver this) [] args env) := by
  cases mode <;> simp only [step,hc,stepRet,hf,CallStart.frame,CallStart.kind,CallStart.receiver,
    retStep,retC,isNullish,Bool.and_false,Bool.cond_false]
  all_goals exact argsNext_ordinary_eq F _ _ _ _ [] args env (by decide)

/-- An evaluated object callee proceeds through the actual argument collector.
Optional-call guards, the receiver, and the target frame are derived. -/
theorem step_callStart_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (mode : CallStart) (a : Nat) (this₀ : Val) (args : List Elem) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a)) (hf₀ : s₀.stack = mode.frame this₀ args env::fs₀) :
    ∃ result, interpC (step F s₀).run C₀ =
        some (argumentState {s₀ with stack := fs₀} mode.kind (.obj a) (mode.receiver this₀) [] args env,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        (argumentState {s₀ with stack := fs₀} mode.kind (.obj a) (mode.receiver this₀) [] args env) result := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨fr,fs,hf,hfr,htail⟩ := h.stack_view hf₀
  obtain ⟨this,hframe,hthis⟩ := hfr.callStart_view mode
  rw [hframe] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  obtain ⟨htl,hel⟩ := mode.frame_live hl.1
  have ha := (h.return_values (.obj a) (.obj (R.a a)) hc₀ hc).2
  refine ⟨argumentState {s with stack := fs} mode.kind (.obj (R.a a)) (mode.receiver this) [] args (R.env env),?_,?_,
    argumentState_roles (h.restack htail hl.2) mode.kind (.obj a) (.obj (R.a a))
      (mode.receiver this₀) (mode.receiver this) [] [] args env (.obj a) hthis .nil ha htl True.intro hel⟩
  · rw [step_callStart_eq F s₀ mode a this₀ args env fs₀ hc₀ hf₀]; rfl
  · rw [step_callStart_eq F s mode (R.a a) this args (R.env env) fs hc hf]; rfl

end Host.Ts.Owned.Parametric

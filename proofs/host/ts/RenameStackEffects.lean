import host.ts.RenameReadStack
import host.ts.RenameRoutePrivateFields
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- A one-step stack effect remains valid below any additional fixed prefix. -/
theorem stack_drop_extend {α : Type} {xs ys : List α} {p q : Nat}
    (h : xs.drop p = ys.drop q) (n : Nat) : xs.drop (p+n) = ys.drop (q+n) := by
  simpa only [List.drop_drop,Nat.add_comm] using congrArg (List.drop n) h

theorem step_this_stack_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C₀ C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (env : Env) (a : Nat) (v₀ : Val)
    (hc₀ : s₀.ctl = .ev .this env) (he : lookupEnv nThis env = some a)
    (hv : s₀.heap.get a = some (.cell (some v₀)))
    (run : interpC (step F s).run C = some (result,D)) : result.stack = s.stack := by
  obtain ⟨_,_,hr,_,_⟩ := step_this_from_source F NR FR R C₀ C live framed before after old old' s₀ s h env a v₀ hc₀ he hv
  have hh := congrArg St.stack (congrArg Prod.fst (Option.some.inj (run.symm.trans hr)))
  exact hh

theorem step_variable_stack_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C₀ C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (env : Env) (a : Nat) (v₀ : Val)
    (hc₀ : s₀.ctl = .ev (.id name) env) (he : lookupEnv name env = some a)
    (hv : s₀.heap.get a = some (.cell (some v₀)))
    (run : interpC (step F s).run C = some (result,D)) : result.stack = s.stack := by
  have hc := (h.control_view hc₀).ev_view
  have hl := h.controlLive
  rw [hc₀] at hl
  obtain ⟨_,_,hr,_,_⟩ := step_variable_roles F NR FR R C₀ C live framed before after old old' s₀ s h
    name env a v₀ hc₀ hc he (env_lookup_live name env a hl.2.1 he) hv
  have heq := congrArg Prod.fst (Option.some.inj (run.symm.trans hr))
  have hh := congrArg St.stack heq
  exact hh

theorem step_method_descent_stack (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C₀ C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (obj : Expr) (name : Name) (args : List Elem) (env : Env) (oo oc : Bool)
    (hc₀ : s₀.ctl = .ev (.call (.member obj name oo) args oc) env)
    (run : interpC (step F s).run C = some (result,D)) : result.stack.tail = s.stack := by
  obtain ⟨_,hr,_⟩ := step_method_descent_from_source F NR FR R C₀ C live framed before after old old' s₀ s h obj name args env oo oc hc₀
  have hh := congrArg (fun t => t.stack.tail) (congrArg Prod.fst (Option.some.inj (run.symm.trans hr)))
  exact hh

theorem step_private_descent_stack (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C₀ C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (obj : Expr) (name : Name) (opt : Bool) (env : Env) (brand : Nat)
    (hc₀ : s₀.ctl = .ev (.priv obj name opt) env) (hb₀ : lookupEnv (privName name) env = some brand)
    (run : interpC (step F s).run C = some (result,D)) : result.stack.tail = s.stack := by
  obtain ⟨_,hr,_⟩ := step_private_descent_from_source F NR FR R C₀ C live framed before after old old' s₀ s h
    obj name opt env brand hc₀ hb₀
  have hh := congrArg (fun t => t.stack.tail) (congrArg Prod.fst (Option.some.inj (run.symm.trans hr)))
  exact hh

theorem step_identifier_call_stack (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C₀ C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (args : List Elem) (opt : Bool) (env : Env)
    (hc₀ : s₀.ctl = .ev (.call (.id name) args opt) env)
    (run : interpC (step F s).run C = some (result,D)) : result.stack.tail = s.stack := by
  obtain ⟨_,hr,_⟩ := step_identifier_call_descent_from_source F NR FR R C₀ C live framed before after old old' s₀ s h
    name args opt env hc₀
  have hh := congrArg (fun t => t.stack.tail) (congrArg Prod.fst (Option.some.inj (run.symm.trans hr)))
  exact hh

theorem step_return_exit_stack (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (exit : ReturnExit) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = exit.frame env::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.stack = s.stack.tail := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.returnExit_view] at hf
  rw [step_return_exit_eq F s v (R.env env) exit fs hc hf] at run
  rw [hf]
  exact (congrArg St.stack (congrArg Prod.fst (Option.some.inj run))).symm

theorem step_return_unwind_stack (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (unwind : ReturnUnwind) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .abr (.ret v₀)) (hf₀ : s₀.stack = unwind.frame env::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.stack = s.stack.tail := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).returnAbrupt_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.returnUnwind_view] at hf
  rw [step_return_unwind_eq F s v (R.env env) unwind fs hc hf] at run
  rw [hf]
  exact (congrArg St.stack (congrArg Prod.fst (Option.some.inj run))).symm

theorem step_block_next_stack (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (st : Stmt) (rest : List Stmt) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .s (.block (st::rest) env)::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.stack.tail = s.stack.tail := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.block_view] at hf
  rw [step_block_next_eq F s v st rest (R.env env) fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  rw [hf]
  exact (congrArg (fun t => t.stack.tail) he).symm

theorem step_method_data_stack (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o₀ : Obj) (name : Name) (args : List Elem) (env : Env) (oo oc : Bool)
    (v₀ : Val) (w e : Bool) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a))
    (hf₀ : s₀.stack = .c (.member (.str name) args env oo oc)::fs₀)
    (ho₀ : s₀.heap.get a = some (.obj o₀)) (hk₀ : o₀.kind = .ordinary)
    (hp₀ : findProp (.str name) o₀.props = some (.data v₀ w e))
    (run : interpC (step F s).run C = some (result,D)) : result.stack.tail = s.stack.tail := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.callMember_view] at hf
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨o,ho,hor,_⟩ := h.heap.readOrdinary a o₀ ha ho₀ hk₀
  obtain ⟨v,hp,_⟩ := hor.properties.find_data name v₀ w e hp₀
  rw [step_method_data_eq F s (R.a a) o name args (R.env env) oo oc v w e fs hc hf ho
    (hor.ordinary hk₀) hp] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  rw [hf]
  exact (congrArg (fun t => t.stack.tail) he).symm

theorem step_statement_stack (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : StatementAction) (env : Env) (hc₀ : s₀.ctl = .ex a.statement env)
    (run : interpC (step F s).run C = some (result,D)) : result.stack = a.frames (R.env env) ++ s.stack := by
  have hc := (h.control_view hc₀).ex_view
  rw [step_statement_eq F s a (R.env env) hc] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  exact (congrArg St.stack he).symm

theorem step_if_stack (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (b : Bool) (yes : Stmt) (no : Option Stmt) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.bool b)) (hf₀ : s₀.stack = .s (.if_ yes no env)::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.stack = s.stack.tail := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.if_view] at hf
  rw [step_if_bool_eq F s b yes no (R.env env) fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  dsimp only at he
  rw [← he,hf]
  cases b <;> cases no <;> rfl

theorem step_callStart_expression_stack (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (mode : CallStart) (a : Nat) (this : Val) (args : List Elem) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a)) (hf₀ : s₀.stack = mode.frame this args env::fs₀)
    (expression : Expr) (rest : List Elem) (args_shape : args = .expr expression::rest)
    (run : interpC (step F s).run C = some (result,D)) : result.stack.tail = s.stack.tail := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨t,hft,_⟩ := hfr.callStart_view mode
  rw [hft] at hf
  rw [step_callStart_eq F s mode (R.a a) t args (R.env env) fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  dsimp only at he
  rw [← he,hf,args_shape]
  rfl

theorem step_argument_done_stack (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (kind : Nat) (fn₀ this₀ : Val) (acc₀ : List Val) (rest : List Elem) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .c (.args kind fn₀ this₀ acc₀ rest env)::fs₀)
    (hk : kind ≤ 1) (rest_shape : rest = []) (run : interpC (step F s).run C = some (result,D)) : result.stack = s.stack.tail := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨fn,this,acc,hframe,_,_,_⟩ := hfr.args_view
  rw [hframe] at hf
  rw [step_argument_eq F s v kind fn this acc rest (R.env env) fs hc hf hk] at run
  have hr := congrArg Prod.fst (Option.some.inj run)
  dsimp only [M.pure,interpC_pure] at hr
  rw [← hr,hf,rest_shape]
  cases kind <;> rfl

theorem step_private_read_stack (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a brand : Nat) (name : Name) (o₀ : Obj) (p₀ : PropV) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a)) (hf₀ : s₀.stack = .e (.priv brand name false)::fs₀)
    (ho₀ : s₀.heap.get a = some (.obj o₀)) (hk₀ : o₀.kind = .ordinary)
    (hp₀ : findPriv brand name o₀.priv = some p₀)
    (run : interpC (step F s).run C = some (result,D)) : result.stack = s.stack.tail := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.private_view] at hf
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  have hb : live brand := by
    have hl := h.stackLive
    change listSupport (fun f => treeSupport live (Encode.frame f)) s₀.stack at hl
    rw [hf₀] at hl
    exact hl.1.1.1
  obtain ⟨p,hr₀,hr,hs,hp⟩ := step_private_read_roles F NR FR R C₀ C live framed before after old old'
    s₀ s h a brand name o₀ p₀ fs₀ fs hc₀ hc hf₀ hf ha hb ho₀ hk₀ hp₀
  have he := congrArg Prod.fst (Option.some.inj (run.symm.trans hr))
  have stack := congrArg St.stack he
  rw [readProp_stack] at stack
  rw [hf]
  exact stack

end Host.Ts.Owned.Parametric

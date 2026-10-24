import host.sim.steps.Props
namespace Host.Ts.Sim

/-! # Expression evaluation: the first step of `.ev e env`

Most expressions push a frame and evaluate a subexpression. Steps that
allocate an object with an intrinsic prototype (closures, arrays, object
literals, thrown errors) need the map to fix that intrinsic address
(`h.intr`). Reads of global variables go through the global object's
prototype chain (`getChain_sim`, which takes `FfiSim` for typed-array reads);
the variable's name must be a plain key (`VarOK`). -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

/-! ## Helpers -/

theorem lookupEnv_supp {A : Nat → Prop} {n : Nat} {x : Name} {env : Env} {b : Nat}
    (he : Supp.env A n env) (hl : lookupEnv x env = some b) : A b := by
  induction env with
  | nil => cases hl
  | cons p env ih =>
    obtain ⟨m, a⟩ := p
    change brec (Nat.beq (pack x) (pack m)) (some a) (lookupEnv x env) = some b at hl
    cases hb : Nat.beq (pack x) (pack m)
    · rw [hb] at hl
      exact ih (fun y hy => he y (List.mem_cons_of_mem _ hy)) hl
    · rw [hb] at hl
      rw [← Option.some.inj hl]
      exact he (m, a) (List.mem_cons_self ..)

theorem lookupEnv_map_some {M : Map} {x : Name} {env : Env} {b : Nat} (hl : lookupEnv x env = some b) :
    lookupEnv x (M.env env) = some (M.a b) := by
  rw [lookupEnv_map, hl]; rfl

theorem lookupEnv_map_none {M : Map} {x : Name} {env : Env} (hl : lookupEnv x env = none) :
    lookupEnv x (M.env env) = none := by
  rw [lookupEnv_map, hl]; rfl

theorem Map.vals_reverse (M : Map) (vs : List Val) : (M.vals vs).reverse = M.vals vs.reverse := by
  simp [Map.vals]

theorem step_ev_eq {e : Expr} {env : Env} (hc : s.ctl = .ev e env) : step F s = evStep F s e env := by
  unfold step; rw [hc]

theorem RelB.step_ev (h : RelB F FR W stk M ν K s S t C) {e : Expr} {env : Env} (hc : s.ctl = .ev e env) :
    step F t = evStep F t e (M.env env) := by
  unfold step; rw [h.ctl, hc]; rfl

theorem RelB.ev_supp (h : RelB F FR W stk M ν K s S t C) {e : Expr} {env : Env} (hc : s.ctl = .ev e env) :
    Supp.env (Present s) S.tab.length env := by
  have hs := h.ctlSupp
  rw [hc] at hs
  exact hs

theorem RelB.s64 (_h : RelB F FR W stk M ν K s S t C) (hn : s.next < Sim.bound) : s.next < 2 ^ 64 := by
  have hb : Sim.bound = 2 ^ 61 := rfl
  rw [hb] at hn
  omega

/-- A cell read: the target cell holds the image. -/
theorem RelB.cellVal_map (h : RelB F FR W stk M ν K s S t C) {n : Name} {env : Env} {v : Val}
    (hv : Host.Ts.cellVal? F s n env = some v) (hcn : CellNoW K W env n) : Host.Ts.cellVal? F t n (M.env env) = some (M.val v) := by
  unfold Host.Ts.cellVal? at hv ⊢
  cases hl : lookupEnv n env with
  | none => rw [hl] at hv; cases hv
  | some c =>
    rw [hl] at hv
    change (s.cell? c).bind id = some v at hv
    rw [lookupEnv_map_some hl]
    cases hc : s.cell? c with
    | none => rw [hc] at hv; cases hv
    | some x =>
      rw [hc] at hv
      cases x with
      | none => cases hv
      | some w =>
        cases hv
        show (t.cell? (M.a c)).bind id = some (M.val _)
        rw [h.cell? hc (.of_or (hcn c hl))]
        rfl

theorem RelB.cellVal_supp (h : RelB F FR W stk M ν K s S t C) {n : Name} {env : Env} {v : Val}
    (hv : Host.Ts.cellVal? F s n env = some v) : Supp.val (Present s) S.tab.length v := by
  unfold Host.Ts.cellVal? at hv
  cases hl : lookupEnv n env with
  | none => rw [hl] at hv; cases hv
  | some c =>
    rw [hl] at hv
    change (s.cell? c).bind id = some v at hv
    cases hc : s.cell? c with
    | none => rw [hc] at hv; cases hv
    | some x =>
      rw [hc] at hv
      cases x with
      | none => cases hv
      | some w =>
        cases hv
        exact h.cell?_supp hc

/-- An object that is not an array, of a kind no frame admits, is never framed: its target image
is the mapped object. -/
theorem RelB.obj?_plain (h : RelB F FR W stk M ν K s S t C) {a : Nat} {o : Obj}
    (ho : s.obj? a = some o) (hk : ∀ es, o.kind ≠ .array es) (hw : ¬ Wideable o.kind) :
    t.obj? (M.a a) = some (M.obj o) :=
  h.obj? ho (h.fr_none ho hk hw)

/-- A step to related states. -/
theorem evSim_rel {s' t' : St F.S} (h : RelB F FR W stk M ν K s' S t' C) :
    MSim (StepPostB F FR W stk M ν K S C) S C (Host.Ts.M.pure s') (Host.Ts.M.pure t') :=
  MSim.pure ⟨Grow.refl h.srv, h⟩

/-- Push a frame and evaluate. -/
theorem evSim_push_go (h : RelB F FR W stk M ν K s S t C) (f : Frame) (c : Ctl)
    (hf : Supp.frame (Present s) S.tab.length f) (hc : Supp.ctl (Present s) S.tab.length c) :
    MSim (StepPostB F FR W stk M ν K S C) S C (Host.Ts.M.pure ((s.push f).go c))
      (Host.Ts.M.pure ((t.push (M.frame f)).go (M.ctl c))) :=
  evSim_rel ((h.push f hf).go c hc)

theorem evSim_ret (h : RelB F FR W stk M ν K s S t C) (v : Val) (hv : Supp.val (Present s) S.tab.length v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (retS F s v) (retS F t (M.val v)) :=
  evSim_rel (h.ret v hv)

/-- Allocate an object and return it. -/
theorem evSim_allocObj_retV (h : RelB F FR W stk M ν K s S t C) (k : Kind) (pr : Val) (ps : Props)
    (hn : s.next < Sim.bound) (hk : Supp.kind (Present s) S.tab.length k)
    (hpr : Supp.val (Present s) S.tab.length pr) (hps : Supp.props (Present s) S.tab.length ps) :
    MSim (StepPostB F FR W stk M ν K S C) S C
      (retS F (s.allocObj k pr ps).2 (.obj (s.allocObj k pr ps).1))
      (retS F (t.allocObj (M.kind k) (M.val pr) (M.props ps)).2
        (.obj (t.allocObj (M.kind k) (M.val pr) (M.props ps)).1)) := by
  have h64 := h.s64 hn
  have hP : ∀ a, Present s a → Present (s.allocObj k pr ps).2 a :=
    fun _ ha => Present.alloc _ h64 ha
  obtain ⟨ha, hr⟩ := h.allocObj k pr ps hn (Supp.kind_mono hP (Nat.le_refl _) hk)
    (Supp.val_mono hP (Nat.le_refl _) hpr) (Supp.props_mono hP (Nat.le_refl _) hps)
  have := evSim_ret hr (.obj (s.allocObj k pr ps).1) (Present.alloc_next s _ h64)
  rw [show M.val (.obj (s.allocObj k pr ps).1) = .obj (M.a (s.allocObj k pr ps).1) from rfl, ← ha] at this
  exact this

/-- Allocate an object with an intrinsic prototype and return it. -/
theorem evSim_allocObj_ret (h : RelB F FR W stk M ν K s S t C) (k : Kind) (p : Nat) (ps : Props)
    (hn : s.next < Sim.bound) (hpa : M.a p = p) (hp : Present s p)
    (hk : Supp.kind (Present s) S.tab.length k) (hps : Supp.props (Present s) S.tab.length ps) :
    MSim (StepPostB F FR W stk M ν K S C) S C
      (retS F (s.allocObj k (.obj p) ps).2 (.obj (s.allocObj k (.obj p) ps).1))
      (retS F (t.allocObj (M.kind k) (.obj p) (M.props ps)).2
        (.obj (t.allocObj (M.kind k) (.obj p) (M.props ps)).1)) := by
  have := evSim_allocObj_retV h k (.obj p) ps hn hk hp hps
  rwa [show M.val (.obj p) = .obj p from by show Val.obj (M.a p) = .obj p; rw [hpa]] at this

theorem margin_lt (hn : s.next + margin < Sim.bound) : s.next < Sim.bound := by
  have : 0 < margin := by decide
  omega

/-! ## Variables -/

/-- A local variable read (initialized or not). -/
theorem readVar_local_sim (h : RelB F FR W stk M ν K s S t C) {n : Name} {env : Env} {c : Nat}
    (hl : lookupEnv n env = some c) (hn : s.next < Sim.bound)
    (hp : Present s aReferenceErrorProto) (hcn : W c = none ∨ K.fr c = none) :
    MSim (StepPostB F FR W stk M ν K S C) S C (readVar F s n env) (readVar F t n (M.env env)) := by
  have hl' := lookupEnv_map_some (M := M) hl
  cases hv : s.cell? c with
  | none =>
    simp only [readVar, hl, hv]
    exact MSim.fail _ _
  | some x =>
    have hv' := h.cell? hv (.of_or hcn)
    cases x with
    | none =>
      simp only [readVar, hl, hv, hl', hv', Option.map_none]
      exact refErr_sim h h.intr hn hp _
    | some v =>
      simp only [readVar, hl, hv, hl', hv', Option.map_some]
      exact evSim_ret h v (h.cell?_supp hv)

/-- The source-side condition of a variable read: a local binding whose cell carries no frame of
`W` (or is unframed), or a global-object property with a plain name (not an array index, not
`length`) along a chain where no frame of `W` matters. -/
def VarOK {S' : Type} (K : Ctx) (W : Nat → Option WFrame) (s : St S') (env : Env) (n : Name) : Prop :=
  match lookupEnv n env with
  | some c => W c = none ∨ K.fr c = none
  | none => Present s aGlobal ∧ keyIndex (.str n) = none ∧ keyEq (.str n) kLength = false ∧
      ChainNoW K W s 16 aGlobal

/-- `VarOK` that allocations and writes keep: a global read needs no frames of `W` at all. -/
def ShortOK {S' : Type} (K : Ctx) (W : Nat → Option WFrame) (s : St S') (env : Env) (n : Name) : Prop :=
  match lookupEnv n env with
  | some c => W c = none ∨ K.fr c = none
  | none => Present s aGlobal ∧ keyIndex (.str n) = none ∧ keyEq (.str n) kLength = false ∧ ∀ a, W a = none

theorem ShortOK.varOK {S' : Type} {K : Ctx} {W : Nat → Option WFrame} {s : St S'} {env : Env} {n : Name}
    (hv : ShortOK K W s env n) : VarOK K W s env n := by
  unfold ShortOK at hv
  unfold VarOK
  cases he : lookupEnv n env with
  | none => rw [he] at hv; exact ⟨hv.1, hv.2.1, hv.2.2.1, ChainNoW.of_none hv.2.2.2 16 aGlobal⟩
  | some _ => rw [he] at hv; exact hv

theorem ShortOK.mono {S' : Type} {K : Ctx} {W : Nat → Option WFrame} {s s' : St S'} {env : Env} {n : Name}
    (hP : ∀ a, Present s a → Present s' a) (hv : ShortOK K W s env n) : ShortOK K W s' env n := by
  unfold ShortOK at hv ⊢
  cases he : lookupEnv n env with
  | none => rw [he] at hv; exact ⟨hP _ hv.1, hv.2⟩
  | some _ => rw [he] at hv; exact hv

/-- A read of the global object's chain (the map fixes the global object). -/
theorem getChain_global_sim (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    {k : PKey} (hk : Supp.key (Present s) S.tab.length k) (hc : ChainOK F K W s S k 16 aGlobal) :
    MSim (ReadPost M S C (PropR M (Present s) S.tab.length)) S C
      (getChain F s k 16 aGlobal) (getChain F t (M.key k) 16 aGlobal) := by
  have := getChain_sim h hF hk 16 aGlobal hc
  rwa [h.intr aGlobal (by decide)] at this

theorem RelB.val_global (h : RelB F FR W stk M ν K s S t C) : M.val (.obj aGlobal) = .obj aGlobal := by
  show Val.obj (M.a aGlobal) = _
  rw [h.intr aGlobal (by decide)]

/-- Every variable read: local cells, and globals (a getter is called, an absent name throws). -/
theorem readVar_sim (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    {n : Name} {env : Env} (hok : VarOK K W s env n) (hn : s.next < Sim.bound)
    (hp : Present s aReferenceErrorProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (readVar F s n env) (readVar F t n (M.env env)) := by
  cases hl : lookupEnv n env with
  | some c =>
    simp only [VarOK, hl] at hok
    exact readVar_local_sim h hl hn hp hok
  | none =>
    simp only [VarOK, hl] at hok
    simp only [readVar, hl, lookupEnv_map_none hl]
    refine MSim.bind (getChain_global_sim h hF (k := .str n) trivial
      (ChainOK.of_noW hok.2.1 hok.2.2.1 16 aGlobal hok.2.2.2)) ?_
    rintro M' S' C' r r' ⟨-, hS, hC, hr, hsupp⟩
    rw [hS, hC, hr]
    cases r with
    | none =>
      cases hi : nameEq n (chars!"setImmediate")
      · simp only [Bool.cond_false]
        exact refErr_sim h h.intr hn hp _
      · simp only [Bool.cond_true]
        exact evSim_allocObj_retV h _ .null [] hn (fun _ hx => nomatch hx) trivial (fun _ hx => nomatch hx)
    | some p =>
      have hg := h.read (recv := .obj aGlobal) (p := some p) hok.1 hsupp
      rw [h.val_global] at hg
      exact evSim_rel hg

/-! ## Frame-pushing expressions -/

section push
variable (h : RelB F FR W stk M ν K s S t C)
include h

theorem step_member {o : Expr} {p : Name} {opt : Bool} {env : Env}
    (hc : s.ctl = .ev (.member o p opt) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact evSim_push_go h (.e (.member (.str p) opt)) (.ev o env) trivial (h.ev_supp hc)

theorem step_bin {op : BinOp} {a b : Expr} {env : Env} (hc : s.ctl = .ev (.bin op a b) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact evSim_push_go h (.e (.binL op b env)) (.ev a env) (h.ev_supp hc) (h.ev_supp hc)

theorem step_log {op : LogOp} {a b : Expr} {env : Env} (hc : s.ctl = .ev (.log op a b) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact evSim_push_go h (.e (.logL op b env)) (.ev a env) (h.ev_supp hc) (h.ev_supp hc)

theorem step_cond {c a b : Expr} {env : Env} (hc : s.ctl = .ev (.cond c a b) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact evSim_push_go h (.e (.cond a b env)) (.ev c env) (h.ev_supp hc) (h.ev_supp hc)

theorem step_seq {a b : Expr} {env : Env} (hc : s.ctl = .ev (.seq a b) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact evSim_push_go h (.e (.seq b env)) (.ev a env) (h.ev_supp hc) (h.ev_supp hc)

theorem step_index {o k : Expr} {opt : Bool} {env : Env} (hc : s.ctl = .ev (.index o k opt) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact evSim_push_go h (.e (.indexL k env opt)) (.ev o env) (h.ev_supp hc) (h.ev_supp hc)

theorem step_new {callee : Expr} {args : List Elem} {env : Env}
    (hc : s.ctl = .ev (.new callee args) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact evSim_push_go h (.c (.newCallee args env)) (.ev callee env) (h.ev_supp hc) (h.ev_supp hc)

theorem step_chain {e : Expr} {env : Env} (hc : s.ctl = .ev (.chain e) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact evSim_push_go h (.e .chain) (.ev e env) trivial (h.ev_supp hc)

theorem step_await {e : Expr} {env : Env} (hc : s.ctl = .ev (.await e) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact evSim_push_go h (.k .await) (.ev e env) trivial (h.ev_supp hc)

theorem step_yield {arg : Option Expr} {d : Bool} {env : Env} (hc : s.ctl = .ev (.yield arg d) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  cases arg with
  | some a => exact evSim_push_go h (.k (.yield d)) (.ev a env) trivial (h.ev_supp hc)
  | none => exact evSim_rel ((h.push (.k (.yield d)) trivial).ret .undef trivial)

theorem step_priv {o : Expr} {n : Name} {opt : Bool} {env : Env}
    (hc : s.ctl = .ev (.priv o n opt) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  have he := h.ev_supp hc
  cases hl : lookupEnv (privName n) env with
  | none =>
    simp only [evStep, hl]
    exact MSim.fail _ _
  | some b =>
    simp only [evStep, hl, lookupEnv_map_some hl]
    exact evSim_push_go h (.e (.priv b n opt)) (.ev o env) (lookupEnv_supp he hl) he

theorem step_super {env : Env} (hc : s.ctl = .ev .super env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact MSim.fail _ _

/-- A class with a heritage clause evaluates the heritage first (`defineClass` is not covered). -/
theorem step_cls_extends {name : Option Name} {sup : Expr} {ms : List Member} {env : Env}
    (hc : s.ctl = .ev (.cls (.mk name (some sup) ms)) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact evSim_push_go h (.k (.classHeritage (.mk name (some sup) ms) env)) (.ev sup env) (h.ev_supp hc)
    (h.ev_supp hc)

theorem step_tagged {tag : Expr} {quasis : List (List Char)} {subs : List Expr} {env : Env}
    (hc : s.ctl = .ev (.template (some tag) quasis subs) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact evSim_push_go h (.l (.tagged .undef quasis [] subs env)) (.ev tag env)
    ⟨trivial, fun _ hx => (nomatch hx), h.ev_supp hc⟩ (h.ev_supp hc)

theorem tmplNext_sim {acc : List Char} {quasis : List (List Char)} {subs : List Expr} {env : Env}
    (he : Supp.env (Present s) S.tab.length env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (tmplNext F s acc quasis subs env)
      (tmplNext F t acc quasis subs (M.env env)) := by
  cases subs with
  | nil => exact evSim_ret h (.str acc) trivial
  | cons e es => exact evSim_push_go h (.l (.tmpl acc quasis es env)) (.ev e env) he he

theorem step_template {quasis : List (List Char)} {subs : List Expr} {env : Env}
    (hc : s.ctl = .ev (.template none quasis subs) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  cases quasis with
  | nil => exact MSim.fail _ _
  | cons q qs =>
    cases hq : cook q with
    | none =>
      simp only [evStep, hq]
      exact MSim.fail _ _
    | some c =>
      simp only [evStep, hq]
      exact tmplNext_sim h (h.ev_supp hc)

end push

/-! ## Closures -/

theorem step_arrow (h : RelB F FR W stk M ν K s S t C) {f : Func} {env : Env}
    (hc : s.ctl = .ev (.arrow f) env) (hn : s.next + margin < Sim.bound)
    (hp : Present s aFunctionProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact evSim_allocObj_ret h (.fn (.closure f env true .undef)) aFunctionProto [] (margin_lt hn)
    (h.intr _ (by decide)) hp ⟨h.ev_supp hc, trivial⟩ (fun _ hx => nomatch hx)

theorem step_func (h : RelB F FR W stk M ν K s S t C) {f : Func} {env : Env}
    (hc : s.ctl = .ev (.func f) env) (hn : s.next + margin < Sim.bound)
    (hp : Present s aFunctionProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact evSim_allocObj_ret h (.fn (.closure f env false .undef)) aFunctionProto [] (margin_lt hn)
    (h.intr _ (by decide)) hp ⟨h.ev_supp hc, trivial⟩ (fun _ hx => nomatch hx)

/-! ## Literals -/

theorem Mbind_pure {α β : Type} (a : α) (f : α → Host.Ts.M β) :
    Host.Ts.M.bind (Host.Ts.M.pure a) f = f a := rfl

/-- `new RegExp(p, fl)` (the host builtin) with the prototype `pr`. -/
theorem regexNew_sim (h : RelB F FR W stk M ν K s S t C) (hn : s.next < Sim.bound) {p fl : List Char} {pr : Nat}
    (hpr : Present s pr) :
    MSim (StepPostB F FR W stk M ν K S C) S C (hostN F s .undef [.str p, .str fl] [.obj pr] .regexNew)
      (hostN F t .undef [.str p, .str fl] [.obj (M.a pr)] .regexNew) := by
  simp only [hostN, arg, nthD, primStr, Mbind_pure]
  cases hre : reParse p with
  | none => exact MSim.fail _ _
  | some _ =>
    exact evSim_allocObj_retV h .ordinary (.obj pr) _ hn trivial hpr (fun x hx => by
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hx
      rcases hx with rfl | rfl | rfl | rfl | rfl | rfl <;> exact ⟨trivial, trivial⟩)

/-- Every literal: a regular expression allocates a `RegExp` with the global constructor's
prototype; bigints need `BigFixed`. -/
theorem evLit_sim (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    {l : Lit} (hn : s.next < Sim.bound)
    (hb : ∀ raw n, l = .big raw → F64.parseIntLit raw = some n → BigFixed K.lo K.hi n)
    (hre : ∀ p fl, l = .regex p fl → ∀ a, W a = none) :
    MSim (StepPostB F FR W stk M ν K S C) S C (evLit F s l) (evLit F t l) := by
  cases l with
  | num raw =>
    cases hx : F64.ofLit raw with
    | none => simp only [evLit, hx]; exact MSim.fail _ _
    | some x => simp only [evLit, hx]; exact evSim_ret h (.num (.lit x)) trivial
  | big raw =>
    cases hx : F64.parseIntLit raw with
    | none => simp only [evLit, hx]; exact MSim.fail _ _
    | some n =>
      simp only [evLit, hx]
      have := evSim_ret h (.big n) trivial
      rw [show M.val (.big n) = .big n from by
        show Val.big (M.big n) = _; rw [h.bigFixed _ (hb raw n rfl hx)]] at this
      exact this
  | str raw =>
    cases hx : cook raw with
    | none => simp only [evLit, hx]; exact MSim.fail _ _
    | some cs => simp only [evLit, hx]; exact evSim_ret h (.str cs) trivial
  | bool b => exact evSim_ret h (.bool b) trivial
  | null => exact evSim_ret h .null trivial
  | regex p fl =>
    simp only [evLit]
    refine MSim.bind (getChain_global_sim h hF (k := .str chars!"RegExp") trivial
      (ChainOK.of_plain rfl rfl (hre _ _ rfl) 16 aGlobal)) ?_
    rintro M' S' C' r r' ⟨-, hS, hC, hr, hsupp⟩
    rw [hS, hC, hr]
    rcases r with _ | ⟨v, w, e⟩ | ⟨g, st, e⟩
    · exact MSim.fail _ _
    · cases v
      case obj c =>
        simp only [Option.map_some, Map.prop, Map.val]
        refine MSim.bind (dataOf_sim h hF h.intr (recv := .obj c) (k := kPrototype) hsupp trivial
          (LookupOK.of_plain rfl rfl (hre _ _ rfl) _)) ?_
        rintro M2 S2 C2 r2 r2' ⟨-, hS2, hC2, hr2, hsupp2⟩
        rw [hS2, hC2, hr2]
        rcases r2 with _ | v2
        · exact MSim.fail _ _
        · cases v2
          case obj pr =>
            exact regexNew_sim h hn (hsupp2 _ rfl)
          all_goals exact MSim.fail _ _
      all_goals exact MSim.fail _ _
    · exact MSim.fail _ _

theorem step_lit (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    {l : Lit} {env : Env} (hc : s.ctl = .ev (.lit l) env) (hn : s.next + margin < Sim.bound)
    (hb : ∀ raw n, l = .big raw → F64.parseIntLit raw = some n → BigFixed K.lo K.hi n)
    (hre : ∀ p fl, l = .regex p fl → ∀ a, W a = none) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact evLit_sim h hF (margin_lt hn) hb hre

/-! ## Variables and `this` -/

/-- A variable read: a local value or `ReferenceError` before initialization, or a global
(its value, a getter call, or `ReferenceError` when absent). -/
theorem step_id (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    {n : Name} {env : Env} (hc : s.ctl = .ev (.id n) env) (hn : s.next + margin < Sim.bound)
    (hp : Present s aReferenceErrorProto) (hok : VarOK K W s env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact readVar_sim h hF hok (margin_lt hn) hp

theorem step_this (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    {env : Env} (hc : s.ctl = .ev .this env) (hn : s.next + margin < Sim.bound)
    (hp : Present s aReferenceErrorProto) (hok : VarOK K W s env nThis) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact readVar_sim h hF hok (margin_lt hn) hp

/-! ## Array literals -/

theorem arrayNext_sim (h : RelB F FR W stk M ν K s S t C) {env : Env} (hn : s.next < Sim.bound)
    (hp : Present s aArrayProto)
    (he : Supp.env (Present s) S.tab.length env) :
    ∀ (rest : List Elem) (acc : List Val), Supp.vals (Present s) S.tab.length acc →
      MSim (StepPostB F FR W stk M ν K S C) S C (arrayNext F s acc rest env)
        (arrayNext F t (M.vals acc) rest (M.env env)) := by
  intro rest
  induction rest with
  | nil =>
    intro acc hacc
    show MSim _ S C (retS F (newArray s acc.reverse).2 (.obj (newArray s acc.reverse).1))
      (retS F (newArray t (M.vals acc).reverse).2 (.obj (newArray t (M.vals acc).reverse).1))
    rw [Map.vals_reverse]
    exact evSim_allocObj_ret h (.array acc.reverse) aArrayProto [] hn (h.intr _ (by decide)) hp
      (fun v hv => hacc v (List.mem_reverse.1 hv)) (fun _ hx => nomatch hx)
  | cons el r ih =>
    intro acc hacc
    cases el with
    | hole =>
      exact ih (.undef :: acc) (fun v hv => by
        rcases List.mem_cons.1 hv with rfl | hv
        · trivial
        · exact hacc v hv)
    | expr e => exact evSim_push_go h (.l (.array acc r env)) (.ev e env) ⟨hacc, he⟩ he
    | spread e => exact evSim_push_go h (.l (.spread acc r env)) (.ev e env) ⟨hacc, he⟩ he

theorem step_array (h : RelB F FR W stk M ν K s S t C) {elems : List Elem} {env : Env}
    (hc : s.ctl = .ev (.array elems) env) (hn : s.next + margin < Sim.bound)
    (hp : Present s aArrayProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  exact arrayNext_sim h (margin_lt hn) hp (h.ev_supp hc) elems [] (fun _ hx => nomatch hx)

/-! ## Calls -/

theorem argsNext_sim (h : RelB F FR W stk M ν K s S t C) (kind : Nat) {fn this : Val} {env : Env}
    (hfn : Supp.val (Present s) S.tab.length fn) (hth : Supp.val (Present s) S.tab.length this)
    (he : Supp.env (Present s) S.tab.length env) (hsup : 2 ≤ kind → CellNoW K W env nCls ∧ CellNoW K W env nNt) :
    ∀ (rest : List Elem) (acc : List Val), Supp.vals (Present s) S.tab.length acc →
      MSim (StepPostB F FR W stk M ν K S C) S C (argsNext F s kind fn this acc rest env)
        (argsNext F t kind (M.val fn) (M.val this) (M.vals acc) rest (M.env env)) := by
  intro rest
  induction rest with
  | nil =>
    intro acc hacc
    have hrev : Supp.vals (Present s) S.tab.length acc.reverse :=
      fun v hv => hacc v (List.mem_reverse.1 hv)
    match kind with
    | 0 =>
      show MSim _ S C (Host.Ts.M.pure (s.go (.call fn this acc.reverse)))
        (Host.Ts.M.pure (t.go (.call (M.val fn) (M.val this) (M.vals acc).reverse)))
      rw [Map.vals_reverse]
      exact evSim_rel (h.go (.call fn this acc.reverse) ⟨hfn, hth, hrev⟩)
    | 1 =>
      show MSim _ S C (Host.Ts.M.pure (s.go (.construct fn acc.reverse fn)))
        (Host.Ts.M.pure (t.go (.construct (M.val fn) (M.vals acc).reverse (M.val fn))))
      rw [Map.vals_reverse]
      exact evSim_rel (h.go (.construct fn acc.reverse fn) ⟨hfn, hrev, hfn⟩)
    | k + 2 =>
      cases hl : lookupEnv nThis env with
      | none => simp only [argsNext, hl]; exact MSim.fail _ _
      | some tc =>
        cases hcls : Host.Ts.cellVal? F s nCls env with
        | none => simp only [argsNext, hl, hcls]; exact MSim.fail _ _
        | some cv =>
          cases cv
          case obj cls =>
            cases hnt : Host.Ts.cellVal? F s nNt env with
            | none => simp only [argsNext, hl, hcls, hnt]; exact MSim.fail _ _
            | some nt =>
              have hcls' := h.cellVal_map hcls (hsup (by omega)).1
              have hnt' := h.cellVal_map hnt (hsup (by omega)).2
              simp only [Map.val] at hcls'
              simp only [argsNext, hl, hcls, hnt, lookupEnv_map_some hl, hcls', hnt']
              rw [Map.vals_reverse]
              exact evSim_push_go h (.k (.superRet tc cls env)) (.construct fn acc.reverse nt)
                ⟨lookupEnv_supp he hl, h.cellVal_supp hcls, he⟩ ⟨hfn, hrev, h.cellVal_supp hnt⟩
          all_goals (simp only [argsNext, hl, hcls]; exact MSim.fail _ _)
  | cons el r ih =>
    intro acc hacc
    cases el with
    | hole =>
      exact ih (.undef :: acc) (fun v hv => by
        rcases List.mem_cons.1 hv with rfl | hv
        · trivial
        · exact hacc v hv)
    | expr e => exact evSim_push_go h (.c (.args kind fn this acc r env)) (.ev e env) ⟨hfn, hth, hacc, he⟩ he
    | spread e => exact evSim_push_go h (.c (.spread kind fn this acc r env)) (.ev e env) ⟨hfn, hth, hacc, he⟩ he

/-- Every call expression: `super(…)`, method calls (member, index, private) and plain callees. -/
theorem step_call (h : RelB F FR W stk M ν K s S t C) {callee : Expr} {args : List Elem} {opt : Bool}
    {env : Env} (hc : s.ctl = .ev (.call callee args opt) env)
    (hsup : callee = .super → CellNoW K W env nCls ∧ CellNoW K W env nNt) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  have he := h.ev_supp hc
  cases callee
  case super =>
    show MSim _ S C (evCall F s .super args opt env) (evCall F t .super args opt (M.env env))
    cases hcls : Host.Ts.cellVal? F s nCls env with
    | none => simp only [evCall, hcls]; exact MSim.fail _ _
    | some cv =>
      cases cv
      case obj c =>
        have hcls' := h.cellVal_map hcls (hsup rfl).1
        simp only [Map.val] at hcls'
        cases ho : s.obj? c with
        | none => simp only [evCall, hcls, ho]; exact MSim.fail _ _
        | some o =>
          obtain ⟨k, pr, ps, pv, ex⟩ := o
          cases k
          case fn code =>
            cases code
            case klass ctor e par is =>
              have ho' := h.obj?_plain ho (fun _ hk => Kind.noConfusion hk) id
              simp only [Map.obj, Map.kind, Map.code] at ho'
              simp only [evCall, hcls, ho, hcls', ho']
              exact argsNext_sim h 2 (this := .undef) (h.obj?_supp ho).1.2.1 trivial he (fun _ => hsup rfl) args []
                (fun _ hx => nomatch hx)
            all_goals (simp only [evCall, hcls, ho]; exact MSim.fail _ _)
          all_goals (simp only [evCall, hcls, ho]; exact MSim.fail _ _)
      all_goals (simp only [evCall, hcls]; exact MSim.fail _ _)
  case member o p optObj =>
    exact evSim_push_go h (.c (.member (.str p) args env optObj opt)) (.ev o env) ⟨trivial, he⟩ he
  case index o k optObj =>
    exact evSim_push_go h (.c (.index k args env optObj opt)) (.ev o env) he he
  case priv o n optObj =>
    show MSim _ S C (evCall F s (.priv o n optObj) args opt env)
      (evCall F t (.priv o n optObj) args opt (M.env env))
    cases hl : lookupEnv (privName n) env with
    | none => simp only [evCall, hl]; exact MSim.fail _ _
    | some b =>
      simp only [evCall, hl, lookupEnv_map_some hl]
      exact evSim_push_go h (.c (.priv b n args env optObj opt)) (.ev o env) ⟨lookupEnv_supp he hl, he⟩ he
  all_goals exact evSim_push_go h (.c (.callee args env opt)) _ he he

/-! ## Assignment and update -/

/-- Every assignment form; a compound assignment to a variable reads it first. -/
theorem step_assign (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    {op : AsgOp} {target : Pat} {v : Expr} {env : Env}
    (hc : s.ctl = .ev (.assign op target v) env) (hn : s.next + margin < Sim.bound)
    (hp : Present s aReferenceErrorProto)
    (hok : ∀ n, target = .id n → op ≠ .assign → VarOK K W s env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  have he := h.ev_supp hc
  show MSim _ S C (evAssign F s op target v env) (evAssign F t op target v (M.env env))
  cases target with
  | id n =>
    show MSim _ S C (asgTarget F s op (.var n env) v env) (asgTarget F t op (.var n (M.env env)) v (M.env env))
    cases op with
    | assign => exact evSim_push_go h (.a (.put none (.var n env) .undef)) (.ev v env) ⟨he, trivial⟩ he
    | bin o =>
      exact readVar_sim (h.push (.a (.old (.bin o) (.var n env) v env)) ⟨he, he⟩) hF
        (hok n rfl (fun e => AsgOp.noConfusion e)) (margin_lt hn) hp
    | log o =>
      exact readVar_sim (h.push (.a (.old (.log o) (.var n env) v env)) ⟨he, he⟩) hF
        (hok n rfl (fun e => AsgOp.noConfusion e)) (margin_lt hn) hp
  | expr e =>
    cases e
    case member o p _ =>
      exact evSim_push_go h (.a (.obj op (some (.str p)) none v env)) (.ev o env) ⟨trivial, he⟩ he
    case index o k _ =>
      exact evSim_push_go h (.a (.obj op none (some k) v env)) (.ev o env) ⟨trivial, he⟩ he
    case priv o n _ =>
      cases hl : lookupEnv (privName n) env with
      | none => simp only [evAssign, hl]; exact MSim.fail _ _
      | some b =>
        simp only [evAssign, hl, lookupEnv_map_some hl]
        exact evSim_push_go h (.a (.privObj op b n v env)) (.ev o env) ⟨lookupEnv_supp he hl, he⟩ he
    all_goals exact MSim.fail _ _
  | dflt _ _ => exact MSim.fail _ _
  | array ps r =>
    cases op with
    | assign => exact evSim_push_go h (.a (.pat (.array ps r) env)) (.ev v env) he he
    | bin _ => exact MSim.fail _ _
    | log _ => exact MSim.fail _ _
  | object ps r =>
    cases op with
    | assign => exact evSim_push_go h (.a (.pat (.object ps r) env)) (.ev v env) he he
    | bin _ => exact MSim.fail _ _
    | log _ => exact MSim.fail _ _

theorem step_update (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    {inc pre : Bool} {e : Expr} {env : Env}
    (hc : s.ctl = .ev (.update inc pre e) env) (hn : s.next + margin < Sim.bound)
    (hp : Present s aReferenceErrorProto)
    (hok : ∀ n, e = .id n → VarOK K W s env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  have he := h.ev_supp hc
  show MSim _ S C (evUpdate F s inc pre e env) (evUpdate F t inc pre e (M.env env))
  cases e
  case id n =>
    exact readVar_sim (h.push (.a (.updOld inc pre (.var n env))) he) hF (hok n rfl) (margin_lt hn) hp
  case member o p _ =>
    exact evSim_push_go h (.a (.updObj inc pre (some (.str p)) none env)) (.ev o env) ⟨trivial, he⟩ he
  case index o k _ =>
    exact evSim_push_go h (.a (.updObj inc pre none (some k) env)) (.ev o env) ⟨trivial, he⟩ he
  case priv o n _ =>
    cases hl : lookupEnv (privName n) env with
    | none => simp only [evUpdate, hl]; exact MSim.fail _ _
    | some b =>
      simp only [evUpdate, hl, lookupEnv_map_some hl]
      exact evSim_push_go h (.a (.updPrivObj inc pre b n)) (.ev o env) (lookupEnv_supp he hl) he
  all_goals exact MSim.fail _ _

/-! ## Unary operators -/

/-- `typeof x` of a variable checks the binding first: an absent global gives `"undefined"`. -/
theorem step_unary (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    {op : UnOp} {x : Expr} {env : Env}
    (hc : s.ctl = .ev (.unary op x) env) (hok : ∀ n, op = .typeof → x = .id n → VarOK K W s env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  have he := h.ev_supp hc
  cases op
  case delete => exact MSim.fail _ _
  case typeof =>
    cases x
    case id n =>
      cases hl : lookupEnv n env with
      | none =>
        have hok' := hok n rfl rfl
        simp only [VarOK, hl] at hok'
        simp only [evStep, hl, lookupEnv_map_none hl]
        refine MSim.bind (getChain_global_sim h hF (k := .str n) trivial
          (ChainOK.of_noW hok'.2.1 hok'.2.2.1 16 aGlobal hok'.2.2.2)) ?_
        rintro M' S' C' r r' ⟨-, hS, hC, hr, -⟩
        rw [hS, hC, hr]
        cases r with
        | none => exact evSim_ret h (.str _) trivial
        | some p => exact evSim_push_go h (.e .typeof) (.ev (.id n) env) trivial he
      | some c =>
        simp only [evStep, hl, lookupEnv_map_some hl]
        exact evSim_push_go h (.e .typeof) (.ev (.id n) env) trivial he
    all_goals exact evSim_push_go h (.e (.unary .typeof)) _ trivial he
  all_goals exact evSim_push_go h (.e (.unary _)) _ trivial he

/-! ## Object literals -/

private theorem beq_even_odd (x y : Nat) : Nat.beq (Nat.mul 2 x) (Nat.succ (Nat.mul 2 y)) = false := by
  cases hb : Nat.beq (Nat.mul 2 x) (Nat.succ (Nat.mul 2 y))
  · rfl
  · have := Nat.eq_of_beq_eq_true hb
    change 2 * x = 2 * y + 1 at this
    omega

/-- String keys compare with mapped keys as with the originals (symbols have odd codes). -/
theorem beq_code_str_key (M : Map) (a : List Char) (j : PKey) :
    Nat.beq (PKey.code (.str a)) (M.key j).code = Nat.beq (PKey.code (.str a)) j.code := by
  cases j with
  | str b => rfl
  | sym i => exact (beq_even_odd _ _).trans (beq_even_odd _ _).symm

theorem findProp_str_map (M : Map) (a : List Char) (ps : Props) :
    findProp (.str a) (M.props ps) = (findProp (.str a) ps).map M.prop := by
  rw [findProp_eq_linear, findProp_eq_linear]
  induction ps with
  | nil => rfl
  | cons q ps ih =>
    obtain ⟨j, p⟩ := q
    show findPropLinear (.str a) ((M.key j, M.prop p) :: M.props ps) =
      (findPropLinear (.str a) ((j, p) :: ps)).map M.prop
    rw [findPropLinear_cons, findPropLinear_cons, beq_code_str_key]
    cases Nat.beq (PKey.code (.str a)) j.code
    · exact ih
    · rfl

theorem keyEq_str_key (M : Map) (a : List Char) (j : PKey) :
    keyEq (.str a) (M.key j) = keyEq (.str a) j :=
  beq_code_str_key M a j

theorem setPropL_str_map (M : Map) (a : List Char) (p : PropV) (ps : Props) :
    setPropL (.str a) (M.prop p) (M.props ps) = M.props (setPropL (.str a) p ps) := by
  induction ps with
  | nil => rfl
  | cons q ps ih =>
    obtain ⟨j, x⟩ := q
    show setPropL (.str a) (M.prop p) ((M.key j, M.prop x) :: M.props ps) = M.props (setPropL (.str a) p ((j, x) :: ps))
    rw [setPropL_cons, setPropL_cons, keyEq_str_key]
    cases keyEq (.str a) j
    · show (M.key j, M.prop x) :: setPropL (.str a) (M.prop p) (M.props ps) =
        (M.key j, M.prop x) :: M.props (setPropL (.str a) p ps)
      rw [ih]
    · rfl

theorem accessorProp_map (M : Map) (old : Option PropV) (kind : MethodKind) (f : Val) (enum : Bool) :
    accessorProp (old.map M.prop) kind (M.val f) enum = M.prop (accessorProp old kind f enum) := by
  cases old with
  | none => cases kind <;> rfl
  | some q => cases q <;> cases kind <;> rfl

theorem Supp.accessorProp {A : Nat → Prop} {n : Nat} {old : Option PropV} {kind : MethodKind} {f : Val}
    {enum : Bool} (ho : ∀ q, old = some q → Supp.prop A n q) (hf : Supp.val A n f) :
    Supp.prop A n (Host.Ts.accessorProp old kind f enum) := by
  cases old with
  | none =>
    cases kind with
    | method => exact hf
    | get => exact ⟨hf, trivial⟩
    | set => exact ⟨trivial, hf⟩
  | some q =>
    have hq := ho q rfl
    cases q with
    | data v w e =>
      cases kind with
      | method => exact hf
      | get => exact ⟨hf, trivial⟩
      | set => exact ⟨trivial, hf⟩
    | acc g st e =>
      cases kind with
      | method => exact hf
      | get => exact ⟨hf, hq.2⟩
      | set => exact ⟨hq.1, hf⟩

/-- The second half of `methodProp`: install the method on the target object. -/
def withMethod (ob : Obj) (k : PKey) (kind : MethodKind) (f : Val) (enum : Bool) : Obj :=
  { ob with props := setPropL k (accessorProp (findProp k ob.props) kind f enum) ob.props }

def addMethod {S' : Type} (s : St S') (o : Nat) (k : PKey) (kind : MethodKind) (f : Val) (enum : Bool) : St S' :=
  match s.obj? o with
  | some ob => s.setObj o (withMethod ob k kind f enum)
  | none => s

theorem withMethod_map (M : Map) (ob : Obj) (a : List Char) (kind : MethodKind) (f : Val) (enum : Bool) :
    withMethod (M.obj ob) (.str a) kind (M.val f) enum = M.obj (withMethod ob (.str a) kind f enum) := by
  unfold withMethod
  show ({ M.obj ob with props := setPropL (.str a) (accessorProp (findProp (.str a) (M.props ob.props)) kind (M.val f) enum) (M.props ob.props) } : Obj) = _
  rw [findProp_str_map, accessorProp_map, setPropL_str_map]
  rfl

theorem methodProp_eq (s : St F.S) (o : Nat) (k : PKey) (kind : MethodKind) (fn : Func) (env : Env)
    (enum : Bool) :
    methodProp F s o k kind fn env enum =
      addMethod (closureObj s fn env false (.obj o)).2 o k kind (.obj s.next) enum := rfl

theorem addMethod_next {S' : Type} (s : St S') (o : Nat) (k : PKey) (kind : MethodKind) (f : Val)
    (enum : Bool) : (addMethod s o k kind f enum).next = s.next := by
  unfold addMethod
  split <;> rfl

theorem Present.addMethod {S' : Type} {s : St S'} {o x : Nat} {k : PKey} {kind : MethodKind} {f : Val}
    {enum : Bool} (ho : o < 2 ^ 64) (hx : Present s x) : Present (addMethod s o k kind f enum) x := by
  unfold Host.Ts.Sim.addMethod
  split
  · exact Present.set _ ho hx
  · exact hx

theorem addMethod_rel (h : RelB F FR W stk M ν K s S t C) {o : Nat} {a : List Char} {kind : MethodKind}
    {f : Val} {enum : Bool} (hn : s.next < Sim.bound) (ho : Present s o) (hfr : K.fr o = none)
    (hf : Supp.val (Present s) S.tab.length f) :
    RelB F FR W stk M ν K (addMethod s o (.str a) kind f enum) S (addMethod t (M.a o) (.str a) kind (M.val f) enum) C := by
  unfold addMethod
  cases hob : s.obj? o with
  | none =>
    have ht : t.obj? (M.a o) = none := by
      obtain ⟨hh, hg⟩ := ho.get
      cases hh with
      | obj ob => rw [obj?_iff.2 hg] at hob; cases hob
      | cell v =>
        have hg' := h.get hg hfr
        unfold St.obj?
        rw [hg']
        rfl
    rw [ht]
    exact h
  | some ob =>
    rw [h.obj? hob hfr]
    have hs := h.obj?_supp hob
    dsimp only
    rw [withMethod_map]
    exact h.setObj _ hn ho hfr ⟨hs.1, hs.2.1,
      setPropL_supp (k := .str a) trivial (Supp.accessorProp (fun q hq => findProp_supp hs.2.2.1 hq) hf) hs.2.2.1, hs.2.2.2⟩

theorem methodProp_rel (h : RelB F FR W stk M ν K s S t C) {o : Nat} {a : List Char} {kind : MethodKind}
    {fn : Func} {env : Env} {enum : Bool} (hn : s.next + 1 < Sim.bound)
    (hpf : Present s aFunctionProto) (ho : Present s o)
    (hfr : K.fr o = none) (he : Supp.env (Present s) S.tab.length env) :
    RelB F FR W stk M ν K (methodProp F s o (.str a) kind fn env enum) S
      (methodProp F t (M.a o) (.str a) kind fn (M.env env) enum) C := by
  have hn0 : s.next < Sim.bound := by omega
  have h64 := h.s64 hn0
  rw [methodProp_eq, methodProp_eq]
  have hv : M.val (.obj aFunctionProto) = .obj aFunctionProto := by
    show Val.obj (M.a aFunctionProto) = _; rw [h.intr _ (by decide)]
  have hP : ∀ x, Present s x →
      Present (s.allocObj (.fn (.closure fn env false (.obj o))) (.obj aFunctionProto) []).2 x :=
    fun _ hx => Present.alloc _ h64 hx
  obtain ⟨ha, h1⟩ := h.allocObj (.fn (.closure fn env false (.obj o))) (.obj aFunctionProto) [] hn0
    ⟨fun x hx => hP _ (he x hx), hP _ ho⟩ (hP _ hpf) (fun _ hx => nomatch hx)
  rw [hv] at ha h1
  have ht : t.next = M.a s.next := ha
  rw [ht]
  exact addMethod_rel h1 (f := .obj s.next) hn (hP _ ho) hfr (Present.alloc_next s _ h64)

theorem methodProp_next (s : St F.S) (o : Nat) (k : PKey) (kind : MethodKind) (fn : Func) (env : Env)
    (enum : Bool) : (methodProp F s o k kind fn env enum).next = s.next + 1 := by
  rw [methodProp_eq, addMethod_next]
  rfl

theorem Present.methodProp {s : St F.S} {o x : Nat} {k : PKey} {kind : MethodKind} {fn : Func} {env : Env}
    {enum : Bool} (hn : s.next < 2 ^ 64) (ho : o < 2 ^ 64) (hx : Present s x) :
    Present (Host.Ts.methodProp F s o k kind fn env enum) x := by
  rw [methodProp_eq]
  exact Present.addMethod ho (Present.alloc _ hn hx)

theorem keyOf_str {k : Key} {key : PKey} (hk : keyOf k = some key) : ∃ a, key = .str a := by
  cases k with
  | id n => cases hk; exact ⟨_, rfl⟩
  | str raw =>
    simp only [keyOf] at hk
    cases hc : cook raw with
    | none => rw [hc] at hk; cases hk
    | some cs => rw [hc] at hk; cases hk; exact ⟨_, rfl⟩
  | num raw =>
    simp only [keyOf] at hk
    cases hx : F64.ofLit raw with
    | none => rw [hx] at hk; cases hk
    | some x =>
      rw [hx] at hk
      simp only [Option.bind_some] at hk
      cases hs : F64.toStr x with
      | none => rw [hs] at hk; cases hk
      | some cs => rw [hs] at hk; cases hk; exact ⟨_, rfl⟩
  | priv _ => cases hk
  | computed _ => cases hk

/-- Object literal properties: methods are installed in place, the first other property
pushes a frame (a shorthand reads its variable). -/
theorem objNext_sim (hF : FfiSim F FR okCall okBack) :
    ∀ (rest : List Property) {s0 t0 : St F.S} (_h : RelB F FR W stk M ν K s0 S t0 C) {o : Nat} {env : Env},
      s0.next + rest.length < Sim.bound → Present s0 o → K.fr o = none → Present s0 aFunctionProto →
      Present s0 aReferenceErrorProto → Supp.env (Present s0) S.tab.length env →
      (∀ n, Property.short n ∈ rest → ShortOK K W s0 env n) →
      MSim (StepPostB F FR W stk M ν K S C) S C (objNext F s0 o rest env) (objNext F t0 (M.a o) rest (M.env env)) := by
  intro rest
  induction rest with
  | nil => intro s0 t0 h o env _ ho _ _ _ _ _; exact evSim_ret h (.obj o) ho
  | cons p r ih =>
    intro s0 t0 h o env hn ho hfr hpf hpr he hsh
    have hn0 : s0.next < Sim.bound := by simp only [List.length_cons] at hn; omega
    cases p with
    | init k e =>
      cases hk : keyOf k with
      | some key =>
        obtain ⟨a, rfl⟩ := keyOf_str hk
        simp only [objNext, hk]
        exact evSim_push_go h (.l (.objVal o (.str a) r env)) (.ev e env) ⟨ho, trivial, he⟩ he
      | none =>
        cases k
        case computed ke =>
          simp only [objNext, hk]
          exact evSim_push_go h (.l (.objKey o (.init (.computed ke) e) r env)) (.ev ke env) ⟨ho, he⟩ he
        all_goals (simp only [objNext, hk]; exact MSim.fail _ _)
    | short n =>
      exact readVar_sim (h.push (.l (.objVal o (.str n) r env)) ⟨ho, trivial, he⟩) hF
        (hsh n (List.mem_cons_self ..)).varOK hn0 hpr
    | method kind k fn =>
      cases hk : keyOf k with
      | some key =>
        obtain ⟨a, rfl⟩ := keyOf_str hk
        simp only [objNext, hk]
        have h64 := h.s64 hn0
        have hb : Sim.bound = 2 ^ 61 := rfl
        have ho64 : o < 2 ^ 64 := by have := h.presentBound o ho; omega
        have hP : ∀ x, Present s0 x → Present (methodProp F s0 o (.str a) kind fn env true) x :=
          fun _ hx => Present.methodProp h64 ho64 hx
        refine ih (methodProp_rel h (by simp only [List.length_cons] at hn; omega) hpf ho hfr he)
          ?_ (hP _ ho) hfr (hP _ hpf) (hP _ hpr) (Supp.env_mono hP (Nat.le_refl _) he)
          (fun n hm => ShortOK.mono hP (hsh n (List.mem_cons_of_mem _ hm)))
        rw [methodProp_next]
        simp only [List.length_cons] at hn
        omega
      | none =>
        cases k
        case computed ke =>
          simp only [objNext, hk]
          exact evSim_push_go h (.l (.objKey o (.method kind (.computed ke) fn) r env)) (.ev ke env) ⟨ho, he⟩ he
        all_goals (simp only [objNext, hk]; exact MSim.fail _ _)
    | spread e => exact evSim_push_go h (.l (.objSpread o r env)) (.ev e env) ⟨ho, he⟩ he

/-- An object literal: allocate it, install leading methods (one closure each), stop at the
first other property. -/
theorem step_object (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    {props : List Property} {env : Env}
    (hc : s.ctl = .ev (.object props) env) (hn : s.next + margin < Sim.bound)
    (hpo : Present s aObjectProto) (hpf : Present s aFunctionProto)
    (hpr : Present s aReferenceErrorProto) (hlen : props.length ≤ 2 ^ 20)
    (hsh : ∀ n, Property.short n ∈ props → ShortOK K W s env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_ev_eq hc, h.step_ev hc]
  have he := h.ev_supp hc
  have hn0 := margin_lt hn
  have h64 := h.s64 hn0
  have hfr : K.fr s.next = none := by
    cases hf : K.fr s.next with
    | none => rfl
    | some p => exact absurd (h.presentBound _ (h.framedPresent _ _ hf)) (Nat.lt_irrefl _)
  have hv : M.val (.obj aObjectProto) = .obj aObjectProto := by
    show Val.obj (M.a aObjectProto) = _; rw [h.intr _ (by decide)]
  have hP : ∀ x, Present s x → Present (s.allocObj .ordinary (.obj aObjectProto) []).2 x :=
    fun _ hx => Present.alloc _ h64 hx
  obtain ⟨ha, h1⟩ := h.allocObj .ordinary (.obj aObjectProto) [] hn0 trivial (hP _ hpo) (fun _ hx => nomatch hx)
  rw [hv] at ha h1
  show MSim _ S C (objNext F (s.allocObj .ordinary (.obj aObjectProto) []).2 (s.allocObj .ordinary (.obj aObjectProto) []).1 props env)
    (objNext F (t.allocObj .ordinary (.obj aObjectProto) []).2 (t.allocObj .ordinary (.obj aObjectProto) []).1 props (M.env env))
  rw [show (t.allocObj .ordinary (.obj aObjectProto) []).1 = M.a (s.allocObj .ordinary (.obj aObjectProto) []).1 from ha]
  have hm : margin = 2 ^ 30 := rfl
  exact objNext_sim hF props h1 (by show s.next + 1 + props.length < Sim.bound; rw [hm] at hn; omega)
    (Present.alloc_next s _ h64) hfr (hP _ hpf) (hP _ hpr) (Supp.env_mono hP (Nat.le_refl _) he)
    (fun n hm => ShortOK.mono hP (hsh n hm))

end
end Host.Ts.Sim

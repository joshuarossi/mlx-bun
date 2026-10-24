import host.sim.steps.RetE
namespace Host.Ts.Sim

/-! # Call frames receiving a value

Callee, method and argument frames: argument lists (`argsNext`), method
lookups (`getV`, `getIndex`, `privGetV`) with the method frame pushed, and
spread arguments (`spreadElems`). -/

theorem rf_vals_reverse (M : Map) (vs : List Val) : (M.vals vs).reverse = M.vals vs.reverse := by
  simp [Map.vals]

theorem rf_vals_supp_reverse {A : Nat → Prop} {n : Nat} {vs : List Val} (h : Supp.vals A n vs) :
    Supp.vals A n vs.reverse := fun v hv => h v (List.mem_reverse.1 hv)

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

/-! ## Cells and environments -/

theorem RelB.rfCell (h : RelB F FR W stk M ν K s S t C) {c : Nat} (hp : Present s c) (hn : NoW K W s c) :
    t.cell? (M.a c) = (s.cell? c).map (Option.map M.val) := by
  cases hc : s.cell? c with
  | some x => rw [h.cell? hc hn]; rfl
  | none =>
    obtain ⟨o, hg⟩ := hp.get
    cases o with
    | cell v => rw [cell?_iff.2 hg] at hc; cases hc
    | obj o =>
      obtain ⟨o', ht⟩ := h.obj_target hg
      unfold St.cell?
      rw [ht]
      rfl

theorem RelB.rfCellVal (h : RelB F FR W stk M ν K s S t C) {n : Name} {env : Env}
    (he : Supp.env (Present s) S.tab.length env) (hcn : CellNoW K W env n) :
    cellVal? F t n (M.env env) = (cellVal? F s n env).map M.val := by
  unfold cellVal?
  rw [lookupEnv_map]
  cases hl : lookupEnv n env with
  | none => rfl
  | some c =>
    simp only [Option.map_some, Option.bind_some]
    rw [h.rfCell (lookupEnv_supp' he hl) (.of_or (hcn c hl))]
    cases s.cell? c with
    | none => rfl
    | some x => cases x <;> rfl
where
  lookupEnv_supp' {A : Nat → Prop} {n' : Nat} {x : Name} {env : Env} {b : Nat}
      (he : Supp.env A n' env) (hl : lookupEnv x env = some b) : A b := by
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

theorem rf_lookupEnv_supp {A : Nat → Prop} {n : Nat} {x : Name} {env : Env} {b : Nat}
    (he : Supp.env A n env) (hl : lookupEnv x env = some b) : A b :=
  RelB.rfCellVal.lookupEnv_supp' he hl

theorem RelB.rfCellVal_supp (h : RelB F FR W stk M ν K s S t C) {n : Name} {env : Env} {v : Val}
    (hv : cellVal? F s n env = some v) : Supp.val (Present s) S.tab.length v := by
  unfold cellVal? at hv
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

/-! ## Argument lists -/

theorem rf_argsNext (h : RelB F FR W stk M ν K s S t C) (kind : Nat) {fn th : Val} {env : Env}
    (hfn : Supp.val (Present s) S.tab.length fn) (hth : Supp.val (Present s) S.tab.length th)
    (he : Supp.env (Present s) S.tab.length env) (hsup : 2 ≤ kind → CellNoW K W env nCls ∧ CellNoW K W env nNt) :
    ∀ (rest : List Elem) {acc : List Val}, Supp.vals (Present s) S.tab.length acc →
      MSim (StepPostB F FR W stk M ν K S C) S C (argsNext F s kind fn th acc rest env)
        (argsNext F t kind (M.val fn) (M.val th) (M.vals acc) rest (M.env env))
  | [], acc, hacc => by
    match kind with
    | 0 =>
      have := rf_rel (h.go (.call fn th acc.reverse) ⟨hfn, hth, rf_vals_supp_reverse hacc⟩)
      rw [show M.ctl (.call fn th acc.reverse) = .call (M.val fn) (M.val th) (M.vals acc).reverse by
        rw [rf_vals_reverse]; rfl] at this
      exact this
    | 1 =>
      have := rf_rel (h.go (.construct fn acc.reverse fn) ⟨hfn, rf_vals_supp_reverse hacc, hfn⟩)
      rw [show M.ctl (.construct fn acc.reverse fn) = .construct (M.val fn) (M.vals acc).reverse (M.val fn) by
        rw [rf_vals_reverse]; rfl] at this
      exact this
    | k + 2 =>
      simp only [argsNext]
      rw [lookupEnv_map, h.rfCellVal he (hsup (by omega)).1, h.rfCellVal he (hsup (by omega)).2]
      cases hl : lookupEnv nThis env with
      | none => exact MSim.fail _ _
      | some tc =>
        cases hcls : cellVal? F s nCls env with
        | none => exact MSim.fail _ _
        | some cls =>
          cases hnt : cellVal? F s nNt env with
          | none =>
            cases cls <;> exact MSim.fail _ _
          | some nt =>
            have hcs := h.rfCellVal_supp hcls
            have hns := h.rfCellVal_supp hnt
            cases cls with
            | obj c =>
              have := rf_rel ((h.push (.k (.superRet tc c env)) ⟨rf_lookupEnv_supp he hl, hcs, he⟩).go
                (.construct fn acc.reverse nt) ⟨hfn, rf_vals_supp_reverse hacc, hns⟩)
              rw [show M.ctl (.construct fn acc.reverse nt) =
                .construct (M.val fn) (M.vals acc).reverse (M.val nt) by rw [rf_vals_reverse]; rfl] at this
              exact this
            | _ => exact MSim.fail _ _
  | .expr e :: r, acc, hacc =>
    rf_rel ((h.push (.c (.args kind fn th acc r env)) ⟨hfn, hth, hacc, he⟩).go (.ev e env) he)
  | .spread e :: r, acc, hacc =>
    rf_rel ((h.push (.c (.spread kind fn th acc r env)) ⟨hfn, hth, hacc, he⟩).go (.ev e env) he)
  | .hole :: r, acc, hacc => by
    have := rf_argsNext h kind hfn hth he hsup r (acc := .undef :: acc)
      (fun v hv => by
        rcases List.mem_cons.1 hv with rfl | hv
        · trivial
        · exact hacc v hv)
    exact this


/-! ## Local variables -/

/-- A local variable read (initialized or not). -/
theorem rf_readVarLocal (h : RelB F FR W stk M ν K s S t C) {n : Name} {env : Env} {c : Nat}
    (hl : lookupEnv n env = some c) (hn : s.next < Sim.bound) (hp : Present s aReferenceErrorProto)
    (hcn : W c = none ∨ K.fr c = none) :
    MSim (StepPostB F FR W stk M ν K S C) S C (readVar F s n env) (readVar F t n (M.env env)) := by
  have hl' : lookupEnv n (M.env env) = some (M.a c) := by rw [lookupEnv_map, hl]; rfl
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
      exact rf_ret h v (h.cell?_supp hv)

/-- A local variable write. -/
theorem rf_writeVarLocal (h : RelB F FR W stk M ν K s S t C) {n : Name} {env : Env} {c : Nat} {v : Val}
    (hl : lookupEnv n env = some c) (hn : s.next < Sim.bound) (hp : Present s aReferenceErrorProto)
    (hc : Present s c) (hv : Supp.val (Present s) S.tab.length v) (hcn : W c = none ∨ K.fr c = none) :
    MSim (StepPostB F FR W stk M ν K S C) S C (writeVar F s n env v) (writeVar F t n (M.env env) (M.val v)) := by
  have hl' : lookupEnv n (M.env env) = some (M.a c) := by rw [lookupEnv_map, hl]; rfl
  cases hx : s.cell? c with
  | none =>
    simp only [writeVar, hl, hx]
    exact MSim.fail _ _
  | some x =>
    have hx' := h.cell? hx (.of_or hcn)
    cases x with
    | none =>
      simp only [writeVar, hl, hx, hl', hx', Option.map_none]
      exact refErr_sim h h.intr hn hp _
    | some w =>
      simp only [writeVar, hl, hx, hl', hx', Option.map_some]
      have hfr := h.fr_cell (cell?_iff.1 hx) (.of_or hcn)
      have h1 := h.setCell v hn hc hfr hv
      have hb : Sim.bound = 2 ^ 61 := rfl
      have hlt := h.presentBound c hc
      exact rf_ret h1 v (Supp.val_mono (fun _ hp => Present.set _ (by omega) hp) (Nat.le_refl _) hv)

/-! ## Spread elements -/

/-- Side condition of `spreadElems v`: elements are read under `ElemsOK`; a generic
iterable's `Symbol.iterator` is looked up under `LookupOK`. -/
def SpreadOK (F : Ffi) (K : Ctx) (W : Nat → Option WFrame) (s : St F.S) (S : SSrv) (v : Val) : Prop :=
  ElemsOK F K s S v ∧ LookupOK F K W s S v (.sym symIterator)

theorem rf_spreadElems (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    (hn : s.next < Sim.bound) (hpT : Present s aTypeErrorProto) {v : Val} {again : Frame}
    {k : List Val → RS F} {k' : List Val → RS F} (hv : Supp.val (Present s) S.tab.length v)
    (ha : Supp.frame (Present s) S.tab.length again) (hok : SpreadOK F K W s S v)
    (hk : ∀ es, Supp.vals (Present s) S.tab.length es →
      MSim (StepPostB F FR W stk M ν K S C) S C (k es) (k' (M.vals es))) :
    MSim (StepPostB F FR W stk M ν K S C) S C (spreadElems F s v again k)
      (spreadElems F t (M.val v) (M.frame again) k') := by
  unfold spreadElems
  refine MSim.bind (elemsOf_sim h hF hv hok.1) ?_
  rintro M' S' C' r r' ⟨-, hS, hC, rfl, hsupp⟩
  rw [hS, hC]
  cases r with
  | some es => exact hk es (hsupp es rfl)
  | none =>
    have hit : MSim (StepPostB F FR W stk M ν K S C) S C
        (startIter F ((s.push again).push (.b (.collectIt []))) v)
        (startIter F ((t.push (M.frame again)).push (.b (.collectIt []))) (M.val v)) := by
      have h1 := ((h.push again ha).push (.b (.collectIt [])) (fun _ hx => nomatch hx)).push
        (.c (.method v [] [] false)) ⟨hv, fun _ hx => nomatch hx⟩
      exact getV_sim h1 hF h.intr hn hpT hv (fun h16 => absurd h16 (by decide)) hok.2
    cases v with
    | obj a => exact hit
    | _ => exact typeErr_sim h h.intr hn hpT _

end

/-! ## Steps -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
  {v : Val} {fs : List Frame}

theorem step_retC_args (h : RelB F FR W stk M ν K s S t C) {kind : Nat} {fn this : Val} {acc : List Val}
    {rest : List Elem} {env : Env} (hc : s.ctl = .ret v)
    (hs : s.stack = .c (.args kind fn this acc rest env) :: fs)
    (hsup : 2 ≤ kind → CellNoW K W env nCls ∧ CellNoW K W env nNt) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  obtain ⟨hfn, hth, hacc, he⟩ := hf
  exact rf_argsNext hr kind hfn hth he hsup rest (acc := v :: acc) fun x hx => by
    rcases List.mem_cons.1 hx with rfl | hx
    · exact hv
    · exact hacc x hx

theorem step_retC_callee (h : RelB F FR W stk M ν K s S t C) {args : List Elem} {env : Env} {opt : Bool}
    (hc : s.ctl = .ret v) (hs : s.stack = .c (.callee args env opt) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  have he : Supp.env (Present s) S.tab.length env := hf
  show MSim _ S C (bif opt && isNullish v then _ else _) (bif opt && isNullish (M.val v) then _ else _)
  rw [rf_isNullish]
  exact MSim.cond _ (rf_rel (hr.go .short trivial))
    (rf_argsNext hr 0 (th := .undef) hv trivial he (fun h => absurd h (by decide)) args (acc := [])
      fun _ hx => nomatch hx)

theorem step_retC_method (h : RelB F FR W stk M ν K s S t C) {this : Val} {args : List Elem} {env : Env}
    {opt : Bool} (hc : s.ctl = .ret v) (hs : s.stack = .c (.method this args env opt) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  obtain ⟨hth, he⟩ := hf
  show MSim _ S C (bif opt && isNullish v then _ else _) (bif opt && isNullish (M.val v) then _ else _)
  rw [rf_isNullish]
  exact MSim.cond _ (rf_rel (hr.go .short trivial))
    (rf_argsNext hr 0 hv hth he (fun h => absurd h (by decide)) args (acc := []) fun _ hx => nomatch hx)

theorem step_retC_newCallee (h : RelB F FR W stk M ν K s S t C) {args : List Elem} {env : Env}
    (hc : s.ctl = .ret v) (hs : s.stack = .c (.newCallee args env) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  have he : Supp.env (Present s) S.tab.length env := hf
  exact rf_argsNext hr 1 (th := .undef) hv trivial he (fun h => absurd h (by decide)) args (acc := [])
    fun _ hx => nomatch hx

theorem step_retC_index (h : RelB F FR W stk M ν K s S t C) {ke : Expr} {args : List Elem} {env : Env}
    {optObj optCall : Bool} (hc : s.ctl = .ret v)
    (hs : s.stack = .c (.index ke args env optObj optCall) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  have he : Supp.env (Present s) S.tab.length env := hf
  show MSim _ S C (bif optObj && isNullish v then _ else _)
    (bif optObj && isNullish (M.val v) then _ else _)
  rw [rf_isNullish]
  exact MSim.cond _ (rf_rel (hr.go .short trivial))
    (rf_rel ((hr.push (.c (.indexK v args env optCall)) ⟨hv, he⟩).go (.ev ke env) he))

theorem step_retC_member (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    (hn : s.next < Sim.bound) {k : PKey} {args : List Elem} {env : Env} {optObj optCall : Bool}
    (hc : s.ctl = .ret v) (hs : s.stack = .c (.member k args env optObj optCall) :: fs)
    (hpT : Present s aTypeErrorProto) (hok : LookupOK F K W s S v k) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  obtain ⟨hk, he⟩ := hf
  show MSim _ S C (bif optObj && isNullish v then _ else _)
    (bif optObj && isNullish (M.val v) then _ else _)
  rw [rf_isNullish]
  exact MSim.cond _ (rf_rel (hr.go .short trivial))
    (getV_sim (hr.push (.c (.method v args env optCall)) ⟨hv, he⟩) hF h.intr hn hpT hv hk hok)

theorem step_retC_indexK (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    (hn : s.next < Sim.bound) {o : Val} {args : List Elem} {env : Env} {optCall : Bool}
    (hc : s.ctl = .ret v) (hs : s.stack = .c (.indexK o args env optCall) :: fs)
    (hpT : Present s aTypeErrorProto) (hok : GetIndexOK F K W s S o v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  obtain ⟨ho, he⟩ := hf
  exact rf_getIndex (hr.push (.c (.method o args env optCall)) ⟨ho, he⟩) hF hn hpT ho hv hok


theorem step_retC_priv (h : RelB F FR W stk M ν K s S t C) (hn : s.next < Sim.bound) {b : Nat} {nm : Name}
    {args : List Elem} {env : Env} {optObj optCall : Bool} (hc : s.ctl = .ret v)
    (hs : s.stack = .c (.priv b nm args env optObj optCall) :: fs) (hpT : Present s aTypeErrorProto)
    (hpk : PrivOK K W s v nm) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  obtain ⟨hb, he⟩ := hf
  show MSim _ S C (bif optObj && isNullish v then _ else _)
    (bif optObj && isNullish (M.val v) then _ else _)
  rw [rf_isNullish]
  exact MSim.cond _ (rf_rel (hr.go .short trivial))
    (privGetV_sim (hr.push (.c (.method v args env optCall)) ⟨hv, he⟩) h.intr hn hpT hv hb
      (PrivOK.congr (fun _ => rfl) hpk))

theorem step_retC_spread (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    (hn : s.next < Sim.bound) {kind : Nat} {fn this : Val} {acc : List Val} {rest : List Elem} {env : Env}
    (hc : s.ctl = .ret v) (hs : s.stack = .c (.spread kind fn this acc rest env) :: fs)
    (hpT : Present s aTypeErrorProto) (hok : SpreadOK F K W s S v)
    (hsup : 2 ≤ kind → CellNoW K W env nCls ∧ CellNoW K W env nNt) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  have hf' := hf
  obtain ⟨hfn, hth, hacc, he⟩ := hf
  refine rf_spreadElems hr hF hn hpT hv hf' hok fun es hes => ?_
  have := rf_argsNext hr kind hfn hth he hsup rest (acc := es.reverse ++ acc) fun x hx => by
    rcases List.mem_append.1 hx with hx | hx
    · exact hes x (List.mem_reverse.1 hx)
    · exact hacc x hx
  rwa [show M.vals (es.reverse ++ acc) = (M.vals es).reverse ++ M.vals acc by simp [Map.vals]] at this

end
end Host.Ts.Sim

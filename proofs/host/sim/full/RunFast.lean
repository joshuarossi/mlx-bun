import host.sim.Run
import host.sim.dispatch.OkJs
import host.sim.full.CallSym
import host.sim.full.BridgeJs
namespace Host.Ts.Sim

/-! # A faster kernel evaluation of `runOk`

`runOk` appends to the table (`c.tab ++ [e]`) and takes its length at every numeric operation, and its acceptance
function runs native calls and reads numbers over the same list, so the kernel's cost of a chunk grows with the
table. `runOkS` computes the same function with the entries a chunk adds kept newest first and the length as a
number (`runOkS_eq`); `okJSJN` and `smallFX2F` are `okJSJ` and `smallFX2B` over that table (`okJSJN_eq`,
`smallFX2F_eq`). A chunk checked at `runOkS` is the chunk at `runOk` (`runOk_fun_of_runOkS`). -/

/-- A table: `base`, then `rev` reversed; `nb` and `n` the lengths of `base` and of the whole. -/
structure FSrv where
  base : List SymE
  nb : Nat
  rev : List SymE
  n : Nat
  oracle : List Ans

namespace FSrv

def toS (c : FSrv) : SSrv := ⟨c.base ++ c.rev.reverse, c.oracle⟩

def ofS (S : SSrv) : FSrv := ⟨S.tab, S.tab.length, [], S.tab.length, S.oracle⟩

def Wf (c : FSrv) : Prop := c.nb = c.base.length ∧ c.n = c.nb + c.rev.length

def val (c : FSrv) : NumV → Option SymE
  | .lit x => some (.lit x)
  | .ref i => bif Nat.blt i c.nb then nth? c.base i
    else bif Nat.blt i c.n then nth? c.rev (c.n - 1 - i) else none

def answer (c : FSrv) (op : NTest) (x y : SymE) : Option (Bool × FSrv) :=
  match c.oracle with
  | q :: o => bif decide (q.op = op ∧ q.a = x ∧ q.b = y) then some (q.r, { c with oracle := o }) else none
  | [] => none

def push (c : FSrv) (e : SymE) : FSrv := { c with rev := e :: c.rev, n := c.n + 1 }

end FSrv

/-- `interpS` over `FSrv`. -/
noncomputable def interpF {α : Type} (t : Free α) : FSrv → Option (α × FSrv) :=
  Free.rec (motive := fun _ => FSrv → Option (α × FSrv))
    (fun a c => some (a, c))
    (fun _ _ => none)
    (fun op a b _ ih c => match c.val a, c.val b with
      | some x, some y => ih c.n (c.push (.bin op x y))
      | _, _ => none)
    (fun op a _ ih c => match c.val a with
      | some x => ih c.n (c.push (.un op x))
      | none => none)
    (fun op a b _ ih c => match c.val a, c.val b with
      | some x, some y => match c.answer op x y with
        | some (r, c') => ih r c'
        | none => none
      | _, _ => none)
    (fun a _ ih c => match c.val a with
      | some (.lit x) => ih x c
      | _ => none) t

/-- `runOkStep` over `FSrv`. -/
noncomputable def runOkFStep (F : Ffi) (ok : St F.S → FSrv → Bool) (ih : St F.S → FSrv → Option (St F.S × FSrv))
    (s : St F.S) (c : FSrv) : Option (St F.S × FSrv) :=
  bif isHalt s.ctl then some (s, c) else
    match interpF (step F s).run c with
    | some (s', c') => bif ok s' c' then s'.rebuild fun s' => ih s' c' else none
    | none => none

noncomputable def runOkF (F : Ffi) (ok : St F.S → FSrv → Bool) (n : Nat) : St F.S → FSrv → Option (St F.S × FSrv) :=
  Nat.rec (motive := fun _ => St F.S → FSrv → Option (St F.S × FSrv)) (fun s c => some (s, c))
    (fun _ ih => runOkFStep F ok ih) n

/-- `runOk`, computed over `FSrv`. -/
noncomputable def runOkS (F : Ffi) (ok : St F.S → FSrv → Bool) (n : Nat) (s : St F.S) (S : SSrv) : Option (St F.S × SSrv) :=
  (runOkF F ok n s (FSrv.ofS S)).map fun p => (p.1, p.2.toS)

namespace FSrv

theorem wf_ofS (S : SSrv) : (ofS S).Wf := ⟨rfl, by simp [ofS]⟩

theorem toS_ofS (S : SSrv) : (ofS S).toS = S := by
  cases S; simp [toS, ofS]

theorem nth?_append_lt' {α : Type} (l r : List α) (i : Nat) (h : i < l.length) : nth? (l ++ r) i = nth? l i := by
  induction l generalizing i with
  | nil => cases h
  | cons a l ih =>
    cases i with
    | zero => rfl
    | succ i => exact ih i (Nat.lt_of_succ_lt_succ h)

theorem nth?_append_ge' {α : Type} (l r : List α) (i : Nat) (h : l.length ≤ i) :
    nth? (l ++ r) i = nth? r (i - l.length) := by
  induction l generalizing i with
  | nil => simp
  | cons a l ih =>
    cases i with
    | zero => cases h
    | succ i =>
      show nth? (l ++ r) i = _
      rw [ih i (Nat.le_of_succ_le_succ h)]
      simp

theorem nth?_none {α : Type} (l : List α) (i : Nat) (h : l.length ≤ i) : nth? l i = none := by
  induction l generalizing i with
  | nil => cases i <;> rfl
  | cons a l ih =>
    cases i with
    | zero => cases h
    | succ i => exact ih i (Nat.le_of_succ_le_succ h)

theorem nth?_reverse {α : Type} (l : List α) (i : Nat) (h : i < l.length) :
    nth? l.reverse i = nth? l (l.length - 1 - i) := by
  induction l generalizing i with
  | nil => cases h
  | cons a l ih =>
    rw [List.reverse_cons]
    by_cases hi : i < l.length
    · rw [nth?_append_lt' _ _ _ (by simpa using hi), ih i hi]
      have e : (a :: l).length - 1 - i = (l.length - 1 - i) + 1 := by simp; omega
      rw [e]; rfl
    · have hie : i = l.length := by simp at h; omega
      subst hie
      rw [nth?_append_ge' _ _ _ (by simp)]
      simp
      rfl

theorem val_eq {c : FSrv} (h : c.Wf) (v : NumV) : c.val v = c.toS.val v := by
  obtain ⟨h1, h2⟩ := h
  cases v with
  | lit x => rfl
  | ref i =>
    show (bif Nat.blt i c.nb then nth? c.base i else bif Nat.blt i c.n then nth? c.rev (c.n - 1 - i) else none) =
      nth? (c.base ++ c.rev.reverse) i
    cases e1 : Nat.blt i c.nb with
    | true =>
      have hi : i < c.base.length := by rw [← h1]; exact Nat.lt_of_succ_le (Nat.le_of_ble_eq_true e1)
      simp only [Bool.cond_true]
      rw [nth?_append_lt' _ _ _ hi]
    | false =>
      have hi : c.base.length ≤ i := by
        rw [← h1]
        exact Nat.le_of_not_lt fun hl => by
          have : Nat.blt i c.nb = true := Nat.ble_eq_true_of_le hl
          rw [e1] at this; cases this
      simp only [Bool.cond_false]
      rw [nth?_append_ge' _ _ _ hi]
      cases e2 : Nat.blt i c.n with
      | true =>
        have hl : i < c.n := Nat.lt_of_succ_le (Nat.le_of_ble_eq_true e2)
        have hr : i - c.base.length < c.rev.reverse.length := by simp; omega
        simp only [Bool.cond_true]
        rw [nth?_reverse _ _ (by simpa using hr)]
        congr 1
        omega
      | false =>
        have hl : c.n ≤ i := Nat.le_of_not_lt fun hl => by
          have : Nat.blt i c.n = true := Nat.ble_eq_true_of_le hl
          rw [e2] at this; cases this
        simp only [Bool.cond_false]
        rw [nth?_none _ _ (by simp; omega)]

theorem length_toS {c : FSrv} (h : c.Wf) : c.toS.tab.length = c.n := by
  obtain ⟨h1, h2⟩ := h
  simp [toS, h1, h2]

theorem wf_push {c : FSrv} (h : c.Wf) (e : SymE) : (c.push e).Wf := by
  obtain ⟨h1, h2⟩ := h
  exact ⟨h1, by simp [push, h2]; omega⟩

theorem toS_push (c : FSrv) (e : SymE) : (c.push e).toS = { c.toS with tab := c.toS.tab ++ [e] } := by
  simp [push, toS]

theorem answer_eq (c : FSrv) (op : NTest) (x y : SymE) :
    (c.answer op x y).map (fun p => (p.1, p.2.toS)) = c.toS.answer op x y := by
  unfold answer SSrv.answer
  show (match c.oracle with
    | q :: o => bif decide (q.op = op ∧ q.a = x ∧ q.b = y) then some (q.r, { c with oracle := o }) else none
    | [] => none).map _ = (match c.oracle with
    | q :: o => bif decide (q.op = op ∧ q.a = x ∧ q.b = y) then some (q.r, { c.toS with oracle := o }) else none
    | [] => none)
  cases c.oracle with
  | nil => rfl
  | cons q o =>
    dsimp only
    cases decide (q.op = op ∧ q.a = x ∧ q.b = y) <;> rfl

theorem answer_wf {c c' : FSrv} (h : c.Wf) {op : NTest} {x y : SymE} {r : Bool}
    (ha : c.answer op x y = some (r, c')) : c'.Wf := by
  unfold answer at ha
  cases ho : c.oracle with
  | nil => simp [ho] at ha
  | cons q o =>
    simp only [ho] at ha
    cases hd : decide (q.op = op ∧ q.a = x ∧ q.b = y) with
    | false => simp [hd] at ha
    | true =>
      simp only [hd, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at ha
      obtain ⟨-, rfl⟩ := ha
      exact h

end FSrv

theorem interpF_eq {α : Type} (t : Free α) (c : FSrv) (h : c.Wf) :
    (interpF t c).map (fun p => (p.1, p.2.toS)) = interpS t c.toS ∧
      ∀ a c', interpF t c = some (a, c') → c'.Wf := by
  induction t generalizing c with
  | pure a => exact ⟨rfl, fun _ _ e => by cases e; exact h⟩
  | fail m => exact ⟨rfl, fun _ _ e => by cases e⟩
  | bin op a b k ih =>
    have e : interpF (.bin op a b k) c = (match c.val a, c.val b with
      | some x, some y => interpF (k c.n) (c.push (.bin op x y))
      | _, _ => none) := rfl
    rw [e, interpS_bin, ← FSrv.val_eq h, ← FSrv.val_eq h, FSrv.length_toS h]
    cases c.val a with
    | none => exact ⟨rfl, fun _ _ e => by cases e⟩
    | some x =>
      cases c.val b with
      | none => exact ⟨rfl, fun _ _ e => by cases e⟩
      | some y =>
        have := ih c.n (c.push (.bin op x y)) (FSrv.wf_push h _)
        rw [FSrv.toS_push] at this
        exact this
  | un op a k ih =>
    have e : interpF (.un op a k) c = (match c.val a with
      | some x => interpF (k c.n) (c.push (.un op x))
      | none => none) := rfl
    rw [e, interpS_un, ← FSrv.val_eq h, FSrv.length_toS h]
    cases c.val a with
    | none => exact ⟨rfl, fun _ _ e => by cases e⟩
    | some x =>
      have := ih c.n (c.push (.un op x)) (FSrv.wf_push h _)
      rw [FSrv.toS_push] at this
      exact this
  | test op a b k ih =>
    have e : interpF (.test op a b k) c = (match c.val a, c.val b with
      | some x, some y => match c.answer op x y with
        | some (r, c') => interpF (k r) c'
        | none => none
      | _, _ => none) := rfl
    rw [e, interpS_test, ← FSrv.val_eq h, ← FSrv.val_eq h]
    cases c.val a with
    | none => exact ⟨rfl, fun _ _ e => by cases e⟩
    | some x =>
      cases c.val b with
      | none => exact ⟨rfl, fun _ _ e => by cases e⟩
      | some y =>
        show (match c.answer op x y with
            | some (r, c') => interpF (k r) c'
            | none => none).map _ = (match c.toS.answer op x y with
            | some (r, c') => interpS (k r) c'
            | none => none) ∧ ∀ a c'', (match c.answer op x y with
            | some (r, c') => interpF (k r) c'
            | none => none) = some (a, c'') → c''.Wf
        rw [← FSrv.answer_eq]
        cases ha : c.answer op x y with
        | none => exact ⟨rfl, fun _ _ e => by cases e⟩
        | some p =>
          obtain ⟨r, c'⟩ := p
          exact ih r c' (FSrv.answer_wf h ha)
  | conc a k ih =>
    have e : interpF (.conc a k) c = (match c.val a with
      | some (.lit x) => interpF (k x) c
      | _ => none) := rfl
    rw [e, interpS_conc, ← FSrv.val_eq h]
    cases hv : c.val a with
    | none => exact ⟨rfl, fun _ _ e => by cases e⟩
    | some v =>
      cases v with
      | lit x => exact ih x c h
      | var _ => exact ⟨rfl, fun _ _ e => by cases e⟩
      | bin _ _ _ => exact ⟨rfl, fun _ _ e => by cases e⟩
      | un _ _ => exact ⟨rfl, fun _ _ e => by cases e⟩

theorem runOkF_eq (F : Ffi) {ok : St F.S → SSrv → Bool} {okN : St F.S → FSrv → Bool}
    (hok : ∀ s c, c.Wf → okN s c = ok s c.toS) (n : Nat) (s : St F.S) (c : FSrv) (h : c.Wf) :
    (runOkF F okN n s c).map (fun p => (p.1, p.2.toS)) = runOk F ok n s c.toS := by
  induction n generalizing s c with
  | zero => rfl
  | succ n ih =>
    show (runOkFStep F okN (runOkF F okN n) s c).map _ = runOk F ok (n + 1) s c.toS
    rw [runOk_succ]
    unfold runOkFStep
    cases isHalt s.ctl with
    | true => rfl
    | false =>
      simp only [Bool.cond_false]
      have hi := interpF_eq (step F s).run c h
      rw [← hi.1]
      cases hr : interpF (step F s).run c with
      | none => rfl
      | some p =>
        obtain ⟨s', c'⟩ := p
        simp only [Option.map_some]
        have hw := hi.2 s' c' hr
        rw [hok s' c' hw]
        cases ok s' c'.toS with
        | false => rfl
        | true =>
          simp only [Bool.cond_true, St.rebuild_eq]
          exact ih s' c' hw

/-- **The chunk check**: `runOkS` is `runOk`. -/
theorem runOkS_eq (F : Ffi) {ok : St F.S → SSrv → Bool} {okN : St F.S → FSrv → Bool}
    (hok : ∀ s c, c.Wf → okN s c = ok s c.toS) (n : Nat) (s : St F.S) (S : SSrv) :
    runOkS F okN n s S = runOk F ok n s S := by
  have := runOkF_eq F hok n s (FSrv.ofS S) (FSrv.wf_ofS S)
  rw [FSrv.toS_ofS] at this
  exact this

/-- **A chunk's statement from its check at `runOkS`**, over the acceptance's parameters. -/
theorem runOk_fun_of_runOkS {α β : Type} {F : Ffi} {ok : α → β → St F.S → SSrv → Bool} {okN : α → β → St F.S → FSrv → Bool}
    (hok : ∀ a b s c, FSrv.Wf c → okN a b s c = ok a b s c.toS) {n : Nat} {s : St F.S} {S : SSrv}
    {r : Option (St F.S × SSrv)} (h : (fun a b => runOkS F (okN a b) n s S) = fun _ _ => r) :
    (fun a b => runOk F (ok a b) n s S) = fun _ _ => r :=
  funext fun a => funext fun b => (runOkS_eq F (hok a b) n s S).symm.trans (congrFun (congrFun h a) b)

namespace Disp
open Host.Ts.Sim.BufSim
variable {F : Ffi}

/-- `symOKB` over `FSrv`. -/
noncomputable def symOKN (P : JSP F) (smallN : FSrv → F.S → Name → List Arg → Bool) (s : St F.S) (c : FSrv) (name : Name) (tys args : List Val) : Bool :=
  match interpF (decodeArgs F s tys args).run c with
  | some (some as, c1) => P.okCall s.ffi name as && smallN c1 s.ffi name as &&
    (match interpF (F.call s.ffi name as).run c1 with
    | some (r, c2) => resB c2.n r || resCbB P s c2.n r
    | none => true)
  | _ => true

theorem symOKN_eq (P : JSP F) {smallN : FSrv → F.S → Name → List Arg → Bool}
    (hsm : ∀ c x n a, c.Wf → smallN c x n a = P.smallB c.toS x n a) (s : St F.S) {c : FSrv} (h : c.Wf) (name : Name) (tys args : List Val) :
    symOKN P smallN s c name tys args = symOKB P s c.toS name tys args := by
  unfold symOKN symOKB
  have h1 := interpF_eq (decodeArgs F s tys args).run c h
  rw [← h1.1]
  cases hr : interpF (decodeArgs F s tys args).run c with
  | none => rfl
  | some p =>
    obtain ⟨o, c1⟩ := p
    cases o with
    | none => rfl
    | some as =>
      simp only [Option.map_some]
      have hw1 := h1.2 _ _ hr
      rw [hsm c1 _ _ _ hw1]
      have h2 := interpF_eq (F.call s.ffi name as).run c1 hw1
      rw [← h2.1]
      cases hr2 : interpF (F.call s.ffi name as).run c1 with
      | none => rfl
      | some q =>
        obtain ⟨r, c2⟩ := q
        have hw2 := h2.2 _ _ hr2
        simp only [Option.map_some]
        rw [FSrv.length_toS hw2]

/-- `symCallB` over `FSrv`. -/
noncomputable def symCallN (P : JSP F) (smallN : FSrv → F.S → Name → List Arg → Bool) (s : St F.S) (c : FSrv) (data args : List Val) : Bool :=
  match data with
  | [.str name, .obj ta, .str _] => match s.obj? ta with
    | some oa => match oa.kind with
      | .array tys => frB P ta && allB (argBufB P s c.n) args && boolsPB P tys args && symOKN P smallN s c name tys args
      | _ => false
    | none => false
  | _ => false

theorem symCallN_eq (P : JSP F) {smallN : FSrv → F.S → Name → List Arg → Bool}
    (hsm : ∀ c x n a, c.Wf → smallN c x n a = P.smallB c.toS x n a) (s : St F.S) {c : FSrv} (h : c.Wf) (data args : List Val) :
    symCallN P smallN s c data args = symCallB P s c.toS c.n data args := by
  unfold symCallN symCallB
  simp only [symOKN_eq P hsm s h]
  rfl

/-- The data of a native symbol. -/
def symData {S : Type} (s : St S) : Val → Option (List Val)
  | .obj a => match s.obj? a with
    | some o => match o.kind with
      | .fn (.native (.ffi .symbol) data) => some data
      | _ => none
    | none => none
  | _ => none

theorem okCallB_sym (P : JSP F) {s : St F.S} {S : SSrv} {n : Nat} {f this : Val} {args data : List Val}
    (h : symData s f = some data) : okCallB P s S n f this args = symCallB P s S n data args := by
  cases f with
  | obj a =>
    unfold symData at h
    unfold okCallB
    dsimp only at h ⊢
    cases ho : s.obj? a with
    | none => rw [ho] at h; cases h
    | some o =>
      rw [ho] at h
      dsimp only at h ⊢
      split at h
      · rename_i data' he
        rw [he]
        cases h
        rfl
      · cases h
  | _ => cases h

/-- `okCallB` over `FSrv`. -/
noncomputable def okCallN (P : JSP F) (smallN : FSrv → F.S → Name → List Arg → Bool) (s : St F.S) (c : FSrv) (f this : Val) (args : List Val) : Bool :=
  match symData s f with
  | some data => symCallN P smallN s c data args
  | none => okCallB P s c.toS c.n f this args

theorem okCallN_eq (P : JSP F) {smallN : FSrv → F.S → Name → List Arg → Bool}
    (hsm : ∀ c x n a, c.Wf → smallN c x n a = P.smallB c.toS x n a) (s : St F.S) {c : FSrv} (h : c.Wf) (f this : Val) (args : List Val) :
    okCallN P smallN s c f this args = okCallB P s c.toS c.n f this args := by
  unfold okCallN
  cases hd : symData s f with
  | none => rfl
  | some data =>
    dsimp only
    rw [symCallN_eq P hsm s h, okCallB_sym P hd]

/-- `okCtl` over `FSrv`. -/
noncomputable def okCtlN (P : JSP F) (smallN : FSrv → F.S → Name → List Arg → Bool) (s : St F.S) (c : FSrv) : Bool :=
  match s.ctl with
  | .ev e env => okEv P s e env
  | .ex st _ => okEx s st
  | .ret v => okRet P s c.n v s.stack
  | .abr _ => okAbr P s c.n s.stack
  | .call f this args => okCallN P smallN s c f this args
  | .construct f args nt => okConsB P s c.toS c.n f args nt
  | .bind p v env mode _ => okBind P s c.n p v env mode
  | .short => true
  | .halt _ => true

theorem okCtlN_eq (P : JSP F) {smallN : FSrv → F.S → Name → List Arg → Bool}
    (hsm : ∀ c x n a, c.Wf → smallN c x n a = P.smallB c.toS x n a) (s : St F.S) {c : FSrv} (h : c.Wf) :
    okCtlN P smallN s c = okCtl P s c.toS := by
  unfold okCtlN okCtl
  cases s.ctl <;> simp only [FSrv.length_toS h, okCallN_eq P hsm s h]

/-- `okJSJ` over `FSrv`. -/
noncomputable def okJSJN (P : JSP F) (okBack : F.S → Arg → Bool) (D0 : Nat) (smallN : FSrv → F.S → Name → List Arg → Bool) (s : St F.S) (c : FSrv) : Bool :=
  ((Nat.blt s.next nextMax && okCtlN P smallN s c) || cbRetB P okBack s c.toS || moreB P s c.toS) || bigJsCallB s || typedJsB P D0 s c.toS

theorem okJSJN_eq (P : JSP F) (okBack : F.S → Arg → Bool) (D0 : Nat) {smallN : FSrv → F.S → Name → List Arg → Bool}
    (hsm : ∀ c x n a, c.Wf → smallN c x n a = P.smallB c.toS x n a) (s : St F.S) {c : FSrv} (h : c.Wf) :
    okJSJN P okBack D0 smallN s c = okJSJ P okBack D0 s c.toS := by
  unfold okJSJN
  rw [okCtlN_eq P hsm s h]
  rfl

end Disp

namespace Full
open Host.Ts.Sim.G Host.Load.Layers
variable {α : Type}

/-- `refSmallB` over `FSrv`. -/
def refSmallF (VB : Nat → Nat) (c : FSrv) (j : Nat) : Bool :=
  match c.val (.ref j) with
  | some e => match ivlA VB e with
    | some (_, h) => decide (h < 2 ^ 31)
    | none => false
  | none => false

/-- `refGeB` over `FSrv`. -/
def refGeF (VB : Nat → Nat) (c : FSrv) (c0 j : Nat) : Bool :=
  match c.val (.ref j) with
  | some e => match ivl VB e with
    | some (l, h) => decide (c0 ≤ l ∧ h < 2 ^ 31)
    | none => false
  | none => false

theorem refSmallF_eq (VB : Nat → Nat) {c : FSrv} (h : c.Wf) : refSmallF VB c = refSmallB VB c.toS := by
  funext j
  unfold refSmallF refSmallB
  rw [FSrv.val_eq h]
  rfl

theorem refGeF_eq (VB : Nat → Nat) {c : FSrv} (h : c.Wf) (c0 j : Nat) : refGeF VB c c0 j = refGeB VB c.toS c0 j := by
  unfold refGeF refGeB
  rw [FSrv.val_eq h]
  rfl

def symShapeSmallF (VB : Nat → Nat) (c : FSrv) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  match Host.Mlx.Ffi.symOf name with
  | some .conv1d => match convRef x args with
    | some (j, c0) => refGeF VB c c0 j
    | none => true
  | some .reshape => (reshRefs x args).all (refSmallF VB c)
  | _ => true

set_option maxRecDepth 1000000 in
theorem symShapeSmallF_eq (VB : Nat → Nat) {c : FSrv} (h : c.Wf) (x : NSt) (name : Name) (args : List Arg) :
    symShapeSmallF VB c x name args = symShapeSmallB VB c.toS x name args := by
  unfold symShapeSmallF symShapeSmallB
  simp only [refGeF_eq VB h, refSmallF_eq VB h]
  generalize Host.Mlx.Ffi.symOf name = o
  cases o with
  | none => rfl
  | some k => cases k <;> rfl

noncomputable def symRunF (c : FSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  match interpF (Host.Load.call (toLoad x) name args).run c with
  | some (some _, _) => true
  | _ => false

theorem symRunF_eq {c : FSrv} (h : c.Wf) (x : FF.S) (name : Name) (args : List Arg) :
    symRunF c x name args = symRunOk c.toS x name args := by
  unfold symRunF symRunOk
  rw [← (interpF_eq (Host.Load.call (toLoad x) name args).run c h).1]
  cases interpF (Host.Load.call (toLoad x) name args).run c with
  | none => rfl
  | some p =>
    obtain ⟨o, c1⟩ := p
    cases o <;> rfl

noncomputable def smallXF (VB : Nat → Nat) (c : FSrv) (x : Host.Load.LSt) (name : Name) (args : List Arg) : Bool :=
  (smallRefs x.mlx name args).all (refSmallF VB c) && (smallRefsX x.mlx name args).all (refSmallF VB c)

theorem smallXF_eq (VB : Nat → Nat) {c : FSrv} (h : c.Wf) (x : Host.Load.LSt) (name : Name) (args : List Arg) :
    smallXF VB c x name args = smallXB VB c.toS x name args := by
  unfold smallXF smallXB smallLoadB
  rw [refSmallF_eq VB h]

noncomputable def smallFXF (VB : Nat → Nat) (c : FSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  smallXF VB c (toLoad x) name args && (!isSymShape name || symRunF c x name args)

theorem smallFXF_eq (VB : Nat → Nat) {c : FSrv} (h : c.Wf) (x : FF.S) (name : Name) (args : List Arg) :
    smallFXF VB c x name args = smallFXB VB c.toS x name args := by
  unfold smallFXF smallFXB
  rw [smallXF_eq VB h, symRunF_eq h]

noncomputable def cloRunF (c : FSrv) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  match interpF (Host.Mlx.Ffi.call x name args).run c with
  | some (none, _) => false
  | _ => true

theorem cloRunF_eq {c : FSrv} (h : c.Wf) (x : NSt) (name : Name) (args : List Arg) :
    cloRunF c x name args = cloRunB c.toS x name args := by
  unfold cloRunF cloRunB
  rw [← (interpF_eq (Host.Mlx.Ffi.call x name args).run c h).1]
  cases interpF (Host.Mlx.Ffi.call x name args).run c with
  | none => rfl
  | some p =>
    obtain ⟨o, c1⟩ := p
    cases o <;> rfl

noncomputable def cloSmallF (VB : Nat → Nat) (c : FSrv) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  !cloSym x name args || ((cloRefs x args).all (refSmallF VB c) && cloRunF c x name args)

theorem cloSmallF_eq (VB : Nat → Nat) {c : FSrv} (h : c.Wf) (x : NSt) (name : Name) (args : List Arg) :
    cloSmallF VB c x name args = cloSmallB VB c.toS x name args := by
  unfold cloSmallF cloSmallB
  rw [refSmallF_eq VB h, cloRunF_eq h]

/-- `smallFSB` over `FSrv`. -/
noncomputable def smallFSF (VB : Nat → Nat) (c : FSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  bif G.symPath (mlxOf x) name args then symShapeSmallF VB c (mlxOf x) name args
  else smallFXF VB c x name args && cloSmallF VB c (mlxOf x) name args

theorem smallFSF_eq (VB : Nat → Nat) {c : FSrv} (h : c.Wf) (x : FF.S) (name : Name) (args : List Arg) :
    smallFSF VB c x name args = smallFSB VB c.toS x name args := by
  unfold smallFSF smallFSB
  rw [symShapeSmallF_eq VB h, smallFXF_eq VB h, cloSmallF_eq VB h]

noncomputable def aneRunF (c : FSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  match interpF (Host.Load.Ane.call x.1.1 name args).run c with
  | some (a, _) => a.isSome
  | none => true

theorem aneRunF_eq {c : FSrv} (h : c.Wf) (x : FF.S) (name : Name) (args : List Arg) :
    aneRunF c x name args = aneRunOk c.toS x name args := by
  unfold aneRunF aneRunOk
  rw [← (interpF_eq (Host.Load.Ane.call x.1.1 name args).run c h).1]
  cases interpF (Host.Load.Ane.call x.1.1 name args).run c with
  | none => rfl
  | some p => rfl

/-- `smallFX2B` over `FSrv`. -/
noncomputable def smallFX2F (VB : Nat → Nat) (c : FSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  bif (bridgeOf x).active then smallFXF VB c x name args && (!isSymShape name || aneRunF c x name args) &&
    cloSmallF VB c (mlxOf x) name args
  else smallFSF VB c x name args

theorem smallFX2F_eq (VB : Nat → Nat) {c : FSrv} (h : c.Wf) (x : FF.S) (name : Name) (args : List Arg) :
    smallFX2F VB c x name args = smallFX2B VB c.toS x name args := by
  unfold smallFX2F smallFX2B
  rw [smallFXF_eq VB h, aneRunF_eq h, cloSmallF_eq VB h, smallFSF_eq VB h]

end Full

end Host.Ts.Sim

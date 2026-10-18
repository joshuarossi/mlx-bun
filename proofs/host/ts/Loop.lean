import host.ts.Chunk
namespace Host.Ts

/-! # Oracle framing and loop composition

A symbolic run consumes its oracle from the front, so a run that consumes
`o` also runs with `o ++ r` and leaves `r`: chains discovered separately
(their own oracles) compose into one run whose oracle is the concatenation,
and whose correctness at `ρ` is the conjunction (`good_append`).

`host_chain_abs_run` composes the chunks of an abstracted chain (`Chunk`)
into one run for every value of the abstracted array.

`loop_runs` is the induction a generation loop needs: per-iteration runs
from states satisfying an invariant compose to a run of every iteration. The
invariant is the caller's: discharging its step is where a per-iteration
theorem is instantiated. -/

theorem answer_append (S : SSrv) (r : List Ans) {op : NTest} {x y : SymE} {b : Bool} {S' : SSrv}
    (h : S.answer op x y = some (b, S')) :
    ({ S with oracle := S.oracle ++ r } : SSrv).answer op x y = some (b, { S' with oracle := S'.oracle ++ r }) := by
  unfold SSrv.answer at *
  match ho : S.oracle, h with
  | [], h => simp [ho] at h
  | q :: o, h =>
    by_cases hq : q.op = op ∧ q.a = x ∧ q.b = y
    · simp only [ho, hq, and_self, decide_true, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      simp [ho, hq]
    · simp [ho, hq] at h

theorem interpS_append {α : Type} (r : List Ans) (t : Free α) :
    ∀ (S : SSrv) (a : α) (S' : SSrv), interpS t S = some (a, S') →
      interpS t { S with oracle := S.oracle ++ r } = some (a, { S' with oracle := S'.oracle ++ r }) := by
  induction t with
  | pure x =>
    intro S a S' h
    simp only [interpS_pure, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h; rfl
  | fail m => intro S a S' h; simp [interpS_fail] at h
  | bin op x y k ih =>
    intro S a S' h
    match hx : S.val x, hy : S.val y with
    | some ex, some ey =>
      simp only [interpS_bin, hx, hy] at h
      have := ih _ _ _ _ h
      have hx' : ({ S with oracle := S.oracle ++ r } : SSrv).val x = some ex := by simpa [SSrv.val] using hx
      have hy' : ({ S with oracle := S.oracle ++ r } : SSrv).val y = some ey := by simpa [SSrv.val] using hy
      simp only [interpS_bin, hx', hy']
      exact this
    | none, _ => simp [interpS_bin, hx] at h
    | some _, none => simp [interpS_bin, hx, hy] at h
  | un op x k ih =>
    intro S a S' h
    match hx : S.val x with
    | some ex =>
      simp only [interpS_un, hx] at h
      have := ih _ _ _ _ h
      have hx' : ({ S with oracle := S.oracle ++ r } : SSrv).val x = some ex := by simpa [SSrv.val] using hx
      simp only [interpS_un, hx']
      exact this
    | none => simp [interpS_un, hx] at h
  | test op x y k ih =>
    intro S a S' h
    match hx : S.val x, hy : S.val y with
    | none, _ => simp [interpS_test, hx] at h
    | some _, none => simp [interpS_test, hx, hy] at h
    | some ex, some ey =>
      simp only [interpS_test, hx, hy] at h
      match ha : S.answer op ex ey with
      | none => simp [ha] at h
      | some (b, S1) =>
        simp only [ha] at h
        have h1 := ih b S1 a S' h
        have h2 := answer_append S r ha
        have hx' : ({ S with oracle := S.oracle ++ r } : SSrv).val x = some ex := by simpa [SSrv.val] using hx
        have hy' : ({ S with oracle := S.oracle ++ r } : SSrv).val y = some ey := by simpa [SSrv.val] using hy
        simp only [interpS_test, hx', hy', h2]
        exact h1
  | conc x k ih =>
    intro S a S' h
    cases hx : S.val x with
    | none => simp [interpS_conc, hx] at h
    | some e =>
      cases e with
      | lit v =>
        simp only [interpS_conc, hx] at h
        have hx' : ({ S with oracle := S.oracle ++ r } : SSrv).val x = some (.lit v) := by simpa [SSrv.val] using hx
        simp only [interpS_conc, hx']
        exact ih v _ _ _ h
      | _ => simp [interpS_conc, hx] at h

/-- A symbolic run with more oracle answers after its own leaves them unread. -/
theorem runS_append (F : Ffi) (r : List Ans) :
    ∀ (n : Nat) (s s' : St F.S) (S S' : SSrv), runS F n s S = some (s', S') →
      runS F n s { S with oracle := S.oracle ++ r } = some (s', { S' with oracle := S'.oracle ++ r }) := by
  intro n
  induction n with
  | zero =>
    intro s s' S S' h
    simp only [runS, runWith_zero, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h; rfl
  | succ n ih =>
    intro s s' S S' h
    cases hh : isHalt s.ctl
    · simp only [runS, runWith_succ, hh, Bool.cond_false] at h
      cases hs : interpS (step F s).run S with
      | none => simp [hs] at h
      | some p =>
        obtain ⟨s1, S1⟩ := p
        simp only [hs, St.rebuild_eq] at h
        have h1 := interpS_append r _ S s1 S1 hs
        simp only [runS, runWith_succ, hh, Bool.cond_false, h1, St.rebuild_eq]
        exact ih s1 s' S1 S' h
    · simp only [runS, runWith_succ, hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      simp [runS, runWith_succ, hh]

theorem good_append (ρ : Nat → F64) (o r : List Ans) : Good ρ (o ++ r) ↔ Good ρ o ∧ Good ρ r := by
  simp only [Good, List.mem_append]
  exact ⟨fun h => ⟨fun q m => h q (.inl m), fun q m => h q (.inr m)⟩,
    fun ⟨h1, h2⟩ q m => m.elim (h1 q) (h2 q)⟩

/-- Two chains, each with its own oracle (the first's final oracle empty), compose. -/
theorem runS_seq (F : Ffi) {m n : Nat} {s₀ s₁ s₂ : St F.S} {tab₀ tab₁ tab₂ : List SymE} {o₁ o₂ : List Ans}
    (h₁ : runS F m s₀ ⟨tab₀, o₁⟩ = some (s₁, ⟨tab₁, []⟩)) (h₂ : runS F n s₁ ⟨tab₁, o₂⟩ = some (s₂, ⟨tab₂, []⟩)) :
    runS F (m + n) s₀ ⟨tab₀, o₁ ++ o₂⟩ = some (s₂, ⟨tab₂, []⟩) := by
  have := runS_append F o₂ m s₀ s₁ _ _ h₁
  exact runS_trans F this h₂

/-! ## Loops -/

/-- Iterations `t < T` of `k t` steps each, every one taking a state satisfying `inv t` to one
satisfying `inv (t + 1)`, compose into one run of all `T` iterations. -/
theorem loop_runs (F : Ffi) {Srv : Type} (interp : Free (St F.S) → Srv → Option (St F.S × Srv))
    (k : Nat → Nat) (inv : Nat → St F.S → Srv → Prop)
    (hstep : ∀ t s c, inv t s c → ∃ s' c', runWith F interp (k t) s c = some (s', c') ∧ inv (t + 1) s' c') :
    ∀ (T : Nat) (s : St F.S) (c : Srv), inv 0 s c →
      ∃ s' c', runWith F interp ((List.range T).foldl (fun a t => a + k t) 0) s c = some (s', c') ∧ inv T s' c'
  | 0, s, c, h => ⟨s, c, rfl, h⟩
  | T + 1, s, c, h => by
    obtain ⟨s1, c1, h1, i1⟩ := loop_runs F interp k inv hstep T s c h
    obtain ⟨s2, c2, h2, i2⟩ := hstep T s1 c1 i1
    refine ⟨s2, c2, ?_, i2⟩
    rw [List.range_succ, List.foldl_append, List.foldl_cons, List.foldl_nil, runWith_add, h1]
    exact h2


open Lean Elab Command Meta
/-- `host_chain_abs_run P`: `P.absRun : ∀ fw, runS P.F (kᵢ + … + kⱼ₋₁) (P.a<i> fw) P.S<i> = some (P.a<j> fw, P.S<j>)`
from the abstracted chunks. -/
elab "host_chain_abs_run " p:ident : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let ks ← unsafe evalConst (List Nat) (pre ++ `ks)
  let some (.defnInfo d) := (← getEnv).find? (pre ++ `abs) | throwError "no {pre}.abs"
  let #[_, _, .lit (.natVal i), .lit (.natVal j)] := d.value.getAppArgs | throwError "{pre}.abs is not a pair of literals"
  let F := mkConst (pre ++ `F)
  let valL := mkApp (mkConst ``List [.zero]) (mkConst ``Val)
  let aN (k : Nat) := mkConst (pre ++ Name.mkSimple ("a" ++ toString k))
  let sN (k : Nat) := mkConst (pre ++ Name.mkSimple ("S" ++ toString k))
  let fw := Lean.Expr.bvar 0
  let mut fuel := ks[i]!
  let mut pf := mkApp (mkConst (pre ++ Name.mkSimple ("ac" ++ toString i))) fw
  for k in [i + 1:j] do
    let n := ks[k]!
    pf := mkAppN (mkConst ``runS_trans) #[F, mkRawNatLit fuel, mkRawNatLit n, mkApp (aN i) fw, mkApp (aN k) fw,
      mkApp (aN (k + 1)) fw, sN i, sN k, sN (k + 1), pf, mkApp (mkConst (pre ++ Name.mkSimple ("ac" ++ toString k))) fw]
    fuel := fuel + n
  let stTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) F)
  let pTy := mkApp2 (mkConst ``Prod [.zero, .zero]) stTy (mkConst ``SSrv)
  let oTy := mkApp (mkConst ``Option [.zero]) pTy
  let body := mkApp3 (mkConst ``Eq [.succ .zero]) oTy (mkAppN (mkConst ``runS) #[F, mkRawNatLit fuel, mkApp (aN i) fw, sN i])
    (mkApp2 (mkConst ``Option.some [.zero]) pTy (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) stTy (mkConst ``SSrv) (mkApp (aN j) fw) (sN j)))
  addDecl (.thmDecl { name := pre ++ `absRun, levelParams := [], type := .forallE `fw valL body .default, value := .lam `fw valL pf .default })


end Host.Ts

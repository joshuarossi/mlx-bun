import host.ts.RenameParametricForInit
import host.ts.RenameParametricForControl
import host.ts.RenameParametricLiteral
import host.ts.RenameRouteComposition

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

def mapIndexResult {S : Type} (s : St S) (i n : Name) (update : Option Expr) (body : Stmt)
    (env : Env) (value : Val) : St S :=
  let zero : Val := .num (.lit (.zero false))
  let s' := (((s.alloc (.cell none)).2.setCell s.next zero).alloc (.cell (some zero))).2
  let env' := (i,s.next+1)::env
  {s' with ctl := .ret value,stack := (.e (.binR .lt zero)::
    .lp (.forBody (some (.bin .lt (.id i) (.id n))) update body env' [i] [])::s.stack)}

theorem lookupEnv_head (name : Name) (a : Nat) (env : Env) :
    lookupEnv name ((name,a)::env) = some a := by
  simp only [lookupEnv,Nat.beq_refl,brec]

theorem lookupEnv_skip (name other : Name) (a : Nat) (env : Env) (hne : nameEq name other = false) :
    lookupEnv name ((other,a)::env) = lookupEnv name env := by
  change (brec (nameEq name other) (some a) (lookupEnv name env)) = _
  rw [hne]

/-- Execute the original first for-test preparation. The literal zero is
parsed from the program, stored, copied into the iteration cell, and read
back; the array length is read from its untouched pre-existing binding. -/
theorem map_index_run (F : Ffi) (s : St F.S) (C : CSrv) (i n : Name) (update : Option Expr)
    (body : Stmt) (env : Env) (a : Nat) (value : Val)
    (hc : s.ctl = .ex (.for_ (some (.decl .let_ [(.id i,some (.lit (.num ['0'])))]))
      (some (.bin .lt (.id i) (.id n))) update body) env)
    (hne : nameEq n i = false) (hn : lookupEnv n env = some a)
    (hv : s.heap.get a = some (.cell (some value))) (ha : a < s.next) (bound : s.next+1 < 2^64) :
    runC F 10 s C = some (mapIndexResult s i n update body env value,C) := by
  let zero : Val := .num (.lit (.zero false))
  let test : Option Expr := some (.bin .lt (.id i) (.id n))
  let env1 := (i,s.next)::env
  let env2 := (i,s.next+1)::env
  let tail : List Frame := .lp (.forTest true test update body env1 [i] [])::s.stack
  let s1 := forLetState s i (.lit (.num ['0'])) test update body env
  let s2 := s1.ret zero
  let s3 := declarationValue {s2 with stack := tail} .let_ (.id i) [] env1 zero
  let s4 := (s3.setCell s.next zero).ret .undef
  let s5 := {s4 with stack := tail}.ret .undef
  let s6 := forTestState (({s5 with stack := s.stack}).alloc (.cell (some zero))).2 test update body env2 [i] []
  let s7 := (s6.push (.e (.binL .lt (.id n) env2))).go (.ev (.id i) env2)
  let s8 := s7.ret zero
  let frames : List Frame := .lp (.forBody test update body env2 [i] [])::s.stack
  let s9 := binaryLeftState {s8 with stack := frames} .lt (.id n) env2 zero
  let s10 := s9.ret value
  have b0 : s.next < 2^64 := by omega
  have hget0 : s5.heap.get s.next = some (.cell (some zero)) := by
    change ((s.heap.set s.next (.cell none)).set s.next (.cell (some zero))).get s.next = _
    rw [PTrie.get_set_u64 _ _ _ b0]
    simp only [ite_true]
  have hget1 : s7.heap.get (s.next+1) = some (.cell (some zero)) := by
    change (((s.heap.set s.next (.cell none)).set s.next (.cell (some zero))).set (s.next+1) (.cell (some zero))).get (s.next+1) = _
    rw [PTrie.get_set_u64 _ _ _ bound]
    simp only [ite_true]
  have hgetn : s9.heap.get a = some (.cell (some value)) := by
    change (((s.heap.set s.next (.cell none)).set s.next (.cell (some zero))).set (s.next+1) (.cell (some zero))).get a = _
    simp only [PTrie.get_set_u64 _ _ _ bound,PTrie.get_set_u64 _ _ _ b0,
      ite_eq_right (Nat.ne_of_lt ha),ite_eq_right (show a ≠ s.next+1 by omega),hv]
  have h0 : step F s = M.pure s1 := step_for_let_eq F s i (.lit (.num ['0'])) test update body env hc
  have h1 : step F s1 = M.pure s2 := step_literal_eq F s1 (.num ['0']) zero env1
    (.number ['0'] (.zero false) (by rfl)) rfl
  have h2 : step F s2 = M.pure s3 := step_declaration_value_eq F s2 zero .let_ (.id i) [] env1 tail rfl rfl rfl
  have h3 : step F s3 = M.pure s4 := step_bind_init_eq F s3 i zero env1 .let_ s.next rfl (lookupEnv_head i s.next env)
  have h4 : step F s4 = M.pure s5 := step_declaration_next_eq F s4 .undef .let_ [] env1 tail rfl rfl
  have h5 : step F s5 = M.pure s6 := by
    rw [step_for_copy_eq F s5 .undef test update body env1 i [] s.stack rfl rfl]
    rw [nextIter_one_eq F {s5 with stack := s.stack} i env1 s.next zero
      (lookupEnv_head i s.next env) hget0]
    rfl
  have h6 : step F s6 = M.pure s7 := step_descent_eq F s6 (.binary .lt (.id i) (.id n)) env2 rfl
  have h7 : step F s7 = M.pure s8 := step_variable_eq F s7 i env2 (s.next+1) zero rfl
    (lookupEnv_head i (s.next+1) env) hget1
  have h8 : step F s8 = M.pure s9 := step_binary_left_eq F s8 zero .lt (.id n) env2 frames rfl rfl
  have h9 : step F s9 = M.pure s10 := step_variable_eq F s9 n env2 a value rfl
    ((lookupEnv_skip n i (s.next+1) env hne).trans hn) hgetn
  change runC F 10 s C = some (s10,C)
  apply runC_cons F 9 s s1 s10 C C C (by rw [hc]; rfl) (by rw [h0]; rfl)
  apply runC_cons F 8 s1 s2 s10 C C C rfl (by rw [h1]; rfl)
  apply runC_cons F 7 s2 s3 s10 C C C rfl (by rw [h2]; rfl)
  apply runC_cons F 6 s3 s4 s10 C C C rfl (by rw [h3]; rfl)
  apply runC_cons F 5 s4 s5 s10 C C C rfl (by rw [h4]; rfl)
  apply runC_cons F 4 s5 s6 s10 C C C rfl (by rw [h5]; rfl)
  apply runC_cons F 3 s6 s7 s10 C C C rfl (by rw [h6]; rfl)
  apply runC_cons F 2 s7 s8 s10 C C C rfl (by rw [h7]; rfl)
  apply runC_cons F 1 s8 s9 s10 C C C rfl (by rw [h8]; rfl)
  apply runC_cons F 0 s9 s10 s10 C C C rfl (by rw [h9]; rfl)
  rfl

theorem step_block_next_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (st : Stmt) (rest : List Stmt) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .s (.block (st::rest) env)::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.block_view] at hf
  rw [step_block_next_eq F s v st rest (R.env env) fs hc hf] at run
  have hr := congrArg Prod.fst (Option.some.inj run)
  exact (congrArg St.heap hr).symm

end Host.Ts.Owned.Parametric

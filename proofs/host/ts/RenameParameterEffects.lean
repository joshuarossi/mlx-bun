import host.ts.RenameParametricParameterStep
import host.ts.RenameRouteComposition

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem allocCells_heap_below {S : Type} (s : St S) (names : List Name) (env : Env)
    (a : Nat) (ha : a < s.next) (hb : s.next + names.length ≤ 2^64) :
    (allocCells s names env).2.heap.get a = s.heap.get a := by
  induction names generalizing s env with
  | nil => rfl
  | cons n ns ih =>
    have hn : s.next < 2^64 := by simp only [List.length_cons] at hb; omega
    have hab : a < (s.alloc (.cell none)).2.next := by change a < s.next+1; omega
    have hbb : (s.alloc (.cell none)).2.next + ns.length ≤ 2^64 := by
      change s.next+1+ns.length ≤ 2^64
      simp only [List.length_cons] at hb; omega
    change (allocCells (s.alloc (.cell none)).2 ns ((n,s.next)::env)).2.heap.get a = _
    rw [ih _ _ hab hbb]
    simp only [St.alloc,PTrie.get_set_u64 _ _ _ hn,ite_eq_right (Nat.ne_of_lt ha)]

theorem enterBlock_heap_below {S : Type} (s : St S) (ss : List Stmt) (env : Env)
    (a : Nat) (ha : a < s.next) (hb : s.next + (blockNames ss).length ≤ 2^64)
    (hi : noInitFunctions ss = true) : (enterBlock s ss env).heap.get a = s.heap.get a := by
  change (hoist s ss env).2.heap.get a = _
  rw [hoist_inert_eq s env ss hi]
  exact allocCells_heap_below s (blockNames ss) env a ha hb

/-- Exact effects of the original parameter scheduler for two supplied values
and one variable default. This preserves the identity of each supplied value;
in particular a fixed numeric annotation is not weakened to `NumberRoles`. -/
theorem three_parameters_run (F : Ffi) (s : St F.S) (C : CSrv)
    (fn : Func) (fnName : Option Name) (fnParams : List Pat) (ss : List Stmt)
    (n₁ n₂ n₃ ng : Name) (env : Env) (a b c g : Nat) (x y z initial : Val) (fs : List Frame)
    (hc : s.ctl = .ret initial)
    (hf : s.stack = .k (.params fn [.id n₁,.id n₂,.dflt (.id n₃) (.id ng)] [x,y] env)::fs)
    (hfn : fn = .mk fnName fnParams none (.block ss) false false [])
    (h₁ : lookupEnv n₁ env = some a) (h₂ : lookupEnv n₂ env = some b)
    (h₃ : lookupEnv n₃ env = some c) (hg : lookupEnv ng env = some g)
    (hgv : s.heap.get g = some (.cell (some z)))
    (ga : g ≠ a) (gb : g ≠ b) (abound : a < 2^64) (bbound : b < 2^64) :
    runC F 9 s C = some
      (enterBlock {((s.setCell a x).setCell b y).setCell c z with ctl := .ret .undef, stack := fs} ss env,C) := by
  let s1 := parameterArgument {s with stack := fs} fn n₁ [.id n₂,.dflt (.id n₃) (.id ng)] [x,y] env
  let s2 := (s1.setCell a x).ret .undef
  let s3 := parameterArgument {s2 with stack := fs} fn n₂ [.dflt (.id n₃) (.id ng)] [y] env
  let s4 := (s3.setCell b y).ret .undef
  let s5 := parameterDefault {s4 with stack := fs} fn (.id n₃) (.id ng) [] [] env
  let s6 := s5.ret z
  let s7 := parameterDefaultReturn {s6 with stack := fs} fn (.id n₃) [] [] env z
  let s8 := (s7.setCell c z).ret .undef
  let s9 := enterBlock {s8 with stack := fs} ss env
  have hstep0 : step F s = M.pure s1 := step_parameter_id_eq F s initial fn n₁ _ [x,y] env fs hc hf
  have hstep1 : step F s1 = M.pure s2 := step_bind_init_eq F s1 n₁ x env .let_ a rfl h₁
  have hstep2 : step F s2 = M.pure s3 := step_parameter_id_eq F s2 .undef fn n₂ _ [y] env fs rfl rfl
  have hstep3 : step F s3 = M.pure s4 := step_bind_init_eq F s3 n₂ y env .let_ b rfl h₂
  have hstep4 : step F s4 = M.pure s5 := step_parameter_default_eq F s4 .undef fn (.id n₃) (.id ng)
    [] [] env fs rfl rfl rfl
  have hg5 : s5.heap.get g = some (.cell (some z)) := by
    change ((s.heap.set a (.cell (some x))).set b (.cell (some y))).get g = _
    simp only [PTrie.get_set_u64 _ _ _ abound,PTrie.get_set_u64 _ _ _ bbound,ite_eq_right ga,ite_eq_right gb,hgv]
  have hstep5 : step F s5 = M.pure s6 := step_variable_eq F s5 ng env g z rfl hg hg5
  have hstep6 : step F s6 = M.pure s7 := step_parameter_default_return_eq F s6 z fn (.id n₃) [] [] env fs rfl rfl
  have hstep7 : step F s7 = M.pure s8 := step_bind_init_eq F s7 n₃ z env .let_ c rfl h₃
  have hstep8 : step F s8 = M.pure s9 := step_parameter_body_eq F s8 .undef fnName fnParams ss [] env fs rfl
    (by change .k (.params fn [] [] env)::fs = _; rw [hfn])
  change runC F 9 s C = some (s9,C)
  apply runC_cons F 8 s s1 s9 C C C (by rw [hc]; rfl) (by rw [hstep0]; rfl)
  apply runC_cons F 7 s1 s2 s9 C C C rfl (by rw [hstep1]; rfl)
  apply runC_cons F 6 s2 s3 s9 C C C rfl (by rw [hstep2]; rfl)
  apply runC_cons F 5 s3 s4 s9 C C C rfl (by rw [hstep3]; rfl)
  apply runC_cons F 4 s4 s5 s9 C C C rfl (by rw [hstep4]; rfl)
  apply runC_cons F 3 s5 s6 s9 C C C rfl (by rw [hstep5]; rfl)
  apply runC_cons F 2 s6 s7 s9 C C C rfl (by rw [hstep6]; rfl)
  apply runC_cons F 1 s7 s8 s9 C C C rfl (by rw [hstep7]; rfl)
  apply runC_cons F 0 s8 s9 s9 C C C rfl (by rw [hstep8]; rfl)
  rfl

theorem three_parameters_axis {S : Type} (s : St S) (ss : List Stmt) (env : Env)
    (a b c : Nat) (x y z : Val) (fs : List Frame)
    (hb : b < s.next) (bound : s.next + (blockNames ss).length ≤ 2^64)
    (cbound : c < 2^64) (bc : b ≠ c) (hi : noInitFunctions ss = true) :
    (enterBlock {((s.setCell a x).setCell b y).setCell c z with ctl := .ret .undef, stack := fs} ss env).heap.get b =
      some (.cell (some y)) := by
  rw [enterBlock_heap_below {((s.setCell a x).setCell b y).setCell c z with ctl := .ret .undef, stack := fs}
    ss env b (by exact hb) (by exact bound) hi]
  have bbound : b < 2^64 := Nat.lt_of_lt_of_le hb (Nat.le_trans (Nat.le_add_right _ _) bound)
  simp only [St.setCell,PTrie.get_set_u64 _ _ _ cbound,PTrie.get_set_u64 _ _ _ bbound,
    ite_eq_right bc,ite_true]

end Host.Ts.Owned.Parametric

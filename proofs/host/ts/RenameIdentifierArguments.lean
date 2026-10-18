import host.ts.RenameRouteComposition
import host.ts.RenameParametricVariables
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

def cellValueAt {S : Type} (s : St S) (a : Nat) : Val :=
  match s.heap.get a with
  | some (.cell (some v)) => v
  | _ => .undef

theorem cellValueAt_heap_at {S : Type} (s t : St S) (a : Nat)
    (hh : t.heap.get a = s.heap.get a) : cellValueAt t a = cellValueAt s a := by
  simp only [cellValueAt,hh]

/-- Four identifier arguments are evaluated by the original eight host
steps, retaining their exact cell values in left-to-right argument order. -/
theorem run_identifier_arguments4 (F : Ffi) (s : St F.S) (C : CSrv)
    (fn this : Val) (n₁ n₂ n₃ n₄ : Name) (a₁ a₂ a₃ a₄ : Nat)
    (v₁ v₂ v₃ v₄ : Val) (env : Env) (fs : List Frame)
    (hc : s.ctl = .ev (.id n₁) env)
    (hf : s.stack = .c (.args 0 fn this [] [.expr (.id n₂),.expr (.id n₃),.expr (.id n₄)] env)::fs)
    (he₁ : lookupEnv n₁ env = some a₁) (he₂ : lookupEnv n₂ env = some a₂)
    (he₃ : lookupEnv n₃ env = some a₃) (he₄ : lookupEnv n₄ env = some a₄)
    (hv₁ : s.heap.get a₁ = some (.cell (some v₁))) (hv₂ : s.heap.get a₂ = some (.cell (some v₂)))
    (hv₃ : s.heap.get a₃ = some (.cell (some v₃))) (hv₄ : s.heap.get a₄ = some (.cell (some v₄))) :
    runC F 8 s C = some (({s with stack := fs}.go (.call fn this [v₁,v₂,v₃,v₄])),C) := by
  let s₁ := s.ret v₁
  let s₂ := ({s with stack := .c (.args 0 fn this [v₁] [.expr (.id n₃),.expr (.id n₄)] env)::fs}).go (.ev (.id n₂) env)
  let s₃ := s₂.ret v₂
  let s₄ := ({s with stack := .c (.args 0 fn this [v₂,v₁] [.expr (.id n₄)] env)::fs}).go (.ev (.id n₃) env)
  let s₅ := s₄.ret v₃
  let s₆ := ({s with stack := .c (.args 0 fn this [v₃,v₂,v₁] [] env)::fs}).go (.ev (.id n₄) env)
  let s₇ := s₆.ret v₄
  let s₈ := {s with stack := fs}.go (.call fn this [v₁,v₂,v₃,v₄])
  have h₀ : interpC (step F s).run C = some (s₁,C) := by rw [step_variable_eq F s n₁ env a₁ v₁ hc he₁ hv₁]; rfl
  have h₁ : interpC (step F s₁).run C = some (s₂,C) := by
    rw [step_argument_eq F s₁ v₁ 0 fn this [] _ env fs rfl (by exact hf) (by decide)]
    rfl
  have h₂ : interpC (step F s₂).run C = some (s₃,C) := by rw [step_variable_eq F s₂ n₂ env a₂ v₂ rfl he₂ hv₂]; rfl
  have h₃ : interpC (step F s₃).run C = some (s₄,C) := by
    rw [step_argument_eq F s₃ v₂ 0 fn this [v₁] _ env fs rfl rfl (by decide)]
    rfl
  have h₄ : interpC (step F s₄).run C = some (s₅,C) := by rw [step_variable_eq F s₄ n₃ env a₃ v₃ rfl he₃ hv₃]; rfl
  have h₅ : interpC (step F s₅).run C = some (s₆,C) := by
    rw [step_argument_eq F s₅ v₃ 0 fn this [v₂,v₁] _ env fs rfl rfl (by decide)]
    rfl
  have h₆ : interpC (step F s₆).run C = some (s₇,C) := by rw [step_variable_eq F s₆ n₄ env a₄ v₄ rfl he₄ hv₄]; rfl
  have h₇ : interpC (step F s₇).run C = some (s₈,C) := by
    rw [step_argument_eq F s₇ v₄ 0 fn this [v₃,v₂,v₁] [] env fs rfl rfl (by decide)]
    rfl
  apply runC_cons F 7 s s₁ s₈ C C C (by rw [hc]; rfl) h₀
  apply runC_cons F 6 s₁ s₂ s₈ C C C rfl h₁
  apply runC_cons F 5 s₂ s₃ s₈ C C C rfl h₂
  apply runC_cons F 4 s₃ s₄ s₈ C C C rfl h₃
  apply runC_cons F 3 s₄ s₅ s₈ C C C rfl h₄
  apply runC_cons F 2 s₅ s₆ s₈ C C C rfl h₅
  apply runC_cons F 1 s₆ s₇ s₈ C C C rfl h₆
  apply runC_cons F 0 s₇ s₈ s₈ C C C rfl h₇
  rfl
end Host.Ts.Owned.Parametric

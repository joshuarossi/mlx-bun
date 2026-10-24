import metal.Logic
import metal.Launch

namespace Metal
open Core Inference.Contracts.Mlx

/-! # Compositional thread proofs

`Reaches`: the steps of a running thread, without counting them. `Exec`: big-step
runs of a statement list over (locals, memory), ending normally, at `continue`,
`break` or `leave`, or stopped at a barrier or collective; sound into `Reaches`
over any frames below the list. Then evaluation lemmas per expression form and
integer arithmetic at `u32`, `i32` and `u64`. -/

variable (C : M1Max.Contract)

/-- A thread's local slots. -/
abbrev Locals := Nat → Option Val

/-- `l` with `slot` set to `v` (`Thread.set`). -/
def setLocal (l : Locals) (slot : Nat) (v : Val) : Locals := fun i => if i = slot then some v else l i

@[simp] theorem setLocal_same (l : Locals) (slot : Nat) (v : Val) : setLocal l slot v slot = some v := by
  simp [setLocal]

@[simp] theorem setLocal_other (l : Locals) {i slot : Nat} (v : Val) (h : i ≠ slot) : setLocal l slot v i = l i := by
  simp [setLocal, h]

/-- A stopped thread resumed by its SIMD-group with `v` in `slot` (`runSimd`). -/
theorem resumed (ctx : Ctx) (l : Locals) (F : List Frame) (s : Status) (slot : Nat) (v : Val) :
    ({ (⟨ctx, l, F, s⟩ : Thread) with status := .running }).set slot v = ⟨ctx, setLocal l slot v, F, .running⟩ :=
  rfl

/-! ## Reachability -/

/-- `t` in `sh` steps to `t'` in `sh'`, each step taken by a running thread. -/
inductive Reaches : Thread → Shared → Thread → Shared → Prop
  | refl (t : Thread) (sh : Shared) : Reaches t sh t sh
  | cons {t t₁ t' : Thread} {sh sh₁ sh' : Shared} : isRunning t.status = true →
      (step C t).run sh = some (t₁, sh₁) → Reaches t₁ sh₁ t' sh' → Reaches t sh t' sh'

namespace Reaches
variable {C} {t t₁ t₂ t₃ : Thread} {sh sh₁ sh₂ sh₃ : Shared}

theorem trans (h₁ : Reaches C t₁ sh₁ t₂ sh₂) (h₂ : Reaches C t₂ sh₂ t₃ sh₃) : Reaches C t₁ sh₁ t₃ sh₃ := by
  induction h₁ with
  | refl => exact h₂
  | cons hr hs _ ih => exact .cons hr hs (ih h₂)

theorem single (hr : isRunning t₁.status = true) (hs : (step C t₁).run sh₁ = some (t₂, sh₂)) :
    Reaches C t₁ sh₁ t₂ sh₂ :=
  .cons hr hs (.refl _ _)

/-- A run that reaches `t₂` takes a fixed number of steps. -/
theorem fuel (h : Reaches C t₁ sh₁ t₂ sh₂) :
    ∃ n, ∀ m, (runThread C (n + m) t₁).run sh₁ = (runThread C m t₂).run sh₂ := by
  induction h with
  | refl => exact ⟨0, fun m => by rw [Nat.zero_add]⟩
  | cons hr hs _ ih =>
    obtain ⟨n, hn⟩ := ih
    refine ⟨n + 1, fun m => ?_⟩
    rw [show n + 1 + m = n + m + 1 by omega, runThread_step C _ hr, StateT.run_bind, hs]
    exact hn m

/-- A run that reaches a stopped thread is `runThread`'s result at every large enough fuel. -/
theorem run (h : Reaches C t₁ sh₁ t₂ sh₂) (hs : isRunning t₂.status = false) :
    ∃ n, ∀ m, n ≤ m → (runThread C m t₁).run sh₁ = some (t₂, sh₂) := by
  obtain ⟨n, hn⟩ := h.fuel
  refine ⟨n, fun m hm => ?_⟩
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hm
  rw [hn k]
  exact runThread_stop C k hs

end Reaches

/-! ## One step -/

section Step
variable {ctx : Ctx} {l : Locals} {sh sh₁ sh₂ sh₃ : Shared} {K : List Frame} {ss : List CStmt}

theorem step_pop : (step C ⟨ctx, l, .block [] :: K, .running⟩).run sh = some (⟨ctx, l, K, .running⟩, sh) := rfl

theorem step_scope_pop : (step C ⟨ctx, l, .scope :: K, .running⟩).run sh = some (⟨ctx, l, K, .running⟩, sh) := rfl

theorem step_done : (step C ⟨ctx, l, [], .running⟩).run sh = some (⟨ctx, l, [], .done⟩, sh) := rfl

theorem step_set {slot : Nat} {e : CExpr} {v : Val} (he : (eval C ctx l e).run sh = some (v, sh₁)) :
    (step C ⟨ctx, l, .block (.set slot e :: ss) :: K, .running⟩).run sh =
      some (⟨ctx, setLocal l slot v, .block ss :: K, .running⟩, sh₁) := by
  simp only [step, exec, StateT.run_bind, he]
  rfl

theorem step_store {ty : Ty} {p e : CExpr} {q : Ptr} {v : Val}
    (hp : (eval C ctx l p).run sh = some (.ptr q, sh₁)) (he : (eval C ctx l e).run sh₁ = some (v, sh₂))
    (hs : (storeAt ctx ty q v).run sh₂ = some ((), sh₃)) :
    (step C ⟨ctx, l, .block (.store ty p e :: ss) :: K, .running⟩).run sh =
      some (⟨ctx, l, .block ss :: K, .running⟩, sh₃) := by
  simp [step, exec, StateT.run_bind, hp, he, hs]

theorem step_array {slot index : Nat} {g : Bool} {elem : Ty} :
    (step C ⟨ctx, l, .block (.array slot g index elem :: ss) :: K, .running⟩).run sh =
      some (⟨ctx, setLocal l slot (.ptr ⟨if g then ctx.groupArray index else ctx.threadArray index, 0, elem⟩),
        .block ss :: K, .running⟩, sh) := rfl

theorem step_ite {c : CExpr} {a b : List CStmt} {v : Bool} (hc : (eval C ctx l c).run sh = some (.bool v, sh₁)) :
    (step C ⟨ctx, l, .block (.ite c a b :: ss) :: K, .running⟩).run sh =
      some (⟨ctx, l, .block (if v then a else b) :: .block ss :: K, .running⟩, sh₁) := by
  simp only [step, exec, test, StateT.run_bind, hc]
  rfl

theorem step_loop {c : CExpr} {st b : List CStmt} {v : Bool} (hc : (eval C ctx l c).run sh = some (.bool v, sh₁)) :
    (step C ⟨ctx, l, .block (.loop c st b :: ss) :: K, .running⟩).run sh =
      some (⟨ctx, l, if v then .block b :: .loop c st b :: .block ss :: K else .block ss :: K, .running⟩, sh₁) := by
  simp only [step, exec, test, StateT.run_bind, hc]
  cases v <;> rfl

theorem step_loop_frame {c : CExpr} {st b : List CStmt} :
    (step C ⟨ctx, l, .loop c st b :: K, .running⟩).run sh =
      some (⟨ctx, l, .block st :: .next c st b :: K, .running⟩, sh) := rfl

theorem step_next {c : CExpr} {st b : List CStmt} {v : Bool} (hc : (eval C ctx l c).run sh = some (.bool v, sh₁)) :
    (step C ⟨ctx, l, .next c st b :: K, .running⟩).run sh =
      some (⟨ctx, l, if v then .block b :: .loop c st b :: K else K, .running⟩, sh₁) := by
  simp only [step, test, StateT.run_bind, hc]
  cases v <;> rfl

theorem step_scope {body : List CStmt} :
    (step C ⟨ctx, l, .block (.scope body :: ss) :: K, .running⟩).run sh =
      some (⟨ctx, l, .block body :: .scope :: .block ss :: K, .running⟩, sh) := rfl

theorem step_continue {F : List Frame} (hK : unwindTo isLoop K = some F) :
    (step C ⟨ctx, l, .block (.continue_ :: ss) :: K, .running⟩).run sh = some (⟨ctx, l, F, .running⟩, sh) := by
  simp only [step, exec, StateT.run_bind]
  simp [unwindTo, isLoop, hK, lift]

theorem step_break {f : Frame} {F : List Frame} (hK : unwindTo isLoopOrNext K = some (f :: F)) :
    (step C ⟨ctx, l, .block (.break_ :: ss) :: K, .running⟩).run sh = some (⟨ctx, l, F, .running⟩, sh) := by
  simp only [step, exec, StateT.run_bind]
  simp [unwindTo, isLoopOrNext, hK, lift]

theorem step_leave {f : Frame} {F : List Frame} (hK : unwindTo isScope K = some (f :: F)) :
    (step C ⟨ctx, l, .block (.leave :: ss) :: K, .running⟩).run sh = some (⟨ctx, l, F, .running⟩, sh) := by
  simp only [step, exec, StateT.run_bind]
  simp [unwindTo, isScope, hK, lift]

theorem step_barrier {site : Nat} {d g : Bool} :
    (step C ⟨ctx, l, .block (.barrier site d g :: ss) :: K, .running⟩).run sh =
      some (⟨ctx, l, .block ss :: K, .barrier site d g⟩, sh) := rfl

theorem step_collective {site slot k : Nat} {op : Collective} {s : Scalar} {e d : CExpr} {v dv : Val}
    (he : (eval C ctx l e).run sh = some (v, sh₁)) (hd : (eval C ctx l d).run sh₁ = some (dv, sh₂))
    (hk : natOf dv = some k) :
    (step C ⟨ctx, l, .block (.collective site slot op s e d :: ss) :: K, .running⟩).run sh =
      some (⟨ctx, l, .block ss :: K, .collective site slot op s v k⟩, sh₂) := by
  simp [step, exec, StateT.run_bind, he, hd, hk, lift]

end Step

/-! ## Big-step runs -/

/-- How a run of a statement list ends: normally, at `continue`, `break` or `leave`, or
stopped with status `status` and the frames `inner` above the list's continuation. -/
inductive Outcome where
  | normal | continue_ | break_ | leave
  | stop (status : Status) (inner : List Frame)

/-- The thread's status at the end of a run. -/
def Outcome.status : Outcome → Status
  | .stop s _ => s
  | _ => .running

/-- `F` is where a run of `.block ss :: K` ending with outcome `o` leaves the frames. -/
def Lands : Outcome → List Frame → List Frame → Prop
  | .normal, K, F => F = K
  | .continue_, K, F => unwindTo isLoop K = some F
  | .break_, K, F => ∃ f, unwindTo isLoopOrNext K = some (f :: F)
  | .leave, K, F => ∃ f, unwindTo isScope K = some (f :: F)
  | .stop _ inner, K, F => F = inner ++ K

theorem Lands.block {o : Outcome} {K F : List Frame} {ss : List CStmt}
    (ho : o = .continue_ ∨ o = .break_ ∨ o = .leave) (h : Lands o K F) : Lands o (.block ss :: K) F := by
  rcases ho with rfl | rfl | rfl <;> simpa [Lands, unwindTo, isLoop, isLoopOrNext, isScope] using h

variable (ctx : Ctx)

/-- Big-step runs of a statement list from locals `l` and memory `sh` in context `ctx`, to
outcome `o`, locals `l'` and memory `sh'`. Each rule handles the list's first statement. -/
inductive Exec : List CStmt → Locals → Shared → Outcome → Locals → Shared → Prop
  | nil (l : Locals) (sh : Shared) : Exec [] l sh .normal l sh
  | set {slot : Nat} {e : CExpr} {ss l sh v sh₁ o l' sh'} : (eval C ctx l e).run sh = some (v, sh₁) →
      Exec ss (setLocal l slot v) sh₁ o l' sh' → Exec (.set slot e :: ss) l sh o l' sh'
  | store {ty : Ty} {p e : CExpr} {ss l sh q sh₁ v sh₂ sh₃ o l' sh'} :
      (eval C ctx l p).run sh = some (.ptr q, sh₁) → (eval C ctx l e).run sh₁ = some (v, sh₂) →
      (storeAt ctx ty q v).run sh₂ = some ((), sh₃) → Exec ss l sh₃ o l' sh' →
      Exec (.store ty p e :: ss) l sh o l' sh'
  | array {slot index : Nat} {g : Bool} {elem : Ty} {ss l sh o l' sh'} :
      Exec ss (setLocal l slot (.ptr ⟨if g then ctx.groupArray index else ctx.threadArray index, 0, elem⟩))
        sh o l' sh' →
      Exec (.array slot g index elem :: ss) l sh o l' sh'
  | ite {c : CExpr} {a b ss l sh} {v : Bool} {sh₁ l₁ sh₂ o l' sh'} :
      (eval C ctx l c).run sh = some (.bool v, sh₁) → Exec (if v then a else b) l sh₁ .normal l₁ sh₂ →
      Exec ss l₁ sh₂ o l' sh' → Exec (.ite c a b :: ss) l sh o l' sh'
  /-- A branch ending at `continue`, `break` or `leave`. -/
  | ite_exit {c : CExpr} {a b ss l sh} {v : Bool} {sh₁ o l' sh'} :
      (eval C ctx l c).run sh = some (.bool v, sh₁) → Exec (if v then a else b) l sh₁ o l' sh' →
      (o = .continue_ ∨ o = .break_ ∨ o = .leave) → Exec (.ite c a b :: ss) l sh o l' sh'
  | ite_stop {c : CExpr} {a b ss l sh} {v : Bool} {sh₁ s inner l' sh'} :
      (eval C ctx l c).run sh = some (.bool v, sh₁) → Exec (if v then a else b) l sh₁ (.stop s inner) l' sh' →
      Exec (.ite c a b :: ss) l sh (.stop s (inner ++ [.block ss])) l' sh'
  /-- An inlined function body, ending normally or at `leave`. -/
  | scope {body ss l sh o₁ l₁ sh₁ o l' sh'} : Exec body l sh o₁ l₁ sh₁ → (o₁ = .normal ∨ o₁ = .leave) →
      Exec ss l₁ sh₁ o l' sh' → Exec (.scope body :: ss) l sh o l' sh'
  | scope_stop {body ss l sh s inner l' sh'} : Exec body l sh (.stop s inner) l' sh' →
      Exec (.scope body :: ss) l sh (.stop s (inner ++ [.scope, .block ss])) l' sh'
  | leave {ss l sh} : Exec (.leave :: ss) l sh .leave l sh
  | continue_ {ss l sh} : Exec (.continue_ :: ss) l sh .continue_ l sh
  | break_ {ss l sh} : Exec (.break_ :: ss) l sh .break_ l sh
  | loop_exit {c : CExpr} {st b ss l sh sh₁ o l' sh'} : (eval C ctx l c).run sh = some (.bool false, sh₁) →
      Exec ss l sh₁ o l' sh' → Exec (.loop c st b :: ss) l sh o l' sh'
  /-- An iteration: the body ending normally or at `continue`, the step, then the loop again. -/
  | loop_next {c : CExpr} {st b ss l sh sh₁ o₁ l₁ sh₂ l₂ sh₃ o l' sh'} :
      (eval C ctx l c).run sh = some (.bool true, sh₁) → Exec b l sh₁ o₁ l₁ sh₂ →
      (o₁ = .normal ∨ o₁ = .continue_) → Exec st l₁ sh₂ .normal l₂ sh₃ →
      Exec (.loop c st b :: ss) l₂ sh₃ o l' sh' → Exec (.loop c st b :: ss) l sh o l' sh'
  | loop_break {c : CExpr} {st b ss l sh sh₁ l₁ sh₂ o l' sh'} : (eval C ctx l c).run sh = some (.bool true, sh₁) →
      Exec b l sh₁ .break_ l₁ sh₂ → Exec ss l₁ sh₂ o l' sh' → Exec (.loop c st b :: ss) l sh o l' sh'
  | loop_leave {c : CExpr} {st b ss l sh sh₁ l' sh'} : (eval C ctx l c).run sh = some (.bool true, sh₁) →
      Exec b l sh₁ .leave l' sh' → Exec (.loop c st b :: ss) l sh .leave l' sh'
  | loop_stop {c : CExpr} {st b ss l sh sh₁ s inner l' sh'} : (eval C ctx l c).run sh = some (.bool true, sh₁) →
      Exec b l sh₁ (.stop s inner) l' sh' →
      Exec (.loop c st b :: ss) l sh (.stop s (inner ++ [.loop c st b, .block ss])) l' sh'
  | barrier {site : Nat} {d g : Bool} {ss l sh} :
      Exec (.barrier site d g :: ss) l sh (.stop (.barrier site d g) [.block ss]) l sh
  | collective {site slot : Nat} {op : Collective} {s : Scalar} {e d : CExpr} {ss l sh v sh₁ dv sh₂} {k : Nat} :
      (eval C ctx l e).run sh = some (v, sh₁) → (eval C ctx l d).run sh₁ = some (dv, sh₂) → natOf dv = some k →
      Exec (.collective site slot op s e d :: ss) l sh (.stop (.collective site slot op s v k) [.block ss]) l sh₂

variable {C ctx}

/-- Soundness: a run of `ss` from frames `.block ss :: K` reaches the frames its outcome lands at
(and the loop statement's run also from the frame its step leaves). -/
theorem Exec.sound {ss : List CStmt} {l l' : Locals} {sh sh' : Shared} {o : Outcome}
    (h : Exec C ctx ss l sh o l' sh') : ∀ K F, Lands o K F →
      Reaches C ⟨ctx, l, .block ss :: K, .running⟩ sh ⟨ctx, l', F, o.status⟩ sh' ∧
      ∀ c st b rest, ss = .loop c st b :: rest →
        Reaches C ⟨ctx, l, .next c st b :: .block rest :: K, .running⟩ sh ⟨ctx, l', F, o.status⟩ sh' := by
  induction h with
  | nil l sh =>
    intro K F hK
    refine ⟨?_, fun _ _ _ _ h => by cases h⟩
    cases hK
    exact .single rfl (step_pop C)
  | set he _ ih =>
    intro K F hK
    exact ⟨.cons rfl (step_set C he) (ih K F hK).1, fun _ _ _ _ h => by cases h⟩
  | store hp he hs _ ih =>
    intro K F hK
    exact ⟨.cons rfl (step_store C hp he hs) (ih K F hK).1, fun _ _ _ _ h => by cases h⟩
  | array _ ih =>
    intro K F hK
    exact ⟨.cons rfl (step_array C) (ih K F hK).1, fun _ _ _ _ h => by cases h⟩
  | ite hc _ _ ihb ihs =>
    intro K F hK
    exact ⟨.cons rfl (step_ite C hc) ((ihb _ _ rfl).1.trans (ihs K F hK).1), fun _ _ _ _ h => by cases h⟩
  | ite_exit hc _ ho ihb =>
    intro K F hK
    exact ⟨.cons rfl (step_ite C hc) (ihb _ F (hK.block ho)).1, fun _ _ _ _ h => by cases h⟩
  | ite_stop hc _ ihb =>
    intro K F hK
    refine ⟨.cons rfl (step_ite C hc) (ihb _ F ?_).1, fun _ _ _ _ h => by cases h⟩
    simp only [Lands] at hK ⊢
    simp [hK]
  | scope _ ho _ ihb ihs =>
    intro K F hK
    refine ⟨.cons rfl (step_scope C) ?_, fun _ _ _ _ h => by cases h⟩
    rcases ho with rfl | rfl
    · exact (ihb _ _ rfl).1.trans (.cons rfl (step_scope_pop C) (ihs K F hK).1)
    · exact (ihb _ _ ⟨.scope, rfl⟩).1.trans (ihs K F hK).1
  | scope_stop _ ihb =>
    intro K F hK
    refine ⟨.cons rfl (step_scope C) (ihb _ F ?_).1, fun _ _ _ _ h => by cases h⟩
    simp only [Lands] at hK ⊢
    simp [hK]
  | leave =>
    intro K F hK
    obtain ⟨f, hf⟩ := hK
    exact ⟨.single rfl (step_leave C (by simpa [unwindTo, isScope] using hf)), fun _ _ _ _ h => by cases h⟩
  | continue_ =>
    intro K F hK
    exact ⟨.single rfl (step_continue C (by simpa [Lands, unwindTo, isLoop] using hK)), fun _ _ _ _ h => by cases h⟩
  | break_ =>
    intro K F hK
    obtain ⟨f, hf⟩ := hK
    exact ⟨.single rfl (step_break C (by simpa [unwindTo, isLoopOrNext] using hf)), fun _ _ _ _ h => by cases h⟩
  | loop_exit hc _ ihs =>
    intro K F hK
    refine ⟨.cons rfl (step_loop C hc) (ihs K F hK).1, ?_⟩
    rintro c st b rest ⟨⟩
    exact .cons rfl (step_next C hc) (ihs K F hK).1
  | @loop_next c st b ss l sh sh₁ o₁ l₁ sh₂ l₂ sh₃ o l' sh' hc _ ho _ _ ihb ihst ihl =>
    intro K F hK
    have hb : Lands o₁ (.loop c st b :: .block ss :: K) (.loop c st b :: .block ss :: K) := by
      rcases ho with rfl | rfl <;> exact rfl
    have key : Reaches C ⟨ctx, l, .block b :: .loop c st b :: .block ss :: K, .running⟩ sh₁
        ⟨ctx, l', F, o.status⟩ sh' := by
      have h₁ := (ihb _ _ hb).1
      rcases ho with rfl | rfl <;>
      exact h₁.trans (.cons rfl (step_loop_frame C) ((ihst _ _ rfl).1.trans ((ihl K F hK).2 _ _ _ _ rfl)))
    refine ⟨.cons rfl (step_loop C hc) key, ?_⟩
    rintro c st b rest ⟨⟩
    exact .cons rfl (step_next C hc) key
  | @loop_break c st b ss l sh sh₁ l₁ sh₂ o l' sh' hc _ _ ihb ihs =>
    intro K F hK
    have key : Reaches C ⟨ctx, l, .block b :: .loop c st b :: .block ss :: K, .running⟩ sh₁
        ⟨ctx, l', F, o.status⟩ sh' :=
      (ihb (.loop c st b :: .block ss :: K) (.block ss :: K) ⟨_, rfl⟩).1.trans (ihs K F hK).1
    refine ⟨.cons rfl (step_loop C hc) key, ?_⟩
    rintro c st b rest ⟨⟩
    exact .cons rfl (step_next C hc) key
  | @loop_leave c st b ss l sh sh₁ l' sh' hc _ ihb =>
    intro K F hK
    have key : Reaches C ⟨ctx, l, .block b :: .loop c st b :: .block ss :: K, .running⟩ sh₁
        ⟨ctx, l', F, .running⟩ sh' :=
      (ihb (.loop c st b :: .block ss :: K) F (by simpa [Lands, unwindTo, isScope] using hK)).1
    refine ⟨.cons rfl (step_loop C hc) key, ?_⟩
    rintro c st b rest ⟨⟩
    exact .cons rfl (step_next C hc) key
  | @loop_stop c st b ss l sh sh₁ s inner l' sh' hc _ ihb =>
    intro K F hK
    have key : Reaches C ⟨ctx, l, .block b :: .loop c st b :: .block ss :: K, .running⟩ sh₁ ⟨ctx, l', F, s⟩ sh' :=
      (ihb (.loop c st b :: .block ss :: K) F (by simp only [Lands] at hK ⊢; simp [hK])).1
    refine ⟨.cons rfl (step_loop C hc) key, ?_⟩
    rintro c st b rest ⟨⟩
    exact .cons rfl (step_next C hc) key
  | barrier =>
    intro K F hK
    cases hK
    exact ⟨.single rfl (step_barrier C), fun _ _ _ _ h => by cases h⟩
  | collective he hd hk =>
    intro K F hK
    cases hK
    exact ⟨.single rfl (step_collective C he hd hk), fun _ _ _ _ h => by cases h⟩

namespace Exec
variable {ss ss₁ ss₂ rest st b pre : List CStmt} {c : CExpr} {l l₁ l₂ l' : Locals}
  {sh sh₁ sh₂ sh₃ sh' : Shared} {o o₁ : Outcome} {K F : List Frame}

theorem reaches (h : Exec C ctx ss l sh o l' sh') (hK : Lands o K F) :
    Reaches C ⟨ctx, l, .block ss :: K, .running⟩ sh ⟨ctx, l', F, o.status⟩ sh' :=
  (h.sound K F hK).1

theorem reaches_normal (h : Exec C ctx ss l sh .normal l' sh') :
    Reaches C ⟨ctx, l, .block ss :: K, .running⟩ sh ⟨ctx, l', K, .running⟩ sh' :=
  h.reaches rfl

theorem reaches_continue (h : Exec C ctx ss l sh .continue_ l' sh') (hK : unwindTo isLoop K = some F) :
    Reaches C ⟨ctx, l, .block ss :: K, .running⟩ sh ⟨ctx, l', F, .running⟩ sh' :=
  h.reaches hK

theorem reaches_break {f : Frame} (h : Exec C ctx ss l sh .break_ l' sh')
    (hK : unwindTo isLoopOrNext K = some (f :: F)) :
    Reaches C ⟨ctx, l, .block ss :: K, .running⟩ sh ⟨ctx, l', F, .running⟩ sh' :=
  h.reaches ⟨f, hK⟩

theorem reaches_leave {f : Frame} (h : Exec C ctx ss l sh .leave l' sh')
    (hK : unwindTo isScope K = some (f :: F)) :
    Reaches C ⟨ctx, l, .block ss :: K, .running⟩ sh ⟨ctx, l', F, .running⟩ sh' :=
  h.reaches ⟨f, hK⟩

theorem reaches_stop {s : Status} {inner : List Frame} (h : Exec C ctx ss l sh (.stop s inner) l' sh') :
    Reaches C ⟨ctx, l, .block ss :: K, .running⟩ sh ⟨ctx, l', inner ++ K, s⟩ sh' :=
  h.reaches rfl

/-- A thread's whole code, run normally, ends done. -/
theorem reaches_done (h : Exec C ctx ss l sh .normal l' sh') :
    Reaches C ⟨ctx, l, [.block ss], .running⟩ sh ⟨ctx, l', [], .done⟩ sh' :=
  h.reaches_normal.trans (.single rfl (step_done C))

/-- The loop's test, from the frame its step leaves. -/
theorem reaches_next (h : Exec C ctx (.loop c st b :: ss) l sh o l' sh') (hK : Lands o K F) :
    Reaches C ⟨ctx, l, .next c st b :: .block ss :: K, .running⟩ sh ⟨ctx, l', F, o.status⟩ sh' :=
  (h.sound K F hK).2 c st b ss rfl

/-! ### Sequencing -/

theorem append (h₁ : Exec C ctx ss₁ l sh .normal l₁ sh₁) (h₂ : Exec C ctx ss₂ l₁ sh₁ o l' sh') :
    Exec C ctx (ss₁ ++ ss₂) l sh o l' sh' := by
  generalize hn : Outcome.normal = o₀ at h₁
  induction h₁ with
  | nil => exact h₂
  | set he _ ih => exact .set he (ih h₂ hn)
  | store hp he hs _ ih => exact .store hp he hs (ih h₂ hn)
  | array _ ih => exact .array (ih h₂ hn)
  | ite hc hb _ _ ih => exact .ite hc hb (ih h₂ hn)
  | ite_exit _ _ ho => rcases ho with rfl | rfl | rfl <;> cases hn
  | ite_stop => cases hn
  | scope hb ho _ _ ih => exact .scope hb ho (ih h₂ hn)
  | scope_stop => cases hn
  | leave => cases hn
  | continue_ => cases hn
  | break_ => cases hn
  | loop_exit hc _ ih => exact .loop_exit hc (ih h₂ hn)
  | loop_next hc hb ho hst _ _ _ ih => exact .loop_next hc hb ho hst (ih h₂ hn)
  | loop_break hc hb _ _ ih => exact .loop_break hc hb (ih h₂ hn)
  | loop_leave => cases hn
  | loop_stop => cases hn
  | barrier => cases hn
  | collective => cases hn

/-- A prefix ending at `continue`, `break` or `leave` skips what follows. -/
theorem append_jump (h₁ : Exec C ctx ss₁ l sh o l' sh') (ho : o = .continue_ ∨ o = .break_ ∨ o = .leave) :
    Exec C ctx (ss₁ ++ ss₂) l sh o l' sh' := by
  induction h₁ with
  | nil => rcases ho with h | h | h <;> cases h
  | set he _ ih => exact .set he (ih ho)
  | store hp he hs _ ih => exact .store hp he hs (ih ho)
  | array _ ih => exact .array (ih ho)
  | ite hc hb _ _ ih => exact .ite hc hb (ih ho)
  | ite_exit hc hb ho' => exact .ite_exit hc hb ho'
  | ite_stop => rcases ho with h | h | h <;> cases h
  | scope hb ho' _ _ ih => exact .scope hb ho' (ih ho)
  | scope_stop => rcases ho with h | h | h <;> cases h
  | leave => exact .leave
  | continue_ => exact .continue_
  | break_ => exact .break_
  | loop_exit hc _ ih => exact .loop_exit hc (ih ho)
  | loop_next hc hb ho' hst _ _ _ ih => exact .loop_next hc hb ho' hst (ih ho)
  | loop_break hc hb _ _ ih => exact .loop_break hc hb (ih ho)
  | loop_leave hc hb => exact .loop_leave hc hb
  | loop_stop => rcases ho with h | h | h <;> cases h
  | barrier => rcases ho with h | h | h <;> cases h
  | collective => rcases ho with h | h | h <;> cases h

/-! ### Loops -/

/-- A loop by invariant: `I k` holds at the `k`-th test and `J k` after it; the test is true below
`N` and false at `N`, where `J N` gives the exit condition `Q`. Below `N` the body either ends
normally or at `continue`, and the step takes `J k` to `I (k + 1)`; or it ends at `break` in `Q`. -/
theorem loop_inv {c : CExpr} {st b : List CStmt} (N : Nat) (I J : Nat → Locals → Shared → Prop)
    (Q : Locals → Shared → Prop)
    (htest : ∀ k ≤ N, ∀ l sh, I k l sh →
      ∃ sh₁, (eval C ctx l c).run sh = some (.bool (decide (k < N)), sh₁) ∧ J k l sh₁)
    (hdone : ∀ l sh, J N l sh → Q l sh)
    (hbody : ∀ k < N, ∀ l sh, J k l sh → ∃ o l₁ sh₁, Exec C ctx b l sh o l₁ sh₁ ∧
      ((o = .normal ∨ o = .continue_) ∧ (∃ l₂ sh₂, Exec C ctx st l₁ sh₁ .normal l₂ sh₂ ∧ I (k + 1) l₂ sh₂) ∨
        o = .break_ ∧ Q l₁ sh₁))
    {l : Locals} {sh : Shared} (h0 : I 0 l sh) :
    ∃ l' sh', Exec C ctx [.loop c st b] l sh .normal l' sh' ∧ Q l' sh' := by
  suffices key : ∀ j k, k + j = N → ∀ l sh, I k l sh →
      ∃ l' sh', Exec C ctx [.loop c st b] l sh .normal l' sh' ∧ Q l' sh' from key N 0 (by omega) l sh h0
  intro j
  induction j with
  | zero =>
    intro k hk l sh hI
    obtain ⟨sh₁, hc, hJ⟩ := htest k (by omega) l sh hI
    rw [show decide (k < N) = false from decide_eq_false (by omega)] at hc
    subst hk
    exact ⟨l, sh₁, .loop_exit hc (.nil _ _), hdone _ _ hJ⟩
  | succ j ih =>
    intro k hk l sh hI
    obtain ⟨sh₁, hc, hJ⟩ := htest k (by omega) l sh hI
    rw [show decide (k < N) = true from decide_eq_true (by omega)] at hc
    obtain ⟨o, l₁, sh₂, hb, ⟨ho, l₂, sh₃, hst, hI'⟩ | ⟨rfl, hQ⟩⟩ := hbody k (by omega) l sh₁ hJ
    · obtain ⟨l', sh', hl, hQ⟩ := ih (k + 1) (by omega) l₂ sh₃ hI'
      exact ⟨l', sh', .loop_next hc hb ho hst hl, hQ⟩
    · exact ⟨l₁, sh₂, .loop_break hc hb (.nil _ _), hQ⟩

/-- A counted loop (no `break`): it ends in `J N`. -/
theorem loop_count {c : CExpr} {st b : List CStmt} (N : Nat) (I J : Nat → Locals → Shared → Prop)
    (htest : ∀ k ≤ N, ∀ l sh, I k l sh →
      ∃ sh₁, (eval C ctx l c).run sh = some (.bool (decide (k < N)), sh₁) ∧ J k l sh₁)
    (hbody : ∀ k < N, ∀ l sh, J k l sh → ∃ o l₁ sh₁ l₂ sh₂, (o = .normal ∨ o = .continue_) ∧
      Exec C ctx b l sh o l₁ sh₁ ∧ Exec C ctx st l₁ sh₁ .normal l₂ sh₂ ∧ I (k + 1) l₂ sh₂)
    {l : Locals} {sh : Shared} (h0 : I 0 l sh) :
    ∃ l' sh', Exec C ctx [.loop c st b] l sh .normal l' sh' ∧ J N l' sh' :=
  loop_inv N I J (J N) htest (fun _ _ h => h) (fun k hk l sh hJ => by
    obtain ⟨o, l₁, sh₁, l₂, sh₂, ho, hb, hst, hI⟩ := hbody k hk l sh hJ
    exact ⟨o, l₁, sh₁, hb, .inl ⟨ho, l₂, sh₂, hst, hI⟩⟩) h0

/-! ### Stops -/

/-- A stop-free prefix, then a collective: the thread stops there with the rest of its block. -/
theorem reaches_collective {site slot k : Nat} {op : Collective} {s : Scalar} {e d : CExpr} {v dv : Val}
    (hpre : Exec C ctx pre l sh .normal l₁ sh₁) (he : (eval C ctx l₁ e).run sh₁ = some (v, sh₂))
    (hd : (eval C ctx l₁ d).run sh₂ = some (dv, sh₃)) (hk : natOf dv = some k) :
    Reaches C ⟨ctx, l, .block (pre ++ .collective site slot op s e d :: rest) :: K, .running⟩ sh
      ⟨ctx, l₁, .block rest :: K, .collective site slot op s v k⟩ sh₃ :=
  (hpre.append (.collective he hd hk)).reaches_stop

/-- A stop-free prefix, then a barrier. -/
theorem reaches_barrier {site : Nat} {d g : Bool} (hpre : Exec C ctx pre l sh .normal l₁ sh₁) :
    Reaches C ⟨ctx, l, .block (pre ++ .barrier site d g :: rest) :: K, .running⟩ sh
      ⟨ctx, l₁, .block rest :: K, .barrier site d g⟩ sh₁ :=
  (hpre.append .barrier).reaches_stop

/-- A loop whose body has finished: the step, then the loop again. -/
theorem resume_loop (hst : Exec C ctx st l sh .normal l₁ sh₁)
    (hloop : Exec C ctx (.loop c st b :: ss) l₁ sh₁ o l' sh') (hK : Lands o K F) :
    Reaches C ⟨ctx, l, .loop c st b :: .block ss :: K, .running⟩ sh ⟨ctx, l', F, o.status⟩ sh' :=
  .cons rfl (step_loop_frame C) (hst.reaches_normal.trans (hloop.reaches_next hK))

/-- A thread resumed in a loop body (frames `.block rest :: .loop c st b :: .block ss :: K`): the rest
of the body (ending normally or at `continue`), the step, then the loop statement again — `hloop`
gives its next stop (`loop_stop`), or its exit and what follows (`loop_exit`). -/
theorem resume (hrest : Exec C ctx rest l sh o₁ l₁ sh₁) (ho : o₁ = .normal ∨ o₁ = .continue_)
    (hst : Exec C ctx st l₁ sh₁ .normal l₂ sh₂) (hloop : Exec C ctx (.loop c st b :: ss) l₂ sh₂ o l' sh')
    (hK : Lands o K F) :
    Reaches C ⟨ctx, l, .block rest :: .loop c st b :: .block ss :: K, .running⟩ sh
      ⟨ctx, l', F, o.status⟩ sh' := by
  rcases ho with rfl | rfl
  · exact hrest.reaches_normal.trans (resume_loop hst hloop hK)
  · exact (hrest.reaches_continue rfl).trans (resume_loop hst hloop hK)

/-- The body's rest ends at `break`: the loop ends and the block after it runs. -/
theorem resume_break (hrest : Exec C ctx rest l sh .break_ l₁ sh₁) (hss : Exec C ctx ss l₁ sh₁ o l' sh')
    (hK : Lands o K F) :
    Reaches C ⟨ctx, l, .block rest :: .loop c st b :: .block ss :: K, .running⟩ sh
      ⟨ctx, l', F, o.status⟩ sh' :=
  (hrest.reaches_break (f := .loop c st b) rfl).trans (hss.reaches hK)

/-- Resumed in a loop body: the test is true and the next iteration's body stops again. -/
theorem resume_stop {s : Status} {inner : List Frame} {sh₃ : Shared}
    (hrest : Exec C ctx rest l sh o₁ l₁ sh₁) (ho : o₁ = .normal ∨ o₁ = .continue_)
    (hst : Exec C ctx st l₁ sh₁ .normal l₂ sh₂) (hc : (eval C ctx l₂ c).run sh₂ = some (.bool true, sh₃))
    (hb : Exec C ctx b l₂ sh₃ (.stop s inner) l' sh') :
    Reaches C ⟨ctx, l, .block rest :: .loop c st b :: .block ss :: K, .running⟩ sh
      ⟨ctx, l', inner ++ .loop c st b :: .block ss :: K, s⟩ sh' :=
  resume hrest ho hst (.loop_stop hc hb) (by simp [Lands])

/-- Resumed in a loop body: the test is false and the loop ends. -/
theorem resume_exit {sh₃ : Shared} (hrest : Exec C ctx rest l sh o₁ l₁ sh₁)
    (ho : o₁ = .normal ∨ o₁ = .continue_) (hst : Exec C ctx st l₁ sh₁ .normal l₂ sh₂)
    (hc : (eval C ctx l₂ c).run sh₂ = some (.bool false, sh₃)) :
    Reaches C ⟨ctx, l, .block rest :: .loop c st b :: .block ss :: K, .running⟩ sh
      ⟨ctx, l₂, .block ss :: K, .running⟩ sh₃ := by
  have h : Reaches C ⟨ctx, l₁, .loop c st b :: .block ss :: K, .running⟩ sh₁
      ⟨ctx, l₂, .block ss :: K, .running⟩ sh₃ :=
    .cons rfl (step_loop_frame C) (hst.reaches_normal.trans (.single rfl (step_next C hc)))
  rcases ho with rfl | rfl
  · exact hrest.reaches_normal.trans h
  · exact (hrest.reaches_continue rfl).trans h

end Exec

/-! ## Expressions

Run-form evaluation per expression form (`eval_lit`, `eval_local`, `eval_coord` and
`eval_load` are in Logic.lean). -/

/-- An f32 product: an operand the compiler may contract with an addition. -/
def isMulF32 : CExpr → Bool
  | .bin .mul .f32 _ _ _ => true
  | _ => false

section Eval
variable (C) {ctx : Ctx} {l : Locals} {sh sh₁ sh₂ sh₃ : Shared}

/-- `eval_local` with the context and locals implicit. -/
theorem eval_local' {i : Nat} {v : Val} (h : l i = some v) (sh : Shared) :
    (eval C ctx l (.local i)).run sh = some (v, sh) :=
  eval_local C ctx l i v h sh

theorem eval_un {op : Core.UnOp} {s : Scalar} {e : CExpr} {v w : Val} (he : (eval C ctx l e).run sh = some (v, sh₁))
    (hw : lift1 (unary C op s) v = some w) : (eval C ctx l (.un op s e)).run sh = some (w, sh₁) := by
  rw [eval.eq_def]
  simp [he, hw, lift]

/-- A binary operation with no contraction (not at f32, or the site not fused). -/
theorem eval_bin {op : Core.BinOp} {s : Scalar} {site : Nat} {a b : CExpr} {x y z : Val}
    (hf : ¬(ctx.fuse site = true ∧ s = .f32))
    (ha : (eval C ctx l a).run sh = some (x, sh₁)) (hb : (eval C ctx l b).run sh₁ = some (y, sh₂))
    (hz : lift2 (binary C op s) x y = some z) : (eval C ctx l (.bin op s site a b)).run sh = some (z, sh₂) := by
  rw [eval.eq_def]
  simp only [hf, ↓reduceIte]
  simp [ha, hb, hz, lift]

/-- A binary operation that is not a contraction: neither `add` nor `sub`, or no operand an f32
product. -/
theorem eval_bin_plain {op : Core.BinOp} {s : Scalar} {site : Nat} {a b : CExpr} {x y z : Val}
    (hp : op ≠ .add ∧ op ≠ .sub ∨ isMulF32 a = false ∧ isMulF32 b = false)
    (ha : (eval C ctx l a).run sh = some (x, sh₁)) (hb : (eval C ctx l b).run sh₁ = some (y, sh₂))
    (hz : lift2 (binary C op s) x y = some z) : (eval C ctx l (.bin op s site a b)).run sh = some (z, sh₂) := by
  by_cases hf : ctx.fuse site = true ∧ s = .f32
  · obtain ⟨hf, rfl⟩ := hf
    rw [eval.eq_def]
    simp only [hf, and_self, ↓reduceIte]
    split <;> first
      | (simp [isMulF32] at hp; done)
      | simp [ha, hb, hz, lift]
  · exact eval_bin C hf ha hb hz

/-- An integer operation (the left operand an integer; nothing contracts outside f32). -/
theorem eval_int {op : Core.BinOp} {s sa : Scalar} {site w : Nat} {a b : CExpr} {y z : Val} (hs : s ≠ .f32)
    (ha : (eval C ctx l a).run sh = some (.int sa w, sh₁)) (hb : (eval C ctx l b).run sh₁ = some (y, sh₂))
    (hz : binary C op s (.int sa w) y = some z) : (eval C ctx l (.bin op s site a b)).run sh = some (z, sh₂) :=
  eval_bin C (fun h => hs h.2) ha hb hz

/-- A scalar f32 operation that is not a contraction. -/
theorem eval_f32 {op : Core.BinOp} {site : Nat} {a b : CExpr} {p q : Float32} {z : Val}
    (hp : op ≠ .add ∧ op ≠ .sub ∨ isMulF32 a = false ∧ isMulF32 b = false)
    (ha : (eval C ctx l a).run sh = some (.f32 p, sh₁)) (hb : (eval C ctx l b).run sh₁ = some (.f32 q, sh₂))
    (hz : binary C op .f32 (.f32 p) (.f32 q) = some z) :
    (eval C ctx l (.bin op .f32 site a b)).run sh = some (z, sh₂) :=
  eval_bin_plain C hp ha hb hz

/-- Contraction of `x * y + z` at a fused site. -/
theorem eval_fma_mul_add {site m : Nat} {x y z : CExpr} {p q r : Float32} (hf : ctx.fuse site = true)
    (hx : (eval C ctx l x).run sh = some (.f32 p, sh₁)) (hy : (eval C ctx l y).run sh₁ = some (.f32 q, sh₂))
    (hz : (eval C ctx l z).run sh₂ = some (.f32 r, sh₃)) :
    (eval C ctx l (.bin .add .f32 site (.bin .mul .f32 m x y) z)).run sh = some (.f32 (C.fma p q r), sh₃) := by
  rw [eval.eq_def]
  simp [hf, hx, hy, hz, fused]

/-- Contraction of `z + x * y` (`z` not a product) at a fused site. -/
theorem eval_fma_add_mul {site m : Nat} {x y z : CExpr} {p q r : Float32} (hf : ctx.fuse site = true)
    (hm : isMulF32 z = false)
    (hx : (eval C ctx l x).run sh = some (.f32 p, sh₁)) (hy : (eval C ctx l y).run sh₁ = some (.f32 q, sh₂))
    (hz : (eval C ctx l z).run sh₂ = some (.f32 r, sh₃)) :
    (eval C ctx l (.bin .add .f32 site z (.bin .mul .f32 m x y))).run sh = some (.f32 (C.fma p q r), sh₃) := by
  rw [eval.eq_def]
  simp only [hf, and_self, ↓reduceIte]
  split <;> first
    | (simp_all [isMulF32]; done)
    | simp_all [fused]

/-- Contraction of `x * y - z` at a fused site: `fma(x, y, -z)`, `z` evaluated first. -/
theorem eval_fma_mul_sub {site m : Nat} {x y z : CExpr} {p q r : Float32} (hf : ctx.fuse site = true)
    (hz : (eval C ctx l z).run sh = some (.f32 r, sh₁)) (hx : (eval C ctx l x).run sh₁ = some (.f32 p, sh₂))
    (hy : (eval C ctx l y).run sh₂ = some (.f32 q, sh₃)) :
    (eval C ctx l (.bin .sub .f32 site (.bin .mul .f32 m x y) z)).run sh =
      some (.f32 (C.fma p q (f32Neg r)), sh₃) := by
  rw [eval.eq_def]
  simp [hf, hx, hy, hz, fused, unary, lift]

/-- Contraction of `z - x * y` (`z` not a product) at a fused site: `fma(-x, y, z)`. -/
theorem eval_fma_sub_mul {site m : Nat} {x y z : CExpr} {p q r : Float32} (hf : ctx.fuse site = true)
    (hm : isMulF32 z = false)
    (hx : (eval C ctx l x).run sh = some (.f32 p, sh₁)) (hy : (eval C ctx l y).run sh₁ = some (.f32 q, sh₂))
    (hz : (eval C ctx l z).run sh₂ = some (.f32 r, sh₃)) :
    (eval C ctx l (.bin .sub .f32 site z (.bin .mul .f32 m x y))).run sh =
      some (.f32 (C.fma (f32Neg p) q r), sh₃) := by
  rw [eval.eq_def]
  simp only [hf, and_self, ↓reduceIte]
  split <;> first
    | (simp_all [isMulF32]; done)
    | simp_all [fused, unary, lift]

/-- `z + x * y` (`z` not a product) under either choice of the compiler at `site`, for operands
that leave memory unchanged. -/
theorem eval_add_mul {site m : Nat} {x y z : CExpr} {p q r : Float32} (hm : isMulF32 z = false)
    (hx : (eval C ctx l x).run sh = some (.f32 p, sh)) (hy : (eval C ctx l y).run sh = some (.f32 q, sh))
    (hz : (eval C ctx l z).run sh = some (.f32 r, sh)) :
    (eval C ctx l (.bin .add .f32 site z (.bin .mul .f32 m x y))).run sh =
      some (.f32 (if ctx.fuse site then C.fma p q r else C.fadd r (C.fmul p q)), sh) := by
  cases hf : ctx.fuse site
  · exact eval_bin C (by simp [hf]) hz (eval_bin_plain C (.inl ⟨by decide, by decide⟩) hx hy rfl) rfl
  · exact eval_fma_add_mul C hf hm hx hy hz

/-- `x * y + z` under either choice of the compiler at `site`, for operands that leave memory
unchanged. -/
theorem eval_mul_add {site m : Nat} {x y z : CExpr} {p q r : Float32}
    (hx : (eval C ctx l x).run sh = some (.f32 p, sh)) (hy : (eval C ctx l y).run sh = some (.f32 q, sh))
    (hz : (eval C ctx l z).run sh = some (.f32 r, sh)) :
    (eval C ctx l (.bin .add .f32 site (.bin .mul .f32 m x y) z)).run sh =
      some (.f32 (if ctx.fuse site then C.fma p q r else C.fadd (C.fmul p q) r), sh) := by
  cases hf : ctx.fuse site
  · exact eval_bin C (by simp [hf]) (eval_bin_plain C (.inl ⟨by decide, by decide⟩) hx hy rfl) hz rfl
  · exact eval_fma_mul_add C hf hx hy hz

theorem eval_fma {a b c : CExpr} {p q r : Float32}
    (ha : (eval C ctx l a).run sh = some (.f32 p, sh₁)) (hb : (eval C ctx l b).run sh₁ = some (.f32 q, sh₂))
    (hc : (eval C ctx l c).run sh₂ = some (.f32 r, sh₃)) :
    (eval C ctx l (.fma a b c)).run sh = some (.f32 (C.fma p q r), sh₃) := by
  rw [eval.eq_def]
  simp [ha, hb, hc, fused]

theorem eval_conv {t : Scalar} {e : CExpr} {v w : Val} (he : (eval C ctx l e).run sh = some (v, sh₁))
    (hw : lift1 (convert C t) v = some w) : (eval C ctx l (.conv t e)).run sh = some (w, sh₁) := by
  rw [eval.eq_def]
  simp [he, hw, lift]

theorem eval_bitcast {t : Scalar} {e : CExpr} {v w : Val} (he : (eval C ctx l e).run sh = some (v, sh₁))
    (hw : bitcast t v = some w) : (eval C ctx l (.bitcast t e)).run sh = some (w, sh₁) := by
  rw [eval.eq_def]
  simp [he, hw, lift]

/-- The lazy ternary evaluates the chosen operand only. -/
theorem eval_cond {c a b : CExpr} {v : Bool} {w : Val} (hc : (eval C ctx l c).run sh = some (.bool v, sh₁))
    (hw : (eval C ctx l (if v then a else b)).run sh₁ = some (w, sh₂)) :
    (eval C ctx l (.cond c a b)).run sh = some (w, sh₂) := by
  rw [eval.eq_def]
  cases v <;> simp_all [lift, truth]

theorem eval_and_true {a b : CExpr} {w : Val} (ha : (eval C ctx l a).run sh = some (.bool true, sh₁))
    (hb : (eval C ctx l b).run sh₁ = some (w, sh₂)) : (eval C ctx l (.and a b)).run sh = some (w, sh₂) := by
  rw [eval.eq_def]
  simp [ha, hb, lift, truth]

theorem eval_and_false {a b : CExpr} (ha : (eval C ctx l a).run sh = some (.bool false, sh₁)) :
    (eval C ctx l (.and a b)).run sh = some (.bool false, sh₁) := by
  rw [eval.eq_def]
  simp [ha, lift, truth]

theorem eval_or_true {a b : CExpr} (ha : (eval C ctx l a).run sh = some (.bool true, sh₁)) :
    (eval C ctx l (.or a b)).run sh = some (.bool true, sh₁) := by
  rw [eval.eq_def]
  simp [ha, lift, truth]

theorem eval_or_false {a b : CExpr} {w : Val} (ha : (eval C ctx l a).run sh = some (.bool false, sh₁))
    (hb : (eval C ctx l b).run sh₁ = some (w, sh₂)) : (eval C ctx l (.or a b)).run sh = some (w, sh₂) := by
  rw [eval.eq_def]
  simp [ha, hb, lift, truth]

theorem eval_offset {p i : CExpr} {q : Ptr} {s : Scalar} {w : Nat}
    (hp : (eval C ctx l p).run sh = some (.ptr q, sh₁)) (hi : (eval C ctx l i).run sh₁ = some (.int s w, sh₂)) :
    (eval C ctx l (.offset p i)).run sh =
      some (.ptr { q with offset := q.offset + Val.signed s w * q.elem.bytes }, sh₂) := by
  rw [eval.eq_def]
  simp [hp, hi]

theorem eval_ptrCast {t : Ty} {p : CExpr} {q : Ptr} (hp : (eval C ctx l p).run sh = some (.ptr q, sh₁)) :
    (eval C ctx l (.ptrCast t p)).run sh = some (.ptr { q with elem := t }, sh₁) := by
  rw [eval.eq_def]
  simp [hp]

theorem eval_component {v i : CExpr} {s : Scalar} {xs : List Val} {iv x : Val} {n : Nat}
    (hv : (eval C ctx l v).run sh = some (.vec s xs, sh₁)) (hi : (eval C ctx l i).run sh₁ = some (iv, sh₂))
    (hn : natOf iv = some n) (hx : xs[n]? = some x) : (eval C ctx l (.component v i)).run sh = some (x, sh₂) := by
  rw [eval.eq_def]
  simp [hv, hi, hn, hx, lift]

theorem evalList_nil : (evalList C ctx l []).run sh = some ([], sh) := by
  rw [evalList.eq_def]
  rfl

theorem evalList_cons {e : CExpr} {es : List CExpr} {v : Val} {vs : List Val}
    (he : (eval C ctx l e).run sh = some (v, sh₁)) (hs : (evalList C ctx l es).run sh₁ = some (vs, sh₂)) :
    (evalList C ctx l (e :: es)).run sh = some (v :: vs, sh₂) := by
  rw [evalList.eq_def]
  simp [he, hs]

theorem eval_vector {s : Scalar} {es : List CExpr} {vs : List Val}
    (hs : (evalList C ctx l es).run sh = some (vs, sh₁)) :
    (eval C ctx l (.vector s es)).run sh = some (.vec s vs, sh₁) := by
  rw [eval.eq_def]
  simp [hs]

end Eval

/-! ## Integer arithmetic

Unsigned values as `u32 n` and `u64 n` (reduced, so `u32 (a + b)` is the wrapped sum);
non-negative `int` values as `.int .i32 n` with `n < 2 ^ 31`. -/

def u64 (n : Nat) : Val := .int .u64 (n % 2 ^ 64)

theorem u32_lit {n : Nat} (h : n < 2 ^ 32) : Val.int .u32 n = u32 n := by simp [u32]; omega

theorem u64_lit {n : Nat} (h : n < 2 ^ 64) : Val.int .u64 n = u64 n := by simp [u64]; omega

theorem signed_unsigned {s : Scalar} (w : Nat) (h : s.isSigned = false) : Val.signed s w = w := by
  simp [Val.signed, h]

theorem signed_i32 {n : Nat} (h : n < 2 ^ 31) : Val.signed .i32 n = n := by
  simp [Val.signed, Scalar.isSigned, Scalar.width, Scalar.bytes]; omega

theorem wrap_unsigned {s : Scalar} (v : Int) (h : s.isSigned = false) :
    Val.wrap s v = some (v % 2 ^ s.width).toNat := by
  simp [Val.wrap, h]

theorem wrap_i32 {n : Nat} (h : n < 2 ^ 31) : Val.wrap .i32 n = some n := by
  simp [Val.wrap, Scalar.isSigned, Scalar.width, Scalar.bytes]
  constructor
  · omega
  · rw [Int.emod_eq_of_lt (by omega) (by omega)]; rfl

theorem natOf_unsigned {s : Scalar} (w : Nat) (h : s.isSigned = false) : natOf (.int s w) = some w := by
  simp [natOf, h]

theorem natOf_u32 (n : Nat) : natOf (u32 n) = some (n % 2 ^ 32) := rfl

theorem natOf_i32 {n : Nat} (h : n < 2 ^ 31) : natOf (.int .i32 n) = some n := by
  simp [natOf, signed_i32 h]

theorem ordered_le_compare (a b : Int) : ordered .le (some (compare a b)) = some (decide (a ≤ b)) := by
  rcases lt_trichotomy a b with h | h | h
  · simp [ordered, (compare_lt_iff_lt).mpr h, h.le]
  · subst h; simp [ordered]
  · simp [ordered, (compare_gt_iff_gt).mpr h, not_le.mpr h]

theorem ordered_gt_compare (a b : Int) : ordered .gt (some (compare a b)) = some (decide (b < a)) := by
  rcases lt_trichotomy a b with h | h | h
  · simp [ordered, (compare_lt_iff_lt).mpr h, not_lt.mpr h.le]
  · subst h; simp [ordered]
  · simp [ordered, (compare_gt_iff_gt).mpr h, h]

theorem ordered_ge_compare (a b : Int) : ordered .ge (some (compare a b)) = some (decide (b ≤ a)) := by
  rcases lt_trichotomy a b with h | h | h
  · simp [ordered, (compare_lt_iff_lt).mpr h, not_le.mpr h]
  · subst h; simp [ordered]
  · simp [ordered, (compare_gt_iff_gt).mpr h, h.le]

theorem ordered_ne_compare (a b : Int) : ordered .ne (some (compare a b)) = some (decide (a ≠ b)) := by
  rcases lt_trichotomy a b with h | h | h
  · simp [ordered, (compare_lt_iff_lt).mpr h, h.ne]
  · subst h; simp [ordered]
  · simp [ordered, (compare_gt_iff_gt).mpr h, h.ne']

section Arith
variable (C) (a b : Nat)

theorem binary_add_u32 : binary C .add .u32 (u32 a) (u32 b) = some (u32 (a + b)) := by
  simp [binary, u32, Val.signed, Val.wrap, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  omega

theorem binary_mul_u32 : binary C .mul .u32 (u32 a) (u32 b) = some (u32 (a * b)) := by
  simp [binary, u32, Val.signed, Val.wrap, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  rw [← Int.mul_emod, show (a : Int) * b = ((a * b : Nat) : Int) by push_cast; rfl]
  generalize a * b = m
  omega

theorem binary_sub_u32 (h : b ≤ a) : binary C .sub .u32 (u32 a) (u32 b) = some (u32 (a - b)) := by
  simp [binary, u32, Val.signed, Val.wrap, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  omega

theorem binary_div_u32 (ha : a < 2 ^ 32) (hb : b < 2 ^ 32) (h : 0 < b) :
    binary C .div .u32 (u32 a) (u32 b) = some (u32 (a / b)) := by
  rw [← u32_lit ha, ← u32_lit hb]
  simp [binary, u32, Val.signed, Val.wrap, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  refine ⟨by omega, ?_⟩
  rw [show (a : Int) / b = ((a / b : Nat) : Int) by push_cast; rfl]
  generalize a / b = m
  omega

theorem binary_rem_u32 (ha : a < 2 ^ 32) (hb : b < 2 ^ 32) (h : 0 < b) :
    binary C .rem .u32 (u32 a) (u32 b) = some (u32 (a % b)) := by
  rw [← u32_lit ha, ← u32_lit hb]
  simp [binary, u32, Val.signed, Val.wrap, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  refine ⟨by omega, ?_⟩
  rw [show (a : Int).tmod b = ((a % b : Nat) : Int) by push_cast; rfl]
  generalize a % b = m
  omega

theorem binary_shr_u32 (ha : a < 2 ^ 32) (hb : b < 32) :
    binary C .shr .u32 (u32 a) (u32 b) = some (u32 (a / 2 ^ b)) := by
  rw [← u32_lit ha, ← u32_lit (show b < 2 ^ 32 by omega)]
  simp [binary, u32, Val.signed, Val.wrap, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  refine ⟨hb, ?_⟩
  rw [show (a : Int) / 2 ^ b = ((a / 2 ^ b : Nat) : Int) by push_cast; rfl]
  generalize a / 2 ^ b = m
  omega

theorem binary_shl_u32 (hb : b < 32) : binary C .shl .u32 (u32 a) (u32 b) = some (u32 (a * 2 ^ b)) := by
  rw [← u32_lit (show b < 2 ^ 32 by omega)]
  simp [binary, u32, Val.signed, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  omega

theorem binary_min_u32 (ha : a < 2 ^ 32) (hb : b < 2 ^ 32) :
    binary C .min .u32 (u32 a) (u32 b) = some (u32 (min a b)) := by
  rw [← u32_lit ha, ← u32_lit hb]
  simp [binary, u32, Val.signed, Val.wrap, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  omega

theorem binary_max_u32 (ha : a < 2 ^ 32) (hb : b < 2 ^ 32) :
    binary C .max .u32 (u32 a) (u32 b) = some (u32 (max a b)) := by
  rw [← u32_lit ha, ← u32_lit hb]
  simp [binary, u32, Val.signed, Val.wrap, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  omega

theorem binary_bitAnd_u32 (ha : a < 2 ^ 32) (hb : b < 2 ^ 32) :
    binary C .bitAnd .u32 (u32 a) (u32 b) = some (u32 (a &&& b)) := by
  rw [← u32_lit ha, ← u32_lit hb, ← u32_lit (Nat.and_lt_two_pow a hb)]
  simp [binary, Scalar.isInt]

theorem binary_bitOr_u32 (ha : a < 2 ^ 32) (hb : b < 2 ^ 32) :
    binary C .bitOr .u32 (u32 a) (u32 b) = some (u32 (a ||| b)) := by
  rw [← u32_lit ha, ← u32_lit hb, ← u32_lit (Nat.or_lt_two_pow ha hb)]
  simp [binary, Scalar.isInt]

theorem binary_bitXor_u32 (ha : a < 2 ^ 32) (hb : b < 2 ^ 32) :
    binary C .bitXor .u32 (u32 a) (u32 b) = some (u32 (a ^^^ b)) := by
  rw [← u32_lit ha, ← u32_lit hb, ← u32_lit (Nat.xor_lt_two_pow ha hb)]
  simp [binary, Scalar.isInt]

theorem binary_lt_u32 (ha : a < 2 ^ 32) (hb : b < 2 ^ 32) :
    binary C .lt .u32 (u32 a) (u32 b) = some (.bool (decide (a < b))) := by
  rw [← u32_lit ha, ← u32_lit hb]
  simp [binary, Val.signed, Scalar.isSigned, Scalar.isInt, intCompare, ordered_lt_compare]

theorem binary_le_u32 (ha : a < 2 ^ 32) (hb : b < 2 ^ 32) :
    binary C .le .u32 (u32 a) (u32 b) = some (.bool (decide (a ≤ b))) := by
  rw [← u32_lit ha, ← u32_lit hb]
  simp [binary, Val.signed, Scalar.isSigned, Scalar.isInt, intCompare, ordered_le_compare]

theorem binary_gt_u32 (ha : a < 2 ^ 32) (hb : b < 2 ^ 32) :
    binary C .gt .u32 (u32 a) (u32 b) = some (.bool (decide (b < a))) := by
  rw [← u32_lit ha, ← u32_lit hb]
  simp [binary, Val.signed, Scalar.isSigned, Scalar.isInt, intCompare, ordered_gt_compare]

theorem binary_ge_u32 (ha : a < 2 ^ 32) (hb : b < 2 ^ 32) :
    binary C .ge .u32 (u32 a) (u32 b) = some (.bool (decide (b ≤ a))) := by
  rw [← u32_lit ha, ← u32_lit hb]
  simp [binary, Val.signed, Scalar.isSigned, Scalar.isInt, intCompare, ordered_ge_compare]

theorem binary_eq_u32 (ha : a < 2 ^ 32) (hb : b < 2 ^ 32) :
    binary C .eq .u32 (u32 a) (u32 b) = some (.bool (decide (a = b))) := by
  rw [← u32_lit ha, ← u32_lit hb]
  simp [binary, Val.signed, Scalar.isSigned, Scalar.isInt, intCompare, ordered_eq_compare]

theorem binary_ne_u32 (ha : a < 2 ^ 32) (hb : b < 2 ^ 32) :
    binary C .ne .u32 (u32 a) (u32 b) = some (.bool (decide (a ≠ b))) := by
  rw [← u32_lit ha, ← u32_lit hb]
  simp [binary, Val.signed, Scalar.isSigned, Scalar.isInt, intCompare, ordered_ne_compare]

theorem binary_add_i32 (h : a + b < 2 ^ 31) :
    binary C .add .i32 (.int .i32 a) (.int .i32 b) = some (.int .i32 (a + b)) := by
  have hw : Val.wrap .i32 ((a : Int) + b) = some (a + b) := by rw [← Nat.cast_add]; exact wrap_i32 h
  simp [binary, Scalar.isInt, signed_i32 (show a < 2 ^ 31 by omega), signed_i32 (show b < 2 ^ 31 by omega), hw]

theorem binary_sub_i32 (ha : a < 2 ^ 31) (h : b ≤ a) :
    binary C .sub .i32 (.int .i32 a) (.int .i32 b) = some (.int .i32 (a - b)) := by
  have hw : Val.wrap .i32 ((a : Int) - b) = some (a - b) := by
    rw [show (a : Int) - b = ((a - b : Nat) : Int) by omega]; exact wrap_i32 (by omega)
  simp [binary, Scalar.isInt, signed_i32 ha, signed_i32 (show b < 2 ^ 31 by omega), hw]

theorem binary_mul_i32 (h : a * b < 2 ^ 31) (ha : a < 2 ^ 31) (hb : b < 2 ^ 31) :
    binary C .mul .i32 (.int .i32 a) (.int .i32 b) = some (.int .i32 (a * b)) := by
  have hw : Val.wrap .i32 ((a : Int) * b) = some (a * b) := by rw [← Nat.cast_mul]; exact wrap_i32 h
  simp [binary, Scalar.isInt, signed_i32 ha, signed_i32 hb, hw]

theorem binary_lt_i32 (ha : a < 2 ^ 31) (hb : b < 2 ^ 31) :
    binary C .lt .i32 (.int .i32 a) (.int .i32 b) = some (.bool (decide (a < b))) := by
  simp [binary, Scalar.isInt, signed_i32 ha, signed_i32 hb, intCompare, ordered_lt_compare]

theorem binary_le_i32 (ha : a < 2 ^ 31) (hb : b < 2 ^ 31) :
    binary C .le .i32 (.int .i32 a) (.int .i32 b) = some (.bool (decide (a ≤ b))) := by
  simp [binary, Scalar.isInt, signed_i32 ha, signed_i32 hb, intCompare, ordered_le_compare]

theorem binary_gt_i32 (ha : a < 2 ^ 31) (hb : b < 2 ^ 31) :
    binary C .gt .i32 (.int .i32 a) (.int .i32 b) = some (.bool (decide (b < a))) := by
  simp [binary, Scalar.isInt, signed_i32 ha, signed_i32 hb, intCompare, ordered_gt_compare]

theorem binary_ge_i32 (ha : a < 2 ^ 31) (hb : b < 2 ^ 31) :
    binary C .ge .i32 (.int .i32 a) (.int .i32 b) = some (.bool (decide (b ≤ a))) := by
  simp [binary, Scalar.isInt, signed_i32 ha, signed_i32 hb, intCompare, ordered_ge_compare]

theorem binary_eq_i32 (ha : a < 2 ^ 31) (hb : b < 2 ^ 31) :
    binary C .eq .i32 (.int .i32 a) (.int .i32 b) = some (.bool (decide (a = b))) := by
  simp [binary, Scalar.isInt, signed_i32 ha, signed_i32 hb, intCompare, ordered_eq_compare]

theorem binary_ne_i32 (ha : a < 2 ^ 31) (hb : b < 2 ^ 31) :
    binary C .ne .i32 (.int .i32 a) (.int .i32 b) = some (.bool (decide (a ≠ b))) := by
  simp [binary, Scalar.isInt, signed_i32 ha, signed_i32 hb, intCompare, ordered_ne_compare]

theorem binary_add_u64 : binary C .add .u64 (u64 a) (u64 b) = some (u64 (a + b)) := by
  simp [binary, u64, Val.signed, Val.wrap, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  omega

theorem binary_mul_u64 : binary C .mul .u64 (u64 a) (u64 b) = some (u64 (a * b)) := by
  simp [binary, u64, Val.signed, Val.wrap, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  rw [← Int.mul_emod, show (a : Int) * b = ((a * b : Nat) : Int) by push_cast; rfl]
  generalize a * b = m
  omega

theorem convert_u64_u32 (ha : a < 2 ^ 32) : convert C .u64 (u32 a) = some (u64 a) := by
  rw [← u32_lit ha]
  simp [convert, u64, Val.signed, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  omega

theorem convert_u32_i32 (ha : a < 2 ^ 31) : convert C .u32 (.int .i32 a) = some (u32 a) := by
  simp [convert, u32, signed_i32 ha, Scalar.isInt, Scalar.width, Scalar.bytes]
  omega

theorem convert_i32_u32 (ha : a < 2 ^ 31) : convert C .i32 (u32 a) = some (.int .i32 a) := by
  rw [← u32_lit (show a < 2 ^ 32 by omega)]
  simp [convert, Val.signed, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  omega

theorem convert_u16_u32 (ha : a < 2 ^ 16) : convert C .u16 (u32 a) = some (.int .u16 a) := by
  rw [← u32_lit (show a < 2 ^ 32 by omega)]
  simp [convert, Val.signed, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  omega

end Arith

section Offset
variable (C) {ctx : Ctx} {l : Locals} {sh sh₁ sh₂ : Shared} {p i : CExpr} {r o n : Nat} {e : Ty}

/-- A pointer at byte offset `o` moved by a `u32` index `n`. -/
theorem eval_offset_u32 (hp : (eval C ctx l p).run sh = some (.ptr ⟨r, (o : Int), e⟩, sh₁))
    (hi : (eval C ctx l i).run sh₁ = some (u32 n, sh₂)) (hn : n < 2 ^ 32) :
    (eval C ctx l (.offset p i)).run sh = some (.ptr ⟨r, ((o + n * e.bytes : Nat) : Int), e⟩, sh₂) := by
  rw [eval_offset C hp hi, signed_unsigned _ rfl, Nat.mod_eq_of_lt hn]
  push_cast
  rfl

/-- A pointer at byte offset `o` moved by a `u64` index `n`. -/
theorem eval_offset_u64 (hp : (eval C ctx l p).run sh = some (.ptr ⟨r, (o : Int), e⟩, sh₁))
    (hi : (eval C ctx l i).run sh₁ = some (u64 n, sh₂)) (hn : n < 2 ^ 64) :
    (eval C ctx l (.offset p i)).run sh = some (.ptr ⟨r, ((o + n * e.bytes : Nat) : Int), e⟩, sh₂) := by
  rw [eval_offset C hp hi, signed_unsigned _ rfl, Nat.mod_eq_of_lt hn]
  push_cast
  rfl

/-- A pointer at byte offset `o` moved by a non-negative `int` index `n`. -/
theorem eval_offset_i32 (hp : (eval C ctx l p).run sh = some (.ptr ⟨r, (o : Int), e⟩, sh₁))
    (hi : (eval C ctx l i).run sh₁ = some (.int .i32 n, sh₂)) (hn : n < 2 ^ 31) :
    (eval C ctx l (.offset p i)).run sh = some (.ptr ⟨r, ((o + n * e.bytes : Nat) : Int), e⟩, sh₂) := by
  rw [eval_offset C hp hi, signed_i32 hn]
  push_cast
  rfl

end Offset

/-! ## Thread memory

Accesses to a thread's own arrays are not logged. -/

theorem log_loop_thread (ctx : Ctx) (region offset : Nat) (write : Bool) (r : Region) (hs : r.space = .thread) :
    ∀ (xs : List Nat) (sh : Shared), sh.regions region = some r →
    (xs.foldlM (fun _ i => logAccess ctx region (offset + i) write) PUnit.unit).run sh = some (PUnit.unit, sh)
  | [], _, _ => rfl
  | x :: xs, sh, h => by
    have h1 : (logAccess ctx region (offset + x) write).run sh = some ((), sh) := by
      simp [logAccess, StateT.run, modify, modifyGet, MonadStateOf.modifyGet, StateT.modifyGet, h, hs]
    have ih := log_loop_thread ctx region offset write r hs xs sh h
    simp only [List.foldlM_cons, StateT.run_bind, h1] at ih ⊢
    exact ih

theorem loadAt_run_thread (ctx : Ctx) (t : Ty) (p : Ptr) (r : Region) (sh : Shared) (v : Val)
    (hr : sh.regions p.region = some r) (hs : r.space = .thread) (ho : 0 ≤ p.offset)
    (ha : r.align % alignment t = 0) (hoa : p.offset.toNat % alignment t = 0)
    (hb : p.offset.toNat + t.bytes ≤ r.size)
    (hd : decode t ((List.range t.bytes).map fun i => sh.bytes p.region (p.offset.toNat + i)) = some v) :
    (loadAt ctx t p).run sh = some (v, sh) := by
  have hl := log_loop_thread ctx p.region p.offset.toNat false r hs (List.range t.bytes) sh hr
  have hno : ¬ p.offset < 0 := by omega
  have hok : ¬ (r.align % alignment t ≠ 0 ∨ p.offset.toNat % alignment t ≠ 0 ∨ r.size < p.offset.toNat + t.bytes) := by
    omega
  simp [loadAt, place, StateT.run_bind, StateT.run_get, hr, lift, hno, hok, hl, hd, hs, -ne_eq]

theorem storeAt_run_thread (ctx : Ctx) (t : Ty) (p : Ptr) (r : Region) (sh : Shared) (v : Val) (bytes : List (BitVec 8))
    (hr : sh.regions p.region = some r) (hs : r.space = .thread) (ho : 0 ≤ p.offset)
    (ha : r.align % alignment t = 0) (hoa : p.offset.toNat % alignment t = 0) (hb : p.offset.toNat + t.bytes ≤ r.size)
    (he : encode t v = some bytes) :
    (storeAt ctx t p v).run sh = some ((), { sh with
      bytes := fun region => if region = p.region then writeBytes (sh.bytes region) p.offset.toNat bytes
        else sh.bytes region }) := by
  have hl := log_loop_thread ctx p.region p.offset.toNat true r hs (List.range t.bytes) sh hr
  have hno : ¬ p.offset < 0 := by omega
  have hok : ¬ (r.align % alignment t ≠ 0 ∨ p.offset.toNat % alignment t ≠ 0 ∨ r.size < p.offset.toNat + t.bytes) := by
    omega
  simp [storeAt, place, StateT.run_bind, StateT.run_get, hr, lift, hno, hok, hl, he, hs, -ne_eq,
    StateT.run_modify]

end Metal

import host.sim.OraclePrefix
import host.sim.Cases
import host.sim.template.base.Rel
import host.load.run.tail.Concrete
import host.load.run.full.SourceFirstStep
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Load Host.Load.Run.Full Host.Load.Run.Tail

/-! # The boot prefix and the readbacks of the decode route

The boot prefix to the first ordinary readback cut uses only the answers it consumes;
the world's readbacks after the first two tokens are the remaining tokens of the
valuation, as literals; the emitted numbers are the valuation's tokens. -/

/-! ## The boot prefix -/

/-- The answers the boot prefix consumes: `1 < T` and token 1 is not EOS (twice), `2 < T`. -/
def bootAnswers : List Ans :=
  [⟨.lt, .lit (.fin false 1 0), .var 0, true⟩, ⟨.eq, .lit (.fin false 248044 0), .var 1, false⟩,
   ⟨.lt, .lit (.fin false 1 0), .var 0, true⟩, ⟨.eq, .lit (.fin false 248044 0), .var 1, false⟩,
   ⟨.lt, .lit (.fin false 2 0), .var 0, true⟩]

kernel_rfl boot_answers : P.S0.oracle = bootAnswers ++ P.S3272.oracle

theorem good_bootAnswers {ρ : Nat → F64} {T t1 : Nat} (h0 : ρ 0 = F64.ofNat T) (h1 : ρ 1 = F64.ofNat t1)
    (hT : 3 ≤ T) (hTb : T < 2 ^ 53) (ht1 : t1 ≠ 248044) (ht1b : t1 < 2 ^ 53) : Good ρ bootAnswers := by
  have e1 : F64.fin false 1 0 = F64.ofNat 1 := fin_eq_ofNat 1 (by decide) (by decide)
  have e2 : F64.fin false 2 0 = F64.ofNat 2 := fin_eq_ofNat 2 (by decide) (by decide)
  have eE : F64.fin false 248044 0 = F64.ofNat 248044 := fin_eq_ofNat 248044 (by decide) (by decide)
  have l1 : F64.test .lt (F64.ofNat 1) (F64.ofNat T) = true := by
    rw [test_lt_ofNat 1 T (by decide) hTb]; exact decide_eq_true (by omega)
  have l2 : F64.test .lt (F64.ofNat 2) (F64.ofNat T) = true := by
    rw [test_lt_ofNat 2 T (by decide) hTb]; exact decide_eq_true (by omega)
  have q1 : F64.test .eq (F64.ofNat 248044) (F64.ofNat t1) = false := by
    rw [test_eq_ofNat 248044 t1 (by decide) ht1b]; exact decide_eq_false (Ne.symm ht1)
  intro q hq
  simp only [bootAnswers, List.mem_cons, List.not_mem_nil, or_false] at hq
  rcases hq with rfl | rfl | rfl | rfl | rfl <;>
    simp only [SymE.eval, h0, h1, e1, e2, eE, l1, l2, q1]

/-- **The boot prefix** with any unread readback suffix `τ`, from decode boundary 0
(`boot_tail`): running against the table instantiated at `ρ` reaches the first ordinary
readback cut with the cut's table, when the answers the prefix consumes are correct at `ρ`. -/
theorem prefix_run (τ : List NumV) (ρ : Nat → F64) (hg : Good ρ bootAnswers) :
    runC Host.Load.ffi 32711604 (P.ta0 τ) ⟨P.S0.tab.map (SymE.eval ρ)⟩ = some (P.ta3272 τ, Base.COf ρ) := by
  have hrun := runS_drop_suffix (tail_prefix τ) bootAnswers P.S3272.oracle [] boot_answers rfl
  obtain ⟨C, hC, hinst⟩ := run_sim P.F ρ 32711604 (P.ta0 τ) (P.ta3272 τ) { P.S0 with oracle := bootAnswers }
    { P.S3272 with oracle := [] } ⟨P.S0.tab.map (SymE.eval ρ)⟩ ⟨rfl, hg⟩ hrun
  obtain ⟨tab⟩ := C
  obtain ⟨htab, -⟩ := hinst
  change tab = _ at htab
  subst htab
  exact hC

/-! ## The readbacks and the valuation -/

/-- The world's readbacks after the first two tokens: tokens `3 … T` of `ρ`, as literals. -/
def tailReads (ρ : Nat → F64) (T : Nat) : List NumV := (List.range (T - 2)).map fun j => .lit (ρ (j + 3))

/-- The loop's readbacks: token `j + 2` at index `j`. -/
def loopReads (ρ : Nat → F64) (T : Nat) : List NumV := .ref 2 :: tailReads ρ T

theorem loopReads_length (ρ : Nat → F64) (T : Nat) : (loopReads ρ T).length = T - 2 + 1 := by
  simp [loopReads, tailReads]

kernel_rfl cut_tab1 : nth? P.S3272.tab 1 = some (.var 1)
kernel_rfl cut_tab2 : nth? P.S3272.tab 2 = some (.var 2)
kernel_rfl cut_emitted : arrOf P.s3272 12502 = [.num (.ref 1)]
kernel_rfl emitted_cell : lookupEnv chars!"emitted" (entryEnv P.s0) = some 2590

theorem cut_val (ρ : Nat → F64) {C : CSrv} (hC : CSrv.Le (Base.COf ρ) C) (k : Nat) (hk : k = 1 ∨ k = 2) :
    C.val (.ref k) = some (ρ k) := by
  apply hC.val
  rcases hk with rfl | rfl
  · show nth? (P.S3272.tab.map (SymE.eval ρ)) 1 = _
    rw [nth?_map, cut_tab1]; rfl
  · show nth? (P.S3272.tab.map (SymE.eval ρ)) 2 = _
    rw [nth?_map, cut_tab2]; rfl

/-- The template's valuation at the cut is the loop valuation of iteration 1. -/
theorem base_val {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {nx : Nat} (h0 : ρ 0 = F64.ofNat T)
    (h1 : ρ 1 = F64.ofNat (tk 1)) (h2 : ρ 2 = F64.ofNat (tk 2)) (h17 : ρ 17 = F64.ofNat nx) :
    Base.νOf ρ = loopVal ρ T (1 + 2) 1 (cap 1) (tk (1 + 1)) (tk 1) nx := by
  funext j
  match j with
  | 0 => exact h0
  | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 => rfl
  | 9 | 10 | 11 | 12 | 13 => rfl
  | 14 => exact h2
  | 15 => exact h1
  | 16 => rfl
  | 17 => exact h17
  | j + 18 => rfl

theorem mapM_num {C : CSrv} : ∀ (l : List NumV) (xs : List F64), l.length = xs.length →
    (∀ i (h1 : i < l.length) (h2 : i < xs.length), C.val l[i] = some xs[i]) →
      (l.map Val.num).mapM (fun v => match v with | .num n => C.val n | _ => none) = some xs
  | [], [], _, _ => rfl
  | [], _ :: _, hl, _ => by simp at hl
  | _ :: _, [], hl, _ => by simp at hl
  | a :: l, x :: xs, hl, h => by
    have h0 : C.val a = some x := h 0 (by simp) (by simp)
    have ih := mapM_num l xs (by simpa using hl) fun i h1 h2 => h (i + 1) (by simp; omega) (by simp; omega)
    simp [List.mapM_cons, h0, ih]

/-- The emitted numbers: tokens `1 … T` of `ρ`. -/
theorem emitted_numbers {ρ : Nat → F64} {T : Nat} {C : CSrv} {s : St LSt} (hT : 3 ≤ T)
    (hC : CSrv.Le (Base.COf ρ) C)
    (he : (bindingOf s (entryEnv P.s0) chars!"emitted").bind (Extract.elements s) =
      some (arrOf P.s3272 12502 ++ ((loopReads ρ T).take (T - 1)).map Val.num)) :
    emittedNumbers s (entryEnv P.s0) C = some ((List.range T).map fun k => ρ (k + 1)) := by
  unfold emittedNumbers emittedValues
  rw [he, cut_emitted]
  have hl : (loopReads ρ T).take (T - 1) = loopReads ρ T := by
    apply List.take_of_length_le; rw [loopReads_length]; omega
  rw [hl, Option.bind_some, show [Val.num (.ref 1)] ++ (loopReads ρ T).map Val.num =
    (NumV.ref 1 :: loopReads ρ T).map Val.num from rfl]
  apply mapM_num
  · simp [loopReads_length]; omega
  · intro i h1 h2
    simp only [List.getElem_map, List.getElem_range]
    match i, h1 with
    | 0, _ => exact cut_val ρ hC 1 (.inl rfl)
    | 1, _ => exact cut_val ρ hC 2 (.inr rfl)
    | j + 2, h1 =>
      have hj : j < (tailReads ρ T).length := by simp [loopReads, tailReads] at h1 ⊢; omega
      show C.val (tailReads ρ T)[j] = _
      simp only [tailReads, List.getElem_map, List.getElem_range, CSrv.val]

end Host.Load.Run.Tpl

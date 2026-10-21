import host.sim.LoopInv
import host.sim.Boot
import host.sim.extract.CacheFix
import host.sim.extract.GrowRun
import host.sim.template.Oracles
import host.sim.template.base.LoadR
import host.sim.template.ordinary.Case
import host.sim.template.clear.Case
import host.sim.template.growth.Case
import host.sim.template.fill.Case
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Load Host.Load.Run.Full Host.Load.Run.Tail

/-! # The decode loop for every token budget

From decode boundary 0, the boot prefix reaches the first ordinary readback cut
(`P.ta3272`), where the loop invariant holds at iteration 1; `T - 3` iterations, each
one of the four checked loop cases (`loopSel`), reach the invariant at iteration `T - 2`,
the final iteration. -/

/-! ## The loop cases -/

/-- A loop case with one more address its restart fixes. -/
def LoopCase.addFix {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}
    (c : LoopCase ok P s0 tab0 fixA) (a : Nat) (h : c.σ.a a = a) : LoopCase ok P s0 tab0 (fixA ++ [a]) :=
  { c with fix := fun b hb => (List.mem_append.1 hb).elim (c.fix b) fun hb' => by rw [List.mem_singleton.1 hb']; exact h }

/-- The loop's fixed addresses: the framed arrays, the `emitted` cell and the `cache` cell. -/
abbrev loopFixC : List Nat := loopFix ++ [cacheCell]

/-- The loop case of iteration `i`. -/
noncomputable def loopSel (i : Nat) : LoopCase ok loadP0 Base.s0 Base.S0.tab loopFixC :=
  if i % 256 = 0 then LoopCase.addFix CLEAR.loopCase cacheCell CLEAR.fixCache
  else if i % 256 = 253 then LoopCase.addFix FILL.loopCase cacheCell FILL.fixCache
  else if i % 256 = 254 then LoopCase.addFix GROWTH.loopCase cacheCell GROWTH.fixCache
  else LoopCase.addFix ORDINARY.loopCase cacheCell ORDINARY.fixCache

theorem loopSel_cases (i : Nat) :
    (i % 256 = 0 ∧ loopSel i = LoopCase.addFix CLEAR.loopCase cacheCell CLEAR.fixCache) ∨
      (i % 256 = 253 ∧ loopSel i = LoopCase.addFix FILL.loopCase cacheCell FILL.fixCache) ∨
      (i % 256 = 254 ∧ loopSel i = LoopCase.addFix GROWTH.loopCase cacheCell GROWTH.fixCache) ∨
      (i % 256 ≠ 0 ∧ i % 256 ≠ 253 ∧ i % 256 ≠ 254 ∧
        loopSel i = LoopCase.addFix ORDINARY.loopCase cacheCell ORDINARY.fixCache) := by
  unfold loopSel
  by_cases h0 : i % 256 = 0
  · exact .inl ⟨h0, by simp [h0]⟩
  · by_cases h3 : i % 256 = 253
    · exact .inr (.inl ⟨h3, by simp [h3]⟩)
    · by_cases h4 : i % 256 = 254
      · exact .inr (.inr (.inl ⟨h4, by simp [h4]⟩))
      · exact .inr (.inr (.inr ⟨h0, h3, h4, by simp [h0, h3, h4]⟩))

theorem loopSel_grow (i : Nat) : (loopSel i).grow = decide (i % 256 = 254) := by
  rcases loopSel_cases i with ⟨h, e⟩ | ⟨h, e⟩ | ⟨h, e⟩ | ⟨_, _, h, e⟩ <;> rw [e]
  · show false = decide (i % 256 = 254); simp [h]
  · show false = decide (i % 256 = 254); simp [h]
  · show true = decide (i % 256 = 254); simp [h]
  · show false = decide (i % 256 = 254); simp [h]

theorem loopSel_good {rest : Nat → F64} {T i tok ptok next : Nat} (hi1 : 1 ≤ i) (hT : i + 2 < T)
    (htok : tok ≠ 248044) (hTb : T < 2 ^ 29) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) (loopSel i).S0.oracle := by
  rcases loopSel_cases i with ⟨h, e⟩ | ⟨h, e⟩ | ⟨h, e⟩ | ⟨h0, h3, h4, e⟩ <;> rw [e]
  · exact CLEAR.good hi1 hT h htok hTb ht
  · exact FILL.good hi1 hT h htok hTb ht
  · exact GROWTH.good hi1 hT h htok hTb ht
  · exact ORDINARY.good hi1 hT h0 h3 h4 htok hTb ht

theorem loopSel_d (i : Nat) :
    (loopSel i).s1.next - Base.s0.next ≤ 151053 ∧ (loopSel i).s1.ffi.mlx.next - Base.s0.ffi.mlx.next ≤ 3738 ∧
      (loopSel i).s1.ffi.mlx.nnext - Base.s0.ffi.mlx.nnext ≤ 2445 := by
  rcases loopSel_cases i with ⟨_, e⟩ | ⟨_, e⟩ | ⟨_, e⟩ | ⟨_, _, _, e⟩ <;> rw [e]
  · exact ⟨CLEAR.dJ ▸ by decide, CLEAR.dH ▸ by decide, CLEAR.dN ▸ by decide⟩
  · exact ⟨FILL.dJ ▸ by decide, FILL.dH ▸ by decide, FILL.dN ▸ by decide⟩
  · exact ⟨GROWTH.dJ ▸ by decide, GROWTH.dH ▸ by decide, GROWTH.dN ▸ by decide⟩
  · exact ⟨ORDINARY.dJ ▸ by decide, ORDINARY.dH ▸ by decide, ORDINARY.dN ▸ by decide⟩

/-- **The loop invariant at the cut** (iteration 1). -/
theorem base_inv {Gx : Nat → Map → St LF.S → CSrv → Prop} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {nx : Nat}
    (ΔJ ΔH ΔN : Nat) (hT : 3 ≤ T) (h0 : ρ 0 = F64.ofNat T) (h1 : ρ 1 = F64.ofNat (tk 1))
    (h2 : ρ 2 = F64.ofNat (tk 2)) (h17 : ρ 17 = F64.ofNat nx) (hnx : nx ≤ 2 ^ 20)
    (hρ : ∀ k, 3 ≤ k → k ≤ T → ρ k = F64.ofNat (tk k))
    (hG : Gx 1 Base.M (P.ta3272 (tailReads ρ T)) (Base.COf ρ)) :
    LoopInv Gx loadP0 Base.s0 Base.S0.tab loopFixC ρ T tk (loopReads ρ T) (arrOf P.s3272 12502) ΔJ ΔH ΔN 1
      (P.ta3272 (tailReads ρ T)) (Base.COf ρ) := by
  have hjs := (Base.relJS ρ ⟨Base.S0.tab, []⟩ rfl (fun q hq => by cases hq)).setFfi (Base.Y (tailReads ρ T))
  have hr := hjs.toRel (FR := LR loadP0 (tailReads ρ T)) (Base.loadR _)
  rw [base_val h0 h1 h2 h17] at hr
  refine ⟨Base.M, Base.K, nx, arrOf P.s3272 2673447, ?_, ?_, rfl, rfl, rfl, ?_, hnx, ?_, ?_, ?_, ?_,
    fun _ _ => rfl, hG⟩
  · rw [ta3272_eq]; exact hr
  · show frOf Base.s0 (arrOf P.s3272 2673447) (arrOf P.s3272 12502) = _
    rfl
  · show some (NumV.ref 2) = some (Base.M.nv (.ref 79))
    rw [Base.num79]
  · intro j hj
    match j, hj with
    | 0, _ =>
      show (Base.COf ρ).val (.ref 2) = _
      rw [cut_val ρ ⟨[], by simp⟩ 2 (.inr rfl), h2]
    | j + 1, hj =>
      have hj' : j < T - 2 := by rw [loopReads_length] at hj; omega
      have hj'' : j < (tailReads ρ T).length := by simp [tailReads]; omega
      show (Base.COf ρ).val (tailReads ρ T)[j] = _
      simp only [tailReads, List.getElem_map, List.getElem_range, CSrv.val]
      rw [hρ (j + 3) (by omega) (by omega)]
  · show 0 ≤ _; exact Nat.zero_le _
  · rw [ta3272_eq]
    show Base.Y0.next ≤ Base.X0.next + (1 - 1) * ΔH
    rw [Base.next_same]; exact Nat.le_add_right _ _
  · rw [ta3272_eq]
    show Base.Y0.nnext ≤ Base.X0.nnext + (1 - 1) * ΔN
    rw [Base.nnext_same]; exact Nat.le_add_right _ _

theorem loopVal_vb {rest : Nat → F64} {T p i c tok ptok next : Nat} (hr : ∀ j, ∃ k ≤ 2 ^ 20, rest j = F64.ofNat k)
    (hT : T ≤ 2 ^ 20) (hp : p ≤ 2 ^ 20) (hi : i ≤ 2 ^ 20) (hc : c ≤ 2 ^ 20) (ht : tok ≤ 2 ^ 20)
    (hpt : ptok ≤ 2 ^ 20) (hn : next ≤ 2 ^ 20) : LoopVBOk (loopVal rest T p i c tok ptok next) := by
  intro v
  match v with
  | 0 => exact ⟨T, hT, rfl⟩
  | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 => exact hr _
  | 9 => exact ⟨p, hp, rfl⟩
  | 10 | 11 | 12 => exact ⟨i, hi, rfl⟩
  | 13 => exact ⟨i - 1, by show i - 1 ≤ 2 ^ 20; omega, rfl⟩
  | 14 => exact ⟨tok, ht, rfl⟩
  | 15 => exact ⟨ptok, hpt, rfl⟩
  | 16 => exact ⟨c, hc, rfl⟩
  | 17 => exact ⟨next, hn, rfl⟩
  | j + 18 => exact hr _

/-- **The loop for every token budget `T ≥ 3`**: from decode boundary 0 with the world's
readbacks after the first two tokens being tokens `3 … T` of `ρ`, the boot prefix and the
`T - 3` loop iterations reach the loop invariant at the final iteration `T - 2`. -/
theorem loop_reach {Gx : Nat → Map → St LF.S → CSrv → Prop}
    (T : Nat) (hT : 3 ≤ T) (hTb : T ≤ 262144) (ρ : Nat → F64) (tk : Nat → Nat)
    (h0 : ρ 0 = F64.ofNat T) (hρ : ∀ k, 1 ≤ k → k ≤ T → ρ k = F64.ofNat (tk k))
    (hnat : ∀ j, ∃ k ≤ 2 ^ 20, ρ j = F64.ofNat k) (htk : ∀ k, k ≤ T → tk k ≤ 2 ^ 20)
    (notEos : ∀ k, 1 ≤ k → k ≤ T → tk k ≠ 248044)
    (hG0 : Gx 1 Base.M (P.ta3272 (tailReads ρ T)) (Base.COf ρ))
    (hG : ∀ i, 1 ≤ i → i + 2 < T → LoopGStep Gx (loopSel i) ρ T tk (loopReads ρ T) i) :
    ∃ t C, runC Host.Load.ffi (32711604 + iterSteps (fun i => (loopSel i).n) 1 (T - 3)) (P.ta0 (tailReads ρ T))
        ⟨P.S0.tab.map (SymE.eval ρ)⟩ = some (t, C) ∧ CSrv.Le (Base.COf ρ) C ∧
      LoopInv Gx loadP0 Base.s0 Base.S0.tab loopFixC ρ T tk (loopReads ρ T) (arrOf P.s3272 12502) 151053 3738 2445
        (T - 2) t C := by
  have htk' : ∀ k, k ≤ T → tk k < 2 ^ 32 := fun k hk => by have := htk k hk; omega
  have hpre := prefix_run (tailReads ρ T) ρ (good_bootAnswers h0 (hρ 1 (by omega) (by omega)) hT (by omega)
    (notEos 1 (by omega) (by omega)) (by have := htk 1 (by omega); omega))
  obtain ⟨nx, hnx, h17⟩ := hnat 17
  have hinv1 := base_inv (Gx := Gx) (tk := tk) 151053 3738 2445 hT h0 (hρ 1 (by omega) (by omega))
    (hρ 2 (by omega) (by omega)) h17 hnx (fun k hk hkT => hρ k (by omega) hkT) hG0
  obtain ⟨t, C, hrL, hinv⟩ := loop_all (fun r => loadStepSim [2673447, 12502] r) rfl rfl rfl Base.loopStart
    loopSel hT (by rw [loopReads_length]; omega)
    (fun i hi1 hiT _ => loopSel_good hi1 hiT (notEos (i + 1) (by omega) (by omega)) (by omega) (htk' _ (by omega)))
    (fun i hi1 hiT nx hnx => loopVal_vb hnat (by omega) (by omega) (by omega) (by have := cap_le i; omega)
      (htk _ (by omega)) (htk _ (by omega)) hnx)
    loopSel_grow (by omega) (fun i _ => by have := cap_le i; omega) htk
    (fun i => (loopSel_d i).1) (fun i => (loopSel_d i).2.1) (fun i => (loopSel_d i).2.2)
    (by show T * 151053 < 2 ^ 61; omega)
    (by show Base.s0.ffi.mlx.next + T * 3738 + (131072 - Base.s0.ffi.mlx.next) < 2 ^ 46
        rw [Base.mnext_val]; omega)
    (by show Base.s0.ffi.mlx.nnext + T * 2445 + (2 ^ 40 - Base.s0.ffi.mlx.nnext) < 2 ^ 62
        rw [Base.mnnext_val]; omega)
    (fun r _ _ _ _ _ _ _ _ _ _ _ _ hK hν hr hok hrun ht => runOk_ngrow [2673447, 12502] r hK hν hr hok hrun ht)
    hG hinv1
  exact ⟨t, C, runC_trans hpre hrL, runC_le _ _ _ _ _ hrL, hinv⟩

end Host.Load.Run.Tpl

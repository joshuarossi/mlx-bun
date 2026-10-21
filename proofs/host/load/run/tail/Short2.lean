import host.load.run.tail.Prefix
import host.load.run.tail.Boot
import host.load.run.tail.Short2Chain
import host.ts.Loop
import host.sim.OraclePrefix
import host.sim.LoopArith
import host.load.run.full.SourceFirstStep
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

/- Decode boundary 0 to boundary 3123 for every unread suffix. -/
tail_compose P P.tailTo3123 :=
  P.tailGroup0 P.tailGroup1 P.tailGroup2 P.tailGroup3 P.tailGroup4 P.tailGroup5 P.tailGroup6 P.tailGroup7
  P.tailGroup8 P.tailGroup9 P.tailGroup10 P.tailGroup11 P.tailGroup12 P.tailGroup13 P.tailGroup14 P.tailGroup15
  P.tailGroup16 P.tailGroup17 P.tailGroup18 P.tailGroup19 P.tailGroup20 P.tailGroup21 P.tailGroup22 P.tailGroup23
  P.tailGroup24 P.tailGroup25 P.tailGroup26 P.tailGroup27 P.tailGroup28 P.tailGroup29 P.tailGroup30 P.tailGroup31
  P.tailGroup32 P.tailGroup33 P.tailGroup34 P.tailGroup35 P.tailGroup36 P.tailGroup37 P.tailGroup38 P.tailGroup39
  P.tailGroup40 P.tailGroup41 P.tailGroup42 P.tailGroup43 P.tailGroup44 P.tailGroup45 P.tailGroup46 P.tailGroup47
  P.tailGroup48 P.tailGroup49 P.tailGroup50 P.tailGroup51 P.tailGroup52 P.tailGroup53 P.tailGroup54 P.tailGroup55
  P.tailGroup56 P.tailGroup57 P.tailGroup58 P.tailGroup59 P.tailGroup60 P.tailGroup61 P.tailGroup62 P.tailGroup63
  P.tailGroup64 P.tailGroup65 P.tailGroup66 P.tailGroup67 P.tailGroup68 P.tailGroup69 P.tailGroup70 P.tailGroup71
  P.tailGroup72 P.tailGroup73 P.tailGroup74 P.tailGroup75 P.tailGroup76 P.tailGroup77 P.tailGroup78 P.tailGroup79
  P.tailGroup80 P.tailGroup81 P.tailGroup82 P.tailGroup83 P.tailGroup84 P.tailGroup85 P.tailGroup86 P.tailGroup87
  P.tailGroup88 P.tailGroup89 P.tailGroup90 P.tailGroup91 P.tailGroup92 P.tailGroup93 P.tailGroup94 P.tailGroup95
  P.tailGroup96 P.tac3104 P.tac3105 P.tac3106 P.tac3107 P.tac3108 P.tac3109 P.tac3110
  P.tac3111 P.tac3112 P.tac3113 P.tac3114 P.tac3115 P.tac3116 P.tac3117 P.tac3118
  P.tac3119 P.tac3120 P.tac3121 P.tac3122


end Host.Load.Run.Full

namespace Host.Load.Run.Tail
open Host.Ts Host.Ts.Sim Host.Load Host.Load.Run.Full

/-! # Budget 2

The route of the world `worldTail []` with budget `T = 2`: the decode prefix to
boundary 3123 (consuming the first three answers of `P.O`), then the branch
`Short2` (`Short2Stream`): token 1 is checked against EOS, the loop test
`2 < T` fails, token 2 is read and checked against EOS, and the epilogue halts. -/

/-- The answers the budget-2 route consumes. -/
def answersT2 : List Ans :=
  [⟨.lt, .lit (.fin false 1 0), .var 0, true⟩, ⟨.eq, .lit (.fin false 248044 0), .var 1, false⟩,
   ⟨.lt, .lit (.fin false 1 0), .var 0, true⟩, ⟨.eq, .lit (.fin false 248044 0), .var 1, false⟩,
   ⟨.lt, .lit (.fin false 2 0), .var 0, false⟩, ⟨.eq, .lit (.fin false 248044 0), .var 2, false⟩]

kernel_rfl_eager short2_answers : P.O.take 3 ++ Short2.O = answersT2

theorem good_answersT2 {ρ : Nat → F64} {t1 t2 : Nat} (h0 : ρ 0 = F64.ofNat 2) (h1 : ρ 1 = F64.ofNat t1)
    (h2 : ρ 2 = F64.ofNat t2) (ht1 : t1 ≠ 248044) (ht1b : t1 < 2 ^ 53) (ht2 : t2 ≠ 248044)
    (ht2b : t2 < 2 ^ 53) : Good ρ answersT2 := by
  have e1 : F64.fin false 1 0 = F64.ofNat 1 := fin_eq_ofNat 1 (by decide) (by decide)
  have e2 : F64.fin false 2 0 = F64.ofNat 2 := fin_eq_ofNat 2 (by decide) (by decide)
  have eE : F64.fin false 248044 0 = F64.ofNat 248044 := fin_eq_ofNat 248044 (by decide) (by decide)
  have l1 : F64.test .lt (F64.ofNat 1) (F64.ofNat 2) = true := by
    rw [test_lt_ofNat 1 2 (by decide) (by decide)]; rfl
  have l2 : F64.test .lt (F64.ofNat 2) (F64.ofNat 2) = false := by
    rw [test_lt_ofNat 2 2 (by decide) (by decide)]; rfl
  have q1 : F64.test .eq (F64.ofNat 248044) (F64.ofNat t1) = false := by
    rw [test_eq_ofNat 248044 t1 (by decide) ht1b]; exact decide_eq_false (Ne.symm ht1)
  have q2 : F64.test .eq (F64.ofNat 248044) (F64.ofNat t2) = false := by
    rw [test_eq_ofNat 248044 t2 (by decide) ht2b]; exact decide_eq_false (Ne.symm ht2)
  intro q hq
  simp only [answersT2, List.mem_cons, List.not_mem_nil, or_false] at hq
  rcases hq with rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp only [SymE.eval, h0, h1, h2, e1, e2, eE, l1, l2, q1, q2]

kernel_rfl_eager short2_ctl : Short2.s2.ctl = .halt (.normal .undef)
kernel_rfl_eager short2_isHalt : isHalt Short2.s2.ctl = true
kernel_rfl_eager short2_emitted : emittedValues Short2.s2 (entryEnv P.s0) = some [.num (.ref 1), .num (.ref 2)]
kernel_rfl_eager short2_val1 : Short2.S2.val (.ref 1) = some (.var 1)
kernel_rfl_eager short2_val2 : Short2.S2.val (.ref 2) = some (.var 2)
/- The halted state's native readbacks: node 17776 holds `.ref 1`, node 20157
holds `.ref 2`; `nnext = 20158`; the queue is empty. -/
kernel_rfl_eager short2_items1 : (Short2.s2.ffi : LSt).mlx.items.get 17776 = some (.ref 1)
kernel_rfl_eager short2_items2 : (Short2.s2.ffi : LSt).mlx.items.get 20157 = some (.ref 2)
kernel_rfl_eager short2_nnext : (Short2.s2.ffi : LSt).mlx.nnext = 20158
kernel_rfl_eager short2_tokens : (Short2.s2.ffi : LSt).mlx.tokens = []

/-- The symbolic budget-2 route from decode boundary 0 to the halted state. -/
theorem short2_run : runS P.F 31220621 (P.ta0 []) ⟨P.S0.tab, answersT2⟩ = some (Short2.s2, Short2.S2) := by
  have h1 := runS_drop_suffix (P.tailTo3123 []) (P.O.take 3) (P.O.drop 3) [] (List.take_append_drop 3 P.O).symm rfl
  have h2 := runS_append P.F Short2.O _ _ _ _ _ h1
  have h3 := runS_trans P.F h2 Short2.run
  rw [← short2_answers]
  exact h3

/-- **Budget 2.** Booting `worldTail []` and running against the table instantiated
at `ρ` halts normally having emitted tokens 1 and 2, when the consumed answers are
correct at `ρ`. -/
theorem source_T2 (ρ : Nat → F64) (hg : Good ρ answersT2) :
    ∃ N, (∀ n, N ≤ n → (bootL Route.cx (worldTail []) 2000).bind
        (fun s => runC Host.Load.ffi n s ⟨P.S0.tab.map (SymE.eval ρ)⟩) = some (Short2.s2, ⟨Short2.S2.tab.map (SymE.eval ρ)⟩)) ∧
      (∃ v, Short2.s2.ctl = .halt (.normal v)) ∧
      emittedNumbers Short2.s2 (entryEnv P.s0) ⟨Short2.S2.tab.map (SymE.eval ρ)⟩ = some [ρ 1, ρ 2] := by
  refine ⟨31220621, ?_, ⟨.undef, short2_ctl⟩, ?_⟩
  · intro n hn
    obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hn
    have hrun := runS_trans P.F short2_run (runS_halted P.F Short2.S2 short2_isHalt d)
    obtain ⟨C, hC, hinst⟩ := run_sim P.F ρ _ _ _ ⟨P.S0.tab, answersT2⟩ _ ⟨P.S0.tab.map (SymE.eval ρ)⟩ (And.intro rfl hg) hrun
    unfold Inst at hinst
    obtain ⟨tab⟩ := C
    obtain ⟨htab, -⟩ := hinst
    change tab = _ at htab
    subst htab
    exact (congrArg (fun o => o.bind fun s => runC Host.Load.ffi (31220621 + d) s ⟨P.S0.tab.map (SymE.eval ρ)⟩)
      (boot_tail [])).trans ((Option.bind_some _ _).trans hC)
  · unfold emittedNumbers
    rw [short2_emitted]
    simp only [Option.bind_some, List.mapM_cons, List.mapM_nil, val_inst (ρ := ρ) (S := Short2.S2) (C := ⟨Short2.S2.tab.map (SymE.eval ρ)⟩) rfl, short2_val1,
      short2_val2, Option.map_some]
    rfl

end Host.Load.Run.Tail

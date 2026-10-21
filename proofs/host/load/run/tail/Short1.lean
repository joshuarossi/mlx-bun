import host.load.run.tail.Prefix
import host.load.run.tail.Boot
import host.load.run.tail.Short1Chain
import host.ts.Loop
import host.sim.OraclePrefix
import host.sim.LoopArith
import host.load.run.full.SourceFirstStep
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

/- Decode boundary 0 to boundary 2973 for every unread suffix. -/
tail_compose P P.tailTo2973 :=
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
  P.tailGroup88 P.tailGroup89 P.tailGroup90 P.tailGroup91 P.tac2944 P.tac2945 P.tac2946 P.tac2947
  P.tac2948 P.tac2949 P.tac2950 P.tac2951 P.tac2952 P.tac2953 P.tac2954 P.tac2955
  P.tac2956 P.tac2957 P.tac2958 P.tac2959 P.tac2960 P.tac2961 P.tac2962 P.tac2963
  P.tac2964 P.tac2965 P.tac2966 P.tac2967 P.tac2968 P.tac2969 P.tac2970 P.tac2971
  P.tac2972


end Host.Load.Run.Full

namespace Host.Load.Run.Tail
open Host.Ts Host.Ts.Sim Host.Load Host.Load.Run.Full

/-! # Budget 1

The route of the world `worldTail []` with budget `T = 1`: the decode prefix to
boundary 2973 (no answer consumed), then the branch `Short1` (`Short1Stream`):
the loop test `1 < T` fails, token 1 is checked against EOS, and the epilogue
halts. -/

/-- The answers the budget-1 route consumes: `1 < T` fails (twice) and token 1 is not EOS. -/
def answersT1 : List Ans :=
  [⟨.lt, .lit (.fin false 1 0), .var 0, false⟩, ⟨.lt, .lit (.fin false 1 0), .var 0, false⟩,
   ⟨.eq, .lit (.fin false 248044 0), .var 1, false⟩]

kernel_rfl_eager short1_answers : P.O.take 0 ++ Short1.O = answersT1

theorem good_answersT1 {ρ : Nat → F64} {t1 : Nat} (h0 : ρ 0 = F64.ofNat 1) (h1 : ρ 1 = F64.ofNat t1)
    (ht1 : t1 ≠ 248044) (ht1b : t1 < 2 ^ 53) : Good ρ answersT1 := by
  have e1 : F64.fin false 1 0 = F64.ofNat 1 := fin_eq_ofNat 1 (by decide) (by decide)
  have eE : F64.fin false 248044 0 = F64.ofNat 248044 := fin_eq_ofNat 248044 (by decide) (by decide)
  have l1 : F64.test .lt (F64.ofNat 1) (F64.ofNat 1) = false := by
    rw [test_lt_ofNat 1 1 (by decide) (by decide)]; rfl
  have q1 : F64.test .eq (F64.ofNat 248044) (F64.ofNat t1) = false := by
    rw [test_eq_ofNat 248044 t1 (by decide) ht1b]; exact decide_eq_false (Ne.symm ht1)
  intro q hq
  simp only [answersT1, List.mem_cons, List.not_mem_nil, or_false] at hq
  rcases hq with rfl | rfl | rfl <;> simp only [SymE.eval, h0, h1, e1, eE, l1, q1]

kernel_rfl_eager short1_ctl : Short1.s4.ctl = .halt (.normal .undef)
kernel_rfl_eager short1_isHalt : isHalt Short1.s4.ctl = true
kernel_rfl_eager short1_emitted : emittedValues Short1.s4 (entryEnv P.s0) = some [.num (.ref 1)]
kernel_rfl_eager short1_val1 : Short1.S4.val (.ref 1) = some (.var 1)
/- The halted state's native readbacks: node 17776 holds `.ref 1`; `nnext = 17777`;
`.ref 2` is still unread. -/
kernel_rfl_eager short1_items : (Short1.s4.ffi : LSt).mlx.items.get 17776 = some (.ref 1)
kernel_rfl_eager short1_nnext : (Short1.s4.ffi : LSt).mlx.nnext = 17777
kernel_rfl_eager short1_tokens : (Short1.s4.ffi : LSt).mlx.tokens = [.ref 2]

/-- The symbolic budget-1 route from decode boundary 0 to the halted state. -/
theorem short1_run : runS P.F 29727843 (P.ta0 []) ⟨P.S0.tab, answersT1⟩ = some (Short1.s4, Short1.S4) := by
  have h1 := runS_drop_suffix (P.tailTo2973 []) [] P.O [] rfl rfl
  have h2 := runS_append P.F Short1.O _ _ _ _ _ h1
  have h3 := runS_trans P.F h2 Short1.run
  rw [← short1_answers]
  exact h3

/-- **Budget 1.** Booting `worldTail []` and running against the table instantiated
at `ρ` halts normally having emitted token 1, when the consumed answers are
correct at `ρ`. -/
theorem source_T1 (ρ : Nat → F64) (hg : Good ρ answersT1) :
    ∃ N, (∀ n, N ≤ n → (bootL Route.cx (worldTail []) 2000).bind
        (fun s => runC Host.Load.ffi n s ⟨P.S0.tab.map (SymE.eval ρ)⟩) = some (Short1.s4, ⟨Short1.S4.tab.map (SymE.eval ρ)⟩)) ∧
      (∃ v, Short1.s4.ctl = .halt (.normal v)) ∧
      emittedNumbers Short1.s4 (entryEnv P.s0) ⟨Short1.S4.tab.map (SymE.eval ρ)⟩ = some [ρ 1] := by
  refine ⟨29727843, ?_, ⟨.undef, short1_ctl⟩, ?_⟩
  · intro n hn
    obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hn
    have hrun := runS_trans P.F short1_run (runS_halted P.F Short1.S4 short1_isHalt d)
    obtain ⟨C, hC, hinst⟩ := run_sim P.F ρ _ _ _ ⟨P.S0.tab, answersT1⟩ _ ⟨P.S0.tab.map (SymE.eval ρ)⟩ (And.intro rfl hg) hrun
    unfold Inst at hinst
    obtain ⟨tab⟩ := C
    obtain ⟨htab, -⟩ := hinst
    change tab = _ at htab
    subst htab
    exact (congrArg (fun o => o.bind fun s => runC Host.Load.ffi (29727843 + d) s ⟨P.S0.tab.map (SymE.eval ρ)⟩)
      (boot_tail [])).trans ((Option.bind_some _ _).trans hC)
  · unfold emittedNumbers
    rw [short1_emitted]
    change (CSrv.val ⟨Short1.S4.tab.map (SymE.eval ρ)⟩ (.ref 1)).bind (fun v => some [v]) = some [ρ 1]
    rw [val_inst (ρ := ρ) (S := Short1.S4) (C := ⟨Short1.S4.tab.map (SymE.eval ρ)⟩) rfl (.ref 1), short1_val1]
    rfl

end Host.Load.Run.Tail

import host.sim.compose.a4b.FillSetupCall
import host.sim.compose.Literal

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupChunk
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route

kernel_rfl chunkLiteral6 : PRE_setup_early_r0.s6.ctl = .ret (.num (.lit (F64.ofNat 2048)))
kernel_rfl chunkFresh10 : (PRE_setup_early_r0.S6.tab.all fun e => e.noVar 10) = true

/-- The canonical heap's numeric references precede the C entry. -/
def baseNums : Prop := ∀ a o, PRE_setup_early_r0.s6.heap.get a = some o →
  Supp.hobj (fun _ => True) 10 o

/-- The shared setup continuation receives C in fresh variable 10.  Its source
state and table are exactly the post-compaction literal abstraction. -/
noncomputable def setupChunkCCut (NB T : Nat) (tk : Nat → Nat) (L : Nat) : ICut FF :=
  { pbCut (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      setupJ wideP [(9, .L), (10, .C)]
      (PRE_setup_early_r0.s6.ret (.num (.ref PRE_setup_early_r0.S6.tab.length)))
      ⟨PRE_setup_early_r0.S6.tab ++ [.var 10], []⟩ (setupI L) with
    B := fun x => chunkBook L x ∧ fixedCells x ∧ x.M.num 10 = .lit (F64.ofNat (chunkC L)) ∧
      setupInputs T tk x ∧ baseNums }

/-- Concrete K8-to-C seam: no target step, no native change, same prompt,
context and fixed cells. -/
theorem chunk_abstractC {NB T L : Nat} {tk : Nat → Nat} (h1 : 1 ≤ L) (h8 : L ≤ 8) :
    CutConv (withSetupInputs T tk (setupChunkCut NB T tk L)) (setupChunkCCut NB T tk L) := by
  apply cut_abstractLitJ (fullRXD_laws { setupP with rest := machReads T tk } NB) chunkLiteral6
    (fun e he => List.all_eq_true.mp chunkFresh10 e he)
  rintro x hq ⟨hb, hkeep⟩ hr
  have hval := bindQuantity (v := 10) (c := 2048) (q := Q.C) hq.1 hq.2.2
    (by
      intro p hp
      have he : p = (9, Q.L) := List.mem_singleton.mp hp
      subst p
      decide)
    (by change 2048 = chunkC L; exact (chunkC2048 h1 h8).symm)
    (by decide : 2048 ≤ loopVB 10)
  refine ⟨⟨hval.1, hq.2.1, hval.2⟩, hb.1, ?_, ?_, ⟨?_, ?_⟩, ?_⟩
  · have he := Map.setNum_ext x.M PRE_setup_early_r0.S6.tab.length (.lit (F64.ofNat 2048))
    exact ⟨(congrFun he.a 2586).trans hb.2.1, (congrFun he.a 2589).trans hb.2.2⟩
  · have hn : PRE_setup_early_r0.S6.tab.length = 10 := by rw [canonicalTable]; rfl
    change (x.M.setNum PRE_setup_early_r0.S6.tab.length (.lit (F64.ofNat 2048))).num 10 = _
    rw [hn, Map.setNum_self, chunkC2048 h1 h8]
  · intro j hj
    change upd x.ν 10 (F64.ofNat 2048) j = _
    rw [upd_other _ _ (by omega : j ≠ 10)]
    exact hkeep.1 j hj
  · exact (congrFun (Map.setNum_ext x.M PRE_setup_early_r0.S6.tab.length (.lit (F64.ofNat 2048))).a 2590).trans hkeep.2
  · intro a o ho
    exact Supp.hobj_mono (fun _ _ => trivial) (show PRE_setup_early_r0.S6.tab.length ≤ 10 by
      rw [canonicalTable]; decide) (hr.heapSupp a o ho)

end Host.Ts.Sim.Compose.SetupChunk

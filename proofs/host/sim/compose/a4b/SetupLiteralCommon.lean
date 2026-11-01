import host.sim.compose.a4b.SetupCommon

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupCommon
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- All chunk classes retain this frame; their compacted address offsets may differ. -/
def ChunkBook (L : Nat) (x : SegInst FF) : Prop :=
  (Disp.KpJ setupJ 4096 x.K ∧ x.K.fr 4910 = none ∧
  ∃ π : List Nat, π.length = L ∧ (∀ t ∈ π, t < 248320) ∧
    x.K.fr 2665 = some ([], π.map natV) ∧ AneFresh x.t) ∧ (L ≤ 8 → x.K.D = 13) ∧ x.K.D ≤ 3526

noncomputable def literalCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (c : Nat) (i : Cls.Inst) : ICut FF :=
  { pbCut (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) setupJ wideP [(9, .L)]
      ((PRE_setup_early_r0.s6 : St FF.S).ret (.num (.lit (F64.ofNat c)))) PRE_setup_early_r0.S6 i with
    B := fun x => ChunkBook i.L x ∧ setupInputs T tk x ∧ fixedCells x ∧ PromptFr π x ∧ NativeAt 0 0 PRE_setup_early_r0.s6 x.t }

/-- Any checked chunk literal reaches the same C-reference template in zero steps. -/
theorem abstractChunk {NB T c : Nat} {tk : Nat → Nat} {ρ : List Nat} {i : Cls.Inst} {Mem : SegInst FF → Prop}
    (hC : i.C = c) (hchunk : c = chunkC i.L) (hbound : c ≤ loopVB 10)
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) :
    CutConv (withMem Mem (literalCut NB T tk ρ c i)) (withMem Mem (cut NB T tk ρ PRE_g0b.s0 PRE_g0b.S0 i)) := by
  rintro x ⟨hr, hq⟩ ⟨⟨hb, hv, hids, hpin, hnat⟩, hm⟩
  obtain ⟨⟨hk, hmemo, π, hlen, hvocab, hframe, hfresh⟩, hsmall⟩ := hb
  have ha := hr.abstractRetLitJ (fullRXD_laws { setupP with rest := machReads T tk } NB) rfl
    (fun e he => List.all_eq_true.mp chunkFresh10 e he) (fun _ h => nomatch h)
  have hn : PRE_setup_early_r0.S6.tab.length = 10 := by rw [canonicalTable]; rfl
  have hval := bindQuantity (v := 10) (c := c) (q := Q.C) hq.1 hq.2.2
    (by intro p hp; have he := List.mem_singleton.mp hp; subst p; decide)
    hC.symm hbound
  let y : SegInst FF := { x with
    M := x.M.setNum PRE_setup_early_r0.S6.tab.length (.lit (F64.ofNat c))
    ν := upd x.ν 10 (F64.ofNat c) }
  have he := Map.setNum_ext x.M PRE_setup_early_r0.S6.tab.length (.lit (F64.ofNat c))
  refine ⟨y, rfl, rfl, ⟨?_, hval.1, hq.2.1, hval.2⟩,
    ⟨⟨⟨hk, hmemo, π, hlen, hvocab, hframe, hfresh, ?_⟩, ?_, ?_, hsmall⟩, ?_⟩,
    hMem x y (NTrack.conv rfl rfl he.node (congrFun he.a 12504)) hm⟩
  · change RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP []
      y.M y.ν y.K (PRE_g0b.s0 : St FF.S) ⟨PRE_g0b.S0.tab, []⟩ y.t y.C
    have hs : (PRE_g0b.s0 : St FF.S) =
        (PRE_setup_early_r0.s6 : St FF.S).ret (.num (.ref PRE_setup_early_r0.S6.tab.length)) := start_eq
    rw [hs, startTable]
    exact ha
  · change (x.M.setNum PRE_setup_early_r0.S6.tab.length (.lit (F64.ofNat c))).num 10 = _
    rw [hn, Map.setNum_self, hchunk]
  · refine ⟨?_, (congrFun he.a 2590).trans hv.2⟩
    intro j hj
    change upd x.ν 10 (F64.ofNat c) j = _
    rw [upd_other _ _ (by omega : j ≠ 10)]
    exact hv.1 j hj
  · intro a o ho
    exact Supp.hobj_mono (fun _ _ => trivial) (show PRE_setup_early_r0.S6.tab.length ≤ 10 by
      rw [canonicalTable]; decide) (hr.heapSupp a o ho)
  · refine ⟨⟨(congrFun he.a 2586).trans hids.1, (congrFun he.a 2589).trans hids.2⟩, hpin, ?_⟩
    have hs : (PRE_g0b.s0 : St FF.S) =
        (PRE_setup_early_r0.s6 : St FF.S).ret (.num (.ref PRE_setup_early_r0.S6.tab.length)) := start_eq
    change NativeAt 0 0 (PRE_g0b.s0 : St FF.S) x.t
    rw [hs]
    exact hnat

end Host.Ts.Sim.Compose.SetupCommon

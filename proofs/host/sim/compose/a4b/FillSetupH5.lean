import host.sim.compose.a4b.SetupH5

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupH5
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly

theorem rowFacts {i : Cls.Inst} (hi : InRow setup_h5.r0 i) : 8 < i.L ∧ i.C = 64 := by
  obtain ⟨_, x, hx, hq⟩ := hi
  simp only [setup_h5.r0, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
  omega

theorem oldCallConv {NB T L : Nat} {tk : Nat → Nat} {π : List Nat} {Mem : SegInst FF → Prop} :
    CutConv (withMem Mem (withSetupPin T tk π (SetupChunk.chunkCallFixedCut NB T tk L)))
      (withMem Mem (withSetupPin T tk π (chunkCallFixedCut NB T tk L))) := by
  rintro x ⟨hr, hq⟩ ⟨⟨hb, hv, hp, hn⟩, hm⟩
  refine ⟨x, rfl, rfl, ⟨?_, hq⟩, ⟨hb, hv, hp, ?_⟩, hm⟩
  · change RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP []
      x.M x.ν x.K (PRE_setup_h5_chunk.s0 : St FF.S) ⟨PRE_setup_h5_chunk.S0.tab, []⟩ x.t x.C
    rw [startEq, startTab]
    exact hr
  · change NativeAt 0 0 (PRE_setup_h5_chunk.s0 : St FF.S) x.t
    rw [startEq]
    exact hn

theorem toLiteral {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {Mem : SegInst FF → Prop} (hL : 8 < i.L) :
    CutConv (withMem Mem (withSetupPin T tk π (setupChunkCut NB T tk i.L)))
      (withMem Mem (SetupCommon.literalCut NB T tk π 64 i)) := by
  rintro x ⟨hr, hq⟩ ⟨⟨⟨hb, hids⟩, hv, hp, hn⟩, hm⟩
  obtain ⟨hk, hmemo, π', hlen, hvocab, hframe, hd, hfresh⟩ := hb
  refine ⟨x, rfl, rfl, ⟨?_, hq.1, hq.2.1, ?_⟩,
    ⟨⟨⟨hk, hmemo, π', hlen, hvocab, hframe, hfresh⟩, ?_⟩, hv, hids, hp, ?_⟩, hm⟩
  · change RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP []
      x.M x.ν x.K (PRE_setup_h5_chunk.s2 : St FF.S) ⟨PRE_setup_h5_chunk.S2.tab, []⟩ x.t x.C at hr
    rw [canonicalEq, canonicalTab] at hr
    exact hr
  · exact ⟨hq.2.2.1, trivial⟩
  · exact ⟨by intro h8; omega, by change x.K.D ≤ 3526; omega⟩
  · change NativeAt 0 0 (PRE_setup_h5_chunk.s2 : St FF.S) x.t at hn
    rw [canonicalEq] at hn
    exact hn

noncomputable def chunk_K64__g0a__g0b (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (Mem : Nat → SegInst FF → Prop)
    (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    StagePiece FF [setup_h5.r0] [⟨[(0, .L)], Stage.ChunkSize.K64.O⟩]
      (fun i => withMem (Mem i.L) (withSetupPin T tk π (SetupChunk.chunkCallFixedCut NB T tk i.L)))
      (fun i => withMem (Mem i.L) (SetupCommon.cut NB T tk π PRE_g0b.s0 PRE_g0b.S0 i)) where
  m := [(9, .L)]
  n := PRE_setup_h5_chunk.st0.tpl.n + 1
  O := PRE_setup_h5_chunk.st0.S0.oracle
  chk r hr := by
    obtain rfl := List.mem_singleton.mp hr
    exact List.all_eq_true.mp PRE_setup_h5_chunk.chk_site0 _ (by simp)
  ok r hr i hi _ := by
    obtain rfl := List.mem_singleton.mp hr
    have horacle : ∀ ν, MapOk ν (setupI i.L) [(9, .L)] → Good ν PRE_setup_h5_chunk.st0.S0.oracle := by
      intro ν hm
      exact good_of_row (List.all_eq_true.mp PRE_setup_h5_chunk.chk_site0 _ (by simp)) hi
        (show MapOk ν i [(9, .L)] from ⟨hm.1, trivial⟩)
    obtain ⟨hL, hC⟩ := rowFacts hi
    have hchunk : 64 = chunkC i.L :=
      hC.symm.trans (FillSetupEarly.setupC (by simp [FillSetupEarly.setupRows]) hi)
    exact StageCall.intro oldCallConv ((chunkCall_merged_keeps horacle).pinMem T tk π (hMem i.L))
      ((merged_compact_keeps.pinMem T tk π (hMem i.L)).trans
        ((toLiteral hL).trans (SetupCommon.abstractChunk hC hchunk (by decide) (hMem i.L))))

end Host.Ts.Sim.Compose.SetupH5

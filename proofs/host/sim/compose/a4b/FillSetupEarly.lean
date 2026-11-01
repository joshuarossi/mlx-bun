import host.sim.compose.a4b.SetupLiteralCommon
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FillSetupEarly
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupChunk

private theorem ret_same {S : Type} {s : St S} {v : Val} (hc : s.ctl = .ret v) : s.ret v = s := by
  cases s
  cases hc
  rfl

theorem toLiteral {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {Mem : SegInst FF → Prop} :
    CutConv (withMem Mem (withSetupPin T tk π (setupChunkCut NB T tk i.L)))
      (withMem Mem (SetupCommon.literalCut NB T tk π 2048 i)) := by
  rintro x ⟨hr, hq⟩ ⟨⟨⟨hb, hids⟩, hv, hp, hn⟩, hm⟩
  obtain ⟨hk, hmemo, π', hlen, hvocab, hframe, hd, hfresh⟩ := hb
  have hs : (PRE_setup_early_r0.s6 : St FF.S).ret (.num (.lit (F64.ofNat 2048))) = PRE_setup_early_r0.s6 :=
    ret_same chunkLiteral6
  refine ⟨x, rfl, rfl, ⟨?_, hq.1, hq.2.1, ?_⟩,
    ⟨⟨⟨hk, hmemo, π', hlen, hvocab, hframe, hfresh⟩, ?_⟩, hv, hids, hp, hn⟩, hm⟩
  · change RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP []
      x.M x.ν x.K ((PRE_setup_early_r0.s6 : St FF.S).ret (.num (.lit (F64.ofNat 2048))))
      ⟨PRE_setup_early_r0.S6.tab, []⟩ x.t x.C
    rw [hs]
    exact hr
  · exact ⟨hq.2.2.1, trivial⟩
  · exact ⟨fun _ => hd, by change x.K.D ≤ 3526; rw [hd]; decide⟩

/-- K8's concrete site run and compaction, then the same literal seam as every other class. -/
noncomputable def chunk_K8__g0a__g0b (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (Mem : Nat → SegInst FF → Prop)
    (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    StagePiece FF [setup_early.r0] [⟨[(0, .L)], Stage.ChunkSize.K8.O⟩]
      (fun i => withMem (Mem i.L) (withSetupPin T tk π (chunkCallFixedCut NB T tk i.L)))
      (fun i => withMem (Mem i.L) (SetupCommon.cut NB T tk π PRE_g0b.s0 PRE_g0b.S0 i)) where
  m := [(9, .L)]
  n := 101
  O := PRE_setup_early_r0.st0.S0.oracle
  chk := (chunk_K8_literal NB T tk π Mem hMem).chk
  ok r hr i hi ho := by
    have er : r = setup_early.r0 := List.mem_singleton.mp hr
    subst r
    obtain ⟨h1, h8⟩ := bounds hi
    have hC := setupC (i := i) (List.mem_cons_self : setup_early.r0 ∈ setupRows) hi
    have h2048 := chunkC2048 h1 h8
    exact StageCall.intro (CutConv.refl _) ((chunk_K8_literal NB T tk π Mem hMem).ok _ hr i hi ho).step
      (toLiteral.trans (SetupCommon.abstractChunk (hC.trans h2048) h2048.symm (by decide) (hMem i.L)))

end Host.Ts.Sim.Compose.FillSetupEarly

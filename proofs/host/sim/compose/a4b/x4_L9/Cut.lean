import host.sim.compose.a4b.x4_L9.G1Input
import host.sim.compose.a4b.VWG1
import host.sim.compose.a4b.VWBodyBase
import host.sim.template.a4pre_first_tail_x4_L9_r0.SiteZ1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-! # The class's cuts, to its dispatch

The prefill's step is the wide rows'. From there the class has its own chain, the chunk's length a literal. -/

noncomputable def afterCut (NB T : Nat) (tk : Nat → Nat) (ρ : List Nat) (i : Cls.Inst) : ICut FF :=
  { pbCut (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) setupJ wideP npsMap PRE_first_tail_x4_L9_r0.s19 PRE_first_tail_x4_L9_r0.S19 i with
    B := fun x => afterNpsBook T i.L tk x ∧ PromptFr ρ x ∧ NativeAt 0 0 PRE_first_tail_x4_L9_r0.s19 x.t }

noncomputable def typedCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (s : St FF.S) (S : SSrv) (i : Cls.Inst)
    (Dmax : Nat := 3540) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S => ∃ K0,
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] x.M x.ν x.K s S x.t x.C ∧
    ForwardBook i π K0 x Dmax ∧ InputAt (π.take i.n) (x.M.node 15235) x.t x.C ∧
    setupInputs T tk x ∧ MapOk x.ν i npsMap
  B := fun x => AneFresh x.t ∧ fixedCells x ∧ NativeAt 0 0 s x.t

noncomputable abbrev dispatchCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) :=
  typedCut NB T tk π PRE_first_tail_x4_L9_r0.s38 PRE_first_tail_x4_L9_r0.S38

kernel_rfl npsPromptEmpty : arrOf PRE_first_tail_x4_L9_r0.s0 2665 = []

kernel_rfl s19Eq : PRE_first_tail_x4_L9_r0.s19 = PRE_first_tail_x15_r0.s19
kernel_rfl s19Tab : PRE_first_tail_x4_L9_r0.S19.tab = PRE_first_tail_x15_r0.S19.tab

/-- The wide rows' cut after the prefill's step. -/
theorem toAfter {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) (hn : i.n ≤ loopVB 1087) :
    CutConv (withMem Mem (VWFirst.afterNpsCut NB T tk π i)) (withMem Mem (afterCut NB T tk π i)) := by
  rintro x ⟨hr, hq⟩ ⟨⟨hb, hp, hnat⟩, hm⟩
  refine ⟨x, rfl, rfl, ⟨?_, hq⟩, ⟨hb, hp, ?_⟩, hm⟩
  · change RelB FF _ wideP [] x.M x.ν x.K PRE_first_tail_x4_L9_r0.s19 ⟨PRE_first_tail_x4_L9_r0.S19.tab, []⟩ x.t x.C
    rw [s19Eq, s19Tab]
    exact hr
  · rw [s19Eq]
    exact hnat

kernel_rfl cnt38 : countersOkB PRE_first_tail_x4_L9_r0.s19 PRE_first_tail_x4_L9_r0.s38 = true

theorem inactive19 : (bridgeOf PRE_first_tail_x4_L9_r0.s19.ffi).active = false := PRE_first_tail_x4_L9_r0.zbin1
private theorem bridge33 : bridgeOf PRE_first_tail_x4_L9_r0.s33.ffi = bridgeOf PRE_first_tail_x4_L9_r0.s19.ffi :=
  PRE_first_tail_x4_L9_r0.stepA11.dst_bridge.trans PRE_first_tail_x4_L9_r0.k19.src_bridge.symm
private theorem bridge38 : bridgeOf PRE_first_tail_x4_L9_r0.s38.ffi = bridgeOf PRE_first_tail_x4_L9_r0.s19.ffi :=
  typedRun37.dst_bridge.trans PRE_first_tail_x4_L9_r0.k19.src_bridge.symm

theorem g1 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) (hπ : ∀ k ∈ π, k < 248320)
    (hL : 2 ≤ i.L) (hLmax : i.L ≤ 2048) (hn : i.n = i.L - 1) (hL7 : i.L = 9)
    (horacle : ∀ ν, MapOk ν i npsMap → Good ν g1Oracle) :
    CutStep (withMem Mem (afterCut NB T tk π i)) (withMem Mem (dispatchCut NB T tk π i)) 260 := by
  rintro t C ⟨x, rfl, rfl, ⟨hr, hq⟩, ⟨⟨hk, hmemo, ⟨π', hlen, hvc, hfr⟩, hfresh, hins, hids, hbound⟩, hp, hnat⟩, hm⟩
  obtain rfl := (SetupDrop.promptEq hvc hπ hfr hp).symm
  have hi33 : (bridgeOf PRE_first_tail_x4_L9_r0.s33.ffi).active = false := by rw [bridge33]; exact inactive19
  have hi38 : (bridgeOf PRE_first_tail_x4_L9_r0.s38.ffi).active = false := by rw [bridge38]; exact inactive19
  have hvr : x.ν 1087 = F64.ofNat i.n := hq.2.2.2.1
  have hv := hvr
  obtain ⟨M', t', C', K', hrun, hext, hrel, hkp, hframes, hD, hlo, hhi, hev, hinput, ng⟩ :=
    g1Run_input hr hk hq.1 (G1Good.ofGood (horacle x.ν hq.2.2)) hfr
      (by omega) (by omega) (by omega) hv (by omega) hi33 (by omega) hvc
  have hb : ForwardBook i π x.K ⟨M', x.ν, K', t', C'⟩ := by
    refine ⟨hlen, hvc, hq.1, hvr, hkp, hk, hfr, hmemo, hframes, by change K'.D ≤ 3540; rw [hD]; exact hbound,
      hlo, hhi, ?_⟩
    obtain ⟨asR, ret, tr, hev⟩ := hev
    exact ⟨asR, ret, [], tr, hev⟩
  have fresh : AneFresh t' := by
    obtain ⟨_, _, r0⟩ := hr.ffi.1
    obtain ⟨_, _, r1⟩ := hrel.ffi.1
    have he : bridgeOf t'.ffi = bridgeOf x.t.ffi :=
      (r1.toR hi38).bridge.1.trans (bridge38.trans (r0.toR inactive19).bridge.1.symm)
    intro Cx Pc Kc weights kind NE IP G init
    rw [he]
    exact hfresh Cx Pc Kc weights kind NE IP G init
  have ids : fixedCells (⟨M', x.ν, K', t', C'⟩ : SegInst FF) := by
    change M'.a 2586 = 2586 ∧ M'.a 2589 = 2589
    rw [hext.a]
    exact hids
  have inputs : setupInputs T tk (⟨M', x.ν, K', t', C'⟩ : SegInst FF) :=
    ⟨hins.1, by change M'.a 2590 = 2590; rw [hext.a]; exact hins.2⟩
  exact ⟨t', C', hrun, ⟨M', x.ν, K', t', C'⟩, rfl, rfl,
    ⟨x.K, hrel, hb, hinput, inputs, hq.2.2⟩, ⟨fresh, ids,
    hnat.step (P := { setupP with rest := machReads T tk }) rfl hr hrel hext.big hext.node cnt38⟩,
    hMem x _ ⟨runC_le _ _ _ _ _ hrun, hext.node, ng, tokens_of_grow hr hrel ng (countersOkB_tokens cnt38), congrFun hext.a 12504⟩ hm⟩


end Host.Ts.Sim.Compose.VWFirst.X4_L9

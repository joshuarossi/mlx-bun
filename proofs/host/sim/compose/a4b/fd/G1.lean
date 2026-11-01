import host.sim.compose.a4b.fd.G1Input
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

structure ForwardBook (i : Cls.Inst) (π : List Nat) (K0 : Ctx) (x : SegInst FF) (Dmax : Nat := 3540) : Prop where
  length : π.length = i.L
  vocab : ∀ k ∈ π, k < 248320
  valuation : VBOkF loopVB x.ν
  rows : x.ν 12 = F64.ofNat i.n
  context : Disp.KpJ (FDFrames.typedJ (tokenBytes (lastRows π)) (lastRows π).length) 4096 x.K
  incoming : Disp.KpJ setupJ 4096 K0
  incomingPrompt : K0.fr 2665 = some ([], π.map natV)
  incomingMemo : K0.fr 4910 = none
  frames : x.K.fr = (g1Framed K0 π i.n).fr
  offset : x.K.D ≤ Dmax
  lo : x.K.lo = K0.lo
  hi : x.K.hi = K0.hi
  inputEvent : ∃ asR ret pre tr, x.K.base' = pre ++
    ⟨chars!"mlx_array_new_data", .jsPtr (x.M.a FDFrames.buffer) 0 (tokenBytes (lastRows π)) :: asR, ret⟩ :: tr

noncomputable def typedCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (s : St FF.S) (S : SSrv) (i : Cls.Inst)
    (Dmax : Nat := 3540) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S => ∃ K0,
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (FDFrames.typedW (tokenBytes (lastRows π)) (lastRows π).length) [] x.M x.ν x.K s S x.t x.C ∧
    ForwardBook i π K0 x Dmax ∧ InputAt (lastRows π) (x.M.node 15235) x.t x.C ∧
    setupInputs T tk x ∧ MapOk x.ν i npsMap
  B := fun x => AneFresh x.t ∧ fixedCells x ∧ NativeAt 0 0 s x.t

noncomputable abbrev dispatchCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) :=
  typedCut NB T tk π PRE_fd_vw_r0.s21 PRE_fd_vw_r0.S21

kernel_rfl cnt21 : countersOkB PRE_fd_vw_r0.s2 PRE_fd_vw_r0.s21 = true

theorem inactive19 : (bridgeOf PRE_fd_vw_r0.s2.ffi).active = false := PRE_fd_vw_r0.zbin0
private theorem bridge16 : bridgeOf PRE_fd_vw_r0.s16.ffi = bridgeOf PRE_fd_vw_r0.s2.ffi :=
  PRE_fd_vw_r0.stepA6.dst_bridge.trans PRE_fd_vw_r0.k2.src_bridge.symm
private theorem bridge21 : bridgeOf PRE_fd_vw_r0.s21.ffi = bridgeOf PRE_fd_vw_r0.s2.ffi :=
  typedRun20.dst_bridge.trans PRE_fd_vw_r0.k2.src_bridge.symm

theorem g1 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) (hπ : ∀ k ∈ π, k < 248320)
    (hL : 2 ≤ i.L) (hLmax : i.L ≤ 2048) (hn : i.n = i.L - 1)
    (horacle : ∀ ν, MapOk ν i npsMap → Good ν g1Oracle) :
    CutStep (withMem Mem (afterNpsCut NB T tk π i)) (withMem Mem (dispatchCut NB T tk π i)) 260 := by
  rintro t C ⟨x, rfl, rfl, ⟨hr, hq⟩, ⟨⟨hk, hmemo, ⟨π', hlen, hvc, hfr⟩, hfresh, hins, hids, hbound⟩, hp, hnat⟩, hm⟩
  obtain rfl := (SetupDrop.promptEq hvc hπ hfr hp).symm
  have hi16 : (bridgeOf PRE_fd_vw_r0.s16.ffi).active = false := by rw [bridge16]; exact inactive19
  have hi21 : (bridgeOf PRE_fd_vw_r0.s21.ffi).active = false := by rw [bridge21]; exact inactive19
  have hv : x.ν 12 = F64.ofNat i.n := hq.2.2.2.1
  obtain ⟨M', t', C', K', hrun, hext, hrel, hkp, hframes, hD, hlo, hhi, hev, hinput, ng⟩ :=
    g1Run_input hr hk hq.1 (G1Good.ofGood (horacle x.ν hq.2.2)) hfr
      (by omega) (by omega) (by omega) hv hi16 (by omega) hvc
  have hb : ForwardBook i π x.K ⟨M', x.ν, K', t', C'⟩ := by
    refine ⟨hlen, hvc, hq.1, hv, hkp, hk, hfr, hmemo, hframes, by change K'.D ≤ 3540; rw [hD]; exact hbound,
      hlo, hhi, ?_⟩
    obtain ⟨asR, ret, tr, hev⟩ := hev
    exact ⟨asR, ret, [], tr, hev⟩
  have fresh : AneFresh t' := by
    obtain ⟨_, _, r0⟩ := hr.ffi.1
    obtain ⟨_, _, r1⟩ := hrel.ffi.1
    have he : bridgeOf t'.ffi = bridgeOf x.t.ffi :=
      (r1.toR hi21).bridge.1.trans (bridge21.trans (r0.toR inactive19).bridge.1.symm)
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
    hnat.step (P := { setupP with rest := machReads T tk }) rfl hr hrel hext.big hext.node cnt21⟩,
    hMem x _ ⟨runC_le _ _ _ _ _ hrun, hext.node, ng, tokens_of_grow hr hrel ng (countersOkB_tokens cnt21), congrFun hext.a 12504⟩ hm⟩

noncomputable def g1_DTtail_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (hπ : ∀ k ∈ π, k < 248320)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    GluePiece FF firstTailRows (fun i => withMem (Mem i.L) (afterNpsCut NB T tk π i))
      (fun i => withMem (Mem i.L) (dispatchCut NB T tk π i)) where
  m := npsMap
  n := 260
  O := g1Oracle
  chk r hr := List.all_eq_true.mp g1Check r hr
  ok r hr i hi ho := by
    obtain ⟨hL, hLmax, hn, _⟩ := firstTailFacts hr hi
    exact g1 (hMem i.L) hπ hL hLmax hn ho.1

end Host.Ts.Sim.Compose.FDVW

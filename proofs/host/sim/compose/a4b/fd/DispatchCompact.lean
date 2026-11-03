import host.sim.compose.a4b.fd.DispatchJs
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk
noncomputable def dispatchPair (x : SegInst FF) := prefillCompactPair setupP PRE_fd_vw_r0.kappa1
  θZ2 PRE_fd_vw_r0.s22 PRE_fd_vw_r0.s23 x

noncomputable def g2Cut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap H N : Nat) (i : Lin.Cls.Inst) : ICut FF :=
  typedCut NB T tk π cap H N PRE_fd_vw_r0.s23 PRE_fd_vw_r0.S23 i 18

kernel_rfl keepNN2 : PRE_fd_vw_r0.kd1.nn0 = PRE_fd_vw_r0.kd1.nn1
kernel_rfl keepNK2 : PTrie.keys PRE_fd_vw_r0.kd1.node = []
kernel_rfl sameNext2 : (mlxOf PRE_fd_vw_r0.s22.ffi).next = (mlxOf PRE_fd_vw_r0.s23.ffi).next
kernel_rfl sameNnext2 : (mlxOf PRE_fd_vw_r0.s22.ffi).nnext = (mlxOf PRE_fd_vw_r0.s23.ffi).nnext

theorem dispatchVal (ν : Nat → F64) : Shift.valuation θZ2 ν = ν := rfl
kernel_rfl dispatchFixNode : PRE_fd_vw_r0.kappa1.node 19057 = 19057

theorem dispatch_compact {NB T cap H N capB : Nat} {tk : Nat → Nat} {π : List Nat} {i : Lin.Cls.Inst} {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) (hcapB : cap + 18 ≤ capB) (hcapM : capB ≤ 131072) :
    CutConv (withMem Mem (mergedDispatchCut NB T tk π cap H N i)) (withMem Mem (g2Cut NB T tk π capB H N i)) := by
  rintro x ⟨K0, hr, hb, hip, hins, hmap, -⟩ ⟨⟨hfresh, hids, hnat, hcall, hNB, hnative⟩, hm⟩
  let bs := tokenBytes (lastRows π)
  let n := (lastRows π).length
  have hk := hb.context
  have hr0 := hr.ofJ
  have hs := dispatchShift hk.1 hb.prompt hb.chunk hcall hnative
  have hnext : (mlxOf PRE_fd_vw_r0.s23.ffi).next = 21967 := congrArg Prod.fst PRE_fd_vw_r0.ccounters1
  have hD : x.t.next - PRE_fd_vw_r0.s23.next = x.K.D + 18 := by
    have h := hr.offset
    change x.t.next = PRE_fd_vw_r0.s22.next + x.K.D at h
    rw [PRE_fd_vw_r0.zsmn1] at h
    rw [h, PRE_fd_vw_r0.cnext1]
    omega
  have hfree := Conv.jclean_noBigSt (lo := (mlxOf PRE_fd_vw_r0.s23.ffi).next) (E := setupP.E)
    (PRE_fd_vw_r0.cjcl1 dispatchCallClean) (by rw [hnext]) (by decide : setupP.E ≤ RData.bigHi)
    PRE_fd_vw_r0.zroots21
  have hband : ∀ i : Int, ((mlxOf PRE_fd_vw_r0.s23.ffi).next : Int) ≤ i ∧ i < setupP.E →
      ¬ BigFixed x.K.lo x.K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56 := by
    intro i hi
    rw [hnext] at hi
    have hlo : x.K.lo = 18151 := hk.1.1
    have hhi : x.K.hi = 131072 := hk.1.2.1
    rw [hlo, hhi]
    change 21967 ≤ i ∧ i < 131072 at hi
    unfold BigFixed
    constructor
    · omega
    · constructor <;> omega
  have sameH : (mlxOf PRE_fd_vw_r0.s22.ffi).next = (mlxOf PRE_fd_vw_r0.s23.ffi).next :=
    PRE_fd_vw_r0.cnh11.symm.trans hnext.symm
  have sameN : (mlxOf PRE_fd_vw_r0.s22.ffi).nnext = (mlxOf PRE_fd_vw_r0.s23.ffi).nnext :=
    PRE_fd_vw_r0.cnn11.symm.trans (congrArg Prod.snd PRE_fd_vw_r0.ccounters1).symm
  have hroomN : NRoom setupP (Host.Load.Layers.toLoad PRE_fd_vw_r0.s23.ffi)
      (Host.Load.Layers.toLoad x.t.ffi) := by
    obtain ⟨P', hP, hf⟩ := hr.ffi.1
    obtain ⟨_, hE, hNE, _⟩ := Raised.restart (.inl rfl) hP
    constructor
    · have h := hf.load.mlx.hroom.2
      rw [hE] at h
      change (mlxOf x.t.ffi).next + (setupP.E - (mlxOf PRE_fd_vw_r0.s22.ffi).next) < 2 ^ 46 at h
      rw [sameH] at h
      exact h
    · have h := hf.load.mlx.nroom.2.2
      rw [hNE] at h
      change (mlxOf x.t.ffi).nnext + (setupP.NE - (mlxOf PRE_fd_vw_r0.s22.ffi).nnext) < 2 ^ 62 at h
      rw [sameN] at h
      exact h
  have hc := Conv.full_compactQXD NB (P := setupP) (r := machReads T tk)
    (s0 := PRE_fd_vw_r0.s23) (s1 := PRE_fd_vw_r0.s22)
    (S0 := ⟨PRE_fd_vw_r0.S23.tab, []⟩) (S1 := ⟨PRE_fd_vw_r0.S22.tab, []⟩)
    PRE_fd_vw_r0.raised1 hNB hr0 hs PRE_fd_vw_r0.cbigs1 hfree hband
    (fun _ h => nomatch h) (by rw [hD]; change x.K.D + 18 < Sim.bound; have := hb.offset; simp only [Sim.bound]; omega) hroomN
  let N := (x.M.after PRE_fd_vw_r0.kappa1).rebig (mlxOf PRE_fd_vw_r0.s23.ffi).next
    setupP.E (mlxOf x.t.ffi).next
  let K' : Ctx := ⟨Shift.framedNext x.M x.K PRE_fd_vw_r0.s22,
    PRE_fd_vw_r0.s23.trace, x.t.trace, x.t.next - PRE_fd_vw_r0.s23.next, x.K.lo, x.K.hi⟩
  have hJs : NoBigSt (JsBad N) K'.base PRE_fd_vw_r0.s23 :=
    noBigSt_of_above jsHeap23 jsRoots23 (fun j hj => jsBad_above1
      (jsBad_after (M := x.M) (N := N) (σ := PRE_fd_vw_r0.kappa1) hr.ffi.2 rfl
        (fun _ h => jsBig_rebig (by decide : setupP.E ≤ 2 ^ 56) h) hj))
  have hcJ := (hc.withJs (by change x.K.lo ≤ 2 ^ 56; rw [hk.1.1]; change 18151 ≤ 2 ^ 56; decide) hJs
    (fullRXD_withJs hc.ffi dispatchJsNative)).toJ (BigJs.withJs N)
  have hfr : K'.fr = x.K.fr := dispatchFramesNext hk.1
  have hctx : Disp.KpJ (FDFrames.typedJ bs n) 131072 K' :=
    ⟨Kp_restart hk.1 _ _ _, by change x.t.next - PRE_fd_vw_r0.s23.next ≤ 131072; rw [hD]; have := hb.offset; omega⟩
  have hcW := hcJ
  have pairν : (dispatchPair x).ν = x.ν := dispatchVal x.ν
  have pairfr : (dispatchPair x).K.fr = x.K.fr := hfr
  have node : (dispatchPair x).M.node 19057 = x.M.node 19057 := by
    change x.M.node (PRE_fd_vw_r0.kappa1.node 19057) = x.M.node 19057
    rw [dispatchFixNode]
  have aold : ∀ a, a < 2823922 → (dispatchPair x).M.a a = x.M.a a := by
    intro a ha
    change x.M.a (PRE_fd_vw_r0.kappa1.a a) = x.M.a a
    have he : PRE_fd_vw_r0.kappa1.a a = a := by
      rw [PRE_fd_vw_r0.zkap1]
      exact Conv.Map.compact_lt (by exact ha)
    rw [he]
  have book : ForwardBook i π K0 (dispatchPair x) capB := by
    refine ⟨hb.length, hb.vocab, ?_, ?_, ?_, ?_, ?_, hctx, hb.incoming, hb.incomingPrompt,
      pairfr.trans hb.frames, ?_, hb.lo, hb.hi, ?_⟩
    · rw [pairν]; exact hb.valuation
    · rw [pairν]; exact hb.promptValue
    · rw [pairν]; exact hb.rowValue
    · rw [pairν]; exact hb.offsetValue
    · rw [pairν]; exact hb.capValue
    · change x.t.next - PRE_fd_vw_r0.s23.next ≤ capB
      rw [hD]
      have := hb.offset
      omega
    · obtain ⟨asR, ret, pre, tr, hev⟩ := hb.inputEvent
      obtain ⟨fresh, _, ht⟩ := hr.trace
      refine ⟨asR, ret, fresh.map x.M.event ++ pre, tr, ?_⟩
      change x.t.trace = _
      rw [aold FDFrames.buffer (by decide), ht, hev, List.append_assoc]
  have inputs : setupInputs T tk (dispatchPair x) := by
    constructor
    · intro j hj
      rw [pairν]
      exact hins.1 j hj
    · change (dispatchPair x).M.a 2590 = 2590
      rw [aold 2590 (by decide)]
      exact hins.2
  have ids : fixedCells (dispatchPair x) := by
    change (dispatchPair x).M.a 2586 = 2586 ∧ (dispatchPair x).M.a 2589 = 2589
    rw [aold 2586 (by decide), aold 2589 (by decide)]
    exact hids
  refine ⟨dispatchPair x, rfl, rfl, ⟨K0, hcW, book, ?_, inputs, ?_, ?_⟩, ⟨hfresh, ids,
    ⟨sameNext2 ▸ hnat.1, sameNnext2 ▸ hnat.2⟩⟩,
    hMem x _ (NTrack.conv rfl rfl (funext fun k => congrArg x.M.node (compact_node_id keepNN2 keepNK2 k)) (aold 12504 (by decide))) hm⟩
  · rw [node]
    exact hip
  · rw [pairν]
    exact hmap
  · change 18 ≤ x.t.next - PRE_fd_vw_r0.s23.next
    rw [hD]
    omega
end Host.Ts.Sim.Compose.FDVW

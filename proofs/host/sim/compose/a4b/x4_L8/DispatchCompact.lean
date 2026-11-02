import host.sim.compose.a4b.x4_L8.DispatchJs
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk
noncomputable def dispatchPair (x : SegInst FF) := prefillCompactPair setupP PRE_first_tail_x4_L8_r0.kappa2
  θZ2 PRE_first_tail_x4_L8_r0.s39 PRE_first_tail_x4_L8_r0.s40 x

noncomputable def g2Cut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (i : Lin.Cls.Inst) : ICut FF :=
  typedCut NB T tk π PRE_first_tail_x4_L8_r0.s40 PRE_first_tail_x4_L8_r0.S40 i 3571

kernel_rfl keepNN2 : PRE_first_tail_x4_L8_r0.kd2.nn0 = PRE_first_tail_x4_L8_r0.kd2.nn1
kernel_rfl keepNK2 : PTrie.keys PRE_first_tail_x4_L8_r0.kd2.node = []
kernel_rfl sameNext2 : (mlxOf PRE_first_tail_x4_L8_r0.s39.ffi).next = (mlxOf PRE_first_tail_x4_L8_r0.s40.ffi).next
kernel_rfl sameNnext2 : (mlxOf PRE_first_tail_x4_L8_r0.s39.ffi).nnext = (mlxOf PRE_first_tail_x4_L8_r0.s40.ffi).nnext

theorem dispatchVal (ν : Nat → F64) : Shift.valuation θZ2 ν = ν := rfl
kernel_rfl dispatchFixNode : PRE_first_tail_x4_L8_r0.kappa2.node 15235 = 15235

theorem dispatch_compact {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Lin.Cls.Inst} {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) :
    CutConv (withMem Mem (mergedDispatchCut NB T tk π i)) (withMem Mem (g2Cut NB T tk π i)) := by
  rintro x ⟨K0, hr, hb, hip, hins, hmap⟩ ⟨⟨hfresh, hids, hnat, hcall, hNB, hnative⟩, hm⟩
  let bs := tokenBytes (π.take i.n)
  let n := (π.take i.n).length
  have hmemo := hb.memo
  have hk := hb.context
  have hr0 := inactiveMemo hr.ofJ (compactW_agree bs n hmemo)
  have hs := dispatchShift hk.1 hb.prompt hb.chunk hcall hnative
  have hnext : (mlxOf PRE_first_tail_x4_L8_r0.s40.ffi).next = 18156 := congrArg Prod.fst PRE_first_tail_x4_L8_r0.ccounters2
  have hD : x.t.next - PRE_first_tail_x4_L8_r0.s40.next = x.K.D + 28 := by
    have h := hr.offset
    change x.t.next = PRE_first_tail_x4_L8_r0.s39.next + x.K.D at h
    rw [PRE_first_tail_x4_L8_r0.zsmn2] at h
    rw [h, PRE_first_tail_x4_L8_r0.cnext2]
    omega
  have hfree := Conv.jclean_noBigSt (lo := (mlxOf PRE_first_tail_x4_L8_r0.s40.ffi).next) (E := setupP.E)
    (PRE_first_tail_x4_L8_r0.cjcl2 dispatchCallClean) (by rw [hnext]) (by decide : setupP.E ≤ RData.bigHi)
    PRE_first_tail_x4_L8_r0.zroots22
  have hband : ∀ i : Int, ((mlxOf PRE_first_tail_x4_L8_r0.s40.ffi).next : Int) ≤ i ∧ i < setupP.E →
      ¬ BigFixed x.K.lo x.K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56 := by
    intro i hi
    rw [hnext] at hi
    have hlo : x.K.lo = 18151 := hk.1.1
    have hhi : x.K.hi = 131072 := hk.1.2.1
    rw [hlo, hhi]
    change 18156 ≤ i ∧ i < 131072 at hi
    unfold BigFixed
    constructor
    · omega
    · constructor <;> omega
  have sameH : (mlxOf PRE_first_tail_x4_L8_r0.s39.ffi).next = (mlxOf PRE_first_tail_x4_L8_r0.s40.ffi).next :=
    PRE_first_tail_x4_L8_r0.cnh12.symm.trans hnext.symm
  have sameN : (mlxOf PRE_first_tail_x4_L8_r0.s39.ffi).nnext = (mlxOf PRE_first_tail_x4_L8_r0.s40.ffi).nnext :=
    PRE_first_tail_x4_L8_r0.cnn12.symm.trans (congrArg Prod.snd PRE_first_tail_x4_L8_r0.ccounters2).symm
  have hroomN : NRoom setupP (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0.s40.ffi)
      (Host.Load.Layers.toLoad x.t.ffi) := by
    obtain ⟨P', hP, hf⟩ := hr.ffi.1
    obtain ⟨_, hE, hNE, _⟩ := Raised.restart (.inl rfl) hP
    constructor
    · have h := hf.load.mlx.hroom.2
      rw [hE] at h
      change (mlxOf x.t.ffi).next + (setupP.E - (mlxOf PRE_first_tail_x4_L8_r0.s39.ffi).next) < 2 ^ 46 at h
      rw [sameH] at h
      exact h
    · have h := hf.load.mlx.nroom.2.2
      rw [hNE] at h
      change (mlxOf x.t.ffi).nnext + (setupP.NE - (mlxOf PRE_first_tail_x4_L8_r0.s39.ffi).nnext) < 2 ^ 62 at h
      rw [sameN] at h
      exact h
  have hc := Conv.full_compactQXD NB (P := setupP) (r := machReads T tk)
    (s0 := PRE_first_tail_x4_L8_r0.s40) (s1 := PRE_first_tail_x4_L8_r0.s39)
    (S0 := ⟨PRE_first_tail_x4_L8_r0.S40.tab, []⟩) (S1 := ⟨PRE_first_tail_x4_L8_r0.S39.tab, []⟩)
    PRE_first_tail_x4_L8_r0.raised2 hNB hr0 hs PRE_first_tail_x4_L8_r0.cbigs2 hfree hband
    (fun _ h => nomatch h) (by rw [hD]; change x.K.D + 28 < Sim.bound; have := hb.offset; simp only [Sim.bound]; omega) hroomN
  let N := (x.M.after PRE_first_tail_x4_L8_r0.kappa2).rebig (mlxOf PRE_first_tail_x4_L8_r0.s40.ffi).next
    setupP.E (mlxOf x.t.ffi).next
  let K' : Ctx := ⟨Shift.framedNext x.M x.K PRE_first_tail_x4_L8_r0.s39,
    PRE_first_tail_x4_L8_r0.s40.trace, x.t.trace, x.t.next - PRE_first_tail_x4_L8_r0.s40.next, x.K.lo, x.K.hi⟩
  have hJs : NoBigSt (JsBad N) K'.base PRE_first_tail_x4_L8_r0.s40 :=
    dispatchJsFree (fun i hi => jsBad_after (M := x.M) (N := N) (σ := PRE_first_tail_x4_L8_r0.kappa2) hr.ffi.2 rfl
      (fun _ h => jsBig_rebig (by decide : setupP.E ≤ 2 ^ 56) h) hi)
  have hcJ := (hc.withJs (by change x.K.lo ≤ 2 ^ 56; rw [hk.1.1]; change 18151 ≤ 2 ^ 56; decide) hJs
    (fullRXD_withJs hc.ffi dispatchJsNative)).toJ (BigJs.withJs N)
  have hfr : K'.fr = x.K.fr := dispatchFramesNext hk.1
  have hctx : Disp.KpJ (VWFrames.typedJ bs n) 4096 K' :=
    ⟨Kp_restart hk.1 _ _ _, by change x.t.next - PRE_first_tail_x4_L8_r0.s40.next ≤ 4096; rw [hD]; have := hb.offset; omega⟩
  have hmemo' : K'.fr 4910 = none := by rw [hfr]; exact hmemo
  have hcW := inactiveMemo hcJ (fun a ha => (compactW_agree bs n hmemo' a ha).symm)
  have pairν : (dispatchPair x).ν = x.ν := dispatchVal x.ν
  have pairfr : (dispatchPair x).K.fr = x.K.fr := hfr
  have node : (dispatchPair x).M.node 15235 = x.M.node 15235 := by
    change x.M.node (PRE_first_tail_x4_L8_r0.kappa2.node 15235) = x.M.node 15235
    rw [dispatchFixNode]
  have aold : ∀ a, a < 2673488 → (dispatchPair x).M.a a = x.M.a a := by
    intro a ha
    change x.M.a (PRE_first_tail_x4_L8_r0.kappa2.a a) = x.M.a a
    have he : PRE_first_tail_x4_L8_r0.kappa2.a a = a := by
      rw [PRE_first_tail_x4_L8_r0.zkap2]
      exact Conv.Map.compact_lt (by exact ha)
    rw [he]
  have book : ForwardBook i π K0 (dispatchPair x) 3571 := by
    refine ⟨hb.length, hb.vocab, ?_, ?_, hctx, hb.incoming, hb.incomingPrompt, hb.incomingMemo,
      pairfr.trans hb.frames, ?_, hb.lo, hb.hi, ?_⟩
    · rw [pairν]; exact hb.valuation
    · rw [pairν]; exact hb.rows
    · change x.t.next - PRE_first_tail_x4_L8_r0.s40.next ≤ 3571
      rw [hD]
      have := hb.offset
      omega
    · obtain ⟨asR, ret, pre, tr, hev⟩ := hb.inputEvent
      obtain ⟨fresh, _, ht⟩ := hr.trace
      refine ⟨asR, ret, fresh.map x.M.event ++ pre, tr, ?_⟩
      change x.t.trace = _
      rw [aold VWFrames.buffer (by decide), ht, hev, List.append_assoc]
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
  refine ⟨dispatchPair x, rfl, rfl, ⟨K0, hcW, book, ?_, inputs, ?_⟩, ⟨hfresh, ids,
    ⟨sameNext2 ▸ hnat.1, sameNnext2 ▸ hnat.2⟩⟩,
    hMem x _ (NTrack.conv rfl rfl (funext fun k => congrArg x.M.node (compact_node_id keepNN2 keepNK2 k)) (aold 12504 (by decide))) hm⟩
  · rw [node]
    exact hip
  · rw [pairν]
    exact hmap
end Host.Ts.Sim.Compose.VWFirst.X4_L8

import host.sim.compose.a4b.SetupH3Data
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupH3
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

noncomputable def chunkCallFixedCut (NB T : Nat) (tk : Nat → Nat) (L : Nat) : ICut FF :=
  { pbCut (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) setupJ wideP [(9, .L)]
      PRE_setup_h3_chunk.s0 PRE_setup_h3_chunk.S0 (setupI L) with B := fun x => callBook L x ∧ fixedCells x }

def mergedQ (L : Nat) (x : SegInst FF) : Prop :=
  ∃ ν, x.ν = Conv.resVal ν PRE_setup_h3_chunk.ws0
    (Conv.resF SymE.var PRE_setup_h3_chunk.st0.S4.tab PRE_setup_h3_chunk.S0.tab.length ν) ∧
    VBOkF loopVB ν ∧ Disp.Kp setupJ x.K ∧ MapOk ν (setupI L) [(9, .L)]
def mergeBook (NB L : Nat) (x : SegInst FF) : Prop :=
  callBook L x ∧ fixedCells x ∧ Conv.CallFacts PRE_setup_h3_chunk.s0 PRE_setup_h3_chunk.S0.tab.length ∧
  NB ≤ PRE_setup_h3_chunk.P0.NL ∧ Conv.FullShiftQ PRE_setup_h3_chunk.P0 10 PRE_setup_h3_chunk.kappa0
    PRE_setup_h3_chunk.s2.ffi PRE_setup_h3_chunk.s1.ffi
noncomputable def chunkMergedCut (NB T : Nat) (tk : Nat → Nat) (L : Nat) : ICut FF :=
  (Cut.mk PRE_setup_h3_chunk.s1 PRE_setup_h3_chunk.S1.tab
    (Conv.relB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP [] (mergedQ L))).with
    (mergeBook NB L)
def chunkBook (L : Nat) (x : SegInst FF) : Prop :=
  Disp.KpJ setupJ 4096 x.K ∧ x.K.fr 4910 = none ∧
  ∃ π : List Nat, π.length = L ∧ (∀ t ∈ π, t < 248320) ∧
    x.K.fr 2665 = some ([], π.map natV) ∧ x.K.D = 2352 ∧ AneFresh x.t
noncomputable def setupChunkCut (NB T : Nat) (tk : Nat → Nat) (L : Nat) : ICut FF :=
  { pbCut (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) setupJ wideP [(9, .L)]
      PRE_setup_h3_chunk.s2 PRE_setup_h3_chunk.S2 (setupI L) with B := fun x => chunkBook L x ∧ fixedCells x }

noncomputable def θZ0 : Nat → SymE :=
  Conv.compactθZ PRE_setup_h3_chunk.cws0 PRE_setup_h3_chunk.crs0 PRE_setup_h3_chunk.ws0
kernel_rfl cwsDisjoint : PRE_setup_h3_chunk.cws0.all (fun c => !PRE_setup_h3_chunk.ws0.contains c) = true

theorem inactiveStart : (bridgeOf PRE_setup_h3_chunk.s0.ffi).active = false := by
  have h0 : (bridgeOf PRE_setup_early_r0.s0.ffi).active = false := by
    rw [PRE_setup_early_r0.start_eq]
    exact Host.Load.Run.Prompt.ldStT_bridge [] []
  have h4 : (bridgeOf (PRE_setup_early_r0.s4 : St FF.S).ffi).active = false :=
    (congrArg (fun b => b.active) SetupEarly.bridge4).trans h0
  exact (congrArg (fun s : St FF.S => (bridgeOf s.ffi).active) startEq).trans h4

theorem wsOff {j : Nat} (hj : j < 9) : PRE_setup_h3_chunk.ws0.contains j = false := by
  apply Bool.eq_false_iff.mpr
  intro hc
  have hm := List.contains_iff_mem.mp hc
  have hlo := Nat.le_of_ble_eq_true (List.all_eq_true.mp wsLow j hm)
  omega

theorem bridgeMerged : bridgeOf PRE_setup_h3_chunk.s1.ffi = bridgeOf PRE_setup_h3_chunk.s0.ffi :=
  PRE_setup_h3_chunk.cbridge0.trans
    ((congrArg (fun s : St FF.S => bridgeOf s.ffi) canonicalEq).trans
      (SetupChunk.bridge6.trans (congrArg (fun s : St FF.S => bridgeOf s.ffi) startEq).symm))

kernel_rfl sourcePromptEmpty : arrOf PRE_setup_h3_chunk.s0 2665 = []

theorem stageSim (NB T : Nat) (tk : Nat → Nat) (r : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      PRE_setup_h3_chunk.st0.okL (Disp.KpJ setupJ 4096) wideP r (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : setupJ.okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJS P NB loopVB setupJ 4096 hj rfl rfl rfl rfl rfl r setupW_ok
  apply hs.mono
  intro s S h
  change (Disp.okJSJ setupJ (okBackFXS setupP) 4096 s S && Disp.localB s) = true at h
  simp only [Bool.and_eq_true] at h
  simpa only [P, backRest] using h.1


theorem chunkCall_merged_keeps {NB T L : Nat} {tk : Nat → Nat}
    (horacle : ∀ ν, MapOk ν (setupI L) [(9, .L)] → Good ν PRE_setup_h3_chunk.st0.S0.oracle) :
    CutStepKeeps (chunkCallFixedCut NB T tk L) (chunkMergedCut NB T tk L) (PRE_setup_h3_chunk.st0.tpl.n + 1) := by
  rintro c ⟨hr, hq⟩ ⟨hb, hids⟩
  obtain ⟨hk, hmemo, π, hlen, hvocab, hframe, hd, hfresh⟩ := hb
  have h0 := hr.withOracle (horacle c.ν hq.2.2)
  have hS : PRE_setup_h3_chunk.st0.S0 = ⟨PRE_setup_h3_chunk.S0.tab, PRE_setup_h3_chunk.st0.S0.oracle⟩ := by
    rw [← PRE_setup_h3_chunk.tab0_0]
  change RelB FF _ wideP [] c.M c.ν c.K PRE_setup_h3_chunk.s0
    ⟨PRE_setup_h3_chunk.S0.tab, PRE_setup_h3_chunk.st0.S0.oracle⟩ c.t c.C at h0
  rw [← hS] at h0
  let tpl : Stage.StageTpl FF PRE_setup_h3_chunk.st0.okL := PRE_setup_h3_chunk.st0.tpl
  obtain ⟨M', t', C', run, ext, rel⟩ := Conv.site_merge tpl
    PRE_setup_h3_chunk.iso0 rfl (stageSim NB T tk) PRE_setup_h3_chunk.st0.loc hk hq.1
    PRE_setup_h3_chunk.stFoot0 PRE_setup_h3_chunk.wrNodup0 PRE_setup_h3_chunk.wrBound0
    PRE_setup_h3_chunk.trace0 PRE_setup_h3_chunk.S0.tab.length h0
  have hm := PRE_setup_h3_chunk.merged0 rel
  have hext : Ext c.M M' PRE_setup_h3_chunk.S0.tab.length := by
    change Ext c.M M' PRE_setup_h3_chunk.st0.S0.tab.length at ext
    rw [PRE_setup_h3_chunk.tab0_0] at ext
    exact ext
  have hlen2 : PRE_setup_h3_chunk.S0.tab.length ≤ PRE_setup_h3_chunk.st0.S4.tab.length := by
    have h := PRE_setup_h3_chunk.st0.tpl.len2
    change PRE_setup_h3_chunk.st0.S0.tab.length ≤ PRE_setup_h3_chunk.st0.S4.tab.length at h
    rw [PRE_setup_h3_chunk.tab0_0] at h
    exact h
  have hm' := hm.resMerge (tab := PRE_setup_h3_chunk.S0.tab) hr.srv.num hext (runC_le _ _ _ _ _ run) hlen2
    (show PRE_setup_h3_chunk.ws0.length = _ from PRE_setup_h3_chunk.mergeLen0.symm)
    (by decide : PRE_setup_h3_chunk.ws0.Nodup)
    (noVar_of_all (by have h := PRE_setup_h3_chunk.fresh0; simp only [Bool.and_eq_true] at h; exact h.1))
  let ν' := Conv.resVal c.ν PRE_setup_h3_chunk.ws0
    (Conv.resF SymE.var PRE_setup_h3_chunk.st0.S4.tab PRE_setup_h3_chunk.S0.tab.length c.ν)
  refine ⟨⟨M', ν', c.K, t', C'⟩, run, ?_, ?_, ?_, ?_⟩
  · change RelB FF _ wideP [] M' ν' c.K PRE_setup_h3_chunk.s1 ⟨PRE_setup_h3_chunk.S1.tab, []⟩ t' C' ∧ _
    rw [PRE_setup_h3_chunk.mergeTab0]
    exact ⟨hm', c.ν, rfl, hq⟩
  · have top := hr.ffi.1.top (by rfl)
    have hNL : ({ setupP with rest := machReads T tk }.raise (mlxOf PRE_setup_h3_chunk.s0.ffi).nnext).NL ≤
        PRE_setup_h3_chunk.P0.NL := by
      change (mlxOf PRE_setup_h3_chunk.s0.ffi).nnext ≤ 15235
      rw [← PRE_setup_h3_chunk.fcnn0]
    refine ⟨?_, ?_, ⟨hr.presentBound, hr.heapSupp⟩, top.1.load.mlx.nbl.trans hNL,
      PRE_setup_h3_chunk.cshiftR0 top.1 hNL⟩
    · have inactive4 : (bridgeOf PRE_setup_h3_chunk.s0.ffi).active = false := by
        exact inactiveStart
      have inactive5 : (bridgeOf PRE_setup_h3_chunk.s1.ffi).active = false := by rw [bridgeMerged]; exact inactive4
      obtain ⟨_, _, hn0⟩ := hr.ffi.1
      obtain ⟨_, _, hn5⟩ := hm'.ffi.1
      have sameBridge : bridgeOf t'.ffi = bridgeOf c.t.ffi :=
        (hn5.toR inactive5).bridge.1.trans (bridge5.trans (hn0.toR inactive4).bridge.1.symm)
      refine ⟨hk, hmemo, π, hlen, hvocab, hframe, hd, ?_⟩
      intro Cx Pc Kc weights kind NE IP G init
      change Host.Mlx.FfiAneEval.final Pc Kc weights kind NE IP G init (bridgeOf t'.ffi) = _
      rw [sameBridge]
      exact hfresh Cx Pc Kc weights kind NE IP G init

    · change M'.a 2586 = 2586 ∧ M'.a 2589 = 2589
      rw [hext.a]
      exact hids
  · intro j hj
    apply Conv.resVal_off
    exact fun hm => by have h := Nat.le_of_ble_eq_true (List.all_eq_true.mp wsLow j hm); omega
  · exact congrFun hext.a 2590


theorem chunkShift {K : Ctx} (hk : Disp.Kp setupJ K) {π : List Nat}
    (hframe : K.fr 2665 = some ([], π.map natV))
    (hcall : Conv.CallFacts PRE_setup_h3_chunk.s0 PRE_setup_h3_chunk.S0.tab.length)
    (hnative : Conv.FullShiftQ PRE_setup_h3_chunk.P0 10 PRE_setup_h3_chunk.kappa0
      PRE_setup_h3_chunk.s2.ffi PRE_setup_h3_chunk.s1.ffi) :
    ShiftD FF (fun σ x y => x = PRE_setup_h3_chunk.s2.ffi ∧
      Conv.FullShiftQX PRE_setup_h3_chunk.P0 PRE_setup_h3_chunk.S2.tab.length σ x y)
      PRE_setup_h3_chunk.kappa0 θZ0 (kpOf K noFrames) noFrames K
      PRE_setup_h3_chunk.s2 ⟨PRE_setup_h3_chunk.S2.tab, []⟩
      PRE_setup_h3_chunk.s1 ⟨PRE_setup_h3_chunk.S1.tab, []⟩ := by
  have hroots := checkRootsSupp_sound (s := (PRE_setup_h3_chunk.s2 : St FF.S)) PRE_setup_h3_chunk.zroots0
  have hs := Conv.compact_shift (F := FF) (W := noFrames) (K1 := K)
    PRE_setup_h3_chunk.zkap0 hcall callClean PRE_setup_h3_chunk.cfix0
    (fun p hp => Nat.le_of_ble_eq_true (List.all_eq_true.mp PRE_setup_h3_chunk.zpl0 p hp))
    (nodupT_sound PRE_setup_h3_chunk.zplnd0).2 (Nat.le_of_ble_eq_true PRE_setup_h3_chunk.zn10)
    (Nat.le_of_ble_eq_true PRE_setup_h3_chunk.zfirst0) PRE_setup_h3_chunk.zscn0 PRE_setup_h3_chunk.zsmn0
    (Nat.le_of_ble_eq_true PRE_setup_h3_chunk.zgrow0) PRE_setup_h3_chunk.mergeTab0
    (noVar_of_all PRE_setup_h3_chunk.zfresh0) (nodupT_sound PRE_setup_h3_chunk.zcnd0).2
    (by rfl : PRE_setup_h3_chunk.cws0.length = PRE_setup_h3_chunk.nr0.length)
    (fun r hr => Nat.blt_eq.mp (List.all_eq_true.mp PRE_setup_h3_chunk.znrHi0 r hr))
    hk.2.2 (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_setup_h3_chunk.zfrlt0 a ha))
    (Xs := [2665]) (by intro a; simp [noFrames]) (by intro a w hw; cases hw)
    (by
      intro a pre pre' hka _
      have ha := (hk.2.2 a).mp (by rw [hka]; exact Option.some_ne_none _)
      change a ∈ [2665] at ha
      simp only [List.mem_singleton] at ha
      subst ha
      rw [hframe] at hka
      cases hka
      refine ⟨_, arrOf PRE_setup_h3_chunk.s1 2665, PRE_setup_h3_chunk.zg0_2665, ?_, ?_⟩
      · rw [PRE_setup_h3_chunk.zk0_2665, sourcePromptEmpty]
      · simpa only [sourcePromptEmpty, List.length_nil, List.drop_zero, List.nil_append] using
          PRE_setup_h3_chunk.zm0_2665)
    (by intro a w hw; cases hw) (by intro a w hw; cases hw)
    (Conv.heap_off_setAll PRE_setup_h3_chunk.cheap0
      (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_setup_h3_chunk.zclbd0 a ha)))
    (hoff_of PRE_setup_h3_chunk.mheap0 PRE_setup_h3_chunk.stFoot0 PRE_setup_h3_chunk.iso0 PRE_setup_h3_chunk.zwr0)
    PRE_setup_h3_chunk.ckeepP0 PRE_setup_h3_chunk.csupp0 PRE_setup_h3_chunk.cbound0 PRE_setup_h3_chunk.zimg0
    PRE_setup_h3_chunk.zctl0 PRE_setup_h3_chunk.zstack0 PRE_setup_h3_chunk.zjobs0 PRE_setup_h3_chunk.zstores0
    (by rw [PRE_setup_h3_chunk.znC0]; exact hroots.1)
    (by rw [PRE_setup_h3_chunk.znC0]; exact hroots.2.1)
    (by rw [PRE_setup_h3_chunk.znC0]; exact hroots.2.2.1)
    (by rw [PRE_setup_h3_chunk.znC0]; exact hroots.2.2.2)
    (Conv.bigFixed_of_mshift hnative.load.mlx hk.1 hk.2.1)
  have hs' : ShiftD FF (fun _ _ _ => True) PRE_setup_h3_chunk.kappa0 PRE_setup_h3_chunk.ctheta0
      (kpOf K noFrames) noFrames K PRE_setup_h3_chunk.s2 ⟨PRE_setup_h3_chunk.S2.tab, []⟩
      PRE_setup_h3_chunk.s1 ⟨PRE_setup_h3_chunk.S1.tab, []⟩ := by
    rw [PRE_setup_h3_chunk.ctab0]
    exact hs
  have hθ := hs'.retheta (θ' := θZ0) (by
    rw [PRE_setup_h3_chunk.ctab0]
    exact Conv.compactθZ_tab
      (noVar_of_all (by have h := PRE_setup_h3_chunk.fresh0; simp only [Bool.and_eq_true] at h; exact h.1))
      (disj_of_all cwsDisjoint))
  exact { hθ with ffi := ⟨rfl, by
    rw [PRE_setup_h3_chunk.ctab0]
    change Conv.FullShiftQX PRE_setup_h3_chunk.P0 10 PRE_setup_h3_chunk.kappa0 _ _
    exact hnative.toX PRE_setup_h3_chunk.zbin0⟩ }


theorem merged_compact_keeps {NB T L : Nat} {tk : Nat → Nat} :
    CutConvKeeps (chunkMergedCut NB T tk L) (setupChunkCut NB T tk L) := by
  rintro x ⟨hr, ν, hν, hvb, hkp, hmap⟩ ⟨hb, hids, hcall, hNB, hnative⟩
  obtain ⟨hk, hmemo, π, hlen, hvocab, hframe, hd, hfresh⟩ := hb
  have hr0 := inactiveMemo hr.ofJ (fun a ha => (wideInactive hmemo a ha).symm)
  have hs := chunkShift hkp hframe hcall hnative
  have hnext6 : (mlxOf PRE_setup_h3_chunk.s2.ffi).next = 18155 :=
    congrArg Prod.fst PRE_setup_h3_chunk.ccounters0
  have hoff : x.t.next = 2675688 := by
    have h := hr.offset
    change x.t.next = PRE_setup_h3_chunk.s1.next + x.K.D at h
    rw [PRE_setup_h3_chunk.zsmn0, hd, Nat.add_zero] at h
    exact h
  have hD : x.t.next - PRE_setup_h3_chunk.s2.next = 2352 := by rw [hoff, PRE_setup_h3_chunk.cnext0]
  have hfree := Conv.jclean_noBigSt (lo := (mlxOf PRE_setup_h3_chunk.s2.ffi).next) (E := setupP.E)
    (PRE_setup_h3_chunk.cjcl0 callClean)
    (by rw [hnext6]) (by decide : setupP.E ≤ RData.bigHi)
    PRE_setup_h3_chunk.zroots20
  have hband : ∀ i : Int, ((mlxOf PRE_setup_h3_chunk.s2.ffi).next : Int) ≤ i ∧ i < setupP.E →
      ¬ BigFixed x.K.lo x.K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56 := by
    intro i hi
    rw [hnext6] at hi
    have hlo : x.K.lo = 18151 := hk.1.1
    have hhi : x.K.hi = 131072 := hk.1.2.1
    rw [hlo, hhi]
    change 18155 ≤ i ∧ i < 131072 at hi
    unfold BigFixed
    constructor
    · omega
    · constructor <;> omega
  have hroomN : NRoom setupP (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s2.ffi)
      (Host.Load.Layers.toLoad x.t.ffi) := by
    obtain ⟨P', hP, hf⟩ := hr.ffi.1
    obtain ⟨_, hE, hNE, _⟩ := Raised.restart (.inl rfl) hP
    constructor
    · have h := hf.load.mlx.hroom.2
      rw [hE] at h
      change (mlxOf x.t.ffi).next + (setupP.E - (mlxOf PRE_setup_h3_chunk.s1.ffi).next) < 2 ^ 46 at h
      rw [sameNativeNext] at h
      exact h
    · have h := hf.load.mlx.nroom.2.2
      rw [hNE] at h
      change (mlxOf x.t.ffi).nnext + (setupP.NE - (mlxOf PRE_setup_h3_chunk.s1.ffi).nnext) < 2 ^ 62 at h
      rw [sameNativeNnext] at h
      exact h
  have hc := Conv.full_compactQXD NB (P := setupP) (r := machReads T tk)
    (s0 := PRE_setup_h3_chunk.s2) (s1 := PRE_setup_h3_chunk.s1)
    (S0 := ⟨PRE_setup_h3_chunk.S2.tab, []⟩) (S1 := ⟨PRE_setup_h3_chunk.S1.tab, []⟩)
    PRE_setup_h3_chunk.raised0 hNB hr0 hs PRE_setup_h3_chunk.cbigs0 hfree hband
    (fun _ h => nomatch h) (by rw [hD]; decide) hroomN
  let N := (x.M.after PRE_setup_h3_chunk.kappa0).rebig (mlxOf PRE_setup_h3_chunk.s2.ffi).next
    setupP.E (mlxOf x.t.ffi).next
  let K' : Ctx := ⟨Shift.framedNext x.M x.K PRE_setup_h3_chunk.s1,
    PRE_setup_h3_chunk.s2.trace, x.t.trace, x.t.next - PRE_setup_h3_chunk.s2.next, x.K.lo, x.K.hi⟩
  let ν' := Shift.valuation θZ0 x.ν
  have hcD : RelB FF (FullRD { setupP with rest := machReads T tk } NB) noFrames [] N ν' K'
      PRE_setup_h3_chunk.s2 ⟨PRE_setup_h3_chunk.S2.tab, []⟩ x.t x.C := by
    obtain ⟨P', hP, hf⟩ := hc.ffi
    exact hc.mapFR' ⟨P', hP, hf.toR PRE_setup_h3_chunk.zbin0⟩
  have hcJ := hcD.afterJsFullDBlocks (M := x.M) (σ := PRE_setup_h3_chunk.kappa0) hr.ffi.2 rfl
    (fun _ hi => jsBig_rebig (by decide : setupP.E ≤ 2 ^ 56) hi)
    (by change x.K.lo ≤ 2 ^ 56; rw [hk.1.1]; decide)
    canonicalJsHeap canonicalJsRoots canonicalJsNative
  have hctx : Disp.KpJ setupJ 4096 K' := by
    exact ⟨Kp_restart hkp _ _ _, by change x.t.next - PRE_setup_h3_chunk.s2.next ≤ 4096; rw [hD]; decide⟩
  have hmemo' : K'.fr 4910 = none := by
    change Shift.framedNext x.M x.K PRE_setup_h3_chunk.s1 4910 = none
    exact (framedNext_none_iff (M := x.M) (s1 := (PRE_setup_h3_chunk.s1 : St FF.S)) 4910).mpr hmemo
  have hcW := inactiveMemo hcJ (wideInactive hmemo')
  have hcX : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP [] N.withJs ν' K'
      PRE_setup_h3_chunk.s2 ⟨PRE_setup_h3_chunk.S2.tab, []⟩ x.t x.C :=
    RelF.mapFR' hcW ⟨hcW.ffi.1.toXD, hcW.ffi.2⟩
  have hval : VBOkF loopVB ν' ∧ MapOk ν' (setupI L) [(9, .L)] := by
    have hout : ∀ v, PRE_setup_h3_chunk.ws0.contains v = false → x.ν v = ν v := by
      intro v hv
      rw [hν]
      exact Conv.resVal_off (fun hm => by
        have hc := List.contains_iff_mem.mpr hm
        rw [hv] at hc
        cases hc)
    constructor
    · apply Conv.vbOk_post (ws := PRE_setup_h3_chunk.cws0) (rs := PRE_setup_h3_chunk.crs0)
        (zs := PRE_setup_h3_chunk.ws0)
      · intro v hv; rw [hout v hv]; exact hvb v
      · intro j c r hj; cases hj
      · exact Nat.le_refl 0
    · change ν' 9 = F64.ofNat L ∧ True
      refine ⟨?_, trivial⟩
      change Shift.valuation (Conv.compactθZ [] PRE_setup_h3_chunk.crs0 PRE_setup_h3_chunk.ws0) x.ν 9 = _
      rw [Conv.valuation_compactθZ_out (by rfl) (by decide), hout 9 (by decide)]
      exact hmap.1
  refine ⟨⟨N.withJs, ν', K', x.t, x.C⟩, rfl, rfl, ⟨hcX, hval.1, hctx.1, hval.2⟩, ⟨?_, ?_⟩, ?_, ?_⟩
  · refine ⟨hctx, hmemo', π, hlen, hvocab, ?_, hD, hfresh⟩
    obtain ⟨o, ho, hkind⟩ := PRE_setup_h3_chunk.arr0_2665
    have hknd : o.kind = .array ([] ++ []) := by simpa only [sourcePromptEmpty, PRE_setup_h3_chunk.arrEl0_2665] using hkind
    have h := framedNext_of (M := x.M) hframe ho hknd
    simpa only [Map.vals, List.map_nil, List.append_nil] using h
  · have hκ : ∀ a ∈ [2586, 2589], PRE_setup_h3_chunk.kappa0.a a = a := by
      intro a ha
      simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
      rcases ha with rfl | rfl
      · exact Conv.Map.compact_lt (by decide : 2586 < 2673336)
      · exact Conv.Map.compact_lt (by decide : 2589 < 2673336)
    have ht := Track.compactPair (sm := PRE_setup_h3_chunk.s1) (sc := PRE_setup_h3_chunk.s2)
      (θk := θZ0) (P := setupP) (Track.refl [2586, 2589] x) hκ
    exact ⟨(ht 2586 (by decide)).trans hids.1, (ht 2589 (by decide)).trans hids.2⟩
  · intro j hj
    change Shift.valuation (Conv.compactθZ [] PRE_setup_h3_chunk.crs0 PRE_setup_h3_chunk.ws0) x.ν j = _
    apply Conv.valuation_compactθZ_out (by rfl)
    exact wsOff hj
  · change x.M.a (PRE_setup_h3_chunk.kappa0.a 2590) = x.M.a 2590
    have hκ : PRE_setup_h3_chunk.kappa0.a 2590 = 2590 :=
      Conv.Map.compact_lt (by decide : 2590 < 2673336)
    rw [hκ]


end Host.Ts.Sim.Compose.SetupH3

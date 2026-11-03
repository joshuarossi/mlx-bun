import host.sim.compose.a4b.fd_x4_L8.Sim
import host.sim.compose.a4b.fd_x4_L8.Prefill
import host.sim.compose.PfLink
import host.sim.compose.PreCall
import host.sim.compose.a4b.PF4L8EJClean
import host.sim.compose.a4b.PF4L8EFresh
import host.sim.compose.a4b.SetupCommonStart
import host.sim.compose.PreGrow
import host.sim.template.a4pre_fd_x4_L8_r0.SiteZ0
import host.sim.template.a4pre_fd_x4_L8_r0.SiteR0
import host.sim.template.a4pre_fd_x4_L8_r0.SiteD0
import host.sim.template.a4pre_fd_x4_L8_r0.S0Eq
import host.sim.template.a4pre_fd_x4_L8_r0.NCl0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.FDX4L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk Host.Ts.Sim.Compose.Pf

/-! # The final step's `nextPrefillStep`

From the pre-final cut: the template's own start, its stage merged and compacted at the pre-final frames. The stage's results are
fresh and unread, so the valuation stays the cut's off them and `PfBook` carries over. -/

kernel_rfl tokens0 : (mlxOf PRE_pf_x4_L8.s0.ffi).tokens = [.ref 1, .ref 2]

theorem startEq : (PRE_fd_x4_L8_r0.s0 : St FF.S) = PRE_pf_x4_L8.s0 := by
  have hf : fullSetTokens PRE_pf_x4_L8.s0.ffi [.ref 1, .ref 2] = PRE_pf_x4_L8.s0.ffi :=
    (congrArg (fullSetTokens PRE_pf_x4_L8.s0.ffi) tokens0.symm).trans (SetupCommon.fullSetTokens_self _)
  exact PRE_fd_x4_L8_r0.s0_tok.trans ((congrArg (fun z : FF.S => (PRE_pf_x4_L8.s0 : St FF.S).setFfi z) hf).trans rfl)

theorem toStart {NB T cap H N : Nat} {tk : Nat → Nat} {π : List Nat} {Mem : SegInst FF → Prop} :
    CutConv (withMem Mem (Pf.cut NB T tk π cap H N PRE_pf_x4_L8.s0 PRE_pf_x4_L8.S0))
      (withMem Mem (Pf.cut NB T tk π cap H N PRE_fd_x4_L8_r0.s0 PRE_fd_x4_L8_r0.S0)) := by
  rintro x ⟨hr, hb⟩ ⟨⟨hf, hc, hnat⟩, hm⟩
  refine ⟨x, rfl, rfl, ⟨?_, hb⟩, ⟨hf, hc, ?_⟩, hm⟩
  · change RelB FF _ wideGPf [] x.M x.ν x.K (PRE_fd_x4_L8_r0.s0 : St FF.S) ⟨PRE_fd_x4_L8_r0.S0.tab, []⟩ x.t x.C
    rw [startEq, PRE_fd_x4_L8_r0.s0_tab]
    exact hr
  · rw [startEq]
    exact hnat

theorem npsSim (NB T : Nat) (tk : Nat → Nat) (r : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      PRE_fd_x4_L8_r0.st0.okL (Disp.KpJ FDX4L8Frames.startJ 131072) wideGPf r (VBOkF loopVB) := by
  apply (startSim NB T tk r).mono
  intro s S h
  change (Disp.okJSJ FDX4L8Frames.startJ (okBackFXS setupP) 131072 s S && Disp.localB s) = true at h
  simp only [Bool.and_eq_true] at h
  exact h.1

theorem npsGrowSim (NB T : Nat) (tk : Nat → Nat) (r : List Frame) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      PRE_fd_x4_L8_r0.st0.okL (Disp.KpJ FDX4L8Frames.startJ 131072) wideGPf r (VBOkF loopVB) := by
  apply (startGrowSim NB T tk r y0).mono
  intro s S h
  change (Disp.okJSJ FDX4L8Frames.startJ (okBackFXS setupP) 131072 s S && Disp.localB s) = true at h
  simp only [Bool.and_eq_true] at h
  exact h.1

noncomputable def npsVal (ν : Nat → F64) := Conv.resVal ν PRE_fd_x4_L8_r0.ws0
  (Conv.resF SymE.var PRE_fd_x4_L8_r0.st0.S2.tab PRE_fd_x4_L8_r0.S0.tab.length ν)

/-- The merged state: the pre-final cut's book at the valuation before the stage's results. -/
noncomputable def mergedCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap H N : Nat) : ICut FF where
  s0 := PRE_fd_x4_L8_r0.s1
  tab0 := PRE_fd_x4_L8_r0.S1.tab
  R := fun x s S => RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideGPf [] x.M x.ν x.K s S x.t x.C ∧
    ∃ ν, x.ν = npsVal ν ∧ PfBook T tk cap π ⟨x.M, ν, x.K, x.t, x.C⟩
  B := fun x => AneFresh x.t ∧ fixedCells x ∧ NativeAt H N PRE_fd_x4_L8_r0.s1 x.t ∧
    Conv.CallFacts PRE_fd_x4_L8_r0.s0 PRE_fd_x4_L8_r0.S0.tab.length ∧ NB ≤ PRE_fd_x4_L8_r0.P0.NL ∧
    Conv.FullShiftQ PRE_fd_x4_L8_r0.P0 112 PRE_fd_x4_L8_r0.kappa0 PRE_fd_x4_L8_r0.s2.ffi PRE_fd_x4_L8_r0.s1.ffi

kernel_rfl npsWsLow : PRE_fd_x4_L8_r0.ws0.all (Nat.ble 1000) = true
kernel_rfl cnt1 : countersOkB PRE_fd_x4_L8_r0.s0 PRE_fd_x4_L8_r0.s1 = true
kernel_rfl bridge01 : bridgeOf PRE_fd_x4_L8_r0.s1.ffi = bridgeOf PRE_fd_x4_L8_r0.s0.ffi
kernel_rfl nnext0 : (mlxOf PRE_fd_x4_L8_r0.s0.ffi).nnext = 19265
theorem inactive0 : (bridgeOf PRE_fd_x4_L8_r0.s0.ffi).active = false := Host.Load.Boot.replay_active _

theorem low_off {j : Nat} (hj : j < 1000) : j ∉ PRE_fd_x4_L8_r0.ws0 := fun hm => by
  have h := Nat.le_of_ble_eq_true (List.all_eq_true.mp npsWsLow j hm)
  omega

theorem nps_merged {NB T cap H N : Nat} {tk : Nat → Nat} {π : List Nat} {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) (hcap : cap ≤ 131072)
    (horacle : ∀ x : SegInst FF, PfBook T tk cap π x → Mem x → Good x.ν PRE_fd_x4_L8_r0.st0.S0.oracle) :
    CutStep (withMem Mem (Pf.cut NB T tk π cap H N PRE_fd_x4_L8_r0.s0 PRE_fd_x4_L8_r0.S0))
      (withMem Mem (mergedCut NB T tk π cap H N)) (PRE_fd_x4_L8_r0.st0.tpl.n + 1) := by
  rintro t C ⟨x, rfl, rfl, ⟨hr, hb⟩, ⟨hfresh, hids, hnat⟩, hmem⟩
  have hk : Disp.KpJ FDX4L8Frames.startJ 131072 x.K := ⟨hb.context.1, Nat.le_trans hb.context.2 hcap⟩
  have h0 := hr.withOracle (horacle x hb hmem)
  change RelB FF _ wideGPf [] x.M x.ν x.K PRE_fd_x4_L8_r0.s0
    ⟨PRE_fd_x4_L8_r0.S0.tab, PRE_fd_x4_L8_r0.st0.S0.oracle⟩ x.t x.C at h0
  rw [← PRE_fd_x4_L8_r0.tab0_0] at h0
  let d := PRE_fd_x4_L8_r0.site0 (npsSim NB T tk)
  obtain ⟨M', t', C', run, ext, rel⟩ := Conv.site_merge d.tpl d.start rfl d.sim d.localOk
    hk hb.valuation d.foot d.nodup d.bound d.trace PRE_fd_x4_L8_r0.S0.tab.length h0
  rw [d.tab] at ext
  have hm := d.merged rel
  have hm' := hm.resMerge (tab := PRE_fd_x4_L8_r0.S0.tab) hr.srv.num ext (runC_le _ _ _ _ _ run) (d.tab ▸ d.tpl.len2)
    d.len d.freshNodup d.fresh
  have hi' : (bridgeOf PRE_fd_x4_L8_r0.s1.ffi).active = false := by rw [bridge01]; exact inactive0
  have fresh : AneFresh t' := by
    obtain ⟨_, _, r0⟩ := hr.ffi.1
    obtain ⟨_, _, r1⟩ := hm'.ffi.1
    have he : bridgeOf t'.ffi = bridgeOf x.t.ffi :=
      (r1.toR hi').bridge.1.trans (bridge01.trans (r0.toR inactive0).bridge.1.symm)
    intro Cx Pc Kc weights kind NE IP G init
    rw [he]
    exact hfresh Cx Pc Kc weights kind NE IP G init
  have top := hr.ffi.1.top (by rfl)
  have hNL : ({ setupP with rest := machReads T tk }.raise
      (mlxOf PRE_fd_x4_L8_r0.s0.ffi).nnext).NL ≤ PRE_fd_x4_L8_r0.P0.NL := by
    change (mlxOf PRE_fd_x4_L8_r0.s0.ffi).nnext ≤ PRE_fd_x4_L8_r0.P0.NL
    rw [nnext0]
    exact Nat.le_refl _
  have ng : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf t'.ffi) :=
    d.ngrow (fun stk y0 => npsGrowSim NB T tk stk y0) hb.valuation hk h0 run
  refine ⟨t', C', run, ⟨M', npsVal x.ν, x.K, t', C'⟩, rfl, rfl, ?_, ?_⟩
  · change RelB FF _ wideGPf [] M' (npsVal x.ν) x.K PRE_fd_x4_L8_r0.s1 ⟨PRE_fd_x4_L8_r0.S1.tab, []⟩ t' C' ∧ _
    rw [PRE_fd_x4_L8_r0.mergeTab0]
    refine ⟨hm', x.ν, rfl, ?_⟩
    exact { hb with inputs := ⟨hb.inputs.1, (congrFun ext.a 2590).trans hb.inputs.2⟩ }
  · refine ⟨⟨fresh, ⟨(congrFun ext.a 2586).trans hids.1, (congrFun ext.a 2589).trans hids.2⟩,
      hnat.step (P := { setupP with rest := machReads T tk }) rfl hr hm' ext.big ext.node cnt1,
      ⟨hr.presentBound, hr.heapSupp⟩, Nat.le_trans top.1.load.mlx.nbl hNL, PRE_fd_x4_L8_r0.cshiftR0 top.1 hNL⟩,
      hMem x _ ⟨runC_le _ _ _ _ _ run, ext.node, ng, tokens_of_grow hr hm' ng (countersOkB_tokens cnt1), congrFun ext.a 12504⟩ hmem⟩

/-! ## The compaction -/

noncomputable def θZ1 : Nat → SymE := Conv.compactθZ PRE_fd_x4_L8_r0.cws0 PRE_fd_x4_L8_r0.crs0 PRE_fd_x4_L8_r0.ws0

theorem start_xs : ∀ a, a ∈ [2665] ↔ a ∈ (2665 :: 4910 :: ghostPf) ∧ wideGPf a = none := by
  intro a
  constructor
  · intro h
    obtain rfl := List.mem_singleton.mp h
    exact ⟨by simp, rfl⟩
  · rintro ⟨hm, hw⟩
    simp only [ghostPf, List.mem_cons, List.not_mem_nil, or_false] at hm
    rcases hm with rfl | rfl | rfl | rfl | rfl | rfl | rfl
    · simp
    all_goals cases hw

theorem start_framed : ∀ a w, wideGPf a = some w → a ∈ (2665 :: 4910 :: ghostPf) := by
  intro a w hw
  have h : (wideListPf.map Prod.fst).all (fun b => (2665 :: 4910 :: ghostPf).contains b) = true := by decide
  exact List.contains_iff_mem.mp (List.all_eq_true.mp h a (List.mem_map.mpr ⟨(a, w), lookupW_mem hw, rfl⟩))

theorem start_present : ∀ a w, wideGPf a = some w → Present PRE_fd_x4_L8_r0.s2 a := by
  intro a w hw
  have hm : (a, w) ∈ wideListPf := lookupW_mem hw
  simp only [wideListPf, wideListOf, ghostPf, List.map_cons, List.map_nil, List.mem_cons, List.not_mem_nil, or_false, Prod.mk.injEq] at hm
  rcases hm with ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩
  · exact PRE_fd_x4_L8_r0.zw0_4910
  · exact PRE_fd_x4_L8_r0.zw0_1824
  · exact PRE_fd_x4_L8_r0.zw0_1834
  · exact PRE_fd_x4_L8_r0.zw0_1852
  · exact PRE_fd_x4_L8_r0.zw0_1993
  · exact PRE_fd_x4_L8_r0.zw0_2001

theorem start_fix {σ : Map} {P : Nat → Prop} : ∀ a w, wideGPf a = some w → WFix σ P w := by
  intro a w hw
  have hm : (a, w) ∈ wideListPf := lookupW_mem hw
  simp only [wideListPf, wideListOf, ghostPf, List.map_cons, List.map_nil, List.mem_cons, List.not_mem_nil, or_false, Prod.mk.injEq] at hm
  rcases hm with ⟨-, rfl⟩ | ⟨-, rfl⟩ | ⟨-, rfl⟩ | ⟨-, rfl⟩ | ⟨-, rfl⟩ | ⟨-, rfl⟩ <;> trivial

kernel_rfl promptEmpty : arrOf PRE_fd_x4_L8_r0.s0 2665 = []

theorem npsShift {K : Ctx} (hk : Disp.Kp FDX4L8Frames.startJ K) {π : List Nat}
    (hframe : K.fr 2665 = some ([], π.map natV))
    (hcall : Conv.CallFacts PRE_fd_x4_L8_r0.s0 PRE_fd_x4_L8_r0.S0.tab.length)
    (hnative : Conv.FullShiftQ PRE_fd_x4_L8_r0.P0 112 PRE_fd_x4_L8_r0.kappa0
      PRE_fd_x4_L8_r0.s2.ffi PRE_fd_x4_L8_r0.s1.ffi) :
    ShiftD FF (fun σ x y => x = PRE_fd_x4_L8_r0.s2.ffi ∧
      Conv.FullShiftQX PRE_fd_x4_L8_r0.P0 PRE_fd_x4_L8_r0.S2.tab.length σ x y)
      PRE_fd_x4_L8_r0.kappa0 θZ1 (kpOf K wideGPf) wideGPf K
      PRE_fd_x4_L8_r0.s2 ⟨PRE_fd_x4_L8_r0.S2.tab, []⟩
      PRE_fd_x4_L8_r0.s1 ⟨PRE_fd_x4_L8_r0.S1.tab, []⟩ := by
  have hroots := checkRootsSupp_sound (s := (PRE_fd_x4_L8_r0.s2 : St FF.S)) PRE_fd_x4_L8_r0.zroots0
  have hs := Conv.compact_shift (F := FF) (W := wideGPf) (K1 := K)
    PRE_fd_x4_L8_r0.zkap0 hcall PRE_fd_x4_L8_r0.jcl0 PRE_fd_x4_L8_r0.cfix0
    (fun p hp => Nat.le_of_ble_eq_true (List.all_eq_true.mp PRE_fd_x4_L8_r0.zpl0 p hp))
    (nodupT_sound PRE_fd_x4_L8_r0.zplnd0).2 (Nat.le_of_ble_eq_true PRE_fd_x4_L8_r0.zn10)
    (Nat.le_of_ble_eq_true PRE_fd_x4_L8_r0.zfirst0) PRE_fd_x4_L8_r0.zscn0 PRE_fd_x4_L8_r0.zsmn0
    (Nat.le_of_ble_eq_true PRE_fd_x4_L8_r0.zgrow0) PRE_fd_x4_L8_r0.mergeTab0
    (noVar_of_all PRE_fd_x4_L8_r0.zfresh0) (nodupT_sound PRE_fd_x4_L8_r0.zcnd0).2
    (by rfl : PRE_fd_x4_L8_r0.cws0.length = PRE_fd_x4_L8_r0.nr0.length)
    (fun r hr => Nat.blt_eq.mp (List.all_eq_true.mp PRE_fd_x4_L8_r0.znrHi0 r hr))
    hk.2.2 (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_fd_x4_L8_r0.zfrlt0 a ha))
    (Xs := [2665]) start_xs start_framed
    (by
      intro a pre pre' hka hw
      have ha := (hk.2.2 a).mp (by rw [hka]; exact Option.some_ne_none _)
      have ha' := (start_xs a).mpr ⟨ha, hw⟩
      obtain rfl := List.mem_singleton.mp ha'
      rw [hframe] at hka
      cases hka
      refine ⟨_, arrOf PRE_fd_x4_L8_r0.s1 2665, PRE_fd_x4_L8_r0.zg0_2665, ?_, ?_⟩
      · rw [PRE_fd_x4_L8_r0.zk0_2665, promptEmpty]
      · simpa only [promptEmpty, List.length_nil, List.drop_zero, List.nil_append] using
          PRE_fd_x4_L8_r0.zm0_2665)
    start_present start_fix
    (Conv.heap_off_setAll PRE_fd_x4_L8_r0.cheap0
      (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_fd_x4_L8_r0.zclbd0 a ha)))
    (hoff_of PRE_fd_x4_L8_r0.mheap0 PRE_fd_x4_L8_r0.stFoot0 PRE_fd_x4_L8_r0.iso0 PRE_fd_x4_L8_r0.zwr0)
    PRE_fd_x4_L8_r0.ckeepP0 PRE_fd_x4_L8_r0.csupp0 PRE_fd_x4_L8_r0.cbound0 PRE_fd_x4_L8_r0.zimg0
    PRE_fd_x4_L8_r0.zctl0 PRE_fd_x4_L8_r0.zstack0 PRE_fd_x4_L8_r0.zjobs0 PRE_fd_x4_L8_r0.zstores0
    (by rw [PRE_fd_x4_L8_r0.znC0]; exact hroots.1)
    (by rw [PRE_fd_x4_L8_r0.znC0]; exact hroots.2.1)
    (by rw [PRE_fd_x4_L8_r0.znC0]; exact hroots.2.2.1)
    (by rw [PRE_fd_x4_L8_r0.znC0]; exact hroots.2.2.2)
    (Conv.bigFixed_of_mshift hnative.load.mlx hk.1 hk.2.1)
  have hs' : ShiftD FF (fun _ _ _ => True) PRE_fd_x4_L8_r0.kappa0 PRE_fd_x4_L8_r0.ctheta0
      (kpOf K wideGPf) wideGPf K PRE_fd_x4_L8_r0.s2 ⟨PRE_fd_x4_L8_r0.S2.tab, []⟩
      PRE_fd_x4_L8_r0.s1 ⟨PRE_fd_x4_L8_r0.S1.tab, []⟩ := by
    rw [PRE_fd_x4_L8_r0.ctab0]
    exact hs
  have hθ := hs'.retheta (θ' := θZ1) (by
    rw [PRE_fd_x4_L8_r0.ctab0]
    exact Conv.compactθZ_tab
      (noVar_of_all (by have h := PRE_fd_x4_L8_r0.fresh0; simp only [Bool.and_eq_true] at h; exact h.1))
      (disj_of_all PRE_fd_x4_L8_r0.cwsDisj0))
  exact { hθ with ffi := ⟨rfl, by
    rw [PRE_fd_x4_L8_r0.ctab0]
    change Conv.FullShiftQX PRE_fd_x4_L8_r0.P0 112 PRE_fd_x4_L8_r0.kappa0 _ _
    exact hnative.toX PRE_fd_x4_L8_r0.zbin0⟩ }

/-! The JS bookkeeping: the pre-final template's heap, the stage's few changed entries. -/

kernel_rfl jsList0 : PRE_fd_x4_L8_r0.cl0.all (noBigAtP (jsAboveB 2834417) PRE_fd_x4_L8_r0.s2) = true
kernel_rfl jsRoots2 : noBigRootsP (jsAboveB 2834417) PRE_fd_x4_L8_r0.s2.trace PRE_fd_x4_L8_r0.s2 = true
kernel_rfl npsJsNative : bigsOutB jsLoN jsHiN (mlxOf PRE_fd_x4_L8_r0.s2.ffi) = true

theorem jsHeap2 : JsHeapAbove 2834417 PRE_fd_x4_L8_r0.s2 := by
  have h0 : JsHeapAbove 2834417 (PRE_fd_x4_L8_r0.s0 : St FF.S) := by
    rw [startEq]
    exact PRE_pf_x4_L8.jsHeap
  exact h0.step (Nat.le_refl _) (Conv.heap_off_setAll PRE_fd_x4_L8_r0.cheap0
    (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_fd_x4_L8_r0.zclbd0 a ha))) jsList0

theorem jsBad_above {i : Int} (h : jsShiftBadB PRE_fd_x4_L8_r0.kappa0 i = true) : jsAboveB 2834417 i = true := by
  cases hp : jsPtrOf i with
  | none => simp only [jsShiftBadB, hp] at h; cases h
  | some p =>
    obtain ⟨b, off⟩ := p
    obtain ⟨he, hb, _⟩ := jsPtrOf_some hp
    simp only [jsAboveB, hp]
    apply Nat.ble_eq_true_of_le
    refine Nat.le_of_not_lt fun hn => ?_
    have ha : PRE_fd_x4_L8_r0.kappa0.a b = b := by
      rw [PRE_fd_x4_L8_r0.zkap0]
      exact Conv.Map.compact_lt (by change b < 2834417; omega)
    have hi : PRE_fd_x4_L8_r0.kappa0.big i = i := by
      rw [PRE_fd_x4_L8_r0.zkap0]
      exact Conv.rdata_big_js PRE_fd_x4_L8_r0.kd0 i (by rw [hp]; exact Option.some_ne_none _)
    unfold jsShiftBadB at h
    simp only [hp] at h
    rw [ha, hi, he] at h
    simp only [decide_true, Nat.blt_eq.mpr hb, Bool.and_self, Bool.not_true] at h
    cases h

noncomputable def npsPair (x : SegInst FF) := prefillCompactPair setupP PRE_fd_x4_L8_r0.kappa0 θZ1 PRE_fd_x4_L8_r0.s1 PRE_fd_x4_L8_r0.s2 x

kernel_rfl next2 : (mlxOf PRE_fd_x4_L8_r0.s2.ffi).next = 22174
kernel_rfl sameNext1 : (mlxOf PRE_fd_x4_L8_r0.s1.ffi).next = (mlxOf PRE_fd_x4_L8_r0.s2.ffi).next
kernel_rfl sameNnext1 : (mlxOf PRE_fd_x4_L8_r0.s1.ffi).nnext = (mlxOf PRE_fd_x4_L8_r0.s2.ffi).nnext
kernel_rfl keepNN1 : PRE_fd_x4_L8_r0.kd0.nn0 = PRE_fd_x4_L8_r0.kd0.nn1
kernel_rfl keepNK1 : PTrie.keys PRE_fd_x4_L8_r0.kd0.node = []
kernel_rfl snext1 : PRE_fd_x4_L8_r0.s1.next = 2834430
kernel_rfl snext2 : PRE_fd_x4_L8_r0.s2.next = 2834418

theorem θZ1_off {ν : Nat → F64} {j : Nat} (hj : j < 1000) : Shift.valuation θZ1 ν j = ν j := by
  have h1 : Conv.idx? j PRE_fd_x4_L8_r0.cws0 = none := rfl
  have h2 : PRE_fd_x4_L8_r0.ws0.contains j = false := by
    apply Bool.eq_false_iff.mpr
    intro hc
    exact low_off hj (List.contains_iff_mem.mp hc)
  exact Conv.valuation_compactθZ_out h1 h2

/-- The stage's results go to zero, the rest are the cut's. -/
theorem θZ1_val {ν : Nat → F64} (hv : VBOkF loopVB ν) : VBOkF loopVB (Shift.valuation θZ1 (npsVal ν)) := by
  intro j
  have h1 : Conv.idx? j PRE_fd_x4_L8_r0.cws0 = none := rfl
  cases hc : PRE_fd_x4_L8_r0.ws0.contains j with
  | false =>
    obtain ⟨k, hk, he⟩ := hv j
    refine ⟨k, hk, (Conv.valuation_compactθZ_out h1 hc).trans (Eq.trans ?_ he)⟩
    exact Conv.resVal_off (fun hm => by rw [List.contains_iff_mem.mpr hm] at hc; cases hc)
  | true => exact ⟨0, Nat.zero_le _, Conv.valuation_compactθZ_zero h1 hc⟩

/-- **After the stage**: the pre-final cut's book at the template's next boundary. -/
theorem nps_compact {NB T cap H N capA : Nat} {tk : Nat → Nat} {π : List Nat} {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) (hcapA : cap + 12 ≤ capA) (hbound : capA < Sim.bound) :
    CutConv (withMem Mem (mergedCut NB T tk π cap H N)) (withMem Mem (Pf.cut NB T tk π capA H N PRE_fd_x4_L8_r0.s2 PRE_fd_x4_L8_r0.S2)) := by
  rintro x ⟨hr, ν, hν, hb⟩ ⟨⟨hfresh, hids, hnat, hcall, hNB, hnative⟩, hm⟩
  have hK : Disp.Kp PostOk.J0 x.K := hb.context.1
  have hDK : x.K.D ≤ cap := hb.context.2
  have hkp : Disp.Kp FDX4L8Frames.startJ x.K := hK
  have hframe : x.K.fr 2665 = some ([], π.map natV) := hb.prompt
  have hs := npsShift hkp hframe hcall hnative
  have hD : x.t.next - PRE_fd_x4_L8_r0.s2.next = x.K.D + 12 := by
    have h := hr.offset
    change x.t.next = PRE_fd_x4_L8_r0.s1.next + x.K.D at h
    rw [snext1] at h
    rw [h, snext2]
    omega
  have hfree := Conv.jclean_noBigSt (lo := (mlxOf PRE_fd_x4_L8_r0.s2.ffi).next) (E := setupP.E)
    (PRE_fd_x4_L8_r0.cjcl0 PRE_fd_x4_L8_r0.jcl0) (by rw [next2]) (by decide : setupP.E ≤ RData.bigHi)
    PRE_fd_x4_L8_r0.zroots20
  have hlo : x.K.lo = 18151 := hK.1
  have hhi : x.K.hi = 131072 := hK.2.1
  have hband : ∀ i : Int, ((mlxOf PRE_fd_x4_L8_r0.s2.ffi).next : Int) ≤ i ∧ i < setupP.E →
      ¬ BigFixed x.K.lo x.K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56 := by
    intro i hi
    rw [next2] at hi
    rw [hlo, hhi]
    change 22174 ≤ i ∧ i < 131072 at hi
    unfold BigFixed
    constructor
    · omega
    · constructor <;> omega
  have hroomN : NRoom setupP (Host.Load.Layers.toLoad PRE_fd_x4_L8_r0.s2.ffi) (Host.Load.Layers.toLoad x.t.ffi) := by
    obtain ⟨P', hP, hf⟩ := hr.ffi.1
    obtain ⟨_, hE, hNE, _⟩ := Raised.restart (.inl rfl) hP
    constructor
    · have h := hf.load.mlx.hroom.2
      rw [hE] at h
      change (mlxOf x.t.ffi).next + (setupP.E - (mlxOf PRE_fd_x4_L8_r0.s1.ffi).next) < 2 ^ 46 at h
      rw [sameNext1] at h
      exact h
    · have h := hf.load.mlx.nroom.2.2
      rw [hNE] at h
      change (mlxOf x.t.ffi).nnext + (setupP.NE - (mlxOf PRE_fd_x4_L8_r0.s1.ffi).nnext) < 2 ^ 62 at h
      rw [sameNnext1] at h
      exact h
  have hc := Conv.full_compactQXD NB (P := setupP) (r := machReads T tk)
    (s0 := PRE_fd_x4_L8_r0.s2) (s1 := PRE_fd_x4_L8_r0.s1)
    (S0 := ⟨PRE_fd_x4_L8_r0.S2.tab, []⟩) (S1 := ⟨PRE_fd_x4_L8_r0.S1.tab, []⟩)
    PRE_fd_x4_L8_r0.raised0 hNB hr.ofJ hs PRE_fd_x4_L8_r0.cbigs0 hfree hband
    (fun _ h => nomatch h) (by rw [hD]; omega) hroomN
  let N' := (x.M.after PRE_fd_x4_L8_r0.kappa0).rebig (mlxOf PRE_fd_x4_L8_r0.s2.ffi).next setupP.E (mlxOf x.t.ffi).next
  let K' : Ctx := ⟨Shift.framedNext x.M x.K PRE_fd_x4_L8_r0.s1,
    PRE_fd_x4_L8_r0.s2.trace, x.t.trace, x.t.next - PRE_fd_x4_L8_r0.s2.next, x.K.lo, x.K.hi⟩
  have hJs : NoBigSt (JsBad N') K'.base PRE_fd_x4_L8_r0.s2 :=
    noBigSt_of_above jsHeap2 jsRoots2 (fun j hj => jsBad_above
      (jsBad_after (M := x.M) (N := N') (σ := PRE_fd_x4_L8_r0.kappa0) hr.ffi.2 rfl
        (fun _ h => jsBig_rebig (by decide : setupP.E ≤ 2 ^ 56) h) hj))
  have hcJ := (hc.withJs (by change x.K.lo ≤ 2 ^ 56; rw [hlo]; decide) hJs
    (fullRXD_withJs hc.ffi npsJsNative)).toJ (BigJs.withJs N')
  have hctx : Disp.KpJ PostOk.J0 capA K' :=
    ⟨Kp_restart hkp _ _ _, by change x.t.next - PRE_fd_x4_L8_r0.s2.next ≤ capA; rw [hD]; omega⟩
  have hfrp : K'.fr 2665 = some ([], π.map natV) := by
    obtain ⟨o, ho, hkind⟩ := PRE_fd_x4_L8_r0.arr0_2665
    have hknd : o.kind = .array ([] ++ []) := by
      simpa only [promptEmpty, PRE_fd_x4_L8_r0.arrEl0_2665] using hkind
    have h := framedNext_of (M := x.M) hframe ho hknd
    change Shift.framedNext x.M x.K PRE_fd_x4_L8_r0.s1 2665 = some ([], π.map natV)
    simpa only [Map.vals, List.map_nil, List.append_nil] using h
  have hres : ∀ {j : Nat}, j < 1000 → Shift.valuation θZ1 x.ν j = ν j := by
    intro j hj
    rw [θZ1_off hj, hν]
    exact Conv.resVal_off (low_off hj)
  refine ⟨npsPair x, rfl, rfl, ⟨hcJ, ?_⟩, ⟨hfresh, ?_, ⟨sameNext1 ▸ hnat.1, sameNnext1 ▸ hnat.2⟩⟩,
    hMem x _ (NTrack.conv rfl rfl (funext fun k => congrArg x.M.node (compact_node_id keepNN1 keepNK1 k))
      (by change x.M.a (PRE_fd_x4_L8_r0.kappa0.a 12504) = _; rw [PRE_fd_x4_L8_r0.zkap0, Conv.Map.compact_lt (by decide)])) hm⟩
  · refine
      { vocab := hb.vocab
        valuation := by
          change VBOkF loopVB (Shift.valuation θZ1 x.ν)
          rw [hν]
          exact θZ1_val hb.valuation
        promptValue := (hres (by decide)).trans hb.promptValue
        rowValue := (hres (by decide)).trans hb.rowValue
        offsetValue := (hres (by decide)).trans hb.offsetValue
        capValue := (hres (by decide)).trans hb.capValue
        context := hctx
        prompt := hfrp
        inputs := ⟨fun j hj => ?_, ?_⟩ }
    · change Shift.valuation θZ1 x.ν j = _
      rw [hres (by omega)]
      exact hb.inputs.1 j hj
    · change x.M.a (PRE_fd_x4_L8_r0.kappa0.a 2590) = 2590
      have he : PRE_fd_x4_L8_r0.kappa0.a 2590 = 2590 := by rw [PRE_fd_x4_L8_r0.zkap0]; exact Conv.Map.compact_lt (by decide)
      rw [he]
      exact hb.inputs.2
  · change x.M.a (PRE_fd_x4_L8_r0.kappa0.a 2586) = 2586 ∧ x.M.a (PRE_fd_x4_L8_r0.kappa0.a 2589) = 2589
    have h6 : PRE_fd_x4_L8_r0.kappa0.a 2586 = 2586 := by rw [PRE_fd_x4_L8_r0.zkap0]; exact Conv.Map.compact_lt (by decide)
    have h9 : PRE_fd_x4_L8_r0.kappa0.a 2589 = 2589 := by rw [PRE_fd_x4_L8_r0.zkap0]; exact Conv.Map.compact_lt (by decide)
    rw [h6, h9]
    exact hids

end Host.Ts.Sim.Compose.FDX4L8

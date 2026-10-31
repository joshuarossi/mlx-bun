import host.sim.compose.a4b.VWBodySiteStep
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- The growth version of the local body simulation, for a site's native growth. -/
theorem bodyGrowLocalSim (NB T : Nat) (tk : Nat → Nat) (bs : List Byte) (n : Nat)
    (stk : List Frame) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (okLocal (VWFrames.bodyOk bs n)) (Disp.KpJ (VWFrames.typedJ bs n) VWFrames.bodyD0)
      (VWFrames.typedW bs n) stk (VBOkF loopVB) := by
  apply (typedGrowSimAt NB T tk bs n VWFrames.bodyD0 stk y0).mono
  intro s S h
  simp only [okLocal, Bool.and_eq_true] at h
  exact h.1

/-- **One compacting call of the body**: the checked site run and its compaction, carrying the
book, the input, the reserved variables and the row's mapped variables to the canonical state. -/
theorem bodySite {NB T n : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {O O' : BodyOff}
    {m : List (Nat × Q)} {sa sm sc s0 : St FF.S} {Sa Sm Sc : SSrv} {ws cws nr pl l : List Nat}
    {n1 nC : Nat} {D : RData} {κ : Map} {P0 : LoadP} {c c2 : Conv.Cnt} {S2 : List SymE}
    {Es : List (Option SymE)} {qs : List (Option Q)}
    {ok : List Byte → Nat → St FF.S → SSrv → Bool}
    (d : ∀ bs rows, PrefillSite (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (Disp.KpJ (VWFrames.typedJ bs rows) VWFrames.bodyD0) (VWFrames.typedW bs rows) (ok bs rows)
      sa sm Sa ws)
    (hgrow : ∀ bs rows stk y0, Disp.StepSimXLB FF
      (FRQ (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
        (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (ok bs rows) (Disp.KpJ (VWFrames.typedJ bs rows) VWFrames.bodyD0)
      (VWFrames.typedW bs rows) stk (VBOkF loopVB))
    (hn : ∀ bs rows, (d bs rows).tpl.n = n)
    (hS2 : ∀ bs rows, (d bs rows).tpl.S2.tab = S2)
    (F : BodySiteFacts sa sm sc s0 Sa Sm Sc ws cws nr pl l n1 nC D κ P0 c c2)
    (hgood : ∀ bs rows ν, MapOk ν i m → Good ν (d bs rows).tpl.S0.oracle)
    (hEs : ∀ ν, MapOk ν i m → ∀ j o oq, nth? Es j = some o → nth? qs j = some oq →
      ∃ E, o = some E ∧ (∃ k ≤ 2 ^ 20, E.eval ν = F64.ofNat k) ∧
        ∀ q, oq = some q → E.eval ν = F64.ofNat (i.get q))
    (hlq : qs.length = cws.length) (hder : nr.map (fun r => nth? S2 r) = Es)
    (hnrLo : nr.all (Nat.ble Sa.tab.length) = true)
    (hsub : ∀ p ∈ m, (Conv.idx? p.1 cws = none ∧ ws.contains p.1 = false) ∨
      ∃ j, nth? cws j = some p.1 ∧ nth? qs j = some (some p.2))
    (hDmax : O.D + (sm.next - sc.next) ≤ O'.D) (hD' : O'.D ≤ VWFrames.bodyD0)
    (hHmax : O.H + ((mlxOf sm.ffi).next - (mlxOf sc.ffi).next) ≤ O'.H) (hH' : O'.H ≤ 2 ^ 40)
    (hNmax : O.N + ((mlxOf sm.ffi).nnext - (mlxOf sc.ffi).nnext) ≤ O'.N) (hN' : O'.N ≤ 2 ^ 40) :
    CutStep (bodyCut NB T tk π i O m sa Sa) (bodyCut NB T tk π i O' m sc Sc) (n + 1) := by
  rintro t C ⟨x, rfl, rfl, ⟨K0, hr, hb, hnat, hip, hins, hmap⟩, hfresh, hids⟩
  let bs := tokenBytes (π.take i.n)
  let rows := (π.take i.n).length
  let d0 := d bs rows
  have hr1 : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW bs rows) [] x.M x.ν x.K sa ⟨Sa.tab, []⟩ x.t x.C := hr
  have h0 : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW bs rows) [] x.M x.ν x.K sa d0.tpl.S0 x.t x.C := by
    have h := hr1.withOracle (hgood bs rows x.ν hmap)
    rw [← d0.tab] at h
    exact h
  have hlen2 : Sa.tab.length ≤ d0.tpl.S2.tab.length := by
    have h := d0.tpl.len2
    rw [d0.tab] at h
    exact h
  obtain ⟨M', t', C', hrun0, hext, h2⟩ := Conv.site_merge d0.tpl d0.start rfl d0.sim d0.localOk
    hb.context hb.valuation d0.foot d0.nodup d0.bound d0.trace Sa.tab.length h0
  rw [d0.tab] at hext
  have hrun : runC FF (n + 1) x.t x.C = some (t', C') := by
    rw [← hn bs rows]; exact hrun0
  replace h2 := d0.merged h2
  have hm := h2.resMerge hr1.srv.num hext (runC_le _ _ _ _ _ hrun0) hlen2
    d0.len d0.freshNodup d0.fresh
  rw [hS2 bs rows] at hm
  let ν1 := Conv.resVal x.ν ws (Conv.resF SymE.var S2 Sa.tab.length x.ν)
  have hm' : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW bs rows) [] M' ν1 x.K sm ⟨Sm.tab, []⟩ t' C' := by
    rw [F.mergeTab]
    exact hm
  have ng := d0.ngrow (hgrow bs rows) hb.valuation hb.context h0 hrun0
  have hle := runC_le _ _ _ _ _ hrun0
  have ip : InputAt (π.take i.n) (M'.node 15235) t' C' := by
    rw [hext.node]
    exact hip.grow ng hle
  -- the canonical state's shift
  have hk := hb.context
  have hmemo := hb.memo
  have hr0 := inactiveMemo hm'.ofJ (compactW_agree bs rows hmemo)
  have top := hr.ffi.1.top (by rfl)
  have hNL : ({ setupP with rest := machReads T tk }.raise (mlxOf sa.ffi).nnext).NL ≤ P0.NL := by
    change (mlxOf sa.ffi).nnext ≤ P0.NL
    exact F.nnextLe
  have hNB : NB ≤ P0.NL := top.1.load.mlx.nbl.trans hNL
  have hnative := F.cshiftR top.1 hNL
  have hfreshW : ∀ e ∈ Sa.tab, ∀ w ∈ ws, e.noVar w = true := d0.fresh
  have hs := bodyShift F hk.1 hb.prompt hb.chunk ⟨hr.presentBound, hr.heapSupp⟩ hnative hfreshW
  have hD : t'.next - sc.next = x.K.D + (sm.next - sc.next) := by
    have h := hm'.offset
    have hg := Nat.le_of_ble_eq_true F.zgrow
    omega
  have hfree := Conv.jclean_noBigSt (lo := (mlxOf sc.ffi).next) (E := setupP.E)
    (F.cjcl F.clean) F.xnLe (by decide : setupP.E ≤ RData.bigHi) F.zroots2
  have hband : ∀ j : Int, ((mlxOf sc.ffi).next : Int) ≤ j ∧ j < setupP.E →
      ¬ BigFixed x.K.lo x.K.hi j ∧ 0 ≤ j ∧ j < 2 ^ 56 := by
    intro j hj
    have hlo : x.K.lo = 18151 := hk.1.1
    have hhi : x.K.hi = 131072 := hk.1.2.1
    have hl : (18151 : Nat) ≤ (mlxOf sc.ffi).next := F.loLe
    rw [hlo, hhi]
    change _ ∧ j < 131072 at hj
    unfold BigFixed
    constructor
    · omega
    · constructor <;> omega
  have hnat' := hnat.step (P := { setupP with rest := machReads T tk }) rfl hr hm' hext.big hext.node F.cntM
  have hnatC : NativeAt O'.H O'.N sc t' := by
    obtain ⟨h1, h2⟩ := hnat'
    constructor <;> omega
  have hroomN : NRoom setupP (Host.Load.Layers.toLoad sc.ffi) (Host.Load.Layers.toLoad t'.ffi) := by
    obtain ⟨h1, h2⟩ := hnatC
    have hE : setupP.E = 131072 := rfl
    have hNE : setupP.NE = 1099511627776 := rfl
    have hhi := F.hiLe
    have hnhi := F.nhiLe
    constructor
    · change (mlxOf t'.ffi).next + (setupP.E - (mlxOf sc.ffi).next) < 2 ^ 46
      omega
    · change (mlxOf t'.ffi).nnext + (setupP.NE - (mlxOf sc.ffi).nnext) < 2 ^ 62
      omega
  have hoffK : x.K.D ≤ O.D := hb.offset
  have hc := Conv.full_compactQXD NB (P := setupP) (r := machReads T tk)
    (s0 := sc) (s1 := sm) (S0 := ⟨Sc.tab, []⟩) (S1 := ⟨Sm.tab, []⟩)
    F.raised hNB hr0 hs F.cbigs hfree hband (fun _ h => nomatch h)
    (by rw [hD]; change x.K.D + (sm.next - sc.next) < Sim.bound; simp only [Sim.bound, VWFrames.bodyD0] at *; omega)
    hroomN
  let N := (M'.after κ).rebig (mlxOf sc.ffi).next setupP.E (mlxOf t'.ffi).next
  let K' : Ctx := ⟨Shift.framedNext M' x.K sm, sc.trace, t'.trace, t'.next - sc.next, x.K.lo, x.K.hi⟩
  have hJs : NoBigSt (JsBad N) K'.base sc :=
    noBigSt_of_above F.jsHeap F.jsRoots (fun j hj => by
      have hbad := jsBad_after (M := M') (N := N) (σ := κ) hm'.ffi.2 rfl
        (fun _ h => jsBig_rebig (by decide : setupP.E ≤ 2 ^ 56) h) hj
      rw [F.zkap] at hbad
      exact jsShiftBad_above hbad)
  have hcJ := (hc.withJs (by change x.K.lo ≤ 2 ^ 56; rw [hk.1.1]; change 18151 ≤ 2 ^ 56; decide) hJs
    (fullRXD_withJs hc.ffi F.jsNative)).toJ (BigJs.withJs N)
  have hfr : K'.fr = x.K.fr := bodyFramesNext F.framesEmpty hk.1
  have hctx : Disp.KpJ (VWFrames.typedJ bs rows) VWFrames.bodyD0 K' :=
    ⟨Kp_restart hk.1 _ _ _, by
      change t'.next - sc.next ≤ VWFrames.bodyD0
      rw [hD]
      omega⟩
  have hmemo' : K'.fr 4910 = none := by rw [hfr]; exact hmemo
  have hcW := inactiveMemo hcJ (fun a ha => (compactW_agree bs rows hmemo' a ha).symm)
  -- the valuation
  let θ := Conv.compactθZ cws (nr.map fun r => (nth? Sm.tab r).getD (.var 0)) ws
  have hval := post_callV (m := m) (qs := qs) (tab := Sa.tab) (S2 := S2) (Sm := Sm.tab)
    (ws := ws) (cws := cws) (nr := nr) (n0 := Sa.tab.length) (Es := Es) (i := i)
    hb.valuation F.mergeTab rfl (by rw [← hS2 bs rows]; exact d0.len) d0.freshNodup
    (nodupT_sound F.zcnd).2 F.lenc hlq hnrLo
    (fun r hr => Nat.blt_eq.mp (List.all_eq_true.mp F.znrHi r hr)) hder (hEs x.ν hmap) hmap hsub
  have hval1 : VBOkF loopVB (Shift.valuation θ ν1) := hval.1
  have hval2 : MapOk (Shift.valuation θ ν1) i m := hval.2
  let y : SegInst FF := ⟨N.withJs, Shift.valuation θ ν1, K', t', C'⟩
  have node : y.M.node 15235 = M'.node 15235 := by
    change M'.node (κ.node 15235) = M'.node 15235
    rw [Conv.node_of_fixOld F.cfix (le_refl c.nn) 15235 F.inputOld]
  have aold : ∀ a, a < sa.next → y.M.a a = M'.a a := by
    intro a ha
    change M'.a (κ.a a) = M'.a a
    have he : κ.a a = a := by
      rw [F.zkap]
      exact Conv.Map.compact_lt ha
    rw [he]
  have hfrlt : ∀ a, a ∈ [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view] → a < sa.next :=
    fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp F.zfrlt a ha)
  have hsaBig : 2590 < sa.next ∧ 2586 < sa.next ∧ 2589 < sa.next := by
    have := hfrlt 2665 (by simp)
    omega
  have book : BodyBook i π K0 y O'.D := by
    refine ⟨hb.length, hb.vocab, hval1, hctx, hb.incoming, hb.incomingPrompt, hb.incomingMemo,
      hfr.trans hb.frames, ?_, hb.lo, hb.hi, ?_⟩
    · change t'.next - sc.next ≤ O'.D
      rw [hD]
      omega
    · obtain ⟨asR, ret, pre, tr, hev⟩ := hb.inputEvent
      obtain ⟨fresh, _, ht⟩ := hm'.trace
      refine ⟨asR, ret, fresh.map M'.event ++ pre, tr, ?_⟩
      change t'.trace = _
      rw [aold VWFrames.buffer (hfrlt _ (by simp)), hext.a, ht, hev, List.append_assoc]
  have hlowv : ∀ j, j < 9 → Shift.valuation θ ν1 j = x.ν j := by
    intro j hj
    have hlow : ∀ v, v ∈ cws ++ ws → 9 ≤ v := fun v hv => Nat.le_of_ble_eq_true (List.all_eq_true.mp F.lowVars v hv)
    have hc0 : Conv.idx? j cws = none := Conv.idx?_none (fun hm => by
      have := hlow j (List.mem_append_left _ hm); omega)
    have hw0 : ws.contains j = false := Bool.eq_false_iff.mpr fun hc => by
      have := hlow j (List.mem_append_right _ (List.contains_iff_mem.mp hc)); omega
    rw [Conv.valuation_compactθZ_out hc0 hw0]
    exact Conv.resVal_off (fun hm => by
      have hc := List.contains_iff_mem.mpr hm
      rw [hw0] at hc
      cases hc)
  have inputs : setupInputs T tk y := by
    constructor
    · intro j hj
      change Shift.valuation θ ν1 j = _
      rw [hlowv j hj]
      exact hins.1 j hj
    · change y.M.a 2590 = 2590
      rw [aold 2590 hsaBig.1, hext.a]
      exact hins.2
  have ids : fixedCells y := by
    change y.M.a 2586 = 2586 ∧ y.M.a 2589 = 2589
    rw [aold 2586 hsaBig.2.1, aold 2589 hsaBig.2.2, hext.a]
    exact hids
  have hia : (bridgeOf sa.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) (F.sbridge.symm.trans F.cbridge)).trans F.zbin
  have fresh : AneFresh t' := bodyFresh hr hm' hia F.sbridge hfresh
  refine ⟨t', C', hrun, y, rfl, rfl, ⟨K0, hcW, book, hnatC, ?_, inputs, hval2⟩, fresh, ids⟩
  rw [node]
  exact ip

end Host.Ts.Sim.Compose.VWFirst

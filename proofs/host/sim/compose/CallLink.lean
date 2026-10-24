import host.sim.compose.ChainFill
import host.sim.conv.CallPieces
import host.sim.conv.CompactShift
import host.sim.conv.Decanon
import host.sim.conv.SiteMerge
import host.sim.template.Stage
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Full Host.Load.Layers
  Host.Ts.Sim.Template

/-! # A decode chain's call as a decode link

A call of a decode chain (`tpl_chain`'s stage at boundary `a`: the call state `s<a>`, the merged state
`s<a+1>`, the canonical state `s<a+2>`) is a `DLink` between the chain's cuts (`bdCut`,
`host.sim.compose.ChainFill`, the decode world with the target's bridge pinned to `b0`):

* `cut_siteMerge`: the site instance's run and merge (`Conv.site_merge`) as a cut step into the merged
  cut, the stage's entries past the call's table bound to fresh variables `ws` (`RelB.resMerge`: the
  merged table `tab ++ resTab ws` at the valuation `resVal ν ws (resF SymE.var S2 n0 ν)`);
* `callLink`: that step, under the chain's simulation at the instance's acceptance (`decSimAt`,
  `Disp.StepSimXLB.mono`) and the ghost across the merge (`IterGhostCW.merge`), then the compaction
  (`cut_compactQ`) at the substitution `Conv.compactθZ cws crs ws` (`ShiftD.retheta` from the state
  shift at `Conv.compactθ`), the canonical pair's run predicate by `Conv.post_call_valQ` (each result at its own
  quantity), the target's room from the iteration's budget in the cuts (`Bud`, `CutStep.withP`) and the counters
  at the merged state (`IterGhostCW.counters`);
* `glueLinkEndD`: the last glue piece into the iteration's end at the end table with the canonical results back to
  their terms (A3's `RelB.decanon`: each result a decode form of `u`, `Conv.decanon_dec`; `decQ_hvs` from a
  check of the forms against the link's map). `qs_le`: the results' quantities (offset, end position) within the
  bound at an admitted step. -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame}

/-- The relation at another server of the same table length whose numbers the target serves. -/
theorem _root_.Host.Ts.Sim.RelB.retab {M : Map} {ν ν' : Nat → F64} {K : Ctx} {s t : St F.S} {S S' : SSrv}
    {C : CSrv} (h : RelB F FR W stk M ν K s S t C) (hl : S'.tab.length = S.tab.length) (hs : Srv M ν' S' C) :
    RelB F FR W stk M ν' K s S' t C :=
  { h with
    srv := hs
    ffi := hl ▸ h.ffi
    heapSupp := hl ▸ h.heapSupp
    ctlSupp := hl ▸ h.ctlSupp
    stackSupp := hl ▸ h.stackSupp
    jobsSupp := hl ▸ h.jobsSupp
    storesSupp := hl ▸ h.storesSupp
    traceSupp := hl ▸ h.traceSupp }

/-- **The merged relation with the stage's results as fresh variables**: from the call's numbers (`hx`, the
call's table `tab`), the map's extension and the server's growth, the stage's end relation at the instance's
end server `S2` is the relation at the merged table `tab ++ resTab ws`, the valuation binding `ws` to the
stage's entries past `tab` (`resVal`, `resF`). -/
theorem _root_.Host.Ts.Sim.RelB.resMerge {M M' : Map} {ν : Nat → F64} {K : Ctx} {sm t' : St F.S}
    {tab : List SymE} {o : List Ans} {S2 : SSrv} {C C' : CSrv} {ws : List Nat}
    (hx : NumOK M ν ⟨tab, o⟩ C) (he : Ext M M' tab.length) (hle : CSrv.Le C C')
    (h2 : RelB F FR W stk M' ν K sm S2 t' C') (hpre : tab.length ≤ S2.tab.length)
    (hwsl : ws.length = S2.tab.length - tab.length) (hnd : ws.Nodup)
    (hfresh : ∀ e ∈ tab, ∀ w ∈ ws, e.noVar w = true) :
    RelB F FR W stk M' (Conv.resVal ν ws (Conv.resF SymE.var S2.tab tab.length ν)) K sm
      ⟨tab ++ Conv.resTab ws, []⟩ t' C' := by
  have hl : (tab ++ Conv.resTab ws).length = S2.tab.length := by
    rw [List.length_append, Conv.resTab_length]; omega
  refine h2.retab (S' := ⟨tab ++ Conv.resTab ws, []⟩) hl ⟨fun i e hie => ?_, fun q hq => nomatch hq⟩
  by_cases hi : i < tab.length
  · have hie' : nth? tab i = some e := by rw [← nth?_append_lt tab (Conv.resTab ws) i hi]; exact hie
    rw [he.num i hi, Conv.eval_resVal (hfresh e (nth?_mem_some hie'))]
    exact hle.val (hx i e hie')
  · obtain ⟨j, rfl⟩ : ∃ j, i = tab.length + j := ⟨i - tab.length, by omega⟩
    have hie2 : nth? (Conv.resTab ws) j = some e := by rw [← Conv.nth?_append_len tab]; exact hie
    obtain ⟨e2, he2, hev⟩ := Conv.res_hes hnd hwsl SymE.var ν j e hie2
    rw [hev]
    exact h2.srv.num _ e2 he2

/-- **A site instance's run and merge as a cut step** (`Conv.site_merge`, `RelB.resMerge`): the caller's
cut at the call state `sa` into the merged cut at `sm` (the instance's merged state, `hmer`) with the merged
table `tab ++ resTab ws`; the caller's predicate and bookkeeping after the merge by `hQ`, which sees the
caller pair, its relation at the instance's start server, the map's extension, the run and the merged relation. -/
theorem cut_siteMerge {ok : St F.S → SSrv → Bool} {Kp : Ctx → Prop} {VBOk : (Nat → F64) → Prop}
    (T : Stage.StageTpl F ok) {sa sm : St F.S} {tab : List SymE} {wr ws : List Nat}
    {Q B Q' B' : SegInst F → Prop}
    (hs0 : T.s0 = { sa with stack := [] }) (htab : T.S0.tab = tab)
    (hsim : ∀ r, Disp.StepSimXLB F FR ok Kp W r VBOk) (hloc : ∀ s S, ok s S = true → Disp.localB s = true)
    (hfoot : Conv.StageFoot wr T.s0 T.s2) (hnd : wr.Nodup) (hbd : ∀ b ∈ wr, b / 4096 < 4 ^ 31)
    (htr : ∃ fr, T.s2.trace = fr ++ T.s0.trace)
    (hmer : sm = Conv.mergeSt Map.id (Map.id.res tab.length tab.length) sa.stack wr sa T.s2 T.s0 T.s2.ffi)
    (hwsl : ws.length = T.S2.tab.length - tab.length) (hwsnd : ws.Nodup)
    (hfresh : ∀ e ∈ tab, ∀ w ∈ ws, e.noVar w = true)
    (hKν : ∀ c, Q c → B c → Kp c.K ∧ VBOk c.ν) (hg : ∀ c, Q c → B c → Good c.ν T.S0.oracle)
    (hQ : ∀ (c : SegInst F) (M' : Map) (t' : St F.S) (C' : CSrv), Q c → B c →
      RelB F FR W [] c.M c.ν c.K sa T.S0 c.t c.C → Ext c.M M' tab.length →
      runC F (T.n + 1) c.t c.C = some (t', C') →
      RelB F FR W [] M' (Conv.resVal c.ν ws (Conv.resF SymE.var T.S2.tab tab.length c.ν)) c.K sm
        ⟨tab ++ Conv.resTab ws, []⟩ t' C' →
      Q' ⟨M', Conv.resVal c.ν ws (Conv.resF SymE.var T.S2.tab tab.length c.ν), c.K, t', C'⟩ ∧
        B' ⟨M', Conv.resVal c.ν ws (Conv.resF SymE.var T.S2.tab tab.length c.ν), c.K, t', C'⟩) :
    CutStep ((Cut.mk sa tab (Conv.relB F FR W [] Q)).with B)
      ((Cut.mk sm (tab ++ Conv.resTab ws) (Conv.relB F FR W [] Q')).with B') (T.n + 1) := by
  rintro t C ⟨c, rfl, rfl, ⟨hc, hq⟩, hb⟩
  obtain ⟨hK, hν⟩ := hKν c hq hb
  have h0 : RelB F FR W [] c.M c.ν c.K sa T.S0 c.t c.C := by
    have := hc.withOracle (hg c hq hb)
    rw [← htab] at this
    exact this
  obtain ⟨M', t', C', hrun, he, h2⟩ := Conv.site_merge T hs0 rfl hsim hloc hK hν hfoot hnd hbd htr tab.length h0
  rw [htab] at he
  rw [← hmer] at h2
  have hm := h2.resMerge (tab := tab) hc.srv.num he (runC_le _ _ _ _ _ hrun) (htab ▸ T.len2) hwsl hwsnd
    hfresh
  obtain ⟨hq', hb'⟩ := hQ c M' t' C' hq hb h0 he hrun hm
  exact ⟨t', C', hrun, ⟨M', Conv.resVal c.ν ws (Conv.resF SymE.var T.S2.tab tab.length c.ν), c.K, t', C'⟩, rfl, rfl,
    ⟨hm, hq'⟩, hb'⟩

end

/-- A cut step under a fact `P` of the start pair's bookkeeping that the step keeps. -/
theorem CutStep.withP {F : Ffi} {c d : Cut F} {B B' : SegInst F → Prop} {P : Prop} {n : Nat}
    (h : P → CutStep (c.with B) (d.with B') n) :
    CutStep (c.with fun x => B x ∧ P) (d.with fun x => B' x ∧ P) n := by
  rintro t C ⟨x, ht, hC, hR, hB, hp⟩
  obtain ⟨t', C', hr, x', ht', hC', hR', hB'⟩ := h hp t C ⟨x, ht, hC, hR, hB⟩
  exact ⟨t', C', hr, x', ht', hC', hR', hB', hp⟩

/-- **The target's mlx counters at a pair with the ghost**, at a state `sm` the world's relation relates: past the
ghost's fresh handles and nodes by at most the absorbed growth (`IterGhostCW.compact`'s `H`, `N`). -/
theorem IterGhostCW.counters {Wd : World} {A : Addr} {P : Wd.Par} {Fr : LoopFramesA A} {s0 : St Wd.F.S}
    {tab0 : List SymE} {fixA : List Nat} {θ : Nat → SymE} {g : GhostP} {x0 x : SegInst Wd.F}
    (hE : Wd.EndLaws) (h : IterGhostCW Wd A P Fr s0 tab0 fixA θ g x0 x) {sm : St Wd.F.S} {r : List NumV}
    {n : Nat} (hm : Wd.R P r x.M n sm.ffi x.t.ffi) (hH : g.vH ≤ (Wd.toMlx sm.ffi).next)
    (hHE : (Wd.toMlx sm.ffi).next < Wd.E P) (hN : g.vN ≤ (Wd.toMlx sm.ffi).nnext) :
    (Wd.toMlx x.t.ffi).next + g.vH ≤ (Wd.toMlx x0.t.ffi).next + g.dH + (Wd.toMlx sm.ffi).next ∧
      (Wd.toMlx x.t.ffi).nnext + g.vN ≤ (Wd.toMlx x0.t.ffi).nnext + g.dN + (Wd.toMlx sm.ffi).nnext := by
  obtain ⟨tH, hle, hb⟩ := h.H
  have e1 := hE.bigFresh hm 0 (by omega)
  have e2 := hb ((Wd.toMlx sm.ffi).next - g.vH) (by omega)
  rw [show g.vH + ((Wd.toMlx sm.ffi).next - g.vH) = (Wd.toMlx sm.ffi).next + 0 by omega, e1] at e2
  have e3 := Int.ofNat.inj e2
  obtain ⟨tN, hleN, hbN⟩ := h.N
  have f2 := hbN ((Wd.toMlx sm.ffi).nnext - g.vN)
  rw [show g.vN + ((Wd.toMlx sm.ffi).nnext - g.vN) = (Wd.toMlx sm.ffi).nnext + 0 by omega, hE.nodeFresh hm 0] at f2
  constructor <;> omega

/-- The frames after a compaction (`Shift.framedNext`) have the frames' domain. -/
theorem framedNext_ne_none {F : Ffi} (M : Map) (K : Ctx) (s : St F.S) (a : Nat) :
    Shift.framedNext M K s a ≠ none ↔ K.fr a ≠ none := by
  unfold Shift.framedNext
  cases K.fr a with
  | none => simp
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    simp only [ne_eq, reduceCtorEq, not_false_eq_true, iff_true]
    split
    · split <;> simp
    · simp

/-- `Conv.compactθZ` keeps the variables off the results and the stage's fresh variables. -/
theorem compactθZ_off {ws zs : List Nat} {rs : List SymE} {v : Nat} (hv : ¬ (v ∈ ws ∨ v ∈ zs)) :
    Conv.compactθZ ws rs zs v = .var v := by
  have h1 : Conv.idx? v ws = none := Conv.idx?_none fun h => hv (.inl h)
  have h2 : zs.contains v = false := by
    cases hc : zs.contains v with
    | false => rfl
    | true => exact absurd (.inr (List.contains_iff_mem.mp hc)) hv
  simp only [Conv.compactθZ, h1, h2, Bool.cond_false]

/-- The band past a canonical counter at or above the band's low end is not a fixed bigint's. -/
theorem band_of {lo hi n E : Nat} (hn : lo ≤ n) (hE : E ≤ hi) (hE' : E ≤ 72057594037927936) :
    ∀ i : Int, (n : Int) ≤ i ∧ i < E → ¬ BigFixed lo hi i ∧ 0 ≤ i ∧ i < 2 ^ 56 := by
  have h56 : ((2 : Int) ^ 56) = 72057594037927936 := by decide
  rintro i ⟨h1, h2⟩
  unfold BigFixed
  rw [h56]
  omega

section
variable (b0 : BSt) (NB : Nat) (Pw : LoadP) (fr : List Nat) (wd : List (Nat × WFrame)) (W : Nat → Option WFrame)

/-- **The pinned decode world's simulation at a decode chain's acceptance under any stack base.** -/
theorem decSimAt (hW : Disp.Wp (decJ Pw fr wd) W) (r : List NumV) (stk : List Frame) :
    Disp.StepSimXLB FF (FLRb b0 Pw NB r) (decOk Pw fr wd) (Disp.Kp (decJ Pw fr wd)) W stk (VBOkF loopVB) :=
  fullStepSimXLBKFb { Pw with rest := r } NB loopVB (decJ Pw fr wd) (okCallFS_rest Pw r).symm rfl rfl rfl rfl b0 stk hW

end

section
variable {b0 : BSt} {NB : Nat} {Pw : LoadP} {fr : List Nat} {wd : List (Nat × WFrame)} {W : Nat → Option WFrame} {A : Addr}
  {Fr : LoopFramesA A} {s0 : St FF.S} {tab0 : List SymE} {fixA : List Nat} {toks : List NumV}
  {L T : Nat} {tk : Nat → Nat} {uses : List Row} {ΔJ ΔH ΔN : Nat}

/-- **A call as a decode link** (see the module doc): the instance `I` at the call state `sa` (its acceptance
`Template.okLocal` of the chain's), the merged state `sm` with the merged table `tabm`, the canonical state
`sc` under the compaction `κ`; the cuts' maps `R` (at the call) and `R'` (after it, within `R` and the results
`cws` at the quantity `q`); the link's own map `m` (its oracle `O`, the instance's) within `R`.

The facts, by source: the instance and the merge (`hs0` … `hfresh`); the ghost across the merge (`hlen`,
`hgtab`, `hgθ`) and the full world's mlx growth along the instance's run (`hgrow`); the compaction: the
canonical table (`hctab`), the state shift at `Conv.compactθ` (`hshift`) and the native one (`hffi`), the
canonical state's band (`hbig`, `hfree`, `hband`), the target's room (the chain's growth `dJ`, `dH`, `dN` within the
budget, the merged and canonical states' counters: `hdJ` … `hscN`), the map (`hκn`, `hκa`, `hκv`), the merged state's framed arrays (`hfwd`, `hemit`, `hkeep`, `heN`) and counters (`hJ` …
`hN`), the results apart from the stage's other variables (`hdis`); the post-call quantities (`hm0`
… `hq`, `Conv.post_call_valQ`: the results' entries `Es` in the instance's end table, `hEs` their values at their
quantities `qs`). -/
def callLink {m R R' : List (Nat × Q)} {qs : List Q} {θ : Nat → SymE} {g : GhostP} {sa sm sc : St FF.S} {Sa Sc : SSrv}
    {tabm : List SymE} {f eN : List Val}
    (I : Stage.StageTpl FF (Template.okLocal (decOk Pw fr wd))) {wr ws cws nr : List Nat} {κ : Map}
    {Es : List (Option SymE)}
    (O : List Ans) (hW : Disp.Wp (decJ Pw fr wd) W) (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true)
    (hO : I.S0.oracle = O) (hmR : ∀ p ∈ m, p ∈ R)
    -- the instance and the merge
    (hs0 : I.s0 = { sa with stack := [] }) (htab : I.S0.tab = Sa.tab) (hfoot : Conv.StageFoot wr I.s0 I.s2)
    (hnd : wr.Nodup) (hbd : ∀ b ∈ wr, b / 4096 < 4 ^ 31) (htr : ∃ fr, I.s2.trace = fr ++ I.s0.trace)
    (hmer : sm = Conv.mergeSt Map.id (Map.id.res Sa.tab.length Sa.tab.length) sa.stack wr sa I.s2 I.s0 I.s2.ffi)
    (hmtab : tabm = Sa.tab ++ Conv.resTab ws) (hwsl : ws.length = I.S2.tab.length - Sa.tab.length)
    (hwsnd : ws.Nodup) (hfresh : ∀ e ∈ Sa.tab, ∀ w ∈ ws, e.noVar w = true)
    -- the ghost across the merge
    (hlen : tab0.length ≤ Sa.tab.length)
    (hgtab : ∀ j e, nth? tab0 j = some e → ∀ w, (w ∈ cws ∨ w ∈ ws) → e.noVar w = true)
    (hgθ : ∀ j e, nth? tab0 j = some e → ∀ w, (w ∈ cws ∨ w ∈ ws) → w ≠ A.nxt → (e.subst θ).noVar w = true)
    (hgrow : ∀ (r : List NumV) (c : SegInst FF) (t' : St FF.S) (C' : CSrv), VBOkF loopVB c.ν →
      Disp.Kp (decJ Pw fr wd) c.K → RelB FF (FLRb b0 Pw NB r) W [] c.M c.ν c.K sa I.S0 c.t c.C →
      runC FF (I.n + 1) c.t c.C = some (t', C') → Host.Mlx.Ffi.NGrow (mlxOf c.t.ffi) (mlxOf t'.ffi))
    -- the compaction
    (hctab : Sc.tab = Sa.tab ++ cws.map SymE.var) (hdis : ∀ w ∈ cws, w ∉ ws)
    (hshift : ∀ x0 x : SegInst FF, Conv.CallFacts sa Sa.tab.length → Disp.Kp (decJ Pw fr wd) x.K → IterGhostCW (fullWorldFb b0 NB) A Pw Fr s0 tab0 fixA θ g x0 x →
      ShiftD FF (fun _ _ _ => True) κ (Conv.compactθ cws (nr.map fun r => (nth? tabm r).getD (.var 0)))
        (kpOf x.K W) W x.K sc ⟨Sc.tab, []⟩ sm ⟨tabm, []⟩)
    (hffi : Conv.FullShiftQ Pw Sc.tab.length κ sc.ffi sm.ffi)
    (hbig : bigsOutB (mlxOf sc.ffi).next Pw.E (mlxOf sc.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf sc.ffi).next : Int) ≤ i ∧ i < Pw.E) sc.trace sc)
    (hband : ∀ i : Int, ((mlxOf sc.ffi).next : Int) ≤ i ∧ i < Pw.E →
      ¬ BigFixed (decJ Pw fr wd).lo (decJ Pw fr wd).hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (dJ dH dN : Nat) (hdJ : dJ ≤ ΔJ) (hdH : dH ≤ ΔH) (hdN : dN ≤ ΔN)
    (hcJ : sm.next + s0.next + g.dJ ≤ dJ + g.vJ + sc.next)
    (hcH : g.dH + (mlxOf sm.ffi).next + (mlxOf s0.ffi).next ≤ dH + g.vH + (mlxOf sc.ffi).next)
    (hcN : g.dN + (mlxOf sm.ffi).nnext + (mlxOf s0.ffi).nnext ≤ dN + g.vN + (mlxOf sc.ffi).nnext)
    (hs0E : (mlxOf s0.ffi).next ≤ Pw.E) (hscE : (mlxOf sc.ffi).next ≤ Pw.E)
    (hs0N : (mlxOf s0.ffi).nnext ≤ Pw.NE) (hscN : (mlxOf sc.ffi).nnext ≤ Pw.NE)
    (hκn : ∀ j, j < tab0.length → κ.num j = .ref j) (hκa : ∀ a ∈ fixA, κ.a a = a)
    (hκv : ∀ j, j < (mlxOf s0.ffi).nnext → κ.node j = j)
    (hfwd : ∃ o, sm.heap.get A.fwd = some (.obj o) ∧ o.kind = .array (arrOf s0 A.fwd ++ f))
    (hemit : ∃ o, sm.heap.get A.emit = some (.obj o) ∧ o.kind = .array (arrOf s0 A.emit ++ eN))
    (hkeep : KeepsAtW Fr sm) (heN : NumRefs tab0.length eN)
    (hJ : g.vJ ≤ sm.next) (hJc : sc.next ≤ sm.next) (hH : g.vH ≤ (mlxOf sm.ffi).next)
    (hHE : (mlxOf sm.ffi).next < Pw.E) (hN : g.vN ≤ (mlxOf sm.ffi).nnext)
    -- the post-call quantities
    (hm0 : ∀ p ∈ R, Conv.idx? p.1 cws = none ∧ ws.contains p.1 = false) (hndc : cws.Nodup)
    (hlenc : cws.length = nr.length) (hnrLo : nr.all (Nat.ble Sa.tab.length) = true)
    (hder : nr.map (fun r => nth? I.S2.tab r) = Es)
    (hlq : qs.length = cws.length)
    (hEs : ∀ (i : Cls.Inst) (ν : Nat → F64), DecAt L T tk i → MapOk ν i R → VBOkF loopVB ν →
      ∀ j o, nth? Es j = some o → ∃ E q, o = some E ∧ nth? qs j = some q ∧ E.eval ν = F64.ofNat (i.get q))
    (hq : ∀ i, DecAt L T tk i → ∀ j c q, nth? cws j = some c → nth? qs j = some q → i.get q ≤ loopVB c)
    (hR' : ∀ p ∈ R', p ∈ R ++ cws.zip qs) :
    DLink (DecAt L T tk) uses m [] (bdCut b0 NB Pw fr wd W A Fr s0 tab0 fixA toks ΔJ ΔH ΔN θ g R sa Sa)
      (bdCut b0 NB Pw fr wd W A Fr s0 tab0 fixA toks ΔJ ΔH ΔN θ (GhostP.compact (fullWorldFb b0 NB) g sm sc eN) R' sc Sc) where
  n := I.n + 1
  O := O
  chk := hchk
  ok _ _ i _ hobl hadm x0 := CutStep.withP fun hbud => by
    -- the merged cut's predicate: the merged valuation of a call valuation in the bound at `R`, the context, the
    -- target's offset and counters at the merged state, the call state's facts (`Conv.CallFacts`, A3's `compact_shift`)
    let νr : (Nat → F64) → Nat → F64 := fun ν => Conv.resVal ν ws (Conv.resF SymE.var I.S2.tab Sa.tab.length ν)
    let Qm : SegInst FF → Prop := fun x =>
      ∃ ν, x.ν = νr ν ∧ VBOkF loopVB ν ∧ MapOk ν i R ∧ Disp.Kp (decJ Pw fr wd) x.K ∧ x.t.next = sm.next + x.K.D ∧
        (mlxOf x.t.ffi).next + g.vH ≤ (mlxOf x0.t.ffi).next + g.dH + (mlxOf sm.ffi).next ∧
        (mlxOf x.t.ffi).nnext + g.vN ≤ (mlxOf x0.t.ffi).nnext + g.dN + (mlxOf sm.ffi).nnext ∧ Conv.CallFacts sa Sa.tab.length
    let crs := nr.map fun r => (nth? tabm r).getD (.var 0)
    have hstep := cut_siteMerge (FR := FLRb b0 Pw NB (toks.drop i.k)) (W := W)
      (Q := DQ Pw fr wd R i) (B := IterGhostCW (fullWorldFb b0 NB) A Pw Fr s0 tab0 fixA θ g x0) (Q' := Qm)
      (B' := IterGhostCW (fullWorldFb b0 NB) A Pw Fr s0 tab0 fixA θ g x0) I hs0 htab
      (fun stk => (decSimAt b0 NB Pw fr wd W hW _ stk).mono fun s S h => by
        simp only [Template.okLocal, Bool.and_eq_true] at h; exact h.1)
      Template.okLocal_localB hfoot hnd hbd htr hmer hwsl hwsnd hfresh
      (fun c hq _ => ⟨hq.2.1, hq.1⟩) (fun c hq _ => by rw [hO]; exact hobl.1 c.ν (MapOk.sub hq.2.2 hmR))
      (fun c M' t' C' hq hb h0 he hrun hm => by
        have hb' := hb.merge (V := (· ∈ ws)) (M' := M') (t' := t') (C' := C') (he.mono hlen)
          (fun v hv => Conv.resVal_off (ν := c.ν) (ws := ws) (f := Conv.resF SymE.var I.S2.tab Sa.tab.length c.ν) hv)
          (fun j e hj w hw => hgtab j e hj w (.inr hw)) (fun j e hj w hw => hgθ j e hj w (.inr hw))
          (hgrow _ c t' C' hq.1 hq.2.1 h0 hrun)
        have hc := IterGhostCW.counters (fullWorldFb_end b0 NB) hb' hm.ffi hH hHE hN
        exact ⟨⟨c.ν, rfl, hq.1, hq.2.2, hq.2.1, hm.offset, hc.1, hc.2, htab ▸ Conv.CallFacts.of_rel h0⟩, hb'⟩)
    rw [← hmtab] at hstep
    refine hstep.convR (cut_compactQ b0 (V := fun v => v ∈ cws ∨ v ∈ ws) (θk := Conv.compactθZ cws crs ws)
      (Q := Qm) (Q' := DQ Pw fr wd R' i) (f := f) (eN := eN)
      (fun x hx hB => ?_) hbig hfree (fun x hx _ => ?_) (fun x hx hB => ?_) (fun x hx hB => ?_)
      hκn hκa hκv (fun v hv => compactθZ_off hv) hgtab hgθ hfwd hemit hkeep heN hJ hJc hH hHE hN
      (fun x hx _ => ?_))
    · -- the shift at the canonical substitution, the native shift
      obtain ⟨-, -, -, -, hK, -, -, -, hcf⟩ := hx
      have hs := (hshift x0 x hcf hK hB).retheta (θ' := Conv.compactθZ cws crs ws) (by
        rw [hctab]
        exact Conv.compactθZ_tab (fun e he z hz => hfresh e he z hz) hdis)
      exact { hs with ffi := ⟨rfl, hffi⟩ }
    · obtain ⟨-, -, -, -, ⟨hlo, hhi, -⟩, -⟩ := hx
      rw [hlo, hhi]
      exact hband
    · -- the target's room: the offset, the ghost's counters, the budget
      obtain ⟨-, -, -, -, -, hoff, -⟩ := hx
      have hD := hB.D
      have := hbud.1
      omega
    · obtain ⟨-, -, -, -, -, -, hxH, hxN, -⟩ := hx
      obtain ⟨-, hbH, hbN⟩ := hbud
      show (mlxOf x.t.ffi).next + (Pw.E - (mlxOf sc.ffi).next) < 2 ^ 46 ∧
        (mlxOf x.t.ffi).nnext + (Pw.NE - (mlxOf sc.ffi).nnext) < 2 ^ 62
      constructor <;> omega
    · -- the canonical pair's run predicate
      obtain ⟨ν, hxν, hVB, hmap, ⟨hlo, hhi, hfr⟩, -⟩ := hx
      have hp := Conv.post_call_valQ (VB := loopVB) (qs := qs) (S5 := tabm) (n0 := Sa.tab.length) hVB hmap hm0 hmtab
        rfl hwsl hwsnd hndc hlenc hlq hnrLo hder (hEs i ν hadm hmap hVB) (hq i hadm)
      refine ⟨?_, ⟨hlo, hhi, fun a => ?_⟩, ?_⟩
      · show ∀ v, ∃ k ≤ loopVB v, Shift.valuation (Conv.compactθZ cws crs ws) x.ν v = F64.ofNat k
        rw [hxν]; exact hp.1
      · show Shift.framedNext x.M x.K sm a ≠ none ↔ _
        rw [framedNext_ne_none]; exact hfr a
      · show MapOk (Shift.valuation (Conv.compactθZ cws crs ws) x.ν) i R'
        rw [hxν]; exact MapOk.sub hp.2 hR'

end

section
variable {b0 : BSt} {NB : Nat} {Pw : LoadP} {fr : List Nat} {wd : List (Nat × WFrame)} {W : Nat → Option WFrame} {A : Addr}
  {Fr : LoopFramesA A} {s0 : St FF.S} {tab0 : List SymE} {fixA : List Nat} {toks : List NumV}
  {L T : Nat} {tk : Nat → Nat} {uses : List Row} {ΔJ ΔH ΔN : Nat}

/-- `List.zip`'s entries. -/
theorem nth?_zip {α β : Type} : ∀ {xs : List α} {ys : List β} {j : Nat} {a : α} {b : β}, nth? xs j = some a →
    nth? ys j = some b → nth? (xs.zip ys) j = some (a, b)
  | [], _, _, _, _, ha, _ => by cases ha
  | _ :: _, [], _, _, _, _, hb => by cases hb
  | _ :: _, _ :: _, 0, _, _, ha, hb => by
    simp only [nth?, Option.some.injEq] at ha hb; subst ha; subst hb; rfl
  | _ :: xs, _ :: ys, j + 1, _, _, ha, hb => nth?_zip (xs := xs) (ys := ys) (j := j) ha hb

/-- The end results' forms from a check against the link's map: each `es` entry a decode form of `u` whose quantity
the map holds for its `vs` variable. -/
theorem decQ_hvs {u : Nat} {vs : List Nat} {es : List SymE} {m : List (Nat × Q)}
    (h : (vs.zip es).all (fun p => match Conv.decQ u p.2 with | some q => m.contains (p.1, q) | none => false) = true) :
    ∀ j v e, nth? vs j = some v → nth? es j = some e → ∃ q, Conv.decQ u e = some q ∧ (v, q) ∈ m := by
  intro j v e hv he
  have hm := List.all_eq_true.mp h (v, e) (nth?_mem_some (nth?_zip hv he))
  simp only at hm
  cases hq : Conv.decQ u e with
  | none => rw [hq] at hm; cases hm
  | some q => rw [hq] at hm; exact ⟨q, rfl, List.contains_iff_mem.mp hm⟩

/-- **The results' quantities are within the bound** at an admitted step, when each is the offset or the end
position. -/
theorem qs_le {L T : Nat} {tk : Nat → Nat} {qs : List Q} {cws : List Nat}
    (hqs : qs.all (fun q => decide (q = .o ∨ q = .e)) = true) :
    ∀ i, DecAt L T tk i → ∀ j c q, nth? cws j = some c → nth? qs j = some q → i.get q ≤ loopVB c := by
  intro i h j c q _ hq
  have hm := of_decide_eq_true (List.all_eq_true.mp hqs q (nth?_mem_some hq))
  exact DecAt.get_le h (hm.elim .inl fun he => .inr (.inl he))

/-- **The last glue piece into the iteration's end with the end table de-canonicalized** (see the module doc): the end
template's server is the glue's end server with the canonical results `vs` replaced by their terms `es`, each a
decode form of `u` (`Conv.decQ`) at the quantity the link's map holds it, `u` at the offset. -/
def glueLinkEndD {m : List (Nat × Q)} {e : IterEndW (fullWorldFb b0 NB) A Pw s0 tab0 fixA} {g : GhostP} {sa sb : St FF.S}
    {Sa Sb : SSrv} {n : Nat} (O : List Ans) (hW : Disp.Wp (decJ Pw fr wd) W)
    (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true) (hO : Sa.oracle = O)
    (hok : decOk Pw fr wd sa Sa = true)
    (hrun : runOk FF (decOk Pw fr wd) n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true) (vs : List Nat) (es : List SymE) (u : Nat) (he1 : e.s1 = sb)
    (hS1 : e.S1 = ⟨Sb.tab.map (·.subst (Conv.compactθ vs es)), Sb.oracle⟩)
    (hvs : ∀ j v e, nth? vs j = some v → nth? es j = some e → ∃ q, Conv.decQ u e = some q ∧ (v, q) ∈ m)
    (hu : (u, Q.o) ∈ m) (hlen : tab0.length ≤ Sa.tab.length)
    (hgrow : ∀ (r : List NumV) (c : SegInst FF) (t' : St FF.S) (C' : CSrv), VBOkF loopVB c.ν →
      Disp.Kp (decJ Pw fr wd) c.K → RelB FF (FLRb b0 Pw NB r) W [] c.M c.ν c.K sa Sa c.t c.C →
      runC FF n c.t c.C = some (t', C') → Host.Mlx.Ffi.NGrow (mlxOf c.t.ffi) (mlxOf t'.ffi)) :
    DLink (DecAt L T tk) uses m [] (bdCut b0 NB Pw fr wd W A Fr s0 tab0 fixA toks ΔJ ΔH ΔN e.θ g m sa Sa)
      (fun i x0 => iterEndCW (fullWorldFb b0 NB) A W Pw Fr s0 tab0 fixA toks e g i.k x0) where
  n := n
  O := O
  chk := hchk
  ok _ _ i _ hobl hadm x0 := cut_glue (decSim b0 NB Pw fr wd W hW _) hok hrun htop
    (fun _ hq _ => ⟨hq.2.1, hq.1⟩) (fun c hq _ => by rw [hO]; exact hobl.1 c.ν hq.2.2)
    (fun c _ t' _ hq hb hc he hr h2 => ⟨by
        show RelF FF (FLRb b0 Pw NB _) W _ _ _ e.s1 e.S1 _ _
        rw [he1, hS1]
        exact h2.decanon (Conv.decanon_dec hq.2.2 hu (DecAt.get_e hadm) (DecAt.o_succ_lt31 hadm) hvs),
      hb.1.conv (he.mono hlen) rfl (fun _ _ _ => rfl) (fun _ _ _ _ => rfl) (hgrow _ c t' _ hq.1 hq.2.1 hc hr)⟩)

end

end Host.Ts.Sim.Compose

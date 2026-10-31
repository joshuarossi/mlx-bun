import host.sim.compose.PreFill
import host.sim.compose.Pieces
import host.sim.compose.CallLink
import host.sim.full.BridgeJs

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

/-- A call's checked site data.  The caller and merged states retain their stacks;
only the site template is isolated. -/
structure PrefillSite (FR : Map → Nat → FF.S → FF.S → Prop)
    (Kp : Ctx → Prop) (W : Nat → Option WFrame) (ok : St FF.S → SSrv → Bool)
    (sa sm : St FF.S) (Sa : SSrv) (ws : List Nat) where
  tpl : Stage.StageTpl FF ok
  wr : List Nat
  start : tpl.s0 = { sa with stack := [] }
  tab : tpl.S0.tab = Sa.tab
  sim : ∀ stk, Disp.StepSimXLB FF FR ok Kp W stk (VBOkF loopVB)
  localOk : ∀ s S, ok s S = true → Disp.localB s = true
  foot : Conv.StageFoot wr tpl.s0 tpl.s2
  nodup : wr.Nodup
  bound : ∀ b ∈ wr, b / 4096 < 4 ^ 31
  trace : ∃ fr, tpl.s2.trace = fr ++ tpl.s0.trace
  merged : ∀ {M ν K S t C},
    RelB FF FR W [] M ν K
      (Conv.mergeSt Map.id (Map.id.res Sa.tab.length Sa.tab.length) sa.stack wr sa tpl.s2 tpl.s0 tpl.s2.ffi) S t C →
    RelB FF FR W [] M ν K sm S t C
  len : ws.length = tpl.S2.tab.length - Sa.tab.length
  freshNodup : ws.Nodup
  fresh : ∀ e ∈ Sa.tab, ∀ w ∈ ws, e.noVar w = true

/-- Run a checked site, retaining the exact result valuation for compaction.
The caller chooses the bookkeeping transported across this run. -/
theorem PrefillSite.step {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop}
    {W : Nat → Option WFrame} {ok : St FF.S → SSrv → Bool}
    {sa sm : St FF.S} {Sa : SSrv} {ws : List Nat}
    (d : PrefillSite FR Kp W ok sa sm Sa ws) {Q B Q' B' : SegInst FF → Prop}
    (hKν : ∀ x, Q x → B x → Kp x.K ∧ VBOkF loopVB x.ν)
    (hg : ∀ x, Q x → B x → Good x.ν d.tpl.S0.oracle)
    (hpost : ∀ (x : SegInst FF) (M : Map) (t : St FF.S) (C : CSrv), Q x → B x →
      RelB FF FR W [] x.M x.ν x.K sa d.tpl.S0 x.t x.C → Ext x.M M Sa.tab.length →
      runC FF (d.tpl.n + 1) x.t x.C = some (t, C) →
      RelB FF FR W [] M
        (Conv.resVal x.ν ws (Conv.resF SymE.var d.tpl.S2.tab Sa.tab.length x.ν)) x.K sm
        ⟨Sa.tab ++ Conv.resTab ws, []⟩ t C →
      Q' ⟨M, Conv.resVal x.ν ws (Conv.resF SymE.var d.tpl.S2.tab Sa.tab.length x.ν), x.K, t, C⟩ ∧
      B' ⟨M, Conv.resVal x.ν ws (Conv.resF SymE.var d.tpl.S2.tab Sa.tab.length x.ν), x.K, t, C⟩) :
    CutStep ((Cut.mk sa Sa.tab (Conv.relB FF FR W [] Q)).with B)
      ((Cut.mk sm (Sa.tab ++ Conv.resTab ws) (Conv.relB FF FR W [] Q')).with B') (d.tpl.n + 1) :=
  cut_siteMerge d.tpl d.start d.tab d.sim d.localOk d.foot d.nodup d.bound d.trace
    d.merged d.len d.freshNodup d.fresh hKν hg hpost

/-- Fill a stage field from the site's checked run and a canonical conversion.
All rows use this same site template and its own checked oracle. -/
def PrefillSite.stagePiece {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop}
    {W : Nat → Option WFrame} {ok : St FF.S → SSrv → Bool}
    {sa sm : St FF.S} {Sa : SSrv} {ws : List Nat}
    (d : PrefillSite FR Kp W ok sa sm Sa ws) {uses : List Row} (m : List (Nat × Q)) {obls : List Obl}
    {Q B Q' B' : Cls.Inst → SegInst FF → Prop} {Z : Cls.Inst → ICut FF}
    (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) d.tpl.S0.oracle = true)
    (hKν : ∀ r ∈ uses, ∀ i, InRow r i → ∀ x, Q i x → B i x → Kp x.K ∧ VBOkF loopVB x.ν)
    (hmap : ∀ r ∈ uses, ∀ i, InRow r i → ∀ x, Q i x → B i x → MapOk x.ν i m)
    (hpost : ∀ r ∈ uses, ∀ i, InRow r i → ∀ (x : SegInst FF) (M : Map) (t : St FF.S) (C : CSrv),
      Q i x → B i x → RelB FF FR W [] x.M x.ν x.K sa d.tpl.S0 x.t x.C → Ext x.M M Sa.tab.length →
      runC FF (d.tpl.n + 1) x.t x.C = some (t, C) →
      RelB FF FR W [] M
        (Conv.resVal x.ν ws (Conv.resF SymE.var d.tpl.S2.tab Sa.tab.length x.ν)) x.K sm
        ⟨Sa.tab ++ Conv.resTab ws, []⟩ t C →
      Q' i ⟨M, Conv.resVal x.ν ws (Conv.resF SymE.var d.tpl.S2.tab Sa.tab.length x.ν), x.K, t, C⟩ ∧
      B' i ⟨M, Conv.resVal x.ν ws (Conv.resF SymE.var d.tpl.S2.tab Sa.tab.length x.ν), x.K, t, C⟩)
    (hc : ∀ r ∈ uses, ∀ i, InRow r i → OblOk i (⟨m, d.tpl.S0.oracle⟩ :: obls) →
      CutConv ((Cut.mk sm (Sa.tab ++ Conv.resTab ws) (Conv.relB FF FR W [] (Q' i))).with (B' i)) (Z i)) :
    StagePiece FF uses obls
      (fun i => (Cut.mk sa Sa.tab (Conv.relB FF FR W [] (Q i))).with (B i)) Z where
  m := m
  n := d.tpl.n + 1
  O := d.tpl.S0.oracle
  chk := hchk
  ok r hr i hi ho := StageCall.intro (CutConv.refl _)
    (d.step (hKν r hr i hi) (fun x hq hb => ho.1 x.ν (hmap r hr i hi x hq hb)) (hpost r hr i hi))
    (hc r hr i hi ho)

/-- The canonical pair chosen by a prefill compaction. -/
def prefillCompactPair (P : LoadP) (κ : Map) (θ : Nat → SymE) (sm sc : St FF.S) (x : SegInst FF) : SegInst FF :=
  ⟨((x.M.after κ).rebig (mlxOf sc.ffi).next P.E (mlxOf x.t.ffi).next).withJs,
    Shift.valuation θ x.ν,
    ⟨Shift.framedNext x.M x.K sm, sc.trace, x.t.trace, x.t.next - sc.next, x.K.lo, x.K.hi⟩,
    x.t, x.C⟩

/-- Post-call quantities for prefill have no decode-specific restriction: each
result uses the quantity proved for its own table entry. -/
theorem post_callP {ν : Nat → F64} {i : Cls.Inst} {m m' : List (Nat × Q)}
    {qs : List Q} {tab S2 Sm : List SymE} {ws cws nr : List Nat} {n0 : Nat} {Es : List (Option SymE)}
    (hVB : VBOkF loopVB ν) (hm : MapOk ν i m)
    (hm0 : ∀ p ∈ m, Conv.idx? p.1 cws = none ∧ ws.contains p.1 = false)
    (hSm : Sm = tab ++ Conv.resTab ws) (hn0 : tab.length = n0)
    (hws : ws.length = S2.length - n0) (hnd : ws.Nodup)
    (hndc : cws.Nodup) (hlen : cws.length = nr.length) (hlq : qs.length = cws.length)
    (hnrLo : nr.all (Nat.ble n0) = true) (hder : nr.map (fun r => nth? S2 r) = Es)
    (hEs : ∀ j o, nth? Es j = some o → ∃ E q, o = some E ∧ nth? qs j = some q ∧
      E.eval ν = F64.ofNat (i.get q))
    (hq : ∀ j c q, nth? cws j = some c → nth? qs j = some q → i.get q ≤ loopVB c)
    (hsub : ∀ p ∈ m', p ∈ m ++ cws.zip qs) :
    let θ := Conv.compactθZ cws (nr.map fun r => (nth? Sm r).getD (.var 0)) ws
    let ν' := Conv.resVal ν ws (Conv.resF SymE.var S2 n0 ν)
    VBOkF loopVB (Shift.valuation θ ν') ∧ MapOk (Shift.valuation θ ν') i m' := by
  have h := Conv.post_call_valQ hVB hm hm0 hSm hn0 hws hnd hndc hlen hlq hnrLo hder hEs hq
  exact ⟨h.1, MapOk.sub h.2 hsub⟩

/-- Compaction at the raised band, including an active bridge and restoration
of JavaScript pointer integers.  No target step is consumed. -/
theorem cut_compactXD {P P0 : LoadP} {NB : Nat} {r : List NumV}
    {W : Nat → Option WFrame} {sm sc : St FF.S} {Sm Sc : SSrv}
    {κ : Map} {θ : Nat → SymE} {Q B : SegInst FF → Prop} {J : ICut FF}
    (hP : Raised P P0) (hNB : NB ≤ P0.NL)
    (hbig : bigsOutB (mlxOf sc.ffi).next P.E (mlxOf sc.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf sc.ffi).next : Int) ≤ i ∧ i < P.E) sc.trace sc)
    (hE : P.E ≤ 2 ^ 56)
    (hjsHeap : ∀ a, Present sc a → noBigAtP (jsShiftBadB κ) sc a = true)
    (hjsRoots : noBigRootsP (jsShiftBadB κ) sc.trace sc = true)
    (hjsNative : bigsOutB jsLoN jsHiN (mlxOf sc.ffi) = true)
    (hfacts : ∀ x, Q x → B x →
      RelB FF (Disp.FRJ (FullRXD { P with rest := r } NB)) W [] x.M x.ν x.K sm ⟨Sm.tab, []⟩ x.t x.C →
      ShiftD FF (fun σ a b => a = sc.ffi ∧ Conv.FullShiftQX P0 Sc.tab.length σ a b)
        κ θ (kpOf x.K W) W x.K sc ⟨Sc.tab, []⟩ sm ⟨Sm.tab, []⟩ ∧
      (∀ i : Int, ((mlxOf sc.ffi).next : Int) ≤ i ∧ i < P.E →
        ¬ BigFixed x.K.lo x.K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56) ∧
      x.t.next - sc.next < Sim.bound ∧
      NRoom P (Host.Load.Layers.toLoad sc.ffi) (Host.Load.Layers.toLoad x.t.ffi) ∧ x.K.lo ≤ 2 ^ 56)
    (hpost : ∀ x, Q x → B x →
      RelB FF (Disp.FRJ (FullRXD { P with rest := r } NB)) W []
        (prefillCompactPair P κ θ sm sc x).M (prefillCompactPair P κ θ sm sc x).ν (prefillCompactPair P κ θ sm sc x).K
        sc ⟨Sc.tab, []⟩ x.t x.C →
      J.R (prefillCompactPair P κ θ sm sc x) J.s0 ⟨J.tab0, []⟩ ∧ J.B (prefillCompactPair P κ θ sm sc x)) :
    CutConv ((Cut.mk sm Sm.tab
      (Conv.relB FF (Disp.FRJ (FullRXD { P with rest := r } NB)) W [] Q)).with B) J := by
  rintro x ⟨hr, hq⟩ hb
  obtain ⟨hs, hband, hroom, hroomN, hlo⟩ := hfacts x hq hb hr
  have hc := Conv.full_compactQXD NB (S0 := ⟨Sc.tab, []⟩) (S1 := ⟨Sm.tab, []⟩) hP hNB hr.ofJ hs hbig hfree hband
    (fun _ h => nomatch h) hroom hroomN
  have hj := hc.afterJsFullXDBlocks (M := x.M) (σ := κ) hr.ffi.2 rfl
    (fun _ hi => jsBig_rebig hE hi) hlo hjsHeap hjsRoots hjsNative
  obtain ⟨hR, hB⟩ := hpost x hq hb hj
  exact ⟨prefillCompactPair P κ θ sm sc x, rfl, rfl, hR, hB⟩

end Host.Ts.Sim.Compose

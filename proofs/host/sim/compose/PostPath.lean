import host.sim.compose.PostChain
import host.sim.compose.Seg
import host.sim.compose.ShortFix
import host.sim.world.Route
import host.sim.dispatch.BridgeSpread
import host.sim.template.a4pre_d1_post_one.Simulation
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Load.Run.Tpl Host.Load.Run.Prompt

/-! # POST's short paths: to the halted state, under the book

A short path's chain runs in the path's prefix, under `Disp.FRJ`, which a halting chain's plain relation does not give;
its cut is at the halted state and its halting chain has no steps. On the way the path's tail spreads the prompt and the
forwarded tokens into the cache's token array, so the last stretch runs at more frames (`endCut`). -/

/-- What the end of a short path needs of the book. -/
structure BookE (T : Nat) (tk : Nat → Nat) (cap : Nat) (extra : List Nat) (x : SegInst FF) : Prop where
  context : Disp.KpJ (PostOk.JF extra) cap x.K
  valuation : VBOkF loopVB x.ν
  rowValue : x.ν 10 = F64.ofNat 1
  reserved : ∀ j, j < 9 → x.ν j = machVal T tk j
  emittedAnchor : x.M.a 2590 = 2590

/-- The cut after the tail's spread. -/
noncomputable def endCut (NB T : Nat) (tk : Nat → Nat) (cap : Nat) (extra : List Nat) (s : St FF.S) (S : SSrv) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S => RelB FF (Disp.FRJ (FullRXD (PostSimulation.params T tk) NB)) wideP [] x.M x.ν x.K s S x.t x.C ∧
    BookE T tk cap extra x
  B := fun x => AneFresh x.t ∧ Anchors x

/-- A framed array more. -/
theorem kpFrame {J J' : Disp.JSP FF} {K : Ctx} {a cap : Nat} (hlo : J'.lo = J.lo) (hhi : J'.hi = J.hi)
    (hfs : J'.framed = J.framed ++ [a]) (h : Disp.KpJ J cap K) (p : List Val × List Val) :
    Disp.KpJ J' cap (Disp.Ctx.frameAt K a p) := by
  refine ⟨⟨h.1.1.trans hlo.symm, h.1.2.1.trans hhi.symm, fun b => ?_⟩, h.2⟩
  rw [hfs]
  change (bif Nat.beq b a then some p else K.fr b) ≠ none ↔ _
  by_cases hb : b = a
  · subst hb; simp
  · rw [Template.beq_false hb, Bool.cond_false, h.1.2.2]
    simp [hb]

section
variable {NB T cap nI : Nat} {tk : Nat → Nat} {π : List Nat}

/-- A stretch and the step into a bridged call that pops the readback: the bookkeeping changes by `hook`. -/
theorem popCallM (m : Mode NB T tk cap) {ok : St FF.S → SSrv → Bool} {n : Nat} {sa sb sc : St FF.S} {Sa Sb Sc : SSrv}
    {Mem Mem' : SegInst FF → Prop}
    (ha : ok sa Sa = true) (hrun : runOk FF ok n sa Sa = some (sb, Sb)) (hb' : ok sb Sb = true)
    (hh : isHalt sb.ctl = false) (hs : interpS (step FF sb).run Sb = some (sc, Sc)) (htop : noRetBlock sc = true)
    (hgood : ∀ ν, BookV T tk π.length ν → Good ν Sa.oracle)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sc.ffi = bridgeOf sa.ffi)
    (hook : ∀ x y : SegInst FF, (indexedCut NB T tk cap nI π sa Sa).R x sa ⟨Sa.tab, []⟩ →
      (indexedCut NB T tk cap nI π sc Sc).R y sc ⟨Sc.tab, []⟩ → CSrv.Le x.C y.C → y.M.node = x.M.node →
      y.M.a 12504 = x.M.a 12504 → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → Mem x → Mem' y)
    (hm : m.okS = ok) :
    CutStep (withMem Mem (indexedCut NB T tk cap nI π sa Sa)) (withMem Mem' (indexedCut NB T tk cap nI π sc Sc)) (n + 1) := by
  subst hm
  rintro t C ⟨x, rfl, rfl, ⟨γ, hr, hb⟩, ⟨hf, hanc⟩, htr⟩
  obtain ⟨M', t', C', hrun', he, hout, ng⟩ := stretchCall m ha hrun hb' hh hs htop hgood hr hb
  have hb2 := hb.grow he ng (runC_le _ _ _ _ _ hrun')
  exact ⟨t', C', hrun', ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl, ⟨γ, hout, hb2⟩,
    ⟨fresh_of hr hout hi hbr hf, ⟨(congrFun he.a 2586).trans hanc.1, (congrFun he.a 2589).trans hanc.2⟩⟩,
    hook x ⟨M', x.ν, x.K, t', C'⟩ ⟨γ, hr, hb⟩ ⟨γ, hout, hb2⟩ (runC_le _ _ _ _ _ hrun') he.node (congrFun he.a 12504) ng htr⟩

/-- **The tail's spread**: the prompt and a forwarded array into the new token array, three steps, two more frames. -/
theorem spreadM {sO sI sC sA : St FF.S} {SO SI SC SA : SSrv} {env : Env} {fs : List Frame} {e : Expr} {name : Name}
    {cell fwd : Nat} {o : Obj} {xs : List Val} {Tr : SegInst FF → Prop}
    (hctl : sO.ctl = .ret (.obj 2665)) (hst : sO.stack = .l (.spread [] [.spread e] env) :: fs)
    (hOpen : interpS (step FF sO).run SO = some (sI, SI))
    (hIdCtl : sI.ctl = .ev (.id name) env) (hLook : lookupEnv name env = some cell)
    (hCell : sI.cell? cell = some (some (.obj fwd))) (hCellW : wideP cell = none)
    (hIdStep : interpS (step FF sI).run SI = some (sC, SC))
    (hCloseCtl : sC.ctl = .ret (.obj fwd)) (hCloseSt : sC.stack = .l (.spread [] [] env) :: fs)
    (hFwd : sC.obj? fwd = some o) (hFwdK : o.kind = .array xs)
    (hFwdNe : [2665].contains fwd = false) (hFwdW : wideP fwd = none)
    (hCloseStep : interpS (step FF sC).run SC = some (sA, SA))
    (hRoom : Nat.blt (sC.next + margin) Sim.bound = true) (hProto : Present sC aArrayProto)
    (hNewW : wideP sC.next = none)
    (hOr : SO.oracle = []) (hOrA : SA.oracle = [])
    (hi : (bridgeOf sO.ffi).active = false) (hbr : bridgeOf sA.ffi = bridgeOf sO.ffi)
    (hcnt : countersOkB sO sA = true) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π sO SO))
      (withMem Tr (endCut NB T tk cap [fwd, sC.next] sA SA)) 3 := by
  rintro t C ⟨x, rfl, rfl, ⟨γ, hr, hb⟩, ⟨hf, hanc⟩, htr⟩
  have hr0 : RelB FF (Disp.FRJ (FullRXD (PostSimulation.params T tk) NB)) wideP [] x.M x.ν x.K sO SO x.t x.C :=
    hr.withOracle (by rw [hOr]; intro _ h; nomatch h)
  have hq := (relB_withQ hr0.ofJ (Q := fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))
    (Host.Mlx.Ffi.NGrow.refl (mlxOf x.t.ffi))).toJ hr0.ffi.2
  have hpw : wideP 2665 = none := rfl
  obtain ⟨M1, t1, C1, ht1, gg1, hr1⟩ :=
    (Disp.step_spread_open hq hctl hst hb.prompt hpw).run sI SI hOpen
  have hh0 : isHalt x.t.ctl = false := by rw [hq.ctl, hctl]; rfl
  have run1 := runC_one hh0 ht1
  have hnCell : NoW x.K wideP sI cell := .inl hCellW
  obtain ⟨M2, t2, C2, ht2, gg2, hr2⟩ :=
    (Disp.step_id_spread hr1 hIdCtl hLook hCell hnCell).run sC SC hIdStep
  have hh1 : isHalt t1.ctl = false := by
    have hc := hr1.1.ctl
    change t1.ctl = _ at hc
    rw [hc, hIdCtl]; rfl
  have run2 := runC_trans run1 (runC_one hh1 ht2)
  have hfr : x.K.fr fwd = none := by
    cases hk : x.K.fr fwd with
    | none => rfl
    | some p =>
      have hm := (hb.context.1.2.2 fwd).mp (by rw [hk]; exact Option.some_ne_none _)
      have hc : [2665].contains fwd = true := List.contains_iff_mem.mpr hm
      rw [hFwdNe] at hc
      cases hc
  let Kf := Disp.Ctx.frameAt x.K fwd ([], [])
  have hr2f : RelSp FF (Disp.FRJ (FRQ (FullRXD (PostSimulation.params T tk) NB) fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))) wideP [] M2 x.ν Kf (some ([], (π.map natV).reverse)) sC SC t2 C2 :=
    ⟨D1PostOneSim.frameEmpty hr2.1 hFwd hFwdK hfr hFwdW, hr2.2⟩
  have hfk : Kf.fr fwd = some ([], []) := by simp [Kf, Disp.Ctx.frameAt]
  obtain ⟨M3, t3, C3, ht3, gg3, hrel3, hffi3⟩ :=
    (Disp.step_spread_close (A := []) hr2f hCloseCtl hCloseSt hfk (Nat.blt_eq.mp hRoom) hProto hFwdW hNewW).run
      sA SA hCloseStep
  let K2 := Disp.Ctx.frameAt Kf sC.next ([], π.map natV)
  have hr3 : RelB FF (Disp.FRJ (FRQ (FullRXD (PostSimulation.params T tk) NB) fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))) wideP [] M3 x.ν K2 sA SA t3 C3 := by
    simpa only [K2, List.reverse_nil, List.nil_append, List.append_nil, List.reverse_reverse, Map.vals, List.map_nil] using hrel3
  have hh2 : isHalt t2.ctl = false := by
    have hc := hr2.1.ctl
    change t2.ctl = _ at hc
    rw [hc, hCloseCtl]; rfl
  have run3 := runC_trans run2 (runC_one hh2 ht3)
  have hlen1 := interpS_len _ _ _ _ hOpen
  have hlen2 := interpS_len _ _ _ _ hIdStep
  have hext := (gg1.ext.trans gg2.ext hlen1).trans gg3.ext (hlen1.trans hlen2)
  have hkf : Disp.KpJ (PostOk.JF [fwd]) cap Kf :=
    kpFrame (J := PostOk.J) (J' := PostOk.JF [fwd]) (a := fwd) rfl rfl rfl hb.context ([], [])
  have hk2 : Disp.KpJ (PostOk.JF [fwd, sC.next]) cap K2 :=
    kpFrame (J := PostOk.JF [fwd]) (J' := PostOk.JF [fwd, sC.next]) (a := sC.next) rfl rfl rfl hkf ([], π.map natV)
  have hout : RelB FF (Disp.FRJ (FullRXD (PostSimulation.params T tk) NB)) wideP [] M3 x.ν K2 sA SA t3 C3 :=
    { hr3 with ffi := ⟨hr3.ffi.1.1, hr3.ffi.2⟩ }
  have ng : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf t3.ffi) := hr3.ffi.1.2
  refine ⟨t3, C3, run3, ⟨M3, x.ν, K2, t3, C3⟩, rfl, rfl,
    ⟨hout.withOracle (by rw [hOrA]; intro _ h; nomatch h),
      ⟨hk2, hb.valuation, hb.rowValue, hb.reserved, (congrFun hext.a 2590).trans hb.emittedAnchor⟩⟩,
    ⟨fresh_of hr hout hi hbr hf, ⟨(congrFun hext.a 2586).trans hanc.1, (congrFun hext.a 2589).trans hanc.2⟩⟩,
    hT x _ ⟨runC_le _ _ _ _ _ run3, hext.node, ng, tokens_of_grow hr hout ng (countersOkB_tokens hcnt),
      congrFun hext.a 12504⟩ htr⟩

/-- The stretch after the spread. -/
theorem glueE {extra : List Nat} {n : Nat} {sa sb : St FF.S} {Sa Sb : SSrv} {Tr : SegInst FF → Prop}
    (hcap : cap ≤ 4096 + 1593835520)
    (ha : PostOk.okF extra sa Sa = true) (hrun : runOk FF (PostOk.okF extra) n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true) (hOr : Sa.oracle = [])
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hcnt : countersOkB sa sb = true) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (endCut NB T tk cap extra sa Sa)) (withMem Tr (endCut NB T tk cap extra sb Sb)) n := by
  rintro t C ⟨x, rfl, rfl, ⟨hr, hb⟩, ⟨hf, hanc⟩, htr⟩
  have hq : RelB FF (Disp.FRJ (FRQ (FullRXD (PostSimulation.params T tk) NB)
      fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))) wideP [] x.M x.ν x.K sa ⟨Sa.tab, []⟩ x.t x.C :=
    { hr with ffi := ⟨⟨hr.ffi.1, Host.Mlx.Ffi.NGrow.refl _⟩, hr.ffi.2⟩ }
  obtain ⟨M', t', C', hrun', he, hrel⟩ := D1Advance.run
    (PostSimulation.simulationFQ NB T tk extra jsSignedLimit cap (Nat.le_refl _) [] (mlxOf x.t.ffi)) hb.context
    ⟨hb.valuation, hb.rowValue⟩ (by rw [hOr]; intro _ h; nomatch h) (PostSimulation.acceptedF_signed hcap ha)
    (PostSimulation.runF_signed hcap hrun) htop hq
  have hout : RelB FF (Disp.FRJ (FullRXD (PostSimulation.params T tk) NB)) wideP [] M' x.ν x.K sb ⟨Sb.tab, []⟩ t' C' :=
    { hrel with ffi := ⟨hrel.ffi.1.1, hrel.ffi.2⟩ }
  have ng : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf t'.ffi) := hrel.ffi.1.2
  exact ⟨t', C', hrun', ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl,
    ⟨hout, ⟨hb.context, hb.valuation, hb.rowValue, hb.reserved, (congrFun he.a 2590).trans hb.emittedAnchor⟩⟩,
    ⟨fresh_of hr hout hi hbr hf, ⟨(congrFun he.a 2586).trans hanc.1, (congrFun he.a 2589).trans hanc.2⟩⟩,
    hT x _ ⟨runC_le _ _ _ _ _ hrun', he.node, ng, tokens_of_grow hr hout ng (countersOkB_tokens hcnt),
      congrFun he.a 12504⟩ htr⟩

/-- **A short path**: the chain in its prefix, its cut at the halted state, no steps left. -/
noncomputable def haltPath {extra : List Nat} {s : St FF.S} {S : SSrv} {I0 : ICut (fullWorldXD NB).F} {n : Nat}
    {Tr : SegInst FF → Prop} {vs : List F64}
    (pre : CutStep I0 (withMem Tr (endCut NB T tk cap extra s S)) n)
    (v : Val) (hhalt : s.ctl = .halt (.normal v))
    (o : Obj) (hemit : s.heap.get 12504 = some (.obj o)) (hkind : o.kind = .array (arrOf s 12504))
    (hcell : s.cell? 2590 = some (some (.obj 12504)))
    (hfree : (2665 :: extra).contains 12504 = false)
    (hTr : ∀ x, Tr x → x.M.a 12504 = 12504)
    (hvals : ∀ ν : Nat → F64, (∀ j, j < 9 → ν j = machVal T tk j) →
      (arrOf s 12504 ++ []).mapM (symValW ⟨S.tab, []⟩ ν) = some vs) :
    PathW (fullWorldXD NB) addrPrompt wideP setupP shortFixP I0 vs where
  I := withMem Tr (endCut NB T tk cap extra s S)
  n := n
  pre := pre
  r := machReads T tk
  xs := []
  hs := haltSegOf (machReads T tk) (O := []) (QA := fun _ _ => True) (QE := fun _ _ => True) (.nil _ _ _)
    { halt := fun _ x hx => ⟨x.M.val v, by rw [hx.1.ctl]; show x.M.ctl s.ctl = _; rw [hhalt]; rfl⟩
      emitG := ⟨o, hemit, by simpa using hkind⟩
      cell := hcell }
  entry := by
    rintro x ⟨hr, hb⟩ ⟨⟨_, hanc⟩, htr⟩
    refine ⟨hr.ofJ, fun _ h => nomatch h, trivial, ?_, ?_⟩
    · cases hk : x.K.fr 12504 with
      | none => rfl
      | some p =>
        have hm := (hb.context.1.2.2 12504).mp (by rw [hk]; exact Option.some_ne_none _)
        have hc : (2665 :: extra).contains 12504 = true := List.contains_iff_mem.mpr hm
        rw [hfree] at hc
        cases hc
    · intro a ha
      simp only [shortFixP, List.mem_cons, List.not_mem_nil, or_false] at ha
      rcases ha with rfl | rfl | rfl | rfl
      · exact hanc.1
      · exact hanc.2
      · exact hTr x htr
      · exact hb.emittedAnchor
  vals := fun x hx _ => hvals x.ν hx.2.reserved

/-- A short path's goal, from the bookkeeping at the halted cut. -/
theorem haltPath_goal {extra : List Nat} {s : St FF.S} {S : SSrv} {I0 : ICut (fullWorldXD NB).F} {n : Nat}
    {Tr : SegInst FF → Prop} {vs : List F64} (pre : CutStep I0 (withMem Tr (endCut NB T tk cap extra s S)) n)
    (v : Val) (hhalt : s.ctl = .halt (.normal v)) (o : Obj) (hemit : s.heap.get 12504 = some (.obj o))
    (hkind : o.kind = .array (arrOf s 12504)) (hcell : s.cell? 2590 = some (some (.obj 12504)))
    (hfree : (2665 :: extra).contains 12504 = false) (hTr : ∀ x, Tr x → x.M.a 12504 = 12504)
    (hvals : ∀ ν : Nat → F64, (∀ j, j < 9 → ν j = machVal T tk j) →
      (arrOf s 12504 ++ []).mapM (symValW ⟨S.tab, []⟩ ν) = some vs)
    {Gf : St FF.S → CSrv → Prop} (hG : ∀ x : SegInst FF, Tr x → Gf x.t x.C) :
    (haltPath pre v hhalt o hemit hkind hcell hfree hTr hvals).Goal Gf := by
  rintro x xF _ ⟨_, htr⟩ hrun _ _ _ _
  have h := hG x htr
  have hrun' : runC FF 0 x.t x.C = some (xF.t, xF.C) := hrun
  simp only [runC, runWith] at hrun'
  cases hrun'
  exact h

end

end Host.Ts.Sim.Compose.Post

import host.sim.compose.PostGlue
import host.sim.compose.HookMem
import host.sim.template.PostOkFast
import host.sim.template.a4pre_d1_dispatch.Advance
import host.sim.template.a4pre_d1_body.SizeAt
import host.sim.compose.PrefillLen
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Load.Run.Tpl Host.Ts.Sim.Compose.SetupEarly

/-! # POST's flat chains over the prompt's book

The generated chains (`gen.ts post-chain`) are stretches, steps into a bridged call, `mlx_array_size` bridges and the
prompt's length, under one of two acceptances (`Mode`). Each keeps the book. `Tr` is what the caller carries over a
stretch that pops nothing (`NTrack`); `hookMem` turns a chain carrying `NTrack x0` into a change of bookkeeping. -/

/-- What a book says of the valuation. -/
structure BookV (T : Nat) (tk : Nat → Nat) (L : Nat) (ν : Nat → F64) : Prop where
  promptValue : ν 9 = F64.ofNat L
  rowValue : ν 10 = F64.ofNat 1
  offsetValue : ν 11 = F64.ofNat L
  capValue : ν 16 = F64.ofNat (capL L)
  reserved : ∀ j, j < 9 → ν j = machVal T tk j

theorem Book.v {T cap nI : Nat} {tk : Nat → Nat} {π γ : List Nat} {x : SegInst FF} (h : Book T tk cap nI π γ x) :
    BookV T tk π.length x.ν :=
  ⟨h.promptValue, h.rowValue, h.offsetValue, h.capValue, h.reserved⟩

theorem good_drop {ν : Nat → F64} {o : List Ans} (d : Nat) (h : Good ν o) : Good ν (o.drop d) :=
  fun q hq => h q (List.mem_of_mem_drop hq)

/-- A chain's acceptance, the simulation it serves at the admitted offset, and the book's context there. -/
structure Mode (NB T : Nat) (tk : Nat → Nat) (cap : Nat) where
  okS : St FF.S → SSrv → Bool
  okT : St FF.S → SSrv → Bool
  Kp : Ctx → Prop
  lift : ∀ s S, okS s S = true → okT s S = true
  sim : ∀ y0 : Host.Mlx.Ffi.St, Disp.StepSimXLB FF
    (Disp.FRJ (FRQ (FullRXD (PostSimulation.params T tk) NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
    okT Kp wideP [] PostHeadSmall.VP
  ctx : ∀ K, Disp.KpJ PostOk.J cap K → Kp K

/-- The row's forward acceptance at the admitted offset. -/
abbrev okRL (limit cap : Nat) := Disp.okJSJLimit PostOk.JR limit cap (okBackFXS setupP)

theorem simulationRQ (NB T : Nat) (tk : Nat → Nat) (limit cap : Nat) (hlimit : limit ≤ jsSignedLimit)
    (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF
      (Disp.FRJ (FRQ (FullRXD (PostSimulation.params T tk) NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (okRL limit cap) (Disp.KpJ PostOk.JR cap) wideP [] PostHeadSmall.VP := by
  have hj : PostOk.JR.okCall = okCallFXS (PostSimulation.params T tk) :=
    (FlatFwd.okCallFXS_rest setupP (machReads T tk)).symm
  have hC : FfiCallSim FF (FullRXD (PostSimulation.params T tk) NB) PostOk.JR.okCall smallFXS := by
    rw [hj]; exact fullCallSimXS (PostSimulation.params T tk) NB
  have hQ := fullTargetPres (FR := FullRXD (PostSimulation.params T tk) NB) fullRXD_ninv y0
  have hs := Disp.stepSimXLBJSLimit (P := PostOk.JR) (D0 := cap) (stk := [])
    (VBOk := PostHeadSmall.VP) hlimit ((fullFfiSimXD (PostSimulation.params T tk) NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS (PostSimulation.params T tk) NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (fun _ _ _ _ _ hν hb => FlatFwd.smallFX2_sound (r := 10) hν hb)
    (fun _ _ _ _ hν hb => smallBackFB_sound hν.1 hb)
    (fullRXD_laws (PostSimulation.params T tk) NB).liftQ fullLawful
    (fullNativeFactsXD (PostSimulation.params T tk) NB PostOk.JR rfl rfl rfl).liftQ
    PostOk.wp
  simpa only [PostSimulation.params, backRest, okRL] using hs

/-- `PostOk.ok`. -/
noncomputable def modeOk (NB T : Nat) (tk : Nat → Nat) (cap : Nat) (hcap : cap ≤ 4096 + 1593835520) : Mode NB T tk cap where
  okS := PostOk.ok
  okT := PostSimulation.ok jsSignedLimit cap
  Kp := Disp.KpJ PostOk.J cap
  lift _ _ h := PostSimulation.accepted_signed hcap h
  sim y0 := PostSimulation.simulationQ NB T tk jsSignedLimit cap (Nat.le_refl _) [] y0
  ctx _ h := h

/-- `PostOk.okR`: a row's forward. -/
noncomputable def modeR (NB T : Nat) (tk : Nat → Nat) (cap : Nat) (hcap : cap ≤ 4096 + 1593835520) : Mode NB T tk cap where
  okS := PostOk.okR
  okT := okRL jsSignedLimit cap
  Kp := Disp.KpJ PostOk.JR cap
  lift _ _ h := Disp.okJSJLimit_signed_of_allowance hcap h
  sim y0 := simulationRQ NB T tk jsSignedLimit cap (Nat.le_refl _) y0
  ctx _ h := h

/-- The rejection of a Neural Engine state survives any stretch that keeps the bridge. -/
theorem fresh_of {P : LoadP} {NB : Nat} {M M' : Map} {ν ν' : Nat → F64} {K K' : Ctx} {sa sb : St FF.S} {Sa Sb : SSrv}
    {t t' : St FF.S} {C C' : CSrv}
    (h0 : RelB FF (Disp.FRJ (FullRXD P NB)) wideP [] M ν K sa Sa t C)
    (h1 : RelB FF (Disp.FRJ (FullRXD P NB)) wideP [] M' ν' K' sb Sb t' C')
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi) (hf : AneFresh t) : AneFresh t' := by
  obtain ⟨_, _, r0⟩ := h0.ffi.1
  obtain ⟨_, _, r1⟩ := h1.ffi.1
  have hi' : (bridgeOf sb.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) hbr).trans hi
  have hbridge : bridgeOf t'.ffi = bridgeOf t.ffi :=
    (r1.toR hi').bridge.1.trans (hbr.trans (r0.toR hi).bridge.1.symm)
  intro Cx Pc Kc weights kind NE IP G init
  rw [hbridge]
  exact hf Cx Pc Kc weights kind NE IP G init

section
variable {NB T cap nI : Nat} {tk : Nat → Nat} {π : List Nat}

/-- The target's image of a checked stretch: a run, the map's extension, the relation at the end, the growth. -/
theorem stretch (m : Mode NB T tk cap) {n : Nat} {γ : List Nat} {sa sb : St FF.S} {Sa Sb : SSrv} {x : SegInst FF}
    (ha : m.okS sa Sa = true) (hrun : runOk FF m.okS n sa Sa = some (sb, Sb)) (htop : noRetBlock sb = true)
    (hgood : ∀ ν, BookV T tk π.length ν → Good ν Sa.oracle)
    (hr : RelB FF (Disp.FRJ (FullRXD (PostSimulation.params T tk) NB)) wideP [] x.M x.ν x.K sa ⟨Sa.tab, []⟩ x.t x.C)
    (hb : Book T tk cap nI π γ x) :
    ∃ M' t' C', runC FF n x.t x.C = some (t', C') ∧ Ext x.M M' Sa.tab.length ∧
      RelB FF (Disp.FRJ (FullRXD (PostSimulation.params T tk) NB)) wideP [] M' x.ν x.K sb ⟨Sb.tab, []⟩ t' C' ∧
      Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf t'.ffi) := by
  have hq : RelB FF (Disp.FRJ (FRQ (FullRXD (PostSimulation.params T tk) NB)
      fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))) wideP [] x.M x.ν x.K sa ⟨Sa.tab, []⟩ x.t x.C :=
    { hr with ffi := ⟨⟨hr.ffi.1, Host.Mlx.Ffi.NGrow.refl _⟩, hr.ffi.2⟩ }
  obtain ⟨M', t', C', hrun', he, hrel⟩ := D1Advance.run (m.sim (mlxOf x.t.ffi)) (m.ctx _ hb.context)
    ⟨hb.valuation, hb.rowValue⟩ (hgood x.ν hb.v) (m.lift _ _ ha) (runOk_mono (fun _ _ => m.lift _ _) hrun) htop hq
  exact ⟨M', t', C', hrun', he, { hrel with ffi := ⟨hrel.ffi.1.1, hrel.ffi.2⟩ }, hrel.ffi.1.2⟩

/-- `stretch`, and the step into a bridged call. -/
theorem stretchCall (m : Mode NB T tk cap) {n : Nat} {γ : List Nat} {sa sb sc : St FF.S} {Sa Sb Sc : SSrv} {x : SegInst FF}
    (ha : m.okS sa Sa = true) (hrun : runOk FF m.okS n sa Sa = some (sb, Sb)) (hb' : m.okS sb Sb = true)
    (hh : isHalt sb.ctl = false) (hs : interpS (step FF sb).run Sb = some (sc, Sc)) (htop : noRetBlock sc = true)
    (hgood : ∀ ν, BookV T tk π.length ν → Good ν Sa.oracle)
    (hr : RelB FF (Disp.FRJ (FullRXD (PostSimulation.params T tk) NB)) wideP [] x.M x.ν x.K sa ⟨Sa.tab, []⟩ x.t x.C)
    (hb : Book T tk cap nI π γ x) :
    ∃ M' t' C', runC FF (n + 1) x.t x.C = some (t', C') ∧ Ext x.M M' Sa.tab.length ∧
      RelB FF (Disp.FRJ (FullRXD (PostSimulation.params T tk) NB)) wideP [] M' x.ν x.K sc ⟨Sc.tab, []⟩ t' C' ∧
      Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf t'.ffi) := by
  have hq : RelB FF (Disp.FRJ (FRQ (FullRXD (PostSimulation.params T tk) NB)
      fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))) wideP [] x.M x.ν x.K sa ⟨Sa.tab, []⟩ x.t x.C :=
    { hr with ffi := ⟨⟨hr.ffi.1, Host.Mlx.Ffi.NGrow.refl _⟩, hr.ffi.2⟩ }
  obtain ⟨M', t', C', hrun', he, hrel⟩ := D1Advance.call (m.sim (mlxOf x.t.ffi)) (m.ctx _ hb.context)
    ⟨hb.valuation, hb.rowValue⟩ (hgood x.ν hb.v) (m.lift _ _ ha) (runOk_mono (fun _ _ => m.lift _ _) hrun)
    (m.lift _ _ hb') hh hs htop hq
  exact ⟨M', t', C', hrun', he, { hrel with ffi := ⟨hrel.ffi.1.1, hrel.ffi.2⟩ }, hrel.ffi.1.2⟩

/-- A stretch that pops nothing. -/
theorem glueM (m : Mode NB T tk cap) {ok : St FF.S → SSrv → Bool} {n : Nat} {sa sb : St FF.S} {Sa Sb : SSrv} {Tr : SegInst FF → Prop}
    (ha : ok sa Sa = true) (hrun : runOk FF ok n sa Sa = some (sb, Sb)) (htop : noRetBlock sb = true)
    (hgood : ∀ ν, BookV T tk π.length ν → Good ν Sa.oracle)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hcnt : countersOkB sa sb = true) (hT : ∀ x y, NTrack x y → Tr x → Tr y) (hm : m.okS = ok) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π sa Sa)) (withMem Tr (indexedCut NB T tk cap nI π sb Sb)) n := by
  subst hm
  rintro t C ⟨x, rfl, rfl, ⟨γ, hr, hb⟩, ⟨hf, hanc⟩, htr⟩
  obtain ⟨M', t', C', hrun', he, hout, ng⟩ := stretch m ha hrun htop hgood hr hb
  exact ⟨t', C', hrun', ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl, ⟨γ, hout, hb.grow he ng (runC_le _ _ _ _ _ hrun')⟩,
    ⟨fresh_of hr hout hi hbr hf, ⟨(congrFun he.a 2586).trans hanc.1, (congrFun he.a 2589).trans hanc.2⟩⟩,
    hT x _ ⟨runC_le _ _ _ _ _ hrun', he.node, ng, tokens_of_grow hr hout ng (countersOkB_tokens hcnt), congrFun he.a 12504⟩ htr⟩

/-- A stretch and the step into a bridged call, popping nothing. -/
theorem callM (m : Mode NB T tk cap) {ok : St FF.S → SSrv → Bool} {n : Nat} {sa sb sc : St FF.S} {Sa Sb Sc : SSrv} {Tr : SegInst FF → Prop}
    (ha : ok sa Sa = true) (hrun : runOk FF ok n sa Sa = some (sb, Sb)) (hb' : ok sb Sb = true)
    (hh : isHalt sb.ctl = false) (hs : interpS (step FF sb).run Sb = some (sc, Sc)) (htop : noRetBlock sc = true)
    (hgood : ∀ ν, BookV T tk π.length ν → Good ν Sa.oracle)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sc.ffi = bridgeOf sa.ffi)
    (hcnt : countersOkB sa sc = true) (hT : ∀ x y, NTrack x y → Tr x → Tr y) (hm : m.okS = ok) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π sa Sa)) (withMem Tr (indexedCut NB T tk cap nI π sc Sc)) (n + 1) := by
  subst hm
  rintro t C ⟨x, rfl, rfl, ⟨γ, hr, hb⟩, ⟨hf, hanc⟩, htr⟩
  obtain ⟨M', t', C', hrun', he, hout, ng⟩ := stretchCall m ha hrun hb' hh hs htop hgood hr hb
  exact ⟨t', C', hrun', ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl, ⟨γ, hout, hb.grow he ng (runC_le _ _ _ _ _ hrun')⟩,
    ⟨fresh_of hr hout hi hbr hf, ⟨(congrFun he.a 2586).trans hanc.1, (congrFun he.a 2589).trans hanc.2⟩⟩,
    hT x _ ⟨runC_le _ _ _ _ _ hrun', he.node, ng, tokens_of_grow hr hout ng (countersOkB_tokens hcnt), congrFun he.a 12504⟩ htr⟩

/-- A stretch that may pop a token: the bookkeeping changes by `hook`, from what the stretch's end knows. -/
theorem popM (m : Mode NB T tk cap) {ok : St FF.S → SSrv → Bool} {n : Nat} {sa sb : St FF.S} {Sa Sb : SSrv} {Mem Mem' : SegInst FF → Prop}
    (ha : ok sa Sa = true) (hrun : runOk FF ok n sa Sa = some (sb, Sb)) (htop : noRetBlock sb = true)
    (hgood : ∀ ν, BookV T tk π.length ν → Good ν Sa.oracle)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hook : ∀ x y : SegInst FF, (indexedCut NB T tk cap nI π sa Sa).R x sa ⟨Sa.tab, []⟩ →
      (indexedCut NB T tk cap nI π sb Sb).R y sb ⟨Sb.tab, []⟩ → CSrv.Le x.C y.C → y.M.node = x.M.node → y.M.a 12504 = x.M.a 12504 →
      Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → Mem x → Mem' y) (hm : m.okS = ok) :
    CutStep (withMem Mem (indexedCut NB T tk cap nI π sa Sa)) (withMem Mem' (indexedCut NB T tk cap nI π sb Sb)) n := by
  subst hm
  rintro t C ⟨x, rfl, rfl, ⟨γ, hr, hb⟩, ⟨hf, hanc⟩, htr⟩
  obtain ⟨M', t', C', hrun', he, hout, ng⟩ := stretch m ha hrun htop hgood hr hb
  have hb' := hb.grow he ng (runC_le _ _ _ _ _ hrun')
  exact ⟨t', C', hrun', ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl, ⟨γ, hout, hb'⟩,
    ⟨fresh_of hr hout hi hbr hf, ⟨(congrFun he.a 2586).trans hanc.1, (congrFun he.a 2589).trans hanc.2⟩⟩,
    hook x ⟨M', x.ν, x.K, t', C'⟩ ⟨γ, hr, hb⟩ ⟨γ, hout, hb'⟩ (runC_le _ _ _ _ _ hrun') he.node (congrFun he.a 12504) ng htr⟩

/-- An `mlx_array_size` bridge: three target steps, a new trace base. -/
theorem sizeM {sa sb : St FF.S} {Sa Sb Sdec : SSrv} {fsym ta nf : Nat} {name rt : Name} {tys args : List Val}
    {asR : List Arg} {Tr : SegInst FF → Prop}
    (hparts : Disp.sizeParts sa = some (fsym, ta, nf, name, rt, tys, args))
    (hargs : Disp.sizeArgsOk sa = true)
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (hmlx : Host.Load.isMlx name = true)
    (hpay : nameEq name Host.Mlx.FfiAne.payloadName = false)
    (hta : [2665].contains ta = false)
    (hdec : interpS (decodeArgs FF sa tys args).run Sa = some (some asR, Sdec))
    (hpre : sizePreB loopVB Sdec sa.ffi asR = true)
    (hsize : interpS (Disp.sizeS FF sa).run Sa = some (sb, Sb))
    (hgood : ∀ ν, BookV T tk π.length ν → Good ν Sa.oracle)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hcnt : countersOkB sa sb = true) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π sa Sa)) (withMem Tr (indexedCut NB T tk cap nI π sb Sb)) 3 := by
  rintro t C ⟨x, rfl, rfl, ⟨γ, hr, hb⟩, ⟨hf, hanc⟩, htr⟩
  have hr0 : RelB FF (Disp.FRJ (FullRXD (PostSimulation.params T tk) NB)) wideP [] x.M x.ν x.K sa Sa x.t x.C :=
    hr.withOracle (hgood x.ν hb.v)
  have hq := (relB_withQ hr0.ofJ (Q := fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))
    (Host.Mlx.Ffi.NGrow.refl (mlxOf x.t.ffi))).toJ hr0.ffi.2
  have hfr : x.K.fr ta = none := by
    cases hk : x.K.fr ta with
    | none => rfl
    | some p =>
      have hm := (hb.context.1.2.2 ta).mp (by rw [hk]; exact Option.some_ne_none _)
      have hc : [2665].contains ta = true := List.contains_iff_mem.mpr hm
      rw [hta] at hc
      cases hc
  have hpre0 : ∀ ars S1, interpS (decodeArgs FF sa tys args).run Sa = some (some ars, S1) →
      D1BodySize.Pre x.ν S1 sa.ffi ars := fun ars S1 hd =>
    ⟨sizePre_of hdec hpre hb.valuation ars S1 hd, hi⟩
  obtain ⟨M', t', C', _, ⟨⟨gg, hrel, _⟩, hrun⟩⟩ :=
    (D1BodySize.growAt (mlxOf x.t.ffi) hq hparts hargs hsym hmlx hpay hfr hpre0).run sb Sb hsize
  let K' : Ctx := ⟨x.K.fr, sb.trace, t'.trace, x.K.D, x.K.lo, x.K.hi⟩
  have hout0 : RelB FF (Disp.FRJ (FullRXD (PostSimulation.params T tk) NB)) wideP [] M' x.ν K' sb Sb t' C' :=
    { hrel with ffi := ⟨hrel.ffi.1.1, hrel.ffi.2⟩ }
  have hout := hout0.withOracle (o := []) (fun _ h => nomatch h)
  have hext := gg.ext
  have ng : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf t'.ffi) := hrel.ffi.1.2
  have hbook : Book T tk cap nI π γ ⟨M', x.ν, K', t', C'⟩ := by
    refine ⟨hb.nonempty, hb.vocab, hb.lastRows, hb.rowsLength, hb.rowsVocab, hb.valuation, hb.promptValue, hb.rowValue, hb.small21,
      hb.offsetValue, hb.capValue, ⟨hb.context.1, hb.context.2⟩, hb.offsetLow, hb.prompt, hb.reserved,
      (congrFun hext.a 2590).trans hb.emittedAnchor, ?_⟩
    have hip : SetupD1Input.InputAt γ (x.M.node nI) x.t x.C := hb.input
    change SetupD1Input.InputAt γ (M'.node nI) t' C'
    rw [hext.node]
    exact hip.grow ng (runC_le _ _ _ _ _ hrun)
  exact ⟨t', C', hrun, ⟨M', x.ν, K', t', C'⟩, rfl, rfl, ⟨γ, hout, hbook⟩,
    ⟨fresh_of hr hout hi hbr hf, ⟨(congrFun hext.a 2586).trans hanc.1, (congrFun hext.a 2589).trans hanc.2⟩⟩,
    hT x _ ⟨runC_le _ _ _ _ _ hrun, hext.node, ng, tokens_of_grow hr hout ng (countersOkB_tokens hcnt), congrFun hext.a 12504⟩ htr⟩

/-- The prompt's length: one target step, the value at `L`. -/
theorem lenM {sa sb : St FF.S} {Sa Sb : SSrv} {o : Obj} {Tr : SegInst FF → Prop}
    (hc : sa.ctl = .ret (.obj 2665)) (hst : sa.stack = .e (.member kLength false) :: sa.stack.tail)
    (ho : sa.obj? 2665 = some o) (hk : o.kind = .array ([] ++ ([] : List Val)))
    (hp : Bridge.lenPatch sa Sa (.var 9) = (sb, Sb))
    (hgood : ∀ ν, BookV T tk π.length ν → Good ν Sa.oracle)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hcnt : countersOkB sa sb = true) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π sa Sa)) (withMem Tr (indexedCut NB T tk cap nI π sb Sb)) 1 := by
  rintro t C ⟨x, rfl, rfl, ⟨γ, hr, hb⟩, ⟨hf, hanc⟩, htr⟩
  have h0 : RelB FF (Disp.FRJ (FullRXD (PostSimulation.params T tk) NB)) wideP [] x.M x.ν x.K sa ⟨Sa.tab, Sa.oracle⟩ x.t x.C :=
    hr.withOracle (hgood x.ν hb.v)
  have heval : (.var 9 : SymE).eval x.ν = F64.ofNat ((π.map natV).length + ([] : List Val).length) := by
    simpa only [SymE.eval, List.length_map, List.length_nil, Nat.add_zero] using hb.promptValue
  obtain ⟨step1, ext1, rel1⟩ := Disp.bridge_len h0.ofJ
    (fullRXD_laws (PostSimulation.params T tk) NB) hc hst hb.prompt ho hk (.var 9) heval
  let M := x.M.setNum Sa.tab.length (.lit (F64.ofNat ((π.map natV).length + ([] : List Val).length)))
  let t' : St FF.S := { x.t with stack := sa.stack.tail.map x.M.frame ++ [] }.ret
    (natV ((π.map natV).length + ([] : List Val).length))
  have relp : RelB FF (FullRXD (PostSimulation.params T tk) NB) wideP [] M x.ν x.K sb Sb t' x.C :=
    (congrArg (fun p : St FF.S × SSrv => RelB FF (FullRXD (PostSimulation.params T tk) NB) wideP [] M x.ν x.K p.1 p.2 t' x.C) hp).mp rel1
  have relj := relp.toJ (h0.ffi.2.ext ext1)
  have rel' := relj.withOracle (o := []) (fun _ h => nomatch h)
  have ng : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf t'.ffi) := Host.Mlx.Ffi.NGrow.refl _
  have hbook : Book T tk cap nI π γ ⟨M, x.ν, x.K, t', x.C⟩ := by
    refine ⟨hb.nonempty, hb.vocab, hb.lastRows, hb.rowsLength, hb.rowsVocab, hb.valuation, hb.promptValue, hb.rowValue, hb.small21,
      hb.offsetValue, hb.capValue, hb.context, hb.offsetLow, hb.prompt, hb.reserved,
      (congrFun ext1.a 2590).trans hb.emittedAnchor, ?_⟩
    have hip : SetupD1Input.InputAt γ (x.M.node nI) x.t x.C := hb.input
    change SetupD1Input.InputAt γ (M.node nI) t' x.C
    rw [ext1.node]
    exact hip.grow ng (CSrv.Le.refl _)
  exact ⟨t', x.C, runC_one (by rw [h0.isHalt, hc]; rfl) step1, ⟨M, x.ν, x.K, t', x.C⟩, rfl, rfl, ⟨γ, rel', hbook⟩,
    ⟨fresh_of hr rel' hi hbr hf, ⟨(congrFun ext1.a 2586).trans hanc.1, (congrFun ext1.a 2589).trans hanc.2⟩⟩,
    hT x _ ⟨CSrv.Le.refl _, ext1.node, ng, rfl, congrFun ext1.a 12504⟩ htr⟩

end

end Host.Ts.Sim.Compose.Post

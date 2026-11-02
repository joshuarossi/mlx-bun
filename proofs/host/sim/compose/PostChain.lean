import host.sim.compose.PostCut
import host.sim.compose.HookMem
import host.sim.template.PostOkFast
import host.sim.template.a4pre_d1_dispatch.Advance
import host.sim.compose.PrefillLen
import host.sim.compose.a4b.SetupEarlyGlue
import host.sim.full.JsLimit
import host.sim.conv.RunAccept
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Load.Run.Tpl Host.Ts.Sim.Compose.SetupEarly

/-! # POST's flat chains over the prompt's book

The generated chains (`gen.ts post-chain`) are stretches, steps into a bridged call and the prompt's length, under one of
three acceptances (`Mode`). Each keeps the book. `Tr` is what the caller carries over a stretch that pops nothing
(`NTrackV`); `hookMemV` turns a chain carrying `NTrackV x0` into a change of bookkeeping. -/

/-- A stretch at one template keeps the valuation too. -/
structure NTrackV (x y : SegInst FF) : Prop extends NTrack x y where
  val : y.ν = x.ν

theorem NTrackV.refl (x : SegInst FF) : NTrackV x x := ⟨NTrack.refl x, rfl⟩

/-- A pop's counters: the native ones only, the token queue shrinks. -/
def countersPopB (sa sb : St FF.S) : Bool :=
  Nat.ble (mlxOf sa.ffi).next (mlxOf sb.ffi).next && Nat.blt (mlxOf sb.ffi).next 131072 &&
    Nat.ble (mlxOf sa.ffi).nnext (mlxOf sb.ffi).nnext

/-- `NativeAt.step`, where a stretch pops. -/
theorem NativeAt.stepPop {H N NB : Nat} {P : LoadP} {W W' : Nat → Option WFrame} {M M' : Map}
    {ν ν' : Nat → F64} {K K' : Ctx} {sa sb t t' : St FF.S} {Sa Sb : SSrv} {C C' : CSrv}
    (h : NativeAt H N sa t) (hP : P.E = 131072)
    (hr : RelB FF (Disp.FRJ (FullRXD P NB)) W [] M ν K sa Sa t C)
    (hr' : RelB FF (Disp.FRJ (FullRXD P NB)) W' [] M' ν' K' sb Sb t' C')
    (hbig : M'.big = M.big) (hnode : M'.node = M.node) (hc : countersPopB sa sb = true) :
    NativeAt H N sb t' := by
  simp only [countersPopB, Bool.and_eq_true] at hc
  obtain ⟨⟨hle, hlt⟩, hnle⟩ := hc
  have hle := Nat.le_of_ble_eq_true hle
  have hlt := Nat.blt_eq.mp hlt
  have hnle := Nat.le_of_ble_eq_true hnle
  obtain ⟨P0, hP0, r0⟩ := hr.ffi.1
  obtain ⟨P1, hP1, r1⟩ := hr'.ffi.1
  obtain ⟨_, hE0, _, _⟩ := Raised.restart (.inl rfl) hP0
  obtain ⟨_, hE1, _, _⟩ := Raised.restart (.inl rfl) hP1
  have a0 := r0.load.mlx.hfreshB ((mlxOf sb.ffi).next - (mlxOf sa.ffi).next) (by
    change (mlxOf sa.ffi).next + _ < P0.E
    rw [hE0, hP]; omega)
  have a1 := r1.load.mlx.hfreshB 0 (by
    change (mlxOf sb.ffi).next + 0 < P1.E
    rw [hE1, hP]; omega)
  have n0 := r0.load.mlx.nfresh ((mlxOf sb.ffi).nnext - (mlxOf sa.ffi).nnext)
  have n1 := r1.load.mlx.nfresh 0
  change M.big (Int.ofNat ((mlxOf sa.ffi).next + _)) = Int.ofNat ((mlxOf t.ffi).next + _) at a0
  change M'.big (Int.ofNat ((mlxOf sb.ffi).next + 0)) = Int.ofNat ((mlxOf t'.ffi).next + 0) at a1
  change M.node ((mlxOf sa.ffi).nnext + _) = (mlxOf t.ffi).nnext + _ at n0
  change M'.node ((mlxOf sb.ffi).nnext + 0) = (mlxOf t'.ffi).nnext + 0 at n1
  rw [hbig] at a1
  rw [hnode] at n1
  have eh : (mlxOf sa.ffi).next + ((mlxOf sb.ffi).next - (mlxOf sa.ffi).next) = (mlxOf sb.ffi).next + 0 := by omega
  have en : (mlxOf sa.ffi).nnext + ((mlxOf sb.ffi).nnext - (mlxOf sa.ffi).nnext) = (mlxOf sb.ffi).nnext + 0 := by omega
  rw [eh, a1] at a0
  rw [en, n1] at n0
  have a2 := Int.ofNat.inj a0
  obtain ⟨h1, h2⟩ := h
  constructor <;> omega

/-- A chain carrying its start and valuation changes the bookkeeping, from what its end knows. -/
theorem hookMemV {A B : ICut FF} {n : Nat} {Mem Mem' : SegInst FF → Prop}
    (hstep : ∀ x0, CutStep (withMem (NTrackV x0) A) (withMem (NTrackV x0) B) n)
    (hook : ∀ x y : SegInst FF, A.R x A.s0 ⟨A.tab0, []⟩ → B.R y B.s0 ⟨B.tab0, []⟩ → B.B y → NTrackV x y → Mem x → Mem' y) :
    CutStep (withMem Mem A) (withMem Mem' B) n := by
  rintro t C ⟨x, rfl, rfl, hR, ⟨hB, hm⟩⟩
  obtain ⟨t', C', hrun, y, rfl, rfl, hR', ⟨hB', htr⟩⟩ :=
    hstep x x.t x.C ⟨x, rfl, rfl, hR, ⟨hB, NTrackV.refl x⟩⟩
  exact ⟨y.t, y.C, hrun, y, rfl, rfl, hR', ⟨hB', hook x y hR hR' hB' htr hm⟩⟩

/-- What a book says of the valuation. -/
structure BookV (P : Stage) (T : Nat) (tk : Nat → Nat) (L : Nat) (ν : Nat → F64) : Prop where
  promptValue : ν 9 = F64.ofNat L
  rowValue : ν 10 = F64.ofNat 1
  offsetValue : ν 11 = F64.ofNat L
  capValue : ν 16 = F64.ofNat (capL L)
  reserved : ∀ j, j < 9 → ν j = machVal T tk j
  dims : P.dims ν

theorem Book.v {P : Stage} {T cap nI : Nat} {tk : Nat → Nat} {π γ : List Nat} {x : SegInst FF} (h : Book P T tk cap nI π γ x) :
    BookV P T tk π.length x.ν :=
  ⟨h.promptValue, h.rowValue, h.offsetValue, h.capValue, h.reserved, h.dims⟩

/-- The forwards' pinned variables, from the tail's book. -/
theorem pinPost {ν : Nat → F64} (h1 : ν 10 = F64.ofNat 1) (hd : tail.dims ν) :
    ∀ v k, FlatFwd.Pin.post v = some k → ν v = F64.ofNat k := by
  intro v k hv
  unfold FlatFwd.Pin.post at hv
  cases e : Nat.beq v 10 with
  | true =>
    obtain rfl := Nat.eq_of_beq_eq_true e
    simp only [Nat.beq_refl, Bool.cond_true, Option.some.injEq] at hv
    subst hv
    exact h1
  | false =>
    simp only [e, Bool.cond_false] at hv
    exact hd v k hv

theorem good_drop {ν : Nat → F64} {o : List Ans} (d : Nat) (h : Good ν o) : Good ν (o.drop d) :=
  fun q hq => h q (List.mem_of_mem_drop hq)

abbrev params (T : Nat) (tk : Nat → Nat) : LoadP := { setupP with rest := machReads T tk }

/-- A chain's acceptance at a stretch's frames, the simulation it serves at the admitted offset, the book's context and values there. -/
structure Mode (P : Stage) (NB T : Nat) (tk : Nat → Nat) (cap : Nat) where
  okS : St FF.S → SSrv → Bool
  okT : St FF.S → SSrv → Bool
  Kp : Ctx → Prop
  Vp : (Nat → F64) → Prop
  lift : ∀ s S, okS s S = true → okT s S = true
  sim : ∀ y0 : Host.Mlx.Ffi.St, Disp.StepSimXLB FF
    (Disp.FRJ (FRQ (FullRXD (params T tk) NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
    okT Kp P.W [] Vp
  ctx : ∀ K, Disp.KpJ P.J cap K → Kp K
  vp : ∀ {cap' nI : Nat} {π γ : List Nat} {x : SegInst FF}, Book P T tk cap' nI π γ x → Vp x.ν

/-- POST's frames with `PostHeadSmall`'s smallness. -/
abbrev JOf (F : List Nat) (L : List (Nat × WFrame)) : Disp.JSP FF :=
  { fullJSPPXS setupP F L with smallB := PostHeadSmall.smallFX2 }

theorem simulationQ (NB T : Nat) (tk : Nat → Nat) (limit cap : Nat) (hlimit : limit ≤ jsSignedLimit) (stk : List Frame)
    (y0 : Host.Mlx.Ffi.St) (F : List Nat) (L : List (Nat × WFrame)) (W : Nat → Option WFrame) (hwp : Disp.Wp (JOf F L) W) :
    Disp.StepSimXLB FF
      (Disp.FRJ (FRQ (FullRXD (params T tk) NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (Disp.okJSJLimit (JOf F L) limit cap (okBackFXS setupP)) (Disp.KpJ (JOf F L) cap) W stk PostHeadSmall.VP := by
  have hj : (JOf F L).okCall = okCallFXD (params T tk) :=
    (callRaiseRest setupP (machReads T tk)).symm
  have hC : FfiCallSim FF (FullRXD (params T tk) NB) (JOf F L).okCall smallFX2 := by
    rw [hj]; exact fullCallSimXD (params T tk) NB
  have hQ := fullTargetPres (FR := FullRXD (params T tk) NB) fullRXD_ninv y0
  have hs := Disp.stepSimXLBJSLimit (P := JOf F L) (D0 := cap) (stk := stk)
    (VBOk := PostHeadSmall.VP) hlimit ((fullFfiSimXD (params T tk) NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS (params T tk) NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (fun _ _ _ _ _ hν hb => PostHeadSmall.smallFX2_sound hν hb)
    (fun _ _ _ _ hν hb => smallBackFB_sound hν.1 hb)
    (fullRXD_laws (params T tk) NB).liftQ fullLawful
    (fullNativeFactsXD (params T tk) NB (JOf F L) rfl rfl rfl).liftQ
    hwp
  simpa only [params, backRest] using hs

/-- The row's forward acceptance at the admitted offset. -/
abbrev okRL (limit cap : Nat) := Disp.okJSJLimit PostOk.JR limit cap (okBackFXS setupP)

theorem simulationRQ (NB T : Nat) (tk : Nat → Nat) (limit cap : Nat) (hlimit : limit ≤ jsSignedLimit)
    (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF
      (Disp.FRJ (FRQ (FullRXD (params T tk) NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (okRL limit cap) (Disp.KpJ PostOk.JR cap) wideG [] (FlatFwd.VPin FlatFwd.Pin.post) := by
  have hj : PostOk.JR.okCall = okCallFXS (params T tk) :=
    (FlatFwd.okCallFXS_rest setupP (machReads T tk)).symm
  have hC : FfiCallSim FF (FullRXD (params T tk) NB) PostOk.JR.okCall smallFXS := by
    rw [hj]; exact fullCallSimXS (params T tk) NB
  have hQ := fullTargetPres (FR := FullRXD (params T tk) NB) fullRXD_ninv y0
  have hs := Disp.stepSimXLBJSLimit (P := PostOk.JR) (D0 := cap) (stk := [])
    (VBOk := FlatFwd.VPin FlatFwd.Pin.post) hlimit ((fullFfiSimXD (params T tk) NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS (params T tk) NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (fun _ _ _ _ _ hν hb => FlatFwd.smallFX2_sound hν hb)
    (fun _ _ _ _ hν hb => smallBackFB_sound hν.1 hb)
    (fullRXD_laws (params T tk) NB).liftQ fullLawful
    (fullNativeFactsXD (params T tk) NB PostOk.JR rfl rfl rfl).liftQ
    PostOk.wp
  simpa only [params, backRest, okRL] using hs

/-- `PostOk.okF0`: up to the shared cut. -/
noncomputable def modeOk0 (extra : List Nat) (NB T : Nat) (tk : Nat → Nat) (cap : Nat) (hcap : cap ≤ 4096 + 1593835520) : Mode (head extra) NB T tk cap where
  okS := PostOk.okF0 extra
  okT := Disp.okJSJLimit (PostOk.J0F extra) jsSignedLimit cap (okBackFXS setupP)
  Kp := Disp.KpJ (PostOk.J0F extra) cap
  Vp := PostHeadSmall.VP
  lift _ _ h := Disp.okJSJLimit_signed_of_allowance hcap h
  sim y0 := simulationQ NB T tk jsSignedLimit cap (Nat.le_refl _) [] y0 _ _ wideGPf (PostOk.wpF0 extra)
  ctx _ h := h
  vp h := ⟨h.valuation, h.rowValue⟩

/-- `PostOk.ok`. -/
noncomputable def modeOk (NB T : Nat) (tk : Nat → Nat) (cap : Nat) (hcap : cap ≤ 4096 + 1593835520) : Mode tail NB T tk cap where
  okS := PostOk.ok
  okT := Disp.okJSJLimit PostOk.J jsSignedLimit cap (okBackFXS setupP)
  Kp := Disp.KpJ PostOk.J cap
  Vp := PostHeadSmall.VP
  lift _ _ h := Disp.okJSJLimit_signed_of_allowance hcap h
  sim y0 := simulationQ NB T tk jsSignedLimit cap (Nat.le_refl _) [] y0 _ _ wideG PostOk.wp
  ctx _ h := h
  vp h := ⟨h.valuation, h.rowValue⟩

/-- `PostOk.okR`: a row's forward. -/
noncomputable def modeR (NB T : Nat) (tk : Nat → Nat) (cap : Nat) (hcap : cap ≤ 4096 + 1593835520) : Mode tail NB T tk cap where
  okS := PostOk.okR
  okT := okRL jsSignedLimit cap
  Kp := Disp.KpJ PostOk.JR cap
  Vp := FlatFwd.VPin FlatFwd.Pin.post
  lift _ _ h := Disp.okJSJLimit_signed_of_allowance hcap h
  sim y0 := simulationRQ NB T tk jsSignedLimit cap (Nat.le_refl _) y0
  ctx _ h := h
  vp h := ⟨h.valuation, pinPost h.rowValue h.dims⟩

/-- The rejection of a Neural Engine state survives any stretch that keeps the bridge. -/
theorem fresh_of {P : LoadP} {NB : Nat} {W W' : Nat → Option WFrame} {M M' : Map} {ν ν' : Nat → F64} {K K' : Ctx} {sa sb : St FF.S} {Sa Sb : SSrv}
    {t t' : St FF.S} {C C' : CSrv}
    (h0 : RelB FF (Disp.FRJ (FullRXD P NB)) W [] M ν K sa Sa t C)
    (h1 : RelB FF (Disp.FRJ (FullRXD P NB)) W' [] M' ν' K' sb Sb t' C')
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
variable {P : Stage} {NB T cap nI : Nat} {tk : Nat → Nat} {π : List Nat}

/-- The target's image of a checked stretch: a run, the map's extension, the relation at the end, the growth. -/
theorem stretch (m : Mode P NB T tk cap) {n : Nat} {γ : List Nat} {sa sb : St FF.S} {Sa Sb : SSrv} {x : SegInst FF}
    (ha : m.okS sa Sa = true) (hrun : runOk FF m.okS n sa Sa = some (sb, Sb)) (htop : noRetBlock sb = true)
    (hgood : ∀ ν, BookV P T tk π.length ν → Good ν Sa.oracle)
    (hr : RelB FF (Disp.FRJ (FullRXD (params T tk) NB)) P.W [] x.M x.ν x.K sa ⟨Sa.tab, []⟩ x.t x.C)
    (hb : Book P T tk cap nI π γ x) :
    ∃ M' t' C', runC FF n x.t x.C = some (t', C') ∧ Ext x.M M' Sa.tab.length ∧
      RelB FF (Disp.FRJ (FullRXD (params T tk) NB)) P.W [] M' x.ν x.K sb ⟨Sb.tab, []⟩ t' C' ∧
      Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf t'.ffi) := by
  have hq : RelB FF (Disp.FRJ (FRQ (FullRXD (params T tk) NB)
      fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))) P.W [] x.M x.ν x.K sa ⟨Sa.tab, []⟩ x.t x.C :=
    { hr with ffi := ⟨⟨hr.ffi.1, Host.Mlx.Ffi.NGrow.refl _⟩, hr.ffi.2⟩ }
  obtain ⟨M', t', C', hrun', he, hrel⟩ := D1Advance.run (m.sim (mlxOf x.t.ffi)) (m.ctx _ hb.context)
    (m.vp hb) (hgood x.ν hb.v) (m.lift _ _ ha) (runOk_mono (fun _ _ => m.lift _ _) hrun) htop hq
  exact ⟨M', t', C', hrun', he, { hrel with ffi := ⟨hrel.ffi.1.1, hrel.ffi.2⟩ }, hrel.ffi.1.2⟩

/-- `stretch`, and the step into a bridged call. -/
theorem stretchCall (m : Mode P NB T tk cap) {n : Nat} {γ : List Nat} {sa sb sc : St FF.S} {Sa Sb Sc : SSrv} {x : SegInst FF}
    (ha : m.okS sa Sa = true) (hrun : runOk FF m.okS n sa Sa = some (sb, Sb)) (hb' : m.okS sb Sb = true)
    (hh : isHalt sb.ctl = false) (hs : interpS (step FF sb).run Sb = some (sc, Sc)) (htop : noRetBlock sc = true)
    (hgood : ∀ ν, BookV P T tk π.length ν → Good ν Sa.oracle)
    (hr : RelB FF (Disp.FRJ (FullRXD (params T tk) NB)) P.W [] x.M x.ν x.K sa ⟨Sa.tab, []⟩ x.t x.C)
    (hb : Book P T tk cap nI π γ x) :
    ∃ M' t' C', runC FF (n + 1) x.t x.C = some (t', C') ∧ Ext x.M M' Sa.tab.length ∧
      RelB FF (Disp.FRJ (FullRXD (params T tk) NB)) P.W [] M' x.ν x.K sc ⟨Sc.tab, []⟩ t' C' ∧
      Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf t'.ffi) := by
  have hq : RelB FF (Disp.FRJ (FRQ (FullRXD (params T tk) NB)
      fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))) P.W [] x.M x.ν x.K sa ⟨Sa.tab, []⟩ x.t x.C :=
    { hr with ffi := ⟨⟨hr.ffi.1, Host.Mlx.Ffi.NGrow.refl _⟩, hr.ffi.2⟩ }
  obtain ⟨M', t', C', hrun', he, hrel⟩ := D1Advance.call (m.sim (mlxOf x.t.ffi)) (m.ctx _ hb.context)
    (m.vp hb) (hgood x.ν hb.v) (m.lift _ _ ha) (runOk_mono (fun _ _ => m.lift _ _) hrun)
    (m.lift _ _ hb') hh hs htop hq
  exact ⟨M', t', C', hrun', he, { hrel with ffi := ⟨hrel.ffi.1.1, hrel.ffi.2⟩ }, hrel.ffi.1.2⟩

/-- A stretch that pops nothing. -/
theorem glueM (m : Mode P NB T tk cap) {ok : St FF.S → SSrv → Bool} {n : Nat} {sa sb : St FF.S} {Sa Sb : SSrv} {Tr : SegInst FF → Prop}
    (ha : ok sa Sa = true) (hrun : runOk FF ok n sa Sa = some (sb, Sb)) (htop : noRetBlock sb = true)
    (hgood : ∀ ν, BookV P T tk π.length ν → Good ν Sa.oracle)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hcnt : countersOkB sa sb = true) (hT : ∀ x y, NTrackV x y → Tr x → Tr y) (hm : m.okS = ok) :
    CutStep (withMem Tr (indexedCutAt P NB T tk cap nI π sa Sa)) (withMem Tr (indexedCutAt P NB T tk cap nI π sb Sb)) n := by
  subst hm
  rintro t C ⟨x, rfl, rfl, ⟨γ, hr, hb⟩, ⟨hf, hanc, hnat⟩, htr⟩
  obtain ⟨M', t', C', hrun', he, hout, ng⟩ := stretch m ha hrun htop hgood hr hb
  exact ⟨t', C', hrun', ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl, ⟨γ, hout, hb.grow he ng (runC_le _ _ _ _ _ hrun')⟩,
    ⟨fresh_of hr hout hi hbr hf, ⟨(congrFun he.a 2586).trans hanc.1, (congrFun he.a 2589).trans hanc.2⟩,
      hnat.step rfl hr hout he.big he.node hcnt⟩,
    hT x _ ⟨⟨runC_le _ _ _ _ _ hrun', he.node, ng, tokens_of_grow hr hout ng (countersOkB_tokens hcnt), congrFun he.a 12504⟩, rfl⟩ htr⟩

/-- A stretch and the step into a bridged call, popping nothing. -/
theorem callM (m : Mode P NB T tk cap) {ok : St FF.S → SSrv → Bool} {n : Nat} {sa sb sc : St FF.S} {Sa Sb Sc : SSrv} {Tr : SegInst FF → Prop}
    (ha : ok sa Sa = true) (hrun : runOk FF ok n sa Sa = some (sb, Sb)) (hb' : ok sb Sb = true)
    (hh : isHalt sb.ctl = false) (hs : interpS (step FF sb).run Sb = some (sc, Sc)) (htop : noRetBlock sc = true)
    (hgood : ∀ ν, BookV P T tk π.length ν → Good ν Sa.oracle)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sc.ffi = bridgeOf sa.ffi)
    (hcnt : countersOkB sa sc = true) (hT : ∀ x y, NTrackV x y → Tr x → Tr y) (hm : m.okS = ok) :
    CutStep (withMem Tr (indexedCutAt P NB T tk cap nI π sa Sa)) (withMem Tr (indexedCutAt P NB T tk cap nI π sc Sc)) (n + 1) := by
  subst hm
  rintro t C ⟨x, rfl, rfl, ⟨γ, hr, hb⟩, ⟨hf, hanc, hnat⟩, htr⟩
  obtain ⟨M', t', C', hrun', he, hout, ng⟩ := stretchCall m ha hrun hb' hh hs htop hgood hr hb
  exact ⟨t', C', hrun', ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl, ⟨γ, hout, hb.grow he ng (runC_le _ _ _ _ _ hrun')⟩,
    ⟨fresh_of hr hout hi hbr hf, ⟨(congrFun he.a 2586).trans hanc.1, (congrFun he.a 2589).trans hanc.2⟩,
      hnat.step rfl hr hout he.big he.node hcnt⟩,
    hT x _ ⟨⟨runC_le _ _ _ _ _ hrun', he.node, ng, tokens_of_grow hr hout ng (countersOkB_tokens hcnt), congrFun he.a 12504⟩, rfl⟩ htr⟩

/-- A stretch that may pop a token: the bookkeeping changes by `hook`, from what the stretch's end knows. -/
theorem popM (m : Mode P NB T tk cap) {ok : St FF.S → SSrv → Bool} {n : Nat} {sa sb : St FF.S} {Sa Sb : SSrv} {Mem Mem' : SegInst FF → Prop}
    (ha : ok sa Sa = true) (hrun : runOk FF ok n sa Sa = some (sb, Sb)) (htop : noRetBlock sb = true)
    (hgood : ∀ ν, BookV P T tk π.length ν → Good ν Sa.oracle)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi) (hcnt : countersPopB sa sb = true)
    (hook : ∀ x y : SegInst FF, (indexedCutAt P NB T tk cap nI π sa Sa).R x sa ⟨Sa.tab, []⟩ →
      (indexedCutAt P NB T tk cap nI π sb Sb).R y sb ⟨Sb.tab, []⟩ → CSrv.Le x.C y.C → y.M.node = x.M.node → y.M.a 12504 = x.M.a 12504 →
      Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → Mem x → Mem' y) (hm : m.okS = ok) :
    CutStep (withMem Mem (indexedCutAt P NB T tk cap nI π sa Sa)) (withMem Mem' (indexedCutAt P NB T tk cap nI π sb Sb)) n := by
  subst hm
  rintro t C ⟨x, rfl, rfl, ⟨γ, hr, hb⟩, ⟨hf, hanc, hnat⟩, htr⟩
  obtain ⟨M', t', C', hrun', he, hout, ng⟩ := stretch m ha hrun htop hgood hr hb
  have hb' := hb.grow he ng (runC_le _ _ _ _ _ hrun')
  exact ⟨t', C', hrun', ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl, ⟨γ, hout, hb'⟩,
    ⟨fresh_of hr hout hi hbr hf, ⟨(congrFun he.a 2586).trans hanc.1, (congrFun he.a 2589).trans hanc.2⟩,
      NativeAt.stepPop hnat rfl hr hout he.big he.node hcnt⟩,
    hook x ⟨M', x.ν, x.K, t', C'⟩ ⟨γ, hr, hb⟩ ⟨γ, hout, hb'⟩ (runC_le _ _ _ _ _ hrun') he.node (congrFun he.a 12504) ng htr⟩

/-- The prompt's length: one target step, the value at `L`. -/
theorem lenM {sa sb : St FF.S} {Sa Sb : SSrv} {o : Obj} {Tr : SegInst FF → Prop}
    (hc : sa.ctl = .ret (.obj 2665)) (hst : sa.stack = .e (.member kLength false) :: sa.stack.tail)
    (ho : sa.obj? 2665 = some o) (hk : o.kind = .array ([] ++ ([] : List Val)))
    (hp : Bridge.lenPatch sa Sa (.var 9) = (sb, Sb))
    (hgood : ∀ ν, BookV P T tk π.length ν → Good ν Sa.oracle)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hcnt : countersOkB sa sb = true) (hT : ∀ x y, NTrackV x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCutAt P NB T tk cap nI π sa Sa)) (withMem Tr (indexedCutAt P NB T tk cap nI π sb Sb)) 1 := by
  rintro t C ⟨x, rfl, rfl, ⟨γ, hr, hb⟩, ⟨hf, hanc, hnat⟩, htr⟩
  have h0 : RelB FF (Disp.FRJ (FullRXD (params T tk) NB)) P.W [] x.M x.ν x.K sa ⟨Sa.tab, Sa.oracle⟩ x.t x.C :=
    hr.withOracle (hgood x.ν hb.v)
  have heval : (.var 9 : SymE).eval x.ν = F64.ofNat ((π.map natV).length + ([] : List Val).length) := by
    simpa only [SymE.eval, List.length_map, List.length_nil, Nat.add_zero] using hb.promptValue
  obtain ⟨step1, ext1, rel1⟩ := Disp.bridge_len h0.ofJ
    (fullRXD_laws (params T tk) NB) hc hst hb.prompt ho hk (.var 9) heval
  let M := x.M.setNum Sa.tab.length (.lit (F64.ofNat ((π.map natV).length + ([] : List Val).length)))
  let t' : St FF.S := { x.t with stack := sa.stack.tail.map x.M.frame ++ [] }.ret
    (natV ((π.map natV).length + ([] : List Val).length))
  have relp : RelB FF (FullRXD (params T tk) NB) P.W [] M x.ν x.K sb Sb t' x.C :=
    (congrArg (fun p : St FF.S × SSrv => RelB FF (FullRXD (params T tk) NB) P.W [] M x.ν x.K p.1 p.2 t' x.C) hp).mp rel1
  have relj := relp.toJ (h0.ffi.2.ext ext1)
  have rel' := relj.withOracle (o := []) (fun _ h => nomatch h)
  have ng : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf t'.ffi) := Host.Mlx.Ffi.NGrow.refl _
  have hbook : Book P T tk cap nI π γ ⟨M, x.ν, x.K, t', x.C⟩ := hb.grow ext1 ng (CSrv.Le.refl _)
  exact ⟨t', x.C, runC_one (by rw [h0.isHalt, hc]; rfl) step1, ⟨M, x.ν, x.K, t', x.C⟩, rfl, rfl, ⟨γ, rel', hbook⟩,
    ⟨fresh_of hr rel' hi hbr hf, ⟨(congrFun ext1.a 2586).trans hanc.1, (congrFun ext1.a 2589).trans hanc.2⟩,
      hnat.step rfl hr rel' ext1.big ext1.node hcnt⟩,
    hT x _ ⟨⟨CSrv.Le.refl _, ext1.node, ng, rfl, congrFun ext1.a 12504⟩, rfl⟩ htr⟩

end

end Host.Ts.Sim.Compose.Post

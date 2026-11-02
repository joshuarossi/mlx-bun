import host.route.cert.Dec.Final.Data
import host.sim.template.a4final4_eos0.Facts
import host.sim.template.EndGen
import host.sim.compose.Mach
import host.sim.template.a4final4_eos0.SpreadFacts
import host.sim.dispatch.BridgeSpread
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Route.Cert
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Layers
open Host.Load.Run.Prompt Host.Load.Run.Tpl
namespace Final4Eos0Data
open Final4Data
abbrev J := Final4Data.J
abbrev Q := Final4Data.Q
abbrev fr0 : List Nat := [2673448, 12504, 2665, 4910] ++ Host.Load.Run.Tpl.ghostAddrs
abbrev fr1 : List Nat := fr0 ++ [3123627]
def PromptQ (q : List Val) (ν : Nat → F64) (K : Ctx) : Prop :=
  Q fr0 ν K ∧ K.fr 2665 = some (arrOf Dec.s0 2665, q) ∧
    Final4Eos0.promptLen.eval ν = F64.ofNat q.length

theorem firstQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q))
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q)) 942
      Final4Eos0.s0 Final4Eos0.S0 Final4Eos0.s3 Final4Eos0.S3 := by
  let S := acc b0 NB fr0
  have p := PieceSim.ofRunOkW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.sim r) (fun _ _ h => h.1)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hok hrun hrc)
    Final4Eos0.ok0 Final4Eos0.runSeg0
  have l := PieceSim.ofLastW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.simL r) (fun _ _ h => h.1)
    (fun M ν K s t s1 t1 Sv Sv1 C C1 hq hr hh hok hs ht =>
      S.ngL r M ν K s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hh hok hs ht)
    Final4Eos0.ok1 Final4Eos0.halt1 Final4Eos0.stepA1
  have pre := (p.trans l (Nat.ble_eq.mp Final4Eos0.grow01)).trans
    (PieceSim.relOfXW (fun rs env fs h => by rw [Final4Eos0.stack1] at h; cases h))
    ((Nat.ble_eq.mp Final4Eos0.grow01).trans (Nat.ble_eq.mp Final4Eos0.grow12))
  have plen := lenPiece (Wd := fullWorldFb b0 NB) (A := addrPrompt) (P := Dec.Pw)
    (W := wideG) (r := r) (QA := PromptQ q) (QB := PromptQ q) (pre' := q) (xs := [])
    Final4Eos0.ctlA1 Final4Eos0.stack1 Final4Eos0.objA1 Final4Eos0.kind1
    (Option.some.inj Final4Eos0.patchB1) Final4Eos0.oracle3
    (fun _ _ h => h.2.1) (fun _ _ h => by simpa only [List.length_nil, Nat.add_zero] using h.2.2)
    (fun _ _ h => h)
    (fun t t' h => by show Host.Mlx.Ffi.NGrow _ _; rw [h]; exact Host.Mlx.Ffi.NGrow.refl _)
  exact pre.trans plen
    ((Nat.ble_eq.mp Final4Eos0.grow01).trans (Nat.ble_eq.mp Final4Eos0.grow12))

noncomputable def first (b0 : BSt) (NB : Nat) (q : List Val) :
    SPiece (haltLawsW (fullWorldFb b0 NB) addrPrompt) ((fullWorldFb b0 NB).R Dec.Pw) wideG
      ((fullWorldFb b0 NB).finalStartW Dec.s0 Dec.tab0.length) (Dec.tab0 ++ [.var 17]) (PromptQ q)
      Final4Eos0.s3 Final4Eos0.S3.tab (PromptQ q) := by
  have p := piece Final4Eos0.O Final4Eos0.oracle_exact (Nat.ble_eq.mp Final4Eos0.grow03)
    (fun r => firstQ b0 NB r q)
  have hs : Final4Eos0.s0 = (fullWorldFb b0 NB).finalStartW Dec.s0 Dec.tab0.length :=
    Final4Eos0.start_exact.trans rfl
  simpa only [hs, Final4Eos0.tab_exact] using p

theorem secondQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q))
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q)) 15
      Final4Eos0.s3 Final4Eos0.S3 Final4Eos0.s6 Final4Eos0.S6 := by
  let S := acc b0 NB fr0
  have p := PieceSim.ofRunOkW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.sim r) (fun _ _ h => h.1)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hok hrun hrc)
    Final4Eos0.ok3 Final4Eos0.runSeg1
  have l := PieceSim.ofLastW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.simL r) (fun _ _ h => h.1)
    (fun M ν K s t s1 t1 Sv Sv1 C C1 hq hr hh hok hs ht =>
      S.ngL r M ν K s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hh hok hs ht)
    Final4Eos0.ok4 Final4Eos0.halt4 Final4Eos0.stepA2
  have pre := (p.trans l (Nat.ble_eq.mp Final4Eos0.grow34)).trans
    (PieceSim.relOfXW (fun rs env fs h => by rw [Final4Eos0.stack2] at h; cases h))
    ((Nat.ble_eq.mp Final4Eos0.grow34).trans (Nat.ble_eq.mp Final4Eos0.grow45))
  have plen := lenPiece (Wd := fullWorldFb b0 NB) (A := addrPrompt) (P := Dec.Pw)
    (W := wideG) (r := r) (QA := PromptQ q) (QB := PromptQ q) (pre' := q) (xs := [])
    Final4Eos0.ctlA2 Final4Eos0.stack2 Final4Eos0.objA2 Final4Eos0.kind2
    (Option.some.inj Final4Eos0.patchB2) Final4Eos0.oracle6
    (fun _ _ h => h.2.1) (fun _ _ h => by simpa only [List.length_nil, Nat.add_zero] using h.2.2)
    (fun _ _ h => h)
    (fun t t' h => by show Host.Mlx.Ffi.NGrow _ _; rw [h]; exact Host.Mlx.Ffi.NGrow.refl _)
  exact pre.trans plen
    ((Nat.ble_eq.mp Final4Eos0.grow34).trans (Nat.ble_eq.mp Final4Eos0.grow45))

noncomputable def second (b0 : BSt) (NB : Nat) (q : List Val) :
    SPiece (haltLawsW (fullWorldFb b0 NB) addrPrompt) ((fullWorldFb b0 NB).R Dec.Pw) wideG
      Final4Eos0.s3 Final4Eos0.S3.tab (PromptQ q) Final4Eos0.s6 Final4Eos0.S6.tab (PromptQ q) :=
  piece [] Final4Eos0.oracle3 (Nat.ble_eq.mp Final4Eos0.grow36) (fun r => secondQ b0 NB r q)

def SpQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) : SRel FF := fun x s S =>
  RelSp FF (FLRb b0 Dec.Pw NB r) wideG [] x.M x.ν x.K
    (some ((arrOf Dec.s0 2665).reverse, q.reverse)) s S x.t x.C ∧ PromptQ q x.ν x.K

theorem spreadOpen (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q)) (SpQ b0 NB r q) 1
      Final4Eos0.spOpen Final4Eos0.spOpenSrv Final4Eos0.s7 Final4Eos0.S7 := by
  refine PieceSim.ofMSim Final4Eos0.spOpenStep fun x hx => ?_
  have hh : isHalt x.t.ctl = false := by rw [hx.1.ctl, Final4Eos0.spCtl]; rfl
  refine ⟨hh, ?_⟩
  have h := relB_withQ hx.1 (Q := fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))
    (Host.Mlx.Ffi.NGrow.refl _)
  have hm := Disp.step_spread_open h Final4Eos0.spCtl Final4Eos0.spStack hx.2.2.1 (by decide)
  exact hm.mono fun M' S' C' s' t' ⟨hg, hr⟩ =>
    ⟨hg, x.K, (haltLawsW (fullWorldFb b0 NB) addrPrompt).krefl _, hr.1.ffi.2,
      ⟨{ hr.1 with ffi := hr.1.ffi.1 }, hr.2⟩, hx.2⟩

kernel_rfl spCellNoG : Host.Load.Run.Tpl.wideG Final4Eos0.spCell = none

theorem spreadId (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt) (SpQ b0 NB r q) (SpQ b0 NB r q) 1
      Final4Eos0.s7 Final4Eos0.S7 Final4Eos0.s8 Final4Eos0.S8 := by
  refine PieceSim.ofMSim Final4Eos0.stepA3 fun x hx => ?_
  have hc := hx.1.1.ctl
  change x.t.ctl = _ at hc
  have hh : isHalt x.t.ctl = false := by rw [hc, Final4Eos0.spIdCtl]; rfl
  refine ⟨hh, ?_⟩
  have h : RelSp FF (FRQ (FLRb b0 Dec.Pw NB r)
      (fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))) wideG [] x.M x.ν x.K
      (some ((arrOf Dec.s0 2665).reverse, q.reverse)) Final4Eos0.s7 Final4Eos0.S7 x.t x.C :=
    ⟨relB_withQ hx.1.1 (Host.Mlx.Ffi.NGrow.refl _), hx.1.2⟩
  have hn : NoW x.K wideG Final4Eos0.s7 Final4Eos0.spCell := .inl spCellNoG
  have hm := Disp.step_id_spread h Final4Eos0.spIdCtl Final4Eos0.spLookup Final4Eos0.spCellVal hn
  exact hm.mono fun M' S' C' s' t' ⟨hg, hr⟩ =>
    ⟨hg, x.K, (haltLawsW (fullWorldFb b0 NB) addrPrompt).krefl _, hr.1.ffi.2,
      ⟨{ hr.1 with ffi := hr.1.ffi.1 }, hr.2⟩, hx.2⟩

theorem spreadClose (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt) (SpQ b0 NB r q)
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (Q fr1)) 1
      Final4Eos0.s8 Final4Eos0.S8 Final4Eos0.s9 Final4Eos0.S9 := by
  refine PieceSim.ofMSim Final4Eos0.stepB3 fun x hx => ?_
  have hc := hx.1.1.ctl
  change x.t.ctl = _ at hc
  have hh : isHalt x.t.ctl = false := by rw [hc, Final4Eos0.ctlA3]; rfl
  refine ⟨hh, ?_⟩
  have h : RelSp FF (FRQ (FLRb b0 Dec.Pw NB r)
      (fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))) wideG [] x.M x.ν x.K
      (some ((arrOf Dec.s0 2665).reverse, q.reverse)) Final4Eos0.s8 Final4Eos0.S8 x.t x.C :=
    ⟨relB_withQ hx.1.1 (Host.Mlx.Ffi.NGrow.refl _), hx.1.2⟩
  have hne : x.K.fr 2673448 ≠ none := (hx.2.1.1.2.2 2673448).2 (by decide)
  obtain ⟨⟨pre, pre'⟩, hf⟩ := Option.ne_none_iff_exists'.1 hne
  have hp : Present Final4Eos0.s8 aArrayProto := Final4Eos0.arrA3
  have hm := Disp.step_spread_close (A := []) h Final4Eos0.ctlA3 Final4Eos0.spCloseStack hf
    (Nat.blt_eq.mp Final4Eos0.roomA3_check) hp (by decide) (by rw [Final4Eos0.newA3]; decide)
  refine hm.mono fun M' S' C' s' t' ⟨hg, hr, hffi⟩ => ?_
  let K' := Disp.Ctx.frameAt x.K Final4Eos0.s8.next
    ((arrOf Dec.s0 2665).reverse.reverse ++ [].reverse ++ pre, q.reverse.reverse ++ x.M.vals [].reverse ++ pre')
  refine ⟨hg, K', ⟨rfl, rfl, ?_⟩, hr.ffi.2, ⟨{ hr with ffi := hr.ffi.1 }, ?_⟩⟩
  · exact Disp.Ctx.frameAt_ne x.K _ (by rw [Final4Eos0.newA3]; decide)
  · refine ⟨?_, hx.2.1.2⟩
    change Disp.Kp (J fr1) K'
    dsimp only [K']
    rw [Final4Eos0.newA3]
    exact kp_frameAtW (Wd := fullWorldFb b0 NB) (acc b0 NB fr0).hj (acc b0 NB fr1).hj hx.2.1.1 _

theorem thirdQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q))
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (Q fr1)) 37
      Final4Eos0.s6 Final4Eos0.S6 Final4Eos0.s9 Final4Eos0.S9 := by
  let S := acc b0 NB fr0
  have p := PieceSim.ofRunOkW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.sim r) (fun _ _ h => h.1)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hok hrun hrc)
    Final4Eos0.ok6 Final4Eos0.spRun
  have l := PieceSim.ofLastW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.simL r) (fun _ _ h => h.1)
    (fun M ν K s t s1 t1 Sv Sv1 C C1 hq hr hh hok hs ht =>
      S.ngL r M ν K s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hh hok hs ht)
    Final4Eos0.spOk Final4Eos0.spHalt Final4Eos0.spInto
  have p33 := (p.trans l (Nat.ble_eq.mp Final4Eos0.spGrowPre)).trans
    (PieceSim.relOfXW (fun rs env fs h => by rw [Final4Eos0.spStack] at h; cases h))
    ((Nat.ble_eq.mp Final4Eos0.spGrowPre).trans (Nat.ble_eq.mp Final4Eos0.spGrowOpen))
  exact p33.trans ((spreadOpen b0 NB r q).trans ((spreadId b0 NB r q).trans
    (spreadClose b0 NB r q) (Nat.ble_eq.mp Final4Eos0.spGrowClose))
    (Nat.ble_eq.mp Final4Eos0.spGrowId))
    ((Nat.ble_eq.mp Final4Eos0.spGrowPre).trans (Nat.ble_eq.mp Final4Eos0.spGrowOpen))

noncomputable def third (b0 : BSt) (NB : Nat) (q : List Val) :
    SPiece (haltLawsW (fullWorldFb b0 NB) addrPrompt) ((fullWorldFb b0 NB).R Dec.Pw) wideG
      Final4Eos0.s6 Final4Eos0.S6.tab (PromptQ q) Final4Eos0.s9 Final4Eos0.S9.tab (Q fr1) :=
  piece [] Final4Eos0.oracle6 (Nat.ble_eq.mp Final4Eos0.grow69) (fun r => thirdQ b0 NB r q)

noncomputable def fourth (b0 : BSt) (NB : Nat) :
    SPiece (haltLawsW (fullWorldFb b0 NB) addrPrompt) ((fullWorldFb b0 NB).R Dec.Pw) wideG
      Final4Eos0.s9 Final4Eos0.S9.tab (Q fr1) Final4Eos0.s10 Final4Eos0.S10.tab (Q fr1) := by
  let S := acc b0 NB fr1
  apply piece [] Final4Eos0.oracle9 (Nat.ble_eq.mp Final4Eos0.grow910)
  intro r
  exact PieceSim.ofRunOkRelW (S.sim r) (fun _ _ h => h)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1 hq.2 hr hok hrun hrc)
    Final4Eos0.ok9 Final4Eos0.runSeg3
    (fun v h => by rw [Final4Eos0.haltF] at h; cases h)
kernel_rfl stop_g0 : Host.Load.Run.Tpl.wideG Final4Eos0.gF = none
kernel_rfl stop_w0 : Host.Load.Run.Tpl.wideG Final4Eos0.wF = none

end Final4Eos0Data

/-- The final EOS branch without clear after the previous token at the current full-native entry. -/
noncomputable def DEC4.finalEos0 (b0 : BSt) (NB : Nat) (q : List Val) :
    Halt4W (fullWorldFb b0 NB) addrPrompt Dec.Pw wideG Dec.s0
      ((fullWorldFb b0 NB).finalStartW Dec.s0 Dec.tab0.length)
      (Dec.tab0 ++ [.var 17]) [.num (.ref 79)] where
  QA := Final4Eos0Data.PromptQ q
  s1 := Final4Eos0.s3
  t1 := Final4Eos0.S3.tab
  Q1 := Final4Eos0Data.PromptQ q
  s2 := Final4Eos0.s6
  t2 := Final4Eos0.S6.tab
  Q2 := Final4Eos0Data.PromptQ q
  s3 := Final4Eos0.s9
  t3 := Final4Eos0.S9.tab
  Q3 := Final4Eos0Data.Q Final4Eos0Data.fr1
  sE := Final4Eos0.s10
  tE := Final4Eos0.S10.tab
  QE := Final4Eos0Data.Q Final4Eos0Data.fr1
  p1 := Final4Eos0Data.first b0 NB q
  p2 := Final4Eos0Data.second b0 NB q
  p3 := Final4Eos0Data.third b0 NB q
  p4 := Final4Eos0Data.fourth b0 NB
  fin :=
    { halt := fun r x hx => ⟨x.M.val Final4Eos0.vF, by rw [hx.1.ctl, Final4Eos0.haltF]; rfl⟩
      emitG := ⟨_, Final4Eos0.emit_get, Final4Eos0.emit_kind⟩
      cell := Final4Eos0.cell }

theorem DEC4.finalEos0_finalOk (b0 : BSt) (NB : Nat) (q : List Val) :
    FinalEOk false (DEC4.finalEos0 b0 NB q).O := by
  change FinalEOk false Final4Eos0.O
  unfold FinalEOk
  decide +kernel

theorem DEC4.finalEos0_graph (b0 : BSt) (NB : Nat) (q : List Val) (r : List NumV) :
    LastGM Dec.inputs ((DEC4.finalEos0 b0 NB q).seg r) :=
  ⟨Final4Eos0.read, Final4Eos0.fed, Final4Eos0.read_present, Final4Eos0.fed_present,
    Final4Eos0.tokens, Final4Eos0.token_var, Final4Eos0.next_var⟩

theorem DEC4.finalEos0_len {ρ : Nat → F64} {T L : Nat} {tk : Nat → Nat}
    (hT : 3 ≤ T) (hctx : L + T ≤ 262144) :
    Final4Eos0.promptLen.eval (valL ρ T tk L (T - 2) (tk T)) = F64.ofNat L := by
  change F64.bin .sub (F64.bin .sub (F64.ofNat (L + (T - 2) + 1)) (F64.ofNat (T - 2)))
    (F64.ofNat 1) = F64.ofNat L
  rw [bin_sub_ofNat _ _ (by omega) (by omega), bin_sub_ofNat _ _ (by omega) (by omega)]
  congr 1
  omega

/-- Entry at the exact frame retained by the supported loop invariant. -/
theorem DEC4.finalEos0_entry (b0 : BSt) (NB : Nat)
    {ρ : Nat → F64} {T L : Nat} {tk : Nat → Nat} {q p1 : List Val} {K : Ctx} {toks : List NumV}
    (hVP : Host.Load.Run.Tpl.DecOk.VP (valL ρ T tk L (T - 2) (tk T)))
    (hT : 3 ≤ T) (hctx : L + T ≤ 262144) (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (hfr : K.fr = frA addrPrompt Dec.s0 (framesG Dec.s0 q).X p1
      ([.num (.ref 1)] ++ (toks.take (T - 3)).map Val.num))
    (hlen : q.length = L) (hlo : K.lo = Dec.Pw.lo) (hhi : K.hi = Dec.Pw.E) :
    (DEC4.finalEos0 b0 NB q).QA (valL ρ T tk L (T - 2) (tk T)) K := by
  refine ⟨⟨⟨hlo, hhi, ?_⟩, hVP⟩, ?_, ?_⟩
  · intro a
    rw [hfr]
    exact frA_ne_none addrPrompt Dec.s0 (framesG Dec.s0 q) p1 _ a
  · rw [hfr, frA_other addrPrompt Dec.s0 (framesG Dec.s0 q).X p1 _ (by decide) (by decide)]
    rfl
  · rw [hlen]
    exact DEC4.finalEos0_len hT hctx

/-- The actual final EOS selector supplies the original oracle independently of entry. -/
theorem DEC4.finalEos0_good (b0 : BSt) (NB : Nat) (q : List Val)
    {ρ : Nat → F64} {T L : Nat} {tk : Nat → Nat}
    (hT : 3 ≤ T) (hctx : L + T ≤ 262144) (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (htok : tk (T - 1) ≠ 248044) (hnext : tk T = 248044)
    (hrem : (T - 2) % 256 ≠ 0) :
    Good (valL ρ T tk L (T - 2) (tk T)) (DEC4.finalEos0 b0 NB q).O := by
  apply good_finalEW (DEC4.finalEos0_finalOk b0 NB q) (by omega) (by omega)
  · simpa only [show T - 2 + 1 = T - 1 by omega] using htok
  · exact hnext
  · omega
  · have := htv (T - 2 + 1) (by omega); omega
  · exact decide_eq_false hrem

theorem DEC4.finalEos0_stop (b0 : BSt) (NB : Nat) (q : List Val) :
    StopAtW (Wd := fullWorldFb b0 NB) wideG addrPrompt (DEC4.finalEos0 b0 NB q).sE :=
  ⟨by decide, Final4Eos0.gF, Final4Eos0.wF, Final4Eos0.stop_cell, Final4Eos0Data.stop_g0, Final4Eos0.stop_stats, Final4Eos0Data.stop_w0, Final4Eos0.stop_reason⟩

theorem DEC4.finalEos0_stopSrc (b0 : BSt) (NB : Nat) (q : List Val) (r : List NumV) :
    HaltStopSrc ((DEC4.finalEos0 b0 NB q).seg r) :=
  (DEC4.finalEos0 b0 NB q).stop (DEC4.finalEos0_stop b0 NB q) r

end Host.Ts.Sim.Compose

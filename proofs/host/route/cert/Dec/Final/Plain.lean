import host.route.cert.Dec.Final.Data
import host.sim.template.a4final4_plain.Facts
import host.sim.template.EndGen
import host.sim.compose.Mach
import host.sim.template.a4final4_plain.SpreadFacts
import host.sim.dispatch.BridgeSpread
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Route.Cert
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Layers
open Host.Load.Run.Prompt Host.Load.Run.Tpl
namespace Final4Data
abbrev fr0 : List Nat := [2673448, 12504, 2665, 4910] ++ Host.Load.Run.Tpl.ghostAddrs
abbrev fr1 : List Nat := fr0 ++ [3123642]
def PromptQ (q : List Val) (ν : Nat → F64) (K : Ctx) : Prop :=
  Q fr0 ν K ∧ K.fr 2665 = some (arrOf Dec.s0 2665, q) ∧
    Final4Plain.promptLen.eval ν = F64.ofNat q.length

theorem firstQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q))
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q)) 1119
      Final4Plain.s0 Final4Plain.S0 Final4Plain.s3 Final4Plain.S3 := by
  let S := acc b0 NB fr0
  have p := PieceSim.ofRunOkW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.sim r) (fun _ _ h => h.1)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hok hrun hrc)
    Final4Plain.ok0 Final4Plain.runSeg0
  have l := PieceSim.ofLastW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.simL r) (fun _ _ h => h.1)
    (fun M ν K s t s1 t1 Sv Sv1 C C1 hq hr hh hok hs ht =>
      S.ngL r M ν K s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hh hok hs ht)
    Final4Plain.ok1 Final4Plain.halt1 Final4Plain.stepA1
  have pre := (p.trans l (Nat.ble_eq.mp Final4Plain.grow01)).trans
    (PieceSim.relOfXW (fun rs env fs h => by rw [Final4Plain.stack1] at h; cases h))
    ((Nat.ble_eq.mp Final4Plain.grow01).trans (Nat.ble_eq.mp Final4Plain.grow12))
  have plen := lenPiece (Wd := fullWorldFb b0 NB) (A := addrPrompt) (P := Dec.Pw)
    (W := wideG) (r := r) (QA := PromptQ q) (QB := PromptQ q) (pre' := q) (xs := [])
    Final4Plain.ctlA1 Final4Plain.stack1 Final4Plain.objA1 Final4Plain.kind1
    (Option.some.inj Final4Plain.patchB1) Final4Plain.oracle3
    (fun _ _ h => h.2.1) (fun _ _ h => by simpa only [List.length_nil, Nat.add_zero] using h.2.2)
    (fun _ _ h => h)
    (fun t t' h => by show Host.Mlx.Ffi.NGrow _ _; rw [h]; exact Host.Mlx.Ffi.NGrow.refl _)
  exact pre.trans plen
    ((Nat.ble_eq.mp Final4Plain.grow01).trans (Nat.ble_eq.mp Final4Plain.grow12))

noncomputable def first (b0 : BSt) (NB : Nat) (q : List Val) :
    SPiece (haltLawsW (fullWorldFb b0 NB) addrPrompt) ((fullWorldFb b0 NB).R Dec.Pw) wideG
      ((fullWorldFb b0 NB).finalStartW Dec.s0 Dec.tab0.length) (Dec.tab0 ++ [.var 17]) (PromptQ q)
      Final4Plain.s3 Final4Plain.S3.tab (PromptQ q) := by
  have p := piece Final4Plain.O Final4Plain.oracle_exact (Nat.ble_eq.mp Final4Plain.grow03)
    (fun r => firstQ b0 NB r q)
  have hs : Final4Plain.s0 = (fullWorldFb b0 NB).finalStartW Dec.s0 Dec.tab0.length :=
    Final4Plain.start_exact.trans rfl
  simpa only [hs, Final4Plain.tab_exact] using p

theorem secondQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q))
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q)) 15
      Final4Plain.s3 Final4Plain.S3 Final4Plain.s6 Final4Plain.S6 := by
  let S := acc b0 NB fr0
  have p := PieceSim.ofRunOkW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.sim r) (fun _ _ h => h.1)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hok hrun hrc)
    Final4Plain.ok3 Final4Plain.runSeg1
  have l := PieceSim.ofLastW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.simL r) (fun _ _ h => h.1)
    (fun M ν K s t s1 t1 Sv Sv1 C C1 hq hr hh hok hs ht =>
      S.ngL r M ν K s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hh hok hs ht)
    Final4Plain.ok4 Final4Plain.halt4 Final4Plain.stepA2
  have pre := (p.trans l (Nat.ble_eq.mp Final4Plain.grow34)).trans
    (PieceSim.relOfXW (fun rs env fs h => by rw [Final4Plain.stack2] at h; cases h))
    ((Nat.ble_eq.mp Final4Plain.grow34).trans (Nat.ble_eq.mp Final4Plain.grow45))
  have plen := lenPiece (Wd := fullWorldFb b0 NB) (A := addrPrompt) (P := Dec.Pw)
    (W := wideG) (r := r) (QA := PromptQ q) (QB := PromptQ q) (pre' := q) (xs := [])
    Final4Plain.ctlA2 Final4Plain.stack2 Final4Plain.objA2 Final4Plain.kind2
    (Option.some.inj Final4Plain.patchB2) Final4Plain.oracle6
    (fun _ _ h => h.2.1) (fun _ _ h => by simpa only [List.length_nil, Nat.add_zero] using h.2.2)
    (fun _ _ h => h)
    (fun t t' h => by show Host.Mlx.Ffi.NGrow _ _; rw [h]; exact Host.Mlx.Ffi.NGrow.refl _)
  exact pre.trans plen
    ((Nat.ble_eq.mp Final4Plain.grow34).trans (Nat.ble_eq.mp Final4Plain.grow45))

noncomputable def second (b0 : BSt) (NB : Nat) (q : List Val) :
    SPiece (haltLawsW (fullWorldFb b0 NB) addrPrompt) ((fullWorldFb b0 NB).R Dec.Pw) wideG
      Final4Plain.s3 Final4Plain.S3.tab (PromptQ q) Final4Plain.s6 Final4Plain.S6.tab (PromptQ q) :=
  piece [] Final4Plain.oracle3 (Nat.ble_eq.mp Final4Plain.grow36) (fun r => secondQ b0 NB r q)

def SpQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) : SRel FF := fun x s S =>
  RelSp FF (FLRb b0 Dec.Pw NB r) wideG [] x.M x.ν x.K
    (some ((arrOf Dec.s0 2665).reverse, q.reverse)) s S x.t x.C ∧ PromptQ q x.ν x.K

theorem spreadOpen (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q)) (SpQ b0 NB r q) 1
      Final4Plain.spOpen Final4Plain.spOpenSrv Final4Plain.s7 Final4Plain.S7 := by
  refine PieceSim.ofMSim Final4Plain.spOpenStep fun x hx => ?_
  have hh : isHalt x.t.ctl = false := by rw [hx.1.ctl, Final4Plain.spCtl]; rfl
  refine ⟨hh, ?_⟩
  have h := relB_withQ hx.1 (Q := fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))
    (Host.Mlx.Ffi.NGrow.refl _)
  have hm := Disp.step_spread_open h Final4Plain.spCtl Final4Plain.spStack hx.2.2.1 (by decide)
  exact hm.mono fun M' S' C' s' t' ⟨hg, hr⟩ =>
    ⟨hg, x.K, (haltLawsW (fullWorldFb b0 NB) addrPrompt).krefl _, hr.1.ffi.2,
      ⟨{ hr.1 with ffi := hr.1.ffi.1 }, hr.2⟩, hx.2⟩

kernel_rfl spCellNoG : Host.Load.Run.Tpl.wideG Final4Plain.spCell = none

theorem spreadId (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt) (SpQ b0 NB r q) (SpQ b0 NB r q) 1
      Final4Plain.s7 Final4Plain.S7 Final4Plain.s8 Final4Plain.S8 := by
  refine PieceSim.ofMSim Final4Plain.stepA3 fun x hx => ?_
  have hc := hx.1.1.ctl
  change x.t.ctl = _ at hc
  have hh : isHalt x.t.ctl = false := by rw [hc, Final4Plain.spIdCtl]; rfl
  refine ⟨hh, ?_⟩
  have h : RelSp FF (FRQ (FLRb b0 Dec.Pw NB r)
      (fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))) wideG [] x.M x.ν x.K
      (some ((arrOf Dec.s0 2665).reverse, q.reverse)) Final4Plain.s7 Final4Plain.S7 x.t x.C :=
    ⟨relB_withQ hx.1.1 (Host.Mlx.Ffi.NGrow.refl _), hx.1.2⟩
  have hn : NoW x.K wideG Final4Plain.s7 Final4Plain.spCell := .inl spCellNoG
  have hm := Disp.step_id_spread h Final4Plain.spIdCtl Final4Plain.spLookup Final4Plain.spCellVal hn
  exact hm.mono fun M' S' C' s' t' ⟨hg, hr⟩ =>
    ⟨hg, x.K, (haltLawsW (fullWorldFb b0 NB) addrPrompt).krefl _, hr.1.ffi.2,
      ⟨{ hr.1 with ffi := hr.1.ffi.1 }, hr.2⟩, hx.2⟩

theorem spreadClose (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt) (SpQ b0 NB r q)
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (Q fr1)) 1
      Final4Plain.s8 Final4Plain.S8 Final4Plain.s9 Final4Plain.S9 := by
  refine PieceSim.ofMSim Final4Plain.stepB3 fun x hx => ?_
  have hc := hx.1.1.ctl
  change x.t.ctl = _ at hc
  have hh : isHalt x.t.ctl = false := by rw [hc, Final4Plain.ctlA3]; rfl
  refine ⟨hh, ?_⟩
  have h : RelSp FF (FRQ (FLRb b0 Dec.Pw NB r)
      (fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))) wideG [] x.M x.ν x.K
      (some ((arrOf Dec.s0 2665).reverse, q.reverse)) Final4Plain.s8 Final4Plain.S8 x.t x.C :=
    ⟨relB_withQ hx.1.1 (Host.Mlx.Ffi.NGrow.refl _), hx.1.2⟩
  have hne : x.K.fr 2673448 ≠ none := (hx.2.1.1.2.2 2673448).2 (by decide)
  obtain ⟨⟨pre, pre'⟩, hf⟩ := Option.ne_none_iff_exists'.1 hne
  have hp : Present Final4Plain.s8 aArrayProto := Final4Plain.arrA3
  have hm := Disp.step_spread_close (A := []) h Final4Plain.ctlA3 Final4Plain.spCloseStack hf
    (Nat.blt_eq.mp Final4Plain.roomA3_check) hp (by decide) (by rw [Final4Plain.newA3]; decide)
  refine hm.mono fun M' S' C' s' t' ⟨hg, hr, hffi⟩ => ?_
  let K' := Disp.Ctx.frameAt x.K Final4Plain.s8.next
    ((arrOf Dec.s0 2665).reverse.reverse ++ [].reverse ++ pre, q.reverse.reverse ++ x.M.vals [].reverse ++ pre')
  refine ⟨hg, K', ⟨rfl, rfl, ?_⟩, hr.ffi.2, ⟨{ hr with ffi := hr.ffi.1 }, ?_⟩⟩
  · exact Disp.Ctx.frameAt_ne x.K _ (by rw [Final4Plain.newA3]; decide)
  · refine ⟨?_, hx.2.1.2⟩
    change Disp.Kp (J fr1) K'
    dsimp only [K']
    rw [Final4Plain.newA3]
    exact kp_frameAtW (Wd := fullWorldFb b0 NB) (acc b0 NB fr0).hj (acc b0 NB fr1).hj hx.2.1.1 _

theorem thirdQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q))
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (Q fr1)) 36
      Final4Plain.s6 Final4Plain.S6 Final4Plain.s9 Final4Plain.S9 := by
  let S := acc b0 NB fr0
  have p := PieceSim.ofRunOkW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.sim r) (fun _ _ h => h.1)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hok hrun hrc)
    Final4Plain.ok6 Final4Plain.spRun
  have l := PieceSim.ofLastW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.simL r) (fun _ _ h => h.1)
    (fun M ν K s t s1 t1 Sv Sv1 C C1 hq hr hh hok hs ht =>
      S.ngL r M ν K s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hh hok hs ht)
    Final4Plain.spOk Final4Plain.spHalt Final4Plain.spInto
  have p33 := (p.trans l (Nat.ble_eq.mp Final4Plain.spGrowPre)).trans
    (PieceSim.relOfXW (fun rs env fs h => by rw [Final4Plain.spStack] at h; cases h))
    ((Nat.ble_eq.mp Final4Plain.spGrowPre).trans (Nat.ble_eq.mp Final4Plain.spGrowOpen))
  exact p33.trans ((spreadOpen b0 NB r q).trans ((spreadId b0 NB r q).trans
    (spreadClose b0 NB r q) (Nat.ble_eq.mp Final4Plain.spGrowClose))
    (Nat.ble_eq.mp Final4Plain.spGrowId))
    ((Nat.ble_eq.mp Final4Plain.spGrowPre).trans (Nat.ble_eq.mp Final4Plain.spGrowOpen))

noncomputable def third (b0 : BSt) (NB : Nat) (q : List Val) :
    SPiece (haltLawsW (fullWorldFb b0 NB) addrPrompt) ((fullWorldFb b0 NB).R Dec.Pw) wideG
      Final4Plain.s6 Final4Plain.S6.tab (PromptQ q) Final4Plain.s9 Final4Plain.S9.tab (Q fr1) :=
  piece [] Final4Plain.oracle6 (Nat.ble_eq.mp Final4Plain.grow69) (fun r => thirdQ b0 NB r q)

noncomputable def fourth (b0 : BSt) (NB : Nat) :
    SPiece (haltLawsW (fullWorldFb b0 NB) addrPrompt) ((fullWorldFb b0 NB).R Dec.Pw) wideG
      Final4Plain.s9 Final4Plain.S9.tab (Q fr1) Final4Plain.s10 Final4Plain.S10.tab (Q fr1) := by
  let S := acc b0 NB fr1
  apply piece [] Final4Plain.oracle9 (Nat.ble_eq.mp Final4Plain.grow910)
  intro r
  exact PieceSim.ofRunOkRelW (S.sim r) (fun _ _ h => h)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1 hq.2 hr hok hrun hrc)
    Final4Plain.ok9 Final4Plain.runSeg3
    (fun v h => by rw [Final4Plain.haltF] at h; cases h)
end Final4Data

/-- The ordinary final branch at the current full-native decode entry. -/
noncomputable def DEC4.finalPlain (b0 : BSt) (NB : Nat) (q : List Val) :
    Halt4W (fullWorldFb b0 NB) addrPrompt Dec.Pw wideG Dec.s0
      ((fullWorldFb b0 NB).finalStartW Dec.s0 Dec.tab0.length)
      (Dec.tab0 ++ [.var 17]) [.num (.ref 79), .num (.ref Dec.tab0.length)] where
  QA := Final4Data.PromptQ q
  s1 := Final4Plain.s3
  t1 := Final4Plain.S3.tab
  Q1 := Final4Data.PromptQ q
  s2 := Final4Plain.s6
  t2 := Final4Plain.S6.tab
  Q2 := Final4Data.PromptQ q
  s3 := Final4Plain.s9
  t3 := Final4Plain.S9.tab
  Q3 := Final4Data.Q Final4Data.fr1
  sE := Final4Plain.s10
  tE := Final4Plain.S10.tab
  QE := Final4Data.Q Final4Data.fr1
  p1 := Final4Data.first b0 NB q
  p2 := Final4Data.second b0 NB q
  p3 := Final4Data.third b0 NB q
  p4 := Final4Data.fourth b0 NB
  fin :=
    { halt := fun r x hx => ⟨x.M.val Final4Plain.vF, by rw [hx.1.ctl, Final4Plain.haltF]; rfl⟩
      emitG := ⟨_, Final4Plain.emit_get, Final4Plain.emit_kind⟩
      cell := Final4Plain.cell }

theorem DEC4.finalPlain_finalOk (b0 : BSt) (NB : Nat) (q : List Val) :
    FinalOk false false (DEC4.finalPlain b0 NB q).O := by
  change FinalOk false false Final4Plain.O
  unfold FinalOk
  decide +kernel

theorem DEC4.finalPlain_graph (b0 : BSt) (NB : Nat) (q : List Val) (r : List NumV) :
    LastGM Dec.inputs ((DEC4.finalPlain b0 NB q).seg r) :=
  ⟨Final4Plain.read, Final4Plain.fed, Final4Plain.read_present, Final4Plain.fed_present,
    Final4Plain.tokens, Final4Plain.token_var, Final4Plain.next_var⟩

theorem DEC4.finalPlain_len {ρ : Nat → F64} {T L : Nat} {tk : Nat → Nat}
    (hT : 3 ≤ T) (hctx : L + T ≤ 262144) :
    Final4Plain.promptLen.eval (valL ρ T tk L (T - 2) (tk T)) = F64.ofNat L := by
  change F64.bin .sub (F64.bin .sub (F64.ofNat (L + (T - 2) + 1)) (F64.ofNat (T - 2)))
    (F64.ofNat 1) = F64.ofNat L
  rw [bin_sub_ofNat _ _ (by omega) (by omega), bin_sub_ofNat _ _ (by omega) (by omega)]
  congr 1
  omega

/-- Entry at the exact frame retained by the supported loop invariant. -/
theorem DEC4.finalPlain_entry (b0 : BSt) (NB : Nat)
    {ρ : Nat → F64} {T L : Nat} {tk : Nat → Nat} {q p1 : List Val} {K : Ctx} {toks : List NumV}
    (hVP : Host.Load.Run.Tpl.DecOk.VP (valL ρ T tk L (T - 2) (tk T)))
    (hT : 3 ≤ T) (hctx : L + T ≤ 262144) (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (hfr : K.fr = frA addrPrompt Dec.s0 (framesG Dec.s0 q).X p1
      ([.num (.ref 1)] ++ (toks.take (T - 3)).map Val.num))
    (hlen : q.length = L) (hlo : K.lo = Dec.Pw.lo) (hhi : K.hi = Dec.Pw.E) :
    (DEC4.finalPlain b0 NB q).QA (valL ρ T tk L (T - 2) (tk T)) K := by
  refine ⟨⟨⟨hlo, hhi, ?_⟩, hVP⟩, ?_, ?_⟩
  · intro a
    rw [hfr]
    exact frA_ne_none addrPrompt Dec.s0 (framesG Dec.s0 q) p1 _ a
  · rw [hfr, frA_other addrPrompt Dec.s0 (framesG Dec.s0 q).X p1 _ (by decide) (by decide)]
    rfl
  · rw [hlen]
    exact DEC4.finalPlain_len hT hctx


end Host.Ts.Sim.Compose

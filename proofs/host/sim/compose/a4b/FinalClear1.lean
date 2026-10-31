import host.sim.compose.a4b.FinalPlainData
import host.sim.template.a4final_clear1.Facts
import host.sim.template.EndGen
import host.sim.compose.Mach
import host.sim.template.a4final_clear1.SpreadFacts
import host.sim.dispatch.BridgeSpread
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Layers
open Host.Load.Run.Prompt Host.Load.Run.Tpl
namespace FinalClear1Data
open FinalPlainData
abbrev J := FinalPlainData.J
abbrev Q := FinalPlainData.Q
abbrev fr0 : List Nat := [2673448, 12504, 2665, 4910]
abbrev fr1 : List Nat := fr0 ++ [3123643]
def PromptQ (q : List Val) (ν : Nat → F64) (K : Ctx) : Prop :=
  Q fr0 ν K ∧ K.fr 2665 = some (arrOf DEC.s0 2665, q) ∧
    FinalClear1.promptLen.eval ν = F64.ofNat q.length

theorem firstQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 DEC.Pw NB r) wideP (PromptQ q))
      (relQW FF (FLRb b0 DEC.Pw NB r) wideP (PromptQ q)) 1135
      FinalClear1.s0 FinalClear1.S0 FinalClear1.s3 FinalClear1.S3 := by
  let S := acc b0 NB fr0
  have p := PieceSim.ofRunOkW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.sim r) (fun _ _ h => h.1)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hok hrun hrc)
    FinalClear1.ok0 FinalClear1.runSeg0
  have l := PieceSim.ofLastW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.simL r) (fun _ _ h => h.1)
    (fun M ν K s t s1 t1 Sv Sv1 C C1 hq hr hh hok hs ht =>
      S.ngL r M ν K s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hh hok hs ht)
    FinalClear1.ok1 FinalClear1.halt1 FinalClear1.stepA1
  have pre := (p.trans l (Nat.ble_eq.mp FinalClear1.grow01)).trans
    (PieceSim.relOfXW (fun rs env fs h => by rw [FinalClear1.stack1] at h; cases h))
    ((Nat.ble_eq.mp FinalClear1.grow01).trans (Nat.ble_eq.mp FinalClear1.grow12))
  have plen := lenPiece (Wd := fullWorldFb b0 NB) (A := addrPrompt) (P := DEC.Pw)
    (W := wideP) (r := r) (QA := PromptQ q) (QB := PromptQ q) (pre' := q) (xs := [])
    FinalClear1.ctlA1 FinalClear1.stack1 FinalClear1.objA1 FinalClear1.kind1
    (Option.some.inj FinalClear1.patchB1) FinalClear1.oracle3
    (fun _ _ h => h.2.1) (fun _ _ h => by simpa only [List.length_nil, Nat.add_zero] using h.2.2)
    (fun _ _ h => h)
    (fun t t' h => by show Host.Mlx.Ffi.NGrow _ _; rw [h]; exact Host.Mlx.Ffi.NGrow.refl _)
  exact pre.trans plen
    ((Nat.ble_eq.mp FinalClear1.grow01).trans (Nat.ble_eq.mp FinalClear1.grow12))

noncomputable def first (b0 : BSt) (NB : Nat) (q : List Val) :
    SPiece (haltLawsW (fullWorldFb b0 NB) addrPrompt) ((fullWorldFb b0 NB).R DEC.Pw) wideP
      ((fullWorldFb b0 NB).finalStartW DEC.s0 DEC.tab0.length) (DEC.tab0 ++ [.var 17]) (PromptQ q)
      FinalClear1.s3 FinalClear1.S3.tab (PromptQ q) := by
  have p := piece FinalClear1.O FinalClear1.oracle_exact (Nat.ble_eq.mp FinalClear1.grow03)
    (fun r => firstQ b0 NB r q)
  have hs : FinalClear1.s0 = (fullWorldFb b0 NB).finalStartW DEC.s0 DEC.tab0.length :=
    FinalClear1.start_exact.trans rfl
  simpa only [hs, FinalClear1.tab_exact] using p

theorem secondQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 DEC.Pw NB r) wideP (PromptQ q))
      (relQW FF (FLRb b0 DEC.Pw NB r) wideP (PromptQ q)) 15
      FinalClear1.s3 FinalClear1.S3 FinalClear1.s6 FinalClear1.S6 := by
  let S := acc b0 NB fr0
  have p := PieceSim.ofRunOkW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.sim r) (fun _ _ h => h.1)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hok hrun hrc)
    FinalClear1.ok3 FinalClear1.runSeg1
  have l := PieceSim.ofLastW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.simL r) (fun _ _ h => h.1)
    (fun M ν K s t s1 t1 Sv Sv1 C C1 hq hr hh hok hs ht =>
      S.ngL r M ν K s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hh hok hs ht)
    FinalClear1.ok4 FinalClear1.halt4 FinalClear1.stepA2
  have pre := (p.trans l (Nat.ble_eq.mp FinalClear1.grow34)).trans
    (PieceSim.relOfXW (fun rs env fs h => by rw [FinalClear1.stack2] at h; cases h))
    ((Nat.ble_eq.mp FinalClear1.grow34).trans (Nat.ble_eq.mp FinalClear1.grow45))
  have plen := lenPiece (Wd := fullWorldFb b0 NB) (A := addrPrompt) (P := DEC.Pw)
    (W := wideP) (r := r) (QA := PromptQ q) (QB := PromptQ q) (pre' := q) (xs := [])
    FinalClear1.ctlA2 FinalClear1.stack2 FinalClear1.objA2 FinalClear1.kind2
    (Option.some.inj FinalClear1.patchB2) FinalClear1.oracle6
    (fun _ _ h => h.2.1) (fun _ _ h => by simpa only [List.length_nil, Nat.add_zero] using h.2.2)
    (fun _ _ h => h)
    (fun t t' h => by show Host.Mlx.Ffi.NGrow _ _; rw [h]; exact Host.Mlx.Ffi.NGrow.refl _)
  exact pre.trans plen
    ((Nat.ble_eq.mp FinalClear1.grow34).trans (Nat.ble_eq.mp FinalClear1.grow45))

noncomputable def second (b0 : BSt) (NB : Nat) (q : List Val) :
    SPiece (haltLawsW (fullWorldFb b0 NB) addrPrompt) ((fullWorldFb b0 NB).R DEC.Pw) wideP
      FinalClear1.s3 FinalClear1.S3.tab (PromptQ q) FinalClear1.s6 FinalClear1.S6.tab (PromptQ q) :=
  piece [] FinalClear1.oracle3 (Nat.ble_eq.mp FinalClear1.grow36) (fun r => secondQ b0 NB r q)

def SpQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) : SRel FF := fun x s S =>
  RelSp FF (FLRb b0 DEC.Pw NB r) wideP [] x.M x.ν x.K
    (some ((arrOf DEC.s0 2665).reverse, q.reverse)) s S x.t x.C ∧ PromptQ q x.ν x.K

theorem spreadOpen (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 DEC.Pw NB r) wideP (PromptQ q)) (SpQ b0 NB r q) 1
      FinalClear1.spOpen FinalClear1.spOpenSrv FinalClear1.s7 FinalClear1.S7 := by
  refine PieceSim.ofMSim FinalClear1.spOpenStep fun x hx => ?_
  have hh : isHalt x.t.ctl = false := by rw [hx.1.ctl, FinalClear1.spCtl]; rfl
  refine ⟨hh, ?_⟩
  have h := relB_withQ hx.1 (Q := fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))
    (Host.Mlx.Ffi.NGrow.refl _)
  have hm := Disp.step_spread_open h FinalClear1.spCtl FinalClear1.spStack hx.2.2.1 (by decide)
  exact hm.mono fun M' S' C' s' t' ⟨hg, hr⟩ =>
    ⟨hg, x.K, (haltLawsW (fullWorldFb b0 NB) addrPrompt).krefl _, hr.1.ffi.2,
      ⟨{ hr.1 with ffi := hr.1.ffi.1 }, hr.2⟩, hx.2⟩

theorem spreadId (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt) (SpQ b0 NB r q) (SpQ b0 NB r q) 1
      FinalClear1.s7 FinalClear1.S7 FinalClear1.s8 FinalClear1.S8 := by
  refine PieceSim.ofMSim FinalClear1.stepA3 fun x hx => ?_
  have hc := hx.1.1.ctl
  change x.t.ctl = _ at hc
  have hh : isHalt x.t.ctl = false := by rw [hc, FinalClear1.spIdCtl]; rfl
  refine ⟨hh, ?_⟩
  have h : RelSp FF (FRQ (FLRb b0 DEC.Pw NB r)
      (fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))) wideP [] x.M x.ν x.K
      (some ((arrOf DEC.s0 2665).reverse, q.reverse)) FinalClear1.s7 FinalClear1.S7 x.t x.C :=
    ⟨relB_withQ hx.1.1 (Host.Mlx.Ffi.NGrow.refl _), hx.1.2⟩
  have hn : NoW x.K wideP FinalClear1.s7 FinalClear1.spCell := .inl (by
    change (bif Nat.beq FinalClear1.spCell 4910 then some (.memo []) else none) = none
    rw [FinalClear1.spCellNoW]; rfl)
  have hm := Disp.step_id_spread h FinalClear1.spIdCtl FinalClear1.spLookup FinalClear1.spCellVal hn
  exact hm.mono fun M' S' C' s' t' ⟨hg, hr⟩ =>
    ⟨hg, x.K, (haltLawsW (fullWorldFb b0 NB) addrPrompt).krefl _, hr.1.ffi.2,
      ⟨{ hr.1 with ffi := hr.1.ffi.1 }, hr.2⟩, hx.2⟩

theorem spreadClose (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt) (SpQ b0 NB r q)
      (relQW FF (FLRb b0 DEC.Pw NB r) wideP (Q fr1)) 1
      FinalClear1.s8 FinalClear1.S8 FinalClear1.s9 FinalClear1.S9 := by
  refine PieceSim.ofMSim FinalClear1.stepB3 fun x hx => ?_
  have hc := hx.1.1.ctl
  change x.t.ctl = _ at hc
  have hh : isHalt x.t.ctl = false := by rw [hc, FinalClear1.ctlA3]; rfl
  refine ⟨hh, ?_⟩
  have h : RelSp FF (FRQ (FLRb b0 DEC.Pw NB r)
      (fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))) wideP [] x.M x.ν x.K
      (some ((arrOf DEC.s0 2665).reverse, q.reverse)) FinalClear1.s8 FinalClear1.S8 x.t x.C :=
    ⟨relB_withQ hx.1.1 (Host.Mlx.Ffi.NGrow.refl _), hx.1.2⟩
  have hne : x.K.fr 2673448 ≠ none := (hx.2.1.1.2.2 2673448).2 (by decide)
  obtain ⟨⟨pre, pre'⟩, hf⟩ := Option.ne_none_iff_exists'.1 hne
  have hp : Present FinalClear1.s8 aArrayProto := FinalClear1.arrA3
  have hm := Disp.step_spread_close (A := []) h FinalClear1.ctlA3 FinalClear1.spCloseStack hf
    (Nat.blt_eq.mp FinalClear1.roomA3_check) hp (by decide) (by rw [FinalClear1.newA3]; decide)
  refine hm.mono fun M' S' C' s' t' ⟨hg, hr, hffi⟩ => ?_
  let K' := Disp.Ctx.frameAt x.K FinalClear1.s8.next
    ((arrOf DEC.s0 2665).reverse.reverse ++ [].reverse ++ pre, q.reverse.reverse ++ x.M.vals [].reverse ++ pre')
  refine ⟨hg, K', ⟨rfl, rfl, ?_⟩, hr.ffi.2, ⟨{ hr with ffi := hr.ffi.1 }, ?_⟩⟩
  · exact Disp.Ctx.frameAt_ne x.K _ (by rw [FinalClear1.newA3]; decide)
  · refine ⟨?_, hx.2.1.2⟩
    change Disp.Kp (J fr1) K'
    dsimp only [K']
    rw [FinalClear1.newA3]
    exact kp_frameAtW (Wd := fullWorldFb b0 NB) (acc b0 NB fr0).hj (acc b0 NB fr1).hj hx.2.1.1 _

theorem thirdQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 DEC.Pw NB r) wideP (PromptQ q))
      (relQW FF (FLRb b0 DEC.Pw NB r) wideP (Q fr1)) 36
      FinalClear1.s6 FinalClear1.S6 FinalClear1.s9 FinalClear1.S9 := by
  let S := acc b0 NB fr0
  have p := PieceSim.ofRunOkW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.sim r) (fun _ _ h => h.1)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hok hrun hrc)
    FinalClear1.ok6 FinalClear1.spRun
  have l := PieceSim.ofLastW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.simL r) (fun _ _ h => h.1)
    (fun M ν K s t s1 t1 Sv Sv1 C C1 hq hr hh hok hs ht =>
      S.ngL r M ν K s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hh hok hs ht)
    FinalClear1.spOk FinalClear1.spHalt FinalClear1.spInto
  have p33 := (p.trans l (Nat.ble_eq.mp FinalClear1.spGrowPre)).trans
    (PieceSim.relOfXW (fun rs env fs h => by rw [FinalClear1.spStack] at h; cases h))
    ((Nat.ble_eq.mp FinalClear1.spGrowPre).trans (Nat.ble_eq.mp FinalClear1.spGrowOpen))
  exact p33.trans ((spreadOpen b0 NB r q).trans ((spreadId b0 NB r q).trans
    (spreadClose b0 NB r q) (Nat.ble_eq.mp FinalClear1.spGrowClose))
    (Nat.ble_eq.mp FinalClear1.spGrowId))
    ((Nat.ble_eq.mp FinalClear1.spGrowPre).trans (Nat.ble_eq.mp FinalClear1.spGrowOpen))

noncomputable def third (b0 : BSt) (NB : Nat) (q : List Val) :
    SPiece (haltLawsW (fullWorldFb b0 NB) addrPrompt) ((fullWorldFb b0 NB).R DEC.Pw) wideP
      FinalClear1.s6 FinalClear1.S6.tab (PromptQ q) FinalClear1.s9 FinalClear1.S9.tab (Q fr1) :=
  piece [] FinalClear1.oracle6 (Nat.ble_eq.mp FinalClear1.grow69) (fun r => thirdQ b0 NB r q)

noncomputable def fourth (b0 : BSt) (NB : Nat) :
    SPiece (haltLawsW (fullWorldFb b0 NB) addrPrompt) ((fullWorldFb b0 NB).R DEC.Pw) wideP
      FinalClear1.s9 FinalClear1.S9.tab (Q fr1) FinalClear1.s10 FinalClear1.S10.tab (Q fr1) := by
  let S := acc b0 NB fr1
  apply piece [] FinalClear1.oracle9 (Nat.ble_eq.mp FinalClear1.grow910)
  intro r
  exact PieceSim.ofRunOkRelW (S.sim r) (fun _ _ h => h)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1 hq.2 hr hok hrun hrc)
    FinalClear1.ok9 FinalClear1.runSeg3
    (fun v h => by rw [FinalClear1.haltF] at h; cases h)
end FinalClear1Data

/-- The final branch with clear after the last token at the current full-native decode entry. -/
noncomputable def DEC.finalClear1 (b0 : BSt) (NB : Nat) (q : List Val) :
    Halt4W (fullWorldFb b0 NB) addrPrompt DEC.Pw wideP DEC.s0
      ((fullWorldFb b0 NB).finalStartW DEC.s0 DEC.tab0.length)
      (DEC.tab0 ++ [.var 17]) [.num (.ref 79), .num (.ref DEC.tab0.length)] where
  QA := FinalClear1Data.PromptQ q
  s1 := FinalClear1.s3
  t1 := FinalClear1.S3.tab
  Q1 := FinalClear1Data.PromptQ q
  s2 := FinalClear1.s6
  t2 := FinalClear1.S6.tab
  Q2 := FinalClear1Data.PromptQ q
  s3 := FinalClear1.s9
  t3 := FinalClear1.S9.tab
  Q3 := FinalClear1Data.Q FinalClear1Data.fr1
  sE := FinalClear1.s10
  tE := FinalClear1.S10.tab
  QE := FinalClear1Data.Q FinalClear1Data.fr1
  p1 := FinalClear1Data.first b0 NB q
  p2 := FinalClear1Data.second b0 NB q
  p3 := FinalClear1Data.third b0 NB q
  p4 := FinalClear1Data.fourth b0 NB
  fin :=
    { halt := fun r x hx => ⟨x.M.val FinalClear1.vF, by rw [hx.1.ctl, FinalClear1.haltF]; rfl⟩
      emitG := ⟨_, FinalClear1.emit_get, FinalClear1.emit_kind⟩
      cell := FinalClear1.cell }

theorem DEC.finalClear1_finalOk (b0 : BSt) (NB : Nat) (q : List Val) :
    FinalOk false true (DEC.finalClear1 b0 NB q).O := by
  change FinalOk false true FinalClear1.O
  unfold FinalOk
  decide +kernel

theorem DEC.finalClear1_graph (b0 : BSt) (NB : Nat) (q : List Val) (r : List NumV) :
    LastGM DEC.inputs ((DEC.finalClear1 b0 NB q).seg r) :=
  ⟨FinalClear1.read, FinalClear1.fed, FinalClear1.read_present, FinalClear1.fed_present,
    FinalClear1.tokens, FinalClear1.token_var, FinalClear1.next_var⟩

theorem DEC.finalClear1_len {ρ : Nat → F64} {T L : Nat} {tk : Nat → Nat}
    (hT : 3 ≤ T) (hctx : L + T ≤ 262144) :
    FinalClear1.promptLen.eval (valL ρ T tk L (T - 2) (tk T)) = F64.ofNat L := by
  change F64.bin .sub (F64.bin .sub (F64.ofNat (L + (T - 2) + 1)) (F64.ofNat (T - 2)))
    (F64.ofNat 1) = F64.ofNat L
  rw [bin_sub_ofNat _ _ (by omega) (by omega), bin_sub_ofNat _ _ (by omega) (by omega)]
  congr 1
  omega

/-- Entry at the exact frame retained by the supported loop invariant. -/
theorem DEC.finalClear1_entry (b0 : BSt) (NB : Nat)
    {ρ : Nat → F64} {T L : Nat} {tk : Nat → Nat} {q p1 : List Val} {K : Ctx} {toks : List NumV}
    (hρ : ∀ j, ∃ n ≤ 2 ^ 20, ρ j = F64.ofNat n)
    (hT : 3 ≤ T) (hctx : L + T ≤ 262144) (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (hfr : K.fr = frA addrPrompt DEC.s0 (framesP DEC.s0 q).X p1
      ([.num (.ref 1)] ++ (toks.take (T - 3)).map Val.num))
    (hlen : q.length = L) (hlo : K.lo = DEC.Pw.lo) (hhi : K.hi = DEC.Pw.E) :
    (DEC.finalClear1 b0 NB q).QA (valL ρ T tk L (T - 2) (tk T)) K := by
  refine ⟨⟨⟨hlo, hhi, ?_⟩, valL_vb_terminal hρ hctx htv _ _ (by omega) (by have := htv T le_rfl; omega)⟩, ?_, ?_⟩
  · intro a
    rw [hfr]
    exact frA_ne_none addrPrompt DEC.s0 (framesP DEC.s0 q) p1 _ a
  · rw [hfr, frA_other addrPrompt DEC.s0 (framesP DEC.s0 q).X p1 _ (by decide) (by decide)]
    rfl
  · rw [hlen]
    exact DEC.finalClear1_len hT hctx

/-- Branch selection supplies the oracle independently of the context entry proof. -/
theorem DEC.finalClear1_good (b0 : BSt) (NB : Nat) (q : List Val)
    {ρ : Nat → F64} {T L : Nat} {tk : Nat → Nat}
    (hT : 3 ≤ T) (hctx : L + T ≤ 262144) (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (htok : tk (T - 1) ≠ 248044) (hnext : tk T ≠ 248044)
    (hrem : (T - 2) % 256 ≠ 0) (hrem1 : (T - 1) % 256 = 0) :
    Good (valL ρ T tk L (T - 2) (tk T)) (DEC.finalClear1 b0 NB q).O := by
  apply good_finalW (DEC.finalClear1_finalOk b0 NB q) (by omega) (by omega)
  · simpa only [show T - 2 + 1 = T - 1 by omega] using htok
  · exact hnext
  · omega
  · have := htv (T - 2 + 1) (by omega); omega
  · have := htv T le_rfl; omega
  · exact decide_eq_false hrem
  · apply decide_eq_true
    simpa only [show T - 2 + 1 = T - 1 by omega] using hrem1

theorem DEC.finalClear1_steps (b0 : BSt) (NB : Nat) (q : List Val) (r : List NumV) :
    ((DEC.finalClear1 b0 NB q).seg r).case.n = 1681 := rfl
end Host.Ts.Sim.Compose

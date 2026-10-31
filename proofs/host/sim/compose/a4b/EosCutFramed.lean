import host.sim.compose.Mach
import host.sim.dispatch.BridgeSpread
import host.sim.compose.a4b.EosCutFramedData
import host.sim.template.a4eos_cut_ctx.LenFacts
import host.sim.template.a4eos_cut_ctx.Facts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Layers
open Host.Load.Run.Prompt Host.Load.Run.Tpl
namespace EosCutFramedData

abbrev fr0 : List Nat := [2673448, 12504, 2665, 4910]
abbrev fr1 : List Nat := fr0 ++ [3123590]

def PromptQ (q : List Val) (ν : Nat → F64) (K : Ctx) : Prop :=
  Q fr0 ν K ∧ K.fr 2665 = some (arrOf DEC.s0 2665, q) ∧ EOSCutCtx.promptLen.eval ν = F64.ofNat q.length

def QA (ν : Nat → F64) (K : Ctx) : Prop := ∃ q, PromptQ q ν K

theorem frontQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 DEC.Pw NB r) wideP (PromptQ q))
      (relQW FF (FLRb b0 DEC.Pw NB r) wideP (PromptQ q)) 395
      DEC.s0 EOSCutCtxLen.S0 EOSCutCtx.start EOSCutCtx.inputSrv := by
  let S := acc b0 NB fr0
  have p := PieceSim.ofRunOkW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.sim r) (fun _ _ h => h.1)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hok hrun hrc)
    EOSCutCtxLen.ok0 EOSCutCtxLen.prefix
  have l := PieceSim.ofLastW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.simL r) (fun _ _ h => h.1)
    (fun M ν K s t s1 t1 Sv Sv1 C C1 hq hr hh hok hs ht =>
      S.ngL r M ν K s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hh hok hs ht)
    EOSCutCtxLen.okPre EOSCutCtxLen.haltPre EOSCutCtxLen.step
  have p394 := (p.trans l (Nat.ble_eq.mp EOSCutCtxLen.prefixGrow)).trans
    (PieceSim.relOfXW (fun rs env fs h => by rw [EOSCutCtxLen.stack] at h; cases h))
    ((Nat.ble_eq.mp EOSCutCtxLen.prefixGrow).trans (Nat.ble_eq.mp EOSCutCtxLen.stepGrow))
  have plen := lenPiece (Wd := fullWorldFb b0 NB) (A := addrPrompt) (P := DEC.Pw)
    (W := wideP) (r := r) (QA := PromptQ q) (QB := PromptQ q) (pre' := q) (xs := [])
    EOSCutCtxLen.ctl EOSCutCtxLen.stack EOSCutCtxLen.obj EOSCutCtxLen.kind
    EOSCutCtx.patch_exact EOSCutCtxLen.patch_oracle
    (fun _ _ h => h.2.1) (fun _ _ h => by simpa only [List.length_nil, Nat.add_zero] using h.2.2)
    (fun _ _ h => h)
    (fun t t' h => by show Host.Mlx.Ffi.NGrow _ _; rw [h]; exact Host.Mlx.Ffi.NGrow.refl _)
  exact p394.trans plen
    ((Nat.ble_eq.mp EOSCutCtxLen.prefixGrow).trans (Nat.ble_eq.mp EOSCutCtxLen.stepGrow))

noncomputable def front (b0 : BSt) (NB : Nat) :
    SPiece (haltLawsW (fullWorldFb b0 NB) addrPrompt) ((fullWorldFb b0 NB).R DEC.Pw) wideP
      DEC.s0 DEC.tab0 QA EOSCutCtxRest.s0 EOSCutCtxRest.S0.tab QA := by
  have h := piece (Wd := fullWorldFb b0 NB) (A := addrPrompt) (P := DEC.Pw)
    (W := wideP) (QA := QA) (QB := QA) EOSCutCtxLen.O EOSCutCtxLen.oracle_exact
    (Nat.ble_eq.mp EOSCutCtxLen.tabGrow) (fun r x hx => by
      obtain ⟨q, hq⟩ := hx.2
      obtain ⟨x1, hs, hr, hq1⟩ := frontQ b0 NB r q x ⟨hx.1, hq⟩
      exact ⟨x1, hs, hr, q, hq1⟩)
  exact h

theorem secondQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 DEC.Pw NB r) wideP (PromptQ q))
      (relQW FF (FLRb b0 DEC.Pw NB r) wideP (PromptQ q)) 15
      EOSCutCtxRest.s0 EOSCutCtxRest.S0 EOSCutCtxRest.s3 EOSCutCtxRest.S3 := by
  let S := acc b0 NB fr0
  have p := PieceSim.ofRunOkW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.sim r) (fun _ _ h => h.1)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hok hrun hrc)
    EOSCutCtx.okRest0 EOSCutCtxRest.runSeg0
  have l := PieceSim.ofLastW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.simL r) (fun _ _ h => h.1)
    (fun M ν K s t s1 t1 Sv Sv1 C C1 hq hr hh hok hs ht =>
      S.ngL r M ν K s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hh hok hs ht)
    EOSCutCtx.okLenPre2 EOSCutCtx.haltLenPre2 EOSCutCtxRest.stepA1
  have p14 := (p.trans l (Nat.ble_eq.mp EOSCutCtx.prefixGrow2)).trans
    (PieceSim.relOfXW (fun rs env fs h => by rw [EOSCutCtx.stackLen2] at h; cases h))
    ((Nat.ble_eq.mp EOSCutCtx.prefixGrow2).trans (Nat.ble_eq.mp EOSCutCtx.stepGrow2))
  have plen := lenPiece (Wd := fullWorldFb b0 NB) (A := addrPrompt) (P := DEC.Pw)
    (W := wideP) (r := r) (QA := PromptQ q) (QB := PromptQ q) (pre' := q) (xs := [])
    EOSCutCtxRest.ctlA1 EOSCutCtx.stackLen2 EOSCutCtxRest.objA1 EOSCutCtx.kindLen2
    (Option.some.inj EOSCutCtxRest.patchB1) EOSCutCtx.oracleLen2
    (fun _ _ h => h.2.1) (fun _ _ h => by simpa only [List.length_nil, Nat.add_zero] using h.2.2)
    (fun _ _ h => h)
    (fun t t' h => by show Host.Mlx.Ffi.NGrow _ _; rw [h]; exact Host.Mlx.Ffi.NGrow.refl _)
  exact p14.trans plen
    ((Nat.ble_eq.mp EOSCutCtx.prefixGrow2).trans (Nat.ble_eq.mp EOSCutCtx.stepGrow2))


def SpQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) : SRel FF := fun x s S =>
  RelSp FF (FLRb b0 DEC.Pw NB r) wideP [] x.M x.ν x.K
    (some ((arrOf DEC.s0 2665).reverse, q.reverse)) s S x.t x.C ∧ PromptQ q x.ν x.K

theorem spreadOpen (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 DEC.Pw NB r) wideP (PromptQ q)) (SpQ b0 NB r q) 1
      EOSCutCtx.spOpen EOSCutCtx.spOpenSrv EOSCutCtxRest.s4 EOSCutCtxRest.S4 := by
  refine PieceSim.ofMSim EOSCutCtx.spOpenStep fun x hx => ?_
  have hh : isHalt x.t.ctl = false := by rw [hx.1.ctl, EOSCutCtx.spCtl]; rfl
  refine ⟨hh, ?_⟩
  have h := relB_withQ hx.1 (Q := fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))
    (Host.Mlx.Ffi.NGrow.refl _)
  have hm := Disp.step_spread_open h EOSCutCtx.spCtl EOSCutCtx.spStack hx.2.2.1 (by decide)
  exact hm.mono fun M' S' C' s' t' ⟨hg, hr⟩ =>
    ⟨hg, x.K, (haltLawsW (fullWorldFb b0 NB) addrPrompt).krefl _, hr.1.ffi.2,
      ⟨{ hr.1 with ffi := hr.1.ffi.1 }, hr.2⟩, hx.2⟩

theorem spreadId (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt) (SpQ b0 NB r q) (SpQ b0 NB r q) 1
      EOSCutCtxRest.s4 EOSCutCtxRest.S4 EOSCutCtxRest.s5 EOSCutCtxRest.S5 := by
  refine PieceSim.ofMSim EOSCutCtxRest.stepA2 fun x hx => ?_
  have hc := hx.1.1.ctl
  change x.t.ctl = _ at hc
  have hh : isHalt x.t.ctl = false := by rw [hc, EOSCutCtx.spIdCtl]; rfl
  refine ⟨hh, ?_⟩
  have h : RelSp FF (FRQ (FLRb b0 DEC.Pw NB r)
      (fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))) wideP [] x.M x.ν x.K
      (some ((arrOf DEC.s0 2665).reverse, q.reverse)) EOSCutCtxRest.s4 EOSCutCtxRest.S4 x.t x.C :=
    ⟨relB_withQ hx.1.1 (Host.Mlx.Ffi.NGrow.refl _), hx.1.2⟩
  have hn : NoW x.K wideP EOSCutCtxRest.s4 EOSCutCtx.spCell := .inl (by
    change (bif Nat.beq EOSCutCtx.spCell 4910 then some (.memo []) else none) = none
    rw [EOSCutCtx.spCellNoW]; rfl)
  have hm := Disp.step_id_spread h EOSCutCtx.spIdCtl EOSCutCtx.spLookup EOSCutCtx.spCellVal hn
  exact hm.mono fun M' S' C' s' t' ⟨hg, hr⟩ =>
    ⟨hg, x.K, (haltLawsW (fullWorldFb b0 NB) addrPrompt).krefl _, hr.1.ffi.2,
      ⟨{ hr.1 with ffi := hr.1.ffi.1 }, hr.2⟩, hx.2⟩

theorem spreadClose (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt) (SpQ b0 NB r q)
      (relQW FF (FLRb b0 DEC.Pw NB r) wideP (Q fr1)) 1
      EOSCutCtxRest.s5 EOSCutCtxRest.S5 EOSCutCtxRest.s6 EOSCutCtxRest.S6 := by
  refine PieceSim.ofMSim EOSCutCtxRest.stepB2 fun x hx => ?_
  have hc := hx.1.1.ctl
  change x.t.ctl = _ at hc
  have hh : isHalt x.t.ctl = false := by rw [hc, EOSCutCtx.ctlA]; rfl
  refine ⟨hh, ?_⟩
  have h : RelSp FF (FRQ (FLRb b0 DEC.Pw NB r)
      (fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))) wideP [] x.M x.ν x.K
      (some ((arrOf DEC.s0 2665).reverse, q.reverse)) EOSCutCtxRest.s5 EOSCutCtxRest.S5 x.t x.C :=
    ⟨relB_withQ hx.1.1 (Host.Mlx.Ffi.NGrow.refl _), hx.1.2⟩
  have hne : x.K.fr 2673448 ≠ none := (hx.2.1.1.2.2 2673448).2 (by decide)
  obtain ⟨⟨pre, pre'⟩, hf⟩ := Option.ne_none_iff_exists'.1 hne
  have hp : Present EOSCutCtxRest.s5 aArrayProto := EOSCutCtx.arrA
  have hm := Disp.step_spread_close (A := []) h EOSCutCtx.ctlA EOSCutCtx.spCloseStack hf
    (Nat.blt_eq.mp EOSCutCtx.roomA_check) hp (by decide) (by rw [EOSCutCtx.newA]; decide)
  refine hm.mono fun M' S' C' s' t' ⟨hg, hr, hffi⟩ => ?_
  let K' := Disp.Ctx.frameAt x.K EOSCutCtxRest.s5.next
    ((arrOf DEC.s0 2665).reverse.reverse ++ [].reverse ++ pre, q.reverse.reverse ++ x.M.vals [].reverse ++ pre')
  refine ⟨hg, K', ⟨rfl, rfl, ?_⟩, hr.ffi.2, ⟨{ hr with ffi := hr.ffi.1 }, ?_⟩⟩
  · exact Disp.Ctx.frameAt_ne x.K _ (by rw [EOSCutCtx.newA]; decide)
  · refine ⟨?_, hx.2.1.2⟩
    change Disp.Kp (J fr1) K'
    dsimp only [K']
    rw [EOSCutCtx.newA]
    exact kp_frameAtW (Wd := fullWorldFb b0 NB) (acc b0 NB fr0).hj (acc b0 NB fr1).hj hx.2.1.1 _

theorem remainderQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 DEC.Pw NB r) wideP (PromptQ q))
      (relQW FF (FLRb b0 DEC.Pw NB r) wideP (Q fr1)) 519
      EOSCutCtxRest.s3 EOSCutCtxRest.S3 EOSCutCtxRest.s7 EOSCutCtxRest.S7 := by
  let S := acc b0 NB fr0
  let SE := acc b0 NB fr1
  have p := PieceSim.ofRunOkW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.sim r) (fun _ _ h => h.1)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hok hrun hrc)
    EOSCutCtx.okA0 EOSCutCtx.spRun
  have l := PieceSim.ofLastW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.simL r) (fun _ _ h => h.1)
    (fun M ν K s t s1 t1 Sv Sv1 C C1 hq hr hh hok hs ht =>
      S.ngL r M ν K s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hh hok hs ht)
    EOSCutCtx.spOk EOSCutCtx.spHalt EOSCutCtx.spInto
  have p34 := (p.trans l (Nat.ble_eq.mp EOSCutCtx.spGrowPre)).trans
    (PieceSim.relOfXW (fun rs env fs h => by rw [EOSCutCtx.spStack] at h; cases h))
    ((Nat.ble_eq.mp EOSCutCtx.spGrowPre).trans (Nat.ble_eq.mp EOSCutCtx.spGrowOpen))
  have pe := PieceSim.ofRunOkRelW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := Q fr1)
    (SE.sim r) (fun _ _ h => h)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      SE.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1 hq.2 hr hok hrun hrc)
    EOSCutCtx.okB0_after EOSCutCtxRest.runSeg2
    (fun v h => by rw [EOSCutCtx.haltF] at h; cases h)
  exact p34.trans ((spreadOpen b0 NB r q).trans ((spreadId b0 NB r q).trans
    ((spreadClose b0 NB r q).trans pe (Nat.ble_eq.mp EOSCutCtx.spGrowPost))
    (Nat.ble_eq.mp EOSCutCtx.spGrowClose)) (Nat.ble_eq.mp EOSCutCtx.spGrowId))
    ((Nat.ble_eq.mp EOSCutCtx.spGrowPre).trans (Nat.ble_eq.mp EOSCutCtx.spGrowOpen))

noncomputable def tail (b0 : BSt) (NB : Nat) :
    SPiece (haltLawsW (fullWorldFb b0 NB) addrPrompt) ((fullWorldFb b0 NB).R DEC.Pw) wideP
      EOSCutCtxRest.s0 EOSCutCtxRest.S0.tab QA EOSCutCtxRest.s7 EOSCutCtxRest.S7.tab (Q fr1) :=
  piece EOSCutCtxRest.O EOSCutCtx.oracle_exact (Nat.ble_eq.mp EOSCutCtx.fullGrow2)
    (fun r x hx => by
      obtain ⟨q, hq⟩ := hx.2
      exact ((secondQ b0 NB r q).trans (remainderQ b0 NB r q)
        (Nat.ble_eq.mp EOSCutCtx.lenGrow2)) x ⟨hx.1, hq⟩)

end EosCutFramedData

/-- The current full-FFI EOS exit, using its actual prompt frame at the length read. -/
noncomputable def DEC.eosCutFramed (b0 : BSt) (NB : Nat) :
    Halt2W (fullWorldFb b0 NB) addrPrompt DEC.Pw wideP DEC.s0 DEC.s0 DEC.tab0 [] where
  QA := EosCutFramedData.QA
  s1 := EOSCutCtxRest.s0
  t1 := EOSCutCtxRest.S0.tab
  Q1 := EosCutFramedData.QA
  sE := EOSCutCtxRest.s7
  tE := EOSCutCtxRest.S7.tab
  QE := EosCutFramedData.Q EosCutFramedData.fr1
  p1 := EosCutFramedData.front b0 NB
  p2 := EosCutFramedData.tail b0 NB
  fin :=
    { halt := fun r x hx => ⟨x.M.val EOSCutCtx.vF, by rw [hx.1.ctl, EOSCutCtx.haltF]; rfl⟩
      emitG := ⟨_, EOSCutCtx.emit_get, EOSCutCtx.emit_kind⟩
      cell := EOSCutCtx.cell }

/-- Every answer consumed by the patched chain is valid on the existing EOS boxes. -/
theorem DEC.eosCutFramed_exitOk (b0 : BSt) (NB : Nat) : ExitOk (DEC.eosCutFramed b0 NB).O := by
  change ExitOk (EOSCutCtxLen.O ++ (EOSCutCtxRest.O ++ []))
  unfold ExitOk
  decide +kernel

theorem DEC.eosCutFramed_stop (b0 : BSt) (NB : Nat) :
    StopAtW (Wd := fullWorldFb b0 NB) wideP addrPrompt (DEC.eosCutFramed b0 NB).sE := EOSCutCtx.stop b0 NB

theorem DEC.eosCutFramed_graph (b0 : BSt) (NB : Nat) (r : List NumV) :
    CutGM DEC.inputs ((DEC.eosCutFramed b0 NB).seg r) :=
  ⟨EOSCutCtx.read, EOSCutCtx.read_present, EOSCutCtx.tokens, EOSCutCtx.token_var⟩

/-- The composite entry is the prompt length at the existing loop valuation. -/
theorem DEC.eosCutFramed_len {ρ : Nat → F64} {T L : Nat} {tk : Nat → Nat} {i nx : Nat}
    (hctx : L + T ≤ 262144) (hi : i + 2 ≤ T) :
    EOSCutCtx.promptLen.eval (valL ρ T tk L i nx) = F64.ofNat L := by
  change F64.bin .sub (F64.bin .sub (F64.ofNat (L + i + 1)) (F64.ofNat i)) (F64.ofNat 1) = F64.ofNat L
  rw [bin_sub_ofNat _ _ (by omega) (by omega), bin_sub_ofNat _ _ (by omega) (by omega)]
  congr 1
  omega

/-- The entry obligation uses the exact context already carried by `LoopInvW`. -/
theorem DEC.eosCutFramed_entry (b0 : BSt) (NB : Nat)
    {ρ : Nat → F64} {T L : Nat} {tk : Nat → Nat} {q p1 p2 : List Val} {K : Ctx}
    (hρ : ∀ j, ∃ n ≤ 2 ^ 20, ρ j = F64.ofNat n)
    (hctx : L + T ≤ 262144) (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (hfr : K.fr = frA addrPrompt DEC.s0 (framesP DEC.s0 q).X p1 p2) (hlen : q.length = L)
    (hlo : K.lo = DEC.Pw.lo) (hhi : K.hi = DEC.Pw.E)
    (k : Nat) (hk : 2 ≤ k) (hkT : k < T) (nx : Nat) (hnx : nx ≤ 2 ^ 20) :
    (DEC.eosCutFramed b0 NB).QA (valL ρ T tk L (k - 1) nx) K := by
  refine ⟨q, ⟨⟨hlo, hhi, ?_⟩, valL_vb_terminal hρ hctx htv _ nx (by omega) hnx⟩, ?_, ?_⟩
  · intro a
    rw [hfr]
    exact frA_ne_none addrPrompt DEC.s0 (framesP DEC.s0 q) p1 p2 a
  · rw [hfr, frA_other addrPrompt DEC.s0 (framesP DEC.s0 q).X p1 p2 (by decide) (by decide)]
    rfl
  · rw [hlen]
    exact DEC.eosCutFramed_len hctx (by omega)

theorem DEC.eosCutFramed_steps (b0 : BSt) (NB : Nat) (r : List NumV) :
    ((DEC.eosCutFramed b0 NB).seg r).case.n = 929 := rfl

end Host.Ts.Sim.Compose

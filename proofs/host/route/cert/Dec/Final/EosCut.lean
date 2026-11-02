import host.sim.compose.Mach
import host.sim.dispatch.BridgeSpread
import host.route.cert.Dec.Final.Data
import host.sim.template.a4eos4_cut_ctx.LenFacts
import host.sim.template.a4eos4_cut_ctx.Facts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Route.Cert
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Layers
open Host.Load.Run.Prompt Host.Load.Run.Tpl
namespace EosCut4Data
open Final4Data

abbrev fr0 : List Nat := [2673448, 12504, 2665, 4910] ++ Host.Load.Run.Tpl.ghostAddrs
abbrev fr1 : List Nat := fr0 ++ [3123590]

def PromptQ (q : List Val) (ν : Nat → F64) (K : Ctx) : Prop :=
  Q fr0 ν K ∧ K.fr 2665 = some (arrOf Dec.s0 2665, q) ∧ EOSCut44Ctx.promptLen.eval ν = F64.ofNat q.length

def QA (ν : Nat → F64) (K : Ctx) : Prop := ∃ q, PromptQ q ν K

theorem frontQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q))
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q)) 395
      Dec.s0 EOSCut44CtxLen.S0 EOSCut44Ctx.start EOSCut44Ctx.inputSrv := by
  let S := acc b0 NB fr0
  have p := PieceSim.ofRunOkW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.sim r) (fun _ _ h => h.1)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hok hrun hrc)
    EOSCut44CtxLen.ok0 EOSCut44CtxLen.prefix
  have l := PieceSim.ofLastW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.simL r) (fun _ _ h => h.1)
    (fun M ν K s t s1 t1 Sv Sv1 C C1 hq hr hh hok hs ht =>
      S.ngL r M ν K s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hh hok hs ht)
    EOSCut44CtxLen.okPre EOSCut44CtxLen.haltPre EOSCut44CtxLen.step
  have p394 := (p.trans l (Nat.ble_eq.mp EOSCut44CtxLen.prefixGrow)).trans
    (PieceSim.relOfXW (fun rs env fs h => by rw [EOSCut44CtxLen.stack] at h; cases h))
    ((Nat.ble_eq.mp EOSCut44CtxLen.prefixGrow).trans (Nat.ble_eq.mp EOSCut44CtxLen.stepGrow))
  have plen := lenPiece (Wd := fullWorldFb b0 NB) (A := addrPrompt) (P := Dec.Pw)
    (W := wideG) (r := r) (QA := PromptQ q) (QB := PromptQ q) (pre' := q) (xs := [])
    EOSCut44CtxLen.ctl EOSCut44CtxLen.stack EOSCut44CtxLen.obj EOSCut44CtxLen.kind
    EOSCut44Ctx.patch_exact EOSCut44CtxLen.patch_oracle
    (fun _ _ h => h.2.1) (fun _ _ h => by simpa only [List.length_nil, Nat.add_zero] using h.2.2)
    (fun _ _ h => h)
    (fun t t' h => by show Host.Mlx.Ffi.NGrow _ _; rw [h]; exact Host.Mlx.Ffi.NGrow.refl _)
  exact p394.trans plen
    ((Nat.ble_eq.mp EOSCut44CtxLen.prefixGrow).trans (Nat.ble_eq.mp EOSCut44CtxLen.stepGrow))

noncomputable def front (b0 : BSt) (NB : Nat) :
    SPiece (haltLawsW (fullWorldFb b0 NB) addrPrompt) ((fullWorldFb b0 NB).R Dec.Pw) wideG
      Dec.s0 Dec.tab0 QA EOSCut44CtxRest.s0 EOSCut44CtxRest.S0.tab QA := by
  have h := piece (Wd := fullWorldFb b0 NB) (A := addrPrompt) (P := Dec.Pw)
    (W := wideG) (QA := QA) (QB := QA) EOSCut44CtxLen.O EOSCut44CtxLen.oracle_exact
    (Nat.ble_eq.mp EOSCut44CtxLen.tabGrow) (fun r x hx => by
      obtain ⟨q, hq⟩ := hx.2
      obtain ⟨x1, hs, hr, hq1⟩ := frontQ b0 NB r q x ⟨hx.1, hq⟩
      exact ⟨x1, hs, hr, q, hq1⟩)
  exact h

theorem secondQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q))
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q)) 15
      EOSCut44CtxRest.s0 EOSCut44CtxRest.S0 EOSCut44CtxRest.s3 EOSCut44CtxRest.S3 := by
  let S := acc b0 NB fr0
  have p := PieceSim.ofRunOkW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.sim r) (fun _ _ h => h.1)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hok hrun hrc)
    EOSCut44Ctx.okRest0 EOSCut44CtxRest.runSeg0
  have l := PieceSim.ofLastW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.simL r) (fun _ _ h => h.1)
    (fun M ν K s t s1 t1 Sv Sv1 C C1 hq hr hh hok hs ht =>
      S.ngL r M ν K s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hh hok hs ht)
    EOSCut44Ctx.okLenPre2 EOSCut44Ctx.haltLenPre2 EOSCut44CtxRest.stepA1
  have p14 := (p.trans l (Nat.ble_eq.mp EOSCut44Ctx.prefixGrow2)).trans
    (PieceSim.relOfXW (fun rs env fs h => by rw [EOSCut44Ctx.stackLen2] at h; cases h))
    ((Nat.ble_eq.mp EOSCut44Ctx.prefixGrow2).trans (Nat.ble_eq.mp EOSCut44Ctx.stepGrow2))
  have plen := lenPiece (Wd := fullWorldFb b0 NB) (A := addrPrompt) (P := Dec.Pw)
    (W := wideG) (r := r) (QA := PromptQ q) (QB := PromptQ q) (pre' := q) (xs := [])
    EOSCut44CtxRest.ctlA1 EOSCut44Ctx.stackLen2 EOSCut44CtxRest.objA1 EOSCut44Ctx.kindLen2
    (Option.some.inj EOSCut44CtxRest.patchB1) EOSCut44Ctx.oracleLen2
    (fun _ _ h => h.2.1) (fun _ _ h => by simpa only [List.length_nil, Nat.add_zero] using h.2.2)
    (fun _ _ h => h)
    (fun t t' h => by show Host.Mlx.Ffi.NGrow _ _; rw [h]; exact Host.Mlx.Ffi.NGrow.refl _)
  exact p14.trans plen
    ((Nat.ble_eq.mp EOSCut44Ctx.prefixGrow2).trans (Nat.ble_eq.mp EOSCut44Ctx.stepGrow2))


def SpQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) : SRel FF := fun x s S =>
  RelSp FF (FLRb b0 Dec.Pw NB r) wideG [] x.M x.ν x.K
    (some ((arrOf Dec.s0 2665).reverse, q.reverse)) s S x.t x.C ∧ PromptQ q x.ν x.K

theorem spreadOpen (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q)) (SpQ b0 NB r q) 1
      EOSCut44Ctx.spOpen EOSCut44Ctx.spOpenSrv EOSCut44CtxRest.s4 EOSCut44CtxRest.S4 := by
  refine PieceSim.ofMSim EOSCut44Ctx.spOpenStep fun x hx => ?_
  have hh : isHalt x.t.ctl = false := by rw [hx.1.ctl, EOSCut44Ctx.spCtl]; rfl
  refine ⟨hh, ?_⟩
  have h := relB_withQ hx.1 (Q := fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))
    (Host.Mlx.Ffi.NGrow.refl _)
  have hm := Disp.step_spread_open h EOSCut44Ctx.spCtl EOSCut44Ctx.spStack hx.2.2.1 (by decide)
  exact hm.mono fun M' S' C' s' t' ⟨hg, hr⟩ =>
    ⟨hg, x.K, (haltLawsW (fullWorldFb b0 NB) addrPrompt).krefl _, hr.1.ffi.2,
      ⟨{ hr.1 with ffi := hr.1.ffi.1 }, hr.2⟩, hx.2⟩

kernel_rfl spCellNoG : Host.Load.Run.Tpl.wideG EOSCut44Ctx.spCell = none

theorem spreadId (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt) (SpQ b0 NB r q) (SpQ b0 NB r q) 1
      EOSCut44CtxRest.s4 EOSCut44CtxRest.S4 EOSCut44CtxRest.s5 EOSCut44CtxRest.S5 := by
  refine PieceSim.ofMSim EOSCut44CtxRest.stepA2 fun x hx => ?_
  have hc := hx.1.1.ctl
  change x.t.ctl = _ at hc
  have hh : isHalt x.t.ctl = false := by rw [hc, EOSCut44Ctx.spIdCtl]; rfl
  refine ⟨hh, ?_⟩
  have h : RelSp FF (FRQ (FLRb b0 Dec.Pw NB r)
      (fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))) wideG [] x.M x.ν x.K
      (some ((arrOf Dec.s0 2665).reverse, q.reverse)) EOSCut44CtxRest.s4 EOSCut44CtxRest.S4 x.t x.C :=
    ⟨relB_withQ hx.1.1 (Host.Mlx.Ffi.NGrow.refl _), hx.1.2⟩
  have hn : NoW x.K wideG EOSCut44CtxRest.s4 EOSCut44Ctx.spCell := .inl spCellNoG
  have hm := Disp.step_id_spread h EOSCut44Ctx.spIdCtl EOSCut44Ctx.spLookup EOSCut44Ctx.spCellVal hn
  exact hm.mono fun M' S' C' s' t' ⟨hg, hr⟩ =>
    ⟨hg, x.K, (haltLawsW (fullWorldFb b0 NB) addrPrompt).krefl _, hr.1.ffi.2,
      ⟨{ hr.1 with ffi := hr.1.ffi.1 }, hr.2⟩, hx.2⟩

theorem spreadClose (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt) (SpQ b0 NB r q)
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (Q fr1)) 1
      EOSCut44CtxRest.s5 EOSCut44CtxRest.S5 EOSCut44CtxRest.s6 EOSCut44CtxRest.S6 := by
  refine PieceSim.ofMSim EOSCut44CtxRest.stepB2 fun x hx => ?_
  have hc := hx.1.1.ctl
  change x.t.ctl = _ at hc
  have hh : isHalt x.t.ctl = false := by rw [hc, EOSCut44Ctx.ctlA]; rfl
  refine ⟨hh, ?_⟩
  have h : RelSp FF (FRQ (FLRb b0 Dec.Pw NB r)
      (fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))) wideG [] x.M x.ν x.K
      (some ((arrOf Dec.s0 2665).reverse, q.reverse)) EOSCut44CtxRest.s5 EOSCut44CtxRest.S5 x.t x.C :=
    ⟨relB_withQ hx.1.1 (Host.Mlx.Ffi.NGrow.refl _), hx.1.2⟩
  have hne : x.K.fr 2673448 ≠ none := (hx.2.1.1.2.2 2673448).2 (by decide)
  obtain ⟨⟨pre, pre'⟩, hf⟩ := Option.ne_none_iff_exists'.1 hne
  have hp : Present EOSCut44CtxRest.s5 aArrayProto := EOSCut44Ctx.arrA
  have hm := Disp.step_spread_close (A := []) h EOSCut44Ctx.ctlA EOSCut44Ctx.spCloseStack hf
    (Nat.blt_eq.mp EOSCut44Ctx.roomA_check) hp (by decide) (by rw [EOSCut44Ctx.newA]; decide)
  refine hm.mono fun M' S' C' s' t' ⟨hg, hr, hffi⟩ => ?_
  let K' := Disp.Ctx.frameAt x.K EOSCut44CtxRest.s5.next
    ((arrOf Dec.s0 2665).reverse.reverse ++ [].reverse ++ pre, q.reverse.reverse ++ x.M.vals [].reverse ++ pre')
  refine ⟨hg, K', ⟨rfl, rfl, ?_⟩, hr.ffi.2, ⟨{ hr with ffi := hr.ffi.1 }, ?_⟩⟩
  · exact Disp.Ctx.frameAt_ne x.K _ (by rw [EOSCut44Ctx.newA]; decide)
  · refine ⟨?_, hx.2.1.2⟩
    change Disp.Kp (Final4Data.J fr1) K'
    dsimp only [K']
    rw [EOSCut44Ctx.newA]
    exact kp_frameAtW (Wd := fullWorldFb b0 NB) (acc b0 NB fr0).hj (acc b0 NB fr1).hj hx.2.1.1 _

theorem remainderQ (b0 : BSt) (NB : Nat) (r : List NumV) (q : List Val) :
    PieceSim (haltLawsW (fullWorldFb b0 NB) addrPrompt)
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (PromptQ q))
      (relQW FF (FLRb b0 Dec.Pw NB r) wideG (Q fr1)) 519
      EOSCut44CtxRest.s3 EOSCut44CtxRest.S3 EOSCut44CtxRest.s7 EOSCut44CtxRest.S7 := by
  let S := acc b0 NB fr0
  let SE := acc b0 NB fr1
  have p := PieceSim.ofRunOkW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.sim r) (fun _ _ h => h.1)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      S.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hok hrun hrc)
    EOSCut44Ctx.okA0 EOSCut44Ctx.spRun
  have l := PieceSim.ofLastW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := PromptQ q)
    (S.simL r) (fun _ _ h => h.1)
    (fun M ν K s t s1 t1 Sv Sv1 C C1 hq hr hh hok hs ht =>
      S.ngL r M ν K s t s1 t1 Sv Sv1 C C1 hq.1.1 hq.1.2 hr hh hok hs ht)
    EOSCut44Ctx.spOk EOSCut44Ctx.spHalt EOSCut44Ctx.spInto
  have p34 := (p.trans l (Nat.ble_eq.mp EOSCut44Ctx.spGrowPre)).trans
    (PieceSim.relOfXW (fun rs env fs h => by rw [EOSCut44Ctx.spStack] at h; cases h))
    ((Nat.ble_eq.mp EOSCut44Ctx.spGrowPre).trans (Nat.ble_eq.mp EOSCut44Ctx.spGrowOpen))
  have pe := PieceSim.ofRunOkRelW (L := haltLawsW (fullWorldFb b0 NB) addrPrompt) (Q := Q fr1)
    (SE.sim r) (fun _ _ h => h)
    (fun M ν K n s t s1 t1 Sv Sv1 C C1 hq hr hok hrun hrc =>
      SE.ng r M ν K n s t s1 t1 Sv Sv1 C C1 hq.1 hq.2 hr hok hrun hrc)
    EOSCut44Ctx.okB0_after EOSCut44CtxRest.runSeg2
    (fun v h => by rw [EOSCut44Ctx.haltF] at h; cases h)
  exact p34.trans ((spreadOpen b0 NB r q).trans ((spreadId b0 NB r q).trans
    ((spreadClose b0 NB r q).trans pe (Nat.ble_eq.mp EOSCut44Ctx.spGrowPost))
    (Nat.ble_eq.mp EOSCut44Ctx.spGrowClose)) (Nat.ble_eq.mp EOSCut44Ctx.spGrowId))
    ((Nat.ble_eq.mp EOSCut44Ctx.spGrowPre).trans (Nat.ble_eq.mp EOSCut44Ctx.spGrowOpen))

noncomputable def tail (b0 : BSt) (NB : Nat) :
    SPiece (haltLawsW (fullWorldFb b0 NB) addrPrompt) ((fullWorldFb b0 NB).R Dec.Pw) wideG
      EOSCut44CtxRest.s0 EOSCut44CtxRest.S0.tab QA EOSCut44CtxRest.s7 EOSCut44CtxRest.S7.tab (Q fr1) :=
  piece EOSCut44CtxRest.O EOSCut44Ctx.oracle_exact (Nat.ble_eq.mp EOSCut44Ctx.fullGrow2)
    (fun r x hx => by
      obtain ⟨q, hq⟩ := hx.2
      exact ((secondQ b0 NB r q).trans (remainderQ b0 NB r q)
        (Nat.ble_eq.mp EOSCut44Ctx.lenGrow2)) x ⟨hx.1, hq⟩)

kernel_rfl stop_g0 : Host.Load.Run.Tpl.wideG EOSCut44Ctx.gF = none
kernel_rfl stop_w0 : Host.Load.Run.Tpl.wideG EOSCut44Ctx.wF = none

end EosCut4Data

/-- The current full-FFI EOS exit, using its actual prompt frame at the length read. -/
noncomputable def DEC4.eosCut (b0 : BSt) (NB : Nat) :
    Halt2W (fullWorldFb b0 NB) addrPrompt Dec.Pw wideG Dec.s0 Dec.s0 Dec.tab0 [] where
  QA := EosCut4Data.QA
  s1 := EOSCut44CtxRest.s0
  t1 := EOSCut44CtxRest.S0.tab
  Q1 := EosCut4Data.QA
  sE := EOSCut44CtxRest.s7
  tE := EOSCut44CtxRest.S7.tab
  QE := Final4Data.Q EosCut4Data.fr1
  p1 := EosCut4Data.front b0 NB
  p2 := EosCut4Data.tail b0 NB
  fin :=
    { halt := fun r x hx => ⟨x.M.val EOSCut44Ctx.vF, by rw [hx.1.ctl, EOSCut44Ctx.haltF]; rfl⟩
      emitG := ⟨_, EOSCut44Ctx.emit_get, EOSCut44Ctx.emit_kind⟩
      cell := EOSCut44Ctx.cell }

/-- Every answer consumed by the patched chain is valid on the existing EOS boxes. -/
theorem DEC4.eosCut_exitOk (b0 : BSt) (NB : Nat) : ExitOk (DEC4.eosCut b0 NB).O := by
  change ExitOk (EOSCut44CtxLen.O ++ (EOSCut44CtxRest.O ++ []))
  unfold ExitOk
  decide +kernel

theorem DEC4.eosCut_stop (b0 : BSt) (NB : Nat) :
    StopAtW (Wd := fullWorldFb b0 NB) wideG addrPrompt (DEC4.eosCut b0 NB).sE := ⟨by decide, EOSCut44Ctx.gF, EOSCut44Ctx.wF, EOSCut44Ctx.stop_cell, EosCut4Data.stop_g0, EOSCut44Ctx.stop_stats, EosCut4Data.stop_w0, EOSCut44Ctx.stop_reason⟩

theorem DEC4.eosCut_graph (b0 : BSt) (NB : Nat) (r : List NumV) :
    CutGM Dec.inputs ((DEC4.eosCut b0 NB).seg r) :=
  ⟨EOSCut44Ctx.read, EOSCut44Ctx.read_present, EOSCut44Ctx.tokens, EOSCut44Ctx.token_var⟩

/-- The composite entry is the prompt length at the existing loop valuation. -/
theorem DEC4.eosCut_len {ρ : Nat → F64} {T L : Nat} {tk : Nat → Nat} {i nx : Nat}
    (hctx : L + T ≤ 262144) (hi : i + 2 ≤ T) :
    EOSCut44Ctx.promptLen.eval (valL ρ T tk L i nx) = F64.ofNat L := by
  change F64.bin .sub (F64.bin .sub (F64.ofNat (L + i + 1)) (F64.ofNat i)) (F64.ofNat 1) = F64.ofNat L
  rw [bin_sub_ofNat _ _ (by omega) (by omega), bin_sub_ofNat _ _ (by omega) (by omega)]
  congr 1
  omega

/-- The entry obligation uses the exact context already carried by `LoopInvW`. -/
theorem DEC4.eosCut_entry (b0 : BSt) (NB : Nat)
    {ρ : Nat → F64} {T L : Nat} {tk : Nat → Nat} {q p1 p2 : List Val} {K : Ctx}
    (hVP : ∀ i nx, i + 2 ≤ T → nx ≤ 2 ^ 20 → Host.Load.Run.Tpl.DecOk.VP (valL ρ T tk L i nx))
    (hctx : L + T ≤ 262144) (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (hfr : K.fr = frA addrPrompt Dec.s0 (framesG Dec.s0 q).X p1 p2) (hlen : q.length = L)
    (hlo : K.lo = Dec.Pw.lo) (hhi : K.hi = Dec.Pw.E)
    (k : Nat) (hk : 2 ≤ k) (hkT : k < T) (nx : Nat) (hnx : nx ≤ 2 ^ 20) :
    (DEC4.eosCut b0 NB).QA (valL ρ T tk L (k - 1) nx) K := by
  refine ⟨q, ⟨⟨hlo, hhi, ?_⟩, hVP _ nx (by omega) hnx⟩, ?_, ?_⟩
  · intro a
    rw [hfr]
    exact frA_ne_none addrPrompt Dec.s0 (framesG Dec.s0 q) p1 p2 a
  · rw [hfr, frA_other addrPrompt Dec.s0 (framesG Dec.s0 q).X p1 p2 (by decide) (by decide)]
    rfl
  · rw [hlen]
    exact DEC4.eosCut_len hctx (by omega)


end Host.Ts.Sim.Compose

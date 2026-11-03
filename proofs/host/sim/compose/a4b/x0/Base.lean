import host.sim.compose.a4b.x0.G2
import host.sim.template.a4pre_first_tail_x0_r0.GlueN3
import host.sim.conv.CompactJs
import host.sim.conv.Decanon
import host.sim.template.a4pre_first_tail_x0_r0.Boundary
import host.sim.compose.a4b.x0.Count
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl tokens41 : (mlxOf PRE_first_tail_x0_r0.s41.ffi).tokens = [.ref 1, .ref 2]
kernel_rfl bodyFresh10 : PRE_first_tail_x0_r0.S41.tab.all (·.noVar 10) = true
kernel_rfl bodyN0Eq : (mlxOf PRE_first_tail_x0_r0.s41.ffi).nnext = bodyN0

/-- A class chain's start is the prefix's end. -/
theorem bodyStartEqOf {s : St FF.S}
    (h : s = PRE_first_tail_x0_r0.s41.setFfi (fullSetTokens PRE_first_tail_x0_r0.s41.ffi [.ref 1, .ref 2])) :
    s = PRE_first_tail_x0_r0.s41 :=
  startEqOf tokens41 h

/-- The JS bookkeeping at the prefix's end, where every VW chain starts. -/
theorem startClean41 : Conv.JClean (⟨18156, 15236, 2673488, 15⟩ : Conv.Cnt) PRE_first_tail_x0_r0.s41 :=
  PRE_first_tail_x0_r0.gjcl3 (PRE_first_tail_x0_r0.cjcl2 dispatchCallClean)

kernel_rfl prefixJs41 : PRE_first_tail_x0_r0.gjh3.all
  (noBigAtP (jsAboveB 2673488) PRE_first_tail_x0_r0.s41) = true

/-- No heap entry at the prefix's end holds a JS pointer into the fresh addresses. -/
theorem startJs41 : JsHeapAbove 2673488 PRE_first_tail_x0_r0.s41 := by
  have hp : ∀ i, jsAboveB 2673488 i = true → jsShiftBadB PRE_first_tail_x0_r0.kappa2 i = true := by
    intro i hi
    rw [PRE_first_tail_x0_r0.zkap2]
    change jsShiftBadB (Conv.Map.compact PRE_first_tail_x0_r0.s38.next 2673506
      PRE_first_tail_x0_r0.S38.tab.length [] (PRE_first_tail_x0_r0.nr2.map NumV.ref)
      PRE_first_tail_x0_r0.kd2.big PRE_first_tail_x0_r0.kd2.region PRE_first_tail_x0_r0.kd2.nodeF) i = true
    rw [Conv.jsShiftBadB_compact_nil (by decide) (Conv.rdata_big_js PRE_first_tail_x0_r0.kd2)]
    unfold jsAboveB at hi
    cases hq : jsPtrOf i with
    | none => simp [hq] at hi
    | some q =>
      obtain ⟨b, off⟩ := q
      simp only [hq] at hi ⊢
      apply decide_eq_true_eq.mpr
      exact Nat.le_of_ble_eq_true hi
  have h40 : JsHeapAbove 2673488 PRE_first_tail_x0_r0.s40 := (dispatchJsFree hp).heap
  exact h40.step (Nat.le_refl _)
    (Conv.heap_off_setAll PRE_first_tail_x0_r0.gjk3
      (fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x0_r0.gjbd3 b hb))) prefixJs41

theorem inactive41 : (bridgeOf PRE_first_tail_x0_r0.s41.ffi).active = false :=
  (congrArg (fun b : Host.Mlx.FfiAne.St => b.active)
    (typedRun40.dst_bridge.trans typedRun40.src_bridge.symm)).trans PRE_first_tail_x0_r0.zbin2

kernel_rfl endDws : PRE_first_tail_x0_r0.dws = [1008]
kernel_rfl endDrs : PRE_first_tail_x0_r0.drs = [x4CountTerm]
kernel_rfl endFresh10 : PRE_first_tail_x0_r0.endSrv.tab.all (·.noVar 10) = true
kernel_rfl endNoOld : PRE_first_tail_x0_r0.endSrv.tab.map (·.subst (fun v => if v = 1008 then .var 10 else .var v)) = PRE_first_tail_x0_r0.endSrv.tab

/-- The forward's start: the count at its term in the length, and var 10 bound to it. -/
theorem toBody {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {x0 : SegInst FF}
    {s : St FF.S} {S : SSrv} {r : Row} (hs : s = PRE_first_tail_x0_r0.s41) (htab : S.tab = PRE_first_tail_x0_r0.endSrv.tab)
    (hrow : r ∈ [first_tail_x0.r0]) (hi : InRow r i) (hn : i.n ≤ loopVB 10) :
    CutConv (withMem (BodyTrail x0) (forwardCut NB T tk π i)) (withMem (BodyTrail x0) (bodyStartCut NB T tk π i s S)) := by
  rintro x ⟨K0, hr, hb, hip, hins, hmap⟩ ⟨⟨hfresh, hids, hnat⟩, htr⟩
  have hv : x.ν 1008 = F64.ofNat i.n := hmap.2.2.1
  have hval := bindQuantity (v := 10) (c := i.n) (q := Q.n) hb.valuation hmap
    (by
      intro p hp
      simp only [npsMap, List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl | rfl <;> decide) rfl hn
  let y : SegInst FF := { x with ν := upd x.ν 10 (F64.ofNat i.n) }
  have hdec := hr.decanon (vs := PRE_first_tail_x0_r0.dws) (es := PRE_first_tail_x0_r0.drs) (fun j v e hd he => by
    rw [endDws] at hd
    rw [endDrs] at he
    obtain rfl : v = 1008 := List.mem_singleton.mp (nth?_mem_some hd)
    obtain rfl : e = x4CountTerm := List.mem_singleton.mp (nth?_mem_some he)
    rw [hv]
    exact x0Count hrow hi hmap.1)
  have hdec' : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] x.M x.ν x.K PRE_first_tail_x0_r0.s41 ⟨PRE_first_tail_x0_r0.endSrv.tab, []⟩ x.t x.C :=
    (congrArg (fun tab => RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] x.M x.ν x.K PRE_first_tail_x0_r0.s41 ⟨tab, []⟩ x.t x.C) PRE_first_tail_x0_r0.endTab).mp hdec
  have hrel := hdec'.rebindVar (old := 1008) (fresh := 10) (by decide)
    (fun e he => List.all_eq_true.mp endFresh10 e he) (newOracle := []) (fun _ h => nomatch h)
  rw [hv] at hrel
  have ep : ((s : St FF.S), (⟨S.tab, []⟩ : SSrv)) =
      (PRE_first_tail_x0_r0.s41, ⟨PRE_first_tail_x0_r0.endSrv.tab.map (·.subst (fun v => if v = 1008 then .var 10 else .var v)), []⟩) :=
    Prod.ext hs (congrArg (fun tab => (⟨tab, []⟩ : SSrv)) (htab.trans endNoOld.symm))
  have hrel' : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] y.M y.ν y.K
      s ⟨S.tab, []⟩ y.t y.C :=
    (congrArg (fun p : St FF.S × SSrv => RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] y.M y.ν y.K p.1 p.2 y.t y.C) ep).mpr hrel
  have book : ForwardBook i π K0 y 3571 := by
    refine ⟨hb.length, hb.vocab, hval.1, ?_, hb.context, hb.incoming, hb.incomingPrompt, hb.incomingMemo,
      hb.frames, hb.offset, hb.lo, hb.hi, hb.inputEvent⟩
    change upd x.ν 10 (F64.ofNat i.n) 1087 = _
    rw [upd_other _ _ (by decide)]
    exact hb.rows
  have inputs : setupInputs T tk y := by
    refine ⟨?_, hins.2⟩
    intro j hj
    change upd x.ν 10 (F64.ofNat i.n) j = _
    rw [upd_other _ _ (by omega)]
    exact hins.1 j hj
  have hmap' : MapOk y.ν i bodyMap := MapOk.sub hval.2 (by
    intro p hp
    simp only [bodyMap, List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl <;> simp [npsMap])
  have hk : Disp.KpJ (VWFrames.typedJ (tokenBytes (π.take i.n)) (π.take i.n).length) VWFrames.bodyD0 y.K :=
    ⟨hb.context.1, Nat.le_trans hb.context.2 (by decide)⟩
  have hnat' : NativeAt 0 0 s y.t := by
    rw [hs]
    exact hnat
  exact ⟨y, rfl, rfl, ⟨K0, hrel', book, hip, inputs, hmap', hk⟩, ⟨hfresh, hids, hnat'⟩, htr⟩



end Host.Ts.Sim.Compose.VWFirst.X0

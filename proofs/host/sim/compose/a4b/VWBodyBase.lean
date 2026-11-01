import host.sim.compose.a4b.VWBodySite
import host.sim.template.a4pre_first_tail_x15_r0.GlueN3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Load.Run.Tpl Host.Ts.Sim.Compose.SetupChunk

/-- The JS bookkeeping at the prefix's end, where every VW chain starts. -/
theorem startClean41 : Conv.JClean (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) PRE_first_tail_x15_r0.s41 :=
  PRE_first_tail_x15_r0.gjcl3 (PRE_first_tail_x15_r0.cjcl2 dispatchCallClean)

kernel_rfl bodyJs41 : PRE_first_tail_x15_r0.gjh3.all
  (noBigAtP (jsAboveB 2673488) PRE_first_tail_x15_r0.s41) = true

/-- No heap entry at the prefix's end holds a JS pointer into the fresh addresses. -/
theorem startJs41 : JsHeapAbove 2673488 PRE_first_tail_x15_r0.s41 := by
  have hp : ∀ i, jsAboveB 2673488 i = true → jsShiftBadB PRE_first_tail_x15_r0.kappa2 i = true := by
    intro i hi
    rw [PRE_first_tail_x15_r0.zkap2]
    change jsShiftBadB (Conv.Map.compact PRE_first_tail_x15_r0.s38.next 2673519
      PRE_first_tail_x15_r0.S38.tab.length [] (PRE_first_tail_x15_r0.nr2.map NumV.ref)
      PRE_first_tail_x15_r0.kd2.big PRE_first_tail_x15_r0.kd2.region PRE_first_tail_x15_r0.kd2.nodeF) i = true
    rw [Conv.jsShiftBadB_compact_nil (by decide) (Conv.rdata_big_js PRE_first_tail_x15_r0.kd2)]
    unfold jsAboveB at hi
    cases hq : jsPtrOf i with
    | none => simp [hq] at hi
    | some q =>
      obtain ⟨b, off⟩ := q
      simp only [hq] at hi ⊢
      apply decide_eq_true_eq.mpr
      exact Nat.le_of_ble_eq_true hi
  have h40 : JsHeapAbove 2673488 PRE_first_tail_x15_r0.s40 := (dispatchJsFree hp).heap
  exact h40.step (Nat.le_refl _)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0.gjk3
      (fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0.gjbd3 b hb))) bodyJs41

/-- The body's JS chain: a glue stretch and a compaction change only their listed entries. -/
theorem JsHeapAbove.glueSite {S : Type} {n n' : Nat} {sp sa sc : St S} {gl l : List Nat}
    (h : JsHeapAbove n sp) (hn : n ≤ n')
    (hgk : sa.heap = Stage.setAll sp.heap (gl.filterMap fun a => (sa.heap.get a).map (a, ·)))
    (hgb : gl.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true)
    (hck : sc.heap = Stage.setAll sa.heap (l.filterMap fun a => (sc.heap.get a).map (a, ·)))
    (hcb : l.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true)
    (hall : (gl ++ l).all (noBigAtP (jsAboveB n') sc) = true) : JsHeapAbove n' sc :=
  h.step hn (fun a ha => by
    have hg : a ∉ gl := fun h => ha (List.mem_append_left _ h)
    have hc : a ∉ l := fun h => ha (List.mem_append_right _ h)
    exact (Conv.heap_off_setAll hck (fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp hcb b hb)) a hc).trans
      (Conv.heap_off_setAll hgk (fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp hgb b hb)) a hg)) hall

/-- The bridge is inactive at the prefix's end. -/
theorem inactive41 : (bridgeOf PRE_first_tail_x15_r0.s41.ffi).active = false :=
  (congrArg (fun b : Host.Mlx.FfiAne.St => b.active)
    (typedRun40.dst_bridge.trans typedRun40.src_bridge.symm)).trans PRE_first_tail_x15_r0.zbin2

end Host.Ts.Sim.Compose.VWFirst

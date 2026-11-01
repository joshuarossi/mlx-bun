import host.sim.template.a4pre_first_tail_x8_r0_body.m.B31
import host.sim.conv.CallPieces
import host.sim.stage.Mlx
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
import host.sim.template.CallGen
import host.sim.template.EndGen
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.BootEq
import host.sim.StageRel
import host.sim.compose.a4b.VWFramesDefs
import host.sim.template.FullOk
import host.sim.template.FastOk
import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B00
import host.sim.conv.Compact
import host.sim.native.RebigR
import host.sim.template.Sigma
import host.sim.template.NShiftGen
import host.sim.conv.Closed
import host.sim.conv.NClean
import host.sim.conv.CompactFull
import host.sim.template.FootGen
import host.sim.template.a4pre_first_tail_x8_r0_body.States
import host.sim.conv.MergeSt
import host.sim.conv.Fresh

section -- SiteD175
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 175 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived175 : PRE_first_tail_x8_r0_body.nr175.map (fun r => nth? PRE_first_tail_x8_r0_body.st175.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo175 : PRE_first_tail_x8_r0_body.nr175.all (Nat.ble 7562) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj175 : PRE_first_tail_x8_r0_body.cws175.all (fun c => !PRE_first_tail_x8_r0_body.ws175.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ175 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws175 PRE_first_tail_x8_r0_body.crs175 PRE_first_tail_x8_r0_body.ws175

end Host.Load.Run.Tpl
end

section -- st175/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st175`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st175.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st175.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st175.s2.heap PRE_first_tail_x8_r0_body.st175.wrR ++ freshOf PRE_first_tail_x8_r0_body.st175.s2.heap PRE_first_tail_x8_r0_body.st175.s0.next PRE_first_tail_x8_r0_body.st175.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st175.wr : List Nat := PRE_first_tail_x8_r0_body.st175.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st175.heapFoot : PRE_first_tail_x8_r0_body.st175.s2.heap = setAll PRE_first_tail_x8_r0_body.st175.s0.heap PRE_first_tail_x8_r0_body.st175.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st175.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st175.s0.next PRE_first_tail_x8_r0_body.st175.s2.next = true
theorem PRE_first_tail_x8_r0_body.st175.grows : PRE_first_tail_x8_r0_body.st175.s0.next ≤ PRE_first_tail_x8_r0_body.st175.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st175.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st175.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st175.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st175.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st175.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st175.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st175.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st175.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st175.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st175.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st175.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st175.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF175
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 175 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB175 : nodupT PRE_first_tail_x8_r0_body.st175.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup175 : PRE_first_tail_x8_r0_body.st175.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB175).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB175 : PRE_first_tail_x8_r0_body.st175.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound175 : ∀ b ∈ PRE_first_tail_x8_r0_body.st175.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB175 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr175 := PRE_first_tail_x8_r0_body.st175.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq175 : PRE_first_tail_x8_r0_body.st175.s2.trace = PRE_first_tail_x8_r0_body.trFr175 ++ PRE_first_tail_x8_r0_body.st175.s0.trace
theorem PRE_first_tail_x8_r0_body.trace175 : ∃ fr, PRE_first_tail_x8_r0_body.st175.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st175.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq175⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide175 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB175 : (PRE_first_tail_x8_r0_body.wide175.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st175.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix175 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide175, WFix Map.id (Present PRE_first_tail_x8_r0_body.st175.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB175 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL175
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 175 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1693`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO175 : PRE_first_tail_x8_r0_body.st175.S0.oracle = PRE_first_tail_x8_r0_body.st175.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B175 : PRE_first_tail_x8_r0_body.st175.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st175.s0.next || (PRE_first_tail_x8_r0_body.st175.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot175 : Conv.StageFoot PRE_first_tail_x8_r0_body.st175.wr PRE_first_tail_x8_r0_body.st175.s0 PRE_first_tail_x8_r0_body.st175.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st175.heapFoot PRE_first_tail_x8_r0_body.wrNodup175 PRE_first_tail_x8_r0_body.wrBound175 PRE_first_tail_x8_r0_body.wr0B175 PRE_first_tail_x8_r0_body.st175.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged175 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st175.F.S → PRE_first_tail_x8_r0_body.st175.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st175.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st175.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs175 PRE_first_tail_x8_r0_body.st175.wr PRE_first_tail_x8_r0_body.s1692 PRE_first_tail_x8_r0_body.st175.s2 PRE_first_tail_x8_r0_body.st175.s0
      PRE_first_tail_x8_r0_body.st175.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st175.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1693 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso175 PRE_first_tail_x8_r0_body.stFoot175 PRE_first_tail_x8_r0_body.wrNodup175 PRE_first_tail_x8_r0_body.wrBound175 PRE_first_tail_x8_r0_body.trace175 PRE_first_tail_x8_r0_body.mheap175
    PRE_first_tail_x8_r0_body.mnext175 PRE_first_tail_x8_r0_body.mctl175 PRE_first_tail_x8_r0_body.mstack175 PRE_first_tail_x8_r0_body.mjobs175 PRE_first_tail_x8_r0_body.mffi175 PRE_first_tail_x8_r0_body.mtrace175 PRE_first_tail_x8_r0_body.mstores175 h

def PRE_first_tail_x8_r0_body.arrEl175_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE175_2665 : arrOf PRE_first_tail_x8_r0_body.s1693 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl175_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA175_2665 : isArrB PRE_first_tail_x8_r0_body.s1693 2665 = true
theorem PRE_first_tail_x8_r0_body.arr175_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1693.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl175_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE175_2665 PRE_first_tail_x8_r0_body.arrA175_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN175_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl175_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR175_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl175_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN175_2665

def PRE_first_tail_x8_r0_body.arrEl175_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE175_2673467 : arrOf PRE_first_tail_x8_r0_body.s1693 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl175_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA175_2673467 : isArrB PRE_first_tail_x8_r0_body.s1693 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr175_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1693.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl175_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE175_2673467 PRE_first_tail_x8_r0_body.arrA175_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN175_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl175_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR175_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl175_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN175_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k175 : isArrB PRE_first_tail_x8_r0_body.s1693 4910 = false
theorem PRE_first_tail_x8_r0_body.keep175 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1693 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k175 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr175_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl175_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ175
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 175 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1692`, the merged
state `PRE_first_tail_x8_r0_body.s1693`, the canonical state `PRE_first_tail_x8_r0_body.s1694`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl175 : PRE_first_tail_x8_r0_body.pl175.all (Nat.ble PRE_first_tail_x8_r0_body.s1692.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd175 : nodupT PRE_first_tail_x8_r0_body.pl175 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1175 : Nat.ble PRE_first_tail_x8_r0_body.s1692.next 2812317 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst175 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1692.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn175 : PRE_first_tail_x8_r0_body.s1694.next = PRE_first_tail_x8_r0_body.s1692.next + PRE_first_tail_x8_r0_body.pl175.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn175 : PRE_first_tail_x8_r0_body.s1693.next = 2812317
kernel_rfl PRE_first_tail_x8_r0_body.zgrow175 : Nat.ble PRE_first_tail_x8_r0_body.s1694.next PRE_first_tail_x8_r0_body.s1693.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh175 : PRE_first_tail_x8_r0_body.S1692.tab.all (fun e => PRE_first_tail_x8_r0_body.cws175.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd175 : nodupT PRE_first_tail_x8_r0_body.cws175 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi175 : PRE_first_tail_x8_r0_body.nr175.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1693.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt175 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1692.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg175_2665 : PRE_first_tail_x8_r0_body.s1694.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1694 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk175_2665 : (objOf PRE_first_tail_x8_r0_body.s1694 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm175_2665 : PRE_first_tail_x8_r0_body.s1693.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa175.obj (objOf PRE_first_tail_x8_r0_body.s1694 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1693 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg175_2673467 : PRE_first_tail_x8_r0_body.s1694.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1694 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk175_2673467 : (objOf PRE_first_tail_x8_r0_body.s1694 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm175_2673467 : PRE_first_tail_x8_r0_body.s1693.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa175.obj (objOf PRE_first_tail_x8_r0_body.s1694 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1693 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw175_4910 : (PRE_first_tail_x8_r0_body.s1694.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw175_2673472 : (PRE_first_tail_x8_r0_body.s1694.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw175_2673473 : (PRE_first_tail_x8_r0_body.s1694.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd175 : PRE_first_tail_x8_r0_body.cl175.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr175 : PRE_first_tail_x8_r0_body.st175.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1692.next || PRE_first_tail_x8_r0_body.cl175.contains b) = true
def PRE_first_tail_x8_r0_body.zl175 : List Nat := PRE_first_tail_x8_r0_body.cl175.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE175 : PRE_first_tail_x8_r0_body.zl175.map (fun a => PRE_first_tail_x8_r0_body.s1693.heap.get (PRE_first_tail_x8_r0_body.kappa175.a a)) = PRE_first_tail_x8_r0_body.zl175.map (fun a => (PRE_first_tail_x8_r0_body.s1694.heap.get a).map PRE_first_tail_x8_r0_body.kappa175.hobj)
theorem PRE_first_tail_x8_r0_body.zimg175 : HeapImg PRE_first_tail_x8_r0_body.kappa175 PRE_first_tail_x8_r0_body.s1694 PRE_first_tail_x8_r0_body.s1693 PRE_first_tail_x8_r0_body.zl175 := PRE_first_tail_x8_r0_body.zimgE175
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl175 : PRE_first_tail_x8_r0_body.s1693.ctl = PRE_first_tail_x8_r0_body.kappa175.ctl PRE_first_tail_x8_r0_body.s1694.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack175 : PRE_first_tail_x8_r0_body.s1693.stack = PRE_first_tail_x8_r0_body.s1694.stack.map PRE_first_tail_x8_r0_body.kappa175.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs175 : PRE_first_tail_x8_r0_body.s1693.jobs = PRE_first_tail_x8_r0_body.s1694.jobs.map PRE_first_tail_x8_r0_body.kappa175.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores175 : PRE_first_tail_x8_r0_body.s1693.stores = PRE_first_tail_x8_r0_body.kappa175.stores PRE_first_tail_x8_r0_body.s1694.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots175 : checkRootsSupp PRE_first_tail_x8_r0_body.s1694 7562 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC175 : PRE_first_tail_x8_r0_body.S1692.tab.length + PRE_first_tail_x8_r0_body.cws175.length = 7562
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap175 : PRE_first_tail_x8_r0_body.kappa175 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1692.next 2812317 PRE_first_tail_x8_r0_body.S1692.tab.length PRE_first_tail_x8_r0_body.pl175 (PRE_first_tail_x8_r0_body.nr175.map NumV.ref) PRE_first_tail_x8_r0_body.kd175.big
  PRE_first_tail_x8_r0_body.kd175.region PRE_first_tail_x8_r0_body.kd175.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin175 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1694.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc175 : Conv.jcleanListB (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1694 PRE_first_tail_x8_r0_body.cl175 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB175 : noBigRootsP (fun i => !Conv.oldBigB (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1694.trace PRE_first_tail_x8_r0_body.s1694 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm175 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18762 = true
theorem PRE_first_tail_x8_r0_body.cjcl175 (h : Conv.JClean (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1692) : Conv.JClean (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1694 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle175)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap175 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd175 a ha)) PRE_first_tail_x8_r0_body.zjc175

end Host.Load.Run.Tpl
end

section -- st175/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st175.bodyLast from PRE_first_tail_x8_r0_body.st175.s1 to PRE_first_tail_x8_r0_body.st175.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st175.F PRE_first_tail_x8_r0_body.st175.s1).run PRE_first_tail_x8_r0_body.st175.S1 = some (PRE_first_tail_x8_r0_body.st175.s2, PRE_first_tail_x8_r0_body.st175.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st175.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st175.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st175.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st175.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st175/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st175.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st175.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st175.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st175.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st175.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st175.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st175.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st175.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st175.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st175.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st175.s0 PRE_first_tail_x8_r0_body.st175.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st175.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st175.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st175.s1 PRE_first_tail_x8_r0_body.st175.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st175/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st175.bodyK0F from PRE_first_tail_x8_r0_body.st175.s0 to PRE_first_tail_x8_r0_body.st175.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st175.F (PRE_first_tail_x8_r0_body.st175.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st175.ks 0).getD 0) PRE_first_tail_x8_r0_body.st175.s0 PRE_first_tail_x8_r0_body.st175.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st175.s1, PRE_first_tail_x8_r0_body.st175.S1)
theorem PRE_first_tail_x8_r0_body.st175.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st175.F (PRE_first_tail_x8_r0_body.st175.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st175.ks 0).getD 0) PRE_first_tail_x8_r0_body.st175.s0 PRE_first_tail_x8_r0_body.st175.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st175.s1, PRE_first_tail_x8_r0_body.st175.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st175.bodyOkLN_ok PRE_first_tail_x8_r0_body.st175.bodyK0F
end Host.Load.Run.Tpl
end

section -- st175/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st175.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st175.F (PRE_first_tail_x8_r0_body.st175.bodyOkL bytes rows) 27 PRE_first_tail_x8_r0_body.st175.s0 PRE_first_tail_x8_r0_body.st175.S0 = some (PRE_first_tail_x8_r0_body.st175.s1, PRE_first_tail_x8_r0_body.st175.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st175.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st175.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st175.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st175.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st175.F (PRE_first_tail_x8_r0_body.st175.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st175.s0
  S0 := PRE_first_tail_x8_r0_body.st175.S0
  s1 := PRE_first_tail_x8_r0_body.st175.s1
  S1 := PRE_first_tail_x8_r0_body.st175.S1
  s2 := PRE_first_tail_x8_r0_body.st175.s2
  S2 := PRE_first_tail_x8_r0_body.st175.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st175.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st175.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st175.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st175.bodyHalt
  last := PRE_first_tail_x8_r0_body.st175.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st175.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC176
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 176 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1698` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa176` into the merged state
`PRE_first_tail_x8_r0_body.s1697`. -/

def PRE_first_tail_x8_r0_body.pl176 : List Nat := [2812623]
def PRE_first_tail_x8_r0_body.nr176 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd176 : RData :=
  ⟨2812604, 2812624, Stage.setAll PTrie.nil [(2812603, 2812623)], Stage.setAll PTrie.nil [],
   21657, 21657, 18766, 18766, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa176 : Map :=
  Conv.Map.compact 2812603 2812624 7579 PRE_first_tail_x8_r0_body.pl176 (PRE_first_tail_x8_r0_body.nr176.map NumV.ref) PRE_first_tail_x8_r0_body.kd176.big
    PRE_first_tail_x8_r0_body.kd176.region PRE_first_tail_x8_r0_body.kd176.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws176 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs176 : List SymE := PRE_first_tail_x8_r0_body.nr176.map fun r => (nth? PRE_first_tail_x8_r0_body.S1697.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta176 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws176 PRE_first_tail_x8_r0_body.crs176
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB176 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab176 : PRE_first_tail_x8_r0_body.S1698.tab = PRE_first_tail_x8_r0_body.S1696.tab ++ PRE_first_tail_x8_r0_body.cws176.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace176 : PRE_first_tail_x8_r0_body.s1698.trace = PRE_first_tail_x8_r0_body.s1696.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext176 : PRE_first_tail_x8_r0_body.s1698.next = 2812604
kernel_rfl PRE_first_tail_x8_r0_body.ccounters176 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx.nnext) = (21657, 18766)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue176 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1697.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa176.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp176 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx.tokens.all (bSN 7579) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean176 : Conv.cleanListB 21657 131072 (fun r => Nat.ble 86628 r) PRE_first_tail_x8_r0_body.s1698
    (PRE_first_tail_x8_r0_body.wrB176 ++ (List.range 1).map (2812603 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs176 : bigsOutB 21657 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK176
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl176`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl176 : List Nat := [2665, 2673467, 2812603]
def PRE_first_tail_x8_r0_body.clo176 : List Nat := []
def PRE_first_tail_x8_r0_body.cln176 : List Nat := []
def PRE_first_tail_x8_r0_body.cli176 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap176 : PRE_first_tail_x8_r0_body.s1698.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1696.heap (PRE_first_tail_x8_r0_body.cl176.filterMap fun a => (PRE_first_tail_x8_r0_body.s1698.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe176 : Nat.ble PRE_first_tail_x8_r0_body.s1696.next PRE_first_tail_x8_r0_body.s1698.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP176 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1696 PRE_first_tail_x8_r0_body.s1698 PRE_first_tail_x8_r0_body.cl176 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp176 : Conv.suppListB PRE_first_tail_x8_r0_body.s1698 7579 PRE_first_tail_x8_r0_body.cl176 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound176 : Conv.boundListB PRE_first_tail_x8_r0_body.s1698 PRE_first_tail_x8_r0_body.cl176 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK176 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln176.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK176 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo176.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK176 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli176.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst176 : Conv.sstListB 7579 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx PRE_first_tail_x8_r0_body.cln176 PRE_first_tail_x8_r0_body.clo176 PRE_first_tail_x8_r0_body.cli176 = true

end Host.Load.Run.Tpl
end

section -- SiteCl176
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA176 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo176.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd176 : (PRE_first_tail_x8_r0_body.clo176 ++ PRE_first_tail_x8_r0_body.cln176 ++ PRE_first_tail_x8_r0_body.cli176).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle176 : Conv.Cnt.leB (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt) (⟨21657, 18766, 2812604, 7579⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck176 : Conv.ncleanListB (⟨21657, 18766, 2812604, 7579⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx PRE_first_tail_x8_r0_body.clo176 PRE_first_tail_x8_r0_body.cln176 PRE_first_tail_x8_r0_body.cli176 = true
theorem PRE_first_tail_x8_r0_body.cncl176 (h : Conv.NClean (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx) : Conv.NClean (⟨21657, 18766, 2812604, 7579⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle176 PRE_first_tail_x8_r0_body.ckA176 PRE_first_tail_x8_r0_body.cobjsK176 PRE_first_tail_x8_r0_body.cnodesK176 PRE_first_tail_x8_r0_body.citemsK176 PRE_first_tail_x8_r0_body.cbd176 PRE_first_tail_x8_r0_body.cck176

end Host.Load.Run.Tpl
end

section -- SiteS176
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 176 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc176 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P176 : LoadP := PRE_first_tail_x8_r0_body.Pc176.raise 18766
kernel_rfl PRE_first_tail_x8_r0_body.craise176 : Nat.ble PRE_first_tail_x8_r0_body.Pc176.N0 18766 = true
theorem PRE_first_tail_x8_r0_body.raised176 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc176 PRE_first_tail_x8_r0_body.P176 :=
  .inr ⟨18766, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise176, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_176 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_176 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1697.ffi)
def PRE_first_tail_x8_r0_body.khinv176 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv176 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS176 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS176 : List Nat := List.range' 18766 0
def PRE_first_tail_x8_r0_body.ciS176 : List Nat := [] ++ List.range' 18766 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0176 : PRE_first_tail_x8_r0_body.kd176.nh0 = PRE_first_tail_x8_r0_body.cx0_176.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1176 : PRE_first_tail_x8_r0_body.kd176.nh1 = PRE_first_tail_x8_r0_body.cx1_176.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0176 : PRE_first_tail_x8_r0_body.kd176.nn0 = PRE_first_tail_x8_r0_body.cx0_176.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1176 : PRE_first_tail_x8_r0_body.kd176.nn1 = PRE_first_tail_x8_r0_body.cx1_176.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo176 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P176.lo && Nat.ble PRE_first_tail_x8_r0_body.P176.lo PRE_first_tail_x8_r0_body.cx0_176.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P176.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P176.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt176 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_176.mlx.next PRE_first_tail_x8_r0_body.cx1_176.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_176.mlx.nnext PRE_first_tail_x8_r0_body.cx1_176.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband176 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P176.NL && Nat.ble PRE_first_tail_x8_r0_body.P176.NL PRE_first_tail_x8_r0_body.P176.N0 && Nat.ble PRE_first_tail_x8_r0_body.P176.N0 PRE_first_tail_x8_r0_body.cx0_176.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow176 : PRE_first_tail_x8_r0_body.kd176.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren176 : checkRenG PRE_first_tail_x8_r0_body.kd176.hnd PRE_first_tail_x8_r0_body.khinv176 (phB PRE_first_tail_x8_r0_body.cx0_176.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband176 : PRE_first_tail_x8_r0_body.kd176.checkBand PRE_first_tail_x8_r0_body.P176.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos176 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd176.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren176 : checkRenG PRE_first_tail_x8_r0_body.kd176.node PRE_first_tail_x8_r0_body.kninv176 (pnB PRE_first_tail_x8_r0_body.cx0_176.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow176 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd176.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P176.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd176.nodeF j) PRE_first_tail_x8_r0_body.cx1_176.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a176 : PRE_first_tail_x8_r0_body.cx0_176.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b176 : PRE_first_tail_x8_r0_body.cx0_176.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1176 : PRE_first_tail_x8_r0_body.cx1_176.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend176 : PRE_first_tail_x8_r0_body.cx1_176.mlx.pending = PRE_first_tail_x8_r0_body.cx0_176.mlx.pending.map PRE_first_tail_x8_r0_body.kappa176.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh176 : PRE_first_tail_x8_r0_body.cx1_176.mlx.errh = PRE_first_tail_x8_r0_body.cx0_176.mlx.errh.map PRE_first_tail_x8_r0_body.kappa176.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles176 : PRE_first_tail_x8_r0_body.cx1_176.mlx.files = PRE_first_tail_x8_r0_body.cx0_176.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch176 : PRE_first_tail_x8_r0_body.cx1_176.mlx.arch = PRE_first_tail_x8_r0_body.cx0_176.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes176 : PRE_first_tail_x8_r0_body.cx1_176.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_176.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired176 : PRE_first_tail_x8_r0_body.cx1_176.mlx.wired = PRE_first_tail_x8_r0_body.cx0_176.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost176 : PRE_first_tail_x8_r0_body.cx1_176.host = PRE_first_tail_x8_r0_body.cx0_176.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd176`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0176 : PRE_first_tail_x8_r0_body.kd176.n0 = 2812604
kernel_rfl PRE_first_tail_x8_r0_body.ckn1176 : PRE_first_tail_x8_r0_body.kd176.n1 = 2812624
kernel_rfl PRE_first_tail_x8_r0_body.ckheap176 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd176.heap).all (fun x => Nat.ble 2812603 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl176 : (List.range 1).all (fun j => decide (PRE_first_tail_x8_r0_body.kd176.heap.get (2812603 + j) = nth? PRE_first_tail_x8_r0_body.pl176 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja176 : Nat.ble 2812603 2812603 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn176 : Nat.ble 7579 7579 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD176 : Nat.ble 2812603 PRE_first_tail_x8_r0_body.kd176.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn176 : Nat.ble 21657 PRE_first_tail_x8_r0_body.kd176.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn176 : Nat.ble 18766 PRE_first_tail_x8_r0_body.kd176.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb176 : Nat.ble 21657 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap176 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd176.heap).all (Nat.ble (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd176 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd176.hnd).all (Nat.ble (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode176 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd176.node).all (Nat.ble (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix176 : Conv.FixOld (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa176 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja176) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn176) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD176) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn176) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn176) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb176) PRE_first_tail_x8_r0_body.fheap176 PRE_first_tail_x8_r0_body.fhnd176 PRE_first_tail_x8_r0_body.fnode176
kernel_rfl PRE_first_tail_x8_r0_body.fcxn176 : (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn176 : (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0176 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_176.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_176.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk176 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd176.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A176 : PRE_first_tail_x8_r0_body.cx1_176.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS176.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_176.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O176 : PRE_first_tail_x8_r0_body.cx1_176.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS176.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_176.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N176 : PRE_first_tail_x8_r0_body.cx1_176.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS176.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_176.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I176 : PRE_first_tail_x8_r0_body.cx1_176.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS176.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_176.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd176 : (PRE_first_tail_x8_r0_body.clo176 ++ PRE_first_tail_x8_r0_body.cln176 ++ PRE_first_tail_x8_r0_body.cli176 ++ PRE_first_tail_x8_r0_body.cwS176 ++ PRE_first_tail_x8_r0_body.cnS176 ++ PRE_first_tail_x8_r0_body.ciS176).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW176 : PRE_first_tail_x8_r0_body.cwS176.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo176.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI176 : PRE_first_tail_x8_r0_body.ciS176.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli176.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN176 : PRE_first_tail_x8_r0_body.cnS176.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF176 : PRE_first_tail_x8_r0_body.cln176.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh176 : PRE_first_tail_x8_r0_body.clo176.all (handleOK PRE_first_tail_x8_r0_body.kappa176 PRE_first_tail_x8_r0_body.P176.lo PRE_first_tail_x8_r0_body.cx0_176.mlx PRE_first_tail_x8_r0_body.cx1_176.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo176 : PRE_first_tail_x8_r0_body.clo176.map (fun h => PRE_first_tail_x8_r0_body.cx1_176.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa176.handle h)) = PRE_first_tail_x8_r0_body.clo176.map (fun h => (PRE_first_tail_x8_r0_body.cx0_176.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa176.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok176 : PRE_first_tail_x8_r0_body.clo176.all (objOK PRE_first_tail_x8_r0_body.kappa176 PRE_first_tail_x8_r0_body.P176.NL PRE_first_tail_x8_r0_body.cx0_176.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd176 : PRE_first_tail_x8_r0_body.cln176.all (nodeOKF PRE_first_tail_x8_r0_body.kappa176 PRE_first_tail_x8_r0_body.P176 PRE_first_tail_x8_r0_body.cx0_176.mlx PRE_first_tail_x8_r0_body.cx1_176.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp176 : ((PRE_first_tail_x8_r0_body.cln176.filter (fullB PRE_first_tail_x8_r0_body.P176))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_176.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa176.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln176.filter (fullB PRE_first_tail_x8_r0_body.P176))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_176.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa176.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI176 : incrB PRE_first_tail_x8_r0_body.kd176.nodeF (List.range' 18766 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK176 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd176.node).all (fun k => Nat.ble 18766 k && Nat.blt k 18766) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL176 : (PRE_first_tail_x8_r0_body.cln176.filter (Nat.ble PRE_first_tail_x8_r0_body.P176.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd176.nodeF i) && (Nat.blt i 18766 || Nat.ble PRE_first_tail_x8_r0_body.kd176.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord176 : (PRE_first_tail_x8_r0_body.cln176.filter (Nat.ble PRE_first_tail_x8_r0_body.P176.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd176.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd176.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd176.nodeF j) (PRE_first_tail_x8_r0_body.kd176.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow176 PRE_first_tail_x8_r0_body.cnn1176 PRE_first_tail_x8_r0_body.fnordI176 PRE_first_tail_x8_r0_body.fnordK176 PRE_first_tail_x8_r0_body.fnordL176
kernel_rfl PRE_first_tail_x8_r0_body.fi176 : PRE_first_tail_x8_r0_body.cli176.all (pnB PRE_first_tail_x8_r0_body.cx0_176.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii176 : PRE_first_tail_x8_r0_body.cli176.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_176.mlx.items.get (PRE_first_tail_x8_r0_body.kappa176.node k) = (PRE_first_tail_x8_r0_body.cx0_176.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa176.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot176 (clean : Conv.NClean (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P176.NL) (cl : SSt (· < 7579) PRE_first_tail_x8_r0_body.cx0_176.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P176 7579 PRE_first_tail_x8_r0_body.kappa176 PRE_first_tail_x8_r0_body.kd176 PRE_first_tail_x8_r0_body.khinv176 PRE_first_tail_x8_r0_body.kninv176 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx PRE_first_tail_x8_r0_body.cx0_176.mlx PRE_first_tail_x8_r0_body.cx1_176.mlx (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo176 PRE_first_tail_x8_r0_body.cln176 PRE_first_tail_x8_r0_body.cli176 PRE_first_tail_x8_r0_body.cwS176 PRE_first_tail_x8_r0_body.cnS176 PRE_first_tail_x8_r0_body.ciS176 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0176, PRE_first_tail_x8_r0_body.cnh1176, PRE_first_tail_x8_r0_body.cnn0176, PRE_first_tail_x8_r0_body.cnn1176, PRE_first_tail_x8_r0_body.cplo176, PRE_first_tail_x8_r0_body.ccnt176, PRE_first_tail_x8_r0_body.cnband176, PRE_first_tail_x8_r0_body.chbelow176, PRE_first_tail_x8_r0_body.chren176, PRE_first_tail_x8_r0_body.cband176, PRE_first_tail_x8_r0_body.cnh1pos176, PRE_first_tail_x8_r0_body.cnren176, PRE_first_tail_x8_r0_body.cnlow176, PRE_first_tail_x8_r0_body.cabs0a176, PRE_first_tail_x8_r0_body.cabs0b176, PRE_first_tail_x8_r0_body.ctok1176, PRE_first_tail_x8_r0_body.cpend176, PRE_first_tail_x8_r0_body.cerrh176, PRE_first_tail_x8_r0_body.cfiles176, PRE_first_tail_x8_r0_body.carch176, PRE_first_tail_x8_r0_body.csizes176, PRE_first_tail_x8_r0_body.cwired176, PRE_first_tail_x8_r0_body.cfix176, clean, PRE_first_tail_x8_r0_body.fcxn176, PRE_first_tail_x8_r0_body.fcnn176, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0176, PRE_first_tail_x8_r0_body.fnk176, PRE_first_tail_x8_r0_body.ckA176, PRE_first_tail_x8_r0_body.cobjsK176, PRE_first_tail_x8_r0_body.cnodesK176, PRE_first_tail_x8_r0_body.citemsK176, PRE_first_tail_x8_r0_body.f1A176, PRE_first_tail_x8_r0_body.f1O176, PRE_first_tail_x8_r0_body.f1N176, PRE_first_tail_x8_r0_body.f1I176, PRE_first_tail_x8_r0_body.fbd176, PRE_first_tail_x8_r0_body.fincW176, PRE_first_tail_x8_r0_body.fincI176, PRE_first_tail_x8_r0_body.fincN176, PRE_first_tail_x8_r0_body.flnF176, PRE_first_tail_x8_r0_body.fh176, PRE_first_tail_x8_r0_body.fo176, PRE_first_tail_x8_r0_body.fok176, PRE_first_tail_x8_r0_body.fnd176, PRE_first_tail_x8_r0_body.fp176, PRE_first_tail_x8_r0_body.fnord176, PRE_first_tail_x8_r0_body.fi176, PRE_first_tail_x8_r0_body.fii176⟩
theorem PRE_first_tail_x8_r0_body.cnshift176 (clean : Conv.NClean (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P176.NL) (cl : SSt (· < 7579) PRE_first_tail_x8_r0_body.cx0_176.mlx) : NShift PRE_first_tail_x8_r0_body.P176 7579 PRE_first_tail_x8_r0_body.kappa176 PRE_first_tail_x8_r0_body.cx0_176 PRE_first_tail_x8_r0_body.cx1_176 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot176 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost176 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0176 PRE_first_tail_x8_r0_body.ckn1176 PRE_first_tail_x8_r0_body.ckheap176 PRE_first_tail_x8_r0_body.ckpl176)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_176 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1696.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_176 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1696.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_176 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1696.ffi) = some PRE_first_tail_x8_r0_body.fxC_176
kernel_rfl PRE_first_tail_x8_r0_body.okrC_176 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1696.ffi) = some PRE_first_tail_x8_r0_body.krC_176
noncomputable def PRE_first_tail_x8_r0_body.fx0_176 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1698.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_176 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1698.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_176 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1698.ffi) = some PRE_first_tail_x8_r0_body.fx0_176
kernel_rfl PRE_first_tail_x8_r0_body.okr0_176 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1698.ffi) = some PRE_first_tail_x8_r0_body.kr0_176
noncomputable def PRE_first_tail_x8_r0_body.fx1_176 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1697.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_176 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1697.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_176 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1697.ffi) = some PRE_first_tail_x8_r0_body.fx1_176
kernel_rfl PRE_first_tail_x8_r0_body.okr1_176 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1697.ffi) = some PRE_first_tail_x8_r0_body.kr1_176
kernel_rfl PRE_first_tail_x8_r0_body.ff0176 : PRE_first_tail_x8_r0_body.fx0_176 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_176 (PRE_first_tail_x8_r0_body.clo176.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_176.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1176 : PRE_first_tail_x8_r0_body.fx1_176 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_176 (PRE_first_tail_x8_r0_body.cwS176.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_176.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck176 : freedLB PRE_first_tail_x8_r0_body.kappa176 PRE_first_tail_x8_r0_body.cx0_176.mlx PRE_first_tail_x8_r0_body.fx0_176 PRE_first_tail_x8_r0_body.fx1_176 PRE_first_tail_x8_r0_body.clo176 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0176 : PRE_first_tail_x8_r0_body.kr0_176.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_176.flags (PRE_first_tail_x8_r0_body.clo176.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_176.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0176 : PRE_first_tail_x8_r0_body.kr0_176.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_176.targs (PRE_first_tail_x8_r0_body.clo176.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_176.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1176 : PRE_first_tail_x8_r0_body.kr1_176.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_176.flags (PRE_first_tail_x8_r0_body.cwS176.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_176.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1176 : PRE_first_tail_x8_r0_body.kr1_176.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_176.targs (PRE_first_tail_x8_r0_body.cwS176.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_176.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck176 : krecLB PRE_first_tail_x8_r0_body.kappa176 7579 PRE_first_tail_x8_r0_body.cx0_176.mlx PRE_first_tail_x8_r0_body.kr0_176 PRE_first_tail_x8_r0_body.kr1_176 PRE_first_tail_x8_r0_body.clo176 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn176 : Nat.ble 7579 7579 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge176 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1697.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1698.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR176 : pendRegB PRE_first_tail_x8_r0_body.kappa176 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe176 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1698.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1697.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift176 (clean : Conv.NClean (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P176.NL) (cl : SSt (· < 7579) PRE_first_tail_x8_r0_body.cx0_176.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_176.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_176.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_176.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1696.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_176.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P176 7579 PRE_first_tail_x8_r0_body.kappa176 PRE_first_tail_x8_r0_body.s1698.ffi PRE_first_tail_x8_r0_body.s1697.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift176 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue176, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp176 t ht),
    PRE_first_tail_x8_r0_body.cbridge176,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1698.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1697.ffi) (PRE_first_tail_x8_r0_body.cfoot176 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_176 PRE_first_tail_x8_r0_body.ofx1_176 hobjC PRE_first_tail_x8_r0_body.ff0176 PRE_first_tail_x8_r0_body.ff1176 PRE_first_tail_x8_r0_body.ffck176,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1698.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1697.ffi) (PRE_first_tail_x8_r0_body.cfoot176 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_176 PRE_first_tail_x8_r0_body.okr1_176 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn176) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0176 PRE_first_tail_x8_r0_body.fkt0176 PRE_first_tail_x8_r0_body.fkf1176 PRE_first_tail_x8_r0_body.fkt1176 PRE_first_tail_x8_r0_body.fkck176,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0176 PRE_first_tail_x8_r0_body.cnh1176 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe176) PRE_first_tail_x8_r0_body.cpendR176⟩

end Host.Load.Run.Tpl
end

section -- st176/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st176 0
host_stream_state PRE_first_tail_x8_r0_body.st176 1
host_stream_state PRE_first_tail_x8_r0_body.st176 2
end Host.Load.Run.Tpl
end

section -- Site176
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 176 of chain `PRE_first_tail_x8_r0_body`: `plan__g176__g177` (`plan`), the call state `PRE_first_tail_x8_r0_body.s1696`, the merged state `PRE_first_tail_x8_r0_body.s1697`,
the site template `PRE_first_tail_x8_r0_body.st176` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1698`: the merge.
The footprint's facts are in `SiteF176`, the compaction's in `SiteC176`, `SiteK176`, `SiteNa176`, `SiteNb176`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso176 : PRE_first_tail_x8_r0_body.st176.s0 = { PRE_first_tail_x8_r0_body.s1696 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs176 : List Frame := PRE_first_tail_x8_r0_body.s1696.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_176 : PRE_first_tail_x8_r0_body.S1696.tab.length = 7579
kernel_rfl PRE_first_tail_x8_r0_body.tab0_176 : PRE_first_tail_x8_r0_body.st176.S0.tab = PRE_first_tail_x8_r0_body.S1696.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws176 : List Nat := [3981, 3982, 3983, 3984, 3985, 3986, 3987, 3988, 3989]
kernel_rfl PRE_first_tail_x8_r0_body.fresh176 : (PRE_first_tail_x8_r0_body.S1696.tab.all fun e => PRE_first_tail_x8_r0_body.ws176.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1696.oracle.all fun q => PRE_first_tail_x8_r0_body.ws176.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab176 : PRE_first_tail_x8_r0_body.S1697.tab = PRE_first_tail_x8_r0_body.S1696.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws176
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen176 : PRE_first_tail_x8_r0_body.st176.S2.tab.length - PRE_first_tail_x8_r0_body.st176.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged176`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap176 : PRE_first_tail_x8_r0_body.s1697.heap = PRE_first_tail_x8_r0_body.st176.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext176 : PRE_first_tail_x8_r0_body.s1697.next = PRE_first_tail_x8_r0_body.st176.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl176 : PRE_first_tail_x8_r0_body.s1697.ctl = PRE_first_tail_x8_r0_body.st176.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack176 : PRE_first_tail_x8_r0_body.s1697.stack = PRE_first_tail_x8_r0_body.st176.s2.stack ++ PRE_first_tail_x8_r0_body.s1696.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs176 : PRE_first_tail_x8_r0_body.s1697.jobs = PRE_first_tail_x8_r0_body.st176.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi176 : PRE_first_tail_x8_r0_body.s1697.ffi = PRE_first_tail_x8_r0_body.st176.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace176 : PRE_first_tail_x8_r0_body.s1697.trace = PRE_first_tail_x8_r0_body.st176.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores176 : PRE_first_tail_x8_r0_body.s1697.stores = PRE_first_tail_x8_r0_body.st176.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD176
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 176 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived176 : PRE_first_tail_x8_r0_body.nr176.map (fun r => nth? PRE_first_tail_x8_r0_body.st176.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo176 : PRE_first_tail_x8_r0_body.nr176.all (Nat.ble 7579) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj176 : PRE_first_tail_x8_r0_body.cws176.all (fun c => !PRE_first_tail_x8_r0_body.ws176.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ176 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws176 PRE_first_tail_x8_r0_body.crs176 PRE_first_tail_x8_r0_body.ws176

end Host.Load.Run.Tpl
end

section -- st176/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st176`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st176.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st176.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st176.s2.heap PRE_first_tail_x8_r0_body.st176.wrR ++ freshOf PRE_first_tail_x8_r0_body.st176.s2.heap PRE_first_tail_x8_r0_body.st176.s0.next PRE_first_tail_x8_r0_body.st176.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st176.wr : List Nat := PRE_first_tail_x8_r0_body.st176.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st176.heapFoot : PRE_first_tail_x8_r0_body.st176.s2.heap = setAll PRE_first_tail_x8_r0_body.st176.s0.heap PRE_first_tail_x8_r0_body.st176.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st176.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st176.s0.next PRE_first_tail_x8_r0_body.st176.s2.next = true
theorem PRE_first_tail_x8_r0_body.st176.grows : PRE_first_tail_x8_r0_body.st176.s0.next ≤ PRE_first_tail_x8_r0_body.st176.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st176.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st176.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st176.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st176.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st176.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st176.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st176.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st176.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st176.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st176.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st176.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st176.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF176
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 176 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB176 : nodupT PRE_first_tail_x8_r0_body.st176.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup176 : PRE_first_tail_x8_r0_body.st176.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB176).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB176 : PRE_first_tail_x8_r0_body.st176.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound176 : ∀ b ∈ PRE_first_tail_x8_r0_body.st176.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB176 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr176 := PRE_first_tail_x8_r0_body.st176.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq176 : PRE_first_tail_x8_r0_body.st176.s2.trace = PRE_first_tail_x8_r0_body.trFr176 ++ PRE_first_tail_x8_r0_body.st176.s0.trace
theorem PRE_first_tail_x8_r0_body.trace176 : ∃ fr, PRE_first_tail_x8_r0_body.st176.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st176.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq176⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide176 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB176 : (PRE_first_tail_x8_r0_body.wide176.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st176.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix176 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide176, WFix Map.id (Present PRE_first_tail_x8_r0_body.st176.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB176 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL176
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 176 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1697`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO176 : PRE_first_tail_x8_r0_body.st176.S0.oracle = PRE_first_tail_x8_r0_body.st176.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B176 : PRE_first_tail_x8_r0_body.st176.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st176.s0.next || (PRE_first_tail_x8_r0_body.st176.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot176 : Conv.StageFoot PRE_first_tail_x8_r0_body.st176.wr PRE_first_tail_x8_r0_body.st176.s0 PRE_first_tail_x8_r0_body.st176.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st176.heapFoot PRE_first_tail_x8_r0_body.wrNodup176 PRE_first_tail_x8_r0_body.wrBound176 PRE_first_tail_x8_r0_body.wr0B176 PRE_first_tail_x8_r0_body.st176.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged176 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st176.F.S → PRE_first_tail_x8_r0_body.st176.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st176.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st176.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs176 PRE_first_tail_x8_r0_body.st176.wr PRE_first_tail_x8_r0_body.s1696 PRE_first_tail_x8_r0_body.st176.s2 PRE_first_tail_x8_r0_body.st176.s0
      PRE_first_tail_x8_r0_body.st176.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st176.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1697 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso176 PRE_first_tail_x8_r0_body.stFoot176 PRE_first_tail_x8_r0_body.wrNodup176 PRE_first_tail_x8_r0_body.wrBound176 PRE_first_tail_x8_r0_body.trace176 PRE_first_tail_x8_r0_body.mheap176
    PRE_first_tail_x8_r0_body.mnext176 PRE_first_tail_x8_r0_body.mctl176 PRE_first_tail_x8_r0_body.mstack176 PRE_first_tail_x8_r0_body.mjobs176 PRE_first_tail_x8_r0_body.mffi176 PRE_first_tail_x8_r0_body.mtrace176 PRE_first_tail_x8_r0_body.mstores176 h

def PRE_first_tail_x8_r0_body.arrEl176_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE176_2665 : arrOf PRE_first_tail_x8_r0_body.s1697 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl176_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA176_2665 : isArrB PRE_first_tail_x8_r0_body.s1697 2665 = true
theorem PRE_first_tail_x8_r0_body.arr176_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1697.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl176_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE176_2665 PRE_first_tail_x8_r0_body.arrA176_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN176_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl176_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR176_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl176_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN176_2665

def PRE_first_tail_x8_r0_body.arrEl176_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE176_2673467 : arrOf PRE_first_tail_x8_r0_body.s1697 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl176_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA176_2673467 : isArrB PRE_first_tail_x8_r0_body.s1697 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr176_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1697.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl176_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE176_2673467 PRE_first_tail_x8_r0_body.arrA176_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN176_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl176_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR176_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl176_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN176_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k176 : isArrB PRE_first_tail_x8_r0_body.s1697 4910 = false
theorem PRE_first_tail_x8_r0_body.keep176 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1697 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k176 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr176_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl176_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ176
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 176 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1696`, the merged
state `PRE_first_tail_x8_r0_body.s1697`, the canonical state `PRE_first_tail_x8_r0_body.s1698`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl176 : PRE_first_tail_x8_r0_body.pl176.all (Nat.ble PRE_first_tail_x8_r0_body.s1696.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd176 : nodupT PRE_first_tail_x8_r0_body.pl176 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1176 : Nat.ble PRE_first_tail_x8_r0_body.s1696.next 2812624 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst176 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1696.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn176 : PRE_first_tail_x8_r0_body.s1698.next = PRE_first_tail_x8_r0_body.s1696.next + PRE_first_tail_x8_r0_body.pl176.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn176 : PRE_first_tail_x8_r0_body.s1697.next = 2812624
kernel_rfl PRE_first_tail_x8_r0_body.zgrow176 : Nat.ble PRE_first_tail_x8_r0_body.s1698.next PRE_first_tail_x8_r0_body.s1697.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh176 : PRE_first_tail_x8_r0_body.S1696.tab.all (fun e => PRE_first_tail_x8_r0_body.cws176.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd176 : nodupT PRE_first_tail_x8_r0_body.cws176 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi176 : PRE_first_tail_x8_r0_body.nr176.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1697.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt176 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1696.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg176_2665 : PRE_first_tail_x8_r0_body.s1698.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1698 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk176_2665 : (objOf PRE_first_tail_x8_r0_body.s1698 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm176_2665 : PRE_first_tail_x8_r0_body.s1697.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa176.obj (objOf PRE_first_tail_x8_r0_body.s1698 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1697 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg176_2673467 : PRE_first_tail_x8_r0_body.s1698.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1698 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk176_2673467 : (objOf PRE_first_tail_x8_r0_body.s1698 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm176_2673467 : PRE_first_tail_x8_r0_body.s1697.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa176.obj (objOf PRE_first_tail_x8_r0_body.s1698 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1697 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw176_4910 : (PRE_first_tail_x8_r0_body.s1698.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw176_2673472 : (PRE_first_tail_x8_r0_body.s1698.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw176_2673473 : (PRE_first_tail_x8_r0_body.s1698.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd176 : PRE_first_tail_x8_r0_body.cl176.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr176 : PRE_first_tail_x8_r0_body.st176.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1696.next || PRE_first_tail_x8_r0_body.cl176.contains b) = true
def PRE_first_tail_x8_r0_body.zl176 : List Nat := PRE_first_tail_x8_r0_body.cl176.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE176 : PRE_first_tail_x8_r0_body.zl176.map (fun a => PRE_first_tail_x8_r0_body.s1697.heap.get (PRE_first_tail_x8_r0_body.kappa176.a a)) = PRE_first_tail_x8_r0_body.zl176.map (fun a => (PRE_first_tail_x8_r0_body.s1698.heap.get a).map PRE_first_tail_x8_r0_body.kappa176.hobj)
theorem PRE_first_tail_x8_r0_body.zimg176 : HeapImg PRE_first_tail_x8_r0_body.kappa176 PRE_first_tail_x8_r0_body.s1698 PRE_first_tail_x8_r0_body.s1697 PRE_first_tail_x8_r0_body.zl176 := PRE_first_tail_x8_r0_body.zimgE176
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl176 : PRE_first_tail_x8_r0_body.s1697.ctl = PRE_first_tail_x8_r0_body.kappa176.ctl PRE_first_tail_x8_r0_body.s1698.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack176 : PRE_first_tail_x8_r0_body.s1697.stack = PRE_first_tail_x8_r0_body.s1698.stack.map PRE_first_tail_x8_r0_body.kappa176.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs176 : PRE_first_tail_x8_r0_body.s1697.jobs = PRE_first_tail_x8_r0_body.s1698.jobs.map PRE_first_tail_x8_r0_body.kappa176.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores176 : PRE_first_tail_x8_r0_body.s1697.stores = PRE_first_tail_x8_r0_body.kappa176.stores PRE_first_tail_x8_r0_body.s1698.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots176 : checkRootsSupp PRE_first_tail_x8_r0_body.s1698 7579 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC176 : PRE_first_tail_x8_r0_body.S1696.tab.length + PRE_first_tail_x8_r0_body.cws176.length = 7579
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap176 : PRE_first_tail_x8_r0_body.kappa176 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1696.next 2812624 PRE_first_tail_x8_r0_body.S1696.tab.length PRE_first_tail_x8_r0_body.pl176 (PRE_first_tail_x8_r0_body.nr176.map NumV.ref) PRE_first_tail_x8_r0_body.kd176.big
  PRE_first_tail_x8_r0_body.kd176.region PRE_first_tail_x8_r0_body.kd176.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin176 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1698.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc176 : Conv.jcleanListB (⟨21657, 18766, 2812604, 7579⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1698 PRE_first_tail_x8_r0_body.cl176 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB176 : noBigRootsP (fun i => !Conv.oldBigB (⟨21657, 18766, 2812604, 7579⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1698.trace PRE_first_tail_x8_r0_body.s1698 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm176 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18766 = true
theorem PRE_first_tail_x8_r0_body.cjcl176 (h : Conv.JClean (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1696) : Conv.JClean (⟨21657, 18766, 2812604, 7579⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1698 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle176)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap176 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd176 a ha)) PRE_first_tail_x8_r0_body.zjc176

end Host.Load.Run.Tpl
end

section -- st176/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st176.bodyLast from PRE_first_tail_x8_r0_body.st176.s1 to PRE_first_tail_x8_r0_body.st176.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st176.F PRE_first_tail_x8_r0_body.st176.s1).run PRE_first_tail_x8_r0_body.st176.S1 = some (PRE_first_tail_x8_r0_body.st176.s2, PRE_first_tail_x8_r0_body.st176.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st176.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st176.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st176.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st176.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st176/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st176.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st176.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st176.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st176.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st176.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st176.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st176.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st176.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st176.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st176.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st176.s0 PRE_first_tail_x8_r0_body.st176.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st176.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st176.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st176.s1 PRE_first_tail_x8_r0_body.st176.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st176/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st176.bodyK0F from PRE_first_tail_x8_r0_body.st176.s0 to PRE_first_tail_x8_r0_body.st176.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st176.F (PRE_first_tail_x8_r0_body.st176.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st176.ks 0).getD 0) PRE_first_tail_x8_r0_body.st176.s0 PRE_first_tail_x8_r0_body.st176.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st176.s1, PRE_first_tail_x8_r0_body.st176.S1)
theorem PRE_first_tail_x8_r0_body.st176.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st176.F (PRE_first_tail_x8_r0_body.st176.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st176.ks 0).getD 0) PRE_first_tail_x8_r0_body.st176.s0 PRE_first_tail_x8_r0_body.st176.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st176.s1, PRE_first_tail_x8_r0_body.st176.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st176.bodyOkLN_ok PRE_first_tail_x8_r0_body.st176.bodyK0F
end Host.Load.Run.Tpl
end

section -- st176/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st176.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st176.F (PRE_first_tail_x8_r0_body.st176.bodyOkL bytes rows) 214 PRE_first_tail_x8_r0_body.st176.s0 PRE_first_tail_x8_r0_body.st176.S0 = some (PRE_first_tail_x8_r0_body.st176.s1, PRE_first_tail_x8_r0_body.st176.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st176.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st176.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st176.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st176.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st176.F (PRE_first_tail_x8_r0_body.st176.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st176.s0
  S0 := PRE_first_tail_x8_r0_body.st176.S0
  s1 := PRE_first_tail_x8_r0_body.st176.s1
  S1 := PRE_first_tail_x8_r0_body.st176.S1
  s2 := PRE_first_tail_x8_r0_body.st176.s2
  S2 := PRE_first_tail_x8_r0_body.st176.S2
  n := 214
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st176.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st176.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st176.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st176.bodyHalt
  last := PRE_first_tail_x8_r0_body.st176.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st176.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC177
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 177 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1714` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa177` into the merged state
`PRE_first_tail_x8_r0_body.s1713`. -/

def PRE_first_tail_x8_r0_body.pl177 : List Nat := [2814706, 2814542, 2814594, 2814707, 2814708, 2814544, 2814596, 2814705, 2814704, 2814703, 2814702, 2814696, 2814647, 2814698, 2814649]
def PRE_first_tail_x8_r0_body.nr177 : List Nat := [7664, 7665, 7661, 7667, 7663, 7671, 7672, 7669, 7670]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd177 : RData :=
  ⟨2814359, 2814709, Stage.setAll PTrie.nil [(2814344, 2814706), (2814345, 2814542), (2814346, 2814594), (2814347, 2814707), (2814348, 2814708), (2814349, 2814544), (2814350, 2814596), (2814351, 2814705), (2814352, 2814704), (2814353, 2814703), (2814354, 2814702), (2814355, 2814696), (2814356, 2814647), (2814357, 2814698), (2814358, 2814649)], Stage.setAll PTrie.nil [(21697, 21699), (21698, 21700), (21699, 21702), (21700, 21701)],
   21701, 21703, 18800, 18800, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(7656, .ref 7664), (7657, .ref 7665), (7658, .ref 7661), (7659, .ref 7667), (7660, .ref 7663), (7661, .ref 7671), (7662, .ref 7672), (7663, .ref 7669), (7664, .ref 7670)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa177 : Map :=
  Conv.Map.compact 2814344 2814709 7656 PRE_first_tail_x8_r0_body.pl177 (PRE_first_tail_x8_r0_body.nr177.map NumV.ref) PRE_first_tail_x8_r0_body.kd177.big
    PRE_first_tail_x8_r0_body.kd177.region PRE_first_tail_x8_r0_body.kd177.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws177 : List Nat := [4007, 4008, 4009, 4010, 4011, 4012, 4013, 4014, 4015]
noncomputable def PRE_first_tail_x8_r0_body.crs177 : List SymE := PRE_first_tail_x8_r0_body.nr177.map fun r => (nth? PRE_first_tail_x8_r0_body.S1713.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta177 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws177 PRE_first_tail_x8_r0_body.crs177
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB177 : List Nat := [2665, 2672756, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab177 : PRE_first_tail_x8_r0_body.S1714.tab = PRE_first_tail_x8_r0_body.S1712.tab ++ PRE_first_tail_x8_r0_body.cws177.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace177 : PRE_first_tail_x8_r0_body.s1714.trace = PRE_first_tail_x8_r0_body.s1712.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext177 : PRE_first_tail_x8_r0_body.s1714.next = 2814359
kernel_rfl PRE_first_tail_x8_r0_body.ccounters177 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx.nnext) = (21701, 18800)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue177 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1713.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa177.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp177 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx.tokens.all (bSN 7665) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean177 : Conv.cleanListB 21701 131072 (fun r => Nat.ble 86804 r) PRE_first_tail_x8_r0_body.s1714
    (PRE_first_tail_x8_r0_body.wrB177 ++ (List.range 15).map (2814344 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs177 : bigsOutB 21701 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK177
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl177`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl177 : List Nat := [2665, 2672756, 2673467, 2814344, 2814345, 2814346, 2814347, 2814348, 2814349, 2814350, 2814351, 2814352, 2814353, 2814354, 2814355, 2814356, 2814357, 2814358]
def PRE_first_tail_x8_r0_body.clo177 : List Nat := [21697, 21698, 21699, 21700]
def PRE_first_tail_x8_r0_body.cln177 : List Nat := [18794, 18795, 18796, 18797, 18798, 18799]
def PRE_first_tail_x8_r0_body.cli177 : List Nat := [18794, 18795, 18796, 18797, 18798, 18799]
kernel_rfl PRE_first_tail_x8_r0_body.cheap177 : PRE_first_tail_x8_r0_body.s1714.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1712.heap (PRE_first_tail_x8_r0_body.cl177.filterMap fun a => (PRE_first_tail_x8_r0_body.s1714.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe177 : Nat.ble PRE_first_tail_x8_r0_body.s1712.next PRE_first_tail_x8_r0_body.s1714.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP177 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1712 PRE_first_tail_x8_r0_body.s1714 PRE_first_tail_x8_r0_body.cl177 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp177 : Conv.suppListB PRE_first_tail_x8_r0_body.s1714 7665 PRE_first_tail_x8_r0_body.cl177 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound177 : Conv.boundListB PRE_first_tail_x8_r0_body.s1714 PRE_first_tail_x8_r0_body.cl177 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK177 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln177.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK177 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo177.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK177 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli177.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst177 : Conv.sstListB 7665 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx PRE_first_tail_x8_r0_body.cln177 PRE_first_tail_x8_r0_body.clo177 PRE_first_tail_x8_r0_body.cli177 = true

end Host.Load.Run.Tpl
end

section -- SiteCl177
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA177 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo177.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd177 : (PRE_first_tail_x8_r0_body.clo177 ++ PRE_first_tail_x8_r0_body.cln177 ++ PRE_first_tail_x8_r0_body.cli177).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle177 : Conv.Cnt.leB (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt) (⟨21701, 18800, 2814359, 7665⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck177 : Conv.ncleanListB (⟨21701, 18800, 2814359, 7665⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx PRE_first_tail_x8_r0_body.clo177 PRE_first_tail_x8_r0_body.cln177 PRE_first_tail_x8_r0_body.cli177 = true
theorem PRE_first_tail_x8_r0_body.cncl177 (h : Conv.NClean (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx) : Conv.NClean (⟨21701, 18800, 2814359, 7665⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle177 PRE_first_tail_x8_r0_body.ckA177 PRE_first_tail_x8_r0_body.cobjsK177 PRE_first_tail_x8_r0_body.cnodesK177 PRE_first_tail_x8_r0_body.citemsK177 PRE_first_tail_x8_r0_body.cbd177 PRE_first_tail_x8_r0_body.cck177

end Host.Load.Run.Tpl
end

section -- SiteS177
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 177 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc177 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P177 : LoadP := PRE_first_tail_x8_r0_body.Pc177.raise 18800
kernel_rfl PRE_first_tail_x8_r0_body.craise177 : Nat.ble PRE_first_tail_x8_r0_body.Pc177.N0 18800 = true
theorem PRE_first_tail_x8_r0_body.raised177 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc177 PRE_first_tail_x8_r0_body.P177 :=
  .inr ⟨18800, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise177, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_177 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_177 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1713.ffi)
def PRE_first_tail_x8_r0_body.khinv177 : PTrie Nat := Stage.setAll PTrie.nil [(21699, 21697), (21700, 21698), (21702, 21699), (21701, 21700)]
def PRE_first_tail_x8_r0_body.kninv177 : PTrie Nat := Stage.setAll PTrie.nil [(18794, 18794), (18795, 18795), (18796, 18796), (18797, 18797), (18798, 18798), (18799, 18799)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS177 : List Nat := [21697, 21698, 21699, 21700, 21701, 21702]
def PRE_first_tail_x8_r0_body.cnS177 : List Nat := List.range' 18794 6
def PRE_first_tail_x8_r0_body.ciS177 : List Nat := [] ++ List.range' 18794 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0177 : PRE_first_tail_x8_r0_body.kd177.nh0 = PRE_first_tail_x8_r0_body.cx0_177.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1177 : PRE_first_tail_x8_r0_body.kd177.nh1 = PRE_first_tail_x8_r0_body.cx1_177.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0177 : PRE_first_tail_x8_r0_body.kd177.nn0 = PRE_first_tail_x8_r0_body.cx0_177.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1177 : PRE_first_tail_x8_r0_body.kd177.nn1 = PRE_first_tail_x8_r0_body.cx1_177.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo177 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P177.lo && Nat.ble PRE_first_tail_x8_r0_body.P177.lo PRE_first_tail_x8_r0_body.cx0_177.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P177.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P177.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt177 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_177.mlx.next PRE_first_tail_x8_r0_body.cx1_177.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_177.mlx.nnext PRE_first_tail_x8_r0_body.cx1_177.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband177 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P177.NL && Nat.ble PRE_first_tail_x8_r0_body.P177.NL PRE_first_tail_x8_r0_body.P177.N0 && Nat.ble PRE_first_tail_x8_r0_body.P177.N0 PRE_first_tail_x8_r0_body.cx0_177.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow177 : PRE_first_tail_x8_r0_body.kd177.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren177 : checkRenG PRE_first_tail_x8_r0_body.kd177.hnd PRE_first_tail_x8_r0_body.khinv177 (phB PRE_first_tail_x8_r0_body.cx0_177.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband177 : PRE_first_tail_x8_r0_body.kd177.checkBand PRE_first_tail_x8_r0_body.P177.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos177 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd177.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren177 : checkRenG PRE_first_tail_x8_r0_body.kd177.node PRE_first_tail_x8_r0_body.kninv177 (pnB PRE_first_tail_x8_r0_body.cx0_177.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow177 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd177.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P177.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd177.nodeF j) PRE_first_tail_x8_r0_body.cx1_177.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a177 : PRE_first_tail_x8_r0_body.cx0_177.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b177 : PRE_first_tail_x8_r0_body.cx0_177.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1177 : PRE_first_tail_x8_r0_body.cx1_177.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend177 : PRE_first_tail_x8_r0_body.cx1_177.mlx.pending = PRE_first_tail_x8_r0_body.cx0_177.mlx.pending.map PRE_first_tail_x8_r0_body.kappa177.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh177 : PRE_first_tail_x8_r0_body.cx1_177.mlx.errh = PRE_first_tail_x8_r0_body.cx0_177.mlx.errh.map PRE_first_tail_x8_r0_body.kappa177.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles177 : PRE_first_tail_x8_r0_body.cx1_177.mlx.files = PRE_first_tail_x8_r0_body.cx0_177.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch177 : PRE_first_tail_x8_r0_body.cx1_177.mlx.arch = PRE_first_tail_x8_r0_body.cx0_177.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes177 : PRE_first_tail_x8_r0_body.cx1_177.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_177.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired177 : PRE_first_tail_x8_r0_body.cx1_177.mlx.wired = PRE_first_tail_x8_r0_body.cx0_177.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost177 : PRE_first_tail_x8_r0_body.cx1_177.host = PRE_first_tail_x8_r0_body.cx0_177.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd177`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0177 : PRE_first_tail_x8_r0_body.kd177.n0 = 2814359
kernel_rfl PRE_first_tail_x8_r0_body.ckn1177 : PRE_first_tail_x8_r0_body.kd177.n1 = 2814709
kernel_rfl PRE_first_tail_x8_r0_body.ckheap177 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd177.heap).all (fun x => Nat.ble 2814344 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl177 : (List.range 15).all (fun j => decide (PRE_first_tail_x8_r0_body.kd177.heap.get (2814344 + j) = nth? PRE_first_tail_x8_r0_body.pl177 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja177 : Nat.ble 2814344 2814344 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn177 : Nat.ble 7656 7656 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD177 : Nat.ble 2814344 PRE_first_tail_x8_r0_body.kd177.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn177 : Nat.ble 21697 PRE_first_tail_x8_r0_body.kd177.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn177 : Nat.ble 18794 PRE_first_tail_x8_r0_body.kd177.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb177 : Nat.ble 21697 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap177 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd177.heap).all (Nat.ble (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd177 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd177.hnd).all (Nat.ble (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode177 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd177.node).all (Nat.ble (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix177 : Conv.FixOld (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa177 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja177) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn177) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD177) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn177) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn177) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb177) PRE_first_tail_x8_r0_body.fheap177 PRE_first_tail_x8_r0_body.fhnd177 PRE_first_tail_x8_r0_body.fnode177
kernel_rfl PRE_first_tail_x8_r0_body.fcxn177 : (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn177 : (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0177 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_177.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_177.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk177 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd177.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A177 : PRE_first_tail_x8_r0_body.cx1_177.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS177.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_177.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O177 : PRE_first_tail_x8_r0_body.cx1_177.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS177.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_177.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N177 : PRE_first_tail_x8_r0_body.cx1_177.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS177.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_177.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I177 : PRE_first_tail_x8_r0_body.cx1_177.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS177.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_177.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd177 : (PRE_first_tail_x8_r0_body.clo177 ++ PRE_first_tail_x8_r0_body.cln177 ++ PRE_first_tail_x8_r0_body.cli177 ++ PRE_first_tail_x8_r0_body.cwS177 ++ PRE_first_tail_x8_r0_body.cnS177 ++ PRE_first_tail_x8_r0_body.ciS177).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW177 : PRE_first_tail_x8_r0_body.cwS177.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo177.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI177 : PRE_first_tail_x8_r0_body.ciS177.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli177.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN177 : PRE_first_tail_x8_r0_body.cnS177.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF177 : PRE_first_tail_x8_r0_body.cln177.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh177 : PRE_first_tail_x8_r0_body.clo177.all (handleOK PRE_first_tail_x8_r0_body.kappa177 PRE_first_tail_x8_r0_body.P177.lo PRE_first_tail_x8_r0_body.cx0_177.mlx PRE_first_tail_x8_r0_body.cx1_177.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo177 : PRE_first_tail_x8_r0_body.clo177.map (fun h => PRE_first_tail_x8_r0_body.cx1_177.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa177.handle h)) = PRE_first_tail_x8_r0_body.clo177.map (fun h => (PRE_first_tail_x8_r0_body.cx0_177.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa177.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok177 : PRE_first_tail_x8_r0_body.clo177.all (objOK PRE_first_tail_x8_r0_body.kappa177 PRE_first_tail_x8_r0_body.P177.NL PRE_first_tail_x8_r0_body.cx0_177.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd177 : PRE_first_tail_x8_r0_body.cln177.all (nodeOKF PRE_first_tail_x8_r0_body.kappa177 PRE_first_tail_x8_r0_body.P177 PRE_first_tail_x8_r0_body.cx0_177.mlx PRE_first_tail_x8_r0_body.cx1_177.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp177 : ((PRE_first_tail_x8_r0_body.cln177.filter (fullB PRE_first_tail_x8_r0_body.P177))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_177.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa177.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln177.filter (fullB PRE_first_tail_x8_r0_body.P177))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_177.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa177.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI177 : incrB PRE_first_tail_x8_r0_body.kd177.nodeF (List.range' 18794 6) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK177 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd177.node).all (fun k => Nat.ble 18794 k && Nat.blt k 18800) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL177 : (PRE_first_tail_x8_r0_body.cln177.filter (Nat.ble PRE_first_tail_x8_r0_body.P177.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd177.nodeF i) && (Nat.blt i 18800 || Nat.ble PRE_first_tail_x8_r0_body.kd177.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord177 : (PRE_first_tail_x8_r0_body.cln177.filter (Nat.ble PRE_first_tail_x8_r0_body.P177.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd177.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd177.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd177.nodeF j) (PRE_first_tail_x8_r0_body.kd177.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow177 PRE_first_tail_x8_r0_body.cnn1177 PRE_first_tail_x8_r0_body.fnordI177 PRE_first_tail_x8_r0_body.fnordK177 PRE_first_tail_x8_r0_body.fnordL177
kernel_rfl PRE_first_tail_x8_r0_body.fi177 : PRE_first_tail_x8_r0_body.cli177.all (pnB PRE_first_tail_x8_r0_body.cx0_177.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii177 : PRE_first_tail_x8_r0_body.cli177.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_177.mlx.items.get (PRE_first_tail_x8_r0_body.kappa177.node k) = (PRE_first_tail_x8_r0_body.cx0_177.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa177.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot177 (clean : Conv.NClean (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P177.NL) (cl : SSt (· < 7665) PRE_first_tail_x8_r0_body.cx0_177.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P177 7665 PRE_first_tail_x8_r0_body.kappa177 PRE_first_tail_x8_r0_body.kd177 PRE_first_tail_x8_r0_body.khinv177 PRE_first_tail_x8_r0_body.kninv177 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx PRE_first_tail_x8_r0_body.cx0_177.mlx PRE_first_tail_x8_r0_body.cx1_177.mlx (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo177 PRE_first_tail_x8_r0_body.cln177 PRE_first_tail_x8_r0_body.cli177 PRE_first_tail_x8_r0_body.cwS177 PRE_first_tail_x8_r0_body.cnS177 PRE_first_tail_x8_r0_body.ciS177 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0177, PRE_first_tail_x8_r0_body.cnh1177, PRE_first_tail_x8_r0_body.cnn0177, PRE_first_tail_x8_r0_body.cnn1177, PRE_first_tail_x8_r0_body.cplo177, PRE_first_tail_x8_r0_body.ccnt177, PRE_first_tail_x8_r0_body.cnband177, PRE_first_tail_x8_r0_body.chbelow177, PRE_first_tail_x8_r0_body.chren177, PRE_first_tail_x8_r0_body.cband177, PRE_first_tail_x8_r0_body.cnh1pos177, PRE_first_tail_x8_r0_body.cnren177, PRE_first_tail_x8_r0_body.cnlow177, PRE_first_tail_x8_r0_body.cabs0a177, PRE_first_tail_x8_r0_body.cabs0b177, PRE_first_tail_x8_r0_body.ctok1177, PRE_first_tail_x8_r0_body.cpend177, PRE_first_tail_x8_r0_body.cerrh177, PRE_first_tail_x8_r0_body.cfiles177, PRE_first_tail_x8_r0_body.carch177, PRE_first_tail_x8_r0_body.csizes177, PRE_first_tail_x8_r0_body.cwired177, PRE_first_tail_x8_r0_body.cfix177, clean, PRE_first_tail_x8_r0_body.fcxn177, PRE_first_tail_x8_r0_body.fcnn177, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0177, PRE_first_tail_x8_r0_body.fnk177, PRE_first_tail_x8_r0_body.ckA177, PRE_first_tail_x8_r0_body.cobjsK177, PRE_first_tail_x8_r0_body.cnodesK177, PRE_first_tail_x8_r0_body.citemsK177, PRE_first_tail_x8_r0_body.f1A177, PRE_first_tail_x8_r0_body.f1O177, PRE_first_tail_x8_r0_body.f1N177, PRE_first_tail_x8_r0_body.f1I177, PRE_first_tail_x8_r0_body.fbd177, PRE_first_tail_x8_r0_body.fincW177, PRE_first_tail_x8_r0_body.fincI177, PRE_first_tail_x8_r0_body.fincN177, PRE_first_tail_x8_r0_body.flnF177, PRE_first_tail_x8_r0_body.fh177, PRE_first_tail_x8_r0_body.fo177, PRE_first_tail_x8_r0_body.fok177, PRE_first_tail_x8_r0_body.fnd177, PRE_first_tail_x8_r0_body.fp177, PRE_first_tail_x8_r0_body.fnord177, PRE_first_tail_x8_r0_body.fi177, PRE_first_tail_x8_r0_body.fii177⟩
theorem PRE_first_tail_x8_r0_body.cnshift177 (clean : Conv.NClean (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P177.NL) (cl : SSt (· < 7665) PRE_first_tail_x8_r0_body.cx0_177.mlx) : NShift PRE_first_tail_x8_r0_body.P177 7665 PRE_first_tail_x8_r0_body.kappa177 PRE_first_tail_x8_r0_body.cx0_177 PRE_first_tail_x8_r0_body.cx1_177 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot177 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost177 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0177 PRE_first_tail_x8_r0_body.ckn1177 PRE_first_tail_x8_r0_body.ckheap177 PRE_first_tail_x8_r0_body.ckpl177)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_177 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1712.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_177 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1712.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_177 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1712.ffi) = some PRE_first_tail_x8_r0_body.fxC_177
kernel_rfl PRE_first_tail_x8_r0_body.okrC_177 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1712.ffi) = some PRE_first_tail_x8_r0_body.krC_177
noncomputable def PRE_first_tail_x8_r0_body.fx0_177 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1714.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_177 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1714.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_177 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1714.ffi) = some PRE_first_tail_x8_r0_body.fx0_177
kernel_rfl PRE_first_tail_x8_r0_body.okr0_177 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1714.ffi) = some PRE_first_tail_x8_r0_body.kr0_177
noncomputable def PRE_first_tail_x8_r0_body.fx1_177 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1713.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_177 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1713.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_177 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1713.ffi) = some PRE_first_tail_x8_r0_body.fx1_177
kernel_rfl PRE_first_tail_x8_r0_body.okr1_177 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1713.ffi) = some PRE_first_tail_x8_r0_body.kr1_177
kernel_rfl PRE_first_tail_x8_r0_body.ff0177 : PRE_first_tail_x8_r0_body.fx0_177 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_177 (PRE_first_tail_x8_r0_body.clo177.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_177.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1177 : PRE_first_tail_x8_r0_body.fx1_177 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_177 (PRE_first_tail_x8_r0_body.cwS177.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_177.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck177 : freedLB PRE_first_tail_x8_r0_body.kappa177 PRE_first_tail_x8_r0_body.cx0_177.mlx PRE_first_tail_x8_r0_body.fx0_177 PRE_first_tail_x8_r0_body.fx1_177 PRE_first_tail_x8_r0_body.clo177 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0177 : PRE_first_tail_x8_r0_body.kr0_177.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_177.flags (PRE_first_tail_x8_r0_body.clo177.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_177.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0177 : PRE_first_tail_x8_r0_body.kr0_177.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_177.targs (PRE_first_tail_x8_r0_body.clo177.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_177.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1177 : PRE_first_tail_x8_r0_body.kr1_177.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_177.flags (PRE_first_tail_x8_r0_body.cwS177.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_177.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1177 : PRE_first_tail_x8_r0_body.kr1_177.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_177.targs (PRE_first_tail_x8_r0_body.cwS177.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_177.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck177 : krecLB PRE_first_tail_x8_r0_body.kappa177 7665 PRE_first_tail_x8_r0_body.cx0_177.mlx PRE_first_tail_x8_r0_body.kr0_177 PRE_first_tail_x8_r0_body.kr1_177 PRE_first_tail_x8_r0_body.clo177 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn177 : Nat.ble 7656 7665 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge177 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1713.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1714.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR177 : pendRegB PRE_first_tail_x8_r0_body.kappa177 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe177 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1714.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1713.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift177 (clean : Conv.NClean (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P177.NL) (cl : SSt (· < 7665) PRE_first_tail_x8_r0_body.cx0_177.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_177.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_177.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_177.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1712.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_177.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P177 7665 PRE_first_tail_x8_r0_body.kappa177 PRE_first_tail_x8_r0_body.s1714.ffi PRE_first_tail_x8_r0_body.s1713.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift177 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue177, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp177 t ht),
    PRE_first_tail_x8_r0_body.cbridge177,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1714.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1713.ffi) (PRE_first_tail_x8_r0_body.cfoot177 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_177 PRE_first_tail_x8_r0_body.ofx1_177 hobjC PRE_first_tail_x8_r0_body.ff0177 PRE_first_tail_x8_r0_body.ff1177 PRE_first_tail_x8_r0_body.ffck177,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1714.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1713.ffi) (PRE_first_tail_x8_r0_body.cfoot177 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_177 PRE_first_tail_x8_r0_body.okr1_177 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn177) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0177 PRE_first_tail_x8_r0_body.fkt0177 PRE_first_tail_x8_r0_body.fkf1177 PRE_first_tail_x8_r0_body.fkt1177 PRE_first_tail_x8_r0_body.fkck177,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0177 PRE_first_tail_x8_r0_body.cnh1177 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe177) PRE_first_tail_x8_r0_body.cpendR177⟩

end Host.Load.Run.Tpl
end

section -- st177/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st177 0
host_stream_state PRE_first_tail_x8_r0_body.st177 1
host_stream_state PRE_first_tail_x8_r0_body.st177 2
host_stream_state PRE_first_tail_x8_r0_body.st177 3
end Host.Load.Run.Tpl
end

section -- Site177
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 177 of chain `PRE_first_tail_x8_r0_body`: `kvW__g177__g178` (`appendWindow`), the call state `PRE_first_tail_x8_r0_body.s1712`, the merged state `PRE_first_tail_x8_r0_body.s1713`,
the site template `PRE_first_tail_x8_r0_body.st177` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1714`: the merge.
The footprint's facts are in `SiteF177`, the compaction's in `SiteC177`, `SiteK177`, `SiteNa177`, `SiteNb177`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso177 : PRE_first_tail_x8_r0_body.st177.s0 = { PRE_first_tail_x8_r0_body.s1712 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs177 : List Frame := PRE_first_tail_x8_r0_body.s1712.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_177 : PRE_first_tail_x8_r0_body.S1712.tab.length = 7656
kernel_rfl PRE_first_tail_x8_r0_body.tab0_177 : PRE_first_tail_x8_r0_body.st177.S0.tab = PRE_first_tail_x8_r0_body.S1712.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws177 : List Nat := [3990, 3991, 3992, 3993, 3994, 3995, 3996, 3997, 3998, 3999, 4000, 4001, 4002, 4003, 4004, 4005, 4006]
kernel_rfl PRE_first_tail_x8_r0_body.fresh177 : (PRE_first_tail_x8_r0_body.S1712.tab.all fun e => PRE_first_tail_x8_r0_body.ws177.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1712.oracle.all fun q => PRE_first_tail_x8_r0_body.ws177.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab177 : PRE_first_tail_x8_r0_body.S1713.tab = PRE_first_tail_x8_r0_body.S1712.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws177
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen177 : PRE_first_tail_x8_r0_body.st177.S3.tab.length - PRE_first_tail_x8_r0_body.st177.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged177`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap177 : PRE_first_tail_x8_r0_body.s1713.heap = PRE_first_tail_x8_r0_body.st177.s3.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext177 : PRE_first_tail_x8_r0_body.s1713.next = PRE_first_tail_x8_r0_body.st177.s3.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl177 : PRE_first_tail_x8_r0_body.s1713.ctl = PRE_first_tail_x8_r0_body.st177.s3.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack177 : PRE_first_tail_x8_r0_body.s1713.stack = PRE_first_tail_x8_r0_body.st177.s3.stack ++ PRE_first_tail_x8_r0_body.s1712.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs177 : PRE_first_tail_x8_r0_body.s1713.jobs = PRE_first_tail_x8_r0_body.st177.s3.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi177 : PRE_first_tail_x8_r0_body.s1713.ffi = PRE_first_tail_x8_r0_body.st177.s3.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace177 : PRE_first_tail_x8_r0_body.s1713.trace = PRE_first_tail_x8_r0_body.st177.s3.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores177 : PRE_first_tail_x8_r0_body.s1713.stores = PRE_first_tail_x8_r0_body.st177.s3.stores

end Host.Load.Run.Tpl
end

section -- SiteD177
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 177 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived177 : PRE_first_tail_x8_r0_body.nr177.map (fun r => nth? PRE_first_tail_x8_r0_body.st177.S3.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo177 : PRE_first_tail_x8_r0_body.nr177.all (Nat.ble 7656) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj177 : PRE_first_tail_x8_r0_body.cws177.all (fun c => !PRE_first_tail_x8_r0_body.ws177.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ177 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws177 PRE_first_tail_x8_r0_body.crs177 PRE_first_tail_x8_r0_body.ws177

end Host.Load.Run.Tpl
end

section -- st177/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st177`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st177.wrR : List (Nat × Nat) := [(2672756, 2672757)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st177.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st177.s3.heap PRE_first_tail_x8_r0_body.st177.wrR ++ freshOf PRE_first_tail_x8_r0_body.st177.s3.heap PRE_first_tail_x8_r0_body.st177.s0.next PRE_first_tail_x8_r0_body.st177.s3.next
noncomputable def PRE_first_tail_x8_r0_body.st177.wr : List Nat := PRE_first_tail_x8_r0_body.st177.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st177.heapFoot : PRE_first_tail_x8_r0_body.st177.s3.heap = setAll PRE_first_tail_x8_r0_body.st177.s0.heap PRE_first_tail_x8_r0_body.st177.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st177.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st177.s0.next PRE_first_tail_x8_r0_body.st177.s3.next = true
theorem PRE_first_tail_x8_r0_body.st177.grows : PRE_first_tail_x8_r0_body.st177.s0.next ≤ PRE_first_tail_x8_r0_body.st177.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st177.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st177.wh : List Nat := [21697, 21698, 21699, 21700, 21701, 21702]
def PRE_first_tail_x8_r0_body.st177.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st177.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st177.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st177.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st177.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st177.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st177.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st177.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st177.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st177.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF177
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 177 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB177 : nodupT PRE_first_tail_x8_r0_body.st177.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup177 : PRE_first_tail_x8_r0_body.st177.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB177).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB177 : PRE_first_tail_x8_r0_body.st177.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound177 : ∀ b ∈ PRE_first_tail_x8_r0_body.st177.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB177 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr177 := PRE_first_tail_x8_r0_body.st177.s3.trace.take 26
kernel_rfl PRE_first_tail_x8_r0_body.traceEq177 : PRE_first_tail_x8_r0_body.st177.s3.trace = PRE_first_tail_x8_r0_body.trFr177 ++ PRE_first_tail_x8_r0_body.st177.s0.trace
theorem PRE_first_tail_x8_r0_body.trace177 : ∃ fr, PRE_first_tail_x8_r0_body.st177.s3.trace = fr ++ PRE_first_tail_x8_r0_body.st177.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq177⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide177 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB177 : (PRE_first_tail_x8_r0_body.wide177.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st177.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix177 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide177, WFix Map.id (Present PRE_first_tail_x8_r0_body.st177.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB177 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL177
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 177 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1713`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO177 : PRE_first_tail_x8_r0_body.st177.S0.oracle = PRE_first_tail_x8_r0_body.st177.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B177 : PRE_first_tail_x8_r0_body.st177.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st177.s0.next || (PRE_first_tail_x8_r0_body.st177.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot177 : Conv.StageFoot PRE_first_tail_x8_r0_body.st177.wr PRE_first_tail_x8_r0_body.st177.s0 PRE_first_tail_x8_r0_body.st177.s3 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st177.heapFoot PRE_first_tail_x8_r0_body.wrNodup177 PRE_first_tail_x8_r0_body.wrBound177 PRE_first_tail_x8_r0_body.wr0B177 PRE_first_tail_x8_r0_body.st177.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged177 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st177.F.S → PRE_first_tail_x8_r0_body.st177.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st177.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st177.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs177 PRE_first_tail_x8_r0_body.st177.wr PRE_first_tail_x8_r0_body.s1712 PRE_first_tail_x8_r0_body.st177.s3 PRE_first_tail_x8_r0_body.st177.s0
      PRE_first_tail_x8_r0_body.st177.s3.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st177.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1713 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso177 PRE_first_tail_x8_r0_body.stFoot177 PRE_first_tail_x8_r0_body.wrNodup177 PRE_first_tail_x8_r0_body.wrBound177 PRE_first_tail_x8_r0_body.trace177 PRE_first_tail_x8_r0_body.mheap177
    PRE_first_tail_x8_r0_body.mnext177 PRE_first_tail_x8_r0_body.mctl177 PRE_first_tail_x8_r0_body.mstack177 PRE_first_tail_x8_r0_body.mjobs177 PRE_first_tail_x8_r0_body.mffi177 PRE_first_tail_x8_r0_body.mtrace177 PRE_first_tail_x8_r0_body.mstores177 h

def PRE_first_tail_x8_r0_body.arrEl177_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE177_2665 : arrOf PRE_first_tail_x8_r0_body.s1713 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl177_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA177_2665 : isArrB PRE_first_tail_x8_r0_body.s1713 2665 = true
theorem PRE_first_tail_x8_r0_body.arr177_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1713.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl177_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE177_2665 PRE_first_tail_x8_r0_body.arrA177_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN177_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl177_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR177_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl177_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN177_2665

def PRE_first_tail_x8_r0_body.arrEl177_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE177_2673467 : arrOf PRE_first_tail_x8_r0_body.s1713 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl177_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA177_2673467 : isArrB PRE_first_tail_x8_r0_body.s1713 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr177_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1713.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl177_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE177_2673467 PRE_first_tail_x8_r0_body.arrA177_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN177_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl177_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR177_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl177_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN177_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k177 : isArrB PRE_first_tail_x8_r0_body.s1713 4910 = false
theorem PRE_first_tail_x8_r0_body.keep177 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1713 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k177 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr177_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl177_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ177
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 177 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1712`, the merged
state `PRE_first_tail_x8_r0_body.s1713`, the canonical state `PRE_first_tail_x8_r0_body.s1714`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl177 : PRE_first_tail_x8_r0_body.pl177.all (Nat.ble PRE_first_tail_x8_r0_body.s1712.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd177 : nodupT PRE_first_tail_x8_r0_body.pl177 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1177 : Nat.ble PRE_first_tail_x8_r0_body.s1712.next 2814709 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst177 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1712.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn177 : PRE_first_tail_x8_r0_body.s1714.next = PRE_first_tail_x8_r0_body.s1712.next + PRE_first_tail_x8_r0_body.pl177.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn177 : PRE_first_tail_x8_r0_body.s1713.next = 2814709
kernel_rfl PRE_first_tail_x8_r0_body.zgrow177 : Nat.ble PRE_first_tail_x8_r0_body.s1714.next PRE_first_tail_x8_r0_body.s1713.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh177 : PRE_first_tail_x8_r0_body.S1712.tab.all (fun e => PRE_first_tail_x8_r0_body.cws177.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd177 : nodupT PRE_first_tail_x8_r0_body.cws177 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi177 : PRE_first_tail_x8_r0_body.nr177.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1713.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt177 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1712.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg177_2665 : PRE_first_tail_x8_r0_body.s1714.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1714 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk177_2665 : (objOf PRE_first_tail_x8_r0_body.s1714 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm177_2665 : PRE_first_tail_x8_r0_body.s1713.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa177.obj (objOf PRE_first_tail_x8_r0_body.s1714 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1713 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg177_2673467 : PRE_first_tail_x8_r0_body.s1714.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1714 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk177_2673467 : (objOf PRE_first_tail_x8_r0_body.s1714 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm177_2673467 : PRE_first_tail_x8_r0_body.s1713.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa177.obj (objOf PRE_first_tail_x8_r0_body.s1714 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1713 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw177_4910 : (PRE_first_tail_x8_r0_body.s1714.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw177_2673472 : (PRE_first_tail_x8_r0_body.s1714.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw177_2673473 : (PRE_first_tail_x8_r0_body.s1714.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd177 : PRE_first_tail_x8_r0_body.cl177.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr177 : PRE_first_tail_x8_r0_body.st177.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1712.next || PRE_first_tail_x8_r0_body.cl177.contains b) = true
def PRE_first_tail_x8_r0_body.zl177 : List Nat := PRE_first_tail_x8_r0_body.cl177.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE177 : PRE_first_tail_x8_r0_body.zl177.map (fun a => PRE_first_tail_x8_r0_body.s1713.heap.get (PRE_first_tail_x8_r0_body.kappa177.a a)) = PRE_first_tail_x8_r0_body.zl177.map (fun a => (PRE_first_tail_x8_r0_body.s1714.heap.get a).map PRE_first_tail_x8_r0_body.kappa177.hobj)
theorem PRE_first_tail_x8_r0_body.zimg177 : HeapImg PRE_first_tail_x8_r0_body.kappa177 PRE_first_tail_x8_r0_body.s1714 PRE_first_tail_x8_r0_body.s1713 PRE_first_tail_x8_r0_body.zl177 := PRE_first_tail_x8_r0_body.zimgE177
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl177 : PRE_first_tail_x8_r0_body.s1713.ctl = PRE_first_tail_x8_r0_body.kappa177.ctl PRE_first_tail_x8_r0_body.s1714.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack177 : PRE_first_tail_x8_r0_body.s1713.stack = PRE_first_tail_x8_r0_body.s1714.stack.map PRE_first_tail_x8_r0_body.kappa177.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs177 : PRE_first_tail_x8_r0_body.s1713.jobs = PRE_first_tail_x8_r0_body.s1714.jobs.map PRE_first_tail_x8_r0_body.kappa177.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores177 : PRE_first_tail_x8_r0_body.s1713.stores = PRE_first_tail_x8_r0_body.kappa177.stores PRE_first_tail_x8_r0_body.s1714.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots177 : checkRootsSupp PRE_first_tail_x8_r0_body.s1714 7665 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC177 : PRE_first_tail_x8_r0_body.S1712.tab.length + PRE_first_tail_x8_r0_body.cws177.length = 7665
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap177 : PRE_first_tail_x8_r0_body.kappa177 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1712.next 2814709 PRE_first_tail_x8_r0_body.S1712.tab.length PRE_first_tail_x8_r0_body.pl177 (PRE_first_tail_x8_r0_body.nr177.map NumV.ref) PRE_first_tail_x8_r0_body.kd177.big
  PRE_first_tail_x8_r0_body.kd177.region PRE_first_tail_x8_r0_body.kd177.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin177 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1714.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc177 : Conv.jcleanListB (⟨21701, 18800, 2814359, 7665⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1714 PRE_first_tail_x8_r0_body.cl177 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB177 : noBigRootsP (fun i => !Conv.oldBigB (⟨21701, 18800, 2814359, 7665⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1714.trace PRE_first_tail_x8_r0_body.s1714 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm177 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18794 = true
theorem PRE_first_tail_x8_r0_body.cjcl177 (h : Conv.JClean (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1712) : Conv.JClean (⟨21701, 18800, 2814359, 7665⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1714 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle177)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap177 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd177 a ha)) PRE_first_tail_x8_r0_body.zjc177

end Host.Load.Run.Tpl
end

section -- st177/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st177.bodyLast from PRE_first_tail_x8_r0_body.st177.s2 to PRE_first_tail_x8_r0_body.st177.s3 :
  interpS (step PRE_first_tail_x8_r0_body.st177.F PRE_first_tail_x8_r0_body.st177.s2).run PRE_first_tail_x8_r0_body.st177.S2 = some (PRE_first_tail_x8_r0_body.st177.s3, PRE_first_tail_x8_r0_body.st177.S3)
kernel_rfl PRE_first_tail_x8_r0_body.st177.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st177.s2.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st177.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st177.s3.stack = true

end Host.Load.Run.Tpl
end

section -- st177/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st177.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st177.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st177.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st177.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st177.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st177.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st177.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st177.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st177.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st177.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st177.s0 PRE_first_tail_x8_r0_body.st177.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st177.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st177.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st177.s2 PRE_first_tail_x8_r0_body.st177.S2) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st177/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st177.bodyK0F from PRE_first_tail_x8_r0_body.st177.s0 to PRE_first_tail_x8_r0_body.st177.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st177.F (PRE_first_tail_x8_r0_body.st177.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st177.ks 0).getD 0) PRE_first_tail_x8_r0_body.st177.s0 PRE_first_tail_x8_r0_body.st177.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st177.s1, PRE_first_tail_x8_r0_body.st177.S1)
theorem PRE_first_tail_x8_r0_body.st177.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st177.F (PRE_first_tail_x8_r0_body.st177.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st177.ks 0).getD 0) PRE_first_tail_x8_r0_body.st177.s0 PRE_first_tail_x8_r0_body.st177.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st177.s1, PRE_first_tail_x8_r0_body.st177.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st177.bodyOkLN_ok PRE_first_tail_x8_r0_body.st177.bodyK0F
end Host.Load.Run.Tpl
end

section -- st177/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st177.bodyK1F from PRE_first_tail_x8_r0_body.st177.s1 to PRE_first_tail_x8_r0_body.st177.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st177.F (PRE_first_tail_x8_r0_body.st177.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st177.ks 1).getD 0) PRE_first_tail_x8_r0_body.st177.s1 PRE_first_tail_x8_r0_body.st177.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st177.s2, PRE_first_tail_x8_r0_body.st177.S2)
theorem PRE_first_tail_x8_r0_body.st177.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st177.F (PRE_first_tail_x8_r0_body.st177.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st177.ks 1).getD 0) PRE_first_tail_x8_r0_body.st177.s1 PRE_first_tail_x8_r0_body.st177.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st177.s2, PRE_first_tail_x8_r0_body.st177.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st177.bodyOkLN_ok PRE_first_tail_x8_r0_body.st177.bodyK1F
end Host.Load.Run.Tpl
end

section -- st177/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st177.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st177.F (PRE_first_tail_x8_r0_body.st177.bodyOkL bytes rows) 3452 PRE_first_tail_x8_r0_body.st177.s0 PRE_first_tail_x8_r0_body.st177.S0 = some (PRE_first_tail_x8_r0_body.st177.s2, PRE_first_tail_x8_r0_body.st177.S2) :=
  runOk_trans PRE_first_tail_x8_r0_body.st177.F (PRE_first_tail_x8_r0_body.st177.bodyOkL bytes rows) ((nth? PRE_first_tail_x8_r0_body.st177.ks 0).getD 0) ((nth? PRE_first_tail_x8_r0_body.st177.ks 1).getD 0) PRE_first_tail_x8_r0_body.st177.s0 PRE_first_tail_x8_r0_body.st177.s1 PRE_first_tail_x8_r0_body.st177.s2 PRE_first_tail_x8_r0_body.st177.S0 PRE_first_tail_x8_r0_body.st177.S1 PRE_first_tail_x8_r0_body.st177.S2 ((congrFun (congrFun PRE_first_tail_x8_r0_body.st177.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st177.bodyK1 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st177.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st177.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st177.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st177.F (PRE_first_tail_x8_r0_body.st177.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st177.s0
  S0 := PRE_first_tail_x8_r0_body.st177.S0
  s1 := PRE_first_tail_x8_r0_body.st177.s2
  S1 := PRE_first_tail_x8_r0_body.st177.S2
  s2 := PRE_first_tail_x8_r0_body.st177.s3
  S2 := PRE_first_tail_x8_r0_body.st177.S3
  n := 3452
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st177.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st177.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st177.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st177.bodyHalt
  last := PRE_first_tail_x8_r0_body.st177.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st177.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC178
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 178 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1722` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa178` into the merged state
`PRE_first_tail_x8_r0_body.s1721`. -/

def PRE_first_tail_x8_r0_body.pl178 : List Nat := []
def PRE_first_tail_x8_r0_body.nr178 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd178 : RData :=
  ⟨2814941, 2814943, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21714, 21714, 18810, 18810, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa178 : Map :=
  Conv.Map.compact 2814941 2814943 7688 PRE_first_tail_x8_r0_body.pl178 (PRE_first_tail_x8_r0_body.nr178.map NumV.ref) PRE_first_tail_x8_r0_body.kd178.big
    PRE_first_tail_x8_r0_body.kd178.region PRE_first_tail_x8_r0_body.kd178.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws178 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs178 : List SymE := PRE_first_tail_x8_r0_body.nr178.map fun r => (nth? PRE_first_tail_x8_r0_body.S1721.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta178 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws178 PRE_first_tail_x8_r0_body.crs178
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB178 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab178 : PRE_first_tail_x8_r0_body.S1722.tab = PRE_first_tail_x8_r0_body.S1720.tab ++ PRE_first_tail_x8_r0_body.cws178.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace178 : PRE_first_tail_x8_r0_body.s1722.trace = PRE_first_tail_x8_r0_body.s1720.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext178 : PRE_first_tail_x8_r0_body.s1722.next = 2814941
kernel_rfl PRE_first_tail_x8_r0_body.ccounters178 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx.nnext) = (21714, 18810)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue178 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1721.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa178.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp178 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx.tokens.all (bSN 7688) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean178 : Conv.cleanListB 21714 131072 (fun r => Nat.ble 86856 r) PRE_first_tail_x8_r0_body.s1722
    (PRE_first_tail_x8_r0_body.wrB178 ++ (List.range 0).map (2814941 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs178 : bigsOutB 21714 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK178
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl178`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl178 : List Nat := [2665, 2673467]
def PRE_first_tail_x8_r0_body.clo178 : List Nat := []
def PRE_first_tail_x8_r0_body.cln178 : List Nat := []
def PRE_first_tail_x8_r0_body.cli178 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap178 : PRE_first_tail_x8_r0_body.s1722.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1720.heap (PRE_first_tail_x8_r0_body.cl178.filterMap fun a => (PRE_first_tail_x8_r0_body.s1722.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe178 : Nat.ble PRE_first_tail_x8_r0_body.s1720.next PRE_first_tail_x8_r0_body.s1722.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP178 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1720 PRE_first_tail_x8_r0_body.s1722 PRE_first_tail_x8_r0_body.cl178 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp178 : Conv.suppListB PRE_first_tail_x8_r0_body.s1722 7688 PRE_first_tail_x8_r0_body.cl178 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound178 : Conv.boundListB PRE_first_tail_x8_r0_body.s1722 PRE_first_tail_x8_r0_body.cl178 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK178 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln178.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK178 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo178.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK178 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli178.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst178 : Conv.sstListB 7688 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx PRE_first_tail_x8_r0_body.cln178 PRE_first_tail_x8_r0_body.clo178 PRE_first_tail_x8_r0_body.cli178 = true

end Host.Load.Run.Tpl
end

section -- SiteCl178
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA178 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo178.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd178 : (PRE_first_tail_x8_r0_body.clo178 ++ PRE_first_tail_x8_r0_body.cln178 ++ PRE_first_tail_x8_r0_body.cli178).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle178 : Conv.Cnt.leB (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck178 : Conv.ncleanListB (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx PRE_first_tail_x8_r0_body.clo178 PRE_first_tail_x8_r0_body.cln178 PRE_first_tail_x8_r0_body.cli178 = true
theorem PRE_first_tail_x8_r0_body.cncl178 (h : Conv.NClean (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx) : Conv.NClean (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle178 PRE_first_tail_x8_r0_body.ckA178 PRE_first_tail_x8_r0_body.cobjsK178 PRE_first_tail_x8_r0_body.cnodesK178 PRE_first_tail_x8_r0_body.citemsK178 PRE_first_tail_x8_r0_body.cbd178 PRE_first_tail_x8_r0_body.cck178

end Host.Load.Run.Tpl
end

section -- SiteS178
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 178 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc178 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P178 : LoadP := PRE_first_tail_x8_r0_body.Pc178.raise 18810
kernel_rfl PRE_first_tail_x8_r0_body.craise178 : Nat.ble PRE_first_tail_x8_r0_body.Pc178.N0 18810 = true
theorem PRE_first_tail_x8_r0_body.raised178 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc178 PRE_first_tail_x8_r0_body.P178 :=
  .inr ⟨18810, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise178, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_178 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_178 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1721.ffi)
def PRE_first_tail_x8_r0_body.khinv178 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv178 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS178 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS178 : List Nat := List.range' 18810 0
def PRE_first_tail_x8_r0_body.ciS178 : List Nat := [] ++ List.range' 18810 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0178 : PRE_first_tail_x8_r0_body.kd178.nh0 = PRE_first_tail_x8_r0_body.cx0_178.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1178 : PRE_first_tail_x8_r0_body.kd178.nh1 = PRE_first_tail_x8_r0_body.cx1_178.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0178 : PRE_first_tail_x8_r0_body.kd178.nn0 = PRE_first_tail_x8_r0_body.cx0_178.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1178 : PRE_first_tail_x8_r0_body.kd178.nn1 = PRE_first_tail_x8_r0_body.cx1_178.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo178 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P178.lo && Nat.ble PRE_first_tail_x8_r0_body.P178.lo PRE_first_tail_x8_r0_body.cx0_178.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P178.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P178.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt178 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_178.mlx.next PRE_first_tail_x8_r0_body.cx1_178.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_178.mlx.nnext PRE_first_tail_x8_r0_body.cx1_178.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband178 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P178.NL && Nat.ble PRE_first_tail_x8_r0_body.P178.NL PRE_first_tail_x8_r0_body.P178.N0 && Nat.ble PRE_first_tail_x8_r0_body.P178.N0 PRE_first_tail_x8_r0_body.cx0_178.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow178 : PRE_first_tail_x8_r0_body.kd178.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren178 : checkRenG PRE_first_tail_x8_r0_body.kd178.hnd PRE_first_tail_x8_r0_body.khinv178 (phB PRE_first_tail_x8_r0_body.cx0_178.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband178 : PRE_first_tail_x8_r0_body.kd178.checkBand PRE_first_tail_x8_r0_body.P178.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos178 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd178.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren178 : checkRenG PRE_first_tail_x8_r0_body.kd178.node PRE_first_tail_x8_r0_body.kninv178 (pnB PRE_first_tail_x8_r0_body.cx0_178.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow178 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd178.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P178.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd178.nodeF j) PRE_first_tail_x8_r0_body.cx1_178.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a178 : PRE_first_tail_x8_r0_body.cx0_178.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b178 : PRE_first_tail_x8_r0_body.cx0_178.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1178 : PRE_first_tail_x8_r0_body.cx1_178.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend178 : PRE_first_tail_x8_r0_body.cx1_178.mlx.pending = PRE_first_tail_x8_r0_body.cx0_178.mlx.pending.map PRE_first_tail_x8_r0_body.kappa178.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh178 : PRE_first_tail_x8_r0_body.cx1_178.mlx.errh = PRE_first_tail_x8_r0_body.cx0_178.mlx.errh.map PRE_first_tail_x8_r0_body.kappa178.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles178 : PRE_first_tail_x8_r0_body.cx1_178.mlx.files = PRE_first_tail_x8_r0_body.cx0_178.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch178 : PRE_first_tail_x8_r0_body.cx1_178.mlx.arch = PRE_first_tail_x8_r0_body.cx0_178.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes178 : PRE_first_tail_x8_r0_body.cx1_178.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_178.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired178 : PRE_first_tail_x8_r0_body.cx1_178.mlx.wired = PRE_first_tail_x8_r0_body.cx0_178.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost178 : PRE_first_tail_x8_r0_body.cx1_178.host = PRE_first_tail_x8_r0_body.cx0_178.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd178`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0178 : PRE_first_tail_x8_r0_body.kd178.n0 = 2814941
kernel_rfl PRE_first_tail_x8_r0_body.ckn1178 : PRE_first_tail_x8_r0_body.kd178.n1 = 2814943
kernel_rfl PRE_first_tail_x8_r0_body.ckheap178 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd178.heap).all (fun x => Nat.ble 2814941 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl178 : (List.range 0).all (fun j => decide (PRE_first_tail_x8_r0_body.kd178.heap.get (2814941 + j) = nth? PRE_first_tail_x8_r0_body.pl178 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja178 : Nat.ble 2814941 2814941 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn178 : Nat.ble 7688 7688 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD178 : Nat.ble 2814941 PRE_first_tail_x8_r0_body.kd178.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn178 : Nat.ble 21714 PRE_first_tail_x8_r0_body.kd178.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn178 : Nat.ble 18810 PRE_first_tail_x8_r0_body.kd178.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb178 : Nat.ble 21714 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap178 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd178.heap).all (Nat.ble (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd178 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd178.hnd).all (Nat.ble (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode178 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd178.node).all (Nat.ble (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix178 : Conv.FixOld (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa178 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja178) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn178) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD178) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn178) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn178) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb178) PRE_first_tail_x8_r0_body.fheap178 PRE_first_tail_x8_r0_body.fhnd178 PRE_first_tail_x8_r0_body.fnode178
kernel_rfl PRE_first_tail_x8_r0_body.fcxn178 : (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn178 : (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0178 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_178.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_178.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk178 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd178.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A178 : PRE_first_tail_x8_r0_body.cx1_178.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS178.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_178.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O178 : PRE_first_tail_x8_r0_body.cx1_178.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS178.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_178.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N178 : PRE_first_tail_x8_r0_body.cx1_178.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS178.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_178.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I178 : PRE_first_tail_x8_r0_body.cx1_178.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS178.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_178.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd178 : (PRE_first_tail_x8_r0_body.clo178 ++ PRE_first_tail_x8_r0_body.cln178 ++ PRE_first_tail_x8_r0_body.cli178 ++ PRE_first_tail_x8_r0_body.cwS178 ++ PRE_first_tail_x8_r0_body.cnS178 ++ PRE_first_tail_x8_r0_body.ciS178).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW178 : PRE_first_tail_x8_r0_body.cwS178.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo178.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI178 : PRE_first_tail_x8_r0_body.ciS178.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli178.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN178 : PRE_first_tail_x8_r0_body.cnS178.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF178 : PRE_first_tail_x8_r0_body.cln178.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh178 : PRE_first_tail_x8_r0_body.clo178.all (handleOK PRE_first_tail_x8_r0_body.kappa178 PRE_first_tail_x8_r0_body.P178.lo PRE_first_tail_x8_r0_body.cx0_178.mlx PRE_first_tail_x8_r0_body.cx1_178.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo178 : PRE_first_tail_x8_r0_body.clo178.map (fun h => PRE_first_tail_x8_r0_body.cx1_178.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa178.handle h)) = PRE_first_tail_x8_r0_body.clo178.map (fun h => (PRE_first_tail_x8_r0_body.cx0_178.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa178.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok178 : PRE_first_tail_x8_r0_body.clo178.all (objOK PRE_first_tail_x8_r0_body.kappa178 PRE_first_tail_x8_r0_body.P178.NL PRE_first_tail_x8_r0_body.cx0_178.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd178 : PRE_first_tail_x8_r0_body.cln178.all (nodeOKF PRE_first_tail_x8_r0_body.kappa178 PRE_first_tail_x8_r0_body.P178 PRE_first_tail_x8_r0_body.cx0_178.mlx PRE_first_tail_x8_r0_body.cx1_178.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp178 : ((PRE_first_tail_x8_r0_body.cln178.filter (fullB PRE_first_tail_x8_r0_body.P178))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_178.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa178.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln178.filter (fullB PRE_first_tail_x8_r0_body.P178))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_178.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa178.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI178 : incrB PRE_first_tail_x8_r0_body.kd178.nodeF (List.range' 18810 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK178 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd178.node).all (fun k => Nat.ble 18810 k && Nat.blt k 18810) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL178 : (PRE_first_tail_x8_r0_body.cln178.filter (Nat.ble PRE_first_tail_x8_r0_body.P178.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd178.nodeF i) && (Nat.blt i 18810 || Nat.ble PRE_first_tail_x8_r0_body.kd178.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord178 : (PRE_first_tail_x8_r0_body.cln178.filter (Nat.ble PRE_first_tail_x8_r0_body.P178.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd178.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd178.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd178.nodeF j) (PRE_first_tail_x8_r0_body.kd178.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow178 PRE_first_tail_x8_r0_body.cnn1178 PRE_first_tail_x8_r0_body.fnordI178 PRE_first_tail_x8_r0_body.fnordK178 PRE_first_tail_x8_r0_body.fnordL178
kernel_rfl PRE_first_tail_x8_r0_body.fi178 : PRE_first_tail_x8_r0_body.cli178.all (pnB PRE_first_tail_x8_r0_body.cx0_178.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii178 : PRE_first_tail_x8_r0_body.cli178.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_178.mlx.items.get (PRE_first_tail_x8_r0_body.kappa178.node k) = (PRE_first_tail_x8_r0_body.cx0_178.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa178.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot178 (clean : Conv.NClean (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P178.NL) (cl : SSt (· < 7688) PRE_first_tail_x8_r0_body.cx0_178.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P178 7688 PRE_first_tail_x8_r0_body.kappa178 PRE_first_tail_x8_r0_body.kd178 PRE_first_tail_x8_r0_body.khinv178 PRE_first_tail_x8_r0_body.kninv178 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx PRE_first_tail_x8_r0_body.cx0_178.mlx PRE_first_tail_x8_r0_body.cx1_178.mlx (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo178 PRE_first_tail_x8_r0_body.cln178 PRE_first_tail_x8_r0_body.cli178 PRE_first_tail_x8_r0_body.cwS178 PRE_first_tail_x8_r0_body.cnS178 PRE_first_tail_x8_r0_body.ciS178 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0178, PRE_first_tail_x8_r0_body.cnh1178, PRE_first_tail_x8_r0_body.cnn0178, PRE_first_tail_x8_r0_body.cnn1178, PRE_first_tail_x8_r0_body.cplo178, PRE_first_tail_x8_r0_body.ccnt178, PRE_first_tail_x8_r0_body.cnband178, PRE_first_tail_x8_r0_body.chbelow178, PRE_first_tail_x8_r0_body.chren178, PRE_first_tail_x8_r0_body.cband178, PRE_first_tail_x8_r0_body.cnh1pos178, PRE_first_tail_x8_r0_body.cnren178, PRE_first_tail_x8_r0_body.cnlow178, PRE_first_tail_x8_r0_body.cabs0a178, PRE_first_tail_x8_r0_body.cabs0b178, PRE_first_tail_x8_r0_body.ctok1178, PRE_first_tail_x8_r0_body.cpend178, PRE_first_tail_x8_r0_body.cerrh178, PRE_first_tail_x8_r0_body.cfiles178, PRE_first_tail_x8_r0_body.carch178, PRE_first_tail_x8_r0_body.csizes178, PRE_first_tail_x8_r0_body.cwired178, PRE_first_tail_x8_r0_body.cfix178, clean, PRE_first_tail_x8_r0_body.fcxn178, PRE_first_tail_x8_r0_body.fcnn178, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0178, PRE_first_tail_x8_r0_body.fnk178, PRE_first_tail_x8_r0_body.ckA178, PRE_first_tail_x8_r0_body.cobjsK178, PRE_first_tail_x8_r0_body.cnodesK178, PRE_first_tail_x8_r0_body.citemsK178, PRE_first_tail_x8_r0_body.f1A178, PRE_first_tail_x8_r0_body.f1O178, PRE_first_tail_x8_r0_body.f1N178, PRE_first_tail_x8_r0_body.f1I178, PRE_first_tail_x8_r0_body.fbd178, PRE_first_tail_x8_r0_body.fincW178, PRE_first_tail_x8_r0_body.fincI178, PRE_first_tail_x8_r0_body.fincN178, PRE_first_tail_x8_r0_body.flnF178, PRE_first_tail_x8_r0_body.fh178, PRE_first_tail_x8_r0_body.fo178, PRE_first_tail_x8_r0_body.fok178, PRE_first_tail_x8_r0_body.fnd178, PRE_first_tail_x8_r0_body.fp178, PRE_first_tail_x8_r0_body.fnord178, PRE_first_tail_x8_r0_body.fi178, PRE_first_tail_x8_r0_body.fii178⟩
theorem PRE_first_tail_x8_r0_body.cnshift178 (clean : Conv.NClean (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P178.NL) (cl : SSt (· < 7688) PRE_first_tail_x8_r0_body.cx0_178.mlx) : NShift PRE_first_tail_x8_r0_body.P178 7688 PRE_first_tail_x8_r0_body.kappa178 PRE_first_tail_x8_r0_body.cx0_178 PRE_first_tail_x8_r0_body.cx1_178 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot178 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost178 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0178 PRE_first_tail_x8_r0_body.ckn1178 PRE_first_tail_x8_r0_body.ckheap178 PRE_first_tail_x8_r0_body.ckpl178)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_178 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1720.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_178 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1720.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_178 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1720.ffi) = some PRE_first_tail_x8_r0_body.fxC_178
kernel_rfl PRE_first_tail_x8_r0_body.okrC_178 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1720.ffi) = some PRE_first_tail_x8_r0_body.krC_178
noncomputable def PRE_first_tail_x8_r0_body.fx0_178 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1722.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_178 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1722.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_178 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1722.ffi) = some PRE_first_tail_x8_r0_body.fx0_178
kernel_rfl PRE_first_tail_x8_r0_body.okr0_178 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1722.ffi) = some PRE_first_tail_x8_r0_body.kr0_178
noncomputable def PRE_first_tail_x8_r0_body.fx1_178 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1721.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_178 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1721.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_178 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1721.ffi) = some PRE_first_tail_x8_r0_body.fx1_178
kernel_rfl PRE_first_tail_x8_r0_body.okr1_178 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1721.ffi) = some PRE_first_tail_x8_r0_body.kr1_178
kernel_rfl PRE_first_tail_x8_r0_body.ff0178 : PRE_first_tail_x8_r0_body.fx0_178 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_178 (PRE_first_tail_x8_r0_body.clo178.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_178.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1178 : PRE_first_tail_x8_r0_body.fx1_178 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_178 (PRE_first_tail_x8_r0_body.cwS178.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_178.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck178 : freedLB PRE_first_tail_x8_r0_body.kappa178 PRE_first_tail_x8_r0_body.cx0_178.mlx PRE_first_tail_x8_r0_body.fx0_178 PRE_first_tail_x8_r0_body.fx1_178 PRE_first_tail_x8_r0_body.clo178 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0178 : PRE_first_tail_x8_r0_body.kr0_178.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_178.flags (PRE_first_tail_x8_r0_body.clo178.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_178.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0178 : PRE_first_tail_x8_r0_body.kr0_178.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_178.targs (PRE_first_tail_x8_r0_body.clo178.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_178.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1178 : PRE_first_tail_x8_r0_body.kr1_178.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_178.flags (PRE_first_tail_x8_r0_body.cwS178.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_178.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1178 : PRE_first_tail_x8_r0_body.kr1_178.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_178.targs (PRE_first_tail_x8_r0_body.cwS178.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_178.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck178 : krecLB PRE_first_tail_x8_r0_body.kappa178 7688 PRE_first_tail_x8_r0_body.cx0_178.mlx PRE_first_tail_x8_r0_body.kr0_178 PRE_first_tail_x8_r0_body.kr1_178 PRE_first_tail_x8_r0_body.clo178 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn178 : Nat.ble 7688 7688 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge178 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1721.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1722.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR178 : pendRegB PRE_first_tail_x8_r0_body.kappa178 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe178 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1722.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1721.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift178 (clean : Conv.NClean (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P178.NL) (cl : SSt (· < 7688) PRE_first_tail_x8_r0_body.cx0_178.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_178.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_178.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_178.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1720.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_178.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P178 7688 PRE_first_tail_x8_r0_body.kappa178 PRE_first_tail_x8_r0_body.s1722.ffi PRE_first_tail_x8_r0_body.s1721.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift178 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue178, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp178 t ht),
    PRE_first_tail_x8_r0_body.cbridge178,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1722.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1721.ffi) (PRE_first_tail_x8_r0_body.cfoot178 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_178 PRE_first_tail_x8_r0_body.ofx1_178 hobjC PRE_first_tail_x8_r0_body.ff0178 PRE_first_tail_x8_r0_body.ff1178 PRE_first_tail_x8_r0_body.ffck178,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1722.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1721.ffi) (PRE_first_tail_x8_r0_body.cfoot178 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_178 PRE_first_tail_x8_r0_body.okr1_178 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn178) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0178 PRE_first_tail_x8_r0_body.fkt0178 PRE_first_tail_x8_r0_body.fkf1178 PRE_first_tail_x8_r0_body.fkt1178 PRE_first_tail_x8_r0_body.fkck178,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0178 PRE_first_tail_x8_r0_body.cnh1178 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe178) PRE_first_tail_x8_r0_body.cpendR178⟩

end Host.Load.Run.Tpl
end

section -- st178/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st178 0
host_stream_state PRE_first_tail_x8_r0_body.st178 1
host_stream_state PRE_first_tail_x8_r0_body.st178 2
end Host.Load.Run.Tpl
end

section -- Site178
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 178 of chain `PRE_first_tail_x8_r0_body`: `rowBlocks__g178__g179` (`rowBlocks`), the call state `PRE_first_tail_x8_r0_body.s1720`, the merged state `PRE_first_tail_x8_r0_body.s1721`,
the site template `PRE_first_tail_x8_r0_body.st178` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1722`: the merge.
The footprint's facts are in `SiteF178`, the compaction's in `SiteC178`, `SiteK178`, `SiteNa178`, `SiteNb178`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso178 : PRE_first_tail_x8_r0_body.st178.s0 = { PRE_first_tail_x8_r0_body.s1720 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs178 : List Frame := PRE_first_tail_x8_r0_body.s1720.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_178 : PRE_first_tail_x8_r0_body.S1720.tab.length = 7688
kernel_rfl PRE_first_tail_x8_r0_body.tab0_178 : PRE_first_tail_x8_r0_body.st178.S0.tab = PRE_first_tail_x8_r0_body.S1720.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws178 : List Nat := [4016, 4017]
kernel_rfl PRE_first_tail_x8_r0_body.fresh178 : (PRE_first_tail_x8_r0_body.S1720.tab.all fun e => PRE_first_tail_x8_r0_body.ws178.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1720.oracle.all fun q => PRE_first_tail_x8_r0_body.ws178.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab178 : PRE_first_tail_x8_r0_body.S1721.tab = PRE_first_tail_x8_r0_body.S1720.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws178
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen178 : PRE_first_tail_x8_r0_body.st178.S2.tab.length - PRE_first_tail_x8_r0_body.st178.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged178`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap178 : PRE_first_tail_x8_r0_body.s1721.heap = PRE_first_tail_x8_r0_body.st178.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext178 : PRE_first_tail_x8_r0_body.s1721.next = PRE_first_tail_x8_r0_body.st178.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl178 : PRE_first_tail_x8_r0_body.s1721.ctl = PRE_first_tail_x8_r0_body.st178.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack178 : PRE_first_tail_x8_r0_body.s1721.stack = PRE_first_tail_x8_r0_body.st178.s2.stack ++ PRE_first_tail_x8_r0_body.s1720.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs178 : PRE_first_tail_x8_r0_body.s1721.jobs = PRE_first_tail_x8_r0_body.st178.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi178 : PRE_first_tail_x8_r0_body.s1721.ffi = PRE_first_tail_x8_r0_body.st178.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace178 : PRE_first_tail_x8_r0_body.s1721.trace = PRE_first_tail_x8_r0_body.st178.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores178 : PRE_first_tail_x8_r0_body.s1721.stores = PRE_first_tail_x8_r0_body.st178.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD178
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 178 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived178 : PRE_first_tail_x8_r0_body.nr178.map (fun r => nth? PRE_first_tail_x8_r0_body.st178.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo178 : PRE_first_tail_x8_r0_body.nr178.all (Nat.ble 7688) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj178 : PRE_first_tail_x8_r0_body.cws178.all (fun c => !PRE_first_tail_x8_r0_body.ws178.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ178 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws178 PRE_first_tail_x8_r0_body.crs178 PRE_first_tail_x8_r0_body.ws178

end Host.Load.Run.Tpl
end

section -- st178/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st178`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st178.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st178.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st178.s2.heap PRE_first_tail_x8_r0_body.st178.wrR ++ freshOf PRE_first_tail_x8_r0_body.st178.s2.heap PRE_first_tail_x8_r0_body.st178.s0.next PRE_first_tail_x8_r0_body.st178.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st178.wr : List Nat := PRE_first_tail_x8_r0_body.st178.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st178.heapFoot : PRE_first_tail_x8_r0_body.st178.s2.heap = setAll PRE_first_tail_x8_r0_body.st178.s0.heap PRE_first_tail_x8_r0_body.st178.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st178.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st178.s0.next PRE_first_tail_x8_r0_body.st178.s2.next = true
theorem PRE_first_tail_x8_r0_body.st178.grows : PRE_first_tail_x8_r0_body.st178.s0.next ≤ PRE_first_tail_x8_r0_body.st178.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st178.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st178.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st178.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st178.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st178.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st178.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st178.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st178.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st178.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st178.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st178.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st178.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF178
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 178 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB178 : nodupT PRE_first_tail_x8_r0_body.st178.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup178 : PRE_first_tail_x8_r0_body.st178.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB178).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB178 : PRE_first_tail_x8_r0_body.st178.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound178 : ∀ b ∈ PRE_first_tail_x8_r0_body.st178.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB178 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr178 := PRE_first_tail_x8_r0_body.st178.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq178 : PRE_first_tail_x8_r0_body.st178.s2.trace = PRE_first_tail_x8_r0_body.trFr178 ++ PRE_first_tail_x8_r0_body.st178.s0.trace
theorem PRE_first_tail_x8_r0_body.trace178 : ∃ fr, PRE_first_tail_x8_r0_body.st178.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st178.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq178⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide178 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB178 : (PRE_first_tail_x8_r0_body.wide178.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st178.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix178 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide178, WFix Map.id (Present PRE_first_tail_x8_r0_body.st178.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB178 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL178
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 178 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1721`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO178 : PRE_first_tail_x8_r0_body.st178.S0.oracle = PRE_first_tail_x8_r0_body.st178.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B178 : PRE_first_tail_x8_r0_body.st178.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st178.s0.next || (PRE_first_tail_x8_r0_body.st178.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot178 : Conv.StageFoot PRE_first_tail_x8_r0_body.st178.wr PRE_first_tail_x8_r0_body.st178.s0 PRE_first_tail_x8_r0_body.st178.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st178.heapFoot PRE_first_tail_x8_r0_body.wrNodup178 PRE_first_tail_x8_r0_body.wrBound178 PRE_first_tail_x8_r0_body.wr0B178 PRE_first_tail_x8_r0_body.st178.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged178 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st178.F.S → PRE_first_tail_x8_r0_body.st178.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st178.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st178.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs178 PRE_first_tail_x8_r0_body.st178.wr PRE_first_tail_x8_r0_body.s1720 PRE_first_tail_x8_r0_body.st178.s2 PRE_first_tail_x8_r0_body.st178.s0
      PRE_first_tail_x8_r0_body.st178.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st178.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1721 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso178 PRE_first_tail_x8_r0_body.stFoot178 PRE_first_tail_x8_r0_body.wrNodup178 PRE_first_tail_x8_r0_body.wrBound178 PRE_first_tail_x8_r0_body.trace178 PRE_first_tail_x8_r0_body.mheap178
    PRE_first_tail_x8_r0_body.mnext178 PRE_first_tail_x8_r0_body.mctl178 PRE_first_tail_x8_r0_body.mstack178 PRE_first_tail_x8_r0_body.mjobs178 PRE_first_tail_x8_r0_body.mffi178 PRE_first_tail_x8_r0_body.mtrace178 PRE_first_tail_x8_r0_body.mstores178 h

def PRE_first_tail_x8_r0_body.arrEl178_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE178_2665 : arrOf PRE_first_tail_x8_r0_body.s1721 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl178_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA178_2665 : isArrB PRE_first_tail_x8_r0_body.s1721 2665 = true
theorem PRE_first_tail_x8_r0_body.arr178_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1721.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl178_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE178_2665 PRE_first_tail_x8_r0_body.arrA178_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN178_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl178_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR178_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl178_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN178_2665

def PRE_first_tail_x8_r0_body.arrEl178_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE178_2673467 : arrOf PRE_first_tail_x8_r0_body.s1721 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl178_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA178_2673467 : isArrB PRE_first_tail_x8_r0_body.s1721 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr178_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1721.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl178_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE178_2673467 PRE_first_tail_x8_r0_body.arrA178_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN178_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl178_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR178_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl178_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN178_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k178 : isArrB PRE_first_tail_x8_r0_body.s1721 4910 = false
theorem PRE_first_tail_x8_r0_body.keep178 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1721 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k178 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr178_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl178_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ178
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 178 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1720`, the merged
state `PRE_first_tail_x8_r0_body.s1721`, the canonical state `PRE_first_tail_x8_r0_body.s1722`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl178 : PRE_first_tail_x8_r0_body.pl178.all (Nat.ble PRE_first_tail_x8_r0_body.s1720.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd178 : nodupT PRE_first_tail_x8_r0_body.pl178 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1178 : Nat.ble PRE_first_tail_x8_r0_body.s1720.next 2814943 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst178 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1720.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn178 : PRE_first_tail_x8_r0_body.s1722.next = PRE_first_tail_x8_r0_body.s1720.next + PRE_first_tail_x8_r0_body.pl178.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn178 : PRE_first_tail_x8_r0_body.s1721.next = 2814943
kernel_rfl PRE_first_tail_x8_r0_body.zgrow178 : Nat.ble PRE_first_tail_x8_r0_body.s1722.next PRE_first_tail_x8_r0_body.s1721.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh178 : PRE_first_tail_x8_r0_body.S1720.tab.all (fun e => PRE_first_tail_x8_r0_body.cws178.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd178 : nodupT PRE_first_tail_x8_r0_body.cws178 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi178 : PRE_first_tail_x8_r0_body.nr178.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1721.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt178 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1720.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg178_2665 : PRE_first_tail_x8_r0_body.s1722.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1722 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk178_2665 : (objOf PRE_first_tail_x8_r0_body.s1722 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm178_2665 : PRE_first_tail_x8_r0_body.s1721.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa178.obj (objOf PRE_first_tail_x8_r0_body.s1722 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1721 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg178_2673467 : PRE_first_tail_x8_r0_body.s1722.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1722 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk178_2673467 : (objOf PRE_first_tail_x8_r0_body.s1722 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm178_2673467 : PRE_first_tail_x8_r0_body.s1721.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa178.obj (objOf PRE_first_tail_x8_r0_body.s1722 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1721 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw178_4910 : (PRE_first_tail_x8_r0_body.s1722.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw178_2673472 : (PRE_first_tail_x8_r0_body.s1722.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw178_2673473 : (PRE_first_tail_x8_r0_body.s1722.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd178 : PRE_first_tail_x8_r0_body.cl178.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr178 : PRE_first_tail_x8_r0_body.st178.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1720.next || PRE_first_tail_x8_r0_body.cl178.contains b) = true
def PRE_first_tail_x8_r0_body.zl178 : List Nat := PRE_first_tail_x8_r0_body.cl178.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE178 : PRE_first_tail_x8_r0_body.zl178.map (fun a => PRE_first_tail_x8_r0_body.s1721.heap.get (PRE_first_tail_x8_r0_body.kappa178.a a)) = PRE_first_tail_x8_r0_body.zl178.map (fun a => (PRE_first_tail_x8_r0_body.s1722.heap.get a).map PRE_first_tail_x8_r0_body.kappa178.hobj)
theorem PRE_first_tail_x8_r0_body.zimg178 : HeapImg PRE_first_tail_x8_r0_body.kappa178 PRE_first_tail_x8_r0_body.s1722 PRE_first_tail_x8_r0_body.s1721 PRE_first_tail_x8_r0_body.zl178 := PRE_first_tail_x8_r0_body.zimgE178
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl178 : PRE_first_tail_x8_r0_body.s1721.ctl = PRE_first_tail_x8_r0_body.kappa178.ctl PRE_first_tail_x8_r0_body.s1722.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack178 : PRE_first_tail_x8_r0_body.s1721.stack = PRE_first_tail_x8_r0_body.s1722.stack.map PRE_first_tail_x8_r0_body.kappa178.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs178 : PRE_first_tail_x8_r0_body.s1721.jobs = PRE_first_tail_x8_r0_body.s1722.jobs.map PRE_first_tail_x8_r0_body.kappa178.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores178 : PRE_first_tail_x8_r0_body.s1721.stores = PRE_first_tail_x8_r0_body.kappa178.stores PRE_first_tail_x8_r0_body.s1722.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots178 : checkRootsSupp PRE_first_tail_x8_r0_body.s1722 7688 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC178 : PRE_first_tail_x8_r0_body.S1720.tab.length + PRE_first_tail_x8_r0_body.cws178.length = 7688
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap178 : PRE_first_tail_x8_r0_body.kappa178 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1720.next 2814943 PRE_first_tail_x8_r0_body.S1720.tab.length PRE_first_tail_x8_r0_body.pl178 (PRE_first_tail_x8_r0_body.nr178.map NumV.ref) PRE_first_tail_x8_r0_body.kd178.big
  PRE_first_tail_x8_r0_body.kd178.region PRE_first_tail_x8_r0_body.kd178.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin178 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1722.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc178 : Conv.jcleanListB (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1722 PRE_first_tail_x8_r0_body.cl178 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB178 : noBigRootsP (fun i => !Conv.oldBigB (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1722.trace PRE_first_tail_x8_r0_body.s1722 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm178 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18810 = true
theorem PRE_first_tail_x8_r0_body.cjcl178 (h : Conv.JClean (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1720) : Conv.JClean (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1722 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle178)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap178 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd178 a ha)) PRE_first_tail_x8_r0_body.zjc178

end Host.Load.Run.Tpl
end

section -- st178/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st178.bodyLast from PRE_first_tail_x8_r0_body.st178.s1 to PRE_first_tail_x8_r0_body.st178.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st178.F PRE_first_tail_x8_r0_body.st178.s1).run PRE_first_tail_x8_r0_body.st178.S1 = some (PRE_first_tail_x8_r0_body.st178.s2, PRE_first_tail_x8_r0_body.st178.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st178.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st178.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st178.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st178.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st178/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st178.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st178.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st178.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st178.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st178.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st178.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st178.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st178.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st178.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st178.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st178.s0 PRE_first_tail_x8_r0_body.st178.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st178.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st178.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st178.s1 PRE_first_tail_x8_r0_body.st178.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st178/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st178.bodyK0F from PRE_first_tail_x8_r0_body.st178.s0 to PRE_first_tail_x8_r0_body.st178.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st178.F (PRE_first_tail_x8_r0_body.st178.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st178.ks 0).getD 0) PRE_first_tail_x8_r0_body.st178.s0 PRE_first_tail_x8_r0_body.st178.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st178.s1, PRE_first_tail_x8_r0_body.st178.S1)
theorem PRE_first_tail_x8_r0_body.st178.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st178.F (PRE_first_tail_x8_r0_body.st178.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st178.ks 0).getD 0) PRE_first_tail_x8_r0_body.st178.s0 PRE_first_tail_x8_r0_body.st178.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st178.s1, PRE_first_tail_x8_r0_body.st178.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st178.bodyOkLN_ok PRE_first_tail_x8_r0_body.st178.bodyK0F
end Host.Load.Run.Tpl
end

section -- st178/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st178.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st178.F (PRE_first_tail_x8_r0_body.st178.bodyOkL bytes rows) 27 PRE_first_tail_x8_r0_body.st178.s0 PRE_first_tail_x8_r0_body.st178.S0 = some (PRE_first_tail_x8_r0_body.st178.s1, PRE_first_tail_x8_r0_body.st178.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st178.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st178.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st178.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st178.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st178.F (PRE_first_tail_x8_r0_body.st178.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st178.s0
  S0 := PRE_first_tail_x8_r0_body.st178.S0
  s1 := PRE_first_tail_x8_r0_body.st178.s1
  S1 := PRE_first_tail_x8_r0_body.st178.S1
  s2 := PRE_first_tail_x8_r0_body.st178.s2
  S2 := PRE_first_tail_x8_r0_body.st178.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st178.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st178.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st178.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st178.bodyHalt
  last := PRE_first_tail_x8_r0_body.st178.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st178.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC179
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 179 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1726` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa179` into the merged state
`PRE_first_tail_x8_r0_body.s1725`. -/

def PRE_first_tail_x8_r0_body.pl179 : List Nat := [2815249]
def PRE_first_tail_x8_r0_body.nr179 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd179 : RData :=
  ⟨2815230, 2815250, Stage.setAll PTrie.nil [(2815229, 2815249)], Stage.setAll PTrie.nil [],
   21721, 21721, 18814, 18814, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa179 : Map :=
  Conv.Map.compact 2815229 2815250 7705 PRE_first_tail_x8_r0_body.pl179 (PRE_first_tail_x8_r0_body.nr179.map NumV.ref) PRE_first_tail_x8_r0_body.kd179.big
    PRE_first_tail_x8_r0_body.kd179.region PRE_first_tail_x8_r0_body.kd179.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws179 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs179 : List SymE := PRE_first_tail_x8_r0_body.nr179.map fun r => (nth? PRE_first_tail_x8_r0_body.S1725.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta179 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws179 PRE_first_tail_x8_r0_body.crs179
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB179 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab179 : PRE_first_tail_x8_r0_body.S1726.tab = PRE_first_tail_x8_r0_body.S1724.tab ++ PRE_first_tail_x8_r0_body.cws179.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace179 : PRE_first_tail_x8_r0_body.s1726.trace = PRE_first_tail_x8_r0_body.s1724.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext179 : PRE_first_tail_x8_r0_body.s1726.next = 2815230
kernel_rfl PRE_first_tail_x8_r0_body.ccounters179 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx.nnext) = (21721, 18814)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue179 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1725.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa179.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp179 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx.tokens.all (bSN 7705) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean179 : Conv.cleanListB 21721 131072 (fun r => Nat.ble 86884 r) PRE_first_tail_x8_r0_body.s1726
    (PRE_first_tail_x8_r0_body.wrB179 ++ (List.range 1).map (2815229 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs179 : bigsOutB 21721 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK179
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl179`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl179 : List Nat := [2665, 2673467, 2815229]
def PRE_first_tail_x8_r0_body.clo179 : List Nat := []
def PRE_first_tail_x8_r0_body.cln179 : List Nat := []
def PRE_first_tail_x8_r0_body.cli179 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap179 : PRE_first_tail_x8_r0_body.s1726.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1724.heap (PRE_first_tail_x8_r0_body.cl179.filterMap fun a => (PRE_first_tail_x8_r0_body.s1726.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe179 : Nat.ble PRE_first_tail_x8_r0_body.s1724.next PRE_first_tail_x8_r0_body.s1726.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP179 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1724 PRE_first_tail_x8_r0_body.s1726 PRE_first_tail_x8_r0_body.cl179 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp179 : Conv.suppListB PRE_first_tail_x8_r0_body.s1726 7705 PRE_first_tail_x8_r0_body.cl179 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound179 : Conv.boundListB PRE_first_tail_x8_r0_body.s1726 PRE_first_tail_x8_r0_body.cl179 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK179 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln179.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK179 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo179.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK179 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli179.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst179 : Conv.sstListB 7705 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx PRE_first_tail_x8_r0_body.cln179 PRE_first_tail_x8_r0_body.clo179 PRE_first_tail_x8_r0_body.cli179 = true

end Host.Load.Run.Tpl
end

section -- SiteCl179
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA179 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo179.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd179 : (PRE_first_tail_x8_r0_body.clo179 ++ PRE_first_tail_x8_r0_body.cln179 ++ PRE_first_tail_x8_r0_body.cli179).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle179 : Conv.Cnt.leB (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) (⟨21721, 18814, 2815230, 7705⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck179 : Conv.ncleanListB (⟨21721, 18814, 2815230, 7705⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx PRE_first_tail_x8_r0_body.clo179 PRE_first_tail_x8_r0_body.cln179 PRE_first_tail_x8_r0_body.cli179 = true
theorem PRE_first_tail_x8_r0_body.cncl179 (h : Conv.NClean (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx) : Conv.NClean (⟨21721, 18814, 2815230, 7705⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle179 PRE_first_tail_x8_r0_body.ckA179 PRE_first_tail_x8_r0_body.cobjsK179 PRE_first_tail_x8_r0_body.cnodesK179 PRE_first_tail_x8_r0_body.citemsK179 PRE_first_tail_x8_r0_body.cbd179 PRE_first_tail_x8_r0_body.cck179

end Host.Load.Run.Tpl
end

section -- SiteS179
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 179 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc179 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P179 : LoadP := PRE_first_tail_x8_r0_body.Pc179.raise 18814
kernel_rfl PRE_first_tail_x8_r0_body.craise179 : Nat.ble PRE_first_tail_x8_r0_body.Pc179.N0 18814 = true
theorem PRE_first_tail_x8_r0_body.raised179 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc179 PRE_first_tail_x8_r0_body.P179 :=
  .inr ⟨18814, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise179, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_179 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_179 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1725.ffi)
def PRE_first_tail_x8_r0_body.khinv179 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv179 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS179 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS179 : List Nat := List.range' 18814 0
def PRE_first_tail_x8_r0_body.ciS179 : List Nat := [] ++ List.range' 18814 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0179 : PRE_first_tail_x8_r0_body.kd179.nh0 = PRE_first_tail_x8_r0_body.cx0_179.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1179 : PRE_first_tail_x8_r0_body.kd179.nh1 = PRE_first_tail_x8_r0_body.cx1_179.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0179 : PRE_first_tail_x8_r0_body.kd179.nn0 = PRE_first_tail_x8_r0_body.cx0_179.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1179 : PRE_first_tail_x8_r0_body.kd179.nn1 = PRE_first_tail_x8_r0_body.cx1_179.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo179 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P179.lo && Nat.ble PRE_first_tail_x8_r0_body.P179.lo PRE_first_tail_x8_r0_body.cx0_179.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P179.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P179.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt179 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_179.mlx.next PRE_first_tail_x8_r0_body.cx1_179.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_179.mlx.nnext PRE_first_tail_x8_r0_body.cx1_179.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband179 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P179.NL && Nat.ble PRE_first_tail_x8_r0_body.P179.NL PRE_first_tail_x8_r0_body.P179.N0 && Nat.ble PRE_first_tail_x8_r0_body.P179.N0 PRE_first_tail_x8_r0_body.cx0_179.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow179 : PRE_first_tail_x8_r0_body.kd179.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren179 : checkRenG PRE_first_tail_x8_r0_body.kd179.hnd PRE_first_tail_x8_r0_body.khinv179 (phB PRE_first_tail_x8_r0_body.cx0_179.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband179 : PRE_first_tail_x8_r0_body.kd179.checkBand PRE_first_tail_x8_r0_body.P179.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos179 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd179.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren179 : checkRenG PRE_first_tail_x8_r0_body.kd179.node PRE_first_tail_x8_r0_body.kninv179 (pnB PRE_first_tail_x8_r0_body.cx0_179.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow179 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd179.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P179.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd179.nodeF j) PRE_first_tail_x8_r0_body.cx1_179.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a179 : PRE_first_tail_x8_r0_body.cx0_179.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b179 : PRE_first_tail_x8_r0_body.cx0_179.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1179 : PRE_first_tail_x8_r0_body.cx1_179.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend179 : PRE_first_tail_x8_r0_body.cx1_179.mlx.pending = PRE_first_tail_x8_r0_body.cx0_179.mlx.pending.map PRE_first_tail_x8_r0_body.kappa179.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh179 : PRE_first_tail_x8_r0_body.cx1_179.mlx.errh = PRE_first_tail_x8_r0_body.cx0_179.mlx.errh.map PRE_first_tail_x8_r0_body.kappa179.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles179 : PRE_first_tail_x8_r0_body.cx1_179.mlx.files = PRE_first_tail_x8_r0_body.cx0_179.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch179 : PRE_first_tail_x8_r0_body.cx1_179.mlx.arch = PRE_first_tail_x8_r0_body.cx0_179.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes179 : PRE_first_tail_x8_r0_body.cx1_179.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_179.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired179 : PRE_first_tail_x8_r0_body.cx1_179.mlx.wired = PRE_first_tail_x8_r0_body.cx0_179.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost179 : PRE_first_tail_x8_r0_body.cx1_179.host = PRE_first_tail_x8_r0_body.cx0_179.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd179`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0179 : PRE_first_tail_x8_r0_body.kd179.n0 = 2815230
kernel_rfl PRE_first_tail_x8_r0_body.ckn1179 : PRE_first_tail_x8_r0_body.kd179.n1 = 2815250
kernel_rfl PRE_first_tail_x8_r0_body.ckheap179 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd179.heap).all (fun x => Nat.ble 2815229 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl179 : (List.range 1).all (fun j => decide (PRE_first_tail_x8_r0_body.kd179.heap.get (2815229 + j) = nth? PRE_first_tail_x8_r0_body.pl179 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja179 : Nat.ble 2815229 2815229 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn179 : Nat.ble 7705 7705 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD179 : Nat.ble 2815229 PRE_first_tail_x8_r0_body.kd179.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn179 : Nat.ble 21721 PRE_first_tail_x8_r0_body.kd179.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn179 : Nat.ble 18814 PRE_first_tail_x8_r0_body.kd179.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb179 : Nat.ble 21721 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap179 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd179.heap).all (Nat.ble (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd179 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd179.hnd).all (Nat.ble (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode179 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd179.node).all (Nat.ble (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix179 : Conv.FixOld (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa179 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja179) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn179) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD179) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn179) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn179) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb179) PRE_first_tail_x8_r0_body.fheap179 PRE_first_tail_x8_r0_body.fhnd179 PRE_first_tail_x8_r0_body.fnode179
kernel_rfl PRE_first_tail_x8_r0_body.fcxn179 : (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn179 : (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0179 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_179.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_179.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk179 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd179.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A179 : PRE_first_tail_x8_r0_body.cx1_179.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS179.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_179.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O179 : PRE_first_tail_x8_r0_body.cx1_179.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS179.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_179.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N179 : PRE_first_tail_x8_r0_body.cx1_179.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS179.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_179.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I179 : PRE_first_tail_x8_r0_body.cx1_179.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS179.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_179.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd179 : (PRE_first_tail_x8_r0_body.clo179 ++ PRE_first_tail_x8_r0_body.cln179 ++ PRE_first_tail_x8_r0_body.cli179 ++ PRE_first_tail_x8_r0_body.cwS179 ++ PRE_first_tail_x8_r0_body.cnS179 ++ PRE_first_tail_x8_r0_body.ciS179).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW179 : PRE_first_tail_x8_r0_body.cwS179.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo179.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI179 : PRE_first_tail_x8_r0_body.ciS179.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli179.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN179 : PRE_first_tail_x8_r0_body.cnS179.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF179 : PRE_first_tail_x8_r0_body.cln179.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh179 : PRE_first_tail_x8_r0_body.clo179.all (handleOK PRE_first_tail_x8_r0_body.kappa179 PRE_first_tail_x8_r0_body.P179.lo PRE_first_tail_x8_r0_body.cx0_179.mlx PRE_first_tail_x8_r0_body.cx1_179.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo179 : PRE_first_tail_x8_r0_body.clo179.map (fun h => PRE_first_tail_x8_r0_body.cx1_179.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa179.handle h)) = PRE_first_tail_x8_r0_body.clo179.map (fun h => (PRE_first_tail_x8_r0_body.cx0_179.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa179.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok179 : PRE_first_tail_x8_r0_body.clo179.all (objOK PRE_first_tail_x8_r0_body.kappa179 PRE_first_tail_x8_r0_body.P179.NL PRE_first_tail_x8_r0_body.cx0_179.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd179 : PRE_first_tail_x8_r0_body.cln179.all (nodeOKF PRE_first_tail_x8_r0_body.kappa179 PRE_first_tail_x8_r0_body.P179 PRE_first_tail_x8_r0_body.cx0_179.mlx PRE_first_tail_x8_r0_body.cx1_179.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp179 : ((PRE_first_tail_x8_r0_body.cln179.filter (fullB PRE_first_tail_x8_r0_body.P179))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_179.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa179.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln179.filter (fullB PRE_first_tail_x8_r0_body.P179))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_179.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa179.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI179 : incrB PRE_first_tail_x8_r0_body.kd179.nodeF (List.range' 18814 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK179 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd179.node).all (fun k => Nat.ble 18814 k && Nat.blt k 18814) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL179 : (PRE_first_tail_x8_r0_body.cln179.filter (Nat.ble PRE_first_tail_x8_r0_body.P179.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd179.nodeF i) && (Nat.blt i 18814 || Nat.ble PRE_first_tail_x8_r0_body.kd179.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord179 : (PRE_first_tail_x8_r0_body.cln179.filter (Nat.ble PRE_first_tail_x8_r0_body.P179.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd179.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd179.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd179.nodeF j) (PRE_first_tail_x8_r0_body.kd179.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow179 PRE_first_tail_x8_r0_body.cnn1179 PRE_first_tail_x8_r0_body.fnordI179 PRE_first_tail_x8_r0_body.fnordK179 PRE_first_tail_x8_r0_body.fnordL179
kernel_rfl PRE_first_tail_x8_r0_body.fi179 : PRE_first_tail_x8_r0_body.cli179.all (pnB PRE_first_tail_x8_r0_body.cx0_179.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii179 : PRE_first_tail_x8_r0_body.cli179.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_179.mlx.items.get (PRE_first_tail_x8_r0_body.kappa179.node k) = (PRE_first_tail_x8_r0_body.cx0_179.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa179.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot179 (clean : Conv.NClean (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P179.NL) (cl : SSt (· < 7705) PRE_first_tail_x8_r0_body.cx0_179.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P179 7705 PRE_first_tail_x8_r0_body.kappa179 PRE_first_tail_x8_r0_body.kd179 PRE_first_tail_x8_r0_body.khinv179 PRE_first_tail_x8_r0_body.kninv179 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx PRE_first_tail_x8_r0_body.cx0_179.mlx PRE_first_tail_x8_r0_body.cx1_179.mlx (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo179 PRE_first_tail_x8_r0_body.cln179 PRE_first_tail_x8_r0_body.cli179 PRE_first_tail_x8_r0_body.cwS179 PRE_first_tail_x8_r0_body.cnS179 PRE_first_tail_x8_r0_body.ciS179 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0179, PRE_first_tail_x8_r0_body.cnh1179, PRE_first_tail_x8_r0_body.cnn0179, PRE_first_tail_x8_r0_body.cnn1179, PRE_first_tail_x8_r0_body.cplo179, PRE_first_tail_x8_r0_body.ccnt179, PRE_first_tail_x8_r0_body.cnband179, PRE_first_tail_x8_r0_body.chbelow179, PRE_first_tail_x8_r0_body.chren179, PRE_first_tail_x8_r0_body.cband179, PRE_first_tail_x8_r0_body.cnh1pos179, PRE_first_tail_x8_r0_body.cnren179, PRE_first_tail_x8_r0_body.cnlow179, PRE_first_tail_x8_r0_body.cabs0a179, PRE_first_tail_x8_r0_body.cabs0b179, PRE_first_tail_x8_r0_body.ctok1179, PRE_first_tail_x8_r0_body.cpend179, PRE_first_tail_x8_r0_body.cerrh179, PRE_first_tail_x8_r0_body.cfiles179, PRE_first_tail_x8_r0_body.carch179, PRE_first_tail_x8_r0_body.csizes179, PRE_first_tail_x8_r0_body.cwired179, PRE_first_tail_x8_r0_body.cfix179, clean, PRE_first_tail_x8_r0_body.fcxn179, PRE_first_tail_x8_r0_body.fcnn179, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0179, PRE_first_tail_x8_r0_body.fnk179, PRE_first_tail_x8_r0_body.ckA179, PRE_first_tail_x8_r0_body.cobjsK179, PRE_first_tail_x8_r0_body.cnodesK179, PRE_first_tail_x8_r0_body.citemsK179, PRE_first_tail_x8_r0_body.f1A179, PRE_first_tail_x8_r0_body.f1O179, PRE_first_tail_x8_r0_body.f1N179, PRE_first_tail_x8_r0_body.f1I179, PRE_first_tail_x8_r0_body.fbd179, PRE_first_tail_x8_r0_body.fincW179, PRE_first_tail_x8_r0_body.fincI179, PRE_first_tail_x8_r0_body.fincN179, PRE_first_tail_x8_r0_body.flnF179, PRE_first_tail_x8_r0_body.fh179, PRE_first_tail_x8_r0_body.fo179, PRE_first_tail_x8_r0_body.fok179, PRE_first_tail_x8_r0_body.fnd179, PRE_first_tail_x8_r0_body.fp179, PRE_first_tail_x8_r0_body.fnord179, PRE_first_tail_x8_r0_body.fi179, PRE_first_tail_x8_r0_body.fii179⟩
theorem PRE_first_tail_x8_r0_body.cnshift179 (clean : Conv.NClean (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P179.NL) (cl : SSt (· < 7705) PRE_first_tail_x8_r0_body.cx0_179.mlx) : NShift PRE_first_tail_x8_r0_body.P179 7705 PRE_first_tail_x8_r0_body.kappa179 PRE_first_tail_x8_r0_body.cx0_179 PRE_first_tail_x8_r0_body.cx1_179 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot179 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost179 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0179 PRE_first_tail_x8_r0_body.ckn1179 PRE_first_tail_x8_r0_body.ckheap179 PRE_first_tail_x8_r0_body.ckpl179)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_179 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1724.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_179 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1724.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_179 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1724.ffi) = some PRE_first_tail_x8_r0_body.fxC_179
kernel_rfl PRE_first_tail_x8_r0_body.okrC_179 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1724.ffi) = some PRE_first_tail_x8_r0_body.krC_179
noncomputable def PRE_first_tail_x8_r0_body.fx0_179 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1726.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_179 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1726.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_179 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1726.ffi) = some PRE_first_tail_x8_r0_body.fx0_179
kernel_rfl PRE_first_tail_x8_r0_body.okr0_179 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1726.ffi) = some PRE_first_tail_x8_r0_body.kr0_179
noncomputable def PRE_first_tail_x8_r0_body.fx1_179 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1725.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_179 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1725.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_179 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1725.ffi) = some PRE_first_tail_x8_r0_body.fx1_179
kernel_rfl PRE_first_tail_x8_r0_body.okr1_179 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1725.ffi) = some PRE_first_tail_x8_r0_body.kr1_179
kernel_rfl PRE_first_tail_x8_r0_body.ff0179 : PRE_first_tail_x8_r0_body.fx0_179 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_179 (PRE_first_tail_x8_r0_body.clo179.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_179.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1179 : PRE_first_tail_x8_r0_body.fx1_179 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_179 (PRE_first_tail_x8_r0_body.cwS179.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_179.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck179 : freedLB PRE_first_tail_x8_r0_body.kappa179 PRE_first_tail_x8_r0_body.cx0_179.mlx PRE_first_tail_x8_r0_body.fx0_179 PRE_first_tail_x8_r0_body.fx1_179 PRE_first_tail_x8_r0_body.clo179 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0179 : PRE_first_tail_x8_r0_body.kr0_179.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_179.flags (PRE_first_tail_x8_r0_body.clo179.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_179.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0179 : PRE_first_tail_x8_r0_body.kr0_179.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_179.targs (PRE_first_tail_x8_r0_body.clo179.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_179.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1179 : PRE_first_tail_x8_r0_body.kr1_179.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_179.flags (PRE_first_tail_x8_r0_body.cwS179.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_179.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1179 : PRE_first_tail_x8_r0_body.kr1_179.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_179.targs (PRE_first_tail_x8_r0_body.cwS179.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_179.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck179 : krecLB PRE_first_tail_x8_r0_body.kappa179 7705 PRE_first_tail_x8_r0_body.cx0_179.mlx PRE_first_tail_x8_r0_body.kr0_179 PRE_first_tail_x8_r0_body.kr1_179 PRE_first_tail_x8_r0_body.clo179 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn179 : Nat.ble 7705 7705 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge179 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1725.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1726.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR179 : pendRegB PRE_first_tail_x8_r0_body.kappa179 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe179 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1726.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1725.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift179 (clean : Conv.NClean (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P179.NL) (cl : SSt (· < 7705) PRE_first_tail_x8_r0_body.cx0_179.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_179.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_179.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_179.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1724.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_179.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P179 7705 PRE_first_tail_x8_r0_body.kappa179 PRE_first_tail_x8_r0_body.s1726.ffi PRE_first_tail_x8_r0_body.s1725.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift179 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue179, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp179 t ht),
    PRE_first_tail_x8_r0_body.cbridge179,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1726.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1725.ffi) (PRE_first_tail_x8_r0_body.cfoot179 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_179 PRE_first_tail_x8_r0_body.ofx1_179 hobjC PRE_first_tail_x8_r0_body.ff0179 PRE_first_tail_x8_r0_body.ff1179 PRE_first_tail_x8_r0_body.ffck179,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1726.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1725.ffi) (PRE_first_tail_x8_r0_body.cfoot179 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_179 PRE_first_tail_x8_r0_body.okr1_179 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn179) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0179 PRE_first_tail_x8_r0_body.fkt0179 PRE_first_tail_x8_r0_body.fkf1179 PRE_first_tail_x8_r0_body.fkt1179 PRE_first_tail_x8_r0_body.fkck179,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0179 PRE_first_tail_x8_r0_body.cnh1179 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe179) PRE_first_tail_x8_r0_body.cpendR179⟩

end Host.Load.Run.Tpl
end

section -- st179/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st179 0
host_stream_state PRE_first_tail_x8_r0_body.st179 1
host_stream_state PRE_first_tail_x8_r0_body.st179 2
end Host.Load.Run.Tpl
end

section -- Site179
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 179 of chain `PRE_first_tail_x8_r0_body`: `plan__g179__g180` (`plan`), the call state `PRE_first_tail_x8_r0_body.s1724`, the merged state `PRE_first_tail_x8_r0_body.s1725`,
the site template `PRE_first_tail_x8_r0_body.st179` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1726`: the merge.
The footprint's facts are in `SiteF179`, the compaction's in `SiteC179`, `SiteK179`, `SiteNa179`, `SiteNb179`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso179 : PRE_first_tail_x8_r0_body.st179.s0 = { PRE_first_tail_x8_r0_body.s1724 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs179 : List Frame := PRE_first_tail_x8_r0_body.s1724.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_179 : PRE_first_tail_x8_r0_body.S1724.tab.length = 7705
kernel_rfl PRE_first_tail_x8_r0_body.tab0_179 : PRE_first_tail_x8_r0_body.st179.S0.tab = PRE_first_tail_x8_r0_body.S1724.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws179 : List Nat := [4018, 4019, 4020, 4021, 4022, 4023, 4024, 4025, 4026]
kernel_rfl PRE_first_tail_x8_r0_body.fresh179 : (PRE_first_tail_x8_r0_body.S1724.tab.all fun e => PRE_first_tail_x8_r0_body.ws179.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1724.oracle.all fun q => PRE_first_tail_x8_r0_body.ws179.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab179 : PRE_first_tail_x8_r0_body.S1725.tab = PRE_first_tail_x8_r0_body.S1724.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws179
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen179 : PRE_first_tail_x8_r0_body.st179.S2.tab.length - PRE_first_tail_x8_r0_body.st179.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged179`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap179 : PRE_first_tail_x8_r0_body.s1725.heap = PRE_first_tail_x8_r0_body.st179.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext179 : PRE_first_tail_x8_r0_body.s1725.next = PRE_first_tail_x8_r0_body.st179.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl179 : PRE_first_tail_x8_r0_body.s1725.ctl = PRE_first_tail_x8_r0_body.st179.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack179 : PRE_first_tail_x8_r0_body.s1725.stack = PRE_first_tail_x8_r0_body.st179.s2.stack ++ PRE_first_tail_x8_r0_body.s1724.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs179 : PRE_first_tail_x8_r0_body.s1725.jobs = PRE_first_tail_x8_r0_body.st179.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi179 : PRE_first_tail_x8_r0_body.s1725.ffi = PRE_first_tail_x8_r0_body.st179.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace179 : PRE_first_tail_x8_r0_body.s1725.trace = PRE_first_tail_x8_r0_body.st179.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores179 : PRE_first_tail_x8_r0_body.s1725.stores = PRE_first_tail_x8_r0_body.st179.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD179
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 179 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived179 : PRE_first_tail_x8_r0_body.nr179.map (fun r => nth? PRE_first_tail_x8_r0_body.st179.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo179 : PRE_first_tail_x8_r0_body.nr179.all (Nat.ble 7705) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj179 : PRE_first_tail_x8_r0_body.cws179.all (fun c => !PRE_first_tail_x8_r0_body.ws179.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ179 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws179 PRE_first_tail_x8_r0_body.crs179 PRE_first_tail_x8_r0_body.ws179

end Host.Load.Run.Tpl
end

section -- st179/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st179`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st179.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st179.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st179.s2.heap PRE_first_tail_x8_r0_body.st179.wrR ++ freshOf PRE_first_tail_x8_r0_body.st179.s2.heap PRE_first_tail_x8_r0_body.st179.s0.next PRE_first_tail_x8_r0_body.st179.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st179.wr : List Nat := PRE_first_tail_x8_r0_body.st179.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st179.heapFoot : PRE_first_tail_x8_r0_body.st179.s2.heap = setAll PRE_first_tail_x8_r0_body.st179.s0.heap PRE_first_tail_x8_r0_body.st179.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st179.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st179.s0.next PRE_first_tail_x8_r0_body.st179.s2.next = true
theorem PRE_first_tail_x8_r0_body.st179.grows : PRE_first_tail_x8_r0_body.st179.s0.next ≤ PRE_first_tail_x8_r0_body.st179.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st179.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st179.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st179.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st179.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st179.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st179.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st179.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st179.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st179.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st179.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st179.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st179.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF179
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 179 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB179 : nodupT PRE_first_tail_x8_r0_body.st179.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup179 : PRE_first_tail_x8_r0_body.st179.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB179).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB179 : PRE_first_tail_x8_r0_body.st179.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound179 : ∀ b ∈ PRE_first_tail_x8_r0_body.st179.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB179 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr179 := PRE_first_tail_x8_r0_body.st179.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq179 : PRE_first_tail_x8_r0_body.st179.s2.trace = PRE_first_tail_x8_r0_body.trFr179 ++ PRE_first_tail_x8_r0_body.st179.s0.trace
theorem PRE_first_tail_x8_r0_body.trace179 : ∃ fr, PRE_first_tail_x8_r0_body.st179.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st179.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq179⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide179 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB179 : (PRE_first_tail_x8_r0_body.wide179.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st179.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix179 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide179, WFix Map.id (Present PRE_first_tail_x8_r0_body.st179.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB179 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL179
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 179 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1725`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO179 : PRE_first_tail_x8_r0_body.st179.S0.oracle = PRE_first_tail_x8_r0_body.st179.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B179 : PRE_first_tail_x8_r0_body.st179.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st179.s0.next || (PRE_first_tail_x8_r0_body.st179.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot179 : Conv.StageFoot PRE_first_tail_x8_r0_body.st179.wr PRE_first_tail_x8_r0_body.st179.s0 PRE_first_tail_x8_r0_body.st179.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st179.heapFoot PRE_first_tail_x8_r0_body.wrNodup179 PRE_first_tail_x8_r0_body.wrBound179 PRE_first_tail_x8_r0_body.wr0B179 PRE_first_tail_x8_r0_body.st179.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged179 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st179.F.S → PRE_first_tail_x8_r0_body.st179.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st179.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st179.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs179 PRE_first_tail_x8_r0_body.st179.wr PRE_first_tail_x8_r0_body.s1724 PRE_first_tail_x8_r0_body.st179.s2 PRE_first_tail_x8_r0_body.st179.s0
      PRE_first_tail_x8_r0_body.st179.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st179.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1725 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso179 PRE_first_tail_x8_r0_body.stFoot179 PRE_first_tail_x8_r0_body.wrNodup179 PRE_first_tail_x8_r0_body.wrBound179 PRE_first_tail_x8_r0_body.trace179 PRE_first_tail_x8_r0_body.mheap179
    PRE_first_tail_x8_r0_body.mnext179 PRE_first_tail_x8_r0_body.mctl179 PRE_first_tail_x8_r0_body.mstack179 PRE_first_tail_x8_r0_body.mjobs179 PRE_first_tail_x8_r0_body.mffi179 PRE_first_tail_x8_r0_body.mtrace179 PRE_first_tail_x8_r0_body.mstores179 h

def PRE_first_tail_x8_r0_body.arrEl179_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE179_2665 : arrOf PRE_first_tail_x8_r0_body.s1725 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl179_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA179_2665 : isArrB PRE_first_tail_x8_r0_body.s1725 2665 = true
theorem PRE_first_tail_x8_r0_body.arr179_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1725.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl179_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE179_2665 PRE_first_tail_x8_r0_body.arrA179_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN179_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl179_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR179_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl179_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN179_2665

def PRE_first_tail_x8_r0_body.arrEl179_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE179_2673467 : arrOf PRE_first_tail_x8_r0_body.s1725 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl179_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA179_2673467 : isArrB PRE_first_tail_x8_r0_body.s1725 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr179_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1725.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl179_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE179_2673467 PRE_first_tail_x8_r0_body.arrA179_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN179_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl179_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR179_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl179_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN179_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k179 : isArrB PRE_first_tail_x8_r0_body.s1725 4910 = false
theorem PRE_first_tail_x8_r0_body.keep179 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1725 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k179 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr179_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl179_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ179
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 179 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1724`, the merged
state `PRE_first_tail_x8_r0_body.s1725`, the canonical state `PRE_first_tail_x8_r0_body.s1726`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl179 : PRE_first_tail_x8_r0_body.pl179.all (Nat.ble PRE_first_tail_x8_r0_body.s1724.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd179 : nodupT PRE_first_tail_x8_r0_body.pl179 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1179 : Nat.ble PRE_first_tail_x8_r0_body.s1724.next 2815250 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst179 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1724.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn179 : PRE_first_tail_x8_r0_body.s1726.next = PRE_first_tail_x8_r0_body.s1724.next + PRE_first_tail_x8_r0_body.pl179.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn179 : PRE_first_tail_x8_r0_body.s1725.next = 2815250
kernel_rfl PRE_first_tail_x8_r0_body.zgrow179 : Nat.ble PRE_first_tail_x8_r0_body.s1726.next PRE_first_tail_x8_r0_body.s1725.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh179 : PRE_first_tail_x8_r0_body.S1724.tab.all (fun e => PRE_first_tail_x8_r0_body.cws179.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd179 : nodupT PRE_first_tail_x8_r0_body.cws179 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi179 : PRE_first_tail_x8_r0_body.nr179.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1725.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt179 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1724.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg179_2665 : PRE_first_tail_x8_r0_body.s1726.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1726 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk179_2665 : (objOf PRE_first_tail_x8_r0_body.s1726 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm179_2665 : PRE_first_tail_x8_r0_body.s1725.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa179.obj (objOf PRE_first_tail_x8_r0_body.s1726 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1725 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg179_2673467 : PRE_first_tail_x8_r0_body.s1726.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1726 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk179_2673467 : (objOf PRE_first_tail_x8_r0_body.s1726 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm179_2673467 : PRE_first_tail_x8_r0_body.s1725.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa179.obj (objOf PRE_first_tail_x8_r0_body.s1726 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1725 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw179_4910 : (PRE_first_tail_x8_r0_body.s1726.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw179_2673472 : (PRE_first_tail_x8_r0_body.s1726.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw179_2673473 : (PRE_first_tail_x8_r0_body.s1726.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd179 : PRE_first_tail_x8_r0_body.cl179.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr179 : PRE_first_tail_x8_r0_body.st179.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1724.next || PRE_first_tail_x8_r0_body.cl179.contains b) = true
def PRE_first_tail_x8_r0_body.zl179 : List Nat := PRE_first_tail_x8_r0_body.cl179.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE179 : PRE_first_tail_x8_r0_body.zl179.map (fun a => PRE_first_tail_x8_r0_body.s1725.heap.get (PRE_first_tail_x8_r0_body.kappa179.a a)) = PRE_first_tail_x8_r0_body.zl179.map (fun a => (PRE_first_tail_x8_r0_body.s1726.heap.get a).map PRE_first_tail_x8_r0_body.kappa179.hobj)
theorem PRE_first_tail_x8_r0_body.zimg179 : HeapImg PRE_first_tail_x8_r0_body.kappa179 PRE_first_tail_x8_r0_body.s1726 PRE_first_tail_x8_r0_body.s1725 PRE_first_tail_x8_r0_body.zl179 := PRE_first_tail_x8_r0_body.zimgE179
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl179 : PRE_first_tail_x8_r0_body.s1725.ctl = PRE_first_tail_x8_r0_body.kappa179.ctl PRE_first_tail_x8_r0_body.s1726.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack179 : PRE_first_tail_x8_r0_body.s1725.stack = PRE_first_tail_x8_r0_body.s1726.stack.map PRE_first_tail_x8_r0_body.kappa179.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs179 : PRE_first_tail_x8_r0_body.s1725.jobs = PRE_first_tail_x8_r0_body.s1726.jobs.map PRE_first_tail_x8_r0_body.kappa179.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores179 : PRE_first_tail_x8_r0_body.s1725.stores = PRE_first_tail_x8_r0_body.kappa179.stores PRE_first_tail_x8_r0_body.s1726.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots179 : checkRootsSupp PRE_first_tail_x8_r0_body.s1726 7705 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC179 : PRE_first_tail_x8_r0_body.S1724.tab.length + PRE_first_tail_x8_r0_body.cws179.length = 7705
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap179 : PRE_first_tail_x8_r0_body.kappa179 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1724.next 2815250 PRE_first_tail_x8_r0_body.S1724.tab.length PRE_first_tail_x8_r0_body.pl179 (PRE_first_tail_x8_r0_body.nr179.map NumV.ref) PRE_first_tail_x8_r0_body.kd179.big
  PRE_first_tail_x8_r0_body.kd179.region PRE_first_tail_x8_r0_body.kd179.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin179 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1726.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc179 : Conv.jcleanListB (⟨21721, 18814, 2815230, 7705⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1726 PRE_first_tail_x8_r0_body.cl179 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB179 : noBigRootsP (fun i => !Conv.oldBigB (⟨21721, 18814, 2815230, 7705⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1726.trace PRE_first_tail_x8_r0_body.s1726 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm179 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18814 = true
theorem PRE_first_tail_x8_r0_body.cjcl179 (h : Conv.JClean (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1724) : Conv.JClean (⟨21721, 18814, 2815230, 7705⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1726 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle179)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap179 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd179 a ha)) PRE_first_tail_x8_r0_body.zjc179

end Host.Load.Run.Tpl
end

section -- st179/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st179.bodyLast from PRE_first_tail_x8_r0_body.st179.s1 to PRE_first_tail_x8_r0_body.st179.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st179.F PRE_first_tail_x8_r0_body.st179.s1).run PRE_first_tail_x8_r0_body.st179.S1 = some (PRE_first_tail_x8_r0_body.st179.s2, PRE_first_tail_x8_r0_body.st179.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st179.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st179.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st179.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st179.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st179/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st179.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st179.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st179.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st179.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st179.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st179.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st179.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st179.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st179.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st179.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st179.s0 PRE_first_tail_x8_r0_body.st179.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st179.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st179.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st179.s1 PRE_first_tail_x8_r0_body.st179.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st179/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st179.bodyK0F from PRE_first_tail_x8_r0_body.st179.s0 to PRE_first_tail_x8_r0_body.st179.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st179.F (PRE_first_tail_x8_r0_body.st179.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st179.ks 0).getD 0) PRE_first_tail_x8_r0_body.st179.s0 PRE_first_tail_x8_r0_body.st179.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st179.s1, PRE_first_tail_x8_r0_body.st179.S1)
theorem PRE_first_tail_x8_r0_body.st179.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st179.F (PRE_first_tail_x8_r0_body.st179.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st179.ks 0).getD 0) PRE_first_tail_x8_r0_body.st179.s0 PRE_first_tail_x8_r0_body.st179.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st179.s1, PRE_first_tail_x8_r0_body.st179.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st179.bodyOkLN_ok PRE_first_tail_x8_r0_body.st179.bodyK0F
end Host.Load.Run.Tpl
end

section -- st179/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st179.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st179.F (PRE_first_tail_x8_r0_body.st179.bodyOkL bytes rows) 214 PRE_first_tail_x8_r0_body.st179.s0 PRE_first_tail_x8_r0_body.st179.S0 = some (PRE_first_tail_x8_r0_body.st179.s1, PRE_first_tail_x8_r0_body.st179.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st179.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st179.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st179.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st179.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st179.F (PRE_first_tail_x8_r0_body.st179.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st179.s0
  S0 := PRE_first_tail_x8_r0_body.st179.S0
  s1 := PRE_first_tail_x8_r0_body.st179.s1
  S1 := PRE_first_tail_x8_r0_body.st179.S1
  s2 := PRE_first_tail_x8_r0_body.st179.s2
  S2 := PRE_first_tail_x8_r0_body.st179.S2
  n := 214
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st179.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st179.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st179.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st179.bodyHalt
  last := PRE_first_tail_x8_r0_body.st179.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st179.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC180
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 180 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1743` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa180` into the merged state
`PRE_first_tail_x8_r0_body.s1742`. -/

def PRE_first_tail_x8_r0_body.pl180 : List Nat := [2817839, 2817014, 2817845, 2817841, 2817016, 2817847]
def PRE_first_tail_x8_r0_body.nr180 : List Nat := [7808, 7807, 7783, 7791, 7796, 7801, 7806, 7780, 7781, 7782, 7789, 7790, 7778, 7785, 7786, 7787, 7788, 7784]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd180 : RData :=
  ⟨2816733, 2817882, Stage.setAll PTrie.nil [(2816727, 2817839), (2816728, 2817014), (2816729, 2817845), (2816730, 2817841), (2816731, 2817016), (2816732, 2817847)], Stage.setAll PTrie.nil [(21756, 21782), (21757, 21760), (21758, 21783)],
   21759, 21784, 18860, 18860, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(7778, .ref 7808), (7779, .ref 7807), (7780, .ref 7783), (7781, .ref 7791), (7782, .ref 7796), (7783, .ref 7801), (7784, .ref 7806), (7785, .ref 7780), (7786, .ref 7781), (7787, .ref 7782), (7788, .ref 7789), (7789, .ref 7790), (7790, .ref 7778), (7791, .ref 7785), (7792, .ref 7786), (7793, .ref 7787), (7794, .ref 7788), (7795, .ref 7784)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa180 : Map :=
  Conv.Map.compact 2816727 2817882 7778 PRE_first_tail_x8_r0_body.pl180 (PRE_first_tail_x8_r0_body.nr180.map NumV.ref) PRE_first_tail_x8_r0_body.kd180.big
    PRE_first_tail_x8_r0_body.kd180.region PRE_first_tail_x8_r0_body.kd180.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws180 : List Nat := [4058, 4059, 4060, 4061, 4062, 4063, 4064, 4065, 4066, 4067, 4068, 4069, 4070, 4071, 4072, 4073, 4074, 4075]
noncomputable def PRE_first_tail_x8_r0_body.crs180 : List SymE := PRE_first_tail_x8_r0_body.nr180.map fun r => (nth? PRE_first_tail_x8_r0_body.S1742.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta180 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws180 PRE_first_tail_x8_r0_body.crs180
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB180 : List Nat := [2665, 2672765, 2673467, 2815901, 2816446, 2816702]

kernel_rfl PRE_first_tail_x8_r0_body.ctab180 : PRE_first_tail_x8_r0_body.S1743.tab = PRE_first_tail_x8_r0_body.S1741.tab ++ PRE_first_tail_x8_r0_body.cws180.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace180 : PRE_first_tail_x8_r0_body.s1743.trace = PRE_first_tail_x8_r0_body.s1741.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext180 : PRE_first_tail_x8_r0_body.s1743.next = 2816733
kernel_rfl PRE_first_tail_x8_r0_body.ccounters180 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx.nnext) = (21759, 18860)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue180 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1742.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa180.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp180 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx.tokens.all (bSN 7796) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean180 : Conv.cleanListB 21759 131072 (fun r => Nat.ble 87036 r) PRE_first_tail_x8_r0_body.s1743
    (PRE_first_tail_x8_r0_body.wrB180 ++ (List.range 6).map (2816727 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs180 : bigsOutB 21759 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK180
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl180`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl180 : List Nat := [2665, 2672765, 2673467, 2815901, 2816446, 2816702, 2816727, 2816728, 2816729, 2816730, 2816731, 2816732]
def PRE_first_tail_x8_r0_body.clo180 : List Nat := [21736, 21749, 21755, 21756, 21757, 21758]
def PRE_first_tail_x8_r0_body.cln180 : List Nat := [18833, 18834, 18835, 18836, 18837, 18838, 18839, 18840, 18841, 18842, 18843, 18844, 18845, 18846, 18847, 18848, 18849, 18850, 18851, 18852, 18853, 18854, 18855, 18856, 18857, 18858, 18859]
def PRE_first_tail_x8_r0_body.cli180 : List Nat := [18833, 18834, 18835, 18836, 18837, 18838, 18839, 18840, 18841, 18842, 18843, 18844, 18845, 18846, 18847, 18848, 18849, 18850, 18851, 18852, 18853, 18854, 18855, 18856, 18857, 18858, 18859]
kernel_rfl PRE_first_tail_x8_r0_body.cheap180 : PRE_first_tail_x8_r0_body.s1743.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1741.heap (PRE_first_tail_x8_r0_body.cl180.filterMap fun a => (PRE_first_tail_x8_r0_body.s1743.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe180 : Nat.ble PRE_first_tail_x8_r0_body.s1741.next PRE_first_tail_x8_r0_body.s1743.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP180 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1741 PRE_first_tail_x8_r0_body.s1743 PRE_first_tail_x8_r0_body.cl180 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp180 : Conv.suppListB PRE_first_tail_x8_r0_body.s1743 7796 PRE_first_tail_x8_r0_body.cl180 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound180 : Conv.boundListB PRE_first_tail_x8_r0_body.s1743 PRE_first_tail_x8_r0_body.cl180 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK180 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln180.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK180 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo180.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK180 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli180.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst180 : Conv.sstListB 7796 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx PRE_first_tail_x8_r0_body.cln180 PRE_first_tail_x8_r0_body.clo180 PRE_first_tail_x8_r0_body.cli180 = true

end Host.Load.Run.Tpl
end

section -- SiteCl180
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA180 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo180.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd180 : (PRE_first_tail_x8_r0_body.clo180 ++ PRE_first_tail_x8_r0_body.cln180 ++ PRE_first_tail_x8_r0_body.cli180).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle180 : Conv.Cnt.leB (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt) (⟨21759, 18860, 2816733, 7796⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck180 : Conv.ncleanListB (⟨21759, 18860, 2816733, 7796⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx PRE_first_tail_x8_r0_body.clo180 PRE_first_tail_x8_r0_body.cln180 PRE_first_tail_x8_r0_body.cli180 = true
theorem PRE_first_tail_x8_r0_body.cncl180 (h : Conv.NClean (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx) : Conv.NClean (⟨21759, 18860, 2816733, 7796⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle180 PRE_first_tail_x8_r0_body.ckA180 PRE_first_tail_x8_r0_body.cobjsK180 PRE_first_tail_x8_r0_body.cnodesK180 PRE_first_tail_x8_r0_body.citemsK180 PRE_first_tail_x8_r0_body.cbd180 PRE_first_tail_x8_r0_body.cck180

end Host.Load.Run.Tpl
end

section -- SiteS180
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 180 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc180 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P180 : LoadP := PRE_first_tail_x8_r0_body.Pc180.raise 18860
kernel_rfl PRE_first_tail_x8_r0_body.craise180 : Nat.ble PRE_first_tail_x8_r0_body.Pc180.N0 18860 = true
theorem PRE_first_tail_x8_r0_body.raised180 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc180 PRE_first_tail_x8_r0_body.P180 :=
  .inr ⟨18860, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise180, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_180 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_180 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1742.ffi)
def PRE_first_tail_x8_r0_body.khinv180 : PTrie Nat := Stage.setAll PTrie.nil [(21782, 21756), (21760, 21757), (21783, 21758)]
def PRE_first_tail_x8_r0_body.kninv180 : PTrie Nat := Stage.setAll PTrie.nil [(18833, 18833), (18834, 18834), (18835, 18835), (18836, 18836), (18837, 18837), (18838, 18838), (18839, 18839), (18840, 18840), (18841, 18841), (18842, 18842), (18843, 18843), (18844, 18844), (18845, 18845), (18846, 18846), (18847, 18847), (18848, 18848), (18849, 18849), (18850, 18850), (18851, 18851), (18852, 18852), (18853, 18853), (18854, 18854), (18855, 18855), (18856, 18856), (18857, 18857), (18858, 18858), (18859, 18859)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS180 : List Nat := [21736, 21749, 21755, 21756, 21757, 21758, 21759, 21760, 21761, 21762, 21763, 21764, 21765, 21766, 21767, 21768, 21769, 21770, 21771, 21772, 21773, 21774, 21775, 21776, 21777, 21778, 21779, 21780, 21781, 21782, 21783]
def PRE_first_tail_x8_r0_body.cnS180 : List Nat := List.range' 18833 27
def PRE_first_tail_x8_r0_body.ciS180 : List Nat := [] ++ List.range' 18833 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0180 : PRE_first_tail_x8_r0_body.kd180.nh0 = PRE_first_tail_x8_r0_body.cx0_180.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1180 : PRE_first_tail_x8_r0_body.kd180.nh1 = PRE_first_tail_x8_r0_body.cx1_180.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0180 : PRE_first_tail_x8_r0_body.kd180.nn0 = PRE_first_tail_x8_r0_body.cx0_180.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1180 : PRE_first_tail_x8_r0_body.kd180.nn1 = PRE_first_tail_x8_r0_body.cx1_180.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo180 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P180.lo && Nat.ble PRE_first_tail_x8_r0_body.P180.lo PRE_first_tail_x8_r0_body.cx0_180.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P180.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P180.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt180 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_180.mlx.next PRE_first_tail_x8_r0_body.cx1_180.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_180.mlx.nnext PRE_first_tail_x8_r0_body.cx1_180.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband180 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P180.NL && Nat.ble PRE_first_tail_x8_r0_body.P180.NL PRE_first_tail_x8_r0_body.P180.N0 && Nat.ble PRE_first_tail_x8_r0_body.P180.N0 PRE_first_tail_x8_r0_body.cx0_180.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow180 : PRE_first_tail_x8_r0_body.kd180.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren180 : checkRenG PRE_first_tail_x8_r0_body.kd180.hnd PRE_first_tail_x8_r0_body.khinv180 (phB PRE_first_tail_x8_r0_body.cx0_180.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband180 : PRE_first_tail_x8_r0_body.kd180.checkBand PRE_first_tail_x8_r0_body.P180.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos180 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd180.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren180 : checkRenG PRE_first_tail_x8_r0_body.kd180.node PRE_first_tail_x8_r0_body.kninv180 (pnB PRE_first_tail_x8_r0_body.cx0_180.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow180 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd180.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P180.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd180.nodeF j) PRE_first_tail_x8_r0_body.cx1_180.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a180 : PRE_first_tail_x8_r0_body.cx0_180.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b180 : PRE_first_tail_x8_r0_body.cx0_180.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1180 : PRE_first_tail_x8_r0_body.cx1_180.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend180 : PRE_first_tail_x8_r0_body.cx1_180.mlx.pending = PRE_first_tail_x8_r0_body.cx0_180.mlx.pending.map PRE_first_tail_x8_r0_body.kappa180.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh180 : PRE_first_tail_x8_r0_body.cx1_180.mlx.errh = PRE_first_tail_x8_r0_body.cx0_180.mlx.errh.map PRE_first_tail_x8_r0_body.kappa180.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles180 : PRE_first_tail_x8_r0_body.cx1_180.mlx.files = PRE_first_tail_x8_r0_body.cx0_180.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch180 : PRE_first_tail_x8_r0_body.cx1_180.mlx.arch = PRE_first_tail_x8_r0_body.cx0_180.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes180 : PRE_first_tail_x8_r0_body.cx1_180.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_180.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired180 : PRE_first_tail_x8_r0_body.cx1_180.mlx.wired = PRE_first_tail_x8_r0_body.cx0_180.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost180 : PRE_first_tail_x8_r0_body.cx1_180.host = PRE_first_tail_x8_r0_body.cx0_180.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd180`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0180 : PRE_first_tail_x8_r0_body.kd180.n0 = 2816733
kernel_rfl PRE_first_tail_x8_r0_body.ckn1180 : PRE_first_tail_x8_r0_body.kd180.n1 = 2817882
kernel_rfl PRE_first_tail_x8_r0_body.ckheap180 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd180.heap).all (fun x => Nat.ble 2816727 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl180 : (List.range 6).all (fun j => decide (PRE_first_tail_x8_r0_body.kd180.heap.get (2816727 + j) = nth? PRE_first_tail_x8_r0_body.pl180 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja180 : Nat.ble 2816727 2816727 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn180 : Nat.ble 7778 7778 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD180 : Nat.ble 2816727 PRE_first_tail_x8_r0_body.kd180.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn180 : Nat.ble 21756 PRE_first_tail_x8_r0_body.kd180.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn180 : Nat.ble 18833 PRE_first_tail_x8_r0_body.kd180.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb180 : Nat.ble 21756 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap180 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd180.heap).all (Nat.ble (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd180 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd180.hnd).all (Nat.ble (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode180 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd180.node).all (Nat.ble (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix180 : Conv.FixOld (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa180 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja180) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn180) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD180) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn180) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn180) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb180) PRE_first_tail_x8_r0_body.fheap180 PRE_first_tail_x8_r0_body.fhnd180 PRE_first_tail_x8_r0_body.fnode180
kernel_rfl PRE_first_tail_x8_r0_body.fcxn180 : (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn180 : (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0180 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_180.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_180.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk180 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd180.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A180 : PRE_first_tail_x8_r0_body.cx1_180.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS180.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_180.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O180 : PRE_first_tail_x8_r0_body.cx1_180.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS180.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_180.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N180 : PRE_first_tail_x8_r0_body.cx1_180.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS180.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_180.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I180 : PRE_first_tail_x8_r0_body.cx1_180.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS180.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_180.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd180 : (PRE_first_tail_x8_r0_body.clo180 ++ PRE_first_tail_x8_r0_body.cln180 ++ PRE_first_tail_x8_r0_body.cli180 ++ PRE_first_tail_x8_r0_body.cwS180 ++ PRE_first_tail_x8_r0_body.cnS180 ++ PRE_first_tail_x8_r0_body.ciS180).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW180 : PRE_first_tail_x8_r0_body.cwS180.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo180.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI180 : PRE_first_tail_x8_r0_body.ciS180.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli180.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN180 : PRE_first_tail_x8_r0_body.cnS180.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF180 : PRE_first_tail_x8_r0_body.cln180.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh180 : PRE_first_tail_x8_r0_body.clo180.all (handleOK PRE_first_tail_x8_r0_body.kappa180 PRE_first_tail_x8_r0_body.P180.lo PRE_first_tail_x8_r0_body.cx0_180.mlx PRE_first_tail_x8_r0_body.cx1_180.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo180 : PRE_first_tail_x8_r0_body.clo180.map (fun h => PRE_first_tail_x8_r0_body.cx1_180.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa180.handle h)) = PRE_first_tail_x8_r0_body.clo180.map (fun h => (PRE_first_tail_x8_r0_body.cx0_180.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa180.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok180 : PRE_first_tail_x8_r0_body.clo180.all (objOK PRE_first_tail_x8_r0_body.kappa180 PRE_first_tail_x8_r0_body.P180.NL PRE_first_tail_x8_r0_body.cx0_180.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd180 : PRE_first_tail_x8_r0_body.cln180.all (nodeOKF PRE_first_tail_x8_r0_body.kappa180 PRE_first_tail_x8_r0_body.P180 PRE_first_tail_x8_r0_body.cx0_180.mlx PRE_first_tail_x8_r0_body.cx1_180.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp180 : ((PRE_first_tail_x8_r0_body.cln180.filter (fullB PRE_first_tail_x8_r0_body.P180))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_180.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa180.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln180.filter (fullB PRE_first_tail_x8_r0_body.P180))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_180.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa180.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI180 : incrB PRE_first_tail_x8_r0_body.kd180.nodeF (List.range' 18833 27) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK180 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd180.node).all (fun k => Nat.ble 18833 k && Nat.blt k 18860) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL180 : (PRE_first_tail_x8_r0_body.cln180.filter (Nat.ble PRE_first_tail_x8_r0_body.P180.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd180.nodeF i) && (Nat.blt i 18860 || Nat.ble PRE_first_tail_x8_r0_body.kd180.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord180 : (PRE_first_tail_x8_r0_body.cln180.filter (Nat.ble PRE_first_tail_x8_r0_body.P180.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd180.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd180.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd180.nodeF j) (PRE_first_tail_x8_r0_body.kd180.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow180 PRE_first_tail_x8_r0_body.cnn1180 PRE_first_tail_x8_r0_body.fnordI180 PRE_first_tail_x8_r0_body.fnordK180 PRE_first_tail_x8_r0_body.fnordL180
kernel_rfl PRE_first_tail_x8_r0_body.fi180 : PRE_first_tail_x8_r0_body.cli180.all (pnB PRE_first_tail_x8_r0_body.cx0_180.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii180 : PRE_first_tail_x8_r0_body.cli180.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_180.mlx.items.get (PRE_first_tail_x8_r0_body.kappa180.node k) = (PRE_first_tail_x8_r0_body.cx0_180.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa180.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot180 (clean : Conv.NClean (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P180.NL) (cl : SSt (· < 7796) PRE_first_tail_x8_r0_body.cx0_180.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P180 7796 PRE_first_tail_x8_r0_body.kappa180 PRE_first_tail_x8_r0_body.kd180 PRE_first_tail_x8_r0_body.khinv180 PRE_first_tail_x8_r0_body.kninv180 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx PRE_first_tail_x8_r0_body.cx0_180.mlx PRE_first_tail_x8_r0_body.cx1_180.mlx (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo180 PRE_first_tail_x8_r0_body.cln180 PRE_first_tail_x8_r0_body.cli180 PRE_first_tail_x8_r0_body.cwS180 PRE_first_tail_x8_r0_body.cnS180 PRE_first_tail_x8_r0_body.ciS180 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0180, PRE_first_tail_x8_r0_body.cnh1180, PRE_first_tail_x8_r0_body.cnn0180, PRE_first_tail_x8_r0_body.cnn1180, PRE_first_tail_x8_r0_body.cplo180, PRE_first_tail_x8_r0_body.ccnt180, PRE_first_tail_x8_r0_body.cnband180, PRE_first_tail_x8_r0_body.chbelow180, PRE_first_tail_x8_r0_body.chren180, PRE_first_tail_x8_r0_body.cband180, PRE_first_tail_x8_r0_body.cnh1pos180, PRE_first_tail_x8_r0_body.cnren180, PRE_first_tail_x8_r0_body.cnlow180, PRE_first_tail_x8_r0_body.cabs0a180, PRE_first_tail_x8_r0_body.cabs0b180, PRE_first_tail_x8_r0_body.ctok1180, PRE_first_tail_x8_r0_body.cpend180, PRE_first_tail_x8_r0_body.cerrh180, PRE_first_tail_x8_r0_body.cfiles180, PRE_first_tail_x8_r0_body.carch180, PRE_first_tail_x8_r0_body.csizes180, PRE_first_tail_x8_r0_body.cwired180, PRE_first_tail_x8_r0_body.cfix180, clean, PRE_first_tail_x8_r0_body.fcxn180, PRE_first_tail_x8_r0_body.fcnn180, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0180, PRE_first_tail_x8_r0_body.fnk180, PRE_first_tail_x8_r0_body.ckA180, PRE_first_tail_x8_r0_body.cobjsK180, PRE_first_tail_x8_r0_body.cnodesK180, PRE_first_tail_x8_r0_body.citemsK180, PRE_first_tail_x8_r0_body.f1A180, PRE_first_tail_x8_r0_body.f1O180, PRE_first_tail_x8_r0_body.f1N180, PRE_first_tail_x8_r0_body.f1I180, PRE_first_tail_x8_r0_body.fbd180, PRE_first_tail_x8_r0_body.fincW180, PRE_first_tail_x8_r0_body.fincI180, PRE_first_tail_x8_r0_body.fincN180, PRE_first_tail_x8_r0_body.flnF180, PRE_first_tail_x8_r0_body.fh180, PRE_first_tail_x8_r0_body.fo180, PRE_first_tail_x8_r0_body.fok180, PRE_first_tail_x8_r0_body.fnd180, PRE_first_tail_x8_r0_body.fp180, PRE_first_tail_x8_r0_body.fnord180, PRE_first_tail_x8_r0_body.fi180, PRE_first_tail_x8_r0_body.fii180⟩
theorem PRE_first_tail_x8_r0_body.cnshift180 (clean : Conv.NClean (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P180.NL) (cl : SSt (· < 7796) PRE_first_tail_x8_r0_body.cx0_180.mlx) : NShift PRE_first_tail_x8_r0_body.P180 7796 PRE_first_tail_x8_r0_body.kappa180 PRE_first_tail_x8_r0_body.cx0_180 PRE_first_tail_x8_r0_body.cx1_180 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot180 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost180 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0180 PRE_first_tail_x8_r0_body.ckn1180 PRE_first_tail_x8_r0_body.ckheap180 PRE_first_tail_x8_r0_body.ckpl180)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_180 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1741.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_180 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1741.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_180 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1741.ffi) = some PRE_first_tail_x8_r0_body.fxC_180
kernel_rfl PRE_first_tail_x8_r0_body.okrC_180 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1741.ffi) = some PRE_first_tail_x8_r0_body.krC_180
noncomputable def PRE_first_tail_x8_r0_body.fx0_180 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1743.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_180 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1743.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_180 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1743.ffi) = some PRE_first_tail_x8_r0_body.fx0_180
kernel_rfl PRE_first_tail_x8_r0_body.okr0_180 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1743.ffi) = some PRE_first_tail_x8_r0_body.kr0_180
noncomputable def PRE_first_tail_x8_r0_body.fx1_180 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1742.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_180 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1742.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_180 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1742.ffi) = some PRE_first_tail_x8_r0_body.fx1_180
kernel_rfl PRE_first_tail_x8_r0_body.okr1_180 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1742.ffi) = some PRE_first_tail_x8_r0_body.kr1_180
kernel_rfl PRE_first_tail_x8_r0_body.ff0180 : PRE_first_tail_x8_r0_body.fx0_180 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_180 (PRE_first_tail_x8_r0_body.clo180.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_180.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1180 : PRE_first_tail_x8_r0_body.fx1_180 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_180 (PRE_first_tail_x8_r0_body.cwS180.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_180.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck180 : freedLB PRE_first_tail_x8_r0_body.kappa180 PRE_first_tail_x8_r0_body.cx0_180.mlx PRE_first_tail_x8_r0_body.fx0_180 PRE_first_tail_x8_r0_body.fx1_180 PRE_first_tail_x8_r0_body.clo180 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0180 : PRE_first_tail_x8_r0_body.kr0_180.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_180.flags (PRE_first_tail_x8_r0_body.clo180.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_180.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0180 : PRE_first_tail_x8_r0_body.kr0_180.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_180.targs (PRE_first_tail_x8_r0_body.clo180.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_180.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1180 : PRE_first_tail_x8_r0_body.kr1_180.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_180.flags (PRE_first_tail_x8_r0_body.cwS180.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_180.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1180 : PRE_first_tail_x8_r0_body.kr1_180.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_180.targs (PRE_first_tail_x8_r0_body.cwS180.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_180.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck180 : krecLB PRE_first_tail_x8_r0_body.kappa180 7796 PRE_first_tail_x8_r0_body.cx0_180.mlx PRE_first_tail_x8_r0_body.kr0_180 PRE_first_tail_x8_r0_body.kr1_180 PRE_first_tail_x8_r0_body.clo180 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn180 : Nat.ble 7778 7796 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge180 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1742.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1743.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR180 : pendRegB PRE_first_tail_x8_r0_body.kappa180 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe180 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1743.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1742.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift180 (clean : Conv.NClean (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P180.NL) (cl : SSt (· < 7796) PRE_first_tail_x8_r0_body.cx0_180.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_180.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_180.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_180.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1741.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_180.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P180 7796 PRE_first_tail_x8_r0_body.kappa180 PRE_first_tail_x8_r0_body.s1743.ffi PRE_first_tail_x8_r0_body.s1742.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift180 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue180, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp180 t ht),
    PRE_first_tail_x8_r0_body.cbridge180,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1743.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1742.ffi) (PRE_first_tail_x8_r0_body.cfoot180 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_180 PRE_first_tail_x8_r0_body.ofx1_180 hobjC PRE_first_tail_x8_r0_body.ff0180 PRE_first_tail_x8_r0_body.ff1180 PRE_first_tail_x8_r0_body.ffck180,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1743.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1742.ffi) (PRE_first_tail_x8_r0_body.cfoot180 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_180 PRE_first_tail_x8_r0_body.okr1_180 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn180) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0180 PRE_first_tail_x8_r0_body.fkt0180 PRE_first_tail_x8_r0_body.fkf1180 PRE_first_tail_x8_r0_body.fkt1180 PRE_first_tail_x8_r0_body.fkck180,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0180 PRE_first_tail_x8_r0_body.cnh1180 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe180) PRE_first_tail_x8_r0_body.cpendR180⟩

end Host.Load.Run.Tpl
end

section -- st180/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st180 0
host_stream_state PRE_first_tail_x8_r0_body.st180 1
host_stream_state PRE_first_tail_x8_r0_body.st180 2
host_stream_state PRE_first_tail_x8_r0_body.st180 3
host_stream_state PRE_first_tail_x8_r0_body.st180 4
host_stream_state PRE_first_tail_x8_r0_body.st180 5
end Host.Load.Run.Tpl
end

section -- Site180
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 180 of chain `PRE_first_tail_x8_r0_body`: `ssmW__g180__g181` (`recurWindow`), the call state `PRE_first_tail_x8_r0_body.s1741`, the merged state `PRE_first_tail_x8_r0_body.s1742`,
the site template `PRE_first_tail_x8_r0_body.st180` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1743`: the merge.
The footprint's facts are in `SiteF180`, the compaction's in `SiteC180`, `SiteK180`, `SiteNa180`, `SiteNb180`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso180 : PRE_first_tail_x8_r0_body.st180.s0 = { PRE_first_tail_x8_r0_body.s1741 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs180 : List Frame := PRE_first_tail_x8_r0_body.s1741.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_180 : PRE_first_tail_x8_r0_body.S1741.tab.length = 7778
kernel_rfl PRE_first_tail_x8_r0_body.tab0_180 : PRE_first_tail_x8_r0_body.st180.S0.tab = PRE_first_tail_x8_r0_body.S1741.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws180 : List Nat := [4027, 4028, 4029, 4030, 4031, 4032, 4033, 4034, 4035, 4036, 4037, 4038, 4039, 4040, 4041, 4042, 4043, 4044, 4045, 4046, 4047, 4048, 4049, 4050, 4051, 4052, 4053, 4054, 4055, 4056, 4057]
kernel_rfl PRE_first_tail_x8_r0_body.fresh180 : (PRE_first_tail_x8_r0_body.S1741.tab.all fun e => PRE_first_tail_x8_r0_body.ws180.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1741.oracle.all fun q => PRE_first_tail_x8_r0_body.ws180.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab180 : PRE_first_tail_x8_r0_body.S1742.tab = PRE_first_tail_x8_r0_body.S1741.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws180
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen180 : PRE_first_tail_x8_r0_body.st180.S5.tab.length - PRE_first_tail_x8_r0_body.st180.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged180`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap180 : PRE_first_tail_x8_r0_body.s1742.heap = PRE_first_tail_x8_r0_body.st180.s5.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext180 : PRE_first_tail_x8_r0_body.s1742.next = PRE_first_tail_x8_r0_body.st180.s5.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl180 : PRE_first_tail_x8_r0_body.s1742.ctl = PRE_first_tail_x8_r0_body.st180.s5.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack180 : PRE_first_tail_x8_r0_body.s1742.stack = PRE_first_tail_x8_r0_body.st180.s5.stack ++ PRE_first_tail_x8_r0_body.s1741.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs180 : PRE_first_tail_x8_r0_body.s1742.jobs = PRE_first_tail_x8_r0_body.st180.s5.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi180 : PRE_first_tail_x8_r0_body.s1742.ffi = PRE_first_tail_x8_r0_body.st180.s5.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace180 : PRE_first_tail_x8_r0_body.s1742.trace = PRE_first_tail_x8_r0_body.st180.s5.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores180 : PRE_first_tail_x8_r0_body.s1742.stores = PRE_first_tail_x8_r0_body.st180.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD180
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 180 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived180 : PRE_first_tail_x8_r0_body.nr180.map (fun r => nth? PRE_first_tail_x8_r0_body.st180.S5.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.un .int32 (SymE.un .int32 (SymE.var 10))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))]
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo180 : PRE_first_tail_x8_r0_body.nr180.all (Nat.ble 7778) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj180 : PRE_first_tail_x8_r0_body.cws180.all (fun c => !PRE_first_tail_x8_r0_body.ws180.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ180 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws180 PRE_first_tail_x8_r0_body.crs180 PRE_first_tail_x8_r0_body.ws180

end Host.Load.Run.Tpl
end

section -- st180/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st180`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st180.wrR : List (Nat × Nat) := [(2672765, 2672766), (2815901, 2815902), (2816446, 2816447), (2816702, 2816703)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st180.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st180.s5.heap PRE_first_tail_x8_r0_body.st180.wrR ++ freshOf PRE_first_tail_x8_r0_body.st180.s5.heap PRE_first_tail_x8_r0_body.st180.s0.next PRE_first_tail_x8_r0_body.st180.s5.next
noncomputable def PRE_first_tail_x8_r0_body.st180.wr : List Nat := PRE_first_tail_x8_r0_body.st180.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st180.heapFoot : PRE_first_tail_x8_r0_body.st180.s5.heap = setAll PRE_first_tail_x8_r0_body.st180.s0.heap PRE_first_tail_x8_r0_body.st180.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st180.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st180.s0.next PRE_first_tail_x8_r0_body.st180.s5.next = true
theorem PRE_first_tail_x8_r0_body.st180.grows : PRE_first_tail_x8_r0_body.st180.s0.next ≤ PRE_first_tail_x8_r0_body.st180.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st180.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st180.wh : List Nat := [21736, 21749, 21755, 21756, 21757, 21758, 21759, 21760, 21761, 21762, 21763, 21764, 21765, 21766, 21767, 21768, 21769, 21770, 21771, 21772, 21773, 21774, 21775, 21776, 21777, 21778, 21779, 21780, 21781, 21782, 21783]
def PRE_first_tail_x8_r0_body.st180.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st180.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st180.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st180.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st180.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st180.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st180.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st180.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st180.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st180.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF180
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 180 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB180 : nodupT PRE_first_tail_x8_r0_body.st180.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup180 : PRE_first_tail_x8_r0_body.st180.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB180).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB180 : PRE_first_tail_x8_r0_body.st180.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound180 : ∀ b ∈ PRE_first_tail_x8_r0_body.st180.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB180 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr180 := PRE_first_tail_x8_r0_body.st180.s5.trace.take 120
kernel_rfl PRE_first_tail_x8_r0_body.traceEq180 : PRE_first_tail_x8_r0_body.st180.s5.trace = PRE_first_tail_x8_r0_body.trFr180 ++ PRE_first_tail_x8_r0_body.st180.s0.trace
theorem PRE_first_tail_x8_r0_body.trace180 : ∃ fr, PRE_first_tail_x8_r0_body.st180.s5.trace = fr ++ PRE_first_tail_x8_r0_body.st180.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq180⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide180 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB180 : (PRE_first_tail_x8_r0_body.wide180.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st180.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix180 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide180, WFix Map.id (Present PRE_first_tail_x8_r0_body.st180.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB180 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL180
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 180 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1742`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO180 : PRE_first_tail_x8_r0_body.st180.S0.oracle = PRE_first_tail_x8_r0_body.st180.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B180 : PRE_first_tail_x8_r0_body.st180.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st180.s0.next || (PRE_first_tail_x8_r0_body.st180.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot180 : Conv.StageFoot PRE_first_tail_x8_r0_body.st180.wr PRE_first_tail_x8_r0_body.st180.s0 PRE_first_tail_x8_r0_body.st180.s5 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st180.heapFoot PRE_first_tail_x8_r0_body.wrNodup180 PRE_first_tail_x8_r0_body.wrBound180 PRE_first_tail_x8_r0_body.wr0B180 PRE_first_tail_x8_r0_body.st180.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged180 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st180.F.S → PRE_first_tail_x8_r0_body.st180.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st180.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st180.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs180 PRE_first_tail_x8_r0_body.st180.wr PRE_first_tail_x8_r0_body.s1741 PRE_first_tail_x8_r0_body.st180.s5 PRE_first_tail_x8_r0_body.st180.s0
      PRE_first_tail_x8_r0_body.st180.s5.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st180.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1742 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso180 PRE_first_tail_x8_r0_body.stFoot180 PRE_first_tail_x8_r0_body.wrNodup180 PRE_first_tail_x8_r0_body.wrBound180 PRE_first_tail_x8_r0_body.trace180 PRE_first_tail_x8_r0_body.mheap180
    PRE_first_tail_x8_r0_body.mnext180 PRE_first_tail_x8_r0_body.mctl180 PRE_first_tail_x8_r0_body.mstack180 PRE_first_tail_x8_r0_body.mjobs180 PRE_first_tail_x8_r0_body.mffi180 PRE_first_tail_x8_r0_body.mtrace180 PRE_first_tail_x8_r0_body.mstores180 h

def PRE_first_tail_x8_r0_body.arrEl180_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE180_2665 : arrOf PRE_first_tail_x8_r0_body.s1742 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl180_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA180_2665 : isArrB PRE_first_tail_x8_r0_body.s1742 2665 = true
theorem PRE_first_tail_x8_r0_body.arr180_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1742.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl180_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE180_2665 PRE_first_tail_x8_r0_body.arrA180_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN180_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl180_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR180_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl180_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN180_2665

def PRE_first_tail_x8_r0_body.arrEl180_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE180_2673467 : arrOf PRE_first_tail_x8_r0_body.s1742 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl180_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA180_2673467 : isArrB PRE_first_tail_x8_r0_body.s1742 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr180_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1742.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl180_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE180_2673467 PRE_first_tail_x8_r0_body.arrA180_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN180_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl180_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR180_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl180_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN180_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k180 : isArrB PRE_first_tail_x8_r0_body.s1742 4910 = false
theorem PRE_first_tail_x8_r0_body.keep180 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1742 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k180 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr180_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl180_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ180
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 180 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1741`, the merged
state `PRE_first_tail_x8_r0_body.s1742`, the canonical state `PRE_first_tail_x8_r0_body.s1743`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl180 : PRE_first_tail_x8_r0_body.pl180.all (Nat.ble PRE_first_tail_x8_r0_body.s1741.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd180 : nodupT PRE_first_tail_x8_r0_body.pl180 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1180 : Nat.ble PRE_first_tail_x8_r0_body.s1741.next 2817882 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst180 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1741.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn180 : PRE_first_tail_x8_r0_body.s1743.next = PRE_first_tail_x8_r0_body.s1741.next + PRE_first_tail_x8_r0_body.pl180.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn180 : PRE_first_tail_x8_r0_body.s1742.next = 2817882
kernel_rfl PRE_first_tail_x8_r0_body.zgrow180 : Nat.ble PRE_first_tail_x8_r0_body.s1743.next PRE_first_tail_x8_r0_body.s1742.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh180 : PRE_first_tail_x8_r0_body.S1741.tab.all (fun e => PRE_first_tail_x8_r0_body.cws180.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd180 : nodupT PRE_first_tail_x8_r0_body.cws180 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi180 : PRE_first_tail_x8_r0_body.nr180.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1742.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt180 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1741.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg180_2665 : PRE_first_tail_x8_r0_body.s1743.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1743 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk180_2665 : (objOf PRE_first_tail_x8_r0_body.s1743 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm180_2665 : PRE_first_tail_x8_r0_body.s1742.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa180.obj (objOf PRE_first_tail_x8_r0_body.s1743 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1742 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg180_2673467 : PRE_first_tail_x8_r0_body.s1743.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1743 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk180_2673467 : (objOf PRE_first_tail_x8_r0_body.s1743 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm180_2673467 : PRE_first_tail_x8_r0_body.s1742.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa180.obj (objOf PRE_first_tail_x8_r0_body.s1743 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1742 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw180_4910 : (PRE_first_tail_x8_r0_body.s1743.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw180_2673472 : (PRE_first_tail_x8_r0_body.s1743.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw180_2673473 : (PRE_first_tail_x8_r0_body.s1743.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd180 : PRE_first_tail_x8_r0_body.cl180.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr180 : PRE_first_tail_x8_r0_body.st180.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1741.next || PRE_first_tail_x8_r0_body.cl180.contains b) = true
def PRE_first_tail_x8_r0_body.zl180 : List Nat := PRE_first_tail_x8_r0_body.cl180.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE180 : PRE_first_tail_x8_r0_body.zl180.map (fun a => PRE_first_tail_x8_r0_body.s1742.heap.get (PRE_first_tail_x8_r0_body.kappa180.a a)) = PRE_first_tail_x8_r0_body.zl180.map (fun a => (PRE_first_tail_x8_r0_body.s1743.heap.get a).map PRE_first_tail_x8_r0_body.kappa180.hobj)
theorem PRE_first_tail_x8_r0_body.zimg180 : HeapImg PRE_first_tail_x8_r0_body.kappa180 PRE_first_tail_x8_r0_body.s1743 PRE_first_tail_x8_r0_body.s1742 PRE_first_tail_x8_r0_body.zl180 := PRE_first_tail_x8_r0_body.zimgE180
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl180 : PRE_first_tail_x8_r0_body.s1742.ctl = PRE_first_tail_x8_r0_body.kappa180.ctl PRE_first_tail_x8_r0_body.s1743.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack180 : PRE_first_tail_x8_r0_body.s1742.stack = PRE_first_tail_x8_r0_body.s1743.stack.map PRE_first_tail_x8_r0_body.kappa180.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs180 : PRE_first_tail_x8_r0_body.s1742.jobs = PRE_first_tail_x8_r0_body.s1743.jobs.map PRE_first_tail_x8_r0_body.kappa180.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores180 : PRE_first_tail_x8_r0_body.s1742.stores = PRE_first_tail_x8_r0_body.kappa180.stores PRE_first_tail_x8_r0_body.s1743.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots180 : checkRootsSupp PRE_first_tail_x8_r0_body.s1743 7796 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC180 : PRE_first_tail_x8_r0_body.S1741.tab.length + PRE_first_tail_x8_r0_body.cws180.length = 7796
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap180 : PRE_first_tail_x8_r0_body.kappa180 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1741.next 2817882 PRE_first_tail_x8_r0_body.S1741.tab.length PRE_first_tail_x8_r0_body.pl180 (PRE_first_tail_x8_r0_body.nr180.map NumV.ref) PRE_first_tail_x8_r0_body.kd180.big
  PRE_first_tail_x8_r0_body.kd180.region PRE_first_tail_x8_r0_body.kd180.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin180 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1743.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc180 : Conv.jcleanListB (⟨21759, 18860, 2816733, 7796⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1743 PRE_first_tail_x8_r0_body.cl180 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB180 : noBigRootsP (fun i => !Conv.oldBigB (⟨21759, 18860, 2816733, 7796⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1743.trace PRE_first_tail_x8_r0_body.s1743 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm180 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18833 = true
theorem PRE_first_tail_x8_r0_body.cjcl180 (h : Conv.JClean (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1741) : Conv.JClean (⟨21759, 18860, 2816733, 7796⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1743 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle180)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap180 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd180 a ha)) PRE_first_tail_x8_r0_body.zjc180

end Host.Load.Run.Tpl
end

section -- st180/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st180.bodyLast from PRE_first_tail_x8_r0_body.st180.s4 to PRE_first_tail_x8_r0_body.st180.s5 :
  interpS (step PRE_first_tail_x8_r0_body.st180.F PRE_first_tail_x8_r0_body.st180.s4).run PRE_first_tail_x8_r0_body.st180.S4 = some (PRE_first_tail_x8_r0_body.st180.s5, PRE_first_tail_x8_r0_body.st180.S5)
kernel_rfl PRE_first_tail_x8_r0_body.st180.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st180.s4.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st180.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st180.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st180/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st180.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st180.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st180.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st180.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st180.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st180.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st180.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st180.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st180.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st180.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st180.s0 PRE_first_tail_x8_r0_body.st180.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st180.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st180.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st180.s4 PRE_first_tail_x8_r0_body.st180.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st180/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st180.bodyK0F from PRE_first_tail_x8_r0_body.st180.s0 to PRE_first_tail_x8_r0_body.st180.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st180.F (PRE_first_tail_x8_r0_body.st180.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st180.ks 0).getD 0) PRE_first_tail_x8_r0_body.st180.s0 PRE_first_tail_x8_r0_body.st180.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st180.s1, PRE_first_tail_x8_r0_body.st180.S1)
theorem PRE_first_tail_x8_r0_body.st180.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st180.F (PRE_first_tail_x8_r0_body.st180.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st180.ks 0).getD 0) PRE_first_tail_x8_r0_body.st180.s0 PRE_first_tail_x8_r0_body.st180.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st180.s1, PRE_first_tail_x8_r0_body.st180.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st180.bodyOkLN_ok PRE_first_tail_x8_r0_body.st180.bodyK0F
end Host.Load.Run.Tpl
end

section -- st180/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st180.bodyK1F from PRE_first_tail_x8_r0_body.st180.s1 to PRE_first_tail_x8_r0_body.st180.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st180.F (PRE_first_tail_x8_r0_body.st180.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st180.ks 1).getD 0) PRE_first_tail_x8_r0_body.st180.s1 PRE_first_tail_x8_r0_body.st180.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st180.s2, PRE_first_tail_x8_r0_body.st180.S2)
theorem PRE_first_tail_x8_r0_body.st180.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st180.F (PRE_first_tail_x8_r0_body.st180.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st180.ks 1).getD 0) PRE_first_tail_x8_r0_body.st180.s1 PRE_first_tail_x8_r0_body.st180.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st180.s2, PRE_first_tail_x8_r0_body.st180.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st180.bodyOkLN_ok PRE_first_tail_x8_r0_body.st180.bodyK1F
end Host.Load.Run.Tpl
end

section -- st180/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st180.bodyK2F from PRE_first_tail_x8_r0_body.st180.s2 to PRE_first_tail_x8_r0_body.st180.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st180.F (PRE_first_tail_x8_r0_body.st180.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st180.ks 2).getD 0) PRE_first_tail_x8_r0_body.st180.s2 PRE_first_tail_x8_r0_body.st180.S2) = fun _ _ => some (PRE_first_tail_x8_r0_body.st180.s3, PRE_first_tail_x8_r0_body.st180.S3)
theorem PRE_first_tail_x8_r0_body.st180.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st180.F (PRE_first_tail_x8_r0_body.st180.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st180.ks 2).getD 0) PRE_first_tail_x8_r0_body.st180.s2 PRE_first_tail_x8_r0_body.st180.S2) = fun _ _ => some (PRE_first_tail_x8_r0_body.st180.s3, PRE_first_tail_x8_r0_body.st180.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st180.bodyOkLN_ok PRE_first_tail_x8_r0_body.st180.bodyK2F
end Host.Load.Run.Tpl
end

section -- st180/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st180.bodyK3F from PRE_first_tail_x8_r0_body.st180.s3 to PRE_first_tail_x8_r0_body.st180.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st180.F (PRE_first_tail_x8_r0_body.st180.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st180.ks 3).getD 0) PRE_first_tail_x8_r0_body.st180.s3 PRE_first_tail_x8_r0_body.st180.S3) = fun _ _ => some (PRE_first_tail_x8_r0_body.st180.s4, PRE_first_tail_x8_r0_body.st180.S4)
theorem PRE_first_tail_x8_r0_body.st180.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st180.F (PRE_first_tail_x8_r0_body.st180.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st180.ks 3).getD 0) PRE_first_tail_x8_r0_body.st180.s3 PRE_first_tail_x8_r0_body.st180.S3) = fun _ _ => some (PRE_first_tail_x8_r0_body.st180.s4, PRE_first_tail_x8_r0_body.st180.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st180.bodyOkLN_ok PRE_first_tail_x8_r0_body.st180.bodyK3F
end Host.Load.Run.Tpl
end

section -- st180/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st180.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st180.F (PRE_first_tail_x8_r0_body.st180.bodyOkL bytes rows) 11334 PRE_first_tail_x8_r0_body.st180.s0 PRE_first_tail_x8_r0_body.st180.S0 = some (PRE_first_tail_x8_r0_body.st180.s4, PRE_first_tail_x8_r0_body.st180.S4) :=
  runOk_trans PRE_first_tail_x8_r0_body.st180.F (PRE_first_tail_x8_r0_body.st180.bodyOkL bytes rows) ((((nth? PRE_first_tail_x8_r0_body.st180.ks 0).getD 0) + ((nth? PRE_first_tail_x8_r0_body.st180.ks 1).getD 0)) + ((nth? PRE_first_tail_x8_r0_body.st180.ks 2).getD 0)) ((nth? PRE_first_tail_x8_r0_body.st180.ks 3).getD 0) PRE_first_tail_x8_r0_body.st180.s0 PRE_first_tail_x8_r0_body.st180.s3 PRE_first_tail_x8_r0_body.st180.s4 PRE_first_tail_x8_r0_body.st180.S0 PRE_first_tail_x8_r0_body.st180.S3 PRE_first_tail_x8_r0_body.st180.S4 (runOk_trans PRE_first_tail_x8_r0_body.st180.F (PRE_first_tail_x8_r0_body.st180.bodyOkL bytes rows) (((nth? PRE_first_tail_x8_r0_body.st180.ks 0).getD 0) + ((nth? PRE_first_tail_x8_r0_body.st180.ks 1).getD 0)) ((nth? PRE_first_tail_x8_r0_body.st180.ks 2).getD 0) PRE_first_tail_x8_r0_body.st180.s0 PRE_first_tail_x8_r0_body.st180.s2 PRE_first_tail_x8_r0_body.st180.s3 PRE_first_tail_x8_r0_body.st180.S0 PRE_first_tail_x8_r0_body.st180.S2 PRE_first_tail_x8_r0_body.st180.S3 (runOk_trans PRE_first_tail_x8_r0_body.st180.F (PRE_first_tail_x8_r0_body.st180.bodyOkL bytes rows) ((nth? PRE_first_tail_x8_r0_body.st180.ks 0).getD 0) ((nth? PRE_first_tail_x8_r0_body.st180.ks 1).getD 0) PRE_first_tail_x8_r0_body.st180.s0 PRE_first_tail_x8_r0_body.st180.s1 PRE_first_tail_x8_r0_body.st180.s2 PRE_first_tail_x8_r0_body.st180.S0 PRE_first_tail_x8_r0_body.st180.S1 PRE_first_tail_x8_r0_body.st180.S2 ((congrFun (congrFun PRE_first_tail_x8_r0_body.st180.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st180.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st180.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st180.bodyK3 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st180.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st180.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st180.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st180.F (PRE_first_tail_x8_r0_body.st180.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st180.s0
  S0 := PRE_first_tail_x8_r0_body.st180.S0
  s1 := PRE_first_tail_x8_r0_body.st180.s4
  S1 := PRE_first_tail_x8_r0_body.st180.S4
  s2 := PRE_first_tail_x8_r0_body.st180.s5
  S2 := PRE_first_tail_x8_r0_body.st180.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st180.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st180.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st180.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st180.bodyHalt
  last := PRE_first_tail_x8_r0_body.st180.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st180.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC181
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 181 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1751` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa181` into the merged state
`PRE_first_tail_x8_r0_body.s1750`. -/

def PRE_first_tail_x8_r0_body.pl181 : List Nat := []
def PRE_first_tail_x8_r0_body.nr181 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd181 : RData :=
  ⟨2817223, 2817225, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21772, 21772, 18873, 18873, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa181 : Map :=
  Conv.Map.compact 2817223 2817225 7817 PRE_first_tail_x8_r0_body.pl181 (PRE_first_tail_x8_r0_body.nr181.map NumV.ref) PRE_first_tail_x8_r0_body.kd181.big
    PRE_first_tail_x8_r0_body.kd181.region PRE_first_tail_x8_r0_body.kd181.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws181 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs181 : List SymE := PRE_first_tail_x8_r0_body.nr181.map fun r => (nth? PRE_first_tail_x8_r0_body.S1750.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta181 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws181 PRE_first_tail_x8_r0_body.crs181
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB181 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab181 : PRE_first_tail_x8_r0_body.S1751.tab = PRE_first_tail_x8_r0_body.S1749.tab ++ PRE_first_tail_x8_r0_body.cws181.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace181 : PRE_first_tail_x8_r0_body.s1751.trace = PRE_first_tail_x8_r0_body.s1749.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext181 : PRE_first_tail_x8_r0_body.s1751.next = 2817223
kernel_rfl PRE_first_tail_x8_r0_body.ccounters181 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx.nnext) = (21772, 18873)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue181 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1750.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa181.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp181 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx.tokens.all (bSN 7817) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean181 : Conv.cleanListB 21772 131072 (fun r => Nat.ble 87088 r) PRE_first_tail_x8_r0_body.s1751
    (PRE_first_tail_x8_r0_body.wrB181 ++ (List.range 0).map (2817223 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs181 : bigsOutB 21772 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK181
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl181`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl181 : List Nat := [2665, 2673467]
def PRE_first_tail_x8_r0_body.clo181 : List Nat := []
def PRE_first_tail_x8_r0_body.cln181 : List Nat := []
def PRE_first_tail_x8_r0_body.cli181 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap181 : PRE_first_tail_x8_r0_body.s1751.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1749.heap (PRE_first_tail_x8_r0_body.cl181.filterMap fun a => (PRE_first_tail_x8_r0_body.s1751.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe181 : Nat.ble PRE_first_tail_x8_r0_body.s1749.next PRE_first_tail_x8_r0_body.s1751.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP181 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1749 PRE_first_tail_x8_r0_body.s1751 PRE_first_tail_x8_r0_body.cl181 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp181 : Conv.suppListB PRE_first_tail_x8_r0_body.s1751 7817 PRE_first_tail_x8_r0_body.cl181 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound181 : Conv.boundListB PRE_first_tail_x8_r0_body.s1751 PRE_first_tail_x8_r0_body.cl181 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK181 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln181.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK181 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo181.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK181 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli181.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst181 : Conv.sstListB 7817 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx PRE_first_tail_x8_r0_body.cln181 PRE_first_tail_x8_r0_body.clo181 PRE_first_tail_x8_r0_body.cli181 = true

end Host.Load.Run.Tpl
end

section -- SiteCl181
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA181 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo181.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd181 : (PRE_first_tail_x8_r0_body.clo181 ++ PRE_first_tail_x8_r0_body.cln181 ++ PRE_first_tail_x8_r0_body.cli181).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle181 : Conv.Cnt.leB (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck181 : Conv.ncleanListB (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx PRE_first_tail_x8_r0_body.clo181 PRE_first_tail_x8_r0_body.cln181 PRE_first_tail_x8_r0_body.cli181 = true
theorem PRE_first_tail_x8_r0_body.cncl181 (h : Conv.NClean (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx) : Conv.NClean (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle181 PRE_first_tail_x8_r0_body.ckA181 PRE_first_tail_x8_r0_body.cobjsK181 PRE_first_tail_x8_r0_body.cnodesK181 PRE_first_tail_x8_r0_body.citemsK181 PRE_first_tail_x8_r0_body.cbd181 PRE_first_tail_x8_r0_body.cck181

end Host.Load.Run.Tpl
end

section -- SiteS181
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 181 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc181 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P181 : LoadP := PRE_first_tail_x8_r0_body.Pc181.raise 18873
kernel_rfl PRE_first_tail_x8_r0_body.craise181 : Nat.ble PRE_first_tail_x8_r0_body.Pc181.N0 18873 = true
theorem PRE_first_tail_x8_r0_body.raised181 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc181 PRE_first_tail_x8_r0_body.P181 :=
  .inr ⟨18873, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise181, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_181 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_181 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1750.ffi)
def PRE_first_tail_x8_r0_body.khinv181 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv181 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS181 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS181 : List Nat := List.range' 18873 0
def PRE_first_tail_x8_r0_body.ciS181 : List Nat := [] ++ List.range' 18873 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0181 : PRE_first_tail_x8_r0_body.kd181.nh0 = PRE_first_tail_x8_r0_body.cx0_181.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1181 : PRE_first_tail_x8_r0_body.kd181.nh1 = PRE_first_tail_x8_r0_body.cx1_181.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0181 : PRE_first_tail_x8_r0_body.kd181.nn0 = PRE_first_tail_x8_r0_body.cx0_181.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1181 : PRE_first_tail_x8_r0_body.kd181.nn1 = PRE_first_tail_x8_r0_body.cx1_181.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo181 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P181.lo && Nat.ble PRE_first_tail_x8_r0_body.P181.lo PRE_first_tail_x8_r0_body.cx0_181.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P181.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P181.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt181 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_181.mlx.next PRE_first_tail_x8_r0_body.cx1_181.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_181.mlx.nnext PRE_first_tail_x8_r0_body.cx1_181.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband181 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P181.NL && Nat.ble PRE_first_tail_x8_r0_body.P181.NL PRE_first_tail_x8_r0_body.P181.N0 && Nat.ble PRE_first_tail_x8_r0_body.P181.N0 PRE_first_tail_x8_r0_body.cx0_181.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow181 : PRE_first_tail_x8_r0_body.kd181.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren181 : checkRenG PRE_first_tail_x8_r0_body.kd181.hnd PRE_first_tail_x8_r0_body.khinv181 (phB PRE_first_tail_x8_r0_body.cx0_181.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband181 : PRE_first_tail_x8_r0_body.kd181.checkBand PRE_first_tail_x8_r0_body.P181.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos181 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd181.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren181 : checkRenG PRE_first_tail_x8_r0_body.kd181.node PRE_first_tail_x8_r0_body.kninv181 (pnB PRE_first_tail_x8_r0_body.cx0_181.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow181 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd181.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P181.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd181.nodeF j) PRE_first_tail_x8_r0_body.cx1_181.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a181 : PRE_first_tail_x8_r0_body.cx0_181.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b181 : PRE_first_tail_x8_r0_body.cx0_181.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1181 : PRE_first_tail_x8_r0_body.cx1_181.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend181 : PRE_first_tail_x8_r0_body.cx1_181.mlx.pending = PRE_first_tail_x8_r0_body.cx0_181.mlx.pending.map PRE_first_tail_x8_r0_body.kappa181.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh181 : PRE_first_tail_x8_r0_body.cx1_181.mlx.errh = PRE_first_tail_x8_r0_body.cx0_181.mlx.errh.map PRE_first_tail_x8_r0_body.kappa181.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles181 : PRE_first_tail_x8_r0_body.cx1_181.mlx.files = PRE_first_tail_x8_r0_body.cx0_181.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch181 : PRE_first_tail_x8_r0_body.cx1_181.mlx.arch = PRE_first_tail_x8_r0_body.cx0_181.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes181 : PRE_first_tail_x8_r0_body.cx1_181.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_181.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired181 : PRE_first_tail_x8_r0_body.cx1_181.mlx.wired = PRE_first_tail_x8_r0_body.cx0_181.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost181 : PRE_first_tail_x8_r0_body.cx1_181.host = PRE_first_tail_x8_r0_body.cx0_181.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd181`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0181 : PRE_first_tail_x8_r0_body.kd181.n0 = 2817223
kernel_rfl PRE_first_tail_x8_r0_body.ckn1181 : PRE_first_tail_x8_r0_body.kd181.n1 = 2817225
kernel_rfl PRE_first_tail_x8_r0_body.ckheap181 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd181.heap).all (fun x => Nat.ble 2817223 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl181 : (List.range 0).all (fun j => decide (PRE_first_tail_x8_r0_body.kd181.heap.get (2817223 + j) = nth? PRE_first_tail_x8_r0_body.pl181 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja181 : Nat.ble 2817223 2817223 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn181 : Nat.ble 7817 7817 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD181 : Nat.ble 2817223 PRE_first_tail_x8_r0_body.kd181.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn181 : Nat.ble 21772 PRE_first_tail_x8_r0_body.kd181.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn181 : Nat.ble 18873 PRE_first_tail_x8_r0_body.kd181.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb181 : Nat.ble 21772 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap181 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd181.heap).all (Nat.ble (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd181 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd181.hnd).all (Nat.ble (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode181 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd181.node).all (Nat.ble (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix181 : Conv.FixOld (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa181 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja181) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn181) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD181) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn181) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn181) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb181) PRE_first_tail_x8_r0_body.fheap181 PRE_first_tail_x8_r0_body.fhnd181 PRE_first_tail_x8_r0_body.fnode181
kernel_rfl PRE_first_tail_x8_r0_body.fcxn181 : (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn181 : (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0181 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_181.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_181.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk181 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd181.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A181 : PRE_first_tail_x8_r0_body.cx1_181.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS181.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_181.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O181 : PRE_first_tail_x8_r0_body.cx1_181.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS181.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_181.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N181 : PRE_first_tail_x8_r0_body.cx1_181.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS181.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_181.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I181 : PRE_first_tail_x8_r0_body.cx1_181.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS181.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_181.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd181 : (PRE_first_tail_x8_r0_body.clo181 ++ PRE_first_tail_x8_r0_body.cln181 ++ PRE_first_tail_x8_r0_body.cli181 ++ PRE_first_tail_x8_r0_body.cwS181 ++ PRE_first_tail_x8_r0_body.cnS181 ++ PRE_first_tail_x8_r0_body.ciS181).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW181 : PRE_first_tail_x8_r0_body.cwS181.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo181.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI181 : PRE_first_tail_x8_r0_body.ciS181.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli181.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN181 : PRE_first_tail_x8_r0_body.cnS181.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF181 : PRE_first_tail_x8_r0_body.cln181.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh181 : PRE_first_tail_x8_r0_body.clo181.all (handleOK PRE_first_tail_x8_r0_body.kappa181 PRE_first_tail_x8_r0_body.P181.lo PRE_first_tail_x8_r0_body.cx0_181.mlx PRE_first_tail_x8_r0_body.cx1_181.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo181 : PRE_first_tail_x8_r0_body.clo181.map (fun h => PRE_first_tail_x8_r0_body.cx1_181.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa181.handle h)) = PRE_first_tail_x8_r0_body.clo181.map (fun h => (PRE_first_tail_x8_r0_body.cx0_181.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa181.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok181 : PRE_first_tail_x8_r0_body.clo181.all (objOK PRE_first_tail_x8_r0_body.kappa181 PRE_first_tail_x8_r0_body.P181.NL PRE_first_tail_x8_r0_body.cx0_181.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd181 : PRE_first_tail_x8_r0_body.cln181.all (nodeOKF PRE_first_tail_x8_r0_body.kappa181 PRE_first_tail_x8_r0_body.P181 PRE_first_tail_x8_r0_body.cx0_181.mlx PRE_first_tail_x8_r0_body.cx1_181.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp181 : ((PRE_first_tail_x8_r0_body.cln181.filter (fullB PRE_first_tail_x8_r0_body.P181))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_181.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa181.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln181.filter (fullB PRE_first_tail_x8_r0_body.P181))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_181.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa181.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI181 : incrB PRE_first_tail_x8_r0_body.kd181.nodeF (List.range' 18873 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK181 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd181.node).all (fun k => Nat.ble 18873 k && Nat.blt k 18873) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL181 : (PRE_first_tail_x8_r0_body.cln181.filter (Nat.ble PRE_first_tail_x8_r0_body.P181.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd181.nodeF i) && (Nat.blt i 18873 || Nat.ble PRE_first_tail_x8_r0_body.kd181.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord181 : (PRE_first_tail_x8_r0_body.cln181.filter (Nat.ble PRE_first_tail_x8_r0_body.P181.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd181.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd181.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd181.nodeF j) (PRE_first_tail_x8_r0_body.kd181.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow181 PRE_first_tail_x8_r0_body.cnn1181 PRE_first_tail_x8_r0_body.fnordI181 PRE_first_tail_x8_r0_body.fnordK181 PRE_first_tail_x8_r0_body.fnordL181
kernel_rfl PRE_first_tail_x8_r0_body.fi181 : PRE_first_tail_x8_r0_body.cli181.all (pnB PRE_first_tail_x8_r0_body.cx0_181.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii181 : PRE_first_tail_x8_r0_body.cli181.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_181.mlx.items.get (PRE_first_tail_x8_r0_body.kappa181.node k) = (PRE_first_tail_x8_r0_body.cx0_181.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa181.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot181 (clean : Conv.NClean (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P181.NL) (cl : SSt (· < 7817) PRE_first_tail_x8_r0_body.cx0_181.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P181 7817 PRE_first_tail_x8_r0_body.kappa181 PRE_first_tail_x8_r0_body.kd181 PRE_first_tail_x8_r0_body.khinv181 PRE_first_tail_x8_r0_body.kninv181 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx PRE_first_tail_x8_r0_body.cx0_181.mlx PRE_first_tail_x8_r0_body.cx1_181.mlx (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo181 PRE_first_tail_x8_r0_body.cln181 PRE_first_tail_x8_r0_body.cli181 PRE_first_tail_x8_r0_body.cwS181 PRE_first_tail_x8_r0_body.cnS181 PRE_first_tail_x8_r0_body.ciS181 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0181, PRE_first_tail_x8_r0_body.cnh1181, PRE_first_tail_x8_r0_body.cnn0181, PRE_first_tail_x8_r0_body.cnn1181, PRE_first_tail_x8_r0_body.cplo181, PRE_first_tail_x8_r0_body.ccnt181, PRE_first_tail_x8_r0_body.cnband181, PRE_first_tail_x8_r0_body.chbelow181, PRE_first_tail_x8_r0_body.chren181, PRE_first_tail_x8_r0_body.cband181, PRE_first_tail_x8_r0_body.cnh1pos181, PRE_first_tail_x8_r0_body.cnren181, PRE_first_tail_x8_r0_body.cnlow181, PRE_first_tail_x8_r0_body.cabs0a181, PRE_first_tail_x8_r0_body.cabs0b181, PRE_first_tail_x8_r0_body.ctok1181, PRE_first_tail_x8_r0_body.cpend181, PRE_first_tail_x8_r0_body.cerrh181, PRE_first_tail_x8_r0_body.cfiles181, PRE_first_tail_x8_r0_body.carch181, PRE_first_tail_x8_r0_body.csizes181, PRE_first_tail_x8_r0_body.cwired181, PRE_first_tail_x8_r0_body.cfix181, clean, PRE_first_tail_x8_r0_body.fcxn181, PRE_first_tail_x8_r0_body.fcnn181, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0181, PRE_first_tail_x8_r0_body.fnk181, PRE_first_tail_x8_r0_body.ckA181, PRE_first_tail_x8_r0_body.cobjsK181, PRE_first_tail_x8_r0_body.cnodesK181, PRE_first_tail_x8_r0_body.citemsK181, PRE_first_tail_x8_r0_body.f1A181, PRE_first_tail_x8_r0_body.f1O181, PRE_first_tail_x8_r0_body.f1N181, PRE_first_tail_x8_r0_body.f1I181, PRE_first_tail_x8_r0_body.fbd181, PRE_first_tail_x8_r0_body.fincW181, PRE_first_tail_x8_r0_body.fincI181, PRE_first_tail_x8_r0_body.fincN181, PRE_first_tail_x8_r0_body.flnF181, PRE_first_tail_x8_r0_body.fh181, PRE_first_tail_x8_r0_body.fo181, PRE_first_tail_x8_r0_body.fok181, PRE_first_tail_x8_r0_body.fnd181, PRE_first_tail_x8_r0_body.fp181, PRE_first_tail_x8_r0_body.fnord181, PRE_first_tail_x8_r0_body.fi181, PRE_first_tail_x8_r0_body.fii181⟩
theorem PRE_first_tail_x8_r0_body.cnshift181 (clean : Conv.NClean (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P181.NL) (cl : SSt (· < 7817) PRE_first_tail_x8_r0_body.cx0_181.mlx) : NShift PRE_first_tail_x8_r0_body.P181 7817 PRE_first_tail_x8_r0_body.kappa181 PRE_first_tail_x8_r0_body.cx0_181 PRE_first_tail_x8_r0_body.cx1_181 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot181 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost181 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0181 PRE_first_tail_x8_r0_body.ckn1181 PRE_first_tail_x8_r0_body.ckheap181 PRE_first_tail_x8_r0_body.ckpl181)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_181 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1749.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_181 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1749.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_181 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1749.ffi) = some PRE_first_tail_x8_r0_body.fxC_181
kernel_rfl PRE_first_tail_x8_r0_body.okrC_181 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1749.ffi) = some PRE_first_tail_x8_r0_body.krC_181
noncomputable def PRE_first_tail_x8_r0_body.fx0_181 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1751.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_181 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1751.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_181 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1751.ffi) = some PRE_first_tail_x8_r0_body.fx0_181
kernel_rfl PRE_first_tail_x8_r0_body.okr0_181 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1751.ffi) = some PRE_first_tail_x8_r0_body.kr0_181
noncomputable def PRE_first_tail_x8_r0_body.fx1_181 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1750.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_181 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1750.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_181 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1750.ffi) = some PRE_first_tail_x8_r0_body.fx1_181
kernel_rfl PRE_first_tail_x8_r0_body.okr1_181 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1750.ffi) = some PRE_first_tail_x8_r0_body.kr1_181
kernel_rfl PRE_first_tail_x8_r0_body.ff0181 : PRE_first_tail_x8_r0_body.fx0_181 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_181 (PRE_first_tail_x8_r0_body.clo181.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_181.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1181 : PRE_first_tail_x8_r0_body.fx1_181 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_181 (PRE_first_tail_x8_r0_body.cwS181.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_181.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck181 : freedLB PRE_first_tail_x8_r0_body.kappa181 PRE_first_tail_x8_r0_body.cx0_181.mlx PRE_first_tail_x8_r0_body.fx0_181 PRE_first_tail_x8_r0_body.fx1_181 PRE_first_tail_x8_r0_body.clo181 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0181 : PRE_first_tail_x8_r0_body.kr0_181.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_181.flags (PRE_first_tail_x8_r0_body.clo181.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_181.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0181 : PRE_first_tail_x8_r0_body.kr0_181.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_181.targs (PRE_first_tail_x8_r0_body.clo181.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_181.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1181 : PRE_first_tail_x8_r0_body.kr1_181.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_181.flags (PRE_first_tail_x8_r0_body.cwS181.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_181.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1181 : PRE_first_tail_x8_r0_body.kr1_181.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_181.targs (PRE_first_tail_x8_r0_body.cwS181.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_181.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck181 : krecLB PRE_first_tail_x8_r0_body.kappa181 7817 PRE_first_tail_x8_r0_body.cx0_181.mlx PRE_first_tail_x8_r0_body.kr0_181 PRE_first_tail_x8_r0_body.kr1_181 PRE_first_tail_x8_r0_body.clo181 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn181 : Nat.ble 7817 7817 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge181 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1750.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1751.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR181 : pendRegB PRE_first_tail_x8_r0_body.kappa181 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe181 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1751.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1750.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift181 (clean : Conv.NClean (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P181.NL) (cl : SSt (· < 7817) PRE_first_tail_x8_r0_body.cx0_181.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_181.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_181.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_181.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1749.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_181.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P181 7817 PRE_first_tail_x8_r0_body.kappa181 PRE_first_tail_x8_r0_body.s1751.ffi PRE_first_tail_x8_r0_body.s1750.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift181 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue181, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp181 t ht),
    PRE_first_tail_x8_r0_body.cbridge181,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1751.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1750.ffi) (PRE_first_tail_x8_r0_body.cfoot181 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_181 PRE_first_tail_x8_r0_body.ofx1_181 hobjC PRE_first_tail_x8_r0_body.ff0181 PRE_first_tail_x8_r0_body.ff1181 PRE_first_tail_x8_r0_body.ffck181,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1751.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1750.ffi) (PRE_first_tail_x8_r0_body.cfoot181 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_181 PRE_first_tail_x8_r0_body.okr1_181 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn181) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0181 PRE_first_tail_x8_r0_body.fkt0181 PRE_first_tail_x8_r0_body.fkf1181 PRE_first_tail_x8_r0_body.fkt1181 PRE_first_tail_x8_r0_body.fkck181,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0181 PRE_first_tail_x8_r0_body.cnh1181 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe181) PRE_first_tail_x8_r0_body.cpendR181⟩

end Host.Load.Run.Tpl
end

section -- st181/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st181 0
host_stream_state PRE_first_tail_x8_r0_body.st181 1
host_stream_state PRE_first_tail_x8_r0_body.st181 2
end Host.Load.Run.Tpl
end

section -- Site181
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 181 of chain `PRE_first_tail_x8_r0_body`: `rowBlocks__g181__g182` (`rowBlocks`), the call state `PRE_first_tail_x8_r0_body.s1749`, the merged state `PRE_first_tail_x8_r0_body.s1750`,
the site template `PRE_first_tail_x8_r0_body.st181` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1751`: the merge.
The footprint's facts are in `SiteF181`, the compaction's in `SiteC181`, `SiteK181`, `SiteNa181`, `SiteNb181`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso181 : PRE_first_tail_x8_r0_body.st181.s0 = { PRE_first_tail_x8_r0_body.s1749 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs181 : List Frame := PRE_first_tail_x8_r0_body.s1749.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_181 : PRE_first_tail_x8_r0_body.S1749.tab.length = 7817
kernel_rfl PRE_first_tail_x8_r0_body.tab0_181 : PRE_first_tail_x8_r0_body.st181.S0.tab = PRE_first_tail_x8_r0_body.S1749.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws181 : List Nat := [4076, 4077]
kernel_rfl PRE_first_tail_x8_r0_body.fresh181 : (PRE_first_tail_x8_r0_body.S1749.tab.all fun e => PRE_first_tail_x8_r0_body.ws181.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1749.oracle.all fun q => PRE_first_tail_x8_r0_body.ws181.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab181 : PRE_first_tail_x8_r0_body.S1750.tab = PRE_first_tail_x8_r0_body.S1749.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws181
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen181 : PRE_first_tail_x8_r0_body.st181.S2.tab.length - PRE_first_tail_x8_r0_body.st181.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged181`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap181 : PRE_first_tail_x8_r0_body.s1750.heap = PRE_first_tail_x8_r0_body.st181.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext181 : PRE_first_tail_x8_r0_body.s1750.next = PRE_first_tail_x8_r0_body.st181.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl181 : PRE_first_tail_x8_r0_body.s1750.ctl = PRE_first_tail_x8_r0_body.st181.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack181 : PRE_first_tail_x8_r0_body.s1750.stack = PRE_first_tail_x8_r0_body.st181.s2.stack ++ PRE_first_tail_x8_r0_body.s1749.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs181 : PRE_first_tail_x8_r0_body.s1750.jobs = PRE_first_tail_x8_r0_body.st181.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi181 : PRE_first_tail_x8_r0_body.s1750.ffi = PRE_first_tail_x8_r0_body.st181.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace181 : PRE_first_tail_x8_r0_body.s1750.trace = PRE_first_tail_x8_r0_body.st181.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores181 : PRE_first_tail_x8_r0_body.s1750.stores = PRE_first_tail_x8_r0_body.st181.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD181
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 181 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived181 : PRE_first_tail_x8_r0_body.nr181.map (fun r => nth? PRE_first_tail_x8_r0_body.st181.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo181 : PRE_first_tail_x8_r0_body.nr181.all (Nat.ble 7817) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj181 : PRE_first_tail_x8_r0_body.cws181.all (fun c => !PRE_first_tail_x8_r0_body.ws181.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ181 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws181 PRE_first_tail_x8_r0_body.crs181 PRE_first_tail_x8_r0_body.ws181

end Host.Load.Run.Tpl
end

section -- st181/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st181`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st181.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st181.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st181.s2.heap PRE_first_tail_x8_r0_body.st181.wrR ++ freshOf PRE_first_tail_x8_r0_body.st181.s2.heap PRE_first_tail_x8_r0_body.st181.s0.next PRE_first_tail_x8_r0_body.st181.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st181.wr : List Nat := PRE_first_tail_x8_r0_body.st181.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st181.heapFoot : PRE_first_tail_x8_r0_body.st181.s2.heap = setAll PRE_first_tail_x8_r0_body.st181.s0.heap PRE_first_tail_x8_r0_body.st181.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st181.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st181.s0.next PRE_first_tail_x8_r0_body.st181.s2.next = true
theorem PRE_first_tail_x8_r0_body.st181.grows : PRE_first_tail_x8_r0_body.st181.s0.next ≤ PRE_first_tail_x8_r0_body.st181.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st181.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st181.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st181.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st181.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st181.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st181.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st181.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st181.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st181.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st181.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st181.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st181.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF181
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 181 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB181 : nodupT PRE_first_tail_x8_r0_body.st181.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup181 : PRE_first_tail_x8_r0_body.st181.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB181).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB181 : PRE_first_tail_x8_r0_body.st181.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound181 : ∀ b ∈ PRE_first_tail_x8_r0_body.st181.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB181 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr181 := PRE_first_tail_x8_r0_body.st181.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq181 : PRE_first_tail_x8_r0_body.st181.s2.trace = PRE_first_tail_x8_r0_body.trFr181 ++ PRE_first_tail_x8_r0_body.st181.s0.trace
theorem PRE_first_tail_x8_r0_body.trace181 : ∃ fr, PRE_first_tail_x8_r0_body.st181.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st181.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq181⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide181 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB181 : (PRE_first_tail_x8_r0_body.wide181.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st181.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix181 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide181, WFix Map.id (Present PRE_first_tail_x8_r0_body.st181.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB181 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL181
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 181 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1750`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO181 : PRE_first_tail_x8_r0_body.st181.S0.oracle = PRE_first_tail_x8_r0_body.st181.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B181 : PRE_first_tail_x8_r0_body.st181.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st181.s0.next || (PRE_first_tail_x8_r0_body.st181.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot181 : Conv.StageFoot PRE_first_tail_x8_r0_body.st181.wr PRE_first_tail_x8_r0_body.st181.s0 PRE_first_tail_x8_r0_body.st181.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st181.heapFoot PRE_first_tail_x8_r0_body.wrNodup181 PRE_first_tail_x8_r0_body.wrBound181 PRE_first_tail_x8_r0_body.wr0B181 PRE_first_tail_x8_r0_body.st181.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged181 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st181.F.S → PRE_first_tail_x8_r0_body.st181.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st181.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st181.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs181 PRE_first_tail_x8_r0_body.st181.wr PRE_first_tail_x8_r0_body.s1749 PRE_first_tail_x8_r0_body.st181.s2 PRE_first_tail_x8_r0_body.st181.s0
      PRE_first_tail_x8_r0_body.st181.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st181.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1750 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso181 PRE_first_tail_x8_r0_body.stFoot181 PRE_first_tail_x8_r0_body.wrNodup181 PRE_first_tail_x8_r0_body.wrBound181 PRE_first_tail_x8_r0_body.trace181 PRE_first_tail_x8_r0_body.mheap181
    PRE_first_tail_x8_r0_body.mnext181 PRE_first_tail_x8_r0_body.mctl181 PRE_first_tail_x8_r0_body.mstack181 PRE_first_tail_x8_r0_body.mjobs181 PRE_first_tail_x8_r0_body.mffi181 PRE_first_tail_x8_r0_body.mtrace181 PRE_first_tail_x8_r0_body.mstores181 h

def PRE_first_tail_x8_r0_body.arrEl181_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE181_2665 : arrOf PRE_first_tail_x8_r0_body.s1750 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl181_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA181_2665 : isArrB PRE_first_tail_x8_r0_body.s1750 2665 = true
theorem PRE_first_tail_x8_r0_body.arr181_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1750.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl181_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE181_2665 PRE_first_tail_x8_r0_body.arrA181_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN181_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl181_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR181_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl181_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN181_2665

def PRE_first_tail_x8_r0_body.arrEl181_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE181_2673467 : arrOf PRE_first_tail_x8_r0_body.s1750 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl181_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA181_2673467 : isArrB PRE_first_tail_x8_r0_body.s1750 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr181_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1750.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl181_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE181_2673467 PRE_first_tail_x8_r0_body.arrA181_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN181_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl181_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR181_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl181_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN181_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k181 : isArrB PRE_first_tail_x8_r0_body.s1750 4910 = false
theorem PRE_first_tail_x8_r0_body.keep181 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1750 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k181 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr181_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl181_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ181
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 181 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1749`, the merged
state `PRE_first_tail_x8_r0_body.s1750`, the canonical state `PRE_first_tail_x8_r0_body.s1751`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl181 : PRE_first_tail_x8_r0_body.pl181.all (Nat.ble PRE_first_tail_x8_r0_body.s1749.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd181 : nodupT PRE_first_tail_x8_r0_body.pl181 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1181 : Nat.ble PRE_first_tail_x8_r0_body.s1749.next 2817225 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst181 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1749.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn181 : PRE_first_tail_x8_r0_body.s1751.next = PRE_first_tail_x8_r0_body.s1749.next + PRE_first_tail_x8_r0_body.pl181.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn181 : PRE_first_tail_x8_r0_body.s1750.next = 2817225
kernel_rfl PRE_first_tail_x8_r0_body.zgrow181 : Nat.ble PRE_first_tail_x8_r0_body.s1751.next PRE_first_tail_x8_r0_body.s1750.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh181 : PRE_first_tail_x8_r0_body.S1749.tab.all (fun e => PRE_first_tail_x8_r0_body.cws181.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd181 : nodupT PRE_first_tail_x8_r0_body.cws181 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi181 : PRE_first_tail_x8_r0_body.nr181.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1750.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt181 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1749.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg181_2665 : PRE_first_tail_x8_r0_body.s1751.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1751 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk181_2665 : (objOf PRE_first_tail_x8_r0_body.s1751 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm181_2665 : PRE_first_tail_x8_r0_body.s1750.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa181.obj (objOf PRE_first_tail_x8_r0_body.s1751 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1750 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg181_2673467 : PRE_first_tail_x8_r0_body.s1751.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1751 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk181_2673467 : (objOf PRE_first_tail_x8_r0_body.s1751 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm181_2673467 : PRE_first_tail_x8_r0_body.s1750.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa181.obj (objOf PRE_first_tail_x8_r0_body.s1751 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1750 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw181_4910 : (PRE_first_tail_x8_r0_body.s1751.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw181_2673472 : (PRE_first_tail_x8_r0_body.s1751.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw181_2673473 : (PRE_first_tail_x8_r0_body.s1751.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd181 : PRE_first_tail_x8_r0_body.cl181.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr181 : PRE_first_tail_x8_r0_body.st181.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1749.next || PRE_first_tail_x8_r0_body.cl181.contains b) = true
def PRE_first_tail_x8_r0_body.zl181 : List Nat := PRE_first_tail_x8_r0_body.cl181.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE181 : PRE_first_tail_x8_r0_body.zl181.map (fun a => PRE_first_tail_x8_r0_body.s1750.heap.get (PRE_first_tail_x8_r0_body.kappa181.a a)) = PRE_first_tail_x8_r0_body.zl181.map (fun a => (PRE_first_tail_x8_r0_body.s1751.heap.get a).map PRE_first_tail_x8_r0_body.kappa181.hobj)
theorem PRE_first_tail_x8_r0_body.zimg181 : HeapImg PRE_first_tail_x8_r0_body.kappa181 PRE_first_tail_x8_r0_body.s1751 PRE_first_tail_x8_r0_body.s1750 PRE_first_tail_x8_r0_body.zl181 := PRE_first_tail_x8_r0_body.zimgE181
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl181 : PRE_first_tail_x8_r0_body.s1750.ctl = PRE_first_tail_x8_r0_body.kappa181.ctl PRE_first_tail_x8_r0_body.s1751.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack181 : PRE_first_tail_x8_r0_body.s1750.stack = PRE_first_tail_x8_r0_body.s1751.stack.map PRE_first_tail_x8_r0_body.kappa181.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs181 : PRE_first_tail_x8_r0_body.s1750.jobs = PRE_first_tail_x8_r0_body.s1751.jobs.map PRE_first_tail_x8_r0_body.kappa181.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores181 : PRE_first_tail_x8_r0_body.s1750.stores = PRE_first_tail_x8_r0_body.kappa181.stores PRE_first_tail_x8_r0_body.s1751.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots181 : checkRootsSupp PRE_first_tail_x8_r0_body.s1751 7817 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC181 : PRE_first_tail_x8_r0_body.S1749.tab.length + PRE_first_tail_x8_r0_body.cws181.length = 7817
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap181 : PRE_first_tail_x8_r0_body.kappa181 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1749.next 2817225 PRE_first_tail_x8_r0_body.S1749.tab.length PRE_first_tail_x8_r0_body.pl181 (PRE_first_tail_x8_r0_body.nr181.map NumV.ref) PRE_first_tail_x8_r0_body.kd181.big
  PRE_first_tail_x8_r0_body.kd181.region PRE_first_tail_x8_r0_body.kd181.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin181 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1751.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc181 : Conv.jcleanListB (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1751 PRE_first_tail_x8_r0_body.cl181 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB181 : noBigRootsP (fun i => !Conv.oldBigB (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1751.trace PRE_first_tail_x8_r0_body.s1751 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm181 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18873 = true
theorem PRE_first_tail_x8_r0_body.cjcl181 (h : Conv.JClean (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1749) : Conv.JClean (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1751 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle181)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap181 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd181 a ha)) PRE_first_tail_x8_r0_body.zjc181

end Host.Load.Run.Tpl
end

section -- st181/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st181.bodyLast from PRE_first_tail_x8_r0_body.st181.s1 to PRE_first_tail_x8_r0_body.st181.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st181.F PRE_first_tail_x8_r0_body.st181.s1).run PRE_first_tail_x8_r0_body.st181.S1 = some (PRE_first_tail_x8_r0_body.st181.s2, PRE_first_tail_x8_r0_body.st181.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st181.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st181.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st181.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st181.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st181/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st181.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st181.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st181.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st181.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st181.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st181.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st181.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st181.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st181.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st181.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st181.s0 PRE_first_tail_x8_r0_body.st181.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st181.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st181.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st181.s1 PRE_first_tail_x8_r0_body.st181.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st181/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st181.bodyK0F from PRE_first_tail_x8_r0_body.st181.s0 to PRE_first_tail_x8_r0_body.st181.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st181.F (PRE_first_tail_x8_r0_body.st181.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st181.ks 0).getD 0) PRE_first_tail_x8_r0_body.st181.s0 PRE_first_tail_x8_r0_body.st181.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st181.s1, PRE_first_tail_x8_r0_body.st181.S1)
theorem PRE_first_tail_x8_r0_body.st181.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st181.F (PRE_first_tail_x8_r0_body.st181.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st181.ks 0).getD 0) PRE_first_tail_x8_r0_body.st181.s0 PRE_first_tail_x8_r0_body.st181.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st181.s1, PRE_first_tail_x8_r0_body.st181.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st181.bodyOkLN_ok PRE_first_tail_x8_r0_body.st181.bodyK0F
end Host.Load.Run.Tpl
end

section -- st181/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st181.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st181.F (PRE_first_tail_x8_r0_body.st181.bodyOkL bytes rows) 27 PRE_first_tail_x8_r0_body.st181.s0 PRE_first_tail_x8_r0_body.st181.S0 = some (PRE_first_tail_x8_r0_body.st181.s1, PRE_first_tail_x8_r0_body.st181.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st181.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st181.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st181.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st181.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st181.F (PRE_first_tail_x8_r0_body.st181.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st181.s0
  S0 := PRE_first_tail_x8_r0_body.st181.S0
  s1 := PRE_first_tail_x8_r0_body.st181.s1
  S1 := PRE_first_tail_x8_r0_body.st181.S1
  s2 := PRE_first_tail_x8_r0_body.st181.s2
  S2 := PRE_first_tail_x8_r0_body.st181.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st181.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st181.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st181.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st181.bodyHalt
  last := PRE_first_tail_x8_r0_body.st181.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st181.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC182
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 182 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1755` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa182` into the merged state
`PRE_first_tail_x8_r0_body.s1754`. -/

def PRE_first_tail_x8_r0_body.pl182 : List Nat := [2817531]
def PRE_first_tail_x8_r0_body.nr182 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd182 : RData :=
  ⟨2817512, 2817532, Stage.setAll PTrie.nil [(2817511, 2817531)], Stage.setAll PTrie.nil [],
   21779, 21779, 18877, 18877, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa182 : Map :=
  Conv.Map.compact 2817511 2817532 7834 PRE_first_tail_x8_r0_body.pl182 (PRE_first_tail_x8_r0_body.nr182.map NumV.ref) PRE_first_tail_x8_r0_body.kd182.big
    PRE_first_tail_x8_r0_body.kd182.region PRE_first_tail_x8_r0_body.kd182.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws182 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs182 : List SymE := PRE_first_tail_x8_r0_body.nr182.map fun r => (nth? PRE_first_tail_x8_r0_body.S1754.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta182 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws182 PRE_first_tail_x8_r0_body.crs182
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB182 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab182 : PRE_first_tail_x8_r0_body.S1755.tab = PRE_first_tail_x8_r0_body.S1753.tab ++ PRE_first_tail_x8_r0_body.cws182.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace182 : PRE_first_tail_x8_r0_body.s1755.trace = PRE_first_tail_x8_r0_body.s1753.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext182 : PRE_first_tail_x8_r0_body.s1755.next = 2817512
kernel_rfl PRE_first_tail_x8_r0_body.ccounters182 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx.nnext) = (21779, 18877)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue182 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1754.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa182.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp182 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx.tokens.all (bSN 7834) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean182 : Conv.cleanListB 21779 131072 (fun r => Nat.ble 87116 r) PRE_first_tail_x8_r0_body.s1755
    (PRE_first_tail_x8_r0_body.wrB182 ++ (List.range 1).map (2817511 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs182 : bigsOutB 21779 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK182
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl182`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl182 : List Nat := [2665, 2673467, 2817511]
def PRE_first_tail_x8_r0_body.clo182 : List Nat := []
def PRE_first_tail_x8_r0_body.cln182 : List Nat := []
def PRE_first_tail_x8_r0_body.cli182 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap182 : PRE_first_tail_x8_r0_body.s1755.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1753.heap (PRE_first_tail_x8_r0_body.cl182.filterMap fun a => (PRE_first_tail_x8_r0_body.s1755.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe182 : Nat.ble PRE_first_tail_x8_r0_body.s1753.next PRE_first_tail_x8_r0_body.s1755.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP182 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1753 PRE_first_tail_x8_r0_body.s1755 PRE_first_tail_x8_r0_body.cl182 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp182 : Conv.suppListB PRE_first_tail_x8_r0_body.s1755 7834 PRE_first_tail_x8_r0_body.cl182 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound182 : Conv.boundListB PRE_first_tail_x8_r0_body.s1755 PRE_first_tail_x8_r0_body.cl182 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK182 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln182.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK182 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo182.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK182 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli182.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst182 : Conv.sstListB 7834 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx PRE_first_tail_x8_r0_body.cln182 PRE_first_tail_x8_r0_body.clo182 PRE_first_tail_x8_r0_body.cli182 = true

end Host.Load.Run.Tpl
end

section -- SiteCl182
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA182 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo182.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd182 : (PRE_first_tail_x8_r0_body.clo182 ++ PRE_first_tail_x8_r0_body.cln182 ++ PRE_first_tail_x8_r0_body.cli182).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle182 : Conv.Cnt.leB (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) (⟨21779, 18877, 2817512, 7834⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck182 : Conv.ncleanListB (⟨21779, 18877, 2817512, 7834⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx PRE_first_tail_x8_r0_body.clo182 PRE_first_tail_x8_r0_body.cln182 PRE_first_tail_x8_r0_body.cli182 = true
theorem PRE_first_tail_x8_r0_body.cncl182 (h : Conv.NClean (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx) : Conv.NClean (⟨21779, 18877, 2817512, 7834⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle182 PRE_first_tail_x8_r0_body.ckA182 PRE_first_tail_x8_r0_body.cobjsK182 PRE_first_tail_x8_r0_body.cnodesK182 PRE_first_tail_x8_r0_body.citemsK182 PRE_first_tail_x8_r0_body.cbd182 PRE_first_tail_x8_r0_body.cck182

end Host.Load.Run.Tpl
end

section -- SiteS182
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 182 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc182 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P182 : LoadP := PRE_first_tail_x8_r0_body.Pc182.raise 18877
kernel_rfl PRE_first_tail_x8_r0_body.craise182 : Nat.ble PRE_first_tail_x8_r0_body.Pc182.N0 18877 = true
theorem PRE_first_tail_x8_r0_body.raised182 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc182 PRE_first_tail_x8_r0_body.P182 :=
  .inr ⟨18877, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise182, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_182 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_182 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1754.ffi)
def PRE_first_tail_x8_r0_body.khinv182 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv182 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS182 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS182 : List Nat := List.range' 18877 0
def PRE_first_tail_x8_r0_body.ciS182 : List Nat := [] ++ List.range' 18877 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0182 : PRE_first_tail_x8_r0_body.kd182.nh0 = PRE_first_tail_x8_r0_body.cx0_182.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1182 : PRE_first_tail_x8_r0_body.kd182.nh1 = PRE_first_tail_x8_r0_body.cx1_182.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0182 : PRE_first_tail_x8_r0_body.kd182.nn0 = PRE_first_tail_x8_r0_body.cx0_182.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1182 : PRE_first_tail_x8_r0_body.kd182.nn1 = PRE_first_tail_x8_r0_body.cx1_182.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo182 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P182.lo && Nat.ble PRE_first_tail_x8_r0_body.P182.lo PRE_first_tail_x8_r0_body.cx0_182.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P182.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P182.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt182 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_182.mlx.next PRE_first_tail_x8_r0_body.cx1_182.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_182.mlx.nnext PRE_first_tail_x8_r0_body.cx1_182.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband182 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P182.NL && Nat.ble PRE_first_tail_x8_r0_body.P182.NL PRE_first_tail_x8_r0_body.P182.N0 && Nat.ble PRE_first_tail_x8_r0_body.P182.N0 PRE_first_tail_x8_r0_body.cx0_182.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow182 : PRE_first_tail_x8_r0_body.kd182.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren182 : checkRenG PRE_first_tail_x8_r0_body.kd182.hnd PRE_first_tail_x8_r0_body.khinv182 (phB PRE_first_tail_x8_r0_body.cx0_182.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband182 : PRE_first_tail_x8_r0_body.kd182.checkBand PRE_first_tail_x8_r0_body.P182.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos182 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd182.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren182 : checkRenG PRE_first_tail_x8_r0_body.kd182.node PRE_first_tail_x8_r0_body.kninv182 (pnB PRE_first_tail_x8_r0_body.cx0_182.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow182 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd182.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P182.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd182.nodeF j) PRE_first_tail_x8_r0_body.cx1_182.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a182 : PRE_first_tail_x8_r0_body.cx0_182.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b182 : PRE_first_tail_x8_r0_body.cx0_182.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1182 : PRE_first_tail_x8_r0_body.cx1_182.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend182 : PRE_first_tail_x8_r0_body.cx1_182.mlx.pending = PRE_first_tail_x8_r0_body.cx0_182.mlx.pending.map PRE_first_tail_x8_r0_body.kappa182.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh182 : PRE_first_tail_x8_r0_body.cx1_182.mlx.errh = PRE_first_tail_x8_r0_body.cx0_182.mlx.errh.map PRE_first_tail_x8_r0_body.kappa182.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles182 : PRE_first_tail_x8_r0_body.cx1_182.mlx.files = PRE_first_tail_x8_r0_body.cx0_182.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch182 : PRE_first_tail_x8_r0_body.cx1_182.mlx.arch = PRE_first_tail_x8_r0_body.cx0_182.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes182 : PRE_first_tail_x8_r0_body.cx1_182.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_182.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired182 : PRE_first_tail_x8_r0_body.cx1_182.mlx.wired = PRE_first_tail_x8_r0_body.cx0_182.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost182 : PRE_first_tail_x8_r0_body.cx1_182.host = PRE_first_tail_x8_r0_body.cx0_182.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd182`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0182 : PRE_first_tail_x8_r0_body.kd182.n0 = 2817512
kernel_rfl PRE_first_tail_x8_r0_body.ckn1182 : PRE_first_tail_x8_r0_body.kd182.n1 = 2817532
kernel_rfl PRE_first_tail_x8_r0_body.ckheap182 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd182.heap).all (fun x => Nat.ble 2817511 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl182 : (List.range 1).all (fun j => decide (PRE_first_tail_x8_r0_body.kd182.heap.get (2817511 + j) = nth? PRE_first_tail_x8_r0_body.pl182 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja182 : Nat.ble 2817511 2817511 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn182 : Nat.ble 7834 7834 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD182 : Nat.ble 2817511 PRE_first_tail_x8_r0_body.kd182.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn182 : Nat.ble 21779 PRE_first_tail_x8_r0_body.kd182.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn182 : Nat.ble 18877 PRE_first_tail_x8_r0_body.kd182.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb182 : Nat.ble 21779 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap182 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd182.heap).all (Nat.ble (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd182 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd182.hnd).all (Nat.ble (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode182 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd182.node).all (Nat.ble (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix182 : Conv.FixOld (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa182 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja182) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn182) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD182) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn182) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn182) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb182) PRE_first_tail_x8_r0_body.fheap182 PRE_first_tail_x8_r0_body.fhnd182 PRE_first_tail_x8_r0_body.fnode182
kernel_rfl PRE_first_tail_x8_r0_body.fcxn182 : (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn182 : (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0182 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_182.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_182.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk182 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd182.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A182 : PRE_first_tail_x8_r0_body.cx1_182.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS182.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_182.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O182 : PRE_first_tail_x8_r0_body.cx1_182.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS182.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_182.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N182 : PRE_first_tail_x8_r0_body.cx1_182.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS182.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_182.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I182 : PRE_first_tail_x8_r0_body.cx1_182.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS182.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_182.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd182 : (PRE_first_tail_x8_r0_body.clo182 ++ PRE_first_tail_x8_r0_body.cln182 ++ PRE_first_tail_x8_r0_body.cli182 ++ PRE_first_tail_x8_r0_body.cwS182 ++ PRE_first_tail_x8_r0_body.cnS182 ++ PRE_first_tail_x8_r0_body.ciS182).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW182 : PRE_first_tail_x8_r0_body.cwS182.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo182.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI182 : PRE_first_tail_x8_r0_body.ciS182.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli182.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN182 : PRE_first_tail_x8_r0_body.cnS182.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF182 : PRE_first_tail_x8_r0_body.cln182.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh182 : PRE_first_tail_x8_r0_body.clo182.all (handleOK PRE_first_tail_x8_r0_body.kappa182 PRE_first_tail_x8_r0_body.P182.lo PRE_first_tail_x8_r0_body.cx0_182.mlx PRE_first_tail_x8_r0_body.cx1_182.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo182 : PRE_first_tail_x8_r0_body.clo182.map (fun h => PRE_first_tail_x8_r0_body.cx1_182.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa182.handle h)) = PRE_first_tail_x8_r0_body.clo182.map (fun h => (PRE_first_tail_x8_r0_body.cx0_182.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa182.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok182 : PRE_first_tail_x8_r0_body.clo182.all (objOK PRE_first_tail_x8_r0_body.kappa182 PRE_first_tail_x8_r0_body.P182.NL PRE_first_tail_x8_r0_body.cx0_182.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd182 : PRE_first_tail_x8_r0_body.cln182.all (nodeOKF PRE_first_tail_x8_r0_body.kappa182 PRE_first_tail_x8_r0_body.P182 PRE_first_tail_x8_r0_body.cx0_182.mlx PRE_first_tail_x8_r0_body.cx1_182.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp182 : ((PRE_first_tail_x8_r0_body.cln182.filter (fullB PRE_first_tail_x8_r0_body.P182))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_182.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa182.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln182.filter (fullB PRE_first_tail_x8_r0_body.P182))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_182.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa182.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI182 : incrB PRE_first_tail_x8_r0_body.kd182.nodeF (List.range' 18877 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK182 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd182.node).all (fun k => Nat.ble 18877 k && Nat.blt k 18877) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL182 : (PRE_first_tail_x8_r0_body.cln182.filter (Nat.ble PRE_first_tail_x8_r0_body.P182.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd182.nodeF i) && (Nat.blt i 18877 || Nat.ble PRE_first_tail_x8_r0_body.kd182.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord182 : (PRE_first_tail_x8_r0_body.cln182.filter (Nat.ble PRE_first_tail_x8_r0_body.P182.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd182.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd182.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd182.nodeF j) (PRE_first_tail_x8_r0_body.kd182.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow182 PRE_first_tail_x8_r0_body.cnn1182 PRE_first_tail_x8_r0_body.fnordI182 PRE_first_tail_x8_r0_body.fnordK182 PRE_first_tail_x8_r0_body.fnordL182
kernel_rfl PRE_first_tail_x8_r0_body.fi182 : PRE_first_tail_x8_r0_body.cli182.all (pnB PRE_first_tail_x8_r0_body.cx0_182.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii182 : PRE_first_tail_x8_r0_body.cli182.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_182.mlx.items.get (PRE_first_tail_x8_r0_body.kappa182.node k) = (PRE_first_tail_x8_r0_body.cx0_182.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa182.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot182 (clean : Conv.NClean (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P182.NL) (cl : SSt (· < 7834) PRE_first_tail_x8_r0_body.cx0_182.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P182 7834 PRE_first_tail_x8_r0_body.kappa182 PRE_first_tail_x8_r0_body.kd182 PRE_first_tail_x8_r0_body.khinv182 PRE_first_tail_x8_r0_body.kninv182 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx PRE_first_tail_x8_r0_body.cx0_182.mlx PRE_first_tail_x8_r0_body.cx1_182.mlx (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo182 PRE_first_tail_x8_r0_body.cln182 PRE_first_tail_x8_r0_body.cli182 PRE_first_tail_x8_r0_body.cwS182 PRE_first_tail_x8_r0_body.cnS182 PRE_first_tail_x8_r0_body.ciS182 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0182, PRE_first_tail_x8_r0_body.cnh1182, PRE_first_tail_x8_r0_body.cnn0182, PRE_first_tail_x8_r0_body.cnn1182, PRE_first_tail_x8_r0_body.cplo182, PRE_first_tail_x8_r0_body.ccnt182, PRE_first_tail_x8_r0_body.cnband182, PRE_first_tail_x8_r0_body.chbelow182, PRE_first_tail_x8_r0_body.chren182, PRE_first_tail_x8_r0_body.cband182, PRE_first_tail_x8_r0_body.cnh1pos182, PRE_first_tail_x8_r0_body.cnren182, PRE_first_tail_x8_r0_body.cnlow182, PRE_first_tail_x8_r0_body.cabs0a182, PRE_first_tail_x8_r0_body.cabs0b182, PRE_first_tail_x8_r0_body.ctok1182, PRE_first_tail_x8_r0_body.cpend182, PRE_first_tail_x8_r0_body.cerrh182, PRE_first_tail_x8_r0_body.cfiles182, PRE_first_tail_x8_r0_body.carch182, PRE_first_tail_x8_r0_body.csizes182, PRE_first_tail_x8_r0_body.cwired182, PRE_first_tail_x8_r0_body.cfix182, clean, PRE_first_tail_x8_r0_body.fcxn182, PRE_first_tail_x8_r0_body.fcnn182, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0182, PRE_first_tail_x8_r0_body.fnk182, PRE_first_tail_x8_r0_body.ckA182, PRE_first_tail_x8_r0_body.cobjsK182, PRE_first_tail_x8_r0_body.cnodesK182, PRE_first_tail_x8_r0_body.citemsK182, PRE_first_tail_x8_r0_body.f1A182, PRE_first_tail_x8_r0_body.f1O182, PRE_first_tail_x8_r0_body.f1N182, PRE_first_tail_x8_r0_body.f1I182, PRE_first_tail_x8_r0_body.fbd182, PRE_first_tail_x8_r0_body.fincW182, PRE_first_tail_x8_r0_body.fincI182, PRE_first_tail_x8_r0_body.fincN182, PRE_first_tail_x8_r0_body.flnF182, PRE_first_tail_x8_r0_body.fh182, PRE_first_tail_x8_r0_body.fo182, PRE_first_tail_x8_r0_body.fok182, PRE_first_tail_x8_r0_body.fnd182, PRE_first_tail_x8_r0_body.fp182, PRE_first_tail_x8_r0_body.fnord182, PRE_first_tail_x8_r0_body.fi182, PRE_first_tail_x8_r0_body.fii182⟩
theorem PRE_first_tail_x8_r0_body.cnshift182 (clean : Conv.NClean (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P182.NL) (cl : SSt (· < 7834) PRE_first_tail_x8_r0_body.cx0_182.mlx) : NShift PRE_first_tail_x8_r0_body.P182 7834 PRE_first_tail_x8_r0_body.kappa182 PRE_first_tail_x8_r0_body.cx0_182 PRE_first_tail_x8_r0_body.cx1_182 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot182 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost182 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0182 PRE_first_tail_x8_r0_body.ckn1182 PRE_first_tail_x8_r0_body.ckheap182 PRE_first_tail_x8_r0_body.ckpl182)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_182 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1753.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_182 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1753.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_182 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1753.ffi) = some PRE_first_tail_x8_r0_body.fxC_182
kernel_rfl PRE_first_tail_x8_r0_body.okrC_182 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1753.ffi) = some PRE_first_tail_x8_r0_body.krC_182
noncomputable def PRE_first_tail_x8_r0_body.fx0_182 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1755.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_182 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1755.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_182 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1755.ffi) = some PRE_first_tail_x8_r0_body.fx0_182
kernel_rfl PRE_first_tail_x8_r0_body.okr0_182 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1755.ffi) = some PRE_first_tail_x8_r0_body.kr0_182
noncomputable def PRE_first_tail_x8_r0_body.fx1_182 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1754.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_182 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1754.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_182 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1754.ffi) = some PRE_first_tail_x8_r0_body.fx1_182
kernel_rfl PRE_first_tail_x8_r0_body.okr1_182 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1754.ffi) = some PRE_first_tail_x8_r0_body.kr1_182
kernel_rfl PRE_first_tail_x8_r0_body.ff0182 : PRE_first_tail_x8_r0_body.fx0_182 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_182 (PRE_first_tail_x8_r0_body.clo182.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_182.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1182 : PRE_first_tail_x8_r0_body.fx1_182 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_182 (PRE_first_tail_x8_r0_body.cwS182.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_182.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck182 : freedLB PRE_first_tail_x8_r0_body.kappa182 PRE_first_tail_x8_r0_body.cx0_182.mlx PRE_first_tail_x8_r0_body.fx0_182 PRE_first_tail_x8_r0_body.fx1_182 PRE_first_tail_x8_r0_body.clo182 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0182 : PRE_first_tail_x8_r0_body.kr0_182.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_182.flags (PRE_first_tail_x8_r0_body.clo182.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_182.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0182 : PRE_first_tail_x8_r0_body.kr0_182.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_182.targs (PRE_first_tail_x8_r0_body.clo182.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_182.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1182 : PRE_first_tail_x8_r0_body.kr1_182.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_182.flags (PRE_first_tail_x8_r0_body.cwS182.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_182.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1182 : PRE_first_tail_x8_r0_body.kr1_182.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_182.targs (PRE_first_tail_x8_r0_body.cwS182.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_182.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck182 : krecLB PRE_first_tail_x8_r0_body.kappa182 7834 PRE_first_tail_x8_r0_body.cx0_182.mlx PRE_first_tail_x8_r0_body.kr0_182 PRE_first_tail_x8_r0_body.kr1_182 PRE_first_tail_x8_r0_body.clo182 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn182 : Nat.ble 7834 7834 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge182 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1754.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1755.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR182 : pendRegB PRE_first_tail_x8_r0_body.kappa182 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe182 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1755.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1754.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift182 (clean : Conv.NClean (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P182.NL) (cl : SSt (· < 7834) PRE_first_tail_x8_r0_body.cx0_182.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_182.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_182.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_182.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1753.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_182.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P182 7834 PRE_first_tail_x8_r0_body.kappa182 PRE_first_tail_x8_r0_body.s1755.ffi PRE_first_tail_x8_r0_body.s1754.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift182 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue182, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp182 t ht),
    PRE_first_tail_x8_r0_body.cbridge182,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1755.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1754.ffi) (PRE_first_tail_x8_r0_body.cfoot182 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_182 PRE_first_tail_x8_r0_body.ofx1_182 hobjC PRE_first_tail_x8_r0_body.ff0182 PRE_first_tail_x8_r0_body.ff1182 PRE_first_tail_x8_r0_body.ffck182,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1755.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1754.ffi) (PRE_first_tail_x8_r0_body.cfoot182 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_182 PRE_first_tail_x8_r0_body.okr1_182 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn182) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0182 PRE_first_tail_x8_r0_body.fkt0182 PRE_first_tail_x8_r0_body.fkf1182 PRE_first_tail_x8_r0_body.fkt1182 PRE_first_tail_x8_r0_body.fkck182,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0182 PRE_first_tail_x8_r0_body.cnh1182 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe182) PRE_first_tail_x8_r0_body.cpendR182⟩

end Host.Load.Run.Tpl
end

section -- st182/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st182 0
host_stream_state PRE_first_tail_x8_r0_body.st182 1
host_stream_state PRE_first_tail_x8_r0_body.st182 2
end Host.Load.Run.Tpl
end

section -- Site182
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 182 of chain `PRE_first_tail_x8_r0_body`: `plan__g182__g183` (`plan`), the call state `PRE_first_tail_x8_r0_body.s1753`, the merged state `PRE_first_tail_x8_r0_body.s1754`,
the site template `PRE_first_tail_x8_r0_body.st182` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1755`: the merge.
The footprint's facts are in `SiteF182`, the compaction's in `SiteC182`, `SiteK182`, `SiteNa182`, `SiteNb182`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso182 : PRE_first_tail_x8_r0_body.st182.s0 = { PRE_first_tail_x8_r0_body.s1753 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs182 : List Frame := PRE_first_tail_x8_r0_body.s1753.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_182 : PRE_first_tail_x8_r0_body.S1753.tab.length = 7834
kernel_rfl PRE_first_tail_x8_r0_body.tab0_182 : PRE_first_tail_x8_r0_body.st182.S0.tab = PRE_first_tail_x8_r0_body.S1753.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws182 : List Nat := [4078, 4079, 4080, 4081, 4082, 4083, 4084, 4085, 4086]
kernel_rfl PRE_first_tail_x8_r0_body.fresh182 : (PRE_first_tail_x8_r0_body.S1753.tab.all fun e => PRE_first_tail_x8_r0_body.ws182.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1753.oracle.all fun q => PRE_first_tail_x8_r0_body.ws182.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab182 : PRE_first_tail_x8_r0_body.S1754.tab = PRE_first_tail_x8_r0_body.S1753.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws182
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen182 : PRE_first_tail_x8_r0_body.st182.S2.tab.length - PRE_first_tail_x8_r0_body.st182.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged182`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap182 : PRE_first_tail_x8_r0_body.s1754.heap = PRE_first_tail_x8_r0_body.st182.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext182 : PRE_first_tail_x8_r0_body.s1754.next = PRE_first_tail_x8_r0_body.st182.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl182 : PRE_first_tail_x8_r0_body.s1754.ctl = PRE_first_tail_x8_r0_body.st182.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack182 : PRE_first_tail_x8_r0_body.s1754.stack = PRE_first_tail_x8_r0_body.st182.s2.stack ++ PRE_first_tail_x8_r0_body.s1753.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs182 : PRE_first_tail_x8_r0_body.s1754.jobs = PRE_first_tail_x8_r0_body.st182.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi182 : PRE_first_tail_x8_r0_body.s1754.ffi = PRE_first_tail_x8_r0_body.st182.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace182 : PRE_first_tail_x8_r0_body.s1754.trace = PRE_first_tail_x8_r0_body.st182.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores182 : PRE_first_tail_x8_r0_body.s1754.stores = PRE_first_tail_x8_r0_body.st182.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD182
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 182 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived182 : PRE_first_tail_x8_r0_body.nr182.map (fun r => nth? PRE_first_tail_x8_r0_body.st182.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo182 : PRE_first_tail_x8_r0_body.nr182.all (Nat.ble 7834) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj182 : PRE_first_tail_x8_r0_body.cws182.all (fun c => !PRE_first_tail_x8_r0_body.ws182.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ182 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws182 PRE_first_tail_x8_r0_body.crs182 PRE_first_tail_x8_r0_body.ws182

end Host.Load.Run.Tpl
end

section -- st182/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st182`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st182.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st182.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st182.s2.heap PRE_first_tail_x8_r0_body.st182.wrR ++ freshOf PRE_first_tail_x8_r0_body.st182.s2.heap PRE_first_tail_x8_r0_body.st182.s0.next PRE_first_tail_x8_r0_body.st182.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st182.wr : List Nat := PRE_first_tail_x8_r0_body.st182.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st182.heapFoot : PRE_first_tail_x8_r0_body.st182.s2.heap = setAll PRE_first_tail_x8_r0_body.st182.s0.heap PRE_first_tail_x8_r0_body.st182.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st182.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st182.s0.next PRE_first_tail_x8_r0_body.st182.s2.next = true
theorem PRE_first_tail_x8_r0_body.st182.grows : PRE_first_tail_x8_r0_body.st182.s0.next ≤ PRE_first_tail_x8_r0_body.st182.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st182.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st182.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st182.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st182.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st182.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st182.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st182.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st182.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st182.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st182.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st182.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st182.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF182
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 182 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB182 : nodupT PRE_first_tail_x8_r0_body.st182.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup182 : PRE_first_tail_x8_r0_body.st182.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB182).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB182 : PRE_first_tail_x8_r0_body.st182.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound182 : ∀ b ∈ PRE_first_tail_x8_r0_body.st182.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB182 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr182 := PRE_first_tail_x8_r0_body.st182.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq182 : PRE_first_tail_x8_r0_body.st182.s2.trace = PRE_first_tail_x8_r0_body.trFr182 ++ PRE_first_tail_x8_r0_body.st182.s0.trace
theorem PRE_first_tail_x8_r0_body.trace182 : ∃ fr, PRE_first_tail_x8_r0_body.st182.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st182.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq182⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide182 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB182 : (PRE_first_tail_x8_r0_body.wide182.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st182.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix182 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide182, WFix Map.id (Present PRE_first_tail_x8_r0_body.st182.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB182 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL182
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 182 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1754`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO182 : PRE_first_tail_x8_r0_body.st182.S0.oracle = PRE_first_tail_x8_r0_body.st182.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B182 : PRE_first_tail_x8_r0_body.st182.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st182.s0.next || (PRE_first_tail_x8_r0_body.st182.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot182 : Conv.StageFoot PRE_first_tail_x8_r0_body.st182.wr PRE_first_tail_x8_r0_body.st182.s0 PRE_first_tail_x8_r0_body.st182.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st182.heapFoot PRE_first_tail_x8_r0_body.wrNodup182 PRE_first_tail_x8_r0_body.wrBound182 PRE_first_tail_x8_r0_body.wr0B182 PRE_first_tail_x8_r0_body.st182.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged182 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st182.F.S → PRE_first_tail_x8_r0_body.st182.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st182.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st182.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs182 PRE_first_tail_x8_r0_body.st182.wr PRE_first_tail_x8_r0_body.s1753 PRE_first_tail_x8_r0_body.st182.s2 PRE_first_tail_x8_r0_body.st182.s0
      PRE_first_tail_x8_r0_body.st182.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st182.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1754 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso182 PRE_first_tail_x8_r0_body.stFoot182 PRE_first_tail_x8_r0_body.wrNodup182 PRE_first_tail_x8_r0_body.wrBound182 PRE_first_tail_x8_r0_body.trace182 PRE_first_tail_x8_r0_body.mheap182
    PRE_first_tail_x8_r0_body.mnext182 PRE_first_tail_x8_r0_body.mctl182 PRE_first_tail_x8_r0_body.mstack182 PRE_first_tail_x8_r0_body.mjobs182 PRE_first_tail_x8_r0_body.mffi182 PRE_first_tail_x8_r0_body.mtrace182 PRE_first_tail_x8_r0_body.mstores182 h

def PRE_first_tail_x8_r0_body.arrEl182_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE182_2665 : arrOf PRE_first_tail_x8_r0_body.s1754 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl182_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA182_2665 : isArrB PRE_first_tail_x8_r0_body.s1754 2665 = true
theorem PRE_first_tail_x8_r0_body.arr182_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1754.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl182_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE182_2665 PRE_first_tail_x8_r0_body.arrA182_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN182_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl182_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR182_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl182_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN182_2665

def PRE_first_tail_x8_r0_body.arrEl182_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE182_2673467 : arrOf PRE_first_tail_x8_r0_body.s1754 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl182_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA182_2673467 : isArrB PRE_first_tail_x8_r0_body.s1754 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr182_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1754.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl182_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE182_2673467 PRE_first_tail_x8_r0_body.arrA182_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN182_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl182_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR182_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl182_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN182_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k182 : isArrB PRE_first_tail_x8_r0_body.s1754 4910 = false
theorem PRE_first_tail_x8_r0_body.keep182 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1754 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k182 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr182_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl182_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ182
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 182 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1753`, the merged
state `PRE_first_tail_x8_r0_body.s1754`, the canonical state `PRE_first_tail_x8_r0_body.s1755`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl182 : PRE_first_tail_x8_r0_body.pl182.all (Nat.ble PRE_first_tail_x8_r0_body.s1753.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd182 : nodupT PRE_first_tail_x8_r0_body.pl182 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1182 : Nat.ble PRE_first_tail_x8_r0_body.s1753.next 2817532 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst182 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1753.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn182 : PRE_first_tail_x8_r0_body.s1755.next = PRE_first_tail_x8_r0_body.s1753.next + PRE_first_tail_x8_r0_body.pl182.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn182 : PRE_first_tail_x8_r0_body.s1754.next = 2817532
kernel_rfl PRE_first_tail_x8_r0_body.zgrow182 : Nat.ble PRE_first_tail_x8_r0_body.s1755.next PRE_first_tail_x8_r0_body.s1754.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh182 : PRE_first_tail_x8_r0_body.S1753.tab.all (fun e => PRE_first_tail_x8_r0_body.cws182.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd182 : nodupT PRE_first_tail_x8_r0_body.cws182 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi182 : PRE_first_tail_x8_r0_body.nr182.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1754.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt182 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1753.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg182_2665 : PRE_first_tail_x8_r0_body.s1755.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1755 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk182_2665 : (objOf PRE_first_tail_x8_r0_body.s1755 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm182_2665 : PRE_first_tail_x8_r0_body.s1754.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa182.obj (objOf PRE_first_tail_x8_r0_body.s1755 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1754 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg182_2673467 : PRE_first_tail_x8_r0_body.s1755.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1755 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk182_2673467 : (objOf PRE_first_tail_x8_r0_body.s1755 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm182_2673467 : PRE_first_tail_x8_r0_body.s1754.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa182.obj (objOf PRE_first_tail_x8_r0_body.s1755 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1754 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw182_4910 : (PRE_first_tail_x8_r0_body.s1755.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw182_2673472 : (PRE_first_tail_x8_r0_body.s1755.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw182_2673473 : (PRE_first_tail_x8_r0_body.s1755.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd182 : PRE_first_tail_x8_r0_body.cl182.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr182 : PRE_first_tail_x8_r0_body.st182.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1753.next || PRE_first_tail_x8_r0_body.cl182.contains b) = true
def PRE_first_tail_x8_r0_body.zl182 : List Nat := PRE_first_tail_x8_r0_body.cl182.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE182 : PRE_first_tail_x8_r0_body.zl182.map (fun a => PRE_first_tail_x8_r0_body.s1754.heap.get (PRE_first_tail_x8_r0_body.kappa182.a a)) = PRE_first_tail_x8_r0_body.zl182.map (fun a => (PRE_first_tail_x8_r0_body.s1755.heap.get a).map PRE_first_tail_x8_r0_body.kappa182.hobj)
theorem PRE_first_tail_x8_r0_body.zimg182 : HeapImg PRE_first_tail_x8_r0_body.kappa182 PRE_first_tail_x8_r0_body.s1755 PRE_first_tail_x8_r0_body.s1754 PRE_first_tail_x8_r0_body.zl182 := PRE_first_tail_x8_r0_body.zimgE182
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl182 : PRE_first_tail_x8_r0_body.s1754.ctl = PRE_first_tail_x8_r0_body.kappa182.ctl PRE_first_tail_x8_r0_body.s1755.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack182 : PRE_first_tail_x8_r0_body.s1754.stack = PRE_first_tail_x8_r0_body.s1755.stack.map PRE_first_tail_x8_r0_body.kappa182.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs182 : PRE_first_tail_x8_r0_body.s1754.jobs = PRE_first_tail_x8_r0_body.s1755.jobs.map PRE_first_tail_x8_r0_body.kappa182.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores182 : PRE_first_tail_x8_r0_body.s1754.stores = PRE_first_tail_x8_r0_body.kappa182.stores PRE_first_tail_x8_r0_body.s1755.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots182 : checkRootsSupp PRE_first_tail_x8_r0_body.s1755 7834 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC182 : PRE_first_tail_x8_r0_body.S1753.tab.length + PRE_first_tail_x8_r0_body.cws182.length = 7834
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap182 : PRE_first_tail_x8_r0_body.kappa182 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1753.next 2817532 PRE_first_tail_x8_r0_body.S1753.tab.length PRE_first_tail_x8_r0_body.pl182 (PRE_first_tail_x8_r0_body.nr182.map NumV.ref) PRE_first_tail_x8_r0_body.kd182.big
  PRE_first_tail_x8_r0_body.kd182.region PRE_first_tail_x8_r0_body.kd182.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin182 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1755.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc182 : Conv.jcleanListB (⟨21779, 18877, 2817512, 7834⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1755 PRE_first_tail_x8_r0_body.cl182 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB182 : noBigRootsP (fun i => !Conv.oldBigB (⟨21779, 18877, 2817512, 7834⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1755.trace PRE_first_tail_x8_r0_body.s1755 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm182 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18877 = true
theorem PRE_first_tail_x8_r0_body.cjcl182 (h : Conv.JClean (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1753) : Conv.JClean (⟨21779, 18877, 2817512, 7834⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1755 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle182)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap182 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd182 a ha)) PRE_first_tail_x8_r0_body.zjc182

end Host.Load.Run.Tpl
end

section -- st182/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st182.bodyLast from PRE_first_tail_x8_r0_body.st182.s1 to PRE_first_tail_x8_r0_body.st182.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st182.F PRE_first_tail_x8_r0_body.st182.s1).run PRE_first_tail_x8_r0_body.st182.S1 = some (PRE_first_tail_x8_r0_body.st182.s2, PRE_first_tail_x8_r0_body.st182.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st182.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st182.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st182.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st182.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st182/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st182.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st182.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st182.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st182.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st182.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st182.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st182.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st182.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st182.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st182.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st182.s0 PRE_first_tail_x8_r0_body.st182.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st182.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st182.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st182.s1 PRE_first_tail_x8_r0_body.st182.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st182/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st182.bodyK0F from PRE_first_tail_x8_r0_body.st182.s0 to PRE_first_tail_x8_r0_body.st182.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st182.F (PRE_first_tail_x8_r0_body.st182.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st182.ks 0).getD 0) PRE_first_tail_x8_r0_body.st182.s0 PRE_first_tail_x8_r0_body.st182.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st182.s1, PRE_first_tail_x8_r0_body.st182.S1)
theorem PRE_first_tail_x8_r0_body.st182.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st182.F (PRE_first_tail_x8_r0_body.st182.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st182.ks 0).getD 0) PRE_first_tail_x8_r0_body.st182.s0 PRE_first_tail_x8_r0_body.st182.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st182.s1, PRE_first_tail_x8_r0_body.st182.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st182.bodyOkLN_ok PRE_first_tail_x8_r0_body.st182.bodyK0F
end Host.Load.Run.Tpl
end

section -- st182/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st182.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st182.F (PRE_first_tail_x8_r0_body.st182.bodyOkL bytes rows) 214 PRE_first_tail_x8_r0_body.st182.s0 PRE_first_tail_x8_r0_body.st182.S0 = some (PRE_first_tail_x8_r0_body.st182.s1, PRE_first_tail_x8_r0_body.st182.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st182.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st182.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st182.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st182.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st182.F (PRE_first_tail_x8_r0_body.st182.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st182.s0
  S0 := PRE_first_tail_x8_r0_body.st182.S0
  s1 := PRE_first_tail_x8_r0_body.st182.s1
  S1 := PRE_first_tail_x8_r0_body.st182.S1
  s2 := PRE_first_tail_x8_r0_body.st182.s2
  S2 := PRE_first_tail_x8_r0_body.st182.S2
  n := 214
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st182.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st182.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st182.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st182.bodyHalt
  last := PRE_first_tail_x8_r0_body.st182.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st182.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC183
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 183 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1772` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa183` into the merged state
`PRE_first_tail_x8_r0_body.s1771`. -/

def PRE_first_tail_x8_r0_body.pl183 : List Nat := [2820099, 2819274, 2820105, 2820101, 2819276, 2820107]
def PRE_first_tail_x8_r0_body.nr183 : List Nat := [7937, 7936, 7912, 7920, 7925, 7930, 7935, 7909, 7910, 7911, 7918, 7919, 7907, 7914, 7915, 7916, 7917, 7913]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd183 : RData :=
  ⟨2818993, 2820142, Stage.setAll PTrie.nil [(2818987, 2820099), (2818988, 2819274), (2818989, 2820105), (2818990, 2820101), (2818991, 2819276), (2818992, 2820107)], Stage.setAll PTrie.nil [(21813, 21839), (21814, 21817), (21815, 21840)],
   21816, 21841, 18923, 18923, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(7907, .ref 7937), (7908, .ref 7936), (7909, .ref 7912), (7910, .ref 7920), (7911, .ref 7925), (7912, .ref 7930), (7913, .ref 7935), (7914, .ref 7909), (7915, .ref 7910), (7916, .ref 7911), (7917, .ref 7918), (7918, .ref 7919), (7919, .ref 7907), (7920, .ref 7914), (7921, .ref 7915), (7922, .ref 7916), (7923, .ref 7917), (7924, .ref 7913)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa183 : Map :=
  Conv.Map.compact 2818987 2820142 7907 PRE_first_tail_x8_r0_body.pl183 (PRE_first_tail_x8_r0_body.nr183.map NumV.ref) PRE_first_tail_x8_r0_body.kd183.big
    PRE_first_tail_x8_r0_body.kd183.region PRE_first_tail_x8_r0_body.kd183.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws183 : List Nat := [4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135]
noncomputable def PRE_first_tail_x8_r0_body.crs183 : List SymE := PRE_first_tail_x8_r0_body.nr183.map fun r => (nth? PRE_first_tail_x8_r0_body.S1771.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta183 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws183 PRE_first_tail_x8_r0_body.crs183
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB183 : List Nat := [2665, 2672770, 2673467, 2818161, 2818706, 2818962]

kernel_rfl PRE_first_tail_x8_r0_body.ctab183 : PRE_first_tail_x8_r0_body.S1772.tab = PRE_first_tail_x8_r0_body.S1770.tab ++ PRE_first_tail_x8_r0_body.cws183.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace183 : PRE_first_tail_x8_r0_body.s1772.trace = PRE_first_tail_x8_r0_body.s1770.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext183 : PRE_first_tail_x8_r0_body.s1772.next = 2818993
kernel_rfl PRE_first_tail_x8_r0_body.ccounters183 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx.nnext) = (21816, 18923)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue183 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1771.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa183.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp183 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx.tokens.all (bSN 7925) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean183 : Conv.cleanListB 21816 131072 (fun r => Nat.ble 87264 r) PRE_first_tail_x8_r0_body.s1772
    (PRE_first_tail_x8_r0_body.wrB183 ++ (List.range 6).map (2818987 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs183 : bigsOutB 21816 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK183
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl183`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl183 : List Nat := [2665, 2672770, 2673467, 2818161, 2818706, 2818962, 2818987, 2818988, 2818989, 2818990, 2818991, 2818992]
def PRE_first_tail_x8_r0_body.clo183 : List Nat := [21793, 21806, 21812, 21813, 21814, 21815]
def PRE_first_tail_x8_r0_body.cln183 : List Nat := [18896, 18897, 18898, 18899, 18900, 18901, 18902, 18903, 18904, 18905, 18906, 18907, 18908, 18909, 18910, 18911, 18912, 18913, 18914, 18915, 18916, 18917, 18918, 18919, 18920, 18921, 18922]
def PRE_first_tail_x8_r0_body.cli183 : List Nat := [18896, 18897, 18898, 18899, 18900, 18901, 18902, 18903, 18904, 18905, 18906, 18907, 18908, 18909, 18910, 18911, 18912, 18913, 18914, 18915, 18916, 18917, 18918, 18919, 18920, 18921, 18922]
kernel_rfl PRE_first_tail_x8_r0_body.cheap183 : PRE_first_tail_x8_r0_body.s1772.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1770.heap (PRE_first_tail_x8_r0_body.cl183.filterMap fun a => (PRE_first_tail_x8_r0_body.s1772.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe183 : Nat.ble PRE_first_tail_x8_r0_body.s1770.next PRE_first_tail_x8_r0_body.s1772.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP183 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1770 PRE_first_tail_x8_r0_body.s1772 PRE_first_tail_x8_r0_body.cl183 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp183 : Conv.suppListB PRE_first_tail_x8_r0_body.s1772 7925 PRE_first_tail_x8_r0_body.cl183 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound183 : Conv.boundListB PRE_first_tail_x8_r0_body.s1772 PRE_first_tail_x8_r0_body.cl183 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK183 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln183.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK183 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo183.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK183 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli183.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst183 : Conv.sstListB 7925 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx PRE_first_tail_x8_r0_body.cln183 PRE_first_tail_x8_r0_body.clo183 PRE_first_tail_x8_r0_body.cli183 = true

end Host.Load.Run.Tpl
end

section -- SiteCl183
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA183 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo183.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd183 : (PRE_first_tail_x8_r0_body.clo183 ++ PRE_first_tail_x8_r0_body.cln183 ++ PRE_first_tail_x8_r0_body.cli183).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle183 : Conv.Cnt.leB (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) (⟨21816, 18923, 2818993, 7925⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck183 : Conv.ncleanListB (⟨21816, 18923, 2818993, 7925⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx PRE_first_tail_x8_r0_body.clo183 PRE_first_tail_x8_r0_body.cln183 PRE_first_tail_x8_r0_body.cli183 = true
theorem PRE_first_tail_x8_r0_body.cncl183 (h : Conv.NClean (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx) : Conv.NClean (⟨21816, 18923, 2818993, 7925⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle183 PRE_first_tail_x8_r0_body.ckA183 PRE_first_tail_x8_r0_body.cobjsK183 PRE_first_tail_x8_r0_body.cnodesK183 PRE_first_tail_x8_r0_body.citemsK183 PRE_first_tail_x8_r0_body.cbd183 PRE_first_tail_x8_r0_body.cck183

end Host.Load.Run.Tpl
end

section -- SiteS183
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 183 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc183 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P183 : LoadP := PRE_first_tail_x8_r0_body.Pc183.raise 18923
kernel_rfl PRE_first_tail_x8_r0_body.craise183 : Nat.ble PRE_first_tail_x8_r0_body.Pc183.N0 18923 = true
theorem PRE_first_tail_x8_r0_body.raised183 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc183 PRE_first_tail_x8_r0_body.P183 :=
  .inr ⟨18923, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise183, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_183 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_183 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1771.ffi)
def PRE_first_tail_x8_r0_body.khinv183 : PTrie Nat := Stage.setAll PTrie.nil [(21839, 21813), (21817, 21814), (21840, 21815)]
def PRE_first_tail_x8_r0_body.kninv183 : PTrie Nat := Stage.setAll PTrie.nil [(18896, 18896), (18897, 18897), (18898, 18898), (18899, 18899), (18900, 18900), (18901, 18901), (18902, 18902), (18903, 18903), (18904, 18904), (18905, 18905), (18906, 18906), (18907, 18907), (18908, 18908), (18909, 18909), (18910, 18910), (18911, 18911), (18912, 18912), (18913, 18913), (18914, 18914), (18915, 18915), (18916, 18916), (18917, 18917), (18918, 18918), (18919, 18919), (18920, 18920), (18921, 18921), (18922, 18922)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS183 : List Nat := [21793, 21806, 21812, 21813, 21814, 21815, 21816, 21817, 21818, 21819, 21820, 21821, 21822, 21823, 21824, 21825, 21826, 21827, 21828, 21829, 21830, 21831, 21832, 21833, 21834, 21835, 21836, 21837, 21838, 21839, 21840]
def PRE_first_tail_x8_r0_body.cnS183 : List Nat := List.range' 18896 27
def PRE_first_tail_x8_r0_body.ciS183 : List Nat := [] ++ List.range' 18896 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0183 : PRE_first_tail_x8_r0_body.kd183.nh0 = PRE_first_tail_x8_r0_body.cx0_183.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1183 : PRE_first_tail_x8_r0_body.kd183.nh1 = PRE_first_tail_x8_r0_body.cx1_183.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0183 : PRE_first_tail_x8_r0_body.kd183.nn0 = PRE_first_tail_x8_r0_body.cx0_183.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1183 : PRE_first_tail_x8_r0_body.kd183.nn1 = PRE_first_tail_x8_r0_body.cx1_183.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo183 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P183.lo && Nat.ble PRE_first_tail_x8_r0_body.P183.lo PRE_first_tail_x8_r0_body.cx0_183.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P183.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P183.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt183 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_183.mlx.next PRE_first_tail_x8_r0_body.cx1_183.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_183.mlx.nnext PRE_first_tail_x8_r0_body.cx1_183.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband183 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P183.NL && Nat.ble PRE_first_tail_x8_r0_body.P183.NL PRE_first_tail_x8_r0_body.P183.N0 && Nat.ble PRE_first_tail_x8_r0_body.P183.N0 PRE_first_tail_x8_r0_body.cx0_183.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow183 : PRE_first_tail_x8_r0_body.kd183.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren183 : checkRenG PRE_first_tail_x8_r0_body.kd183.hnd PRE_first_tail_x8_r0_body.khinv183 (phB PRE_first_tail_x8_r0_body.cx0_183.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband183 : PRE_first_tail_x8_r0_body.kd183.checkBand PRE_first_tail_x8_r0_body.P183.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos183 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd183.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren183 : checkRenG PRE_first_tail_x8_r0_body.kd183.node PRE_first_tail_x8_r0_body.kninv183 (pnB PRE_first_tail_x8_r0_body.cx0_183.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow183 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd183.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P183.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd183.nodeF j) PRE_first_tail_x8_r0_body.cx1_183.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a183 : PRE_first_tail_x8_r0_body.cx0_183.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b183 : PRE_first_tail_x8_r0_body.cx0_183.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1183 : PRE_first_tail_x8_r0_body.cx1_183.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend183 : PRE_first_tail_x8_r0_body.cx1_183.mlx.pending = PRE_first_tail_x8_r0_body.cx0_183.mlx.pending.map PRE_first_tail_x8_r0_body.kappa183.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh183 : PRE_first_tail_x8_r0_body.cx1_183.mlx.errh = PRE_first_tail_x8_r0_body.cx0_183.mlx.errh.map PRE_first_tail_x8_r0_body.kappa183.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles183 : PRE_first_tail_x8_r0_body.cx1_183.mlx.files = PRE_first_tail_x8_r0_body.cx0_183.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch183 : PRE_first_tail_x8_r0_body.cx1_183.mlx.arch = PRE_first_tail_x8_r0_body.cx0_183.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes183 : PRE_first_tail_x8_r0_body.cx1_183.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_183.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired183 : PRE_first_tail_x8_r0_body.cx1_183.mlx.wired = PRE_first_tail_x8_r0_body.cx0_183.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost183 : PRE_first_tail_x8_r0_body.cx1_183.host = PRE_first_tail_x8_r0_body.cx0_183.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd183`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0183 : PRE_first_tail_x8_r0_body.kd183.n0 = 2818993
kernel_rfl PRE_first_tail_x8_r0_body.ckn1183 : PRE_first_tail_x8_r0_body.kd183.n1 = 2820142
kernel_rfl PRE_first_tail_x8_r0_body.ckheap183 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd183.heap).all (fun x => Nat.ble 2818987 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl183 : (List.range 6).all (fun j => decide (PRE_first_tail_x8_r0_body.kd183.heap.get (2818987 + j) = nth? PRE_first_tail_x8_r0_body.pl183 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja183 : Nat.ble 2818987 2818987 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn183 : Nat.ble 7907 7907 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD183 : Nat.ble 2818987 PRE_first_tail_x8_r0_body.kd183.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn183 : Nat.ble 21813 PRE_first_tail_x8_r0_body.kd183.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn183 : Nat.ble 18896 PRE_first_tail_x8_r0_body.kd183.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb183 : Nat.ble 21813 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap183 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd183.heap).all (Nat.ble (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd183 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd183.hnd).all (Nat.ble (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode183 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd183.node).all (Nat.ble (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix183 : Conv.FixOld (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa183 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja183) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn183) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD183) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn183) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn183) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb183) PRE_first_tail_x8_r0_body.fheap183 PRE_first_tail_x8_r0_body.fhnd183 PRE_first_tail_x8_r0_body.fnode183
kernel_rfl PRE_first_tail_x8_r0_body.fcxn183 : (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn183 : (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0183 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_183.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_183.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk183 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd183.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A183 : PRE_first_tail_x8_r0_body.cx1_183.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS183.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_183.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O183 : PRE_first_tail_x8_r0_body.cx1_183.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS183.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_183.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N183 : PRE_first_tail_x8_r0_body.cx1_183.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS183.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_183.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I183 : PRE_first_tail_x8_r0_body.cx1_183.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS183.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_183.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd183 : (PRE_first_tail_x8_r0_body.clo183 ++ PRE_first_tail_x8_r0_body.cln183 ++ PRE_first_tail_x8_r0_body.cli183 ++ PRE_first_tail_x8_r0_body.cwS183 ++ PRE_first_tail_x8_r0_body.cnS183 ++ PRE_first_tail_x8_r0_body.ciS183).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW183 : PRE_first_tail_x8_r0_body.cwS183.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo183.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI183 : PRE_first_tail_x8_r0_body.ciS183.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli183.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN183 : PRE_first_tail_x8_r0_body.cnS183.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF183 : PRE_first_tail_x8_r0_body.cln183.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh183 : PRE_first_tail_x8_r0_body.clo183.all (handleOK PRE_first_tail_x8_r0_body.kappa183 PRE_first_tail_x8_r0_body.P183.lo PRE_first_tail_x8_r0_body.cx0_183.mlx PRE_first_tail_x8_r0_body.cx1_183.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo183 : PRE_first_tail_x8_r0_body.clo183.map (fun h => PRE_first_tail_x8_r0_body.cx1_183.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa183.handle h)) = PRE_first_tail_x8_r0_body.clo183.map (fun h => (PRE_first_tail_x8_r0_body.cx0_183.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa183.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok183 : PRE_first_tail_x8_r0_body.clo183.all (objOK PRE_first_tail_x8_r0_body.kappa183 PRE_first_tail_x8_r0_body.P183.NL PRE_first_tail_x8_r0_body.cx0_183.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd183 : PRE_first_tail_x8_r0_body.cln183.all (nodeOKF PRE_first_tail_x8_r0_body.kappa183 PRE_first_tail_x8_r0_body.P183 PRE_first_tail_x8_r0_body.cx0_183.mlx PRE_first_tail_x8_r0_body.cx1_183.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp183 : ((PRE_first_tail_x8_r0_body.cln183.filter (fullB PRE_first_tail_x8_r0_body.P183))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_183.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa183.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln183.filter (fullB PRE_first_tail_x8_r0_body.P183))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_183.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa183.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI183 : incrB PRE_first_tail_x8_r0_body.kd183.nodeF (List.range' 18896 27) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK183 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd183.node).all (fun k => Nat.ble 18896 k && Nat.blt k 18923) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL183 : (PRE_first_tail_x8_r0_body.cln183.filter (Nat.ble PRE_first_tail_x8_r0_body.P183.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd183.nodeF i) && (Nat.blt i 18923 || Nat.ble PRE_first_tail_x8_r0_body.kd183.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord183 : (PRE_first_tail_x8_r0_body.cln183.filter (Nat.ble PRE_first_tail_x8_r0_body.P183.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd183.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd183.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd183.nodeF j) (PRE_first_tail_x8_r0_body.kd183.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow183 PRE_first_tail_x8_r0_body.cnn1183 PRE_first_tail_x8_r0_body.fnordI183 PRE_first_tail_x8_r0_body.fnordK183 PRE_first_tail_x8_r0_body.fnordL183
kernel_rfl PRE_first_tail_x8_r0_body.fi183 : PRE_first_tail_x8_r0_body.cli183.all (pnB PRE_first_tail_x8_r0_body.cx0_183.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii183 : PRE_first_tail_x8_r0_body.cli183.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_183.mlx.items.get (PRE_first_tail_x8_r0_body.kappa183.node k) = (PRE_first_tail_x8_r0_body.cx0_183.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa183.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot183 (clean : Conv.NClean (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P183.NL) (cl : SSt (· < 7925) PRE_first_tail_x8_r0_body.cx0_183.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P183 7925 PRE_first_tail_x8_r0_body.kappa183 PRE_first_tail_x8_r0_body.kd183 PRE_first_tail_x8_r0_body.khinv183 PRE_first_tail_x8_r0_body.kninv183 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx PRE_first_tail_x8_r0_body.cx0_183.mlx PRE_first_tail_x8_r0_body.cx1_183.mlx (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo183 PRE_first_tail_x8_r0_body.cln183 PRE_first_tail_x8_r0_body.cli183 PRE_first_tail_x8_r0_body.cwS183 PRE_first_tail_x8_r0_body.cnS183 PRE_first_tail_x8_r0_body.ciS183 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0183, PRE_first_tail_x8_r0_body.cnh1183, PRE_first_tail_x8_r0_body.cnn0183, PRE_first_tail_x8_r0_body.cnn1183, PRE_first_tail_x8_r0_body.cplo183, PRE_first_tail_x8_r0_body.ccnt183, PRE_first_tail_x8_r0_body.cnband183, PRE_first_tail_x8_r0_body.chbelow183, PRE_first_tail_x8_r0_body.chren183, PRE_first_tail_x8_r0_body.cband183, PRE_first_tail_x8_r0_body.cnh1pos183, PRE_first_tail_x8_r0_body.cnren183, PRE_first_tail_x8_r0_body.cnlow183, PRE_first_tail_x8_r0_body.cabs0a183, PRE_first_tail_x8_r0_body.cabs0b183, PRE_first_tail_x8_r0_body.ctok1183, PRE_first_tail_x8_r0_body.cpend183, PRE_first_tail_x8_r0_body.cerrh183, PRE_first_tail_x8_r0_body.cfiles183, PRE_first_tail_x8_r0_body.carch183, PRE_first_tail_x8_r0_body.csizes183, PRE_first_tail_x8_r0_body.cwired183, PRE_first_tail_x8_r0_body.cfix183, clean, PRE_first_tail_x8_r0_body.fcxn183, PRE_first_tail_x8_r0_body.fcnn183, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0183, PRE_first_tail_x8_r0_body.fnk183, PRE_first_tail_x8_r0_body.ckA183, PRE_first_tail_x8_r0_body.cobjsK183, PRE_first_tail_x8_r0_body.cnodesK183, PRE_first_tail_x8_r0_body.citemsK183, PRE_first_tail_x8_r0_body.f1A183, PRE_first_tail_x8_r0_body.f1O183, PRE_first_tail_x8_r0_body.f1N183, PRE_first_tail_x8_r0_body.f1I183, PRE_first_tail_x8_r0_body.fbd183, PRE_first_tail_x8_r0_body.fincW183, PRE_first_tail_x8_r0_body.fincI183, PRE_first_tail_x8_r0_body.fincN183, PRE_first_tail_x8_r0_body.flnF183, PRE_first_tail_x8_r0_body.fh183, PRE_first_tail_x8_r0_body.fo183, PRE_first_tail_x8_r0_body.fok183, PRE_first_tail_x8_r0_body.fnd183, PRE_first_tail_x8_r0_body.fp183, PRE_first_tail_x8_r0_body.fnord183, PRE_first_tail_x8_r0_body.fi183, PRE_first_tail_x8_r0_body.fii183⟩
theorem PRE_first_tail_x8_r0_body.cnshift183 (clean : Conv.NClean (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P183.NL) (cl : SSt (· < 7925) PRE_first_tail_x8_r0_body.cx0_183.mlx) : NShift PRE_first_tail_x8_r0_body.P183 7925 PRE_first_tail_x8_r0_body.kappa183 PRE_first_tail_x8_r0_body.cx0_183 PRE_first_tail_x8_r0_body.cx1_183 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot183 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost183 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0183 PRE_first_tail_x8_r0_body.ckn1183 PRE_first_tail_x8_r0_body.ckheap183 PRE_first_tail_x8_r0_body.ckpl183)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_183 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1770.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_183 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1770.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_183 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1770.ffi) = some PRE_first_tail_x8_r0_body.fxC_183
kernel_rfl PRE_first_tail_x8_r0_body.okrC_183 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1770.ffi) = some PRE_first_tail_x8_r0_body.krC_183
noncomputable def PRE_first_tail_x8_r0_body.fx0_183 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1772.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_183 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1772.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_183 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1772.ffi) = some PRE_first_tail_x8_r0_body.fx0_183
kernel_rfl PRE_first_tail_x8_r0_body.okr0_183 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1772.ffi) = some PRE_first_tail_x8_r0_body.kr0_183
noncomputable def PRE_first_tail_x8_r0_body.fx1_183 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1771.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_183 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1771.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_183 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1771.ffi) = some PRE_first_tail_x8_r0_body.fx1_183
kernel_rfl PRE_first_tail_x8_r0_body.okr1_183 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1771.ffi) = some PRE_first_tail_x8_r0_body.kr1_183
kernel_rfl PRE_first_tail_x8_r0_body.ff0183 : PRE_first_tail_x8_r0_body.fx0_183 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_183 (PRE_first_tail_x8_r0_body.clo183.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_183.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1183 : PRE_first_tail_x8_r0_body.fx1_183 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_183 (PRE_first_tail_x8_r0_body.cwS183.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_183.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck183 : freedLB PRE_first_tail_x8_r0_body.kappa183 PRE_first_tail_x8_r0_body.cx0_183.mlx PRE_first_tail_x8_r0_body.fx0_183 PRE_first_tail_x8_r0_body.fx1_183 PRE_first_tail_x8_r0_body.clo183 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0183 : PRE_first_tail_x8_r0_body.kr0_183.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_183.flags (PRE_first_tail_x8_r0_body.clo183.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_183.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0183 : PRE_first_tail_x8_r0_body.kr0_183.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_183.targs (PRE_first_tail_x8_r0_body.clo183.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_183.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1183 : PRE_first_tail_x8_r0_body.kr1_183.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_183.flags (PRE_first_tail_x8_r0_body.cwS183.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_183.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1183 : PRE_first_tail_x8_r0_body.kr1_183.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_183.targs (PRE_first_tail_x8_r0_body.cwS183.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_183.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck183 : krecLB PRE_first_tail_x8_r0_body.kappa183 7925 PRE_first_tail_x8_r0_body.cx0_183.mlx PRE_first_tail_x8_r0_body.kr0_183 PRE_first_tail_x8_r0_body.kr1_183 PRE_first_tail_x8_r0_body.clo183 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn183 : Nat.ble 7907 7925 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge183 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1771.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1772.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR183 : pendRegB PRE_first_tail_x8_r0_body.kappa183 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe183 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1772.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1771.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift183 (clean : Conv.NClean (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P183.NL) (cl : SSt (· < 7925) PRE_first_tail_x8_r0_body.cx0_183.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_183.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_183.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_183.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1770.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_183.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P183 7925 PRE_first_tail_x8_r0_body.kappa183 PRE_first_tail_x8_r0_body.s1772.ffi PRE_first_tail_x8_r0_body.s1771.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift183 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue183, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp183 t ht),
    PRE_first_tail_x8_r0_body.cbridge183,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1772.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1771.ffi) (PRE_first_tail_x8_r0_body.cfoot183 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_183 PRE_first_tail_x8_r0_body.ofx1_183 hobjC PRE_first_tail_x8_r0_body.ff0183 PRE_first_tail_x8_r0_body.ff1183 PRE_first_tail_x8_r0_body.ffck183,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1772.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1771.ffi) (PRE_first_tail_x8_r0_body.cfoot183 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_183 PRE_first_tail_x8_r0_body.okr1_183 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn183) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0183 PRE_first_tail_x8_r0_body.fkt0183 PRE_first_tail_x8_r0_body.fkf1183 PRE_first_tail_x8_r0_body.fkt1183 PRE_first_tail_x8_r0_body.fkck183,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0183 PRE_first_tail_x8_r0_body.cnh1183 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe183) PRE_first_tail_x8_r0_body.cpendR183⟩

end Host.Load.Run.Tpl
end

section -- st183/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st183 0
host_stream_state PRE_first_tail_x8_r0_body.st183 1
host_stream_state PRE_first_tail_x8_r0_body.st183 2
host_stream_state PRE_first_tail_x8_r0_body.st183 3
host_stream_state PRE_first_tail_x8_r0_body.st183 4
host_stream_state PRE_first_tail_x8_r0_body.st183 5
end Host.Load.Run.Tpl
end

section -- Site183
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 183 of chain `PRE_first_tail_x8_r0_body`: `ssmW__g183__g184` (`recurWindow`), the call state `PRE_first_tail_x8_r0_body.s1770`, the merged state `PRE_first_tail_x8_r0_body.s1771`,
the site template `PRE_first_tail_x8_r0_body.st183` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1772`: the merge.
The footprint's facts are in `SiteF183`, the compaction's in `SiteC183`, `SiteK183`, `SiteNa183`, `SiteNb183`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso183 : PRE_first_tail_x8_r0_body.st183.s0 = { PRE_first_tail_x8_r0_body.s1770 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs183 : List Frame := PRE_first_tail_x8_r0_body.s1770.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_183 : PRE_first_tail_x8_r0_body.S1770.tab.length = 7907
kernel_rfl PRE_first_tail_x8_r0_body.tab0_183 : PRE_first_tail_x8_r0_body.st183.S0.tab = PRE_first_tail_x8_r0_body.S1770.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws183 : List Nat := [4087, 4088, 4089, 4090, 4091, 4092, 4093, 4094, 4095, 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117]
kernel_rfl PRE_first_tail_x8_r0_body.fresh183 : (PRE_first_tail_x8_r0_body.S1770.tab.all fun e => PRE_first_tail_x8_r0_body.ws183.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1770.oracle.all fun q => PRE_first_tail_x8_r0_body.ws183.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab183 : PRE_first_tail_x8_r0_body.S1771.tab = PRE_first_tail_x8_r0_body.S1770.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws183
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen183 : PRE_first_tail_x8_r0_body.st183.S5.tab.length - PRE_first_tail_x8_r0_body.st183.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged183`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap183 : PRE_first_tail_x8_r0_body.s1771.heap = PRE_first_tail_x8_r0_body.st183.s5.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext183 : PRE_first_tail_x8_r0_body.s1771.next = PRE_first_tail_x8_r0_body.st183.s5.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl183 : PRE_first_tail_x8_r0_body.s1771.ctl = PRE_first_tail_x8_r0_body.st183.s5.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack183 : PRE_first_tail_x8_r0_body.s1771.stack = PRE_first_tail_x8_r0_body.st183.s5.stack ++ PRE_first_tail_x8_r0_body.s1770.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs183 : PRE_first_tail_x8_r0_body.s1771.jobs = PRE_first_tail_x8_r0_body.st183.s5.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi183 : PRE_first_tail_x8_r0_body.s1771.ffi = PRE_first_tail_x8_r0_body.st183.s5.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace183 : PRE_first_tail_x8_r0_body.s1771.trace = PRE_first_tail_x8_r0_body.st183.s5.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores183 : PRE_first_tail_x8_r0_body.s1771.stores = PRE_first_tail_x8_r0_body.st183.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD183
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 183 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived183 : PRE_first_tail_x8_r0_body.nr183.map (fun r => nth? PRE_first_tail_x8_r0_body.st183.S5.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.un .int32 (SymE.un .int32 (SymE.var 10))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))]
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo183 : PRE_first_tail_x8_r0_body.nr183.all (Nat.ble 7907) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj183 : PRE_first_tail_x8_r0_body.cws183.all (fun c => !PRE_first_tail_x8_r0_body.ws183.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ183 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws183 PRE_first_tail_x8_r0_body.crs183 PRE_first_tail_x8_r0_body.ws183

end Host.Load.Run.Tpl
end

section -- st183/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st183`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st183.wrR : List (Nat × Nat) := [(2672770, 2672771), (2818161, 2818162), (2818706, 2818707), (2818962, 2818963)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st183.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st183.s5.heap PRE_first_tail_x8_r0_body.st183.wrR ++ freshOf PRE_first_tail_x8_r0_body.st183.s5.heap PRE_first_tail_x8_r0_body.st183.s0.next PRE_first_tail_x8_r0_body.st183.s5.next
noncomputable def PRE_first_tail_x8_r0_body.st183.wr : List Nat := PRE_first_tail_x8_r0_body.st183.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st183.heapFoot : PRE_first_tail_x8_r0_body.st183.s5.heap = setAll PRE_first_tail_x8_r0_body.st183.s0.heap PRE_first_tail_x8_r0_body.st183.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st183.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st183.s0.next PRE_first_tail_x8_r0_body.st183.s5.next = true
theorem PRE_first_tail_x8_r0_body.st183.grows : PRE_first_tail_x8_r0_body.st183.s0.next ≤ PRE_first_tail_x8_r0_body.st183.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st183.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st183.wh : List Nat := [21793, 21806, 21812, 21813, 21814, 21815, 21816, 21817, 21818, 21819, 21820, 21821, 21822, 21823, 21824, 21825, 21826, 21827, 21828, 21829, 21830, 21831, 21832, 21833, 21834, 21835, 21836, 21837, 21838, 21839, 21840]
def PRE_first_tail_x8_r0_body.st183.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st183.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st183.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st183.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st183.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st183.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st183.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st183.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st183.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st183.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF183
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 183 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB183 : nodupT PRE_first_tail_x8_r0_body.st183.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup183 : PRE_first_tail_x8_r0_body.st183.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB183).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB183 : PRE_first_tail_x8_r0_body.st183.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound183 : ∀ b ∈ PRE_first_tail_x8_r0_body.st183.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB183 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr183 := PRE_first_tail_x8_r0_body.st183.s5.trace.take 120
kernel_rfl PRE_first_tail_x8_r0_body.traceEq183 : PRE_first_tail_x8_r0_body.st183.s5.trace = PRE_first_tail_x8_r0_body.trFr183 ++ PRE_first_tail_x8_r0_body.st183.s0.trace
theorem PRE_first_tail_x8_r0_body.trace183 : ∃ fr, PRE_first_tail_x8_r0_body.st183.s5.trace = fr ++ PRE_first_tail_x8_r0_body.st183.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq183⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide183 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB183 : (PRE_first_tail_x8_r0_body.wide183.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st183.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix183 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide183, WFix Map.id (Present PRE_first_tail_x8_r0_body.st183.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB183 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL183
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 183 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1771`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO183 : PRE_first_tail_x8_r0_body.st183.S0.oracle = PRE_first_tail_x8_r0_body.st183.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B183 : PRE_first_tail_x8_r0_body.st183.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st183.s0.next || (PRE_first_tail_x8_r0_body.st183.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot183 : Conv.StageFoot PRE_first_tail_x8_r0_body.st183.wr PRE_first_tail_x8_r0_body.st183.s0 PRE_first_tail_x8_r0_body.st183.s5 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st183.heapFoot PRE_first_tail_x8_r0_body.wrNodup183 PRE_first_tail_x8_r0_body.wrBound183 PRE_first_tail_x8_r0_body.wr0B183 PRE_first_tail_x8_r0_body.st183.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged183 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st183.F.S → PRE_first_tail_x8_r0_body.st183.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st183.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st183.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs183 PRE_first_tail_x8_r0_body.st183.wr PRE_first_tail_x8_r0_body.s1770 PRE_first_tail_x8_r0_body.st183.s5 PRE_first_tail_x8_r0_body.st183.s0
      PRE_first_tail_x8_r0_body.st183.s5.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st183.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1771 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso183 PRE_first_tail_x8_r0_body.stFoot183 PRE_first_tail_x8_r0_body.wrNodup183 PRE_first_tail_x8_r0_body.wrBound183 PRE_first_tail_x8_r0_body.trace183 PRE_first_tail_x8_r0_body.mheap183
    PRE_first_tail_x8_r0_body.mnext183 PRE_first_tail_x8_r0_body.mctl183 PRE_first_tail_x8_r0_body.mstack183 PRE_first_tail_x8_r0_body.mjobs183 PRE_first_tail_x8_r0_body.mffi183 PRE_first_tail_x8_r0_body.mtrace183 PRE_first_tail_x8_r0_body.mstores183 h

def PRE_first_tail_x8_r0_body.arrEl183_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE183_2665 : arrOf PRE_first_tail_x8_r0_body.s1771 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl183_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA183_2665 : isArrB PRE_first_tail_x8_r0_body.s1771 2665 = true
theorem PRE_first_tail_x8_r0_body.arr183_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1771.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl183_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE183_2665 PRE_first_tail_x8_r0_body.arrA183_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN183_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl183_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR183_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl183_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN183_2665

def PRE_first_tail_x8_r0_body.arrEl183_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE183_2673467 : arrOf PRE_first_tail_x8_r0_body.s1771 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl183_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA183_2673467 : isArrB PRE_first_tail_x8_r0_body.s1771 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr183_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1771.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl183_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE183_2673467 PRE_first_tail_x8_r0_body.arrA183_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN183_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl183_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR183_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl183_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN183_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k183 : isArrB PRE_first_tail_x8_r0_body.s1771 4910 = false
theorem PRE_first_tail_x8_r0_body.keep183 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1771 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k183 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr183_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl183_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ183
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 183 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1770`, the merged
state `PRE_first_tail_x8_r0_body.s1771`, the canonical state `PRE_first_tail_x8_r0_body.s1772`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl183 : PRE_first_tail_x8_r0_body.pl183.all (Nat.ble PRE_first_tail_x8_r0_body.s1770.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd183 : nodupT PRE_first_tail_x8_r0_body.pl183 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1183 : Nat.ble PRE_first_tail_x8_r0_body.s1770.next 2820142 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst183 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1770.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn183 : PRE_first_tail_x8_r0_body.s1772.next = PRE_first_tail_x8_r0_body.s1770.next + PRE_first_tail_x8_r0_body.pl183.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn183 : PRE_first_tail_x8_r0_body.s1771.next = 2820142
kernel_rfl PRE_first_tail_x8_r0_body.zgrow183 : Nat.ble PRE_first_tail_x8_r0_body.s1772.next PRE_first_tail_x8_r0_body.s1771.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh183 : PRE_first_tail_x8_r0_body.S1770.tab.all (fun e => PRE_first_tail_x8_r0_body.cws183.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd183 : nodupT PRE_first_tail_x8_r0_body.cws183 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi183 : PRE_first_tail_x8_r0_body.nr183.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1771.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt183 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1770.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg183_2665 : PRE_first_tail_x8_r0_body.s1772.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1772 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk183_2665 : (objOf PRE_first_tail_x8_r0_body.s1772 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm183_2665 : PRE_first_tail_x8_r0_body.s1771.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa183.obj (objOf PRE_first_tail_x8_r0_body.s1772 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1771 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg183_2673467 : PRE_first_tail_x8_r0_body.s1772.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1772 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk183_2673467 : (objOf PRE_first_tail_x8_r0_body.s1772 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm183_2673467 : PRE_first_tail_x8_r0_body.s1771.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa183.obj (objOf PRE_first_tail_x8_r0_body.s1772 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1771 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw183_4910 : (PRE_first_tail_x8_r0_body.s1772.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw183_2673472 : (PRE_first_tail_x8_r0_body.s1772.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw183_2673473 : (PRE_first_tail_x8_r0_body.s1772.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd183 : PRE_first_tail_x8_r0_body.cl183.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr183 : PRE_first_tail_x8_r0_body.st183.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1770.next || PRE_first_tail_x8_r0_body.cl183.contains b) = true
def PRE_first_tail_x8_r0_body.zl183 : List Nat := PRE_first_tail_x8_r0_body.cl183.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE183 : PRE_first_tail_x8_r0_body.zl183.map (fun a => PRE_first_tail_x8_r0_body.s1771.heap.get (PRE_first_tail_x8_r0_body.kappa183.a a)) = PRE_first_tail_x8_r0_body.zl183.map (fun a => (PRE_first_tail_x8_r0_body.s1772.heap.get a).map PRE_first_tail_x8_r0_body.kappa183.hobj)
theorem PRE_first_tail_x8_r0_body.zimg183 : HeapImg PRE_first_tail_x8_r0_body.kappa183 PRE_first_tail_x8_r0_body.s1772 PRE_first_tail_x8_r0_body.s1771 PRE_first_tail_x8_r0_body.zl183 := PRE_first_tail_x8_r0_body.zimgE183
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl183 : PRE_first_tail_x8_r0_body.s1771.ctl = PRE_first_tail_x8_r0_body.kappa183.ctl PRE_first_tail_x8_r0_body.s1772.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack183 : PRE_first_tail_x8_r0_body.s1771.stack = PRE_first_tail_x8_r0_body.s1772.stack.map PRE_first_tail_x8_r0_body.kappa183.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs183 : PRE_first_tail_x8_r0_body.s1771.jobs = PRE_first_tail_x8_r0_body.s1772.jobs.map PRE_first_tail_x8_r0_body.kappa183.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores183 : PRE_first_tail_x8_r0_body.s1771.stores = PRE_first_tail_x8_r0_body.kappa183.stores PRE_first_tail_x8_r0_body.s1772.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots183 : checkRootsSupp PRE_first_tail_x8_r0_body.s1772 7925 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC183 : PRE_first_tail_x8_r0_body.S1770.tab.length + PRE_first_tail_x8_r0_body.cws183.length = 7925
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap183 : PRE_first_tail_x8_r0_body.kappa183 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1770.next 2820142 PRE_first_tail_x8_r0_body.S1770.tab.length PRE_first_tail_x8_r0_body.pl183 (PRE_first_tail_x8_r0_body.nr183.map NumV.ref) PRE_first_tail_x8_r0_body.kd183.big
  PRE_first_tail_x8_r0_body.kd183.region PRE_first_tail_x8_r0_body.kd183.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin183 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1772.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc183 : Conv.jcleanListB (⟨21816, 18923, 2818993, 7925⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1772 PRE_first_tail_x8_r0_body.cl183 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB183 : noBigRootsP (fun i => !Conv.oldBigB (⟨21816, 18923, 2818993, 7925⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1772.trace PRE_first_tail_x8_r0_body.s1772 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm183 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18896 = true
theorem PRE_first_tail_x8_r0_body.cjcl183 (h : Conv.JClean (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1770) : Conv.JClean (⟨21816, 18923, 2818993, 7925⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1772 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle183)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap183 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd183 a ha)) PRE_first_tail_x8_r0_body.zjc183

end Host.Load.Run.Tpl
end

section -- st183/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st183.bodyLast from PRE_first_tail_x8_r0_body.st183.s4 to PRE_first_tail_x8_r0_body.st183.s5 :
  interpS (step PRE_first_tail_x8_r0_body.st183.F PRE_first_tail_x8_r0_body.st183.s4).run PRE_first_tail_x8_r0_body.st183.S4 = some (PRE_first_tail_x8_r0_body.st183.s5, PRE_first_tail_x8_r0_body.st183.S5)
kernel_rfl PRE_first_tail_x8_r0_body.st183.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st183.s4.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st183.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st183.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st183/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st183.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st183.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st183.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st183.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st183.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st183.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st183.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st183.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st183.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st183.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st183.s0 PRE_first_tail_x8_r0_body.st183.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st183.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st183.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st183.s4 PRE_first_tail_x8_r0_body.st183.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st183/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st183.bodyK0F from PRE_first_tail_x8_r0_body.st183.s0 to PRE_first_tail_x8_r0_body.st183.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st183.F (PRE_first_tail_x8_r0_body.st183.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st183.ks 0).getD 0) PRE_first_tail_x8_r0_body.st183.s0 PRE_first_tail_x8_r0_body.st183.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st183.s1, PRE_first_tail_x8_r0_body.st183.S1)
theorem PRE_first_tail_x8_r0_body.st183.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st183.F (PRE_first_tail_x8_r0_body.st183.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st183.ks 0).getD 0) PRE_first_tail_x8_r0_body.st183.s0 PRE_first_tail_x8_r0_body.st183.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st183.s1, PRE_first_tail_x8_r0_body.st183.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st183.bodyOkLN_ok PRE_first_tail_x8_r0_body.st183.bodyK0F
end Host.Load.Run.Tpl
end

section -- st183/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st183.bodyK1F from PRE_first_tail_x8_r0_body.st183.s1 to PRE_first_tail_x8_r0_body.st183.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st183.F (PRE_first_tail_x8_r0_body.st183.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st183.ks 1).getD 0) PRE_first_tail_x8_r0_body.st183.s1 PRE_first_tail_x8_r0_body.st183.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st183.s2, PRE_first_tail_x8_r0_body.st183.S2)
theorem PRE_first_tail_x8_r0_body.st183.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st183.F (PRE_first_tail_x8_r0_body.st183.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st183.ks 1).getD 0) PRE_first_tail_x8_r0_body.st183.s1 PRE_first_tail_x8_r0_body.st183.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st183.s2, PRE_first_tail_x8_r0_body.st183.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st183.bodyOkLN_ok PRE_first_tail_x8_r0_body.st183.bodyK1F
end Host.Load.Run.Tpl
end

section -- st183/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st183.bodyK2F from PRE_first_tail_x8_r0_body.st183.s2 to PRE_first_tail_x8_r0_body.st183.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st183.F (PRE_first_tail_x8_r0_body.st183.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st183.ks 2).getD 0) PRE_first_tail_x8_r0_body.st183.s2 PRE_first_tail_x8_r0_body.st183.S2) = fun _ _ => some (PRE_first_tail_x8_r0_body.st183.s3, PRE_first_tail_x8_r0_body.st183.S3)
theorem PRE_first_tail_x8_r0_body.st183.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st183.F (PRE_first_tail_x8_r0_body.st183.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st183.ks 2).getD 0) PRE_first_tail_x8_r0_body.st183.s2 PRE_first_tail_x8_r0_body.st183.S2) = fun _ _ => some (PRE_first_tail_x8_r0_body.st183.s3, PRE_first_tail_x8_r0_body.st183.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st183.bodyOkLN_ok PRE_first_tail_x8_r0_body.st183.bodyK2F
end Host.Load.Run.Tpl
end

section -- st183/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st183.bodyK3F from PRE_first_tail_x8_r0_body.st183.s3 to PRE_first_tail_x8_r0_body.st183.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st183.F (PRE_first_tail_x8_r0_body.st183.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st183.ks 3).getD 0) PRE_first_tail_x8_r0_body.st183.s3 PRE_first_tail_x8_r0_body.st183.S3) = fun _ _ => some (PRE_first_tail_x8_r0_body.st183.s4, PRE_first_tail_x8_r0_body.st183.S4)
theorem PRE_first_tail_x8_r0_body.st183.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st183.F (PRE_first_tail_x8_r0_body.st183.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st183.ks 3).getD 0) PRE_first_tail_x8_r0_body.st183.s3 PRE_first_tail_x8_r0_body.st183.S3) = fun _ _ => some (PRE_first_tail_x8_r0_body.st183.s4, PRE_first_tail_x8_r0_body.st183.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st183.bodyOkLN_ok PRE_first_tail_x8_r0_body.st183.bodyK3F
end Host.Load.Run.Tpl
end

section -- st183/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st183.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st183.F (PRE_first_tail_x8_r0_body.st183.bodyOkL bytes rows) 11334 PRE_first_tail_x8_r0_body.st183.s0 PRE_first_tail_x8_r0_body.st183.S0 = some (PRE_first_tail_x8_r0_body.st183.s4, PRE_first_tail_x8_r0_body.st183.S4) :=
  runOk_trans PRE_first_tail_x8_r0_body.st183.F (PRE_first_tail_x8_r0_body.st183.bodyOkL bytes rows) ((((nth? PRE_first_tail_x8_r0_body.st183.ks 0).getD 0) + ((nth? PRE_first_tail_x8_r0_body.st183.ks 1).getD 0)) + ((nth? PRE_first_tail_x8_r0_body.st183.ks 2).getD 0)) ((nth? PRE_first_tail_x8_r0_body.st183.ks 3).getD 0) PRE_first_tail_x8_r0_body.st183.s0 PRE_first_tail_x8_r0_body.st183.s3 PRE_first_tail_x8_r0_body.st183.s4 PRE_first_tail_x8_r0_body.st183.S0 PRE_first_tail_x8_r0_body.st183.S3 PRE_first_tail_x8_r0_body.st183.S4 (runOk_trans PRE_first_tail_x8_r0_body.st183.F (PRE_first_tail_x8_r0_body.st183.bodyOkL bytes rows) (((nth? PRE_first_tail_x8_r0_body.st183.ks 0).getD 0) + ((nth? PRE_first_tail_x8_r0_body.st183.ks 1).getD 0)) ((nth? PRE_first_tail_x8_r0_body.st183.ks 2).getD 0) PRE_first_tail_x8_r0_body.st183.s0 PRE_first_tail_x8_r0_body.st183.s2 PRE_first_tail_x8_r0_body.st183.s3 PRE_first_tail_x8_r0_body.st183.S0 PRE_first_tail_x8_r0_body.st183.S2 PRE_first_tail_x8_r0_body.st183.S3 (runOk_trans PRE_first_tail_x8_r0_body.st183.F (PRE_first_tail_x8_r0_body.st183.bodyOkL bytes rows) ((nth? PRE_first_tail_x8_r0_body.st183.ks 0).getD 0) ((nth? PRE_first_tail_x8_r0_body.st183.ks 1).getD 0) PRE_first_tail_x8_r0_body.st183.s0 PRE_first_tail_x8_r0_body.st183.s1 PRE_first_tail_x8_r0_body.st183.s2 PRE_first_tail_x8_r0_body.st183.S0 PRE_first_tail_x8_r0_body.st183.S1 PRE_first_tail_x8_r0_body.st183.S2 ((congrFun (congrFun PRE_first_tail_x8_r0_body.st183.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st183.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st183.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st183.bodyK3 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st183.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st183.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st183.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st183.F (PRE_first_tail_x8_r0_body.st183.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st183.s0
  S0 := PRE_first_tail_x8_r0_body.st183.S0
  s1 := PRE_first_tail_x8_r0_body.st183.s4
  S1 := PRE_first_tail_x8_r0_body.st183.S4
  s2 := PRE_first_tail_x8_r0_body.st183.s5
  S2 := PRE_first_tail_x8_r0_body.st183.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st183.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st183.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st183.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st183.bodyHalt
  last := PRE_first_tail_x8_r0_body.st183.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st183.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC184
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 184 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1780` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa184` into the merged state
`PRE_first_tail_x8_r0_body.s1779`. -/

def PRE_first_tail_x8_r0_body.pl184 : List Nat := []
def PRE_first_tail_x8_r0_body.nr184 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd184 : RData :=
  ⟨2819483, 2819485, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21829, 21829, 18936, 18936, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa184 : Map :=
  Conv.Map.compact 2819483 2819485 7946 PRE_first_tail_x8_r0_body.pl184 (PRE_first_tail_x8_r0_body.nr184.map NumV.ref) PRE_first_tail_x8_r0_body.kd184.big
    PRE_first_tail_x8_r0_body.kd184.region PRE_first_tail_x8_r0_body.kd184.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws184 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs184 : List SymE := PRE_first_tail_x8_r0_body.nr184.map fun r => (nth? PRE_first_tail_x8_r0_body.S1779.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta184 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws184 PRE_first_tail_x8_r0_body.crs184
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB184 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab184 : PRE_first_tail_x8_r0_body.S1780.tab = PRE_first_tail_x8_r0_body.S1778.tab ++ PRE_first_tail_x8_r0_body.cws184.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace184 : PRE_first_tail_x8_r0_body.s1780.trace = PRE_first_tail_x8_r0_body.s1778.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext184 : PRE_first_tail_x8_r0_body.s1780.next = 2819483
kernel_rfl PRE_first_tail_x8_r0_body.ccounters184 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx.nnext) = (21829, 18936)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue184 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1779.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa184.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp184 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx.tokens.all (bSN 7946) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean184 : Conv.cleanListB 21829 131072 (fun r => Nat.ble 87316 r) PRE_first_tail_x8_r0_body.s1780
    (PRE_first_tail_x8_r0_body.wrB184 ++ (List.range 0).map (2819483 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs184 : bigsOutB 21829 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK184
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl184`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl184 : List Nat := [2665, 2673467]
def PRE_first_tail_x8_r0_body.clo184 : List Nat := []
def PRE_first_tail_x8_r0_body.cln184 : List Nat := []
def PRE_first_tail_x8_r0_body.cli184 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap184 : PRE_first_tail_x8_r0_body.s1780.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1778.heap (PRE_first_tail_x8_r0_body.cl184.filterMap fun a => (PRE_first_tail_x8_r0_body.s1780.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe184 : Nat.ble PRE_first_tail_x8_r0_body.s1778.next PRE_first_tail_x8_r0_body.s1780.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP184 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1778 PRE_first_tail_x8_r0_body.s1780 PRE_first_tail_x8_r0_body.cl184 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp184 : Conv.suppListB PRE_first_tail_x8_r0_body.s1780 7946 PRE_first_tail_x8_r0_body.cl184 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound184 : Conv.boundListB PRE_first_tail_x8_r0_body.s1780 PRE_first_tail_x8_r0_body.cl184 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK184 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln184.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK184 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo184.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK184 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli184.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst184 : Conv.sstListB 7946 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx PRE_first_tail_x8_r0_body.cln184 PRE_first_tail_x8_r0_body.clo184 PRE_first_tail_x8_r0_body.cli184 = true

end Host.Load.Run.Tpl
end

section -- SiteCl184
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA184 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo184.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd184 : (PRE_first_tail_x8_r0_body.clo184 ++ PRE_first_tail_x8_r0_body.cln184 ++ PRE_first_tail_x8_r0_body.cli184).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle184 : Conv.Cnt.leB (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck184 : Conv.ncleanListB (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx PRE_first_tail_x8_r0_body.clo184 PRE_first_tail_x8_r0_body.cln184 PRE_first_tail_x8_r0_body.cli184 = true
theorem PRE_first_tail_x8_r0_body.cncl184 (h : Conv.NClean (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx) : Conv.NClean (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle184 PRE_first_tail_x8_r0_body.ckA184 PRE_first_tail_x8_r0_body.cobjsK184 PRE_first_tail_x8_r0_body.cnodesK184 PRE_first_tail_x8_r0_body.citemsK184 PRE_first_tail_x8_r0_body.cbd184 PRE_first_tail_x8_r0_body.cck184

end Host.Load.Run.Tpl
end

section -- SiteS184
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 184 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc184 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P184 : LoadP := PRE_first_tail_x8_r0_body.Pc184.raise 18936
kernel_rfl PRE_first_tail_x8_r0_body.craise184 : Nat.ble PRE_first_tail_x8_r0_body.Pc184.N0 18936 = true
theorem PRE_first_tail_x8_r0_body.raised184 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc184 PRE_first_tail_x8_r0_body.P184 :=
  .inr ⟨18936, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise184, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_184 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_184 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1779.ffi)
def PRE_first_tail_x8_r0_body.khinv184 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv184 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS184 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS184 : List Nat := List.range' 18936 0
def PRE_first_tail_x8_r0_body.ciS184 : List Nat := [] ++ List.range' 18936 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0184 : PRE_first_tail_x8_r0_body.kd184.nh0 = PRE_first_tail_x8_r0_body.cx0_184.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1184 : PRE_first_tail_x8_r0_body.kd184.nh1 = PRE_first_tail_x8_r0_body.cx1_184.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0184 : PRE_first_tail_x8_r0_body.kd184.nn0 = PRE_first_tail_x8_r0_body.cx0_184.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1184 : PRE_first_tail_x8_r0_body.kd184.nn1 = PRE_first_tail_x8_r0_body.cx1_184.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo184 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P184.lo && Nat.ble PRE_first_tail_x8_r0_body.P184.lo PRE_first_tail_x8_r0_body.cx0_184.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P184.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P184.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt184 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_184.mlx.next PRE_first_tail_x8_r0_body.cx1_184.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_184.mlx.nnext PRE_first_tail_x8_r0_body.cx1_184.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband184 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P184.NL && Nat.ble PRE_first_tail_x8_r0_body.P184.NL PRE_first_tail_x8_r0_body.P184.N0 && Nat.ble PRE_first_tail_x8_r0_body.P184.N0 PRE_first_tail_x8_r0_body.cx0_184.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow184 : PRE_first_tail_x8_r0_body.kd184.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren184 : checkRenG PRE_first_tail_x8_r0_body.kd184.hnd PRE_first_tail_x8_r0_body.khinv184 (phB PRE_first_tail_x8_r0_body.cx0_184.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband184 : PRE_first_tail_x8_r0_body.kd184.checkBand PRE_first_tail_x8_r0_body.P184.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos184 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd184.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren184 : checkRenG PRE_first_tail_x8_r0_body.kd184.node PRE_first_tail_x8_r0_body.kninv184 (pnB PRE_first_tail_x8_r0_body.cx0_184.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow184 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd184.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P184.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd184.nodeF j) PRE_first_tail_x8_r0_body.cx1_184.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a184 : PRE_first_tail_x8_r0_body.cx0_184.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b184 : PRE_first_tail_x8_r0_body.cx0_184.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1184 : PRE_first_tail_x8_r0_body.cx1_184.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend184 : PRE_first_tail_x8_r0_body.cx1_184.mlx.pending = PRE_first_tail_x8_r0_body.cx0_184.mlx.pending.map PRE_first_tail_x8_r0_body.kappa184.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh184 : PRE_first_tail_x8_r0_body.cx1_184.mlx.errh = PRE_first_tail_x8_r0_body.cx0_184.mlx.errh.map PRE_first_tail_x8_r0_body.kappa184.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles184 : PRE_first_tail_x8_r0_body.cx1_184.mlx.files = PRE_first_tail_x8_r0_body.cx0_184.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch184 : PRE_first_tail_x8_r0_body.cx1_184.mlx.arch = PRE_first_tail_x8_r0_body.cx0_184.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes184 : PRE_first_tail_x8_r0_body.cx1_184.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_184.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired184 : PRE_first_tail_x8_r0_body.cx1_184.mlx.wired = PRE_first_tail_x8_r0_body.cx0_184.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost184 : PRE_first_tail_x8_r0_body.cx1_184.host = PRE_first_tail_x8_r0_body.cx0_184.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd184`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0184 : PRE_first_tail_x8_r0_body.kd184.n0 = 2819483
kernel_rfl PRE_first_tail_x8_r0_body.ckn1184 : PRE_first_tail_x8_r0_body.kd184.n1 = 2819485
kernel_rfl PRE_first_tail_x8_r0_body.ckheap184 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd184.heap).all (fun x => Nat.ble 2819483 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl184 : (List.range 0).all (fun j => decide (PRE_first_tail_x8_r0_body.kd184.heap.get (2819483 + j) = nth? PRE_first_tail_x8_r0_body.pl184 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja184 : Nat.ble 2819483 2819483 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn184 : Nat.ble 7946 7946 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD184 : Nat.ble 2819483 PRE_first_tail_x8_r0_body.kd184.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn184 : Nat.ble 21829 PRE_first_tail_x8_r0_body.kd184.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn184 : Nat.ble 18936 PRE_first_tail_x8_r0_body.kd184.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb184 : Nat.ble 21829 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap184 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd184.heap).all (Nat.ble (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd184 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd184.hnd).all (Nat.ble (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode184 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd184.node).all (Nat.ble (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix184 : Conv.FixOld (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa184 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja184) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn184) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD184) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn184) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn184) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb184) PRE_first_tail_x8_r0_body.fheap184 PRE_first_tail_x8_r0_body.fhnd184 PRE_first_tail_x8_r0_body.fnode184
kernel_rfl PRE_first_tail_x8_r0_body.fcxn184 : (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn184 : (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0184 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_184.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_184.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk184 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd184.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A184 : PRE_first_tail_x8_r0_body.cx1_184.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS184.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_184.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O184 : PRE_first_tail_x8_r0_body.cx1_184.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS184.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_184.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N184 : PRE_first_tail_x8_r0_body.cx1_184.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS184.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_184.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I184 : PRE_first_tail_x8_r0_body.cx1_184.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS184.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_184.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd184 : (PRE_first_tail_x8_r0_body.clo184 ++ PRE_first_tail_x8_r0_body.cln184 ++ PRE_first_tail_x8_r0_body.cli184 ++ PRE_first_tail_x8_r0_body.cwS184 ++ PRE_first_tail_x8_r0_body.cnS184 ++ PRE_first_tail_x8_r0_body.ciS184).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW184 : PRE_first_tail_x8_r0_body.cwS184.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo184.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI184 : PRE_first_tail_x8_r0_body.ciS184.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli184.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN184 : PRE_first_tail_x8_r0_body.cnS184.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF184 : PRE_first_tail_x8_r0_body.cln184.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh184 : PRE_first_tail_x8_r0_body.clo184.all (handleOK PRE_first_tail_x8_r0_body.kappa184 PRE_first_tail_x8_r0_body.P184.lo PRE_first_tail_x8_r0_body.cx0_184.mlx PRE_first_tail_x8_r0_body.cx1_184.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo184 : PRE_first_tail_x8_r0_body.clo184.map (fun h => PRE_first_tail_x8_r0_body.cx1_184.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa184.handle h)) = PRE_first_tail_x8_r0_body.clo184.map (fun h => (PRE_first_tail_x8_r0_body.cx0_184.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa184.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok184 : PRE_first_tail_x8_r0_body.clo184.all (objOK PRE_first_tail_x8_r0_body.kappa184 PRE_first_tail_x8_r0_body.P184.NL PRE_first_tail_x8_r0_body.cx0_184.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd184 : PRE_first_tail_x8_r0_body.cln184.all (nodeOKF PRE_first_tail_x8_r0_body.kappa184 PRE_first_tail_x8_r0_body.P184 PRE_first_tail_x8_r0_body.cx0_184.mlx PRE_first_tail_x8_r0_body.cx1_184.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp184 : ((PRE_first_tail_x8_r0_body.cln184.filter (fullB PRE_first_tail_x8_r0_body.P184))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_184.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa184.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln184.filter (fullB PRE_first_tail_x8_r0_body.P184))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_184.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa184.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI184 : incrB PRE_first_tail_x8_r0_body.kd184.nodeF (List.range' 18936 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK184 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd184.node).all (fun k => Nat.ble 18936 k && Nat.blt k 18936) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL184 : (PRE_first_tail_x8_r0_body.cln184.filter (Nat.ble PRE_first_tail_x8_r0_body.P184.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd184.nodeF i) && (Nat.blt i 18936 || Nat.ble PRE_first_tail_x8_r0_body.kd184.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord184 : (PRE_first_tail_x8_r0_body.cln184.filter (Nat.ble PRE_first_tail_x8_r0_body.P184.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd184.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd184.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd184.nodeF j) (PRE_first_tail_x8_r0_body.kd184.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow184 PRE_first_tail_x8_r0_body.cnn1184 PRE_first_tail_x8_r0_body.fnordI184 PRE_first_tail_x8_r0_body.fnordK184 PRE_first_tail_x8_r0_body.fnordL184
kernel_rfl PRE_first_tail_x8_r0_body.fi184 : PRE_first_tail_x8_r0_body.cli184.all (pnB PRE_first_tail_x8_r0_body.cx0_184.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii184 : PRE_first_tail_x8_r0_body.cli184.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_184.mlx.items.get (PRE_first_tail_x8_r0_body.kappa184.node k) = (PRE_first_tail_x8_r0_body.cx0_184.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa184.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot184 (clean : Conv.NClean (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P184.NL) (cl : SSt (· < 7946) PRE_first_tail_x8_r0_body.cx0_184.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P184 7946 PRE_first_tail_x8_r0_body.kappa184 PRE_first_tail_x8_r0_body.kd184 PRE_first_tail_x8_r0_body.khinv184 PRE_first_tail_x8_r0_body.kninv184 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx PRE_first_tail_x8_r0_body.cx0_184.mlx PRE_first_tail_x8_r0_body.cx1_184.mlx (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo184 PRE_first_tail_x8_r0_body.cln184 PRE_first_tail_x8_r0_body.cli184 PRE_first_tail_x8_r0_body.cwS184 PRE_first_tail_x8_r0_body.cnS184 PRE_first_tail_x8_r0_body.ciS184 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0184, PRE_first_tail_x8_r0_body.cnh1184, PRE_first_tail_x8_r0_body.cnn0184, PRE_first_tail_x8_r0_body.cnn1184, PRE_first_tail_x8_r0_body.cplo184, PRE_first_tail_x8_r0_body.ccnt184, PRE_first_tail_x8_r0_body.cnband184, PRE_first_tail_x8_r0_body.chbelow184, PRE_first_tail_x8_r0_body.chren184, PRE_first_tail_x8_r0_body.cband184, PRE_first_tail_x8_r0_body.cnh1pos184, PRE_first_tail_x8_r0_body.cnren184, PRE_first_tail_x8_r0_body.cnlow184, PRE_first_tail_x8_r0_body.cabs0a184, PRE_first_tail_x8_r0_body.cabs0b184, PRE_first_tail_x8_r0_body.ctok1184, PRE_first_tail_x8_r0_body.cpend184, PRE_first_tail_x8_r0_body.cerrh184, PRE_first_tail_x8_r0_body.cfiles184, PRE_first_tail_x8_r0_body.carch184, PRE_first_tail_x8_r0_body.csizes184, PRE_first_tail_x8_r0_body.cwired184, PRE_first_tail_x8_r0_body.cfix184, clean, PRE_first_tail_x8_r0_body.fcxn184, PRE_first_tail_x8_r0_body.fcnn184, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0184, PRE_first_tail_x8_r0_body.fnk184, PRE_first_tail_x8_r0_body.ckA184, PRE_first_tail_x8_r0_body.cobjsK184, PRE_first_tail_x8_r0_body.cnodesK184, PRE_first_tail_x8_r0_body.citemsK184, PRE_first_tail_x8_r0_body.f1A184, PRE_first_tail_x8_r0_body.f1O184, PRE_first_tail_x8_r0_body.f1N184, PRE_first_tail_x8_r0_body.f1I184, PRE_first_tail_x8_r0_body.fbd184, PRE_first_tail_x8_r0_body.fincW184, PRE_first_tail_x8_r0_body.fincI184, PRE_first_tail_x8_r0_body.fincN184, PRE_first_tail_x8_r0_body.flnF184, PRE_first_tail_x8_r0_body.fh184, PRE_first_tail_x8_r0_body.fo184, PRE_first_tail_x8_r0_body.fok184, PRE_first_tail_x8_r0_body.fnd184, PRE_first_tail_x8_r0_body.fp184, PRE_first_tail_x8_r0_body.fnord184, PRE_first_tail_x8_r0_body.fi184, PRE_first_tail_x8_r0_body.fii184⟩
theorem PRE_first_tail_x8_r0_body.cnshift184 (clean : Conv.NClean (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P184.NL) (cl : SSt (· < 7946) PRE_first_tail_x8_r0_body.cx0_184.mlx) : NShift PRE_first_tail_x8_r0_body.P184 7946 PRE_first_tail_x8_r0_body.kappa184 PRE_first_tail_x8_r0_body.cx0_184 PRE_first_tail_x8_r0_body.cx1_184 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot184 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost184 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0184 PRE_first_tail_x8_r0_body.ckn1184 PRE_first_tail_x8_r0_body.ckheap184 PRE_first_tail_x8_r0_body.ckpl184)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_184 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1778.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_184 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1778.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_184 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1778.ffi) = some PRE_first_tail_x8_r0_body.fxC_184
kernel_rfl PRE_first_tail_x8_r0_body.okrC_184 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1778.ffi) = some PRE_first_tail_x8_r0_body.krC_184
noncomputable def PRE_first_tail_x8_r0_body.fx0_184 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1780.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_184 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1780.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_184 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1780.ffi) = some PRE_first_tail_x8_r0_body.fx0_184
kernel_rfl PRE_first_tail_x8_r0_body.okr0_184 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1780.ffi) = some PRE_first_tail_x8_r0_body.kr0_184
noncomputable def PRE_first_tail_x8_r0_body.fx1_184 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1779.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_184 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1779.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_184 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1779.ffi) = some PRE_first_tail_x8_r0_body.fx1_184
kernel_rfl PRE_first_tail_x8_r0_body.okr1_184 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1779.ffi) = some PRE_first_tail_x8_r0_body.kr1_184
kernel_rfl PRE_first_tail_x8_r0_body.ff0184 : PRE_first_tail_x8_r0_body.fx0_184 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_184 (PRE_first_tail_x8_r0_body.clo184.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_184.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1184 : PRE_first_tail_x8_r0_body.fx1_184 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_184 (PRE_first_tail_x8_r0_body.cwS184.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_184.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck184 : freedLB PRE_first_tail_x8_r0_body.kappa184 PRE_first_tail_x8_r0_body.cx0_184.mlx PRE_first_tail_x8_r0_body.fx0_184 PRE_first_tail_x8_r0_body.fx1_184 PRE_first_tail_x8_r0_body.clo184 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0184 : PRE_first_tail_x8_r0_body.kr0_184.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_184.flags (PRE_first_tail_x8_r0_body.clo184.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_184.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0184 : PRE_first_tail_x8_r0_body.kr0_184.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_184.targs (PRE_first_tail_x8_r0_body.clo184.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_184.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1184 : PRE_first_tail_x8_r0_body.kr1_184.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_184.flags (PRE_first_tail_x8_r0_body.cwS184.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_184.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1184 : PRE_first_tail_x8_r0_body.kr1_184.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_184.targs (PRE_first_tail_x8_r0_body.cwS184.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_184.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck184 : krecLB PRE_first_tail_x8_r0_body.kappa184 7946 PRE_first_tail_x8_r0_body.cx0_184.mlx PRE_first_tail_x8_r0_body.kr0_184 PRE_first_tail_x8_r0_body.kr1_184 PRE_first_tail_x8_r0_body.clo184 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn184 : Nat.ble 7946 7946 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge184 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1779.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1780.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR184 : pendRegB PRE_first_tail_x8_r0_body.kappa184 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe184 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1780.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1779.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift184 (clean : Conv.NClean (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P184.NL) (cl : SSt (· < 7946) PRE_first_tail_x8_r0_body.cx0_184.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_184.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_184.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_184.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1778.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_184.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P184 7946 PRE_first_tail_x8_r0_body.kappa184 PRE_first_tail_x8_r0_body.s1780.ffi PRE_first_tail_x8_r0_body.s1779.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift184 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue184, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp184 t ht),
    PRE_first_tail_x8_r0_body.cbridge184,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1780.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1779.ffi) (PRE_first_tail_x8_r0_body.cfoot184 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_184 PRE_first_tail_x8_r0_body.ofx1_184 hobjC PRE_first_tail_x8_r0_body.ff0184 PRE_first_tail_x8_r0_body.ff1184 PRE_first_tail_x8_r0_body.ffck184,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1780.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1779.ffi) (PRE_first_tail_x8_r0_body.cfoot184 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_184 PRE_first_tail_x8_r0_body.okr1_184 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn184) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0184 PRE_first_tail_x8_r0_body.fkt0184 PRE_first_tail_x8_r0_body.fkf1184 PRE_first_tail_x8_r0_body.fkt1184 PRE_first_tail_x8_r0_body.fkck184,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0184 PRE_first_tail_x8_r0_body.cnh1184 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe184) PRE_first_tail_x8_r0_body.cpendR184⟩

end Host.Load.Run.Tpl
end

section -- st184/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st184 0
host_stream_state PRE_first_tail_x8_r0_body.st184 1
host_stream_state PRE_first_tail_x8_r0_body.st184 2
end Host.Load.Run.Tpl
end

section -- Site184
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 184 of chain `PRE_first_tail_x8_r0_body`: `rowBlocks__g184__g185` (`rowBlocks`), the call state `PRE_first_tail_x8_r0_body.s1778`, the merged state `PRE_first_tail_x8_r0_body.s1779`,
the site template `PRE_first_tail_x8_r0_body.st184` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1780`: the merge.
The footprint's facts are in `SiteF184`, the compaction's in `SiteC184`, `SiteK184`, `SiteNa184`, `SiteNb184`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso184 : PRE_first_tail_x8_r0_body.st184.s0 = { PRE_first_tail_x8_r0_body.s1778 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs184 : List Frame := PRE_first_tail_x8_r0_body.s1778.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_184 : PRE_first_tail_x8_r0_body.S1778.tab.length = 7946
kernel_rfl PRE_first_tail_x8_r0_body.tab0_184 : PRE_first_tail_x8_r0_body.st184.S0.tab = PRE_first_tail_x8_r0_body.S1778.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws184 : List Nat := [4136, 4137]
kernel_rfl PRE_first_tail_x8_r0_body.fresh184 : (PRE_first_tail_x8_r0_body.S1778.tab.all fun e => PRE_first_tail_x8_r0_body.ws184.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1778.oracle.all fun q => PRE_first_tail_x8_r0_body.ws184.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab184 : PRE_first_tail_x8_r0_body.S1779.tab = PRE_first_tail_x8_r0_body.S1778.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws184
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen184 : PRE_first_tail_x8_r0_body.st184.S2.tab.length - PRE_first_tail_x8_r0_body.st184.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged184`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap184 : PRE_first_tail_x8_r0_body.s1779.heap = PRE_first_tail_x8_r0_body.st184.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext184 : PRE_first_tail_x8_r0_body.s1779.next = PRE_first_tail_x8_r0_body.st184.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl184 : PRE_first_tail_x8_r0_body.s1779.ctl = PRE_first_tail_x8_r0_body.st184.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack184 : PRE_first_tail_x8_r0_body.s1779.stack = PRE_first_tail_x8_r0_body.st184.s2.stack ++ PRE_first_tail_x8_r0_body.s1778.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs184 : PRE_first_tail_x8_r0_body.s1779.jobs = PRE_first_tail_x8_r0_body.st184.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi184 : PRE_first_tail_x8_r0_body.s1779.ffi = PRE_first_tail_x8_r0_body.st184.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace184 : PRE_first_tail_x8_r0_body.s1779.trace = PRE_first_tail_x8_r0_body.st184.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores184 : PRE_first_tail_x8_r0_body.s1779.stores = PRE_first_tail_x8_r0_body.st184.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD184
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 184 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived184 : PRE_first_tail_x8_r0_body.nr184.map (fun r => nth? PRE_first_tail_x8_r0_body.st184.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo184 : PRE_first_tail_x8_r0_body.nr184.all (Nat.ble 7946) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj184 : PRE_first_tail_x8_r0_body.cws184.all (fun c => !PRE_first_tail_x8_r0_body.ws184.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ184 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws184 PRE_first_tail_x8_r0_body.crs184 PRE_first_tail_x8_r0_body.ws184

end Host.Load.Run.Tpl
end

section -- st184/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st184`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st184.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st184.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st184.s2.heap PRE_first_tail_x8_r0_body.st184.wrR ++ freshOf PRE_first_tail_x8_r0_body.st184.s2.heap PRE_first_tail_x8_r0_body.st184.s0.next PRE_first_tail_x8_r0_body.st184.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st184.wr : List Nat := PRE_first_tail_x8_r0_body.st184.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st184.heapFoot : PRE_first_tail_x8_r0_body.st184.s2.heap = setAll PRE_first_tail_x8_r0_body.st184.s0.heap PRE_first_tail_x8_r0_body.st184.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st184.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st184.s0.next PRE_first_tail_x8_r0_body.st184.s2.next = true
theorem PRE_first_tail_x8_r0_body.st184.grows : PRE_first_tail_x8_r0_body.st184.s0.next ≤ PRE_first_tail_x8_r0_body.st184.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st184.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st184.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st184.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st184.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st184.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st184.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st184.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st184.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st184.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st184.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st184.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st184.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF184
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 184 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB184 : nodupT PRE_first_tail_x8_r0_body.st184.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup184 : PRE_first_tail_x8_r0_body.st184.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB184).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB184 : PRE_first_tail_x8_r0_body.st184.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound184 : ∀ b ∈ PRE_first_tail_x8_r0_body.st184.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB184 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr184 := PRE_first_tail_x8_r0_body.st184.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq184 : PRE_first_tail_x8_r0_body.st184.s2.trace = PRE_first_tail_x8_r0_body.trFr184 ++ PRE_first_tail_x8_r0_body.st184.s0.trace
theorem PRE_first_tail_x8_r0_body.trace184 : ∃ fr, PRE_first_tail_x8_r0_body.st184.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st184.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq184⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide184 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB184 : (PRE_first_tail_x8_r0_body.wide184.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st184.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix184 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide184, WFix Map.id (Present PRE_first_tail_x8_r0_body.st184.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB184 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL184
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 184 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1779`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO184 : PRE_first_tail_x8_r0_body.st184.S0.oracle = PRE_first_tail_x8_r0_body.st184.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B184 : PRE_first_tail_x8_r0_body.st184.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st184.s0.next || (PRE_first_tail_x8_r0_body.st184.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot184 : Conv.StageFoot PRE_first_tail_x8_r0_body.st184.wr PRE_first_tail_x8_r0_body.st184.s0 PRE_first_tail_x8_r0_body.st184.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st184.heapFoot PRE_first_tail_x8_r0_body.wrNodup184 PRE_first_tail_x8_r0_body.wrBound184 PRE_first_tail_x8_r0_body.wr0B184 PRE_first_tail_x8_r0_body.st184.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged184 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st184.F.S → PRE_first_tail_x8_r0_body.st184.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st184.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st184.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs184 PRE_first_tail_x8_r0_body.st184.wr PRE_first_tail_x8_r0_body.s1778 PRE_first_tail_x8_r0_body.st184.s2 PRE_first_tail_x8_r0_body.st184.s0
      PRE_first_tail_x8_r0_body.st184.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st184.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1779 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso184 PRE_first_tail_x8_r0_body.stFoot184 PRE_first_tail_x8_r0_body.wrNodup184 PRE_first_tail_x8_r0_body.wrBound184 PRE_first_tail_x8_r0_body.trace184 PRE_first_tail_x8_r0_body.mheap184
    PRE_first_tail_x8_r0_body.mnext184 PRE_first_tail_x8_r0_body.mctl184 PRE_first_tail_x8_r0_body.mstack184 PRE_first_tail_x8_r0_body.mjobs184 PRE_first_tail_x8_r0_body.mffi184 PRE_first_tail_x8_r0_body.mtrace184 PRE_first_tail_x8_r0_body.mstores184 h

def PRE_first_tail_x8_r0_body.arrEl184_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE184_2665 : arrOf PRE_first_tail_x8_r0_body.s1779 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl184_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA184_2665 : isArrB PRE_first_tail_x8_r0_body.s1779 2665 = true
theorem PRE_first_tail_x8_r0_body.arr184_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1779.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl184_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE184_2665 PRE_first_tail_x8_r0_body.arrA184_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN184_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl184_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR184_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl184_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN184_2665

def PRE_first_tail_x8_r0_body.arrEl184_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE184_2673467 : arrOf PRE_first_tail_x8_r0_body.s1779 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl184_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA184_2673467 : isArrB PRE_first_tail_x8_r0_body.s1779 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr184_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1779.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl184_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE184_2673467 PRE_first_tail_x8_r0_body.arrA184_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN184_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl184_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR184_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl184_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN184_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k184 : isArrB PRE_first_tail_x8_r0_body.s1779 4910 = false
theorem PRE_first_tail_x8_r0_body.keep184 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1779 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k184 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr184_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl184_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ184
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 184 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1778`, the merged
state `PRE_first_tail_x8_r0_body.s1779`, the canonical state `PRE_first_tail_x8_r0_body.s1780`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl184 : PRE_first_tail_x8_r0_body.pl184.all (Nat.ble PRE_first_tail_x8_r0_body.s1778.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd184 : nodupT PRE_first_tail_x8_r0_body.pl184 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1184 : Nat.ble PRE_first_tail_x8_r0_body.s1778.next 2819485 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst184 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1778.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn184 : PRE_first_tail_x8_r0_body.s1780.next = PRE_first_tail_x8_r0_body.s1778.next + PRE_first_tail_x8_r0_body.pl184.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn184 : PRE_first_tail_x8_r0_body.s1779.next = 2819485
kernel_rfl PRE_first_tail_x8_r0_body.zgrow184 : Nat.ble PRE_first_tail_x8_r0_body.s1780.next PRE_first_tail_x8_r0_body.s1779.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh184 : PRE_first_tail_x8_r0_body.S1778.tab.all (fun e => PRE_first_tail_x8_r0_body.cws184.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd184 : nodupT PRE_first_tail_x8_r0_body.cws184 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi184 : PRE_first_tail_x8_r0_body.nr184.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1779.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt184 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1778.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg184_2665 : PRE_first_tail_x8_r0_body.s1780.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1780 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk184_2665 : (objOf PRE_first_tail_x8_r0_body.s1780 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm184_2665 : PRE_first_tail_x8_r0_body.s1779.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa184.obj (objOf PRE_first_tail_x8_r0_body.s1780 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1779 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg184_2673467 : PRE_first_tail_x8_r0_body.s1780.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1780 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk184_2673467 : (objOf PRE_first_tail_x8_r0_body.s1780 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm184_2673467 : PRE_first_tail_x8_r0_body.s1779.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa184.obj (objOf PRE_first_tail_x8_r0_body.s1780 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1779 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw184_4910 : (PRE_first_tail_x8_r0_body.s1780.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw184_2673472 : (PRE_first_tail_x8_r0_body.s1780.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw184_2673473 : (PRE_first_tail_x8_r0_body.s1780.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd184 : PRE_first_tail_x8_r0_body.cl184.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr184 : PRE_first_tail_x8_r0_body.st184.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1778.next || PRE_first_tail_x8_r0_body.cl184.contains b) = true
def PRE_first_tail_x8_r0_body.zl184 : List Nat := PRE_first_tail_x8_r0_body.cl184.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE184 : PRE_first_tail_x8_r0_body.zl184.map (fun a => PRE_first_tail_x8_r0_body.s1779.heap.get (PRE_first_tail_x8_r0_body.kappa184.a a)) = PRE_first_tail_x8_r0_body.zl184.map (fun a => (PRE_first_tail_x8_r0_body.s1780.heap.get a).map PRE_first_tail_x8_r0_body.kappa184.hobj)
theorem PRE_first_tail_x8_r0_body.zimg184 : HeapImg PRE_first_tail_x8_r0_body.kappa184 PRE_first_tail_x8_r0_body.s1780 PRE_first_tail_x8_r0_body.s1779 PRE_first_tail_x8_r0_body.zl184 := PRE_first_tail_x8_r0_body.zimgE184
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl184 : PRE_first_tail_x8_r0_body.s1779.ctl = PRE_first_tail_x8_r0_body.kappa184.ctl PRE_first_tail_x8_r0_body.s1780.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack184 : PRE_first_tail_x8_r0_body.s1779.stack = PRE_first_tail_x8_r0_body.s1780.stack.map PRE_first_tail_x8_r0_body.kappa184.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs184 : PRE_first_tail_x8_r0_body.s1779.jobs = PRE_first_tail_x8_r0_body.s1780.jobs.map PRE_first_tail_x8_r0_body.kappa184.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores184 : PRE_first_tail_x8_r0_body.s1779.stores = PRE_first_tail_x8_r0_body.kappa184.stores PRE_first_tail_x8_r0_body.s1780.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots184 : checkRootsSupp PRE_first_tail_x8_r0_body.s1780 7946 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC184 : PRE_first_tail_x8_r0_body.S1778.tab.length + PRE_first_tail_x8_r0_body.cws184.length = 7946
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap184 : PRE_first_tail_x8_r0_body.kappa184 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1778.next 2819485 PRE_first_tail_x8_r0_body.S1778.tab.length PRE_first_tail_x8_r0_body.pl184 (PRE_first_tail_x8_r0_body.nr184.map NumV.ref) PRE_first_tail_x8_r0_body.kd184.big
  PRE_first_tail_x8_r0_body.kd184.region PRE_first_tail_x8_r0_body.kd184.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin184 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1780.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc184 : Conv.jcleanListB (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1780 PRE_first_tail_x8_r0_body.cl184 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB184 : noBigRootsP (fun i => !Conv.oldBigB (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1780.trace PRE_first_tail_x8_r0_body.s1780 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm184 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18936 = true
theorem PRE_first_tail_x8_r0_body.cjcl184 (h : Conv.JClean (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1778) : Conv.JClean (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1780 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle184)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap184 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd184 a ha)) PRE_first_tail_x8_r0_body.zjc184

end Host.Load.Run.Tpl
end

section -- st184/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st184.bodyLast from PRE_first_tail_x8_r0_body.st184.s1 to PRE_first_tail_x8_r0_body.st184.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st184.F PRE_first_tail_x8_r0_body.st184.s1).run PRE_first_tail_x8_r0_body.st184.S1 = some (PRE_first_tail_x8_r0_body.st184.s2, PRE_first_tail_x8_r0_body.st184.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st184.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st184.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st184.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st184.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st184/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st184.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st184.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st184.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st184.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st184.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st184.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st184.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st184.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st184.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st184.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st184.s0 PRE_first_tail_x8_r0_body.st184.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st184.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st184.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st184.s1 PRE_first_tail_x8_r0_body.st184.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st184/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st184.bodyK0F from PRE_first_tail_x8_r0_body.st184.s0 to PRE_first_tail_x8_r0_body.st184.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st184.F (PRE_first_tail_x8_r0_body.st184.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st184.ks 0).getD 0) PRE_first_tail_x8_r0_body.st184.s0 PRE_first_tail_x8_r0_body.st184.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st184.s1, PRE_first_tail_x8_r0_body.st184.S1)
theorem PRE_first_tail_x8_r0_body.st184.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st184.F (PRE_first_tail_x8_r0_body.st184.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st184.ks 0).getD 0) PRE_first_tail_x8_r0_body.st184.s0 PRE_first_tail_x8_r0_body.st184.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st184.s1, PRE_first_tail_x8_r0_body.st184.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st184.bodyOkLN_ok PRE_first_tail_x8_r0_body.st184.bodyK0F
end Host.Load.Run.Tpl
end

section -- st184/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st184.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st184.F (PRE_first_tail_x8_r0_body.st184.bodyOkL bytes rows) 27 PRE_first_tail_x8_r0_body.st184.s0 PRE_first_tail_x8_r0_body.st184.S0 = some (PRE_first_tail_x8_r0_body.st184.s1, PRE_first_tail_x8_r0_body.st184.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st184.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st184.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st184.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st184.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st184.F (PRE_first_tail_x8_r0_body.st184.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st184.s0
  S0 := PRE_first_tail_x8_r0_body.st184.S0
  s1 := PRE_first_tail_x8_r0_body.st184.s1
  S1 := PRE_first_tail_x8_r0_body.st184.S1
  s2 := PRE_first_tail_x8_r0_body.st184.s2
  S2 := PRE_first_tail_x8_r0_body.st184.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st184.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st184.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st184.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st184.bodyHalt
  last := PRE_first_tail_x8_r0_body.st184.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st184.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC185
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 185 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1784` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa185` into the merged state
`PRE_first_tail_x8_r0_body.s1783`. -/

def PRE_first_tail_x8_r0_body.pl185 : List Nat := [2819791]
def PRE_first_tail_x8_r0_body.nr185 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd185 : RData :=
  ⟨2819772, 2819792, Stage.setAll PTrie.nil [(2819771, 2819791)], Stage.setAll PTrie.nil [],
   21836, 21836, 18940, 18940, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa185 : Map :=
  Conv.Map.compact 2819771 2819792 7963 PRE_first_tail_x8_r0_body.pl185 (PRE_first_tail_x8_r0_body.nr185.map NumV.ref) PRE_first_tail_x8_r0_body.kd185.big
    PRE_first_tail_x8_r0_body.kd185.region PRE_first_tail_x8_r0_body.kd185.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws185 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs185 : List SymE := PRE_first_tail_x8_r0_body.nr185.map fun r => (nth? PRE_first_tail_x8_r0_body.S1783.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta185 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws185 PRE_first_tail_x8_r0_body.crs185
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB185 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab185 : PRE_first_tail_x8_r0_body.S1784.tab = PRE_first_tail_x8_r0_body.S1782.tab ++ PRE_first_tail_x8_r0_body.cws185.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace185 : PRE_first_tail_x8_r0_body.s1784.trace = PRE_first_tail_x8_r0_body.s1782.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext185 : PRE_first_tail_x8_r0_body.s1784.next = 2819772
kernel_rfl PRE_first_tail_x8_r0_body.ccounters185 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx.nnext) = (21836, 18940)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue185 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1783.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa185.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp185 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx.tokens.all (bSN 7963) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean185 : Conv.cleanListB 21836 131072 (fun r => Nat.ble 87344 r) PRE_first_tail_x8_r0_body.s1784
    (PRE_first_tail_x8_r0_body.wrB185 ++ (List.range 1).map (2819771 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs185 : bigsOutB 21836 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK185
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl185`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl185 : List Nat := [2665, 2673467, 2819771]
def PRE_first_tail_x8_r0_body.clo185 : List Nat := []
def PRE_first_tail_x8_r0_body.cln185 : List Nat := []
def PRE_first_tail_x8_r0_body.cli185 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap185 : PRE_first_tail_x8_r0_body.s1784.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1782.heap (PRE_first_tail_x8_r0_body.cl185.filterMap fun a => (PRE_first_tail_x8_r0_body.s1784.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe185 : Nat.ble PRE_first_tail_x8_r0_body.s1782.next PRE_first_tail_x8_r0_body.s1784.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP185 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1782 PRE_first_tail_x8_r0_body.s1784 PRE_first_tail_x8_r0_body.cl185 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp185 : Conv.suppListB PRE_first_tail_x8_r0_body.s1784 7963 PRE_first_tail_x8_r0_body.cl185 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound185 : Conv.boundListB PRE_first_tail_x8_r0_body.s1784 PRE_first_tail_x8_r0_body.cl185 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK185 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln185.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK185 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo185.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK185 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli185.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst185 : Conv.sstListB 7963 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx PRE_first_tail_x8_r0_body.cln185 PRE_first_tail_x8_r0_body.clo185 PRE_first_tail_x8_r0_body.cli185 = true

end Host.Load.Run.Tpl
end

section -- SiteCl185
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA185 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo185.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd185 : (PRE_first_tail_x8_r0_body.clo185 ++ PRE_first_tail_x8_r0_body.cln185 ++ PRE_first_tail_x8_r0_body.cli185).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle185 : Conv.Cnt.leB (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt) (⟨21836, 18940, 2819772, 7963⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck185 : Conv.ncleanListB (⟨21836, 18940, 2819772, 7963⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx PRE_first_tail_x8_r0_body.clo185 PRE_first_tail_x8_r0_body.cln185 PRE_first_tail_x8_r0_body.cli185 = true
theorem PRE_first_tail_x8_r0_body.cncl185 (h : Conv.NClean (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx) : Conv.NClean (⟨21836, 18940, 2819772, 7963⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle185 PRE_first_tail_x8_r0_body.ckA185 PRE_first_tail_x8_r0_body.cobjsK185 PRE_first_tail_x8_r0_body.cnodesK185 PRE_first_tail_x8_r0_body.citemsK185 PRE_first_tail_x8_r0_body.cbd185 PRE_first_tail_x8_r0_body.cck185

end Host.Load.Run.Tpl
end

section -- SiteS185
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 185 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc185 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P185 : LoadP := PRE_first_tail_x8_r0_body.Pc185.raise 18940
kernel_rfl PRE_first_tail_x8_r0_body.craise185 : Nat.ble PRE_first_tail_x8_r0_body.Pc185.N0 18940 = true
theorem PRE_first_tail_x8_r0_body.raised185 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc185 PRE_first_tail_x8_r0_body.P185 :=
  .inr ⟨18940, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise185, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_185 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_185 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1783.ffi)
def PRE_first_tail_x8_r0_body.khinv185 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv185 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS185 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS185 : List Nat := List.range' 18940 0
def PRE_first_tail_x8_r0_body.ciS185 : List Nat := [] ++ List.range' 18940 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0185 : PRE_first_tail_x8_r0_body.kd185.nh0 = PRE_first_tail_x8_r0_body.cx0_185.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1185 : PRE_first_tail_x8_r0_body.kd185.nh1 = PRE_first_tail_x8_r0_body.cx1_185.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0185 : PRE_first_tail_x8_r0_body.kd185.nn0 = PRE_first_tail_x8_r0_body.cx0_185.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1185 : PRE_first_tail_x8_r0_body.kd185.nn1 = PRE_first_tail_x8_r0_body.cx1_185.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo185 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P185.lo && Nat.ble PRE_first_tail_x8_r0_body.P185.lo PRE_first_tail_x8_r0_body.cx0_185.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P185.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P185.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt185 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_185.mlx.next PRE_first_tail_x8_r0_body.cx1_185.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_185.mlx.nnext PRE_first_tail_x8_r0_body.cx1_185.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband185 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P185.NL && Nat.ble PRE_first_tail_x8_r0_body.P185.NL PRE_first_tail_x8_r0_body.P185.N0 && Nat.ble PRE_first_tail_x8_r0_body.P185.N0 PRE_first_tail_x8_r0_body.cx0_185.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow185 : PRE_first_tail_x8_r0_body.kd185.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren185 : checkRenG PRE_first_tail_x8_r0_body.kd185.hnd PRE_first_tail_x8_r0_body.khinv185 (phB PRE_first_tail_x8_r0_body.cx0_185.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband185 : PRE_first_tail_x8_r0_body.kd185.checkBand PRE_first_tail_x8_r0_body.P185.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos185 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd185.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren185 : checkRenG PRE_first_tail_x8_r0_body.kd185.node PRE_first_tail_x8_r0_body.kninv185 (pnB PRE_first_tail_x8_r0_body.cx0_185.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow185 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd185.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P185.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd185.nodeF j) PRE_first_tail_x8_r0_body.cx1_185.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a185 : PRE_first_tail_x8_r0_body.cx0_185.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b185 : PRE_first_tail_x8_r0_body.cx0_185.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1185 : PRE_first_tail_x8_r0_body.cx1_185.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend185 : PRE_first_tail_x8_r0_body.cx1_185.mlx.pending = PRE_first_tail_x8_r0_body.cx0_185.mlx.pending.map PRE_first_tail_x8_r0_body.kappa185.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh185 : PRE_first_tail_x8_r0_body.cx1_185.mlx.errh = PRE_first_tail_x8_r0_body.cx0_185.mlx.errh.map PRE_first_tail_x8_r0_body.kappa185.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles185 : PRE_first_tail_x8_r0_body.cx1_185.mlx.files = PRE_first_tail_x8_r0_body.cx0_185.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch185 : PRE_first_tail_x8_r0_body.cx1_185.mlx.arch = PRE_first_tail_x8_r0_body.cx0_185.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes185 : PRE_first_tail_x8_r0_body.cx1_185.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_185.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired185 : PRE_first_tail_x8_r0_body.cx1_185.mlx.wired = PRE_first_tail_x8_r0_body.cx0_185.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost185 : PRE_first_tail_x8_r0_body.cx1_185.host = PRE_first_tail_x8_r0_body.cx0_185.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd185`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0185 : PRE_first_tail_x8_r0_body.kd185.n0 = 2819772
kernel_rfl PRE_first_tail_x8_r0_body.ckn1185 : PRE_first_tail_x8_r0_body.kd185.n1 = 2819792
kernel_rfl PRE_first_tail_x8_r0_body.ckheap185 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd185.heap).all (fun x => Nat.ble 2819771 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl185 : (List.range 1).all (fun j => decide (PRE_first_tail_x8_r0_body.kd185.heap.get (2819771 + j) = nth? PRE_first_tail_x8_r0_body.pl185 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja185 : Nat.ble 2819771 2819771 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn185 : Nat.ble 7963 7963 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD185 : Nat.ble 2819771 PRE_first_tail_x8_r0_body.kd185.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn185 : Nat.ble 21836 PRE_first_tail_x8_r0_body.kd185.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn185 : Nat.ble 18940 PRE_first_tail_x8_r0_body.kd185.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb185 : Nat.ble 21836 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap185 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd185.heap).all (Nat.ble (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd185 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd185.hnd).all (Nat.ble (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode185 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd185.node).all (Nat.ble (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix185 : Conv.FixOld (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa185 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja185) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn185) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD185) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn185) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn185) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb185) PRE_first_tail_x8_r0_body.fheap185 PRE_first_tail_x8_r0_body.fhnd185 PRE_first_tail_x8_r0_body.fnode185
kernel_rfl PRE_first_tail_x8_r0_body.fcxn185 : (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn185 : (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0185 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_185.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_185.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk185 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd185.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A185 : PRE_first_tail_x8_r0_body.cx1_185.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS185.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_185.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O185 : PRE_first_tail_x8_r0_body.cx1_185.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS185.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_185.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N185 : PRE_first_tail_x8_r0_body.cx1_185.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS185.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_185.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I185 : PRE_first_tail_x8_r0_body.cx1_185.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS185.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_185.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd185 : (PRE_first_tail_x8_r0_body.clo185 ++ PRE_first_tail_x8_r0_body.cln185 ++ PRE_first_tail_x8_r0_body.cli185 ++ PRE_first_tail_x8_r0_body.cwS185 ++ PRE_first_tail_x8_r0_body.cnS185 ++ PRE_first_tail_x8_r0_body.ciS185).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW185 : PRE_first_tail_x8_r0_body.cwS185.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo185.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI185 : PRE_first_tail_x8_r0_body.ciS185.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli185.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN185 : PRE_first_tail_x8_r0_body.cnS185.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF185 : PRE_first_tail_x8_r0_body.cln185.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh185 : PRE_first_tail_x8_r0_body.clo185.all (handleOK PRE_first_tail_x8_r0_body.kappa185 PRE_first_tail_x8_r0_body.P185.lo PRE_first_tail_x8_r0_body.cx0_185.mlx PRE_first_tail_x8_r0_body.cx1_185.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo185 : PRE_first_tail_x8_r0_body.clo185.map (fun h => PRE_first_tail_x8_r0_body.cx1_185.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa185.handle h)) = PRE_first_tail_x8_r0_body.clo185.map (fun h => (PRE_first_tail_x8_r0_body.cx0_185.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa185.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok185 : PRE_first_tail_x8_r0_body.clo185.all (objOK PRE_first_tail_x8_r0_body.kappa185 PRE_first_tail_x8_r0_body.P185.NL PRE_first_tail_x8_r0_body.cx0_185.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd185 : PRE_first_tail_x8_r0_body.cln185.all (nodeOKF PRE_first_tail_x8_r0_body.kappa185 PRE_first_tail_x8_r0_body.P185 PRE_first_tail_x8_r0_body.cx0_185.mlx PRE_first_tail_x8_r0_body.cx1_185.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp185 : ((PRE_first_tail_x8_r0_body.cln185.filter (fullB PRE_first_tail_x8_r0_body.P185))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_185.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa185.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln185.filter (fullB PRE_first_tail_x8_r0_body.P185))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_185.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa185.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI185 : incrB PRE_first_tail_x8_r0_body.kd185.nodeF (List.range' 18940 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK185 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd185.node).all (fun k => Nat.ble 18940 k && Nat.blt k 18940) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL185 : (PRE_first_tail_x8_r0_body.cln185.filter (Nat.ble PRE_first_tail_x8_r0_body.P185.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd185.nodeF i) && (Nat.blt i 18940 || Nat.ble PRE_first_tail_x8_r0_body.kd185.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord185 : (PRE_first_tail_x8_r0_body.cln185.filter (Nat.ble PRE_first_tail_x8_r0_body.P185.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd185.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd185.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd185.nodeF j) (PRE_first_tail_x8_r0_body.kd185.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow185 PRE_first_tail_x8_r0_body.cnn1185 PRE_first_tail_x8_r0_body.fnordI185 PRE_first_tail_x8_r0_body.fnordK185 PRE_first_tail_x8_r0_body.fnordL185
kernel_rfl PRE_first_tail_x8_r0_body.fi185 : PRE_first_tail_x8_r0_body.cli185.all (pnB PRE_first_tail_x8_r0_body.cx0_185.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii185 : PRE_first_tail_x8_r0_body.cli185.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_185.mlx.items.get (PRE_first_tail_x8_r0_body.kappa185.node k) = (PRE_first_tail_x8_r0_body.cx0_185.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa185.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot185 (clean : Conv.NClean (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P185.NL) (cl : SSt (· < 7963) PRE_first_tail_x8_r0_body.cx0_185.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P185 7963 PRE_first_tail_x8_r0_body.kappa185 PRE_first_tail_x8_r0_body.kd185 PRE_first_tail_x8_r0_body.khinv185 PRE_first_tail_x8_r0_body.kninv185 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx PRE_first_tail_x8_r0_body.cx0_185.mlx PRE_first_tail_x8_r0_body.cx1_185.mlx (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo185 PRE_first_tail_x8_r0_body.cln185 PRE_first_tail_x8_r0_body.cli185 PRE_first_tail_x8_r0_body.cwS185 PRE_first_tail_x8_r0_body.cnS185 PRE_first_tail_x8_r0_body.ciS185 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0185, PRE_first_tail_x8_r0_body.cnh1185, PRE_first_tail_x8_r0_body.cnn0185, PRE_first_tail_x8_r0_body.cnn1185, PRE_first_tail_x8_r0_body.cplo185, PRE_first_tail_x8_r0_body.ccnt185, PRE_first_tail_x8_r0_body.cnband185, PRE_first_tail_x8_r0_body.chbelow185, PRE_first_tail_x8_r0_body.chren185, PRE_first_tail_x8_r0_body.cband185, PRE_first_tail_x8_r0_body.cnh1pos185, PRE_first_tail_x8_r0_body.cnren185, PRE_first_tail_x8_r0_body.cnlow185, PRE_first_tail_x8_r0_body.cabs0a185, PRE_first_tail_x8_r0_body.cabs0b185, PRE_first_tail_x8_r0_body.ctok1185, PRE_first_tail_x8_r0_body.cpend185, PRE_first_tail_x8_r0_body.cerrh185, PRE_first_tail_x8_r0_body.cfiles185, PRE_first_tail_x8_r0_body.carch185, PRE_first_tail_x8_r0_body.csizes185, PRE_first_tail_x8_r0_body.cwired185, PRE_first_tail_x8_r0_body.cfix185, clean, PRE_first_tail_x8_r0_body.fcxn185, PRE_first_tail_x8_r0_body.fcnn185, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0185, PRE_first_tail_x8_r0_body.fnk185, PRE_first_tail_x8_r0_body.ckA185, PRE_first_tail_x8_r0_body.cobjsK185, PRE_first_tail_x8_r0_body.cnodesK185, PRE_first_tail_x8_r0_body.citemsK185, PRE_first_tail_x8_r0_body.f1A185, PRE_first_tail_x8_r0_body.f1O185, PRE_first_tail_x8_r0_body.f1N185, PRE_first_tail_x8_r0_body.f1I185, PRE_first_tail_x8_r0_body.fbd185, PRE_first_tail_x8_r0_body.fincW185, PRE_first_tail_x8_r0_body.fincI185, PRE_first_tail_x8_r0_body.fincN185, PRE_first_tail_x8_r0_body.flnF185, PRE_first_tail_x8_r0_body.fh185, PRE_first_tail_x8_r0_body.fo185, PRE_first_tail_x8_r0_body.fok185, PRE_first_tail_x8_r0_body.fnd185, PRE_first_tail_x8_r0_body.fp185, PRE_first_tail_x8_r0_body.fnord185, PRE_first_tail_x8_r0_body.fi185, PRE_first_tail_x8_r0_body.fii185⟩
theorem PRE_first_tail_x8_r0_body.cnshift185 (clean : Conv.NClean (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P185.NL) (cl : SSt (· < 7963) PRE_first_tail_x8_r0_body.cx0_185.mlx) : NShift PRE_first_tail_x8_r0_body.P185 7963 PRE_first_tail_x8_r0_body.kappa185 PRE_first_tail_x8_r0_body.cx0_185 PRE_first_tail_x8_r0_body.cx1_185 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot185 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost185 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0185 PRE_first_tail_x8_r0_body.ckn1185 PRE_first_tail_x8_r0_body.ckheap185 PRE_first_tail_x8_r0_body.ckpl185)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_185 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1782.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_185 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1782.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_185 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1782.ffi) = some PRE_first_tail_x8_r0_body.fxC_185
kernel_rfl PRE_first_tail_x8_r0_body.okrC_185 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1782.ffi) = some PRE_first_tail_x8_r0_body.krC_185
noncomputable def PRE_first_tail_x8_r0_body.fx0_185 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1784.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_185 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1784.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_185 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1784.ffi) = some PRE_first_tail_x8_r0_body.fx0_185
kernel_rfl PRE_first_tail_x8_r0_body.okr0_185 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1784.ffi) = some PRE_first_tail_x8_r0_body.kr0_185
noncomputable def PRE_first_tail_x8_r0_body.fx1_185 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1783.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_185 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1783.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_185 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1783.ffi) = some PRE_first_tail_x8_r0_body.fx1_185
kernel_rfl PRE_first_tail_x8_r0_body.okr1_185 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1783.ffi) = some PRE_first_tail_x8_r0_body.kr1_185
kernel_rfl PRE_first_tail_x8_r0_body.ff0185 : PRE_first_tail_x8_r0_body.fx0_185 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_185 (PRE_first_tail_x8_r0_body.clo185.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_185.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1185 : PRE_first_tail_x8_r0_body.fx1_185 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_185 (PRE_first_tail_x8_r0_body.cwS185.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_185.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck185 : freedLB PRE_first_tail_x8_r0_body.kappa185 PRE_first_tail_x8_r0_body.cx0_185.mlx PRE_first_tail_x8_r0_body.fx0_185 PRE_first_tail_x8_r0_body.fx1_185 PRE_first_tail_x8_r0_body.clo185 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0185 : PRE_first_tail_x8_r0_body.kr0_185.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_185.flags (PRE_first_tail_x8_r0_body.clo185.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_185.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0185 : PRE_first_tail_x8_r0_body.kr0_185.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_185.targs (PRE_first_tail_x8_r0_body.clo185.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_185.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1185 : PRE_first_tail_x8_r0_body.kr1_185.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_185.flags (PRE_first_tail_x8_r0_body.cwS185.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_185.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1185 : PRE_first_tail_x8_r0_body.kr1_185.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_185.targs (PRE_first_tail_x8_r0_body.cwS185.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_185.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck185 : krecLB PRE_first_tail_x8_r0_body.kappa185 7963 PRE_first_tail_x8_r0_body.cx0_185.mlx PRE_first_tail_x8_r0_body.kr0_185 PRE_first_tail_x8_r0_body.kr1_185 PRE_first_tail_x8_r0_body.clo185 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn185 : Nat.ble 7963 7963 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge185 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1783.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1784.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR185 : pendRegB PRE_first_tail_x8_r0_body.kappa185 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe185 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1784.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1783.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift185 (clean : Conv.NClean (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P185.NL) (cl : SSt (· < 7963) PRE_first_tail_x8_r0_body.cx0_185.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_185.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_185.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_185.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1782.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_185.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P185 7963 PRE_first_tail_x8_r0_body.kappa185 PRE_first_tail_x8_r0_body.s1784.ffi PRE_first_tail_x8_r0_body.s1783.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift185 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue185, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp185 t ht),
    PRE_first_tail_x8_r0_body.cbridge185,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1784.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1783.ffi) (PRE_first_tail_x8_r0_body.cfoot185 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_185 PRE_first_tail_x8_r0_body.ofx1_185 hobjC PRE_first_tail_x8_r0_body.ff0185 PRE_first_tail_x8_r0_body.ff1185 PRE_first_tail_x8_r0_body.ffck185,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1784.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1783.ffi) (PRE_first_tail_x8_r0_body.cfoot185 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_185 PRE_first_tail_x8_r0_body.okr1_185 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn185) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0185 PRE_first_tail_x8_r0_body.fkt0185 PRE_first_tail_x8_r0_body.fkf1185 PRE_first_tail_x8_r0_body.fkt1185 PRE_first_tail_x8_r0_body.fkck185,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0185 PRE_first_tail_x8_r0_body.cnh1185 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe185) PRE_first_tail_x8_r0_body.cpendR185⟩

end Host.Load.Run.Tpl
end

section -- st185/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st185 0
host_stream_state PRE_first_tail_x8_r0_body.st185 1
host_stream_state PRE_first_tail_x8_r0_body.st185 2
end Host.Load.Run.Tpl
end

section -- Site185
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 185 of chain `PRE_first_tail_x8_r0_body`: `plan__g185__g186` (`plan`), the call state `PRE_first_tail_x8_r0_body.s1782`, the merged state `PRE_first_tail_x8_r0_body.s1783`,
the site template `PRE_first_tail_x8_r0_body.st185` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1784`: the merge.
The footprint's facts are in `SiteF185`, the compaction's in `SiteC185`, `SiteK185`, `SiteNa185`, `SiteNb185`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso185 : PRE_first_tail_x8_r0_body.st185.s0 = { PRE_first_tail_x8_r0_body.s1782 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs185 : List Frame := PRE_first_tail_x8_r0_body.s1782.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_185 : PRE_first_tail_x8_r0_body.S1782.tab.length = 7963
kernel_rfl PRE_first_tail_x8_r0_body.tab0_185 : PRE_first_tail_x8_r0_body.st185.S0.tab = PRE_first_tail_x8_r0_body.S1782.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws185 : List Nat := [4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146]
kernel_rfl PRE_first_tail_x8_r0_body.fresh185 : (PRE_first_tail_x8_r0_body.S1782.tab.all fun e => PRE_first_tail_x8_r0_body.ws185.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1782.oracle.all fun q => PRE_first_tail_x8_r0_body.ws185.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab185 : PRE_first_tail_x8_r0_body.S1783.tab = PRE_first_tail_x8_r0_body.S1782.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws185
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen185 : PRE_first_tail_x8_r0_body.st185.S2.tab.length - PRE_first_tail_x8_r0_body.st185.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged185`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap185 : PRE_first_tail_x8_r0_body.s1783.heap = PRE_first_tail_x8_r0_body.st185.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext185 : PRE_first_tail_x8_r0_body.s1783.next = PRE_first_tail_x8_r0_body.st185.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl185 : PRE_first_tail_x8_r0_body.s1783.ctl = PRE_first_tail_x8_r0_body.st185.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack185 : PRE_first_tail_x8_r0_body.s1783.stack = PRE_first_tail_x8_r0_body.st185.s2.stack ++ PRE_first_tail_x8_r0_body.s1782.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs185 : PRE_first_tail_x8_r0_body.s1783.jobs = PRE_first_tail_x8_r0_body.st185.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi185 : PRE_first_tail_x8_r0_body.s1783.ffi = PRE_first_tail_x8_r0_body.st185.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace185 : PRE_first_tail_x8_r0_body.s1783.trace = PRE_first_tail_x8_r0_body.st185.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores185 : PRE_first_tail_x8_r0_body.s1783.stores = PRE_first_tail_x8_r0_body.st185.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD185
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 185 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived185 : PRE_first_tail_x8_r0_body.nr185.map (fun r => nth? PRE_first_tail_x8_r0_body.st185.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo185 : PRE_first_tail_x8_r0_body.nr185.all (Nat.ble 7963) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj185 : PRE_first_tail_x8_r0_body.cws185.all (fun c => !PRE_first_tail_x8_r0_body.ws185.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ185 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws185 PRE_first_tail_x8_r0_body.crs185 PRE_first_tail_x8_r0_body.ws185

end Host.Load.Run.Tpl
end

section -- st185/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st185`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st185.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st185.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st185.s2.heap PRE_first_tail_x8_r0_body.st185.wrR ++ freshOf PRE_first_tail_x8_r0_body.st185.s2.heap PRE_first_tail_x8_r0_body.st185.s0.next PRE_first_tail_x8_r0_body.st185.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st185.wr : List Nat := PRE_first_tail_x8_r0_body.st185.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st185.heapFoot : PRE_first_tail_x8_r0_body.st185.s2.heap = setAll PRE_first_tail_x8_r0_body.st185.s0.heap PRE_first_tail_x8_r0_body.st185.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st185.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st185.s0.next PRE_first_tail_x8_r0_body.st185.s2.next = true
theorem PRE_first_tail_x8_r0_body.st185.grows : PRE_first_tail_x8_r0_body.st185.s0.next ≤ PRE_first_tail_x8_r0_body.st185.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st185.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st185.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st185.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st185.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st185.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st185.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st185.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st185.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st185.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st185.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st185.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st185.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF185
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 185 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB185 : nodupT PRE_first_tail_x8_r0_body.st185.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup185 : PRE_first_tail_x8_r0_body.st185.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB185).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB185 : PRE_first_tail_x8_r0_body.st185.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound185 : ∀ b ∈ PRE_first_tail_x8_r0_body.st185.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB185 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr185 := PRE_first_tail_x8_r0_body.st185.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq185 : PRE_first_tail_x8_r0_body.st185.s2.trace = PRE_first_tail_x8_r0_body.trFr185 ++ PRE_first_tail_x8_r0_body.st185.s0.trace
theorem PRE_first_tail_x8_r0_body.trace185 : ∃ fr, PRE_first_tail_x8_r0_body.st185.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st185.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq185⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide185 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB185 : (PRE_first_tail_x8_r0_body.wide185.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st185.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix185 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide185, WFix Map.id (Present PRE_first_tail_x8_r0_body.st185.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB185 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL185
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 185 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1783`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO185 : PRE_first_tail_x8_r0_body.st185.S0.oracle = PRE_first_tail_x8_r0_body.st185.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B185 : PRE_first_tail_x8_r0_body.st185.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st185.s0.next || (PRE_first_tail_x8_r0_body.st185.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot185 : Conv.StageFoot PRE_first_tail_x8_r0_body.st185.wr PRE_first_tail_x8_r0_body.st185.s0 PRE_first_tail_x8_r0_body.st185.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st185.heapFoot PRE_first_tail_x8_r0_body.wrNodup185 PRE_first_tail_x8_r0_body.wrBound185 PRE_first_tail_x8_r0_body.wr0B185 PRE_first_tail_x8_r0_body.st185.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged185 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st185.F.S → PRE_first_tail_x8_r0_body.st185.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st185.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st185.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs185 PRE_first_tail_x8_r0_body.st185.wr PRE_first_tail_x8_r0_body.s1782 PRE_first_tail_x8_r0_body.st185.s2 PRE_first_tail_x8_r0_body.st185.s0
      PRE_first_tail_x8_r0_body.st185.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st185.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1783 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso185 PRE_first_tail_x8_r0_body.stFoot185 PRE_first_tail_x8_r0_body.wrNodup185 PRE_first_tail_x8_r0_body.wrBound185 PRE_first_tail_x8_r0_body.trace185 PRE_first_tail_x8_r0_body.mheap185
    PRE_first_tail_x8_r0_body.mnext185 PRE_first_tail_x8_r0_body.mctl185 PRE_first_tail_x8_r0_body.mstack185 PRE_first_tail_x8_r0_body.mjobs185 PRE_first_tail_x8_r0_body.mffi185 PRE_first_tail_x8_r0_body.mtrace185 PRE_first_tail_x8_r0_body.mstores185 h

def PRE_first_tail_x8_r0_body.arrEl185_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE185_2665 : arrOf PRE_first_tail_x8_r0_body.s1783 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl185_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA185_2665 : isArrB PRE_first_tail_x8_r0_body.s1783 2665 = true
theorem PRE_first_tail_x8_r0_body.arr185_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1783.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl185_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE185_2665 PRE_first_tail_x8_r0_body.arrA185_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN185_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl185_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR185_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl185_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN185_2665

def PRE_first_tail_x8_r0_body.arrEl185_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE185_2673467 : arrOf PRE_first_tail_x8_r0_body.s1783 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl185_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA185_2673467 : isArrB PRE_first_tail_x8_r0_body.s1783 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr185_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1783.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl185_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE185_2673467 PRE_first_tail_x8_r0_body.arrA185_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN185_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl185_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR185_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl185_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN185_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k185 : isArrB PRE_first_tail_x8_r0_body.s1783 4910 = false
theorem PRE_first_tail_x8_r0_body.keep185 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1783 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k185 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr185_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl185_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ185
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 185 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1782`, the merged
state `PRE_first_tail_x8_r0_body.s1783`, the canonical state `PRE_first_tail_x8_r0_body.s1784`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl185 : PRE_first_tail_x8_r0_body.pl185.all (Nat.ble PRE_first_tail_x8_r0_body.s1782.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd185 : nodupT PRE_first_tail_x8_r0_body.pl185 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1185 : Nat.ble PRE_first_tail_x8_r0_body.s1782.next 2819792 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst185 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1782.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn185 : PRE_first_tail_x8_r0_body.s1784.next = PRE_first_tail_x8_r0_body.s1782.next + PRE_first_tail_x8_r0_body.pl185.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn185 : PRE_first_tail_x8_r0_body.s1783.next = 2819792
kernel_rfl PRE_first_tail_x8_r0_body.zgrow185 : Nat.ble PRE_first_tail_x8_r0_body.s1784.next PRE_first_tail_x8_r0_body.s1783.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh185 : PRE_first_tail_x8_r0_body.S1782.tab.all (fun e => PRE_first_tail_x8_r0_body.cws185.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd185 : nodupT PRE_first_tail_x8_r0_body.cws185 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi185 : PRE_first_tail_x8_r0_body.nr185.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1783.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt185 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1782.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg185_2665 : PRE_first_tail_x8_r0_body.s1784.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1784 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk185_2665 : (objOf PRE_first_tail_x8_r0_body.s1784 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm185_2665 : PRE_first_tail_x8_r0_body.s1783.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa185.obj (objOf PRE_first_tail_x8_r0_body.s1784 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1783 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg185_2673467 : PRE_first_tail_x8_r0_body.s1784.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1784 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk185_2673467 : (objOf PRE_first_tail_x8_r0_body.s1784 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm185_2673467 : PRE_first_tail_x8_r0_body.s1783.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa185.obj (objOf PRE_first_tail_x8_r0_body.s1784 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1783 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw185_4910 : (PRE_first_tail_x8_r0_body.s1784.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw185_2673472 : (PRE_first_tail_x8_r0_body.s1784.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw185_2673473 : (PRE_first_tail_x8_r0_body.s1784.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd185 : PRE_first_tail_x8_r0_body.cl185.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr185 : PRE_first_tail_x8_r0_body.st185.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1782.next || PRE_first_tail_x8_r0_body.cl185.contains b) = true
def PRE_first_tail_x8_r0_body.zl185 : List Nat := PRE_first_tail_x8_r0_body.cl185.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE185 : PRE_first_tail_x8_r0_body.zl185.map (fun a => PRE_first_tail_x8_r0_body.s1783.heap.get (PRE_first_tail_x8_r0_body.kappa185.a a)) = PRE_first_tail_x8_r0_body.zl185.map (fun a => (PRE_first_tail_x8_r0_body.s1784.heap.get a).map PRE_first_tail_x8_r0_body.kappa185.hobj)
theorem PRE_first_tail_x8_r0_body.zimg185 : HeapImg PRE_first_tail_x8_r0_body.kappa185 PRE_first_tail_x8_r0_body.s1784 PRE_first_tail_x8_r0_body.s1783 PRE_first_tail_x8_r0_body.zl185 := PRE_first_tail_x8_r0_body.zimgE185
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl185 : PRE_first_tail_x8_r0_body.s1783.ctl = PRE_first_tail_x8_r0_body.kappa185.ctl PRE_first_tail_x8_r0_body.s1784.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack185 : PRE_first_tail_x8_r0_body.s1783.stack = PRE_first_tail_x8_r0_body.s1784.stack.map PRE_first_tail_x8_r0_body.kappa185.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs185 : PRE_first_tail_x8_r0_body.s1783.jobs = PRE_first_tail_x8_r0_body.s1784.jobs.map PRE_first_tail_x8_r0_body.kappa185.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores185 : PRE_first_tail_x8_r0_body.s1783.stores = PRE_first_tail_x8_r0_body.kappa185.stores PRE_first_tail_x8_r0_body.s1784.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots185 : checkRootsSupp PRE_first_tail_x8_r0_body.s1784 7963 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC185 : PRE_first_tail_x8_r0_body.S1782.tab.length + PRE_first_tail_x8_r0_body.cws185.length = 7963
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap185 : PRE_first_tail_x8_r0_body.kappa185 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1782.next 2819792 PRE_first_tail_x8_r0_body.S1782.tab.length PRE_first_tail_x8_r0_body.pl185 (PRE_first_tail_x8_r0_body.nr185.map NumV.ref) PRE_first_tail_x8_r0_body.kd185.big
  PRE_first_tail_x8_r0_body.kd185.region PRE_first_tail_x8_r0_body.kd185.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin185 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1784.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc185 : Conv.jcleanListB (⟨21836, 18940, 2819772, 7963⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1784 PRE_first_tail_x8_r0_body.cl185 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB185 : noBigRootsP (fun i => !Conv.oldBigB (⟨21836, 18940, 2819772, 7963⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1784.trace PRE_first_tail_x8_r0_body.s1784 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm185 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18940 = true
theorem PRE_first_tail_x8_r0_body.cjcl185 (h : Conv.JClean (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1782) : Conv.JClean (⟨21836, 18940, 2819772, 7963⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1784 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle185)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap185 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd185 a ha)) PRE_first_tail_x8_r0_body.zjc185

end Host.Load.Run.Tpl
end

section -- st185/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st185.bodyLast from PRE_first_tail_x8_r0_body.st185.s1 to PRE_first_tail_x8_r0_body.st185.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st185.F PRE_first_tail_x8_r0_body.st185.s1).run PRE_first_tail_x8_r0_body.st185.S1 = some (PRE_first_tail_x8_r0_body.st185.s2, PRE_first_tail_x8_r0_body.st185.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st185.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st185.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st185.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st185.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st185/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st185.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st185.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st185.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st185.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st185.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st185.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st185.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st185.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st185.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st185.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st185.s0 PRE_first_tail_x8_r0_body.st185.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st185.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st185.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st185.s1 PRE_first_tail_x8_r0_body.st185.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st185/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st185.bodyK0F from PRE_first_tail_x8_r0_body.st185.s0 to PRE_first_tail_x8_r0_body.st185.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st185.F (PRE_first_tail_x8_r0_body.st185.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st185.ks 0).getD 0) PRE_first_tail_x8_r0_body.st185.s0 PRE_first_tail_x8_r0_body.st185.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st185.s1, PRE_first_tail_x8_r0_body.st185.S1)
theorem PRE_first_tail_x8_r0_body.st185.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st185.F (PRE_first_tail_x8_r0_body.st185.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st185.ks 0).getD 0) PRE_first_tail_x8_r0_body.st185.s0 PRE_first_tail_x8_r0_body.st185.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st185.s1, PRE_first_tail_x8_r0_body.st185.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st185.bodyOkLN_ok PRE_first_tail_x8_r0_body.st185.bodyK0F
end Host.Load.Run.Tpl
end

section -- st185/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st185.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st185.F (PRE_first_tail_x8_r0_body.st185.bodyOkL bytes rows) 214 PRE_first_tail_x8_r0_body.st185.s0 PRE_first_tail_x8_r0_body.st185.S0 = some (PRE_first_tail_x8_r0_body.st185.s1, PRE_first_tail_x8_r0_body.st185.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st185.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st185.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st185.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st185.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st185.F (PRE_first_tail_x8_r0_body.st185.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st185.s0
  S0 := PRE_first_tail_x8_r0_body.st185.S0
  s1 := PRE_first_tail_x8_r0_body.st185.s1
  S1 := PRE_first_tail_x8_r0_body.st185.S1
  s2 := PRE_first_tail_x8_r0_body.st185.s2
  S2 := PRE_first_tail_x8_r0_body.st185.S2
  n := 214
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st185.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st185.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st185.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st185.bodyHalt
  last := PRE_first_tail_x8_r0_body.st185.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st185.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC186
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 186 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1801` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa186` into the merged state
`PRE_first_tail_x8_r0_body.s1800`. -/

def PRE_first_tail_x8_r0_body.pl186 : List Nat := [2822359, 2821534, 2822365, 2822361, 2821536, 2822367]
def PRE_first_tail_x8_r0_body.nr186 : List Nat := [8066, 8065, 8041, 8049, 8054, 8059, 8064, 8038, 8039, 8040, 8047, 8048, 8036, 8043, 8044, 8045, 8046, 8042]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd186 : RData :=
  ⟨2821253, 2822402, Stage.setAll PTrie.nil [(2821247, 2822359), (2821248, 2821534), (2821249, 2822365), (2821250, 2822361), (2821251, 2821536), (2821252, 2822367)], Stage.setAll PTrie.nil [(21870, 21896), (21871, 21874), (21872, 21897)],
   21873, 21898, 18986, 18986, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(8036, .ref 8066), (8037, .ref 8065), (8038, .ref 8041), (8039, .ref 8049), (8040, .ref 8054), (8041, .ref 8059), (8042, .ref 8064), (8043, .ref 8038), (8044, .ref 8039), (8045, .ref 8040), (8046, .ref 8047), (8047, .ref 8048), (8048, .ref 8036), (8049, .ref 8043), (8050, .ref 8044), (8051, .ref 8045), (8052, .ref 8046), (8053, .ref 8042)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa186 : Map :=
  Conv.Map.compact 2821247 2822402 8036 PRE_first_tail_x8_r0_body.pl186 (PRE_first_tail_x8_r0_body.nr186.map NumV.ref) PRE_first_tail_x8_r0_body.kd186.big
    PRE_first_tail_x8_r0_body.kd186.region PRE_first_tail_x8_r0_body.kd186.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws186 : List Nat := [4178, 4179, 4180, 4181, 4182, 4183, 4184, 4185, 4186, 4187, 4188, 4189, 4190, 4191, 4192, 4193, 4194, 4195]
noncomputable def PRE_first_tail_x8_r0_body.crs186 : List SymE := PRE_first_tail_x8_r0_body.nr186.map fun r => (nth? PRE_first_tail_x8_r0_body.S1800.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta186 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws186 PRE_first_tail_x8_r0_body.crs186
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB186 : List Nat := [2665, 2672775, 2673467, 2820421, 2820966, 2821222]

kernel_rfl PRE_first_tail_x8_r0_body.ctab186 : PRE_first_tail_x8_r0_body.S1801.tab = PRE_first_tail_x8_r0_body.S1799.tab ++ PRE_first_tail_x8_r0_body.cws186.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace186 : PRE_first_tail_x8_r0_body.s1801.trace = PRE_first_tail_x8_r0_body.s1799.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext186 : PRE_first_tail_x8_r0_body.s1801.next = 2821253
kernel_rfl PRE_first_tail_x8_r0_body.ccounters186 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx.nnext) = (21873, 18986)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue186 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1800.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa186.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp186 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx.tokens.all (bSN 8054) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean186 : Conv.cleanListB 21873 131072 (fun r => Nat.ble 87492 r) PRE_first_tail_x8_r0_body.s1801
    (PRE_first_tail_x8_r0_body.wrB186 ++ (List.range 6).map (2821247 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs186 : bigsOutB 21873 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK186
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl186`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl186 : List Nat := [2665, 2672775, 2673467, 2820421, 2820966, 2821222, 2821247, 2821248, 2821249, 2821250, 2821251, 2821252]
def PRE_first_tail_x8_r0_body.clo186 : List Nat := [21850, 21863, 21869, 21870, 21871, 21872]
def PRE_first_tail_x8_r0_body.cln186 : List Nat := [18959, 18960, 18961, 18962, 18963, 18964, 18965, 18966, 18967, 18968, 18969, 18970, 18971, 18972, 18973, 18974, 18975, 18976, 18977, 18978, 18979, 18980, 18981, 18982, 18983, 18984, 18985]
def PRE_first_tail_x8_r0_body.cli186 : List Nat := [18959, 18960, 18961, 18962, 18963, 18964, 18965, 18966, 18967, 18968, 18969, 18970, 18971, 18972, 18973, 18974, 18975, 18976, 18977, 18978, 18979, 18980, 18981, 18982, 18983, 18984, 18985]
kernel_rfl PRE_first_tail_x8_r0_body.cheap186 : PRE_first_tail_x8_r0_body.s1801.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1799.heap (PRE_first_tail_x8_r0_body.cl186.filterMap fun a => (PRE_first_tail_x8_r0_body.s1801.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe186 : Nat.ble PRE_first_tail_x8_r0_body.s1799.next PRE_first_tail_x8_r0_body.s1801.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP186 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1799 PRE_first_tail_x8_r0_body.s1801 PRE_first_tail_x8_r0_body.cl186 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp186 : Conv.suppListB PRE_first_tail_x8_r0_body.s1801 8054 PRE_first_tail_x8_r0_body.cl186 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound186 : Conv.boundListB PRE_first_tail_x8_r0_body.s1801 PRE_first_tail_x8_r0_body.cl186 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK186 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln186.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK186 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo186.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK186 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli186.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst186 : Conv.sstListB 8054 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx PRE_first_tail_x8_r0_body.cln186 PRE_first_tail_x8_r0_body.clo186 PRE_first_tail_x8_r0_body.cli186 = true

end Host.Load.Run.Tpl
end

section -- SiteCl186
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA186 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo186.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd186 : (PRE_first_tail_x8_r0_body.clo186 ++ PRE_first_tail_x8_r0_body.cln186 ++ PRE_first_tail_x8_r0_body.cli186).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle186 : Conv.Cnt.leB (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) (⟨21873, 18986, 2821253, 8054⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck186 : Conv.ncleanListB (⟨21873, 18986, 2821253, 8054⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx PRE_first_tail_x8_r0_body.clo186 PRE_first_tail_x8_r0_body.cln186 PRE_first_tail_x8_r0_body.cli186 = true
theorem PRE_first_tail_x8_r0_body.cncl186 (h : Conv.NClean (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx) : Conv.NClean (⟨21873, 18986, 2821253, 8054⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle186 PRE_first_tail_x8_r0_body.ckA186 PRE_first_tail_x8_r0_body.cobjsK186 PRE_first_tail_x8_r0_body.cnodesK186 PRE_first_tail_x8_r0_body.citemsK186 PRE_first_tail_x8_r0_body.cbd186 PRE_first_tail_x8_r0_body.cck186

end Host.Load.Run.Tpl
end

section -- SiteS186
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 186 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc186 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P186 : LoadP := PRE_first_tail_x8_r0_body.Pc186.raise 18986
kernel_rfl PRE_first_tail_x8_r0_body.craise186 : Nat.ble PRE_first_tail_x8_r0_body.Pc186.N0 18986 = true
theorem PRE_first_tail_x8_r0_body.raised186 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc186 PRE_first_tail_x8_r0_body.P186 :=
  .inr ⟨18986, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise186, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_186 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_186 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1800.ffi)
def PRE_first_tail_x8_r0_body.khinv186 : PTrie Nat := Stage.setAll PTrie.nil [(21896, 21870), (21874, 21871), (21897, 21872)]
def PRE_first_tail_x8_r0_body.kninv186 : PTrie Nat := Stage.setAll PTrie.nil [(18959, 18959), (18960, 18960), (18961, 18961), (18962, 18962), (18963, 18963), (18964, 18964), (18965, 18965), (18966, 18966), (18967, 18967), (18968, 18968), (18969, 18969), (18970, 18970), (18971, 18971), (18972, 18972), (18973, 18973), (18974, 18974), (18975, 18975), (18976, 18976), (18977, 18977), (18978, 18978), (18979, 18979), (18980, 18980), (18981, 18981), (18982, 18982), (18983, 18983), (18984, 18984), (18985, 18985)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS186 : List Nat := [21850, 21863, 21869, 21870, 21871, 21872, 21873, 21874, 21875, 21876, 21877, 21878, 21879, 21880, 21881, 21882, 21883, 21884, 21885, 21886, 21887, 21888, 21889, 21890, 21891, 21892, 21893, 21894, 21895, 21896, 21897]
def PRE_first_tail_x8_r0_body.cnS186 : List Nat := List.range' 18959 27
def PRE_first_tail_x8_r0_body.ciS186 : List Nat := [] ++ List.range' 18959 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0186 : PRE_first_tail_x8_r0_body.kd186.nh0 = PRE_first_tail_x8_r0_body.cx0_186.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1186 : PRE_first_tail_x8_r0_body.kd186.nh1 = PRE_first_tail_x8_r0_body.cx1_186.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0186 : PRE_first_tail_x8_r0_body.kd186.nn0 = PRE_first_tail_x8_r0_body.cx0_186.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1186 : PRE_first_tail_x8_r0_body.kd186.nn1 = PRE_first_tail_x8_r0_body.cx1_186.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo186 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P186.lo && Nat.ble PRE_first_tail_x8_r0_body.P186.lo PRE_first_tail_x8_r0_body.cx0_186.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P186.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P186.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt186 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_186.mlx.next PRE_first_tail_x8_r0_body.cx1_186.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_186.mlx.nnext PRE_first_tail_x8_r0_body.cx1_186.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband186 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P186.NL && Nat.ble PRE_first_tail_x8_r0_body.P186.NL PRE_first_tail_x8_r0_body.P186.N0 && Nat.ble PRE_first_tail_x8_r0_body.P186.N0 PRE_first_tail_x8_r0_body.cx0_186.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow186 : PRE_first_tail_x8_r0_body.kd186.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren186 : checkRenG PRE_first_tail_x8_r0_body.kd186.hnd PRE_first_tail_x8_r0_body.khinv186 (phB PRE_first_tail_x8_r0_body.cx0_186.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband186 : PRE_first_tail_x8_r0_body.kd186.checkBand PRE_first_tail_x8_r0_body.P186.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos186 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd186.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren186 : checkRenG PRE_first_tail_x8_r0_body.kd186.node PRE_first_tail_x8_r0_body.kninv186 (pnB PRE_first_tail_x8_r0_body.cx0_186.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow186 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd186.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P186.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd186.nodeF j) PRE_first_tail_x8_r0_body.cx1_186.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a186 : PRE_first_tail_x8_r0_body.cx0_186.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b186 : PRE_first_tail_x8_r0_body.cx0_186.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1186 : PRE_first_tail_x8_r0_body.cx1_186.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend186 : PRE_first_tail_x8_r0_body.cx1_186.mlx.pending = PRE_first_tail_x8_r0_body.cx0_186.mlx.pending.map PRE_first_tail_x8_r0_body.kappa186.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh186 : PRE_first_tail_x8_r0_body.cx1_186.mlx.errh = PRE_first_tail_x8_r0_body.cx0_186.mlx.errh.map PRE_first_tail_x8_r0_body.kappa186.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles186 : PRE_first_tail_x8_r0_body.cx1_186.mlx.files = PRE_first_tail_x8_r0_body.cx0_186.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch186 : PRE_first_tail_x8_r0_body.cx1_186.mlx.arch = PRE_first_tail_x8_r0_body.cx0_186.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes186 : PRE_first_tail_x8_r0_body.cx1_186.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_186.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired186 : PRE_first_tail_x8_r0_body.cx1_186.mlx.wired = PRE_first_tail_x8_r0_body.cx0_186.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost186 : PRE_first_tail_x8_r0_body.cx1_186.host = PRE_first_tail_x8_r0_body.cx0_186.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd186`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0186 : PRE_first_tail_x8_r0_body.kd186.n0 = 2821253
kernel_rfl PRE_first_tail_x8_r0_body.ckn1186 : PRE_first_tail_x8_r0_body.kd186.n1 = 2822402
kernel_rfl PRE_first_tail_x8_r0_body.ckheap186 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd186.heap).all (fun x => Nat.ble 2821247 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl186 : (List.range 6).all (fun j => decide (PRE_first_tail_x8_r0_body.kd186.heap.get (2821247 + j) = nth? PRE_first_tail_x8_r0_body.pl186 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja186 : Nat.ble 2821247 2821247 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn186 : Nat.ble 8036 8036 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD186 : Nat.ble 2821247 PRE_first_tail_x8_r0_body.kd186.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn186 : Nat.ble 21870 PRE_first_tail_x8_r0_body.kd186.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn186 : Nat.ble 18959 PRE_first_tail_x8_r0_body.kd186.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb186 : Nat.ble 21870 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap186 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd186.heap).all (Nat.ble (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd186 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd186.hnd).all (Nat.ble (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode186 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd186.node).all (Nat.ble (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix186 : Conv.FixOld (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa186 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja186) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn186) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD186) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn186) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn186) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb186) PRE_first_tail_x8_r0_body.fheap186 PRE_first_tail_x8_r0_body.fhnd186 PRE_first_tail_x8_r0_body.fnode186
kernel_rfl PRE_first_tail_x8_r0_body.fcxn186 : (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn186 : (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0186 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_186.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_186.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk186 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd186.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A186 : PRE_first_tail_x8_r0_body.cx1_186.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS186.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_186.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O186 : PRE_first_tail_x8_r0_body.cx1_186.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS186.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_186.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N186 : PRE_first_tail_x8_r0_body.cx1_186.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS186.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_186.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I186 : PRE_first_tail_x8_r0_body.cx1_186.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS186.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_186.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd186 : (PRE_first_tail_x8_r0_body.clo186 ++ PRE_first_tail_x8_r0_body.cln186 ++ PRE_first_tail_x8_r0_body.cli186 ++ PRE_first_tail_x8_r0_body.cwS186 ++ PRE_first_tail_x8_r0_body.cnS186 ++ PRE_first_tail_x8_r0_body.ciS186).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW186 : PRE_first_tail_x8_r0_body.cwS186.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo186.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI186 : PRE_first_tail_x8_r0_body.ciS186.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli186.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN186 : PRE_first_tail_x8_r0_body.cnS186.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF186 : PRE_first_tail_x8_r0_body.cln186.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh186 : PRE_first_tail_x8_r0_body.clo186.all (handleOK PRE_first_tail_x8_r0_body.kappa186 PRE_first_tail_x8_r0_body.P186.lo PRE_first_tail_x8_r0_body.cx0_186.mlx PRE_first_tail_x8_r0_body.cx1_186.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo186 : PRE_first_tail_x8_r0_body.clo186.map (fun h => PRE_first_tail_x8_r0_body.cx1_186.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa186.handle h)) = PRE_first_tail_x8_r0_body.clo186.map (fun h => (PRE_first_tail_x8_r0_body.cx0_186.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa186.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok186 : PRE_first_tail_x8_r0_body.clo186.all (objOK PRE_first_tail_x8_r0_body.kappa186 PRE_first_tail_x8_r0_body.P186.NL PRE_first_tail_x8_r0_body.cx0_186.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd186 : PRE_first_tail_x8_r0_body.cln186.all (nodeOKF PRE_first_tail_x8_r0_body.kappa186 PRE_first_tail_x8_r0_body.P186 PRE_first_tail_x8_r0_body.cx0_186.mlx PRE_first_tail_x8_r0_body.cx1_186.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp186 : ((PRE_first_tail_x8_r0_body.cln186.filter (fullB PRE_first_tail_x8_r0_body.P186))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_186.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa186.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln186.filter (fullB PRE_first_tail_x8_r0_body.P186))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_186.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa186.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI186 : incrB PRE_first_tail_x8_r0_body.kd186.nodeF (List.range' 18959 27) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK186 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd186.node).all (fun k => Nat.ble 18959 k && Nat.blt k 18986) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL186 : (PRE_first_tail_x8_r0_body.cln186.filter (Nat.ble PRE_first_tail_x8_r0_body.P186.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd186.nodeF i) && (Nat.blt i 18986 || Nat.ble PRE_first_tail_x8_r0_body.kd186.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord186 : (PRE_first_tail_x8_r0_body.cln186.filter (Nat.ble PRE_first_tail_x8_r0_body.P186.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd186.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd186.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd186.nodeF j) (PRE_first_tail_x8_r0_body.kd186.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow186 PRE_first_tail_x8_r0_body.cnn1186 PRE_first_tail_x8_r0_body.fnordI186 PRE_first_tail_x8_r0_body.fnordK186 PRE_first_tail_x8_r0_body.fnordL186
kernel_rfl PRE_first_tail_x8_r0_body.fi186 : PRE_first_tail_x8_r0_body.cli186.all (pnB PRE_first_tail_x8_r0_body.cx0_186.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii186 : PRE_first_tail_x8_r0_body.cli186.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_186.mlx.items.get (PRE_first_tail_x8_r0_body.kappa186.node k) = (PRE_first_tail_x8_r0_body.cx0_186.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa186.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot186 (clean : Conv.NClean (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P186.NL) (cl : SSt (· < 8054) PRE_first_tail_x8_r0_body.cx0_186.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P186 8054 PRE_first_tail_x8_r0_body.kappa186 PRE_first_tail_x8_r0_body.kd186 PRE_first_tail_x8_r0_body.khinv186 PRE_first_tail_x8_r0_body.kninv186 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx PRE_first_tail_x8_r0_body.cx0_186.mlx PRE_first_tail_x8_r0_body.cx1_186.mlx (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo186 PRE_first_tail_x8_r0_body.cln186 PRE_first_tail_x8_r0_body.cli186 PRE_first_tail_x8_r0_body.cwS186 PRE_first_tail_x8_r0_body.cnS186 PRE_first_tail_x8_r0_body.ciS186 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0186, PRE_first_tail_x8_r0_body.cnh1186, PRE_first_tail_x8_r0_body.cnn0186, PRE_first_tail_x8_r0_body.cnn1186, PRE_first_tail_x8_r0_body.cplo186, PRE_first_tail_x8_r0_body.ccnt186, PRE_first_tail_x8_r0_body.cnband186, PRE_first_tail_x8_r0_body.chbelow186, PRE_first_tail_x8_r0_body.chren186, PRE_first_tail_x8_r0_body.cband186, PRE_first_tail_x8_r0_body.cnh1pos186, PRE_first_tail_x8_r0_body.cnren186, PRE_first_tail_x8_r0_body.cnlow186, PRE_first_tail_x8_r0_body.cabs0a186, PRE_first_tail_x8_r0_body.cabs0b186, PRE_first_tail_x8_r0_body.ctok1186, PRE_first_tail_x8_r0_body.cpend186, PRE_first_tail_x8_r0_body.cerrh186, PRE_first_tail_x8_r0_body.cfiles186, PRE_first_tail_x8_r0_body.carch186, PRE_first_tail_x8_r0_body.csizes186, PRE_first_tail_x8_r0_body.cwired186, PRE_first_tail_x8_r0_body.cfix186, clean, PRE_first_tail_x8_r0_body.fcxn186, PRE_first_tail_x8_r0_body.fcnn186, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0186, PRE_first_tail_x8_r0_body.fnk186, PRE_first_tail_x8_r0_body.ckA186, PRE_first_tail_x8_r0_body.cobjsK186, PRE_first_tail_x8_r0_body.cnodesK186, PRE_first_tail_x8_r0_body.citemsK186, PRE_first_tail_x8_r0_body.f1A186, PRE_first_tail_x8_r0_body.f1O186, PRE_first_tail_x8_r0_body.f1N186, PRE_first_tail_x8_r0_body.f1I186, PRE_first_tail_x8_r0_body.fbd186, PRE_first_tail_x8_r0_body.fincW186, PRE_first_tail_x8_r0_body.fincI186, PRE_first_tail_x8_r0_body.fincN186, PRE_first_tail_x8_r0_body.flnF186, PRE_first_tail_x8_r0_body.fh186, PRE_first_tail_x8_r0_body.fo186, PRE_first_tail_x8_r0_body.fok186, PRE_first_tail_x8_r0_body.fnd186, PRE_first_tail_x8_r0_body.fp186, PRE_first_tail_x8_r0_body.fnord186, PRE_first_tail_x8_r0_body.fi186, PRE_first_tail_x8_r0_body.fii186⟩
theorem PRE_first_tail_x8_r0_body.cnshift186 (clean : Conv.NClean (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P186.NL) (cl : SSt (· < 8054) PRE_first_tail_x8_r0_body.cx0_186.mlx) : NShift PRE_first_tail_x8_r0_body.P186 8054 PRE_first_tail_x8_r0_body.kappa186 PRE_first_tail_x8_r0_body.cx0_186 PRE_first_tail_x8_r0_body.cx1_186 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot186 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost186 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0186 PRE_first_tail_x8_r0_body.ckn1186 PRE_first_tail_x8_r0_body.ckheap186 PRE_first_tail_x8_r0_body.ckpl186)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_186 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1799.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_186 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1799.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_186 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1799.ffi) = some PRE_first_tail_x8_r0_body.fxC_186
kernel_rfl PRE_first_tail_x8_r0_body.okrC_186 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1799.ffi) = some PRE_first_tail_x8_r0_body.krC_186
noncomputable def PRE_first_tail_x8_r0_body.fx0_186 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1801.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_186 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1801.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_186 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1801.ffi) = some PRE_first_tail_x8_r0_body.fx0_186
kernel_rfl PRE_first_tail_x8_r0_body.okr0_186 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1801.ffi) = some PRE_first_tail_x8_r0_body.kr0_186
noncomputable def PRE_first_tail_x8_r0_body.fx1_186 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1800.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_186 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1800.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_186 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1800.ffi) = some PRE_first_tail_x8_r0_body.fx1_186
kernel_rfl PRE_first_tail_x8_r0_body.okr1_186 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1800.ffi) = some PRE_first_tail_x8_r0_body.kr1_186
kernel_rfl PRE_first_tail_x8_r0_body.ff0186 : PRE_first_tail_x8_r0_body.fx0_186 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_186 (PRE_first_tail_x8_r0_body.clo186.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_186.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1186 : PRE_first_tail_x8_r0_body.fx1_186 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_186 (PRE_first_tail_x8_r0_body.cwS186.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_186.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck186 : freedLB PRE_first_tail_x8_r0_body.kappa186 PRE_first_tail_x8_r0_body.cx0_186.mlx PRE_first_tail_x8_r0_body.fx0_186 PRE_first_tail_x8_r0_body.fx1_186 PRE_first_tail_x8_r0_body.clo186 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0186 : PRE_first_tail_x8_r0_body.kr0_186.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_186.flags (PRE_first_tail_x8_r0_body.clo186.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_186.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0186 : PRE_first_tail_x8_r0_body.kr0_186.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_186.targs (PRE_first_tail_x8_r0_body.clo186.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_186.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1186 : PRE_first_tail_x8_r0_body.kr1_186.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_186.flags (PRE_first_tail_x8_r0_body.cwS186.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_186.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1186 : PRE_first_tail_x8_r0_body.kr1_186.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_186.targs (PRE_first_tail_x8_r0_body.cwS186.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_186.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck186 : krecLB PRE_first_tail_x8_r0_body.kappa186 8054 PRE_first_tail_x8_r0_body.cx0_186.mlx PRE_first_tail_x8_r0_body.kr0_186 PRE_first_tail_x8_r0_body.kr1_186 PRE_first_tail_x8_r0_body.clo186 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn186 : Nat.ble 8036 8054 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge186 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1800.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1801.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR186 : pendRegB PRE_first_tail_x8_r0_body.kappa186 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe186 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1801.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1800.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift186 (clean : Conv.NClean (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P186.NL) (cl : SSt (· < 8054) PRE_first_tail_x8_r0_body.cx0_186.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_186.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_186.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_186.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1799.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_186.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P186 8054 PRE_first_tail_x8_r0_body.kappa186 PRE_first_tail_x8_r0_body.s1801.ffi PRE_first_tail_x8_r0_body.s1800.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift186 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue186, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp186 t ht),
    PRE_first_tail_x8_r0_body.cbridge186,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1801.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1800.ffi) (PRE_first_tail_x8_r0_body.cfoot186 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_186 PRE_first_tail_x8_r0_body.ofx1_186 hobjC PRE_first_tail_x8_r0_body.ff0186 PRE_first_tail_x8_r0_body.ff1186 PRE_first_tail_x8_r0_body.ffck186,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1801.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1800.ffi) (PRE_first_tail_x8_r0_body.cfoot186 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_186 PRE_first_tail_x8_r0_body.okr1_186 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn186) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0186 PRE_first_tail_x8_r0_body.fkt0186 PRE_first_tail_x8_r0_body.fkf1186 PRE_first_tail_x8_r0_body.fkt1186 PRE_first_tail_x8_r0_body.fkck186,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0186 PRE_first_tail_x8_r0_body.cnh1186 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe186) PRE_first_tail_x8_r0_body.cpendR186⟩

end Host.Load.Run.Tpl
end

section -- st186/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st186 0
host_stream_state PRE_first_tail_x8_r0_body.st186 1
host_stream_state PRE_first_tail_x8_r0_body.st186 2
host_stream_state PRE_first_tail_x8_r0_body.st186 3
host_stream_state PRE_first_tail_x8_r0_body.st186 4
host_stream_state PRE_first_tail_x8_r0_body.st186 5
end Host.Load.Run.Tpl
end

section -- Site186
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 186 of chain `PRE_first_tail_x8_r0_body`: `ssmW__g186__g187` (`recurWindow`), the call state `PRE_first_tail_x8_r0_body.s1799`, the merged state `PRE_first_tail_x8_r0_body.s1800`,
the site template `PRE_first_tail_x8_r0_body.st186` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1801`: the merge.
The footprint's facts are in `SiteF186`, the compaction's in `SiteC186`, `SiteK186`, `SiteNa186`, `SiteNb186`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso186 : PRE_first_tail_x8_r0_body.st186.s0 = { PRE_first_tail_x8_r0_body.s1799 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs186 : List Frame := PRE_first_tail_x8_r0_body.s1799.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_186 : PRE_first_tail_x8_r0_body.S1799.tab.length = 8036
kernel_rfl PRE_first_tail_x8_r0_body.tab0_186 : PRE_first_tail_x8_r0_body.st186.S0.tab = PRE_first_tail_x8_r0_body.S1799.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws186 : List Nat := [4147, 4148, 4149, 4150, 4151, 4152, 4153, 4154, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4163, 4164, 4165, 4166, 4167, 4168, 4169, 4170, 4171, 4172, 4173, 4174, 4175, 4176, 4177]
kernel_rfl PRE_first_tail_x8_r0_body.fresh186 : (PRE_first_tail_x8_r0_body.S1799.tab.all fun e => PRE_first_tail_x8_r0_body.ws186.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1799.oracle.all fun q => PRE_first_tail_x8_r0_body.ws186.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab186 : PRE_first_tail_x8_r0_body.S1800.tab = PRE_first_tail_x8_r0_body.S1799.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws186
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen186 : PRE_first_tail_x8_r0_body.st186.S5.tab.length - PRE_first_tail_x8_r0_body.st186.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged186`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap186 : PRE_first_tail_x8_r0_body.s1800.heap = PRE_first_tail_x8_r0_body.st186.s5.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext186 : PRE_first_tail_x8_r0_body.s1800.next = PRE_first_tail_x8_r0_body.st186.s5.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl186 : PRE_first_tail_x8_r0_body.s1800.ctl = PRE_first_tail_x8_r0_body.st186.s5.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack186 : PRE_first_tail_x8_r0_body.s1800.stack = PRE_first_tail_x8_r0_body.st186.s5.stack ++ PRE_first_tail_x8_r0_body.s1799.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs186 : PRE_first_tail_x8_r0_body.s1800.jobs = PRE_first_tail_x8_r0_body.st186.s5.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi186 : PRE_first_tail_x8_r0_body.s1800.ffi = PRE_first_tail_x8_r0_body.st186.s5.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace186 : PRE_first_tail_x8_r0_body.s1800.trace = PRE_first_tail_x8_r0_body.st186.s5.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores186 : PRE_first_tail_x8_r0_body.s1800.stores = PRE_first_tail_x8_r0_body.st186.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD186
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 186 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived186 : PRE_first_tail_x8_r0_body.nr186.map (fun r => nth? PRE_first_tail_x8_r0_body.st186.S5.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.un .int32 (SymE.un .int32 (SymE.var 10))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))]
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo186 : PRE_first_tail_x8_r0_body.nr186.all (Nat.ble 8036) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj186 : PRE_first_tail_x8_r0_body.cws186.all (fun c => !PRE_first_tail_x8_r0_body.ws186.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ186 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws186 PRE_first_tail_x8_r0_body.crs186 PRE_first_tail_x8_r0_body.ws186

end Host.Load.Run.Tpl
end

section -- st186/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st186`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st186.wrR : List (Nat × Nat) := [(2672775, 2672776), (2820421, 2820422), (2820966, 2820967), (2821222, 2821223)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st186.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st186.s5.heap PRE_first_tail_x8_r0_body.st186.wrR ++ freshOf PRE_first_tail_x8_r0_body.st186.s5.heap PRE_first_tail_x8_r0_body.st186.s0.next PRE_first_tail_x8_r0_body.st186.s5.next
noncomputable def PRE_first_tail_x8_r0_body.st186.wr : List Nat := PRE_first_tail_x8_r0_body.st186.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st186.heapFoot : PRE_first_tail_x8_r0_body.st186.s5.heap = setAll PRE_first_tail_x8_r0_body.st186.s0.heap PRE_first_tail_x8_r0_body.st186.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st186.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st186.s0.next PRE_first_tail_x8_r0_body.st186.s5.next = true
theorem PRE_first_tail_x8_r0_body.st186.grows : PRE_first_tail_x8_r0_body.st186.s0.next ≤ PRE_first_tail_x8_r0_body.st186.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st186.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st186.wh : List Nat := [21850, 21863, 21869, 21870, 21871, 21872, 21873, 21874, 21875, 21876, 21877, 21878, 21879, 21880, 21881, 21882, 21883, 21884, 21885, 21886, 21887, 21888, 21889, 21890, 21891, 21892, 21893, 21894, 21895, 21896, 21897]
def PRE_first_tail_x8_r0_body.st186.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st186.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st186.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st186.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st186.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st186.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st186.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st186.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st186.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st186.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF186
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 186 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB186 : nodupT PRE_first_tail_x8_r0_body.st186.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup186 : PRE_first_tail_x8_r0_body.st186.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB186).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB186 : PRE_first_tail_x8_r0_body.st186.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound186 : ∀ b ∈ PRE_first_tail_x8_r0_body.st186.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB186 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr186 := PRE_first_tail_x8_r0_body.st186.s5.trace.take 120
kernel_rfl PRE_first_tail_x8_r0_body.traceEq186 : PRE_first_tail_x8_r0_body.st186.s5.trace = PRE_first_tail_x8_r0_body.trFr186 ++ PRE_first_tail_x8_r0_body.st186.s0.trace
theorem PRE_first_tail_x8_r0_body.trace186 : ∃ fr, PRE_first_tail_x8_r0_body.st186.s5.trace = fr ++ PRE_first_tail_x8_r0_body.st186.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq186⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide186 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB186 : (PRE_first_tail_x8_r0_body.wide186.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st186.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix186 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide186, WFix Map.id (Present PRE_first_tail_x8_r0_body.st186.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB186 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL186
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 186 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1800`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO186 : PRE_first_tail_x8_r0_body.st186.S0.oracle = PRE_first_tail_x8_r0_body.st186.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B186 : PRE_first_tail_x8_r0_body.st186.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st186.s0.next || (PRE_first_tail_x8_r0_body.st186.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot186 : Conv.StageFoot PRE_first_tail_x8_r0_body.st186.wr PRE_first_tail_x8_r0_body.st186.s0 PRE_first_tail_x8_r0_body.st186.s5 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st186.heapFoot PRE_first_tail_x8_r0_body.wrNodup186 PRE_first_tail_x8_r0_body.wrBound186 PRE_first_tail_x8_r0_body.wr0B186 PRE_first_tail_x8_r0_body.st186.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged186 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st186.F.S → PRE_first_tail_x8_r0_body.st186.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st186.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st186.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs186 PRE_first_tail_x8_r0_body.st186.wr PRE_first_tail_x8_r0_body.s1799 PRE_first_tail_x8_r0_body.st186.s5 PRE_first_tail_x8_r0_body.st186.s0
      PRE_first_tail_x8_r0_body.st186.s5.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st186.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1800 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso186 PRE_first_tail_x8_r0_body.stFoot186 PRE_first_tail_x8_r0_body.wrNodup186 PRE_first_tail_x8_r0_body.wrBound186 PRE_first_tail_x8_r0_body.trace186 PRE_first_tail_x8_r0_body.mheap186
    PRE_first_tail_x8_r0_body.mnext186 PRE_first_tail_x8_r0_body.mctl186 PRE_first_tail_x8_r0_body.mstack186 PRE_first_tail_x8_r0_body.mjobs186 PRE_first_tail_x8_r0_body.mffi186 PRE_first_tail_x8_r0_body.mtrace186 PRE_first_tail_x8_r0_body.mstores186 h

def PRE_first_tail_x8_r0_body.arrEl186_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE186_2665 : arrOf PRE_first_tail_x8_r0_body.s1800 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl186_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA186_2665 : isArrB PRE_first_tail_x8_r0_body.s1800 2665 = true
theorem PRE_first_tail_x8_r0_body.arr186_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1800.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl186_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE186_2665 PRE_first_tail_x8_r0_body.arrA186_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN186_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl186_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR186_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl186_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN186_2665

def PRE_first_tail_x8_r0_body.arrEl186_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE186_2673467 : arrOf PRE_first_tail_x8_r0_body.s1800 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl186_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA186_2673467 : isArrB PRE_first_tail_x8_r0_body.s1800 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr186_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1800.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl186_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE186_2673467 PRE_first_tail_x8_r0_body.arrA186_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN186_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl186_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR186_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl186_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN186_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k186 : isArrB PRE_first_tail_x8_r0_body.s1800 4910 = false
theorem PRE_first_tail_x8_r0_body.keep186 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1800 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k186 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr186_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl186_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ186
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 186 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1799`, the merged
state `PRE_first_tail_x8_r0_body.s1800`, the canonical state `PRE_first_tail_x8_r0_body.s1801`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl186 : PRE_first_tail_x8_r0_body.pl186.all (Nat.ble PRE_first_tail_x8_r0_body.s1799.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd186 : nodupT PRE_first_tail_x8_r0_body.pl186 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1186 : Nat.ble PRE_first_tail_x8_r0_body.s1799.next 2822402 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst186 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1799.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn186 : PRE_first_tail_x8_r0_body.s1801.next = PRE_first_tail_x8_r0_body.s1799.next + PRE_first_tail_x8_r0_body.pl186.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn186 : PRE_first_tail_x8_r0_body.s1800.next = 2822402
kernel_rfl PRE_first_tail_x8_r0_body.zgrow186 : Nat.ble PRE_first_tail_x8_r0_body.s1801.next PRE_first_tail_x8_r0_body.s1800.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh186 : PRE_first_tail_x8_r0_body.S1799.tab.all (fun e => PRE_first_tail_x8_r0_body.cws186.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd186 : nodupT PRE_first_tail_x8_r0_body.cws186 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi186 : PRE_first_tail_x8_r0_body.nr186.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1800.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt186 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1799.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg186_2665 : PRE_first_tail_x8_r0_body.s1801.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1801 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk186_2665 : (objOf PRE_first_tail_x8_r0_body.s1801 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm186_2665 : PRE_first_tail_x8_r0_body.s1800.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa186.obj (objOf PRE_first_tail_x8_r0_body.s1801 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1800 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg186_2673467 : PRE_first_tail_x8_r0_body.s1801.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1801 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk186_2673467 : (objOf PRE_first_tail_x8_r0_body.s1801 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm186_2673467 : PRE_first_tail_x8_r0_body.s1800.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa186.obj (objOf PRE_first_tail_x8_r0_body.s1801 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1800 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw186_4910 : (PRE_first_tail_x8_r0_body.s1801.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw186_2673472 : (PRE_first_tail_x8_r0_body.s1801.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw186_2673473 : (PRE_first_tail_x8_r0_body.s1801.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd186 : PRE_first_tail_x8_r0_body.cl186.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr186 : PRE_first_tail_x8_r0_body.st186.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1799.next || PRE_first_tail_x8_r0_body.cl186.contains b) = true
def PRE_first_tail_x8_r0_body.zl186 : List Nat := PRE_first_tail_x8_r0_body.cl186.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE186 : PRE_first_tail_x8_r0_body.zl186.map (fun a => PRE_first_tail_x8_r0_body.s1800.heap.get (PRE_first_tail_x8_r0_body.kappa186.a a)) = PRE_first_tail_x8_r0_body.zl186.map (fun a => (PRE_first_tail_x8_r0_body.s1801.heap.get a).map PRE_first_tail_x8_r0_body.kappa186.hobj)
theorem PRE_first_tail_x8_r0_body.zimg186 : HeapImg PRE_first_tail_x8_r0_body.kappa186 PRE_first_tail_x8_r0_body.s1801 PRE_first_tail_x8_r0_body.s1800 PRE_first_tail_x8_r0_body.zl186 := PRE_first_tail_x8_r0_body.zimgE186
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl186 : PRE_first_tail_x8_r0_body.s1800.ctl = PRE_first_tail_x8_r0_body.kappa186.ctl PRE_first_tail_x8_r0_body.s1801.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack186 : PRE_first_tail_x8_r0_body.s1800.stack = PRE_first_tail_x8_r0_body.s1801.stack.map PRE_first_tail_x8_r0_body.kappa186.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs186 : PRE_first_tail_x8_r0_body.s1800.jobs = PRE_first_tail_x8_r0_body.s1801.jobs.map PRE_first_tail_x8_r0_body.kappa186.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores186 : PRE_first_tail_x8_r0_body.s1800.stores = PRE_first_tail_x8_r0_body.kappa186.stores PRE_first_tail_x8_r0_body.s1801.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots186 : checkRootsSupp PRE_first_tail_x8_r0_body.s1801 8054 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC186 : PRE_first_tail_x8_r0_body.S1799.tab.length + PRE_first_tail_x8_r0_body.cws186.length = 8054
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap186 : PRE_first_tail_x8_r0_body.kappa186 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1799.next 2822402 PRE_first_tail_x8_r0_body.S1799.tab.length PRE_first_tail_x8_r0_body.pl186 (PRE_first_tail_x8_r0_body.nr186.map NumV.ref) PRE_first_tail_x8_r0_body.kd186.big
  PRE_first_tail_x8_r0_body.kd186.region PRE_first_tail_x8_r0_body.kd186.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin186 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1801.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc186 : Conv.jcleanListB (⟨21873, 18986, 2821253, 8054⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1801 PRE_first_tail_x8_r0_body.cl186 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB186 : noBigRootsP (fun i => !Conv.oldBigB (⟨21873, 18986, 2821253, 8054⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1801.trace PRE_first_tail_x8_r0_body.s1801 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm186 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18959 = true
theorem PRE_first_tail_x8_r0_body.cjcl186 (h : Conv.JClean (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1799) : Conv.JClean (⟨21873, 18986, 2821253, 8054⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1801 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle186)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap186 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd186 a ha)) PRE_first_tail_x8_r0_body.zjc186

end Host.Load.Run.Tpl
end

section -- st186/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st186.bodyLast from PRE_first_tail_x8_r0_body.st186.s4 to PRE_first_tail_x8_r0_body.st186.s5 :
  interpS (step PRE_first_tail_x8_r0_body.st186.F PRE_first_tail_x8_r0_body.st186.s4).run PRE_first_tail_x8_r0_body.st186.S4 = some (PRE_first_tail_x8_r0_body.st186.s5, PRE_first_tail_x8_r0_body.st186.S5)
kernel_rfl PRE_first_tail_x8_r0_body.st186.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st186.s4.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st186.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st186.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st186/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st186.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st186.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st186.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st186.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st186.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st186.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st186.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st186.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st186.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st186.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st186.s0 PRE_first_tail_x8_r0_body.st186.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st186.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st186.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st186.s4 PRE_first_tail_x8_r0_body.st186.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st186/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st186.bodyK0F from PRE_first_tail_x8_r0_body.st186.s0 to PRE_first_tail_x8_r0_body.st186.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st186.F (PRE_first_tail_x8_r0_body.st186.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st186.ks 0).getD 0) PRE_first_tail_x8_r0_body.st186.s0 PRE_first_tail_x8_r0_body.st186.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st186.s1, PRE_first_tail_x8_r0_body.st186.S1)
theorem PRE_first_tail_x8_r0_body.st186.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st186.F (PRE_first_tail_x8_r0_body.st186.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st186.ks 0).getD 0) PRE_first_tail_x8_r0_body.st186.s0 PRE_first_tail_x8_r0_body.st186.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st186.s1, PRE_first_tail_x8_r0_body.st186.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st186.bodyOkLN_ok PRE_first_tail_x8_r0_body.st186.bodyK0F
end Host.Load.Run.Tpl
end

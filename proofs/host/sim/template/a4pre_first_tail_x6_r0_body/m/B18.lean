import host.sim.template.a4pre_first_tail_x6_r0_body.m.B17
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
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B00
import host.sim.conv.Compact
import host.sim.native.RebigR
import host.sim.template.Sigma
import host.sim.template.NShiftGen
import host.sim.conv.Closed
import host.sim.conv.NClean
import host.sim.conv.CompactFull
import host.sim.template.FootGen
import host.sim.template.a4pre_first_tail_x6_r0_body.States
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
import host.sim.conv.CallPieces

section -- st21/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st21`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st21.wrR : List (Nat × Nat) := [(2672353, 2672354)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st21.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st21.s3.heap PRE_first_tail_x6_r0_body.st21.wrR ++ freshOf PRE_first_tail_x6_r0_body.st21.s3.heap PRE_first_tail_x6_r0_body.st21.s0.next PRE_first_tail_x6_r0_body.st21.s3.next
noncomputable def PRE_first_tail_x6_r0_body.st21.wr : List Nat := PRE_first_tail_x6_r0_body.st21.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st21.heapFoot : PRE_first_tail_x6_r0_body.st21.s3.heap = setAll PRE_first_tail_x6_r0_body.st21.s0.heap PRE_first_tail_x6_r0_body.st21.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st21.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st21.s0.next PRE_first_tail_x6_r0_body.st21.s3.next = true
theorem PRE_first_tail_x6_r0_body.st21.grows : PRE_first_tail_x6_r0_body.st21.s0.next ≤ PRE_first_tail_x6_r0_body.st21.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st21.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st21.wh : List Nat := [18629, 18630, 18631, 18632, 18633, 18634]
def PRE_first_tail_x6_r0_body.st21.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st21.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st21.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st21.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st21.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st21.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st21.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st21.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st21.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st21.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF21
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 21 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB21 : nodupT PRE_first_tail_x6_r0_body.st21.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup21 : PRE_first_tail_x6_r0_body.st21.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB21).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB21 : PRE_first_tail_x6_r0_body.st21.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound21 : ∀ b ∈ PRE_first_tail_x6_r0_body.st21.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB21 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr21 := PRE_first_tail_x6_r0_body.st21.s3.trace.take 26
kernel_rfl PRE_first_tail_x6_r0_body.traceEq21 : PRE_first_tail_x6_r0_body.st21.s3.trace = PRE_first_tail_x6_r0_body.trFr21 ++ PRE_first_tail_x6_r0_body.st21.s0.trace
theorem PRE_first_tail_x6_r0_body.trace21 : ∃ fr, PRE_first_tail_x6_r0_body.st21.s3.trace = fr ++ PRE_first_tail_x6_r0_body.st21.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq21⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide21 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB21 : (PRE_first_tail_x6_r0_body.wide21.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st21.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix21 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide21, WFix Map.id (Present PRE_first_tail_x6_r0_body.st21.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB21 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL21
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 21 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s218`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO21 : PRE_first_tail_x6_r0_body.st21.S0.oracle = PRE_first_tail_x6_r0_body.st21.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B21 : PRE_first_tail_x6_r0_body.st21.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st21.s0.next || (PRE_first_tail_x6_r0_body.st21.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot21 : Conv.StageFoot PRE_first_tail_x6_r0_body.st21.wr PRE_first_tail_x6_r0_body.st21.s0 PRE_first_tail_x6_r0_body.st21.s3 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st21.heapFoot PRE_first_tail_x6_r0_body.wrNodup21 PRE_first_tail_x6_r0_body.wrBound21 PRE_first_tail_x6_r0_body.wr0B21 PRE_first_tail_x6_r0_body.st21.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged21 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st21.F.S → PRE_first_tail_x6_r0_body.st21.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st21.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st21.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs21 PRE_first_tail_x6_r0_body.st21.wr PRE_first_tail_x6_r0_body.s217 PRE_first_tail_x6_r0_body.st21.s3 PRE_first_tail_x6_r0_body.st21.s0
      PRE_first_tail_x6_r0_body.st21.s3.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st21.F FR W stk M ν K PRE_first_tail_x6_r0_body.s218 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso21 PRE_first_tail_x6_r0_body.stFoot21 PRE_first_tail_x6_r0_body.wrNodup21 PRE_first_tail_x6_r0_body.wrBound21 PRE_first_tail_x6_r0_body.trace21 PRE_first_tail_x6_r0_body.mheap21
    PRE_first_tail_x6_r0_body.mnext21 PRE_first_tail_x6_r0_body.mctl21 PRE_first_tail_x6_r0_body.mstack21 PRE_first_tail_x6_r0_body.mjobs21 PRE_first_tail_x6_r0_body.mffi21 PRE_first_tail_x6_r0_body.mtrace21 PRE_first_tail_x6_r0_body.mstores21 h

def PRE_first_tail_x6_r0_body.arrEl21_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE21_2665 : arrOf PRE_first_tail_x6_r0_body.s218 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl21_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA21_2665 : isArrB PRE_first_tail_x6_r0_body.s218 2665 = true
theorem PRE_first_tail_x6_r0_body.arr21_2665 : ∃ o, PRE_first_tail_x6_r0_body.s218.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl21_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE21_2665 PRE_first_tail_x6_r0_body.arrA21_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN21_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl21_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR21_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl21_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN21_2665

def PRE_first_tail_x6_r0_body.arrEl21_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE21_2673467 : arrOf PRE_first_tail_x6_r0_body.s218 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl21_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA21_2673467 : isArrB PRE_first_tail_x6_r0_body.s218 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr21_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s218.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl21_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE21_2673467 PRE_first_tail_x6_r0_body.arrA21_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN21_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl21_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR21_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl21_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN21_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k21 : isArrB PRE_first_tail_x6_r0_body.s218 4910 = false
theorem PRE_first_tail_x6_r0_body.keep21 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s218 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k21 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr21_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl21_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ21
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 21 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s217`, the merged
state `PRE_first_tail_x6_r0_body.s218`, the canonical state `PRE_first_tail_x6_r0_body.s219`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl21 : PRE_first_tail_x6_r0_body.pl21.all (Nat.ble PRE_first_tail_x6_r0_body.s217.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd21 : nodupT PRE_first_tail_x6_r0_body.pl21 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn121 : Nat.ble PRE_first_tail_x6_r0_body.s217.next 2692273 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst21 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s217.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn21 : PRE_first_tail_x6_r0_body.s219.next = PRE_first_tail_x6_r0_body.s217.next + PRE_first_tail_x6_r0_body.pl21.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn21 : PRE_first_tail_x6_r0_body.s218.next = 2692273
kernel_rfl PRE_first_tail_x6_r0_body.zgrow21 : Nat.ble PRE_first_tail_x6_r0_body.s219.next PRE_first_tail_x6_r0_body.s218.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh21 : PRE_first_tail_x6_r0_body.S217.tab.all (fun e => PRE_first_tail_x6_r0_body.cws21.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd21 : nodupT PRE_first_tail_x6_r0_body.cws21 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi21 : PRE_first_tail_x6_r0_body.nr21.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S218.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt21 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s217.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg21_2665 : PRE_first_tail_x6_r0_body.s219.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s219 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk21_2665 : (objOf PRE_first_tail_x6_r0_body.s219 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm21_2665 : PRE_first_tail_x6_r0_body.s218.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa21.obj (objOf PRE_first_tail_x6_r0_body.s219 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s218 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg21_2673467 : PRE_first_tail_x6_r0_body.s219.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s219 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk21_2673467 : (objOf PRE_first_tail_x6_r0_body.s219 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm21_2673467 : PRE_first_tail_x6_r0_body.s218.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa21.obj (objOf PRE_first_tail_x6_r0_body.s219 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s218 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw21_4910 : (PRE_first_tail_x6_r0_body.s219.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw21_2673472 : (PRE_first_tail_x6_r0_body.s219.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw21_2673473 : (PRE_first_tail_x6_r0_body.s219.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd21 : PRE_first_tail_x6_r0_body.cl21.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr21 : PRE_first_tail_x6_r0_body.st21.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s217.next || PRE_first_tail_x6_r0_body.cl21.contains b) = true
def PRE_first_tail_x6_r0_body.zl21 : List Nat := PRE_first_tail_x6_r0_body.cl21.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE21 : PRE_first_tail_x6_r0_body.zl21.map (fun a => PRE_first_tail_x6_r0_body.s218.heap.get (PRE_first_tail_x6_r0_body.kappa21.a a)) = PRE_first_tail_x6_r0_body.zl21.map (fun a => (PRE_first_tail_x6_r0_body.s219.heap.get a).map PRE_first_tail_x6_r0_body.kappa21.hobj)
theorem PRE_first_tail_x6_r0_body.zimg21 : HeapImg PRE_first_tail_x6_r0_body.kappa21 PRE_first_tail_x6_r0_body.s219 PRE_first_tail_x6_r0_body.s218 PRE_first_tail_x6_r0_body.zl21 := PRE_first_tail_x6_r0_body.zimgE21
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl21 : PRE_first_tail_x6_r0_body.s218.ctl = PRE_first_tail_x6_r0_body.kappa21.ctl PRE_first_tail_x6_r0_body.s219.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack21 : PRE_first_tail_x6_r0_body.s218.stack = PRE_first_tail_x6_r0_body.s219.stack.map PRE_first_tail_x6_r0_body.kappa21.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs21 : PRE_first_tail_x6_r0_body.s218.jobs = PRE_first_tail_x6_r0_body.s219.jobs.map PRE_first_tail_x6_r0_body.kappa21.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores21 : PRE_first_tail_x6_r0_body.s218.stores = PRE_first_tail_x6_r0_body.kappa21.stores PRE_first_tail_x6_r0_body.s219.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots21 : checkRootsSupp PRE_first_tail_x6_r0_body.s219 996 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC21 : PRE_first_tail_x6_r0_body.S217.tab.length + PRE_first_tail_x6_r0_body.cws21.length = 996
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap21 : PRE_first_tail_x6_r0_body.kappa21 = Conv.Map.compact PRE_first_tail_x6_r0_body.s217.next 2692273 PRE_first_tail_x6_r0_body.S217.tab.length PRE_first_tail_x6_r0_body.pl21 (PRE_first_tail_x6_r0_body.nr21.map NumV.ref) PRE_first_tail_x6_r0_body.kd21.big
  PRE_first_tail_x6_r0_body.kd21.region PRE_first_tail_x6_r0_body.kd21.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin21 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s219.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc21 : Conv.jcleanListB (⟨18633, 15719, 2691923, 996⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s219 PRE_first_tail_x6_r0_body.cl21 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB21 : noBigRootsP (fun i => !Conv.oldBigB (⟨18633, 15719, 2691923, 996⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s219.trace PRE_first_tail_x6_r0_body.s219 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm21 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15713 = true
theorem PRE_first_tail_x6_r0_body.cjcl21 (h : Conv.JClean (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s217) : Conv.JClean (⟨18633, 15719, 2691923, 996⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s219 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle21)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap21 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd21 a ha)) PRE_first_tail_x6_r0_body.zjc21

end Host.Load.Run.Tpl
end

section -- st21/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st21.bodyLast from PRE_first_tail_x6_r0_body.st21.s2 to PRE_first_tail_x6_r0_body.st21.s3 :
  interpS (step PRE_first_tail_x6_r0_body.st21.F PRE_first_tail_x6_r0_body.st21.s2).run PRE_first_tail_x6_r0_body.st21.S2 = some (PRE_first_tail_x6_r0_body.st21.s3, PRE_first_tail_x6_r0_body.st21.S3)
kernel_rfl PRE_first_tail_x6_r0_body.st21.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st21.s2.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st21.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st21.s3.stack = true

end Host.Load.Run.Tpl
end

section -- st21/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st21.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st21.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st21.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st21.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st21.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st21.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st21.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st21.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st21.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st21.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st21.s0 PRE_first_tail_x6_r0_body.st21.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st21.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st21.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st21.s2 PRE_first_tail_x6_r0_body.st21.S2) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st21/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st21.bodyK0F from PRE_first_tail_x6_r0_body.st21.s0 to PRE_first_tail_x6_r0_body.st21.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st21.F (PRE_first_tail_x6_r0_body.st21.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st21.ks 0).getD 0) PRE_first_tail_x6_r0_body.st21.s0 PRE_first_tail_x6_r0_body.st21.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st21.s1, PRE_first_tail_x6_r0_body.st21.S1)
theorem PRE_first_tail_x6_r0_body.st21.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st21.F (PRE_first_tail_x6_r0_body.st21.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st21.ks 0).getD 0) PRE_first_tail_x6_r0_body.st21.s0 PRE_first_tail_x6_r0_body.st21.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st21.s1, PRE_first_tail_x6_r0_body.st21.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st21.bodyOkLN_ok PRE_first_tail_x6_r0_body.st21.bodyK0F
end Host.Load.Run.Tpl
end

section -- st21/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st21.bodyK1F from PRE_first_tail_x6_r0_body.st21.s1 to PRE_first_tail_x6_r0_body.st21.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st21.F (PRE_first_tail_x6_r0_body.st21.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st21.ks 1).getD 0) PRE_first_tail_x6_r0_body.st21.s1 PRE_first_tail_x6_r0_body.st21.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st21.s2, PRE_first_tail_x6_r0_body.st21.S2)
theorem PRE_first_tail_x6_r0_body.st21.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st21.F (PRE_first_tail_x6_r0_body.st21.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st21.ks 1).getD 0) PRE_first_tail_x6_r0_body.st21.s1 PRE_first_tail_x6_r0_body.st21.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st21.s2, PRE_first_tail_x6_r0_body.st21.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st21.bodyOkLN_ok PRE_first_tail_x6_r0_body.st21.bodyK1F
end Host.Load.Run.Tpl
end

section -- st21/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st21.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st21.F (PRE_first_tail_x6_r0_body.st21.bodyOkL bytes rows) 3452 PRE_first_tail_x6_r0_body.st21.s0 PRE_first_tail_x6_r0_body.st21.S0 = some (PRE_first_tail_x6_r0_body.st21.s2, PRE_first_tail_x6_r0_body.st21.S2) :=
  runOk_trans PRE_first_tail_x6_r0_body.st21.F (PRE_first_tail_x6_r0_body.st21.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st21.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st21.ks 1).getD 0) PRE_first_tail_x6_r0_body.st21.s0 PRE_first_tail_x6_r0_body.st21.s1 PRE_first_tail_x6_r0_body.st21.s2 PRE_first_tail_x6_r0_body.st21.S0 PRE_first_tail_x6_r0_body.st21.S1 PRE_first_tail_x6_r0_body.st21.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st21.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st21.bodyK1 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st21.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st21.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st21.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st21.F (PRE_first_tail_x6_r0_body.st21.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st21.s0
  S0 := PRE_first_tail_x6_r0_body.st21.S0
  s1 := PRE_first_tail_x6_r0_body.st21.s2
  S1 := PRE_first_tail_x6_r0_body.st21.S2
  s2 := PRE_first_tail_x6_r0_body.st21.s3
  S2 := PRE_first_tail_x6_r0_body.st21.S3
  n := 3452
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st21.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st21.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st21.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st21.bodyHalt
  last := PRE_first_tail_x6_r0_body.st21.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st21.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC22
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 22 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s227` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa22` into the merged state
`PRE_first_tail_x6_r0_body.s226`. -/

def PRE_first_tail_x6_r0_body.pl22 : List Nat := []
def PRE_first_tail_x6_r0_body.nr22 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd22 : RData :=
  ⟨2692505, 2692507, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18646, 18646, 15729, 15729, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa22 : Map :=
  Conv.Map.compact 2692505 2692507 1019 PRE_first_tail_x6_r0_body.pl22 (PRE_first_tail_x6_r0_body.nr22.map NumV.ref) PRE_first_tail_x6_r0_body.kd22.big
    PRE_first_tail_x6_r0_body.kd22.region PRE_first_tail_x6_r0_body.kd22.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws22 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs22 : List SymE := PRE_first_tail_x6_r0_body.nr22.map fun r => (nth? PRE_first_tail_x6_r0_body.S226.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta22 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws22 PRE_first_tail_x6_r0_body.crs22
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB22 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab22 : PRE_first_tail_x6_r0_body.S227.tab = PRE_first_tail_x6_r0_body.S225.tab ++ PRE_first_tail_x6_r0_body.cws22.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace22 : PRE_first_tail_x6_r0_body.s227.trace = PRE_first_tail_x6_r0_body.s225.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext22 : PRE_first_tail_x6_r0_body.s227.next = 2692505
kernel_rfl PRE_first_tail_x6_r0_body.ccounters22 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx.nnext) = (18646, 15729)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue22 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s226.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa22.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp22 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx.tokens.all (bSN 1019) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean22 : Conv.cleanListB 18646 131072 (fun r => Nat.ble 74584 r) PRE_first_tail_x6_r0_body.s227
    (PRE_first_tail_x6_r0_body.wrB22 ++ (List.range 0).map (2692505 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs22 : bigsOutB 18646 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK22
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl22`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl22 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo22 : List Nat := []
def PRE_first_tail_x6_r0_body.cln22 : List Nat := []
def PRE_first_tail_x6_r0_body.cli22 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap22 : PRE_first_tail_x6_r0_body.s227.heap = Stage.setAll PRE_first_tail_x6_r0_body.s225.heap (PRE_first_tail_x6_r0_body.cl22.filterMap fun a => (PRE_first_tail_x6_r0_body.s227.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe22 : Nat.ble PRE_first_tail_x6_r0_body.s225.next PRE_first_tail_x6_r0_body.s227.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP22 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s225 PRE_first_tail_x6_r0_body.s227 PRE_first_tail_x6_r0_body.cl22 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp22 : Conv.suppListB PRE_first_tail_x6_r0_body.s227 1019 PRE_first_tail_x6_r0_body.cl22 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound22 : Conv.boundListB PRE_first_tail_x6_r0_body.s227 PRE_first_tail_x6_r0_body.cl22 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK22 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln22.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK22 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo22.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK22 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli22.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst22 : Conv.sstListB 1019 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx PRE_first_tail_x6_r0_body.cln22 PRE_first_tail_x6_r0_body.clo22 PRE_first_tail_x6_r0_body.cli22 = true

end Host.Load.Run.Tpl
end

section -- SiteCl22
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA22 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo22.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd22 : (PRE_first_tail_x6_r0_body.clo22 ++ PRE_first_tail_x6_r0_body.cln22 ++ PRE_first_tail_x6_r0_body.cli22).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle22 : Conv.Cnt.leB (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck22 : Conv.ncleanListB (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx PRE_first_tail_x6_r0_body.clo22 PRE_first_tail_x6_r0_body.cln22 PRE_first_tail_x6_r0_body.cli22 = true
theorem PRE_first_tail_x6_r0_body.cncl22 (h : Conv.NClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx) : Conv.NClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle22 PRE_first_tail_x6_r0_body.ckA22 PRE_first_tail_x6_r0_body.cobjsK22 PRE_first_tail_x6_r0_body.cnodesK22 PRE_first_tail_x6_r0_body.citemsK22 PRE_first_tail_x6_r0_body.cbd22 PRE_first_tail_x6_r0_body.cck22

end Host.Load.Run.Tpl
end

section -- SiteS22
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 22 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc22 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P22 : LoadP := PRE_first_tail_x6_r0_body.Pc22.raise 15729
kernel_rfl PRE_first_tail_x6_r0_body.craise22 : Nat.ble PRE_first_tail_x6_r0_body.Pc22.N0 15729 = true
theorem PRE_first_tail_x6_r0_body.raised22 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc22 PRE_first_tail_x6_r0_body.P22 :=
  .inr ⟨15729, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise22, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_22 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_22 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s226.ffi)
def PRE_first_tail_x6_r0_body.khinv22 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv22 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS22 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS22 : List Nat := List.range' 15729 0
def PRE_first_tail_x6_r0_body.ciS22 : List Nat := [] ++ List.range' 15729 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh022 : PRE_first_tail_x6_r0_body.kd22.nh0 = PRE_first_tail_x6_r0_body.cx0_22.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh122 : PRE_first_tail_x6_r0_body.kd22.nh1 = PRE_first_tail_x6_r0_body.cx1_22.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn022 : PRE_first_tail_x6_r0_body.kd22.nn0 = PRE_first_tail_x6_r0_body.cx0_22.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn122 : PRE_first_tail_x6_r0_body.kd22.nn1 = PRE_first_tail_x6_r0_body.cx1_22.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo22 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P22.lo && Nat.ble PRE_first_tail_x6_r0_body.P22.lo PRE_first_tail_x6_r0_body.cx0_22.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P22.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P22.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt22 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_22.mlx.next PRE_first_tail_x6_r0_body.cx1_22.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_22.mlx.nnext PRE_first_tail_x6_r0_body.cx1_22.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband22 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P22.NL && Nat.ble PRE_first_tail_x6_r0_body.P22.NL PRE_first_tail_x6_r0_body.P22.N0 && Nat.ble PRE_first_tail_x6_r0_body.P22.N0 PRE_first_tail_x6_r0_body.cx0_22.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow22 : PRE_first_tail_x6_r0_body.kd22.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren22 : checkRenG PRE_first_tail_x6_r0_body.kd22.hnd PRE_first_tail_x6_r0_body.khinv22 (phB PRE_first_tail_x6_r0_body.cx0_22.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband22 : PRE_first_tail_x6_r0_body.kd22.checkBand PRE_first_tail_x6_r0_body.P22.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos22 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd22.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren22 : checkRenG PRE_first_tail_x6_r0_body.kd22.node PRE_first_tail_x6_r0_body.kninv22 (pnB PRE_first_tail_x6_r0_body.cx0_22.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow22 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd22.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P22.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd22.nodeF j) PRE_first_tail_x6_r0_body.cx1_22.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a22 : PRE_first_tail_x6_r0_body.cx0_22.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b22 : PRE_first_tail_x6_r0_body.cx0_22.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok122 : PRE_first_tail_x6_r0_body.cx1_22.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend22 : PRE_first_tail_x6_r0_body.cx1_22.mlx.pending = PRE_first_tail_x6_r0_body.cx0_22.mlx.pending.map PRE_first_tail_x6_r0_body.kappa22.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh22 : PRE_first_tail_x6_r0_body.cx1_22.mlx.errh = PRE_first_tail_x6_r0_body.cx0_22.mlx.errh.map PRE_first_tail_x6_r0_body.kappa22.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles22 : PRE_first_tail_x6_r0_body.cx1_22.mlx.files = PRE_first_tail_x6_r0_body.cx0_22.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch22 : PRE_first_tail_x6_r0_body.cx1_22.mlx.arch = PRE_first_tail_x6_r0_body.cx0_22.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes22 : PRE_first_tail_x6_r0_body.cx1_22.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_22.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired22 : PRE_first_tail_x6_r0_body.cx1_22.mlx.wired = PRE_first_tail_x6_r0_body.cx0_22.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost22 : PRE_first_tail_x6_r0_body.cx1_22.host = PRE_first_tail_x6_r0_body.cx0_22.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd22`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn022 : PRE_first_tail_x6_r0_body.kd22.n0 = 2692505
kernel_rfl PRE_first_tail_x6_r0_body.ckn122 : PRE_first_tail_x6_r0_body.kd22.n1 = 2692507
kernel_rfl PRE_first_tail_x6_r0_body.ckheap22 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd22.heap).all (fun x => Nat.ble 2692505 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl22 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd22.heap.get (2692505 + j) = nth? PRE_first_tail_x6_r0_body.pl22 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja22 : Nat.ble 2692505 2692505 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn22 : Nat.ble 1019 1019 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD22 : Nat.ble 2692505 PRE_first_tail_x6_r0_body.kd22.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn22 : Nat.ble 18646 PRE_first_tail_x6_r0_body.kd22.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn22 : Nat.ble 15729 PRE_first_tail_x6_r0_body.kd22.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb22 : Nat.ble 18646 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap22 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd22.heap).all (Nat.ble (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd22 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd22.hnd).all (Nat.ble (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode22 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd22.node).all (Nat.ble (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix22 : Conv.FixOld (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa22 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja22) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn22) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD22) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn22) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn22) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb22) PRE_first_tail_x6_r0_body.fheap22 PRE_first_tail_x6_r0_body.fhnd22 PRE_first_tail_x6_r0_body.fnode22
kernel_rfl PRE_first_tail_x6_r0_body.fcxn22 : (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn22 : (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle022 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_22.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_22.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk22 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd22.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A22 : PRE_first_tail_x6_r0_body.cx1_22.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS22.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_22.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O22 : PRE_first_tail_x6_r0_body.cx1_22.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS22.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_22.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N22 : PRE_first_tail_x6_r0_body.cx1_22.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS22.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_22.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I22 : PRE_first_tail_x6_r0_body.cx1_22.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS22.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_22.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd22 : (PRE_first_tail_x6_r0_body.clo22 ++ PRE_first_tail_x6_r0_body.cln22 ++ PRE_first_tail_x6_r0_body.cli22 ++ PRE_first_tail_x6_r0_body.cwS22 ++ PRE_first_tail_x6_r0_body.cnS22 ++ PRE_first_tail_x6_r0_body.ciS22).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW22 : PRE_first_tail_x6_r0_body.cwS22.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo22.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI22 : PRE_first_tail_x6_r0_body.ciS22.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli22.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN22 : PRE_first_tail_x6_r0_body.cnS22.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF22 : PRE_first_tail_x6_r0_body.cln22.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh22 : PRE_first_tail_x6_r0_body.clo22.all (handleOK PRE_first_tail_x6_r0_body.kappa22 PRE_first_tail_x6_r0_body.P22.lo PRE_first_tail_x6_r0_body.cx0_22.mlx PRE_first_tail_x6_r0_body.cx1_22.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo22 : PRE_first_tail_x6_r0_body.clo22.map (fun h => PRE_first_tail_x6_r0_body.cx1_22.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa22.handle h)) = PRE_first_tail_x6_r0_body.clo22.map (fun h => (PRE_first_tail_x6_r0_body.cx0_22.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa22.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok22 : PRE_first_tail_x6_r0_body.clo22.all (objOK PRE_first_tail_x6_r0_body.kappa22 PRE_first_tail_x6_r0_body.P22.NL PRE_first_tail_x6_r0_body.cx0_22.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd22 : PRE_first_tail_x6_r0_body.cln22.all (nodeOKF PRE_first_tail_x6_r0_body.kappa22 PRE_first_tail_x6_r0_body.P22 PRE_first_tail_x6_r0_body.cx0_22.mlx PRE_first_tail_x6_r0_body.cx1_22.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp22 : ((PRE_first_tail_x6_r0_body.cln22.filter (fullB PRE_first_tail_x6_r0_body.P22))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_22.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa22.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln22.filter (fullB PRE_first_tail_x6_r0_body.P22))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_22.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa22.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI22 : incrB PRE_first_tail_x6_r0_body.kd22.nodeF (List.range' 15729 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK22 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd22.node).all (fun k => Nat.ble 15729 k && Nat.blt k 15729) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL22 : (PRE_first_tail_x6_r0_body.cln22.filter (Nat.ble PRE_first_tail_x6_r0_body.P22.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd22.nodeF i) && (Nat.blt i 15729 || Nat.ble PRE_first_tail_x6_r0_body.kd22.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord22 : (PRE_first_tail_x6_r0_body.cln22.filter (Nat.ble PRE_first_tail_x6_r0_body.P22.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd22.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd22.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd22.nodeF j) (PRE_first_tail_x6_r0_body.kd22.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow22 PRE_first_tail_x6_r0_body.cnn122 PRE_first_tail_x6_r0_body.fnordI22 PRE_first_tail_x6_r0_body.fnordK22 PRE_first_tail_x6_r0_body.fnordL22
kernel_rfl PRE_first_tail_x6_r0_body.fi22 : PRE_first_tail_x6_r0_body.cli22.all (pnB PRE_first_tail_x6_r0_body.cx0_22.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii22 : PRE_first_tail_x6_r0_body.cli22.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_22.mlx.items.get (PRE_first_tail_x6_r0_body.kappa22.node k) = (PRE_first_tail_x6_r0_body.cx0_22.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa22.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot22 (clean : Conv.NClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P22.NL) (cl : SSt (· < 1019) PRE_first_tail_x6_r0_body.cx0_22.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P22 1019 PRE_first_tail_x6_r0_body.kappa22 PRE_first_tail_x6_r0_body.kd22 PRE_first_tail_x6_r0_body.khinv22 PRE_first_tail_x6_r0_body.kninv22 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx PRE_first_tail_x6_r0_body.cx0_22.mlx PRE_first_tail_x6_r0_body.cx1_22.mlx (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo22 PRE_first_tail_x6_r0_body.cln22 PRE_first_tail_x6_r0_body.cli22 PRE_first_tail_x6_r0_body.cwS22 PRE_first_tail_x6_r0_body.cnS22 PRE_first_tail_x6_r0_body.ciS22 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh022, PRE_first_tail_x6_r0_body.cnh122, PRE_first_tail_x6_r0_body.cnn022, PRE_first_tail_x6_r0_body.cnn122, PRE_first_tail_x6_r0_body.cplo22, PRE_first_tail_x6_r0_body.ccnt22, PRE_first_tail_x6_r0_body.cnband22, PRE_first_tail_x6_r0_body.chbelow22, PRE_first_tail_x6_r0_body.chren22, PRE_first_tail_x6_r0_body.cband22, PRE_first_tail_x6_r0_body.cnh1pos22, PRE_first_tail_x6_r0_body.cnren22, PRE_first_tail_x6_r0_body.cnlow22, PRE_first_tail_x6_r0_body.cabs0a22, PRE_first_tail_x6_r0_body.cabs0b22, PRE_first_tail_x6_r0_body.ctok122, PRE_first_tail_x6_r0_body.cpend22, PRE_first_tail_x6_r0_body.cerrh22, PRE_first_tail_x6_r0_body.cfiles22, PRE_first_tail_x6_r0_body.carch22, PRE_first_tail_x6_r0_body.csizes22, PRE_first_tail_x6_r0_body.cwired22, PRE_first_tail_x6_r0_body.cfix22, clean, PRE_first_tail_x6_r0_body.fcxn22, PRE_first_tail_x6_r0_body.fcnn22, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle022, PRE_first_tail_x6_r0_body.fnk22, PRE_first_tail_x6_r0_body.ckA22, PRE_first_tail_x6_r0_body.cobjsK22, PRE_first_tail_x6_r0_body.cnodesK22, PRE_first_tail_x6_r0_body.citemsK22, PRE_first_tail_x6_r0_body.f1A22, PRE_first_tail_x6_r0_body.f1O22, PRE_first_tail_x6_r0_body.f1N22, PRE_first_tail_x6_r0_body.f1I22, PRE_first_tail_x6_r0_body.fbd22, PRE_first_tail_x6_r0_body.fincW22, PRE_first_tail_x6_r0_body.fincI22, PRE_first_tail_x6_r0_body.fincN22, PRE_first_tail_x6_r0_body.flnF22, PRE_first_tail_x6_r0_body.fh22, PRE_first_tail_x6_r0_body.fo22, PRE_first_tail_x6_r0_body.fok22, PRE_first_tail_x6_r0_body.fnd22, PRE_first_tail_x6_r0_body.fp22, PRE_first_tail_x6_r0_body.fnord22, PRE_first_tail_x6_r0_body.fi22, PRE_first_tail_x6_r0_body.fii22⟩
theorem PRE_first_tail_x6_r0_body.cnshift22 (clean : Conv.NClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P22.NL) (cl : SSt (· < 1019) PRE_first_tail_x6_r0_body.cx0_22.mlx) : NShift PRE_first_tail_x6_r0_body.P22 1019 PRE_first_tail_x6_r0_body.kappa22 PRE_first_tail_x6_r0_body.cx0_22 PRE_first_tail_x6_r0_body.cx1_22 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot22 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost22 (compact_a_eq PRE_first_tail_x6_r0_body.ckn022 PRE_first_tail_x6_r0_body.ckn122 PRE_first_tail_x6_r0_body.ckheap22 PRE_first_tail_x6_r0_body.ckpl22)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_22 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s225.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_22 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s225.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_22 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s225.ffi) = some PRE_first_tail_x6_r0_body.fxC_22
kernel_rfl PRE_first_tail_x6_r0_body.okrC_22 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s225.ffi) = some PRE_first_tail_x6_r0_body.krC_22
noncomputable def PRE_first_tail_x6_r0_body.fx0_22 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s227.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_22 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s227.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_22 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s227.ffi) = some PRE_first_tail_x6_r0_body.fx0_22
kernel_rfl PRE_first_tail_x6_r0_body.okr0_22 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s227.ffi) = some PRE_first_tail_x6_r0_body.kr0_22
noncomputable def PRE_first_tail_x6_r0_body.fx1_22 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s226.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_22 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s226.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_22 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s226.ffi) = some PRE_first_tail_x6_r0_body.fx1_22
kernel_rfl PRE_first_tail_x6_r0_body.okr1_22 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s226.ffi) = some PRE_first_tail_x6_r0_body.kr1_22
kernel_rfl PRE_first_tail_x6_r0_body.ff022 : PRE_first_tail_x6_r0_body.fx0_22 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_22 (PRE_first_tail_x6_r0_body.clo22.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_22.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff122 : PRE_first_tail_x6_r0_body.fx1_22 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_22 (PRE_first_tail_x6_r0_body.cwS22.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_22.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck22 : freedLB PRE_first_tail_x6_r0_body.kappa22 PRE_first_tail_x6_r0_body.cx0_22.mlx PRE_first_tail_x6_r0_body.fx0_22 PRE_first_tail_x6_r0_body.fx1_22 PRE_first_tail_x6_r0_body.clo22 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf022 : PRE_first_tail_x6_r0_body.kr0_22.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_22.flags (PRE_first_tail_x6_r0_body.clo22.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_22.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt022 : PRE_first_tail_x6_r0_body.kr0_22.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_22.targs (PRE_first_tail_x6_r0_body.clo22.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_22.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf122 : PRE_first_tail_x6_r0_body.kr1_22.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_22.flags (PRE_first_tail_x6_r0_body.cwS22.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_22.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt122 : PRE_first_tail_x6_r0_body.kr1_22.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_22.targs (PRE_first_tail_x6_r0_body.cwS22.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_22.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck22 : krecLB PRE_first_tail_x6_r0_body.kappa22 1019 PRE_first_tail_x6_r0_body.cx0_22.mlx PRE_first_tail_x6_r0_body.kr0_22 PRE_first_tail_x6_r0_body.kr1_22 PRE_first_tail_x6_r0_body.clo22 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn22 : Nat.ble 1019 1019 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge22 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s226.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s227.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR22 : pendRegB PRE_first_tail_x6_r0_body.kappa22 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe22 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s227.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s226.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift22 (clean : Conv.NClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P22.NL) (cl : SSt (· < 1019) PRE_first_tail_x6_r0_body.cx0_22.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_22.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_22.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_22.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s225.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_22.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P22 1019 PRE_first_tail_x6_r0_body.kappa22 PRE_first_tail_x6_r0_body.s227.ffi PRE_first_tail_x6_r0_body.s226.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift22 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue22, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp22 t ht),
    PRE_first_tail_x6_r0_body.cbridge22,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s227.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s226.ffi) (PRE_first_tail_x6_r0_body.cfoot22 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_22 PRE_first_tail_x6_r0_body.ofx1_22 hobjC PRE_first_tail_x6_r0_body.ff022 PRE_first_tail_x6_r0_body.ff122 PRE_first_tail_x6_r0_body.ffck22,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s227.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s226.ffi) (PRE_first_tail_x6_r0_body.cfoot22 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_22 PRE_first_tail_x6_r0_body.okr1_22 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn22) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf022 PRE_first_tail_x6_r0_body.fkt022 PRE_first_tail_x6_r0_body.fkf122 PRE_first_tail_x6_r0_body.fkt122 PRE_first_tail_x6_r0_body.fkck22,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh022 PRE_first_tail_x6_r0_body.cnh122 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe22) PRE_first_tail_x6_r0_body.cpendR22⟩

end Host.Load.Run.Tpl
end

section -- st22/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st22 0
host_stream_state PRE_first_tail_x6_r0_body.st22 1
host_stream_state PRE_first_tail_x6_r0_body.st22 2
end Host.Load.Run.Tpl
end

section -- Site22
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 22 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g22__g23` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s225`, the merged state `PRE_first_tail_x6_r0_body.s226`,
the site template `PRE_first_tail_x6_r0_body.st22` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s227`: the merge.
The footprint's facts are in `SiteF22`, the compaction's in `SiteC22`, `SiteK22`, `SiteNa22`, `SiteNb22`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso22 : PRE_first_tail_x6_r0_body.st22.s0 = { PRE_first_tail_x6_r0_body.s225 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs22 : List Frame := PRE_first_tail_x6_r0_body.s225.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_22 : PRE_first_tail_x6_r0_body.S225.tab.length = 1019
kernel_rfl PRE_first_tail_x6_r0_body.tab0_22 : PRE_first_tail_x6_r0_body.st22.S0.tab = PRE_first_tail_x6_r0_body.S225.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws22 : List Nat := [1387, 1388]
kernel_rfl PRE_first_tail_x6_r0_body.fresh22 : (PRE_first_tail_x6_r0_body.S225.tab.all fun e => PRE_first_tail_x6_r0_body.ws22.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S225.oracle.all fun q => PRE_first_tail_x6_r0_body.ws22.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab22 : PRE_first_tail_x6_r0_body.S226.tab = PRE_first_tail_x6_r0_body.S225.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws22
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen22 : PRE_first_tail_x6_r0_body.st22.S2.tab.length - PRE_first_tail_x6_r0_body.st22.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged22`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap22 : PRE_first_tail_x6_r0_body.s226.heap = PRE_first_tail_x6_r0_body.st22.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext22 : PRE_first_tail_x6_r0_body.s226.next = PRE_first_tail_x6_r0_body.st22.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl22 : PRE_first_tail_x6_r0_body.s226.ctl = PRE_first_tail_x6_r0_body.st22.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack22 : PRE_first_tail_x6_r0_body.s226.stack = PRE_first_tail_x6_r0_body.st22.s2.stack ++ PRE_first_tail_x6_r0_body.s225.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs22 : PRE_first_tail_x6_r0_body.s226.jobs = PRE_first_tail_x6_r0_body.st22.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi22 : PRE_first_tail_x6_r0_body.s226.ffi = PRE_first_tail_x6_r0_body.st22.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace22 : PRE_first_tail_x6_r0_body.s226.trace = PRE_first_tail_x6_r0_body.st22.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores22 : PRE_first_tail_x6_r0_body.s226.stores = PRE_first_tail_x6_r0_body.st22.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD22
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 22 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived22 : PRE_first_tail_x6_r0_body.nr22.map (fun r => nth? PRE_first_tail_x6_r0_body.st22.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo22 : PRE_first_tail_x6_r0_body.nr22.all (Nat.ble 1019) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj22 : PRE_first_tail_x6_r0_body.cws22.all (fun c => !PRE_first_tail_x6_r0_body.ws22.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ22 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws22 PRE_first_tail_x6_r0_body.crs22 PRE_first_tail_x6_r0_body.ws22

end Host.Load.Run.Tpl
end

section -- st22/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st22`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st22.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st22.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st22.s2.heap PRE_first_tail_x6_r0_body.st22.wrR ++ freshOf PRE_first_tail_x6_r0_body.st22.s2.heap PRE_first_tail_x6_r0_body.st22.s0.next PRE_first_tail_x6_r0_body.st22.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st22.wr : List Nat := PRE_first_tail_x6_r0_body.st22.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st22.heapFoot : PRE_first_tail_x6_r0_body.st22.s2.heap = setAll PRE_first_tail_x6_r0_body.st22.s0.heap PRE_first_tail_x6_r0_body.st22.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st22.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st22.s0.next PRE_first_tail_x6_r0_body.st22.s2.next = true
theorem PRE_first_tail_x6_r0_body.st22.grows : PRE_first_tail_x6_r0_body.st22.s0.next ≤ PRE_first_tail_x6_r0_body.st22.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st22.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st22.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st22.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st22.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st22.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st22.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st22.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st22.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st22.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st22.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st22.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st22.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF22
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 22 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB22 : nodupT PRE_first_tail_x6_r0_body.st22.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup22 : PRE_first_tail_x6_r0_body.st22.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB22).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB22 : PRE_first_tail_x6_r0_body.st22.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound22 : ∀ b ∈ PRE_first_tail_x6_r0_body.st22.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB22 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr22 := PRE_first_tail_x6_r0_body.st22.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq22 : PRE_first_tail_x6_r0_body.st22.s2.trace = PRE_first_tail_x6_r0_body.trFr22 ++ PRE_first_tail_x6_r0_body.st22.s0.trace
theorem PRE_first_tail_x6_r0_body.trace22 : ∃ fr, PRE_first_tail_x6_r0_body.st22.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st22.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq22⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide22 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB22 : (PRE_first_tail_x6_r0_body.wide22.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st22.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix22 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide22, WFix Map.id (Present PRE_first_tail_x6_r0_body.st22.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB22 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL22
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 22 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s226`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO22 : PRE_first_tail_x6_r0_body.st22.S0.oracle = PRE_first_tail_x6_r0_body.st22.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B22 : PRE_first_tail_x6_r0_body.st22.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st22.s0.next || (PRE_first_tail_x6_r0_body.st22.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot22 : Conv.StageFoot PRE_first_tail_x6_r0_body.st22.wr PRE_first_tail_x6_r0_body.st22.s0 PRE_first_tail_x6_r0_body.st22.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st22.heapFoot PRE_first_tail_x6_r0_body.wrNodup22 PRE_first_tail_x6_r0_body.wrBound22 PRE_first_tail_x6_r0_body.wr0B22 PRE_first_tail_x6_r0_body.st22.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged22 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st22.F.S → PRE_first_tail_x6_r0_body.st22.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st22.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st22.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs22 PRE_first_tail_x6_r0_body.st22.wr PRE_first_tail_x6_r0_body.s225 PRE_first_tail_x6_r0_body.st22.s2 PRE_first_tail_x6_r0_body.st22.s0
      PRE_first_tail_x6_r0_body.st22.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st22.F FR W stk M ν K PRE_first_tail_x6_r0_body.s226 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso22 PRE_first_tail_x6_r0_body.stFoot22 PRE_first_tail_x6_r0_body.wrNodup22 PRE_first_tail_x6_r0_body.wrBound22 PRE_first_tail_x6_r0_body.trace22 PRE_first_tail_x6_r0_body.mheap22
    PRE_first_tail_x6_r0_body.mnext22 PRE_first_tail_x6_r0_body.mctl22 PRE_first_tail_x6_r0_body.mstack22 PRE_first_tail_x6_r0_body.mjobs22 PRE_first_tail_x6_r0_body.mffi22 PRE_first_tail_x6_r0_body.mtrace22 PRE_first_tail_x6_r0_body.mstores22 h

def PRE_first_tail_x6_r0_body.arrEl22_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE22_2665 : arrOf PRE_first_tail_x6_r0_body.s226 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl22_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA22_2665 : isArrB PRE_first_tail_x6_r0_body.s226 2665 = true
theorem PRE_first_tail_x6_r0_body.arr22_2665 : ∃ o, PRE_first_tail_x6_r0_body.s226.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl22_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE22_2665 PRE_first_tail_x6_r0_body.arrA22_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN22_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl22_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR22_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl22_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN22_2665

def PRE_first_tail_x6_r0_body.arrEl22_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE22_2673467 : arrOf PRE_first_tail_x6_r0_body.s226 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl22_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA22_2673467 : isArrB PRE_first_tail_x6_r0_body.s226 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr22_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s226.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl22_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE22_2673467 PRE_first_tail_x6_r0_body.arrA22_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN22_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl22_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR22_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl22_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN22_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k22 : isArrB PRE_first_tail_x6_r0_body.s226 4910 = false
theorem PRE_first_tail_x6_r0_body.keep22 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s226 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k22 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr22_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl22_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ22
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 22 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s225`, the merged
state `PRE_first_tail_x6_r0_body.s226`, the canonical state `PRE_first_tail_x6_r0_body.s227`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl22 : PRE_first_tail_x6_r0_body.pl22.all (Nat.ble PRE_first_tail_x6_r0_body.s225.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd22 : nodupT PRE_first_tail_x6_r0_body.pl22 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn122 : Nat.ble PRE_first_tail_x6_r0_body.s225.next 2692507 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst22 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s225.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn22 : PRE_first_tail_x6_r0_body.s227.next = PRE_first_tail_x6_r0_body.s225.next + PRE_first_tail_x6_r0_body.pl22.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn22 : PRE_first_tail_x6_r0_body.s226.next = 2692507
kernel_rfl PRE_first_tail_x6_r0_body.zgrow22 : Nat.ble PRE_first_tail_x6_r0_body.s227.next PRE_first_tail_x6_r0_body.s226.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh22 : PRE_first_tail_x6_r0_body.S225.tab.all (fun e => PRE_first_tail_x6_r0_body.cws22.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd22 : nodupT PRE_first_tail_x6_r0_body.cws22 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi22 : PRE_first_tail_x6_r0_body.nr22.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S226.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt22 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s225.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg22_2665 : PRE_first_tail_x6_r0_body.s227.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s227 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk22_2665 : (objOf PRE_first_tail_x6_r0_body.s227 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm22_2665 : PRE_first_tail_x6_r0_body.s226.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa22.obj (objOf PRE_first_tail_x6_r0_body.s227 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s226 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg22_2673467 : PRE_first_tail_x6_r0_body.s227.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s227 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk22_2673467 : (objOf PRE_first_tail_x6_r0_body.s227 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm22_2673467 : PRE_first_tail_x6_r0_body.s226.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa22.obj (objOf PRE_first_tail_x6_r0_body.s227 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s226 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw22_4910 : (PRE_first_tail_x6_r0_body.s227.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw22_2673472 : (PRE_first_tail_x6_r0_body.s227.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw22_2673473 : (PRE_first_tail_x6_r0_body.s227.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd22 : PRE_first_tail_x6_r0_body.cl22.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr22 : PRE_first_tail_x6_r0_body.st22.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s225.next || PRE_first_tail_x6_r0_body.cl22.contains b) = true
def PRE_first_tail_x6_r0_body.zl22 : List Nat := PRE_first_tail_x6_r0_body.cl22.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE22 : PRE_first_tail_x6_r0_body.zl22.map (fun a => PRE_first_tail_x6_r0_body.s226.heap.get (PRE_first_tail_x6_r0_body.kappa22.a a)) = PRE_first_tail_x6_r0_body.zl22.map (fun a => (PRE_first_tail_x6_r0_body.s227.heap.get a).map PRE_first_tail_x6_r0_body.kappa22.hobj)
theorem PRE_first_tail_x6_r0_body.zimg22 : HeapImg PRE_first_tail_x6_r0_body.kappa22 PRE_first_tail_x6_r0_body.s227 PRE_first_tail_x6_r0_body.s226 PRE_first_tail_x6_r0_body.zl22 := PRE_first_tail_x6_r0_body.zimgE22
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl22 : PRE_first_tail_x6_r0_body.s226.ctl = PRE_first_tail_x6_r0_body.kappa22.ctl PRE_first_tail_x6_r0_body.s227.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack22 : PRE_first_tail_x6_r0_body.s226.stack = PRE_first_tail_x6_r0_body.s227.stack.map PRE_first_tail_x6_r0_body.kappa22.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs22 : PRE_first_tail_x6_r0_body.s226.jobs = PRE_first_tail_x6_r0_body.s227.jobs.map PRE_first_tail_x6_r0_body.kappa22.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores22 : PRE_first_tail_x6_r0_body.s226.stores = PRE_first_tail_x6_r0_body.kappa22.stores PRE_first_tail_x6_r0_body.s227.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots22 : checkRootsSupp PRE_first_tail_x6_r0_body.s227 1019 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC22 : PRE_first_tail_x6_r0_body.S225.tab.length + PRE_first_tail_x6_r0_body.cws22.length = 1019
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap22 : PRE_first_tail_x6_r0_body.kappa22 = Conv.Map.compact PRE_first_tail_x6_r0_body.s225.next 2692507 PRE_first_tail_x6_r0_body.S225.tab.length PRE_first_tail_x6_r0_body.pl22 (PRE_first_tail_x6_r0_body.nr22.map NumV.ref) PRE_first_tail_x6_r0_body.kd22.big
  PRE_first_tail_x6_r0_body.kd22.region PRE_first_tail_x6_r0_body.kd22.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin22 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s227.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc22 : Conv.jcleanListB (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s227 PRE_first_tail_x6_r0_body.cl22 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB22 : noBigRootsP (fun i => !Conv.oldBigB (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s227.trace PRE_first_tail_x6_r0_body.s227 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm22 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15729 = true
theorem PRE_first_tail_x6_r0_body.cjcl22 (h : Conv.JClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s225) : Conv.JClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s227 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle22)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap22 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd22 a ha)) PRE_first_tail_x6_r0_body.zjc22

end Host.Load.Run.Tpl
end

section -- st22/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st22.bodyLast from PRE_first_tail_x6_r0_body.st22.s1 to PRE_first_tail_x6_r0_body.st22.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st22.F PRE_first_tail_x6_r0_body.st22.s1).run PRE_first_tail_x6_r0_body.st22.S1 = some (PRE_first_tail_x6_r0_body.st22.s2, PRE_first_tail_x6_r0_body.st22.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st22.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st22.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st22.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st22.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st22/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st22.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st22.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st22.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st22.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st22.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st22.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st22.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st22.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st22.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st22.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st22.s0 PRE_first_tail_x6_r0_body.st22.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st22.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st22.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st22.s1 PRE_first_tail_x6_r0_body.st22.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st22/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st22.bodyK0F from PRE_first_tail_x6_r0_body.st22.s0 to PRE_first_tail_x6_r0_body.st22.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st22.F (PRE_first_tail_x6_r0_body.st22.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st22.ks 0).getD 0) PRE_first_tail_x6_r0_body.st22.s0 PRE_first_tail_x6_r0_body.st22.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st22.s1, PRE_first_tail_x6_r0_body.st22.S1)
theorem PRE_first_tail_x6_r0_body.st22.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st22.F (PRE_first_tail_x6_r0_body.st22.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st22.ks 0).getD 0) PRE_first_tail_x6_r0_body.st22.s0 PRE_first_tail_x6_r0_body.st22.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st22.s1, PRE_first_tail_x6_r0_body.st22.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st22.bodyOkLN_ok PRE_first_tail_x6_r0_body.st22.bodyK0F
end Host.Load.Run.Tpl
end

section -- st22/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st22.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st22.F (PRE_first_tail_x6_r0_body.st22.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st22.s0 PRE_first_tail_x6_r0_body.st22.S0 = some (PRE_first_tail_x6_r0_body.st22.s1, PRE_first_tail_x6_r0_body.st22.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st22.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st22.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st22.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st22.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st22.F (PRE_first_tail_x6_r0_body.st22.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st22.s0
  S0 := PRE_first_tail_x6_r0_body.st22.S0
  s1 := PRE_first_tail_x6_r0_body.st22.s1
  S1 := PRE_first_tail_x6_r0_body.st22.S1
  s2 := PRE_first_tail_x6_r0_body.st22.s2
  S2 := PRE_first_tail_x6_r0_body.st22.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st22.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st22.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st22.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st22.bodyHalt
  last := PRE_first_tail_x6_r0_body.st22.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st22.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC23
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 23 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s231` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa23` into the merged state
`PRE_first_tail_x6_r0_body.s230`. -/

def PRE_first_tail_x6_r0_body.pl23 : List Nat := [2692803]
def PRE_first_tail_x6_r0_body.nr23 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd23 : RData :=
  ⟨2692794, 2692804, Stage.setAll PTrie.nil [(2692793, 2692803)], Stage.setAll PTrie.nil [],
   18653, 18653, 15733, 15733, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa23 : Map :=
  Conv.Map.compact 2692793 2692804 1036 PRE_first_tail_x6_r0_body.pl23 (PRE_first_tail_x6_r0_body.nr23.map NumV.ref) PRE_first_tail_x6_r0_body.kd23.big
    PRE_first_tail_x6_r0_body.kd23.region PRE_first_tail_x6_r0_body.kd23.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws23 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs23 : List SymE := PRE_first_tail_x6_r0_body.nr23.map fun r => (nth? PRE_first_tail_x6_r0_body.S230.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta23 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws23 PRE_first_tail_x6_r0_body.crs23
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB23 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab23 : PRE_first_tail_x6_r0_body.S231.tab = PRE_first_tail_x6_r0_body.S229.tab ++ PRE_first_tail_x6_r0_body.cws23.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace23 : PRE_first_tail_x6_r0_body.s231.trace = PRE_first_tail_x6_r0_body.s229.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext23 : PRE_first_tail_x6_r0_body.s231.next = 2692794
kernel_rfl PRE_first_tail_x6_r0_body.ccounters23 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx.nnext) = (18653, 15733)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue23 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s230.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa23.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp23 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx.tokens.all (bSN 1036) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean23 : Conv.cleanListB 18653 131072 (fun r => Nat.ble 74612 r) PRE_first_tail_x6_r0_body.s231
    (PRE_first_tail_x6_r0_body.wrB23 ++ (List.range 1).map (2692793 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs23 : bigsOutB 18653 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK23
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl23`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl23 : List Nat := [2665, 2673467, 2692793]
def PRE_first_tail_x6_r0_body.clo23 : List Nat := []
def PRE_first_tail_x6_r0_body.cln23 : List Nat := []
def PRE_first_tail_x6_r0_body.cli23 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap23 : PRE_first_tail_x6_r0_body.s231.heap = Stage.setAll PRE_first_tail_x6_r0_body.s229.heap (PRE_first_tail_x6_r0_body.cl23.filterMap fun a => (PRE_first_tail_x6_r0_body.s231.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe23 : Nat.ble PRE_first_tail_x6_r0_body.s229.next PRE_first_tail_x6_r0_body.s231.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP23 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s229 PRE_first_tail_x6_r0_body.s231 PRE_first_tail_x6_r0_body.cl23 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp23 : Conv.suppListB PRE_first_tail_x6_r0_body.s231 1036 PRE_first_tail_x6_r0_body.cl23 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound23 : Conv.boundListB PRE_first_tail_x6_r0_body.s231 PRE_first_tail_x6_r0_body.cl23 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK23 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln23.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK23 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo23.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK23 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli23.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst23 : Conv.sstListB 1036 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx PRE_first_tail_x6_r0_body.cln23 PRE_first_tail_x6_r0_body.clo23 PRE_first_tail_x6_r0_body.cli23 = true

end Host.Load.Run.Tpl
end

section -- SiteCl23
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA23 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo23.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd23 : (PRE_first_tail_x6_r0_body.clo23 ++ PRE_first_tail_x6_r0_body.cln23 ++ PRE_first_tail_x6_r0_body.cli23).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle23 : Conv.Cnt.leB (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) (⟨18653, 15733, 2692794, 1036⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck23 : Conv.ncleanListB (⟨18653, 15733, 2692794, 1036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx PRE_first_tail_x6_r0_body.clo23 PRE_first_tail_x6_r0_body.cln23 PRE_first_tail_x6_r0_body.cli23 = true
theorem PRE_first_tail_x6_r0_body.cncl23 (h : Conv.NClean (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx) : Conv.NClean (⟨18653, 15733, 2692794, 1036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle23 PRE_first_tail_x6_r0_body.ckA23 PRE_first_tail_x6_r0_body.cobjsK23 PRE_first_tail_x6_r0_body.cnodesK23 PRE_first_tail_x6_r0_body.citemsK23 PRE_first_tail_x6_r0_body.cbd23 PRE_first_tail_x6_r0_body.cck23

end Host.Load.Run.Tpl
end

section -- SiteS23
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 23 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc23 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P23 : LoadP := PRE_first_tail_x6_r0_body.Pc23.raise 15733
kernel_rfl PRE_first_tail_x6_r0_body.craise23 : Nat.ble PRE_first_tail_x6_r0_body.Pc23.N0 15733 = true
theorem PRE_first_tail_x6_r0_body.raised23 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc23 PRE_first_tail_x6_r0_body.P23 :=
  .inr ⟨15733, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise23, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_23 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_23 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s230.ffi)
def PRE_first_tail_x6_r0_body.khinv23 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv23 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS23 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS23 : List Nat := List.range' 15733 0
def PRE_first_tail_x6_r0_body.ciS23 : List Nat := [] ++ List.range' 15733 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh023 : PRE_first_tail_x6_r0_body.kd23.nh0 = PRE_first_tail_x6_r0_body.cx0_23.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh123 : PRE_first_tail_x6_r0_body.kd23.nh1 = PRE_first_tail_x6_r0_body.cx1_23.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn023 : PRE_first_tail_x6_r0_body.kd23.nn0 = PRE_first_tail_x6_r0_body.cx0_23.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn123 : PRE_first_tail_x6_r0_body.kd23.nn1 = PRE_first_tail_x6_r0_body.cx1_23.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo23 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P23.lo && Nat.ble PRE_first_tail_x6_r0_body.P23.lo PRE_first_tail_x6_r0_body.cx0_23.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P23.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P23.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt23 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_23.mlx.next PRE_first_tail_x6_r0_body.cx1_23.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_23.mlx.nnext PRE_first_tail_x6_r0_body.cx1_23.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband23 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P23.NL && Nat.ble PRE_first_tail_x6_r0_body.P23.NL PRE_first_tail_x6_r0_body.P23.N0 && Nat.ble PRE_first_tail_x6_r0_body.P23.N0 PRE_first_tail_x6_r0_body.cx0_23.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow23 : PRE_first_tail_x6_r0_body.kd23.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren23 : checkRenG PRE_first_tail_x6_r0_body.kd23.hnd PRE_first_tail_x6_r0_body.khinv23 (phB PRE_first_tail_x6_r0_body.cx0_23.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband23 : PRE_first_tail_x6_r0_body.kd23.checkBand PRE_first_tail_x6_r0_body.P23.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos23 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd23.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren23 : checkRenG PRE_first_tail_x6_r0_body.kd23.node PRE_first_tail_x6_r0_body.kninv23 (pnB PRE_first_tail_x6_r0_body.cx0_23.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow23 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd23.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P23.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd23.nodeF j) PRE_first_tail_x6_r0_body.cx1_23.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a23 : PRE_first_tail_x6_r0_body.cx0_23.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b23 : PRE_first_tail_x6_r0_body.cx0_23.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok123 : PRE_first_tail_x6_r0_body.cx1_23.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend23 : PRE_first_tail_x6_r0_body.cx1_23.mlx.pending = PRE_first_tail_x6_r0_body.cx0_23.mlx.pending.map PRE_first_tail_x6_r0_body.kappa23.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh23 : PRE_first_tail_x6_r0_body.cx1_23.mlx.errh = PRE_first_tail_x6_r0_body.cx0_23.mlx.errh.map PRE_first_tail_x6_r0_body.kappa23.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles23 : PRE_first_tail_x6_r0_body.cx1_23.mlx.files = PRE_first_tail_x6_r0_body.cx0_23.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch23 : PRE_first_tail_x6_r0_body.cx1_23.mlx.arch = PRE_first_tail_x6_r0_body.cx0_23.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes23 : PRE_first_tail_x6_r0_body.cx1_23.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_23.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired23 : PRE_first_tail_x6_r0_body.cx1_23.mlx.wired = PRE_first_tail_x6_r0_body.cx0_23.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost23 : PRE_first_tail_x6_r0_body.cx1_23.host = PRE_first_tail_x6_r0_body.cx0_23.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd23`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn023 : PRE_first_tail_x6_r0_body.kd23.n0 = 2692794
kernel_rfl PRE_first_tail_x6_r0_body.ckn123 : PRE_first_tail_x6_r0_body.kd23.n1 = 2692804
kernel_rfl PRE_first_tail_x6_r0_body.ckheap23 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd23.heap).all (fun x => Nat.ble 2692793 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl23 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd23.heap.get (2692793 + j) = nth? PRE_first_tail_x6_r0_body.pl23 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja23 : Nat.ble 2692793 2692793 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn23 : Nat.ble 1036 1036 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD23 : Nat.ble 2692793 PRE_first_tail_x6_r0_body.kd23.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn23 : Nat.ble 18653 PRE_first_tail_x6_r0_body.kd23.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn23 : Nat.ble 15733 PRE_first_tail_x6_r0_body.kd23.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb23 : Nat.ble 18653 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap23 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd23.heap).all (Nat.ble (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd23 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd23.hnd).all (Nat.ble (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode23 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd23.node).all (Nat.ble (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix23 : Conv.FixOld (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa23 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja23) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn23) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD23) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn23) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn23) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb23) PRE_first_tail_x6_r0_body.fheap23 PRE_first_tail_x6_r0_body.fhnd23 PRE_first_tail_x6_r0_body.fnode23
kernel_rfl PRE_first_tail_x6_r0_body.fcxn23 : (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn23 : (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle023 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_23.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_23.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk23 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd23.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A23 : PRE_first_tail_x6_r0_body.cx1_23.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS23.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_23.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O23 : PRE_first_tail_x6_r0_body.cx1_23.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS23.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_23.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N23 : PRE_first_tail_x6_r0_body.cx1_23.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS23.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_23.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I23 : PRE_first_tail_x6_r0_body.cx1_23.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS23.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_23.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd23 : (PRE_first_tail_x6_r0_body.clo23 ++ PRE_first_tail_x6_r0_body.cln23 ++ PRE_first_tail_x6_r0_body.cli23 ++ PRE_first_tail_x6_r0_body.cwS23 ++ PRE_first_tail_x6_r0_body.cnS23 ++ PRE_first_tail_x6_r0_body.ciS23).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW23 : PRE_first_tail_x6_r0_body.cwS23.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo23.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI23 : PRE_first_tail_x6_r0_body.ciS23.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli23.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN23 : PRE_first_tail_x6_r0_body.cnS23.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF23 : PRE_first_tail_x6_r0_body.cln23.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh23 : PRE_first_tail_x6_r0_body.clo23.all (handleOK PRE_first_tail_x6_r0_body.kappa23 PRE_first_tail_x6_r0_body.P23.lo PRE_first_tail_x6_r0_body.cx0_23.mlx PRE_first_tail_x6_r0_body.cx1_23.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo23 : PRE_first_tail_x6_r0_body.clo23.map (fun h => PRE_first_tail_x6_r0_body.cx1_23.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa23.handle h)) = PRE_first_tail_x6_r0_body.clo23.map (fun h => (PRE_first_tail_x6_r0_body.cx0_23.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa23.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok23 : PRE_first_tail_x6_r0_body.clo23.all (objOK PRE_first_tail_x6_r0_body.kappa23 PRE_first_tail_x6_r0_body.P23.NL PRE_first_tail_x6_r0_body.cx0_23.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd23 : PRE_first_tail_x6_r0_body.cln23.all (nodeOKF PRE_first_tail_x6_r0_body.kappa23 PRE_first_tail_x6_r0_body.P23 PRE_first_tail_x6_r0_body.cx0_23.mlx PRE_first_tail_x6_r0_body.cx1_23.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp23 : ((PRE_first_tail_x6_r0_body.cln23.filter (fullB PRE_first_tail_x6_r0_body.P23))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_23.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa23.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln23.filter (fullB PRE_first_tail_x6_r0_body.P23))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_23.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa23.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI23 : incrB PRE_first_tail_x6_r0_body.kd23.nodeF (List.range' 15733 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK23 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd23.node).all (fun k => Nat.ble 15733 k && Nat.blt k 15733) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL23 : (PRE_first_tail_x6_r0_body.cln23.filter (Nat.ble PRE_first_tail_x6_r0_body.P23.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd23.nodeF i) && (Nat.blt i 15733 || Nat.ble PRE_first_tail_x6_r0_body.kd23.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord23 : (PRE_first_tail_x6_r0_body.cln23.filter (Nat.ble PRE_first_tail_x6_r0_body.P23.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd23.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd23.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd23.nodeF j) (PRE_first_tail_x6_r0_body.kd23.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow23 PRE_first_tail_x6_r0_body.cnn123 PRE_first_tail_x6_r0_body.fnordI23 PRE_first_tail_x6_r0_body.fnordK23 PRE_first_tail_x6_r0_body.fnordL23
kernel_rfl PRE_first_tail_x6_r0_body.fi23 : PRE_first_tail_x6_r0_body.cli23.all (pnB PRE_first_tail_x6_r0_body.cx0_23.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii23 : PRE_first_tail_x6_r0_body.cli23.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_23.mlx.items.get (PRE_first_tail_x6_r0_body.kappa23.node k) = (PRE_first_tail_x6_r0_body.cx0_23.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa23.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot23 (clean : Conv.NClean (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P23.NL) (cl : SSt (· < 1036) PRE_first_tail_x6_r0_body.cx0_23.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P23 1036 PRE_first_tail_x6_r0_body.kappa23 PRE_first_tail_x6_r0_body.kd23 PRE_first_tail_x6_r0_body.khinv23 PRE_first_tail_x6_r0_body.kninv23 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx PRE_first_tail_x6_r0_body.cx0_23.mlx PRE_first_tail_x6_r0_body.cx1_23.mlx (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo23 PRE_first_tail_x6_r0_body.cln23 PRE_first_tail_x6_r0_body.cli23 PRE_first_tail_x6_r0_body.cwS23 PRE_first_tail_x6_r0_body.cnS23 PRE_first_tail_x6_r0_body.ciS23 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh023, PRE_first_tail_x6_r0_body.cnh123, PRE_first_tail_x6_r0_body.cnn023, PRE_first_tail_x6_r0_body.cnn123, PRE_first_tail_x6_r0_body.cplo23, PRE_first_tail_x6_r0_body.ccnt23, PRE_first_tail_x6_r0_body.cnband23, PRE_first_tail_x6_r0_body.chbelow23, PRE_first_tail_x6_r0_body.chren23, PRE_first_tail_x6_r0_body.cband23, PRE_first_tail_x6_r0_body.cnh1pos23, PRE_first_tail_x6_r0_body.cnren23, PRE_first_tail_x6_r0_body.cnlow23, PRE_first_tail_x6_r0_body.cabs0a23, PRE_first_tail_x6_r0_body.cabs0b23, PRE_first_tail_x6_r0_body.ctok123, PRE_first_tail_x6_r0_body.cpend23, PRE_first_tail_x6_r0_body.cerrh23, PRE_first_tail_x6_r0_body.cfiles23, PRE_first_tail_x6_r0_body.carch23, PRE_first_tail_x6_r0_body.csizes23, PRE_first_tail_x6_r0_body.cwired23, PRE_first_tail_x6_r0_body.cfix23, clean, PRE_first_tail_x6_r0_body.fcxn23, PRE_first_tail_x6_r0_body.fcnn23, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle023, PRE_first_tail_x6_r0_body.fnk23, PRE_first_tail_x6_r0_body.ckA23, PRE_first_tail_x6_r0_body.cobjsK23, PRE_first_tail_x6_r0_body.cnodesK23, PRE_first_tail_x6_r0_body.citemsK23, PRE_first_tail_x6_r0_body.f1A23, PRE_first_tail_x6_r0_body.f1O23, PRE_first_tail_x6_r0_body.f1N23, PRE_first_tail_x6_r0_body.f1I23, PRE_first_tail_x6_r0_body.fbd23, PRE_first_tail_x6_r0_body.fincW23, PRE_first_tail_x6_r0_body.fincI23, PRE_first_tail_x6_r0_body.fincN23, PRE_first_tail_x6_r0_body.flnF23, PRE_first_tail_x6_r0_body.fh23, PRE_first_tail_x6_r0_body.fo23, PRE_first_tail_x6_r0_body.fok23, PRE_first_tail_x6_r0_body.fnd23, PRE_first_tail_x6_r0_body.fp23, PRE_first_tail_x6_r0_body.fnord23, PRE_first_tail_x6_r0_body.fi23, PRE_first_tail_x6_r0_body.fii23⟩
theorem PRE_first_tail_x6_r0_body.cnshift23 (clean : Conv.NClean (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P23.NL) (cl : SSt (· < 1036) PRE_first_tail_x6_r0_body.cx0_23.mlx) : NShift PRE_first_tail_x6_r0_body.P23 1036 PRE_first_tail_x6_r0_body.kappa23 PRE_first_tail_x6_r0_body.cx0_23 PRE_first_tail_x6_r0_body.cx1_23 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot23 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost23 (compact_a_eq PRE_first_tail_x6_r0_body.ckn023 PRE_first_tail_x6_r0_body.ckn123 PRE_first_tail_x6_r0_body.ckheap23 PRE_first_tail_x6_r0_body.ckpl23)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_23 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s229.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_23 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s229.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_23 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s229.ffi) = some PRE_first_tail_x6_r0_body.fxC_23
kernel_rfl PRE_first_tail_x6_r0_body.okrC_23 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s229.ffi) = some PRE_first_tail_x6_r0_body.krC_23
noncomputable def PRE_first_tail_x6_r0_body.fx0_23 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s231.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_23 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s231.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_23 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s231.ffi) = some PRE_first_tail_x6_r0_body.fx0_23
kernel_rfl PRE_first_tail_x6_r0_body.okr0_23 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s231.ffi) = some PRE_first_tail_x6_r0_body.kr0_23
noncomputable def PRE_first_tail_x6_r0_body.fx1_23 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s230.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_23 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s230.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_23 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s230.ffi) = some PRE_first_tail_x6_r0_body.fx1_23
kernel_rfl PRE_first_tail_x6_r0_body.okr1_23 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s230.ffi) = some PRE_first_tail_x6_r0_body.kr1_23
kernel_rfl PRE_first_tail_x6_r0_body.ff023 : PRE_first_tail_x6_r0_body.fx0_23 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_23 (PRE_first_tail_x6_r0_body.clo23.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_23.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff123 : PRE_first_tail_x6_r0_body.fx1_23 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_23 (PRE_first_tail_x6_r0_body.cwS23.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_23.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck23 : freedLB PRE_first_tail_x6_r0_body.kappa23 PRE_first_tail_x6_r0_body.cx0_23.mlx PRE_first_tail_x6_r0_body.fx0_23 PRE_first_tail_x6_r0_body.fx1_23 PRE_first_tail_x6_r0_body.clo23 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf023 : PRE_first_tail_x6_r0_body.kr0_23.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_23.flags (PRE_first_tail_x6_r0_body.clo23.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_23.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt023 : PRE_first_tail_x6_r0_body.kr0_23.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_23.targs (PRE_first_tail_x6_r0_body.clo23.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_23.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf123 : PRE_first_tail_x6_r0_body.kr1_23.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_23.flags (PRE_first_tail_x6_r0_body.cwS23.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_23.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt123 : PRE_first_tail_x6_r0_body.kr1_23.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_23.targs (PRE_first_tail_x6_r0_body.cwS23.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_23.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck23 : krecLB PRE_first_tail_x6_r0_body.kappa23 1036 PRE_first_tail_x6_r0_body.cx0_23.mlx PRE_first_tail_x6_r0_body.kr0_23 PRE_first_tail_x6_r0_body.kr1_23 PRE_first_tail_x6_r0_body.clo23 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn23 : Nat.ble 1036 1036 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge23 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s230.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s231.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR23 : pendRegB PRE_first_tail_x6_r0_body.kappa23 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe23 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s231.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s230.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift23 (clean : Conv.NClean (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P23.NL) (cl : SSt (· < 1036) PRE_first_tail_x6_r0_body.cx0_23.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_23.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_23.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_23.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s229.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_23.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P23 1036 PRE_first_tail_x6_r0_body.kappa23 PRE_first_tail_x6_r0_body.s231.ffi PRE_first_tail_x6_r0_body.s230.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift23 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue23, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp23 t ht),
    PRE_first_tail_x6_r0_body.cbridge23,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s231.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s230.ffi) (PRE_first_tail_x6_r0_body.cfoot23 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_23 PRE_first_tail_x6_r0_body.ofx1_23 hobjC PRE_first_tail_x6_r0_body.ff023 PRE_first_tail_x6_r0_body.ff123 PRE_first_tail_x6_r0_body.ffck23,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s231.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s230.ffi) (PRE_first_tail_x6_r0_body.cfoot23 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_23 PRE_first_tail_x6_r0_body.okr1_23 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn23) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf023 PRE_first_tail_x6_r0_body.fkt023 PRE_first_tail_x6_r0_body.fkf123 PRE_first_tail_x6_r0_body.fkt123 PRE_first_tail_x6_r0_body.fkck23,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh023 PRE_first_tail_x6_r0_body.cnh123 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe23) PRE_first_tail_x6_r0_body.cpendR23⟩

end Host.Load.Run.Tpl
end

section -- st23/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st23 0
host_stream_state PRE_first_tail_x6_r0_body.st23 1
host_stream_state PRE_first_tail_x6_r0_body.st23 2
end Host.Load.Run.Tpl
end

section -- Site23
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 23 of chain `PRE_first_tail_x6_r0_body`: `plan__g23__g24` (`plan`), the call state `PRE_first_tail_x6_r0_body.s229`, the merged state `PRE_first_tail_x6_r0_body.s230`,
the site template `PRE_first_tail_x6_r0_body.st23` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s231`: the merge.
The footprint's facts are in `SiteF23`, the compaction's in `SiteC23`, `SiteK23`, `SiteNa23`, `SiteNb23`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso23 : PRE_first_tail_x6_r0_body.st23.s0 = { PRE_first_tail_x6_r0_body.s229 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs23 : List Frame := PRE_first_tail_x6_r0_body.s229.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_23 : PRE_first_tail_x6_r0_body.S229.tab.length = 1036
kernel_rfl PRE_first_tail_x6_r0_body.tab0_23 : PRE_first_tail_x6_r0_body.st23.S0.tab = PRE_first_tail_x6_r0_body.S229.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws23 : List Nat := [1389, 1390, 1391]
kernel_rfl PRE_first_tail_x6_r0_body.fresh23 : (PRE_first_tail_x6_r0_body.S229.tab.all fun e => PRE_first_tail_x6_r0_body.ws23.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S229.oracle.all fun q => PRE_first_tail_x6_r0_body.ws23.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab23 : PRE_first_tail_x6_r0_body.S230.tab = PRE_first_tail_x6_r0_body.S229.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws23
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen23 : PRE_first_tail_x6_r0_body.st23.S2.tab.length - PRE_first_tail_x6_r0_body.st23.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged23`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap23 : PRE_first_tail_x6_r0_body.s230.heap = PRE_first_tail_x6_r0_body.st23.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext23 : PRE_first_tail_x6_r0_body.s230.next = PRE_first_tail_x6_r0_body.st23.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl23 : PRE_first_tail_x6_r0_body.s230.ctl = PRE_first_tail_x6_r0_body.st23.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack23 : PRE_first_tail_x6_r0_body.s230.stack = PRE_first_tail_x6_r0_body.st23.s2.stack ++ PRE_first_tail_x6_r0_body.s229.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs23 : PRE_first_tail_x6_r0_body.s230.jobs = PRE_first_tail_x6_r0_body.st23.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi23 : PRE_first_tail_x6_r0_body.s230.ffi = PRE_first_tail_x6_r0_body.st23.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace23 : PRE_first_tail_x6_r0_body.s230.trace = PRE_first_tail_x6_r0_body.st23.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores23 : PRE_first_tail_x6_r0_body.s230.stores = PRE_first_tail_x6_r0_body.st23.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD23
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 23 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived23 : PRE_first_tail_x6_r0_body.nr23.map (fun r => nth? PRE_first_tail_x6_r0_body.st23.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo23 : PRE_first_tail_x6_r0_body.nr23.all (Nat.ble 1036) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj23 : PRE_first_tail_x6_r0_body.cws23.all (fun c => !PRE_first_tail_x6_r0_body.ws23.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ23 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws23 PRE_first_tail_x6_r0_body.crs23 PRE_first_tail_x6_r0_body.ws23

end Host.Load.Run.Tpl
end

section -- st23/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st23`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st23.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st23.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st23.s2.heap PRE_first_tail_x6_r0_body.st23.wrR ++ freshOf PRE_first_tail_x6_r0_body.st23.s2.heap PRE_first_tail_x6_r0_body.st23.s0.next PRE_first_tail_x6_r0_body.st23.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st23.wr : List Nat := PRE_first_tail_x6_r0_body.st23.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st23.heapFoot : PRE_first_tail_x6_r0_body.st23.s2.heap = setAll PRE_first_tail_x6_r0_body.st23.s0.heap PRE_first_tail_x6_r0_body.st23.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st23.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st23.s0.next PRE_first_tail_x6_r0_body.st23.s2.next = true
theorem PRE_first_tail_x6_r0_body.st23.grows : PRE_first_tail_x6_r0_body.st23.s0.next ≤ PRE_first_tail_x6_r0_body.st23.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st23.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st23.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st23.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st23.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st23.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st23.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st23.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st23.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st23.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st23.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st23.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st23.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF23
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 23 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB23 : nodupT PRE_first_tail_x6_r0_body.st23.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup23 : PRE_first_tail_x6_r0_body.st23.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB23).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB23 : PRE_first_tail_x6_r0_body.st23.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound23 : ∀ b ∈ PRE_first_tail_x6_r0_body.st23.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB23 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr23 := PRE_first_tail_x6_r0_body.st23.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq23 : PRE_first_tail_x6_r0_body.st23.s2.trace = PRE_first_tail_x6_r0_body.trFr23 ++ PRE_first_tail_x6_r0_body.st23.s0.trace
theorem PRE_first_tail_x6_r0_body.trace23 : ∃ fr, PRE_first_tail_x6_r0_body.st23.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st23.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq23⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide23 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB23 : (PRE_first_tail_x6_r0_body.wide23.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st23.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix23 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide23, WFix Map.id (Present PRE_first_tail_x6_r0_body.st23.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB23 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL23
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 23 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s230`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO23 : PRE_first_tail_x6_r0_body.st23.S0.oracle = PRE_first_tail_x6_r0_body.st23.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B23 : PRE_first_tail_x6_r0_body.st23.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st23.s0.next || (PRE_first_tail_x6_r0_body.st23.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot23 : Conv.StageFoot PRE_first_tail_x6_r0_body.st23.wr PRE_first_tail_x6_r0_body.st23.s0 PRE_first_tail_x6_r0_body.st23.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st23.heapFoot PRE_first_tail_x6_r0_body.wrNodup23 PRE_first_tail_x6_r0_body.wrBound23 PRE_first_tail_x6_r0_body.wr0B23 PRE_first_tail_x6_r0_body.st23.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged23 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st23.F.S → PRE_first_tail_x6_r0_body.st23.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st23.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st23.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs23 PRE_first_tail_x6_r0_body.st23.wr PRE_first_tail_x6_r0_body.s229 PRE_first_tail_x6_r0_body.st23.s2 PRE_first_tail_x6_r0_body.st23.s0
      PRE_first_tail_x6_r0_body.st23.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st23.F FR W stk M ν K PRE_first_tail_x6_r0_body.s230 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso23 PRE_first_tail_x6_r0_body.stFoot23 PRE_first_tail_x6_r0_body.wrNodup23 PRE_first_tail_x6_r0_body.wrBound23 PRE_first_tail_x6_r0_body.trace23 PRE_first_tail_x6_r0_body.mheap23
    PRE_first_tail_x6_r0_body.mnext23 PRE_first_tail_x6_r0_body.mctl23 PRE_first_tail_x6_r0_body.mstack23 PRE_first_tail_x6_r0_body.mjobs23 PRE_first_tail_x6_r0_body.mffi23 PRE_first_tail_x6_r0_body.mtrace23 PRE_first_tail_x6_r0_body.mstores23 h

def PRE_first_tail_x6_r0_body.arrEl23_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE23_2665 : arrOf PRE_first_tail_x6_r0_body.s230 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl23_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA23_2665 : isArrB PRE_first_tail_x6_r0_body.s230 2665 = true
theorem PRE_first_tail_x6_r0_body.arr23_2665 : ∃ o, PRE_first_tail_x6_r0_body.s230.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl23_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE23_2665 PRE_first_tail_x6_r0_body.arrA23_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN23_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl23_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR23_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl23_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN23_2665

def PRE_first_tail_x6_r0_body.arrEl23_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE23_2673467 : arrOf PRE_first_tail_x6_r0_body.s230 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl23_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA23_2673467 : isArrB PRE_first_tail_x6_r0_body.s230 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr23_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s230.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl23_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE23_2673467 PRE_first_tail_x6_r0_body.arrA23_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN23_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl23_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR23_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl23_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN23_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k23 : isArrB PRE_first_tail_x6_r0_body.s230 4910 = false
theorem PRE_first_tail_x6_r0_body.keep23 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s230 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k23 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr23_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl23_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ23
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 23 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s229`, the merged
state `PRE_first_tail_x6_r0_body.s230`, the canonical state `PRE_first_tail_x6_r0_body.s231`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl23 : PRE_first_tail_x6_r0_body.pl23.all (Nat.ble PRE_first_tail_x6_r0_body.s229.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd23 : nodupT PRE_first_tail_x6_r0_body.pl23 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn123 : Nat.ble PRE_first_tail_x6_r0_body.s229.next 2692804 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst23 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s229.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn23 : PRE_first_tail_x6_r0_body.s231.next = PRE_first_tail_x6_r0_body.s229.next + PRE_first_tail_x6_r0_body.pl23.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn23 : PRE_first_tail_x6_r0_body.s230.next = 2692804
kernel_rfl PRE_first_tail_x6_r0_body.zgrow23 : Nat.ble PRE_first_tail_x6_r0_body.s231.next PRE_first_tail_x6_r0_body.s230.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh23 : PRE_first_tail_x6_r0_body.S229.tab.all (fun e => PRE_first_tail_x6_r0_body.cws23.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd23 : nodupT PRE_first_tail_x6_r0_body.cws23 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi23 : PRE_first_tail_x6_r0_body.nr23.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S230.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt23 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s229.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg23_2665 : PRE_first_tail_x6_r0_body.s231.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s231 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk23_2665 : (objOf PRE_first_tail_x6_r0_body.s231 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm23_2665 : PRE_first_tail_x6_r0_body.s230.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa23.obj (objOf PRE_first_tail_x6_r0_body.s231 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s230 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg23_2673467 : PRE_first_tail_x6_r0_body.s231.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s231 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk23_2673467 : (objOf PRE_first_tail_x6_r0_body.s231 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm23_2673467 : PRE_first_tail_x6_r0_body.s230.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa23.obj (objOf PRE_first_tail_x6_r0_body.s231 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s230 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw23_4910 : (PRE_first_tail_x6_r0_body.s231.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw23_2673472 : (PRE_first_tail_x6_r0_body.s231.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw23_2673473 : (PRE_first_tail_x6_r0_body.s231.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd23 : PRE_first_tail_x6_r0_body.cl23.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr23 : PRE_first_tail_x6_r0_body.st23.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s229.next || PRE_first_tail_x6_r0_body.cl23.contains b) = true
def PRE_first_tail_x6_r0_body.zl23 : List Nat := PRE_first_tail_x6_r0_body.cl23.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE23 : PRE_first_tail_x6_r0_body.zl23.map (fun a => PRE_first_tail_x6_r0_body.s230.heap.get (PRE_first_tail_x6_r0_body.kappa23.a a)) = PRE_first_tail_x6_r0_body.zl23.map (fun a => (PRE_first_tail_x6_r0_body.s231.heap.get a).map PRE_first_tail_x6_r0_body.kappa23.hobj)
theorem PRE_first_tail_x6_r0_body.zimg23 : HeapImg PRE_first_tail_x6_r0_body.kappa23 PRE_first_tail_x6_r0_body.s231 PRE_first_tail_x6_r0_body.s230 PRE_first_tail_x6_r0_body.zl23 := PRE_first_tail_x6_r0_body.zimgE23
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl23 : PRE_first_tail_x6_r0_body.s230.ctl = PRE_first_tail_x6_r0_body.kappa23.ctl PRE_first_tail_x6_r0_body.s231.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack23 : PRE_first_tail_x6_r0_body.s230.stack = PRE_first_tail_x6_r0_body.s231.stack.map PRE_first_tail_x6_r0_body.kappa23.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs23 : PRE_first_tail_x6_r0_body.s230.jobs = PRE_first_tail_x6_r0_body.s231.jobs.map PRE_first_tail_x6_r0_body.kappa23.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores23 : PRE_first_tail_x6_r0_body.s230.stores = PRE_first_tail_x6_r0_body.kappa23.stores PRE_first_tail_x6_r0_body.s231.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots23 : checkRootsSupp PRE_first_tail_x6_r0_body.s231 1036 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC23 : PRE_first_tail_x6_r0_body.S229.tab.length + PRE_first_tail_x6_r0_body.cws23.length = 1036
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap23 : PRE_first_tail_x6_r0_body.kappa23 = Conv.Map.compact PRE_first_tail_x6_r0_body.s229.next 2692804 PRE_first_tail_x6_r0_body.S229.tab.length PRE_first_tail_x6_r0_body.pl23 (PRE_first_tail_x6_r0_body.nr23.map NumV.ref) PRE_first_tail_x6_r0_body.kd23.big
  PRE_first_tail_x6_r0_body.kd23.region PRE_first_tail_x6_r0_body.kd23.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin23 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s231.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc23 : Conv.jcleanListB (⟨18653, 15733, 2692794, 1036⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s231 PRE_first_tail_x6_r0_body.cl23 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB23 : noBigRootsP (fun i => !Conv.oldBigB (⟨18653, 15733, 2692794, 1036⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s231.trace PRE_first_tail_x6_r0_body.s231 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm23 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15733 = true
theorem PRE_first_tail_x6_r0_body.cjcl23 (h : Conv.JClean (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s229) : Conv.JClean (⟨18653, 15733, 2692794, 1036⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s231 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle23)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap23 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd23 a ha)) PRE_first_tail_x6_r0_body.zjc23

end Host.Load.Run.Tpl
end

section -- st23/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st23.bodyLast from PRE_first_tail_x6_r0_body.st23.s1 to PRE_first_tail_x6_r0_body.st23.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st23.F PRE_first_tail_x6_r0_body.st23.s1).run PRE_first_tail_x6_r0_body.st23.S1 = some (PRE_first_tail_x6_r0_body.st23.s2, PRE_first_tail_x6_r0_body.st23.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st23.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st23.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st23.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st23.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st23/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st23.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st23.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st23.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st23.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st23.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st23.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st23.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st23.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st23.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st23.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st23.s0 PRE_first_tail_x6_r0_body.st23.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st23.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st23.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st23.s1 PRE_first_tail_x6_r0_body.st23.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st23/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st23.bodyK0F from PRE_first_tail_x6_r0_body.st23.s0 to PRE_first_tail_x6_r0_body.st23.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st23.F (PRE_first_tail_x6_r0_body.st23.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st23.ks 0).getD 0) PRE_first_tail_x6_r0_body.st23.s0 PRE_first_tail_x6_r0_body.st23.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st23.s1, PRE_first_tail_x6_r0_body.st23.S1)
theorem PRE_first_tail_x6_r0_body.st23.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st23.F (PRE_first_tail_x6_r0_body.st23.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st23.ks 0).getD 0) PRE_first_tail_x6_r0_body.st23.s0 PRE_first_tail_x6_r0_body.st23.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st23.s1, PRE_first_tail_x6_r0_body.st23.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st23.bodyOkLN_ok PRE_first_tail_x6_r0_body.st23.bodyK0F
end Host.Load.Run.Tpl
end

section -- st23/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st23.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st23.F (PRE_first_tail_x6_r0_body.st23.bodyOkL bytes rows) 98 PRE_first_tail_x6_r0_body.st23.s0 PRE_first_tail_x6_r0_body.st23.S0 = some (PRE_first_tail_x6_r0_body.st23.s1, PRE_first_tail_x6_r0_body.st23.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st23.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st23.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st23.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st23.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st23.F (PRE_first_tail_x6_r0_body.st23.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st23.s0
  S0 := PRE_first_tail_x6_r0_body.st23.S0
  s1 := PRE_first_tail_x6_r0_body.st23.s1
  S1 := PRE_first_tail_x6_r0_body.st23.S1
  s2 := PRE_first_tail_x6_r0_body.st23.s2
  S2 := PRE_first_tail_x6_r0_body.st23.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st23.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st23.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st23.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st23.bodyHalt
  last := PRE_first_tail_x6_r0_body.st23.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st23.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC24
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 24 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s248` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa24` into the merged state
`PRE_first_tail_x6_r0_body.s247`. -/

def PRE_first_tail_x6_r0_body.pl24 : List Nat := [2695399, 2694574, 2695405, 2695401, 2694576, 2695407]
def PRE_first_tail_x6_r0_body.nr24 : List Nat := [1139, 1138, 1114, 1122, 1127, 1132, 1137, 1111, 1112, 1113, 1120, 1121, 1109, 1116, 1117, 1118, 1119, 1115]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd24 : RData :=
  ⟨2694293, 2695442, Stage.setAll PTrie.nil [(2694287, 2695399), (2694288, 2694574), (2694289, 2695405), (2694290, 2695401), (2694291, 2694576), (2694292, 2695407)], Stage.setAll PTrie.nil [(18688, 18714), (18689, 18692), (18690, 18715)],
   18691, 18716, 15779, 15779, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(1109, .ref 1139), (1110, .ref 1138), (1111, .ref 1114), (1112, .ref 1122), (1113, .ref 1127), (1114, .ref 1132), (1115, .ref 1137), (1116, .ref 1111), (1117, .ref 1112), (1118, .ref 1113), (1119, .ref 1120), (1120, .ref 1121), (1121, .ref 1109), (1122, .ref 1116), (1123, .ref 1117), (1124, .ref 1118), (1125, .ref 1119), (1126, .ref 1115)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa24 : Map :=
  Conv.Map.compact 2694287 2695442 1109 PRE_first_tail_x6_r0_body.pl24 (PRE_first_tail_x6_r0_body.nr24.map NumV.ref) PRE_first_tail_x6_r0_body.kd24.big
    PRE_first_tail_x6_r0_body.kd24.region PRE_first_tail_x6_r0_body.kd24.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws24 : List Nat := [1423, 1424, 1425, 1426, 1427, 1428, 1429, 1430, 1431, 1432, 1433, 1434, 1435, 1436, 1437, 1438, 1439, 1440]
noncomputable def PRE_first_tail_x6_r0_body.crs24 : List SymE := PRE_first_tail_x6_r0_body.nr24.map fun r => (nth? PRE_first_tail_x6_r0_body.S247.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta24 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws24 PRE_first_tail_x6_r0_body.crs24
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB24 : List Nat := [2665, 2672362, 2673467, 2693461, 2694006, 2694262]

kernel_rfl PRE_first_tail_x6_r0_body.ctab24 : PRE_first_tail_x6_r0_body.S248.tab = PRE_first_tail_x6_r0_body.S246.tab ++ PRE_first_tail_x6_r0_body.cws24.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace24 : PRE_first_tail_x6_r0_body.s248.trace = PRE_first_tail_x6_r0_body.s246.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext24 : PRE_first_tail_x6_r0_body.s248.next = 2694293
kernel_rfl PRE_first_tail_x6_r0_body.ccounters24 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx.nnext) = (18691, 15779)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue24 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s247.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa24.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp24 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx.tokens.all (bSN 1127) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean24 : Conv.cleanListB 18691 131072 (fun r => Nat.ble 74764 r) PRE_first_tail_x6_r0_body.s248
    (PRE_first_tail_x6_r0_body.wrB24 ++ (List.range 6).map (2694287 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs24 : bigsOutB 18691 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK24
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl24`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl24 : List Nat := [2665, 2672362, 2673467, 2693461, 2694006, 2694262, 2694287, 2694288, 2694289, 2694290, 2694291, 2694292]
def PRE_first_tail_x6_r0_body.clo24 : List Nat := [18668, 18681, 18687, 18688, 18689, 18690]
def PRE_first_tail_x6_r0_body.cln24 : List Nat := [15752, 15753, 15754, 15755, 15756, 15757, 15758, 15759, 15760, 15761, 15762, 15763, 15764, 15765, 15766, 15767, 15768, 15769, 15770, 15771, 15772, 15773, 15774, 15775, 15776, 15777, 15778]
def PRE_first_tail_x6_r0_body.cli24 : List Nat := [15752, 15753, 15754, 15755, 15756, 15757, 15758, 15759, 15760, 15761, 15762, 15763, 15764, 15765, 15766, 15767, 15768, 15769, 15770, 15771, 15772, 15773, 15774, 15775, 15776, 15777, 15778]
kernel_rfl PRE_first_tail_x6_r0_body.cheap24 : PRE_first_tail_x6_r0_body.s248.heap = Stage.setAll PRE_first_tail_x6_r0_body.s246.heap (PRE_first_tail_x6_r0_body.cl24.filterMap fun a => (PRE_first_tail_x6_r0_body.s248.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe24 : Nat.ble PRE_first_tail_x6_r0_body.s246.next PRE_first_tail_x6_r0_body.s248.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP24 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s246 PRE_first_tail_x6_r0_body.s248 PRE_first_tail_x6_r0_body.cl24 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp24 : Conv.suppListB PRE_first_tail_x6_r0_body.s248 1127 PRE_first_tail_x6_r0_body.cl24 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound24 : Conv.boundListB PRE_first_tail_x6_r0_body.s248 PRE_first_tail_x6_r0_body.cl24 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK24 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln24.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK24 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo24.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK24 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli24.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst24 : Conv.sstListB 1127 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx PRE_first_tail_x6_r0_body.cln24 PRE_first_tail_x6_r0_body.clo24 PRE_first_tail_x6_r0_body.cli24 = true

end Host.Load.Run.Tpl
end

section -- SiteCl24
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA24 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo24.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd24 : (PRE_first_tail_x6_r0_body.clo24 ++ PRE_first_tail_x6_r0_body.cln24 ++ PRE_first_tail_x6_r0_body.cli24).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle24 : Conv.Cnt.leB (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) (⟨18691, 15779, 2694293, 1127⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck24 : Conv.ncleanListB (⟨18691, 15779, 2694293, 1127⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx PRE_first_tail_x6_r0_body.clo24 PRE_first_tail_x6_r0_body.cln24 PRE_first_tail_x6_r0_body.cli24 = true
theorem PRE_first_tail_x6_r0_body.cncl24 (h : Conv.NClean (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx) : Conv.NClean (⟨18691, 15779, 2694293, 1127⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle24 PRE_first_tail_x6_r0_body.ckA24 PRE_first_tail_x6_r0_body.cobjsK24 PRE_first_tail_x6_r0_body.cnodesK24 PRE_first_tail_x6_r0_body.citemsK24 PRE_first_tail_x6_r0_body.cbd24 PRE_first_tail_x6_r0_body.cck24

end Host.Load.Run.Tpl
end

section -- SiteS24
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 24 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc24 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P24 : LoadP := PRE_first_tail_x6_r0_body.Pc24.raise 15779
kernel_rfl PRE_first_tail_x6_r0_body.craise24 : Nat.ble PRE_first_tail_x6_r0_body.Pc24.N0 15779 = true
theorem PRE_first_tail_x6_r0_body.raised24 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc24 PRE_first_tail_x6_r0_body.P24 :=
  .inr ⟨15779, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise24, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_24 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_24 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s247.ffi)
def PRE_first_tail_x6_r0_body.khinv24 : PTrie Nat := Stage.setAll PTrie.nil [(18714, 18688), (18692, 18689), (18715, 18690)]
def PRE_first_tail_x6_r0_body.kninv24 : PTrie Nat := Stage.setAll PTrie.nil [(15752, 15752), (15753, 15753), (15754, 15754), (15755, 15755), (15756, 15756), (15757, 15757), (15758, 15758), (15759, 15759), (15760, 15760), (15761, 15761), (15762, 15762), (15763, 15763), (15764, 15764), (15765, 15765), (15766, 15766), (15767, 15767), (15768, 15768), (15769, 15769), (15770, 15770), (15771, 15771), (15772, 15772), (15773, 15773), (15774, 15774), (15775, 15775), (15776, 15776), (15777, 15777), (15778, 15778)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS24 : List Nat := [18668, 18681, 18687, 18688, 18689, 18690, 18691, 18692, 18693, 18694, 18695, 18696, 18697, 18698, 18699, 18700, 18701, 18702, 18703, 18704, 18705, 18706, 18707, 18708, 18709, 18710, 18711, 18712, 18713, 18714, 18715]
def PRE_first_tail_x6_r0_body.cnS24 : List Nat := List.range' 15752 27
def PRE_first_tail_x6_r0_body.ciS24 : List Nat := [] ++ List.range' 15752 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh024 : PRE_first_tail_x6_r0_body.kd24.nh0 = PRE_first_tail_x6_r0_body.cx0_24.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh124 : PRE_first_tail_x6_r0_body.kd24.nh1 = PRE_first_tail_x6_r0_body.cx1_24.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn024 : PRE_first_tail_x6_r0_body.kd24.nn0 = PRE_first_tail_x6_r0_body.cx0_24.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn124 : PRE_first_tail_x6_r0_body.kd24.nn1 = PRE_first_tail_x6_r0_body.cx1_24.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo24 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P24.lo && Nat.ble PRE_first_tail_x6_r0_body.P24.lo PRE_first_tail_x6_r0_body.cx0_24.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P24.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P24.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt24 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_24.mlx.next PRE_first_tail_x6_r0_body.cx1_24.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_24.mlx.nnext PRE_first_tail_x6_r0_body.cx1_24.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband24 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P24.NL && Nat.ble PRE_first_tail_x6_r0_body.P24.NL PRE_first_tail_x6_r0_body.P24.N0 && Nat.ble PRE_first_tail_x6_r0_body.P24.N0 PRE_first_tail_x6_r0_body.cx0_24.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow24 : PRE_first_tail_x6_r0_body.kd24.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren24 : checkRenG PRE_first_tail_x6_r0_body.kd24.hnd PRE_first_tail_x6_r0_body.khinv24 (phB PRE_first_tail_x6_r0_body.cx0_24.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband24 : PRE_first_tail_x6_r0_body.kd24.checkBand PRE_first_tail_x6_r0_body.P24.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos24 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd24.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren24 : checkRenG PRE_first_tail_x6_r0_body.kd24.node PRE_first_tail_x6_r0_body.kninv24 (pnB PRE_first_tail_x6_r0_body.cx0_24.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow24 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd24.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P24.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd24.nodeF j) PRE_first_tail_x6_r0_body.cx1_24.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a24 : PRE_first_tail_x6_r0_body.cx0_24.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b24 : PRE_first_tail_x6_r0_body.cx0_24.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok124 : PRE_first_tail_x6_r0_body.cx1_24.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend24 : PRE_first_tail_x6_r0_body.cx1_24.mlx.pending = PRE_first_tail_x6_r0_body.cx0_24.mlx.pending.map PRE_first_tail_x6_r0_body.kappa24.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh24 : PRE_first_tail_x6_r0_body.cx1_24.mlx.errh = PRE_first_tail_x6_r0_body.cx0_24.mlx.errh.map PRE_first_tail_x6_r0_body.kappa24.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles24 : PRE_first_tail_x6_r0_body.cx1_24.mlx.files = PRE_first_tail_x6_r0_body.cx0_24.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch24 : PRE_first_tail_x6_r0_body.cx1_24.mlx.arch = PRE_first_tail_x6_r0_body.cx0_24.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes24 : PRE_first_tail_x6_r0_body.cx1_24.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_24.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired24 : PRE_first_tail_x6_r0_body.cx1_24.mlx.wired = PRE_first_tail_x6_r0_body.cx0_24.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost24 : PRE_first_tail_x6_r0_body.cx1_24.host = PRE_first_tail_x6_r0_body.cx0_24.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd24`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn024 : PRE_first_tail_x6_r0_body.kd24.n0 = 2694293
kernel_rfl PRE_first_tail_x6_r0_body.ckn124 : PRE_first_tail_x6_r0_body.kd24.n1 = 2695442
kernel_rfl PRE_first_tail_x6_r0_body.ckheap24 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd24.heap).all (fun x => Nat.ble 2694287 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl24 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd24.heap.get (2694287 + j) = nth? PRE_first_tail_x6_r0_body.pl24 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja24 : Nat.ble 2694287 2694287 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn24 : Nat.ble 1109 1109 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD24 : Nat.ble 2694287 PRE_first_tail_x6_r0_body.kd24.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn24 : Nat.ble 18688 PRE_first_tail_x6_r0_body.kd24.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn24 : Nat.ble 15752 PRE_first_tail_x6_r0_body.kd24.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb24 : Nat.ble 18688 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap24 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd24.heap).all (Nat.ble (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd24 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd24.hnd).all (Nat.ble (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode24 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd24.node).all (Nat.ble (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix24 : Conv.FixOld (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa24 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja24) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn24) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD24) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn24) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn24) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb24) PRE_first_tail_x6_r0_body.fheap24 PRE_first_tail_x6_r0_body.fhnd24 PRE_first_tail_x6_r0_body.fnode24
kernel_rfl PRE_first_tail_x6_r0_body.fcxn24 : (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn24 : (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle024 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_24.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_24.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk24 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd24.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A24 : PRE_first_tail_x6_r0_body.cx1_24.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS24.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_24.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O24 : PRE_first_tail_x6_r0_body.cx1_24.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS24.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_24.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N24 : PRE_first_tail_x6_r0_body.cx1_24.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS24.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_24.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I24 : PRE_first_tail_x6_r0_body.cx1_24.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS24.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_24.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd24 : (PRE_first_tail_x6_r0_body.clo24 ++ PRE_first_tail_x6_r0_body.cln24 ++ PRE_first_tail_x6_r0_body.cli24 ++ PRE_first_tail_x6_r0_body.cwS24 ++ PRE_first_tail_x6_r0_body.cnS24 ++ PRE_first_tail_x6_r0_body.ciS24).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW24 : PRE_first_tail_x6_r0_body.cwS24.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo24.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI24 : PRE_first_tail_x6_r0_body.ciS24.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli24.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN24 : PRE_first_tail_x6_r0_body.cnS24.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF24 : PRE_first_tail_x6_r0_body.cln24.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh24 : PRE_first_tail_x6_r0_body.clo24.all (handleOK PRE_first_tail_x6_r0_body.kappa24 PRE_first_tail_x6_r0_body.P24.lo PRE_first_tail_x6_r0_body.cx0_24.mlx PRE_first_tail_x6_r0_body.cx1_24.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo24 : PRE_first_tail_x6_r0_body.clo24.map (fun h => PRE_first_tail_x6_r0_body.cx1_24.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa24.handle h)) = PRE_first_tail_x6_r0_body.clo24.map (fun h => (PRE_first_tail_x6_r0_body.cx0_24.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa24.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok24 : PRE_first_tail_x6_r0_body.clo24.all (objOK PRE_first_tail_x6_r0_body.kappa24 PRE_first_tail_x6_r0_body.P24.NL PRE_first_tail_x6_r0_body.cx0_24.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd24 : PRE_first_tail_x6_r0_body.cln24.all (nodeOKF PRE_first_tail_x6_r0_body.kappa24 PRE_first_tail_x6_r0_body.P24 PRE_first_tail_x6_r0_body.cx0_24.mlx PRE_first_tail_x6_r0_body.cx1_24.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp24 : ((PRE_first_tail_x6_r0_body.cln24.filter (fullB PRE_first_tail_x6_r0_body.P24))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_24.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa24.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln24.filter (fullB PRE_first_tail_x6_r0_body.P24))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_24.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa24.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI24 : incrB PRE_first_tail_x6_r0_body.kd24.nodeF (List.range' 15752 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK24 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd24.node).all (fun k => Nat.ble 15752 k && Nat.blt k 15779) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL24 : (PRE_first_tail_x6_r0_body.cln24.filter (Nat.ble PRE_first_tail_x6_r0_body.P24.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd24.nodeF i) && (Nat.blt i 15779 || Nat.ble PRE_first_tail_x6_r0_body.kd24.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord24 : (PRE_first_tail_x6_r0_body.cln24.filter (Nat.ble PRE_first_tail_x6_r0_body.P24.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd24.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd24.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd24.nodeF j) (PRE_first_tail_x6_r0_body.kd24.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow24 PRE_first_tail_x6_r0_body.cnn124 PRE_first_tail_x6_r0_body.fnordI24 PRE_first_tail_x6_r0_body.fnordK24 PRE_first_tail_x6_r0_body.fnordL24
kernel_rfl PRE_first_tail_x6_r0_body.fi24 : PRE_first_tail_x6_r0_body.cli24.all (pnB PRE_first_tail_x6_r0_body.cx0_24.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii24 : PRE_first_tail_x6_r0_body.cli24.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_24.mlx.items.get (PRE_first_tail_x6_r0_body.kappa24.node k) = (PRE_first_tail_x6_r0_body.cx0_24.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa24.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot24 (clean : Conv.NClean (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P24.NL) (cl : SSt (· < 1127) PRE_first_tail_x6_r0_body.cx0_24.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P24 1127 PRE_first_tail_x6_r0_body.kappa24 PRE_first_tail_x6_r0_body.kd24 PRE_first_tail_x6_r0_body.khinv24 PRE_first_tail_x6_r0_body.kninv24 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx PRE_first_tail_x6_r0_body.cx0_24.mlx PRE_first_tail_x6_r0_body.cx1_24.mlx (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo24 PRE_first_tail_x6_r0_body.cln24 PRE_first_tail_x6_r0_body.cli24 PRE_first_tail_x6_r0_body.cwS24 PRE_first_tail_x6_r0_body.cnS24 PRE_first_tail_x6_r0_body.ciS24 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh024, PRE_first_tail_x6_r0_body.cnh124, PRE_first_tail_x6_r0_body.cnn024, PRE_first_tail_x6_r0_body.cnn124, PRE_first_tail_x6_r0_body.cplo24, PRE_first_tail_x6_r0_body.ccnt24, PRE_first_tail_x6_r0_body.cnband24, PRE_first_tail_x6_r0_body.chbelow24, PRE_first_tail_x6_r0_body.chren24, PRE_first_tail_x6_r0_body.cband24, PRE_first_tail_x6_r0_body.cnh1pos24, PRE_first_tail_x6_r0_body.cnren24, PRE_first_tail_x6_r0_body.cnlow24, PRE_first_tail_x6_r0_body.cabs0a24, PRE_first_tail_x6_r0_body.cabs0b24, PRE_first_tail_x6_r0_body.ctok124, PRE_first_tail_x6_r0_body.cpend24, PRE_first_tail_x6_r0_body.cerrh24, PRE_first_tail_x6_r0_body.cfiles24, PRE_first_tail_x6_r0_body.carch24, PRE_first_tail_x6_r0_body.csizes24, PRE_first_tail_x6_r0_body.cwired24, PRE_first_tail_x6_r0_body.cfix24, clean, PRE_first_tail_x6_r0_body.fcxn24, PRE_first_tail_x6_r0_body.fcnn24, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle024, PRE_first_tail_x6_r0_body.fnk24, PRE_first_tail_x6_r0_body.ckA24, PRE_first_tail_x6_r0_body.cobjsK24, PRE_first_tail_x6_r0_body.cnodesK24, PRE_first_tail_x6_r0_body.citemsK24, PRE_first_tail_x6_r0_body.f1A24, PRE_first_tail_x6_r0_body.f1O24, PRE_first_tail_x6_r0_body.f1N24, PRE_first_tail_x6_r0_body.f1I24, PRE_first_tail_x6_r0_body.fbd24, PRE_first_tail_x6_r0_body.fincW24, PRE_first_tail_x6_r0_body.fincI24, PRE_first_tail_x6_r0_body.fincN24, PRE_first_tail_x6_r0_body.flnF24, PRE_first_tail_x6_r0_body.fh24, PRE_first_tail_x6_r0_body.fo24, PRE_first_tail_x6_r0_body.fok24, PRE_first_tail_x6_r0_body.fnd24, PRE_first_tail_x6_r0_body.fp24, PRE_first_tail_x6_r0_body.fnord24, PRE_first_tail_x6_r0_body.fi24, PRE_first_tail_x6_r0_body.fii24⟩
theorem PRE_first_tail_x6_r0_body.cnshift24 (clean : Conv.NClean (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P24.NL) (cl : SSt (· < 1127) PRE_first_tail_x6_r0_body.cx0_24.mlx) : NShift PRE_first_tail_x6_r0_body.P24 1127 PRE_first_tail_x6_r0_body.kappa24 PRE_first_tail_x6_r0_body.cx0_24 PRE_first_tail_x6_r0_body.cx1_24 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot24 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost24 (compact_a_eq PRE_first_tail_x6_r0_body.ckn024 PRE_first_tail_x6_r0_body.ckn124 PRE_first_tail_x6_r0_body.ckheap24 PRE_first_tail_x6_r0_body.ckpl24)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_24 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s246.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_24 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s246.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_24 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s246.ffi) = some PRE_first_tail_x6_r0_body.fxC_24
kernel_rfl PRE_first_tail_x6_r0_body.okrC_24 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s246.ffi) = some PRE_first_tail_x6_r0_body.krC_24
noncomputable def PRE_first_tail_x6_r0_body.fx0_24 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s248.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_24 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s248.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_24 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s248.ffi) = some PRE_first_tail_x6_r0_body.fx0_24
kernel_rfl PRE_first_tail_x6_r0_body.okr0_24 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s248.ffi) = some PRE_first_tail_x6_r0_body.kr0_24
noncomputable def PRE_first_tail_x6_r0_body.fx1_24 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s247.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_24 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s247.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_24 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s247.ffi) = some PRE_first_tail_x6_r0_body.fx1_24
kernel_rfl PRE_first_tail_x6_r0_body.okr1_24 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s247.ffi) = some PRE_first_tail_x6_r0_body.kr1_24
kernel_rfl PRE_first_tail_x6_r0_body.ff024 : PRE_first_tail_x6_r0_body.fx0_24 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_24 (PRE_first_tail_x6_r0_body.clo24.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_24.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff124 : PRE_first_tail_x6_r0_body.fx1_24 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_24 (PRE_first_tail_x6_r0_body.cwS24.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_24.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck24 : freedLB PRE_first_tail_x6_r0_body.kappa24 PRE_first_tail_x6_r0_body.cx0_24.mlx PRE_first_tail_x6_r0_body.fx0_24 PRE_first_tail_x6_r0_body.fx1_24 PRE_first_tail_x6_r0_body.clo24 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf024 : PRE_first_tail_x6_r0_body.kr0_24.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_24.flags (PRE_first_tail_x6_r0_body.clo24.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_24.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt024 : PRE_first_tail_x6_r0_body.kr0_24.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_24.targs (PRE_first_tail_x6_r0_body.clo24.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_24.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf124 : PRE_first_tail_x6_r0_body.kr1_24.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_24.flags (PRE_first_tail_x6_r0_body.cwS24.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_24.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt124 : PRE_first_tail_x6_r0_body.kr1_24.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_24.targs (PRE_first_tail_x6_r0_body.cwS24.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_24.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck24 : krecLB PRE_first_tail_x6_r0_body.kappa24 1127 PRE_first_tail_x6_r0_body.cx0_24.mlx PRE_first_tail_x6_r0_body.kr0_24 PRE_first_tail_x6_r0_body.kr1_24 PRE_first_tail_x6_r0_body.clo24 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn24 : Nat.ble 1109 1127 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge24 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s247.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s248.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR24 : pendRegB PRE_first_tail_x6_r0_body.kappa24 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe24 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s247.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift24 (clean : Conv.NClean (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P24.NL) (cl : SSt (· < 1127) PRE_first_tail_x6_r0_body.cx0_24.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_24.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_24.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_24.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_24.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P24 1127 PRE_first_tail_x6_r0_body.kappa24 PRE_first_tail_x6_r0_body.s248.ffi PRE_first_tail_x6_r0_body.s247.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift24 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue24, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp24 t ht),
    PRE_first_tail_x6_r0_body.cbridge24,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s248.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s247.ffi) (PRE_first_tail_x6_r0_body.cfoot24 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_24 PRE_first_tail_x6_r0_body.ofx1_24 hobjC PRE_first_tail_x6_r0_body.ff024 PRE_first_tail_x6_r0_body.ff124 PRE_first_tail_x6_r0_body.ffck24,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s248.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s247.ffi) (PRE_first_tail_x6_r0_body.cfoot24 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_24 PRE_first_tail_x6_r0_body.okr1_24 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn24) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf024 PRE_first_tail_x6_r0_body.fkt024 PRE_first_tail_x6_r0_body.fkf124 PRE_first_tail_x6_r0_body.fkt124 PRE_first_tail_x6_r0_body.fkck24,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh024 PRE_first_tail_x6_r0_body.cnh124 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe24) PRE_first_tail_x6_r0_body.cpendR24⟩

end Host.Load.Run.Tpl
end

section -- st24/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st24 0
host_stream_state PRE_first_tail_x6_r0_body.st24 1
host_stream_state PRE_first_tail_x6_r0_body.st24 2
host_stream_state PRE_first_tail_x6_r0_body.st24 3
host_stream_state PRE_first_tail_x6_r0_body.st24 4
host_stream_state PRE_first_tail_x6_r0_body.st24 5
end Host.Load.Run.Tpl
end

section -- Site24
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 24 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g24__g25` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s246`, the merged state `PRE_first_tail_x6_r0_body.s247`,
the site template `PRE_first_tail_x6_r0_body.st24` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s248`: the merge.
The footprint's facts are in `SiteF24`, the compaction's in `SiteC24`, `SiteK24`, `SiteNa24`, `SiteNb24`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso24 : PRE_first_tail_x6_r0_body.st24.s0 = { PRE_first_tail_x6_r0_body.s246 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs24 : List Frame := PRE_first_tail_x6_r0_body.s246.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_24 : PRE_first_tail_x6_r0_body.S246.tab.length = 1109
kernel_rfl PRE_first_tail_x6_r0_body.tab0_24 : PRE_first_tail_x6_r0_body.st24.S0.tab = PRE_first_tail_x6_r0_body.S246.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws24 : List Nat := [1392, 1393, 1394, 1395, 1396, 1397, 1398, 1399, 1400, 1401, 1402, 1403, 1404, 1405, 1406, 1407, 1408, 1409, 1410, 1411, 1412, 1413, 1414, 1415, 1416, 1417, 1418, 1419, 1420, 1421, 1422]
kernel_rfl PRE_first_tail_x6_r0_body.fresh24 : (PRE_first_tail_x6_r0_body.S246.tab.all fun e => PRE_first_tail_x6_r0_body.ws24.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S246.oracle.all fun q => PRE_first_tail_x6_r0_body.ws24.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab24 : PRE_first_tail_x6_r0_body.S247.tab = PRE_first_tail_x6_r0_body.S246.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws24
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen24 : PRE_first_tail_x6_r0_body.st24.S5.tab.length - PRE_first_tail_x6_r0_body.st24.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged24`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap24 : PRE_first_tail_x6_r0_body.s247.heap = PRE_first_tail_x6_r0_body.st24.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext24 : PRE_first_tail_x6_r0_body.s247.next = PRE_first_tail_x6_r0_body.st24.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl24 : PRE_first_tail_x6_r0_body.s247.ctl = PRE_first_tail_x6_r0_body.st24.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack24 : PRE_first_tail_x6_r0_body.s247.stack = PRE_first_tail_x6_r0_body.st24.s5.stack ++ PRE_first_tail_x6_r0_body.s246.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs24 : PRE_first_tail_x6_r0_body.s247.jobs = PRE_first_tail_x6_r0_body.st24.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi24 : PRE_first_tail_x6_r0_body.s247.ffi = PRE_first_tail_x6_r0_body.st24.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace24 : PRE_first_tail_x6_r0_body.s247.trace = PRE_first_tail_x6_r0_body.st24.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores24 : PRE_first_tail_x6_r0_body.s247.stores = PRE_first_tail_x6_r0_body.st24.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD24
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 24 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived24 : PRE_first_tail_x6_r0_body.nr24.map (fun r => nth? PRE_first_tail_x6_r0_body.st24.S5.tab r) =
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
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo24 : PRE_first_tail_x6_r0_body.nr24.all (Nat.ble 1109) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj24 : PRE_first_tail_x6_r0_body.cws24.all (fun c => !PRE_first_tail_x6_r0_body.ws24.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ24 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws24 PRE_first_tail_x6_r0_body.crs24 PRE_first_tail_x6_r0_body.ws24

end Host.Load.Run.Tpl
end

section -- st24/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st24`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st24.wrR : List (Nat × Nat) := [(2672362, 2672363), (2693461, 2693462), (2694006, 2694007), (2694262, 2694263)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st24.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st24.s5.heap PRE_first_tail_x6_r0_body.st24.wrR ++ freshOf PRE_first_tail_x6_r0_body.st24.s5.heap PRE_first_tail_x6_r0_body.st24.s0.next PRE_first_tail_x6_r0_body.st24.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st24.wr : List Nat := PRE_first_tail_x6_r0_body.st24.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st24.heapFoot : PRE_first_tail_x6_r0_body.st24.s5.heap = setAll PRE_first_tail_x6_r0_body.st24.s0.heap PRE_first_tail_x6_r0_body.st24.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st24.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st24.s0.next PRE_first_tail_x6_r0_body.st24.s5.next = true
theorem PRE_first_tail_x6_r0_body.st24.grows : PRE_first_tail_x6_r0_body.st24.s0.next ≤ PRE_first_tail_x6_r0_body.st24.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st24.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st24.wh : List Nat := [18668, 18681, 18687, 18688, 18689, 18690, 18691, 18692, 18693, 18694, 18695, 18696, 18697, 18698, 18699, 18700, 18701, 18702, 18703, 18704, 18705, 18706, 18707, 18708, 18709, 18710, 18711, 18712, 18713, 18714, 18715]
def PRE_first_tail_x6_r0_body.st24.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st24.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st24.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st24.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st24.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st24.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st24.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st24.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st24.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st24.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF24
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 24 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB24 : nodupT PRE_first_tail_x6_r0_body.st24.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup24 : PRE_first_tail_x6_r0_body.st24.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB24).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB24 : PRE_first_tail_x6_r0_body.st24.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound24 : ∀ b ∈ PRE_first_tail_x6_r0_body.st24.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB24 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr24 := PRE_first_tail_x6_r0_body.st24.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq24 : PRE_first_tail_x6_r0_body.st24.s5.trace = PRE_first_tail_x6_r0_body.trFr24 ++ PRE_first_tail_x6_r0_body.st24.s0.trace
theorem PRE_first_tail_x6_r0_body.trace24 : ∃ fr, PRE_first_tail_x6_r0_body.st24.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st24.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq24⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide24 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB24 : (PRE_first_tail_x6_r0_body.wide24.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st24.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix24 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide24, WFix Map.id (Present PRE_first_tail_x6_r0_body.st24.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB24 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL24
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 24 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s247`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO24 : PRE_first_tail_x6_r0_body.st24.S0.oracle = PRE_first_tail_x6_r0_body.st24.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B24 : PRE_first_tail_x6_r0_body.st24.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st24.s0.next || (PRE_first_tail_x6_r0_body.st24.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot24 : Conv.StageFoot PRE_first_tail_x6_r0_body.st24.wr PRE_first_tail_x6_r0_body.st24.s0 PRE_first_tail_x6_r0_body.st24.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st24.heapFoot PRE_first_tail_x6_r0_body.wrNodup24 PRE_first_tail_x6_r0_body.wrBound24 PRE_first_tail_x6_r0_body.wr0B24 PRE_first_tail_x6_r0_body.st24.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged24 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st24.F.S → PRE_first_tail_x6_r0_body.st24.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st24.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st24.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs24 PRE_first_tail_x6_r0_body.st24.wr PRE_first_tail_x6_r0_body.s246 PRE_first_tail_x6_r0_body.st24.s5 PRE_first_tail_x6_r0_body.st24.s0
      PRE_first_tail_x6_r0_body.st24.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st24.F FR W stk M ν K PRE_first_tail_x6_r0_body.s247 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso24 PRE_first_tail_x6_r0_body.stFoot24 PRE_first_tail_x6_r0_body.wrNodup24 PRE_first_tail_x6_r0_body.wrBound24 PRE_first_tail_x6_r0_body.trace24 PRE_first_tail_x6_r0_body.mheap24
    PRE_first_tail_x6_r0_body.mnext24 PRE_first_tail_x6_r0_body.mctl24 PRE_first_tail_x6_r0_body.mstack24 PRE_first_tail_x6_r0_body.mjobs24 PRE_first_tail_x6_r0_body.mffi24 PRE_first_tail_x6_r0_body.mtrace24 PRE_first_tail_x6_r0_body.mstores24 h

def PRE_first_tail_x6_r0_body.arrEl24_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE24_2665 : arrOf PRE_first_tail_x6_r0_body.s247 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl24_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA24_2665 : isArrB PRE_first_tail_x6_r0_body.s247 2665 = true
theorem PRE_first_tail_x6_r0_body.arr24_2665 : ∃ o, PRE_first_tail_x6_r0_body.s247.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl24_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE24_2665 PRE_first_tail_x6_r0_body.arrA24_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN24_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl24_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR24_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl24_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN24_2665

def PRE_first_tail_x6_r0_body.arrEl24_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE24_2673467 : arrOf PRE_first_tail_x6_r0_body.s247 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl24_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA24_2673467 : isArrB PRE_first_tail_x6_r0_body.s247 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr24_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s247.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl24_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE24_2673467 PRE_first_tail_x6_r0_body.arrA24_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN24_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl24_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR24_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl24_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN24_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k24 : isArrB PRE_first_tail_x6_r0_body.s247 4910 = false
theorem PRE_first_tail_x6_r0_body.keep24 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s247 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k24 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr24_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl24_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ24
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 24 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s246`, the merged
state `PRE_first_tail_x6_r0_body.s247`, the canonical state `PRE_first_tail_x6_r0_body.s248`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl24 : PRE_first_tail_x6_r0_body.pl24.all (Nat.ble PRE_first_tail_x6_r0_body.s246.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd24 : nodupT PRE_first_tail_x6_r0_body.pl24 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn124 : Nat.ble PRE_first_tail_x6_r0_body.s246.next 2695442 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst24 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s246.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn24 : PRE_first_tail_x6_r0_body.s248.next = PRE_first_tail_x6_r0_body.s246.next + PRE_first_tail_x6_r0_body.pl24.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn24 : PRE_first_tail_x6_r0_body.s247.next = 2695442
kernel_rfl PRE_first_tail_x6_r0_body.zgrow24 : Nat.ble PRE_first_tail_x6_r0_body.s248.next PRE_first_tail_x6_r0_body.s247.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh24 : PRE_first_tail_x6_r0_body.S246.tab.all (fun e => PRE_first_tail_x6_r0_body.cws24.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd24 : nodupT PRE_first_tail_x6_r0_body.cws24 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi24 : PRE_first_tail_x6_r0_body.nr24.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S247.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt24 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s246.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg24_2665 : PRE_first_tail_x6_r0_body.s248.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s248 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk24_2665 : (objOf PRE_first_tail_x6_r0_body.s248 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm24_2665 : PRE_first_tail_x6_r0_body.s247.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa24.obj (objOf PRE_first_tail_x6_r0_body.s248 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s247 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg24_2673467 : PRE_first_tail_x6_r0_body.s248.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s248 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk24_2673467 : (objOf PRE_first_tail_x6_r0_body.s248 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm24_2673467 : PRE_first_tail_x6_r0_body.s247.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa24.obj (objOf PRE_first_tail_x6_r0_body.s248 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s247 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw24_4910 : (PRE_first_tail_x6_r0_body.s248.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw24_2673472 : (PRE_first_tail_x6_r0_body.s248.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw24_2673473 : (PRE_first_tail_x6_r0_body.s248.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd24 : PRE_first_tail_x6_r0_body.cl24.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr24 : PRE_first_tail_x6_r0_body.st24.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s246.next || PRE_first_tail_x6_r0_body.cl24.contains b) = true
def PRE_first_tail_x6_r0_body.zl24 : List Nat := PRE_first_tail_x6_r0_body.cl24.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE24 : PRE_first_tail_x6_r0_body.zl24.map (fun a => PRE_first_tail_x6_r0_body.s247.heap.get (PRE_first_tail_x6_r0_body.kappa24.a a)) = PRE_first_tail_x6_r0_body.zl24.map (fun a => (PRE_first_tail_x6_r0_body.s248.heap.get a).map PRE_first_tail_x6_r0_body.kappa24.hobj)
theorem PRE_first_tail_x6_r0_body.zimg24 : HeapImg PRE_first_tail_x6_r0_body.kappa24 PRE_first_tail_x6_r0_body.s248 PRE_first_tail_x6_r0_body.s247 PRE_first_tail_x6_r0_body.zl24 := PRE_first_tail_x6_r0_body.zimgE24
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl24 : PRE_first_tail_x6_r0_body.s247.ctl = PRE_first_tail_x6_r0_body.kappa24.ctl PRE_first_tail_x6_r0_body.s248.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack24 : PRE_first_tail_x6_r0_body.s247.stack = PRE_first_tail_x6_r0_body.s248.stack.map PRE_first_tail_x6_r0_body.kappa24.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs24 : PRE_first_tail_x6_r0_body.s247.jobs = PRE_first_tail_x6_r0_body.s248.jobs.map PRE_first_tail_x6_r0_body.kappa24.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores24 : PRE_first_tail_x6_r0_body.s247.stores = PRE_first_tail_x6_r0_body.kappa24.stores PRE_first_tail_x6_r0_body.s248.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots24 : checkRootsSupp PRE_first_tail_x6_r0_body.s248 1127 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC24 : PRE_first_tail_x6_r0_body.S246.tab.length + PRE_first_tail_x6_r0_body.cws24.length = 1127
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap24 : PRE_first_tail_x6_r0_body.kappa24 = Conv.Map.compact PRE_first_tail_x6_r0_body.s246.next 2695442 PRE_first_tail_x6_r0_body.S246.tab.length PRE_first_tail_x6_r0_body.pl24 (PRE_first_tail_x6_r0_body.nr24.map NumV.ref) PRE_first_tail_x6_r0_body.kd24.big
  PRE_first_tail_x6_r0_body.kd24.region PRE_first_tail_x6_r0_body.kd24.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin24 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s248.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc24 : Conv.jcleanListB (⟨18691, 15779, 2694293, 1127⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s248 PRE_first_tail_x6_r0_body.cl24 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB24 : noBigRootsP (fun i => !Conv.oldBigB (⟨18691, 15779, 2694293, 1127⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s248.trace PRE_first_tail_x6_r0_body.s248 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm24 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15752 = true
theorem PRE_first_tail_x6_r0_body.cjcl24 (h : Conv.JClean (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s246) : Conv.JClean (⟨18691, 15779, 2694293, 1127⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s248 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle24)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap24 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd24 a ha)) PRE_first_tail_x6_r0_body.zjc24

end Host.Load.Run.Tpl
end

section -- st24/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st24.bodyLast from PRE_first_tail_x6_r0_body.st24.s4 to PRE_first_tail_x6_r0_body.st24.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st24.F PRE_first_tail_x6_r0_body.st24.s4).run PRE_first_tail_x6_r0_body.st24.S4 = some (PRE_first_tail_x6_r0_body.st24.s5, PRE_first_tail_x6_r0_body.st24.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st24.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st24.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st24.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st24.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st24/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st24.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st24.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st24.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st24.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st24.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st24.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st24.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st24.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st24.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st24.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st24.s0 PRE_first_tail_x6_r0_body.st24.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st24.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st24.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st24.s4 PRE_first_tail_x6_r0_body.st24.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st24/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st24.bodyK0F from PRE_first_tail_x6_r0_body.st24.s0 to PRE_first_tail_x6_r0_body.st24.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st24.F (PRE_first_tail_x6_r0_body.st24.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st24.ks 0).getD 0) PRE_first_tail_x6_r0_body.st24.s0 PRE_first_tail_x6_r0_body.st24.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st24.s1, PRE_first_tail_x6_r0_body.st24.S1)
theorem PRE_first_tail_x6_r0_body.st24.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st24.F (PRE_first_tail_x6_r0_body.st24.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st24.ks 0).getD 0) PRE_first_tail_x6_r0_body.st24.s0 PRE_first_tail_x6_r0_body.st24.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st24.s1, PRE_first_tail_x6_r0_body.st24.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st24.bodyOkLN_ok PRE_first_tail_x6_r0_body.st24.bodyK0F
end Host.Load.Run.Tpl
end

section -- st24/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st24.bodyK1F from PRE_first_tail_x6_r0_body.st24.s1 to PRE_first_tail_x6_r0_body.st24.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st24.F (PRE_first_tail_x6_r0_body.st24.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st24.ks 1).getD 0) PRE_first_tail_x6_r0_body.st24.s1 PRE_first_tail_x6_r0_body.st24.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st24.s2, PRE_first_tail_x6_r0_body.st24.S2)
theorem PRE_first_tail_x6_r0_body.st24.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st24.F (PRE_first_tail_x6_r0_body.st24.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st24.ks 1).getD 0) PRE_first_tail_x6_r0_body.st24.s1 PRE_first_tail_x6_r0_body.st24.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st24.s2, PRE_first_tail_x6_r0_body.st24.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st24.bodyOkLN_ok PRE_first_tail_x6_r0_body.st24.bodyK1F
end Host.Load.Run.Tpl
end

section -- st24/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st24.bodyK2F from PRE_first_tail_x6_r0_body.st24.s2 to PRE_first_tail_x6_r0_body.st24.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st24.F (PRE_first_tail_x6_r0_body.st24.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st24.ks 2).getD 0) PRE_first_tail_x6_r0_body.st24.s2 PRE_first_tail_x6_r0_body.st24.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st24.s3, PRE_first_tail_x6_r0_body.st24.S3)
theorem PRE_first_tail_x6_r0_body.st24.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st24.F (PRE_first_tail_x6_r0_body.st24.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st24.ks 2).getD 0) PRE_first_tail_x6_r0_body.st24.s2 PRE_first_tail_x6_r0_body.st24.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st24.s3, PRE_first_tail_x6_r0_body.st24.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st24.bodyOkLN_ok PRE_first_tail_x6_r0_body.st24.bodyK2F
end Host.Load.Run.Tpl
end

section -- st24/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st24.bodyK3F from PRE_first_tail_x6_r0_body.st24.s3 to PRE_first_tail_x6_r0_body.st24.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st24.F (PRE_first_tail_x6_r0_body.st24.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st24.ks 3).getD 0) PRE_first_tail_x6_r0_body.st24.s3 PRE_first_tail_x6_r0_body.st24.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st24.s4, PRE_first_tail_x6_r0_body.st24.S4)
theorem PRE_first_tail_x6_r0_body.st24.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st24.F (PRE_first_tail_x6_r0_body.st24.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st24.ks 3).getD 0) PRE_first_tail_x6_r0_body.st24.s3 PRE_first_tail_x6_r0_body.st24.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st24.s4, PRE_first_tail_x6_r0_body.st24.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st24.bodyOkLN_ok PRE_first_tail_x6_r0_body.st24.bodyK3F
end Host.Load.Run.Tpl
end

section -- st24/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st24.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st24.F (PRE_first_tail_x6_r0_body.st24.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st24.s0 PRE_first_tail_x6_r0_body.st24.S0 = some (PRE_first_tail_x6_r0_body.st24.s4, PRE_first_tail_x6_r0_body.st24.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st24.F (PRE_first_tail_x6_r0_body.st24.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st24.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st24.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st24.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st24.ks 3).getD 0) PRE_first_tail_x6_r0_body.st24.s0 PRE_first_tail_x6_r0_body.st24.s3 PRE_first_tail_x6_r0_body.st24.s4 PRE_first_tail_x6_r0_body.st24.S0 PRE_first_tail_x6_r0_body.st24.S3 PRE_first_tail_x6_r0_body.st24.S4 (runOk_trans PRE_first_tail_x6_r0_body.st24.F (PRE_first_tail_x6_r0_body.st24.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st24.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st24.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st24.ks 2).getD 0) PRE_first_tail_x6_r0_body.st24.s0 PRE_first_tail_x6_r0_body.st24.s2 PRE_first_tail_x6_r0_body.st24.s3 PRE_first_tail_x6_r0_body.st24.S0 PRE_first_tail_x6_r0_body.st24.S2 PRE_first_tail_x6_r0_body.st24.S3 (runOk_trans PRE_first_tail_x6_r0_body.st24.F (PRE_first_tail_x6_r0_body.st24.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st24.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st24.ks 1).getD 0) PRE_first_tail_x6_r0_body.st24.s0 PRE_first_tail_x6_r0_body.st24.s1 PRE_first_tail_x6_r0_body.st24.s2 PRE_first_tail_x6_r0_body.st24.S0 PRE_first_tail_x6_r0_body.st24.S1 PRE_first_tail_x6_r0_body.st24.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st24.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st24.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st24.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st24.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st24.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st24.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st24.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st24.F (PRE_first_tail_x6_r0_body.st24.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st24.s0
  S0 := PRE_first_tail_x6_r0_body.st24.S0
  s1 := PRE_first_tail_x6_r0_body.st24.s4
  S1 := PRE_first_tail_x6_r0_body.st24.S4
  s2 := PRE_first_tail_x6_r0_body.st24.s5
  S2 := PRE_first_tail_x6_r0_body.st24.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st24.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st24.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st24.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st24.bodyHalt
  last := PRE_first_tail_x6_r0_body.st24.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st24.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC25
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 25 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s256` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa25` into the merged state
`PRE_first_tail_x6_r0_body.s255`. -/

def PRE_first_tail_x6_r0_body.pl25 : List Nat := []
def PRE_first_tail_x6_r0_body.nr25 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd25 : RData :=
  ⟨2694783, 2694785, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18704, 18704, 15792, 15792, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa25 : Map :=
  Conv.Map.compact 2694783 2694785 1148 PRE_first_tail_x6_r0_body.pl25 (PRE_first_tail_x6_r0_body.nr25.map NumV.ref) PRE_first_tail_x6_r0_body.kd25.big
    PRE_first_tail_x6_r0_body.kd25.region PRE_first_tail_x6_r0_body.kd25.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws25 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs25 : List SymE := PRE_first_tail_x6_r0_body.nr25.map fun r => (nth? PRE_first_tail_x6_r0_body.S255.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta25 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws25 PRE_first_tail_x6_r0_body.crs25
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB25 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab25 : PRE_first_tail_x6_r0_body.S256.tab = PRE_first_tail_x6_r0_body.S254.tab ++ PRE_first_tail_x6_r0_body.cws25.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace25 : PRE_first_tail_x6_r0_body.s256.trace = PRE_first_tail_x6_r0_body.s254.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext25 : PRE_first_tail_x6_r0_body.s256.next = 2694783
kernel_rfl PRE_first_tail_x6_r0_body.ccounters25 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx.nnext) = (18704, 15792)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue25 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s255.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa25.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp25 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx.tokens.all (bSN 1148) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean25 : Conv.cleanListB 18704 131072 (fun r => Nat.ble 74816 r) PRE_first_tail_x6_r0_body.s256
    (PRE_first_tail_x6_r0_body.wrB25 ++ (List.range 0).map (2694783 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs25 : bigsOutB 18704 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK25
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl25`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl25 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo25 : List Nat := []
def PRE_first_tail_x6_r0_body.cln25 : List Nat := []
def PRE_first_tail_x6_r0_body.cli25 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap25 : PRE_first_tail_x6_r0_body.s256.heap = Stage.setAll PRE_first_tail_x6_r0_body.s254.heap (PRE_first_tail_x6_r0_body.cl25.filterMap fun a => (PRE_first_tail_x6_r0_body.s256.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe25 : Nat.ble PRE_first_tail_x6_r0_body.s254.next PRE_first_tail_x6_r0_body.s256.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP25 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s254 PRE_first_tail_x6_r0_body.s256 PRE_first_tail_x6_r0_body.cl25 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp25 : Conv.suppListB PRE_first_tail_x6_r0_body.s256 1148 PRE_first_tail_x6_r0_body.cl25 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound25 : Conv.boundListB PRE_first_tail_x6_r0_body.s256 PRE_first_tail_x6_r0_body.cl25 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK25 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln25.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK25 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo25.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK25 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli25.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst25 : Conv.sstListB 1148 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx PRE_first_tail_x6_r0_body.cln25 PRE_first_tail_x6_r0_body.clo25 PRE_first_tail_x6_r0_body.cli25 = true

end Host.Load.Run.Tpl
end

section -- SiteCl25
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA25 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo25.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd25 : (PRE_first_tail_x6_r0_body.clo25 ++ PRE_first_tail_x6_r0_body.cln25 ++ PRE_first_tail_x6_r0_body.cli25).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle25 : Conv.Cnt.leB (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck25 : Conv.ncleanListB (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx PRE_first_tail_x6_r0_body.clo25 PRE_first_tail_x6_r0_body.cln25 PRE_first_tail_x6_r0_body.cli25 = true
theorem PRE_first_tail_x6_r0_body.cncl25 (h : Conv.NClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx) : Conv.NClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle25 PRE_first_tail_x6_r0_body.ckA25 PRE_first_tail_x6_r0_body.cobjsK25 PRE_first_tail_x6_r0_body.cnodesK25 PRE_first_tail_x6_r0_body.citemsK25 PRE_first_tail_x6_r0_body.cbd25 PRE_first_tail_x6_r0_body.cck25

end Host.Load.Run.Tpl
end

section -- SiteS25
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 25 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc25 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P25 : LoadP := PRE_first_tail_x6_r0_body.Pc25.raise 15792
kernel_rfl PRE_first_tail_x6_r0_body.craise25 : Nat.ble PRE_first_tail_x6_r0_body.Pc25.N0 15792 = true
theorem PRE_first_tail_x6_r0_body.raised25 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc25 PRE_first_tail_x6_r0_body.P25 :=
  .inr ⟨15792, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise25, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_25 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_25 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s255.ffi)
def PRE_first_tail_x6_r0_body.khinv25 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv25 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS25 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS25 : List Nat := List.range' 15792 0
def PRE_first_tail_x6_r0_body.ciS25 : List Nat := [] ++ List.range' 15792 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh025 : PRE_first_tail_x6_r0_body.kd25.nh0 = PRE_first_tail_x6_r0_body.cx0_25.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh125 : PRE_first_tail_x6_r0_body.kd25.nh1 = PRE_first_tail_x6_r0_body.cx1_25.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn025 : PRE_first_tail_x6_r0_body.kd25.nn0 = PRE_first_tail_x6_r0_body.cx0_25.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn125 : PRE_first_tail_x6_r0_body.kd25.nn1 = PRE_first_tail_x6_r0_body.cx1_25.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo25 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P25.lo && Nat.ble PRE_first_tail_x6_r0_body.P25.lo PRE_first_tail_x6_r0_body.cx0_25.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P25.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P25.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt25 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_25.mlx.next PRE_first_tail_x6_r0_body.cx1_25.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_25.mlx.nnext PRE_first_tail_x6_r0_body.cx1_25.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband25 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P25.NL && Nat.ble PRE_first_tail_x6_r0_body.P25.NL PRE_first_tail_x6_r0_body.P25.N0 && Nat.ble PRE_first_tail_x6_r0_body.P25.N0 PRE_first_tail_x6_r0_body.cx0_25.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow25 : PRE_first_tail_x6_r0_body.kd25.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren25 : checkRenG PRE_first_tail_x6_r0_body.kd25.hnd PRE_first_tail_x6_r0_body.khinv25 (phB PRE_first_tail_x6_r0_body.cx0_25.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband25 : PRE_first_tail_x6_r0_body.kd25.checkBand PRE_first_tail_x6_r0_body.P25.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos25 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd25.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren25 : checkRenG PRE_first_tail_x6_r0_body.kd25.node PRE_first_tail_x6_r0_body.kninv25 (pnB PRE_first_tail_x6_r0_body.cx0_25.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow25 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd25.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P25.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd25.nodeF j) PRE_first_tail_x6_r0_body.cx1_25.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a25 : PRE_first_tail_x6_r0_body.cx0_25.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b25 : PRE_first_tail_x6_r0_body.cx0_25.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok125 : PRE_first_tail_x6_r0_body.cx1_25.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend25 : PRE_first_tail_x6_r0_body.cx1_25.mlx.pending = PRE_first_tail_x6_r0_body.cx0_25.mlx.pending.map PRE_first_tail_x6_r0_body.kappa25.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh25 : PRE_first_tail_x6_r0_body.cx1_25.mlx.errh = PRE_first_tail_x6_r0_body.cx0_25.mlx.errh.map PRE_first_tail_x6_r0_body.kappa25.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles25 : PRE_first_tail_x6_r0_body.cx1_25.mlx.files = PRE_first_tail_x6_r0_body.cx0_25.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch25 : PRE_first_tail_x6_r0_body.cx1_25.mlx.arch = PRE_first_tail_x6_r0_body.cx0_25.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes25 : PRE_first_tail_x6_r0_body.cx1_25.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_25.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired25 : PRE_first_tail_x6_r0_body.cx1_25.mlx.wired = PRE_first_tail_x6_r0_body.cx0_25.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost25 : PRE_first_tail_x6_r0_body.cx1_25.host = PRE_first_tail_x6_r0_body.cx0_25.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd25`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn025 : PRE_first_tail_x6_r0_body.kd25.n0 = 2694783
kernel_rfl PRE_first_tail_x6_r0_body.ckn125 : PRE_first_tail_x6_r0_body.kd25.n1 = 2694785
kernel_rfl PRE_first_tail_x6_r0_body.ckheap25 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd25.heap).all (fun x => Nat.ble 2694783 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl25 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd25.heap.get (2694783 + j) = nth? PRE_first_tail_x6_r0_body.pl25 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja25 : Nat.ble 2694783 2694783 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn25 : Nat.ble 1148 1148 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD25 : Nat.ble 2694783 PRE_first_tail_x6_r0_body.kd25.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn25 : Nat.ble 18704 PRE_first_tail_x6_r0_body.kd25.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn25 : Nat.ble 15792 PRE_first_tail_x6_r0_body.kd25.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb25 : Nat.ble 18704 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap25 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd25.heap).all (Nat.ble (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd25 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd25.hnd).all (Nat.ble (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode25 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd25.node).all (Nat.ble (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix25 : Conv.FixOld (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa25 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja25) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn25) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD25) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn25) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn25) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb25) PRE_first_tail_x6_r0_body.fheap25 PRE_first_tail_x6_r0_body.fhnd25 PRE_first_tail_x6_r0_body.fnode25
kernel_rfl PRE_first_tail_x6_r0_body.fcxn25 : (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn25 : (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle025 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_25.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_25.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk25 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd25.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A25 : PRE_first_tail_x6_r0_body.cx1_25.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS25.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_25.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O25 : PRE_first_tail_x6_r0_body.cx1_25.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS25.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_25.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N25 : PRE_first_tail_x6_r0_body.cx1_25.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS25.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_25.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I25 : PRE_first_tail_x6_r0_body.cx1_25.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS25.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_25.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd25 : (PRE_first_tail_x6_r0_body.clo25 ++ PRE_first_tail_x6_r0_body.cln25 ++ PRE_first_tail_x6_r0_body.cli25 ++ PRE_first_tail_x6_r0_body.cwS25 ++ PRE_first_tail_x6_r0_body.cnS25 ++ PRE_first_tail_x6_r0_body.ciS25).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW25 : PRE_first_tail_x6_r0_body.cwS25.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo25.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI25 : PRE_first_tail_x6_r0_body.ciS25.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli25.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN25 : PRE_first_tail_x6_r0_body.cnS25.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF25 : PRE_first_tail_x6_r0_body.cln25.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh25 : PRE_first_tail_x6_r0_body.clo25.all (handleOK PRE_first_tail_x6_r0_body.kappa25 PRE_first_tail_x6_r0_body.P25.lo PRE_first_tail_x6_r0_body.cx0_25.mlx PRE_first_tail_x6_r0_body.cx1_25.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo25 : PRE_first_tail_x6_r0_body.clo25.map (fun h => PRE_first_tail_x6_r0_body.cx1_25.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa25.handle h)) = PRE_first_tail_x6_r0_body.clo25.map (fun h => (PRE_first_tail_x6_r0_body.cx0_25.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa25.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok25 : PRE_first_tail_x6_r0_body.clo25.all (objOK PRE_first_tail_x6_r0_body.kappa25 PRE_first_tail_x6_r0_body.P25.NL PRE_first_tail_x6_r0_body.cx0_25.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd25 : PRE_first_tail_x6_r0_body.cln25.all (nodeOKF PRE_first_tail_x6_r0_body.kappa25 PRE_first_tail_x6_r0_body.P25 PRE_first_tail_x6_r0_body.cx0_25.mlx PRE_first_tail_x6_r0_body.cx1_25.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp25 : ((PRE_first_tail_x6_r0_body.cln25.filter (fullB PRE_first_tail_x6_r0_body.P25))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_25.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa25.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln25.filter (fullB PRE_first_tail_x6_r0_body.P25))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_25.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa25.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI25 : incrB PRE_first_tail_x6_r0_body.kd25.nodeF (List.range' 15792 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK25 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd25.node).all (fun k => Nat.ble 15792 k && Nat.blt k 15792) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL25 : (PRE_first_tail_x6_r0_body.cln25.filter (Nat.ble PRE_first_tail_x6_r0_body.P25.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd25.nodeF i) && (Nat.blt i 15792 || Nat.ble PRE_first_tail_x6_r0_body.kd25.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord25 : (PRE_first_tail_x6_r0_body.cln25.filter (Nat.ble PRE_first_tail_x6_r0_body.P25.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd25.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd25.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd25.nodeF j) (PRE_first_tail_x6_r0_body.kd25.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow25 PRE_first_tail_x6_r0_body.cnn125 PRE_first_tail_x6_r0_body.fnordI25 PRE_first_tail_x6_r0_body.fnordK25 PRE_first_tail_x6_r0_body.fnordL25
kernel_rfl PRE_first_tail_x6_r0_body.fi25 : PRE_first_tail_x6_r0_body.cli25.all (pnB PRE_first_tail_x6_r0_body.cx0_25.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii25 : PRE_first_tail_x6_r0_body.cli25.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_25.mlx.items.get (PRE_first_tail_x6_r0_body.kappa25.node k) = (PRE_first_tail_x6_r0_body.cx0_25.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa25.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot25 (clean : Conv.NClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P25.NL) (cl : SSt (· < 1148) PRE_first_tail_x6_r0_body.cx0_25.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P25 1148 PRE_first_tail_x6_r0_body.kappa25 PRE_first_tail_x6_r0_body.kd25 PRE_first_tail_x6_r0_body.khinv25 PRE_first_tail_x6_r0_body.kninv25 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx PRE_first_tail_x6_r0_body.cx0_25.mlx PRE_first_tail_x6_r0_body.cx1_25.mlx (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo25 PRE_first_tail_x6_r0_body.cln25 PRE_first_tail_x6_r0_body.cli25 PRE_first_tail_x6_r0_body.cwS25 PRE_first_tail_x6_r0_body.cnS25 PRE_first_tail_x6_r0_body.ciS25 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh025, PRE_first_tail_x6_r0_body.cnh125, PRE_first_tail_x6_r0_body.cnn025, PRE_first_tail_x6_r0_body.cnn125, PRE_first_tail_x6_r0_body.cplo25, PRE_first_tail_x6_r0_body.ccnt25, PRE_first_tail_x6_r0_body.cnband25, PRE_first_tail_x6_r0_body.chbelow25, PRE_first_tail_x6_r0_body.chren25, PRE_first_tail_x6_r0_body.cband25, PRE_first_tail_x6_r0_body.cnh1pos25, PRE_first_tail_x6_r0_body.cnren25, PRE_first_tail_x6_r0_body.cnlow25, PRE_first_tail_x6_r0_body.cabs0a25, PRE_first_tail_x6_r0_body.cabs0b25, PRE_first_tail_x6_r0_body.ctok125, PRE_first_tail_x6_r0_body.cpend25, PRE_first_tail_x6_r0_body.cerrh25, PRE_first_tail_x6_r0_body.cfiles25, PRE_first_tail_x6_r0_body.carch25, PRE_first_tail_x6_r0_body.csizes25, PRE_first_tail_x6_r0_body.cwired25, PRE_first_tail_x6_r0_body.cfix25, clean, PRE_first_tail_x6_r0_body.fcxn25, PRE_first_tail_x6_r0_body.fcnn25, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle025, PRE_first_tail_x6_r0_body.fnk25, PRE_first_tail_x6_r0_body.ckA25, PRE_first_tail_x6_r0_body.cobjsK25, PRE_first_tail_x6_r0_body.cnodesK25, PRE_first_tail_x6_r0_body.citemsK25, PRE_first_tail_x6_r0_body.f1A25, PRE_first_tail_x6_r0_body.f1O25, PRE_first_tail_x6_r0_body.f1N25, PRE_first_tail_x6_r0_body.f1I25, PRE_first_tail_x6_r0_body.fbd25, PRE_first_tail_x6_r0_body.fincW25, PRE_first_tail_x6_r0_body.fincI25, PRE_first_tail_x6_r0_body.fincN25, PRE_first_tail_x6_r0_body.flnF25, PRE_first_tail_x6_r0_body.fh25, PRE_first_tail_x6_r0_body.fo25, PRE_first_tail_x6_r0_body.fok25, PRE_first_tail_x6_r0_body.fnd25, PRE_first_tail_x6_r0_body.fp25, PRE_first_tail_x6_r0_body.fnord25, PRE_first_tail_x6_r0_body.fi25, PRE_first_tail_x6_r0_body.fii25⟩
theorem PRE_first_tail_x6_r0_body.cnshift25 (clean : Conv.NClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P25.NL) (cl : SSt (· < 1148) PRE_first_tail_x6_r0_body.cx0_25.mlx) : NShift PRE_first_tail_x6_r0_body.P25 1148 PRE_first_tail_x6_r0_body.kappa25 PRE_first_tail_x6_r0_body.cx0_25 PRE_first_tail_x6_r0_body.cx1_25 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot25 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost25 (compact_a_eq PRE_first_tail_x6_r0_body.ckn025 PRE_first_tail_x6_r0_body.ckn125 PRE_first_tail_x6_r0_body.ckheap25 PRE_first_tail_x6_r0_body.ckpl25)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_25 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s254.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_25 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s254.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_25 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s254.ffi) = some PRE_first_tail_x6_r0_body.fxC_25
kernel_rfl PRE_first_tail_x6_r0_body.okrC_25 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s254.ffi) = some PRE_first_tail_x6_r0_body.krC_25
noncomputable def PRE_first_tail_x6_r0_body.fx0_25 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s256.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_25 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s256.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_25 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s256.ffi) = some PRE_first_tail_x6_r0_body.fx0_25
kernel_rfl PRE_first_tail_x6_r0_body.okr0_25 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s256.ffi) = some PRE_first_tail_x6_r0_body.kr0_25
noncomputable def PRE_first_tail_x6_r0_body.fx1_25 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s255.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_25 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s255.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_25 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s255.ffi) = some PRE_first_tail_x6_r0_body.fx1_25
kernel_rfl PRE_first_tail_x6_r0_body.okr1_25 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s255.ffi) = some PRE_first_tail_x6_r0_body.kr1_25
kernel_rfl PRE_first_tail_x6_r0_body.ff025 : PRE_first_tail_x6_r0_body.fx0_25 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_25 (PRE_first_tail_x6_r0_body.clo25.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_25.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff125 : PRE_first_tail_x6_r0_body.fx1_25 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_25 (PRE_first_tail_x6_r0_body.cwS25.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_25.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck25 : freedLB PRE_first_tail_x6_r0_body.kappa25 PRE_first_tail_x6_r0_body.cx0_25.mlx PRE_first_tail_x6_r0_body.fx0_25 PRE_first_tail_x6_r0_body.fx1_25 PRE_first_tail_x6_r0_body.clo25 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf025 : PRE_first_tail_x6_r0_body.kr0_25.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_25.flags (PRE_first_tail_x6_r0_body.clo25.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_25.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt025 : PRE_first_tail_x6_r0_body.kr0_25.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_25.targs (PRE_first_tail_x6_r0_body.clo25.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_25.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf125 : PRE_first_tail_x6_r0_body.kr1_25.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_25.flags (PRE_first_tail_x6_r0_body.cwS25.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_25.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt125 : PRE_first_tail_x6_r0_body.kr1_25.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_25.targs (PRE_first_tail_x6_r0_body.cwS25.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_25.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck25 : krecLB PRE_first_tail_x6_r0_body.kappa25 1148 PRE_first_tail_x6_r0_body.cx0_25.mlx PRE_first_tail_x6_r0_body.kr0_25 PRE_first_tail_x6_r0_body.kr1_25 PRE_first_tail_x6_r0_body.clo25 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn25 : Nat.ble 1148 1148 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge25 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s255.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s256.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR25 : pendRegB PRE_first_tail_x6_r0_body.kappa25 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe25 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s255.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift25 (clean : Conv.NClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P25.NL) (cl : SSt (· < 1148) PRE_first_tail_x6_r0_body.cx0_25.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_25.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_25.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_25.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_25.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P25 1148 PRE_first_tail_x6_r0_body.kappa25 PRE_first_tail_x6_r0_body.s256.ffi PRE_first_tail_x6_r0_body.s255.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift25 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue25, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp25 t ht),
    PRE_first_tail_x6_r0_body.cbridge25,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s256.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s255.ffi) (PRE_first_tail_x6_r0_body.cfoot25 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_25 PRE_first_tail_x6_r0_body.ofx1_25 hobjC PRE_first_tail_x6_r0_body.ff025 PRE_first_tail_x6_r0_body.ff125 PRE_first_tail_x6_r0_body.ffck25,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s256.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s255.ffi) (PRE_first_tail_x6_r0_body.cfoot25 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_25 PRE_first_tail_x6_r0_body.okr1_25 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn25) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf025 PRE_first_tail_x6_r0_body.fkt025 PRE_first_tail_x6_r0_body.fkf125 PRE_first_tail_x6_r0_body.fkt125 PRE_first_tail_x6_r0_body.fkck25,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh025 PRE_first_tail_x6_r0_body.cnh125 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe25) PRE_first_tail_x6_r0_body.cpendR25⟩

end Host.Load.Run.Tpl
end

section -- st25/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st25 0
host_stream_state PRE_first_tail_x6_r0_body.st25 1
host_stream_state PRE_first_tail_x6_r0_body.st25 2
end Host.Load.Run.Tpl
end

section -- Site25
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 25 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g25__g26` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s254`, the merged state `PRE_first_tail_x6_r0_body.s255`,
the site template `PRE_first_tail_x6_r0_body.st25` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s256`: the merge.
The footprint's facts are in `SiteF25`, the compaction's in `SiteC25`, `SiteK25`, `SiteNa25`, `SiteNb25`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso25 : PRE_first_tail_x6_r0_body.st25.s0 = { PRE_first_tail_x6_r0_body.s254 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs25 : List Frame := PRE_first_tail_x6_r0_body.s254.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_25 : PRE_first_tail_x6_r0_body.S254.tab.length = 1148
kernel_rfl PRE_first_tail_x6_r0_body.tab0_25 : PRE_first_tail_x6_r0_body.st25.S0.tab = PRE_first_tail_x6_r0_body.S254.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws25 : List Nat := [1441, 1442]
kernel_rfl PRE_first_tail_x6_r0_body.fresh25 : (PRE_first_tail_x6_r0_body.S254.tab.all fun e => PRE_first_tail_x6_r0_body.ws25.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S254.oracle.all fun q => PRE_first_tail_x6_r0_body.ws25.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab25 : PRE_first_tail_x6_r0_body.S255.tab = PRE_first_tail_x6_r0_body.S254.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws25
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen25 : PRE_first_tail_x6_r0_body.st25.S2.tab.length - PRE_first_tail_x6_r0_body.st25.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged25`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap25 : PRE_first_tail_x6_r0_body.s255.heap = PRE_first_tail_x6_r0_body.st25.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext25 : PRE_first_tail_x6_r0_body.s255.next = PRE_first_tail_x6_r0_body.st25.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl25 : PRE_first_tail_x6_r0_body.s255.ctl = PRE_first_tail_x6_r0_body.st25.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack25 : PRE_first_tail_x6_r0_body.s255.stack = PRE_first_tail_x6_r0_body.st25.s2.stack ++ PRE_first_tail_x6_r0_body.s254.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs25 : PRE_first_tail_x6_r0_body.s255.jobs = PRE_first_tail_x6_r0_body.st25.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi25 : PRE_first_tail_x6_r0_body.s255.ffi = PRE_first_tail_x6_r0_body.st25.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace25 : PRE_first_tail_x6_r0_body.s255.trace = PRE_first_tail_x6_r0_body.st25.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores25 : PRE_first_tail_x6_r0_body.s255.stores = PRE_first_tail_x6_r0_body.st25.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD25
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 25 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived25 : PRE_first_tail_x6_r0_body.nr25.map (fun r => nth? PRE_first_tail_x6_r0_body.st25.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo25 : PRE_first_tail_x6_r0_body.nr25.all (Nat.ble 1148) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj25 : PRE_first_tail_x6_r0_body.cws25.all (fun c => !PRE_first_tail_x6_r0_body.ws25.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ25 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws25 PRE_first_tail_x6_r0_body.crs25 PRE_first_tail_x6_r0_body.ws25

end Host.Load.Run.Tpl
end

section -- st25/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st25`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st25.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st25.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st25.s2.heap PRE_first_tail_x6_r0_body.st25.wrR ++ freshOf PRE_first_tail_x6_r0_body.st25.s2.heap PRE_first_tail_x6_r0_body.st25.s0.next PRE_first_tail_x6_r0_body.st25.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st25.wr : List Nat := PRE_first_tail_x6_r0_body.st25.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st25.heapFoot : PRE_first_tail_x6_r0_body.st25.s2.heap = setAll PRE_first_tail_x6_r0_body.st25.s0.heap PRE_first_tail_x6_r0_body.st25.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st25.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st25.s0.next PRE_first_tail_x6_r0_body.st25.s2.next = true
theorem PRE_first_tail_x6_r0_body.st25.grows : PRE_first_tail_x6_r0_body.st25.s0.next ≤ PRE_first_tail_x6_r0_body.st25.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st25.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st25.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st25.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st25.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st25.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st25.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st25.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st25.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st25.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st25.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st25.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st25.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF25
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 25 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB25 : nodupT PRE_first_tail_x6_r0_body.st25.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup25 : PRE_first_tail_x6_r0_body.st25.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB25).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB25 : PRE_first_tail_x6_r0_body.st25.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound25 : ∀ b ∈ PRE_first_tail_x6_r0_body.st25.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB25 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr25 := PRE_first_tail_x6_r0_body.st25.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq25 : PRE_first_tail_x6_r0_body.st25.s2.trace = PRE_first_tail_x6_r0_body.trFr25 ++ PRE_first_tail_x6_r0_body.st25.s0.trace
theorem PRE_first_tail_x6_r0_body.trace25 : ∃ fr, PRE_first_tail_x6_r0_body.st25.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st25.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq25⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide25 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB25 : (PRE_first_tail_x6_r0_body.wide25.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st25.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix25 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide25, WFix Map.id (Present PRE_first_tail_x6_r0_body.st25.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB25 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL25
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 25 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s255`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO25 : PRE_first_tail_x6_r0_body.st25.S0.oracle = PRE_first_tail_x6_r0_body.st25.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B25 : PRE_first_tail_x6_r0_body.st25.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st25.s0.next || (PRE_first_tail_x6_r0_body.st25.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot25 : Conv.StageFoot PRE_first_tail_x6_r0_body.st25.wr PRE_first_tail_x6_r0_body.st25.s0 PRE_first_tail_x6_r0_body.st25.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st25.heapFoot PRE_first_tail_x6_r0_body.wrNodup25 PRE_first_tail_x6_r0_body.wrBound25 PRE_first_tail_x6_r0_body.wr0B25 PRE_first_tail_x6_r0_body.st25.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged25 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st25.F.S → PRE_first_tail_x6_r0_body.st25.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st25.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st25.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs25 PRE_first_tail_x6_r0_body.st25.wr PRE_first_tail_x6_r0_body.s254 PRE_first_tail_x6_r0_body.st25.s2 PRE_first_tail_x6_r0_body.st25.s0
      PRE_first_tail_x6_r0_body.st25.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st25.F FR W stk M ν K PRE_first_tail_x6_r0_body.s255 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso25 PRE_first_tail_x6_r0_body.stFoot25 PRE_first_tail_x6_r0_body.wrNodup25 PRE_first_tail_x6_r0_body.wrBound25 PRE_first_tail_x6_r0_body.trace25 PRE_first_tail_x6_r0_body.mheap25
    PRE_first_tail_x6_r0_body.mnext25 PRE_first_tail_x6_r0_body.mctl25 PRE_first_tail_x6_r0_body.mstack25 PRE_first_tail_x6_r0_body.mjobs25 PRE_first_tail_x6_r0_body.mffi25 PRE_first_tail_x6_r0_body.mtrace25 PRE_first_tail_x6_r0_body.mstores25 h

def PRE_first_tail_x6_r0_body.arrEl25_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE25_2665 : arrOf PRE_first_tail_x6_r0_body.s255 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl25_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA25_2665 : isArrB PRE_first_tail_x6_r0_body.s255 2665 = true
theorem PRE_first_tail_x6_r0_body.arr25_2665 : ∃ o, PRE_first_tail_x6_r0_body.s255.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl25_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE25_2665 PRE_first_tail_x6_r0_body.arrA25_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN25_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl25_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR25_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl25_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN25_2665

def PRE_first_tail_x6_r0_body.arrEl25_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE25_2673467 : arrOf PRE_first_tail_x6_r0_body.s255 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl25_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA25_2673467 : isArrB PRE_first_tail_x6_r0_body.s255 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr25_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s255.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl25_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE25_2673467 PRE_first_tail_x6_r0_body.arrA25_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN25_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl25_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR25_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl25_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN25_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k25 : isArrB PRE_first_tail_x6_r0_body.s255 4910 = false
theorem PRE_first_tail_x6_r0_body.keep25 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s255 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k25 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr25_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl25_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ25
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 25 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s254`, the merged
state `PRE_first_tail_x6_r0_body.s255`, the canonical state `PRE_first_tail_x6_r0_body.s256`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl25 : PRE_first_tail_x6_r0_body.pl25.all (Nat.ble PRE_first_tail_x6_r0_body.s254.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd25 : nodupT PRE_first_tail_x6_r0_body.pl25 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn125 : Nat.ble PRE_first_tail_x6_r0_body.s254.next 2694785 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst25 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s254.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn25 : PRE_first_tail_x6_r0_body.s256.next = PRE_first_tail_x6_r0_body.s254.next + PRE_first_tail_x6_r0_body.pl25.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn25 : PRE_first_tail_x6_r0_body.s255.next = 2694785
kernel_rfl PRE_first_tail_x6_r0_body.zgrow25 : Nat.ble PRE_first_tail_x6_r0_body.s256.next PRE_first_tail_x6_r0_body.s255.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh25 : PRE_first_tail_x6_r0_body.S254.tab.all (fun e => PRE_first_tail_x6_r0_body.cws25.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd25 : nodupT PRE_first_tail_x6_r0_body.cws25 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi25 : PRE_first_tail_x6_r0_body.nr25.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S255.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt25 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s254.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg25_2665 : PRE_first_tail_x6_r0_body.s256.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s256 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk25_2665 : (objOf PRE_first_tail_x6_r0_body.s256 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm25_2665 : PRE_first_tail_x6_r0_body.s255.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa25.obj (objOf PRE_first_tail_x6_r0_body.s256 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s255 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg25_2673467 : PRE_first_tail_x6_r0_body.s256.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s256 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk25_2673467 : (objOf PRE_first_tail_x6_r0_body.s256 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm25_2673467 : PRE_first_tail_x6_r0_body.s255.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa25.obj (objOf PRE_first_tail_x6_r0_body.s256 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s255 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw25_4910 : (PRE_first_tail_x6_r0_body.s256.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw25_2673472 : (PRE_first_tail_x6_r0_body.s256.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw25_2673473 : (PRE_first_tail_x6_r0_body.s256.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd25 : PRE_first_tail_x6_r0_body.cl25.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr25 : PRE_first_tail_x6_r0_body.st25.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s254.next || PRE_first_tail_x6_r0_body.cl25.contains b) = true
def PRE_first_tail_x6_r0_body.zl25 : List Nat := PRE_first_tail_x6_r0_body.cl25.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE25 : PRE_first_tail_x6_r0_body.zl25.map (fun a => PRE_first_tail_x6_r0_body.s255.heap.get (PRE_first_tail_x6_r0_body.kappa25.a a)) = PRE_first_tail_x6_r0_body.zl25.map (fun a => (PRE_first_tail_x6_r0_body.s256.heap.get a).map PRE_first_tail_x6_r0_body.kappa25.hobj)
theorem PRE_first_tail_x6_r0_body.zimg25 : HeapImg PRE_first_tail_x6_r0_body.kappa25 PRE_first_tail_x6_r0_body.s256 PRE_first_tail_x6_r0_body.s255 PRE_first_tail_x6_r0_body.zl25 := PRE_first_tail_x6_r0_body.zimgE25
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl25 : PRE_first_tail_x6_r0_body.s255.ctl = PRE_first_tail_x6_r0_body.kappa25.ctl PRE_first_tail_x6_r0_body.s256.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack25 : PRE_first_tail_x6_r0_body.s255.stack = PRE_first_tail_x6_r0_body.s256.stack.map PRE_first_tail_x6_r0_body.kappa25.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs25 : PRE_first_tail_x6_r0_body.s255.jobs = PRE_first_tail_x6_r0_body.s256.jobs.map PRE_first_tail_x6_r0_body.kappa25.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores25 : PRE_first_tail_x6_r0_body.s255.stores = PRE_first_tail_x6_r0_body.kappa25.stores PRE_first_tail_x6_r0_body.s256.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots25 : checkRootsSupp PRE_first_tail_x6_r0_body.s256 1148 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC25 : PRE_first_tail_x6_r0_body.S254.tab.length + PRE_first_tail_x6_r0_body.cws25.length = 1148
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap25 : PRE_first_tail_x6_r0_body.kappa25 = Conv.Map.compact PRE_first_tail_x6_r0_body.s254.next 2694785 PRE_first_tail_x6_r0_body.S254.tab.length PRE_first_tail_x6_r0_body.pl25 (PRE_first_tail_x6_r0_body.nr25.map NumV.ref) PRE_first_tail_x6_r0_body.kd25.big
  PRE_first_tail_x6_r0_body.kd25.region PRE_first_tail_x6_r0_body.kd25.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin25 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s256.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc25 : Conv.jcleanListB (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s256 PRE_first_tail_x6_r0_body.cl25 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB25 : noBigRootsP (fun i => !Conv.oldBigB (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s256.trace PRE_first_tail_x6_r0_body.s256 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm25 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15792 = true
theorem PRE_first_tail_x6_r0_body.cjcl25 (h : Conv.JClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s254) : Conv.JClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s256 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle25)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap25 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd25 a ha)) PRE_first_tail_x6_r0_body.zjc25

end Host.Load.Run.Tpl
end

section -- st25/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st25.bodyLast from PRE_first_tail_x6_r0_body.st25.s1 to PRE_first_tail_x6_r0_body.st25.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st25.F PRE_first_tail_x6_r0_body.st25.s1).run PRE_first_tail_x6_r0_body.st25.S1 = some (PRE_first_tail_x6_r0_body.st25.s2, PRE_first_tail_x6_r0_body.st25.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st25.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st25.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st25.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st25.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st25/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st25.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st25.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st25.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st25.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st25.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st25.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st25.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st25.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st25.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st25.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st25.s0 PRE_first_tail_x6_r0_body.st25.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st25.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st25.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st25.s1 PRE_first_tail_x6_r0_body.st25.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st25/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st25.bodyK0F from PRE_first_tail_x6_r0_body.st25.s0 to PRE_first_tail_x6_r0_body.st25.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st25.F (PRE_first_tail_x6_r0_body.st25.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st25.ks 0).getD 0) PRE_first_tail_x6_r0_body.st25.s0 PRE_first_tail_x6_r0_body.st25.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st25.s1, PRE_first_tail_x6_r0_body.st25.S1)
theorem PRE_first_tail_x6_r0_body.st25.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st25.F (PRE_first_tail_x6_r0_body.st25.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st25.ks 0).getD 0) PRE_first_tail_x6_r0_body.st25.s0 PRE_first_tail_x6_r0_body.st25.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st25.s1, PRE_first_tail_x6_r0_body.st25.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st25.bodyOkLN_ok PRE_first_tail_x6_r0_body.st25.bodyK0F
end Host.Load.Run.Tpl
end

section -- st25/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st25.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st25.F (PRE_first_tail_x6_r0_body.st25.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st25.s0 PRE_first_tail_x6_r0_body.st25.S0 = some (PRE_first_tail_x6_r0_body.st25.s1, PRE_first_tail_x6_r0_body.st25.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st25.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st25.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st25.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st25.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st25.F (PRE_first_tail_x6_r0_body.st25.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st25.s0
  S0 := PRE_first_tail_x6_r0_body.st25.S0
  s1 := PRE_first_tail_x6_r0_body.st25.s1
  S1 := PRE_first_tail_x6_r0_body.st25.S1
  s2 := PRE_first_tail_x6_r0_body.st25.s2
  S2 := PRE_first_tail_x6_r0_body.st25.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st25.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st25.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st25.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st25.bodyHalt
  last := PRE_first_tail_x6_r0_body.st25.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st25.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC26
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 26 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s260` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa26` into the merged state
`PRE_first_tail_x6_r0_body.s259`. -/

def PRE_first_tail_x6_r0_body.pl26 : List Nat := [2695081]
def PRE_first_tail_x6_r0_body.nr26 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd26 : RData :=
  ⟨2695072, 2695082, Stage.setAll PTrie.nil [(2695071, 2695081)], Stage.setAll PTrie.nil [],
   18711, 18711, 15796, 15796, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa26 : Map :=
  Conv.Map.compact 2695071 2695082 1165 PRE_first_tail_x6_r0_body.pl26 (PRE_first_tail_x6_r0_body.nr26.map NumV.ref) PRE_first_tail_x6_r0_body.kd26.big
    PRE_first_tail_x6_r0_body.kd26.region PRE_first_tail_x6_r0_body.kd26.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws26 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs26 : List SymE := PRE_first_tail_x6_r0_body.nr26.map fun r => (nth? PRE_first_tail_x6_r0_body.S259.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta26 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws26 PRE_first_tail_x6_r0_body.crs26
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB26 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab26 : PRE_first_tail_x6_r0_body.S260.tab = PRE_first_tail_x6_r0_body.S258.tab ++ PRE_first_tail_x6_r0_body.cws26.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace26 : PRE_first_tail_x6_r0_body.s260.trace = PRE_first_tail_x6_r0_body.s258.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext26 : PRE_first_tail_x6_r0_body.s260.next = 2695072
kernel_rfl PRE_first_tail_x6_r0_body.ccounters26 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx.nnext) = (18711, 15796)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue26 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s259.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa26.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp26 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx.tokens.all (bSN 1165) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean26 : Conv.cleanListB 18711 131072 (fun r => Nat.ble 74844 r) PRE_first_tail_x6_r0_body.s260
    (PRE_first_tail_x6_r0_body.wrB26 ++ (List.range 1).map (2695071 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs26 : bigsOutB 18711 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK26
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl26`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl26 : List Nat := [2665, 2673467, 2695071]
def PRE_first_tail_x6_r0_body.clo26 : List Nat := []
def PRE_first_tail_x6_r0_body.cln26 : List Nat := []
def PRE_first_tail_x6_r0_body.cli26 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap26 : PRE_first_tail_x6_r0_body.s260.heap = Stage.setAll PRE_first_tail_x6_r0_body.s258.heap (PRE_first_tail_x6_r0_body.cl26.filterMap fun a => (PRE_first_tail_x6_r0_body.s260.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe26 : Nat.ble PRE_first_tail_x6_r0_body.s258.next PRE_first_tail_x6_r0_body.s260.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP26 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s258 PRE_first_tail_x6_r0_body.s260 PRE_first_tail_x6_r0_body.cl26 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp26 : Conv.suppListB PRE_first_tail_x6_r0_body.s260 1165 PRE_first_tail_x6_r0_body.cl26 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound26 : Conv.boundListB PRE_first_tail_x6_r0_body.s260 PRE_first_tail_x6_r0_body.cl26 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK26 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln26.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK26 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo26.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK26 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli26.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst26 : Conv.sstListB 1165 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx PRE_first_tail_x6_r0_body.cln26 PRE_first_tail_x6_r0_body.clo26 PRE_first_tail_x6_r0_body.cli26 = true

end Host.Load.Run.Tpl
end

section -- SiteCl26
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA26 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo26.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd26 : (PRE_first_tail_x6_r0_body.clo26 ++ PRE_first_tail_x6_r0_body.cln26 ++ PRE_first_tail_x6_r0_body.cli26).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle26 : Conv.Cnt.leB (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) (⟨18711, 15796, 2695072, 1165⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck26 : Conv.ncleanListB (⟨18711, 15796, 2695072, 1165⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx PRE_first_tail_x6_r0_body.clo26 PRE_first_tail_x6_r0_body.cln26 PRE_first_tail_x6_r0_body.cli26 = true
theorem PRE_first_tail_x6_r0_body.cncl26 (h : Conv.NClean (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx) : Conv.NClean (⟨18711, 15796, 2695072, 1165⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle26 PRE_first_tail_x6_r0_body.ckA26 PRE_first_tail_x6_r0_body.cobjsK26 PRE_first_tail_x6_r0_body.cnodesK26 PRE_first_tail_x6_r0_body.citemsK26 PRE_first_tail_x6_r0_body.cbd26 PRE_first_tail_x6_r0_body.cck26

end Host.Load.Run.Tpl
end

section -- SiteS26
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 26 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc26 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P26 : LoadP := PRE_first_tail_x6_r0_body.Pc26.raise 15796
kernel_rfl PRE_first_tail_x6_r0_body.craise26 : Nat.ble PRE_first_tail_x6_r0_body.Pc26.N0 15796 = true
theorem PRE_first_tail_x6_r0_body.raised26 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc26 PRE_first_tail_x6_r0_body.P26 :=
  .inr ⟨15796, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise26, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_26 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_26 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s259.ffi)
def PRE_first_tail_x6_r0_body.khinv26 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv26 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS26 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS26 : List Nat := List.range' 15796 0
def PRE_first_tail_x6_r0_body.ciS26 : List Nat := [] ++ List.range' 15796 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh026 : PRE_first_tail_x6_r0_body.kd26.nh0 = PRE_first_tail_x6_r0_body.cx0_26.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh126 : PRE_first_tail_x6_r0_body.kd26.nh1 = PRE_first_tail_x6_r0_body.cx1_26.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn026 : PRE_first_tail_x6_r0_body.kd26.nn0 = PRE_first_tail_x6_r0_body.cx0_26.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn126 : PRE_first_tail_x6_r0_body.kd26.nn1 = PRE_first_tail_x6_r0_body.cx1_26.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo26 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P26.lo && Nat.ble PRE_first_tail_x6_r0_body.P26.lo PRE_first_tail_x6_r0_body.cx0_26.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P26.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P26.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt26 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_26.mlx.next PRE_first_tail_x6_r0_body.cx1_26.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_26.mlx.nnext PRE_first_tail_x6_r0_body.cx1_26.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband26 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P26.NL && Nat.ble PRE_first_tail_x6_r0_body.P26.NL PRE_first_tail_x6_r0_body.P26.N0 && Nat.ble PRE_first_tail_x6_r0_body.P26.N0 PRE_first_tail_x6_r0_body.cx0_26.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow26 : PRE_first_tail_x6_r0_body.kd26.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren26 : checkRenG PRE_first_tail_x6_r0_body.kd26.hnd PRE_first_tail_x6_r0_body.khinv26 (phB PRE_first_tail_x6_r0_body.cx0_26.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband26 : PRE_first_tail_x6_r0_body.kd26.checkBand PRE_first_tail_x6_r0_body.P26.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos26 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd26.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren26 : checkRenG PRE_first_tail_x6_r0_body.kd26.node PRE_first_tail_x6_r0_body.kninv26 (pnB PRE_first_tail_x6_r0_body.cx0_26.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow26 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd26.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P26.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd26.nodeF j) PRE_first_tail_x6_r0_body.cx1_26.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a26 : PRE_first_tail_x6_r0_body.cx0_26.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b26 : PRE_first_tail_x6_r0_body.cx0_26.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok126 : PRE_first_tail_x6_r0_body.cx1_26.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend26 : PRE_first_tail_x6_r0_body.cx1_26.mlx.pending = PRE_first_tail_x6_r0_body.cx0_26.mlx.pending.map PRE_first_tail_x6_r0_body.kappa26.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh26 : PRE_first_tail_x6_r0_body.cx1_26.mlx.errh = PRE_first_tail_x6_r0_body.cx0_26.mlx.errh.map PRE_first_tail_x6_r0_body.kappa26.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles26 : PRE_first_tail_x6_r0_body.cx1_26.mlx.files = PRE_first_tail_x6_r0_body.cx0_26.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch26 : PRE_first_tail_x6_r0_body.cx1_26.mlx.arch = PRE_first_tail_x6_r0_body.cx0_26.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes26 : PRE_first_tail_x6_r0_body.cx1_26.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_26.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired26 : PRE_first_tail_x6_r0_body.cx1_26.mlx.wired = PRE_first_tail_x6_r0_body.cx0_26.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost26 : PRE_first_tail_x6_r0_body.cx1_26.host = PRE_first_tail_x6_r0_body.cx0_26.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd26`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn026 : PRE_first_tail_x6_r0_body.kd26.n0 = 2695072
kernel_rfl PRE_first_tail_x6_r0_body.ckn126 : PRE_first_tail_x6_r0_body.kd26.n1 = 2695082
kernel_rfl PRE_first_tail_x6_r0_body.ckheap26 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd26.heap).all (fun x => Nat.ble 2695071 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl26 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd26.heap.get (2695071 + j) = nth? PRE_first_tail_x6_r0_body.pl26 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja26 : Nat.ble 2695071 2695071 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn26 : Nat.ble 1165 1165 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD26 : Nat.ble 2695071 PRE_first_tail_x6_r0_body.kd26.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn26 : Nat.ble 18711 PRE_first_tail_x6_r0_body.kd26.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn26 : Nat.ble 15796 PRE_first_tail_x6_r0_body.kd26.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb26 : Nat.ble 18711 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap26 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd26.heap).all (Nat.ble (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd26 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd26.hnd).all (Nat.ble (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode26 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd26.node).all (Nat.ble (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix26 : Conv.FixOld (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa26 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja26) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn26) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD26) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn26) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn26) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb26) PRE_first_tail_x6_r0_body.fheap26 PRE_first_tail_x6_r0_body.fhnd26 PRE_first_tail_x6_r0_body.fnode26
kernel_rfl PRE_first_tail_x6_r0_body.fcxn26 : (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn26 : (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle026 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_26.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_26.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk26 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd26.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A26 : PRE_first_tail_x6_r0_body.cx1_26.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS26.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_26.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O26 : PRE_first_tail_x6_r0_body.cx1_26.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS26.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_26.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N26 : PRE_first_tail_x6_r0_body.cx1_26.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS26.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_26.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I26 : PRE_first_tail_x6_r0_body.cx1_26.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS26.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_26.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd26 : (PRE_first_tail_x6_r0_body.clo26 ++ PRE_first_tail_x6_r0_body.cln26 ++ PRE_first_tail_x6_r0_body.cli26 ++ PRE_first_tail_x6_r0_body.cwS26 ++ PRE_first_tail_x6_r0_body.cnS26 ++ PRE_first_tail_x6_r0_body.ciS26).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW26 : PRE_first_tail_x6_r0_body.cwS26.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo26.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI26 : PRE_first_tail_x6_r0_body.ciS26.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli26.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN26 : PRE_first_tail_x6_r0_body.cnS26.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF26 : PRE_first_tail_x6_r0_body.cln26.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh26 : PRE_first_tail_x6_r0_body.clo26.all (handleOK PRE_first_tail_x6_r0_body.kappa26 PRE_first_tail_x6_r0_body.P26.lo PRE_first_tail_x6_r0_body.cx0_26.mlx PRE_first_tail_x6_r0_body.cx1_26.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo26 : PRE_first_tail_x6_r0_body.clo26.map (fun h => PRE_first_tail_x6_r0_body.cx1_26.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa26.handle h)) = PRE_first_tail_x6_r0_body.clo26.map (fun h => (PRE_first_tail_x6_r0_body.cx0_26.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa26.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok26 : PRE_first_tail_x6_r0_body.clo26.all (objOK PRE_first_tail_x6_r0_body.kappa26 PRE_first_tail_x6_r0_body.P26.NL PRE_first_tail_x6_r0_body.cx0_26.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd26 : PRE_first_tail_x6_r0_body.cln26.all (nodeOKF PRE_first_tail_x6_r0_body.kappa26 PRE_first_tail_x6_r0_body.P26 PRE_first_tail_x6_r0_body.cx0_26.mlx PRE_first_tail_x6_r0_body.cx1_26.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp26 : ((PRE_first_tail_x6_r0_body.cln26.filter (fullB PRE_first_tail_x6_r0_body.P26))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_26.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa26.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln26.filter (fullB PRE_first_tail_x6_r0_body.P26))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_26.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa26.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI26 : incrB PRE_first_tail_x6_r0_body.kd26.nodeF (List.range' 15796 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK26 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd26.node).all (fun k => Nat.ble 15796 k && Nat.blt k 15796) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL26 : (PRE_first_tail_x6_r0_body.cln26.filter (Nat.ble PRE_first_tail_x6_r0_body.P26.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd26.nodeF i) && (Nat.blt i 15796 || Nat.ble PRE_first_tail_x6_r0_body.kd26.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord26 : (PRE_first_tail_x6_r0_body.cln26.filter (Nat.ble PRE_first_tail_x6_r0_body.P26.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd26.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd26.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd26.nodeF j) (PRE_first_tail_x6_r0_body.kd26.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow26 PRE_first_tail_x6_r0_body.cnn126 PRE_first_tail_x6_r0_body.fnordI26 PRE_first_tail_x6_r0_body.fnordK26 PRE_first_tail_x6_r0_body.fnordL26
kernel_rfl PRE_first_tail_x6_r0_body.fi26 : PRE_first_tail_x6_r0_body.cli26.all (pnB PRE_first_tail_x6_r0_body.cx0_26.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii26 : PRE_first_tail_x6_r0_body.cli26.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_26.mlx.items.get (PRE_first_tail_x6_r0_body.kappa26.node k) = (PRE_first_tail_x6_r0_body.cx0_26.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa26.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot26 (clean : Conv.NClean (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P26.NL) (cl : SSt (· < 1165) PRE_first_tail_x6_r0_body.cx0_26.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P26 1165 PRE_first_tail_x6_r0_body.kappa26 PRE_first_tail_x6_r0_body.kd26 PRE_first_tail_x6_r0_body.khinv26 PRE_first_tail_x6_r0_body.kninv26 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx PRE_first_tail_x6_r0_body.cx0_26.mlx PRE_first_tail_x6_r0_body.cx1_26.mlx (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo26 PRE_first_tail_x6_r0_body.cln26 PRE_first_tail_x6_r0_body.cli26 PRE_first_tail_x6_r0_body.cwS26 PRE_first_tail_x6_r0_body.cnS26 PRE_first_tail_x6_r0_body.ciS26 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh026, PRE_first_tail_x6_r0_body.cnh126, PRE_first_tail_x6_r0_body.cnn026, PRE_first_tail_x6_r0_body.cnn126, PRE_first_tail_x6_r0_body.cplo26, PRE_first_tail_x6_r0_body.ccnt26, PRE_first_tail_x6_r0_body.cnband26, PRE_first_tail_x6_r0_body.chbelow26, PRE_first_tail_x6_r0_body.chren26, PRE_first_tail_x6_r0_body.cband26, PRE_first_tail_x6_r0_body.cnh1pos26, PRE_first_tail_x6_r0_body.cnren26, PRE_first_tail_x6_r0_body.cnlow26, PRE_first_tail_x6_r0_body.cabs0a26, PRE_first_tail_x6_r0_body.cabs0b26, PRE_first_tail_x6_r0_body.ctok126, PRE_first_tail_x6_r0_body.cpend26, PRE_first_tail_x6_r0_body.cerrh26, PRE_first_tail_x6_r0_body.cfiles26, PRE_first_tail_x6_r0_body.carch26, PRE_first_tail_x6_r0_body.csizes26, PRE_first_tail_x6_r0_body.cwired26, PRE_first_tail_x6_r0_body.cfix26, clean, PRE_first_tail_x6_r0_body.fcxn26, PRE_first_tail_x6_r0_body.fcnn26, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle026, PRE_first_tail_x6_r0_body.fnk26, PRE_first_tail_x6_r0_body.ckA26, PRE_first_tail_x6_r0_body.cobjsK26, PRE_first_tail_x6_r0_body.cnodesK26, PRE_first_tail_x6_r0_body.citemsK26, PRE_first_tail_x6_r0_body.f1A26, PRE_first_tail_x6_r0_body.f1O26, PRE_first_tail_x6_r0_body.f1N26, PRE_first_tail_x6_r0_body.f1I26, PRE_first_tail_x6_r0_body.fbd26, PRE_first_tail_x6_r0_body.fincW26, PRE_first_tail_x6_r0_body.fincI26, PRE_first_tail_x6_r0_body.fincN26, PRE_first_tail_x6_r0_body.flnF26, PRE_first_tail_x6_r0_body.fh26, PRE_first_tail_x6_r0_body.fo26, PRE_first_tail_x6_r0_body.fok26, PRE_first_tail_x6_r0_body.fnd26, PRE_first_tail_x6_r0_body.fp26, PRE_first_tail_x6_r0_body.fnord26, PRE_first_tail_x6_r0_body.fi26, PRE_first_tail_x6_r0_body.fii26⟩
theorem PRE_first_tail_x6_r0_body.cnshift26 (clean : Conv.NClean (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P26.NL) (cl : SSt (· < 1165) PRE_first_tail_x6_r0_body.cx0_26.mlx) : NShift PRE_first_tail_x6_r0_body.P26 1165 PRE_first_tail_x6_r0_body.kappa26 PRE_first_tail_x6_r0_body.cx0_26 PRE_first_tail_x6_r0_body.cx1_26 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot26 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost26 (compact_a_eq PRE_first_tail_x6_r0_body.ckn026 PRE_first_tail_x6_r0_body.ckn126 PRE_first_tail_x6_r0_body.ckheap26 PRE_first_tail_x6_r0_body.ckpl26)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_26 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s258.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_26 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s258.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_26 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s258.ffi) = some PRE_first_tail_x6_r0_body.fxC_26
kernel_rfl PRE_first_tail_x6_r0_body.okrC_26 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s258.ffi) = some PRE_first_tail_x6_r0_body.krC_26
noncomputable def PRE_first_tail_x6_r0_body.fx0_26 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s260.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_26 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s260.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_26 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s260.ffi) = some PRE_first_tail_x6_r0_body.fx0_26
kernel_rfl PRE_first_tail_x6_r0_body.okr0_26 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s260.ffi) = some PRE_first_tail_x6_r0_body.kr0_26
noncomputable def PRE_first_tail_x6_r0_body.fx1_26 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s259.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_26 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s259.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_26 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s259.ffi) = some PRE_first_tail_x6_r0_body.fx1_26
kernel_rfl PRE_first_tail_x6_r0_body.okr1_26 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s259.ffi) = some PRE_first_tail_x6_r0_body.kr1_26
kernel_rfl PRE_first_tail_x6_r0_body.ff026 : PRE_first_tail_x6_r0_body.fx0_26 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_26 (PRE_first_tail_x6_r0_body.clo26.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_26.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff126 : PRE_first_tail_x6_r0_body.fx1_26 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_26 (PRE_first_tail_x6_r0_body.cwS26.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_26.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck26 : freedLB PRE_first_tail_x6_r0_body.kappa26 PRE_first_tail_x6_r0_body.cx0_26.mlx PRE_first_tail_x6_r0_body.fx0_26 PRE_first_tail_x6_r0_body.fx1_26 PRE_first_tail_x6_r0_body.clo26 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf026 : PRE_first_tail_x6_r0_body.kr0_26.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_26.flags (PRE_first_tail_x6_r0_body.clo26.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_26.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt026 : PRE_first_tail_x6_r0_body.kr0_26.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_26.targs (PRE_first_tail_x6_r0_body.clo26.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_26.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf126 : PRE_first_tail_x6_r0_body.kr1_26.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_26.flags (PRE_first_tail_x6_r0_body.cwS26.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_26.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt126 : PRE_first_tail_x6_r0_body.kr1_26.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_26.targs (PRE_first_tail_x6_r0_body.cwS26.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_26.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck26 : krecLB PRE_first_tail_x6_r0_body.kappa26 1165 PRE_first_tail_x6_r0_body.cx0_26.mlx PRE_first_tail_x6_r0_body.kr0_26 PRE_first_tail_x6_r0_body.kr1_26 PRE_first_tail_x6_r0_body.clo26 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn26 : Nat.ble 1165 1165 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge26 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s259.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s260.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR26 : pendRegB PRE_first_tail_x6_r0_body.kappa26 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe26 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s259.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift26 (clean : Conv.NClean (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P26.NL) (cl : SSt (· < 1165) PRE_first_tail_x6_r0_body.cx0_26.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_26.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_26.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_26.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_26.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P26 1165 PRE_first_tail_x6_r0_body.kappa26 PRE_first_tail_x6_r0_body.s260.ffi PRE_first_tail_x6_r0_body.s259.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift26 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue26, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp26 t ht),
    PRE_first_tail_x6_r0_body.cbridge26,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s260.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s259.ffi) (PRE_first_tail_x6_r0_body.cfoot26 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_26 PRE_first_tail_x6_r0_body.ofx1_26 hobjC PRE_first_tail_x6_r0_body.ff026 PRE_first_tail_x6_r0_body.ff126 PRE_first_tail_x6_r0_body.ffck26,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s260.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s259.ffi) (PRE_first_tail_x6_r0_body.cfoot26 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_26 PRE_first_tail_x6_r0_body.okr1_26 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn26) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf026 PRE_first_tail_x6_r0_body.fkt026 PRE_first_tail_x6_r0_body.fkf126 PRE_first_tail_x6_r0_body.fkt126 PRE_first_tail_x6_r0_body.fkck26,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh026 PRE_first_tail_x6_r0_body.cnh126 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe26) PRE_first_tail_x6_r0_body.cpendR26⟩

end Host.Load.Run.Tpl
end

section -- st26/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st26 0
host_stream_state PRE_first_tail_x6_r0_body.st26 1
host_stream_state PRE_first_tail_x6_r0_body.st26 2
end Host.Load.Run.Tpl
end

section -- Site26
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 26 of chain `PRE_first_tail_x6_r0_body`: `plan__g26__g27` (`plan`), the call state `PRE_first_tail_x6_r0_body.s258`, the merged state `PRE_first_tail_x6_r0_body.s259`,
the site template `PRE_first_tail_x6_r0_body.st26` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s260`: the merge.
The footprint's facts are in `SiteF26`, the compaction's in `SiteC26`, `SiteK26`, `SiteNa26`, `SiteNb26`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso26 : PRE_first_tail_x6_r0_body.st26.s0 = { PRE_first_tail_x6_r0_body.s258 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs26 : List Frame := PRE_first_tail_x6_r0_body.s258.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_26 : PRE_first_tail_x6_r0_body.S258.tab.length = 1165
kernel_rfl PRE_first_tail_x6_r0_body.tab0_26 : PRE_first_tail_x6_r0_body.st26.S0.tab = PRE_first_tail_x6_r0_body.S258.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws26 : List Nat := [1443, 1444, 1445]
kernel_rfl PRE_first_tail_x6_r0_body.fresh26 : (PRE_first_tail_x6_r0_body.S258.tab.all fun e => PRE_first_tail_x6_r0_body.ws26.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S258.oracle.all fun q => PRE_first_tail_x6_r0_body.ws26.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab26 : PRE_first_tail_x6_r0_body.S259.tab = PRE_first_tail_x6_r0_body.S258.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws26
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen26 : PRE_first_tail_x6_r0_body.st26.S2.tab.length - PRE_first_tail_x6_r0_body.st26.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged26`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap26 : PRE_first_tail_x6_r0_body.s259.heap = PRE_first_tail_x6_r0_body.st26.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext26 : PRE_first_tail_x6_r0_body.s259.next = PRE_first_tail_x6_r0_body.st26.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl26 : PRE_first_tail_x6_r0_body.s259.ctl = PRE_first_tail_x6_r0_body.st26.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack26 : PRE_first_tail_x6_r0_body.s259.stack = PRE_first_tail_x6_r0_body.st26.s2.stack ++ PRE_first_tail_x6_r0_body.s258.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs26 : PRE_first_tail_x6_r0_body.s259.jobs = PRE_first_tail_x6_r0_body.st26.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi26 : PRE_first_tail_x6_r0_body.s259.ffi = PRE_first_tail_x6_r0_body.st26.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace26 : PRE_first_tail_x6_r0_body.s259.trace = PRE_first_tail_x6_r0_body.st26.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores26 : PRE_first_tail_x6_r0_body.s259.stores = PRE_first_tail_x6_r0_body.st26.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD26
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 26 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived26 : PRE_first_tail_x6_r0_body.nr26.map (fun r => nth? PRE_first_tail_x6_r0_body.st26.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo26 : PRE_first_tail_x6_r0_body.nr26.all (Nat.ble 1165) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj26 : PRE_first_tail_x6_r0_body.cws26.all (fun c => !PRE_first_tail_x6_r0_body.ws26.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ26 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws26 PRE_first_tail_x6_r0_body.crs26 PRE_first_tail_x6_r0_body.ws26

end Host.Load.Run.Tpl
end

section -- st26/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st26`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st26.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st26.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st26.s2.heap PRE_first_tail_x6_r0_body.st26.wrR ++ freshOf PRE_first_tail_x6_r0_body.st26.s2.heap PRE_first_tail_x6_r0_body.st26.s0.next PRE_first_tail_x6_r0_body.st26.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st26.wr : List Nat := PRE_first_tail_x6_r0_body.st26.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st26.heapFoot : PRE_first_tail_x6_r0_body.st26.s2.heap = setAll PRE_first_tail_x6_r0_body.st26.s0.heap PRE_first_tail_x6_r0_body.st26.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st26.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st26.s0.next PRE_first_tail_x6_r0_body.st26.s2.next = true
theorem PRE_first_tail_x6_r0_body.st26.grows : PRE_first_tail_x6_r0_body.st26.s0.next ≤ PRE_first_tail_x6_r0_body.st26.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st26.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st26.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st26.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st26.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st26.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st26.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st26.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st26.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st26.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st26.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st26.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st26.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF26
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 26 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB26 : nodupT PRE_first_tail_x6_r0_body.st26.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup26 : PRE_first_tail_x6_r0_body.st26.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB26).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB26 : PRE_first_tail_x6_r0_body.st26.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound26 : ∀ b ∈ PRE_first_tail_x6_r0_body.st26.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB26 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr26 := PRE_first_tail_x6_r0_body.st26.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq26 : PRE_first_tail_x6_r0_body.st26.s2.trace = PRE_first_tail_x6_r0_body.trFr26 ++ PRE_first_tail_x6_r0_body.st26.s0.trace
theorem PRE_first_tail_x6_r0_body.trace26 : ∃ fr, PRE_first_tail_x6_r0_body.st26.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st26.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq26⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide26 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB26 : (PRE_first_tail_x6_r0_body.wide26.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st26.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix26 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide26, WFix Map.id (Present PRE_first_tail_x6_r0_body.st26.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB26 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL26
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 26 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s259`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO26 : PRE_first_tail_x6_r0_body.st26.S0.oracle = PRE_first_tail_x6_r0_body.st26.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B26 : PRE_first_tail_x6_r0_body.st26.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st26.s0.next || (PRE_first_tail_x6_r0_body.st26.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot26 : Conv.StageFoot PRE_first_tail_x6_r0_body.st26.wr PRE_first_tail_x6_r0_body.st26.s0 PRE_first_tail_x6_r0_body.st26.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st26.heapFoot PRE_first_tail_x6_r0_body.wrNodup26 PRE_first_tail_x6_r0_body.wrBound26 PRE_first_tail_x6_r0_body.wr0B26 PRE_first_tail_x6_r0_body.st26.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged26 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st26.F.S → PRE_first_tail_x6_r0_body.st26.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st26.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st26.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs26 PRE_first_tail_x6_r0_body.st26.wr PRE_first_tail_x6_r0_body.s258 PRE_first_tail_x6_r0_body.st26.s2 PRE_first_tail_x6_r0_body.st26.s0
      PRE_first_tail_x6_r0_body.st26.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st26.F FR W stk M ν K PRE_first_tail_x6_r0_body.s259 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso26 PRE_first_tail_x6_r0_body.stFoot26 PRE_first_tail_x6_r0_body.wrNodup26 PRE_first_tail_x6_r0_body.wrBound26 PRE_first_tail_x6_r0_body.trace26 PRE_first_tail_x6_r0_body.mheap26
    PRE_first_tail_x6_r0_body.mnext26 PRE_first_tail_x6_r0_body.mctl26 PRE_first_tail_x6_r0_body.mstack26 PRE_first_tail_x6_r0_body.mjobs26 PRE_first_tail_x6_r0_body.mffi26 PRE_first_tail_x6_r0_body.mtrace26 PRE_first_tail_x6_r0_body.mstores26 h

def PRE_first_tail_x6_r0_body.arrEl26_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE26_2665 : arrOf PRE_first_tail_x6_r0_body.s259 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl26_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA26_2665 : isArrB PRE_first_tail_x6_r0_body.s259 2665 = true
theorem PRE_first_tail_x6_r0_body.arr26_2665 : ∃ o, PRE_first_tail_x6_r0_body.s259.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl26_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE26_2665 PRE_first_tail_x6_r0_body.arrA26_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN26_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl26_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR26_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl26_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN26_2665

def PRE_first_tail_x6_r0_body.arrEl26_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE26_2673467 : arrOf PRE_first_tail_x6_r0_body.s259 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl26_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA26_2673467 : isArrB PRE_first_tail_x6_r0_body.s259 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr26_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s259.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl26_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE26_2673467 PRE_first_tail_x6_r0_body.arrA26_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN26_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl26_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR26_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl26_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN26_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k26 : isArrB PRE_first_tail_x6_r0_body.s259 4910 = false
theorem PRE_first_tail_x6_r0_body.keep26 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s259 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k26 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr26_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl26_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ26
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 26 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s258`, the merged
state `PRE_first_tail_x6_r0_body.s259`, the canonical state `PRE_first_tail_x6_r0_body.s260`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl26 : PRE_first_tail_x6_r0_body.pl26.all (Nat.ble PRE_first_tail_x6_r0_body.s258.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd26 : nodupT PRE_first_tail_x6_r0_body.pl26 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn126 : Nat.ble PRE_first_tail_x6_r0_body.s258.next 2695082 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst26 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s258.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn26 : PRE_first_tail_x6_r0_body.s260.next = PRE_first_tail_x6_r0_body.s258.next + PRE_first_tail_x6_r0_body.pl26.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn26 : PRE_first_tail_x6_r0_body.s259.next = 2695082
kernel_rfl PRE_first_tail_x6_r0_body.zgrow26 : Nat.ble PRE_first_tail_x6_r0_body.s260.next PRE_first_tail_x6_r0_body.s259.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh26 : PRE_first_tail_x6_r0_body.S258.tab.all (fun e => PRE_first_tail_x6_r0_body.cws26.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd26 : nodupT PRE_first_tail_x6_r0_body.cws26 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi26 : PRE_first_tail_x6_r0_body.nr26.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S259.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt26 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s258.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg26_2665 : PRE_first_tail_x6_r0_body.s260.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s260 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk26_2665 : (objOf PRE_first_tail_x6_r0_body.s260 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm26_2665 : PRE_first_tail_x6_r0_body.s259.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa26.obj (objOf PRE_first_tail_x6_r0_body.s260 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s259 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg26_2673467 : PRE_first_tail_x6_r0_body.s260.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s260 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk26_2673467 : (objOf PRE_first_tail_x6_r0_body.s260 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm26_2673467 : PRE_first_tail_x6_r0_body.s259.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa26.obj (objOf PRE_first_tail_x6_r0_body.s260 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s259 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw26_4910 : (PRE_first_tail_x6_r0_body.s260.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw26_2673472 : (PRE_first_tail_x6_r0_body.s260.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw26_2673473 : (PRE_first_tail_x6_r0_body.s260.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd26 : PRE_first_tail_x6_r0_body.cl26.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr26 : PRE_first_tail_x6_r0_body.st26.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s258.next || PRE_first_tail_x6_r0_body.cl26.contains b) = true
def PRE_first_tail_x6_r0_body.zl26 : List Nat := PRE_first_tail_x6_r0_body.cl26.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE26 : PRE_first_tail_x6_r0_body.zl26.map (fun a => PRE_first_tail_x6_r0_body.s259.heap.get (PRE_first_tail_x6_r0_body.kappa26.a a)) = PRE_first_tail_x6_r0_body.zl26.map (fun a => (PRE_first_tail_x6_r0_body.s260.heap.get a).map PRE_first_tail_x6_r0_body.kappa26.hobj)
theorem PRE_first_tail_x6_r0_body.zimg26 : HeapImg PRE_first_tail_x6_r0_body.kappa26 PRE_first_tail_x6_r0_body.s260 PRE_first_tail_x6_r0_body.s259 PRE_first_tail_x6_r0_body.zl26 := PRE_first_tail_x6_r0_body.zimgE26
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl26 : PRE_first_tail_x6_r0_body.s259.ctl = PRE_first_tail_x6_r0_body.kappa26.ctl PRE_first_tail_x6_r0_body.s260.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack26 : PRE_first_tail_x6_r0_body.s259.stack = PRE_first_tail_x6_r0_body.s260.stack.map PRE_first_tail_x6_r0_body.kappa26.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs26 : PRE_first_tail_x6_r0_body.s259.jobs = PRE_first_tail_x6_r0_body.s260.jobs.map PRE_first_tail_x6_r0_body.kappa26.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores26 : PRE_first_tail_x6_r0_body.s259.stores = PRE_first_tail_x6_r0_body.kappa26.stores PRE_first_tail_x6_r0_body.s260.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots26 : checkRootsSupp PRE_first_tail_x6_r0_body.s260 1165 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC26 : PRE_first_tail_x6_r0_body.S258.tab.length + PRE_first_tail_x6_r0_body.cws26.length = 1165
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap26 : PRE_first_tail_x6_r0_body.kappa26 = Conv.Map.compact PRE_first_tail_x6_r0_body.s258.next 2695082 PRE_first_tail_x6_r0_body.S258.tab.length PRE_first_tail_x6_r0_body.pl26 (PRE_first_tail_x6_r0_body.nr26.map NumV.ref) PRE_first_tail_x6_r0_body.kd26.big
  PRE_first_tail_x6_r0_body.kd26.region PRE_first_tail_x6_r0_body.kd26.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin26 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s260.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc26 : Conv.jcleanListB (⟨18711, 15796, 2695072, 1165⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s260 PRE_first_tail_x6_r0_body.cl26 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB26 : noBigRootsP (fun i => !Conv.oldBigB (⟨18711, 15796, 2695072, 1165⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s260.trace PRE_first_tail_x6_r0_body.s260 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm26 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15796 = true
theorem PRE_first_tail_x6_r0_body.cjcl26 (h : Conv.JClean (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s258) : Conv.JClean (⟨18711, 15796, 2695072, 1165⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s260 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle26)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap26 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd26 a ha)) PRE_first_tail_x6_r0_body.zjc26

end Host.Load.Run.Tpl
end

section -- st26/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st26.bodyLast from PRE_first_tail_x6_r0_body.st26.s1 to PRE_first_tail_x6_r0_body.st26.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st26.F PRE_first_tail_x6_r0_body.st26.s1).run PRE_first_tail_x6_r0_body.st26.S1 = some (PRE_first_tail_x6_r0_body.st26.s2, PRE_first_tail_x6_r0_body.st26.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st26.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st26.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st26.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st26.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st26/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st26.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st26.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st26.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st26.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st26.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st26.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st26.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st26.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st26.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st26.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st26.s0 PRE_first_tail_x6_r0_body.st26.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st26.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st26.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st26.s1 PRE_first_tail_x6_r0_body.st26.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st26/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st26.bodyK0F from PRE_first_tail_x6_r0_body.st26.s0 to PRE_first_tail_x6_r0_body.st26.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st26.F (PRE_first_tail_x6_r0_body.st26.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st26.ks 0).getD 0) PRE_first_tail_x6_r0_body.st26.s0 PRE_first_tail_x6_r0_body.st26.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st26.s1, PRE_first_tail_x6_r0_body.st26.S1)
theorem PRE_first_tail_x6_r0_body.st26.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st26.F (PRE_first_tail_x6_r0_body.st26.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st26.ks 0).getD 0) PRE_first_tail_x6_r0_body.st26.s0 PRE_first_tail_x6_r0_body.st26.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st26.s1, PRE_first_tail_x6_r0_body.st26.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st26.bodyOkLN_ok PRE_first_tail_x6_r0_body.st26.bodyK0F
end Host.Load.Run.Tpl
end

section -- st26/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st26.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st26.F (PRE_first_tail_x6_r0_body.st26.bodyOkL bytes rows) 98 PRE_first_tail_x6_r0_body.st26.s0 PRE_first_tail_x6_r0_body.st26.S0 = some (PRE_first_tail_x6_r0_body.st26.s1, PRE_first_tail_x6_r0_body.st26.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st26.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st26.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st26.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st26.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st26.F (PRE_first_tail_x6_r0_body.st26.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st26.s0
  S0 := PRE_first_tail_x6_r0_body.st26.S0
  s1 := PRE_first_tail_x6_r0_body.st26.s1
  S1 := PRE_first_tail_x6_r0_body.st26.S1
  s2 := PRE_first_tail_x6_r0_body.st26.s2
  S2 := PRE_first_tail_x6_r0_body.st26.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st26.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st26.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st26.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st26.bodyHalt
  last := PRE_first_tail_x6_r0_body.st26.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st26.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC27
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 27 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s277` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa27` into the merged state
`PRE_first_tail_x6_r0_body.s276`. -/

def PRE_first_tail_x6_r0_body.pl27 : List Nat := [2697655, 2696830, 2697661, 2697657, 2696832, 2697663]
def PRE_first_tail_x6_r0_body.nr27 : List Nat := [1268, 1267, 1243, 1251, 1256, 1261, 1266, 1240, 1241, 1242, 1249, 1250, 1238, 1245, 1246, 1247, 1248, 1244]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd27 : RData :=
  ⟨2696549, 2697698, Stage.setAll PTrie.nil [(2696543, 2697655), (2696544, 2696830), (2696545, 2697661), (2696546, 2697657), (2696547, 2696832), (2696548, 2697663)], Stage.setAll PTrie.nil [(18745, 18771), (18746, 18749), (18747, 18772)],
   18748, 18773, 15842, 15842, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(1238, .ref 1268), (1239, .ref 1267), (1240, .ref 1243), (1241, .ref 1251), (1242, .ref 1256), (1243, .ref 1261), (1244, .ref 1266), (1245, .ref 1240), (1246, .ref 1241), (1247, .ref 1242), (1248, .ref 1249), (1249, .ref 1250), (1250, .ref 1238), (1251, .ref 1245), (1252, .ref 1246), (1253, .ref 1247), (1254, .ref 1248), (1255, .ref 1244)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa27 : Map :=
  Conv.Map.compact 2696543 2697698 1238 PRE_first_tail_x6_r0_body.pl27 (PRE_first_tail_x6_r0_body.nr27.map NumV.ref) PRE_first_tail_x6_r0_body.kd27.big
    PRE_first_tail_x6_r0_body.kd27.region PRE_first_tail_x6_r0_body.kd27.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws27 : List Nat := [1477, 1478, 1479, 1480, 1481, 1482, 1483, 1484, 1485, 1486, 1487, 1488, 1489, 1490, 1491, 1492, 1493, 1494]
noncomputable def PRE_first_tail_x6_r0_body.crs27 : List SymE := PRE_first_tail_x6_r0_body.nr27.map fun r => (nth? PRE_first_tail_x6_r0_body.S276.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta27 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws27 PRE_first_tail_x6_r0_body.crs27
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB27 : List Nat := [2665, 2672367, 2673467, 2695717, 2696262, 2696518]

kernel_rfl PRE_first_tail_x6_r0_body.ctab27 : PRE_first_tail_x6_r0_body.S277.tab = PRE_first_tail_x6_r0_body.S275.tab ++ PRE_first_tail_x6_r0_body.cws27.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace27 : PRE_first_tail_x6_r0_body.s277.trace = PRE_first_tail_x6_r0_body.s275.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext27 : PRE_first_tail_x6_r0_body.s277.next = 2696549
kernel_rfl PRE_first_tail_x6_r0_body.ccounters27 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx.nnext) = (18748, 15842)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue27 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s276.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa27.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp27 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx.tokens.all (bSN 1256) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean27 : Conv.cleanListB 18748 131072 (fun r => Nat.ble 74992 r) PRE_first_tail_x6_r0_body.s277
    (PRE_first_tail_x6_r0_body.wrB27 ++ (List.range 6).map (2696543 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs27 : bigsOutB 18748 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK27
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl27`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl27 : List Nat := [2665, 2672367, 2673467, 2695717, 2696262, 2696518, 2696543, 2696544, 2696545, 2696546, 2696547, 2696548]
def PRE_first_tail_x6_r0_body.clo27 : List Nat := [18725, 18738, 18744, 18745, 18746, 18747]
def PRE_first_tail_x6_r0_body.cln27 : List Nat := [15815, 15816, 15817, 15818, 15819, 15820, 15821, 15822, 15823, 15824, 15825, 15826, 15827, 15828, 15829, 15830, 15831, 15832, 15833, 15834, 15835, 15836, 15837, 15838, 15839, 15840, 15841]
def PRE_first_tail_x6_r0_body.cli27 : List Nat := [15815, 15816, 15817, 15818, 15819, 15820, 15821, 15822, 15823, 15824, 15825, 15826, 15827, 15828, 15829, 15830, 15831, 15832, 15833, 15834, 15835, 15836, 15837, 15838, 15839, 15840, 15841]
kernel_rfl PRE_first_tail_x6_r0_body.cheap27 : PRE_first_tail_x6_r0_body.s277.heap = Stage.setAll PRE_first_tail_x6_r0_body.s275.heap (PRE_first_tail_x6_r0_body.cl27.filterMap fun a => (PRE_first_tail_x6_r0_body.s277.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe27 : Nat.ble PRE_first_tail_x6_r0_body.s275.next PRE_first_tail_x6_r0_body.s277.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP27 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s275 PRE_first_tail_x6_r0_body.s277 PRE_first_tail_x6_r0_body.cl27 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp27 : Conv.suppListB PRE_first_tail_x6_r0_body.s277 1256 PRE_first_tail_x6_r0_body.cl27 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound27 : Conv.boundListB PRE_first_tail_x6_r0_body.s277 PRE_first_tail_x6_r0_body.cl27 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK27 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln27.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK27 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo27.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK27 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli27.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst27 : Conv.sstListB 1256 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx PRE_first_tail_x6_r0_body.cln27 PRE_first_tail_x6_r0_body.clo27 PRE_first_tail_x6_r0_body.cli27 = true

end Host.Load.Run.Tpl
end

section -- SiteCl27
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA27 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo27.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd27 : (PRE_first_tail_x6_r0_body.clo27 ++ PRE_first_tail_x6_r0_body.cln27 ++ PRE_first_tail_x6_r0_body.cli27).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle27 : Conv.Cnt.leB (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) (⟨18748, 15842, 2696549, 1256⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck27 : Conv.ncleanListB (⟨18748, 15842, 2696549, 1256⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx PRE_first_tail_x6_r0_body.clo27 PRE_first_tail_x6_r0_body.cln27 PRE_first_tail_x6_r0_body.cli27 = true
theorem PRE_first_tail_x6_r0_body.cncl27 (h : Conv.NClean (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx) : Conv.NClean (⟨18748, 15842, 2696549, 1256⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle27 PRE_first_tail_x6_r0_body.ckA27 PRE_first_tail_x6_r0_body.cobjsK27 PRE_first_tail_x6_r0_body.cnodesK27 PRE_first_tail_x6_r0_body.citemsK27 PRE_first_tail_x6_r0_body.cbd27 PRE_first_tail_x6_r0_body.cck27

end Host.Load.Run.Tpl
end

section -- SiteS27
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 27 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc27 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P27 : LoadP := PRE_first_tail_x6_r0_body.Pc27.raise 15842
kernel_rfl PRE_first_tail_x6_r0_body.craise27 : Nat.ble PRE_first_tail_x6_r0_body.Pc27.N0 15842 = true
theorem PRE_first_tail_x6_r0_body.raised27 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc27 PRE_first_tail_x6_r0_body.P27 :=
  .inr ⟨15842, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise27, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_27 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_27 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s276.ffi)
def PRE_first_tail_x6_r0_body.khinv27 : PTrie Nat := Stage.setAll PTrie.nil [(18771, 18745), (18749, 18746), (18772, 18747)]
def PRE_first_tail_x6_r0_body.kninv27 : PTrie Nat := Stage.setAll PTrie.nil [(15815, 15815), (15816, 15816), (15817, 15817), (15818, 15818), (15819, 15819), (15820, 15820), (15821, 15821), (15822, 15822), (15823, 15823), (15824, 15824), (15825, 15825), (15826, 15826), (15827, 15827), (15828, 15828), (15829, 15829), (15830, 15830), (15831, 15831), (15832, 15832), (15833, 15833), (15834, 15834), (15835, 15835), (15836, 15836), (15837, 15837), (15838, 15838), (15839, 15839), (15840, 15840), (15841, 15841)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS27 : List Nat := [18725, 18738, 18744, 18745, 18746, 18747, 18748, 18749, 18750, 18751, 18752, 18753, 18754, 18755, 18756, 18757, 18758, 18759, 18760, 18761, 18762, 18763, 18764, 18765, 18766, 18767, 18768, 18769, 18770, 18771, 18772]
def PRE_first_tail_x6_r0_body.cnS27 : List Nat := List.range' 15815 27
def PRE_first_tail_x6_r0_body.ciS27 : List Nat := [] ++ List.range' 15815 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh027 : PRE_first_tail_x6_r0_body.kd27.nh0 = PRE_first_tail_x6_r0_body.cx0_27.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh127 : PRE_first_tail_x6_r0_body.kd27.nh1 = PRE_first_tail_x6_r0_body.cx1_27.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn027 : PRE_first_tail_x6_r0_body.kd27.nn0 = PRE_first_tail_x6_r0_body.cx0_27.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn127 : PRE_first_tail_x6_r0_body.kd27.nn1 = PRE_first_tail_x6_r0_body.cx1_27.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo27 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P27.lo && Nat.ble PRE_first_tail_x6_r0_body.P27.lo PRE_first_tail_x6_r0_body.cx0_27.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P27.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P27.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt27 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_27.mlx.next PRE_first_tail_x6_r0_body.cx1_27.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_27.mlx.nnext PRE_first_tail_x6_r0_body.cx1_27.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband27 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P27.NL && Nat.ble PRE_first_tail_x6_r0_body.P27.NL PRE_first_tail_x6_r0_body.P27.N0 && Nat.ble PRE_first_tail_x6_r0_body.P27.N0 PRE_first_tail_x6_r0_body.cx0_27.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow27 : PRE_first_tail_x6_r0_body.kd27.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren27 : checkRenG PRE_first_tail_x6_r0_body.kd27.hnd PRE_first_tail_x6_r0_body.khinv27 (phB PRE_first_tail_x6_r0_body.cx0_27.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband27 : PRE_first_tail_x6_r0_body.kd27.checkBand PRE_first_tail_x6_r0_body.P27.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos27 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd27.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren27 : checkRenG PRE_first_tail_x6_r0_body.kd27.node PRE_first_tail_x6_r0_body.kninv27 (pnB PRE_first_tail_x6_r0_body.cx0_27.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow27 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd27.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P27.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd27.nodeF j) PRE_first_tail_x6_r0_body.cx1_27.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a27 : PRE_first_tail_x6_r0_body.cx0_27.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b27 : PRE_first_tail_x6_r0_body.cx0_27.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok127 : PRE_first_tail_x6_r0_body.cx1_27.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend27 : PRE_first_tail_x6_r0_body.cx1_27.mlx.pending = PRE_first_tail_x6_r0_body.cx0_27.mlx.pending.map PRE_first_tail_x6_r0_body.kappa27.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh27 : PRE_first_tail_x6_r0_body.cx1_27.mlx.errh = PRE_first_tail_x6_r0_body.cx0_27.mlx.errh.map PRE_first_tail_x6_r0_body.kappa27.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles27 : PRE_first_tail_x6_r0_body.cx1_27.mlx.files = PRE_first_tail_x6_r0_body.cx0_27.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch27 : PRE_first_tail_x6_r0_body.cx1_27.mlx.arch = PRE_first_tail_x6_r0_body.cx0_27.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes27 : PRE_first_tail_x6_r0_body.cx1_27.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_27.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired27 : PRE_first_tail_x6_r0_body.cx1_27.mlx.wired = PRE_first_tail_x6_r0_body.cx0_27.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost27 : PRE_first_tail_x6_r0_body.cx1_27.host = PRE_first_tail_x6_r0_body.cx0_27.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd27`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn027 : PRE_first_tail_x6_r0_body.kd27.n0 = 2696549
kernel_rfl PRE_first_tail_x6_r0_body.ckn127 : PRE_first_tail_x6_r0_body.kd27.n1 = 2697698
kernel_rfl PRE_first_tail_x6_r0_body.ckheap27 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd27.heap).all (fun x => Nat.ble 2696543 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl27 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd27.heap.get (2696543 + j) = nth? PRE_first_tail_x6_r0_body.pl27 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja27 : Nat.ble 2696543 2696543 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn27 : Nat.ble 1238 1238 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD27 : Nat.ble 2696543 PRE_first_tail_x6_r0_body.kd27.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn27 : Nat.ble 18745 PRE_first_tail_x6_r0_body.kd27.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn27 : Nat.ble 15815 PRE_first_tail_x6_r0_body.kd27.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb27 : Nat.ble 18745 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap27 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd27.heap).all (Nat.ble (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd27 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd27.hnd).all (Nat.ble (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode27 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd27.node).all (Nat.ble (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix27 : Conv.FixOld (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa27 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja27) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn27) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD27) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn27) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn27) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb27) PRE_first_tail_x6_r0_body.fheap27 PRE_first_tail_x6_r0_body.fhnd27 PRE_first_tail_x6_r0_body.fnode27
kernel_rfl PRE_first_tail_x6_r0_body.fcxn27 : (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn27 : (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle027 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_27.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_27.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk27 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd27.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A27 : PRE_first_tail_x6_r0_body.cx1_27.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS27.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_27.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O27 : PRE_first_tail_x6_r0_body.cx1_27.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS27.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_27.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N27 : PRE_first_tail_x6_r0_body.cx1_27.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS27.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_27.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I27 : PRE_first_tail_x6_r0_body.cx1_27.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS27.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_27.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd27 : (PRE_first_tail_x6_r0_body.clo27 ++ PRE_first_tail_x6_r0_body.cln27 ++ PRE_first_tail_x6_r0_body.cli27 ++ PRE_first_tail_x6_r0_body.cwS27 ++ PRE_first_tail_x6_r0_body.cnS27 ++ PRE_first_tail_x6_r0_body.ciS27).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW27 : PRE_first_tail_x6_r0_body.cwS27.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo27.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI27 : PRE_first_tail_x6_r0_body.ciS27.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli27.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN27 : PRE_first_tail_x6_r0_body.cnS27.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF27 : PRE_first_tail_x6_r0_body.cln27.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh27 : PRE_first_tail_x6_r0_body.clo27.all (handleOK PRE_first_tail_x6_r0_body.kappa27 PRE_first_tail_x6_r0_body.P27.lo PRE_first_tail_x6_r0_body.cx0_27.mlx PRE_first_tail_x6_r0_body.cx1_27.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo27 : PRE_first_tail_x6_r0_body.clo27.map (fun h => PRE_first_tail_x6_r0_body.cx1_27.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa27.handle h)) = PRE_first_tail_x6_r0_body.clo27.map (fun h => (PRE_first_tail_x6_r0_body.cx0_27.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa27.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok27 : PRE_first_tail_x6_r0_body.clo27.all (objOK PRE_first_tail_x6_r0_body.kappa27 PRE_first_tail_x6_r0_body.P27.NL PRE_first_tail_x6_r0_body.cx0_27.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd27 : PRE_first_tail_x6_r0_body.cln27.all (nodeOKF PRE_first_tail_x6_r0_body.kappa27 PRE_first_tail_x6_r0_body.P27 PRE_first_tail_x6_r0_body.cx0_27.mlx PRE_first_tail_x6_r0_body.cx1_27.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp27 : ((PRE_first_tail_x6_r0_body.cln27.filter (fullB PRE_first_tail_x6_r0_body.P27))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_27.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa27.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln27.filter (fullB PRE_first_tail_x6_r0_body.P27))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_27.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa27.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI27 : incrB PRE_first_tail_x6_r0_body.kd27.nodeF (List.range' 15815 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK27 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd27.node).all (fun k => Nat.ble 15815 k && Nat.blt k 15842) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL27 : (PRE_first_tail_x6_r0_body.cln27.filter (Nat.ble PRE_first_tail_x6_r0_body.P27.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd27.nodeF i) && (Nat.blt i 15842 || Nat.ble PRE_first_tail_x6_r0_body.kd27.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord27 : (PRE_first_tail_x6_r0_body.cln27.filter (Nat.ble PRE_first_tail_x6_r0_body.P27.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd27.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd27.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd27.nodeF j) (PRE_first_tail_x6_r0_body.kd27.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow27 PRE_first_tail_x6_r0_body.cnn127 PRE_first_tail_x6_r0_body.fnordI27 PRE_first_tail_x6_r0_body.fnordK27 PRE_first_tail_x6_r0_body.fnordL27
kernel_rfl PRE_first_tail_x6_r0_body.fi27 : PRE_first_tail_x6_r0_body.cli27.all (pnB PRE_first_tail_x6_r0_body.cx0_27.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii27 : PRE_first_tail_x6_r0_body.cli27.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_27.mlx.items.get (PRE_first_tail_x6_r0_body.kappa27.node k) = (PRE_first_tail_x6_r0_body.cx0_27.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa27.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot27 (clean : Conv.NClean (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P27.NL) (cl : SSt (· < 1256) PRE_first_tail_x6_r0_body.cx0_27.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P27 1256 PRE_first_tail_x6_r0_body.kappa27 PRE_first_tail_x6_r0_body.kd27 PRE_first_tail_x6_r0_body.khinv27 PRE_first_tail_x6_r0_body.kninv27 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx PRE_first_tail_x6_r0_body.cx0_27.mlx PRE_first_tail_x6_r0_body.cx1_27.mlx (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo27 PRE_first_tail_x6_r0_body.cln27 PRE_first_tail_x6_r0_body.cli27 PRE_first_tail_x6_r0_body.cwS27 PRE_first_tail_x6_r0_body.cnS27 PRE_first_tail_x6_r0_body.ciS27 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh027, PRE_first_tail_x6_r0_body.cnh127, PRE_first_tail_x6_r0_body.cnn027, PRE_first_tail_x6_r0_body.cnn127, PRE_first_tail_x6_r0_body.cplo27, PRE_first_tail_x6_r0_body.ccnt27, PRE_first_tail_x6_r0_body.cnband27, PRE_first_tail_x6_r0_body.chbelow27, PRE_first_tail_x6_r0_body.chren27, PRE_first_tail_x6_r0_body.cband27, PRE_first_tail_x6_r0_body.cnh1pos27, PRE_first_tail_x6_r0_body.cnren27, PRE_first_tail_x6_r0_body.cnlow27, PRE_first_tail_x6_r0_body.cabs0a27, PRE_first_tail_x6_r0_body.cabs0b27, PRE_first_tail_x6_r0_body.ctok127, PRE_first_tail_x6_r0_body.cpend27, PRE_first_tail_x6_r0_body.cerrh27, PRE_first_tail_x6_r0_body.cfiles27, PRE_first_tail_x6_r0_body.carch27, PRE_first_tail_x6_r0_body.csizes27, PRE_first_tail_x6_r0_body.cwired27, PRE_first_tail_x6_r0_body.cfix27, clean, PRE_first_tail_x6_r0_body.fcxn27, PRE_first_tail_x6_r0_body.fcnn27, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle027, PRE_first_tail_x6_r0_body.fnk27, PRE_first_tail_x6_r0_body.ckA27, PRE_first_tail_x6_r0_body.cobjsK27, PRE_first_tail_x6_r0_body.cnodesK27, PRE_first_tail_x6_r0_body.citemsK27, PRE_first_tail_x6_r0_body.f1A27, PRE_first_tail_x6_r0_body.f1O27, PRE_first_tail_x6_r0_body.f1N27, PRE_first_tail_x6_r0_body.f1I27, PRE_first_tail_x6_r0_body.fbd27, PRE_first_tail_x6_r0_body.fincW27, PRE_first_tail_x6_r0_body.fincI27, PRE_first_tail_x6_r0_body.fincN27, PRE_first_tail_x6_r0_body.flnF27, PRE_first_tail_x6_r0_body.fh27, PRE_first_tail_x6_r0_body.fo27, PRE_first_tail_x6_r0_body.fok27, PRE_first_tail_x6_r0_body.fnd27, PRE_first_tail_x6_r0_body.fp27, PRE_first_tail_x6_r0_body.fnord27, PRE_first_tail_x6_r0_body.fi27, PRE_first_tail_x6_r0_body.fii27⟩
theorem PRE_first_tail_x6_r0_body.cnshift27 (clean : Conv.NClean (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P27.NL) (cl : SSt (· < 1256) PRE_first_tail_x6_r0_body.cx0_27.mlx) : NShift PRE_first_tail_x6_r0_body.P27 1256 PRE_first_tail_x6_r0_body.kappa27 PRE_first_tail_x6_r0_body.cx0_27 PRE_first_tail_x6_r0_body.cx1_27 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot27 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost27 (compact_a_eq PRE_first_tail_x6_r0_body.ckn027 PRE_first_tail_x6_r0_body.ckn127 PRE_first_tail_x6_r0_body.ckheap27 PRE_first_tail_x6_r0_body.ckpl27)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_27 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s275.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_27 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s275.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_27 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s275.ffi) = some PRE_first_tail_x6_r0_body.fxC_27
kernel_rfl PRE_first_tail_x6_r0_body.okrC_27 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s275.ffi) = some PRE_first_tail_x6_r0_body.krC_27
noncomputable def PRE_first_tail_x6_r0_body.fx0_27 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s277.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_27 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s277.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_27 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s277.ffi) = some PRE_first_tail_x6_r0_body.fx0_27
kernel_rfl PRE_first_tail_x6_r0_body.okr0_27 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s277.ffi) = some PRE_first_tail_x6_r0_body.kr0_27
noncomputable def PRE_first_tail_x6_r0_body.fx1_27 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s276.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_27 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s276.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_27 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s276.ffi) = some PRE_first_tail_x6_r0_body.fx1_27
kernel_rfl PRE_first_tail_x6_r0_body.okr1_27 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s276.ffi) = some PRE_first_tail_x6_r0_body.kr1_27
kernel_rfl PRE_first_tail_x6_r0_body.ff027 : PRE_first_tail_x6_r0_body.fx0_27 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_27 (PRE_first_tail_x6_r0_body.clo27.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_27.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff127 : PRE_first_tail_x6_r0_body.fx1_27 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_27 (PRE_first_tail_x6_r0_body.cwS27.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_27.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck27 : freedLB PRE_first_tail_x6_r0_body.kappa27 PRE_first_tail_x6_r0_body.cx0_27.mlx PRE_first_tail_x6_r0_body.fx0_27 PRE_first_tail_x6_r0_body.fx1_27 PRE_first_tail_x6_r0_body.clo27 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf027 : PRE_first_tail_x6_r0_body.kr0_27.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_27.flags (PRE_first_tail_x6_r0_body.clo27.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_27.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt027 : PRE_first_tail_x6_r0_body.kr0_27.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_27.targs (PRE_first_tail_x6_r0_body.clo27.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_27.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf127 : PRE_first_tail_x6_r0_body.kr1_27.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_27.flags (PRE_first_tail_x6_r0_body.cwS27.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_27.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt127 : PRE_first_tail_x6_r0_body.kr1_27.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_27.targs (PRE_first_tail_x6_r0_body.cwS27.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_27.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck27 : krecLB PRE_first_tail_x6_r0_body.kappa27 1256 PRE_first_tail_x6_r0_body.cx0_27.mlx PRE_first_tail_x6_r0_body.kr0_27 PRE_first_tail_x6_r0_body.kr1_27 PRE_first_tail_x6_r0_body.clo27 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn27 : Nat.ble 1238 1256 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge27 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s276.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s277.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR27 : pendRegB PRE_first_tail_x6_r0_body.kappa27 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe27 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s276.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift27 (clean : Conv.NClean (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P27.NL) (cl : SSt (· < 1256) PRE_first_tail_x6_r0_body.cx0_27.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_27.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_27.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_27.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_27.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P27 1256 PRE_first_tail_x6_r0_body.kappa27 PRE_first_tail_x6_r0_body.s277.ffi PRE_first_tail_x6_r0_body.s276.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift27 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue27, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp27 t ht),
    PRE_first_tail_x6_r0_body.cbridge27,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s277.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s276.ffi) (PRE_first_tail_x6_r0_body.cfoot27 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_27 PRE_first_tail_x6_r0_body.ofx1_27 hobjC PRE_first_tail_x6_r0_body.ff027 PRE_first_tail_x6_r0_body.ff127 PRE_first_tail_x6_r0_body.ffck27,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s277.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s276.ffi) (PRE_first_tail_x6_r0_body.cfoot27 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_27 PRE_first_tail_x6_r0_body.okr1_27 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn27) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf027 PRE_first_tail_x6_r0_body.fkt027 PRE_first_tail_x6_r0_body.fkf127 PRE_first_tail_x6_r0_body.fkt127 PRE_first_tail_x6_r0_body.fkck27,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh027 PRE_first_tail_x6_r0_body.cnh127 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe27) PRE_first_tail_x6_r0_body.cpendR27⟩

end Host.Load.Run.Tpl
end

section -- st27/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st27 0
host_stream_state PRE_first_tail_x6_r0_body.st27 1
host_stream_state PRE_first_tail_x6_r0_body.st27 2
host_stream_state PRE_first_tail_x6_r0_body.st27 3
host_stream_state PRE_first_tail_x6_r0_body.st27 4
host_stream_state PRE_first_tail_x6_r0_body.st27 5
end Host.Load.Run.Tpl
end

section -- Site27
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 27 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g27__g28` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s275`, the merged state `PRE_first_tail_x6_r0_body.s276`,
the site template `PRE_first_tail_x6_r0_body.st27` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s277`: the merge.
The footprint's facts are in `SiteF27`, the compaction's in `SiteC27`, `SiteK27`, `SiteNa27`, `SiteNb27`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso27 : PRE_first_tail_x6_r0_body.st27.s0 = { PRE_first_tail_x6_r0_body.s275 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs27 : List Frame := PRE_first_tail_x6_r0_body.s275.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_27 : PRE_first_tail_x6_r0_body.S275.tab.length = 1238
kernel_rfl PRE_first_tail_x6_r0_body.tab0_27 : PRE_first_tail_x6_r0_body.st27.S0.tab = PRE_first_tail_x6_r0_body.S275.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws27 : List Nat := [1446, 1447, 1448, 1449, 1450, 1451, 1452, 1453, 1454, 1455, 1456, 1457, 1458, 1459, 1460, 1461, 1462, 1463, 1464, 1465, 1466, 1467, 1468, 1469, 1470, 1471, 1472, 1473, 1474, 1475, 1476]
kernel_rfl PRE_first_tail_x6_r0_body.fresh27 : (PRE_first_tail_x6_r0_body.S275.tab.all fun e => PRE_first_tail_x6_r0_body.ws27.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S275.oracle.all fun q => PRE_first_tail_x6_r0_body.ws27.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab27 : PRE_first_tail_x6_r0_body.S276.tab = PRE_first_tail_x6_r0_body.S275.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws27
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen27 : PRE_first_tail_x6_r0_body.st27.S5.tab.length - PRE_first_tail_x6_r0_body.st27.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged27`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap27 : PRE_first_tail_x6_r0_body.s276.heap = PRE_first_tail_x6_r0_body.st27.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext27 : PRE_first_tail_x6_r0_body.s276.next = PRE_first_tail_x6_r0_body.st27.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl27 : PRE_first_tail_x6_r0_body.s276.ctl = PRE_first_tail_x6_r0_body.st27.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack27 : PRE_first_tail_x6_r0_body.s276.stack = PRE_first_tail_x6_r0_body.st27.s5.stack ++ PRE_first_tail_x6_r0_body.s275.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs27 : PRE_first_tail_x6_r0_body.s276.jobs = PRE_first_tail_x6_r0_body.st27.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi27 : PRE_first_tail_x6_r0_body.s276.ffi = PRE_first_tail_x6_r0_body.st27.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace27 : PRE_first_tail_x6_r0_body.s276.trace = PRE_first_tail_x6_r0_body.st27.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores27 : PRE_first_tail_x6_r0_body.s276.stores = PRE_first_tail_x6_r0_body.st27.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD27
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 27 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived27 : PRE_first_tail_x6_r0_body.nr27.map (fun r => nth? PRE_first_tail_x6_r0_body.st27.S5.tab r) =
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
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo27 : PRE_first_tail_x6_r0_body.nr27.all (Nat.ble 1238) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj27 : PRE_first_tail_x6_r0_body.cws27.all (fun c => !PRE_first_tail_x6_r0_body.ws27.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ27 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws27 PRE_first_tail_x6_r0_body.crs27 PRE_first_tail_x6_r0_body.ws27

end Host.Load.Run.Tpl
end

section -- st27/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st27`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st27.wrR : List (Nat × Nat) := [(2672367, 2672368), (2695717, 2695718), (2696262, 2696263), (2696518, 2696519)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st27.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st27.s5.heap PRE_first_tail_x6_r0_body.st27.wrR ++ freshOf PRE_first_tail_x6_r0_body.st27.s5.heap PRE_first_tail_x6_r0_body.st27.s0.next PRE_first_tail_x6_r0_body.st27.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st27.wr : List Nat := PRE_first_tail_x6_r0_body.st27.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st27.heapFoot : PRE_first_tail_x6_r0_body.st27.s5.heap = setAll PRE_first_tail_x6_r0_body.st27.s0.heap PRE_first_tail_x6_r0_body.st27.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st27.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st27.s0.next PRE_first_tail_x6_r0_body.st27.s5.next = true
theorem PRE_first_tail_x6_r0_body.st27.grows : PRE_first_tail_x6_r0_body.st27.s0.next ≤ PRE_first_tail_x6_r0_body.st27.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st27.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st27.wh : List Nat := [18725, 18738, 18744, 18745, 18746, 18747, 18748, 18749, 18750, 18751, 18752, 18753, 18754, 18755, 18756, 18757, 18758, 18759, 18760, 18761, 18762, 18763, 18764, 18765, 18766, 18767, 18768, 18769, 18770, 18771, 18772]
def PRE_first_tail_x6_r0_body.st27.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st27.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st27.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st27.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st27.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st27.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st27.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st27.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st27.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st27.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF27
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 27 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB27 : nodupT PRE_first_tail_x6_r0_body.st27.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup27 : PRE_first_tail_x6_r0_body.st27.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB27).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB27 : PRE_first_tail_x6_r0_body.st27.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound27 : ∀ b ∈ PRE_first_tail_x6_r0_body.st27.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB27 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr27 := PRE_first_tail_x6_r0_body.st27.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq27 : PRE_first_tail_x6_r0_body.st27.s5.trace = PRE_first_tail_x6_r0_body.trFr27 ++ PRE_first_tail_x6_r0_body.st27.s0.trace
theorem PRE_first_tail_x6_r0_body.trace27 : ∃ fr, PRE_first_tail_x6_r0_body.st27.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st27.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq27⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide27 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB27 : (PRE_first_tail_x6_r0_body.wide27.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st27.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix27 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide27, WFix Map.id (Present PRE_first_tail_x6_r0_body.st27.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB27 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL27
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 27 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s276`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO27 : PRE_first_tail_x6_r0_body.st27.S0.oracle = PRE_first_tail_x6_r0_body.st27.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B27 : PRE_first_tail_x6_r0_body.st27.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st27.s0.next || (PRE_first_tail_x6_r0_body.st27.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot27 : Conv.StageFoot PRE_first_tail_x6_r0_body.st27.wr PRE_first_tail_x6_r0_body.st27.s0 PRE_first_tail_x6_r0_body.st27.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st27.heapFoot PRE_first_tail_x6_r0_body.wrNodup27 PRE_first_tail_x6_r0_body.wrBound27 PRE_first_tail_x6_r0_body.wr0B27 PRE_first_tail_x6_r0_body.st27.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged27 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st27.F.S → PRE_first_tail_x6_r0_body.st27.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st27.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st27.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs27 PRE_first_tail_x6_r0_body.st27.wr PRE_first_tail_x6_r0_body.s275 PRE_first_tail_x6_r0_body.st27.s5 PRE_first_tail_x6_r0_body.st27.s0
      PRE_first_tail_x6_r0_body.st27.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st27.F FR W stk M ν K PRE_first_tail_x6_r0_body.s276 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso27 PRE_first_tail_x6_r0_body.stFoot27 PRE_first_tail_x6_r0_body.wrNodup27 PRE_first_tail_x6_r0_body.wrBound27 PRE_first_tail_x6_r0_body.trace27 PRE_first_tail_x6_r0_body.mheap27
    PRE_first_tail_x6_r0_body.mnext27 PRE_first_tail_x6_r0_body.mctl27 PRE_first_tail_x6_r0_body.mstack27 PRE_first_tail_x6_r0_body.mjobs27 PRE_first_tail_x6_r0_body.mffi27 PRE_first_tail_x6_r0_body.mtrace27 PRE_first_tail_x6_r0_body.mstores27 h

def PRE_first_tail_x6_r0_body.arrEl27_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE27_2665 : arrOf PRE_first_tail_x6_r0_body.s276 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl27_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA27_2665 : isArrB PRE_first_tail_x6_r0_body.s276 2665 = true
theorem PRE_first_tail_x6_r0_body.arr27_2665 : ∃ o, PRE_first_tail_x6_r0_body.s276.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl27_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE27_2665 PRE_first_tail_x6_r0_body.arrA27_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN27_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl27_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR27_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl27_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN27_2665

def PRE_first_tail_x6_r0_body.arrEl27_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE27_2673467 : arrOf PRE_first_tail_x6_r0_body.s276 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl27_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA27_2673467 : isArrB PRE_first_tail_x6_r0_body.s276 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr27_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s276.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl27_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE27_2673467 PRE_first_tail_x6_r0_body.arrA27_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN27_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl27_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR27_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl27_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN27_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k27 : isArrB PRE_first_tail_x6_r0_body.s276 4910 = false
theorem PRE_first_tail_x6_r0_body.keep27 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s276 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k27 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr27_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl27_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ27
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 27 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s275`, the merged
state `PRE_first_tail_x6_r0_body.s276`, the canonical state `PRE_first_tail_x6_r0_body.s277`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl27 : PRE_first_tail_x6_r0_body.pl27.all (Nat.ble PRE_first_tail_x6_r0_body.s275.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd27 : nodupT PRE_first_tail_x6_r0_body.pl27 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn127 : Nat.ble PRE_first_tail_x6_r0_body.s275.next 2697698 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst27 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s275.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn27 : PRE_first_tail_x6_r0_body.s277.next = PRE_first_tail_x6_r0_body.s275.next + PRE_first_tail_x6_r0_body.pl27.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn27 : PRE_first_tail_x6_r0_body.s276.next = 2697698
kernel_rfl PRE_first_tail_x6_r0_body.zgrow27 : Nat.ble PRE_first_tail_x6_r0_body.s277.next PRE_first_tail_x6_r0_body.s276.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh27 : PRE_first_tail_x6_r0_body.S275.tab.all (fun e => PRE_first_tail_x6_r0_body.cws27.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd27 : nodupT PRE_first_tail_x6_r0_body.cws27 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi27 : PRE_first_tail_x6_r0_body.nr27.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S276.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt27 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s275.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg27_2665 : PRE_first_tail_x6_r0_body.s277.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s277 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk27_2665 : (objOf PRE_first_tail_x6_r0_body.s277 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm27_2665 : PRE_first_tail_x6_r0_body.s276.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa27.obj (objOf PRE_first_tail_x6_r0_body.s277 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s276 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg27_2673467 : PRE_first_tail_x6_r0_body.s277.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s277 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk27_2673467 : (objOf PRE_first_tail_x6_r0_body.s277 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm27_2673467 : PRE_first_tail_x6_r0_body.s276.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa27.obj (objOf PRE_first_tail_x6_r0_body.s277 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s276 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw27_4910 : (PRE_first_tail_x6_r0_body.s277.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw27_2673472 : (PRE_first_tail_x6_r0_body.s277.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw27_2673473 : (PRE_first_tail_x6_r0_body.s277.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd27 : PRE_first_tail_x6_r0_body.cl27.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr27 : PRE_first_tail_x6_r0_body.st27.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s275.next || PRE_first_tail_x6_r0_body.cl27.contains b) = true
def PRE_first_tail_x6_r0_body.zl27 : List Nat := PRE_first_tail_x6_r0_body.cl27.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE27 : PRE_first_tail_x6_r0_body.zl27.map (fun a => PRE_first_tail_x6_r0_body.s276.heap.get (PRE_first_tail_x6_r0_body.kappa27.a a)) = PRE_first_tail_x6_r0_body.zl27.map (fun a => (PRE_first_tail_x6_r0_body.s277.heap.get a).map PRE_first_tail_x6_r0_body.kappa27.hobj)
theorem PRE_first_tail_x6_r0_body.zimg27 : HeapImg PRE_first_tail_x6_r0_body.kappa27 PRE_first_tail_x6_r0_body.s277 PRE_first_tail_x6_r0_body.s276 PRE_first_tail_x6_r0_body.zl27 := PRE_first_tail_x6_r0_body.zimgE27
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl27 : PRE_first_tail_x6_r0_body.s276.ctl = PRE_first_tail_x6_r0_body.kappa27.ctl PRE_first_tail_x6_r0_body.s277.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack27 : PRE_first_tail_x6_r0_body.s276.stack = PRE_first_tail_x6_r0_body.s277.stack.map PRE_first_tail_x6_r0_body.kappa27.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs27 : PRE_first_tail_x6_r0_body.s276.jobs = PRE_first_tail_x6_r0_body.s277.jobs.map PRE_first_tail_x6_r0_body.kappa27.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores27 : PRE_first_tail_x6_r0_body.s276.stores = PRE_first_tail_x6_r0_body.kappa27.stores PRE_first_tail_x6_r0_body.s277.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots27 : checkRootsSupp PRE_first_tail_x6_r0_body.s277 1256 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC27 : PRE_first_tail_x6_r0_body.S275.tab.length + PRE_first_tail_x6_r0_body.cws27.length = 1256
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap27 : PRE_first_tail_x6_r0_body.kappa27 = Conv.Map.compact PRE_first_tail_x6_r0_body.s275.next 2697698 PRE_first_tail_x6_r0_body.S275.tab.length PRE_first_tail_x6_r0_body.pl27 (PRE_first_tail_x6_r0_body.nr27.map NumV.ref) PRE_first_tail_x6_r0_body.kd27.big
  PRE_first_tail_x6_r0_body.kd27.region PRE_first_tail_x6_r0_body.kd27.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin27 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s277.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc27 : Conv.jcleanListB (⟨18748, 15842, 2696549, 1256⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s277 PRE_first_tail_x6_r0_body.cl27 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB27 : noBigRootsP (fun i => !Conv.oldBigB (⟨18748, 15842, 2696549, 1256⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s277.trace PRE_first_tail_x6_r0_body.s277 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm27 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15815 = true
theorem PRE_first_tail_x6_r0_body.cjcl27 (h : Conv.JClean (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s275) : Conv.JClean (⟨18748, 15842, 2696549, 1256⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s277 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle27)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap27 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd27 a ha)) PRE_first_tail_x6_r0_body.zjc27

end Host.Load.Run.Tpl
end

section -- st27/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st27.bodyLast from PRE_first_tail_x6_r0_body.st27.s4 to PRE_first_tail_x6_r0_body.st27.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st27.F PRE_first_tail_x6_r0_body.st27.s4).run PRE_first_tail_x6_r0_body.st27.S4 = some (PRE_first_tail_x6_r0_body.st27.s5, PRE_first_tail_x6_r0_body.st27.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st27.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st27.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st27.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st27.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st27/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st27.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st27.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st27.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st27.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st27.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st27.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st27.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st27.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st27.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st27.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st27.s0 PRE_first_tail_x6_r0_body.st27.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st27.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st27.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st27.s4 PRE_first_tail_x6_r0_body.st27.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st27/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st27.bodyK0F from PRE_first_tail_x6_r0_body.st27.s0 to PRE_first_tail_x6_r0_body.st27.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st27.F (PRE_first_tail_x6_r0_body.st27.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st27.ks 0).getD 0) PRE_first_tail_x6_r0_body.st27.s0 PRE_first_tail_x6_r0_body.st27.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st27.s1, PRE_first_tail_x6_r0_body.st27.S1)
theorem PRE_first_tail_x6_r0_body.st27.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st27.F (PRE_first_tail_x6_r0_body.st27.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st27.ks 0).getD 0) PRE_first_tail_x6_r0_body.st27.s0 PRE_first_tail_x6_r0_body.st27.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st27.s1, PRE_first_tail_x6_r0_body.st27.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st27.bodyOkLN_ok PRE_first_tail_x6_r0_body.st27.bodyK0F
end Host.Load.Run.Tpl
end

section -- st27/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st27.bodyK1F from PRE_first_tail_x6_r0_body.st27.s1 to PRE_first_tail_x6_r0_body.st27.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st27.F (PRE_first_tail_x6_r0_body.st27.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st27.ks 1).getD 0) PRE_first_tail_x6_r0_body.st27.s1 PRE_first_tail_x6_r0_body.st27.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st27.s2, PRE_first_tail_x6_r0_body.st27.S2)
theorem PRE_first_tail_x6_r0_body.st27.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st27.F (PRE_first_tail_x6_r0_body.st27.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st27.ks 1).getD 0) PRE_first_tail_x6_r0_body.st27.s1 PRE_first_tail_x6_r0_body.st27.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st27.s2, PRE_first_tail_x6_r0_body.st27.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st27.bodyOkLN_ok PRE_first_tail_x6_r0_body.st27.bodyK1F
end Host.Load.Run.Tpl
end

section -- st27/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st27.bodyK2F from PRE_first_tail_x6_r0_body.st27.s2 to PRE_first_tail_x6_r0_body.st27.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st27.F (PRE_first_tail_x6_r0_body.st27.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st27.ks 2).getD 0) PRE_first_tail_x6_r0_body.st27.s2 PRE_first_tail_x6_r0_body.st27.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st27.s3, PRE_first_tail_x6_r0_body.st27.S3)
theorem PRE_first_tail_x6_r0_body.st27.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st27.F (PRE_first_tail_x6_r0_body.st27.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st27.ks 2).getD 0) PRE_first_tail_x6_r0_body.st27.s2 PRE_first_tail_x6_r0_body.st27.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st27.s3, PRE_first_tail_x6_r0_body.st27.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st27.bodyOkLN_ok PRE_first_tail_x6_r0_body.st27.bodyK2F
end Host.Load.Run.Tpl
end

section -- st27/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st27.bodyK3F from PRE_first_tail_x6_r0_body.st27.s3 to PRE_first_tail_x6_r0_body.st27.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st27.F (PRE_first_tail_x6_r0_body.st27.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st27.ks 3).getD 0) PRE_first_tail_x6_r0_body.st27.s3 PRE_first_tail_x6_r0_body.st27.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st27.s4, PRE_first_tail_x6_r0_body.st27.S4)
theorem PRE_first_tail_x6_r0_body.st27.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st27.F (PRE_first_tail_x6_r0_body.st27.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st27.ks 3).getD 0) PRE_first_tail_x6_r0_body.st27.s3 PRE_first_tail_x6_r0_body.st27.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st27.s4, PRE_first_tail_x6_r0_body.st27.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st27.bodyOkLN_ok PRE_first_tail_x6_r0_body.st27.bodyK3F
end Host.Load.Run.Tpl
end

section -- st27/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st27.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st27.F (PRE_first_tail_x6_r0_body.st27.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st27.s0 PRE_first_tail_x6_r0_body.st27.S0 = some (PRE_first_tail_x6_r0_body.st27.s4, PRE_first_tail_x6_r0_body.st27.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st27.F (PRE_first_tail_x6_r0_body.st27.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st27.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st27.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st27.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st27.ks 3).getD 0) PRE_first_tail_x6_r0_body.st27.s0 PRE_first_tail_x6_r0_body.st27.s3 PRE_first_tail_x6_r0_body.st27.s4 PRE_first_tail_x6_r0_body.st27.S0 PRE_first_tail_x6_r0_body.st27.S3 PRE_first_tail_x6_r0_body.st27.S4 (runOk_trans PRE_first_tail_x6_r0_body.st27.F (PRE_first_tail_x6_r0_body.st27.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st27.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st27.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st27.ks 2).getD 0) PRE_first_tail_x6_r0_body.st27.s0 PRE_first_tail_x6_r0_body.st27.s2 PRE_first_tail_x6_r0_body.st27.s3 PRE_first_tail_x6_r0_body.st27.S0 PRE_first_tail_x6_r0_body.st27.S2 PRE_first_tail_x6_r0_body.st27.S3 (runOk_trans PRE_first_tail_x6_r0_body.st27.F (PRE_first_tail_x6_r0_body.st27.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st27.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st27.ks 1).getD 0) PRE_first_tail_x6_r0_body.st27.s0 PRE_first_tail_x6_r0_body.st27.s1 PRE_first_tail_x6_r0_body.st27.s2 PRE_first_tail_x6_r0_body.st27.S0 PRE_first_tail_x6_r0_body.st27.S1 PRE_first_tail_x6_r0_body.st27.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st27.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st27.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st27.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st27.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st27.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st27.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st27.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st27.F (PRE_first_tail_x6_r0_body.st27.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st27.s0
  S0 := PRE_first_tail_x6_r0_body.st27.S0
  s1 := PRE_first_tail_x6_r0_body.st27.s4
  S1 := PRE_first_tail_x6_r0_body.st27.S4
  s2 := PRE_first_tail_x6_r0_body.st27.s5
  S2 := PRE_first_tail_x6_r0_body.st27.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st27.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st27.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st27.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st27.bodyHalt
  last := PRE_first_tail_x6_r0_body.st27.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st27.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC28
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 28 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s285` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa28` into the merged state
`PRE_first_tail_x6_r0_body.s284`. -/

def PRE_first_tail_x6_r0_body.pl28 : List Nat := []
def PRE_first_tail_x6_r0_body.nr28 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd28 : RData :=
  ⟨2697039, 2697041, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18761, 18761, 15855, 15855, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa28 : Map :=
  Conv.Map.compact 2697039 2697041 1277 PRE_first_tail_x6_r0_body.pl28 (PRE_first_tail_x6_r0_body.nr28.map NumV.ref) PRE_first_tail_x6_r0_body.kd28.big
    PRE_first_tail_x6_r0_body.kd28.region PRE_first_tail_x6_r0_body.kd28.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws28 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs28 : List SymE := PRE_first_tail_x6_r0_body.nr28.map fun r => (nth? PRE_first_tail_x6_r0_body.S284.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta28 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws28 PRE_first_tail_x6_r0_body.crs28
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB28 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab28 : PRE_first_tail_x6_r0_body.S285.tab = PRE_first_tail_x6_r0_body.S283.tab ++ PRE_first_tail_x6_r0_body.cws28.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace28 : PRE_first_tail_x6_r0_body.s285.trace = PRE_first_tail_x6_r0_body.s283.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext28 : PRE_first_tail_x6_r0_body.s285.next = 2697039
kernel_rfl PRE_first_tail_x6_r0_body.ccounters28 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx.nnext) = (18761, 15855)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue28 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s284.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa28.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp28 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx.tokens.all (bSN 1277) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean28 : Conv.cleanListB 18761 131072 (fun r => Nat.ble 75044 r) PRE_first_tail_x6_r0_body.s285
    (PRE_first_tail_x6_r0_body.wrB28 ++ (List.range 0).map (2697039 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs28 : bigsOutB 18761 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK28
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl28`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl28 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo28 : List Nat := []
def PRE_first_tail_x6_r0_body.cln28 : List Nat := []
def PRE_first_tail_x6_r0_body.cli28 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap28 : PRE_first_tail_x6_r0_body.s285.heap = Stage.setAll PRE_first_tail_x6_r0_body.s283.heap (PRE_first_tail_x6_r0_body.cl28.filterMap fun a => (PRE_first_tail_x6_r0_body.s285.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe28 : Nat.ble PRE_first_tail_x6_r0_body.s283.next PRE_first_tail_x6_r0_body.s285.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP28 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s283 PRE_first_tail_x6_r0_body.s285 PRE_first_tail_x6_r0_body.cl28 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp28 : Conv.suppListB PRE_first_tail_x6_r0_body.s285 1277 PRE_first_tail_x6_r0_body.cl28 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound28 : Conv.boundListB PRE_first_tail_x6_r0_body.s285 PRE_first_tail_x6_r0_body.cl28 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK28 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln28.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK28 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo28.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK28 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli28.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst28 : Conv.sstListB 1277 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx PRE_first_tail_x6_r0_body.cln28 PRE_first_tail_x6_r0_body.clo28 PRE_first_tail_x6_r0_body.cli28 = true

end Host.Load.Run.Tpl
end

section -- SiteCl28
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA28 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo28.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd28 : (PRE_first_tail_x6_r0_body.clo28 ++ PRE_first_tail_x6_r0_body.cln28 ++ PRE_first_tail_x6_r0_body.cli28).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle28 : Conv.Cnt.leB (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck28 : Conv.ncleanListB (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx PRE_first_tail_x6_r0_body.clo28 PRE_first_tail_x6_r0_body.cln28 PRE_first_tail_x6_r0_body.cli28 = true
theorem PRE_first_tail_x6_r0_body.cncl28 (h : Conv.NClean (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx) : Conv.NClean (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle28 PRE_first_tail_x6_r0_body.ckA28 PRE_first_tail_x6_r0_body.cobjsK28 PRE_first_tail_x6_r0_body.cnodesK28 PRE_first_tail_x6_r0_body.citemsK28 PRE_first_tail_x6_r0_body.cbd28 PRE_first_tail_x6_r0_body.cck28

end Host.Load.Run.Tpl
end

section -- SiteS28
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 28 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc28 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P28 : LoadP := PRE_first_tail_x6_r0_body.Pc28.raise 15855
kernel_rfl PRE_first_tail_x6_r0_body.craise28 : Nat.ble PRE_first_tail_x6_r0_body.Pc28.N0 15855 = true
theorem PRE_first_tail_x6_r0_body.raised28 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc28 PRE_first_tail_x6_r0_body.P28 :=
  .inr ⟨15855, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise28, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_28 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_28 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s284.ffi)
def PRE_first_tail_x6_r0_body.khinv28 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv28 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS28 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS28 : List Nat := List.range' 15855 0
def PRE_first_tail_x6_r0_body.ciS28 : List Nat := [] ++ List.range' 15855 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh028 : PRE_first_tail_x6_r0_body.kd28.nh0 = PRE_first_tail_x6_r0_body.cx0_28.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh128 : PRE_first_tail_x6_r0_body.kd28.nh1 = PRE_first_tail_x6_r0_body.cx1_28.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn028 : PRE_first_tail_x6_r0_body.kd28.nn0 = PRE_first_tail_x6_r0_body.cx0_28.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn128 : PRE_first_tail_x6_r0_body.kd28.nn1 = PRE_first_tail_x6_r0_body.cx1_28.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo28 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P28.lo && Nat.ble PRE_first_tail_x6_r0_body.P28.lo PRE_first_tail_x6_r0_body.cx0_28.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P28.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P28.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt28 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_28.mlx.next PRE_first_tail_x6_r0_body.cx1_28.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_28.mlx.nnext PRE_first_tail_x6_r0_body.cx1_28.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband28 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P28.NL && Nat.ble PRE_first_tail_x6_r0_body.P28.NL PRE_first_tail_x6_r0_body.P28.N0 && Nat.ble PRE_first_tail_x6_r0_body.P28.N0 PRE_first_tail_x6_r0_body.cx0_28.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow28 : PRE_first_tail_x6_r0_body.kd28.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren28 : checkRenG PRE_first_tail_x6_r0_body.kd28.hnd PRE_first_tail_x6_r0_body.khinv28 (phB PRE_first_tail_x6_r0_body.cx0_28.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband28 : PRE_first_tail_x6_r0_body.kd28.checkBand PRE_first_tail_x6_r0_body.P28.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos28 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd28.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren28 : checkRenG PRE_first_tail_x6_r0_body.kd28.node PRE_first_tail_x6_r0_body.kninv28 (pnB PRE_first_tail_x6_r0_body.cx0_28.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow28 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd28.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P28.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd28.nodeF j) PRE_first_tail_x6_r0_body.cx1_28.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a28 : PRE_first_tail_x6_r0_body.cx0_28.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b28 : PRE_first_tail_x6_r0_body.cx0_28.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok128 : PRE_first_tail_x6_r0_body.cx1_28.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend28 : PRE_first_tail_x6_r0_body.cx1_28.mlx.pending = PRE_first_tail_x6_r0_body.cx0_28.mlx.pending.map PRE_first_tail_x6_r0_body.kappa28.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh28 : PRE_first_tail_x6_r0_body.cx1_28.mlx.errh = PRE_first_tail_x6_r0_body.cx0_28.mlx.errh.map PRE_first_tail_x6_r0_body.kappa28.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles28 : PRE_first_tail_x6_r0_body.cx1_28.mlx.files = PRE_first_tail_x6_r0_body.cx0_28.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch28 : PRE_first_tail_x6_r0_body.cx1_28.mlx.arch = PRE_first_tail_x6_r0_body.cx0_28.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes28 : PRE_first_tail_x6_r0_body.cx1_28.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_28.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired28 : PRE_first_tail_x6_r0_body.cx1_28.mlx.wired = PRE_first_tail_x6_r0_body.cx0_28.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost28 : PRE_first_tail_x6_r0_body.cx1_28.host = PRE_first_tail_x6_r0_body.cx0_28.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd28`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn028 : PRE_first_tail_x6_r0_body.kd28.n0 = 2697039
kernel_rfl PRE_first_tail_x6_r0_body.ckn128 : PRE_first_tail_x6_r0_body.kd28.n1 = 2697041
kernel_rfl PRE_first_tail_x6_r0_body.ckheap28 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd28.heap).all (fun x => Nat.ble 2697039 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl28 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd28.heap.get (2697039 + j) = nth? PRE_first_tail_x6_r0_body.pl28 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja28 : Nat.ble 2697039 2697039 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn28 : Nat.ble 1277 1277 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD28 : Nat.ble 2697039 PRE_first_tail_x6_r0_body.kd28.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn28 : Nat.ble 18761 PRE_first_tail_x6_r0_body.kd28.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn28 : Nat.ble 15855 PRE_first_tail_x6_r0_body.kd28.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb28 : Nat.ble 18761 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap28 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd28.heap).all (Nat.ble (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd28 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd28.hnd).all (Nat.ble (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode28 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd28.node).all (Nat.ble (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix28 : Conv.FixOld (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa28 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja28) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn28) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD28) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn28) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn28) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb28) PRE_first_tail_x6_r0_body.fheap28 PRE_first_tail_x6_r0_body.fhnd28 PRE_first_tail_x6_r0_body.fnode28
kernel_rfl PRE_first_tail_x6_r0_body.fcxn28 : (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn28 : (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle028 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_28.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_28.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk28 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd28.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A28 : PRE_first_tail_x6_r0_body.cx1_28.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS28.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_28.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O28 : PRE_first_tail_x6_r0_body.cx1_28.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS28.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_28.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N28 : PRE_first_tail_x6_r0_body.cx1_28.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS28.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_28.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I28 : PRE_first_tail_x6_r0_body.cx1_28.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS28.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_28.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd28 : (PRE_first_tail_x6_r0_body.clo28 ++ PRE_first_tail_x6_r0_body.cln28 ++ PRE_first_tail_x6_r0_body.cli28 ++ PRE_first_tail_x6_r0_body.cwS28 ++ PRE_first_tail_x6_r0_body.cnS28 ++ PRE_first_tail_x6_r0_body.ciS28).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW28 : PRE_first_tail_x6_r0_body.cwS28.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo28.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI28 : PRE_first_tail_x6_r0_body.ciS28.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli28.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN28 : PRE_first_tail_x6_r0_body.cnS28.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF28 : PRE_first_tail_x6_r0_body.cln28.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh28 : PRE_first_tail_x6_r0_body.clo28.all (handleOK PRE_first_tail_x6_r0_body.kappa28 PRE_first_tail_x6_r0_body.P28.lo PRE_first_tail_x6_r0_body.cx0_28.mlx PRE_first_tail_x6_r0_body.cx1_28.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo28 : PRE_first_tail_x6_r0_body.clo28.map (fun h => PRE_first_tail_x6_r0_body.cx1_28.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa28.handle h)) = PRE_first_tail_x6_r0_body.clo28.map (fun h => (PRE_first_tail_x6_r0_body.cx0_28.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa28.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok28 : PRE_first_tail_x6_r0_body.clo28.all (objOK PRE_first_tail_x6_r0_body.kappa28 PRE_first_tail_x6_r0_body.P28.NL PRE_first_tail_x6_r0_body.cx0_28.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd28 : PRE_first_tail_x6_r0_body.cln28.all (nodeOKF PRE_first_tail_x6_r0_body.kappa28 PRE_first_tail_x6_r0_body.P28 PRE_first_tail_x6_r0_body.cx0_28.mlx PRE_first_tail_x6_r0_body.cx1_28.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp28 : ((PRE_first_tail_x6_r0_body.cln28.filter (fullB PRE_first_tail_x6_r0_body.P28))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_28.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa28.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln28.filter (fullB PRE_first_tail_x6_r0_body.P28))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_28.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa28.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI28 : incrB PRE_first_tail_x6_r0_body.kd28.nodeF (List.range' 15855 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK28 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd28.node).all (fun k => Nat.ble 15855 k && Nat.blt k 15855) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL28 : (PRE_first_tail_x6_r0_body.cln28.filter (Nat.ble PRE_first_tail_x6_r0_body.P28.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd28.nodeF i) && (Nat.blt i 15855 || Nat.ble PRE_first_tail_x6_r0_body.kd28.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord28 : (PRE_first_tail_x6_r0_body.cln28.filter (Nat.ble PRE_first_tail_x6_r0_body.P28.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd28.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd28.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd28.nodeF j) (PRE_first_tail_x6_r0_body.kd28.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow28 PRE_first_tail_x6_r0_body.cnn128 PRE_first_tail_x6_r0_body.fnordI28 PRE_first_tail_x6_r0_body.fnordK28 PRE_first_tail_x6_r0_body.fnordL28
kernel_rfl PRE_first_tail_x6_r0_body.fi28 : PRE_first_tail_x6_r0_body.cli28.all (pnB PRE_first_tail_x6_r0_body.cx0_28.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii28 : PRE_first_tail_x6_r0_body.cli28.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_28.mlx.items.get (PRE_first_tail_x6_r0_body.kappa28.node k) = (PRE_first_tail_x6_r0_body.cx0_28.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa28.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot28 (clean : Conv.NClean (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P28.NL) (cl : SSt (· < 1277) PRE_first_tail_x6_r0_body.cx0_28.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P28 1277 PRE_first_tail_x6_r0_body.kappa28 PRE_first_tail_x6_r0_body.kd28 PRE_first_tail_x6_r0_body.khinv28 PRE_first_tail_x6_r0_body.kninv28 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx PRE_first_tail_x6_r0_body.cx0_28.mlx PRE_first_tail_x6_r0_body.cx1_28.mlx (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo28 PRE_first_tail_x6_r0_body.cln28 PRE_first_tail_x6_r0_body.cli28 PRE_first_tail_x6_r0_body.cwS28 PRE_first_tail_x6_r0_body.cnS28 PRE_first_tail_x6_r0_body.ciS28 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh028, PRE_first_tail_x6_r0_body.cnh128, PRE_first_tail_x6_r0_body.cnn028, PRE_first_tail_x6_r0_body.cnn128, PRE_first_tail_x6_r0_body.cplo28, PRE_first_tail_x6_r0_body.ccnt28, PRE_first_tail_x6_r0_body.cnband28, PRE_first_tail_x6_r0_body.chbelow28, PRE_first_tail_x6_r0_body.chren28, PRE_first_tail_x6_r0_body.cband28, PRE_first_tail_x6_r0_body.cnh1pos28, PRE_first_tail_x6_r0_body.cnren28, PRE_first_tail_x6_r0_body.cnlow28, PRE_first_tail_x6_r0_body.cabs0a28, PRE_first_tail_x6_r0_body.cabs0b28, PRE_first_tail_x6_r0_body.ctok128, PRE_first_tail_x6_r0_body.cpend28, PRE_first_tail_x6_r0_body.cerrh28, PRE_first_tail_x6_r0_body.cfiles28, PRE_first_tail_x6_r0_body.carch28, PRE_first_tail_x6_r0_body.csizes28, PRE_first_tail_x6_r0_body.cwired28, PRE_first_tail_x6_r0_body.cfix28, clean, PRE_first_tail_x6_r0_body.fcxn28, PRE_first_tail_x6_r0_body.fcnn28, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle028, PRE_first_tail_x6_r0_body.fnk28, PRE_first_tail_x6_r0_body.ckA28, PRE_first_tail_x6_r0_body.cobjsK28, PRE_first_tail_x6_r0_body.cnodesK28, PRE_first_tail_x6_r0_body.citemsK28, PRE_first_tail_x6_r0_body.f1A28, PRE_first_tail_x6_r0_body.f1O28, PRE_first_tail_x6_r0_body.f1N28, PRE_first_tail_x6_r0_body.f1I28, PRE_first_tail_x6_r0_body.fbd28, PRE_first_tail_x6_r0_body.fincW28, PRE_first_tail_x6_r0_body.fincI28, PRE_first_tail_x6_r0_body.fincN28, PRE_first_tail_x6_r0_body.flnF28, PRE_first_tail_x6_r0_body.fh28, PRE_first_tail_x6_r0_body.fo28, PRE_first_tail_x6_r0_body.fok28, PRE_first_tail_x6_r0_body.fnd28, PRE_first_tail_x6_r0_body.fp28, PRE_first_tail_x6_r0_body.fnord28, PRE_first_tail_x6_r0_body.fi28, PRE_first_tail_x6_r0_body.fii28⟩
theorem PRE_first_tail_x6_r0_body.cnshift28 (clean : Conv.NClean (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P28.NL) (cl : SSt (· < 1277) PRE_first_tail_x6_r0_body.cx0_28.mlx) : NShift PRE_first_tail_x6_r0_body.P28 1277 PRE_first_tail_x6_r0_body.kappa28 PRE_first_tail_x6_r0_body.cx0_28 PRE_first_tail_x6_r0_body.cx1_28 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot28 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost28 (compact_a_eq PRE_first_tail_x6_r0_body.ckn028 PRE_first_tail_x6_r0_body.ckn128 PRE_first_tail_x6_r0_body.ckheap28 PRE_first_tail_x6_r0_body.ckpl28)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_28 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s283.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_28 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s283.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_28 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s283.ffi) = some PRE_first_tail_x6_r0_body.fxC_28
kernel_rfl PRE_first_tail_x6_r0_body.okrC_28 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s283.ffi) = some PRE_first_tail_x6_r0_body.krC_28
noncomputable def PRE_first_tail_x6_r0_body.fx0_28 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s285.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_28 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s285.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_28 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s285.ffi) = some PRE_first_tail_x6_r0_body.fx0_28
kernel_rfl PRE_first_tail_x6_r0_body.okr0_28 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s285.ffi) = some PRE_first_tail_x6_r0_body.kr0_28
noncomputable def PRE_first_tail_x6_r0_body.fx1_28 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s284.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_28 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s284.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_28 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s284.ffi) = some PRE_first_tail_x6_r0_body.fx1_28
kernel_rfl PRE_first_tail_x6_r0_body.okr1_28 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s284.ffi) = some PRE_first_tail_x6_r0_body.kr1_28
kernel_rfl PRE_first_tail_x6_r0_body.ff028 : PRE_first_tail_x6_r0_body.fx0_28 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_28 (PRE_first_tail_x6_r0_body.clo28.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_28.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff128 : PRE_first_tail_x6_r0_body.fx1_28 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_28 (PRE_first_tail_x6_r0_body.cwS28.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_28.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck28 : freedLB PRE_first_tail_x6_r0_body.kappa28 PRE_first_tail_x6_r0_body.cx0_28.mlx PRE_first_tail_x6_r0_body.fx0_28 PRE_first_tail_x6_r0_body.fx1_28 PRE_first_tail_x6_r0_body.clo28 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf028 : PRE_first_tail_x6_r0_body.kr0_28.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_28.flags (PRE_first_tail_x6_r0_body.clo28.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_28.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt028 : PRE_first_tail_x6_r0_body.kr0_28.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_28.targs (PRE_first_tail_x6_r0_body.clo28.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_28.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf128 : PRE_first_tail_x6_r0_body.kr1_28.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_28.flags (PRE_first_tail_x6_r0_body.cwS28.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_28.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt128 : PRE_first_tail_x6_r0_body.kr1_28.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_28.targs (PRE_first_tail_x6_r0_body.cwS28.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_28.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck28 : krecLB PRE_first_tail_x6_r0_body.kappa28 1277 PRE_first_tail_x6_r0_body.cx0_28.mlx PRE_first_tail_x6_r0_body.kr0_28 PRE_first_tail_x6_r0_body.kr1_28 PRE_first_tail_x6_r0_body.clo28 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn28 : Nat.ble 1277 1277 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge28 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s284.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s285.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR28 : pendRegB PRE_first_tail_x6_r0_body.kappa28 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe28 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s284.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift28 (clean : Conv.NClean (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P28.NL) (cl : SSt (· < 1277) PRE_first_tail_x6_r0_body.cx0_28.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_28.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_28.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_28.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_28.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P28 1277 PRE_first_tail_x6_r0_body.kappa28 PRE_first_tail_x6_r0_body.s285.ffi PRE_first_tail_x6_r0_body.s284.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift28 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue28, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp28 t ht),
    PRE_first_tail_x6_r0_body.cbridge28,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s285.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s284.ffi) (PRE_first_tail_x6_r0_body.cfoot28 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_28 PRE_first_tail_x6_r0_body.ofx1_28 hobjC PRE_first_tail_x6_r0_body.ff028 PRE_first_tail_x6_r0_body.ff128 PRE_first_tail_x6_r0_body.ffck28,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s285.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s284.ffi) (PRE_first_tail_x6_r0_body.cfoot28 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_28 PRE_first_tail_x6_r0_body.okr1_28 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn28) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf028 PRE_first_tail_x6_r0_body.fkt028 PRE_first_tail_x6_r0_body.fkf128 PRE_first_tail_x6_r0_body.fkt128 PRE_first_tail_x6_r0_body.fkck28,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh028 PRE_first_tail_x6_r0_body.cnh128 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe28) PRE_first_tail_x6_r0_body.cpendR28⟩

end Host.Load.Run.Tpl
end

section -- st28/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st28 0
host_stream_state PRE_first_tail_x6_r0_body.st28 1
host_stream_state PRE_first_tail_x6_r0_body.st28 2
end Host.Load.Run.Tpl
end

section -- Site28
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 28 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g28__g29` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s283`, the merged state `PRE_first_tail_x6_r0_body.s284`,
the site template `PRE_first_tail_x6_r0_body.st28` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s285`: the merge.
The footprint's facts are in `SiteF28`, the compaction's in `SiteC28`, `SiteK28`, `SiteNa28`, `SiteNb28`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso28 : PRE_first_tail_x6_r0_body.st28.s0 = { PRE_first_tail_x6_r0_body.s283 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs28 : List Frame := PRE_first_tail_x6_r0_body.s283.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_28 : PRE_first_tail_x6_r0_body.S283.tab.length = 1277
kernel_rfl PRE_first_tail_x6_r0_body.tab0_28 : PRE_first_tail_x6_r0_body.st28.S0.tab = PRE_first_tail_x6_r0_body.S283.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws28 : List Nat := [1495, 1496]
kernel_rfl PRE_first_tail_x6_r0_body.fresh28 : (PRE_first_tail_x6_r0_body.S283.tab.all fun e => PRE_first_tail_x6_r0_body.ws28.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S283.oracle.all fun q => PRE_first_tail_x6_r0_body.ws28.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab28 : PRE_first_tail_x6_r0_body.S284.tab = PRE_first_tail_x6_r0_body.S283.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws28
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen28 : PRE_first_tail_x6_r0_body.st28.S2.tab.length - PRE_first_tail_x6_r0_body.st28.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged28`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap28 : PRE_first_tail_x6_r0_body.s284.heap = PRE_first_tail_x6_r0_body.st28.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext28 : PRE_first_tail_x6_r0_body.s284.next = PRE_first_tail_x6_r0_body.st28.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl28 : PRE_first_tail_x6_r0_body.s284.ctl = PRE_first_tail_x6_r0_body.st28.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack28 : PRE_first_tail_x6_r0_body.s284.stack = PRE_first_tail_x6_r0_body.st28.s2.stack ++ PRE_first_tail_x6_r0_body.s283.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs28 : PRE_first_tail_x6_r0_body.s284.jobs = PRE_first_tail_x6_r0_body.st28.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi28 : PRE_first_tail_x6_r0_body.s284.ffi = PRE_first_tail_x6_r0_body.st28.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace28 : PRE_first_tail_x6_r0_body.s284.trace = PRE_first_tail_x6_r0_body.st28.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores28 : PRE_first_tail_x6_r0_body.s284.stores = PRE_first_tail_x6_r0_body.st28.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD28
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 28 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived28 : PRE_first_tail_x6_r0_body.nr28.map (fun r => nth? PRE_first_tail_x6_r0_body.st28.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo28 : PRE_first_tail_x6_r0_body.nr28.all (Nat.ble 1277) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj28 : PRE_first_tail_x6_r0_body.cws28.all (fun c => !PRE_first_tail_x6_r0_body.ws28.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ28 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws28 PRE_first_tail_x6_r0_body.crs28 PRE_first_tail_x6_r0_body.ws28

end Host.Load.Run.Tpl
end

section -- st28/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st28`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st28.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st28.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st28.s2.heap PRE_first_tail_x6_r0_body.st28.wrR ++ freshOf PRE_first_tail_x6_r0_body.st28.s2.heap PRE_first_tail_x6_r0_body.st28.s0.next PRE_first_tail_x6_r0_body.st28.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st28.wr : List Nat := PRE_first_tail_x6_r0_body.st28.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st28.heapFoot : PRE_first_tail_x6_r0_body.st28.s2.heap = setAll PRE_first_tail_x6_r0_body.st28.s0.heap PRE_first_tail_x6_r0_body.st28.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st28.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st28.s0.next PRE_first_tail_x6_r0_body.st28.s2.next = true
theorem PRE_first_tail_x6_r0_body.st28.grows : PRE_first_tail_x6_r0_body.st28.s0.next ≤ PRE_first_tail_x6_r0_body.st28.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st28.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st28.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st28.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st28.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st28.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st28.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st28.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st28.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st28.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st28.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st28.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st28.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF28
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 28 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB28 : nodupT PRE_first_tail_x6_r0_body.st28.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup28 : PRE_first_tail_x6_r0_body.st28.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB28).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB28 : PRE_first_tail_x6_r0_body.st28.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound28 : ∀ b ∈ PRE_first_tail_x6_r0_body.st28.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB28 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr28 := PRE_first_tail_x6_r0_body.st28.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq28 : PRE_first_tail_x6_r0_body.st28.s2.trace = PRE_first_tail_x6_r0_body.trFr28 ++ PRE_first_tail_x6_r0_body.st28.s0.trace
theorem PRE_first_tail_x6_r0_body.trace28 : ∃ fr, PRE_first_tail_x6_r0_body.st28.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st28.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq28⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide28 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB28 : (PRE_first_tail_x6_r0_body.wide28.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st28.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix28 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide28, WFix Map.id (Present PRE_first_tail_x6_r0_body.st28.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB28 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL28
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 28 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s284`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO28 : PRE_first_tail_x6_r0_body.st28.S0.oracle = PRE_first_tail_x6_r0_body.st28.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B28 : PRE_first_tail_x6_r0_body.st28.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st28.s0.next || (PRE_first_tail_x6_r0_body.st28.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot28 : Conv.StageFoot PRE_first_tail_x6_r0_body.st28.wr PRE_first_tail_x6_r0_body.st28.s0 PRE_first_tail_x6_r0_body.st28.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st28.heapFoot PRE_first_tail_x6_r0_body.wrNodup28 PRE_first_tail_x6_r0_body.wrBound28 PRE_first_tail_x6_r0_body.wr0B28 PRE_first_tail_x6_r0_body.st28.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged28 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st28.F.S → PRE_first_tail_x6_r0_body.st28.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st28.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st28.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs28 PRE_first_tail_x6_r0_body.st28.wr PRE_first_tail_x6_r0_body.s283 PRE_first_tail_x6_r0_body.st28.s2 PRE_first_tail_x6_r0_body.st28.s0
      PRE_first_tail_x6_r0_body.st28.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st28.F FR W stk M ν K PRE_first_tail_x6_r0_body.s284 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso28 PRE_first_tail_x6_r0_body.stFoot28 PRE_first_tail_x6_r0_body.wrNodup28 PRE_first_tail_x6_r0_body.wrBound28 PRE_first_tail_x6_r0_body.trace28 PRE_first_tail_x6_r0_body.mheap28
    PRE_first_tail_x6_r0_body.mnext28 PRE_first_tail_x6_r0_body.mctl28 PRE_first_tail_x6_r0_body.mstack28 PRE_first_tail_x6_r0_body.mjobs28 PRE_first_tail_x6_r0_body.mffi28 PRE_first_tail_x6_r0_body.mtrace28 PRE_first_tail_x6_r0_body.mstores28 h

def PRE_first_tail_x6_r0_body.arrEl28_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE28_2665 : arrOf PRE_first_tail_x6_r0_body.s284 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl28_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA28_2665 : isArrB PRE_first_tail_x6_r0_body.s284 2665 = true
theorem PRE_first_tail_x6_r0_body.arr28_2665 : ∃ o, PRE_first_tail_x6_r0_body.s284.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl28_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE28_2665 PRE_first_tail_x6_r0_body.arrA28_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN28_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl28_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR28_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl28_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN28_2665

def PRE_first_tail_x6_r0_body.arrEl28_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE28_2673467 : arrOf PRE_first_tail_x6_r0_body.s284 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl28_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA28_2673467 : isArrB PRE_first_tail_x6_r0_body.s284 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr28_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s284.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl28_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE28_2673467 PRE_first_tail_x6_r0_body.arrA28_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN28_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl28_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR28_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl28_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN28_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k28 : isArrB PRE_first_tail_x6_r0_body.s284 4910 = false
theorem PRE_first_tail_x6_r0_body.keep28 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s284 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k28 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr28_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl28_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ28
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 28 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s283`, the merged
state `PRE_first_tail_x6_r0_body.s284`, the canonical state `PRE_first_tail_x6_r0_body.s285`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl28 : PRE_first_tail_x6_r0_body.pl28.all (Nat.ble PRE_first_tail_x6_r0_body.s283.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd28 : nodupT PRE_first_tail_x6_r0_body.pl28 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn128 : Nat.ble PRE_first_tail_x6_r0_body.s283.next 2697041 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst28 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s283.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn28 : PRE_first_tail_x6_r0_body.s285.next = PRE_first_tail_x6_r0_body.s283.next + PRE_first_tail_x6_r0_body.pl28.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn28 : PRE_first_tail_x6_r0_body.s284.next = 2697041
kernel_rfl PRE_first_tail_x6_r0_body.zgrow28 : Nat.ble PRE_first_tail_x6_r0_body.s285.next PRE_first_tail_x6_r0_body.s284.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh28 : PRE_first_tail_x6_r0_body.S283.tab.all (fun e => PRE_first_tail_x6_r0_body.cws28.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd28 : nodupT PRE_first_tail_x6_r0_body.cws28 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi28 : PRE_first_tail_x6_r0_body.nr28.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S284.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt28 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s283.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg28_2665 : PRE_first_tail_x6_r0_body.s285.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s285 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk28_2665 : (objOf PRE_first_tail_x6_r0_body.s285 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm28_2665 : PRE_first_tail_x6_r0_body.s284.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa28.obj (objOf PRE_first_tail_x6_r0_body.s285 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s284 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg28_2673467 : PRE_first_tail_x6_r0_body.s285.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s285 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk28_2673467 : (objOf PRE_first_tail_x6_r0_body.s285 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm28_2673467 : PRE_first_tail_x6_r0_body.s284.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa28.obj (objOf PRE_first_tail_x6_r0_body.s285 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s284 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw28_4910 : (PRE_first_tail_x6_r0_body.s285.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw28_2673472 : (PRE_first_tail_x6_r0_body.s285.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw28_2673473 : (PRE_first_tail_x6_r0_body.s285.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd28 : PRE_first_tail_x6_r0_body.cl28.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr28 : PRE_first_tail_x6_r0_body.st28.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s283.next || PRE_first_tail_x6_r0_body.cl28.contains b) = true
def PRE_first_tail_x6_r0_body.zl28 : List Nat := PRE_first_tail_x6_r0_body.cl28.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE28 : PRE_first_tail_x6_r0_body.zl28.map (fun a => PRE_first_tail_x6_r0_body.s284.heap.get (PRE_first_tail_x6_r0_body.kappa28.a a)) = PRE_first_tail_x6_r0_body.zl28.map (fun a => (PRE_first_tail_x6_r0_body.s285.heap.get a).map PRE_first_tail_x6_r0_body.kappa28.hobj)
theorem PRE_first_tail_x6_r0_body.zimg28 : HeapImg PRE_first_tail_x6_r0_body.kappa28 PRE_first_tail_x6_r0_body.s285 PRE_first_tail_x6_r0_body.s284 PRE_first_tail_x6_r0_body.zl28 := PRE_first_tail_x6_r0_body.zimgE28
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl28 : PRE_first_tail_x6_r0_body.s284.ctl = PRE_first_tail_x6_r0_body.kappa28.ctl PRE_first_tail_x6_r0_body.s285.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack28 : PRE_first_tail_x6_r0_body.s284.stack = PRE_first_tail_x6_r0_body.s285.stack.map PRE_first_tail_x6_r0_body.kappa28.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs28 : PRE_first_tail_x6_r0_body.s284.jobs = PRE_first_tail_x6_r0_body.s285.jobs.map PRE_first_tail_x6_r0_body.kappa28.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores28 : PRE_first_tail_x6_r0_body.s284.stores = PRE_first_tail_x6_r0_body.kappa28.stores PRE_first_tail_x6_r0_body.s285.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots28 : checkRootsSupp PRE_first_tail_x6_r0_body.s285 1277 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC28 : PRE_first_tail_x6_r0_body.S283.tab.length + PRE_first_tail_x6_r0_body.cws28.length = 1277
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap28 : PRE_first_tail_x6_r0_body.kappa28 = Conv.Map.compact PRE_first_tail_x6_r0_body.s283.next 2697041 PRE_first_tail_x6_r0_body.S283.tab.length PRE_first_tail_x6_r0_body.pl28 (PRE_first_tail_x6_r0_body.nr28.map NumV.ref) PRE_first_tail_x6_r0_body.kd28.big
  PRE_first_tail_x6_r0_body.kd28.region PRE_first_tail_x6_r0_body.kd28.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin28 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s285.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc28 : Conv.jcleanListB (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s285 PRE_first_tail_x6_r0_body.cl28 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB28 : noBigRootsP (fun i => !Conv.oldBigB (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s285.trace PRE_first_tail_x6_r0_body.s285 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm28 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15855 = true
theorem PRE_first_tail_x6_r0_body.cjcl28 (h : Conv.JClean (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s283) : Conv.JClean (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s285 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle28)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap28 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd28 a ha)) PRE_first_tail_x6_r0_body.zjc28

end Host.Load.Run.Tpl
end

section -- st28/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st28.bodyLast from PRE_first_tail_x6_r0_body.st28.s1 to PRE_first_tail_x6_r0_body.st28.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st28.F PRE_first_tail_x6_r0_body.st28.s1).run PRE_first_tail_x6_r0_body.st28.S1 = some (PRE_first_tail_x6_r0_body.st28.s2, PRE_first_tail_x6_r0_body.st28.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st28.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st28.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st28.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st28.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st28/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st28.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st28.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st28.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st28.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st28.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st28.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st28.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st28.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st28.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st28.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st28.s0 PRE_first_tail_x6_r0_body.st28.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st28.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st28.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st28.s1 PRE_first_tail_x6_r0_body.st28.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st28/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st28.bodyK0F from PRE_first_tail_x6_r0_body.st28.s0 to PRE_first_tail_x6_r0_body.st28.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st28.F (PRE_first_tail_x6_r0_body.st28.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st28.ks 0).getD 0) PRE_first_tail_x6_r0_body.st28.s0 PRE_first_tail_x6_r0_body.st28.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st28.s1, PRE_first_tail_x6_r0_body.st28.S1)
theorem PRE_first_tail_x6_r0_body.st28.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st28.F (PRE_first_tail_x6_r0_body.st28.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st28.ks 0).getD 0) PRE_first_tail_x6_r0_body.st28.s0 PRE_first_tail_x6_r0_body.st28.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st28.s1, PRE_first_tail_x6_r0_body.st28.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st28.bodyOkLN_ok PRE_first_tail_x6_r0_body.st28.bodyK0F
end Host.Load.Run.Tpl
end

section -- st28/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st28.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st28.F (PRE_first_tail_x6_r0_body.st28.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st28.s0 PRE_first_tail_x6_r0_body.st28.S0 = some (PRE_first_tail_x6_r0_body.st28.s1, PRE_first_tail_x6_r0_body.st28.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st28.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st28.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st28.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st28.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st28.F (PRE_first_tail_x6_r0_body.st28.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st28.s0
  S0 := PRE_first_tail_x6_r0_body.st28.S0
  s1 := PRE_first_tail_x6_r0_body.st28.s1
  S1 := PRE_first_tail_x6_r0_body.st28.S1
  s2 := PRE_first_tail_x6_r0_body.st28.s2
  S2 := PRE_first_tail_x6_r0_body.st28.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st28.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st28.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st28.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st28.bodyHalt
  last := PRE_first_tail_x6_r0_body.st28.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st28.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC29
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 29 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s289` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa29` into the merged state
`PRE_first_tail_x6_r0_body.s288`. -/

def PRE_first_tail_x6_r0_body.pl29 : List Nat := [2697337]
def PRE_first_tail_x6_r0_body.nr29 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd29 : RData :=
  ⟨2697328, 2697338, Stage.setAll PTrie.nil [(2697327, 2697337)], Stage.setAll PTrie.nil [],
   18768, 18768, 15859, 15859, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa29 : Map :=
  Conv.Map.compact 2697327 2697338 1294 PRE_first_tail_x6_r0_body.pl29 (PRE_first_tail_x6_r0_body.nr29.map NumV.ref) PRE_first_tail_x6_r0_body.kd29.big
    PRE_first_tail_x6_r0_body.kd29.region PRE_first_tail_x6_r0_body.kd29.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws29 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs29 : List SymE := PRE_first_tail_x6_r0_body.nr29.map fun r => (nth? PRE_first_tail_x6_r0_body.S288.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta29 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws29 PRE_first_tail_x6_r0_body.crs29
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB29 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab29 : PRE_first_tail_x6_r0_body.S289.tab = PRE_first_tail_x6_r0_body.S287.tab ++ PRE_first_tail_x6_r0_body.cws29.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace29 : PRE_first_tail_x6_r0_body.s289.trace = PRE_first_tail_x6_r0_body.s287.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext29 : PRE_first_tail_x6_r0_body.s289.next = 2697328
kernel_rfl PRE_first_tail_x6_r0_body.ccounters29 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx.nnext) = (18768, 15859)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue29 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s288.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa29.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp29 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx.tokens.all (bSN 1294) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean29 : Conv.cleanListB 18768 131072 (fun r => Nat.ble 75072 r) PRE_first_tail_x6_r0_body.s289
    (PRE_first_tail_x6_r0_body.wrB29 ++ (List.range 1).map (2697327 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs29 : bigsOutB 18768 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK29
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl29`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl29 : List Nat := [2665, 2673467, 2697327]
def PRE_first_tail_x6_r0_body.clo29 : List Nat := []
def PRE_first_tail_x6_r0_body.cln29 : List Nat := []
def PRE_first_tail_x6_r0_body.cli29 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap29 : PRE_first_tail_x6_r0_body.s289.heap = Stage.setAll PRE_first_tail_x6_r0_body.s287.heap (PRE_first_tail_x6_r0_body.cl29.filterMap fun a => (PRE_first_tail_x6_r0_body.s289.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe29 : Nat.ble PRE_first_tail_x6_r0_body.s287.next PRE_first_tail_x6_r0_body.s289.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP29 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s287 PRE_first_tail_x6_r0_body.s289 PRE_first_tail_x6_r0_body.cl29 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp29 : Conv.suppListB PRE_first_tail_x6_r0_body.s289 1294 PRE_first_tail_x6_r0_body.cl29 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound29 : Conv.boundListB PRE_first_tail_x6_r0_body.s289 PRE_first_tail_x6_r0_body.cl29 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK29 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln29.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK29 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo29.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK29 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli29.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst29 : Conv.sstListB 1294 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx PRE_first_tail_x6_r0_body.cln29 PRE_first_tail_x6_r0_body.clo29 PRE_first_tail_x6_r0_body.cli29 = true

end Host.Load.Run.Tpl
end

section -- SiteCl29
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA29 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo29.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd29 : (PRE_first_tail_x6_r0_body.clo29 ++ PRE_first_tail_x6_r0_body.cln29 ++ PRE_first_tail_x6_r0_body.cli29).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle29 : Conv.Cnt.leB (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) (⟨18768, 15859, 2697328, 1294⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck29 : Conv.ncleanListB (⟨18768, 15859, 2697328, 1294⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx PRE_first_tail_x6_r0_body.clo29 PRE_first_tail_x6_r0_body.cln29 PRE_first_tail_x6_r0_body.cli29 = true
theorem PRE_first_tail_x6_r0_body.cncl29 (h : Conv.NClean (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx) : Conv.NClean (⟨18768, 15859, 2697328, 1294⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle29 PRE_first_tail_x6_r0_body.ckA29 PRE_first_tail_x6_r0_body.cobjsK29 PRE_first_tail_x6_r0_body.cnodesK29 PRE_first_tail_x6_r0_body.citemsK29 PRE_first_tail_x6_r0_body.cbd29 PRE_first_tail_x6_r0_body.cck29

end Host.Load.Run.Tpl
end

section -- SiteS29
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 29 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc29 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P29 : LoadP := PRE_first_tail_x6_r0_body.Pc29.raise 15859
kernel_rfl PRE_first_tail_x6_r0_body.craise29 : Nat.ble PRE_first_tail_x6_r0_body.Pc29.N0 15859 = true
theorem PRE_first_tail_x6_r0_body.raised29 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc29 PRE_first_tail_x6_r0_body.P29 :=
  .inr ⟨15859, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise29, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_29 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_29 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s288.ffi)
def PRE_first_tail_x6_r0_body.khinv29 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv29 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS29 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS29 : List Nat := List.range' 15859 0
def PRE_first_tail_x6_r0_body.ciS29 : List Nat := [] ++ List.range' 15859 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh029 : PRE_first_tail_x6_r0_body.kd29.nh0 = PRE_first_tail_x6_r0_body.cx0_29.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh129 : PRE_first_tail_x6_r0_body.kd29.nh1 = PRE_first_tail_x6_r0_body.cx1_29.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn029 : PRE_first_tail_x6_r0_body.kd29.nn0 = PRE_first_tail_x6_r0_body.cx0_29.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn129 : PRE_first_tail_x6_r0_body.kd29.nn1 = PRE_first_tail_x6_r0_body.cx1_29.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo29 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P29.lo && Nat.ble PRE_first_tail_x6_r0_body.P29.lo PRE_first_tail_x6_r0_body.cx0_29.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P29.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P29.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt29 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_29.mlx.next PRE_first_tail_x6_r0_body.cx1_29.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_29.mlx.nnext PRE_first_tail_x6_r0_body.cx1_29.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband29 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P29.NL && Nat.ble PRE_first_tail_x6_r0_body.P29.NL PRE_first_tail_x6_r0_body.P29.N0 && Nat.ble PRE_first_tail_x6_r0_body.P29.N0 PRE_first_tail_x6_r0_body.cx0_29.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow29 : PRE_first_tail_x6_r0_body.kd29.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren29 : checkRenG PRE_first_tail_x6_r0_body.kd29.hnd PRE_first_tail_x6_r0_body.khinv29 (phB PRE_first_tail_x6_r0_body.cx0_29.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband29 : PRE_first_tail_x6_r0_body.kd29.checkBand PRE_first_tail_x6_r0_body.P29.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos29 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd29.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren29 : checkRenG PRE_first_tail_x6_r0_body.kd29.node PRE_first_tail_x6_r0_body.kninv29 (pnB PRE_first_tail_x6_r0_body.cx0_29.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow29 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd29.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P29.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd29.nodeF j) PRE_first_tail_x6_r0_body.cx1_29.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a29 : PRE_first_tail_x6_r0_body.cx0_29.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b29 : PRE_first_tail_x6_r0_body.cx0_29.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok129 : PRE_first_tail_x6_r0_body.cx1_29.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend29 : PRE_first_tail_x6_r0_body.cx1_29.mlx.pending = PRE_first_tail_x6_r0_body.cx0_29.mlx.pending.map PRE_first_tail_x6_r0_body.kappa29.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh29 : PRE_first_tail_x6_r0_body.cx1_29.mlx.errh = PRE_first_tail_x6_r0_body.cx0_29.mlx.errh.map PRE_first_tail_x6_r0_body.kappa29.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles29 : PRE_first_tail_x6_r0_body.cx1_29.mlx.files = PRE_first_tail_x6_r0_body.cx0_29.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch29 : PRE_first_tail_x6_r0_body.cx1_29.mlx.arch = PRE_first_tail_x6_r0_body.cx0_29.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes29 : PRE_first_tail_x6_r0_body.cx1_29.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_29.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired29 : PRE_first_tail_x6_r0_body.cx1_29.mlx.wired = PRE_first_tail_x6_r0_body.cx0_29.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost29 : PRE_first_tail_x6_r0_body.cx1_29.host = PRE_first_tail_x6_r0_body.cx0_29.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd29`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn029 : PRE_first_tail_x6_r0_body.kd29.n0 = 2697328
kernel_rfl PRE_first_tail_x6_r0_body.ckn129 : PRE_first_tail_x6_r0_body.kd29.n1 = 2697338
kernel_rfl PRE_first_tail_x6_r0_body.ckheap29 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd29.heap).all (fun x => Nat.ble 2697327 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl29 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd29.heap.get (2697327 + j) = nth? PRE_first_tail_x6_r0_body.pl29 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja29 : Nat.ble 2697327 2697327 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn29 : Nat.ble 1294 1294 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD29 : Nat.ble 2697327 PRE_first_tail_x6_r0_body.kd29.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn29 : Nat.ble 18768 PRE_first_tail_x6_r0_body.kd29.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn29 : Nat.ble 15859 PRE_first_tail_x6_r0_body.kd29.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb29 : Nat.ble 18768 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap29 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd29.heap).all (Nat.ble (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd29 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd29.hnd).all (Nat.ble (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode29 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd29.node).all (Nat.ble (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix29 : Conv.FixOld (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa29 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja29) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn29) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD29) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn29) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn29) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb29) PRE_first_tail_x6_r0_body.fheap29 PRE_first_tail_x6_r0_body.fhnd29 PRE_first_tail_x6_r0_body.fnode29
kernel_rfl PRE_first_tail_x6_r0_body.fcxn29 : (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn29 : (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle029 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_29.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_29.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk29 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd29.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A29 : PRE_first_tail_x6_r0_body.cx1_29.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS29.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_29.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O29 : PRE_first_tail_x6_r0_body.cx1_29.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS29.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_29.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N29 : PRE_first_tail_x6_r0_body.cx1_29.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS29.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_29.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I29 : PRE_first_tail_x6_r0_body.cx1_29.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS29.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_29.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd29 : (PRE_first_tail_x6_r0_body.clo29 ++ PRE_first_tail_x6_r0_body.cln29 ++ PRE_first_tail_x6_r0_body.cli29 ++ PRE_first_tail_x6_r0_body.cwS29 ++ PRE_first_tail_x6_r0_body.cnS29 ++ PRE_first_tail_x6_r0_body.ciS29).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW29 : PRE_first_tail_x6_r0_body.cwS29.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo29.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI29 : PRE_first_tail_x6_r0_body.ciS29.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli29.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN29 : PRE_first_tail_x6_r0_body.cnS29.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF29 : PRE_first_tail_x6_r0_body.cln29.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh29 : PRE_first_tail_x6_r0_body.clo29.all (handleOK PRE_first_tail_x6_r0_body.kappa29 PRE_first_tail_x6_r0_body.P29.lo PRE_first_tail_x6_r0_body.cx0_29.mlx PRE_first_tail_x6_r0_body.cx1_29.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo29 : PRE_first_tail_x6_r0_body.clo29.map (fun h => PRE_first_tail_x6_r0_body.cx1_29.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa29.handle h)) = PRE_first_tail_x6_r0_body.clo29.map (fun h => (PRE_first_tail_x6_r0_body.cx0_29.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa29.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok29 : PRE_first_tail_x6_r0_body.clo29.all (objOK PRE_first_tail_x6_r0_body.kappa29 PRE_first_tail_x6_r0_body.P29.NL PRE_first_tail_x6_r0_body.cx0_29.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd29 : PRE_first_tail_x6_r0_body.cln29.all (nodeOKF PRE_first_tail_x6_r0_body.kappa29 PRE_first_tail_x6_r0_body.P29 PRE_first_tail_x6_r0_body.cx0_29.mlx PRE_first_tail_x6_r0_body.cx1_29.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp29 : ((PRE_first_tail_x6_r0_body.cln29.filter (fullB PRE_first_tail_x6_r0_body.P29))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_29.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa29.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln29.filter (fullB PRE_first_tail_x6_r0_body.P29))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_29.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa29.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI29 : incrB PRE_first_tail_x6_r0_body.kd29.nodeF (List.range' 15859 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK29 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd29.node).all (fun k => Nat.ble 15859 k && Nat.blt k 15859) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL29 : (PRE_first_tail_x6_r0_body.cln29.filter (Nat.ble PRE_first_tail_x6_r0_body.P29.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd29.nodeF i) && (Nat.blt i 15859 || Nat.ble PRE_first_tail_x6_r0_body.kd29.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord29 : (PRE_first_tail_x6_r0_body.cln29.filter (Nat.ble PRE_first_tail_x6_r0_body.P29.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd29.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd29.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd29.nodeF j) (PRE_first_tail_x6_r0_body.kd29.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow29 PRE_first_tail_x6_r0_body.cnn129 PRE_first_tail_x6_r0_body.fnordI29 PRE_first_tail_x6_r0_body.fnordK29 PRE_first_tail_x6_r0_body.fnordL29
kernel_rfl PRE_first_tail_x6_r0_body.fi29 : PRE_first_tail_x6_r0_body.cli29.all (pnB PRE_first_tail_x6_r0_body.cx0_29.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii29 : PRE_first_tail_x6_r0_body.cli29.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_29.mlx.items.get (PRE_first_tail_x6_r0_body.kappa29.node k) = (PRE_first_tail_x6_r0_body.cx0_29.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa29.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot29 (clean : Conv.NClean (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P29.NL) (cl : SSt (· < 1294) PRE_first_tail_x6_r0_body.cx0_29.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P29 1294 PRE_first_tail_x6_r0_body.kappa29 PRE_first_tail_x6_r0_body.kd29 PRE_first_tail_x6_r0_body.khinv29 PRE_first_tail_x6_r0_body.kninv29 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx PRE_first_tail_x6_r0_body.cx0_29.mlx PRE_first_tail_x6_r0_body.cx1_29.mlx (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo29 PRE_first_tail_x6_r0_body.cln29 PRE_first_tail_x6_r0_body.cli29 PRE_first_tail_x6_r0_body.cwS29 PRE_first_tail_x6_r0_body.cnS29 PRE_first_tail_x6_r0_body.ciS29 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh029, PRE_first_tail_x6_r0_body.cnh129, PRE_first_tail_x6_r0_body.cnn029, PRE_first_tail_x6_r0_body.cnn129, PRE_first_tail_x6_r0_body.cplo29, PRE_first_tail_x6_r0_body.ccnt29, PRE_first_tail_x6_r0_body.cnband29, PRE_first_tail_x6_r0_body.chbelow29, PRE_first_tail_x6_r0_body.chren29, PRE_first_tail_x6_r0_body.cband29, PRE_first_tail_x6_r0_body.cnh1pos29, PRE_first_tail_x6_r0_body.cnren29, PRE_first_tail_x6_r0_body.cnlow29, PRE_first_tail_x6_r0_body.cabs0a29, PRE_first_tail_x6_r0_body.cabs0b29, PRE_first_tail_x6_r0_body.ctok129, PRE_first_tail_x6_r0_body.cpend29, PRE_first_tail_x6_r0_body.cerrh29, PRE_first_tail_x6_r0_body.cfiles29, PRE_first_tail_x6_r0_body.carch29, PRE_first_tail_x6_r0_body.csizes29, PRE_first_tail_x6_r0_body.cwired29, PRE_first_tail_x6_r0_body.cfix29, clean, PRE_first_tail_x6_r0_body.fcxn29, PRE_first_tail_x6_r0_body.fcnn29, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle029, PRE_first_tail_x6_r0_body.fnk29, PRE_first_tail_x6_r0_body.ckA29, PRE_first_tail_x6_r0_body.cobjsK29, PRE_first_tail_x6_r0_body.cnodesK29, PRE_first_tail_x6_r0_body.citemsK29, PRE_first_tail_x6_r0_body.f1A29, PRE_first_tail_x6_r0_body.f1O29, PRE_first_tail_x6_r0_body.f1N29, PRE_first_tail_x6_r0_body.f1I29, PRE_first_tail_x6_r0_body.fbd29, PRE_first_tail_x6_r0_body.fincW29, PRE_first_tail_x6_r0_body.fincI29, PRE_first_tail_x6_r0_body.fincN29, PRE_first_tail_x6_r0_body.flnF29, PRE_first_tail_x6_r0_body.fh29, PRE_first_tail_x6_r0_body.fo29, PRE_first_tail_x6_r0_body.fok29, PRE_first_tail_x6_r0_body.fnd29, PRE_first_tail_x6_r0_body.fp29, PRE_first_tail_x6_r0_body.fnord29, PRE_first_tail_x6_r0_body.fi29, PRE_first_tail_x6_r0_body.fii29⟩
theorem PRE_first_tail_x6_r0_body.cnshift29 (clean : Conv.NClean (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P29.NL) (cl : SSt (· < 1294) PRE_first_tail_x6_r0_body.cx0_29.mlx) : NShift PRE_first_tail_x6_r0_body.P29 1294 PRE_first_tail_x6_r0_body.kappa29 PRE_first_tail_x6_r0_body.cx0_29 PRE_first_tail_x6_r0_body.cx1_29 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot29 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost29 (compact_a_eq PRE_first_tail_x6_r0_body.ckn029 PRE_first_tail_x6_r0_body.ckn129 PRE_first_tail_x6_r0_body.ckheap29 PRE_first_tail_x6_r0_body.ckpl29)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_29 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s287.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_29 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s287.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_29 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s287.ffi) = some PRE_first_tail_x6_r0_body.fxC_29
kernel_rfl PRE_first_tail_x6_r0_body.okrC_29 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s287.ffi) = some PRE_first_tail_x6_r0_body.krC_29
noncomputable def PRE_first_tail_x6_r0_body.fx0_29 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s289.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_29 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s289.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_29 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s289.ffi) = some PRE_first_tail_x6_r0_body.fx0_29
kernel_rfl PRE_first_tail_x6_r0_body.okr0_29 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s289.ffi) = some PRE_first_tail_x6_r0_body.kr0_29
noncomputable def PRE_first_tail_x6_r0_body.fx1_29 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s288.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_29 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s288.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_29 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s288.ffi) = some PRE_first_tail_x6_r0_body.fx1_29
kernel_rfl PRE_first_tail_x6_r0_body.okr1_29 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s288.ffi) = some PRE_first_tail_x6_r0_body.kr1_29
kernel_rfl PRE_first_tail_x6_r0_body.ff029 : PRE_first_tail_x6_r0_body.fx0_29 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_29 (PRE_first_tail_x6_r0_body.clo29.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_29.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff129 : PRE_first_tail_x6_r0_body.fx1_29 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_29 (PRE_first_tail_x6_r0_body.cwS29.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_29.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck29 : freedLB PRE_first_tail_x6_r0_body.kappa29 PRE_first_tail_x6_r0_body.cx0_29.mlx PRE_first_tail_x6_r0_body.fx0_29 PRE_first_tail_x6_r0_body.fx1_29 PRE_first_tail_x6_r0_body.clo29 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf029 : PRE_first_tail_x6_r0_body.kr0_29.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_29.flags (PRE_first_tail_x6_r0_body.clo29.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_29.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt029 : PRE_first_tail_x6_r0_body.kr0_29.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_29.targs (PRE_first_tail_x6_r0_body.clo29.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_29.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf129 : PRE_first_tail_x6_r0_body.kr1_29.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_29.flags (PRE_first_tail_x6_r0_body.cwS29.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_29.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt129 : PRE_first_tail_x6_r0_body.kr1_29.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_29.targs (PRE_first_tail_x6_r0_body.cwS29.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_29.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck29 : krecLB PRE_first_tail_x6_r0_body.kappa29 1294 PRE_first_tail_x6_r0_body.cx0_29.mlx PRE_first_tail_x6_r0_body.kr0_29 PRE_first_tail_x6_r0_body.kr1_29 PRE_first_tail_x6_r0_body.clo29 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn29 : Nat.ble 1294 1294 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge29 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s288.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s289.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR29 : pendRegB PRE_first_tail_x6_r0_body.kappa29 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe29 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s288.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift29 (clean : Conv.NClean (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P29.NL) (cl : SSt (· < 1294) PRE_first_tail_x6_r0_body.cx0_29.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_29.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_29.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_29.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_29.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P29 1294 PRE_first_tail_x6_r0_body.kappa29 PRE_first_tail_x6_r0_body.s289.ffi PRE_first_tail_x6_r0_body.s288.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift29 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue29, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp29 t ht),
    PRE_first_tail_x6_r0_body.cbridge29,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s289.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s288.ffi) (PRE_first_tail_x6_r0_body.cfoot29 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_29 PRE_first_tail_x6_r0_body.ofx1_29 hobjC PRE_first_tail_x6_r0_body.ff029 PRE_first_tail_x6_r0_body.ff129 PRE_first_tail_x6_r0_body.ffck29,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s289.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s288.ffi) (PRE_first_tail_x6_r0_body.cfoot29 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_29 PRE_first_tail_x6_r0_body.okr1_29 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn29) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf029 PRE_first_tail_x6_r0_body.fkt029 PRE_first_tail_x6_r0_body.fkf129 PRE_first_tail_x6_r0_body.fkt129 PRE_first_tail_x6_r0_body.fkck29,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh029 PRE_first_tail_x6_r0_body.cnh129 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe29) PRE_first_tail_x6_r0_body.cpendR29⟩

end Host.Load.Run.Tpl
end

section -- st29/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st29 0
host_stream_state PRE_first_tail_x6_r0_body.st29 1
host_stream_state PRE_first_tail_x6_r0_body.st29 2
end Host.Load.Run.Tpl
end

section -- Site29
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 29 of chain `PRE_first_tail_x6_r0_body`: `plan__g29__g30` (`plan`), the call state `PRE_first_tail_x6_r0_body.s287`, the merged state `PRE_first_tail_x6_r0_body.s288`,
the site template `PRE_first_tail_x6_r0_body.st29` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s289`: the merge.
The footprint's facts are in `SiteF29`, the compaction's in `SiteC29`, `SiteK29`, `SiteNa29`, `SiteNb29`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso29 : PRE_first_tail_x6_r0_body.st29.s0 = { PRE_first_tail_x6_r0_body.s287 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs29 : List Frame := PRE_first_tail_x6_r0_body.s287.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_29 : PRE_first_tail_x6_r0_body.S287.tab.length = 1294
kernel_rfl PRE_first_tail_x6_r0_body.tab0_29 : PRE_first_tail_x6_r0_body.st29.S0.tab = PRE_first_tail_x6_r0_body.S287.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws29 : List Nat := [1497, 1498, 1499]
kernel_rfl PRE_first_tail_x6_r0_body.fresh29 : (PRE_first_tail_x6_r0_body.S287.tab.all fun e => PRE_first_tail_x6_r0_body.ws29.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S287.oracle.all fun q => PRE_first_tail_x6_r0_body.ws29.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab29 : PRE_first_tail_x6_r0_body.S288.tab = PRE_first_tail_x6_r0_body.S287.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws29
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen29 : PRE_first_tail_x6_r0_body.st29.S2.tab.length - PRE_first_tail_x6_r0_body.st29.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged29`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap29 : PRE_first_tail_x6_r0_body.s288.heap = PRE_first_tail_x6_r0_body.st29.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext29 : PRE_first_tail_x6_r0_body.s288.next = PRE_first_tail_x6_r0_body.st29.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl29 : PRE_first_tail_x6_r0_body.s288.ctl = PRE_first_tail_x6_r0_body.st29.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack29 : PRE_first_tail_x6_r0_body.s288.stack = PRE_first_tail_x6_r0_body.st29.s2.stack ++ PRE_first_tail_x6_r0_body.s287.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs29 : PRE_first_tail_x6_r0_body.s288.jobs = PRE_first_tail_x6_r0_body.st29.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi29 : PRE_first_tail_x6_r0_body.s288.ffi = PRE_first_tail_x6_r0_body.st29.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace29 : PRE_first_tail_x6_r0_body.s288.trace = PRE_first_tail_x6_r0_body.st29.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores29 : PRE_first_tail_x6_r0_body.s288.stores = PRE_first_tail_x6_r0_body.st29.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD29
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 29 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived29 : PRE_first_tail_x6_r0_body.nr29.map (fun r => nth? PRE_first_tail_x6_r0_body.st29.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo29 : PRE_first_tail_x6_r0_body.nr29.all (Nat.ble 1294) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj29 : PRE_first_tail_x6_r0_body.cws29.all (fun c => !PRE_first_tail_x6_r0_body.ws29.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ29 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws29 PRE_first_tail_x6_r0_body.crs29 PRE_first_tail_x6_r0_body.ws29

end Host.Load.Run.Tpl
end

section -- st29/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st29`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st29.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st29.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st29.s2.heap PRE_first_tail_x6_r0_body.st29.wrR ++ freshOf PRE_first_tail_x6_r0_body.st29.s2.heap PRE_first_tail_x6_r0_body.st29.s0.next PRE_first_tail_x6_r0_body.st29.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st29.wr : List Nat := PRE_first_tail_x6_r0_body.st29.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st29.heapFoot : PRE_first_tail_x6_r0_body.st29.s2.heap = setAll PRE_first_tail_x6_r0_body.st29.s0.heap PRE_first_tail_x6_r0_body.st29.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st29.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st29.s0.next PRE_first_tail_x6_r0_body.st29.s2.next = true
theorem PRE_first_tail_x6_r0_body.st29.grows : PRE_first_tail_x6_r0_body.st29.s0.next ≤ PRE_first_tail_x6_r0_body.st29.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st29.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st29.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st29.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st29.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st29.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st29.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st29.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st29.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st29.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st29.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st29.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st29.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF29
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 29 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB29 : nodupT PRE_first_tail_x6_r0_body.st29.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup29 : PRE_first_tail_x6_r0_body.st29.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB29).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB29 : PRE_first_tail_x6_r0_body.st29.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound29 : ∀ b ∈ PRE_first_tail_x6_r0_body.st29.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB29 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr29 := PRE_first_tail_x6_r0_body.st29.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq29 : PRE_first_tail_x6_r0_body.st29.s2.trace = PRE_first_tail_x6_r0_body.trFr29 ++ PRE_first_tail_x6_r0_body.st29.s0.trace
theorem PRE_first_tail_x6_r0_body.trace29 : ∃ fr, PRE_first_tail_x6_r0_body.st29.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st29.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq29⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide29 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB29 : (PRE_first_tail_x6_r0_body.wide29.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st29.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix29 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide29, WFix Map.id (Present PRE_first_tail_x6_r0_body.st29.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB29 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL29
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 29 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s288`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO29 : PRE_first_tail_x6_r0_body.st29.S0.oracle = PRE_first_tail_x6_r0_body.st29.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B29 : PRE_first_tail_x6_r0_body.st29.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st29.s0.next || (PRE_first_tail_x6_r0_body.st29.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot29 : Conv.StageFoot PRE_first_tail_x6_r0_body.st29.wr PRE_first_tail_x6_r0_body.st29.s0 PRE_first_tail_x6_r0_body.st29.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st29.heapFoot PRE_first_tail_x6_r0_body.wrNodup29 PRE_first_tail_x6_r0_body.wrBound29 PRE_first_tail_x6_r0_body.wr0B29 PRE_first_tail_x6_r0_body.st29.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged29 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st29.F.S → PRE_first_tail_x6_r0_body.st29.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st29.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st29.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs29 PRE_first_tail_x6_r0_body.st29.wr PRE_first_tail_x6_r0_body.s287 PRE_first_tail_x6_r0_body.st29.s2 PRE_first_tail_x6_r0_body.st29.s0
      PRE_first_tail_x6_r0_body.st29.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st29.F FR W stk M ν K PRE_first_tail_x6_r0_body.s288 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso29 PRE_first_tail_x6_r0_body.stFoot29 PRE_first_tail_x6_r0_body.wrNodup29 PRE_first_tail_x6_r0_body.wrBound29 PRE_first_tail_x6_r0_body.trace29 PRE_first_tail_x6_r0_body.mheap29
    PRE_first_tail_x6_r0_body.mnext29 PRE_first_tail_x6_r0_body.mctl29 PRE_first_tail_x6_r0_body.mstack29 PRE_first_tail_x6_r0_body.mjobs29 PRE_first_tail_x6_r0_body.mffi29 PRE_first_tail_x6_r0_body.mtrace29 PRE_first_tail_x6_r0_body.mstores29 h

def PRE_first_tail_x6_r0_body.arrEl29_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE29_2665 : arrOf PRE_first_tail_x6_r0_body.s288 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl29_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA29_2665 : isArrB PRE_first_tail_x6_r0_body.s288 2665 = true
theorem PRE_first_tail_x6_r0_body.arr29_2665 : ∃ o, PRE_first_tail_x6_r0_body.s288.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl29_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE29_2665 PRE_first_tail_x6_r0_body.arrA29_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN29_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl29_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR29_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl29_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN29_2665

def PRE_first_tail_x6_r0_body.arrEl29_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE29_2673467 : arrOf PRE_first_tail_x6_r0_body.s288 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl29_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA29_2673467 : isArrB PRE_first_tail_x6_r0_body.s288 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr29_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s288.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl29_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE29_2673467 PRE_first_tail_x6_r0_body.arrA29_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN29_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl29_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR29_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl29_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN29_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k29 : isArrB PRE_first_tail_x6_r0_body.s288 4910 = false
theorem PRE_first_tail_x6_r0_body.keep29 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s288 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k29 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr29_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl29_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ29
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 29 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s287`, the merged
state `PRE_first_tail_x6_r0_body.s288`, the canonical state `PRE_first_tail_x6_r0_body.s289`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl29 : PRE_first_tail_x6_r0_body.pl29.all (Nat.ble PRE_first_tail_x6_r0_body.s287.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd29 : nodupT PRE_first_tail_x6_r0_body.pl29 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn129 : Nat.ble PRE_first_tail_x6_r0_body.s287.next 2697338 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst29 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s287.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn29 : PRE_first_tail_x6_r0_body.s289.next = PRE_first_tail_x6_r0_body.s287.next + PRE_first_tail_x6_r0_body.pl29.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn29 : PRE_first_tail_x6_r0_body.s288.next = 2697338
kernel_rfl PRE_first_tail_x6_r0_body.zgrow29 : Nat.ble PRE_first_tail_x6_r0_body.s289.next PRE_first_tail_x6_r0_body.s288.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh29 : PRE_first_tail_x6_r0_body.S287.tab.all (fun e => PRE_first_tail_x6_r0_body.cws29.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd29 : nodupT PRE_first_tail_x6_r0_body.cws29 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi29 : PRE_first_tail_x6_r0_body.nr29.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S288.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt29 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s287.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg29_2665 : PRE_first_tail_x6_r0_body.s289.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s289 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk29_2665 : (objOf PRE_first_tail_x6_r0_body.s289 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm29_2665 : PRE_first_tail_x6_r0_body.s288.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa29.obj (objOf PRE_first_tail_x6_r0_body.s289 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s288 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg29_2673467 : PRE_first_tail_x6_r0_body.s289.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s289 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk29_2673467 : (objOf PRE_first_tail_x6_r0_body.s289 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm29_2673467 : PRE_first_tail_x6_r0_body.s288.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa29.obj (objOf PRE_first_tail_x6_r0_body.s289 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s288 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw29_4910 : (PRE_first_tail_x6_r0_body.s289.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw29_2673472 : (PRE_first_tail_x6_r0_body.s289.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw29_2673473 : (PRE_first_tail_x6_r0_body.s289.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd29 : PRE_first_tail_x6_r0_body.cl29.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr29 : PRE_first_tail_x6_r0_body.st29.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s287.next || PRE_first_tail_x6_r0_body.cl29.contains b) = true
def PRE_first_tail_x6_r0_body.zl29 : List Nat := PRE_first_tail_x6_r0_body.cl29.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE29 : PRE_first_tail_x6_r0_body.zl29.map (fun a => PRE_first_tail_x6_r0_body.s288.heap.get (PRE_first_tail_x6_r0_body.kappa29.a a)) = PRE_first_tail_x6_r0_body.zl29.map (fun a => (PRE_first_tail_x6_r0_body.s289.heap.get a).map PRE_first_tail_x6_r0_body.kappa29.hobj)
theorem PRE_first_tail_x6_r0_body.zimg29 : HeapImg PRE_first_tail_x6_r0_body.kappa29 PRE_first_tail_x6_r0_body.s289 PRE_first_tail_x6_r0_body.s288 PRE_first_tail_x6_r0_body.zl29 := PRE_first_tail_x6_r0_body.zimgE29
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl29 : PRE_first_tail_x6_r0_body.s288.ctl = PRE_first_tail_x6_r0_body.kappa29.ctl PRE_first_tail_x6_r0_body.s289.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack29 : PRE_first_tail_x6_r0_body.s288.stack = PRE_first_tail_x6_r0_body.s289.stack.map PRE_first_tail_x6_r0_body.kappa29.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs29 : PRE_first_tail_x6_r0_body.s288.jobs = PRE_first_tail_x6_r0_body.s289.jobs.map PRE_first_tail_x6_r0_body.kappa29.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores29 : PRE_first_tail_x6_r0_body.s288.stores = PRE_first_tail_x6_r0_body.kappa29.stores PRE_first_tail_x6_r0_body.s289.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots29 : checkRootsSupp PRE_first_tail_x6_r0_body.s289 1294 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC29 : PRE_first_tail_x6_r0_body.S287.tab.length + PRE_first_tail_x6_r0_body.cws29.length = 1294
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap29 : PRE_first_tail_x6_r0_body.kappa29 = Conv.Map.compact PRE_first_tail_x6_r0_body.s287.next 2697338 PRE_first_tail_x6_r0_body.S287.tab.length PRE_first_tail_x6_r0_body.pl29 (PRE_first_tail_x6_r0_body.nr29.map NumV.ref) PRE_first_tail_x6_r0_body.kd29.big
  PRE_first_tail_x6_r0_body.kd29.region PRE_first_tail_x6_r0_body.kd29.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin29 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s289.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc29 : Conv.jcleanListB (⟨18768, 15859, 2697328, 1294⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s289 PRE_first_tail_x6_r0_body.cl29 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB29 : noBigRootsP (fun i => !Conv.oldBigB (⟨18768, 15859, 2697328, 1294⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s289.trace PRE_first_tail_x6_r0_body.s289 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm29 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15859 = true
theorem PRE_first_tail_x6_r0_body.cjcl29 (h : Conv.JClean (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s287) : Conv.JClean (⟨18768, 15859, 2697328, 1294⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s289 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle29)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap29 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd29 a ha)) PRE_first_tail_x6_r0_body.zjc29

end Host.Load.Run.Tpl
end

section -- st29/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st29.bodyLast from PRE_first_tail_x6_r0_body.st29.s1 to PRE_first_tail_x6_r0_body.st29.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st29.F PRE_first_tail_x6_r0_body.st29.s1).run PRE_first_tail_x6_r0_body.st29.S1 = some (PRE_first_tail_x6_r0_body.st29.s2, PRE_first_tail_x6_r0_body.st29.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st29.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st29.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st29.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st29.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st29/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st29.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st29.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st29.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st29.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st29.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st29.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st29.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st29.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st29.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st29.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st29.s0 PRE_first_tail_x6_r0_body.st29.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st29.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st29.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st29.s1 PRE_first_tail_x6_r0_body.st29.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st29/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st29.bodyK0F from PRE_first_tail_x6_r0_body.st29.s0 to PRE_first_tail_x6_r0_body.st29.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st29.F (PRE_first_tail_x6_r0_body.st29.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st29.ks 0).getD 0) PRE_first_tail_x6_r0_body.st29.s0 PRE_first_tail_x6_r0_body.st29.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st29.s1, PRE_first_tail_x6_r0_body.st29.S1)
theorem PRE_first_tail_x6_r0_body.st29.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st29.F (PRE_first_tail_x6_r0_body.st29.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st29.ks 0).getD 0) PRE_first_tail_x6_r0_body.st29.s0 PRE_first_tail_x6_r0_body.st29.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st29.s1, PRE_first_tail_x6_r0_body.st29.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st29.bodyOkLN_ok PRE_first_tail_x6_r0_body.st29.bodyK0F
end Host.Load.Run.Tpl
end

section -- st29/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st29.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st29.F (PRE_first_tail_x6_r0_body.st29.bodyOkL bytes rows) 98 PRE_first_tail_x6_r0_body.st29.s0 PRE_first_tail_x6_r0_body.st29.S0 = some (PRE_first_tail_x6_r0_body.st29.s1, PRE_first_tail_x6_r0_body.st29.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st29.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st29.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st29.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st29.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st29.F (PRE_first_tail_x6_r0_body.st29.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st29.s0
  S0 := PRE_first_tail_x6_r0_body.st29.S0
  s1 := PRE_first_tail_x6_r0_body.st29.s1
  S1 := PRE_first_tail_x6_r0_body.st29.S1
  s2 := PRE_first_tail_x6_r0_body.st29.s2
  S2 := PRE_first_tail_x6_r0_body.st29.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st29.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st29.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st29.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st29.bodyHalt
  last := PRE_first_tail_x6_r0_body.st29.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st29.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC30
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 30 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s306` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa30` into the merged state
`PRE_first_tail_x6_r0_body.s305`. -/

def PRE_first_tail_x6_r0_body.pl30 : List Nat := [2699911, 2699086, 2699917, 2699913, 2699088, 2699919]
def PRE_first_tail_x6_r0_body.nr30 : List Nat := [1397, 1396, 1372, 1380, 1385, 1390, 1395, 1369, 1370, 1371, 1378, 1379, 1367, 1374, 1375, 1376, 1377, 1373]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd30 : RData :=
  ⟨2698805, 2699954, Stage.setAll PTrie.nil [(2698799, 2699911), (2698800, 2699086), (2698801, 2699917), (2698802, 2699913), (2698803, 2699088), (2698804, 2699919)], Stage.setAll PTrie.nil [(18802, 18828), (18803, 18806), (18804, 18829)],
   18805, 18830, 15905, 15905, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(1367, .ref 1397), (1368, .ref 1396), (1369, .ref 1372), (1370, .ref 1380), (1371, .ref 1385), (1372, .ref 1390), (1373, .ref 1395), (1374, .ref 1369), (1375, .ref 1370), (1376, .ref 1371), (1377, .ref 1378), (1378, .ref 1379), (1379, .ref 1367), (1380, .ref 1374), (1381, .ref 1375), (1382, .ref 1376), (1383, .ref 1377), (1384, .ref 1373)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa30 : Map :=
  Conv.Map.compact 2698799 2699954 1367 PRE_first_tail_x6_r0_body.pl30 (PRE_first_tail_x6_r0_body.nr30.map NumV.ref) PRE_first_tail_x6_r0_body.kd30.big
    PRE_first_tail_x6_r0_body.kd30.region PRE_first_tail_x6_r0_body.kd30.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws30 : List Nat := [1531, 1532, 1533, 1534, 1535, 1536, 1537, 1538, 1539, 1540, 1541, 1542, 1543, 1544, 1545, 1546, 1547, 1548]
noncomputable def PRE_first_tail_x6_r0_body.crs30 : List SymE := PRE_first_tail_x6_r0_body.nr30.map fun r => (nth? PRE_first_tail_x6_r0_body.S305.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta30 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws30 PRE_first_tail_x6_r0_body.crs30
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB30 : List Nat := [2665, 2672372, 2673467, 2697973, 2698518, 2698774]

kernel_rfl PRE_first_tail_x6_r0_body.ctab30 : PRE_first_tail_x6_r0_body.S306.tab = PRE_first_tail_x6_r0_body.S304.tab ++ PRE_first_tail_x6_r0_body.cws30.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace30 : PRE_first_tail_x6_r0_body.s306.trace = PRE_first_tail_x6_r0_body.s304.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext30 : PRE_first_tail_x6_r0_body.s306.next = 2698805
kernel_rfl PRE_first_tail_x6_r0_body.ccounters30 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx.nnext) = (18805, 15905)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue30 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s305.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa30.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp30 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx.tokens.all (bSN 1385) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean30 : Conv.cleanListB 18805 131072 (fun r => Nat.ble 75220 r) PRE_first_tail_x6_r0_body.s306
    (PRE_first_tail_x6_r0_body.wrB30 ++ (List.range 6).map (2698799 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs30 : bigsOutB 18805 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK30
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl30`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl30 : List Nat := [2665, 2672372, 2673467, 2697973, 2698518, 2698774, 2698799, 2698800, 2698801, 2698802, 2698803, 2698804]
def PRE_first_tail_x6_r0_body.clo30 : List Nat := [18782, 18795, 18801, 18802, 18803, 18804]
def PRE_first_tail_x6_r0_body.cln30 : List Nat := [15878, 15879, 15880, 15881, 15882, 15883, 15884, 15885, 15886, 15887, 15888, 15889, 15890, 15891, 15892, 15893, 15894, 15895, 15896, 15897, 15898, 15899, 15900, 15901, 15902, 15903, 15904]
def PRE_first_tail_x6_r0_body.cli30 : List Nat := [15878, 15879, 15880, 15881, 15882, 15883, 15884, 15885, 15886, 15887, 15888, 15889, 15890, 15891, 15892, 15893, 15894, 15895, 15896, 15897, 15898, 15899, 15900, 15901, 15902, 15903, 15904]
kernel_rfl PRE_first_tail_x6_r0_body.cheap30 : PRE_first_tail_x6_r0_body.s306.heap = Stage.setAll PRE_first_tail_x6_r0_body.s304.heap (PRE_first_tail_x6_r0_body.cl30.filterMap fun a => (PRE_first_tail_x6_r0_body.s306.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe30 : Nat.ble PRE_first_tail_x6_r0_body.s304.next PRE_first_tail_x6_r0_body.s306.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP30 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s304 PRE_first_tail_x6_r0_body.s306 PRE_first_tail_x6_r0_body.cl30 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp30 : Conv.suppListB PRE_first_tail_x6_r0_body.s306 1385 PRE_first_tail_x6_r0_body.cl30 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound30 : Conv.boundListB PRE_first_tail_x6_r0_body.s306 PRE_first_tail_x6_r0_body.cl30 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK30 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln30.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK30 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo30.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK30 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli30.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst30 : Conv.sstListB 1385 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx PRE_first_tail_x6_r0_body.cln30 PRE_first_tail_x6_r0_body.clo30 PRE_first_tail_x6_r0_body.cli30 = true

end Host.Load.Run.Tpl
end

section -- SiteCl30
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA30 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo30.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd30 : (PRE_first_tail_x6_r0_body.clo30 ++ PRE_first_tail_x6_r0_body.cln30 ++ PRE_first_tail_x6_r0_body.cli30).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle30 : Conv.Cnt.leB (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) (⟨18805, 15905, 2698805, 1385⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck30 : Conv.ncleanListB (⟨18805, 15905, 2698805, 1385⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx PRE_first_tail_x6_r0_body.clo30 PRE_first_tail_x6_r0_body.cln30 PRE_first_tail_x6_r0_body.cli30 = true
theorem PRE_first_tail_x6_r0_body.cncl30 (h : Conv.NClean (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx) : Conv.NClean (⟨18805, 15905, 2698805, 1385⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle30 PRE_first_tail_x6_r0_body.ckA30 PRE_first_tail_x6_r0_body.cobjsK30 PRE_first_tail_x6_r0_body.cnodesK30 PRE_first_tail_x6_r0_body.citemsK30 PRE_first_tail_x6_r0_body.cbd30 PRE_first_tail_x6_r0_body.cck30

end Host.Load.Run.Tpl
end

section -- SiteS30
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 30 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc30 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P30 : LoadP := PRE_first_tail_x6_r0_body.Pc30.raise 15905
kernel_rfl PRE_first_tail_x6_r0_body.craise30 : Nat.ble PRE_first_tail_x6_r0_body.Pc30.N0 15905 = true
theorem PRE_first_tail_x6_r0_body.raised30 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc30 PRE_first_tail_x6_r0_body.P30 :=
  .inr ⟨15905, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise30, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_30 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_30 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s305.ffi)
def PRE_first_tail_x6_r0_body.khinv30 : PTrie Nat := Stage.setAll PTrie.nil [(18828, 18802), (18806, 18803), (18829, 18804)]
def PRE_first_tail_x6_r0_body.kninv30 : PTrie Nat := Stage.setAll PTrie.nil [(15878, 15878), (15879, 15879), (15880, 15880), (15881, 15881), (15882, 15882), (15883, 15883), (15884, 15884), (15885, 15885), (15886, 15886), (15887, 15887), (15888, 15888), (15889, 15889), (15890, 15890), (15891, 15891), (15892, 15892), (15893, 15893), (15894, 15894), (15895, 15895), (15896, 15896), (15897, 15897), (15898, 15898), (15899, 15899), (15900, 15900), (15901, 15901), (15902, 15902), (15903, 15903), (15904, 15904)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS30 : List Nat := [18782, 18795, 18801, 18802, 18803, 18804, 18805, 18806, 18807, 18808, 18809, 18810, 18811, 18812, 18813, 18814, 18815, 18816, 18817, 18818, 18819, 18820, 18821, 18822, 18823, 18824, 18825, 18826, 18827, 18828, 18829]
def PRE_first_tail_x6_r0_body.cnS30 : List Nat := List.range' 15878 27
def PRE_first_tail_x6_r0_body.ciS30 : List Nat := [] ++ List.range' 15878 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh030 : PRE_first_tail_x6_r0_body.kd30.nh0 = PRE_first_tail_x6_r0_body.cx0_30.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh130 : PRE_first_tail_x6_r0_body.kd30.nh1 = PRE_first_tail_x6_r0_body.cx1_30.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn030 : PRE_first_tail_x6_r0_body.kd30.nn0 = PRE_first_tail_x6_r0_body.cx0_30.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn130 : PRE_first_tail_x6_r0_body.kd30.nn1 = PRE_first_tail_x6_r0_body.cx1_30.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo30 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P30.lo && Nat.ble PRE_first_tail_x6_r0_body.P30.lo PRE_first_tail_x6_r0_body.cx0_30.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P30.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P30.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt30 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_30.mlx.next PRE_first_tail_x6_r0_body.cx1_30.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_30.mlx.nnext PRE_first_tail_x6_r0_body.cx1_30.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband30 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P30.NL && Nat.ble PRE_first_tail_x6_r0_body.P30.NL PRE_first_tail_x6_r0_body.P30.N0 && Nat.ble PRE_first_tail_x6_r0_body.P30.N0 PRE_first_tail_x6_r0_body.cx0_30.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow30 : PRE_first_tail_x6_r0_body.kd30.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren30 : checkRenG PRE_first_tail_x6_r0_body.kd30.hnd PRE_first_tail_x6_r0_body.khinv30 (phB PRE_first_tail_x6_r0_body.cx0_30.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband30 : PRE_first_tail_x6_r0_body.kd30.checkBand PRE_first_tail_x6_r0_body.P30.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos30 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd30.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren30 : checkRenG PRE_first_tail_x6_r0_body.kd30.node PRE_first_tail_x6_r0_body.kninv30 (pnB PRE_first_tail_x6_r0_body.cx0_30.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow30 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd30.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P30.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd30.nodeF j) PRE_first_tail_x6_r0_body.cx1_30.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a30 : PRE_first_tail_x6_r0_body.cx0_30.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b30 : PRE_first_tail_x6_r0_body.cx0_30.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok130 : PRE_first_tail_x6_r0_body.cx1_30.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend30 : PRE_first_tail_x6_r0_body.cx1_30.mlx.pending = PRE_first_tail_x6_r0_body.cx0_30.mlx.pending.map PRE_first_tail_x6_r0_body.kappa30.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh30 : PRE_first_tail_x6_r0_body.cx1_30.mlx.errh = PRE_first_tail_x6_r0_body.cx0_30.mlx.errh.map PRE_first_tail_x6_r0_body.kappa30.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles30 : PRE_first_tail_x6_r0_body.cx1_30.mlx.files = PRE_first_tail_x6_r0_body.cx0_30.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch30 : PRE_first_tail_x6_r0_body.cx1_30.mlx.arch = PRE_first_tail_x6_r0_body.cx0_30.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes30 : PRE_first_tail_x6_r0_body.cx1_30.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_30.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired30 : PRE_first_tail_x6_r0_body.cx1_30.mlx.wired = PRE_first_tail_x6_r0_body.cx0_30.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost30 : PRE_first_tail_x6_r0_body.cx1_30.host = PRE_first_tail_x6_r0_body.cx0_30.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd30`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn030 : PRE_first_tail_x6_r0_body.kd30.n0 = 2698805
kernel_rfl PRE_first_tail_x6_r0_body.ckn130 : PRE_first_tail_x6_r0_body.kd30.n1 = 2699954
kernel_rfl PRE_first_tail_x6_r0_body.ckheap30 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd30.heap).all (fun x => Nat.ble 2698799 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl30 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd30.heap.get (2698799 + j) = nth? PRE_first_tail_x6_r0_body.pl30 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja30 : Nat.ble 2698799 2698799 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn30 : Nat.ble 1367 1367 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD30 : Nat.ble 2698799 PRE_first_tail_x6_r0_body.kd30.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn30 : Nat.ble 18802 PRE_first_tail_x6_r0_body.kd30.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn30 : Nat.ble 15878 PRE_first_tail_x6_r0_body.kd30.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb30 : Nat.ble 18802 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap30 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd30.heap).all (Nat.ble (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd30 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd30.hnd).all (Nat.ble (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode30 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd30.node).all (Nat.ble (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix30 : Conv.FixOld (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa30 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja30) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn30) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD30) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn30) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn30) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb30) PRE_first_tail_x6_r0_body.fheap30 PRE_first_tail_x6_r0_body.fhnd30 PRE_first_tail_x6_r0_body.fnode30
kernel_rfl PRE_first_tail_x6_r0_body.fcxn30 : (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn30 : (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle030 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_30.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_30.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk30 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd30.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A30 : PRE_first_tail_x6_r0_body.cx1_30.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS30.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_30.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O30 : PRE_first_tail_x6_r0_body.cx1_30.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS30.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_30.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N30 : PRE_first_tail_x6_r0_body.cx1_30.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS30.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_30.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I30 : PRE_first_tail_x6_r0_body.cx1_30.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS30.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_30.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd30 : (PRE_first_tail_x6_r0_body.clo30 ++ PRE_first_tail_x6_r0_body.cln30 ++ PRE_first_tail_x6_r0_body.cli30 ++ PRE_first_tail_x6_r0_body.cwS30 ++ PRE_first_tail_x6_r0_body.cnS30 ++ PRE_first_tail_x6_r0_body.ciS30).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW30 : PRE_first_tail_x6_r0_body.cwS30.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo30.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI30 : PRE_first_tail_x6_r0_body.ciS30.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli30.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN30 : PRE_first_tail_x6_r0_body.cnS30.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF30 : PRE_first_tail_x6_r0_body.cln30.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh30 : PRE_first_tail_x6_r0_body.clo30.all (handleOK PRE_first_tail_x6_r0_body.kappa30 PRE_first_tail_x6_r0_body.P30.lo PRE_first_tail_x6_r0_body.cx0_30.mlx PRE_first_tail_x6_r0_body.cx1_30.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo30 : PRE_first_tail_x6_r0_body.clo30.map (fun h => PRE_first_tail_x6_r0_body.cx1_30.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa30.handle h)) = PRE_first_tail_x6_r0_body.clo30.map (fun h => (PRE_first_tail_x6_r0_body.cx0_30.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa30.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok30 : PRE_first_tail_x6_r0_body.clo30.all (objOK PRE_first_tail_x6_r0_body.kappa30 PRE_first_tail_x6_r0_body.P30.NL PRE_first_tail_x6_r0_body.cx0_30.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd30 : PRE_first_tail_x6_r0_body.cln30.all (nodeOKF PRE_first_tail_x6_r0_body.kappa30 PRE_first_tail_x6_r0_body.P30 PRE_first_tail_x6_r0_body.cx0_30.mlx PRE_first_tail_x6_r0_body.cx1_30.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp30 : ((PRE_first_tail_x6_r0_body.cln30.filter (fullB PRE_first_tail_x6_r0_body.P30))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_30.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa30.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln30.filter (fullB PRE_first_tail_x6_r0_body.P30))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_30.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa30.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI30 : incrB PRE_first_tail_x6_r0_body.kd30.nodeF (List.range' 15878 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK30 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd30.node).all (fun k => Nat.ble 15878 k && Nat.blt k 15905) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL30 : (PRE_first_tail_x6_r0_body.cln30.filter (Nat.ble PRE_first_tail_x6_r0_body.P30.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd30.nodeF i) && (Nat.blt i 15905 || Nat.ble PRE_first_tail_x6_r0_body.kd30.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord30 : (PRE_first_tail_x6_r0_body.cln30.filter (Nat.ble PRE_first_tail_x6_r0_body.P30.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd30.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd30.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd30.nodeF j) (PRE_first_tail_x6_r0_body.kd30.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow30 PRE_first_tail_x6_r0_body.cnn130 PRE_first_tail_x6_r0_body.fnordI30 PRE_first_tail_x6_r0_body.fnordK30 PRE_first_tail_x6_r0_body.fnordL30
kernel_rfl PRE_first_tail_x6_r0_body.fi30 : PRE_first_tail_x6_r0_body.cli30.all (pnB PRE_first_tail_x6_r0_body.cx0_30.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii30 : PRE_first_tail_x6_r0_body.cli30.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_30.mlx.items.get (PRE_first_tail_x6_r0_body.kappa30.node k) = (PRE_first_tail_x6_r0_body.cx0_30.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa30.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot30 (clean : Conv.NClean (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P30.NL) (cl : SSt (· < 1385) PRE_first_tail_x6_r0_body.cx0_30.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P30 1385 PRE_first_tail_x6_r0_body.kappa30 PRE_first_tail_x6_r0_body.kd30 PRE_first_tail_x6_r0_body.khinv30 PRE_first_tail_x6_r0_body.kninv30 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx PRE_first_tail_x6_r0_body.cx0_30.mlx PRE_first_tail_x6_r0_body.cx1_30.mlx (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo30 PRE_first_tail_x6_r0_body.cln30 PRE_first_tail_x6_r0_body.cli30 PRE_first_tail_x6_r0_body.cwS30 PRE_first_tail_x6_r0_body.cnS30 PRE_first_tail_x6_r0_body.ciS30 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh030, PRE_first_tail_x6_r0_body.cnh130, PRE_first_tail_x6_r0_body.cnn030, PRE_first_tail_x6_r0_body.cnn130, PRE_first_tail_x6_r0_body.cplo30, PRE_first_tail_x6_r0_body.ccnt30, PRE_first_tail_x6_r0_body.cnband30, PRE_first_tail_x6_r0_body.chbelow30, PRE_first_tail_x6_r0_body.chren30, PRE_first_tail_x6_r0_body.cband30, PRE_first_tail_x6_r0_body.cnh1pos30, PRE_first_tail_x6_r0_body.cnren30, PRE_first_tail_x6_r0_body.cnlow30, PRE_first_tail_x6_r0_body.cabs0a30, PRE_first_tail_x6_r0_body.cabs0b30, PRE_first_tail_x6_r0_body.ctok130, PRE_first_tail_x6_r0_body.cpend30, PRE_first_tail_x6_r0_body.cerrh30, PRE_first_tail_x6_r0_body.cfiles30, PRE_first_tail_x6_r0_body.carch30, PRE_first_tail_x6_r0_body.csizes30, PRE_first_tail_x6_r0_body.cwired30, PRE_first_tail_x6_r0_body.cfix30, clean, PRE_first_tail_x6_r0_body.fcxn30, PRE_first_tail_x6_r0_body.fcnn30, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle030, PRE_first_tail_x6_r0_body.fnk30, PRE_first_tail_x6_r0_body.ckA30, PRE_first_tail_x6_r0_body.cobjsK30, PRE_first_tail_x6_r0_body.cnodesK30, PRE_first_tail_x6_r0_body.citemsK30, PRE_first_tail_x6_r0_body.f1A30, PRE_first_tail_x6_r0_body.f1O30, PRE_first_tail_x6_r0_body.f1N30, PRE_first_tail_x6_r0_body.f1I30, PRE_first_tail_x6_r0_body.fbd30, PRE_first_tail_x6_r0_body.fincW30, PRE_first_tail_x6_r0_body.fincI30, PRE_first_tail_x6_r0_body.fincN30, PRE_first_tail_x6_r0_body.flnF30, PRE_first_tail_x6_r0_body.fh30, PRE_first_tail_x6_r0_body.fo30, PRE_first_tail_x6_r0_body.fok30, PRE_first_tail_x6_r0_body.fnd30, PRE_first_tail_x6_r0_body.fp30, PRE_first_tail_x6_r0_body.fnord30, PRE_first_tail_x6_r0_body.fi30, PRE_first_tail_x6_r0_body.fii30⟩
theorem PRE_first_tail_x6_r0_body.cnshift30 (clean : Conv.NClean (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P30.NL) (cl : SSt (· < 1385) PRE_first_tail_x6_r0_body.cx0_30.mlx) : NShift PRE_first_tail_x6_r0_body.P30 1385 PRE_first_tail_x6_r0_body.kappa30 PRE_first_tail_x6_r0_body.cx0_30 PRE_first_tail_x6_r0_body.cx1_30 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot30 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost30 (compact_a_eq PRE_first_tail_x6_r0_body.ckn030 PRE_first_tail_x6_r0_body.ckn130 PRE_first_tail_x6_r0_body.ckheap30 PRE_first_tail_x6_r0_body.ckpl30)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_30 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s304.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_30 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s304.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_30 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s304.ffi) = some PRE_first_tail_x6_r0_body.fxC_30
kernel_rfl PRE_first_tail_x6_r0_body.okrC_30 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s304.ffi) = some PRE_first_tail_x6_r0_body.krC_30
noncomputable def PRE_first_tail_x6_r0_body.fx0_30 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s306.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_30 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s306.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_30 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s306.ffi) = some PRE_first_tail_x6_r0_body.fx0_30
kernel_rfl PRE_first_tail_x6_r0_body.okr0_30 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s306.ffi) = some PRE_first_tail_x6_r0_body.kr0_30
noncomputable def PRE_first_tail_x6_r0_body.fx1_30 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s305.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_30 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s305.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_30 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s305.ffi) = some PRE_first_tail_x6_r0_body.fx1_30
kernel_rfl PRE_first_tail_x6_r0_body.okr1_30 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s305.ffi) = some PRE_first_tail_x6_r0_body.kr1_30
kernel_rfl PRE_first_tail_x6_r0_body.ff030 : PRE_first_tail_x6_r0_body.fx0_30 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_30 (PRE_first_tail_x6_r0_body.clo30.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_30.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff130 : PRE_first_tail_x6_r0_body.fx1_30 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_30 (PRE_first_tail_x6_r0_body.cwS30.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_30.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck30 : freedLB PRE_first_tail_x6_r0_body.kappa30 PRE_first_tail_x6_r0_body.cx0_30.mlx PRE_first_tail_x6_r0_body.fx0_30 PRE_first_tail_x6_r0_body.fx1_30 PRE_first_tail_x6_r0_body.clo30 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf030 : PRE_first_tail_x6_r0_body.kr0_30.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_30.flags (PRE_first_tail_x6_r0_body.clo30.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_30.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt030 : PRE_first_tail_x6_r0_body.kr0_30.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_30.targs (PRE_first_tail_x6_r0_body.clo30.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_30.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf130 : PRE_first_tail_x6_r0_body.kr1_30.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_30.flags (PRE_first_tail_x6_r0_body.cwS30.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_30.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt130 : PRE_first_tail_x6_r0_body.kr1_30.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_30.targs (PRE_first_tail_x6_r0_body.cwS30.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_30.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck30 : krecLB PRE_first_tail_x6_r0_body.kappa30 1385 PRE_first_tail_x6_r0_body.cx0_30.mlx PRE_first_tail_x6_r0_body.kr0_30 PRE_first_tail_x6_r0_body.kr1_30 PRE_first_tail_x6_r0_body.clo30 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn30 : Nat.ble 1367 1385 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge30 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s305.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s306.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR30 : pendRegB PRE_first_tail_x6_r0_body.kappa30 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe30 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s305.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift30 (clean : Conv.NClean (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P30.NL) (cl : SSt (· < 1385) PRE_first_tail_x6_r0_body.cx0_30.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_30.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_30.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_30.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_30.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P30 1385 PRE_first_tail_x6_r0_body.kappa30 PRE_first_tail_x6_r0_body.s306.ffi PRE_first_tail_x6_r0_body.s305.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift30 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue30, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp30 t ht),
    PRE_first_tail_x6_r0_body.cbridge30,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s306.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s305.ffi) (PRE_first_tail_x6_r0_body.cfoot30 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_30 PRE_first_tail_x6_r0_body.ofx1_30 hobjC PRE_first_tail_x6_r0_body.ff030 PRE_first_tail_x6_r0_body.ff130 PRE_first_tail_x6_r0_body.ffck30,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s306.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s305.ffi) (PRE_first_tail_x6_r0_body.cfoot30 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_30 PRE_first_tail_x6_r0_body.okr1_30 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn30) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf030 PRE_first_tail_x6_r0_body.fkt030 PRE_first_tail_x6_r0_body.fkf130 PRE_first_tail_x6_r0_body.fkt130 PRE_first_tail_x6_r0_body.fkck30,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh030 PRE_first_tail_x6_r0_body.cnh130 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe30) PRE_first_tail_x6_r0_body.cpendR30⟩

end Host.Load.Run.Tpl
end

section -- st30/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st30 0
host_stream_state PRE_first_tail_x6_r0_body.st30 1
host_stream_state PRE_first_tail_x6_r0_body.st30 2
host_stream_state PRE_first_tail_x6_r0_body.st30 3
host_stream_state PRE_first_tail_x6_r0_body.st30 4
host_stream_state PRE_first_tail_x6_r0_body.st30 5
end Host.Load.Run.Tpl
end

section -- Site30
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 30 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g30__g31` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s304`, the merged state `PRE_first_tail_x6_r0_body.s305`,
the site template `PRE_first_tail_x6_r0_body.st30` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s306`: the merge.
The footprint's facts are in `SiteF30`, the compaction's in `SiteC30`, `SiteK30`, `SiteNa30`, `SiteNb30`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso30 : PRE_first_tail_x6_r0_body.st30.s0 = { PRE_first_tail_x6_r0_body.s304 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs30 : List Frame := PRE_first_tail_x6_r0_body.s304.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_30 : PRE_first_tail_x6_r0_body.S304.tab.length = 1367
kernel_rfl PRE_first_tail_x6_r0_body.tab0_30 : PRE_first_tail_x6_r0_body.st30.S0.tab = PRE_first_tail_x6_r0_body.S304.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws30 : List Nat := [1500, 1501, 1502, 1503, 1504, 1505, 1506, 1507, 1508, 1509, 1510, 1511, 1512, 1513, 1514, 1515, 1516, 1517, 1518, 1519, 1520, 1521, 1522, 1523, 1524, 1525, 1526, 1527, 1528, 1529, 1530]
kernel_rfl PRE_first_tail_x6_r0_body.fresh30 : (PRE_first_tail_x6_r0_body.S304.tab.all fun e => PRE_first_tail_x6_r0_body.ws30.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S304.oracle.all fun q => PRE_first_tail_x6_r0_body.ws30.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab30 : PRE_first_tail_x6_r0_body.S305.tab = PRE_first_tail_x6_r0_body.S304.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws30
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen30 : PRE_first_tail_x6_r0_body.st30.S5.tab.length - PRE_first_tail_x6_r0_body.st30.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged30`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap30 : PRE_first_tail_x6_r0_body.s305.heap = PRE_first_tail_x6_r0_body.st30.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext30 : PRE_first_tail_x6_r0_body.s305.next = PRE_first_tail_x6_r0_body.st30.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl30 : PRE_first_tail_x6_r0_body.s305.ctl = PRE_first_tail_x6_r0_body.st30.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack30 : PRE_first_tail_x6_r0_body.s305.stack = PRE_first_tail_x6_r0_body.st30.s5.stack ++ PRE_first_tail_x6_r0_body.s304.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs30 : PRE_first_tail_x6_r0_body.s305.jobs = PRE_first_tail_x6_r0_body.st30.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi30 : PRE_first_tail_x6_r0_body.s305.ffi = PRE_first_tail_x6_r0_body.st30.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace30 : PRE_first_tail_x6_r0_body.s305.trace = PRE_first_tail_x6_r0_body.st30.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores30 : PRE_first_tail_x6_r0_body.s305.stores = PRE_first_tail_x6_r0_body.st30.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD30
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 30 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived30 : PRE_first_tail_x6_r0_body.nr30.map (fun r => nth? PRE_first_tail_x6_r0_body.st30.S5.tab r) =
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
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo30 : PRE_first_tail_x6_r0_body.nr30.all (Nat.ble 1367) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj30 : PRE_first_tail_x6_r0_body.cws30.all (fun c => !PRE_first_tail_x6_r0_body.ws30.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ30 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws30 PRE_first_tail_x6_r0_body.crs30 PRE_first_tail_x6_r0_body.ws30

end Host.Load.Run.Tpl
end

section -- st30/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st30`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st30.wrR : List (Nat × Nat) := [(2672372, 2672373), (2697973, 2697974), (2698518, 2698519), (2698774, 2698775)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st30.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st30.s5.heap PRE_first_tail_x6_r0_body.st30.wrR ++ freshOf PRE_first_tail_x6_r0_body.st30.s5.heap PRE_first_tail_x6_r0_body.st30.s0.next PRE_first_tail_x6_r0_body.st30.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st30.wr : List Nat := PRE_first_tail_x6_r0_body.st30.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st30.heapFoot : PRE_first_tail_x6_r0_body.st30.s5.heap = setAll PRE_first_tail_x6_r0_body.st30.s0.heap PRE_first_tail_x6_r0_body.st30.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st30.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st30.s0.next PRE_first_tail_x6_r0_body.st30.s5.next = true
theorem PRE_first_tail_x6_r0_body.st30.grows : PRE_first_tail_x6_r0_body.st30.s0.next ≤ PRE_first_tail_x6_r0_body.st30.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st30.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st30.wh : List Nat := [18782, 18795, 18801, 18802, 18803, 18804, 18805, 18806, 18807, 18808, 18809, 18810, 18811, 18812, 18813, 18814, 18815, 18816, 18817, 18818, 18819, 18820, 18821, 18822, 18823, 18824, 18825, 18826, 18827, 18828, 18829]
def PRE_first_tail_x6_r0_body.st30.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st30.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st30.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st30.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st30.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st30.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st30.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st30.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st30.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st30.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF30
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 30 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB30 : nodupT PRE_first_tail_x6_r0_body.st30.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup30 : PRE_first_tail_x6_r0_body.st30.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB30).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB30 : PRE_first_tail_x6_r0_body.st30.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound30 : ∀ b ∈ PRE_first_tail_x6_r0_body.st30.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB30 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr30 := PRE_first_tail_x6_r0_body.st30.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq30 : PRE_first_tail_x6_r0_body.st30.s5.trace = PRE_first_tail_x6_r0_body.trFr30 ++ PRE_first_tail_x6_r0_body.st30.s0.trace
theorem PRE_first_tail_x6_r0_body.trace30 : ∃ fr, PRE_first_tail_x6_r0_body.st30.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st30.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq30⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide30 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB30 : (PRE_first_tail_x6_r0_body.wide30.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st30.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix30 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide30, WFix Map.id (Present PRE_first_tail_x6_r0_body.st30.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB30 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL30
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 30 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s305`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO30 : PRE_first_tail_x6_r0_body.st30.S0.oracle = PRE_first_tail_x6_r0_body.st30.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B30 : PRE_first_tail_x6_r0_body.st30.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st30.s0.next || (PRE_first_tail_x6_r0_body.st30.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot30 : Conv.StageFoot PRE_first_tail_x6_r0_body.st30.wr PRE_first_tail_x6_r0_body.st30.s0 PRE_first_tail_x6_r0_body.st30.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st30.heapFoot PRE_first_tail_x6_r0_body.wrNodup30 PRE_first_tail_x6_r0_body.wrBound30 PRE_first_tail_x6_r0_body.wr0B30 PRE_first_tail_x6_r0_body.st30.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged30 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st30.F.S → PRE_first_tail_x6_r0_body.st30.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st30.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st30.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs30 PRE_first_tail_x6_r0_body.st30.wr PRE_first_tail_x6_r0_body.s304 PRE_first_tail_x6_r0_body.st30.s5 PRE_first_tail_x6_r0_body.st30.s0
      PRE_first_tail_x6_r0_body.st30.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st30.F FR W stk M ν K PRE_first_tail_x6_r0_body.s305 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso30 PRE_first_tail_x6_r0_body.stFoot30 PRE_first_tail_x6_r0_body.wrNodup30 PRE_first_tail_x6_r0_body.wrBound30 PRE_first_tail_x6_r0_body.trace30 PRE_first_tail_x6_r0_body.mheap30
    PRE_first_tail_x6_r0_body.mnext30 PRE_first_tail_x6_r0_body.mctl30 PRE_first_tail_x6_r0_body.mstack30 PRE_first_tail_x6_r0_body.mjobs30 PRE_first_tail_x6_r0_body.mffi30 PRE_first_tail_x6_r0_body.mtrace30 PRE_first_tail_x6_r0_body.mstores30 h

def PRE_first_tail_x6_r0_body.arrEl30_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE30_2665 : arrOf PRE_first_tail_x6_r0_body.s305 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl30_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA30_2665 : isArrB PRE_first_tail_x6_r0_body.s305 2665 = true
theorem PRE_first_tail_x6_r0_body.arr30_2665 : ∃ o, PRE_first_tail_x6_r0_body.s305.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl30_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE30_2665 PRE_first_tail_x6_r0_body.arrA30_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN30_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl30_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR30_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl30_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN30_2665

def PRE_first_tail_x6_r0_body.arrEl30_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE30_2673467 : arrOf PRE_first_tail_x6_r0_body.s305 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl30_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA30_2673467 : isArrB PRE_first_tail_x6_r0_body.s305 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr30_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s305.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl30_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE30_2673467 PRE_first_tail_x6_r0_body.arrA30_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN30_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl30_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR30_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl30_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN30_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k30 : isArrB PRE_first_tail_x6_r0_body.s305 4910 = false
theorem PRE_first_tail_x6_r0_body.keep30 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s305 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k30 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr30_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl30_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ30
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 30 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s304`, the merged
state `PRE_first_tail_x6_r0_body.s305`, the canonical state `PRE_first_tail_x6_r0_body.s306`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl30 : PRE_first_tail_x6_r0_body.pl30.all (Nat.ble PRE_first_tail_x6_r0_body.s304.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd30 : nodupT PRE_first_tail_x6_r0_body.pl30 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn130 : Nat.ble PRE_first_tail_x6_r0_body.s304.next 2699954 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst30 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s304.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn30 : PRE_first_tail_x6_r0_body.s306.next = PRE_first_tail_x6_r0_body.s304.next + PRE_first_tail_x6_r0_body.pl30.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn30 : PRE_first_tail_x6_r0_body.s305.next = 2699954
kernel_rfl PRE_first_tail_x6_r0_body.zgrow30 : Nat.ble PRE_first_tail_x6_r0_body.s306.next PRE_first_tail_x6_r0_body.s305.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh30 : PRE_first_tail_x6_r0_body.S304.tab.all (fun e => PRE_first_tail_x6_r0_body.cws30.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd30 : nodupT PRE_first_tail_x6_r0_body.cws30 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi30 : PRE_first_tail_x6_r0_body.nr30.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S305.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt30 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s304.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg30_2665 : PRE_first_tail_x6_r0_body.s306.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s306 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk30_2665 : (objOf PRE_first_tail_x6_r0_body.s306 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm30_2665 : PRE_first_tail_x6_r0_body.s305.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa30.obj (objOf PRE_first_tail_x6_r0_body.s306 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s305 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg30_2673467 : PRE_first_tail_x6_r0_body.s306.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s306 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk30_2673467 : (objOf PRE_first_tail_x6_r0_body.s306 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm30_2673467 : PRE_first_tail_x6_r0_body.s305.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa30.obj (objOf PRE_first_tail_x6_r0_body.s306 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s305 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw30_4910 : (PRE_first_tail_x6_r0_body.s306.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw30_2673472 : (PRE_first_tail_x6_r0_body.s306.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw30_2673473 : (PRE_first_tail_x6_r0_body.s306.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd30 : PRE_first_tail_x6_r0_body.cl30.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr30 : PRE_first_tail_x6_r0_body.st30.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s304.next || PRE_first_tail_x6_r0_body.cl30.contains b) = true
def PRE_first_tail_x6_r0_body.zl30 : List Nat := PRE_first_tail_x6_r0_body.cl30.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE30 : PRE_first_tail_x6_r0_body.zl30.map (fun a => PRE_first_tail_x6_r0_body.s305.heap.get (PRE_first_tail_x6_r0_body.kappa30.a a)) = PRE_first_tail_x6_r0_body.zl30.map (fun a => (PRE_first_tail_x6_r0_body.s306.heap.get a).map PRE_first_tail_x6_r0_body.kappa30.hobj)
theorem PRE_first_tail_x6_r0_body.zimg30 : HeapImg PRE_first_tail_x6_r0_body.kappa30 PRE_first_tail_x6_r0_body.s306 PRE_first_tail_x6_r0_body.s305 PRE_first_tail_x6_r0_body.zl30 := PRE_first_tail_x6_r0_body.zimgE30
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl30 : PRE_first_tail_x6_r0_body.s305.ctl = PRE_first_tail_x6_r0_body.kappa30.ctl PRE_first_tail_x6_r0_body.s306.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack30 : PRE_first_tail_x6_r0_body.s305.stack = PRE_first_tail_x6_r0_body.s306.stack.map PRE_first_tail_x6_r0_body.kappa30.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs30 : PRE_first_tail_x6_r0_body.s305.jobs = PRE_first_tail_x6_r0_body.s306.jobs.map PRE_first_tail_x6_r0_body.kappa30.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores30 : PRE_first_tail_x6_r0_body.s305.stores = PRE_first_tail_x6_r0_body.kappa30.stores PRE_first_tail_x6_r0_body.s306.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots30 : checkRootsSupp PRE_first_tail_x6_r0_body.s306 1385 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC30 : PRE_first_tail_x6_r0_body.S304.tab.length + PRE_first_tail_x6_r0_body.cws30.length = 1385
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap30 : PRE_first_tail_x6_r0_body.kappa30 = Conv.Map.compact PRE_first_tail_x6_r0_body.s304.next 2699954 PRE_first_tail_x6_r0_body.S304.tab.length PRE_first_tail_x6_r0_body.pl30 (PRE_first_tail_x6_r0_body.nr30.map NumV.ref) PRE_first_tail_x6_r0_body.kd30.big
  PRE_first_tail_x6_r0_body.kd30.region PRE_first_tail_x6_r0_body.kd30.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin30 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s306.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc30 : Conv.jcleanListB (⟨18805, 15905, 2698805, 1385⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s306 PRE_first_tail_x6_r0_body.cl30 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB30 : noBigRootsP (fun i => !Conv.oldBigB (⟨18805, 15905, 2698805, 1385⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s306.trace PRE_first_tail_x6_r0_body.s306 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm30 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15878 = true
theorem PRE_first_tail_x6_r0_body.cjcl30 (h : Conv.JClean (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s304) : Conv.JClean (⟨18805, 15905, 2698805, 1385⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s306 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle30)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap30 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd30 a ha)) PRE_first_tail_x6_r0_body.zjc30

end Host.Load.Run.Tpl
end

section -- st30/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st30.bodyLast from PRE_first_tail_x6_r0_body.st30.s4 to PRE_first_tail_x6_r0_body.st30.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st30.F PRE_first_tail_x6_r0_body.st30.s4).run PRE_first_tail_x6_r0_body.st30.S4 = some (PRE_first_tail_x6_r0_body.st30.s5, PRE_first_tail_x6_r0_body.st30.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st30.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st30.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st30.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st30.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st30/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st30.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st30.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st30.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st30.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st30.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st30.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st30.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st30.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st30.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st30.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st30.s0 PRE_first_tail_x6_r0_body.st30.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st30.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st30.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st30.s4 PRE_first_tail_x6_r0_body.st30.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st30/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st30.bodyK0F from PRE_first_tail_x6_r0_body.st30.s0 to PRE_first_tail_x6_r0_body.st30.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st30.F (PRE_first_tail_x6_r0_body.st30.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st30.ks 0).getD 0) PRE_first_tail_x6_r0_body.st30.s0 PRE_first_tail_x6_r0_body.st30.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st30.s1, PRE_first_tail_x6_r0_body.st30.S1)
theorem PRE_first_tail_x6_r0_body.st30.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st30.F (PRE_first_tail_x6_r0_body.st30.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st30.ks 0).getD 0) PRE_first_tail_x6_r0_body.st30.s0 PRE_first_tail_x6_r0_body.st30.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st30.s1, PRE_first_tail_x6_r0_body.st30.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st30.bodyOkLN_ok PRE_first_tail_x6_r0_body.st30.bodyK0F
end Host.Load.Run.Tpl
end

section -- st30/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st30.bodyK1F from PRE_first_tail_x6_r0_body.st30.s1 to PRE_first_tail_x6_r0_body.st30.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st30.F (PRE_first_tail_x6_r0_body.st30.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st30.ks 1).getD 0) PRE_first_tail_x6_r0_body.st30.s1 PRE_first_tail_x6_r0_body.st30.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st30.s2, PRE_first_tail_x6_r0_body.st30.S2)
theorem PRE_first_tail_x6_r0_body.st30.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st30.F (PRE_first_tail_x6_r0_body.st30.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st30.ks 1).getD 0) PRE_first_tail_x6_r0_body.st30.s1 PRE_first_tail_x6_r0_body.st30.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st30.s2, PRE_first_tail_x6_r0_body.st30.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st30.bodyOkLN_ok PRE_first_tail_x6_r0_body.st30.bodyK1F
end Host.Load.Run.Tpl
end

section -- st30/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st30.bodyK2F from PRE_first_tail_x6_r0_body.st30.s2 to PRE_first_tail_x6_r0_body.st30.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st30.F (PRE_first_tail_x6_r0_body.st30.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st30.ks 2).getD 0) PRE_first_tail_x6_r0_body.st30.s2 PRE_first_tail_x6_r0_body.st30.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st30.s3, PRE_first_tail_x6_r0_body.st30.S3)
theorem PRE_first_tail_x6_r0_body.st30.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st30.F (PRE_first_tail_x6_r0_body.st30.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st30.ks 2).getD 0) PRE_first_tail_x6_r0_body.st30.s2 PRE_first_tail_x6_r0_body.st30.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st30.s3, PRE_first_tail_x6_r0_body.st30.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st30.bodyOkLN_ok PRE_first_tail_x6_r0_body.st30.bodyK2F
end Host.Load.Run.Tpl
end

section -- st30/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st30.bodyK3F from PRE_first_tail_x6_r0_body.st30.s3 to PRE_first_tail_x6_r0_body.st30.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st30.F (PRE_first_tail_x6_r0_body.st30.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st30.ks 3).getD 0) PRE_first_tail_x6_r0_body.st30.s3 PRE_first_tail_x6_r0_body.st30.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st30.s4, PRE_first_tail_x6_r0_body.st30.S4)
theorem PRE_first_tail_x6_r0_body.st30.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st30.F (PRE_first_tail_x6_r0_body.st30.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st30.ks 3).getD 0) PRE_first_tail_x6_r0_body.st30.s3 PRE_first_tail_x6_r0_body.st30.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st30.s4, PRE_first_tail_x6_r0_body.st30.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st30.bodyOkLN_ok PRE_first_tail_x6_r0_body.st30.bodyK3F
end Host.Load.Run.Tpl
end

section -- st30/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st30.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st30.F (PRE_first_tail_x6_r0_body.st30.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st30.s0 PRE_first_tail_x6_r0_body.st30.S0 = some (PRE_first_tail_x6_r0_body.st30.s4, PRE_first_tail_x6_r0_body.st30.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st30.F (PRE_first_tail_x6_r0_body.st30.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st30.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st30.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st30.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st30.ks 3).getD 0) PRE_first_tail_x6_r0_body.st30.s0 PRE_first_tail_x6_r0_body.st30.s3 PRE_first_tail_x6_r0_body.st30.s4 PRE_first_tail_x6_r0_body.st30.S0 PRE_first_tail_x6_r0_body.st30.S3 PRE_first_tail_x6_r0_body.st30.S4 (runOk_trans PRE_first_tail_x6_r0_body.st30.F (PRE_first_tail_x6_r0_body.st30.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st30.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st30.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st30.ks 2).getD 0) PRE_first_tail_x6_r0_body.st30.s0 PRE_first_tail_x6_r0_body.st30.s2 PRE_first_tail_x6_r0_body.st30.s3 PRE_first_tail_x6_r0_body.st30.S0 PRE_first_tail_x6_r0_body.st30.S2 PRE_first_tail_x6_r0_body.st30.S3 (runOk_trans PRE_first_tail_x6_r0_body.st30.F (PRE_first_tail_x6_r0_body.st30.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st30.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st30.ks 1).getD 0) PRE_first_tail_x6_r0_body.st30.s0 PRE_first_tail_x6_r0_body.st30.s1 PRE_first_tail_x6_r0_body.st30.s2 PRE_first_tail_x6_r0_body.st30.S0 PRE_first_tail_x6_r0_body.st30.S1 PRE_first_tail_x6_r0_body.st30.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st30.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st30.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st30.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st30.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st30.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st30.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st30.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st30.F (PRE_first_tail_x6_r0_body.st30.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st30.s0
  S0 := PRE_first_tail_x6_r0_body.st30.S0
  s1 := PRE_first_tail_x6_r0_body.st30.s4
  S1 := PRE_first_tail_x6_r0_body.st30.S4
  s2 := PRE_first_tail_x6_r0_body.st30.s5
  S2 := PRE_first_tail_x6_r0_body.st30.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st30.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st30.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st30.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st30.bodyHalt
  last := PRE_first_tail_x6_r0_body.st30.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st30.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC31
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 31 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s314` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa31` into the merged state
`PRE_first_tail_x6_r0_body.s313`. -/

def PRE_first_tail_x6_r0_body.pl31 : List Nat := []
def PRE_first_tail_x6_r0_body.nr31 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd31 : RData :=
  ⟨2699295, 2699297, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18818, 18818, 15918, 15918, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa31 : Map :=
  Conv.Map.compact 2699295 2699297 1406 PRE_first_tail_x6_r0_body.pl31 (PRE_first_tail_x6_r0_body.nr31.map NumV.ref) PRE_first_tail_x6_r0_body.kd31.big
    PRE_first_tail_x6_r0_body.kd31.region PRE_first_tail_x6_r0_body.kd31.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws31 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs31 : List SymE := PRE_first_tail_x6_r0_body.nr31.map fun r => (nth? PRE_first_tail_x6_r0_body.S313.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta31 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws31 PRE_first_tail_x6_r0_body.crs31
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB31 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab31 : PRE_first_tail_x6_r0_body.S314.tab = PRE_first_tail_x6_r0_body.S312.tab ++ PRE_first_tail_x6_r0_body.cws31.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace31 : PRE_first_tail_x6_r0_body.s314.trace = PRE_first_tail_x6_r0_body.s312.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext31 : PRE_first_tail_x6_r0_body.s314.next = 2699295
kernel_rfl PRE_first_tail_x6_r0_body.ccounters31 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx.nnext) = (18818, 15918)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue31 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s313.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa31.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp31 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx.tokens.all (bSN 1406) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean31 : Conv.cleanListB 18818 131072 (fun r => Nat.ble 75272 r) PRE_first_tail_x6_r0_body.s314
    (PRE_first_tail_x6_r0_body.wrB31 ++ (List.range 0).map (2699295 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs31 : bigsOutB 18818 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK31
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl31`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl31 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo31 : List Nat := []
def PRE_first_tail_x6_r0_body.cln31 : List Nat := []
def PRE_first_tail_x6_r0_body.cli31 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap31 : PRE_first_tail_x6_r0_body.s314.heap = Stage.setAll PRE_first_tail_x6_r0_body.s312.heap (PRE_first_tail_x6_r0_body.cl31.filterMap fun a => (PRE_first_tail_x6_r0_body.s314.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe31 : Nat.ble PRE_first_tail_x6_r0_body.s312.next PRE_first_tail_x6_r0_body.s314.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP31 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s312 PRE_first_tail_x6_r0_body.s314 PRE_first_tail_x6_r0_body.cl31 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp31 : Conv.suppListB PRE_first_tail_x6_r0_body.s314 1406 PRE_first_tail_x6_r0_body.cl31 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound31 : Conv.boundListB PRE_first_tail_x6_r0_body.s314 PRE_first_tail_x6_r0_body.cl31 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK31 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln31.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK31 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo31.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK31 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli31.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst31 : Conv.sstListB 1406 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx PRE_first_tail_x6_r0_body.cln31 PRE_first_tail_x6_r0_body.clo31 PRE_first_tail_x6_r0_body.cli31 = true

end Host.Load.Run.Tpl
end

section -- SiteCl31
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA31 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo31.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd31 : (PRE_first_tail_x6_r0_body.clo31 ++ PRE_first_tail_x6_r0_body.cln31 ++ PRE_first_tail_x6_r0_body.cli31).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle31 : Conv.Cnt.leB (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck31 : Conv.ncleanListB (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx PRE_first_tail_x6_r0_body.clo31 PRE_first_tail_x6_r0_body.cln31 PRE_first_tail_x6_r0_body.cli31 = true
theorem PRE_first_tail_x6_r0_body.cncl31 (h : Conv.NClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx) : Conv.NClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle31 PRE_first_tail_x6_r0_body.ckA31 PRE_first_tail_x6_r0_body.cobjsK31 PRE_first_tail_x6_r0_body.cnodesK31 PRE_first_tail_x6_r0_body.citemsK31 PRE_first_tail_x6_r0_body.cbd31 PRE_first_tail_x6_r0_body.cck31

end Host.Load.Run.Tpl
end

section -- SiteS31
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 31 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc31 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P31 : LoadP := PRE_first_tail_x6_r0_body.Pc31.raise 15918
kernel_rfl PRE_first_tail_x6_r0_body.craise31 : Nat.ble PRE_first_tail_x6_r0_body.Pc31.N0 15918 = true
theorem PRE_first_tail_x6_r0_body.raised31 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc31 PRE_first_tail_x6_r0_body.P31 :=
  .inr ⟨15918, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise31, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_31 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_31 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s313.ffi)
def PRE_first_tail_x6_r0_body.khinv31 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv31 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS31 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS31 : List Nat := List.range' 15918 0
def PRE_first_tail_x6_r0_body.ciS31 : List Nat := [] ++ List.range' 15918 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh031 : PRE_first_tail_x6_r0_body.kd31.nh0 = PRE_first_tail_x6_r0_body.cx0_31.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh131 : PRE_first_tail_x6_r0_body.kd31.nh1 = PRE_first_tail_x6_r0_body.cx1_31.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn031 : PRE_first_tail_x6_r0_body.kd31.nn0 = PRE_first_tail_x6_r0_body.cx0_31.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn131 : PRE_first_tail_x6_r0_body.kd31.nn1 = PRE_first_tail_x6_r0_body.cx1_31.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo31 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P31.lo && Nat.ble PRE_first_tail_x6_r0_body.P31.lo PRE_first_tail_x6_r0_body.cx0_31.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P31.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P31.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt31 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_31.mlx.next PRE_first_tail_x6_r0_body.cx1_31.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_31.mlx.nnext PRE_first_tail_x6_r0_body.cx1_31.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband31 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P31.NL && Nat.ble PRE_first_tail_x6_r0_body.P31.NL PRE_first_tail_x6_r0_body.P31.N0 && Nat.ble PRE_first_tail_x6_r0_body.P31.N0 PRE_first_tail_x6_r0_body.cx0_31.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow31 : PRE_first_tail_x6_r0_body.kd31.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren31 : checkRenG PRE_first_tail_x6_r0_body.kd31.hnd PRE_first_tail_x6_r0_body.khinv31 (phB PRE_first_tail_x6_r0_body.cx0_31.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband31 : PRE_first_tail_x6_r0_body.kd31.checkBand PRE_first_tail_x6_r0_body.P31.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos31 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd31.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren31 : checkRenG PRE_first_tail_x6_r0_body.kd31.node PRE_first_tail_x6_r0_body.kninv31 (pnB PRE_first_tail_x6_r0_body.cx0_31.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow31 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd31.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P31.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd31.nodeF j) PRE_first_tail_x6_r0_body.cx1_31.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a31 : PRE_first_tail_x6_r0_body.cx0_31.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b31 : PRE_first_tail_x6_r0_body.cx0_31.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok131 : PRE_first_tail_x6_r0_body.cx1_31.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend31 : PRE_first_tail_x6_r0_body.cx1_31.mlx.pending = PRE_first_tail_x6_r0_body.cx0_31.mlx.pending.map PRE_first_tail_x6_r0_body.kappa31.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh31 : PRE_first_tail_x6_r0_body.cx1_31.mlx.errh = PRE_first_tail_x6_r0_body.cx0_31.mlx.errh.map PRE_first_tail_x6_r0_body.kappa31.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles31 : PRE_first_tail_x6_r0_body.cx1_31.mlx.files = PRE_first_tail_x6_r0_body.cx0_31.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch31 : PRE_first_tail_x6_r0_body.cx1_31.mlx.arch = PRE_first_tail_x6_r0_body.cx0_31.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes31 : PRE_first_tail_x6_r0_body.cx1_31.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_31.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired31 : PRE_first_tail_x6_r0_body.cx1_31.mlx.wired = PRE_first_tail_x6_r0_body.cx0_31.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost31 : PRE_first_tail_x6_r0_body.cx1_31.host = PRE_first_tail_x6_r0_body.cx0_31.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd31`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn031 : PRE_first_tail_x6_r0_body.kd31.n0 = 2699295
kernel_rfl PRE_first_tail_x6_r0_body.ckn131 : PRE_first_tail_x6_r0_body.kd31.n1 = 2699297
kernel_rfl PRE_first_tail_x6_r0_body.ckheap31 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd31.heap).all (fun x => Nat.ble 2699295 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl31 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd31.heap.get (2699295 + j) = nth? PRE_first_tail_x6_r0_body.pl31 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja31 : Nat.ble 2699295 2699295 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn31 : Nat.ble 1406 1406 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD31 : Nat.ble 2699295 PRE_first_tail_x6_r0_body.kd31.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn31 : Nat.ble 18818 PRE_first_tail_x6_r0_body.kd31.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn31 : Nat.ble 15918 PRE_first_tail_x6_r0_body.kd31.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb31 : Nat.ble 18818 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap31 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd31.heap).all (Nat.ble (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd31 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd31.hnd).all (Nat.ble (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode31 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd31.node).all (Nat.ble (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix31 : Conv.FixOld (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa31 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja31) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn31) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD31) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn31) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn31) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb31) PRE_first_tail_x6_r0_body.fheap31 PRE_first_tail_x6_r0_body.fhnd31 PRE_first_tail_x6_r0_body.fnode31
kernel_rfl PRE_first_tail_x6_r0_body.fcxn31 : (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn31 : (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle031 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_31.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_31.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk31 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd31.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A31 : PRE_first_tail_x6_r0_body.cx1_31.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS31.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_31.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O31 : PRE_first_tail_x6_r0_body.cx1_31.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS31.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_31.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N31 : PRE_first_tail_x6_r0_body.cx1_31.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS31.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_31.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I31 : PRE_first_tail_x6_r0_body.cx1_31.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS31.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_31.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd31 : (PRE_first_tail_x6_r0_body.clo31 ++ PRE_first_tail_x6_r0_body.cln31 ++ PRE_first_tail_x6_r0_body.cli31 ++ PRE_first_tail_x6_r0_body.cwS31 ++ PRE_first_tail_x6_r0_body.cnS31 ++ PRE_first_tail_x6_r0_body.ciS31).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW31 : PRE_first_tail_x6_r0_body.cwS31.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo31.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI31 : PRE_first_tail_x6_r0_body.ciS31.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli31.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN31 : PRE_first_tail_x6_r0_body.cnS31.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF31 : PRE_first_tail_x6_r0_body.cln31.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh31 : PRE_first_tail_x6_r0_body.clo31.all (handleOK PRE_first_tail_x6_r0_body.kappa31 PRE_first_tail_x6_r0_body.P31.lo PRE_first_tail_x6_r0_body.cx0_31.mlx PRE_first_tail_x6_r0_body.cx1_31.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo31 : PRE_first_tail_x6_r0_body.clo31.map (fun h => PRE_first_tail_x6_r0_body.cx1_31.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa31.handle h)) = PRE_first_tail_x6_r0_body.clo31.map (fun h => (PRE_first_tail_x6_r0_body.cx0_31.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa31.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok31 : PRE_first_tail_x6_r0_body.clo31.all (objOK PRE_first_tail_x6_r0_body.kappa31 PRE_first_tail_x6_r0_body.P31.NL PRE_first_tail_x6_r0_body.cx0_31.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd31 : PRE_first_tail_x6_r0_body.cln31.all (nodeOKF PRE_first_tail_x6_r0_body.kappa31 PRE_first_tail_x6_r0_body.P31 PRE_first_tail_x6_r0_body.cx0_31.mlx PRE_first_tail_x6_r0_body.cx1_31.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp31 : ((PRE_first_tail_x6_r0_body.cln31.filter (fullB PRE_first_tail_x6_r0_body.P31))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_31.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa31.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln31.filter (fullB PRE_first_tail_x6_r0_body.P31))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_31.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa31.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI31 : incrB PRE_first_tail_x6_r0_body.kd31.nodeF (List.range' 15918 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK31 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd31.node).all (fun k => Nat.ble 15918 k && Nat.blt k 15918) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL31 : (PRE_first_tail_x6_r0_body.cln31.filter (Nat.ble PRE_first_tail_x6_r0_body.P31.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd31.nodeF i) && (Nat.blt i 15918 || Nat.ble PRE_first_tail_x6_r0_body.kd31.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord31 : (PRE_first_tail_x6_r0_body.cln31.filter (Nat.ble PRE_first_tail_x6_r0_body.P31.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd31.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd31.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd31.nodeF j) (PRE_first_tail_x6_r0_body.kd31.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow31 PRE_first_tail_x6_r0_body.cnn131 PRE_first_tail_x6_r0_body.fnordI31 PRE_first_tail_x6_r0_body.fnordK31 PRE_first_tail_x6_r0_body.fnordL31
kernel_rfl PRE_first_tail_x6_r0_body.fi31 : PRE_first_tail_x6_r0_body.cli31.all (pnB PRE_first_tail_x6_r0_body.cx0_31.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii31 : PRE_first_tail_x6_r0_body.cli31.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_31.mlx.items.get (PRE_first_tail_x6_r0_body.kappa31.node k) = (PRE_first_tail_x6_r0_body.cx0_31.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa31.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot31 (clean : Conv.NClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P31.NL) (cl : SSt (· < 1406) PRE_first_tail_x6_r0_body.cx0_31.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P31 1406 PRE_first_tail_x6_r0_body.kappa31 PRE_first_tail_x6_r0_body.kd31 PRE_first_tail_x6_r0_body.khinv31 PRE_first_tail_x6_r0_body.kninv31 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx PRE_first_tail_x6_r0_body.cx0_31.mlx PRE_first_tail_x6_r0_body.cx1_31.mlx (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo31 PRE_first_tail_x6_r0_body.cln31 PRE_first_tail_x6_r0_body.cli31 PRE_first_tail_x6_r0_body.cwS31 PRE_first_tail_x6_r0_body.cnS31 PRE_first_tail_x6_r0_body.ciS31 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh031, PRE_first_tail_x6_r0_body.cnh131, PRE_first_tail_x6_r0_body.cnn031, PRE_first_tail_x6_r0_body.cnn131, PRE_first_tail_x6_r0_body.cplo31, PRE_first_tail_x6_r0_body.ccnt31, PRE_first_tail_x6_r0_body.cnband31, PRE_first_tail_x6_r0_body.chbelow31, PRE_first_tail_x6_r0_body.chren31, PRE_first_tail_x6_r0_body.cband31, PRE_first_tail_x6_r0_body.cnh1pos31, PRE_first_tail_x6_r0_body.cnren31, PRE_first_tail_x6_r0_body.cnlow31, PRE_first_tail_x6_r0_body.cabs0a31, PRE_first_tail_x6_r0_body.cabs0b31, PRE_first_tail_x6_r0_body.ctok131, PRE_first_tail_x6_r0_body.cpend31, PRE_first_tail_x6_r0_body.cerrh31, PRE_first_tail_x6_r0_body.cfiles31, PRE_first_tail_x6_r0_body.carch31, PRE_first_tail_x6_r0_body.csizes31, PRE_first_tail_x6_r0_body.cwired31, PRE_first_tail_x6_r0_body.cfix31, clean, PRE_first_tail_x6_r0_body.fcxn31, PRE_first_tail_x6_r0_body.fcnn31, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle031, PRE_first_tail_x6_r0_body.fnk31, PRE_first_tail_x6_r0_body.ckA31, PRE_first_tail_x6_r0_body.cobjsK31, PRE_first_tail_x6_r0_body.cnodesK31, PRE_first_tail_x6_r0_body.citemsK31, PRE_first_tail_x6_r0_body.f1A31, PRE_first_tail_x6_r0_body.f1O31, PRE_first_tail_x6_r0_body.f1N31, PRE_first_tail_x6_r0_body.f1I31, PRE_first_tail_x6_r0_body.fbd31, PRE_first_tail_x6_r0_body.fincW31, PRE_first_tail_x6_r0_body.fincI31, PRE_first_tail_x6_r0_body.fincN31, PRE_first_tail_x6_r0_body.flnF31, PRE_first_tail_x6_r0_body.fh31, PRE_first_tail_x6_r0_body.fo31, PRE_first_tail_x6_r0_body.fok31, PRE_first_tail_x6_r0_body.fnd31, PRE_first_tail_x6_r0_body.fp31, PRE_first_tail_x6_r0_body.fnord31, PRE_first_tail_x6_r0_body.fi31, PRE_first_tail_x6_r0_body.fii31⟩
theorem PRE_first_tail_x6_r0_body.cnshift31 (clean : Conv.NClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P31.NL) (cl : SSt (· < 1406) PRE_first_tail_x6_r0_body.cx0_31.mlx) : NShift PRE_first_tail_x6_r0_body.P31 1406 PRE_first_tail_x6_r0_body.kappa31 PRE_first_tail_x6_r0_body.cx0_31 PRE_first_tail_x6_r0_body.cx1_31 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot31 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost31 (compact_a_eq PRE_first_tail_x6_r0_body.ckn031 PRE_first_tail_x6_r0_body.ckn131 PRE_first_tail_x6_r0_body.ckheap31 PRE_first_tail_x6_r0_body.ckpl31)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_31 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s312.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_31 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s312.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_31 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s312.ffi) = some PRE_first_tail_x6_r0_body.fxC_31
kernel_rfl PRE_first_tail_x6_r0_body.okrC_31 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s312.ffi) = some PRE_first_tail_x6_r0_body.krC_31
noncomputable def PRE_first_tail_x6_r0_body.fx0_31 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s314.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_31 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s314.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_31 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s314.ffi) = some PRE_first_tail_x6_r0_body.fx0_31
kernel_rfl PRE_first_tail_x6_r0_body.okr0_31 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s314.ffi) = some PRE_first_tail_x6_r0_body.kr0_31
noncomputable def PRE_first_tail_x6_r0_body.fx1_31 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s313.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_31 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s313.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_31 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s313.ffi) = some PRE_first_tail_x6_r0_body.fx1_31
kernel_rfl PRE_first_tail_x6_r0_body.okr1_31 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s313.ffi) = some PRE_first_tail_x6_r0_body.kr1_31
kernel_rfl PRE_first_tail_x6_r0_body.ff031 : PRE_first_tail_x6_r0_body.fx0_31 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_31 (PRE_first_tail_x6_r0_body.clo31.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_31.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff131 : PRE_first_tail_x6_r0_body.fx1_31 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_31 (PRE_first_tail_x6_r0_body.cwS31.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_31.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck31 : freedLB PRE_first_tail_x6_r0_body.kappa31 PRE_first_tail_x6_r0_body.cx0_31.mlx PRE_first_tail_x6_r0_body.fx0_31 PRE_first_tail_x6_r0_body.fx1_31 PRE_first_tail_x6_r0_body.clo31 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf031 : PRE_first_tail_x6_r0_body.kr0_31.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_31.flags (PRE_first_tail_x6_r0_body.clo31.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_31.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt031 : PRE_first_tail_x6_r0_body.kr0_31.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_31.targs (PRE_first_tail_x6_r0_body.clo31.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_31.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf131 : PRE_first_tail_x6_r0_body.kr1_31.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_31.flags (PRE_first_tail_x6_r0_body.cwS31.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_31.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt131 : PRE_first_tail_x6_r0_body.kr1_31.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_31.targs (PRE_first_tail_x6_r0_body.cwS31.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_31.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck31 : krecLB PRE_first_tail_x6_r0_body.kappa31 1406 PRE_first_tail_x6_r0_body.cx0_31.mlx PRE_first_tail_x6_r0_body.kr0_31 PRE_first_tail_x6_r0_body.kr1_31 PRE_first_tail_x6_r0_body.clo31 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn31 : Nat.ble 1406 1406 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge31 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s313.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s314.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR31 : pendRegB PRE_first_tail_x6_r0_body.kappa31 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe31 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s313.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift31 (clean : Conv.NClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P31.NL) (cl : SSt (· < 1406) PRE_first_tail_x6_r0_body.cx0_31.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_31.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_31.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_31.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_31.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P31 1406 PRE_first_tail_x6_r0_body.kappa31 PRE_first_tail_x6_r0_body.s314.ffi PRE_first_tail_x6_r0_body.s313.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift31 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue31, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp31 t ht),
    PRE_first_tail_x6_r0_body.cbridge31,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s314.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s313.ffi) (PRE_first_tail_x6_r0_body.cfoot31 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_31 PRE_first_tail_x6_r0_body.ofx1_31 hobjC PRE_first_tail_x6_r0_body.ff031 PRE_first_tail_x6_r0_body.ff131 PRE_first_tail_x6_r0_body.ffck31,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s314.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s313.ffi) (PRE_first_tail_x6_r0_body.cfoot31 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_31 PRE_first_tail_x6_r0_body.okr1_31 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn31) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf031 PRE_first_tail_x6_r0_body.fkt031 PRE_first_tail_x6_r0_body.fkf131 PRE_first_tail_x6_r0_body.fkt131 PRE_first_tail_x6_r0_body.fkck31,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh031 PRE_first_tail_x6_r0_body.cnh131 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe31) PRE_first_tail_x6_r0_body.cpendR31⟩

end Host.Load.Run.Tpl
end

section -- st31/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st31 0
host_stream_state PRE_first_tail_x6_r0_body.st31 1
host_stream_state PRE_first_tail_x6_r0_body.st31 2
end Host.Load.Run.Tpl
end

section -- Site31
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 31 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g31__g32` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s312`, the merged state `PRE_first_tail_x6_r0_body.s313`,
the site template `PRE_first_tail_x6_r0_body.st31` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s314`: the merge.
The footprint's facts are in `SiteF31`, the compaction's in `SiteC31`, `SiteK31`, `SiteNa31`, `SiteNb31`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso31 : PRE_first_tail_x6_r0_body.st31.s0 = { PRE_first_tail_x6_r0_body.s312 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs31 : List Frame := PRE_first_tail_x6_r0_body.s312.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_31 : PRE_first_tail_x6_r0_body.S312.tab.length = 1406
kernel_rfl PRE_first_tail_x6_r0_body.tab0_31 : PRE_first_tail_x6_r0_body.st31.S0.tab = PRE_first_tail_x6_r0_body.S312.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws31 : List Nat := [1549, 1550]
kernel_rfl PRE_first_tail_x6_r0_body.fresh31 : (PRE_first_tail_x6_r0_body.S312.tab.all fun e => PRE_first_tail_x6_r0_body.ws31.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S312.oracle.all fun q => PRE_first_tail_x6_r0_body.ws31.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab31 : PRE_first_tail_x6_r0_body.S313.tab = PRE_first_tail_x6_r0_body.S312.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws31
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen31 : PRE_first_tail_x6_r0_body.st31.S2.tab.length - PRE_first_tail_x6_r0_body.st31.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged31`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap31 : PRE_first_tail_x6_r0_body.s313.heap = PRE_first_tail_x6_r0_body.st31.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext31 : PRE_first_tail_x6_r0_body.s313.next = PRE_first_tail_x6_r0_body.st31.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl31 : PRE_first_tail_x6_r0_body.s313.ctl = PRE_first_tail_x6_r0_body.st31.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack31 : PRE_first_tail_x6_r0_body.s313.stack = PRE_first_tail_x6_r0_body.st31.s2.stack ++ PRE_first_tail_x6_r0_body.s312.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs31 : PRE_first_tail_x6_r0_body.s313.jobs = PRE_first_tail_x6_r0_body.st31.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi31 : PRE_first_tail_x6_r0_body.s313.ffi = PRE_first_tail_x6_r0_body.st31.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace31 : PRE_first_tail_x6_r0_body.s313.trace = PRE_first_tail_x6_r0_body.st31.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores31 : PRE_first_tail_x6_r0_body.s313.stores = PRE_first_tail_x6_r0_body.st31.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD31
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 31 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived31 : PRE_first_tail_x6_r0_body.nr31.map (fun r => nth? PRE_first_tail_x6_r0_body.st31.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo31 : PRE_first_tail_x6_r0_body.nr31.all (Nat.ble 1406) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj31 : PRE_first_tail_x6_r0_body.cws31.all (fun c => !PRE_first_tail_x6_r0_body.ws31.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ31 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws31 PRE_first_tail_x6_r0_body.crs31 PRE_first_tail_x6_r0_body.ws31

end Host.Load.Run.Tpl
end

section -- st31/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st31`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st31.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st31.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st31.s2.heap PRE_first_tail_x6_r0_body.st31.wrR ++ freshOf PRE_first_tail_x6_r0_body.st31.s2.heap PRE_first_tail_x6_r0_body.st31.s0.next PRE_first_tail_x6_r0_body.st31.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st31.wr : List Nat := PRE_first_tail_x6_r0_body.st31.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st31.heapFoot : PRE_first_tail_x6_r0_body.st31.s2.heap = setAll PRE_first_tail_x6_r0_body.st31.s0.heap PRE_first_tail_x6_r0_body.st31.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st31.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st31.s0.next PRE_first_tail_x6_r0_body.st31.s2.next = true
theorem PRE_first_tail_x6_r0_body.st31.grows : PRE_first_tail_x6_r0_body.st31.s0.next ≤ PRE_first_tail_x6_r0_body.st31.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st31.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st31.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st31.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st31.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st31.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st31.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st31.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st31.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st31.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st31.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st31.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st31.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF31
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 31 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB31 : nodupT PRE_first_tail_x6_r0_body.st31.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup31 : PRE_first_tail_x6_r0_body.st31.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB31).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB31 : PRE_first_tail_x6_r0_body.st31.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound31 : ∀ b ∈ PRE_first_tail_x6_r0_body.st31.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB31 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr31 := PRE_first_tail_x6_r0_body.st31.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq31 : PRE_first_tail_x6_r0_body.st31.s2.trace = PRE_first_tail_x6_r0_body.trFr31 ++ PRE_first_tail_x6_r0_body.st31.s0.trace
theorem PRE_first_tail_x6_r0_body.trace31 : ∃ fr, PRE_first_tail_x6_r0_body.st31.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st31.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq31⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide31 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB31 : (PRE_first_tail_x6_r0_body.wide31.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st31.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix31 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide31, WFix Map.id (Present PRE_first_tail_x6_r0_body.st31.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB31 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL31
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 31 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s313`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO31 : PRE_first_tail_x6_r0_body.st31.S0.oracle = PRE_first_tail_x6_r0_body.st31.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B31 : PRE_first_tail_x6_r0_body.st31.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st31.s0.next || (PRE_first_tail_x6_r0_body.st31.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot31 : Conv.StageFoot PRE_first_tail_x6_r0_body.st31.wr PRE_first_tail_x6_r0_body.st31.s0 PRE_first_tail_x6_r0_body.st31.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st31.heapFoot PRE_first_tail_x6_r0_body.wrNodup31 PRE_first_tail_x6_r0_body.wrBound31 PRE_first_tail_x6_r0_body.wr0B31 PRE_first_tail_x6_r0_body.st31.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged31 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st31.F.S → PRE_first_tail_x6_r0_body.st31.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st31.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st31.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs31 PRE_first_tail_x6_r0_body.st31.wr PRE_first_tail_x6_r0_body.s312 PRE_first_tail_x6_r0_body.st31.s2 PRE_first_tail_x6_r0_body.st31.s0
      PRE_first_tail_x6_r0_body.st31.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st31.F FR W stk M ν K PRE_first_tail_x6_r0_body.s313 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso31 PRE_first_tail_x6_r0_body.stFoot31 PRE_first_tail_x6_r0_body.wrNodup31 PRE_first_tail_x6_r0_body.wrBound31 PRE_first_tail_x6_r0_body.trace31 PRE_first_tail_x6_r0_body.mheap31
    PRE_first_tail_x6_r0_body.mnext31 PRE_first_tail_x6_r0_body.mctl31 PRE_first_tail_x6_r0_body.mstack31 PRE_first_tail_x6_r0_body.mjobs31 PRE_first_tail_x6_r0_body.mffi31 PRE_first_tail_x6_r0_body.mtrace31 PRE_first_tail_x6_r0_body.mstores31 h

def PRE_first_tail_x6_r0_body.arrEl31_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE31_2665 : arrOf PRE_first_tail_x6_r0_body.s313 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl31_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA31_2665 : isArrB PRE_first_tail_x6_r0_body.s313 2665 = true
theorem PRE_first_tail_x6_r0_body.arr31_2665 : ∃ o, PRE_first_tail_x6_r0_body.s313.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl31_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE31_2665 PRE_first_tail_x6_r0_body.arrA31_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN31_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl31_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR31_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl31_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN31_2665

def PRE_first_tail_x6_r0_body.arrEl31_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE31_2673467 : arrOf PRE_first_tail_x6_r0_body.s313 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl31_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA31_2673467 : isArrB PRE_first_tail_x6_r0_body.s313 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr31_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s313.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl31_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE31_2673467 PRE_first_tail_x6_r0_body.arrA31_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN31_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl31_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR31_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl31_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN31_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k31 : isArrB PRE_first_tail_x6_r0_body.s313 4910 = false
theorem PRE_first_tail_x6_r0_body.keep31 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s313 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k31 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr31_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl31_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ31
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 31 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s312`, the merged
state `PRE_first_tail_x6_r0_body.s313`, the canonical state `PRE_first_tail_x6_r0_body.s314`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl31 : PRE_first_tail_x6_r0_body.pl31.all (Nat.ble PRE_first_tail_x6_r0_body.s312.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd31 : nodupT PRE_first_tail_x6_r0_body.pl31 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn131 : Nat.ble PRE_first_tail_x6_r0_body.s312.next 2699297 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst31 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s312.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn31 : PRE_first_tail_x6_r0_body.s314.next = PRE_first_tail_x6_r0_body.s312.next + PRE_first_tail_x6_r0_body.pl31.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn31 : PRE_first_tail_x6_r0_body.s313.next = 2699297
kernel_rfl PRE_first_tail_x6_r0_body.zgrow31 : Nat.ble PRE_first_tail_x6_r0_body.s314.next PRE_first_tail_x6_r0_body.s313.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh31 : PRE_first_tail_x6_r0_body.S312.tab.all (fun e => PRE_first_tail_x6_r0_body.cws31.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd31 : nodupT PRE_first_tail_x6_r0_body.cws31 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi31 : PRE_first_tail_x6_r0_body.nr31.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S313.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt31 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s312.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg31_2665 : PRE_first_tail_x6_r0_body.s314.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s314 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk31_2665 : (objOf PRE_first_tail_x6_r0_body.s314 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm31_2665 : PRE_first_tail_x6_r0_body.s313.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa31.obj (objOf PRE_first_tail_x6_r0_body.s314 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s313 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg31_2673467 : PRE_first_tail_x6_r0_body.s314.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s314 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk31_2673467 : (objOf PRE_first_tail_x6_r0_body.s314 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm31_2673467 : PRE_first_tail_x6_r0_body.s313.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa31.obj (objOf PRE_first_tail_x6_r0_body.s314 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s313 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw31_4910 : (PRE_first_tail_x6_r0_body.s314.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw31_2673472 : (PRE_first_tail_x6_r0_body.s314.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw31_2673473 : (PRE_first_tail_x6_r0_body.s314.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd31 : PRE_first_tail_x6_r0_body.cl31.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr31 : PRE_first_tail_x6_r0_body.st31.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s312.next || PRE_first_tail_x6_r0_body.cl31.contains b) = true
def PRE_first_tail_x6_r0_body.zl31 : List Nat := PRE_first_tail_x6_r0_body.cl31.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE31 : PRE_first_tail_x6_r0_body.zl31.map (fun a => PRE_first_tail_x6_r0_body.s313.heap.get (PRE_first_tail_x6_r0_body.kappa31.a a)) = PRE_first_tail_x6_r0_body.zl31.map (fun a => (PRE_first_tail_x6_r0_body.s314.heap.get a).map PRE_first_tail_x6_r0_body.kappa31.hobj)
theorem PRE_first_tail_x6_r0_body.zimg31 : HeapImg PRE_first_tail_x6_r0_body.kappa31 PRE_first_tail_x6_r0_body.s314 PRE_first_tail_x6_r0_body.s313 PRE_first_tail_x6_r0_body.zl31 := PRE_first_tail_x6_r0_body.zimgE31
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl31 : PRE_first_tail_x6_r0_body.s313.ctl = PRE_first_tail_x6_r0_body.kappa31.ctl PRE_first_tail_x6_r0_body.s314.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack31 : PRE_first_tail_x6_r0_body.s313.stack = PRE_first_tail_x6_r0_body.s314.stack.map PRE_first_tail_x6_r0_body.kappa31.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs31 : PRE_first_tail_x6_r0_body.s313.jobs = PRE_first_tail_x6_r0_body.s314.jobs.map PRE_first_tail_x6_r0_body.kappa31.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores31 : PRE_first_tail_x6_r0_body.s313.stores = PRE_first_tail_x6_r0_body.kappa31.stores PRE_first_tail_x6_r0_body.s314.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots31 : checkRootsSupp PRE_first_tail_x6_r0_body.s314 1406 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC31 : PRE_first_tail_x6_r0_body.S312.tab.length + PRE_first_tail_x6_r0_body.cws31.length = 1406
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap31 : PRE_first_tail_x6_r0_body.kappa31 = Conv.Map.compact PRE_first_tail_x6_r0_body.s312.next 2699297 PRE_first_tail_x6_r0_body.S312.tab.length PRE_first_tail_x6_r0_body.pl31 (PRE_first_tail_x6_r0_body.nr31.map NumV.ref) PRE_first_tail_x6_r0_body.kd31.big
  PRE_first_tail_x6_r0_body.kd31.region PRE_first_tail_x6_r0_body.kd31.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin31 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s314.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc31 : Conv.jcleanListB (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s314 PRE_first_tail_x6_r0_body.cl31 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB31 : noBigRootsP (fun i => !Conv.oldBigB (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s314.trace PRE_first_tail_x6_r0_body.s314 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm31 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15918 = true
theorem PRE_first_tail_x6_r0_body.cjcl31 (h : Conv.JClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s312) : Conv.JClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s314 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle31)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap31 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd31 a ha)) PRE_first_tail_x6_r0_body.zjc31

end Host.Load.Run.Tpl
end

section -- st31/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st31.bodyLast from PRE_first_tail_x6_r0_body.st31.s1 to PRE_first_tail_x6_r0_body.st31.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st31.F PRE_first_tail_x6_r0_body.st31.s1).run PRE_first_tail_x6_r0_body.st31.S1 = some (PRE_first_tail_x6_r0_body.st31.s2, PRE_first_tail_x6_r0_body.st31.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st31.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st31.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st31.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st31.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st31/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st31.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st31.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st31.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st31.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st31.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st31.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st31.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st31.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st31.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st31.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st31.s0 PRE_first_tail_x6_r0_body.st31.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st31.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st31.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st31.s1 PRE_first_tail_x6_r0_body.st31.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st31/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st31.bodyK0F from PRE_first_tail_x6_r0_body.st31.s0 to PRE_first_tail_x6_r0_body.st31.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st31.F (PRE_first_tail_x6_r0_body.st31.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st31.ks 0).getD 0) PRE_first_tail_x6_r0_body.st31.s0 PRE_first_tail_x6_r0_body.st31.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st31.s1, PRE_first_tail_x6_r0_body.st31.S1)
theorem PRE_first_tail_x6_r0_body.st31.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st31.F (PRE_first_tail_x6_r0_body.st31.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st31.ks 0).getD 0) PRE_first_tail_x6_r0_body.st31.s0 PRE_first_tail_x6_r0_body.st31.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st31.s1, PRE_first_tail_x6_r0_body.st31.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st31.bodyOkLN_ok PRE_first_tail_x6_r0_body.st31.bodyK0F
end Host.Load.Run.Tpl
end

section -- st31/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st31.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st31.F (PRE_first_tail_x6_r0_body.st31.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st31.s0 PRE_first_tail_x6_r0_body.st31.S0 = some (PRE_first_tail_x6_r0_body.st31.s1, PRE_first_tail_x6_r0_body.st31.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st31.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st31.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st31.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st31.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st31.F (PRE_first_tail_x6_r0_body.st31.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st31.s0
  S0 := PRE_first_tail_x6_r0_body.st31.S0
  s1 := PRE_first_tail_x6_r0_body.st31.s1
  S1 := PRE_first_tail_x6_r0_body.st31.S1
  s2 := PRE_first_tail_x6_r0_body.st31.s2
  S2 := PRE_first_tail_x6_r0_body.st31.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st31.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st31.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st31.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st31.bodyHalt
  last := PRE_first_tail_x6_r0_body.st31.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st31.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC32
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 32 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s318` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa32` into the merged state
`PRE_first_tail_x6_r0_body.s317`. -/

def PRE_first_tail_x6_r0_body.pl32 : List Nat := [2699593]
def PRE_first_tail_x6_r0_body.nr32 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd32 : RData :=
  ⟨2699584, 2699594, Stage.setAll PTrie.nil [(2699583, 2699593)], Stage.setAll PTrie.nil [],
   18825, 18825, 15922, 15922, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa32 : Map :=
  Conv.Map.compact 2699583 2699594 1423 PRE_first_tail_x6_r0_body.pl32 (PRE_first_tail_x6_r0_body.nr32.map NumV.ref) PRE_first_tail_x6_r0_body.kd32.big
    PRE_first_tail_x6_r0_body.kd32.region PRE_first_tail_x6_r0_body.kd32.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws32 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs32 : List SymE := PRE_first_tail_x6_r0_body.nr32.map fun r => (nth? PRE_first_tail_x6_r0_body.S317.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta32 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws32 PRE_first_tail_x6_r0_body.crs32
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB32 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab32 : PRE_first_tail_x6_r0_body.S318.tab = PRE_first_tail_x6_r0_body.S316.tab ++ PRE_first_tail_x6_r0_body.cws32.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace32 : PRE_first_tail_x6_r0_body.s318.trace = PRE_first_tail_x6_r0_body.s316.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext32 : PRE_first_tail_x6_r0_body.s318.next = 2699584
kernel_rfl PRE_first_tail_x6_r0_body.ccounters32 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx.nnext) = (18825, 15922)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue32 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s317.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa32.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp32 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx.tokens.all (bSN 1423) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean32 : Conv.cleanListB 18825 131072 (fun r => Nat.ble 75300 r) PRE_first_tail_x6_r0_body.s318
    (PRE_first_tail_x6_r0_body.wrB32 ++ (List.range 1).map (2699583 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs32 : bigsOutB 18825 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK32
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl32`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl32 : List Nat := [2665, 2673467, 2699583]
def PRE_first_tail_x6_r0_body.clo32 : List Nat := []
def PRE_first_tail_x6_r0_body.cln32 : List Nat := []
def PRE_first_tail_x6_r0_body.cli32 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap32 : PRE_first_tail_x6_r0_body.s318.heap = Stage.setAll PRE_first_tail_x6_r0_body.s316.heap (PRE_first_tail_x6_r0_body.cl32.filterMap fun a => (PRE_first_tail_x6_r0_body.s318.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe32 : Nat.ble PRE_first_tail_x6_r0_body.s316.next PRE_first_tail_x6_r0_body.s318.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP32 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s316 PRE_first_tail_x6_r0_body.s318 PRE_first_tail_x6_r0_body.cl32 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp32 : Conv.suppListB PRE_first_tail_x6_r0_body.s318 1423 PRE_first_tail_x6_r0_body.cl32 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound32 : Conv.boundListB PRE_first_tail_x6_r0_body.s318 PRE_first_tail_x6_r0_body.cl32 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK32 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln32.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK32 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo32.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK32 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli32.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst32 : Conv.sstListB 1423 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx PRE_first_tail_x6_r0_body.cln32 PRE_first_tail_x6_r0_body.clo32 PRE_first_tail_x6_r0_body.cli32 = true

end Host.Load.Run.Tpl
end

section -- SiteCl32
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA32 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo32.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd32 : (PRE_first_tail_x6_r0_body.clo32 ++ PRE_first_tail_x6_r0_body.cln32 ++ PRE_first_tail_x6_r0_body.cli32).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle32 : Conv.Cnt.leB (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) (⟨18825, 15922, 2699584, 1423⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck32 : Conv.ncleanListB (⟨18825, 15922, 2699584, 1423⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx PRE_first_tail_x6_r0_body.clo32 PRE_first_tail_x6_r0_body.cln32 PRE_first_tail_x6_r0_body.cli32 = true
theorem PRE_first_tail_x6_r0_body.cncl32 (h : Conv.NClean (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx) : Conv.NClean (⟨18825, 15922, 2699584, 1423⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle32 PRE_first_tail_x6_r0_body.ckA32 PRE_first_tail_x6_r0_body.cobjsK32 PRE_first_tail_x6_r0_body.cnodesK32 PRE_first_tail_x6_r0_body.citemsK32 PRE_first_tail_x6_r0_body.cbd32 PRE_first_tail_x6_r0_body.cck32

end Host.Load.Run.Tpl
end

section -- SiteS32
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 32 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc32 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P32 : LoadP := PRE_first_tail_x6_r0_body.Pc32.raise 15922
kernel_rfl PRE_first_tail_x6_r0_body.craise32 : Nat.ble PRE_first_tail_x6_r0_body.Pc32.N0 15922 = true
theorem PRE_first_tail_x6_r0_body.raised32 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc32 PRE_first_tail_x6_r0_body.P32 :=
  .inr ⟨15922, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise32, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_32 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_32 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s317.ffi)
def PRE_first_tail_x6_r0_body.khinv32 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv32 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS32 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS32 : List Nat := List.range' 15922 0
def PRE_first_tail_x6_r0_body.ciS32 : List Nat := [] ++ List.range' 15922 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh032 : PRE_first_tail_x6_r0_body.kd32.nh0 = PRE_first_tail_x6_r0_body.cx0_32.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh132 : PRE_first_tail_x6_r0_body.kd32.nh1 = PRE_first_tail_x6_r0_body.cx1_32.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn032 : PRE_first_tail_x6_r0_body.kd32.nn0 = PRE_first_tail_x6_r0_body.cx0_32.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn132 : PRE_first_tail_x6_r0_body.kd32.nn1 = PRE_first_tail_x6_r0_body.cx1_32.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo32 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P32.lo && Nat.ble PRE_first_tail_x6_r0_body.P32.lo PRE_first_tail_x6_r0_body.cx0_32.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P32.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P32.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt32 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_32.mlx.next PRE_first_tail_x6_r0_body.cx1_32.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_32.mlx.nnext PRE_first_tail_x6_r0_body.cx1_32.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband32 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P32.NL && Nat.ble PRE_first_tail_x6_r0_body.P32.NL PRE_first_tail_x6_r0_body.P32.N0 && Nat.ble PRE_first_tail_x6_r0_body.P32.N0 PRE_first_tail_x6_r0_body.cx0_32.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow32 : PRE_first_tail_x6_r0_body.kd32.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren32 : checkRenG PRE_first_tail_x6_r0_body.kd32.hnd PRE_first_tail_x6_r0_body.khinv32 (phB PRE_first_tail_x6_r0_body.cx0_32.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband32 : PRE_first_tail_x6_r0_body.kd32.checkBand PRE_first_tail_x6_r0_body.P32.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos32 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd32.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren32 : checkRenG PRE_first_tail_x6_r0_body.kd32.node PRE_first_tail_x6_r0_body.kninv32 (pnB PRE_first_tail_x6_r0_body.cx0_32.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow32 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd32.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P32.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd32.nodeF j) PRE_first_tail_x6_r0_body.cx1_32.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a32 : PRE_first_tail_x6_r0_body.cx0_32.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b32 : PRE_first_tail_x6_r0_body.cx0_32.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok132 : PRE_first_tail_x6_r0_body.cx1_32.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend32 : PRE_first_tail_x6_r0_body.cx1_32.mlx.pending = PRE_first_tail_x6_r0_body.cx0_32.mlx.pending.map PRE_first_tail_x6_r0_body.kappa32.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh32 : PRE_first_tail_x6_r0_body.cx1_32.mlx.errh = PRE_first_tail_x6_r0_body.cx0_32.mlx.errh.map PRE_first_tail_x6_r0_body.kappa32.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles32 : PRE_first_tail_x6_r0_body.cx1_32.mlx.files = PRE_first_tail_x6_r0_body.cx0_32.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch32 : PRE_first_tail_x6_r0_body.cx1_32.mlx.arch = PRE_first_tail_x6_r0_body.cx0_32.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes32 : PRE_first_tail_x6_r0_body.cx1_32.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_32.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired32 : PRE_first_tail_x6_r0_body.cx1_32.mlx.wired = PRE_first_tail_x6_r0_body.cx0_32.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost32 : PRE_first_tail_x6_r0_body.cx1_32.host = PRE_first_tail_x6_r0_body.cx0_32.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd32`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn032 : PRE_first_tail_x6_r0_body.kd32.n0 = 2699584
kernel_rfl PRE_first_tail_x6_r0_body.ckn132 : PRE_first_tail_x6_r0_body.kd32.n1 = 2699594
kernel_rfl PRE_first_tail_x6_r0_body.ckheap32 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd32.heap).all (fun x => Nat.ble 2699583 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl32 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd32.heap.get (2699583 + j) = nth? PRE_first_tail_x6_r0_body.pl32 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja32 : Nat.ble 2699583 2699583 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn32 : Nat.ble 1423 1423 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD32 : Nat.ble 2699583 PRE_first_tail_x6_r0_body.kd32.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn32 : Nat.ble 18825 PRE_first_tail_x6_r0_body.kd32.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn32 : Nat.ble 15922 PRE_first_tail_x6_r0_body.kd32.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb32 : Nat.ble 18825 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap32 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd32.heap).all (Nat.ble (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd32 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd32.hnd).all (Nat.ble (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode32 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd32.node).all (Nat.ble (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix32 : Conv.FixOld (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa32 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja32) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn32) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD32) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn32) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn32) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb32) PRE_first_tail_x6_r0_body.fheap32 PRE_first_tail_x6_r0_body.fhnd32 PRE_first_tail_x6_r0_body.fnode32
kernel_rfl PRE_first_tail_x6_r0_body.fcxn32 : (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn32 : (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle032 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_32.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_32.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk32 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd32.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A32 : PRE_first_tail_x6_r0_body.cx1_32.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS32.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_32.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O32 : PRE_first_tail_x6_r0_body.cx1_32.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS32.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_32.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N32 : PRE_first_tail_x6_r0_body.cx1_32.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS32.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_32.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I32 : PRE_first_tail_x6_r0_body.cx1_32.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS32.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_32.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd32 : (PRE_first_tail_x6_r0_body.clo32 ++ PRE_first_tail_x6_r0_body.cln32 ++ PRE_first_tail_x6_r0_body.cli32 ++ PRE_first_tail_x6_r0_body.cwS32 ++ PRE_first_tail_x6_r0_body.cnS32 ++ PRE_first_tail_x6_r0_body.ciS32).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW32 : PRE_first_tail_x6_r0_body.cwS32.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo32.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI32 : PRE_first_tail_x6_r0_body.ciS32.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli32.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN32 : PRE_first_tail_x6_r0_body.cnS32.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF32 : PRE_first_tail_x6_r0_body.cln32.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh32 : PRE_first_tail_x6_r0_body.clo32.all (handleOK PRE_first_tail_x6_r0_body.kappa32 PRE_first_tail_x6_r0_body.P32.lo PRE_first_tail_x6_r0_body.cx0_32.mlx PRE_first_tail_x6_r0_body.cx1_32.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo32 : PRE_first_tail_x6_r0_body.clo32.map (fun h => PRE_first_tail_x6_r0_body.cx1_32.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa32.handle h)) = PRE_first_tail_x6_r0_body.clo32.map (fun h => (PRE_first_tail_x6_r0_body.cx0_32.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa32.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok32 : PRE_first_tail_x6_r0_body.clo32.all (objOK PRE_first_tail_x6_r0_body.kappa32 PRE_first_tail_x6_r0_body.P32.NL PRE_first_tail_x6_r0_body.cx0_32.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd32 : PRE_first_tail_x6_r0_body.cln32.all (nodeOKF PRE_first_tail_x6_r0_body.kappa32 PRE_first_tail_x6_r0_body.P32 PRE_first_tail_x6_r0_body.cx0_32.mlx PRE_first_tail_x6_r0_body.cx1_32.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp32 : ((PRE_first_tail_x6_r0_body.cln32.filter (fullB PRE_first_tail_x6_r0_body.P32))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_32.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa32.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln32.filter (fullB PRE_first_tail_x6_r0_body.P32))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_32.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa32.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI32 : incrB PRE_first_tail_x6_r0_body.kd32.nodeF (List.range' 15922 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK32 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd32.node).all (fun k => Nat.ble 15922 k && Nat.blt k 15922) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL32 : (PRE_first_tail_x6_r0_body.cln32.filter (Nat.ble PRE_first_tail_x6_r0_body.P32.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd32.nodeF i) && (Nat.blt i 15922 || Nat.ble PRE_first_tail_x6_r0_body.kd32.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord32 : (PRE_first_tail_x6_r0_body.cln32.filter (Nat.ble PRE_first_tail_x6_r0_body.P32.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd32.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd32.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd32.nodeF j) (PRE_first_tail_x6_r0_body.kd32.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow32 PRE_first_tail_x6_r0_body.cnn132 PRE_first_tail_x6_r0_body.fnordI32 PRE_first_tail_x6_r0_body.fnordK32 PRE_first_tail_x6_r0_body.fnordL32
kernel_rfl PRE_first_tail_x6_r0_body.fi32 : PRE_first_tail_x6_r0_body.cli32.all (pnB PRE_first_tail_x6_r0_body.cx0_32.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii32 : PRE_first_tail_x6_r0_body.cli32.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_32.mlx.items.get (PRE_first_tail_x6_r0_body.kappa32.node k) = (PRE_first_tail_x6_r0_body.cx0_32.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa32.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot32 (clean : Conv.NClean (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P32.NL) (cl : SSt (· < 1423) PRE_first_tail_x6_r0_body.cx0_32.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P32 1423 PRE_first_tail_x6_r0_body.kappa32 PRE_first_tail_x6_r0_body.kd32 PRE_first_tail_x6_r0_body.khinv32 PRE_first_tail_x6_r0_body.kninv32 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx PRE_first_tail_x6_r0_body.cx0_32.mlx PRE_first_tail_x6_r0_body.cx1_32.mlx (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo32 PRE_first_tail_x6_r0_body.cln32 PRE_first_tail_x6_r0_body.cli32 PRE_first_tail_x6_r0_body.cwS32 PRE_first_tail_x6_r0_body.cnS32 PRE_first_tail_x6_r0_body.ciS32 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh032, PRE_first_tail_x6_r0_body.cnh132, PRE_first_tail_x6_r0_body.cnn032, PRE_first_tail_x6_r0_body.cnn132, PRE_first_tail_x6_r0_body.cplo32, PRE_first_tail_x6_r0_body.ccnt32, PRE_first_tail_x6_r0_body.cnband32, PRE_first_tail_x6_r0_body.chbelow32, PRE_first_tail_x6_r0_body.chren32, PRE_first_tail_x6_r0_body.cband32, PRE_first_tail_x6_r0_body.cnh1pos32, PRE_first_tail_x6_r0_body.cnren32, PRE_first_tail_x6_r0_body.cnlow32, PRE_first_tail_x6_r0_body.cabs0a32, PRE_first_tail_x6_r0_body.cabs0b32, PRE_first_tail_x6_r0_body.ctok132, PRE_first_tail_x6_r0_body.cpend32, PRE_first_tail_x6_r0_body.cerrh32, PRE_first_tail_x6_r0_body.cfiles32, PRE_first_tail_x6_r0_body.carch32, PRE_first_tail_x6_r0_body.csizes32, PRE_first_tail_x6_r0_body.cwired32, PRE_first_tail_x6_r0_body.cfix32, clean, PRE_first_tail_x6_r0_body.fcxn32, PRE_first_tail_x6_r0_body.fcnn32, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle032, PRE_first_tail_x6_r0_body.fnk32, PRE_first_tail_x6_r0_body.ckA32, PRE_first_tail_x6_r0_body.cobjsK32, PRE_first_tail_x6_r0_body.cnodesK32, PRE_first_tail_x6_r0_body.citemsK32, PRE_first_tail_x6_r0_body.f1A32, PRE_first_tail_x6_r0_body.f1O32, PRE_first_tail_x6_r0_body.f1N32, PRE_first_tail_x6_r0_body.f1I32, PRE_first_tail_x6_r0_body.fbd32, PRE_first_tail_x6_r0_body.fincW32, PRE_first_tail_x6_r0_body.fincI32, PRE_first_tail_x6_r0_body.fincN32, PRE_first_tail_x6_r0_body.flnF32, PRE_first_tail_x6_r0_body.fh32, PRE_first_tail_x6_r0_body.fo32, PRE_first_tail_x6_r0_body.fok32, PRE_first_tail_x6_r0_body.fnd32, PRE_first_tail_x6_r0_body.fp32, PRE_first_tail_x6_r0_body.fnord32, PRE_first_tail_x6_r0_body.fi32, PRE_first_tail_x6_r0_body.fii32⟩
theorem PRE_first_tail_x6_r0_body.cnshift32 (clean : Conv.NClean (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P32.NL) (cl : SSt (· < 1423) PRE_first_tail_x6_r0_body.cx0_32.mlx) : NShift PRE_first_tail_x6_r0_body.P32 1423 PRE_first_tail_x6_r0_body.kappa32 PRE_first_tail_x6_r0_body.cx0_32 PRE_first_tail_x6_r0_body.cx1_32 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot32 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost32 (compact_a_eq PRE_first_tail_x6_r0_body.ckn032 PRE_first_tail_x6_r0_body.ckn132 PRE_first_tail_x6_r0_body.ckheap32 PRE_first_tail_x6_r0_body.ckpl32)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_32 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s316.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_32 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s316.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_32 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s316.ffi) = some PRE_first_tail_x6_r0_body.fxC_32
kernel_rfl PRE_first_tail_x6_r0_body.okrC_32 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s316.ffi) = some PRE_first_tail_x6_r0_body.krC_32
noncomputable def PRE_first_tail_x6_r0_body.fx0_32 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s318.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_32 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s318.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_32 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s318.ffi) = some PRE_first_tail_x6_r0_body.fx0_32
kernel_rfl PRE_first_tail_x6_r0_body.okr0_32 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s318.ffi) = some PRE_first_tail_x6_r0_body.kr0_32
noncomputable def PRE_first_tail_x6_r0_body.fx1_32 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s317.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_32 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s317.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_32 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s317.ffi) = some PRE_first_tail_x6_r0_body.fx1_32
kernel_rfl PRE_first_tail_x6_r0_body.okr1_32 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s317.ffi) = some PRE_first_tail_x6_r0_body.kr1_32
kernel_rfl PRE_first_tail_x6_r0_body.ff032 : PRE_first_tail_x6_r0_body.fx0_32 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_32 (PRE_first_tail_x6_r0_body.clo32.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_32.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff132 : PRE_first_tail_x6_r0_body.fx1_32 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_32 (PRE_first_tail_x6_r0_body.cwS32.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_32.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck32 : freedLB PRE_first_tail_x6_r0_body.kappa32 PRE_first_tail_x6_r0_body.cx0_32.mlx PRE_first_tail_x6_r0_body.fx0_32 PRE_first_tail_x6_r0_body.fx1_32 PRE_first_tail_x6_r0_body.clo32 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf032 : PRE_first_tail_x6_r0_body.kr0_32.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_32.flags (PRE_first_tail_x6_r0_body.clo32.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_32.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt032 : PRE_first_tail_x6_r0_body.kr0_32.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_32.targs (PRE_first_tail_x6_r0_body.clo32.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_32.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf132 : PRE_first_tail_x6_r0_body.kr1_32.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_32.flags (PRE_first_tail_x6_r0_body.cwS32.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_32.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt132 : PRE_first_tail_x6_r0_body.kr1_32.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_32.targs (PRE_first_tail_x6_r0_body.cwS32.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_32.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck32 : krecLB PRE_first_tail_x6_r0_body.kappa32 1423 PRE_first_tail_x6_r0_body.cx0_32.mlx PRE_first_tail_x6_r0_body.kr0_32 PRE_first_tail_x6_r0_body.kr1_32 PRE_first_tail_x6_r0_body.clo32 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn32 : Nat.ble 1423 1423 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge32 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s317.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s318.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR32 : pendRegB PRE_first_tail_x6_r0_body.kappa32 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe32 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s318.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s317.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift32 (clean : Conv.NClean (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P32.NL) (cl : SSt (· < 1423) PRE_first_tail_x6_r0_body.cx0_32.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_32.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_32.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_32.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s316.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_32.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P32 1423 PRE_first_tail_x6_r0_body.kappa32 PRE_first_tail_x6_r0_body.s318.ffi PRE_first_tail_x6_r0_body.s317.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift32 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue32, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp32 t ht),
    PRE_first_tail_x6_r0_body.cbridge32,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s318.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s317.ffi) (PRE_first_tail_x6_r0_body.cfoot32 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_32 PRE_first_tail_x6_r0_body.ofx1_32 hobjC PRE_first_tail_x6_r0_body.ff032 PRE_first_tail_x6_r0_body.ff132 PRE_first_tail_x6_r0_body.ffck32,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s318.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s317.ffi) (PRE_first_tail_x6_r0_body.cfoot32 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_32 PRE_first_tail_x6_r0_body.okr1_32 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn32) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf032 PRE_first_tail_x6_r0_body.fkt032 PRE_first_tail_x6_r0_body.fkf132 PRE_first_tail_x6_r0_body.fkt132 PRE_first_tail_x6_r0_body.fkck32,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh032 PRE_first_tail_x6_r0_body.cnh132 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe32) PRE_first_tail_x6_r0_body.cpendR32⟩

end Host.Load.Run.Tpl
end

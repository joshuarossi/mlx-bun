import host.sim.template.a4pre_first_tail_x6_r0_body.States
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B00
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B18
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
import host.sim.conv.Compact
import host.sim.native.RebigR
import host.sim.template.Sigma
import host.sim.template.NShiftGen
import host.sim.conv.Closed
import host.sim.conv.NClean
import host.sim.conv.CompactFull
import host.sim.template.FootGen

section -- st32/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st32 0
host_stream_state PRE_first_tail_x6_r0_body.st32 1
host_stream_state PRE_first_tail_x6_r0_body.st32 2
end Host.Load.Run.Tpl
end

section -- Site32
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 32 of chain `PRE_first_tail_x6_r0_body`: `plan__g32__g33` (`plan`), the call state `PRE_first_tail_x6_r0_body.s316`, the merged state `PRE_first_tail_x6_r0_body.s317`,
the site template `PRE_first_tail_x6_r0_body.st32` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s318`: the merge.
The footprint's facts are in `SiteF32`, the compaction's in `SiteC32`, `SiteK32`, `SiteNa32`, `SiteNb32`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso32 : PRE_first_tail_x6_r0_body.st32.s0 = { PRE_first_tail_x6_r0_body.s316 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs32 : List Frame := PRE_first_tail_x6_r0_body.s316.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_32 : PRE_first_tail_x6_r0_body.S316.tab.length = 1423
kernel_rfl PRE_first_tail_x6_r0_body.tab0_32 : PRE_first_tail_x6_r0_body.st32.S0.tab = PRE_first_tail_x6_r0_body.S316.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws32 : List Nat := [1551, 1552, 1553]
kernel_rfl PRE_first_tail_x6_r0_body.fresh32 : (PRE_first_tail_x6_r0_body.S316.tab.all fun e => PRE_first_tail_x6_r0_body.ws32.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S316.oracle.all fun q => PRE_first_tail_x6_r0_body.ws32.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab32 : PRE_first_tail_x6_r0_body.S317.tab = PRE_first_tail_x6_r0_body.S316.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws32
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen32 : PRE_first_tail_x6_r0_body.st32.S2.tab.length - PRE_first_tail_x6_r0_body.st32.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged32`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap32 : PRE_first_tail_x6_r0_body.s317.heap = PRE_first_tail_x6_r0_body.st32.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext32 : PRE_first_tail_x6_r0_body.s317.next = PRE_first_tail_x6_r0_body.st32.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl32 : PRE_first_tail_x6_r0_body.s317.ctl = PRE_first_tail_x6_r0_body.st32.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack32 : PRE_first_tail_x6_r0_body.s317.stack = PRE_first_tail_x6_r0_body.st32.s2.stack ++ PRE_first_tail_x6_r0_body.s316.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs32 : PRE_first_tail_x6_r0_body.s317.jobs = PRE_first_tail_x6_r0_body.st32.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi32 : PRE_first_tail_x6_r0_body.s317.ffi = PRE_first_tail_x6_r0_body.st32.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace32 : PRE_first_tail_x6_r0_body.s317.trace = PRE_first_tail_x6_r0_body.st32.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores32 : PRE_first_tail_x6_r0_body.s317.stores = PRE_first_tail_x6_r0_body.st32.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD32
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 32 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived32 : PRE_first_tail_x6_r0_body.nr32.map (fun r => nth? PRE_first_tail_x6_r0_body.st32.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo32 : PRE_first_tail_x6_r0_body.nr32.all (Nat.ble 1423) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj32 : PRE_first_tail_x6_r0_body.cws32.all (fun c => !PRE_first_tail_x6_r0_body.ws32.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ32 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws32 PRE_first_tail_x6_r0_body.crs32 PRE_first_tail_x6_r0_body.ws32

end Host.Load.Run.Tpl
end

section -- st32/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st32`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st32.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st32.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st32.s2.heap PRE_first_tail_x6_r0_body.st32.wrR ++ freshOf PRE_first_tail_x6_r0_body.st32.s2.heap PRE_first_tail_x6_r0_body.st32.s0.next PRE_first_tail_x6_r0_body.st32.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st32.wr : List Nat := PRE_first_tail_x6_r0_body.st32.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st32.heapFoot : PRE_first_tail_x6_r0_body.st32.s2.heap = setAll PRE_first_tail_x6_r0_body.st32.s0.heap PRE_first_tail_x6_r0_body.st32.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st32.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st32.s0.next PRE_first_tail_x6_r0_body.st32.s2.next = true
theorem PRE_first_tail_x6_r0_body.st32.grows : PRE_first_tail_x6_r0_body.st32.s0.next ≤ PRE_first_tail_x6_r0_body.st32.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st32.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st32.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st32.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st32.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st32.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st32.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st32.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st32.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st32.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st32.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st32.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st32.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF32
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 32 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB32 : nodupT PRE_first_tail_x6_r0_body.st32.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup32 : PRE_first_tail_x6_r0_body.st32.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB32).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB32 : PRE_first_tail_x6_r0_body.st32.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound32 : ∀ b ∈ PRE_first_tail_x6_r0_body.st32.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB32 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr32 := PRE_first_tail_x6_r0_body.st32.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq32 : PRE_first_tail_x6_r0_body.st32.s2.trace = PRE_first_tail_x6_r0_body.trFr32 ++ PRE_first_tail_x6_r0_body.st32.s0.trace
theorem PRE_first_tail_x6_r0_body.trace32 : ∃ fr, PRE_first_tail_x6_r0_body.st32.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st32.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq32⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide32 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB32 : (PRE_first_tail_x6_r0_body.wide32.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st32.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix32 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide32, WFix Map.id (Present PRE_first_tail_x6_r0_body.st32.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB32 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL32
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 32 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s317`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO32 : PRE_first_tail_x6_r0_body.st32.S0.oracle = PRE_first_tail_x6_r0_body.st32.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B32 : PRE_first_tail_x6_r0_body.st32.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st32.s0.next || (PRE_first_tail_x6_r0_body.st32.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot32 : Conv.StageFoot PRE_first_tail_x6_r0_body.st32.wr PRE_first_tail_x6_r0_body.st32.s0 PRE_first_tail_x6_r0_body.st32.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st32.heapFoot PRE_first_tail_x6_r0_body.wrNodup32 PRE_first_tail_x6_r0_body.wrBound32 PRE_first_tail_x6_r0_body.wr0B32 PRE_first_tail_x6_r0_body.st32.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged32 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st32.F.S → PRE_first_tail_x6_r0_body.st32.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st32.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st32.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs32 PRE_first_tail_x6_r0_body.st32.wr PRE_first_tail_x6_r0_body.s316 PRE_first_tail_x6_r0_body.st32.s2 PRE_first_tail_x6_r0_body.st32.s0
      PRE_first_tail_x6_r0_body.st32.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st32.F FR W stk M ν K PRE_first_tail_x6_r0_body.s317 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso32 PRE_first_tail_x6_r0_body.stFoot32 PRE_first_tail_x6_r0_body.wrNodup32 PRE_first_tail_x6_r0_body.wrBound32 PRE_first_tail_x6_r0_body.trace32 PRE_first_tail_x6_r0_body.mheap32
    PRE_first_tail_x6_r0_body.mnext32 PRE_first_tail_x6_r0_body.mctl32 PRE_first_tail_x6_r0_body.mstack32 PRE_first_tail_x6_r0_body.mjobs32 PRE_first_tail_x6_r0_body.mffi32 PRE_first_tail_x6_r0_body.mtrace32 PRE_first_tail_x6_r0_body.mstores32 h

def PRE_first_tail_x6_r0_body.arrEl32_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE32_2665 : arrOf PRE_first_tail_x6_r0_body.s317 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl32_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA32_2665 : isArrB PRE_first_tail_x6_r0_body.s317 2665 = true
theorem PRE_first_tail_x6_r0_body.arr32_2665 : ∃ o, PRE_first_tail_x6_r0_body.s317.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl32_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE32_2665 PRE_first_tail_x6_r0_body.arrA32_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN32_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl32_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR32_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl32_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN32_2665

def PRE_first_tail_x6_r0_body.arrEl32_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE32_2673467 : arrOf PRE_first_tail_x6_r0_body.s317 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl32_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA32_2673467 : isArrB PRE_first_tail_x6_r0_body.s317 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr32_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s317.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl32_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE32_2673467 PRE_first_tail_x6_r0_body.arrA32_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN32_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl32_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR32_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl32_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN32_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k32 : isArrB PRE_first_tail_x6_r0_body.s317 4910 = false
theorem PRE_first_tail_x6_r0_body.keep32 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s317 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k32 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr32_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl32_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ32
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 32 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s316`, the merged
state `PRE_first_tail_x6_r0_body.s317`, the canonical state `PRE_first_tail_x6_r0_body.s318`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl32 : PRE_first_tail_x6_r0_body.pl32.all (Nat.ble PRE_first_tail_x6_r0_body.s316.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd32 : nodupT PRE_first_tail_x6_r0_body.pl32 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn132 : Nat.ble PRE_first_tail_x6_r0_body.s316.next 2699594 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst32 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s316.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn32 : PRE_first_tail_x6_r0_body.s318.next = PRE_first_tail_x6_r0_body.s316.next + PRE_first_tail_x6_r0_body.pl32.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn32 : PRE_first_tail_x6_r0_body.s317.next = 2699594
kernel_rfl PRE_first_tail_x6_r0_body.zgrow32 : Nat.ble PRE_first_tail_x6_r0_body.s318.next PRE_first_tail_x6_r0_body.s317.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh32 : PRE_first_tail_x6_r0_body.S316.tab.all (fun e => PRE_first_tail_x6_r0_body.cws32.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd32 : nodupT PRE_first_tail_x6_r0_body.cws32 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi32 : PRE_first_tail_x6_r0_body.nr32.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S317.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt32 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s316.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg32_2665 : PRE_first_tail_x6_r0_body.s318.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s318 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk32_2665 : (objOf PRE_first_tail_x6_r0_body.s318 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm32_2665 : PRE_first_tail_x6_r0_body.s317.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa32.obj (objOf PRE_first_tail_x6_r0_body.s318 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s317 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg32_2673467 : PRE_first_tail_x6_r0_body.s318.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s318 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk32_2673467 : (objOf PRE_first_tail_x6_r0_body.s318 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm32_2673467 : PRE_first_tail_x6_r0_body.s317.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa32.obj (objOf PRE_first_tail_x6_r0_body.s318 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s317 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw32_4910 : (PRE_first_tail_x6_r0_body.s318.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw32_2673472 : (PRE_first_tail_x6_r0_body.s318.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw32_2673473 : (PRE_first_tail_x6_r0_body.s318.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd32 : PRE_first_tail_x6_r0_body.cl32.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr32 : PRE_first_tail_x6_r0_body.st32.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s316.next || PRE_first_tail_x6_r0_body.cl32.contains b) = true
def PRE_first_tail_x6_r0_body.zl32 : List Nat := PRE_first_tail_x6_r0_body.cl32.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE32 : PRE_first_tail_x6_r0_body.zl32.map (fun a => PRE_first_tail_x6_r0_body.s317.heap.get (PRE_first_tail_x6_r0_body.kappa32.a a)) = PRE_first_tail_x6_r0_body.zl32.map (fun a => (PRE_first_tail_x6_r0_body.s318.heap.get a).map PRE_first_tail_x6_r0_body.kappa32.hobj)
theorem PRE_first_tail_x6_r0_body.zimg32 : HeapImg PRE_first_tail_x6_r0_body.kappa32 PRE_first_tail_x6_r0_body.s318 PRE_first_tail_x6_r0_body.s317 PRE_first_tail_x6_r0_body.zl32 := PRE_first_tail_x6_r0_body.zimgE32
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl32 : PRE_first_tail_x6_r0_body.s317.ctl = PRE_first_tail_x6_r0_body.kappa32.ctl PRE_first_tail_x6_r0_body.s318.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack32 : PRE_first_tail_x6_r0_body.s317.stack = PRE_first_tail_x6_r0_body.s318.stack.map PRE_first_tail_x6_r0_body.kappa32.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs32 : PRE_first_tail_x6_r0_body.s317.jobs = PRE_first_tail_x6_r0_body.s318.jobs.map PRE_first_tail_x6_r0_body.kappa32.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores32 : PRE_first_tail_x6_r0_body.s317.stores = PRE_first_tail_x6_r0_body.kappa32.stores PRE_first_tail_x6_r0_body.s318.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots32 : checkRootsSupp PRE_first_tail_x6_r0_body.s318 1423 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC32 : PRE_first_tail_x6_r0_body.S316.tab.length + PRE_first_tail_x6_r0_body.cws32.length = 1423
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap32 : PRE_first_tail_x6_r0_body.kappa32 = Conv.Map.compact PRE_first_tail_x6_r0_body.s316.next 2699594 PRE_first_tail_x6_r0_body.S316.tab.length PRE_first_tail_x6_r0_body.pl32 (PRE_first_tail_x6_r0_body.nr32.map NumV.ref) PRE_first_tail_x6_r0_body.kd32.big
  PRE_first_tail_x6_r0_body.kd32.region PRE_first_tail_x6_r0_body.kd32.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin32 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s318.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc32 : Conv.jcleanListB (⟨18825, 15922, 2699584, 1423⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s318 PRE_first_tail_x6_r0_body.cl32 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB32 : noBigRootsP (fun i => !Conv.oldBigB (⟨18825, 15922, 2699584, 1423⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s318.trace PRE_first_tail_x6_r0_body.s318 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm32 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15922 = true
theorem PRE_first_tail_x6_r0_body.cjcl32 (h : Conv.JClean (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s316) : Conv.JClean (⟨18825, 15922, 2699584, 1423⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s318 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle32)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap32 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd32 a ha)) PRE_first_tail_x6_r0_body.zjc32

end Host.Load.Run.Tpl
end

section -- st32/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st32.bodyLast from PRE_first_tail_x6_r0_body.st32.s1 to PRE_first_tail_x6_r0_body.st32.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st32.F PRE_first_tail_x6_r0_body.st32.s1).run PRE_first_tail_x6_r0_body.st32.S1 = some (PRE_first_tail_x6_r0_body.st32.s2, PRE_first_tail_x6_r0_body.st32.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st32.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st32.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st32.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st32.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st32/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st32.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st32.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st32.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st32.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st32.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st32.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st32.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st32.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st32.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st32.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st32.s0 PRE_first_tail_x6_r0_body.st32.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st32.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st32.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st32.s1 PRE_first_tail_x6_r0_body.st32.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st32/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st32.bodyK0F from PRE_first_tail_x6_r0_body.st32.s0 to PRE_first_tail_x6_r0_body.st32.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st32.F (PRE_first_tail_x6_r0_body.st32.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st32.ks 0).getD 0) PRE_first_tail_x6_r0_body.st32.s0 PRE_first_tail_x6_r0_body.st32.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st32.s1, PRE_first_tail_x6_r0_body.st32.S1)
theorem PRE_first_tail_x6_r0_body.st32.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st32.F (PRE_first_tail_x6_r0_body.st32.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st32.ks 0).getD 0) PRE_first_tail_x6_r0_body.st32.s0 PRE_first_tail_x6_r0_body.st32.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st32.s1, PRE_first_tail_x6_r0_body.st32.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st32.bodyOkLN_ok PRE_first_tail_x6_r0_body.st32.bodyK0F
end Host.Load.Run.Tpl
end

section -- st32/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st32.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st32.F (PRE_first_tail_x6_r0_body.st32.bodyOkL bytes rows) 98 PRE_first_tail_x6_r0_body.st32.s0 PRE_first_tail_x6_r0_body.st32.S0 = some (PRE_first_tail_x6_r0_body.st32.s1, PRE_first_tail_x6_r0_body.st32.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st32.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st32.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st32.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st32.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st32.F (PRE_first_tail_x6_r0_body.st32.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st32.s0
  S0 := PRE_first_tail_x6_r0_body.st32.S0
  s1 := PRE_first_tail_x6_r0_body.st32.s1
  S1 := PRE_first_tail_x6_r0_body.st32.S1
  s2 := PRE_first_tail_x6_r0_body.st32.s2
  S2 := PRE_first_tail_x6_r0_body.st32.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st32.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st32.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st32.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st32.bodyHalt
  last := PRE_first_tail_x6_r0_body.st32.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st32.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC33
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 33 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s334` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa33` into the merged state
`PRE_first_tail_x6_r0_body.s333`. -/

def PRE_first_tail_x6_r0_body.pl33 : List Nat := [2701682, 2701518, 2701570, 2701683, 2701684, 2701520, 2701572, 2701681, 2701680, 2701679, 2701678, 2701672, 2701623, 2701674, 2701625]
def PRE_first_tail_x6_r0_body.nr33 : List Nat := [1508, 1509, 1505, 1511, 1507, 1515, 1516, 1513, 1514]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd33 : RData :=
  ⟨2701335, 2701685, Stage.setAll PTrie.nil [(2701320, 2701682), (2701321, 2701518), (2701322, 2701570), (2701323, 2701683), (2701324, 2701684), (2701325, 2701520), (2701326, 2701572), (2701327, 2701681), (2701328, 2701680), (2701329, 2701679), (2701330, 2701678), (2701331, 2701672), (2701332, 2701623), (2701333, 2701674), (2701334, 2701625)], Stage.setAll PTrie.nil [(18865, 18867), (18866, 18868), (18867, 18870), (18868, 18869)],
   18869, 18871, 15956, 15956, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(1500, .ref 1508), (1501, .ref 1509), (1502, .ref 1505), (1503, .ref 1511), (1504, .ref 1507), (1505, .ref 1515), (1506, .ref 1516), (1507, .ref 1513), (1508, .ref 1514)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa33 : Map :=
  Conv.Map.compact 2701320 2701685 1500 PRE_first_tail_x6_r0_body.pl33 (PRE_first_tail_x6_r0_body.nr33.map NumV.ref) PRE_first_tail_x6_r0_body.kd33.big
    PRE_first_tail_x6_r0_body.kd33.region PRE_first_tail_x6_r0_body.kd33.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws33 : List Nat := [1571, 1572, 1573, 1574, 1575, 1576, 1577, 1578, 1579]
noncomputable def PRE_first_tail_x6_r0_body.crs33 : List SymE := PRE_first_tail_x6_r0_body.nr33.map fun r => (nth? PRE_first_tail_x6_r0_body.S333.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta33 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws33 PRE_first_tail_x6_r0_body.crs33
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB33 : List Nat := [2665, 2672384, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab33 : PRE_first_tail_x6_r0_body.S334.tab = PRE_first_tail_x6_r0_body.S332.tab ++ PRE_first_tail_x6_r0_body.cws33.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace33 : PRE_first_tail_x6_r0_body.s334.trace = PRE_first_tail_x6_r0_body.s332.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext33 : PRE_first_tail_x6_r0_body.s334.next = 2701335
kernel_rfl PRE_first_tail_x6_r0_body.ccounters33 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx.nnext) = (18869, 15956)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue33 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s333.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa33.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp33 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx.tokens.all (bSN 1509) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean33 : Conv.cleanListB 18869 131072 (fun r => Nat.ble 75476 r) PRE_first_tail_x6_r0_body.s334
    (PRE_first_tail_x6_r0_body.wrB33 ++ (List.range 15).map (2701320 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs33 : bigsOutB 18869 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK33
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl33`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl33 : List Nat := [2665, 2672384, 2673467, 2701320, 2701321, 2701322, 2701323, 2701324, 2701325, 2701326, 2701327, 2701328, 2701329, 2701330, 2701331, 2701332, 2701333, 2701334]
def PRE_first_tail_x6_r0_body.clo33 : List Nat := [18865, 18866, 18867, 18868]
def PRE_first_tail_x6_r0_body.cln33 : List Nat := [15950, 15951, 15952, 15953, 15954, 15955]
def PRE_first_tail_x6_r0_body.cli33 : List Nat := [15950, 15951, 15952, 15953, 15954, 15955]
kernel_rfl PRE_first_tail_x6_r0_body.cheap33 : PRE_first_tail_x6_r0_body.s334.heap = Stage.setAll PRE_first_tail_x6_r0_body.s332.heap (PRE_first_tail_x6_r0_body.cl33.filterMap fun a => (PRE_first_tail_x6_r0_body.s334.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe33 : Nat.ble PRE_first_tail_x6_r0_body.s332.next PRE_first_tail_x6_r0_body.s334.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP33 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s332 PRE_first_tail_x6_r0_body.s334 PRE_first_tail_x6_r0_body.cl33 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp33 : Conv.suppListB PRE_first_tail_x6_r0_body.s334 1509 PRE_first_tail_x6_r0_body.cl33 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound33 : Conv.boundListB PRE_first_tail_x6_r0_body.s334 PRE_first_tail_x6_r0_body.cl33 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK33 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln33.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK33 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo33.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK33 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli33.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst33 : Conv.sstListB 1509 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx PRE_first_tail_x6_r0_body.cln33 PRE_first_tail_x6_r0_body.clo33 PRE_first_tail_x6_r0_body.cli33 = true

end Host.Load.Run.Tpl
end

section -- SiteCl33
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA33 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo33.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd33 : (PRE_first_tail_x6_r0_body.clo33 ++ PRE_first_tail_x6_r0_body.cln33 ++ PRE_first_tail_x6_r0_body.cli33).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle33 : Conv.Cnt.leB (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) (⟨18869, 15956, 2701335, 1509⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck33 : Conv.ncleanListB (⟨18869, 15956, 2701335, 1509⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx PRE_first_tail_x6_r0_body.clo33 PRE_first_tail_x6_r0_body.cln33 PRE_first_tail_x6_r0_body.cli33 = true
theorem PRE_first_tail_x6_r0_body.cncl33 (h : Conv.NClean (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx) : Conv.NClean (⟨18869, 15956, 2701335, 1509⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle33 PRE_first_tail_x6_r0_body.ckA33 PRE_first_tail_x6_r0_body.cobjsK33 PRE_first_tail_x6_r0_body.cnodesK33 PRE_first_tail_x6_r0_body.citemsK33 PRE_first_tail_x6_r0_body.cbd33 PRE_first_tail_x6_r0_body.cck33

end Host.Load.Run.Tpl
end

section -- SiteS33
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 33 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc33 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P33 : LoadP := PRE_first_tail_x6_r0_body.Pc33.raise 15956
kernel_rfl PRE_first_tail_x6_r0_body.craise33 : Nat.ble PRE_first_tail_x6_r0_body.Pc33.N0 15956 = true
theorem PRE_first_tail_x6_r0_body.raised33 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc33 PRE_first_tail_x6_r0_body.P33 :=
  .inr ⟨15956, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise33, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_33 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_33 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s333.ffi)
def PRE_first_tail_x6_r0_body.khinv33 : PTrie Nat := Stage.setAll PTrie.nil [(18867, 18865), (18868, 18866), (18870, 18867), (18869, 18868)]
def PRE_first_tail_x6_r0_body.kninv33 : PTrie Nat := Stage.setAll PTrie.nil [(15950, 15950), (15951, 15951), (15952, 15952), (15953, 15953), (15954, 15954), (15955, 15955)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS33 : List Nat := [18865, 18866, 18867, 18868, 18869, 18870]
def PRE_first_tail_x6_r0_body.cnS33 : List Nat := List.range' 15950 6
def PRE_first_tail_x6_r0_body.ciS33 : List Nat := [] ++ List.range' 15950 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh033 : PRE_first_tail_x6_r0_body.kd33.nh0 = PRE_first_tail_x6_r0_body.cx0_33.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh133 : PRE_first_tail_x6_r0_body.kd33.nh1 = PRE_first_tail_x6_r0_body.cx1_33.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn033 : PRE_first_tail_x6_r0_body.kd33.nn0 = PRE_first_tail_x6_r0_body.cx0_33.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn133 : PRE_first_tail_x6_r0_body.kd33.nn1 = PRE_first_tail_x6_r0_body.cx1_33.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo33 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P33.lo && Nat.ble PRE_first_tail_x6_r0_body.P33.lo PRE_first_tail_x6_r0_body.cx0_33.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P33.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P33.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt33 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_33.mlx.next PRE_first_tail_x6_r0_body.cx1_33.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_33.mlx.nnext PRE_first_tail_x6_r0_body.cx1_33.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband33 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P33.NL && Nat.ble PRE_first_tail_x6_r0_body.P33.NL PRE_first_tail_x6_r0_body.P33.N0 && Nat.ble PRE_first_tail_x6_r0_body.P33.N0 PRE_first_tail_x6_r0_body.cx0_33.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow33 : PRE_first_tail_x6_r0_body.kd33.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren33 : checkRenG PRE_first_tail_x6_r0_body.kd33.hnd PRE_first_tail_x6_r0_body.khinv33 (phB PRE_first_tail_x6_r0_body.cx0_33.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband33 : PRE_first_tail_x6_r0_body.kd33.checkBand PRE_first_tail_x6_r0_body.P33.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos33 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd33.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren33 : checkRenG PRE_first_tail_x6_r0_body.kd33.node PRE_first_tail_x6_r0_body.kninv33 (pnB PRE_first_tail_x6_r0_body.cx0_33.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow33 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd33.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P33.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd33.nodeF j) PRE_first_tail_x6_r0_body.cx1_33.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a33 : PRE_first_tail_x6_r0_body.cx0_33.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b33 : PRE_first_tail_x6_r0_body.cx0_33.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok133 : PRE_first_tail_x6_r0_body.cx1_33.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend33 : PRE_first_tail_x6_r0_body.cx1_33.mlx.pending = PRE_first_tail_x6_r0_body.cx0_33.mlx.pending.map PRE_first_tail_x6_r0_body.kappa33.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh33 : PRE_first_tail_x6_r0_body.cx1_33.mlx.errh = PRE_first_tail_x6_r0_body.cx0_33.mlx.errh.map PRE_first_tail_x6_r0_body.kappa33.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles33 : PRE_first_tail_x6_r0_body.cx1_33.mlx.files = PRE_first_tail_x6_r0_body.cx0_33.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch33 : PRE_first_tail_x6_r0_body.cx1_33.mlx.arch = PRE_first_tail_x6_r0_body.cx0_33.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes33 : PRE_first_tail_x6_r0_body.cx1_33.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_33.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired33 : PRE_first_tail_x6_r0_body.cx1_33.mlx.wired = PRE_first_tail_x6_r0_body.cx0_33.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost33 : PRE_first_tail_x6_r0_body.cx1_33.host = PRE_first_tail_x6_r0_body.cx0_33.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd33`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn033 : PRE_first_tail_x6_r0_body.kd33.n0 = 2701335
kernel_rfl PRE_first_tail_x6_r0_body.ckn133 : PRE_first_tail_x6_r0_body.kd33.n1 = 2701685
kernel_rfl PRE_first_tail_x6_r0_body.ckheap33 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd33.heap).all (fun x => Nat.ble 2701320 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl33 : (List.range 15).all (fun j => decide (PRE_first_tail_x6_r0_body.kd33.heap.get (2701320 + j) = nth? PRE_first_tail_x6_r0_body.pl33 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja33 : Nat.ble 2701320 2701320 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn33 : Nat.ble 1500 1500 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD33 : Nat.ble 2701320 PRE_first_tail_x6_r0_body.kd33.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn33 : Nat.ble 18865 PRE_first_tail_x6_r0_body.kd33.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn33 : Nat.ble 15950 PRE_first_tail_x6_r0_body.kd33.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb33 : Nat.ble 18865 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap33 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd33.heap).all (Nat.ble (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd33 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd33.hnd).all (Nat.ble (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode33 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd33.node).all (Nat.ble (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix33 : Conv.FixOld (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa33 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja33) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn33) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD33) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn33) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn33) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb33) PRE_first_tail_x6_r0_body.fheap33 PRE_first_tail_x6_r0_body.fhnd33 PRE_first_tail_x6_r0_body.fnode33
kernel_rfl PRE_first_tail_x6_r0_body.fcxn33 : (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn33 : (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle033 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_33.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_33.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk33 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd33.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A33 : PRE_first_tail_x6_r0_body.cx1_33.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS33.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_33.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O33 : PRE_first_tail_x6_r0_body.cx1_33.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS33.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_33.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N33 : PRE_first_tail_x6_r0_body.cx1_33.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS33.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_33.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I33 : PRE_first_tail_x6_r0_body.cx1_33.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS33.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_33.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd33 : (PRE_first_tail_x6_r0_body.clo33 ++ PRE_first_tail_x6_r0_body.cln33 ++ PRE_first_tail_x6_r0_body.cli33 ++ PRE_first_tail_x6_r0_body.cwS33 ++ PRE_first_tail_x6_r0_body.cnS33 ++ PRE_first_tail_x6_r0_body.ciS33).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW33 : PRE_first_tail_x6_r0_body.cwS33.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo33.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI33 : PRE_first_tail_x6_r0_body.ciS33.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli33.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN33 : PRE_first_tail_x6_r0_body.cnS33.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF33 : PRE_first_tail_x6_r0_body.cln33.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh33 : PRE_first_tail_x6_r0_body.clo33.all (handleOK PRE_first_tail_x6_r0_body.kappa33 PRE_first_tail_x6_r0_body.P33.lo PRE_first_tail_x6_r0_body.cx0_33.mlx PRE_first_tail_x6_r0_body.cx1_33.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo33 : PRE_first_tail_x6_r0_body.clo33.map (fun h => PRE_first_tail_x6_r0_body.cx1_33.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa33.handle h)) = PRE_first_tail_x6_r0_body.clo33.map (fun h => (PRE_first_tail_x6_r0_body.cx0_33.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa33.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok33 : PRE_first_tail_x6_r0_body.clo33.all (objOK PRE_first_tail_x6_r0_body.kappa33 PRE_first_tail_x6_r0_body.P33.NL PRE_first_tail_x6_r0_body.cx0_33.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd33 : PRE_first_tail_x6_r0_body.cln33.all (nodeOKF PRE_first_tail_x6_r0_body.kappa33 PRE_first_tail_x6_r0_body.P33 PRE_first_tail_x6_r0_body.cx0_33.mlx PRE_first_tail_x6_r0_body.cx1_33.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp33 : ((PRE_first_tail_x6_r0_body.cln33.filter (fullB PRE_first_tail_x6_r0_body.P33))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_33.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa33.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln33.filter (fullB PRE_first_tail_x6_r0_body.P33))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_33.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa33.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI33 : incrB PRE_first_tail_x6_r0_body.kd33.nodeF (List.range' 15950 6) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK33 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd33.node).all (fun k => Nat.ble 15950 k && Nat.blt k 15956) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL33 : (PRE_first_tail_x6_r0_body.cln33.filter (Nat.ble PRE_first_tail_x6_r0_body.P33.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd33.nodeF i) && (Nat.blt i 15956 || Nat.ble PRE_first_tail_x6_r0_body.kd33.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord33 : (PRE_first_tail_x6_r0_body.cln33.filter (Nat.ble PRE_first_tail_x6_r0_body.P33.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd33.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd33.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd33.nodeF j) (PRE_first_tail_x6_r0_body.kd33.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow33 PRE_first_tail_x6_r0_body.cnn133 PRE_first_tail_x6_r0_body.fnordI33 PRE_first_tail_x6_r0_body.fnordK33 PRE_first_tail_x6_r0_body.fnordL33
kernel_rfl PRE_first_tail_x6_r0_body.fi33 : PRE_first_tail_x6_r0_body.cli33.all (pnB PRE_first_tail_x6_r0_body.cx0_33.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii33 : PRE_first_tail_x6_r0_body.cli33.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_33.mlx.items.get (PRE_first_tail_x6_r0_body.kappa33.node k) = (PRE_first_tail_x6_r0_body.cx0_33.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa33.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot33 (clean : Conv.NClean (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P33.NL) (cl : SSt (· < 1509) PRE_first_tail_x6_r0_body.cx0_33.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P33 1509 PRE_first_tail_x6_r0_body.kappa33 PRE_first_tail_x6_r0_body.kd33 PRE_first_tail_x6_r0_body.khinv33 PRE_first_tail_x6_r0_body.kninv33 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx PRE_first_tail_x6_r0_body.cx0_33.mlx PRE_first_tail_x6_r0_body.cx1_33.mlx (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo33 PRE_first_tail_x6_r0_body.cln33 PRE_first_tail_x6_r0_body.cli33 PRE_first_tail_x6_r0_body.cwS33 PRE_first_tail_x6_r0_body.cnS33 PRE_first_tail_x6_r0_body.ciS33 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh033, PRE_first_tail_x6_r0_body.cnh133, PRE_first_tail_x6_r0_body.cnn033, PRE_first_tail_x6_r0_body.cnn133, PRE_first_tail_x6_r0_body.cplo33, PRE_first_tail_x6_r0_body.ccnt33, PRE_first_tail_x6_r0_body.cnband33, PRE_first_tail_x6_r0_body.chbelow33, PRE_first_tail_x6_r0_body.chren33, PRE_first_tail_x6_r0_body.cband33, PRE_first_tail_x6_r0_body.cnh1pos33, PRE_first_tail_x6_r0_body.cnren33, PRE_first_tail_x6_r0_body.cnlow33, PRE_first_tail_x6_r0_body.cabs0a33, PRE_first_tail_x6_r0_body.cabs0b33, PRE_first_tail_x6_r0_body.ctok133, PRE_first_tail_x6_r0_body.cpend33, PRE_first_tail_x6_r0_body.cerrh33, PRE_first_tail_x6_r0_body.cfiles33, PRE_first_tail_x6_r0_body.carch33, PRE_first_tail_x6_r0_body.csizes33, PRE_first_tail_x6_r0_body.cwired33, PRE_first_tail_x6_r0_body.cfix33, clean, PRE_first_tail_x6_r0_body.fcxn33, PRE_first_tail_x6_r0_body.fcnn33, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle033, PRE_first_tail_x6_r0_body.fnk33, PRE_first_tail_x6_r0_body.ckA33, PRE_first_tail_x6_r0_body.cobjsK33, PRE_first_tail_x6_r0_body.cnodesK33, PRE_first_tail_x6_r0_body.citemsK33, PRE_first_tail_x6_r0_body.f1A33, PRE_first_tail_x6_r0_body.f1O33, PRE_first_tail_x6_r0_body.f1N33, PRE_first_tail_x6_r0_body.f1I33, PRE_first_tail_x6_r0_body.fbd33, PRE_first_tail_x6_r0_body.fincW33, PRE_first_tail_x6_r0_body.fincI33, PRE_first_tail_x6_r0_body.fincN33, PRE_first_tail_x6_r0_body.flnF33, PRE_first_tail_x6_r0_body.fh33, PRE_first_tail_x6_r0_body.fo33, PRE_first_tail_x6_r0_body.fok33, PRE_first_tail_x6_r0_body.fnd33, PRE_first_tail_x6_r0_body.fp33, PRE_first_tail_x6_r0_body.fnord33, PRE_first_tail_x6_r0_body.fi33, PRE_first_tail_x6_r0_body.fii33⟩
theorem PRE_first_tail_x6_r0_body.cnshift33 (clean : Conv.NClean (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P33.NL) (cl : SSt (· < 1509) PRE_first_tail_x6_r0_body.cx0_33.mlx) : NShift PRE_first_tail_x6_r0_body.P33 1509 PRE_first_tail_x6_r0_body.kappa33 PRE_first_tail_x6_r0_body.cx0_33 PRE_first_tail_x6_r0_body.cx1_33 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot33 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost33 (compact_a_eq PRE_first_tail_x6_r0_body.ckn033 PRE_first_tail_x6_r0_body.ckn133 PRE_first_tail_x6_r0_body.ckheap33 PRE_first_tail_x6_r0_body.ckpl33)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_33 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s332.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_33 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s332.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_33 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s332.ffi) = some PRE_first_tail_x6_r0_body.fxC_33
kernel_rfl PRE_first_tail_x6_r0_body.okrC_33 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s332.ffi) = some PRE_first_tail_x6_r0_body.krC_33
noncomputable def PRE_first_tail_x6_r0_body.fx0_33 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s334.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_33 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s334.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_33 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s334.ffi) = some PRE_first_tail_x6_r0_body.fx0_33
kernel_rfl PRE_first_tail_x6_r0_body.okr0_33 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s334.ffi) = some PRE_first_tail_x6_r0_body.kr0_33
noncomputable def PRE_first_tail_x6_r0_body.fx1_33 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s333.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_33 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s333.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_33 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s333.ffi) = some PRE_first_tail_x6_r0_body.fx1_33
kernel_rfl PRE_first_tail_x6_r0_body.okr1_33 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s333.ffi) = some PRE_first_tail_x6_r0_body.kr1_33
kernel_rfl PRE_first_tail_x6_r0_body.ff033 : PRE_first_tail_x6_r0_body.fx0_33 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_33 (PRE_first_tail_x6_r0_body.clo33.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_33.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff133 : PRE_first_tail_x6_r0_body.fx1_33 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_33 (PRE_first_tail_x6_r0_body.cwS33.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_33.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck33 : freedLB PRE_first_tail_x6_r0_body.kappa33 PRE_first_tail_x6_r0_body.cx0_33.mlx PRE_first_tail_x6_r0_body.fx0_33 PRE_first_tail_x6_r0_body.fx1_33 PRE_first_tail_x6_r0_body.clo33 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf033 : PRE_first_tail_x6_r0_body.kr0_33.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_33.flags (PRE_first_tail_x6_r0_body.clo33.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_33.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt033 : PRE_first_tail_x6_r0_body.kr0_33.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_33.targs (PRE_first_tail_x6_r0_body.clo33.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_33.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf133 : PRE_first_tail_x6_r0_body.kr1_33.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_33.flags (PRE_first_tail_x6_r0_body.cwS33.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_33.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt133 : PRE_first_tail_x6_r0_body.kr1_33.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_33.targs (PRE_first_tail_x6_r0_body.cwS33.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_33.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck33 : krecLB PRE_first_tail_x6_r0_body.kappa33 1509 PRE_first_tail_x6_r0_body.cx0_33.mlx PRE_first_tail_x6_r0_body.kr0_33 PRE_first_tail_x6_r0_body.kr1_33 PRE_first_tail_x6_r0_body.clo33 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn33 : Nat.ble 1500 1509 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge33 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s333.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s334.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR33 : pendRegB PRE_first_tail_x6_r0_body.kappa33 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe33 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s334.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s333.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift33 (clean : Conv.NClean (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P33.NL) (cl : SSt (· < 1509) PRE_first_tail_x6_r0_body.cx0_33.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_33.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_33.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_33.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s332.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_33.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P33 1509 PRE_first_tail_x6_r0_body.kappa33 PRE_first_tail_x6_r0_body.s334.ffi PRE_first_tail_x6_r0_body.s333.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift33 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue33, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp33 t ht),
    PRE_first_tail_x6_r0_body.cbridge33,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s334.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s333.ffi) (PRE_first_tail_x6_r0_body.cfoot33 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_33 PRE_first_tail_x6_r0_body.ofx1_33 hobjC PRE_first_tail_x6_r0_body.ff033 PRE_first_tail_x6_r0_body.ff133 PRE_first_tail_x6_r0_body.ffck33,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s334.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s333.ffi) (PRE_first_tail_x6_r0_body.cfoot33 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_33 PRE_first_tail_x6_r0_body.okr1_33 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn33) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf033 PRE_first_tail_x6_r0_body.fkt033 PRE_first_tail_x6_r0_body.fkf133 PRE_first_tail_x6_r0_body.fkt133 PRE_first_tail_x6_r0_body.fkck33,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh033 PRE_first_tail_x6_r0_body.cnh133 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe33) PRE_first_tail_x6_r0_body.cpendR33⟩

end Host.Load.Run.Tpl
end

section -- st33/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st33 0
host_stream_state PRE_first_tail_x6_r0_body.st33 1
host_stream_state PRE_first_tail_x6_r0_body.st33 2
host_stream_state PRE_first_tail_x6_r0_body.st33 3
end Host.Load.Run.Tpl
end

section -- Site33
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 33 of chain `PRE_first_tail_x6_r0_body`: `kvW__g33__g34` (`appendWindow`), the call state `PRE_first_tail_x6_r0_body.s332`, the merged state `PRE_first_tail_x6_r0_body.s333`,
the site template `PRE_first_tail_x6_r0_body.st33` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s334`: the merge.
The footprint's facts are in `SiteF33`, the compaction's in `SiteC33`, `SiteK33`, `SiteNa33`, `SiteNb33`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso33 : PRE_first_tail_x6_r0_body.st33.s0 = { PRE_first_tail_x6_r0_body.s332 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs33 : List Frame := PRE_first_tail_x6_r0_body.s332.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_33 : PRE_first_tail_x6_r0_body.S332.tab.length = 1500
kernel_rfl PRE_first_tail_x6_r0_body.tab0_33 : PRE_first_tail_x6_r0_body.st33.S0.tab = PRE_first_tail_x6_r0_body.S332.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws33 : List Nat := [1554, 1555, 1556, 1557, 1558, 1559, 1560, 1561, 1562, 1563, 1564, 1565, 1566, 1567, 1568, 1569, 1570]
kernel_rfl PRE_first_tail_x6_r0_body.fresh33 : (PRE_first_tail_x6_r0_body.S332.tab.all fun e => PRE_first_tail_x6_r0_body.ws33.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S332.oracle.all fun q => PRE_first_tail_x6_r0_body.ws33.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab33 : PRE_first_tail_x6_r0_body.S333.tab = PRE_first_tail_x6_r0_body.S332.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws33
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen33 : PRE_first_tail_x6_r0_body.st33.S3.tab.length - PRE_first_tail_x6_r0_body.st33.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged33`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap33 : PRE_first_tail_x6_r0_body.s333.heap = PRE_first_tail_x6_r0_body.st33.s3.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext33 : PRE_first_tail_x6_r0_body.s333.next = PRE_first_tail_x6_r0_body.st33.s3.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl33 : PRE_first_tail_x6_r0_body.s333.ctl = PRE_first_tail_x6_r0_body.st33.s3.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack33 : PRE_first_tail_x6_r0_body.s333.stack = PRE_first_tail_x6_r0_body.st33.s3.stack ++ PRE_first_tail_x6_r0_body.s332.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs33 : PRE_first_tail_x6_r0_body.s333.jobs = PRE_first_tail_x6_r0_body.st33.s3.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi33 : PRE_first_tail_x6_r0_body.s333.ffi = PRE_first_tail_x6_r0_body.st33.s3.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace33 : PRE_first_tail_x6_r0_body.s333.trace = PRE_first_tail_x6_r0_body.st33.s3.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores33 : PRE_first_tail_x6_r0_body.s333.stores = PRE_first_tail_x6_r0_body.st33.s3.stores

end Host.Load.Run.Tpl
end

section -- SiteD33
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 33 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived33 : PRE_first_tail_x6_r0_body.nr33.map (fun r => nth? PRE_first_tail_x6_r0_body.st33.S3.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo33 : PRE_first_tail_x6_r0_body.nr33.all (Nat.ble 1500) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj33 : PRE_first_tail_x6_r0_body.cws33.all (fun c => !PRE_first_tail_x6_r0_body.ws33.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ33 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws33 PRE_first_tail_x6_r0_body.crs33 PRE_first_tail_x6_r0_body.ws33

end Host.Load.Run.Tpl
end

section -- st33/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st33`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st33.wrR : List (Nat × Nat) := [(2672384, 2672385)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st33.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st33.s3.heap PRE_first_tail_x6_r0_body.st33.wrR ++ freshOf PRE_first_tail_x6_r0_body.st33.s3.heap PRE_first_tail_x6_r0_body.st33.s0.next PRE_first_tail_x6_r0_body.st33.s3.next
noncomputable def PRE_first_tail_x6_r0_body.st33.wr : List Nat := PRE_first_tail_x6_r0_body.st33.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st33.heapFoot : PRE_first_tail_x6_r0_body.st33.s3.heap = setAll PRE_first_tail_x6_r0_body.st33.s0.heap PRE_first_tail_x6_r0_body.st33.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st33.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st33.s0.next PRE_first_tail_x6_r0_body.st33.s3.next = true
theorem PRE_first_tail_x6_r0_body.st33.grows : PRE_first_tail_x6_r0_body.st33.s0.next ≤ PRE_first_tail_x6_r0_body.st33.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st33.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st33.wh : List Nat := [18865, 18866, 18867, 18868, 18869, 18870]
def PRE_first_tail_x6_r0_body.st33.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st33.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st33.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st33.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st33.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st33.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st33.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st33.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st33.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st33.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF33
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 33 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB33 : nodupT PRE_first_tail_x6_r0_body.st33.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup33 : PRE_first_tail_x6_r0_body.st33.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB33).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB33 : PRE_first_tail_x6_r0_body.st33.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound33 : ∀ b ∈ PRE_first_tail_x6_r0_body.st33.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB33 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr33 := PRE_first_tail_x6_r0_body.st33.s3.trace.take 26
kernel_rfl PRE_first_tail_x6_r0_body.traceEq33 : PRE_first_tail_x6_r0_body.st33.s3.trace = PRE_first_tail_x6_r0_body.trFr33 ++ PRE_first_tail_x6_r0_body.st33.s0.trace
theorem PRE_first_tail_x6_r0_body.trace33 : ∃ fr, PRE_first_tail_x6_r0_body.st33.s3.trace = fr ++ PRE_first_tail_x6_r0_body.st33.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq33⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide33 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB33 : (PRE_first_tail_x6_r0_body.wide33.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st33.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix33 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide33, WFix Map.id (Present PRE_first_tail_x6_r0_body.st33.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB33 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL33
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 33 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s333`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO33 : PRE_first_tail_x6_r0_body.st33.S0.oracle = PRE_first_tail_x6_r0_body.st33.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B33 : PRE_first_tail_x6_r0_body.st33.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st33.s0.next || (PRE_first_tail_x6_r0_body.st33.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot33 : Conv.StageFoot PRE_first_tail_x6_r0_body.st33.wr PRE_first_tail_x6_r0_body.st33.s0 PRE_first_tail_x6_r0_body.st33.s3 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st33.heapFoot PRE_first_tail_x6_r0_body.wrNodup33 PRE_first_tail_x6_r0_body.wrBound33 PRE_first_tail_x6_r0_body.wr0B33 PRE_first_tail_x6_r0_body.st33.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged33 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st33.F.S → PRE_first_tail_x6_r0_body.st33.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st33.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st33.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs33 PRE_first_tail_x6_r0_body.st33.wr PRE_first_tail_x6_r0_body.s332 PRE_first_tail_x6_r0_body.st33.s3 PRE_first_tail_x6_r0_body.st33.s0
      PRE_first_tail_x6_r0_body.st33.s3.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st33.F FR W stk M ν K PRE_first_tail_x6_r0_body.s333 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso33 PRE_first_tail_x6_r0_body.stFoot33 PRE_first_tail_x6_r0_body.wrNodup33 PRE_first_tail_x6_r0_body.wrBound33 PRE_first_tail_x6_r0_body.trace33 PRE_first_tail_x6_r0_body.mheap33
    PRE_first_tail_x6_r0_body.mnext33 PRE_first_tail_x6_r0_body.mctl33 PRE_first_tail_x6_r0_body.mstack33 PRE_first_tail_x6_r0_body.mjobs33 PRE_first_tail_x6_r0_body.mffi33 PRE_first_tail_x6_r0_body.mtrace33 PRE_first_tail_x6_r0_body.mstores33 h

def PRE_first_tail_x6_r0_body.arrEl33_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE33_2665 : arrOf PRE_first_tail_x6_r0_body.s333 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl33_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA33_2665 : isArrB PRE_first_tail_x6_r0_body.s333 2665 = true
theorem PRE_first_tail_x6_r0_body.arr33_2665 : ∃ o, PRE_first_tail_x6_r0_body.s333.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl33_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE33_2665 PRE_first_tail_x6_r0_body.arrA33_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN33_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl33_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR33_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl33_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN33_2665

def PRE_first_tail_x6_r0_body.arrEl33_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE33_2673467 : arrOf PRE_first_tail_x6_r0_body.s333 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl33_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA33_2673467 : isArrB PRE_first_tail_x6_r0_body.s333 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr33_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s333.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl33_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE33_2673467 PRE_first_tail_x6_r0_body.arrA33_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN33_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl33_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR33_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl33_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN33_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k33 : isArrB PRE_first_tail_x6_r0_body.s333 4910 = false
theorem PRE_first_tail_x6_r0_body.keep33 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s333 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k33 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr33_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl33_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ33
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 33 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s332`, the merged
state `PRE_first_tail_x6_r0_body.s333`, the canonical state `PRE_first_tail_x6_r0_body.s334`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl33 : PRE_first_tail_x6_r0_body.pl33.all (Nat.ble PRE_first_tail_x6_r0_body.s332.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd33 : nodupT PRE_first_tail_x6_r0_body.pl33 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn133 : Nat.ble PRE_first_tail_x6_r0_body.s332.next 2701685 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst33 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s332.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn33 : PRE_first_tail_x6_r0_body.s334.next = PRE_first_tail_x6_r0_body.s332.next + PRE_first_tail_x6_r0_body.pl33.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn33 : PRE_first_tail_x6_r0_body.s333.next = 2701685
kernel_rfl PRE_first_tail_x6_r0_body.zgrow33 : Nat.ble PRE_first_tail_x6_r0_body.s334.next PRE_first_tail_x6_r0_body.s333.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh33 : PRE_first_tail_x6_r0_body.S332.tab.all (fun e => PRE_first_tail_x6_r0_body.cws33.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd33 : nodupT PRE_first_tail_x6_r0_body.cws33 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi33 : PRE_first_tail_x6_r0_body.nr33.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S333.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt33 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s332.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg33_2665 : PRE_first_tail_x6_r0_body.s334.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s334 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk33_2665 : (objOf PRE_first_tail_x6_r0_body.s334 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm33_2665 : PRE_first_tail_x6_r0_body.s333.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa33.obj (objOf PRE_first_tail_x6_r0_body.s334 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s333 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg33_2673467 : PRE_first_tail_x6_r0_body.s334.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s334 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk33_2673467 : (objOf PRE_first_tail_x6_r0_body.s334 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm33_2673467 : PRE_first_tail_x6_r0_body.s333.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa33.obj (objOf PRE_first_tail_x6_r0_body.s334 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s333 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw33_4910 : (PRE_first_tail_x6_r0_body.s334.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw33_2673472 : (PRE_first_tail_x6_r0_body.s334.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw33_2673473 : (PRE_first_tail_x6_r0_body.s334.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd33 : PRE_first_tail_x6_r0_body.cl33.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr33 : PRE_first_tail_x6_r0_body.st33.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s332.next || PRE_first_tail_x6_r0_body.cl33.contains b) = true
def PRE_first_tail_x6_r0_body.zl33 : List Nat := PRE_first_tail_x6_r0_body.cl33.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE33 : PRE_first_tail_x6_r0_body.zl33.map (fun a => PRE_first_tail_x6_r0_body.s333.heap.get (PRE_first_tail_x6_r0_body.kappa33.a a)) = PRE_first_tail_x6_r0_body.zl33.map (fun a => (PRE_first_tail_x6_r0_body.s334.heap.get a).map PRE_first_tail_x6_r0_body.kappa33.hobj)
theorem PRE_first_tail_x6_r0_body.zimg33 : HeapImg PRE_first_tail_x6_r0_body.kappa33 PRE_first_tail_x6_r0_body.s334 PRE_first_tail_x6_r0_body.s333 PRE_first_tail_x6_r0_body.zl33 := PRE_first_tail_x6_r0_body.zimgE33
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl33 : PRE_first_tail_x6_r0_body.s333.ctl = PRE_first_tail_x6_r0_body.kappa33.ctl PRE_first_tail_x6_r0_body.s334.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack33 : PRE_first_tail_x6_r0_body.s333.stack = PRE_first_tail_x6_r0_body.s334.stack.map PRE_first_tail_x6_r0_body.kappa33.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs33 : PRE_first_tail_x6_r0_body.s333.jobs = PRE_first_tail_x6_r0_body.s334.jobs.map PRE_first_tail_x6_r0_body.kappa33.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores33 : PRE_first_tail_x6_r0_body.s333.stores = PRE_first_tail_x6_r0_body.kappa33.stores PRE_first_tail_x6_r0_body.s334.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots33 : checkRootsSupp PRE_first_tail_x6_r0_body.s334 1509 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC33 : PRE_first_tail_x6_r0_body.S332.tab.length + PRE_first_tail_x6_r0_body.cws33.length = 1509
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap33 : PRE_first_tail_x6_r0_body.kappa33 = Conv.Map.compact PRE_first_tail_x6_r0_body.s332.next 2701685 PRE_first_tail_x6_r0_body.S332.tab.length PRE_first_tail_x6_r0_body.pl33 (PRE_first_tail_x6_r0_body.nr33.map NumV.ref) PRE_first_tail_x6_r0_body.kd33.big
  PRE_first_tail_x6_r0_body.kd33.region PRE_first_tail_x6_r0_body.kd33.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin33 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s334.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc33 : Conv.jcleanListB (⟨18869, 15956, 2701335, 1509⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s334 PRE_first_tail_x6_r0_body.cl33 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB33 : noBigRootsP (fun i => !Conv.oldBigB (⟨18869, 15956, 2701335, 1509⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s334.trace PRE_first_tail_x6_r0_body.s334 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm33 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15950 = true
theorem PRE_first_tail_x6_r0_body.cjcl33 (h : Conv.JClean (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s332) : Conv.JClean (⟨18869, 15956, 2701335, 1509⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s334 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle33)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap33 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd33 a ha)) PRE_first_tail_x6_r0_body.zjc33

end Host.Load.Run.Tpl
end

section -- st33/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st33.bodyLast from PRE_first_tail_x6_r0_body.st33.s2 to PRE_first_tail_x6_r0_body.st33.s3 :
  interpS (step PRE_first_tail_x6_r0_body.st33.F PRE_first_tail_x6_r0_body.st33.s2).run PRE_first_tail_x6_r0_body.st33.S2 = some (PRE_first_tail_x6_r0_body.st33.s3, PRE_first_tail_x6_r0_body.st33.S3)
kernel_rfl PRE_first_tail_x6_r0_body.st33.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st33.s2.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st33.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st33.s3.stack = true

end Host.Load.Run.Tpl
end

section -- st33/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st33.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st33.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st33.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st33.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st33.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st33.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st33.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st33.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st33.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st33.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st33.s0 PRE_first_tail_x6_r0_body.st33.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st33.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st33.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st33.s2 PRE_first_tail_x6_r0_body.st33.S2) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st33/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st33.bodyK0F from PRE_first_tail_x6_r0_body.st33.s0 to PRE_first_tail_x6_r0_body.st33.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st33.F (PRE_first_tail_x6_r0_body.st33.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st33.ks 0).getD 0) PRE_first_tail_x6_r0_body.st33.s0 PRE_first_tail_x6_r0_body.st33.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st33.s1, PRE_first_tail_x6_r0_body.st33.S1)
theorem PRE_first_tail_x6_r0_body.st33.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st33.F (PRE_first_tail_x6_r0_body.st33.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st33.ks 0).getD 0) PRE_first_tail_x6_r0_body.st33.s0 PRE_first_tail_x6_r0_body.st33.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st33.s1, PRE_first_tail_x6_r0_body.st33.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st33.bodyOkLN_ok PRE_first_tail_x6_r0_body.st33.bodyK0F
end Host.Load.Run.Tpl
end

section -- st33/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st33.bodyK1F from PRE_first_tail_x6_r0_body.st33.s1 to PRE_first_tail_x6_r0_body.st33.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st33.F (PRE_first_tail_x6_r0_body.st33.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st33.ks 1).getD 0) PRE_first_tail_x6_r0_body.st33.s1 PRE_first_tail_x6_r0_body.st33.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st33.s2, PRE_first_tail_x6_r0_body.st33.S2)
theorem PRE_first_tail_x6_r0_body.st33.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st33.F (PRE_first_tail_x6_r0_body.st33.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st33.ks 1).getD 0) PRE_first_tail_x6_r0_body.st33.s1 PRE_first_tail_x6_r0_body.st33.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st33.s2, PRE_first_tail_x6_r0_body.st33.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st33.bodyOkLN_ok PRE_first_tail_x6_r0_body.st33.bodyK1F
end Host.Load.Run.Tpl
end

section -- st33/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st33.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st33.F (PRE_first_tail_x6_r0_body.st33.bodyOkL bytes rows) 3452 PRE_first_tail_x6_r0_body.st33.s0 PRE_first_tail_x6_r0_body.st33.S0 = some (PRE_first_tail_x6_r0_body.st33.s2, PRE_first_tail_x6_r0_body.st33.S2) :=
  runOk_trans PRE_first_tail_x6_r0_body.st33.F (PRE_first_tail_x6_r0_body.st33.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st33.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st33.ks 1).getD 0) PRE_first_tail_x6_r0_body.st33.s0 PRE_first_tail_x6_r0_body.st33.s1 PRE_first_tail_x6_r0_body.st33.s2 PRE_first_tail_x6_r0_body.st33.S0 PRE_first_tail_x6_r0_body.st33.S1 PRE_first_tail_x6_r0_body.st33.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st33.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st33.bodyK1 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st33.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st33.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st33.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st33.F (PRE_first_tail_x6_r0_body.st33.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st33.s0
  S0 := PRE_first_tail_x6_r0_body.st33.S0
  s1 := PRE_first_tail_x6_r0_body.st33.s2
  S1 := PRE_first_tail_x6_r0_body.st33.S2
  s2 := PRE_first_tail_x6_r0_body.st33.s3
  S2 := PRE_first_tail_x6_r0_body.st33.S3
  n := 3452
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st33.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st33.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st33.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st33.bodyHalt
  last := PRE_first_tail_x6_r0_body.st33.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st33.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC34
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 34 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s342` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa34` into the merged state
`PRE_first_tail_x6_r0_body.s341`. -/

def PRE_first_tail_x6_r0_body.pl34 : List Nat := []
def PRE_first_tail_x6_r0_body.nr34 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd34 : RData :=
  ⟨2701917, 2701919, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18882, 18882, 15966, 15966, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa34 : Map :=
  Conv.Map.compact 2701917 2701919 1532 PRE_first_tail_x6_r0_body.pl34 (PRE_first_tail_x6_r0_body.nr34.map NumV.ref) PRE_first_tail_x6_r0_body.kd34.big
    PRE_first_tail_x6_r0_body.kd34.region PRE_first_tail_x6_r0_body.kd34.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws34 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs34 : List SymE := PRE_first_tail_x6_r0_body.nr34.map fun r => (nth? PRE_first_tail_x6_r0_body.S341.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta34 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws34 PRE_first_tail_x6_r0_body.crs34
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB34 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab34 : PRE_first_tail_x6_r0_body.S342.tab = PRE_first_tail_x6_r0_body.S340.tab ++ PRE_first_tail_x6_r0_body.cws34.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace34 : PRE_first_tail_x6_r0_body.s342.trace = PRE_first_tail_x6_r0_body.s340.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext34 : PRE_first_tail_x6_r0_body.s342.next = 2701917
kernel_rfl PRE_first_tail_x6_r0_body.ccounters34 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx.nnext) = (18882, 15966)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue34 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s341.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa34.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp34 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx.tokens.all (bSN 1532) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean34 : Conv.cleanListB 18882 131072 (fun r => Nat.ble 75528 r) PRE_first_tail_x6_r0_body.s342
    (PRE_first_tail_x6_r0_body.wrB34 ++ (List.range 0).map (2701917 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs34 : bigsOutB 18882 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK34
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl34`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl34 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo34 : List Nat := []
def PRE_first_tail_x6_r0_body.cln34 : List Nat := []
def PRE_first_tail_x6_r0_body.cli34 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap34 : PRE_first_tail_x6_r0_body.s342.heap = Stage.setAll PRE_first_tail_x6_r0_body.s340.heap (PRE_first_tail_x6_r0_body.cl34.filterMap fun a => (PRE_first_tail_x6_r0_body.s342.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe34 : Nat.ble PRE_first_tail_x6_r0_body.s340.next PRE_first_tail_x6_r0_body.s342.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP34 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s340 PRE_first_tail_x6_r0_body.s342 PRE_first_tail_x6_r0_body.cl34 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp34 : Conv.suppListB PRE_first_tail_x6_r0_body.s342 1532 PRE_first_tail_x6_r0_body.cl34 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound34 : Conv.boundListB PRE_first_tail_x6_r0_body.s342 PRE_first_tail_x6_r0_body.cl34 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK34 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln34.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK34 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo34.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK34 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli34.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst34 : Conv.sstListB 1532 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx PRE_first_tail_x6_r0_body.cln34 PRE_first_tail_x6_r0_body.clo34 PRE_first_tail_x6_r0_body.cli34 = true

end Host.Load.Run.Tpl
end

section -- SiteCl34
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA34 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo34.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd34 : (PRE_first_tail_x6_r0_body.clo34 ++ PRE_first_tail_x6_r0_body.cln34 ++ PRE_first_tail_x6_r0_body.cli34).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle34 : Conv.Cnt.leB (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck34 : Conv.ncleanListB (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx PRE_first_tail_x6_r0_body.clo34 PRE_first_tail_x6_r0_body.cln34 PRE_first_tail_x6_r0_body.cli34 = true
theorem PRE_first_tail_x6_r0_body.cncl34 (h : Conv.NClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx) : Conv.NClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle34 PRE_first_tail_x6_r0_body.ckA34 PRE_first_tail_x6_r0_body.cobjsK34 PRE_first_tail_x6_r0_body.cnodesK34 PRE_first_tail_x6_r0_body.citemsK34 PRE_first_tail_x6_r0_body.cbd34 PRE_first_tail_x6_r0_body.cck34

end Host.Load.Run.Tpl
end

section -- SiteS34
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 34 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc34 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P34 : LoadP := PRE_first_tail_x6_r0_body.Pc34.raise 15966
kernel_rfl PRE_first_tail_x6_r0_body.craise34 : Nat.ble PRE_first_tail_x6_r0_body.Pc34.N0 15966 = true
theorem PRE_first_tail_x6_r0_body.raised34 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc34 PRE_first_tail_x6_r0_body.P34 :=
  .inr ⟨15966, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise34, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_34 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_34 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s341.ffi)
def PRE_first_tail_x6_r0_body.khinv34 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv34 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS34 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS34 : List Nat := List.range' 15966 0
def PRE_first_tail_x6_r0_body.ciS34 : List Nat := [] ++ List.range' 15966 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh034 : PRE_first_tail_x6_r0_body.kd34.nh0 = PRE_first_tail_x6_r0_body.cx0_34.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh134 : PRE_first_tail_x6_r0_body.kd34.nh1 = PRE_first_tail_x6_r0_body.cx1_34.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn034 : PRE_first_tail_x6_r0_body.kd34.nn0 = PRE_first_tail_x6_r0_body.cx0_34.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn134 : PRE_first_tail_x6_r0_body.kd34.nn1 = PRE_first_tail_x6_r0_body.cx1_34.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo34 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P34.lo && Nat.ble PRE_first_tail_x6_r0_body.P34.lo PRE_first_tail_x6_r0_body.cx0_34.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P34.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P34.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt34 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_34.mlx.next PRE_first_tail_x6_r0_body.cx1_34.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_34.mlx.nnext PRE_first_tail_x6_r0_body.cx1_34.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband34 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P34.NL && Nat.ble PRE_first_tail_x6_r0_body.P34.NL PRE_first_tail_x6_r0_body.P34.N0 && Nat.ble PRE_first_tail_x6_r0_body.P34.N0 PRE_first_tail_x6_r0_body.cx0_34.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow34 : PRE_first_tail_x6_r0_body.kd34.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren34 : checkRenG PRE_first_tail_x6_r0_body.kd34.hnd PRE_first_tail_x6_r0_body.khinv34 (phB PRE_first_tail_x6_r0_body.cx0_34.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband34 : PRE_first_tail_x6_r0_body.kd34.checkBand PRE_first_tail_x6_r0_body.P34.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos34 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd34.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren34 : checkRenG PRE_first_tail_x6_r0_body.kd34.node PRE_first_tail_x6_r0_body.kninv34 (pnB PRE_first_tail_x6_r0_body.cx0_34.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow34 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd34.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P34.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd34.nodeF j) PRE_first_tail_x6_r0_body.cx1_34.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a34 : PRE_first_tail_x6_r0_body.cx0_34.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b34 : PRE_first_tail_x6_r0_body.cx0_34.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok134 : PRE_first_tail_x6_r0_body.cx1_34.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend34 : PRE_first_tail_x6_r0_body.cx1_34.mlx.pending = PRE_first_tail_x6_r0_body.cx0_34.mlx.pending.map PRE_first_tail_x6_r0_body.kappa34.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh34 : PRE_first_tail_x6_r0_body.cx1_34.mlx.errh = PRE_first_tail_x6_r0_body.cx0_34.mlx.errh.map PRE_first_tail_x6_r0_body.kappa34.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles34 : PRE_first_tail_x6_r0_body.cx1_34.mlx.files = PRE_first_tail_x6_r0_body.cx0_34.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch34 : PRE_first_tail_x6_r0_body.cx1_34.mlx.arch = PRE_first_tail_x6_r0_body.cx0_34.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes34 : PRE_first_tail_x6_r0_body.cx1_34.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_34.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired34 : PRE_first_tail_x6_r0_body.cx1_34.mlx.wired = PRE_first_tail_x6_r0_body.cx0_34.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost34 : PRE_first_tail_x6_r0_body.cx1_34.host = PRE_first_tail_x6_r0_body.cx0_34.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd34`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn034 : PRE_first_tail_x6_r0_body.kd34.n0 = 2701917
kernel_rfl PRE_first_tail_x6_r0_body.ckn134 : PRE_first_tail_x6_r0_body.kd34.n1 = 2701919
kernel_rfl PRE_first_tail_x6_r0_body.ckheap34 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd34.heap).all (fun x => Nat.ble 2701917 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl34 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd34.heap.get (2701917 + j) = nth? PRE_first_tail_x6_r0_body.pl34 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja34 : Nat.ble 2701917 2701917 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn34 : Nat.ble 1532 1532 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD34 : Nat.ble 2701917 PRE_first_tail_x6_r0_body.kd34.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn34 : Nat.ble 18882 PRE_first_tail_x6_r0_body.kd34.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn34 : Nat.ble 15966 PRE_first_tail_x6_r0_body.kd34.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb34 : Nat.ble 18882 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap34 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd34.heap).all (Nat.ble (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd34 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd34.hnd).all (Nat.ble (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode34 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd34.node).all (Nat.ble (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix34 : Conv.FixOld (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa34 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja34) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn34) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD34) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn34) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn34) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb34) PRE_first_tail_x6_r0_body.fheap34 PRE_first_tail_x6_r0_body.fhnd34 PRE_first_tail_x6_r0_body.fnode34
kernel_rfl PRE_first_tail_x6_r0_body.fcxn34 : (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn34 : (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle034 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_34.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_34.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk34 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd34.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A34 : PRE_first_tail_x6_r0_body.cx1_34.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS34.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_34.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O34 : PRE_first_tail_x6_r0_body.cx1_34.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS34.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_34.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N34 : PRE_first_tail_x6_r0_body.cx1_34.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS34.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_34.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I34 : PRE_first_tail_x6_r0_body.cx1_34.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS34.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_34.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd34 : (PRE_first_tail_x6_r0_body.clo34 ++ PRE_first_tail_x6_r0_body.cln34 ++ PRE_first_tail_x6_r0_body.cli34 ++ PRE_first_tail_x6_r0_body.cwS34 ++ PRE_first_tail_x6_r0_body.cnS34 ++ PRE_first_tail_x6_r0_body.ciS34).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW34 : PRE_first_tail_x6_r0_body.cwS34.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo34.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI34 : PRE_first_tail_x6_r0_body.ciS34.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli34.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN34 : PRE_first_tail_x6_r0_body.cnS34.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF34 : PRE_first_tail_x6_r0_body.cln34.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh34 : PRE_first_tail_x6_r0_body.clo34.all (handleOK PRE_first_tail_x6_r0_body.kappa34 PRE_first_tail_x6_r0_body.P34.lo PRE_first_tail_x6_r0_body.cx0_34.mlx PRE_first_tail_x6_r0_body.cx1_34.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo34 : PRE_first_tail_x6_r0_body.clo34.map (fun h => PRE_first_tail_x6_r0_body.cx1_34.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa34.handle h)) = PRE_first_tail_x6_r0_body.clo34.map (fun h => (PRE_first_tail_x6_r0_body.cx0_34.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa34.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok34 : PRE_first_tail_x6_r0_body.clo34.all (objOK PRE_first_tail_x6_r0_body.kappa34 PRE_first_tail_x6_r0_body.P34.NL PRE_first_tail_x6_r0_body.cx0_34.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd34 : PRE_first_tail_x6_r0_body.cln34.all (nodeOKF PRE_first_tail_x6_r0_body.kappa34 PRE_first_tail_x6_r0_body.P34 PRE_first_tail_x6_r0_body.cx0_34.mlx PRE_first_tail_x6_r0_body.cx1_34.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp34 : ((PRE_first_tail_x6_r0_body.cln34.filter (fullB PRE_first_tail_x6_r0_body.P34))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_34.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa34.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln34.filter (fullB PRE_first_tail_x6_r0_body.P34))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_34.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa34.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI34 : incrB PRE_first_tail_x6_r0_body.kd34.nodeF (List.range' 15966 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK34 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd34.node).all (fun k => Nat.ble 15966 k && Nat.blt k 15966) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL34 : (PRE_first_tail_x6_r0_body.cln34.filter (Nat.ble PRE_first_tail_x6_r0_body.P34.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd34.nodeF i) && (Nat.blt i 15966 || Nat.ble PRE_first_tail_x6_r0_body.kd34.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord34 : (PRE_first_tail_x6_r0_body.cln34.filter (Nat.ble PRE_first_tail_x6_r0_body.P34.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd34.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd34.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd34.nodeF j) (PRE_first_tail_x6_r0_body.kd34.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow34 PRE_first_tail_x6_r0_body.cnn134 PRE_first_tail_x6_r0_body.fnordI34 PRE_first_tail_x6_r0_body.fnordK34 PRE_first_tail_x6_r0_body.fnordL34
kernel_rfl PRE_first_tail_x6_r0_body.fi34 : PRE_first_tail_x6_r0_body.cli34.all (pnB PRE_first_tail_x6_r0_body.cx0_34.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii34 : PRE_first_tail_x6_r0_body.cli34.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_34.mlx.items.get (PRE_first_tail_x6_r0_body.kappa34.node k) = (PRE_first_tail_x6_r0_body.cx0_34.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa34.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot34 (clean : Conv.NClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P34.NL) (cl : SSt (· < 1532) PRE_first_tail_x6_r0_body.cx0_34.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P34 1532 PRE_first_tail_x6_r0_body.kappa34 PRE_first_tail_x6_r0_body.kd34 PRE_first_tail_x6_r0_body.khinv34 PRE_first_tail_x6_r0_body.kninv34 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx PRE_first_tail_x6_r0_body.cx0_34.mlx PRE_first_tail_x6_r0_body.cx1_34.mlx (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo34 PRE_first_tail_x6_r0_body.cln34 PRE_first_tail_x6_r0_body.cli34 PRE_first_tail_x6_r0_body.cwS34 PRE_first_tail_x6_r0_body.cnS34 PRE_first_tail_x6_r0_body.ciS34 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh034, PRE_first_tail_x6_r0_body.cnh134, PRE_first_tail_x6_r0_body.cnn034, PRE_first_tail_x6_r0_body.cnn134, PRE_first_tail_x6_r0_body.cplo34, PRE_first_tail_x6_r0_body.ccnt34, PRE_first_tail_x6_r0_body.cnband34, PRE_first_tail_x6_r0_body.chbelow34, PRE_first_tail_x6_r0_body.chren34, PRE_first_tail_x6_r0_body.cband34, PRE_first_tail_x6_r0_body.cnh1pos34, PRE_first_tail_x6_r0_body.cnren34, PRE_first_tail_x6_r0_body.cnlow34, PRE_first_tail_x6_r0_body.cabs0a34, PRE_first_tail_x6_r0_body.cabs0b34, PRE_first_tail_x6_r0_body.ctok134, PRE_first_tail_x6_r0_body.cpend34, PRE_first_tail_x6_r0_body.cerrh34, PRE_first_tail_x6_r0_body.cfiles34, PRE_first_tail_x6_r0_body.carch34, PRE_first_tail_x6_r0_body.csizes34, PRE_first_tail_x6_r0_body.cwired34, PRE_first_tail_x6_r0_body.cfix34, clean, PRE_first_tail_x6_r0_body.fcxn34, PRE_first_tail_x6_r0_body.fcnn34, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle034, PRE_first_tail_x6_r0_body.fnk34, PRE_first_tail_x6_r0_body.ckA34, PRE_first_tail_x6_r0_body.cobjsK34, PRE_first_tail_x6_r0_body.cnodesK34, PRE_first_tail_x6_r0_body.citemsK34, PRE_first_tail_x6_r0_body.f1A34, PRE_first_tail_x6_r0_body.f1O34, PRE_first_tail_x6_r0_body.f1N34, PRE_first_tail_x6_r0_body.f1I34, PRE_first_tail_x6_r0_body.fbd34, PRE_first_tail_x6_r0_body.fincW34, PRE_first_tail_x6_r0_body.fincI34, PRE_first_tail_x6_r0_body.fincN34, PRE_first_tail_x6_r0_body.flnF34, PRE_first_tail_x6_r0_body.fh34, PRE_first_tail_x6_r0_body.fo34, PRE_first_tail_x6_r0_body.fok34, PRE_first_tail_x6_r0_body.fnd34, PRE_first_tail_x6_r0_body.fp34, PRE_first_tail_x6_r0_body.fnord34, PRE_first_tail_x6_r0_body.fi34, PRE_first_tail_x6_r0_body.fii34⟩
theorem PRE_first_tail_x6_r0_body.cnshift34 (clean : Conv.NClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P34.NL) (cl : SSt (· < 1532) PRE_first_tail_x6_r0_body.cx0_34.mlx) : NShift PRE_first_tail_x6_r0_body.P34 1532 PRE_first_tail_x6_r0_body.kappa34 PRE_first_tail_x6_r0_body.cx0_34 PRE_first_tail_x6_r0_body.cx1_34 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot34 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost34 (compact_a_eq PRE_first_tail_x6_r0_body.ckn034 PRE_first_tail_x6_r0_body.ckn134 PRE_first_tail_x6_r0_body.ckheap34 PRE_first_tail_x6_r0_body.ckpl34)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_34 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s340.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_34 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s340.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_34 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s340.ffi) = some PRE_first_tail_x6_r0_body.fxC_34
kernel_rfl PRE_first_tail_x6_r0_body.okrC_34 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s340.ffi) = some PRE_first_tail_x6_r0_body.krC_34
noncomputable def PRE_first_tail_x6_r0_body.fx0_34 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s342.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_34 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s342.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_34 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s342.ffi) = some PRE_first_tail_x6_r0_body.fx0_34
kernel_rfl PRE_first_tail_x6_r0_body.okr0_34 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s342.ffi) = some PRE_first_tail_x6_r0_body.kr0_34
noncomputable def PRE_first_tail_x6_r0_body.fx1_34 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s341.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_34 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s341.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_34 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s341.ffi) = some PRE_first_tail_x6_r0_body.fx1_34
kernel_rfl PRE_first_tail_x6_r0_body.okr1_34 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s341.ffi) = some PRE_first_tail_x6_r0_body.kr1_34
kernel_rfl PRE_first_tail_x6_r0_body.ff034 : PRE_first_tail_x6_r0_body.fx0_34 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_34 (PRE_first_tail_x6_r0_body.clo34.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_34.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff134 : PRE_first_tail_x6_r0_body.fx1_34 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_34 (PRE_first_tail_x6_r0_body.cwS34.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_34.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck34 : freedLB PRE_first_tail_x6_r0_body.kappa34 PRE_first_tail_x6_r0_body.cx0_34.mlx PRE_first_tail_x6_r0_body.fx0_34 PRE_first_tail_x6_r0_body.fx1_34 PRE_first_tail_x6_r0_body.clo34 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf034 : PRE_first_tail_x6_r0_body.kr0_34.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_34.flags (PRE_first_tail_x6_r0_body.clo34.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_34.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt034 : PRE_first_tail_x6_r0_body.kr0_34.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_34.targs (PRE_first_tail_x6_r0_body.clo34.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_34.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf134 : PRE_first_tail_x6_r0_body.kr1_34.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_34.flags (PRE_first_tail_x6_r0_body.cwS34.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_34.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt134 : PRE_first_tail_x6_r0_body.kr1_34.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_34.targs (PRE_first_tail_x6_r0_body.cwS34.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_34.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck34 : krecLB PRE_first_tail_x6_r0_body.kappa34 1532 PRE_first_tail_x6_r0_body.cx0_34.mlx PRE_first_tail_x6_r0_body.kr0_34 PRE_first_tail_x6_r0_body.kr1_34 PRE_first_tail_x6_r0_body.clo34 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn34 : Nat.ble 1532 1532 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge34 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s341.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s342.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR34 : pendRegB PRE_first_tail_x6_r0_body.kappa34 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe34 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s342.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s341.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift34 (clean : Conv.NClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P34.NL) (cl : SSt (· < 1532) PRE_first_tail_x6_r0_body.cx0_34.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_34.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_34.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_34.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s340.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_34.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P34 1532 PRE_first_tail_x6_r0_body.kappa34 PRE_first_tail_x6_r0_body.s342.ffi PRE_first_tail_x6_r0_body.s341.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift34 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue34, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp34 t ht),
    PRE_first_tail_x6_r0_body.cbridge34,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s342.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s341.ffi) (PRE_first_tail_x6_r0_body.cfoot34 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_34 PRE_first_tail_x6_r0_body.ofx1_34 hobjC PRE_first_tail_x6_r0_body.ff034 PRE_first_tail_x6_r0_body.ff134 PRE_first_tail_x6_r0_body.ffck34,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s342.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s341.ffi) (PRE_first_tail_x6_r0_body.cfoot34 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_34 PRE_first_tail_x6_r0_body.okr1_34 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn34) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf034 PRE_first_tail_x6_r0_body.fkt034 PRE_first_tail_x6_r0_body.fkf134 PRE_first_tail_x6_r0_body.fkt134 PRE_first_tail_x6_r0_body.fkck34,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh034 PRE_first_tail_x6_r0_body.cnh134 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe34) PRE_first_tail_x6_r0_body.cpendR34⟩

end Host.Load.Run.Tpl
end

section -- st34/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st34 0
host_stream_state PRE_first_tail_x6_r0_body.st34 1
host_stream_state PRE_first_tail_x6_r0_body.st34 2
end Host.Load.Run.Tpl
end

section -- Site34
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 34 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g34__g35` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s340`, the merged state `PRE_first_tail_x6_r0_body.s341`,
the site template `PRE_first_tail_x6_r0_body.st34` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s342`: the merge.
The footprint's facts are in `SiteF34`, the compaction's in `SiteC34`, `SiteK34`, `SiteNa34`, `SiteNb34`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso34 : PRE_first_tail_x6_r0_body.st34.s0 = { PRE_first_tail_x6_r0_body.s340 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs34 : List Frame := PRE_first_tail_x6_r0_body.s340.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_34 : PRE_first_tail_x6_r0_body.S340.tab.length = 1532
kernel_rfl PRE_first_tail_x6_r0_body.tab0_34 : PRE_first_tail_x6_r0_body.st34.S0.tab = PRE_first_tail_x6_r0_body.S340.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws34 : List Nat := [1580, 1581]
kernel_rfl PRE_first_tail_x6_r0_body.fresh34 : (PRE_first_tail_x6_r0_body.S340.tab.all fun e => PRE_first_tail_x6_r0_body.ws34.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S340.oracle.all fun q => PRE_first_tail_x6_r0_body.ws34.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab34 : PRE_first_tail_x6_r0_body.S341.tab = PRE_first_tail_x6_r0_body.S340.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws34
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen34 : PRE_first_tail_x6_r0_body.st34.S2.tab.length - PRE_first_tail_x6_r0_body.st34.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged34`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap34 : PRE_first_tail_x6_r0_body.s341.heap = PRE_first_tail_x6_r0_body.st34.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext34 : PRE_first_tail_x6_r0_body.s341.next = PRE_first_tail_x6_r0_body.st34.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl34 : PRE_first_tail_x6_r0_body.s341.ctl = PRE_first_tail_x6_r0_body.st34.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack34 : PRE_first_tail_x6_r0_body.s341.stack = PRE_first_tail_x6_r0_body.st34.s2.stack ++ PRE_first_tail_x6_r0_body.s340.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs34 : PRE_first_tail_x6_r0_body.s341.jobs = PRE_first_tail_x6_r0_body.st34.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi34 : PRE_first_tail_x6_r0_body.s341.ffi = PRE_first_tail_x6_r0_body.st34.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace34 : PRE_first_tail_x6_r0_body.s341.trace = PRE_first_tail_x6_r0_body.st34.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores34 : PRE_first_tail_x6_r0_body.s341.stores = PRE_first_tail_x6_r0_body.st34.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD34
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 34 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived34 : PRE_first_tail_x6_r0_body.nr34.map (fun r => nth? PRE_first_tail_x6_r0_body.st34.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo34 : PRE_first_tail_x6_r0_body.nr34.all (Nat.ble 1532) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj34 : PRE_first_tail_x6_r0_body.cws34.all (fun c => !PRE_first_tail_x6_r0_body.ws34.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ34 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws34 PRE_first_tail_x6_r0_body.crs34 PRE_first_tail_x6_r0_body.ws34

end Host.Load.Run.Tpl
end

section -- st34/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st34`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st34.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st34.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st34.s2.heap PRE_first_tail_x6_r0_body.st34.wrR ++ freshOf PRE_first_tail_x6_r0_body.st34.s2.heap PRE_first_tail_x6_r0_body.st34.s0.next PRE_first_tail_x6_r0_body.st34.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st34.wr : List Nat := PRE_first_tail_x6_r0_body.st34.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st34.heapFoot : PRE_first_tail_x6_r0_body.st34.s2.heap = setAll PRE_first_tail_x6_r0_body.st34.s0.heap PRE_first_tail_x6_r0_body.st34.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st34.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st34.s0.next PRE_first_tail_x6_r0_body.st34.s2.next = true
theorem PRE_first_tail_x6_r0_body.st34.grows : PRE_first_tail_x6_r0_body.st34.s0.next ≤ PRE_first_tail_x6_r0_body.st34.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st34.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st34.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st34.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st34.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st34.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st34.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st34.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st34.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st34.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st34.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st34.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st34.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF34
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 34 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB34 : nodupT PRE_first_tail_x6_r0_body.st34.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup34 : PRE_first_tail_x6_r0_body.st34.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB34).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB34 : PRE_first_tail_x6_r0_body.st34.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound34 : ∀ b ∈ PRE_first_tail_x6_r0_body.st34.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB34 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr34 := PRE_first_tail_x6_r0_body.st34.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq34 : PRE_first_tail_x6_r0_body.st34.s2.trace = PRE_first_tail_x6_r0_body.trFr34 ++ PRE_first_tail_x6_r0_body.st34.s0.trace
theorem PRE_first_tail_x6_r0_body.trace34 : ∃ fr, PRE_first_tail_x6_r0_body.st34.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st34.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq34⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide34 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB34 : (PRE_first_tail_x6_r0_body.wide34.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st34.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix34 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide34, WFix Map.id (Present PRE_first_tail_x6_r0_body.st34.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB34 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL34
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 34 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s341`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO34 : PRE_first_tail_x6_r0_body.st34.S0.oracle = PRE_first_tail_x6_r0_body.st34.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B34 : PRE_first_tail_x6_r0_body.st34.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st34.s0.next || (PRE_first_tail_x6_r0_body.st34.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot34 : Conv.StageFoot PRE_first_tail_x6_r0_body.st34.wr PRE_first_tail_x6_r0_body.st34.s0 PRE_first_tail_x6_r0_body.st34.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st34.heapFoot PRE_first_tail_x6_r0_body.wrNodup34 PRE_first_tail_x6_r0_body.wrBound34 PRE_first_tail_x6_r0_body.wr0B34 PRE_first_tail_x6_r0_body.st34.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged34 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st34.F.S → PRE_first_tail_x6_r0_body.st34.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st34.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st34.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs34 PRE_first_tail_x6_r0_body.st34.wr PRE_first_tail_x6_r0_body.s340 PRE_first_tail_x6_r0_body.st34.s2 PRE_first_tail_x6_r0_body.st34.s0
      PRE_first_tail_x6_r0_body.st34.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st34.F FR W stk M ν K PRE_first_tail_x6_r0_body.s341 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso34 PRE_first_tail_x6_r0_body.stFoot34 PRE_first_tail_x6_r0_body.wrNodup34 PRE_first_tail_x6_r0_body.wrBound34 PRE_first_tail_x6_r0_body.trace34 PRE_first_tail_x6_r0_body.mheap34
    PRE_first_tail_x6_r0_body.mnext34 PRE_first_tail_x6_r0_body.mctl34 PRE_first_tail_x6_r0_body.mstack34 PRE_first_tail_x6_r0_body.mjobs34 PRE_first_tail_x6_r0_body.mffi34 PRE_first_tail_x6_r0_body.mtrace34 PRE_first_tail_x6_r0_body.mstores34 h

def PRE_first_tail_x6_r0_body.arrEl34_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE34_2665 : arrOf PRE_first_tail_x6_r0_body.s341 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl34_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA34_2665 : isArrB PRE_first_tail_x6_r0_body.s341 2665 = true
theorem PRE_first_tail_x6_r0_body.arr34_2665 : ∃ o, PRE_first_tail_x6_r0_body.s341.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl34_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE34_2665 PRE_first_tail_x6_r0_body.arrA34_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN34_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl34_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR34_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl34_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN34_2665

def PRE_first_tail_x6_r0_body.arrEl34_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE34_2673467 : arrOf PRE_first_tail_x6_r0_body.s341 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl34_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA34_2673467 : isArrB PRE_first_tail_x6_r0_body.s341 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr34_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s341.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl34_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE34_2673467 PRE_first_tail_x6_r0_body.arrA34_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN34_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl34_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR34_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl34_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN34_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k34 : isArrB PRE_first_tail_x6_r0_body.s341 4910 = false
theorem PRE_first_tail_x6_r0_body.keep34 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s341 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k34 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr34_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl34_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ34
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 34 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s340`, the merged
state `PRE_first_tail_x6_r0_body.s341`, the canonical state `PRE_first_tail_x6_r0_body.s342`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl34 : PRE_first_tail_x6_r0_body.pl34.all (Nat.ble PRE_first_tail_x6_r0_body.s340.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd34 : nodupT PRE_first_tail_x6_r0_body.pl34 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn134 : Nat.ble PRE_first_tail_x6_r0_body.s340.next 2701919 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst34 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s340.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn34 : PRE_first_tail_x6_r0_body.s342.next = PRE_first_tail_x6_r0_body.s340.next + PRE_first_tail_x6_r0_body.pl34.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn34 : PRE_first_tail_x6_r0_body.s341.next = 2701919
kernel_rfl PRE_first_tail_x6_r0_body.zgrow34 : Nat.ble PRE_first_tail_x6_r0_body.s342.next PRE_first_tail_x6_r0_body.s341.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh34 : PRE_first_tail_x6_r0_body.S340.tab.all (fun e => PRE_first_tail_x6_r0_body.cws34.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd34 : nodupT PRE_first_tail_x6_r0_body.cws34 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi34 : PRE_first_tail_x6_r0_body.nr34.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S341.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt34 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s340.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg34_2665 : PRE_first_tail_x6_r0_body.s342.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s342 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk34_2665 : (objOf PRE_first_tail_x6_r0_body.s342 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm34_2665 : PRE_first_tail_x6_r0_body.s341.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa34.obj (objOf PRE_first_tail_x6_r0_body.s342 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s341 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg34_2673467 : PRE_first_tail_x6_r0_body.s342.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s342 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk34_2673467 : (objOf PRE_first_tail_x6_r0_body.s342 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm34_2673467 : PRE_first_tail_x6_r0_body.s341.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa34.obj (objOf PRE_first_tail_x6_r0_body.s342 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s341 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw34_4910 : (PRE_first_tail_x6_r0_body.s342.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw34_2673472 : (PRE_first_tail_x6_r0_body.s342.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw34_2673473 : (PRE_first_tail_x6_r0_body.s342.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd34 : PRE_first_tail_x6_r0_body.cl34.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr34 : PRE_first_tail_x6_r0_body.st34.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s340.next || PRE_first_tail_x6_r0_body.cl34.contains b) = true
def PRE_first_tail_x6_r0_body.zl34 : List Nat := PRE_first_tail_x6_r0_body.cl34.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE34 : PRE_first_tail_x6_r0_body.zl34.map (fun a => PRE_first_tail_x6_r0_body.s341.heap.get (PRE_first_tail_x6_r0_body.kappa34.a a)) = PRE_first_tail_x6_r0_body.zl34.map (fun a => (PRE_first_tail_x6_r0_body.s342.heap.get a).map PRE_first_tail_x6_r0_body.kappa34.hobj)
theorem PRE_first_tail_x6_r0_body.zimg34 : HeapImg PRE_first_tail_x6_r0_body.kappa34 PRE_first_tail_x6_r0_body.s342 PRE_first_tail_x6_r0_body.s341 PRE_first_tail_x6_r0_body.zl34 := PRE_first_tail_x6_r0_body.zimgE34
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl34 : PRE_first_tail_x6_r0_body.s341.ctl = PRE_first_tail_x6_r0_body.kappa34.ctl PRE_first_tail_x6_r0_body.s342.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack34 : PRE_first_tail_x6_r0_body.s341.stack = PRE_first_tail_x6_r0_body.s342.stack.map PRE_first_tail_x6_r0_body.kappa34.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs34 : PRE_first_tail_x6_r0_body.s341.jobs = PRE_first_tail_x6_r0_body.s342.jobs.map PRE_first_tail_x6_r0_body.kappa34.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores34 : PRE_first_tail_x6_r0_body.s341.stores = PRE_first_tail_x6_r0_body.kappa34.stores PRE_first_tail_x6_r0_body.s342.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots34 : checkRootsSupp PRE_first_tail_x6_r0_body.s342 1532 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC34 : PRE_first_tail_x6_r0_body.S340.tab.length + PRE_first_tail_x6_r0_body.cws34.length = 1532
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap34 : PRE_first_tail_x6_r0_body.kappa34 = Conv.Map.compact PRE_first_tail_x6_r0_body.s340.next 2701919 PRE_first_tail_x6_r0_body.S340.tab.length PRE_first_tail_x6_r0_body.pl34 (PRE_first_tail_x6_r0_body.nr34.map NumV.ref) PRE_first_tail_x6_r0_body.kd34.big
  PRE_first_tail_x6_r0_body.kd34.region PRE_first_tail_x6_r0_body.kd34.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin34 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s342.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc34 : Conv.jcleanListB (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s342 PRE_first_tail_x6_r0_body.cl34 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB34 : noBigRootsP (fun i => !Conv.oldBigB (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s342.trace PRE_first_tail_x6_r0_body.s342 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm34 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15966 = true
theorem PRE_first_tail_x6_r0_body.cjcl34 (h : Conv.JClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s340) : Conv.JClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s342 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle34)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap34 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd34 a ha)) PRE_first_tail_x6_r0_body.zjc34

end Host.Load.Run.Tpl
end

section -- st34/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st34.bodyLast from PRE_first_tail_x6_r0_body.st34.s1 to PRE_first_tail_x6_r0_body.st34.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st34.F PRE_first_tail_x6_r0_body.st34.s1).run PRE_first_tail_x6_r0_body.st34.S1 = some (PRE_first_tail_x6_r0_body.st34.s2, PRE_first_tail_x6_r0_body.st34.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st34.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st34.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st34.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st34.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st34/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st34.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st34.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st34.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st34.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st34.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st34.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st34.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st34.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st34.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st34.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st34.s0 PRE_first_tail_x6_r0_body.st34.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st34.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st34.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st34.s1 PRE_first_tail_x6_r0_body.st34.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st34/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st34.bodyK0F from PRE_first_tail_x6_r0_body.st34.s0 to PRE_first_tail_x6_r0_body.st34.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st34.F (PRE_first_tail_x6_r0_body.st34.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st34.ks 0).getD 0) PRE_first_tail_x6_r0_body.st34.s0 PRE_first_tail_x6_r0_body.st34.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st34.s1, PRE_first_tail_x6_r0_body.st34.S1)
theorem PRE_first_tail_x6_r0_body.st34.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st34.F (PRE_first_tail_x6_r0_body.st34.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st34.ks 0).getD 0) PRE_first_tail_x6_r0_body.st34.s0 PRE_first_tail_x6_r0_body.st34.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st34.s1, PRE_first_tail_x6_r0_body.st34.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st34.bodyOkLN_ok PRE_first_tail_x6_r0_body.st34.bodyK0F
end Host.Load.Run.Tpl
end

section -- st34/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st34.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st34.F (PRE_first_tail_x6_r0_body.st34.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st34.s0 PRE_first_tail_x6_r0_body.st34.S0 = some (PRE_first_tail_x6_r0_body.st34.s1, PRE_first_tail_x6_r0_body.st34.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st34.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st34.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st34.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st34.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st34.F (PRE_first_tail_x6_r0_body.st34.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st34.s0
  S0 := PRE_first_tail_x6_r0_body.st34.S0
  s1 := PRE_first_tail_x6_r0_body.st34.s1
  S1 := PRE_first_tail_x6_r0_body.st34.S1
  s2 := PRE_first_tail_x6_r0_body.st34.s2
  S2 := PRE_first_tail_x6_r0_body.st34.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st34.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st34.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st34.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st34.bodyHalt
  last := PRE_first_tail_x6_r0_body.st34.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st34.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC35
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 35 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s346` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa35` into the merged state
`PRE_first_tail_x6_r0_body.s345`. -/

def PRE_first_tail_x6_r0_body.pl35 : List Nat := [2702224]
def PRE_first_tail_x6_r0_body.nr35 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd35 : RData :=
  ⟨2702206, 2702225, Stage.setAll PTrie.nil [(2702205, 2702224)], Stage.setAll PTrie.nil [],
   18889, 18889, 15970, 15970, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa35 : Map :=
  Conv.Map.compact 2702205 2702225 1549 PRE_first_tail_x6_r0_body.pl35 (PRE_first_tail_x6_r0_body.nr35.map NumV.ref) PRE_first_tail_x6_r0_body.kd35.big
    PRE_first_tail_x6_r0_body.kd35.region PRE_first_tail_x6_r0_body.kd35.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws35 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs35 : List SymE := PRE_first_tail_x6_r0_body.nr35.map fun r => (nth? PRE_first_tail_x6_r0_body.S345.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta35 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws35 PRE_first_tail_x6_r0_body.crs35
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB35 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab35 : PRE_first_tail_x6_r0_body.S346.tab = PRE_first_tail_x6_r0_body.S344.tab ++ PRE_first_tail_x6_r0_body.cws35.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace35 : PRE_first_tail_x6_r0_body.s346.trace = PRE_first_tail_x6_r0_body.s344.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext35 : PRE_first_tail_x6_r0_body.s346.next = 2702206
kernel_rfl PRE_first_tail_x6_r0_body.ccounters35 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx.nnext) = (18889, 15970)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue35 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s345.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa35.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp35 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx.tokens.all (bSN 1549) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean35 : Conv.cleanListB 18889 131072 (fun r => Nat.ble 75556 r) PRE_first_tail_x6_r0_body.s346
    (PRE_first_tail_x6_r0_body.wrB35 ++ (List.range 1).map (2702205 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs35 : bigsOutB 18889 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK35
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl35`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl35 : List Nat := [2665, 2673467, 2702205]
def PRE_first_tail_x6_r0_body.clo35 : List Nat := []
def PRE_first_tail_x6_r0_body.cln35 : List Nat := []
def PRE_first_tail_x6_r0_body.cli35 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap35 : PRE_first_tail_x6_r0_body.s346.heap = Stage.setAll PRE_first_tail_x6_r0_body.s344.heap (PRE_first_tail_x6_r0_body.cl35.filterMap fun a => (PRE_first_tail_x6_r0_body.s346.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe35 : Nat.ble PRE_first_tail_x6_r0_body.s344.next PRE_first_tail_x6_r0_body.s346.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP35 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s344 PRE_first_tail_x6_r0_body.s346 PRE_first_tail_x6_r0_body.cl35 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp35 : Conv.suppListB PRE_first_tail_x6_r0_body.s346 1549 PRE_first_tail_x6_r0_body.cl35 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound35 : Conv.boundListB PRE_first_tail_x6_r0_body.s346 PRE_first_tail_x6_r0_body.cl35 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK35 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln35.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK35 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo35.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK35 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli35.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst35 : Conv.sstListB 1549 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx PRE_first_tail_x6_r0_body.cln35 PRE_first_tail_x6_r0_body.clo35 PRE_first_tail_x6_r0_body.cli35 = true

end Host.Load.Run.Tpl
end

section -- SiteCl35
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA35 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo35.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd35 : (PRE_first_tail_x6_r0_body.clo35 ++ PRE_first_tail_x6_r0_body.cln35 ++ PRE_first_tail_x6_r0_body.cli35).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle35 : Conv.Cnt.leB (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) (⟨18889, 15970, 2702206, 1549⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck35 : Conv.ncleanListB (⟨18889, 15970, 2702206, 1549⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx PRE_first_tail_x6_r0_body.clo35 PRE_first_tail_x6_r0_body.cln35 PRE_first_tail_x6_r0_body.cli35 = true
theorem PRE_first_tail_x6_r0_body.cncl35 (h : Conv.NClean (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx) : Conv.NClean (⟨18889, 15970, 2702206, 1549⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle35 PRE_first_tail_x6_r0_body.ckA35 PRE_first_tail_x6_r0_body.cobjsK35 PRE_first_tail_x6_r0_body.cnodesK35 PRE_first_tail_x6_r0_body.citemsK35 PRE_first_tail_x6_r0_body.cbd35 PRE_first_tail_x6_r0_body.cck35

end Host.Load.Run.Tpl
end

section -- SiteS35
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 35 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc35 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P35 : LoadP := PRE_first_tail_x6_r0_body.Pc35.raise 15970
kernel_rfl PRE_first_tail_x6_r0_body.craise35 : Nat.ble PRE_first_tail_x6_r0_body.Pc35.N0 15970 = true
theorem PRE_first_tail_x6_r0_body.raised35 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc35 PRE_first_tail_x6_r0_body.P35 :=
  .inr ⟨15970, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise35, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_35 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_35 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s345.ffi)
def PRE_first_tail_x6_r0_body.khinv35 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv35 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS35 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS35 : List Nat := List.range' 15970 0
def PRE_first_tail_x6_r0_body.ciS35 : List Nat := [] ++ List.range' 15970 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh035 : PRE_first_tail_x6_r0_body.kd35.nh0 = PRE_first_tail_x6_r0_body.cx0_35.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh135 : PRE_first_tail_x6_r0_body.kd35.nh1 = PRE_first_tail_x6_r0_body.cx1_35.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn035 : PRE_first_tail_x6_r0_body.kd35.nn0 = PRE_first_tail_x6_r0_body.cx0_35.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn135 : PRE_first_tail_x6_r0_body.kd35.nn1 = PRE_first_tail_x6_r0_body.cx1_35.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo35 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P35.lo && Nat.ble PRE_first_tail_x6_r0_body.P35.lo PRE_first_tail_x6_r0_body.cx0_35.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P35.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P35.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt35 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_35.mlx.next PRE_first_tail_x6_r0_body.cx1_35.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_35.mlx.nnext PRE_first_tail_x6_r0_body.cx1_35.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband35 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P35.NL && Nat.ble PRE_first_tail_x6_r0_body.P35.NL PRE_first_tail_x6_r0_body.P35.N0 && Nat.ble PRE_first_tail_x6_r0_body.P35.N0 PRE_first_tail_x6_r0_body.cx0_35.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow35 : PRE_first_tail_x6_r0_body.kd35.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren35 : checkRenG PRE_first_tail_x6_r0_body.kd35.hnd PRE_first_tail_x6_r0_body.khinv35 (phB PRE_first_tail_x6_r0_body.cx0_35.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband35 : PRE_first_tail_x6_r0_body.kd35.checkBand PRE_first_tail_x6_r0_body.P35.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos35 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd35.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren35 : checkRenG PRE_first_tail_x6_r0_body.kd35.node PRE_first_tail_x6_r0_body.kninv35 (pnB PRE_first_tail_x6_r0_body.cx0_35.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow35 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd35.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P35.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd35.nodeF j) PRE_first_tail_x6_r0_body.cx1_35.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a35 : PRE_first_tail_x6_r0_body.cx0_35.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b35 : PRE_first_tail_x6_r0_body.cx0_35.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok135 : PRE_first_tail_x6_r0_body.cx1_35.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend35 : PRE_first_tail_x6_r0_body.cx1_35.mlx.pending = PRE_first_tail_x6_r0_body.cx0_35.mlx.pending.map PRE_first_tail_x6_r0_body.kappa35.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh35 : PRE_first_tail_x6_r0_body.cx1_35.mlx.errh = PRE_first_tail_x6_r0_body.cx0_35.mlx.errh.map PRE_first_tail_x6_r0_body.kappa35.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles35 : PRE_first_tail_x6_r0_body.cx1_35.mlx.files = PRE_first_tail_x6_r0_body.cx0_35.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch35 : PRE_first_tail_x6_r0_body.cx1_35.mlx.arch = PRE_first_tail_x6_r0_body.cx0_35.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes35 : PRE_first_tail_x6_r0_body.cx1_35.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_35.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired35 : PRE_first_tail_x6_r0_body.cx1_35.mlx.wired = PRE_first_tail_x6_r0_body.cx0_35.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost35 : PRE_first_tail_x6_r0_body.cx1_35.host = PRE_first_tail_x6_r0_body.cx0_35.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd35`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn035 : PRE_first_tail_x6_r0_body.kd35.n0 = 2702206
kernel_rfl PRE_first_tail_x6_r0_body.ckn135 : PRE_first_tail_x6_r0_body.kd35.n1 = 2702225
kernel_rfl PRE_first_tail_x6_r0_body.ckheap35 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd35.heap).all (fun x => Nat.ble 2702205 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl35 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd35.heap.get (2702205 + j) = nth? PRE_first_tail_x6_r0_body.pl35 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja35 : Nat.ble 2702205 2702205 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn35 : Nat.ble 1549 1549 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD35 : Nat.ble 2702205 PRE_first_tail_x6_r0_body.kd35.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn35 : Nat.ble 18889 PRE_first_tail_x6_r0_body.kd35.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn35 : Nat.ble 15970 PRE_first_tail_x6_r0_body.kd35.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb35 : Nat.ble 18889 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap35 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd35.heap).all (Nat.ble (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd35 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd35.hnd).all (Nat.ble (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode35 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd35.node).all (Nat.ble (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix35 : Conv.FixOld (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa35 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja35) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn35) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD35) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn35) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn35) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb35) PRE_first_tail_x6_r0_body.fheap35 PRE_first_tail_x6_r0_body.fhnd35 PRE_first_tail_x6_r0_body.fnode35
kernel_rfl PRE_first_tail_x6_r0_body.fcxn35 : (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn35 : (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle035 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_35.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_35.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk35 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd35.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A35 : PRE_first_tail_x6_r0_body.cx1_35.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS35.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_35.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O35 : PRE_first_tail_x6_r0_body.cx1_35.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS35.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_35.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N35 : PRE_first_tail_x6_r0_body.cx1_35.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS35.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_35.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I35 : PRE_first_tail_x6_r0_body.cx1_35.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS35.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_35.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd35 : (PRE_first_tail_x6_r0_body.clo35 ++ PRE_first_tail_x6_r0_body.cln35 ++ PRE_first_tail_x6_r0_body.cli35 ++ PRE_first_tail_x6_r0_body.cwS35 ++ PRE_first_tail_x6_r0_body.cnS35 ++ PRE_first_tail_x6_r0_body.ciS35).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW35 : PRE_first_tail_x6_r0_body.cwS35.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo35.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI35 : PRE_first_tail_x6_r0_body.ciS35.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli35.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN35 : PRE_first_tail_x6_r0_body.cnS35.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF35 : PRE_first_tail_x6_r0_body.cln35.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh35 : PRE_first_tail_x6_r0_body.clo35.all (handleOK PRE_first_tail_x6_r0_body.kappa35 PRE_first_tail_x6_r0_body.P35.lo PRE_first_tail_x6_r0_body.cx0_35.mlx PRE_first_tail_x6_r0_body.cx1_35.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo35 : PRE_first_tail_x6_r0_body.clo35.map (fun h => PRE_first_tail_x6_r0_body.cx1_35.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa35.handle h)) = PRE_first_tail_x6_r0_body.clo35.map (fun h => (PRE_first_tail_x6_r0_body.cx0_35.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa35.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok35 : PRE_first_tail_x6_r0_body.clo35.all (objOK PRE_first_tail_x6_r0_body.kappa35 PRE_first_tail_x6_r0_body.P35.NL PRE_first_tail_x6_r0_body.cx0_35.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd35 : PRE_first_tail_x6_r0_body.cln35.all (nodeOKF PRE_first_tail_x6_r0_body.kappa35 PRE_first_tail_x6_r0_body.P35 PRE_first_tail_x6_r0_body.cx0_35.mlx PRE_first_tail_x6_r0_body.cx1_35.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp35 : ((PRE_first_tail_x6_r0_body.cln35.filter (fullB PRE_first_tail_x6_r0_body.P35))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_35.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa35.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln35.filter (fullB PRE_first_tail_x6_r0_body.P35))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_35.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa35.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI35 : incrB PRE_first_tail_x6_r0_body.kd35.nodeF (List.range' 15970 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK35 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd35.node).all (fun k => Nat.ble 15970 k && Nat.blt k 15970) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL35 : (PRE_first_tail_x6_r0_body.cln35.filter (Nat.ble PRE_first_tail_x6_r0_body.P35.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd35.nodeF i) && (Nat.blt i 15970 || Nat.ble PRE_first_tail_x6_r0_body.kd35.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord35 : (PRE_first_tail_x6_r0_body.cln35.filter (Nat.ble PRE_first_tail_x6_r0_body.P35.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd35.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd35.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd35.nodeF j) (PRE_first_tail_x6_r0_body.kd35.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow35 PRE_first_tail_x6_r0_body.cnn135 PRE_first_tail_x6_r0_body.fnordI35 PRE_first_tail_x6_r0_body.fnordK35 PRE_first_tail_x6_r0_body.fnordL35
kernel_rfl PRE_first_tail_x6_r0_body.fi35 : PRE_first_tail_x6_r0_body.cli35.all (pnB PRE_first_tail_x6_r0_body.cx0_35.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii35 : PRE_first_tail_x6_r0_body.cli35.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_35.mlx.items.get (PRE_first_tail_x6_r0_body.kappa35.node k) = (PRE_first_tail_x6_r0_body.cx0_35.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa35.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot35 (clean : Conv.NClean (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P35.NL) (cl : SSt (· < 1549) PRE_first_tail_x6_r0_body.cx0_35.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P35 1549 PRE_first_tail_x6_r0_body.kappa35 PRE_first_tail_x6_r0_body.kd35 PRE_first_tail_x6_r0_body.khinv35 PRE_first_tail_x6_r0_body.kninv35 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx PRE_first_tail_x6_r0_body.cx0_35.mlx PRE_first_tail_x6_r0_body.cx1_35.mlx (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo35 PRE_first_tail_x6_r0_body.cln35 PRE_first_tail_x6_r0_body.cli35 PRE_first_tail_x6_r0_body.cwS35 PRE_first_tail_x6_r0_body.cnS35 PRE_first_tail_x6_r0_body.ciS35 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh035, PRE_first_tail_x6_r0_body.cnh135, PRE_first_tail_x6_r0_body.cnn035, PRE_first_tail_x6_r0_body.cnn135, PRE_first_tail_x6_r0_body.cplo35, PRE_first_tail_x6_r0_body.ccnt35, PRE_first_tail_x6_r0_body.cnband35, PRE_first_tail_x6_r0_body.chbelow35, PRE_first_tail_x6_r0_body.chren35, PRE_first_tail_x6_r0_body.cband35, PRE_first_tail_x6_r0_body.cnh1pos35, PRE_first_tail_x6_r0_body.cnren35, PRE_first_tail_x6_r0_body.cnlow35, PRE_first_tail_x6_r0_body.cabs0a35, PRE_first_tail_x6_r0_body.cabs0b35, PRE_first_tail_x6_r0_body.ctok135, PRE_first_tail_x6_r0_body.cpend35, PRE_first_tail_x6_r0_body.cerrh35, PRE_first_tail_x6_r0_body.cfiles35, PRE_first_tail_x6_r0_body.carch35, PRE_first_tail_x6_r0_body.csizes35, PRE_first_tail_x6_r0_body.cwired35, PRE_first_tail_x6_r0_body.cfix35, clean, PRE_first_tail_x6_r0_body.fcxn35, PRE_first_tail_x6_r0_body.fcnn35, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle035, PRE_first_tail_x6_r0_body.fnk35, PRE_first_tail_x6_r0_body.ckA35, PRE_first_tail_x6_r0_body.cobjsK35, PRE_first_tail_x6_r0_body.cnodesK35, PRE_first_tail_x6_r0_body.citemsK35, PRE_first_tail_x6_r0_body.f1A35, PRE_first_tail_x6_r0_body.f1O35, PRE_first_tail_x6_r0_body.f1N35, PRE_first_tail_x6_r0_body.f1I35, PRE_first_tail_x6_r0_body.fbd35, PRE_first_tail_x6_r0_body.fincW35, PRE_first_tail_x6_r0_body.fincI35, PRE_first_tail_x6_r0_body.fincN35, PRE_first_tail_x6_r0_body.flnF35, PRE_first_tail_x6_r0_body.fh35, PRE_first_tail_x6_r0_body.fo35, PRE_first_tail_x6_r0_body.fok35, PRE_first_tail_x6_r0_body.fnd35, PRE_first_tail_x6_r0_body.fp35, PRE_first_tail_x6_r0_body.fnord35, PRE_first_tail_x6_r0_body.fi35, PRE_first_tail_x6_r0_body.fii35⟩
theorem PRE_first_tail_x6_r0_body.cnshift35 (clean : Conv.NClean (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P35.NL) (cl : SSt (· < 1549) PRE_first_tail_x6_r0_body.cx0_35.mlx) : NShift PRE_first_tail_x6_r0_body.P35 1549 PRE_first_tail_x6_r0_body.kappa35 PRE_first_tail_x6_r0_body.cx0_35 PRE_first_tail_x6_r0_body.cx1_35 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot35 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost35 (compact_a_eq PRE_first_tail_x6_r0_body.ckn035 PRE_first_tail_x6_r0_body.ckn135 PRE_first_tail_x6_r0_body.ckheap35 PRE_first_tail_x6_r0_body.ckpl35)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_35 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s344.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_35 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s344.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_35 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s344.ffi) = some PRE_first_tail_x6_r0_body.fxC_35
kernel_rfl PRE_first_tail_x6_r0_body.okrC_35 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s344.ffi) = some PRE_first_tail_x6_r0_body.krC_35
noncomputable def PRE_first_tail_x6_r0_body.fx0_35 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s346.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_35 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s346.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_35 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s346.ffi) = some PRE_first_tail_x6_r0_body.fx0_35
kernel_rfl PRE_first_tail_x6_r0_body.okr0_35 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s346.ffi) = some PRE_first_tail_x6_r0_body.kr0_35
noncomputable def PRE_first_tail_x6_r0_body.fx1_35 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s345.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_35 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s345.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_35 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s345.ffi) = some PRE_first_tail_x6_r0_body.fx1_35
kernel_rfl PRE_first_tail_x6_r0_body.okr1_35 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s345.ffi) = some PRE_first_tail_x6_r0_body.kr1_35
kernel_rfl PRE_first_tail_x6_r0_body.ff035 : PRE_first_tail_x6_r0_body.fx0_35 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_35 (PRE_first_tail_x6_r0_body.clo35.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_35.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff135 : PRE_first_tail_x6_r0_body.fx1_35 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_35 (PRE_first_tail_x6_r0_body.cwS35.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_35.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck35 : freedLB PRE_first_tail_x6_r0_body.kappa35 PRE_first_tail_x6_r0_body.cx0_35.mlx PRE_first_tail_x6_r0_body.fx0_35 PRE_first_tail_x6_r0_body.fx1_35 PRE_first_tail_x6_r0_body.clo35 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf035 : PRE_first_tail_x6_r0_body.kr0_35.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_35.flags (PRE_first_tail_x6_r0_body.clo35.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_35.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt035 : PRE_first_tail_x6_r0_body.kr0_35.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_35.targs (PRE_first_tail_x6_r0_body.clo35.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_35.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf135 : PRE_first_tail_x6_r0_body.kr1_35.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_35.flags (PRE_first_tail_x6_r0_body.cwS35.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_35.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt135 : PRE_first_tail_x6_r0_body.kr1_35.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_35.targs (PRE_first_tail_x6_r0_body.cwS35.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_35.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck35 : krecLB PRE_first_tail_x6_r0_body.kappa35 1549 PRE_first_tail_x6_r0_body.cx0_35.mlx PRE_first_tail_x6_r0_body.kr0_35 PRE_first_tail_x6_r0_body.kr1_35 PRE_first_tail_x6_r0_body.clo35 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn35 : Nat.ble 1549 1549 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge35 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s345.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s346.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR35 : pendRegB PRE_first_tail_x6_r0_body.kappa35 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe35 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s346.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s345.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift35 (clean : Conv.NClean (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P35.NL) (cl : SSt (· < 1549) PRE_first_tail_x6_r0_body.cx0_35.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_35.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_35.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_35.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s344.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_35.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P35 1549 PRE_first_tail_x6_r0_body.kappa35 PRE_first_tail_x6_r0_body.s346.ffi PRE_first_tail_x6_r0_body.s345.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift35 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue35, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp35 t ht),
    PRE_first_tail_x6_r0_body.cbridge35,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s346.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s345.ffi) (PRE_first_tail_x6_r0_body.cfoot35 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_35 PRE_first_tail_x6_r0_body.ofx1_35 hobjC PRE_first_tail_x6_r0_body.ff035 PRE_first_tail_x6_r0_body.ff135 PRE_first_tail_x6_r0_body.ffck35,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s346.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s345.ffi) (PRE_first_tail_x6_r0_body.cfoot35 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_35 PRE_first_tail_x6_r0_body.okr1_35 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn35) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf035 PRE_first_tail_x6_r0_body.fkt035 PRE_first_tail_x6_r0_body.fkf135 PRE_first_tail_x6_r0_body.fkt135 PRE_first_tail_x6_r0_body.fkck35,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh035 PRE_first_tail_x6_r0_body.cnh135 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe35) PRE_first_tail_x6_r0_body.cpendR35⟩

end Host.Load.Run.Tpl
end

section -- st35/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st35 0
host_stream_state PRE_first_tail_x6_r0_body.st35 1
host_stream_state PRE_first_tail_x6_r0_body.st35 2
end Host.Load.Run.Tpl
end

section -- Site35
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 35 of chain `PRE_first_tail_x6_r0_body`: `plan__g35__g36` (`plan`), the call state `PRE_first_tail_x6_r0_body.s344`, the merged state `PRE_first_tail_x6_r0_body.s345`,
the site template `PRE_first_tail_x6_r0_body.st35` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s346`: the merge.
The footprint's facts are in `SiteF35`, the compaction's in `SiteC35`, `SiteK35`, `SiteNa35`, `SiteNb35`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso35 : PRE_first_tail_x6_r0_body.st35.s0 = { PRE_first_tail_x6_r0_body.s344 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs35 : List Frame := PRE_first_tail_x6_r0_body.s344.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_35 : PRE_first_tail_x6_r0_body.S344.tab.length = 1549
kernel_rfl PRE_first_tail_x6_r0_body.tab0_35 : PRE_first_tail_x6_r0_body.st35.S0.tab = PRE_first_tail_x6_r0_body.S344.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws35 : List Nat := [1582, 1583, 1584, 1585, 1586, 1587, 1588, 1589, 1590]
kernel_rfl PRE_first_tail_x6_r0_body.fresh35 : (PRE_first_tail_x6_r0_body.S344.tab.all fun e => PRE_first_tail_x6_r0_body.ws35.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S344.oracle.all fun q => PRE_first_tail_x6_r0_body.ws35.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab35 : PRE_first_tail_x6_r0_body.S345.tab = PRE_first_tail_x6_r0_body.S344.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws35
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen35 : PRE_first_tail_x6_r0_body.st35.S2.tab.length - PRE_first_tail_x6_r0_body.st35.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged35`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap35 : PRE_first_tail_x6_r0_body.s345.heap = PRE_first_tail_x6_r0_body.st35.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext35 : PRE_first_tail_x6_r0_body.s345.next = PRE_first_tail_x6_r0_body.st35.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl35 : PRE_first_tail_x6_r0_body.s345.ctl = PRE_first_tail_x6_r0_body.st35.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack35 : PRE_first_tail_x6_r0_body.s345.stack = PRE_first_tail_x6_r0_body.st35.s2.stack ++ PRE_first_tail_x6_r0_body.s344.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs35 : PRE_first_tail_x6_r0_body.s345.jobs = PRE_first_tail_x6_r0_body.st35.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi35 : PRE_first_tail_x6_r0_body.s345.ffi = PRE_first_tail_x6_r0_body.st35.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace35 : PRE_first_tail_x6_r0_body.s345.trace = PRE_first_tail_x6_r0_body.st35.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores35 : PRE_first_tail_x6_r0_body.s345.stores = PRE_first_tail_x6_r0_body.st35.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD35
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 35 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived35 : PRE_first_tail_x6_r0_body.nr35.map (fun r => nth? PRE_first_tail_x6_r0_body.st35.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo35 : PRE_first_tail_x6_r0_body.nr35.all (Nat.ble 1549) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj35 : PRE_first_tail_x6_r0_body.cws35.all (fun c => !PRE_first_tail_x6_r0_body.ws35.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ35 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws35 PRE_first_tail_x6_r0_body.crs35 PRE_first_tail_x6_r0_body.ws35

end Host.Load.Run.Tpl
end

section -- st35/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st35`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st35.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st35.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st35.s2.heap PRE_first_tail_x6_r0_body.st35.wrR ++ freshOf PRE_first_tail_x6_r0_body.st35.s2.heap PRE_first_tail_x6_r0_body.st35.s0.next PRE_first_tail_x6_r0_body.st35.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st35.wr : List Nat := PRE_first_tail_x6_r0_body.st35.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st35.heapFoot : PRE_first_tail_x6_r0_body.st35.s2.heap = setAll PRE_first_tail_x6_r0_body.st35.s0.heap PRE_first_tail_x6_r0_body.st35.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st35.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st35.s0.next PRE_first_tail_x6_r0_body.st35.s2.next = true
theorem PRE_first_tail_x6_r0_body.st35.grows : PRE_first_tail_x6_r0_body.st35.s0.next ≤ PRE_first_tail_x6_r0_body.st35.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st35.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st35.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st35.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st35.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st35.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st35.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st35.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st35.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st35.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st35.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st35.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st35.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF35
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 35 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB35 : nodupT PRE_first_tail_x6_r0_body.st35.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup35 : PRE_first_tail_x6_r0_body.st35.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB35).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB35 : PRE_first_tail_x6_r0_body.st35.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound35 : ∀ b ∈ PRE_first_tail_x6_r0_body.st35.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB35 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr35 := PRE_first_tail_x6_r0_body.st35.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq35 : PRE_first_tail_x6_r0_body.st35.s2.trace = PRE_first_tail_x6_r0_body.trFr35 ++ PRE_first_tail_x6_r0_body.st35.s0.trace
theorem PRE_first_tail_x6_r0_body.trace35 : ∃ fr, PRE_first_tail_x6_r0_body.st35.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st35.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq35⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide35 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB35 : (PRE_first_tail_x6_r0_body.wide35.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st35.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix35 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide35, WFix Map.id (Present PRE_first_tail_x6_r0_body.st35.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB35 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL35
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 35 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s345`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO35 : PRE_first_tail_x6_r0_body.st35.S0.oracle = PRE_first_tail_x6_r0_body.st35.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B35 : PRE_first_tail_x6_r0_body.st35.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st35.s0.next || (PRE_first_tail_x6_r0_body.st35.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot35 : Conv.StageFoot PRE_first_tail_x6_r0_body.st35.wr PRE_first_tail_x6_r0_body.st35.s0 PRE_first_tail_x6_r0_body.st35.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st35.heapFoot PRE_first_tail_x6_r0_body.wrNodup35 PRE_first_tail_x6_r0_body.wrBound35 PRE_first_tail_x6_r0_body.wr0B35 PRE_first_tail_x6_r0_body.st35.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged35 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st35.F.S → PRE_first_tail_x6_r0_body.st35.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st35.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st35.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs35 PRE_first_tail_x6_r0_body.st35.wr PRE_first_tail_x6_r0_body.s344 PRE_first_tail_x6_r0_body.st35.s2 PRE_first_tail_x6_r0_body.st35.s0
      PRE_first_tail_x6_r0_body.st35.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st35.F FR W stk M ν K PRE_first_tail_x6_r0_body.s345 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso35 PRE_first_tail_x6_r0_body.stFoot35 PRE_first_tail_x6_r0_body.wrNodup35 PRE_first_tail_x6_r0_body.wrBound35 PRE_first_tail_x6_r0_body.trace35 PRE_first_tail_x6_r0_body.mheap35
    PRE_first_tail_x6_r0_body.mnext35 PRE_first_tail_x6_r0_body.mctl35 PRE_first_tail_x6_r0_body.mstack35 PRE_first_tail_x6_r0_body.mjobs35 PRE_first_tail_x6_r0_body.mffi35 PRE_first_tail_x6_r0_body.mtrace35 PRE_first_tail_x6_r0_body.mstores35 h

def PRE_first_tail_x6_r0_body.arrEl35_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE35_2665 : arrOf PRE_first_tail_x6_r0_body.s345 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl35_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA35_2665 : isArrB PRE_first_tail_x6_r0_body.s345 2665 = true
theorem PRE_first_tail_x6_r0_body.arr35_2665 : ∃ o, PRE_first_tail_x6_r0_body.s345.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl35_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE35_2665 PRE_first_tail_x6_r0_body.arrA35_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN35_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl35_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR35_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl35_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN35_2665

def PRE_first_tail_x6_r0_body.arrEl35_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE35_2673467 : arrOf PRE_first_tail_x6_r0_body.s345 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl35_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA35_2673467 : isArrB PRE_first_tail_x6_r0_body.s345 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr35_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s345.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl35_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE35_2673467 PRE_first_tail_x6_r0_body.arrA35_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN35_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl35_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR35_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl35_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN35_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k35 : isArrB PRE_first_tail_x6_r0_body.s345 4910 = false
theorem PRE_first_tail_x6_r0_body.keep35 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s345 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k35 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr35_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl35_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ35
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 35 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s344`, the merged
state `PRE_first_tail_x6_r0_body.s345`, the canonical state `PRE_first_tail_x6_r0_body.s346`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl35 : PRE_first_tail_x6_r0_body.pl35.all (Nat.ble PRE_first_tail_x6_r0_body.s344.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd35 : nodupT PRE_first_tail_x6_r0_body.pl35 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn135 : Nat.ble PRE_first_tail_x6_r0_body.s344.next 2702225 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst35 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s344.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn35 : PRE_first_tail_x6_r0_body.s346.next = PRE_first_tail_x6_r0_body.s344.next + PRE_first_tail_x6_r0_body.pl35.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn35 : PRE_first_tail_x6_r0_body.s345.next = 2702225
kernel_rfl PRE_first_tail_x6_r0_body.zgrow35 : Nat.ble PRE_first_tail_x6_r0_body.s346.next PRE_first_tail_x6_r0_body.s345.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh35 : PRE_first_tail_x6_r0_body.S344.tab.all (fun e => PRE_first_tail_x6_r0_body.cws35.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd35 : nodupT PRE_first_tail_x6_r0_body.cws35 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi35 : PRE_first_tail_x6_r0_body.nr35.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S345.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt35 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s344.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg35_2665 : PRE_first_tail_x6_r0_body.s346.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s346 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk35_2665 : (objOf PRE_first_tail_x6_r0_body.s346 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm35_2665 : PRE_first_tail_x6_r0_body.s345.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa35.obj (objOf PRE_first_tail_x6_r0_body.s346 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s345 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg35_2673467 : PRE_first_tail_x6_r0_body.s346.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s346 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk35_2673467 : (objOf PRE_first_tail_x6_r0_body.s346 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm35_2673467 : PRE_first_tail_x6_r0_body.s345.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa35.obj (objOf PRE_first_tail_x6_r0_body.s346 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s345 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw35_4910 : (PRE_first_tail_x6_r0_body.s346.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw35_2673472 : (PRE_first_tail_x6_r0_body.s346.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw35_2673473 : (PRE_first_tail_x6_r0_body.s346.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd35 : PRE_first_tail_x6_r0_body.cl35.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr35 : PRE_first_tail_x6_r0_body.st35.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s344.next || PRE_first_tail_x6_r0_body.cl35.contains b) = true
def PRE_first_tail_x6_r0_body.zl35 : List Nat := PRE_first_tail_x6_r0_body.cl35.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE35 : PRE_first_tail_x6_r0_body.zl35.map (fun a => PRE_first_tail_x6_r0_body.s345.heap.get (PRE_first_tail_x6_r0_body.kappa35.a a)) = PRE_first_tail_x6_r0_body.zl35.map (fun a => (PRE_first_tail_x6_r0_body.s346.heap.get a).map PRE_first_tail_x6_r0_body.kappa35.hobj)
theorem PRE_first_tail_x6_r0_body.zimg35 : HeapImg PRE_first_tail_x6_r0_body.kappa35 PRE_first_tail_x6_r0_body.s346 PRE_first_tail_x6_r0_body.s345 PRE_first_tail_x6_r0_body.zl35 := PRE_first_tail_x6_r0_body.zimgE35
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl35 : PRE_first_tail_x6_r0_body.s345.ctl = PRE_first_tail_x6_r0_body.kappa35.ctl PRE_first_tail_x6_r0_body.s346.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack35 : PRE_first_tail_x6_r0_body.s345.stack = PRE_first_tail_x6_r0_body.s346.stack.map PRE_first_tail_x6_r0_body.kappa35.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs35 : PRE_first_tail_x6_r0_body.s345.jobs = PRE_first_tail_x6_r0_body.s346.jobs.map PRE_first_tail_x6_r0_body.kappa35.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores35 : PRE_first_tail_x6_r0_body.s345.stores = PRE_first_tail_x6_r0_body.kappa35.stores PRE_first_tail_x6_r0_body.s346.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots35 : checkRootsSupp PRE_first_tail_x6_r0_body.s346 1549 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC35 : PRE_first_tail_x6_r0_body.S344.tab.length + PRE_first_tail_x6_r0_body.cws35.length = 1549
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap35 : PRE_first_tail_x6_r0_body.kappa35 = Conv.Map.compact PRE_first_tail_x6_r0_body.s344.next 2702225 PRE_first_tail_x6_r0_body.S344.tab.length PRE_first_tail_x6_r0_body.pl35 (PRE_first_tail_x6_r0_body.nr35.map NumV.ref) PRE_first_tail_x6_r0_body.kd35.big
  PRE_first_tail_x6_r0_body.kd35.region PRE_first_tail_x6_r0_body.kd35.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin35 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s346.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc35 : Conv.jcleanListB (⟨18889, 15970, 2702206, 1549⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s346 PRE_first_tail_x6_r0_body.cl35 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB35 : noBigRootsP (fun i => !Conv.oldBigB (⟨18889, 15970, 2702206, 1549⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s346.trace PRE_first_tail_x6_r0_body.s346 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm35 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15970 = true
theorem PRE_first_tail_x6_r0_body.cjcl35 (h : Conv.JClean (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s344) : Conv.JClean (⟨18889, 15970, 2702206, 1549⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s346 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle35)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap35 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd35 a ha)) PRE_first_tail_x6_r0_body.zjc35

end Host.Load.Run.Tpl
end

section -- st35/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st35.bodyLast from PRE_first_tail_x6_r0_body.st35.s1 to PRE_first_tail_x6_r0_body.st35.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st35.F PRE_first_tail_x6_r0_body.st35.s1).run PRE_first_tail_x6_r0_body.st35.S1 = some (PRE_first_tail_x6_r0_body.st35.s2, PRE_first_tail_x6_r0_body.st35.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st35.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st35.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st35.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st35.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st35/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st35.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st35.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st35.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st35.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st35.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st35.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st35.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st35.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st35.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st35.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st35.s0 PRE_first_tail_x6_r0_body.st35.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st35.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st35.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st35.s1 PRE_first_tail_x6_r0_body.st35.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st35/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st35.bodyK0F from PRE_first_tail_x6_r0_body.st35.s0 to PRE_first_tail_x6_r0_body.st35.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st35.F (PRE_first_tail_x6_r0_body.st35.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st35.ks 0).getD 0) PRE_first_tail_x6_r0_body.st35.s0 PRE_first_tail_x6_r0_body.st35.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st35.s1, PRE_first_tail_x6_r0_body.st35.S1)
theorem PRE_first_tail_x6_r0_body.st35.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st35.F (PRE_first_tail_x6_r0_body.st35.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st35.ks 0).getD 0) PRE_first_tail_x6_r0_body.st35.s0 PRE_first_tail_x6_r0_body.st35.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st35.s1, PRE_first_tail_x6_r0_body.st35.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st35.bodyOkLN_ok PRE_first_tail_x6_r0_body.st35.bodyK0F
end Host.Load.Run.Tpl
end

section -- st35/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st35.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st35.F (PRE_first_tail_x6_r0_body.st35.bodyOkL bytes rows) 206 PRE_first_tail_x6_r0_body.st35.s0 PRE_first_tail_x6_r0_body.st35.S0 = some (PRE_first_tail_x6_r0_body.st35.s1, PRE_first_tail_x6_r0_body.st35.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st35.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st35.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st35.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st35.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st35.F (PRE_first_tail_x6_r0_body.st35.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st35.s0
  S0 := PRE_first_tail_x6_r0_body.st35.S0
  s1 := PRE_first_tail_x6_r0_body.st35.s1
  S1 := PRE_first_tail_x6_r0_body.st35.S1
  s2 := PRE_first_tail_x6_r0_body.st35.s2
  S2 := PRE_first_tail_x6_r0_body.st35.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st35.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st35.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st35.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st35.bodyHalt
  last := PRE_first_tail_x6_r0_body.st35.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st35.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC36
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 36 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s363` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa36` into the merged state
`PRE_first_tail_x6_r0_body.s362`. -/

def PRE_first_tail_x6_r0_body.pl36 : List Nat := [2704815, 2703990, 2704821, 2704817, 2703992, 2704823]
def PRE_first_tail_x6_r0_body.nr36 : List Nat := [1652, 1651, 1627, 1635, 1640, 1645, 1650, 1624, 1625, 1626, 1633, 1634, 1622, 1629, 1630, 1631, 1632, 1628]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd36 : RData :=
  ⟨2703709, 2704858, Stage.setAll PTrie.nil [(2703703, 2704815), (2703704, 2703990), (2703705, 2704821), (2703706, 2704817), (2703707, 2703992), (2703708, 2704823)], Stage.setAll PTrie.nil [(18924, 18950), (18925, 18928), (18926, 18951)],
   18927, 18952, 16016, 16016, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(1622, .ref 1652), (1623, .ref 1651), (1624, .ref 1627), (1625, .ref 1635), (1626, .ref 1640), (1627, .ref 1645), (1628, .ref 1650), (1629, .ref 1624), (1630, .ref 1625), (1631, .ref 1626), (1632, .ref 1633), (1633, .ref 1634), (1634, .ref 1622), (1635, .ref 1629), (1636, .ref 1630), (1637, .ref 1631), (1638, .ref 1632), (1639, .ref 1628)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa36 : Map :=
  Conv.Map.compact 2703703 2704858 1622 PRE_first_tail_x6_r0_body.pl36 (PRE_first_tail_x6_r0_body.nr36.map NumV.ref) PRE_first_tail_x6_r0_body.kd36.big
    PRE_first_tail_x6_r0_body.kd36.region PRE_first_tail_x6_r0_body.kd36.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws36 : List Nat := [1622, 1623, 1624, 1625, 1626, 1627, 1628, 1629, 1630, 1631, 1632, 1633, 1634, 1635, 1636, 1637, 1638, 1639]
noncomputable def PRE_first_tail_x6_r0_body.crs36 : List SymE := PRE_first_tail_x6_r0_body.nr36.map fun r => (nth? PRE_first_tail_x6_r0_body.S362.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta36 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws36 PRE_first_tail_x6_r0_body.crs36
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB36 : List Nat := [2665, 2672393, 2673467, 2702877, 2703422, 2703678]

kernel_rfl PRE_first_tail_x6_r0_body.ctab36 : PRE_first_tail_x6_r0_body.S363.tab = PRE_first_tail_x6_r0_body.S361.tab ++ PRE_first_tail_x6_r0_body.cws36.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace36 : PRE_first_tail_x6_r0_body.s363.trace = PRE_first_tail_x6_r0_body.s361.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext36 : PRE_first_tail_x6_r0_body.s363.next = 2703709
kernel_rfl PRE_first_tail_x6_r0_body.ccounters36 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx.nnext) = (18927, 16016)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue36 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s362.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa36.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp36 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx.tokens.all (bSN 1640) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean36 : Conv.cleanListB 18927 131072 (fun r => Nat.ble 75708 r) PRE_first_tail_x6_r0_body.s363
    (PRE_first_tail_x6_r0_body.wrB36 ++ (List.range 6).map (2703703 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs36 : bigsOutB 18927 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK36
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl36`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl36 : List Nat := [2665, 2672393, 2673467, 2702877, 2703422, 2703678, 2703703, 2703704, 2703705, 2703706, 2703707, 2703708]
def PRE_first_tail_x6_r0_body.clo36 : List Nat := [18904, 18917, 18923, 18924, 18925, 18926]
def PRE_first_tail_x6_r0_body.cln36 : List Nat := [15989, 15990, 15991, 15992, 15993, 15994, 15995, 15996, 15997, 15998, 15999, 16000, 16001, 16002, 16003, 16004, 16005, 16006, 16007, 16008, 16009, 16010, 16011, 16012, 16013, 16014, 16015]
def PRE_first_tail_x6_r0_body.cli36 : List Nat := [15989, 15990, 15991, 15992, 15993, 15994, 15995, 15996, 15997, 15998, 15999, 16000, 16001, 16002, 16003, 16004, 16005, 16006, 16007, 16008, 16009, 16010, 16011, 16012, 16013, 16014, 16015]
kernel_rfl PRE_first_tail_x6_r0_body.cheap36 : PRE_first_tail_x6_r0_body.s363.heap = Stage.setAll PRE_first_tail_x6_r0_body.s361.heap (PRE_first_tail_x6_r0_body.cl36.filterMap fun a => (PRE_first_tail_x6_r0_body.s363.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe36 : Nat.ble PRE_first_tail_x6_r0_body.s361.next PRE_first_tail_x6_r0_body.s363.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP36 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s361 PRE_first_tail_x6_r0_body.s363 PRE_first_tail_x6_r0_body.cl36 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp36 : Conv.suppListB PRE_first_tail_x6_r0_body.s363 1640 PRE_first_tail_x6_r0_body.cl36 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound36 : Conv.boundListB PRE_first_tail_x6_r0_body.s363 PRE_first_tail_x6_r0_body.cl36 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK36 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln36.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK36 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo36.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK36 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli36.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst36 : Conv.sstListB 1640 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx PRE_first_tail_x6_r0_body.cln36 PRE_first_tail_x6_r0_body.clo36 PRE_first_tail_x6_r0_body.cli36 = true

end Host.Load.Run.Tpl
end

section -- SiteCl36
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA36 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo36.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd36 : (PRE_first_tail_x6_r0_body.clo36 ++ PRE_first_tail_x6_r0_body.cln36 ++ PRE_first_tail_x6_r0_body.cli36).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle36 : Conv.Cnt.leB (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) (⟨18927, 16016, 2703709, 1640⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck36 : Conv.ncleanListB (⟨18927, 16016, 2703709, 1640⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx PRE_first_tail_x6_r0_body.clo36 PRE_first_tail_x6_r0_body.cln36 PRE_first_tail_x6_r0_body.cli36 = true
theorem PRE_first_tail_x6_r0_body.cncl36 (h : Conv.NClean (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx) : Conv.NClean (⟨18927, 16016, 2703709, 1640⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle36 PRE_first_tail_x6_r0_body.ckA36 PRE_first_tail_x6_r0_body.cobjsK36 PRE_first_tail_x6_r0_body.cnodesK36 PRE_first_tail_x6_r0_body.citemsK36 PRE_first_tail_x6_r0_body.cbd36 PRE_first_tail_x6_r0_body.cck36

end Host.Load.Run.Tpl
end

section -- SiteS36
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 36 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc36 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P36 : LoadP := PRE_first_tail_x6_r0_body.Pc36.raise 16016
kernel_rfl PRE_first_tail_x6_r0_body.craise36 : Nat.ble PRE_first_tail_x6_r0_body.Pc36.N0 16016 = true
theorem PRE_first_tail_x6_r0_body.raised36 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc36 PRE_first_tail_x6_r0_body.P36 :=
  .inr ⟨16016, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise36, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_36 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_36 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s362.ffi)
def PRE_first_tail_x6_r0_body.khinv36 : PTrie Nat := Stage.setAll PTrie.nil [(18950, 18924), (18928, 18925), (18951, 18926)]
def PRE_first_tail_x6_r0_body.kninv36 : PTrie Nat := Stage.setAll PTrie.nil [(15989, 15989), (15990, 15990), (15991, 15991), (15992, 15992), (15993, 15993), (15994, 15994), (15995, 15995), (15996, 15996), (15997, 15997), (15998, 15998), (15999, 15999), (16000, 16000), (16001, 16001), (16002, 16002), (16003, 16003), (16004, 16004), (16005, 16005), (16006, 16006), (16007, 16007), (16008, 16008), (16009, 16009), (16010, 16010), (16011, 16011), (16012, 16012), (16013, 16013), (16014, 16014), (16015, 16015)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS36 : List Nat := [18904, 18917, 18923, 18924, 18925, 18926, 18927, 18928, 18929, 18930, 18931, 18932, 18933, 18934, 18935, 18936, 18937, 18938, 18939, 18940, 18941, 18942, 18943, 18944, 18945, 18946, 18947, 18948, 18949, 18950, 18951]
def PRE_first_tail_x6_r0_body.cnS36 : List Nat := List.range' 15989 27
def PRE_first_tail_x6_r0_body.ciS36 : List Nat := [] ++ List.range' 15989 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh036 : PRE_first_tail_x6_r0_body.kd36.nh0 = PRE_first_tail_x6_r0_body.cx0_36.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh136 : PRE_first_tail_x6_r0_body.kd36.nh1 = PRE_first_tail_x6_r0_body.cx1_36.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn036 : PRE_first_tail_x6_r0_body.kd36.nn0 = PRE_first_tail_x6_r0_body.cx0_36.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn136 : PRE_first_tail_x6_r0_body.kd36.nn1 = PRE_first_tail_x6_r0_body.cx1_36.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo36 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P36.lo && Nat.ble PRE_first_tail_x6_r0_body.P36.lo PRE_first_tail_x6_r0_body.cx0_36.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P36.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P36.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt36 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_36.mlx.next PRE_first_tail_x6_r0_body.cx1_36.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_36.mlx.nnext PRE_first_tail_x6_r0_body.cx1_36.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband36 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P36.NL && Nat.ble PRE_first_tail_x6_r0_body.P36.NL PRE_first_tail_x6_r0_body.P36.N0 && Nat.ble PRE_first_tail_x6_r0_body.P36.N0 PRE_first_tail_x6_r0_body.cx0_36.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow36 : PRE_first_tail_x6_r0_body.kd36.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren36 : checkRenG PRE_first_tail_x6_r0_body.kd36.hnd PRE_first_tail_x6_r0_body.khinv36 (phB PRE_first_tail_x6_r0_body.cx0_36.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband36 : PRE_first_tail_x6_r0_body.kd36.checkBand PRE_first_tail_x6_r0_body.P36.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos36 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd36.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren36 : checkRenG PRE_first_tail_x6_r0_body.kd36.node PRE_first_tail_x6_r0_body.kninv36 (pnB PRE_first_tail_x6_r0_body.cx0_36.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow36 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd36.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P36.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd36.nodeF j) PRE_first_tail_x6_r0_body.cx1_36.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a36 : PRE_first_tail_x6_r0_body.cx0_36.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b36 : PRE_first_tail_x6_r0_body.cx0_36.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok136 : PRE_first_tail_x6_r0_body.cx1_36.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend36 : PRE_first_tail_x6_r0_body.cx1_36.mlx.pending = PRE_first_tail_x6_r0_body.cx0_36.mlx.pending.map PRE_first_tail_x6_r0_body.kappa36.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh36 : PRE_first_tail_x6_r0_body.cx1_36.mlx.errh = PRE_first_tail_x6_r0_body.cx0_36.mlx.errh.map PRE_first_tail_x6_r0_body.kappa36.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles36 : PRE_first_tail_x6_r0_body.cx1_36.mlx.files = PRE_first_tail_x6_r0_body.cx0_36.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch36 : PRE_first_tail_x6_r0_body.cx1_36.mlx.arch = PRE_first_tail_x6_r0_body.cx0_36.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes36 : PRE_first_tail_x6_r0_body.cx1_36.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_36.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired36 : PRE_first_tail_x6_r0_body.cx1_36.mlx.wired = PRE_first_tail_x6_r0_body.cx0_36.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost36 : PRE_first_tail_x6_r0_body.cx1_36.host = PRE_first_tail_x6_r0_body.cx0_36.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd36`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn036 : PRE_first_tail_x6_r0_body.kd36.n0 = 2703709
kernel_rfl PRE_first_tail_x6_r0_body.ckn136 : PRE_first_tail_x6_r0_body.kd36.n1 = 2704858
kernel_rfl PRE_first_tail_x6_r0_body.ckheap36 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd36.heap).all (fun x => Nat.ble 2703703 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl36 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd36.heap.get (2703703 + j) = nth? PRE_first_tail_x6_r0_body.pl36 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja36 : Nat.ble 2703703 2703703 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn36 : Nat.ble 1622 1622 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD36 : Nat.ble 2703703 PRE_first_tail_x6_r0_body.kd36.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn36 : Nat.ble 18924 PRE_first_tail_x6_r0_body.kd36.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn36 : Nat.ble 15989 PRE_first_tail_x6_r0_body.kd36.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb36 : Nat.ble 18924 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap36 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd36.heap).all (Nat.ble (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd36 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd36.hnd).all (Nat.ble (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode36 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd36.node).all (Nat.ble (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix36 : Conv.FixOld (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa36 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja36) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn36) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD36) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn36) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn36) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb36) PRE_first_tail_x6_r0_body.fheap36 PRE_first_tail_x6_r0_body.fhnd36 PRE_first_tail_x6_r0_body.fnode36
kernel_rfl PRE_first_tail_x6_r0_body.fcxn36 : (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn36 : (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle036 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_36.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_36.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk36 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd36.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A36 : PRE_first_tail_x6_r0_body.cx1_36.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS36.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_36.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O36 : PRE_first_tail_x6_r0_body.cx1_36.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS36.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_36.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N36 : PRE_first_tail_x6_r0_body.cx1_36.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS36.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_36.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I36 : PRE_first_tail_x6_r0_body.cx1_36.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS36.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_36.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd36 : (PRE_first_tail_x6_r0_body.clo36 ++ PRE_first_tail_x6_r0_body.cln36 ++ PRE_first_tail_x6_r0_body.cli36 ++ PRE_first_tail_x6_r0_body.cwS36 ++ PRE_first_tail_x6_r0_body.cnS36 ++ PRE_first_tail_x6_r0_body.ciS36).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW36 : PRE_first_tail_x6_r0_body.cwS36.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo36.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI36 : PRE_first_tail_x6_r0_body.ciS36.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli36.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN36 : PRE_first_tail_x6_r0_body.cnS36.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF36 : PRE_first_tail_x6_r0_body.cln36.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh36 : PRE_first_tail_x6_r0_body.clo36.all (handleOK PRE_first_tail_x6_r0_body.kappa36 PRE_first_tail_x6_r0_body.P36.lo PRE_first_tail_x6_r0_body.cx0_36.mlx PRE_first_tail_x6_r0_body.cx1_36.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo36 : PRE_first_tail_x6_r0_body.clo36.map (fun h => PRE_first_tail_x6_r0_body.cx1_36.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa36.handle h)) = PRE_first_tail_x6_r0_body.clo36.map (fun h => (PRE_first_tail_x6_r0_body.cx0_36.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa36.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok36 : PRE_first_tail_x6_r0_body.clo36.all (objOK PRE_first_tail_x6_r0_body.kappa36 PRE_first_tail_x6_r0_body.P36.NL PRE_first_tail_x6_r0_body.cx0_36.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd36 : PRE_first_tail_x6_r0_body.cln36.all (nodeOKF PRE_first_tail_x6_r0_body.kappa36 PRE_first_tail_x6_r0_body.P36 PRE_first_tail_x6_r0_body.cx0_36.mlx PRE_first_tail_x6_r0_body.cx1_36.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp36 : ((PRE_first_tail_x6_r0_body.cln36.filter (fullB PRE_first_tail_x6_r0_body.P36))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_36.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa36.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln36.filter (fullB PRE_first_tail_x6_r0_body.P36))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_36.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa36.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI36 : incrB PRE_first_tail_x6_r0_body.kd36.nodeF (List.range' 15989 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK36 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd36.node).all (fun k => Nat.ble 15989 k && Nat.blt k 16016) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL36 : (PRE_first_tail_x6_r0_body.cln36.filter (Nat.ble PRE_first_tail_x6_r0_body.P36.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd36.nodeF i) && (Nat.blt i 16016 || Nat.ble PRE_first_tail_x6_r0_body.kd36.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord36 : (PRE_first_tail_x6_r0_body.cln36.filter (Nat.ble PRE_first_tail_x6_r0_body.P36.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd36.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd36.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd36.nodeF j) (PRE_first_tail_x6_r0_body.kd36.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow36 PRE_first_tail_x6_r0_body.cnn136 PRE_first_tail_x6_r0_body.fnordI36 PRE_first_tail_x6_r0_body.fnordK36 PRE_first_tail_x6_r0_body.fnordL36
kernel_rfl PRE_first_tail_x6_r0_body.fi36 : PRE_first_tail_x6_r0_body.cli36.all (pnB PRE_first_tail_x6_r0_body.cx0_36.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii36 : PRE_first_tail_x6_r0_body.cli36.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_36.mlx.items.get (PRE_first_tail_x6_r0_body.kappa36.node k) = (PRE_first_tail_x6_r0_body.cx0_36.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa36.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot36 (clean : Conv.NClean (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P36.NL) (cl : SSt (· < 1640) PRE_first_tail_x6_r0_body.cx0_36.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P36 1640 PRE_first_tail_x6_r0_body.kappa36 PRE_first_tail_x6_r0_body.kd36 PRE_first_tail_x6_r0_body.khinv36 PRE_first_tail_x6_r0_body.kninv36 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx PRE_first_tail_x6_r0_body.cx0_36.mlx PRE_first_tail_x6_r0_body.cx1_36.mlx (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo36 PRE_first_tail_x6_r0_body.cln36 PRE_first_tail_x6_r0_body.cli36 PRE_first_tail_x6_r0_body.cwS36 PRE_first_tail_x6_r0_body.cnS36 PRE_first_tail_x6_r0_body.ciS36 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh036, PRE_first_tail_x6_r0_body.cnh136, PRE_first_tail_x6_r0_body.cnn036, PRE_first_tail_x6_r0_body.cnn136, PRE_first_tail_x6_r0_body.cplo36, PRE_first_tail_x6_r0_body.ccnt36, PRE_first_tail_x6_r0_body.cnband36, PRE_first_tail_x6_r0_body.chbelow36, PRE_first_tail_x6_r0_body.chren36, PRE_first_tail_x6_r0_body.cband36, PRE_first_tail_x6_r0_body.cnh1pos36, PRE_first_tail_x6_r0_body.cnren36, PRE_first_tail_x6_r0_body.cnlow36, PRE_first_tail_x6_r0_body.cabs0a36, PRE_first_tail_x6_r0_body.cabs0b36, PRE_first_tail_x6_r0_body.ctok136, PRE_first_tail_x6_r0_body.cpend36, PRE_first_tail_x6_r0_body.cerrh36, PRE_first_tail_x6_r0_body.cfiles36, PRE_first_tail_x6_r0_body.carch36, PRE_first_tail_x6_r0_body.csizes36, PRE_first_tail_x6_r0_body.cwired36, PRE_first_tail_x6_r0_body.cfix36, clean, PRE_first_tail_x6_r0_body.fcxn36, PRE_first_tail_x6_r0_body.fcnn36, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle036, PRE_first_tail_x6_r0_body.fnk36, PRE_first_tail_x6_r0_body.ckA36, PRE_first_tail_x6_r0_body.cobjsK36, PRE_first_tail_x6_r0_body.cnodesK36, PRE_first_tail_x6_r0_body.citemsK36, PRE_first_tail_x6_r0_body.f1A36, PRE_first_tail_x6_r0_body.f1O36, PRE_first_tail_x6_r0_body.f1N36, PRE_first_tail_x6_r0_body.f1I36, PRE_first_tail_x6_r0_body.fbd36, PRE_first_tail_x6_r0_body.fincW36, PRE_first_tail_x6_r0_body.fincI36, PRE_first_tail_x6_r0_body.fincN36, PRE_first_tail_x6_r0_body.flnF36, PRE_first_tail_x6_r0_body.fh36, PRE_first_tail_x6_r0_body.fo36, PRE_first_tail_x6_r0_body.fok36, PRE_first_tail_x6_r0_body.fnd36, PRE_first_tail_x6_r0_body.fp36, PRE_first_tail_x6_r0_body.fnord36, PRE_first_tail_x6_r0_body.fi36, PRE_first_tail_x6_r0_body.fii36⟩
theorem PRE_first_tail_x6_r0_body.cnshift36 (clean : Conv.NClean (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P36.NL) (cl : SSt (· < 1640) PRE_first_tail_x6_r0_body.cx0_36.mlx) : NShift PRE_first_tail_x6_r0_body.P36 1640 PRE_first_tail_x6_r0_body.kappa36 PRE_first_tail_x6_r0_body.cx0_36 PRE_first_tail_x6_r0_body.cx1_36 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot36 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost36 (compact_a_eq PRE_first_tail_x6_r0_body.ckn036 PRE_first_tail_x6_r0_body.ckn136 PRE_first_tail_x6_r0_body.ckheap36 PRE_first_tail_x6_r0_body.ckpl36)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_36 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s361.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_36 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s361.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_36 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s361.ffi) = some PRE_first_tail_x6_r0_body.fxC_36
kernel_rfl PRE_first_tail_x6_r0_body.okrC_36 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s361.ffi) = some PRE_first_tail_x6_r0_body.krC_36
noncomputable def PRE_first_tail_x6_r0_body.fx0_36 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s363.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_36 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s363.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_36 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s363.ffi) = some PRE_first_tail_x6_r0_body.fx0_36
kernel_rfl PRE_first_tail_x6_r0_body.okr0_36 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s363.ffi) = some PRE_first_tail_x6_r0_body.kr0_36
noncomputable def PRE_first_tail_x6_r0_body.fx1_36 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s362.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_36 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s362.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_36 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s362.ffi) = some PRE_first_tail_x6_r0_body.fx1_36
kernel_rfl PRE_first_tail_x6_r0_body.okr1_36 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s362.ffi) = some PRE_first_tail_x6_r0_body.kr1_36
kernel_rfl PRE_first_tail_x6_r0_body.ff036 : PRE_first_tail_x6_r0_body.fx0_36 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_36 (PRE_first_tail_x6_r0_body.clo36.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_36.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff136 : PRE_first_tail_x6_r0_body.fx1_36 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_36 (PRE_first_tail_x6_r0_body.cwS36.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_36.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck36 : freedLB PRE_first_tail_x6_r0_body.kappa36 PRE_first_tail_x6_r0_body.cx0_36.mlx PRE_first_tail_x6_r0_body.fx0_36 PRE_first_tail_x6_r0_body.fx1_36 PRE_first_tail_x6_r0_body.clo36 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf036 : PRE_first_tail_x6_r0_body.kr0_36.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_36.flags (PRE_first_tail_x6_r0_body.clo36.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_36.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt036 : PRE_first_tail_x6_r0_body.kr0_36.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_36.targs (PRE_first_tail_x6_r0_body.clo36.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_36.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf136 : PRE_first_tail_x6_r0_body.kr1_36.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_36.flags (PRE_first_tail_x6_r0_body.cwS36.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_36.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt136 : PRE_first_tail_x6_r0_body.kr1_36.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_36.targs (PRE_first_tail_x6_r0_body.cwS36.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_36.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck36 : krecLB PRE_first_tail_x6_r0_body.kappa36 1640 PRE_first_tail_x6_r0_body.cx0_36.mlx PRE_first_tail_x6_r0_body.kr0_36 PRE_first_tail_x6_r0_body.kr1_36 PRE_first_tail_x6_r0_body.clo36 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn36 : Nat.ble 1622 1640 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge36 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s362.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s363.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR36 : pendRegB PRE_first_tail_x6_r0_body.kappa36 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe36 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s363.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s362.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift36 (clean : Conv.NClean (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P36.NL) (cl : SSt (· < 1640) PRE_first_tail_x6_r0_body.cx0_36.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_36.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_36.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_36.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s361.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_36.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P36 1640 PRE_first_tail_x6_r0_body.kappa36 PRE_first_tail_x6_r0_body.s363.ffi PRE_first_tail_x6_r0_body.s362.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift36 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue36, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp36 t ht),
    PRE_first_tail_x6_r0_body.cbridge36,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s363.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s362.ffi) (PRE_first_tail_x6_r0_body.cfoot36 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_36 PRE_first_tail_x6_r0_body.ofx1_36 hobjC PRE_first_tail_x6_r0_body.ff036 PRE_first_tail_x6_r0_body.ff136 PRE_first_tail_x6_r0_body.ffck36,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s363.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s362.ffi) (PRE_first_tail_x6_r0_body.cfoot36 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_36 PRE_first_tail_x6_r0_body.okr1_36 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn36) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf036 PRE_first_tail_x6_r0_body.fkt036 PRE_first_tail_x6_r0_body.fkf136 PRE_first_tail_x6_r0_body.fkt136 PRE_first_tail_x6_r0_body.fkck36,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh036 PRE_first_tail_x6_r0_body.cnh136 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe36) PRE_first_tail_x6_r0_body.cpendR36⟩

end Host.Load.Run.Tpl
end

section -- st36/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st36 0
host_stream_state PRE_first_tail_x6_r0_body.st36 1
host_stream_state PRE_first_tail_x6_r0_body.st36 2
host_stream_state PRE_first_tail_x6_r0_body.st36 3
host_stream_state PRE_first_tail_x6_r0_body.st36 4
host_stream_state PRE_first_tail_x6_r0_body.st36 5
end Host.Load.Run.Tpl
end

section -- Site36
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 36 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g36__g37` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s361`, the merged state `PRE_first_tail_x6_r0_body.s362`,
the site template `PRE_first_tail_x6_r0_body.st36` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s363`: the merge.
The footprint's facts are in `SiteF36`, the compaction's in `SiteC36`, `SiteK36`, `SiteNa36`, `SiteNb36`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso36 : PRE_first_tail_x6_r0_body.st36.s0 = { PRE_first_tail_x6_r0_body.s361 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs36 : List Frame := PRE_first_tail_x6_r0_body.s361.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_36 : PRE_first_tail_x6_r0_body.S361.tab.length = 1622
kernel_rfl PRE_first_tail_x6_r0_body.tab0_36 : PRE_first_tail_x6_r0_body.st36.S0.tab = PRE_first_tail_x6_r0_body.S361.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws36 : List Nat := [1591, 1592, 1593, 1594, 1595, 1596, 1597, 1598, 1599, 1600, 1601, 1602, 1603, 1604, 1605, 1606, 1607, 1608, 1609, 1610, 1611, 1612, 1613, 1614, 1615, 1616, 1617, 1618, 1619, 1620, 1621]
kernel_rfl PRE_first_tail_x6_r0_body.fresh36 : (PRE_first_tail_x6_r0_body.S361.tab.all fun e => PRE_first_tail_x6_r0_body.ws36.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S361.oracle.all fun q => PRE_first_tail_x6_r0_body.ws36.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab36 : PRE_first_tail_x6_r0_body.S362.tab = PRE_first_tail_x6_r0_body.S361.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws36
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen36 : PRE_first_tail_x6_r0_body.st36.S5.tab.length - PRE_first_tail_x6_r0_body.st36.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged36`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap36 : PRE_first_tail_x6_r0_body.s362.heap = PRE_first_tail_x6_r0_body.st36.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext36 : PRE_first_tail_x6_r0_body.s362.next = PRE_first_tail_x6_r0_body.st36.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl36 : PRE_first_tail_x6_r0_body.s362.ctl = PRE_first_tail_x6_r0_body.st36.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack36 : PRE_first_tail_x6_r0_body.s362.stack = PRE_first_tail_x6_r0_body.st36.s5.stack ++ PRE_first_tail_x6_r0_body.s361.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs36 : PRE_first_tail_x6_r0_body.s362.jobs = PRE_first_tail_x6_r0_body.st36.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi36 : PRE_first_tail_x6_r0_body.s362.ffi = PRE_first_tail_x6_r0_body.st36.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace36 : PRE_first_tail_x6_r0_body.s362.trace = PRE_first_tail_x6_r0_body.st36.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores36 : PRE_first_tail_x6_r0_body.s362.stores = PRE_first_tail_x6_r0_body.st36.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD36
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 36 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived36 : PRE_first_tail_x6_r0_body.nr36.map (fun r => nth? PRE_first_tail_x6_r0_body.st36.S5.tab r) =
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
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo36 : PRE_first_tail_x6_r0_body.nr36.all (Nat.ble 1622) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj36 : PRE_first_tail_x6_r0_body.cws36.all (fun c => !PRE_first_tail_x6_r0_body.ws36.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ36 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws36 PRE_first_tail_x6_r0_body.crs36 PRE_first_tail_x6_r0_body.ws36

end Host.Load.Run.Tpl
end

section -- st36/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st36`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st36.wrR : List (Nat × Nat) := [(2672393, 2672394), (2702877, 2702878), (2703422, 2703423), (2703678, 2703679)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st36.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st36.s5.heap PRE_first_tail_x6_r0_body.st36.wrR ++ freshOf PRE_first_tail_x6_r0_body.st36.s5.heap PRE_first_tail_x6_r0_body.st36.s0.next PRE_first_tail_x6_r0_body.st36.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st36.wr : List Nat := PRE_first_tail_x6_r0_body.st36.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st36.heapFoot : PRE_first_tail_x6_r0_body.st36.s5.heap = setAll PRE_first_tail_x6_r0_body.st36.s0.heap PRE_first_tail_x6_r0_body.st36.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st36.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st36.s0.next PRE_first_tail_x6_r0_body.st36.s5.next = true
theorem PRE_first_tail_x6_r0_body.st36.grows : PRE_first_tail_x6_r0_body.st36.s0.next ≤ PRE_first_tail_x6_r0_body.st36.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st36.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st36.wh : List Nat := [18904, 18917, 18923, 18924, 18925, 18926, 18927, 18928, 18929, 18930, 18931, 18932, 18933, 18934, 18935, 18936, 18937, 18938, 18939, 18940, 18941, 18942, 18943, 18944, 18945, 18946, 18947, 18948, 18949, 18950, 18951]
def PRE_first_tail_x6_r0_body.st36.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st36.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st36.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st36.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st36.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st36.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st36.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st36.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st36.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st36.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF36
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 36 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB36 : nodupT PRE_first_tail_x6_r0_body.st36.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup36 : PRE_first_tail_x6_r0_body.st36.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB36).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB36 : PRE_first_tail_x6_r0_body.st36.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound36 : ∀ b ∈ PRE_first_tail_x6_r0_body.st36.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB36 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr36 := PRE_first_tail_x6_r0_body.st36.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq36 : PRE_first_tail_x6_r0_body.st36.s5.trace = PRE_first_tail_x6_r0_body.trFr36 ++ PRE_first_tail_x6_r0_body.st36.s0.trace
theorem PRE_first_tail_x6_r0_body.trace36 : ∃ fr, PRE_first_tail_x6_r0_body.st36.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st36.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq36⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide36 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB36 : (PRE_first_tail_x6_r0_body.wide36.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st36.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix36 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide36, WFix Map.id (Present PRE_first_tail_x6_r0_body.st36.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB36 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL36
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 36 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s362`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO36 : PRE_first_tail_x6_r0_body.st36.S0.oracle = PRE_first_tail_x6_r0_body.st36.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B36 : PRE_first_tail_x6_r0_body.st36.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st36.s0.next || (PRE_first_tail_x6_r0_body.st36.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot36 : Conv.StageFoot PRE_first_tail_x6_r0_body.st36.wr PRE_first_tail_x6_r0_body.st36.s0 PRE_first_tail_x6_r0_body.st36.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st36.heapFoot PRE_first_tail_x6_r0_body.wrNodup36 PRE_first_tail_x6_r0_body.wrBound36 PRE_first_tail_x6_r0_body.wr0B36 PRE_first_tail_x6_r0_body.st36.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged36 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st36.F.S → PRE_first_tail_x6_r0_body.st36.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st36.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st36.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs36 PRE_first_tail_x6_r0_body.st36.wr PRE_first_tail_x6_r0_body.s361 PRE_first_tail_x6_r0_body.st36.s5 PRE_first_tail_x6_r0_body.st36.s0
      PRE_first_tail_x6_r0_body.st36.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st36.F FR W stk M ν K PRE_first_tail_x6_r0_body.s362 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso36 PRE_first_tail_x6_r0_body.stFoot36 PRE_first_tail_x6_r0_body.wrNodup36 PRE_first_tail_x6_r0_body.wrBound36 PRE_first_tail_x6_r0_body.trace36 PRE_first_tail_x6_r0_body.mheap36
    PRE_first_tail_x6_r0_body.mnext36 PRE_first_tail_x6_r0_body.mctl36 PRE_first_tail_x6_r0_body.mstack36 PRE_first_tail_x6_r0_body.mjobs36 PRE_first_tail_x6_r0_body.mffi36 PRE_first_tail_x6_r0_body.mtrace36 PRE_first_tail_x6_r0_body.mstores36 h

def PRE_first_tail_x6_r0_body.arrEl36_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE36_2665 : arrOf PRE_first_tail_x6_r0_body.s362 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl36_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA36_2665 : isArrB PRE_first_tail_x6_r0_body.s362 2665 = true
theorem PRE_first_tail_x6_r0_body.arr36_2665 : ∃ o, PRE_first_tail_x6_r0_body.s362.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl36_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE36_2665 PRE_first_tail_x6_r0_body.arrA36_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN36_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl36_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR36_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl36_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN36_2665

def PRE_first_tail_x6_r0_body.arrEl36_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE36_2673467 : arrOf PRE_first_tail_x6_r0_body.s362 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl36_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA36_2673467 : isArrB PRE_first_tail_x6_r0_body.s362 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr36_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s362.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl36_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE36_2673467 PRE_first_tail_x6_r0_body.arrA36_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN36_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl36_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR36_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl36_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN36_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k36 : isArrB PRE_first_tail_x6_r0_body.s362 4910 = false
theorem PRE_first_tail_x6_r0_body.keep36 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s362 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k36 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr36_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl36_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ36
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 36 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s361`, the merged
state `PRE_first_tail_x6_r0_body.s362`, the canonical state `PRE_first_tail_x6_r0_body.s363`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl36 : PRE_first_tail_x6_r0_body.pl36.all (Nat.ble PRE_first_tail_x6_r0_body.s361.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd36 : nodupT PRE_first_tail_x6_r0_body.pl36 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn136 : Nat.ble PRE_first_tail_x6_r0_body.s361.next 2704858 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst36 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s361.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn36 : PRE_first_tail_x6_r0_body.s363.next = PRE_first_tail_x6_r0_body.s361.next + PRE_first_tail_x6_r0_body.pl36.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn36 : PRE_first_tail_x6_r0_body.s362.next = 2704858
kernel_rfl PRE_first_tail_x6_r0_body.zgrow36 : Nat.ble PRE_first_tail_x6_r0_body.s363.next PRE_first_tail_x6_r0_body.s362.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh36 : PRE_first_tail_x6_r0_body.S361.tab.all (fun e => PRE_first_tail_x6_r0_body.cws36.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd36 : nodupT PRE_first_tail_x6_r0_body.cws36 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi36 : PRE_first_tail_x6_r0_body.nr36.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S362.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt36 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s361.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg36_2665 : PRE_first_tail_x6_r0_body.s363.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s363 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk36_2665 : (objOf PRE_first_tail_x6_r0_body.s363 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm36_2665 : PRE_first_tail_x6_r0_body.s362.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa36.obj (objOf PRE_first_tail_x6_r0_body.s363 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s362 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg36_2673467 : PRE_first_tail_x6_r0_body.s363.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s363 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk36_2673467 : (objOf PRE_first_tail_x6_r0_body.s363 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm36_2673467 : PRE_first_tail_x6_r0_body.s362.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa36.obj (objOf PRE_first_tail_x6_r0_body.s363 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s362 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw36_4910 : (PRE_first_tail_x6_r0_body.s363.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw36_2673472 : (PRE_first_tail_x6_r0_body.s363.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw36_2673473 : (PRE_first_tail_x6_r0_body.s363.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd36 : PRE_first_tail_x6_r0_body.cl36.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr36 : PRE_first_tail_x6_r0_body.st36.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s361.next || PRE_first_tail_x6_r0_body.cl36.contains b) = true
def PRE_first_tail_x6_r0_body.zl36 : List Nat := PRE_first_tail_x6_r0_body.cl36.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE36 : PRE_first_tail_x6_r0_body.zl36.map (fun a => PRE_first_tail_x6_r0_body.s362.heap.get (PRE_first_tail_x6_r0_body.kappa36.a a)) = PRE_first_tail_x6_r0_body.zl36.map (fun a => (PRE_first_tail_x6_r0_body.s363.heap.get a).map PRE_first_tail_x6_r0_body.kappa36.hobj)
theorem PRE_first_tail_x6_r0_body.zimg36 : HeapImg PRE_first_tail_x6_r0_body.kappa36 PRE_first_tail_x6_r0_body.s363 PRE_first_tail_x6_r0_body.s362 PRE_first_tail_x6_r0_body.zl36 := PRE_first_tail_x6_r0_body.zimgE36
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl36 : PRE_first_tail_x6_r0_body.s362.ctl = PRE_first_tail_x6_r0_body.kappa36.ctl PRE_first_tail_x6_r0_body.s363.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack36 : PRE_first_tail_x6_r0_body.s362.stack = PRE_first_tail_x6_r0_body.s363.stack.map PRE_first_tail_x6_r0_body.kappa36.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs36 : PRE_first_tail_x6_r0_body.s362.jobs = PRE_first_tail_x6_r0_body.s363.jobs.map PRE_first_tail_x6_r0_body.kappa36.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores36 : PRE_first_tail_x6_r0_body.s362.stores = PRE_first_tail_x6_r0_body.kappa36.stores PRE_first_tail_x6_r0_body.s363.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots36 : checkRootsSupp PRE_first_tail_x6_r0_body.s363 1640 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC36 : PRE_first_tail_x6_r0_body.S361.tab.length + PRE_first_tail_x6_r0_body.cws36.length = 1640
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap36 : PRE_first_tail_x6_r0_body.kappa36 = Conv.Map.compact PRE_first_tail_x6_r0_body.s361.next 2704858 PRE_first_tail_x6_r0_body.S361.tab.length PRE_first_tail_x6_r0_body.pl36 (PRE_first_tail_x6_r0_body.nr36.map NumV.ref) PRE_first_tail_x6_r0_body.kd36.big
  PRE_first_tail_x6_r0_body.kd36.region PRE_first_tail_x6_r0_body.kd36.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin36 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s363.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc36 : Conv.jcleanListB (⟨18927, 16016, 2703709, 1640⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s363 PRE_first_tail_x6_r0_body.cl36 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB36 : noBigRootsP (fun i => !Conv.oldBigB (⟨18927, 16016, 2703709, 1640⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s363.trace PRE_first_tail_x6_r0_body.s363 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm36 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15989 = true
theorem PRE_first_tail_x6_r0_body.cjcl36 (h : Conv.JClean (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s361) : Conv.JClean (⟨18927, 16016, 2703709, 1640⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s363 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle36)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap36 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd36 a ha)) PRE_first_tail_x6_r0_body.zjc36

end Host.Load.Run.Tpl
end

section -- st36/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st36.bodyLast from PRE_first_tail_x6_r0_body.st36.s4 to PRE_first_tail_x6_r0_body.st36.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st36.F PRE_first_tail_x6_r0_body.st36.s4).run PRE_first_tail_x6_r0_body.st36.S4 = some (PRE_first_tail_x6_r0_body.st36.s5, PRE_first_tail_x6_r0_body.st36.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st36.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st36.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st36.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st36.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st36/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st36.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st36.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st36.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st36.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st36.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st36.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st36.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st36.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st36.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st36.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st36.s0 PRE_first_tail_x6_r0_body.st36.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st36.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st36.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st36.s4 PRE_first_tail_x6_r0_body.st36.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st36/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st36.bodyK0F from PRE_first_tail_x6_r0_body.st36.s0 to PRE_first_tail_x6_r0_body.st36.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st36.F (PRE_first_tail_x6_r0_body.st36.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st36.ks 0).getD 0) PRE_first_tail_x6_r0_body.st36.s0 PRE_first_tail_x6_r0_body.st36.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st36.s1, PRE_first_tail_x6_r0_body.st36.S1)
theorem PRE_first_tail_x6_r0_body.st36.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st36.F (PRE_first_tail_x6_r0_body.st36.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st36.ks 0).getD 0) PRE_first_tail_x6_r0_body.st36.s0 PRE_first_tail_x6_r0_body.st36.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st36.s1, PRE_first_tail_x6_r0_body.st36.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st36.bodyOkLN_ok PRE_first_tail_x6_r0_body.st36.bodyK0F
end Host.Load.Run.Tpl
end

section -- st36/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st36.bodyK1F from PRE_first_tail_x6_r0_body.st36.s1 to PRE_first_tail_x6_r0_body.st36.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st36.F (PRE_first_tail_x6_r0_body.st36.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st36.ks 1).getD 0) PRE_first_tail_x6_r0_body.st36.s1 PRE_first_tail_x6_r0_body.st36.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st36.s2, PRE_first_tail_x6_r0_body.st36.S2)
theorem PRE_first_tail_x6_r0_body.st36.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st36.F (PRE_first_tail_x6_r0_body.st36.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st36.ks 1).getD 0) PRE_first_tail_x6_r0_body.st36.s1 PRE_first_tail_x6_r0_body.st36.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st36.s2, PRE_first_tail_x6_r0_body.st36.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st36.bodyOkLN_ok PRE_first_tail_x6_r0_body.st36.bodyK1F
end Host.Load.Run.Tpl
end

section -- st36/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st36.bodyK2F from PRE_first_tail_x6_r0_body.st36.s2 to PRE_first_tail_x6_r0_body.st36.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st36.F (PRE_first_tail_x6_r0_body.st36.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st36.ks 2).getD 0) PRE_first_tail_x6_r0_body.st36.s2 PRE_first_tail_x6_r0_body.st36.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st36.s3, PRE_first_tail_x6_r0_body.st36.S3)
theorem PRE_first_tail_x6_r0_body.st36.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st36.F (PRE_first_tail_x6_r0_body.st36.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st36.ks 2).getD 0) PRE_first_tail_x6_r0_body.st36.s2 PRE_first_tail_x6_r0_body.st36.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st36.s3, PRE_first_tail_x6_r0_body.st36.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st36.bodyOkLN_ok PRE_first_tail_x6_r0_body.st36.bodyK2F
end Host.Load.Run.Tpl
end

section -- st36/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st36.bodyK3F from PRE_first_tail_x6_r0_body.st36.s3 to PRE_first_tail_x6_r0_body.st36.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st36.F (PRE_first_tail_x6_r0_body.st36.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st36.ks 3).getD 0) PRE_first_tail_x6_r0_body.st36.s3 PRE_first_tail_x6_r0_body.st36.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st36.s4, PRE_first_tail_x6_r0_body.st36.S4)
theorem PRE_first_tail_x6_r0_body.st36.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st36.F (PRE_first_tail_x6_r0_body.st36.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st36.ks 3).getD 0) PRE_first_tail_x6_r0_body.st36.s3 PRE_first_tail_x6_r0_body.st36.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st36.s4, PRE_first_tail_x6_r0_body.st36.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st36.bodyOkLN_ok PRE_first_tail_x6_r0_body.st36.bodyK3F
end Host.Load.Run.Tpl
end

section -- st36/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st36.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st36.F (PRE_first_tail_x6_r0_body.st36.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st36.s0 PRE_first_tail_x6_r0_body.st36.S0 = some (PRE_first_tail_x6_r0_body.st36.s4, PRE_first_tail_x6_r0_body.st36.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st36.F (PRE_first_tail_x6_r0_body.st36.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st36.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st36.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st36.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st36.ks 3).getD 0) PRE_first_tail_x6_r0_body.st36.s0 PRE_first_tail_x6_r0_body.st36.s3 PRE_first_tail_x6_r0_body.st36.s4 PRE_first_tail_x6_r0_body.st36.S0 PRE_first_tail_x6_r0_body.st36.S3 PRE_first_tail_x6_r0_body.st36.S4 (runOk_trans PRE_first_tail_x6_r0_body.st36.F (PRE_first_tail_x6_r0_body.st36.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st36.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st36.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st36.ks 2).getD 0) PRE_first_tail_x6_r0_body.st36.s0 PRE_first_tail_x6_r0_body.st36.s2 PRE_first_tail_x6_r0_body.st36.s3 PRE_first_tail_x6_r0_body.st36.S0 PRE_first_tail_x6_r0_body.st36.S2 PRE_first_tail_x6_r0_body.st36.S3 (runOk_trans PRE_first_tail_x6_r0_body.st36.F (PRE_first_tail_x6_r0_body.st36.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st36.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st36.ks 1).getD 0) PRE_first_tail_x6_r0_body.st36.s0 PRE_first_tail_x6_r0_body.st36.s1 PRE_first_tail_x6_r0_body.st36.s2 PRE_first_tail_x6_r0_body.st36.S0 PRE_first_tail_x6_r0_body.st36.S1 PRE_first_tail_x6_r0_body.st36.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st36.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st36.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st36.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st36.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st36.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st36.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st36.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st36.F (PRE_first_tail_x6_r0_body.st36.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st36.s0
  S0 := PRE_first_tail_x6_r0_body.st36.S0
  s1 := PRE_first_tail_x6_r0_body.st36.s4
  S1 := PRE_first_tail_x6_r0_body.st36.S4
  s2 := PRE_first_tail_x6_r0_body.st36.s5
  S2 := PRE_first_tail_x6_r0_body.st36.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st36.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st36.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st36.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st36.bodyHalt
  last := PRE_first_tail_x6_r0_body.st36.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st36.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC37
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 37 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s371` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa37` into the merged state
`PRE_first_tail_x6_r0_body.s370`. -/

def PRE_first_tail_x6_r0_body.pl37 : List Nat := []
def PRE_first_tail_x6_r0_body.nr37 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd37 : RData :=
  ⟨2704199, 2704201, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18940, 18940, 16029, 16029, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa37 : Map :=
  Conv.Map.compact 2704199 2704201 1661 PRE_first_tail_x6_r0_body.pl37 (PRE_first_tail_x6_r0_body.nr37.map NumV.ref) PRE_first_tail_x6_r0_body.kd37.big
    PRE_first_tail_x6_r0_body.kd37.region PRE_first_tail_x6_r0_body.kd37.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws37 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs37 : List SymE := PRE_first_tail_x6_r0_body.nr37.map fun r => (nth? PRE_first_tail_x6_r0_body.S370.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta37 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws37 PRE_first_tail_x6_r0_body.crs37
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB37 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab37 : PRE_first_tail_x6_r0_body.S371.tab = PRE_first_tail_x6_r0_body.S369.tab ++ PRE_first_tail_x6_r0_body.cws37.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace37 : PRE_first_tail_x6_r0_body.s371.trace = PRE_first_tail_x6_r0_body.s369.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext37 : PRE_first_tail_x6_r0_body.s371.next = 2704199
kernel_rfl PRE_first_tail_x6_r0_body.ccounters37 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx.nnext) = (18940, 16029)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue37 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s370.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa37.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp37 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx.tokens.all (bSN 1661) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean37 : Conv.cleanListB 18940 131072 (fun r => Nat.ble 75760 r) PRE_first_tail_x6_r0_body.s371
    (PRE_first_tail_x6_r0_body.wrB37 ++ (List.range 0).map (2704199 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs37 : bigsOutB 18940 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK37
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl37`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl37 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo37 : List Nat := []
def PRE_first_tail_x6_r0_body.cln37 : List Nat := []
def PRE_first_tail_x6_r0_body.cli37 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap37 : PRE_first_tail_x6_r0_body.s371.heap = Stage.setAll PRE_first_tail_x6_r0_body.s369.heap (PRE_first_tail_x6_r0_body.cl37.filterMap fun a => (PRE_first_tail_x6_r0_body.s371.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe37 : Nat.ble PRE_first_tail_x6_r0_body.s369.next PRE_first_tail_x6_r0_body.s371.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP37 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s369 PRE_first_tail_x6_r0_body.s371 PRE_first_tail_x6_r0_body.cl37 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp37 : Conv.suppListB PRE_first_tail_x6_r0_body.s371 1661 PRE_first_tail_x6_r0_body.cl37 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound37 : Conv.boundListB PRE_first_tail_x6_r0_body.s371 PRE_first_tail_x6_r0_body.cl37 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK37 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln37.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK37 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo37.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK37 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli37.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst37 : Conv.sstListB 1661 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx PRE_first_tail_x6_r0_body.cln37 PRE_first_tail_x6_r0_body.clo37 PRE_first_tail_x6_r0_body.cli37 = true

end Host.Load.Run.Tpl
end

section -- SiteCl37
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA37 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo37.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd37 : (PRE_first_tail_x6_r0_body.clo37 ++ PRE_first_tail_x6_r0_body.cln37 ++ PRE_first_tail_x6_r0_body.cli37).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle37 : Conv.Cnt.leB (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck37 : Conv.ncleanListB (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx PRE_first_tail_x6_r0_body.clo37 PRE_first_tail_x6_r0_body.cln37 PRE_first_tail_x6_r0_body.cli37 = true
theorem PRE_first_tail_x6_r0_body.cncl37 (h : Conv.NClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx) : Conv.NClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle37 PRE_first_tail_x6_r0_body.ckA37 PRE_first_tail_x6_r0_body.cobjsK37 PRE_first_tail_x6_r0_body.cnodesK37 PRE_first_tail_x6_r0_body.citemsK37 PRE_first_tail_x6_r0_body.cbd37 PRE_first_tail_x6_r0_body.cck37

end Host.Load.Run.Tpl
end

section -- SiteS37
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 37 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc37 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P37 : LoadP := PRE_first_tail_x6_r0_body.Pc37.raise 16029
kernel_rfl PRE_first_tail_x6_r0_body.craise37 : Nat.ble PRE_first_tail_x6_r0_body.Pc37.N0 16029 = true
theorem PRE_first_tail_x6_r0_body.raised37 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc37 PRE_first_tail_x6_r0_body.P37 :=
  .inr ⟨16029, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise37, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_37 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_37 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s370.ffi)
def PRE_first_tail_x6_r0_body.khinv37 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv37 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS37 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS37 : List Nat := List.range' 16029 0
def PRE_first_tail_x6_r0_body.ciS37 : List Nat := [] ++ List.range' 16029 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh037 : PRE_first_tail_x6_r0_body.kd37.nh0 = PRE_first_tail_x6_r0_body.cx0_37.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh137 : PRE_first_tail_x6_r0_body.kd37.nh1 = PRE_first_tail_x6_r0_body.cx1_37.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn037 : PRE_first_tail_x6_r0_body.kd37.nn0 = PRE_first_tail_x6_r0_body.cx0_37.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn137 : PRE_first_tail_x6_r0_body.kd37.nn1 = PRE_first_tail_x6_r0_body.cx1_37.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo37 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P37.lo && Nat.ble PRE_first_tail_x6_r0_body.P37.lo PRE_first_tail_x6_r0_body.cx0_37.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P37.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P37.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt37 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_37.mlx.next PRE_first_tail_x6_r0_body.cx1_37.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_37.mlx.nnext PRE_first_tail_x6_r0_body.cx1_37.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband37 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P37.NL && Nat.ble PRE_first_tail_x6_r0_body.P37.NL PRE_first_tail_x6_r0_body.P37.N0 && Nat.ble PRE_first_tail_x6_r0_body.P37.N0 PRE_first_tail_x6_r0_body.cx0_37.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow37 : PRE_first_tail_x6_r0_body.kd37.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren37 : checkRenG PRE_first_tail_x6_r0_body.kd37.hnd PRE_first_tail_x6_r0_body.khinv37 (phB PRE_first_tail_x6_r0_body.cx0_37.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband37 : PRE_first_tail_x6_r0_body.kd37.checkBand PRE_first_tail_x6_r0_body.P37.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos37 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd37.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren37 : checkRenG PRE_first_tail_x6_r0_body.kd37.node PRE_first_tail_x6_r0_body.kninv37 (pnB PRE_first_tail_x6_r0_body.cx0_37.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow37 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd37.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P37.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd37.nodeF j) PRE_first_tail_x6_r0_body.cx1_37.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a37 : PRE_first_tail_x6_r0_body.cx0_37.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b37 : PRE_first_tail_x6_r0_body.cx0_37.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok137 : PRE_first_tail_x6_r0_body.cx1_37.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend37 : PRE_first_tail_x6_r0_body.cx1_37.mlx.pending = PRE_first_tail_x6_r0_body.cx0_37.mlx.pending.map PRE_first_tail_x6_r0_body.kappa37.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh37 : PRE_first_tail_x6_r0_body.cx1_37.mlx.errh = PRE_first_tail_x6_r0_body.cx0_37.mlx.errh.map PRE_first_tail_x6_r0_body.kappa37.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles37 : PRE_first_tail_x6_r0_body.cx1_37.mlx.files = PRE_first_tail_x6_r0_body.cx0_37.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch37 : PRE_first_tail_x6_r0_body.cx1_37.mlx.arch = PRE_first_tail_x6_r0_body.cx0_37.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes37 : PRE_first_tail_x6_r0_body.cx1_37.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_37.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired37 : PRE_first_tail_x6_r0_body.cx1_37.mlx.wired = PRE_first_tail_x6_r0_body.cx0_37.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost37 : PRE_first_tail_x6_r0_body.cx1_37.host = PRE_first_tail_x6_r0_body.cx0_37.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd37`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn037 : PRE_first_tail_x6_r0_body.kd37.n0 = 2704199
kernel_rfl PRE_first_tail_x6_r0_body.ckn137 : PRE_first_tail_x6_r0_body.kd37.n1 = 2704201
kernel_rfl PRE_first_tail_x6_r0_body.ckheap37 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd37.heap).all (fun x => Nat.ble 2704199 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl37 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd37.heap.get (2704199 + j) = nth? PRE_first_tail_x6_r0_body.pl37 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja37 : Nat.ble 2704199 2704199 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn37 : Nat.ble 1661 1661 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD37 : Nat.ble 2704199 PRE_first_tail_x6_r0_body.kd37.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn37 : Nat.ble 18940 PRE_first_tail_x6_r0_body.kd37.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn37 : Nat.ble 16029 PRE_first_tail_x6_r0_body.kd37.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb37 : Nat.ble 18940 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap37 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd37.heap).all (Nat.ble (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd37 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd37.hnd).all (Nat.ble (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode37 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd37.node).all (Nat.ble (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix37 : Conv.FixOld (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa37 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja37) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn37) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD37) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn37) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn37) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb37) PRE_first_tail_x6_r0_body.fheap37 PRE_first_tail_x6_r0_body.fhnd37 PRE_first_tail_x6_r0_body.fnode37
kernel_rfl PRE_first_tail_x6_r0_body.fcxn37 : (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn37 : (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle037 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_37.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_37.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk37 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd37.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A37 : PRE_first_tail_x6_r0_body.cx1_37.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS37.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_37.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O37 : PRE_first_tail_x6_r0_body.cx1_37.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS37.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_37.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N37 : PRE_first_tail_x6_r0_body.cx1_37.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS37.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_37.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I37 : PRE_first_tail_x6_r0_body.cx1_37.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS37.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_37.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd37 : (PRE_first_tail_x6_r0_body.clo37 ++ PRE_first_tail_x6_r0_body.cln37 ++ PRE_first_tail_x6_r0_body.cli37 ++ PRE_first_tail_x6_r0_body.cwS37 ++ PRE_first_tail_x6_r0_body.cnS37 ++ PRE_first_tail_x6_r0_body.ciS37).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW37 : PRE_first_tail_x6_r0_body.cwS37.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo37.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI37 : PRE_first_tail_x6_r0_body.ciS37.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli37.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN37 : PRE_first_tail_x6_r0_body.cnS37.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF37 : PRE_first_tail_x6_r0_body.cln37.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh37 : PRE_first_tail_x6_r0_body.clo37.all (handleOK PRE_first_tail_x6_r0_body.kappa37 PRE_first_tail_x6_r0_body.P37.lo PRE_first_tail_x6_r0_body.cx0_37.mlx PRE_first_tail_x6_r0_body.cx1_37.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo37 : PRE_first_tail_x6_r0_body.clo37.map (fun h => PRE_first_tail_x6_r0_body.cx1_37.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa37.handle h)) = PRE_first_tail_x6_r0_body.clo37.map (fun h => (PRE_first_tail_x6_r0_body.cx0_37.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa37.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok37 : PRE_first_tail_x6_r0_body.clo37.all (objOK PRE_first_tail_x6_r0_body.kappa37 PRE_first_tail_x6_r0_body.P37.NL PRE_first_tail_x6_r0_body.cx0_37.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd37 : PRE_first_tail_x6_r0_body.cln37.all (nodeOKF PRE_first_tail_x6_r0_body.kappa37 PRE_first_tail_x6_r0_body.P37 PRE_first_tail_x6_r0_body.cx0_37.mlx PRE_first_tail_x6_r0_body.cx1_37.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp37 : ((PRE_first_tail_x6_r0_body.cln37.filter (fullB PRE_first_tail_x6_r0_body.P37))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_37.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa37.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln37.filter (fullB PRE_first_tail_x6_r0_body.P37))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_37.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa37.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI37 : incrB PRE_first_tail_x6_r0_body.kd37.nodeF (List.range' 16029 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK37 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd37.node).all (fun k => Nat.ble 16029 k && Nat.blt k 16029) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL37 : (PRE_first_tail_x6_r0_body.cln37.filter (Nat.ble PRE_first_tail_x6_r0_body.P37.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd37.nodeF i) && (Nat.blt i 16029 || Nat.ble PRE_first_tail_x6_r0_body.kd37.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord37 : (PRE_first_tail_x6_r0_body.cln37.filter (Nat.ble PRE_first_tail_x6_r0_body.P37.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd37.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd37.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd37.nodeF j) (PRE_first_tail_x6_r0_body.kd37.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow37 PRE_first_tail_x6_r0_body.cnn137 PRE_first_tail_x6_r0_body.fnordI37 PRE_first_tail_x6_r0_body.fnordK37 PRE_first_tail_x6_r0_body.fnordL37
kernel_rfl PRE_first_tail_x6_r0_body.fi37 : PRE_first_tail_x6_r0_body.cli37.all (pnB PRE_first_tail_x6_r0_body.cx0_37.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii37 : PRE_first_tail_x6_r0_body.cli37.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_37.mlx.items.get (PRE_first_tail_x6_r0_body.kappa37.node k) = (PRE_first_tail_x6_r0_body.cx0_37.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa37.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot37 (clean : Conv.NClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P37.NL) (cl : SSt (· < 1661) PRE_first_tail_x6_r0_body.cx0_37.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P37 1661 PRE_first_tail_x6_r0_body.kappa37 PRE_first_tail_x6_r0_body.kd37 PRE_first_tail_x6_r0_body.khinv37 PRE_first_tail_x6_r0_body.kninv37 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx PRE_first_tail_x6_r0_body.cx0_37.mlx PRE_first_tail_x6_r0_body.cx1_37.mlx (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo37 PRE_first_tail_x6_r0_body.cln37 PRE_first_tail_x6_r0_body.cli37 PRE_first_tail_x6_r0_body.cwS37 PRE_first_tail_x6_r0_body.cnS37 PRE_first_tail_x6_r0_body.ciS37 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh037, PRE_first_tail_x6_r0_body.cnh137, PRE_first_tail_x6_r0_body.cnn037, PRE_first_tail_x6_r0_body.cnn137, PRE_first_tail_x6_r0_body.cplo37, PRE_first_tail_x6_r0_body.ccnt37, PRE_first_tail_x6_r0_body.cnband37, PRE_first_tail_x6_r0_body.chbelow37, PRE_first_tail_x6_r0_body.chren37, PRE_first_tail_x6_r0_body.cband37, PRE_first_tail_x6_r0_body.cnh1pos37, PRE_first_tail_x6_r0_body.cnren37, PRE_first_tail_x6_r0_body.cnlow37, PRE_first_tail_x6_r0_body.cabs0a37, PRE_first_tail_x6_r0_body.cabs0b37, PRE_first_tail_x6_r0_body.ctok137, PRE_first_tail_x6_r0_body.cpend37, PRE_first_tail_x6_r0_body.cerrh37, PRE_first_tail_x6_r0_body.cfiles37, PRE_first_tail_x6_r0_body.carch37, PRE_first_tail_x6_r0_body.csizes37, PRE_first_tail_x6_r0_body.cwired37, PRE_first_tail_x6_r0_body.cfix37, clean, PRE_first_tail_x6_r0_body.fcxn37, PRE_first_tail_x6_r0_body.fcnn37, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle037, PRE_first_tail_x6_r0_body.fnk37, PRE_first_tail_x6_r0_body.ckA37, PRE_first_tail_x6_r0_body.cobjsK37, PRE_first_tail_x6_r0_body.cnodesK37, PRE_first_tail_x6_r0_body.citemsK37, PRE_first_tail_x6_r0_body.f1A37, PRE_first_tail_x6_r0_body.f1O37, PRE_first_tail_x6_r0_body.f1N37, PRE_first_tail_x6_r0_body.f1I37, PRE_first_tail_x6_r0_body.fbd37, PRE_first_tail_x6_r0_body.fincW37, PRE_first_tail_x6_r0_body.fincI37, PRE_first_tail_x6_r0_body.fincN37, PRE_first_tail_x6_r0_body.flnF37, PRE_first_tail_x6_r0_body.fh37, PRE_first_tail_x6_r0_body.fo37, PRE_first_tail_x6_r0_body.fok37, PRE_first_tail_x6_r0_body.fnd37, PRE_first_tail_x6_r0_body.fp37, PRE_first_tail_x6_r0_body.fnord37, PRE_first_tail_x6_r0_body.fi37, PRE_first_tail_x6_r0_body.fii37⟩
theorem PRE_first_tail_x6_r0_body.cnshift37 (clean : Conv.NClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P37.NL) (cl : SSt (· < 1661) PRE_first_tail_x6_r0_body.cx0_37.mlx) : NShift PRE_first_tail_x6_r0_body.P37 1661 PRE_first_tail_x6_r0_body.kappa37 PRE_first_tail_x6_r0_body.cx0_37 PRE_first_tail_x6_r0_body.cx1_37 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot37 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost37 (compact_a_eq PRE_first_tail_x6_r0_body.ckn037 PRE_first_tail_x6_r0_body.ckn137 PRE_first_tail_x6_r0_body.ckheap37 PRE_first_tail_x6_r0_body.ckpl37)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_37 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s369.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_37 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s369.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_37 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s369.ffi) = some PRE_first_tail_x6_r0_body.fxC_37
kernel_rfl PRE_first_tail_x6_r0_body.okrC_37 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s369.ffi) = some PRE_first_tail_x6_r0_body.krC_37
noncomputable def PRE_first_tail_x6_r0_body.fx0_37 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s371.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_37 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s371.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_37 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s371.ffi) = some PRE_first_tail_x6_r0_body.fx0_37
kernel_rfl PRE_first_tail_x6_r0_body.okr0_37 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s371.ffi) = some PRE_first_tail_x6_r0_body.kr0_37
noncomputable def PRE_first_tail_x6_r0_body.fx1_37 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s370.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_37 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s370.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_37 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s370.ffi) = some PRE_first_tail_x6_r0_body.fx1_37
kernel_rfl PRE_first_tail_x6_r0_body.okr1_37 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s370.ffi) = some PRE_first_tail_x6_r0_body.kr1_37
kernel_rfl PRE_first_tail_x6_r0_body.ff037 : PRE_first_tail_x6_r0_body.fx0_37 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_37 (PRE_first_tail_x6_r0_body.clo37.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_37.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff137 : PRE_first_tail_x6_r0_body.fx1_37 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_37 (PRE_first_tail_x6_r0_body.cwS37.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_37.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck37 : freedLB PRE_first_tail_x6_r0_body.kappa37 PRE_first_tail_x6_r0_body.cx0_37.mlx PRE_first_tail_x6_r0_body.fx0_37 PRE_first_tail_x6_r0_body.fx1_37 PRE_first_tail_x6_r0_body.clo37 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf037 : PRE_first_tail_x6_r0_body.kr0_37.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_37.flags (PRE_first_tail_x6_r0_body.clo37.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_37.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt037 : PRE_first_tail_x6_r0_body.kr0_37.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_37.targs (PRE_first_tail_x6_r0_body.clo37.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_37.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf137 : PRE_first_tail_x6_r0_body.kr1_37.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_37.flags (PRE_first_tail_x6_r0_body.cwS37.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_37.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt137 : PRE_first_tail_x6_r0_body.kr1_37.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_37.targs (PRE_first_tail_x6_r0_body.cwS37.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_37.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck37 : krecLB PRE_first_tail_x6_r0_body.kappa37 1661 PRE_first_tail_x6_r0_body.cx0_37.mlx PRE_first_tail_x6_r0_body.kr0_37 PRE_first_tail_x6_r0_body.kr1_37 PRE_first_tail_x6_r0_body.clo37 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn37 : Nat.ble 1661 1661 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge37 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s370.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s371.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR37 : pendRegB PRE_first_tail_x6_r0_body.kappa37 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe37 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s371.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s370.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift37 (clean : Conv.NClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P37.NL) (cl : SSt (· < 1661) PRE_first_tail_x6_r0_body.cx0_37.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_37.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_37.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_37.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s369.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_37.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P37 1661 PRE_first_tail_x6_r0_body.kappa37 PRE_first_tail_x6_r0_body.s371.ffi PRE_first_tail_x6_r0_body.s370.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift37 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue37, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp37 t ht),
    PRE_first_tail_x6_r0_body.cbridge37,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s371.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s370.ffi) (PRE_first_tail_x6_r0_body.cfoot37 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_37 PRE_first_tail_x6_r0_body.ofx1_37 hobjC PRE_first_tail_x6_r0_body.ff037 PRE_first_tail_x6_r0_body.ff137 PRE_first_tail_x6_r0_body.ffck37,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s371.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s370.ffi) (PRE_first_tail_x6_r0_body.cfoot37 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_37 PRE_first_tail_x6_r0_body.okr1_37 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn37) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf037 PRE_first_tail_x6_r0_body.fkt037 PRE_first_tail_x6_r0_body.fkf137 PRE_first_tail_x6_r0_body.fkt137 PRE_first_tail_x6_r0_body.fkck37,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh037 PRE_first_tail_x6_r0_body.cnh137 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe37) PRE_first_tail_x6_r0_body.cpendR37⟩

end Host.Load.Run.Tpl
end

section -- st37/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st37 0
host_stream_state PRE_first_tail_x6_r0_body.st37 1
host_stream_state PRE_first_tail_x6_r0_body.st37 2
end Host.Load.Run.Tpl
end

section -- Site37
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 37 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g37__g38` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s369`, the merged state `PRE_first_tail_x6_r0_body.s370`,
the site template `PRE_first_tail_x6_r0_body.st37` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s371`: the merge.
The footprint's facts are in `SiteF37`, the compaction's in `SiteC37`, `SiteK37`, `SiteNa37`, `SiteNb37`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso37 : PRE_first_tail_x6_r0_body.st37.s0 = { PRE_first_tail_x6_r0_body.s369 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs37 : List Frame := PRE_first_tail_x6_r0_body.s369.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_37 : PRE_first_tail_x6_r0_body.S369.tab.length = 1661
kernel_rfl PRE_first_tail_x6_r0_body.tab0_37 : PRE_first_tail_x6_r0_body.st37.S0.tab = PRE_first_tail_x6_r0_body.S369.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws37 : List Nat := [1640, 1641]
kernel_rfl PRE_first_tail_x6_r0_body.fresh37 : (PRE_first_tail_x6_r0_body.S369.tab.all fun e => PRE_first_tail_x6_r0_body.ws37.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S369.oracle.all fun q => PRE_first_tail_x6_r0_body.ws37.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab37 : PRE_first_tail_x6_r0_body.S370.tab = PRE_first_tail_x6_r0_body.S369.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws37
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen37 : PRE_first_tail_x6_r0_body.st37.S2.tab.length - PRE_first_tail_x6_r0_body.st37.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged37`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap37 : PRE_first_tail_x6_r0_body.s370.heap = PRE_first_tail_x6_r0_body.st37.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext37 : PRE_first_tail_x6_r0_body.s370.next = PRE_first_tail_x6_r0_body.st37.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl37 : PRE_first_tail_x6_r0_body.s370.ctl = PRE_first_tail_x6_r0_body.st37.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack37 : PRE_first_tail_x6_r0_body.s370.stack = PRE_first_tail_x6_r0_body.st37.s2.stack ++ PRE_first_tail_x6_r0_body.s369.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs37 : PRE_first_tail_x6_r0_body.s370.jobs = PRE_first_tail_x6_r0_body.st37.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi37 : PRE_first_tail_x6_r0_body.s370.ffi = PRE_first_tail_x6_r0_body.st37.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace37 : PRE_first_tail_x6_r0_body.s370.trace = PRE_first_tail_x6_r0_body.st37.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores37 : PRE_first_tail_x6_r0_body.s370.stores = PRE_first_tail_x6_r0_body.st37.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD37
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 37 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived37 : PRE_first_tail_x6_r0_body.nr37.map (fun r => nth? PRE_first_tail_x6_r0_body.st37.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo37 : PRE_first_tail_x6_r0_body.nr37.all (Nat.ble 1661) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj37 : PRE_first_tail_x6_r0_body.cws37.all (fun c => !PRE_first_tail_x6_r0_body.ws37.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ37 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws37 PRE_first_tail_x6_r0_body.crs37 PRE_first_tail_x6_r0_body.ws37

end Host.Load.Run.Tpl
end

section -- st37/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st37`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st37.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st37.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st37.s2.heap PRE_first_tail_x6_r0_body.st37.wrR ++ freshOf PRE_first_tail_x6_r0_body.st37.s2.heap PRE_first_tail_x6_r0_body.st37.s0.next PRE_first_tail_x6_r0_body.st37.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st37.wr : List Nat := PRE_first_tail_x6_r0_body.st37.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st37.heapFoot : PRE_first_tail_x6_r0_body.st37.s2.heap = setAll PRE_first_tail_x6_r0_body.st37.s0.heap PRE_first_tail_x6_r0_body.st37.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st37.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st37.s0.next PRE_first_tail_x6_r0_body.st37.s2.next = true
theorem PRE_first_tail_x6_r0_body.st37.grows : PRE_first_tail_x6_r0_body.st37.s0.next ≤ PRE_first_tail_x6_r0_body.st37.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st37.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st37.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st37.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st37.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st37.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st37.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st37.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st37.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st37.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st37.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st37.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st37.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF37
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 37 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB37 : nodupT PRE_first_tail_x6_r0_body.st37.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup37 : PRE_first_tail_x6_r0_body.st37.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB37).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB37 : PRE_first_tail_x6_r0_body.st37.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound37 : ∀ b ∈ PRE_first_tail_x6_r0_body.st37.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB37 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr37 := PRE_first_tail_x6_r0_body.st37.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq37 : PRE_first_tail_x6_r0_body.st37.s2.trace = PRE_first_tail_x6_r0_body.trFr37 ++ PRE_first_tail_x6_r0_body.st37.s0.trace
theorem PRE_first_tail_x6_r0_body.trace37 : ∃ fr, PRE_first_tail_x6_r0_body.st37.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st37.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq37⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide37 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB37 : (PRE_first_tail_x6_r0_body.wide37.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st37.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix37 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide37, WFix Map.id (Present PRE_first_tail_x6_r0_body.st37.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB37 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL37
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 37 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s370`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO37 : PRE_first_tail_x6_r0_body.st37.S0.oracle = PRE_first_tail_x6_r0_body.st37.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B37 : PRE_first_tail_x6_r0_body.st37.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st37.s0.next || (PRE_first_tail_x6_r0_body.st37.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot37 : Conv.StageFoot PRE_first_tail_x6_r0_body.st37.wr PRE_first_tail_x6_r0_body.st37.s0 PRE_first_tail_x6_r0_body.st37.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st37.heapFoot PRE_first_tail_x6_r0_body.wrNodup37 PRE_first_tail_x6_r0_body.wrBound37 PRE_first_tail_x6_r0_body.wr0B37 PRE_first_tail_x6_r0_body.st37.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged37 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st37.F.S → PRE_first_tail_x6_r0_body.st37.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st37.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st37.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs37 PRE_first_tail_x6_r0_body.st37.wr PRE_first_tail_x6_r0_body.s369 PRE_first_tail_x6_r0_body.st37.s2 PRE_first_tail_x6_r0_body.st37.s0
      PRE_first_tail_x6_r0_body.st37.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st37.F FR W stk M ν K PRE_first_tail_x6_r0_body.s370 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso37 PRE_first_tail_x6_r0_body.stFoot37 PRE_first_tail_x6_r0_body.wrNodup37 PRE_first_tail_x6_r0_body.wrBound37 PRE_first_tail_x6_r0_body.trace37 PRE_first_tail_x6_r0_body.mheap37
    PRE_first_tail_x6_r0_body.mnext37 PRE_first_tail_x6_r0_body.mctl37 PRE_first_tail_x6_r0_body.mstack37 PRE_first_tail_x6_r0_body.mjobs37 PRE_first_tail_x6_r0_body.mffi37 PRE_first_tail_x6_r0_body.mtrace37 PRE_first_tail_x6_r0_body.mstores37 h

def PRE_first_tail_x6_r0_body.arrEl37_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE37_2665 : arrOf PRE_first_tail_x6_r0_body.s370 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl37_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA37_2665 : isArrB PRE_first_tail_x6_r0_body.s370 2665 = true
theorem PRE_first_tail_x6_r0_body.arr37_2665 : ∃ o, PRE_first_tail_x6_r0_body.s370.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl37_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE37_2665 PRE_first_tail_x6_r0_body.arrA37_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN37_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl37_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR37_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl37_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN37_2665

def PRE_first_tail_x6_r0_body.arrEl37_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE37_2673467 : arrOf PRE_first_tail_x6_r0_body.s370 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl37_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA37_2673467 : isArrB PRE_first_tail_x6_r0_body.s370 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr37_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s370.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl37_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE37_2673467 PRE_first_tail_x6_r0_body.arrA37_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN37_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl37_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR37_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl37_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN37_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k37 : isArrB PRE_first_tail_x6_r0_body.s370 4910 = false
theorem PRE_first_tail_x6_r0_body.keep37 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s370 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k37 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr37_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl37_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ37
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 37 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s369`, the merged
state `PRE_first_tail_x6_r0_body.s370`, the canonical state `PRE_first_tail_x6_r0_body.s371`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl37 : PRE_first_tail_x6_r0_body.pl37.all (Nat.ble PRE_first_tail_x6_r0_body.s369.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd37 : nodupT PRE_first_tail_x6_r0_body.pl37 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn137 : Nat.ble PRE_first_tail_x6_r0_body.s369.next 2704201 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst37 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s369.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn37 : PRE_first_tail_x6_r0_body.s371.next = PRE_first_tail_x6_r0_body.s369.next + PRE_first_tail_x6_r0_body.pl37.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn37 : PRE_first_tail_x6_r0_body.s370.next = 2704201
kernel_rfl PRE_first_tail_x6_r0_body.zgrow37 : Nat.ble PRE_first_tail_x6_r0_body.s371.next PRE_first_tail_x6_r0_body.s370.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh37 : PRE_first_tail_x6_r0_body.S369.tab.all (fun e => PRE_first_tail_x6_r0_body.cws37.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd37 : nodupT PRE_first_tail_x6_r0_body.cws37 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi37 : PRE_first_tail_x6_r0_body.nr37.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S370.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt37 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s369.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg37_2665 : PRE_first_tail_x6_r0_body.s371.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s371 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk37_2665 : (objOf PRE_first_tail_x6_r0_body.s371 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm37_2665 : PRE_first_tail_x6_r0_body.s370.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa37.obj (objOf PRE_first_tail_x6_r0_body.s371 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s370 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg37_2673467 : PRE_first_tail_x6_r0_body.s371.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s371 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk37_2673467 : (objOf PRE_first_tail_x6_r0_body.s371 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm37_2673467 : PRE_first_tail_x6_r0_body.s370.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa37.obj (objOf PRE_first_tail_x6_r0_body.s371 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s370 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw37_4910 : (PRE_first_tail_x6_r0_body.s371.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw37_2673472 : (PRE_first_tail_x6_r0_body.s371.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw37_2673473 : (PRE_first_tail_x6_r0_body.s371.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd37 : PRE_first_tail_x6_r0_body.cl37.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr37 : PRE_first_tail_x6_r0_body.st37.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s369.next || PRE_first_tail_x6_r0_body.cl37.contains b) = true
def PRE_first_tail_x6_r0_body.zl37 : List Nat := PRE_first_tail_x6_r0_body.cl37.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE37 : PRE_first_tail_x6_r0_body.zl37.map (fun a => PRE_first_tail_x6_r0_body.s370.heap.get (PRE_first_tail_x6_r0_body.kappa37.a a)) = PRE_first_tail_x6_r0_body.zl37.map (fun a => (PRE_first_tail_x6_r0_body.s371.heap.get a).map PRE_first_tail_x6_r0_body.kappa37.hobj)
theorem PRE_first_tail_x6_r0_body.zimg37 : HeapImg PRE_first_tail_x6_r0_body.kappa37 PRE_first_tail_x6_r0_body.s371 PRE_first_tail_x6_r0_body.s370 PRE_first_tail_x6_r0_body.zl37 := PRE_first_tail_x6_r0_body.zimgE37
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl37 : PRE_first_tail_x6_r0_body.s370.ctl = PRE_first_tail_x6_r0_body.kappa37.ctl PRE_first_tail_x6_r0_body.s371.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack37 : PRE_first_tail_x6_r0_body.s370.stack = PRE_first_tail_x6_r0_body.s371.stack.map PRE_first_tail_x6_r0_body.kappa37.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs37 : PRE_first_tail_x6_r0_body.s370.jobs = PRE_first_tail_x6_r0_body.s371.jobs.map PRE_first_tail_x6_r0_body.kappa37.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores37 : PRE_first_tail_x6_r0_body.s370.stores = PRE_first_tail_x6_r0_body.kappa37.stores PRE_first_tail_x6_r0_body.s371.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots37 : checkRootsSupp PRE_first_tail_x6_r0_body.s371 1661 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC37 : PRE_first_tail_x6_r0_body.S369.tab.length + PRE_first_tail_x6_r0_body.cws37.length = 1661
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap37 : PRE_first_tail_x6_r0_body.kappa37 = Conv.Map.compact PRE_first_tail_x6_r0_body.s369.next 2704201 PRE_first_tail_x6_r0_body.S369.tab.length PRE_first_tail_x6_r0_body.pl37 (PRE_first_tail_x6_r0_body.nr37.map NumV.ref) PRE_first_tail_x6_r0_body.kd37.big
  PRE_first_tail_x6_r0_body.kd37.region PRE_first_tail_x6_r0_body.kd37.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin37 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s371.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc37 : Conv.jcleanListB (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s371 PRE_first_tail_x6_r0_body.cl37 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB37 : noBigRootsP (fun i => !Conv.oldBigB (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s371.trace PRE_first_tail_x6_r0_body.s371 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm37 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 16029 = true
theorem PRE_first_tail_x6_r0_body.cjcl37 (h : Conv.JClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s369) : Conv.JClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s371 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle37)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap37 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd37 a ha)) PRE_first_tail_x6_r0_body.zjc37

end Host.Load.Run.Tpl
end

section -- st37/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st37.bodyLast from PRE_first_tail_x6_r0_body.st37.s1 to PRE_first_tail_x6_r0_body.st37.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st37.F PRE_first_tail_x6_r0_body.st37.s1).run PRE_first_tail_x6_r0_body.st37.S1 = some (PRE_first_tail_x6_r0_body.st37.s2, PRE_first_tail_x6_r0_body.st37.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st37.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st37.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st37.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st37.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st37/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st37.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st37.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st37.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st37.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st37.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st37.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st37.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st37.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st37.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st37.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st37.s0 PRE_first_tail_x6_r0_body.st37.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st37.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st37.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st37.s1 PRE_first_tail_x6_r0_body.st37.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st37/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st37.bodyK0F from PRE_first_tail_x6_r0_body.st37.s0 to PRE_first_tail_x6_r0_body.st37.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st37.F (PRE_first_tail_x6_r0_body.st37.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st37.ks 0).getD 0) PRE_first_tail_x6_r0_body.st37.s0 PRE_first_tail_x6_r0_body.st37.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st37.s1, PRE_first_tail_x6_r0_body.st37.S1)
theorem PRE_first_tail_x6_r0_body.st37.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st37.F (PRE_first_tail_x6_r0_body.st37.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st37.ks 0).getD 0) PRE_first_tail_x6_r0_body.st37.s0 PRE_first_tail_x6_r0_body.st37.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st37.s1, PRE_first_tail_x6_r0_body.st37.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st37.bodyOkLN_ok PRE_first_tail_x6_r0_body.st37.bodyK0F
end Host.Load.Run.Tpl
end

section -- st37/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st37.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st37.F (PRE_first_tail_x6_r0_body.st37.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st37.s0 PRE_first_tail_x6_r0_body.st37.S0 = some (PRE_first_tail_x6_r0_body.st37.s1, PRE_first_tail_x6_r0_body.st37.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st37.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st37.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st37.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st37.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st37.F (PRE_first_tail_x6_r0_body.st37.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st37.s0
  S0 := PRE_first_tail_x6_r0_body.st37.S0
  s1 := PRE_first_tail_x6_r0_body.st37.s1
  S1 := PRE_first_tail_x6_r0_body.st37.S1
  s2 := PRE_first_tail_x6_r0_body.st37.s2
  S2 := PRE_first_tail_x6_r0_body.st37.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st37.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st37.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st37.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st37.bodyHalt
  last := PRE_first_tail_x6_r0_body.st37.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st37.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC38
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 38 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s375` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa38` into the merged state
`PRE_first_tail_x6_r0_body.s374`. -/

def PRE_first_tail_x6_r0_body.pl38 : List Nat := [2704497]
def PRE_first_tail_x6_r0_body.nr38 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd38 : RData :=
  ⟨2704488, 2704498, Stage.setAll PTrie.nil [(2704487, 2704497)], Stage.setAll PTrie.nil [],
   18947, 18947, 16033, 16033, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa38 : Map :=
  Conv.Map.compact 2704487 2704498 1678 PRE_first_tail_x6_r0_body.pl38 (PRE_first_tail_x6_r0_body.nr38.map NumV.ref) PRE_first_tail_x6_r0_body.kd38.big
    PRE_first_tail_x6_r0_body.kd38.region PRE_first_tail_x6_r0_body.kd38.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws38 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs38 : List SymE := PRE_first_tail_x6_r0_body.nr38.map fun r => (nth? PRE_first_tail_x6_r0_body.S374.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta38 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws38 PRE_first_tail_x6_r0_body.crs38
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB38 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab38 : PRE_first_tail_x6_r0_body.S375.tab = PRE_first_tail_x6_r0_body.S373.tab ++ PRE_first_tail_x6_r0_body.cws38.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace38 : PRE_first_tail_x6_r0_body.s375.trace = PRE_first_tail_x6_r0_body.s373.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext38 : PRE_first_tail_x6_r0_body.s375.next = 2704488
kernel_rfl PRE_first_tail_x6_r0_body.ccounters38 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx.nnext) = (18947, 16033)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue38 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s374.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa38.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp38 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx.tokens.all (bSN 1678) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean38 : Conv.cleanListB 18947 131072 (fun r => Nat.ble 75788 r) PRE_first_tail_x6_r0_body.s375
    (PRE_first_tail_x6_r0_body.wrB38 ++ (List.range 1).map (2704487 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs38 : bigsOutB 18947 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK38
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl38`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl38 : List Nat := [2665, 2673467, 2704487]
def PRE_first_tail_x6_r0_body.clo38 : List Nat := []
def PRE_first_tail_x6_r0_body.cln38 : List Nat := []
def PRE_first_tail_x6_r0_body.cli38 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap38 : PRE_first_tail_x6_r0_body.s375.heap = Stage.setAll PRE_first_tail_x6_r0_body.s373.heap (PRE_first_tail_x6_r0_body.cl38.filterMap fun a => (PRE_first_tail_x6_r0_body.s375.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe38 : Nat.ble PRE_first_tail_x6_r0_body.s373.next PRE_first_tail_x6_r0_body.s375.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP38 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s373 PRE_first_tail_x6_r0_body.s375 PRE_first_tail_x6_r0_body.cl38 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp38 : Conv.suppListB PRE_first_tail_x6_r0_body.s375 1678 PRE_first_tail_x6_r0_body.cl38 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound38 : Conv.boundListB PRE_first_tail_x6_r0_body.s375 PRE_first_tail_x6_r0_body.cl38 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK38 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln38.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK38 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo38.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK38 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli38.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst38 : Conv.sstListB 1678 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx PRE_first_tail_x6_r0_body.cln38 PRE_first_tail_x6_r0_body.clo38 PRE_first_tail_x6_r0_body.cli38 = true

end Host.Load.Run.Tpl
end

section -- SiteCl38
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA38 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo38.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd38 : (PRE_first_tail_x6_r0_body.clo38 ++ PRE_first_tail_x6_r0_body.cln38 ++ PRE_first_tail_x6_r0_body.cli38).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle38 : Conv.Cnt.leB (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) (⟨18947, 16033, 2704488, 1678⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck38 : Conv.ncleanListB (⟨18947, 16033, 2704488, 1678⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx PRE_first_tail_x6_r0_body.clo38 PRE_first_tail_x6_r0_body.cln38 PRE_first_tail_x6_r0_body.cli38 = true
theorem PRE_first_tail_x6_r0_body.cncl38 (h : Conv.NClean (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx) : Conv.NClean (⟨18947, 16033, 2704488, 1678⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle38 PRE_first_tail_x6_r0_body.ckA38 PRE_first_tail_x6_r0_body.cobjsK38 PRE_first_tail_x6_r0_body.cnodesK38 PRE_first_tail_x6_r0_body.citemsK38 PRE_first_tail_x6_r0_body.cbd38 PRE_first_tail_x6_r0_body.cck38

end Host.Load.Run.Tpl
end

section -- SiteS38
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 38 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc38 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P38 : LoadP := PRE_first_tail_x6_r0_body.Pc38.raise 16033
kernel_rfl PRE_first_tail_x6_r0_body.craise38 : Nat.ble PRE_first_tail_x6_r0_body.Pc38.N0 16033 = true
theorem PRE_first_tail_x6_r0_body.raised38 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc38 PRE_first_tail_x6_r0_body.P38 :=
  .inr ⟨16033, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise38, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_38 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_38 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s374.ffi)
def PRE_first_tail_x6_r0_body.khinv38 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv38 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS38 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS38 : List Nat := List.range' 16033 0
def PRE_first_tail_x6_r0_body.ciS38 : List Nat := [] ++ List.range' 16033 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh038 : PRE_first_tail_x6_r0_body.kd38.nh0 = PRE_first_tail_x6_r0_body.cx0_38.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh138 : PRE_first_tail_x6_r0_body.kd38.nh1 = PRE_first_tail_x6_r0_body.cx1_38.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn038 : PRE_first_tail_x6_r0_body.kd38.nn0 = PRE_first_tail_x6_r0_body.cx0_38.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn138 : PRE_first_tail_x6_r0_body.kd38.nn1 = PRE_first_tail_x6_r0_body.cx1_38.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo38 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P38.lo && Nat.ble PRE_first_tail_x6_r0_body.P38.lo PRE_first_tail_x6_r0_body.cx0_38.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P38.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P38.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt38 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_38.mlx.next PRE_first_tail_x6_r0_body.cx1_38.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_38.mlx.nnext PRE_first_tail_x6_r0_body.cx1_38.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband38 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P38.NL && Nat.ble PRE_first_tail_x6_r0_body.P38.NL PRE_first_tail_x6_r0_body.P38.N0 && Nat.ble PRE_first_tail_x6_r0_body.P38.N0 PRE_first_tail_x6_r0_body.cx0_38.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow38 : PRE_first_tail_x6_r0_body.kd38.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren38 : checkRenG PRE_first_tail_x6_r0_body.kd38.hnd PRE_first_tail_x6_r0_body.khinv38 (phB PRE_first_tail_x6_r0_body.cx0_38.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband38 : PRE_first_tail_x6_r0_body.kd38.checkBand PRE_first_tail_x6_r0_body.P38.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos38 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd38.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren38 : checkRenG PRE_first_tail_x6_r0_body.kd38.node PRE_first_tail_x6_r0_body.kninv38 (pnB PRE_first_tail_x6_r0_body.cx0_38.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow38 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd38.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P38.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd38.nodeF j) PRE_first_tail_x6_r0_body.cx1_38.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a38 : PRE_first_tail_x6_r0_body.cx0_38.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b38 : PRE_first_tail_x6_r0_body.cx0_38.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok138 : PRE_first_tail_x6_r0_body.cx1_38.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend38 : PRE_first_tail_x6_r0_body.cx1_38.mlx.pending = PRE_first_tail_x6_r0_body.cx0_38.mlx.pending.map PRE_first_tail_x6_r0_body.kappa38.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh38 : PRE_first_tail_x6_r0_body.cx1_38.mlx.errh = PRE_first_tail_x6_r0_body.cx0_38.mlx.errh.map PRE_first_tail_x6_r0_body.kappa38.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles38 : PRE_first_tail_x6_r0_body.cx1_38.mlx.files = PRE_first_tail_x6_r0_body.cx0_38.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch38 : PRE_first_tail_x6_r0_body.cx1_38.mlx.arch = PRE_first_tail_x6_r0_body.cx0_38.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes38 : PRE_first_tail_x6_r0_body.cx1_38.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_38.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired38 : PRE_first_tail_x6_r0_body.cx1_38.mlx.wired = PRE_first_tail_x6_r0_body.cx0_38.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost38 : PRE_first_tail_x6_r0_body.cx1_38.host = PRE_first_tail_x6_r0_body.cx0_38.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd38`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn038 : PRE_first_tail_x6_r0_body.kd38.n0 = 2704488
kernel_rfl PRE_first_tail_x6_r0_body.ckn138 : PRE_first_tail_x6_r0_body.kd38.n1 = 2704498
kernel_rfl PRE_first_tail_x6_r0_body.ckheap38 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd38.heap).all (fun x => Nat.ble 2704487 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl38 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd38.heap.get (2704487 + j) = nth? PRE_first_tail_x6_r0_body.pl38 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja38 : Nat.ble 2704487 2704487 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn38 : Nat.ble 1678 1678 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD38 : Nat.ble 2704487 PRE_first_tail_x6_r0_body.kd38.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn38 : Nat.ble 18947 PRE_first_tail_x6_r0_body.kd38.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn38 : Nat.ble 16033 PRE_first_tail_x6_r0_body.kd38.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb38 : Nat.ble 18947 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap38 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd38.heap).all (Nat.ble (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd38 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd38.hnd).all (Nat.ble (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode38 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd38.node).all (Nat.ble (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix38 : Conv.FixOld (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa38 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja38) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn38) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD38) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn38) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn38) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb38) PRE_first_tail_x6_r0_body.fheap38 PRE_first_tail_x6_r0_body.fhnd38 PRE_first_tail_x6_r0_body.fnode38
kernel_rfl PRE_first_tail_x6_r0_body.fcxn38 : (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn38 : (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle038 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_38.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_38.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk38 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd38.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A38 : PRE_first_tail_x6_r0_body.cx1_38.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS38.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_38.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O38 : PRE_first_tail_x6_r0_body.cx1_38.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS38.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_38.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N38 : PRE_first_tail_x6_r0_body.cx1_38.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS38.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_38.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I38 : PRE_first_tail_x6_r0_body.cx1_38.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS38.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_38.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd38 : (PRE_first_tail_x6_r0_body.clo38 ++ PRE_first_tail_x6_r0_body.cln38 ++ PRE_first_tail_x6_r0_body.cli38 ++ PRE_first_tail_x6_r0_body.cwS38 ++ PRE_first_tail_x6_r0_body.cnS38 ++ PRE_first_tail_x6_r0_body.ciS38).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW38 : PRE_first_tail_x6_r0_body.cwS38.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo38.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI38 : PRE_first_tail_x6_r0_body.ciS38.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli38.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN38 : PRE_first_tail_x6_r0_body.cnS38.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF38 : PRE_first_tail_x6_r0_body.cln38.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh38 : PRE_first_tail_x6_r0_body.clo38.all (handleOK PRE_first_tail_x6_r0_body.kappa38 PRE_first_tail_x6_r0_body.P38.lo PRE_first_tail_x6_r0_body.cx0_38.mlx PRE_first_tail_x6_r0_body.cx1_38.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo38 : PRE_first_tail_x6_r0_body.clo38.map (fun h => PRE_first_tail_x6_r0_body.cx1_38.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa38.handle h)) = PRE_first_tail_x6_r0_body.clo38.map (fun h => (PRE_first_tail_x6_r0_body.cx0_38.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa38.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok38 : PRE_first_tail_x6_r0_body.clo38.all (objOK PRE_first_tail_x6_r0_body.kappa38 PRE_first_tail_x6_r0_body.P38.NL PRE_first_tail_x6_r0_body.cx0_38.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd38 : PRE_first_tail_x6_r0_body.cln38.all (nodeOKF PRE_first_tail_x6_r0_body.kappa38 PRE_first_tail_x6_r0_body.P38 PRE_first_tail_x6_r0_body.cx0_38.mlx PRE_first_tail_x6_r0_body.cx1_38.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp38 : ((PRE_first_tail_x6_r0_body.cln38.filter (fullB PRE_first_tail_x6_r0_body.P38))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_38.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa38.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln38.filter (fullB PRE_first_tail_x6_r0_body.P38))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_38.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa38.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI38 : incrB PRE_first_tail_x6_r0_body.kd38.nodeF (List.range' 16033 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK38 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd38.node).all (fun k => Nat.ble 16033 k && Nat.blt k 16033) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL38 : (PRE_first_tail_x6_r0_body.cln38.filter (Nat.ble PRE_first_tail_x6_r0_body.P38.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd38.nodeF i) && (Nat.blt i 16033 || Nat.ble PRE_first_tail_x6_r0_body.kd38.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord38 : (PRE_first_tail_x6_r0_body.cln38.filter (Nat.ble PRE_first_tail_x6_r0_body.P38.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd38.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd38.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd38.nodeF j) (PRE_first_tail_x6_r0_body.kd38.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow38 PRE_first_tail_x6_r0_body.cnn138 PRE_first_tail_x6_r0_body.fnordI38 PRE_first_tail_x6_r0_body.fnordK38 PRE_first_tail_x6_r0_body.fnordL38
kernel_rfl PRE_first_tail_x6_r0_body.fi38 : PRE_first_tail_x6_r0_body.cli38.all (pnB PRE_first_tail_x6_r0_body.cx0_38.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii38 : PRE_first_tail_x6_r0_body.cli38.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_38.mlx.items.get (PRE_first_tail_x6_r0_body.kappa38.node k) = (PRE_first_tail_x6_r0_body.cx0_38.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa38.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot38 (clean : Conv.NClean (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P38.NL) (cl : SSt (· < 1678) PRE_first_tail_x6_r0_body.cx0_38.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P38 1678 PRE_first_tail_x6_r0_body.kappa38 PRE_first_tail_x6_r0_body.kd38 PRE_first_tail_x6_r0_body.khinv38 PRE_first_tail_x6_r0_body.kninv38 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx PRE_first_tail_x6_r0_body.cx0_38.mlx PRE_first_tail_x6_r0_body.cx1_38.mlx (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo38 PRE_first_tail_x6_r0_body.cln38 PRE_first_tail_x6_r0_body.cli38 PRE_first_tail_x6_r0_body.cwS38 PRE_first_tail_x6_r0_body.cnS38 PRE_first_tail_x6_r0_body.ciS38 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh038, PRE_first_tail_x6_r0_body.cnh138, PRE_first_tail_x6_r0_body.cnn038, PRE_first_tail_x6_r0_body.cnn138, PRE_first_tail_x6_r0_body.cplo38, PRE_first_tail_x6_r0_body.ccnt38, PRE_first_tail_x6_r0_body.cnband38, PRE_first_tail_x6_r0_body.chbelow38, PRE_first_tail_x6_r0_body.chren38, PRE_first_tail_x6_r0_body.cband38, PRE_first_tail_x6_r0_body.cnh1pos38, PRE_first_tail_x6_r0_body.cnren38, PRE_first_tail_x6_r0_body.cnlow38, PRE_first_tail_x6_r0_body.cabs0a38, PRE_first_tail_x6_r0_body.cabs0b38, PRE_first_tail_x6_r0_body.ctok138, PRE_first_tail_x6_r0_body.cpend38, PRE_first_tail_x6_r0_body.cerrh38, PRE_first_tail_x6_r0_body.cfiles38, PRE_first_tail_x6_r0_body.carch38, PRE_first_tail_x6_r0_body.csizes38, PRE_first_tail_x6_r0_body.cwired38, PRE_first_tail_x6_r0_body.cfix38, clean, PRE_first_tail_x6_r0_body.fcxn38, PRE_first_tail_x6_r0_body.fcnn38, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle038, PRE_first_tail_x6_r0_body.fnk38, PRE_first_tail_x6_r0_body.ckA38, PRE_first_tail_x6_r0_body.cobjsK38, PRE_first_tail_x6_r0_body.cnodesK38, PRE_first_tail_x6_r0_body.citemsK38, PRE_first_tail_x6_r0_body.f1A38, PRE_first_tail_x6_r0_body.f1O38, PRE_first_tail_x6_r0_body.f1N38, PRE_first_tail_x6_r0_body.f1I38, PRE_first_tail_x6_r0_body.fbd38, PRE_first_tail_x6_r0_body.fincW38, PRE_first_tail_x6_r0_body.fincI38, PRE_first_tail_x6_r0_body.fincN38, PRE_first_tail_x6_r0_body.flnF38, PRE_first_tail_x6_r0_body.fh38, PRE_first_tail_x6_r0_body.fo38, PRE_first_tail_x6_r0_body.fok38, PRE_first_tail_x6_r0_body.fnd38, PRE_first_tail_x6_r0_body.fp38, PRE_first_tail_x6_r0_body.fnord38, PRE_first_tail_x6_r0_body.fi38, PRE_first_tail_x6_r0_body.fii38⟩
theorem PRE_first_tail_x6_r0_body.cnshift38 (clean : Conv.NClean (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P38.NL) (cl : SSt (· < 1678) PRE_first_tail_x6_r0_body.cx0_38.mlx) : NShift PRE_first_tail_x6_r0_body.P38 1678 PRE_first_tail_x6_r0_body.kappa38 PRE_first_tail_x6_r0_body.cx0_38 PRE_first_tail_x6_r0_body.cx1_38 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot38 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost38 (compact_a_eq PRE_first_tail_x6_r0_body.ckn038 PRE_first_tail_x6_r0_body.ckn138 PRE_first_tail_x6_r0_body.ckheap38 PRE_first_tail_x6_r0_body.ckpl38)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_38 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s373.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_38 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s373.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_38 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s373.ffi) = some PRE_first_tail_x6_r0_body.fxC_38
kernel_rfl PRE_first_tail_x6_r0_body.okrC_38 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s373.ffi) = some PRE_first_tail_x6_r0_body.krC_38
noncomputable def PRE_first_tail_x6_r0_body.fx0_38 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s375.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_38 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s375.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_38 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s375.ffi) = some PRE_first_tail_x6_r0_body.fx0_38
kernel_rfl PRE_first_tail_x6_r0_body.okr0_38 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s375.ffi) = some PRE_first_tail_x6_r0_body.kr0_38
noncomputable def PRE_first_tail_x6_r0_body.fx1_38 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s374.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_38 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s374.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_38 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s374.ffi) = some PRE_first_tail_x6_r0_body.fx1_38
kernel_rfl PRE_first_tail_x6_r0_body.okr1_38 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s374.ffi) = some PRE_first_tail_x6_r0_body.kr1_38
kernel_rfl PRE_first_tail_x6_r0_body.ff038 : PRE_first_tail_x6_r0_body.fx0_38 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_38 (PRE_first_tail_x6_r0_body.clo38.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_38.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff138 : PRE_first_tail_x6_r0_body.fx1_38 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_38 (PRE_first_tail_x6_r0_body.cwS38.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_38.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck38 : freedLB PRE_first_tail_x6_r0_body.kappa38 PRE_first_tail_x6_r0_body.cx0_38.mlx PRE_first_tail_x6_r0_body.fx0_38 PRE_first_tail_x6_r0_body.fx1_38 PRE_first_tail_x6_r0_body.clo38 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf038 : PRE_first_tail_x6_r0_body.kr0_38.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_38.flags (PRE_first_tail_x6_r0_body.clo38.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_38.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt038 : PRE_first_tail_x6_r0_body.kr0_38.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_38.targs (PRE_first_tail_x6_r0_body.clo38.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_38.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf138 : PRE_first_tail_x6_r0_body.kr1_38.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_38.flags (PRE_first_tail_x6_r0_body.cwS38.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_38.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt138 : PRE_first_tail_x6_r0_body.kr1_38.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_38.targs (PRE_first_tail_x6_r0_body.cwS38.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_38.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck38 : krecLB PRE_first_tail_x6_r0_body.kappa38 1678 PRE_first_tail_x6_r0_body.cx0_38.mlx PRE_first_tail_x6_r0_body.kr0_38 PRE_first_tail_x6_r0_body.kr1_38 PRE_first_tail_x6_r0_body.clo38 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn38 : Nat.ble 1678 1678 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge38 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s374.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s375.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR38 : pendRegB PRE_first_tail_x6_r0_body.kappa38 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe38 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s375.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s374.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift38 (clean : Conv.NClean (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P38.NL) (cl : SSt (· < 1678) PRE_first_tail_x6_r0_body.cx0_38.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_38.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_38.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_38.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s373.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_38.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P38 1678 PRE_first_tail_x6_r0_body.kappa38 PRE_first_tail_x6_r0_body.s375.ffi PRE_first_tail_x6_r0_body.s374.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift38 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue38, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp38 t ht),
    PRE_first_tail_x6_r0_body.cbridge38,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s375.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s374.ffi) (PRE_first_tail_x6_r0_body.cfoot38 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_38 PRE_first_tail_x6_r0_body.ofx1_38 hobjC PRE_first_tail_x6_r0_body.ff038 PRE_first_tail_x6_r0_body.ff138 PRE_first_tail_x6_r0_body.ffck38,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s375.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s374.ffi) (PRE_first_tail_x6_r0_body.cfoot38 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_38 PRE_first_tail_x6_r0_body.okr1_38 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn38) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf038 PRE_first_tail_x6_r0_body.fkt038 PRE_first_tail_x6_r0_body.fkf138 PRE_first_tail_x6_r0_body.fkt138 PRE_first_tail_x6_r0_body.fkck38,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh038 PRE_first_tail_x6_r0_body.cnh138 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe38) PRE_first_tail_x6_r0_body.cpendR38⟩

end Host.Load.Run.Tpl
end

section -- st38/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st38 0
host_stream_state PRE_first_tail_x6_r0_body.st38 1
host_stream_state PRE_first_tail_x6_r0_body.st38 2
end Host.Load.Run.Tpl
end

section -- Site38
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 38 of chain `PRE_first_tail_x6_r0_body`: `plan__g38__g39` (`plan`), the call state `PRE_first_tail_x6_r0_body.s373`, the merged state `PRE_first_tail_x6_r0_body.s374`,
the site template `PRE_first_tail_x6_r0_body.st38` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s375`: the merge.
The footprint's facts are in `SiteF38`, the compaction's in `SiteC38`, `SiteK38`, `SiteNa38`, `SiteNb38`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso38 : PRE_first_tail_x6_r0_body.st38.s0 = { PRE_first_tail_x6_r0_body.s373 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs38 : List Frame := PRE_first_tail_x6_r0_body.s373.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_38 : PRE_first_tail_x6_r0_body.S373.tab.length = 1678
kernel_rfl PRE_first_tail_x6_r0_body.tab0_38 : PRE_first_tail_x6_r0_body.st38.S0.tab = PRE_first_tail_x6_r0_body.S373.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws38 : List Nat := [1642, 1643, 1644]
kernel_rfl PRE_first_tail_x6_r0_body.fresh38 : (PRE_first_tail_x6_r0_body.S373.tab.all fun e => PRE_first_tail_x6_r0_body.ws38.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S373.oracle.all fun q => PRE_first_tail_x6_r0_body.ws38.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab38 : PRE_first_tail_x6_r0_body.S374.tab = PRE_first_tail_x6_r0_body.S373.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws38
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen38 : PRE_first_tail_x6_r0_body.st38.S2.tab.length - PRE_first_tail_x6_r0_body.st38.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged38`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap38 : PRE_first_tail_x6_r0_body.s374.heap = PRE_first_tail_x6_r0_body.st38.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext38 : PRE_first_tail_x6_r0_body.s374.next = PRE_first_tail_x6_r0_body.st38.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl38 : PRE_first_tail_x6_r0_body.s374.ctl = PRE_first_tail_x6_r0_body.st38.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack38 : PRE_first_tail_x6_r0_body.s374.stack = PRE_first_tail_x6_r0_body.st38.s2.stack ++ PRE_first_tail_x6_r0_body.s373.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs38 : PRE_first_tail_x6_r0_body.s374.jobs = PRE_first_tail_x6_r0_body.st38.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi38 : PRE_first_tail_x6_r0_body.s374.ffi = PRE_first_tail_x6_r0_body.st38.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace38 : PRE_first_tail_x6_r0_body.s374.trace = PRE_first_tail_x6_r0_body.st38.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores38 : PRE_first_tail_x6_r0_body.s374.stores = PRE_first_tail_x6_r0_body.st38.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD38
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 38 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived38 : PRE_first_tail_x6_r0_body.nr38.map (fun r => nth? PRE_first_tail_x6_r0_body.st38.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo38 : PRE_first_tail_x6_r0_body.nr38.all (Nat.ble 1678) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj38 : PRE_first_tail_x6_r0_body.cws38.all (fun c => !PRE_first_tail_x6_r0_body.ws38.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ38 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws38 PRE_first_tail_x6_r0_body.crs38 PRE_first_tail_x6_r0_body.ws38

end Host.Load.Run.Tpl
end

section -- st38/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st38`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st38.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st38.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st38.s2.heap PRE_first_tail_x6_r0_body.st38.wrR ++ freshOf PRE_first_tail_x6_r0_body.st38.s2.heap PRE_first_tail_x6_r0_body.st38.s0.next PRE_first_tail_x6_r0_body.st38.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st38.wr : List Nat := PRE_first_tail_x6_r0_body.st38.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st38.heapFoot : PRE_first_tail_x6_r0_body.st38.s2.heap = setAll PRE_first_tail_x6_r0_body.st38.s0.heap PRE_first_tail_x6_r0_body.st38.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st38.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st38.s0.next PRE_first_tail_x6_r0_body.st38.s2.next = true
theorem PRE_first_tail_x6_r0_body.st38.grows : PRE_first_tail_x6_r0_body.st38.s0.next ≤ PRE_first_tail_x6_r0_body.st38.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st38.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st38.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st38.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st38.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st38.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st38.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st38.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st38.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st38.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st38.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st38.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st38.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF38
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 38 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB38 : nodupT PRE_first_tail_x6_r0_body.st38.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup38 : PRE_first_tail_x6_r0_body.st38.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB38).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB38 : PRE_first_tail_x6_r0_body.st38.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound38 : ∀ b ∈ PRE_first_tail_x6_r0_body.st38.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB38 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr38 := PRE_first_tail_x6_r0_body.st38.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq38 : PRE_first_tail_x6_r0_body.st38.s2.trace = PRE_first_tail_x6_r0_body.trFr38 ++ PRE_first_tail_x6_r0_body.st38.s0.trace
theorem PRE_first_tail_x6_r0_body.trace38 : ∃ fr, PRE_first_tail_x6_r0_body.st38.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st38.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq38⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide38 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB38 : (PRE_first_tail_x6_r0_body.wide38.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st38.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix38 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide38, WFix Map.id (Present PRE_first_tail_x6_r0_body.st38.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB38 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL38
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 38 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s374`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO38 : PRE_first_tail_x6_r0_body.st38.S0.oracle = PRE_first_tail_x6_r0_body.st38.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B38 : PRE_first_tail_x6_r0_body.st38.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st38.s0.next || (PRE_first_tail_x6_r0_body.st38.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot38 : Conv.StageFoot PRE_first_tail_x6_r0_body.st38.wr PRE_first_tail_x6_r0_body.st38.s0 PRE_first_tail_x6_r0_body.st38.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st38.heapFoot PRE_first_tail_x6_r0_body.wrNodup38 PRE_first_tail_x6_r0_body.wrBound38 PRE_first_tail_x6_r0_body.wr0B38 PRE_first_tail_x6_r0_body.st38.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged38 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st38.F.S → PRE_first_tail_x6_r0_body.st38.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st38.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st38.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs38 PRE_first_tail_x6_r0_body.st38.wr PRE_first_tail_x6_r0_body.s373 PRE_first_tail_x6_r0_body.st38.s2 PRE_first_tail_x6_r0_body.st38.s0
      PRE_first_tail_x6_r0_body.st38.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st38.F FR W stk M ν K PRE_first_tail_x6_r0_body.s374 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso38 PRE_first_tail_x6_r0_body.stFoot38 PRE_first_tail_x6_r0_body.wrNodup38 PRE_first_tail_x6_r0_body.wrBound38 PRE_first_tail_x6_r0_body.trace38 PRE_first_tail_x6_r0_body.mheap38
    PRE_first_tail_x6_r0_body.mnext38 PRE_first_tail_x6_r0_body.mctl38 PRE_first_tail_x6_r0_body.mstack38 PRE_first_tail_x6_r0_body.mjobs38 PRE_first_tail_x6_r0_body.mffi38 PRE_first_tail_x6_r0_body.mtrace38 PRE_first_tail_x6_r0_body.mstores38 h

def PRE_first_tail_x6_r0_body.arrEl38_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE38_2665 : arrOf PRE_first_tail_x6_r0_body.s374 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl38_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA38_2665 : isArrB PRE_first_tail_x6_r0_body.s374 2665 = true
theorem PRE_first_tail_x6_r0_body.arr38_2665 : ∃ o, PRE_first_tail_x6_r0_body.s374.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl38_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE38_2665 PRE_first_tail_x6_r0_body.arrA38_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN38_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl38_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR38_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl38_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN38_2665

def PRE_first_tail_x6_r0_body.arrEl38_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE38_2673467 : arrOf PRE_first_tail_x6_r0_body.s374 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl38_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA38_2673467 : isArrB PRE_first_tail_x6_r0_body.s374 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr38_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s374.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl38_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE38_2673467 PRE_first_tail_x6_r0_body.arrA38_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN38_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl38_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR38_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl38_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN38_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k38 : isArrB PRE_first_tail_x6_r0_body.s374 4910 = false
theorem PRE_first_tail_x6_r0_body.keep38 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s374 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k38 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr38_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl38_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ38
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 38 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s373`, the merged
state `PRE_first_tail_x6_r0_body.s374`, the canonical state `PRE_first_tail_x6_r0_body.s375`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl38 : PRE_first_tail_x6_r0_body.pl38.all (Nat.ble PRE_first_tail_x6_r0_body.s373.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd38 : nodupT PRE_first_tail_x6_r0_body.pl38 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn138 : Nat.ble PRE_first_tail_x6_r0_body.s373.next 2704498 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst38 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s373.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn38 : PRE_first_tail_x6_r0_body.s375.next = PRE_first_tail_x6_r0_body.s373.next + PRE_first_tail_x6_r0_body.pl38.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn38 : PRE_first_tail_x6_r0_body.s374.next = 2704498
kernel_rfl PRE_first_tail_x6_r0_body.zgrow38 : Nat.ble PRE_first_tail_x6_r0_body.s375.next PRE_first_tail_x6_r0_body.s374.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh38 : PRE_first_tail_x6_r0_body.S373.tab.all (fun e => PRE_first_tail_x6_r0_body.cws38.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd38 : nodupT PRE_first_tail_x6_r0_body.cws38 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi38 : PRE_first_tail_x6_r0_body.nr38.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S374.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt38 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s373.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg38_2665 : PRE_first_tail_x6_r0_body.s375.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s375 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk38_2665 : (objOf PRE_first_tail_x6_r0_body.s375 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm38_2665 : PRE_first_tail_x6_r0_body.s374.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa38.obj (objOf PRE_first_tail_x6_r0_body.s375 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s374 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg38_2673467 : PRE_first_tail_x6_r0_body.s375.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s375 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk38_2673467 : (objOf PRE_first_tail_x6_r0_body.s375 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm38_2673467 : PRE_first_tail_x6_r0_body.s374.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa38.obj (objOf PRE_first_tail_x6_r0_body.s375 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s374 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw38_4910 : (PRE_first_tail_x6_r0_body.s375.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw38_2673472 : (PRE_first_tail_x6_r0_body.s375.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw38_2673473 : (PRE_first_tail_x6_r0_body.s375.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd38 : PRE_first_tail_x6_r0_body.cl38.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr38 : PRE_first_tail_x6_r0_body.st38.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s373.next || PRE_first_tail_x6_r0_body.cl38.contains b) = true
def PRE_first_tail_x6_r0_body.zl38 : List Nat := PRE_first_tail_x6_r0_body.cl38.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE38 : PRE_first_tail_x6_r0_body.zl38.map (fun a => PRE_first_tail_x6_r0_body.s374.heap.get (PRE_first_tail_x6_r0_body.kappa38.a a)) = PRE_first_tail_x6_r0_body.zl38.map (fun a => (PRE_first_tail_x6_r0_body.s375.heap.get a).map PRE_first_tail_x6_r0_body.kappa38.hobj)
theorem PRE_first_tail_x6_r0_body.zimg38 : HeapImg PRE_first_tail_x6_r0_body.kappa38 PRE_first_tail_x6_r0_body.s375 PRE_first_tail_x6_r0_body.s374 PRE_first_tail_x6_r0_body.zl38 := PRE_first_tail_x6_r0_body.zimgE38
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl38 : PRE_first_tail_x6_r0_body.s374.ctl = PRE_first_tail_x6_r0_body.kappa38.ctl PRE_first_tail_x6_r0_body.s375.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack38 : PRE_first_tail_x6_r0_body.s374.stack = PRE_first_tail_x6_r0_body.s375.stack.map PRE_first_tail_x6_r0_body.kappa38.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs38 : PRE_first_tail_x6_r0_body.s374.jobs = PRE_first_tail_x6_r0_body.s375.jobs.map PRE_first_tail_x6_r0_body.kappa38.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores38 : PRE_first_tail_x6_r0_body.s374.stores = PRE_first_tail_x6_r0_body.kappa38.stores PRE_first_tail_x6_r0_body.s375.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots38 : checkRootsSupp PRE_first_tail_x6_r0_body.s375 1678 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC38 : PRE_first_tail_x6_r0_body.S373.tab.length + PRE_first_tail_x6_r0_body.cws38.length = 1678
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap38 : PRE_first_tail_x6_r0_body.kappa38 = Conv.Map.compact PRE_first_tail_x6_r0_body.s373.next 2704498 PRE_first_tail_x6_r0_body.S373.tab.length PRE_first_tail_x6_r0_body.pl38 (PRE_first_tail_x6_r0_body.nr38.map NumV.ref) PRE_first_tail_x6_r0_body.kd38.big
  PRE_first_tail_x6_r0_body.kd38.region PRE_first_tail_x6_r0_body.kd38.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin38 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s375.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc38 : Conv.jcleanListB (⟨18947, 16033, 2704488, 1678⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s375 PRE_first_tail_x6_r0_body.cl38 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB38 : noBigRootsP (fun i => !Conv.oldBigB (⟨18947, 16033, 2704488, 1678⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s375.trace PRE_first_tail_x6_r0_body.s375 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm38 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 16033 = true
theorem PRE_first_tail_x6_r0_body.cjcl38 (h : Conv.JClean (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s373) : Conv.JClean (⟨18947, 16033, 2704488, 1678⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s375 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle38)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap38 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd38 a ha)) PRE_first_tail_x6_r0_body.zjc38

end Host.Load.Run.Tpl
end

section -- st38/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st38.bodyLast from PRE_first_tail_x6_r0_body.st38.s1 to PRE_first_tail_x6_r0_body.st38.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st38.F PRE_first_tail_x6_r0_body.st38.s1).run PRE_first_tail_x6_r0_body.st38.S1 = some (PRE_first_tail_x6_r0_body.st38.s2, PRE_first_tail_x6_r0_body.st38.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st38.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st38.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st38.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st38.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st38/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st38.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st38.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st38.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st38.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st38.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st38.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st38.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st38.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st38.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st38.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st38.s0 PRE_first_tail_x6_r0_body.st38.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st38.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st38.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st38.s1 PRE_first_tail_x6_r0_body.st38.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st38/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st38.bodyK0F from PRE_first_tail_x6_r0_body.st38.s0 to PRE_first_tail_x6_r0_body.st38.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st38.F (PRE_first_tail_x6_r0_body.st38.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st38.ks 0).getD 0) PRE_first_tail_x6_r0_body.st38.s0 PRE_first_tail_x6_r0_body.st38.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st38.s1, PRE_first_tail_x6_r0_body.st38.S1)
theorem PRE_first_tail_x6_r0_body.st38.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st38.F (PRE_first_tail_x6_r0_body.st38.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st38.ks 0).getD 0) PRE_first_tail_x6_r0_body.st38.s0 PRE_first_tail_x6_r0_body.st38.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st38.s1, PRE_first_tail_x6_r0_body.st38.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st38.bodyOkLN_ok PRE_first_tail_x6_r0_body.st38.bodyK0F
end Host.Load.Run.Tpl
end

section -- st38/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st38.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st38.F (PRE_first_tail_x6_r0_body.st38.bodyOkL bytes rows) 98 PRE_first_tail_x6_r0_body.st38.s0 PRE_first_tail_x6_r0_body.st38.S0 = some (PRE_first_tail_x6_r0_body.st38.s1, PRE_first_tail_x6_r0_body.st38.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st38.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st38.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st38.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st38.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st38.F (PRE_first_tail_x6_r0_body.st38.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st38.s0
  S0 := PRE_first_tail_x6_r0_body.st38.S0
  s1 := PRE_first_tail_x6_r0_body.st38.s1
  S1 := PRE_first_tail_x6_r0_body.st38.S1
  s2 := PRE_first_tail_x6_r0_body.st38.s2
  S2 := PRE_first_tail_x6_r0_body.st38.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st38.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st38.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st38.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st38.bodyHalt
  last := PRE_first_tail_x6_r0_body.st38.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st38.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC39
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 39 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s392` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa39` into the merged state
`PRE_first_tail_x6_r0_body.s391`. -/

def PRE_first_tail_x6_r0_body.pl39 : List Nat := [2707071, 2706246, 2707077, 2707073, 2706248, 2707079]
def PRE_first_tail_x6_r0_body.nr39 : List Nat := [1781, 1780, 1756, 1764, 1769, 1774, 1779, 1753, 1754, 1755, 1762, 1763, 1751, 1758, 1759, 1760, 1761, 1757]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd39 : RData :=
  ⟨2705965, 2707114, Stage.setAll PTrie.nil [(2705959, 2707071), (2705960, 2706246), (2705961, 2707077), (2705962, 2707073), (2705963, 2706248), (2705964, 2707079)], Stage.setAll PTrie.nil [(18981, 19007), (18982, 18985), (18983, 19008)],
   18984, 19009, 16079, 16079, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(1751, .ref 1781), (1752, .ref 1780), (1753, .ref 1756), (1754, .ref 1764), (1755, .ref 1769), (1756, .ref 1774), (1757, .ref 1779), (1758, .ref 1753), (1759, .ref 1754), (1760, .ref 1755), (1761, .ref 1762), (1762, .ref 1763), (1763, .ref 1751), (1764, .ref 1758), (1765, .ref 1759), (1766, .ref 1760), (1767, .ref 1761), (1768, .ref 1757)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa39 : Map :=
  Conv.Map.compact 2705959 2707114 1751 PRE_first_tail_x6_r0_body.pl39 (PRE_first_tail_x6_r0_body.nr39.map NumV.ref) PRE_first_tail_x6_r0_body.kd39.big
    PRE_first_tail_x6_r0_body.kd39.region PRE_first_tail_x6_r0_body.kd39.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws39 : List Nat := [1676, 1677, 1678, 1679, 1680, 1681, 1682, 1683, 1684, 1685, 1686, 1687, 1688, 1689, 1690, 1691, 1692, 1693]
noncomputable def PRE_first_tail_x6_r0_body.crs39 : List SymE := PRE_first_tail_x6_r0_body.nr39.map fun r => (nth? PRE_first_tail_x6_r0_body.S391.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta39 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws39 PRE_first_tail_x6_r0_body.crs39
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB39 : List Nat := [2665, 2672398, 2673467, 2705133, 2705678, 2705934]

kernel_rfl PRE_first_tail_x6_r0_body.ctab39 : PRE_first_tail_x6_r0_body.S392.tab = PRE_first_tail_x6_r0_body.S390.tab ++ PRE_first_tail_x6_r0_body.cws39.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace39 : PRE_first_tail_x6_r0_body.s392.trace = PRE_first_tail_x6_r0_body.s390.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext39 : PRE_first_tail_x6_r0_body.s392.next = 2705965
kernel_rfl PRE_first_tail_x6_r0_body.ccounters39 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx.nnext) = (18984, 16079)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue39 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s391.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa39.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp39 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx.tokens.all (bSN 1769) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean39 : Conv.cleanListB 18984 131072 (fun r => Nat.ble 75936 r) PRE_first_tail_x6_r0_body.s392
    (PRE_first_tail_x6_r0_body.wrB39 ++ (List.range 6).map (2705959 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs39 : bigsOutB 18984 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK39
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl39`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl39 : List Nat := [2665, 2672398, 2673467, 2705133, 2705678, 2705934, 2705959, 2705960, 2705961, 2705962, 2705963, 2705964]
def PRE_first_tail_x6_r0_body.clo39 : List Nat := [18961, 18974, 18980, 18981, 18982, 18983]
def PRE_first_tail_x6_r0_body.cln39 : List Nat := [16052, 16053, 16054, 16055, 16056, 16057, 16058, 16059, 16060, 16061, 16062, 16063, 16064, 16065, 16066, 16067, 16068, 16069, 16070, 16071, 16072, 16073, 16074, 16075, 16076, 16077, 16078]
def PRE_first_tail_x6_r0_body.cli39 : List Nat := [16052, 16053, 16054, 16055, 16056, 16057, 16058, 16059, 16060, 16061, 16062, 16063, 16064, 16065, 16066, 16067, 16068, 16069, 16070, 16071, 16072, 16073, 16074, 16075, 16076, 16077, 16078]
kernel_rfl PRE_first_tail_x6_r0_body.cheap39 : PRE_first_tail_x6_r0_body.s392.heap = Stage.setAll PRE_first_tail_x6_r0_body.s390.heap (PRE_first_tail_x6_r0_body.cl39.filterMap fun a => (PRE_first_tail_x6_r0_body.s392.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe39 : Nat.ble PRE_first_tail_x6_r0_body.s390.next PRE_first_tail_x6_r0_body.s392.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP39 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s390 PRE_first_tail_x6_r0_body.s392 PRE_first_tail_x6_r0_body.cl39 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp39 : Conv.suppListB PRE_first_tail_x6_r0_body.s392 1769 PRE_first_tail_x6_r0_body.cl39 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound39 : Conv.boundListB PRE_first_tail_x6_r0_body.s392 PRE_first_tail_x6_r0_body.cl39 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK39 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln39.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK39 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo39.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK39 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli39.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst39 : Conv.sstListB 1769 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx PRE_first_tail_x6_r0_body.cln39 PRE_first_tail_x6_r0_body.clo39 PRE_first_tail_x6_r0_body.cli39 = true

end Host.Load.Run.Tpl
end

section -- SiteCl39
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA39 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo39.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd39 : (PRE_first_tail_x6_r0_body.clo39 ++ PRE_first_tail_x6_r0_body.cln39 ++ PRE_first_tail_x6_r0_body.cli39).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle39 : Conv.Cnt.leB (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) (⟨18984, 16079, 2705965, 1769⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck39 : Conv.ncleanListB (⟨18984, 16079, 2705965, 1769⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx PRE_first_tail_x6_r0_body.clo39 PRE_first_tail_x6_r0_body.cln39 PRE_first_tail_x6_r0_body.cli39 = true
theorem PRE_first_tail_x6_r0_body.cncl39 (h : Conv.NClean (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx) : Conv.NClean (⟨18984, 16079, 2705965, 1769⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle39 PRE_first_tail_x6_r0_body.ckA39 PRE_first_tail_x6_r0_body.cobjsK39 PRE_first_tail_x6_r0_body.cnodesK39 PRE_first_tail_x6_r0_body.citemsK39 PRE_first_tail_x6_r0_body.cbd39 PRE_first_tail_x6_r0_body.cck39

end Host.Load.Run.Tpl
end

section -- SiteS39
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 39 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc39 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P39 : LoadP := PRE_first_tail_x6_r0_body.Pc39.raise 16079
kernel_rfl PRE_first_tail_x6_r0_body.craise39 : Nat.ble PRE_first_tail_x6_r0_body.Pc39.N0 16079 = true
theorem PRE_first_tail_x6_r0_body.raised39 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc39 PRE_first_tail_x6_r0_body.P39 :=
  .inr ⟨16079, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise39, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_39 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_39 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s391.ffi)
def PRE_first_tail_x6_r0_body.khinv39 : PTrie Nat := Stage.setAll PTrie.nil [(19007, 18981), (18985, 18982), (19008, 18983)]
def PRE_first_tail_x6_r0_body.kninv39 : PTrie Nat := Stage.setAll PTrie.nil [(16052, 16052), (16053, 16053), (16054, 16054), (16055, 16055), (16056, 16056), (16057, 16057), (16058, 16058), (16059, 16059), (16060, 16060), (16061, 16061), (16062, 16062), (16063, 16063), (16064, 16064), (16065, 16065), (16066, 16066), (16067, 16067), (16068, 16068), (16069, 16069), (16070, 16070), (16071, 16071), (16072, 16072), (16073, 16073), (16074, 16074), (16075, 16075), (16076, 16076), (16077, 16077), (16078, 16078)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS39 : List Nat := [18961, 18974, 18980, 18981, 18982, 18983, 18984, 18985, 18986, 18987, 18988, 18989, 18990, 18991, 18992, 18993, 18994, 18995, 18996, 18997, 18998, 18999, 19000, 19001, 19002, 19003, 19004, 19005, 19006, 19007, 19008]
def PRE_first_tail_x6_r0_body.cnS39 : List Nat := List.range' 16052 27
def PRE_first_tail_x6_r0_body.ciS39 : List Nat := [] ++ List.range' 16052 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh039 : PRE_first_tail_x6_r0_body.kd39.nh0 = PRE_first_tail_x6_r0_body.cx0_39.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh139 : PRE_first_tail_x6_r0_body.kd39.nh1 = PRE_first_tail_x6_r0_body.cx1_39.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn039 : PRE_first_tail_x6_r0_body.kd39.nn0 = PRE_first_tail_x6_r0_body.cx0_39.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn139 : PRE_first_tail_x6_r0_body.kd39.nn1 = PRE_first_tail_x6_r0_body.cx1_39.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo39 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P39.lo && Nat.ble PRE_first_tail_x6_r0_body.P39.lo PRE_first_tail_x6_r0_body.cx0_39.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P39.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P39.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt39 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_39.mlx.next PRE_first_tail_x6_r0_body.cx1_39.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_39.mlx.nnext PRE_first_tail_x6_r0_body.cx1_39.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband39 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P39.NL && Nat.ble PRE_first_tail_x6_r0_body.P39.NL PRE_first_tail_x6_r0_body.P39.N0 && Nat.ble PRE_first_tail_x6_r0_body.P39.N0 PRE_first_tail_x6_r0_body.cx0_39.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow39 : PRE_first_tail_x6_r0_body.kd39.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren39 : checkRenG PRE_first_tail_x6_r0_body.kd39.hnd PRE_first_tail_x6_r0_body.khinv39 (phB PRE_first_tail_x6_r0_body.cx0_39.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband39 : PRE_first_tail_x6_r0_body.kd39.checkBand PRE_first_tail_x6_r0_body.P39.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos39 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd39.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren39 : checkRenG PRE_first_tail_x6_r0_body.kd39.node PRE_first_tail_x6_r0_body.kninv39 (pnB PRE_first_tail_x6_r0_body.cx0_39.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow39 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd39.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P39.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd39.nodeF j) PRE_first_tail_x6_r0_body.cx1_39.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a39 : PRE_first_tail_x6_r0_body.cx0_39.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b39 : PRE_first_tail_x6_r0_body.cx0_39.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok139 : PRE_first_tail_x6_r0_body.cx1_39.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend39 : PRE_first_tail_x6_r0_body.cx1_39.mlx.pending = PRE_first_tail_x6_r0_body.cx0_39.mlx.pending.map PRE_first_tail_x6_r0_body.kappa39.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh39 : PRE_first_tail_x6_r0_body.cx1_39.mlx.errh = PRE_first_tail_x6_r0_body.cx0_39.mlx.errh.map PRE_first_tail_x6_r0_body.kappa39.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles39 : PRE_first_tail_x6_r0_body.cx1_39.mlx.files = PRE_first_tail_x6_r0_body.cx0_39.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch39 : PRE_first_tail_x6_r0_body.cx1_39.mlx.arch = PRE_first_tail_x6_r0_body.cx0_39.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes39 : PRE_first_tail_x6_r0_body.cx1_39.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_39.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired39 : PRE_first_tail_x6_r0_body.cx1_39.mlx.wired = PRE_first_tail_x6_r0_body.cx0_39.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost39 : PRE_first_tail_x6_r0_body.cx1_39.host = PRE_first_tail_x6_r0_body.cx0_39.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd39`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn039 : PRE_first_tail_x6_r0_body.kd39.n0 = 2705965
kernel_rfl PRE_first_tail_x6_r0_body.ckn139 : PRE_first_tail_x6_r0_body.kd39.n1 = 2707114
kernel_rfl PRE_first_tail_x6_r0_body.ckheap39 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd39.heap).all (fun x => Nat.ble 2705959 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl39 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd39.heap.get (2705959 + j) = nth? PRE_first_tail_x6_r0_body.pl39 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja39 : Nat.ble 2705959 2705959 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn39 : Nat.ble 1751 1751 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD39 : Nat.ble 2705959 PRE_first_tail_x6_r0_body.kd39.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn39 : Nat.ble 18981 PRE_first_tail_x6_r0_body.kd39.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn39 : Nat.ble 16052 PRE_first_tail_x6_r0_body.kd39.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb39 : Nat.ble 18981 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap39 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd39.heap).all (Nat.ble (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd39 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd39.hnd).all (Nat.ble (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode39 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd39.node).all (Nat.ble (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix39 : Conv.FixOld (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa39 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja39) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn39) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD39) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn39) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn39) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb39) PRE_first_tail_x6_r0_body.fheap39 PRE_first_tail_x6_r0_body.fhnd39 PRE_first_tail_x6_r0_body.fnode39
kernel_rfl PRE_first_tail_x6_r0_body.fcxn39 : (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn39 : (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle039 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_39.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_39.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk39 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd39.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A39 : PRE_first_tail_x6_r0_body.cx1_39.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS39.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_39.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O39 : PRE_first_tail_x6_r0_body.cx1_39.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS39.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_39.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N39 : PRE_first_tail_x6_r0_body.cx1_39.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS39.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_39.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I39 : PRE_first_tail_x6_r0_body.cx1_39.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS39.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_39.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd39 : (PRE_first_tail_x6_r0_body.clo39 ++ PRE_first_tail_x6_r0_body.cln39 ++ PRE_first_tail_x6_r0_body.cli39 ++ PRE_first_tail_x6_r0_body.cwS39 ++ PRE_first_tail_x6_r0_body.cnS39 ++ PRE_first_tail_x6_r0_body.ciS39).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW39 : PRE_first_tail_x6_r0_body.cwS39.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo39.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI39 : PRE_first_tail_x6_r0_body.ciS39.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli39.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN39 : PRE_first_tail_x6_r0_body.cnS39.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF39 : PRE_first_tail_x6_r0_body.cln39.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh39 : PRE_first_tail_x6_r0_body.clo39.all (handleOK PRE_first_tail_x6_r0_body.kappa39 PRE_first_tail_x6_r0_body.P39.lo PRE_first_tail_x6_r0_body.cx0_39.mlx PRE_first_tail_x6_r0_body.cx1_39.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo39 : PRE_first_tail_x6_r0_body.clo39.map (fun h => PRE_first_tail_x6_r0_body.cx1_39.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa39.handle h)) = PRE_first_tail_x6_r0_body.clo39.map (fun h => (PRE_first_tail_x6_r0_body.cx0_39.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa39.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok39 : PRE_first_tail_x6_r0_body.clo39.all (objOK PRE_first_tail_x6_r0_body.kappa39 PRE_first_tail_x6_r0_body.P39.NL PRE_first_tail_x6_r0_body.cx0_39.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd39 : PRE_first_tail_x6_r0_body.cln39.all (nodeOKF PRE_first_tail_x6_r0_body.kappa39 PRE_first_tail_x6_r0_body.P39 PRE_first_tail_x6_r0_body.cx0_39.mlx PRE_first_tail_x6_r0_body.cx1_39.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp39 : ((PRE_first_tail_x6_r0_body.cln39.filter (fullB PRE_first_tail_x6_r0_body.P39))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_39.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa39.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln39.filter (fullB PRE_first_tail_x6_r0_body.P39))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_39.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa39.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI39 : incrB PRE_first_tail_x6_r0_body.kd39.nodeF (List.range' 16052 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK39 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd39.node).all (fun k => Nat.ble 16052 k && Nat.blt k 16079) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL39 : (PRE_first_tail_x6_r0_body.cln39.filter (Nat.ble PRE_first_tail_x6_r0_body.P39.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd39.nodeF i) && (Nat.blt i 16079 || Nat.ble PRE_first_tail_x6_r0_body.kd39.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord39 : (PRE_first_tail_x6_r0_body.cln39.filter (Nat.ble PRE_first_tail_x6_r0_body.P39.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd39.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd39.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd39.nodeF j) (PRE_first_tail_x6_r0_body.kd39.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow39 PRE_first_tail_x6_r0_body.cnn139 PRE_first_tail_x6_r0_body.fnordI39 PRE_first_tail_x6_r0_body.fnordK39 PRE_first_tail_x6_r0_body.fnordL39
kernel_rfl PRE_first_tail_x6_r0_body.fi39 : PRE_first_tail_x6_r0_body.cli39.all (pnB PRE_first_tail_x6_r0_body.cx0_39.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii39 : PRE_first_tail_x6_r0_body.cli39.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_39.mlx.items.get (PRE_first_tail_x6_r0_body.kappa39.node k) = (PRE_first_tail_x6_r0_body.cx0_39.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa39.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot39 (clean : Conv.NClean (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P39.NL) (cl : SSt (· < 1769) PRE_first_tail_x6_r0_body.cx0_39.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P39 1769 PRE_first_tail_x6_r0_body.kappa39 PRE_first_tail_x6_r0_body.kd39 PRE_first_tail_x6_r0_body.khinv39 PRE_first_tail_x6_r0_body.kninv39 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx PRE_first_tail_x6_r0_body.cx0_39.mlx PRE_first_tail_x6_r0_body.cx1_39.mlx (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo39 PRE_first_tail_x6_r0_body.cln39 PRE_first_tail_x6_r0_body.cli39 PRE_first_tail_x6_r0_body.cwS39 PRE_first_tail_x6_r0_body.cnS39 PRE_first_tail_x6_r0_body.ciS39 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh039, PRE_first_tail_x6_r0_body.cnh139, PRE_first_tail_x6_r0_body.cnn039, PRE_first_tail_x6_r0_body.cnn139, PRE_first_tail_x6_r0_body.cplo39, PRE_first_tail_x6_r0_body.ccnt39, PRE_first_tail_x6_r0_body.cnband39, PRE_first_tail_x6_r0_body.chbelow39, PRE_first_tail_x6_r0_body.chren39, PRE_first_tail_x6_r0_body.cband39, PRE_first_tail_x6_r0_body.cnh1pos39, PRE_first_tail_x6_r0_body.cnren39, PRE_first_tail_x6_r0_body.cnlow39, PRE_first_tail_x6_r0_body.cabs0a39, PRE_first_tail_x6_r0_body.cabs0b39, PRE_first_tail_x6_r0_body.ctok139, PRE_first_tail_x6_r0_body.cpend39, PRE_first_tail_x6_r0_body.cerrh39, PRE_first_tail_x6_r0_body.cfiles39, PRE_first_tail_x6_r0_body.carch39, PRE_first_tail_x6_r0_body.csizes39, PRE_first_tail_x6_r0_body.cwired39, PRE_first_tail_x6_r0_body.cfix39, clean, PRE_first_tail_x6_r0_body.fcxn39, PRE_first_tail_x6_r0_body.fcnn39, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle039, PRE_first_tail_x6_r0_body.fnk39, PRE_first_tail_x6_r0_body.ckA39, PRE_first_tail_x6_r0_body.cobjsK39, PRE_first_tail_x6_r0_body.cnodesK39, PRE_first_tail_x6_r0_body.citemsK39, PRE_first_tail_x6_r0_body.f1A39, PRE_first_tail_x6_r0_body.f1O39, PRE_first_tail_x6_r0_body.f1N39, PRE_first_tail_x6_r0_body.f1I39, PRE_first_tail_x6_r0_body.fbd39, PRE_first_tail_x6_r0_body.fincW39, PRE_first_tail_x6_r0_body.fincI39, PRE_first_tail_x6_r0_body.fincN39, PRE_first_tail_x6_r0_body.flnF39, PRE_first_tail_x6_r0_body.fh39, PRE_first_tail_x6_r0_body.fo39, PRE_first_tail_x6_r0_body.fok39, PRE_first_tail_x6_r0_body.fnd39, PRE_first_tail_x6_r0_body.fp39, PRE_first_tail_x6_r0_body.fnord39, PRE_first_tail_x6_r0_body.fi39, PRE_first_tail_x6_r0_body.fii39⟩
theorem PRE_first_tail_x6_r0_body.cnshift39 (clean : Conv.NClean (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P39.NL) (cl : SSt (· < 1769) PRE_first_tail_x6_r0_body.cx0_39.mlx) : NShift PRE_first_tail_x6_r0_body.P39 1769 PRE_first_tail_x6_r0_body.kappa39 PRE_first_tail_x6_r0_body.cx0_39 PRE_first_tail_x6_r0_body.cx1_39 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot39 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost39 (compact_a_eq PRE_first_tail_x6_r0_body.ckn039 PRE_first_tail_x6_r0_body.ckn139 PRE_first_tail_x6_r0_body.ckheap39 PRE_first_tail_x6_r0_body.ckpl39)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_39 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s390.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_39 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s390.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_39 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s390.ffi) = some PRE_first_tail_x6_r0_body.fxC_39
kernel_rfl PRE_first_tail_x6_r0_body.okrC_39 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s390.ffi) = some PRE_first_tail_x6_r0_body.krC_39
noncomputable def PRE_first_tail_x6_r0_body.fx0_39 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s392.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_39 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s392.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_39 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s392.ffi) = some PRE_first_tail_x6_r0_body.fx0_39
kernel_rfl PRE_first_tail_x6_r0_body.okr0_39 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s392.ffi) = some PRE_first_tail_x6_r0_body.kr0_39
noncomputable def PRE_first_tail_x6_r0_body.fx1_39 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s391.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_39 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s391.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_39 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s391.ffi) = some PRE_first_tail_x6_r0_body.fx1_39
kernel_rfl PRE_first_tail_x6_r0_body.okr1_39 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s391.ffi) = some PRE_first_tail_x6_r0_body.kr1_39
kernel_rfl PRE_first_tail_x6_r0_body.ff039 : PRE_first_tail_x6_r0_body.fx0_39 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_39 (PRE_first_tail_x6_r0_body.clo39.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_39.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff139 : PRE_first_tail_x6_r0_body.fx1_39 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_39 (PRE_first_tail_x6_r0_body.cwS39.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_39.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck39 : freedLB PRE_first_tail_x6_r0_body.kappa39 PRE_first_tail_x6_r0_body.cx0_39.mlx PRE_first_tail_x6_r0_body.fx0_39 PRE_first_tail_x6_r0_body.fx1_39 PRE_first_tail_x6_r0_body.clo39 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf039 : PRE_first_tail_x6_r0_body.kr0_39.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_39.flags (PRE_first_tail_x6_r0_body.clo39.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_39.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt039 : PRE_first_tail_x6_r0_body.kr0_39.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_39.targs (PRE_first_tail_x6_r0_body.clo39.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_39.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf139 : PRE_first_tail_x6_r0_body.kr1_39.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_39.flags (PRE_first_tail_x6_r0_body.cwS39.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_39.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt139 : PRE_first_tail_x6_r0_body.kr1_39.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_39.targs (PRE_first_tail_x6_r0_body.cwS39.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_39.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck39 : krecLB PRE_first_tail_x6_r0_body.kappa39 1769 PRE_first_tail_x6_r0_body.cx0_39.mlx PRE_first_tail_x6_r0_body.kr0_39 PRE_first_tail_x6_r0_body.kr1_39 PRE_first_tail_x6_r0_body.clo39 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn39 : Nat.ble 1751 1769 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge39 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s391.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s392.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR39 : pendRegB PRE_first_tail_x6_r0_body.kappa39 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe39 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s392.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s391.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift39 (clean : Conv.NClean (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P39.NL) (cl : SSt (· < 1769) PRE_first_tail_x6_r0_body.cx0_39.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_39.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_39.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_39.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s390.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_39.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P39 1769 PRE_first_tail_x6_r0_body.kappa39 PRE_first_tail_x6_r0_body.s392.ffi PRE_first_tail_x6_r0_body.s391.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift39 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue39, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp39 t ht),
    PRE_first_tail_x6_r0_body.cbridge39,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s392.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s391.ffi) (PRE_first_tail_x6_r0_body.cfoot39 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_39 PRE_first_tail_x6_r0_body.ofx1_39 hobjC PRE_first_tail_x6_r0_body.ff039 PRE_first_tail_x6_r0_body.ff139 PRE_first_tail_x6_r0_body.ffck39,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s392.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s391.ffi) (PRE_first_tail_x6_r0_body.cfoot39 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_39 PRE_first_tail_x6_r0_body.okr1_39 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn39) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf039 PRE_first_tail_x6_r0_body.fkt039 PRE_first_tail_x6_r0_body.fkf139 PRE_first_tail_x6_r0_body.fkt139 PRE_first_tail_x6_r0_body.fkck39,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh039 PRE_first_tail_x6_r0_body.cnh139 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe39) PRE_first_tail_x6_r0_body.cpendR39⟩

end Host.Load.Run.Tpl
end

section -- st39/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st39 0
host_stream_state PRE_first_tail_x6_r0_body.st39 1
host_stream_state PRE_first_tail_x6_r0_body.st39 2
host_stream_state PRE_first_tail_x6_r0_body.st39 3
host_stream_state PRE_first_tail_x6_r0_body.st39 4
host_stream_state PRE_first_tail_x6_r0_body.st39 5
end Host.Load.Run.Tpl
end

section -- Site39
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 39 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g39__g40` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s390`, the merged state `PRE_first_tail_x6_r0_body.s391`,
the site template `PRE_first_tail_x6_r0_body.st39` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s392`: the merge.
The footprint's facts are in `SiteF39`, the compaction's in `SiteC39`, `SiteK39`, `SiteNa39`, `SiteNb39`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso39 : PRE_first_tail_x6_r0_body.st39.s0 = { PRE_first_tail_x6_r0_body.s390 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs39 : List Frame := PRE_first_tail_x6_r0_body.s390.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_39 : PRE_first_tail_x6_r0_body.S390.tab.length = 1751
kernel_rfl PRE_first_tail_x6_r0_body.tab0_39 : PRE_first_tail_x6_r0_body.st39.S0.tab = PRE_first_tail_x6_r0_body.S390.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws39 : List Nat := [1645, 1646, 1647, 1648, 1649, 1650, 1651, 1652, 1653, 1654, 1655, 1656, 1657, 1658, 1659, 1660, 1661, 1662, 1663, 1664, 1665, 1666, 1667, 1668, 1669, 1670, 1671, 1672, 1673, 1674, 1675]
kernel_rfl PRE_first_tail_x6_r0_body.fresh39 : (PRE_first_tail_x6_r0_body.S390.tab.all fun e => PRE_first_tail_x6_r0_body.ws39.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S390.oracle.all fun q => PRE_first_tail_x6_r0_body.ws39.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab39 : PRE_first_tail_x6_r0_body.S391.tab = PRE_first_tail_x6_r0_body.S390.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws39
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen39 : PRE_first_tail_x6_r0_body.st39.S5.tab.length - PRE_first_tail_x6_r0_body.st39.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged39`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap39 : PRE_first_tail_x6_r0_body.s391.heap = PRE_first_tail_x6_r0_body.st39.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext39 : PRE_first_tail_x6_r0_body.s391.next = PRE_first_tail_x6_r0_body.st39.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl39 : PRE_first_tail_x6_r0_body.s391.ctl = PRE_first_tail_x6_r0_body.st39.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack39 : PRE_first_tail_x6_r0_body.s391.stack = PRE_first_tail_x6_r0_body.st39.s5.stack ++ PRE_first_tail_x6_r0_body.s390.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs39 : PRE_first_tail_x6_r0_body.s391.jobs = PRE_first_tail_x6_r0_body.st39.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi39 : PRE_first_tail_x6_r0_body.s391.ffi = PRE_first_tail_x6_r0_body.st39.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace39 : PRE_first_tail_x6_r0_body.s391.trace = PRE_first_tail_x6_r0_body.st39.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores39 : PRE_first_tail_x6_r0_body.s391.stores = PRE_first_tail_x6_r0_body.st39.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD39
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 39 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived39 : PRE_first_tail_x6_r0_body.nr39.map (fun r => nth? PRE_first_tail_x6_r0_body.st39.S5.tab r) =
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
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo39 : PRE_first_tail_x6_r0_body.nr39.all (Nat.ble 1751) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj39 : PRE_first_tail_x6_r0_body.cws39.all (fun c => !PRE_first_tail_x6_r0_body.ws39.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ39 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws39 PRE_first_tail_x6_r0_body.crs39 PRE_first_tail_x6_r0_body.ws39

end Host.Load.Run.Tpl
end

section -- st39/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st39`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st39.wrR : List (Nat × Nat) := [(2672398, 2672399), (2705133, 2705134), (2705678, 2705679), (2705934, 2705935)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st39.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st39.s5.heap PRE_first_tail_x6_r0_body.st39.wrR ++ freshOf PRE_first_tail_x6_r0_body.st39.s5.heap PRE_first_tail_x6_r0_body.st39.s0.next PRE_first_tail_x6_r0_body.st39.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st39.wr : List Nat := PRE_first_tail_x6_r0_body.st39.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st39.heapFoot : PRE_first_tail_x6_r0_body.st39.s5.heap = setAll PRE_first_tail_x6_r0_body.st39.s0.heap PRE_first_tail_x6_r0_body.st39.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st39.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st39.s0.next PRE_first_tail_x6_r0_body.st39.s5.next = true
theorem PRE_first_tail_x6_r0_body.st39.grows : PRE_first_tail_x6_r0_body.st39.s0.next ≤ PRE_first_tail_x6_r0_body.st39.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st39.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st39.wh : List Nat := [18961, 18974, 18980, 18981, 18982, 18983, 18984, 18985, 18986, 18987, 18988, 18989, 18990, 18991, 18992, 18993, 18994, 18995, 18996, 18997, 18998, 18999, 19000, 19001, 19002, 19003, 19004, 19005, 19006, 19007, 19008]
def PRE_first_tail_x6_r0_body.st39.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st39.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st39.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st39.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st39.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st39.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st39.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st39.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st39.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st39.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF39
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 39 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB39 : nodupT PRE_first_tail_x6_r0_body.st39.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup39 : PRE_first_tail_x6_r0_body.st39.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB39).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB39 : PRE_first_tail_x6_r0_body.st39.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound39 : ∀ b ∈ PRE_first_tail_x6_r0_body.st39.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB39 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr39 := PRE_first_tail_x6_r0_body.st39.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq39 : PRE_first_tail_x6_r0_body.st39.s5.trace = PRE_first_tail_x6_r0_body.trFr39 ++ PRE_first_tail_x6_r0_body.st39.s0.trace
theorem PRE_first_tail_x6_r0_body.trace39 : ∃ fr, PRE_first_tail_x6_r0_body.st39.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st39.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq39⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide39 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB39 : (PRE_first_tail_x6_r0_body.wide39.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st39.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix39 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide39, WFix Map.id (Present PRE_first_tail_x6_r0_body.st39.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB39 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL39
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 39 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s391`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO39 : PRE_first_tail_x6_r0_body.st39.S0.oracle = PRE_first_tail_x6_r0_body.st39.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B39 : PRE_first_tail_x6_r0_body.st39.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st39.s0.next || (PRE_first_tail_x6_r0_body.st39.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot39 : Conv.StageFoot PRE_first_tail_x6_r0_body.st39.wr PRE_first_tail_x6_r0_body.st39.s0 PRE_first_tail_x6_r0_body.st39.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st39.heapFoot PRE_first_tail_x6_r0_body.wrNodup39 PRE_first_tail_x6_r0_body.wrBound39 PRE_first_tail_x6_r0_body.wr0B39 PRE_first_tail_x6_r0_body.st39.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged39 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st39.F.S → PRE_first_tail_x6_r0_body.st39.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st39.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st39.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs39 PRE_first_tail_x6_r0_body.st39.wr PRE_first_tail_x6_r0_body.s390 PRE_first_tail_x6_r0_body.st39.s5 PRE_first_tail_x6_r0_body.st39.s0
      PRE_first_tail_x6_r0_body.st39.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st39.F FR W stk M ν K PRE_first_tail_x6_r0_body.s391 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso39 PRE_first_tail_x6_r0_body.stFoot39 PRE_first_tail_x6_r0_body.wrNodup39 PRE_first_tail_x6_r0_body.wrBound39 PRE_first_tail_x6_r0_body.trace39 PRE_first_tail_x6_r0_body.mheap39
    PRE_first_tail_x6_r0_body.mnext39 PRE_first_tail_x6_r0_body.mctl39 PRE_first_tail_x6_r0_body.mstack39 PRE_first_tail_x6_r0_body.mjobs39 PRE_first_tail_x6_r0_body.mffi39 PRE_first_tail_x6_r0_body.mtrace39 PRE_first_tail_x6_r0_body.mstores39 h

def PRE_first_tail_x6_r0_body.arrEl39_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE39_2665 : arrOf PRE_first_tail_x6_r0_body.s391 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl39_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA39_2665 : isArrB PRE_first_tail_x6_r0_body.s391 2665 = true
theorem PRE_first_tail_x6_r0_body.arr39_2665 : ∃ o, PRE_first_tail_x6_r0_body.s391.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl39_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE39_2665 PRE_first_tail_x6_r0_body.arrA39_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN39_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl39_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR39_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl39_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN39_2665

def PRE_first_tail_x6_r0_body.arrEl39_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE39_2673467 : arrOf PRE_first_tail_x6_r0_body.s391 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl39_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA39_2673467 : isArrB PRE_first_tail_x6_r0_body.s391 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr39_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s391.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl39_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE39_2673467 PRE_first_tail_x6_r0_body.arrA39_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN39_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl39_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR39_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl39_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN39_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k39 : isArrB PRE_first_tail_x6_r0_body.s391 4910 = false
theorem PRE_first_tail_x6_r0_body.keep39 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s391 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k39 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr39_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl39_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ39
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 39 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s390`, the merged
state `PRE_first_tail_x6_r0_body.s391`, the canonical state `PRE_first_tail_x6_r0_body.s392`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl39 : PRE_first_tail_x6_r0_body.pl39.all (Nat.ble PRE_first_tail_x6_r0_body.s390.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd39 : nodupT PRE_first_tail_x6_r0_body.pl39 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn139 : Nat.ble PRE_first_tail_x6_r0_body.s390.next 2707114 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst39 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s390.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn39 : PRE_first_tail_x6_r0_body.s392.next = PRE_first_tail_x6_r0_body.s390.next + PRE_first_tail_x6_r0_body.pl39.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn39 : PRE_first_tail_x6_r0_body.s391.next = 2707114
kernel_rfl PRE_first_tail_x6_r0_body.zgrow39 : Nat.ble PRE_first_tail_x6_r0_body.s392.next PRE_first_tail_x6_r0_body.s391.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh39 : PRE_first_tail_x6_r0_body.S390.tab.all (fun e => PRE_first_tail_x6_r0_body.cws39.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd39 : nodupT PRE_first_tail_x6_r0_body.cws39 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi39 : PRE_first_tail_x6_r0_body.nr39.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S391.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt39 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s390.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg39_2665 : PRE_first_tail_x6_r0_body.s392.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s392 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk39_2665 : (objOf PRE_first_tail_x6_r0_body.s392 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm39_2665 : PRE_first_tail_x6_r0_body.s391.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa39.obj (objOf PRE_first_tail_x6_r0_body.s392 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s391 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg39_2673467 : PRE_first_tail_x6_r0_body.s392.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s392 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk39_2673467 : (objOf PRE_first_tail_x6_r0_body.s392 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm39_2673467 : PRE_first_tail_x6_r0_body.s391.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa39.obj (objOf PRE_first_tail_x6_r0_body.s392 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s391 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw39_4910 : (PRE_first_tail_x6_r0_body.s392.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw39_2673472 : (PRE_first_tail_x6_r0_body.s392.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw39_2673473 : (PRE_first_tail_x6_r0_body.s392.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd39 : PRE_first_tail_x6_r0_body.cl39.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr39 : PRE_first_tail_x6_r0_body.st39.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s390.next || PRE_first_tail_x6_r0_body.cl39.contains b) = true
def PRE_first_tail_x6_r0_body.zl39 : List Nat := PRE_first_tail_x6_r0_body.cl39.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE39 : PRE_first_tail_x6_r0_body.zl39.map (fun a => PRE_first_tail_x6_r0_body.s391.heap.get (PRE_first_tail_x6_r0_body.kappa39.a a)) = PRE_first_tail_x6_r0_body.zl39.map (fun a => (PRE_first_tail_x6_r0_body.s392.heap.get a).map PRE_first_tail_x6_r0_body.kappa39.hobj)
theorem PRE_first_tail_x6_r0_body.zimg39 : HeapImg PRE_first_tail_x6_r0_body.kappa39 PRE_first_tail_x6_r0_body.s392 PRE_first_tail_x6_r0_body.s391 PRE_first_tail_x6_r0_body.zl39 := PRE_first_tail_x6_r0_body.zimgE39
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl39 : PRE_first_tail_x6_r0_body.s391.ctl = PRE_first_tail_x6_r0_body.kappa39.ctl PRE_first_tail_x6_r0_body.s392.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack39 : PRE_first_tail_x6_r0_body.s391.stack = PRE_first_tail_x6_r0_body.s392.stack.map PRE_first_tail_x6_r0_body.kappa39.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs39 : PRE_first_tail_x6_r0_body.s391.jobs = PRE_first_tail_x6_r0_body.s392.jobs.map PRE_first_tail_x6_r0_body.kappa39.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores39 : PRE_first_tail_x6_r0_body.s391.stores = PRE_first_tail_x6_r0_body.kappa39.stores PRE_first_tail_x6_r0_body.s392.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots39 : checkRootsSupp PRE_first_tail_x6_r0_body.s392 1769 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC39 : PRE_first_tail_x6_r0_body.S390.tab.length + PRE_first_tail_x6_r0_body.cws39.length = 1769
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap39 : PRE_first_tail_x6_r0_body.kappa39 = Conv.Map.compact PRE_first_tail_x6_r0_body.s390.next 2707114 PRE_first_tail_x6_r0_body.S390.tab.length PRE_first_tail_x6_r0_body.pl39 (PRE_first_tail_x6_r0_body.nr39.map NumV.ref) PRE_first_tail_x6_r0_body.kd39.big
  PRE_first_tail_x6_r0_body.kd39.region PRE_first_tail_x6_r0_body.kd39.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin39 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s392.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc39 : Conv.jcleanListB (⟨18984, 16079, 2705965, 1769⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s392 PRE_first_tail_x6_r0_body.cl39 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB39 : noBigRootsP (fun i => !Conv.oldBigB (⟨18984, 16079, 2705965, 1769⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s392.trace PRE_first_tail_x6_r0_body.s392 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm39 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 16052 = true
theorem PRE_first_tail_x6_r0_body.cjcl39 (h : Conv.JClean (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s390) : Conv.JClean (⟨18984, 16079, 2705965, 1769⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s392 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle39)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap39 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd39 a ha)) PRE_first_tail_x6_r0_body.zjc39

end Host.Load.Run.Tpl
end

section -- st39/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st39.bodyLast from PRE_first_tail_x6_r0_body.st39.s4 to PRE_first_tail_x6_r0_body.st39.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st39.F PRE_first_tail_x6_r0_body.st39.s4).run PRE_first_tail_x6_r0_body.st39.S4 = some (PRE_first_tail_x6_r0_body.st39.s5, PRE_first_tail_x6_r0_body.st39.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st39.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st39.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st39.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st39.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st39/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st39.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st39.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st39.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st39.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st39.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st39.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st39.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st39.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st39.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st39.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st39.s0 PRE_first_tail_x6_r0_body.st39.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st39.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st39.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st39.s4 PRE_first_tail_x6_r0_body.st39.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st39/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st39.bodyK0F from PRE_first_tail_x6_r0_body.st39.s0 to PRE_first_tail_x6_r0_body.st39.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st39.F (PRE_first_tail_x6_r0_body.st39.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st39.ks 0).getD 0) PRE_first_tail_x6_r0_body.st39.s0 PRE_first_tail_x6_r0_body.st39.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st39.s1, PRE_first_tail_x6_r0_body.st39.S1)
theorem PRE_first_tail_x6_r0_body.st39.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st39.F (PRE_first_tail_x6_r0_body.st39.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st39.ks 0).getD 0) PRE_first_tail_x6_r0_body.st39.s0 PRE_first_tail_x6_r0_body.st39.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st39.s1, PRE_first_tail_x6_r0_body.st39.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st39.bodyOkLN_ok PRE_first_tail_x6_r0_body.st39.bodyK0F
end Host.Load.Run.Tpl
end

section -- st39/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st39.bodyK1F from PRE_first_tail_x6_r0_body.st39.s1 to PRE_first_tail_x6_r0_body.st39.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st39.F (PRE_first_tail_x6_r0_body.st39.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st39.ks 1).getD 0) PRE_first_tail_x6_r0_body.st39.s1 PRE_first_tail_x6_r0_body.st39.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st39.s2, PRE_first_tail_x6_r0_body.st39.S2)
theorem PRE_first_tail_x6_r0_body.st39.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st39.F (PRE_first_tail_x6_r0_body.st39.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st39.ks 1).getD 0) PRE_first_tail_x6_r0_body.st39.s1 PRE_first_tail_x6_r0_body.st39.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st39.s2, PRE_first_tail_x6_r0_body.st39.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st39.bodyOkLN_ok PRE_first_tail_x6_r0_body.st39.bodyK1F
end Host.Load.Run.Tpl
end

section -- st39/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st39.bodyK2F from PRE_first_tail_x6_r0_body.st39.s2 to PRE_first_tail_x6_r0_body.st39.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st39.F (PRE_first_tail_x6_r0_body.st39.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st39.ks 2).getD 0) PRE_first_tail_x6_r0_body.st39.s2 PRE_first_tail_x6_r0_body.st39.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st39.s3, PRE_first_tail_x6_r0_body.st39.S3)
theorem PRE_first_tail_x6_r0_body.st39.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st39.F (PRE_first_tail_x6_r0_body.st39.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st39.ks 2).getD 0) PRE_first_tail_x6_r0_body.st39.s2 PRE_first_tail_x6_r0_body.st39.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st39.s3, PRE_first_tail_x6_r0_body.st39.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st39.bodyOkLN_ok PRE_first_tail_x6_r0_body.st39.bodyK2F
end Host.Load.Run.Tpl
end

section -- st39/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st39.bodyK3F from PRE_first_tail_x6_r0_body.st39.s3 to PRE_first_tail_x6_r0_body.st39.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st39.F (PRE_first_tail_x6_r0_body.st39.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st39.ks 3).getD 0) PRE_first_tail_x6_r0_body.st39.s3 PRE_first_tail_x6_r0_body.st39.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st39.s4, PRE_first_tail_x6_r0_body.st39.S4)
theorem PRE_first_tail_x6_r0_body.st39.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st39.F (PRE_first_tail_x6_r0_body.st39.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st39.ks 3).getD 0) PRE_first_tail_x6_r0_body.st39.s3 PRE_first_tail_x6_r0_body.st39.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st39.s4, PRE_first_tail_x6_r0_body.st39.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st39.bodyOkLN_ok PRE_first_tail_x6_r0_body.st39.bodyK3F
end Host.Load.Run.Tpl
end

section -- st39/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st39.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st39.F (PRE_first_tail_x6_r0_body.st39.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st39.s0 PRE_first_tail_x6_r0_body.st39.S0 = some (PRE_first_tail_x6_r0_body.st39.s4, PRE_first_tail_x6_r0_body.st39.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st39.F (PRE_first_tail_x6_r0_body.st39.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st39.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st39.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st39.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st39.ks 3).getD 0) PRE_first_tail_x6_r0_body.st39.s0 PRE_first_tail_x6_r0_body.st39.s3 PRE_first_tail_x6_r0_body.st39.s4 PRE_first_tail_x6_r0_body.st39.S0 PRE_first_tail_x6_r0_body.st39.S3 PRE_first_tail_x6_r0_body.st39.S4 (runOk_trans PRE_first_tail_x6_r0_body.st39.F (PRE_first_tail_x6_r0_body.st39.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st39.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st39.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st39.ks 2).getD 0) PRE_first_tail_x6_r0_body.st39.s0 PRE_first_tail_x6_r0_body.st39.s2 PRE_first_tail_x6_r0_body.st39.s3 PRE_first_tail_x6_r0_body.st39.S0 PRE_first_tail_x6_r0_body.st39.S2 PRE_first_tail_x6_r0_body.st39.S3 (runOk_trans PRE_first_tail_x6_r0_body.st39.F (PRE_first_tail_x6_r0_body.st39.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st39.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st39.ks 1).getD 0) PRE_first_tail_x6_r0_body.st39.s0 PRE_first_tail_x6_r0_body.st39.s1 PRE_first_tail_x6_r0_body.st39.s2 PRE_first_tail_x6_r0_body.st39.S0 PRE_first_tail_x6_r0_body.st39.S1 PRE_first_tail_x6_r0_body.st39.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st39.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st39.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st39.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st39.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st39.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st39.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st39.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st39.F (PRE_first_tail_x6_r0_body.st39.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st39.s0
  S0 := PRE_first_tail_x6_r0_body.st39.S0
  s1 := PRE_first_tail_x6_r0_body.st39.s4
  S1 := PRE_first_tail_x6_r0_body.st39.S4
  s2 := PRE_first_tail_x6_r0_body.st39.s5
  S2 := PRE_first_tail_x6_r0_body.st39.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st39.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st39.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st39.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st39.bodyHalt
  last := PRE_first_tail_x6_r0_body.st39.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st39.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC40
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 40 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s400` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa40` into the merged state
`PRE_first_tail_x6_r0_body.s399`. -/

def PRE_first_tail_x6_r0_body.pl40 : List Nat := []
def PRE_first_tail_x6_r0_body.nr40 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd40 : RData :=
  ⟨2706455, 2706457, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18997, 18997, 16092, 16092, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa40 : Map :=
  Conv.Map.compact 2706455 2706457 1790 PRE_first_tail_x6_r0_body.pl40 (PRE_first_tail_x6_r0_body.nr40.map NumV.ref) PRE_first_tail_x6_r0_body.kd40.big
    PRE_first_tail_x6_r0_body.kd40.region PRE_first_tail_x6_r0_body.kd40.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws40 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs40 : List SymE := PRE_first_tail_x6_r0_body.nr40.map fun r => (nth? PRE_first_tail_x6_r0_body.S399.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta40 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws40 PRE_first_tail_x6_r0_body.crs40
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB40 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab40 : PRE_first_tail_x6_r0_body.S400.tab = PRE_first_tail_x6_r0_body.S398.tab ++ PRE_first_tail_x6_r0_body.cws40.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace40 : PRE_first_tail_x6_r0_body.s400.trace = PRE_first_tail_x6_r0_body.s398.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext40 : PRE_first_tail_x6_r0_body.s400.next = 2706455
kernel_rfl PRE_first_tail_x6_r0_body.ccounters40 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx.nnext) = (18997, 16092)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue40 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s399.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa40.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp40 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx.tokens.all (bSN 1790) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean40 : Conv.cleanListB 18997 131072 (fun r => Nat.ble 75988 r) PRE_first_tail_x6_r0_body.s400
    (PRE_first_tail_x6_r0_body.wrB40 ++ (List.range 0).map (2706455 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs40 : bigsOutB 18997 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK40
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl40`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl40 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo40 : List Nat := []
def PRE_first_tail_x6_r0_body.cln40 : List Nat := []
def PRE_first_tail_x6_r0_body.cli40 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap40 : PRE_first_tail_x6_r0_body.s400.heap = Stage.setAll PRE_first_tail_x6_r0_body.s398.heap (PRE_first_tail_x6_r0_body.cl40.filterMap fun a => (PRE_first_tail_x6_r0_body.s400.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe40 : Nat.ble PRE_first_tail_x6_r0_body.s398.next PRE_first_tail_x6_r0_body.s400.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP40 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s398 PRE_first_tail_x6_r0_body.s400 PRE_first_tail_x6_r0_body.cl40 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp40 : Conv.suppListB PRE_first_tail_x6_r0_body.s400 1790 PRE_first_tail_x6_r0_body.cl40 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound40 : Conv.boundListB PRE_first_tail_x6_r0_body.s400 PRE_first_tail_x6_r0_body.cl40 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK40 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln40.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK40 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo40.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK40 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli40.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst40 : Conv.sstListB 1790 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx PRE_first_tail_x6_r0_body.cln40 PRE_first_tail_x6_r0_body.clo40 PRE_first_tail_x6_r0_body.cli40 = true

end Host.Load.Run.Tpl
end

section -- SiteCl40
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA40 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo40.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd40 : (PRE_first_tail_x6_r0_body.clo40 ++ PRE_first_tail_x6_r0_body.cln40 ++ PRE_first_tail_x6_r0_body.cli40).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle40 : Conv.Cnt.leB (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck40 : Conv.ncleanListB (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx PRE_first_tail_x6_r0_body.clo40 PRE_first_tail_x6_r0_body.cln40 PRE_first_tail_x6_r0_body.cli40 = true
theorem PRE_first_tail_x6_r0_body.cncl40 (h : Conv.NClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx) : Conv.NClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle40 PRE_first_tail_x6_r0_body.ckA40 PRE_first_tail_x6_r0_body.cobjsK40 PRE_first_tail_x6_r0_body.cnodesK40 PRE_first_tail_x6_r0_body.citemsK40 PRE_first_tail_x6_r0_body.cbd40 PRE_first_tail_x6_r0_body.cck40

end Host.Load.Run.Tpl
end

section -- SiteS40
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 40 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc40 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P40 : LoadP := PRE_first_tail_x6_r0_body.Pc40.raise 16092
kernel_rfl PRE_first_tail_x6_r0_body.craise40 : Nat.ble PRE_first_tail_x6_r0_body.Pc40.N0 16092 = true
theorem PRE_first_tail_x6_r0_body.raised40 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc40 PRE_first_tail_x6_r0_body.P40 :=
  .inr ⟨16092, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise40, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_40 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_40 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s399.ffi)
def PRE_first_tail_x6_r0_body.khinv40 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv40 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS40 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS40 : List Nat := List.range' 16092 0
def PRE_first_tail_x6_r0_body.ciS40 : List Nat := [] ++ List.range' 16092 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh040 : PRE_first_tail_x6_r0_body.kd40.nh0 = PRE_first_tail_x6_r0_body.cx0_40.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh140 : PRE_first_tail_x6_r0_body.kd40.nh1 = PRE_first_tail_x6_r0_body.cx1_40.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn040 : PRE_first_tail_x6_r0_body.kd40.nn0 = PRE_first_tail_x6_r0_body.cx0_40.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn140 : PRE_first_tail_x6_r0_body.kd40.nn1 = PRE_first_tail_x6_r0_body.cx1_40.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo40 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P40.lo && Nat.ble PRE_first_tail_x6_r0_body.P40.lo PRE_first_tail_x6_r0_body.cx0_40.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P40.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P40.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt40 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_40.mlx.next PRE_first_tail_x6_r0_body.cx1_40.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_40.mlx.nnext PRE_first_tail_x6_r0_body.cx1_40.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband40 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P40.NL && Nat.ble PRE_first_tail_x6_r0_body.P40.NL PRE_first_tail_x6_r0_body.P40.N0 && Nat.ble PRE_first_tail_x6_r0_body.P40.N0 PRE_first_tail_x6_r0_body.cx0_40.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow40 : PRE_first_tail_x6_r0_body.kd40.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren40 : checkRenG PRE_first_tail_x6_r0_body.kd40.hnd PRE_first_tail_x6_r0_body.khinv40 (phB PRE_first_tail_x6_r0_body.cx0_40.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband40 : PRE_first_tail_x6_r0_body.kd40.checkBand PRE_first_tail_x6_r0_body.P40.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos40 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd40.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren40 : checkRenG PRE_first_tail_x6_r0_body.kd40.node PRE_first_tail_x6_r0_body.kninv40 (pnB PRE_first_tail_x6_r0_body.cx0_40.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow40 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd40.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P40.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd40.nodeF j) PRE_first_tail_x6_r0_body.cx1_40.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a40 : PRE_first_tail_x6_r0_body.cx0_40.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b40 : PRE_first_tail_x6_r0_body.cx0_40.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok140 : PRE_first_tail_x6_r0_body.cx1_40.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend40 : PRE_first_tail_x6_r0_body.cx1_40.mlx.pending = PRE_first_tail_x6_r0_body.cx0_40.mlx.pending.map PRE_first_tail_x6_r0_body.kappa40.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh40 : PRE_first_tail_x6_r0_body.cx1_40.mlx.errh = PRE_first_tail_x6_r0_body.cx0_40.mlx.errh.map PRE_first_tail_x6_r0_body.kappa40.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles40 : PRE_first_tail_x6_r0_body.cx1_40.mlx.files = PRE_first_tail_x6_r0_body.cx0_40.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch40 : PRE_first_tail_x6_r0_body.cx1_40.mlx.arch = PRE_first_tail_x6_r0_body.cx0_40.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes40 : PRE_first_tail_x6_r0_body.cx1_40.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_40.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired40 : PRE_first_tail_x6_r0_body.cx1_40.mlx.wired = PRE_first_tail_x6_r0_body.cx0_40.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost40 : PRE_first_tail_x6_r0_body.cx1_40.host = PRE_first_tail_x6_r0_body.cx0_40.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd40`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn040 : PRE_first_tail_x6_r0_body.kd40.n0 = 2706455
kernel_rfl PRE_first_tail_x6_r0_body.ckn140 : PRE_first_tail_x6_r0_body.kd40.n1 = 2706457
kernel_rfl PRE_first_tail_x6_r0_body.ckheap40 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd40.heap).all (fun x => Nat.ble 2706455 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl40 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd40.heap.get (2706455 + j) = nth? PRE_first_tail_x6_r0_body.pl40 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja40 : Nat.ble 2706455 2706455 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn40 : Nat.ble 1790 1790 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD40 : Nat.ble 2706455 PRE_first_tail_x6_r0_body.kd40.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn40 : Nat.ble 18997 PRE_first_tail_x6_r0_body.kd40.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn40 : Nat.ble 16092 PRE_first_tail_x6_r0_body.kd40.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb40 : Nat.ble 18997 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap40 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd40.heap).all (Nat.ble (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd40 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd40.hnd).all (Nat.ble (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode40 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd40.node).all (Nat.ble (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix40 : Conv.FixOld (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa40 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja40) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn40) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD40) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn40) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn40) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb40) PRE_first_tail_x6_r0_body.fheap40 PRE_first_tail_x6_r0_body.fhnd40 PRE_first_tail_x6_r0_body.fnode40
kernel_rfl PRE_first_tail_x6_r0_body.fcxn40 : (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn40 : (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle040 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_40.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_40.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk40 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd40.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A40 : PRE_first_tail_x6_r0_body.cx1_40.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS40.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_40.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O40 : PRE_first_tail_x6_r0_body.cx1_40.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS40.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_40.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N40 : PRE_first_tail_x6_r0_body.cx1_40.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS40.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_40.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I40 : PRE_first_tail_x6_r0_body.cx1_40.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS40.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_40.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd40 : (PRE_first_tail_x6_r0_body.clo40 ++ PRE_first_tail_x6_r0_body.cln40 ++ PRE_first_tail_x6_r0_body.cli40 ++ PRE_first_tail_x6_r0_body.cwS40 ++ PRE_first_tail_x6_r0_body.cnS40 ++ PRE_first_tail_x6_r0_body.ciS40).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW40 : PRE_first_tail_x6_r0_body.cwS40.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo40.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI40 : PRE_first_tail_x6_r0_body.ciS40.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli40.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN40 : PRE_first_tail_x6_r0_body.cnS40.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF40 : PRE_first_tail_x6_r0_body.cln40.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh40 : PRE_first_tail_x6_r0_body.clo40.all (handleOK PRE_first_tail_x6_r0_body.kappa40 PRE_first_tail_x6_r0_body.P40.lo PRE_first_tail_x6_r0_body.cx0_40.mlx PRE_first_tail_x6_r0_body.cx1_40.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo40 : PRE_first_tail_x6_r0_body.clo40.map (fun h => PRE_first_tail_x6_r0_body.cx1_40.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa40.handle h)) = PRE_first_tail_x6_r0_body.clo40.map (fun h => (PRE_first_tail_x6_r0_body.cx0_40.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa40.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok40 : PRE_first_tail_x6_r0_body.clo40.all (objOK PRE_first_tail_x6_r0_body.kappa40 PRE_first_tail_x6_r0_body.P40.NL PRE_first_tail_x6_r0_body.cx0_40.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd40 : PRE_first_tail_x6_r0_body.cln40.all (nodeOKF PRE_first_tail_x6_r0_body.kappa40 PRE_first_tail_x6_r0_body.P40 PRE_first_tail_x6_r0_body.cx0_40.mlx PRE_first_tail_x6_r0_body.cx1_40.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp40 : ((PRE_first_tail_x6_r0_body.cln40.filter (fullB PRE_first_tail_x6_r0_body.P40))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_40.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa40.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln40.filter (fullB PRE_first_tail_x6_r0_body.P40))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_40.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa40.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI40 : incrB PRE_first_tail_x6_r0_body.kd40.nodeF (List.range' 16092 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK40 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd40.node).all (fun k => Nat.ble 16092 k && Nat.blt k 16092) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL40 : (PRE_first_tail_x6_r0_body.cln40.filter (Nat.ble PRE_first_tail_x6_r0_body.P40.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd40.nodeF i) && (Nat.blt i 16092 || Nat.ble PRE_first_tail_x6_r0_body.kd40.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord40 : (PRE_first_tail_x6_r0_body.cln40.filter (Nat.ble PRE_first_tail_x6_r0_body.P40.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd40.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd40.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd40.nodeF j) (PRE_first_tail_x6_r0_body.kd40.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow40 PRE_first_tail_x6_r0_body.cnn140 PRE_first_tail_x6_r0_body.fnordI40 PRE_first_tail_x6_r0_body.fnordK40 PRE_first_tail_x6_r0_body.fnordL40
kernel_rfl PRE_first_tail_x6_r0_body.fi40 : PRE_first_tail_x6_r0_body.cli40.all (pnB PRE_first_tail_x6_r0_body.cx0_40.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii40 : PRE_first_tail_x6_r0_body.cli40.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_40.mlx.items.get (PRE_first_tail_x6_r0_body.kappa40.node k) = (PRE_first_tail_x6_r0_body.cx0_40.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa40.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot40 (clean : Conv.NClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P40.NL) (cl : SSt (· < 1790) PRE_first_tail_x6_r0_body.cx0_40.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P40 1790 PRE_first_tail_x6_r0_body.kappa40 PRE_first_tail_x6_r0_body.kd40 PRE_first_tail_x6_r0_body.khinv40 PRE_first_tail_x6_r0_body.kninv40 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx PRE_first_tail_x6_r0_body.cx0_40.mlx PRE_first_tail_x6_r0_body.cx1_40.mlx (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo40 PRE_first_tail_x6_r0_body.cln40 PRE_first_tail_x6_r0_body.cli40 PRE_first_tail_x6_r0_body.cwS40 PRE_first_tail_x6_r0_body.cnS40 PRE_first_tail_x6_r0_body.ciS40 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh040, PRE_first_tail_x6_r0_body.cnh140, PRE_first_tail_x6_r0_body.cnn040, PRE_first_tail_x6_r0_body.cnn140, PRE_first_tail_x6_r0_body.cplo40, PRE_first_tail_x6_r0_body.ccnt40, PRE_first_tail_x6_r0_body.cnband40, PRE_first_tail_x6_r0_body.chbelow40, PRE_first_tail_x6_r0_body.chren40, PRE_first_tail_x6_r0_body.cband40, PRE_first_tail_x6_r0_body.cnh1pos40, PRE_first_tail_x6_r0_body.cnren40, PRE_first_tail_x6_r0_body.cnlow40, PRE_first_tail_x6_r0_body.cabs0a40, PRE_first_tail_x6_r0_body.cabs0b40, PRE_first_tail_x6_r0_body.ctok140, PRE_first_tail_x6_r0_body.cpend40, PRE_first_tail_x6_r0_body.cerrh40, PRE_first_tail_x6_r0_body.cfiles40, PRE_first_tail_x6_r0_body.carch40, PRE_first_tail_x6_r0_body.csizes40, PRE_first_tail_x6_r0_body.cwired40, PRE_first_tail_x6_r0_body.cfix40, clean, PRE_first_tail_x6_r0_body.fcxn40, PRE_first_tail_x6_r0_body.fcnn40, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle040, PRE_first_tail_x6_r0_body.fnk40, PRE_first_tail_x6_r0_body.ckA40, PRE_first_tail_x6_r0_body.cobjsK40, PRE_first_tail_x6_r0_body.cnodesK40, PRE_first_tail_x6_r0_body.citemsK40, PRE_first_tail_x6_r0_body.f1A40, PRE_first_tail_x6_r0_body.f1O40, PRE_first_tail_x6_r0_body.f1N40, PRE_first_tail_x6_r0_body.f1I40, PRE_first_tail_x6_r0_body.fbd40, PRE_first_tail_x6_r0_body.fincW40, PRE_first_tail_x6_r0_body.fincI40, PRE_first_tail_x6_r0_body.fincN40, PRE_first_tail_x6_r0_body.flnF40, PRE_first_tail_x6_r0_body.fh40, PRE_first_tail_x6_r0_body.fo40, PRE_first_tail_x6_r0_body.fok40, PRE_first_tail_x6_r0_body.fnd40, PRE_first_tail_x6_r0_body.fp40, PRE_first_tail_x6_r0_body.fnord40, PRE_first_tail_x6_r0_body.fi40, PRE_first_tail_x6_r0_body.fii40⟩
theorem PRE_first_tail_x6_r0_body.cnshift40 (clean : Conv.NClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P40.NL) (cl : SSt (· < 1790) PRE_first_tail_x6_r0_body.cx0_40.mlx) : NShift PRE_first_tail_x6_r0_body.P40 1790 PRE_first_tail_x6_r0_body.kappa40 PRE_first_tail_x6_r0_body.cx0_40 PRE_first_tail_x6_r0_body.cx1_40 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot40 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost40 (compact_a_eq PRE_first_tail_x6_r0_body.ckn040 PRE_first_tail_x6_r0_body.ckn140 PRE_first_tail_x6_r0_body.ckheap40 PRE_first_tail_x6_r0_body.ckpl40)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_40 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s398.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_40 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s398.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_40 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s398.ffi) = some PRE_first_tail_x6_r0_body.fxC_40
kernel_rfl PRE_first_tail_x6_r0_body.okrC_40 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s398.ffi) = some PRE_first_tail_x6_r0_body.krC_40
noncomputable def PRE_first_tail_x6_r0_body.fx0_40 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s400.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_40 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s400.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_40 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s400.ffi) = some PRE_first_tail_x6_r0_body.fx0_40
kernel_rfl PRE_first_tail_x6_r0_body.okr0_40 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s400.ffi) = some PRE_first_tail_x6_r0_body.kr0_40
noncomputable def PRE_first_tail_x6_r0_body.fx1_40 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s399.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_40 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s399.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_40 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s399.ffi) = some PRE_first_tail_x6_r0_body.fx1_40
kernel_rfl PRE_first_tail_x6_r0_body.okr1_40 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s399.ffi) = some PRE_first_tail_x6_r0_body.kr1_40
kernel_rfl PRE_first_tail_x6_r0_body.ff040 : PRE_first_tail_x6_r0_body.fx0_40 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_40 (PRE_first_tail_x6_r0_body.clo40.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_40.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff140 : PRE_first_tail_x6_r0_body.fx1_40 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_40 (PRE_first_tail_x6_r0_body.cwS40.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_40.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck40 : freedLB PRE_first_tail_x6_r0_body.kappa40 PRE_first_tail_x6_r0_body.cx0_40.mlx PRE_first_tail_x6_r0_body.fx0_40 PRE_first_tail_x6_r0_body.fx1_40 PRE_first_tail_x6_r0_body.clo40 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf040 : PRE_first_tail_x6_r0_body.kr0_40.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_40.flags (PRE_first_tail_x6_r0_body.clo40.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_40.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt040 : PRE_first_tail_x6_r0_body.kr0_40.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_40.targs (PRE_first_tail_x6_r0_body.clo40.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_40.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf140 : PRE_first_tail_x6_r0_body.kr1_40.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_40.flags (PRE_first_tail_x6_r0_body.cwS40.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_40.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt140 : PRE_first_tail_x6_r0_body.kr1_40.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_40.targs (PRE_first_tail_x6_r0_body.cwS40.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_40.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck40 : krecLB PRE_first_tail_x6_r0_body.kappa40 1790 PRE_first_tail_x6_r0_body.cx0_40.mlx PRE_first_tail_x6_r0_body.kr0_40 PRE_first_tail_x6_r0_body.kr1_40 PRE_first_tail_x6_r0_body.clo40 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn40 : Nat.ble 1790 1790 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge40 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s399.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s400.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR40 : pendRegB PRE_first_tail_x6_r0_body.kappa40 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe40 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s400.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s399.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift40 (clean : Conv.NClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P40.NL) (cl : SSt (· < 1790) PRE_first_tail_x6_r0_body.cx0_40.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_40.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_40.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_40.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s398.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_40.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P40 1790 PRE_first_tail_x6_r0_body.kappa40 PRE_first_tail_x6_r0_body.s400.ffi PRE_first_tail_x6_r0_body.s399.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift40 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue40, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp40 t ht),
    PRE_first_tail_x6_r0_body.cbridge40,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s400.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s399.ffi) (PRE_first_tail_x6_r0_body.cfoot40 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_40 PRE_first_tail_x6_r0_body.ofx1_40 hobjC PRE_first_tail_x6_r0_body.ff040 PRE_first_tail_x6_r0_body.ff140 PRE_first_tail_x6_r0_body.ffck40,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s400.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s399.ffi) (PRE_first_tail_x6_r0_body.cfoot40 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_40 PRE_first_tail_x6_r0_body.okr1_40 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn40) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf040 PRE_first_tail_x6_r0_body.fkt040 PRE_first_tail_x6_r0_body.fkf140 PRE_first_tail_x6_r0_body.fkt140 PRE_first_tail_x6_r0_body.fkck40,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh040 PRE_first_tail_x6_r0_body.cnh140 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe40) PRE_first_tail_x6_r0_body.cpendR40⟩

end Host.Load.Run.Tpl
end

section -- st40/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st40 0
host_stream_state PRE_first_tail_x6_r0_body.st40 1
host_stream_state PRE_first_tail_x6_r0_body.st40 2
end Host.Load.Run.Tpl
end

section -- Site40
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 40 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g40__g41` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s398`, the merged state `PRE_first_tail_x6_r0_body.s399`,
the site template `PRE_first_tail_x6_r0_body.st40` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s400`: the merge.
The footprint's facts are in `SiteF40`, the compaction's in `SiteC40`, `SiteK40`, `SiteNa40`, `SiteNb40`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso40 : PRE_first_tail_x6_r0_body.st40.s0 = { PRE_first_tail_x6_r0_body.s398 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs40 : List Frame := PRE_first_tail_x6_r0_body.s398.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_40 : PRE_first_tail_x6_r0_body.S398.tab.length = 1790
kernel_rfl PRE_first_tail_x6_r0_body.tab0_40 : PRE_first_tail_x6_r0_body.st40.S0.tab = PRE_first_tail_x6_r0_body.S398.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws40 : List Nat := [1694, 1695]
kernel_rfl PRE_first_tail_x6_r0_body.fresh40 : (PRE_first_tail_x6_r0_body.S398.tab.all fun e => PRE_first_tail_x6_r0_body.ws40.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S398.oracle.all fun q => PRE_first_tail_x6_r0_body.ws40.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab40 : PRE_first_tail_x6_r0_body.S399.tab = PRE_first_tail_x6_r0_body.S398.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws40
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen40 : PRE_first_tail_x6_r0_body.st40.S2.tab.length - PRE_first_tail_x6_r0_body.st40.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged40`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap40 : PRE_first_tail_x6_r0_body.s399.heap = PRE_first_tail_x6_r0_body.st40.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext40 : PRE_first_tail_x6_r0_body.s399.next = PRE_first_tail_x6_r0_body.st40.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl40 : PRE_first_tail_x6_r0_body.s399.ctl = PRE_first_tail_x6_r0_body.st40.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack40 : PRE_first_tail_x6_r0_body.s399.stack = PRE_first_tail_x6_r0_body.st40.s2.stack ++ PRE_first_tail_x6_r0_body.s398.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs40 : PRE_first_tail_x6_r0_body.s399.jobs = PRE_first_tail_x6_r0_body.st40.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi40 : PRE_first_tail_x6_r0_body.s399.ffi = PRE_first_tail_x6_r0_body.st40.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace40 : PRE_first_tail_x6_r0_body.s399.trace = PRE_first_tail_x6_r0_body.st40.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores40 : PRE_first_tail_x6_r0_body.s399.stores = PRE_first_tail_x6_r0_body.st40.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD40
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 40 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived40 : PRE_first_tail_x6_r0_body.nr40.map (fun r => nth? PRE_first_tail_x6_r0_body.st40.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo40 : PRE_first_tail_x6_r0_body.nr40.all (Nat.ble 1790) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj40 : PRE_first_tail_x6_r0_body.cws40.all (fun c => !PRE_first_tail_x6_r0_body.ws40.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ40 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws40 PRE_first_tail_x6_r0_body.crs40 PRE_first_tail_x6_r0_body.ws40

end Host.Load.Run.Tpl
end

section -- st40/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st40`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st40.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st40.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st40.s2.heap PRE_first_tail_x6_r0_body.st40.wrR ++ freshOf PRE_first_tail_x6_r0_body.st40.s2.heap PRE_first_tail_x6_r0_body.st40.s0.next PRE_first_tail_x6_r0_body.st40.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st40.wr : List Nat := PRE_first_tail_x6_r0_body.st40.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st40.heapFoot : PRE_first_tail_x6_r0_body.st40.s2.heap = setAll PRE_first_tail_x6_r0_body.st40.s0.heap PRE_first_tail_x6_r0_body.st40.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st40.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st40.s0.next PRE_first_tail_x6_r0_body.st40.s2.next = true
theorem PRE_first_tail_x6_r0_body.st40.grows : PRE_first_tail_x6_r0_body.st40.s0.next ≤ PRE_first_tail_x6_r0_body.st40.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st40.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st40.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st40.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st40.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st40.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st40.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st40.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st40.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st40.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st40.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st40.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st40.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF40
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 40 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB40 : nodupT PRE_first_tail_x6_r0_body.st40.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup40 : PRE_first_tail_x6_r0_body.st40.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB40).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB40 : PRE_first_tail_x6_r0_body.st40.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound40 : ∀ b ∈ PRE_first_tail_x6_r0_body.st40.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB40 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr40 := PRE_first_tail_x6_r0_body.st40.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq40 : PRE_first_tail_x6_r0_body.st40.s2.trace = PRE_first_tail_x6_r0_body.trFr40 ++ PRE_first_tail_x6_r0_body.st40.s0.trace
theorem PRE_first_tail_x6_r0_body.trace40 : ∃ fr, PRE_first_tail_x6_r0_body.st40.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st40.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq40⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide40 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB40 : (PRE_first_tail_x6_r0_body.wide40.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st40.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix40 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide40, WFix Map.id (Present PRE_first_tail_x6_r0_body.st40.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB40 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL40
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 40 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s399`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO40 : PRE_first_tail_x6_r0_body.st40.S0.oracle = PRE_first_tail_x6_r0_body.st40.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B40 : PRE_first_tail_x6_r0_body.st40.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st40.s0.next || (PRE_first_tail_x6_r0_body.st40.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot40 : Conv.StageFoot PRE_first_tail_x6_r0_body.st40.wr PRE_first_tail_x6_r0_body.st40.s0 PRE_first_tail_x6_r0_body.st40.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st40.heapFoot PRE_first_tail_x6_r0_body.wrNodup40 PRE_first_tail_x6_r0_body.wrBound40 PRE_first_tail_x6_r0_body.wr0B40 PRE_first_tail_x6_r0_body.st40.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged40 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st40.F.S → PRE_first_tail_x6_r0_body.st40.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st40.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st40.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs40 PRE_first_tail_x6_r0_body.st40.wr PRE_first_tail_x6_r0_body.s398 PRE_first_tail_x6_r0_body.st40.s2 PRE_first_tail_x6_r0_body.st40.s0
      PRE_first_tail_x6_r0_body.st40.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st40.F FR W stk M ν K PRE_first_tail_x6_r0_body.s399 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso40 PRE_first_tail_x6_r0_body.stFoot40 PRE_first_tail_x6_r0_body.wrNodup40 PRE_first_tail_x6_r0_body.wrBound40 PRE_first_tail_x6_r0_body.trace40 PRE_first_tail_x6_r0_body.mheap40
    PRE_first_tail_x6_r0_body.mnext40 PRE_first_tail_x6_r0_body.mctl40 PRE_first_tail_x6_r0_body.mstack40 PRE_first_tail_x6_r0_body.mjobs40 PRE_first_tail_x6_r0_body.mffi40 PRE_first_tail_x6_r0_body.mtrace40 PRE_first_tail_x6_r0_body.mstores40 h

def PRE_first_tail_x6_r0_body.arrEl40_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE40_2665 : arrOf PRE_first_tail_x6_r0_body.s399 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl40_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA40_2665 : isArrB PRE_first_tail_x6_r0_body.s399 2665 = true
theorem PRE_first_tail_x6_r0_body.arr40_2665 : ∃ o, PRE_first_tail_x6_r0_body.s399.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl40_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE40_2665 PRE_first_tail_x6_r0_body.arrA40_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN40_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl40_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR40_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl40_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN40_2665

def PRE_first_tail_x6_r0_body.arrEl40_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE40_2673467 : arrOf PRE_first_tail_x6_r0_body.s399 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl40_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA40_2673467 : isArrB PRE_first_tail_x6_r0_body.s399 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr40_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s399.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl40_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE40_2673467 PRE_first_tail_x6_r0_body.arrA40_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN40_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl40_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR40_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl40_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN40_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k40 : isArrB PRE_first_tail_x6_r0_body.s399 4910 = false
theorem PRE_first_tail_x6_r0_body.keep40 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s399 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k40 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr40_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl40_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ40
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 40 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s398`, the merged
state `PRE_first_tail_x6_r0_body.s399`, the canonical state `PRE_first_tail_x6_r0_body.s400`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl40 : PRE_first_tail_x6_r0_body.pl40.all (Nat.ble PRE_first_tail_x6_r0_body.s398.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd40 : nodupT PRE_first_tail_x6_r0_body.pl40 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn140 : Nat.ble PRE_first_tail_x6_r0_body.s398.next 2706457 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst40 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s398.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn40 : PRE_first_tail_x6_r0_body.s400.next = PRE_first_tail_x6_r0_body.s398.next + PRE_first_tail_x6_r0_body.pl40.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn40 : PRE_first_tail_x6_r0_body.s399.next = 2706457
kernel_rfl PRE_first_tail_x6_r0_body.zgrow40 : Nat.ble PRE_first_tail_x6_r0_body.s400.next PRE_first_tail_x6_r0_body.s399.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh40 : PRE_first_tail_x6_r0_body.S398.tab.all (fun e => PRE_first_tail_x6_r0_body.cws40.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd40 : nodupT PRE_first_tail_x6_r0_body.cws40 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi40 : PRE_first_tail_x6_r0_body.nr40.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S399.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt40 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s398.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg40_2665 : PRE_first_tail_x6_r0_body.s400.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s400 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk40_2665 : (objOf PRE_first_tail_x6_r0_body.s400 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm40_2665 : PRE_first_tail_x6_r0_body.s399.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa40.obj (objOf PRE_first_tail_x6_r0_body.s400 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s399 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg40_2673467 : PRE_first_tail_x6_r0_body.s400.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s400 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk40_2673467 : (objOf PRE_first_tail_x6_r0_body.s400 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm40_2673467 : PRE_first_tail_x6_r0_body.s399.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa40.obj (objOf PRE_first_tail_x6_r0_body.s400 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s399 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw40_4910 : (PRE_first_tail_x6_r0_body.s400.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw40_2673472 : (PRE_first_tail_x6_r0_body.s400.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw40_2673473 : (PRE_first_tail_x6_r0_body.s400.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd40 : PRE_first_tail_x6_r0_body.cl40.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr40 : PRE_first_tail_x6_r0_body.st40.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s398.next || PRE_first_tail_x6_r0_body.cl40.contains b) = true
def PRE_first_tail_x6_r0_body.zl40 : List Nat := PRE_first_tail_x6_r0_body.cl40.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE40 : PRE_first_tail_x6_r0_body.zl40.map (fun a => PRE_first_tail_x6_r0_body.s399.heap.get (PRE_first_tail_x6_r0_body.kappa40.a a)) = PRE_first_tail_x6_r0_body.zl40.map (fun a => (PRE_first_tail_x6_r0_body.s400.heap.get a).map PRE_first_tail_x6_r0_body.kappa40.hobj)
theorem PRE_first_tail_x6_r0_body.zimg40 : HeapImg PRE_first_tail_x6_r0_body.kappa40 PRE_first_tail_x6_r0_body.s400 PRE_first_tail_x6_r0_body.s399 PRE_first_tail_x6_r0_body.zl40 := PRE_first_tail_x6_r0_body.zimgE40
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl40 : PRE_first_tail_x6_r0_body.s399.ctl = PRE_first_tail_x6_r0_body.kappa40.ctl PRE_first_tail_x6_r0_body.s400.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack40 : PRE_first_tail_x6_r0_body.s399.stack = PRE_first_tail_x6_r0_body.s400.stack.map PRE_first_tail_x6_r0_body.kappa40.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs40 : PRE_first_tail_x6_r0_body.s399.jobs = PRE_first_tail_x6_r0_body.s400.jobs.map PRE_first_tail_x6_r0_body.kappa40.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores40 : PRE_first_tail_x6_r0_body.s399.stores = PRE_first_tail_x6_r0_body.kappa40.stores PRE_first_tail_x6_r0_body.s400.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots40 : checkRootsSupp PRE_first_tail_x6_r0_body.s400 1790 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC40 : PRE_first_tail_x6_r0_body.S398.tab.length + PRE_first_tail_x6_r0_body.cws40.length = 1790
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap40 : PRE_first_tail_x6_r0_body.kappa40 = Conv.Map.compact PRE_first_tail_x6_r0_body.s398.next 2706457 PRE_first_tail_x6_r0_body.S398.tab.length PRE_first_tail_x6_r0_body.pl40 (PRE_first_tail_x6_r0_body.nr40.map NumV.ref) PRE_first_tail_x6_r0_body.kd40.big
  PRE_first_tail_x6_r0_body.kd40.region PRE_first_tail_x6_r0_body.kd40.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin40 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s400.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc40 : Conv.jcleanListB (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s400 PRE_first_tail_x6_r0_body.cl40 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB40 : noBigRootsP (fun i => !Conv.oldBigB (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s400.trace PRE_first_tail_x6_r0_body.s400 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm40 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 16092 = true
theorem PRE_first_tail_x6_r0_body.cjcl40 (h : Conv.JClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s398) : Conv.JClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s400 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle40)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap40 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd40 a ha)) PRE_first_tail_x6_r0_body.zjc40

end Host.Load.Run.Tpl
end

section -- st40/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st40.bodyLast from PRE_first_tail_x6_r0_body.st40.s1 to PRE_first_tail_x6_r0_body.st40.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st40.F PRE_first_tail_x6_r0_body.st40.s1).run PRE_first_tail_x6_r0_body.st40.S1 = some (PRE_first_tail_x6_r0_body.st40.s2, PRE_first_tail_x6_r0_body.st40.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st40.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st40.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st40.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st40.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st40/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st40.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st40.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st40.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st40.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st40.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st40.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st40.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st40.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st40.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st40.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st40.s0 PRE_first_tail_x6_r0_body.st40.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st40.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st40.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st40.s1 PRE_first_tail_x6_r0_body.st40.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st40/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st40.bodyK0F from PRE_first_tail_x6_r0_body.st40.s0 to PRE_first_tail_x6_r0_body.st40.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st40.F (PRE_first_tail_x6_r0_body.st40.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st40.ks 0).getD 0) PRE_first_tail_x6_r0_body.st40.s0 PRE_first_tail_x6_r0_body.st40.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st40.s1, PRE_first_tail_x6_r0_body.st40.S1)
theorem PRE_first_tail_x6_r0_body.st40.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st40.F (PRE_first_tail_x6_r0_body.st40.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st40.ks 0).getD 0) PRE_first_tail_x6_r0_body.st40.s0 PRE_first_tail_x6_r0_body.st40.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st40.s1, PRE_first_tail_x6_r0_body.st40.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st40.bodyOkLN_ok PRE_first_tail_x6_r0_body.st40.bodyK0F
end Host.Load.Run.Tpl
end

section -- st40/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st40.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st40.F (PRE_first_tail_x6_r0_body.st40.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st40.s0 PRE_first_tail_x6_r0_body.st40.S0 = some (PRE_first_tail_x6_r0_body.st40.s1, PRE_first_tail_x6_r0_body.st40.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st40.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st40.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st40.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st40.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st40.F (PRE_first_tail_x6_r0_body.st40.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st40.s0
  S0 := PRE_first_tail_x6_r0_body.st40.S0
  s1 := PRE_first_tail_x6_r0_body.st40.s1
  S1 := PRE_first_tail_x6_r0_body.st40.S1
  s2 := PRE_first_tail_x6_r0_body.st40.s2
  S2 := PRE_first_tail_x6_r0_body.st40.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st40.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st40.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st40.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st40.bodyHalt
  last := PRE_first_tail_x6_r0_body.st40.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st40.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC41
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 41 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s404` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa41` into the merged state
`PRE_first_tail_x6_r0_body.s403`. -/

def PRE_first_tail_x6_r0_body.pl41 : List Nat := [2706762]
def PRE_first_tail_x6_r0_body.nr41 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd41 : RData :=
  ⟨2706744, 2706763, Stage.setAll PTrie.nil [(2706743, 2706762)], Stage.setAll PTrie.nil [],
   19004, 19004, 16096, 16096, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa41 : Map :=
  Conv.Map.compact 2706743 2706763 1807 PRE_first_tail_x6_r0_body.pl41 (PRE_first_tail_x6_r0_body.nr41.map NumV.ref) PRE_first_tail_x6_r0_body.kd41.big
    PRE_first_tail_x6_r0_body.kd41.region PRE_first_tail_x6_r0_body.kd41.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws41 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs41 : List SymE := PRE_first_tail_x6_r0_body.nr41.map fun r => (nth? PRE_first_tail_x6_r0_body.S403.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta41 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws41 PRE_first_tail_x6_r0_body.crs41
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB41 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab41 : PRE_first_tail_x6_r0_body.S404.tab = PRE_first_tail_x6_r0_body.S402.tab ++ PRE_first_tail_x6_r0_body.cws41.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace41 : PRE_first_tail_x6_r0_body.s404.trace = PRE_first_tail_x6_r0_body.s402.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext41 : PRE_first_tail_x6_r0_body.s404.next = 2706744
kernel_rfl PRE_first_tail_x6_r0_body.ccounters41 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx.nnext) = (19004, 16096)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue41 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s403.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa41.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp41 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx.tokens.all (bSN 1807) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean41 : Conv.cleanListB 19004 131072 (fun r => Nat.ble 76016 r) PRE_first_tail_x6_r0_body.s404
    (PRE_first_tail_x6_r0_body.wrB41 ++ (List.range 1).map (2706743 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs41 : bigsOutB 19004 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK41
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl41`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl41 : List Nat := [2665, 2673467, 2706743]
def PRE_first_tail_x6_r0_body.clo41 : List Nat := []
def PRE_first_tail_x6_r0_body.cln41 : List Nat := []
def PRE_first_tail_x6_r0_body.cli41 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap41 : PRE_first_tail_x6_r0_body.s404.heap = Stage.setAll PRE_first_tail_x6_r0_body.s402.heap (PRE_first_tail_x6_r0_body.cl41.filterMap fun a => (PRE_first_tail_x6_r0_body.s404.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe41 : Nat.ble PRE_first_tail_x6_r0_body.s402.next PRE_first_tail_x6_r0_body.s404.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP41 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s402 PRE_first_tail_x6_r0_body.s404 PRE_first_tail_x6_r0_body.cl41 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp41 : Conv.suppListB PRE_first_tail_x6_r0_body.s404 1807 PRE_first_tail_x6_r0_body.cl41 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound41 : Conv.boundListB PRE_first_tail_x6_r0_body.s404 PRE_first_tail_x6_r0_body.cl41 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK41 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln41.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK41 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo41.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK41 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli41.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst41 : Conv.sstListB 1807 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx PRE_first_tail_x6_r0_body.cln41 PRE_first_tail_x6_r0_body.clo41 PRE_first_tail_x6_r0_body.cli41 = true

end Host.Load.Run.Tpl
end

section -- SiteCl41
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA41 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo41.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd41 : (PRE_first_tail_x6_r0_body.clo41 ++ PRE_first_tail_x6_r0_body.cln41 ++ PRE_first_tail_x6_r0_body.cli41).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle41 : Conv.Cnt.leB (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) (⟨19004, 16096, 2706744, 1807⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck41 : Conv.ncleanListB (⟨19004, 16096, 2706744, 1807⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx PRE_first_tail_x6_r0_body.clo41 PRE_first_tail_x6_r0_body.cln41 PRE_first_tail_x6_r0_body.cli41 = true
theorem PRE_first_tail_x6_r0_body.cncl41 (h : Conv.NClean (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx) : Conv.NClean (⟨19004, 16096, 2706744, 1807⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle41 PRE_first_tail_x6_r0_body.ckA41 PRE_first_tail_x6_r0_body.cobjsK41 PRE_first_tail_x6_r0_body.cnodesK41 PRE_first_tail_x6_r0_body.citemsK41 PRE_first_tail_x6_r0_body.cbd41 PRE_first_tail_x6_r0_body.cck41

end Host.Load.Run.Tpl
end

section -- SiteS41
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 41 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc41 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P41 : LoadP := PRE_first_tail_x6_r0_body.Pc41.raise 16096
kernel_rfl PRE_first_tail_x6_r0_body.craise41 : Nat.ble PRE_first_tail_x6_r0_body.Pc41.N0 16096 = true
theorem PRE_first_tail_x6_r0_body.raised41 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc41 PRE_first_tail_x6_r0_body.P41 :=
  .inr ⟨16096, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise41, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_41 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_41 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s403.ffi)
def PRE_first_tail_x6_r0_body.khinv41 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv41 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS41 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS41 : List Nat := List.range' 16096 0
def PRE_first_tail_x6_r0_body.ciS41 : List Nat := [] ++ List.range' 16096 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh041 : PRE_first_tail_x6_r0_body.kd41.nh0 = PRE_first_tail_x6_r0_body.cx0_41.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh141 : PRE_first_tail_x6_r0_body.kd41.nh1 = PRE_first_tail_x6_r0_body.cx1_41.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn041 : PRE_first_tail_x6_r0_body.kd41.nn0 = PRE_first_tail_x6_r0_body.cx0_41.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn141 : PRE_first_tail_x6_r0_body.kd41.nn1 = PRE_first_tail_x6_r0_body.cx1_41.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo41 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P41.lo && Nat.ble PRE_first_tail_x6_r0_body.P41.lo PRE_first_tail_x6_r0_body.cx0_41.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P41.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P41.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt41 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_41.mlx.next PRE_first_tail_x6_r0_body.cx1_41.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_41.mlx.nnext PRE_first_tail_x6_r0_body.cx1_41.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband41 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P41.NL && Nat.ble PRE_first_tail_x6_r0_body.P41.NL PRE_first_tail_x6_r0_body.P41.N0 && Nat.ble PRE_first_tail_x6_r0_body.P41.N0 PRE_first_tail_x6_r0_body.cx0_41.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow41 : PRE_first_tail_x6_r0_body.kd41.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren41 : checkRenG PRE_first_tail_x6_r0_body.kd41.hnd PRE_first_tail_x6_r0_body.khinv41 (phB PRE_first_tail_x6_r0_body.cx0_41.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband41 : PRE_first_tail_x6_r0_body.kd41.checkBand PRE_first_tail_x6_r0_body.P41.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos41 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd41.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren41 : checkRenG PRE_first_tail_x6_r0_body.kd41.node PRE_first_tail_x6_r0_body.kninv41 (pnB PRE_first_tail_x6_r0_body.cx0_41.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow41 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd41.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P41.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd41.nodeF j) PRE_first_tail_x6_r0_body.cx1_41.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a41 : PRE_first_tail_x6_r0_body.cx0_41.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b41 : PRE_first_tail_x6_r0_body.cx0_41.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok141 : PRE_first_tail_x6_r0_body.cx1_41.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend41 : PRE_first_tail_x6_r0_body.cx1_41.mlx.pending = PRE_first_tail_x6_r0_body.cx0_41.mlx.pending.map PRE_first_tail_x6_r0_body.kappa41.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh41 : PRE_first_tail_x6_r0_body.cx1_41.mlx.errh = PRE_first_tail_x6_r0_body.cx0_41.mlx.errh.map PRE_first_tail_x6_r0_body.kappa41.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles41 : PRE_first_tail_x6_r0_body.cx1_41.mlx.files = PRE_first_tail_x6_r0_body.cx0_41.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch41 : PRE_first_tail_x6_r0_body.cx1_41.mlx.arch = PRE_first_tail_x6_r0_body.cx0_41.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes41 : PRE_first_tail_x6_r0_body.cx1_41.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_41.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired41 : PRE_first_tail_x6_r0_body.cx1_41.mlx.wired = PRE_first_tail_x6_r0_body.cx0_41.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost41 : PRE_first_tail_x6_r0_body.cx1_41.host = PRE_first_tail_x6_r0_body.cx0_41.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd41`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn041 : PRE_first_tail_x6_r0_body.kd41.n0 = 2706744
kernel_rfl PRE_first_tail_x6_r0_body.ckn141 : PRE_first_tail_x6_r0_body.kd41.n1 = 2706763
kernel_rfl PRE_first_tail_x6_r0_body.ckheap41 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd41.heap).all (fun x => Nat.ble 2706743 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl41 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd41.heap.get (2706743 + j) = nth? PRE_first_tail_x6_r0_body.pl41 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja41 : Nat.ble 2706743 2706743 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn41 : Nat.ble 1807 1807 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD41 : Nat.ble 2706743 PRE_first_tail_x6_r0_body.kd41.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn41 : Nat.ble 19004 PRE_first_tail_x6_r0_body.kd41.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn41 : Nat.ble 16096 PRE_first_tail_x6_r0_body.kd41.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb41 : Nat.ble 19004 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap41 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd41.heap).all (Nat.ble (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd41 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd41.hnd).all (Nat.ble (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode41 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd41.node).all (Nat.ble (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix41 : Conv.FixOld (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa41 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja41) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn41) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD41) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn41) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn41) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb41) PRE_first_tail_x6_r0_body.fheap41 PRE_first_tail_x6_r0_body.fhnd41 PRE_first_tail_x6_r0_body.fnode41
kernel_rfl PRE_first_tail_x6_r0_body.fcxn41 : (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn41 : (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle041 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_41.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_41.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk41 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd41.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A41 : PRE_first_tail_x6_r0_body.cx1_41.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS41.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_41.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O41 : PRE_first_tail_x6_r0_body.cx1_41.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS41.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_41.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N41 : PRE_first_tail_x6_r0_body.cx1_41.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS41.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_41.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I41 : PRE_first_tail_x6_r0_body.cx1_41.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS41.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_41.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd41 : (PRE_first_tail_x6_r0_body.clo41 ++ PRE_first_tail_x6_r0_body.cln41 ++ PRE_first_tail_x6_r0_body.cli41 ++ PRE_first_tail_x6_r0_body.cwS41 ++ PRE_first_tail_x6_r0_body.cnS41 ++ PRE_first_tail_x6_r0_body.ciS41).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW41 : PRE_first_tail_x6_r0_body.cwS41.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo41.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI41 : PRE_first_tail_x6_r0_body.ciS41.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli41.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN41 : PRE_first_tail_x6_r0_body.cnS41.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF41 : PRE_first_tail_x6_r0_body.cln41.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh41 : PRE_first_tail_x6_r0_body.clo41.all (handleOK PRE_first_tail_x6_r0_body.kappa41 PRE_first_tail_x6_r0_body.P41.lo PRE_first_tail_x6_r0_body.cx0_41.mlx PRE_first_tail_x6_r0_body.cx1_41.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo41 : PRE_first_tail_x6_r0_body.clo41.map (fun h => PRE_first_tail_x6_r0_body.cx1_41.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa41.handle h)) = PRE_first_tail_x6_r0_body.clo41.map (fun h => (PRE_first_tail_x6_r0_body.cx0_41.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa41.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok41 : PRE_first_tail_x6_r0_body.clo41.all (objOK PRE_first_tail_x6_r0_body.kappa41 PRE_first_tail_x6_r0_body.P41.NL PRE_first_tail_x6_r0_body.cx0_41.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd41 : PRE_first_tail_x6_r0_body.cln41.all (nodeOKF PRE_first_tail_x6_r0_body.kappa41 PRE_first_tail_x6_r0_body.P41 PRE_first_tail_x6_r0_body.cx0_41.mlx PRE_first_tail_x6_r0_body.cx1_41.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp41 : ((PRE_first_tail_x6_r0_body.cln41.filter (fullB PRE_first_tail_x6_r0_body.P41))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_41.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa41.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln41.filter (fullB PRE_first_tail_x6_r0_body.P41))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_41.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa41.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI41 : incrB PRE_first_tail_x6_r0_body.kd41.nodeF (List.range' 16096 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK41 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd41.node).all (fun k => Nat.ble 16096 k && Nat.blt k 16096) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL41 : (PRE_first_tail_x6_r0_body.cln41.filter (Nat.ble PRE_first_tail_x6_r0_body.P41.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd41.nodeF i) && (Nat.blt i 16096 || Nat.ble PRE_first_tail_x6_r0_body.kd41.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord41 : (PRE_first_tail_x6_r0_body.cln41.filter (Nat.ble PRE_first_tail_x6_r0_body.P41.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd41.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd41.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd41.nodeF j) (PRE_first_tail_x6_r0_body.kd41.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow41 PRE_first_tail_x6_r0_body.cnn141 PRE_first_tail_x6_r0_body.fnordI41 PRE_first_tail_x6_r0_body.fnordK41 PRE_first_tail_x6_r0_body.fnordL41
kernel_rfl PRE_first_tail_x6_r0_body.fi41 : PRE_first_tail_x6_r0_body.cli41.all (pnB PRE_first_tail_x6_r0_body.cx0_41.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii41 : PRE_first_tail_x6_r0_body.cli41.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_41.mlx.items.get (PRE_first_tail_x6_r0_body.kappa41.node k) = (PRE_first_tail_x6_r0_body.cx0_41.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa41.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot41 (clean : Conv.NClean (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P41.NL) (cl : SSt (· < 1807) PRE_first_tail_x6_r0_body.cx0_41.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P41 1807 PRE_first_tail_x6_r0_body.kappa41 PRE_first_tail_x6_r0_body.kd41 PRE_first_tail_x6_r0_body.khinv41 PRE_first_tail_x6_r0_body.kninv41 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx PRE_first_tail_x6_r0_body.cx0_41.mlx PRE_first_tail_x6_r0_body.cx1_41.mlx (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo41 PRE_first_tail_x6_r0_body.cln41 PRE_first_tail_x6_r0_body.cli41 PRE_first_tail_x6_r0_body.cwS41 PRE_first_tail_x6_r0_body.cnS41 PRE_first_tail_x6_r0_body.ciS41 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh041, PRE_first_tail_x6_r0_body.cnh141, PRE_first_tail_x6_r0_body.cnn041, PRE_first_tail_x6_r0_body.cnn141, PRE_first_tail_x6_r0_body.cplo41, PRE_first_tail_x6_r0_body.ccnt41, PRE_first_tail_x6_r0_body.cnband41, PRE_first_tail_x6_r0_body.chbelow41, PRE_first_tail_x6_r0_body.chren41, PRE_first_tail_x6_r0_body.cband41, PRE_first_tail_x6_r0_body.cnh1pos41, PRE_first_tail_x6_r0_body.cnren41, PRE_first_tail_x6_r0_body.cnlow41, PRE_first_tail_x6_r0_body.cabs0a41, PRE_first_tail_x6_r0_body.cabs0b41, PRE_first_tail_x6_r0_body.ctok141, PRE_first_tail_x6_r0_body.cpend41, PRE_first_tail_x6_r0_body.cerrh41, PRE_first_tail_x6_r0_body.cfiles41, PRE_first_tail_x6_r0_body.carch41, PRE_first_tail_x6_r0_body.csizes41, PRE_first_tail_x6_r0_body.cwired41, PRE_first_tail_x6_r0_body.cfix41, clean, PRE_first_tail_x6_r0_body.fcxn41, PRE_first_tail_x6_r0_body.fcnn41, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle041, PRE_first_tail_x6_r0_body.fnk41, PRE_first_tail_x6_r0_body.ckA41, PRE_first_tail_x6_r0_body.cobjsK41, PRE_first_tail_x6_r0_body.cnodesK41, PRE_first_tail_x6_r0_body.citemsK41, PRE_first_tail_x6_r0_body.f1A41, PRE_first_tail_x6_r0_body.f1O41, PRE_first_tail_x6_r0_body.f1N41, PRE_first_tail_x6_r0_body.f1I41, PRE_first_tail_x6_r0_body.fbd41, PRE_first_tail_x6_r0_body.fincW41, PRE_first_tail_x6_r0_body.fincI41, PRE_first_tail_x6_r0_body.fincN41, PRE_first_tail_x6_r0_body.flnF41, PRE_first_tail_x6_r0_body.fh41, PRE_first_tail_x6_r0_body.fo41, PRE_first_tail_x6_r0_body.fok41, PRE_first_tail_x6_r0_body.fnd41, PRE_first_tail_x6_r0_body.fp41, PRE_first_tail_x6_r0_body.fnord41, PRE_first_tail_x6_r0_body.fi41, PRE_first_tail_x6_r0_body.fii41⟩
theorem PRE_first_tail_x6_r0_body.cnshift41 (clean : Conv.NClean (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P41.NL) (cl : SSt (· < 1807) PRE_first_tail_x6_r0_body.cx0_41.mlx) : NShift PRE_first_tail_x6_r0_body.P41 1807 PRE_first_tail_x6_r0_body.kappa41 PRE_first_tail_x6_r0_body.cx0_41 PRE_first_tail_x6_r0_body.cx1_41 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot41 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost41 (compact_a_eq PRE_first_tail_x6_r0_body.ckn041 PRE_first_tail_x6_r0_body.ckn141 PRE_first_tail_x6_r0_body.ckheap41 PRE_first_tail_x6_r0_body.ckpl41)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_41 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s402.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_41 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s402.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_41 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s402.ffi) = some PRE_first_tail_x6_r0_body.fxC_41
kernel_rfl PRE_first_tail_x6_r0_body.okrC_41 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s402.ffi) = some PRE_first_tail_x6_r0_body.krC_41
noncomputable def PRE_first_tail_x6_r0_body.fx0_41 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s404.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_41 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s404.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_41 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s404.ffi) = some PRE_first_tail_x6_r0_body.fx0_41
kernel_rfl PRE_first_tail_x6_r0_body.okr0_41 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s404.ffi) = some PRE_first_tail_x6_r0_body.kr0_41
noncomputable def PRE_first_tail_x6_r0_body.fx1_41 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s403.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_41 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s403.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_41 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s403.ffi) = some PRE_first_tail_x6_r0_body.fx1_41
kernel_rfl PRE_first_tail_x6_r0_body.okr1_41 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s403.ffi) = some PRE_first_tail_x6_r0_body.kr1_41
kernel_rfl PRE_first_tail_x6_r0_body.ff041 : PRE_first_tail_x6_r0_body.fx0_41 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_41 (PRE_first_tail_x6_r0_body.clo41.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_41.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff141 : PRE_first_tail_x6_r0_body.fx1_41 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_41 (PRE_first_tail_x6_r0_body.cwS41.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_41.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck41 : freedLB PRE_first_tail_x6_r0_body.kappa41 PRE_first_tail_x6_r0_body.cx0_41.mlx PRE_first_tail_x6_r0_body.fx0_41 PRE_first_tail_x6_r0_body.fx1_41 PRE_first_tail_x6_r0_body.clo41 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf041 : PRE_first_tail_x6_r0_body.kr0_41.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_41.flags (PRE_first_tail_x6_r0_body.clo41.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_41.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt041 : PRE_first_tail_x6_r0_body.kr0_41.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_41.targs (PRE_first_tail_x6_r0_body.clo41.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_41.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf141 : PRE_first_tail_x6_r0_body.kr1_41.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_41.flags (PRE_first_tail_x6_r0_body.cwS41.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_41.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt141 : PRE_first_tail_x6_r0_body.kr1_41.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_41.targs (PRE_first_tail_x6_r0_body.cwS41.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_41.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck41 : krecLB PRE_first_tail_x6_r0_body.kappa41 1807 PRE_first_tail_x6_r0_body.cx0_41.mlx PRE_first_tail_x6_r0_body.kr0_41 PRE_first_tail_x6_r0_body.kr1_41 PRE_first_tail_x6_r0_body.clo41 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn41 : Nat.ble 1807 1807 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge41 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s403.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s404.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR41 : pendRegB PRE_first_tail_x6_r0_body.kappa41 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe41 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s404.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s403.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift41 (clean : Conv.NClean (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P41.NL) (cl : SSt (· < 1807) PRE_first_tail_x6_r0_body.cx0_41.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_41.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_41.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_41.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s402.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_41.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P41 1807 PRE_first_tail_x6_r0_body.kappa41 PRE_first_tail_x6_r0_body.s404.ffi PRE_first_tail_x6_r0_body.s403.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift41 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue41, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp41 t ht),
    PRE_first_tail_x6_r0_body.cbridge41,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s404.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s403.ffi) (PRE_first_tail_x6_r0_body.cfoot41 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_41 PRE_first_tail_x6_r0_body.ofx1_41 hobjC PRE_first_tail_x6_r0_body.ff041 PRE_first_tail_x6_r0_body.ff141 PRE_first_tail_x6_r0_body.ffck41,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s404.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s403.ffi) (PRE_first_tail_x6_r0_body.cfoot41 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_41 PRE_first_tail_x6_r0_body.okr1_41 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn41) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf041 PRE_first_tail_x6_r0_body.fkt041 PRE_first_tail_x6_r0_body.fkf141 PRE_first_tail_x6_r0_body.fkt141 PRE_first_tail_x6_r0_body.fkck41,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh041 PRE_first_tail_x6_r0_body.cnh141 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe41) PRE_first_tail_x6_r0_body.cpendR41⟩

end Host.Load.Run.Tpl
end

section -- st41/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st41 0
host_stream_state PRE_first_tail_x6_r0_body.st41 1
host_stream_state PRE_first_tail_x6_r0_body.st41 2
end Host.Load.Run.Tpl
end

section -- Site41
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 41 of chain `PRE_first_tail_x6_r0_body`: `plan__g41__g42` (`plan`), the call state `PRE_first_tail_x6_r0_body.s402`, the merged state `PRE_first_tail_x6_r0_body.s403`,
the site template `PRE_first_tail_x6_r0_body.st41` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s404`: the merge.
The footprint's facts are in `SiteF41`, the compaction's in `SiteC41`, `SiteK41`, `SiteNa41`, `SiteNb41`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso41 : PRE_first_tail_x6_r0_body.st41.s0 = { PRE_first_tail_x6_r0_body.s402 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs41 : List Frame := PRE_first_tail_x6_r0_body.s402.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_41 : PRE_first_tail_x6_r0_body.S402.tab.length = 1807
kernel_rfl PRE_first_tail_x6_r0_body.tab0_41 : PRE_first_tail_x6_r0_body.st41.S0.tab = PRE_first_tail_x6_r0_body.S402.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws41 : List Nat := [1696, 1697, 1698, 1699, 1700, 1701, 1702, 1703, 1704]
kernel_rfl PRE_first_tail_x6_r0_body.fresh41 : (PRE_first_tail_x6_r0_body.S402.tab.all fun e => PRE_first_tail_x6_r0_body.ws41.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S402.oracle.all fun q => PRE_first_tail_x6_r0_body.ws41.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab41 : PRE_first_tail_x6_r0_body.S403.tab = PRE_first_tail_x6_r0_body.S402.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws41
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen41 : PRE_first_tail_x6_r0_body.st41.S2.tab.length - PRE_first_tail_x6_r0_body.st41.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged41`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap41 : PRE_first_tail_x6_r0_body.s403.heap = PRE_first_tail_x6_r0_body.st41.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext41 : PRE_first_tail_x6_r0_body.s403.next = PRE_first_tail_x6_r0_body.st41.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl41 : PRE_first_tail_x6_r0_body.s403.ctl = PRE_first_tail_x6_r0_body.st41.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack41 : PRE_first_tail_x6_r0_body.s403.stack = PRE_first_tail_x6_r0_body.st41.s2.stack ++ PRE_first_tail_x6_r0_body.s402.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs41 : PRE_first_tail_x6_r0_body.s403.jobs = PRE_first_tail_x6_r0_body.st41.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi41 : PRE_first_tail_x6_r0_body.s403.ffi = PRE_first_tail_x6_r0_body.st41.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace41 : PRE_first_tail_x6_r0_body.s403.trace = PRE_first_tail_x6_r0_body.st41.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores41 : PRE_first_tail_x6_r0_body.s403.stores = PRE_first_tail_x6_r0_body.st41.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD41
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 41 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived41 : PRE_first_tail_x6_r0_body.nr41.map (fun r => nth? PRE_first_tail_x6_r0_body.st41.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo41 : PRE_first_tail_x6_r0_body.nr41.all (Nat.ble 1807) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj41 : PRE_first_tail_x6_r0_body.cws41.all (fun c => !PRE_first_tail_x6_r0_body.ws41.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ41 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws41 PRE_first_tail_x6_r0_body.crs41 PRE_first_tail_x6_r0_body.ws41

end Host.Load.Run.Tpl
end

section -- st41/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st41`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st41.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st41.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st41.s2.heap PRE_first_tail_x6_r0_body.st41.wrR ++ freshOf PRE_first_tail_x6_r0_body.st41.s2.heap PRE_first_tail_x6_r0_body.st41.s0.next PRE_first_tail_x6_r0_body.st41.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st41.wr : List Nat := PRE_first_tail_x6_r0_body.st41.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st41.heapFoot : PRE_first_tail_x6_r0_body.st41.s2.heap = setAll PRE_first_tail_x6_r0_body.st41.s0.heap PRE_first_tail_x6_r0_body.st41.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st41.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st41.s0.next PRE_first_tail_x6_r0_body.st41.s2.next = true
theorem PRE_first_tail_x6_r0_body.st41.grows : PRE_first_tail_x6_r0_body.st41.s0.next ≤ PRE_first_tail_x6_r0_body.st41.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st41.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st41.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st41.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st41.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st41.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st41.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st41.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st41.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st41.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st41.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st41.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st41.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF41
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 41 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB41 : nodupT PRE_first_tail_x6_r0_body.st41.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup41 : PRE_first_tail_x6_r0_body.st41.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB41).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB41 : PRE_first_tail_x6_r0_body.st41.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound41 : ∀ b ∈ PRE_first_tail_x6_r0_body.st41.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB41 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr41 := PRE_first_tail_x6_r0_body.st41.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq41 : PRE_first_tail_x6_r0_body.st41.s2.trace = PRE_first_tail_x6_r0_body.trFr41 ++ PRE_first_tail_x6_r0_body.st41.s0.trace
theorem PRE_first_tail_x6_r0_body.trace41 : ∃ fr, PRE_first_tail_x6_r0_body.st41.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st41.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq41⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide41 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB41 : (PRE_first_tail_x6_r0_body.wide41.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st41.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix41 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide41, WFix Map.id (Present PRE_first_tail_x6_r0_body.st41.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB41 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL41
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 41 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s403`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO41 : PRE_first_tail_x6_r0_body.st41.S0.oracle = PRE_first_tail_x6_r0_body.st41.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B41 : PRE_first_tail_x6_r0_body.st41.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st41.s0.next || (PRE_first_tail_x6_r0_body.st41.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot41 : Conv.StageFoot PRE_first_tail_x6_r0_body.st41.wr PRE_first_tail_x6_r0_body.st41.s0 PRE_first_tail_x6_r0_body.st41.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st41.heapFoot PRE_first_tail_x6_r0_body.wrNodup41 PRE_first_tail_x6_r0_body.wrBound41 PRE_first_tail_x6_r0_body.wr0B41 PRE_first_tail_x6_r0_body.st41.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged41 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st41.F.S → PRE_first_tail_x6_r0_body.st41.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st41.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st41.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs41 PRE_first_tail_x6_r0_body.st41.wr PRE_first_tail_x6_r0_body.s402 PRE_first_tail_x6_r0_body.st41.s2 PRE_first_tail_x6_r0_body.st41.s0
      PRE_first_tail_x6_r0_body.st41.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st41.F FR W stk M ν K PRE_first_tail_x6_r0_body.s403 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso41 PRE_first_tail_x6_r0_body.stFoot41 PRE_first_tail_x6_r0_body.wrNodup41 PRE_first_tail_x6_r0_body.wrBound41 PRE_first_tail_x6_r0_body.trace41 PRE_first_tail_x6_r0_body.mheap41
    PRE_first_tail_x6_r0_body.mnext41 PRE_first_tail_x6_r0_body.mctl41 PRE_first_tail_x6_r0_body.mstack41 PRE_first_tail_x6_r0_body.mjobs41 PRE_first_tail_x6_r0_body.mffi41 PRE_first_tail_x6_r0_body.mtrace41 PRE_first_tail_x6_r0_body.mstores41 h

def PRE_first_tail_x6_r0_body.arrEl41_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE41_2665 : arrOf PRE_first_tail_x6_r0_body.s403 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl41_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA41_2665 : isArrB PRE_first_tail_x6_r0_body.s403 2665 = true
theorem PRE_first_tail_x6_r0_body.arr41_2665 : ∃ o, PRE_first_tail_x6_r0_body.s403.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl41_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE41_2665 PRE_first_tail_x6_r0_body.arrA41_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN41_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl41_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR41_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl41_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN41_2665

def PRE_first_tail_x6_r0_body.arrEl41_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE41_2673467 : arrOf PRE_first_tail_x6_r0_body.s403 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl41_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA41_2673467 : isArrB PRE_first_tail_x6_r0_body.s403 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr41_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s403.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl41_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE41_2673467 PRE_first_tail_x6_r0_body.arrA41_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN41_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl41_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR41_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl41_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN41_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k41 : isArrB PRE_first_tail_x6_r0_body.s403 4910 = false
theorem PRE_first_tail_x6_r0_body.keep41 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s403 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k41 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr41_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl41_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ41
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 41 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s402`, the merged
state `PRE_first_tail_x6_r0_body.s403`, the canonical state `PRE_first_tail_x6_r0_body.s404`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl41 : PRE_first_tail_x6_r0_body.pl41.all (Nat.ble PRE_first_tail_x6_r0_body.s402.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd41 : nodupT PRE_first_tail_x6_r0_body.pl41 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn141 : Nat.ble PRE_first_tail_x6_r0_body.s402.next 2706763 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst41 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s402.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn41 : PRE_first_tail_x6_r0_body.s404.next = PRE_first_tail_x6_r0_body.s402.next + PRE_first_tail_x6_r0_body.pl41.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn41 : PRE_first_tail_x6_r0_body.s403.next = 2706763
kernel_rfl PRE_first_tail_x6_r0_body.zgrow41 : Nat.ble PRE_first_tail_x6_r0_body.s404.next PRE_first_tail_x6_r0_body.s403.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh41 : PRE_first_tail_x6_r0_body.S402.tab.all (fun e => PRE_first_tail_x6_r0_body.cws41.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd41 : nodupT PRE_first_tail_x6_r0_body.cws41 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi41 : PRE_first_tail_x6_r0_body.nr41.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S403.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt41 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s402.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg41_2665 : PRE_first_tail_x6_r0_body.s404.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s404 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk41_2665 : (objOf PRE_first_tail_x6_r0_body.s404 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm41_2665 : PRE_first_tail_x6_r0_body.s403.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa41.obj (objOf PRE_first_tail_x6_r0_body.s404 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s403 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg41_2673467 : PRE_first_tail_x6_r0_body.s404.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s404 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk41_2673467 : (objOf PRE_first_tail_x6_r0_body.s404 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm41_2673467 : PRE_first_tail_x6_r0_body.s403.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa41.obj (objOf PRE_first_tail_x6_r0_body.s404 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s403 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw41_4910 : (PRE_first_tail_x6_r0_body.s404.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw41_2673472 : (PRE_first_tail_x6_r0_body.s404.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw41_2673473 : (PRE_first_tail_x6_r0_body.s404.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd41 : PRE_first_tail_x6_r0_body.cl41.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr41 : PRE_first_tail_x6_r0_body.st41.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s402.next || PRE_first_tail_x6_r0_body.cl41.contains b) = true
def PRE_first_tail_x6_r0_body.zl41 : List Nat := PRE_first_tail_x6_r0_body.cl41.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE41 : PRE_first_tail_x6_r0_body.zl41.map (fun a => PRE_first_tail_x6_r0_body.s403.heap.get (PRE_first_tail_x6_r0_body.kappa41.a a)) = PRE_first_tail_x6_r0_body.zl41.map (fun a => (PRE_first_tail_x6_r0_body.s404.heap.get a).map PRE_first_tail_x6_r0_body.kappa41.hobj)
theorem PRE_first_tail_x6_r0_body.zimg41 : HeapImg PRE_first_tail_x6_r0_body.kappa41 PRE_first_tail_x6_r0_body.s404 PRE_first_tail_x6_r0_body.s403 PRE_first_tail_x6_r0_body.zl41 := PRE_first_tail_x6_r0_body.zimgE41
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl41 : PRE_first_tail_x6_r0_body.s403.ctl = PRE_first_tail_x6_r0_body.kappa41.ctl PRE_first_tail_x6_r0_body.s404.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack41 : PRE_first_tail_x6_r0_body.s403.stack = PRE_first_tail_x6_r0_body.s404.stack.map PRE_first_tail_x6_r0_body.kappa41.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs41 : PRE_first_tail_x6_r0_body.s403.jobs = PRE_first_tail_x6_r0_body.s404.jobs.map PRE_first_tail_x6_r0_body.kappa41.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores41 : PRE_first_tail_x6_r0_body.s403.stores = PRE_first_tail_x6_r0_body.kappa41.stores PRE_first_tail_x6_r0_body.s404.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots41 : checkRootsSupp PRE_first_tail_x6_r0_body.s404 1807 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC41 : PRE_first_tail_x6_r0_body.S402.tab.length + PRE_first_tail_x6_r0_body.cws41.length = 1807
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap41 : PRE_first_tail_x6_r0_body.kappa41 = Conv.Map.compact PRE_first_tail_x6_r0_body.s402.next 2706763 PRE_first_tail_x6_r0_body.S402.tab.length PRE_first_tail_x6_r0_body.pl41 (PRE_first_tail_x6_r0_body.nr41.map NumV.ref) PRE_first_tail_x6_r0_body.kd41.big
  PRE_first_tail_x6_r0_body.kd41.region PRE_first_tail_x6_r0_body.kd41.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin41 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s404.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc41 : Conv.jcleanListB (⟨19004, 16096, 2706744, 1807⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s404 PRE_first_tail_x6_r0_body.cl41 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB41 : noBigRootsP (fun i => !Conv.oldBigB (⟨19004, 16096, 2706744, 1807⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s404.trace PRE_first_tail_x6_r0_body.s404 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm41 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 16096 = true
theorem PRE_first_tail_x6_r0_body.cjcl41 (h : Conv.JClean (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s402) : Conv.JClean (⟨19004, 16096, 2706744, 1807⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s404 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle41)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap41 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd41 a ha)) PRE_first_tail_x6_r0_body.zjc41

end Host.Load.Run.Tpl
end

section -- st41/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st41.bodyLast from PRE_first_tail_x6_r0_body.st41.s1 to PRE_first_tail_x6_r0_body.st41.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st41.F PRE_first_tail_x6_r0_body.st41.s1).run PRE_first_tail_x6_r0_body.st41.S1 = some (PRE_first_tail_x6_r0_body.st41.s2, PRE_first_tail_x6_r0_body.st41.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st41.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st41.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st41.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st41.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st41/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st41.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st41.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st41.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st41.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st41.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st41.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st41.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st41.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st41.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st41.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st41.s0 PRE_first_tail_x6_r0_body.st41.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st41.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st41.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st41.s1 PRE_first_tail_x6_r0_body.st41.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st41/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st41.bodyK0F from PRE_first_tail_x6_r0_body.st41.s0 to PRE_first_tail_x6_r0_body.st41.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st41.F (PRE_first_tail_x6_r0_body.st41.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st41.ks 0).getD 0) PRE_first_tail_x6_r0_body.st41.s0 PRE_first_tail_x6_r0_body.st41.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st41.s1, PRE_first_tail_x6_r0_body.st41.S1)
theorem PRE_first_tail_x6_r0_body.st41.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st41.F (PRE_first_tail_x6_r0_body.st41.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st41.ks 0).getD 0) PRE_first_tail_x6_r0_body.st41.s0 PRE_first_tail_x6_r0_body.st41.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st41.s1, PRE_first_tail_x6_r0_body.st41.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st41.bodyOkLN_ok PRE_first_tail_x6_r0_body.st41.bodyK0F
end Host.Load.Run.Tpl
end

section -- st41/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st41.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st41.F (PRE_first_tail_x6_r0_body.st41.bodyOkL bytes rows) 206 PRE_first_tail_x6_r0_body.st41.s0 PRE_first_tail_x6_r0_body.st41.S0 = some (PRE_first_tail_x6_r0_body.st41.s1, PRE_first_tail_x6_r0_body.st41.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st41.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st41.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st41.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st41.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st41.F (PRE_first_tail_x6_r0_body.st41.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st41.s0
  S0 := PRE_first_tail_x6_r0_body.st41.S0
  s1 := PRE_first_tail_x6_r0_body.st41.s1
  S1 := PRE_first_tail_x6_r0_body.st41.S1
  s2 := PRE_first_tail_x6_r0_body.st41.s2
  S2 := PRE_first_tail_x6_r0_body.st41.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st41.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st41.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st41.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st41.bodyHalt
  last := PRE_first_tail_x6_r0_body.st41.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st41.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC42
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 42 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s421` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa42` into the merged state
`PRE_first_tail_x6_r0_body.s420`. -/

def PRE_first_tail_x6_r0_body.pl42 : List Nat := [2709331, 2708506, 2709337, 2709333, 2708508, 2709339]
def PRE_first_tail_x6_r0_body.nr42 : List Nat := [1910, 1909, 1885, 1893, 1898, 1903, 1908, 1882, 1883, 1884, 1891, 1892, 1880, 1887, 1888, 1889, 1890, 1886]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd42 : RData :=
  ⟨2708225, 2709374, Stage.setAll PTrie.nil [(2708219, 2709331), (2708220, 2708506), (2708221, 2709337), (2708222, 2709333), (2708223, 2708508), (2708224, 2709339)], Stage.setAll PTrie.nil [(19038, 19064), (19039, 19042), (19040, 19065)],
   19041, 19066, 16142, 16142, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(1880, .ref 1910), (1881, .ref 1909), (1882, .ref 1885), (1883, .ref 1893), (1884, .ref 1898), (1885, .ref 1903), (1886, .ref 1908), (1887, .ref 1882), (1888, .ref 1883), (1889, .ref 1884), (1890, .ref 1891), (1891, .ref 1892), (1892, .ref 1880), (1893, .ref 1887), (1894, .ref 1888), (1895, .ref 1889), (1896, .ref 1890), (1897, .ref 1886)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa42 : Map :=
  Conv.Map.compact 2708219 2709374 1880 PRE_first_tail_x6_r0_body.pl42 (PRE_first_tail_x6_r0_body.nr42.map NumV.ref) PRE_first_tail_x6_r0_body.kd42.big
    PRE_first_tail_x6_r0_body.kd42.region PRE_first_tail_x6_r0_body.kd42.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws42 : List Nat := [1736, 1737, 1738, 1739, 1740, 1741, 1742, 1743, 1744, 1745, 1746, 1747, 1748, 1749, 1750, 1751, 1752, 1753]
noncomputable def PRE_first_tail_x6_r0_body.crs42 : List SymE := PRE_first_tail_x6_r0_body.nr42.map fun r => (nth? PRE_first_tail_x6_r0_body.S420.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta42 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws42 PRE_first_tail_x6_r0_body.crs42
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB42 : List Nat := [2665, 2672403, 2673467, 2707393, 2707938, 2708194]

kernel_rfl PRE_first_tail_x6_r0_body.ctab42 : PRE_first_tail_x6_r0_body.S421.tab = PRE_first_tail_x6_r0_body.S419.tab ++ PRE_first_tail_x6_r0_body.cws42.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace42 : PRE_first_tail_x6_r0_body.s421.trace = PRE_first_tail_x6_r0_body.s419.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext42 : PRE_first_tail_x6_r0_body.s421.next = 2708225
kernel_rfl PRE_first_tail_x6_r0_body.ccounters42 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx.nnext) = (19041, 16142)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue42 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s420.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa42.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp42 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx.tokens.all (bSN 1898) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean42 : Conv.cleanListB 19041 131072 (fun r => Nat.ble 76164 r) PRE_first_tail_x6_r0_body.s421
    (PRE_first_tail_x6_r0_body.wrB42 ++ (List.range 6).map (2708219 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs42 : bigsOutB 19041 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK42
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl42`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl42 : List Nat := [2665, 2672403, 2673467, 2707393, 2707938, 2708194, 2708219, 2708220, 2708221, 2708222, 2708223, 2708224]
def PRE_first_tail_x6_r0_body.clo42 : List Nat := [19018, 19031, 19037, 19038, 19039, 19040]
def PRE_first_tail_x6_r0_body.cln42 : List Nat := [16115, 16116, 16117, 16118, 16119, 16120, 16121, 16122, 16123, 16124, 16125, 16126, 16127, 16128, 16129, 16130, 16131, 16132, 16133, 16134, 16135, 16136, 16137, 16138, 16139, 16140, 16141]
def PRE_first_tail_x6_r0_body.cli42 : List Nat := [16115, 16116, 16117, 16118, 16119, 16120, 16121, 16122, 16123, 16124, 16125, 16126, 16127, 16128, 16129, 16130, 16131, 16132, 16133, 16134, 16135, 16136, 16137, 16138, 16139, 16140, 16141]
kernel_rfl PRE_first_tail_x6_r0_body.cheap42 : PRE_first_tail_x6_r0_body.s421.heap = Stage.setAll PRE_first_tail_x6_r0_body.s419.heap (PRE_first_tail_x6_r0_body.cl42.filterMap fun a => (PRE_first_tail_x6_r0_body.s421.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe42 : Nat.ble PRE_first_tail_x6_r0_body.s419.next PRE_first_tail_x6_r0_body.s421.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP42 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s419 PRE_first_tail_x6_r0_body.s421 PRE_first_tail_x6_r0_body.cl42 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp42 : Conv.suppListB PRE_first_tail_x6_r0_body.s421 1898 PRE_first_tail_x6_r0_body.cl42 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound42 : Conv.boundListB PRE_first_tail_x6_r0_body.s421 PRE_first_tail_x6_r0_body.cl42 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK42 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln42.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK42 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo42.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK42 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli42.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst42 : Conv.sstListB 1898 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx PRE_first_tail_x6_r0_body.cln42 PRE_first_tail_x6_r0_body.clo42 PRE_first_tail_x6_r0_body.cli42 = true

end Host.Load.Run.Tpl
end

section -- SiteCl42
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA42 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo42.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd42 : (PRE_first_tail_x6_r0_body.clo42 ++ PRE_first_tail_x6_r0_body.cln42 ++ PRE_first_tail_x6_r0_body.cli42).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle42 : Conv.Cnt.leB (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) (⟨19041, 16142, 2708225, 1898⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck42 : Conv.ncleanListB (⟨19041, 16142, 2708225, 1898⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx PRE_first_tail_x6_r0_body.clo42 PRE_first_tail_x6_r0_body.cln42 PRE_first_tail_x6_r0_body.cli42 = true
theorem PRE_first_tail_x6_r0_body.cncl42 (h : Conv.NClean (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx) : Conv.NClean (⟨19041, 16142, 2708225, 1898⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle42 PRE_first_tail_x6_r0_body.ckA42 PRE_first_tail_x6_r0_body.cobjsK42 PRE_first_tail_x6_r0_body.cnodesK42 PRE_first_tail_x6_r0_body.citemsK42 PRE_first_tail_x6_r0_body.cbd42 PRE_first_tail_x6_r0_body.cck42

end Host.Load.Run.Tpl
end

section -- SiteS42
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 42 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc42 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P42 : LoadP := PRE_first_tail_x6_r0_body.Pc42.raise 16142
kernel_rfl PRE_first_tail_x6_r0_body.craise42 : Nat.ble PRE_first_tail_x6_r0_body.Pc42.N0 16142 = true
theorem PRE_first_tail_x6_r0_body.raised42 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc42 PRE_first_tail_x6_r0_body.P42 :=
  .inr ⟨16142, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise42, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_42 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_42 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s420.ffi)
def PRE_first_tail_x6_r0_body.khinv42 : PTrie Nat := Stage.setAll PTrie.nil [(19064, 19038), (19042, 19039), (19065, 19040)]
def PRE_first_tail_x6_r0_body.kninv42 : PTrie Nat := Stage.setAll PTrie.nil [(16115, 16115), (16116, 16116), (16117, 16117), (16118, 16118), (16119, 16119), (16120, 16120), (16121, 16121), (16122, 16122), (16123, 16123), (16124, 16124), (16125, 16125), (16126, 16126), (16127, 16127), (16128, 16128), (16129, 16129), (16130, 16130), (16131, 16131), (16132, 16132), (16133, 16133), (16134, 16134), (16135, 16135), (16136, 16136), (16137, 16137), (16138, 16138), (16139, 16139), (16140, 16140), (16141, 16141)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS42 : List Nat := [19018, 19031, 19037, 19038, 19039, 19040, 19041, 19042, 19043, 19044, 19045, 19046, 19047, 19048, 19049, 19050, 19051, 19052, 19053, 19054, 19055, 19056, 19057, 19058, 19059, 19060, 19061, 19062, 19063, 19064, 19065]
def PRE_first_tail_x6_r0_body.cnS42 : List Nat := List.range' 16115 27
def PRE_first_tail_x6_r0_body.ciS42 : List Nat := [] ++ List.range' 16115 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh042 : PRE_first_tail_x6_r0_body.kd42.nh0 = PRE_first_tail_x6_r0_body.cx0_42.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh142 : PRE_first_tail_x6_r0_body.kd42.nh1 = PRE_first_tail_x6_r0_body.cx1_42.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn042 : PRE_first_tail_x6_r0_body.kd42.nn0 = PRE_first_tail_x6_r0_body.cx0_42.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn142 : PRE_first_tail_x6_r0_body.kd42.nn1 = PRE_first_tail_x6_r0_body.cx1_42.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo42 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P42.lo && Nat.ble PRE_first_tail_x6_r0_body.P42.lo PRE_first_tail_x6_r0_body.cx0_42.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P42.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P42.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt42 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_42.mlx.next PRE_first_tail_x6_r0_body.cx1_42.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_42.mlx.nnext PRE_first_tail_x6_r0_body.cx1_42.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband42 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P42.NL && Nat.ble PRE_first_tail_x6_r0_body.P42.NL PRE_first_tail_x6_r0_body.P42.N0 && Nat.ble PRE_first_tail_x6_r0_body.P42.N0 PRE_first_tail_x6_r0_body.cx0_42.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow42 : PRE_first_tail_x6_r0_body.kd42.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren42 : checkRenG PRE_first_tail_x6_r0_body.kd42.hnd PRE_first_tail_x6_r0_body.khinv42 (phB PRE_first_tail_x6_r0_body.cx0_42.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband42 : PRE_first_tail_x6_r0_body.kd42.checkBand PRE_first_tail_x6_r0_body.P42.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos42 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd42.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren42 : checkRenG PRE_first_tail_x6_r0_body.kd42.node PRE_first_tail_x6_r0_body.kninv42 (pnB PRE_first_tail_x6_r0_body.cx0_42.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow42 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd42.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P42.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd42.nodeF j) PRE_first_tail_x6_r0_body.cx1_42.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a42 : PRE_first_tail_x6_r0_body.cx0_42.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b42 : PRE_first_tail_x6_r0_body.cx0_42.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok142 : PRE_first_tail_x6_r0_body.cx1_42.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend42 : PRE_first_tail_x6_r0_body.cx1_42.mlx.pending = PRE_first_tail_x6_r0_body.cx0_42.mlx.pending.map PRE_first_tail_x6_r0_body.kappa42.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh42 : PRE_first_tail_x6_r0_body.cx1_42.mlx.errh = PRE_first_tail_x6_r0_body.cx0_42.mlx.errh.map PRE_first_tail_x6_r0_body.kappa42.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles42 : PRE_first_tail_x6_r0_body.cx1_42.mlx.files = PRE_first_tail_x6_r0_body.cx0_42.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch42 : PRE_first_tail_x6_r0_body.cx1_42.mlx.arch = PRE_first_tail_x6_r0_body.cx0_42.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes42 : PRE_first_tail_x6_r0_body.cx1_42.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_42.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired42 : PRE_first_tail_x6_r0_body.cx1_42.mlx.wired = PRE_first_tail_x6_r0_body.cx0_42.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost42 : PRE_first_tail_x6_r0_body.cx1_42.host = PRE_first_tail_x6_r0_body.cx0_42.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd42`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn042 : PRE_first_tail_x6_r0_body.kd42.n0 = 2708225
kernel_rfl PRE_first_tail_x6_r0_body.ckn142 : PRE_first_tail_x6_r0_body.kd42.n1 = 2709374
kernel_rfl PRE_first_tail_x6_r0_body.ckheap42 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd42.heap).all (fun x => Nat.ble 2708219 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl42 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd42.heap.get (2708219 + j) = nth? PRE_first_tail_x6_r0_body.pl42 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja42 : Nat.ble 2708219 2708219 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn42 : Nat.ble 1880 1880 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD42 : Nat.ble 2708219 PRE_first_tail_x6_r0_body.kd42.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn42 : Nat.ble 19038 PRE_first_tail_x6_r0_body.kd42.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn42 : Nat.ble 16115 PRE_first_tail_x6_r0_body.kd42.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb42 : Nat.ble 19038 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap42 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd42.heap).all (Nat.ble (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd42 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd42.hnd).all (Nat.ble (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode42 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd42.node).all (Nat.ble (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix42 : Conv.FixOld (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa42 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja42) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn42) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD42) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn42) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn42) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb42) PRE_first_tail_x6_r0_body.fheap42 PRE_first_tail_x6_r0_body.fhnd42 PRE_first_tail_x6_r0_body.fnode42
kernel_rfl PRE_first_tail_x6_r0_body.fcxn42 : (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn42 : (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle042 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_42.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_42.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk42 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd42.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A42 : PRE_first_tail_x6_r0_body.cx1_42.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS42.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_42.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O42 : PRE_first_tail_x6_r0_body.cx1_42.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS42.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_42.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N42 : PRE_first_tail_x6_r0_body.cx1_42.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS42.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_42.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I42 : PRE_first_tail_x6_r0_body.cx1_42.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS42.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_42.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd42 : (PRE_first_tail_x6_r0_body.clo42 ++ PRE_first_tail_x6_r0_body.cln42 ++ PRE_first_tail_x6_r0_body.cli42 ++ PRE_first_tail_x6_r0_body.cwS42 ++ PRE_first_tail_x6_r0_body.cnS42 ++ PRE_first_tail_x6_r0_body.ciS42).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW42 : PRE_first_tail_x6_r0_body.cwS42.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo42.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI42 : PRE_first_tail_x6_r0_body.ciS42.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli42.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN42 : PRE_first_tail_x6_r0_body.cnS42.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF42 : PRE_first_tail_x6_r0_body.cln42.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh42 : PRE_first_tail_x6_r0_body.clo42.all (handleOK PRE_first_tail_x6_r0_body.kappa42 PRE_first_tail_x6_r0_body.P42.lo PRE_first_tail_x6_r0_body.cx0_42.mlx PRE_first_tail_x6_r0_body.cx1_42.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo42 : PRE_first_tail_x6_r0_body.clo42.map (fun h => PRE_first_tail_x6_r0_body.cx1_42.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa42.handle h)) = PRE_first_tail_x6_r0_body.clo42.map (fun h => (PRE_first_tail_x6_r0_body.cx0_42.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa42.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok42 : PRE_first_tail_x6_r0_body.clo42.all (objOK PRE_first_tail_x6_r0_body.kappa42 PRE_first_tail_x6_r0_body.P42.NL PRE_first_tail_x6_r0_body.cx0_42.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd42 : PRE_first_tail_x6_r0_body.cln42.all (nodeOKF PRE_first_tail_x6_r0_body.kappa42 PRE_first_tail_x6_r0_body.P42 PRE_first_tail_x6_r0_body.cx0_42.mlx PRE_first_tail_x6_r0_body.cx1_42.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp42 : ((PRE_first_tail_x6_r0_body.cln42.filter (fullB PRE_first_tail_x6_r0_body.P42))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_42.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa42.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln42.filter (fullB PRE_first_tail_x6_r0_body.P42))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_42.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa42.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI42 : incrB PRE_first_tail_x6_r0_body.kd42.nodeF (List.range' 16115 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK42 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd42.node).all (fun k => Nat.ble 16115 k && Nat.blt k 16142) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL42 : (PRE_first_tail_x6_r0_body.cln42.filter (Nat.ble PRE_first_tail_x6_r0_body.P42.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd42.nodeF i) && (Nat.blt i 16142 || Nat.ble PRE_first_tail_x6_r0_body.kd42.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord42 : (PRE_first_tail_x6_r0_body.cln42.filter (Nat.ble PRE_first_tail_x6_r0_body.P42.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd42.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd42.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd42.nodeF j) (PRE_first_tail_x6_r0_body.kd42.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow42 PRE_first_tail_x6_r0_body.cnn142 PRE_first_tail_x6_r0_body.fnordI42 PRE_first_tail_x6_r0_body.fnordK42 PRE_first_tail_x6_r0_body.fnordL42
kernel_rfl PRE_first_tail_x6_r0_body.fi42 : PRE_first_tail_x6_r0_body.cli42.all (pnB PRE_first_tail_x6_r0_body.cx0_42.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii42 : PRE_first_tail_x6_r0_body.cli42.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_42.mlx.items.get (PRE_first_tail_x6_r0_body.kappa42.node k) = (PRE_first_tail_x6_r0_body.cx0_42.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa42.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot42 (clean : Conv.NClean (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P42.NL) (cl : SSt (· < 1898) PRE_first_tail_x6_r0_body.cx0_42.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P42 1898 PRE_first_tail_x6_r0_body.kappa42 PRE_first_tail_x6_r0_body.kd42 PRE_first_tail_x6_r0_body.khinv42 PRE_first_tail_x6_r0_body.kninv42 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx PRE_first_tail_x6_r0_body.cx0_42.mlx PRE_first_tail_x6_r0_body.cx1_42.mlx (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo42 PRE_first_tail_x6_r0_body.cln42 PRE_first_tail_x6_r0_body.cli42 PRE_first_tail_x6_r0_body.cwS42 PRE_first_tail_x6_r0_body.cnS42 PRE_first_tail_x6_r0_body.ciS42 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh042, PRE_first_tail_x6_r0_body.cnh142, PRE_first_tail_x6_r0_body.cnn042, PRE_first_tail_x6_r0_body.cnn142, PRE_first_tail_x6_r0_body.cplo42, PRE_first_tail_x6_r0_body.ccnt42, PRE_first_tail_x6_r0_body.cnband42, PRE_first_tail_x6_r0_body.chbelow42, PRE_first_tail_x6_r0_body.chren42, PRE_first_tail_x6_r0_body.cband42, PRE_first_tail_x6_r0_body.cnh1pos42, PRE_first_tail_x6_r0_body.cnren42, PRE_first_tail_x6_r0_body.cnlow42, PRE_first_tail_x6_r0_body.cabs0a42, PRE_first_tail_x6_r0_body.cabs0b42, PRE_first_tail_x6_r0_body.ctok142, PRE_first_tail_x6_r0_body.cpend42, PRE_first_tail_x6_r0_body.cerrh42, PRE_first_tail_x6_r0_body.cfiles42, PRE_first_tail_x6_r0_body.carch42, PRE_first_tail_x6_r0_body.csizes42, PRE_first_tail_x6_r0_body.cwired42, PRE_first_tail_x6_r0_body.cfix42, clean, PRE_first_tail_x6_r0_body.fcxn42, PRE_first_tail_x6_r0_body.fcnn42, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle042, PRE_first_tail_x6_r0_body.fnk42, PRE_first_tail_x6_r0_body.ckA42, PRE_first_tail_x6_r0_body.cobjsK42, PRE_first_tail_x6_r0_body.cnodesK42, PRE_first_tail_x6_r0_body.citemsK42, PRE_first_tail_x6_r0_body.f1A42, PRE_first_tail_x6_r0_body.f1O42, PRE_first_tail_x6_r0_body.f1N42, PRE_first_tail_x6_r0_body.f1I42, PRE_first_tail_x6_r0_body.fbd42, PRE_first_tail_x6_r0_body.fincW42, PRE_first_tail_x6_r0_body.fincI42, PRE_first_tail_x6_r0_body.fincN42, PRE_first_tail_x6_r0_body.flnF42, PRE_first_tail_x6_r0_body.fh42, PRE_first_tail_x6_r0_body.fo42, PRE_first_tail_x6_r0_body.fok42, PRE_first_tail_x6_r0_body.fnd42, PRE_first_tail_x6_r0_body.fp42, PRE_first_tail_x6_r0_body.fnord42, PRE_first_tail_x6_r0_body.fi42, PRE_first_tail_x6_r0_body.fii42⟩
theorem PRE_first_tail_x6_r0_body.cnshift42 (clean : Conv.NClean (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P42.NL) (cl : SSt (· < 1898) PRE_first_tail_x6_r0_body.cx0_42.mlx) : NShift PRE_first_tail_x6_r0_body.P42 1898 PRE_first_tail_x6_r0_body.kappa42 PRE_first_tail_x6_r0_body.cx0_42 PRE_first_tail_x6_r0_body.cx1_42 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot42 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost42 (compact_a_eq PRE_first_tail_x6_r0_body.ckn042 PRE_first_tail_x6_r0_body.ckn142 PRE_first_tail_x6_r0_body.ckheap42 PRE_first_tail_x6_r0_body.ckpl42)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_42 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s419.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_42 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s419.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_42 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s419.ffi) = some PRE_first_tail_x6_r0_body.fxC_42
kernel_rfl PRE_first_tail_x6_r0_body.okrC_42 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s419.ffi) = some PRE_first_tail_x6_r0_body.krC_42
noncomputable def PRE_first_tail_x6_r0_body.fx0_42 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s421.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_42 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s421.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_42 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s421.ffi) = some PRE_first_tail_x6_r0_body.fx0_42
kernel_rfl PRE_first_tail_x6_r0_body.okr0_42 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s421.ffi) = some PRE_first_tail_x6_r0_body.kr0_42
noncomputable def PRE_first_tail_x6_r0_body.fx1_42 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s420.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_42 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s420.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_42 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s420.ffi) = some PRE_first_tail_x6_r0_body.fx1_42
kernel_rfl PRE_first_tail_x6_r0_body.okr1_42 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s420.ffi) = some PRE_first_tail_x6_r0_body.kr1_42
kernel_rfl PRE_first_tail_x6_r0_body.ff042 : PRE_first_tail_x6_r0_body.fx0_42 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_42 (PRE_first_tail_x6_r0_body.clo42.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_42.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff142 : PRE_first_tail_x6_r0_body.fx1_42 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_42 (PRE_first_tail_x6_r0_body.cwS42.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_42.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck42 : freedLB PRE_first_tail_x6_r0_body.kappa42 PRE_first_tail_x6_r0_body.cx0_42.mlx PRE_first_tail_x6_r0_body.fx0_42 PRE_first_tail_x6_r0_body.fx1_42 PRE_first_tail_x6_r0_body.clo42 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf042 : PRE_first_tail_x6_r0_body.kr0_42.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_42.flags (PRE_first_tail_x6_r0_body.clo42.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_42.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt042 : PRE_first_tail_x6_r0_body.kr0_42.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_42.targs (PRE_first_tail_x6_r0_body.clo42.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_42.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf142 : PRE_first_tail_x6_r0_body.kr1_42.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_42.flags (PRE_first_tail_x6_r0_body.cwS42.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_42.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt142 : PRE_first_tail_x6_r0_body.kr1_42.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_42.targs (PRE_first_tail_x6_r0_body.cwS42.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_42.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck42 : krecLB PRE_first_tail_x6_r0_body.kappa42 1898 PRE_first_tail_x6_r0_body.cx0_42.mlx PRE_first_tail_x6_r0_body.kr0_42 PRE_first_tail_x6_r0_body.kr1_42 PRE_first_tail_x6_r0_body.clo42 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn42 : Nat.ble 1880 1898 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge42 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s420.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s421.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR42 : pendRegB PRE_first_tail_x6_r0_body.kappa42 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe42 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s421.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s420.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift42 (clean : Conv.NClean (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P42.NL) (cl : SSt (· < 1898) PRE_first_tail_x6_r0_body.cx0_42.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_42.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_42.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_42.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s419.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_42.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P42 1898 PRE_first_tail_x6_r0_body.kappa42 PRE_first_tail_x6_r0_body.s421.ffi PRE_first_tail_x6_r0_body.s420.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift42 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue42, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp42 t ht),
    PRE_first_tail_x6_r0_body.cbridge42,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s421.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s420.ffi) (PRE_first_tail_x6_r0_body.cfoot42 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_42 PRE_first_tail_x6_r0_body.ofx1_42 hobjC PRE_first_tail_x6_r0_body.ff042 PRE_first_tail_x6_r0_body.ff142 PRE_first_tail_x6_r0_body.ffck42,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s421.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s420.ffi) (PRE_first_tail_x6_r0_body.cfoot42 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_42 PRE_first_tail_x6_r0_body.okr1_42 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn42) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf042 PRE_first_tail_x6_r0_body.fkt042 PRE_first_tail_x6_r0_body.fkf142 PRE_first_tail_x6_r0_body.fkt142 PRE_first_tail_x6_r0_body.fkck42,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh042 PRE_first_tail_x6_r0_body.cnh142 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe42) PRE_first_tail_x6_r0_body.cpendR42⟩

end Host.Load.Run.Tpl
end

section -- st42/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st42 0
host_stream_state PRE_first_tail_x6_r0_body.st42 1
host_stream_state PRE_first_tail_x6_r0_body.st42 2
host_stream_state PRE_first_tail_x6_r0_body.st42 3
host_stream_state PRE_first_tail_x6_r0_body.st42 4
host_stream_state PRE_first_tail_x6_r0_body.st42 5
end Host.Load.Run.Tpl
end

section -- Site42
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 42 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g42__g43` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s419`, the merged state `PRE_first_tail_x6_r0_body.s420`,
the site template `PRE_first_tail_x6_r0_body.st42` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s421`: the merge.
The footprint's facts are in `SiteF42`, the compaction's in `SiteC42`, `SiteK42`, `SiteNa42`, `SiteNb42`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso42 : PRE_first_tail_x6_r0_body.st42.s0 = { PRE_first_tail_x6_r0_body.s419 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs42 : List Frame := PRE_first_tail_x6_r0_body.s419.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_42 : PRE_first_tail_x6_r0_body.S419.tab.length = 1880
kernel_rfl PRE_first_tail_x6_r0_body.tab0_42 : PRE_first_tail_x6_r0_body.st42.S0.tab = PRE_first_tail_x6_r0_body.S419.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws42 : List Nat := [1705, 1706, 1707, 1708, 1709, 1710, 1711, 1712, 1713, 1714, 1715, 1716, 1717, 1718, 1719, 1720, 1721, 1722, 1723, 1724, 1725, 1726, 1727, 1728, 1729, 1730, 1731, 1732, 1733, 1734, 1735]
kernel_rfl PRE_first_tail_x6_r0_body.fresh42 : (PRE_first_tail_x6_r0_body.S419.tab.all fun e => PRE_first_tail_x6_r0_body.ws42.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S419.oracle.all fun q => PRE_first_tail_x6_r0_body.ws42.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab42 : PRE_first_tail_x6_r0_body.S420.tab = PRE_first_tail_x6_r0_body.S419.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws42
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen42 : PRE_first_tail_x6_r0_body.st42.S5.tab.length - PRE_first_tail_x6_r0_body.st42.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged42`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap42 : PRE_first_tail_x6_r0_body.s420.heap = PRE_first_tail_x6_r0_body.st42.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext42 : PRE_first_tail_x6_r0_body.s420.next = PRE_first_tail_x6_r0_body.st42.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl42 : PRE_first_tail_x6_r0_body.s420.ctl = PRE_first_tail_x6_r0_body.st42.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack42 : PRE_first_tail_x6_r0_body.s420.stack = PRE_first_tail_x6_r0_body.st42.s5.stack ++ PRE_first_tail_x6_r0_body.s419.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs42 : PRE_first_tail_x6_r0_body.s420.jobs = PRE_first_tail_x6_r0_body.st42.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi42 : PRE_first_tail_x6_r0_body.s420.ffi = PRE_first_tail_x6_r0_body.st42.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace42 : PRE_first_tail_x6_r0_body.s420.trace = PRE_first_tail_x6_r0_body.st42.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores42 : PRE_first_tail_x6_r0_body.s420.stores = PRE_first_tail_x6_r0_body.st42.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD42
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 42 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived42 : PRE_first_tail_x6_r0_body.nr42.map (fun r => nth? PRE_first_tail_x6_r0_body.st42.S5.tab r) =
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
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo42 : PRE_first_tail_x6_r0_body.nr42.all (Nat.ble 1880) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj42 : PRE_first_tail_x6_r0_body.cws42.all (fun c => !PRE_first_tail_x6_r0_body.ws42.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ42 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws42 PRE_first_tail_x6_r0_body.crs42 PRE_first_tail_x6_r0_body.ws42

end Host.Load.Run.Tpl
end

section -- st42/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st42`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st42.wrR : List (Nat × Nat) := [(2672403, 2672404), (2707393, 2707394), (2707938, 2707939), (2708194, 2708195)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st42.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st42.s5.heap PRE_first_tail_x6_r0_body.st42.wrR ++ freshOf PRE_first_tail_x6_r0_body.st42.s5.heap PRE_first_tail_x6_r0_body.st42.s0.next PRE_first_tail_x6_r0_body.st42.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st42.wr : List Nat := PRE_first_tail_x6_r0_body.st42.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st42.heapFoot : PRE_first_tail_x6_r0_body.st42.s5.heap = setAll PRE_first_tail_x6_r0_body.st42.s0.heap PRE_first_tail_x6_r0_body.st42.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st42.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st42.s0.next PRE_first_tail_x6_r0_body.st42.s5.next = true
theorem PRE_first_tail_x6_r0_body.st42.grows : PRE_first_tail_x6_r0_body.st42.s0.next ≤ PRE_first_tail_x6_r0_body.st42.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st42.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st42.wh : List Nat := [19018, 19031, 19037, 19038, 19039, 19040, 19041, 19042, 19043, 19044, 19045, 19046, 19047, 19048, 19049, 19050, 19051, 19052, 19053, 19054, 19055, 19056, 19057, 19058, 19059, 19060, 19061, 19062, 19063, 19064, 19065]
def PRE_first_tail_x6_r0_body.st42.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st42.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st42.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st42.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st42.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st42.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st42.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st42.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st42.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st42.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF42
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 42 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB42 : nodupT PRE_first_tail_x6_r0_body.st42.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup42 : PRE_first_tail_x6_r0_body.st42.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB42).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB42 : PRE_first_tail_x6_r0_body.st42.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound42 : ∀ b ∈ PRE_first_tail_x6_r0_body.st42.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB42 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr42 := PRE_first_tail_x6_r0_body.st42.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq42 : PRE_first_tail_x6_r0_body.st42.s5.trace = PRE_first_tail_x6_r0_body.trFr42 ++ PRE_first_tail_x6_r0_body.st42.s0.trace
theorem PRE_first_tail_x6_r0_body.trace42 : ∃ fr, PRE_first_tail_x6_r0_body.st42.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st42.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq42⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide42 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB42 : (PRE_first_tail_x6_r0_body.wide42.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st42.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix42 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide42, WFix Map.id (Present PRE_first_tail_x6_r0_body.st42.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB42 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL42
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 42 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s420`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO42 : PRE_first_tail_x6_r0_body.st42.S0.oracle = PRE_first_tail_x6_r0_body.st42.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B42 : PRE_first_tail_x6_r0_body.st42.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st42.s0.next || (PRE_first_tail_x6_r0_body.st42.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot42 : Conv.StageFoot PRE_first_tail_x6_r0_body.st42.wr PRE_first_tail_x6_r0_body.st42.s0 PRE_first_tail_x6_r0_body.st42.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st42.heapFoot PRE_first_tail_x6_r0_body.wrNodup42 PRE_first_tail_x6_r0_body.wrBound42 PRE_first_tail_x6_r0_body.wr0B42 PRE_first_tail_x6_r0_body.st42.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged42 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st42.F.S → PRE_first_tail_x6_r0_body.st42.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st42.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st42.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs42 PRE_first_tail_x6_r0_body.st42.wr PRE_first_tail_x6_r0_body.s419 PRE_first_tail_x6_r0_body.st42.s5 PRE_first_tail_x6_r0_body.st42.s0
      PRE_first_tail_x6_r0_body.st42.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st42.F FR W stk M ν K PRE_first_tail_x6_r0_body.s420 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso42 PRE_first_tail_x6_r0_body.stFoot42 PRE_first_tail_x6_r0_body.wrNodup42 PRE_first_tail_x6_r0_body.wrBound42 PRE_first_tail_x6_r0_body.trace42 PRE_first_tail_x6_r0_body.mheap42
    PRE_first_tail_x6_r0_body.mnext42 PRE_first_tail_x6_r0_body.mctl42 PRE_first_tail_x6_r0_body.mstack42 PRE_first_tail_x6_r0_body.mjobs42 PRE_first_tail_x6_r0_body.mffi42 PRE_first_tail_x6_r0_body.mtrace42 PRE_first_tail_x6_r0_body.mstores42 h

def PRE_first_tail_x6_r0_body.arrEl42_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE42_2665 : arrOf PRE_first_tail_x6_r0_body.s420 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl42_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA42_2665 : isArrB PRE_first_tail_x6_r0_body.s420 2665 = true
theorem PRE_first_tail_x6_r0_body.arr42_2665 : ∃ o, PRE_first_tail_x6_r0_body.s420.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl42_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE42_2665 PRE_first_tail_x6_r0_body.arrA42_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN42_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl42_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR42_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl42_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN42_2665

def PRE_first_tail_x6_r0_body.arrEl42_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE42_2673467 : arrOf PRE_first_tail_x6_r0_body.s420 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl42_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA42_2673467 : isArrB PRE_first_tail_x6_r0_body.s420 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr42_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s420.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl42_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE42_2673467 PRE_first_tail_x6_r0_body.arrA42_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN42_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl42_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR42_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl42_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN42_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k42 : isArrB PRE_first_tail_x6_r0_body.s420 4910 = false
theorem PRE_first_tail_x6_r0_body.keep42 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s420 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k42 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr42_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl42_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ42
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 42 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s419`, the merged
state `PRE_first_tail_x6_r0_body.s420`, the canonical state `PRE_first_tail_x6_r0_body.s421`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl42 : PRE_first_tail_x6_r0_body.pl42.all (Nat.ble PRE_first_tail_x6_r0_body.s419.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd42 : nodupT PRE_first_tail_x6_r0_body.pl42 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn142 : Nat.ble PRE_first_tail_x6_r0_body.s419.next 2709374 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst42 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s419.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn42 : PRE_first_tail_x6_r0_body.s421.next = PRE_first_tail_x6_r0_body.s419.next + PRE_first_tail_x6_r0_body.pl42.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn42 : PRE_first_tail_x6_r0_body.s420.next = 2709374
kernel_rfl PRE_first_tail_x6_r0_body.zgrow42 : Nat.ble PRE_first_tail_x6_r0_body.s421.next PRE_first_tail_x6_r0_body.s420.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh42 : PRE_first_tail_x6_r0_body.S419.tab.all (fun e => PRE_first_tail_x6_r0_body.cws42.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd42 : nodupT PRE_first_tail_x6_r0_body.cws42 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi42 : PRE_first_tail_x6_r0_body.nr42.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S420.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt42 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s419.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg42_2665 : PRE_first_tail_x6_r0_body.s421.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s421 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk42_2665 : (objOf PRE_first_tail_x6_r0_body.s421 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm42_2665 : PRE_first_tail_x6_r0_body.s420.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa42.obj (objOf PRE_first_tail_x6_r0_body.s421 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s420 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg42_2673467 : PRE_first_tail_x6_r0_body.s421.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s421 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk42_2673467 : (objOf PRE_first_tail_x6_r0_body.s421 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm42_2673467 : PRE_first_tail_x6_r0_body.s420.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa42.obj (objOf PRE_first_tail_x6_r0_body.s421 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s420 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw42_4910 : (PRE_first_tail_x6_r0_body.s421.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw42_2673472 : (PRE_first_tail_x6_r0_body.s421.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw42_2673473 : (PRE_first_tail_x6_r0_body.s421.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd42 : PRE_first_tail_x6_r0_body.cl42.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr42 : PRE_first_tail_x6_r0_body.st42.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s419.next || PRE_first_tail_x6_r0_body.cl42.contains b) = true
def PRE_first_tail_x6_r0_body.zl42 : List Nat := PRE_first_tail_x6_r0_body.cl42.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE42 : PRE_first_tail_x6_r0_body.zl42.map (fun a => PRE_first_tail_x6_r0_body.s420.heap.get (PRE_first_tail_x6_r0_body.kappa42.a a)) = PRE_first_tail_x6_r0_body.zl42.map (fun a => (PRE_first_tail_x6_r0_body.s421.heap.get a).map PRE_first_tail_x6_r0_body.kappa42.hobj)
theorem PRE_first_tail_x6_r0_body.zimg42 : HeapImg PRE_first_tail_x6_r0_body.kappa42 PRE_first_tail_x6_r0_body.s421 PRE_first_tail_x6_r0_body.s420 PRE_first_tail_x6_r0_body.zl42 := PRE_first_tail_x6_r0_body.zimgE42
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl42 : PRE_first_tail_x6_r0_body.s420.ctl = PRE_first_tail_x6_r0_body.kappa42.ctl PRE_first_tail_x6_r0_body.s421.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack42 : PRE_first_tail_x6_r0_body.s420.stack = PRE_first_tail_x6_r0_body.s421.stack.map PRE_first_tail_x6_r0_body.kappa42.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs42 : PRE_first_tail_x6_r0_body.s420.jobs = PRE_first_tail_x6_r0_body.s421.jobs.map PRE_first_tail_x6_r0_body.kappa42.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores42 : PRE_first_tail_x6_r0_body.s420.stores = PRE_first_tail_x6_r0_body.kappa42.stores PRE_first_tail_x6_r0_body.s421.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots42 : checkRootsSupp PRE_first_tail_x6_r0_body.s421 1898 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC42 : PRE_first_tail_x6_r0_body.S419.tab.length + PRE_first_tail_x6_r0_body.cws42.length = 1898
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap42 : PRE_first_tail_x6_r0_body.kappa42 = Conv.Map.compact PRE_first_tail_x6_r0_body.s419.next 2709374 PRE_first_tail_x6_r0_body.S419.tab.length PRE_first_tail_x6_r0_body.pl42 (PRE_first_tail_x6_r0_body.nr42.map NumV.ref) PRE_first_tail_x6_r0_body.kd42.big
  PRE_first_tail_x6_r0_body.kd42.region PRE_first_tail_x6_r0_body.kd42.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin42 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s421.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc42 : Conv.jcleanListB (⟨19041, 16142, 2708225, 1898⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s421 PRE_first_tail_x6_r0_body.cl42 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB42 : noBigRootsP (fun i => !Conv.oldBigB (⟨19041, 16142, 2708225, 1898⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s421.trace PRE_first_tail_x6_r0_body.s421 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm42 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 16115 = true
theorem PRE_first_tail_x6_r0_body.cjcl42 (h : Conv.JClean (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s419) : Conv.JClean (⟨19041, 16142, 2708225, 1898⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s421 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle42)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap42 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd42 a ha)) PRE_first_tail_x6_r0_body.zjc42

end Host.Load.Run.Tpl
end

section -- st42/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st42.bodyLast from PRE_first_tail_x6_r0_body.st42.s4 to PRE_first_tail_x6_r0_body.st42.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st42.F PRE_first_tail_x6_r0_body.st42.s4).run PRE_first_tail_x6_r0_body.st42.S4 = some (PRE_first_tail_x6_r0_body.st42.s5, PRE_first_tail_x6_r0_body.st42.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st42.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st42.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st42.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st42.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st42/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st42.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st42.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st42.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st42.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st42.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st42.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st42.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st42.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st42.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st42.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st42.s0 PRE_first_tail_x6_r0_body.st42.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st42.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st42.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st42.s4 PRE_first_tail_x6_r0_body.st42.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st42/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st42.bodyK0F from PRE_first_tail_x6_r0_body.st42.s0 to PRE_first_tail_x6_r0_body.st42.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st42.F (PRE_first_tail_x6_r0_body.st42.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st42.ks 0).getD 0) PRE_first_tail_x6_r0_body.st42.s0 PRE_first_tail_x6_r0_body.st42.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st42.s1, PRE_first_tail_x6_r0_body.st42.S1)
theorem PRE_first_tail_x6_r0_body.st42.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st42.F (PRE_first_tail_x6_r0_body.st42.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st42.ks 0).getD 0) PRE_first_tail_x6_r0_body.st42.s0 PRE_first_tail_x6_r0_body.st42.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st42.s1, PRE_first_tail_x6_r0_body.st42.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st42.bodyOkLN_ok PRE_first_tail_x6_r0_body.st42.bodyK0F
end Host.Load.Run.Tpl
end

section -- st42/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st42.bodyK1F from PRE_first_tail_x6_r0_body.st42.s1 to PRE_first_tail_x6_r0_body.st42.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st42.F (PRE_first_tail_x6_r0_body.st42.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st42.ks 1).getD 0) PRE_first_tail_x6_r0_body.st42.s1 PRE_first_tail_x6_r0_body.st42.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st42.s2, PRE_first_tail_x6_r0_body.st42.S2)
theorem PRE_first_tail_x6_r0_body.st42.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st42.F (PRE_first_tail_x6_r0_body.st42.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st42.ks 1).getD 0) PRE_first_tail_x6_r0_body.st42.s1 PRE_first_tail_x6_r0_body.st42.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st42.s2, PRE_first_tail_x6_r0_body.st42.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st42.bodyOkLN_ok PRE_first_tail_x6_r0_body.st42.bodyK1F
end Host.Load.Run.Tpl
end

section -- st42/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st42.bodyK2F from PRE_first_tail_x6_r0_body.st42.s2 to PRE_first_tail_x6_r0_body.st42.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st42.F (PRE_first_tail_x6_r0_body.st42.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st42.ks 2).getD 0) PRE_first_tail_x6_r0_body.st42.s2 PRE_first_tail_x6_r0_body.st42.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st42.s3, PRE_first_tail_x6_r0_body.st42.S3)
theorem PRE_first_tail_x6_r0_body.st42.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st42.F (PRE_first_tail_x6_r0_body.st42.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st42.ks 2).getD 0) PRE_first_tail_x6_r0_body.st42.s2 PRE_first_tail_x6_r0_body.st42.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st42.s3, PRE_first_tail_x6_r0_body.st42.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st42.bodyOkLN_ok PRE_first_tail_x6_r0_body.st42.bodyK2F
end Host.Load.Run.Tpl
end

section -- st42/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st42.bodyK3F from PRE_first_tail_x6_r0_body.st42.s3 to PRE_first_tail_x6_r0_body.st42.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st42.F (PRE_first_tail_x6_r0_body.st42.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st42.ks 3).getD 0) PRE_first_tail_x6_r0_body.st42.s3 PRE_first_tail_x6_r0_body.st42.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st42.s4, PRE_first_tail_x6_r0_body.st42.S4)
theorem PRE_first_tail_x6_r0_body.st42.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st42.F (PRE_first_tail_x6_r0_body.st42.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st42.ks 3).getD 0) PRE_first_tail_x6_r0_body.st42.s3 PRE_first_tail_x6_r0_body.st42.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st42.s4, PRE_first_tail_x6_r0_body.st42.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st42.bodyOkLN_ok PRE_first_tail_x6_r0_body.st42.bodyK3F
end Host.Load.Run.Tpl
end

section -- st42/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st42.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st42.F (PRE_first_tail_x6_r0_body.st42.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st42.s0 PRE_first_tail_x6_r0_body.st42.S0 = some (PRE_first_tail_x6_r0_body.st42.s4, PRE_first_tail_x6_r0_body.st42.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st42.F (PRE_first_tail_x6_r0_body.st42.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st42.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st42.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st42.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st42.ks 3).getD 0) PRE_first_tail_x6_r0_body.st42.s0 PRE_first_tail_x6_r0_body.st42.s3 PRE_first_tail_x6_r0_body.st42.s4 PRE_first_tail_x6_r0_body.st42.S0 PRE_first_tail_x6_r0_body.st42.S3 PRE_first_tail_x6_r0_body.st42.S4 (runOk_trans PRE_first_tail_x6_r0_body.st42.F (PRE_first_tail_x6_r0_body.st42.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st42.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st42.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st42.ks 2).getD 0) PRE_first_tail_x6_r0_body.st42.s0 PRE_first_tail_x6_r0_body.st42.s2 PRE_first_tail_x6_r0_body.st42.s3 PRE_first_tail_x6_r0_body.st42.S0 PRE_first_tail_x6_r0_body.st42.S2 PRE_first_tail_x6_r0_body.st42.S3 (runOk_trans PRE_first_tail_x6_r0_body.st42.F (PRE_first_tail_x6_r0_body.st42.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st42.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st42.ks 1).getD 0) PRE_first_tail_x6_r0_body.st42.s0 PRE_first_tail_x6_r0_body.st42.s1 PRE_first_tail_x6_r0_body.st42.s2 PRE_first_tail_x6_r0_body.st42.S0 PRE_first_tail_x6_r0_body.st42.S1 PRE_first_tail_x6_r0_body.st42.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st42.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st42.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st42.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st42.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st42.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st42.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st42.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st42.F (PRE_first_tail_x6_r0_body.st42.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st42.s0
  S0 := PRE_first_tail_x6_r0_body.st42.S0
  s1 := PRE_first_tail_x6_r0_body.st42.s4
  S1 := PRE_first_tail_x6_r0_body.st42.S4
  s2 := PRE_first_tail_x6_r0_body.st42.s5
  S2 := PRE_first_tail_x6_r0_body.st42.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st42.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st42.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st42.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st42.bodyHalt
  last := PRE_first_tail_x6_r0_body.st42.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st42.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC43
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 43 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s429` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa43` into the merged state
`PRE_first_tail_x6_r0_body.s428`. -/

def PRE_first_tail_x6_r0_body.pl43 : List Nat := []
def PRE_first_tail_x6_r0_body.nr43 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd43 : RData :=
  ⟨2708715, 2708717, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19054, 19054, 16155, 16155, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa43 : Map :=
  Conv.Map.compact 2708715 2708717 1919 PRE_first_tail_x6_r0_body.pl43 (PRE_first_tail_x6_r0_body.nr43.map NumV.ref) PRE_first_tail_x6_r0_body.kd43.big
    PRE_first_tail_x6_r0_body.kd43.region PRE_first_tail_x6_r0_body.kd43.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws43 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs43 : List SymE := PRE_first_tail_x6_r0_body.nr43.map fun r => (nth? PRE_first_tail_x6_r0_body.S428.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta43 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws43 PRE_first_tail_x6_r0_body.crs43
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB43 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab43 : PRE_first_tail_x6_r0_body.S429.tab = PRE_first_tail_x6_r0_body.S427.tab ++ PRE_first_tail_x6_r0_body.cws43.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace43 : PRE_first_tail_x6_r0_body.s429.trace = PRE_first_tail_x6_r0_body.s427.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext43 : PRE_first_tail_x6_r0_body.s429.next = 2708715
kernel_rfl PRE_first_tail_x6_r0_body.ccounters43 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s429.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s429.ffi).mlx.nnext) = (19054, 16155)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue43 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s428.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s429.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa43.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp43 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s429.ffi).mlx.tokens.all (bSN 1919) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean43 : Conv.cleanListB 19054 131072 (fun r => Nat.ble 76216 r) PRE_first_tail_x6_r0_body.s429
    (PRE_first_tail_x6_r0_body.wrB43 ++ (List.range 0).map (2708715 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs43 : bigsOutB 19054 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s429.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK43
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl43`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl43 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo43 : List Nat := []
def PRE_first_tail_x6_r0_body.cln43 : List Nat := []
def PRE_first_tail_x6_r0_body.cli43 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap43 : PRE_first_tail_x6_r0_body.s429.heap = Stage.setAll PRE_first_tail_x6_r0_body.s427.heap (PRE_first_tail_x6_r0_body.cl43.filterMap fun a => (PRE_first_tail_x6_r0_body.s429.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe43 : Nat.ble PRE_first_tail_x6_r0_body.s427.next PRE_first_tail_x6_r0_body.s429.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP43 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s427 PRE_first_tail_x6_r0_body.s429 PRE_first_tail_x6_r0_body.cl43 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp43 : Conv.suppListB PRE_first_tail_x6_r0_body.s429 1919 PRE_first_tail_x6_r0_body.cl43 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound43 : Conv.boundListB PRE_first_tail_x6_r0_body.s429 PRE_first_tail_x6_r0_body.cl43 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK43 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s429.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s427.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln43.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s429.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK43 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s429.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s427.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo43.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s429.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK43 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s429.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s427.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli43.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s429.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst43 : Conv.sstListB 1919 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s429.ffi).mlx PRE_first_tail_x6_r0_body.cln43 PRE_first_tail_x6_r0_body.clo43 PRE_first_tail_x6_r0_body.cli43 = true

end Host.Load.Run.Tpl
end

section -- SiteCl43
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA43 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s429.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s427.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo43.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s429.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd43 : (PRE_first_tail_x6_r0_body.clo43 ++ PRE_first_tail_x6_r0_body.cln43 ++ PRE_first_tail_x6_r0_body.cli43).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle43 : Conv.Cnt.leB (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck43 : Conv.ncleanListB (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s429.ffi).mlx PRE_first_tail_x6_r0_body.clo43 PRE_first_tail_x6_r0_body.cln43 PRE_first_tail_x6_r0_body.cli43 = true
theorem PRE_first_tail_x6_r0_body.cncl43 (h : Conv.NClean (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s427.ffi).mlx) : Conv.NClean (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s429.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle43 PRE_first_tail_x6_r0_body.ckA43 PRE_first_tail_x6_r0_body.cobjsK43 PRE_first_tail_x6_r0_body.cnodesK43 PRE_first_tail_x6_r0_body.citemsK43 PRE_first_tail_x6_r0_body.cbd43 PRE_first_tail_x6_r0_body.cck43

end Host.Load.Run.Tpl
end

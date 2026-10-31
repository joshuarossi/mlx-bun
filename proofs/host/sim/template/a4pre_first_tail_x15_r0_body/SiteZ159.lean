import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS159
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK159
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF159
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 159 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1406`, the merged
state `PRE_first_tail_x15_r0_body.s1407`, the canonical state `PRE_first_tail_x15_r0_body.s1408`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl159 : PRE_first_tail_x15_r0_body.pl159.all (Nat.ble PRE_first_tail_x15_r0_body.s1406.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd159 : nodupT PRE_first_tail_x15_r0_body.pl159 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1159 : Nat.ble PRE_first_tail_x15_r0_body.s1406.next 2801290 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst159 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1406.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn159 : PRE_first_tail_x15_r0_body.s1408.next = PRE_first_tail_x15_r0_body.s1406.next + PRE_first_tail_x15_r0_body.pl159.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn159 : PRE_first_tail_x15_r0_body.s1407.next = 2801290
kernel_rfl PRE_first_tail_x15_r0_body.zgrow159 : Nat.ble PRE_first_tail_x15_r0_body.s1408.next PRE_first_tail_x15_r0_body.s1407.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh159 : PRE_first_tail_x15_r0_body.S1406.tab.all (fun e => PRE_first_tail_x15_r0_body.cws159.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd159 : nodupT PRE_first_tail_x15_r0_body.cws159 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi159 : PRE_first_tail_x15_r0_body.nr159.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1407.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt159 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1406.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg159_2665 : PRE_first_tail_x15_r0_body.s1408.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1408 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk159_2665 : (objOf PRE_first_tail_x15_r0_body.s1408 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm159_2665 : PRE_first_tail_x15_r0_body.s1407.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa159.obj (objOf PRE_first_tail_x15_r0_body.s1408 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1407 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg159_2673467 : PRE_first_tail_x15_r0_body.s1408.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1408 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk159_2673467 : (objOf PRE_first_tail_x15_r0_body.s1408 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm159_2673467 : PRE_first_tail_x15_r0_body.s1407.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa159.obj (objOf PRE_first_tail_x15_r0_body.s1408 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1407 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw159_4910 : (PRE_first_tail_x15_r0_body.s1408.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw159_2673472 : (PRE_first_tail_x15_r0_body.s1408.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw159_2673473 : (PRE_first_tail_x15_r0_body.s1408.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd159 : PRE_first_tail_x15_r0_body.cl159.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr159 : PRE_first_tail_x15_r0_body.st159.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1406.next || PRE_first_tail_x15_r0_body.cl159.contains b) = true
def PRE_first_tail_x15_r0_body.zl159 : List Nat := PRE_first_tail_x15_r0_body.cl159.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE159 : PRE_first_tail_x15_r0_body.zl159.map (fun a => PRE_first_tail_x15_r0_body.s1407.heap.get (PRE_first_tail_x15_r0_body.kappa159.a a)) = PRE_first_tail_x15_r0_body.zl159.map (fun a => (PRE_first_tail_x15_r0_body.s1408.heap.get a).map PRE_first_tail_x15_r0_body.kappa159.hobj)
theorem PRE_first_tail_x15_r0_body.zimg159 : HeapImg PRE_first_tail_x15_r0_body.kappa159 PRE_first_tail_x15_r0_body.s1408 PRE_first_tail_x15_r0_body.s1407 PRE_first_tail_x15_r0_body.zl159 := PRE_first_tail_x15_r0_body.zimgE159
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl159 : PRE_first_tail_x15_r0_body.s1407.ctl = PRE_first_tail_x15_r0_body.kappa159.ctl PRE_first_tail_x15_r0_body.s1408.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack159 : PRE_first_tail_x15_r0_body.s1407.stack = PRE_first_tail_x15_r0_body.s1408.stack.map PRE_first_tail_x15_r0_body.kappa159.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs159 : PRE_first_tail_x15_r0_body.s1407.jobs = PRE_first_tail_x15_r0_body.s1408.jobs.map PRE_first_tail_x15_r0_body.kappa159.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores159 : PRE_first_tail_x15_r0_body.s1407.stores = PRE_first_tail_x15_r0_body.kappa159.stores PRE_first_tail_x15_r0_body.s1408.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots159 : checkRootsSupp PRE_first_tail_x15_r0_body.s1408 6899 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC159 : PRE_first_tail_x15_r0_body.S1406.tab.length + PRE_first_tail_x15_r0_body.cws159.length = 6899
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap159 : PRE_first_tail_x15_r0_body.kappa159 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1406.next 2801290 PRE_first_tail_x15_r0_body.S1406.tab.length PRE_first_tail_x15_r0_body.pl159 (PRE_first_tail_x15_r0_body.nr159.map NumV.ref) PRE_first_tail_x15_r0_body.kd159.big
  PRE_first_tail_x15_r0_body.kd159.region PRE_first_tail_x15_r0_body.kd159.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin159 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1408.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc159 : Conv.jcleanListB (⟨21344, 18449, 2800141, 6899⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1408 PRE_first_tail_x15_r0_body.cl159 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2159 : noBigRootsP (fun i => !Conv.oldBigB (⟨21344, 18449, 2800141, 6899⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1408.trace PRE_first_tail_x15_r0_body.s1408 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm159 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18422 = true
theorem PRE_first_tail_x15_r0_body.cjcl159 (h : Conv.JClean (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1406) : Conv.JClean (⟨21344, 18449, 2800141, 6899⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1408 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle159)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap159 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd159 a ha)) PRE_first_tail_x15_r0_body.zjc159

end Host.Load.Run.Tpl

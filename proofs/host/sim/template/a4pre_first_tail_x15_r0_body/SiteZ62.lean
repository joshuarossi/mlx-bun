import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS62
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK62
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF62
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 62 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s550`, the merged
state `PRE_first_tail_x15_r0_body.s551`, the canonical state `PRE_first_tail_x15_r0_body.s552`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl62 : PRE_first_tail_x15_r0_body.pl62.all (Nat.ble PRE_first_tail_x15_r0_body.s550.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd62 : nodupT PRE_first_tail_x15_r0_body.pl62 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn162 : Nat.ble PRE_first_tail_x15_r0_body.s550.next 2723342 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst62 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s550.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn62 : PRE_first_tail_x15_r0_body.s552.next = PRE_first_tail_x15_r0_body.s550.next + PRE_first_tail_x15_r0_body.pl62.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn62 : PRE_first_tail_x15_r0_body.s551.next = 2723342
kernel_rfl PRE_first_tail_x15_r0_body.zgrow62 : Nat.ble PRE_first_tail_x15_r0_body.s552.next PRE_first_tail_x15_r0_body.s551.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh62 : PRE_first_tail_x15_r0_body.S550.tab.all (fun e => PRE_first_tail_x15_r0_body.cws62.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd62 : nodupT PRE_first_tail_x15_r0_body.cws62 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi62 : PRE_first_tail_x15_r0_body.nr62.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S551.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt62 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s550.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg62_2665 : PRE_first_tail_x15_r0_body.s552.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s552 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk62_2665 : (objOf PRE_first_tail_x15_r0_body.s552 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm62_2665 : PRE_first_tail_x15_r0_body.s551.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa62.obj (objOf PRE_first_tail_x15_r0_body.s552 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s551 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg62_2673467 : PRE_first_tail_x15_r0_body.s552.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s552 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk62_2673467 : (objOf PRE_first_tail_x15_r0_body.s552 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm62_2673467 : PRE_first_tail_x15_r0_body.s551.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa62.obj (objOf PRE_first_tail_x15_r0_body.s552 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s551 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw62_4910 : (PRE_first_tail_x15_r0_body.s552.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw62_2673472 : (PRE_first_tail_x15_r0_body.s552.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw62_2673473 : (PRE_first_tail_x15_r0_body.s552.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd62 : PRE_first_tail_x15_r0_body.cl62.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr62 : PRE_first_tail_x15_r0_body.st62.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s550.next || PRE_first_tail_x15_r0_body.cl62.contains b) = true
def PRE_first_tail_x15_r0_body.zl62 : List Nat := PRE_first_tail_x15_r0_body.cl62.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE62 : PRE_first_tail_x15_r0_body.zl62.map (fun a => PRE_first_tail_x15_r0_body.s551.heap.get (PRE_first_tail_x15_r0_body.kappa62.a a)) = PRE_first_tail_x15_r0_body.zl62.map (fun a => (PRE_first_tail_x15_r0_body.s552.heap.get a).map PRE_first_tail_x15_r0_body.kappa62.hobj)
theorem PRE_first_tail_x15_r0_body.zimg62 : HeapImg PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.s552 PRE_first_tail_x15_r0_body.s551 PRE_first_tail_x15_r0_body.zl62 := PRE_first_tail_x15_r0_body.zimgE62
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl62 : PRE_first_tail_x15_r0_body.s551.ctl = PRE_first_tail_x15_r0_body.kappa62.ctl PRE_first_tail_x15_r0_body.s552.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack62 : PRE_first_tail_x15_r0_body.s551.stack = PRE_first_tail_x15_r0_body.s552.stack.map PRE_first_tail_x15_r0_body.kappa62.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs62 : PRE_first_tail_x15_r0_body.s551.jobs = PRE_first_tail_x15_r0_body.s552.jobs.map PRE_first_tail_x15_r0_body.kappa62.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores62 : PRE_first_tail_x15_r0_body.s551.stores = PRE_first_tail_x15_r0_body.kappa62.stores PRE_first_tail_x15_r0_body.s552.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots62 : checkRootsSupp PRE_first_tail_x15_r0_body.s552 2704 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC62 : PRE_first_tail_x15_r0_body.S550.tab.length + PRE_first_tail_x15_r0_body.cws62.length = 2704
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap62 : PRE_first_tail_x15_r0_body.kappa62 = Conv.Map.compact PRE_first_tail_x15_r0_body.s550.next 2723342 PRE_first_tail_x15_r0_body.S550.tab.length PRE_first_tail_x15_r0_body.pl62 (PRE_first_tail_x15_r0_body.nr62.map NumV.ref) PRE_first_tail_x15_r0_body.kd62.big
  PRE_first_tail_x15_r0_body.kd62.region PRE_first_tail_x15_r0_body.kd62.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin62 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s552.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc62 : Conv.jcleanListB (⟨19419, 16507, 2723332, 2704⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s552 PRE_first_tail_x15_r0_body.cl62 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots262 : noBigRootsP (fun i => !Conv.oldBigB (⟨19419, 16507, 2723332, 2704⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s552.trace PRE_first_tail_x15_r0_body.s552 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm62 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16507 = true
theorem PRE_first_tail_x15_r0_body.cjcl62 (h : Conv.JClean (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s550) : Conv.JClean (⟨19419, 16507, 2723332, 2704⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s552 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle62)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap62 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd62 a ha)) PRE_first_tail_x15_r0_body.zjc62

end Host.Load.Run.Tpl

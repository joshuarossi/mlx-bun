import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS13
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK13
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF13
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 13 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s126`, the merged
state `PRE_first_tail_x15_r0_body.s127`, the canonical state `PRE_first_tail_x15_r0_body.s128`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl13 : PRE_first_tail_x15_r0_body.pl13.all (Nat.ble PRE_first_tail_x15_r0_body.s126.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd13 : nodupT PRE_first_tail_x15_r0_body.pl13 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn113 : Nat.ble PRE_first_tail_x15_r0_body.s126.next 2685373 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst13 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s126.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn13 : PRE_first_tail_x15_r0_body.s128.next = PRE_first_tail_x15_r0_body.s126.next + PRE_first_tail_x15_r0_body.pl13.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn13 : PRE_first_tail_x15_r0_body.s127.next = 2685373
kernel_rfl PRE_first_tail_x15_r0_body.zgrow13 : Nat.ble PRE_first_tail_x15_r0_body.s128.next PRE_first_tail_x15_r0_body.s127.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh13 : PRE_first_tail_x15_r0_body.S126.tab.all (fun e => PRE_first_tail_x15_r0_body.cws13.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd13 : nodupT PRE_first_tail_x15_r0_body.cws13 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi13 : PRE_first_tail_x15_r0_body.nr13.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S127.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt13 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s126.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg13_2665 : PRE_first_tail_x15_r0_body.s128.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s128 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk13_2665 : (objOf PRE_first_tail_x15_r0_body.s128 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm13_2665 : PRE_first_tail_x15_r0_body.s127.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa13.obj (objOf PRE_first_tail_x15_r0_body.s128 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s127 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg13_2673467 : PRE_first_tail_x15_r0_body.s128.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s128 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk13_2673467 : (objOf PRE_first_tail_x15_r0_body.s128 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm13_2673467 : PRE_first_tail_x15_r0_body.s127.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa13.obj (objOf PRE_first_tail_x15_r0_body.s128 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s127 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw13_4910 : (PRE_first_tail_x15_r0_body.s128.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw13_2673472 : (PRE_first_tail_x15_r0_body.s128.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw13_2673473 : (PRE_first_tail_x15_r0_body.s128.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd13 : PRE_first_tail_x15_r0_body.cl13.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr13 : PRE_first_tail_x15_r0_body.st13.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s126.next || PRE_first_tail_x15_r0_body.cl13.contains b) = true
def PRE_first_tail_x15_r0_body.zl13 : List Nat := PRE_first_tail_x15_r0_body.cl13.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE13 : PRE_first_tail_x15_r0_body.zl13.map (fun a => PRE_first_tail_x15_r0_body.s127.heap.get (PRE_first_tail_x15_r0_body.kappa13.a a)) = PRE_first_tail_x15_r0_body.zl13.map (fun a => (PRE_first_tail_x15_r0_body.s128.heap.get a).map PRE_first_tail_x15_r0_body.kappa13.hobj)
theorem PRE_first_tail_x15_r0_body.zimg13 : HeapImg PRE_first_tail_x15_r0_body.kappa13 PRE_first_tail_x15_r0_body.s128 PRE_first_tail_x15_r0_body.s127 PRE_first_tail_x15_r0_body.zl13 := PRE_first_tail_x15_r0_body.zimgE13
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl13 : PRE_first_tail_x15_r0_body.s127.ctl = PRE_first_tail_x15_r0_body.kappa13.ctl PRE_first_tail_x15_r0_body.s128.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack13 : PRE_first_tail_x15_r0_body.s127.stack = PRE_first_tail_x15_r0_body.s128.stack.map PRE_first_tail_x15_r0_body.kappa13.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs13 : PRE_first_tail_x15_r0_body.s127.jobs = PRE_first_tail_x15_r0_body.s128.jobs.map PRE_first_tail_x15_r0_body.kappa13.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores13 : PRE_first_tail_x15_r0_body.s127.stores = PRE_first_tail_x15_r0_body.kappa13.stores PRE_first_tail_x15_r0_body.s128.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots13 : checkRootsSupp PRE_first_tail_x15_r0_body.s128 635 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC13 : PRE_first_tail_x15_r0_body.S126.tab.length + PRE_first_tail_x15_r0_body.cws13.length = 635
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap13 : PRE_first_tail_x15_r0_body.kappa13 = Conv.Map.compact PRE_first_tail_x15_r0_body.s126.next 2685373 PRE_first_tail_x15_r0_body.S126.tab.length PRE_first_tail_x15_r0_body.pl13 (PRE_first_tail_x15_r0_body.nr13.map NumV.ref) PRE_first_tail_x15_r0_body.kd13.big
  PRE_first_tail_x15_r0_body.kd13.region PRE_first_tail_x15_r0_body.kd13.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin13 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s128.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc13 : Conv.jcleanListB (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s128 PRE_first_tail_x15_r0_body.cl13 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots213 : noBigRootsP (fun i => !Conv.oldBigB (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s128.trace PRE_first_tail_x15_r0_body.s128 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm13 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15555 = true
theorem PRE_first_tail_x15_r0_body.cjcl13 (h : Conv.JClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s126) : Conv.JClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s128 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle13)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap13 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd13 a ha)) PRE_first_tail_x15_r0_body.zjc13

end Host.Load.Run.Tpl

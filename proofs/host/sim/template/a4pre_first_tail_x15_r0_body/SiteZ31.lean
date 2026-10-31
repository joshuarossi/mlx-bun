import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS31
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK31
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF31
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 31 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s285`, the merged
state `PRE_first_tail_x15_r0_body.s286`, the canonical state `PRE_first_tail_x15_r0_body.s287`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl31 : PRE_first_tail_x15_r0_body.pl31.all (Nat.ble PRE_first_tail_x15_r0_body.s285.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd31 : nodupT PRE_first_tail_x15_r0_body.pl31 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn131 : Nat.ble PRE_first_tail_x15_r0_body.s285.next 2699297 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst31 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s285.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn31 : PRE_first_tail_x15_r0_body.s287.next = PRE_first_tail_x15_r0_body.s285.next + PRE_first_tail_x15_r0_body.pl31.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn31 : PRE_first_tail_x15_r0_body.s286.next = 2699297
kernel_rfl PRE_first_tail_x15_r0_body.zgrow31 : Nat.ble PRE_first_tail_x15_r0_body.s287.next PRE_first_tail_x15_r0_body.s286.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh31 : PRE_first_tail_x15_r0_body.S285.tab.all (fun e => PRE_first_tail_x15_r0_body.cws31.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd31 : nodupT PRE_first_tail_x15_r0_body.cws31 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi31 : PRE_first_tail_x15_r0_body.nr31.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S286.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt31 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s285.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg31_2665 : PRE_first_tail_x15_r0_body.s287.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s287 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk31_2665 : (objOf PRE_first_tail_x15_r0_body.s287 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm31_2665 : PRE_first_tail_x15_r0_body.s286.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa31.obj (objOf PRE_first_tail_x15_r0_body.s287 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s286 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg31_2673467 : PRE_first_tail_x15_r0_body.s287.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s287 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk31_2673467 : (objOf PRE_first_tail_x15_r0_body.s287 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm31_2673467 : PRE_first_tail_x15_r0_body.s286.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa31.obj (objOf PRE_first_tail_x15_r0_body.s287 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s286 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw31_4910 : (PRE_first_tail_x15_r0_body.s287.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw31_2673472 : (PRE_first_tail_x15_r0_body.s287.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw31_2673473 : (PRE_first_tail_x15_r0_body.s287.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd31 : PRE_first_tail_x15_r0_body.cl31.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr31 : PRE_first_tail_x15_r0_body.st31.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s285.next || PRE_first_tail_x15_r0_body.cl31.contains b) = true
def PRE_first_tail_x15_r0_body.zl31 : List Nat := PRE_first_tail_x15_r0_body.cl31.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE31 : PRE_first_tail_x15_r0_body.zl31.map (fun a => PRE_first_tail_x15_r0_body.s286.heap.get (PRE_first_tail_x15_r0_body.kappa31.a a)) = PRE_first_tail_x15_r0_body.zl31.map (fun a => (PRE_first_tail_x15_r0_body.s287.heap.get a).map PRE_first_tail_x15_r0_body.kappa31.hobj)
theorem PRE_first_tail_x15_r0_body.zimg31 : HeapImg PRE_first_tail_x15_r0_body.kappa31 PRE_first_tail_x15_r0_body.s287 PRE_first_tail_x15_r0_body.s286 PRE_first_tail_x15_r0_body.zl31 := PRE_first_tail_x15_r0_body.zimgE31
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl31 : PRE_first_tail_x15_r0_body.s286.ctl = PRE_first_tail_x15_r0_body.kappa31.ctl PRE_first_tail_x15_r0_body.s287.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack31 : PRE_first_tail_x15_r0_body.s286.stack = PRE_first_tail_x15_r0_body.s287.stack.map PRE_first_tail_x15_r0_body.kappa31.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs31 : PRE_first_tail_x15_r0_body.s286.jobs = PRE_first_tail_x15_r0_body.s287.jobs.map PRE_first_tail_x15_r0_body.kappa31.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores31 : PRE_first_tail_x15_r0_body.s286.stores = PRE_first_tail_x15_r0_body.kappa31.stores PRE_first_tail_x15_r0_body.s287.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots31 : checkRootsSupp PRE_first_tail_x15_r0_body.s287 1406 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC31 : PRE_first_tail_x15_r0_body.S285.tab.length + PRE_first_tail_x15_r0_body.cws31.length = 1406
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap31 : PRE_first_tail_x15_r0_body.kappa31 = Conv.Map.compact PRE_first_tail_x15_r0_body.s285.next 2699297 PRE_first_tail_x15_r0_body.S285.tab.length PRE_first_tail_x15_r0_body.pl31 (PRE_first_tail_x15_r0_body.nr31.map NumV.ref) PRE_first_tail_x15_r0_body.kd31.big
  PRE_first_tail_x15_r0_body.kd31.region PRE_first_tail_x15_r0_body.kd31.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin31 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s287.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc31 : Conv.jcleanListB (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s287 PRE_first_tail_x15_r0_body.cl31 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots231 : noBigRootsP (fun i => !Conv.oldBigB (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s287.trace PRE_first_tail_x15_r0_body.s287 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm31 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15918 = true
theorem PRE_first_tail_x15_r0_body.cjcl31 (h : Conv.JClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s285) : Conv.JClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s287 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle31)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap31 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd31 a ha)) PRE_first_tail_x15_r0_body.zjc31

end Host.Load.Run.Tpl

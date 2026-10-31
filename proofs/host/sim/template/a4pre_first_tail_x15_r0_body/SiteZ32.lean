import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS32
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK32
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF32
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 32 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s289`, the merged
state `PRE_first_tail_x15_r0_body.s290`, the canonical state `PRE_first_tail_x15_r0_body.s291`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl32 : PRE_first_tail_x15_r0_body.pl32.all (Nat.ble PRE_first_tail_x15_r0_body.s289.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd32 : nodupT PRE_first_tail_x15_r0_body.pl32 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn132 : Nat.ble PRE_first_tail_x15_r0_body.s289.next 2699594 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst32 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s289.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn32 : PRE_first_tail_x15_r0_body.s291.next = PRE_first_tail_x15_r0_body.s289.next + PRE_first_tail_x15_r0_body.pl32.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn32 : PRE_first_tail_x15_r0_body.s290.next = 2699594
kernel_rfl PRE_first_tail_x15_r0_body.zgrow32 : Nat.ble PRE_first_tail_x15_r0_body.s291.next PRE_first_tail_x15_r0_body.s290.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh32 : PRE_first_tail_x15_r0_body.S289.tab.all (fun e => PRE_first_tail_x15_r0_body.cws32.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd32 : nodupT PRE_first_tail_x15_r0_body.cws32 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi32 : PRE_first_tail_x15_r0_body.nr32.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S290.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt32 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s289.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg32_2665 : PRE_first_tail_x15_r0_body.s291.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s291 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk32_2665 : (objOf PRE_first_tail_x15_r0_body.s291 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm32_2665 : PRE_first_tail_x15_r0_body.s290.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa32.obj (objOf PRE_first_tail_x15_r0_body.s291 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s290 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg32_2673467 : PRE_first_tail_x15_r0_body.s291.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s291 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk32_2673467 : (objOf PRE_first_tail_x15_r0_body.s291 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm32_2673467 : PRE_first_tail_x15_r0_body.s290.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa32.obj (objOf PRE_first_tail_x15_r0_body.s291 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s290 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw32_4910 : (PRE_first_tail_x15_r0_body.s291.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw32_2673472 : (PRE_first_tail_x15_r0_body.s291.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw32_2673473 : (PRE_first_tail_x15_r0_body.s291.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd32 : PRE_first_tail_x15_r0_body.cl32.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr32 : PRE_first_tail_x15_r0_body.st32.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s289.next || PRE_first_tail_x15_r0_body.cl32.contains b) = true
def PRE_first_tail_x15_r0_body.zl32 : List Nat := PRE_first_tail_x15_r0_body.cl32.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE32 : PRE_first_tail_x15_r0_body.zl32.map (fun a => PRE_first_tail_x15_r0_body.s290.heap.get (PRE_first_tail_x15_r0_body.kappa32.a a)) = PRE_first_tail_x15_r0_body.zl32.map (fun a => (PRE_first_tail_x15_r0_body.s291.heap.get a).map PRE_first_tail_x15_r0_body.kappa32.hobj)
theorem PRE_first_tail_x15_r0_body.zimg32 : HeapImg PRE_first_tail_x15_r0_body.kappa32 PRE_first_tail_x15_r0_body.s291 PRE_first_tail_x15_r0_body.s290 PRE_first_tail_x15_r0_body.zl32 := PRE_first_tail_x15_r0_body.zimgE32
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl32 : PRE_first_tail_x15_r0_body.s290.ctl = PRE_first_tail_x15_r0_body.kappa32.ctl PRE_first_tail_x15_r0_body.s291.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack32 : PRE_first_tail_x15_r0_body.s290.stack = PRE_first_tail_x15_r0_body.s291.stack.map PRE_first_tail_x15_r0_body.kappa32.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs32 : PRE_first_tail_x15_r0_body.s290.jobs = PRE_first_tail_x15_r0_body.s291.jobs.map PRE_first_tail_x15_r0_body.kappa32.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores32 : PRE_first_tail_x15_r0_body.s290.stores = PRE_first_tail_x15_r0_body.kappa32.stores PRE_first_tail_x15_r0_body.s291.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots32 : checkRootsSupp PRE_first_tail_x15_r0_body.s291 1423 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC32 : PRE_first_tail_x15_r0_body.S289.tab.length + PRE_first_tail_x15_r0_body.cws32.length = 1423
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap32 : PRE_first_tail_x15_r0_body.kappa32 = Conv.Map.compact PRE_first_tail_x15_r0_body.s289.next 2699594 PRE_first_tail_x15_r0_body.S289.tab.length PRE_first_tail_x15_r0_body.pl32 (PRE_first_tail_x15_r0_body.nr32.map NumV.ref) PRE_first_tail_x15_r0_body.kd32.big
  PRE_first_tail_x15_r0_body.kd32.region PRE_first_tail_x15_r0_body.kd32.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin32 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s291.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc32 : Conv.jcleanListB (⟨18825, 15922, 2699584, 1423⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s291 PRE_first_tail_x15_r0_body.cl32 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots232 : noBigRootsP (fun i => !Conv.oldBigB (⟨18825, 15922, 2699584, 1423⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s291.trace PRE_first_tail_x15_r0_body.s291 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm32 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15922 = true
theorem PRE_first_tail_x15_r0_body.cjcl32 (h : Conv.JClean (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s289) : Conv.JClean (⟨18825, 15922, 2699584, 1423⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s291 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle32)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap32 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd32 a ha)) PRE_first_tail_x15_r0_body.zjc32

end Host.Load.Run.Tpl

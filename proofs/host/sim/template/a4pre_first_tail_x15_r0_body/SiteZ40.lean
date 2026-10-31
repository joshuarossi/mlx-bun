import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS40
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK40
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF40
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 40 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s398`, the merged
state `PRE_first_tail_x15_r0_body.s399`, the canonical state `PRE_first_tail_x15_r0_body.s400`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl40 : PRE_first_tail_x15_r0_body.pl40.all (Nat.ble PRE_first_tail_x15_r0_body.s398.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd40 : nodupT PRE_first_tail_x15_r0_body.pl40 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn140 : Nat.ble PRE_first_tail_x15_r0_body.s398.next 2706457 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst40 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s398.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn40 : PRE_first_tail_x15_r0_body.s400.next = PRE_first_tail_x15_r0_body.s398.next + PRE_first_tail_x15_r0_body.pl40.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn40 : PRE_first_tail_x15_r0_body.s399.next = 2706457
kernel_rfl PRE_first_tail_x15_r0_body.zgrow40 : Nat.ble PRE_first_tail_x15_r0_body.s400.next PRE_first_tail_x15_r0_body.s399.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh40 : PRE_first_tail_x15_r0_body.S398.tab.all (fun e => PRE_first_tail_x15_r0_body.cws40.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd40 : nodupT PRE_first_tail_x15_r0_body.cws40 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi40 : PRE_first_tail_x15_r0_body.nr40.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S399.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt40 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s398.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg40_2665 : PRE_first_tail_x15_r0_body.s400.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s400 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk40_2665 : (objOf PRE_first_tail_x15_r0_body.s400 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm40_2665 : PRE_first_tail_x15_r0_body.s399.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa40.obj (objOf PRE_first_tail_x15_r0_body.s400 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s399 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg40_2673467 : PRE_first_tail_x15_r0_body.s400.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s400 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk40_2673467 : (objOf PRE_first_tail_x15_r0_body.s400 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm40_2673467 : PRE_first_tail_x15_r0_body.s399.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa40.obj (objOf PRE_first_tail_x15_r0_body.s400 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s399 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw40_4910 : (PRE_first_tail_x15_r0_body.s400.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw40_2673472 : (PRE_first_tail_x15_r0_body.s400.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw40_2673473 : (PRE_first_tail_x15_r0_body.s400.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd40 : PRE_first_tail_x15_r0_body.cl40.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr40 : PRE_first_tail_x15_r0_body.st40.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s398.next || PRE_first_tail_x15_r0_body.cl40.contains b) = true
def PRE_first_tail_x15_r0_body.zl40 : List Nat := PRE_first_tail_x15_r0_body.cl40.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE40 : PRE_first_tail_x15_r0_body.zl40.map (fun a => PRE_first_tail_x15_r0_body.s399.heap.get (PRE_first_tail_x15_r0_body.kappa40.a a)) = PRE_first_tail_x15_r0_body.zl40.map (fun a => (PRE_first_tail_x15_r0_body.s400.heap.get a).map PRE_first_tail_x15_r0_body.kappa40.hobj)
theorem PRE_first_tail_x15_r0_body.zimg40 : HeapImg PRE_first_tail_x15_r0_body.kappa40 PRE_first_tail_x15_r0_body.s400 PRE_first_tail_x15_r0_body.s399 PRE_first_tail_x15_r0_body.zl40 := PRE_first_tail_x15_r0_body.zimgE40
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl40 : PRE_first_tail_x15_r0_body.s399.ctl = PRE_first_tail_x15_r0_body.kappa40.ctl PRE_first_tail_x15_r0_body.s400.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack40 : PRE_first_tail_x15_r0_body.s399.stack = PRE_first_tail_x15_r0_body.s400.stack.map PRE_first_tail_x15_r0_body.kappa40.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs40 : PRE_first_tail_x15_r0_body.s399.jobs = PRE_first_tail_x15_r0_body.s400.jobs.map PRE_first_tail_x15_r0_body.kappa40.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores40 : PRE_first_tail_x15_r0_body.s399.stores = PRE_first_tail_x15_r0_body.kappa40.stores PRE_first_tail_x15_r0_body.s400.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots40 : checkRootsSupp PRE_first_tail_x15_r0_body.s400 1790 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC40 : PRE_first_tail_x15_r0_body.S398.tab.length + PRE_first_tail_x15_r0_body.cws40.length = 1790
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap40 : PRE_first_tail_x15_r0_body.kappa40 = Conv.Map.compact PRE_first_tail_x15_r0_body.s398.next 2706457 PRE_first_tail_x15_r0_body.S398.tab.length PRE_first_tail_x15_r0_body.pl40 (PRE_first_tail_x15_r0_body.nr40.map NumV.ref) PRE_first_tail_x15_r0_body.kd40.big
  PRE_first_tail_x15_r0_body.kd40.region PRE_first_tail_x15_r0_body.kd40.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin40 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s400.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc40 : Conv.jcleanListB (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s400 PRE_first_tail_x15_r0_body.cl40 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB40 : noBigRootsP (fun i => !Conv.oldBigB (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s400.trace PRE_first_tail_x15_r0_body.s400 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm40 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16092 = true
theorem PRE_first_tail_x15_r0_body.cjcl40 (h : Conv.JClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s398) : Conv.JClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s400 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle40)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap40 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd40 a ha)) PRE_first_tail_x15_r0_body.zjc40

end Host.Load.Run.Tpl

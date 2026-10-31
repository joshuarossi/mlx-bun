import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS12
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK12
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF12
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 12 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s119`, the merged
state `PRE_first_tail_x15_r0_body.s120`, the canonical state `PRE_first_tail_x15_r0_body.s121`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl12 : PRE_first_tail_x15_r0_body.pl12.all (Nat.ble PRE_first_tail_x15_r0_body.s119.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd12 : nodupT PRE_first_tail_x15_r0_body.pl12 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn112 : Nat.ble PRE_first_tail_x15_r0_body.s119.next 2686030 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst12 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s119.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn12 : PRE_first_tail_x15_r0_body.s121.next = PRE_first_tail_x15_r0_body.s119.next + PRE_first_tail_x15_r0_body.pl12.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn12 : PRE_first_tail_x15_r0_body.s120.next = 2686030
kernel_rfl PRE_first_tail_x15_r0_body.zgrow12 : Nat.ble PRE_first_tail_x15_r0_body.s121.next PRE_first_tail_x15_r0_body.s120.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh12 : PRE_first_tail_x15_r0_body.S119.tab.all (fun e => PRE_first_tail_x15_r0_body.cws12.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd12 : nodupT PRE_first_tail_x15_r0_body.cws12 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi12 : PRE_first_tail_x15_r0_body.nr12.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S120.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt12 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s119.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg12_2665 : PRE_first_tail_x15_r0_body.s121.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s121 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk12_2665 : (objOf PRE_first_tail_x15_r0_body.s121 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm12_2665 : PRE_first_tail_x15_r0_body.s120.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa12.obj (objOf PRE_first_tail_x15_r0_body.s121 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s120 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg12_2673467 : PRE_first_tail_x15_r0_body.s121.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s121 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk12_2673467 : (objOf PRE_first_tail_x15_r0_body.s121 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm12_2673467 : PRE_first_tail_x15_r0_body.s120.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa12.obj (objOf PRE_first_tail_x15_r0_body.s121 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s120 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw12_4910 : (PRE_first_tail_x15_r0_body.s121.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw12_2673472 : (PRE_first_tail_x15_r0_body.s121.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw12_2673473 : (PRE_first_tail_x15_r0_body.s121.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd12 : PRE_first_tail_x15_r0_body.cl12.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr12 : PRE_first_tail_x15_r0_body.st12.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s119.next || PRE_first_tail_x15_r0_body.cl12.contains b) = true
def PRE_first_tail_x15_r0_body.zl12 : List Nat := PRE_first_tail_x15_r0_body.cl12.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE12 : PRE_first_tail_x15_r0_body.zl12.map (fun a => PRE_first_tail_x15_r0_body.s120.heap.get (PRE_first_tail_x15_r0_body.kappa12.a a)) = PRE_first_tail_x15_r0_body.zl12.map (fun a => (PRE_first_tail_x15_r0_body.s121.heap.get a).map PRE_first_tail_x15_r0_body.kappa12.hobj)
theorem PRE_first_tail_x15_r0_body.zimg12 : HeapImg PRE_first_tail_x15_r0_body.kappa12 PRE_first_tail_x15_r0_body.s121 PRE_first_tail_x15_r0_body.s120 PRE_first_tail_x15_r0_body.zl12 := PRE_first_tail_x15_r0_body.zimgE12
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl12 : PRE_first_tail_x15_r0_body.s120.ctl = PRE_first_tail_x15_r0_body.kappa12.ctl PRE_first_tail_x15_r0_body.s121.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack12 : PRE_first_tail_x15_r0_body.s120.stack = PRE_first_tail_x15_r0_body.s121.stack.map PRE_first_tail_x15_r0_body.kappa12.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs12 : PRE_first_tail_x15_r0_body.s120.jobs = PRE_first_tail_x15_r0_body.s121.jobs.map PRE_first_tail_x15_r0_body.kappa12.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores12 : PRE_first_tail_x15_r0_body.s120.stores = PRE_first_tail_x15_r0_body.kappa12.stores PRE_first_tail_x15_r0_body.s121.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots12 : checkRootsSupp PRE_first_tail_x15_r0_body.s121 614 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC12 : PRE_first_tail_x15_r0_body.S119.tab.length + PRE_first_tail_x15_r0_body.cws12.length = 614
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap12 : PRE_first_tail_x15_r0_body.kappa12 = Conv.Map.compact PRE_first_tail_x15_r0_body.s119.next 2686030 PRE_first_tail_x15_r0_body.S119.tab.length PRE_first_tail_x15_r0_body.pl12 (PRE_first_tail_x15_r0_body.nr12.map NumV.ref) PRE_first_tail_x15_r0_body.kd12.big
  PRE_first_tail_x15_r0_body.kd12.region PRE_first_tail_x15_r0_body.kd12.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin12 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s121.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc12 : Conv.jcleanListB (⟨18455, 15542, 2684881, 614⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s121 PRE_first_tail_x15_r0_body.cl12 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots212 : noBigRootsP (fun i => !Conv.oldBigB (⟨18455, 15542, 2684881, 614⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s121.trace PRE_first_tail_x15_r0_body.s121 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm12 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15515 = true
theorem PRE_first_tail_x15_r0_body.cjcl12 (h : Conv.JClean (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s119) : Conv.JClean (⟨18455, 15542, 2684881, 614⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s121 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle12)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap12 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd12 a ha)) PRE_first_tail_x15_r0_body.zjc12

end Host.Load.Run.Tpl

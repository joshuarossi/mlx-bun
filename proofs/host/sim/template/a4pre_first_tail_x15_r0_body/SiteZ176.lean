import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS176
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK176
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF176
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 176 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1696`, the merged
state `PRE_first_tail_x15_r0_body.s1697`, the canonical state `PRE_first_tail_x15_r0_body.s1698`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl176 : PRE_first_tail_x15_r0_body.pl176.all (Nat.ble PRE_first_tail_x15_r0_body.s1696.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd176 : nodupT PRE_first_tail_x15_r0_body.pl176 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1176 : Nat.ble PRE_first_tail_x15_r0_body.s1696.next 2812623 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst176 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1696.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn176 : PRE_first_tail_x15_r0_body.s1698.next = PRE_first_tail_x15_r0_body.s1696.next + PRE_first_tail_x15_r0_body.pl176.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn176 : PRE_first_tail_x15_r0_body.s1697.next = 2812623
kernel_rfl PRE_first_tail_x15_r0_body.zgrow176 : Nat.ble PRE_first_tail_x15_r0_body.s1698.next PRE_first_tail_x15_r0_body.s1697.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh176 : PRE_first_tail_x15_r0_body.S1696.tab.all (fun e => PRE_first_tail_x15_r0_body.cws176.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd176 : nodupT PRE_first_tail_x15_r0_body.cws176 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi176 : PRE_first_tail_x15_r0_body.nr176.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1697.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt176 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1696.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg176_2665 : PRE_first_tail_x15_r0_body.s1698.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1698 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk176_2665 : (objOf PRE_first_tail_x15_r0_body.s1698 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm176_2665 : PRE_first_tail_x15_r0_body.s1697.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa176.obj (objOf PRE_first_tail_x15_r0_body.s1698 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1697 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg176_2673467 : PRE_first_tail_x15_r0_body.s1698.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1698 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk176_2673467 : (objOf PRE_first_tail_x15_r0_body.s1698 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm176_2673467 : PRE_first_tail_x15_r0_body.s1697.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa176.obj (objOf PRE_first_tail_x15_r0_body.s1698 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1697 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw176_4910 : (PRE_first_tail_x15_r0_body.s1698.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw176_2673472 : (PRE_first_tail_x15_r0_body.s1698.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw176_2673473 : (PRE_first_tail_x15_r0_body.s1698.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd176 : PRE_first_tail_x15_r0_body.cl176.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr176 : PRE_first_tail_x15_r0_body.st176.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1696.next || PRE_first_tail_x15_r0_body.cl176.contains b) = true
def PRE_first_tail_x15_r0_body.zl176 : List Nat := PRE_first_tail_x15_r0_body.cl176.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE176 : PRE_first_tail_x15_r0_body.zl176.map (fun a => PRE_first_tail_x15_r0_body.s1697.heap.get (PRE_first_tail_x15_r0_body.kappa176.a a)) = PRE_first_tail_x15_r0_body.zl176.map (fun a => (PRE_first_tail_x15_r0_body.s1698.heap.get a).map PRE_first_tail_x15_r0_body.kappa176.hobj)
theorem PRE_first_tail_x15_r0_body.zimg176 : HeapImg PRE_first_tail_x15_r0_body.kappa176 PRE_first_tail_x15_r0_body.s1698 PRE_first_tail_x15_r0_body.s1697 PRE_first_tail_x15_r0_body.zl176 := PRE_first_tail_x15_r0_body.zimgE176
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl176 : PRE_first_tail_x15_r0_body.s1697.ctl = PRE_first_tail_x15_r0_body.kappa176.ctl PRE_first_tail_x15_r0_body.s1698.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack176 : PRE_first_tail_x15_r0_body.s1697.stack = PRE_first_tail_x15_r0_body.s1698.stack.map PRE_first_tail_x15_r0_body.kappa176.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs176 : PRE_first_tail_x15_r0_body.s1697.jobs = PRE_first_tail_x15_r0_body.s1698.jobs.map PRE_first_tail_x15_r0_body.kappa176.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores176 : PRE_first_tail_x15_r0_body.s1697.stores = PRE_first_tail_x15_r0_body.kappa176.stores PRE_first_tail_x15_r0_body.s1698.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots176 : checkRootsSupp PRE_first_tail_x15_r0_body.s1698 7579 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC176 : PRE_first_tail_x15_r0_body.S1696.tab.length + PRE_first_tail_x15_r0_body.cws176.length = 7579
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap176 : PRE_first_tail_x15_r0_body.kappa176 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1696.next 2812623 PRE_first_tail_x15_r0_body.S1696.tab.length PRE_first_tail_x15_r0_body.pl176 (PRE_first_tail_x15_r0_body.nr176.map NumV.ref) PRE_first_tail_x15_r0_body.kd176.big
  PRE_first_tail_x15_r0_body.kd176.region PRE_first_tail_x15_r0_body.kd176.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin176 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1698.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc176 : Conv.jcleanListB (⟨21657, 18766, 2812604, 7579⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1698 PRE_first_tail_x15_r0_body.cl176 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB176 : noBigRootsP (fun i => !Conv.oldBigB (⟨21657, 18766, 2812604, 7579⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1698.trace PRE_first_tail_x15_r0_body.s1698 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm176 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18766 = true
theorem PRE_first_tail_x15_r0_body.cjcl176 (h : Conv.JClean (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1696) : Conv.JClean (⟨21657, 18766, 2812604, 7579⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1698 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle176)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap176 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd176 a ha)) PRE_first_tail_x15_r0_body.zjc176

end Host.Load.Run.Tpl

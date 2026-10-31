import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS84
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK84
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF84
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 84 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s749`, the merged
state `PRE_first_tail_x15_r0_body.s750`, the canonical state `PRE_first_tail_x15_r0_body.s751`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl84 : PRE_first_tail_x15_r0_body.pl84.all (Nat.ble PRE_first_tail_x15_r0_body.s749.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd84 : nodupT PRE_first_tail_x15_r0_body.pl84 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn184 : Nat.ble PRE_first_tail_x15_r0_body.s749.next 2742526 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst84 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s749.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn84 : PRE_first_tail_x15_r0_body.s751.next = PRE_first_tail_x15_r0_body.s749.next + PRE_first_tail_x15_r0_body.pl84.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn84 : PRE_first_tail_x15_r0_body.s750.next = 2742526
kernel_rfl PRE_first_tail_x15_r0_body.zgrow84 : Nat.ble PRE_first_tail_x15_r0_body.s751.next PRE_first_tail_x15_r0_body.s750.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh84 : PRE_first_tail_x15_r0_body.S749.tab.all (fun e => PRE_first_tail_x15_r0_body.cws84.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd84 : nodupT PRE_first_tail_x15_r0_body.cws84 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi84 : PRE_first_tail_x15_r0_body.nr84.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S750.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt84 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s749.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg84_2665 : PRE_first_tail_x15_r0_body.s751.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s751 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk84_2665 : (objOf PRE_first_tail_x15_r0_body.s751 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm84_2665 : PRE_first_tail_x15_r0_body.s750.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa84.obj (objOf PRE_first_tail_x15_r0_body.s751 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s750 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg84_2673467 : PRE_first_tail_x15_r0_body.s751.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s751 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk84_2673467 : (objOf PRE_first_tail_x15_r0_body.s751 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm84_2673467 : PRE_first_tail_x15_r0_body.s750.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa84.obj (objOf PRE_first_tail_x15_r0_body.s751 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s750 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw84_4910 : (PRE_first_tail_x15_r0_body.s751.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw84_2673472 : (PRE_first_tail_x15_r0_body.s751.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw84_2673473 : (PRE_first_tail_x15_r0_body.s751.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd84 : PRE_first_tail_x15_r0_body.cl84.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr84 : PRE_first_tail_x15_r0_body.st84.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s749.next || PRE_first_tail_x15_r0_body.cl84.contains b) = true
def PRE_first_tail_x15_r0_body.zl84 : List Nat := PRE_first_tail_x15_r0_body.cl84.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE84 : PRE_first_tail_x15_r0_body.zl84.map (fun a => PRE_first_tail_x15_r0_body.s750.heap.get (PRE_first_tail_x15_r0_body.kappa84.a a)) = PRE_first_tail_x15_r0_body.zl84.map (fun a => (PRE_first_tail_x15_r0_body.s751.heap.get a).map PRE_first_tail_x15_r0_body.kappa84.hobj)
theorem PRE_first_tail_x15_r0_body.zimg84 : HeapImg PRE_first_tail_x15_r0_body.kappa84 PRE_first_tail_x15_r0_body.s751 PRE_first_tail_x15_r0_body.s750 PRE_first_tail_x15_r0_body.zl84 := PRE_first_tail_x15_r0_body.zimgE84
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl84 : PRE_first_tail_x15_r0_body.s750.ctl = PRE_first_tail_x15_r0_body.kappa84.ctl PRE_first_tail_x15_r0_body.s751.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack84 : PRE_first_tail_x15_r0_body.s750.stack = PRE_first_tail_x15_r0_body.s751.stack.map PRE_first_tail_x15_r0_body.kappa84.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs84 : PRE_first_tail_x15_r0_body.s750.jobs = PRE_first_tail_x15_r0_body.s751.jobs.map PRE_first_tail_x15_r0_body.kappa84.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores84 : PRE_first_tail_x15_r0_body.s750.stores = PRE_first_tail_x15_r0_body.kappa84.stores PRE_first_tail_x15_r0_body.s751.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots84 : checkRootsSupp PRE_first_tail_x15_r0_body.s751 3692 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC84 : PRE_first_tail_x15_r0_body.S749.tab.length + PRE_first_tail_x15_r0_body.cws84.length = 3692
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap84 : PRE_first_tail_x15_r0_body.kappa84 = Conv.Map.compact PRE_first_tail_x15_r0_body.s749.next 2742526 PRE_first_tail_x15_r0_body.S749.tab.length PRE_first_tail_x15_r0_body.pl84 (PRE_first_tail_x15_r0_body.nr84.map NumV.ref) PRE_first_tail_x15_r0_body.kd84.big
  PRE_first_tail_x15_r0_body.kd84.region PRE_first_tail_x15_r0_body.kd84.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin84 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s751.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc84 : Conv.jcleanListB (⟨19871, 16964, 2741377, 3692⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s751 PRE_first_tail_x15_r0_body.cl84 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots284 : noBigRootsP (fun i => !Conv.oldBigB (⟨19871, 16964, 2741377, 3692⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s751.trace PRE_first_tail_x15_r0_body.s751 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm84 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16937 = true
theorem PRE_first_tail_x15_r0_body.cjcl84 (h : Conv.JClean (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s749) : Conv.JClean (⟨19871, 16964, 2741377, 3692⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s751 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle84)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap84 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd84 a ha)) PRE_first_tail_x15_r0_body.zjc84

end Host.Load.Run.Tpl

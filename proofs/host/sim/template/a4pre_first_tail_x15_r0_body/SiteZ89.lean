import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS89
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK89
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF89
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 89 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s862`, the merged
state `PRE_first_tail_x15_r0_body.s863`, the canonical state `PRE_first_tail_x15_r0_body.s864`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl89 : PRE_first_tail_x15_r0_body.pl89.all (Nat.ble PRE_first_tail_x15_r0_body.s862.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd89 : nodupT PRE_first_tail_x15_r0_body.pl89 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn189 : Nat.ble PRE_first_tail_x15_r0_body.s862.next 2744431 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst89 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s862.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn89 : PRE_first_tail_x15_r0_body.s864.next = PRE_first_tail_x15_r0_body.s862.next + PRE_first_tail_x15_r0_body.pl89.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn89 : PRE_first_tail_x15_r0_body.s863.next = 2744431
kernel_rfl PRE_first_tail_x15_r0_body.zgrow89 : Nat.ble PRE_first_tail_x15_r0_body.s864.next PRE_first_tail_x15_r0_body.s863.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh89 : PRE_first_tail_x15_r0_body.S862.tab.all (fun e => PRE_first_tail_x15_r0_body.cws89.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd89 : nodupT PRE_first_tail_x15_r0_body.cws89 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi89 : PRE_first_tail_x15_r0_body.nr89.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S863.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt89 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s862.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg89_2665 : PRE_first_tail_x15_r0_body.s864.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s864 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk89_2665 : (objOf PRE_first_tail_x15_r0_body.s864 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm89_2665 : PRE_first_tail_x15_r0_body.s863.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa89.obj (objOf PRE_first_tail_x15_r0_body.s864 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s863 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg89_2673467 : PRE_first_tail_x15_r0_body.s864.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s864 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk89_2673467 : (objOf PRE_first_tail_x15_r0_body.s864 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm89_2673467 : PRE_first_tail_x15_r0_body.s863.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa89.obj (objOf PRE_first_tail_x15_r0_body.s864 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s863 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw89_4910 : (PRE_first_tail_x15_r0_body.s864.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw89_2673472 : (PRE_first_tail_x15_r0_body.s864.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw89_2673473 : (PRE_first_tail_x15_r0_body.s864.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd89 : PRE_first_tail_x15_r0_body.cl89.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr89 : PRE_first_tail_x15_r0_body.st89.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s862.next || PRE_first_tail_x15_r0_body.cl89.contains b) = true
def PRE_first_tail_x15_r0_body.zl89 : List Nat := PRE_first_tail_x15_r0_body.cl89.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE89 : PRE_first_tail_x15_r0_body.zl89.map (fun a => PRE_first_tail_x15_r0_body.s863.heap.get (PRE_first_tail_x15_r0_body.kappa89.a a)) = PRE_first_tail_x15_r0_body.zl89.map (fun a => (PRE_first_tail_x15_r0_body.s864.heap.get a).map PRE_first_tail_x15_r0_body.kappa89.hobj)
theorem PRE_first_tail_x15_r0_body.zimg89 : HeapImg PRE_first_tail_x15_r0_body.kappa89 PRE_first_tail_x15_r0_body.s864 PRE_first_tail_x15_r0_body.s863 PRE_first_tail_x15_r0_body.zl89 := PRE_first_tail_x15_r0_body.zimgE89
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl89 : PRE_first_tail_x15_r0_body.s863.ctl = PRE_first_tail_x15_r0_body.kappa89.ctl PRE_first_tail_x15_r0_body.s864.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack89 : PRE_first_tail_x15_r0_body.s863.stack = PRE_first_tail_x15_r0_body.s864.stack.map PRE_first_tail_x15_r0_body.kappa89.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs89 : PRE_first_tail_x15_r0_body.s863.jobs = PRE_first_tail_x15_r0_body.s864.jobs.map PRE_first_tail_x15_r0_body.kappa89.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores89 : PRE_first_tail_x15_r0_body.s863.stores = PRE_first_tail_x15_r0_body.kappa89.stores PRE_first_tail_x15_r0_body.s864.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots89 : checkRootsSupp PRE_first_tail_x15_r0_body.s864 3859 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC89 : PRE_first_tail_x15_r0_body.S862.tab.length + PRE_first_tail_x15_r0_body.cws89.length = 3859
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap89 : PRE_first_tail_x15_r0_body.kappa89 = Conv.Map.compact PRE_first_tail_x15_r0_body.s862.next 2744431 PRE_first_tail_x15_r0_body.S862.tab.length PRE_first_tail_x15_r0_body.pl89 (PRE_first_tail_x15_r0_body.nr89.map NumV.ref) PRE_first_tail_x15_r0_body.kd89.big
  PRE_first_tail_x15_r0_body.kd89.region PRE_first_tail_x15_r0_body.kd89.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin89 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s864.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc89 : Conv.jcleanListB (⟨19948, 17044, 2744412, 3859⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s864 PRE_first_tail_x15_r0_body.cl89 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB89 : noBigRootsP (fun i => !Conv.oldBigB (⟨19948, 17044, 2744412, 3859⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s864.trace PRE_first_tail_x15_r0_body.s864 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm89 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17044 = true
theorem PRE_first_tail_x15_r0_body.cjcl89 (h : Conv.JClean (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s862) : Conv.JClean (⟨19948, 17044, 2744412, 3859⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s864 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle89)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap89 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd89 a ha)) PRE_first_tail_x15_r0_body.zjc89

end Host.Load.Run.Tpl

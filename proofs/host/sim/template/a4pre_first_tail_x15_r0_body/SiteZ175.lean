import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS175
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK175
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF175
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 175 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1692`, the merged
state `PRE_first_tail_x15_r0_body.s1693`, the canonical state `PRE_first_tail_x15_r0_body.s1694`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl175 : PRE_first_tail_x15_r0_body.pl175.all (Nat.ble PRE_first_tail_x15_r0_body.s1692.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd175 : nodupT PRE_first_tail_x15_r0_body.pl175 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1175 : Nat.ble PRE_first_tail_x15_r0_body.s1692.next 2812317 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst175 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1692.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn175 : PRE_first_tail_x15_r0_body.s1694.next = PRE_first_tail_x15_r0_body.s1692.next + PRE_first_tail_x15_r0_body.pl175.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn175 : PRE_first_tail_x15_r0_body.s1693.next = 2812317
kernel_rfl PRE_first_tail_x15_r0_body.zgrow175 : Nat.ble PRE_first_tail_x15_r0_body.s1694.next PRE_first_tail_x15_r0_body.s1693.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh175 : PRE_first_tail_x15_r0_body.S1692.tab.all (fun e => PRE_first_tail_x15_r0_body.cws175.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd175 : nodupT PRE_first_tail_x15_r0_body.cws175 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi175 : PRE_first_tail_x15_r0_body.nr175.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1693.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt175 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1692.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg175_2665 : PRE_first_tail_x15_r0_body.s1694.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1694 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk175_2665 : (objOf PRE_first_tail_x15_r0_body.s1694 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm175_2665 : PRE_first_tail_x15_r0_body.s1693.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa175.obj (objOf PRE_first_tail_x15_r0_body.s1694 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1693 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg175_2673467 : PRE_first_tail_x15_r0_body.s1694.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1694 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk175_2673467 : (objOf PRE_first_tail_x15_r0_body.s1694 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm175_2673467 : PRE_first_tail_x15_r0_body.s1693.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa175.obj (objOf PRE_first_tail_x15_r0_body.s1694 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1693 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw175_4910 : (PRE_first_tail_x15_r0_body.s1694.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw175_2673472 : (PRE_first_tail_x15_r0_body.s1694.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw175_2673473 : (PRE_first_tail_x15_r0_body.s1694.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd175 : PRE_first_tail_x15_r0_body.cl175.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr175 : PRE_first_tail_x15_r0_body.st175.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1692.next || PRE_first_tail_x15_r0_body.cl175.contains b) = true
def PRE_first_tail_x15_r0_body.zl175 : List Nat := PRE_first_tail_x15_r0_body.cl175.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE175 : PRE_first_tail_x15_r0_body.zl175.map (fun a => PRE_first_tail_x15_r0_body.s1693.heap.get (PRE_first_tail_x15_r0_body.kappa175.a a)) = PRE_first_tail_x15_r0_body.zl175.map (fun a => (PRE_first_tail_x15_r0_body.s1694.heap.get a).map PRE_first_tail_x15_r0_body.kappa175.hobj)
theorem PRE_first_tail_x15_r0_body.zimg175 : HeapImg PRE_first_tail_x15_r0_body.kappa175 PRE_first_tail_x15_r0_body.s1694 PRE_first_tail_x15_r0_body.s1693 PRE_first_tail_x15_r0_body.zl175 := PRE_first_tail_x15_r0_body.zimgE175
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl175 : PRE_first_tail_x15_r0_body.s1693.ctl = PRE_first_tail_x15_r0_body.kappa175.ctl PRE_first_tail_x15_r0_body.s1694.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack175 : PRE_first_tail_x15_r0_body.s1693.stack = PRE_first_tail_x15_r0_body.s1694.stack.map PRE_first_tail_x15_r0_body.kappa175.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs175 : PRE_first_tail_x15_r0_body.s1693.jobs = PRE_first_tail_x15_r0_body.s1694.jobs.map PRE_first_tail_x15_r0_body.kappa175.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores175 : PRE_first_tail_x15_r0_body.s1693.stores = PRE_first_tail_x15_r0_body.kappa175.stores PRE_first_tail_x15_r0_body.s1694.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots175 : checkRootsSupp PRE_first_tail_x15_r0_body.s1694 7562 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC175 : PRE_first_tail_x15_r0_body.S1692.tab.length + PRE_first_tail_x15_r0_body.cws175.length = 7562
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap175 : PRE_first_tail_x15_r0_body.kappa175 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1692.next 2812317 PRE_first_tail_x15_r0_body.S1692.tab.length PRE_first_tail_x15_r0_body.pl175 (PRE_first_tail_x15_r0_body.nr175.map NumV.ref) PRE_first_tail_x15_r0_body.kd175.big
  PRE_first_tail_x15_r0_body.kd175.region PRE_first_tail_x15_r0_body.kd175.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin175 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1694.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc175 : Conv.jcleanListB (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1694 PRE_first_tail_x15_r0_body.cl175 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB175 : noBigRootsP (fun i => !Conv.oldBigB (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1694.trace PRE_first_tail_x15_r0_body.s1694 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm175 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18762 = true
theorem PRE_first_tail_x15_r0_body.cjcl175 (h : Conv.JClean (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1692) : Conv.JClean (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1694 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle175)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap175 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd175 a ha)) PRE_first_tail_x15_r0_body.zjc175

end Host.Load.Run.Tpl

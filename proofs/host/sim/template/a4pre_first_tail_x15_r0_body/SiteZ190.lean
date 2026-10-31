import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS190
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK190
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF190
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 190 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1835`, the merged
state `PRE_first_tail_x15_r0_body.s1836`, the canonical state `PRE_first_tail_x15_r0_body.s1837`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl190 : PRE_first_tail_x15_r0_body.pl190.all (Nat.ble PRE_first_tail_x15_r0_body.s1835.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd190 : nodupT PRE_first_tail_x15_r0_body.pl190 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1190 : Nat.ble PRE_first_tail_x15_r0_body.s1835.next 2824367 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst190 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1835.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn190 : PRE_first_tail_x15_r0_body.s1837.next = PRE_first_tail_x15_r0_body.s1835.next + PRE_first_tail_x15_r0_body.pl190.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn190 : PRE_first_tail_x15_r0_body.s1836.next = 2824367
kernel_rfl PRE_first_tail_x15_r0_body.zgrow190 : Nat.ble PRE_first_tail_x15_r0_body.s1837.next PRE_first_tail_x15_r0_body.s1836.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh190 : PRE_first_tail_x15_r0_body.S1835.tab.all (fun e => PRE_first_tail_x15_r0_body.cws190.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd190 : nodupT PRE_first_tail_x15_r0_body.cws190 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi190 : PRE_first_tail_x15_r0_body.nr190.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1836.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt190 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1835.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg190_2665 : PRE_first_tail_x15_r0_body.s1837.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1837 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk190_2665 : (objOf PRE_first_tail_x15_r0_body.s1837 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm190_2665 : PRE_first_tail_x15_r0_body.s1836.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa190.obj (objOf PRE_first_tail_x15_r0_body.s1837 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1836 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg190_2673467 : PRE_first_tail_x15_r0_body.s1837.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1837 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk190_2673467 : (objOf PRE_first_tail_x15_r0_body.s1837 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm190_2673467 : PRE_first_tail_x15_r0_body.s1836.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa190.obj (objOf PRE_first_tail_x15_r0_body.s1837 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1836 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw190_4910 : (PRE_first_tail_x15_r0_body.s1837.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw190_2673472 : (PRE_first_tail_x15_r0_body.s1837.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw190_2673473 : (PRE_first_tail_x15_r0_body.s1837.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd190 : PRE_first_tail_x15_r0_body.cl190.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr190 : PRE_first_tail_x15_r0_body.st190.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1835.next || PRE_first_tail_x15_r0_body.cl190.contains b) = true
def PRE_first_tail_x15_r0_body.zl190 : List Nat := PRE_first_tail_x15_r0_body.cl190.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE190 : PRE_first_tail_x15_r0_body.zl190.map (fun a => PRE_first_tail_x15_r0_body.s1836.heap.get (PRE_first_tail_x15_r0_body.kappa190.a a)) = PRE_first_tail_x15_r0_body.zl190.map (fun a => (PRE_first_tail_x15_r0_body.s1837.heap.get a).map PRE_first_tail_x15_r0_body.kappa190.hobj)
theorem PRE_first_tail_x15_r0_body.zimg190 : HeapImg PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.s1837 PRE_first_tail_x15_r0_body.s1836 PRE_first_tail_x15_r0_body.zl190 := PRE_first_tail_x15_r0_body.zimgE190
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl190 : PRE_first_tail_x15_r0_body.s1836.ctl = PRE_first_tail_x15_r0_body.kappa190.ctl PRE_first_tail_x15_r0_body.s1837.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack190 : PRE_first_tail_x15_r0_body.s1836.stack = PRE_first_tail_x15_r0_body.s1837.stack.map PRE_first_tail_x15_r0_body.kappa190.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs190 : PRE_first_tail_x15_r0_body.s1836.jobs = PRE_first_tail_x15_r0_body.s1837.jobs.map PRE_first_tail_x15_r0_body.kappa190.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores190 : PRE_first_tail_x15_r0_body.s1836.stores = PRE_first_tail_x15_r0_body.kappa190.stores PRE_first_tail_x15_r0_body.s1837.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots190 : checkRootsSupp PRE_first_tail_x15_r0_body.s1837 8201 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC190 : PRE_first_tail_x15_r0_body.S1835.tab.length + PRE_first_tail_x15_r0_body.cws190.length = 8201
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap190 : PRE_first_tail_x15_r0_body.kappa190 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1835.next 2824367 PRE_first_tail_x15_r0_body.S1835.tab.length PRE_first_tail_x15_r0_body.pl190 (PRE_first_tail_x15_r0_body.nr190.map NumV.ref) PRE_first_tail_x15_r0_body.kd190.big
  PRE_first_tail_x15_r0_body.kd190.region PRE_first_tail_x15_r0_body.kd190.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin190 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1837.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc190 : Conv.jcleanListB (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1837 PRE_first_tail_x15_r0_body.cl190 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB190 : noBigRootsP (fun i => !Conv.oldBigB (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1837.trace PRE_first_tail_x15_r0_body.s1837 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm190 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 19047 = true
theorem PRE_first_tail_x15_r0_body.cjcl190 (h : Conv.JClean (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1835) : Conv.JClean (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1837 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle190)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap190 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd190 a ha)) PRE_first_tail_x15_r0_body.zjc190

end Host.Load.Run.Tpl

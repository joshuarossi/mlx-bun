import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS172
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK172
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF172
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 172 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1663`, the merged
state `PRE_first_tail_x15_r0_body.s1664`, the canonical state `PRE_first_tail_x15_r0_body.s1665`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl172 : PRE_first_tail_x15_r0_body.pl172.all (Nat.ble PRE_first_tail_x15_r0_body.s1663.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd172 : nodupT PRE_first_tail_x15_r0_body.pl172 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1172 : Nat.ble PRE_first_tail_x15_r0_body.s1663.next 2810057 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst172 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1663.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn172 : PRE_first_tail_x15_r0_body.s1665.next = PRE_first_tail_x15_r0_body.s1663.next + PRE_first_tail_x15_r0_body.pl172.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn172 : PRE_first_tail_x15_r0_body.s1664.next = 2810057
kernel_rfl PRE_first_tail_x15_r0_body.zgrow172 : Nat.ble PRE_first_tail_x15_r0_body.s1665.next PRE_first_tail_x15_r0_body.s1664.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh172 : PRE_first_tail_x15_r0_body.S1663.tab.all (fun e => PRE_first_tail_x15_r0_body.cws172.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd172 : nodupT PRE_first_tail_x15_r0_body.cws172 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi172 : PRE_first_tail_x15_r0_body.nr172.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1664.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt172 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1663.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg172_2665 : PRE_first_tail_x15_r0_body.s1665.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1665 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk172_2665 : (objOf PRE_first_tail_x15_r0_body.s1665 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm172_2665 : PRE_first_tail_x15_r0_body.s1664.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa172.obj (objOf PRE_first_tail_x15_r0_body.s1665 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1664 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg172_2673467 : PRE_first_tail_x15_r0_body.s1665.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1665 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk172_2673467 : (objOf PRE_first_tail_x15_r0_body.s1665 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm172_2673467 : PRE_first_tail_x15_r0_body.s1664.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa172.obj (objOf PRE_first_tail_x15_r0_body.s1665 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1664 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw172_4910 : (PRE_first_tail_x15_r0_body.s1665.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw172_2673472 : (PRE_first_tail_x15_r0_body.s1665.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw172_2673473 : (PRE_first_tail_x15_r0_body.s1665.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd172 : PRE_first_tail_x15_r0_body.cl172.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr172 : PRE_first_tail_x15_r0_body.st172.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1663.next || PRE_first_tail_x15_r0_body.cl172.contains b) = true
def PRE_first_tail_x15_r0_body.zl172 : List Nat := PRE_first_tail_x15_r0_body.cl172.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE172 : PRE_first_tail_x15_r0_body.zl172.map (fun a => PRE_first_tail_x15_r0_body.s1664.heap.get (PRE_first_tail_x15_r0_body.kappa172.a a)) = PRE_first_tail_x15_r0_body.zl172.map (fun a => (PRE_first_tail_x15_r0_body.s1665.heap.get a).map PRE_first_tail_x15_r0_body.kappa172.hobj)
theorem PRE_first_tail_x15_r0_body.zimg172 : HeapImg PRE_first_tail_x15_r0_body.kappa172 PRE_first_tail_x15_r0_body.s1665 PRE_first_tail_x15_r0_body.s1664 PRE_first_tail_x15_r0_body.zl172 := PRE_first_tail_x15_r0_body.zimgE172
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl172 : PRE_first_tail_x15_r0_body.s1664.ctl = PRE_first_tail_x15_r0_body.kappa172.ctl PRE_first_tail_x15_r0_body.s1665.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack172 : PRE_first_tail_x15_r0_body.s1664.stack = PRE_first_tail_x15_r0_body.s1665.stack.map PRE_first_tail_x15_r0_body.kappa172.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs172 : PRE_first_tail_x15_r0_body.s1664.jobs = PRE_first_tail_x15_r0_body.s1665.jobs.map PRE_first_tail_x15_r0_body.kappa172.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores172 : PRE_first_tail_x15_r0_body.s1664.stores = PRE_first_tail_x15_r0_body.kappa172.stores PRE_first_tail_x15_r0_body.s1665.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots172 : checkRootsSupp PRE_first_tail_x15_r0_body.s1665 7433 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC172 : PRE_first_tail_x15_r0_body.S1663.tab.length + PRE_first_tail_x15_r0_body.cws172.length = 7433
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap172 : PRE_first_tail_x15_r0_body.kappa172 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1663.next 2810057 PRE_first_tail_x15_r0_body.S1663.tab.length PRE_first_tail_x15_r0_body.pl172 (PRE_first_tail_x15_r0_body.nr172.map NumV.ref) PRE_first_tail_x15_r0_body.kd172.big
  PRE_first_tail_x15_r0_body.kd172.region PRE_first_tail_x15_r0_body.kd172.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin172 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1665.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc172 : Conv.jcleanListB (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1665 PRE_first_tail_x15_r0_body.cl172 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB172 : noBigRootsP (fun i => !Conv.oldBigB (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1665.trace PRE_first_tail_x15_r0_body.s1665 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm172 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18699 = true
theorem PRE_first_tail_x15_r0_body.cjcl172 (h : Conv.JClean (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1663) : Conv.JClean (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1665 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle172)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap172 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd172 a ha)) PRE_first_tail_x15_r0_body.zjc172

end Host.Load.Run.Tpl

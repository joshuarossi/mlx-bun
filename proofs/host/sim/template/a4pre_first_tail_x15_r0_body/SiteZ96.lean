import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS96
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK96
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF96
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 96 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s936`, the merged
state `PRE_first_tail_x15_r0_body.s937`, the canonical state `PRE_first_tail_x15_r0_body.s938`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl96 : PRE_first_tail_x15_r0_body.pl96.all (Nat.ble PRE_first_tail_x15_r0_body.s936.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd96 : nodupT PRE_first_tail_x15_r0_body.pl96 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn196 : Nat.ble PRE_first_tail_x15_r0_body.s936.next 2751946 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst96 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s936.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn96 : PRE_first_tail_x15_r0_body.s938.next = PRE_first_tail_x15_r0_body.s936.next + PRE_first_tail_x15_r0_body.pl96.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn96 : PRE_first_tail_x15_r0_body.s937.next = 2751946
kernel_rfl PRE_first_tail_x15_r0_body.zgrow96 : Nat.ble PRE_first_tail_x15_r0_body.s938.next PRE_first_tail_x15_r0_body.s937.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh96 : PRE_first_tail_x15_r0_body.S936.tab.all (fun e => PRE_first_tail_x15_r0_body.cws96.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd96 : nodupT PRE_first_tail_x15_r0_body.cws96 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi96 : PRE_first_tail_x15_r0_body.nr96.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S937.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt96 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s936.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg96_2665 : PRE_first_tail_x15_r0_body.s938.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s938 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk96_2665 : (objOf PRE_first_tail_x15_r0_body.s938 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm96_2665 : PRE_first_tail_x15_r0_body.s937.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa96.obj (objOf PRE_first_tail_x15_r0_body.s938 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s937 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg96_2673467 : PRE_first_tail_x15_r0_body.s938.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s938 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk96_2673467 : (objOf PRE_first_tail_x15_r0_body.s938 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm96_2673467 : PRE_first_tail_x15_r0_body.s937.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa96.obj (objOf PRE_first_tail_x15_r0_body.s938 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s937 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw96_4910 : (PRE_first_tail_x15_r0_body.s938.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw96_2673472 : (PRE_first_tail_x15_r0_body.s938.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw96_2673473 : (PRE_first_tail_x15_r0_body.s938.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd96 : PRE_first_tail_x15_r0_body.cl96.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr96 : PRE_first_tail_x15_r0_body.st96.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s936.next || PRE_first_tail_x15_r0_body.cl96.contains b) = true
def PRE_first_tail_x15_r0_body.zl96 : List Nat := PRE_first_tail_x15_r0_body.cl96.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE96 : PRE_first_tail_x15_r0_body.zl96.map (fun a => PRE_first_tail_x15_r0_body.s937.heap.get (PRE_first_tail_x15_r0_body.kappa96.a a)) = PRE_first_tail_x15_r0_body.zl96.map (fun a => (PRE_first_tail_x15_r0_body.s938.heap.get a).map PRE_first_tail_x15_r0_body.kappa96.hobj)
theorem PRE_first_tail_x15_r0_body.zimg96 : HeapImg PRE_first_tail_x15_r0_body.kappa96 PRE_first_tail_x15_r0_body.s938 PRE_first_tail_x15_r0_body.s937 PRE_first_tail_x15_r0_body.zl96 := PRE_first_tail_x15_r0_body.zimgE96
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl96 : PRE_first_tail_x15_r0_body.s937.ctl = PRE_first_tail_x15_r0_body.kappa96.ctl PRE_first_tail_x15_r0_body.s938.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack96 : PRE_first_tail_x15_r0_body.s937.stack = PRE_first_tail_x15_r0_body.s938.stack.map PRE_first_tail_x15_r0_body.kappa96.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs96 : PRE_first_tail_x15_r0_body.s937.jobs = PRE_first_tail_x15_r0_body.s938.jobs.map PRE_first_tail_x15_r0_body.kappa96.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores96 : PRE_first_tail_x15_r0_body.s937.stores = PRE_first_tail_x15_r0_body.kappa96.stores PRE_first_tail_x15_r0_body.s938.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots96 : checkRootsSupp PRE_first_tail_x15_r0_body.s938 4205 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC96 : PRE_first_tail_x15_r0_body.S936.tab.length + PRE_first_tail_x15_r0_body.cws96.length = 4205
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap96 : PRE_first_tail_x15_r0_body.kappa96 = Conv.Map.compact PRE_first_tail_x15_r0_body.s936.next 2751946 PRE_first_tail_x15_r0_body.S936.tab.length PRE_first_tail_x15_r0_body.pl96 (PRE_first_tail_x15_r0_body.nr96.map NumV.ref) PRE_first_tail_x15_r0_body.kd96.big
  PRE_first_tail_x15_r0_body.kd96.region PRE_first_tail_x15_r0_body.kd96.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin96 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s938.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc96 : Conv.jcleanListB (⟨20107, 17201, 2750797, 4205⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s938 PRE_first_tail_x15_r0_body.cl96 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB96 : noBigRootsP (fun i => !Conv.oldBigB (⟨20107, 17201, 2750797, 4205⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s938.trace PRE_first_tail_x15_r0_body.s938 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm96 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17174 = true
theorem PRE_first_tail_x15_r0_body.cjcl96 (h : Conv.JClean (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s936) : Conv.JClean (⟨20107, 17201, 2750797, 4205⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s938 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle96)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap96 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd96 a ha)) PRE_first_tail_x15_r0_body.zjc96

end Host.Load.Run.Tpl

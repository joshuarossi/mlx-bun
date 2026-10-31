import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS108
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK108
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF108
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 108 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1051`, the merged
state `PRE_first_tail_x15_r0_body.s1052`, the canonical state `PRE_first_tail_x15_r0_body.s1053`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl108 : PRE_first_tail_x15_r0_body.pl108.all (Nat.ble PRE_first_tail_x15_r0_body.s1051.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd108 : nodupT PRE_first_tail_x15_r0_body.pl108 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1108 : Nat.ble PRE_first_tail_x15_r0_body.s1051.next 2761366 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst108 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1051.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn108 : PRE_first_tail_x15_r0_body.s1053.next = PRE_first_tail_x15_r0_body.s1051.next + PRE_first_tail_x15_r0_body.pl108.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn108 : PRE_first_tail_x15_r0_body.s1052.next = 2761366
kernel_rfl PRE_first_tail_x15_r0_body.zgrow108 : Nat.ble PRE_first_tail_x15_r0_body.s1053.next PRE_first_tail_x15_r0_body.s1052.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh108 : PRE_first_tail_x15_r0_body.S1051.tab.all (fun e => PRE_first_tail_x15_r0_body.cws108.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd108 : nodupT PRE_first_tail_x15_r0_body.cws108 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi108 : PRE_first_tail_x15_r0_body.nr108.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1052.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt108 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1051.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg108_2665 : PRE_first_tail_x15_r0_body.s1053.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1053 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk108_2665 : (objOf PRE_first_tail_x15_r0_body.s1053 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm108_2665 : PRE_first_tail_x15_r0_body.s1052.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa108.obj (objOf PRE_first_tail_x15_r0_body.s1053 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1052 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg108_2673467 : PRE_first_tail_x15_r0_body.s1053.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1053 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk108_2673467 : (objOf PRE_first_tail_x15_r0_body.s1053 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm108_2673467 : PRE_first_tail_x15_r0_body.s1052.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa108.obj (objOf PRE_first_tail_x15_r0_body.s1053 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1052 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw108_4910 : (PRE_first_tail_x15_r0_body.s1053.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw108_2673472 : (PRE_first_tail_x15_r0_body.s1053.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw108_2673473 : (PRE_first_tail_x15_r0_body.s1053.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd108 : PRE_first_tail_x15_r0_body.cl108.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr108 : PRE_first_tail_x15_r0_body.st108.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1051.next || PRE_first_tail_x15_r0_body.cl108.contains b) = true
def PRE_first_tail_x15_r0_body.zl108 : List Nat := PRE_first_tail_x15_r0_body.cl108.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE108 : PRE_first_tail_x15_r0_body.zl108.map (fun a => PRE_first_tail_x15_r0_body.s1052.heap.get (PRE_first_tail_x15_r0_body.kappa108.a a)) = PRE_first_tail_x15_r0_body.zl108.map (fun a => (PRE_first_tail_x15_r0_body.s1053.heap.get a).map PRE_first_tail_x15_r0_body.kappa108.hobj)
theorem PRE_first_tail_x15_r0_body.zimg108 : HeapImg PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.s1053 PRE_first_tail_x15_r0_body.s1052 PRE_first_tail_x15_r0_body.zl108 := PRE_first_tail_x15_r0_body.zimgE108
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl108 : PRE_first_tail_x15_r0_body.s1052.ctl = PRE_first_tail_x15_r0_body.kappa108.ctl PRE_first_tail_x15_r0_body.s1053.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack108 : PRE_first_tail_x15_r0_body.s1052.stack = PRE_first_tail_x15_r0_body.s1053.stack.map PRE_first_tail_x15_r0_body.kappa108.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs108 : PRE_first_tail_x15_r0_body.s1052.jobs = PRE_first_tail_x15_r0_body.s1053.jobs.map PRE_first_tail_x15_r0_body.kappa108.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores108 : PRE_first_tail_x15_r0_body.s1052.stores = PRE_first_tail_x15_r0_body.kappa108.stores PRE_first_tail_x15_r0_body.s1053.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots108 : checkRootsSupp PRE_first_tail_x15_r0_body.s1053 4718 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC108 : PRE_first_tail_x15_r0_body.S1051.tab.length + PRE_first_tail_x15_r0_body.cws108.length = 4718
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap108 : PRE_first_tail_x15_r0_body.kappa108 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1051.next 2761366 PRE_first_tail_x15_r0_body.S1051.tab.length PRE_first_tail_x15_r0_body.pl108 (PRE_first_tail_x15_r0_body.nr108.map NumV.ref) PRE_first_tail_x15_r0_body.kd108.big
  PRE_first_tail_x15_r0_body.kd108.region PRE_first_tail_x15_r0_body.kd108.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin108 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1053.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc108 : Conv.jcleanListB (⟨20343, 17438, 2760217, 4718⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1053 PRE_first_tail_x15_r0_body.cl108 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB108 : noBigRootsP (fun i => !Conv.oldBigB (⟨20343, 17438, 2760217, 4718⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1053.trace PRE_first_tail_x15_r0_body.s1053 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm108 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17411 = true
theorem PRE_first_tail_x15_r0_body.cjcl108 (h : Conv.JClean (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1051) : Conv.JClean (⟨20343, 17438, 2760217, 4718⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1053 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle108)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap108 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd108 a ha)) PRE_first_tail_x15_r0_body.zjc108

end Host.Load.Run.Tpl

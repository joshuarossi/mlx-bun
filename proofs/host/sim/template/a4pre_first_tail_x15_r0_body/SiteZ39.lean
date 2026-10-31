import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS39
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK39
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF39
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 39 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s356`, the merged
state `PRE_first_tail_x15_r0_body.s357`, the canonical state `PRE_first_tail_x15_r0_body.s358`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl39 : PRE_first_tail_x15_r0_body.pl39.all (Nat.ble PRE_first_tail_x15_r0_body.s356.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd39 : nodupT PRE_first_tail_x15_r0_body.pl39 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn139 : Nat.ble PRE_first_tail_x15_r0_body.s356.next 2707114 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst39 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s356.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn39 : PRE_first_tail_x15_r0_body.s358.next = PRE_first_tail_x15_r0_body.s356.next + PRE_first_tail_x15_r0_body.pl39.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn39 : PRE_first_tail_x15_r0_body.s357.next = 2707114
kernel_rfl PRE_first_tail_x15_r0_body.zgrow39 : Nat.ble PRE_first_tail_x15_r0_body.s358.next PRE_first_tail_x15_r0_body.s357.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh39 : PRE_first_tail_x15_r0_body.S356.tab.all (fun e => PRE_first_tail_x15_r0_body.cws39.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd39 : nodupT PRE_first_tail_x15_r0_body.cws39 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi39 : PRE_first_tail_x15_r0_body.nr39.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S357.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt39 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s356.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg39_2665 : PRE_first_tail_x15_r0_body.s358.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s358 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk39_2665 : (objOf PRE_first_tail_x15_r0_body.s358 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm39_2665 : PRE_first_tail_x15_r0_body.s357.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa39.obj (objOf PRE_first_tail_x15_r0_body.s358 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s357 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg39_2673467 : PRE_first_tail_x15_r0_body.s358.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s358 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk39_2673467 : (objOf PRE_first_tail_x15_r0_body.s358 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm39_2673467 : PRE_first_tail_x15_r0_body.s357.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa39.obj (objOf PRE_first_tail_x15_r0_body.s358 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s357 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw39_4910 : (PRE_first_tail_x15_r0_body.s358.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw39_2673472 : (PRE_first_tail_x15_r0_body.s358.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw39_2673473 : (PRE_first_tail_x15_r0_body.s358.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd39 : PRE_first_tail_x15_r0_body.cl39.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr39 : PRE_first_tail_x15_r0_body.st39.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s356.next || PRE_first_tail_x15_r0_body.cl39.contains b) = true
def PRE_first_tail_x15_r0_body.zl39 : List Nat := PRE_first_tail_x15_r0_body.cl39.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE39 : PRE_first_tail_x15_r0_body.zl39.map (fun a => PRE_first_tail_x15_r0_body.s357.heap.get (PRE_first_tail_x15_r0_body.kappa39.a a)) = PRE_first_tail_x15_r0_body.zl39.map (fun a => (PRE_first_tail_x15_r0_body.s358.heap.get a).map PRE_first_tail_x15_r0_body.kappa39.hobj)
theorem PRE_first_tail_x15_r0_body.zimg39 : HeapImg PRE_first_tail_x15_r0_body.kappa39 PRE_first_tail_x15_r0_body.s358 PRE_first_tail_x15_r0_body.s357 PRE_first_tail_x15_r0_body.zl39 := PRE_first_tail_x15_r0_body.zimgE39
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl39 : PRE_first_tail_x15_r0_body.s357.ctl = PRE_first_tail_x15_r0_body.kappa39.ctl PRE_first_tail_x15_r0_body.s358.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack39 : PRE_first_tail_x15_r0_body.s357.stack = PRE_first_tail_x15_r0_body.s358.stack.map PRE_first_tail_x15_r0_body.kappa39.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs39 : PRE_first_tail_x15_r0_body.s357.jobs = PRE_first_tail_x15_r0_body.s358.jobs.map PRE_first_tail_x15_r0_body.kappa39.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores39 : PRE_first_tail_x15_r0_body.s357.stores = PRE_first_tail_x15_r0_body.kappa39.stores PRE_first_tail_x15_r0_body.s358.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots39 : checkRootsSupp PRE_first_tail_x15_r0_body.s358 1769 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC39 : PRE_first_tail_x15_r0_body.S356.tab.length + PRE_first_tail_x15_r0_body.cws39.length = 1769
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap39 : PRE_first_tail_x15_r0_body.kappa39 = Conv.Map.compact PRE_first_tail_x15_r0_body.s356.next 2707114 PRE_first_tail_x15_r0_body.S356.tab.length PRE_first_tail_x15_r0_body.pl39 (PRE_first_tail_x15_r0_body.nr39.map NumV.ref) PRE_first_tail_x15_r0_body.kd39.big
  PRE_first_tail_x15_r0_body.kd39.region PRE_first_tail_x15_r0_body.kd39.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin39 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s358.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc39 : Conv.jcleanListB (⟨18984, 16079, 2705965, 1769⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s358 PRE_first_tail_x15_r0_body.cl39 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots239 : noBigRootsP (fun i => !Conv.oldBigB (⟨18984, 16079, 2705965, 1769⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s358.trace PRE_first_tail_x15_r0_body.s358 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm39 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16052 = true
theorem PRE_first_tail_x15_r0_body.cjcl39 (h : Conv.JClean (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s356) : Conv.JClean (⟨18984, 16079, 2705965, 1769⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s358 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle39)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap39 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd39 a ha)) PRE_first_tail_x15_r0_body.zjc39

end Host.Load.Run.Tpl

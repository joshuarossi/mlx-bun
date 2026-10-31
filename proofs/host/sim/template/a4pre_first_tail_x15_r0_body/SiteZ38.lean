import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS38
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK38
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF38
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 38 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s340`, the merged
state `PRE_first_tail_x15_r0_body.s341`, the canonical state `PRE_first_tail_x15_r0_body.s342`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl38 : PRE_first_tail_x15_r0_body.pl38.all (Nat.ble PRE_first_tail_x15_r0_body.s340.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd38 : nodupT PRE_first_tail_x15_r0_body.pl38 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn138 : Nat.ble PRE_first_tail_x15_r0_body.s340.next 2704498 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst38 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s340.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn38 : PRE_first_tail_x15_r0_body.s342.next = PRE_first_tail_x15_r0_body.s340.next + PRE_first_tail_x15_r0_body.pl38.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn38 : PRE_first_tail_x15_r0_body.s341.next = 2704498
kernel_rfl PRE_first_tail_x15_r0_body.zgrow38 : Nat.ble PRE_first_tail_x15_r0_body.s342.next PRE_first_tail_x15_r0_body.s341.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh38 : PRE_first_tail_x15_r0_body.S340.tab.all (fun e => PRE_first_tail_x15_r0_body.cws38.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd38 : nodupT PRE_first_tail_x15_r0_body.cws38 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi38 : PRE_first_tail_x15_r0_body.nr38.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S341.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt38 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s340.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg38_2665 : PRE_first_tail_x15_r0_body.s342.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s342 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk38_2665 : (objOf PRE_first_tail_x15_r0_body.s342 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm38_2665 : PRE_first_tail_x15_r0_body.s341.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa38.obj (objOf PRE_first_tail_x15_r0_body.s342 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s341 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg38_2673467 : PRE_first_tail_x15_r0_body.s342.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s342 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk38_2673467 : (objOf PRE_first_tail_x15_r0_body.s342 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm38_2673467 : PRE_first_tail_x15_r0_body.s341.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa38.obj (objOf PRE_first_tail_x15_r0_body.s342 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s341 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw38_4910 : (PRE_first_tail_x15_r0_body.s342.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw38_2673472 : (PRE_first_tail_x15_r0_body.s342.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw38_2673473 : (PRE_first_tail_x15_r0_body.s342.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd38 : PRE_first_tail_x15_r0_body.cl38.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr38 : PRE_first_tail_x15_r0_body.st38.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s340.next || PRE_first_tail_x15_r0_body.cl38.contains b) = true
def PRE_first_tail_x15_r0_body.zl38 : List Nat := PRE_first_tail_x15_r0_body.cl38.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE38 : PRE_first_tail_x15_r0_body.zl38.map (fun a => PRE_first_tail_x15_r0_body.s341.heap.get (PRE_first_tail_x15_r0_body.kappa38.a a)) = PRE_first_tail_x15_r0_body.zl38.map (fun a => (PRE_first_tail_x15_r0_body.s342.heap.get a).map PRE_first_tail_x15_r0_body.kappa38.hobj)
theorem PRE_first_tail_x15_r0_body.zimg38 : HeapImg PRE_first_tail_x15_r0_body.kappa38 PRE_first_tail_x15_r0_body.s342 PRE_first_tail_x15_r0_body.s341 PRE_first_tail_x15_r0_body.zl38 := PRE_first_tail_x15_r0_body.zimgE38
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl38 : PRE_first_tail_x15_r0_body.s341.ctl = PRE_first_tail_x15_r0_body.kappa38.ctl PRE_first_tail_x15_r0_body.s342.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack38 : PRE_first_tail_x15_r0_body.s341.stack = PRE_first_tail_x15_r0_body.s342.stack.map PRE_first_tail_x15_r0_body.kappa38.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs38 : PRE_first_tail_x15_r0_body.s341.jobs = PRE_first_tail_x15_r0_body.s342.jobs.map PRE_first_tail_x15_r0_body.kappa38.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores38 : PRE_first_tail_x15_r0_body.s341.stores = PRE_first_tail_x15_r0_body.kappa38.stores PRE_first_tail_x15_r0_body.s342.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots38 : checkRootsSupp PRE_first_tail_x15_r0_body.s342 1678 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC38 : PRE_first_tail_x15_r0_body.S340.tab.length + PRE_first_tail_x15_r0_body.cws38.length = 1678
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap38 : PRE_first_tail_x15_r0_body.kappa38 = Conv.Map.compact PRE_first_tail_x15_r0_body.s340.next 2704498 PRE_first_tail_x15_r0_body.S340.tab.length PRE_first_tail_x15_r0_body.pl38 (PRE_first_tail_x15_r0_body.nr38.map NumV.ref) PRE_first_tail_x15_r0_body.kd38.big
  PRE_first_tail_x15_r0_body.kd38.region PRE_first_tail_x15_r0_body.kd38.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin38 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s342.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc38 : Conv.jcleanListB (⟨18947, 16033, 2704488, 1678⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s342 PRE_first_tail_x15_r0_body.cl38 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots238 : noBigRootsP (fun i => !Conv.oldBigB (⟨18947, 16033, 2704488, 1678⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s342.trace PRE_first_tail_x15_r0_body.s342 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm38 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16033 = true
theorem PRE_first_tail_x15_r0_body.cjcl38 (h : Conv.JClean (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s340) : Conv.JClean (⟨18947, 16033, 2704488, 1678⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s342 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle38)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap38 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd38 a ha)) PRE_first_tail_x15_r0_body.zjc38

end Host.Load.Run.Tpl

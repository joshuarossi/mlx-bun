import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS34
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK34
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF34
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 34 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s340`, the merged
state `PRE_first_tail_x15_r0_body.s341`, the canonical state `PRE_first_tail_x15_r0_body.s342`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl34 : PRE_first_tail_x15_r0_body.pl34.all (Nat.ble PRE_first_tail_x15_r0_body.s340.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd34 : nodupT PRE_first_tail_x15_r0_body.pl34 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn134 : Nat.ble PRE_first_tail_x15_r0_body.s340.next 2701919 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst34 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s340.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn34 : PRE_first_tail_x15_r0_body.s342.next = PRE_first_tail_x15_r0_body.s340.next + PRE_first_tail_x15_r0_body.pl34.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn34 : PRE_first_tail_x15_r0_body.s341.next = 2701919
kernel_rfl PRE_first_tail_x15_r0_body.zgrow34 : Nat.ble PRE_first_tail_x15_r0_body.s342.next PRE_first_tail_x15_r0_body.s341.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh34 : PRE_first_tail_x15_r0_body.S340.tab.all (fun e => PRE_first_tail_x15_r0_body.cws34.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd34 : nodupT PRE_first_tail_x15_r0_body.cws34 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi34 : PRE_first_tail_x15_r0_body.nr34.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S341.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt34 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s340.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg34_2665 : PRE_first_tail_x15_r0_body.s342.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s342 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk34_2665 : (objOf PRE_first_tail_x15_r0_body.s342 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm34_2665 : PRE_first_tail_x15_r0_body.s341.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa34.obj (objOf PRE_first_tail_x15_r0_body.s342 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s341 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg34_2673467 : PRE_first_tail_x15_r0_body.s342.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s342 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk34_2673467 : (objOf PRE_first_tail_x15_r0_body.s342 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm34_2673467 : PRE_first_tail_x15_r0_body.s341.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa34.obj (objOf PRE_first_tail_x15_r0_body.s342 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s341 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw34_4910 : (PRE_first_tail_x15_r0_body.s342.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw34_2673472 : (PRE_first_tail_x15_r0_body.s342.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw34_2673473 : (PRE_first_tail_x15_r0_body.s342.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd34 : PRE_first_tail_x15_r0_body.cl34.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr34 : PRE_first_tail_x15_r0_body.st34.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s340.next || PRE_first_tail_x15_r0_body.cl34.contains b) = true
def PRE_first_tail_x15_r0_body.zl34 : List Nat := PRE_first_tail_x15_r0_body.cl34.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE34 : PRE_first_tail_x15_r0_body.zl34.map (fun a => PRE_first_tail_x15_r0_body.s341.heap.get (PRE_first_tail_x15_r0_body.kappa34.a a)) = PRE_first_tail_x15_r0_body.zl34.map (fun a => (PRE_first_tail_x15_r0_body.s342.heap.get a).map PRE_first_tail_x15_r0_body.kappa34.hobj)
theorem PRE_first_tail_x15_r0_body.zimg34 : HeapImg PRE_first_tail_x15_r0_body.kappa34 PRE_first_tail_x15_r0_body.s342 PRE_first_tail_x15_r0_body.s341 PRE_first_tail_x15_r0_body.zl34 := PRE_first_tail_x15_r0_body.zimgE34
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl34 : PRE_first_tail_x15_r0_body.s341.ctl = PRE_first_tail_x15_r0_body.kappa34.ctl PRE_first_tail_x15_r0_body.s342.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack34 : PRE_first_tail_x15_r0_body.s341.stack = PRE_first_tail_x15_r0_body.s342.stack.map PRE_first_tail_x15_r0_body.kappa34.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs34 : PRE_first_tail_x15_r0_body.s341.jobs = PRE_first_tail_x15_r0_body.s342.jobs.map PRE_first_tail_x15_r0_body.kappa34.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores34 : PRE_first_tail_x15_r0_body.s341.stores = PRE_first_tail_x15_r0_body.kappa34.stores PRE_first_tail_x15_r0_body.s342.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots34 : checkRootsSupp PRE_first_tail_x15_r0_body.s342 1532 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC34 : PRE_first_tail_x15_r0_body.S340.tab.length + PRE_first_tail_x15_r0_body.cws34.length = 1532
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap34 : PRE_first_tail_x15_r0_body.kappa34 = Conv.Map.compact PRE_first_tail_x15_r0_body.s340.next 2701919 PRE_first_tail_x15_r0_body.S340.tab.length PRE_first_tail_x15_r0_body.pl34 (PRE_first_tail_x15_r0_body.nr34.map NumV.ref) PRE_first_tail_x15_r0_body.kd34.big
  PRE_first_tail_x15_r0_body.kd34.region PRE_first_tail_x15_r0_body.kd34.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin34 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s342.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc34 : Conv.jcleanListB (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s342 PRE_first_tail_x15_r0_body.cl34 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB34 : noBigRootsP (fun i => !Conv.oldBigB (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s342.trace PRE_first_tail_x15_r0_body.s342 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm34 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15966 = true
theorem PRE_first_tail_x15_r0_body.cjcl34 (h : Conv.JClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s340) : Conv.JClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s342 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle34)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap34 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd34 a ha)) PRE_first_tail_x15_r0_body.zjc34

end Host.Load.Run.Tpl

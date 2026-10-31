import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS165
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK165
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF165
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 165 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1457`, the merged
state `PRE_first_tail_x15_r0_body.s1458`, the canonical state `PRE_first_tail_x15_r0_body.s1459`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl165 : PRE_first_tail_x15_r0_body.pl165.all (Nat.ble PRE_first_tail_x15_r0_body.s1457.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd165 : nodupT PRE_first_tail_x15_r0_body.pl165 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1165 : Nat.ble PRE_first_tail_x15_r0_body.s1457.next 2805281 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst165 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1457.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn165 : PRE_first_tail_x15_r0_body.s1459.next = PRE_first_tail_x15_r0_body.s1457.next + PRE_first_tail_x15_r0_body.pl165.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn165 : PRE_first_tail_x15_r0_body.s1458.next = 2805281
kernel_rfl PRE_first_tail_x15_r0_body.zgrow165 : Nat.ble PRE_first_tail_x15_r0_body.s1459.next PRE_first_tail_x15_r0_body.s1458.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh165 : PRE_first_tail_x15_r0_body.S1457.tab.all (fun e => PRE_first_tail_x15_r0_body.cws165.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd165 : nodupT PRE_first_tail_x15_r0_body.cws165 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi165 : PRE_first_tail_x15_r0_body.nr165.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1458.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt165 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1457.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg165_2665 : PRE_first_tail_x15_r0_body.s1459.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1459 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk165_2665 : (objOf PRE_first_tail_x15_r0_body.s1459 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm165_2665 : PRE_first_tail_x15_r0_body.s1458.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa165.obj (objOf PRE_first_tail_x15_r0_body.s1459 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1458 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg165_2673467 : PRE_first_tail_x15_r0_body.s1459.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1459 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk165_2673467 : (objOf PRE_first_tail_x15_r0_body.s1459 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm165_2673467 : PRE_first_tail_x15_r0_body.s1458.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa165.obj (objOf PRE_first_tail_x15_r0_body.s1459 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1458 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw165_4910 : (PRE_first_tail_x15_r0_body.s1459.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw165_2673472 : (PRE_first_tail_x15_r0_body.s1459.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw165_2673473 : (PRE_first_tail_x15_r0_body.s1459.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd165 : PRE_first_tail_x15_r0_body.cl165.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr165 : PRE_first_tail_x15_r0_body.st165.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1457.next || PRE_first_tail_x15_r0_body.cl165.contains b) = true
def PRE_first_tail_x15_r0_body.zl165 : List Nat := PRE_first_tail_x15_r0_body.cl165.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE165 : PRE_first_tail_x15_r0_body.zl165.map (fun a => PRE_first_tail_x15_r0_body.s1458.heap.get (PRE_first_tail_x15_r0_body.kappa165.a a)) = PRE_first_tail_x15_r0_body.zl165.map (fun a => (PRE_first_tail_x15_r0_body.s1459.heap.get a).map PRE_first_tail_x15_r0_body.kappa165.hobj)
theorem PRE_first_tail_x15_r0_body.zimg165 : HeapImg PRE_first_tail_x15_r0_body.kappa165 PRE_first_tail_x15_r0_body.s1459 PRE_first_tail_x15_r0_body.s1458 PRE_first_tail_x15_r0_body.zl165 := PRE_first_tail_x15_r0_body.zimgE165
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl165 : PRE_first_tail_x15_r0_body.s1458.ctl = PRE_first_tail_x15_r0_body.kappa165.ctl PRE_first_tail_x15_r0_body.s1459.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack165 : PRE_first_tail_x15_r0_body.s1458.stack = PRE_first_tail_x15_r0_body.s1459.stack.map PRE_first_tail_x15_r0_body.kappa165.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs165 : PRE_first_tail_x15_r0_body.s1458.jobs = PRE_first_tail_x15_r0_body.s1459.jobs.map PRE_first_tail_x15_r0_body.kappa165.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores165 : PRE_first_tail_x15_r0_body.s1458.stores = PRE_first_tail_x15_r0_body.kappa165.stores PRE_first_tail_x15_r0_body.s1459.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots165 : checkRootsSupp PRE_first_tail_x15_r0_body.s1459 7152 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC165 : PRE_first_tail_x15_r0_body.S1457.tab.length + PRE_first_tail_x15_r0_body.cws165.length = 7152
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap165 : PRE_first_tail_x15_r0_body.kappa165 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1457.next 2805281 PRE_first_tail_x15_r0_body.S1457.tab.length PRE_first_tail_x15_r0_body.pl165 (PRE_first_tail_x15_r0_body.nr165.map NumV.ref) PRE_first_tail_x15_r0_body.kd165.big
  PRE_first_tail_x15_r0_body.kd165.region PRE_first_tail_x15_r0_body.kd165.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin165 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1459.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc165 : Conv.jcleanListB (⟨21465, 18563, 2804931, 7152⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1459 PRE_first_tail_x15_r0_body.cl165 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2165 : noBigRootsP (fun i => !Conv.oldBigB (⟨21465, 18563, 2804931, 7152⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1459.trace PRE_first_tail_x15_r0_body.s1459 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm165 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18557 = true
theorem PRE_first_tail_x15_r0_body.cjcl165 (h : Conv.JClean (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1457) : Conv.JClean (⟨21465, 18563, 2804931, 7152⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1459 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle165)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap165 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd165 a ha)) PRE_first_tail_x15_r0_body.zjc165

end Host.Load.Run.Tpl

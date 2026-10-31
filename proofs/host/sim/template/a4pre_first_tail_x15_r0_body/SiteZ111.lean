import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS111
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK111
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF111
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 111 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1080`, the merged
state `PRE_first_tail_x15_r0_body.s1081`, the canonical state `PRE_first_tail_x15_r0_body.s1082`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl111 : PRE_first_tail_x15_r0_body.pl111.all (Nat.ble PRE_first_tail_x15_r0_body.s1080.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd111 : nodupT PRE_first_tail_x15_r0_body.pl111 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1111 : Nat.ble PRE_first_tail_x15_r0_body.s1080.next 2763622 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst111 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1080.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn111 : PRE_first_tail_x15_r0_body.s1082.next = PRE_first_tail_x15_r0_body.s1080.next + PRE_first_tail_x15_r0_body.pl111.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn111 : PRE_first_tail_x15_r0_body.s1081.next = 2763622
kernel_rfl PRE_first_tail_x15_r0_body.zgrow111 : Nat.ble PRE_first_tail_x15_r0_body.s1082.next PRE_first_tail_x15_r0_body.s1081.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh111 : PRE_first_tail_x15_r0_body.S1080.tab.all (fun e => PRE_first_tail_x15_r0_body.cws111.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd111 : nodupT PRE_first_tail_x15_r0_body.cws111 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi111 : PRE_first_tail_x15_r0_body.nr111.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1081.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt111 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1080.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg111_2665 : PRE_first_tail_x15_r0_body.s1082.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1082 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk111_2665 : (objOf PRE_first_tail_x15_r0_body.s1082 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm111_2665 : PRE_first_tail_x15_r0_body.s1081.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa111.obj (objOf PRE_first_tail_x15_r0_body.s1082 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1081 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg111_2673467 : PRE_first_tail_x15_r0_body.s1082.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1082 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk111_2673467 : (objOf PRE_first_tail_x15_r0_body.s1082 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm111_2673467 : PRE_first_tail_x15_r0_body.s1081.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa111.obj (objOf PRE_first_tail_x15_r0_body.s1082 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1081 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw111_4910 : (PRE_first_tail_x15_r0_body.s1082.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw111_2673472 : (PRE_first_tail_x15_r0_body.s1082.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw111_2673473 : (PRE_first_tail_x15_r0_body.s1082.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd111 : PRE_first_tail_x15_r0_body.cl111.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr111 : PRE_first_tail_x15_r0_body.st111.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1080.next || PRE_first_tail_x15_r0_body.cl111.contains b) = true
def PRE_first_tail_x15_r0_body.zl111 : List Nat := PRE_first_tail_x15_r0_body.cl111.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE111 : PRE_first_tail_x15_r0_body.zl111.map (fun a => PRE_first_tail_x15_r0_body.s1081.heap.get (PRE_first_tail_x15_r0_body.kappa111.a a)) = PRE_first_tail_x15_r0_body.zl111.map (fun a => (PRE_first_tail_x15_r0_body.s1082.heap.get a).map PRE_first_tail_x15_r0_body.kappa111.hobj)
theorem PRE_first_tail_x15_r0_body.zimg111 : HeapImg PRE_first_tail_x15_r0_body.kappa111 PRE_first_tail_x15_r0_body.s1082 PRE_first_tail_x15_r0_body.s1081 PRE_first_tail_x15_r0_body.zl111 := PRE_first_tail_x15_r0_body.zimgE111
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl111 : PRE_first_tail_x15_r0_body.s1081.ctl = PRE_first_tail_x15_r0_body.kappa111.ctl PRE_first_tail_x15_r0_body.s1082.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack111 : PRE_first_tail_x15_r0_body.s1081.stack = PRE_first_tail_x15_r0_body.s1082.stack.map PRE_first_tail_x15_r0_body.kappa111.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs111 : PRE_first_tail_x15_r0_body.s1081.jobs = PRE_first_tail_x15_r0_body.s1082.jobs.map PRE_first_tail_x15_r0_body.kappa111.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores111 : PRE_first_tail_x15_r0_body.s1081.stores = PRE_first_tail_x15_r0_body.kappa111.stores PRE_first_tail_x15_r0_body.s1082.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots111 : checkRootsSupp PRE_first_tail_x15_r0_body.s1082 4847 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC111 : PRE_first_tail_x15_r0_body.S1080.tab.length + PRE_first_tail_x15_r0_body.cws111.length = 4847
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap111 : PRE_first_tail_x15_r0_body.kappa111 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1080.next 2763622 PRE_first_tail_x15_r0_body.S1080.tab.length PRE_first_tail_x15_r0_body.pl111 (PRE_first_tail_x15_r0_body.nr111.map NumV.ref) PRE_first_tail_x15_r0_body.kd111.big
  PRE_first_tail_x15_r0_body.kd111.region PRE_first_tail_x15_r0_body.kd111.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin111 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1082.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc111 : Conv.jcleanListB (⟨20400, 17501, 2762473, 4847⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1082 PRE_first_tail_x15_r0_body.cl111 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB111 : noBigRootsP (fun i => !Conv.oldBigB (⟨20400, 17501, 2762473, 4847⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1082.trace PRE_first_tail_x15_r0_body.s1082 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm111 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17474 = true
theorem PRE_first_tail_x15_r0_body.cjcl111 (h : Conv.JClean (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1080) : Conv.JClean (⟨20400, 17501, 2762473, 4847⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1082 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle111)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap111 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd111 a ha)) PRE_first_tail_x15_r0_body.zjc111

end Host.Load.Run.Tpl

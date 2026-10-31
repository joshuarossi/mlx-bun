import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS50
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK50
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF50
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 50 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s445`, the merged
state `PRE_first_tail_x15_r0_body.s446`, the canonical state `PRE_first_tail_x15_r0_body.s447`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl50 : PRE_first_tail_x15_r0_body.pl50.all (Nat.ble PRE_first_tail_x15_r0_body.s445.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd50 : nodupT PRE_first_tail_x15_r0_body.pl50 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn150 : Nat.ble PRE_first_tail_x15_r0_body.s445.next 2713927 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst50 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s445.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn50 : PRE_first_tail_x15_r0_body.s447.next = PRE_first_tail_x15_r0_body.s445.next + PRE_first_tail_x15_r0_body.pl50.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn50 : PRE_first_tail_x15_r0_body.s446.next = 2713927
kernel_rfl PRE_first_tail_x15_r0_body.zgrow50 : Nat.ble PRE_first_tail_x15_r0_body.s447.next PRE_first_tail_x15_r0_body.s446.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh50 : PRE_first_tail_x15_r0_body.S445.tab.all (fun e => PRE_first_tail_x15_r0_body.cws50.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd50 : nodupT PRE_first_tail_x15_r0_body.cws50 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi50 : PRE_first_tail_x15_r0_body.nr50.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S446.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt50 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s445.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg50_2665 : PRE_first_tail_x15_r0_body.s447.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s447 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk50_2665 : (objOf PRE_first_tail_x15_r0_body.s447 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm50_2665 : PRE_first_tail_x15_r0_body.s446.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa50.obj (objOf PRE_first_tail_x15_r0_body.s447 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s446 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg50_2673467 : PRE_first_tail_x15_r0_body.s447.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s447 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk50_2673467 : (objOf PRE_first_tail_x15_r0_body.s447 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm50_2673467 : PRE_first_tail_x15_r0_body.s446.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa50.obj (objOf PRE_first_tail_x15_r0_body.s447 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s446 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw50_4910 : (PRE_first_tail_x15_r0_body.s447.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw50_2673472 : (PRE_first_tail_x15_r0_body.s447.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw50_2673473 : (PRE_first_tail_x15_r0_body.s447.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd50 : PRE_first_tail_x15_r0_body.cl50.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr50 : PRE_first_tail_x15_r0_body.st50.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s445.next || PRE_first_tail_x15_r0_body.cl50.contains b) = true
def PRE_first_tail_x15_r0_body.zl50 : List Nat := PRE_first_tail_x15_r0_body.cl50.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE50 : PRE_first_tail_x15_r0_body.zl50.map (fun a => PRE_first_tail_x15_r0_body.s446.heap.get (PRE_first_tail_x15_r0_body.kappa50.a a)) = PRE_first_tail_x15_r0_body.zl50.map (fun a => (PRE_first_tail_x15_r0_body.s447.heap.get a).map PRE_first_tail_x15_r0_body.kappa50.hobj)
theorem PRE_first_tail_x15_r0_body.zimg50 : HeapImg PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.s447 PRE_first_tail_x15_r0_body.s446 PRE_first_tail_x15_r0_body.zl50 := PRE_first_tail_x15_r0_body.zimgE50
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl50 : PRE_first_tail_x15_r0_body.s446.ctl = PRE_first_tail_x15_r0_body.kappa50.ctl PRE_first_tail_x15_r0_body.s447.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack50 : PRE_first_tail_x15_r0_body.s446.stack = PRE_first_tail_x15_r0_body.s447.stack.map PRE_first_tail_x15_r0_body.kappa50.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs50 : PRE_first_tail_x15_r0_body.s446.jobs = PRE_first_tail_x15_r0_body.s447.jobs.map PRE_first_tail_x15_r0_body.kappa50.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores50 : PRE_first_tail_x15_r0_body.s446.stores = PRE_first_tail_x15_r0_body.kappa50.stores PRE_first_tail_x15_r0_body.s447.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots50 : checkRootsSupp PRE_first_tail_x15_r0_body.s447 2191 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC50 : PRE_first_tail_x15_r0_body.S445.tab.length + PRE_first_tail_x15_r0_body.cws50.length = 2191
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap50 : PRE_first_tail_x15_r0_body.kappa50 = Conv.Map.compact PRE_first_tail_x15_r0_body.s445.next 2713927 PRE_first_tail_x15_r0_body.S445.tab.length PRE_first_tail_x15_r0_body.pl50 (PRE_first_tail_x15_r0_body.nr50.map NumV.ref) PRE_first_tail_x15_r0_body.kd50.big
  PRE_first_tail_x15_r0_body.kd50.region PRE_first_tail_x15_r0_body.kd50.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin50 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s447.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc50 : Conv.jcleanListB (⟨19183, 16270, 2713908, 2191⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s447 PRE_first_tail_x15_r0_body.cl50 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots250 : noBigRootsP (fun i => !Conv.oldBigB (⟨19183, 16270, 2713908, 2191⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s447.trace PRE_first_tail_x15_r0_body.s447 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm50 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16270 = true
theorem PRE_first_tail_x15_r0_body.cjcl50 (h : Conv.JClean (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s445) : Conv.JClean (⟨19183, 16270, 2713908, 2191⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s447 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle50)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap50 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd50 a ha)) PRE_first_tail_x15_r0_body.zjc50

end Host.Load.Run.Tpl

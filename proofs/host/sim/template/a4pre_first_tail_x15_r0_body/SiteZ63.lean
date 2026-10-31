import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS63
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK63
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF63
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 63 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s620`, the merged
state `PRE_first_tail_x15_r0_body.s621`, the canonical state `PRE_first_tail_x15_r0_body.s622`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl63 : PRE_first_tail_x15_r0_body.pl63.all (Nat.ble PRE_first_tail_x15_r0_body.s620.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd63 : nodupT PRE_first_tail_x15_r0_body.pl63 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn163 : Nat.ble PRE_first_tail_x15_r0_body.s620.next 2725958 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst63 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s620.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn63 : PRE_first_tail_x15_r0_body.s622.next = PRE_first_tail_x15_r0_body.s620.next + PRE_first_tail_x15_r0_body.pl63.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn63 : PRE_first_tail_x15_r0_body.s621.next = 2725958
kernel_rfl PRE_first_tail_x15_r0_body.zgrow63 : Nat.ble PRE_first_tail_x15_r0_body.s622.next PRE_first_tail_x15_r0_body.s621.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh63 : PRE_first_tail_x15_r0_body.S620.tab.all (fun e => PRE_first_tail_x15_r0_body.cws63.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd63 : nodupT PRE_first_tail_x15_r0_body.cws63 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi63 : PRE_first_tail_x15_r0_body.nr63.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S621.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt63 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s620.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg63_2665 : PRE_first_tail_x15_r0_body.s622.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s622 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk63_2665 : (objOf PRE_first_tail_x15_r0_body.s622 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm63_2665 : PRE_first_tail_x15_r0_body.s621.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa63.obj (objOf PRE_first_tail_x15_r0_body.s622 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s621 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg63_2673467 : PRE_first_tail_x15_r0_body.s622.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s622 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk63_2673467 : (objOf PRE_first_tail_x15_r0_body.s622 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm63_2673467 : PRE_first_tail_x15_r0_body.s621.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa63.obj (objOf PRE_first_tail_x15_r0_body.s622 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s621 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw63_4910 : (PRE_first_tail_x15_r0_body.s622.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw63_2673472 : (PRE_first_tail_x15_r0_body.s622.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw63_2673473 : (PRE_first_tail_x15_r0_body.s622.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd63 : PRE_first_tail_x15_r0_body.cl63.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr63 : PRE_first_tail_x15_r0_body.st63.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s620.next || PRE_first_tail_x15_r0_body.cl63.contains b) = true
def PRE_first_tail_x15_r0_body.zl63 : List Nat := PRE_first_tail_x15_r0_body.cl63.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE63 : PRE_first_tail_x15_r0_body.zl63.map (fun a => PRE_first_tail_x15_r0_body.s621.heap.get (PRE_first_tail_x15_r0_body.kappa63.a a)) = PRE_first_tail_x15_r0_body.zl63.map (fun a => (PRE_first_tail_x15_r0_body.s622.heap.get a).map PRE_first_tail_x15_r0_body.kappa63.hobj)
theorem PRE_first_tail_x15_r0_body.zimg63 : HeapImg PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.s622 PRE_first_tail_x15_r0_body.s621 PRE_first_tail_x15_r0_body.zl63 := PRE_first_tail_x15_r0_body.zimgE63
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl63 : PRE_first_tail_x15_r0_body.s621.ctl = PRE_first_tail_x15_r0_body.kappa63.ctl PRE_first_tail_x15_r0_body.s622.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack63 : PRE_first_tail_x15_r0_body.s621.stack = PRE_first_tail_x15_r0_body.s622.stack.map PRE_first_tail_x15_r0_body.kappa63.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs63 : PRE_first_tail_x15_r0_body.s621.jobs = PRE_first_tail_x15_r0_body.s622.jobs.map PRE_first_tail_x15_r0_body.kappa63.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores63 : PRE_first_tail_x15_r0_body.s621.stores = PRE_first_tail_x15_r0_body.kappa63.stores PRE_first_tail_x15_r0_body.s622.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots63 : checkRootsSupp PRE_first_tail_x15_r0_body.s622 2795 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC63 : PRE_first_tail_x15_r0_body.S620.tab.length + PRE_first_tail_x15_r0_body.cws63.length = 2795
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap63 : PRE_first_tail_x15_r0_body.kappa63 = Conv.Map.compact PRE_first_tail_x15_r0_body.s620.next 2725958 PRE_first_tail_x15_r0_body.S620.tab.length PRE_first_tail_x15_r0_body.pl63 (PRE_first_tail_x15_r0_body.nr63.map NumV.ref) PRE_first_tail_x15_r0_body.kd63.big
  PRE_first_tail_x15_r0_body.kd63.region PRE_first_tail_x15_r0_body.kd63.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin63 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s622.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc63 : Conv.jcleanListB (⟨19456, 16553, 2724809, 2795⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s622 PRE_first_tail_x15_r0_body.cl63 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB63 : noBigRootsP (fun i => !Conv.oldBigB (⟨19456, 16553, 2724809, 2795⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s622.trace PRE_first_tail_x15_r0_body.s622 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm63 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16526 = true
theorem PRE_first_tail_x15_r0_body.cjcl63 (h : Conv.JClean (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s620) : Conv.JClean (⟨19456, 16553, 2724809, 2795⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s622 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle63)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap63 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd63 a ha)) PRE_first_tail_x15_r0_body.zjc63

end Host.Load.Run.Tpl

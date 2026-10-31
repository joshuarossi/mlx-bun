import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS5
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK5
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF5
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 5 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s52`, the merged
state `PRE_first_tail_x15_r0_body.s53`, the canonical state `PRE_first_tail_x15_r0_body.s54`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl5 : PRE_first_tail_x15_r0_body.pl5.all (Nat.ble PRE_first_tail_x15_r0_body.s52.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd5 : nodupT PRE_first_tail_x15_r0_body.pl5 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn15 : Nat.ble PRE_first_tail_x15_r0_body.s52.next 2678418 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst5 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s52.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn5 : PRE_first_tail_x15_r0_body.s54.next = PRE_first_tail_x15_r0_body.s52.next + PRE_first_tail_x15_r0_body.pl5.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn5 : PRE_first_tail_x15_r0_body.s53.next = 2678418
kernel_rfl PRE_first_tail_x15_r0_body.zgrow5 : Nat.ble PRE_first_tail_x15_r0_body.s54.next PRE_first_tail_x15_r0_body.s53.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh5 : PRE_first_tail_x15_r0_body.S52.tab.all (fun e => PRE_first_tail_x15_r0_body.cws5.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd5 : nodupT PRE_first_tail_x15_r0_body.cws5 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi5 : PRE_first_tail_x15_r0_body.nr5.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S53.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt5 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s52.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg5_2665 : PRE_first_tail_x15_r0_body.s54.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s54 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk5_2665 : (objOf PRE_first_tail_x15_r0_body.s54 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm5_2665 : PRE_first_tail_x15_r0_body.s53.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa5.obj (objOf PRE_first_tail_x15_r0_body.s54 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s53 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg5_2673467 : PRE_first_tail_x15_r0_body.s54.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s54 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk5_2673467 : (objOf PRE_first_tail_x15_r0_body.s54 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm5_2673467 : PRE_first_tail_x15_r0_body.s53.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa5.obj (objOf PRE_first_tail_x15_r0_body.s54 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s53 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw5_4910 : (PRE_first_tail_x15_r0_body.s54.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw5_2673472 : (PRE_first_tail_x15_r0_body.s54.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw5_2673473 : (PRE_first_tail_x15_r0_body.s54.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd5 : PRE_first_tail_x15_r0_body.cl5.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr5 : PRE_first_tail_x15_r0_body.st5.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s52.next || PRE_first_tail_x15_r0_body.cl5.contains b) = true
def PRE_first_tail_x15_r0_body.zl5 : List Nat := PRE_first_tail_x15_r0_body.cl5.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE5 : PRE_first_tail_x15_r0_body.zl5.map (fun a => PRE_first_tail_x15_r0_body.s53.heap.get (PRE_first_tail_x15_r0_body.kappa5.a a)) = PRE_first_tail_x15_r0_body.zl5.map (fun a => (PRE_first_tail_x15_r0_body.s54.heap.get a).map PRE_first_tail_x15_r0_body.kappa5.hobj)
theorem PRE_first_tail_x15_r0_body.zimg5 : HeapImg PRE_first_tail_x15_r0_body.kappa5 PRE_first_tail_x15_r0_body.s54 PRE_first_tail_x15_r0_body.s53 PRE_first_tail_x15_r0_body.zl5 := PRE_first_tail_x15_r0_body.zimgE5
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl5 : PRE_first_tail_x15_r0_body.s53.ctl = PRE_first_tail_x15_r0_body.kappa5.ctl PRE_first_tail_x15_r0_body.s54.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack5 : PRE_first_tail_x15_r0_body.s53.stack = PRE_first_tail_x15_r0_body.s54.stack.map PRE_first_tail_x15_r0_body.kappa5.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs5 : PRE_first_tail_x15_r0_body.s53.jobs = PRE_first_tail_x15_r0_body.s54.jobs.map PRE_first_tail_x15_r0_body.kappa5.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores5 : PRE_first_tail_x15_r0_body.s53.stores = PRE_first_tail_x15_r0_body.kappa5.stores PRE_first_tail_x15_r0_body.s54.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots5 : checkRootsSupp PRE_first_tail_x15_r0_body.s54 268 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC5 : PRE_first_tail_x15_r0_body.S52.tab.length + PRE_first_tail_x15_r0_body.cws5.length = 268
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap5 : PRE_first_tail_x15_r0_body.kappa5 = Conv.Map.compact PRE_first_tail_x15_r0_body.s52.next 2678418 PRE_first_tail_x15_r0_body.S52.tab.length PRE_first_tail_x15_r0_body.pl5 (PRE_first_tail_x15_r0_body.nr5.map NumV.ref) PRE_first_tail_x15_r0_body.kd5.big
  PRE_first_tail_x15_r0_body.kd5.region PRE_first_tail_x15_r0_body.kd5.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin5 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s54.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc5 : Conv.jcleanListB (⟨18293, 15385, 2678408, 268⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s54 PRE_first_tail_x15_r0_body.cl5 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots25 : noBigRootsP (fun i => !Conv.oldBigB (⟨18293, 15385, 2678408, 268⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s54.trace PRE_first_tail_x15_r0_body.s54 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm5 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15385 = true
theorem PRE_first_tail_x15_r0_body.cjcl5 (h : Conv.JClean (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s52) : Conv.JClean (⟨18293, 15385, 2678408, 268⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s54 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle5)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap5 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd5 a ha)) PRE_first_tail_x15_r0_body.zjc5

end Host.Load.Run.Tpl

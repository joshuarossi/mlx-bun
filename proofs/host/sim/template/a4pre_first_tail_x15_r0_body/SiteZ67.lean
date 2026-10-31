import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS67
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK67
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF67
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 67 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s600`, the merged
state `PRE_first_tail_x15_r0_body.s601`, the canonical state `PRE_first_tail_x15_r0_body.s602`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl67 : PRE_first_tail_x15_r0_body.pl67.all (Nat.ble PRE_first_tail_x15_r0_body.s600.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd67 : nodupT PRE_first_tail_x15_r0_body.pl67 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn167 : Nat.ble PRE_first_tail_x15_r0_body.s600.next 2727557 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst67 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s600.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn67 : PRE_first_tail_x15_r0_body.s602.next = PRE_first_tail_x15_r0_body.s600.next + PRE_first_tail_x15_r0_body.pl67.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn67 : PRE_first_tail_x15_r0_body.s601.next = 2727557
kernel_rfl PRE_first_tail_x15_r0_body.zgrow67 : Nat.ble PRE_first_tail_x15_r0_body.s602.next PRE_first_tail_x15_r0_body.s601.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh67 : PRE_first_tail_x15_r0_body.S600.tab.all (fun e => PRE_first_tail_x15_r0_body.cws67.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd67 : nodupT PRE_first_tail_x15_r0_body.cws67 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi67 : PRE_first_tail_x15_r0_body.nr67.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S601.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt67 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s600.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg67_2665 : PRE_first_tail_x15_r0_body.s602.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s602 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk67_2665 : (objOf PRE_first_tail_x15_r0_body.s602 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm67_2665 : PRE_first_tail_x15_r0_body.s601.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa67.obj (objOf PRE_first_tail_x15_r0_body.s602 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s601 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg67_2673467 : PRE_first_tail_x15_r0_body.s602.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s602 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk67_2673467 : (objOf PRE_first_tail_x15_r0_body.s602 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm67_2673467 : PRE_first_tail_x15_r0_body.s601.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa67.obj (objOf PRE_first_tail_x15_r0_body.s602 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s601 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw67_4910 : (PRE_first_tail_x15_r0_body.s602.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw67_2673472 : (PRE_first_tail_x15_r0_body.s602.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw67_2673473 : (PRE_first_tail_x15_r0_body.s602.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd67 : PRE_first_tail_x15_r0_body.cl67.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr67 : PRE_first_tail_x15_r0_body.st67.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s600.next || PRE_first_tail_x15_r0_body.cl67.contains b) = true
def PRE_first_tail_x15_r0_body.zl67 : List Nat := PRE_first_tail_x15_r0_body.cl67.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE67 : PRE_first_tail_x15_r0_body.zl67.map (fun a => PRE_first_tail_x15_r0_body.s601.heap.get (PRE_first_tail_x15_r0_body.kappa67.a a)) = PRE_first_tail_x15_r0_body.zl67.map (fun a => (PRE_first_tail_x15_r0_body.s602.heap.get a).map PRE_first_tail_x15_r0_body.kappa67.hobj)
theorem PRE_first_tail_x15_r0_body.zimg67 : HeapImg PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.s602 PRE_first_tail_x15_r0_body.s601 PRE_first_tail_x15_r0_body.zl67 := PRE_first_tail_x15_r0_body.zimgE67
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl67 : PRE_first_tail_x15_r0_body.s601.ctl = PRE_first_tail_x15_r0_body.kappa67.ctl PRE_first_tail_x15_r0_body.s602.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack67 : PRE_first_tail_x15_r0_body.s601.stack = PRE_first_tail_x15_r0_body.s602.stack.map PRE_first_tail_x15_r0_body.kappa67.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs67 : PRE_first_tail_x15_r0_body.s601.jobs = PRE_first_tail_x15_r0_body.s602.jobs.map PRE_first_tail_x15_r0_body.kappa67.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores67 : PRE_first_tail_x15_r0_body.s601.stores = PRE_first_tail_x15_r0_body.kappa67.stores PRE_first_tail_x15_r0_body.s602.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots67 : checkRootsSupp PRE_first_tail_x15_r0_body.s602 2945 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC67 : PRE_first_tail_x15_r0_body.S600.tab.length + PRE_first_tail_x15_r0_body.cws67.length = 2945
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap67 : PRE_first_tail_x15_r0_body.kappa67 = Conv.Map.compact PRE_first_tail_x15_r0_body.s600.next 2727557 PRE_first_tail_x15_r0_body.S600.tab.length PRE_first_tail_x15_r0_body.pl67 (PRE_first_tail_x15_r0_body.nr67.map NumV.ref) PRE_first_tail_x15_r0_body.kd67.big
  PRE_first_tail_x15_r0_body.kd67.region PRE_first_tail_x15_r0_body.kd67.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin67 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s602.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc67 : Conv.jcleanListB (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s602 PRE_first_tail_x15_r0_body.cl67 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots267 : noBigRootsP (fun i => !Conv.oldBigB (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s602.trace PRE_first_tail_x15_r0_body.s602 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm67 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16629 = true
theorem PRE_first_tail_x15_r0_body.cjcl67 (h : Conv.JClean (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s600) : Conv.JClean (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s602 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle67)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap67 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd67 a ha)) PRE_first_tail_x15_r0_body.zjc67

end Host.Load.Run.Tpl

import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS169
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK169
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF169
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 169 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1491`, the merged
state `PRE_first_tail_x15_r0_body.s1492`, the canonical state `PRE_first_tail_x15_r0_body.s1493`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl169 : PRE_first_tail_x15_r0_body.pl169.all (Nat.ble PRE_first_tail_x15_r0_body.s1491.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd169 : nodupT PRE_first_tail_x15_r0_body.pl169 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1169 : Nat.ble PRE_first_tail_x15_r0_body.s1491.next 2807797 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst169 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1491.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn169 : PRE_first_tail_x15_r0_body.s1493.next = PRE_first_tail_x15_r0_body.s1491.next + PRE_first_tail_x15_r0_body.pl169.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn169 : PRE_first_tail_x15_r0_body.s1492.next = 2807797
kernel_rfl PRE_first_tail_x15_r0_body.zgrow169 : Nat.ble PRE_first_tail_x15_r0_body.s1493.next PRE_first_tail_x15_r0_body.s1492.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh169 : PRE_first_tail_x15_r0_body.S1491.tab.all (fun e => PRE_first_tail_x15_r0_body.cws169.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd169 : nodupT PRE_first_tail_x15_r0_body.cws169 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi169 : PRE_first_tail_x15_r0_body.nr169.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1492.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt169 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1491.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg169_2665 : PRE_first_tail_x15_r0_body.s1493.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1493 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk169_2665 : (objOf PRE_first_tail_x15_r0_body.s1493 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm169_2665 : PRE_first_tail_x15_r0_body.s1492.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa169.obj (objOf PRE_first_tail_x15_r0_body.s1493 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1492 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg169_2673467 : PRE_first_tail_x15_r0_body.s1493.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1493 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk169_2673467 : (objOf PRE_first_tail_x15_r0_body.s1493 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm169_2673467 : PRE_first_tail_x15_r0_body.s1492.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa169.obj (objOf PRE_first_tail_x15_r0_body.s1493 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1492 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw169_4910 : (PRE_first_tail_x15_r0_body.s1493.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw169_2673472 : (PRE_first_tail_x15_r0_body.s1493.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw169_2673473 : (PRE_first_tail_x15_r0_body.s1493.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd169 : PRE_first_tail_x15_r0_body.cl169.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr169 : PRE_first_tail_x15_r0_body.st169.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1491.next || PRE_first_tail_x15_r0_body.cl169.contains b) = true
def PRE_first_tail_x15_r0_body.zl169 : List Nat := PRE_first_tail_x15_r0_body.cl169.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE169 : PRE_first_tail_x15_r0_body.zl169.map (fun a => PRE_first_tail_x15_r0_body.s1492.heap.get (PRE_first_tail_x15_r0_body.kappa169.a a)) = PRE_first_tail_x15_r0_body.zl169.map (fun a => (PRE_first_tail_x15_r0_body.s1493.heap.get a).map PRE_first_tail_x15_r0_body.kappa169.hobj)
theorem PRE_first_tail_x15_r0_body.zimg169 : HeapImg PRE_first_tail_x15_r0_body.kappa169 PRE_first_tail_x15_r0_body.s1493 PRE_first_tail_x15_r0_body.s1492 PRE_first_tail_x15_r0_body.zl169 := PRE_first_tail_x15_r0_body.zimgE169
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl169 : PRE_first_tail_x15_r0_body.s1492.ctl = PRE_first_tail_x15_r0_body.kappa169.ctl PRE_first_tail_x15_r0_body.s1493.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack169 : PRE_first_tail_x15_r0_body.s1492.stack = PRE_first_tail_x15_r0_body.s1493.stack.map PRE_first_tail_x15_r0_body.kappa169.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs169 : PRE_first_tail_x15_r0_body.s1492.jobs = PRE_first_tail_x15_r0_body.s1493.jobs.map PRE_first_tail_x15_r0_body.kappa169.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores169 : PRE_first_tail_x15_r0_body.s1492.stores = PRE_first_tail_x15_r0_body.kappa169.stores PRE_first_tail_x15_r0_body.s1493.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots169 : checkRootsSupp PRE_first_tail_x15_r0_body.s1493 7304 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC169 : PRE_first_tail_x15_r0_body.S1491.tab.length + PRE_first_tail_x15_r0_body.cws169.length = 7304
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap169 : PRE_first_tail_x15_r0_body.kappa169 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1491.next 2807797 PRE_first_tail_x15_r0_body.S1491.tab.length PRE_first_tail_x15_r0_body.pl169 (PRE_first_tail_x15_r0_body.nr169.map NumV.ref) PRE_first_tail_x15_r0_body.kd169.big
  PRE_first_tail_x15_r0_body.kd169.region PRE_first_tail_x15_r0_body.kd169.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin169 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1493.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc169 : Conv.jcleanListB (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1493 PRE_first_tail_x15_r0_body.cl169 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2169 : noBigRootsP (fun i => !Conv.oldBigB (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1493.trace PRE_first_tail_x15_r0_body.s1493 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm169 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18636 = true
theorem PRE_first_tail_x15_r0_body.cjcl169 (h : Conv.JClean (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1491) : Conv.JClean (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1493 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle169)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap169 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd169 a ha)) PRE_first_tail_x15_r0_body.zjc169

end Host.Load.Run.Tpl

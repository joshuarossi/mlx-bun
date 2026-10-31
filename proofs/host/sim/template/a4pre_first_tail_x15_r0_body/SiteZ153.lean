import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS153
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK153
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF153
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 153 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1352`, the merged
state `PRE_first_tail_x15_r0_body.s1353`, the canonical state `PRE_first_tail_x15_r0_body.s1354`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl153 : PRE_first_tail_x15_r0_body.pl153.all (Nat.ble PRE_first_tail_x15_r0_body.s1352.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd153 : nodupT PRE_first_tail_x15_r0_body.pl153 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1153 : Nat.ble PRE_first_tail_x15_r0_body.s1352.next 2795865 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst153 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1352.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn153 : PRE_first_tail_x15_r0_body.s1354.next = PRE_first_tail_x15_r0_body.s1352.next + PRE_first_tail_x15_r0_body.pl153.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn153 : PRE_first_tail_x15_r0_body.s1353.next = 2795865
kernel_rfl PRE_first_tail_x15_r0_body.zgrow153 : Nat.ble PRE_first_tail_x15_r0_body.s1354.next PRE_first_tail_x15_r0_body.s1353.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh153 : PRE_first_tail_x15_r0_body.S1352.tab.all (fun e => PRE_first_tail_x15_r0_body.cws153.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd153 : nodupT PRE_first_tail_x15_r0_body.cws153 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi153 : PRE_first_tail_x15_r0_body.nr153.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1353.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt153 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1352.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg153_2665 : PRE_first_tail_x15_r0_body.s1354.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1354 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk153_2665 : (objOf PRE_first_tail_x15_r0_body.s1354 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm153_2665 : PRE_first_tail_x15_r0_body.s1353.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa153.obj (objOf PRE_first_tail_x15_r0_body.s1354 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1353 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg153_2673467 : PRE_first_tail_x15_r0_body.s1354.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1354 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk153_2673467 : (objOf PRE_first_tail_x15_r0_body.s1354 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm153_2673467 : PRE_first_tail_x15_r0_body.s1353.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa153.obj (objOf PRE_first_tail_x15_r0_body.s1354 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1353 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw153_4910 : (PRE_first_tail_x15_r0_body.s1354.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw153_2673472 : (PRE_first_tail_x15_r0_body.s1354.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw153_2673473 : (PRE_first_tail_x15_r0_body.s1354.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd153 : PRE_first_tail_x15_r0_body.cl153.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr153 : PRE_first_tail_x15_r0_body.st153.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1352.next || PRE_first_tail_x15_r0_body.cl153.contains b) = true
def PRE_first_tail_x15_r0_body.zl153 : List Nat := PRE_first_tail_x15_r0_body.cl153.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE153 : PRE_first_tail_x15_r0_body.zl153.map (fun a => PRE_first_tail_x15_r0_body.s1353.heap.get (PRE_first_tail_x15_r0_body.kappa153.a a)) = PRE_first_tail_x15_r0_body.zl153.map (fun a => (PRE_first_tail_x15_r0_body.s1354.heap.get a).map PRE_first_tail_x15_r0_body.kappa153.hobj)
theorem PRE_first_tail_x15_r0_body.zimg153 : HeapImg PRE_first_tail_x15_r0_body.kappa153 PRE_first_tail_x15_r0_body.s1354 PRE_first_tail_x15_r0_body.s1353 PRE_first_tail_x15_r0_body.zl153 := PRE_first_tail_x15_r0_body.zimgE153
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl153 : PRE_first_tail_x15_r0_body.s1353.ctl = PRE_first_tail_x15_r0_body.kappa153.ctl PRE_first_tail_x15_r0_body.s1354.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack153 : PRE_first_tail_x15_r0_body.s1353.stack = PRE_first_tail_x15_r0_body.s1354.stack.map PRE_first_tail_x15_r0_body.kappa153.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs153 : PRE_first_tail_x15_r0_body.s1353.jobs = PRE_first_tail_x15_r0_body.s1354.jobs.map PRE_first_tail_x15_r0_body.kappa153.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores153 : PRE_first_tail_x15_r0_body.s1353.stores = PRE_first_tail_x15_r0_body.kappa153.stores PRE_first_tail_x15_r0_body.s1354.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots153 : checkRootsSupp PRE_first_tail_x15_r0_body.s1354 6639 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC153 : PRE_first_tail_x15_r0_body.S1352.tab.length + PRE_first_tail_x15_r0_body.cws153.length = 6639
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap153 : PRE_first_tail_x15_r0_body.kappa153 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1352.next 2795865 PRE_first_tail_x15_r0_body.S1352.tab.length PRE_first_tail_x15_r0_body.pl153 (PRE_first_tail_x15_r0_body.nr153.map NumV.ref) PRE_first_tail_x15_r0_body.kd153.big
  PRE_first_tail_x15_r0_body.kd153.region PRE_first_tail_x15_r0_body.kd153.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin153 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1354.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc153 : Conv.jcleanListB (⟨21229, 18326, 2795515, 6639⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1354 PRE_first_tail_x15_r0_body.cl153 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2153 : noBigRootsP (fun i => !Conv.oldBigB (⟨21229, 18326, 2795515, 6639⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1354.trace PRE_first_tail_x15_r0_body.s1354 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm153 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18320 = true
theorem PRE_first_tail_x15_r0_body.cjcl153 (h : Conv.JClean (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1352) : Conv.JClean (⟨21229, 18326, 2795515, 6639⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1354 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle153)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap153 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd153 a ha)) PRE_first_tail_x15_r0_body.zjc153

end Host.Load.Run.Tpl

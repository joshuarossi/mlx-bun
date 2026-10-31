import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS143
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK143
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF143
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 143 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1379`, the merged
state `PRE_first_tail_x15_r0_body.s1380`, the canonical state `PRE_first_tail_x15_r0_body.s1381`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl143 : PRE_first_tail_x15_r0_body.pl143.all (Nat.ble PRE_first_tail_x15_r0_body.s1379.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd143 : nodupT PRE_first_tail_x15_r0_body.pl143 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1143 : Nat.ble PRE_first_tail_x15_r0_body.s1379.next 2786981 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst143 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1379.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn143 : PRE_first_tail_x15_r0_body.s1381.next = PRE_first_tail_x15_r0_body.s1379.next + PRE_first_tail_x15_r0_body.pl143.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn143 : PRE_first_tail_x15_r0_body.s1380.next = 2786981
kernel_rfl PRE_first_tail_x15_r0_body.zgrow143 : Nat.ble PRE_first_tail_x15_r0_body.s1381.next PRE_first_tail_x15_r0_body.s1380.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh143 : PRE_first_tail_x15_r0_body.S1379.tab.all (fun e => PRE_first_tail_x15_r0_body.cws143.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd143 : nodupT PRE_first_tail_x15_r0_body.cws143 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi143 : PRE_first_tail_x15_r0_body.nr143.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1380.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt143 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1379.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg143_2665 : PRE_first_tail_x15_r0_body.s1381.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1381 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk143_2665 : (objOf PRE_first_tail_x15_r0_body.s1381 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm143_2665 : PRE_first_tail_x15_r0_body.s1380.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa143.obj (objOf PRE_first_tail_x15_r0_body.s1381 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1380 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg143_2673467 : PRE_first_tail_x15_r0_body.s1381.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1381 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk143_2673467 : (objOf PRE_first_tail_x15_r0_body.s1381 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm143_2673467 : PRE_first_tail_x15_r0_body.s1380.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa143.obj (objOf PRE_first_tail_x15_r0_body.s1381 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1380 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw143_4910 : (PRE_first_tail_x15_r0_body.s1381.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw143_2673472 : (PRE_first_tail_x15_r0_body.s1381.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw143_2673473 : (PRE_first_tail_x15_r0_body.s1381.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd143 : PRE_first_tail_x15_r0_body.cl143.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr143 : PRE_first_tail_x15_r0_body.st143.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1379.next || PRE_first_tail_x15_r0_body.cl143.contains b) = true
def PRE_first_tail_x15_r0_body.zl143 : List Nat := PRE_first_tail_x15_r0_body.cl143.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE143 : PRE_first_tail_x15_r0_body.zl143.map (fun a => PRE_first_tail_x15_r0_body.s1380.heap.get (PRE_first_tail_x15_r0_body.kappa143.a a)) = PRE_first_tail_x15_r0_body.zl143.map (fun a => (PRE_first_tail_x15_r0_body.s1381.heap.get a).map PRE_first_tail_x15_r0_body.kappa143.hobj)
theorem PRE_first_tail_x15_r0_body.zimg143 : HeapImg PRE_first_tail_x15_r0_body.kappa143 PRE_first_tail_x15_r0_body.s1381 PRE_first_tail_x15_r0_body.s1380 PRE_first_tail_x15_r0_body.zl143 := PRE_first_tail_x15_r0_body.zimgE143
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl143 : PRE_first_tail_x15_r0_body.s1380.ctl = PRE_first_tail_x15_r0_body.kappa143.ctl PRE_first_tail_x15_r0_body.s1381.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack143 : PRE_first_tail_x15_r0_body.s1380.stack = PRE_first_tail_x15_r0_body.s1381.stack.map PRE_first_tail_x15_r0_body.kappa143.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs143 : PRE_first_tail_x15_r0_body.s1380.jobs = PRE_first_tail_x15_r0_body.s1381.jobs.map PRE_first_tail_x15_r0_body.kappa143.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores143 : PRE_first_tail_x15_r0_body.s1380.stores = PRE_first_tail_x15_r0_body.kappa143.stores PRE_first_tail_x15_r0_body.s1381.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots143 : checkRootsSupp PRE_first_tail_x15_r0_body.s1381 6166 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC143 : PRE_first_tail_x15_r0_body.S1379.tab.length + PRE_first_tail_x15_r0_body.cws143.length = 6166
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap143 : PRE_first_tail_x15_r0_body.kappa143 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1379.next 2786981 PRE_first_tail_x15_r0_body.S1379.tab.length PRE_first_tail_x15_r0_body.pl143 (PRE_first_tail_x15_r0_body.nr143.map NumV.ref) PRE_first_tail_x15_r0_body.kd143.big
  PRE_first_tail_x15_r0_body.kd143.region PRE_first_tail_x15_r0_body.kd143.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin143 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1381.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc143 : Conv.jcleanListB (⟨21013, 18103, 2786962, 6166⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1381 PRE_first_tail_x15_r0_body.cl143 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB143 : noBigRootsP (fun i => !Conv.oldBigB (⟨21013, 18103, 2786962, 6166⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1381.trace PRE_first_tail_x15_r0_body.s1381 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm143 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18103 = true
theorem PRE_first_tail_x15_r0_body.cjcl143 (h : Conv.JClean (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1379) : Conv.JClean (⟨21013, 18103, 2786962, 6166⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1381 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle143)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap143 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd143 a ha)) PRE_first_tail_x15_r0_body.zjc143

end Host.Load.Run.Tpl

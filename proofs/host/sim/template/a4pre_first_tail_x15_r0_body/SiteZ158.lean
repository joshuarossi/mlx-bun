import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS158
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK158
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF158
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 158 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1523`, the merged
state `PRE_first_tail_x15_r0_body.s1524`, the canonical state `PRE_first_tail_x15_r0_body.s1525`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl158 : PRE_first_tail_x15_r0_body.pl158.all (Nat.ble PRE_first_tail_x15_r0_body.s1523.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd158 : nodupT PRE_first_tail_x15_r0_body.pl158 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1158 : Nat.ble PRE_first_tail_x15_r0_body.s1523.next 2798674 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst158 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1523.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn158 : PRE_first_tail_x15_r0_body.s1525.next = PRE_first_tail_x15_r0_body.s1523.next + PRE_first_tail_x15_r0_body.pl158.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn158 : PRE_first_tail_x15_r0_body.s1524.next = 2798674
kernel_rfl PRE_first_tail_x15_r0_body.zgrow158 : Nat.ble PRE_first_tail_x15_r0_body.s1525.next PRE_first_tail_x15_r0_body.s1524.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh158 : PRE_first_tail_x15_r0_body.S1523.tab.all (fun e => PRE_first_tail_x15_r0_body.cws158.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd158 : nodupT PRE_first_tail_x15_r0_body.cws158 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi158 : PRE_first_tail_x15_r0_body.nr158.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1524.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt158 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1523.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg158_2665 : PRE_first_tail_x15_r0_body.s1525.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1525 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk158_2665 : (objOf PRE_first_tail_x15_r0_body.s1525 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm158_2665 : PRE_first_tail_x15_r0_body.s1524.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa158.obj (objOf PRE_first_tail_x15_r0_body.s1525 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1524 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg158_2673467 : PRE_first_tail_x15_r0_body.s1525.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1525 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk158_2673467 : (objOf PRE_first_tail_x15_r0_body.s1525 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm158_2673467 : PRE_first_tail_x15_r0_body.s1524.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa158.obj (objOf PRE_first_tail_x15_r0_body.s1525 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1524 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw158_4910 : (PRE_first_tail_x15_r0_body.s1525.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw158_2673472 : (PRE_first_tail_x15_r0_body.s1525.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw158_2673473 : (PRE_first_tail_x15_r0_body.s1525.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd158 : PRE_first_tail_x15_r0_body.cl158.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr158 : PRE_first_tail_x15_r0_body.st158.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1523.next || PRE_first_tail_x15_r0_body.cl158.contains b) = true
def PRE_first_tail_x15_r0_body.zl158 : List Nat := PRE_first_tail_x15_r0_body.cl158.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE158 : PRE_first_tail_x15_r0_body.zl158.map (fun a => PRE_first_tail_x15_r0_body.s1524.heap.get (PRE_first_tail_x15_r0_body.kappa158.a a)) = PRE_first_tail_x15_r0_body.zl158.map (fun a => (PRE_first_tail_x15_r0_body.s1525.heap.get a).map PRE_first_tail_x15_r0_body.kappa158.hobj)
theorem PRE_first_tail_x15_r0_body.zimg158 : HeapImg PRE_first_tail_x15_r0_body.kappa158 PRE_first_tail_x15_r0_body.s1525 PRE_first_tail_x15_r0_body.s1524 PRE_first_tail_x15_r0_body.zl158 := PRE_first_tail_x15_r0_body.zimgE158
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl158 : PRE_first_tail_x15_r0_body.s1524.ctl = PRE_first_tail_x15_r0_body.kappa158.ctl PRE_first_tail_x15_r0_body.s1525.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack158 : PRE_first_tail_x15_r0_body.s1524.stack = PRE_first_tail_x15_r0_body.s1525.stack.map PRE_first_tail_x15_r0_body.kappa158.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs158 : PRE_first_tail_x15_r0_body.s1524.jobs = PRE_first_tail_x15_r0_body.s1525.jobs.map PRE_first_tail_x15_r0_body.kappa158.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores158 : PRE_first_tail_x15_r0_body.s1524.stores = PRE_first_tail_x15_r0_body.kappa158.stores PRE_first_tail_x15_r0_body.s1525.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots158 : checkRootsSupp PRE_first_tail_x15_r0_body.s1525 6808 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC158 : PRE_first_tail_x15_r0_body.S1523.tab.length + PRE_first_tail_x15_r0_body.cws158.length = 6808
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap158 : PRE_first_tail_x15_r0_body.kappa158 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1523.next 2798674 PRE_first_tail_x15_r0_body.S1523.tab.length PRE_first_tail_x15_r0_body.pl158 (PRE_first_tail_x15_r0_body.nr158.map NumV.ref) PRE_first_tail_x15_r0_body.kd158.big
  PRE_first_tail_x15_r0_body.kd158.region PRE_first_tail_x15_r0_body.kd158.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin158 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1525.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc158 : Conv.jcleanListB (⟨21307, 18403, 2798664, 6808⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1525 PRE_first_tail_x15_r0_body.cl158 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB158 : noBigRootsP (fun i => !Conv.oldBigB (⟨21307, 18403, 2798664, 6808⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1525.trace PRE_first_tail_x15_r0_body.s1525 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm158 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18403 = true
theorem PRE_first_tail_x15_r0_body.cjcl158 (h : Conv.JClean (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1523) : Conv.JClean (⟨21307, 18403, 2798664, 6808⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1525 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle158)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap158 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd158 a ha)) PRE_first_tail_x15_r0_body.zjc158

end Host.Load.Run.Tpl

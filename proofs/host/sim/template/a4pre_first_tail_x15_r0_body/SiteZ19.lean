import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS19
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK19
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF19
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 19 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s180`, the merged
state `PRE_first_tail_x15_r0_body.s181`, the canonical state `PRE_first_tail_x15_r0_body.s182`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl19 : PRE_first_tail_x15_r0_body.pl19.all (Nat.ble PRE_first_tail_x15_r0_body.s180.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd19 : nodupT PRE_first_tail_x15_r0_body.pl19 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn119 : Nat.ble PRE_first_tail_x15_r0_body.s180.next 2689885 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst19 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s180.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn19 : PRE_first_tail_x15_r0_body.s182.next = PRE_first_tail_x15_r0_body.s180.next + PRE_first_tail_x15_r0_body.pl19.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn19 : PRE_first_tail_x15_r0_body.s181.next = 2689885
kernel_rfl PRE_first_tail_x15_r0_body.zgrow19 : Nat.ble PRE_first_tail_x15_r0_body.s182.next PRE_first_tail_x15_r0_body.s181.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh19 : PRE_first_tail_x15_r0_body.S180.tab.all (fun e => PRE_first_tail_x15_r0_body.cws19.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd19 : nodupT PRE_first_tail_x15_r0_body.cws19 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi19 : PRE_first_tail_x15_r0_body.nr19.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S181.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt19 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s180.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg19_2665 : PRE_first_tail_x15_r0_body.s182.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s182 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk19_2665 : (objOf PRE_first_tail_x15_r0_body.s182 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm19_2665 : PRE_first_tail_x15_r0_body.s181.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa19.obj (objOf PRE_first_tail_x15_r0_body.s182 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s181 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg19_2673467 : PRE_first_tail_x15_r0_body.s182.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s182 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk19_2673467 : (objOf PRE_first_tail_x15_r0_body.s182 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm19_2673467 : PRE_first_tail_x15_r0_body.s181.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa19.obj (objOf PRE_first_tail_x15_r0_body.s182 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s181 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw19_4910 : (PRE_first_tail_x15_r0_body.s182.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw19_2673472 : (PRE_first_tail_x15_r0_body.s182.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw19_2673473 : (PRE_first_tail_x15_r0_body.s182.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd19 : PRE_first_tail_x15_r0_body.cl19.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr19 : PRE_first_tail_x15_r0_body.st19.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s180.next || PRE_first_tail_x15_r0_body.cl19.contains b) = true
def PRE_first_tail_x15_r0_body.zl19 : List Nat := PRE_first_tail_x15_r0_body.cl19.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE19 : PRE_first_tail_x15_r0_body.zl19.map (fun a => PRE_first_tail_x15_r0_body.s181.heap.get (PRE_first_tail_x15_r0_body.kappa19.a a)) = PRE_first_tail_x15_r0_body.zl19.map (fun a => (PRE_first_tail_x15_r0_body.s182.heap.get a).map PRE_first_tail_x15_r0_body.kappa19.hobj)
theorem PRE_first_tail_x15_r0_body.zimg19 : HeapImg PRE_first_tail_x15_r0_body.kappa19 PRE_first_tail_x15_r0_body.s182 PRE_first_tail_x15_r0_body.s181 PRE_first_tail_x15_r0_body.zl19 := PRE_first_tail_x15_r0_body.zimgE19
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl19 : PRE_first_tail_x15_r0_body.s181.ctl = PRE_first_tail_x15_r0_body.kappa19.ctl PRE_first_tail_x15_r0_body.s182.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack19 : PRE_first_tail_x15_r0_body.s181.stack = PRE_first_tail_x15_r0_body.s182.stack.map PRE_first_tail_x15_r0_body.kappa19.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs19 : PRE_first_tail_x15_r0_body.s181.jobs = PRE_first_tail_x15_r0_body.s182.jobs.map PRE_first_tail_x15_r0_body.kappa19.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores19 : PRE_first_tail_x15_r0_body.s181.stores = PRE_first_tail_x15_r0_body.kappa19.stores PRE_first_tail_x15_r0_body.s182.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots19 : checkRootsSupp PRE_first_tail_x15_r0_body.s182 893 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC19 : PRE_first_tail_x15_r0_body.S180.tab.length + PRE_first_tail_x15_r0_body.cws19.length = 893
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap19 : PRE_first_tail_x15_r0_body.kappa19 = Conv.Map.compact PRE_first_tail_x15_r0_body.s180.next 2689885 PRE_first_tail_x15_r0_body.S180.tab.length PRE_first_tail_x15_r0_body.pl19 (PRE_first_tail_x15_r0_body.nr19.map NumV.ref) PRE_first_tail_x15_r0_body.kd19.big
  PRE_first_tail_x15_r0_body.kd19.region PRE_first_tail_x15_r0_body.kd19.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin19 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s182.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc19 : Conv.jcleanListB (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s182 PRE_first_tail_x15_r0_body.cl19 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots219 : noBigRootsP (fun i => !Conv.oldBigB (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s182.trace PRE_first_tail_x15_r0_body.s182 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm19 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15681 = true
theorem PRE_first_tail_x15_r0_body.cjcl19 (h : Conv.JClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s180) : Conv.JClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s182 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle19)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap19 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd19 a ha)) PRE_first_tail_x15_r0_body.zjc19

end Host.Load.Run.Tpl

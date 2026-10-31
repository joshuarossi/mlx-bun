import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS91
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK91
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF91
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 91 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s810`, the merged
state `PRE_first_tail_x15_r0_body.s811`, the canonical state `PRE_first_tail_x15_r0_body.s812`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl91 : PRE_first_tail_x15_r0_body.pl91.all (Nat.ble PRE_first_tail_x15_r0_body.s810.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd91 : nodupT PRE_first_tail_x15_r0_body.pl91 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn191 : Nat.ble PRE_first_tail_x15_r0_body.s810.next 2746385 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst91 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s810.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn91 : PRE_first_tail_x15_r0_body.s812.next = PRE_first_tail_x15_r0_body.s810.next + PRE_first_tail_x15_r0_body.pl91.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn91 : PRE_first_tail_x15_r0_body.s811.next = 2746385
kernel_rfl PRE_first_tail_x15_r0_body.zgrow91 : Nat.ble PRE_first_tail_x15_r0_body.s812.next PRE_first_tail_x15_r0_body.s811.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh91 : PRE_first_tail_x15_r0_body.S810.tab.all (fun e => PRE_first_tail_x15_r0_body.cws91.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd91 : nodupT PRE_first_tail_x15_r0_body.cws91 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi91 : PRE_first_tail_x15_r0_body.nr91.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S811.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt91 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s810.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg91_2665 : PRE_first_tail_x15_r0_body.s812.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s812 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk91_2665 : (objOf PRE_first_tail_x15_r0_body.s812 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm91_2665 : PRE_first_tail_x15_r0_body.s811.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa91.obj (objOf PRE_first_tail_x15_r0_body.s812 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s811 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg91_2673467 : PRE_first_tail_x15_r0_body.s812.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s812 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk91_2673467 : (objOf PRE_first_tail_x15_r0_body.s812 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm91_2673467 : PRE_first_tail_x15_r0_body.s811.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa91.obj (objOf PRE_first_tail_x15_r0_body.s812 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s811 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw91_4910 : (PRE_first_tail_x15_r0_body.s812.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw91_2673472 : (PRE_first_tail_x15_r0_body.s812.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw91_2673473 : (PRE_first_tail_x15_r0_body.s812.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd91 : PRE_first_tail_x15_r0_body.cl91.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr91 : PRE_first_tail_x15_r0_body.st91.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s810.next || PRE_first_tail_x15_r0_body.cl91.contains b) = true
def PRE_first_tail_x15_r0_body.zl91 : List Nat := PRE_first_tail_x15_r0_body.cl91.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE91 : PRE_first_tail_x15_r0_body.zl91.map (fun a => PRE_first_tail_x15_r0_body.s811.heap.get (PRE_first_tail_x15_r0_body.kappa91.a a)) = PRE_first_tail_x15_r0_body.zl91.map (fun a => (PRE_first_tail_x15_r0_body.s812.heap.get a).map PRE_first_tail_x15_r0_body.kappa91.hobj)
theorem PRE_first_tail_x15_r0_body.zimg91 : HeapImg PRE_first_tail_x15_r0_body.kappa91 PRE_first_tail_x15_r0_body.s812 PRE_first_tail_x15_r0_body.s811 PRE_first_tail_x15_r0_body.zl91 := PRE_first_tail_x15_r0_body.zimgE91
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl91 : PRE_first_tail_x15_r0_body.s811.ctl = PRE_first_tail_x15_r0_body.kappa91.ctl PRE_first_tail_x15_r0_body.s812.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack91 : PRE_first_tail_x15_r0_body.s811.stack = PRE_first_tail_x15_r0_body.s812.stack.map PRE_first_tail_x15_r0_body.kappa91.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs91 : PRE_first_tail_x15_r0_body.s811.jobs = PRE_first_tail_x15_r0_body.s812.jobs.map PRE_first_tail_x15_r0_body.kappa91.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores91 : PRE_first_tail_x15_r0_body.s811.stores = PRE_first_tail_x15_r0_body.kappa91.stores PRE_first_tail_x15_r0_body.s812.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots91 : checkRootsSupp PRE_first_tail_x15_r0_body.s812 3971 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC91 : PRE_first_tail_x15_r0_body.S810.tab.length + PRE_first_tail_x15_r0_body.cws91.length = 3971
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap91 : PRE_first_tail_x15_r0_body.kappa91 = Conv.Map.compact PRE_first_tail_x15_r0_body.s810.next 2746385 PRE_first_tail_x15_r0_body.S810.tab.length PRE_first_tail_x15_r0_body.pl91 (PRE_first_tail_x15_r0_body.nr91.map NumV.ref) PRE_first_tail_x15_r0_body.kd91.big
  PRE_first_tail_x15_r0_body.kd91.region PRE_first_tail_x15_r0_body.kd91.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin91 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s812.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc91 : Conv.jcleanListB (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s812 PRE_first_tail_x15_r0_body.cl91 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots291 : noBigRootsP (fun i => !Conv.oldBigB (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s812.trace PRE_first_tail_x15_r0_body.s812 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm91 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17103 = true
theorem PRE_first_tail_x15_r0_body.cjcl91 (h : Conv.JClean (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s810) : Conv.JClean (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s812 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle91)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap91 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd91 a ha)) PRE_first_tail_x15_r0_body.zjc91

end Host.Load.Run.Tpl

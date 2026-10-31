import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS16
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK16
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF16
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 16 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s153`, the merged
state `PRE_first_tail_x15_r0_body.s154`, the canonical state `PRE_first_tail_x15_r0_body.s155`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl16 : PRE_first_tail_x15_r0_body.pl16.all (Nat.ble PRE_first_tail_x15_r0_body.s153.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd16 : nodupT PRE_first_tail_x15_r0_body.pl16 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn116 : Nat.ble PRE_first_tail_x15_r0_body.s153.next 2687629 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst16 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s153.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn16 : PRE_first_tail_x15_r0_body.s155.next = PRE_first_tail_x15_r0_body.s153.next + PRE_first_tail_x15_r0_body.pl16.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn16 : PRE_first_tail_x15_r0_body.s154.next = 2687629
kernel_rfl PRE_first_tail_x15_r0_body.zgrow16 : Nat.ble PRE_first_tail_x15_r0_body.s155.next PRE_first_tail_x15_r0_body.s154.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh16 : PRE_first_tail_x15_r0_body.S153.tab.all (fun e => PRE_first_tail_x15_r0_body.cws16.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd16 : nodupT PRE_first_tail_x15_r0_body.cws16 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi16 : PRE_first_tail_x15_r0_body.nr16.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S154.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt16 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s153.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg16_2665 : PRE_first_tail_x15_r0_body.s155.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s155 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk16_2665 : (objOf PRE_first_tail_x15_r0_body.s155 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm16_2665 : PRE_first_tail_x15_r0_body.s154.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa16.obj (objOf PRE_first_tail_x15_r0_body.s155 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s154 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg16_2673467 : PRE_first_tail_x15_r0_body.s155.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s155 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk16_2673467 : (objOf PRE_first_tail_x15_r0_body.s155 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm16_2673467 : PRE_first_tail_x15_r0_body.s154.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa16.obj (objOf PRE_first_tail_x15_r0_body.s155 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s154 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw16_4910 : (PRE_first_tail_x15_r0_body.s155.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw16_2673472 : (PRE_first_tail_x15_r0_body.s155.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw16_2673473 : (PRE_first_tail_x15_r0_body.s155.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd16 : PRE_first_tail_x15_r0_body.cl16.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr16 : PRE_first_tail_x15_r0_body.st16.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s153.next || PRE_first_tail_x15_r0_body.cl16.contains b) = true
def PRE_first_tail_x15_r0_body.zl16 : List Nat := PRE_first_tail_x15_r0_body.cl16.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE16 : PRE_first_tail_x15_r0_body.zl16.map (fun a => PRE_first_tail_x15_r0_body.s154.heap.get (PRE_first_tail_x15_r0_body.kappa16.a a)) = PRE_first_tail_x15_r0_body.zl16.map (fun a => (PRE_first_tail_x15_r0_body.s155.heap.get a).map PRE_first_tail_x15_r0_body.kappa16.hobj)
theorem PRE_first_tail_x15_r0_body.zimg16 : HeapImg PRE_first_tail_x15_r0_body.kappa16 PRE_first_tail_x15_r0_body.s155 PRE_first_tail_x15_r0_body.s154 PRE_first_tail_x15_r0_body.zl16 := PRE_first_tail_x15_r0_body.zimgE16
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl16 : PRE_first_tail_x15_r0_body.s154.ctl = PRE_first_tail_x15_r0_body.kappa16.ctl PRE_first_tail_x15_r0_body.s155.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack16 : PRE_first_tail_x15_r0_body.s154.stack = PRE_first_tail_x15_r0_body.s155.stack.map PRE_first_tail_x15_r0_body.kappa16.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs16 : PRE_first_tail_x15_r0_body.s154.jobs = PRE_first_tail_x15_r0_body.s155.jobs.map PRE_first_tail_x15_r0_body.kappa16.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores16 : PRE_first_tail_x15_r0_body.s154.stores = PRE_first_tail_x15_r0_body.kappa16.stores PRE_first_tail_x15_r0_body.s155.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots16 : checkRootsSupp PRE_first_tail_x15_r0_body.s155 764 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC16 : PRE_first_tail_x15_r0_body.S153.tab.length + PRE_first_tail_x15_r0_body.cws16.length = 764
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap16 : PRE_first_tail_x15_r0_body.kappa16 = Conv.Map.compact PRE_first_tail_x15_r0_body.s153.next 2687629 PRE_first_tail_x15_r0_body.S153.tab.length PRE_first_tail_x15_r0_body.pl16 (PRE_first_tail_x15_r0_body.nr16.map NumV.ref) PRE_first_tail_x15_r0_body.kd16.big
  PRE_first_tail_x15_r0_body.kd16.region PRE_first_tail_x15_r0_body.kd16.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin16 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s155.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc16 : Conv.jcleanListB (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s155 PRE_first_tail_x15_r0_body.cl16 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots216 : noBigRootsP (fun i => !Conv.oldBigB (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s155.trace PRE_first_tail_x15_r0_body.s155 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm16 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15618 = true
theorem PRE_first_tail_x15_r0_body.cjcl16 (h : Conv.JClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s153) : Conv.JClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s155 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle16)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap16 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd16 a ha)) PRE_first_tail_x15_r0_body.zjc16

end Host.Load.Run.Tpl

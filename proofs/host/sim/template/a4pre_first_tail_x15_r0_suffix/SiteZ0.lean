import host.sim.template.a4pre_first_tail_x15_r0_suffix.SiteS0
import host.sim.template.a4pre_first_tail_x15_r0_suffix.SiteK0
import host.sim.template.a4pre_first_tail_x15_r0_suffix.SiteF0
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 0 of chain `PRE_first_tail_x15_r0_suffix` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_suffix.s2`, the merged
state `PRE_first_tail_x15_r0_suffix.s3`, the canonical state `PRE_first_tail_x15_r0_suffix.s4`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_suffix.zpl0 : PRE_first_tail_x15_r0_suffix.pl0.all (Nat.ble PRE_first_tail_x15_r0_suffix.s2.next) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.zplnd0 : nodupT PRE_first_tail_x15_r0_suffix.pl0 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_suffix.zn10 : Nat.ble PRE_first_tail_x15_r0_suffix.s2.next 2828013 = true
kernel_rfl PRE_first_tail_x15_r0_suffix.zfirst0 : Nat.ble aFirst PRE_first_tail_x15_r0_suffix.s2.next = true
kernel_rfl PRE_first_tail_x15_r0_suffix.zscn0 : PRE_first_tail_x15_r0_suffix.s4.next = PRE_first_tail_x15_r0_suffix.s2.next + PRE_first_tail_x15_r0_suffix.pl0.length
kernel_rfl PRE_first_tail_x15_r0_suffix.zsmn0 : PRE_first_tail_x15_r0_suffix.s3.next = 2828013
kernel_rfl PRE_first_tail_x15_r0_suffix.zgrow0 : Nat.ble PRE_first_tail_x15_r0_suffix.s4.next PRE_first_tail_x15_r0_suffix.s3.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_suffix.zfresh0 : PRE_first_tail_x15_r0_suffix.S2.tab.all (fun e => PRE_first_tail_x15_r0_suffix.cws0.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.zcnd0 : nodupT PRE_first_tail_x15_r0_suffix.cws0 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_suffix.znrHi0 : PRE_first_tail_x15_r0_suffix.nr0.all (fun r => Nat.blt r PRE_first_tail_x15_r0_suffix.S3.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_suffix.zfrlt0 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_suffix.s2.next) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.zg0_2665 : PRE_first_tail_x15_r0_suffix.s4.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_suffix.s4 2665))
kernel_rfl PRE_first_tail_x15_r0_suffix.zk0_2665 : (objOf PRE_first_tail_x15_r0_suffix.s4 2665).kind = .array (arrOf PRE_first_tail_x15_r0_suffix.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_suffix.zm0_2665 : PRE_first_tail_x15_r0_suffix.s3.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_suffix.kappa0.obj (objOf PRE_first_tail_x15_r0_suffix.s4 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_suffix.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_suffix.s3 2665).drop (arrOf PRE_first_tail_x15_r0_suffix.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_suffix.zg0_2673467 : PRE_first_tail_x15_r0_suffix.s4.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_suffix.s4 2673467))
kernel_rfl PRE_first_tail_x15_r0_suffix.zk0_2673467 : (objOf PRE_first_tail_x15_r0_suffix.s4 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_suffix.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_suffix.zm0_2673467 : PRE_first_tail_x15_r0_suffix.s3.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_suffix.kappa0.obj (objOf PRE_first_tail_x15_r0_suffix.s4 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_suffix.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_suffix.s3 2673467).drop (arrOf PRE_first_tail_x15_r0_suffix.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_suffix.zw0_4910 : (PRE_first_tail_x15_r0_suffix.s4.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_suffix.zw0_2673472 : (PRE_first_tail_x15_r0_suffix.s4.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_suffix.zw0_2673473 : (PRE_first_tail_x15_r0_suffix.s4.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_suffix.zclbd0 : PRE_first_tail_x15_r0_suffix.cl0.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.zwr0 : PRE_first_tail_x15_r0_suffix.st0.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_suffix.s2.next || PRE_first_tail_x15_r0_suffix.cl0.contains b) = true
def PRE_first_tail_x15_r0_suffix.zl0 : List Nat := PRE_first_tail_x15_r0_suffix.cl0.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_suffix.zimgE0 : PRE_first_tail_x15_r0_suffix.zl0.map (fun a => PRE_first_tail_x15_r0_suffix.s3.heap.get (PRE_first_tail_x15_r0_suffix.kappa0.a a)) = PRE_first_tail_x15_r0_suffix.zl0.map (fun a => (PRE_first_tail_x15_r0_suffix.s4.heap.get a).map PRE_first_tail_x15_r0_suffix.kappa0.hobj)
theorem PRE_first_tail_x15_r0_suffix.zimg0 : HeapImg PRE_first_tail_x15_r0_suffix.kappa0 PRE_first_tail_x15_r0_suffix.s4 PRE_first_tail_x15_r0_suffix.s3 PRE_first_tail_x15_r0_suffix.zl0 := PRE_first_tail_x15_r0_suffix.zimgE0
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_suffix.zctl0 : PRE_first_tail_x15_r0_suffix.s3.ctl = PRE_first_tail_x15_r0_suffix.kappa0.ctl PRE_first_tail_x15_r0_suffix.s4.ctl
kernel_rfl PRE_first_tail_x15_r0_suffix.zstack0 : PRE_first_tail_x15_r0_suffix.s3.stack = PRE_first_tail_x15_r0_suffix.s4.stack.map PRE_first_tail_x15_r0_suffix.kappa0.frame
kernel_rfl PRE_first_tail_x15_r0_suffix.zjobs0 : PRE_first_tail_x15_r0_suffix.s3.jobs = PRE_first_tail_x15_r0_suffix.s4.jobs.map PRE_first_tail_x15_r0_suffix.kappa0.job
kernel_rfl PRE_first_tail_x15_r0_suffix.zstores0 : PRE_first_tail_x15_r0_suffix.s3.stores = PRE_first_tail_x15_r0_suffix.kappa0.stores PRE_first_tail_x15_r0_suffix.s4.stores
kernel_rfl PRE_first_tail_x15_r0_suffix.zroots0 : checkRootsSupp PRE_first_tail_x15_r0_suffix.s4 8226 = true
kernel_rfl PRE_first_tail_x15_r0_suffix.znC0 : PRE_first_tail_x15_r0_suffix.S2.tab.length + PRE_first_tail_x15_r0_suffix.cws0.length = 8226
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_suffix.zkap0 : PRE_first_tail_x15_r0_suffix.kappa0 = Conv.Map.compact PRE_first_tail_x15_r0_suffix.s2.next 2828013 PRE_first_tail_x15_r0_suffix.S2.tab.length PRE_first_tail_x15_r0_suffix.pl0 (PRE_first_tail_x15_r0_suffix.nr0.map NumV.ref) PRE_first_tail_x15_r0_suffix.kd0.big
  PRE_first_tail_x15_r0_suffix.kd0.region PRE_first_tail_x15_r0_suffix.kd0.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_suffix.zbin0 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_suffix.s4.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_suffix.zjc0 : Conv.jcleanListB (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) PRE_first_tail_x15_r0_suffix.s4 PRE_first_tail_x15_r0_suffix.cl0 = true
kernel_rfl PRE_first_tail_x15_r0_suffix.zroots20 : noBigRootsP (fun i => !Conv.oldBigB (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_suffix.s4.trace PRE_first_tail_x15_r0_suffix.s4 = true
kernel_rfl PRE_first_tail_x15_r0_suffix.zhm0 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s0.ffi).mlx.nnext 19057 = true
theorem PRE_first_tail_x15_r0_suffix.cjcl0 (h : Conv.JClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) PRE_first_tail_x15_r0_suffix.s2) : Conv.JClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) PRE_first_tail_x15_r0_suffix.s4 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_suffix.cle0)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_suffix.cheap0 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_suffix.zclbd0 a ha)) PRE_first_tail_x15_r0_suffix.zjc0

end Host.Load.Run.Tpl

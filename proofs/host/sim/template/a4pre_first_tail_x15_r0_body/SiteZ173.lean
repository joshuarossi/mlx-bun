import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS173
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK173
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF173
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 173 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1667`, the merged
state `PRE_first_tail_x15_r0_body.s1668`, the canonical state `PRE_first_tail_x15_r0_body.s1669`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl173 : PRE_first_tail_x15_r0_body.pl173.all (Nat.ble PRE_first_tail_x15_r0_body.s1667.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd173 : nodupT PRE_first_tail_x15_r0_body.pl173 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1173 : Nat.ble PRE_first_tail_x15_r0_body.s1667.next 2810363 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst173 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1667.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn173 : PRE_first_tail_x15_r0_body.s1669.next = PRE_first_tail_x15_r0_body.s1667.next + PRE_first_tail_x15_r0_body.pl173.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn173 : PRE_first_tail_x15_r0_body.s1668.next = 2810363
kernel_rfl PRE_first_tail_x15_r0_body.zgrow173 : Nat.ble PRE_first_tail_x15_r0_body.s1669.next PRE_first_tail_x15_r0_body.s1668.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh173 : PRE_first_tail_x15_r0_body.S1667.tab.all (fun e => PRE_first_tail_x15_r0_body.cws173.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd173 : nodupT PRE_first_tail_x15_r0_body.cws173 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi173 : PRE_first_tail_x15_r0_body.nr173.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1668.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt173 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1667.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg173_2665 : PRE_first_tail_x15_r0_body.s1669.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1669 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk173_2665 : (objOf PRE_first_tail_x15_r0_body.s1669 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm173_2665 : PRE_first_tail_x15_r0_body.s1668.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa173.obj (objOf PRE_first_tail_x15_r0_body.s1669 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1668 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg173_2673467 : PRE_first_tail_x15_r0_body.s1669.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1669 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk173_2673467 : (objOf PRE_first_tail_x15_r0_body.s1669 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm173_2673467 : PRE_first_tail_x15_r0_body.s1668.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa173.obj (objOf PRE_first_tail_x15_r0_body.s1669 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1668 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw173_4910 : (PRE_first_tail_x15_r0_body.s1669.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw173_2673472 : (PRE_first_tail_x15_r0_body.s1669.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw173_2673473 : (PRE_first_tail_x15_r0_body.s1669.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd173 : PRE_first_tail_x15_r0_body.cl173.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr173 : PRE_first_tail_x15_r0_body.st173.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1667.next || PRE_first_tail_x15_r0_body.cl173.contains b) = true
def PRE_first_tail_x15_r0_body.zl173 : List Nat := PRE_first_tail_x15_r0_body.cl173.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE173 : PRE_first_tail_x15_r0_body.zl173.map (fun a => PRE_first_tail_x15_r0_body.s1668.heap.get (PRE_first_tail_x15_r0_body.kappa173.a a)) = PRE_first_tail_x15_r0_body.zl173.map (fun a => (PRE_first_tail_x15_r0_body.s1669.heap.get a).map PRE_first_tail_x15_r0_body.kappa173.hobj)
theorem PRE_first_tail_x15_r0_body.zimg173 : HeapImg PRE_first_tail_x15_r0_body.kappa173 PRE_first_tail_x15_r0_body.s1669 PRE_first_tail_x15_r0_body.s1668 PRE_first_tail_x15_r0_body.zl173 := PRE_first_tail_x15_r0_body.zimgE173
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl173 : PRE_first_tail_x15_r0_body.s1668.ctl = PRE_first_tail_x15_r0_body.kappa173.ctl PRE_first_tail_x15_r0_body.s1669.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack173 : PRE_first_tail_x15_r0_body.s1668.stack = PRE_first_tail_x15_r0_body.s1669.stack.map PRE_first_tail_x15_r0_body.kappa173.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs173 : PRE_first_tail_x15_r0_body.s1668.jobs = PRE_first_tail_x15_r0_body.s1669.jobs.map PRE_first_tail_x15_r0_body.kappa173.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores173 : PRE_first_tail_x15_r0_body.s1668.stores = PRE_first_tail_x15_r0_body.kappa173.stores PRE_first_tail_x15_r0_body.s1669.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots173 : checkRootsSupp PRE_first_tail_x15_r0_body.s1669 7450 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC173 : PRE_first_tail_x15_r0_body.S1667.tab.length + PRE_first_tail_x15_r0_body.cws173.length = 7450
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap173 : PRE_first_tail_x15_r0_body.kappa173 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1667.next 2810363 PRE_first_tail_x15_r0_body.S1667.tab.length PRE_first_tail_x15_r0_body.pl173 (PRE_first_tail_x15_r0_body.nr173.map NumV.ref) PRE_first_tail_x15_r0_body.kd173.big
  PRE_first_tail_x15_r0_body.kd173.region PRE_first_tail_x15_r0_body.kd173.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin173 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1669.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc173 : Conv.jcleanListB (⟨21600, 18703, 2810344, 7450⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1669 PRE_first_tail_x15_r0_body.cl173 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB173 : noBigRootsP (fun i => !Conv.oldBigB (⟨21600, 18703, 2810344, 7450⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1669.trace PRE_first_tail_x15_r0_body.s1669 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm173 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18703 = true
theorem PRE_first_tail_x15_r0_body.cjcl173 (h : Conv.JClean (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1667) : Conv.JClean (⟨21600, 18703, 2810344, 7450⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1669 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle173)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap173 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd173 a ha)) PRE_first_tail_x15_r0_body.zjc173

end Host.Load.Run.Tpl

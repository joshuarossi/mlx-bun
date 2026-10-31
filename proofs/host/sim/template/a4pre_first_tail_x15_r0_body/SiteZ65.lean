import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS65
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK65
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF65
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 65 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s577`, the merged
state `PRE_first_tail_x15_r0_body.s578`, the canonical state `PRE_first_tail_x15_r0_body.s579`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl65 : PRE_first_tail_x15_r0_body.pl65.all (Nat.ble PRE_first_tail_x15_r0_body.s577.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd65 : nodupT PRE_first_tail_x15_r0_body.pl65 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn165 : Nat.ble PRE_first_tail_x15_r0_body.s577.next 2725598 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst65 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s577.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn65 : PRE_first_tail_x15_r0_body.s579.next = PRE_first_tail_x15_r0_body.s577.next + PRE_first_tail_x15_r0_body.pl65.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn65 : PRE_first_tail_x15_r0_body.s578.next = 2725598
kernel_rfl PRE_first_tail_x15_r0_body.zgrow65 : Nat.ble PRE_first_tail_x15_r0_body.s579.next PRE_first_tail_x15_r0_body.s578.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh65 : PRE_first_tail_x15_r0_body.S577.tab.all (fun e => PRE_first_tail_x15_r0_body.cws65.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd65 : nodupT PRE_first_tail_x15_r0_body.cws65 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi65 : PRE_first_tail_x15_r0_body.nr65.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S578.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt65 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s577.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg65_2665 : PRE_first_tail_x15_r0_body.s579.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s579 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk65_2665 : (objOf PRE_first_tail_x15_r0_body.s579 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm65_2665 : PRE_first_tail_x15_r0_body.s578.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa65.obj (objOf PRE_first_tail_x15_r0_body.s579 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s578 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg65_2673467 : PRE_first_tail_x15_r0_body.s579.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s579 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk65_2673467 : (objOf PRE_first_tail_x15_r0_body.s579 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm65_2673467 : PRE_first_tail_x15_r0_body.s578.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa65.obj (objOf PRE_first_tail_x15_r0_body.s579 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s578 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw65_4910 : (PRE_first_tail_x15_r0_body.s579.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw65_2673472 : (PRE_first_tail_x15_r0_body.s579.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw65_2673473 : (PRE_first_tail_x15_r0_body.s579.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd65 : PRE_first_tail_x15_r0_body.cl65.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr65 : PRE_first_tail_x15_r0_body.st65.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s577.next || PRE_first_tail_x15_r0_body.cl65.contains b) = true
def PRE_first_tail_x15_r0_body.zl65 : List Nat := PRE_first_tail_x15_r0_body.cl65.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE65 : PRE_first_tail_x15_r0_body.zl65.map (fun a => PRE_first_tail_x15_r0_body.s578.heap.get (PRE_first_tail_x15_r0_body.kappa65.a a)) = PRE_first_tail_x15_r0_body.zl65.map (fun a => (PRE_first_tail_x15_r0_body.s579.heap.get a).map PRE_first_tail_x15_r0_body.kappa65.hobj)
theorem PRE_first_tail_x15_r0_body.zimg65 : HeapImg PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.s579 PRE_first_tail_x15_r0_body.s578 PRE_first_tail_x15_r0_body.zl65 := PRE_first_tail_x15_r0_body.zimgE65
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl65 : PRE_first_tail_x15_r0_body.s578.ctl = PRE_first_tail_x15_r0_body.kappa65.ctl PRE_first_tail_x15_r0_body.s579.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack65 : PRE_first_tail_x15_r0_body.s578.stack = PRE_first_tail_x15_r0_body.s579.stack.map PRE_first_tail_x15_r0_body.kappa65.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs65 : PRE_first_tail_x15_r0_body.s578.jobs = PRE_first_tail_x15_r0_body.s579.jobs.map PRE_first_tail_x15_r0_body.kappa65.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores65 : PRE_first_tail_x15_r0_body.s578.stores = PRE_first_tail_x15_r0_body.kappa65.stores PRE_first_tail_x15_r0_body.s579.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots65 : checkRootsSupp PRE_first_tail_x15_r0_body.s579 2833 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC65 : PRE_first_tail_x15_r0_body.S577.tab.length + PRE_first_tail_x15_r0_body.cws65.length = 2833
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap65 : PRE_first_tail_x15_r0_body.kappa65 = Conv.Map.compact PRE_first_tail_x15_r0_body.s577.next 2725598 PRE_first_tail_x15_r0_body.S577.tab.length PRE_first_tail_x15_r0_body.pl65 (PRE_first_tail_x15_r0_body.nr65.map NumV.ref) PRE_first_tail_x15_r0_body.kd65.big
  PRE_first_tail_x15_r0_body.kd65.region PRE_first_tail_x15_r0_body.kd65.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin65 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s579.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc65 : Conv.jcleanListB (⟨19476, 16570, 2725588, 2833⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s579 PRE_first_tail_x15_r0_body.cl65 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots265 : noBigRootsP (fun i => !Conv.oldBigB (⟨19476, 16570, 2725588, 2833⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s579.trace PRE_first_tail_x15_r0_body.s579 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm65 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16570 = true
theorem PRE_first_tail_x15_r0_body.cjcl65 (h : Conv.JClean (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s577) : Conv.JClean (⟨19476, 16570, 2725588, 2833⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s579 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle65)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap65 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd65 a ha)) PRE_first_tail_x15_r0_body.zjc65

end Host.Load.Run.Tpl

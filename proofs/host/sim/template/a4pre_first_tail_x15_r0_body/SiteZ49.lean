import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS49
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK49
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF49
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 49 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s441`, the merged
state `PRE_first_tail_x15_r0_body.s442`, the canonical state `PRE_first_tail_x15_r0_body.s443`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl49 : PRE_first_tail_x15_r0_body.pl49.all (Nat.ble PRE_first_tail_x15_r0_body.s441.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd49 : nodupT PRE_first_tail_x15_r0_body.pl49 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn149 : Nat.ble PRE_first_tail_x15_r0_body.s441.next 2713621 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst49 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s441.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn49 : PRE_first_tail_x15_r0_body.s443.next = PRE_first_tail_x15_r0_body.s441.next + PRE_first_tail_x15_r0_body.pl49.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn49 : PRE_first_tail_x15_r0_body.s442.next = 2713621
kernel_rfl PRE_first_tail_x15_r0_body.zgrow49 : Nat.ble PRE_first_tail_x15_r0_body.s443.next PRE_first_tail_x15_r0_body.s442.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh49 : PRE_first_tail_x15_r0_body.S441.tab.all (fun e => PRE_first_tail_x15_r0_body.cws49.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd49 : nodupT PRE_first_tail_x15_r0_body.cws49 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi49 : PRE_first_tail_x15_r0_body.nr49.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S442.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt49 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s441.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg49_2665 : PRE_first_tail_x15_r0_body.s443.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s443 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk49_2665 : (objOf PRE_first_tail_x15_r0_body.s443 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm49_2665 : PRE_first_tail_x15_r0_body.s442.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa49.obj (objOf PRE_first_tail_x15_r0_body.s443 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s442 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg49_2673467 : PRE_first_tail_x15_r0_body.s443.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s443 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk49_2673467 : (objOf PRE_first_tail_x15_r0_body.s443 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm49_2673467 : PRE_first_tail_x15_r0_body.s442.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa49.obj (objOf PRE_first_tail_x15_r0_body.s443 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s442 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw49_4910 : (PRE_first_tail_x15_r0_body.s443.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw49_2673472 : (PRE_first_tail_x15_r0_body.s443.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw49_2673473 : (PRE_first_tail_x15_r0_body.s443.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd49 : PRE_first_tail_x15_r0_body.cl49.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr49 : PRE_first_tail_x15_r0_body.st49.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s441.next || PRE_first_tail_x15_r0_body.cl49.contains b) = true
def PRE_first_tail_x15_r0_body.zl49 : List Nat := PRE_first_tail_x15_r0_body.cl49.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE49 : PRE_first_tail_x15_r0_body.zl49.map (fun a => PRE_first_tail_x15_r0_body.s442.heap.get (PRE_first_tail_x15_r0_body.kappa49.a a)) = PRE_first_tail_x15_r0_body.zl49.map (fun a => (PRE_first_tail_x15_r0_body.s443.heap.get a).map PRE_first_tail_x15_r0_body.kappa49.hobj)
theorem PRE_first_tail_x15_r0_body.zimg49 : HeapImg PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.s443 PRE_first_tail_x15_r0_body.s442 PRE_first_tail_x15_r0_body.zl49 := PRE_first_tail_x15_r0_body.zimgE49
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl49 : PRE_first_tail_x15_r0_body.s442.ctl = PRE_first_tail_x15_r0_body.kappa49.ctl PRE_first_tail_x15_r0_body.s443.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack49 : PRE_first_tail_x15_r0_body.s442.stack = PRE_first_tail_x15_r0_body.s443.stack.map PRE_first_tail_x15_r0_body.kappa49.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs49 : PRE_first_tail_x15_r0_body.s442.jobs = PRE_first_tail_x15_r0_body.s443.jobs.map PRE_first_tail_x15_r0_body.kappa49.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores49 : PRE_first_tail_x15_r0_body.s442.stores = PRE_first_tail_x15_r0_body.kappa49.stores PRE_first_tail_x15_r0_body.s443.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots49 : checkRootsSupp PRE_first_tail_x15_r0_body.s443 2174 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC49 : PRE_first_tail_x15_r0_body.S441.tab.length + PRE_first_tail_x15_r0_body.cws49.length = 2174
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap49 : PRE_first_tail_x15_r0_body.kappa49 = Conv.Map.compact PRE_first_tail_x15_r0_body.s441.next 2713621 PRE_first_tail_x15_r0_body.S441.tab.length PRE_first_tail_x15_r0_body.pl49 (PRE_first_tail_x15_r0_body.nr49.map NumV.ref) PRE_first_tail_x15_r0_body.kd49.big
  PRE_first_tail_x15_r0_body.kd49.region PRE_first_tail_x15_r0_body.kd49.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin49 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s443.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc49 : Conv.jcleanListB (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s443 PRE_first_tail_x15_r0_body.cl49 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots249 : noBigRootsP (fun i => !Conv.oldBigB (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s443.trace PRE_first_tail_x15_r0_body.s443 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm49 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16266 = true
theorem PRE_first_tail_x15_r0_body.cjcl49 (h : Conv.JClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s441) : Conv.JClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s443 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle49)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap49 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd49 a ha)) PRE_first_tail_x15_r0_body.zjc49

end Host.Load.Run.Tpl

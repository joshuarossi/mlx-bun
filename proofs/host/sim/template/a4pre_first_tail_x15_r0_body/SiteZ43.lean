import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS43
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK43
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF43
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 43 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s427`, the merged
state `PRE_first_tail_x15_r0_body.s428`, the canonical state `PRE_first_tail_x15_r0_body.s429`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl43 : PRE_first_tail_x15_r0_body.pl43.all (Nat.ble PRE_first_tail_x15_r0_body.s427.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd43 : nodupT PRE_first_tail_x15_r0_body.pl43 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn143 : Nat.ble PRE_first_tail_x15_r0_body.s427.next 2708717 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst43 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s427.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn43 : PRE_first_tail_x15_r0_body.s429.next = PRE_first_tail_x15_r0_body.s427.next + PRE_first_tail_x15_r0_body.pl43.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn43 : PRE_first_tail_x15_r0_body.s428.next = 2708717
kernel_rfl PRE_first_tail_x15_r0_body.zgrow43 : Nat.ble PRE_first_tail_x15_r0_body.s429.next PRE_first_tail_x15_r0_body.s428.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh43 : PRE_first_tail_x15_r0_body.S427.tab.all (fun e => PRE_first_tail_x15_r0_body.cws43.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd43 : nodupT PRE_first_tail_x15_r0_body.cws43 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi43 : PRE_first_tail_x15_r0_body.nr43.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S428.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt43 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s427.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg43_2665 : PRE_first_tail_x15_r0_body.s429.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s429 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk43_2665 : (objOf PRE_first_tail_x15_r0_body.s429 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm43_2665 : PRE_first_tail_x15_r0_body.s428.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa43.obj (objOf PRE_first_tail_x15_r0_body.s429 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s428 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg43_2673467 : PRE_first_tail_x15_r0_body.s429.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s429 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk43_2673467 : (objOf PRE_first_tail_x15_r0_body.s429 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm43_2673467 : PRE_first_tail_x15_r0_body.s428.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa43.obj (objOf PRE_first_tail_x15_r0_body.s429 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s428 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw43_4910 : (PRE_first_tail_x15_r0_body.s429.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw43_2673472 : (PRE_first_tail_x15_r0_body.s429.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw43_2673473 : (PRE_first_tail_x15_r0_body.s429.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd43 : PRE_first_tail_x15_r0_body.cl43.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr43 : PRE_first_tail_x15_r0_body.st43.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s427.next || PRE_first_tail_x15_r0_body.cl43.contains b) = true
def PRE_first_tail_x15_r0_body.zl43 : List Nat := PRE_first_tail_x15_r0_body.cl43.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE43 : PRE_first_tail_x15_r0_body.zl43.map (fun a => PRE_first_tail_x15_r0_body.s428.heap.get (PRE_first_tail_x15_r0_body.kappa43.a a)) = PRE_first_tail_x15_r0_body.zl43.map (fun a => (PRE_first_tail_x15_r0_body.s429.heap.get a).map PRE_first_tail_x15_r0_body.kappa43.hobj)
theorem PRE_first_tail_x15_r0_body.zimg43 : HeapImg PRE_first_tail_x15_r0_body.kappa43 PRE_first_tail_x15_r0_body.s429 PRE_first_tail_x15_r0_body.s428 PRE_first_tail_x15_r0_body.zl43 := PRE_first_tail_x15_r0_body.zimgE43
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl43 : PRE_first_tail_x15_r0_body.s428.ctl = PRE_first_tail_x15_r0_body.kappa43.ctl PRE_first_tail_x15_r0_body.s429.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack43 : PRE_first_tail_x15_r0_body.s428.stack = PRE_first_tail_x15_r0_body.s429.stack.map PRE_first_tail_x15_r0_body.kappa43.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs43 : PRE_first_tail_x15_r0_body.s428.jobs = PRE_first_tail_x15_r0_body.s429.jobs.map PRE_first_tail_x15_r0_body.kappa43.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores43 : PRE_first_tail_x15_r0_body.s428.stores = PRE_first_tail_x15_r0_body.kappa43.stores PRE_first_tail_x15_r0_body.s429.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots43 : checkRootsSupp PRE_first_tail_x15_r0_body.s429 1919 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC43 : PRE_first_tail_x15_r0_body.S427.tab.length + PRE_first_tail_x15_r0_body.cws43.length = 1919
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap43 : PRE_first_tail_x15_r0_body.kappa43 = Conv.Map.compact PRE_first_tail_x15_r0_body.s427.next 2708717 PRE_first_tail_x15_r0_body.S427.tab.length PRE_first_tail_x15_r0_body.pl43 (PRE_first_tail_x15_r0_body.nr43.map NumV.ref) PRE_first_tail_x15_r0_body.kd43.big
  PRE_first_tail_x15_r0_body.kd43.region PRE_first_tail_x15_r0_body.kd43.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin43 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s429.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc43 : Conv.jcleanListB (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s429 PRE_first_tail_x15_r0_body.cl43 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB43 : noBigRootsP (fun i => !Conv.oldBigB (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s429.trace PRE_first_tail_x15_r0_body.s429 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm43 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16155 = true
theorem PRE_first_tail_x15_r0_body.cjcl43 (h : Conv.JClean (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s427) : Conv.JClean (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s429 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle43)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap43 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd43 a ha)) PRE_first_tail_x15_r0_body.zjc43

end Host.Load.Run.Tpl

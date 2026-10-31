import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS80
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK80
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF80
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 80 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s776`, the merged
state `PRE_first_tail_x15_r0_body.s777`, the canonical state `PRE_first_tail_x15_r0_body.s778`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl80 : PRE_first_tail_x15_r0_body.pl80.all (Nat.ble PRE_first_tail_x15_r0_body.s776.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd80 : nodupT PRE_first_tail_x15_r0_body.pl80 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn180 : Nat.ble PRE_first_tail_x15_r0_body.s776.next 2737266 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst80 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s776.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn80 : PRE_first_tail_x15_r0_body.s778.next = PRE_first_tail_x15_r0_body.s776.next + PRE_first_tail_x15_r0_body.pl80.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn80 : PRE_first_tail_x15_r0_body.s777.next = 2737266
kernel_rfl PRE_first_tail_x15_r0_body.zgrow80 : Nat.ble PRE_first_tail_x15_r0_body.s778.next PRE_first_tail_x15_r0_body.s777.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh80 : PRE_first_tail_x15_r0_body.S776.tab.all (fun e => PRE_first_tail_x15_r0_body.cws80.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd80 : nodupT PRE_first_tail_x15_r0_body.cws80 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi80 : PRE_first_tail_x15_r0_body.nr80.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S777.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt80 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s776.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg80_2665 : PRE_first_tail_x15_r0_body.s778.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s778 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk80_2665 : (objOf PRE_first_tail_x15_r0_body.s778 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm80_2665 : PRE_first_tail_x15_r0_body.s777.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa80.obj (objOf PRE_first_tail_x15_r0_body.s778 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s777 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg80_2673467 : PRE_first_tail_x15_r0_body.s778.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s778 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk80_2673467 : (objOf PRE_first_tail_x15_r0_body.s778 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm80_2673467 : PRE_first_tail_x15_r0_body.s777.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa80.obj (objOf PRE_first_tail_x15_r0_body.s778 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s777 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw80_4910 : (PRE_first_tail_x15_r0_body.s778.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw80_2673472 : (PRE_first_tail_x15_r0_body.s778.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw80_2673473 : (PRE_first_tail_x15_r0_body.s778.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd80 : PRE_first_tail_x15_r0_body.cl80.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr80 : PRE_first_tail_x15_r0_body.st80.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s776.next || PRE_first_tail_x15_r0_body.cl80.contains b) = true
def PRE_first_tail_x15_r0_body.zl80 : List Nat := PRE_first_tail_x15_r0_body.cl80.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE80 : PRE_first_tail_x15_r0_body.zl80.map (fun a => PRE_first_tail_x15_r0_body.s777.heap.get (PRE_first_tail_x15_r0_body.kappa80.a a)) = PRE_first_tail_x15_r0_body.zl80.map (fun a => (PRE_first_tail_x15_r0_body.s778.heap.get a).map PRE_first_tail_x15_r0_body.kappa80.hobj)
theorem PRE_first_tail_x15_r0_body.zimg80 : HeapImg PRE_first_tail_x15_r0_body.kappa80 PRE_first_tail_x15_r0_body.s778 PRE_first_tail_x15_r0_body.s777 PRE_first_tail_x15_r0_body.zl80 := PRE_first_tail_x15_r0_body.zimgE80
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl80 : PRE_first_tail_x15_r0_body.s777.ctl = PRE_first_tail_x15_r0_body.kappa80.ctl PRE_first_tail_x15_r0_body.s778.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack80 : PRE_first_tail_x15_r0_body.s777.stack = PRE_first_tail_x15_r0_body.s778.stack.map PRE_first_tail_x15_r0_body.kappa80.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs80 : PRE_first_tail_x15_r0_body.s777.jobs = PRE_first_tail_x15_r0_body.s778.jobs.map PRE_first_tail_x15_r0_body.kappa80.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores80 : PRE_first_tail_x15_r0_body.s777.stores = PRE_first_tail_x15_r0_body.kappa80.stores PRE_first_tail_x15_r0_body.s778.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots80 : checkRootsSupp PRE_first_tail_x15_r0_body.s778 3475 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC80 : PRE_first_tail_x15_r0_body.S776.tab.length + PRE_first_tail_x15_r0_body.cws80.length = 3475
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap80 : PRE_first_tail_x15_r0_body.kappa80 = Conv.Map.compact PRE_first_tail_x15_r0_body.s776.next 2737266 PRE_first_tail_x15_r0_body.S776.tab.length PRE_first_tail_x15_r0_body.pl80 (PRE_first_tail_x15_r0_body.nr80.map NumV.ref) PRE_first_tail_x15_r0_body.kd80.big
  PRE_first_tail_x15_r0_body.kd80.region PRE_first_tail_x15_r0_body.kd80.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin80 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s778.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc80 : Conv.jcleanListB (⟨19769, 16870, 2737256, 3475⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s778 PRE_first_tail_x15_r0_body.cl80 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB80 : noBigRootsP (fun i => !Conv.oldBigB (⟨19769, 16870, 2737256, 3475⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s778.trace PRE_first_tail_x15_r0_body.s778 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm80 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16870 = true
theorem PRE_first_tail_x15_r0_body.cjcl80 (h : Conv.JClean (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s776) : Conv.JClean (⟨19769, 16870, 2737256, 3475⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s778 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle80)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap80 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd80 a ha)) PRE_first_tail_x15_r0_body.zjc80

end Host.Load.Run.Tpl

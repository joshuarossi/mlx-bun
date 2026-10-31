import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS121
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK121
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF121
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 121 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1174`, the merged
state `PRE_first_tail_x15_r0_body.s1175`, the canonical state `PRE_first_tail_x15_r0_body.s1176`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl121 : PRE_first_tail_x15_r0_body.pl121.all (Nat.ble PRE_first_tail_x15_r0_body.s1174.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd121 : nodupT PRE_first_tail_x15_r0_body.pl121 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1121 : Nat.ble PRE_first_tail_x15_r0_body.s1174.next 2770121 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst121 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1174.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn121 : PRE_first_tail_x15_r0_body.s1176.next = PRE_first_tail_x15_r0_body.s1174.next + PRE_first_tail_x15_r0_body.pl121.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn121 : PRE_first_tail_x15_r0_body.s1175.next = 2770121
kernel_rfl PRE_first_tail_x15_r0_body.zgrow121 : Nat.ble PRE_first_tail_x15_r0_body.s1176.next PRE_first_tail_x15_r0_body.s1175.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh121 : PRE_first_tail_x15_r0_body.S1174.tab.all (fun e => PRE_first_tail_x15_r0_body.cws121.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd121 : nodupT PRE_first_tail_x15_r0_body.cws121 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi121 : PRE_first_tail_x15_r0_body.nr121.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1175.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt121 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1174.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg121_2665 : PRE_first_tail_x15_r0_body.s1176.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1176 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk121_2665 : (objOf PRE_first_tail_x15_r0_body.s1176 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm121_2665 : PRE_first_tail_x15_r0_body.s1175.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa121.obj (objOf PRE_first_tail_x15_r0_body.s1176 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1175 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg121_2673467 : PRE_first_tail_x15_r0_body.s1176.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1176 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk121_2673467 : (objOf PRE_first_tail_x15_r0_body.s1176 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm121_2673467 : PRE_first_tail_x15_r0_body.s1175.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa121.obj (objOf PRE_first_tail_x15_r0_body.s1176 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1175 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw121_4910 : (PRE_first_tail_x15_r0_body.s1176.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw121_2673472 : (PRE_first_tail_x15_r0_body.s1176.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw121_2673473 : (PRE_first_tail_x15_r0_body.s1176.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd121 : PRE_first_tail_x15_r0_body.cl121.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr121 : PRE_first_tail_x15_r0_body.st121.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1174.next || PRE_first_tail_x15_r0_body.cl121.contains b) = true
def PRE_first_tail_x15_r0_body.zl121 : List Nat := PRE_first_tail_x15_r0_body.cl121.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE121 : PRE_first_tail_x15_r0_body.zl121.map (fun a => PRE_first_tail_x15_r0_body.s1175.heap.get (PRE_first_tail_x15_r0_body.kappa121.a a)) = PRE_first_tail_x15_r0_body.zl121.map (fun a => (PRE_first_tail_x15_r0_body.s1176.heap.get a).map PRE_first_tail_x15_r0_body.kappa121.hobj)
theorem PRE_first_tail_x15_r0_body.zimg121 : HeapImg PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.s1176 PRE_first_tail_x15_r0_body.s1175 PRE_first_tail_x15_r0_body.zl121 := PRE_first_tail_x15_r0_body.zimgE121
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl121 : PRE_first_tail_x15_r0_body.s1175.ctl = PRE_first_tail_x15_r0_body.kappa121.ctl PRE_first_tail_x15_r0_body.s1176.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack121 : PRE_first_tail_x15_r0_body.s1175.stack = PRE_first_tail_x15_r0_body.s1176.stack.map PRE_first_tail_x15_r0_body.kappa121.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs121 : PRE_first_tail_x15_r0_body.s1175.jobs = PRE_first_tail_x15_r0_body.s1176.jobs.map PRE_first_tail_x15_r0_body.kappa121.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores121 : PRE_first_tail_x15_r0_body.s1175.stores = PRE_first_tail_x15_r0_body.kappa121.stores PRE_first_tail_x15_r0_body.s1176.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots121 : checkRootsSupp PRE_first_tail_x15_r0_body.s1176 5252 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC121 : PRE_first_tail_x15_r0_body.S1174.tab.length + PRE_first_tail_x15_r0_body.cws121.length = 5252
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap121 : PRE_first_tail_x15_r0_body.kappa121 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1174.next 2770121 PRE_first_tail_x15_r0_body.S1174.tab.length PRE_first_tail_x15_r0_body.pl121 (PRE_first_tail_x15_r0_body.nr121.map NumV.ref) PRE_first_tail_x15_r0_body.kd121.big
  PRE_first_tail_x15_r0_body.kd121.region PRE_first_tail_x15_r0_body.kd121.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin121 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1176.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc121 : Conv.jcleanListB (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1176 PRE_first_tail_x15_r0_body.cl121 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB121 : noBigRootsP (fun i => !Conv.oldBigB (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1176.trace PRE_first_tail_x15_r0_body.s1176 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm121 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17688 = true
theorem PRE_first_tail_x15_r0_body.cjcl121 (h : Conv.JClean (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1174) : Conv.JClean (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1176 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle121)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap121 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd121 a ha)) PRE_first_tail_x15_r0_body.zjc121

end Host.Load.Run.Tpl

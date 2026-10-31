import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS142
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK142
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF142
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 142 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1375`, the merged
state `PRE_first_tail_x15_r0_body.s1376`, the canonical state `PRE_first_tail_x15_r0_body.s1377`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl142 : PRE_first_tail_x15_r0_body.pl142.all (Nat.ble PRE_first_tail_x15_r0_body.s1375.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd142 : nodupT PRE_first_tail_x15_r0_body.pl142 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1142 : Nat.ble PRE_first_tail_x15_r0_body.s1375.next 2786675 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst142 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1375.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn142 : PRE_first_tail_x15_r0_body.s1377.next = PRE_first_tail_x15_r0_body.s1375.next + PRE_first_tail_x15_r0_body.pl142.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn142 : PRE_first_tail_x15_r0_body.s1376.next = 2786675
kernel_rfl PRE_first_tail_x15_r0_body.zgrow142 : Nat.ble PRE_first_tail_x15_r0_body.s1377.next PRE_first_tail_x15_r0_body.s1376.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh142 : PRE_first_tail_x15_r0_body.S1375.tab.all (fun e => PRE_first_tail_x15_r0_body.cws142.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd142 : nodupT PRE_first_tail_x15_r0_body.cws142 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi142 : PRE_first_tail_x15_r0_body.nr142.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1376.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt142 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1375.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg142_2665 : PRE_first_tail_x15_r0_body.s1377.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1377 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk142_2665 : (objOf PRE_first_tail_x15_r0_body.s1377 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm142_2665 : PRE_first_tail_x15_r0_body.s1376.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa142.obj (objOf PRE_first_tail_x15_r0_body.s1377 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1376 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg142_2673467 : PRE_first_tail_x15_r0_body.s1377.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1377 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk142_2673467 : (objOf PRE_first_tail_x15_r0_body.s1377 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm142_2673467 : PRE_first_tail_x15_r0_body.s1376.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa142.obj (objOf PRE_first_tail_x15_r0_body.s1377 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1376 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw142_4910 : (PRE_first_tail_x15_r0_body.s1377.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw142_2673472 : (PRE_first_tail_x15_r0_body.s1377.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw142_2673473 : (PRE_first_tail_x15_r0_body.s1377.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd142 : PRE_first_tail_x15_r0_body.cl142.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr142 : PRE_first_tail_x15_r0_body.st142.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1375.next || PRE_first_tail_x15_r0_body.cl142.contains b) = true
def PRE_first_tail_x15_r0_body.zl142 : List Nat := PRE_first_tail_x15_r0_body.cl142.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE142 : PRE_first_tail_x15_r0_body.zl142.map (fun a => PRE_first_tail_x15_r0_body.s1376.heap.get (PRE_first_tail_x15_r0_body.kappa142.a a)) = PRE_first_tail_x15_r0_body.zl142.map (fun a => (PRE_first_tail_x15_r0_body.s1377.heap.get a).map PRE_first_tail_x15_r0_body.kappa142.hobj)
theorem PRE_first_tail_x15_r0_body.zimg142 : HeapImg PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.s1377 PRE_first_tail_x15_r0_body.s1376 PRE_first_tail_x15_r0_body.zl142 := PRE_first_tail_x15_r0_body.zimgE142
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl142 : PRE_first_tail_x15_r0_body.s1376.ctl = PRE_first_tail_x15_r0_body.kappa142.ctl PRE_first_tail_x15_r0_body.s1377.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack142 : PRE_first_tail_x15_r0_body.s1376.stack = PRE_first_tail_x15_r0_body.s1377.stack.map PRE_first_tail_x15_r0_body.kappa142.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs142 : PRE_first_tail_x15_r0_body.s1376.jobs = PRE_first_tail_x15_r0_body.s1377.jobs.map PRE_first_tail_x15_r0_body.kappa142.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores142 : PRE_first_tail_x15_r0_body.s1376.stores = PRE_first_tail_x15_r0_body.kappa142.stores PRE_first_tail_x15_r0_body.s1377.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots142 : checkRootsSupp PRE_first_tail_x15_r0_body.s1377 6149 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC142 : PRE_first_tail_x15_r0_body.S1375.tab.length + PRE_first_tail_x15_r0_body.cws142.length = 6149
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap142 : PRE_first_tail_x15_r0_body.kappa142 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1375.next 2786675 PRE_first_tail_x15_r0_body.S1375.tab.length PRE_first_tail_x15_r0_body.pl142 (PRE_first_tail_x15_r0_body.nr142.map NumV.ref) PRE_first_tail_x15_r0_body.kd142.big
  PRE_first_tail_x15_r0_body.kd142.region PRE_first_tail_x15_r0_body.kd142.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin142 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1377.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc142 : Conv.jcleanListB (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1377 PRE_first_tail_x15_r0_body.cl142 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB142 : noBigRootsP (fun i => !Conv.oldBigB (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1377.trace PRE_first_tail_x15_r0_body.s1377 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm142 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18099 = true
theorem PRE_first_tail_x15_r0_body.cjcl142 (h : Conv.JClean (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1375) : Conv.JClean (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1377 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle142)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap142 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd142 a ha)) PRE_first_tail_x15_r0_body.zjc142

end Host.Load.Run.Tpl

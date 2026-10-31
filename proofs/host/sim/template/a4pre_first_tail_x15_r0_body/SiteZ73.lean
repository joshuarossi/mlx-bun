import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS73
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK73
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF73
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 73 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s651`, the merged
state `PRE_first_tail_x15_r0_body.s652`, the canonical state `PRE_first_tail_x15_r0_body.s653`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl73 : PRE_first_tail_x15_r0_body.pl73.all (Nat.ble PRE_first_tail_x15_r0_body.s651.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd73 : nodupT PRE_first_tail_x15_r0_body.pl73 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn173 : Nat.ble PRE_first_tail_x15_r0_body.s651.next 2732457 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst73 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s651.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn73 : PRE_first_tail_x15_r0_body.s653.next = PRE_first_tail_x15_r0_body.s651.next + PRE_first_tail_x15_r0_body.pl73.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn73 : PRE_first_tail_x15_r0_body.s652.next = 2732457
kernel_rfl PRE_first_tail_x15_r0_body.zgrow73 : Nat.ble PRE_first_tail_x15_r0_body.s653.next PRE_first_tail_x15_r0_body.s652.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh73 : PRE_first_tail_x15_r0_body.S651.tab.all (fun e => PRE_first_tail_x15_r0_body.cws73.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd73 : nodupT PRE_first_tail_x15_r0_body.cws73 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi73 : PRE_first_tail_x15_r0_body.nr73.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S652.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt73 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s651.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg73_2665 : PRE_first_tail_x15_r0_body.s653.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s653 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk73_2665 : (objOf PRE_first_tail_x15_r0_body.s653 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm73_2665 : PRE_first_tail_x15_r0_body.s652.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa73.obj (objOf PRE_first_tail_x15_r0_body.s653 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s652 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg73_2673467 : PRE_first_tail_x15_r0_body.s653.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s653 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk73_2673467 : (objOf PRE_first_tail_x15_r0_body.s653 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm73_2673467 : PRE_first_tail_x15_r0_body.s652.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa73.obj (objOf PRE_first_tail_x15_r0_body.s653 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s652 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw73_4910 : (PRE_first_tail_x15_r0_body.s653.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw73_2673472 : (PRE_first_tail_x15_r0_body.s653.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw73_2673473 : (PRE_first_tail_x15_r0_body.s653.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd73 : PRE_first_tail_x15_r0_body.cl73.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr73 : PRE_first_tail_x15_r0_body.st73.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s651.next || PRE_first_tail_x15_r0_body.cl73.contains b) = true
def PRE_first_tail_x15_r0_body.zl73 : List Nat := PRE_first_tail_x15_r0_body.cl73.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE73 : PRE_first_tail_x15_r0_body.zl73.map (fun a => PRE_first_tail_x15_r0_body.s652.heap.get (PRE_first_tail_x15_r0_body.kappa73.a a)) = PRE_first_tail_x15_r0_body.zl73.map (fun a => (PRE_first_tail_x15_r0_body.s653.heap.get a).map PRE_first_tail_x15_r0_body.kappa73.hobj)
theorem PRE_first_tail_x15_r0_body.zimg73 : HeapImg PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.s653 PRE_first_tail_x15_r0_body.s652 PRE_first_tail_x15_r0_body.zl73 := PRE_first_tail_x15_r0_body.zimgE73
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl73 : PRE_first_tail_x15_r0_body.s652.ctl = PRE_first_tail_x15_r0_body.kappa73.ctl PRE_first_tail_x15_r0_body.s653.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack73 : PRE_first_tail_x15_r0_body.s652.stack = PRE_first_tail_x15_r0_body.s653.stack.map PRE_first_tail_x15_r0_body.kappa73.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs73 : PRE_first_tail_x15_r0_body.s652.jobs = PRE_first_tail_x15_r0_body.s653.jobs.map PRE_first_tail_x15_r0_body.kappa73.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores73 : PRE_first_tail_x15_r0_body.s652.stores = PRE_first_tail_x15_r0_body.kappa73.stores PRE_first_tail_x15_r0_body.s653.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots73 : checkRootsSupp PRE_first_tail_x15_r0_body.s653 3200 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC73 : PRE_first_tail_x15_r0_body.S651.tab.length + PRE_first_tail_x15_r0_body.cws73.length = 3200
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap73 : PRE_first_tail_x15_r0_body.kappa73 = Conv.Map.compact PRE_first_tail_x15_r0_body.s651.next 2732457 PRE_first_tail_x15_r0_body.S651.tab.length PRE_first_tail_x15_r0_body.pl73 (PRE_first_tail_x15_r0_body.nr73.map NumV.ref) PRE_first_tail_x15_r0_body.kd73.big
  PRE_first_tail_x15_r0_body.kd73.region PRE_first_tail_x15_r0_body.kd73.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin73 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s653.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc73 : Conv.jcleanListB (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s653 PRE_first_tail_x15_r0_body.cl73 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots273 : noBigRootsP (fun i => !Conv.oldBigB (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s653.trace PRE_first_tail_x15_r0_body.s653 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm73 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16740 = true
theorem PRE_first_tail_x15_r0_body.cjcl73 (h : Conv.JClean (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s651) : Conv.JClean (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s653 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle73)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap73 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd73 a ha)) PRE_first_tail_x15_r0_body.zjc73

end Host.Load.Run.Tpl

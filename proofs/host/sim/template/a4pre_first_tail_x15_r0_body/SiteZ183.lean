import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS183
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK183
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF183
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 183 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1616`, the merged
state `PRE_first_tail_x15_r0_body.s1617`, the canonical state `PRE_first_tail_x15_r0_body.s1618`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl183 : PRE_first_tail_x15_r0_body.pl183.all (Nat.ble PRE_first_tail_x15_r0_body.s1616.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd183 : nodupT PRE_first_tail_x15_r0_body.pl183 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1183 : Nat.ble PRE_first_tail_x15_r0_body.s1616.next 2820142 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst183 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1616.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn183 : PRE_first_tail_x15_r0_body.s1618.next = PRE_first_tail_x15_r0_body.s1616.next + PRE_first_tail_x15_r0_body.pl183.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn183 : PRE_first_tail_x15_r0_body.s1617.next = 2820142
kernel_rfl PRE_first_tail_x15_r0_body.zgrow183 : Nat.ble PRE_first_tail_x15_r0_body.s1618.next PRE_first_tail_x15_r0_body.s1617.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh183 : PRE_first_tail_x15_r0_body.S1616.tab.all (fun e => PRE_first_tail_x15_r0_body.cws183.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd183 : nodupT PRE_first_tail_x15_r0_body.cws183 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi183 : PRE_first_tail_x15_r0_body.nr183.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1617.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt183 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1616.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg183_2665 : PRE_first_tail_x15_r0_body.s1618.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1618 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk183_2665 : (objOf PRE_first_tail_x15_r0_body.s1618 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm183_2665 : PRE_first_tail_x15_r0_body.s1617.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa183.obj (objOf PRE_first_tail_x15_r0_body.s1618 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1617 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg183_2673467 : PRE_first_tail_x15_r0_body.s1618.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1618 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk183_2673467 : (objOf PRE_first_tail_x15_r0_body.s1618 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm183_2673467 : PRE_first_tail_x15_r0_body.s1617.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa183.obj (objOf PRE_first_tail_x15_r0_body.s1618 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1617 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw183_4910 : (PRE_first_tail_x15_r0_body.s1618.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw183_2673472 : (PRE_first_tail_x15_r0_body.s1618.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw183_2673473 : (PRE_first_tail_x15_r0_body.s1618.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd183 : PRE_first_tail_x15_r0_body.cl183.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr183 : PRE_first_tail_x15_r0_body.st183.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1616.next || PRE_first_tail_x15_r0_body.cl183.contains b) = true
def PRE_first_tail_x15_r0_body.zl183 : List Nat := PRE_first_tail_x15_r0_body.cl183.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE183 : PRE_first_tail_x15_r0_body.zl183.map (fun a => PRE_first_tail_x15_r0_body.s1617.heap.get (PRE_first_tail_x15_r0_body.kappa183.a a)) = PRE_first_tail_x15_r0_body.zl183.map (fun a => (PRE_first_tail_x15_r0_body.s1618.heap.get a).map PRE_first_tail_x15_r0_body.kappa183.hobj)
theorem PRE_first_tail_x15_r0_body.zimg183 : HeapImg PRE_first_tail_x15_r0_body.kappa183 PRE_first_tail_x15_r0_body.s1618 PRE_first_tail_x15_r0_body.s1617 PRE_first_tail_x15_r0_body.zl183 := PRE_first_tail_x15_r0_body.zimgE183
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl183 : PRE_first_tail_x15_r0_body.s1617.ctl = PRE_first_tail_x15_r0_body.kappa183.ctl PRE_first_tail_x15_r0_body.s1618.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack183 : PRE_first_tail_x15_r0_body.s1617.stack = PRE_first_tail_x15_r0_body.s1618.stack.map PRE_first_tail_x15_r0_body.kappa183.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs183 : PRE_first_tail_x15_r0_body.s1617.jobs = PRE_first_tail_x15_r0_body.s1618.jobs.map PRE_first_tail_x15_r0_body.kappa183.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores183 : PRE_first_tail_x15_r0_body.s1617.stores = PRE_first_tail_x15_r0_body.kappa183.stores PRE_first_tail_x15_r0_body.s1618.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots183 : checkRootsSupp PRE_first_tail_x15_r0_body.s1618 7925 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC183 : PRE_first_tail_x15_r0_body.S1616.tab.length + PRE_first_tail_x15_r0_body.cws183.length = 7925
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap183 : PRE_first_tail_x15_r0_body.kappa183 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1616.next 2820142 PRE_first_tail_x15_r0_body.S1616.tab.length PRE_first_tail_x15_r0_body.pl183 (PRE_first_tail_x15_r0_body.nr183.map NumV.ref) PRE_first_tail_x15_r0_body.kd183.big
  PRE_first_tail_x15_r0_body.kd183.region PRE_first_tail_x15_r0_body.kd183.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin183 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1618.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc183 : Conv.jcleanListB (⟨21816, 18923, 2818993, 7925⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1618 PRE_first_tail_x15_r0_body.cl183 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2183 : noBigRootsP (fun i => !Conv.oldBigB (⟨21816, 18923, 2818993, 7925⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1618.trace PRE_first_tail_x15_r0_body.s1618 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm183 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18896 = true
theorem PRE_first_tail_x15_r0_body.cjcl183 (h : Conv.JClean (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1616) : Conv.JClean (⟨21816, 18923, 2818993, 7925⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1618 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle183)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap183 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd183 a ha)) PRE_first_tail_x15_r0_body.zjc183

end Host.Load.Run.Tpl

import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS186
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK186
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF186
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 186 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1643`, the merged
state `PRE_first_tail_x15_r0_body.s1644`, the canonical state `PRE_first_tail_x15_r0_body.s1645`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl186 : PRE_first_tail_x15_r0_body.pl186.all (Nat.ble PRE_first_tail_x15_r0_body.s1643.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd186 : nodupT PRE_first_tail_x15_r0_body.pl186 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1186 : Nat.ble PRE_first_tail_x15_r0_body.s1643.next 2822402 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst186 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1643.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn186 : PRE_first_tail_x15_r0_body.s1645.next = PRE_first_tail_x15_r0_body.s1643.next + PRE_first_tail_x15_r0_body.pl186.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn186 : PRE_first_tail_x15_r0_body.s1644.next = 2822402
kernel_rfl PRE_first_tail_x15_r0_body.zgrow186 : Nat.ble PRE_first_tail_x15_r0_body.s1645.next PRE_first_tail_x15_r0_body.s1644.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh186 : PRE_first_tail_x15_r0_body.S1643.tab.all (fun e => PRE_first_tail_x15_r0_body.cws186.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd186 : nodupT PRE_first_tail_x15_r0_body.cws186 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi186 : PRE_first_tail_x15_r0_body.nr186.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1644.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt186 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1643.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg186_2665 : PRE_first_tail_x15_r0_body.s1645.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1645 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk186_2665 : (objOf PRE_first_tail_x15_r0_body.s1645 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm186_2665 : PRE_first_tail_x15_r0_body.s1644.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa186.obj (objOf PRE_first_tail_x15_r0_body.s1645 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1644 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg186_2673467 : PRE_first_tail_x15_r0_body.s1645.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1645 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk186_2673467 : (objOf PRE_first_tail_x15_r0_body.s1645 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm186_2673467 : PRE_first_tail_x15_r0_body.s1644.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa186.obj (objOf PRE_first_tail_x15_r0_body.s1645 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1644 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw186_4910 : (PRE_first_tail_x15_r0_body.s1645.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw186_2673472 : (PRE_first_tail_x15_r0_body.s1645.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw186_2673473 : (PRE_first_tail_x15_r0_body.s1645.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd186 : PRE_first_tail_x15_r0_body.cl186.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr186 : PRE_first_tail_x15_r0_body.st186.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1643.next || PRE_first_tail_x15_r0_body.cl186.contains b) = true
def PRE_first_tail_x15_r0_body.zl186 : List Nat := PRE_first_tail_x15_r0_body.cl186.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE186 : PRE_first_tail_x15_r0_body.zl186.map (fun a => PRE_first_tail_x15_r0_body.s1644.heap.get (PRE_first_tail_x15_r0_body.kappa186.a a)) = PRE_first_tail_x15_r0_body.zl186.map (fun a => (PRE_first_tail_x15_r0_body.s1645.heap.get a).map PRE_first_tail_x15_r0_body.kappa186.hobj)
theorem PRE_first_tail_x15_r0_body.zimg186 : HeapImg PRE_first_tail_x15_r0_body.kappa186 PRE_first_tail_x15_r0_body.s1645 PRE_first_tail_x15_r0_body.s1644 PRE_first_tail_x15_r0_body.zl186 := PRE_first_tail_x15_r0_body.zimgE186
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl186 : PRE_first_tail_x15_r0_body.s1644.ctl = PRE_first_tail_x15_r0_body.kappa186.ctl PRE_first_tail_x15_r0_body.s1645.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack186 : PRE_first_tail_x15_r0_body.s1644.stack = PRE_first_tail_x15_r0_body.s1645.stack.map PRE_first_tail_x15_r0_body.kappa186.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs186 : PRE_first_tail_x15_r0_body.s1644.jobs = PRE_first_tail_x15_r0_body.s1645.jobs.map PRE_first_tail_x15_r0_body.kappa186.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores186 : PRE_first_tail_x15_r0_body.s1644.stores = PRE_first_tail_x15_r0_body.kappa186.stores PRE_first_tail_x15_r0_body.s1645.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots186 : checkRootsSupp PRE_first_tail_x15_r0_body.s1645 8054 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC186 : PRE_first_tail_x15_r0_body.S1643.tab.length + PRE_first_tail_x15_r0_body.cws186.length = 8054
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap186 : PRE_first_tail_x15_r0_body.kappa186 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1643.next 2822402 PRE_first_tail_x15_r0_body.S1643.tab.length PRE_first_tail_x15_r0_body.pl186 (PRE_first_tail_x15_r0_body.nr186.map NumV.ref) PRE_first_tail_x15_r0_body.kd186.big
  PRE_first_tail_x15_r0_body.kd186.region PRE_first_tail_x15_r0_body.kd186.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin186 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1645.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc186 : Conv.jcleanListB (⟨21873, 18986, 2821253, 8054⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1645 PRE_first_tail_x15_r0_body.cl186 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2186 : noBigRootsP (fun i => !Conv.oldBigB (⟨21873, 18986, 2821253, 8054⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1645.trace PRE_first_tail_x15_r0_body.s1645 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm186 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18959 = true
theorem PRE_first_tail_x15_r0_body.cjcl186 (h : Conv.JClean (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1643) : Conv.JClean (⟨21873, 18986, 2821253, 8054⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1645 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle186)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap186 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd186 a ha)) PRE_first_tail_x15_r0_body.zjc186

end Host.Load.Run.Tpl

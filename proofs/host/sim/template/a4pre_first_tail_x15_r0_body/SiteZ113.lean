import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS113
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK113
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF113
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 113 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1092`, the merged
state `PRE_first_tail_x15_r0_body.s1093`, the canonical state `PRE_first_tail_x15_r0_body.s1094`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl113 : PRE_first_tail_x15_r0_body.pl113.all (Nat.ble PRE_first_tail_x15_r0_body.s1092.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd113 : nodupT PRE_first_tail_x15_r0_body.pl113 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1113 : Nat.ble PRE_first_tail_x15_r0_body.s1092.next 2763262 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst113 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1092.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn113 : PRE_first_tail_x15_r0_body.s1094.next = PRE_first_tail_x15_r0_body.s1092.next + PRE_first_tail_x15_r0_body.pl113.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn113 : PRE_first_tail_x15_r0_body.s1093.next = 2763262
kernel_rfl PRE_first_tail_x15_r0_body.zgrow113 : Nat.ble PRE_first_tail_x15_r0_body.s1094.next PRE_first_tail_x15_r0_body.s1093.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh113 : PRE_first_tail_x15_r0_body.S1092.tab.all (fun e => PRE_first_tail_x15_r0_body.cws113.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd113 : nodupT PRE_first_tail_x15_r0_body.cws113 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi113 : PRE_first_tail_x15_r0_body.nr113.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1093.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt113 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1092.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg113_2665 : PRE_first_tail_x15_r0_body.s1094.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1094 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk113_2665 : (objOf PRE_first_tail_x15_r0_body.s1094 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm113_2665 : PRE_first_tail_x15_r0_body.s1093.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa113.obj (objOf PRE_first_tail_x15_r0_body.s1094 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1093 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg113_2673467 : PRE_first_tail_x15_r0_body.s1094.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1094 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk113_2673467 : (objOf PRE_first_tail_x15_r0_body.s1094 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm113_2673467 : PRE_first_tail_x15_r0_body.s1093.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa113.obj (objOf PRE_first_tail_x15_r0_body.s1094 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1093 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw113_4910 : (PRE_first_tail_x15_r0_body.s1094.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw113_2673472 : (PRE_first_tail_x15_r0_body.s1094.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw113_2673473 : (PRE_first_tail_x15_r0_body.s1094.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd113 : PRE_first_tail_x15_r0_body.cl113.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr113 : PRE_first_tail_x15_r0_body.st113.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1092.next || PRE_first_tail_x15_r0_body.cl113.contains b) = true
def PRE_first_tail_x15_r0_body.zl113 : List Nat := PRE_first_tail_x15_r0_body.cl113.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE113 : PRE_first_tail_x15_r0_body.zl113.map (fun a => PRE_first_tail_x15_r0_body.s1093.heap.get (PRE_first_tail_x15_r0_body.kappa113.a a)) = PRE_first_tail_x15_r0_body.zl113.map (fun a => (PRE_first_tail_x15_r0_body.s1094.heap.get a).map PRE_first_tail_x15_r0_body.kappa113.hobj)
theorem PRE_first_tail_x15_r0_body.zimg113 : HeapImg PRE_first_tail_x15_r0_body.kappa113 PRE_first_tail_x15_r0_body.s1094 PRE_first_tail_x15_r0_body.s1093 PRE_first_tail_x15_r0_body.zl113 := PRE_first_tail_x15_r0_body.zimgE113
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl113 : PRE_first_tail_x15_r0_body.s1093.ctl = PRE_first_tail_x15_r0_body.kappa113.ctl PRE_first_tail_x15_r0_body.s1094.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack113 : PRE_first_tail_x15_r0_body.s1093.stack = PRE_first_tail_x15_r0_body.s1094.stack.map PRE_first_tail_x15_r0_body.kappa113.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs113 : PRE_first_tail_x15_r0_body.s1093.jobs = PRE_first_tail_x15_r0_body.s1094.jobs.map PRE_first_tail_x15_r0_body.kappa113.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores113 : PRE_first_tail_x15_r0_body.s1093.stores = PRE_first_tail_x15_r0_body.kappa113.stores PRE_first_tail_x15_r0_body.s1094.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots113 : checkRootsSupp PRE_first_tail_x15_r0_body.s1094 4885 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC113 : PRE_first_tail_x15_r0_body.S1092.tab.length + PRE_first_tail_x15_r0_body.cws113.length = 4885
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap113 : PRE_first_tail_x15_r0_body.kappa113 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1092.next 2763262 PRE_first_tail_x15_r0_body.S1092.tab.length PRE_first_tail_x15_r0_body.pl113 (PRE_first_tail_x15_r0_body.nr113.map NumV.ref) PRE_first_tail_x15_r0_body.kd113.big
  PRE_first_tail_x15_r0_body.kd113.region PRE_first_tail_x15_r0_body.kd113.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin113 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1094.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc113 : Conv.jcleanListB (⟨20420, 17518, 2763252, 4885⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1094 PRE_first_tail_x15_r0_body.cl113 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB113 : noBigRootsP (fun i => !Conv.oldBigB (⟨20420, 17518, 2763252, 4885⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1094.trace PRE_first_tail_x15_r0_body.s1094 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm113 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17518 = true
theorem PRE_first_tail_x15_r0_body.cjcl113 (h : Conv.JClean (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1092) : Conv.JClean (⟨20420, 17518, 2763252, 4885⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1094 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle113)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap113 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd113 a ha)) PRE_first_tail_x15_r0_body.zjc113

end Host.Load.Run.Tpl

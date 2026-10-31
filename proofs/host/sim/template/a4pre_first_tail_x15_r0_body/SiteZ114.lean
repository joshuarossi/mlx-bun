import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS114
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK114
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF114
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 114 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1013`, the merged
state `PRE_first_tail_x15_r0_body.s1014`, the canonical state `PRE_first_tail_x15_r0_body.s1015`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl114 : PRE_first_tail_x15_r0_body.pl114.all (Nat.ble PRE_first_tail_x15_r0_body.s1013.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd114 : nodupT PRE_first_tail_x15_r0_body.pl114 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1114 : Nat.ble PRE_first_tail_x15_r0_body.s1013.next 2765878 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst114 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1013.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn114 : PRE_first_tail_x15_r0_body.s1015.next = PRE_first_tail_x15_r0_body.s1013.next + PRE_first_tail_x15_r0_body.pl114.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn114 : PRE_first_tail_x15_r0_body.s1014.next = 2765878
kernel_rfl PRE_first_tail_x15_r0_body.zgrow114 : Nat.ble PRE_first_tail_x15_r0_body.s1015.next PRE_first_tail_x15_r0_body.s1014.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh114 : PRE_first_tail_x15_r0_body.S1013.tab.all (fun e => PRE_first_tail_x15_r0_body.cws114.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd114 : nodupT PRE_first_tail_x15_r0_body.cws114 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi114 : PRE_first_tail_x15_r0_body.nr114.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1014.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt114 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1013.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg114_2665 : PRE_first_tail_x15_r0_body.s1015.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1015 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk114_2665 : (objOf PRE_first_tail_x15_r0_body.s1015 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm114_2665 : PRE_first_tail_x15_r0_body.s1014.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa114.obj (objOf PRE_first_tail_x15_r0_body.s1015 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1014 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg114_2673467 : PRE_first_tail_x15_r0_body.s1015.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1015 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk114_2673467 : (objOf PRE_first_tail_x15_r0_body.s1015 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm114_2673467 : PRE_first_tail_x15_r0_body.s1014.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa114.obj (objOf PRE_first_tail_x15_r0_body.s1015 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1014 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw114_4910 : (PRE_first_tail_x15_r0_body.s1015.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw114_2673472 : (PRE_first_tail_x15_r0_body.s1015.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw114_2673473 : (PRE_first_tail_x15_r0_body.s1015.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd114 : PRE_first_tail_x15_r0_body.cl114.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr114 : PRE_first_tail_x15_r0_body.st114.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1013.next || PRE_first_tail_x15_r0_body.cl114.contains b) = true
def PRE_first_tail_x15_r0_body.zl114 : List Nat := PRE_first_tail_x15_r0_body.cl114.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE114 : PRE_first_tail_x15_r0_body.zl114.map (fun a => PRE_first_tail_x15_r0_body.s1014.heap.get (PRE_first_tail_x15_r0_body.kappa114.a a)) = PRE_first_tail_x15_r0_body.zl114.map (fun a => (PRE_first_tail_x15_r0_body.s1015.heap.get a).map PRE_first_tail_x15_r0_body.kappa114.hobj)
theorem PRE_first_tail_x15_r0_body.zimg114 : HeapImg PRE_first_tail_x15_r0_body.kappa114 PRE_first_tail_x15_r0_body.s1015 PRE_first_tail_x15_r0_body.s1014 PRE_first_tail_x15_r0_body.zl114 := PRE_first_tail_x15_r0_body.zimgE114
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl114 : PRE_first_tail_x15_r0_body.s1014.ctl = PRE_first_tail_x15_r0_body.kappa114.ctl PRE_first_tail_x15_r0_body.s1015.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack114 : PRE_first_tail_x15_r0_body.s1014.stack = PRE_first_tail_x15_r0_body.s1015.stack.map PRE_first_tail_x15_r0_body.kappa114.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs114 : PRE_first_tail_x15_r0_body.s1014.jobs = PRE_first_tail_x15_r0_body.s1015.jobs.map PRE_first_tail_x15_r0_body.kappa114.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores114 : PRE_first_tail_x15_r0_body.s1014.stores = PRE_first_tail_x15_r0_body.kappa114.stores PRE_first_tail_x15_r0_body.s1015.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots114 : checkRootsSupp PRE_first_tail_x15_r0_body.s1015 4976 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC114 : PRE_first_tail_x15_r0_body.S1013.tab.length + PRE_first_tail_x15_r0_body.cws114.length = 4976
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap114 : PRE_first_tail_x15_r0_body.kappa114 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1013.next 2765878 PRE_first_tail_x15_r0_body.S1013.tab.length PRE_first_tail_x15_r0_body.pl114 (PRE_first_tail_x15_r0_body.nr114.map NumV.ref) PRE_first_tail_x15_r0_body.kd114.big
  PRE_first_tail_x15_r0_body.kd114.region PRE_first_tail_x15_r0_body.kd114.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin114 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1015.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc114 : Conv.jcleanListB (⟨20457, 17564, 2764729, 4976⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1015 PRE_first_tail_x15_r0_body.cl114 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2114 : noBigRootsP (fun i => !Conv.oldBigB (⟨20457, 17564, 2764729, 4976⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1015.trace PRE_first_tail_x15_r0_body.s1015 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm114 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17537 = true
theorem PRE_first_tail_x15_r0_body.cjcl114 (h : Conv.JClean (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1013) : Conv.JClean (⟨20457, 17564, 2764729, 4976⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1015 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle114)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap114 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd114 a ha)) PRE_first_tail_x15_r0_body.zjc114

end Host.Load.Run.Tpl

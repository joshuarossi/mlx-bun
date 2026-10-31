import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS148
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK148
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF148
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 148 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1308`, the merged
state `PRE_first_tail_x15_r0_body.s1309`, the canonical state `PRE_first_tail_x15_r0_body.s1310`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl148 : PRE_first_tail_x15_r0_body.pl148.all (Nat.ble PRE_first_tail_x15_r0_body.s1308.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd148 : nodupT PRE_first_tail_x15_r0_body.pl148 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1148 : Nat.ble PRE_first_tail_x15_r0_body.s1308.next 2791217 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst148 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1308.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn148 : PRE_first_tail_x15_r0_body.s1310.next = PRE_first_tail_x15_r0_body.s1308.next + PRE_first_tail_x15_r0_body.pl148.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn148 : PRE_first_tail_x15_r0_body.s1309.next = 2791217
kernel_rfl PRE_first_tail_x15_r0_body.zgrow148 : Nat.ble PRE_first_tail_x15_r0_body.s1310.next PRE_first_tail_x15_r0_body.s1309.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh148 : PRE_first_tail_x15_r0_body.S1308.tab.all (fun e => PRE_first_tail_x15_r0_body.cws148.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd148 : nodupT PRE_first_tail_x15_r0_body.cws148 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi148 : PRE_first_tail_x15_r0_body.nr148.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1309.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt148 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1308.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg148_2665 : PRE_first_tail_x15_r0_body.s1310.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1310 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk148_2665 : (objOf PRE_first_tail_x15_r0_body.s1310 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm148_2665 : PRE_first_tail_x15_r0_body.s1309.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa148.obj (objOf PRE_first_tail_x15_r0_body.s1310 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1309 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg148_2673467 : PRE_first_tail_x15_r0_body.s1310.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1310 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk148_2673467 : (objOf PRE_first_tail_x15_r0_body.s1310 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm148_2673467 : PRE_first_tail_x15_r0_body.s1309.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa148.obj (objOf PRE_first_tail_x15_r0_body.s1310 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1309 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw148_4910 : (PRE_first_tail_x15_r0_body.s1310.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw148_2673472 : (PRE_first_tail_x15_r0_body.s1310.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw148_2673473 : (PRE_first_tail_x15_r0_body.s1310.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd148 : PRE_first_tail_x15_r0_body.cl148.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr148 : PRE_first_tail_x15_r0_body.st148.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1308.next || PRE_first_tail_x15_r0_body.cl148.contains b) = true
def PRE_first_tail_x15_r0_body.zl148 : List Nat := PRE_first_tail_x15_r0_body.cl148.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE148 : PRE_first_tail_x15_r0_body.zl148.map (fun a => PRE_first_tail_x15_r0_body.s1309.heap.get (PRE_first_tail_x15_r0_body.kappa148.a a)) = PRE_first_tail_x15_r0_body.zl148.map (fun a => (PRE_first_tail_x15_r0_body.s1310.heap.get a).map PRE_first_tail_x15_r0_body.kappa148.hobj)
theorem PRE_first_tail_x15_r0_body.zimg148 : HeapImg PRE_first_tail_x15_r0_body.kappa148 PRE_first_tail_x15_r0_body.s1310 PRE_first_tail_x15_r0_body.s1309 PRE_first_tail_x15_r0_body.zl148 := PRE_first_tail_x15_r0_body.zimgE148
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl148 : PRE_first_tail_x15_r0_body.s1309.ctl = PRE_first_tail_x15_r0_body.kappa148.ctl PRE_first_tail_x15_r0_body.s1310.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack148 : PRE_first_tail_x15_r0_body.s1309.stack = PRE_first_tail_x15_r0_body.s1310.stack.map PRE_first_tail_x15_r0_body.kappa148.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs148 : PRE_first_tail_x15_r0_body.s1309.jobs = PRE_first_tail_x15_r0_body.s1310.jobs.map PRE_first_tail_x15_r0_body.kappa148.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores148 : PRE_first_tail_x15_r0_body.s1309.stores = PRE_first_tail_x15_r0_body.kappa148.stores PRE_first_tail_x15_r0_body.s1310.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots148 : checkRootsSupp PRE_first_tail_x15_r0_body.s1310 6407 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC148 : PRE_first_tail_x15_r0_body.S1308.tab.length + PRE_first_tail_x15_r0_body.cws148.length = 6407
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap148 : PRE_first_tail_x15_r0_body.kappa148 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1308.next 2791217 PRE_first_tail_x15_r0_body.S1308.tab.length PRE_first_tail_x15_r0_body.pl148 (PRE_first_tail_x15_r0_body.nr148.map NumV.ref) PRE_first_tail_x15_r0_body.kd148.big
  PRE_first_tail_x15_r0_body.kd148.region PRE_first_tail_x15_r0_body.kd148.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin148 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1310.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc148 : Conv.jcleanListB (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1310 PRE_first_tail_x15_r0_body.cl148 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2148 : noBigRootsP (fun i => !Conv.oldBigB (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1310.trace PRE_first_tail_x15_r0_body.s1310 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm148 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18225 = true
theorem PRE_first_tail_x15_r0_body.cjcl148 (h : Conv.JClean (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1308) : Conv.JClean (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1310 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle148)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap148 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd148 a ha)) PRE_first_tail_x15_r0_body.zjc148

end Host.Load.Run.Tpl

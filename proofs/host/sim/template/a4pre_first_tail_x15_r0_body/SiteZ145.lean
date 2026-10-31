import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS145
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK145
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF145
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 145 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1281`, the merged
state `PRE_first_tail_x15_r0_body.s1282`, the canonical state `PRE_first_tail_x15_r0_body.s1283`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl145 : PRE_first_tail_x15_r0_body.pl145.all (Nat.ble PRE_first_tail_x15_r0_body.s1281.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd145 : nodupT PRE_first_tail_x15_r0_body.pl145 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1145 : Nat.ble PRE_first_tail_x15_r0_body.s1281.next 2788957 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst145 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1281.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn145 : PRE_first_tail_x15_r0_body.s1283.next = PRE_first_tail_x15_r0_body.s1281.next + PRE_first_tail_x15_r0_body.pl145.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn145 : PRE_first_tail_x15_r0_body.s1282.next = 2788957
kernel_rfl PRE_first_tail_x15_r0_body.zgrow145 : Nat.ble PRE_first_tail_x15_r0_body.s1283.next PRE_first_tail_x15_r0_body.s1282.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh145 : PRE_first_tail_x15_r0_body.S1281.tab.all (fun e => PRE_first_tail_x15_r0_body.cws145.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd145 : nodupT PRE_first_tail_x15_r0_body.cws145 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi145 : PRE_first_tail_x15_r0_body.nr145.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1282.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt145 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1281.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg145_2665 : PRE_first_tail_x15_r0_body.s1283.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1283 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk145_2665 : (objOf PRE_first_tail_x15_r0_body.s1283 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm145_2665 : PRE_first_tail_x15_r0_body.s1282.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa145.obj (objOf PRE_first_tail_x15_r0_body.s1283 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1282 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg145_2673467 : PRE_first_tail_x15_r0_body.s1283.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1283 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk145_2673467 : (objOf PRE_first_tail_x15_r0_body.s1283 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm145_2673467 : PRE_first_tail_x15_r0_body.s1282.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa145.obj (objOf PRE_first_tail_x15_r0_body.s1283 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1282 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw145_4910 : (PRE_first_tail_x15_r0_body.s1283.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw145_2673472 : (PRE_first_tail_x15_r0_body.s1283.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw145_2673473 : (PRE_first_tail_x15_r0_body.s1283.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd145 : PRE_first_tail_x15_r0_body.cl145.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr145 : PRE_first_tail_x15_r0_body.st145.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1281.next || PRE_first_tail_x15_r0_body.cl145.contains b) = true
def PRE_first_tail_x15_r0_body.zl145 : List Nat := PRE_first_tail_x15_r0_body.cl145.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE145 : PRE_first_tail_x15_r0_body.zl145.map (fun a => PRE_first_tail_x15_r0_body.s1282.heap.get (PRE_first_tail_x15_r0_body.kappa145.a a)) = PRE_first_tail_x15_r0_body.zl145.map (fun a => (PRE_first_tail_x15_r0_body.s1283.heap.get a).map PRE_first_tail_x15_r0_body.kappa145.hobj)
theorem PRE_first_tail_x15_r0_body.zimg145 : HeapImg PRE_first_tail_x15_r0_body.kappa145 PRE_first_tail_x15_r0_body.s1283 PRE_first_tail_x15_r0_body.s1282 PRE_first_tail_x15_r0_body.zl145 := PRE_first_tail_x15_r0_body.zimgE145
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl145 : PRE_first_tail_x15_r0_body.s1282.ctl = PRE_first_tail_x15_r0_body.kappa145.ctl PRE_first_tail_x15_r0_body.s1283.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack145 : PRE_first_tail_x15_r0_body.s1282.stack = PRE_first_tail_x15_r0_body.s1283.stack.map PRE_first_tail_x15_r0_body.kappa145.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs145 : PRE_first_tail_x15_r0_body.s1282.jobs = PRE_first_tail_x15_r0_body.s1283.jobs.map PRE_first_tail_x15_r0_body.kappa145.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores145 : PRE_first_tail_x15_r0_body.s1282.stores = PRE_first_tail_x15_r0_body.kappa145.stores PRE_first_tail_x15_r0_body.s1283.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots145 : checkRootsSupp PRE_first_tail_x15_r0_body.s1283 6278 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC145 : PRE_first_tail_x15_r0_body.S1281.tab.length + PRE_first_tail_x15_r0_body.cws145.length = 6278
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap145 : PRE_first_tail_x15_r0_body.kappa145 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1281.next 2788957 PRE_first_tail_x15_r0_body.S1281.tab.length PRE_first_tail_x15_r0_body.pl145 (PRE_first_tail_x15_r0_body.nr145.map NumV.ref) PRE_first_tail_x15_r0_body.kd145.big
  PRE_first_tail_x15_r0_body.kd145.region PRE_first_tail_x15_r0_body.kd145.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin145 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1283.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc145 : Conv.jcleanListB (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1283 PRE_first_tail_x15_r0_body.cl145 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2145 : noBigRootsP (fun i => !Conv.oldBigB (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1283.trace PRE_first_tail_x15_r0_body.s1283 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm145 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18162 = true
theorem PRE_first_tail_x15_r0_body.cjcl145 (h : Conv.JClean (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1281) : Conv.JClean (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1283 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle145)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap145 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd145 a ha)) PRE_first_tail_x15_r0_body.zjc145

end Host.Load.Run.Tpl

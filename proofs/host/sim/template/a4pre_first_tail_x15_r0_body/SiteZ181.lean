import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS181
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK181
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF181
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 181 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1749`, the merged
state `PRE_first_tail_x15_r0_body.s1750`, the canonical state `PRE_first_tail_x15_r0_body.s1751`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl181 : PRE_first_tail_x15_r0_body.pl181.all (Nat.ble PRE_first_tail_x15_r0_body.s1749.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd181 : nodupT PRE_first_tail_x15_r0_body.pl181 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1181 : Nat.ble PRE_first_tail_x15_r0_body.s1749.next 2817225 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst181 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1749.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn181 : PRE_first_tail_x15_r0_body.s1751.next = PRE_first_tail_x15_r0_body.s1749.next + PRE_first_tail_x15_r0_body.pl181.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn181 : PRE_first_tail_x15_r0_body.s1750.next = 2817225
kernel_rfl PRE_first_tail_x15_r0_body.zgrow181 : Nat.ble PRE_first_tail_x15_r0_body.s1751.next PRE_first_tail_x15_r0_body.s1750.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh181 : PRE_first_tail_x15_r0_body.S1749.tab.all (fun e => PRE_first_tail_x15_r0_body.cws181.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd181 : nodupT PRE_first_tail_x15_r0_body.cws181 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi181 : PRE_first_tail_x15_r0_body.nr181.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1750.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt181 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1749.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg181_2665 : PRE_first_tail_x15_r0_body.s1751.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1751 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk181_2665 : (objOf PRE_first_tail_x15_r0_body.s1751 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm181_2665 : PRE_first_tail_x15_r0_body.s1750.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa181.obj (objOf PRE_first_tail_x15_r0_body.s1751 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1750 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg181_2673467 : PRE_first_tail_x15_r0_body.s1751.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1751 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk181_2673467 : (objOf PRE_first_tail_x15_r0_body.s1751 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm181_2673467 : PRE_first_tail_x15_r0_body.s1750.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa181.obj (objOf PRE_first_tail_x15_r0_body.s1751 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1750 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw181_4910 : (PRE_first_tail_x15_r0_body.s1751.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw181_2673472 : (PRE_first_tail_x15_r0_body.s1751.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw181_2673473 : (PRE_first_tail_x15_r0_body.s1751.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd181 : PRE_first_tail_x15_r0_body.cl181.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr181 : PRE_first_tail_x15_r0_body.st181.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1749.next || PRE_first_tail_x15_r0_body.cl181.contains b) = true
def PRE_first_tail_x15_r0_body.zl181 : List Nat := PRE_first_tail_x15_r0_body.cl181.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE181 : PRE_first_tail_x15_r0_body.zl181.map (fun a => PRE_first_tail_x15_r0_body.s1750.heap.get (PRE_first_tail_x15_r0_body.kappa181.a a)) = PRE_first_tail_x15_r0_body.zl181.map (fun a => (PRE_first_tail_x15_r0_body.s1751.heap.get a).map PRE_first_tail_x15_r0_body.kappa181.hobj)
theorem PRE_first_tail_x15_r0_body.zimg181 : HeapImg PRE_first_tail_x15_r0_body.kappa181 PRE_first_tail_x15_r0_body.s1751 PRE_first_tail_x15_r0_body.s1750 PRE_first_tail_x15_r0_body.zl181 := PRE_first_tail_x15_r0_body.zimgE181
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl181 : PRE_first_tail_x15_r0_body.s1750.ctl = PRE_first_tail_x15_r0_body.kappa181.ctl PRE_first_tail_x15_r0_body.s1751.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack181 : PRE_first_tail_x15_r0_body.s1750.stack = PRE_first_tail_x15_r0_body.s1751.stack.map PRE_first_tail_x15_r0_body.kappa181.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs181 : PRE_first_tail_x15_r0_body.s1750.jobs = PRE_first_tail_x15_r0_body.s1751.jobs.map PRE_first_tail_x15_r0_body.kappa181.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores181 : PRE_first_tail_x15_r0_body.s1750.stores = PRE_first_tail_x15_r0_body.kappa181.stores PRE_first_tail_x15_r0_body.s1751.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots181 : checkRootsSupp PRE_first_tail_x15_r0_body.s1751 7817 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC181 : PRE_first_tail_x15_r0_body.S1749.tab.length + PRE_first_tail_x15_r0_body.cws181.length = 7817
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap181 : PRE_first_tail_x15_r0_body.kappa181 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1749.next 2817225 PRE_first_tail_x15_r0_body.S1749.tab.length PRE_first_tail_x15_r0_body.pl181 (PRE_first_tail_x15_r0_body.nr181.map NumV.ref) PRE_first_tail_x15_r0_body.kd181.big
  PRE_first_tail_x15_r0_body.kd181.region PRE_first_tail_x15_r0_body.kd181.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin181 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1751.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc181 : Conv.jcleanListB (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1751 PRE_first_tail_x15_r0_body.cl181 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB181 : noBigRootsP (fun i => !Conv.oldBigB (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1751.trace PRE_first_tail_x15_r0_body.s1751 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm181 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18873 = true
theorem PRE_first_tail_x15_r0_body.cjcl181 (h : Conv.JClean (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1749) : Conv.JClean (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1751 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle181)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap181 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd181 a ha)) PRE_first_tail_x15_r0_body.zjc181

end Host.Load.Run.Tpl
